
; modul DOSMUSE.ASM

; *****************************************************************************
;
;                          Ovl†d†n° programu
;
; *****************************************************************************

extrn    storekall:near,kurzlin:near,skokax:near,obrlin:near,edilin:near
extrn    editor:near,zobraz:near,menu:near,menexec:near,setwsel:near
extrn    select:near,wram1:near,wram2:near,setwsel:near,wnadpis:near
extrn    podklad:near,stinw:near,storesel:near,help:near,althelp:near
extrn    parbreak:word,edittop0:near,editall:near
extrn    zobtopini:near,zobhlp0:near,zoball:near,hledej:near,strom:near
extrn    editors:near,exten:near,endline:near,kurzoff:near,zobrfile:near
extrn    files:near,kurzon:near,endline:near,msgcek:near,diskfail:near
extrn    hledpol:near,adrpolsi:near,adrpoldi:near,cmpfile:near,obrpath:near
extrn    window:near,rozborn:near,topret:near,getkurz:near,readdir:near
extrn    creatfile:near,storfile:near,settabf:near,soucins:near
extrn    getatrib0:near,insertf:near,directory:near,delpolf:near
extrn    aktdisk:near,srcnxt:near,srcins:near,aktfile:near,space:near
extrn    storefile:near,hledpol0:near,menexc3:near,rozbor:near
extrn    obnovs:near,radeknul:near,srcins0:near,storekur:near
extrn    initmouse:near,initmous1:near,parrez:byte,prijem:near,vysil:near
extrn    quickv:near,outspc:near

public   uziv


uziv:                                     ;* inicializace povelovÇho ©†dku

         call      outhelp                  ; zobrazen° n†povàdy

         and       byte ptr cs:[config],not 10h ; zru®en° p©°znaku naáten°

         push      ds
         xor       ax,ax
         mov       ds,ax
         and       byte ptr ds:[0417h],not 3
         pop       ds

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

         mov       ax,3c00h                 ; kl†vesa F2 - uëiv. volby
         test      byte ptr ds:[conf3],2    ; poëaduje se uëiv. volba ?
         jnz       uziv045                  ; je poëadavek uëiv. volby

         call      mouseget                 ; test tlaá°tek my®i
         jz        uziv044                  ; nen° ë†dnÇ tlaá°tko

         call      mousemen                 ; vstup funkán° kl†vesy my®i
         jnc       uziv045                  ; je funkán° kl†vesa
         call      mousez                   ; obsluha my®i v z†kladn°m oknà
         jnc       uziv045                  ; navrac° se kl†vesa

uziv044: call      quickv                   ; rychlÇ zobrazen° souboru
         call      testkey                  ; test stavu kl†vesnice
         pushf
         lea       si,[tabhlp0]
         call      modihlp                  ; modifikace n†povàd
         call      modihlpalt               ; modifikace n†povàdy s Alt
         popf
         jz        uziv04                   ; áek†n° na zad†n° znaku

         call      inpkey                   ; vstup znaku z kl†vesnice
uziv045:
         call      getakt                   ; poskytnut° ukazatele aktiv. okna

         cmp       al," "
         jae       uziv046
         or        ah,ah
         jz        uziv046
         and       byte ptr cs:[config],not 10h ; zru®en° p©°znaku naáten°
         mov       byte ptr cs:[citacexp],8 ; nastaven° á°taáe
uziv046:
         call      quicks                   ; rychlÇ vyhled†v†n° poloëek
         and       byte ptr ds:[conf2],not 8; zru®en° nucenÇho p©°znaku SHIFT
         cmp       byte ptr ds:[numsrc],0   ; je znak v bufferu ?
         jne       uziv04                   ; je funkce rychlovyhled†v†n°

         or        ah,ah
         jz        uziv123                  ; je klavesa s ALT-
         cmp       al," "                   ; je ridici klavesa ?
         jb        uziv122                  ; je ridici klavesa
uziv123: jmp       uziv18                   ; vlozeni kodu klavesy

uziv122:                                  ;* obsluha kl†vesy
         mov       word ptr ds:[parbreak],0
         cmp       al,27                    ; je kl†vesa <Esc> ?
         jne       uziv12
         mov       al,19h                   ; n†hrada znakem ^Y (maz†n° ©†dku)
uziv12:
         call      getnuml
         mov       dx,cx                    ; poáet ©†dkñ se soubory

         cmp       word ptr ds:[poclin],0   ; je nàjakò znak v bufferu ?
         jne       uziv18                   ; v bufferu je nàjakò znak
         mov       bx,ds:[bp+11]            ; kurzor
         cmp       ah,73h                   ; je ^vlevo ?
         je        uziv1g                   ; je p©esun vlevo
         cmp       ah,4bh                   ; je kurzor vlevo ?
         jne       uziv1c                   ; nen° kurzor vlevo
         call      testsetw                 ; je plnÇ zobrazen° okna ?
         jz        uziv1g                   ; je plnÇ zobrazen° okna
         or        bx,bx                    ; je jië prvn° poloëka ?
         jz        uziv1c                   ; je jië prvn° poloëka
         jmp       setwleft                 ; posun kurzoru vlevo
uziv1g:  cmp       byte ptr ds:[bp+3],40    ; je levÇ okno ?
         jb        uziv1d                   ; je levÇ okno - neplat°
uziv1e:  mov       ax,0f09h                 ; n†hrada znakem tabel†toru

uziv1c:  cmp       ah,74h                   ; je ^vpravo ?
         je        uziv1h                   ; je p©esun vpravo
         cmp       ah,4dh                   ; je kurzor vpravo ?
         jne       uziv1d                   ; nen° kurzor vpravo
         call      testsetw                 ; je plnÇ zobrazen° okna ?
         jz        uziv1h                   ; je plnÇ zobrazen° okna
         inc       bx                       ; kurzor + 1
         cmp       bx,ds:[bp+7]             ; je jië posledn° poloëka ?
         jae       uziv1d                   ; je jië posledn° poloëka
uziv1j:  jmp       setwright                ; posun kurzoru vpravo
uziv1h:  cmp       byte ptr ds:[bp+3],40    ; je pravÇ okno ?
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
         lea       bx,[skokuziv]            ; tabulka skokñ do uëivat. funkce
         call      skokax                   ; skok do obsluhy funkce
         jnc       uziv1a                   ; k¢d kl†vesy nalezen - OK
         call      userxx                   ; obsluha uëivatelskòch funkc°

uziv16:                                   ;* obsluha editaán°ch funkc°

         cmp       ax,5100h                 ; je str†nka dolñ ?
         jne       uziv166                  ; nen° str†nka dolñ

         call      getnumf                  ; poáet souborñ v oknà
;         mov       cx,dx                    ; poáet ©†dkñ na str†nku
;         call      testsetw                 ; je plnÇ zobrazen° okna ?
;         jz        uziv163                  ; nen° trojsloupcovÇ zobrazen°
;         add       cx,dx
;         add       cx,dx
uziv163: add       cx,ds:[bp+9]             ; p©edpokl†danò konec seznamu
         cmp       cx,ds:[bp+7]             ; je jië konec seznamu ?
         jae       uziv166                  ; je jië konec seznamu
         call      usesedit                 ; posun o str†nku dolñ nebo nahoru
uziv165: mov       ax,7700h                 ; kl†vesa Ctrl-Home (horn° okraj)
uziv166: call      usesedit                 ; obsluha editaán°ch kl†ves
         cmp       ax,4900h                 ; byla str†nka nahoru ?
         jne       uziv1a                   ; nebyla str†nka nahoru
         cmp       word ptr ds:[bp+9],0     ; je zaá†tek seznamu ?
         jne       uziv165                  ; nen° zaá†tek seznamu - horn° okraj
uziv1a:  jmp       uziv0



public   setwleft
setwleft:                                 ;* posun kurzoru vlevo
         call      kurzoff                  ; vypnut° kurzoru
         mov       cx,ds:[bp+11]            ; kurzor
         sub       cx,dx                    ; sn°ëen° pozice kurzoru
         jnc       setwlef1
         xor       cx,cx
setwlef1:mov       ds:[bp+11],cx            ; nov† pozice kurzoru
         call      testshft                 ; je stisknut SHIFT ?
         jnz       setwlef5                 ; je SHIFT
         cmp       cx,ds:[bp+9]             ; je pod prvn° poloëkou ?
         jae       setwlef2                 ; nen° pod prvn° poloëkou
setwlef5:sub       ds:[bp+9],dx             ; sn°ëen° prvn°ho ©†dku
         jnc       setwlef3
         mov       word ptr ds:[bp+9],0
setwlef3:call      files                    ; novÇ zobrazen° souborñ
setwlef2:call      kurzon
setwlef4:jmp       short uziv1a


public   setwright
setwright:                                ;* posun kurzoru vpravo

setwrig0:call      kurzoff                  ; vypnut° kurzoru
         mov       cx,ds:[bp+11]            ; kurzor
         add       cx,dx                    ; zvò®en° pozice kurzoru
         mov       bx,ds:[bp+7]             ; poáet ©†dkñ
         dec       bx                       ; á°slo posledn°ho ©†dku
         cmp       cx,bx                    ; je nad posledn°m ©†dkem ?
         jbe       setwrig1                 ; nen° nad posledn°m ©†dkem
         mov       cx,bx                    ; omezen° na posledn° ©†dek
setwrig1:mov       ds:[bp+11],cx            ; nov† pozice kurzoru
         call      testshft                 ; je stisknut SHIFT ?
         jnz       setwrig6                 ; je SHIFT
         sub       cx,dx
         sub       cx,dx
         sub       cx,dx                    ; p©edpokl†dan† prvn° poloëka -1
         sub       cx,ds:[bp+9]             ; je posun konce ?
         jl        setwrig4                 ; nen° posun konce
setwrig6:mov       cx,ds:[bp+9]             ; prvn° poloëka
         add       cx,dx                    ; zvò®en° prvn° poloëky
         sub       bx,dx
         sub       bx,dx
         sub       bx,dx
         inc       bx                       ; maxim†ln° prvn° poloëka
         cmp       cx,bx
         jle       setwrig3
         mov       cx,bx
setwrig3:mov       ds:[bp+9],cx             ; nov† prvn° poloëka
         call      files                    ; novÇ zobrazen° souborñ
setwrig4:call      kurzon
         jmp       short setwlef4


public   mousez

mousez:                                   ;* ovl†d†n° my®i v z†kladn°m oknà
                                            ; VSTUP: BL=k¢d tlaá°tek
                                            ; VùSTUP: AX=k¢d funkán° kl†vesy
                                            ;         CY=nenavrac° se kl†vesa

         push      bx
         push      cx
         push      dx
         push      bp
         or        bl,bl
         jz        mousez8                  ; nen° ë†dnÇ tlaá°tko
         mov       dx,ds:[mousepoz]         ; pozice my®i
         cmp       bl,7                     ; je levÇ tlaá°tko 2x ?
         jne       mousez3                  ; nen° levÇ tlaá°tko 2x
         call      testaktw
         jc        mousez3
                                          ;* je funkce ENTER
         call      getatrib0                ; poskytnut° atributñ kurzoru
         jc        mousez8                  ; neplatnÇ á°slo poloëky
         mov       ax,2b1ch                 ; kl†vesa Ctrl-\
         test      bl,10h                   ; je adres†© ?
         jnz       mousez9                  ; je to adres†©
         mov       ax,1519h                 ; kl†vesa ^Y (vymaz†n° ©†dku)
         call      usesedit
         mov       ax,1c0dh                 ; kl†vesa <ENTER>
         clc
         jmp       short mousez9

mousez3:
                                          ;* nastaven° kurzoru na soubor
         call      getakt                   ; aktivn° okno
         call      mousezw                  ; nastaven° souboru v oknà
         call      getnakt                  ; neaktivn° okno
         call      mousezw                  ; nastaven° souboru v oknà

mousez8: stc
mousez9: pop       bp
         pop       dx
         pop       cx
         pop       bx
         ret

public   mousezw
mousezw:                                  ;* nastaven° kurzoru v oknà
                                            ; VSTUP: DX=pozice my®i

         push      bx
         push      cx
         push      dx
         cmp       bl,3                     ; drë° se tlaá°tko ?
         ja        mousezw8                 ; je funkce zmàny tlaá°tek
         call      testaktw
         jc        mousezw8                 ; nen° aktivn°
                                          ;* test, zda je kurzor v oknà
         push      dx
         call      getendl                  ; posledn° ©†dek okna
         inc       dh
         mov       ch,dh
         pop       dx
;mousezw1:
         sub       dl,ds:[bp+3]             ; relativn° pozice v oknà
         jb        mousezw8                 ; nen° v oknà
         cmp       dl,39                    ; je za okrajem ?
         ja        mousezw8                 ; nen° v oknà
         jb        mousezw3
         dec       dl                       ; o©ez†n° max. pozice
mousezw3:
;         or        dh,dh                    ; je prvn° ©†dek ?
;         je        mousezw8                 ; nen° v oknà
         cmp       dh,ch                    ; je pod oknem ?
         ja        mousezw8                 ; nen° v oknà
                                          ;* p©epnut° okna na aktivn°
         call      testakt                  ; je okno aktivn° ?
         je        mousezw2                 ; okno je jië aktivn°
         push      bp
         call      getakt                   ; poskytnut° aktivn°ho okna
         call      xchgakt                  ; zmàna aktivn°ho okna
         pop       bp
mousezw2:                                 ;* vòpoáet novÇho souboru
         call      mousezf                  ; nalezen° á°sla souboru

mousezw8:pop       dx
         pop       cx
         pop       bx
         ret

public   mousezf
mousezf:                                  ;* nastaven° na soubor
                                            ; VSTUP: DX=rel. pozice my®i v oknà
                                            ;        CH=á°slo posledn°ho ©†dku
                                            ;        BP=tabulka okna
                                            ; VùSTUP: AX=á°slo souboru

         push      cx
         push      dx

         sub       ch,5                     ; poáet poloëek ve sloupci
         sub       dh,4                     ; odeáten° horn°ho okraje
         jae       mousezf7                 ; nen° posun nahoru
                                          ;* plynulò posun nahoru
mousezf0:cmp       word ptr cs:[bp+11],0    ; je jië dosaëeno prvn° poloëky ?
         je        mousezf6                 ; je jië prvn° poloëka
         mov       ax,4800h                 ; k¢d kurzoru nahoru
mousezfa:call      mouseins
         call      usesedit                 ; posuv kurzoru nahoru
         jmp       short mousezf4

mousezf7:cmp       dh,ch                    ; je spodn° okraj ?
         jb        mousezf8                 ; nen° spodn° okraj
                                          ;* plynulò posun dolñ
mousezf9:mov       ax,cs:[bp+7]             ; poáet poloëek v seznamu
         dec       ax
         cmp       word ptr cs:[bp+11],ax   ; je jië posledn° poloëka ?
         je        mousezf6                 ; je jië posledn° poloëka
         mov       ax,5000h                 ; k¢d kurzoru dolñ
         jmp       short mousezfa           ; posun dolñ
mousezf8:                                 ;* vòpoáet relativn°ho ©†dku
         dec       ch
         call      testsetw                 ; je trojsloupcovÇ zobrazen° ?
         jz        mousezf5                 ; je plnÇ zobrazen° okna

mousezf1:sub       dl,13
         jb        mousezf2                 ; je jië spr†vnò ©†dek
         add       dh,ch                    ; p©iáten° posledn°ho ©†dku
         inc       dh
         jmp       short mousezf1           ; dal®° test
mousezf5:
mousezf2:
         mov       al,dh                    ; relativn° ©†dek
         cbw
         add       ax,cs:[bp+9]             ; vòpoáet á°sla poloëky
         mov       dx,cs:[bp+7]             ; poáet poloëek
         dec       dx                       ; posledn° poloëka
         cmp       ax,dx
         jbe       mousezf3
         mov       ax,dx                    ; n†hradn° á°slo poloëky
mousezf3:test      bl,2                     ; je pravÇ tlaá°tko ?
         jz        mousezfc                 ; nen° pravÇ tlaá°tko
         test      byte ptr cs:[insmouse],1 ; je prvn° poloëka ?
         jnz       mousezfb                 ; je prvn° poloëka
mousezfc:cmp       ax,cs:[bp+11]            ; je jië dosaëeno pozice kurzoru ?
         je        mousezf6                 ; je jië pozice kurzoru
mousezfb:                                 ;* nastaven° na soubor
         call      kurzoff                  ; vypnut° kurzoru
         mov       cs:[bp+11],ax            ; nov† pozice kurzoru
         call      kurzon                   ; zapnut° kurzoru
mousezf4:                                 ;* byl posun kurzoru
         call      mouseins                 ; oznaáen° souboru

mousezf6:pop       dx
         pop       cx
         ret

mouseins:                                 ;* oznaáen° jednoho souboru
         push      ax
         push      ds
         push      si
         test      bl,2                     ; je pravÇ tlaá°tko ?
         jz        mousein2                 ; nen° pravÇ tlaá°tko
         call      getkurz                  ; poskytnut° adresy kurzoru
         jc        mousein2                 ; nen° platnò kurzor
         test      byte ptr ds:[si],10h
         jnz       mousein2                 ; je to adres†©
         mov       al,cs:[insmouse]         ; poëadovanÇ nastaven° oznaáen°
         test      al,1                     ; je nastaveno oznaáov†n° ?
         jz        mousein1                 ; oznaáov†n° je nastaveno
         mov       al,ds:[si]               ; aktu†ln° oznaáen°
         not       al                       ; negace AL
         and       al,80h                   ; novÇ oznaáen°
         mov       byte ptr cs:[insmouse],al ; novÇ oznaáen°
mousein1:and       byte ptr ds:[si],7fh     ; zru®en° oznaáen°
         or        byte ptr ds:[si],al      ; nastaven° oznaáen°
         push      cs
         pop       ds
         call      endline                  ; zobrazen° koncovÇho ©†dku
         call      kurzon                   ; novÇ zobrazen° kurzoru
mousein2:pop       si
         pop       ds
         pop       ax
         ret


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

;         mov       al,18
;         test      byte ptr ds:[flags],4    ; je aktivn° n†povàda ?
;         jnz       usesedi2                 ; je aktivn° n†povàda
;         inc       al
;usesedi2:test      byte ptr ds:[bp+29],1    ; je dvousloupcovÇ zobrazen° ?
;         jz        usesedi3                 ; nen° dvousloupcovÇ zobrazen°
;         mov       ah,al
;         add       al,al
;         add       al,ah                    ; poáet ©†dkñ * 3
;usesedi3:mov       ds:[delrol],al
         pop       ax

         push      bp
         lea       bp,[comlin]              ; definice povelovÇho ©†dku
         call      edilin                   ; editace povelovÇho ©†dku
         pop       bp
         call      retwind                  ; n†vrat parametrñ okna po editaci
         pop       ds
         ret



public   skokuziv

skokuziv label     word                     ; tabulka skokñ do uëivatel. funkc°

         db        00h+14                   ; testuje se AL
         db        02h                      ; zap/vyp n†povàdy CTRL-B
         dw        offset sethlp
         db        09h                      ; p©epnut° oken ^I, TAB
         dw        offset xchgakt
         db        0ah                      ; p©enesen° jmÇna CTRL-ENTER, ^J
         dw        offset ctrlent
IFDEF    upver
         db        0bh                      ; trojsloupcovÇ zobrazen° ^K
         dw        offset setsetw
ELSE
         db        0bh                      ; opàtovnÇ naáten° neakt.adres†©e ^K
         dw        offset rereadk
ENDIF
         db        0ch                      ; zap/vyp druhÇho okna CTRL-L
         dw        offset xchgw
         db        0dh                      ; ENTER, ^M
         dw        offset enterx
         db        0eh                      ; opàtovnÇ naáten° akt. adres. ^N
         dw        offset reread
         db        0fh                      ; zap/vyp obou oken CTRL-O
         dw        offset xchgall
IFDEF    upver
         db        11h                      ; rychlò prohl°ëeá ^Q
         dw        offset setquickv
ELSE
         db        11h                      ; zmàna zobrazen° ^Q
         dw        offset setsetw
ENDIF
         db        15h                      ; z†màna oken CTRL-U
         dw        offset xchgwind
         db        16h                      ; oznaáen° souboru CTRL-V
         dw        offset insert
         db        1ch                      ; Zmàna adres†©e ^\
         dw        offset xchgpath
         db        1dh                      ; n†vrat posledn°ho vòbàru ^]
         dw        offset selback
         db        1eh                      ; vòbàr spustitelnòch programñ ^^
         dw        offset selfcom

         db        80h+4                    ; testuje se AX
         dw        0f00h                    ; p©epnut° oken SHIFT-TAB
         dw        offset xchgakt
         dw        9200h                    ; inverze vòbàru CTRL-INS
         dw        offset invsel
         dw        9000h                    ; vòbàr v®ech souborñ CTRL+
         dw        offset selfall
         dw        8e00h                    ; zru®en° vòbàru v®ech souborñ CTRL-
         dw        offset unselfall

         db        40h+32                   ; testuje se AH
         db        44h                      ; konec programu F10
         dw        offset keyf10
         db        52h                      ; oznaáen° souboru INS
         dw        offset insert
         db        4eh                      ; oznaáen° souborñ +
         dw        offset selplus
         db        4ah                      ; oznaáen° souborñ -
         dw        offset selminus
         db        3dh                      ; prohl°ëen° souborñ F3
         dw        offset zobraz
         db        6ah                      ; prohl°ëen° souborñ Alt-F3
         dw        offset zobrazx
         db        3eh                      ; editace souborñ F4
         dw        offset editor
         db        6bh                      ; editace souborñ Alt-F4
         dw        offset editorx
         db        57h                      ; editace souborñ Shift-F4
         dw        offset editors
         db        3fh                      ; kop°rov†n° F5
         dw        offset copyfile
         db        6ch                      ; kop°rov†n° jednoho souboru ALT-F5
         dw        offset copyfile1
         db        40h                      ; p©esun souborñ F6
         dw        offset movefile
         db        6dh                      ; p©esun jednoho souboru ALT-F6
         dw        offset movefile1
         db        41h                      ; vyto©en° adres†©e F7
         dw        offset vytvadr
         db        42h                      ; ru®en° souborñ F8
         dw        offset delfile
         db        6fh                      ; ru®en° 1 souboru ALT-F8
         dw        offset delfile1
         db        55h                      ; historie p©°kazñ SHIFT-F2
         dw        offset povely
         db        68h                      ; nastaven° levÇho disku ALT-F1
         dw        offset setdskl
         db        69h                      ; nastaven° pravÇho disku ALT-F2
         dw        offset setdskr
         db        3bh                      ; n†povàda F1
         dw        offset help
         db        54h                      ; n†povàda SHIFT-F1
         dw        offset althelp
         db        71h                      ; strom ALT-F10
         dw        offset strom
         db        6eh                      ; vyhled†v†n° ALT-F7
         dw        offset hledej
         db        3ch                      ; uëivatelskÇ volby F2
         dw        offset menu
         db        43h                      ; atributy F9
         dw        offset atrfile
         db        70h                      ; porovn†n° Alt-F9
         dw        offset compfile
         db        5bh                      ; obnoven° souborñ Shift-F8
         dw        offset obnov
         db        5ch                      ; t©°dàn° souborñ Shift-F9
         dw        offset sortfile
         db        37h                      ; inverze vòbàru [*]
         dw        offset invsel
         db        58h                      ; vys°l†n° souborñ Shift-F5
         dw        offset vysil
         db        59h                      ; p©°jem souborñ Shift-F6
         dw        offset prijem
         db        5dh                      ; EGA 43 ©†dkñ Shift-F10
         dw        offset ega43

         db        0

; -----------------------------------------------------------------------------
public   setquickv
setquickv:                                ;* rychlò prohl°ëeá ^Q
         xor       byte ptr ds:[conf5],2    ; zmàna p©°znaku rychlÇho prohl°ëeáe
         call      windretx
         ret
; -----------------------------------------------------------------------------
public   keyf10

keyf10:                                   ;* ukonáen° programu F10
         lea       di,[txtkon1]             ; nadpis 'Chcete ukonáit program ?'
         lea       si,[txtkon2]             ; volby Ano/Ne
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
         mov       es,ds:[segrez]           ; segment rezidentn°ch dat
         xor       al,al
         mov       es:[80h],al              ; vymaz†n° p©°kazovÇho ©†dku
         jmp       mainx                    ; n†vrat do systÇmu

; -----------------------------------------------------------------------------
public   setsetw

setsetw:                                  ;* zmàna zobrazen° okna
         xor       byte ptr cs:[bp+29],1    ; zmàna p©°znaku zobrazen° okna
         xor       ax,ax
         call      usesedit                 ; normalizace zobrazen° oken
         call      windretx                 ; p©ekreslen° okna
         ret

; -----------------------------------------------------------------------------
public   userxx

userxx:                                   ;* uëivatelskÇ funkce

         or        al,al
         jnz       userxx9                  ; nezn†m† kl†vesa
         mov       bh,ah
         lea       di,[outbuf]
         lea       si,[fileuser]            ; jmÇno programu USER.BAT
         call      transtxt                 ; p©enos jmÇna programu
         sub       bh,5dh                   ; je nië®° k¢d neë Ctrl-F1 ?
         jbe       userxx9                  ; je nië®° k¢d neë Ctrl-F1
         cmp       bh,10                    ; je kl†vesa Ctrl-F10 nebo nië®° ?
         jbe       userxx4                  ; je Ctrl-F10 nebo nië®° - OK
         mov       bh,ah
         sub       bh,85h-11                ; vòpoáet kl†vesy F11 ...
         cmp       bh,11
         jb        userxx9
         cmp       bh,18
         ja        userxx9
userxx4: mov       al,bh                    ; á°slo funkce
         xor       ah,ah
         xor       dx,dx
         call      deknum                   ; dek¢dov†n° á°sla
         lea       si,[outbuf]              ; jmÇno funkce
         jmp       short editxx1            ; vyvol†n° programu USERxx.BAT

userxx9: stc                                ; kl†vesa nenalezena
         ret

; -----------------------------------------------------------------------------
public   zobrazx

zobrazx:                                  ;* zobrazen° souboru ALT-F3

        lea        si,[filewiev]            ; jmÇno souboru "VIEW"
        jmp        short editxx1            ; vyvol†n° programu VIEW.BAT

; -----------------------------------------------------------------------------
public   editorx

editorx:                                  ;* vnàj®° editor ALT-F4

         lea       si,[fileedit]            ; jmÇno souboru "EDIT"
editxx1:                                  ;* cesta k domovskÇmu adres†©i
         xor       di,di                    ; ukl†dac° adresa
         mov       es,cs:[topseg]           ; segment k uloëen° dat
         call      menexc3                  ; p©enesen° domovskÇ cesty
         call      transtxt                 ; p©enesen° jmÇna souboru
         lea       si,[filebat]             ; p©°pona
         call      transtxt                 ; p©enesen° p©°pony programu BAT
         push      cs
         pop       es
         mov       ds:[editnum],di          ; poáet znakñ textu
         xor       si,si                    ; adresa textu (v (TOPSEG):)
         jmp       menexec                  ; proveden° p©°kazu

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
;         mov       dx,18
;         call      testakth
;         jnc       retwind1
;         inc       dx
;retwind1:
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
;         call      endline                  ; zobrazen° spodn°ho ©†dku
retwind9:pop       dx
         pop       cx
         pop       bx
         pop       ax
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
pathcm2: mov       cs:[bp+dellin-comlin],al ; ®°©ka ©†dku textu
         mov       cs:[bp+pozlin-comlin],dx ; pozice zaá†tku textu
         call      mouseon                  ; zapnut° my®i
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   setdskl,setdskr,setdsk11

setdskl:                                  ;* p©epnut° disku pro levÇ okno ALT-1
         call      getakt                   ; aktivn° okno
         cmp       byte ptr ds:[bp+3],20    ; je levÇ okno ?
         jb        setdsk1                  ; je levÇ okno
         jmp       short setdsk0

setdskr:                                  ;* p©epnut° disku pro pravÇ okno ALT-2
         call      getakt                   ; aktivn° okno
         cmp       byte ptr ds:[bp+3],20    ; je pravÇ okno ?
         jae       setdsk1                  ; je pravÇ okno
setdsk0: call      getnakt                  ; druhÇ okno

setdsk1:
                                          ;* sestaven° nadpisu
         lea       di,[outbuf]              ; pracovn° buffer
         lea       si,[txtdisk1]
setdsk11:
         call      transtxt                 ; p©enos textu "Zmàna disku pro "
         lea       si,[txtdisk2]            ; text "levÇ"
         cmp       byte ptr ds:[bp+3],20    ; je levÇ okno ?
         jb        setdsk2                  ; je levÇ okno
         lea       si,[txtdisk3]            ; text "pravÇ
setdsk2: call      transtxt                 ; p©enos textu

;         lea       si,[txtdisk4]            ; text "okno:"
;         call      transtxt                 ; p©enos textu
                                          ;* sestaven° textu voleb
         lea       di,[outbuf]              ; pracovn° buffer
         mov       bx,ds:[bp+4]             ; adresa cesty
         xchg      di,si                    ; £schova DI do SI
         lea       di,[selbuf]
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

public   reread
reread:                                   ;* opàtovnÇ naáten° aktivn°ho adres†©e
         call      storekall                ; £schova pozice kurzorñ obou oken
         and       byte ptr ds:[bp+0],not 6 ; p©°znak, ëe adres†© nen° naáten
setdsk9:
         call      windretx                 ; n†vrat zobrazen° oken
         xor       ax,ax
         call      usesedit                 ; normalizace kurzoru
         ret

IFNDEF   upver
public   rereadk
rereadk:                                  ;* opàtovnÇ naáten° neaktivn°ho adres.
         call      getnakt                  ; neaktivn° okno
         jmp       short reread             ; opàtovnÇ naáten° adres†©e
ENDIF
; -----------------------------------------------------------------------------
public   egaget

egaget:                                   ;* poskytnut° informac° o EGA
                                            ; VùSTUP: CY=nen° EGA

         push      ax
         push      bx
         push      cx
         push      dx
         push      bp
         push      es
         and       byte ptr cs:[flags],not 10h ; zru®en° p©°znaku fontu 8x8
         call      egaask                   ; test videokarty EGA
         jc        egaget4                  ; karta nen° nainstalov†na
         cmp       dh,8                     ; je font 8x8 bodñ ?
         jne       egaget1                  ; nen° font 8x8 bodñ
         or        byte ptr cs:[flags],10h  ; p©°znak fontu 8x8 bodñ
egaget1: clc
egaget4: mov       cs:[displ],dl            ; novò posledn° ©†dek displeje
         pop       es
         pop       bp
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   egaask

egaask:                                   ;* dotaz na stav EGA karty
                                            ; VùSTUP: CY=nen° EGA
                                            ;         DL=poáet ©†dkñ
                                            ;         DH=poáet linek na znak

         push      ax
         push      bx
         push      cx

         mov       ah,12h
         mov       bl,10h
         int       10h                      ; poskytnut° informac° o EGA
         cmp       bl,10h                   ; je karta nainstalov†na ?
         stc
         mov       dh,8                     ; poáet linek na znak
         mov       dl,24                    ; n†hradn° posledn° ©†dek = 24
         je        egaask2                  ; karta nen° nainstalov†na
                                          ;* zji®tàn° parametrñ ©†dkov†n°
         push      ds
         xor       ax,ax
         mov       ds,ax                    ; DS <- 0
         mov       dx,ds:[484h]             ; DL<-poáet ©†dkñ, DH<-poáet linek
         pop       ds                       ; n†vrat DS

egaask2: pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   ega43

ega43:                                    ;* zmàna ©†dkov†n° 43 ©†dkñ Alt-F9

         call      egaset                   ; zmàna ©†dkov†n° displeje

         call      getakt
         xor       ax,ax
         call      usesedit                 ; normalizace kurzoru
         call      getnakt
         xor       ax,ax
         call      usesedit
         call      windretx
         ret

public   egaset
egaset:                                   ;* zmàna ©†dkov†n° displeje

         call      mouseoff
         mov       cx,40h
         mov       ds,cx
         call      egaask                   ; poskytnut° ©†dkov†n° displeje
         push      dx                       ; pñvodn° nastaven° ©†dkov†n°
                                          ;* nastaven° norm†ln°ho videom¢du
         mov       ah,0fh
         int       10h                      ; poskytnut° videom¢du
         xor       ah,ah
         int       10h                      ; incializace videom¢du

         call      egaask                   ; je videokarta EGA/VGA ?
         pop       dx                       ; pñvodn° ©†dkov†n° displeje
         jc        ega436                   ; nen° karta EGA/VGA
                                          ;* nastaven° karty EGA/VGA
         push      dx
         and       byte ptr ds:[87h],not 81h ; zru®en° p©°znaku ©†dkov†n° 43 ©†dkñ
         mov       ax,100h
         mov       cx,0607h
         int       10h                      ; nastaven° zobrazen° kurzoru
         pop       dx

         call      egaget                   ; nastaven° ©†dkov†n° EGA/VGA
         cmp       dh,8                     ; byl font 8x8 ?
         je        ega436                   ; byl font 8x8 - ponech† se novò
                                          ;* nastaven° fontu 8x8 bodñ
         and       byte ptr ds:[87h],not 80h ; zru®en° p©°znaku fontu 8x8
         mov       ax,1112h                 ; fonty 8x8
         xor       bl,bl
         int       10h                      ; nastaven° ©†dkov†n°
         or        byte ptr ds:[87h],1      ; p©°znak ©†dkov†n° 43 ©†dkñ

         mov       ax,100h
         mov       cx,0607h
         int       10h                      ; nastaven° zobrazen° kurzoru

         mov       ax,1200h
         mov       bl,20h
         int       10h                      ; nastaven° alternativn°ho tisku

         cli
         mov       dx,ds:[63h]              ; adresa portu EGA
         mov       al,0eh
         out       dx,al                    ; volba registru 0eh (adresa kurzoru)
         inc       dx
         mov       al,7
         out       dx,al                    ; nastaven° vy®®°ho bajtu adresy
         sti

ega436:  call      egaget                   ; aktualizace p©°znaku ©†dkov†n°
ega437:  call      initmous1                ; nov† definice my®i
;         push      cs
;         pop       ds
;         push      cs
;         pop       es
         ret

; -----------------------------------------------------------------------------
public   quicks
quicks:                                   ;* rychlÇ vyhled†v†n° poloëek
                                            ; VSTUP: AH=k¢d kl†vesy s Alt
                                            ;        DS,ES <- CS

         call      testaktw                 ; test zapnut° okna
         jc        quicks1                  ; okno je vypnuto
         call      testalt                  ; test stisku kl†vesy Alt
         jnz       quicks2                  ; kl†vesa Alt je stisknuta
quicks1: ret
quicks2:
         push      ax
         push      bx
         push      cx
         push      di
                                          ;* nastaven° ukazatelñ
         mov       cx,word ptr ds:[numsrc]  ; poáet znakñ v bufferu
         lea       di,[bufsrc]              ; buffer pro rychlÇ vyhled†v†n°
         add       di,cx                    ; ukl†dac° adresa do bufferu
         xor       bx,bx                    ; poá†teán° soubor k hled†n°
                                          ;* je platnò znak ?
         call      prevalt                  ; p©evod na znak ASCII
         jc        quicks4                  ; nen° platnò znak ASCII
                                          ;* uloëen° znaku do bufferu
         cmp       cx,11                    ; je buffer jië plnò ?
         jae       quicks8                  ; buffer je jië plnò
         stosb                              ; uloëen° znaku do bufferu
         inc       cx                       ; zvò®en° á°taáe znakñ v bufferu
         jmp       short quicks5            ; zobrazen° prvn°ho souboru
quicks4:                                  ;* je jin† kl†vesa
         lea       bx,[tabquick]            ; tabulka skokñ
         call      skokax                   ; obsluha kl†vesy
         jc        quicks8                  ; nen° zn†m† kl†vesa

quicks5:                                  ;* aktualizace parametrñ bufferu
         mov       ds:[numsrc],cl           ; novò poáet znakñ
         push      cx
         sub       cl,11
         neg       cl                       ; doplnàk do 11
         mov       al,"?"
         rep       stosb                    ; vynulov†n° zbytku bufferu
         pop       cx
                                         ;* nalezen° dal®°ho souboru
         call      srcfilx                  ; nalezen° stejnÇho souboru
         jnc       quicks7                  ; odpov°daj°c° soubor nalezen
         call      srcfile                  ; nalezen° bl°zkÇho souboru
quicks7: xor       ax,ax
         call      usesedit                 ; normalizace poloëek
         call      kurzon                   ; zapnut° kurzoru na novÇ pozici
         call      endline                  ; koncovò ©†dek
         cmp       byte ptr ds:[numsrc],0   ; je nàjakò znak v bufferu ?
         jne       quicks8                  ; je v bufferu znak
         call      obrkurz                  ; zobrazen° kurzoru povel. ©†dku
quicks8:
         pop       di
         pop       cx
         pop       bx
         pop       ax
         ret


tabquick label     byte                   ;* tabulka kl†ves pro rychlovyhled.
         db        40h+8                    ; testuje se AH
         db        0eh                      ; BS
         dw        offset quickdel
         db        0a3h                     ; Delete
         dw        offset quickdel
         db        9bh                      ; kurzor vlevo
         dw        offset quicklf
         db        34h                      ; p©°pona "."
         dw        offset quickt
         db        0a0h                     ; kurzor dolñ
         dw        offset quickdn
         db        9fh                      ; posledn° poloëka END
         dw        offset quickend
         db        97h                      ; prvn° poloëka HOME
         dw        offset quickhom
         db        98h                      ; kurzor nahoru
         dw        offset quickup

         db        0


public   quickdel
quickdel:                                 ;* zru®en° znaku DELETE
         jcxz      quickdl2                 ; nen° dal®° znak
         dec       cx                       ; sn°ëen° á°taáe znakñ
         dec       di                       ; sn°ëen° ukazatele znakñ
         cmp       word ptr ds:[di-1],"??"  ; byl a bude znak "?" ?
         je        quickdel                 ; byl otazn°k
quickdl2:ret


public   quicklf
quicklf:                                  ;* posun o znak vlevo
         jcxz      quicklf2                 ; nen° dal®° znak
         dec       cx                       ; sn°ëen° á°taáe znakñ
         dec       di                       ; sn°ëen° ukazatele znakñ
quicklf2:ret


public   quickt
quickt:                                   ;* z†pis p©°pony
         cmp       cl,8
         jae       quickt3                  ; je jië p©°pona
         mov       al,"?"
         stosb                              ; uloëen° znaku "?"
         inc       cx
         jmp       short quickt             ; dal®° znak
quickt3: ret


public   quickup
quickup:                                  ;* kurzor nahoru
         mov       dx,ds:[bp+kurzl-tabl]    ; uschovan† pozice kurzoru
quickup1:mov       ax,bx                    ; £schova pozice kurzoru
         inc       bx                       ; n†sleduj°c° poloëka
         call      srcfilx                  ; nalezen° dal®° poloëky
         jc        quickup2                 ; nen° jië dal®° poloëka
         mov       bx,ds:[bp+kurzl-tabl]    ; nov† pozice kurzoru
         cmp       bx,dx                    ; je jië dosaëeno pozice kurzoru ?
         jb        quickup1                 ; nen° pozice kurzoru
quickup2:mov       bx,ax                    ; nov† pozice kurzoru
quickup3:ret


public   quickdn
quickdn:                                  ;* kurzor dolñ
         mov       bx,ds:[bp+kurzl-tabl]    ; souáasn† pozice kurzoru
         inc       bx                       ; n†sleduj°c° poloëka
         call      srcfilx                  ; nalezen° dal®° shodnÇ poloëky
         jc        quickend                 ; nenalezen - na posledn° poloëku
         mov       bx,ds:[bp+kurzl-tabl]    ; pozice kurzoru
quickhom:ret


public   quickend
quickend:                                 ;* posledn° poloëka
         xor       bx,bx                    ; prvn° poloëka
         dec       bx
quicken1:inc       bx                       ; n†sleduj°c° poloëka
         call      srcfilx                  ; nalezen° dal®° shodnÇ poloëky
         mov       bx,ds:[bp+kurzl-tabl]    ; pozice kurzoru
         jnc       quicken1                 ; nalezen - dal®°
quicken2:ret

; -----------------------------------------------------------------------------
public   prevalt

prevalt:                                  ;* p©evod znaku s Alt na ASCII znak
                                            ; VSTUP: AX=k¢d kl†vesy
                                            ; VùSTUP: AL=k¢d znaku ASCII
                                            ;         CY=nen° znak ASCII

         push      bx
         push      cx
         push      si
         mov       bl,al                    ; mezera
         cmp       al," "                   ; je mezera ?
         je        prevalt9                 ; je mezera - OK
         mov       bl,"?"
         cmp       ah,35h
         je        prevalt9                 ; je otazn°k
         cmp       ah,9dh                   ; kurzor vpravo
         je        prevalt9                 ; je kurzor vpravo
                                          ;* nalezen° p°smena v tabulce
         mov       bl,"A"                   ; prvn° znak v tabulce
         mov       cx,26                    ; poáet znakñ v tabulce
         lea       si,[tabchar]             ; tabulka znakñ Alt
prevalt1:cmp       ah,cs:[si]               ; nalezen znak ?
         je        prevalt9                 ; znak nalezen
         inc       si                       ; zvò®en° ukazatele v tabulce
         inc       bl                       ; zvò®en° znaku
         loop      prevalt1                 ; test dal®°ho znaku
                                          ;* interpretace jako á°slice
         mov       bl,"0"                   ; n†hradn° znak pro "0"
         cmp       ah,81h                   ; je znak vàt®° neë "0" ?
         je        prevalt9                 ; je kl†vesa "0"
         cmc
         jc        prevalt9                 ; je kl†vesa vàt®° neë "0"
         mov       bl,ah                    ; k¢d kl†vesy
         sub       bl,78h                   ; je men®° neë "1" ?
         jb        prevalt9                 ; nen° platnò znak
         add       bl,"1"                   ; korekce na znak á°slice
prevalt9:jc        prevalt8
         mov       al,bl
prevalt8:pop       si
         pop       cx
         pop       bx
         ret

; -----------------------------------------------------------------------------
public   srcfile

srcfile:                                  ;* nastaven° poloëky pro rychlÇ hled.

         push      ax
         push      bx
         push      si
         push      ds
         push      cs
         pop       ds
         lea       si,[bufsrc-1]            ; jmÇno souboru
         call      hledpol                  ; nalezen° poloëky v seznamu
         jnc       srcfile1                 ; soubor nalezen OK
         test      byte ptr ds:[bp+0],11110000b ; nestandardn° t©°dàn° ?
         jnz       srcfile2                 ; nestandardn° t©°dàn°
srcfile1:mov       ds:[bp+kurzl-tabl],bx    ; nastaven° pozice kurzoru
srcfile2:pop       ds
         pop       si
         pop       bx
         pop       ax
         ret


public   srcfilx

srcfilx:                                  ;* hled†n° prvn° shodnÇ poloëky
                                            ; VSTUP: BX=prvn° poloëka
                                            ; VùSTUP: CY=poloëka nenalezena

         push      ax
         push      bx
         push      si
         push      di
         push      ds
         push      es
         push      cs
         pop       ds
         call      kurzoff                  ; vypnut° kurzoru
         lea       si,[bufsrc-1]            ; jmÇno souboru
srcfilx1:call      adrpoldi                 ; poskytnut° adresy prvn° poloëky
         jc        srcfilx3                 ; konec seznamu - poloëka nenalezena
         cmp       byte ptr ds:[numsrc],0   ; je nàjakò znak v bufferu ?
         jne       srcfilx4                 ; v bufferu nen° ë†dnò znak
         test      byte ptr es:[di],80h     ; je vybranò soubor ?
         jnz       srcfilx2                 ; je vybranò soubor - OK
         jmp       short srcfilx5           ; dal®° soubor
srcfilx4:call      cmpfile                  ; porovn†n° souborñ SI,DI
         je        srcfilx2                 ; nalezen stejnò soubor
srcfilx5:inc       bx                       ; zvò®en° ukazatele poloëky
         jmp       short srcfilx1           ; test dal®° poloëky
srcfilx2:mov       ds:[bp+kurzl-tabl],bx    ; nastaven° pozice kurzoru
srcfilx3:pop       es
         pop       ds
         pop       di
         pop       si
         pop       bx
         pop       ax
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
         call      stinw                    ; zobrazen° st°nu okna
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

         test      byte ptr ds:[conf5],2    ; je zapnutÇ rychlÇ zobrazen° ?
         jnz       xchgakt1                 ; je rychlÇ zobrazen°

         call      kurzon                   ; vypnut° kurzoru
         call      obrpath
         call      getakt                   ; novÇ aktivn° okno
         call      kurzon
         call      obrpath
         call      obrcomm
         xor       ax,ax
         call      usesedit                 ; normalizace kurzoru
         ret

xchgwind:                                 ;* z†màna oken ^U
         mov       al,ds:[pozr]             ; pozice pravÇho okna
         xchg      al,ds:[pozl]             ; z†màna s pozic° levÇho okna
         mov       ds:[pozr],al             ; nov† pozice pravÇho okna
xchgakt1:call      windretx                 ; obnoveni zobrazeni oken
         xor       ax,ax
         call      usesedit                 ; normalizace kurzoru
xchgakt2:ret

; -----------------------------------------------------------------------------
public   sortfile

sortfile:                                 ;* nastaven° zpñsobu t©°dàn° adres†©e

         call      testaktw                 ; je okno aktivn° ?
         jc        sortfil7                 ; okno nen° aktivn°
                                          ;* nastaveni predvolby
         lea       di,[txtwin1]             ; nadpis
         lea       si,[txtwin5]             ; volby
         xor       al,al                    ; p©edvolba "JmÇno" - 0
         test      byte ptr ds:[bp+0],0f0h  ; t©°dàn° podle jmÇna ?
         jz        sortfil2                 ; t©°dàn° podle jmÇna
         inc       al                       ; p©edvolba "P©°pona" - 1
         test      byte ptr ds:[bp+0],20h   ; t©°dàn° podle p©°pony ?
         jnz       sortfil2                 ; t©°dàn° podle p©°pony
         inc       al                       ; p©edvolba "Datum" - 2
         test      byte ptr ds:[bp+0],40h   ; t©°dàn° podle data a áasu ?
         jnz       sortfil2                 ; t©°dàn° podle data a áasu
         inc       al                       ; p©edvolba "Velikost" - 3
         test      byte ptr ds:[bp+0],80h   ; t©°dàn° podle velikosti ?
         jnz       sortfil2                 ; t©°dàn° podle velikosti
         inc       al                       ; p©edvolba "Net©°dit" - 4
sortfil2:call      volbyh                   ; volba t©°dàn°
         call      windretx                 ; navrat oken
         jc        sortfil7                 ; p©eru®en° operace
                                          ;* nove nastaveni prepinacu
         and       byte ptr ds:[bp+0],0fh   ; zru®en° p©°znakñ t©°dàn° adres†©e
         dec       al                       ; je t©°dàn° podle p©°pony ?
         jnz       sortfil3                 ; nen° t©°dàn° podle p©°pony
         or        byte ptr ds:[bp+0],20h   ; p©°znak t©°dàn° podle p©°pony
sortfil3:dec       al                       ; je t©°dàn° podle data a áasu ?
         jnz       sortfil4                 ; nen° t©°dàn° podle data a áasu
         or        byte ptr ds:[bp+0],40h   ; p©°znak t©°dàn° podle data a áasu
sortfil4:dec       al                       ; je t©°dàn° podle velikosti ?
         jnz       sortfil5                 ; nen° t©°dàn° podle data a áasu
         or        byte ptr ds:[bp+0],80h   ; p©°znak t©°dàn° podle velikosti
sortfil5:dec       al                       ; je net©°dàn° adres†© ?
         jnz       sortfil6                 ; nen° net©°dànò adres†©
         or        byte ptr ds:[bp+0],10h   ; p©°znak net©°dànÇho adres†©e
sortfil6:call      storekall                ; uloëen° kurzorñ
         call      rerdir                   ; p©°znak novÇho naáten° adres†©e
;         and       byte ptr ds:[bp+0],not 2 ; zru®en° p©°znaku naáten° adres†©e
;         or        byte ptr ds:[bp+0],4     ; p©°znak, ëe se adres†© nenuluje
         call      windretx
sortfil7:ret

; -----------------------------------------------------------------------------
public   compfile

compfile:                                  ;* porovn†n° adres†©ñ

         call      testaktw                 ; je okno aktivn° ?
         jc        compfilx                 ; okno nen° aktivn°
         call      testaktwn                ; je neaktivni okno zapnute ?
         jc        compfilx                 ; druhÇ okno nen° aktivn°

         lea       si,[txtcomp4]            ; volby £rovnà porovn†n°
         lea       di,[txtcomp1]            ; nadpis 'Zvolte £rove§ porovn†n°'
         xor       al,al                    ; p©edvolba - prvn° poloëka
         call      volbyh                   ; volba £rovnà porovn†n° adres†©ñ
         jc        compfilw                 ; p©eru®en° operace
                                          ;* nastaven° p©°znakñ typu porovn†n°
         call      msgcek                   ; hl†®en° "áekejte"
         and       byte ptr cs:[conf3],0fh  ; zru®en° p©°znakñ porovn†n°
         or        al,al                    ; je volba 1 = aktu†ln° ?
         jnz       compfls1                 ; nen° volba 1
         or        byte ptr cs:[conf3],30h  ; p©°znaky pro aktu†ln°
compfls1:dec       al                       ; je 2 = novàj®° ?
         jnz       compfls2                 ; nen° volba 2
         or        byte ptr cs:[conf3],10h  ; p©°znaky pro novàj®°
compfls2:dec       al                       ; je 3 = dopl§kovÇ ?
         jnz       compfls3                 ; nen° volba 3
         or        byte ptr cs:[conf3],20h  ; p©°znaky pro dopl§kovÇ
compfls3:dec       al                       ; je 4 = shodnÇ ?
         jnz       compfls4                 ; nen° volba 4
         or        byte ptr cs:[conf3],40h  ; p©°znaky pro shodnÇ
compfls4:dec       al                       ; je 5 = rozd°lnÇ ?
         jnz       compfls5                 ; nen° volba 5
         or        byte ptr cs:[conf3],80h  ; p©°znaky pro rozd°lnÇ
compfls5:
         call      compfil0                 ; porovn†n° aktu†ln°ho okna
         xor       byte ptr cs:[flags],1    ; zmàna aktivity okna
         call      compfil0                 ; porovn†n° neaktu†ln°ho okna
         xor       byte ptr cs:[flags],1    ; n†vrat aktivity okna
compfilw:call      windretx                 ; novÇ zobrazen° oken
compfilx:ret


compfil0:                                 ;* porovn†v†n° aktivn°ho adres†©e
         xor       bx,bx                    ; ukazatel testovanòch souborñ
                                          ;* poskytnut° adresy poloëky
compfil1:call      getakt                   ; aktivn° okno
         call      adrpolsi                 ; poskytnut° adresy DS:SI
         jc        compfil4                 ; nen° jië dal®° soubor
         inc       bx                       ; zvò®en° ukazatele souborñ
         and       byte ptr ds:[si],7fh     ; zru®en° vòbàru souboru
         test      byte ptr ds:[si],10h     ; je adres†© ?
         jnz       compfil1                 ; je adres†© - dal®° soubor
                                          ;* nalezen° protàj®° poloëky
         push      bx
         call      getnakt                  ; neaktivn° okno
         call      hledpol0                 ; nalezen° stejnÇ poloëky
         pushf
         call      adrpoldi                 ; poskytnut° adresy poloëky
         popf
         pop       bx
         jc        compfil2                 ; nenalezen protàj®° soubor
         test      byte ptr es:[di],10h     ; je adres†© ?
         jnz       compfil2                 ; je adres†© - nen° protàj®° soubor

                                          ;* nalezen protàj®° soubor
                                          ;* porovn†n° novàj®°ho souboru
         test      byte ptr cs:[conf3],10h  ; porovn†vaj° se novàj®° soubory ?
         jz        compfil5                 ; neporovn†vaj° se novàj®° soubory
         call      compfild                 ; porovn†n° parametrñ souborñ
         ja        compfil3                 ; je novàj®° nebo vàt®° - oznaáen°
compfil5:                                 ;* porovn†n° stejnÇho souboru
         test      byte ptr cs:[conf3],40h  ; porovn†vaj° se stejnÇ soubory ?
         jz        compfil6                 ; neporovn†vaj° se stejnÇ soubory
         call      compfild                 ; porovn†n° souborñ
         je        compfil3                 ; jsou stejnÇ soubory - oznaáen°
compfil6:                                 ;* porovn†n° rozd°lnÇho souboru
         test      byte ptr cs:[conf3],80h  ; porovn†vaj° se rozd°lnÇ soubory ?
         jz        compfil1                 ; neporovn†vaj° se rozd°lnÇ soubory
         call      compfild                 ; porovn†n° souborñ
         jne       compfil3                 ; jsou rozd°lnÇ soubory - oznaáen°
         jmp       short compfil1           ; soubor se neoznaá°

compfil2:                                 ;* nenalezen protàj®° soubor
         test      byte ptr cs:[conf3],20h  ; porovn†vaj° se dopl§kovÇ soubory ?
         jz        compfil1                 ; neoznaá° se dopl§kovÇ soubory
compfil3:                                 ;* soubor se oznaá°
         or        byte ptr ds:[si],80h     ; oznaáen° souboru
         jmp       short compfil1           ; test dal®°ho souboru
compfil4:
         push      cs
         pop       ds
         push      cs
         pop       es
         ret

compfild:                                 ;* porovn†n° parametrñ souborñ
         push      ax
         mov       ax,ds:[si+16]            ; datum souboru
         cmp       ax,es:[di+16]            ; porov†n° dat souborñ
         jne       compfld3                 ; data nejsou shodn†
         mov       ax,ds:[si+18]            ; áas souboru
         cmp       ax,es:[di+18]            ; porovn†n° áasñ souborñ
         jne       compfld3                 ; áasy nejsou shodnÇ
         mov       ax,ds:[si+14]            ; vy®®° slovo velikosti
         cmp       ax,es:[di+14]            ; porovn†n° velikost° souborñ
         jne       compfld3                 ; nen° shodn† velikost
         mov       ax,ds:[si+12]            ; nië®° slovo velikosti
         cmp       ax,es:[di+12]            ; porovn†n° velikost° souborñ
compfld3:pop       ax
         ret

; -----------------------------------------------------------------------------
public   selminus,selplus


selminus:                                 ;* vòbàr souborñ pomoc° [-]

         call      testshft                 ; test kl†vesy SHIFT
         jz        selmina                  ; kl†vesa SHIFT nen° stisknuta
         jmp       unsel1f                  ; zru®en° vòbàru jednoho souboru

selmina: mov       di,offset txtunsel       ; nadpis "zru®it vòbàr"
         xor       dl,dl                    ; p©°znak zru®en° oznaáen°
         jmp       short selfile

selplus:                                  ;* vòbàr souborñ pomoc° [+]

         call      testshft                 ; test kl†vesy SHIFT
         jz        selplusa                 ; kl†vesa SHIFT nen° stisknuta
         jmp       sel1f                    ; vòbàr jednoho souboru

selplusa:mov       di,offset txtsel         ; nadpis "vybrat soubory"
         mov       dl,80h                   ; p©°znak nastaven° oznaáen°

selfile:                                  ;* vòbàr podle specifikace
         call      testaktw                 ; test zapnut° okna
         jc        selplus8                 ; okno je vypnutÇ
         mov       si,offset bufsel         ; buffer masek pro vòbàr
         mov       word ptr ds:[si],bufsel2-bufsel1
         mov       byte ptr ds:[bufsel2],1
         mov       word ptr ds:[bufsel2+1],offset all

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
         lea       si,[rozbset]             ; rozbor jmÇna souboru
         call      cmpfile                  ; porovn†n° jmÇna souboru
         pop       ds
         pop       si
         ret

; -----------------------------------------------------------------------------
public   insert,sel1f,unsel1f,insert0

sel1f:                                    ;* vòbàr jednoho souboru Shift+
         mov       ax,0ff80h                ; hodnota pro nastaven° poloëek
         jmp       short insert0


unsel1f:                                  ;* zru®en° vòbàru jednoho souboru Shift-
         mov       ax,7f00h                 ; hodnota pro nulov†n° poloëek
         jmp       short insert0

insert:                                   ;* oznaáen° souboru
         mov       ax,0ff00h                ; hodnota pro nulov†n° a maskov†n°

insert0:
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
public   selback

selback:                                  ;* n†vrat posledn°ho vòbàru ^]

         call      testaktw                 ; test zapnut° okna
         jc        selback3                 ; okno je vypnutÇ
         xor       bx,bx                    ; á°slo prvn° poloëky
selback1:call      adrpolsi                 ; poskytnut° adresy prvn° poloëky
         jc        selback2                 ; konec seznamu
         inc       bx                       ; zvò®en° ukazatele poloëek
         test      byte ptr ds:[si],40h     ; byla vybran† poloëka ?
         jz        selback1                 ; nebyla vybran†
         or        byte ptr ds:[si],80h     ; nastaven° vòbàru
         jmp       short selback1           ; dal®° poloëka
selback2:call      windretx                 ; n†vrat zobrazen° oken
selback3:ret

; -----------------------------------------------------------------------------
public   selfcom

selfcom:                                  ;* vòbàr spustitelnòch programñ ^^

         call      testaktw                 ; test zapnut° okna
         jc        selfcom3                 ; okno je vypnutÇ
         xor       bx,bx                    ; á°slo prvn° poloëky
selfcom1:call      adrpolsi                 ; poskytnut° adresy prvn° poloëky
         jc        selfcom2                 ; konec seznamu
         inc       bx                       ; zvò®en° ukazatele poloëky
         call      testexe                  ; test, zda je poloëka EXE,COM,BAT
         jnz       selfcom1                 ; nen° spustitelnò program
         xor       byte ptr ds:[si],80h     ; zmàna vòbàru
         jmp       short selfcom1           ; dal®° poloëka
selfcom2:call      windretx                 ; n†vrat zobrazen° oken
selfcom3:ret

; -----------------------------------------------------------------------------
public   selfall,unselfall,invsel

selfall:                                  ;* vòbàr v®ech souborñ CTRL+
         mov       ax,0ff80h                ; hodnota pro nastaven° poloëek
         jmp       short selsoub


unselfall:                                ;* zru®en° vòbàru v®ech souborñ CTRL-
         mov       ax,7f00h                 ; hodnota pro nulov†n° poloëek
         jmp       short selsoub


invsel:                                   ;* inverze vòbàru souborñ CTRL-INS
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

         call      testshft                 ; test p©esmykaáe SHIFT
         jz        ctrlent1                 ; nen° SHIFT - p©enese se jen jmÇno
         call      entpath                  ; p©enesen° cesty
ctrlent1:                                 ;* pokraáuje p©enesen° jmÇna poloëky


public   entname

entname:                                  ;* vloëen° jmÇna poloëky

         call      testaktw                 ; test zapnut° okna
         jc        entname3                 ; okno je vypnutÇ
         call      getkurz                  ; poskytnut° adresy kurzoru
         jc        entname3                 ; nen° platnÇ jmÇno
         lea       di,[outbuf]              ; vòstupn° buffer
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


public   entpath

entpath:                                  ;* vloëen° jmÇna aktivn° cesty
         mov       si,ds:[bp+4]             ; cesta k aktivn°mu adres†©i
         xor       ah,ah
entpath1:lodsb
         or        al,al                    ; je jië konec ?
         jz        entpath2                 ; konec textu
         call      usesedit                 ; zobrazen° znaku
         jmp       short entpath1
entpath2:cmp       byte ptr ds:[si-2],"\"   ; byla cesta ukonáena s "\"
         je        entpath3                 ; je jië znak "\"
         mov       al,"\"
         call      usesedit                 ; z†pis ukonáovac°ho znaku adres†©e
entpath3:ret

; -----------------------------------------------------------------------------
public   enterx,xchgpath

enterx:                                   ;* funkce ENTER

         call      testshft                 ; test p©esmykaáe SHIFT
         jnz       entpath                  ; je SHIFT - p©enesen° cesty
         mov       cx,ds:[poclin]           ; poáet znakñ v bufferu
         call      testaktw                 ; test zapnut° okna
         jc        entex08                  ; okno je vypnutÇ
         or        cx,cx                    ; je nàjakò znak v bufferu ?
         je        entex0                   ; v bufferu nen° ë†dnò znak

entex08:                                  ;* proveden° p©°kazu z ©†dku
         mov       ds:[numselb],cx          ; poáet znakñ textu
         lea       si,[buftxt]              ; buffer textu p©°kazovÇho ©†dku
         lea       di,[selbuf]              ; buffer pro zad†n° voleb
         rep       movsb                    ; p©enos textu
         lea       si,[bufcomm]             ; buffer poloëek
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
         jmp       exten                    ; obsluha p©°pony souboru
entex07:
         lea       di,[outbuf]              ; pracovn° buffer
         push      di
         call      dekfile                  ; dek¢dov†n° jmÇna souboru
         pop       si                       ; buffer s textem
         jmp       short entex02            ; proveden° p©°kazu


xchgpath:                                 ;* zmàna adres†©e ^\
         call      testshft                 ; je stisknuta kl†vesa SHIFT ?
         jz        entex213                 ; kl†vesa SHIFT nen° stisknuta
                                          ;* ponech†n° prvn°ho podadres†©e
         mov       cx,20                    ; max. poáet znakñ
         mov       di,ds:[bp+4]             ; adresa cesty k adres†©i
         add       di,3                     ; p©eskoáen° z†klad. adres†©e
         cmp       byte ptr ds:[di],0       ; je z†kladn° adres†© ?
         je        entex212                 ; je to z†kladn° adres†©
         mov       al,"\"                   ; hledanò znak
         repnz     scasb                    ; nalezen° oddàlovaáe "\"
         mov       byte ptr ds:[di-1],0     ; konec podadres†©e
         call      getkurz                  ; poskytnut° adresy kurzoru
         jmp       short entex214
entex212:ret                                ; adres†© se nep©epne

entex213:                                 ;* je zmàna adres†©e pod kurzorem
         call      getkurz                  ; poskytnut° adres souboru s kurz.
         test      byte ptr ds:[si],10h     ; je adres†© ?
         jnz       entex2                   ; je to adres†©
         mov       si,cs:[bp+4]             ; adresa cesty k adres†©i
         cmp       byte ptr cs:[si+3],0     ; je z†kladn° adres†© ?
         je        entex212                 ; je jië z†kladn° adres†©
entex214:xor       si,si                    ; adresa prvn° poloëky ("..")

entex2:                                   ;* zmàna adres†©e DS:SI (novò adres†©)
                                          ;* £schova jmÇna adres†©e
         push      si
         push      ds
         cmp       word ptr ds:[si+1],".."  ; je p©epnut° do podadres†©e ?
         push      cs
         pop       ds
         lea       si,ds:[nadadr]           ; oznaáen° nad©azenÇho adres†©e ".."
         jne       entex23                  ; nen° p©epnut° do ko©ene
         mov       si,ds:[bp+4]             ; cesta k adres†©i
entex23: call      rozbor                   ; rozbor jmÇna souboru
         lea       si,[rozbset]             ; jmÇno adres†©e
         call      storefile                ; £schova jmÇna cesty
         pop       ds
         pop       si
                                          ;* p©epnut° adres†©e
         lea       di,[outbuf]              ; tiskovò buffer
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
         xor       ax,ax
         call      usesedit                 ; normalizace kurzoru
         ret

; -----------------------------------------------------------------------------
public   obnov

obnov:                                    ;* obnoven° souboru Shift-F8
         lea       di,[outbuf]
         push      di
         call      menexc3                  ; p©enesen° domovskÇ cesty
         lea       si,[fileobn]             ; program pro obnoven° souborñ
         call      transtxt
         pop       si
         xor       dx,dx
                                            ; n†sleduje program "execute"

; -----------------------------------------------------------------------------
public   execute
execute:                                  ;* proveden° p©°kazu DS:SI
                                            ; DX=0 p©°znak, ëe se text nezobraz°

         call      msgcek                   ; hl†®en° "áekejte"
                                          ;* p©enesen° p©°kaz. ©†dku na 80h
         mov       es,cs:[segrez]           ; segment rezidentn°ch dat
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

povely:                                   ;* historie povelñ Shift-F2

         mov       word ptr ds:[bufcomm],bufcomm2-bufcomm1 ; dÇlka bufferu
         mov       byte ptr ds:[bufcomm2],0 ; poáet p©edvoleb
         mov       ax,ds:[poclin]           ; poáet znakñ v bufferu
         or        ax,ax                    ; je nàjakò znak v bufferu ?
         jnz       povely1                  ; v bufferu je nàjakò znak
         cmp       byte ptr ds:[bufcomm1],0 ; je nàco v bufferu ?
         je        povely4                  ; buffer je pr†zdnò
povely1: inc       byte ptr ds:[bufcomm2]   ; je 1 p©edvolba
         lea       si,[buftxt]              ; buffet textu p©°kaz. ©†dku
         mov       ds:[bufcomm3],si         ; adresa bufferu s textem
         add       si,ax                    ; konec textu
         mov       byte ptr ds:[si],0       ; konec textu
povely2: lea       si,[bufcomm]             ; buffer povelñ
         lea       di,[txtpovel]            ; text "Historie povelñ: "
         call      select                   ; volby
         call      windretx
         jc        povely4                  ; p©eru®en° voleb
         jmp       entex02                  ; proveden° povelu
povely4: ret

; -----------------------------------------------------------------------------
public   vytvadr

vytvadr:                                  ;* vytvo©en° adres†©e F7

         mov       word ptr ds:[bufadr],bufadr2-bufadr1 ; dÇlka bufferu

         lea       si,[bufadr]              ; buffer poloëek adres†©ñ
         lea       di,[txtvyt1]             ; text nadpisu "Vytvo©°m adres†©: "
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
         lea       si,[outbuf]              ; pracovn° buffer
         call      aktdir                   ; nastaven° zadanÇho adres†©e
         jc        vytvad4                  ; diskov† chyba
         lea       di,[selbuf]              ; buffer k naáten° adres†©e
         call      loadpath                 ; naáten° adres†©e
         jc        vytvad4                  ; diskov† chyba
                                          ;* dek¢dov†n° jmÇna adres†©e
         lea       di,[outbuf]              ; buffer pro uloëen° jmÇna
         lea       si,[rozbflg]             ; zadanÇ jmÇno adres†©e
         mov       byte ptr ds:[si],10h     ; p©°znak adres†©e
         call      dekfile                  ; dek¢dov†n° jmÇna adres†©e
                                          ;* hl†®en° o vytv†©en° adres†©e
         call      mouseoff                 ; vypnut° my®i
         call      informc                  ; vymaz†n° informaán°ho okna
         lea       si,[txtvyt2]             ; text "Vytv†©°m adres†©"
         call      outtxt
         lea       si,[selbuf]              ; cesta k adres†©i
         call      outtxt
         cmp       byte ptr ds:[si-2],"\"   ; byla cesta ukonáena s "\" ?
         je        vytvad2                  ; byl znak "\"
         mov       al,"\"
         call      outch1                   ; zobrazen° znaku "\"
vytvad2: lea       si,[outbuf]              ; jmÇno adres†©e
         call      outtxt                   ; zobrazen° jmÇna novÇho adres†©e
         call      kurzout                  ; vypnut° kurzoru
         call      mouseon                  ; zapnut° my®i
                                          ;* vytvo©en° adres†©e
ifndef   demo
         lea       dx,[outbuf]              ; jmÇno novÇho adres†©e
         mov       ah,39h                   ; funkce vytvo©en° adres†©e
         int       21h                      ; vytvo©en° adres†©e
else
         call      prodldem                 ; prodleva
         clc
endif
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
         lea       si,[erradres]            ; chyba "ChybnÇ zad†n° adres†©e !"
         call      zobrchyb                 ; zobrazen° chybovÇho hl†®en°
         jmp       short vytvad5


vytvad8:                                  ;* aktualizace adres†©e

         call      cmpcpath                 ; je to c°lovò adres†© ?
         jne       vytvad82                 ; nen° to c°lovò adres†©
         lea       si,[rozbflg]             ; zadanÇ jmÇno adres†©e
;         call      testakt                  ; je to aktivn° okno ?
;         jnz       vytvad81                 ; nen° to aktivn° okno
         call      storefile                ; uloëen° adres†©e pro p©edvolbu
;vytvad81:
         call      rerdir                   ; novÇ naáten° adres†©e
;         or        byte ptr ds:[bp+0],4     ; poëadavek nenulov†n° adres†©e
;         call      obnovs                   ; obnoven° souboru v adres†©i
;         call      settabf                  ; nastaven° na adres†©
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
         lea       di,[buffail]             ; buffer pro hl†®en° chyb
         lea       si,[txtchyb]
         call      transtxt                 ; p©enos textu
         pop       si
         push      si
         call      transtxt
         lea       si,[txtchyb1]
         lea       di,[buffail]
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
public   storsel

storsel:                                  ;* uschov†n° vòbàru souborñ

         push      bx
         push      si
         push      ds
         call      testaktw                 ; test zapnut° okna
         jc        storsel2                 ; okno je vypnutÇ
         xor       bx,bx                    ; á°slo prvn° poloëky
storsel1:call      adrpolsi                 ; poskytnut° adresy prvn° poloëky
         jc        storsel2                 ; je konec seznamu
         inc       bx                       ; zvò®en° ukazatele souboru
         and       byte ptr ds:[si],not 40h ; zru®en° vòbàru
         test      byte ptr ds:[si],80h     ; je vybran† poloëka ?
         jz        storsel1                 ; nen° vybran†
         or        byte ptr ds:[si],40h     ; nastaven° vòbàru
         jmp       short storsel1           ; dal®° poloëka
storsel2:pop       ds
         pop       si
         pop       bx
         ret

; -----------------------------------------------------------------------------
public   getoper

getoper:                                  ;* poskytnut° operace
                                            ; VùSTUP: AL=0:kop°rov†n° souborñ
                                            ;            1:p©ejmenov†n° souborñ
                                            ;            2:ru®en° souborñ
                                            ;            3:atributy souborñ
                                            ; p©°znaky: JB - kop°r. nebo p©ejm.
                                            ;           JE - ru®en°
                                            ;           JA - atributy

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
public   copyfile1,copyfile,movefile1,movefile,delfile1,delfile,atrfile

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

atrfile:                                  ;* atributy souborñ
         mov       byte ptr ds:[flagsc],3   ; operace nastaven° atributñ

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
         je        file32                   ; je ru®en°

                                          ;* volby pro nastaven° atributñ
         call      atrvolby                 ; volby pro nastaven° atributñ
         jc        file33                   ; p©eru®en° operace
         cmp       word ptr cs:[rozbats],0  ; jsou zad†ny atributy ?
         jne       file62                   ; jsou zad†ny atributy - proveden°
         test      byte ptr cs:[rozbdat0],0eh
         jnz       file62
         test      byte ptr cs:[rozbcas0],0eh
         jnz       file62
         ret                                ; n†vrat - p©eru®en°

                                          ;* volby pro ru®en°
file32:  lea       si,[txtkon2]             ; poloëky voleb "Ano", "Ne"
         xor       al,al                    ; p©edvolba
         call      volbyh                   ; zobrazen° varov†n°
         call      windretx                 ; n†vrat oken
         jc        file33                   ; p©eru®en° operace
         or        al,al                    ; je volba ANO ?
         jz        file62                   ; je potvrzen° ANO
file33:  ret                                ; p©eru®en° operace

file31:                                   ;* volby pro kop°rov†n°/p©esun
         call      precopy                  ; nastaven° p©edvoleb pro COPY,...
         lea       si,[bufcopy]             ; buffer poloëek
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
         call      storsel                  ; uschov†n° vòbàrñ souborñ
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
file70: ; call      testbreak                ; test p©eru®en° operace
        ; jc        file71                   ; je p©eru®en° operace
         call      setnext                  ; nastaven° dal®°ho souboru
file72:  jc        file71                   ; nen° jië dal®° soubor
         call      storekur                 ; £schova pozice kurzoru
         call      getoper                  ; poskytnut° á°sla operace
         jb        file73                   ; je kop°rov†n° nebo p©esun
         ja        file78                   ; je nastaven° atributñ
                                          ;* zru®en° jednoho souboru
         call      delete1f                 ; zru®en° jednoho souboru
         jc        file71                   ; p©eru®en° operace
         jmp       short file70             ; zru®en° dal®°ho souboru
file78:                                   ;* nastaven° atributñ jednoho souboru
         call      atrib1f                  ; nastaven° atributu pro 1 soubor
         jc        file71                   ; p©eru®en° operace
         jmp       short file7              ; nastaven° dal®°ho souboru


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
;         call      settabf                  ; n†vrat kurzoru
         call      getakt
         call      rerdir                   ; nastaven° novÇho naáten° adres†©e
;         call      settabf                  ; n†vrat kurzoru
         call      windretx                 ; n†vrat zobrazen° oken
         ret

; -----------------------------------------------------------------------------
public   rerdir

rerdir:                                   ;* nastaven° novÇho naáten° adres†©e
         and       byte ptr cs:[bp+0],not 2 ; zru®en° p©°znaku naáten° adres†©e
         or        byte ptr cs:[bp+0],4     ; p©°znak, ëe se adres†© nenuluje
         ret

; -----------------------------------------------------------------------------
atrvolb3:mov       word ptr ds:[rozbats],dx ; poëadovanÇ nastaven° atributñ
atrvolb4:call      windretx                 ; novÇ zobrazen° oken
         ret

public   atrvolby
atrvolby:                                 ;* volby pro nastaven° atributñ
         mov       byte ptr ds:[rozbdat0],0 ; p©°znak - nezad†no datum
         mov       byte ptr ds:[rozbcas0],0 ; p©°znak - nezad†n áas
                                          ;* nastaven° p©edvolby
         lea       di,[preatrib]            ; p©edvolba atributñ
         mov       ds:[bufatr3],di          ; nastaven° adresy p©edvolby
         mov       byte ptr ds:[bufatr2],1  ; poáet p©edvoleb = 1
         mov       bh,2                     ; maska atributñ pro levÇ okno
         cmp       bp,offset tabl           ; je levÇ okno ?
         je        atrvolb0                 ; je levÇ okno
         mov       bh,4                     ; maska atributñ pro pravÇ okno
atrvolb0:test      byte ptr ds:[conf2],bh   ; jsou zapnuty atributy ?
         mov       al,"+"                   ; p©°znak pro zapnut° atributñ
         jz        atrvolb5                 ; atributy nejsou zapnuty
         mov       al,"-"                   ; p©°znak pro vypnut° atributñ
atrvolb5:mov       ds:[di],al               ; nastaven° p©edvolby atributñ
                                          ;* zad†n° atributñ
         lea       si,[bufatr]              ; buffer volby atributñ
         mov       ax,offset(bufatr2-bufatr1) ; dÇlka bufferu pro volbu atrib.
         mov       ds:[si],ax               ; nastaven° dÇlky bufferu
         lea       di,[txtatr1]             ; nadpis voleb
         call      select                   ; nastaven° voleb
         jc        atrvolb4                 ; p©eru®en° operace
         xor       dx,dx                    ; st©adaá atributñ
                                          ;* dek¢dov†n° p©°kazu
atrvolb1:lodsb                              ; naáten° zadanÇho znaku
         or        al,al                    ; je jië konec textu ?
         jz        atrvolb3                 ; je konec textu
         cmp       al,"+"                   ; je zapnut° zobrazen° ?
         jne       atrvol1                  ; nen° zapnut° zobrazen°
         or        byte ptr ds:[conf2],bh   ; zapnut° zobrazen° atributñ
atrvol1: cmp       al,"-"                   ; je vypnut° zobrazen° ?
         jne       atrvol2                  ; nen° vypnut° zobrazen°
         or        byte ptr ds:[conf2],bh
         xor       byte ptr ds:[conf2],bh   ; vypnut° zobrazen° atributñ
atrvol2: cmp       al,"A"                   ; je nastaven° atributu "ARC" ?
         jne       atrvol3                  ; nen° nastaven° "ARC"
         or        dl,20h                   ; nastaven° "ARC"
         and       dh,not 20h               ; zru®en° nulov†n° "ARC"
atrvol3: cmp       al,"S"                   ; je nastaven° atributu "SYS" ?
         jne       atrvol4                  ; nen° nastaven° "SYS"
         or        dl,4                     ; nastaven° "SYS"
         and       dh,not 4                 ; zru®en° nulov†n° "SYS"
atrvol4: cmp       al,"H"                   ; je nastaven° atributu "HID" ?
         jne       atrvol5                  ; nen° nastaven° "HID"
         or        dl,2                     ; nastaven° "HID"
         and       dh,not 2                 ; zru®en° nulov†n° "HID"
atrvol5: cmp       al,"R"                   ; je nastaven° atributu "R/O" ?
         jne       atrvol6                  ; nen° nastaven° "R/O"
         or        dl,1                     ; nastaven° "R/O"
         and       dh,not 1                 ; zru®en° nulov†n° "R/O"
atrvol6: cmp       al,"a"                   ; je nulov†n° atributu "ARC" ?
         jne       atrvol7                  ; nen° nulov†n° "ARC"
         or        dh,20h                   ; nulov†n° "ARC"
         and       dl,not 20h               ; zru®en° nastaven° "ARC"
atrvol7: cmp       al,"s"                   ; je nulov†n° atributu "SYS" ?
         jne       atrvol8                  ; nen° nulov†n° "SYS"
         or        dh,4                     ; nulov†n° "SYS"
         and       dl,not 4                 ; zru®en° nastaven° "SYS"
atrvol8: cmp       al,"h"                   ; je nulov†n° atributu "HID" ?
         jne       atrvol9                  ; nen° nulov†n° "HID"
         or        dh,2                     ; nulov†n° "HID"
         and       dl,not 2                 ; zru®en° nastaven° "HID"
atrvol9: cmp       al,"r"                   ; je nulov†n° atributu "R/O" ?
         jne       atrvola                  ; nen° nulov†n° "R/O"
         or        dh,1                     ; nulov†n° "R/O"
         and       dl,not 1                 ; zru®en° nastaven° "R/O"
                                          ;* zad†n° data
atrvola: mov       di,offset rozbdat0       ; parametr rozboru data

ifdef    upver
         cmp       al,"D"                   ; zad†no datum ?
         je        atrvolc
         cmp       al,"d"
         jne       atrvold
atrvolc: push      dx
         mov       ah,2ah
         int       21h                      ; poskytnut° systÇmovÇho data
         mov       ds:[di+1],dl             ; den
         mov       ds:[di+2],dh             ; màs°c
         sub       cx,1900
         mov       ds:[di+3],cl             ; rok
         call      rozbordt                 ; rozbor data
         pop       dx
         jmp       atrvolb1
                                          ;* zad†n° áasu
atrvold: mov       di,offset rozbcas0       ; parametr rozboru áasu
         cmp       al,"T"                   ; zad†no datum ?
         je        atrvole
         cmp       al,"t"
         jne       atrvolf
atrvole: push      dx
         mov       ah,2ch
         int       21h                      ; poskytnut° systÇmovÇho áasu
         mov       ds:[di+1],ch             ; hodina
         mov       ds:[di+2],cl             ; minuta
         mov       ds:[di+3],dh             ; sekunda
         call      rozbordt                 ; rozbor áasu
         pop       dx
endif
atrvolf: jmp       atrvolb1

ifdef    upver
rozbordt:                                 ;* rozbor data / áasu
         mov       byte ptr ds:[di],1       ; p©°znak zad†n° data/áasu
         call      outspc                   ; p©eskoáen° mezer
                                          ;* prvn° á°slo (den,hodina)
         call      rozbnum                  ; rozbor prvn°ho á°sla
         jc        rozbord2                 ; á°slo nen° zad†no
         or        byte ptr ds:[di],2       ; p©°znak zad†n° prvn°ho á°sla
         mov       byte ptr ds:[di+1],al    ; uloëen° prvn°ho á°sla
rozbord2:call      rozbodd                  ; test oddàlovaáe
         jc        rozbord6                 ; je konec zad†n°
                                          ;* druhÇ á°slo (màs°c,minuta)
         call      rozbnum                  ; rozbor druhÇho á°sla
         jc        rozbord3                 ; á°slo nen° zad†no
         or        byte ptr ds:[di],4       ; p©°znak zad†n° druhÇho á°sla
         mov       byte ptr ds:[di+2],al    ; uloëen° druhÇho á°sla
rozbord3:call      rozbodd                  ; test oddàlovaáe
         jc        rozbord6                 ; je konec zad†n°
                                          ;* t©et° á°slo (rok,sekunda)
         call      rozbnum                  ; rozbor t©et°ho á°sla
         jc        rozbord5                 ; á°slo nen° zad†no
         or        byte ptr ds:[di],8       ; p©°znak zad†n° t©et°ho á°sla
         cmp       ax,1980                  ; je á°slo vàt®° neë 1980 ?
         jb        rozbord4                 ; nen° vàt®° neë 1980
         sub       ax,1900                  ; odeáten° stolet° 1900
rozbord4:mov       byte ptr ds:[di+3],al    ; uloëen° t©et°ho á°sla
rozbord5:call      rozbodd                  ; test oddàlovaáe
rozbord6:test      byte ptr ds:[di],0eh     ; je zad†no nàkterÇ á°slo ?
         jnz       rozbord7                 ; je zad†no nàkterÇ á°slo
         or        byte ptr ds:[di],0fh     ; p©°znak, ëe je zad†no v®e
rozbord7:ret


rozbodd:                                  ;* test oddàlovaáe
                                            ; VùSTUP: CY=je konec zad†n°

         push      ax
         lodsb                              ; naáten° testovanÇho znaku
         cmp       al," "                   ; je konec zad†n° ?
         jbe       rozbodd1                 ; je konec zad†n°
         cmp       al,"."
         je        rozbodd2
         cmp       al,","
         je        rozbodd2
         cmp       al,":"
         je        rozbodd2
         cmp       al,"-"
         je        rozbodd2
rozbodd1:dec       si                       ; n†vrat ukazatele
         stc
rozbodd2:pop       ax
         ret

rozbnum:                                  ;* rozbor jednoho á°sla
                                            ; VùSTUP: AX=á°slo
                                            ;         CY=á°slo nen° zad†no

         push      bx
         push      cx
         push      dx
         xor       ax,ax                    ; st©adaá á°sla
         xor       bx,bx                    ; BX <- 0 p©°prava pro á°slici
         call      rozbdt5                  ; test jednÇ á°slice
         jc        rozbdt2                  ; nen° ë†dn† á°slice
rozbdt1: sub       bl,"0"                   ; korekce na á°slo
         inc       si                       ; zvò®en° ukazatele
         mov       cx,10
         mul       cx                       ; vyn†soben° st©†danÇho á°sla 10
         add       ax,bx                    ; p©iáten° novÇ á°slice
         call      rozbdt5                  ; test jednÇ á°slice
         jnc       rozbdt1                  ; je dal®° á°slice
         clc
rozbdt2: pop       dx
         pop       cx
         pop       bx
         ret

rozbdt5:                                  ;* test á°slice
                                            ; VùSTUP: BL=znak
                                            ;         CY=nen° á°slice

         mov       bl,ds:[si]               ; p©ipravenò znak
         cmp       bl,"0"
         jb        rozbdt6                  ; nen° á°slice
         cmp       bl,"9"+1
         cmc
rozbdt6: ret

endif
; -----------------------------------------------------------------------------
public   nadpfile

nadpfile:                                 ;* sestaven° nadpisu pro okno voleb
                                            ; VùSTUP: DI=buffer s textem nadpisu
                                          ;* sestaven° £vodu nadpisu
         push      si
         lea       di,[bufnadp]             ; buffer pro nadpis
         push      di
                                          ;* £vodn° text nadpisu
         call      getoper                  ; test prov†dànÇ operace
         lea       si,[txtatr1]             ; text 'Nastav°m atributy pro'
         ja        nadpfl2                  ; je nastaven° atributñ
         dec       al                       ; je AL=1 ? (=p©esun)
         lea       si,[txtcop1]             ; test 'Zkop°ruji'
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
         lea       si,[txtmov2]             ; text 'P©ejmenuji'
         jnz       nadpfl1                  ; je adres†©
nadpfl11:lea       si,[txtmov1]             ; text 'P©esunu/p©ejmenuji '
nadpfl1: or        al,al
         jz        nadpfl2                  ; je p©esun/p©ejmenov†n°
         lea       si,[txtvar]              ; text "Varov†n°"
         call      transtxt                 ; p©enos textu varov†n°
         lea       si,[txtdel1]             ; text 'Zru®°m'

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
         ja        nadpfl8                  ; je nastaven° atributñ
         lea       si,[txtcop2]             ; text ' na: '
         jb        nadpfl7                  ; je kop°rov†n°, p©esun
         lea       si,[txtdel3]             ; text " !"
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
         lea       si,[textvy2+2]           ; text 'soubor'
         jz        nadpf12                  ; nen° adres†©
         lea       si,[txtadr]              ; text ' adres†©'
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
         lea       si,[txtcop3]             ; text ' oznaáen'
         call      transtxt                 ; p©enos textu ' oznaáen'
         pop       si                       ; adresa á°sla
         push      si                       ; adresa á°sla
         call      testkonc                 ; test koncovky á°sla
         lea       si,[textsp20]            ; koncovka "ò"
         or        al,al
         jz        nadpfm1                  ; je á°slo "1"
         lea       si,[textsp21]            ; koncovka "Ç"
         dec       al                       ; je á°slo 2,3,4 ?
         jz        nadpfm1                  ; je koncovka "Ç"
         lea       si,[textsp22]            ; koncovka "òch"
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
         lea       dx,[selbuf]              ; cesta k c°lovÇmu souboru
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
         lea       di,[outbuf+40]
         lea       si,[txtvar]              ; text varov†n°
         call      transtxt                 ; uloëen° nadpisu
         lea       si,[errdel1]             ; text "Soubor"
         call      transtxt                 ; p©enos oznaáen°
         lea       si,[selbuf]              ; plnÇ oznaáen° souboru
         call      transtxt
         lea       si,[errcop4]             ; text "jië existuje..."
         call      transtxt
         lea       si,[copyvolb]            ; volby
         lea       di,[outbuf+40]           ; buffer s textem
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
testex5: lea       dx,[selbuf]              ; c°lovò soubor
ifndef   demo
         mov       ax,4300h                 ; funkce poskytnut° atributñ
         int       21h                      ; poskytnut° atributñ
         test      cx,7                     ; je atribut SYS, HID nebo R/O ?
         jz        testex52                 ; nen° nastaven ë†dnò atribut
         mov       ax,4301h                 ; funkce nastaven° atributñ
         and       cx,not 7                 ; zru®en° atributñ SYS, HID, R/O
         int       21h                      ; zru®en° atributu SYS, HID, R/O
testex52:
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
         jz        testbrk1                 ; nen° p©ipraven znak
         cmp       al,27                    ; je Esc ?
         clc
         jne       testbrk1                 ; nen° Esc
         test      byte ptr cs:[parrez],4   ; je z†kaz p©eru®en° ?
         jnz       testbrk1                 ; je z†kaz p©eru®en°
         mov       word ptr cs:[parbreak],-1 ; p©°znak p©eru®en°
testbrk2:;mov       word ptr cs:[parbreak],0 ; zru®en° p©°znaku p©eru®en°
         call      flushkey                 ; vypr†zdnàn° kl†vesnice
         stc                                ; p©°znak p©eru®en° CY
testbrk1:pop       ax
         ret

; -----------------------------------------------------------------------------
public   atrib1f

atrib1f:                                  ;* nastaven° atributñ pro jeden soubor
                                            ; VùSTUP: CY=p©eru®en° operace

                                          ;* zobrazen° informaán°ho ©†dku
         call      mouseoff                 ; vypnut° my®i
         call      informc                  ; vymaz†n° okna
         mov       bx,word ptr ds:[rozbats] ; poëadovanÇ nastaven° atributñ
         lea       si,[txtatr7]             ; text "Nastavuji"
         or        bl,bl                    ; je nastaven° atributñ ?
         jnz       atrib1f1                 ; je nastaven° atributñ
         lea       si,[txtatr8]             ; text "Nuluji"
atrib1f1:call      outtxt                   ; zobrazen° textu
         lea       si,[txtatr9]             ; text "atributy"
         call      outtxt
         lea       di,[selbuf]              ; pracovn° buffer
         push      di                       ; buffer k uloëen° jmÇna souboru
         push      ds                       ; £schova DS
         call      getkurz                  ; poskytnut° adresy kurzoru
         mov       cl,ds:[si]               ; £schova atributñ
         call      dekfile                  ; dek¢dov†n° jmÇna souboru
         pop       ds                       ; n†vrat DS
         lea       si,[txtatra]             ; text "souboru"
         test      cl,10h                   ; je adres†© ?
         jz        atrib1f4                 ; je soubor
         lea       si,[txtatrb]             ; text "adres†©e"
atrib1f4:call      outtxt
         pop       si                       ; jmÇno souboru
         push      si                       ; jmÇno poloëky
         call      outtxt                   ; zobrazen° jmÇna souboru
         pop       dx                       ; jmÇno poloëky
         call      mouseon                  ; zapnut° my®i
                                          ;* proveden° operace nastaven° atrib.
         call      msgcek                   ; hl†®en° "áekejte"
         call      atribfk                  ; nastaven° atributñ souboru
         jc        atrib1f3                 ; chyba p©i mànàn° atributñ
;         call      datefk                   ; nastaven° data a áasu souboru
;         jc        atrib1f3                 ; chyba p©i zmànà data/áasu
         mov       bx,cs:[bp+11]            ; pozice kurzoru
ifndef   demo
         call      atribpol                 ; nastaven° atributñ poloëky
endif
         call      cmppath                  ; jsou stejnÇ adres†©e ?
         jne       atrib1f5                 ; nejsou stejnÇ adres†©e
         push      bp
         call      getnakt                  ; adresa neaktivn°ho okna
ifndef   demo
         call      atribpol                 ; nastaven° atributñ poloëky
endif
         pop       bp
atrib1f5:clc
atrib1f2:call      nulsel                   ; nulov†n° atributu vòbàru
atrib1f3:call      topret                   ; n†vrat horn°ho ©†dku
         call      kurzout                  ; vypnut° kurzoru
         ret

; -----------------------------------------------------------------------------
public   atribfk
atribfk:                                  ;* nastaven° atributñ souboru na disku
                                            ; VSTUP: DS:DX=jmÇno souboru
                                            ; VùSTUP: CY=chyba operace

         push      ax
         push      bx
         push      cx
         push      di
         push      dx                       ; jmÇno souboru (dodrëet z†sobn°k !)
                                          ;* resetov†n° atributu R/O
         mov       ax,4300h                 ; funkce poskytnut° atributñ
         int       21h                      ; poskytnut° atributñ souboru
         jc        datefk8                  ; chyba operace
         push      cx                       ; £schova atributñ souboru
         and       cx,not 1                 ; zru®en° atributu R/O
ifndef   demo
         mov       ax,4301h                 ; funkce nastaven° atributñ souboru
         int       21h                      ; nastaven° atributñ souboru bez R/O
         jc        datefk7                  ; chyba operace
endif
                                          ;* zji®tàn° data a áasu souboru
         mov       ax,3d02h                 ; m¢d otev©en° áten°/z†pis
         int       21h                      ; otev©en° souboru
         jc        datefk7                  ; chyba operace
         mov       bx,ax                    ; identifik†tor souboru
         mov       ax,5700h                 ; funkce poskytnut° data souboru
         int       21h                      ; poskytnut° atributñ souboru
         jc        datefk6                  ; chyba operace
         call      datefdt                  ; modifikace data a áasu
ifndef   demo
         mov       ax,5701h
         int       21h                      ; nastaven° data a áasu souboru
else
         call      prodldem                 ; prodleva pro demo
         clc
endif
datefk6:                                  ;* uzav©en° souboru
         pushf
         mov       ah,3eh
         int       21h                      ; uzav©en° souboru
         popf
datefk7:                                  ;* nastaven° atributñ souboru
         pop       cx                       ; n†vrat pñvodn°ch atributñ
         jc        datefk8                  ; byla chyba operace
         mov       ax,word ptr cs:[rozbats] ; poëadovanÇ nastaven° atributñ
         not       ah                       ; nulovanÇ atributy
         or        cl,al                    ; nastaven° atributñ
         and       cl,ah                    ; nulov†n° atributñ
         and       cl,not 10h               ; zru®en° atributu adres†©e
ifndef   demo
         mov       ax,4301h                 ; funkce nastaven° atributñ souboru
         pop       dx                       ; jmÇno souboru
         push      dx                       ; jmÇno souboru
         int       21h                      ; nastaven° atributñ souboru
else
         call      prodldem                 ; prodleva pro demo
endif
                                          ;* n†vrat - zobrazen° chyby operace
datefk8: jnc       datefk9                  ; operace OK
         call      testbreak                ; je p©eru®en° ?
         jc        datefk9                  ; je p©eru®en° operace
         lea       si,[erroper]             ; text "Operaci nelze provÇst"
         call      zobrchyb                 ; zobrazen° chybovÇho hl†®en°
datefk9: pop       dx                       ; jmÇno souboru
         pop       di
         pop       cx
         pop       bx
         pop       ax
         ret

public   datefdt
datefdt:                                  ;* modifikace data DX a áasu CX
         push      cx
         mov       di,offset rozbdat0
                                          ;* modifikace dne
         test      byte ptr cs:[di],2       ; zad†n den ?
         jz        datefd2                  ; nen° zad†n den
         mov       al,cs:[di+1]             ; zadanò den
         and       al,1fh                   ; maska dne
         and       dl,not 1fh
         or        dl,al                    ; novò den
datefd2:                                  ;* modifikace màs°ce
         test      byte ptr cs:[di],4       ; zad†n màs°c ?
         jz        datefd3                  ; nen° zad†n màs°c
         mov       al,cs:[di+2]             ; zadanò màs°c
         and       ax,0fh                   ; maska màs°ce
         mov       cl,5                     ; poáet rotac°
         shl       ax,cl                    ; rotace màs°ce na pozici
         and       dx,not 1e0h              ; zru®en° pñvodn°ho màs°ce
         or        dx,ax                    ; novò màs°c
datefd3:                                  ;* modifikace roku
         test      byte ptr cs:[di],8       ; zad†n rok ?
         jz        datefd5                  ; nen° zad†n rok
         mov       al,cs:[di+3]             ; zadanò rok
         sub       al,80                    ; odeáten° offsetu 1980
         jnc       datefd4                  ; nen° p©elom stolet°
         add       al,100                   ; p©elom stolet°
datefd4: mov       cl,9                     ; poáet rotac°
         shl       ax,cl                    ; rotace roku na pozici
         and       dx,1ffh                  ; zru®en° pñvodn°ho roku
         or        dx,ax                    ; novò rok
datefd5: pop       cx

                                          ;* modifikace áasu CX podle zad†n°
         push      dx
         xchg      dx,cx
         mov       di,offset rozbcas0
                                          ;* modifikace sekundy
         test      byte ptr cs:[di],8       ; zad†na sekunda ?
         jz        dateft2                  ; nen° zad†na sekunda
         mov       al,cs:[di+3]             ; zadan† sekunda
         shr       al,1                     ; vydàlen° sekund 2
         and       al,1fh                   ; maska sekund
         and       dl,not 1fh
         or        dl,al                    ; novÇ sekundy
dateft2:                                  ;* modifikace minut
         test      byte ptr cs:[di],4       ; zad†ny minuty ?
         jz        dateft3                  ; nejsou zad†ny minuty
         mov       al,cs:[di+2]             ; zadanÇ minuty
         and       ax,3fh                   ; maska minut
         mov       cl,5                     ; poáet rotac°
         shl       ax,cl                    ; rotace minut na pozici
         and       dx,not 7e0h              ; zru®en° pñvodn°ch minut
         or        dx,ax                    ; novÇ minuty
dateft3:                                  ;* modifikace hodin
         test      byte ptr cs:[di],2       ; zad†na hodina ?
         jz        dateft5                  ; nen° zad†na hodina
         mov       al,cs:[di+1]             ; zadan† hodina
         mov       cl,11                    ; poáet rotac°
         shl       ax,cl                    ; rotace hodiny na pozici
         and       dx,7ffh                  ; zru®en° pñvodn°ch hodin
         or        dx,ax                    ; nov† hodina
dateft5: xchg      dx,cx
         pop       dx
         ret
; -----------------------------------------------------------------------------
public   atribpol

atribpol:                                 ;* nastaven° atributñ poloëky
                                            ; VSTUP: BX=á°slo poloëky
ifndef   demo
         push      ax
         push      cx
         push      dx
         push      si
         push      ds
         call      adrpolsi                 ; poskytnut° adresy poloëky
         jc        atribpl2                 ; neplatn† poloëka
         mov       ax,word ptr cs:[rozbats] ; poëadovanÇ nastaven° atributñ
         not       ah                       ; nulovanÇ atributy
         or        ds:[si],al               ; nastaven° atributñ
         and       ds:[si],ah               ; nulov†n° atributñ
         mov       cx,ds:[si+18]            ; áas souboru
         mov       dx,ds:[si+16]            ; datum souboru
         call      datefdt                  ; modifikace data a áasu
         mov       ds:[si+18],cx            ; áas souboru
         mov       ds:[si+16],dx            ; datum souboru
         call      testaktw                 ; je okno aktivn° ?
         jc        atribpl2                 ; okno nen° aktivn°
         call      zobrfile                 ; novÇ zobrazen° poloëky
atribpl2:pop       ds
         pop       si
         pop       dx
         pop       cx
         pop       ax
endif
         clc
         ret

; -----------------------------------------------------------------------------
public   move1f

move1f:                                   ;* p©esun/p©ejmenov†n° jednoho souboru
                                            ; VùSTUP: CY=chyba kop°rov†n°

         call      cmpcdisk                 ; p©esouv† se na stejnÇm disku ?
         lea       si,[txtmov5]             ; text "P©esouv†m"
         je        move1f0                  ; p©esun mezi adres†©i
         jmp       move1f5                  ; p©esun souboru mezi disky
                                          ;* p©esun souboru mezi adres†©i
move1f0: call      cmpcpath                 ; je p©esun v adres†©i ?
         lea       di,[txtcop6]             ; text "do"
         jne       move1f1                  ; je p©esun mezi adres†©i
;         call      cmpdisk                  ; jsou stejnÇ disky v oknech ?
;         jne       move1f03                 ; nejsou stejnÇ disky
;         call      getatrib0                ; poskytnut° atributñ souboru
;         test      bl,10h                   ; je to adres†© ?
;         jz        move1f03                 ; nen° to adres†©
;         push      bp
;         call      getnakt
;         and       byte ptr cs:[bp+0],not 2 ; zru®en° p©°znaku naáten° adres†©e
;         or        byte ptr cs:[bp+0],4     ; p©°znak, ëe se adres†© nenuluje
;         pop       bp
move1f03:lea       si,[txtmov6]             ; text "P©ejmenov†v†m"
         lea       di,[txtmov7]             ; text "na"
move1f1: call      informz                  ; zobrazen° z†kladn°ho inform. ©†dku
         call      mouseoff                 ; vypnut° my®i
         mov       si,di                    ; text "do" nebo "na"
         call      outtxt
         call      mouseon                  ; zapnut° my®i
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
         jc        move1f6                  ; chyba operace
else
         call      prodldem
endif
                                          ;* zmàna poloëek v adres†©°ch
         pop       di                       ; pñvodn° adresa konce SELBUF
         push      di
         xor       al,al
         stosb
                                          ;* aktualizace aktivn°ho adres†©e
         mov       bx,cs:[bp+11]
ifndef   demo
         call      delpol                   ; zru®en° pñvodn° poloëky
         call      inspol                   ; vloëen° poloëky do adres†©e
else
         call      nulsel                   ; zru®en° oznaáen° poloëky
endif
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
ifndef   demo
         call      delpol                   ; zru®en° poloëky z adres†©e
endif
move1ff:
ifndef   demo
         call      inspol                   ; vloëen° poloëky do adres†©e
endif
move1fe: call      modikap                  ; modifikace kapacity o soubor
move1f4: pop       bp
         clc
         jmp       short move1f7

move1f6: ;lea       si,[erroper]
         call      topret                   ; n†vrat horn°ho ©†dku
         ;call      zobrchyb                 ; hl†®en° chyby

move1f2: pushf
         call      setkurzn                 ; zvò®en° pozice kurzoru
         jnc       move1f77                 ; je dal®° soubor
         popf
         stc                                ; p©°znak konce seznamu
         pushf
move1f77:
;         inc       word ptr ds:[bp+kurzl-tabl] ; zvò®en° pozice kurzoru
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
;         inc       word ptr ds:[bp+kurzl-tabl] ; zvò®en° pozice kurzoru
         clc
         ret
move1fa: ;mov       bx,ds:[bp+11]
         call      deletef0
move1f8: ret

; -----------------------------------------------------------------------------
public   copy1f

copy1f:                                   ;* kop°rov†n° jednoho souboru
                                            ; VùSTUP: CY=chyba kop°rov†n°
                                            ;         NZ=operace neprobàhla

         lea       si,[txtcop5]             ; text " Kop°ruji"
copy1f0: call      informz                  ; zobrazen° z†kladn°ho inform. ©†dku
         call      mouseoff                 ; vypnut° my®i
         lea       si,[txtcop6]             ; text "do"
         call      outtxt
         call      mouseon                  ; zapnut° my®i
         call      cmpcpath                 ; je kop°rov†n° v adres†©i ?
         call      setpcil                  ; sestaven° c°lovÇ cesty souboru
         push      di                       ; pñvodn° konec cesty
         call      dispcil                  ; zobrazen° c°le operace
         pushf
         mov       al,77
         sub       al,dl                    ; poáet znakñ do zbytku ©†dku
         jnc       copy1f1
         xor       al,al                    ; nen° ë†dnò volnò znak
copy1f1: call      initukaz                 ; nastaven° ukazatele kop°rov†n°
         popf
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
public   initukaz

initukaz:                                 ;* inicializace ukazatele kop°rov†n°
                                            ; VSTUP: AL=maxim†ln° dÇlka ukazat.
         call      mouseoff                 ; vypnut° my®i
         push      ax
         push      bx
         push      cx
         push      dx
         push      ds
         push      cs
         pop       ds
         mov       bl,al                    ; £schova maxim†ln° dÇlky ukazatele
         xor       ax,ax
         mov       word ptr ds:[blokuk],ax
         mov       word ptr ds:[blokuk+2],ax ; vynulov†n° velikosti ukazatele
         mov       word ptr ds:[transuk],ax
         mov       word ptr ds:[transuk+2],ax ; vynulov†n° ukazatele p©enes. dat
                                          ;* vòpoáet dÇlky ukazatele

         call      getkurz
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
                                          ;* test, zda je operace v adres†©i
         inc       di
         mov       cl,ds:[di-1]             ; £schova znaku oddàlovaáe
         mov       byte ptr ds:[di-1],0
         call      cmpcpath                 ; je operace v adres†©i ?
         mov       ds:[di-1],cl             ; n†vrat znaku
         mov       si,di                    ; zaá†tek jmÇna souboru
         je        dispcil3                 ; je operace v adres†©i

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
dispcil3:call      outtxt                   ; zobrazen° zbytku textu
         call      mouseon                  ; zapnut° my®i
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

         lea       di,[selbuf]              ; c°lovò adres†©
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

; -----------------------------------------------------------------------------
public   delete1f

delete1f:                                 ;* zru®en° souboru s kurzorem
                                            ; VùSTUP: CY=p©eru®en° operace

         lea       si,[txtdel2]             ; text "Ru®°m "
         call      informz                  ; zobrazen° z†kladn°ho inform. ©†dku
deletef0:                                 ;* zru®en° souboru BX
         call      msgcek                   ; hl†®en° "áekejte"
                                          ;* rozk¢dov†n° jmÇna souboru
         push      ds
         call      getkurz                  ; poskytnut° adresy poloëky
         lea       di,[outbuf]              ; buffer k uloëen° jmÇna souboru
         push      di
         call      dekfile                  ; dek¢dov†n° jmÇna poloëky
         pop       dx                       ; adresa textu - jmÇno souboru
         pop       ds
                                          ;* zru®en° poloëky DS:DX
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


         mov       ah,4eh
         mov       cx,17h                   ; atribut - v®echny soubory
         int       21h                      ; nalezen° poëadovanÇho souboru
         lea       si,[erroper]
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
         and       cx,not 11h               ; zru®en° atributu DIR a R/O
         int       21h                      ; zru®en° atributu R/O
         jc        delfk3                   ; chyba operace
endif
         call      testbreak                ; je p©eru®en° operace ?
         jc        delfk5                   ; je p©eru®en° operace
delfk1:  test      byte ptr ds:[95h],10h    ; atributy souboru - je adres†© ?
         jnz       delfk2                   ; je adres†©
                                          ;* zru®en° souboru
ifndef   demo
         mov       ah,41h                   ; funkce zru®en° souboru
         int       21h                      ; zru®en° souboru
else
         call      prodldem                 ; prodleva
endif
         jnc       delfk5                   ; soubor zru®en OK
         jmp       short delfk3             ; chyba operace
delfk2:                                   ;* zru®en° adres†©e
ifndef   demo
         mov       ah,3ah                   ; funkce zru®en° adres†©e
         int       21h                      ; zru®en° adres†©e
endif
         jnc       delfk5                   ; adres†© zru®en OK
         lea       si,[errdir3]             ; chyba - adres†© mus° bòt pr†zdnò
delfk3:                                   ;* chyba - operaci nelze provÇst
         call      testbreak                ; test p©eru®en° operace
         jc        delfk5                   ; je p©eru®en° operace
         push      cs
         pop       ds
         call      zobrchyb                 ; hl†®en° chyby
delfk5:  ret


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

;                                          ;* zru®en° atributu R/O
;
;         test      byte ptr ds:[si],1       ; m† soubor nastaven atribut R/O ?
;         push      cs
;         pop       ds
;         push      dx
;         jz        delfk4                   ; nen° atribut R/O
;
;IFNDEF   demo
;         mov       ax,4300h                 ; funkce poskytnut° atributñ
;         int       21h                      ; poskytnut° atributñ
;         mov       ax,4301h                 ; funkce nastaven° atributñ
;         and       cx,not 1                 ; zru®en° atributu R/O
;         int       21h                      ; zru®en° atributu R/O
;ENDIF
;
;delfk4:  pop       dx
;         jc        delfk2                   ; chyba operace
;
;         mov       bx,cs:[bp+kurzl-tabl]    ; ru®enò soubor
;         call      adrpolsi                 ; adresa poloëky
;         test      byte ptr ds:[si],10h     ; je adres†© ?
;         push      cs
;         pop       ds
;
;IFNDEF   demo
;         jz        delfk1                   ; nen° adres†©
;                                          ;* aktualizace v protàj®°m oknà
;         call      cmpdisk                  ; porovn†n° diskñ
;         clc
;         jne       delfk21                  ; disky nejsou shodnÇ
;         call      delaktdir                ; zru®en° protàj®°ho adres†©e
;         jmp       short delfk21            ; ukonáen° operace OK
;                                          ;* chyba - adres†© nen° pr†zdnò
;delfk51: call      erradr1                  ; chybovÇ hl†®en°-adr. nen° pr†zdnò
;         jc        delfk2                   ; p©eru®en° operace
;delfk5:  inc       word ptr cs:[bp+kurzl-tabl] ; p©eskoáen° adres†©e
;         jmp       short delfk2             ; p©eskoáen° poloëky
;                                          ;* zru®en° adres†©e
;
;ELSE
;         call      prodldem                 ; prodleva pro DEMO
;         call      prodldem                 ; prodleva pro DEMO
;         call      prodldem
;ENDIF
;delfk21: xor       al,al
;delfk2:  pop       es
;         pop       ds
;         pop       di
;         pop       si
;         pop       dx
;         pop       bx
;         pop       ax
;         ret
;
;
;public   testro
;
;testro:                                   ;* test, zda je poloëka R/O
;                                            ; VùSTUP: CY=p©eru®en° operace
;                                            ;         ZY=poloëka se ru®°
;
;         push      ax
;         push      si
;         push      ds
;         push      es
;         push      cs
;         pop       es
;                                          ;* test, zda je poloëka R/O
;         mov       bx,cs:[bp+kurzl-tabl]    ; poloëka s kurzorem
;         call      adrpolsi                 ; poskytnut° adresy poloëky
;         mov       bh,ds:[si]               ; £schova atributu
;         test      bh,1                     ; m† poloëku ochranu proti z†pisu ?
;         jz        testro4                  ; poloëka nem† ochranu proti z†pisu
;                                          ;* test, zda je automatickò reëim
;         test      byte ptr cs:[flagsc],40h ; prov†d° se dotaz ?
;         jnz       testro3                  ; dotaz se neprov†d°
;                                          ;* sestaven° textu dotazu
;         push      cs
;         pop       ds                       ; DS <- CS
;         lea       di,[outbuf]
;         lea       si,[txtvar]              ; text varov†n°
;         call      transtxt                 ; uloëen° nadpisu
;         lea       si,[errdel1]             ; text "Soubor"
;         test      bh,10h                   ; je to adres†© ?
;         jz        testro2                  ; nen° to adres†©
;         lea       si,[errdir1]             ; test "Adres†©"
;testro2: call      transtxt                 ; p©enos oznaáen°
;         mov       bx,cs:[bp+kurzl-tabl]    ; poloëka s kurzorem
;         call      adrpolsi                 ; poskytnut° adresy poloëky
;         call      dekfile                  ; dek¢dov†n° jmÇna souboru
;         push      cs
;         pop       ds
;         lea       si,[errdir2]             ; text "nelze zru®it, "
;         call      transtxt
;         lea       si,[errdel2]             ; text "protoëe je chr†nàn..."
;         call      transtxt
;                                          ;* provede se dotaz na dal®° postup
;         lea       si,[delvolb]             ; volby
;         lea       di,[outbuf]              ; buffer s textem
;         xor       al,al
;         call      volbyh                   ; proveden° voleb
;         call      windret                  ; navr†cen° oken
;         jc        testro4                  ; p©eru®en° operace
;         mov       cl,6                     ; poáet rotac°
;         shl       al,cl                    ; á°slo dal®° funkce
;         and       byte ptr cs:[flagsc],3fh ; zru®en° staròch p©°znakñ
;         or        cs:[flagsc],al           ; nastaven° novòch p©°znakñ
;testro3: test      byte ptr cs:[flagsc],80h ; ru®° se poloëka ?
;         jz        testro4                  ; poloëka se ru®°
;         inc       word ptr cs:[bp+kurzl-tabl] ; zvò®en° ukazatele kurzoru
;testro4: pop       es
;         pop       ds
;         pop       si
;         pop       ax
;         ret
;
;
;
;
;public   delaktdir
;
;delaktdir:                                ;* zru®en° protàj®°ho adres†©e
;
;         pushf
;         push      ax
;         push      bx
;         push      si
;         push      di
;         push      bp
;         push      ds
;         push      es
;
;         call      getnakt                  ; neaktivn° okno
;         cmp       word ptr cs:[bp+7],1     ; je poáet poloëek = 1 ?
;         jne       delakt3                  ; nen° pr†và 1 poloëka
;         call      cmpdisk
;
;
;         xor       bx,bx                    ; á°slo prvn° poloëky
;         call      adrpolsi                 ; adresa poloëky
;         cmp       word ptr ds:[si+1],".."  ; je to adres†© ".." ?
;         jne       delakt3                  ; nen° to adres†© ".."
;         push      cs
;         pop       ds
;         push      cs
;         pop       es
;         mov       si,ds:[bp+4]             ; cesta k adres†©i
;         mov       di,si
;         call      aktdir                   ; pokus o nastaven° adres†©e
;         call      loadpath                 ; naáten° spr†vnÇho adres†©e
;         and       byte ptr ds:[bp+0],not 2 ; zru®en° p©°znaku naáten° adres†©e
;delakt3: pop       es
;         pop       ds
;         pop       bp
;         pop       di
;         pop       si
;         pop       bx
;         pop       ax
;         popf
;         ret
;
; -----------------------------------------------------------------------------
;public   erradr1
;
;erradr1:                                  ;* chybovÇ hl†®en° - nelze zru®it
;
;
;         push      ax
;         push      bx
;         push      cx
;         push      dx
;         push      si
;         push      di
;         push      ds
;         push      es
;         push      cs
;         pop       es                       ; ES <- CS
;
;         call      topret                   ; n†vrat horn°ho ©†dku
;         mov       bx,cs:[bp+kurzl-tabl]    ; poloëka s kurzorem
;         call      adrpolsi                 ; poskytnut° adresy poloëky
;         mov       bh,ds:[si]               ; £schova atributu
;         push      cs
;         pop       ds                       ; DS <- CS
;                                          ;* sestaven° textu hl†®en°
;
;         lea       di,[outbuf]
;         lea       si,[txtvar]              ; text varov†n°
;         call      transtxt                 ; uloëen° nadpisu
;         lea       si,[errdel1]             ; text "Soubor"
;         test      bh,10h                   ; je to adres†© ?
;         jz        erradr11                 ; nen° to adres†©
;         lea       si,[errdir1]             ; test "Adres†©"
;erradr11:push      bx
;         call      transtxt                 ; p©enos oznaáen°
;         mov       bx,cs:[bp+kurzl-tabl]    ; poloëka s kurzorem
;         call      adrpolsi                 ; poskytnut° adresy poloëky
;         call      dekfile                  ; dek¢dov†n° jmÇna souboru
;         push      cs
;         pop       ds
;         lea       si,[errdir2]             ; text "nelze zru®it"
;         call      transtxt
;         pop       bx                       ; atribut poloëky
;         test      bh,10h                   ; je to adres†© ?
;         lea       si,[errdir6]             ; text "!"
;         jz        erradr12                 ; nen° to adres†©
;         lea       si,[errdir3]             ; text "protoëe nen° pr†zdnò !"
;erradr12:call      transtxt
;                                          ;* zobrazen° hl†®en°
;         lea       si,[txtchyb1]            ; volba "OK"
;         lea       di,[outbuf]              ; buffer s textem
;         xor       al,al
;         call      volbyh                   ; proveden° voleb
;         pushf
;         call      windret                  ; navr†cen° oken
;         popf
;         pop       es
;         pop       ds
;         pop       di
;         pop       si
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;
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

         mov       ah,0dh
         int       21h                      ; reset diskovÇho systÇmu
                                          ;* otev©en° zdrojovÇho souboru
         lea       dx,[outbuf]              ; zdrojovò soubor
         mov       ax,3d00h                 ; otev©en° pro áten°
         int       21h                      ; otev©en° zdrojovÇho souboru
         jc        copyfk8                  ; chyba otev©en° souboru
         call      testbreak                ; je p©eru®en° operace ?
         jc        copyfk9                  ; je p©eru®en° operace
         mov       ds:[inpid],ax            ; identifik†tor vstupn°ho souboru
                                          ;* vytvo©en° c°lovÇho souboru
         lea       dx,[selbuf]              ; c°lovò soubor
;         mov       cl,[outbuf+20]           ; atributy pñvodn°ho souboru
;         and       cx,27h                   ; ponech†n° norm†ln°ch atributñ
ifndef   demo
         xor       cx,cx                    ; norm†ln° atributy
         mov       ah,3ch                   ; funkce vytvo©en° souboru
         int       21h                      ; vytvo©en° c°lovÇho souboru
;         jc        copyfk0                  ; chyba operace
;         call      zrusfil                  ; zru®en° souborñ ze seznamñ
;copyfk0:
endif
         mov       ds:[outid],ax            ; identifik†tor vòstupn°ho souboru
         jc        copyfk1                  ; chyba operace
         call      testbreak                ; je p©eru®en° operace ?
         jnc       copyfk2                  ; operace OK
;         call      copyclose                ; uzav©en° souborñ
         jmp       short copyfk6            ; p©eru®en° operace
copyfk1: call      copycl1                  ; uzav©en° vstupn°ho souboru
         jmp       short copyfk8            ; chyba operace

copyfk2:                                  ;* kop°rov†n° souboru
         sti
         cld
         call      readblok                 ; áten° bloku dat
         jc        copyfk6                  ; chyba operace - p©eru®en°
         jz        copyfk4                  ; konec operace
         sti
         call      writeblok                ; z†pis á†sti bloku dat
         jc        copyfk6                  ; chyba operace - p©eru®en°
         je        copyfk2                  ; jsou zaps†na v®echna data
                                          ;* chyba - nedostatek m°sta
         stc                                ; p©°znak chyby operace
         call      copyclose                ; uzav©en° souborñ
         lea       di,[bufnadp]             ; buffer textu nadpisu
         lea       si,[errcop5]             ; text "Na disku"
         push      di                       ; adresa textu
         call      transtxt
         mov       al,ds:[selbuf]           ; disk c°lovÇ operace
         stosb
         lea       si,[errcop51]            ; text "nen° dost volnÇho m°sta !"
         call      transtxt
         pop       si                       ; text chybovÇho hl†®en°
         jmp       short copyfka            ; chybovò n†vrat

copyfk4:                                  ;* nastaven° data a áasu
         stc
         call      modiukaz                 ; plnÇ zobrazen° ukazatele kop°rov.
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
         lea       si,[erroper]             ; text "Operaci nelze provÇst !"
copyfka: call      zobrchyb                 ; zobrazen° chybovÇho hl†®en°
copyfk9: ret


;public   zrusfil
;zrusfil:                                  ;* zru®en° c°lovÇho souboru ze seznamñ
;
;         pushf
;         push      bp
;         call      getakt                   ; aktivn° okno
;         call      zrusfil0
;         call      getnakt
;         call      zrusfil0
;         pop       bp
;         popf
;         ret
;
;
;zrusfil0:
;         push      bx
;         push      si
;         push      ds
;         call      cmpcpath                 ; je c°lovò adres†© ?
;         jne       zrusfil2                 ; nen° c°lovò adres†©
;         push      cs
;         pop       ds
;         lea       si,[outbuf+20]           ; p©ek¢dovanÇ jmÇno souboru
;         call      hledpol0                 ; nalezen° stejnÇ poloëky
;         jne       zrusfil2                 ; nenalezena stejn† poloëka
;         call      delpol                   ; zru®en° poloëky ze seznamu
;zrusfil2:pop       ds
;         pop       si
;         pop       bx
;         ret
;
;

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
         lea       dx,[selbuf]              ; c°lovò soubor
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
         mov       cx,word ptr ds:[blokuk]  ; nië®° slovo velikosti bloku
         cmp       word ptr ds:[blokuk+2],0 ; je blok vàt®° neë 0ffffh ?
         jne       writebl2                 ; blok je vàt®° neë 0ffffh
         cmp       cx,8000h                 ; je blok vàt®° neë 32 KB ?
         jb        writebl3                 ; blok je men®° neë 32 KB
writebl2:mov       cx,8000h                 ; maxim†ln° blok 32 KB
writebl3:                                 ;* omezen° velikosti bloku zdola
         cmp       cx,2000h                 ; nejmen®° blok 8 KB
         ja        writebl4                 ; blok nen° men®° neë 8 KB
         mov       cx,2000h                 ; omezen° zdola na 8 KB
writebl4:                                 ;* omezen° skuteánòmi daty
         cmp       cx,ds:[numbuf]           ; je v bufferu men®° blok dat ?
         jb        writebl5                 ; blok dat je men®° neë data v bufferu
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
         jne       writebl7                 ; chyba - nedostatek m°sta na disku
         add       dx,ax                    ; zvò®en° adresy v bufferu
         call      modiukaz                 ; zobrazen° ukazatele kop°rov†n°
         sub       ds:[numbuf],ax           ; sn°ëen° poátu dat v bufferu
         ja        writebl1                 ; z†pis dal®°ho bloku dat
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

         lea       si,[outbuf]              ; zadanò adres†©
         call      aktdir                   ; nastaven° c°lovÇho adres†©e
         jnc       adrcop1                  ; adres†© existuje
         call      testbreak                ; je p©eru®en° operace ?
         jc        adrcop33                 ; p©eru®en° operace
                                          ;* chyba zad†n° adres†©e
         lea       si,[errcop1]             ; text "ChybnÇ zad†n° ..."
         jmp       zobrchyb                 ; zobrazen° chybovÇho hl†®en°

adrcop1:                                  ;* pokus o p©epnut° na podadres†©
         lea       di,[outbuf]              ; uloëen° podadres†©e
         lea       si,[rozbflg]             ; moënÇ jmÇno podadres†©e
         push      di
         call      dekfile                  ; dek¢dov†n° jmÇna podadres†©e
         pop       si                       ; p©°padnò podadres†©
         call      aktdir                   ; nastaven° podadres†©e
         jc        adrcop2                  ; nen° to podadres†©
                                          ;* je to podadres†© - zru®° se jmÇno
         lea       di,[rozbnam]             ; jmÇno souboru
         mov       cx,11
         mov       al,"?"                   ; n†hradn° znak
         rep       stosb                    ; vynulov†n° jmÇna
adrcop2: call      testbreak                ; je p©eru®en° operace ?
         jc        adrcop33                 ; p©eru®en° operace
         lea       di,[selbuf]              ; buffer k uloëen° adres†©e
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
         lea       di,[rozbnam]             ; rozbor zadanÇho jmÇna
         mov       cx,11                    ; poáet znakñ jmÇna
         mov       al,"?"                   ; n†hradn° znak
         repne     scasb                    ; nalezen°, zda je znak "?"
         jne       errcopy2                 ; chyba - v°ce souborñ do jednoho
adrcop3: clc
adrcop33:ret

errcopy2:                                 ;* chyba - v°ce souborñ do jednoho

         lea       di,[selbuf]
         push      di
         lea       si,[errcop2]             ; text "Nelze"
         call      transtxt
         call      getoper                  ; poskytnut° operace
         or        al,al                    ; je kop°rov†n° ?
         lea       si,[errcop21]            ; text chyby "kop°rovat"
         jz        errcopy3                 ; je kop°rov†n°
         lea       si,[errcop22]            ; text chyby "p©esouvat"
errcopy3:call      transtxt
         lea       si,[errcop25]            ; text "v°ce souborñ do jednoho !"
         call      transtxt
         pop       si                       ; vòslednò text chyby
         jmp       zobrchyb                 ; zobrazen° chybovÇho hl†®en°

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
;         and       byte ptr cs:[bp+0],not 2 ; zru®en° p©°znaku naáten° adres†©e
;         or        byte ptr cs:[bp+0],4     ; p©°znak, ëe se adres. nenuluje
         call      windretx                 ; naáten° adres†©e
aktuald2:call      testbreak                ; je p©eru®en° operace ?
         pop       bx
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
         mov       word ptr ds:[bufcopy],bufcop2-bufcop1
         mov       byte ptr ds:[bufcop2],0  ; ë†dn† p©edvolba
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
         mov       cs:[bufcop3],di          ; nastaven° cesty k protàj®°mu oknu
         inc       byte ptr cs:[bufcop2]    ; = 1 p©edvolba
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
         call      testaktwn                ; je neaktivn° okno zapnutÇ ?
         jnc       precop6                  ; neakt. okno je zapnutÇ
         mov       si,cs:[bufcop3]          ; p©edvolba 1
         xchg      si,cs:[bufcop4]          ; z†màna p©edvoleb
         mov       cs:[bufcop3],si
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
         test      byte ptr cs:[parint],30h ; je funkce F3 nebo F4 ?
         jz        windret7                 ; nen° ani F3 ani F4
         mov       bh,80h                   ; p©°znak - p©ekreslit v®echny ©†dky
         cmp       word ptr cs:[parbreak],0
         jne       windret9                 ; je diskov† chyba
         test      byte ptr cs:[parint],10h ; je funkce F3 ?
         jnz       windret4                 ; je funkce F3
                                          ;* obnoven° okna F4
         call      outedhlp                 ; zobrazen° n†povàdy
         call      edittop0                 ; poá†teán° zobrazen° inform. ©†dku
         call      editall                  ; p©ekresln° v®ech ©†dkñ
         jmp       short windret9
windret4:                                 ;* obnoven° okna F3
         call      zobtopini                ; inicializace horn°ho ©†dku
         call      zobhlp0                  ; zobrazen° n†povàdy
         call      zoball                   ; p©ekreslen° okna F3
         jmp       short windret9
                                          ;* obnoven° z†kladn°ho okna
windret7:call      getakt
         call      window                   ; aktivn° okno
         call      getnakt
         call      window                   ; neaktivn° okno
windret9:;mov       byte ptr cs:[citachod],0 ; inicializace hodin
         pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         pop       bp
         popf
         ret

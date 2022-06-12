
; modul DOSMEDI.ASM - textovò editor

; *****************************************************************************
;
;                          Textovò editor
;
; *****************************************************************************

code     segment   public
         assume    cs:code,ds:code


extrn    segend:word,topseg:word,editmax:word,erredi1:byte
extrn    getkurz:near,zobrchyb:near,aktdir:near,outbuf:byte
extrn    erroper:byte,col1:byte,col3:byte
extrn    outid:word,editnum:word,dekfile:near,getakt:near
extrn    color:byte,tisknm0:near,outtxt:near,outch1:near
extrn    windret:near,deknum5:near,parnum:byte
extrn    ediradek:word,edipoz:word
extrn    ediflag:byte,deknum3:near,outch:near
extrn    parint:byte,edikurz:word,edidrad:byte,testakth:near
extrn    outch10:near,adrradek:word
extrn    firstrad:word,endrad:word,toppoz:word,delkarad:word
extrn    skokax:near,testshft:near
extrn    testchar:near,testkey:near,aktpage:byte
extrn    edikey:word,volbyh:near,txtchyb1:byte
extrn    flags:byte,transtxt:near
extrn    highcase:near,select:near,lensi:near
extrn    txtedi8:byte
extrn    readdir:near,topret:near,getnakt:near
extrn    delpol:near,modikap:near,cmpdisk:near,cmppath:near
extrn    bufwin:byte,creatfile:near,storfile:near
extrn    msgcek:near,kurzout:near
extrn    inpkeyf:near
extrn    setkurz:near,storfile:near,hledpol:near,rozbset:byte
extrn    diskfail:near,rozbnam:byte,namel:byte,tabr:byte,namer:byte
extrn    firstwl:word,firstwr:word,settabf:near,testaktw:near
extrn    selbuf:byte,windretx:near
extrn    rozbflg:byte,rozbvel:dword,nuldir:byte,loadpath:near
extrn    edikpoz:word
extrn    testbreak:near,parbreak:word
extrn    buffedi:byte,storekall:near,config:byte
extrn    conf2:byte,edivolb2:byte
extrn    lowcase:near,erredi5:byte
extrn    rerdir:near,getdispl:near
extrn    displ:byte,getdispcx:near

edits1:  call      windretx                 ; navr†cen° oken p©i p©eru®en°
edits11: ret

public   editor

editor:                                   ;* editace souboru F4
         call      testaktw
         jc        edits11                  ; okno nen° zapnuto
         call      getkurz                  ; poskytnut° adresy kurzoru
         test      byte ptr ds:[si],11h     ; je to adres†© nebo R/O ?
         jnz       edits11                  ; je to adres†© - konec
         mov       di,offset bufwin         ; pracovn° buffer
         mov       dx,di                    ; zadanò soubor
         call      dekfile                  ; dek¢dov†n° jmÇna souboru

edits2:                                   ;* editace souboru DX
         push      cs
         pop       ds                       ; DS <- CS
         call      msgcek                   ; hl†®en° "áekejte"
         mov       si,ds:[bp+4]             ; adresa cesty k adres†©i
         call      aktdir                   ; nastaven° aktivn°ho adres†©e
         jc        edits1                   ; chyba nastaven° adres†©e
         mov       ah,4eh
         mov       cx,16h                   ; atributy - v®echny soubory
         int       21h                      ; nalezen° souboru
         jc        edits1                   ; soubor neexistuje - chyba

edits4:                                   ;* nastaven° volnÇ pamàti
         mov       ax,ds:[segend]           ; segment konce pamàti
         sub       ax,2                     ; rezerva
         sub       ax,ds:[topseg]           ; voln† pamàü
         jc        edits1                   ; pamàü nedostaáuje
         cmp       ax,1000h                 ; je vàt®° neë 64 KB ?
         jb        editor1                  ; nen° vàt®° neë 64 KB
         mov       ax,0fffh                 ; omezen° na 64 KB
editor1: mov       cl,4
         shl       ax,cl                    ; voln† kapacita (v bajtech)
         mov       ds:[editmax],ax          ; £schova velikosti bufferu

                                          ;* nastaven° ukazatelñ a indik†torñ
         and       byte ptr ds:[ediflag],01110000b ; zru®en° p©°znakñ

                                          ;* naáten° zadanÇho souboru do pamàti
         mov       dx,offset bufwin         ; editovanò soubor
         call      editread                 ; áten° souboru do pamàti
         jc        editor8                  ; chyba - operaci nelze provÇst
         mov       si,9eh                   ; jmÇno souboru
         mov       di,offset buffedi        ; buffer k uloëen° jmÇna
         call      transtxt                 ; p©enos jmÇna souboru


         call      edited                   ; editace souboru

editor8:
         mov       word ptr ds:[editnum],0  ; zru®en° dat v pamàti
         call      windretx                 ; navr†cen° obsahu oken
         ret


public   editmodi
editmodi:                                 ;* modifikace adres†©ñ
         push      bp
         call      storekall                ; uloëen° obou kurzorñ
         call      rerdir                   ; p©°znak novÇho naáten° adres†©e
         mov       bp,ds:[bp+1]             ; adresa protàj®°ho okna
         call      rerdir                   ; p©°znak novÇho naáten° adres†©e
         pop       bp
         ret

; -----------------------------------------------------------------------------
public   edited

edited:                                   ;* editace textu v pamàti

         mov       word ptr ds:[edikey],0   ; zru®en° znaku z bufferu kl†ves
         mov       bx,8000h                 ; p©°znak - p©epsat v®echny ©†dky
edited0:                                  ;* zaá†tek obsluhy jednÇ kl†vesy
edited35:
         push      cs
         pop       ds
         push      cs
         pop       es
         call      editall                  ; zobrazen° v®ech ©†dkñ obrazovky
         or        bl,bl                    ; m† se p©epsat ©†dek ?
         jz        edited1                  ; nep©episuje se ©†dek
         mov       si,cs:[adrradek]         ; adresa ©†dku s kurzorem
         mov       dh,cs:[edidrad]          ; ©†dek na displeji
         call      editline                 ; zobrazen° ©†dku
edited1:
         call      editobrk                 ; zobrazen° kurzoru
         call      inpkeyf                  ; vstup znaku pro editor

         call      resshft                  ; zru®en° nucenÇho p©°znaku SHIFT

edited32:cmp       ax,0300h                 ; je kl†vesa ^@ ?
         je        edited3                  ; je platnò znak ^Q
         or        ah,ah                    ; je znak s ALT- ?
         jz        edited3                  ; je znak s ALT-
         cmp       al,32                    ; je ©°dic° znak < 32 ?
         jb        edited4                  ; je ©°dic° znak (< 32)
         cmp       al,127                   ; je znak ^BS (Delete) ?
         je        edited4                  ; je ©°dic° znak ^BS
edited3: call      ediinsch                 ; vloëen° znaku do ©†dku
         jmp       short edited35           ; vstup dal®°ho znaku
                                          ;* je ©°dic° kl†vesa
edited4: cmp       al,27                    ; je p©eru®en° <ESC> ?
         je        edited6                  ; je p©eru®en° editace <ESC>
         cmp       ah,44h                   ; je konec F10 ?
         je        edited7                  ; konec F10 - uloëen° souboru
         mov       bx,offset skokedi        ; tabulka skokñ editoru
         call      skokax                   ; skok do obsluhy
         jmp       short edited35           ; vstup dal®°ho znaku

edited6:                                  ;* p©eru®en° editace Esc
         call      ediaskul                 ; dotaz na uloëen°
         jc        edited35                 ; p©eru®en° volby - pokraáov†n°
         dec       al                       ; je volba neukl†dat text ?
         je        edited8                  ; text se neukl†d†
         jns       edited35                 ; je pokraáov†n° v editaci

edited7:                                  ;* uloëen° souboru F10, ^KD
         test      byte ptr ds:[ediflag],1  ; byl soubor modifikov†n ?
         jz        edited8                  ; soubor nebyl modifikov†n
         call      ediuloz                  ; uloëen° textu
         jc        edited35                 ; pokraáov†n° v editaci
edited8:
         push      cs
         pop       ds
         push      cs
         pop       es

         ret


; -----------------------------------------------------------------------------

public   skokedi

skokedi  label     word                     ; tabulka skokñ editoru

         db        00h+19                   ; testuje se AL
         db        01h                      ; slovo vlevo ^A
         dw        offset ediwleft
         db        03h                      ; str†nka dolñ ^C
         dw        offset edipgdn
         db        04h                      ; kurzor vpravo ^D
         dw        offset ediright
         db        05h                      ; kurzor nahoru ^E
         dw        offset ediup
         db        06h                      ; slovo vpravo ^F
         dw        offset ediwright
         db        07h                      ; maz†n° znaku vpravo ^G
         dw        offset edidel
         db        08h                      ; maz†n° znaku p©ed kurzorem BS ^H
         dw        offset edibs
         db        09h                      ; tabel†tor ^I
         dw        offset editab
         db        0ah                      ; vloëen° ©†dku ^J
         dw        offset edinl
         db        0dh                      ; konec ©†dku ^M
         dw        offset edienter
         db        0eh                      ; vloëen° ©†dku ^N
         dw        offset edinl
         db        10h                      ; vloëen° znaku ^P
         dw        offset edispec
         db        12h                      ; str†nka nahoru ^R
         dw        offset edipgup
         db        13h                      ; kurzor vlevo ^S
         dw        offset edileft
         db        14h                      ; maz†n° slova vpravo ^T
         dw        offset ediwdel
         db        18h                      ; kurzor dolñ ^X
         dw        offset edidown
         db        19h                      ; vymaz†n° ©†dky ^Y
         dw        offset edidell
         db        7fh                      ; maz†n° slova vlevo ^BS
         dw        offset ediwbs
         db        1fh                      ; z†màna znakñ ^-
         dw        offset edixchg

         db        40h+15                   ; testuje se AH
         db        4dh                      ; kurzor vpravo RIGHT
         dw        offset ediright
         db        4bh                      ; kurzor vlevo LEFT
         dw        offset edileft
         db        50h                      ; kurzor dolñ DOWN
         dw        offset edidown
         db        48h                      ; kurzor nahoru UP
         dw        offset ediup
         db        47h                      ; zaá†tek ©†dku HOME
         dw        offset edihome
         db        4fh                      ; konec ©†dku END
         dw        offset ediend
         db        84h                      ; zaá†tek souboru ^PAGE UP
         dw        offset edicpgup
         db        76h                      ; konec souboru ^PAGE DOWN
         dw        offset edicpgdn
         db        53h                      ; vymaz†n° znaku DELETE
         dw        offset edidel
         db        74h                      ; slovo vpravo ^RIGHT
         dw        offset ediwright
         db        73h                      ; slovo vlevo ^LEFT
         dw        offset ediwleft
         db        77h                      ; horn° okraj ^HOME
         dw        offset edichome
         db        75h                      ; doln° okraj ^END
         dw        offset edicend
         db        49h                      ; o str†nku nahoru PAGEUP
         dw        offset edipgup
         db        51h                      ; o str†nku dolñ PAGEDONW
         dw        offset edipgdn

         db        80h+1                    ; testuje se AX
         dw        0f00h                    ; tabel†tor zpàt SHIFT-TAB
         dw        offset edibtab

         db        0

; -----------------------------------------------------------------------------
public   editread

editread:                                 ;* áten° souboru DX do pamàti


         mov       cx,ds:[editmax]          ; velikost bufferu
         dec       cx
         xor       si,si                    ; poá†teán° ukl†dac° adresa
         call      editrdb                  ; áten° souboru jako bloku
         jc        editrd6                  ; chyba operace
         mov       ds:[editnum],ax          ; nastaven° aktu†ln° dÇlky dat
         and       byte ptr ds:[ediflag],01110100b ; zru®en° p©°znakñ
         call      edicpgup                 ; skok na zaá†tek souboru
         mov       bh,80h
editrd6: ret


editrdb:                                  ;* áten° bloku dat do pamàti
                                            ; VSTUP: DS:DX=jmÇno souboru
                                            ;        SI=ukl†dac° adresa
                                            ;        CX=max. dÇlka dat pro áten°
                                            ; VùSTUP: CY=chyba operace
                                            ;         AX=poáet naátenòch bajtñ

                                          ;* test, zda soubor lze nalÇst
         push      cx
         mov       ah,4eh
         mov       cx,16h                   ; atributy - v®echny soubory
         int       21h                      ; nalezen° souboru
         pop       cx
         jc        editrd2                  ; chyba - nenalezen
                                          ;* test, zda to nen° adres†© nebo R/O
         test      byte ptr ds:[95h],11h    ; je to soubor R/O nebo adres†© ?
         stc
         jnz       editrd2                  ; je to soubor R/O nebo adres†©
                                          ;* otev©en° souboru
         mov       ax,3d00h                 ; otev©en° souboru pro áten°
         int       21h                      ; otev©en° souboru pro áten°
         jc        editrd2                  ; chyba operace
                                          ;* naáten° souboru
         mov       bx,ax                    ; identifik†tor souboru
         mov       ds,ds:[topseg]           ; segment zaá†tku bufferu
         mov       dx,si                    ; poá†teán° offset bufferu
         mov       ah,3fh                   ; funkce áten° ze souboru
         int       21h                      ; naáten° dat ze souboru
         push      cs
         pop       ds
                                          ;* uzav©en° souboru
         push      ax
         pushf
         mov       ah,3eh                   ; funkce uzav©en° souboru
         int       21h                      ; uzav©en° souboru
         popf
         pop       ax                       ; dÇlka naátenòch dat
         jc        editrd7                  ; chyba naáten° dat
         cmp       word ptr ds:[9ch],0      ; je soubor vàt®° neë 64 KB ?
         jne       editrd4                  ; soubor je p©°li® velkò
         mov       dx,ds:[editmax]          ; velikost pamàti
         cmp       dx,ds:[9ah]              ; nië®° slovo velikosti souboru
         jbe       editrd4                  ; soubor p©°li® velkò
         cmp       cx,ax                    ; je naáten plnò rozsah dat ?
         jbe       editrd4                  ; chyba - soubor nen° celò
                                          ;* obsluha chyb
editrd2: jnc       editrd3
editrd7: call      testbreak
         jc        editrd3                  ; bylo p©eru®en°
                                          ;* chyba - soubor je velkò
editrd4: call      windret
         mov       si,offset erredi1        ; chyba "soubor se nenaáetl celò !"
         call      zobrchyb                 ; zobrazen° chybovÇho hl†®en°
editrd3: mov       word ptr ds:[parbreak],0
         ret

; -----------------------------------------------------------------------------
public   ediuloz
ediuloz:                                  ;* uloëen° souboru F2
                                            ; VùSTUP: CY=chyba operace

         mov       dx,offset bufwin         ; editovanò soubor
ediuloz0:
         and       byte ptr cs:[ediflag],0feh ; zru®en° p©°znaku modifikace
         xor       si,si                    ; poá†teán° adresa
         mov       cx,cs:[editnum]          ; dÇlka dat k z†pisu

public   editwr
editwr:                                   ;* z†pis bloku dat na disk
                                            ; VSTUP: DS:DX=jmÇno souboru
                                            ;        SI=adresa bloku
                                            ;        CX=dÇlka dat k z†pisu
                                            ; VùSTUP: CY=chyba z†pisu

         call      editmodi                 ; modifikace adres†©ñ
                                          ;* otev©en° souboru
         mov       ax,3d01h                 ; otev©en° souboru pro z†pis
         int       21h                      ; otev©en° souboru pro z†pis
         jnc       editwr2                  ; operace OK
         call      testbreak                ; bylo to p©eru®en° operace ?
         jc        editwr1                  ; bylo p©eru®en° operace
         push      cx
         xor       cx,cx
         mov       ah,3ch
         int       21h                      ; vytvo©en° souboru
         pop       cx
         jnc       editwr2                  ; operace OK
editwr0: call      testbreak                ; bylo to p©eru®en° operace ?
         jc        editwr1                  ; bylo p©eru®en° operace
         mov       si,offset erredi5        ; chyba "chyba zad†n° souboru"
editwr3: call      zobrchyb                 ; zobrazen° chybovÇho hl†®en°
         call      windret                  ; navr†cen° obsahu okna
editwr1: mov       word ptr ds:[parbreak],0 ; zru®en° p©°znaku p©eru®en°
         stc                                ; p©°znak chyby z†pisu
         ret
editwr2:                                  ;* z†pis dat na disk
         mov       bx,ax                    ; identifik†tor souboru
         mov       ah,40h                   ; funkce z†pisu do souboru
         mov       dx,si                    ; poá†teán° offset dat
         mov       ds,ds:[topseg]           ; segment s textem
         push      cx                       ; poëadovanò poáet bajtñ
         int       21h                      ; z†pis dat do souboru
         push      cs
         pop       ds
         push      ax                       ; skuteán† dÇlka zapsanòch dat
         pushf
         mov       ah,40h                   ; funkce z†pisu do souboru
         xor       cx,cx                    ; poëadavek zkr†cen° souboru
         int       21h                      ; zkr†cen° souboru
         mov       ah,3eh
         int       21h                      ; uzav©en° souboru
         popf
         pop       ax                       ; skuteán† dÇlka dat
         pop       cx                       ; poëadovan† dÇlka dat
         jc        editwr0                  ; chyba p©i z†pisu dat
         mov       si,offset erredi5        ; hl†®en° o chybà uloëen°
         cmp       ax,cx                    ; souhlas° poáet zapsanòch bajtñ ?
         jne       editwr3                  ; soubor nebyl uloëen celò

         ret

; -----------------------------------------------------------------------------
public   edixchg

edixchg:                                  ;* z†màna dvou znakñ ^-
         call      edisetk                  ; aktualizace pozice na ©†dku
         push      ds
         call      edigkurz                 ; poskytnut° adresy kurzoru
         cmp       word ptr ds:[si],0a0dh   ; je konec ©†dku ?
         je        edixchg2                 ; je konec ©†dku
         cmp       word ptr ds:[si+1],0a0dh ; je p©ed koncem ©†dku ?
         je        edixchg2                 ; je p©ed koncem ©†dku
         mov       ax,ds:[si]               ; 2 znaky nad kurzorem
         xchg      ah,al                    ; z†màna znakñ
         mov       ds:[si],ax               ; uloëen° znakñ
         inc       bl                       ; p©°znak modifikace ©†dku
         or        byte ptr cs:[ediflag],1  ; p©°znak modifikace souboru
edixchg2:pop       ds
         ret

; -----------------------------------------------------------------------------
public   ediaskul

ediaskul:                                 ;* dotaz, zda se m† provÇst uloëen°
                                            ; VùSTUP: AL=0 - uloëit text
                                            ;            1 - neukl†dat text
                                            ;            2 - pokraáov†n°
                                            ;         CY=p©eru®en° operace

         push      si
         push      di
         mov       bh,80h                   ; p©°znak p©ekreslen° obrazovky
         mov       al,1                     ; k¢d - neukl†dat text
         test      byte ptr ds:[ediflag],1  ; byl soubor modifikov†n ?
         jz        ediasku3                 ; soubor nebyl modifikov†n
         mov       si,offset edivolb2       ; volby
         mov       di,offset txtedi8        ; hl†®en° o modifikaci
         xor       al,al                    ; p©edvolba
         call      volbyh                   ; dotaz na dal®° operaci
ediasku3:pop       di
         pop       si
         ret

; -----------------------------------------------------------------------------
public   deletemet

deletemet:                                ;* zru®en° bloku textu s posunem kurz.

         call      deletemem                ; zru®en° bloku textu
                                          ;* korekce adres
         push      ax
                                          ;* korekce kurzoru
         mov       ax,cs:[edikurz]          ; pñvodn° adresa kurzoru
         call      edimoved                 ; p©esun ukazatele po ru®en° bloku
         mov       cs:[edikurz],ax          ; nov† adresa kurzoru
                                          ;* korekce prvn°ho zobrazenÇho ©†dku
         mov       ax,cs:[firstrad]         ; pñvodn° adresa prvn°ho ©†dku
         call      edimoved                 ; p©esun ukazatele po ru®en° bloku
         mov       cs:[firstrad],ax         ; nov† adresa prvn°ho ©†dku
         pop       ax
         ret


public   deletemem

deletemem:                                ;* zru®en° bloku textu
                                            ; VSTUP: SI=prvn° adresa bloku
                                            ;        DI=druh† adresa bloku

         push      cx
         push      si
         push      di
         push      ds
         push      es
         mov       ds,cs:[topseg]           ; DS <- segment s textem
         push      ds
         pop       es                       ; ES <- segment s textem
                                          ;* zru®en° bloku
         cmp       si,di                    ; je SI pod DI ?
         je        deletem3                 ; adresy jsou shodnÇ
         ja        deletem2                 ; SI je nad DI - OK
         xchg      si,di                    ; z†màna SI a DI (oprava po©ad°)
deletem2:mov       cx,cs:[editnum]          ; poáet znakñ v souboru
         sub       cx,si                    ; poáet znakñ do zbytku textu

         rep       movsb                    ; vymaz†n° bloku
         sub       si,di                    ; vòpoáet dÇlky bloku
         sub       cs:[editnum],si          ; zmen®en° dÇlky textu
         or        byte ptr cs:[ediflag],1  ; p©°znak, ëe byl soub. modifikov†n

deletem3:pop       es
         pop       ds
         pop       di
         pop       si
         pop       cx
                                          ;* korekce znaáek v textu
;         push      ax
;         push      bx
;         push      cx
;         lea       bx,[ediblkb]             ; tabulka adres znaáek
;         mov       cx,13                    ; poáet znaáek v tabulce
;deletem4:mov       ax,cs:[bx]               ; korigovan† znaáka
;         call      edimoved                 ; p©esun ukazatele po ru®en° bloku
;         mov       cs:[bx],ax               ; nov† hodnota znaáky
;         add       bx,2                     ; zvò®en° ukazatele v tabulce
;         loop      deletem4                 ; dal®° znaáka
;         pop       cx
;         pop       bx
;         pop       ax
         ret

; -----------------------------------------------------------------------------
public   insertbl
insertbl:                                 ;* vytvo©en° prostoru pro blok
                                            ; VSTUP: SI,DI=adresy bloku
                                            ; VùSTUP: CY=nen° dostateánò prostor

         push      cx
         push      si
         push      di
         push      ds
         push      es
         mov       ds,cs:[topseg]           ; segment s textem
         push      ds
         pop       es                       ; ES <- buffer s textem
                                          ;* korekce: SI=nië®°, DI=vy®®°
         cmp       si,di
         jb        insertb1                 ; SI je pod DI - OK
         je        insertb4                 ; nejsou ë†dn† data k vloëen°
         xchg      si,di                    ; z†màna SI a DI
insertb1:                                 ;* zvò®en° dat v pamàti
         mov       cx,di                    ; ukl†dac° adresa
         sub       cx,si                    ; poáet vkl†danòch bajtñ
         add       cx,cs:[editnum]          ; novò konec dat
         cmp       cx,cs:[editmax]          ; je p©ekroáen poáet dat v bufferu ?
         cmc
         jc        insertb4                 ; nen° dostateánò prostor pro blok
         mov       cs:[editnum],cx          ; novò konec dat v pamàti
                                          ;* odsun bloku dat
         sub       cx,di                    ; poáet znakñ do zbytku textu
         jbe       insertb2                 ; nejsou ë†dn† data
         add       si,cx                    ; zdrojov† adresa p©esunu + 1
         add       di,cx                    ; c°lov† adresa p©esunu + 1
         dec       si                       ; zdrojov† adresa p©esunu
         dec       di                       ; c°lov† adresa p©esunu
         std                                ; smàr dolñ
         rep       movsb                    ; odsun bloku textu
         cld                                ; smàr nahoru
insertb2:or        byte ptr cs:[ediflag],1  ; nastaven° p©°znaku modifik. textu
insertb4:pop       es
         pop       ds
         pop       di
         pop       si
         pop       cx
                                          ;* korekce znaáek v textu
;         pushf
;         push      ax
;         push      bx
;         push      cx
;         lea       bx,[ediblkb]             ; tabulka adres znaáek
;         mov       cx,13                    ; poáet znaáek v tabulce
;insertb3:mov       ax,cs:[bx]               ; korigovan† znaáka
;         call      edimovei                 ; p©esun ukazatele po ru®en° bloku
;         mov       cs:[bx],ax               ; nov† hodnota znaáky
;         add       bx,2                     ; zvò®en° ukazatele v tabulce
;         loop      insertb3                 ; dal®° znaáka
;         pop       cx
;         pop       bx
;         pop       ax
;         popf

         ret

; -----------------------------------------------------------------------------
public   ediiniuk

ediiniuk:                                 ;* inicializace ukazatelñ textu

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      ds
                                          ;* kontrola spr†vnosti kurzoru
         call      edigkurz                 ; poskytnut° adresy kurzoru
         or        si,si                    ; je jië zaá†tek ?
         jz        ediiniu1                 ; je zaá†tek souboru
         cmp       word ptr ds:[si-1],0a0dh ; je kurzor na p©elomu ©†dku ?
         jne       ediiniu1                 ; nen° na p©elomu ©†dku
         dec       word ptr cs:[edikurz]    ; korekce kurzoru
ediiniu1:
         push      cs
         pop       ds
                                          ;* nastaven° á°sla a adresy ©†dku
         mov       ax,ds:[edikurz]          ; adresa kurzoru
         call      findrad                  ; nalezen° ©†dku v textu
         mov       ds:[adrradek],si         ; adresa zaá†tku ©†dku
         mov       ds:[ediradek],dx         ; á°slo ©†dku
         mov       di,si                    ; £schova adresy ©†dku s kurzorem
                                          ;* nastaven° pozice na ©†dku
         call      findpoz                  ; nalezen° pozice na ©†dku
         mov       ds:[edikpoz],bx          ; nastaven° pozice na ©†dku
         mov       si,ds:[firstrad]         ; adresa prvn°ho ©†dku
                                          ;* kontrola podteáen° horn°ho ©†dku
         cmp       si,di                    ; je prvn° ©†dek pod kurzorovòm ?
         jbe       ediiniu2                 ; je pod kurzorovòm - OK
         mov       ds:[firstrad],di         ; je to jako novò prvn° ©†dek
         mov       byte ptr ds:[edidrad],0  ; kurzor je na 1. ©†dku
         mov       bh,80h
         jmp       short ediiniu6
ediiniu2:                                 ;* nalezen° á°sla prvn°ho ©†dku
         mov       cx,dx                    ; £schova á°sla ©†dku s kurzorem
         mov       ax,si                    ; hledan† adresa (prvn° ©†dek)
         call      findrad                  ; nalezen° á°sla prvn°ho ©†dku
                                          ;* vòpoáet á°sla ©†dku na displeji
         mov       al,cs:[displ]            ; poáet ©†dkñ celkem
         cbw
         sub       cx,dx                    ; rozd°l ©†dkñ
         inc       cx                       ; á°slo ©†dku s kurzorem na displeji
         cmp       cx,ax                    ; je ©†dek vy®®° neë posledn° ?
         jb        ediiniu5                 ; ©†dek je je®tà v mez°ch
         shr       ax,1                     ; polovina ©†dku
ediiniu3:                                 ;* kontrola p©eteáen° horn°ho ©†dku
         cmp       cx,ax                    ; je ©†dek vy®®° neë prost©edn° ?
         jbe       ediiniu5                 ; ©†dek je jië v mez°ch
         call      edisnxt0                 ; nalezen° dal®°ho ©†dku
         jc        ediiniu5
         mov       bh,80h
         dec       cx                       ; zmen®en° rozd°lu ©†dkñ
         jmp       short ediiniu3           ; dal®° test
ediiniu5:mov       ds:[firstrad],si         ; nastaven° adresy prvn°ho ©†dku
         dec       cl
         mov       ds:[edidrad],cl          ; nastaven° ©†dku pro zobrazen°
ediiniu6:
         call      edikort                   ; korekce zaá†tku ©†dku
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   findrad

findrad:                                  ;* nalezen° ©†dku v textu
                                            ; VSTUP: AX=hledan† adresa
                                            ; VùSTUP: SI=adresa ©†dku
                                            ;         DX=á°slo ©†dku
                                            ;         CY=©†dek nenalezen

         push      ax
         push      di
         xor       si,si                    ; adresa prvn°ho ©†dku
         xor       dx,dx                    ; á°taá ©†dkñ
         dec       dx                       ; p©ednastaven° á°taáe na -1
findrad1:inc       dx                       ; zvò®en° á°taáe ©†dkñ
         mov       di,si                    ; £schova p©edchoz°ho ©†dku
         call      edisnxt0                 ; nalezen° dal®°ho ©†dku
         jc        findrad3                 ; ©†dek nenalezen
         cmp       si,ax                    ; je jië nad hledanou pozic° ?
         jbe       findrad1                 ; pozice je®tà nen° dosaëeno
findrad3:mov       si,di                    ; n†vrat adresy zaá†tku ©†dku
         pop       di
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   findpoz

findpoz:                                  ;* nalezen° pozice na ©†dku
                                            ; VSTUP: AX=hledan† adresa
                                            ;        SI=adresa zaá†tku ©†dku
                                            ; VùSTUP: BX=pozice na ©†dku
                                            ;         CY=neplatn† adresa

         push      si
         push      dx
         push      ds
         mov       ds,cs:[topseg]           ; segment bufferu
         xor       dx,dx                    ; relativn° á°taá pozice na ©†dku
findpoz1:cmp       si,ax                    ; je jië dosaëeno hledanÇ pozice ?
         jae       findpoz2                 ; hledanÇ pozice je jië dosaëeno
         call      ediincp                  ; zvò®en° pozice na ©†dku
         jnc       findpoz1                 ; nen° konec - dal®° pozice
findpoz2:mov       bx,dx                    ; pozice na ©†dku
         pop       ds
         pop       dx
         pop       si
         ret

; -----------------------------------------------------------------------------
public   edimovei

edimovei:                                 ;* p©esun ukazatele po vytvo©en° bloku
                                            ; VSTUP: SI=prvn° adresa bloku
                                            ;        DI=druh† adresa bloku
                                            ; V/V:   AX=korigovan† adresa

         push      si
         push      di
         cmp       si,di                    ; je SI pod DI ?
         jbe       edimovi1                 ; SI je pod DI - OK
         xchg      si,di                    ; z†màna SI a DI (oprava po©ad°)
edimovi1:cmp       ax,si                    ; je ukazatel pod blokem ?
         jb        edimovi4                 ; ukazatel je pod blokem - OK
         sub       di,si                    ; vòpoáet dÇlky bloku
         add       ax,di                    ; zvò®en° adresy o blok
edimovi4:pop       di
         pop       si
         ret

; -----------------------------------------------------------------------------
public   edimoved

edimoved:                                 ;* p©esun ukazatele po ru®en° bloku
                                            ; VSTUP: SI=prvn° adresa bloku
                                            ;        DI=druh† adresa bloku
                                            ; V/V:   AX=korigovan† adresa

         push      si
         push      di
         cmp       si,di                    ; je SI pod DI ?
         jbe       edimovd1                 ; SI je pod DI - OK
         xchg      si,di                    ; z†màna SI a DI (oprava po©ad°)
edimovd1:cmp       ax,si                    ; je ukazatel pod blokem ?
         jb        edimovd4                 ; ukazatel je pod blokem - OK
         cmp       ax,di                    ; je ukazatel nad blokem ?
         jae       edimovd3                 ; ukazatel je nad blokem
         mov       ax,si                    ; ukazatel uvnit© -> zaá†tek bloku
         jmp       short edimovd4
edimovd3:sub       di,si                    ; vòpoáet dÇlky bloku
         sub       ax,di                    ; sn°ëen° adresy kurzoru o blok
edimovd4:pop       di
         pop       si
         ret

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------
public   edienter,edinl

edienter:                                 ;* konec ©†dku ^M (ENTER)

edient2: call      edinl                    ; vloëen° ©†dku
         jmp       ediright                 ; posun na novò ©†dek


edinl:                                    ;* vloëen° ©†dku ^N,^J (^ENTER)
         push      word ptr cs:[edikurz]    ; £schova adresy kurzoru
         push      word ptr cs:[edikpoz]    ; £schova pozice kurzoru
         mov       al,0dh
         call      ediinsch                 ; vloëen° znaku 0dh
         mov       al,0ah
         call      ediinsch                 ; vloëen° znaku 0ah
         pop       word ptr cs:[edikpoz]    ; n†vrat pozice kurzoru
         pop       word ptr cs:[edikurz]    ; n†vrat adresy kurzoru
         mov       bh,80h                   ; p©°znak p©eps†n° v®ech ©†dkñ
         ret

; -----------------------------------------------------------------------------
public   edibtab

edibtab:                                  ;* zpàtnò tabel†tor SHIFT-TAB

edibtb1: call      edileft                  ; posun kurzoru o znak vpravo
         jc        edibtb2                  ; konec souboru
         test      byte ptr cs:[edikpoz],7  ; je pozice tabel†toru ?
         jnz       edibtb1                  ; nedosaëeno je®tà pozice
edibtb2: ret

; -----------------------------------------------------------------------------
public   editab

editab:                                   ;* vloëen° tabel†toru ^I (TAB)

         push      ds
         test      byte ptr ds:[ediflag],4  ; je zapnuto vkl†d†n° ?
         jz        editab4                  ; vkl†d†n° je zapnuto - vloëen° TAB
editab1: call      edigkurz                 ; poskytnut° adresy kurzoru
         cmp       word ptr ds:[si],0a0dh   ; je konec ©†dku ?
         je        editab4                  ; konec ©†dku - vloëen° tabel†toru
editab3: call      ediright                 ; posun kurzoru o znak vpravo
         jc        editab4                  ; konec souboru - vloëen° tabel†toru
         test      byte ptr cs:[edikpoz],7  ; je pozice tabel†toru ?
         jnz       editab1                  ; pozice je®tà nedosaëeno - dal®°
         jmp       short editab2
editab4: call      ediinsch                 ; vloëen° znaku tabel†toru
editab2: pop       ds
         ret

; -----------------------------------------------------------------------------
public   edispec

edispec:                                  ;* vloëen° znaku ^P

         xor       dx,dx
         mov       al,3
         call      outch1
         mov       al,"^"
         call      outch1
         mov       al,"P"
         call      outch1
         xor       ax,ax
         int       16h                      ; vstup znaku z kl†vesnice

public   ediinsch

ediinsch:                                 ;* vloëen° znaku AL

         push      si
         push      di
         push      ds
         call      edigkurz                 ; poskytnut° adresy kurzoru
         cmp       si,cs:[editnum]          ; je na konci souboru ?
         jae       ediinsc0                 ; vloëen° znaku
         cmp       word ptr ds:[si],0a0dh   ; je p©ed koncem ©†dku ?
         je        ediinsc0                 ; je p©ed koncem ©†dku - vkl†d†n°
ediinsc3:test      byte ptr cs:[ediflag],4  ; je vkl†d†n° INSERT ?
         jnz       ediinsc1                 ; vkl†d†n° nen° zapnuto
ediinsc0:mov       di,si                    ; £schova adresy
         inc       di                       ; druh† adresa pro vloëen°
         call      insertbl                 ; vytvo©en° prostoru pro znak
         jc        ediinsc2                 ; nen° prostor pro vloëen° znaku
ediinsc1:mov       ds:[si],al               ; uloëen° novÇho znaku
         or        byte ptr cs:[ediflag],1  ; nastaven° p©°znaku modifik. textu
         mov       ax,cs:[edikpoz]          ; £schova pozice kurzoru
         inc       bl                       ; p©°znak modifikace ©†dku
         call      ediright                 ; posun kurzoru vpravo

ediinsc2:call      edisetk                  ; uschov†n° pozice kurzoru
         pop       ds
         pop       di
         pop       si
         ret

; -----------------------------------------------------------------------------
public   ediwleft

ediwleft:                                ;* posun o slovo vpravo

         push      ax
         push      si
         push      ds
                                          ;* nalezen° konce slova
ediwlft1:call      edigkurz                 ; poskytnut° adresy kurzoru
         dec       si                       ; p©edch†zej°c° znak
         lodsb                              ; znak p©ed kurzorem
         call      testchar                 ; je oddàlovac° znak ?
         jnc       ediwlft2                 ; nen° oddàlovac° znak
         call      edileft                  ; posun kurzoru vlevo
         jnc       ediwlft1                 ; dal®° znak
                                          ;* nalezen° zaá†tku p©ede®lÇho slova
ediwlft2:call      edigkurz                 ; poskytnut° adresy kurzoru
         dec       si                       ; p©edch†zej°c° znak
         lodsb                              ; znak p©ed kurzorem
         call      testchar                 ; je oddàlovac° znak ?
         jc        ediwlft3                 ; je oddàlovac° znak
         call      edileft                  ; posun kurzoru vlevo
         jnc       ediwlft2                 ; dal®° znak
ediwlft3:pop       ds
         pop       si
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   ediwright

ediwright:                                ;* posun o slovo vpravo

         push      ax
         push      si
         push      ds
                                          ;* nalezen° konce slova
ediwrg1: call      edigkurz                 ; poskytnut° adresy kurzoru
         lodsb                              ; znak nad kurzorem
         call      testchar                 ; je oddàlovac° znak ?
         jc        ediwrg2                  ; je oddàlovac° znak
         call      ediright                 ; posun kurzoru vpravo
         jnc       ediwrg1                  ; dal®° znak
                                          ;* nalezen° zaá†tku dal®°ho slova
ediwrg2: call      edigkurz                 ; poskytnut° adresy kurzoru
         lodsb                              ; znak nad kurzorem
         call      testchar                 ; je oddàlovac° znak ?
         jnc       ediwrg3                  ; nen° oddàlovac° znak
         call      ediright                 ; posun kurzoru vpravo
         jnc       ediwrg2                  ; dal®° znak
ediwrg3: pop       ds
         pop       si
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   ediwbs

ediwbs:                                   ;* maz†n° slova p©ed kurzorem

         mov       di,ds:[edikurz]          ; adresa kurzoru
         call      ediwleft                 ; skok o slovo vlevo
         mov       si,ds:[edikurz]          ; nov† adresa kurzoru
         cmp       si,di                    ; byl posun kurzoru ?
         je        ediwbs3                  ; nebyl posun kurzoru
         call      deletemem                ; zru®en° bloku textu
         call      edidell0                 ; p©ekreslen° zbytku obrazovky
ediwbs3: ret

; -----------------------------------------------------------------------------
public   ediwdel

ediwdel:                                  ;* maz†n° slova vpravo ^T, ^DELETE

         push      ds
         call      edigkurz                 ; poskytnut° adresy kurzoru
         mov       di,si                    ; £schova kurzoru
                                          ;* nalezen° konce slova
ediwdel1:cmp       si,cs:[editnum]          ; je jië konec souboru ?
         jae       ediwdel3                 ; je konec souboru
         lodsb                              ; znak nad kurzorem
         call      testchar                 ; je oddàlovac° znak ?
         jnc       ediwdel1                 ; nen° oddàlovaá - dal®° znak
         dec       si                       ; n†vrat prvn°ho znaku oddàlovaáe
         cmp       si,di                    ; byl nàjakò znak ?
         jne       ediwdel2                 ; byl nàjakò znak - ru®en° po EOL
         cmp       word ptr ds:[si],0a0dh   ; n†sleduje ihned EOL ?
         jne       ediwdel2                 ; nen†sleduje EOL
         inc       si                       ; p©eskoáen° bajtu CR
                                          ;* nalezen° zaá†tku dal®°ho slova
ediwdel2:cmp       si,cs:[editnum]          ; je jië konec souboru ?
         jae       ediwdel3                 ; je konec souboru
         cmp       word ptr ds:[si],0a0dh   ; je konec ©†dku ?
         je        ediwdel3                 ; je konec ©†dku
         lodsb                              ; znak nad kurzorem
         call      testchar                 ; je oddàlovac° znak ?
         jc        ediwdel2                 ; je oddàlovaá - dal®° znak
         dec       si
ediwdel3:pop       ds

         cmp       si,di                    ; je nàjakò znak ?
         je        ediwdel4                 ; nen° ë†dnò znak k ru®en°
         call      deletemem                ; zru®en° bloku textu
         call      edidell0                 ; p©ekreslen° zbytku obrazovky
ediwdel4:ret

; -----------------------------------------------------------------------------
public   edidel,edibs

edibs:                                    ;* zru®en° znaku p©ed kurzorem
         call      edileft                  ; posun kurzoru vlevo
         jc        edidel3                  ; je jië na zaá†tku textu

edidel:                                   ;* vymaz†n° znaku nad kurzorem
                                            ; VùSTUP: CY=neru®il se ë†dnò znak

         push      si
         push      di
         push      ds
         call      edigkurz                 ; poskytnut° adresy kurzoru
         mov       di,si                    ; adresa kurzoru
         inc       di                       ; ru®° se 1 znak
         cmp       si,cs:[editnum]          ; je jië konec souboru ?
         cmc
         jb        edidel2                  ; je jië konec souboru
         inc       bl                       ; p©°znak p©eps†n° ©†dku
         cmp       word ptr ds:[si],0a0dh   ; je konec ©†dku ?
         jne       edidel1                  ; ru®° se jen 1 znak
         inc       di                       ; ru®° s 2 znaky
edidel0: mov       bh,80h                   ; p©°znak p©eps†n° v®ech ©†dkñ
edidel1: call      deletemem                ; zru®en° bloku pamàti
         clc
edidel2: pop       ds
         pop       di
         pop       si
edidel3: ret

; -----------------------------------------------------------------------------
public   edidell

edidell:                                  ;* vymaz†n° ©†dku ^Y

         mov       si,cs:[adrradek]         ; adresa ©†dku s kurzorem
         mov       di,si
         call      edisnxt0                 ; nalezen° dal®°ho ©†dku
         cmp       si,di                    ; je nàjakò znak k ru®en° ?
         je        edidell2                 ; nen° ë†dnò znak k ru®en°
         call      deletemem                ; zru®en° bloku pamàti
         call      edinorm                  ; normalizace kurzoru
edidell0:or        bh,bh                    ; je p©ekreslen° obrazovky ?
         jnz       edidell2                 ; je p©ekreslen°
                                          ;* zobrazen° zbylòch ©†dkñ
         mov       si,cs:[adrradek]         ; adresa ©†dku
         mov       dh,cs:[edidrad]          ; ©†dek s kurzorem
         xor       cx,cx
         mov       cl,cs:[displ]            ; p¢cet ©†dkñ - 1
         inc       cx                       ; poáet ©†dkñ
         sub       cl,dh                    ; poáet zbylòch ©†dkñ k zobrazen°
;         call      testakth
;         jc        edidell1                 ; nen° n†povàda
;         dec       cl
edidell1:mov       cs:[endrad],si           ; nastaven° adresy posledn°ho ©†dku
         call      editline                 ; zobrazen° jednoho ©†dku
         call      edisnxt                  ; nalezen° dal®°ho ©†dku
         inc       dh                       ; zvò®en° ©†dku na displeji
         loop      edidell1
         xor       bh,bh
edidell2:ret

; -----------------------------------------------------------------------------
public   edicpgup

edicpgup:                                 ;* posun na zaá†tek souboru ^PAGE UP

         xor       ax,ax
         cmp       ds:[edikurz],ax          ; je jië zaá†tek souboru ?
         pushf
         mov       di,offset firstrad
         mov       cx,offset edidrad+1
         sub       cx,offset firstrad       ; poáet bajtñ tabulky
         rep       stosb                    ; vymaz†n° dat
;         inc       al
;         stosb                              ; nastaven° prvn°ho ©†dku
         popf
         je        edicpgu2                 ; je jië zaá†tek souboru
         mov       bh,80h                   ; p©ekreslen° obrazovky
edicpgu2:ret

; -----------------------------------------------------------------------------
public   edicpgdn

edicpgdn:                                 ;* posun na konec souboru ^PAGE DOWN

         call      edidown                  ; posun o ©†dek dolñ
         jnc       edicpgdn
         call      ediend                   ; posun na konec ©†dku
         ret

; -----------------------------------------------------------------------------
public   edipgup

edipgup:                                  ;* posun o str†nku nahoru

         call      getdispcx                ; poáet ©†dkñ bez n†povàdy
         dec       cx                       ; poáet ©†dkñ pro posun
edipgup1:                                 ;* nastaven° novÇho prvn°ho ©†dku
         call      setshft                  ; nucenò p©°znak SHIFT
         jmp       short edicup1            ; posun nahoru

; -----------------------------------------------------------------------------
public   edipgdn

edipgdn:                                  ;* posun o str†nku dolñ


         call      getdispcx                ; poáet ©†dkñ bez n†povàdy
         dec       cx                       ; poáet ©†dkñ pro posun
edipgdn0:                                 ;* zvò®en° adresy ©†dku s kurzorem
         call      setshft                  ; nucenò p©°znak SHIFT
         jmp       short edicdn1            ; posun dolñ

edicup1: call      ediup
         loop      edicup1
         ret

edicdn1: call      edidown
         loop      edicdn1
         ret

; -----------------------------------------------------------------------------
public   setshft
setshft:                                  ;* nastaven° nucenÇho p©°znaku SHIFT
         pushf
         or        byte ptr cs:[conf2],8    ; nucenò p©°znak SHIFT
         popf
         ret


public   resshft
resshft:                                  ;* nulov†n° nucenÇho p©°znaku SHIFT

         pushf
         and       byte ptr cs:[conf2],not 8; zru®en° nucenÇho p©°znaku SHIFT
         popf
         ret

; -----------------------------------------------------------------------------
public   ediup

ediup:                                    ;* posun kurzoru nahoru
                                            ; VùSTUP: CY=nen° posun

         push      ax
         push      cx
         push      si
                                          ;* nastaven° na p©edchoz° ©†dek
         mov       si,cs:[adrradek]         ; adresa ©†dku s kurzorem
         call      edispre                  ; nalezen° p©edchoz°ho ©†dku
         jc        ediup6                   ; nen° jië dal®° ©†dek
         mov       cs:[adrradek],si         ; nastaven° novÇ adresy ©†dku
         dec       word ptr cs:[ediradek]   ; zvò®en° á°sla ©†dku
         call      edinorm                  ; normalizace kurzoru
                                          ;* sn°ëen° ©†dku na displeji
         dec       byte ptr cs:[edidrad]    ; sn°ëen° ©†dku na displeji
         js        ediup8                   ; p©ekroáen zaá†tek - rolov†n°
                                          ;* rolov†n° p©i SHIFT ?
         call      testshft                 ; je stisknut p©esmykaá SHIFT ?
         jz        ediup3                   ; p©esmykaá nen° stisknut
ediup8:                                   ;* proveden° rolov†n°
         mov       si,cs:[firstrad]         ; adresa prvn°ho ©†dku
         call      edispre                  ; nalezen° p©edchoz°ho ©†dku
         jc        ediup3                   ; nen° jië dal®° ©†dek
         dec       bh                       ; p©°znak rolov†n° dolñ
         cmp       bh,80h
         jne       ediup2
         inc       bh
ediup2:  mov       cs:[firstrad],si         ; novò prvn° ©†dek
         inc       byte ptr cs:[edidrad]    ; n†vrat ©†dku na displeji
ediup3:  clc
ediup6:  pop       si
         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   edidown

edidown:                                  ;* posun kurzoru dolñ
                                            ; VùSTUP: CY=nen° posun

         push      ax
         push      dx
         push      si
                                          ;* nastaven° na dal®° ©†dek
         mov       si,cs:[adrradek]         ; adresa ©†dku s kurzorem
         call      edisnxt0                 ; nalezen° dal®°ho ©†dku
         jc        edidown6                 ; nen° jië dal®° ©†dek
         mov       cs:[adrradek],si         ; nastaven° novÇ adresy ©†dku
         inc       word ptr cs:[ediradek]   ; zvò®en° á°sla ©†dku
         call      edinorm                  ; normalizace kurzoru
                                          ;* zvò®en° ©†dku na displeji
         call      getdispl
         mov       al,cs:[edidrad]          ; ©†dek na displeji
         inc       al                       ; zvò®en° ©†dku na displeji
         mov       cs:[edidrad],al          ; ©†dek na displeji
         cmp       al,dh                    ; p©ekroáen konec obrazovky ?
         ja        edidown8                 ; p©ekroáen konec obrazovky - rol.
                                          ;* rolov†n° p©i SHIFT ?
         call      testshft                 ; je stisknut p©esmykaá SHIFT ?
         jz        edidown3                 ; p©esmykaá nen° stisknut
edidown8:                                 ;* proveden° rolov†n°
         mov       si,cs:[endrad]           ; adresa posledn°ho ©†dku
         call      edisnxt0                 ; nalezen° dal®°ho ©†dku
         jc        edidown3                 ; nen° dal®° ©†dek - nen° rolov†n°
         mov       cs:[endrad],si           ; nastaven° novÇho posledn°ho ©†dku
         inc       bh
         cmp       bh,80h
         jne       edidown2
         dec       bh                       ; p©°znak rolov†n° nahoru
edidown2:mov       si,cs:[firstrad]         ; adresa prvn°ho ©†dku
         call      edisnxt0                 ; nalezen° dal®°ho ©†dku
         mov       cs:[firstrad],si         ; novò prvn° ©†dek
         dec       byte ptr cs:[edidrad]    ; n†vrat ©†dku na displeji
edidown3:clc
edidown6:pop       si
         pop       dx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   edichome

edichome:                                 ;* posun na horn° okraj ^HOME

         cmp       byte ptr cs:[edidrad],0  ; je jië horn° ©†dek ?
         je        edichm2                  ; je jië prvn° ©†dek
         call      ediup                    ; posun kurzoru nahoru
         jnc       edichome                 ; dal®° ©†dek
edichm2: ret


; -----------------------------------------------------------------------------
public   edicend

edicend:                                  ;* posun na doln° okraj ^END

         push      dx
         call      getdispl                 ; posledn° ©†dek
edicend1:cmp       byte ptr cs:[edidrad],dh ; je jië dosaëeno spodn°ho ©†dku ?
         jae       edicend2                 ; je jië spodn° ©†dek
         call      edidown                  ; posun o ©†dek dolñ
         jnc       edicend1                 ; dal®° ©†dek
edicend2:pop       dx
         ret

; -----------------------------------------------------------------------------
public   ediright

ediright:                                 ;* posun kurzoru vpravo
                                            ; VùSTUP: CY=nen° posun

         push      ax
         push      cx
         push      dx
         push      si
         push      ds
                                          ;* kontrola dosaëen° konce
         mov       ds,cs:[topseg]           ; segment s textem
         mov       si,cs:[edikurz]          ; adresa kurzoru v souboru
         mov       dx,cs:[edikpoz]          ; skuteán† pozice kurzoru na ©†dku
         cmp       si,cs:[editnum]          ; je jië konec souboru ?
         cmc
         jc        edirig6                  ; je jië konec souboru
                                          ;* zvò®en° pozice na ©†dku
         call      ediincp                  ; zvò®en° pozice na ©†dku
         jc        edirig3                  ; je konec ©†dku - novò ©†dek
         mov       cs:[edikpoz],dx          ; nov† pozice kurzoru
         mov       cs:[edikurz],si          ; nov† adresa kurzoru
                                          ;* posun podkladu
         or        bl,bl                    ; je  vyvol†n z vloëen° znaku ?
         jnz       edirig5                  ; je vyvol†n z vloëen° znaku
         call      testshft                 ; je stisknut p©esmykaá SHIFT ?
         jz        edirig5                  ; nen° stisknut p©esmykaá SHIFT
                                          ;* posun kurzoru o 16 znakñ
         add       word ptr cs:[toppoz],16  ; zvò®en° poá†tku ©†dku
         mov       cx,dx                    ; souáasn† pozice
         add       cx,15                    ; poëadovan† pozice
edirig2: cmp       dx,cx                    ; je jië dosaëeno pozice ?
         jae       edirig8                  ; pozice je jië dosaëeno
         call      ediincp                  ; zvò®en° pozice na ©†dku
         jnc       edirig2                  ; dal®° posun
edirig8: mov       cs:[edikpoz],dx          ; nov† pozice kurzoru
         mov       cs:[edikurz],si          ; nov† adresa kurzoru
         mov       bh,80h                   ; p©°znak p©ekreslen° obrazovky
         jmp       short edirig5
edirig3:                                  ;* posun na dal®° ©†dek
         call      edidown                  ; posun na dal®° ©†dek
         call      edihome                  ; nastaven° na zaá†tek ©†dku
edirig5: call      edikort                  ; korekce zaá†tku ©†dku
         call      edisetk                  ; uschov†n° pozice kurzoru
         clc
edirig6: pop       ds
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret



ediincp:                                  ;* zvò®en° pozice na ©†dku
                                            ; VSTUP: DS:SI=adresa v souboru
                                            ;        DX=pozice na ©†dku
                                            ; VùSTUP:DS:SI=nov† adresa v souboru
                                            ;        DX=nov† pozice na ©†dku
                                            ;        CY=konec souboru nebo ©†dku

         cmp       si,cs:[editnum]          ; je jië konec souboru ?
         jae       ediincp3                 ; je jië konec souboru
         test      byte ptr cs:[ediflag],40h ; je bin†rn° editace ?
         jz        ediincp1                 ; nen° bin†rn° editace
         cmp       dx,79
         jae       ediincp3                 ; je jië konec ©†dku
         inc       dx                       ; zvò®en° pozice
         jmp       short ediincp2
ediincp1:cmp       word ptr ds:[si],0a0dh   ; je konec ©†dku ?
         je        ediincp3                 ; je konec ©†dku - novò ©†dek
         inc       dx                       ; zvò®en° pozice na ©†dku
         cmp       byte ptr ds:[si],9       ; je tabel†tor ?
         jne       ediincp2                 ; nen° tabel†tor
         test      byte ptr cs:[ediflag],10h ; zobrazuj° se tabel†tory ?
         jnz       ediincp2                 ; tabel†tory se nezobrazuj°
         add       dx,7                     ; korekce pro zaokrouhlen°
         and       dx,not 7                 ; zaokrouhlen° pozice na tabel†tor
ediincp2:inc       si                       ; zvò®en° adresy kurzoru
         stc
ediincp3:cmc
         ret


edikort:                                  ;* korekce zaá†tku ©†dku
                                            ; VùSTUP: BH=80h p©ekreslen° disp.

         push      ax
         push      dx
         pushf
         mov       ax,cs:[edikpoz]          ; pozice kurzoru na ©†dku
         mov       dx,cs:[toppoz]           ; pozice zaá†tku ©†dku
                                          ;* kontrola p©ekroáen° zaá†tku
         cmp       ax,dx                    ; je kurzor pod zaá†tkem ?
         jb        edikort1                 ; kurzor je pod zaá†tkem
                                          ;* kontrola p©ekroáen° konce
         sub       ax,79                    ; minim†ln° zaá†tek ©†dku
         jb        edikort3                 ; kurzor nen° za koncem
         cmp       ax,dx                    ; je za koncem ©†dku ?
         jbe       edikort3                 ; nen° za koncem
         add       ax,15                    ; zaokrouhlen° nahoru
edikort1:and       ax,not 0fh               ; nastaven° na pozici tabel†toru
         mov       cs:[toppoz],ax           ; nastaven° novÇho zaá†tku ©†dku
edikort2:mov       bh,80h                   ; p©°znak p©ekreslen° displeje
edikort3:popf
         pop       dx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   edinorm

edinorm:                                  ;* normalizace EDIKURZ a TOPPOZ

                                          ;* nastaven° pozice na ©†dku
         push      ax
         push      si
         call      edigetk                  ; poskytnut° pozice kurzoru
         mov       cs:[edikurz],si          ; adresa kurzoru absolutnà
         mov       cs:[edikpoz],ax          ; pozice kurzoru na ©†dku
         call      edikort                  ; korekce zaá†tku ©†dku
         clc
         pop       si
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   edihome

edihome:                                  ;* kurzor na zaá†tek ©†dku HOME

         push      word ptr cs:[adrradek]
         pop       word ptr cs:[edikurz]
         mov       word ptr cs:[edikpoz],0  ; pozice kurzoru na ©†dku
edihome1:call      edikort                  ; korekce zaá†tku ©†dku
         call      edisetk                  ; uschov†n° pozice kurzoru
         ret


public   ediend

ediend:                                   ;* konec ©†dku END

         push      si
         push      bx
         mov       bx,-1                    ; hledan† pozice - konec
         mov       si,cs:[adrradek]         ; adresa ©†dku s kurzorem
         call      edigadr                  ; nalezen° pozice na ©†dku
         mov       cs:[edikurz],si          ; adresa kurzoru na ©†dku
         mov       cs:[edikpoz],bx          ; pozice kurzoru na ©†dku
         pop       bx
         pop       si
         jmp       short edihome1

; -----------------------------------------------------------------------------
public   edileft

edileft:                                  ;* posun kurzoru vlevo
                                            ; VùSTUP: CY=nen° posun

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      ds
                                          ;* kontrola dosaëen° konce
         mov       ds,cs:[topseg]           ; segment s textem
         mov       si,cs:[edikurz]          ; adresa kurzoru v souboru
         mov       dx,cs:[edikpoz]          ; skuteán† pozice kurzoru na ©†dku
         mov       di,cs:[adrradek]         ; adresa zaá†tku ©†dku
         or        si,si                    ; je jië zaá†tek souboru ?
         stc
         jz        edilft5                  ; je jië zaá†tek souboru
                                          ;* sn°ëen° pozice na ©†dku
         call      edidecp                  ; sn°ëen° pozice na ©†dku
         jc        edilft3                  ; byl zaá†tek ©†dku - dal®° ©†dek
         mov       cs:[edikpoz],dx          ; nov† pozice kurzoru
         mov       cs:[edikurz],si          ; nov† adresa kurzoru
                                          ;* posun podkladu
         or        bl,bl                    ; je  vyvol†n z vloëen° znaku ?
         jnz       edilft5                  ; je vyvol†n z vloëen° znaku
         call      testshft                 ; je stisknut p©esmykaá SHIFT ?
         jz        edilft5                  ; nen° stisknut p©esmykaá SHIFT
                                          ;* posun kurzoru o 8 znakñ
         cmp       word ptr cs:[toppoz],16  ; je poá†tek n°ëe neë 8 znakñ ?
         jb        edilft5                  ; je jië zaá†tek displeje
         sub       word ptr cs:[toppoz],16  ; sn°ëen° poá†tku ©†dku
         mov       cx,dx                    ; souáasn† pozice
         sub       cx,15                    ; poëadovan† pozice
         jnc       edilft2                  ; nen° podteáen°
         xor       cx,cx
edilft2: cmp       dx,cx                    ; je jië dosaëeno pozice ?
         jbe       edilft8                  ; pozice je jië dosaëeno
         call      edidecp                  ; sn°ëen° pozice na ©†dku
         jnc       edilft2                  ; dal®° posun
edilft8: mov       cs:[edikpoz],dx          ; nov† pozice kurzoru
         mov       cs:[edikurz],si          ; nov† adresa kurzoru
         mov       bh,80h
         jmp       short edilft5
edilft3:                                  ;* posun na p©edchoz° ©†dek
         call      ediup                    ; posun o ©†dek vò®e
         call      ediend                   ; nastaven° na konec ©†dku
edilft5: call      edikort                  ; korekce zaá†tku ©†dku
         call      edisetk                  ; uschov†n° pozice kurzoru
         clc
edilft6: pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret


edidecp:                                  ;* sn°ëen° pozice na ©†dku
                                            ; VSTUP: DS:SI=adresa v souboru
                                            ;        DX=pozice na ©†dku
                                            ;        DI=adresa zaá†tku ©†dku
                                            ; VùSTUP:DS:SI=nov† adresa v souboru
                                            ;        DX=nov† pozice na ©†dku
                                            ;        CY=zaáatek souboru, ©†dku

         or        si,si                    ; je jië zaá†tek souboru ?
         jz        edidecp3                 ; je jië zaá†tek souboru
         or        dx,dx                    ; je jië zaá†tek ©†dku ?
         jz        edidecp3                 ; je jië zaá†tek ©†dku
edidecp1:dec       dx                       ; sn°ëen° pozice na ©†dku
         dec       si                       ; sn°ëen° adresy kurzoru
         cmp       byte ptr ds:[si],9       ; je tabel†tor ?
         jne       edidecp2                 ; nen° tabel†tor
         test      byte ptr cs:[ediflag],10h ; zobrazuj° se tabel†tory ?
         jnz       edidecp2                 ; tabel†tory se nezobrazuj°
                                          ;* nalezen° pozice pro tabel†tor
         push      ax
         push      bx
         push      si
         mov       ax,si                    ; nov† adresa kurzoru
         mov       si,di                    ; adresa zaá†tku ©†dku
         call      findpoz                  ; nalezen° novÇ pozice tabel†toru
         mov       dx,bx                    ; nov† pozice kurzoru
         pop       si
         pop       bx
         pop       ax
edidecp2:stc
edidecp3:cmc
         ret

; -----------------------------------------------------------------------------
public   editobrk

editobrk:                                 ;* zobrazen° kurzoru
         push      ax
         push      dx
         mov       dx,cs:[edikpoz]          ; skuteán† pozice kurzoru na ©†dku
         sub       dx,cs:[toppoz]           ; vòpoáet pozice na displeji
         mov       dh,cs:[edidrad]          ; ©†dek s kurzorem na displeji
         xor       al,al
         call      outch1                   ; nastaven° pozice kurzoru
         pop       dx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   editall

editall:                                  ;* zobrazen° ©†dkñ okna (normalizace)
                                            ; VSTUP: BH=poáet ©†dkñ k rolov†n°

         push      ax
         push      si
         push      cx
         push      dx

         mov       si,cs:[firstrad]         ; adresa prvn°ho ©†dku
         xor       dh,dh                    ; adresa prvn°ho ©†dku na displeji

         call      getdispcx                ; poáet ©†dkñ
         inc       cx

         or        bh,bh                    ; jsou ©†dkovÇ zmàny ?
         jz        editall3                 ; nejsou ©†dkovÇ zmàny
         jns       editall4                 ; je rolov†n° nahoru

editall7:                                 ;* rolov†n° dolñ
         mov       al,bh                    ; poáet ©†dkñ k rolov†n°
         neg       al
         cmp       al,10                    ; je vàt®° poáet ©†dkñ neë 10 ?
         jae       edital71                 ; je velkò poáet ©†dkñ
         mov       ah,7                     ; funkce rolov†n° dolñ
         call      ediroll                  ; rolov†n° obrazovky dolñ
edital71:cbw                                ; AX <- AL
         cmp       ax,10                    ; je velkò poáet ©†dkñ ?
         jb        edital72                 ; nen° velkò poáet ©†dkñ
         mov       ax,cx                    ; omezen° poátu ©†dkñ
edital72:sub       cx,ax                    ; zbylò poáet ©†dkñ
         push      cx                       ; poáet zbylòch ©†dkñ
         mov       cx,ax                    ; poáet novòch ©†dkñ
editall8:mov       cs:[endrad],si           ; nastaven° adresy posledn°ho ©†dku
         call      editline                 ; zobrazen° jednoho ©†dku
         call      edisnxt                  ; nalezen° zaá†tku dal®°ho ©†dku
         inc       dh                       ; zvò®en° ©†dku na displeji
         loop      editall8
         pop       cx                       ; poáet zbylòch ©†dkñ
         jcxz      editall5                 ; nezbòv† ë†dnò ©†dek
edital81:mov       cs:[endrad],si           ; nastaven° adresy posledn°ho ©†dku
         call      edisnxt0                 ; nalezen° dal®°ho ©†dku
         loop      edital81
         jmp       short editall5

editall4:                                 ;* rolov†n° nahoru
         mov       al,bh                    ; poáet ©†dkñ k rolov†n°
         cmp       al,10
         jae       edital43                 ; je velkò poáet ©†dkñ
         mov       ah,6                     ; funkce rolov†n° nahoru
         call      ediroll                  ; rolov†n° obrazovky nahoru
edital43:cbw                                ; AX <- AL
         cmp       ax,10                    ; je vàt®° poáet ©†dkñ ?
         jb        edital42                 ; nen° velkò poáet ©†dkñ
         mov       ax,cx                    ; omezen° poátu ©†dkñ
edital42:sub       cx,ax                    ; zbylò poáet ©†dkñ
         jz        edital92                 ; nezbyl ë†dnò ©†dek
edital91:call      edisnxt0                 ; nalezen° dal®°ho ©†dku
         inc       dh                       ; zvò®en° ©†dku na displeji
         loop      edital91                 ; nalezen° adresy ©†dku
edital92:mov       cx,ax                    ; poáet novòch ©†dkñ
editall9:mov       cs:[endrad],si           ; nastaven° adresy posledn°ho ©†dku
         call      editline                 ; zobrazen° jednoho ©†dku
         call      edisnxt                  ; nalezen° dal®°ho ©†dku
         inc       dh                       ; zvò®en° ©†dku na displeji
         loop      editall9
editall5:xor       bx,bx                    ; p©°znak - zmàny zobrazeny
editall3:pop       dx
         pop       cx
         pop       si
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   ediroll

ediroll:                                  ;* rolov†n° obrazovky
                                            ; VSTUP: AH=6 - rolov†n° nahoru
                                            ;           7 - rolov†n° dolñ
                                            ;        AL=poáet ©†dek k rolov†n°

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es
         xor       cx,cx                    ; pozice levÇho horn°ho rohu
         call      getdispl                 ; posledn° ©†dek
         inc       dh
         mov       dl,79
         mov       bh,cs:[col1]             ; atributy pro barvu 1
         int       10h                      ; rolov†n° obrazovky
         pop       es
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
public   editline

editline:                                 ;* zobrazen° jednoho ©†dku
                                            ; VSTUP: SI=zaá†tek ©†dku
                                            ;        DH=©†dek na displeji
                                            ; VùSTUP: SI=adresa konce zobrazen°

         push      ax
         push      cx
         push      dx
         push      di
         push      ds

         call      edigtop                  ; nalezen° zaá†tku ©†dku pro zobraz.
         xor       dl,dl                    ; poá†teán° pozice pro zobrazen°
                                          ;* zobrazen° ©†dku od adresy DS:SI
         mov       ds,cs:[topseg]           ; segment bufferu s textem
         mov       cx,80                    ; poáet znakñ na ©†dek
editlin2:cmp       si,cs:[editnum]          ; dosaëeno konce textu ?
         jae       editlin4                 ; dosaëeno konce textu
         cmp       word ptr ds:[si],0a0dh   ; je konec ©†dku ?
         je        editlin4                 ; konec ©†dku
editln22:                                 ;* nastaven° barvy zobrazen° znaku
         cmp       byte ptr ds:[si]," "     ; je ©°dic° znak ?
         mov       al,1                     ; barva textu
         jae       editln12                 ; nen° ©°dic° znak
         mov       al,15                    ; barva pro ©°dic° znak
editln12:
editlin1:call      outch1                   ; nastaven° barvy podkladu

         lodsb                              ; naáten° znaku k zobrazen°
         cmp       al,32                    ; je ©°dic° znak ?
         jae       editlin3                 ; nen° ©°dic° znak - zobrazen°
         cmp       al,9                     ; je tabel†tor ?
         jne       editlin5                 ; nen° tabel†tor
                                          ;* zobrazen° tabel†toru
         mov       al," "                   ; n†hradn° znak
editlin7:call      outch1                   ; zobrazen° znaku
         dec       cx                       ; sn°ëen° á°taáe
         jcxz      editlin8                 ; konec ©†dku
         test      dl,7                     ; je pozice tabel†toru ?
         jnz       editlin7                 ; dal®° znak
         jmp       short editlin2           ; dal®° znak
                                          ;* zobrazen° ©°dic°ho znaku
editlin5:
                                          ;* zobrazen° norm†ln°ho znaku
editlin3:or        al,al                    ; je znak 00 ?
         jnz       editlina                 ; nen° znak 00
         mov       al,"."                   ; n†hradn° znak
editlina:call      outch10                  ; zobrazen° znaku
editlin6:loop      editlin2                 ; dal®° znak k zobrazen°
                                          ;* vymazan° zbytku ©†dku (CX znakñ)
editlin4:
         mov       al,1                     ; barva textu
editlin0:call      outch1                   ; nastaven° barvy podkladu
         mov       al," "
         call      outch                    ; vymaz†n° zbytku ©†dku
editlin8:pop       ds
         pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   edispre

edispre:                                  ;* nalezen° p©edchoz°ho ©†dku
                                            ; VSTUP: SI=zaá†tek ©†dku
                                            ; VùSTUP: SI=zaá†tek p©edch. ©†dku
                                            ;         CY=nen° dal®° ©†dek
         push      ax
         push      ds

         mov       ds,cs:[topseg]
         or        si,si                    ; je jië zaá†tek textu ?
         stc                                ; p©°znak chyby
         jz        edispre3                 ; nen° dal®° ©†dek

edispre2:or        si,si                    ; je zaá†tek textu ?
         jz        edispre3                 ; je zaá†tek textu
         dec       si                       ; sn°ëen° pozice v bufferu
         cmp       si,2
         jb        edispre2
         cmp       word ptr ds:[si-2],0a0dh ; je zaá†tek ©†dku ?
         jne       edispre2                 ; nen° je®tà zaá†tek ©†dku
edispre3:pop       ds
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   edisnxt0

edisnxt0:                                 ;* nalezen° dal®°ho ©†dku z poá†tku
                                            ; VSTUP: SI=zaá†tek ©†dku
                                            ; VùSTUP: SI=zaá†tek dal®°ho ©†dku
                                            ;         CY=nen° dal®° ©†dek


;         call      edittbin                 ; je bin†rn° editace ?
;         jz        edisnxt                  ; nen° bin†rn° editace
;         add       si,80                    ; zvò®en° adresy ©†dku
;         jc        edisnxt1                 ; je konec bufferu
;         cmp       cs:[editnum],si          ; je jië konec souboru ?
;         ja        edisnxt4                 ; nen° konec souboru
;edisnxt1:mov       si,cs:[editnum]
;         dec       si
;         stc
;edisnxt4:ret
;

public   edisnxt

edisnxt:                                  ;* nalezen° dal®°ho ©†dku
                                            ; VSTUP: SI=pozice v textu
                                            ; VùSTUP: SI=zaá†tek dal®°ho ©†dku
                                            ;         CY=nen° dal®° ©†dek
         push      ax
         push      ds
         mov       ds,cs:[topseg]
         mov       ax,cs:[editnum]          ; poáet znakñ v bufferu
edisnxt2:cmp       si,ax                    ; je jië dosaëeno konce ?
         cmc                                ; negace p©°znaku CF
         jb        edisnxt3                 ; dosaëeno konce
         inc       si                       ; zvò®en° adresy v bufferu
         cmp       word ptr ds:[si-1],0a0dh ; je konec ©†dku ?
         jne       edisnxt2                 ; nenalezen konec ©†dku
         inc       si                       ; nastaven° zaá†tku dal®°ho ©†dku
edisnxt3:pop       ds
         pop       ax
         ret

; -----------------------------------------------------------------------------
;public   edittop0,edittop
;
;edittop0:                                 ;* poá†teán° zobrazen° horn°ho ©†dku
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
;         pop       ds
;         push      cs
;         pop       es
;
;
;         mov       al,3                     ; barva 3
;         call      outch1                   ; nastaven° barvy
;                                          ;* vymaz†n° horn°ho ©†dku
;         xor       dx,dx                    ; poá†teán° pozice
;         mov       al," "                   ; mazac° znak
;         mov       cx,80                    ; poáet znakñ k tisku
;         call      outch                    ; vymaz†n° ©†dku
;                                          ;* zobrazen° oddàlovaáñ pol°
;;         mov       al,179                   ; oddàlovaá pole
;;         mov       dx,2
;;         call      outch1
;;         mov       dl,15
;;         call      outch1
;;         mov       dl,70
;;         call      outch1
;;         mov       dl,79
;;         call      outch1
;;                                          ;* zobrazen° jmÇna souboru
;;         call      getakt                   ; poskytnut° aktivn°ho okna
;;         mov       si,ds:[bp+4]             ; adresa p©°stupovÇ cesty
;;         lodsw                              ; naáten° disku a oddàlovaáe ":"
;         mov       dx,3                     ; pozice pro zobrazen° souboru
;;         call      outch1                   ; zobrazen° jmÇna disku
;;         mov       al,ah
;;         call      outch1                   ; zobrazen° oddàlovaáe ":"
;         lea       si,[buffedi]              ; uschovanÇ jmÇno souboru
;;         call      getkurz                  ; poskytnut° editovanÇho souboru
;;         lea       di,[outbuf]              ; pracovn° buffer
;;         push      di
;;         call      dekfile                  ; dek¢dov†n° jmÇna souboru
;;         pop       si
;;         push      cs
;;         pop       ds
;         call      outtxt                   ; zobrazen° jmÇna souboru
;;         jmp       short edittop1
;
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
;
;                                          ;* pokraáuje dal®° zobrazen°
;
;edittop:                                  ;* zobrazen° horn°ho ©†dku
;         ret
;
; -----------------------------------------------------------------------------
public   aktedipoz

aktedipoz:                                ;* aktualizace pozice na ©†dku

         push      ax
         push      si
         call      edigetk                  ; poskytnut° pozice kurzoru
         mov       cs:[edipoz],ax           ; nastaven° pozice kurzoru
         pop       si
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   edigkurz

edigkurz:                                 ;* poskytnut° adresy kurzoru DS:SI
                                            ; VùSTUP: DS:SI=adresa kurzoru

         mov       si,cs:[edikurz]          ; adresa kurzoru v bufferu
         mov       ds,cs:[topseg]           ; segment bufferu
         ret

; -----------------------------------------------------------------------------
public   edisetk

edisetk:                                  ;* aktualizace pozice kurzoru na ©†dku

         push      word ptr cs:[edikpoz]    ; skuteán† pozice kurzoru na ©†dku
         pop       word ptr cs:[edipoz]     ; £schova novÇ pozice kurzoru
         ret

; -----------------------------------------------------------------------------
public   edigetk,edigetk0

edigetk0:                                 ;* poskytnut° konce ©†dku s kurzorem
                                            ; VùSTUP: AX=pozice kurzoru
                                            ;         SI=adresa kurzoru v pamàti
                                            ;         CY=pozice byla zkr†cena

         push      bx
         mov       bx,-1                    ; p©ednastaven° pozice kurzoru
         jmp       short edigetk1           ; zji®tàn° pozice kurzoru

edigetk:                                  ;* poskytnut° pozice kurzoru na ©†dku
                                            ; VùSTUP: AX=pozice kurzoru
                                            ;         SI=adresa kurzoru v pamàti
                                            ;         CY=pozice byla zkr†cena

         push      bx
         mov       bx,cs:[edipoz]           ; pozice kurzoru na ©†dku
edigetk1:mov       si,cs:[adrradek]         ; adresa ©†dku s kurzorem
         call      edigadr                  ; poskytnut° adresy a pozice
         mov       ax,bx                    ; pozice kurzoru na ©†dku
         pop       bx
         ret

; -----------------------------------------------------------------------------
public   edigtop
edigtop:                                  ;* poskytnut° adresy zaá†tku ©†dku
                                            ; VSTUP: SI=adresa ©†dku
                                            ; VùSTUP: SI=adresa zaá†tku ©†dku
                                            ;         CY=zaá†tek za koncem ©†dku

         push      bx
         mov       bx,cs:[toppoz]           ; offset poá†teán° pozice ©†dku rel.
         call      edigadr                  ; nalezen° adresy v ©†dku
         pop       bx
         ret


public   edigadr
edigadr:                                  ;* nalezen° adresy v ©†dku
                                            ; VSTUP: SI=adresa ©†dku
                                            ;        BX=hledan† pozice
                                            ; VùSTUP: SI=adresa pozice
                                            ;         BX=nov† pozice na ©†dku
                                            ;         CY=pozice za koncem ©†dku

         push      dx
         push      ds
         mov       ds,cs:[topseg]           ; segment bufferu
         xor       dx,dx                    ; relativn° á°taá pozice na ©†dku
edigadr1:cmp       dx,bx                    ; je jië dosaëeno hledanÇ pozice ?
         jae       edigadr2                 ; hledanÇ pozice je jië dosaëeno
         call      ediincp                  ; zvò®en° pozice na ©†dku
         jnc       edigadr1                 ; nen° konec - dal®° pozice
edigadr2:mov       bx,dx                    ; korigovan† pozice
         pop       ds
         pop       dx
         ret

; -----------------------------------------------------------------------------

code     ends

         end


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
extrn    erroper:byte,inpkey:near,citachod:byte,col1:byte,col3:byte
extrn    outid:word,editnum:word,dekfile:near,getakt:near
extrn    color:byte,tisknm0:near,outtxt:near,outch1:near
extrn    windret:near,deknum5:near,txtedi1:byte,parnum:byte
extrn    txtedi2:byte,txtedi3:byte,ediradek:word,edipoz:word
extrn    txtedi4:byte,ediflag:byte,deknum3:near,outch:near
extrn    parint:byte,edikurz:word,edidrad:byte,testakth:near
extrn    outhelp:near,outch10:near,adrradek:word,outedhlp:near
extrn    firstrad:word,endrad:word,toppoz:word,delkarad:word
extrn    skokax:near,txtedi5:byte,txtedi6:byte,testshft:near
extrn    testchar:near,testkey:near,edinormk:word,aktpage:byte
extrn    edikey:word,volbyh:near,erredi2:byte,txtchyb1:byte
extrn    ediblkb:word,ediblkk:word
extrn    outthlp:near,flags:byte,txthlped:byte,transtxt:near
extrn    bufhlde:word,bufhlde1:byte,bufhlde2:byte,txtedi7:byte
extrn    highcase:near,select:near,lensi:near,findstr:byte
extrn    erredi3:byte,erredi4:byte,edivolb2:byte,txtedi8:byte
extrn    erredi5:byte,readdir:near,topret:near,getnakt:near
extrn    delpol:near,modikap:near,cmpdisk:near,cmppath:near
extrn    bufwin:byte,creatfile:near,storfile:near
extrn    ediznac:word,msgcek:near,kurzout:near,help:near,althelp:near
extrn    inpkeyf:near,txtedis:byte,bufcopy:byte,bufcop1:byte,bufcop2:byte
extrn    setkurz:near,storfile:near,hledpol:near,rozbset:byte
extrn    diskfail:near,rozbnam:byte,namel:byte,tabr:byte,namer:byte
extrn    firstwl:word,firstwr:word,settabf:near,testaktw:near
extrn    tabhlped:word,selbuf:byte,windretx:near
extrn    rozbflg:byte,rozbvel:dword,nuldir:byte,loadpath:near
extrn    mouseon:near,mouseoff:near,mouseget:near,mousemen:near
extrn    modihlp:near,mousepoz:word,erredi6:byte,edikpoz:word
extrn    testbreak:near,parbreak:word,txtedi9:byte,txtedia:byte
extrn    buffedi:byte,storekall:near,bufcop3:word,config:byte
extrn    conf2:byte,txtedib:byte,insmouse:byte,edivolb3:byte
extrn    txtedif1:byte,lowcase:near,prevcs:byte,txtedif2:byte
extrn    edivolb4:byte,rerdir:near,getpocl:near,getdispl:near
extrn    getendl:near,displ:byte,egaset:near,conf4:byte,replstr:byte
extrn    bufparh:word,bufparh1:byte,bufparh2:byte
extrn    txtedic:byte,txtedid:byte,txtedie:byte,lensi0:near
extrn    txtedif:byte,window1:near,conf5:byte,bufhlde3:word
extrn    aktokna:near,testdev:near,citacexp:byte
extrn    storefile:near,rozbor:near,usesedit:near,hledpol0:near
extrn    txtedig:byte

public   editors,editorex

editors:                                  ;* editace zadanÇho souboru SHIFT-F4

         lea       di,[txtedis]             ; nadpis "zadejte jmÇno souboru ..."
         call      editzadf                 ; vstup zad†n° jmÇna souboru
         jc        edits1                   ; p©eru®en° operace
editorex:lea       di,[bufwin]
         mov       dx,di
         call      transtxt
         jnc       edits2                   ; operace OK
edits1:  call      windretx                 ; navr†cen° oken p©i p©eru®en°
edits11: ret

edits1er:                                 ;* chyba zad†n° souboru
         call      windret
         lea       si,[erredi6]             ; chyba "chyba zad†n° souboru"
         call      zobrchyb                 ; zobrazen° chybovÇho hl†®en°
         jmp       short edits1


public   editor

editor:                                   ;* editace souboru F4
         call      testaktw
         jc        edits11                  ; okno nen° zapnuto
         call      getkurz                  ; poskytnut° adresy kurzoru
         test      byte ptr ds:[si],10h     ; je to adres†© ?
         jnz       edits11                  ; je to adres†© - konec
         lea       di,[bufwin]              ; pracovn° buffer
         mov       dx,di                    ; zadanò soubor
         call      dekfile                  ; dek¢dov†n° jmÇna souboru

edits2:                                   ;* editace souboru DX
         push      cs
         pop       ds                       ; DS <- CS
         call      storekall                ; £schova pozic kurzorñ
         call      aktokna                  ; aktualizace historie oken
         call      msgcek                   ; hl†®en° "áekejte"
         mov       si,ds:[bp+4]             ; adresa cesty k adres†©i
         call      aktdir                   ; nastaven° aktivn°ho adres†©e
         jc        edits1                   ; chyba nastaven° adres†©e
         mov       ah,4eh
         mov       cx,16h                   ; atributy - v®echny soubory
         int       21h                      ; nalezen° souboru
         jnc       edits4                   ; soubor jië existuje
                                          ;* vytvo©en° souboru
ifndef   demo
         call      editmodi                 ; modifikace adres†©ñ
         mov       ah,3ch                   ; vytvo©en° souboru
         xor       cx,cx                    ; norm†ln° atributy
         int       21h                      ; vytvo©en° souboru
         mov       bx,ax                    ; identifik†tor novÇho souboru
         mov       ah,3eh
         int       21h                      ; uzav©en° souboru
endif
edits4:                                   ;* nastaven° volnÇ pamàti
         mov       ax,ds:[segend]           ; segment konce pamàti
         sub       ax,2                     ; rezerva
         sub       ax,ds:[topseg]           ; voln† pamàü
         jbe       edits1                   ; pamàü nedostaáuje
         cmp       ax,1000h                 ; je vàt®° neë 64 KB ?
         jb        editor1                  ; nen° vàt®° neë 64 KB
         mov       ax,1000h                 ; omezen° na 64 KB
editor1: mov       cl,4
         shl       ax,cl                    ; voln† kapacita (v bajtech)
         or        ax,ax
         jnz       editor12
         dec       ax                       ; 64 KB
editor12:mov       ds:[editmax],ax          ; £schova velikosti bufferu

                                          ;* nastaven° ukazatelñ a indik†torñ
         and       byte ptr ds:[ediflag],01110000b ; zru®en° p©°znakñ
         or        byte ptr ds:[parint],20h ; nastaven° p©°znaku editace F4

                                          ;* naáten° zadanÇho souboru do pamàti
         lea       dx,[bufwin]              ; editovanò soubor
         call      editread                 ; áten° souboru do pamàti
         jc        editor8                  ; chyba - operaci nelze provÇst
         mov       si,9eh                   ; jmÇno souboru
                                          ;* £schova jmÇna souboru
         push      si
         push      bx
         call      rozbor                   ; dek¢dov†n° jmÇna souboru
         mov       si,offset rozbset
         call      hledpol0                 ; nalezen° poloëky
         jc        editor2s                 ; soubor nenalezen
         mov       ds:[bp+11],bx            ; nastaven° pozice kurzoru
editor2s:call      storefile                ; uloëen° jmÇna souboru
         pop       bx
         pop       si

         lea       di,[buffedi]             ; buffer k uloëen° jmÇna
         call      transtxt                 ; p©enos jmÇna souboru

         call      edited                   ; editace souboru

editor8: and       byte ptr ds:[parint],not 20h ; zru®en° p©°znaku F4
         mov       word ptr ds:[editnum],0  ; zru®en° dat v pamàti
         and       byte ptr cs:[config],not 10h ; zru®en° p©°znaku naáten°
         mov       byte ptr cs:[citacexp],8 ; nastaven° á°taáe
         push      bp
         call      getakt
         call      window1
         xor       ax,ax
         call      usesedit                 ; normalizace
         call      getnakt
         call      window1
         call      outhelp
         pop       bp
         call      windretx                 ; navr†cen° obsahu oken
         ret


public   editzadf
editzadf:                                 ;* zad†n° jmÇna souboru (nadpis DI)
         lea       si,[bufcopy]             ; buffer poloëek
         lea       ax,[bufcop2]             ; konec bufferu
         sub       ax,offset bufcop1        ; dÇlka bufferu
         mov       ds:[si],ax               ; dÇlka bufferu
         mov       byte ptr ds:[bufcop2],1  ; 1 p©edvolba
         mov       word ptr ds:[bufcop3],offset buffedi ; editovanò soubor
         call      select                   ; volba souboru
         call      outedhlp                 ; zobrazen° n†povàdy editoru
         ret


public   editmodi
editmodi:                                 ;* modifikace adres†©ñ
         push      bp
;         call      storekall                ; uloëen° obou kurzorñ
         call      rerdir                   ; p©°znak novÇho naáten° adres†©e
;         and       byte ptr ds:[bp+0],not 2 ; zru®en° p©°znaku naáten° adres†©e
;         or        byte ptr ds:[bp+0],4     ; p©°znak, ëe se adres†© nenuluje
         mov       bp,ds:[bp+1]             ; adresa protàj®°ho okna
         call      rerdir                   ; p©°znak novÇho naáten° adres†©e
;         and       byte ptr ds:[bp+0],not 2 ; zru®en° p©°znaku naáten° adres†©e
;         or        byte ptr ds:[bp+0],4     ; p©°znak, ëe se adres†© nenuluje
         pop       bp
         ret

; -----------------------------------------------------------------------------
public   edited

edited:                                   ;* editace textu v pamàti

         mov       word ptr ds:[edikey],0   ; zru®en° znaku z bufferu kl†ves
;         mov       byte ptr ds:[citachod],0 ; nastaven° hodin
         mov       ah,3                     ; funkce poskytnut° kurzoru
         mov       bh,ds:[aktpage]          ; pracovn° videostr†nka
         int       10h                      ; poskytnut° kurzoru
         mov       ds:[edinormk],cx         ; £schova vzhledu kurzoru
;         call      edicpgup                 ; nastaven° na zaá†tek souboru
         mov       bx,8000h                 ; p©°znak - p©epsat v®echny ©†dky
         call      outedhlp                 ; zobrazen° n†povàdy editoru
         call      edittop0                 ; poá†teán° zobrazen° inform. ©†dku
;         call      edithlp0                 ; zobrazen° n†povàdy
edited0:                                  ;* zaá†tek obsluhy jednÇ kl†vesy
         push      cs
         pop       ds
         push      cs
         pop       es
;         call      getendl                  ; posledn° ©†dek
;         cmp       dh,ds:[edidrad]          ; je ©†dek s kurzorem OK ?
;         jae       edited04                 ; ©†dek je OK
;         call      ediup                    ; posun o ©†dek nahoru
edited04:call      editall                  ; zobrazen° v®ech ©†dkñ obrazovky
         or        bl,bl                    ; m† se p©epsat ©†dek ?
         jz        edited1                  ; nep©episuje se ©†dek
         mov       si,cs:[adrradek]         ; adresa ©†dku s kurzorem
         mov       dh,cs:[edidrad]          ; ©†dek na displeji
         call      editline                 ; zobrazen° ©†dku
edited1:
         call      edittop                  ; zobrazen° horn°ho ©†dku
         call      editobrk                 ; zobrazen° kurzoru
         call      inpkeye                  ; vstup znaku pro editor
         mov       word ptr ds:[parbreak],0 ; zru®en° p©°znaku chyby

         call      resshft                  ; zru®en° nucenÇho p©°znaku SHIFT
         test      byte ptr cs:[ediflag],82h ; byl prefix ^K nebo ^Q ?
         jz        edited32                 ; nebyl prefix ^K ani ^Q
         call      highcase                 ; p©evod na velkÇ p°smeno
         cmp       al,32                    ; je znak s CTRL ?
         jnb       edited31                 ; nen° znak s CTRL
         add       al,"@"                   ; korekce na znak ASCII
edited31:lea       bx,[skokediq]            ; tabulka skokñ editoru pro ^Q
         cmp       al,"0"
         jb        edited33
         cmp       al,"9"
         ja        edited33
         mov       cl,al
         sub       cl,"0"-1
         mov       al,1
edited33:test      byte ptr cs:[ediflag],2  ; byl prefix ^Q ?
         jnz       edited34                 ; byl prefix ^Q
                                          ;* je prefix ^K
         cmp       al,"D"                   ; je ukonáen° ^KD ?
         je        edited7                  ; je ukonáen° editoru ^KD
         cmp       al,"Q"                   ; je p©eru®en° ^KQ ?
         je        edited6                  ; je p©eru®en° editace ^KQ
         lea       bx,[skokedik]            ; tabulka skokñ editoru pro ^K
edited34:call      skokax                   ; skok do obsluhy
edited36:and       byte ptr cs:[ediflag],not 82h ; zru®en° p©°znakñ prefixñ
edited35:jmp       short edited0
                                          ;* nebyl znak s prefixem
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
         je        edited6                  ; je p©eru®en° editace <ESC>, ^KQ
         cmp       ah,44h                   ; je konec F10 ?
         je        edited7                  ; konec F10 - uloëen° souboru
         cmp       ah,71h                   ; je p©eru®en° Alt-F10 ?
         je        edited6                  ; je p©eru®en° Alt-F10
         lea       bx,[skokedi]             ; tabulka skokñ editoru
         call      skokax                   ; skok do obsluhy
         jmp       short edited35           ; vstup dal®°ho znaku

edited6:                                  ;* p©eru®en° editace Esc, ^KQ
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

         test      byte ptr ds:[ediflag],4  ; je p©°znak INSERT ?
         jz        edited85                 ; kurzor je OK
         call      ediins                   ; zmàna kurzoru
edited85:                                 ;* uzav©en° souboru
         ret



inpkeyea:ret

public   inpkeye
inpkeye:                                  ;* vstup znaku pro editor
         call      mouseget                 ; vstup znaku z my®i
         jnz       inpkeyed
inpkeyee:jmp       inpkeye6                 ; nen° ë†dnÇ tlaá°tko
inpkeyed:call      mousemen                 ; test funkán° kl†vesy
         jnc       inpkeyea                 ; byla funkán° kl†vesa
                                          ;* oznaáen° zaá†tku bloku pravòm tlaá.
         cmp       bl,5                     ; je stisk pravÇho tlaá°tka ?
         jne       inpkeye0                 ; nen° pravÇ tlaá°tko
         and       byte ptr cs:[insmouse],11111001b ; zru®en° p©°znakñ oznaáen°
inpkeye0:                                 ;* nastaven° na pozici
         call      getpocl                  ; poáet ©†dkñ bez n†povàdy
;         call      getendl                  ; á°slo posledn°ho ©†dku
;         mov       cl,dh
         mov       dx,cs:[mousepoz]         ; pozice my®i
         mov       ax,5000h                 ; kurzor dolñ
         cmp       dh,cl                    ; je spodn° ©†dek ?
         je        inpkeyea                 ; je rolov†n°
         ja        inpkeyee                 ; je n†povàda - p©eskoá° se
         cmp       dh,cs:[edidrad]          ; souhlas° ©†dek ?
         ja        inpkeyea                 ; je nad kurzorem
         mov       ax,4800h
         jb        inpkeyea
         mov       ax,4b00h                 ; kurzor vlevo
         cmp       word ptr cs:[toppoz],0   ; je zobrazen zaá†tek ?
         je        inpkeye2                 ; je jië zaá†tek ©†dku
         or        dl,dl
         jz        inpkeyea
inpkeye2:mov       cx,cs:[edikpoz]
         sub       cx,cs:[toppoz]
         cmp       dl,cl                    ; je men®° pozice ?
         jb        inpkeyea
         mov       ax,4d00h                 ; kurzor vpravo
         je        inpkeye5                 ; pozice je dosaëeno
         push      ds
         call      edigkurz                 ; poskytnut° adresy kurzoru
         cmp       word ptr ds:[si],0a0dh   ; je jië konec ©†dku ?
         pop       ds
;         je        inpkeye6                 ; je jië konec ©†dku
         jne       inpkeye9
inpkeye5:                                 ;* pozice dosaëeno
         cmp       dl,79                    ; je posledn° pozice ?
         je        inpkeye9                 ; je plynulò posun
         cmp       bl,2                     ; drë° se pravÇ tlaá°tko ?
         jne       inpkeye6                 ; nedrë° se
         test      byte ptr cs:[insmouse],2 ; bylo jië prvn° nastaven° ?
         jnz       inpkeyeb                 ; bylo jië prvn° nastaven°
         or        byte ptr cs:[insmouse],2 ; p©°znak, ëe bylo prvn° nastaven°
         call      ediznacb                 ; nastaven° zaá†tku bloku
         mov       ax,3e00h                 ; kl†vesa F4 - konec bloku
         ret
inpkeyeb:mov       cx,cs:[edikurz]          ; adresa kurzoru
         test      byte ptr cs:[insmouse],4 ; je pevnò konec ?
         jnz       inpkeye7                 ; je pevnò konec
inpkeyec:                                 ;* je pevnò zaá†tek
         mov       ax,3e00h                 ; kl†vesa F4 = oznaáen° konec
         cmp       cx,cs:[ediblkk]          ; je jië konce dosaëeno ?
         je        inpkeye6                 ; konce je jië dosaëeno
         cmp       cx,cs:[ediblkb]          ; je za zaá†tkem ?
         jae       inpkeye9                 ; je za zaá†tkem - OK
         call      xchgblok                 ; z†màna znaáek bloku
inpkeye7:                                 ;* je pevnò konec
         mov       ax,3d00h                 ; kl†vesa F3 = oznaáen° zaá†tku
         cmp       cx,cs:[ediblkb]          ; je jië zaá†tku dosaëeno ?
         je        inpkeye6                 ; zaá†tku je jië dosaëeno
         cmp       cx,cs:[ediblkk]          ; je p©ed koncem ?
         jbe       inpkeye9                 ; je p©ed koncem - OK
         call      xchgblok                 ; z†màna znaáek bloku
         jmp       short inpkeyec

inpkeye6:

         lea       si,[tabhlped]            ; tabulka n†povàd pro editor
         call      modihlp                  ; modifikace n†povàdy
         cmp       word ptr cs:[edikey],0   ; je nàjakò znak v bufferu ?
         jne       inpkeye8                 ; je nàjakò znak v bufferu
         call      testkey                  ; je p©ipraven znak ?
         jnz       inpkeye8
         jmp       inpkeye                  ; áek†n° na p©°chod znaku
inpkeye8:call      inpkeyf                  ; vstup znaku z vyprazd§ov†n°m
inpkeye9:ret

public   xchgblok
xchgblok:                                 ;* z†màna znaáek bloku
         push      word ptr cs:[ediblkb]
         push      word ptr cs:[ediblkk]
         pop       word ptr cs:[ediblkb]
         pop       word ptr cs:[ediblkk]
         xor       byte ptr cs:[insmouse],4 ; zmàna pevnÇho bodu
         ret

; -----------------------------------------------------------------------------

public   skokedik

skokedik label     word                     ; tabulka skokñ editoru pro ^K

         db        00h+10                   ; testuje se AL
         db        "S"                      ; uloëen° souboru ^KS
         dw        offset ediuloz
         db        "B"                      ; prvn° znaáka bloku ^KB
         dw        offset ediznacb
         db        "K"                      ; druh† znaáka bloku ^KK
         dw        offset ediznack
         db        "C"                      ; kop°rov†n° bloku ^KC
         dw        offset edicopybl
         db        "V"                      ; p©esun bloku ^KV
         dw        offset edimovebl
         db        "Y"                      ; ru®en° bloku ^KY
         dw        offset edidelbl
         db        "H"                      ; oznaáen° bloku ^KH
         dw        offset edihid
         db        "R"                      ; áten° bloku ^KR
         dw        offset edireadb
         db        "W"                      ; z†pis bloku ^KW
         dw        offset ediulozb
         db        1                        ; nastaven° znaáky ^Kn
         dw        offset edisetz

         db        0

skokediq label     word                     ; tabulka skokñ editoru pro ^Q

         db        00h+15                   ; testuje se AL
         db        "A"                      ; n†hrada ©etàzce ^QA
         dw        offset edirepl
         db        "B"                      ; zaá†tek bloku ^QB
         dw        offset edizacb
         db        "C"                      ; konec souboru ^QC
         dw        offset edicpgdn
         db        "D"                      ; konec ©†dku ^QD
         dw        offset ediend
         db        "E"                      ; horn° okraj ^QE
         dw        offset edichome
         db        "F"                      ; nalezen° textu ^QF
         dw        offset edifind
         db        "K"                      ; konec bloku ^QK
         dw        offset edikonb
         db        "L"                      ; pokraáov†n° v hled†n° ^QL
         dw        offset edifindn
         db        "M"                      ; nastaven° znaáky ^QM
         dw        offset edisetm
         db        "P"                      ; n†vrat na znaáku ^QP
         dw        offset ediretm
         db        "R"                      ; zaá†tek souboru ^QR
         dw        offset edicpgup
         db        "S"                      ; zaá†tek ©†dku ^QS
         dw        offset edihome
         db        "X"                      ; doln° okraj ^QX
         dw        offset edicend
         db        "Y"                      ; maz†n° po konec ©†dku ^QY
         dw        offset edidelly
         db        1                        ; n†vrat na znaáku ^Qn
         dw        offset ediretz
         db        0


public   skokedi

skokedi  label     word                     ; tabulka skokñ editoru

         db        00h+26                   ; testuje se AL
         db        01h                      ; slovo vlevo ^A
         dw        offset ediwleft
         db        02h                      ; n†povàda ^B
         dw        offset edithelp
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
         db        0bh                      ; prefif ^K
         dw        offset editctk
         db        0ch                      ; pokraáov†n° v hled†n° ^L
         dw        offset edifindn
         db        0dh                      ; konec ©†dku ^M
         dw        offset edienter
         db        0eh                      ; vloëen° ©†dku ^N
         dw        offset edinl
         db        10h                      ; vloëen° znaku ^P
         dw        offset edispec
         db        11h                      ; prefix ^Q
         dw        offset editctq
         db        12h                      ; str†nka nahoru ^R
         dw        offset edipgup
         db        13h                      ; kurzor vlevo ^S
         dw        offset edileft
         db        14h                      ; maz†n° slova vpravo ^T
         dw        offset ediwdel
         db        16h                      ; vkl†d†n° ^V
         dw        offset ediins
         db        17h                      ; posun nahoru ^W
         dw        offset edimup
         db        18h                      ; kurzor dolñ ^X
         dw        offset edidown
         db        19h                      ; vymaz†n° ©†dky ^Y
         dw        offset edidell
         db        1ah                      ; posun dolñ ^Z
         dw        offset edimdown
         db        7fh                      ; maz†n° slova vlevo ^BS
         dw        offset ediwbs
         db        1fh                      ; z†màna znakñ ^-
         dw        offset edixchg

         db        40h+42                   ; testuje se AH
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
         db        93h                      ; maz†n° slova vpravo ^DELETE
         dw        offset ediwdel
         db        77h                      ; horn° okraj ^HOME
         dw        offset edichome
         db        75h                      ; doln° okraj ^END
         dw        offset edicend
         db        49h                      ; o str†nku nahoru PAGEUP
         dw        offset edipgup
         db        51h                      ; o str†nku dolñ PAGEDONW
         dw        offset edipgdn
         db        8dh                      ; 6 ©†dkñ nahoru ^UP
         dw        offset edicup
         db        91h                      ; 6 ©†dkñ dolñ ^DOWN
         dw        offset edicdown
         db        52h                      ; vkl†d†n° INSERT
         dw        offset ediins
         db        3bh                      ; n†povàda F1
         dw        offset help
         db        54h                      ; n†povàda Shift-F1
         dw        offset althelp
         db        3ch                      ; uloëen° souboru F2
         dw        offset ediuloz
         db        55h                      ; uloëen° souboru SHIFT-F2
         dw        offset ediulozs
         db        3dh                      ; prvn° znaáka bloku F3
         dw        offset ediznacb
         db        56h                      ; z†pis bloku SHIFT-F3
         dw        offset ediulozb
         db        6ah                      ; bin†rn° editace Alt-F3
         dw        offset editbinar
         db        3eh                      ; druh† znaáka bloku F4
         dw        offset ediznack
         db        57h                      ; áten° zadanÇho souboru Shift-F4
         dw        offset edireads
         db        6bh                      ; zmàna zobr. ©°d. znakñ Alt-F4
         dw        offset edictrl
         db        3fh                      ; kop°rov†n° bloku F5
         dw        offset edicopybl
         db        58h                      ; áten° bloku SHIFT-F5
         dw        offset edireadb
         db        6ch                      ; zmàna zobr. tabel†torñ Alt-F5
         dw        offset editabel
         db        40h                      ; p©esun bloku F6
         dw        offset edimovebl
         db        41h                      ; nalezen° textu F7
         dw        offset edifind
         db        6eh                      ; p©evod fontñ ALT-F7
         dw        offset edifont
         db        5ah                      ; pokraáov†n° v hled†n° SHIFT-F7
         dw        offset edifindn
         db        42h                      ; ru®en° bloku F8
         dw        offset edidelbl
         db        6fh                      ; zmàna znakñ Alt-F8
         dw        offset ediznak
         db        5bh                      ; n†hrada ©etàzce Shift-F8
         dw        offset edirepl
         db        43h                      ; oznaáen° bloku F9
         dw        offset edihid
         db        70h                      ; zmàna 1 znaku Alt-F9
         dw        offset edizmena
         db        5dh                      ; ©†dkov†n° EGA 43 Shift-F10
         dw        offset editega43

         db        80h+1                    ; testuje se AX
         dw        0f00h                    ; tabel†tor zpàt SHIFT-TAB
         dw        offset edibtab

         db        0

; -----------------------------------------------------------------------------
public   editega43

editega43:                                ;* ©†dkov†n° EGA 43

         call      egaset                   ; zmàna ©†dkov†n° displeje EGA
         mov       ah,3                     ; funkce poskytnut° kurzoru
         mov       bh,ds:[aktpage]          ; pracovn° videostr†nka
         int       10h                      ; poskytnut° kurzoru
         mov       ds:[edinormk],cx         ; £schova vzhledu kurzoru
         call      ediiniuk                 ; inicializace ukazatelñ kurzoru
         call      edimodik                 ; modifikace kurzoru
         call      windret
         ret

; -----------------------------------------------------------------------------
public   edireads

edireads:                                 ;* naáten° zadanÇho souboru Shift-F4

         lea       di,[txtedis]             ; nadpis "zadejte jmÇno souboru ..."
         call      editzadf                 ; vstup zad†n° jmÇna souboru
         call      windret                  ; navr†cen° okna
         jc        edireds1                 ; p©eru®en° operace
         lea       di,[bufwin]
         mov       dx,di
         call      transtxt
         call      editread                 ; áten° souboru do pamàti
         jc        edireds1                 ; chyba - operaci nelze provÇst
         mov       si,9eh                   ; jmÇno souboru
         lea       di,[buffedi]             ; buffer k uloëen° jmÇna
         call      transtxt                 ; p©enos jmÇna souboru
         call      edittop0                 ; poá†teán° zobrazen° inform. ©†dku
edireds1:mov       bh,80h
         ret

; -----------------------------------------------------------------------------
public   edireadb

edireadb:                                 ;* naáten° bloku do pamàti Shift-F5


         lea       di,[txtedib]             ; text "Naátu jako blok..."
         call      editzadf                 ; zad†n° jmÇna souboru
         call      windret                  ; navr†cen° okna
         jc        ediredb9                 ; p©eru®en° operace
         mov       dx,si                    ; jmÇno souboru
                                          ;* uvolnàn° m°sta pro soubor
         mov       di,ds:[editnum]          ; konec textu
         mov       cx,ds:[editmax]          ; konec pamàti
         sub       cx,di                    ; volnò prostor pamàti
         dec       cx
         push      cx
         push      es
         mov       es,ds:[topseg]           ; adresa segmentu s textem
         mov       al," "
         rep       stosb                    ; vymaz†n° zbylÇho prostoru
         pop       es
         pop       cx
         mov       si,ds:[edikurz]          ; adresa kurzoru
         mov       di,si
         add       di,cx                    ; konec volnÇho prostoru
         call      insertbl                 ; uvolnàn° m°sta pro soubor
         jc        ediredb9
                                          ;* naáten° dat do pamàti
         push      si
         push      di
         push      cx
         call      editrdb                  ; naáten° souboru do pamàti
         pop       cx
         pop       di
         pop       si
         jc        ediredb5                 ; chyba áten° souboru
         add       si,ax                    ; data se ponechaj°
                                          ;* zru®en° zbytku prostoru
ediredb5:pushf
         call      deletemem                ; zru®en° zbytku dat
         popf
         jc        ediredb9                 ; byla chyba operace
         mov       cx,ax                    ; dÇlka novÇho bloku
         jmp       edicopb1                 ; oznaáen° novÇho bloku

ediredb9:mov       bh,80h
         ret

; -----------------------------------------------------------------------------
public   edifont

edifont:                                  ;* p©evod áeskòch fontñ Alt-F9

         call      getznacb                 ; poskytnut° adresy bloku
         jc        edifont9                 ; blok nen° aktivn°
                                          ;* volba operace
         lea       si,[edivolb3]            ; volby pro p©evod
         lea       di,[txtedif1]            ; nadpis
         xor       al,al
         call      volbyh                   ; proveden° voleb
         jc        edifont8
                                          ;* nastaven° adres pro p©evod
         call      getznacb                 ; poskytnut° adres bloku
         mov       cx,di                    ; adresa konce bloku
         sub       cx,si                    ; poáet bajtñ k p©evodu
         mov       di,si
                                          ;* stanoven° konverzn°ho programu
         dec       al
         lea       si,[konvkc]              ; p©evod Kamenickòch -> bez
         lea       bx,[prevcs]              ; tabulka pro p©evod
         js        edifont2
         inc       bx
         dec       al
         lea       si,[konvkl]              ; p©evod Kamenickòch -> Latin 2
         js        edifont2
         lea       si,[konvlc]              ; p©evod Latin 2 -> bez
         je        edifont2                 ; konverze Latin 2 -> Kamenickòch
         lea       si,[konvlk]              ; p©evod Latin 2 -> Kamenickòch
edifont2:
         mov       es,ds:[topseg]           ; segment s daty
edifont3:mov       al,es:[di]               ; znak k p©evodu
         call      si                       ; konverzn° program
         stosb                              ; uloëen° p©evedenÇho znaku
         loop      edifont3                 ; dal®° znak k p©evodu

         or        byte ptr ds:[ediflag],1  ; p©°znak, ëe byl soub. modifikov†n
         and       byte ptr ds:[ediflag],not 8 ; vypnut° bloku
edifont8:mov       bh,80h
edifont9:ret

; -----------------------------------------------------------------------------
public   ediznak

ediznak:                                  ;* p©evod znakñ v bloku Alt-F8

         call      getznacb                 ; poskytnut° adresy bloku
         jc        edifont9                 ; blok nen° aktivn°
                                          ;* volba operace
         lea       si,[edivolb4]            ; volby pro p©evod
         lea       di,[txtedif2]            ; nadpis
         xor       al,al
         call      volbyh                   ; proveden° voleb
         jc        edifont8                 ; p©eru®en°
                                          ;* nastaven° adres pro p©evod
         call      getznacb                 ; poskytnut° adres bloku
         mov       cx,di                    ; adresa konce bloku
         sub       cx,si                    ; poáet bajtñ k p©evodu
         mov       di,si
         lea       si,[highcase]            ; p©evod na velk† p°smena
         dec       al
         js        edifont2
         lea       si,[lowcase]             ; p©evod na mal† p°smena
         jmp       short edifont2

; -----------------------------------------------------------------------------
public   konvkc,konvlc,konvkl,konvlk

konvkl:                                   ;* p©evod Kamenickòch -> Latin 2
konvkc:                                   ;* p©evod Kamenickòch -> bez diakrit.
         or        al,al
         jns       konvkc2                  ; je men®° neë 128
         cmp       al,171                   ; nejvàt®° znak
         ja        konvkc2                  ; je vàt®°
         sub       al,128                   ; offset v tabulce
         add       al,al                    ; offset * 2
         xlat                               ; p©evod znaku
konvkc2: ret


konvlc:                                   ;* p©evod Latin 2 -> bez diakritiky

         or        al,al
         jns       konvlc3                  ; nen° znak s diakritikou
         push      cx
         push      bx
         mov       cx,44                    ; poáet poloëek v tabulce
         sub       bx,2
         mov       dl,127                   ; prvn° znak - 1
konvlc1: add       bx,2
         inc       dl
         cmp       ds:[bx],al
         loopne    konvlc1                  ; dal®° znak
         jne       konvlc2                  ; p©evod nebyl £spà®nò
         mov       al,ds:[bx-1]             ; áeskò znak bez diakritiky
konvlc2: pop       bx
         pop       cx
konvlc3: ret


konvlk:                                   ;* p©evod Latin 2 -> Kamenickòch
         mov       dh,al
         call      konvlc
         cmp       al,dh
         je        konvlk2
         mov       al,dl
konvlk2: ret

; -----------------------------------------------------------------------------
public   editread

editread:                                 ;* áten° souboru DX do pamàti


         mov       cx,ds:[editmax]          ; velikost bufferu
;         dec       cx
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
                                          ;* test, zda to nen° adres†©
         test      byte ptr ds:[95h],10h    ; je to adres†© ?
         stc
         jnz       editrd2                  ; je to adres†©

ifdef    upver
                                          ;* test velikosti souboru
         cmp       word ptr ds:[9ch],0      ; je soubor vàt®° neë 64 KB ?
         jne       editrd4                  ; soubor je p©°li® velkò
         cmp       cx,ds:[9ah]              ; nië®° slovo velikosti souboru
         jbe       editrd4                  ; soubor p©°li® velkò
endif
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
         call      windret
         jc        editrd3                  ; bylo p©eru®en°
         lea       si,[erredi6]             ; chyba "chyba zad†n° souboru"
editrd5: call      zobrchyb                 ; zobrazen° chybovÇho hl†®en°
editrd3: mov       word ptr ds:[parbreak],0
         ret
                                          ;* chyba - soubor je velkò
editrd4: call      windret
         lea       si,[erredi1]             ; chyba "soubor se nenaáetl celò !"
         call      zobrchyb                 ; zobrazen° chybovÇho hl†®en°

ifndef   upver
         clc
endif

         jmp       short editrd3

; -----------------------------------------------------------------------------
public   ediulozb

ediulozb:                                 ;* uloëen° bloku jako soubor Shift-F10
         call      getznacb                 ; vòpoáet adres znaáek bloku
         jc        editwr1                  ; operaci nelze provÇst
         lea       di,[txtedia]             ; text "Blok uloë°m jako:"
         call      editzadf                 ; zad†n° jmÇna souboru
         call      windret
         jc        editwr1                  ; p©eru®en° operace
         mov       dx,si                    ; jmÇno souboru
         call      getznacb                 ; vòpoáet adres znaáek bloku
         mov       cx,di                    ; adresa konce bloku
         sub       cx,si                    ; dÇlka bloku
         jmp       short editwr             ; z†pis bloku na disk

public   ediulozs

ediulozs:                                 ;* uloëen° jako soubor Shift-F2

         lea       di,[txtedi9]             ; text "Soubor uloë°m jako ..."
         call      editzadf                 ; zad†n° jmÇna souboru
         call      windret
         jc        editwr1                  ; p©eru®en° operace
         mov       dx,si                    ; jmÇno souboru
         jmp       short ediuloz0

public   ediuloz
ediuloz:                                  ;* uloëen° souboru F2
                                            ; VùSTUP: CY=chyba operace

         lea       dx,[bufwin]              ; editovanò soubor
ediuloz0:
         xor       si,si                    ; poá†teán° adresa
         mov       cx,cs:[editnum]          ; dÇlka dat k z†pisu
         call      editwr                   ; z†pis souboru na disk
         jc        ediuloz1                 ; chyba operace
         and       byte ptr cs:[ediflag],0feh ; zru®en° p©°znaku modifikace
ediuloz1:ret


public   editwr
editwr:                                   ;* z†pis bloku dat na disk
                                            ; VSTUP: DS:DX=jmÇno souboru
                                            ;        SI=adresa bloku
                                            ;        CX=dÇlka dat k z†pisu
                                            ; VùSTUP: CY=chyba z†pisu

ifndef   demo
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
         mov       si,offset txtedig        ; soubor m† ochranu proti z†pisu
         cmp       ax,5
         je        editwr3                  ; soubor m† ochranu proti z†pisu
         lea       si,[erredi6]             ; chyba "chyba zad†n° souboru"
editwr3: call      zobrchyb                 ; zobrazen° chybovÇho hl†®en°
editwr1: mov       word ptr ds:[parbreak],0 ; zru®en° p©°znaku p©eru®en°
         call      windret                  ; navr†cen° obsahu okna
         stc                                ; p©°znak chyby z†pisu
         ret
editwr2:                                  ;* z†pis dat na disk
         mov       bx,ax                    ; identifik†tor souboru
         call      testdev                  ; test znakovÇho za©°zen°

editwr7: push      cx
         cmp       cx,800h
         jbe       editwr4
         mov       cx,800h                  ; omezen° na 2 KB
editwr4: mov       ah,40h                   ; funkce z†pisu do souboru
         mov       dx,si                    ; poá†teán° offset dat
         mov       ds,cs:[topseg]           ; segment s textem
         int       21h                      ; z†pis dat do souboru
         jc        editwr5
         cmp       ax,cx
         clc
editwr5: pop       cx
         jc        editwr6                  ; chyba z†pisu
         jne       editwr8                  ; nesouhlas° poáet bajtñ - disk plnò
         add       si,ax                    ; zvò®en° adresy
         sub       cx,ax                    ; sn°ëen° poátu bajtñ
         jnz       editwr7                  ; z†pis dal®°ho bloku dat
         xor       ax,ax

editwr8: call      testdev                  ; je znakovÇ za©°zen° ?
         jc        editwr9
         jz        editwr9                  ; je to soubor
         mov       ax,cx                    ; poáet bajtñ bude souhlasit
editwr9: clc

editwr6:
         push      cs
         pop       ds
         push      cx                       ; poëadovanò poáet bajtñ
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
         lea       si,[erredi5]             ; hl†®en° o chybà uloëen°
         cmp       ax,cx                    ; souhlas° poáet zapsanòch bajtñ ?
         jne       editwr3                  ; soubor nebyl uloëen celò
else
editwr1:
endif
         call      windret                  ; navr†cen° obsahu okna
         ret

; -----------------------------------------------------------------------------
public   ediretz,ediretm,edizacb,edikonb

ediretz: mov       bl,cl                  ;* n†vrat na znaáku ^Qn (CL=1 - 10)
ediretm: inc       bx                     ;* n†vrat na znaáku ^QP (=2)
edikonb: inc       bx                     ;* skok na konec bloku ^QK (=1)
edizacb:                                  ;* skok na zaá†tek bloku ^QB (=0)
         shl       bx,1                     ; á°slo znaáky * 2
         push      word ptr ds:[ediblkb+bx] ; poëadovan† nov† adresa
         pop       word ptr ds:[edikurz]    ; nastaven° novÇ pozice kurzoru
         call      ediiniuk                 ; inicializace ukazatelñ
         call      edisetk                  ; aktualizace pozice na ©†dku
         ret

; -----------------------------------------------------------------------------
public   edisetz,edisetm

edisetz: mov       bl,cl                  ;* nastaven° znaáky ^Kn (CL=1 - 10)
edisetm:                                  ;* nastaven° znaáky ^QM
         shl       bx,1                     ; á°slo znaáky * 2
         push      word ptr ds:[edikurz]    ; pozice kurzoru
         pop       word ptr ds:[ediznac+bx] ; uschov†n° adresy
         ret

; -----------------------------------------------------------------------------
public   editbinar
editbinar:                               ;* nastaven° bin†rn° editace

         xor       byte ptr ds:[ediflag],40h ; zmàna p©°znaku bin†rn° editace
         mov       word ptr ds:[firstrad],0 ; zru®en° prvn°ho ©†dku
         mov       word ptr ds:[toppoz],0   ; je poá†tek ©†dku
editbin2:call      ediiniuk                 ; inicializace ukazatelñ
         call      edisetk                  ; £schova pozice kurzoru
         mov       bh,80h                   ; p©°znak p©ekreslen°
         ret

; -----------------------------------------------------------------------------
public   editabel
editabel:                                 ;* zmàna zobrazen° tabel†torñ

         xor       byte ptr cs:[ediflag],10h ; zmàna p©°znaku zobrazen° tabel†t.
         jmp       short editbin2           ; normalizace parametrñ

; -----------------------------------------------------------------------------
public   edictrl
edictrl:                                  ;* zmàna zobrazen° ©°dic°ch znakñ

         xor       byte ptr cs:[config],4   ; zmàna p©°znaku zobrazen° CTRL-
         mov       bh,80h                   ; p©°znak p©ekreslen° obrazovky
         ret

; -----------------------------------------------------------------------------
public   edizmena

edizmena:                                 ;* zmàna 1 znaku na kurzoru Alt-F9
         call      edisetk                  ; aktualizace pozice na ©†dku
         push      ds
         call      edigkurz                 ; poskytnut° adresy kurzoru
         mov       al,ds:[si]               ; znak k p©evodu
         call      highcase                 ; p©evod na velkÇ p°smeno
         cmp       al,ds:[si]               ; byla zmàna ?
         jne       edizmen3                 ; byla zmàna
         call      lowcase                  ; p©evod na malÇ p°smeno
edizmen3:mov       ds:[si],al               ; nastaven° znaku
         inc       bl                       ; p©°znak modifikace ©†dku
         or        byte ptr cs:[ediflag],1  ; p©°znak modifikace souboru
         pop       ds
         jmp       ediright                 ; posun kurzoru na dal®° znak

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
public   editctq

editctq:                                  ;* prefix ^Q
         or        byte ptr cs:[ediflag],2 ; nastaven° p©°znaku ^Q
         ret

; -----------------------------------------------------------------------------
public   editctk

editctk:                                  ;* prefix ^K
         or        byte ptr cs:[ediflag],80h ; nastaven° p©°znaku ^K
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
         lea       si,[edivolb2]            ; volby
         lea       di,[txtedi8]             ; hl†®en° o modifikaci
         xor       al,al                    ; p©edvolba
         call      volbyh                   ; dotaz na dal®° operaci
ediasku3:pop       di
         pop       si
         ret

; -----------------------------------------------------------------------------
public   edirepl

edirepl:                                  ;* n†hrada ©etàzce ^QA, Shift-F8
         or        byte ptr ds:[conf4],1    ; nastaven° p©°znaku n†hrady textu
         jmp       short edifin00
; -----------------------------------------------------------------------------
public   edifind

edifind:                                  ;* nalezen° textu ^QF,F7

         and       byte ptr ds:[conf4],not 1 ; zru®en° p©°znaku n†hrady textu
                                          ;* zad†n° hledanÇho ©etàzce
edifin00:mov       byte ptr ds:[bufhlde2],1 ; p©ednastaven° - 1 p©edvolba
         mov       word ptr ds:[bufhlde3],offset findstr ; p©edvolba hled. textu
         lea       si,[bufhlde]             ; buffer voleb
         lea       ax,[bufhlde2]            ; adresa konce bufferu
         sub       ax,offset bufhlde1       ; vòpoáet dÇlky bufferu
         mov       ds:[si],ax               ; nastaven° dÇlky bufferu
         lea       di,[txtedi7]             ; nadpis "Zadejte hledanò text:"
         call      select                   ; proveden° volby
         jnc       edifind0                 ; zad†n° OK
edifind3:jmp       edifind6                 ; operace p©eru®ena
edifind0:lea       di,[findstr]             ; buffer hledanÇho ©etàzce
         call      transtxt                 ; £schova hledanÇho ©etàzce
         call      windret                  ; n†vrat zobrazen° okna
                                          ;* zad†n° n†hradn°ho ©etàzce
         test      byte ptr ds:[conf4],1    ; je n†hrada textu ?
         jz        edifin02                 ; nen° n†hrada textu
         mov       word ptr ds:[bufhlde3],offset replstr ; p©edvolba n†hrady
         lea       si,[bufhlde]             ; buffer voleb
         lea       di,[txtedie]             ; nadpis "Novò text:"
         call      select                   ; proveden° volby
         jc        edifind3                 ; p©eru®en° operace
         lea       di,[replstr]             ; n†hradn° text
         call      transtxt                 ; £schova n†hradn°ho ©etàzce
         call      windret                  ; n†vrat zobrazen° okna
edifin02:                                 ;* volba parametrñ operace
         call      edifndv                  ; nastaven° voleb pro vyhled†v†n°
         jc        edifind3                 ; p©eru®en° operace
         or        byte ptr ds:[conf5],20h  ; p©°znak zah†jen° hled†n°
                                          ;* p©evod na velk† p°smena
         test      byte ptr ds:[conf4],2    ; rozli®uj° se p°smena ?
         jz        edifindg                 ; rozli®uj° se p°smena
         lea       si,[findstr]             ; hledanò ©etàzec
         push      si                       ; adresa ©etàzce
         mov       di,si
edifin03:lodsb
         call      highcase                 ; p©evod na velkÇ p°smeno
         stosb
         or        al,al                    ; je to konec ©etàzce ?
         jnz       edifin03                 ; nen° konec - dal®° znak
         pop       si                       ; adresa ©etàzce
edifindg:                                 ;* vòchoz° adresa operace
         mov       bl,ds:[conf4]            ; p©°znaky pro hled†n°
         xor       di,di                    ; poá†teán° adresa pro volbu "G"
;         mov       di,-1                    ; poá†teán° adresa pro volbu "G"
         test      bl,4                     ; je hled†n° zpàt ?
         jz        edifind1                 ; nen° hled†n° zpàt
         mov       di,ds:[editnum]          ; adresa konce textu
         or        di,di
         jz        edifind1
         dec       di
edifind1:test      bl,10h                   ; je hled†n° v souboru "G" ?
         jnz       edifind2                 ; je hled†n° v souboru "G"
         mov       di,ds:[ediblkb]          ; adresa zaá†tku bloku
;         dec       di
         test      bl,4                     ; je hled†n° zpàt ?
         jz        edifindh                 ; nen° hled†n° zpàt
         mov       di,ds:[ediblkk]          ; adresa konce bloku
         or        di,di
         jz        edifindh
         dec       di
edifindh:test      bl,20h                   ; je hled†n° v bloku ?
         jnz       edifind2                 ; je hled†n° v bloku



edifindn:                                 ;* pokraáov†n° v hled†n° ^L, SHIFT-F7
                                          ;* poá†teán° adresa pro pokraá.hled†n°
         mov       di,cs:[edikurz]          ; adresa kurzoru
         test      byte ptr ds:[conf4],20h  ; je hled†n° v bloku ?
         jz        edifind2                 ; nen° hled†n° v bloku
         mov       ax,ds:[ediblkb]          ; adresa zaá†tku bloku
;         dec       ax
         cmp       di,ax                    ; je kurzor pod blokem ?
         jb        edifindi                 ; je pod blokem
         mov       ax,ds:[ediblkk]          ; adresa konce bloku
         cmp       di,ax                    ; je nad blokem ?
         jb        edifind2                 ; je uvnit© bloku
         or        ax,ax
         jz        edifindi
         dec       ax
edifindi:mov       di,ax                    ; vòchoz° adresa pro hled†n°

edifind2:                                 ;* nalezen° ©etàzce
         lea       si,[findstr]             ; hledanò ©etàzec
         call      lensi0                   ; zji®tàn° dÇlky ©etàzce
         mov       cx,ax                    ; dÇlka ©etàzce
         or        cx,cx
         jnz       edifindu
         jmp       edifind6                 ; nen° ë†dnò text
edifindu:                                 ;* nalezen° textovÇho ©etàzce od DI
         call      edifndf                  ; nalezen° textu v souboru
         jc        edifind7                 ; text nenalezen
         or        byte ptr ds:[conf5],40h  ; p©°znak nalezen° textu
                                          ;* nastaven° kurzoru
         mov       cs:[edikurz],di          ; nastaven° pozice kurzoru
         call      ediiniuk                 ; inicializace ukazatelñ
         call      editall                  ; p©°padnÇ p©ekreslen° displeje
         test      byte ptr ds:[conf4],1    ; je n†hrada textu ?
         jz        edifindc                 ; nen° n†hrada textu - konec

         call      edifndq                  ; dotaz na dal®° operaci
         jc        edifindc                 ; p©eru®en° operace
         jz        edifinds                 ; nen° n†hrada textu

         call      edifndr                  ; n†hrada textu
         jc        edifindc                 ; nedostatek pamàti

edifinds:                                 ;* pokraáov†n° - dal®° hled†n°
         test      byte ptr ds:[conf4],30h  ; je n†hrada v bloku nebo souboru ?
         jnz       edifindn                 ; pokraáov†n° v operaci
edifindc:mov       bh,80h                   ; p©°znak pro p©ekreslen° displeje
         call      edisetk                  ; aktualizace pozice na ©†dku
         and       byte ptr ds:[conf5],not 40h ; zru®en° p©°znaku nalezen° textu
         ret


edifind7:                                 ;* ©etàzec nenalezen
         test      byte ptr ds:[conf5],40h  ; byl text nalezen alespo§ 1x ?
;         test      byte ptr ds:[conf4],30h  ; je n†hrada v bloku nebo souboru ?
         jnz       edifindc                 ; text byl nalezen - nehl†s° se
         push      cs
         pop       ds
         push      cs
         pop       es
         lea       di,[outbuf]
         push      di
         lea       si,[erredi3]             ; text "Hledanò text"
         call      transtxt                 ; p©enos textu
         lea       si,[findstr]             ; hledanò text
         call      lensi0                   ; dÇlka textu
         cmp       al,30                    ; je del®° text neë 20 znakñ ?
         jb        edifind8                 ; je men®° neë 30 znakñ
         mov       al,30
edifind8:mov       cl,al                    ; dÇlka textu
         xor       ch,ch                    ; CH <- 0
edifinde:lodsb
         cmp       al,32
         jae       edifindf
         mov       al," "
edifindf:stosb
         loop      edifinde                 ; p©enos textu
         lea       si,[erredi4]             ; text "nenalezen !"
         call      transtxt
         pop       di                       ; text hl†®en°
         lea       si,[txtchyb1]            ; volba OK
         xor       al,al                    ; p©edvolen† poloëka
         call      volbyh                   ; zobrazen° hl†®en°
edifind6:
         call      outedhlp                 ; novÇ zobrazen° n†povàdy
         jmp       short edifindc           ; n†vrat

; -----------------------------------------------------------------------------
public   edifndr

edifndr:                                  ;* n†hrada nalezenÇho textu
                                            ; VùSTUP: CY=nedostatek pamàti

                                          ;* zru®en° pñvodn°ho ©etàzce
         mov       di,cs:[edikurz]          ; pozice kurzoru
         lea       si,[findstr]             ; hledanò ©etàzec
         call      lensi0                   ; dÇlka ©etàzce
         mov       si,di                    ; pozice kurzoru
         add       si,ax                    ; konec ru®enÇho bloku
         call      deletemem                ; zru®en° bloku pamàti
                                          ;* vytvo©en° m°sta pro novò ©etàzec
         lea       si,[replstr]             ; n†hradn° ©etàzec
         push      si                       ; adresa ©etàzce
         call      lensi0                   ; dÇlka n†hradn°ho ©etàzce
         mov       si,di                    ; adresa kurzoru
         add       si,ax                    ; konec novÇho bloku
         mov       cx,ax                    ; dÇlka novÇho ©etàzce
         call      insertbl                 ; vytvo©en° m°sta pro novò ©etàzec
         pop       si                       ; adresa ©etàzce
         jc        edifndr2                 ; nen° dostatek m°sta
                                          ;* p©enesen° textu novÇho ©etàzce
         add       cs:[edikurz],cx          ; zvò®en° pozice kurzoru
         or        byte ptr cs:[conf5],20h  ; p©°znak - nemànit kurzor
edifndr1:push      es
         mov       es,ds:[topseg]
         rep       movsb                    ; p©enos textu
         pop       es
         mov       bh,80h
         call      editall                  ; n†vrat zobrazen° okna
         call      ediiniuk                 ; inicializace ukazatelñ
         clc
edifndr2:ret

; -----------------------------------------------------------------------------
public   edifndq

edifndq:                                  ;* dotaz, zda se m† n†hrada provÇst
                                            ; VùSTUP: CY=p©eru®en° operace
                                            ;         NZ=n†hrada se m† provÇst

         call      editobrk                 ; zobrazen° kurzoru
         call      testbreak                ; je p©eru®en° operace ?
         jc        edifndq5                 ; je p©eru®en° operace
         test      byte ptr ds:[conf4],40h  ; je n†hrada bez dotazu ?
         jnz       edifndq5                 ; je n†hrada bez dotazu
                                          ;* dotaz, zda se m† n†hrada provÇst
         call      mouseoff                 ; vypnut° my®i
         mov       al,3                     ; barva 3
         call      outch1                   ; nastaven° barvy
         xor       dx,dx                    ; poá†teán° pozice
         mov       al," "                   ; mazac° znak
         mov       cx,71                    ; poáet znakñ k tisku
         call      outch                    ; vymaz†n° ©†dku
         mov       dl,6                     ; poá†teán° pozice pro dotaz
         lea       si,[txtedif]             ; text dotazu
         call      outtxt                   ; zobrazen° textu
         call      mouseon                  ; zapnut° my®i
edifndq2:call      inpkey                   ; vstup znaku z kl†vesnice
         call      highcase                 ; p©evod na velkÇ p°smeno
         cmp       al,1bh                   ; je p©eru®en° operace ?
         stc
         je        edifndq3                 ; p©eru®en° operace

ifdef    ANGL
         cmp       al,"Y"                   ; potvrzen° volby ?
else
         cmp       al,"A"                   ; potvrzen° volby ?
endif

         je        edifndq4                 ; n†hrada se provede

ifdef    ANGL
         cmp       al,"A"                   ; v®echny se nahrad° ?
else
         cmp       al,"V"                   ; v®echny se nahrad° ?
endif

         je        edifndq6                 ; je volba "V"
         xor       al,al                    ; p©°znak - n†hrada se neprovede
         jmp       short edifndq3
edifndq6:
;         jne       edifndq2                 ; nen° volba "V" - dal®° znak
         or        byte ptr ds:[conf4],40h  ; p©°znak n†hrady bez dotazu
         test      byte ptr ds:[conf4],30h  ; je volba "G" nebo "L" ?
         jnz       edifndq4                 ; je volba "G" nebo "L"
         or        byte ptr ds:[conf4],10h  ; nastaven° p©°znaku volby "G"
edifndq4:inc       al                       ; p©°znak NZ
edifndq3:pushf
         call      edittop0                 ; n†vrat horn°ho ©†dku po dotazu
         popf
edifndq5:ret

; -----------------------------------------------------------------------------
public   edifndv

edifndv:                                  ;* nastaven° parametrñ vyhled†v†n°
                                            ; VùSTUP: CY=p©eru®en° operace

         push      dx
         push      si
         lea       si,[bufparh]             ; buffer voleb p©edvolby
         mov       word ptr ds:[si],132     ; nastaven° dÇlky bufferu
         cmp       byte ptr ds:[si+2],0     ; je jië nàco v bufferu ?
         jnz       edifndv1                 ; je jië nàco v bufferu
         mov       word ptr ds:[si+2],"U"   ; p©edvolba - parametr "U"
edifndv1:lea       di,[txtedic]             ; nadpis "Parametry:"
         mov       ax," ,"                  ; plat° volba "N"
         mov       bl,ds:[conf4]            ; maska parametrñ
         and       bl,1                     ; ponech† se p©°znak n†hrady
         jnz       edifndv2                 ; je n†hrada
         mov       ax," "                   ; z†kaz volby "N"
edifndv2:mov       word ptr ds:[txtedid],ax ; povolen° volby "N"
         call      select                   ; proveden° volby
         jc        edifndv8                 ; p©eru®en° operace
         call      windret                  ; zru®en° okna voleb
edifndv3:lodsb                              ; naáten° zadanÇho znaku
         call      highcase                 ; p©evod na velkÇ p°smeno
         cmp       al,"?"                   ; je povolena n†hrada otazn°kem ?
         jne       edifndve
         or        bl,80h                   ; p©°znak povolen° n†hrady otazn°kem
edifndve:cmp       al,"U"                   ; je volba "U" ?
         jne       edifndv4                 ; nen° volba "U"
         or        bl,2                     ; nastaven° p©°znaku volby "U"
edifndv4:cmp       al,"B"                   ; je volba "B" ?
         jne       edifndv5                 ; nen° volba "B"
         or        bl,4                     ; nastaven° p©°znaku volby "B"
edifndv5:cmp       al,"W"                   ; je volba "W" ?
         jne       edifndv6                 ; nen° volba "W"
         or        bl,8                     ; nastaven° p©°znaku volby "W"
edifndv6:cmp       al,"G"                   ; je volba "G" ?
         jne       edifndva                 ; nen° volba "G"
         or        bl,10h                   ; nastaven° p©°znaku volby "G"
edifndva:cmp       al,"L"                   ; je volba "L" ?
         jne       edifndvb                 ; nen° volba "L"
         or        bl,20h                   ; nastaven° p©°znaku volby "L"
edifndvb:cmp       al,"N"                   ; je volba "N" ?
         jne       edifndvc                 ; nen° volba "N"
         or        bl,40h                   ; nastaven° p©°znaku volby "N"
edifndvc:or        al,al                    ; je konec textu ?
         jnz       edifndv3                 ; nen° konec textu - dal®° znak
         mov       ds:[conf4],bl            ; novÇ nastaven° p©°znakñ
edifndv8:pop       si
         pop       dx
         ret

; -----------------------------------------------------------------------------
public   edifndf

edifndf:                                  ;* nalezen° textu v souboru
                                            ; VSTUP: DI=poá†teán° adresa hled†n°
                                            ;        DS:SI=hledanò text
                                            ;        CX=dÇlka hledanÇho textu
                                            ;        BL=p©°znaky pro hled†n°
                                            ; VùSTUP: CY=text nenalezen
                                            ;         DI=adresa nalezenÇho textu

         push      ax
         push      es

         push      ax
         push      dx
         mov       al,3                     ; barva 3
         call      outch1                   ; nastaven° barvy
         xor       dx,dx                    ; poá†teán° pozice
         mov       al,"*"                   ; indik†tor hled†n° "*"
         call      outch1                   ; zobrazen° znaku
         call      outch1                   ; zobrazen° znaku
         call      kurzout
         pop       dx
         pop       ax

         mov       bl,ds:[conf4]            ; p©°znaky pro hled†n°
         mov       es,ds:[topseg]           ; segment s textem
         test      byte ptr cs:[conf5],20h  ; je zah†jen° hled†n° ?
         jnz       edifndf2                 ; je zah†jen° hled†n°-stejn† pozice
edifndf1:                                 ;* posun ukazatele danòm smàrem
         inc       di                       ; zvò®en° adresy textu
         test      bl,4                     ; je hled†n° zpàt ?
         jz        edifndf2                 ; je hled†n° vp©ed
         dec       di                       ; n†vrat adresy textu
         jz        edifndf8                 ; je jië zaá†tek textu
         dec       di                       ; sn°ëen° adresy textu
edifndf2:
         test      bl,20h                   ; hled† se v bloku ?
         jz        edifndfb                 ; nehled† se v bloku
         cmp       di,ds:[ediblkb]          ; je pod zaá†tkem bloku ?
         jb        edifndf8                 ; je pod zaá†tkem bloku
         cmp       di,ds:[ediblkk]          ; je nad koncem bloku ?
         jae       edifndf8                 ; je nad koncem bloku
edifndfb:cmp       di,ds:[editnum]          ; je jië konec souboru ?
         jae       edifndf8                 ; je jië konec souboru
                                          ;* porovn†n° textu na adrese
         clc
         jcxz      edifndf9                 ; je nulov† dÇlka ©etàzce - nalezen
         push      cx                       ; dÇlka hledanÇho textu
         push      si
         push      di
edifndf3:inc       di                       ; zvò®en° adresy textu
         inc       si
         cmp       di,ds:[editnum]          ; je jië konec souboru ?
         ja        edifndf7                 ; je jië konec souboru
         mov       al,es:[di-1]             ; testovanò znak
         test      bl,2                     ; rozli®uj° se p°smena ?
         jz        edifndf4                 ; rozli®uj° se velk† a mal† p°smena
         call      highcase                 ; p©evod na velkÇ p°smeno
edifndf4:test      bl,80h                   ; je otazn°k platnò znak ?
         jz        edifndf5                 ; otazn°k je platnò znak
         cmp       byte ptr ds:[si-1],"?"   ; kontroluje se znak ?
         je        edifndf6                 ; znak se nekontroluje
edifndf5:cmp       al,ds:[si-1]             ; porovn†n° s hledanòm znakem
edifndf6:loopz     edifndf3                 ; p©i shodà test dal®°ho znaku
         jnz       edifndf7                 ; nen° shoda ©etàzcñ
         test      bl,8                     ; je porovn†n° celÇho slova ?
         jz        edifndf7                 ; nen° porovn†n° celÇho slova
         cmp       di,ds:[editnum]          ; je konec souboru ?
         je        edifndf7                 ; je konec souboru
         mov       al,es:[di]               ; znak n†sleduj°c° za ©etàzcem
         call      testchar                 ; je to oddàlovac° znak ?
         jnc       edifndfa                 ; nen° oddàlovac° znak - chyba
         xor       al,al                    ; oddàlovac° znak - p©°znak shody OK
edifndfa:or        al,al                    ; nastaven° p©°znaku ZY
edifndf7:pop       di
         pop       si
         pop       cx
         jnz       edifndf1                 ; ©etàzec nesouhlas° - dal®° pokus
         test      bl,8                     ; je porovn†n° celÇho slova ?
         jz        edifndf9                 ; nen° porovn†n° celÇho slova
         or        di,di                    ; je jië zaá†tek textu ?
         jz        edifndf9                 ; je jië zaá†tek textu - OK
         mov       al,es:[di-1]             ; znak p©ed ©etàzcem
         call      testchar                 ; je to oddàlovac° znak ?
         cmc
         jnc       edifndf9                 ; je to oddàlovac° znak - OK
         jmp       short edifndf1           ; nen° oddàlovac° znak - dal®° pokus
edifndf8:stc
edifndf9:pop       es
         pop       ax
         pushf
         and       byte ptr cs:[conf5],not 20h ; zru®en° p©°znaku zah†jen° hled.

         push      ax
         push      dx
         mov       al,3                     ; barva 3
         call      outch1                   ; nastaven° barvy
         xor       dx,dx                    ; poá†teán° pozice
         mov       al," "                   ; vymaz†n° indik†toru hled†n°
         call      outch1                   ; zobrazen° znaku
         call      outch1                   ; zobrazen° znaku
         call      kurzout
         pop       dx
         pop       ax

         popf
         ret

; -----------------------------------------------------------------------------
public   edithelp

edithelp:                                 ;* p©epnut° zobrazen° n†povàdy ^B

         xor       byte ptr ds:[flags],4    ; zmàna p©°znaku n†povàdy
         call      outedhlp                 ; zobrazen° n†povàdy editoru
edithlp2:call      ediiniuk                 ; inicializace ukazatelñ
         mov       bh,80h                   ; p©°znak p©episu okna
         ret

; -----------------------------------------------------------------------------
public   ediznacb,ediznack

ediznacb:                                 ;* nastaven° zaá†tku bloku F3, ^KB

         mov       ax,ds:[edikurz]          ; adresa kurzoru
         mov       ds:[ediblkb],ax          ; nastaven° zaá†tku bloku
ediznac2:or        byte ptr cs:[ediflag],8  ; zapnut° bloku
         mov       bh,80h                   ; p©°znak novÇho zobrazen°
         ret

ediznack:                                 ;* nastaven° konce bloku F4, ^KK
         push      word ptr ds:[edikurz]    ; adresa kurzoru
         pop       word ptr ds:[ediblkk]    ; nastaven° konce bloku
         jmp       short ediznac2

edihid:                                   ;* zap/vyp bloku F7, ^KH
         xor       byte ptr ds:[ediflag],8  ; zmàna p©°znaku bloku
         mov       bh,80h                   ; p©°znak novÇho zobrazen°
         ret

; -----------------------------------------------------------------------------
public   edimovebl
edimovebl:                                ;* p©esun bloku F6

         mov       ax,ds:[edikurz]          ; adresa kurzoru
         cmp       ax,ds:[ediblkk]          ; je kurzor ihned za koncem ?
         je        edicopb2                 ; je ihned za blokem - neprovede se
         call      edicopbl                 ; zkop°rov†n° bloku za kurzor
         jc        edicopb2                 ; chyba - nedostatek pamàti
         call      getznacb                 ; adresy znaáek bloku
         call      deletemet                ; zru®en° bloku textu (SI aë DI)
         jmp       short edicopb1


public   edicopybl
edicopybl:                                ;* kop°rov†n° bloku F5

         call      edicopbl                 ; zkop°rov†n° bloku
         jc        edicopb2                 ; operaci nelze provÇst
edicopb1:call      ediznacb                 ; nastaven° adresy zaá†tku bloku
         add       ax,cx                    ; novò konec bloku
         mov       ds:[ediblkk],ax          ; nastaven° konce bloku
         call      ediiniuk                 ; inicializace ukazatele
         mov       bh,80h                   ; p©°znak p©ekreslen° obrazovky
edicopb2:ret

edicopbl:
         call      edisetk                  ; uschov†n° pozice kurzoru
         call      getznacb0                ; vòpoáet adres znaáek bloku
         jc        edicpbl6                 ; operaci nelze provÇst
                                          ;* vytvo©en° m°sta pro blok
         mov       cx,di                    ; adresa konce bloku
         sub       cx,si                    ; dÇlka bloku
         mov       si,ds:[edikurz]          ; adresa kurzoru
         mov       di,si
         add       di,cx                    ; konec bloku

         call      insertbl                 ; vytvo©en° prostoru pro blok
         jc        edicpbl6                 ; chyba - nedostatek m°sta

         call      getznacb0                ; adresy znaáek bloku
         xchg      si,di
         call      edigkurz                 ; poskytnut° adresy kurzoru
         xchg      si,di
         push      ds
         pop       es
         push      cx
         rep       movsb                    ; p©esun bloku (zkop°rov†n°)
         pop       cx

         mov       bh,80h                   ; p©°znak p©ekreslen° obrazovky
         clc                                ; operace provedena
edicpbl6:push      cs
         pop       ds
         ret

;
;edicpble:                                 ;* chyba - nedostatek pamàti
;         push      si
;         push      di
;         push      ax
;         lea       si,[txtchyb1]            ; volba OK
;         lea       di,[erredi2]             ; chybovò text "Nedostatek m°sta"
;         xor       al,al                    ; p©edvolen† poloëka
;         call      volbyh                   ; zobrazen° hl†®en°
;         stc
;         mov       bh,80h                   ; p©°znak zobrazen° v®ech ©†dkñ
;         pop       ax
;         pop       di
;         pop       si
;         ret

; -----------------------------------------------------------------------------
public   edidelbl

edidelbl:                                 ;* ru®en° bloku F8

         call      getznacb                 ; vòpoáet adres znaáek bloku
         jc        edidlbl6                 ; operaci nelze provÇst
         call      deletemet                ; zru®en° bloku textu (SI aë DI)
         call      ediiniuk                 ; inicializace ukazatelñ
         mov       bh,80h
edidlbl6:ret

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
         push      ax
         push      bx
         push      cx
         lea       bx,[ediblkb]             ; tabulka adres znaáek
         mov       cx,13                    ; poáet znaáek v tabulce
deletem4:mov       ax,cs:[bx]               ; korigovan† znaáka
         call      edimoved                 ; p©esun ukazatele po ru®en° bloku
         mov       cs:[bx],ax               ; nov† hodnota znaáky
         add       bx,2                     ; zvò®en° ukazatele v tabulce
         loop      deletem4                 ; dal®° znaáka
         pop       cx
         pop       bx
         pop       ax
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
         jc        insertb4                 ; nedostatek m°sta
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
         pushf
         push      ax
         push      bx
         push      cx
         lea       bx,[ediblkb]             ; tabulka adres znaáek
         mov       cx,13                    ; poáet znaáek v tabulce
insertb3:mov       ax,cs:[bx]               ; korigovan† znaáka
         call      edimovei                 ; p©esun ukazatele po ru®en° bloku
         mov       cs:[bx],ax               ; nov† hodnota znaáky
         add       bx,2                     ; zvò®en° ukazatele v tabulce
         loop      insertb3                 ; dal®° znaáka
         pop       cx
         pop       bx
         pop       ax
         popf

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
         test      byte ptr cs:[ediflag],40h; je bin†rn° editace ?
         jnz       ediiniu1                 ; je bin†rn° editace
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
         mov       byte ptr ds:[edidrad],1  ; kurzor je na 1. ©†dku
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
ediiniu5:mov       ds:[firstrad],si         ; nastaven° adresy prvn°ho ©†dku
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
;public   edimovec
;
;edimovec:                                 ;* p©esun ukazat. po kop°rov†n° bloku
;                                            ; VSTUP: SI=nov† adresa bloku
;                                            ;        CX=velikost bloku
;                                            ; V/V:   AX=korigovan† adresa
;                                            ; VùSTUP: CY=ukazatel pod blokem
;
;         push      si
;         push      di
;         cmp       ax,si                    ; je ukazatel pod blokem ?
;         jb        edimovc4                 ; ukazatel je pod blokem - OK
;         add       ax,cx                    ; nov† adresa ukazatele
;edimovc4:pop       di
;         pop       si
;         ret
;
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
public   getznacb,getznacb0

getznacb0:                                ;* vòpoáet znaáek bloku pro kop°rov†n°

         call      getznacb
         jc        getzncb4                 ; operaci nelze provÇst
         cmp       cs:[edikurz],di          ; kontrola konce bloku
         jae       getzncb4                 ; kurzor nad blokem - OK
         cmp       si,cs:[edikurz]          ; kontrola zaá†tku bloku
getzncb4:ret


getznacb:                                 ;* poskytnut° adres znaáek bloku
                                            ; VùSTUP: SI=adresa zaá†tku bloku
                                            ;         DI=adresa konce bloku
                                            ;         CY=operaci nelze provÇst

         mov       si,cs:[ediblkb]          ; adresa zaá†tku bloku
         mov       di,cs:[ediblkk]          ; adresa konce bloku
         test      byte ptr cs:[ediflag],8  ; je blok zapnut ?
         jz        getzncb1                 ; blok je vypnut - chyba
         cmp       si,di                    ; je zaá†tek pod koncem ?
getzncb1:cmc
         ret

; -----------------------------------------------------------------------------
public   testblok

testblok:                                 ;* test, zda je v bloku
                                            ; VSTUP: SI=adresa
                                            ; VùSTUP: CY=nen° v bloku

         test      byte ptr cs:[ediflag],8  ; je blok zapnut ?
         jz        testblk1                 ; blok je vypnut - nen° v bloku
         cmp       si,cs:[ediblkb]          ; je nad zaá†tkem bloku ?
         jb        testblk2                 ; je pod koncem bloku
         cmp       si,cs:[ediblkk]          ; je pod koncem bloku ?
testblk1:cmc
testblk2:ret

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------
public   edienter,edinl

edienter:                                 ;* konec ©†dku ^M (ENTER)
         call      edittbin                 ; je bin†rn° editace ?
         jnz       edient1                  ; je bin†rn° editace
         test      byte ptr cs:[ediflag],4  ; je zapnuto vkl†d†n° INSERT ?
         jz        edient2                  ; vkl†d†n° je zapnuto
edient1: call      edihome                  ; zaá†tek ©†dku
         jmp       edidown                  ; posun o ©†dek dolñ

edient2: call      edinl                    ; vloëen° ©†dku
         jmp       ediright                 ; posun na novò ©†dek


edinl:                                    ;* vloëen° ©†dku ^N,^J (^ENTER)
         mov       al,cs:[ediflag]          ; p©°znak vkl†d†n°
         push      ax                       ; £schova p©°znaku vkl†d†n°
         and       byte ptr cs:[ediflag],not 4 ; zapnut° funkce vkl†d†n°

         push      word ptr cs:[edikurz]    ; £schova adresy kurzoru
         push      word ptr cs:[edikpoz]    ; £schova pozice kurzoru
         mov       al,0dh
         call      ediinsch                 ; vloëen° znaku 0dh
         mov       al,0ah
         call      ediinsch                 ; vloëen° znaku 0ah
         pop       word ptr cs:[edikpoz]    ; n†vrat pozice kurzoru
         pop       word ptr cs:[edikurz]    ; n†vrat adresy kurzoru
         mov       bh,80h                   ; p©°znak p©eps†n° v®ech ©†dkñ

         pop       ax
         or        al,1                     ; p©°znak modifikace souboru
         mov       cs:[ediflag],al          ; n†vrat p©°znaku vkl†d†n°

         ret

; -----------------------------------------------------------------------------
public   ediins

ediins:                                   ;* zap/vyp vkl†d†n° ^V (INSERT)

         xor       byte ptr cs:[ediflag],4  ; zmàna indik†toru INSERT

edimodik:                                 ;* modifikace vzhledu kurzoru

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         mov       cx,cs:[edinormk]         ; uchovanò vzhled kurzoru
         test      byte ptr cs:[ediflag],4  ; je zapnuto vkl†d†n° INSERT ?
         jz        edimodk2                 ; vkl†d†n° je zapnuto
         mov       ch,cl
         sub       ch,4                     ; poá†teán° linka
edimodk2:mov       ah,1                     ; funkce nastaven° vzhledu kurzoru
         mov       bh,cs:[aktpage]          ; pracovn° videostr†nka
         int       10h                      ; nastaven° kurzoru
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
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
         call      edittbin                 ; je bin†rn° editace ?
         jnz       editab3                  ; je bin†rn° editace
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

;         call      inpkey                   ; vstup znaku z kl†vesnice


public   ediinsch

ediinsch:                                 ;* vloëen° znaku AL

         push      si
         push      di
         push      ds
         call      edigkurz                 ; poskytnut° adresy kurzoru
         cmp       si,cs:[editnum]          ; je na konci souboru ?
         jae       ediinsc0                 ; vloëen° znaku
         call      edittbin                 ; je bin†rn° editace ?
         jnz       ediinsc3                 ; je bin†rn° editace
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
         call      edittbin                 ; je bin†rn° editace ?
         jz        ediinsc2                 ; nen° bin†rn° editace
         cmp       ax,79                    ; byl kurzor na posledn° pozici ?
         jae       ediinsc4                 ; byl p©esun na novò ©†dek
         test      byte ptr cs:[ediflag],4  ; je vkl†d†n° INSERT ?
         jnz       ediinsc2                 ; vkl†d†n° nen° zapnuto
ediinsc4:mov       bh,80h                   ; p©°znak p©ekreslen° obrazovky
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
public   edidelly
edidelly:                                 ;* maz†n° po konec ©†dku ^QY

         call      edittbin                 ; je bin†rn° editace ?
         jnz       edidlly4                 ; je bin†rn° editace
         push      ds
         call      edigkurz                 ; poskytnut° adresy kurzoru
         mov       di,si                    ; £schova kurzoru
edidlly2:                                 ;* nalezen° konce ©†dku
         cmp       si,cs:[editnum]          ; je jië konec textu ?
         jae       edidlly3                 ; je konec textu
         inc       si                       ; zvò®en° adresy v bufferu
         cmp       word ptr ds:[si-1],0a0dh ; je konec ©†dku ?
         jne       edidlly2                 ; nenalezen konec ©†dku
         dec       si                       ; nastaven° konce ©†dku
edidlly3:
         pop       ds
         cmp       si,di                    ; je nàjakò znak ?
         je        edidlly4                 ; nen° ë†dnò znak k ru®en°
         call      deletemem                ; zru®en° bloku textu
         inc       bl                       ; p©°znak p©ekreslen° ©†dku
edidlly4:ret

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
         call      edittbin                 ; je bin†rn° editace ?
         jnz       edidel0                  ; je bin†rn° editace
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
         call      testakth
         jc        edidell1                 ; nen° n†povàda
         dec       cl
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
         lea       di,[firstrad]
         lea       cx,[edidrad]
         sub       cx,offset firstrad       ; poáet bajtñ tabulky
         rep       stosb                    ; vymaz†n° dat
         inc       al
         stosb                              ; nastaven° prvn°ho ©†dku
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

         call      getpocl                  ; poáet ©†dkñ bez n†povàdy
;         call      getendl
;         mov       cl,dl
;         xor       ch,ch
         dec       cx                       ; poáet ©†dkñ pro posun
edipgup1:                                 ;* nastaven° novÇho prvn°ho ©†dku
         call      setshft                  ; nucenò p©°znak SHIFT
         jmp       short edicup1            ; posun nahoru

; -----------------------------------------------------------------------------
public   edipgdn

edipgdn:                                  ;* posun o str†nku dolñ


         call      getpocl                  ; poáet ©†dkñ bez n†povàdy
;         call      getendl
;         mov       cl,dl
;         xor       ch,ch
         dec       cx                       ; poáet ©†dkñ pro posun
edipgdn0:                                 ;* zvò®en° adresy ©†dku s kurzorem
         call      setshft                  ; nucenò p©°znak SHIFT
         jmp       short edicdn1            ; posun dolñ

; -----------------------------------------------------------------------------
public   edicup

edicup:                                   ;* posun o 5 ©†dkñ nahoru

         mov       cx,6
edicup1: call      ediup
         loop      edicup1
         ret

; -----------------------------------------------------------------------------
public   edicdown

edicdown:                                 ;* posun o 5 ©†dkñ dolñ

         mov       cx,6
edicdn1: call      edidown
         loop      edicdn1
         ret

; -----------------------------------------------------------------------------
public   edimup

edimup:                                   ;* posun str†nky nahoru ^W

         call      setshft                  ; nucenò p©°znak SHIFT
         call      edidown                  ; posun dolñ s rolov†n°m
         call      resshft                  ; zru®en° nucenÇho p©°znaku SHIFT
         jc        edimup2                  ; nebyl posun kurzoru
         cmp       byte ptr cs:[edidrad],1  ; je to prvn° ©†dek ?
         je        edimup2                  ; je to prvn° ©†dek
         call      ediup                    ; n†vrat kurzoru nahoru
edimup2: ret

; -----------------------------------------------------------------------------
public   edimdown

edimdown:                                 ;* posun str†nky dolñ ^Z

         call      setshft                  ; nucenò p©°znak SHIFT
         call      ediup                    ; posun nahoru s rolov†n°m
         call      resshft                  ; zru®en° nucenÇho p©°znaku SHIFT
         jc        edimdwn2                 ; nebyl posun kurzoru
         call      getendl                  ; posledn° ©†dek
edimdwn1:cmp       cs:[edidrad],dh          ; je to posledn° ©†dek ?
         je        edimdwn2                 ; je to posledn° ©†dek
         call      edidown                  ; n†vrat kurzoru dolñ
edimdwn2:ret

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
         jz        ediup8                   ; p©ekroáen zaá†tek - rolov†n°
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
         call      getendl
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
         jnc       edidown7                 ; dal®° ©†dek nalezen OK
         cmp       al,dh
         jbe       edidown3                 ; konec nen° p©ekroáen
;         jc        edidown3                 ; nen° dal®° ©†dek - nen° rolov†n°
edidown7:mov       cs:[endrad],si           ; nastaven° novÇho posledn°ho ©†dku
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

         cmp       byte ptr cs:[edidrad],1  ; je jië horn° ©†dek ?
         je        edichm2                  ; je jië prvn° ©†dek
         call      ediup                    ; posun kurzoru nahoru
         jnc       edichome                 ; dal®° ©†dek
edichm2: ret


; -----------------------------------------------------------------------------
public   edicend

edicend:                                  ;* posun na doln° okraj ^END

         push      dx
         call      getendl                  ; posledn° ©†dek
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
         call      edittbin                 ; je bin†rn° editace ?
         jnz       edirig5                  ; je bin†rn° editace
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
         jz        edilft6                  ; je jië zaá†tek souboru
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
         call      edittbin                 ; je bin†rn° editace ?
         jnz       edidecp2                 ; je bin†rn° editace
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
;public   setdelkar
;
;setdelkar:                                ;* nastaven° dÇlky ©†dku s kurzorem
;         push      ax
;         push      si
;         mov       ax,cs:[adrradek]         ; adresa ©†dku s kurzorem
;         mov       si,ax
;         call      edisnxt0                 ; nalezen° dal®°ho ©†dku
;         jc        setdelka2                ; je konec textu
;         sub       si,2                     ; odeáten° znakñ <CR><LF>
;setdelka2:sub       si,ax                    ; rozd°l adres ©†dkñ
;         mov       cs:[delkarad],si         ; nastaven° dÇlky ©†dku
;         pop       si
;         pop       ax
;         ret
;
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
         mov       dh,1                     ; adresa prvn°ho ©†dku na displeji

         call      getpocl                  ; poáet ©†dkñ bez n†povàdy
;         mov       cx,24                    ; poáet ©†dkñ
;         call      testakth                 ; je n†povàda aktivn° ?
;         jc        editall2                 ; napovàda nen° aktivn°
;         dec       cx                       ; poáet ©†dkñ = 23
;editall2:
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

         call      mouseoff                 ; vypnut° my®i
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es
         mov       cx,100h                  ; pozice levÇho horn°ho rohu
         call      getendl                  ; posledn° ©†dek
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
         call      mouseon                  ; zapnut° my®i
         ret

; -----------------------------------------------------------------------------
public   editline

editline:                                 ;* zobrazen° jednoho ©†dku
                                            ; VSTUP: SI=zaá†tek ©†dku
                                            ;        DH=©†dek na displeji
                                            ; VùSTUP: SI=adresa konce zobrazen°

         call      mouseoff                 ; vypnut° my®i
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
         call      edittbin                 ; je bin†rn° editace ?
         jnz       editln22                 ; je bin†rn° editace
         cmp       word ptr ds:[si],0a0dh   ; je konec ©†dku ?
         je        editlin4                 ; konec ©†dku
editln22:                                 ;* nastaven° barvy zobrazen° znaku
         cmp       byte ptr ds:[si]," "     ; je ©°dic° znak ?
         mov       al,1                     ; barva textu
         jae       editln12                 ; nen° ©°dic° znak
         mov       al,15                    ; barva pro ©°dic° znak
editln12:call      testblok                 ; test, zda je v bloku
         jc        editlin1                 ; nen° v bloku
         mov       al,3                     ; negovanò text
editlin1:call      outch1                   ; nastaven° barvy podkladu

         lodsb                              ; naáten° znaku k zobrazen°
         cmp       al,32                    ; je ©°dic° znak ?
         jae       editlin3                 ; nen° ©°dic° znak - zobrazen°
         call      edittbin                 ; je bin†rn° editace ?
         jnz       editlin5                 ; je bin†rn° editace
         cmp       al,9                     ; je tabel†tor ?
         jne       editlin5                 ; nen° tabel†tor
         test      byte ptr cs:[ediflag],10h ; zobrazuj° se tabel†tory ?
         jnz       editlin5                 ; tabel†tory se nezobrazuj°
                                          ;* zobrazen° tabel†toru
         mov       al," "                   ; n†hradn° znak
editlin7:call      outch1                   ; zobrazen° znaku
         dec       cx                       ; sn°ëen° á°taáe
         jcxz      editlin8                 ; konec ©†dku
         test      dl,7                     ; je pozice tabel†toru ?
         jnz       editlin7                 ; dal®° znak
         jmp       short editlin2           ; dal®° znak
                                          ;* zobrazen° ©°dic°ho znaku
editlin5:test      byte ptr cs:[config],4   ; zobrazuje se jako CTRL ?
         jz        editlin3                 ; nezobrazuje se jako CTRL
         add       al,"@"                   ; korekce na znak ASCII
                                          ;* zobrazen° norm†ln°ho znaku
editlin3:or        al,al                    ; je znak 00 ?
         jnz       editlina                 ; nen° znak 00
         mov       al,"."                   ; n†hradn° znak
editlina:call      outch10                  ; zobrazen° znaku
editlin6:loop      editlin2                 ; dal®° znak k zobrazen°
                                          ;* vymazan° zbytku ©†dku (CX znakñ)
editlin4:call      testblok                 ; test, zda je v bloku
         mov       al,1                     ; barva textu
         jc        editlin0                 ; nen° v bloku
         mov       al,3                     ; negovanò text
editlin0:call      outch1                   ; nastaven° barvy podkladu
         mov       al," "
         call      outch                    ; vymaz†n° zbytku ©†dku
editlin8:pop       ds
         pop       di
         pop       dx
         pop       cx
         pop       ax
         call      mouseon                  ; zapnut° my®i
         ret

; -----------------------------------------------------------------------------
public   edittbin

edittbin:                                 ;* test, zda je bin†rn° editace
                                            ; VùSTUP: ZN=je bin†rn° editace

         test      byte ptr cs:[ediflag],40h ; je bin†rn° editace ?
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

         call      edittbin                 ; je bin†rn° editace ?
         jz        edispre2                 ; nen° bin†rn° editace
         sub       si,80                    ; sn°ëen° adresy o 80
         jnc       edispre3                 ; nen° je®tà
         xor       si,si
         jmp       short edispre3

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

         call      edittbin                 ; je bin†rn° editace ?
         jz        edisnxt                  ; nen° bin†rn° editace
         add       si,80                    ; zvò®en° adresy ©†dku
         jc        edisnxt1                 ; je konec bufferu
         cmp       cs:[editnum],si          ; je jië konec souboru ?
         jae       edisnxt4                 ; nen° konec souboru
edisnxt1:mov       si,cs:[editnum]
         dec       si
         stc
edisnxt4:ret


public   edisnxt

edisnxt:                                  ;* nalezen° dal®°ho ©†dku
                                            ; VSTUP: SI=pozice v textu
                                            ; VùSTUP: SI=zaá†tek dal®°ho ©†dku
                                            ;         CY=nen° dal®° ©†dek
         push      ax
         push      ds
         call      edittbin                 ; je bin†rn° editace ?
         jnz       edisnxt3                 ; je bin†rn° editace
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
public   edittop0,edittop

edittop0:                                 ;* poá†teán° zobrazen° horn°ho ©†dku

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

         call      mouseoff                 ; vypnut° my®i

         mov       al,3                     ; barva 3
         call      outch1                   ; nastaven° barvy
                                          ;* vymaz†n° horn°ho ©†dku
         xor       dx,dx                    ; poá†teán° pozice
         mov       al," "                   ; mazac° znak
         mov       cx,71                    ; poáet znakñ k tisku
         call      outch                    ; vymaz†n° ©†dku
                                          ;* zobrazen° oddàlovaáñ pol°
         mov       al,179                   ; oddàlovaá pole
         mov       dx,2
         call      outch1
         mov       dl,15
         call      outch1
         mov       dl,70
         call      outch1
         mov       dl,79
         call      outch1

         mov       byte ptr ds:[citachod],0 ; nastaven° hodin

                                          ;* zobrazen° jmÇna souboru
;         call      getakt                   ; poskytnut° aktivn°ho okna
;         mov       si,ds:[bp+4]             ; adresa p©°stupovÇ cesty
;         lodsw                              ; naáten° disku a oddàlovaáe ":"
         mov       dx,3                     ; pozice pro zobrazen° souboru
;         call      outch1                   ; zobrazen° jmÇna disku
;         mov       al,ah
;         call      outch1                   ; zobrazen° oddàlovaáe ":"
         lea       si,[buffedi]              ; uschovanÇ jmÇno souboru
;         call      getkurz                  ; poskytnut° editovanÇho souboru
;         lea       di,[outbuf]              ; pracovn° buffer
;         push      di
;         call      dekfile                  ; dek¢dov†n° jmÇna souboru
;         pop       si
;         push      cs
;         pop       ds
         call      outtxt                   ; zobrazen° jmÇna souboru
         call      mouseon                  ; zapnut° my®i
         jmp       short edittop1
                                          ;* pokraáuje dal®° zobrazen°

edittop:                                  ;* zobrazen° horn°ho ©†dku
         call      mouseoff                 ; vypnut° my®i
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es
edittop1:push      cs
         pop       ds
         push      cs
         pop       es
                                          ;* vymaz†n° bufferu
         lea       di,[outbuf]              ; vòstupn° buffer
         mov       al,3                     ; barva 3
         stosb
         push      di
         mov       cx,55                    ; dÇlka textu
         mov       al," "
         rep       stosb                    ; vymaz†n° bufferu
         pop       di                       ; ukl†dac° adresa
         or        byte ptr ds:[parnum],10h ; z†kaz tisku teáku tis°cñ
                                          ;* p©°znak modifikace textu
         test      byte ptr ds:[ediflag],1  ; byl text modifikovanò ?
         jz        edittop4                 ; text nebyl modifikov†n
         mov       al,"*"
         mov       es:[di],al
edittop4:inc       di
                                          ;* á°slo znaku nad kurzorem
         push      di
         push      ds
         call      edigkurz
         lodsw                              ; naáten° znaku nad kurzorem
         pop       ds
         dec       si
         cmp       si,cs:[editnum]          ; je jië konec souboru ?
         lea       si,[txtedi6]             ; text EOF
         ja        edittop7                 ; je konec souboru
         je        edittop6                 ; je posledn° znak
         cmp       ax,0a0dh                 ; je konec ©†dku ?
         lea       si,[txtedi5]             ; text EOL
         jne       edittop6                 ; nen° konec ©†dku
edittop7:call      transtxt                 ; uloëen° textu
         jmp       short edittop5
edittop6:xor       ah,ah                    ; AH <- 0
         xor       dx,dx                    ; DX <- 0
         call      deknum3                  ; dek¢dov†n° á°sla
edittop5:mov       al," "
         stosb
         pop       di

         add       di,3
         mov       al,179                   ; oddàlovaá pole
         stosb
                                          ;* á°slo ©†dku kurzoru
         lea       si,[txtedi2]             ; text "û†dek:"
         mov       ax,ds:[ediradek]         ; editovanò ©†dek
         inc       ax
         mov       dl,11
         call      editop9
                                          ;* pozice kurzoru
         mov       ax,ds:[edikpoz]          ; skuteán† pozice kurzoru na ©†dku
;         call      edigetk                  ; pozice kurzoru
         inc       ax
         lea       si,[txtedi3]             ; text "Pozice:"
         mov       dl,12
         call      editop9
                                          ;* absolutn° pozice kurzoru
         lea       si,[txtedi4]             ; text "Offset:"
         mov       ax,ds:[edikurz]          ; adresa kurzoru v bufferu
         mov       dl,12
         call      editop9
                                          ;* voln† kapacita
         lea       si,[txtedi1]             ; text "VolnÇ:"
         mov       ax,ds:[editmax]          ; maxim†ln° velikost bufferu
         sub       ax,ds:[editnum]          ; vòpoáet volnÇ kapacity
         dec       ax                       ; rezerva na posledn° znak
         mov       dl,11
         call      editop9

         xor       al,al
         stosb                              ; koncov† 0

         and       byte ptr cs:[parnum],0efh; povolen° tisku teáky tis°cñ

         lea       si,[outbuf]              ; vòstupn° buffer
         mov       dx,16
         call      outtxt

         mov       cl,cs:[ediflag]
         xor       dx,dx
         mov       ax,"  "
         test      cl,082h
         jz        edittop8
         mov       ax,"K^"
         test      cl,80h
         jnz       edittop8
         mov       ah,"Q"
edittop8:call      outch1
         mov       al,ah
         call      outch1

         pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      mouseon                  ; zapnut° my®i
         ret

editop9:                                  ;* poloëka nadpisu
                                            ; VSTUP: ES:DI=ukl†dac° adresa
                                            ;        DL=dÇlka poloëky
                                            ;        DS:SI=text
                                            ;        AX=á°slo
                                            ; VùSTUP: ES:DI=nov† adresa
         push      di
         push      dx
         call      transtxt                 ; text
         xor       dx,dx                    ; DX <- 0
         call      deknum5                  ; dek¢dov†n° á°sla
         mov       al," "
         stosb                              ; zru®en° koncovÇ 0
         pop       dx
         pop       di
         xor       dh,dh
         add       di,dx                    ; nov† adresa
         mov       al,179
         stosb                              ; oddàlovaá
         ret

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
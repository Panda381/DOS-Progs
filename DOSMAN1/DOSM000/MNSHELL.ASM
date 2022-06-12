; ##############################################################################
; #                                                                            #
; #                         M I N E S  -  S H E L L                            #
; #                 program pro operace se soubory a s disky                   #
; #                                                                            #
; #                  >>> Autor: ing. Miroslav Nàmeáek <<<                      #
; #                                                                 verze 0.10 #
; ##############################################################################

; ChybovÇ n†vratovÇ k¢dy:
;
;        0 - odskok do systÇmu, start programu (z prost©ed°)
;        1 - odskok do systÇmu, vyvol†n° souboru MNEXEC.BAT
;        2 - konec pr†ce programu MNSHELL (funkce EXIT)
;        3 - chyba verze operaán°ho systÇmu
;        4 - chyba grafickÇ karty
;
;

; *****************************************************************************
;
;                             Programovò segment
;
; *****************************************************************************
code     segment
         assume    cs:code,ds:data,ss:stack

public   main,init,initwin,uses,deinit,mainx,konecerr,konec0,chkver
public   initmem,initpar,charpar,initdir,readcnf,initmod,testcard
public   testmda,testvmod,setown,initint,pushscr
public   initwin,readdir,dirnul,diskread,dirread,setmem,adrfile,aktdir
public   transfile,kodfile,storfile,cmpfile,normatr,insertf,aktdisk
public   aktfile,settabf,window,topline,space,directory,obrpath,files
public   zobrfile,zobrfilz,zobrfil0,zobrfila,zobrfiln,zobrfilv,zobrfild
public   zobrfilc,endline,kurzon,kurzoff,getkurz,deinit,uses,obrcomm
public   obrcom0,obrcomt,obrcomt0,obrkurz,xchgakt,windnul,moveup
public   movedown,movehome,moveend,pageup,pagedown,insert,invsel
public   enter,testexit,insch,chleft,chright,delchar,delbs,homer,endr
public   ctrlent,xchgpg,xchgw,sethlp,outch1,outch01,outch02,outch,outch0
public   outtxt,outtx0,wrolldown,wrollup,lowcase,highcase,transtxt
public   setkonc,testkonc,readtest,center,tisknm2s,tisknm20,tisknm0
public   setspc,setnul,setfre,deknumx,deknum,deknum0,deknum9,deknum8
public   deknum7,deknum6,deknum5,deknum4,deknum3,deknum2,dekfile
public   loadpath,openex,openw,closew,writte,writex
public   errver,errcard,citdek,citnum,parnum,outbuf,texthlp,textclk
public   textsp1,textsp2,textsp20,textsp21,textsp22,textsp23
public   textsp3,textsp30,textsp4,textvy1,textvy11,textvy12,textvy13
public   textvy14,textvy2,textvy21,textvy22,txtsubd,txtupd,txtdsk,txthelp2
public   txthelp,color,all,filecnf,fileexc,txtcall,normdsk,namepath
public   flags,numchar,poztop,pozcomm,pozbuf,endadr,tabl,tabr,verze
public   segpsp,typdisp,vmod,segvram,segend,aktatr,radek,aktpage,outid
public   inpid,ukazbuf,numbuf,buftxt,diskbuf,normfil,pathhome,pathinit
public   endshell,delenv,srcenv,parenv,maxenv,setenv,selplus,selmin
public   select,selwin,setwsel,testsel,asksel,bufsel,stin,selall,selpol
public   podklad,wram1,wram2,wnadpis,stinw,obrstin,numselb,ukazsel,topsel
public   selbuf,firstsel,kurzsel,setkurzs,editsel,obredit,selwleft
public   selwright,obnov,testchar,delwl,delwr,selleft,selright,selend
public   selhome,selwleft,selwright,srcident,delselect,storesel,cmpname

main:                                     ;* start programu - hlavn° á†st
         mov       ax,seg data              ; segment dat
         mov       ds,ax                    ; nastaven° datovÇho segmentu
         mov       ds:[segpsp],es           ; £schova segmentu PSP
         mov       es,ax                    ; segment dat
         cld                                ; smàr p©enosu dat nahoru

         call      init                     ; poá†teán° inicializace programu

         cli
         mov       ax,ds:[segend]
         mov       ax,7000h
         mov       ss,ax
;         xor       ax,ax
         mov       ax,1000h
         mov       sp,ax
         sti

         call      initwin                  ; poá†teán° zobrazen° oken

         call      uses                     ; hlavn° program - povely
mainx:  ; call      storecnf                 ; uloëen° konfigurace do pamàti
;         call      savecomm                 ; uloëen° povelovÇho souboru
         call      deinit
         jmp       short konec0             ; konec programu

konecerr:                                 ;* konec programu s chybou
                                          ;* (AL=n†vrat.k¢d, DS:DX=chybovò text)
         push      ax                       ; £schova n†vratovÇho k¢du
         call      deinit                   ; deinicializace programu
         mov       ah,9                     ; funkce tisku textu na displej
         int       21h                      ; zobrazen° chybovÇho textu
         pop       ax                       ; n†vrat chybovÇho k¢du

konec0:                                   ;* konec programu (AL=n†vratovò k¢d)
         mov       ah,4ch                   ; funkce pro n†vrat z programu
         int       21h                      ; ukonáen° programu



; *****************************************************************************
;
;                             Inicializace programu
;
; *****************************************************************************

init:                                     ;* poá†teán° inicializace programu

         call      chkver                   ; kontrola verze operaán°ho systÇmu
         call      initmem                  ; inicializace pamàti (alokace)
         call      initpar                  ; inicializace parametrñ (zad†n°)
         call      initdir                  ; nastaven° adres†©ñ - inicializace
         call      readcnf                  ; áten° konfiguraán°ho souboru
         call      srcenv                   ; nalezen° otcovskÇho prost©ed°
;         call      delenv                   ; zru®en° ©etàzce EXE.. z prost©ed°
         call      initmod                  ; inicializace videom¢du
         call      initint                  ; inicializace obsluh p©eru®en°
         call      pushscr                  ; uloëen° obsahu obrazovky
         ret


; -----------------------------------------------------------------------------
;                     Kontrola verze operaán°ho systÇmu
; -----------------------------------------------------------------------------

chkver:                                   ;* kontrola verze operaán°ho systÇmu
                                            ; zniáenÇ registry: AX

         mov       ah,30h                   ; funkce poskytnut° á°sla verze OS
         int       21h                      ; poskytnut° á°sla verze OS
         xchg      al,ah                    ; z†màna á°sla verze a podverze
         mov       [verze],ax               ; £schova á°sla verze OS
         cmp       ax,200h                  ; je verze alespo§ 2.00 ?
         jb        chkver1                  ; je chyba á°sla verze systÇmu
         ret
                                          ;* chyba verze operaán°ho systÇmu
chkver1: pop       ax                       ; zru®en° n†vratu do INIT
         pop       ax                       ; zru®en° n†vratu do hlavn°ho prog.
         mov       al,3                     ; k¢d chyby verze operaán°ho systÇmu
         mov       dx,offset errver         ; text chyby verze operaán°ho syst.
         jmp       konecerr                 ; chybovò n†vrat z programu

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

initmem:                                  ;* inicializace pamàti (alokace)

                                          ;* £schova volnÇ kapacity pamàti
         push      ds                       ; £schova DS
         mov       ds,ds:[segpsp]           ; segment PSP
         mov       ax,ds:[2]                ; segment konce p©idàlenÇho bloku
         pop       ds                       ; n†vrat DS
         mov       ds:[segend],ax           ; segment konce p©idàlenÇho bloku
         ret

; -----------------------------------------------------------------------------
;                  Inicializace parametrñ z p©°kazovÇho ©†dku
; -----------------------------------------------------------------------------

initpar:                                  ;* inicializace parametrñ z p©°k. ©†d.
                                            ; zniáenÇ registry: AX,CX,SI,DI

         cld
         push      ds                       ; £schova DS
         mov       ds,ds:[segpsp]           ; segment PSP
         mov       si,81h                   ; p©°kazovò ©†dek
         xor       ch,ch                    ; CH <- 0
         mov       cl,ds:[si-1]             ; dÇlka ©etàzce p©°kazovÇho ©†dku
         jcxz      initpr3                  ; nen° zad†n ë†dnò parametr
         mov       di,offset pathl
;         mov       di,offset filecnf        ; jmÇno konfiguraán°ho souboru
                                          ;* nalezen° zaá†tku textu
initpr1: call      charpar                  ; naáten° znaku z p©°kaz. ©†dku
         jc        initpr3                  ; je konec ©†dku
         jz        initpr1                  ; test dal®°ho znaku
                                          ;* p©enos jmÇna souboru
initpr2: call      highcase                 ; p©evod na velkÇ p°smeno
         stosb                              ; uloëen° znaku
         call      charpar                  ; naáten° dal®°ho znaku z p©°k. ©†d.
         ja        initpr2                  ; nen° oddàlovaá ani konec - uloëen°
         xor       al,al                    ; ukonáovac° bajt 0
         stosb                              ; uloëen° ukonáovac°ho bajtu 0
initpr3: pop       ds                       ; n†vrat DS
         ret

; -----------------------------------------------------------------------------

charpar:                                  ;* naáten° znaku z p©°kaz. ©†dku
                                            ; VSTUP: CX=á°taá znakñ
                                            ;        DS:SI=ukazatel textu
                                            ; VùSTUP: CY=je konec textu
                                            ;         ZY=je oddàlovac° znak

         stc                                ; p©°znak konce textu
         jcxz      charpr1                  ; je konec textu p©°kaz. ©†dku
         lodsb                              ; naáten° znaku
         dec       cx                       ; sn°ëen° á°taáe znakñ
         cmp       al," "                   ; je oddàlovac° mezera ?
         je        charpr1                  ; je oddàlovac° mezera
         cmp       al,9                     ; je tabel†tor ?
         je        charpr1                  ; je oddàlovac° tabel†tor
         cmp       al,"/"                   ; je oznaáen° parametrñ ?
         je        charpr1                  ; je oznaáen° parametrñ
         clc                                ; maz†n° p©°znaku konce textu
charpr1: ret

; -----------------------------------------------------------------------------
;                  Inicializace adres†©ñ (p©°stupovòch cest)
; -----------------------------------------------------------------------------

initdir:                                  ;* nastaven° adres†©ñ - inicializace
                                            ; zniáenÇ registry: AX,CX,SI,DI

         cld
         push      ds                       ; £schova DS
         mov       di,offset pathinit       ; inicializaán° aktivn° cesta
         call      loadpath                 ; naáten° aktivn° cesty
         mov       di,offset pathl          ; cesta k levÇmu adres†©i
         cmp       byte ptr ds:[di],0
         jne       initdr01
         call      loadpath                 ; naáten° aktivn° cesty
initdr01:mov       di,offset pathr          ; cesta k pravÇmu adres†©i
         call      loadpath                 ; naáten° aktivn° cesty
         cmp       word ptr ds:[verze],300h ; je verze 3.00 nebo vy®®° ?
         jb        initdr4                  ; je nië®° verze neë 3.00
         mov       ds,ds:[segpsp]           ; segment PSP
         mov       ds,ds:[2ch]              ; segment prost©ed°
         mov       cx,7fffh                 ; maxim†ln° dÇlka prost©ed°
         xor       si,si                    ; poá†teán° offset prost©ed°
initdr1: cmp       word ptr ds:[si],0       ; je konec prost©ed° ?
         je        initdr2                  ; je konec prost©ed°
         inc       si                       ; zvò®en° adresy textu
         loop      initdr1                  ; test dal®°ho znaku
         jmp       short initdr4            ; chyba - nenalezen konec
initdr2: inc       si
         inc       si                       ; poáet ©etàzcñ
         cmp       word ptr ds:[si],8       ; je velkò poáet ©etàzcñ ?
         ja        initdr4                  ; je velkò poáet ©etàzcñ
         inc       si
         inc       si                       ; zaá†tek ©etàzce
         mov       di,offset pathhome       ; cesta k domovskÇmu adres†©i
         mov       cx,127                   ; maxim†ln° dÇlka cesty
         push      di                       ; £schova adresy zaá†tku textu
initdr3: lodsb                              ; naáten° znaku ©etàzce
         stosb                              ; uloëen° znaku
         cmp       al,"\"                   ; je oznaáen° adres†©e ?
         jne       initdr31                 ; nen° znak adres†©e
         add       sp,2                     ; zru®en° adresy textu
         push      di                       ; uloëen° novÇ adresy konce textu
initdr31:or        al,al                    ; je jië konec ©etàzce ?
         jnz       initdr32                 ; nen° je®tà konec ©etàzce
         pop       di                       ; n†vrat adresy konce ©etàzce
         dec       di
         stosb                              ; uloëen° koncovÇho bajtu 0
         jmp       short initdr5            ; konec ©etàzce
initdr32:loop      initdr3                  ; p©enos dal®°ho znaku
         pop       di
initdr4:                                  ;* nestandardn° naáten° dom. cesty
         mov       di,offset pathhome       ; cesta k domovskÇmu adres†©i
         call      loadpath                 ; naáten° cesty k domovskÇmu adr.
initdr5: pop       ds                       ; n†vrat DS
         ret

; -----------------------------------------------------------------------------
;                     Äten° souboru konfigurace
; -----------------------------------------------------------------------------

readcnf:                                  ;* áten° konfiguraán°ho souboru
         ret

; -----------------------------------------------------------------------------
;                  Nastaven° videom¢du, test displeje
; -----------------------------------------------------------------------------

initmod:                                  ;* inicializace videom¢du

         call      testvmod                 ; test nastavenÇho videom¢du
         jnc       initmd1                  ; videom¢d je nastaven spr†vnà
         mov       ax,3                     ; poëadovanò videom¢d 3
         int       10h                      ; nastaven° videom¢du 3
         call      testvmod                 ; test nastavenÇho videom¢du
         jnc       initmd1                  ; videom¢d je nastaven spr†vnà
         mov       ax,2                     ; poëadovanò videom¢d 2
         int       10h                      ; nastaven° videom¢du 2
         call      testvmod                 ; test nastavenÇho videom¢du
         jnc       initmd1                  ; videom¢d je nastaven spr†vnà
         mov       ax,7                     ; poëadovanò videom¢d 7
         int       10h                      ; nastaven° videom¢du 7
         call      testvmod                 ; test nastavenÇho videom¢du
         jnc       initmd1                  ; videom¢d je nastaven spr†vnà
         pop       ax                       ; zru®en° n†vratu do INIT
         pop       ax                       ; zru®en° n†vratu do hlavn°ho prog.
         mov       al,4                     ; k¢d chyby grafickÇ karty
         mov       dx,offset errcard        ; text chyby grafickÇ karty
         jmp       konecerr                 ; chybovò n†vrat z programu
initmd1:
         mov       ds:[vmod],al             ; uloëen° aktivn°ho videom¢du
         mov       ds:[segvram],dx          ; adresa segmentu VRAM
         mov       ds:[aktpage],3           ; aktivn° str†nka = 1
         mov       ah,3                     ; dotaz na pozici kurzoru
         xor       bh,bh                    ; str†nka 0
         int       10h                      ; poskytnut° pozice kurzoru
         mov       ds:[radek],dh            ; £schova ©†dku s kurzorem
         mov       ah,5                     ; funkce nastaven° str†nky displeje
         mov       al,ds:[aktpage]          ; poëadovan† str†nka
         and       al,1
         int       10h                      ; nastaven° str†nky displeje 1
initmd11:call      testcard                 ; test videokarty
         cmp       byte ptr ds:[vmod],2     ; je videom¢d 2 ?
         je        initmd2                  ; je videom¢d 2
         cmp       byte ptr ds:[vmod],3     ; je videom¢d 3 ?
         jne       initmd4                  ; nen° ani videom¢d 3
initmd2: cmp       byte ptr ds:[typdisp],1  ; je displej CGA ?
         je        initmd3                  ; je displej CGA
         cmp       byte ptr ds:[typdisp],3  ; je displej EGA ?
         jne       initmd4                  ; nen° ani displej EGA
initmd3: call      setown                   ; nastaven° vlastn° obsluhy displeje
initmd4: mov       ah,8
         xor       bh,bh
         int       10h
         mov       ds:[aktatr],ah           ; atribut znaku
         call      obrcomm
         call      obrkurz
         ret


; -----------------------------------------------------------------------------

testcard:                                 ;* test (rozpozn†n°) videokarty
                                            ; zniáenÇ registry: AX,BX

         mov       ah,12h                   ; funkce alternativ. nastaven° EGA
         mov       bl,10h                   ; podsluëba - informace o EGA
         int       10h                      ; poskytnut° informac° o EGA
         cmp       bl,10h                   ; funkce nen° podporov†na ?
         je        testcr1                  ; funkce nen° podporov†na (nen° EGA)
         mov       byte ptr ds:[typdisp],3  ; je grafick† karta EGA
         ret
testcr1: mov       al,ds:[vmod]             ; aktivn° videom¢d
         cmp       al,7                     ; je textovò reëim MDA ?
         jne       testcr2                  ; nen° textovò reëim MDA - je CGA
         call      testmda                  ; test grafickÇ karty MDA
         jz        testcr2                  ; nen° grafick† karta MDA
         mov       byte ptr ds:[typdisp],2  ; je grafick† karta MDA
         ret
testcr2: mov       byte ptr ds:[typdisp],1  ; je grafick† karta CGA
         ret

; -----------------------------------------------------------------------------

testmda:                                  ;* test grafickÇ karty MDA
                                          ;* VùSTUP: ZY=nen° karta MDA

         push      ds                       ; £schova registru DS
         push      dx                       ; £schova registru DX
         push      cx                       ; £schova registru CX
         xor       ax,ax                    ; AX <- 0000
         mov       ds,ax                    ; DS <- 0000
         mov       dx,ds:[463h]             ; b†zov† ©°dic° adresa displeje
         and       dl,0f0h                  ; z†klad adresy
         or        dl,0ah                   ; adresa stavovÇho registru
         mov       cx,2000h                 ; maxim†ln° doba pro test impulsu
testmda1:in        al,dx                    ; vstup ze stavovÇho registru
         test      al,80h                   ; je synchronizaán° impuls MDA ?
         jz        testmda2                 ; p©i®el impuls - je karta MDA
         loop      testmda1                 ; dal®° áek†n° na impuls MDA
testmda2:or        cx,cx                    ; bylo p©eteáen° áekac° smyáky ?
         pop       cx                       ; n†vrat registru CX
         pop       dx                       ; n†vrat registru DX
         pop       ds                       ; n†vrat registru DS
         ret

; -----------------------------------------------------------------------------

testvmod:                                 ;* test videom¢du
                                            ; VùSTUP: CY=nespr†vnò videom¢d
                                            ;         AL=videom¢d
                                            ;         DX=segment videopamàti

         mov       ah,0fh                   ; funkce dotazu na videom¢d
         int       10h                      ; dotaz na nastavenò videom¢d
         mov       dx,0b800h                ; segment videopamàti EGA,CGA
         cmp       al,2                     ; je videom¢d 2 ?
         je        testvm1                  ; je videom¢d 2 - OK
         cmp       al,3                     ; je videom¢d 3 ?
         je        testvm1                  ; je videom¢d 3 - OK
         cmp       al,7                     ; je videom¢d 7 ?
         jne       testvm2                  ; nen° videom¢d 7
         mov       dh,0b0h                  ; segment videopamàti MDA
testvm1: or        bh,bh                    ; je str†nka 0 ?
         jnz       testvm2                  ; nen° str†nka 0
         cmp       ah,80                    ; je poáet pozic na ©†dek 80 ?
         jne       testvm2                  ; nen° 80 znakñ na ©†dek
         ret
testvm2: stc                                ; p©°znak - nespr†vnò videom¢d
         ret

; -----------------------------------------------------------------------------

setown:                                   ;* nastaven° vlastn° obsluhy displeje

         mov       ax,offset(outch01-setout)-3
         mov       word ptr cs:[setout+1],ax ; instrukce skoku
         ret


; -----------------------------------------------------------------------------
;                   Instalace vlastn°ch obsluh p©eru®en°
; -----------------------------------------------------------------------------

initint:                                    ; inicializace obsluh p©eru®en°
         ret

; -----------------------------------------------------------------------------
;                       £schova obsahu obrazovky
; -----------------------------------------------------------------------------

pushscr:                                    ; inicializace obsluh p©eru®en°
         ret


; *****************************************************************************
;
;                          Poá†teán° zobrazen° oken
;
; *****************************************************************************

initwin:                                  ;* poá†teán° zobrazen° oken
                                            ; zniáenÇ registry: BP

         mov       bp,offset tabr           ; tabulka definice okna
         call      readdir                  ; aktualizace - naáten° adres†©ñ
         call      window                   ; zobrazen° okna
         mov       bp,offset tabl           ; tabulka definice okna
         call      readdir                  ; aktualizace - naáten° adres†©ñ
         call      window                   ; zobrazen° okna
         ret


; -----------------------------------------------------------------------------
;                            Naáten° adres†©e
; -----------------------------------------------------------------------------

readdir:                                  ;* aktualizace - naáten° adres†©e
                                            ; VSTUP: BP=ukazatel okna

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         call      dirnul                   ; vynulov†n° adres†©e
         call      diskread                 ; naáten° platnòch diskñ
         call      dirread                  ; naáten° novÇho adres†©e
         call      aktdisk                  ; aktualizace parametrñ disku
         call      aktfile                  ; aktualizace kapacity souborñ
         call      settabf                  ; nastaven° ukazatelñ tabulky
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------

dirnul:                                   ;* vynulov†n° adres†©e
                                            ; VSTUP: BP=adresa okna
                                            ; zniáenÇ reg.: CX,SI,DI

         cld                                ; smàr posunu ukazatele nahoru
         mov       di,ds:[adrfr]            ; offset pravÇho okna
         mov       si,ds:[adrfl]            ; offset levÇho okna
         test      byte ptr ds:[bp+flagsl-tabl],4 ; je levÇ okno ?
         jz        dirout1                  ; je pravÇ okno
         xchg      si,di
                                          ;* DI-vypou®.adres†©, SI-druhò adres†©
dirout1: cmp       di,si                    ; je novò adres†© DI n°ë neë SI ?
         ja        dirout2                  ; novò adres†© je vò® - OK
         push      di                       ; £schova adresy adres.
         mov       cx,ds:[endadr]           ; adresa konce pamàti
         sub       cx,si                    ; dÇlka dat druhÇho adres†©e SI
         rep       movsb                    ; p©enos druhÇho adres†©e SI->DI
         pop       si                       ; adresa druhÇho adres†©e
dirout2: mov       ds:[endadr],di           ; nov† adresa konce pamàti
         test      byte ptr ds:[bp+flagsl-tabl],4 ; je levÇ okno ?
         jz        dirout3                  ; je pravÇ okno
         xchg      si,di
dirout3: mov       ds:[adrfr],di            ; nov† adresa pravÇho adres†©e
         mov       ds:[adrfl],si            ; nov† adresa levÇho adres†©e
         mov       word ptr ds:[bp+numfl-tabl],0 ; poáet souborñ
         ret

; -----------------------------------------------------------------------------

diskread:                                 ;* naáten° diskñ v systÇmu
                                            ; VSTUP: BP=adresa okna
                                            ; zniáenÇ reg.: AX,BX,CX,DX,SI,DI

         xor       dl,dl                    ; á°slo disku
         xor       bx,bx                    ; á°taá diskñ
         mov       cx,30                    ; maxim†ln° poáet diskñ
diskrd1: mov       ah,0eh                   ; funkce vòbàru aktivn°ho disku
         int       21h                      ; vòbàr aktivn°ho disku DL
         mov       ah,19h                   ; funkce poskytnut° aktivn°ho disku
         int       21h                      ; poskytnut° aktivn°ho disku
         cmp       al,dl                    ; kontrola á°sla disku
         jne       diskrd4                  ; nen° platnò disk
                                          ;* uloëen° oznaáen° disku
         push      dx
         push      cx
         mov       si,offset normdsk        ; oznaáen° disku
         add       al,"A"                   ; korekce á°sla disku na znak ASCII
         mov       ds:[si+6],al             ; uloëen° oznaáen° disku
         mov       di,offset normfil        ; normalizovanò soubor
         mov       cx,12                    ; dÇlka poloëky
         rep       movsb                    ; p©enos poloëky
diskrd2: call      setmem                   ; nastaven° konce pamàti
         jc        diskrd3                  ; p©ekroáen° konce pamàti
         push      bx                       ; £schova á°taáe poloëek
         call      storfile                 ; uloëen° poloëky do seznamu adres.
         pop       bx                       ; n†vrat á°taáe poloëek
         inc       bx                       ; zvò®en° á°taáe poloëek
diskrd3: pop       cx
         pop       dx

diskrd4: inc       dl                       ; zvò®en° á°sla disku
         loop      diskrd1                  ; nastaven° dal®°ho disku
         mov       ds:[bp+numfl-tabl],bx    ; uloëen° poátu diskñ
         ret


; -----------------------------------------------------------------------------

dirread:                                  ;* naáten° novÇho adres†©e
                                            ; VSTUP: BP=adresa okna
                                            ; zniáenÇ reg.: AX,BX,CX,DX,SI,DI

         lea       si,ds:[bp+pathl-tabl]    ; cesta k adres†©i
         call      aktdir                   ; nastaven° aktivn°ho adres†©e okna
         mov       bx,ds:[bp+numfl-tabl]    ; poáet uloëenòch souborñ
         mov       cx,16h                   ; atribut pro hled†n° poloëek
         mov       dx,offset all            ; specifikace - v®echny soubory
         mov       ah,4eh                   ; funkce nalezen° prvn° poloëky
                                          ;* zaá†tek cyklu naá°t†n° poloëek
dirrd2:  int       21h                      ; naáten° poloëky adres†©e
         jc        dirrd5                   ; nen° dal®° poloëka
                                          ;* kontrola, zda to nen° adres. "."
         push      ds                       ; £schova DS
         mov       ds,ds:[segpsp]           ; adresa segmentu PSP
         mov       ax,ds:[95h]              ; atributy nalezenÇ poloëky
         test      al,10h                   ; byl nalezen adres†© ?
         mov       ax,word ptr ds:[9eh]     ; prvn° 2 znaky jmÇna souboru
         pop       ds                       ; n†vrat DS
         jz        dirrd3                   ; nen° to adres†©
         cmp       ax,"."                   ; je to oznaáen° aktiv. adres†©e ?
         je        dirrd4                   ; je aktivn° adres†© - neuloë° se
                                          ;* uloëen° souboru do seznamu
dirrd3:  call      setmem                   ; nastaven° konce pamàti
         jc        dirrd5                   ; p©ekroáen° konce pamàti
         push      bx
         call      transfile                ; p©enos parametrñ souboru
         call      storfile                 ; uloëen° poloëky do seznamu adres.
         pop       bx
         inc       bx                       ; zvò®en° á°taáe poloëek
dirrd4:  mov       ah,4fh                   ; funkce nalezen° dal®° poloëky
         jmp       short dirrd2             ; nalezen° dal®° poloëky
dirrd5:                                   ;* konec naá°t†n° souborñ
         mov       ds:[bp+numfl-tabl],bx    ; poáet souborñ
         xor       ax,ax                    ; AX <- 0
         mov       ds:[bp+insfil-tabl],ax   ; nastaven° poátu oznaáenòch souborñ
         mov       ds:[bp+kapfil-tabl],ax   ; nastaven° zabranÇ kapacity soubory
         mov       ds:[bp+2+(kapfil-tabl)],ax ; - " - (vy®®° slovo)
         ret

; -----------------------------------------------------------------------------

setmem:                                   ;* nastaven° konce pamàti
                                            ; VSTUP: BX=á°slo novÇ poloëky
                                            ;        BP=ukazatel tabulky okna
                                            ; VùSTUP: CY=p©ekroáen konec pamàti
                                            ; zniáenÇ registry: AX,SI

         mov       ax,20                    ; dÇlka 1 poloëky
         mul       bx                       ; offset poloëky v seznamu
         mov       si,ds:[bp+adrfl-tabl]    ; adresa zaá†tku tabulky
         add       si,20                    ; konec poloëky
         add       si,ax                    ; adresa poloëky (CY=p©eteáen°)
         jc        setmem1                  ; p©eteáen°
         mov       ds:[endadr],si           ; nov† adresa konce pamàti
setmem1: ret


; -----------------------------------------------------------------------------

adrfile:                                  ;* adresa poloëky v seznamu
                                            ; VSTUP: BX=á°slo poloëky
                                            ;        BP=ukazatel tabulky okna
                                            ; VùSTUP: SI=adresa poloëky
                                            ;         CY=neplatnÇ á°slo poloëky

         push      ax
         push      bx
         push      dx
         mov       ax,bx
         inc       ax
         cmp       ds:[bp+numfl-tabl],ax    ; kontrola á°sla poloëky
         jc        adrfil1                  ; nespr†vnÇ á°slo poloëky
         dec       ax
         mov       bx,20
         mul       bx
         mov       si,ds:[bp+adrfl-tabl]    ; adresa zaá†tku tabulky
         add       si,ax                    ; adresa poloëky (CY=p©eteáen°)
adrfil1: pop       dx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------

aktdir:                                   ;* nastaven° aktivn°ho adres†©e
                                            ; VSTUP: DS:SI=p©°stupov† cesta
                                            ; VùSTUP: CY=chyba

         push      dx                       ; £schova DX
         push      ax                       ; £schova AX
         cmp       byte ptr ds:[si+1],":"   ; je ud†n disk ?
         jne       aktdir1                  ; nen° ud†n disk
         mov       al,ds:[si]               ; oznaáen° disku
         call      highcase                 ; p©evod na velkÇ p°smeno
         sub       al,"A"                   ; p©evod na á°slo disku
         mov       dl,al                    ; poëadovanò disk
         mov       ah,0eh                   ; funkce nastaven° disku
         int       21h                      ; nastaven° aktivn°ho disku
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

transfile:                                  ; p©enos jmÇna souboru
                                            ; zniáenÇ reg.: AX,BX,CX,DX,SI,DI

         push      ds                       ; £schova DS
         mov       ds,ds:[segpsp]           ; adresa segmentu PSP
         mov       di,offset normfil        ; ukl†dac° adresa
         mov       si,95h                   ; atribut nalezenÇho souboru
         lodsb                              ; atribut souboru
         stosb                              ; p©enos atributu poloëky
         mov       si,9eh                   ; jmÇno nalezenÇho souboru
         call      kodfile                  ; zak¢dov†n° jmÇna souboru
         add       di,11                    ; zvò®en° ukl†dac° adresy
         mov       si,9ah                   ; velikost souboru
         movsw                              ; nië®° slovo velikosti souboru
         movsw                              ; p©enos velikosti souboru
         mov       si,98h                   ; datum souboru
         movsw                              ; p©enos data souboru
         mov       si,96h                   ; áas souboru
         movsw                              ; p©enos áasu souboru
         pop       ds                       ; n†vrat DS
         ret

; -----------------------------------------------------------------------------

kodfile:                                  ;* zak¢dov†n° jmÇna souboru
                                            ; VSTUP: DS:SI=jmÇno souboru ASCIIZ
                                            ;        ES:DI=jmÇno v pevnÇm k¢du

         push      ax
         push      cx
         push      si
         push      di
         mov       cx,8                     ; poáet znakñ jmÇna souboru
         mov       ax,ds:[si]               ; prvn° dva znaky jmÇna
         cmp       ax,".."                  ; je nad©azenò adres†© ".." ?
         jne       kodfi1                   ; nen° nad©azenò adres†© ".."
         stosw                              ; uloëen° textu ".."
         mov       al," "                   ; mezera
         mov       cl,9                     ; poáet mezer k uloëen°
         rep       stosb                    ; doplnàn° mezerami
         jmp       short kodfi6             ; n†vrat z podprogramu
kodfi1:  lodsb                              ; naáten° znaku jmÇna
         or        al,al                    ; je konec jmÇna ?
         jz        kodfi2                   ; je konec jmÇna
         cmp       al,"."                   ; je oznaáen° extentu ?
         jnz       kodfi3                   ; nen° oznaáen° extentu
kodfi2:  mov       al," "                   ; n†hradn° znak mezery
         dec       si                       ; n†vrat átec° adresy
kodfi3:  stosb                              ; uloëen° jmÇna souboru
         loop      kodfi1                   ; p©enos dal®°ho znaku jmÇna
         mov       cl,3                     ; poáet znakñ extentu
kodfi4:  lodsb                              ; naáten° znaku jmÇna
         cmp       al,"."                   ; je oznaáen° extentu ?
         jz        kodfi4                   ; ignorov†n° oznaáen° extentu
         or        al,al                    ; je konec jmÇna ?
         jnz       kodfi5                   ; nen° konec jmÇna
         mov       al," "                   ; n†hradn° znak mezery
         dec       si                       ; n†vrat átec° adresy
kodfi5:  stosb                              ; uloëen° jmÇna souboru
         loop      kodfi4                   ; p©enos dal®°ho znaku jmÇna
kodfi6:  pop       di
         pop       si
         pop       cx
         pop       ax
         ret


; -----------------------------------------------------------------------------

storfile:                                 ;* uloëen° souboru do seznamu
                                            ; VSTUP: BP=ukazatel tabulky okna
                                            ;        BX=poáet uloëenòch souborñ
                                            ; zniëenÇ registry: AX,CX,SI,DI

         mov       cx,bx                    ; poáet uloëenòch souborñ
         mov       di,ds:[bp+adrfl-tabl]    ; adresa seznamu adres†©e
         mov       si,offset normfil        ; ukl†danò soubor
         jcxz      storf2                   ; nen° ë†dnò soubor
storf1:  call      cmpfile                  ; porovn†n° souborñ SI,DI
         jb        storf2                   ; soubor je men®° - uloëen°
         add       di,20                    ; zvò®en° adresy v bufferu
         loop      storf1                   ; test dal®°ho souboru
storf2:  call      insertf                  ; vloëen° souboru do seznamu
         ret

; -----------------------------------------------------------------------------

cmpfile:                                    ; porovn†n° souborñ DS:SI a ES:DI
                                            ; VSTUP: ES:DI,DS:SI=soubory
                                            ; zniëenÇ registry: AX

         push      cx
         push      si
         push      di
         mov       al,[di]                  ; atribut souboru 2
         call      normatr                  ; normalizace atributu 2
         xchg      ah,al                    ; AH <- atribut souboru 2
         mov       al,[si]                  ; atribut souboru 1
         call      normatr                  ; normalizace atributu 1
         cmp       ah,al                    ; porovn†n° atributñ 2 a 1
         jne       cmpfil2                  ; atributy nejsou shodnÇ
         mov       cx,11                    ; poáet znakñ jmÇna a extentu
         inc       si                       ; adresa jmÇna souboru 1
         inc       di                       ; adresa jmÇna souboru 2
         repe      cmpsb                    ; porovn†n° jmen
cmpfil2: pop       di
         pop       si
         pop       cx
         ret

; -----------------------------------------------------------------------------

normatr:                                    ; normalizace atributu
                                            ; VSTUP: AL=atribut souboru

         push      bx
         mov       bl,al                    ; £schova atributu
         shl       al,1                     ; AL * 2
         and       al,4                     ; ponech† bit 2 (=bit 1)
         or        al,bl                    ; atribut souboru
         and       al,54h                   ; ponech† bity 6, 4 a 2
         test      al,50h                   ; je disk nebo adres†© ?
         jz        normatr1                 ; nen° disk ani adres†©
         and       al,50h                   ; zru®en° p©°znaku HID a SYS
normatr1:pop       bx
         ret

; -----------------------------------------------------------------------------

insertf:                                    ; vloëen° souboru SI
                                            ; VSTUP: ES:DI=ukl†dac° adresa
                                            ;        DS:SI=soubor
                                            ; zniáenÇ reg.: CX,SI,DI

         push      si                       ; adresa souboru
         push      di                       ; ukl†dac° adresa
         mov       si,ds:[endadr]           ; novò konec pamàti
         sub       si,20                    ; novò konec pamàti - 20
         mov       cx,si                    ; novò konec pamàti - 20
         sub       cx,di                    ; poáet bajtñ k p©esunu
         mov       di,ds:[endadr]           ; novò konec pamàti
         std                                ; smàr posunu ukazatele dolñ
         dec       si                       ; korekce na konec dat
         dec       di                       ; korekce na konec dat
         rep       movsb                    ; p©enos zbytku pamàti (INSERT)
         cld                                ; smàr posunu ukazatele nahoru
         pop       di                       ; n†vrat ukl†dac° adresy
         pop       si                       ; n†vrat adresy souboru
         mov       cl,20                    ; dÇlka poloëky souboru
         rep       movsb                    ; p©enos - uloëen° poloëky souboru
         ret

; -----------------------------------------------------------------------------
;                        Aktualizace parametrñ disku
; -----------------------------------------------------------------------------

aktdisk:                                  ;* aktualizace kapacity aktiv. disku
                                            ; VSTUP: BP=adresa tabulky parametrñ
                                            ; zniáenÇ reg.: AX,BX,CX,DX,SI,DI

         lea       di,ds:[bp+alokl-tabl]    ; zaá†tek parametrñ disku
         mov       ah,36h                   ; funkce poskytnut° kapacity disku
         mov       dl,0                     ; aktivn° disk
         int       21h                      ; poskytnut° kapacity disku
         push      bx                       ; poáet volnòch alokaán°ch blokñ
         push      dx                       ; celkovò poáet alokaán°ch blokñ
         mul       cx                       ; vòpoáet kapacity alokaán°ho bloku
         stosw                              ; uloëen° kapacity alokaán°ho bloku
         mov       cx,ax                    ; £schova kapacity alokaán°ho bloku
         pop       ax                       ; celkovò poáet alokaán°ch blokñ
         mul       cx                       ; vòpoáet celkovÇ kapacity disku
         stosw                              ; nië®° slovo kapacity disku
         mov       ax,dx                    ; vy®®° slovo kapacity disku
         stosw                              ; vy®®° slovo kapacity disku
         pop       ax                       ; poáet volnòch alokaán°ch blokñ
         mul       cx                       ; vòpoáet volnÇ kapacity disku
         stosw                              ; nië®° slovo volnÇ kapacity disku
         mov       ax,dx                    ; vy®®° slovo volnÇ kapacity disku
         stosw                              ; vy®®° slovo volnÇ kapacity disku
         ret

; -----------------------------------------------------------------------------
;                  Aktualizace obsazenÇ kapacity v adres†©i
; -----------------------------------------------------------------------------

aktfile:                                  ;* zji®tàn° kapacity v adres†©i
                                            ; VSTUP: BP=adresa tabulky parametrñ
                                            ; zniáenÇ reg.: AX,BX,CX,DX,SI,DI

         lea       di,ds:[bp+soubl-tabl]    ; zaá†tek parametrñ souborñ
         mov       bx,ds:[bp+alokl-tabl]    ; velikost alokaán°ho bloku
         xor       ax,ax                    ; AX <- 0
         push      di                       ; £schova ukl†dac° adresy
         stosw                              ; poáet souborñ = 0
         stosw                              ; kapacita souborñ (LOW) = 0
         stosw                              ; kapacita souborñ (HIGH) = 0
         pop       di                       ; n†vrat ukl†dac° adresy
         mov       cx,ds:[bp+numfl-tabl]    ; celkovò poáet souborñ v adres†©i
         jcxz      aktfil3                  ; nen° ë†dnò soubor
         mov       si,ds:[bp+adrfl-tabl]    ; adresa seznamu adres†©e
                                          ;* zaá†tek smyáky sá°t†n° kapacity
aktfil1: test      byte ptr ds:[si],50h     ; je adres†© nebo disk ?
         jnz       aktfil2                  ; je adres†© nebo disk - dal®° soub.
         inc       word ptr ds:[di]         ; zvò®en° á°taáe souborñ
         mov       ax,ds:[si+12]            ; nië®° slovo velikosti
         mov       dx,ds:[si+14]            ; vy®®° slovo velikosti
aktfil4: or        dx,dx                    ; je DX=0 ?
         jnz       aktfil5                  ; DX nen° 0
         or        ax,ax                    ; je AX=0 ?
         jz        aktfil2                  ; AX i DX je = 0
aktfil5: add       word ptr es:[di+2],bx    ; p©iáten° alokaán°ho bloku k souátu
         adc       word ptr es:[di+4],0     ; p©enos do vy®®°ho slova
         sub       ax,bx                    ; odeáten° od nië®°ho slova
         sbb       dx,0                     ; odeáten° p©enosu
         jnc       aktfil4                  ; nen° je®tà p©eteáen°
aktfil2: add       si,20                    ; zvò®en° adresy souboru
         loop      aktfil1                  ; dal®° soubor
aktfil3: ret

; -----------------------------------------------------------------------------
;                    Nastaven° ukazatelñ tabulky souborñ
; -----------------------------------------------------------------------------

settabf:                                  ;* nastaven° ukazatelñ tabulky souborñ
                                            ; VSTUP: BP=adresa tabulky parametrñ
                                            ; zniáenÇ registry:AX,BX,CX,DX,SI,DI

         mov       di,offset outbuf         ; tiskovò buffer
         mov       si,offset namepath       ; jmÇno adres†©e
         push      di                       ; tiskovò buffer
         call      kodfile                  ; zak¢dov†n° jmÇna souboru
         pop       si                       ; tiskovò buffer
         mov       cx,ds:[bp+numfl-tabl]    ; poáet souborñ
         mov       di,ds:[bp+adrfl-tabl]    ; adresa seznamu souborñ
         xor       bx,bx                    ; ukazatel jmÇna souboru
         xor       dx,dx                    ; ukazatel zaá†tku zobrazen°
         jcxz      settabf4                 ; nen° ë†dnò soubor
settabf1:test      byte ptr ds:[di],40h     ; je disk ?
         jz        settabf2                 ; nen° disk
         inc       dx                       ; zvò®en° ukazatele zaá†tku zobraz.
         inc       bx                       ; zvò®en° ukazatele kurzoru
         add       di,20                    ; zvò®en° adresy v seznamu
         loop      settabf1                 ; test dal®°ho souboru
settabf2:mov       ds:[bp+numdskl-tabl],dl  ; uloëen° poátu diskñ v seznamu
         inc       di                       ; prvn° soubor + 1
         jcxz      settabf4                 ; nen° ë†dnò soubor
settabf3:push      cx                       ; £schova á°taáe poloëke
         push      si                       ; hledanÇ jmÇno
         push      di                       ; ukazatel v seznamu
         mov       cx,8                     ; dÇlka kontrolovanÇho jmÇna
         repe      cmpsb                    ; porovn†n° jmen
         pop       di                       ; n†vrat ukazatele seznamu
         pop       si                       ; n†vrat hledanÇho jmÇna
         pop       cx                       ; n†vrat á°taáe poloëek
         je        settabf4                 ; jmÇno bylo nalezeno
         add       di,20                    ; zvò®en° adresy v seznamu
         inc       bx                       ; zvò®en° ukazatele poloëek
         loop      settabf3                 ; test dal®°ho souboru
         mov       bx,dx                    ; nastaven° kurzoru na zaá†tek
settabf4:mov       word ptr ds:[bp+kurzl-tabl],bx ; nastaven° pozice kurzoru
         sub       bx,17                    ; pozice pro prvn° zobrazenò soub.
         cmp       bx,dx                    ; kontrola poá†tku zobrazen°
         jnl       settabf5
         mov       bx,dx
settabf5:mov       word ptr ds:[bp+firstl-tabl],bx
         ret

; -----------------------------------------------------------------------------
;                            Zobrazen° okna
; -----------------------------------------------------------------------------

window:                                     ; zobrazen° okna
                                            ; VSTUP: BP=ukazatel parametrñ okna

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         test      byte ptr ds:[bp+flagsl-tabl],2 ; p©°znak okna
         jnz       window1                  ; zapnut° okna
         call      windnul                  ; vypnut° okna
         jmp       short window2
window1: call      topline                  ; zobrazen° 1. ©†dku
         call      space                    ; zobrazen° informac° o disku
         call      directory                ; zobrazen° informac° o adres†©i
         call      obrpath                  ; zobrazen° cesty
         call      files                    ; zobrazen° souborñ z adres†©e
         call      endline                  ; zobrazen° koncovÇ linky
window2: pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;                      vypnut° okna (zobrazen° podkladu)
; -----------------------------------------------------------------------------

windnul:                                  ;* vypnut° okna (zobrazen° podkladu)

         push      cx
         push      dx
         push      si
         push      di
         push      bp
                                          ;* p©enos okna
         cmp       ds:[typdisp],1           ; je displej CGA ?
         je        windnul1                 ; je displej CGA
         cmp       ds:[typdisp],3           ; je displej EGA ?
         jne       windnul3                 ; nen° displej EGA
windnul1:mov       dl,ds:[bp+pozl-tabl]     ; pozice na ©†dku
         xor       dh,dh
         mov       si,dx
         add       si,si                    ; poá†teán° adresa - str†nka 0
         mov       cx,24                    ; poáet ©†dkñ
         test      byte ptr ds:[flags],8    ; je n†povàda ?
         jz        windnul4
         dec       cx
windnul4:push      ds
         push      es
         mov       es,ds:[segvram]
         mov       ds,ds:[segvram]
         cld
windnul2:push      cx
         push      si
         mov       di,si
         add       di,1000h                 ; adresa str†nky 1
         mov       cx,40
         rep       movsw
         pop       si
         pop       cx
         add       si,160
         loop      windnul2
         pop       es
         pop       ds
         jmp       short windnul7

windnul3:
         mov       dl,ds:[bp+pozl-tabl]     ; pozice na ©†dku
         xor       dh,dh
         mov       si,dx
         add       si,si                    ; poá†teán° adresa - str†nka 0
         mov       cx,24                    ; poáet ©†dkñ
         test      byte ptr ds:[flags],8    ; je n†povàda ?
         jz        windnul5
         dec       cx
windnul5:push      cx
         push      dx
         mov       cx,40
windnul6:push      cx
         push      dx
         xor       bh,bh
         mov       ah,2
         int       10h
         pop       dx
         push      dx
         mov       bh,1
         mov       ah,2
         int       10h
         mov       ah,8
         xor       bh,bh
         int       10h
         mov       bl,ah
         mov       ah,9
         mov       bh,1
         mov       cx,1
         int       10h
         pop       dx
         pop       cx
         inc       dl
         loop      windnul6
         pop       dx
         pop       cx
         inc       dh
         loop      windnul5
windnul7:
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         ret

; -----------------------------------------------------------------------------
;                   Zobrazen° horn°ho ©†dku okna (1. ©†dek)
; -----------------------------------------------------------------------------

topline:                                  ;* zobrazen° 1. ©†dku okna
                                            ; VSTUP: BP=tabulka okna

         push      ax
         push      cx
         push      dx
         push      si
                                          ;* zobrazen° podkladovÇ linky
         mov       dl,ds:[bp+pozl-tabl]     ; poá†teán° pozice okna
         xor       dh,dh                    ; ©†dek pro kreslen° linky
         mov       al,1                     ; atribut 1
         call      outch1                   ; nastaven° atributu 1
         mov       al,201                   ; levò horn° roh
         call      outch1                   ; zobrazen° znaku rohu
         mov       al,205                   ; rovn† dvojit† á†ra
         mov       cx,38                    ; dÇlka linky
         call      outch                    ; zobrazen° horn° linky
         mov       al,187                   ; pravò horn° roh
         call      outch1                   ; zobrazen° pravÇho horn°ho rohu
                                          ;* zobrazen° textu v roz°ch
         mov       dl,1                     ; pozice textu "<F1>=?"
         mov       si,offset texthlp        ; text "<F1>=?"
         cmp       byte ptr ds:[bp+pozl-tabl],40 ; je levÇ okno ?
         jb        toplin1                 ; je levÇ okno
         mov       dl,72                    ; je pravÇ okno
         mov       si,offset textclk        ; text hodin
toplin1: call      outtxt                   ; zobrazen° textu
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;                  Zobrazen° informac° o disku (2. ©†dek)
; -----------------------------------------------------------------------------

space:                                    ;* zobrazen° informac° o disku
                                            ; VSTUP: BP=tabulka okna

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
                                          ;* vykreslen° podkladu ©†dku
         mov       dl,ds:[bp+pozl-tabl]     ; poá†teán° pozice okna
         mov       dh,1                     ; ©†dek k tisku
         mov       al,1                     ; nastaven° z†kladn° barvy textu
         call      outch1                   ; nastaven° z†kladn° barvy textu
         push      dx                       ; £schova pozice k tisku
         mov       al,186                   ; dvojit† svisl† á†ra
         call      outch1                   ; zobrazen° levÇ á†ry
         mov       al,32                    ; znak mezery
         mov       cx,38                    ; poáet znakñ k tisku mezery
         call      outch                    ; vymaz†n° ©†dku
         mov       al,186                   ; dvojit† svisl† á†ra
         call      outch1                   ; zobrazen° levÇ á†ry
                                          ;* vyti®tàn° informac° o disku

         mov       di,offset outbuf         ; tiskovò buffer
         mov       byte ptr ds:[di],2       ; p©°znak nastaven° zvòraznànÇ barvy
         inc       di                       ; zvò®en° ukl†dac° pozice v bufferu
         push      di                       ; adresa á°sla volnÇ kapacity
         mov       ax,ds:[bp+volnl-tabl]    ; voln† kapacita disku - LOW
         mov       dx,ds:[bp+volnl-tabl+2]  ; voln† kapacita disku - HIGH
         call      deknumx                  ; dek¢dov†n° á°sla DX:AX
         mov       si,offset textsp1        ; text "bajt"
         call      transtxt                 ; uloëen° textu "bajt"
         pop       si                       ; adresa á°sla volnÇ kapacity
         push      si                       ; £schova adresy á°sla
         call      setkonc                  ; nastaven° koncovky "y", "ñ"
         mov       si,offset textsp2        ; text "voln"
         call      transtxt                 ; uloëen° textu "voln"
         pop       si                       ; adresa á°sla
         call      testkonc                 ; test koncovky á°sla
         mov       si,offset textsp20       ; koncovka "ò"
         or        al,al
         jz        space2                   ; je á°slo "1"
         mov       si,offset textsp21       ; koncovka "Ç"
         dec       al                       ; je á°slo 2,3,4 ?
         jz        space2                   ; je koncovka "Ç"
         mov       si,offset textsp22       ; koncovka "òch"
space2:  call      transtxt                 ; uloëen° koncovky
         mov       si,offset textsp23       ; text "z"
         call      transtxt                 ; uloëen° textu "z"
         mov       ax,ds:[bp+celkl-tabl]    ; celkov† kapacita disku - LOW
         mov       dx,ds:[bp+celkl-tabl+2]  ; celkov† kapacita disku - HIGH
         call      deknumx                  ; dek¢dov†n° á°sla DX:AX

         pop       dx                       ; n†vrat pozice kurzoru
         mov       si,offset outbuf         ; tiskovò buffer
         inc       dl                       ; zaá†tek textu na druhÇ pozici
         mov       cl,38                    ; ®°©ka volnÇho okna
         call      center                   ; centrov†n° textu
         call      outtxt                   ; tisk textu DS:SI
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;                 Zobrazen° informac° o adres†©i (3. ©†dek)
; -----------------------------------------------------------------------------

directory:                                ;* zobrazen° informac° o adres†©i
                                            ; VSTUP: BP=tabulka okna

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
                                          ;* vykreslen° podkladu ©†dku
         mov       dl,ds:[bp+pozl-tabl]     ; poá†teán° pozice okna
         mov       dh,2                     ; ©†dek k tisku
         mov       al,1                     ; nastaven° z†kladn° barvy textu
         call      outch1                   ; nastaven° z†kladn° barvy textu
         push      dx                       ; £schova pozice k tisku
         mov       al,186                   ; dvojit† svisl† á†ra
         call      outch1
         mov       al,32                    ; znak mezery
         mov       cx,38                    ; poáet znakñ k tisku mezery
         call      outch                    ; vymaz†n° ©†dku
         mov       al,186                   ; dvojit† svisl† á†ra
         call      outch1                   ; zobrazen° levÇ á†ry
                                          ;* vyti®tàn° informac° o adres†©i
         mov       di,offset outbuf         ; tiskovò buffer
         mov       byte ptr ds:[di],2       ; p©°znak nastaven° zvòraznànÇ barvy
         inc       di                       ; zvò®en° ukl†dac° pozice v bufferu
         mov       ax,ds:[bp+soubl-tabl]    ; nië®° slovo poátu souborñ
         mov       dx,0                     ; vy®®° slovo poátu souborñ
         push      di                       ; ukazatel textu á°sla
         or        byte ptr ds:[parnum],1   ; z†kaz tisku teáek
         call      deknum                   ; dek¢dov†n° poátu souborñ
         and       byte ptr ds:[parnum],0feh ; povolen° tisku teáek
         mov       si,offset textsp3        ; text "soubor"
         call      transtxt                 ; uloëen° textu "soubor"
         pop       si                       ; ukazatel textu á°sla
         call      setkonc                  ; nastaven° koncovky textu "y", "ñ"
         mov       si,offset textsp30       ; test "zab°r†"
         call      transtxt                 ; uloëen° textu "zab°r†"
         mov       ax,ds:[bp+zabl-tabl]     ; nië®° slovo zabranÇ kapacity
         mov       dx,ds:[bp+zabl-tabl+2]   ; vy®®° slovo zabranÇ kapacity
         push      di                       ; ukazatel á°sla
         call      deknum                   ; dek¢dov†n° zabranÇ kapacity
         mov       si,offset textsp4        ; text "bajt"
         call      transtxt                 ; uloëen° textu "bajt"
         pop       si                       ; ukazatel á°sla
         call      setkonc                  ; nastaven° koncovky "y", "ñ"
         pop       dx                       ; n†vrat pozice kurzoru
         mov       si,offset outbuf         ; tiskovò buffer
         inc       dl                       ; druh† pozice kurzoru
         mov       cl,38                    ; dÇlka prostoru pro tisk
         call      center                   ; centrov†n° textu
         call      outtxt                   ; vyti®tàn° textu
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;                         Zobrazen° cesty adres†©e
; -----------------------------------------------------------------------------

obrpath:                                  ;* zobrazen° cesty adres†©e
                                            ; VSTUP: BP=tabulka okna

         push      ax
         push      cx
         push      dx
         push      si
         push      di
                                          ;* vykreslen° podkladovÇ á†ry
         mov       dl,ds:[bp+pozl-tabl]     ; poá†teán° pozice okna
         mov       dh,3                     ; ©†dek k tisku
         mov       al,1                     ; nastaven° z†kladn° barvy textu
         call      outch1                   ; nastaven° z†kladn° barvy textu
         push      dx                       ; £schova poá†teán° pozice kurzoru
         mov       al,204                   ; lev† á†ra
         call      outch1                   ; zobrazen° levÇ á†ry
         mov       al,205                   ; vodorovn† dvojit† á†ra
         mov       cx,38                    ; dÇlka linky
         call      outch                    ; zobrazen° linky
         mov       al,185                   ; prav† á†ra
         call      outch1                   ; zobrazen° pravÇ á†ry
         pop       dx                       ; n†vrat pozice kurzoru

         mov       al,ds:[bp+flagsl-tabl]   ; p©°znaky adres†©e
         shr       al,1
         shr       al,1                     ; bit 0 = p©°znak okna
         xor       al,ds:[flags]            ; porovn†n° s aktivn°m oknem
         and       al,1                     ; vòslednò bit
         mov       al,1                     ; nastaven° norm†ln° barvy
         jnz       obrpth2                  ; nen° to aktivn° okno
         mov       al,3                     ; barva kurzoru proaktivn° okno
obrpth2: call      outch1                   ; nastaven° barvy kurzoru
         lea       si,ds:[bp+pathl-tabl]    ; cesta adres†©e
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

         mov       di,si                    ; zaá†tek cesty (za oznaáen°m disku)
         mov       cx,255                   ; á°taá dÇlky ©etàzce
         xor       al,al                    ; hledanò bajt 0
         repnz     scasb                    ; nalezen° konce textu
         not       cl                       ; dÇlka ©etàzce
         cmp       cl,36                    ; je text del®° neë 36 znakñ ?
         jna       outpth3                  ; text nen° del®° neë 36 znakñ
         sub       cl,31                    ; p©ebytek dÇlky ©etàzce
         add       si,cx                    ; zaá†tek ©etàzce
         mov       al,"."                   ; oddàlovac° teáka
         mov       cx,3                     ; poáet znakñ "."
         call      outch                    ; zobrazen° textu "..."
outpth3: call      outtxt                   ; zobrazen° (zbytku) cesty adres†©e
         mov       al," "                   ; znak oddàlovac° mezery
         call      outch1                   ; zobrazen° mezery
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;                        Zobrazen° souborñ v oknà
; -----------------------------------------------------------------------------

files:                                      ; zobrazen° souborñ z adres†©e
                                            ; VSTUP: BP=tabulka okna

         push      bx
         push      cx
         push      dx
         mov       dl,ds:[bp+pozl-tabl]     ; poá†teán° pozice okna
         mov       dh,4                     ; poá†teán° ©†dek k tisku
         mov       bx,ds:[bp+firstl-tabl]   ; á°slo prvn°ho souboru
         mov       cx,19                    ; poáet ©†dkñ displeje
         test      byte ptr ds:[flags],8    ; je n†povàda ?
         jz        files1
         dec       cx                       ; je aktivn°
files1:  call      zobrfile                 ; zobrazen° souboru
         inc       bx                       ; zvò®en° á°sla souboru
         inc       dh                       ; zvò®en° ©†dku
         loop      files1                   ; zobrazen° dal®°ho souboru
         pop       dx
         pop       cx
         pop       bx
         ret


; -----------------------------------------------------------------------------

zobrfile:                                 ;* zobrazen° poloëky adres†©e
                                            ; VSTUP: DX=pozice na displeji
                                            ;        BX=á°slo poloëky
                                            ;        BP=adresa parametrñ okna

         push      ax
         push      bx                       ; á°slo poloëky
         push      cx
         push      dx                       ; pozice na displeji
         push      si
         push      di
         call      zobrfilz                 ; zobrazen° znaáky kurzoru
         call      adrfile                  ; zji®tàn° adresy souboru v seznamu
         jnc       zobrf01                  ; je platnò soubor
                                          ;* nen° platnò soubor
         call      zobrfil0                 ; zobrazen° pr†zdnÇ ©†dky
         jmp       zobrf02                  ; zobrazen° konce souboru
                                          ;* zobrazen° platnÇho souboru
zobrf01: call      zobrfila                 ; nastaven° barvy ©†dku souboru
         call      zobrfiln                 ; zobrazen° jmÇna souboru

         mov       al,179                   ; svisl† á†ra
         test      byte ptr ds:[si],80h     ; je soubor vybranò
         jz        zobrf04                  ; soubor nen° vybranò
         mov       al,0b2h                  ; oznaáen° vybranÇho souboru
zobrf04: call      outch1                   ; zobrazen° oddàlovac° á†ry

         call      zobrfilv                 ; zobrazen° velikosti souboru

         mov       al,179                   ; svisl† á†ra
         call      outch1                   ; zobrazen° oddàlovac° á†ry

         call      zobrfild                 ; zobrazen° data souboru

         mov       al,179                   ; svisl† á†ra
         call      outch1                   ; zobrazen° oddàlovac° á†ry

         call      zobrfilc                 ; zobrazen° áasu souboru
zobrf02: call      zobrfilz                 ; zobrazen° znaáky kurzoru
zobrf03: pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------

zobrfilz:                                 ;* zobrazen° znaáky kurzoru
                                            ; VSTUP: DX=pozice na displeji
                                            ;        BP=adresa parametrñ okna
                                            ;        BX=á°slo souboru
                                            ; VùSTUP: DX=nov† pozice na displeji

         push      ax
         mov       al,1                     ; p©°znak norm†ln° barvy
         call      outch1                   ; nastaven° norm†ln° barvy
         cmp       bx,ds:[bp+kurzl-tabl]    ; je soubor s kurzorem ?
         mov       al,186                   ; norm†ln° dvojit† á†ra
         jnz       zobrfz1                  ; nen° soubor s kurzorem
         mov       al,0b0h                  ; znaáka kurzoru
zobrfz1: call      outch1                   ; zobrazen° oznaáen° kurzoru
         pop       ax
         ret

; -----------------------------------------------------------------------------

zobrfil0:                                 ;* zobrazen° pr†zdnÇ ©†dky souboru
                                            ; VSTUP: DX=pozice na displeji
                                            ;        BP=adresa parametrñ okna
                                            ; VùSTUP: DX=nov† pozice na displeji

         push      ax
         push      cx
         mov       ax,179*256+32            ; jednoduch† svisl† á†ra a mezera
         mov       cx,12                    ; mezera pro jmÇno souboru
         call      outch                    ; zobrazen° mezery pro jmÇno souboru
         xchg      ah,al                    ; AL <- znak á†ry
         call      outch1                   ; zobrazen° oddàlovac° á†ry
         xchg      ah,al                    ; AL <- mezera
         mov       cl,10                    ; mezera pro velikost souboru
         call      outch                    ; zobrazen° mezery pro velik. soub.
         xchg      ah,al                    ; AL <- znak á†ry
         call      outch1                   ; zobrazen° oddàlovac° á†ry
         xchg      ah,al                    ; AL <- mezera
         mov       cl,8                     ; mezera pro datum
         call      outch                    ; zobrazen° mezery pro datum
         xchg      ah,al                    ; AL <- znak á†ry
         call      outch1                   ; zobrazen° oddàlovac° á†ry
         xchg      ah,al                    ; AL <- mezera
         mov       cl,5                     ; mezera pro áas
         call      outch                    ; zobrazen° mezery pro áas
         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------

zobrfila:                                 ;* nastaven° barvy ©†dku souboru
                                            ; VSTUP: DX=pozice na displeji
                                            ;        BX=á°slo souboru
                                            ;        BP=adresa parametrñ okna
                                            ;        DS:SI=poloëka souboru
                                            ; VùSTUP: DX=nov† pozice na displeji

         push      ax
         push      si
         mov       ah,ds:[si]               ; atribut souboru
         mov       al,1                     ; norm†ln° barva
         test      ah,80h                   ; je vybranò soubor ?
         jz        zobrfa1                  ; nen° vybranò soubor
         inc       al                       ; barva vybranÇho souboru
zobrfa1: cmp       bx,ds:[bp+kurzl-tabl]    ; je soubor s kurzorem ?
         jnz       zobrfa2                  ; nen° soubor s kurzorem
         mov       ah,ds:[bp+flagsl-tabl]   ; p©°znaky adres†©e
         shr       ah,1
         shr       ah,1                     ; bit 0 = p©°znak okna
         xor       ah,ds:[flags]            ; porovn†n° s aktivn°m oknem
         and       ah,1                     ; vòslednò bit
         jnz       zobrfa2                  ; nen° to aktivn° okno
         add       al,2                     ; barva kurzoru
zobrfa2: call      outch1                   ; nastaven° barvy kurzoru
         pop       si
         pop       ax
         ret

; -----------------------------------------------------------------------------

zobrfiln:                                 ;* zobrazen° jmÇna souboru v adres.
                                            ; VSTUP: DX=pozice na displeji
                                            ;        DS:SI=poloëka souboru
                                            ;        BP=adresa parametrñ okna
                                            ; VùSTUP: DX=nov† pozice na displeji

         push      ax
         push      bx                       ; £schova á°sla souboru
         push      cx
         push      si
         lodsb                              ; atributy souboru
         mov       bl,al                    ; atributy (£schova)
         mov       bh,al                    ; atributy (£schova)
                                          ;* zobrazen° jmÇna souboru
         mov       cx,8                     ; dÇlka jmÇna
zobrfn1: lodsb                              ; naáten° znaku jmÇna
         test      bl,50h                   ; je adres†© nebo disk ?
         jnz       zobrfn3                  ; je adres†©
         test      bl,6                     ; je skrytò nebo systÇmovò ?
         jnz       zobrfn2                  ; je skrytò nebo systÇmovò
         call      lowcase                  ; p©evod na malÇ p°smeno
zobrfn2: and       bl,0f9h                  ; nulov†n° atrib. skryt. a syst. s.
zobrfn3: call      outch1                   ; zobrazen° znaku jmÇna
         loop      zobrfn1                  ; zobrazen° dal®°ho znaku jmÇna
                                          ;* zobrazen° oddàlovac°ho znaku
         mov       al," "                   ; oddàlovac° mezera
         test      bh,1                     ; je z†kaz z†pisu ?
         jz        zobrfn4                  ; nen° z†kaz z†pisu
         mov       al,177                   ; oznaáen° souboru R/O
zobrfn4: test      bh,6                     ; je skrytò nebo systÇmovò soubor ?
         jz        zobrfn5                  ; nen° skrytò ani systÇmovò soubor
         mov       al,176                   ; oznaáen° souboru SYS nebo HID
zobrfn5: test      bh,80h                   ; je vybranò soubor ?
         jz        zobrfn6                  ; nen° vybranò soubor
         test      byte ptr ds:[flags],40h  ; je oznaáen° vybranÇho souboru ?
         jz        zobrfn6                  ; nen° oznaáen° vybranÇho souboru
         mov       al,0bah                  ; oznaáen° vybranÇho souboru
         test      bh,7                     ; je atribut SYS, HID nebo R/O ?
         jz        zobrfn6                  ; nen° atribut SYS, HID nebo R/O
         mov       al,0dbh                  ; oznaáen° souboru SYS, HID, R/O
zobrfn6: call      outch1                   ; zobrazen° oddàlovac°ho znaku
                                          ;* zobrazen° p©°pony souboru
         mov       cx,3                     ; dÇlka p©°pony soubour
zobrfn7: lodsb                              ; naáten° znaku p©°pony souboru
         test      bh,50h                   ; je adres†© nebo disk ?
         jnz       zobrfn8                  ; je adres†© - jsou velk† p°smena
         call      lowcase                  ; p©evod na malÇ p°smeno
zobrfn8: call      outch1                   ; zobrazen° znaku p©°pony
         loop      zobrfn7                  ; zobrazen° dal®°ho znaku jmÇna
         pop       si
         pop       cx
         pop       bx                       ; n†vrat á°sla souboru
         pop       ax
         ret

; -----------------------------------------------------------------------------

zobrfilv:                                 ;* zobrazen° velikosti souboru
                                            ; VSTUP: DX=pozice na displeji
                                            ;        DS:SI=poloëka souboru
                                            ;        BP=adresa parametrñ okna
                                            ; VùSTUP: DX=nov† pozice na displeji

         push      ax
         push      bx                       ; £schova á°sla souboru
         push      cx
         push      si
         add       si,12                    ; ukazatel na velikost souboru
         test      byte ptr ds:[si-12],50h  ; je podadres†© nebo disk ?
         jz        zobrfv2                  ; nen° podadres†© ani disk
                                          ;* zobrazen° textu disku nebo adres†©e
         push      si                       ; £schova ukazatele souboru
         test      byte ptr ds:[si-12],40h  ; je disk ?
         mov       si,offset txtdsk         ; text oznaáen° disku "<--DISK-->"
         jnz       zobrfv1                  ; je disk
         pop       si                       ; ukazatel souboru
         push      si                       ; ukazatel souboru
         cmp       word ptr ds:[si-11],".." ; je oznaáen° nad©azenÇho podadres.?
         mov       si,offset txtsubd        ; text podadres†©e "<POD--ADR>"
         jne       zobrfv1                  ; nen° adres†© ".."
         mov       si,offset txtupd         ; text podadres†©e "<NAD--ADR>"
zobrfv1: call      outtxt                   ; zobrazen° oznaáen° adres†©e, disku
         pop       si                       ; n†vrat ukazatele dat souboru
         add       si,4                     ; adresa data
         jmp       short zobrfv3
                                          ;* zobrazen° velikosti souboru
zobrfv2: lodsw                              ; nië®° slovo velikosti souboru
         mov       bx,ax                    ; BX <- nië®° slovo velikosti
         lodsw                              ; vy®®° slovo velikosti souboru
         xchg      ax,bx                    ; AX <- nië®°, BX <- vy®®° slovo
         call      tisknm0                  ; tisk á°sla velikosti (10 á°slic)
zobrfv3: pop       si
         pop       cx
         pop       bx                       ; n†vrat á°sla souboru
         pop       ax
         ret

; -----------------------------------------------------------------------------

zobrfild:                                 ;* zobrazen° data souboru
                                            ; VSTUP: DX=pozice na displeji
                                            ;        DS:SI=poloëka souboru
                                            ;        BP=adresa parametrñ okna
                                            ; VùSTUP: DX=nov† pozice na displeji

         push      ax
         push      cx
         push      si
         add       si,16
         test      byte ptr ds:[si-16],40h  ; je disk ?
         jz        zobrfd0                  ; nen° disk
                                          ;* n†hradn° mezera
         mov       al," "                   ; mazac° mezera
         mov       cx,8                     ; dÇlka mezery
         call      outch                    ; zobrazen° mezery
         jmp       short zobrfd3
                                          ;* zobrazen° data souboru
zobrfd0: lodsw                              ; datum souboru
         push      ax                       ; £schova data souboru
         and       al,1fh                   ; maska pro den
         call      tisknm2s                 ; zobrazen° dne
         mov       al,"."                   ; oddàlovac° teáka
         call      outch1                   ; zobrazen° oddàlovac° teáky
         pop       ax                       ; n†vrat data souboru
         push      ax                       ; £schova data souboru
         mov       cl,5                     ; poáet rotac°
         shr       ax,cl                    ; AX >> màs°c
         and       al,0fh                   ; maska pro màs°c
         call      tisknm20                 ; zobrazen° màs°ce
         mov       al,"."                   ; oddàlovac° teáka
         call      outch1                   ; zobrazen° oddàlovac° teáky
         pop       ax                       ; n†vrat data souboru
         mov       cl,9                     ; poáet rotac°
         shr       ax,cl                    ; AX >> rok
         and       ax,7fh                   ; maska pro rok
         add       ax,80                    ; korekce - p©iáten° roku 1980
zobrfd1: cmp       ax,100                   ; je á°slo men®° neë 99 ?
         jb        zobrfd2                  ; je á°slo men®° neë 99
         sub       ax,100                   ; korekce - odeáten° 100
         jmp       short zobrfd1            ; dal®° kontrola á°sla
zobrfd2: call      tisknm20                 ; zobrazen° roku
zobrfd3: pop       si
         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------

zobrfilc:                                 ;* zobrazen° áasu souboru
                                            ; VSTUP: DX=pozice na displeji
                                            ;        DS:SI=poloëka souboru
                                            ;        BP=adresa parametrñ okna
                                            ; VùSTUP: DX=nov† pozice na displeji

         push      ax
         push      cx
         push      si
         add       si,18
         test      byte ptr ds:[si-18],40h  ; je disk ?
         jz        zobrfc0                  ; nen° disk
                                          ;* n†hradn° mezera
         mov       al," "                   ; mazac° mezera
         mov       cx,5                     ; dÇlka mezery
         call      outch                    ; zobrazen° mezery
         jmp       short zobrfc1
                                          ;* zobrazen° data souboru
zobrfc0: lodsw                              ; áas souboru
         push      ax                       ; £schova áasu souboru
         mov       cl,11                    ; poáet rotac°
         shr       ax,cl                    ; AX >> hodina
         and       al,1fh                   ; maska pro hodinu
         call      tisknm2s                 ; zobrazen° hodiny
         mov       al,"."                   ; oddàlovac° teáka
         call      outch1                   ; zobrazen° oddàlovac° teáky
         pop       ax                       ; n†vrat áasu souboru
         mov       cl,5                     ; poáet rotac°
         shr       ax,cl                    ; AX >> minuta
         and       al,3fh                   ; maska pro minutu
         call      tisknm20                 ; zobrazen° minuty
zobrfc1: pop       si
         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;                  Zobrazen° posledn°ho ©†dku okna
; -----------------------------------------------------------------------------

endline:                                  ;* zobrazen° koncovÇ linky
                                            ; VSTUP: BP=adresa parametrñ okna

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         mov       dl,ds:[bp+pozl-tabl]     ; poá†teán° pozice okna
         mov       dh,23                    ; ©†dek k tisku
         test      byte ptr ds:[flags],8    ; je n†povàda ?
         jz        endlin5                  ; nen° aktivn°
         dec       dh
endlin5:
                                          ;* zobrazen° podkladovÇ linky
         mov       al,200                   ; levò doln° roh
         call      outch1                   ; zobrazen° levÇho doln°ho rohu
         push      dx                       ; £schova poá†teán° pozice
         mov       al,205                   ; rovn† dvojit† á†ra
         mov       cx,38                    ; dÇlka linky
         call      outch                    ; zobrazen° horn° linky
         mov       al,188                   ; pravò doln° roh
         call      outch1                   ; zobrazen° pravÇho doln°ho rohu

         mov       ax,ds:[bp+insfil-tabl]   ; poáet oznaáenòch souborñ
         or        ax,ax                    ; je oznaáen nàjakò soubor ?
         jnz       endlin0                  ; je soubor
         jmp       endlin1                  ; nen° oznaáen ë†dnò soubor
                                          ;* dek¢dov†n° obsazenÇ kapacity
endlin0: push      ax                       ; £schova poátu souborñ
         mov       di,offset outbuf         ; tiskovò buffer
         mov       byte ptr ds:[di],2       ; nastaven° zvòraznànÇho textu
         inc       di                       ; zvò®en° ukl†dac° adresy
         mov       byte ptr ds:[di],32      ; uloëen° £vodn° mezery
         inc       di                       ; zvò®en° ukl†dac° adresy
         push      di
         mov       ax,ds:[bp+kapfil-tabl]   ; zabran† kapacita - LOW
         mov       dx,ds:[bp+kapfil-tabl+2] ; zabran† kapacita - HIGH
         call      deknum                   ; dek¢dov†n° á°sla
         mov       si,offset textvy1        ; text "bajt"
         call      transtxt                 ; uloëen° textu "bajt"
         pop       si
         call      setkonc                  ; nastaven° koncovky "y", "ñ"
         pop       ax                       ; poáet souborñ

         push      ax                       ; poáet souborñ
         mov       si,offset textvy13       ; ukonáen° textu ' v '
         cmp       ax,2
         jb        endlin4
         cmp       ax,4                     ; je vàt®° neë 4 ?
         jbe       endlin3                  ; je men®° neë 5
         cmp       ax,12
         jb        endlin4
         cmp       ax,14
         jbe       endlin3
         cmp       ax,20
         jb        endlin4
         cmp       ax,49
         jbe       endlin3
         cmp       ax,100
         jb        endlin4
         cmp       ax,499
         ja        endlin4
endlin3: mov       si,offset textvy14       ; ukonáen° textu ' ve '
endlin4: call      transtxt                 ; uloëen° textu ' v ', 've'
         pop       ax                       ; n†vrat poátu souborñ
                                          ;* dek¢dov†n° poátu souborñ
         mov       dx,0                     ; vy®®° slovo á°sla
         push      di                       ; ukazatel na á°slo
         call      deknum5                  ; dek¢dov†n° poátu souborñ
         mov       si,offset textvy2        ; text "soubor"
         call      transtxt                 ; uloëen° textu "soubor"
         pop       si                       ; ukazatel na á°slo
         call      testkonc                 ; test koncovky á°sla
         mov       si,offset textvy21       ; koncovka pro á°slo "1"
         or        al,al                    ; je koncovka pro "1" ?
         jz        endlin2                  ; je koncovka pro "1"
         mov       si,offset textvy22       ; koncovka pro ostatn° á°sla
endlin2: call      transtxt                 ; uloëen° koncovky

                                          ;* tisk informac° o vòbàru souborñ
         pop       dx                       ; n†vrat poá†teán° pozice
         push      dx                       ; £schova poá†teán° pozice
         mov       si,offset outbuf         ; tiskovò buffer
         mov       cl,38                    ; ®°©ka prostoru k tisku
         call      center                   ; centrov†n° textu
         call      outtxt                   ; tisk textu
endlin1: pop       dx                       ; n†vrat pozice na displeji
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;                         Zapnut° kurzoru
; -----------------------------------------------------------------------------

kurzon:                                   ;* zapnut° kurzoru

         push      ax
         push      bx
         push      dx
         push      bp
         mov       bp,offset tabl           ; tabulka levÇho okna
         test      byte ptr ds:[flags],1    ; je levÇ okno ?
         jnz       kurzon1                  ; je levÇ okno
         mov       bp,offset tabr           ; tabulka pravÇho okna
kurzon1:
         mov       dl,ds:[bp+pozl-tabl]     ; pozice na displeji
         mov       bx,ds:[bp+kurzl-tabl]    ; soubor s kurzorem
         jmp       short kurzof2

; -----------------------------------------------------------------------------
;                           Vypnut° kurzoru
; -----------------------------------------------------------------------------

kurzoff:                                  ;* vypnut° kurzoru

         push      ax
         push      bx
         push      dx
         push      bp
         mov       bp,offset tabl           ; tabulka levÇho okna
         test      byte ptr ds:[flags],1    ; je levÇ okno ?
         jnz       kurzof1                  ; je levÇ okno
         mov       bp,offset tabr           ; tabulka pravÇho okna
kurzof1:
         mov       dl,ds:[bp+pozl-tabl]     ; pozice na displeji
         mov       bx,-1                    ; nov† pozice pro zru®en° kurzoru
         xchg      bx,ds:[bp+kurzl-tabl]    ; soubor s kurzorem
kurzof2: mov       ax,4                     ; poá†teán° ©†dek
         add       ax,bx                    ; p©iáten° á°sla soub. s kurzorem
         sub       ax,ds:[bp+firstl-tabl]   ; odeáten° prvn°ho souboru
         mov       dh,al                    ; ©†dek s kurzorem
         call      zobrfile                 ; zobrazen° souboru
         mov       ds:[bp+kurzl-tabl],bx    ; n†vrat á°sla kurzoru
         pop       bp
         pop       dx
         pop       bx
         pop       ax
         ret


; -----------------------------------------------------------------------------
;                 Poskytnut° adresy souboru s kurzorem
; -----------------------------------------------------------------------------

getkurz:                                    ; poskytnut° adresy s kurzorem
                                            ; VùSTUP: DS:SI

         push      ax
         push      bx
         push      bp
         mov       bp,offset tabl           ; levÇ okno
         test      byte ptr ds:[flags],1    ; je levÇ okno ?
         jnz       getkurz1                 ; je levÇ okno
         mov       bp,offset tabr           ; pravÇ okno
getkurz1:mov       bx,ds:[bp+kurzl-tabl]    ; á°slo souboru s kurzorem
         call      adrfile                  ; poskytnut° adresy souboru
         pop       bp
         pop       bx
         pop       ax
         ret


; -----------------------------------------------------------------------------

deinit:
         push      ax
         push      dx
         xor       al,al
         mov       ah,5
         int       10h
         mov       al,13
         int       29h
         mov       al,10
         int       29h
         pop       dx
         pop       ax
         ret


; *****************************************************************************
;
;                          Ovl†d†n° programu
;
; *****************************************************************************

uses:
         call      obrcomm                  ; zobrazen° povelovÇho ©†dku

uses0:
         call      obrkurz                  ; zobrazen° kurzoru na ©†dku

uses04:  mov       ah,1
         int       16h
         pushf
         push      ds
         xor       ax,ax
         mov       ds,ax
         test      byte ptr ds:[417h],8
         pop       ds
         jz        uses05                   ; nen° kl†vesa ALT stisknuta

         test      byte ptr ds:[flags],10h
         jnz       uses07
         or        byte ptr ds:[flags],10h
         mov       dx,25*256+80
         xor       al,al
         call      outch
         mov       dx,24*256
         mov       si,offset txthelp2
         call      outtxt
         jmp       short uses07

uses05:  test      byte ptr ds:[flags],10h
         jz        uses07
         and       byte ptr ds:[flags],0efh
         test      byte ptr ds:[flags],8
         jz        uses08
         call      obrkurz
         mov       dx,24*256
         mov       si,offset txthelp
         call      outtxt
         jmp       short uses07
uses08:
         call      obrkurz
         call      obrcomm

uses07:  popf
         jz        uses04
uses06:  xor       ah,ah
         int       16h

         mov       bp,offset tabl           ; tabulka levÇho okna
         test      byte ptr ds:[flags],1    ; je levÇ okno ?
         jnz       uses01                   ; je levÇ okno
         mov       bp,offset tabr           ; tabulka pravÇho okna
uses01:


uses02:  cmp       al,19h                   ; je Ctrl-Y ?
         je        uses03                   ; je vymaz†n° ©†dku
         cmp       ax,011bh                 ; je Esc ?
         jne       uses1

uses03:  xor       al,al
         mov       ds:[pozcomm],al
         mov       ds:[pozbuf],al
         mov       ds:[buftxt],al
         mov       ds:[poztop],al
         mov       ds:[numchar],al
         jmp       uses

uses1:   cmp       ax,0f09h                 ; Tab
         jnz       uses2

         call      xchgakt                  ; zmàna aktivn°ho okna
         jmp       uses


uses2:   cmp       ax,4800h                 ; kurzor nahoru
         jne       uses3

         call      moveup                   ; posun kurzoru nahoru
         jmp       uses0


uses3:   cmp       ax,5000h                 ; kurzor dolñ
         jne       uses4                    ; nen° kurzor dolñ

         call      movedown                 ; posun kurzoru dolñ
         jmp       uses0



uses4:   cmp       ax,4700h                 ; Home
         jne       uses41
         cmp       byte ptr ds:[numchar],0
         je        uses42
uses41:  cmp       ax,8400h                 ; ^Page Up
         jne       uses5

uses42:
         call      movehome                 ; p©esun na zaá†tek adres†©e
         jmp       uses0


uses44:  call      kurzon                   ; zapnut° kurzoru
uses45:  jmp       uses0


uses5:   cmp       ax,4f00h                 ; End
         jne       uses51
         cmp       byte ptr ds:[numchar],0
         je        uses52
uses51:  cmp       ax,7600h                 ; ^Page Down
         jne       uses6

uses52:
         call      moveend                  ; p©esun na konec adres†©e
uses50:  jmp       uses0


uses6:   cmp       ax,4900h                 ; Page Up
         jne       uses7

         call      pageup                   ; p©esun o str†nku nahoru
         jmp       uses0


uses7:   cmp       ax,5100h                 ; Page Down
         jne       uses8

         call      pagedown                 ; p©esun o str†nku dolñ
         jmp       uses0


uses8:   cmp       ax,4e2bh                 ; [+]
         jne       uses81

         call      selplus
         jmp       uses0

uses81:  cmp       ax,4a2dh                 ; [-]
         jne       uses82

         call      selmin
         jmp       uses0

uses82:  cmp       ax,5200h                 ; Insert
         jne       uses9

         call      insert                   ; oznaáen° souborñ
         jmp       uses0


uses9:   cmp       ax,1c0dh                 ; Enter
         je        uses90
         jmp       usesa
uses90:

         call      enter                    ; funkce Enter
         jmp       uses

usesa:   or        ah,ah
         jz        usesa0
         cmp       ax,0300h
         jz        usesa0
         cmp       al,32
         jb        usesb
usesa0:
         call      insch                    ; vloëen° znaku
         jmp       uses0


usesb:   cmp       ax,0e08h
         jne       usesc

         call      delbs                    ; zru®en° znaku p©ed kurzorem
         jmp       uses0

usesc:   cmp       ax,4b00h                 ; kurzor vlevo
         jne       usesd

         call      chleft                   ; posun o znak vlevo
         jmp       uses0

usesd:   cmp       ax,4d00h                 ; kurzor vpravo
         jne       usese

         call      chright                  ; posun o znak vpravo
         jmp       uses0

usese:   cmp       ax,5300h                 ; Delete
         jne       usesf

         call      delchar                  ; vymaz†n° znaku nad kurzorem
         jmp       uses0

usesf:   cmp       ax,4700h                 ; Home ©†dku
         jne       usesg

         call      homer                    ; funkce Home na ©†dku
         jmp       uses0

usesg:   cmp       ax,4f00h                 ; End ©†dku
         jne       usesh

         call      endr                     ; funkce End na ©†dku
         jmp       uses0

usesh:   cmp       ax,0f00h                 ; Shift - Tab
         jne       usesi

         call      invsel                   ; inverze vòbàru souborñ
         jmp       uses0

usesi:   cmp       al,0ah                   ; Ctrl - Enter, Ctrl-J
         jne       usesj

         call      ctrlent                  ; p©enesen° jmÇna souboru
         jmp       uses0

usesj:   cmp       al,0fh                   ; Ctrl-O
         jne       usesk

         call      xchgpg                   ; zmàna str†nky displeje
         jmp       uses0

usesk:   cmp       al,10h                   ; Ctrl-P
         jne       usesl

         call      xchgw                    ; zmàna okna
         jmp       uses0

usesl:   cmp       al,2                     ; Ctrl-B
         jne       usesm

         call      sethlp
         jmp       uses0

usesm:   cmp       ax,3f00h                 ; F5 (kop°rov†n°)
         jne       usesn

         call      copyfile
         jmp       uses0

usesn:



jmp       uses0

; -----------------------------------------------------------------------------

obrcomm:                                    ; zobrazen° p©°kazovÇho ©†dku
         push      dx
         and       byte ptr ds:[aktpage],0feh
         mov       dh,ds:[radek]
         call      obrcom0
         or        byte ptr ds:[aktpage],1
         mov       dh,24
         test      byte ptr ds:[flags],8
         jz        obrcomm4                 ; n†povàda nen° aktivn°
         dec       dh
obrcomm4:call      obrcom0
         pop       dx
         ret

obrcom0: push      ax
         push      dx
         push      si
         mov       al,ds:[aktatr]           ; aktivn° atribut
         mov       ds:[color],al
         xor       dl,dl                    ; poá†teán° pozice kurzoru
         mov       si,offset pathl          ; cesta k levÇmu adres†©i
         test      byte ptr ds:[flags],1    ; je aktivn° levÇ okno ?
         jnz       obrcom1                  ; je aktivn° levÇ okno
         mov       si,offset pathr          ; cesta k pravÇmu adres†©i
obrcom1: call      outtx0                   ; zobrazen° textu cesty
         mov       al,">"                   ; £vodn° prompt
         call      outch1                   ; zobrazen° promptu
         mov       ds:[pozcomm],dl          ; pozice zaá†tku p©°kazu

         mov       dl,ds:[pozbuf]           ; pozice v bufferu
         sub       dl,ds:[poztop]           ; offset od promptu
         add       dl,ds:[pozcomm]          ; offset od zaá†tku ©†dku
         sub       dl,78                    ; kontrola p©eteáen° okraje
         jc        obrcom2                  ; nen° p©ekroáen° okraje
         add       ds:[poztop],dl           ; zvò®en° offsetu zaá†tku
obrcom2: call      obrcomt0                 ; zobrazen° textu p©°kazu
         pop       si
         pop       dx
         pop       ax
         ret

; -----------------------------------------------------------------------------

obrcomt:                                  ;* zobrazen° p©°kazovÇho ©†dku
         push      dx
         and       byte ptr ds:[aktpage],0feh
         mov       dh,ds:[radek]
         call      obrcomt0
         or        byte ptr ds:[aktpage],1
         mov       dh,24
         test      byte ptr ds:[flags],8
         jz        obrcomt4                 ; n†povàda nen° aktivn°
         dec       dh
obrcomt4:call      obrcomt0
         pop       dx
         ret

obrcomt0:
         push      ax
         push      cx
         push      dx
         push      si
         mov       al,ds:[aktatr]
         mov       ds:[color],al
         mov       dl,ds:[pozcomm]          ; pozice zaá†tku p©°kazu
         mov       cl,ds:[poztop]           ; pozice zaá†tku zobrazenÇho textu
         xor       ch,ch                    ; CH <- 0
         mov       si,offset buftxt         ; buffer p©°kazovÇho ©†dku
         add       si,cx                    ; zaá†tek zobrazenÇho textu
         mov       al,ds:[numchar]          ; poáet znakñ v bufferu
         sub       al,cl                    ; zbytek ©†dku
         mov       cl,al                    ; poáet znakñ k tisku
         jbe       obrcomt2                 ; nen° ë†dnò znak
         mov       ah,80                    ; ®°©ka ©†dku
         sub       ah,dl                    ; poáet znakñ do zbytku ©†dku
         cmp       cl,ah                    ; je p©ekroáen poáet znakñ ?
         jbe       obrcomt1                 ; nen° p©ekroáen poáet znakñ
         mov       cl,ah                    ; omezen° poátu znakñ
obrcomt1:lodsb                              ; naáten° znaku k vòstupu
         push      cx
         mov       cl,1
         call      outch0                   ; vòstup znaku
         pop       cx
         loop      obrcomt1                 ; vòstup dal®°ho znaku
obrcomt2:mov       cl,80
         sub       cl,dl                    ; souáasn† pozice na ©†dku
         mov       al," "                   ; mazac° mezera
         call      outch                    ; vymaz†n° zbytku ©†dku
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------

obrkurz:                                    ; zobrazen° kurzoru na ©†dku

         push      ax
         push      dx
         mov       dl,ds:[pozbuf]           ; pozice v bufferu
         sub       dl,ds:[poztop]           ; odeáten° poá†teán° pozice
         add       dl,ds:[pozcomm]          ; poá†teán° pozice na displeji
         xor       al,al                    ; povel k nastaven° kurzoru
         and       byte ptr ds:[aktpage],0feh
         mov       dh,ds:[radek]
         call      outch1                   ; nastaven° pozice kurzoru
         or        byte ptr ds:[aktpage],1
         mov       dh,24                    ; ©†dek p©°kazovÇho ©†dku
         test      byte ptr ds:[flags],8
         jz        obrkur2                  ; n†povàda nen° aktivn°
         dec       dh
obrkur2: call      outch1                   ; nastaven° pozice kurzoru
         pop       dx
         pop       ax
         ret

; -----------------------------------------------------------------------------

xchgakt:                                  ;* zmàna aktivn°ho okna

                                          ;* vypnut° zobrazen° kurzoru
         push      bp
         test      byte ptr ds:[flags],1    ; je levÇ okno ?
         mov       bp,offset tabr           ; p©°znak pravÇho okna
         jnz       xchakt1                  ; je levÇ okno
         mov       bp,offset tabl           ; p©°znak levÇho okna
xchakt1: test      byte ptr ds:[bp+flagsl-tabl],2 ; p©°znak okna
         pop       bp
         jz        xchakt2                  ; okno nen° zapnutÇ - p©epnut° oken

         push      word ptr ds:[col3]       ; £schova zvòraznànòch barev
         mov       ax,word ptr ds:[col1]    ; norm†ln° barvy
         mov       word ptr ds:[col3],ax    ; nastaven° barev pro kurzor
         call      kurzon                   ; zobrazen° pr†zdnÇho kurzoru
         pop       word ptr ds:[col3]       ; n†vrat barev pro kurzor
xchakt3:                                  ;* zmàna zobrazen° kurzorñ
         xor       byte ptr ds:[flags],1    ; zmàna aktivn°ho okna
         mov       bp,offset tabl           ; adresa levÇho okna
         call      obrpath                  ; zobrazen° cesty levÇho okna
         mov       bp,offset tabr           ; adresa pravÇho okna
         call      obrpath                  ; zobrazen° cesty pravÇho okna
         call      kurzon                   ; zapnut° novÇho kurzoru
         ret

xchakt2:                                  ;* zmàna pozice okna
         mov       al,ds:[pozr]
         xchg      al,ds:[pozl]
         mov       ds:[pozr],al
         mov       bp,offset tabl
         call      window
         mov       bp,offset tabr
         call      window
         ret

; -----------------------------------------------------------------------------

moveup:                                   ;* posun kurzoru nahoru

         push      ax
         push      dx
         mov       ax,ds:[bp+kurzl-tabl]    ; pozice kurzoru
         or        ax,ax                    ; je jië prvn° pozice kurzoru ?
         jz        moveup2                  ; kurzor je jië na prvn° pozici
         call      kurzoff                  ; vypnut° kurzoru
         dec       ax                       ; sn°ëen° pozice kurzoru
         mov       ds:[bp+kurzl-tabl],ax    ; nastaven° novÇ pozice kurzoru
         mov       dl,ds:[bp+numdskl-tabl]  ; poáet diskñ
         xor       dh,dh                    ; DH <- 0
         cmp       ds:[bp+firstl-tabl],dx   ; prvn° zobrazenò soubor
         jle       moveup3                  ; je jië p©ed oznaáen°m diskñ

         cmp       ax,ds:[bp+firstl-tabl]
         jnb       moveup4
         call      wrolldown
moveup4: dec       ax
         cmp       ax,ds:[bp+firstl-tabl]
         jnb       moveup1
         mov       ds:[bp+firstl-tabl],ax
         call      wrolldown

         mov       bx,ax
         mov       dh,4
         mov       dl,ds:[bp+pozl-tabl]
         call      zobrfile
         jmp       short moveup1

moveup3: cmp       ax,ds:[bp+firstl-tabl]   ; je kurzor p©ed prvn°m souborem ?
         jnb       moveup1                  ; kurzor nen° p©ed prvn°m souborem
         mov       ds:[bp+firstl-tabl],ax   ; nastaven° prvn°ho souboru
         call      wrolldown                ; rolov†n° okna dolñ
moveup1: call      kurzon                   ; zapnut° kurzoru
moveup2: pop       dx
         pop       ax
         ret

; -----------------------------------------------------------------------------

movedown:                                 ;* posun kurzoru dolñ

         push      ax
         push      bx
         push      dx
         mov       ax,ds:[bp+kurzl-tabl]    ; pozice kurzoru
         inc       ax                       ; pozice kurzoru + 1
         cmp       ax,ds:[bp+numfl-tabl]    ; je to jië posledn° soubor ?
         jae       moved3                   ; je to jië posledn° soubor
         call      kurzoff                  ; vypnut° kurzoru
         mov       ds:[bp+kurzl-tabl],ax    ; nastaven° novÇ pozice kurzoru

         mov       bx,ds:[bp+firstl-tabl]   ; prvn° zobrazenò soubor
         add       bx,18                    ; p©edpokl†danò konec + 1
         test      byte ptr ds:[flags],8
         jnz       moved6
         inc       bx
moved6:  cmp       bx,ds:[bp+numfl-tabl]    ; je p©ed koncem ?
         jae       moved1                   ; je posledn° nebo p©edposledn°

         dec       bx
         cmp       ax,bx
         jb        moved2                   ; je p©ed p©edposledn°m souborem
         je        moved4
         inc       bx
         call      wrollup
moved4:  sub       bx,16
         test      byte ptr ds:[flags],8
         jnz       moved8
         dec       bx
moved8:  mov       ds:[bp+firstl-tabl],bx   ; zvò®en° prvn°ho souboru
         call      wrollup                  ; rolov†n° okna nahoru
         inc       ax
         mov       bx,ax
         mov       dh,22
         test      byte ptr ds:[flags],8
         jz        moved7
         dec       dh
moved7:  mov       dl,ds:[bp+pozl-tabl]
         call      zobrfile
         jmp       short moved2

moved1:  dec       bx
         cmp       ax,bx                    ; je kurzor za koncem ?
         jna       moved2                   ; kurzor nen° za koncem
         inc       word ptr ds:[bp+firstl-tabl] ; zvò®en° prvn°ho souboru
         call      wrollup                  ; rolov†n° okna nahoru
moved2:  call      kurzon                   ; zapnut° kurzoru
moved3:  pop       dx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------

movehome:                                 ;* p©esun na zaá†tek adres†©e

         push      ax
         push      dx
         mov       ax,ds:[bp+kurzl-tabl]    ; pozice kurzoru
         mov       dl,ds:[bp+numdskl-tabl]  ; poáet diskñ v seznamu
         xor       dh,dh                    ; DH <- 0
         cmp       ax,dx                    ; je jië na prvn° pozici adres†©e ?
         je        moveh1                   ; kurzor je jië na prvn° pozici
         call      kurzoff                  ; vypnut° kurzoru
         mov       word ptr ds:[bp+kurzl-tabl],dx ; nastaven° pozice kurzoru
         mov       word ptr ds:[bp+firstl-tabl],dx ; prvn° zobrazenò soubor
         call      files                    ; zobrazen° adres†©e
moveh1:  pop       dx
         pop       ax
         ret

; -----------------------------------------------------------------------------

moveend:                                    ; p©esun na konec adres†©e

         push      ax
         push      dx
         mov       dl,ds:[bp+numdskl-tabl]  ; poáet diskñ v seznamu
         xor       dh,dh                    ; DH <- 0
         mov       ax,ds:[bp+numfl-tabl]    ; poáet souborñ
         sub       ax,18                    ; p©edpokl†danò prvn° soubor
         test      byte ptr ds:[flags],8
         jnz       movee5
         dec       ax
movee5:  cmp       ax,dx                    ; je p©ed prvn°m souborem ?
         jl        movee1                   ; je p©ed prvn°m souborem
         mov       dx,ax                    ; prvn° soubor
movee1:  mov       ax,ds:[bp+numfl-tabl]    ; poáet souborñ
         dec       ax                       ; posledn° soubor
         or        ah,ah                    ; je vy®®° slovo = 0 ?
         jnz       movee2                   ; nen° poáet < 256
         cmp       al,ds:[bp+numdskl-tabl]  ; je nàjakò soubor ?
         jbe       movee4                   ; nen° ë†dnò soubor
movee2:  cmp       dx,ds:[bp+firstl-tabl]   ; je jië nastaven prvn° soubor ?
         jne       movee3                   ; prvn° soubor nebyl nastaven
         cmp       ax,ds:[bp+kurzl-tabl]    ; kontrola nastaven° kurzoru
         je        movee4                   ; je jië na posledn° pozici
movee3:  call      kurzoff                  ; vypnut° kurzoru
         mov       ds:[bp+kurzl-tabl],ax    ; nov† pozice kurzoru
         mov       ds:[bp+firstl-tabl],dx   ; novò zaá†tek zobrazen°
         call      files                    ; zobrazen° adres†©e
movee4:  pop       dx
         pop       ax
         ret

; -----------------------------------------------------------------------------

pageup:                                   ;* p©esun o str†nku nahoru

         push      ax
         push      dx
         mov       ax,ds:[bp+kurzl-tabl]    ; pozice kurzoru
         mov       dl,ds:[bp+numdskl-tabl]  ; poáet diskñ v seznamu
         xor       dh,dh                    ; DH <- 0
         cmp       ax,dx                    ; je jië na prvn° pozici adres†©e ?
         jb        pageup1                  ; je men®° - skok na prvn° pozici
         jne       pageup2                  ; kurzor nen° na prvn° pozici
         cmp       dx,ds:[bp+firstl-tabl]   ; je zobrazen prvn° soubor ?
         je        pageup5                  ; ë†dn† funkce
pageup1: call      movehome                 ; nen° - funkce Home
         jmp       short pageup5

pageup2: call      kurzoff                  ; vypnut° kurzoru
         mov       ax,ds:[bp+firstl-tabl]   ; prvn° zobrazenò soubor
         cmp       ax,dx                    ; je prvn° poloëka ?
         je        pageup1                  ; je jië zobrazen† prvn° poloëka
                                          ;* posun prvn° zobrazenÇ poloëky
         sub       ax,17                    ; sn°ëen° ukazatele prvn° poloëky
         test      byte ptr ds:[flags],8
         jnz       pageup6
         dec       ax
pageup6: cmp       ax,dx                    ; je nië®° neë prvn° poloëka ?
         jnl       pageup3                  ; nen° men®° neë prvn° poloëka
         add       ax,17                    ; n†vrat ukazatele prvn° poloëky
         test      byte ptr ds:[flags],8
         jnz       pageup7
         inc       ax
pageup7: sub       ax,dx                    ; poáet poloëek k posuvu
         sub       ds:[bp+kurzl-tabl],ax    ; nov† pozice kurzoru
         mov       ax,dx                    ; poáet diskñ
         jmp       short pageup4
pageup3: sub       word ptr ds:[bp+kurzl-tabl],18 ; sn°ëen° ukazatele kurzoru
         test      byte ptr ds:[flags],8
         jz        pageup4
         inc       word ptr ds:[bp+kurzl-tabl] ; sn°ëen° ukazatele kurzoru
pageup4: mov       ds:[bp+firstl-tabl],ax   ; nastaven° prvn° zobrazenÇ poloëky
         call      files
pageup5: pop       dx
         pop       ax
         ret

; -----------------------------------------------------------------------------

pagedown:                                 ;* p©esun o str†nku dolñ

         push      ax
         push      bx
         push      cx
         push      dx
         mov       bx,word ptr ds:[bp+numfl-tabl] ; poáet souborñ
         dec       bx                       ; posledn° soubor
         cmp       bx,word ptr ds:[bp+kurzl-tabl] ; je dosaëeno konce ?
         jg        pagedo0                  ; nen° je®tà konec
         jmp       pagedo6                  ; je konec adres†©e
pagedo0: call      kurzoff
         mov       cx,bx                    ; posledn° soubor
         mov       dl,ds:[bp+numdskl-tabl]  ; poáet diskñ
         xor       dh,dh                    ; DH <- 0
         sub       bx,17                    ; max. á°slo zaá†tku
         test      byte ptr ds:[flags],8
         jnz       pagedo7
         dec       bx
pagedo7: cmp       bx,dx
         jnl       pagedo1                  ; poáet souborñ >= 18
         mov       bx,dx                    ; max. á°slo zaá†tku
pagedo1: mov       ax,ds:[bp+firstl-tabl]
         add       ax,17
         test      byte ptr ds:[flags],8
         jnz       pagedo8
         inc       ax
pagedo8: cmp       ax,bx
         jbe       pagedo2
         cmp       word ptr ds:[bp+firstl-tabl],bx ; kontrola poá†tku
         jnz       pagedo4                  ; nen° je®tà dosaëeno maxima
pagedo2: mov       ax,ds:[bp+kurzl-tabl]    ; pozice kurzoru
         add       ax,17                    ; zvò®en° pozice kurzoru
         test      byte ptr ds:[flags],8
         jnz       pagedo9
         inc       ax
pagedo9: cmp       ax,cx
         jna       pagedo3                  ; nen° p©ekroáen°
;         cmp       word ptr ds:[bp+firstl-tabl],0
;         jne       pagedo4
         mov       ax,cx
pagedo3: mov       ds:[bp+kurzl-tabl],ax
pagedo4: mov       ax,ds:[bp+firstl-tabl]
         add       ax,17
         test      byte ptr ds:[flags],8
         jnz       pagedoa
         inc       ax
pagedoa: cmp       ax,bx
         jna       pagedo5
         sub       ax,17
         test      byte ptr ds:[flags],8
         jnz       pagedob
         dec       ax
pagedob: sub       ax,bx
         neg       ax
         add       ds:[bp+kurzl-tabl],ax
         mov       ax,bx
pagedo5: mov       ds:[bp+firstl-tabl],ax
         call      files
pagedo6: pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------

insert:                                     ; oznaáen° souborñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         call      kurzoff
         mov       ax,ds:[bp+kurzl-tabl]
         mov       bx,20
         mul       bx
         add       ax,ds:[bp+adrfl-tabl]
         mov       di,ax
         test      byte ptr ds:[di],50h
         jz        insert1

         jnz       insert4
          ;
         cmp       word ptr ds:[di+1],".."
         je        insert4
insert1: xor       byte ptr ds:[di],80h
         mov       ax,word ptr ds:[di+12]
         mov       dx,word ptr ds:[di+14]
         test      byte ptr ds:[di],80h
         jz        insert2                  ; je zru®en°
         inc       word ptr ds:[bp+insfil-tabl]
         add       word ptr ds:[bp+kapfil-tabl],ax
         adc       word ptr ds:[bp+kapfil-tabl+2],dx
         jmp       short insert3
insert2: dec       word ptr ds:[bp+insfil-tabl]
         sub       word ptr ds:[bp+kapfil-tabl],ax
         sbb       word ptr ds:[bp+kapfil-tabl+2],dx
insert3: call      endline                  ; vykreslen° koncovÇ linky
insert4: call      kurzon
         call      movedown                 ; posun kurzoru dolñ
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------

invsel:                                     ; inverze vòbàru souborñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         mov       cx,ds:[bp+numfl-tabl]
         jcxz      invsel3
         mov       si,ds:[bp+adrfl-tabl]
invsel1: test      byte ptr ds:[si],50h
         jnz       invsel2                  ; je disk nebo adres†©
         xor       byte ptr ds:[si],80h     ; zmàna vòbàru

         mov       ax,word ptr ds:[si+12]
         mov       dx,word ptr ds:[si+14]
         test      byte ptr ds:[si],80h
         jz        invsel4                  ; je zru®en°
         inc       word ptr ds:[bp+insfil-tabl]
         add       word ptr ds:[bp+kapfil-tabl],ax
         adc       word ptr ds:[bp+kapfil-tabl+2],dx
         jmp       short invsel2
invsel4: dec       word ptr ds:[bp+insfil-tabl]
         sub       word ptr ds:[bp+kapfil-tabl],ax
         sbb       word ptr ds:[bp+kapfil-tabl+2],dx
invsel2: add       si,20
         loop      invsel1
         call      files                    ; zobrazen° adres†©e
         call      endline                  ; koncovò ©†dek
invsel3: pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------

enter:                                    ;* funkce ENTER

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         mov       al,ds:[numchar]
         cbw
         or        al,al                    ; je nàjakò znak v bufferu ?
         je        enter0                   ; v bufferu nen° ë†dnò znak
         call      testexit                 ; test EXIT
         jc        enter08

         mov       al,2
         jmp       short enter09

enter08:
         mov       si,offset buftxt         ; buffer textu
         push      si
         add       si,ax                    ; adresa konce textu v bufferu
         mov       byte ptr ds:[si],0       ; nastaven° koncovÇho bajtu 0
         pop       si
enter02:
         call      setenv                   ; z†pis do prost©ed°
         mov       al,0
         jnc       enter09                  ; z†pis OK - proveden° povelu

         call      openex                   ; otev©en° souboru MNEXEC.BAT
         jc        enter04                  ; chyba otev©en° souboru
         call      writte                   ; z†pis textu do bufferu
         jc        enter04
         call      closew                   ; uzav©en° souboru
         mov       al,1                     ; n†vratovò k¢d

enter09: add       sp,16                    ; zru®en° dat v z†sobn°ku
         push      ax
         lea       si,ds:[bp+pathl-tabl]    ; adresa cesty
         call      aktdir                   ; nastaven° aktivn° cesty
         pop       ax
         jmp       mainx                    ; n†vrat do systÇmu

enter04: jmp       enter7

enter0:  call      getkurz                  ; poskytnut° adres souboru s kurz.
         test      byte ptr ds:[si],10h     ; je adres†© ?
         jnz       enter2                   ; je adres†©
         test      byte ptr ds:[si],40h     ; je disk ?
         jnz       enter1                   ; je disk
                                          ;* proveden° p©°kazu s kurzorem
         mov       di,offset outbuf         ; tiskovò buffer
         cmp       word ptr ds:[si+9],"OC"  ; je soubor COM ?
         jne       enter05                  ; nen° souboru COM
         cmp       byte ptr ds:[si+11],"M"  ; je soubor COM ?
         je        enter07                  ; je soubor COM
enter05: cmp       word ptr ds:[si+9],"XE"  ; je soubor EXE ?
         jne       enter06                  ; nen° soubor EXE
         cmp       byte ptr ds:[si+11],"E"  ; je soubor EXE ?
         je        enter07                  ; je soubor EXE
enter06: cmp       word ptr ds:[si+9],"AB"  ; je soubor BAT ?
         jne       enter04                  ; nen° soubor BAT
         cmp       byte ptr ds:[si+11],"T"  ; je soubor BAT ?
         jne       enter04                  ; nen° soubor BAT
         push      si
         mov       si,offset txtcall        ; text CALL
         call      transtxt                 ; p©enos textu
         pop       si
enter07:
         push      di
         call      dekfile                  ; dek¢dov†n° jmÇna souboru
         pop       si

         mov       si,offset outbuf         ; buffer s textem
         jmp       short enter02            ; z†pis a proveden° p©°kazu

enter1:                                   ;* je zmàna disku
         mov       byte ptr ds:[namepath],0 ; zru®en° jmÇna cesty
         mov       al,ds:[si+6]             ; oznaáen° disku
         sub       al,"A"                   ; korekce na á°slo disku
         mov       dl,al                    ; poëadovanò novò disk
         mov       ah,0eh                   ; funkce nastaven° aktivn°ho disku
         int       21h                      ; nastaven° novÇho aktivn°ho disku
         lea       di,ds:[bp+pathl-tabl]    ; p©°stupov† cesta k adres†©i
         call      loadpath                 ; sestaven° novÇ p©°stupovÇ cesty
         call      readdir                  ; aktualizace - naáten° adres†©ñ
         call      window                   ; zobrazen° okna
         jmp       enter7
                                          ;* je zmàna adres†©e
enter2:                                   ;* £schova cesty pro n†vrat kurzoru
         push      si
         mov       di,offset namepath       ; £schova jmÇna cesty
         mov       ax,".."
         cmp       ax,ds:[si+1]             ; je cesta dolñ ?
         jne       enter5                   ; nen° cesta dolñ - uloëen° ".."
         cmp       byte ptr ds:[si+3]," "
         jne       enter5
                                          ;* uloëen° jmÇna adres†©e
         lea       si,ds:[bp+pathl-tabl]
         push      si
enter3:  lodsb
         or        al,al
         jz        enter4
         cmp       al,"\"
         jnz       enter3
         pop       ax
         push      si
         jmp       short enter3
enter4:  pop       si
         call      transtxt                 ; p©enos textu
         jmp       short enter6

enter5:  stosw                              ; bude cesta ".."
         xor       al,al
         stosb
enter6:  pop       si                       ; poloëka adres†©e v seznamu
                                          ;* p©epnut° adres†©e
         mov       di,offset outbuf         ; tiskovò buffer
         call      dekfile                  ; zak¢dov†n° jmÇna souboru
         lea       si,ds:[bp+pathl-tabl]    ; cesta k adres†©i
         call      aktdir                   ; nastaven° aktivn°ho adres†©e
         mov       si,di                    ; jmÇno novÇ cesty
         call      aktdir                   ; zapnut° novÇho adres†©e
         lea       di,ds:[bp+pathl-tabl]    ; p©°stupov† cesta k adres†©i
         call      loadpath                 ; sestaven° novÇ p©°stupovÇ cesty
         call      readdir                  ; aktualizace - naáten° adres†©ñ
         call      window                   ; zobrazen° okna
enter7:  pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------

testexit:
                                          ;* test p©°kazu EXIT
         mov       si,offset buftxt
         mov       cx,ax                    ; poáet znakñ
enter01: lodsb
         cmp       al,32
         jnb       enter03
         loop      enter01
         jmp       short exit1
enter03: call      highcase                 ; p©eveden° na velkÇ p°smeno
         cmp       al,"E"
         jne       exit1
         dec       cx
         jcxz      exit1
         lodsb
         call      highcase                 ; p©eveden° na velkÇ p°smeno
         cmp       al,"X"
         jne       exit1
         dec       cx
         jcxz      exit1
         lodsb
         call      highcase                 ; p©eveden° na velkÇ p°smeno
         cmp       al,"I"
         jne       exit1
         dec       cx
         jcxz      exit1
         lodsb
         call      highcase                 ; p©eveden° na velkÇ p°smeno
         cmp       al,"T"
         je        exit0
exit1:   stc
         ret

exit0:   clc
         ret

; -----------------------------------------------------------------------------

insch:                                      ; vloëen° znaku

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

         cmp       byte ptr ds:[numchar],128 ; poáet znakñ v bufferu
         jnb       insch3                   ; je jië maxim†ln° poáet znakñ
                                          ;* nejd©°ve se vytvo©° m°sto pro znak
         mov       cx,127
         sub       cl,ds:[pozbuf]           ; poáet znakñ do zbytku ©†dku
         mov       di,offset buftxt + 127
         mov       si,offset buftxt + 126
         std
         rep       movsb
         cld
                                          ;* uloëen° novÇho znaku
         mov       dl,ds:[pozbuf]           ; pozice v bufferu
         xor       dh,dh
         mov       di,offset buftxt
         add       di,dx                    ; adresa znaku v bufferu
         stosb
                                          ;* zvò®en° ukazatelñ
         inc       byte ptr ds:[pozbuf]     ; zvò®en° pozice v bufferu
         inc       byte ptr ds:[numchar]    ; zvò®en° poátu znakñ v bufferu
         inc       dl
         sub       dl,ds:[poztop]           ; offset od promptu
         add       dl,ds:[pozcomm]          ; offset od zaá†tku ©†dku
         cmp       dl,79
         jb        insch2
         inc       byte ptr ds:[poztop]
insch2:  call      obrcomt
insch3:  pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------

chleft:                                     ; posun o znak vlevo

         push      dx
         mov       dl,ds:[pozbuf]           ; pozice znaku v bufferu
         or        dl,dl                    ; je jië zaá†tek ?
         jz        chleft4                  ; je jië na zaá†tku
         dec       byte ptr ds:[pozbuf]     ; sn°ëen° pozice v bufferu
         dec       dl
         cmp       dl,ds:[poztop]           ; pozice zaá†tku textu
         ja        chleft4                  ; nen° je®tà na zaá†tku
         cmp       byte ptr ds:[poztop],0   ; je jië zaá†tek textu ?
         je        chleft4                  ; je jië zaá†tek textu
         dec       byte ptr ds:[poztop]     ; sn°ëen° zaá†tku textu
         call      obrcomt                  ; zobrazen° p©°kazovÇho ©†dku
chleft4: pop       dx
         ret

; -----------------------------------------------------------------------------

chright:                                    ; posun o znak vpravo

         push      dx
         push      di
         mov       dl,ds:[pozbuf]           ; pozice znaku v bufferu
         cmp       dl,ds:[numchar]          ; je jië konec textu ?
         jae       chrig2                   ; je jië konec textu
         inc       byte ptr ds:[pozbuf]     ; uloëen° novÇ pozice
         sub       dl,ds:[poztop]           ; offset od zaá†tku zobraz. textu
         add       dl,ds:[pozcomm]          ; offset od zaá†tku ©†dku
         cmp       dl,78                    ; je p©ekroáen konec ©†dku ?
         jb        chrig2                   ; nen° p©ekroáen konec ©†dku
         inc       byte ptr ds:[poztop]     ; zvò®en° pozice zaá†tku textu
         call      obrcomt                  ; zobrazen° textu
chrig2:  pop       di
         pop       dx
         ret

; -----------------------------------------------------------------------------

delchar:                                    ; vymaz†n° znaku nad kurzorem

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         mov       dl,ds:[pozbuf]           ; pozice v bufferu
         xor       dh,dh
         mov       di,offset buftxt
         add       di,dx                    ; adresa znaku v bufferu
         mov       si,di
         inc       si
         mov       cx,128
         sub       cx,dx                    ; poáet znakñ za kurzorem
         rep       movsb                    ; p©enos textu
         mov       al,ds:[pozbuf]           ; ukazatel kurzoru
         cmp       al,ds:[numchar]          ; je nàjakò znak za kurzorem ?
         jae       delchar1                 ; za kurzorem nen° ë†dnò znak
         dec       byte ptr ds:[numchar]    ; sn°ëen° poátu znakñ v bufferu
         call      obrcomt                  ; zobrazen° textu
delchar1:pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------

delbs:                                      ; zru®en° znaku p©ed kurzorem

         push      dx
         cmp       byte ptr ds:[pozbuf],0   ; je jië zaá†tek bufferu ?
         je        delbs1                   ; je jië zaá†tek bufferu
         call      chleft                   ; posun kurzoru vlevo
         call      delchar                  ; vymaz†n° znaku nad kurzorem
delbs1:  pop       dx
         ret

; -----------------------------------------------------------------------------

homer:                                      ; nastaven° prvn° pozice na ©†dku

         push      ax
         xor       al,al
         cmp       al,ds:[pozbuf]           ; je jië na prvn° pozici ?
         je        homer1                   ; je jië na prvn° pozici
         mov       ds:[pozbuf],al           ; pozice kurzoru v bufferu
         mov       ds:[poztop],al           ; prvn° zobrazen† pozice textu
         call      obrcomt                  ; zobrazen° textu
homer1:  pop       ax
         ret

; -----------------------------------------------------------------------------

endr:                                       ; nastaven° posledn° pozice na ©†dku

         push      ax
         push      dx
         mov       al,ds:[numchar]          ; poáet znakñ v bufferu
         or        al,al                    ; posledn° pozice textu
         jz        endr1                    ; nen° ë†dnò znak textu
         cmp       al,ds:[pozbuf]           ; pozice v bufferu
         je        endr1                    ; je jië na posledn° pozici bufferu
         mov       ds:[pozbuf],al           ; nastaven° posledn° pozice bufferu
         mov       dl,78                    ; posledn° zobrazen† pozice
         sub       dl,ds:[pozcomm]          ; poáet znakñ do konce ©†dku
         sub       al,dl                    ; pozice poá†tku ©†dku
         jns       endr2                    ; je p©ekroáen° konce ©†dku
         xor       al,al                    ; poá†teán° pozice = 0
endr2:   mov       ds:[poztop],al           ; poá†teán° zobrazen° textu
         call      obrcomt                  ; zobrazen° textu
endr1:   pop       dx
         pop       ax
         ret

; -----------------------------------------------------------------------------

ctrlent:                                    ; p©enesen° jmÇna souboru

         push      ax
         push      bx
         push      si
         push      di
         push      ds
         xor       ax,ax
         mov       ds,ax
         test      byte ptr ds:[417h],3     ; je Shift ?
         pop       ds
         jz        ctrlen4

         mov       bx,ds:[bp+kurzl-tabl]
         call      adrfile
         jc        ctrlen51
         test      byte ptr ds:[si],40h
         jz        ctrlen51

         mov       al,ds:[si+6]             ; oznaáen° disku
         cmp       al,ds:[bp+pathl-tabl]    ; je aktivn° disk ?
         je        ctrlen51                 ; je aktivn° adres†©
         sub       al,"A"
         mov       dl,al
         mov       ah,0eh
         int       21h
         mov       di,offset outbuf
         push      di
         call      loadpath
         pop       si
         jmp       short ctrlen5

ctrlen51:lea       si,ds:[bp+pathl-tabl]
ctrlen5: lodsb
         or        al,al
         jz        ctrlen6
         call      insch                    ; vloëen° znaku
         jmp       short ctrlen5
ctrlen6: cmp       byte ptr ds:[si-2],"\"
         je        ctrlen3
         mov       al,"\"
         jmp       short ctrlen7

ctrlen4:
         mov       bx,ds:[bp+kurzl-tabl]
         call      adrfile
         jc        ctrlen3
         test      byte ptr ds:[si],40h     ; je disk ?
         jz        ctrlen8                  ; nen° disk
         mov       al,ds:[si+6]             ; oznaáen° disku
         call      insch
         mov       al,":"
         jmp       short ctrlen7

ctrlen8: mov       di,offset outbuf         ; tiskovò buffer
         push      di
         call      dekfile                  ; dek¢dov†n° jmÇna souboru
         pop       si
ctrlen1: lodsb
         or        al,al
         jz        ctrlen2
         call      insch                    ; vloëen° znaku
         jmp       short ctrlen1
ctrlen2: mov       al," "
ctrlen7: call      insch
ctrlen3: pop       di
         pop       si
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------

xchgpg:                                   ;* zmàna str†nky displeje
         push      ax
         xor       byte ptr ds:[aktpage],2  ; zmàna aktivn° str†nky displeje
         mov       al,ds:[aktpage]          ; aktivn° str†nka displeje
         shr       al,1
         and       al,1
         mov       ah,5
         int       10h                      ; nastaven° novÇ aktivn° str†nky
         pop       ax
         ret

; -----------------------------------------------------------------------------

xchgw:                                    ;* zmàna okna

         push      ax
         push      bp
         test      byte ptr ds:[bp+flagsl-tabl],4 ; je levÇ okno ?
         mov       bp,offset tabr           ; p©°znak pravÇho okna
         jnz       xchgw1                   ; je levÇ okno
         mov       bp,offset tabl           ; p©°znak levÇho okna
xchgw1:  test      byte ptr ds:[aktpage],1
         jz        xchgw2                   ; nen° str†nka 1
         xor       byte ptr ds:[bp+flagsl-tabl],2 ; zmàna p©°znaku okna
         call      window                   ; zapnut° okna
xchgw2:  pop       bp
         pop       ax
         ret

; -----------------------------------------------------------------------------

sethlp:                                   ;* nastaven° n†povàdy

         xor       byte ptr ds:[flags],8    ; zmàna p©°znaku n†povàdy
         test      byte ptr ds:[flags],8
         jz        sethlp2                  ; n†povàda nen° aktivn°
         mov       si,offset txthelp
         mov       dx,24*256
         call      outtxt
sethlp2: push      bp
         call      obrcomm
         mov       ax,ds:[kurzl]
         sub       ax,ds:[firstl]
         cmp       ax,18
         jc        sethlp3
         inc       word ptr ds:[firstl]
sethlp3:
         mov       ax,ds:[kurzr]
         sub       ax,ds:[firstr]
         cmp       ax,18
         jc        sethlp4
         inc       word ptr ds:[firstr]
sethlp4:
         mov       bp,offset tabr           ; tabulka definice okna
         call      window                   ; zobrazen° okna
         mov       bp,offset tabl           ; tabulka definice okna
         call      window                   ; zobrazen° okna
         pop       bp
         ret

; -----------------------------------------------------------------------------

selmin:                                   ;* vòbàr souborñ pomoc° [-]

         mov       di,offset txtunsel       ; nadpis "zru®it vòbàr"
         xor       bl,bl                    ; p©°znak zru®en° oznaáen°
         jmp       short selfile

; -----------------------------------------------------------------------------

selplus:                                  ;* vòbàr souborñ pomoc° [+]

         mov       di,offset txtsel         ; nadpis "vybrat soubory"
         mov       bl,80h                   ; p©°znak nastaven° oznaáen°

selfile: mov       al,ds:[aktpage]          ; aktivn° str†nka
         shr       al,1                     ; AL / 2
         xor       al,ds:[aktpage]          ; porovn†n° str†nek
         and       al,1                     ; souhlas° str†nky ?
         jz        selplus0                 ; str†nky souhlas°
         ret
selplus0:mov       si,offset bufsel         ; buffer masek pro vòbàr
         mov       dl,8                     ; poá†tek pro pravÇ okno
         cmp       byte ptr ds:[bp+pozl-tabl],40 ; je levÇ nebo pravÇ okno ?
         jnb       selplus1                 ; je pravÇ okno
         mov       dl,46                    ; poá†tek pro levÇ okno
selplus1:mov       cl,25                    ; ®°©ka okna
         xor       dh,dh                    ; ©†dek okna automatickò
         mov       ch,12                    ; maxim†ln° vò®ka okna
         call      select                   ; zad†n° masky
         mov       di,ds:[bp+adrfl-tabl]    ; seznam souborñ
         mov       cx,ds:[bp+numfl-tabl]    ; poáet souborñ v seznamu
         jcxz      selplus6                 ; nen° ë†dnò soubor
selplusb:lodsb
         cmp       al," "                   ; je mezera p©ed textem ?
         jz        selplusb                 ; vypu®tàn° mezer p©ed textem
         dec       si                       ; n†vrat adresy zaá†tku ©etàzce
                                          ;* smyáka oznaáen° souborñ
selplus3:test      byte ptr ds:[di],50h     ; je disk nebo adres†© ?
         jnz       selplus5                 ; je disk nebo adres†©
         push      di
         push      si
         push      cx
         inc       di                       ; zaá†tek jmÇna souboru
                                          ;* test znakñ jmÇna
         mov       cx,8                     ; maxim†ln° poáet znakñ jmÇna
         call      cmpname                  ; porovn†n° jmÇna
         jnz       selplusm                 ; nen° shoda jmÇna
                                          ;* vypu®tàn° znakñ * a .
         lodsb                              ; naáten° dal®°ho znaku
         or        al,al                    ; byl konec ?
         jz        selpluse                 ; byl konec textu
         cmp       al,"."                   ; je oddàlovac° teáka ?
         jz        selplusi                 ; p©eskoáen° teáky
         cmp       al,"*"                   ; je n†hradn° znak "*" ?
         jnz       selpluse                 ; nen° znak "*"
         lodsb                              ; naáten° dal®°ho znaku
         cmp       al,"."                   ; je teáka ?
         je        selplusi                 ; p©eskoáen° teáky
selpluse:dec       si                       ; n†vrat pozice znaku
                                          ;* test znakñ p©°pony
selplusi:mov       cx,3                     ; maxim†ln° poáet znakñ p©°pony
         call      cmpname                  ; porovn†n° p©°pony
         jnz       selplusm                 ; nen° shoda p©°pony

         mov       al,ds:[di-12]            ; atributy
         xor       al,bl                    ; zmàna atributñ
         and       al,80h                   ; je zmàna atributñ ?
         jz        selplusm                 ; nen° zmàna atributñ
         and       byte ptr ds:[di-12],7fh  ; zru®en° oznaáen°
         or        ds:[di-12],bl            ; nastaven° vòbàru souboru

         push      dx
         mov       ax,word ptr ds:[di]
         mov       dx,word ptr ds:[di+2]
         test      byte ptr ds:[di-12],80h
         jz        selplusj                 ; je zru®en°
         inc       word ptr ds:[bp+insfil-tabl]
         add       word ptr ds:[bp+kapfil-tabl],ax
         adc       word ptr ds:[bp+kapfil-tabl+2],dx
         jmp       short selplusk
selplusj:dec       word ptr ds:[bp+insfil-tabl]
         sub       word ptr ds:[bp+kapfil-tabl],ax
         sbb       word ptr ds:[bp+kapfil-tabl+2],dx
selplusk:pop       dx

selplusm:pop       cx
         pop       si
         pop       di
selplus5:add       di,20                    ; zvò®en° adresy poloëky v seznamu
         loop      selplus3                 ; test dal®°ho souboru

selplus6:push      bp
         mov       bp,offset tabl
         call      window
         mov       bp,offset tabr
         call      window
         pop       bp

selplus9:ret

; -----------------------------------------------------------------------------

cmpname:                                  ;* porovn†n° jmÇna/p©°pony souboru
                                            ; VSTUP: DS:SI=jmÇno ASCII
                                            ;        DS:DI=jmÇno ve vnit©. tvaru
                                            ;        CX=poáet znakñ
                                            ; VùSTUP: SI,DI=novÇ pozice

cmpname1:lodsb                              ; znak zad†n°
         call      highcase                 ; p©evod znaku na velkÇ p°smeno
         or        al,al                    ; je konec zad†n° ?
         jz        cmpname2                 ; je konec textu zad†n°
         cmp       al,"."                   ; je oddàlovac° teáka ?
         jne       cmpname3                 ; nen° oddàlovac° teáka
cmpname2:dec       si                       ; n†vrat pozice
         mov       al," "                   ; n†hradn° znak - mezera
cmpname3:cmp       al,"*"                   ; je n†hradn° znak "*" ?
         jne       cmpname4
         dec       si                       ; n†vrat ukazatele na znak "*"
         mov       al,"?"                   ; n†hradn° znak "?"
cmpname4:cmp       al,"?"                   ; je n†hradn° znak "?" ?
         je        cmpname5                 ; znak se nekontroluje
         cmp       al,ds:[di]               ; je shoda znakñ ?
         jnz       cmpname6                 ; nen° shoda znakñ
cmpname5:inc       di                       ; zvò®en° pozice v seznamu
         loop      cmpname1                 ; test dal®°ho znaku jmÇna
         xor       al,al                    ; p©°znak ZF=shoda
cmpname6:ret

; -----------------------------------------------------------------------------

copyfile:                                 ;* kop°rov†n° souboru

         mov       si,offset bufcopy        ; buffer poloëek
         mov       di,offset txtcopy        ; text nadpis
         mov       ch,16
         mov       cl,76
         mov       dl,2
         call      select
         push      bp
         mov       bp,offset tabl
         call      window
         mov       bp,offset tabr
         call      window
         pop       bp
         ret

; -----------------------------------------------------------------------------

;numchar  db        0                        ; poáet znakñ v bufferu
;poztop   db        0                        ; pozice zaá†tku zobrazenÇho textu
;pozcomm  db        0                        ; pozice zaá†tku textu na displeji
;pozbuf   db        0                        ; pozice kurzoru v textovÇm bufferu
;buftxt   db        129 dup(0)               ; textovò buffer
; -----------------------------------------------------------------------------

select:                                   ;* zad†n° volby
                                            ; VSTUP: DS:SI=buffer pro zad†n°
                                            ;        DS:DI=text nadpisu
                                            ;        DL=poá†tek okna (0=aut.)
                                            ;        DH=©†dek okna (0=aut.)
                                            ;        CL=®°©ka okna (0=aut.)
                                            ;        CH=max. vò®ka okna
                                            ; VùSTUP: DS:SI=ukazatel na ©etàzec
                                            ;         AX=ukonáovac° kl†vesa

         push      es
         push      ds
         pop       es
         push      bx
         push      dx
         push      cx
         call      testsel                  ; test bufferu zad†n°
         call      setwsel                  ; nastaven° parametrñ okna voleb
         call      selwin                   ; vykreslen° okna pro volby
select1: call      selall                   ; zobrazen° poloëek voleb

                                            ;        BH=maxim. dÇlka ©etàzce
                                            ;        BL=poáet poloëek
                                            ;        DL=poá†tek okna (0=aut.)
                                            ;        DH=©†dek okna (0=aut.)
                                            ;        CL=®°©ka okna (0=aut.)
                                            ;        CH=max. vò®ka okna (0=max.)

select2: call      setkurzs                 ; nastaven° kurzoru pro select
         xor       ah,ah
         int       16h                      ; áek†n° na znak z kl†vesnice
                                          ;* <Esc>
select21:
                                          ;* kurzor nahoru
select3: cmp       ax,4800h                 ; kurzor nahoru
         jne       select4
         mov       al,ds:[kurzsel]
         or        al,al                    ; je jië prvn° pozice ?
         jz        select2                  ; je jië prvn° pozice
select32:dec       al                       ; sn°ëen° pozice kurzoru
         mov       ds:[kurzsel],al          ; nov† pozice kurzoru
         cmp       al,ds:[firstsel]         ; je jië nad prvn° poloëkou ?
         jnb       select31                 ; nen° nad prvn° poloëkou
         dec       byte ptr ds:[firstsel]   ; sn°ëen° prvn° poloëky
         jmp       short select1            ; novÇ zobrazen° okna

select31:mov       al,ds:[kurzsel]          ; pozice s kurzorem
         call      selpol                   ; zobrazen° novÇ poloëky
         inc       al                       ; nov† pozice
         call      selpol                   ; zobrazen° pñvodn° poloëky
         jmp       short select2
                                          ;* kurzor dolñ
select4: cmp       ax,5000h                 ; kurzor dolñ
         jne       select5
         mov       al,ds:[kurzsel]          ; pozice kurzoru
         inc       al                       ; nov† pozice kurzoru
         cmp       al,bl                    ; je jië konec poloëek ?
         jnb       select2                  ; je jië konec
         inc       byte ptr ds:[kurzsel]    ; zvò®en° pozice kurzoru
         sub       al,ds:[firstsel]         ; <- poáet poloëek na displeji
         add       al,4                     ; + okraje
         cmp       al,ch                    ; nep©esahuje okraj okna ?
         jb        select41                 ; nen° je®tà pod okrajem okna
         inc       byte ptr ds:[firstsel]   ; zvò®en° prvn° poloëky
         jmp       short select1
select41:mov       al,ds:[kurzsel]          ; pozice s kurzorem
         call      selpol                   ; zobrazen° novÇ poloëky
         dec       al                       ; nov† pozice
         call      selpol                   ; zobrazen° pñvodn° poloëky
select45:jmp       select2
                                          ;* Page Up, Ctrl-Page Up
select5: cmp       ax,8400h                 ; je Ctrl-Page Up ?
         je        select51
         cmp       ax,4900h                 ; je str†nka nahoru ? (=prvn° pol.)
         jne       select6
select51:cmp       byte ptr ds:[kurzsel],0  ; je jië prvn° poloëka ?
         je        select45                 ; je jië prvn° poloëka
select52:xor       al,al
         mov       ds:[firstsel],al         ; prvn° zobrazenò poloëka = 0
         mov       ds:[kurzsel],al          ; nastaven° kurzoru
select55:jmp       select1
                                          ;* Page Down, Ctrl-Page Down
select6: cmp       ax,7600h                 ; je Ctrl-Page Down
         je        select61
         cmp       ax,5100h                 ; je str†nka dolñ ?
         jne       select7
select61:mov       al,bl                    ; poáet poloëek
         dec       al                       ; á°slo posledn° poloëky
         cmp       al,ds:[kurzsel]          ; je jië posledn° poloëka ?
         je        select45                 ; je jië posledn° poloëka
         mov       ds:[kurzsel],al          ; nastaven° novÇho kurzoru
         sub       al,ch
         add       al,5                     ; p©iáten° okrajñ
         mov       ds:[firstsel],al         ; nastaven° prvn° zobrazenÇ poloëky
         jmp       short select55

select7:                                  ;* je jin† kl†vesa - editace
         cmp       al,27                    ; je <Esc> ?
         je        select22

         call      editsel                  ; editace ©†dku volby
         cmp       al,0dh                   ; je Enter ?
         je        select22                 ; je Enter
         jmp       select21                 ; obsluha ©°dic° kl†vesy

                                          ;* <Enter>
select22:
         pop       cx
         pop       dx
         pop       bx
         pop       es
         ret


; -----------------------------------------------------------------------------

editsel:                                  ;* editace poloëky volby
                                            ; VSTUP: AX=prvn° kl†vesa
                                            ;        DS:SI=buffer poloëek
                                            ;        DL=poá†tek okna
                                            ;        DH=©†dek okna
                                            ;        CL=®°©ka okna
                                            ;        CH=vò®ka okna

         push      bx
         push      cx
         push      dx
         push      di

                                          ;* inicializace parametrñ pro editaci
edits01: mov       byte ptr ds:[ukazsel],0  ; nulov†n° ukazatele kurzoru
         mov       byte ptr ds:[topsel],0   ; nulov†n° poá†tku zobrazen°
         mov       byte ptr ds:[numselb],0  ; nulov†n° poátu znakñ v bufferu
         cmp       al,32                    ; je platnò znak ?
         jnb       edits22                  ; je platnò znak ASCII - nulov†n°
         call      obnov                    ; obnoven° ©†dku
         jmp       short edits22            ; proveden° obsluhy kl†vesy

edits2:  call      kurzedsel                ; zobrazen° kurzoru na ©†dku
edits21: xor       ah,ah
         int       16h                      ; áek†n° na vstup z kl†vesnice
                                          ; <Esc>, <Enter>
edits22: cmp       al,27                    ; je <Esc> ?
         jz        edits27
         cmp       al,13                    ; je <Enter> ?
         jnz       edits28
         call      storesel                 ; uloëen° poloëky do bufferu
                                            ; DS:SI=adresa textu
edits27:
         pop       di
         pop       dx
         pop       cx
         pop       bx
         ret

edits28:                                  ;* platnò znak ASCII
         cmp       al,7fh
         je        edits3                   ; je znak Ctrl-<BS>
         cmp       al,32                    ; je platnò znak ?
         jb        edits3                   ; nen° platnò znak ASCII
         call      inschsel                 ; vloëen° znaku do bufferu SELECT
         jmp       short edits2
                                          ;* kurzor vlevo
edits3:  cmp       ax,4b00h                 ; je kurzor vlevo ?
         jne       edits4

         call      selleft                  ; posun kurzoru vlevo
         jmp       short edits2
                                          ;* kurzor vpravo
edits4:  cmp       ax,4d00h                 ; je kurzor vpravo
         jne       edits5

         call      selright                 ; posun kurzoru vpravo
         jmp       short edits2
                                          ;* zaá†tek ©†dku
edits5:  cmp       ax,4700h                 ; je kl†vesa <Home> ?
         jne       edits6

         call      selhome                  ; posun na zaá†tek ©†dku
         jmp       short edits2
                                          ;* konec ©†dku
edits6:  cmp       ax,4f00h                 ; je kl†vesa <End> ?
         jne       edits7

         call      selend                   ; posun na konec ©†dku
         jmp       short edits2
                                          ;* vymaz†n° znaku za kurzorem Del
edits7:  cmp       ax,5300h                 ; je kl†vesa <Delete> ?
         jne       edits8

         call      seldel                   ; vymaz†n° znaku nad kurzorem
         jmp       short edits2

edits8:  cmp       al,8                     ; je kl†vesa <BS> ?
         jne       edits9

         call      seldelbs                 ; vymaz†n° znaku nad kurzorem
         jmp       short edits2

edits9:  cmp       al,19h                   ; je Ctrl-Y ?
         jne       editsa

         mov       byte ptr ds:[ukazsel],0  ; nulov†n° ukazatele kurzoru
         mov       byte ptr ds:[topsel],0   ; nulov†n° poá†tku zobrazen°
         mov       byte ptr ds:[numselb],0  ; nulov†n° poátu znakñ v bufferu
         call      obredit                  ; zobrazen° ©†dku
         jmp       short edits2

editsa:  cmp       al,0ch                   ; je Ctrl-L ?
         jne       editsb

         call      obnov                    ; obnoven° ©†dku textu
         jmp       edits2

editsb:  cmp       ax,7300h                 ; slovo vlevo
         jne       editsc

         call      selwleft                 ; skok o slovo vlevo
         jmp       edits2

editsc:  cmp       ax,7400h                 ; slovo vpravo
         jne       editsd

         call      selwright                ; skok o slovo vpravo
         jmp       edits2

editsd:  cmp       al,14h                   ; Ctrl-T
         jne       editse                   ; je vymaz†n° slova vpravo

         call      delwr                    ; vymaz†n° slova vpravo
         jmp       edits2

editse:  cmp       al,7fh                   ; Ctrl-<BS>
         jne       editsf

         call      delwl                    ; vymaz†n° slova vlevo
         jmp       edits2

editsf:

editsx:
         cmp       ax,4800h                 ; kurzor nahoru ?
         je        editsx1
         cmp       ax,5000h                 ; kurzor dolñ ?
         je        editsx1
         cmp       ax,4900h                 ; Pge Up ?
         je        editsx1
         cmp       ax,8400h                 ; Ctrl-Page Up
         je        editsx1
         cmp       ax,5100h                 ; Page Down ?
         je        editsx1
         cmp       ax,7600h                 ; Ctrl-Page Down ?
         je        editsx1
         jmp       edits21

editsx1: call      obnov                    ; obnoven° ©†dku
         jmp       edits27



;numselb  db        0                        ; poáet znakñ v bufferu pro vòbàr
;ukazsel  db        0                        ; ukazatel kurzoru pro buffer vòbàru
;topsel   db        0                        ; zaá†tek zobrazenÇho textu volby
;firstsel db        0                        ; prvn° zobrazen† poloëka voleb
;kurzsel  db        0                        ; kurzor pro volby
; selbuf  db 128 dup(?)                     ; buffer

; -----------------------------------------------------------------------------

storesel:                                 ;* uloëen° poloëky do bufferu
                                            ; VSTUP:DS:SI=buffer poloëek
                                            ; VùSTUP: DS:SI=adresa textu ASCIIZ

         push      ax
         push      bx
         push      cx
         push      di
         call      srcident                 ; nalezen° stejnÇ poloëky v seznamu
         jc        stores1                  ; stejn† poloëka nenalezena
         call      delselect                ; vypu®tàn° poloëky ze seznamu
stores1: mov       di,si                    ; zaá†tek bufferu
         mov       cx,ds:[si]               ; dÇlka bufferu
         inc       di
stores3: inc       di                       ; n†sleduj°c° adresa
         cmp       word ptr ds:[di],0       ; je konec bufferu ?
         loopnz    stores3                  ; nalezen° konce bufferu
         push      di
         sub       di,2
         cmp       si,di
         pop       di
         je        stores2
         inc       di
stores2: mov       bl,ds:[numselb]          ; dÇlka dat v bufferu
         xor       bh,bh
         push      bx
         add       bx,4                     ; rezerva pro koncovÇ nuly
         cmp       bx,cx                    ; postaáuje kapacita ?
         pop       bx
         jb        stores4                  ; kapacita postaáuje
         xor       al,al                    ; ru®° se poloëka 0
         call      delselect                ; zru®en° poloëky 0
         jmp       short stores1
stores4: mov       cx,bx                    ; dÇlka dat k p©enosu
         mov       si,offset selbuf         ; buffer s textem
         push      di                       ; adresa zaá†tku textu
         rep       movsb                    ; uloëen° textu
         xor       ax,ax
         stosw                              ; uloëen° koncovÇho slova 0
         pop       si                       ; text zad†n°
         pop       di
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------

srcident:                                 ;* nalezen° stejnÇ poloëky ze seznamu
                                            ; VSTUP:DS:SI=buffer poloëek
                                            ; VùSTUP: AL=á°slo poloëky
                                            ;         CY=poloëka nenalezena

         push      bx
         push      cx
         push      dx
         push      si
         push      di
                                          ;* nastaven° parametrñ
         lodsw                              ; dÇlka bufferu
         mov       cx,ax                    ; dÇlka bufferu
         xor       bh,bh                    ; á°taá ©etàzcñ textñ
         mov       bl,ds:[numselb]          ; dÇlka textu v bufferu
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
         add       cx,si                    ; adresa konce bufferu
         mov       ah,al                    ; á°taá ©etàzcñ
         add       si,2                     ; zaá†tek textñ
delsel2: cmp       byte ptr ds:[si],0       ; je jië konec bufferu ?
         stc                                ; p©°znak chyby
         jz        delsel4                  ; je konec bufferu - nenalezen
         or        ah,ah                    ; je poëadovanò ©etàzec ?
         jz        delsel3                  ; nalezen poëadovanò ©etàzec
delsel5: lodsb                              ; naáten° znaku
         or        al,al                    ; je konec ©etàzce ?
         jnz       delsel5                  ; nen° je®tà konec ©etàzce
         dec       ah                       ; sn°ëen° á°taáe ©etàzcñ
         jmp       short delsel2            ; dal®° ©etàzec

;         call      asksel                   ; nalezen° poloëky v seznamu
;         jc        delsel4                  ; poloëka nenalezena
delsel3: sub       cx,si                    ; dÇlka zbytku bufferu
         mov       di,si                    ; £schova zaá†tku ru®enÇ poloëky
                                          ;* nalezen° adresy n†sleduj°c° poloëky
         cmp       byte ptr ds:[si],0       ; n†sleduje nàjak† poloëka ?
         jne       delsel1                  ; je nàjak† poloëka
         mov       byte ptr ds:[di],0       ; zru®en° poloëky
         jmp       short delsel4
delsel1: lodsb                              ; naáten° znaku poloëky
         or        al,al                    ; je konec poloëky ?
         loopnz    delsel1                  ; nalezen° konce poloëky
         jcxz      delsel4
         rep       movsb                    ; p©enos textu - vypu®tàn° poloëky
delsel4: pop       di
         pop       si
         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------

delwr:                                    ;* vymaz†n° slova vpravo

         push      ax
         push      bx
         push      cx
         push      dx
                                          ;* vymaz†n° platnòch znakñ
delwr1:  mov       al,ds:[ukazsel]          ; pozice znaku v bufferu
         cmp       al,ds:[numselb]          ; je jië na konci ©†dku ?
         je        delwr4                   ; je jië posledn° pozice
         xor       ah,ah
         push      si
         mov       si,offset selbuf
         add       si,ax                    ; pozice znaku nad kurzorem
         lodsb                              ; naáten° znaku nad kurzorem
         pop       si
         call      testchar                 ; test, zda je oddàlovac° znak
         jc        delwr2                   ; je oddàlovac° znak
         call      seldel                   ; vymaz†n° znaku nad kurzorem
         jmp       delwr1
                                          ;* vymaz†n° oddàlovac°ch znakñ
delwr2:  mov       al,ds:[ukazsel]          ; pozice znaku v bufferu
         cmp       al,ds:[numselb]          ; je jië na konci ©†dku ?
         je        delwr4                   ; je jië posledn° pozice
         xor       ah,ah
         push      si
         mov       si,offset selbuf
         add       si,ax                    ; pozice n†sleduj°c°ho znaku
         lodsb                              ; naáten° n†sleduj°c°ho znaku
         pop       si
         call      testchar                 ; test, zda je oddàlovac° znak
         jnc       delwr4                   ; nen° oddàlovac° znak - konec
         call      seldel                   ; vymaz†n° znaku nad kurzorem
         jmp       short delwr2             ; dal®° znak
delwr4:  pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------

delwl:                                    ;* vymaz†n° slova vlevo

         push      ax
         push      bx
         push      cx
         push      dx
                                          ;* vymaz†n° oddàlovac°ch znakñ
delwl1:  mov       al,ds:[ukazsel]          ; pozice znaku v bufferu
         or        al,al
         jz        delwl4                   ; je jië prvn° pozice
         xor       ah,ah
         push      si
         mov       si,offset selbuf
         dec       al
         add       si,ax                    ; pozice znaku p©ed kurzorem
         lodsb                              ; naáten° znaku p©ed kurzorem
         pop       si
         call      testchar                 ; test, zda je oddàlovac° znak
         jnc       delwl2                   ; nen° oddàlovac° znak
         call      seldelbs                 ; vymaz†n° znaku p©ed kurzorem
         jmp       short delwl1
                                          ;* vymaz†n° platnòch znakñ
delwl2:  mov       al,ds:[ukazsel]          ; pozice znaku v bufferu
         or        al,al
         jz        delwl4                   ; je jië prvn° pozice
         xor       ah,ah
         push      si
         mov       si,offset selbuf
         dec       al
         add       si,ax                    ; pozice znaku p©ed kurzorem
         lodsb                              ; naáten° znaku p©ed kurzorem
         pop       si
         call      testchar                 ; test, zda je oddàlovac° znak
         jc        delwl3                   ; je oddàlovac° znak - konec
         call      seldelbs                 ; vymaz†n° znaku p©ed kurzorem
         jmp       short delwl2             ; dal®° znak
delwl3:  mov       al,ds:[ukazsel]          ; pozice znaku v bufferu
         push      ax                       ; £schova pozice
         call      selleft                  ; posun o znak vlevo
         call      selleft                  ; posun o znak vlevo
         call      selleft                  ; posun o znak vlevo
         call      selleft                  ; posun o znak vlevo
         call      selleft                  ; posun o znak vlevo
         call      selleft                  ; posun o znak vlevo
         pop       ax
delwl31: cmp       al,ds:[ukazsel]          ; je jië navr†cena pozice ?
         jbe       delwl32                  ; pozice je navr†cena
         push      ax
         call      selright                 ; posun o znak vpravo
         pop       ax
         jmp       short delwl31            ; posun o dal®° znak
delwl32: call      obredit                  ; zobrazen° ©†dku
delwl4:  pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------

selwleft:                                 ;* posun o slovo vlevo

         push      ax
         push      bx
         push      cx
         push      dx
                                          ;* vypu®tàn° oddàlovac°ch znakñ
selwl1:  call      selleft                  ; posun o znak vlevo
         mov       al,ds:[ukazsel]          ; pozice znaku v bufferu
         or        al,al                    ; je jië na prvn° pozici ?
         jz        selwl4                   ; je jië prvn° pozice
         xor       ah,ah
         push      si
         mov       si,offset selbuf
         add       si,ax                    ; pozice novÇho znaku
         lodsb                              ; naáten° znaku
         pop       si
         call      testchar                 ; test, zda je oddàlovac° znak
         jc        selwl1                   ; je oddàlovac° znak - dal®° znak
                                          ;* vypu®tàn° platnòch znakñ
selwl2:  mov       al,ds:[ukazsel]          ; pozice znaku v bufferu
         or        al,al                    ; je jië na prvn° pozici ?
         jz        selwl4                   ; je jië prvn° pozice
         xor       ah,ah
         push      si
         mov       si,offset selbuf
         dec       al                       ; n†sleduj°c° znak
         add       si,ax                    ; pozice n†sleduj°c°ho znaku
         lodsb                              ; naáten° n†sleduj°c°ho znaku
         pop       si
         call      testchar                 ; test, zda je oddàlovac° znak
         jc        selwl4                   ; je oddàlovac° znak - konec
         call      selleft                  ; posun na dal®° pozici
         jmp       short selwl2             ; dal®° znak
selwl4:  pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------

selwright:                                ;* posun o slovo vpravo

         push      ax
         push      bx
         push      cx
         push      dx
                                          ;* vypu®tàn° platnòch znakñ
selwr1:  mov       al,ds:[ukazsel]          ; pozice znaku v bufferu
         cmp       al,ds:[numselb]          ; je jië na konci ©†dku ?
         je        selwr4                   ; je jië posledn° pozice
         push      ax                       ; £schova pozice
         call      selright                 ; posun o znak vpravo
         pop       ax
         xor       ah,ah
         push      si
         mov       si,offset selbuf
         add       si,ax                    ; pozice posledn°ho znaku
         lodsb                              ; naáten° posledn°ho znaku
         pop       si
         call      testchar                 ; test, zda je oddàlovac° znak
         jnc       selwr1                   ; nebyl oddàlovac° znak - dal®° znak
                                          ;* vypu®tàn° oddàlovac°ch znakñ
selwr2:  mov       al,ds:[ukazsel]          ; pozice znaku v bufferu
         cmp       al,ds:[numselb]          ; je jië na konci ©†dku ?
         jz        selwr4                   ; je jië posledn° pozice
         xor       ah,ah
         push      si
         mov       si,offset selbuf
         add       si,ax                    ; pozice n†sleduj°c°ho znaku
         lodsb                              ; naáten° n†sleduj°c°ho znaku
         pop       si
         call      testchar                 ; test, zda je oddàlovac° znak
         jnc       selwr4                   ; nen° oddàlovac° znak - konec
         call      selright                 ; posun na dal®° pozici
         jmp       short selwr2             ; dal®° znak
selwr4:  pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------

testchar:                                 ;* test znaku, zda je oddàlovac°
                                            ; VSTUP: AL=znak
                                            ; VùSTUP: CY=je oddàlovac° znak

         cmp       al,"!"
         je        testch5
         cmp       al,"#"
         je        testch5
         cmp       al,"$"
         je        testch5
         cmp       al,"%"
         je        testch5
         cmp       al,"*"
         je        testch5
         cmp       al,"0"
         jb        testch6
         cmp       al,"9"+1
         jb        testch5
         cmp       al,"@"
         jb        testch6
         cmp       al,"Z"+1
         jb        testch5
         cmp       al,"a"
         jb        testch6
         cmp       al,"z"+1
         jb        testch5
         cmp       al,128
         jb        testch6
testch5: clc                                ; p©°znak - nen° oddàlovac° znak
         ret
testch6: stc                                ; p©°znak - je oddàlovac° znak
         ret

; -----------------------------------------------------------------------------

obnov:                                    ;* obnoven° ©†dku textu
                                            ; VSTUP:DS:SI=buffer poloëek
                                            ;       DL=poá†tek okna
                                            ;       DH=©†dek okna
                                            ;       CL=®°©ka okna
                                            ;       CH=vò®ka okna

         push      ax
         push      cx
         push      si
         mov       byte ptr ds:[ukazsel],0  ; nulov†n° ukazatele kurzoru
         mov       byte ptr ds:[topsel],0   ; nulov†n° poá†tku zobrazen°
         mov       al,ds:[kurzsel]          ; á°slo editovanÇ poloëky
         call      asksel                   ; poskytnut° adresy poloëky
         cmp       al,128                   ; je dÇlka vàt®° neë 128 ?
         jna       obnov1                   ; dÇlka nen° vàt®° neë 128
         mov       al,128                   ; omezen° na dÇlku 128
obnov1:  mov       ds:[numselb],al          ; poáet znakñ textu
         mov       cl,al                    ; dÇlka poloëky
         xor       ch,ch                    ; CH <- 0
         jcxz      obnov2                   ; nen° ë†dnò znak k p©enosu
         mov       di,offset selbuf         ; buffer pro editaci textu
         rep       movsb                    ; p©enos textu do bufferu
obnov2:  pop       si
         pop       cx
         pop       ax
         call      obredit                  ; zobrazen° ©†dku
         call      kurzedsel                ; zobrazen° kurzoru na ©†dku
         ret

; -----------------------------------------------------------------------------

seldel:                                   ;* vymaz†n° znaku nad kurzorem

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         mov       dl,ds:[ukazsel]          ; pozice v bufferu
         xor       dh,dh
         mov       di,offset selbuf
         add       di,dx                    ; adresa znaku v bufferu
         mov       si,di
         inc       si
         mov       cx,128
         sub       cx,dx                    ; poáet znakñ za kurzorem
         rep       movsb                    ; p©enos textu
         pop       di
         pop       si
         pop       dx
         pop       cx
         mov       al,ds:[ukazsel]          ; ukazatel kurzoru
         cmp       al,ds:[numselb]          ; je nàjakò znak za kurzorem ?
         jae       seldel1                  ; za kurzorem nen° ë†dnò znak
         dec       byte ptr ds:[numselb]    ; sn°ëen° poátu znakñ v bufferu
         call      obredit                  ; zobrazen° textu
seldel1: pop       ax
         ret

; -----------------------------------------------------------------------------

seldelbs:                                 ;* zru®en° znaku p©ed kurzorem

         push      dx
         cmp       byte ptr ds:[ukazsel],0  ; je jië zaá†tek bufferu ?
         je        seldbs1                  ; je jië zaá†tek bufferu
         call      selleft                  ; posun kurzoru vlevo
         call      seldel                   ; vymaz†n° znaku nad kurzorem
seldbs1: pop       dx
         ret

; -----------------------------------------------------------------------------

selend:                                   ;* posun na konec ©†dku

         push      ax
         mov       al,ds:[numselb]          ; poáet znakñ v bufferu
         or        al,al                    ; posledn° pozice textu
         jz        selend2                  ; nen° ë†dnò znak textu
         cmp       al,ds:[ukazsel]          ; pozice v bufferu
         je        selend2                  ; je jië na posledn° pozici bufferu
         mov       ds:[ukazsel],al          ; nastaven° posledn° pozice bufferu
         push      cx
         sub       cl,11                    ; skuteán† ®°©ka ©†dku
         sub       al,cl                    ; pozice poá†tku ©†dku
         jns       selend1                  ; je p©ekroáen° konce ©†dku
         xor       al,al                    ; poá†teán° pozice = 0
selend1: mov       ds:[topsel],al           ; poá†teán° zobrazen° textu
         pop       cx
         call      obredit                  ; zobrazen° textu
selend2: pop       ax
         ret

; -----------------------------------------------------------------------------

selhome:                                  ;* posun na zaá†tek ©†dku

         push      ax
         xor       al,al
         cmp       al,ds:[ukazsel]          ; je jië na prvn° pozici ?
         je        selhom1                  ; je jië na prvn° pozici
         mov       ds:[ukazsel],al          ; pozice kurzoru v bufferu
         mov       ds:[topsel],al           ; prvn° zobrazen† pozice textu
         call      obredit                  ; zobrazen° textu
selhom1: pop       ax
         ret

; -----------------------------------------------------------------------------

selright:                                   ; posun o znak vpravo

         push      di
         push      cx
         push      dx
         sub       cl,12                    ; ®°©ka textu
         mov       dl,ds:[ukazsel]          ; pozice znaku v bufferu
         cmp       dl,ds:[numselb]          ; je jië konec textu ?
         jae       selrg2                   ; je jië konec textu
         inc       byte ptr ds:[ukazsel]    ; uloëen° novÇ pozice
         push      dx
         add       dl,3
         cmp       dl,ds:[numselb]          ; je p©edposledn° znak ?
         pop       dx
         je        selrg1                   ; je posledn° znak
         sub       dl,ds:[topsel]           ; offset od zaá†tku zobraz. textu
         cmp       dl,cl                    ; je p©ekroáen konec ©†dku ?
         jb        selrg2                   ; nen° p©ekroáen konec ©†dku
         inc       byte ptr ds:[topsel]     ; zvò®en° pozice zaá†tku textu
selrg1:  pop       dx
         pop       cx
         call      obredit                  ; zobrazen° textu
         push      cx
         push      dx
selrg2:  pop       dx
         pop       cx
         pop       di
         ret

; -----------------------------------------------------------------------------

selleft:                                    ; posun o znak vlevo

         push      dx
         mov       dl,ds:[ukazsel]          ; pozice znaku v bufferu
         or        dl,dl                    ; je jië zaá†tek ?
         jz        selleft1                 ; je jië na zaá†tku
         dec       byte ptr ds:[ukazsel]    ; sn°ëen° pozice v bufferu
         dec       dl
         cmp       dl,ds:[topsel]           ; pozice zaá†tku textu
         ja        selleft1                 ; nen° je®tà na zaá†tku
         cmp       byte ptr ds:[topsel],0   ; je jië zaá†tek textu ?
         je        selleft1                 ; je jië zaá†tek textu
         dec       byte ptr ds:[topsel]     ; sn°ëen° zaá†tku textu
         pop       dx
         call      obredit                  ; zobrazen° p©°kazovÇho ©†dku
         push      dx
selleft1:pop       dx
         ret

; -----------------------------------------------------------------------------

inschsel:                                 ;* vloëen° znaku do bufferu SELECT
                                            ; VSTUP: AL=znak k uloëen°

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

         cmp       byte ptr ds:[numselb],128 ; poáet znakñ v bufferu
         jnb       inschs3                   ; je jië maxim†ln° poáet znakñ
                                          ;* nejd©°ve se vytvo©° m°sto pro znak
         mov       bl,cl                    ; ®°©ka okna
         sub       bl,10                    ; skuteán† ®°©ka textu
         mov       cx,127
         sub       cl,ds:[ukazsel]           ; poáet znakñ do zbytku ©†dku
         mov       di,offset selbuf + 127
         mov       si,offset selbuf + 126
         std                                ; smàr p©enosu dolñ
         rep       movsb                    ; p©enos textu - Insert
         cld                                ; smàr p©enosu nahoru
                                          ;* uloëen° novÇho znaku
         mov       dl,ds:[ukazsel]           ; pozice v bufferu
         xor       dh,dh
         mov       di,offset selbuf         ; buffer textu
         add       di,dx                    ; adresa znaku v bufferu
         stosb                              ; uloëen° znaku
                                          ;* zvò®en° ukazatelñ
         inc       byte ptr ds:[ukazsel]    ; zvò®en° pozice v bufferu
         inc       byte ptr ds:[numselb]    ; zvò®en° poátu znakñ v bufferu
         inc       dl                       ; nov† pozice v bufferu
         sub       dl,ds:[topsel]           ; offset od zaá†tku ©†dku
         cmp       dl,bl                    ; p©esahuje konec ©†dku ?
         jb        inschs3
         inc       byte ptr ds:[topsel]     ; zvò®en° poá†teán°ho offsetu
         stc
inschs3: pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         jnc       inschs2                  ; neprovede se zobrazen° ©†dku
         call      obredit                  ; zobrazen° editovanÇho ©†dku
inschs2: ret

; -----------------------------------------------------------------------------

kurzedsel:                                ;* zobrazen° kurzoru p©i editaci SEL.
                                            ; VSTUP: DL=poá†tek okna
                                            ;        DH=©†dek okna
                                            ;        CL=®°©ka okna
                                            ;        CH=vò®ka okna

         push      ax
         push      dx
         add       dh,2                     ; p©eskoáen° horn°ho okraje
         add       dh,ds:[kurzsel]          ; p©iáten° á°sla poloëky s kurzorem
         sub       dh,ds:[firstsel]         ; odeáten° á°sla prvn° poloëky
         add       dl,5                     ; p©eskoáen° levÇho okraje
         add       dl,ds:[ukazsel]          ; p©iáten° ukazatele v bufferu
         sub       dl,ds:[topsel]           ; odeáten° poá†tku zobrazen°
         xor       al,al                    ; p©°znak nastaven° kurzoru
         call      outch1                   ; nastaven° pozice kurzoru
         pop       dx
         pop       ax
         ret

; -----------------------------------------------------------------------------

obredit:                                  ;* zobrazen° editovanÇho ©†dku
                                            ; VSTUP: DL=poá†tek okna
                                            ;        DH=©†dek okna
                                            ;        CL=®°©ka okna
                                            ;        CH=vò®ka okna
         push      si
         push      ax
         push      bx
         push      cx
         push      dx
         mov       al,3                     ; barva pro zobrazen° textu
         call      outch1                   ; nastaven° barvy 3
         mov       al,ds:[kurzsel]          ; ©†dek s kurzorem
         sub       al,ds:[firstsel]         ; offset ©†dku s kurzorem
         add       dh,2
         add       dh,al                    ; ©†dek s kurzorem
         add       dl,5                     ; poá†tek pro zobrazen° textu
         xor       ch,ch                    ; CH <- 0
         sub       cl,10                    ; skuteán† dÇlka textu na ©†dku
         mov       si,offset selbuf         ; buffer textu
         mov       bl,ds:[topsel]           ; poá†teán° offset textu
         xor       bh,bh
         add       si,bx                    ; adresa zobrazenÇ á†sti textu
         mov       bl,ds:[numselb]          ; poáet znakñ v bufferu
         sub       bl,ds:[topsel]           ; odeáten° poá†teán°ho offsetu
         or        bl,bl                    ; je nàjakò znak k zobrazen° ?
         jz        obredit2                 ; nen° ë†dnò znak k zobrazen°
obredit1:lodsb                              ; naáten° znaku k zobrazen°
         call      outch1                   ; zobrazen° znaku
         dec       bl                       ; je jië konec textu ?
         jz        obredit4                 ; je jië konec textu
         loop      obredit1                 ; zobrazen° dal®°ho znaku
         jmp       obredit3                 ; nezobraz° se dal®° znak
obredit4:dec       cx                       ; sn°ëen° á°taáe znakñ
obredit2:mov       al," "                   ; mazac° znak mezery
         call      outch                    ; vymaz†n° zbytku ©†dku
obredit3:pop       dx
         pop       cx
         pop       bx
         pop       ax
         pop       si
         ret

; -----------------------------------------------------------------------------

setkurzs:                                 ;* nastaven° kurzoru pro select
                                            ; VSTUP:DS:SI=buffer poloëek
                                            ;       DL=poá†tek okna
                                            ;       DH=©†dek okna
                                            ;       CL=®°©ka okna
                                            ;       CH=vò®ka okna
         push      ax
         push      dx
         add       dh,2                     ; p©iáten° horn°ho okraje
         mov       al,ds:[kurzsel]          ; kurzor
         sub       al,ds:[firstsel]         ; prvn° zobrazen† poloëka
         add       dh,al                    ; offset ©†dku s kurzorem
         add       dl,5                     ; offset od levÇho okraje
         xor       al,al                    ; p©°znak - nastaven° kurzoru
         call      outch1                   ; nastaven° pozice kurzoru
         pop       dx
         pop       ax
         ret

; -----------------------------------------------------------------------------

selall:                                   ;* zobrazen° v®ech poloëek voleb
                                            ; VSTUP:DS:SI=buffer poloëek
                                            ;       DL=poá†tek okna
                                            ;       DH=©†dek okna
                                            ;       CL=®°©ka okna
                                            ;       CH=vò®ka okna

         push      ax
         push      cx
         push      dx
         mov       al,ds:[firstsel]         ; prvn° zobrazen† poloëka voleb
         mov       ah,ch                    ; vò®ka okna
         sub       ah,4                     ; poáet poloëek k zobrazen°
         jbe       selall2                  ; je malò poáet poloëek
selall1: call      selpol                   ; zobrazen° jednÇ poloëky volby
         inc       al                       ; zvò®en° á°sla poloëky
         dec       ah                       ; sn°ëen° á°taáe ©†dkñ
         jnz       selall1                  ; zobrazen° dal®° poloëky
selall2: pop       dx
         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------

selpol:                                   ;* zobrazen° jednÇ poloëky volby
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
         cmp       al,ds:[firstsel]         ; je pod prvn° poloëkou ?
         jb        selpol6                  ; je pod prvn° poloëkou
         push      ax
         mov       ah,7                     ; barva pro norm†ln° poloëku
         cmp       al,ds:[kurzsel]          ; je poloëka s kurzorem ?
         jne       selpol0                  ; nen° poloëka s kurzorem
         mov       ah,3                     ; barva poloëky s kurzorem
selpol0: mov       al,ah                    ; barva pro zobrazen° poloëky
         call      outch1                   ; nastaven° barvy textu
         pop       ax
         mov       ah,dh                    ; £schova poá†teán°ho ©†dku
         add       ah,ch                    ; koncovò ©†dek
         sub       ah,2                     ; odeáten° spodn°ho okraje
         add       dh,2                     ; p©iáten° horn°ho okraje
         add       dh,al                    ; p©iáten° á°sla poloëky
         sub       dh,ds:[firstsel]         ; odeáten° poá†teán° poloëky
         cmp       dh,ah                    ; p©esahuje poloëka spodn° okraj ?
         ja        selpol6                  ; poloëka je mimo rozsah
         add       dl,5                     ; poá†tek pro zobrazen° textu
         xor       ch,ch                    ; CH <- 0
         sub       cl,10                    ; odeáten° okrajñ okna
         jnc       selpol1                  ; nen° podteáen° ®°©ky okna
         xor       cl,cl                    ; n†hradn° ®°©ka textu
selpol1: call      asksel                   ; poskytnut° adresy poloëky
         cmp       al,cl                    ; je poloëka vàt®° neë maxim†ln° ?
         jbe       selpol2                  ; je men®° nebo shodn†
         mov       al,cl                    ; maxim†ln° dÇlka poloëky k tisku
selpol2: mov       bl,al                    ; dÇlka zobrazenÇ poloëky
         sub       cl,bl                    ; zbytek ©†dku
         or        bl,bl                    ; je nàjakò znak ?
         jz        selpol4                  ; nen° jië dal®° znak
selpol3: lodsb                              ; znak k tisku
         call      outch1                   ; zobrazen° znaku
         dec       bl                       ; sn°ëen° á°taáe znakñ
         jnz       selpol3                  ; dal®° znak
selpol4: jcxz      selpol6                  ; nen° ë†dn† mezera k tisku
         mov       al," "                   ; znak mezery k tisku
selpol5: call      outch1                   ; zobrazen° mezery
         loop      selpol5                  ; zobrazen° dal®° mezery
selpol6: pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------

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

wnadpis:                                  ;* zobrazen° nadpisu okna
                                            ; VSTUP:DS:DI=text nadpisu
                                            ;       DL=poá†tek okna
                                            ;       DH=©†dek okna
                                            ;       CL=®°©ka okna
                                            ;       CH=vò®ka okna
         push      ax
         push      bx
         push      cx
         push      dx                       ; £schova sou©adnice
         push      si
         push      di
         mov       si,di                    ; text
         xor       bx,bx                    ; á°taá dÇlky ©etàzce
         xor       al,al
wnadp1:  cmp       al,ds:[di]               ; je jië konec ©etàzce ?
         je        wnadp2                   ; je konec ©etàzce
         inc       bx                       ; zvò®en° á°taáe znakñ ©etàzce
         inc       di                       ; zvò®en° ukazatele textu
         jmp       short wnadp1             ; test dal®°ho znaku
wnadp2:  or        bh,bh                    ; je dÇlka vàt®° neë 255 ?
         jz        wnadp3                   ; dÇlka nen° vàt®° neë 255
         mov       bl,255                   ; n†hradn° dÇlka 255
wnadp3:  shr       bl,1                     ; dÇlka ©etàzce / 2
         shr       cl,1                     ; ®°©ka okna / 2
         add       dl,cl                    ; prost©edek okna
         sub       dl,bl                    ; poá†teán° pozice pro tisk textu
         inc       dh                       ; prvn° ©†dek
         call      outtxt                   ; zobrazen° textu nadpisu
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------

stinw:                                    ;* zobrazen° st°nu pod oknem
                                            ; VSTUP: DL=poá†tek okna
                                            ;        DH=©†dek okna
                                            ;        CL=®°©ka okna
                                            ;        CH=vò®ka okna

         push      ax
         push      bx
         push      si
                                          ;* nastaven° offsetu pro st°n
         push      cx
         push      dx
         mov       ah,2ch                   ; funkce poskytnut° syst. áasu
         int       21h                      ; poskytnut° systÇmovÇho áasu
         mov       al,ch                    ; hodina
         mov       si,offset tabstin        ; tabulka hodin pro st°n
         mov       cx,6                     ; poáet hodnot v tabulce
         mov       bl,3                     ; vòchoz° hodnota offsetu st°nu
stinw1:  cmp       al,ds:[si]               ; je men®° neë £daj hodin ?
         jb        stinw2                   ; nalezen áasovò interval
         inc       si                       ; zvò®en° ukazatele v tabulce
         dec       bl                       ; posun st°nu o znak vlevo
         loop      stinw1                   ; test dal®°ho áasu
stinw2:  pop       dx
         pop       cx
         cmp       bl,-3                    ; je pozdà veáer ?
         je        stinw5                   ; je noc
         cmp       bl,3                     ; je brzo r†no ?
         je        stinw5                   ; je noc
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

stinw5:  pop       si
         pop       bx
         pop       ax
         ret


; -----------------------------------------------------------------------------

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
         and       bh,1                     ; aktivn° str†nka pro vòstup
         push      bx                       ; £schova str†nky
         mov       ah,2                     ; funkce nastaven° pozice kurzoru
         int       10h                      ; nastaven° pozice kurzoru
         pop       bx                       ; str†nka
         mov       ah,8                     ; funkce áten° znaku
         int       10h                      ; poskytnut° znaku a atributu
         mov       bl,ah
         and       ah,7fh
         mov       cl,4
         shr       ah,cl
         and       bl,0fh
         cmp       ah,bl
         mov       ah,7
         jna       stin1
         mov       ah,70h
stin1:   pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         push      word ptr ds:[color]      ; £schova atributu barev
         mov       ds:[color],ah            ; barva b°lÇ p°smo na áernÇm pozad°
         call      outch1                   ; vòstup znaku s novòm atributem
         pop       word ptr ds:[color]      ; navr†cen° pñvodn° barvy
         pop       ax
         ret

; -----------------------------------------------------------------------------

setwsel:                                  ;* nastaven° okna pro volby
                                            ; VSTUP: DS:DI=text nadpisu
                                            ;        BH=maxim. dÇlka ©etàzce
                                            ;        BL=poáet poloëek
                                            ;        DL=poá†tek okna (0=aut.)
                                            ;        DH=©†dek okna (0=aut.)
                                            ;        CL=®°©ka okna (0=aut.)
                                            ;        CH=max. vò®ka okna (0=max.)
                                            ; VùSTUP:DL=poá†tek okna
                                            ;        DH=©†dek okna
                                            ;        BH=maxim. dÇlka ©etàzce
                                            ;        BL=poáet poloëek
                                            ;        CL=®°©ka okna
                                            ;        CH=vò®ka okna

         push      ax
                                          ;* nastaven° ®°©ky okna
         or        cl,cl                    ; je ®°©ka okna zadan† ?
         jnz       setwsl2                  ; ®°©ka okna je zadan†
         mov       cl,bh                    ; maxim†ln° dÇlka ©etàzce
         call      lendi                    ; zji®tàn° dÇlky ©etàzce DS:DI
         cmp       al,cl                    ; je dÇlka vàt®° neë nalezen† ?
         jna       setwsl04                 ; dÇlka nen° vàt®°
         mov       cl,al                    ; nastaven° novÇ dÇlky textu
setwsl04:cmp       cl,66                    ; je dÇlka ©etàzce vàt®° neë 68 ?
         jna       setwsl11                 ; ®°©ka nen° vàt®° neë 68
         mov       cl,66                    ; omezen° na ®°©ku 68
setwsl11:cmp       cl,12                    ; minim†ln° ®°©ka poloëky
         jnb       setwsl12                 ; nen° men®° neë 12
         mov       cl,12                    ; omezen° na 12
setwsl12:add       cl,10                    ; p©iáten° okrajñ
                                          ;* nastaven° vò®ky okna
setwsl2: mov       al,bl                    ; poáet poloëek
         cmp       al,19                    ; je vàt®° poáet poloëek neë 19 ?
         jna       setwsl21                 ; nen° vàt®° poáet poloëek neë 19
         mov       al,19                    ; omezen° na 21 poloëek
setwsl21:or        al,al                    ; je nàjak† poloëka ?
         jnz       setwsl22                 ; je nàjak† poloëka
         inc       al                       ; 1 poloëka
setwsl22:add       al,4                     ; p©iáten° okrajñ
         or        ch,ch                    ; je zad†na vò®ka okna ?
         jz        setwsl23                 ; vò®ka okna nen° zadan†
         cmp       al,ch                    ; je vò®ka okna vàt®° neë poëadov. ?
         jae       setwsl3                  ; vò®ka okna je vàt®° nebo shodn†
setwsl23:mov       ch,al                    ; zmen®en° vò®ky okna
                                         ;* nastaven° poá†tku okna
setwsl3: or        dl,dl                    ; je nastaven poá†tek okna ?
         jnz       setwsl4                  ; poá†tek okna je nastaven
         mov       dl,80                    ; ®°©ka obrazovky
         sub       dl,cl                    ; odeáten° ®°©ky okna
         shr       dl,1                     ; offset od zaá†tku ©†dku
                                          ;* nastaven° ©†dku okna
setwsl4: or        dh,dh                    ; je nastaven ©†dek okna ?
         jnz       setwsl5                  ; ©†dek okna je nastaven
         mov       dh,25                    ; vò®ka obrazovky
         sub       dh,ch                    ; odeáten° vò®ky okna
         shr       dh,1                     ; poáet ©†dkñ nad oknem
         mov       al,ch                    ; poáet ©†dkñ celkem
         shr       al,1                     ; AL / 2
         shr       al,1                     ; AL / 4
         shr       al,1                     ; AL / 8 (poáet ©†dkñ 0 aë 3)
         sub       al,3
         neg       al                       ; 3 aë 0
         sub       dh,al
setwsl5:                                  ;* nastaven° prvn° zobrazenÇ poloëky
         mov       al,bl                    ; poáet poloëek
         dec       al
         mov       ds:[kurzsel],al          ; nastaven° kurzoru na posledn° pol.
         sub       al,ch                    ; odeáten° vò®ky okna
         add       al,4                     ; korekce okrajñ
         inc       al
         mov       ds:[firstsel],al         ; prvn° zobrazen† poloëka
         pop       ax
         ret

; -----------------------------------------------------------------------------

asksel:                                   ;* poskytnut° poloëky zad†n°
                                            ; VSTUP: DS:SI=buffer pro zad†n°
                                            ;        AL=á°slo poloëky 0...
                                            ; VùSTUP: DS:SI=adresa poloëky
                                            ;         AL=dÇlka poloëky
         push      bx
         push      cx
         push      dx
         push      di
         push      es
         push      ds
         pop       es
         mov       dl,al                    ; á°taá poloëek
         lodsw                              ; naáten° dÇlky
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
asksel9: pop       es
         pop       di
         pop       dx
         pop       cx
         pop       bx
         ret

; -----------------------------------------------------------------------------

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
         call      asksel                   ; test poloëky
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
; -----------------------------------------------------------------------------

; *****************************************************************************
;
;                    ZnakovÇ vstupnà/vòstupn° podprogramy
;
; *****************************************************************************

outch1:                                     ; vòstup 1 znaku na displej
                                            ; VSTUP: DX=pozice kurzoru
                                            ;        AL=ASCII znak

         push      cx                       ; £schova CX
         mov       cx,1                     ; poáet - 1 znak
         call      outch                    ; zobrazen° 1 znaku
         pop       cx                       ; n†vrat CX
         ret

; -----------------------------------------------------------------------------

outch01:                                    ; vòstup znaku na displej
                                            ; VSTUP: DX=pozice kurzoru
                                            ;        CX=poáet znakñ
                                            ;        AL=ASCII znak
                                            ;        BL=atribut barvy


         push      cx
         push      dx
         push      es
         cmp       dl,79                    ; je p©ekroáena pozice ?
         ja        outch011                 ; pozice p©ekroáena
         cmp       dh,24                    ; je p©ekroáen ©†dek ?
         ja        outch011                 ; ©†dek p©ekroáen
         push      ax
         mov       al,80
         mul       dh
         xor       dh,dh
         add       ax,dx
         add       ax,ax
         mov       di,ax
         test      byte ptr ds:[aktpage],1  ; je aktivn° str†nka 0 ?
         jz        outch012                 ; je aktivn° str†nka 0
         add       di,1000h                 ; dÇlka 1 str†nky
outch012:mov       ax,0b800h
         mov       es,ax
         pop       ax
         mov       ah,bl
         rep       stosw
outch011:pop       es
         pop       dx
         pop       cx
         ret



outch02: push      cx
         push      dx
         push      ax
         mov       bh,ds:[aktpage]          ; aktivn° str†nka
         and       bh,1
         mov       ah,2                     ; funkce nastaven° pozice kurzoru
         int       10h                      ; nastaven° pozice kurzoru
         pop       ax
         mov       ah,9                     ; funkce z†pisu znaku s atributem
         int       10h                      ; z†pis znaku
         pop       dx
         pop       cx
         ret

outch:                                      ; vòstup znaku na displej (- ©°dic°)
                                            ; VSTUP: DX=pozice kurzoru
                                            ;        CX=poáet znakñ
                                            ;        AL=ASCII znak
                                            ;        DS=datovò segment

         cmp       al,9                     ; je nastaven° atributu ?
         ja        outch0                   ; nen° nastaven° atributu - tisk
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
         lodsb                              ; naáten° barvy
         mov       ds:[color],al            ; nastaven° atributu barvy
         jmp       short outch13            ; n†vrat z obsluhy
                                          ;* nastaven° kurzoru
outch12: mov       bh,ds:[aktpage]          ; aktivn° videostr†nka
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

outch0:                                     ; vòstup znaku na displej
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
         mov       bl,ds:[color]            ; aktivn° barva (atribut)
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

outtxt:                                     ; vòstup textu na displej
                                            ; VSTUP: DX=pozice kurzoru
                                            ;        DS:SI=text k tisku
                                            ;        (DS=datovò segment)

         lodsb                              ; naáten° znaku k tisku
         or        al,al                    ; je koncovò bajt 0 ?
         jz        outtx1                   ; je koncovò bajt 0 - konec
         call      outch1                   ; tisk 1 znaku
         jmp       short outtxt             ; tisk dal®°ho znaku
outtx1:  ret

; -----------------------------------------------------------------------------

outtx0:                                     ; vòstup textu na displej
                                            ; VSTUP: DX=pozice kurzoru
                                            ;        DS:SI=text k tisku
                                            ;        (DS=datovò segment)

         push      ax
         push      cx
         mov       cx,1
outtx2:  lodsb                              ; naáten° znaku k tisku
         or        al,al                    ; je koncovò bajt 0 ?
         jz        outtx3                   ; je koncovò bajt 0 - konec
         call      outch0                   ; tisk 1 znaku
         jmp       short outtx2             ; tisk dal®°ho znaku
outtx3:  pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------

wrolldown:                                  ; rolov†n° okna dolñ
                                            ; VSTUP: BP=ukazatel okna
         push      bp
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         mov       cl,ds:[bp+pozl-tabl]
         mov       dl,cl
         add       dl,39
         mov       ax,701h
         mov       bh,ds:[col1]
         mov       ch,4
         mov       dh,22
         test      byte ptr ds:[flags],8
         jz        wrolldn1
         dec       dh
wrolldn1:int       10h
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         pop       bp
         ret

; -----------------------------------------------------------------------------

wrollup:                                    ; rolov†n° okna nahoru
                                            ; VSTUP: BP=ukazatel okna
         push      bp
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         mov       cl,ds:[bp+pozl-tabl]
         mov       dl,cl
         add       dl,39
         mov       ax,601h
         mov       bh,ds:[col1]
         mov       ch,4
         mov       dh,22
         test      byte ptr ds:[flags],8
         jz        wrollup1
         dec       dh
wrollup1:int       10h
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         pop       bp
         ret

; *****************************************************************************
;
;                       V®eobecnÇ pomocnÇ podprogramy
;
; *****************************************************************************

lowcase:                                  ;* p©evod znaku na malÇ p°smeno
                                            ; VSTUP: AL=znak k p©evodu

         cmp       al,"A"                   ; je znak men®° neë "A" ?
         jb        highc1                   ; nen° velkÇ p°smeno
         cmp       al,"Z"                   ; je znak vàt®° neë "Z" ?
         ja        lowc1                    ; nen° velkÇ p°smeno
         add       al,32                    ; korekce na malÇ p°smeno
lowc1:   ret

; -----------------------------------------------------------------------------

highcase:                                 ;* korekce AL na velkÇ p°smeno
                                            ; VSTUP: AL=znak k p©evodu

         cmp       al,"a"                   ; je znak men®° neë "a" ?
         jb        highc1                   ; nen° malÇ p°smeno
         cmp       al,"z"                   ; je znak vàt®° neë "z" ?
         ja        highc1                   ; nen° malÇ p°smeno
         sub       al,32                    ; korekce na velkÇ p°smeno
highc1:  ret

; -----------------------------------------------------------------------------

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


testkonc:                                   ; test koncovky á°sla
                                            ; VSTUP: DS:SI=text á°sla
                                            ; VùSTUP: AL=0 je koncovka pro "1"
                                            ;         AL=1 koncovka pro 2,3,4
                                            ;         AL=2 ostatn° á°sla

         push      dx
         push      si
         mov       dx,"00"                  ; posledn° 2 á°slice
testkon1:call      readtest                 ; naáten° dal®° á°slice
         jc        testkon2                 ; nen° jië dal®° á°slice
         mov       dh,dl                    ; p©edposledn° á°slice
         mov       dl,al                    ; posledn° á°slice
         jmp       short testkon1           ; naáten° dal®° á°slice
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
         cmp       al,8                     ; je znak men®° neë 8 (©°dic°) ?
         jbe       center1                  ; je bajt 8 nebo men®° - dal®° znak
         dec       cl                       ; sn°ëen° á°taáe znakñ
         jnz       center1                  ; nen° je®tà 0 - dal®° znak
center2: shr       cl,1                     ; CL/2 - offset od zaá†tku
         add       dl,cl                    ; zvò®en° pozice kurzoru
         pop       si                       ; n†vrat SI
         pop       ax                       ; n†vrat AX
         ret

; -----------------------------------------------------------------------------

lensi:                                    ;* zji®tàn° dÇlky ©etàzce ASCIIZ DS:SI
                                            ; VSTUP: DS:SI=adresa ©etàzce
                                            ; VùSTUP: AL=dÇlka ©etàzce
                                            ;         CY=p©eteáen° (AL=255)

         push      si
         xor       al,al                    ; á°taá dÇlky ©etàzce
lens1:   cmp       byte ptr ds:[si],0       ; je jië konec ©etàzce ?
         je        lens2                    ; je konec ©etàzce
         inc       si                       ; zvò®en° ukazatele textu
         inc       al                       ; zvò®en° á°taáe znakñ ©etàzce
         jnz       lens1                    ; test dal®°ho znaku
         dec       al                       ; AL <- 255 p©eteáen° textu
         stc                                ; p©°znak p©eteáen° textu
lens2:   pop       si
         ret

; -----------------------------------------------------------------------------

lendi:                                    ;* zji®tàn° dÇlky ©etàzce ASCIIZ DS:DI
                                            ; VSTUP: DS:DI=adresa ©etàzce
                                            ; VùSTUP: AL=dÇlka ©etàzce
                                            ;         CY=p©eteáen° (AL=255)

         push      di
         xor       al,al                    ; á°taá dÇlky ©etàzce
lend1:   cmp       byte ptr ds:[di],0       ; je jië konec ©etàzce ?
         je        lend2                    ; je konec ©etàzce
         inc       di                       ; zvò®en° ukazatele textu
         inc       al                       ; zvò®en° á°taáe znakñ ©etàzce
         jnz       lend1                    ; test dal®°ho znaku
         dec       al                       ; AL <- 255 p©eteáen° textu
         stc                                ; p©°znak p©eteáen° textu
lend2:   pop       di
         ret

; -----------------------------------------------------------------------------

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
         push      dx                       ; pozice
         mov       di,offset outbuf         ; tiskovò buffer
         xor       ah,ah
         call      deknum2                  ; dek¢dov†n° á°sla 2 á°slice
         pop       dx                       ; pozice
         mov       si,offset outbuf         ; tiskovò buffer
         call      outtxt                   ; zobrazen° textu
         call      setfre                   ; volnò form†t tisku á°sla
         pop       cx
         pop       bx
         pop       si
         pop       di
         ret

; -----------------------------------------------------------------------------

tisknm0:                                    ; tisk á°sla 10 á°slic zarov. vpravo
                                            ; VSTUP: BX:AX=á°slo
                                            ;        DX=pozice

         push      di
         push      si
         push      dx                       ; pozice
         call      setspc                   ; nastaven° m¢du tisku mezer
         mov       dx,bx                    ; vy®®° slovo á°sla
         mov       di,offset outbuf         ; tiskovò buffer
         call      deknumx                  ; p©ek¢dov†n° á°sla s omezen°m
         pop       dx                       ; pozice
         mov       si,offset outbuf         ; tiskovò buffer
         call      outtxt                   ; zobrazen° textu
         call      setfre                   ; volnò form†t tisku á°sla
         pop       si
         pop       di
         ret

; -----------------------------------------------------------------------------

setspc:                                   ;* zapnut° tisku mezer p©ed á°slem

         and       byte ptr ds:[parnum],0fdh ; vypnut° tisku nul
         or        byte ptr ds:[parnum],2   ; zapnut° tisku mezer
         ret


setnul:                                   ;* zapnut° tisku nul p©ed á°slem

         and       byte ptr ds:[parnum],0fbh ; vypnut° tisku mezer
         or        byte ptr ds:[parnum],4   ; zapnut° tisku nul
         ret


setfre:                                   ;* zapnut° volnÇho form†tu á°sla

         and       byte ptr ds:[parnum],0f9h ; vypnut° tisku mezer a nul
         ret

; -----------------------------------------------------------------------------

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
         or        byte ptr ds:[parnum],10h ; z†kaz tisku teáku tis°cñ
         call      deknum9                  ; dek¢dov†n° á°sla 9 á°slic
         and       byte ptr ds:[parnum],0efh; povolen° tisku teáky tis°cñ
         ret

deknmx4: or        byte ptr ds:[parnum],1   ; z†kaz tisku teáek
         call      deknum0                  ; dek¢dov†n° á°sla 10 á°slic
         and       byte ptr ds:[parnum],0feh ; povolen° tisku teáek
         ret

; -----------------------------------------------------------------------------

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
         test      byte ptr ds:[parnum],10h ; je z†kaz tisku tis°cñ ?
         jz        deknum41                 ; nen° z†kaz tisku tis°cñ
         or        byte ptr ds:[parnum],8   ; p©echodnò z†kaz tisku teáky
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
         and       byte ptr ds:[parnum],0f7h; zru®en° p©echodnÇho z†kazu teáky
         xchg      al,ds:[citdek]           ; vynulov†n° á°taáe á°slic
         inc       al                       ; poáet znakñ dek¢dovanÇho textu
         ret

                                          ;* dek¢dov†n° á°slice 32-bit. á°sla
                                            ; VSTUP: DX:AX=á°slo
                                            ;        BX:CX=dàlitel á°sla
                                            ;        ES:DI=adr. k uloëen° textu

deknm00: xor       dx,dx                    ; DX <- 0
deknm01: xor       bl,bl                    ; BL <- 0
deknm02: xor       bh,bh                    ; BH <- 0
deknm0:  mov       byte ptr ds:[citnum],2fh ; inicializace á°taáe á°slice
deknm1:  inc       byte ptr ds:[citnum]     ; zvò®en° á°taáe á°slice
         sub       ax,cx                    ; odeáten° nië®°ho slova á°sla
         sbb       dx,bx                    ; odeáten° vy®®°ho slova á°sla
         jnc       deknm1                   ; nen° je®tà p©eteáen°
         add       ax,cx                    ; n†vrat nië®°ho slova á°sla
         adc       dx,bx                    ; n†vrat vy®®°ho slova á°sla
         cmp       byte ptr ds:[citnum],"0" ; je á°slice 0 ?
         jne       deknm2                   ; nen° á°slice 0 - dek¢dov†n°
         cmp       byte ptr ds:[citdek],0   ; byla jië nàjak† á°slice ?
         jne       deknm2                   ; byla jië nàjak† á°slice
         test      byte ptr ds:[parnum],4   ; je tisku nul ?
         jnz       deknm2                   ; je tisk nul
         mov       byte ptr ds:[citnum]," " ; n†hradn° znak mezery
         test      byte ptr ds:[parnum],2   ; je tisk mezer ?
         jz        deknm3                   ; nen° tisk mezer
         jmp       short deknm21
deknm2:  inc       byte ptr ds:[citdek]     ; zvò®en° á°taáe á°slic
deknm21: push      ax                       ; £schova AX
         mov       al,ds:[citnum]           ; dek¢dovan† á°slice
         stosb                              ; uloëen° á°slice
         pop       ax                       ; n†vrat AX
deknm3:  ret

deknm8:
         push      ax
         mov       al,"."                   ; oddàlovac° teáka
         test      byte ptr ds:[parnum],9   ; je povolenò tisk teáky ?
         jnz       deknm9                   ; tisk nen° povolenò
         cmp       byte ptr ds:[citdek],0   ; byla jië platn† á°slice ?
         jne       deknm81                  ; byla jië platn† á°slice
         test      byte ptr ds:[parnum],3   ; je volnò form†t ?
         jz        deknm9                   ; je volnò form†t
         test      byte ptr ds:[parnum],4   ; je tisk nul ?
         jnz       deknm81                  ; je tisk nul
         mov       al," "                   ; n†hradn° oddàlovac° mezera
deknm81: mov       byte ptr es:[di],al      ; oddàlovac° znak
         inc       di                       ; zvò®en° ukl†dac° adresy
         cmp       byte ptr ds:[citdek],0   ; je jië nàjak† á°slice ?
         je        deknm9                   ; nen° je®tà ë†dn† á°slice
         inc       byte ptr ds:[citdek]     ; zvò®en° á°taáe á°slic (znakñ)
deknm9:  pop       ax
         ret


; -----------------------------------------------------------------------------

dekfile:                                    ; zak¢dov†n° jmÇna souboru
                                            ; VSTUP: DS:SI -> ES:DI
         push      cx
         push      si
         push      di
         inc       si
         mov       cx,8
dekfil1: lodsb
         cmp       al," "
         je        dekfil2
         stosb
dekfil2: loop      dekfil1
         test      byte ptr ds:[si-9],10h
         jnz       dekfil21                 ; je adres†©
         mov       al,"."
         stosb
dekfil21:mov       cl,3
dekfil3: lodsb
         cmp       al," "
         je        dekfil4
         stosb
dekfil4: loop      dekfil3
         xor       al,al
         stosb
         pop       di
         pop       si
         pop       cx
         ret


; *****************************************************************************
;
;                      Podprogramy pro diskovÇ operace
;
; *****************************************************************************

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

openex:                                   ;* otev©en° souboru MNEXEC.BAT
                                            ; VùSTUP: CY=chyba otev©en°
                                            ;         AL=chybovò k¢d

         push      dx
         push      si
         mov       si,offset pathhome       ; p©°stupov† cesta k domovskÇmu adr.
         call      aktdir                   ; nastaven° aktivn°ho adres†©e
         jc        openex2                  ; chyba otev©en° adres†©e
         mov       dx,offset fileexc        ; jmÇno souboru "MNEXEC.BAT"
         call      openw                    ; otev©en° souboru pro z†pis
openex2: pop       si
         pop       dx
         ret

; -----------------------------------------------------------------------------

openw:                                    ;* otev©en° souboru pro z†pis
                                            ; VSTUP: DX=jmÇno souboru
                                            ; VùSTUP: CY=chyba otev©en°
                                            ;         AL=chybovò k¢d

         push      ax                       ; £schova AX
         push      cx
         xor       cx,cx                    ; atributy souboru
         mov       ah,3ch                   ; funkce vytvo©en° souboru
         int       21h                      ; otev©en° souboru pro z†pis
         jc        openw1                   ; chyba otev©en° souboru
         mov       ds:[outid],ax            ; identidik†tor souboru
         xor       ax,ax                    ; AX <- 0
         mov       ds:[ukazbuf],ax          ; nulov†n° ukazatele bufferu
         mov       ds:[numbuf],ax           ; nulov†n° poátu dat v bufferu
openw1:  pop       cx
         pop       ax                       ; n†vrat AX
         ret

; -----------------------------------------------------------------------------

closew:                                   ;* uzav©en° vòstupn°ho souboru
                                            ; VùSTUP: CY=chyba uzav©en°
                                            ;         AL=chybovò k¢d

         push      bx
         mov       bx,ds:[outid]            ; identifik†tor vòstupn°ho souboru
         mov       ah,3eh                   ; funkce uzav©en° souboru
         int       21h                      ; uzav©en° vòstupn°ho souboru
         pop       bx
         ret

; -----------------------------------------------------------------------------

srcenv:                                   ;* nalezen° otcovskÇho prost©ed°

         push      es
         push      ds
         mov       es,ds:[segpsp]
         mov       es,es:[2ch]              ; ES <- adresa prost©ed°
         mov       word ptr ds:[parenv+2],es
         mov       ax,es                    ; dekrementace ES
         dec       ax
         mov       es,ax
         mov       dx,es:[3]                ; dÇlka alokaán°ho bloku (odstavcñ)
         inc       ax
         mov       es,ax
         xor       di,di                    ; DI <- 0
                                          ;* nalezen° konce prost©ed°
         xor       ax,ax                    ; AX <- 0 hledanÇ slovo
         mov       cx,8000h                 ; maxim†ln° dÇlka prost©ed°
hled1:   cmp       es:[di],ax               ; je konec prost©ed° ?
         je        hled0                    ; je konec prost©ed°
         inc       di                       ; dal®° znak
         loop      hled1                    ; test dal®°ho bajtu
hled0:                                    ;* nalezen° otcovskÇho prost©ed°
         mov       bx,di                    ; dÇlka prost©ed°
         mov       word ptr ds:[parenv],di  ; konec prost©ed°
         mov       cx,es                    ; maxim†ln° poáet segmentñ
         push      es
         pop       ds                       ; DS <- adresa prost©ed°
hled2:   xor       di,di                    ; DI <- 0
         xor       si,si                    ; SI <- 0
         mov       ax,es                    ; dekrementace ES
         dec       ax
         mov       es,ax
         push      cx
         mov       cx,bx                    ; dÇlka prost©ed°
         repz      cmpsb                    ; porovn†n° prost©ed°
         pop       cx
         jne       hled3                    ; prost©ed° nen° nalezeno

         mov       ax,es                    ; dekrementace ES
         dec       ax
         mov       es,ax
         cmp       byte ptr es:[0],"M"      ; je alokaán° blok ?
         jne       hled3                    ; nen° alokaán° blok
         mov       dx,es:[3]                ; dÇlka alokaán°ho bloku (odstavcñ)
         mov       ax,es                    ; inkrementace ES
         inc       ax
         mov       es,ax
         jmp       short hled4

hled3:   loop      hled2                    ; test dal®°ho odstavce
hled4:   pop       ds
         shl       dx,1
         shl       dx,1
         shl       dx,1
         shl       dx,1
         mov       ds:[maxenv],dx           ; max. dÇlka prost©ed°
         mov       word ptr ds:[parenv+2],es
         xor       ax,ax                    ; AX <- 0 hledanÇ slovo
         mov       cx,8000h                 ; maxim†ln° dÇlka prost©ed°
hled5:   cmp       es:[di],ax               ; je konec prost©ed° ?
         je        hled6                    ; je konec prost©ed°
         inc       di                       ; dal®° znak
         loop      hled5                    ; test dal®°ho bajtu
hled6:   mov       word ptr ds:[parenv],di  ; konec prost©ed°
         pop       es
         ret

; -----------------------------------------------------------------------------

delenv:                                   ;* zru®en° prost©ed° EXECUTE

         push      es
         push      ds
         mov       si,offset envexec        ; nastaven° prost©ed° pro EXECUTE
         xor       di,di                    ; adresa zaá†tku prost©ed°
         mov       es,word ptr ds:[parenv+2] ; segment prost©ed°
delenv1: xor       al,al
         cmp       es:[di],al               ; je posledn° ©etàzec prost©ed° ?
         je        delenv3                  ; je konec prost©ed°
         push      si
         push      di
         mov       cx,8                     ; dÇlka ©etàzce
         repe      cmpsb                    ; porovn†n° ©etàzcñ
         mov       cx,-1
         je        delenv2                  ; ©etàzce jsou shodnÇ
         pop       di
         pop       si
         repne     scasb                    ; nalezen° konce ©etàzce
         jmp       short delenv1
delenv2:                                  ;* ©etàzec nalezen
         pop       di
         push      di                       ; zaá†tek ©etàzce EXECUTE
         repne     scasb
         mov       si,di                    ; zaá†tek n†sleduj°c°ho ©etàzce
delenv5: cmp       al,es:[di]
         je        delenv4
         repne     scasb
         jmp       short delenv5            ; nalezen° konce prost©ed°

delenv4: mov       cx,di                    ; konec prost©ed°
         pop       di                       ; zaá†tek ©etàzce EXECUTE
         sub       cx,si                    ; dÇlka prost©ed°
         mov       ax,es
         mov       ds,ax
         inc       cx
         rep       movsb                    ; p©enos prost©ed°
         pop       si
delenv3: pop       ds
         pop       es
         dec       di
         mov       word ptr ds:[parenv],di  ; konec prost©ed°
         add       di,90                    ; novò poëadovanò konec prost©ed°
         cmp       di,ds:[maxenv]           ; kontrola maxim†ln° dÇlky prost©ed°
         jb        delenv6                  ; nebylo by p©eteáen° prost©ed°
                                          ;* zobrazen° hl†®en° o p©eteáen°
         push      di                       ; poëadovan† velikost prost©ed°
         mov       si,offset errenv         ; text chyby prost©ed° systÇmu
         mov       di,offset outbuf
         call      transtxt                 ; p©enos textu
         pop       ax                       ; poëadovan† velikost prost©ed°
         add       ax,15                    ; zaokrouhlen° na odstavec
         and       ax,NOT 0fh               ; zaokrouhlen° na odstavec
         xor       dx,dx                    ; DX <- 0
         call      deknum5                  ; dek¢dov†n° á°sla
         mov       si,offset errenv0
         call      transtxt                 ; p©enos zbytku textu
         call      setkonc                  ; nastaven° koncovky
         mov       si,offset errenv1
         call      transtxt
         mov       dx,offset outbuf         ; chybovò text
         mov       ah,9
         int       21h

delenv6: ret
; -----------------------------------------------------------------------------

setenv:                                   ;* z†pis textu do prost©ed° (EXECUTE)
                                            ; VSTUP: DS:SI=text k z†pisu
                                            ; VùSTUP: CY=nedostateán† kapacita

         push      es
         push      si
;         mov       ax,ds
;         mov       es,ax
;         mov       cx,-1
;         xor       al,al
;         mov       di,si
;         repnz     scasb                    ; nalezen° konce textu
;         jcxz      setenv4
;         neg       cx                       ; dÇlka textu
;         add       cx,11                    ; p©iáten° textu "EXECUTE"
;         add       cx,word ptr ds:[parenv]  ; p©iáten° konce prost©ed°
;         cmp       cx,ds:[maxenv]           ; kontrola konce prost©ed°
;         jae       setenv4                  ; prost©ed° nedostaáuje
;
;         les       di,ds:[parenv]           ; adresa konce prost©ed°
;         mov       si,offset envexec        ; nastaven° prost©ed° pro EXECUTE
;         call      transtxt                 ; p©enos textu "EXECUTE"
;
;         push      es
;         mov       ax,0b800h
;         mov       es,ax
;         mov       ax,ds:[maxenv]
;         mov       es:[1000h],al
;         mov       es:[1002h],ah
;         mov       ax,word ptr ds:[parenv]
;         mov       es:[1004h],al
;         mov       es:[1006h],ah
;         mov       ax,cx
;         mov       es:[1008h],al
;         mov       es:[100ah],ah
;         mov       ax,di
;         mov       es:[100ch],al
;         mov       es:[100eh],ah
;         pop       es
;
;         pop       si
;         call      transtxt
;         xor       ax,ax
;         mov       es:[di],ax
;         pop       es
;         clc
;         ret

setenv4: pop       si
         pop       es
         stc                                ; p©°znak chyby prost©ed°
         ret

; -----------------------------------------------------------------------------

writte:                                   ;* z†pis ©†dku textu do MNEXEC.BAT
                                            ; VSTUP: DS:SI=text k z†pisu
         push      si
writt1:  lodsb
         or        al,al
         jz        writt2                   ; konec textu
         call      writex                   ; z†pis znaku do souboru MNEXEC.BAT
         jc        writt3                   ; chyba z†pisu
         cmp       word ptr ds:[si-2],0a0dh ; byl text od©†dkov†n° ?
         jne       writt1                   ; nebyl konec ©†dku - dal®° znak
writt2:  mov       al,0dh
         call      writex
         jc        writt3
         mov       al,0ah
         call      writex
         jc        writt3
writt4:  xor       al,al
         stc
         call      writex                   ; vypr†zdnàn° bufferu
writt3:  pop       si
         ret

; -----------------------------------------------------------------------------

writex:                                   ;* z†pis bajtu do souboru MNEXEC.BAT
                                            ; VSTUP: AL=bajt k z†pisu
                                            ;        CY=vypr†zdnàn° bufferu

         push      bx
         push      cx
         push      dx
         mov       bx,ds:[numbuf]           ; poáet bajtñ v bufferu
         jc        writex1                  ; je vypr†zdnàn° bufferu
         mov       ds:[bx+diskbuf],al       ; uloëen° dal®°ho znaku do bufferu
         inc       bx                       ; zvò®en° poátu bajtñ v bufferu
         cmp       bx,512                   ; je jië buffer zaplnàn ?
         cmc                                ; negace bitu CF
         jnc       writex2                  ; buffer je®tà nen° zaplnàn
writex1: mov       cx,bx                    ; poáet bajtñ k z†pisu
         clc
         jcxz      writex2                  ; nejsou ë†dn† data k z†pisu
         mov       ah,40h                   ; funkce z†pisu do souboru
         mov       bx,ds:[outid]            ; identifik†tor vòstupn°ho souboru
         mov       dx,offset diskbuf        ; diskovò buffer
         int       21h                      ; z†pis dat do souboru
         jc        writex3                  ; chyva diskovÇ operace
         xor       bx,bx                    ; poáet bajt v bufferu = 0
writex2: mov       ds:[numbuf],bx           ; nastaven° novÇho poátu bajtñ
writex3: pop       dx
         pop       cx
         pop       bx
         ret

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------


code     ends

; *****************************************************************************
;
;                             Datovò segment
;
; *****************************************************************************
data     segment

errver   db        'Chybn† verze operaán°ho systÇmu !',13,10,'$'
errcard  db        'Chybn† grafick† karta (nen° m¢d 80x25 znakñ) !',13,10,'$'
errenv   db        'Nedostateán† velikost prost©ed° systÇmu - zmà§te alespo§'
         db        ' na ',0
errenv0  db        ' bajt',0
errenv1  db        ' !',13,10,'$',0

                                          ;* registry pro dek¢dov†n° á°sla
citdek   db        0                        ; á°taá platnòch á°slic pro p©evod
citnum   db        0                        ; á°taá 1 á°slice
parnum   db        0                        ; parametry pro dek¢dov†n° á°sla
                                            ;   bit 0=z†kaz oddàlovac° teáky
                                            ;   bit 1=tisk mezer
                                            ;   bit 2=tisk nul
                                            ;   bit 3=p©echodnò z†kaz teáky
                                            ;   bit 4=z†kaz tisku teáky tis°cñ

tabstin  db        5,8,11,13,16,19          ; tabulka hodin pro st°n

outbuf   db        100 dup(0)               ; tiskovò buffer

texthlp  db        3,' <F1>=? ',0
textclk  db        3,' 00:00 ',0

textsp1  db        1,' bajt',0
textsp2  db        ' voln',0
textsp20 db        98h,0                    ; koncovka "ò"
textsp21 db        82h,0                    ; koncovka "Ç"
textsp22 db        'òch',0
textsp23 db        ' z ',2,0

textsp3  db        1,' soubor',0
textsp30 db        ' zab°r† ',2,0
textsp4  db        1,' bajt',0

textvy1  db        1,' bajt',0
textvy11 db        'y',0                    ; koncovka "y"
textvy12 db        96h,0                    ; koncovka "ñ"
textvy13 db        ' v ',2,0
textvy14 db        ' ve ',2,0

textvy2  db        1,' soubor',0
textvy21 db        'u ',0
textvy22 db        'ech ',0

txtsubd  db        '<POD--ADR>',0
txtupd   db        '<NAD--ADR>',0
txtdsk   db        '  <DISK>  ',0

txthelp2 db        9,'1',3,'pomoc'
         db        9,' 2',3,'povel'
         db        9,' 3',3,'zobraz'
         db        9,' 4',3,'edituj'
         db        9,' 5',3,'kop°ruj'
         db        9,' 6',3,'p©esu§'
         db        9,' 7',3,'hledej'
         db        9,' 8',3,'obnov'
         db        9,' 9',3,'porovnej'
         db        9,' 10',3,'!konec'
         db        0

txthelp  db        9,'1',3,'pomoc'
         db        9,' 2',3,'volby'
         db        9,' 3',3,'zobraz'
         db        9,' 4',3,'edituj'
         db        9,' 5',3,'kop°ruj'
         db        9,' 6',3,'p©esu§'
         db        9,' 7',3,'vytvo©'
         db        9,' 8',3,'zru®'
         db        9,' 9',3,'atributy'
         db        9,' 10',3,'kalkul.'
         db        0

txtsel   db        ' vòbàr souborñ ',0
txtunsel db        ' zru®it vòbàr ',0
txtcopy  db        ' budou se kop°rovat soubory do ',0

col1     db        1bh                      ; atribut norm†ln°ho textu okna
col2     db        1eh                      ; atribut vysv°cenÇho textu
col3     db        30h                      ; atribut negovanÇho textu
col4     db        3eh                      ; atribut negovanÇho vysv°cenÇho tx.
col5     db        6fh                      ; ukazatel norm†ln°
col6     db        6ch                      ; ukazatel vysv°cen°
col7     db        70h                      ; norm†ln° okno
col8     db        47h                      ; chybovÇ hl†®en°
col9     db        07h                      ; text á°sla funkán° kl†v. n†povàdy

color    db        1bh                      ; aktivn° barva textu
                                            ; (n†sled. bajt slouë° tÇë k PUSH)

all      db        '*.*',0                  ; oznaáen° - v®echny soubory

filecnf  db        'MNSHELL.CNF',0          ; konfiguraán° soubor programu
fileexc  db        'MNEXEC.BAT',0           ; p©°kazovò soubor
txtcall  db        'CALL ',0                ; vol†n° souboru BAT
envexec  db        'EXECUTE=',0,0,0,0       ; nastaven° prost©ed° pro EXECUTE

normdsk  db        40h                      ; poloëka disku
         db        '   - A -   '            ; jmÇno disku

namepath db        '..',0,0,0,0,0,0,0,0,0,0 ; jmÇno adres†©e

flags    db        00000000b                ; indik†tor
                                            ; bit 0: 1=aktivn° je levÇ okno
                                            ; bit 1: 1=operace prob°h† s L oknem
                                            ; bit 2: 1=obà okna jsou vypnuta
                                            ; bit 3: 1=n†povàda je zapnuta
                                            ; bit 4: 1=je n†povàda s ALT
                                            ; bit 6: 1=je znaáka vòbàru souboru
                                          ;* ukazatele pro editaci p©°kaz. ©†dku
numchar  db        0                        ; poáet znakñ v bufferu
poztop   db        0                        ; pozice zaá†tku zobrazenÇho textu
pozcomm  db        0                        ; pozice zaá†tku textu na displeji
pozbuf   db        0                        ; pozice kurzoru v textovÇm bufferu
                                          ;* ukazatele pro editaci ©†dku volby
numselb  db        0                        ; poáet znakñ v bufferu pro vòbàr
ukazsel  db        0                        ; ukazatel kurzoru pro buffer vòbàru
topsel   db        0                        ; zaá†tek zobrazenÇho textu volby
firstsel db        0                        ; prvn° zobrazen† poloëka voleb
kurzsel  db        0                        ; kurzor pro volby

endadr   dw        offset endshell          ; adresa konce pamàti (offset)

bufsel   label     byte                   ;* buffer masek pro selekci souborñ
         dw        bufsel2-bufsel1          ; dÇlka bufferu
bufsel1  db        128 dup(?)               ; buffer
bufsel2  db        1                        ; poáet p©edvoleb
         dw        offset all               ; adresa p©edvolby "*.*"

bufcopy  label     byte                   ;* buffer pro kop°rov†n° souborñ
         dw        bufcop2-bufcop1
bufcop1  db        256 dup(?)
bufcop2  db        2
         dw        offset pathl
         dw        offset pathr

; -----------------------------------------------------------------------------

TABL     label     byte                     ; tabulka definic levÇho okna

flagsl   db        6                        ; indik†tor stavu okna
                                            ; bit 0: 1=okno m† bòt zapnuto
                                            ; bit 1: 1=okno je zapnuto
                                            ; bit 2: 1=p©°znak - je levÇ okno

pozl     db        0                        ; poá†teán° pozice okna
radkul   db        19                       ; poáet ©†dkñ souborñ
insfil   dw        ?                        ; poáet oznaáenòch souborñ
kapfil   dd        ?                        ; kapacita oznaáenòch souborñ

numdskl  db        ?                        ; poáet diskñ v seznamu
numfl    dw        ?                        ; poáet souborñ v adres†©i
kurzl    dw        ?                        ; á°slo souboru s kurzorem
firstl   dw        ?                        ; á°slo prvn°ho zobrazenÇho souboru
adrfl    dw        offset endshell          ; offset adresy bufferu souborñ
                                          ;* parametry disku (dodrëet po©ad° !)
alokl    dw        ?                        ; kapacita alokaán°ho bloku levÇho
celkl    dd        ?                        ; celkov† kapacita levÇho disku
volnl    dd        ?                        ; voln† kapacita levÇho disku
soubl    dw        ?                        ; souborñ v levÇm adres†©i
zabl     dd        ?                        ; zabran† kapacita souborñ vlevo

pathl    db        128 dup(?)               ; cesta k levÇmu adres†©i

; -----------------------------------------------------------------------------

TABR     label     byte                     ; tabulka definic pravÇho okna

flagsr   db        2                        ; indik†tor stavu okna
                                            ; bit 0: 1=okno m† bòt zapnuto
                                            ; bit 1: 1=okno je zapnuto
                                            ; bit 2: 0=p©°znak - je pravÇ okno

pozr     db        40                       ; poá†teán° pozice okna
radkur   db        19                       ; poáet ©†dkñ souborñ
insfir   dw        ?                        ; poáet oznaáenòch souborñ
kapfir   dd        ?                        ; kapacita oznaáenòch souborñ

numdskr  db        ?                        ; poáet diskñ v seznamu
numfr    dw        ?                        ; poáet souborñ v adres†©i
kurzr    dw        ?                        ; á°slo souboru s kurzorem
firstr   dw        ?                        ; á°slo prvn°ho zobrazenÇho souboru
adrfr    dw        offset endshell          ; offset adresy bufferu souborñ
                                          ;* parametry disku (dodrëet po©ad° !)
alokr    dw        ?                        ; kapacita alokaán°ho bloku pravÇho
celkr    dd        ?                        ; celkov† kapacita pravÇho disku
volnr    dd        ?                        ; voln† kapacita pravÇho disku
soubr    dw        ?                        ; souborñ v pravÇm adres†©i
zabr     dd        ?                        ; zabran† kapacita souborñ vpravo

pathr    db        128 dup(?)               ; cesta k pravÇmu adres†©i

; -----------------------------------------------------------------------------

verze    dw        ?                        ; á°slo verze operaán°ho systÇmu
segpsp   dw        ?                        ; segment PSP
typdisp  db        ?                        ; typ displeje:
                                            ;    0=nestandardn°
                                            ;    1=CGA
                                            ;    2=MDA
                                            ;    3=EGA
vmod     db        ?                        ; aktivn° videom¢d
segvram  dw        ?                        ; segment videopamàti
segend   dw        ?                        ; segment konce alokaán°ho bloku
aktatr   db        ?                        ; aktivn° atribut displeje
radek    db        ?                        ; ©†dek kurzoru
aktpage  db        ?                        ; aktivn° str†nka displeje
                                            ;  bit 1=str†nka pro vòstup
                                            ;  bit 2=str†nka pro displej
parenv   dd        ?                        ; otcovskÇ prost©ed°
maxenv   dw        ?                        ; maxim†ln° dÇlka prost©ed°

outid    dw        ?                        ; identifik†tor vòstupn°ho souboru
inpid    dw        ?                        ; identifik†tor vstupn°ho souboru
ukazbuf  dw        ?                        ; ukazatel dat v diskovÇm buffer
numbuf   dw        ?                        ; poáet bajtñ v diskovÇm bufferu

buftxt   db        129 dup(?)               ; textovò buffer

diskbuf  db        512 dup(?)               ; diskovò buffer

normfil  db        20 dup(?)                ; normalizovanò soubor
                                            ; 1 bajt - atributy
                                            ; 8 bajtñ - jmÇno
                                            ; 3 bajty - p©°pona
                                            ; 4 bajty - velikost
                                            ; 2 bajty - datum
                                            ; 2 bajty - áas

pathhome db        128 dup(?)               ; p©°stupov† cesta k domovskÇmu adr.
pathinit db        128 dup(?)               ; inicializaán° aktivn° cesta

selbuf   db        128 dup(?)               ; buffer pro editaci p©i vòbàru


endshell label   byte                       ; adresa konce programu

data     ends

; *****************************************************************************
;
;                  Segment z†sobn°ku (p©echodnà do inicializace)
;
; *****************************************************************************

stack    segment   stack
         dw        512 dup(?)               ; z†sobn°k
stack    ends

         END       main                     ; startovac° adresa

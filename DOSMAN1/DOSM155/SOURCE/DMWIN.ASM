
;               modul DOSMWIN.ASM pro program DOSM.ASM - obsluha oken


; *****************************************************************************
;
;                            Naáten° adres†©e
;
; *****************************************************************************

code     segment   public
         assume    cs:code,ds:code

extrn    rozborn:near,aktdir:near,loadpath:near,delseg:near,createseg:near,bufwin:byte
extrn    all:byte,parbreak:word,getseg:near,modiseg:near,namel:byte,namer:byte
extrn    firstwl:word,firstwr:word,tabr:byte,tabl:byte,usesedit:near,testaktw:near
extrn    cisvram:byte,color:byte,outch:near,outch10:near,outch1:near,testakth:near
extrn    getakt:near,getnakt:near,outtxt:near,tisknm20:near,flags:byte
extrn    tisknm2s:near,numsrc:byte,bufsrc:byte,lowcase:near,deknum:near,textvy1:byte
extrn    transtxt:near,setkonc:near,textvy13:byte,textvy14:byte,textvy2:byte
extrn    testkonc:near,center:near,aktkurz:near,parint:byte,citachod:byte
extrn    textcek:byte,deknumx:near,textsp23:byte,lensi:near,parnum:byte
extrn    textsp1:byte,textsp2:byte,textsp20:byte,textsp21:byte,textsp22:byte
extrn    textsp3:byte,textsp30:byte,textsp31:byte,textsp32:byte,textsp4:byte
extrn    testakt:near,txtsubd:byte,txtupd:byte,tisknm0:near,texthlp:byte
extrn    deknum5:near,textvy21:byte,textvy22:byte,dekfile:near,conf2:byte
extrn    testsetw:near,mouseon:near,mouseoff:near,getnumf:near
extrn    getnuml:near,getendl:near,getdispl:near,getnumf:near,outch0:near
extrn    displ:byte,delvram:word,lowcase0:near,parint2:byte,parrez:byte
extrn    edittop0:near,editall:near,outedhlp:near,outhelp:near
extrn    zobtopini:near,zobhlp0:near,zoball:near
extrn    adrmaskl:word,maskl:byte,adrmaskr:word,maskr:byte
extrn    rozbset:byte,rozbor:near,conf6:byte,col3:byte
extrn    getendlw:near,getnumlw:near,getnumfw:near,storekur:near
extrn    volr:byte,voll:byte,rootdir:byte,conf5:byte,soubinf:byte
extrn    getmax:near,pathhome:byte,outbuf4:byte,rozbflg:byte,soubfil:byte


public   readdir

readdir:                                  ;* aktualizace - naáten° adres†©e
                                            ; VSTUP: BP=ukazatel okna

         sti
         cld
         push      word ptr cs:[parbreak]   ; £schova parametru p©eru®en°
         mov       word ptr cs:[parbreak],0
         call      msgcek                   ; hl†®en° "áekejte"
         test      byte ptr cs:[bp+0],4     ; nuluje se adres†© ?
         jz        readdir0                 ; adres†© se nuluje
         call      oznacdir                 ; oznaákov†n° poloëek adres†©e
         jmp       short readdir1
readdir0:call      dirnul                   ; vynulov†n° adres†©e
readdir1:call      dirread                  ; naáten° novÇho adres†©e
         jc        readdir5                 ; diskov† chyba
         call      inforead                 ; áten° pozn†mek k souborñm
         jc        readdir5                 ; diskov† chyba
         test      byte ptr cs:[bp+0],4     ; nuluje se adres†© ?
         jz        readdir3                 ; adres†© se nuloval
         call      oznacdel                 ; zru®en° oznaákovanòch poloëek
readdir3:call      aktdisk                  ; aktualizace parametrñ disku
         clc
         call      diskfail                 ; diskov† chyba
         jc        readdir5                 ; je diskov† chyba
         call      aktfile                  ; aktualizace kapacity souborñ
         call      settabf                  ; nastaven° ukazatelñ tabulky
         or        byte ptr cs:[bp+0],2     ; nastaven° p©°znaku naáten° adres.
readdir5:pop       word ptr cs:[parbreak]   ; n†vrat parametry p©eru®en°
         call      topret                   ; navr†cen° horn°ho ©†dku
         ret

; -----------------------------------------------------------------------------
public   oznacdir

oznacdir:                                 ;* oznaákov†n° poloëek adres†©e
                                            ; VSTUP: BP=adresa okna

         push      bx
         push      si
         push      ds
         xor       bx,bx                    ; ukazatel poloëek
oznacdr1:call      adrpolsi                 ; vòpoáet adresy poloëky DS:SI
         jc        oznacdr2                 ; nen° jië dal®° poloëka
         inc       bx                       ; zvò®en° ukazatele poloëek
         or        byte ptr ds:[si],8       ; oznaákov†n° poloëky
         test      byte ptr ds:[si],0c0h    ; je vybran† poloëka ?
         jnz       oznacdr1                 ; je vybran† poloëka - zñstane
         dec       bx                       ; n†vrat ukazatele poloëky
         call      delpolf                  ; zru®en° poloëky ze seznamu
         jnc       oznacdr1                 ; dal®° poloëka adres†©e
oznacdr2:pop       ds
         pop       si
         pop       bx
         ret

; -----------------------------------------------------------------------------
public   oznacdel

oznacdel:                                 ;* zru®en° oznaákovanòch poloëek
                                            ; VSTUP: BP=adresa okna

         push      bx
         push      si
         push      ds
         xor       bx,bx                    ; ukazatel poloëek
oznacdl1:call      adrpolsi                 ; vòpoáet adresy poloëky DS:SI
         jc        oznacdl3                 ; nen° jië dal®° poloëka
         inc       bx                       ; zvò®en° ukazatele poloëek
         test      byte ptr ds:[si],8       ; je to oznaákovan† poloëka ?
         jz        oznacdl1                 ; nen° to oznaákovan† poloëka
         dec       bx                       ; n†vrat ukazatele poloëek
         call      delpolf                  ; zru®en° poloëky ze seznamu
         jnc       oznacdl1                 ; dal®° poloëka adres†©e
oznacdl3:pop       ds
         pop       si
         pop       bx
         ret

; -----------------------------------------------------------------------------
public   dirnul

dirnul:                                   ;* vynulov†n° adres†©e
                                            ; VSTUP: BP=adresa okna

         push      ax
         test      byte ptr cs:[bp+29],4    ; je vytvo©en segment pozn†mek ?
         jz        dirnul1                  ; nen° vytvo©en
         and       byte ptr cs:[bp+29],not 4 ; zru®en° p©°znaku segmentu
         mov       al,cs:[bp+32]            ; á°slo segmentu pozn†mek
         call      delseg                   ; zru®en° segmentu pozn†mek

dirnul1: test      byte ptr cs:[bp+29],2    ; m† bòt zobrazen° pozn†mek ?
         jz        dirnul2                  ; nem† bòt zobrazen° pozn†mek
         call      createseg                ; vytvo©en° segmentu pozn†mek
         jc        dirnul2                  ; nen° volnò segment
         mov       cs:[bp+32],al            ; £schova á°sla segmentu pozn†mek
         or        byte ptr cs:[bp+29],4    ; p©°znak vytvo©en° segmentu
         mov       word ptr cs:[bp+33],0    ; vynulov†n° bufferu pozn†mek
dirnul2: mov       al,cs:[bp+6]             ; á°slo modifikovanÇho segmentu
         call      delseg                   ; zru®en° segmentu
         call      createseg                ; vytvo©en° novÇho segmentu
         mov       cs:[bp+6],al             ; £schova á°sla segmentu
         mov       word ptr cs:[bp+7],0     ; poáet poloëek = 0
infordb: pop       ax
inforda: ret

; -----------------------------------------------------------------------------
public   inforead
inforead:                                 ;* áten° pozn†mek k souborñm

         test      byte ptr cs:[bp+29],2    ; naá°taj° se pozn†mky ?
         jz        inforda                  ; pozn†mky se nenaá°taj°

                                          ;* p©°padnÇ vytvo©en° segmentu
         push      ax
         test      byte ptr cs:[bp+29],4    ; je segment vytvo©en ?
         jnz       inford1                  ; segment je vytvo©en
         call      createseg                ; vytvo©en° segmentu pozn†mek
         jc        infordb                  ; nen° volnò segment
         mov       cs:[bp+32],al            ; £schova á°sla segmentu pozn†mek
         or        byte ptr cs:[bp+29],4    ; p©°znak vytvo©en° segmentu
         mov       word ptr cs:[bp+33],0    ; vynulov†n° bufferu pozn†mek
inford1: push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es
         push      cs
         pop       es
         push      cs
         pop       ds

                                          ;* vytvo©en° maxim†ln°ho segmentu
         call      getmax                   ; poskytnut° max. velikosti segmentu
         jc        inford8                  ; nen° voln† pamàü
         sub       bx,15000
         jc        inford8
;         mov       bx,2000
         mov       al,ds:[bp+32]            ; á°slo segmentu pozn†mek
         call      modiseg                  ; modifikace segmentu na max. velik.
         jc        inford8
                                          ;* nastaven° adres†©e okna
         mov       si,ds:[bp+4]             ; cesta k adres†©i
         call      aktdir                   ; nastaven° aktivn°ho adres†©e okna
         clc
         call      diskfail                 ; test diskovÇ chyby
         jc        inford9                  ; diskov† chyba
                                          ;* nalezen° v aktivn°m adres†©i
         mov       dx,offset soubfil        ; soubor DOSMAN.FIL
         mov       ax,3d00h
         int       21h                      ; nalezen° souboru v akt. adres†©i
         jnc       inford2                  ; soubor nalezen OK
                                          ;* nastaven° domovskÇho adres†©e
         mov       si,offset pathhome       ; cesta k domovskÇmu adres†©i
         call      aktdir                   ; nastaven° domovskÇho adres†©e
         clc
         call      diskfail                 ; test diskovÇ chyby
         jc        inford9                  ; diskov† chyba
                                          ;* nalezen° v domovskÇm adres†©i
         mov       dx,offset soubfil        ; soubor DOSMAN.FIL
         mov       ax,3d00h
         int       21h                      ; nalezen° souboru v akt. adres†©i
         jc        inford8                  ; soubor nenalezen

inford2:                                  ;* p©°prava registrñ pro áten°
         push      ax                       ; £schova identifik†toru souboru
         mov       cx,bx                    ; velikost p©idàlenÇho segmentu
         mov       al,ds:[bp+32]            ; á°slo segmentu pozn†mek
         call      getseg                   ; poskytnut° adresy segmentu
         mov       ds,bx                    ; adresa segmentu
         pop       bx                       ; identifik†tor souboru
                                          ;* naáten° souboru do pamàti
         xor       dx,dx                    ; offset k naáten° souboru
         inc       dx                       ; adresa k naáten° = 1
         dec       cx
         mov       ah,3fh
         int       21h                      ; áten° souboru do pamàti
         jc        inford7                  ; chyba áten° souboru
         mov       cs:[bp+33],ax            ; poáet bajtñ v segmentu
                                          ;* zru®en° znakñ LF
         mov       byte ptr ds:[0],0
         mov       cx,ax                    ; poáet bajtñ v segmentu
         add       cx,2
         cld
         push      ds
         pop       es
         xor       di,di                    ; poá†teán° adresa k hled†n°
         mov       al,10                    ; hledanò bajt LF
         cld
inford6: jcxz      inford7                  ; nen° jië dal®° bajt
         repne     scasb
         mov       byte ptr es:[di-1],0     ; n†hrada bajtem 0
         je        inford6                  ; nalezen° dal®°ho bajtu LF

inford7: mov       ah,3eh
         int       21h                      ; uzav©en° souboru

inford8: clc
inford9: pushf
         mov       al,cs:[bp+32]            ; á°slo segmentu pozn†mek
         mov       bx,cs:[bp+33]            ; poáet bajtñ v segmentu
         call      modiseg                  ; modifikace segmentu na minimum
         popf
         call      diskfail                 ; test diskovÇ chyby
         pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   dirread

dirread:                                  ;* novÇ naáten° adres†©e
                                            ; VSTUP: BP=adresa okna
                                            ; VùSTUP: CY=diskov† chyba

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es
         push      cs
         pop       es
         push      cs
         pop       ds

         mov       dx,80h                   ; adresa DTA
         mov       ah,1ah
         int       21h                      ; definice adresy DTA

         test      byte ptr ds:[conf5],80h  ; zobrazuje se n†và®t° ?
         jz        dirrd42                  ; n†và®t° se nezobrazuje
                                          ;* nastaven° z†kladn°ho adres†©e
         mov       si,ds:[bp+4]             ; cesta k adres†©i
         mov       dl,ds:[si]               ; disk
         sub       dl,"A"                   ; á°slo disku
         mov       ah,0eh
         int       21h                      ; nastaven° aktivn°ho disku
         mov       si,offset rootdir        ; specifikace z†kladn°ho adres†©e
         call      aktdir                   ; nastaven° z†kladn°ho adres†©e
         clc
         call      diskfail                 ; test diskovÇ chyby
         jc        dirrd44                  ; je diskov† chyba
                                          ;* nalezen° n†và®t° disku
         call      getvol                   ; poskytnut° adresy n†và®t°
         mov       byte ptr ds:[si],0       ; zru®en° pñvodn°ho n†và®t°
         mov       di,si                    ; adresa n†và®t°
         mov       cx,8                     ; atributy - n†và®t° disku
         mov       dx,offset all            ; specifikace - v®echna
         mov       ah,4eh
dirrd41: int       21h                      ; nalezen° n†và®t° disku
         jc        dirrd42                  ; navà®t° nenalezeno
         mov       ah,4fh                   ; funkce nalezen° dal®° poloëky
         test      byte ptr ds:[95h],8      ; je to n†và®t° ?
         jz        dirrd41                  ; nen° to n†và®t° - dal®° poloëka
                                          ;* uloëen° n†và®t° disku
         mov       cx,12                    ; maxim†ln° poáet znakñ
         mov       si,9eh                   ; jmÇno n†và®t°
dirrd43: lodsb
         cmp       al,"."
         je        dirrd45
         stosb
dirrd45: loop      dirrd43
         xor       al,al
         stosb
dirrd42:
                                          ;* inicializace adres†©e
         mov       si,ds:[bp+4]             ; cesta k adres†©i
         mov       di,si
         call      aktdir                   ; nastaven° aktivn°ho adres†©e okna
         clc
         call      diskfail                 ; test diskovÇ chyby
         jc        dirrd44                  ; diskov† chyba
         call      loadpath                 ; naáten° aktu†ln° cesty
         call      diskfail                 ; test diskovÇ chyby
dirrd44: jc        dirrd4                   ; diskov† chyba
                                          ;* vnucen° adres†©e ".."
         cmp       byte ptr ds:[si+3],0     ; je z†kladn° adres†© ?
         je        dirrd0                   ; je z†kladn° adres†©
         mov       di,95h                   ; atributy souboru
         mov       al,10h                   ; atributy souboru
         stosb                              ; uloëen° atributñ souboru
         xor       ax,ax                    ; AX <- 0 nulovac° slovo
         stosw                              ; áas
         stosw                              ; datum
         stosw                              ; velikost - LOW
         stosw                              ; velikost - HIGH
         mov       ax,".."                  ; jmÇno adres†©e
         stosw                              ; jmÇno adres†©e
         xor       al,al
         stosb                              ; koncovò bajt 0
         lea       si,[bufwin]              ; pracovn° buffer
         call      creatfile                ; vytvo©en° poloëky souboru
         call      storfile                 ; uloëen° poloëky do seznamu adres.
dirrd0:                                   ;* naáten° jednotlivòch poloëek
         mov       cx,10h                   ; atribut - norm†ln° soubory a adr.
         test      byte ptr cs:[conf6],1    ; povolenÇ soubory HID/SYS ?
         jz        dirrd01                  ; jenom norm†ln° soubory a adres†©e
         mov       cl,16h                   ; atribut - takÇ HID a SYS
dirrd01: lea       dx,[all]                 ; specifikace - v®echny soubory
         mov       ah,4eh                   ; funkce nalezen° prvn° poloëky
dirrd1:  int       21h                      ; naáten° poloëky adres†©e
         jnc       dirrd5                   ; poloëka nalezena OK
         cmp       ax,2                     ; soubor nenalezen ?
         je        dirrd4                   ; soubor nenalezen
         cmp       ax,12h                   ; dal®° soubor nenalezen ?
         je        dirrd4                   ; dal®° soubor nenalezen
         stc                                ; p©°znak chyby
dirrd5:  call      diskfail                 ; test diskovÇ chyby
         jc        dirrd4                   ; je diskov† chyba
         test      byte ptr ds:[95h],10h    ; je to adres†© ?
         jz        dirrd2                   ; nen° to adres†© - uloëen° poloëky
         cmp       word ptr ds:[9eh],"."    ; je to oznaáen° aktiv. adres†©e ?
         je        dirrd3                   ; je aktivn° adres†© - neuloë° se

dirrd2:  lea       si,[bufwin]              ; pracovn° buffer
         call      creatfile                ; vytvo©en° poloëky souboru
         test      byte ptr ds:[95h],10h    ; je to adres†© ?
         jnz       dirrd6                   ; je to to adres†© - uloëen° poloëky
                                          ;* porovn†n° poloëky
         push      si
         push      di
         mov       di,cs:[bp+30]            ; zadan† mask
         add       di,13                    ; maska rozepsan†
         call      cmpfile                  ; porovn†n° jmen
         pop       di
         pop       si
         clc
         jne       dirrd3                   ; nen° povolenò soubor

dirrd6:  call      storfile                 ; uloëen° poloëky do seznamu adres.
dirrd3:  mov       ah,4fh                   ; funkce nalezen° dal®° poloëky
         jnc       dirrd1                   ; nalezen° dal®° poloëky
         clc

dirrd4:  call      diskfail                 ; test diskovÇ chyby
         pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   obnovs

obnovs:                                   ;* obnoven° souboru v adres†©i
                                            ; VSTUP: DS:SI=soubor (vnit©n° tvar)

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

         push      cs
         pop       es
         lea       di,[bufwin]              ; pracovn° buffer
         mov       dx,di
         call      dekfile                  ; dek¢dov†n° jmÇna souboru
         push      cs
         pop       ds
         mov       si,dx
         mov       cx,16h                   ; atribut pro hled†n° poloëek
         mov       ah,4eh                   ; funkce nalezen° prvn° poloëky
         int       21h                      ; naáten° poloëky adres†©e
         jc        obnovs3                  ; poloëka nenalezena
         call      creatfile                ; vytvo©en° poloëky souboru
         call      storfile                 ; uloëen° poloëky do seznamu adres.

obnovs3: pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   diskfail

diskfail:                                 ;* diskov† chyba
                                            ; VSTUP: CY=p©°znak chyby
                                            ; VùSTUP: CY=diskov† chyba

         push      ax
         rcl       al,1                     ; uschova priznaku CY
         cmp       word ptr cs:[parbreak],0 ; je nàjak† chyba ?
         je        diskf6                   ; nen° ë†dn† chyba
;         cmp       word ptr cs:[parbreak],-2 ; je ignorov†n° chyby ?
;         je        diskf6
         and       byte ptr cs:[bp+0],not 3 ; vypnut° okna, adres. nenaáten
         or        al,1                     ; nastaveni priznaku CY
diskf6:  rcr       al,1                     ; navrat priznaku CY
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   adrpolsi

adrpolsi:                                 ;* vòpoáet adresy poloëky SI
                                            ; VSTUP: BX=á°slo poloëky
                                            ;        BP=ukazatel tabulky okna
                                            ; VùSTUP: DS:SI=adresa poloëky
                                            ;         CY=neplatnÇ á°slo poloëky

         push      ax
         push      dx
         push      bx                       ; á°slo poloëky
         mov       al,cs:[bp+6]             ; á°slo segmentu adres†©e
         call      getseg                   ; poskytnut° adresy segmentu
         mov       ds,bx                    ; nastaven° segmentu seznamu
         pop       bx                       ; á°slo poloëky
         mov       ax,20                    ; dÇlka 1 poloëky seznamu
         mul       bx                       ; vòpoáet
         mov       si,ax                    ; adresa poloëky v seznamu
         cmp       bx,cs:[bp+7]             ; kontrola p©ekroáen° seznamu
         cmc
         pop       dx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   adrpoldi

adrpoldi:                                 ;* vòpoáet adresy poloëky DI
                                            ; VSTUP: BX=á°slo poloëky
                                            ;        BP=ukazatel tabulky okna
                                            ; VùSTUP: ES:DI=adresa poloëky
                                            ;         CY=neplatnÇ á°slo poloëky

         push      ds
         push      si
         call      adrpolsi                 ; vòpoáet adresy poloëky SI
         mov       di,si                    ; offset poloëky
         push      ds                       ; segment seznamu
         pop       es
         pop       si
         pop       ds
         ret

; -----------------------------------------------------------------------------
public   creatfile

creatfile:                                ;* vytvo©en° poloëky souboru
                                            ; VSTUP: DS:SI=buffer pro uloë.pol.

         push      ax
         push      si
         push      di
         push      ds
         push      es
         push      ds
         pop       es
         push      cs
         pop       ds                       ; DS <- segment s tabulkou
         mov       di,si                    ; ukl†dac° adresa

         mov       si,95h                   ; atribut nalezenÇho souboru
         lodsb                              ; atribut souboru
         and       al,37h                   ; vynuluje atributy 6, 7 a 3
         stosb                              ; p©enos atributu poloëky
         mov       si,9eh                   ; jmÇno nalezenÇho souboru
         call      rozborn                  ; zak¢dov†n° jmÇna souboru
         add       di,11                    ; zvò®en° ukl†dac° adresy
         mov       si,9ah                   ; velikost souboru
         movsw                              ; nië®° slovo velikosti souboru
         movsw                              ; p©enos velikosti souboru
         mov       si,98h                   ; datum souboru
         movsw                              ; p©enos data souboru
         mov       si,96h                   ; áas souboru
         movsw                              ; p©enos áasu souboru

         pop       es
         pop       ds
         pop       di
         pop       si
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   storfile

storfile:                                 ;* zaálenàn° poloëky do seznamu
                                            ; VSTUP: BP=ukazatel tabulky okna
                                            ;        DS:SI=soubor k uloëen°
                                            ; VùSTUP: CY=nedostatek pamàti

         push      bx
         test      byte ptr cs:[bp+0],4     ; nuluje se adres†© ?
         jz        storfil2                 ; adres†© se nuluje
         call      hledpol0                 ; nalezen° stejnÇ poloëky
         jc        storfil2                 ; poloëka nenalezena
         push      bx                       ; £schova ukazatele poloëky
         call      getatrib                 ; poskytnut° atributu poloëky
         and       bl,0c0h                  ; ponech†n° oznaáen° poloëky
         or        ds:[si],bl               ; nastaven° atributu
         pop       bx
         call      delpolf                  ; zru®en° poloëky ze seznamu
storfil2:call      hledpol                  ; nalezen° poloëky v seznamu
         call      insertf                  ; vloëen° souboru do seznamu
         pop       bx
         ret

; -----------------------------------------------------------------------------
public   cmpfile

cmpfile:                                  ;* porovn†n° souborñ DS:SI a ES:DI
                                            ; VSTUP: ES:DI,DS:SI=soubory

         push      ax
         push      cx
         push      si
         push      di
                                          ;* jsou jmÇna souborñ shodnÇ ?
         inc       si                       ; adresa jmÇna souboru 1
         inc       di                       ; adresa jmÇna souboru 2
         mov       cx,11                    ; poáet znakñ jmÇna a extentu
         call      cmpname                  ; porovn†n° jmÇna i s p©°ponou
         je        cmpfil6                  ; jsou shodn† jmÇna souborñ
                                          ;* test jmÇna adres†©e ".."
         cmp       word ptr ds:[si],".."    ; je to adres†© ".." ?
         je        cmpfil3                  ; p©°znak BELOW
         cmp       word ptr es:[di],".."    ; je adres†© ".." ?
         jne       cmpfil7                  ; nen° to adres†© ".."
         or        cl,cl                    ; p©°znak ABOWE
         jmp       short cmpfil6            ; n†vrat
cmpfil7:                                  ;* porovn†n° atributñ
         mov       al,es:[di-1]             ; atribut souboru 2
         call      normatr                  ; normalizace atributu 2
         mov       ah,al                    ; AH <- atribut souboru 2
         mov       al,ds:[si-1]             ; atribut souboru 1
         call      normatr                  ; normalizace atributu 1
         cmp       ah,al                    ; porovn†n° atributñ 2 a 1
         jne       cmpfil5                  ; atributy nejsou shodnÇ
                                          ;* porovn†n° podle p©°pony
         test      byte ptr cs:[bp+0],20h   ; je t©°dàn° podle p©°pony ?
         jz        cmpfil1                  ; nen° t©°dàn° podle p©°pony
         push      si
         push      di
         push      cx
         mov       cl,3                     ; dÇlka p©°pony
         add       si,8                     ; adresa p©°pony
         add       di,8                     ; adresa p©°pony
         call      cmpname                  ; porovn†n° p©°pony
         pop       cx
         pop       di
         pop       si
         jne       cmpfil5                  ; nen° shoda
cmpfil1:                                  ;* porovn†n° podle data a áasu
         test      byte ptr cs:[bp+0],40h   ; je t©°dàn° podle data a áasu ?
         jz        cmpfil2                  ; nen° t©°dàn° podle data a áasu
         mov       ax,es:[di+15]            ; datum
         cmp       ax,ds:[si+15]
         jne       cmpfil5                  ; je rozd°l
         mov       ax,es:[di+17]            ; áas
         cmp       ax,ds:[si+17]
         jne       cmpfil5                  ; je rozd°l
cmpfil2:                                  ;* porovn†n° podle velikosti
         test      byte ptr cs:[bp+0],80h   ; je t©°dàn° podle velikosti ?
         jz        cmpfil4                  ; nen° t©°dàn° podle velikosti
         mov       ax,es:[di+13]            ; vy®®° slovo velikosti
         cmp       ax,ds:[si+13]
         jne       cmpfil5                  ; je rozd°l
         mov       ax,es:[di+11]            ; nië®° slovo velikost
         cmp       ax,ds:[si+11]
         jne       cmpfil5                  ; je rozd°l
                                          ;* porovn†n° jmÇna
cmpfil4: call      cmpname                  ; porovn†n° jmÇna i p©°pony
cmpfil5: ja        cmpfil6                  ; je vàt®°
                                          ;* (je men®°) net©°dit
         test      byte ptr cs:[bp+0],10h   ; je vypnuto t©°dàn° souborñ ?
         jnz       cmpfil6                  ; t©°dàn° je vypnuto
cmpfil3: sub       ch,1                     ; p©°znak BELOW
cmpfil6: pop       di
         pop       si
         pop       cx
         pop       ax
         ret


public   cmpname

cmpname:                                  ;* porovn†n° á†sti jmÇna CMP DS:SI,ES:DI
                                            ; VSTUP: ES:DI,DS:SI=soubory
                                            ;        CX=poáet znakñ k porovn†n°

         push      ax
         push      cx
         push      si
         push      di
cmpname1:cmpsb                              ; porovn†n° 1 znaku
         je        cmpname2                 ; je shoda
         cmp       byte ptr ds:[si-1],"?"   ; je znak "?" ?
         je        cmpname2                 ; je n†hradn° znak - shoda
         cmp       byte ptr es:[di-1],"?"   ; je znak "?" ?
         je        cmpname2                 ; je n†hradn° znak - shoda
         mov       al,ds:[si-1]
         cmp       al,es:[di-1]             ; porovn†n° rozd°lu neshodnòch znakñ
cmpname2:loopz     cmpname1                 ; p©i shodà porovn†n° dal®°ho znaku
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret


public   normatr

normatr:                                  ;* normalizace atributu
                                            ; VSTUP: AL=atribut souboru

         push      bx
         mov       bl,al                    ; £schova atributu
         shl       al,1                     ; AL * 2 (bit 1 se p©evede na bit 2)
         and       al,4                     ; ponech† bit 2 (=bit 1)
         or        al,bl                    ; atribut souboru (HID + SYS)
         and       al,14h                   ; ponech† bity 4, 2 (a 1)
         test      al,10h                   ; je adres†© ?
         jz        normatr1                 ; nen° adres†©
         and       al,10h                   ; zru®en° p©°znaku HID a SYS
normatr1:pop       bx
         ret

; -----------------------------------------------------------------------------
public   delpolf

delpolf:                                  ;* zru®en° poloëky ze seznamu
                                            ; VSTUP: BX=á°slo poloëky
                                            ;        BP=ukazatel tabulky okna
                                            ; VùSTUP: CY=neplatnÇ á°slo poloëky

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es
                                          ;* vypu®tàn° poloëky
         call      adrpoldi                 ; vòpoáet adresy poloëky ES:DI
         jc        delpolf1                 ; nen° platn† poloëka
         dec       word ptr cs:[bp+7]       ; sn°ëen° poátu poloëek v seznamu
         mov       bx,cs:[bp+7]             ; poáet poloëek v seznamu - 1
         call      adrpolsi                 ; adresa posledn° poloëky
         mov       cx,si                    ; adresa posledn° poloëky
         sub       cx,di                    ; dÇlka dat k p©enosu
         mov       si,di                    ; zaá†tek seznamu
         add       si,20                    ; konec posledn° poloëky

         cld
         shr       cx,1
         rep       movsw
         jnc       delpolf3
         movsb
delpolf3:

;         rep       movsb                    ; p©enos - zru®en° poloëky

                                          ;* modifikace konce pamàti
         mov       bx,di                    ; nov† adresa konce seznamu
         mov       al,cs:[bp+6]             ; á°slo segmentu seznamu
         call      modiseg                  ; modifikace velikosti segmentu

delpolf1:pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   insertf

insertf:                                  ;* vloëen° poloëky do seznamu
                                            ; VSTUP: DS:SI=soubor
                                            ;        BX=á°slo poloëky
                                            ;        BP=ukazatel tabulky okna
                                            ; VùSTUP: CY=p©eplnàn° pamàti
         push      ax
         push      bx
         push      cx
         push      si
         push      di
         push      es
                                          ;* je p©epis poloëky ?
         mov       cx,11                    ; dÇlka jmÇna
         call      adrpoldi                 ; poskytnut° adresy poloëky
         jc        insertf0                 ; je nov† poloëka
         call      cmpfile                  ; porovn†n° souborñ
         je        insertf2                 ; m† stejnÇ jmÇno - p©eps†n°
insertf0:                                 ;* nastaven° novÇ velikosti segmentu
         mov       ax,cs:[bp+7]             ; poáet poloëek v seznamu
         inc       ax                       ; novò poáet poloëek v seznamu
         mov       cl,20                    ; dÇlka 1 poloëky seznamu
         mul       cx                       ; vòpoáet adresy konce
         mov       bx,ax                    ; adresa poloëky v seznamu
         mov       al,cs:[bp+6]             ; á°slo segmentu seznamu
         call      modiseg                  ; modifikace velikosti segmentu
         jc        insertf1                 ; chyba - nedostatek pamàti
                                          ;* vytvo©en° m°sta v seznamu
         push      di                       ; ukl†dac° adresa
         push      si                       ; zdrojov† adresa
         push      ds                       ; £schova DS
         mov       bx,cs:[bp+7]             ; poáet poloëek v seznamu
         call      adrpolsi                 ; adresa konce seznamu
         mov       cx,si                    ; novò konec pamàti
         sub       cx,di                    ; poáet bajtñ k p©esunu
         mov       di,si                    ; adresa konce seznamu
         add       di,19                    ; nov† posledn° poloëka
         dec       si                       ; korekce na konec dat
         std                                ; smàr posunu ukazatele dolñ


         dec       si
         dec       di
         shr       cx,1

         rep       movsw

         jnc       insertf4
         movsb
insertf4:

;         rep       movsb                    ; p©enos zbytku pamàti (INSERT)

         cld                                ; smàr posunu ukazatele nahoru
         pop       ds                       ; n†vrat DS
         pop       si                       ; n†vrat adresy souboru
         pop       di                       ; n†vrat ukl†dac° adresy
                                          ;* p©enos poloëky
         inc       word ptr cs:[bp+7]       ; zvò®en° poátu poloëek v seznamu
         mov       byte ptr es:[di],0       ; zru®en° p©°znaku vòbàru
insertf2:mov       al,es:[di]               ; pñvodn° atributy souboru
         and       al,0c0h                  ; ponech† p©°znaky oznaáen°

         mov       cl,10
         rep       movsw

;         mov       cl,20                    ; dÇlka poloëky souboru
;         rep       movsb                    ; p©enos - uloëen° poloëky souboru

         or        es:[di-20],al            ; n†vrat p©°znaku oznaáen°
insertf1:pop       es
         pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   aktdisk

aktdisk:                                  ;* aktualizace kapacity aktiv. disku
                                            ; VSTUP: BP=adresa tabulky parametrñ
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

         push      cs
         pop       es                       ; ES <- CS

         mov       di,cs:[bp+4]             ; adresa cesty
         mov       dl,cs:[di]               ; disk
         sub       dl,"A"-1                 ; á°slo disku
         mov       ah,36h                   ; funkce poskytnut° kapacity disku
         int       21h                      ; poskytnut° kapacity disku
         clc
         call      diskfail                 ; byla diskov† chyba ?
         jc        aktdisk2                 ; byla diskov† chyba
         lea       di,[bp+13]               ; zaá†tek parametrñ disku
         cld
         push      bx                       ; poáet volnòch alokaán°ch blokñ

         push      dx                       ; celkovò poáet alokaán°ch blokñ
         mul       cx                       ; vòpoáet kapacity alokaán°ho bloku
         stosw                              ; uloëen° kapacity alokaán°ho bloku
         mov       cx,ax                    ; £schova kapacity alokaán°ho bloku
         mov       si,dx                    ; kapacita alokaán°ho bloku HIGH
         pop       ax                       ; celkovò poáet alokaán°ch blokñ

         push      ax
         mul       cx                       ; vòpoáet celkovÇ kapacity disku LOW
         stosw                              ; nië®° slovo kapacity disku
         mov       ax,dx                    ; vy®®° slovo kapacity disku
         stosw                              ; vy®®° slovo kapacity disku
         pop       ax                       ; celkovò poáet alokaán°ch blokñ
         mul       si                       ; celkov† kapacita HIGH
         add       es:[di-2],ax             ; p©iáten° celkovÇ kapacity HIGH

         pop       ax                       ; poáet volnòch alokaán°ch blokñ
         push      ax
         mul       cx                       ; vòpoáet volnÇ kapacity disku
         stosw                              ; nië®° slovo volnÇ kapacity disku
         mov       ax,dx                    ; vy®®° slovo volnÇ kapacity disku
         stosw                              ; vy®®° slovo volnÇ kapacity disku
         pop       ax                       ; poáet volnòch alok. blokñ
         mul       si                       ; poáet volnòch blokñ HIGH
         add       es:[di-2],ax             ; p©iáten° volnòch blokñ HIGH

aktdisk2:
         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   aktfile

aktfile:                                  ;* zji®tàn° kapacity v adres†©i
                                            ; VSTUP: BP=adresa tabulky parametrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      ds

         xor       ax,ax                    ; AX <- 0 nulovac° slovo
         mov       cs:[bp+23],ax            ; poáet souborñ = 0
         mov       cs:[bp+25],ax            ; kapacita souborñ (LOW) = 0
         mov       cs:[bp+27],ax            ; kapacita souborñ (HIGH) = 0
         mov       cx,cs:[bp+13]            ; velikost alokaán°ho bloku
         xor       bx,bx                    ; á°slo prvn° poloëky = 0
         cmp       cx,32
         jb        aktfil5                  ; mal† velikost bloku

aktfil1: call      adrpolsi                 ; poskytnut° adresy poloëky
         jc        aktfil5                  ; nen° jië dal®° poloëka
         test      byte ptr ds:[si],10h     ; je adres†© ?
         jnz       aktfil4                  ; je adres†© - dal®° soub.

         inc       word ptr cs:[bp+23]      ; zvò®en° poátu souborñ
         mov       ax,ds:[si+12]            ; nië®° slovo velikosti
         mov       dx,ds:[si+14]            ; vy®®° slovo velikosti

;aktfil2: or        dx,dx                    ; je DX=0 ?
;         jnz       aktfil3                  ; DX nen° 0
;         or        ax,ax                    ; je AX=0 ?
;         jz        aktfil4                  ; AX i DX je = 0
;aktfil3: add       word ptr cs:[bp+25],cx   ; p©iáten° alokaán°ho bloku k souátu
;         adc       word ptr cs:[bp+27],0    ; p©enos do vy®®°ho slova
;         sub       ax,cx                    ; odeáten° od nië®°ho slova
;         sbb       dx,0                     ; odeáten° p©enosu
;         jnc       aktfil2                  ; nen° je®tà p©eteáen°

         add       cs:[bp+25],ax             ; p©iáten° velikosti LOW
         adc       cs:[bp+27],dx             ; p©iáten° velikosti HIGH

         push      ax                       ; £schova nië®°ho slova á°sla
         mov       ax,dx                    ; vy®®° slovo á°sla
         xor       dx,dx                    ; DX <- 0
         div       cx                       ; vydàlen° vy®®°ho slova á°sla
         pop       ax                       ; n†vrat nië®°ho slova
         div       cx                       ; vydàlen° nië®°ho slova á°sla
         or        dx,dx                    ; je je®tà dal®° blok ?
         jz        aktfil4                  ; nen° dal®° blok

         mov       ax,cx                    ; velikost bloku
         sub       ax,dx                    ; zbytek do plnÇho bloku
         add       cs:[bp+25],ax            ; p©iáten° je®tà zbytku bloku
         adc       word ptr cs:[bp+27],0    ; p©enos do vy®®°ho slova

aktfil4: inc       bx                       ; zvò®en° á°sla poloëky
         jmp       short aktfil1            ; dal®° poloëka adres†©e
aktfil5:
         pop       ds
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   settabf

settabf:                                  ;* nastaven° ukazatelñ tabulky souborñ
                                            ; VSTUP: BP=adresa tabulky parametrñ

         push      ax
         push      bx
         push      si
         push      ds
         push      cs
         pop       ds
         lea       si,[namel]               ; jmÇno souboru L
         mov       bx,ds:[firstwl]          ; prvn° poloëka
         cmp       bp,offset tabr           ; je to pravÇ okno ?
         jne       settabf1                 ; je to levÇ okno
         lea       si,[namer]               ; jmÇno souboru R
         mov       bx,ds:[firstwr]          ; prvn° poloëka
settabf1:
         mov       word ptr ds:[bp+9],bx    ; poá†teán° poloëka
;         xor       bx,bx
;         test      byte ptr ds:[bp+0],4     ; nuluje se adres†© ?
;         jz        settabf2                 ; adres†© se nuluje
         call      hledpol0                 ; nalezen° poloëky v seznamu
         jnc       settabf2                 ; poloëka nalezena OK
         xor       bx,bx                    ; n†hradn° poloëka - prvn° poloëka
         test      byte ptr ds:[bp+0],10h   ; je net©°dànÇ okno ?
         jnz       settabf2                 ; je net©°dànÇ okno
                                          ;* nalezen° nejblië®° poloëky
         call      hledpol                  ; nalezen° nejblië®° poloëky
         cmp       bx,ds:[bp+7]             ; je za posledn° poloëkou ?
         jb        settabf2                 ; nen° za posledn° poloëkou
         mov       bx,ds:[bp+7]             ; n†hradn° poloëka
         dec       bx
settabf2:mov       ds:[bp+11],bx            ; nastaven° pozice kurzoru
         xor       ax,ax
         call      usesedit                 ; normalizace poloëek
         pop       ds
         pop       si
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   hledpol0

hledpol0:                                 ;* nalezen° stejnÇ poloëky v seznamu
                                            ; VSTUP: DS:SI=poloëka (vnit©. tvar)
                                            ; VùSTUP: BX=á°slo nalezenÇ poloëky
                                            ;         CY=poloëka nenalezena

         push      di
         push      es
         xor       bx,bx                    ; ukazatel poloëek - 1.poloëka
hledpol1:call      adrpoldi                 ; poskytnut° adresy prvn° poloëky
         jc        hledpol2                 ; konec seznamu - poloëka nenalezena
         call      cmpfile                  ; porovn†n° souborñ SI,DI
         je        hledpol2                 ; nalezen stejnò soubor
         inc       bx                       ; zvò®en° ukazatele poloëky
         jmp       short hledpol1           ; test dal®° poloëky
hledpol2:pop       es
         pop       di
         ret

; -----------------------------------------------------------------------------
public   hledpol

hledpol:                                  ;* nalezen° poloëky v seznamu
                                            ; VSTUP: DS:SI=poloëka (vnit©. tvar)
                                            ; VùSTUP: BX=á°slo nalezenÇ poloëky
                                            ;         CY=poloëka nenalezena

         push      di
         push      es
         xor       bx,bx                    ; ukazatel poloëek - 1.poloëka
hledpol3:call      adrpoldi                 ; poskytnut° adresy prvn° poloëky
         jc        hledpol4                 ; je jië konec seznamu
         call      cmpfile                  ; porovn†n° souborñ SI,DI
         jbe       hledpol4                 ; soubor je men®° nebo shodnò
         inc       bx                       ; zvò®en° ukazatele poloëky
         jmp       short hledpol3           ; test dal®° poloëky
hledpol4:pop       es
         pop       di
         ret

; -----------------------------------------------------------------------------
public   soucins

soucins:                                  ;* souáet oznaáenòch souborñ
                                            ; VùSTUP: CX=poáet souborñ
                                            ;         DX:AX=souáet velikost°
                                            ;         ZY=nen° ë†dnò soubor

         push      bx
         push      si
         push      ds
         xor       ax,ax                    ; st©adaá souátu poloëek - LOW
         xor       dx,dx                    ; st©adaá souátu poloëek - HIGH
         xor       cx,cx                    ; st©adaá poátu poloëek
         xor       bx,bx                    ; ukazatel poloëek
soucins1:call      adrpolsi                 ; vòpoáet adresy poloëky
         jc        soucins3                 ; nen° jië dal®° soubor
         test      byte ptr ds:[si],80h     ; je oznaáenò soubor ?
         jz        soucins2                 ; nen° oznaáenò soubor
         inc       cx                       ; zvò®en° á°taáe oznaáenòch souborñ
         add       ax,ds:[si+12]            ; p©iáten° nië®°ho slova velikosti
         adc       dx,ds:[si+14]            ; p©iáten° vy®®°ho slova velikosti
soucins2:inc       bx                       ; zvò®en° ukazatele souborñ
         jmp       short soucins1           ; test dal®°ho souboru
soucins3:or        cx,cx                    ; p©°znak ZY = nen° ë†dnò soubor
         pop       ds
         pop       si
         pop       bx
         ret

; -----------------------------------------------------------------------------
public   srcins,srcnxt,srcins0

srcins:                                   ;* nalezen° prvn° oznaáenÇ poloëky
                                            ; VSTUP: BP=ukazatel definice
                                            ; VùSTUP: BX=á°slo poloëky
                                            ;         CY=poloëka nenalezena

         xor       bx,bx                    ; ukazatel prvn° poloëky
         jmp       short srcins0            ; nalezen° prvn° poloëky

srcnxt:                                   ;* nalezen° dal®° oznaáenÇ poloëky
                                            ; VSTUP: BP=ukazatel definice
                                            ;        BX=poloëka, za kterou hled†
                                            ; VùSTUP: BX=á°slo dal®° poloëky
                                            ;         CY=poloëka nenalezena
         inc       bx
srcins0:                                  ;* nalezen° oznaáenÇ poloëky
         push      si
         push      ds
srcins1: call      adrpolsi                 ; vòpoáet adresy poloëky DS:SI
         jc        srcins2                  ; nen° jië dal®° poloëka
         test      byte ptr ds:[si],80h     ; je oznaáen† poloëka ?
         jnz       srcins3                  ; je to oznaáen† poloëka
         inc       bx                       ; zvò®en° ukazatele poloëek
         jmp       short srcins1            ; test dal®° poloëky
srcins2: mov       bx,cs:[bp+11]            ; n†hradn° pozice - kurzor
srcins3: pop       ds
         pop       si
         ret

; *****************************************************************************
;
;                            Zobrazen° okna
;
; *****************************************************************************

public   window,window1

window:                                     ; zobrazen° okna
                                            ; VSTUP: BP=ukazatel parametrñ okna

         test      byte ptr cs:[parint],4   ; je aktivn° INT 24h ?
         jnz       window2                  ; je aktivn° INT 24h - obnova
         call      testaktw                 ; test zapnut° okna
         jc        window1                  ; okno nen° zapnuto

         test      byte ptr cs:[bp+0],2     ; je adres†© naáten ?
         jnz       window1                  ; adres†© je naáten
;         cmp       word ptr cs:[parbreak],0 ; je nàjak† chyba ?
;         je        window0                  ; nen° ë†dn† chyba
;         cmp       word ptr cs:[parbreak],-2 ; je ignorov†n° chyb ?
;         jne       window1                  ; je nàjak† chyba
window0: call      readdir                  ; aktualizace - naáten° adres†©ñ

window1: and       byte ptr cs:[bp+0],not 8 ; p©°znak, ëe okno nen° zobrazeno
         call      testaktw                 ; je okno zapnuto ?
         jc        window2                  ; okno nen° zapnuto
         or        byte ptr cs:[bp+0],8     ; p©°znak, ëe je okno zobrazeno
window2: call      topline                  ; zobrazen° 1. ©†dku
         call      space                    ; zobrazen° informac° o disku
         call      directory                ; zobrazen° informac° o adres†©i
         call      obrpath                  ; zobrazen° cesty
         call      files                    ; zobrazen° souborñ z adres†©e
         call      endline                  ; zobrazen° koncovÇ linky
         call      resline                  ; zbytkovÇ ©†dky
         ret

; -----------------------------------------------------------------------------
;                      vypnut° okna (zobrazen° podkladu)
; -----------------------------------------------------------------------------
public   radek40

radek40:                                  ;* zobrazen° podkladu ©†dku 40 znakñ
                                            ; VSTUP: DX=poá†teán° pozice

         test      byte ptr cs:[bp+0],8     ; je okno zobrazeno ?
         stc
         jnz       radek41                  ; okno je zobrazeno
         push      cx
         mov       cl,40
         call      radeknul                 ; zobrazen° podkladu ©†dku okna
         pop       cx
         clc
radek41: ret

; -----------------------------------------------------------------------------
public   radeknul

radeknul:                                 ;* zobrazen° podkladu ©†dku okna
                                            ; VSTUP: DX=poá†teán° pozice
                                            ;        CL=poáet znakñ k zobrazen°

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      ds
         call      mouseoff                 ; vypnut° my®i
         mov       al,cs:[color]
         push      ax
         mov       al,cs:[cisvram]          ; á°slo segmentu s VRAM
         call      getseg                   ; poskytnut° adresy segmentu
         mov       ds,bx                    ; segment s VRAM
         xor       si,si                    ; poá†teán° adresa v segmentu
                                          ;* vòpoáet poá†teán° adresy displeje
         mov       al,cs:[displ]            ; posledn° ©†dek displeje
         call      testakth                 ; je n†povàda aktivn° ?
         jc        radeknl0                 ; n†povàda nen° aktivn°
         dec       al
                                          ;* AL=posledn° povoleò ©†dek
radeknl0:cmp       byte ptr cs:[aktkurz+1],al ; je kurzor na posl. ©†dku ?
         jbe       radeknl1                 ; je maxim†lnà na posledn°m ©†dku
         add       si,2*80                  ; jako prvn° je druhò ©†dek
         inc       al
         jnz       radeknl0
radeknl1:                                 ;* vòpoáet adresy zaá†tku textu
         push      dx                       ; pozice pro zobrazen°
         mov       al,160                   ; poáet znakñ na ©†dek
         mul       dh                       ; p©epoáet ©†dkñ na bajty
         xor       dh,dh                    ; DH <- 0
         add       ax,dx
         add       ax,dx                    ; vòpoáet offsetu ve videopamàti
         add       si,ax                    ; poá†teán° adresa textu
         pop       dx                       ; pozice pro zobrazen°
                                          ;* zobrazen° textu
         xor       ch,ch                    ; CH <- 0
;         cmp       dh,24                    ; je ©†dek mimo ?
;         jbe       radeknl2                 ; nen° je®tà mimo
;         mov       byte ptr cs:[color],7    ; atribut
;         mov       al," "
;         call      outch0                   ; vymaz†n° ©†dku
;         jmp       short radeknl3
;
radeknl2:cmp       si,cs:[delvram]          ; je jië mimo buffer ?
         mov       ax,720h
         jae       radeknl4                 ; je jië mimo buffer
         lodsw                              ; naáten° znaku a atributu
radeknl4:mov       cs:[color],ah            ; uloëen° atributu barvy
         call      outch10                  ; vòstup znaku
         loop      radeknl2                 ; vòstup dal®°ho znaku

radeknl3:call      mouseon                  ; zapnut° my®i
         pop       ax
         mov       cs:[color],al
         pop       ds
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;                   Zobrazen° horn°ho ©†dku okna (1. ©†dek)
; -----------------------------------------------------------------------------
public   topline

topline:                                  ;* zobrazen° 1. ©†dku okna
                                            ; VSTUP: BP=tabulka okna

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      ds
         push      cs
         pop       ds
         call      mouseoff                 ; vypnut° my®i
                                          ;* zobrazen° podkladovÇho ©†dku
         xor       dh,dh                    ; ©†dek pro kreslen° linky
         mov       dl,ds:[bp+3]             ; poá†teán° pozice okna
         xor       bl,bl
         test      byte ptr ds:[bp+0],8     ; je okno zobrazeno ?
         jnz       toplin2                  ; okno je zobrazeno
         test      byte ptr ds:[parint2],1  ; je zobrazen strom ?
         jnz       toplin2                  ; je zobrazen strom
         cmp       dl,40                    ; je pravÇ okno ?
         jb        toplin1                  ; je levÇ okno
         and       byte ptr ds:[parint],7fh ; vypnut° p©°znaku hodin
toplin1: call      radek40                  ; zobrazen° podkladu
         jmp       short toplin5
toplin2:                                  ;* zobrazen° horn°ho ©†dku okna
         mov       al,1                     ; atribut 1
         call      outch1                   ; nastaven° atributu 1
         mov       al,201                   ; levò horn° roh
         call      outch1                   ; zobrazen° znaku rohu
         mov       al,205                   ; rovn† dvojit† á†ra
         mov       cx,38                    ; dÇlka linky
         call      outch                    ; zobrazen° horn° linky
         mov       al,187                   ; pravò horn° roh
         call      outch1                   ; zobrazen° pravÇho horn°ho rohu
                                          ;* nastaven° zobrazen° n†povàd
         cmp       dl,60                    ; je pravÇ okno ?
         jb        toplin3                  ; je levÇ okno
         or        byte ptr ds:[parint],80h ; zapnut° p©°znaku hodin
         mov       byte ptr ds:[citachod],0 ; poëadavek okamëitÇho zobrazen°
         jmp       short toplin4
toplin3:                                  ;* zobrazen° textu n†povàdy
         test      byte ptr ds:[parint2],1  ; je zobrazen° stromu ?
         jnz       toplin4                  ; je zobrazen° stromu
         call      testakth                 ; je n†povàda aktivn° ?
         jnc       toplin4                  ; n†povàda je aktivn°
         mov       dl,1                     ; pozice textu "<F1>=n†povàda"
         lea       si,[texthlp]             ; text "<F1>=n†povàda"
         call      outtxt                   ; zobrazen° textu
         mov       bl,dl                    ; koncov† pozice n†povàdy

toplin4: test      byte ptr ds:[parint2],1  ; je zobrazen strom ?
         jnz       toplin5                  ; je zobrazen strom
         test      byte ptr ds:[conf5],80h  ; zobrazuje se n†và®t° ?
         jz        toplin5                  ; n†và®t° se nezobrazuje
         call      getvol                   ; poskytnut° adresy n†và®t°
         cmp       byte ptr ds:[si],0       ; je n†và®t° disku ?
         je        toplin5                  ; nen° n†và®t° disku
         mov       al,1                     ; norm†ln° text
         call      outch1                   ; nastaven° norm†ln° barvy
         mov       dl,ds:[bp+3]             ; poá†teán° pozice okna
         mov       cl,40                    ; ®°©ka okna
         call      center
         cmp       dl,bl                    ; je za pozic° n†povàdy ?
         jbe       toplin6                  ; je n°zk† pozice
         dec       dl
toplin6: mov       al," "
         call      outch1                   ; lev† mezera
         call      outtxt                   ; zobrazen° n†và®t°
         mov       al," "
         call      outch1                   ; prav† mezera
toplin5:
         call      mouseon                  ; zapnut° my®i
         pop       ds
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   topret,msgcek

topret:                                   ;* n†vrat horn°ho ©†dku
         pushf
         push      bp
         call      getakt
         call      topline
         call      getnakt
         call      topline
         pop       bp
         popf
         ret

msgcek:                                   ;* hl†®en° "ÄEKEJTE !"
         pushf
         push      ax
         push      dx
         push      si
         push      bp
         push      ds
         push      cs
         pop       ds
         test      byte ptr ds:[flags],2    ; jsou obà okna vypnuta ?
         jnz       msgcek2                  ; obà okna jsou vypnuta
         call      mouseoff                 ; vypnut° my®i
         call      getakt                   ; aktivn° okno
         test      byte ptr ds:[parint2],1  ; je zobrazen strom ?
         jnz       msgcek0                  ; je zobrazen strom
         call      msgpoz
         call      testaktw
         jc        msgcek1                  ; aktivn° okno nen° zapnutÇ
         call      getnakt                  ; neaktivn° okno
         call      msgpoz
         call      testaktw
         jc        msgcek1                  ; neaktivn° okno nen° zapnutÇ
msgcek0: mov       dl,34                    ; zobrazen° textu uprost©ed
msgcek1: lea       si,[textcek]             ; text "áekejte"
         xor       dh,dh
         call      outtxt                   ; zobrazen° textu
         call      mouseon                  ; zapnut° my®i
msgcek2: pop       ds
         pop       bp
         pop       si
         pop       dx
         pop       ax
         popf
         ret

                                          ;* vòpoáet pozice pro okno
msgpoz:  mov       dl,ds:[bp+3]             ; poá†teán° pozice okna
         cmp       dl,40
         mov       dl,42
         jb        msgpoz1
         mov       dl,27
msgpoz1: ret

; -----------------------------------------------------------------------------
;                  Zobrazen° informac° o disku (2. ©†dek)
; -----------------------------------------------------------------------------
public   space

space:                                    ;* zobrazen° informac° o disku
                                            ; VSTUP: BP=tabulka okna

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
                                          ;* pokus o zobrazen° podkladu
         mov       dl,ds:[bp+3]             ; poá†teán° pozice okna
         mov       dh,1                     ; ©†dek k tisku
         call      radek40                  ; zobrazen° podkladu
         jnc       space3                   ; podklad zobrazen OK
         call      mouseoff                 ; vypnut° my®i
                                          ;* vyti®tàn° informac° o disku
         call      podklsp                  ; zobrazen° z†kladu ©†dku
         push      dx                       ; £schova pozice k tisku
         mov       cx,2                     ; poáet pokusñ o zkr†cen°
space1:  push      cx                       ; á°taá pokusñ o zkr†cen°
         lea       di,[bufwin]              ; pracovn° buffer oken
         mov       al,2                     ; p©°znak nastaven° zvòraznànÇ barvy
         stosb
         push      di                       ; adresa á°sla volnÇ kapacity
         mov       ax,ds:[bp+19]            ; voln† kapacita disku - LOW
         mov       dx,ds:[bp+21]            ; voln† kapacita disku - HIGH
         call      deknumx                  ; dek¢dov†n° á°sla DX:AX
         pop       si
         call      setvoln                  ; nastaven° textu "bajtñ volnòch"
         lea       si,[textsp23]            ; text "z"
         call      transtxt                 ; uloëen° textu "z"
         mov       ax,ds:[bp+15]            ; celkov† kapacita disku - LOW
         mov       dx,ds:[bp+17]            ; celkov† kapacita disku - HIGH
         call      deknumx                  ; dek¢dov†n° á°sla DX:AX
         pop       cx                       ; á°taá pokusñ o zkr†cen°
         lea       si,[bufwin]              ; text k zobrazen°
         call      lensi                    ; dÇlka textu
         cmp       al,36                    ; je text del®° neë 36 znakñ ?
         jbe       space2                   ; dÇlka staá°
         or        byte ptr ds:[parnum],10h ; z†kaz tisku teáku tis°cñ
         loop      space1                   ; dal®° pokus o dek¢dov†n°
space2:  and       byte ptr ds:[parnum],0efh; povolen° tisku teáky tis°cñ
         pop       dx                       ; n†vrat pozice kurzoru
         inc       dl                       ; zaá†tek textu na druhÇ pozici
         mov       cl,38                    ; ®°©ka volnÇho okna
         call      center                   ; centrov†n° textu
         call      outtxt                   ; tisk textu DS:SI
         call      mouseon                  ; zapnut° my®i
space3:  pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret


public   setvoln

setvoln:                                  ;* nastaven° textu "bajtñ volnòch"
         push      ax
         push      si                       ; adresa á°sla volnÇ kapacity
         lea       si,[textsp1]             ; text "bajt"
         call      transtxt                 ; uloëen° textu "bajt"
         pop       si                       ; adresa á°sla volnÇ kapacity
         push      si                       ; £schova adresy á°sla
;         call      setkonc                  ; nastaven° koncovky "y", "ñ"
         lea       si,[textsp2]             ; text "voln"
         call      transtxt                 ; uloëen° textu "voln"
         pop       si                       ; adresa á°sla
         call      testkonc                 ; test koncovky á°sla
         lea       si,[textsp20]            ; koncovka "ò"
         or        al,al
         jz        setvoln1                 ; je á°slo "1"
         lea       si,[textsp21]            ; koncovka "Ç"
         dec       al                       ; je á°slo 2,3,4 ?
         jz        setvoln1                 ; je koncovka "Ç"
         lea       si,[textsp22]            ; koncovka "òch"
setvoln1:call      transtxt                 ; uloëen° koncovky
         pop       ax
         ret


public   podklsp

podklsp:                                  ;* podklad pro text informac°
                                            ; VSTUP: DX=pozice

         push      ax
         push      cx
         push      dx
         call      mouseoff                 ; vypnut° my®i
         mov       al,1                     ; nastaven° z†kladn° barvy textu
         call      outch1                   ; nastaven° z†kladn° barvy textu
         mov       al,186                   ; dvojit† svisl† á†ra
         call      outch1                   ; zobrazen° levÇ á†ry
         mov       al,32                    ; znak mezery
         mov       cx,38                    ; poáet znakñ k tisku mezery
         call      outch                    ; vymaz†n° ©†dku
         mov       al,186                   ; dvojit† svisl† á†ra
         call      outch1                   ; zobrazen° levÇ á†ry
         call      mouseon                  ; zapnut° my®i
         pop       dx
         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;                 Zobrazen° informac° o adres†©i (3. ©†dek)
; -----------------------------------------------------------------------------
public   directory

directory:                                ;* zobrazen° informac° o adres†©i
                                            ; VSTUP: BP=tabulka okna

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
                                          ;* vykreslen° podkladu ©†dku
         mov       dl,ds:[bp+3]             ; poá†teán° pozice okna
         mov       dh,2                     ; ©†dek k tisku
         call      radek40                  ; zobrazen° podkladu
         jnc       direct2                  ; podklad zobrazen OK
         call      mouseoff                 ; vypnut° my®i
                                          ;* vyti®tàn° informac° o adres†©i
         push      dx                       ; £schova pozice k tisku
         call      podklsp                  ; zobrazen° podkladu
         lea       di,[bufwin]              ; pracovn° buffer
         mov       al,2                     ; p©°znak nastaven° zvòraznànÇ barvy
         stosb
         mov       ax,ds:[bp+23]            ; nië®° slovo poátu souborñ
         mov       dx,0                     ; vy®®° slovo poátu souborñ
         push      di                       ; ukazatel textu á°sla
         or        byte ptr ds:[parnum],1   ; z†kaz tisku teáek
         call      deknum                   ; dek¢dov†n° poátu souborñ
         and       byte ptr ds:[parnum],0feh ; povolen° tisku teáek
         lea       si,[textsp3]             ; text "soubor"
         call      transtxt                 ; uloëen° textu "soubor"
         pop       si                       ; ukazatel textu á°sla
         push      si
         call      setkonc                  ; nastaven° koncovky textu "y", "ñ"
         lea       si,[textsp30]            ; test "zab°r"
         call      transtxt                 ; uloëen° textu "zab°r"
         pop       si                       ; text á°sla
         call      testkonc
         dec       al                       ; je 1=koncovka pro 2,3,4 ?
         lea       si,[textsp31]            ; koncovka '†'
         jnz       direct1                  ; nen° koncovka 2,3,4
         lea       si,[textsp32]            ; koncovka 'aj°'
direct1: call      transtxt                 ; uloëen° koncovky
         mov       ax,ds:[bp+25]            ; nië®° slovo zabranÇ kapacity
         mov       dx,ds:[bp+27]            ; vy®®° slovo zabranÇ kapacity
         push      di                       ; ukazatel á°sla
         call      deknum                   ; dek¢dov†n° zabranÇ kapacity
         lea       si,[textsp4]             ; text "bajt"
         call      transtxt                 ; uloëen° textu "bajt"
         pop       si                       ; ukazatel á°sla
         call      setkonc                  ; nastaven° koncovky "y", "ñ"
         pop       dx                       ; n†vrat pozice kurzoru
         lea       si,[bufwin]              ; tiskovò buffer
         inc       dl                       ; druh† pozice kurzoru
         mov       cl,38                    ; dÇlka prostoru pro tisk
         call      center                   ; centrov†n° textu
         call      outtxt                   ; vyti®tàn° textu
         call      mouseon                  ; zapnut° my®i

direct2: pop       es
         pop       ds
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
public   obrpath

obrpath:                                  ;* zobrazen° cesty adres†©e
                                            ; VSTUP: BP=tabulka okna

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      cs
         pop       ds
                                          ;* zobrazen° podkladu
         mov       dl,ds:[bp+3]             ; poá†teán° pozice okna
         mov       dh,3                     ; ©†dek k tisku
         call      radek40                  ; zobrazen° podkladu
         jc        obrpth01                 ; podklad nezobrazen
         jmp       obrpth3                  ; podklad zobrazen OK

obrpth01:call      mouseoff                 ; vypnut° my®i
                                          ;* vykreslen° podkladovÇ á†ry
         push      dx                       ; £schova poá†teán° pozice kurzoru
         mov       al,1                     ; nastaven° z†kladn° barvy textu
         call      outch1                   ; nastaven° z†kladn° barvy textu
         mov       al,204                   ; lev† á†ra
         call      outch1                   ; zobrazen° levÇ á†ry
         mov       al,205                   ; vodorovn† dvojit† á†ra
         mov       cx,38                    ; dÇlka linky
         call      outch                    ; zobrazen° linky
         mov       al,185                   ; prav† á†ra
         call      outch1                   ; zobrazen° pravÇ á†ry
         pop       dx                       ; n†vrat pozice kurzoru
                                          ;* vykreslen° cesty
         call      testakt                  ; test, zda je okno aktivn°
         mov       al,1                     ; nastaven° norm†ln° barvy
         jnz       obrpth1                  ; nen° to aktivn° okno
         mov       al,3                     ; barva kurzoru pro aktivn° okno
obrpth1: call      outch1                   ; nastaven° barvy kurzoru
                                          ;* sestaven° textu nadpisu
         push      dx
         mov       di,offset bufwin         ; buffer pro okna
         push      di
         mov       si,ds:[bp+4]             ; cesta adres†©e
         call      transtxt                 ; p©enesen° textu cesty
         mov       si,ds:[bp+30]            ; maska souborñ
         cmp       word ptr ds:[si],".*"    ; maska - v®echny soubory ?
         jne       obrpth13                 ; nejsou v®echny soubory
         cmp       byte ptr ds:[si+2],"*"   ; v®echny soubory ?
         je        obrpth11                 ; jsou v®echny soubory
obrpth13:mov       al,"\"                   ; oddàlovaá cesty adres†©e
         cmp       ds:[di-1],al             ; je z†kladn° adres†© ?
         je        obrpth14                 ; je z†kladn° adres†©
         stosb                              ; uloëen° oddàlovaáe
obrpth14:call      transtxt                 ; p©enesen° masky
obrpth11:pop       si
         pop       dx

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
         cmp       cl,34                    ; je text del®° neë 34 znakñ ?
         jna       obrpth2                  ; text nen° del®° neë 34 znakñ
         sub       cl,31                    ; p©ebytek dÇlky ©etàzce
         add       si,cx                    ; zaá†tek ©etàzce
         mov       al,"."                   ; oddàlovac° teáka
         mov       cx,3                     ; poáet znakñ "."
         call      outch                    ; zobrazen° textu "..."
obrpth2: call      outtxt                   ; zobrazen° (zbytku) cesty adres†©e
         mov       al," "                   ; znak oddàlovac° mezery
         call      outch1                   ; zobrazen° mezery
         call      mouseon                  ; zapnut° my®i
obrpth3: pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;                        Zobrazen° souborñ v oknà
; -----------------------------------------------------------------------------
public   files

files:                                      ; zobrazen° souborñ z adres†©e
                                            ; VSTUP: BP=tabulka okna

         push      bx
         push      cx
         mov       bx,cs:[bp+9]             ; á°slo prvn°ho souboru
         call      getnumfw                 ; poskytnut° poátu souborñ v oknà
;         mov       cx,19                    ; poáet ©†dkñ displeje
;         call      testsetw                 ; je plnÇ zobrazen° okna ?
;         jz        files1                   ; je plnÇ zobrazen° okna
;         mov       cl,19*3
files1:  call      zobrfile                 ; zobrazen° souboru
         inc       bx                       ; zvò®en° á°sla souboru
         loop      files1                   ; zobrazen° dal®°ho souboru
         pop       cx
         pop       bx
         ret

; -----------------------------------------------------------------------------
public   zobrfile

zobrfile:                                 ;* zobrazen° poloëky adres†©e
                                            ; VSTUP: BX=á°slo poloëky
                                            ;        BP=adresa parametrñ okna

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
                                          ;* vòpoáet relativn°ho ©†dku
         mov       dl,cs:[bp+3]             ; poá†teán° pozice okna
         mov       ax,bx                    ; soubor k zobrazen°
         sub       ax,cs:[bp+9]             ; zobrazenò soubor relativnà
                                          ;* kontrola á°sla ©†dku
         jb        zobrf0b                  ; je nad prvn°m souborem
         call      getnumfw                 ; poáet zobrazenòch souborñ
         cmp       ax,cx                    ; p©ekroáen posledn° soubor ?
         jae       zobrf0b                  ; p©ekroáen konec seznamu
         call      getnumlw                 ; poáet zobrazenòch ©†dkñ
                                          ;* vòpoáet pozice a ©†dku zobrazen°
zobrf07: cmp       ax,cx                    ; p©ekroáen okraj ?
         jb        zobrf08                  ; nen° p©ekroáen okraj
         sub       ax,cx                    ; sn°ëen° relativn°ho ©†dku
         add       dl,13                    ; zvò®en° pozice na displeji
         jmp       short zobrf07            ; dal®° test
zobrf08: mov       dh,al                    ; ©†dek s kurzorem
         add       dh,4                     ; poá†teán° ©†dek k zobrazen°
                                          ;* zobrazen° podkladu
         test      byte ptr cs:[bp+0],8     ; je okno zobrazeno ?
         jnz       zobrf09                  ; okno je zobrazeno
         push      cx
         mov       cl,40
         call      testsetw                 ; je plnÇ zobrazen° okna ?
         jz        zobrf0a                  ; nen° trojsloupcovÇ zobrazen°
         mov       cl,14
zobrf0a: call      radeknul                 ; zobrazen° podkladu ©†dku okna
         pop       cx
zobrf0b: jmp       short zobrf05            ; podklad zobrazen OK

zobrf09:                                  ;* zobrazen° levÇho okraje
         call      mouseoff                 ; vypnut° my®i
         call      zobrflzl                 ; zobrazen° levÇ znaáky kurzoru
         call      adrpolsi                 ; zji®tàn° adresy souboru v seznamu
         jnc       zobrf02                  ; je platnò soubor
                                          ;* nen° platnò soubor
         call      zobrfil0                 ; zobrazen° pr†zdnÇ ©†dky
         jmp       short zobrf04            ; zobrazen° konce souboru
                                          ;* zobrazen° platnÇho souboru
zobrf02: call      zobrfila                 ; nastaven° barvy ©†dku poloëky
         call      zobrfiln                 ; zobrazen° jmÇna souboru

         call      testsetw                 ; je plnÇ zobrazen° okna ?
         jnz       zobrf04                  ; je trojsloupcovÇ zobrazen°
                                          ;* oddàlovac° á†ra za jmÇnem souboru
         mov       al,179                   ; svisl† á†ra
         test      byte ptr ds:[si],80h     ; je soubor vybranò ?
         jz        zobrf03                  ; soubor nen° vybranò
         mov       al,0b2h                  ; oznaáen° vybranÇho souboru
zobrf03: call      outch1                   ; zobrazen° oddàlovac° á†ry

         test      byte ptr cs:[bp+29],4    ; zobrazuj° se pozn†mky ?
         jz        zobrf032                 ; pozn†mky se nezobrazuj°
         test      byte ptr cs:[bp+29],2
         jz        zobrf032

         call      zobrinf                  ; zobrazen° pozn†mek k souborñm
         jmp       short zobrf04            ; konec zobrazen°

zobrf032:call      zobrfilv                 ; zobrazen° velikosti souboru

         mov       al,179                   ; svisl† á†ra
         call      outch1                   ; zobrazen° oddàlovac° á†ry

         call      zobrfild                 ; zobrazen° data souboru

         mov       al,179                   ; svisl† á†ra
         call      outch1                   ; zobrazen° oddàlovac° á†ry

         call      zobrfilc                 ; zobrazen° áasu souboru
zobrf04: call      zobrflzr                 ; zobrazen° koncovÇ znaáky kurzoru
         call      mouseon                  ; zapnut° my®i
zobrf05: pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret


; -----------------------------------------------------------------------------

public   zobrinf
zobrinf:                                  ;* zobrazen° pozn†mek k souborñm

         push      ax
         push      bx
         push      cx
         push      si
         push      di
         push      es

         call      adrpoldi                 ; adresa souboru ES:DI

         xor       cx,cx
         mov       cl,dl
         add       cl,25                    ; koncov† pozice
         push      cx
         push      ds

         mov       al,cs:[bp+32]            ; á°slo segmentu pozn†mek
         call      getseg                   ; poskytnut° adresy segmentu
         mov       ds,bx                    ; adresa segmentu

         xor       si,si                    ; poá†tek textu pro hled†n°
zobrinf1:                                 ;* porovn†n° jmÇna s kurzorem
         call      cmpfile                  ; porovn†n° specifikac°
         je        zobrinf4                 ; jmÇno je OK - zobrazen°
         inc       si                       ; p©eskoáen° konce ©†dku
                                          ;* nalezen° dal®°ho ©†dku
zobrinf2:call      zobrich                  ; naáten° dal®°ho znaku
         jc        zobrinf6                 ; nen° dal®° znak
         jnz       zobrinf2                 ; nen° konec ©†dku - dal®° znak
         dec       si                       ; n†vrat bajtu 0
         jmp       short zobrinf1           ; test dal®°ho ©†dku
                                          ;* soubor nalezen - zobrazen°
zobrinf4:add       si,13                    ; zaá†tek textu
         mov       cx,25                    ; maxim†ln° poáet znakñ textu
zobrinf5:call      zobrich                  ; naáten° dal®°ho znaku
         jbe       zobrinf6                 ; konec ©†dku nebo textu
         call      outch10                  ; zobrazen° znaku
         loop      zobrinf5                 ; zobrazen° dal®°ho znaku
zobrinf6:
         pop       ds
         pop       cx
         sub       cl,dl                    ; poáet zbylòch znakñ
         mov       al," "
         call      outch

         pop       es
         pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   zobrich
zobrich:                                  ;* naáten° dal®°ho znaku
                                            ; VùSTUP: CY=konec textu
                                            ;         ZY=konec ©†dku

         cmp       si,cs:[bp+33]            ; jsou jië v®echny znaky ?
         cmc
         jc        zobrich2                 ; jsou jië v®echny znaky
         cld
         lodsb
         cmp       al,13                    ; je CR ?
         je        zobrich                  ; ignorov†n° CR
         or        al,al                    ; ZY=je konec ©†dku
zobrich2:ret

; -----------------------------------------------------------------------------
public   zobrflzl

zobrflzl:                                 ;* zobrazen° levÇ znaáky kurzoru
                                            ; VSTUP: DX=pozice na displeji
                                            ;        BP=adresa parametrñ okna
                                            ;        BX=á°slo souboru
                                            ; VùSTUP: DX=nov† pozice na displeji

         push      ax
         mov       al,1                     ; p©°znak norm†ln° barvy
         call      outch1                   ; nastaven° norm†ln° barvy
         cmp       dl,cs:[bp+3]             ; je levò okraj okna ?
         jne       zobrfzl2                 ; nen° levò okraj okna
         mov       al,186                   ; norm†ln° dvojit† á†ra
         call      testsetw                 ; je plnÇ zobrazen° okna ?
         jnz       zobrfzl1                 ; nen° plnÇ zobrazen° okna
         cmp       bx,cs:[bp+11]            ; je soubor s kurzorem ?
         jne       zobrfzl1                 ; nen° soubor s kurzorem
         mov       al,0b0h                  ; znaáka kurzoru
zobrfzl1:call      outch1                   ; zobrazen° oznaáen° kurzoru
         dec       dl
zobrfzl2:inc       dl
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   zobrflzr

zobrflzr:                                 ;* zobrazen° pravÇ znaáky kurzoru
                                            ; VSTUP: DX=pozice na displeji
                                            ;        BP=adresa parametrñ okna
                                            ;        BX=á°slo souboru
                                            ; VùSTUP: DX=nov† pozice na displeji

         push      ax
         call      testsetw                 ; je plnÇ zobrazen° okna ?
         jz        zobrfzr2                 ; je plnÇ zobrazen° okna
         call      adrpolsi                 ; zji®tàn° adresy poloëky
         jc        zobrfzr2                 ; nen° platn† poloëka
         test      byte ptr ds:[si],80h     ; je vybran† poloëka ?
         mov       al,0b2h                  ; oznaáen° vybranÇho souboru
         jnz       zobrfzr1                 ; je vybran† poloëka
zobrfzr2:
         mov       al,1                     ; p©°znak norm†ln° barvy
         call      outch1                   ; nastaven° norm†ln° barvy
         mov       al,186                   ; norm†ln° dvojit† á†ra
         mov       ah,cs:[bp+3]             ; poá†teán° pozice okna
         add       ah,39                    ; pravò okraj
         cmp       dl,ah                    ; je pravò okraj ?
         je        zobrfzr0                 ; je pravò okraj
         mov       al,179                   ; norm†ln° á†ra "≥"
zobrfzr0:call      testsetw                 ; je plnÇ zobrazen° okna ?
         jnz       zobrfzr1                 ; nen° plnÇ zobrazen° okna

         cmp       bx,cs:[bp+11]            ; je soubor s kurzorem ?
         jne       zobrfzr1                 ; nen° soubor s kurzorem
         mov       al,0b0h                  ; znaáka kurzoru
zobrfzr1:call      outch1                   ; zobrazen° oznaáen° kurzoru
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   zobrfil0

zobrfil0:                                 ;* zobrazen° pr†zdnÇ ©†dky souboru
                                            ; VSTUP: DX=pozice na displeji
                                            ;        BP=adresa parametrñ okna
                                            ; VùSTUP: DX=nov† pozice na displeji

         push      ax
         push      cx
         mov       ax,179*256+32            ; jednoduch† svisl† á†ra a mezera
         mov       cx,12                    ; mezera pro jmÇno souboru
         call      outch                    ; zobrazen° mezery pro jmÇno souboru
         call      testsetw                 ; je plnÇ zobrazen° okna ?
         jnz       zobrfl01                 ; je trojsloupcovÇ zobrazen°
         xchg      ah,al                    ; AL <- znak á†ry
         call      outch1                   ; zobrazen° oddàlovac° á†ry
         test      byte ptr cs:[bp+29],2    ; zobrazuj° se pozn†mky ?
         jz        zobrfl00                 ; nezobrazuj° se pozn†mky
         mov       al," "
zobrfl00:xchg      ah,al                    ; AL <- mezera
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
zobrfl01:pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   zobrfila

zobrfila:                                 ;* nastaven° barvy ©†dku souboru
                                            ; VSTUP: DX=pozice na displeji
                                            ;        BX=á°slo souboru
                                            ;        BP=adresa parametrñ okna
                                            ;        DS:SI=poloëka souboru
                                            ; VùSTUP: DX=nov† pozice na displeji

         push      ax
         mov       al,1                     ; norm†ln° barva
         test      byte ptr ds:[si],80h     ; je vybranò soubor ?
         jz        zobrfa1                  ; nen° vybranò soubor
         inc       al                       ; barva vybranÇho souboru
zobrfa1: cmp       bx,cs:[bp+11]            ; je soubor s kurzorem ?
         jne       zobrfa2                  ; nen° soubor s kurzorem
         call      testakt                  ; test, zda je aktivn° okno
         jnz       zobrfa2                  ; nen° to aktivn° okno
         add       al,2                     ; barva kurzoru (inverzn°)
zobrfa2: call      outch1                   ; nastaven° barvy kurzoru
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   zobrfiln

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
         mov       bl,al                    ; atributy (£schova pro jmÇno)
         mov       bh,al                    ; atributy (£schova pro p©°ponu)
                                          ;* zobrazen° jmÇna souboru
         mov       cx,8                     ; dÇlka jmÇna
zobrfn1: lodsb                              ; naáten° znaku jmÇna
         test      bl,10h                   ; je disk ?
         jnz       zobrfn3                  ; je adres†©
         test      bl,6                     ; je skrytò nebo systÇmovò ?
         jnz       zobrfn2                  ; je skrytò nebo systÇmovò
         call      lowcase0                 ; p©evod na malÇ p°smeno
zobrfn2: and       bl,not 6                 ; nulov†n° atrib. skryt. a syst. s.
zobrfn3: call      outch1                   ; zobrazen° znaku jmÇna
         loop      zobrfn1                  ; zobrazen° dal®°ho znaku jmÇna
                                          ;* zobrazen° oddàlovac°ho znaku
         mov       al," "                   ; oddàlovac° mezera
         test      bh,1                     ; je z†kaz z†pisu ?
         jz        zobrfn4                  ; nen° z†kaz z†pisu
ifdef    upver
         mov       al,"*"                   ; oznaáen° souboru R/O
else
         mov       al,177                   ; oznaáen° souboru R/O
endif
zobrfn4: test      bh,6                     ; je skrytò nebo systÇmovò soubor ?
         jz        zobrfn5                  ; nen° skrytò ani systÇmovò soubor
         mov       al,176                   ; oznaáen° souboru SYS nebo HID
zobrfn5: call      outch1                   ; zobrazen° oddàlovac°ho znaku
                                          ;* zobrazen° p©°pony souboru
         mov       cx,3                     ; dÇlka p©°pony soubour
zobrfn6: lodsb                              ; naáten° znaku p©°pony souboru
         test      bh,10h                   ; je adres†© nebo disk ?
         jnz       zobrfn7                  ; je adres†© - jsou velk† p°smena
         call      lowcase0                 ; p©evod na malÇ p°smeno
zobrfn7: call      outch1                   ; zobrazen° znaku p©°pony
         loop      zobrfn6                  ; zobrazen° dal®°ho znaku jmÇna
         pop       si
         pop       cx
         pop       bx                       ; n†vrat á°sla souboru
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   zobrfilv

zobrfilv:                                 ;* zobrazen° velikosti souboru
                                            ; VSTUP: DX=pozice na displeji
                                            ;        DS:SI=poloëka souboru
                                            ;        BP=adresa parametrñ okna
                                            ; VùSTUP: DX=nov† pozice na displeji

         push      ax
         push      bx                       ; £schova á°sla souboru
         push      cx
         push      si
         push      ds
         test      byte ptr ds:[si],10h     ; je podadres†© ?
         jz        zobrfv2                  ; nen° podadres†©
                                          ;* zobrazen° textu adres†©e
         cmp       word ptr ds:[si+1],".."  ; je oznaáen° nad©azenÇho podadres.?
         lea       si,[txtsubd]             ; text podadres†©e "<POD--ADR>"
         jne       zobrfv1                  ; nen° adres†© ".."
         lea       si,[txtupd]              ; text podadres†©e "<NAD--ADR>"
zobrfv1: push      cs
         pop       ds
         call      outtxt                   ; zobrazen° oznaáen° adres†©e, disku
         jmp       short zobrfv3
zobrfv2:                                  ;* zobrazen° velikosti souboru
         mov       ax,ds:[si+12]            ; AX <- nië®° slovo velikosti
         mov       bx,ds:[si+14]            ; vy®®° slovo velikosti souboru
         call      tisknm0                  ; tisk á°sla velikosti (10 á°slic)
zobrfv3: pop       ds
         pop       si
         pop       cx
         pop       bx                       ; n†vrat á°sla souboru
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   zobrfild,zobrfd0

zobrfild:                                 ;* zobrazen° data souboru
                                            ; VSTUP: DX=pozice na displeji
                                            ;        DS:SI=poloëka souboru
                                            ;        BP=adresa parametrñ okna
                                            ; VùSTUP: DX=nov† pozice na displeji

         push      ax
         mov       ax,ds:[si+16]            ; datum souboru
         call      zobrfd0
         pop       ax
         ret

zobrfd0: push      cx
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
zobrfd1: sub       ax,100                   ; korekce - odeáten° 100
         jns       zobrfd1                  ; je á°slo vàt®° neë 100
         add       ax,100                   ; n†vrat á°sla roku
         call      tisknm20                 ; zobrazen° roku
         pop       cx
         ret

; -----------------------------------------------------------------------------
public   zobrfilc

zobrfilc:                                 ;* zobrazen° áasu souboru
                                            ; VSTUP: DX=pozice na displeji
                                            ;        DS:SI=poloëka souboru
                                            ;        BP=adresa parametrñ okna
                                            ; VùSTUP: DX=nov† pozice na displeji

         push      ax
         push      cx
         push      si
         mov       cl,2                     ; maska atributñ pro levÇ okno
         cmp       bp,offset tabl           ; je levÇ okno ?
         je        zobrfc0                  ; je levÇ okno
         mov       cl,4                     ; maska atributñ pro pravÇ okno
zobrfc0: test      cs:[conf2],cl            ; zobrazuj° se atributy ?
         jz        zobrfc1                  ; zobrazuje se áas souboru
                                          ;* zobrazen° atributñ poloëek
         mov       cl,ds:[si]               ; bajt atributñ
         mov       al,"A"
         call      zobrfatr                 ; bit 5 (ARC)
         mov       al,"D"
         call      zobrfatr                 ; bit 4 (DIR)
         add       cl,cl
         mov       al,"S"
         call      zobrfatr                 ; bit 2 (SYS)
         mov       al,"H"
         call      zobrfatr                 ; bit 1 (HID)
         mov       al,"R"
         call      zobrfatr                 ; bit 0 (R/O)
         jmp       short zobrfc2

zobrfc1:                                  ;* zobrazen° áasu souboru
         mov       ax,ds:[si+18]            ; áas souboru
         push      ax                       ; £schova áasu souboru
         mov       cl,11                    ; poáet rotac°
         shr       ax,cl                    ; AX >> hodina
         and       al,1fh                   ; maska pro hodinu
         call      tisknm2s                 ; zobrazen° hodiny
         mov       al,":"                   ; oddàlovac° znak
         call      outch1                   ; zobrazen° oddàlovac° teáky
         pop       ax                       ; n†vrat áasu souboru
         mov       cl,5                     ; poáet rotac°
         shr       ax,cl                    ; AX >> minuta
         and       al,3fh                   ; maska pro minutu
         call      tisknm20                 ; zobrazen° minuty
zobrfc2: pop       si
         pop       cx
         pop       ax
         ret

zobrfatr:test      cl,20h                   ; je atribut nastaven ?
         jnz       zobrfat1                 ; je nastaven
         mov       al,"."                   ; n†hradn° znak
zobrfat1:call      outch1
         add       cl,cl                    ; rotace CL vlevo
         ret

; -----------------------------------------------------------------------------
;                  Zobrazen° posledn°ho ©†dku okna
; -----------------------------------------------------------------------------
public   endline

endline:                                  ;* zobrazen° koncovÇ linky
                                            ; VSTUP: BP=adresa parametrñ okna

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

         mov       dl,ds:[bp+3]             ; poá†teán° pozice okna
         call      getendlw                 ; á°slo posledn°ho ©†dku okna
         call      radek40                  ; zobrazen° podkladu
         jnc       endlin3                  ; podklad zobrazen OK
                                          ;* zobrazen° podkladovÇ linky
         call      mouseoff                 ; vypnut° my®i
         mov       al,1
         call      outch1                   ; nastaven° z†kladn° barvy
         mov       al,200                   ; levò doln° roh
         call      outch1                   ; zobrazen° levÇho doln°ho rohu

         test      byte ptr ds:[conf6],4    ; je aktivn° SCROOL LOCK ?
         jz        endlin1                  ; SCROLL LOCK nen° aktivn°
         mov       al,2                     ; vysv°cenò text
         call      outch1                   ; nastaven° vysv°cenÇho textu

endlin1:                                  ;* zobrazen° podkladu
         push      dx                       ; £schova poá†teán° pozice
         mov       al,205                   ; rovn† dvojit† á†ra
         mov       cx,38                    ; dÇlka linky
         call      outch                    ; zobrazen° horn° linky
         mov       al,1                     ; norm†ln° text
         call      outch1                   ; nastaven° norm†ln° barvy textu
         mov       al,188                   ; pravò doln° roh
         call      outch1                   ; zobrazen° pravÇho doln°ho rohu
         pop       dx
         test      byte ptr ds:[conf6],4    ; je aktivn° SCROOL LOCK ?
         jz        endlin0                  ; SCROLL LOCK nen° aktivn°

         mov       al,ds:[col3]             ; negovanò text
         or        al,80h                   ; blikaj°c° text
         mov       ds:[color],al            ; nastaven° barvy textu
;         mov       al,3                     ; barva kurzoru
;         call      outch1                   ; nastaven° barvy kurzoru
         add       dl,18                    ; pozice doprost©ed
         mov       al,18                    ; ®ipky
         call      outch10                  ; zobrazen° ®ipek
         jmp       short endlin4

endlin0:                                  ;* zobrazen° rychlÇho vyhled†v†n°
         cmp       byte ptr ds:[numsrc],0   ; je nàjakò znak v bufferu ?
         je        endlin2                  ; nen° ë†dnò znak v bufferu
         test      byte ptr ds:[parint2],1  ; je zobrazen° stromu ?
         jnz       endlin2                  ; je zobrazen° stromu
         add       dl,13                    ; poá†tek pro zobrazen°
         call      endlinq                  ; zobrazen° rychlÇho vyhled†v†n°
         jmp       short endlin4
endlin2:
         call      zobsellin                ; zobrazen° vybranòch souborñ
endlin4: call      mouseon                  ; zapnut° my®i
endlin3:
         pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret


public   endlinq

endlinq:                                  ;* zobrazen° rychlÇho vyhled†v†n°
                                            ; VSTUP: DX=pozice pro zobrazen°

         mov       al,2
         call      outch1                   ; barva - zvòraznànò text
         mov       al," "
         call      outch1                   ; poá†teán° mezera
         push      dx                       ; £schova poá†teán° pozice
         lea       si,[bufsrc]              ; buffer textu
         xor       bl,bl                    ; á°taá znakñ
         mov       cx,8                     ; poáet znakñ jmÇna = 8
         call      zobquick                 ; zobrazen° jmÇna souboru
         mov       al,"."                   ; oddàlovaá p©°pony
         cmp       bl,ds:[numsrc]           ; je jië konec textu ?
         jbe       endlinq1                 ; kurzor je v p©°ponà
         mov       al," "                   ; n†hradn° oddàlovaá
endlinq1:call      outch1                   ; oddàlovac° mezera
         mov       cl,3                     ; poáet znakñ p©°pony = 3
         call      zobquick                 ; zobrazen° p©°pony
         mov       al," "                   ; koncov† mezera
         call      outch1                   ; zobrazen° koncovÇ mezery
         pop       dx                       ; poá†teán° pozice textu
         add       dl,ds:[numsrc]           ; pozice kurzoru
         cmp       byte ptr ds:[numsrc],8   ; je jië p©°pona ?
         jb        endlinq2                 ; nen° p©°pona
         inc       dl                       ; p©eskoáen° oddàlovaáe p©°pony
endlinq2:xor       al,al
         call      outch1                   ; nastaven° pozice kurzoru
         ret


zobquick:                                 ;* zobrazen° textu vyhled†n°

zobquic1:mov       al," "                   ; n†hradn° znak mezery
         inc       bl                       ; zvò®en° á°taáe znakñ
         cmp       bl,ds:[numsrc]           ; je jië konec textu ?
         ja        zobquic2                 ; je za koncem textu
         lodsb                              ; znak k zobrazen°
         call      lowcase                  ; p©evod na malÇ p°smeno
zobquic2:call      outch1                   ; zobrazen° znaku
         loop      zobquic1                 ; dal®° znak
         ret


zobsellin:                                ;* zobrazen° informac° o vòbàru
                                            ; VSTUP: poá†teán° pozice ©†dku

         push      dx
         lea       di,[bufwin]              ; tiskovò buffer
         mov       ax," "*256+2             ; £vodn° znaky
         stosw
         call      soucins                  ; seáten° oznaáenòch souborñ
         or        cx,cx                    ; je nàjakò soubor ?
         jnz       endlin8                  ; je nàjakò soubor
         pop       dx
;         call      zob3file                 ; zobrazen° souboru u 3-sl. okna
         ret
                                          ;* dek¢dov†n° obsazenÇ kapacity
                                            ; VSTUP: CX=poáet souborñ
                                            ;        DX:AX=souáet kapacit

endlin8: push      cx                       ; £schova poátu souborñ
         push      di                       ; £schova zaá†tku á°sla
         call      deknum                   ; dek¢dov†n° á°sla
         lea       si,[textvy1]             ; text "bajt"
         call      transtxt                 ; uloëen° textu "bajt"
         pop       si
         call      setkonc                  ; nastaven° koncovky "y", "ñ"
         pop       ax                       ; poáet souborñ

         push      ax                       ; poáet souborñ
         lea       si,[textvy13]            ; ukonáen° textu ' v '
         cmp       ax,2
         jb        endlin6
         cmp       ax,4                     ; je vàt®° neë 4 ?
         jbe       endlin5                  ; je men®° neë 5
         cmp       ax,12
         jb        endlin6
         cmp       ax,14
         jbe       endlin5
         cmp       ax,20
         jb        endlin6
         cmp       ax,49
         jbe       endlin5
         cmp       ax,100
         jb        endlin6
         cmp       ax,499
         ja        endlin6
endlin5: lea       si,[textvy14]            ; ukonáen° textu ' ve '
endlin6: call      transtxt                 ; uloëen° textu ' v ', 've'
         pop       ax                       ; n†vrat poátu souborñ
                                          ;* dek¢dov†n° poátu souborñ
         xor       dx,dx                    ; vy®®° slovo á°sla
         push      di                       ; ukazatel na á°slo
         call      deknum5                  ; dek¢dov†n° poátu souborñ
         lea       si,[textvy2]             ; text "soubor"
         call      transtxt                 ; uloëen° textu "soubor"
         pop       si                       ; ukazatel na á°slo
         call      testkonc                 ; test koncovky á°sla
         lea       si,[textvy21]            ; koncovka pro á°slo "1"
         or        al,al                    ; je koncovka pro "1" ?
         jz        endlin7                  ; je koncovka pro "1"
         lea       si,[textvy22]            ; koncovka pro ostatn° á°sla
endlin7: call      transtxt                 ; uloëen° koncovky
                                          ;* tisk informac° o vòbàru souborñ
endlina: pop       dx                       ; n†vrat poá†teán° pozice
         lea       si,[bufwin]              ; pracovn° buffer s textem
         mov       cl,38                    ; ®°©ka prostoru k tisku
         call      center                   ; centrov†n° textu
         call      outtxt                   ; tisk textu
endlinb: ret

;zob3file:                                 ;* zobrazen° ©†dku pro 3-sl. okno
;                                            ; VSTUP: DX=pozice
;
;         call      testsetw                 ; je plnÇ zobrazen° okna ?
;         jz        endlinb                  ; nen° trojsloupcovÇ zobrazen°
;         call      getkurz                  ; poskytnut° adresy kurzoru
;         jc        endlinb                  ; nen° ë†dnò soubor
;         add       dl,5
;         mov       al,"π"
;         call      outch1
;         call      zobrfilv                 ; zobrazen° velikosti souboru
;         mov       al,179                   ; svisl† á†ra
;         call      outch1                   ; zobrazen° oddàlovac° á†ry
;         call      zobrfild                 ; zobrazen° data souboru
;         mov       al,179                   ; svisl† á†ra
;         call      outch1                   ; zobrazen° oddàlovac° á†ry
;         call      zobrfilc                 ; zobrazen° áasu souboru
;         mov       al,"Ã"
;         call      outch1
;         ret

; -----------------------------------------------------------------------------
;                         ZbytkovÇ ©†dky
; -----------------------------------------------------------------------------
public   resline

resline:                                  ;* zobrazen° zbytkovòch ©†dkñ

         push      ax
         push      cx
         push      dx
         push      ds
         push      es

         push      cs
         pop       ds
         push      cs
         pop       es

         mov       dl,ds:[bp+3]             ; poá†teán° pozice okna
         call      getendl                  ; maxim†ln° ©†dek okna
         mov       al,dh                    ; maxim†ln° ©†dek okna
         call      getendlw                 ; á°slo posledn°ho ©†dku okna
         sub       al,dh                    ; poáet zbylòch ©†dkñ
         jbe       resline9                 ; nezbòv† ë†dnò ©†dek
         xor       cx,cx
         mov       cl,al                    ; poáet zbylòch ©†dkñ
resline4:
         inc       dh                       ; zvò®en° á°sla ©†dku
         push      cx
         mov       cl,40
         call      radeknul                 ; zobrazen° podkladu ©†dku okna
         pop       cx
         loop      resline4                 ; dal®° ©†dek

resline9:
         pop       es
         pop       ds
         pop       dx
         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;                         Zapnut° kurzoru
; -----------------------------------------------------------------------------
public   kurzon

kurzon:                                   ;* zapnut° kurzoru

         push      bx
         mov       bx,cs:[bp+11]            ; soubor s kurzorem
         call      zobrfile                 ; zobrazen° souboru
         pop       bx
         ret

; -----------------------------------------------------------------------------
;                           Vypnut° kurzoru
; -----------------------------------------------------------------------------
public   kurzoff

kurzoff:                                  ;* vypnut° kurzoru

         push      bx
         mov       bx,-1                    ; nov† pozice pro zru®en° kurzoru
         xchg      bx,cs:[bp+11]            ; soubor s kurzorem
         call      zobrfile                 ; zobrazen° souboru
         mov       cs:[bp+11],bx            ; n†vrat á°sla kurzoru
         pop       bx
         ret

; -----------------------------------------------------------------------------
;                 Poskytnut° adresy souboru s kurzorem
; -----------------------------------------------------------------------------
public   getkurz

getkurz:                                  ;* poskytnut° adresy s kurzorem
                                            ; VùSTUP: DS:SI

         push      bx
         mov       bx,cs:[bp+11]            ; á°slo souboru s kurzorem
         call      adrpolsi                 ; poskytnut° adresy souboru
         pop       bx
         ret

; -----------------------------------------------------------------------------
public   getatrib0

getatrib0:                                ;* poskytnut° atributñ kurzoru
                                            ; VùSTUP: BL=atributy
         mov       bx,cs:[bp+11]            ; á°slo souboru s kurzorem


public   getatrib

getatrib:                                 ;* poskytnut° atributñ poloëky
                                            ; VSTUP: BX=á°slo poloëky
                                            ; VùSTUP: BL=atributy
         push      si
         push      ds
         call      adrpolsi                 ; poskytnut° adresy souboru
         mov       bl,ds:[si]               ; atributy
         pop       ds
         pop       si
         ret

; -----------------------------------------------------------------------------
public   getvol
getvol:                                   ;* poskytnut° adresy n†và®t° SI
         mov       si,offset voll           ; n†và®t° levÇho okna
         cmp       bp,offset tabl           ; je to levÇ okno ?
         je        getvol2                  ; je levÇ okno
         mov       si,offset volr           ; n†và®t° pravÇho okna
getvol2: ret

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
         call      getakt
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
windret7:;call      getakt
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



code     ends

         end

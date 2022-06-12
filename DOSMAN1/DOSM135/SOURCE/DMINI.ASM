
; ##############################################################################
; #                                                                            #
; #                          D O S   M a n a ë e r                             #
; #                 program pro operace se soubory a s disky                   #
; #                                                                            #
; #                  >>> Autor: ing. Miroslav Nàmeáek <<<                      #
; #                                                                 verze 1.00 #
; ##############################################################################

;keystd   equ       ""                       ; zapnut° standardn° kl†vesnice
;biosdrv  equ       ""                       ; ovladaá displeje BIOS
;debug    equ       ""                       ; je odlaÉov†n°

; *****************************************************************************
;
;                    óvodn° a inicializaán° á†st programu
;
; *****************************************************************************
public   strt,konecprg,adrini,datarez,parbreak

extrn    main:near,verze:word,errver:byte,endshell:word,topseg:word,segend:word
extrn    zasob:word,errmem:byte,inidata:byte,datseg:word
extrn    pathhom1:byte,pathhome:byte,outch1:near
extrn    highcase:near,loadpath:near,old08:dword,old09:dword,old10:dword
extrn    aktpage:byte,typdisp:byte,old1b:dword
extrn    normat:byte,segvram:word,aktkurz:word
extrn    adrvram:word,outch02:near,setout:near,outch01:near
extrn    flags:byte,flagsl:byte,flagsr:byte,tabl:byte,tabr:byte
extrn    adrtabl:word,adrtabr:word,pozwl:byte,pozwr:byte,pozl:byte,pozr:byte
extrn    pathl:byte,adrpathl:word,pathr:byte,adrpathr:word
extrn    createseg:near,cissegl:byte,cissegr:byte
extrn    getakt:near,getnakt:near,loadpath:near
extrn    comlin:byte,buftxt:byte,sellin:byte,selbuf:byte,keystat:byte
extrn    color:byte,aktdir:near,path:byte,transtxt:near
extrn    zacmaz:byte,konecmaz:byte,inidend:byte,int08:near
extrn    int09:near,int10:near,int21:near,old21:dword,cisvram:byte
extrn    outch10:near,namel:byte,namer:byte,adrpolsi:near
extrn    firstwl:word,firstwr:word,old24:dword,int24:near
extrn    countryh:dword,outbuf:byte,col1:byte,colbw:byte
extrn    prevcs:byte,zactxt:byte,konectxt:byte,konvfnt:near
extrn    config:byte,errcard:byte,skokax:near,poclin:word
extrn    execute:near,keyf102:near,windret:near,licence:dword
extrn    flags0l:byte,flags0r:byte,testaktw:near
extrn    hlpuse:byte,soubuse:byte,zacmazr:byte,modiseg:near,getseg:near
extrn    soubcol:byte,helpbuf:byte,colcol:byte,coldisp:byte
extrn    getkurz:near,conf2:byte,prodldem:near,setwl:byte,setwr:byte
extrn    setwls:byte,setwrs:byte,mouseon:near,mouseoff:near,mouseget:near
extrn    mousepoz:word,mainout:near,displ:byte,egaget:near,egaset:near
extrn    egaask:near,getdispcx:near,radeknul:near,delvram:word
extrn    conf3:byte,bufcomm:word,bufcomm1:byte,bufcomm2:byte,topseged:word
extrn    inpkey:near,outbuf3:byte,outbuf4:byte,buffedi2:byte
extrn    adrmaskl:word,maskl:byte,adrmaskr:word,maskr:byte
extrn    conf6:byte,displw:byte,dark:word,darkcit:word
extrn    testkey:near,vyzvycom:byte,soundoff:near,vyzvacit:byte
extrn    conf5:byte,conf7:byte,zachis:byte,konhis:byte,soubhis:byte

code     segment   public
         assume    cs:code,ds:code
         org       100h                     ; poá†teán° adresa COM

zacident label     byte                     ; zaá†tek identifikace programu

strt:    jmp       initstart                ; prvn° start programu

konecprg dw        offset zacmaz            ; konec programu

adrini   dw        offset inidata           ; adresa inicializaán°ch dat

; -----------------------------------------------------------------------------
;                      start programu - rezidentn° modul
; -----------------------------------------------------------------------------
public   execx

execx:                                    ;* start p©°kazu operaán°ho systÇmu
                                            ; VSTUP: [80h]: p©°kaz pro system

         push      cs
         pop       ds                       ; DS <- CS
         push      cs
         pop       es                       ; ES <- CS
                                          ;* nastaven° pomocnÇho z†sobn°ku
         cli
         mov       cx,cs
         mov       ss,cx
         lea       cx,[zasobrez]            ; z†sobn°k pro rezidentn° modul
         mov       sp,cx
         sti
                                          ;* pokud nen° p©°kaz, konec programu
         cmp       byte ptr cs:[80h],0      ; je p©°kazovò ©†dek ?
         jne       execx1                   ; je nàco v p©°kazovÇm ©†dku
execx0:
         push      ax
         mov       ax,2523h
         lds       dx,cs:[old23]
         int       21h                      ; n†vrat p©eru®en° CTRL-BREAK
         mov       ax,2522h
         lds       dx,[old22]
         int       21h                      ; n†vrat obsluhy INT 22h
         pop       ax
         mov       ah,4ch                   ; funkce ukonáen° programu
         int       21h                      ; ukonáen° programu

execx1:                                   ;* zmen®en° p©idàlenÇ pamàti
         test      byte ptr cs:[parrez],1   ; je rezidentn° reëim ?
         jnz       execx13                  ; je rezidentn° reëim
         lea       bx,[inidend]             ; konec rezidentn°ch dat
         sub       bx,offset inidata        ; dÇlka rezidentn°ch dat
         add       bx,offset datarez        ; konec rezidentn°ch dat
         add       bx,15                    ; zaokrouhlen°
         shr       bx,1
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; p©epoáet na odstavce
         mov       ah,4ah
         int       21h                      ; modifikace pamàti
         jnc       execx13                  ; blok pamàti OK
execx82: jmp       execx8                   ; chyba - zniáen blok pamàti
                                          ;* nalezen° specifikace cesty
execx13: push      cs
         pop       es
         mov       ax,cs:[2ch]              ; adresa prost©ed°
         mov       ds,ax                    ; segment prost©ed°
         xor       si,si                    ; ukazatel cesty
execx5:  lea       di,[comspec]             ; ukazatel reference COMSPEC
         cmp       byte ptr ds:[si],0       ; je jië konec prost©ed° ?
         je        execx82                  ; konec prost©ed° - chyba
         mov       cx,8                     ; poáet znakñ k porovn†n°
execx51: lodsb
         cmp       al,"a"                   ; je znak men®° neë "a" ?
         jb        execx52                  ; nen° malÇ p°smeno
         cmp       al,"z"                   ; je znak vàt®° neë "z" ?
         ja        execx52                  ; nen° malÇ p°smeno
         sub       al,32                    ; korekce na velkÇ p°smeno
execx52: scasb                              ; porovn†n° s referenán°m znakem
         jne       execx53                  ; nen° spr†vnò ©etàzec
         loop      execx51                  ; dal®° znak ©etàzce
         mov       dx,si                    ; adresa ©etàzce
         jmp       short execx6             ; proveden° p©°kazu
execx53:                                  ;* nalezen° konce ©etàzce
         cmp       byte ptr ds:[si-1],0     ; byl konec ©etàzce ?
         je        execx5                   ; dal®° ©etàzec
         inc       si
         jmp       short execx53

execx6:                                   ;* nastaven° adres parametrñ EXEC
         push      ds
         push      dx
         push      cs
         pop       ds
;         mov       ax,2522h
;         lea       dx,[int22]
;         int       21h                      ; nastaven° obsluhy INT 22h
;
         mov       ax,2523h
         lea       dx,[int23]
;         lds       dx,cs:[old23]
         int       21h                      ; n†vrat p©eru®en° CTRL-BREAK

         pop       dx
         pop       ds

         lea       bx,[paramexec]           ; parametry EXEC
         mov       word ptr cs:[bx],ds      ; adresa prost©ed° pro podproces
         mov       word ptr cs:[bx+2],80h   ; offset p©°kazovÇho ©†dku
         mov       word ptr cs:[bx+4],cs    ; segment p©°kazovÇho ©†dku
         mov       word ptr cs:[bx+6],5ch   ; offset prvn°ho FCB
         mov       word ptr cs:[bx+8],cs    ; segment prvn°ho FCB
         mov       word ptr cs:[bx+10],6ch  ; offset druhÇho FCB
         mov       word ptr cs:[bx+12],cs   ; segment druhÇho FCB
                                          ;* proveden° p©°kazu
         test      byte ptr cs:[conf2e],1   ; je prov†dàn° p©°kazu s INT 2Eh
ifndef   demo
         jz        execx62                  ; nen° prov†dàn° s INT 2Eh
;         jmp       execx2e                  ; proveden° p©°kazu s INT 2Eh
execx62: mov       ax,4b00h
         int       21h
         pushf
         add       al,"0"
         mov       cs:[errcomm1],al
         popf
endif

execx63: cli
         mov       cx,cs
         mov       ss,cx
         lea       cx,[zasobrez]            ; z†sobn°k pro rezidentn° modul
         mov       sp,cx
         sti
         push      cs
         pop       ds
         pushf
         mov       ax,2524h
         lea       dx,[intx24]              ; p©echodn† obsluha INT 24h
         int       21h
         mov       ax,2523h
         lea       dx,[int23]
         int       21h                      ; nastaven° obsluhy INT 23h
         popf

         jnc       execx9                   ; operace provedena OK
execx8:                                   ;* program COMMAND.COM nespustitelnò
         push      cs
         pop       ds
         lea       dx,[errcomm]             ; chyba "COMMAND.COM nespustitelnò"
         mov       ah,9
         int       21h                      ; zobrazen° chyby
         call      exexchg                  ; dotaz na dal®° postup
         jc        execx9                   ; p©eru®en° operace
         jmp       execx13                  ; opakov†n° pokusu
                                          ;* n†vrat do programu DOSMAN
execx9:  push      cs
         pop       ds
         push      cs
         pop       es
         cld
         mov       byte ptr ds:[80h],0      ; zru®en° p©°kazovÇho ©†dku
         test      byte ptr ds:[parrez],1   ; je rezidentn° reëim ?
         je        execxa                   ; nen° rezidentn° reëim
         jmp       init                     ; inicializace programu
execxa:                                   ;* sestaven° cesty k programu DOSMAN
         mov       di,81h                   ; buffer pro uloëen° jmÇna programu
         push      di
         mov       si,offset pathhom1       ; cesta k dom†c°mu adres†©i
         sub       si,offset inidata        ; zaá†tek inic. dat
         add       si,offset datarez        ; p©epoáet na data v pamàti
execx3:  lodsb
         stosb
         or        al,al
         jnz       execx3                   ; p©enos textu cesty
         dec       di                       ; n†vrat konce ©etàzce
         mov       al,"\"
         cmp       byte ptr es:[di-1],al    ; je posledn° znak "\" ?
         je        execx4                   ; posledn° znak je jië "\"
         stosb                              ; oddàlovaá cesty a jmÇna programu
execx4:  lea       si,[identnm]             ; jmÇno programu
;         mov       cx,11
;         rep       movsb                    ; p©enesen° jmÇna programu
execx42: lodsb
         stosb
         or        al,al
         jnz       execx42                  ; p©enesen° jmÇna programu
         pop       dx                       ; jmÇno programu DOSMAN
                                          ;* vyvol†n° programu DOSMAN
         lea       bx,[paramexec]           ; parametry EXEC
         mov       ax,4b00h
         int       21h
         pushf
         push      cs
         pop       ds
         add       al,"0"
         mov       ds:[errdosm1],al
         mov       ax,2524h
         lea       dx,[intx24]              ; p©echodn† obsluha INT 24h
         int       21h
         popf
         jc        execx2                   ; chyba
         xor       al,al
         jmp       short execx23
execx2:                                   ;* chyba
         push      cs
         pop       ds
         push      ax
         lea       dx,[errdosm]             ; hl†®en° "Nen° moënò DOSMAN"
         mov       ah,9
         int       21h                      ; zobrazen° chyby
         call      exexchg                  ; dotaz na dal®° postup
         pop       ax
         jnc       execx9                   ; opakov†n° operace
execx23: jmp       execx                    ; dal®° p©°kaz

;public   execx2e
;execx2e:                                  ;* proveden° p©°kazu s INT 2Eh
;         push      cs
;         pop       ds
 ;        push      cs
;         pop       es
;         mov       cl,ds:[80h]              ; dÇlka textu
;         sub       cl,2                     ; skuteán† dÇlka p©°kazu
;         jc        execx2e5
;         xor       ch,ch
;         mov       ds:[80h],cl              ; skuteán† dÇlka textu
;         mov       di,81h
;         mov       si,83h
;         cld
;         rep       movsb
;         mov       al,0dh
;         stosb
;         mov       si,80h
;         int       2eh
;int22:
;execx2e5:clc
;         jmp       execx63                  ; n†vrat do programu


public   intx24

intx24:                                   ;* p©echodn† obsluha INT 24h
         xor       al,al                    ; p©°znak ignorov†n° chyby
         iret                               ; n†vrat z obsluhy


public   int23

int23:                                    ;* uëivatelskÇ p©eru®en° CTRL-BREAK
                                          ;* je zde takÇ obsluha INT 1Bh

         or        byte ptr cs:[parrez],80h ; p©°znak p©eru®en° operace
         iret

public   exexchg
exexchg:                                  ;* poëadavek dal®° operace
                                            ; VùSTUP: CY=p©eru®en°
         push      ax
         push      dx
         mov       ah,9
         lea       dx,[errxchg]             ; poëadavek dal®° operace
         int       21h                      ; zobrazen° zpr†vy
         sti
exexchg2:xor       ah,ah
         int       16h                      ; vstup znaku z kl†vesnice
         cmp       al,13                    ; je <Enter> ?
         je        exexchg3                 ; je <Enter>=opakov†n° operace
         cmp       al,27                    ; je <Esc> ?
         jne       exexchg2                 ; nen° <Esc> = novò vstup
         stc                                ; p©°znak p©eru®en° operace
exexchg3:pop       dx
         pop       ax
         ret

IFDEF    slov
errcomm  db        'Subor COMMAND.COM nieje mozne zaviest do pamati ! (chyba '
konident label     byte                     ; konec identifikace programu
errcomm1 db        '0)',13,10,'$'
errdosm  db        'Nieje mozny navrat do programu DOS Manazer ! (chyba '
errdosm1 db        '0)',13,10,'$'
errxchg  db        'Stlacte <Enter>=novy pokus, <Esc>=prerusenie.',13,10,'$'
comspec  db        'COMSPEC='               ; specifikace COMSPEC
ELSE
errcomm  db        'Soubor COMMAND.COM neni mozne zavest do pameti ! (chyba '
konident label     byte                     ; konec identifikace programu
errcomm1 db        '0)',13,10,'$'
errdosm  db        'Neni mozny navrat do programu DOS Manazer ! (chyba '
errdosm1 db        '0)',13,10,'$'
errxchg  db        'Stisknete <Enter>=novy pokus, <Esc>=preruseni.',13,10,'$'
comspec  db        'COMSPEC='               ; specifikace COMSPEC
ENDIF

public   identnm
ifndef    debug
identnm  db        'DOSMAN.EXE',0
else
identnm  db        'DOSMAN.COM',0
endif

paramexec db       14 dup(0)                ; parametry pro spu®tàn° programy

public   segrez,parrez,conf2e
segrez   dw        0                        ; segment rezidentn°ch dat

public   old22
old22    dd        0                        ; pñvodn° adresa obsluhy INT 22h
old23    dd        0                        ; pñvodn° adresa obsluhy INT 23h
parbreak dw        0                        ; 1=p©°znak uëiv. p©eru®en° BREAK
parrez   db        0                        ;   bit 0: 1=je rezidentn° reëim
                                            ;   bit 1: 1=byl jië prvn° start
                                            ;   bit 2: 1=z†kaz p©eru®en° BREAK
                                            ;   bit 3: 1=ignorovat chyby
                                            ;   bit 4: 1=fonty jsou zkonvert.
                                            ;   bit 7: 1=je p©eru®en° INT 23h

conf2e   db        0                        ;   bit 0: 1=prov†dàn° p©°kazñ INT 2Eh



public   initstart

initstart:                                ;* prvn° start programu
;         push      ds
;         xor       ax,ax
;         mov       ds,ax
;         mov       ax,ds:[4*3]              ; offset INT 3
;         mov       ds:[4*1],ax              ; offset INT 1
;         mov       ax,ds:[4*3+2]            ; segment INT 3
;         mov       ds:[4*1+2],ax            ; segment INT 1
;         pop       ds

         lea       ax,[init]                ; adresa k pokraáov†n° inicializace
         push      ax                       ; n†vratov† adresa z prvn°ho startu
         cld
         lea       ax,[initnul-103h]        ; adresa pro fale®nò start
         mov       word ptr ds:[strt+1],ax  ; nastaven° skoku na fale®nò start
         lea       di,[initstart]           ; zaá†tek dat k vymaz†n°
         mov       cx,offset (initst1-initstart) ; dÇlka dat k vymaz†n°
         xor       al,al                    ; mazac° bajt
         jmp       initstosb                ; vymaz†n° dat

initst1  label     near

         dw        80 dup (0)               ; z†sobn°k pro rezidentn° modul
zasobrez label     word                     ; z†sobn°k
;         dw        0

datarez  label     byte                   ;* zaá†tek rezidentn°ch dat


;              modul DOSMINI.ASM pro program DOSMAN - inicializace

; *****************************************************************************
;
;                        Inicializace programu p©i startu
;
; *****************************************************************************

public   initnul

initnul:                                  ;* fale®nò start programu
;         mov       word ptr ds:[parbreak],-2 ; p©°znak ignorov†n° chyb
         call      chkver                   ; kontrola verze operaán°ho systÇmu
         call      initmem                  ; inicializace pamàti a z†sobn°ku
         call      initcountry              ; inicializace n†rodn°ch informac°
         call      initmod                  ; inicializace displeje
         call      initkey                  ; inicializace zad†n° z p©°kaz.©†dku
         call      initpth0                 ; inicializace aktivn°ho adres†©e
         call      initcus                  ; inicializace uëivatelskòch barev
         call      initpath                 ; inicializace neaktivn°ho adres†©e
         call      initwpar                 ; inicialiace parametrñ oken
         call      initrez                  ; inicializace rezidentn°ch dat
         call      initcolor                ; inicializace barev displeje
         jmp       main

; -----------------------------------------------------------------------------
;                     Kontrola verze operaán°ho systÇmu
; -----------------------------------------------------------------------------
public   chkver

chkver:                                   ;* kontrola verze operaán°ho systÇmu
         mov       ah,30h                   ; funkce poskytnut° á°sla verze OS
         int       21h                      ; poskytnut° á°sla verze OS
         xchg      al,ah                    ; z†màna á°sla verze a podverze
         mov       ds:[verze],ax            ; £schova á°sla verze OS
         cmp       ax,200h                  ; je verze alespo§ 2.00 ?
         jb        chkver1                  ; je chyba n°zkÇ verze systÇmu
         ret
                                          ;* chyba verze operaán°ho systÇmu
chkver1: pop       ax                       ; zru®en° n†vratovÇ adresy
         lea       dx,[errver]              ; text chyby verze operaán°ho syst.
         mov       ah,9                     ; funkce zobrazen° textu
         int       21h                      ; zobrazen° chybovÇho textu
         int       20h                      ; ukonáen° programu (verze OS=1.xx)

; -----------------------------------------------------------------------------
;                            Inicializace pamàti
; -----------------------------------------------------------------------------
public   initmem

initmem:                                  ;* inicializace pamàti

                                          ;* zmen®en° bloku s programem
         lea       bx,[endshell]            ; konec programu
         add       bx,15                    ; zaokrouhlen°
         mov       cl,4
         shr       bx,cl                    ; p©epoáet na odstavce
         mov       ah,4ah
         int       21h                      ; zmen®en° bloku s programem
         jc        initmem1                 ; chyba - nedostatek pamàti
                                          ;* p©idàlen° bloku pro data
         mov       ah,48h
         mov       bx,0ffffh                ; max. blok
         int       21h                      ; dotaz na max. velikost bloku
         mov       ah,48h
         int       21h                      ; p©idàlen° skuteánÇho bloku pamàti
         jc        initmem1                 ; chyba - nedostatek pamàti
         cmp       bx,400h                  ; nejmen®° blok = 16 KB
         jb        initmem1                 ; nedostatek pamàti
         mov       ds:[datseg],ax           ; alokaán° blok dat
         add       ax,bx                    ; segment konec bloku
         sub       ax,100h                  ; odeáten° velikosti z†sobn°ku
         mov       ds:[segend],ax           ; segment konce p©idàlenÇho bloku
                                          ;* inicializace novÇho z†sobn°ku
         pop       bx                       ; n†vratov† adresa z podprogramu
         cli                                ; z†kaz p©eru®en°
         mov       ss,ax                    ; novò segment z†sobn°ku
         mov       ax,1000h                 ; offset konce z†sobn°ku
         mov       sp,ax                    ; novò ukazatel na konce z†sobn°ku
         sti
                                          ;* vymaz†n° oblasti dat
         push      ax                       ; £schova vrcholu z†sobn°ku
         push      word ptr ds:[verze]      ; £schova verze
         push      word ptr ds:[datseg]     ; £schova poá†teán°ho segmentu
         push      word ptr ds:[segend]     ; £schova koncovÇho segmentu
         lea       di,[zacmaz]              ; zaá†tek dat k vymaz†n°
         test      byte ptr ds:[parrez],3   ; je opakovanò start ?
         je        initmem2                 ; nen° opakovanò start
         lea       di,[zacmazr]             ; zaá†tek dat k vymaz†n°
initmem2:lea       cx,[konecmaz]            ; konec dat k maz†n°
         sub       cx,di                    ; dÇlka dat k vymaz†n°
         xor       al,al                    ; AL <- 0 mazac° bajt
         rep       stosb                    ; vymaz†n° oblasti dat
         pop       word ptr ds:[segend]     ; n†vrat koncovÇho segmentu
         pop       word ptr ds:[datseg]     ; n†vrat poá†teán°ho segmentu
         pop       word ptr ds:[verze]      ; n†vrat verze systÇmu
         pop       word ptr ds:[zasob]      ; n†vrat vrcholu z†sobn°ku
         mov       ax,ds:[datseg]           ; zaá†tek alok. bloku dat
         mov       ds:[topseg],ax           ; segment zaá†tku volnÇ pamàti
         mov       ds:[topseged],ax         ; segment zaá†tku volnÇ pamàti
         mov       ax,offset bufcomm2
         sub       ax,offset bufcomm1
         mov       ds:[bufcomm],ax          ; nastaven° dÇlky bufferu p©°kazñ
;         test      byte ptr ds:[parrez],3   ; je opakovanò start ?
;         jne       initmem3                 ; je opakovanò start
;         mov       word ptr ds:[mousepoz],12*256+40 ; pozice my®i
initmem3:jmp       bx                       ; n†vrat z podprogramu

                                          ;* chyba - nedostatek pamàti
initmem1:pop       ax                       ; zru®en° n†vratovÇ adresy
         lea       dx,[errmem]              ; text chyby nedostatku pamàti
         mov       ah,9                     ; funkce zobrazen° textu
         int       21h                      ; zobrazen° chybovÇho textu
         mov       ax,4c01h                 ; funkce n†vratu p©i chybà pamàti
         int       21h                      ; konec programu p©i chybà pamàti

; -----------------------------------------------------------------------------
;                  Inicializace n†rodn°ho prost©ed°
; -----------------------------------------------------------------------------
public   initcountry

initcountry:                              ;* inicializace n†rodn°ho prost©ed°

         test      byte ptr ds:[parrez],3   ; je opakovanò start ?
         jne       initcnt6                 ; je opakovanò start

;         lea       ax,[initcnt8]            ; obsluha RET FAR
;         mov       word ptr cs:[countryh],ax ; offset rutiny mapov†n° znakñ
;         mov       word ptr cs:[countryh+2],cs ; segment rutiny mapov†n° znakñ

         xor       bx,bx                    ; inicializace BX
         mov       ax,3800h                 ; funkce dotazu na prost©ed°
         lea       dx,[outbuf]              ; pracovn° buffer
         int       21h                      ; dotaz na nastaven° prost©ed°
;         cmp       word ptr cs:[verze],300h ; je vy®®° verze neë 3.00 ?
;         jb        initcnt2                 ; je nië®° verze neë 3.00
;         mov       ax,word ptr cs:[outbuf+12h] ; offset rutiny mapov†n° znakñ
;         mov       word ptr cs:[countryh],ax ; offset rutiny mapov†n° znakñ
;         mov       ax,word ptr cs:[outbuf+14h] ; segment rutiny mapov†n° znakñ
;         mov       word ptr cs:[countryh+2],ax ; segment rutiny mapov†n° znakñ
;initcnt2:                                 ;* nastaven° áeskòch fontñ
         test      byte ptr cs:[parrez],3   ; je opakovanò start ?
         jne       initcnt6                 ; je opakovanò start
         cmp       bx,852                   ; je áe®tina Latin 2 ?
         je        initcnt5                 ; je áe®tina Latin 2
         cmp       bx,850                   ; je k¢d Kamenickòch ?
         je        initcnt4                 ; je áe®tina Kamenickòch
         cmp       word ptr cs:[verze],303h ; je vy®®° verze neë 3.03 ?
         jb        initcnt6                 ; je nië®° verze neë 3.03
         mov       ax,6601h                 ; funkce poskytnut° n†rod. informac°
         int       21h                      ; poskytnut° k¢du zemà
         cmp       bx,852                   ; je áe®tina Latin 2 ?
         je        initcnt5                 ; je áe®tina Latin 2
         cmp       bx,850                   ; je k¢d Kamenickòch ?
         jne       initcnt6                 ; nen° zn†mò k¢d prost©ed°
initcnt4:                                 ;* je áe®tina Kamenickòch
         or        byte ptr cs:[config],2   ; nastaven° k¢du Kamenickòch
initcnt5:                                 ;* je áe®tina LATIN 2
         xor       byte ptr cs:[config],3   ; k¢d LATIN 2
initcnt6:
         ret
;
;initcnt  proc      far
;initcnt8:ret                                ; instrukce RET FAR
;initcnt  endp

; -----------------------------------------------------------------------------
;                     Inicializace videom¢du, test displeje
; -----------------------------------------------------------------------------
public   initmod

initmod:                                  ;* inicializace videom¢du

                                          ;* test, zda je videom¢d jië nastaven
         sti
         mov       ah,0fh                   ; funkce dotazu na videom¢d
         int       10h                      ; dotaz na nastavenò videom¢d
         and       al,7fh                   ; zru®en° bitu 7
         cmp       al,3                     ; je videom¢d 3 ?
         je        initmod2                 ; je videom¢d 3 - OK
         cmp       al,2                     ; je videom¢d 2 ?
         je        initmod2                 ; je videom¢d 2 - OK
         cmp       al,7                     ; je videom¢d 7 ?
         je        initmod2                 ; je videom¢d 7 - OK
                                          ;* pokus o nastaven° videom¢du
         mov       al,3                     ; poëadovanò videom¢d 3
         call      initsmod                 ; nastaven° videom¢du
         je        initmod2                 ; videom¢d £spà®nà nastaven
         mov       al,2                     ; poëadovanò videom¢d 2
         call      initsmod                 ; nastaven° videom¢du
         je        initmod2                 ; videom¢d £spà®nà nastaven
         mov       al,7                     ; poëadovanò videom¢d 7
         call      initsmod                 ; nastaven° videom¢du 7 (MDA)
         je        initmod2                 ; videom¢d £spà®nà nastaven
                                          ;* chyba grafickÇ karty
         lea       dx,[errcard]             ; text chyby
         mov       ah,9                     ; funkce tisku textu na displej
         int       21h                      ; zobrazen° chybovÇho textu
         mov       ax,4c01h                 ; funkce n†vratu z programu s chybou
         int       21h                      ; ukonáen° programu s chybou
initmod2:                                 ;* videom¢d £spà®nà nastaven
         mov       ds:[aktpage],bh          ; £schova zobrazenÇ str†nky displeje
         mov       byte ptr ds:[normat],07h ; barva textu p©°kaz. ©†dku
         push      ax                       ; nastavenò videom¢d
         mov       ax,0e0dh
         call      mainout
;         int       10h                      ; znak <CR>
         mov       ax,0e0ah
         call      mainout
;         int       10h                      ; znak <LF>
         mov       ah,3
         int       10h                      ; áten° pozice kurzoru
         mov       ds:[aktkurz],dx          ; £schova pozice kurzoru
         pop       ax                       ; nastavenò videom¢d
         call      initcard                 ; test a nastaven° grafickÇ karty
ifdef    biosdrv
         stc                                ; vnucen° ovladaáe displeje BIOS
endif
                                          ;* instalace ovladaáe displeje
         pushf
         lea       ax,[outch01]             ; ovladaá displeje EGA/CGA/MDA
         jnc       initmod33                ; lze pouë°t vlastn° ovladaá
         lea       ax,[outch02]             ; ovladaá displeje BIOS
initmod33:sub       ax,offset setout
         sub       ax,3
         mov       word ptr cs:[setout+1],ax ; instrukce skoku

;         lea       di,[videoram]            ; buffer videopamàti
                                          ;* vytvo©en° segmentu pro VRAM
         call      createseg                ; vytvo©en° novÇho segmentu dat
         mov       cs:[cisvram],al          ; á°slo segmentu s VRAM
         push      ax
         call      egaask                   ; dotaz na poáet ©†dkñ
         mov       bl,dl                    ; poáet ©†dkñ - 1
         inc       bl
         mov       al,80*2
         mul       bl                       ; dÇlka videpamàti
         mov       bx,ax
         mov       cs:[delvram],ax          ; velikost bufferu videopamàti
         pop       ax

         push      bx
;         mov       bx,80*25*2               ; poëadovan† velikost segmentu
         call      modiseg                  ; modifikace segmentu
         call      getseg                   ; poskytnut° adresy segmentu
         mov       es,bx                    ; adresa segmentu
         xor       di,di                    ; offset ukl†dac° adresy
         pop       bx


         popf
         cld
         jc        initmod4                 ; nen° zn†mò displej
;                                          ;* je vlastn° ovladaá displeje
;         lea       ax,[outch01]             ; ovladaá displeje EGA/CGA/MDA
;         sub       ax,offset setout
;         sub       ax,3
;         mov       word ptr cs:[setout+1],ax ; instrukce skoku
                                          ;* £schova obsahu obrazovky
         lds       si,dword ptr cs:[adrvram]; adresa videopamàti
         mov       cx,bx                    ; dÇlka videopamàti
         shr       cx,1                     ; poáet znakñ v bufferu
;         mov       cx,80*25                 ; poáet znakñ ve videopamàti
         rep       movsw                    ; £schova videopamàti
         push      cs
         pop       ds
         push      cs
         pop       es
         ret
initmod4:                                 ;* £schova obsahu nestand. displeje
         xor       dx,dx                    ; ukazatel pozice
initmod6:push      dx                       ; ukazatel textu
         mov       cx,80                    ; ®°©ka ©†dku
initmod7:push      di                       ; ukl†dac° adresa
         mov       ah,2                     ; funkce nastaven° pozice kurzoru
         int       10h                      ; nastaven° pozice kurzoru
         mov       ah,8                     ; funkce áten° znaku
         int       10h                      ; áten° znaku s atributem
         pop       di                       ; ukl†dac° adresa
         stosw                              ; uloëen° znaku s atributem
         inc       dl                       ; zvò®en° pozice na ©†dku
         loop      initmod7                 ; dal®° znak na ©†dku
         pop       dx
         inc       dh                       ; zvò®en° ©†dku
         cmp       dh,25
         jb        initmod6                 ; dal®° ©†dek
         push      cs
         pop       es
         ret

; -----------------------------------------------------------------------------
public   initsmod

initsmod:                                 ;* pokus o nastaven° videom¢du
                                            ; VSTUP: AL=videom¢d
                                            ; VùSTUP: ZY=videom¢d nastaven

         push      dx
         push      ax                       ; £schova poëadovanÇho videom¢du
         xor       ah,ah                    ; funkce nastaven° videom¢du
         int       10h                      ; nastaven° videom¢du
         mov       ah,0fh                   ; funkce poskytnut° aktiv. videom¢du
         int       10h                      ; poskytnut° aktivn°ho videom¢du
         mov       dl,al                    ; aktu†ln° videom¢d
         pop       ax                       ; n†vrat poëadovanÇho videom¢du
         cmp       al,dl                    ; souhlas° videom¢d s poëadovanòm ?
         pop       dx
         ret

; -----------------------------------------------------------------------------
public   initcard

initcard:                                 ;* test a nastaven° grafickÇ karty
                                            ; VSTUP: AL=aktivn° videom¢d
                                            ;        BH=aktivn° videostr†nka
                                            ; VùSTUP: CY=nestandard. displej

         push      ax                       ; AL=aktivn° videom¢d
         push      bx                       ; BH=aktivn° videostr†nka
         push      ds
                                          ;* inicializace parametrñ
         xor       cx,cx
         mov       ds,cx                    ; DS <- 0
         mov       si,ds:[044eh]            ; poá†teán° adresa videostr†nky
         mov       cs:[adrvram],si          ; poá†teán° adresa videostr†nky
         mov       cx,0b800h                ; segment B800h pro EGA, CGA
         cmp       al,7                     ; je videom¢d 7 ?
         jne       initcrd2                 ; nen° MDA
         mov       cx,0b000h                ; segment B000h pro MDA/Hercules
         test      byte ptr cs:[parrez],3   ; je opakovanò start ?
         jne       initcrd2                 ; displej je jië nainstalov†n
         or        byte ptr cs:[flags],20h  ; p©°znak monochromatickÇho displeje
initcrd2:mov       cs:[segvram],cx          ; segment videopamàti
         mov       ds,cx                    ; segment videopamàti
                                          ;* £schova znaku
         push      si                       ; adresa zaá†tku videostr†nky
         xor       dx,dx                    ; pozice kurzoru levò horn° roh
         mov       ah,2                     ; funkce nastaven° kurzoru
         int       10h                      ; pozice kurzoru do levÇho rohu
         mov       ah,8                     ; funkce áten° znaku s atributem
         int       10h                      ; áten° znaku pod kuzorem
         pop       si
         cmp       ax,ds:[si]               ; shoduje se znak ?
         stc                                ; p©°znak chyby
         jne       initcrd5                 ; znak se neshoduje
                                          ;* test z†pisu opaánÇho znaku
         not       ax                       ; negace znaku
         push      si                       ; adresa zaá†tku videostr†nky
         push      ax                       ; negovanò znak s atributem
         mov       bl,ah                    ; atribut znaku
         mov       ah,9                     ; funkce z†pisu znaku s atributem
         mov       cx,1                     ; poáet znakñ k z†pisu = 1
         int       10h                      ; z†pis znaku
         pop       ax                       ; negovanò znak
         pop       si                       ; adresa zaá†tku videostr†nky
         cmp       word ptr ds:[si],ax      ; souhlas° zapsanò znak ?
         je        initcrd4                 ; znak souhlas°
         stc                                ; p©°znak chyby
initcrd4:                                 ;* n†vrat znaku
         pushf                              ; CF = p©°znak, zda je driver OK
         not       ax                       ; n†vrat pñvodn°ho znaku
         mov       bl,ah                    ; atribut znaku
         mov       ah,9                     ; funkce z†pisu znaku s atributem
         mov       cx,1                     ; poáet znakñ k z†pisu = 1
         int       10h                      ; n†vrat pñvodn°ho znaku
         popf                               ; CF = p©°znak, zda je driver OK
initcrd5:pushf
         mov       dx,cs:[aktkurz]          ; uschovan† pozice kurzoru
         mov       ah,2                     ; funkce nastaven° kurzoru
         int       10h                      ; n†vrat pozice kurzoru
         popf
         pop       ds
         pop       bx                       ; BH=aktivn° videostr†nka
         pop       ax                       ; AL=aktivn° videom¢d
         ret

; -----------------------------------------------------------------------------
;                   Instalace vlastn°ch obsluh p©eru®en°
; -----------------------------------------------------------------------------
public   initint

initint:                                    ; inicializace obsluh p©eru®en°
                                          ;* instalace INT 1Bh
         mov       ax,351bh
         int       21h
         mov       word ptr ds:[old1b],bx
         mov       word ptr ds:[old1b+2],es ; pñvodn° adresa INT 1bh
         mov       ax,251bh
         lea       dx,[int23]
         int       21h                      ; nastaven° obsluhy INT 1bh
                                          ;* instalace INT 23h
         test      byte ptr cs:[parrez],3   ; je opakovanò start ?
         jne       initint2                 ; je opakovanò start
         mov       ax,3523h
         int       21h
         mov       word ptr ds:[old23],bx
         mov       word ptr ds:[old23+2],es ; pñvodn° adresa INT 23h
         mov       ax,2523h
         lea       dx,[int23]
         int       21h                      ; nastaven° obsluhy INT 23h
initint2:                                 ;* inicializace INT 24h
         mov       ax,3522h
         int       21h
         mov       word ptr ds:[old22],bx
         mov       word ptr ds:[old22+2],es ; pñvodn° adresa INT 22h

         mov       ax,3524h
         int       21h
         mov       word ptr ds:[old24],bx
         mov       word ptr ds:[old24+2],es ; pñvodn° adresa INT 24h
         mov       ax,2524h
         lea       dx,[int24]
         int       21h                      ; nastaven° obsluhy INT 24h

         mov       ax,3508h
         int       21h
         mov       word ptr ds:[old08],bx
         mov       word ptr ds:[old08+2],es ; pñvodn° adresa INT 08h
         mov       ax,2508h
         lea       dx,[int08]
         int       21h                      ; nastaven° obsluhy INT 08h

         mov       ax,3509h
         int       21h
         mov       word ptr ds:[old09],bx
         mov       word ptr ds:[old09+2],es ; pñvodn° adresa INT 09h
         mov       ax,2509h
         lea       dx,[int09]
         int       21h                      ; nastaven° obsluhy INT 09h

         mov       ax,3510h
         int       21h
         mov       word ptr ds:[old10],bx
         mov       word ptr ds:[old10+2],es ; pñvodn° adresa INT 10h
         mov       ax,2510h
         lea       dx,[int10]
         int       21h                      ; nastaven° obsluhy INT 10h

         mov       ax,3521h
         int       21h
         mov       word ptr ds:[old21],bx
         mov       word ptr ds:[old21+2],es ; pñvodn° adresa INT 21h
         mov       ax,2521h
         lea       dx,[int21]
         int       21h                      ; nastaven° obsluhy INT 21h

         push      cs
         pop       es
         ret

; -----------------------------------------------------------------------------
;                  Inicializace aktu†ln°ho adres†©e
; -----------------------------------------------------------------------------
public   initpth0

initpth0:                                 ;* inicializace aktivn°ho adres†©e

         lea       di,[pathr]               ; pravò adres†©
         call      loadpath                 ; naáten° aktivn°ho adres†©e
         lea       si,[pathl]               ; levò adres†©
         xchg      si,di
         call      transtxt                 ; zkop°rov†n° adres†©ñ
         ret

; -----------------------------------------------------------------------------
;                  Inicializace domovskÇho adres†©e
; -----------------------------------------------------------------------------
public   inithome

inithome:                                 ;* inicializace domovskÇho adres†©e

         push      cs
         pop       ds
         push      cs
         pop       es
         test      byte ptr ds:[parrez],3   ; je opakovanò start ?
         jne       inithom6                 ; je opakovanò start
         mov       bx,offset pathhom1       ; p©°stupov† cesta k adres†©i
         cmp       word ptr ds:[verze],300h ; je verze 3.00 nebo vy®®° ?
         jb        inithom5                 ; je nië®° verze neë 3.00
                                          ;* nalezen° ©etàzce domovskÇ cesty
         mov       ds,ds:[2ch]              ; segment prost©ed°
         mov       si,3                     ; poá†teán° offset prost©ed° + 3
         xor       ax,ax                    ; AX <- 0 (hledanÇ slovo)
inithom1:inc       si                       ; zvò®en° adresy textu
         cmp       ds:[si-4],ax             ; je konec ©etàzcñ prost©ed° (0) ?
         jne       inithom1                 ; nen° konec ©etàzcñ prost©ed°
         cmp       ds:[si-2],ax             ; je nàjakò ©etàzec ?
         je        inithom5                 ; nen° ë†dnò ©etàzec - chyba
                                          ;* p©enos domovskÇho adres†©e
         mov       di,bx                    ; p©°stupov† cesta k adres†©i
         mov       cx,127                   ; maxim†ln° dÇlka cesty
         push      di                       ; £schova adresy zaá†tku textu
inithom2:lodsb                              ; naáten° znaku ©etàzce
         stosb                              ; uloëen° znaku
         cmp       al,"\"                   ; je oznaáen° adres†©e ?
         jne       inithom3                 ; nen° znak adres†©e
         dec       di                       ; n†vrat adresy znaku "\"
         add       sp,2                     ; zru®en° uschovanÇ adresy konce
         push      di                       ; uloëen° novÇ adresy konce textu
         inc       di                       ; zvò®en° na adresu dal®°ho znaku
inithom3:or        al,al                    ; je jië konec ©etàzce ?
         jz        inithom4                 ; je jië konec ©etàzce
         loop      inithom2                 ; p©enos dal®°ho znaku
inithom4:;pop       si                       ; n†vrat adresy konce ©etàzce
;                                          ;* £schova jmÇna programu
;         push      si
;         push      ds
;         push      cs
;         pop       ds
;         inc       si
;         lea       di,[identnm]             ; identifikaán° text souboru
;         call      transtxt                 ; p©enos jmÇna programu
;         pop       ds
         pop       di
;
;         cmp       byte ptr es:[di-1],":"   ; je z†kladn° adres†© ?
;         jne       inithom7
;         inc       di                       ; p©eskoáen° znaku "\"
inithom7:xor       al,al                    ; AL <- 0 ukonáovac° bajt ©etàzce
         stosb                              ; uloëen° koncovÇho bajtu 0
         push      cs
         pop       ds
         mov       si,bx                    ; p©°stupov† cesta k adres†©i
         call      aktdir                   ; nastaven° poëadovanÇho adres†©e
inithom5:                                 ;* naáten° domovskÇ cesty
         mov       di,bx                    ; p©°stupov† cesta k adres†©i
         call      loadpath                 ; naáten° aktivn° cesty
inithom6:push      cs
         pop       ds
         test      byte ptr ds:[parrez],3   ; je opakovanò start ?
         jne       inithom8                 ; je opakovanò start
         mov       si,offset pathhom1
         mov       di,offset pathhome
         call      transtxt                 ; kopie adres†©e
inithom8:ret

; -----------------------------------------------------------------------------
;                    Inicializace uëivatelskÇ n†povàdy
; -----------------------------------------------------------------------------
public   inituse

inituse:                                  ;* inicializace uëivatelskÇ n†povàdy
                                            ; je nastaven domovskò adres†©

         test      byte ptr ds:[parrez],3   ; je opakovanò start ?
         jne       inituse2                 ; je opakovanò start
         lea       di,[hlpuse]
         mov       al," "
         mov       cx,6*10
         rep       stosb                    ; vymaz†n° bufferu
                                          ;* otev©en° souboru
         lea       dx,[soubuse]             ; jmÇno souboru "DOSMAN.USE"
         mov       ax,3d00h
         int       21h                      ; otev©en° souboru pro áten°
         jc        inituse2                 ; chyba
                                          ;* naáten° souboru
         mov       bx,ax                    ; identifik†tor souboru
         lea       dx,[hlpuse]              ; adresa k naáten° souboru
         mov       cx,6*10                  ; dÇlka n†povàdy
         mov       ah,3fh
         int       21h                      ; naáten° souboru
                                          ;* uzav©en° souboru
         mov       ah,3eh
         int       21h                      ; uzav©en° souboru
inituse2:
         ret

; -----------------------------------------------------------------------------
;                    Inicializace uëivatelskòch barev
; -----------------------------------------------------------------------------
public   initcus

initcus:                                  ;* inicializace uëivatelskòch barev

         test      byte ptr ds:[parrez],3   ; je opakovanò start ?
         jne       initcus2                 ; je opakovanò start
                                          ;* vymaz†n° bufferu
         lea       di,[helpbuf]
         mov       cx,1024                  ; dÇlka bufferu
         xor       al,al
         rep       stosb                    ; vymaz†n° bufferu
                                          ;* otev©en° souboru
         lea       dx,[soubcol]             ; jmÇno souboru "DOSMAN.COL"
         mov       ax,3d00h
         int       21h                      ; otev©en° souboru pro áten°
         jc        initcus2                 ; chyba
                                          ;* naáten° souboru
         mov       bx,ax                    ; identifik†tor souboru
         lea       dx,[helpbuf]             ; adresa k naáten° souboru
         mov       cx,1020                  ; max. dÇlka souboru
         mov       ah,3fh
         int       21h                      ; naáten° souboru
                                          ;* uzav©en° souboru
         mov       ah,3eh
         int       21h                      ; uzav©en° souboru
initcus2:
         ret

; -----------------------------------------------------------------------------
;                  Inicializace historie povelñ
; -----------------------------------------------------------------------------
public   inithis

inithis:                                  ;* inicializace historie povelñ
         test      byte ptr ds:[parrez],3   ; je opakovanò start ?
         jne       inithis4                 ; je opakovanò start
                                          ;* otev©en° souboru
         mov       dx,offset soubhis        ; jmÇno souboru "$DOSMAN$.HIS"
         mov       ax,3d00h
         int       21h                      ; otev©en° souboru pro áten°
         jc        inithis4                 ; chyba
         mov       bx,ax                    ; identifik†tor souboru
                                          ;* kontrola velikosti souboru
         mov       ax,4202h
         xor       cx,cx                    ; DX <- 0 nië®° slovo offsetu
         xor       dx,dx                    ; CX <- 0 vy®®° slovo offsetu
         int       21h                      ; p©esun ukazatele na konec souboru
         add       ax,offset zachis         ; vòpoáet konce historie
         cmp       ax,offset konhis         ; souhlas° velikost souboru ?
         jne       inithis3                 ; velikost nesouhlas°
         mov       ax,4200h
         xor       cx,cx                    ; CX <- 0 vy®®° slovo offsetu
         xor       dx,dx                    ; DX <- 0 nië®° slovo offsetu
         int       21h                      ; p©esun ukazatele na zaá†tek soub.

                                          ;* naáten° souboru
         mov       dx,offset zachis         ; zaá†tek historie
         mov       cx,offset konhis         ; konec historie
         sub       cx,dx                    ; dÇlka historie
         mov       ah,3fh
         int       21h                      ; naáten° souboru
                                          ;* uzav©en° souboru
inithis3:mov       ah,3eh
         int       21h                      ; uzav©en° souboru
inithis4:
         ret

; -----------------------------------------------------------------------------
;                    Inicializace podle rezidentn°ch dat
; -----------------------------------------------------------------------------
public   initrez

initrez:                                  ;* inicializace podle rezidentn°ch dat

         test      byte ptr ds:[parrez],3   ; je rezidentn° reëim ?
         jne       initrz2                  ; je rezidentn° reëim
                                          ;* nalezen° rezidentn°ch dat v pamàti
         mov       cs:[segrez],cs           ; segment rezidentn°ch dat
         mov       ds,ds:[10h]              ; segment pro p©eru®en° programu
         lea       si,[zacident]            ; zaá†tek identifikaán°ch dat
         mov       di,si                    ; zaá†tek identifikace v tomto prog.
         mov       cx,offset(konident-zacident); dÇlka identifikaán°ch dat
         repe      cmpsb                    ; porovn†n° identifikaán°ch ©etàzcñ
         jne       initrz2                  ; nenalezena rezidentn° data
                                          ;* naáten° rezidentn°ch dat
         mov       cs:[segrez],ds           ; segment rezidentn°ch dat
         lea       si,[datarez]             ; zaá†tek rezidentn°ch dat
         lea       di,[inidata]             ; zaá†tek inicializaán°ch dat
         lea       cx,[inidend]
         sub       cx,di                    ; dÇlka rezidentn°ch dat
         rep       movsb                    ; naáten° rezidentn°ch dat
initrz2: push      cs
         pop       ds
         ret

; -----------------------------------------------------------------------------
;                      Inicializace parametrñ oken
; -----------------------------------------------------------------------------
public   initwpar

initwpar:                                 ;* inicializace parametrñ oken

                                          ;* inicializace p©°znakñ oken
         mov       al,ds:[flags0l]          ; uschovanÇ p©°znaky levÇho okna
         and       al,0f1h                  ; zru®en° p©°znakñ naáten° adres†©e
         mov       ds:[flagsl],al           ; nastaven° p©°znakñ levÇho okna
         mov       al,ds:[flags0r]          ; uschovanÇ p©°znaky pravÇho okna
         and       al,0f1h                  ; zru®en° p©°znakñ naáten° adres†©e
         mov       ds:[flagsr],al           ; nastaven° p©°znakñ pravÇho okna
                                          ;* nastaven° parametrñ oken
         mov       al,ds:[setwls]
         and       al,not 4                 ; zru®en° p©°znaku segmentu pozn.
         mov       ds:[setwl],al
         mov       al,ds:[setwrs]
         and       al,not 4                 ; zru®en° p©°znaku segmentu pozn.
         mov       ds:[setwr],al
                                          ;* nastaven° adres n†vaznosti oken
initwpr3:lea       ax,[tabl]                ; adresa levÇho okna
         mov       ds:[adrtabr],ax          ; n†vaznost na levÇ okno
         lea       ax,[tabr]                ; adresa pravÇho
         mov       ds:[adrtabl],ax          ; n†vaznost na pravÇ okno
                                          ;* nastaven° poá†teán°ch pozic oken
         mov       ax,word ptr ds:[pozwr]   ; poá†teán° pozice pravÇho okna
         mov       ds:[pozr],al             ; poá†teán° pozice pravÇho okna
         mov       ds:[pozl],ah             ; poá†teán° pozice levÇho okna
                                          ;* nastaven° adres p©°stupovòch cest
         lea       ax,[pathr]               ; p©°stupov† cesta prav†
         mov       ds:[adrpathr],ax         ; nastaven° pravÇ p©°stupovÇ cesty
         lea       ax,[pathl]               ; p©°stupov† cesta lev†
         mov       ds:[adrpathl],ax         ; nastaven° levÇ p©°stupovÇ cesty
                                          ;* nastaven° adres masek
         mov       word ptr ds:[adrmaskl],offset maskl ; adr. masky levÇho okna
         mov       word ptr ds:[adrmaskr],offset maskr ; adr. masky pravÇho okna
                                          ;* nastaven° adres bufferñ seznamñ
         call      createseg                ; vytvo©en° datovÇho segmentu
         mov       ds:[cissegl],al          ; p©idàlen° segmentu levÇmu oknu
         call      createseg                ; vytvo©en° datovÇho segmentu
         mov       ds:[cissegr],al          ; p©idàlen° segmentu pravÇmu oknu

         ret

; -----------------------------------------------------------------------------
;                  Inicializace neaktivn°ho adres†©e
; -----------------------------------------------------------------------------
public   initpath

initpath:                                 ;* inicializace neaktivn°ho adres†©e

         call      getnakt                  ; poskytnut° adresy neaktiv. okna
         lea       si,[path]                ; cesta k neaktivn°mu oknu
         cmp       byte ptr ds:[si],0       ; je nàjakò ©etàzec ?
         je        initpth1                 ; nen° ë†dnò ©etàzec
         mov       di,ds:[bp+4]             ; adresa p©°stupovÇ cesty
         mov       cx,70                    ; dÇlka ©etàzce cesty
         rep       movsb                    ; p©enesen° ©etàzce
initpth1:ret

; -----------------------------------------------------------------------------
;                          Zad†n° z p©°kazovÇho ©†dku
; -----------------------------------------------------------------------------
public   initkey

initkey:                                  ;* inicializace p©°kazovÇho ©†dku
                                          ;* inicializace licenán°ho á°sla
         mov       ax,ds:[0fah]             ; nië®° slovo licenán°ho á°sla
         mov       word ptr ds:[licence],ax
         mov       ax,ds:[0fch]             ; vy®®° slovo licenán°ho á°sla
         mov       word ptr ds:[licence+2],ax

         mov       di,81h                   ; adresa p©°kazovÇho ©†dku
         xor       ch,ch                    ; CH <- 0
         mov       cl,ds:[di-1]             ; dÇlka ©etàzce p©°kazovÇho ©†dku
         mov       ds:[di-1],ch             ; vynulov†n° bufferu
         cmp       cl,120                   ; maxim†ln° dÇlka p©°kaz. ©†dku
         jbe       initkey2
         mov       cl,120                   ; omezen° dÇlky ©†dku
                                          ;* nalezen° zad†n° parametrñ "/"
initkey2:jcxz      initkey1                 ; nen° zadanò ë†dnò znak
         mov       al,ds:[di]               ; znak z p©°kazovÇho ©†dku
         inc       di                       ; zvò®en° ukazatele znakñ
         dec       cx                       ; sn°ëen° á°taáe znakñ
         cmp       al," "                   ; je oddàlovaá ?
         jbe       initkey2                 ; je oddàlovaá - ignorov†n°
         cmp       al,"/"                   ; je oddàlovaá parametrñ ?
         je        initkey3                 ; je parametr
                                          ;* inicializace editoru
ifdef    upver
         cmp       byte ptr ds:[di-2]," "   ; p©edch†zel oddàlovaá ?
         ja        initkey2                 ; nep©edch†zel oddàlovaá
         call      initkeed                 ; inicializace editoru
endif
         jmp       short initkey2           ; dal®° znak

initkey3:                                 ;* skok podle zadanÇho parametru
         mov       al,ds:[di+1]             ; dal®° n†sleduj°c° znak
         call      highcase                 ; p©evod na velkÇ p°smeno
         mov       ah,al
         mov       al,ds:[di]               ; n†sleduj°c° znak
         call      highcase                 ; p©evod na velkÇ p°smeno
         call      getakt                   ; poskytnut° aktivn°ho okna
         lea       bx,[skokinik]            ; tabulka skokñ pro inicializaci
         call      skokax                   ; skok podle hodnoty AX
         jmp       short initkey2           ; dal®° znak
initkey1:
         ret

initkdm:                                  ;* parametr "/DM" - monochrom. disp.
         or        byte ptr ds:[flags],20h  ; nastaven° p©°znaku monochr. displ.
         ret

initkdc:                                  ;* parametr "/DC" - barevnò displej
         and       byte ptr ds:[flags],not 20h ; p©°znak barevnÇho displeje
         ret

initkfc:                                  ;* parametr "/FC" - áe®tina bez diakr.
         and       byte ptr ds:[config],not 3
         or        byte ptr ds:[config],1   ; p©°znak vypnut° áe®tiny
         ret

initkfk:                                  ;* parametr "/FK" - áe®tina Kamenic.
         and       byte ptr ds:[config],not 3 ; áe®tina Kamenickòch
         ret

initkfl:                                  ;* parametr "/FL" - áe®tina Latin 2
         and       byte ptr ds:[config],not 3
         or        byte ptr ds:[config],2   ; áe®tina LATIN 2
         ret

initkb:                                   ;* parametr "/B" - n†povàda
         xor       byte ptr ds:[flags],4    ; zmàna p©°znaku n†povàdy
         ret

initkl:                                   ;* parametr "/L" - neaktivn° okno
         call      getnakt                  ; poskytnut° neaktivn°ho okna
         xor       byte ptr ds:[bp+0],1     ; zmàna p©°znaku aktivity okna
         ret

initko:                                   ;* parametr "/O" - zap/vyp obou oken
         xor       byte ptr ds:[flags],2    ; zmàna p©°znaku aktivity obou oken
         ret

initkt:                                   ;* parametr "/T" - p©epnut° aktiv.okna

         call      testaktw                 ; je aktivn° okno zapnuto ?
         jc        initku1                  ; okno nen° zapnuto
         xor       byte ptr ds:[flags],1    ; zmàna aktivn°ho okna
         call      getakt                   ; novÇ aktivn° okno
         call      testaktw                 ; je neaktivn° okno zapnuto ?
         jnc       initku1                  ; neaktivn° okno je zapnuto
         xor       byte ptr ds:[flags],1    ; n†vrat aktivn°ho okna

initku:                                   ;* parametr "/U" - z†màna oken
         mov       al,ds:[pozl]             ; pozice levÇho okna
         xchg      al,ds:[pozr]             ; nov† pozice pravÇho okna
         mov       ds:[pozl],al             ; nov† pozice levÇho okna
initku1: ret


initkc:                                   ;* parametr "/C" - proveden° p©°kazu

         mov       si,di                    ; zaá†tek textu cesty
         inc       si
         lea       di,[buftxt]              ; buffer povelovÇho ©†dku
         jcxz      initkp2                  ; je konec ©etàzce
         dec       cx
         push      di
         rep       movsb                    ; p©enos textu p©°kazu
         xor       al,al
         stosb                              ; koncov† 0
         pop       si                       ; adresa textu
;         jmp       execute                  ; proveden° p©°kazu

initkp2: ret

initksn:                                  ;* parametr "/SN" - t©°dàn° podle jmÇna
         and       byte ptr ds:[bp+0],0fh   ; zru®en° p©°znakñ t©°dàn°
         ret

initkp:                                   ;* parametr "/P" - rezidentn° reëim
         or        byte ptr ds:[flags],8    ; p©°znak rezidentn°ho reëimu
         ret

initkse:                                  ;* parametr "/SE" - t©°dàn° podle p©°pony
         and       byte ptr ds:[bp+0],0fh   ; zru®en° p©°znakñ t©°dàn°
         or        byte ptr ds:[bp+0],20h   ; p©°znak t©°dàn° podle p©°pony
         ret

initksd:                                  ;* parametr "/SD" - t©°dàn° podle data
         and       byte ptr ds:[bp+0],0fh   ; zru®en° p©°znakñ t©°dàn°
         or        byte ptr ds:[bp+0],40h   ; p©°znak t©°dàn° podle data
         ret

initkss:                                  ;* parametr "/SS" - t©°dàn° podle velikosti
         and       byte ptr ds:[bp+0],0fh   ; zru®en° p©°znakñ t©°dàn°
         or        byte ptr ds:[bp+0],80h   ; p©°znak t©°dàn° podle velikosti
         ret

initksx:                                  ;* parametr "/SX" - net©°dàn° adres†©
         and       byte ptr ds:[bp+0],0fh   ; zru®en° p©°znakñ t©°dàn°
         or        byte ptr ds:[bp+0],10h   ; p©°znak net©°dànÇho adres†©e
         ret


initkx:                                   ;* parametr "/X" - prov†dàn° povelñ INT 2eh
ifndef   demo
         or        byte ptr ds:[conf2],1    ; p©°znak povelñ pomoc° INT 2Eh
endif
         ret

initka:  cmp       bp,offset tabl           ; je levÇ okno ?
         mov       al,2                     ; maska pro levÇ okno
         je        initka2                  ; je levÇ okno
         mov       al,4                     ; maska pro pravÇ okno
initka2: xor       cs:[conf2],al            ; zmàna p©°znakñ okna
         ret

initkqq:                                  ;* parametr "/QQ" - zobrazen° pozn†mek
ifdef    upver
         xor       byte ptr ds:[bp+29],2    ; zmàna p©°znaku zobrazen° pozn†mek
         ret
endif

initkq:                                   ;* parametr "/Q" - trojsloupc. zobraz.
         xor       byte ptr ds:[bp+29],1    ; zmàna p©°znaku zobrazen°
         ret

initkh:                                   ;* parametr "/H" - vypnut° SHIFT
         and       byte ptr ds:[conf2],not 10h ; vypnut° funkce SHIFT
         ret

initk43:                                  ;* parametr "/43" - nastaven° EGA 43
         or        byte ptr ds:[conf7],4    ; p©°znak displeje EGA 43
         and       byte ptr ds:[conf7],not 1; zru®en° p©°znaku displeje VGA 28
         ret

initkn:                                   ;* parametr "/N" - uëivatelskÇ menu
         or        byte ptr ds:[conf3],3    ; p©°znak automatickÇho menu
         ret

initkk:                                   ;* parametr "/K" - stand. kl†vesnice
         or        byte ptr ds:[conf3],4    ; p©°znak standardn° kl†vesnice
         ret

initkm0:                                  ;* parametr "M0" - z†kaz pouëit° my®i
         or        byte ptr ds:[conf3],8    ; p©°znak z†kazu pouëit° my®i
         ret


initkz:                                   ;* zad†n° domovskÇho adres†©e

ifdef    upver
         jcxz      initkz3
         inc       di                       ; p©eskoáen° znaku "Z"
         dec       cx                       ; sn°ëen° á°taáe znakñ
         push      di
         mov       di,offset outbuf3
         call      loadpath                 ; £schova cesty
         pop       di
         mov       si,offset outbuf4        ; pracovn° buffer
         call      initspec                 ; p©enos specifikace souboru
         call      aktdir                   ; nastaven° poëadovanÇho adres†©e
         jc        initkz2                  ; chyba zad†n° adres†©e
         push      di
         mov       di,offset pathhome       ; cesta k domovskÇmu adres†©i
         call      loadpath                 ; naáten° cesty k domovskÇmu adres.
         pop       di
initkz2: mov       si,offset outbuf3
         call      aktdir                   ; navr†cen° pñvodn°ho adres†©e
endif
initkz3: ret

initspec:                                 ;* p©enos specifikace souboru
         push      si
         push      dx
         xor       dx,dx                    ; á°taá znakñ
         jcxz      initspc3
                                          ;* nalezen° zaá†tku zad†n°
initspc1:mov       al,ds:[di]
         cmp       al," "
         ja        initspc2                 ; nen° oddàlovaá
         inc       di
         loop      initspc1
         jcxz      initspc3
                                          ;* p©enesen° textu
initspc2:mov       al,ds:[di]
         cmp       al," "
         jbe       initspc3                 ; konec
         cmp       al,"/"
         je        initspc3
         cmp       al,'"'
         je        initspc3
         cmp       al,"'"
         je        initspc3
         cmp       al,","
         je        initspc3
         cmp       al,";"
         je        initspc3
         mov       ds:[si],al               ; uloëen° znaku
         inc       dx                       ; zvò®en° á°taáe znakñ
         inc       si
         inc       di
         loop      initspc2
initspc3:or        dx,dx
         jz        initspc4                 ; nen° ë†dnò znak
         cmp       byte ptr ds:[si-1],"\"   ; byl posledn° znak "\" ?
         jne       initspc4                 ; cesta nekonáila "\"
         cmp       dx,1                     ; je pouze 1 znak ?
         jbe       initspc4                 ; je jen 1 znak
         cmp       byte ptr ds:[si-2],":"   ; byl zad†n disk ?
         je        initspc4                 ; byl zad†n disk
         dec       si                       ; n†vrat posledn°ho znaku
initspc4:mov       byte ptr ds:[si],0       ; koncov† 0 textu
         pop       dx
         pop       si
         ret

ifdef    upver
initkeed:                                 ;* inicializace parametru editoru

         mov       bx,offset buffedi2       ; jmÇno pro editaci
initked1:mov       ds:[bx],al               ; uloëen° znaku
         inc       bx                       ; zvò®en° ukl†dac° pozice
         jcxz      initked2                 ; nen° jië dal®° znak
         mov       al,ds:[di]               ; dal®° znak
         cmp       al," "                   ; je oddàlovac° znak ?
         jbe       initked2                 ; oddàlovaá - konec jmÇna souboru
         cmp       al,"/"                   ; oddàlovaá parametrñ ?
         je        initked2                 ; parametry - konec jmÇna souboru
         cmp       al,"="
         je        initked2
         cmp       al,","
         je        initked2
         inc       di                       ; zvò®en° átec° adresy
         dec       cx
         jmp       short initked1           ; dal®° znak
initked2:
         mov       byte ptr ds:[bx],0       ; oznaáen° konce textu
         ret
endif

initkv:                                   ;* zviditelnàn° skrytòch souborñ
         or        byte ptr ds:[conf6],1    ; zapnut° souborñ HID a SYS
         ret

initky:                                   ;* zobrazuje se n†và®t° "/Y"
ifdef    upver
         or        byte ptr ds:[conf5],80h  ; p©°znak zobrazen° n†và®t°
endif
         ret


initkr:                                   ;* nastaven° doby stm°v†n° "/R"
ifdef    upver
         jcxz      initkr3
         inc       di                       ; p©eskoáen° znaku "R"
         dec       cx                       ; sn°ëen° á°taáe znakñ
         call      initknum                 ; áten° á°sla
         or        dx,dx                    ; á°slo > 65535 ?
         jnz       initkr3                  ; je vàt®°
         cmp       ax,60                    ; maxim†ln° doba 60 minut
         ja        initkr3                  ; chyba
         mov       dx,60*18                 ; n†sobek pro 1 minutu
         mul       dx                       ; p©epoáet na impulsy
         mov       ds:[dark],ax
endif
initkr3: ret



initkw:                                   ;* nastaven° velikosti okna

ifdef    upver
         jcxz      initkw3
         inc       di                       ; p©eskoáen° znaku "W"
         dec       cx                       ; sn°ëen° á°taáe znakñ
         call      initknum                 ; áten° á°sla
         or        dx,dx                    ; á°slo > 65535 ?
         jnz       initkw3                  ; je vàt®°
         cmp       ax,250
         ja        initkw3

         or        ax,ax
         jz        initkw3                  ; nebyl parametr
         cmp       al,3                     ; minim†ln° velikost
         jae       initkw1
         mov       al,3
initkw1: add       al,5
         mov       ds:[displw],al
endif
initkw3: ret

initkg:                                   ;* parametr "/G" - porty COM pro vòzvu
         jcxz      initkg5
         inc       di                       ; p©eskoáen° znaku "G"
         dec       cx
initkg1: mov       al,ds:[di]               ; dal®° p©ipravenò znak
         sub       al,"1"
         jb        initkg5                  ; nen° platn† á°slice
         cmp       al,3
         ja        initkg5                  ; nen° platn† á°slice
         inc       di                       ; zvò®en° ukazatele textu
         push      cx
         mov       cl,al                    ; á°slo portu
         mov       al,1
         shl       al,cl                    ; rotace na pozici
         pop       cx
         or        byte ptr ds:[vyzvycom],al ; zapnut° p©°jmu vòzvy
         loop      initkg1                  ; dal®° znak
initkg5: ret

initkj:  or        byte ptr ds:[conf6],80h  ; automatickò kalend†©
         ret

initk28:                                  ;* parametr "/28" - 28 ©†dkñ pro VGA
ifdef    upver
         and       byte ptr ds:[conf7],not 4; zru®en° p©°znaku displeje EGA 43
         or        byte ptr ds:[conf7],1    ; p©°znak 28 ©†dkñ pro VGA
endif
         ret

initki:                                   ;* parametr "/I" - £schova historie
ifdef    upver
         or        byte ptr ds:[conf7],2    ; p©°znak £schovy historie
endif
         ret


initknum:                                 ;* áten° á°sla DX:AX
         xor       dx,dx
         xor       ax,ax
         mov       si,10
         xor       bx,bx
initknu1:jcxz      initknu4
         mov       bl,ds:[di]
         sub       bl,"0"
         jb        initknu4
         cmp       bl,10
         jae       initknu4
         mul       si
         add       ax,bx
         adc       dx,0
         inc       di
         loop      initknu1
initknu4:ret


skokinik label     byte                   ;* tabulka skokñ pro INITKEY
         db        80h+14                   ; testuje se AX
         dw        "CD"
         dw        offset initkdc           ; barevnò displej
         dw        "MD"
         dw        offset initkdm           ; monochromatickò displej
         dw        "CF"
         dw        offset initkfc           ; áe®tina bez diakritiky
         dw        "KF"
         dw        offset initkfk           ; áe®tina Kamenickòch
         dw        "LF"
         dw        offset initkfl           ; áe®tina Latin 2
         dw        "0M"
         dw        offset initkm0           ; vypnut° my®i
         dw        "QQ"
         dw        offset initkqq           ; zobrazen° pozn†mek
         dw        "DS"
         dw        offset initksd           ; t©°dàn° podle data a áasu
         dw        "ES"
         dw        offset initkse           ; t©°dàn° podle p©°pony
         dw        "NS"
         dw        offset initksn           ; t©°dàn° podle jmÇna
         dw        "SS"
         dw        offset initkss           ; t©°dàn° podle velikosti
         dw        "XS"
         dw        offset initksx           ; net©°dàn° adres†©
         dw        "82"
         dw        offset initk28           ; nastaven° ©†dkov†n° VGA 28
         dw        "34"
         dw        offset initk43           ; nastaven° ©†dkov†n° EGA 43

         db        00h+21                   ; testuje se AL
         db        "A"
         dw        offset initka            ; nastaven° atributñ okna
         db        "B"
         dw        offset initkb            ; zap/vyp n†povàdy
         db        "C"
         dw        offset initkc            ; p©°kaz
         db        "G"
         dw        offset initkg            ; komunikaán° porty pro vòzvu
         db        "H"
         dw        offset initkh            ; vypnut° funkce SHIFT
         db        "I"
         dw        offset initki            ; £schova historie
         db        "J"
         dw        offset initkj            ; automatickò kalend†©
         db        "K"
         dw        offset initkk            ; standardn° kl†vesnice 83/84
         db        "L"
         dw        offset initkl            ; zap/vyp neaktivn°ho okna
         db        "N"
         dw        offset initkn            ; uëivatelskÇ menu
         db        "O"
         dw        offset initko            ; zap/vyp obou oken
         db        "P"
         dw        offset initkp            ; rezidentn° reëim
         db        "Q"
         dw        offset initkq            ; trojsloupcovÇ zobrazen°
         db        "R"
         dw        offset initkr            ; stmaven° displeje
         db        "T"
         dw        offset initkt            ; p©epnut° aktivn°ho okna
         db        "U"
         dw        offset initku            ; z†màna oken
         db        "V"
         dw        offset initkv            ; skrytÇ soubory zap.
         db        "W"
         dw        offset initkw            ; nastaven° velikosti okna
         db        "X"
         dw        offset initkx            ; prov†dàn° povelñ pomoc° INT 2eh
         db        "Y"
         dw        offset initky            ; zobrazuje se n†và®t° disku
         db        "Z"
         dw        offset initkz            ; zad†n° domovskÇho adres†©e

         db        0

; -----------------------------------------------------------------------------
;                      Inicializace barev displeje
; -----------------------------------------------------------------------------
public   initcolor

initcolor:                                ;* inicializace barev displeje

         mov       al,ds:[conf7]
         call      egaget                   ; test stavu displeje
         jc        initcol0                 ; nen° karta EGA
         push      ax
         xor       al,ds:[conf7]            ; je jinò stav neë poëadovanò ?
         pop       ax
         jz        initcol9                 ; nebyla zmàna m¢du
                                          ;* zmàna ©†dkov†n°
         push      ax
         call      egaset                   ; zmàna zobrazen° displeje
         pop       ax

                                          ;* je®tà jedna zmàna pro VGA kartu
         xor       al,ds:[conf7]            ; je videom¢d jië spr†vnà ?
         jz        initcol9                 ; videom¢d je jië spr†vnà
         call      egaset                   ; znovu zmàna zobrazen° displeje

initcol9:;test      byte ptr ds:[conf7],1    ; ©†dkov†n° 28 ©†dkñ ?
         ;jz        initcol0                 ; nen° ©†dkov†n° 28 ©†dkñ
         ;call      egaask                   ; zji®tàn° poátu ©†dkñ
         ;cmp       dh,16                    ; je 16 linek na znak ?
         ;jne       initcol0                 ; nen° 16 linek na znak
         ;
         ;                                 ;* nastaven° fontñ 8*14 pro VGA
         ;mov       ax,1111h                 ; fonty 8x14
         ;xor       bl,bl
         ;int       10h                      ; nastaven° ©†dkov†n°
         ;mov       ax,100h
         ;mov       cx,0607h
         ;int       10h                      ; nastaven° zobrazen° kurzoru
         ;call      egaget                   ; aktualizace p©°znaku ©†dkov†n°

initcol0:push      cs
         pop       ds

         test      byte ptr ds:[parrez],2   ; je opakovanò start ?
         jne       initcol6                 ; je opakovanò start
                                          ;* prvn° instalace barev
         lea       si,[colcol]              ; barvy pro barevnò displej
         test      byte ptr ds:[flags],20h  ; je áernob°lò displej ?
         jz        initcol1                 ; nen° áernob°lò displej
         lea       si,[colbw]               ; barvy pro áernob°lò displej
initcol1:lea       di,[coldisp]             ; aktu†ln° barvy displeje
         mov       cx,19                    ; dÇlka tabulky barev
         rep       movsb                    ; p©enos tabulky
                                          ;* instalace uëivatelskòch barev
         lea       si,[helpbuf]             ; adresa s textem
         lea       di,[coldisp]             ; barvy displeje
         mov       cx,19                    ; poáet bajtñ v tabulce
initcol2:mov       bl,ds:[di]
         call      initcln                  ; áten° á°sla
         mov       ds:[di],bl               ; nastaven° novÇho atributu
         inc       di
         loop      initcol2                 ; dal®° atribut barvy
initcol6:test      byte ptr ds:[conf7],8    ; je zvò®enò jas EGA ?
         jz        initcol7                 ; nen° zvò®en° jas EGA
         test      byte ptr ds:[conf6],8    ; je karta EGA ?
         jz        initcol7                 ; nen° karta EGA
         mov       ax,1003h
         xor       bl,bl
         int       10h                      ; zvò®enò jas EGA
initcol7:
         ret

initcln: lodsb                              ; dal®° znak
         cmp       al,"@"                   ; je p©ep°naá pro zvò®enò jas ?
         jne       initcln1
         or        byte ptr ds:[conf7],8    ; p©°znak zvò®enÇho jasu EGA
initcln1:call      highcase                 ; p©evod na velkÇ p°smeno
         or        al,al                    ; je konec textu ?
         jz        initcln3                 ; konec textu
         cmp       al,13
         je        initcln3                 ; konec ©†dku
         cmp       al,","
         je        initcln4                 ; je oddàlovaá dat
         cmp       al," "
         jbe       initcln                  ; oddàlovaá

         cmp       al,"A"
         jb        initcln2
         sub       al,7
initcln2:and       al,0fh                   ; korekce na á°slici
         mov       cl,4
         shl       bl,cl
         or        bl,al                    ; novò atribut
         jmp       short initcln            ; dal®° znak

initcln3:dec       si                       ; n†vrat posledn°ho znaku
initcln4:ret

; -----------------------------------------------------------------------------
;                      Inicializace fontu textñ
; -----------------------------------------------------------------------------
public   inittext

inittext:                                 ;* inicializace fontñ textñ

         test      byte ptr ds:[flags],8    ; je permanentn° reëim ?
         jz        inittxt0                 ; nen° rezidentn° reëim
         test      byte ptr ds:[parrez],10h ; jsou fonty p©ekonvertovanÇ ?
         jnz       inittxt2                 ; fonty jsou p©ekonvertovanÇ
inittxt0:lea       si,[zactxt]              ; zaá†tek textñ programu
         mov       di,si
         lea       cx,[konectxt]            ; konec textñ programu
         sub       cx,si                    ; dÇlka textñ programu
inittxt1:lodsb
         call      konvfnt                  ; konverze fontu
         stosb
         loop      inittxt1                 ; dal®° znak
         or        byte ptr ds:[parrez],10h ; p©°znak p©ekonvertovanòch fontñ
inittxt2:ret

; -----------------------------------------------------------------------------
;                      Inicializace bufferñ textu
; -----------------------------------------------------------------------------
public   initbuf

initbuf:                                  ;* inicializace parametrñ bufferñ
         lea       di,[comlin]             ; definice povelovÇho ©†dku
         lea       ax,[buftxt]
         stosw                              ; offset adresy bufferu
         mov       ax,cs
         stosw                              ; nastaven° segmentu adresy
         mov       ax,123
         stosw                              ; maxim†ln° poáet znakñ
                                          ;* inicializace bufferu pro volby
         lea       di,[sellin]             ; definice pro editaci voleb
         lea       ax,[selbuf]
         stosw                              ; offset adresy bufferu
         mov       ax,cs
         stosw                              ; nastaven° segmentu adresy
         mov       ax,123
         stosw                              ; maxim†ln° poáet znakñ

         ret

; -----------------------------------------------------------------------------
;                         Inicializace kl†vesnice
; -----------------------------------------------------------------------------
public   initkin

initkin:                                  ;* inicializace vstupu z kl†vesnice
         push      ds
         xor       ax,ax
         mov       ds,ax                    ; DS <- 0
         inc       ax                       ; AX <- 1
         test      byte ptr ds:[0496h],10h  ; je instalov†na kl†vesnice 101/102?
         pop       ds
         jz        initkin1                 ; nen° kl†vesnice 101/102
         test      byte ptr ds:[conf3],4    ; je standardn° kl†vesnice ?
         jnz       initkin1                 ; je standardn° kl†vesnice
ifndef   keystd
         add       ax,1010h                 ; zvò®en° k¢du o 10h
endif
initkin1:mov       word ptr ds:[keystat],ax ; nastaven° k¢dñ pro vstup z kl†v.
         ret

; -----------------------------------------------------------------------------
;                      Instalace my®i
; -----------------------------------------------------------------------------
public   initmouse,initmous1

initmouse:                                ;* inicializace obsluhy my®i
         sti
         pushf
         and       byte ptr cs:[config],not 40h ; zru®en° p©°znaku my®i
         test      byte ptr cs:[conf3],8    ; je z†kaz pouëit° my®i ?
         jnz       inmouse4                 ; pouëit° my®i zak†z†no

         push      es
         push      bx
         mov       ax,3533h
         int       21h                      ; poskytnut° adresy INT 33h
         mov       ax,es
         pop       bx
         pop       es
         cmp       ax,60h
         jb        inmouse4                 ; nen° my®
         cmp       ax,0f000h
         jae       inmouse4

         sti
         xor       ax,ax
         int       33h                      ; je nainstalov†na my® ?
         inc       ax                       ; pokud je AX=-1, je my®
         jnz       inmouse4                 ; nen° my®
         or        byte ptr cs:[config],40h ; nastaven° p©°znaku my®i
         popf

initmous1:                                ;* opakovan† inicializace
         pushf
         test      byte ptr cs:[config],40h ; je my® instalovan† ?
         jz        inmouse4                 ; my® nen° instalovan†
                                          ;* definov†n° kurzoru my®i
         mov       ax,0ah
         xor       bx,bx                    ; p©°znak softwarovÇho kurzoru
         mov       cx,0ffffh                ; maska obrazovky (AND)
         mov       dx,7700h                 ; maska kurzoru (XOR)
         sti
         int       33h
                                          ;* instalace rozmàrñ okna
;         mov       ax,7
;         xor       cx,cx                    ; minim†ln° pozice
;         mov       dx,79*8                  ; maxim†ln° pozice
;         int       33h                      ; definov†n° horizont†ln°ch rozmàrñ
         mov       ax,8
         xor       cx,cx                    ; minim†ln° ©†dek
         xor       dh,dh
         mov       dl,cs:[displ]
         shl       dx,1
         shl       dx,1
         shl       dx,1                     ; maxim†ln° ©†dek * 8
         sti
         int       33h                      ; definov†n° vertik†ln°ch rozmàrñ
                                          ;* nastaven° st©edn° pozice
         mov       ax,4
         xor       cx,cx
         mov       cl,byte ptr cs:[mousepoz]
         add       cx,cx
         add       cx,cx
         add       cx,cx                    ; pozice
         xor       dx,dx
         mov       dl,byte ptr cs:[mousepoz+1]
         add       dx,dx
         add       dx,dx
         add       dx,dx                    ; ©†dek
         sti
         int       33h                      ; nastaven° pozice kurzoru

         call      mouseon                  ; zapnut° my®i

inmouse4:popf
         push      cs
         pop       ds
         push      cs
         pop       es
         ret

; -----------------------------------------------------------------------------
initstosb:                                ;* vymaz†n° inicializaán°ch dat

         rep       stosb                    ; vymaz†n° dat
         ret

; -----------------------------------------------------------------------------
;                      Odinstalov†n° programu
; -----------------------------------------------------------------------------
public   deinit

deinit:
         push      si
         push      ax
         push      dx
         push      cs
         pop       ds

         and       byte ptr ds:[vyzvycom],not 40h ; zru®en° poëadavku vòzvy COM
         cmp       byte ptr ds:[vyzvacit],0 ; je vòzva aktivn° ?
         je        deinit00                 ; vòzva nen° aktivn°
         mov       byte ptr ds:[vyzvacit],0 ; zru®en° p©°znaku vòzvy
         call      soundoff                 ; vypnut° zvuku
deinit00:


;                                          ;* n†vrat p©eru®en° od my®i
;         test      byte ptr ds:[config],40h ; je nainstalov†na my® ?
;         jz        deinit1                  ; my® nen° nainstalov†na
;         xor       cx,cx
;         mov       ax,000ch
;         int       33h                      ; z†kaz p©eru®en° od my®i
;         call      mouseoff                 ; vypnut° my®i
;         mov       ax,0000h
;         int       33h                      ; reset ovladaáe my®i
                                          ;* n†vrat p©eru®en°
deinit1: mov       ax,2508h
         lds       dx,cs:[old08]
         int       21h
         mov       ax,2509h
         lds       dx,cs:[old09]
         int       21h
         mov       ax,2510h
         lds       dx,cs:[old10]
         int       21h
         mov       ax,2521h
         lds       dx,cs:[old21]
         int       21h

         push      cs
         pop       ds

         mov       ax,2524h
         lea       dx,[intx24]              ; p©echodn† obsluha INT 24h
;         lds       dx,cs:[old24]
         int       21h


         push      word ptr cs:[flags]
         and       byte ptr cs:[flags],not 4 ; vypnut° n†povàdy
         xor       dx,dx                    ; poá†teán° adresa pro zobrazen°
         call      getdispcx
         inc       cx                       ; poáet ©†dkñ displeje
deinit3:
         push      cx
         mov       cl,80
         call      radeknul
         inc       dh
         pop       cx
         loop      deinit3
         pop       word ptr cs:[flags]
         call      mouseoff                 ; vypnut° my®i

         mov       dx,cs:[aktkurz]          ; pñvodn° pozice kurzoru
         cmp       dh,cs:[displ]
         jbe       deinit4
         mov       dh,cs:[displ]            ; omezen° na posledn° ©†dek
deinit4: xor       al,al
         call      outch1                   ; nastaven° pñvodn° pozice kurzoru

deinit2: call      getakt
         mov       si,ds:[bp+4]             ; adresa cesty
         call      aktdir                   ; nastaven° aktivn° cesty

                                          ;* uvolnàn° bloku s daty
         mov       es,cs:[datseg]           ; alokaán° blok dat
         mov       ah,49h
         int       21h                      ; uvolnàn° pamàti
         push      cs
         pop       es
                                          ;* n†vrat adresy obsluhy INT 1Bh
         mov       ax,251bh
         lds       dx,cs:[old1b]
         int       21h

         mov       ax,cs:[dark]
         mov       cs:[darkcit],ax
         call      testkey                  ; rozsv°cen° displeje

         push      cs
         pop       ds
         pop       dx
         pop       ax
         pop       si
         ret

; -----------------------------------------------------------------------------
public   storecnf

storecnf:                                 ;* uloëen° konfigurace do pamàti
                                            ; VSTUP: AL=ukonáovac° k¢d

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      cs
         pop       ds
         push      cs
         pop       es
         call      storekall                ; £schova obou kurzorñ

         mov       al,ds:[pozr]             ; pozice pravÇho okna
         mov       ah,ds:[pozl]             ; pozice levÇho okna
         mov       word ptr ds:[pozwr],ax   ; £schova poá†teán°ch pozic oken

         mov       al,ds:[flagsl]           ; uschovanÇ p©°znaky levÇho okna
         mov       ds:[flags0l],al          ; nastaven° p©°znakñ levÇho okna
         mov       al,ds:[flagsr]           ; uschovanÇ p©°znaky pravÇho okna
         mov       ds:[flags0r],al          ; nastaven° p©°znakñ pravÇho okna
                                          ;* £schova parametrñ oken
         mov       al,ds:[setwl]
         mov       ds:[setwls],al
         mov       al,ds:[setwr]
         mov       ds:[setwrs],al

         call      getnakt                  ; neaktivn° okno
         mov       si,ds:[bp+4]
         lea       di,[path]                ; cesta k neaktivn°mu oknu
         call      transtxt                 ; p©enos textu
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   storekur,storekall,storefile

storekur:                                 ;* £schova nastaven° kurzoru na soubor
                                            ; VSTUP: BP=adresa definice okna


         pushf
         push      si
         push      ds
         call      getkurz                  ; poskytnut° adresy souboru
         jc        storeku2                 ; nen° platnò kurzor
         call      storefile                ; uloëen° poloëky
storeku2:pop       ds
         pop       si
         popf
         ret

storefile:                                ;* £schova poloëky DS:SI

         push      ax
         push      bx
         push      cx
         push      si
         push      di
         push      es
         push      cs
         pop       es

         lea       di,[namel]               ; jmÇno souboru L
         lea       bx,[firstwl]
         cmp       bp,offset tabr           ; je to pravÇ okno ?
         jne       storek2                  ; je aktivn° levÇ okno
         lea       di,[namer]               ; jmÇno souboru R
         lea       bx,[firstwr]
storek2: mov       cx,20                    ; dÇlka poloëky souboru
         rep       movsb                    ; p©enos poloëky souboru
         mov       ax,cs:[bp+9]             ; prvn° poloëka
         mov       cs:[bx],ax               ; £schova prvn° poloëky

storek3: pop       es
         pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

storekall:                                ;* uloëen° obou kurzorñ
         push      bp
         call      getnakt
         call      storekur                 ; £schova pozice kurzoru
         call      getakt
         call      storekur                 ; £schova pozice kurzoru
         pop       bp
         ret

; -----------------------------------------------------------------------------
;                      Inicializace programu
; -----------------------------------------------------------------------------

                                            ; v podprogramech nutno zachovat
                                            ; segmentovÇ registry DS,ES <- CS !

public   init
init:                                     ;* start programu (inicializace)
         push      cs
         pop       ds
         push      cs
         pop       es
         cld                                ; ukazatel p©enosu nahoru
         sti                                ; povolen° p©eru®en°
         or        byte ptr ds:[parrez],0ch ; ignor. p©eru®. i chyby
         mov       word ptr ds:[parbreak],0
         mov       dx,80h
         mov       ah,1ah
         int       21h                      ; nastaven° adresy DTA

         call      chkver                   ; kontrola verze operaán°ho systÇmu
         call      initmem                  ; inicializace pamàti a z†sobn°ku
         call      initcountry              ; inicializace n†rodn°ch informac°
;         call      initmouse                ; inicializace obsluhy my®i
         call      initmod                  ; inicializace displeje
         mov       byte ptr ds:[displ],24   ; posledn° ©†dek displeje = 24
;         call      egaget                   ; nastaven° poátu ©†dkñ displeje
                                          ;* odtuto jië nen° chybovò n†vrat
         call      initint                  ; inicializace obsluh p©eru®en°
         call      initpth0                 ; inicializace aktivn°ho adres†©e
         call      inithome                 ; inicializace domovskÇho adres†©e
         call      inituse                  ; inicializace uëivatelskÇ n†povàdy
         call      initcus                  ; inicializace uëivatelskòch barev
         call      inithis                  ; inicializace historie povelñ
         call      initrez                  ; inicializace rezidentn°ch dat
         call      initwpar                 ; inicialiace parametrñ oken
         call      initpath                 ; inicializace neaktivn°ho adres†©e
         call      initkey                  ; inicializace zad†n° z p©°kaz.©†dku
                                          ;* zde je jië nastavena konfigurace
         call      initcolor                ; inicializace barev displeje
         call      initkin                  ; inicializace vstupu z kl†vesnice

         lea       si,[buftxt]              ; buffer povelovÇho ©†dku
         cmp       byte ptr ds:[si],0       ; je zadanò povel ?
         je        init8                    ; nen° zadanò povel
         jmp       execute                  ; proveden° povelu
init8:
         call      inittext                 ; inicializace fontu textñ
         call      initbuf                  ; inicializace bufferñ textu
         call      initmouse                ; inicializace obsluhy my®i
;         call      initwin
;         mov       word ptr ds:[parbreak],-2 ; p©°znak ignorov†n° chyb
         mov       word ptr cs:[parbreak],0 ; zru®en° p©°znaku chyby
         and       byte ptr cs:[parrez],not 8 ; zru®en° p©°znaku ignor. chyb

         cmp       byte ptr cs:[buffedi2],0 ; je zad†na editace ?
         jne       init9                    ; je zad†na editace

         call      windret                  ; zobrazen° obou oken
init9:
         and       byte ptr cs:[parrez],not 4 ; zru®en° p©°znaku ignor. p©eru®en°
         jmp       main                     ; hlavn° obsluha programu



code     ends

         end       strt

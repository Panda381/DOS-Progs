
; ##############################################################################
; #                                                                            #
; #                          D O S   M a n a ‘ e r                             #
; #                 program pro operace se soubory a s disky                   #
; #                                                                            #
; #                  >>> Autor: ing. Miroslav Nˆme‡ek <<<                      #
; #                                                                 verze 1.00 #
; ##############################################################################

; *****************************************************************************
;
;                    —vodn¡ a inicializa‡n¡ ‡ st programu
;
; *****************************************************************************
public   strt,konecprg,adrini,datarez,parbreak

extrn    main:near,endshell:word,topseg:word,segend:word
extrn    zasob:word,errmem:byte,inidata:byte,datseg:word
extrn    outch1:near
extrn    highcase:near,loadpath:near
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
extrn    zacmaz:byte,konecmaz:byte,inidend:byte
extrn    cisvram:byte
extrn    outch10:near,namel:byte,namer:byte,adrpolsi:near
extrn    firstwl:word,firstwr:word,old24:dword,int24:near
extrn    countryh:dword,outbuf:byte,col1:byte,colbw:byte
extrn    prevcs:byte,zactxt:byte,konectxt:byte,konvfnt:near
extrn    config:byte,skokax:near,poclin:word
extrn    execute:near,keyf102:near,windret:near,licence:dword
extrn    flags0l:byte,flags0r:byte,testaktw:near
extrn    hlpuse:byte,soubuse:byte,zacmazr:byte,modiseg:near,getseg:near
extrn    soubcol:byte,helpbuf:byte,colcol:byte,coldisp:byte
extrn    getkurz:near,conf2:byte,prodldem:near,setwl:byte,setwr:byte
extrn    setwls:byte,setwrs:byte,mouseon:near,mouseoff:near,mouseget:near
extrn    mousepoz:word,mainout:near,displ:byte,egaget:near,egaset:near
extrn    egaask:near,getdispcx:near,radeknul:near,delvram:word
extrn    conf3:byte,verze:word

code     segment   public
         assume    cs:code,ds:code
         org       100h                     ; po‡ te‡n¡ adresa COM

strt:    jmp       init                     ; start programu

konecprg dw        offset zacmaz            ; konec programu

adrini   dw        offset inidata           ; adresa inicializa‡n¡ch dat

; -----------------------------------------------------------------------------
;                      start programu - rezidentn¡ modul
; -----------------------------------------------------------------------------
public   execx

execx:                                    ;* start p©¡kazu opera‡n¡ho syst‚mu
                                            ; VSTUP: [80h]: p©¡kaz pro system

         push      cs
         pop       ds                       ; DS <- CS
         push      cs
         pop       es                       ; ES <- CS
                                          ;* nastaven¡ pomocn‚ho z sobn¡ku
         mov       bx,cs
         mov       cx,offset zasobrez       ; z sobn¡k pro rezidentn¡ modul
         mov       ss,bx
         mov       sp,cx
                                          ;* pokud nen¡ p©¡kaz, konec programu
         cmp       byte ptr cs:[80h],0      ; je p©¡kazov˜ © dek ?
         jne       execx1                   ; je nˆco v p©¡kazov‚m © dku ?
execx0:                                   ;* je konec programu
         push      ax
         mov       ax,2523h
         lds       dx,cs:[old23]
         int       21h                      ; n vrat p©eru¨en¡ CTRL-BREAK
         mov       ax,2522h
         lds       dx,[old22]
         int       21h                      ; n vrat obsluhy INT 22h
         pop       ax
         mov       ah,4ch                   ; funkce ukon‡en¡ programu
         int       21h                      ; ukon‡en¡ programu

execx1:                                   ;* zmen¨en¡ p©idˆlen‚ pamˆti
         test      byte ptr cs:[parrez],1   ; je rezidentn¡ re‘im ?
         jnz       execx13                  ; je rezidentn¡ re‘im
         lea       bx,[inidend]             ; konec rezidentn¡ch dat
         sub       bx,offset inidata        ; d‚lka rezidentn¡ch dat
         add       bx,offset datarez        ; konec rezidentn¡ch dat
         add       bx,15                    ; zaokrouhlen¡
         shr       bx,1
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; p©epo‡et na odstavce
         mov       ah,4ah
         int       21h                      ; modifikace pamˆti
         jnc       execx13                  ; blok pamˆti OK
execx82: jmp       execx8                   ; chyba - zni‡en blok pamˆti
                                          ;* nalezen¡ specifikace cesty
execx13: push      cs
         pop       es
         mov       ax,cs:[2ch]              ; adresa prost©ed¡
         mov       ds,ax                    ; segment prost©ed¡
         xor       si,si                    ; ukazatel cesty
execx5:  lea       di,[comspec]             ; ukazatel reference COMSPEC
         cmp       byte ptr ds:[si],0       ; je ji‘ konec prost©ed¡ ?
         je        execx82                  ; konec prost©ed¡ - chyba
         mov       cx,8                     ; po‡et znak– k porovn n¡
execx51: lodsb
         cmp       al,"a"                   ; je znak men¨¡ ne‘ "a" ?
         jb        execx52                  ; nen¡ mal‚ p¡smeno
         cmp       al,"z"                   ; je znak vˆt¨¡ ne‘ "z" ?
         ja        execx52                  ; nen¡ mal‚ p¡smeno
         sub       al,32                    ; korekce na velk‚ p¡smeno
execx52: scasb                              ; porovn n¡ s referen‡n¡m znakem
         jne       execx53                  ; nen¡ spr vn˜ ©etˆzec
         loop      execx51                  ; dal¨¡ znak ©etˆzce
         mov       dx,si                    ; adresa ©etˆzce
         jmp       short execx6             ; proveden¡ p©¡kazu
execx53:                                  ;* nalezen¡ konce ©etˆzce
         cmp       byte ptr ds:[si-1],0     ; byl konec ©etˆzce ?
         je        execx5                   ; dal¨¡ ©etˆzec
         inc       si
         jmp       short execx53

execx6:                                   ;* nastaven¡ adres parametr– EXEC
         push      ds
         push      dx
         push      cs
         pop       ds

         mov       ax,2523h
         lds       dx,cs:[old23]
         int       21h                      ; n vrat p©eru¨en¡ CTRL-BREAK

         pop       dx
         pop       ds

         lea       bx,[paramexec]           ; parametry EXEC
         mov       cs:[bx],ds               ; adresa prost©ed¡ pro podproces
         mov       byte ptr cs:[bx+2],80h   ; offset p©¡kazov‚ho © dku
         mov       cs:[bx+4],cs             ; segment p©¡kazov‚ho © dku
         mov       byte ptr cs:[bx+6],5ch   ; offset prvn¡ho FCB
         mov       byte ptr cs:[bx+8],cs    ; segment prvn¡ho FCB
         mov       byte ptr cs:[bx+10],6ch  ; offset druh‚ho FCB
         mov       byte ptr cs:[bx+12],cs   ; segment druh‚ho FCB
                                          ;* proveden¡ p©¡kazu
ifndef   demo
         mov       ax,4b00h
         int       21h
endif

execx63: mov       bx,cs
         lea       cx,[zasobrez]            ; z sobn¡k pro rezidentn¡ modul
         mov       ss,bx
         mov       sp,cx
         push      cs
         pop       ds
         pushf
         mov       ax,2524h
         lea       dx,[intx24]              ; p©echodn  obsluha INT 24h
         int       21h
         mov       ax,2523h
         lea       dx,[int23]
         int       21h                      ; nastaven¡ obsluhy INT 23h
         popf

         jnc       execx9                   ; operace provedena OK
execx8:                                   ;* program COMMAND.COM nespustiteln˜
         push      cs
         pop       ds
         lea       dx,[errcomm]             ; chyba "COMMAND.COM nespustiteln˜"
         mov       ah,9
         int       21h                      ; zobrazen¡ chyby
         call      exexchg                  ; dotaz na dal¨¡ postup
         jc        execx9                   ; p©eru¨en¡ operace
         jmp       execx13                  ; opakov n¡ pokusu
                                          ;* n vrat do programu DOSMAN
execx9:  push      cs
         pop       ds
         push      cs
         pop       es
         cld
         mov       byte ptr ds:[80h],0      ; zru¨en¡ p©¡kazov‚ho © dku

         jmp       init                     ; inicializace programu


int22:
execx2e5:clc
         jmp       execx63                  ; n vrat do programu


public   intx24

intx24:                                   ;* p©echodn  obsluha INT 24h
         xor       al,al                    ; p©¡znak ignorov n¡ chyby
         iret                               ; n vrat z obsluhy


public   int23

int23:                                    ;* u‘ivatelsk‚ p©eru¨en¡ CTRL-BREAK
                                          ;* je zde tak‚ obsluha INT 1Bh

         cmp       word ptr cs:[parbreak],0 ; je ji‘ nˆjak  chyba ?
         jne       int233                   ; je ji‘ chyba
int232:  mov       word ptr cs:[parbreak],-1 ; k¢d - u‘ivatelsk‚ p©eru¨en¡
int233:  iret

public   exexchg
exexchg:                                  ;* po‘adavek dal¨¡ operace
                                            ; VSTUP: CY=p©eru¨en¡
         push      ax
         push      dx
exexchg2:xor       ah,ah
         int       16h                      ; vstup znaku z kl vesnice
         cmp       al,13                    ; je <Enter> ?
         je        exexchg3                 ; je <Enter>=opakov n¡ operace
         cmp       al,27                    ; je <Esc> ?
         jne       exexchg2                 ; nen¡ <Esc> = nov˜ vstup
         stc                                ; p©¡znak p©eru¨en¡ operace
exexchg3:pop       dx
         pop       ax
         ret

errcomm  db        'Soubor COMMAND.COM neni mozne zavest do pameti !',13,10
         db        'Stisknete <Enter>=novy pokus, <Esc>=preruseni.',13,10,'$'
comspec  db        'COMSPEC='               ; specifikace COMSPEC

paramexec db       14 dup(0)                ; parametry pro spu¨tˆn¡ programy

public   segrez,parrez
segrez   dw        0                        ; segment rezidentn¡ch dat

public   old22
old22    dd        0                        ; p–vodn¡ adresa obsluhy INT 22h
old23    dd        0                        ; p–vodn¡ adresa obsluhy INT 23h
parbreak dw        0                        ; 1=p©¡znak u‘iv. p©eru¨en¡ BREAK
parrez   db        0                        ;  (bit 0: 1=je rezidentn¡ re‘im)
                                            ;   bit 1: 1=byl ji‘ prvn¡ start


initst1  label     near

         dw        80 dup (0)               ; z sobn¡k pro rezidentn¡ modul
zasobrez label     word                     ; z sobn¡k
;         dw        0

datarez  label     byte                   ;* za‡ tek rezidentn¡ch dat


;              modul DOSMINI.ASM pro program DOSMAN - inicializace

; *****************************************************************************
;
;                        Inicializace programu p©i startu
;
; *****************************************************************************

                                            ; v podprogramech nutno zachovat
                                            ; segmentov‚ registry DS,ES <- CS !

public   init
init:                                     ;* start programu (inicializace)
         push      cs
         pop       ds
         push      cs
         pop       es
         cld                                ; ukazatel p©enosu nahoru
         sti                                ; povolen¡ p©eru¨en¡
         mov       word ptr ds:[parbreak],-2 ; p©¡znak ignorov n¡ chyb
         mov       dx,80h
         mov       ah,1ah
         int       21h                      ; nastaven¡ adresy DTA

         call      chkver                   ; kontrola verze opera‡n¡ho syst‚mu
         call      initmem                  ; inicializace pamˆti a z sobn¡ku
;         call      initmouse                ; inicializace obsluhy my¨i
         call      initmod                  ; inicializace displeje
         mov       byte ptr ds:[displ],24   ; posledn¡ © dek displeje = 24
;         call      egaget                   ; nastaven¡ po‡tu © dk– displeje
                                          ;* odtuto ji‘ nen¡ chybov˜ n vrat
         call      initint                  ; inicializace obsluh p©eru¨en¡
         call      initpth0                 ; inicializace aktivn¡ho adres ©e
;         call      inithome                 ; inicializace domovsk‚ho adres ©e
;         call      inituse                  ; inicializace u‘ivatelsk‚ n povˆdy
;         call      initcus                  ; inicializace u‘ivatelsk˜ch barev
         call      initrez                  ; inicializace rezidentn¡ch dat
         call      initwpar                 ; inicialiace parametr– oken
         call      initpath                 ; inicializace neaktivn¡ho adres ©e
;         call      initkey                  ; inicializace zad n¡ z p©¡kaz.© dku
                                          ;* zde je ji‘ nastavena konfigurace
         call      initcolor                ; inicializace barev displeje

         lea       si,[buftxt]              ; buffer povelov‚ho © dku
         cmp       byte ptr ds:[si],0       ; je zadan˜ povel ?
         je        init8                    ; nen¡ zadan˜ povel
         jmp       execute                  ; proveden¡ povelu
init8:
;         call      inittext                 ; inicializace fontu text–
         call      initbuf                  ; inicializace buffer– textu
         call      initkin                  ; inicializace vstupu z kl vesnice
         call      initmouse                ; inicializace obsluhy my¨i
;         call      initwin
         mov       word ptr ds:[parbreak],-2 ; p©¡znak ignorov n¡ chyb
;         mov       word ptr cs:[parbreak],0 ; zru¨en¡ p©¡znaku chyby
         call      windret                  ; zobrazen¡ obou oken
         jmp       main                     ; hlavn¡ obsluha programu

; -----------------------------------------------------------------------------
;                     Kontrola verze opera‡n¡ho syst‚mu
; -----------------------------------------------------------------------------
public   chkver

chkver:                                   ;* kontrola verze opera‡n¡ho syst‚mu
         mov       ah,30h                   ; funkce poskytnut¡ ‡¡sla verze OS
         int       21h                      ; poskytnut¡ ‡¡sla verze OS
         xchg      al,ah                    ; z mˆna ‡¡sla verze a podverze
         mov       ds:[verze],ax            ; £schova ‡¡sla verze OS
         ret

; -----------------------------------------------------------------------------
;                            Inicializace pamˆti
; -----------------------------------------------------------------------------
public   initmem

initmem:                                  ;* inicializace pamˆti

                                          ;* zmen¨en¡ bloku s programem
         mov       bx,offset endshell       ; konec programu
         add       bx,15                    ; zaokrouhlen¡
         mov       cl,4
         shr       bx,cl                    ; p©epo‡et na odstavce
         mov       ah,4ah
         int       21h                      ; zmen¨en¡ bloku s programem
         jc        initmem1                 ; chyba - nedostatek pamˆti
                                          ;* p©idˆlen¡ bloku pro data
         mov       ah,48h
         mov       bx,0ffffh                ; max. blok
         int       21h                      ; dotaz na max. velikost bloku
         mov       ah,48h
         int       21h                      ; p©idˆlen¡ skute‡n‚ho bloku pamˆti
         jc        initmem1                 ; chyba - nedostatek pamˆti
         cmp       bx,400h                  ; nejmen¨¡ blok = 16 KB
         jb        initmem1                 ; nedostatek pamˆti
         mov       ds:[datseg],ax           ; aloka‡n¡ blok dat
         add       ax,bx                    ; segment konec bloku
         sub       ax,100h                  ; ode‡ten¡ velikosti z sobn¡ku
         mov       ds:[segend],ax           ; segment konce p©idˆlen‚ho bloku
                                          ;* inicializace nov‚ho z sobn¡ku
         pop       bx                       ; n vratov  adresa z podprogramu
         mov       cx,1000h                 ; offset konce z sobn¡ku
         mov       ss,ax                    ; nov˜ segment z sobn¡ku
         mov       sp,cx                    ; nov˜ ukazatel na konce z sobn¡ku
                                          ;* vymaz n¡ oblasti dat
         push      cx                       ; £schova vrcholu z sobn¡ku
         push      word ptr ds:[verze]      ; £schova verze
         push      word ptr ds:[datseg]     ; £schova po‡ te‡n¡ho segmentu
         push      word ptr ds:[segend]     ; £schova koncov‚ho segmentu
         mov       di,offset zacmaz         ; za‡ tek dat k vymaz n¡
         test      byte ptr ds:[parrez],3   ; je opakovan˜ start ?
         je        initmem2                 ; nen¡ opakovan˜ start
         mov       di,offset zacmazr        ; za‡ tek dat k vymaz n¡
initmem2:mov       cx,offset konecmaz       ; konec dat k maz n¡
         sub       cx,di                    ; d‚lka dat k vymaz n¡
         xor       al,al                    ; AL <- 0 mazac¡ bajt
         rep       stosb                    ; vymaz n¡ oblasti dat
         pop       word ptr ds:[segend]     ; n vrat koncov‚ho segmentu
         pop       word ptr ds:[datseg]     ; n vrat po‡ te‡n¡ho segmentu
         pop       word ptr ds:[verze]      ; n vrat verze syst‚mu
         pop       word ptr ds:[zasob]      ; n vrat vrcholu z sobn¡ku
         mov       ax,ds:[datseg]           ; za‡ tek alok. bloku dat
         mov       ds:[topseg],ax           ; segment za‡ tku voln‚ pamˆti
initmem3:jmp       bx                       ; n vrat z podprogramu

                                          ;* chyba - nedostatek pamˆti
initmem1:pop       ax                       ; zru¨en¡ n vratov‚ adresy
         lea       dx,[errmem]              ; text chyby nedostatku pamˆti
         mov       ah,9                     ; funkce zobrazen¡ textu
         int       21h                      ; zobrazen¡ chybov‚ho textu
         mov       ax,4c01h                 ; funkce n vratu p©i chybˆ pamˆti
         int       21h                      ; konec programu p©i chybˆ pamˆti

; -----------------------------------------------------------------------------
;                     Inicializace videom¢du, test displeje
; -----------------------------------------------------------------------------
public   initmod

initmod:                                  ;* inicializace videom¢du

                                          ;* test, zda je videom¢d ji‘ nastaven
         mov       ah,0fh                   ; funkce dotazu na videom¢d
         int       10h                      ; dotaz na nastaven˜ videom¢d
         and       al,7fh
         cmp       al,3                     ; je videom¢d 3 ?
         je        initmod2                 ; je videom¢d 3 - OK
         cmp       al,2                     ; je videom¢d 2 ?
         je        initmod2                 ; je videom¢d 2 - OK
         cmp       al,7                     ; je videom¢d 7 ?
         je        initmod2                 ; je videom¢d 7 - OK
         mov       ax,3                     ; funkce nastaven¡ videom¢du 3
         int       10h                      ; nastaven¡ videom¢du
initmod2:                                 ;* od© dkov n¡ textu na displeji
         mov       byte ptr ds:[normat],07h ; barva textu p©¡kaz. © dku
         mov       al,13
         call      mainout
         mov       al,10
         call      mainout
                                          ;* zji¨tˆn¡ aktivn¡ str nky
         mov       ah,0fh
         int       10h                      ; poskytnut¡ aktivn¡ str nky
         mov       ds:[aktpage],bh          ; £schova zobrazen‚ str nky displeje
                                          ;* inicializace parametr–
         push      ds
         xor       cx,cx
         mov       ds,cx                    ; DS <- 0
         mov       si,ds:[044eh]            ; po‡ te‡n¡ adresa videostr nky
         mov       cx,0b800h                ; segment B800h pro EGA, CGA
         cmp       al,7                     ; je videom¢d 7 ?
         jne       initcrd2                 ; nen¡ MDA
         mov       cx,0b000h                ; segment B000h pro MDA/Hercules
         test      byte ptr cs:[parrez],3   ; je opakovan˜ start ?
         jne       initcrd2                 ; displej je ji‘ nainstalov n
         or        byte ptr cs:[flags],20h  ; p©¡znak monochromatick‚ho displeje
initcrd2:pop       ds
         mov       ds:[adrvram],si          ; po‡ te‡n¡ adresa videostr nky
         mov       ds:[segvram],cx          ; segment videopamˆti
         mov       ah,3
         int       10h                      ; ‡ten¡ pozice kurzoru
         mov       ds:[aktkurz],dx          ; £schova pozice kurzoru

                                          ;* vytvo©en¡ segmentu pro VRAM
         call      createseg                ; vytvo©en¡ nov‚ho segmentu dat
         mov       ds:[cisvram],al          ; ‡¡slo segmentu s VRAM
         push      ax                       ; ‡¡slo segmentu
         call      egaask                   ; dotaz na po‡et © dk–
         mov       bl,dl                    ; po‡et © dk– - 1
         inc       bl
         mov       al,80*2
         mul       bl                       ; d‚lka videpamˆti
         mov       bx,ax
         mov       ds:[delvram],ax          ; velikost bufferu videopamˆti
         pop       ax                       ; ‡¡slo segmentu

         push      bx
         call      modiseg                  ; modifikace segmentu
         call      getseg                   ; poskytnut¡ adresy segmentu
         mov       es,bx                    ; adresa segmentu
         xor       di,di                    ; offset ukl dac¡ adresy
         pop       bx
                                          ;* £schova obsahu obrazovky
         push      ds
         push      es
         lds       si,dword ptr cs:[adrvram]; adresa videopamˆti
         mov       cx,bx                    ; d‚lka videopamˆti
         shr       cx,1                     ; po‡et znak– v bufferu
         cld
         rep       movsw                    ; £schova videopamˆti
         pop       es
         pop       ds
         ret

; -----------------------------------------------------------------------------
;                   Instalace vlastn¡ch obsluh p©eru¨en¡
; -----------------------------------------------------------------------------
public   initint

initint:                                    ; inicializace obsluh p©eru¨en¡
                                          ;* instalace INT 1Bh
         mov       ax,351bh
         int       21h
         mov       word ptr ds:[old1b],bx
         mov       word ptr ds:[old1b+2],es ; p–vodn¡ adresa INT 1bh
         mov       ax,251bh
         lea       dx,[int23]
         int       21h                      ; nastaven¡ obsluhy INT 1bh
                                          ;* instalace INT 23h
         test      byte ptr cs:[parrez],3   ; je opakovan˜ start ?
         jne       initint2                 ; je opakovan˜ start
         mov       ax,3523h
         int       21h
         mov       word ptr ds:[old23],bx
         mov       word ptr ds:[old23+2],es ; p–vodn¡ adresa INT 23h
         mov       ax,2523h
         lea       dx,[int23]
         int       21h                      ; nastaven¡ obsluhy INT 23h
initint2:                                 ;* inicializace INT 24h
         mov       ax,3522h
         int       21h
         mov       word ptr ds:[old22],bx
         mov       word ptr ds:[old22+2],es ; p–vodn¡ adresa INT 22h

         mov       ax,3524h
         int       21h
         mov       word ptr ds:[old24],bx
         mov       word ptr ds:[old24+2],es ; p–vodn¡ adresa INT 24h
         mov       ax,2524h
         lea       dx,[int24]
         int       21h                      ; nastaven¡ obsluhy INT 24h

;         mov       ax,3508h
;         int       21h
;         mov       word ptr ds:[old08],bx
;         mov       word ptr ds:[old08+2],es ; p–vodn¡ adresa INT 08h
;         mov       ax,2508h
;         lea       dx,[int08]
;         int       21h                      ; nastaven¡ obsluhy INT 08h

;         mov       ax,3509h
;         int       21h
;         mov       word ptr ds:[old09],bx
;         mov       word ptr ds:[old09+2],es ; p–vodn¡ adresa INT 09h
;         mov       ax,2509h
;         lea       dx,[int09]
;         int       21h                      ; nastaven¡ obsluhy INT 09h

;         mov       ax,3510h
;         int       21h
;         mov       word ptr ds:[old10],bx
;         mov       word ptr ds:[old10+2],es ; p–vodn¡ adresa INT 10h
;         mov       ax,2510h
;         lea       dx,[int10]
;         int       21h                      ; nastaven¡ obsluhy INT 10h

;         mov       ax,3521h
;         int       21h
;         mov       word ptr ds:[old21],bx
;         mov       word ptr ds:[old21+2],es ; p–vodn¡ adresa INT 21h
;         mov       ax,2521h
;         lea       dx,[int21]
;         int       21h                      ; nastaven¡ obsluhy INT 21h

         push      cs
         pop       es
         ret

; -----------------------------------------------------------------------------
;                  Inicializace aktu ln¡ho adres ©e
; -----------------------------------------------------------------------------
public   initpth0

initpth0:                                 ;* inicializace aktivn¡ho adres ©e

         lea       di,[pathr]               ; prav˜ adres ©
         call      loadpath                 ; na‡ten¡ aktivn¡ho adres ©e
         lea       si,[pathl]               ; lev˜ adres ©
         xchg      si,di
         call      transtxt                 ; zkop¡rov n¡ adres ©–
         ret

; -----------------------------------------------------------------------------
;                  Inicializace domovsk‚ho adres ©e
; -----------------------------------------------------------------------------
;public   inithome
;
;inithome:                                 ;* inicializace domovsk‚ho adres ©e
;
;         test      byte ptr ds:[parrez],3   ; je opakovan˜ start ?
;         jne       inithom6                 ; je opakovan˜ start
;         lea       bx,[pathhome]            ; p©¡stupov  cesta k adres ©i
;         cmp       word ptr ds:[verze],300h ; je verze 3.00 nebo vy¨¨¡ ?
;         jb        inithom5                 ; je ni‘¨¡ verze ne‘ 3.00
;                                          ;* nalezen¡ ©etˆzce domovsk‚ cesty
;         mov       ds,ds:[2ch]              ; segment prost©ed¡
;         mov       si,3                     ; po‡ te‡n¡ offset prost©ed¡ + 3
;         xor       ax,ax                    ; AX <- 0 (hledan‚ slovo)
;inithom1:inc       si                       ; zv˜¨en¡ adresy textu
;         cmp       ds:[si-4],ax             ; je konec ©etˆzc– prost©ed¡ (0) ?
;         jne       inithom1                 ; nen¡ konec ©etˆzc– prost©ed¡
;         cmp       ds:[si-2],ax             ; je nˆjak˜ ©etˆzec ?
;         je        inithom5                 ; nen¡ ‘ dn˜ ©etˆzec - chyba
;                                          ;* p©enos domovsk‚ho adres ©e
;         mov       di,bx                    ; p©¡stupov  cesta k adres ©i
;         mov       cx,127                   ; maxim ln¡ d‚lka cesty
;         push      di                       ; £schova adresy za‡ tku textu
;inithom2:lodsb                              ; na‡ten¡ znaku ©etˆzce
;         stosb                              ; ulo‘en¡ znaku
;         cmp       al,"\"                   ; je ozna‡en¡ adres ©e ?
;         jne       inithom3                 ; nen¡ znak adres ©e
;         dec       di                       ; n vrat adresy znaku "\"
;         add       sp,2                     ; zru¨en¡ uschovan‚ adresy konce
;         push      di                       ; ulo‘en¡ nov‚ adresy konce textu
;         inc       di                       ; zv˜¨en¡ na adresu dal¨¡ho znaku
;inithom3:or        al,al                    ; je ji‘ konec ©etˆzce ?
;         jz        inithom4                 ; je ji‘ konec ©etˆzce
;         loop      inithom2                 ; p©enos dal¨¡ho znaku
;inithom4:;pop       si                       ; n vrat adresy konce ©etˆzce
;;                                          ;* £schova jm‚na programu
;;         push      si
;;         push      ds
;;         push      cs
;;         pop       ds
;;         inc       si
;;         lea       di,[identnm]             ; identifika‡n¡ text souboru
;;         call      transtxt                 ; p©enos jm‚na programu
;;         pop       ds
;         pop       di
;;
;;         cmp       byte ptr es:[di-1],":"   ; je z kladn¡ adres © ?
;;         jne       inithom7
;;         inc       di                       ; p©esko‡en¡ znaku "\"
;inithom7:xor       al,al                    ; AL <- 0 ukon‡ovac¡ bajt ©etˆzce
;         stosb                              ; ulo‘en¡ koncov‚ho bajtu 0
;         push      cs
;         pop       ds
;         mov       si,bx                    ; p©¡stupov  cesta k adres ©i
;         call      aktdir                   ; nastaven¡ po‘adovan‚ho adres ©e
;inithom5:                                 ;* na‡ten¡ domovsk‚ cesty
;         mov       di,bx                    ; p©¡stupov  cesta k adres ©i
;         call      loadpath                 ; na‡ten¡ aktivn¡ cesty
;inithom6:push      cs
;         pop       ds
;         ret
;
; -----------------------------------------------------------------------------
;                    Inicializace u‘ivatelsk‚ n povˆdy
; -----------------------------------------------------------------------------
;public   inituse
;
;inituse:                                  ;* inicializace u‘ivatelsk‚ n povˆdy
;                                            ; je nastaven domovsk˜ adres ©
;
;         test      byte ptr ds:[parrez],3   ; je opakovan˜ start ?
;         jne       inituse2                 ; je opakovan˜ start
;         lea       di,[hlpuse]
;         mov       al," "
;         mov       cx,6*10
;         rep       stosb                    ; vymaz n¡ bufferu
;                                          ;* otev©en¡ souboru
;;         lea       dx,[soubuse]             ; jm‚no souboru "DOSMAN.USE"
;;         mov       ax,3d00h
;;         int       21h                      ; otev©en¡ souboru pro ‡ten¡
;;        jc        inituse2                 ; chyba
;;                                          ;* na‡ten¡ souboru
;;         mov       bx,ax                    ; identifik tor souboru
;;         lea       dx,[hlpuse]              ; adresa k na‡ten¡ souboru
;;         mov       cx,6*10                  ; d‚lka n povˆdy
;;         mov       ah,3fh
;;         int       21h                      ; na‡ten¡ souboru
;;                                          ;* uzav©en¡ souboru
;;         mov       ah,3eh
;;         int       21h                      ; uzav©en¡ souboru
;inituse2:
;         ret
;
;; -----------------------------------------------------------------------------
;;                    Inicializace u‘ivatelsk˜ch barev
;; -----------------------------------------------------------------------------
;public   initcus
;
;initcus:                                  ;* inicializace u‘ivatelsk˜ch barev
;
;         test      byte ptr ds:[parrez],3   ; je opakovan˜ start ?
;         jne       initcus2                 ; je opakovan˜ start
;                                          ;* vymaz n¡ bufferu
;         lea       di,[helpbuf]
;         mov       cx,1024                  ; d‚lka bufferu
;         xor       al,al
;         rep       stosb                    ; vymaz n¡ bufferu
;                                          ;* otev©en¡ souboru
;;         lea       dx,[soubcol]             ; jm‚no souboru "DOSMAN.COL"
;;         mov       ax,3d00h
;;         int       21h                      ; otev©en¡ souboru pro ‡ten¡
;;         jc        initcus2                 ; chyba
;;                                          ;* na‡ten¡ souboru
;;         mov       bx,ax                    ; identifik tor souboru
;;         lea       dx,[helpbuf]             ; adresa k na‡ten¡ souboru
;;         mov       cx,1020                  ; max. d‚lka souboru
;;         mov       ah,3fh
;;         int       21h                      ; na‡ten¡ souboru
;;                                          ;* uzav©en¡ souboru
;;         mov       ah,3eh
;;         int       21h                      ; uzav©en¡ souboru
;initcus2:
;         ret

; -----------------------------------------------------------------------------
;                    Inicializace podle rezidentn¡ch dat
; -----------------------------------------------------------------------------
public   initrez

initrez:                                  ;* inicializace podle rezidentn¡ch dat

         test      byte ptr ds:[parrez],3   ; je rezidentn¡ re‘im ?
         jne       initrz2                  ; je rezidentn¡ re‘im
                                          ;* nalezen¡ rezidentn¡ch dat v pamˆti
         mov       cs:[segrez],cs           ; segment rezidentn¡ch dat
         mov       ds,ds:[10h]              ; segment pro p©eru¨en¡ programu
         lea       si,[strt]                ; za‡ tek identifika‡n¡ch dat
         mov       di,si                    ; za‡ tek identifikace v tomto prog.
         mov       cx,offset(paramexec-strt); d‚lka identifika‡n¡ch dat
         repe      cmpsb                    ; porovn n¡ identifika‡n¡ch ©etˆzc–
         jne       initrz2                  ; nenalezena rezidentn¡ data
                                          ;* na‡ten¡ rezidentn¡ch dat
         mov       cs:[segrez],ds           ; segment rezidentn¡ch dat
         lea       si,[datarez]             ; za‡ tek rezidentn¡ch dat
         lea       di,[inidata]             ; za‡ tek inicializa‡n¡ch dat
         lea       cx,[inidend]
         sub       cx,di                    ; d‚lka rezidentn¡ch dat
         rep       movsb                    ; na‡ten¡ rezidentn¡ch dat
initrz2: push      cs
         pop       ds
         ret

; -----------------------------------------------------------------------------
;                      Inicializace parametr– oken
; -----------------------------------------------------------------------------
public   initwpar

initwpar:                                 ;* inicializace parametr– oken

                                          ;* inicializace p©¡znak– oken
         mov       al,ds:[flags0l]          ; uschovan‚ p©¡znaky lev‚ho okna
         and       al,0f1h                  ; zru¨en¡ p©¡znak– na‡ten¡ adres ©e
         mov       ds:[flagsl],al           ; nastaven¡ p©¡znak– lev‚ho okna
         mov       al,ds:[flags0r]          ; uschovan‚ p©¡znaky prav‚ho okna
         and       al,0f1h                  ; zru¨en¡ p©¡znak– na‡ten¡ adres ©e
         mov       ds:[flagsr],al           ; nastaven¡ p©¡znak– prav‚ho okna
                                          ;* nastaven¡ parametr– oken
         mov       al,ds:[setwls]
         mov       ds:[setwl],al
         mov       al,ds:[setwrs]
         mov       ds:[setwr],al
                                          ;* nastaven¡ adres n vaznosti oken
initwpr3:lea       ax,[tabl]                ; adresa lev‚ho okna
         mov       ds:[adrtabr],ax          ; n vaznost na lev‚ okno
         lea       ax,[tabr]                ; adresa prav‚ho
         mov       ds:[adrtabl],ax          ; n vaznost na prav‚ okno
                                          ;* nastaven¡ po‡ te‡n¡ch pozic oken
         mov       ax,word ptr ds:[pozwr]   ; po‡ te‡n¡ pozice prav‚ho okna
         mov       ds:[pozr],al             ; po‡ te‡n¡ pozice prav‚ho okna
         mov       ds:[pozl],ah             ; po‡ te‡n¡ pozice lev‚ho okna
                                          ;* nastaven¡ adres p©¡stupov˜ch cest
         lea       ax,[pathr]               ; p©¡stupov  cesta prav 
         mov       ds:[adrpathr],ax         ; nastaven¡ prav‚ p©¡stupov‚ cesty
         lea       ax,[pathl]               ; p©¡stupov  cesta lev 
         mov       ds:[adrpathl],ax         ; nastaven¡ lev‚ p©¡stupov‚ cesty
                                          ;* nastaven¡ adres buffer– seznam–
         call      createseg                ; vytvo©en¡ datov‚ho segmentu
         mov       ds:[cissegl],al          ; p©idˆlen¡ segmentu lev‚mu oknu
         call      createseg                ; vytvo©en¡ datov‚ho segmentu
         mov       ds:[cissegr],al          ; p©idˆlen¡ segmentu prav‚mu oknu

         ret

; -----------------------------------------------------------------------------
;                  Inicializace neaktivn¡ho adres ©e
; -----------------------------------------------------------------------------
public   initpath

initpath:                                 ;* inicializace neaktivn¡ho adres ©e

         call      getnakt                  ; poskytnut¡ adresy neaktiv. okna
         lea       si,[path]                ; cesta k neaktivn¡mu oknu
         cmp       byte ptr ds:[si],0       ; je nˆjak˜ ©etˆzec ?
         je        initpth1                 ; nen¡ ‘ dn˜ ©etˆzec
         mov       di,ds:[bp+4]             ; adresa p©¡stupov‚ cesty
         mov       cx,70                    ; d‚lka ©etˆzce cesty
         rep       movsb                    ; p©enesen¡ ©etˆzce
initpth1:ret

; -----------------------------------------------------------------------------
;                          Zad n¡ z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------
;public   initkey
;
;initkey:                                  ;* inicializace p©¡kazov‚ho © dku
;                                          ;* inicializace licen‡n¡ho ‡¡sla
;         mov       ax,ds:[0fah]             ; ni‘¨¡ slovo licen‡n¡ho ‡¡sla
;         mov       word ptr ds:[licence],ax
;         mov       ax,ds:[0fch]             ; vy¨¨¡ slovo licen‡n¡ho ‡¡sla
;         mov       word ptr ds:[licence+2],ax
;
;         mov       di,81h                   ; adresa p©¡kazov‚ho © dku
;         xor       ch,ch                    ; CH <- 0
;         mov       cl,ds:[di-1]             ; d‚lka ©etˆzce p©¡kazov‚ho © dku
;         mov       ds:[di-1],ch             ; vynulov n¡ bufferu
;         cmp       cl,120                   ; maxim ln¡ d‚lka p©¡kaz. © dku
;         jbe       initkey2
;         mov       cl,120                   ; omezen¡ d‚lky © dku
;                                          ;* nalezen¡ zad n¡ parametr– "/"
;initkey2:mov       al,"/"                   ; ozna‡en¡ parametr–
;         jcxz      initkey1                 ; nen¡ zadan˜ ‘ dn˜ znak
;         repne     scasb                    ; nalezen¡ oddˆlova‡e "/"
;         jne       initkey1                 ; nenalezen oddˆlova‡ "/"
;                                          ;* skok podle zadan‚ho parametru
;         mov       al,ds:[di+1]             ; dal¨¡ n sleduj¡c¡ znak
;         call      highcase                 ; p©evod na velk‚ p¡smeno
;         mov       ah,al
;         mov       al,ds:[di]               ; n sleduj¡c¡ znak
;         call      highcase                 ; p©evod na velk‚ p¡smeno
;         call      getakt                   ; poskytnut¡ aktivn¡ho okna
;         lea       bx,[skokinik]            ; tabulka skok– pro inicializaci
;         call      skokax                   ; skok podle hodnoty AX
;         jmp       short initkey2           ; dal¨¡ znak
;initkey1:
;         ret
;
;initkdm:                                  ;* parametr "/DM" - monochrom. disp.
;         or        byte ptr ds:[flags],20h  ; nastaven¡ p©¡znaku monochr. displ.
;         ret
;
;initkdc:                                  ;* parametr "/DC" - barevn˜ displej
;         and       byte ptr ds:[flags],not 20h ; p©¡znak barevn‚ho displeje
;         ret
;
;initkfc:                                  ;* parametr "/FC" - ‡e¨tina bez diakr.
;         and       byte ptr ds:[config],not 3
;         or        byte ptr ds:[config],1   ; p©¡znak vypnut¡ ‡e¨tiny
;         ret
;
;initkfk:                                  ;* parametr "/FK" - ‡e¨tina Kamenic.
;         and       byte ptr ds:[config],not 3 ; ‡e¨tina Kamenick˜ch
;         ret
;
;initkfl:                                  ;* parametr "/FL" - ‡e¨tina Latin 2
;         and       byte ptr ds:[config],not 3
;         or        byte ptr ds:[config],2   ; ‡e¨tina LATIN 2
;         ret
;
;initkb:                                   ;* parametr "/B" - n povˆda
;         xor       byte ptr ds:[flags],4    ; zmˆna p©¡znaku n povˆdy
;         ret
;
;initkl:                                   ;* parametr "/L" - neaktivn¡ okno
;         call      getnakt                  ; poskytnut¡ neaktivn¡ho okna
;         xor       byte ptr ds:[bp+0],1     ; zmˆna p©¡znaku aktivity okna
;         ret
;
;initko:                                   ;* parametr "/O" - zap/vyp obou oken
;         xor       byte ptr ds:[flags],2    ; zmˆna p©¡znaku aktivity obou oken
;         ret
;
;initkt:                                   ;* parametr "/T" - p©epnut¡ aktiv.okna
;
;         call      testaktw                 ; je aktivn¡ okno zapnuto ?
;         jc        initku1                  ; okno nen¡ zapnuto
;         xor       byte ptr ds:[flags],1    ; zmˆna aktivn¡ho okna
;         call      getakt                   ; nov‚ aktivn¡ okno
;         call      testaktw                 ; je neaktivn¡ okno zapnuto ?
;         jnc       initku1                  ; neaktivn¡ okno je zapnuto
;         xor       byte ptr ds:[flags],1    ; n vrat aktivn¡ho okna
;
;initku:                                   ;* parametr "/U" - z mˆna oken
;         mov       al,ds:[pozl]             ; pozice lev‚ho okna
;         xchg      al,ds:[pozr]             ; nov  pozice prav‚ho okna
;         mov       ds:[pozl],al             ; nov  pozice lev‚ho okna
;initku1: ret
;
;
;initkc:                                   ;* parametr "/C" - proveden¡ p©¡kazu
;
;         mov       si,di                    ; za‡ tek textu cesty
;         inc       si
;         lea       di,[buftxt]              ; buffer povelov‚ho © dku
;         jcxz      initkp2                  ; je konec ©etˆzce
;         dec       cx
;         push      di
;         rep       movsb                    ; p©enos textu p©¡kazu
;         xor       al,al
;         stosb                              ; koncov  0
;         pop       si                       ; adresa textu
;;         jmp       execute                  ; proveden¡ p©¡kazu
;
;initkp2: ret
;
;initksn:                                  ;* parametr "/SN" - t©¡dˆn¡ podle jm‚na
;;         and       byte ptr ds:[bp+0],0fh   ; zru¨en¡ p©¡znak– t©¡dˆn¡
;         ret
;
;initkp:                                   ;* parametr "/P" - rezidentn¡ re‘im
;;         or        byte ptr ds:[flags],8    ; p©¡znak rezidentn¡ho re‘imu
;         ret
;
;initkse:                                  ;* parametr "/SE" - t©¡dˆn¡ podle p©¡pony
;;         and       byte ptr ds:[bp+0],0fh   ; zru¨en¡ p©¡znak– t©¡dˆn¡
;;         or        byte ptr ds:[bp+0],20h   ; p©¡znak t©¡dˆn¡ podle p©¡pony
;         ret
;
;initksd:                                  ;* parametr "/SD" - t©¡dˆn¡ podle data
;;         and       byte ptr ds:[bp+0],0fh   ; zru¨en¡ p©¡znak– t©¡dˆn¡
;;         or        byte ptr ds:[bp+0],40h   ; p©¡znak t©¡dˆn¡ podle data
;         ret
;
;initkss:                                  ;* parametr "/SS" - t©¡dˆn¡ podle velikosti
;;         and       byte ptr ds:[bp+0],0fh   ; zru¨en¡ p©¡znak– t©¡dˆn¡
;;         or        byte ptr ds:[bp+0],80h   ; p©¡znak t©¡dˆn¡ podle velikosti
;         ret
;
;initksx:                                  ;* parametr "/SX" - net©¡dˆn¡ adres ©
;;         and       byte ptr ds:[bp+0],0fh   ; zru¨en¡ p©¡znak– t©¡dˆn¡
;;         or        byte ptr ds:[bp+0],10h   ; p©¡znak net©¡dˆn‚ho adres ©e
;         ret
;
;
;initkx:                                   ;* parametr "/X" - prov dˆn¡ povel– INT 2eh
;ifndef   demo
;;         or        byte ptr ds:[conf2],1    ; p©¡znak povel– pomoc¡ INT 2Eh
;endif
;         ret
;
;initka:  cmp       bp,offset tabl           ; je lev‚ okno ?
;         mov       al,2                     ; maska pro lev‚ okno
;         je        initka2                  ; je lev‚ okno
;         mov       al,4                     ; maska pro prav‚ okno
;initka2: xor       cs:[conf2],al            ; zmˆna p©¡znak– okna
;         ret
;
;
;initkq:                                   ;* parametr "/Q" - trojsloupc. zobraz.
;;         xor       byte ptr ds:[bp+29],1    ; zmˆna p©¡znaku zobrazen¡
;         ret
;
;initkh:                                   ;* parametr "/H" - vypnut¡ SHIFT
;         and       byte ptr ds:[conf2],not 10h ; vypnut¡ funkce SHIFT
;         ret
;
;initk43:                                  ;* parametr "/43" - nastaven¡ EGA 43
;;         or        byte ptr ds:[flags],10h  ; p©¡znak displeje EGA 43
;         ret
;
;initkn:                                   ;* parametr "/N" - u‘ivatelsk‚ menu
;;         or        byte ptr ds:[conf3],3    ; p©¡znak automatick‚ho menu
;         ret
;
;initkk:                                   ;* parametr "/K" - stand. kl vesnice
;         or        byte ptr ds:[conf3],4    ; p©¡znak standardn¡ kl vesnice
;         ret
;
;
;skokinik label     byte                   ;* tabulka skok– pro INITKEY
;         db        80h+11                   ; testuje se AX
;         dw        "MD"
;         dw        offset initkdm           ; monochromatick˜ displej
;         dw        "CD"
;         dw        offset initkdc           ; barevn˜ displej
;         dw        "CF"
;         dw        offset initkfc           ; ‡e¨tina bez diakritiky
;         dw        "KF"
;         dw        offset initkfk           ; ‡e¨tina Kamenick˜ch
;         dw        "LF"
;         dw        offset initkfl           ; ‡e¨tina Latin 2
;         dw        "NS"
;         dw        offset initksn           ; t©¡dˆn¡ podle jm‚na
;         dw        "ES"
;         dw        offset initkse           ; t©¡dˆn¡ podle p©¡pony
;         dw        "DS"
;         dw        offset initksd           ; t©¡dˆn¡ podle data a ‡asu
;         dw        "SS"
;         dw        offset initkss           ; t©¡dˆn¡ podle velikosti
;         dw        "XS"
;         dw        offset initksx           ; net©¡dˆn¡ adres ©
;         dw        "34"
;         dw        offset initk43           ; nastaven¡ © dkov n¡ EGA 43
;
;         db        00h+13                   ; testuje se AL
;         db        "B"
;         dw        offset initkb            ; zap/vyp n povˆdy
;         db        "L"
;         dw        offset initkl            ; zap/vyp neaktivn¡ho okna
;         db        "O"
;         dw        offset initko            ; zap/vyp obou oken
;         db        "T"
;         dw        offset initkt            ; p©epnut¡ aktivn¡ho okna
;         db        "C"
;         dw        offset initkc            ; p©¡kaz
;         db        "U"
;         dw        offset initku            ; z mˆna oken
;         db        "P"
;         dw        offset initkp            ; rezidentn¡ re‘im
;         db        "X"
;         dw        offset initkx            ; prov dˆn¡ povel– pomoc¡ INT 2eh
;         db        "A"
;         dw        offset initka            ; nastaven¡ atribut– okna
;         db        "Q"
;         dw        offset initkq            ; trojsloupcov‚ zobrazen¡
;         db        "H"
;         dw        offset initkh            ; vypnut¡ funkce SHIFT
;         db        "N"
;         dw        offset initkn            ; u‘ivatelsk‚ menu
;         db        "K"
;         dw        offset initkk            ; standardn¡ kl vesnice 83/84
;
;         db        0

; -----------------------------------------------------------------------------
;                      Inicializace barev displeje
; -----------------------------------------------------------------------------
public   initcolor

initcolor:                                ;* inicializace barev displeje

initcol0:push      cs
         pop       ds

         test      byte ptr ds:[parrez],2   ; je opakovan˜ start ?
         jne       initcol6                 ; je opakovan˜ start
                                          ;* prvn¡ instalace barev
         lea       si,[colcol]              ; barvy pro barevn˜ displej
         test      byte ptr ds:[flags],20h  ; je ‡ernob¡l˜ displej ?
         jz        initcol1                 ; nen¡ ‡ernob¡l˜ displej
         lea       si,[colbw]               ; barvy pro ‡ernob¡l˜ displej
initcol1:lea       di,[coldisp]             ; aktu ln¡ barvy displeje
         mov       cx,19                    ; d‚lka tabulky barev
         rep       movsb                    ; p©enos tabulky
initcol6:
         ret

;initcln: lodsb                              ; dal¨¡ znak
;         call      highcase                 ; p©evod na velk‚ p¡smeno
;         or        al,al                    ; je konec textu ?
;         jz        initcln3                 ; konec textu
;         cmp       al,","
;         je        initcln4                 ; je oddˆlova‡ dat
;         cmp       al," "
;         jbe       initcln                  ; oddˆlova‡
;
;         cmp       al,"A"
;         jb        initcln2
;         sub       al,7
;initcln2:and       al,0fh                   ; korekce na ‡¡slici
;         mov       cl,4
;         shl       bl,cl
;         or        bl,al                    ; nov˜ atribut
;         jmp       short initcln            ; dal¨¡ znak
;
;initcln3:dec       si                       ; n vrat posledn¡ho znaku
;initcln4:ret

; -----------------------------------------------------------------------------
;                      Inicializace fontu text–
; -----------------------------------------------------------------------------
;public   inittext
;
;inittext:                                 ;* inicializace font– text–
;
;         lea       si,[zactxt]              ; za‡ tek text– programu
;         mov       di,si
;         lea       cx,[konectxt]            ; konec text– programu
;         sub       cx,si                    ; d‚lka text– programu
;inittxt1:lodsb
;         call      konvfnt                  ; konverze fontu
;         stosb
;         loop      inittxt1                 ; dal¨¡ znak
;         ret
;
; -----------------------------------------------------------------------------
;                      Inicializace buffer– textu
; -----------------------------------------------------------------------------
public   initbuf

initbuf:                                  ;* inicializace parametr– buffer–
         lea       di,[comlin]             ; definice povelov‚ho © dku
         lea       ax,[buftxt]
         stosw                              ; offset adresy bufferu
         mov       ax,cs
         stosw                              ; nastaven¡ segmentu adresy
         mov       ax,120
         stosw                              ; maxim ln¡ po‡et znak–
                                          ;* inicializace bufferu pro volby
         lea       di,[sellin]             ; definice pro editaci voleb
         lea       ax,[selbuf]
         stosw                              ; offset adresy bufferu
         mov       ax,cs
         stosw                              ; nastaven¡ segmentu adresy
         mov       ax,127
         stosw                              ; maxim ln¡ po‡et znak–

         ret

; -----------------------------------------------------------------------------
;                         Inicializace kl vesnice
; -----------------------------------------------------------------------------
public   initkin

initkin:                                  ;* inicializace vstupu z kl vesnice
;         push      ds
         xor       ax,ax
;         mov       ds,ax                    ; DS <- 0
         inc       ax                       ; AX <- 1
;         test      byte ptr ds:[0496h],10h  ; je instalov na kl vesnice 101/102?
;         pop       ds
;         jz        initkin1                 ; nen¡ kl vesnice 101/102
;         test      byte ptr ds:[conf3],4    ; je standardn¡ kl vesnice ?
;         jnz       initkin1                 ; je standardn¡ kl vesnice
;ifndef   keystd
;         add       ax,1010h                 ; zv˜¨en¡ k¢du o 10h
;endif
initkin1:mov       word ptr ds:[keystat],ax ; nastaven¡ k¢d– pro vstup z kl v.
         ret

; -----------------------------------------------------------------------------
;                      Odinstalov n¡ programu
; -----------------------------------------------------------------------------
public   initmouse

initmouse:                                ;* inicializace obsluhy my¨i
         push      cs
         pop       ds
         and       byte ptr ds:[config],not 40h ; zru¨en¡ p©¡znaku my¨i
;         xor       ax,ax
;         int       33h                      ; je nainstalov na my¨ ?
;         inc       ax                       ; pokud je AX=-1, je my¨
;         jnz       inmouse4                 ; nen¡ my¨
;                                          ;* instalace rozmˆr– okna
;         mov       ax,7
;         xor       cx,cx                    ; minim ln¡ pozice
;         mov       dx,79*8                  ; maxim ln¡ pozice
;         int       33h                      ; definov n¡ horizont ln¡ch rozmˆr–
;         mov       ax,8
;         xor       cx,cx                    ; minim ln¡ © dek
;         xor       dh,dh
;         mov       dl,ds:[displ]
;         shl       dx,1
;         shl       dx,1
;         shl       dx,1                     ; maxim ln¡ © dek
;         int       33h                      ; definov n¡ vertik ln¡ch rozmˆr–
;                                          ;* definov n¡ kurzoru my¨i
;         mov       ax,0ah
;         xor       bx,bx                    ; p©¡znak softwarov‚ho kurzoru
;         mov       cx,0ffffh                ; maska obrazovky (AND)
;         mov       dx,7700h                 ; maska kurzoru (XOR)
;                                          ;* nastaven¡ st©edn¡ pozice
;         mov       ax,4
;         xor       cx,cx
;         xor       dx,dx
;         mov       cl,byte ptr ds:[mousepoz]
;         add       cx,cx
;         add       cx,cx
;         add       cx,cx                    ; pozice
;         mov       dl,byte ptr ds:[mousepoz+1]
;         add       dx,dx
;         add       dx,dx
;         add       dx,dx                    ; © dek
;         int       33h                      ; nastaven¡ pozice kurzoru
;
;         or        byte ptr ds:[config],40h ; nastaven¡ p©¡znaku my¨i
;         call      mouseon                  ; zapnut¡ my¨i
;
inmouse4:ret

; -----------------------------------------------------------------------------
;initstosb:                                ;* vymaz n¡ inicializa‡n¡ch dat
;
;         rep       stosb                    ; vymaz n¡ dat
;         ret
;
; -----------------------------------------------------------------------------
;                      Odinstalov n¡ programu
; -----------------------------------------------------------------------------
public   deinit

deinit:
         push      si
         push      ax
         push      dx
         push      cs
         pop       ds
                                          ;* n vrat p©eru¨en¡ od my¨i
;         test      byte ptr ds:[config],40h ; je nainstalov na my¨ ?
;         jz        deinit1                  ; my¨ nen¡ nainstalov na
;         xor       cx,cx
;         mov       ax,000ch
;         int       33h                      ; z kaz p©eru¨en¡ od my¨i
;         call      mouseoff                 ; vypnut¡ my¨i
;         mov       ax,0000h
;         int       33h                      ; reset ovlada‡e my¨i
                                          ;* n vrat p©eru¨en¡
deinit1:; mov       ax,2508h
        ; lds       dx,cs:[old08]
        ; int       21h
;         mov       ax,2509h
;         lds       dx,cs:[old09]
;         int       21h
;         mov       ax,2510h
;         lds       dx,cs:[old10]
;         int       21h
;         mov       ax,2521h
;         lds       dx,cs:[old21]
;         int       21h

         push      cs
         pop       ds

         mov       ax,2524h
         lea       dx,[intx24]              ; p©echodn  obsluha INT 24h
;         lds       dx,cs:[old24]
         int       21h


         push      word ptr cs:[flags]
         and       byte ptr cs:[flags],not 4 ; vypnut¡ n povˆdy
         xor       dx,dx                    ; po‡ te‡n¡ adresa pro zobrazen¡
         call      getdispcx
         inc       cx                       ; po‡et © dk– displeje
deinit3:
         push      cx
         mov       cl,80
         call      radeknul
         inc       dh
         pop       cx
         loop      deinit3
         pop       word ptr cs:[flags]

;                                          ;* navr cen¡ p–vodn¡ho obsahu displeje
;         mov       dx,cs:[aktkurz]          ; p–vodn¡ pozice kurzoru
;         xor       al,al
;         call      outch1                   ; nastaven¡ p–vodn¡ pozice kurzoru
;         push      ds
;         push      bx
;         xor       cx,cx
;         mov       cl,cs:[displ]            ; posledn¡ © dek
;         inc       cx
;         xor       dx,dx
;         mov       al,cs:[cisvram]          ; ‡¡slo segmentu s VRAM
;         call      getseg                   ; poskytnut¡ adresy segmentu s VRAM
;         mov       ds,bx                    ; segment s VRAM
;         xor       si,si                    ; po‡ te‡n¡ offset
;;         lea       si,[videoram]
;deinit3: push      cx
;         push      dx
;         mov       cx,80
;deinit4: mov       ax,0720h
;         cmp       dh,25
;         jae       deinit5
;         lodsw
;deinit5: mov       cs:[color],ah
;         call      outch10
;         loop      deinit4
;         pop       dx
;         pop       cx
;         inc       dh
;         loop      deinit3
;         pop       bx
;         pop       ds

         mov       dx,cs:[aktkurz]          ; p–vodn¡ pozice kurzoru
         cmp       dh,cs:[displ]
         jbe       deinit4
         mov       dh,cs:[displ]            ; omezen¡ na posledn¡ © dek
deinit4: xor       al,al
         call      outch1                   ; nastaven¡ p–vodn¡ pozice kurzoru


deinit2: call      getakt
         mov       si,ds:[bp+4]             ; adresa cesty
         call      aktdir                   ; nastaven¡ aktivn¡ cesty

                                          ;* uvolnˆn¡ bloku s daty
         mov       es,cs:[datseg]           ; aloka‡n¡ blok dat
         mov       ah,49h
         int       21h                      ; uvolnˆn¡ pamˆti
         push      cs
         pop       es
                                          ;* n vrat adresy obsluhy INT 1Bh
         mov       ax,251bh
         lds       dx,cs:[old1b]
         int       21h

         push      cs
         pop       ds
         pop       dx
         pop       ax
         pop       si
         ret

; -----------------------------------------------------------------------------
public   storecnf

storecnf:                                 ;* ulo‘en¡ konfigurace do pamˆti
                                            ; VSTUP: AL=ukon‡ovac¡ k¢d

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
         call      storekall                ; £schova obou kurzor–
         mov       al,ds:[flagsl]           ; uschovan‚ p©¡znaky lev‚ho okna
         mov       ds:[flags0l],al          ; nastaven¡ p©¡znak– lev‚ho okna
         mov       al,ds:[flagsr]           ; uschovan‚ p©¡znaky prav‚ho okna
         mov       ds:[flags0r],al          ; nastaven¡ p©¡znak– prav‚ho okna
                                          ;* £schova parametr– oken
         mov       al,ds:[setwl]
         mov       ds:[setwls],al
         mov       al,ds:[setwr]
         mov       ds:[setwrs],al

         call      getnakt                  ; neaktivn¡ okno
         mov       si,ds:[bp+4]
         lea       di,[path]                ; cesta k neaktivn¡mu oknu
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

storekur:                                 ;* £schova nastaven¡ kurzoru na soubor
                                            ; VSTUP: BP=adresa definice okna


         pushf
         push      si
         push      ds
         call      getkurz                  ; poskytnut¡ adresy souboru
         jc        storeku2                 ; nen¡ platn˜ kurzor
         call      storefile                ; ulo‘en¡ polo‘ky
storeku2:pop       ds
         pop       si
         popf
         ret

storefile:                                ;* £schova polo‘ky DS:SI

         push      ax
         push      bx
         push      cx
         push      si
         push      di
         push      es
         push      cs
         pop       es

         lea       di,[namel]               ; jm‚no souboru L
         lea       bx,[firstwl]
         lea       ax,[pozwl]               ; pozice lev‚ho okna
         cmp       bp,offset tabr           ; je to prav‚ okno ?
         jnz       storek2                  ; je aktivn¡ lev‚ okno
         lea       di,[namer]               ; jm‚no souboru R
         lea       bx,[firstwr]
         lea       ax,[pozwr]               ; pozice prav‚ho okna
storek2: mov       cx,20                    ; d‚lka polo‘ky souboru
         rep       movsb                    ; p©enos polo‘ky souboru
         mov       di,ax                    ; pozice okna
         mov       al,cs:[bp+3]
         stosb                              ; £schova pozice okna
         mov       ax,cs:[bp+9]
         mov       cs:[bx],ax

storek3: pop       es
         pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

storekall:                                ;* ulo‘en¡ obou kurzor–
         push      bp
         call      getnakt
         call      storekur                 ; £schova pozice kurzoru
         call      getakt
         call      storekur                 ; £schova pozice kurzoru
         pop       bp
         ret



code     ends

         end       strt

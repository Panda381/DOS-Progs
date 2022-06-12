
; ##############################################################################
; #                                                                            #
; #                       M i k r o    M a n a ‘ e r                           #
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
extrn    aktpage:byte,old1b:dword
extrn    normat:byte,segvram:word,aktkurz:word
extrn    adrvram:word,setout:near,outch01:near
extrn    flags:byte,flagsl:byte,flagsr:byte,tabl:byte,tabr:byte
extrn    adrtabl:word,adrtabr:word,pozwl:byte,pozwr:byte,pozl:byte,pozr:byte
extrn    pathl:byte,adrpathl:word,pathr:byte,adrpathr:word
extrn    createseg:near,cissegl:byte,cissegr:byte
extrn    getakt:near,getnakt:near,loadpath:near
extrn    comlin:byte,buftxt:byte,sellin:byte,selbuf:byte
extrn    color:byte,aktdir:near,path:byte,transtxt:near
extrn    zacmaz:byte,konecmaz:byte,inidend:byte
extrn    cisvram:byte
extrn    outch10:near,namel:byte,namer:byte,adrpolsi:near
extrn    firstwl:word,firstwr:word,int24:near
extrn    outbuf:byte,col1:byte,colbw:byte
extrn    config:byte,skokax:near,poclin:word
extrn    execute:near,keyf102:near,windret:near
extrn    flags0l:byte,flags0r:byte,testaktw:near
extrn    zacmazr:byte,modiseg:near,getseg:near
extrn    colcol:byte,coldisp:byte
extrn    getkurz:near,conf2:byte
extrn    mainout:near,displ:byte
extrn    getdispcx:near,radeknul:near,delvram:word
extrn    conf3:byte,verze:word,zasobrez:word
extrn    historie:byte,delhist:word

code     segment   public
         assume    cs:code,ds:code
         org       100h                     ; po‡ te‡n¡ adresa COM

strt:    jmp       init0                    ; prvn¡ start programu

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
         jne       execx13                  ; je nˆco v p©¡kazov‚m © dku
execx0:                                   ;* je konec programu
         push      ax
         mov       ax,2523h
         lds       dx,cs:[old23]
         int       21h                      ; n vrat p©eru¨en¡ CTRL-BREAK
         pop       ax
         mov       ah,4ch                   ; funkce ukon‡en¡ programu
         int       21h                      ; ukon‡en¡ programu

execx82: jmp       execx8                   ; chyba

                                          ;* nalezen¡ specifikace cesty
execx13: push      cs
         pop       es
         cld
         mov       ax,cs:[2ch]              ; adresa prost©ed¡
         mov       ds,ax                    ; segment prost©ed¡
         xor       si,si                    ; ukazatel cesty
execx5:  mov       di,offset comspec        ; ukazatel reference COMSPEC
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

         mov       bx,offset paramexec      ; parametry EXEC
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
         mov       cx,offset zasobrez       ; z sobn¡k pro rezidentn¡ modul
         mov       ss,bx
         mov       sp,cx
         push      cs
         pop       ds
         pushf
         mov       ax,2524h
         mov       dx,offset intx24         ; p©echodn  obsluha INT 24h
         int       21h
         mov       ax,2523h
         mov       dx,offset int23
         int       21h                      ; nastaven¡ obsluhy INT 23h
         popf

         jnc       execx9                   ; operace provedena OK
execx8:                                   ;* program COMMAND.COM nespustiteln˜
         push      cs
         pop       ds
         mov       dx,offset errcomm        ; chyba "COMMAND.COM nespustiteln˜"
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

         or        byte ptr ds:[parrez],2   ; p©¡znak opakovan‚ho startu

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

errcomm  db        'COMMAND.COM nelze spustit !',13,10
         db        '<Enter>=znovu, <Esc>=navrat',13,10,'$'
comspec  db        'COMSPEC='               ; specifikace COMSPEC

paramexec db       14 dup(0)                ; parametry pro spu¨tˆn¡ programy

public   parrez

old23    dd        0                        ; p–vodn¡ adresa obsluhy INT 23h
parbreak dw        0                        ; 1=p©¡znak u‘iv. p©eru¨en¡ BREAK
parrez   db        0                        ;   bit 1: 1=opakovan˜ start


initst1  label     near


datarez  label     byte                   ;* za‡ tek rezidentn¡ch dat


;              modul DOSMINI.ASM pro program DOSMAN - inicializace

; *****************************************************************************
;
;                        Inicializace programu p©i startu
;
; *****************************************************************************

                                            ; v podprogramech nutno zachovat
                                            ; segmentov‚ registry DS,ES <- CS !
public   init0
init0:   mov       dx,offset zacmaz         ; £vodn¡ text
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu


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
         call      initmod                  ; inicializace displeje
                                          ;* odtuto ji‘ nen¡ chybov˜ n vrat
         call      initint                  ; inicializace obsluh p©eru¨en¡
         call      initpth0                 ; inicializace aktivn¡ho adres ©e
         call      initwpar                 ; inicialiace parametr– oken
         call      initpath                 ; inicializace neaktivn¡ho adres ©e
                                          ;* zde je ji‘ nastavena konfigurace
         call      initcolor                ; inicializace barev displeje
         call      initbuf                  ; inicializace buffer– textu
         mov       word ptr ds:[parbreak],-2 ; p©¡znak ignorov n¡ chyb
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
         test      byte ptr ds:[parrez],2   ; je opakovan˜ start ?
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
initmem3:mov       word ptr ds:[historie],offset delhist ; d‚lka bufferu hist.
         jmp       bx                       ; n vrat z podprogramu

                                          ;* chyba - nedostatek pamˆti
initmem1:pop       ax                       ; zru¨en¡ n vratov‚ adresy
         mov       dx,offset errmem         ; text chyby nedostatku pamˆti
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
         je        initmod1                 ; je videom¢d 3 - OK
         or        byte ptr ds:[flags],20h  ; p©¡znak ‡ernob¡l‚ho displeje
         cmp       al,2                     ; je videom¢d 2 ?
         je        initmod2                 ; je videom¢d 2 - OK
         cmp       al,7                     ; je videom¢d 7 ?
         je        initmod2                 ; je videom¢d 7 - OK
         mov       ax,3                     ; funkce nastaven¡ videom¢du 3
         int       10h                      ; nastaven¡ videom¢du
initmod1:and       byte ptr ds:[flags],not 20h  ; zru¨en¡ p©¡znaku mono displeje
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
initcrd2:pop       ds
         mov       ds:[segvram],cx          ; segment videopamˆti
         mov       ds:[adrvram],si          ; po‡ te‡n¡ adresa videostr nky
         mov       ah,3
         int       10h                      ; ‡ten¡ pozice kurzoru
         mov       ds:[aktkurz],dx          ; £schova pozice kurzoru

                                          ;* vytvo©en¡ segmentu pro VRAM
         call      createseg                ; vytvo©en¡ nov‚ho segmentu dat
         mov       ds:[cisvram],al          ; ‡¡slo segmentu s VRAM
         push      ax                       ; ‡¡slo segmentu
         call      egaask                   ; dotaz na po‡et © dk–
         mov       ds:[displ],dl            ; £schova po‡tu © dk– - 1
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
public   egaask

egaask:                                   ;* dotaz na stav EGA karty
                                            ; VSTUP: DL=po‡et © dk–

         push      ax
         push      bx
         push      cx
         push      ds
         push      es

         mov       ah,12h
         mov       bl,10h
         int       10h                      ; poskytnut¡ informac¡ o EGA
         cmp       bl,10h                   ; je karta nainstalov na ?
         mov       dl,24                    ; n hradn¡ posledn¡ © dek = 24
         je        egaask2                  ; karta nen¡ nainstalov na
         xor       bh,bh
         mov       ax,1130h
         int       10h                      ; poskytnut¡ informac¡ o fontech
egaask2: pop       es
         pop       ds
         pop       cx
         pop       bx
         pop       ax
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
         mov       dx,offset int23
         int       21h                      ; nastaven¡ obsluhy INT 1bh
                                          ;* instalace INT 23h
         test      byte ptr cs:[parrez],3   ; je opakovan˜ start ?
         jne       initint2                 ; je opakovan˜ start
         mov       ax,3523h
         int       21h
         mov       word ptr ds:[old23],bx
         mov       word ptr ds:[old23+2],es ; p–vodn¡ adresa INT 23h
         mov       ax,2523h
         mov       dx,offset int23
         int       21h                      ; nastaven¡ obsluhy INT 23h
initint2:                                 ;* inicializace INT 24h
         mov       ax,2524h
         mov       dx,offset int24
         int       21h                      ; nastaven¡ obsluhy INT 24h

         push      cs
         pop       es
         ret

; -----------------------------------------------------------------------------
;                  Inicializace aktu ln¡ho adres ©e
; -----------------------------------------------------------------------------
public   initpth0

initpth0:                                 ;* inicializace aktivn¡ho adres ©e

         mov       di,offset pathr          ; prav˜ adres ©
         call      loadpath                 ; na‡ten¡ aktivn¡ho adres ©e
         mov       si,offset pathl          ; lev˜ adres ©
         xchg      si,di
         call      transtxt                 ; zkop¡rov n¡ adres ©–
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
                                          ;* nastaven¡ adres n vaznosti oken
initwpr3:mov       ax,offset tabl           ; adresa lev‚ho okna
         mov       ds:[adrtabr],ax          ; n vaznost na lev‚ okno
         mov       ax,offset tabr           ; adresa prav‚ho
         mov       ds:[adrtabl],ax          ; n vaznost na prav‚ okno
                                          ;* nastaven¡ po‡ te‡n¡ch pozic oken
         mov       ax,word ptr ds:[pozwr]   ; po‡ te‡n¡ pozice prav‚ho okna
         mov       ds:[pozr],al             ; po‡ te‡n¡ pozice prav‚ho okna
         mov       ds:[pozl],ah             ; po‡ te‡n¡ pozice lev‚ho okna
                                          ;* nastaven¡ adres p©¡stupov˜ch cest
         mov       ax,offset pathr          ; p©¡stupov  cesta prav 
         mov       ds:[adrpathr],ax         ; nastaven¡ prav‚ p©¡stupov‚ cesty
         mov       ax,offset pathl          ; p©¡stupov  cesta lev 
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
         mov       si,offset path           ; cesta k neaktivn¡mu oknu
         cmp       byte ptr ds:[si],0       ; je nˆjak˜ ©etˆzec ?
         je        initpth1                 ; nen¡ ‘ dn˜ ©etˆzec
         mov       di,ds:[bp+4]             ; adresa p©¡stupov‚ cesty
         mov       cx,70                    ; d‚lka ©etˆzce cesty
         rep       movsb                    ; p©enesen¡ ©etˆzce
initpth1:ret

; -----------------------------------------------------------------------------
;                      Inicializace barev displeje
; -----------------------------------------------------------------------------
public   initcolor

initcolor:                                ;* inicializace barev displeje
         mov       si,offset colcol         ; barvy pro barevn˜ displej
         test      byte ptr ds:[flags],20h  ; je ‡ernob¡l˜ displej ?
         jz        initcol1                 ; nen¡ ‡ernob¡l˜ displej
         mov       si,offset colbw          ; barvy pro ‡ernob¡l˜ displej
initcol1:mov       di,offset coldisp        ; aktu ln¡ barvy displeje
         mov       cx,19                    ; d‚lka tabulky barev
         rep       movsb                    ; p©enos tabulky
initcol6:
         ret

; -----------------------------------------------------------------------------
;                      Inicializace buffer– textu
; -----------------------------------------------------------------------------
public   initbuf

initbuf:                                  ;* inicializace parametr– buffer–
         mov       di,offset comlin         ; definice povelov‚ho © dku
         mov       ax,offset buftxt
         stosw                              ; offset adresy bufferu
         mov       ax,cs
         stosw                              ; nastaven¡ segmentu adresy
         mov       ax,120
         stosw                              ; maxim ln¡ po‡et znak–
                                          ;* inicializace bufferu pro volby
         mov       di,offset sellin         ; definice pro editaci voleb
         mov       ax,offset selbuf
         stosw                              ; offset adresy bufferu
         mov       ax,cs
         stosw                              ; nastaven¡ segmentu adresy
         mov       ax,127
         stosw                              ; maxim ln¡ po‡et znak–

         ret

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

         mov       ax,2524h
         mov       dx,offset intx24          ; p©echodn  obsluha INT 24h
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
         call      getnakt                  ; neaktivn¡ okno
         mov       si,ds:[bp+4]
         mov       di,offset path           ; cesta k neaktivn¡mu oknu
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

         mov       di,offset namel          ; jm‚no souboru L
         mov       bx,offset firstwl
         mov       ax,offset pozwl          ; pozice lev‚ho okna
         cmp       bp,offset tabr           ; je to prav‚ okno ?
         jnz       storek2                  ; je aktivn¡ lev‚ okno
         mov       di,offset namer          ; jm‚no souboru R
         mov       bx,offset firstwr
         mov       ax,offset pozwr          ; pozice prav‚ho okna
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
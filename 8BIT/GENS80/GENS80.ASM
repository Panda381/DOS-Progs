
comment %
               Gener†tor zdrojovÇho textu pro mikroprocesor Z-80

        %

;--------------------------------------------------------------------------
;                            Segment z†sobn°ku
;--------------------------------------------------------------------------

stack    SEGMENT   stack

         DW        256 DUP(?)               ; z†sobn°k

stack    ENDS

;--------------------------------------------------------------------------
;                            Programovò segment
;--------------------------------------------------------------------------

code     SEGMENT   page
         ASSUME    cs:code,ds:data,ss:stack,es:data

;--------------------------------------------------------------------------
;                            Hlavn° program
;--------------------------------------------------------------------------

start:                                      ; hlavn° tàlo programu

         call      bootini                  ; poá†teán° inicializace
         mov       [stackp],sp              ; uloëen° ukazatele z†sobn°ku

         mov       si,0                     ; poá†teán° adresa k p©ekladu

st0:
         mov       dx,100h
         mov       cx,23*256+80
         mov       ah,[coltext]
         call      box
         push      si
         mov       dx,100h                  ; poá†teán° adresa kurzoru
         mov       cx,23
st01:    mov       word ptr [pozice],dx
st1:     mov       ax,si
         call      outwrd
         mov       al,":"
         call      outchr
         mov       al,[pozkod]
         call      tabel
         mov       al,[si]
         call      outbyte
         mov       al,[si+1]
         call      outbyte
         mov       al,[si+2]
         call      outbyte
         mov       al,[si+3]
         call      outbyte
         mov       al," "
         call      outchr

         call      disas                    ; disassemblov†n° instrukce
         loop      st1
         pop       si

st10:    call      inpch
         cmp       ax,148h                  ; ®ipka nahoru
         jnz       st2
         call      roldown                  ; rolov†n° obrazovky dolñ
         dec       si
         push      si
         mov       dx,100h
         mov       cx,1
         jmp       st01
st2:     cmp       ax,150h                  ; dolñ
         jnz       st3
         call      rolup
         inc       si
         push      si
         add       si,22
         mov       dx,23*256
         mov       cx,1
         jmp       st01

st3:     cmp       ax,13
         jnz       st41



st31:    xor       ax,ax
st33:    call      akcemen1


st32:    jmp       st10

st41:    cmp       ax,"A"
         jc        st32
         cmp       ax,"z"+1
         jnc       st32
         cmp       ax,"Z"+1
         jc        st33
         cmp       ax,"a"
         jc        st32
         jmp       short st33




;------------------------------------------------------------------------------
;            Poá†teán° a koneán† inicializace programu
;------------------------------------------------------------------------------

bootini:                                    ; poá†teán° inicializace
                                            ; ES,DS = segment PSP
                                            ; vòstup ES,DS = segment DATA

                                            ; nastaven° aktu†ln°ch cest
         push      ds                       ; segment PSP
         mov       ax,seg data              ; datovò segment
         mov       ds,ax                    ; datovò segment
         mov       es,ax                    ; datovò segment
         mov       si,offset pathakt        ; aktu†ln° adres†©
         call      getadr                   ; poskytnut° aktu†ln°ho adres†©e
         mov       si,offset pathexe        ; p©°stupov† cesta k programu GENS80
         call      getadr                   ; poskytnut° aktu†ln°ho adres†©e
         mov       si,offset pathcom        ; cesta k souboru COM
         call      getadr                   ; poskytnut° aktu†ln°ho adres†©e
         mov       si,offset pathgen        ; cesta k souborñm GEN
         call      getadr                   ; poskytnut° aktu†ln°ho adres†©e
         pop       ds                       ; segment PSP
         call      getexe                   ; nastaven° cesty k programu GENS80
         call      modimem                  ; modifikace pamàti
         mov       ax,es                    ; datovò segment
         mov       ds,ax                    ; nastaven° datovÇho segmentu
         call      scrinit                  ; uschov†n° displeje a inicializace
         call      inint8                   ; inicializace obsluhy INT 8
         mov       dx,offset dta            ; adresa bufferu DTA
         mov       ah,1ah
         int       21h                      ; nastaven° adresy DTA
         ret

;------------------------------------------------------------------------------

konec:                                      ; ukonáen° programu
         mov       al,1
         mov       [ukazobr],al             ; nastaven° ukazatele obrazovky
         mov       sp,[stackp]              ; n†vrat ukazatele z†sobn°ku
         call      retint8                  ; n†vrat vektoru p©eru®en° INT 8
         call      scrret                   ; n†vrat obsahu a stavu obrazovky
kon1:    mov       ax,4c00h                 ; ukonáen° programu s k¢dem 0
         int       21h

;------------------------------------------------------------------------------

getexe:                                     ; poskytnut° cesty k programu GENS80
                                            ; DS = segment PSP
                                            ; ES = datovò segment
         push      di
         push      si
         push      ds
         mov       di,offset pathexe        ; cesta k programu GENS80
         mov       ax,ds:[2ch]              ; adresa segmentu prost©ed°
         mov       ds,ax                    ; segment prost©ed°
         xor       si,si                    ; ukazatel prost©ed°
getexe1: lodsb                              ; znak z ©etàzce prost©ed°
         or        al,al                    ; je bajt 0 ?
         jnz       getexe1                  ; nalezen° konce ©etàzce
         lodsb                              ; prvn° bajt dal®°ho ©etàzce
         or        al,al                    ; je nulovò ©etàzec ?
         jnz       getexe1                  ; nen° nulovò ©etàzec
         inc       si
         inc       si                       ; ignorov†n° á°taáe ©etàzcñ
         cmp       byte ptr [si+1],":"      ; je druhò znak oznaáen° disku ?
         jz        getexe3                  ; je zad†n i disk
getexe2: mov       al,es:[di+1]             ; znak cesty
         inc       di
         or        al,al
         jnz       getexe2                  ; nalezen° konce textu akt. cesty
getexe3: lodsb                              ; p©eáten° bajtu
         stosb                              ; uloëen° bajtu
         or        al,al                    ; je = 0 ?
         jnz       getexe3                  ; nebyl je®tà = 0
         pop       ds
         pop       si
         pop       di
         ret

;------------------------------------------------------------------------------

modimem:                                    ; inicializace pamàti
                                            ; DS = segment PSP
                                            ; ES = datovò segment
         push      bx
         push      cx
         push      es
         mov       ax,ds
         mov       es,ax                    ; segment PSP
         mov       ah,4ah                   ; funkce modifikace pamàti
         xor       bx,bx
         dec       bx                       ; BX = FFFFH
         int       21h                      ; pokus o nastaven° max. pamàti
         mov       ah,4ah
         int       21h                      ; modifikace na max. velikost
         pop       es
         mov       ax,offset segend         ; offset konce datovÇho segmentu
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; vydàlen° AX/4 (poáet segmentñ)
         inc       ax                       ; dÇlka datovÇho segmentu (segmentñ)
         mov       cx,ds                    ; segment PSP
         add       bx,cx                    ; koneánò segment p©idàlenÇ pamàti
         mov       cx,es                    ; datovò segment
         add       ax,cx                    ; segment konce datovÇho segmentu
         mov       es:[topmem],ax           ; poá†teán° segment pamàti dat
         mov       es:[freemem],ax          ; poá†teán° segment volnÇ pamàti
         mov       es:[endmem],bx           ; prvn° zak†zanò segment pamàti
         pop       cx
         pop       bx
         ret

;------------------------------------------------------------------------------

scrinit:                                    ; uchov†n° stavu displeje a inicial.
                                            ; DS = datovò segment
         push      si
         push      dx
         push      cx
         push      bx
         mov       ah,15                    ; funkce dotazu na souáasnò videom¢d
         int       10h                      ; poskytnut° souáasnÇho videom¢du
         mov       [sysmod],al              ; systÇmovò videom¢d
         cmp       al,3                     ; je videom¢d 3 ?
         jz        scrini1
         cmp       al,2                     ; je alternativn° videom¢d 2 ?
         jnz       scrini2
scrini1: mov       [videomod],al            ; nastaven° videom¢du 2 nebo 3
scrini2: mov       ah,3                     ; funkce áten° pozice kurzoru
         xor       bh,bh                    ; str†nka 0 displeje
         int       10h                      ; áten° pozice kurzoru
         mov       [syspoz],dx              ; pozice kurzoru v systÇmu
         mov       [syskurz],cx             ; velikost kurzoru v systÇmu
         call      ulozob                   ; uloëen° systÇmovÇ obrazovky
         call      init                     ; inicializace displeje
         call      clear                    ; z†kladn° zobrazen° displeje
         pop       bx
         pop       cx
         pop       dx
         pop       si
         ret

;------------------------------------------------------------------------------

scrret:                                     ; n†vrat obsahu a stavu displeje
                                            ; DS = datovò segment
         push      bx
         mov       al,[sysmod]              ; systÇmovò videom¢d
         mov       [videomod],al            ; n†vrat systÇmovÇho videom¢du
         call      init                     ; zpàtn† inicializace obrazovky
         call      navrob                   ; navr†cen° obsahu obrazovky
         mov       dx,[syspoz]              ; pozice kurzoru v systÇmu
         xor       bh,bh                    ; str†nka 0 displeje
         mov       ah,2                     ; funkce nastaven° pozice kurzoru
         int       10h                      ; nastaven° pozice kurzoru
         mov       cx,[syskurz]             ; velikost kurzoru v systÇmu
         mov       ah,1                     ; funkce nastaven° velikosti kurzoru
         int       10h                      ; nastaven° pñvodn° velikosti kurz.
         pop       bx
         ret

;------------------------------------------------------------------------------

init:                                       ; inicializace displeje
         push      ax
         push      si
         push      di
         push      bp
         mov       ah,15                    ; dotaz na nastavenò videom¢d
         int       10h
         cmp       al,ds:[videomod]         ; odpov°d† poëadovanÇmu videom¢du ?
         jz        init1                    ; videom¢d je jië nastaven
         xor       ah,ah
         mov       al,ds:[videomod]         ; nastaven° m¢du displeje
         int       10h                      ; textovò reëim 80x25
init1:   pop       bp
         pop       di
         pop       si
         pop       ax
         ret

;------------------------------------------------------------------------------

clear:                                      ; z†kladn° zobrazen° displeje
                                            ; DS = datovò segment
         push      dx
         push      cx
         push      bx
         push      si
         mov       ah,ds:[coltext]          ; barva textu
         mov       dx,100h                  ; poá†tek obrazovky ©†dek 1, poz. 0
         mov       cx,23*256+80             ; rozmàry obrazovky 23 * 80
         call      box                      ; vymaz†n° obrazovky
         dec       dh                       ; poá†tek ©†dku - ©†dek 0, pozice 0
         mov       cx,1*256+80              ; rozmàry ©†dku 1 * 80
         mov       ah,ds:[colinf]           ; barva informaán°ch ©†dkñ
         call      box                      ; nastaven° horn°ho ©†dku
         mov       dh,24                    ; poá†tek spodn°ho ©†dku (©.24/p.0)
         call      box                      ; nastaven° spodn°ho ©†dku
         mov       cx,1*256+10              ; rozmàry okna pro hodiny
         mov       dx,70                    ; poá†tek okna pro hodiny
         mov       ah,ds:[colclck]          ; barva okna pro hodiny
         call      box                      ; nastaven° okna pro hodiny
         mov       dx,0                     ; poá†tek pro tisk textu horn°ho ©.
         mov       si,offset text1          ; text horn°ho ©†dku
         call      zobtext                  ; zobrazen° horn°ho ©†dku
         mov       si,offset text2          ; text spodn°ho ©†dku
         mov       dx,24*256                ; zaá†tek spodn°ho ©†dku
         call      zobtext                  ; zobrazen° spodn°ho ©†dku
         pop       si
         pop       bx
         pop       cx
         pop       dx
         ret

;------------------------------------------------------------------------------

inint8:                                     ; inicializace obsluhy INT 8
         push      ds
         push      es
         push      bx
         mov       ax,3508h                 ; funkce poskytnut° vektoru INT 8
         int       21h
         mov       cs:[adr_int8],bx         ; offset adresy obsluhy INT 8
         mov       cs:[adr_int8+2],es       ; segment obsluhy INT 8
         mov       ax,cs
         mov       ds,ax
         mov       dx,offset int8           ; vlastn° obsluha INT 8
         mov       ax,2508h                 ; funkce nastaven° vektoru INT 8
         int       21h                      ; nastaven° adresy vlastn° obsluhy
         pop       bx
         pop       es
         pop       ds
         ret

;------------------------------------------------------------------------------

retint8:                                    ; n†vrat vektoru p©eru®en° INT 8
         push      ds
         push      dx
         mov       dx,cs:[adr_int8]
         mov       ds,cs:[adr_int8+2]
         mov       ax,2508h                 ; funkce nastaven° vektoru INT 8
         int       21h                      ; nastaven° adresy vlastn° obsluhy
         pop       dx
         pop       ds
         ret

;------------------------------------------------------------------------------
;                          Z†kladn° akce
;------------------------------------------------------------------------------

akcemenu1:
         xor       ax,ax                    ; akán° kl†vesa
akcemen1:
         mov       si,offset tabmenu1       ; menu
         call      menu
         ret

akcemenu4:                                  ; proveden° akce menu 4 (Define)
         mov       si,offset tabmenu4
akcemen: xor       ax,ax
         call      menu
         jmp       short akcemenu1                ; vyvol†n° menu 1

akcemenu5:                                  ; proveden° akce menu 5 (File)
         mov       si,offset tabmenu5
         jmp       short akcemen

         db        0,1,2,3,4,5,6

akcemenuf:
         push      di
         push      es
         mov       ax,ds:[freemem]          ; segment volnÇ pamàti
         mov       es,ax
         mov       di,0                     ; offset bufferu
         mov       dx,offset selall         ; specifikace v®ech souborñ
         call      loaddir                  ; naáten° souborñ z akt. adres†©e
         mov       dx,ds:[aktfile]          ; á°slo prvn° poloëky k p©enesen°
         call      ulozob                   ; uloëen° obrazovky
akcmnf1: mov       si,offset txtmenf1       ; text poloëek menu
         mov       cx,10                    ; poáet poloëek k p©enesen°
         mov       ds:[aktfile],dx          ; uloëen° prvn° poloëky adres†©e
         call      menudir                  ; vytvo©en° menu adres†©e
         push      dx
         mov       cx,dx                    ; ukazatel souboru
         add       cx,11                    ; á°slo posledn° poloëky souboru
         mov       si,offset tabmenuf
         call      zobmenu1                 ; zobrazen° menu
akcmnf21:push      dx
         push      si
         mov       si,offset txtmfile+2
         call      getadr                   ; poskytnut° adres†©e
         mov       [ukaztxt],si             ; ukazatel textu
         mov       si,offset tabmfile
         call      zobmenu1
         add       dx,103h                  ; zaá†tek textu
         push      cx
         push      dx
         mov       ah,ds:[colinp]           ; barva vstupn°ho textu
         mov       cx,63                    ; poáet znakñ
akcmnf22:call      putatr                   ; z†pis atributu
         loop      akcmnf22
         pop       dx
         pop       cx
         pop       si
         pop       dx
akcmnf2:
;        push      si
;        push      di
;        push      cx
;        mov       cl,[si+11]               ; á°slo aktivn° poloëky
;        xor       ch,ch
;         cmp       cl,1                     ; je prvn° poloëka ?
;         jz        akcmnf24                 ; je prvn°
;akcmnf23:inc       si
;         cmp       [si-1],31                ; je = 0 ?
;         jnz       akcmnf23                 ; nalezen° konce poloëky
;         loop      akcmnf23                 ; dal®° poloëka
;akcmnf24:mov       di,ds:[ukaztxt]          ; ukazatel textu
;akcmnf25:lodsb
;         cmp       al,32
;         jnz       akcmnf26
;         mov       al,"."
;         stosb
;akcmnf26:
;
;         mov       si,[ukaztxt]             ; ukazatel textu
;
;         mov       si,offset
         call      kurzmenu                 ; zobrazen° kurzoru
         call      posunmenu                ; posun menu
         jnc       akcmnf21                 ; byl posun menu
         cmp       ax,13                    ; kl†vesa <Enter> ?
         jz        akcmnf9                  ; konec - vybr†no
         cmp       ax,150h                  ; kurzor dolñ
         jnz       akcmnf3                  ; nen° kurzor dolñ
         call      zvysmenu                 ; zvò®en° menu
         jnc       akcmnf2                  ; nov† pozice kurzoru
         cmp       cx,ds:[numfiles]         ; je dosaëeno posledn°ho souboru ?
         jnc       akcmnf2                  ; je dosaëeno posledn°ho souboru
         pop       dx                       ; ukazatel poá†teán°ho souboru
         inc       dx                       ; zvò®en° ukazatele poá†t. souboru
         jmp       short akcmnf1            ; zobrazen° novÇho menu souborñ
akcmnf3: cmp       ax,148h                  ; kurzor nahoru
         jnz       akcmnf4                  ; nen° kurzor nahoru
         call      snizmenu                 ; sn°ëen° menu
         jnc       akcmnf2                  ; nov† pozice kurzoru
         cmp       cx,13                    ; je dosaëeno prvn°ho souboru ?
         jc        akcmnf2                  ; je dosaëeno prvn°ho souboru
         pop       dx                       ; ukazatel poá†teán°ho souboru
         dec       dx                       ; sn°ëen° ukazatele poá†t. souboru
         jmp       short akcmnf1            ; zobrazen° novÇho menu souborñ
akcmnf4: cmp       ax,147h                  ; je kl†vesa <Home> ?
         jnz       akcmnf5                  ; nen° kl†vesa <Home>
akcmnf41:call      snizmenu                 ; sn°ëen° menu
         jnc       akcmnf41                 ; dal®° sn°ëen° menu
         cmp       cx,13                    ; je dosaëeno prvn°ho souboru ?
         jc        akcmnf2                  ; je dosaëeno prvn°ho souboru
         pop       dx                       ; ukazatel poá†teán°ho souboru
akcmnf42:mov       dx,1                     ; nastaven° ukazatele poá†t. souboru
         jmp       akcmnf1                  ; zobrazen° novÇho menu souborñ
akcmnf5: cmp       ax,14fh                  ; je kl†vesa <End> ?
         jnz       akcmnf6                  ; nen° kl†vesa <End>
akcmnf51:call      zvysmenu                 ; zvò®en° menu
         jnc       akcmnf51                 ; dal®° zvò®en° menu
         cmp       cx,ds:[numfiles]         ; je dosaëeno posledn°ho souboru ?
         jnc       akcmnf2                  ; je dosaëeno posledn°ho souboru
         pop       dx                       ; ukazatel poá†teán°ho souboru
         mov       dx,ds:[numfiles]         ; á°slo posledn°ho souboru
         sub       dx,11                    ; odeáten° poátu poloëek
         jbe       akcmnf42
         jmp       akcmnf1
akcmnf6:

akcmnf8: cmp       ax,27                    ; je kl†vesa <Esc> ?
         jnz       akcmnf2

akcmnf9: call      navrob                   ; navr†cen° obrazovky
         pop       dx
         pop       es
         pop       di
         jmp       akcemenu5

;------------------------------------------------------------------------------
;                   Procedury pro pr†ci s adres†©i
;------------------------------------------------------------------------------

loaddir:                                    ; naáten° souborñ aktu†l. adres†©e
                                            ; DS:DX ©etàzec specifikace souborñ
                                            ; ES:DI vòpis souborñ (po 16 B)
         push      ax
         push      cx
         push      di
         push      si
         xor       cx,cx
         mov       [numfiles],cx            ; poáet souborñ v adres†©i = 0
         mov       cl,10h                   ; atribut adres†©ovòch souborñ
         mov       ah,4eh
         int       21h                      ; nalezen° prvn°ho podadres†©e
         jc        loaddr0                  ; nen° podadres†©
         call      transsdr                 ; p©enesen° podadres†©e do bufferu
loadd01: mov       ah,4fh
         int       21h                      ; nalezen° dal®°ho podadres†©e
         jc        loaddr0                  ; nen° jië dal®° podadres†©
         call      transsdr                 ; p©enesen° podadres†©e do bufferu
         jmp       short loadd01
loaddr0: mov       cl,0                     ; atributy = norm†ln° soubory
         mov       ah,4eh
         int       21h                      ; nalezen° prvn° poloëky adres†©e
         jc        loaddr3                  ; soubor nenalezen
         call      transdir                 ; p©enesen° jmÇna souboru do bufferu
loaddr1:
         mov       ah,4fh
         int       21h                      ; nalezen° dal®°ho souboru
         jc        loaddr2                  ; nen° jië dal®° soubor
         call      transdir                 ; p©enesen° jmÇna souboru do bufferu
         jmp       short loaddr1            ; dal®° jmÇno souboru
loaddr2: clc
         mov       ax,ds:[aktfile]          ; aktivn° soubor
         or        ax,ax                    ; je = 0 ?
         jz        loaddr22
         add       ax,10
         cmp       ax,ds:[numfiles]         ; poáet souborñ
         clc
         jnc       loaddr3
loaddr22:mov       ax,1
         mov       ds:[aktfile],ax          ; aktivn° soubor = 1
loaddr3: pop       si                       ; pokud CF = 1 soubor nenalezen
         pop       di
         pop       cx
         pop       ax
         ret

;------------------------------------------------------------------------------

transsdr:                                   ; p©enos podadres†©e z DTA
                                            ; ES:DI ukl†dac° buffer
         push      ds
         push      si
         push      cx
         push      ax
         mov       ax,seg data              ; datovò segment
         mov       ds,ax
         mov       al,ds:[dta + 15h]        ; atribut nalezenÇho souboru
         test      al,10h                   ; je adres†© ?
         jz        transs5                  ; nen° adres†©
         mov       si,offset dta + 1eh      ; offset jmÇna souboru
         cmp       word ptr [si],002eh      ; porovn†n° - je adres†© "." ?
         jz        transs5                  ; ignorov†n° adres†©e "."
         push      di
         mov       al," "
         mov       cx,11                    ; poáet znakñ k vymaz†n°
         rep       stosb                    ; vymaz†n° jmÇna
         pop       di                       ; ukl†dac° adresa
         push      di                       ; ukl†dac° adresa
         mov       cx,11                    ; max. poáet znakñ k p©enosu
transs1: lodsb                              ; p©eáten° znaku jmÇna souboru
         or        al,al                    ; je konec roz®°©en° jmÇna ?
         jz        transs4                  ; konec p©enosu
         stosb                              ; uloëen° znaku
         loop      transs1                  ; dal®° znak
transs4: pop       di                       ; ukl†dac° adresa
         add       di,11                    ; offset pro uloëen° atributu soub.
         mov       si,offset dta + 15h      ; offset atributu souboru
         mov       cx,5
         rep       movsb                    ; p©enesen° atr.,áasu a data souboru
         inc       word ptr [numfiles]      ; zvò®en° á°taáe souborñ
transs5: pop       ax
         pop       cx
         pop       si
         pop       ds
         ret

;------------------------------------------------------------------------------

transdir:                                   ; p©enos poloëky adres†©e z DTA
                                            ; ES:DI ukl†dac° buffer
         push      ds
         push      si
         push      cx
         push      ax
         mov       ax,seg data              ; datovò segment
         mov       ds,ax
         mov       si,offset dta + 1eh      ; offset jmÇna souboru
         push      di
         mov       al," "
         mov       cx,11                    ; poáet znakñ k vymaz†n°
         rep       stosb                    ; vymaz†n° jmÇna
         pop       di                       ; ukl†dac° adresa
         push      di                       ; ukl†dac° adresa
         mov       cx,8                     ; poáet znakñ k p©enosu
transd1: lodsb                              ; p©eáten° znaku jmÇna souboru
         or        al,al                    ; je konec jmÇna ?
         jz        transd4                  ; konec p©enosu
         cmp       al,"."                   ; je oddàlovaá roz®°©en° souboru ?
         jz        transd2                  ; n†sleduje roz®°©en° souboru
         call      lowercase                ; p©evod na malÇ p°smeno
         stosb                              ; uloëen° znaku
         loop      transd1                  ; dal®° znak
         lodsb
         or        al,al
         jz        transd4                  ; je konec jmÇna
transd2: mov       cx,3                     ; poáet znakñ extentu
         pop       di
         push      di                       ; ukl†dac° adresa
         add       di,8                     ; offset pro ukl†d†n° roz®°©en°
transd3: lodsb
         or        al,al                    ; je konec roz®°©en° jmÇna ?
         jz        transd4                  ; konec p©enosu
         call      lowercase                ; p©evod na malÇ p°smeno
         stosb                              ; uloëen° znaku
         jmp       short transd3            ; dal®° znak
transd4: pop       di                       ; ukl†dac° adresa
         add       di,11                    ; offset pro uloëen° atrib. soub.
         mov       si,offset dta + 15h      ; offset atrib. souboru
         mov       cx,5
         rep       movsb                    ; p©enesen° áasu a data souboru
         inc       word ptr [numfiles]      ; zvò®en° á°taáe souborñ
         pop       ax
         pop       cx
         pop       si
         pop       ds
         ret
;------------------------------------------------------------------------------

menudir:                                    ; p©enos poloëek adres†©e do menu
                                            ; DS:SI = poloëky menu (po 14 B)
                                            ; ES:DI = buffer adres†©e (po 16 B)
                                            ; CX = poáet poloëek k p©enesen°
                                            ; DX = poá†teán° á°slo poloëky
         push      ds                       ; poloëky menu
         push      es                       ; buffer adres†©e
         push      si                       ; poloëky menu
         push      di                       ; buffer adres†©e
         push      si
         push      di
         pop       si
         pop       di
         push      es
         push      ds
         pop       es
         pop       ds
         push      ax
         push      dx                       ; poá†teán° á°slo poloëky
         or        dx,dx                    ; je DX = 0 ?
         jz        menudr2                  ; chyba zad†n°
         or        cx,cx                    ; je CX = 0 ?
         jz        menudr2                  ; chyba zad†n°
menudr3: dec       dx
         jz        menudr4
         add       si,16                    ; zvò®en° ukazatele poloëky v buff.
         jmp       short menudr3
menudr4: pop       dx                       ; á°slo poloëky
         push      dx
         push      cx                       ; poáet poloëek k p©enesen°
menudr1: mov       byte ptr es:[di],3       ; tabel†tor textu
         inc       di
         inc       dx                       ; zvò®en° ukazatele poloëek
         push      cx
         mov       cx,12
         mov       al,' '
         cmp       dx,ds:[numfiles]         ; je p©ekroáen poáet souborñ ?
         jc        menudr52                 ; nen° vàt®° neë max. poáet
         rep       stosb                    ; vymaz†n° znaku
         jmp       short menudr6
menudr52:test      byte ptr [si+11],10h     ; atribut souboru = adres†© ?
         jz        menudr5                  ; nen° adres†©
         dec       cx
         mov       byte ptr es:[di],">"     ; oznaáen° adres†©e
         mov       byte ptr es:[di-1],2     ; sn°ëen° tabel†toru textu
         inc       di
         rep       movsb
         add       si,5
         jmp       short menudr6
menudr5: lodsb
         cmp       cx,4                     ; zaá°n† extent souboru ?
         jnz       menudr51
         mov       al," "                   ; oddàlovac° mezera
         test      byte ptr [si+2],1        ; je atribut z†kazu z†pisu ?
         jz        menudr53                 ; nen° z†kaz z†pisu
         mov       al,'*'                   ; oznaáen° chr†nànÇho souboru
menudr53:dec       si
menudr51:stosb
         loop      menudr5                  ; p©enesen° poloëky
         add       si,5                     ; p©eskoáen° £dajñ o áase a datu
menudr6: inc       di                       ; p©eskoáen° bajtu 31
         pop       cx
         loop      menudr1                  ; dal®° poloëka k p©enesen°
         pop       cx
menudr2: pop       dx
         pop       ax
         pop       di
         pop       si
         pop       es
         pop       ds
         ret

;------------------------------------------------------------------------------

getadr:                                     ; poskytnut° aktivn°ho adres†©e
                                            ; DS:SI = ukazatel bufferu 64 Bajtñ
                                            ; vòstup SI = konec textu
         push      ax
         push      cx
         push      dx
         mov       ah,19h
         int       21h                      ; poskytnut° aktu†ln°ho disku
         add       al,"A"                   ; korekce na znak ASCII
         mov       [si],al                  ; uloëen° znaku disku
         inc       si
         mov       byte ptr [si],":"        ; oddàlovac° znak
         inc       si
         mov       byte ptr [si],"\"        ; oddàlovac° znak
         inc       si
         mov       ah,47h
         mov       dl,0                     ; aktivn° disk
         int       21h                      ; poskytnut° aktu†ln°ho adres†©e
getadr1: inc       si
         cmp       byte ptr [si],0          ; nalezen° konce textu
         jnz       getadr1
         cmp       byte ptr [si-1],"\"      ; byl koncovò znak "\" ?
         jz        getadr2                  ; ano, byl znak "\"
         mov       byte ptr [si],"\"
         inc       si
getadr2: pop       dx
         pop       cx
         pop       ax
         ret

;------------------------------------------------------------------------------
;                        Disassembler
;------------------------------------------------------------------------------

disas:                                      ; disassemblov†n° instrukce
                                            ; DS:SI adresa instrukce
                                            ; DX = pozice kurzoru
                                            ; DS:SI nov† adresa
         push      ax
         push      di
         mov       al,[pozins]              ; pozice instrukce
         call      tabel                    ; tabel†tor
         mov       di,offset tab0           ; z†kladn° tabulka instrukc°
         xor       al,al
         mov       [prefdd],al              ; vynulov†n° prefixu DD, FD
         mov       [prefed],al              ; vynulov†n° prefixu ED, CB
disas1:  lodsb                              ; naáten° k¢du instrukce do AL
         cmp       al,0ddh                  ; prefix IX
         jz        disas2
         cmp       al,0fdh                  ; prefix IY
         jnz       disas3
disas2:  mov       [prefdd],al
         jmp       short disas1
disas3:  cmp       al,0cbh                  ; prefix CB
         jnz       disas4
         mov       di,offset tabcb
         jmp       short disas5
disas4:  cmp       al,0edh                  ; prefix ED
         jnz       disas6
         mov       di,offset tabed
disas5:  mov       [prefed],al
         lodsb                              ; p©eáten° operandu instrukce
disas6:  call      hledkod                  ; nalezen° textu instrukce DS:DI
         call      textins                  ; tisk textu instrukce
         mov       byte ptr [pozice],0      ; nastaven° novÇho ©†dku
         inc       byte ptr [radek]
         pop       di
         pop       ax
         ret

;------------------------------------------------------------------------------

textins:                                    ; vòstup textu instrukce
                                            ; DS:DI ukazatel textu
                                            ; DS:SI adresa instrukce
                                            ; DX pozice kurzoru
         push      di
         push      cx
         push      bx
         push      ax
textin0: push      di
textin1: pop       di                       ; ukazatel textu instrukce
         mov       al,es:[di]               ; znak k vòstupu
         inc       di
         push      di
         mov       di,offset tbskok         ; tabulka skokñ
         mov       cx,cs:[di]               ; poáet adres
textin2: inc       di
         cmp       al,cs:[di]               ; je hledanò znak ?
         jz        textin3
         inc       di
         inc       di
         loop      textin2                  ; dal®° pokus
textin8: pop       di
         call      outchr                   ; vòstup znaku
         jmp       textin0

textin3: mov       bx,cs:[di+1]             ; adresa skoku
         jmp       bx                       ; skok na danou adresu

textin9: pop       di                       ; ukonáen° programu textins
         pop       ax
         pop       bx
         pop       cx
         pop       di
         ret

;------------------------------------------- obsluhy symbolickòch tiskñ

textmez:                                    ; tabelaán° mezera argumentu
         mov       al,[pozoper]             ; pozice operandu instrukce
         call      tabel                    ; tabel†tor
         jmp       short textin1

texta:                                      ; argument 2 bajty (adresa)
         lodsw                              ; operand instrukce 2 bajty
texta1:  call      outwrd                   ; tisk slova (adresy)
texta2:  mov       al,"H"                   ; tisk znaku H
         call      outchr
         jmp       short textin1

textb:                                      ; parametr bitovòch instrukc°
         mov       di,offset tabb           ; tabulka operandñ bitovòch instr.
         jmp       short textc0             ; p©ek¢dov†n°

textc:                                      ; podm°nka
         mov       di,offset tabc           ; tabulka podm°nek
textc0:  dec       si
         lodsb                              ; k¢d instrukce
textc2:  call      hledkod                  ; nalezen° textu v tabulce DI
         call      textins                  ; tisk textu z tabulky DI
textc1:  jmp       short textin1

textd:                                      ; argument 1 bajt se znamÇnkem
         lodsb                              ; p©eáten° argumentu instrukce
         or        al,al                    ; je kladnÇ á°slo ?
         mov       al,"+"
         jns       textd2                   ; je kladnÇ á°slo
         mov       al,"-"
         call      outchr                   ; tisk znamÇnka -
         xor       al,al
         sub       al,[si-1]                ; negace operandu
textd1:  call      outbyte
         jmp       short texta2
textd2:  call      outchr                   ; tisk znamÇnka +
         mov       al,[si-1]                ; operand
         jmp       short textd1

texte:                                      ; relativn° skok
         lodsb                              ; p©eáten° operandu instrukce
         xor       ah,ah
         add       ax,si                    ; p©iáten° absolutn° adresy
         test      byte ptr [SI],80h        ; je kladnÇ á°slo ?
         jz        texta1                   ; tisk slova (adresy)
         dec       ah
         jmp       short texta1

textf:                                      ; registr typu 1 a dÇlky 2 bajty
         mov       di,offset tabf
         jmp       short textc0

textg:                                      ; registr typu 2 a dÇlky 2 bajty
         mov       di,offset tabg
         jmp       short textc0

texth:                                      ; registr HL, IX, IY
         mov       di,offset tabh
texth1:  mov       al,[prefdd]              ; prefix DD, FD
         jmp       short textc2

textn:                                      ; argument 1 bajt bez znamÇnka
         lodsb                              ; p©eáten° argumentu 1 bajt
         jmp       short textd1

texto:                                      ; aritmetick† operace
         mov       di,offset tabo
         jmp       short textc0

textr:                                      ; doplnàk instrukc° LDIR, ...
         mov       di,offset tabr
         jmp       short textc0

texts:                                      ; argument instrukce RST
         mov       al,[si-1]                ; k¢d instrukce
         and       al,38h
         jmp       short textd1             ; tisk operandu

textu:                                      ; registr typu 1 a dÇlky 1 bajt
         mov       di,offset tabu
         jmp       short textc0

textv:                                      ; registr typu 2 a dÇlky 1 bajt
         mov       di,offset tabv
         jmp       short textc0

textw:                                      ; registr typu 3 a dÇlky 1 bajt
         jmp       textin8
textx:                                      ; parametr (IX+d), (IY+d)
         mov       di,offset tabx
         jmp       short texth1

;------------------------------------------- tabulka skokñ na vòstupn° procedury

tbskok:                                     ; tabulka skokñ
         db        18                       ; poáet adres skokñ
         db        0                        ; ukonáovac° bajt 0
         dw        textin9                  ; konec tisku textu
         db        ' '                      ; tabelaán° mezera
         dw        textmez
         db        'a'                      ; argument 2 bajty (adresa)
         dw        texta
         db        'b'                      ; parametr bitovòch instrukc°
         dw        textb
         db        'c'                      ; podm°nka
         dw        textc
         db        'd'                      ; argument 1 bajt se znamÇnkem
         dw        textd
         db        'e'                      ; relativn° skok
         dw        texte
         db        'f'                      ; registr typu 1 a dÇlky 2 bajty
         dw        textf
         db        'g'                      ; registr typu 2 a dÇlky 2 bajty
         dw        textg
         db        'h'                      ; registr HL, IX, IY
         dw        texth
         db        'n'                      ; argument 1 bajt bez znamÇnka
         dw        textn
         db        'o'                      ; aritmetick† operace
         dw        texto
         db        'r'                      ; doplnàk instrukc° LDIR, ...
         dw        textr
         db        's'                      ; argument instrukce RST
         dw        texts
         db        'u'                      ; registr typu 1 a dÇlky 1 bajt
         dw        textu
         db        'v'                      ; registr typu 2 a dÇlky 1 bajt
         dw        textv
         db        'w'                      ; registr typu 3 a dÇlky 1 bajt
         dw        textw
         db        'x'                      ; parametr (IX+d), (IY+d)
         dw        textx

;------------------------------------------------------------------------------

hledkod:                                    ; hled†n° k¢du v tabulce
                                            ; ES:DI = prohled†van† tabulka
                                            ; AL = hledanò k¢d
                                            ; vòstup ES:DI = adresa poloëky
                                            ; CF = 1 - poloëka nenalezena
         push      cx
         mov       cl,es:[di]               ; poáet blokñ
         inc       di
         xor       ch,ch
hledko1: push      cx                       ; á°taá blokñ
         mov       cl,es:[di]               ; poáet poloëek v bloku
         inc       di
         push      ax                       ; hledanò k¢d
         and       al,es:[di]               ; maskov†n° k¢du
         inc       di
hledko2: cmp       al,es:[di]               ; odpov°d† hledanÇmu k¢du ?
         jz        hledko5                  ; k¢d nalezen
hledko3: inc       di
         cmp       byte ptr es:[di],0       ; je konec poloëky ?
         jnz       hledko3                  ; nalezen° konce poloëky
         inc       di                       ; zaá†tek dal®° poloëky
         loop      hledko2                  ; dal®° poloëka v bloku
         pop       ax                       ; hledanò k¢d
         pop       cx                       ; á°taá blokñ
         loop      hledko1                  ; dal®° blok tabulky
         stc
         jmp       short hledko6            ; konec - nenalezeno
hledko5: pop       ax
         pop       cx
         inc       di
hledko6: pop       cx
         ret


;------------------------------------------------------------------------------
;                         sluëby menu
;------------------------------------------------------------------------------

comment %

tabmenu1 dw        txtmenu1                 ; SI+0 adresa textu menu1
         dw        hlpmenu1                 ; SI+2 adresa helpu menu
         dw        adrmenu1                 ; SI+4 adresa menu na displeji
         db        30                       ; SI+6 ®°©ka r†meáku menu
         db        10                       ; SI+7 vò®ka r†meáku menu
         db        2                        ; SI+8 poá†tek kurzoru
         db        20                       ; SI+9 dÇlka kurzoru
         db        0                        ; SI+10 poáet poloëek menu
         db        0                        ; SI+11 aktivn° poloëka menu
%

menu:                                       ; svislÇ menu
                                            ; DS:SI = adresa definice menu
                                            ; AX = akán° kl†vesa
                                            ; n†vrat AX = kl†vesa
         push      di
         push      dx
         call      ulozob                   ; uloëen° obrazovky
         call      zobmenu1                 ; zobrazen° menu
         jmp       short menu11
menu1:   call      klicmenu                 ; zobrazen° kl°áovòch znakñ menu
         call      kurzmenu                 ; zobrazen° kurzoru menu
menu11:  call      posunmenu                ; posun menu podle kl†ves
         jnc       menu1                    ; stisknuta kl†vesa SHIFT
         cmp       ax,13                    ; kl†vesa <Enter>
         jz        menu8                    ; vyvol†n° aktivn° poloëky
         cmp       ax,148h                  ; kurzor nahoru
         jnz       menu2                    ; nen° kurzor nahoru
         call      snizmenu                 ; sniëen° menu
         jmp       short menu1
menu2:   cmp       ax,150h                  ; kurzor dolñ
         jnz       menu3                    ; nen° kurzor dolñ
         call      zvysmenu                 ; zvò®en° menu
         jmp       short menu1
menu3:   cmp       ax,147h                  ; kl†vesa Home
         jnz       menu4                    ; nen° kl†vesa Home
menu31:  call      snizmenu                 ; sn°ëen° ukazatele menu
         jnc       menu31                   ; dal®° pozice ukazatele
         jmp       short menu1              ; je jië okraj menu
menu4:   cmp       ax,14fh                  ; je kl†vesa End ?
         jnz       menu5                    ; nen° je®tà kl†vesa End
menu41:  call      zvysmenu                 ; zvò®en° ukazatele menu
         jnc       menu41                   ; dal®° zvò®en° ukazatele
         jmp       short menu1              ; je jië okraj menu
menu5:   call      hledklic                 ; hled†n° kl°áe
         jc        menu6                    ; kl°á nenalezen
         mov       [si+11],al               ; nastaven° aktivn° poloëky menu
menu8:   mov       al,[si+11]
         push      si
menu51:  add       si,4
         dec       al
         jnz       menu51
         mov       ax,[si+10]               ; adresa akce
         pop       si
         call      navrob                   ; navr†cen° obrazovky
         pop       dx
         pop       di
         inc       sp
         inc       sp                       ; zru®en° n†vratovÇ adresy
         push      ax                       ; adresa akce
         ret                                ; vyvol†n° akce

menu6:   cmp       ax,1ch                   ; kl†vesa Ctrl-\
         jz        menu7                    ; skok do z†kladn°ho menu
         cmp       ax,27                    ; kl†vesa <Esc>
         jnz       menu1
         push      ax
         xor       ax,ax
         push      ds
         mov       ds,ax
         mov       al,ds:[0417h]            ; statut p©esmykaáñ
         test      al,4                     ; test kl†vesy Ctrl
         pop       ds
         pop       ax
         jz        menu9                    ; nen° stisknuta kl†vesa Ctrl
         mov       al,2
         mov       [ukazobr],al             ; nastaven° ukazatele obrazovky
         mov       sp,[stackp]              ; n†vrat ukazatele z†sobn°ku
         sub       sp,6                     ; navr†cen° posledn°ch poloëek
         call      navrob                   ; navr†cen° obrazovky
         pop       dx
         pop       di
         ret

menu9:   call      navrob                   ; navr†cen° obrazovky
         pop       dx
         pop       di
menuret: ret

menu7:   mov       al,2
         mov       [ukazobr],al             ; nastaven° ukazatele obrazovky
         mov       sp,[stackp]              ; n†vrat ukazatele z†sobn°ku
         sub       sp,6                     ; navr†cen° posledn°ch poloëek
         call      navrob
         pop       dx
         pop       di
         xor       ax,ax
         mov       si,offset tabmenu1       ; vyvol†n° menu 1
         jmp       menu                     ; n†vrat z menu


;------------------------------------------------------------------------------

zvysmenu:                                   ; zvò®en° poloëky menu
                                            ; DS:SI adresa definice menu
                                            ; vòstup CF=1 nen° jië dal®° pol.
         push      ax
         mov       al,[si+11]               ; aktivn° poloëka menu
zvsmn3:  cmp       al,[si+10]               ; je jië posledn° poloëka ?
         cmc
         jc        zvsmn1                   ; je jië posledn°
         inc       al                       ; zvò®en° poloëky
         push      si
         push      ax
zvsmn2:  add       si,4
         dec       al
         jnz       zvsmn2
         cmp       byte ptr [si+8],0        ; je poloëka vypnut† ?
         pop       ax
         pop       si
         jz        zvsmn3                   ; je vypnut† - dal®° poloëka
         mov       [si+11],al               ; uloëen° novÇ poloëky
         clc
zvsmn1:  pop       ax
         ret

;------------------------------------------------------------------------------

snizmenu:                                   ; sn°ëen° poloëky menu
                                            ; DS:SI adresa definice menu
                                            ; vòstup CF=1 nen° jië dal®° pol.
         push      ax
         mov       al,[si+11]               ; aktivn° poloëka menu
snzmn1:  cmp       al,2                     ; je jië prvn° poloëka ?
         jc        snzmn3                   ; je jië prvn°
         dec       al                       ; sn°ëen° poloëky
         push      si
         push      ax
snzmn2:  add       si,4
         dec       al
         jnz       snzmn2                   ; vòpoáet adresy poloëky menu
         cmp       byte ptr [si+8],0        ; je poloëka vypnut† ?
         pop       ax
         pop       si
         jz        snzmn1                   ; dal®° poloëka
         mov       [si+11],al               ; uloëen° novÇ poloëky
         clc
snzmn3:  pop       ax
         ret

;------------------------------------------------------------------------------

posunmenu:                                  ; posune menu podle kl†vesy AX
                                            ; (pokud je stisknut SHIFT)
                                            ; DS:SI = ukazatel menu
                                            ; vòstup: DX = nov† pozice menu
                                            ; CF = 1 nenastal posun
         push      di
         push      cx
         push      ax
         cmp       ax,9                     ; kl†vesa <Tab> ?
         jnz       posmenb                  ; nen° <Tab>
         push      ax
         mov       al,[paradr]
         xor       al,1
         mov       [paradr],al
         pop       ax
posmenb: call      adrmenu                  ; adresa menu na displeji
         cmp       ax,9
         jz        posmen2
         push      ds
         xor       ax,ax
         mov       ds,ax                    ; segment 0
         mov       al,byte ptr ds:[417h]
         test      al,3                     ; test p©esmykaáñ SHIFT
         pop       ds
         stc
         jz        posmen1                  ; nen° stisknut p©esmykaá SHIFT
         pop       ax                       ; navr†cen° ovl†dac° kl†vesy
         push      ax
         mov       dx,[di]                  ; pozice menu
         mov       cx,[si+6]                ; rozmàry menu
         cmp       ax,14dh                  ; ®ipka vpravo
         jnz       posmen3                  ; nen° ®ipka vpravo
         inc       dl
         push      dx
         add       dl,cl
         cmp       dl,81                    ; dosaëeno okraje ?
         pop       dx
         jc        posmen2                  ; nedosaëeno
         dec       dl                       ; navr†cen° polohy
         jmp       short posmen0
posmen3: cmp       ax,14bh                  ; ®ipka vlevo
         jnz       posmen4                  ; nen° ®ipka vlevo
         dec       dl                       ; korekce vlevo
         jns       posmen2
         inc       dl
         jmp       short posmen0
posmen4: cmp       ax,150h                  ; ®ipka dolñ
         jnz       posmen5                  ; nen° ®ipka dolñ
         inc       dh
         push      dx
         add       dh,ch
         cmp       dh,26                    ; dosaëeno okraje ?
         pop       dx
         jc        posmen2                  ; nedosaëeno
         dec       dh                       ; navr†cen° polohy
         jmp       short posmen0
posmen5: cmp       ax,148h                  ; ®ipka nahoru
         jnz       posmen6                  ; nen° ®ipka nahoru
         dec       dh                       ; korekce nahoru
         jns       posmen2                  ; nedosaëeno okraje
         inc       dh                       ; navr†cen° pozice
         jmp       short posmen0
posmen6: cmp       ax,147h                  ; Home
         jnz       posmen7                  ; nen° Home
         mov       dl,0                     ; pozice 0
         jmp       short posmen2
posmen7: cmp       ax,14fh                  ; End
         jnz       posmen8                  ; nen° End
         mov       dl,80
         sub       dl,cl                    ; posledn° pozice
         jmp       short posmen2
posmen8: cmp       ax,149h                  ; Page Up
         jnz       posmen9                  ; nen° Page Up
         mov       dh,0                     ; ©†dek 0
         jmp       short posmen2
posmen9: cmp       ax,151h                  ; Page Down
         stc
         jnz       posmen1
         mov       dh,25
         sub       dh,ch
posmen2: call      navrob                   ; navr†cen° obrazovky
         mov       [di],dx                  ; nov† pozice menu
         call      ulozob                   ; uloëen° obrazovky
         call      zobmenu                  ; zobrazen° menu na novÇ pozici
posmen0: clc
posmen1: pop       ax
         pop       cx
         pop       di
         ret

;------------------------------------------------------------------------------

adrmenu:                                    ; adresa menu na obrazovce
                                            ; DS:SI = adresa definice menu
                                            ; vòstup DX = pozice na displeji
                                            ;        DI = ukazatel adresy pozice
         mov       di,[si+4]                ; adresa pozice menu na displeji
         push      ax
         mov       al,[paradr]              ; parametr pro volbu adresy menu
         test      al,al
         pop       ax
         jz        menu00
         inc       di
         inc       di
menu00:  mov       dx,[di]                  ; DX = poá†teán° sou©adnice menu
         ret

;------------------------------------------------------------------------------

zobmenu1:                                   ; zobrazen° menu
                                            ; DS:SI = adresa definice menu
                                            ; vòstup DX = pozice na displeji

         push      di
         call      adrmenu                  ; vòpoáet adresy menu
         pop       di
zobmenu:                                    ; zobrazen° menu
                                            ; DS:SI - adresa definice menu
                                            ; DX - poá†teán° sou©adnice okna
         push      si                       ; adresa definice menu
         push      ax
         push      bx
         push      cx
         push      dx                       ; poá†teán° sou©adnice okna
         mov       cx,[si+6]                ; rozmàry okna menu
         mov       ah,[colmenu]             ; barva menu
         call      box                      ; vykreslen° podkladu
         dec       cl
         dec       cl
         inc       dl
         call      ram                      ; nakreslen° r†meáku menu
         dec       dl
         inc       cl
         inc       cl
         call      stin                     ; vykreslen° st°nu pod r†meákem
zobmen1: mov       bl,dl                    ; poá†teán° pozice textu
         mov       si,[si]                  ; adresa textu menu
         call      zobtext                  ; zobrazen° textu menu
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         pop       si
         ret

;------------------------------------------------------------------------------

klicmenu:                                   ; zvòraznàn° kl°áovòch znakñ menu
                                            ; DS:SI - adresa definice menu
                                            ; DX - poá†teán° sou©adnice okna

         push      ax
         push      bx
         push      cx
         push      si                       ; adresa definice kurzorñ
         mov       cl,[si+10]               ; poáet poloëek menu
         or        cl,cl                    ; je nàjak† poloëka ?
         jz        klicmn3                  ; nen° ë†dn† poloëka
         xor       ch,ch
         mov       bh,ch
klicmn1: push      dx                       ; poá†teán° sou©adnice okna
         inc       bh                       ; relativn° ©†dek kurzoru
         mov       bl,[si+13]               ; pozice kl°áovÇho znaku
         add       dx,bx                    ; adresa kl°áovÇho znaku
         mov       ah,[colklic]             ; barva kl°áovÇho znaku
         cmp       byte ptr [si+12],0       ; parametr vypnut° poloëky
         jz        klicmn2                  ; nezobraz° se
         test      bl,bl                    ; je kl°áovò znak ?
         jz        klicmn2                  ; nem† bòt zobrazen
         call      putatr                   ; nastaven° atributñ kl°á. znaku
klicmn2: pop       dx                       ; poá†teán° sou©adnice okna
         add       si,4                     ; dal®° poloëka menu
         loop      klicmn1
klicmn3: pop       si                       ; adresa definice kurzorñ
         pop       cx
         pop       bx
         pop       ax
         ret

;------------------------------------------------------------------------------

kurzmenu:                                   ; zobrazen° kurzoru menu
                                            ; DS:SI = adresa definice menu
                                            ; DX = poá†teán° sou©adnice okna
                                            ; vòstup AX = stisknut† kl†vesa
         push      di
         push      si
         push      dx                       ; poá†teán° sou©adnice okna
         push      bx
         push      cx
         mov       bh,[si+11]               ; aktivn° poloëka menu
         or        bh,bh                    ; je zobrazena nàjak† poloëka ?
         jz        krzmn5                   ; nen° ë†dn† poloëka
         call      helpmenu                 ; zobrazen° n†povàdu poloëky menu
         xor       ch,ch
         mov       bl,[si+8]                ; poá†teán° pozice kurzoru
         add       dx,bx                    ; poá†teán° adresa kurzoru
         mov       cl,[si+9]                ; dÇlka kurzoru
         mov       ah,[colkurz]             ; barva kurzoru
         push      cx                       ; ®°©ka kurzoru
         push      dx                       ; adresa kurzoru
krzmn2:  call      putatr                   ; zobrazen° atributu
         loop      krzmn2
         call      inpch
         pop       dx                       ; adresa kurzoru
         pop       cx                       ; ®°©ka kurzoru
         push      ax
         mov       ah,[colmenu]             ; barva menu
krzmn3:  call      putatr
         loop      krzmn3
         pop       ax                       ; znak z kl†vesnice
krzmn5:  pop       cx
         pop       bx
         pop       dx
         pop       si
         pop       di
         call      klicmenu                 ; obnoven° kl°áovòch znakñ menu
         ret

;------------------------------------------------------------------------------

helpmenu:                                   ; zobrazen° n†povàdy aktivn° poloëky
                                            ; DS:SI = adresa definice menu
         push      dx
         push      cx
         push      bx
         push      ax
         push      si
         mov       dx,24*256                ; poá†teán° pozice n†povàdy
         mov       cx,1*256+80              ; rozmàry okna n†povàdy
         mov       ah,ds:[colinf]           ; barva informaán°ho ©†dku
         call      box                      ; vymaz†n° okna n†povàdy
         mov       cl,bh                    ; aktivn° poloëka menu
         mov       si,[si+2]                ; adresa n†povàd menu
         dec       si
hlpmn1:  inc       si
         dec       cl
         jz        hlpmn3
hlpmn2:  cmp       byte ptr [si],0
         jz        hlpmn1
         inc       si
         jmp       short hlpmn2
hlpmn3:  mov       dx,24*256+1
         call      zobtext                  ; vòstup textu
         pop       si
         pop       ax
         pop       bx
         pop       cx
         pop       dx
         ret

;------------------------------------------------------------------------------

hledklic:                                   ; hled†n° kl°áovÇho znaku menu
                                            ; (menu mus° bòt zobrazeno)
                                            ; SI = adresa definice menu
                                            ; DX = poá†teán° adresa menu
                                            ; AL = hledanò kl°á
                                            ; vòstup: pokud CF=0, je AL=poloëka
         push      bx
         push      cx
         push      ax                       ; hledanò znak
         push      si                       ; adresa definice menu
         call      upercase                 ; p©evod znaku v AL na velkÇ p°smeno
         mov       cl,[si+10]               ; poáet poloëek menu
         xor       ch,ch
         mov       bh,ch
hledkl1: push      dx                       ; poá†teán° sou©adnice okna
         inc       bh                       ; relativn° ©†dek kurzoru
         cmp       byte ptr [si+12],0       ; parametr vypnut° poloëky
         jz        hledkl2                  ; poloëka je vypnuta
         mov       bl,[si+13]               ; pozice kl°áovÇho znaku
         add       dx,bx                    ; adresa kl°áovÇho znaku
         test      bl,bl                    ; m† bòt znak zobrazen ?
         jz        hledkl2                  ; nem† bòt zobrazen
         mov       bl,al                    ; hledanò znak
         call      readchat                 ; áten° znaku kl°áe
         call      upercase                 ; p©evod na velkÇ p°smeno
         cmp       al,bl                    ; je hledanò znak ?
         pop       dx
         jz        hledkl3                  ; znak byl nalezen
         push      dx
         mov       al,bl                    ; hledanò znak
hledkl2: pop       dx                       ; poá†teán° sou©adnice okna
         add       si,4                     ; dal®° poloëka menu
         loop      hledkl1
hledkl3: pop       si                       ; adresa definice menu
         mov       al,[si+10]               ; poáet poloëek menu
         sub       al,cl                    ; á°slo poloëky
         inc       al
         cmp       al,[si+10]               ; byla poloëka nalezena ?
         pop       cx                       ; hledanò kl°á
         jz        hledkl4
         cmc
         jnc       hledkl4                  ; kl°á byl nalezen
         mov       ax,cx                    ; n†vrat hledanÇho kl°áe
hledkl4: pop       cx                       ; CF = 1 - poloëka nebyla nalezena
         pop       bx
         ret

;------------------------------------------------------------------------------
;                      ZnakovÇ vstupnà/vòstupn° operace
;------------------------------------------------------------------------------

tabel:                                      ; tabel†tor (AL=pozice tabel†toru)
         cmp       al,[pozice]              ; pozice kurzoru
         jnc       tabel1                   ; nen° je®tà dosaëeno znaáky
         ret
tabel1:  push      ax
         mov       al,32                    ; mezera
         call      outchr                   ; tisk mezery
         pop       ax
         jmp       short tabel

;------------------------------------------------------------------------------

upercase:                                   ; p©evod AL na velkÇ p°smeno
         cmp       al,128
         jnc       uperc2
         cmp       al,"a"
         jc        uperc1
         cmp       al,"z"+1
         jnc       uperc1
         sub       al,32
uperc1:  ret
uperc2:  push      cx
         push      si
         mov       si,offset tabuper        ; tabulka pro p©evod p°smen
         mov       cl,[si]                  ; poáet poloëek tabulky
         xor       ch,ch
uperc3:  cmp       al,[si+2]
         jnz       uperc4
         mov       al,[si+1]
         jmp       short uperc5
uperc4:  inc       si
         inc       si
         loop      uperc3
uperc5:  pop       si
         pop       cx
         ret

;------------------------------------------------------------------------------

lowercase:                                  ; p©evod AL na malÇ p°smeno
         cmp       al,128
         jnc       lowrc2
         cmp       al,"A"
         jc        lowrc1
         cmp       al,"Z"+1
         jnc       lowrc1
         add       al,32
lowrc1:  ret
lowrc2:  push      cx
         push      si
         mov       si,offset tabuper        ; tabulka pro p©evod p°smen
         mov       cl,[si]                  ; poáet poloëek tabulky
         xor       ch,ch
lowrc3:  cmp       al,[si+1]
         jnz       lowrc4
         mov       al,[si+2]
         jmp       short lowrc5
lowrc4:  inc       si
         inc       si
         loop      lowrc3
lowrc5:  pop       si
         pop       cx
         ret

;------------------------------------------------------------------------------

todek:                                      ; p©evod slova v DX:AX na á°slo
                                            ; do bufferu DS:DI (7 á°slic)
         push      ax
         push      bx
         push      cx
         push      dx
         mov       bx,15
         mov       cx,4240h                 ; miliony
         call      todek1
         mov       bx,1
         mov       cx,86a0h                 ; statis°ce
         call      todek1
         xor       bx,bx
         mov       cx,10000                 ; desetitis°ce
         call      todek1
         mov       cx,1000                  ; tis°ce
         call      todek1
         mov       cx,100                   ; stovky
         call      todek1
         mov       cl,10                    ; des°tky
         call      todek1
         mov       cl,1                     ; jednotky
         call      todek1
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

todek1:
         mov       cs:[todekc],2fh
todek2:
         inc       cs:[todekc]              ; zvò®en° á°taáe á°slice
         sub       ax,cx
         sbb       dx,bx
         jnc       todek2                   ; nen° je®tà podteáen°
         add       ax,cx
         adc       dx,bx                    ; zpàtn† korekce
         push      ax
         mov       al,cs:[todekc]
         mov       [di],al                  ; uloëen° á°slice
         inc       di
         pop       ax
         ret



todekc   db        0                        ; á°taá á°slice


;------------------------------------------------------------------------------

outwrd:                                     ; tisk slova v AX v HEX tvaru
         push      ax
         mov       al,ah                    ; vy®®° bajt slova
         call      outbyte                  ; tisk vy®®°ho bajtu slova
         pop       ax
                                            ; tisk bajtu v AL v HEX tvaru
outbyte: push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         call      outhex                   ; tisk vy®®° tetr†dy bajtu
         pop       ax
                                            ; tisk tetr†dy v AL v HEX tvaru
outhex:  push      ax
         and       al,0fh
         add       al,30h                   ; korekce na á°slici
         cmp       al,3ah
         jb        outhx1
         add       al,7
outhx1:  call      outchr                   ; vòstup znaku
         pop       ax
         ret

;------------------------------------------------------------------------------

outchr:                                     ; vòstup znaku na vòstupn° kan†l
         push      cx
         cmp       al,8
         jnz       outchr1
         cmp       [pozice],0
         jz        outchr3
         dec       [pozice]
         jmp       short outchr2
outchr1: inc       [pozice]                 ; zvò®en° ukazatele pozice
         cmp       al,13
         jnz       outchr2
         mov       [pozice],0
         inc       [radek]
outchr2:

         mov       dx,word ptr [pozice]
         call      putch

outchr3: pop       cx
         ret

;------------------------------------------------------------------------------

ulozob:                                     ; uloëen° obrazovky do bufferu
         push      ds
         push      es
         push      si
         push      di
         push      ax
         push      cx
         xor       si,si
         mov       di,si
         inc       [ukazobr]                ; zvò®en° ukazatele obrazovky
         mov       cl,[ukazobr]             ; á°slo aktu†ln° obrazovky
         xor       ch,ch
ulozob1: add       di,1000H
         loop      ulozob1                  ; adresa obrazovky
         mov       ax,0b800h                ; poá†teán° segment obrazovky
         mov       ds,ax                    ; segment obrazovky
         mov       es,ax
         mov       cx,800H                  ; poáet slov obrazovky
         rep       movsw
         pop       cx
         pop       ax
         pop       di
         pop       si
         pop       es
         pop       ds
         ret

;------------------------------------------------------------------------------

navrob:                                     ; navr†cen° obrazovky z buff. DS:SI
         push      ds
         push      es
         push      si
         push      di
         push      ax
         push      cx
         xor       di,di
         mov       si,di
         mov       cl,[ukazobr]
         dec       [ukazobr]
         xor       ch,ch
navrob1: add       si,1000H
         loop      navrob1
         mov       ax,0b800h                ; poá†teán° segment obrazovky
         mov       es,ax                    ; segment obrazovky
         mov       ds,ax
         mov       cx,800H                  ; poáet slov obrazovky
         rep       movsw
         pop       cx
         pop       ax
         pop       di
         pop       si
         pop       es
         pop       ds
         ret

;------------------------------------------------------------------------------

box:                                        ; vymaz†n° obdÇln°ku
                                            ; vstup:  AH = barva pozad° a textu
                                            ;         DX = levò horn° roh
                                            ;         CX = ©†dkñ/znakñ
         push      ax                       
         push      bx                       
         push      cx                       
         push      dx                       
box1:    push      dx                       ; DX = sou©. levÇho horn°ho rohu
         push      cx                       ; poáet znakñ a poáet ©†dkñ
         mov       al,32                    ; znak k vymaz†n°
         mov       ch,0                     ; CL = poáet znakñ na ©†dce
box2:    call      putchat                  ; z†pis znaku s atributy
         loop      box2
         pop       cx                       ; poáet znakñ a poáet ©†dkñ
         pop       dx                       ; sou©adnice kurzroru
         inc       dh                       ; dal®° ©†dek
         dec       ch                       ; á°taá ©†dkñ
         jnz       box1                     ; dal®° ©†dek
         pop       dx                       
         pop       cx                       
         pop       bx
         pop       ax
         ret

;------------------------------------------------------------------------------

stin:                                       ; vykreslen° st°nu pod r†meákem
                                            ; vstup:  DX = levò horn° roh
                                            ;         CX = ©†dkñ/znakñ
         push      ax                       
         push      bx                       
         push      cx                       
         push      dx
         mov       bx,cx                    ; á°taá ©†dkñ a pozic
         inc       dh
         xor       ch,ch
         add       dx,cx                    ; poá†tek pravÇho st°nu
stin1:   push      dx
         call      readchat                 ; áten° atributu
         and       ah,7                     ; zamaskov†n° podkladu
         dec       dl
         call      putatr                   ; nastaven° atributu
         call      readchat                 ; áten° atributu
         and       ah,7                     ; zamaskov†n° podkladu
         dec       dl
         call      putatr                   ; nastaven° atributu
         pop       dx
         inc       dh
         dec       bh                       ; dal®° ©†dek
         jnz       stin1
         pop       dx                       ; sou©adnice rohu
         pop       cx
         push      cx
         push      dx
         xor       cl,cl
         add       dx,cx                    ; zaá†tek spodn°ho st°nu
         inc       dl
stin2:   call      readchat                 ; áten° atributu
         and       ah,7                     ; zamaskov†n° podkladu
         dec       dl
         call      putatr                   ; nastaven° atrubutu
         dec       bl
         jnz       stin2                    ; dal®° pozice
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

;------------------------------------------------------------------------------

ram:                                        ; vykreslen° r†meáku
                                            ; DX - levò horn° roh
                                            ; CX - rozmàry r†meáku
         push      ax
         push      bx
         push      cx                       ; rozmàry r†meáku
         push      dx                       ; poá†teán° sou©adnice r†meáku
         push      dx                       ; poá†teán° sou©adnice ©†dku
         dec       cl
         dec       cl
         mov       bx,cx                    ; uschov†n° rozmàrñ r†meáku
         xor       ch,ch
         mov       al,"…"
         call      putch                    ; vyti®tàn° rohu okna
         mov       al,"Õ"
ram1:    call      putch
         loop      ram1
         mov       al,"ª"
         call      putch
         pop       dx                       ; poá†teán° sou©adnice ©†dku
         dec       bh
         dec       bh
         mov       cl,bl
ram2:    inc       dh
         push      dx                       ; poá†teán° sou©adnice ©†dku
         mov       al,"∫"
         call      putch
         add       dl,cl
         call      putch
         pop       dx
         dec       bh
         jnz       ram2                     ; dal®° ©†dek
         inc       dh                       ; posledn° ©†dek
         mov       al,"»"
         call      putch
         mov       al,"Õ"
ram3:    call      putch
         loop      ram3
         mov       al,"º"
         call      putch
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

;------------------------------------------------------------------------------

zobtext:                                    ; zobrazen° textu ASCIIZ
                                            ; SI = ukazatel textu (po bajt 0)
                                            ; DX = sou©adnice kurzoru
                                            ; BL = poá†teán° offsetov† pozice
                                            ; vòstup DX,SI - novÇ pozice
         push      ax
         xor       ah,ah
zobtx1:  lodsb                              ; znak k tisku
         or        al,al                    ; je = 0 ? (konec textu)
         jz        zobtx4                   ; je konec textu
         cmp       al,1fh                   ; znak novÇho ©†dku
         jnz       zobtx2                   ; nen° znak konce ©†dku
         mov       dl,bl                    ; poá†teán° pozice textu
         inc       dh                       ; dal®° ©†dek
         jmp       short zobtx1
zobtx2:  jnc       zobtx3                   ; je znak k tisku
         add       dx,ax                    ; zvò®en° pozice kurzoru
         jmp       short zobtx1             ; dal®° znak
zobtx3:  call      putch                    ; tisk znaku
         jmp       short zobtx1
zobtx4:  pop       ax
         ret


;------------------------------------------------------------------------------

rolup:                                      ; rolov†n° obrazovky o ©†dek nahoru
         push      es
         push      ds
         push      si
         push      di
         push      cx
         push      ax
         mov       ah,[coltext]
         push      ax
         mov       ax,0b800h                ; segment displeje
         mov       es,ax
         mov       ds,ax
         cld                                ; p©enos nahoru
         mov       di,160
         mov       si,320
         mov       cx,80*22
         rep       movsw
         mov       si,di
         inc       di
         inc       di
         mov       cx,78
         pop       ax
         mov       al,32
         mov       [si],ax
         rep       movsw
         pop       ax
         pop       cx
         pop       di
         pop       si
         pop       ds
         pop       es
         ret

;------------------------------------------------------------------------------

roldown:                                    ; rolov†n° obrazovky o ©†dek dolñ
         push      es
         push      ds
         push      si
         push      di
         push      cx
         push      ax
         mov       ah,[coltext]
         push      ax
         mov       ax,0b800h                ; segment displeje
         mov       es,ax
         mov       ds,ax
         std                                ; p©enos dolñ
         mov       si,80*23*2-2
         mov       di,80*24*2-2
         mov       cx,80*22
         rep       movsw
         mov       si,di
         dec       di
         dec       di
         mov       cx,78
         pop       ax
         mov       al,32
         mov       [si],ax
         rep       movsw
         cld                                ; p©enos nahoru
         pop       ax
         pop       cx
         pop       di
         pop       si
         pop       ds
         pop       es
         ret

;------------------------------------------------------------------------------

putch:                                      ; vòpis znaku na displej
                                            ; AL = znak k vòstupu
                                            ; DX = pozice kurzoru (©†dky/sloupce)
         push      es
         push      di
         cmp       dl,80                    ; je p©ekroáen okraj ©†dku ?
         jnc       putch0                   ; je p©ekroáen
         cmp       dh,25                    ; je p©ekroáen poáet ©†dkñ ?
         jnc       putch0                   ; je p©ekroáen
         push      ax
         mov       al,80                    ; poáet znakñ na ©†dek
         mul       dh                       ; p©epoáet ©†dkñ na znaky
         add       al,dl                    ; p©iáten° pozice na ©†dku
         adc       ah,0                     ; p©iáten° p©enosu
         add       ax,ax                    ; zdvojn†soben°
         mov       di,ax                    ; offset znaku v pamàti
         mov       ax,0b800h                ; segment videopamàti
         mov       es,ax
         pop       ax                       ; znak k vòstupu
         stosb                              ; uloëen° znaku
putch0:  inc       dl                       ; zvò®en° pozice kurzoru
         pop       di
         pop       es
         ret

;------------------------------------------------------------------------------

putchat:                                    ; vòpis znaku na displej s atributy

                                            ; AL = znak k vòstupu
                                            ; AH = atributy znaku
                                            ; DX = pozice kurzoru (©†dky/sloupce)
         push      es
         push      di
         cmp       dl,80                    ; je p©ekroáen okraj ©†dku ?
         jnc       putcha0                  ; je p©ekroáen
         cmp       dh,25                    ; je p©ekroáen poáet ©†dkñ ?
         jnc       putcha0                  ; je p©ekroáen
         push      ax
         mov       al,80                    ; poáet znakñ na ©†dek
         mul       dh                       ; p©epoáet ©†dkñ na znaky
         add       al,dl                    ; p©iáten° pozice na ©†dku
         adc       ah,0                     ; p©iáten° p©enosu
         add       ax,ax                    ; zdvojn†soben°
         mov       di,ax                    ; offset znaku v pamàti
         mov       ax,0b800h                ; segment videopamàti
         mov       es,ax
         pop       ax                       ; znak k vòstupu
         stosw                              ; uloëen° znaku
putcha0: inc       dl                       ; zvò®en° pozice kurzoru
         pop       di
         pop       es
         ret

;------------------------------------------------------------------------------

putatr:                                     ; vòpis atributu na displej
                                            ; AH = atribut k vòstupu
                                            ; DX = pozice kurzoru (©†dky/sloupce)
         push      es
         push      di
         cmp       dl,80                    ; je p©ekroáen okraj ©†dku ?
         jnc       putatr0                  ; je p©ekroáen
         cmp       dh,25                    ; je p©ekroáen poáet ©†dkñ ?
         jnc       putatr0                  ; je p©ekroáen
         push      ax
         mov       al,80                    ; poáet znakñ na ©†dek
         mul       dh                       ; p©epoáet ©†dkñ na znaky
         add       al,dl                    ; p©iáten° pozice na ©†dku
         adc       ah,0                     ; p©iáten° p©enosu
         add       ax,ax                    ; zdvojn†soben°
         inc       ax
         mov       di,ax                    ; offset znaku v pamàti
         mov       ax,0b800h                ; segment videopamàti
         mov       es,ax
         pop       ax                       ; atribut k vòstupu
         push      ax
         mov       al,ah
         stosb                              ; uloëen° atributu
         pop       ax
putatr0: inc       dl                       ; zvò®en° pozice kurzoru
         pop       di
         pop       es
         ret

;------------------------------------------------------------------------------

readchat:                                   ; áten° znaku z displeje s atributem
                                            ; vstup:
                                            ; DX = pozice kurzoru (©†dky/sloupce)
                                            ; vòstup:
                                            ; AL = znak z pozice kurzoru
                                            ; AH = atribut znaku

         push      ds
         push      si
         mov       ax,0
         cmp       dl,80                    ; je p©ekroáen okraj ©†dku ?
         jnc       readch0                  ; je p©ekroáen
         cmp       dh,25                    ; je p©ekroáen poáet ©†dkñ ?
         jnc       readch0                  ; je p©ekroáen
         mov       al,80                    ; poáet znakñ na ©†dek
         mul       dh                       ; p©epoáet ©†dkñ na znaky
         add       al,dl                    ; p©iáten° pozice na ©†dku
         adc       ah,0                     ; p©iáten° p©enosu
         add       ax,ax                    ; zdvojn†soben°
         mov       si,ax                    ; offset znaku v pamàti
         mov       ax,0b800h                ; segment videopamàti
         mov       ds,ax
         lodsw                              ; áten° znaku s atributem
readch0: inc       dl                       ; zvò®en° pozice kurzoru
         pop       si
         pop       ds
         ret

;------------------------------------------------------------------------------

testch:                                     ; test p©°chodu znaku z kl†vesnice
                                            ; n†vrat Z = 1 nen° p©ipraven znak
         push      ax
         mov       ah,11
         int       21h
         test      al,al
         pop       ax
         ret

;------------------------------------------------------------------------------

inpch:                                      ; vstup znaku z kl†vesnice
         push      dx                       
         push      si                       
         push      di                       
         push      bx                       
         push      bp                       
         mov       ah,2                     
         mov       bh,0                     
         mov       dx,25*256+80             ; kurzor mimo obrazovku
         int       10h                      ; nastaven° pozice kurzoru
         mov       ah,8                     
         int       21h                      ; vstup znaku z kl†vesnice
         mov       ah,0                     
         test      al,al                    ; bude ©°d°c° k¢d ?
         jnz       inpch1                   ; nen° speci†ln° kl†vesa
         mov       ah,8                     ; áten° k¢du speci†ln° kl†vesy
         int       21h                      ; vstup znaku
         mov       ah,1                     ; indikace spec. kl†vesy
inpch1:  pop       bp                       
         pop       bx                       
         pop       di                       
         pop       si
         pop       dx
         ret


;--------------------------------------------------------------------------
;                         BlokovÇ vtupnà/vòstupn° operace
;--------------------------------------------------------------------------

openfr:                                     ; otev©en° souboru pro áten°
                                            ; DX = ukazatel na jmÇno souboru
         push      dx                       
         push      ax                       
         mov       ax,3d00h                 ; otev©eno pro áten°
         int       21h                      
         mov       [handle],ax              ; identifikace souboru
         pop       ax                       
         pop       dx
         ret

;------------------------------------------------------------------------------

readch:                                ; áten° znaku ze souboru
                                       ; vstup DI = ukazatel na buffer
                                       ; vòstup AL = p©eátenò znak,
                                       ;        DI = DI + 1
         push      dx
         push      cx
         push      bx
         push      ax
         mov       dx,di               ; z†pisovò buffer
         mov       bx,[handle]         ; identifikace souboru
         mov       cx,1                ; 1 bajt ke áten°
         mov       ah,3fh
         int       21h                 ; áten° ze souboru
         pop       ax
         mov       al,[di]             ; p©eáten° uloëenÇho znaku
         inc       di
         pop       bx
         pop       cx
         pop       dx
         ret

;------------------------------------------------------------------------------

clfile:                                ; uzav©en° souboru
         push      ax
         push      bx
         mov       ah,3eh
         mov       bx,[handle]
         int       21h                 ; uzav©en° souboru
         pop       bx
         pop       ax
         ret

;------------------------------------------------------------------------------

newfile:                               ; vytvo©en° novÇho souboru
                                       ; DX = ukazatel na jmÇno
         push      dx
         push      cx
         push      bx
         push      ax
         mov       ah,3ch
         mov       cx,0                ; atributy
         int       21h                 ; vytvo©en° souboru
         mov       [handle],ax         ; identifikace souboru
         pop       ax
         pop       bx
         pop       cx
         pop       dx
         ret

;------------------------------------------------------------------------------
;                              P©eru®en°
;------------------------------------------------------------------------------

int8:                                       ; obsluha p©eru®en° INT 08H
         pushf
         call      dword ptr cs:[adr_int8]  ; standardn° obsluha INT 8
         push      ds
         push      es
         push      si
         push      di
         push      dx
         push      cx
         push      bx
         push      ax
         mov       ax,0
         mov       ds,ax
         mov       ax,0b800h
         mov       es,ax

         mov       ax,ds:[046ch]            ; nië®° á†st á°taáe áasu
         mov       dx,ds:[046eh]            ; vy®®° á†st á°taáe áasu
         mov       cl,4                     ; poáet rotac°
         shl       dx,cl                    ; DX * 4
         mov       bx,ax
         mov       cl,12
         shr       bx,cl
         add       dx,bx
         mov       cl,4
         shl       ax,cl
         mov       bx,4446h
         div       bx
         mov       cs:[udaj+4],dx
         mov       bx,3ch
         xor       dx,dx
         div       bx
         mov       cs:[udaj+2],dx
         aam
         add       ax,3030h
         xchg      ah,al
         mov       cs:[udaj],ax
         mov       ax,cs:[udaj+2]
         aam
         add       ax,3030h
         xchg      ah,al
         mov       cs:[udaj+2],ax
         mov       ax,cs:[udaj+4]
         xor       dx,dx
         mov       bx,3ch
         mul       bx
         mov       bx,4446h
         div       bx
         aam
         add       ax,3030h
         xchg      ah,al
         mov       cs:[udaj+4],ax
         cmp       ah,cs:[sekunda]
         jz        int81                    ; nen° zmàna sekund
         mov       cs:[sekunda],ah

         mov       al,":"
         mov       es:[0092h],al
         mov       es:[0098h],al
         mov       ax,cs:[udaj]
         mov       es:[008eh],al
         mov       es:[0090h],ah
         mov       ax,cs:[udaj+2]
         mov       es:[0094h],al
         mov       es:[0096h],ah
         mov       ax,cs:[udaj+4]
         mov       es:[009ah],al
         mov       es:[009ch],ah

         mov       ax,SEG data              ; datovò segment
         mov       ds,ax
         mov       ax,[endmem]              ; konec pamàti
         mov       bx,[freemem]             ; zaá†tek volnÇ pamàti
         sub       ax,bx                    ; poáet odstavcñ volnÇ pamàti
         dec       ax
         xor       dx,dx
         shl       ax,1
         rcl       dx,1
         shl       ax,1
         rcl       dx,1
         shl       ax,1
         rcl       dx,1
         shl       ax,1
         rcl       dx,1
         mov       di,offset buffcis
         call      todek                    ; p©ek¢dov†n° na á°slo
         mov       si,offset buffcis
         mov       di,6eh                   ; offset zobrazen° á°sla na displeji
         mov       cx,6                     ; poáet á°slic pro zobrazen° - 1
int82:   lodsb                              ; p©eáten° á°slice
         inc       cx
         cmp       al,30h                   ; je 0 ?
         jnz       int83                    ; nen° - zobraz° se
         dec       cx
         mov       al," "                   ; nahrad° se mezerou
         stosb                              ; uloëen° mezery
         inc       di                       ; p©eskoáen° atributu
         loop      int82                    ; dal®° znak
         inc       cx
int84:   lodsb                              ; p©eáten° dal®° á°slice
int83:   stosb                              ; uloëen° á°slice
         inc       di                       ; p©eskoáen° atributu
         loop      int84                    ; dal®° á°slice

int81:   pop       ax
         pop       bx
         pop       cx
         pop       dx
         pop       di
         pop       si
         pop       es
         pop       ds
         iret                               ; n†vrat z p©eru®en°

adr_int8 dw        0                        ; adresa systÇmovÇ obsluhy INT 8
         dw        0

sekunda  db        0                        ; jednotky sekund

udaj     dw        0
         dw        0
         dw        0

;------------------------------------------------------------------------------


code     ENDS

;--------------------------------------------------------------------------
;                            Datovò segment
;--------------------------------------------------------------------------

data     SEGMENT

                                            ; pracovn° datovÇ poloëky

buffcis  db        '       ',0              ; buffer dekadickÇho á°sla pro INT 8
dta      db        128 dup (0)              ; buffer pro diskovÇ p©enosy DTA

                                            ; nastaven° systÇmovÇho displeje
sysmod   db        0                        ; systÇmovò m¢d
syspoz   dw        0                        ; systÇmov† pozice kurzoru
syskurz  dw        0                        ; rozmàry systÇmovÇho kurzoru

                                            ; aktu†ln° nastaven° displeje
videomod db        3                        ; souáasnà nastavenò videom¢d
pozice   db        0                        ; á°taá pozice na ©†dku
radek    db        1                        ; ukazatel ©†dkñ na displeji

ukazobr  db        0                        ; ukazatel aktu†ln° obrazovky

                                            ; pomocnÇ promànnÇ pro disassembler
prefdd   db        0                        ; prefix DD, FD
prefed   db        0                        ; prefix ED, CB

ukaztxt  dw        0                        ; ukazatel jmÇna souboru
stackp   dw        0                        ; uloëen° ukazatele z†sobn°ku

handle   dw        0                        ; identifik†tor souboru

                                            ; pracovn° adres†©e
pathakt  db        64 dup (0)               ; cesta k aktu†ln°mu adres†©i
pathexe  db        64 dup (0)               ; buffer cesty k programu GENS80
pathcom  db        64 dup (0)               ; cesta k souborñm COM
pathgen  db        64 dup (0)               ; cesta k souborñm GEN

selall   db        '*.*',0                  ; ©etàzec pro vòbàr v®ech souborñ

;--------------------------------------------------------------------------
                                            ; soubor konfigurace programu GENS80

                                            ; z†hlav° konfiguraán°ho souboru
hlava    db        'G80/1.0',0              ; identifikaán° z†hlav° konfigurace

                                            ; nastaven° barev
coltext  db        1*16+11                  ; barva textu
colmenu  db        7*16+0                   ; barva menu
colinf   db        3*16+0                   ; barva informaán°ch ©†dkñ
colkurz  db        4*16+15                  ; barva kurzoru menu
colklic  db        7*16+4                   ; barva kl°áovÇho znaku
colclck  db        3*16+1                   ; barva £daje hodin
colinp   db        3*16+0                   ; barva vstupn°ho textu

                                            ; nastaven° tabelaán°ch znaáek
pozadr   db        1                        ; poá†teán° pozice adresy
pozkod   db        6                        ; pozice k¢du instrukce
pozoddel db        14                       ; pozice oddàlovaáe
poznav   db        15                       ; pozice n†và®t°
pozins   db        22                       ; pozice instrukce
pozoper  db        27                       ; pozice operandu instrukce
pozpoz   db        42                       ; pozice pozn†mky
pozkonec db        80                       ; pozice konce ©†dku

                                            ; nastaven° oddàlovac°ch znakñ
oddel1   db        ':    '                  ; text oddàlovaáe adresa/k¢d
oddel2   db        '≥    '                  ; text oddàlovaáe k¢d/n†và®t°

paradr   db        0                        ; selektor pro volbu adresy menu

                                            ; adresy menu na displeji
adrmenu1 db        62,2                     ; pozice a ©†dek menu
         db        2,2                      ; zrcadlov† pozice menu1

adrmenu4 db        62,2                     ; pozice a ©†dek menu Definice
         db        2,2                      ; zrcadlov† pozice menu

adrmenu5 db        62,2                     ; pozice a ©†dek menu File
         db        2,2                      ; zrcadlov† pozice menu

adrmenuf db        58,8                     ; pozice a ©†dek menu Load
         db        2,2                      ; zrcadlov† pozice menu

adrmfile db        6,3                      ; pozice a ©†dek menu zad†n° souboru
         db        6,19                     ; zrcadlov† pozice menu

pathco2  db        64 dup (0)               ; zadan† cesta k souborñm COM
pathge2  db        64 dup (0)               ; zadan† cesta k souborñm GEN

;--------------------------------------------------------------------------
                                            ; tabulky

tabuper  db        22                       ; tabulka pro p©evod p°smen
         db        'è†'
         db        'éÑ'
         db        'Äá'
         db        'ÖÉ'
         db        'êÇ'
         db        'âà'
         db        'ã°'
         db        'äç'
         db        'úå'
         db        '•§'
         db        'ï¢'
         db        'ßì'
         db        'ôî'
         db        'û©'
         db        '´™'
         db        'õ®'
         db        'Üü'
         db        'ó£'
         db        '¶ñ'
         db        'öÅ'
         db        'ùò'
         db        'íë'

text1    db        ' Soubor: NONAME.GEN      ©†dek: 1234       voln† pamàü'
         db        ':        bajtñ   00:00:00 ',0
text2    db        ' <F1>=Help   <Enter>=z†kladn° nab°dka funkc° '
         db        ' A,C,D,F,I,L,O,P,R,S,T=volby',0

;--------------------------------------------------------------------------
                                            ; tabulky menu


                                            ; hlavn° menu 1

tabmenu1 dw        txtmenu1                 ; SI+0 adresa textu menu1
         dw        hlpmenu1                 ; SI+2 adresa helpu menu
         dw        adrmenu1                 ; SI+4 adresa menu na displeji
         db        15                       ; SI+6 ®°©ka r†meáku menu
         db        13                       ; SI+7 vò®ka r†meáku menu
         db        2                        ; SI+8 poá†tek kurzoru
         db        11                       ; SI+9 dÇlka kurzoru
         db        11                       ; SI+10 poáet poloëek menu
         db        3                        ; SI+11 aktivn° poloëka menu
         db        1,3                      ; k¢d vypnut° poloëky, akán° znak
         dw        menuret                  ; adresa akce poloëky menu
         db        1,3
         dw        menuret
         db        1,3
         dw        akcemenu4
         db        1,3
         dw        akcemenu5
         db        1,3
         dw        menuret
         db        1,3
         dw        menuret
         db        1,3
         dw        menuret
         db        1,3
         dw        menuret
         db        1,3
         dw        menuret
         db        1,3
         dw        menuret
         db        1,3
         dw        menuret

txtmenu1 db        31
         db        3,'Address',31
         db        3,'Comment',31
         db        3,'Define',31
         db        3,'File',31
         db        3,'Insert',31
         db        3,'Label',31
         db        3,'Option',31
         db        3,'Procedure',31
         db        3,'Return',31
         db        3,'Segment',31
         db        3,'Trace',31
         db        0

hlpmenu1 db        'Nastaven° kurzoru na danou adresu programu.',0
         db        'Z†pis pozn†mky k instrukci na nastavenÇ adrese.',0
         db        'Definov†n° p©ekladu jako instrukce, bajt, slovo nebo'
         db        ' struktura.',0
         db        'Operace se soubory, ukonáen° programu.',0
         db        'Vkl†d†n° ©†dek do vòpisu textu.',0
         db        'Definov†n° symbolickÇho n†và®t°.',0
         db        'Roz®i©uj°c° volby a nastaven° programu.',0
         db        'Z†pis textu z†hlav° procedury',0
         db        'N†vrat na adresu p©edch†zej°c° funcki Adress.',0
         db        'Definice a zmàny zdrojovòch segmentñ programu.',0
         db        'Trasov†n° a krokov†n° programu, simulace jeho funkce.',0


                                            ; menu Define

tabmenu4 dw        txtmenu4                 ; SI+0 adresa textu menu
         dw        hlpmenu4                 ; SI+2 adresa helpu menu
         dw        adrmenu4                 ; SI+4 adresa menu na displeji
         db        15                       ; SI+6 ®°©ka r†meáku menu
         db        7                        ; SI+7 vò®ka r†meáku menu
         db        2                        ; SI+8 poá†tek kurzoru
         db        11                       ; SI+9 dÇlka kurzoru
         db        5                        ; SI+10 poáet poloëek menu
         db        2                        ; SI+11 aktivn° poloëka menu
         db        1,3                      ; k¢d vypnut° poloëky, akán° znak
         dw        menuret                  ; adresa akce poloëky menu
         db        1,3
         dw        menuret
         db        1,3
         dw        menuret
         db        1,3
         dw        menuret
         db        1,3
         dw        menuret

txtmenu4 db        4,'Define',31
         db        3,'Command',31
         db        3,'Byte',31
         db        3,'Word',31
         db        3,'Structure',31
         db        3,'Automat',31
         db        0

hlpmenu4 db        'Definov†n° nastavenÇ adresy jako instrukce.',0
         db        'Definov†n° nastavenÇ adresy jako bajt.',0
         db        'Definov†n° nastavenÇ adresy jako slovo.',0
         db        'Definov†n° nastavenÇ adresy jako struktura.',0
         db        'AutomatickÇ definov†n° instrukc° programu.',0


                                            ; menu File

tabmenu5 dw        txtmenu5                 ; SI+0 adresa textu menu
         dw        hlpmenu5                 ; SI+2 adresa helpu menu
         dw        adrmenu5                 ; SI+4 adresa menu na displeji
         db        15                       ; SI+6 ®°©ka r†meáku menu
         db        10                       ; SI+7 vò®ka r†meáku menu
         db        2                        ; SI+8 poá†tek kurzoru
         db        11                       ; SI+9 dÇlka kurzoru
         db        8                        ; SI+10 poáet poloëek menu
         db        2                        ; SI+11 aktivn° poloëka menu
         db        1,3                      ; k¢d vypnut° poloëky, akán° znak
         dw        menuret                  ; adresa akce poloëky menu
         db        1,3
         dw        akcemenuf
         db        1,3
         dw        menuret
         db        1,3
         dw        menuret
         db        1,3
         dw        akcemenuf
         db        1,3
         dw        konec
         db        1,3
         dw        konec
         db        1,3
         dw        konec

txtmenu5 db        3,'File menu',31
         db        3,'New',31
         db        3,'Load',31
         db        3,'Save',31
         db        3,'Output',31
         db        3,'View',31
         db        3,'Dos shell',31
         db        3,'End',31
         db        3,'Quit',31
         db        0

hlpmenu5 db        'Vytvo©en° novÇho definián°ho souboru.',0
         db        'Naáten° definián°ho souboru programu.',0
         db        'Uloëen° definián°ho souboru programu.',0
         db        'Vòstup/tisk rozk¢dovanÇho souboru ve tvaru'
         db          ' zdrojovÇho textu.',0
         db        'Zobrazen° obsahu souboru ve tvaru HEX a ASCII.',0
         db        'Odskok do operaán°ho systÇmu (n†vrat pomoc° Exit).',0
         db        'Uloëen° definián°ho souboru a ukonáen° programu.',0
         db        'P©eru®en° pr†ce bez uloëen°, n†vrat do operaán°ho systÇmu.',0


                                            ; menu Load

tabmenuf dw        txtmenuf                 ; SI+0 adresa textu menu
         dw        hlpmenuf                 ; SI+2 adresa helpu menu
         dw        adrmenuf                 ; SI+4 adresa menu na displeji
         db        18                       ; SI+6 ®°©ka r†meáku menu
         db        12                       ; SI+7 vò®ka r†meáku menu
         db        2                        ; SI+8 poá†tek kurzoru
         db        14                       ; SI+9 dÇlka kurzoru
         db        10                       ; SI+10 poáet poloëek menu
         db        1                        ; SI+11 aktivn° poloëka menu
         db        1,0                      ; k¢d vypnut° poloëky, akán° znak
         dw        menuret                  ; adresa akce poloëky menu
         db        1,0
         dw        menuret
         db        1,0
         dw        menuret
         db        1,0
         dw        menuret
         db        1,0
         dw        menuret
         db        1,0
         dw        menuret
         db        1,0
         dw        menuret
         db        1,0
         dw        menuret
         db        1,0
         dw        menuret
         db        1,0
         dw        menuret

txtmenuf db        5,'Load:',31
txtmenf1 db        3,'            ',31
         db        3,'            ',31
         db        3,'            ',31
         db        3,'            ',31
         db        3,'            ',31
         db        3,'            ',31
         db        3,'            ',31
         db        3,'            ',31
         db        3,'            ',31
         db        3,'            ',31
         db        0

hlpmenuf db        0
         db        0
         db        0
         db        0
         db        0
         db        0
         db        0
         db        0
         db        0
         db        0


                                            ; menu pro zad†n° jmÇna souboru

tabmfile dw        txtmfile                 ; SI+0 adresa textu menu
         dw        hlpmfile                 ; SI+2 adresa helpu menu
         dw        adrmfile                 ; SI+4 adresa menu na displeji
         db        69                       ; SI+6 ®°©ka r†meáku menu
         db        3                        ; SI+7 vò®ka r†meáku menu
         db        2                        ; SI+8 poá†tek kurzoru
         db        63                       ; SI+9 dÇlka kurzoru
         db        1                        ; SI+10 poáet poloëek menu
         db        1                        ; SI+11 aktivn° poloëka menu
         db        1,0                      ; k¢d vypnut° poloëky, akán° znak
         dw        menuret                  ; adresa akce poloëky menu

txtmfile db        31
         db        3,63 dup (32)              ; buffer pro vstup cesty
         db        0,0,0,0,0,0,0,0,0,0,0

hlpmfile db        'Zvolte soubor z adres†©e nebo zadejte cestu k souboru.',0


;--------------------------------------------------------------------------
                                            ; tabulky instrukc° pro disassembler


                                            ; tabulka z†kladn°ch instrukc°

tab0     db        4                        ; poáet blokñ tabulky
         db        37,0ffh                  ; maska 0FFH
         db        0,'NOP',0                ; NOP
         db        10h,'DJNZ e',0           ; DJNZ e
         db        20h,'JR NZ,e',0          ; JR NZ,e
         db        30h,'JR NC,e',0          ; JR NC,e
         db        2,'LD (BC),A',0          ; LD (BC),A
         db        12h,'LD (DE),A',0        ; LD (DE),A
         db        22h,'LD (a),h',0         ; LD (a),HL; LD (a),IX; LD (a),IY
         db        32h,'LD (a),A',0         ; LD (a),A
         db        7,'RLCA',0               ; RLCA
         db        17h,'RLA',0              ; RLA
         db        27h,'DAA',0              ; DAA
         db        37h,'SCF',0              ; SCF
         db        8,'EX AF,AF',39,0        ; EX AF,AF'
         db        18h,'JR e',0             ; JR e
         db        28h,'JR Z,e',0           ; JR Z,e
         db        38h,'JR C,e',0           ; JR C,e
         db        10h,'LD A,(BC)',0        ; LD A,(BC)
         db        1ah,'LD A,(DE)',0        ; LD A,(DE)
         db        2ah,'LD HL,(a)',0        ; LD HL,(a)
         db        3ah,'LD A,(a)',0         ; LD A,(a)
         db        0fh,'RRCA',0             ; RRCA
         db        1fh,'RRA',0              ; RRA
         db        2fh,'CPL',0              ; CPL
         db        3fh,'CCF',0              ; CCF
         db        76h,'HALT',0             ; HALT
         db        0c3h,'JP a',0            ; JP a
         db        0d3h,'OUT (n),A',0       ; OUT (n),A
         db        0e3h,'EX (SP),h',0       ; EX (SP),HL; EX (SP),IX; EX (SP),IY
         db        0f3h,'DI',0              ; DI
         db        0c9h,'RET',0             ; RET
         db        0d9h,'EXX',0             ; EXX
         db        0e9h,'JP (h)',0          ; JP (HL); JP (IX); JP (IY)
         db        0f9h,'LD SP,h',0         ; LD SP,HL; LD SP,IX; LD SP,IY
         db        0dbh,'IN A,(n)',0        ; IN A,(n)
         db        0ebh,'EX DE,h',0         ; EX DE,HL; EX DE,IX; EX DE,IY
         db        0fbh,'EI',0              ; EI
         db        0cdh,'CALL a',0          ; CALL a

         db        2,0c0h                   ; maska 0C0H
         db        40h,'LD v,u',0           ; LD r2,r1
         db        80h,'ou',0               ; arop r1

         db        6,0cfh                   ; maska 0CFH
         db        1,'LD f,a',0             ; LD dr1,a
         db        3,'INC f',0              ; INC dr1
         db        9,'ADD h,f',0            ; ADD HL,dr1; ADD IX,dr1; ADD IY,dr1
         db        0bh,'DEC f',0            ; DEC drg1
         db        0c1h,'POP g',0           ; POP drg2
         db        0c5h,'PUSH g',0          ; PUSH drg2

         db        8,0c7h                   ; maska 0C7H
         db        4,'INC v',0              ; INC r2
         db        5,'DEC v',0              ; DEC r2
         db        6,'LD v,n',0             ; LD r2,n
         db        0c0h,'RET c',0           ; RET podm
         db        0c2h,'JP c,a',0          ; JP podm,a
         db        0c4h,'CALL c,a',0        ; CALL podm,a
         db        0c6h,'on',0              ; arop n
         db        0c7h,'RST s',0           ; RST s


                                            ; tabulka instrukc° s prefixem ED

tabed    db        4                        ; poáet blokñ tabulku
         db        12,0ffh                  ; maska 0FFH
         db        44h,'NEG',0              ; NEG
         db        45h,'RETN',0             ; RETN
         db        46h,'IM 0',0             ; IM 0
         db        56h,'IM 1',0             ; IM 1
         db        47h,'LD I,A',0           ; LD I,A
         db        57h,'LD A,I',0           ; LD A,I
         db        67h,'RRD',0              ; RRD
         db        4dh,'RETI',0             ; RETI
         db        5eh,'IM 2',0             ; IM 2
         db        4fh,'LD R,A',0           ; LD R,A
         db        5fh,'LD A,R',0           ; LD A,R
         db        6fh,'RLD',0              ; RLD

         db        2,0c7h                   ; maska 0C7H
         db        40h,'IN v,(C)',0         ; IN r2,(C)
         db        41h,'OUT (C),v',0        ; OUT (C),r2

         db        4,0cfh                   ; maska 0CFH
         db        42h,'SBC HL,f',0         ; SBC HL,dr1
         db        4ah,'ADC HL,f',0         ; ADD HL,dr1
         db        43h,'LD (a),f',0         ; LD (a),dr1
         db        4bh,'LD f,(a)',0         ; LD dr1,(a)

         db        4,0e7h                   ; maska 0E7H
         db        0a0h,'LDr',0             ; LDI, LDD, LDIR, LDDR
         db        0a1h,'CPr',0             ; CPI, CPD, CPIR, CPDR
         db        0a2h,'INr',0             ; INI, IND, INIR, INDR
         db        0a3h,'OTr',0             ; OTI, OTD, OTIR, OTDR


                                            ; tabulka instrukc° s prefixem CB

tabcb    db        4                        ; poáet blokñ tabulky
         db        8,0ffh                   ; maska 0FFH
         db        6,'RLC w',0              ; RLC (IX + d); RLC (IY + d)
         db        0eh,'RRC w',0            ; RRC (IX + d); RRC (IY + d)
         db        16h,'RL w',0             ; RL (IX + d); RL (IY + d)
         db        1eh,'RR w',0             ; RR (IX + d); RR (IY + d)
         db        26h,'SLA w',0            ; SLA (IX + d); SLA (IY + d)
         db        2eh,'SRA w',0            ; SRA (IX + d); SRA (IY + d)
         db        36h,'SLI w',0            ; SLI (IX + d); SLI (IY + d)
         db        3eh,'SRL w',0            ; SRL (IX + d); SRL (IY + d)

         db        3,0c7h                   ; maska 0C7H
         db        46h,'BIT b,w',0          ; BIT b,(IX + d); BIT b,(IY + d)
         db        86h,'RES b,w',0          ; RES b,(IX + d); RES b,(IY + d)
         db        0c6h,'SET b,w',0         ; SET b,(IX + d); SET b,(IY + d)

         db        8,0f8h                   ; maska 0F8H
         db        0,'RLC u',0              ; RLC r1
         db        8,'RRC u',0              ; RRC r1
         db        10h,'RL u',0             ; RL r1
         db        18h,'RR u',0             ; RR r1
         db        20h,'SLA u',0            ; SLA r1
         db        28h,'SRA u',0            ; SRA r1
         db        30h,'SLI u',0            ; SLI r1
         db        38h,'SRL u',0            ; SRL r1

         db        3,0c0h                   ; maska 0C0H
         db        40h,'BIT b,u',0          ; BIT b,r1
         db        80h,'RES b,u',0          ; RES b,r1
         db        0c0h,'SET b,u',0         ; SET b,r1


tabb     db        1                        ; parametr bitovòch instrukc°
         db        8,7
         db        0,'0',0
         db        1,'1',0
         db        2,'2',0
         db        3,'3',0
         db        4,'4',0
         db        5,'5',0
         db        6,'6',0
         db        7,'7',0

tabc     db        1                        ; podm°nka
         db        8,38h
         db        0,'NZ',0
         db        8,'Z',0
         db        10h,'NC',0
         db        18h,'C',0
         db        20h,'PO',0
         db        28h,'PE',0
         db        30h,'P',0
         db        38h,'M',0

tabf     db        1                        ; registr typu 1 a dÇlky 2 bajty
         db        4,30h
         db        0,'BC',0
         db        10h,'DE',0
         db        20h,'h',0
         db        30h,'SP',0

tabg     db        1                        ; registr typu 2 a dÇlky 2 bajty
         db        4,30h
         db        0,'BC',0
         db        10h,'DE',0
         db        20h,'h',0
         db        30h,'AF',0

tabh     db        1                        ; symboly HL, IX, IY
         db        3,0ffh
         db        0,'HL',0
         db        0ddh,'IX',0
         db        0fdh,'IY',0

tabo     db        1                        ; aritmetickÇ operace
         db        8,38h
         db        0,'ADD A,',0
         db        8,'ADC A,',0
         db        10h,'SUB ',0
         db        18h,'SBC A,',0
         db        20h,'AND ',0
         db        28h,'XOR ',0
         db        30h,'OR ',0
         db        38h,'CP ',0

tabr     db        1                        ; doplnàk instrukc° LDIR, ....
         db        4,18h
         db        0,'I',0
         db        8,'D',0
         db        10h,'IR',0
         db        18h,'DR',0

tabu     db        1                        ; registr typu 1 a dÇlku 1 bajt
         db        8,7
         db        0,'B',0
         db        1,'C',0
         db        2,'D',0
         db        3,'E',0
         db        4,'H',0
         db        5,'L',0
         db        6,'x',0
         db        7,'A',0

tabv     db        1                        ; registr typu 2 a dÇlku 1 bajt
         db        8,38h
         db        0,'B',0
         db        8,'C',0
         db        10h,'D',0
         db        18h,'E',0
         db        20h,'H',0
         db        28h,'L',0
         db        30h,'x',0
         db        38h,'A',0

tabx     db        1                        ; symboly (HL), (IX+d), (IY+d)
         db        3,0ffh
         db        0,'(HL)',0
         db        0ddh,'(IXd)',0
         db        0fdh,'(IYd)',0

;--------------------------------------------------------------------------
                                            ; adresy datovòch segmentñ

numfiles dw        0                        ; poáet souborñ (poloëek) v bufferu
aktfile  dw        0                        ; prvn° aktivnà zobrazenò soubor

topmem   dw        0                        ; poá†teán° segment pamàti dat
freemem  dw        0                        ; poá†teán° segment volnÇ pamàti
endmem   dw        0                        ; poá†teán° segment zak†zanÇ pamàti


segend   db        0                        ; koncov† adresa programu

data     ENDS


         END       start                    ; startovac° adresa programu

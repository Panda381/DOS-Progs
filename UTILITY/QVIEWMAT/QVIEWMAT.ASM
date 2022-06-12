
; *****************************************************************************
;
;                        Prohl¡§eŸ soubor… MAT
;
; *****************************************************************************
code     SEGMENT
         ASSUME    cs:code,ds:code
         ORG       100h

start:   jmp       cti

         dw        offset konec

buffvram equ       offset buff + 8000h      ; zaŸ tek bufferu s videostr nkou
xbuff    equ       offset buff + 4000h      ; adresa poloviny bufferu

old09    dd        0                        ; p…vodn¡ obsluha INT 09h

par      db        0                        ; pýep¡naŸe
                                            ;   bit 0: 1=dvojn sobn  ç¡ýka
         db        0

atrib    db        1bh                      ; atributy pro zobrazen¡ na displeji
pozic    db        80                       ; poŸet pozic na ý dek
radek    db        24                       ; posledn¡ ý dek na displeji
stranka  db        0                        ; aktivn¡ videostr nka
adrvram  dd        0b8000000h               ; adresa videostr nky
portcrt  dw        3d4h                     ; b zov  adresa portu CRT
delka    dw        80*25                    ; d‚lka videostr nky ve znac¡ch
kurzor   dw        0                        ; uschovan  pozice kurzoru

endline  dw        0                        ; pozice konce ý dku
topline  dw        0                        ; offset zaŸ tku ý dku
adrfile  dd        -1                       ; ukazatel bufferu v souboru
adrbuf   dw        offset konec             ; adresa v bufferu zaŸ tku str nky
adrend   dw        offset konec             ; adresa konce dat v bufferu

zahlavi  dw        0                        ; d‚lka z hlav¡

ident    dw        0                        ; identifik tor souboru
soubor   db        'CTI_MNE.MAT',0          ; implicitn¡ soubor

errtxt   db        'QVIEWMAT v1.10 - prohlizec souboru MAT; (c) Miroslav Nemecek',13,10
         db        'Zadejte jako parametr jmeno souboru k zobrazeni !$'
errtxt2  db        'Chyba videomodu !$'
errtxt3  db        'Chyba - nedostatek pameti !$'

; -----------------------------------------------------------------------------
;                                Start programu
; -----------------------------------------------------------------------------
public   cti
cti:
         cld                                ; smØr nahoru
         mov       si,81h
         xor       cx,cx
         mov       cl,ds:[si-1]             ; poŸet znak… parametru
         mov       dx,offset soubor         ; implicitn¡ soubor CTI.MNE
                                          ;* nalezen¡ zaŸ tku zad n¡ souboru
cti1:    jcxz      cti4                     ; nen¡ zad n¡ - je implicitn¡ soubor
         lodsb                              ; naŸten¡ znaku z ý dku
         dec       cx                       ; sn¡§en¡ Ÿ¡taŸe znak…
         cmp       al,13                    ; je konec ý dku CR ?
         je        cti4                     ; konec zad n¡ (je CR)
         cmp       al," "                   ; je oddØlovaŸ ?
         jbe       cti1                     ; je oddØlovaŸ - vypustØn¡
         mov       dx,si                    ; adresa zaŸ tku zadan‚ho textu
         dec       dx                       ; n vrat adresy zadan‚ho parametru
                                          ;* nalezen¡ konce zad n¡ souboru
cti2:    lodsb                              ; naŸten¡ znaku z ý dku
         jcxz      cti3                     ; konec ý dku
         dec       cx                       ; sn¡§en¡ Ÿ¡taŸe znak…
         cmp       al,13                    ; je konec ý dku CR ?
         je        cti3                     ; konec zad n¡ (je CR)
         cmp       al," "                   ; je oddØlovaŸ ?
         ja        cti2                     ; nen¡ oddØlovaŸ - dalç¡ znak
cti3:    mov       byte ptr ds:[si-1],0     ; oznaŸen¡ konce textu
                                          ;* otevýen¡ souboru
cti4:    mov       ax,3d00h
         int       21h                      ; otevýen¡ zadan‚ho souboru
         mov       ds:[ident],ax            ; £schova identifik toru souboru
         jnc       cti6                     ; soubor otevýen OK
                                          ;* chyba otevýen¡ souboru
         mov       dx,offset errtxt         ; chybovì text
cti5:    mov       ah,9
         int       21h                      ; zobrazen¡ chybov‚ho textu
         int       20h                      ; konec programu
cti6:                                     ;* zjiçtØn¡ typu displeje - videom¢du
         mov       ah,0fh
         int       10h                      ; poskytnut¡ videom¢du
         mov       ds:[pozic],ah            ; £schova poŸtu pozic na ý dek
         mov       ds:[stranka],bh          ; £schova aktivn¡ videostr nky
         and       al,7fh                   ; zruçen¡ bitu 7
         cmp       al,3                     ; je videom¢d CGA ?
         jbe       cti7                     ; je videom¢d CGA
         cmp       al,7                     ; je videom¢d MDA ?
         mov       dx,offset errtxt2        ; text - chybnì videom¢d
         jne       cti5                     ; nen¡ ani videom¢d MDA - chyba
         mov       word ptr ds:[adrvram+2],0b000h ; segment adresy displeje
         mov       byte ptr ds:[atrib],07h  ; atributy pro monochrom. zobrazen¡
cti7:                                     ;* z¡sk n¡ parametr… displeje
         push      es                       ; £schova ES
         xor       ax,ax                    ; AX <- 0
         mov       es,ax                    ; ES <- 0
         mov       ax,es:[44eh]             ; offset zaŸ tku videopamØti
         mov       word ptr ds:[adrvram],ax ; offset zaŸ tku videopamØti
         mov       ax,es:[463h]             ; b zov  adresa portu CRT
         mov       ds:[portcrt],ax          ; b zov  adresa portu CRT
                                          ;* zjiçtØn¡ poŸtu ý dk… a snØ§en¡
         push      es                       ; £schova ES (=0)
         xor       dx,dx                    ; DL <- 0 (pýednastaven¡)
         xor       bx,bx                    ; BH <- 0 (pýednastaven¡)
         mov       ax,1130h
         int       10h                      ; poskytnut¡ informac¡ o fontech EGA
         pop       es                       ; n vrat ES
         or        dl,dl                    ; je slu§ba podporovan  ?
         jz        cti8                     ; slu§ba nen¡ podporovan 
         mov       ds:[radek],dl            ; £schova Ÿ¡sla posledn¡ho ý dku
cti8:                                     ;* rozdØlen¡ buffer…
         pop       es                       ; n vrat ES
         mov       al,ds:[pozic]            ; poŸet pozic na ý dek
         mov       bl,ds:[radek]            ; Ÿ¡slo posledn¡ho ý dku
         inc       bl                       ; poŸet ý dk… na displeji
         mul       bl                       ; vìpoŸet celkov‚ho poŸtu znak…
         mov       ds:[delka],ax            ; poŸet zobrazenìch znak… celkem
         add       ax,ax                    ; poŸet bajt… na str nku
         add       ax,buffvram              ; vìpoŸet adresy konce buffer…
         jc        cti9                     ; chyba pýeteŸen¡ pamØti
         add       ax,200h                  ; rezerva pro z sobn¡k
         jc        cti9                     ; pýeteŸen¡ pamØti
         cmp       ax,sp                    ; je pýekroŸen¡ voln‚ho m¡sta ?
         jbe       ctia                     ; je jeçtØ dostatek m¡sta v pamØti
cti9:                                     ;* chyba pýeteŸen¡ pamØti
         mov       dx,offset errtxt3        ; text chyby nedostatku pamØti
         jmp       cti5                     ; zobrazen¡ chybov‚ho textu
ctia:                                     ;* £schova obsahu obrazovky
         mov       di,buffvram              ; adresa bufferu pro £schovu displ.
         mov       cx,ds:[delka]            ; d‚lka videopamØti ve znac¡ch
         push      ds                       ; £schova DS
         lds       si,ds:[adrvram]          ; adresa zaŸ tku displeje
         rep       movsw                    ; £schova obsahu displeje
         pop       ds                       ; n vrat DS
         mov       ah,3
         mov       bh,ds:[stranka]          ; aktivn¡ videostr nka
         int       10h                      ; poskytnut¡ pozice kurzoru
         mov       ds:[kurzor],dx           ; £schova pozice kurzoru
         mov       dh,ds:[radek]            ; Ÿ¡slo posledn¡ho ý dku
         inc       dh                       ; ý dek za displejem
         mov       ah,2
         int       10h                      ; nastaven¡ kurzoru za roh
                                          ;* inicializace obsluhy INT 23h
         push      es
         mov       dx,offset navrat         ; adresa ukonŸen¡ programu
         mov       ax,2523h
         int       21h                      ; nadefinov n¡ adresy INT 23h
         mov       ax,3509h
         int       21h                      ; poskytnut¡ adresy INT 09h
         mov       word ptr ds:[old09],bx   ; £schova adresy INT 09h
         mov       word ptr ds:[old09+2],es
         mov       dx,offset int09          ; obsluha INT 09h
         mov       ax,2509h
         int       21h                      ; nadefinov n¡ obsluhy INT 09h
         pop       es

         call      home                     ; naŸten¡ zaŸ tku souboru
         mov       ax,ds:[si+304]           ; velikost pý¡davnìch dat
         xchg      al,ah                    ; oprava poýad¡ bajt…
         add       ax,306
         mov       ds:[zahlavi],ax          ; nov  d‚lka z hlav¡
         mov       word ptr ds:[adrfile+2],-1 ; zruçen¡ bufferu

         call      home                     ; skok na zaŸ tek souboru
         mov       ds:[adrbuf],si           ; adresa zaŸ tku str nky v bufferu
ctib:                                     ;* cyklus obsluhy jedn‚ kl vesy
;         mov       bh,80h                   ; pý¡znak - zobraz¡ se vçechny ý dky
ctic:    call      zobrall                  ; zobrazen¡ displeje
ctid:    mov       ah,8
         int       21h                      ; vstup znaku z konzoly bez echa
         cmp       al,27                    ; je konec ESC ?
         je        navrat                   ; je konec ESC
         or        al,al                    ; bude ý¡dic¡ kl vesa ?
         jnz       ctid                     ; nebude ý¡dic¡ kl vesa - dalç¡
         mov       ah,8
         int       21h                      ; Ÿten¡ SCAN k¢du ý¡dic¡ kl vesy
         sub       al,47h                   ; odeŸten¡ offsetu ý¡dic¡ch kl ves
         jb        ctid                     ; nespr vn  kl vesa - znovu
         cmp       al,10
         ja        ctid                     ; nespr vn  kl vesa - znovu
         push      ax
         mov       ah,0bh
         int       21h                      ; test pýipravenosti dalç¡ kl vesy
         inc       al                       ; je pýipravena kl vesa ?
         pop       ax
         jz        ctid                     ; je dalç¡ kl vesa - vstup

         xor       bx,bx                    ; AX <- 9
         mov       bl,al                    ; k¢d kl vesy
         add       bx,bx                    ; k¢d kl vesy * 2
         mov       si,ds:[adrbuf]           ; adresa zaŸ tku zobrazen‚ str nky
         call      ds:[bx+tabskok]          ; vyvol n¡ obsluhy funkce
         mov       ds:[adrbuf],si           ; nov  adresa v bufferu
         jmp       short ctic               ; nov‚ zobrazen¡ displeje

navrat:                                   ;* n vrat z programu
         mov       si,buffvram              ; adresa bufferu displeje
         les       di,ds:[adrvram]          ; adresa videopamØti
         mov       cx,ds:[delka]            ; d‚lka videostr nky
         rep       movsw                    ; n vrat videostr nky
         mov       dx,ds:[kurzor]           ; p…vodn¡ pozice kurzoru
         mov       ah,2
         mov       bh,ds:[stranka]          ; aktivn¡ videostr nka
         int       10h                      ; n vrat p…vodn¡ pozice kurzoru
         mov       bx,ds:[ident]            ; identifik tor souboru
         mov       ah,3eh
         int       21h                      ; uzavýen¡ souboru
         lds       dx,ds:[old09]            ; p…vodn¡ adresa INT 09h
         mov       ax,2509h
         int       21h                      ; n vrat p…vodn¡ obsluhy INT 09h
         int       20h                      ; konec programu

public   zobrall
zobrall:                                  ;* zobrazen¡ str nky displeje

         push      word ptr ds:[par]        ; pý¡znak dvojn sobn‚ ç¡ýky
         push      es
                                          ;* inicializace konce ý dku
         xor       ax,ax
         mov       al,[pozic]               ; poŸet pozic na ý dek
         add       ax,ds:[topline]          ; vìpoŸet pozice konce ý dku
         mov       ds:[endline],ax          ; pozice zobrazen¡ konce ý dku
         xor       dx,dx                    ; DH <- 0 ukazatel ý dku textu
zobrall4:
         call      zobrline                 ; zobrazen¡ jednoho ý dku
         inc       dh                       ; zvìçen¡ Ÿ¡taŸe ý dk…
         cmp       dh,ds:[radek]            ; byl ji§ posledn¡ ý dek ?
         jbe       zobrall4                 ; nebyl jeçtØ posledn¡ ý dek
zobrall6:pop       es
         pop       word ptr ds:[par]        ; pý¡znak dvojn sobn‚ ç¡ýky
         ret


zobrline:                                 ;* zobrazen¡ ý dku textu (DH=ý dek)
         xor       bx,bx                    ; ukazatel pozice na ý dku
         xor       cx,cx                    ; CX <- 0
         mov       cl,ds:[pozic]            ; poŸet pozic na ý dek
         les       di,ds:[adrvram]          ; adresa videopamØti
         mov       al,ds:[pozic]            ; poŸet pozic na ý dek
         mul       dh                       ; offset ve videopamØti
         add       ax,ax                    ; offset v bajtech
         add       di,ax                    ; adresa ve videopamØti
                                          ;* zobrazen¡ jednoho znaku na ý dku
zobrlin2:call      readnxt                  ; naŸten¡ dalç¡ho znaku ze souboru
         jc        zobrlin6                 ; nen¡ dalç¡ znak v souboru


zobrln21:cmp       al,13                    ; je CR ?
         je        zobrlin2                 ; je CR - ignorov n¡
         cmp       al,10                    ; je LF ?
         je        zobrlin6                 ; je LF - konec ý dku
         mov       cx,1                     ; 1 znak k zobrazen¡
zobrln22:
                                          ;* znam‚nko "õ"
zobrln37:
         cmp       al," "
         jae       zobrlin3                 ; je bØ§nì znak
         jmp       short zobrlin2           ; znak < 32 se ignoruje

zobrlin3:call      zobrch                   ; zobrazen¡ jednoho znaku
         test      byte ptr ds:[par],1      ; je dvojn sobn  ç¡ýka ?
         jz        zobrln3a                 ; nen¡ dvojn sobn  ç¡ýka
         push      ax
         mov       al," "
         call      zobrch
         pop       ax
zobrln3a:loop      zobrlin3                 ; zobrazen¡ znaku
         jmp       short zobrlin2           ; zobrazen¡ dalç¡ho znaku
zobrlin5:                                 ;* vymaz n¡ zbytku ý dku
         mov       al," "
         call      zobrch                   ; zobrazen¡ jednoho znaku
zobrlin6:cmp       bx,ds:[endline]          ; je ji§ konec ý dku ?
         jb        zobrlin5                 ; zobrazen¡ dalç¡ho znaku
         ret


zobrch:                                   ;* zobrazen¡ jednoho znaku
                                            ; VSTUP: AL=znak
                                            ;        BX=pozice na ý dku
                                            ;        ES:DI=ukl dac¡ adresa

         mov       ah,ds:[atrib]            ; atribut pro zobrazen¡ textu
         cmp       bx,ds:[topline]          ; offset zobrazen¡ zaŸ tku ý dku
         jb        zobrch2                  ; je pýed poŸ tkem ý dku
         ja        zobrch1                  ; nen¡ prvn¡ znak na ý dku
         or        bx,bx                    ; je prvn¡ pozice ?
         jz        zobrch1                  ; je prvn¡ pozice
         cmp       si,ds:[adrend]           ; adresa konce dat v bufferu souboru
         jnc       zobrch1                  ; je konec souboru

         mov       al,"®"
         or        ah,0fh
         jmp       short zobrch4

zobrch1: cmp       bx,ds:[endline]          ; je za koncem zobrazen¡ ý dku ?
         ja        zobrch2                  ; je ji§ za koncem ý dku
         jb        zobrch4
         mov       al,"¯"
         or        ah,0fh
         sub       di,2
zobrch4: stosw                              ; ulo§en¡ znaku do videopamØti
zobrch2: inc       bx                       ; zvìçen¡ ukazatele pozice na ý dku
         ret





public   readnxt
readnxt:                                  ;* naŸten¡ dalç¡ho znaku z bufferu
         cmp       si,ds:[adrend]           ; adresa konce dat v bufferu souboru
         jnc       readnxt3                 ; nen¡ ji§ dalç¡ bajt v souboru
         cmp       si,buffvram              ; je ji§ konec bufferu ?
         jc        readnxt2                 ; nen¡ jeçtØ konec bufferu
                                          ;* naŸten¡ bloku dat
         push      cx                       ; £schova CX
         push      dx                       ; £schova DX
         push      di                       ; £schova DI
         push      es                       ; £schova ES
         push      ds                       ; DS -> stack
         pop       es                       ; ES <- DS
         mov       si,xbuff                 ; adresa poloviny bufferu
         mov       di,offset buff           ; adresa zaŸ tku bufferu
         mov       cx,2000h                 ; d‚lka poloviny bufferu ve slovech
         sub       word ptr ds:[adrbuf],4000h; nov  adresa zaŸ tku bufferu
         rep       movsw                    ; pýesun dat do prvn¡ poloviny buff.
         mov       si,di                    ; adresa poloviny bufferu
         add       word ptr ds:[adrfile],8000h ; zvìçen¡ ukazatele v souboru
         adc       word ptr ds:[adrfile+2],0 ; pýenos do vyçç¡ho slova
         mov       dx,xbuff                 ; adresa poloviny bufferu
         mov       cx,4000h                 ; poŸet bajt… k naŸten¡
         call      readfile                 ; naŸten¡ bloku dat ze souboru
         sub       word ptr ds:[adrfile],4000h ; n vrat ukazatele souboru
         sbb       word ptr ds:[adrfile+2],0 ; pýenos do vyçç¡ho slova
         pop       es                       ; n vrat ES
         pop       di                       ; n vrat DI
         pop       dx                       ; n vrat DX
         pop       cx                       ; n vrat CX
         jmp       short readnxt            ; naŸten¡ dalç¡ho znaku
readnxt2:lodsb                              ; naŸten¡ znaku z bufferu

         pushf
         cmp       al,10
         jne       readnx20
         and       byte ptr ds:[par],not 1  ; zruçen¡ çirok‚ho p¡sma
readnx20:cmp       al,22                    ; dvojn sobn  ç¡ýka ?
         jne       readnx22
readnx21:xor       byte ptr ds:[par],1      ; zmØna pý¡znaku dvojn sobn‚ ç¡ýky
readnx22:popf

readnxt3:cmc                                ; pý¡znak chyby
         ret

public   readpre
readpre:                                  ;* naŸten¡ pýedchoz¡ho znaku ze soub.
         cmp       si,offset buff           ; je ji§ zaŸ tek souboru ?
         ja        readpre2                 ; nen¡ jeçtØ zaŸ tek bufferu
         mov       ax,word ptr ds:[adrfile] ; ukazatel souboru - ni§ç¡ slovo
         or        ax,word ptr ds:[adrfile+2] ; je ji§ zaŸ tek souboru ?
         stc                                ; pý¡znak chyby
         jz        readpre3                 ; je ji§ zaŸ tek souboru - chyba
                                          ;* naŸten¡ dalç¡ho bloku dat
         push      cx                       ; £schova CX
         push      dx                       ; £schova DX
         mov       si,offset buff           ; zaŸ tek bufferu
         mov       di,xbuff                 ; polovina bufferu
         mov       cx,2000h                 ; poŸet slov poloviny bufferu
         add       word ptr ds:[adrbuf],4000h ; adresa zaŸ tku zobrazen¡ v buff.
         rep       movsw                    ; pýesun do druh‚ poloviny bufferu
         sub       word ptr ds:[adrfile],4000h ; sn¡§en¡ ukazatele v souboru
         sbb       word ptr ds:[adrfile+2],0 ; pýenos do vyçç¡ho slova ukazatele
         mov       dx,offset buff           ; adresa zaŸ tku bufferu
         mov       cx,4000h                 ; poŸet bajt… k naŸten¡
         call      readfile                 ; naŸten¡ dalç¡ho bloku dat ze soub.
         pop       dx                       ; n vrat DX
         pop       cx                       ; n vrat CX
readpre2:                                 ;* naŸten¡ znaku z bufferu
         dec       si                       ; sn¡§en¡ ukazatelele v bufferu
         mov       al,ds:[si]               ; znak z bufferu

         cmp       al,10
         jne       readpr20
         and       byte ptr ds:[par],not 1
readpr20:cmp       al,22                    ; dvojn sobn  ç¡ýka ?
         jne       readpr22
readpr21:xor       byte ptr ds:[par],1      ; zmØna pý¡znaku dvojn sobn‚ ç¡ýky
readpr22:

         clc                                ; pý¡znak - platnì znak
readpre3:ret

public   readfile
readfile:                                 ;* naŸten¡ CX bajt… ze souboru

         push      ax                       ; £schova AX
         push      bx                       ; £schova BX
         push      cx                       ; £schova CX
         push      dx                       ; £schova DX
         mov       word ptr ds:[adrend],0ffffh ; adresa konce bufferu - plnì
         mov       dx,word ptr ds:[adrfile] ; adresa v souboru - ni§ç¡ slovo
         mov       cx,word ptr ds:[adrfile+2] ; adresa v souboru - vyçç¡ slovo
         add       dx,ds:[zahlavi]          ; odeŸten¡ z hlav¡
         adc       cx,0
         mov       bx,ds:[ident]            ; identifik tor souboru
         xor       ax,ax                    ; podslu§ba - ukazatel od zaŸ tku
         mov       ah,42h
         int       21h                      ; nastaven¡ ukazatele souboru
         pop       dx                       ; n vrat DX (adresa bufferu)
         pop       cx                       ; n vrat CX (poŸet bajt…)
         mov       ah,3fh
         int       21h                      ; naŸten¡ dat ze souboru
         jnc       readfil2                 ; Ÿten¡ dat OK
         xor       ax,ax                    ; chyba Ÿten¡ - poŸet bajt… = 0
readfil2:cmp       ax,cx                    ; souhlas¡ poŸet bajt… ?
         je        readfil3                 ; poŸet bajt… souhlas¡ OK
         add       ax,dx                    ; adresa konce bufferu
         mov       ds:[adrend],ax           ; adresa konce dat v bufferu
readfil3:pop       bx                       ; n vrat BX
         pop       ax                       ; n vrat AX
         ret


tabskok  label     word                   ;* tabulka skok… do obsluh kl ves
         dw        offset home              ; 47h Home
         dw        offset up                ; 48h nahoru
         dw        offset pageup            ; 49h PageUp
         dw        offset nokey             ; 4ah [-]
         dw        offset left              ; 4bh vlevo
         dw        offset nokey             ; 4ch [5]
         dw        offset right             ; 4dh vpravo
         dw        offset nokey             ; 4eh [+]
         dw        offset end0              ; 4fh End
         dw        offset down              ; 50h dol…
         dw        offset pagedown          ; 51h PageDown

nokey:                                    ;* neobslou§en  kl vesa
         ret

public   home
home:                                     ;* skok na zaŸ tek souboru
         xor       bx,bx                    ; BX <- 0
         mov       ax,word ptr ds:[adrfile] ; ukazatel v souboru - ni§ç¡ slovo
         or        ax,word ptr ds:[adrfile+2]; ukazatel v souboru - vyçç¡ slovo
         mov       word ptr ds:[adrfile],bx ; ukazatel v souboru - ni§ç¡ slovo
         mov       word ptr ds:[adrfile+2],bx; ukazatel v souboru - vyçç¡ slovo
         mov       ds:[topline],bx          ; offset zaŸ tku ý dku
         mov       word ptr ds:[par],bx     ; pý¡znak dvojn sobn‚ ç¡ýky
         jz        home1                    ; je ji§ zaŸ tek souboru
                                          ;* naŸten¡ dalç¡ho bloku dat
         mov       dx,offset buff           ; zaŸ tek bufferu
         mov       cx,8000h                 ; d‚lka bufferu
         call      readfile                 ; naŸten¡ cel‚ho bufferu
home1:   mov       si,offset buff
;         mov       word ptr ds:[adrbuf],si  ; adresa zaŸ tku str nky v bufferu
;         mov       bh,80h                   ; pý¡znak pýekreslen¡ cel‚ str nky
         ret

up:                                       ;* kurzor nahoru UP
         push      dx
         call      readpre                  ; naŸten¡ pýedchoz¡ho znaku (CR)
         jc        up3                      ; nen¡ dalç¡ znak - je ji§ zaŸ tek
up1:     mov       dl,al                    ; £schova pýedchoz¡ho znaku
         call      readpre                  ; naŸten¡ pýedchoz¡ho znaku
         jc        up2                      ; nen¡ dalç¡ znak
         cmp       al,10                    ; je znak LF ?
         jne       up1                      ; nen¡ jeçtØ LF - dalç¡ znak
;         cmp       dl,"@"
;         je        up1                      ; je znak "@" - ý dek se zruç¡

         call      readnxt                  ; n vrat znaku LF
up2:
         clc                                ; pý¡znak - operace se provedla
up3:     pop       dx
         ret



pagedown:                                 ;* str nka dol… PageDown
         xor       cx,cx
         mov       cl,ds:[radek]            ; poŸet ý dk… - 1
pagedn1: call      down                     ; posun o ý dek dol…
         jc        pagedn3                  ; nen¡ ji§ dalç¡ ý dek
         loop      pagedn1                  ; dalç¡ ý dek dol…
pagedn2: ret


pagedn3: call      pageup
         jmp       down



pageup:                                   ;* str nka nahoru PageUp
         xor       cx,cx
         mov       cl,ds:[radek]            ; poŸet ý dk… - 1
pageup1: call      up                       ; posun o ý dek nahoru
         jc        pageup2                  ; nen¡ dalç¡ ý dek
         loop      pageup1                  ; dalç¡ ý dek
pageup2: ret

left:                                     ;* kurzor vlevo
         cmp       word ptr ds:[topline],8  ; je ji§ zaŸ tek ý dku ?
         jb        left2                    ; je ji§ zaŸ tek ý dku
         sub       word ptr ds:[topline],8  ; sn¡§en¡ offsetu zaŸ tku ý dku
;         mov       bh,80h                   ; pý¡znak pýekreslen¡ obrazovky
left2:   ret

right:                                    ;* kurzor vpravo
         add       word ptr ds:[topline],8  ; zvìçen¡ offsetu zaŸ tku ý dku
;         mov       bh,80h                   ; pý¡znak pýekreslen¡ obrazovky
         ret

end0:                                     ;* konec souboru END
         call      down                     ; posun o ý dek dol…
         jc        end3                     ; je ji§ konec souboru
end1:    call      down                     ; posun o ý dek dol…
         jnc       end1                     ; posun o dalç¡ ý dek
end3:    mov       word ptr ds:[topline],0  ; offset zaŸ tku ý dku
;         mov       bh,80h
         jmp       pagedn3                  ; n vrat o str nku nahoru


down:                                     ;* kurzor dol… DOWN
         cmp       si,offset buff           ; je ji§ zaŸ tek souboru ?
         jne       down1                    ; nen¡ zaŸ tek bufferu
         mov       ax,word ptr ds:[adrfile] ; ukazatel souboru - ni§ç¡ slovo
         or        ax,word ptr ds:[adrfile+2] ; je ji§ zaŸ tek souboru ?
         jne       down1                    ; nen¡ zaŸ tek souboru
         call      readnxt
         jc        down4
;         cmp       al,"@"
;         jne       down1
;         call      down1                    ; nalezen¡ konce ý dku
down1:   call      readnxt                  ; naŸten¡ dalç¡ho znaku ze souboru
         jc        down4                    ; konec souboru - n vrat ý dku
down2:   cmp       al,10                    ; je LF ?
         jne       down1                    ; nen¡ LF - dalç¡ znak
;         call      readnxt                  ; naŸten¡ dalç¡ho znaku
;         jc        down33
;         cmp       al,"@"
;         je        down1                    ; pýeskoŸen¡ ý dku
;         call      readpre                  ; n vrat znaku
down33:  clc
down3:   ret
                                          ;* posledn¡ ý dek - jeho n vrat
down4:   call      readpre                  ; naŸten¡ pýedchoz¡ho znaku
         jc        down5                    ; nen¡ dalç¡ znak
         cmp       al,10                    ; je znak LF ?
         jne       down4                    ; nen¡ jeçtØ LF - dalç¡ znak
         call      readnxt                  ; n vrat - naŸten¡ dalç¡ho znaku
down5:   stc                                ; pý¡znak - operace se neprovedla
         ret


int09:                                    ;* obsluha INT 09h

         push      ax
         push      bx
         push      ds
         mov       bx,40h                   ; datovì segment BIOS
         mov       ds,bx                    ; DS <- datovì segment BIOS
         mov       bx,ds:[1ch]              ; £schova ukazatele znak…
         pushf
         call      dword ptr cs:[old09]     ; vol n¡ p…vodn¡ obsluhy INT 09h
         cmp       ds:[1ch],bx              ; byl pýijat znak ?
         je        int092                   ; nebyl pýijat znak
                                          ;* kontrola, zda je rezerva 1 znak
         push      bx
         mov       bx,ds:[1ch]              ; nov  ukl dac¡ adresa
         call      int09ins                 ; zvìçen¡ ukl dac¡ adresy
         pop       bx                       ; n vrat p…vodn¡ho ukazatele
         jne       int092                   ; nebude pýesycen¡
         mov       ds:[1ch],bx              ; pýesycen¡, zruçen¡ znaku v bufferu
int092:  pop       ds
         pop       bx
         pop       ax
         iret

int09ins:                                 ;* zvìçen¡ ukl dac¡ adresy BX
                                            ; VíSTUP: ZY=bude pýesycen¡

         add       bx,2                     ; zvìçen¡ ukl dac¡ adresy
         cmp       bx,3eh                   ; je pýekroŸen¡ konce bufferu ?
         jb        int09in2                 ; nen¡ jeçtØ pýekroŸen konec bufferu
         sub       bx,20h                   ; pýesun ukazatele na zaŸ tek
int09in2:cmp       bx,ds:[1ah]              ; bude ji§ pýesycen¡ ?
         ret

konec    label     near                     ; konec programu
; -------------------------- buffery ------------------------------------------
         EVEN                               ; zarovn n¡ na sudou adresu
buff     label     byte                     ; buffer pro pr ci se souborem

code     ENDS
         END       start

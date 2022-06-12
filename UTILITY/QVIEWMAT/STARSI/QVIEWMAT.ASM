
; *****************************************************************************
;
;                        Prohl¡‘e‡ soubor– MAT
;
; *****************************************************************************
code     SEGMENT
         ASSUME    cs:code,ds:code
         ORG       100h

start:   jmp       cti

         dw        offset konec

buffvram equ       offset buff + 8000h      ; za‡ tek bufferu s videostr nkou
xbuff    equ       offset buff + 4000h      ; adresa poloviny bufferu

old09    dd        0                        ; p–vodn¡ obsluha INT 09h

par      db        0                        ; p©ep¡na‡e
                                            ;   bit 0: 1=dvojn sobn  ¨¡©ka
         db        0

atrib    db        1bh                      ; atributy pro zobrazen¡ na displeji
pozic    db        80                       ; po‡et pozic na © dek
radek    db        24                       ; posledn¡ © dek na displeji
stranka  db        0                        ; aktivn¡ videostr nka
adrvram  dd        0b8000000h               ; adresa videostr nky
portcrt  dw        3d4h                     ; b zov  adresa portu CRT
delka    dw        80*25                    ; d‚lka videostr nky ve znac¡ch
kurzor   dw        0                        ; uschovan  pozice kurzoru

endline  dw        0                        ; pozice konce © dku
topline  dw        0                        ; offset za‡ tku © dku
adrfile  dd        -1                       ; ukazatel bufferu v souboru
adrbuf   dw        offset konec             ; adresa v bufferu za‡ tku str nky
adrend   dw        offset konec             ; adresa konce dat v bufferu

ident    dw        0                        ; identifik tor souboru
soubor   db        'CTI_MNE.MAT',0          ; implicitn¡ soubor

errtxt   db        'Chyba - soubor nenalezen !$'
errtxt2  db        'Chyba videomodu !$'
errtxt3  db        'Chyba - nedostatek pameti !$'

; -----------------------------------------------------------------------------
;                                Start programu
; -----------------------------------------------------------------------------
public   cti
cti:
         cld                                ; smˆr nahoru
         mov       si,81h
         xor       cx,cx
         mov       cl,ds:[si-1]             ; po‡et znak– parametru
         mov       dx,offset soubor         ; implicitn¡ soubor CTI.MNE
                                          ;* nalezen¡ za‡ tku zad n¡ souboru
cti1:    jcxz      cti4                     ; nen¡ zad n¡ - je implicitn¡ soubor
         lodsb                              ; na‡ten¡ znaku z © dku
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         cmp       al,13                    ; je konec © dku CR ?
         je        cti4                     ; konec zad n¡ (je CR)
         cmp       al," "                   ; je oddˆlova‡ ?
         jbe       cti1                     ; je oddˆlova‡ - vypustˆn¡
         mov       dx,si                    ; adresa za‡ tku zadan‚ho textu
         dec       dx                       ; n vrat adresy zadan‚ho parametru
                                          ;* nalezen¡ konce zad n¡ souboru
cti2:    lodsb                              ; na‡ten¡ znaku z © dku
         jcxz      cti3                     ; konec © dku
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         cmp       al,13                    ; je konec © dku CR ?
         je        cti3                     ; konec zad n¡ (je CR)
         cmp       al," "                   ; je oddˆlova‡ ?
         ja        cti2                     ; nen¡ oddˆlova‡ - dal¨¡ znak
cti3:    mov       byte ptr ds:[si-1],0     ; ozna‡en¡ konce textu
                                          ;* otev©en¡ souboru
cti4:    mov       ax,3d00h
         int       21h                      ; otev©en¡ zadan‚ho souboru
         mov       ds:[ident],ax            ; £schova identifik toru souboru
         jnc       cti6                     ; soubor otev©en OK
                                          ;* chyba otev©en¡ souboru
         mov       dx,offset errtxt         ; chybov˜ text
cti5:    mov       ah,9
         int       21h                      ; zobrazen¡ chybov‚ho textu
         int       20h                      ; konec programu
cti6:                                     ;* zji¨tˆn¡ typu displeje - videom¢du
         mov       ah,0fh
         int       10h                      ; poskytnut¡ videom¢du
         mov       ds:[pozic],ah            ; £schova po‡tu pozic na © dek
         mov       ds:[stranka],bh          ; £schova aktivn¡ videostr nky
         and       al,7fh                   ; zru¨en¡ bitu 7
         cmp       al,3                     ; je videom¢d CGA ?
         jbe       cti7                     ; je videom¢d CGA
         cmp       al,7                     ; je videom¢d MDA ?
         mov       dx,offset errtxt2        ; text - chybn˜ videom¢d
         jne       cti5                     ; nen¡ ani videom¢d MDA - chyba
         mov       word ptr ds:[adrvram+2],0b000h ; segment adresy displeje
         mov       byte ptr ds:[atrib],07h  ; atributy pro monochrom. zobrazen¡
cti7:                                     ;* z¡sk n¡ parametr– displeje
         push      es                       ; £schova ES
         xor       ax,ax                    ; AX <- 0
         mov       es,ax                    ; ES <- 0
         mov       ax,es:[44eh]             ; offset za‡ tku videopamˆti
         mov       word ptr ds:[adrvram],ax ; offset za‡ tku videopamˆti
         mov       ax,es:[463h]             ; b zov  adresa portu CRT
         mov       ds:[portcrt],ax          ; b zov  adresa portu CRT
                                          ;* zji¨tˆn¡ po‡tu © dk– a snˆ‘en¡
         push      es                       ; £schova ES (=0)
         xor       dx,dx                    ; DL <- 0 (p©ednastaven¡)
         xor       bx,bx                    ; BH <- 0 (p©ednastaven¡)
         mov       ax,1130h
         int       10h                      ; poskytnut¡ informac¡ o fontech EGA
         pop       es                       ; n vrat ES
         or        dl,dl                    ; je slu‘ba podporovan  ?
         jz        cti8                     ; slu‘ba nen¡ podporovan 
         mov       ds:[radek],dl            ; £schova ‡¡sla posledn¡ho © dku
cti8:                                     ;* rozdˆlen¡ buffer–
         pop       es                       ; n vrat ES
         mov       al,ds:[pozic]            ; po‡et pozic na © dek
         mov       bl,ds:[radek]            ; ‡¡slo posledn¡ho © dku
         inc       bl                       ; po‡et © dk– na displeji
         mul       bl                       ; v˜po‡et celkov‚ho po‡tu znak–
         mov       ds:[delka],ax            ; po‡et zobrazen˜ch znak– celkem
         add       ax,ax                    ; po‡et bajt– na str nku
         add       ax,buffvram              ; v˜po‡et adresy konce buffer–
         jc        cti9                     ; chyba p©ete‡en¡ pamˆti
         add       ax,200h                  ; rezerva pro z sobn¡k
         jc        cti9                     ; p©ete‡en¡ pamˆti
         cmp       ax,sp                    ; je p©ekro‡en¡ voln‚ho m¡sta ?
         jbe       ctia                     ; je je¨tˆ dostatek m¡sta v pamˆti
cti9:                                     ;* chyba p©ete‡en¡ pamˆti
         mov       dx,offset errtxt3        ; text chyby nedostatku pamˆti
         jmp       cti5                     ; zobrazen¡ chybov‚ho textu
ctia:                                     ;* £schova obsahu obrazovky
         mov       di,buffvram              ; adresa bufferu pro £schovu displ.
         mov       cx,ds:[delka]            ; d‚lka videopamˆti ve znac¡ch
         push      ds                       ; £schova DS
         lds       si,ds:[adrvram]          ; adresa za‡ tku displeje
         rep       movsw                    ; £schova obsahu displeje
         pop       ds                       ; n vrat DS
         mov       ah,3
         mov       bh,ds:[stranka]          ; aktivn¡ videostr nka
         int       10h                      ; poskytnut¡ pozice kurzoru
         mov       ds:[kurzor],dx           ; £schova pozice kurzoru
         mov       dh,ds:[radek]            ; ‡¡slo posledn¡ho © dku
         inc       dh                       ; © dek za displejem
         mov       ah,2
         int       10h                      ; nastaven¡ kurzoru za roh
                                          ;* inicializace obsluhy INT 23h
         push      es
         mov       dx,offset navrat         ; adresa ukon‡en¡ programu
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

         call      home                     ; skok na za‡ tek souboru
         mov       ds:[adrbuf],si           ; adresa za‡ tku str nky v bufferu
ctib:                                     ;* cyklus obsluhy jedn‚ kl vesy
;         mov       bh,80h                   ; p©¡znak - zobraz¡ se v¨echny © dky
ctic:    call      zobrall                  ; zobrazen¡ displeje
ctid:    mov       ah,8
         int       21h                      ; vstup znaku z konzoly bez echa
         cmp       al,27                    ; je konec ESC ?
         je        navrat                   ; je konec ESC
         or        al,al                    ; bude ©¡dic¡ kl vesa ?
         jnz       ctid                     ; nebude ©¡dic¡ kl vesa - dal¨¡
         mov       ah,8
         int       21h                      ; ‡ten¡ SCAN k¢du ©¡dic¡ kl vesy
         sub       al,47h                   ; ode‡ten¡ offsetu ©¡dic¡ch kl ves
         jb        ctid                     ; nespr vn  kl vesa - znovu
         cmp       al,10
         ja        ctid                     ; nespr vn  kl vesa - znovu
         push      ax
         mov       ah,0bh
         int       21h                      ; test p©ipravenosti dal¨¡ kl vesy
         inc       al                       ; je p©ipravena kl vesa ?
         pop       ax
         jz        ctid                     ; je dal¨¡ kl vesa - vstup

         xor       bx,bx                    ; AX <- 9
         mov       bl,al                    ; k¢d kl vesy
         add       bx,bx                    ; k¢d kl vesy * 2
         mov       si,ds:[adrbuf]           ; adresa za‡ tku zobrazen‚ str nky
         call      ds:[bx+tabskok]          ; vyvol n¡ obsluhy funkce
         mov       ds:[adrbuf],si           ; nov  adresa v bufferu
         jmp       short ctic               ; nov‚ zobrazen¡ displeje

navrat:                                   ;* n vrat z programu
         mov       si,buffvram              ; adresa bufferu displeje
         les       di,ds:[adrvram]          ; adresa videopamˆti
         mov       cx,ds:[delka]            ; d‚lka videostr nky
         rep       movsw                    ; n vrat videostr nky
         mov       dx,ds:[kurzor]           ; p–vodn¡ pozice kurzoru
         mov       ah,2
         mov       bh,ds:[stranka]          ; aktivn¡ videostr nka
         int       10h                      ; n vrat p–vodn¡ pozice kurzoru
         mov       bx,ds:[ident]            ; identifik tor souboru
         mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru
         lds       dx,ds:[old09]            ; p–vodn¡ adresa INT 09h
         mov       ax,2509h
         int       21h                      ; n vrat p–vodn¡ obsluhy INT 09h
         int       20h                      ; konec programu

public   zobrall
zobrall:                                  ;* zobrazen¡ str nky displeje

         push      word ptr ds:[par]        ; p©¡znak dvojn sobn‚ ¨¡©ky
         push      es
                                          ;* inicializace konce © dku
         xor       ax,ax
         mov       al,[pozic]               ; po‡et pozic na © dek
         add       ax,ds:[topline]          ; v˜po‡et pozice konce © dku
         mov       ds:[endline],ax          ; pozice zobrazen¡ konce © dku
         xor       dx,dx                    ; DH <- 0 ukazatel © dku textu
zobrall4:
         call      zobrline                 ; zobrazen¡ jednoho © dku
         inc       dh                       ; zv˜¨en¡ ‡¡ta‡e © dk–
         cmp       dh,ds:[radek]            ; byl ji‘ posledn¡ © dek ?
         jbe       zobrall4                 ; nebyl je¨tˆ posledn¡ © dek
zobrall6:pop       es
         pop       word ptr ds:[par]        ; p©¡znak dvojn sobn‚ ¨¡©ky
         ret


zobrline:                                 ;* zobrazen¡ © dku textu (DH=© dek)
         xor       bx,bx                    ; ukazatel pozice na © dku
         xor       cx,cx                    ; CX <- 0
         mov       cl,ds:[pozic]            ; po‡et pozic na © dek
         les       di,ds:[adrvram]          ; adresa videopamˆti
         mov       al,ds:[pozic]            ; po‡et pozic na © dek
         mul       dh                       ; offset ve videopamˆti
         add       ax,ax                    ; offset v bajtech
         add       di,ax                    ; adresa ve videopamˆti
                                          ;* zobrazen¡ jednoho znaku na © dku
zobrlin2:call      readnxt                  ; na‡ten¡ dal¨¡ho znaku ze souboru
         jc        zobrlin6                 ; nen¡ dal¨¡ znak v souboru


zobrln21:cmp       al,13                    ; je CR ?
         je        zobrlin2                 ; je CR - ignorov n¡
         cmp       al,10                    ; je LF ?
         je        zobrlin6                 ; je LF - konec © dku
         mov       cx,1                     ; 1 znak k zobrazen¡
zobrln22:
                                          ;* znam‚nko "­"
zobrln37:
         cmp       al," "
         jae       zobrlin3                 ; je bˆ‘n˜ znak
         jmp       short zobrlin2           ; znak < 32 se ignoruje

zobrlin3:call      zobrch                   ; zobrazen¡ jednoho znaku
         test      byte ptr ds:[par],1      ; je dvojn sobn  ¨¡©ka ?
         jz        zobrln3a                 ; nen¡ dvojn sobn  ¨¡©ka
         push      ax
         mov       al," "
         call      zobrch
         pop       ax
zobrln3a:loop      zobrlin3                 ; zobrazen¡ znaku
         jmp       short zobrlin2           ; zobrazen¡ dal¨¡ho znaku
zobrlin5:                                 ;* vymaz n¡ zbytku © dku
         mov       al," "
         call      zobrch                   ; zobrazen¡ jednoho znaku
zobrlin6:cmp       bx,ds:[endline]          ; je ji‘ konec © dku ?
         jb        zobrlin5                 ; zobrazen¡ dal¨¡ho znaku
         ret


zobrch:                                   ;* zobrazen¡ jednoho znaku
                                            ; VSTUP: AL=znak
                                            ;        BX=pozice na © dku
                                            ;        ES:DI=ukl dac¡ adresa

         mov       ah,ds:[atrib]            ; atribut pro zobrazen¡ textu
         cmp       bx,ds:[topline]          ; offset zobrazen¡ za‡ tku © dku
         jb        zobrch2                  ; je p©ed po‡ tkem © dku
         ja        zobrch1                  ; nen¡ prvn¡ znak na © dku
         or        bx,bx                    ; je prvn¡ pozice ?
         jz        zobrch1                  ; je prvn¡ pozice
         cmp       si,ds:[adrend]           ; adresa konce dat v bufferu souboru
         jnc       zobrch1                  ; je konec souboru

         mov       al,"®"
         or        ah,0fh
         jmp       short zobrch4

zobrch1: cmp       bx,ds:[endline]          ; je za koncem zobrazen¡ © dku ?
         ja        zobrch2                  ; je ji‘ za koncem © dku
         jb        zobrch4
         mov       al,"¯"
         or        ah,0fh
         sub       di,2
zobrch4: stosw                              ; ulo‘en¡ znaku do videopamˆti
zobrch2: inc       bx                       ; zv˜¨en¡ ukazatele pozice na © dku
         ret





public   readnxt
readnxt:                                  ;* na‡ten¡ dal¨¡ho znaku z bufferu
         cmp       si,ds:[adrend]           ; adresa konce dat v bufferu souboru
         jnc       readnxt3                 ; nen¡ ji‘ dal¨¡ bajt v souboru
         cmp       si,buffvram              ; je ji‘ konec bufferu ?
         jc        readnxt2                 ; nen¡ je¨tˆ konec bufferu
                                          ;* na‡ten¡ bloku dat
         push      cx                       ; £schova CX
         push      dx                       ; £schova DX
         push      di                       ; £schova DI
         push      es                       ; £schova ES
         push      ds                       ; DS -> stack
         pop       es                       ; ES <- DS
         mov       si,xbuff                 ; adresa poloviny bufferu
         mov       di,offset buff           ; adresa za‡ tku bufferu
         mov       cx,2000h                 ; d‚lka poloviny bufferu ve slovech
         sub       word ptr ds:[adrbuf],4000h; nov  adresa za‡ tku bufferu
         rep       movsw                    ; p©esun dat do prvn¡ poloviny buff.
         mov       si,di                    ; adresa poloviny bufferu
         add       word ptr ds:[adrfile],8000h ; zv˜¨en¡ ukazatele v souboru
         adc       word ptr ds:[adrfile+2],0 ; p©enos do vy¨¨¡ho slova
         mov       dx,xbuff                 ; adresa poloviny bufferu
         mov       cx,4000h                 ; po‡et bajt– k na‡ten¡
         call      readfile                 ; na‡ten¡ bloku dat ze souboru
         sub       word ptr ds:[adrfile],4000h ; n vrat ukazatele souboru
         sbb       word ptr ds:[adrfile+2],0 ; p©enos do vy¨¨¡ho slova
         pop       es                       ; n vrat ES
         pop       di                       ; n vrat DI
         pop       dx                       ; n vrat DX
         pop       cx                       ; n vrat CX
         jmp       short readnxt            ; na‡ten¡ dal¨¡ho znaku
readnxt2:lodsb                              ; na‡ten¡ znaku z bufferu

         pushf
         cmp       al,10
         jne       readnx20
         and       byte ptr ds:[par],not 1  ; zru¨en¡ ¨irok‚ho p¡sma
readnx20:cmp       al,22                    ; dvojn sobn  ¨¡©ka ?
         jne       readnx22
readnx21:xor       byte ptr ds:[par],1      ; zmˆna p©¡znaku dvojn sobn‚ ¨¡©ky
readnx22:popf

readnxt3:cmc                                ; p©¡znak chyby
         ret

public   readpre
readpre:                                  ;* na‡ten¡ p©edchoz¡ho znaku ze soub.
         cmp       si,offset buff           ; je ji‘ za‡ tek souboru ?
         ja        readpre2                 ; nen¡ je¨tˆ za‡ tek bufferu
         mov       ax,word ptr ds:[adrfile] ; ukazatel souboru - ni‘¨¡ slovo
         or        ax,word ptr ds:[adrfile+2] ; je ji‘ za‡ tek souboru ?
         stc                                ; p©¡znak chyby
         jz        readpre3                 ; je ji‘ za‡ tek souboru - chyba
                                          ;* na‡ten¡ dal¨¡ho bloku dat
         push      cx                       ; £schova CX
         push      dx                       ; £schova DX
         mov       si,offset buff           ; za‡ tek bufferu
         mov       di,xbuff                 ; polovina bufferu
         mov       cx,2000h                 ; po‡et slov poloviny bufferu
         add       word ptr ds:[adrbuf],4000h ; adresa za‡ tku zobrazen¡ v buff.
         rep       movsw                    ; p©esun do druh‚ poloviny bufferu
         sub       word ptr ds:[adrfile],4000h ; sn¡‘en¡ ukazatele v souboru
         sbb       word ptr ds:[adrfile+2],0 ; p©enos do vy¨¨¡ho slova ukazatele
         mov       dx,offset buff           ; adresa za‡ tku bufferu
         mov       cx,4000h                 ; po‡et bajt– k na‡ten¡
         call      readfile                 ; na‡ten¡ dal¨¡ho bloku dat ze soub.
         pop       dx                       ; n vrat DX
         pop       cx                       ; n vrat CX
readpre2:                                 ;* na‡ten¡ znaku z bufferu
         dec       si                       ; sn¡‘en¡ ukazatelele v bufferu
         mov       al,ds:[si]               ; znak z bufferu

         cmp       al,10
         jne       readpr20
         and       byte ptr ds:[par],not 1
readpr20:cmp       al,22                    ; dvojn sobn  ¨¡©ka ?
         jne       readpr22
readpr21:xor       byte ptr ds:[par],1      ; zmˆna p©¡znaku dvojn sobn‚ ¨¡©ky
readpr22:

         clc                                ; p©¡znak - platn˜ znak
readpre3:ret

public   readfile
readfile:                                 ;* na‡ten¡ CX bajt– ze souboru

         push      ax                       ; £schova AX
         push      bx                       ; £schova BX
         push      cx                       ; £schova CX
         push      dx                       ; £schova DX
         mov       word ptr ds:[adrend],0ffffh ; adresa konce bufferu - pln˜
         mov       dx,word ptr ds:[adrfile] ; adresa v souboru - ni‘¨¡ slovo
         mov       cx,word ptr ds:[adrfile+2] ; adresa v souboru - vy¨¨¡ slovo
         add       dx,306                   ; ode‡ten¡ z hlav¡
         adc       cx,0
         mov       bx,ds:[ident]            ; identifik tor souboru
         xor       ax,ax                    ; podslu‘ba - ukazatel od za‡ tku
         mov       ah,42h
         int       21h                      ; nastaven¡ ukazatele souboru
         pop       dx                       ; n vrat DX (adresa bufferu)
         pop       cx                       ; n vrat CX (po‡et bajt–)
         mov       ah,3fh
         int       21h                      ; na‡ten¡ dat ze souboru
         jnc       readfil2                 ; ‡ten¡ dat OK
         xor       ax,ax                    ; chyba ‡ten¡ - po‡et bajt– = 0
readfil2:cmp       ax,cx                    ; souhlas¡ po‡et bajt– ?
         je        readfil3                 ; po‡et bajt– souhlas¡ OK
         add       ax,dx                    ; adresa konce bufferu
         mov       ds:[adrend],ax           ; adresa konce dat v bufferu
readfil3:pop       bx                       ; n vrat BX
         pop       ax                       ; n vrat AX
         ret


tabskok  label     word                   ;* tabulka skok– do obsluh kl ves
         dw        offset home              ; 47h Home
         dw        offset up                ; 48h nahoru
         dw        offset pageup            ; 49h PageUp
         dw        offset nokey             ; 4ah [-]
         dw        offset left              ; 4bh vlevo
         dw        offset nokey             ; 4ch [5]
         dw        offset right             ; 4dh vpravo
         dw        offset nokey             ; 4eh [+]
         dw        offset end0              ; 4fh End
         dw        offset down              ; 50h dol–
         dw        offset pagedown          ; 51h PageDown

nokey:                                    ;* neobslou‘en  kl vesa
         ret

public   home
home:                                     ;* skok na za‡ tek souboru
         xor       bx,bx                    ; BX <- 0
         mov       ax,word ptr ds:[adrfile] ; ukazatel v souboru - ni‘¨¡ slovo
         or        ax,word ptr ds:[adrfile+2]; ukazatel v souboru - vy¨¨¡ slovo
         mov       word ptr ds:[adrfile],bx ; ukazatel v souboru - ni‘¨¡ slovo
         mov       word ptr ds:[adrfile+2],bx; ukazatel v souboru - vy¨¨¡ slovo
         mov       ds:[topline],bx          ; offset za‡ tku © dku
         mov       word ptr ds:[par],bx     ; p©¡znak dvojn sobn‚ ¨¡©ky
         jz        home1                    ; je ji‘ za‡ tek souboru
                                          ;* na‡ten¡ dal¨¡ho bloku dat
         mov       dx,offset buff           ; za‡ tek bufferu
         mov       cx,8000h                 ; d‚lka bufferu
         call      readfile                 ; na‡ten¡ cel‚ho bufferu
home1:   mov       si,offset buff
;         mov       word ptr ds:[adrbuf],si  ; adresa za‡ tku str nky v bufferu
;         mov       bh,80h                   ; p©¡znak p©ekreslen¡ cel‚ str nky
         ret

up:                                       ;* kurzor nahoru UP
         push      dx
         call      readpre                  ; na‡ten¡ p©edchoz¡ho znaku (CR)
         jc        up3                      ; nen¡ dal¨¡ znak - je ji‘ za‡ tek
up1:     mov       dl,al                    ; £schova p©edchoz¡ho znaku
         call      readpre                  ; na‡ten¡ p©edchoz¡ho znaku
         jc        up2                      ; nen¡ dal¨¡ znak
         cmp       al,10                    ; je znak LF ?
         jne       up1                      ; nen¡ je¨tˆ LF - dal¨¡ znak
;         cmp       dl,"@"
;         je        up1                      ; je znak "@" - © dek se zru¨¡

         call      readnxt                  ; n vrat znaku LF
up2:
         clc                                ; p©¡znak - operace se provedla
up3:     pop       dx
         ret



pagedown:                                 ;* str nka dol– PageDown
         xor       cx,cx
         mov       cl,ds:[radek]            ; po‡et © dk– - 1
pagedn1: call      down                     ; posun o © dek dol–
         jc        pagedn3                  ; nen¡ ji‘ dal¨¡ © dek
         loop      pagedn1                  ; dal¨¡ © dek dol–
pagedn2: ret


pagedn3: call      pageup
         jmp       down



pageup:                                   ;* str nka nahoru PageUp
         xor       cx,cx
         mov       cl,ds:[radek]            ; po‡et © dk– - 1
pageup1: call      up                       ; posun o © dek nahoru
         jc        pageup2                  ; nen¡ dal¨¡ © dek
         loop      pageup1                  ; dal¨¡ © dek
pageup2: ret

left:                                     ;* kurzor vlevo
         cmp       word ptr ds:[topline],8  ; je ji‘ za‡ tek © dku ?
         jb        left2                    ; je ji‘ za‡ tek © dku
         sub       word ptr ds:[topline],8  ; sn¡‘en¡ offsetu za‡ tku © dku
;         mov       bh,80h                   ; p©¡znak p©ekreslen¡ obrazovky
left2:   ret

right:                                    ;* kurzor vpravo
         add       word ptr ds:[topline],8  ; zv˜¨en¡ offsetu za‡ tku © dku
;         mov       bh,80h                   ; p©¡znak p©ekreslen¡ obrazovky
         ret

end0:                                     ;* konec souboru END
         call      down                     ; posun o © dek dol–
         jc        end3                     ; je ji‘ konec souboru
end1:    call      down                     ; posun o © dek dol–
         jnc       end1                     ; posun o dal¨¡ © dek
end3:    mov       word ptr ds:[topline],0  ; offset za‡ tku © dku
;         mov       bh,80h
         jmp       pagedn3                  ; n vrat o str nku nahoru


down:                                     ;* kurzor dol– DOWN
         cmp       si,offset buff           ; je ji‘ za‡ tek souboru ?
         jne       down1                    ; nen¡ za‡ tek bufferu
         mov       ax,word ptr ds:[adrfile] ; ukazatel souboru - ni‘¨¡ slovo
         or        ax,word ptr ds:[adrfile+2] ; je ji‘ za‡ tek souboru ?
         jne       down1                    ; nen¡ za‡ tek souboru
         call      readnxt
         jc        down4
;         cmp       al,"@"
;         jne       down1
;         call      down1                    ; nalezen¡ konce © dku
down1:   call      readnxt                  ; na‡ten¡ dal¨¡ho znaku ze souboru
         jc        down4                    ; konec souboru - n vrat © dku
down2:   cmp       al,10                    ; je LF ?
         jne       down1                    ; nen¡ LF - dal¨¡ znak
;         call      readnxt                  ; na‡ten¡ dal¨¡ho znaku
;         jc        down33
;         cmp       al,"@"
;         je        down1                    ; p©esko‡en¡ © dku
;         call      readpre                  ; n vrat znaku
down33:  clc
down3:   ret
                                          ;* posledn¡ © dek - jeho n vrat
down4:   call      readpre                  ; na‡ten¡ p©edchoz¡ho znaku
         jc        down5                    ; nen¡ dal¨¡ znak
         cmp       al,10                    ; je znak LF ?
         jne       down4                    ; nen¡ je¨tˆ LF - dal¨¡ znak
         call      readnxt                  ; n vrat - na‡ten¡ dal¨¡ho znaku
down5:   stc                                ; p©¡znak - operace se neprovedla
         ret


int09:                                    ;* obsluha INT 09h

         push      ax
         push      bx
         push      ds
         mov       bx,40h                   ; datov˜ segment BIOS
         mov       ds,bx                    ; DS <- datov˜ segment BIOS
         mov       bx,ds:[1ch]              ; £schova ukazatele znak–
         pushf
         call      dword ptr cs:[old09]     ; vol n¡ p–vodn¡ obsluhy INT 09h
         cmp       ds:[1ch],bx              ; byl p©ijat znak ?
         je        int092                   ; nebyl p©ijat znak
                                          ;* kontrola, zda je rezerva 1 znak
         push      bx
         mov       bx,ds:[1ch]              ; nov  ukl dac¡ adresa
         call      int09ins                 ; zv˜¨en¡ ukl dac¡ adresy
         pop       bx                       ; n vrat p–vodn¡ho ukazatele
         jne       int092                   ; nebude p©esycen¡
         mov       ds:[1ch],bx              ; p©esycen¡, zru¨en¡ znaku v bufferu
int092:  pop       ds
         pop       bx
         pop       ax
         iret

int09ins:                                 ;* zv˜¨en¡ ukl dac¡ adresy BX
                                            ; VSTUP: ZY=bude p©esycen¡

         add       bx,2                     ; zv˜¨en¡ ukl dac¡ adresy
         cmp       bx,3eh                   ; je p©ekro‡en¡ konce bufferu ?
         jb        int09in2                 ; nen¡ je¨tˆ p©ekro‡en konec bufferu
         sub       bx,20h                   ; p©esun ukazatele na za‡ tek
int09in2:cmp       bx,ds:[1ah]              ; bude ji‘ p©esycen¡ ?
         ret

konec    label     near                     ; konec programu
; -------------------------- buffery ------------------------------------------
         EVEN                               ; zarovn n¡ na sudou adresu
buff     label     byte                     ; buffer pro pr ci se souborem

code     ENDS
         END       start

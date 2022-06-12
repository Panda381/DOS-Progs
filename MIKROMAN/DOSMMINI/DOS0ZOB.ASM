
; modul DOSMZOB.ASM - zobrazen¡

; *****************************************************************************
;
;                          Zobrazen¡ soubor–
;
; *****************************************************************************

code     segment   public
         assume    cs:code,ds:code


extrn    zobrchyb:near,getkurz:near,outbuf:byte,dekfile:near,segend:word
extrn    topseg:word,editmax:word,windret:near,outhelp:near,aktdir:near
extrn    getkurz:near,erroper:byte,outch10:near,inpid:word,editnum:word
extrn    erredi2:byte,inpkey:near,outch1:near,outch:near
extrn    zobbuf:dword,zobukaz:dword,zobnum:dword,zobbuf:dword
extrn    parint:byte,skokax:near,edikey:word,testkey:near,ediroll:near
extrn    testakth:near,getakt:near,outtxt:near,blokuk:dword
extrn    poziceuk:byte,delkauk:byte,txthlpzo:byte,flags:byte,outthlp:near
extrn    ediflag:byte,outhexw:near,outhexb:near,kurzout:near
extrn    deknum:near,texthlpb:byte,setkonc:near,transtxt:near
extrn    highcase:near,volbyh:near,erredi4:byte,txtchyb1:byte
extrn    findstr:word,txtedi7:byte,bufhlde:byte,lensi:near
extrn    bufhlde2:byte,select:near,erredi3:byte
extrn    testbreak:near,msgcek:near,inpkeyf:near,zobmid:word
extrn    config:byte,parbreak:byte,zobseg:byte,zobadrs:word
extrn    testaktw:near,tabhlzob:word,getpocl:near,endpoz:word
extrn    mousepoz:word,mouseget:near,mousemen:near,modihlp:near
extrn    edikey:word,mouseon:near,mouseoff:near,egaset:near
extrn    toppoz:word,getdispcx:near,createseg:near,delseg:near
extrn    windretx:near,getssize:near,firstrad:word,getseg:near
extrn    maxsize:near,outch0:near,tabhlfnd:word

public   zobraz

zobraz:                                   ;* zobrazen¡ souboru

                                          ;* test opr vnˆnosti po‘adavku
         call      testaktw
         jnc       zobraz0
zobraz01:ret                                ; okno nen¡ zapnuto
zobraz0: call      getkurz                  ; soubor s kurzorem
         jc        zobraz01                 ; neni zadny soubor
         test      byte ptr ds:[si],10h     ; je to adres © ?
         jnz       zobraz01                 ; je to podadres © - neprovede se

                                          ;* dek¢dov n¡ jm‚na souboru
         mov       di,offset outbuf         ; pomocn˜ buffer
         mov       dx,di
         call      dekfile                  ; dek¢dov n¡ jm‚na souboru
         push      cs
         pop       ds                       ; DS <- CS

                                          ;* p©idˆlen¡ bloku pamˆti
         call      createseg                ; vytvo©en¡ bloku pamˆti
         jc        zobraz01                 ; chyba
         mov       ds:[zobseg],al           ; £schova ‡¡sla segmentu
         call      getseg                   ; poskytnut¡ velikosti semgentu
         mov       ds:[zobadrs],bx          ; £schova adresy segmentu
         call      maxsize                  ; nastaven¡ maxim ln¡ velikosti seg.
         and       bx,0fff0h                ; zaokrouhlen¡ na odstavec
         mov       ds:[editmax],bx          ; maxim ln¡ velikost bufferu
         shr       bx,1
         mov       ds:[zobmid],bx           ; polovina bufferu
         jz        zobraza                  ; chyba

                                          ;* otev©en¡ souboru
         call      msgcek                   ; zobrazen¡ hl ¨en¡ "‡ekejte"
         mov       si,ds:[bp+4]             ; adresa cesty k adres ©i
         call      aktdir                   ; nastaven¡ aktivn¡ho adres ©e
         jc        zobraza                  ; chyba operace
         mov       ax,3d00h                 ; otev©en¡ souboru pro ‡ten¡
         int       21h                      ; otev©en¡ souboru
         jc        zobraza                  ; chyba operace
         mov       ds:[inpid],ax            ; identifik tor souboru
         mov       bx,ax                    ; identifik tor souboru

                                          ;* zah jen¡ prohl¡‘en¡ souboru
         call      home                     ; skok na za‡ tek souboru
         mov       ds:[firstrad],si         ; adresa za‡ tku str nky v bufferu

ctib:                                     ;* cyklus obsluhy jedn‚ kl vesy
ctic:    call      zobrall                  ; zobrazen¡ displeje
ctid:    call      kurzout                  ; vypnut¡ kurzoru
         mov       si,offset tabhlfnd
         call      inpkeyf                  ; vstup znaku z kl vesnice
         cmp       al,27                    ; je konec ESC ?
         je        zobraz9                  ; je konec ESC
         or        al,al                    ; je to ©¡dic¡ kl vesa ?
         jnz       ctid                     ; nen¡ to ©¡dic¡ kl vesa - dal¨¡
         mov       al,ah                    ; k¢d ©¡dic¡ kl vesy
         sub       al,47h                   ; ode‡ten¡ offsetu ©¡dic¡ch kl ves
         jb        ctid                     ; nespr vn  kl vesa - znovu
         cmp       al,10
         ja        ctid                     ; nespr vn  kl vesa - znovu
         cbw
         mov       bx,ax                    ; k¢d kl vesy
         add       bx,bx                    ; k¢d kl vesy * 2
         mov       si,ds:[firstrad]         ; adresa za‡ tku zobrazen‚ str nky
         call      word ptr ds:[bx+tabskok] ; vyvol n¡ obsluhy funkce
         mov       ds:[firstrad],si         ; nov  adresa v bufferu
         jmp       short ctic               ; nov‚ zobrazen¡ displeje

                                          ;* uzav©en¡ souboru
zobraz9: mov       bx,cs:[inpid]            ; identifik tor souboru
         mov       ah,3eh                   ; funkce uzav©en¡ souboru
         int       21h                      ; uzav©en¡ souboru

zobraza:                                  ;* uzav©en¡ buffer–
         push      cs
         pop       ds
         mov       al,ds:[zobseg]
         call      delseg                   ; uvolnˆn¡ segmentu pamˆti
         call      windretx                 ; n vrat zobrazen¡ oken
         ret
; -----------------------------------------------------------------------------
public   zobrall
zobrall:                                  ;* zobrazen¡ str nky displeje

                                          ;* inicializace konce © dku
         mov       al,1
         call      outch1                   ; nastaven¡ barvy zobrazen¡
         xor       ax,ax
         mov       ax,ds:[toppoz]           ; po‡ te‡n¡ pozice © dku
         add       ax,80                    ; v˜po‡et konce © dku
         mov       ds:[endpoz],ax           ; pozice zobrazen¡ konce © dku
         xor       dx,dx                    ; DH <- 0 ukazatel © dku textu
         call      getdispcx                ; ‡¡slo posledn¡ho © dku
         inc       cx                       ; po‡et © dk– displeje
zobrall4:
         call      zobrline                 ; zobrazen¡ jednoho © dku
         inc       dh                       ; zv˜¨en¡ ‡¡ta‡e © dk–
         loop      zobrall4                 ; nebyl je¨tˆ posledn¡ © dek
zobrall6:
         ret

; -----------------------------------------------------------------------------
zobrline:                                 ;* zobrazen¡ © dku textu (DH=© dek)


         push      cx
         xor       bx,bx                    ; ukazatel pozice na © dku
         xor       dl,dl                    ; po‡ te‡n¡ pozice pro zobrazen¡
                                          ;* zobrazen¡ jednoho znaku na © dku
zobrlin2:call      readnxt                  ; na‡ten¡ dal¨¡ho znaku ze souboru
         jc        zobrlin6                 ; nen¡ dal¨¡ znak v souboru
         cmp       al,13                    ; je CR ?
         je        zobrlin2                 ; je CR - ignorov n¡
         cmp       al,10                    ; je LF ?
         je        zobrlin6                 ; je LF - konec © dku
         or        bh,bh                    ; je p©ekro‡eno 256 znak– ?
         jnz       zobrlin6                 ; p©ekro‡en konec © dku - konec
         mov       cx,1                     ; 1 znak k zobrazen¡
         cmp       al,9                     ; je tabel tor ?
         jne       zobrlin3                 ; nen¡ tabel tor - je bˆ‘n˜ znak
                                          ;* zobrazen¡ tabel toru
         mov       ax,bx                    ; ukazatel pozice na © dku
         and       ax,7                     ; maska
         mov       cx,8                     ; po‡et pozice tabel toru
         sub       cx,ax                    ; po‡et mezer k zobrazen¡
         mov       al," "
zobrlin3:call      zobrch                   ; zobrazen¡ znaku
         jmp       short zobrlin2           ; zobrazen¡ dal¨¡ho znaku

zobrlin5:                                 ;* vymaz n¡ zbytku © dku
         mov       cx,1
         mov       al," "
         call      zobrch                   ; zobrazen¡ znaku
zobrlin6:cmp       bx,ds:[endpoz]          ; je ji‘ konec © dku ?
         jb        zobrlin5                 ; zobrazen¡ dal¨¡ho znaku
         pop       cx
         ret
; -----------------------------------------------------------------------------
zobrch:                                   ;* zobrazen¡ znaku
         cmp       bx,ds:[toppoz]           ; je pod po‡ te‡n¡ pozic¡ ?
         jb        zobrch2                  ; je pod po‡ te‡n¡ pozic¡
         cmp       bx,ds:[endpoz]           ; je nad koncovou pozic¡ ?
         jae       zobrch2                  ; je nad koncovou pozic¡
         call      outch0                   ; zobrazen¡ znaku
zobrch2: add       bx,cx                    ; zv˜¨en¡ pozice na © dku
         ret
; -----------------------------------------------------------------------------
public   readnxt
readnxt:                                  ;* na‡ten¡ dal¨¡ho znaku z bufferu
         cmp       si,ds:[editnum]          ; adresa konce dat v bufferu souboru
         jb        readnxt2                 ; nen¡ je¨tˆ konec dat
         cmp       si,ds:[editmax]          ; je konec bufferu ?
         jb        readnxt3                 ; nen¡ konec bufferu - konec souboru

                                          ;* na‡ten¡ dal¨¡ho bloku dat
         push      cx                       ; £schova CX
         push      dx                       ; £schova DX
         push      di                       ; £schova DI
         push      ds                       ; £schova DS
         push      es                       ; £schova ES
         xor       di,di                    ; adresa za‡ tku bufferu
         mov       cx,ds:[zobmid]           ; adresa poloviny bufferu
         mov       si,cx                    ; velikost poloviny bufferu
         push      cx
         sub       ds:[firstrad],cx         ; nov  adresa za‡ tku bufferu
         add       word ptr ds:[zobbuf],cx  ; zv˜¨en¡ ukazatele v souboru
         adc       word ptr ds:[zobbuf+2],0 ; p©enos do vy¨¨¡ho slova
         add       word ptr ds:[zobbuf],cx  ; zv˜¨en¡ ukazatele v souboru
         adc       word ptr ds:[zobbuf+2],0 ; p©enos do vy¨¨¡ho slova
         mov       es,ds:[zobadrs]          ; segment bufferu
         mov       ds,ds:[zobadrs]
         cld
         shr       cx,1                     ; d‚lka poloviny bufferu ve slovech
         rep       movsw                    ; p©esun dat do prvn¡ poloviny buff.
         mov       si,di                    ; adresa poloviny bufferu
         pop       cx                       ; velikost poloviny bufferu
         mov       dx,cx                    ; adresa poloviny bufferu
         pop       es                       ; n vrat ES
         pop       ds
         call      readfile                 ; na‡ten¡ bloku dat ze souboru
         sub       word ptr ds:[zobbuf],cx  ; n vrat ukazatele souboru
         sbb       word ptr ds:[zobbuf+2],0 ; p©enos do vy¨¨¡ho slova
         pop       di                       ; n vrat DI
         pop       dx                       ; n vrat DX
         pop       cx                       ; n vrat CX
         jmp       short readnxt            ; na‡ten¡ dal¨¡ho znaku

readnxt2:
         push      ds
         mov       ds,ds:[zobadrs]
         lodsb                              ; na‡ten¡ znaku z bufferu
         pop       ds
         clc
readnxt3:ret

; -----------------------------------------------------------------------------
public   readpre
readpre:                                  ;* na‡ten¡ p©edchoz¡ho znaku ze soub.
         or        si,si
         jnz       readpre2                 ; nen¡ je¨tˆ za‡ tek bufferu

                                          ;* je to ji‘ za‡ tek souboru ?
         mov       ax,word ptr ds:[zobbuf] ; ukazatel souboru - ni‘¨¡ slovo
         or        ax,word ptr ds:[zobbuf+2] ; je ji‘ za‡ tek souboru ?
         stc                                ; p©¡znak chyby
         jz        readpre3                 ; je ji‘ za‡ tek souboru - chyba

                                          ;* na‡ten¡ dal¨¡ho bloku dat
         push      cx                       ; £schova CX
         push      dx                       ; £schova DX
         push      ds
         push      es
         xor       si,si                    ; za‡ tek bufferu
         mov       cx,ds:[zobmid]           ; polovina bufferu
         mov       di,cx                    ; polovina bufferu
         push      cx                       ; po‡et bajt– ke ‡ten¡
         add       ds:[firstrad],cx         ; adresa za‡ tku zobrazen¡ v buff.
         sub       word ptr ds:[zobbuf],cx  ; sn¡‘en¡ ukazatele v souboru
         sbb       word ptr ds:[zobbuf+2],0 ; p©enos do vy¨¨¡ho slova ukazatele
         mov       es,ds:[zobadrs]          ; segment bufferu
         mov       ds,ds:[zobadrs]
         cld                                ; smˆr nahoru
         shr       cx,1                     ; po‡et slov poloviny bufferu
         rep       movsw                    ; p©esun do druh‚ poloviny bufferu
         xor       dx,dx                    ; adresa za‡ tku bufferu
         pop       cx                       ; po‡et bajt– k na‡ten¡
         pop       es
         pop       ds
         call      readfile                 ; na‡ten¡ dal¨¡ho bloku dat ze soub.
         pop       dx                       ; n vrat DX
         pop       cx                       ; n vrat CX
readpre2:                                 ;* na‡ten¡ znaku z bufferu
         dec       si                       ; sn¡‘en¡ ukazatelele v bufferu
         push      ds
         mov       ds,ds:[zobadrs]
         mov       al,ds:[si]               ; znak z bufferu
         pop       ds
         clc                                ; p©¡znak - platn˜ znak
readpre3:ret

; -----------------------------------------------------------------------------
readfile:                                 ;* na‡ten¡ CX bajt– na adresu DX

         push      ax                       ; £schova AX
         push      bx                       ; £schova BX
                                          ;* nastaven¡ ukazatele v souboru
         push      cx                       ; £schova CX
         push      dx                       ; £schova DX
         mov       dx,word ptr ds:[zobbuf]  ; adresa v souboru - ni‘¨¡ slovo
         mov       cx,word ptr ds:[zobbuf+2]; adresa v souboru - vy¨¨¡ slovo
         mov       bx,ds:[inpid]            ; identifik tor souboru
         xor       ax,ax                    ; podslu‘ba - ukazatel od za‡ tku
         mov       ah,42h
         int       21h                      ; nastaven¡ ukazatele souboru
         pop       dx                       ; n vrat DX (adresa bufferu)
         pop       cx                       ; n vrat CX (po‡et bajt–)

         mov       ax,ds:[editmax]          ; velikost bufferu
         mov       ds:[editnum],ax          ; adresa konce bufferu - pln˜

         push      ds
         mov       ds,ds:[zobadrs]          ; adresa segmentu prohl¡‘e‡e
         mov       ah,3fh
         int       21h                      ; na‡ten¡ dat ze souboru
         pop       ds
         jnc       readfil2                 ; ‡ten¡ dat OK
         xor       ax,ax                    ; chyba ‡ten¡ - po‡et bajt– = 0
readfil2:cmp       ax,cx                    ; souhlas¡ po‡et bajt– ?
         je        readfil3                 ; po‡et bajt– souhlas¡ OK
         add       ax,dx                    ; adresa konce bufferu
         mov       ds:[editnum],ax          ; adresa konce dat v bufferu
readfil3:pop       bx                       ; n vrat BX
         pop       ax                       ; n vrat AX
         ret
; -----------------------------------------------------------------------------
tabskok  label     word                   ;* tabulka skok– do obsluh kl ves
         dw        offset home              ; 47h Home
         dw        offset up                ; 48h nahoru
         dw        offset pageup            ; 49h PageUp
         dw        offset nokey             ; 4ah [-]
         dw        offset left              ; 4bh vlevo
         dw        offset nokey             ; 4ch [5]
         dw        offset right             ; 4dh vpravo
         dw        offset nokey             ; 4eh [+]
         dw        offset end               ; 4fh End
         dw        offset down              ; 50h dol–
         dw        offset pagedown          ; 51h PageDown

nokey:                                    ;* neobslou‘en  kl vesa
         ret
; -----------------------------------------------------------------------------
home:                                     ;* skok na za‡ tek souboru

         xor       bx,bx                    ; BX <- 0
;         mov       ax,word ptr ds:[zobbuf]  ; ukazatel v souboru - ni‘¨¡ slovo
;         or        ax,word ptr ds:[zobbuf+2]; ukazatel v souboru - vy¨¨¡ slovo
         mov       word ptr ds:[zobbuf],bx  ; ukazatel v souboru - ni‘¨¡ slovo
         mov       word ptr ds:[zobbuf+2],bx; ukazatel v souboru - vy¨¨¡ slovo
         mov       ds:[toppoz],bx           ; offset za‡ tku © dku
;         jz        home1                    ; je ji‘ za‡ tek souboru
                                          ;* na‡ten¡ dal¨¡ho bloku dat
         xor       dx,dx                    ; za‡ tek bufferu
         mov       cx,ds:[editmax]          ; d‚lka bufferu
         call      readfile                 ; na‡ten¡ cel‚ho bufferu
home1:   xor       si,si                    ; po‡ te‡n¡ ukazatel
         ret
; -----------------------------------------------------------------------------
up:                                       ;* kurzor nahoru UP
         push      cx
         call      readpre                  ; na‡ten¡ p©edchoz¡ho znaku (CR)
         jc        up3                      ; nen¡ dal¨¡ znak - je ji‘ za‡ tek
         mov       cx,256
up1:     call      readpre                  ; na‡ten¡ p©edchoz¡ho znaku
         jc        up2                      ; nen¡ dal¨¡ znak
         cmp       al,10                    ; je znak LF ?
         loopne    up1                      ; nen¡ je¨tˆ LF - dal¨¡ znak
         jcxz      up2
         call      readnxt                  ; n vrat - na‡ten¡ dal¨¡ho znaku
up2:     clc                                ; p©¡znak - operace se provedla
up3:     pop       cx
         ret
; -----------------------------------------------------------------------------
pageup:                                   ;* str nka nahoru PageUp
         call      getdispcx                ; po‡et © dk– - 1
pageup1: call      up                       ; posun o © dek nahoru
         jc        pageup2                  ; nen¡ dal¨¡ © dek
         loop      pageup1                  ; dal¨¡ © dek
pageup2: ret
; -----------------------------------------------------------------------------
left:                                     ;* kurzor vlevo
         cmp       word ptr ds:[toppoz],8  ; je ji‘ za‡ tek © dku ?
         jb        left2                    ; je ji‘ za‡ tek © dku
         sub       word ptr ds:[toppoz],8  ; sn¡‘en¡ offsetu za‡ tku © dku
left2:   ret
; -----------------------------------------------------------------------------
right:                                    ;* kurzor vpravo
         add       word ptr ds:[toppoz],8  ; zv˜¨en¡ offsetu za‡ tku © dku
         ret
; -----------------------------------------------------------------------------
end:                                      ;* konec souboru END
end1:    call      down                     ; posun o © dek dol–
         jnc       end1                     ; posun o dal¨¡ © dek
         mov       word ptr ds:[toppoz],0  ; offset za‡ tku © dku
         ret
; -----------------------------------------------------------------------------
down:                                     ;* kurzor dol– DOWN
         push      cx
         mov       cx,256                   ; maxim ln¡ po‡et znak– na © dek
down1:   call      readnxt                  ; na‡ten¡ dal¨¡ho znaku ze souboru
         jc        down4                    ; konec souboru - n vrat © dku
         cmp       al,10                    ; je LF ?
         loopne    down1                    ; nen¡ LF - dal¨¡ znak
down3:   clc
         pop       cx
         ret
                                          ;* posledn¡ © dek - jeho n vrat
         mov       cx,256
down4:   call      readpre                  ; na‡ten¡ p©edchoz¡ho znaku
         jc        down5                    ; nen¡ dal¨¡ znak
         cmp       al,10                    ; je znak LF ?
         loopne    down4                    ; nen¡ je¨tˆ LF - dal¨¡ znak
         call      readnxt                  ; n vrat - na‡ten¡ dal¨¡ho znaku
down5:   stc                                ; p©¡znak - operace se neprovedla
         pop       cx
         ret
; -----------------------------------------------------------------------------
pagedown:                                 ;* str nka dol– PageDown
         call      getdispcx                ; po‡et © dk– - 1
pagedn1: call      down                     ; posun o © dek dol–
         jc        pagedn2                  ; nen¡ ji‘ dal¨¡ © dek
         loop      pagedn1                  ; dal¨¡ © dek dol–
pagedn2: ret
; -----------------------------------------------------------------------------

code     ENDS
         END

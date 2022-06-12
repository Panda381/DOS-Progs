
; modul DOSMINT.ASM - obsluhy p©eru¨en¡

extrn    old09:dword,old10:dword,parint:byte,old08:dword,citmouse:byte
extrn    citachod:byte,citacexp:byte,color:byte,aktpage:byte,parbreak:word
extrn    buffail:byte,txtfail:byte,txtfai0:byte,txtfai2:byte,txtfai4:byte
extrn    txtfai7:byte,txtfai8:byte,txtfaid:byte,txtfaifa:byte,txtfaidi:byte
extrn    txtfaic:byte,txtfaic2:byte,volbfail:byte,verze:word,windret:near
extrn    transtxt:near,deknum:near,volbyh:near,flushkey:near,edikey:word
extrn    old21:dword,edikeym:word,outch1:near,testalt:near,parrez:byte
extrn    txtfai6:byte,txtfai9:byte,dark:word,darkcit:word,vyzvycom:byte
extrn    vyzvacit:byte,parint2:byte,oldstack:dword,txtfai1:byte
extrn    cittout:byte,parint25:byte

; *****************************************************************************
;
;                          Obsluhy p©eru¨en¡
;
; *****************************************************************************
code     segment   public
         assume    cs:code,ds:code

public   int09

int09:

         push      ax
         push      bx
         push      ds
         mov       ax,cs:[dark]             ; konstanta pro stm¡va‡
         mov       cs:[darkcit],ax          ; nastaven¡ ‡¡ta‡e pro stm¡v n¡
         in        al,[60h]                 ; p©ipraven  kl vesa
         mov       ah,al                    ; £schova kl vesy
         mov       bx,40h                   ; datov˜ segment BIOS
         mov       ds,bx                    ; DS <- datov˜ segment BIOS
         mov       bx,ds:[1ch]              ; £schova ukazatele znak–
         cmp       ah,1                     ; je kl vesa ESC ?
         jne       int091                   ; nen¡ kl vesa ESC
         mov       ds:[1ah],bx              ; vynulov n¡ bufferu kl vesnice
         mov       word ptr cs:[edikey],0   ; zru¨en¡ znaku v bufferu
int091:  pushf
         call      dword ptr cs:[old09]     ; vol n¡ p–vodn¡ obsluhy INT 09h
         cmp       ds:[1ch],bx              ; byl p©ijat znak ?
         jne       int094                   ; byl p©ijat znak
                                          ;* nebyl p©ijat znak - test INSERT
         xor       al,al
         cmp       ah,52h                   ; je kl vesa INSERT ?
         jne       int092                   ; nen¡ kl vesa INSERT
         call      testalt                  ; je kl vesa Alt- stisknuta ?
         jnz       int092                   ; kl vesa Alt- je stisknuta
                                          ;* vlo‘en¡ znaku INSERT
         mov       ds:[bx],ax               ; ulo‘en¡ k¢du kl vesy INSERT
         push      bx
         call      int09ins                 ; zv˜¨en¡ ukl dac¡ adresy
         jz        int093                   ; bude p©esycen¡
         mov       ds:[1ch],bx              ; nastaven¡ nov‚ adresy
int093:  pop       bx

int094:                                   ;* kontrola, zda je rezerva 1 znak
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

; -----------------------------------------------------------------------------
public   int10

int10:                                    ;* monitorov n¡ obsluhy INT 10h

;         jmp       dword ptr cs:[old10]

         or        byte ptr cs:[parint],2   ; p©¡znak obsluhy INT 10h

         push      bp
         push      si
         push      di
         push      ds
         push      es

         pushf
         call      dword ptr cs:[old10]     ; p–vodn¡ obsluha INT 10h

         pop       es
         pop       ds
         pop       di
         pop       si

         mov       bp,sp

         push      ax                       ; £schova AX
         pushf                              ; navr cen˜ registr p©¡znak–
         pop       ax
         and       word ptr [bp+6],300h     ; zru¨en¡ p©¡znak– kromˆ IF a TF
         and       ax,not 300h              ; zru¨en¡ p©¡znak– IF a TF
         or        [bp+6],ax                ; nastaven¡ nov˜ch p©¡znak–
         cmp       word ptr cs:[parbreak],0 ; byla diskov  chyba ?
         je        int102                   ; nebyla diskov  chyba
         or        word ptr [bp+6],1        ; p©¡znak chyby CF
int102:  pop       ax                       ; navrat AX

         and       byte ptr cs:[parint],not 2 ; zru¨en¡ p©¡znaku obsluhy INT 10h

         pop       bp
         iret

; -----------------------------------------------------------------------------

public   int08

int08:                                    ;* obsluha p©eru¨en¡ INT 08H

         or        byte ptr cs:[parint],1   ; p©¡znak obsluhy INT 10h
         call      vyzvaint                 ; obsluha p©eru¨en¡ pro v˜zvu
         pushf
         call      dword ptr cs:[old08]     ; standardn¡ obsluha INT 8
                                          ;* ‡¡t n¡ stm¡v n¡
         cmp       word ptr cs:[darkcit],0  ; je ‡¡ta‡ stm¡v n¡ ji‘ 0 ?
         je        int08d1                  ; ‡¡ta‡ je ji‘ 0
         dec       word ptr cs:[darkcit]    ; sn¡‘en¡ ‡¡ta‡e stm¡va‡e
int08d1:                                  ;* ‡¡t n¡ my¨i
         cmp       byte ptr cs:[citmouse],0 ; je ji‘ ‡¡ta‡ my¨i na 0 ?
         je        int08m1                  ; ‡¡ta‡ my¨i je ji‘ na 0
         dec       byte ptr cs:[citmouse]   ; sn¡‘en¡ ‡¡ta‡e my¨i
int08m1:
         cmp       byte ptr cs:[citacexp],0
         je        int08m2
         dec       byte ptr cs:[citacexp]   ; ‡¡t n¡ exploze
int08m2:
         cmp       byte ptr cs:[cittout],0
         je        int08m3
         dec       byte ptr cs:[cittout]    ; ‡¡t n¡ doby pro TIME-OUT
int08m3:
         cmp       byte ptr cs:[citachod],0 ; ‡ek  se ji‘ na obsluhu ?
         je        int081                   ; ‡ek  se na obsluhu zobrazen¡ hodin
         dec       byte ptr cs:[citachod]   ; sn¡‘en¡ ‡¡ta‡e hodin
         jnz       int082                   ; nepo‘aduje se je¨tˆ obsluha
int081:  test      byte ptr cs:[parint],30h ; je editace F4 nebo F3 ?
         jnz       int089                   ; je editace F4 nebo F3
         test      byte ptr cs:[parint2],2  ; je n povˆda ?
         jnz       int089                   ; je n povˆda
         test      byte ptr cs:[parint],80h ; povoleno zobrazen¡ ‡asu ?
         jz        int082                   ; zobrazen¡ ‡asu nen¡ povoleno
         test      byte ptr cs:[ParInt2],8  ; prob¡h  komunikace COM ?
         jnz       int082                   ; prob¡h  komunikace - z kaz obsluhy
         test      byte ptr cs:[parint],10h ; je zobrazen¡ F3 ?
         jnz       int082                   ; je zobrazen¡ F3
int089:  test      byte ptr cs:[parint],42h ; je povolena obsluha p©eru¨en¡ ?
         jz        int083                   ; obsluha je povolena
int082:  jmp       int084
int083:  or        byte ptr cs:[parint],40h ; p©¡znak - prob¡h  zobrazen¡ ‡asu
                                          ;* zobraz¡ se ‡as
;         sti                                ; povolen¡ p©eru¨en¡
         push      ds
         push      es
         push      bp
         push      si
         push      di
         push      dx
         push      cx
         push      bx
         push      ax
         push      cs
         pop       ds                       ; DS <- CS
         push      cs
         pop       es                       ; ES <- CS
                                          ;* £schova nastaven¡ displeje
         push      word ptr ds:[color]      ; £schova barvy zobrazen¡
;         mov       ah,3
;         mov       bh,ds:[aktpage]          ; pracovn¡ videostr nka
;         int       10h                      ; poskytnut¡ pozice kurzoru
;         push      dx                       ; £schova pozice kurzoru
                                          ;* nastaven¡ displeje pro v˜stup
         mov       al,3
         call      outch1                   ; nastaven¡ barvy textu

         push      ds
         xor       ax,ax
         mov       ds,ax                    ; DS <- 0
         mov       ax,ds:[046ch]            ; ‡ten¡ ni‘¨¡ ‡ sti ‡¡ta‡e ‡asu
         mov       dx,ds:[046eh]            ; ‡ten¡ vy¨¨¡ ‡ sti ‡¡ta‡e ‡asu
         pop       ds

         mov       cl,4                     ; po‡et rotac¡
         shl       dx,cl                    ; vy¨¨¡ slovo * 16
         mov       bx,ax                    ; ni‘¨¡ slovo ‡¡ta‡e ‡asu
         mov       cl,12
         shr       bx,cl                    ; nejvy¨¨¡ 4 bity ni‘¨¡ho slova
         add       dx,bx                    ; p©enos 4 bit– do vy¨¨¡ho slova
         mov       cl,4
         shl       ax,cl                    ; ni‘¨¡ slovo * 16
         mov       bx,17478
         div       bx                       ; ‡¡ta‡ ‡asu / 1092.375
         push      dx                       ; £schova zbytku v minutˆ
         mov       bx,60                    ; po‡et minut v hodinˆ
         xor       dx,dx                    ; DX <- 0, AX=po‡et minut
         div       bx                       ; v˜po‡et hodiny a minuty
         push      dx                       ; £schova minuty
         mov       dx,69                    ; po‡ te‡n¡ pozice textu
         push      ax                       ; £schova hodiny
         test      byte ptr ds:[parint],30h ; prob¡h  editace F4/F3 ?
         jz        int086                   ; neprob¡h  editace F4/F3
         test      byte ptr ds:[parint2],2  ; je n povˆda ?
         jnz       int086                   ; je n povˆda
         inc       dl                       ; zv˜¨en¡ pozice
         inc       dl                       ; zv˜¨en¡ pozice
         jmp       short int085
int086:  mov       al," "
         call      outch1                   ; zobrazen¡ oddˆlovac¡ mezery
int085:  pop       ax                       ; n vrat hodiny
                                          ;* zobrazen¡ £daje hodin
         aam                                ; korekce na BCD k¢d
         add       ax,3030h                 ; korekce na ASCII k¢d
         xchg      ah,al                    ; AL <- des¡tky hodin
         call      outch1                   ; zobrazen¡ des¡tky hodin
         mov       al,ah                    ; jednotky hodin
         call      outch1                   ; zobrazen¡ jednotky hodin
         mov       al,":"                   ; oddˆlovac¡ znak
         call      outch1                   ; zobrazen¡ oddˆlovac¡ho znaku
         pop       ax                       ; n vrat minut
                                          ;* zobrazen¡ £daje minut
         aam                                ; korekce na BCD k¢d
         add       ax,3030h                 ; korekce na BCD k¢d
         xchg      ah,al                    ; AL <- des¡tky minut
         call      outch1                   ; zobrazen¡ des¡tek minut
         mov       al,ah                    ; jednotky minut
         call      outch1                   ; zobrazen¡ jednotek minut
         mov       al,":"                   ; oddˆlovac¡ znak
         call      outch1                   ; zobrazen¡ oddˆlovac¡ho znaku
         pop       ax                       ; n vrat zbytku do 1 minuty
                                          ;* zobrazen¡ £daje sekund
         push      dx                       ; £schova pozice textu
;         xor       dx,dx                    ; DX <- 0
         mov       bx,60                    ; po‡et sekund v minutˆ
         mul       bx                       ; v˜po‡et po‡tu sekund a setin
         mov       bx,17478                 ; p©evod na abs. £daj
         div       bx                       ; v˜po‡et po‡tu sekund
                                          ;* v˜po‡et ‡ sti sekundy
         push      ax                       ; £schova po‡tu sekund
         mov       ax,dx                    ; zbytek do 1 sekundy
;         xor       dx,dx                    ; DX <- 0
         mov       bx,18                    ; po‡et impuls– v 1 sekundˆ
         mul       bx                       ; v˜po‡et po‡tu impuls– v sekundˆ
         mov       bx,17478                 ; p©evod na abs. £daj
         div       bx                       ; v˜po‡et po‡tu ‡ sti sekundy
         sub       al,18                    ; -zbytek do sekundy
         neg       al                       ; zbytek do sekundy
         inc       al
         mov       cs:[citachod],al         ; ‡¡ta‡ obsluhy hodin
         pop       ax                       ; n vrat po‡tu sekund

         pop       dx                       ; n vrat pozice textu
         aam                                ; korekce na BCD k¢d
         add       ax,3030h                 ; korekce na ASCII k¢d
         xchg      ah,al
         call      outch1
         mov       al,ah
         call      outch1
         test      byte ptr ds:[parint2],2  ; je n povˆda ?
         jnz       int0881                  ; je n povˆda
         test      byte ptr ds:[parint],30h ; prob¡h  editace F4/F3 ?
         jnz       int088                   ; prob¡h  editace F4/F3
int0881: mov       al," "
         call      outch1
int088:
;         mov       byte ptr cs:[citachod],18 ; ‡¡ta‡ obsluhy hodin
;         pop       dx                       ; p–vodn¡ pozice kurzoru
;         mov       ah,2
;         mov       bh,cs:[aktpage]          ; pracovn¡ videostr nka
;         int       10h                      ; nastaven¡ pozice kurzoru
         pop       word ptr cs:[color]      ; n vrat barvy
         pop       ax
         pop       bx
         pop       cx
         pop       dx
         pop       di
         pop       si
         pop       bp
         pop       es
         pop       ds
         and       byte ptr cs:[parint],not 40h ; zru¨en¡ p©¡znaku zobraz. ‡asu
int084:  and       byte ptr cs:[parint],not 1 ; zru¨en¡ p©¡znaku obsluhy INT 08h
         iret





public   int24

int24:                                    ;* obsluha kritick˜ch chyb
                                            ; VSTUP: DI=k¢d chyby 0 a‘ 0Ch

         cmp       byte ptr cs:[parbreak],0 ; je ji‘ nˆjak  chyba ?
         je        int241                   ; nen¡ je¨tˆ ‘ dn  chyba
int240:  xor       al,al                    ; n vratov˜ k¢d - ignorov n¡ chyby
         iret

int241:  test      byte ptr cs:[parrez],8   ; je ignorov n¡ chyb ?
         jnz       int240                   ; ignorov n¡ chyby
         test      byte ptr cs:[parint],4   ; prob¡h  ji‘ obsluha INT 24h ?
         jnz       int240                   ; prob¡h  ji‘ obsluha INT 24h
         or        byte ptr cs:[parint],4   ; p©¡znak INT 24h
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es
                                          ;* hl ¨en¡ o chybˆ
         push      cs
         pop       ds                       ; DS <- CS
         push      cs
         pop       es                       ; ES <- CS

         mov       dl,ah                    ; typ chyby
         xor       dh,dh
         add       di,13h                   ; k¢d chyby DOS
         call      exterr                   ; roz¨¡©en˜ chybov˜ k¢d
         mov       cx,di                    ; k¢d chyby DOS
         push      cx                       ; k¢d chyby DOS
                                          ;* hl ¨en¡ chyby
         lea       di,[buffail]             ; buffer pro hl ¨en¡ chyby
         lea       si,[txtfail]             ; text "Chyba za©¡zen¡ !'
         call      transtxt                 ; p©enos textu
         lea       si,[txtfai0]             ; hl ¨en¡ - ochrana proti z pisu
         cmp       cx,13h                   ; je chyba 13h ?
         je        int244                   ; je chyba 0
         lea       si,[txtfai1]             ; hl ¨en¡ - neplatn˜ disk
         cmp       cx,14h                   ; je chyba 14h ?
         je        int244                   ; je chyba 0
         lea       si,[txtfai2]             ; hl ¨en¡ - nen¡ vlo‘ena disketa
         cmp       cx,15h
         je        int244
         lea       si,[txtfai4]             ; hl ¨en¡ - vadn˜ sektor
         cmp       cx,17h
         je        int244
         lea       si,[txtfai6]             ; hl ¨en¡ - chyba vystaven¡
         cmp       cx,19h
         je        int244
         lea       si,[txtfai7]             ; hl ¨en¡ - nezn m˜ form t
         cmp       cx,1ah
         je        int244
         lea       si,[txtfai8]             ; hl ¨en¡ - sektor nenalezen
         cmp       cx,1bh
         je        int244
         lea       si,[txtfai9]             ; hl ¨en¡ - nen¡ pap¡r
         cmp       cx,1ch
         je        int244
         lea       si,[txtfaid]             ; hl ¨en¡ - poru¨eno sd¡len¡ soubor–
         cmp       cx,20h
         je        int244
         lea       si,[txtfaifa]            ; hl ¨en¡ - vadn  tabulka FAT disku
         mov       al,dl                    ; typ chyby
         and       al,6
         cmp       al,2                     ; je chyba tabulky FAT ?
         je        int244                   ; je chyba tabulky FAT disku
         lea       si,[txtfaidi]            ; hl ¨en¡ - vadn˜ adres © diskety
         cmp       al,4                     ; je chyba adres ©e ?
         je        int244                   ; je vadn˜ adres © disku
                                          ;* v¨eobecn  chyba
         lea       si,[txtfaic]             ; hl ¨en¡ - nezn m  chyba
         call      transtxt                 ; p©enos textu hl ¨en¡
         push      dx                       ; £schova typu chyby
         mov       ax,cx                    ; k¢d chyby
         xor       dx,dx
         call      deknum                   ; dek¢dov n¡ ‡¡sla chyby
         lea       si,[txtfaic2]
         call      transtxt
         pop       ax                       ; typ chyby
         xor       dx,dx
         call      deknum
         jmp       short int245
int244:  call      transtxt                 ; p©enos textu chyby
int245:  lea       di,[buffail]             ; buffer pro hl ¨en¡ chyby
         lea       si,[volbfail]            ; volby pro chyby
         call      flushkey                 ; vypr zdnˆn¡ kl vesnice
         xor       al,al                    ; p©edvolba
         call      volbyh                   ; proveden¡ voleb
         jc        int248                   ; p©eru¨en¡ operace
         cmp       al,1                     ; p©eru¨en¡ operace ?
         cmc                                ; CY=p©eru¨en¡ nebo ignorov n¡
int248:  pop       cx                       ; k¢d chyby DOS
         mov       bl,1                     ; n vratov˜ k¢d - opakov n¡
         jnc       int249                   ; je opakov n¡
         xor       bl,bl                    ; n vratov˜ k¢d - ignorov n¡
         cmp       al,2                     ; je ignorov n¡ ?
         je        int249                   ; je ignorov n¡ chyby
         or        byte ptr cs:[parint25],8 ; p©¡znak p©eru¨en¡ funkce
         mov       word ptr cs:[parbreak],cx ; nastaven¡ k¢du chyby
         cmp       word ptr cs:[verze],3*256+20 ; minim ln¡ verze syst‚mu
         jb        int249                   ; je men¨¡ verze ne‘ 3.20
         mov       bl,3                     ; n vratov˜ k¢d - ohl ¨en¡ chyby
int249:  mov       al,bl                    ; n vratov˜ k¢d
         call      windret                  ; navr cen¡ oken
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         and       byte ptr cs:[parint],not 4; zru¨en¡ p©¡znaku INT 24h
         iret

; -----------------------------------------------------------------------------
public   exterr
exterr:                                   ;* roz¨i©uj¡c¡ chybov‚ informace
                                            ; VSTUP: DI=chybov˜ k¢d
         pushf
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      bp
         push      ds
         push      es
         cmp       word ptr cs:[verze],300h ; je verze OS alespo¤ 3.00 ?
         jb        exterr2                  ; je ni‘¨¡ verze
         xor       bx,bx                    ; BX <- 0
         mov       ah,59h
         int       21h                      ; poskytnut¡ chybov˜ch informac¡
         mov       di,ax                    ; roz¨i©uj¡c¡ chybov˜ k¢d
         clc
exterr2: pop       es
         pop       ds
         pop       bp
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         popf
         ret
; -----------------------------------------------------------------------------

public   int21

int21:                                    ;* obsluha INT 21h

;         test      byte ptr cs:[parint2],4  ; prob¡h  ji‘ obsluha INT 21h ?
;         jnz       int213                   ; prob¡h  ji‘ obsluha INT 21h
;
;
;         push      bp
;         mov       bp,sp
;
;         or        byte ptr cs:[parint2],4  ; p©¡znak obsluhy INT 21h
;         mov       word ptr cs:[oldstack+2],ss ; £schova segmentu z sobn¡ku
;         mov       word ptr cs:[oldstack],sp ; £schova offsetu z sobn¡ku
;
;         pushf
;         call      dword ptr cs:[old21]     ; p–vodn¡ obsluha INT 21h
;
;         mov       ss,word ptr cs:[oldstack+2] ; £schova segmentu z sobn¡ku
;         mov       sp,word ptr cs:[oldstack] ; £schova offsetu z sobn¡ku
;
;         push      ax                       ; £schova AX
;         lahf                               ; AH <- registr p©¡znak– F
;;         pushf                              ; navr cen˜ registr p©¡znak–
;;         pop       ax
;;         and       word ptr [bp+6],300h     ; zru¨en¡ p©¡znak– kromˆ IF a TF
;;         and       ax,not 300h              ; zru¨en¡ p©¡znak– IF a TF
;;         or        [bp+6],ax                ; nastaven¡ nov˜ch p©¡znak–
;         cmp       word ptr cs:[parbreak],0 ; byla diskov  chyba ?
;         je        int212                   ; nebyla diskov  chyba
;         or        ah,1                     ; p©¡znak chyby CY
;;         or        word ptr [bp+6],1        ; p©¡znak chyby CF
;int212:  mov       ss:[bp+6],ah             ; registr p©¡znak–
;         and       byte ptr cs:[parint2],not 4 ; zru¨en¡ p©¡znaku INT 21h
;         pop       ax                       ; navrat AX
;
;         pop       bp
;         iret
;
int213:  jmp       dword ptr cs:[old21]     ; p–vodn¡ obsluha INT 21h

; -----------------------------------------------------------------------------
public   vyzvaint
vyzvaint:                                   ; obsluha p©eru¨en¡ pro v˜zvu

ifdef    upver

         push      ax
         mov       al,cs:[vyzvacit]         ; ‡¡ta‡ sign lu v˜zvy
         or        al,al                    ; je sign l aktivn¡ ?
         jnz       vyzvai2                  ; sign l je aktivn¡

                                          ;* sign l nen¡ - je po‘adov n ?
         test      byte ptr cs:[vyzvycom],40h ; je sign l po‘adov n ?
         jz        vyzvai6                  ; sign l nen¡ po‘adov n
         mov       al,5*18                  ; ‡asov  konstanta ‡¡ta‡e
                                          ;* sign l je aktivn¡ - obsluha
vyzvai2: dec       al                       ; sn¡‘en¡ ‡¡ta‡e v˜zvy
         and       byte ptr cs:[vyzvycom],not 40h ; zru¨en¡ po‘adavku v˜zvy
         mov       cs:[vyzvacit],al         ; ulo‘en¡ nov‚ hodnoty ‡¡ta‡e v˜zvy
         cmp       al,4*18                  ; je doba ticha ?
         jb        vyzvai5                  ; je doba ticha

                                          ;* nastaven¡ t¢nu
         test      al,1                     ; je vy¨¨¡ t¢n ?
         mov       ax,1435                  ; vy¨¨¡ t¢n
         jnz       vyzvai4
         mov       ax,1706                  ; ni‘¨¡ t¢n
vyzvai4: call      sound                    ; nastaven¡ po‘adovan‚ho zvuku
         jmp       short vyzvai6

vyzvai5: call      soundoff                 ; vypnut¡ zvuku
vyzvai6: pop       ax

endif
         ret
; -----------------------------------------------------------------------------

public   sound
sound:                                    ;* nastaven¡ zvukov‚ho gener toru

         push      ax
         push      bx

         mov       bx,ax                    ; po‘adovan  konstanta
         in        al,[61h]
         or        al,3
         out       [61h],al
         mov       al,0b6h
         out       [43h],al
         mov       al,bl
         out       [42h],al
         mov       al,bh
         out       [42h],al

         pop       bx
         pop       ax
         ret
  
; -----------------------------------------------------------------------------

public   soundoff
soundoff:                                 ;* vypnut¡ zvukov‚ho gener toru

         push      ax
         in        al,[61h]
         and       al,not 3
         out       [61h],al
         pop       ax
         ret

; -----------------------------------------------------------------------------

code     ends

         end

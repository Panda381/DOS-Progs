
; modul DOSMINT.ASM - obsluhy p©eru¨en¡

extrn    old09:dword,old10:dword,parint:byte,old08:dword,citmouse:byte
extrn    citachod:byte,citacexp:byte,color:byte,aktpage:byte,parbreak:word
extrn    buffail:byte,txtfail:byte,txtfai0:byte,txtfai2:byte,txtfai4:byte
extrn    txtfai7:byte,txtfai8:byte,txtfaid:byte,txtfaifa:byte,txtfaidi:byte
extrn    txtfaic:byte,txtfaic2:byte,volbfail:byte,verze:word,windret:near
extrn    transtxt:near,deknum:near,volbyh:near,flushkey:near
extrn    old21:dword,edikeym:word,outch1:near,testalt:near,parrez:byte

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
         in        al,[60h]                 ; p©ipraven  kl vesa
         mov       ah,al                    ; £schova kl vesy
         mov       bx,40h                   ; datov˜ segment BIOS
         mov       ds,bx                    ; DS <- datov˜ segment BIOS
         mov       bx,ds:[1ch]              ; £schova ukazatele znak–
         pushf
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

obsl10   proc      far

int10:                                    ;* monitorov n¡ obsluhy INT 10h

         pushf
         or        byte ptr cs:[parint],2   ; p©¡znak obsluhy INT 10h
         popf
         pushf
         call      dword ptr cs:[old10]     ; p–vodn¡ obsluha INT 10h
         pushf
         and       byte ptr cs:[parint],not 2 ; zru¨en¡ p©¡znaku obsluhy INT 10h
         popf
         sti
         ret       2

obsl10   endp

; -----------------------------------------------------------------------------
public   int08

int08:                                    ;* obsluha p©eru¨en¡ INT 08H

         or        byte ptr cs:[parint],1   ; p©¡znak obsluhy INT 10h
         pushf
         call      dword ptr cs:[old08]     ; standardn¡ obsluha INT 8
                                          ;* ‡¡t n¡ my¨i
         cmp       byte ptr cs:[citmouse],0 ; je ji‘ ‡¡ta‡ my¨i na 0 ?
         je        int08m1                  ; ‡¡ta‡ my¨i je ji‘ na 0
         dec       byte ptr cs:[citmouse]   ; sn¡‘en¡ ‡¡ta‡e my¨i
;         jnz       int08m1                  ; nen¡ je¨tˆ TIME-OUT
;         mov       word ptr cs:[edikeym],0  ; zru¨en¡ znaku v bufferu my¨i
int08m1: cmp       byte ptr cs:[citacexp],0
         je        int08m2
         dec       byte ptr cs:[citacexp]   ; ‡¡t n¡ exploze
int08m2:
         cmp       byte ptr cs:[citachod],0 ; ‡ek  se ji‘ na obsluhu ?
         je        int081                   ; ‡ek  se na obsluhu zobrazen¡ hodin
         dec       byte ptr cs:[citachod]   ; sn¡‘en¡ ‡¡ta‡e hodin
         jnz       int082                   ; nepo‘aduje se je¨tˆ obsluha
int081:  test      byte ptr cs:[parint],30h ; je editace F4 nebo F3 ?
         jnz       int089                   ; je editace F4 nebo F3
         test      byte ptr cs:[parint],80h ; povoleno zobrazen¡ ‡asu ?
         jz        int082                   ; zobrazen¡ ‡asu nen¡ povoleno
         test      byte ptr cs:[parint],10h ; je zobrazen¡ F3 ?
         jnz       int082                   ; je zobrazen¡ F3
int089:  test      byte ptr cs:[parint],42h ; je povolena obsluha p©eru¨en¡ ?
         jz        int083                   ; obsluha je povolena
int082:  jmp       int084
int083:  or        byte ptr cs:[parint],40h ; p©¡znak - prob¡h  zobrazen¡ ‡asu
                                          ;* zobraz¡ se ‡as
         sti                                ; povolen¡ p©eru¨en¡
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
         mov       ah,3
         mov       bh,ds:[aktpage]          ; pracovn¡ videostr nka
         int       10h                      ; poskytnut¡ pozice kurzoru
         push      dx                       ; £schova pozice kurzoru
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
         shl       dx,cl                    ; DX * 4
         mov       bx,ax
         mov       cl,12
         shr       bx,cl
         add       dx,bx
         mov       cl,4
         shl       ax,cl
         mov       bx,4446h
         div       bx
         push      dx
         mov       bx,3ch
         xor       dx,dx
         div       bx
         push      dx
         mov       dx,69                    ; po‡ te‡n¡ pozice textu
         push      ax
         test      byte ptr ds:[parint],30h ; prob¡h  editace F4/F3 ?
         jz        int086                   ; neprob¡h  editace F4/F3
         inc       dl                       ; zv˜¨en¡ pozice
         inc       dl                       ; zv˜¨en¡ pozice
         jmp       short int085
int086:  mov       al," "
         call      outch1
int085:  pop       ax
                                          ;* zobrazen¡ £daje hodin
         aam
         add       ax,3030h
         xchg      ah,al
         call      outch1
         mov       al,ah
         call      outch1
         mov       al,":"
         call      outch1
         pop       ax
                                          ;* zobrazen¡ £daje minut
         aam
         add       ax,3030h
         xchg      ah,al
         call      outch1
         mov       al,ah
         call      outch1
         mov       al,":"
         call      outch1
         pop       ax
                                          ;* zobrazen¡ £daje sekund
         push      dx                       ; £schova pozice textu
         xor       dx,dx
         mov       bx,3ch
         mul       bx
         mov       bx,4446h
         div       bx
         pop       dx                       ; n vrat pozice textu
         aam
         add       ax,3030h
         xchg      ah,al
         call      outch1
         mov       al,ah
         call      outch1
         test      byte ptr ds:[parint],30h ; prob¡h  editace F4/F3 ?
         jnz       int088                   ; prob¡h  editace F4/F3
         mov       al," "
         call      outch1
int088:
         mov       byte ptr cs:[citachod],18 ; ‡¡ta‡ obsluhy hodin
         pop       dx                       ; p–vodn¡ pozice kurzoru
         mov       ah,2
         mov       bh,cs:[aktpage]          ; pracovn¡ videostr nka
         int       10h                      ; nastaven¡ pozice kurzoru
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
         mov       cx,di                    ; k¢d chyby DOS
         push      cx                       ; k¢d chyby DOS
                                          ;* hl ¨en¡ chyby
         lea       di,[buffail]             ; buffer pro hl ¨en¡ chyby
         lea       si,[txtfail]             ; text "Chyba za©¡zen¡ !'
         call      transtxt                 ; p©enos textu
         lea       si,[txtfai0]             ; hl ¨en¡ - ochrana proti z pisu
         cmp       cx,13h                   ; je chyba 13h ?
         jz        int244                   ; je chyba 0
         lea       si,[txtfai2]             ; hl ¨en¡ - nen¡ vlo‘ena disketa
         cmp       cx,15h
         je        int244
         lea       si,[txtfai4]             ; hl ¨en¡ - vadn˜ sektor
         cmp       cx,17h
         je        int244
         lea       si,[txtfai7]             ; hl ¨en¡ - nezn m˜ form t
         cmp       cx,1ah
         je        int244
         lea       si,[txtfai8]             ; hl ¨en¡ - sektor nenalezen
         cmp       cx,1bh
         je        int244
         lea       si,[txtfaid]             ; hl ¨en¡ - poru¨eno sd¡len¡ soubor–
         cmp       cx,1dh
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

public   int21

obsl21   proc      far

int21:                                    ;* obsluha INT 21h

         pushf
         call      dword ptr cs:[old21]     ; p–vodn¡ obsluha INT 21h

         push      ax                       ; uschova AX
         rcl       al,1                     ; uschova priznaku CF
         cmp       word ptr cs:[parbreak],0 ; byla diskov  chyba ?
         je        int212                   ; nebyla diskov  chyba
;         cmp       word ptr cs:[parbreak],-2 ; je ignorov n¡ chyb ?
;         je        int212
         or        al,1                     ; p©¡znak chyby CF
int212:  rcr       al,1                     ; navrat priznaku CF
         pop       ax                       ; navrat AX

         ret       2

obsl21   endp

; -----------------------------------------------------------------------------

code     ends

         end

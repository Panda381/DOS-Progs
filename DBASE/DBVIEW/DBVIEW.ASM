; -----------------------------------------------------------------------------
;                      Prohl°ëeá datab†zovòch souborñ
; -----------------------------------------------------------------------------
code     SEGMENT
         ASSUME    cs:code,ds:code
         org       100h
dbv:
         call      rozbor                   ; p©°prava povelovÇho ©†dku
         mov       dx,si                    ; adresa jmÇna souboru
         mov       ds:[soubor],si
         call      initfile                 ; inicializace souboru
         jnc       dbv0                     ; otev©en° souboru OK

error:   lea       dx,[errtxt]
         mov       ah,9
         int       21h
         mov       ax,4c01h
         int       21h

dbv0:                                     ;* instalace INT 1bh
         mov       ax,351bh
         int       21h
         mov       word ptr ds:[old1b],bx
         mov       word ptr ds:[old1b+2],es
         lea       dx,[int1b]
         mov       ax,251bh
         int       21h
                                          ;* instalace INT 09h
         mov       ax,3509h
         int       21h
         mov       word ptr ds:[old09],bx
         mov       word ptr ds:[old09+2],es
         lea       dx,[int09]
         mov       ax,2509h
         int       21h

         push      cs
         pop       es

         call      initmod                  ; inicializace programu

         xor       cx,cx
         xor       dx,dx

         call      windret                  ; novÇ zobrazen° celÇho okna

dbv11:   xor       cx,cx
         xor       dx,dx                    ; á°slo z†znamu

dbv1:    call      zobzazn                  ; zobrazen° z†znamu
         call      topline                  ; zobrazen° horn°ho ©†dku

dbv2:    call      kurzout
dbv22:   mov       ah,1
         int       16h
         jz        dbv23
         xor       ah,ah
         int       16h
         jmp       short dbv22

dbv23:   xor       ah,ah
         int       16h
         cmp       al,1bh                   ; je <Esc> ?
         je        dbv26                    ; je <Esc> - konec
         cmp       ah,44h                   ; je F10 ?
         jne       dbv24                    ; je F10
dbv26:   jmp       konec                    ; konec
dbv24:   cmp       ah,51h                   ; Page Down
         jne       end0
         add       dx,1
         adc       cx,0
dbv27:   cmp       cx,word ptr ds:[zaznamu+2]
         jne       dbv25
         cmp       dx,word ptr ds:[zaznamu]
dbv25:   jb        dbv1
         mov       cx,word ptr ds:[zaznamu+2]
         mov       dx,word ptr ds:[zaznamu]
         sub       dx,1
         sbb       cx,0
         jmp       short dbv1

end0:    cmp       ah,4fh                   ; End
         jne       dbv3
         mov       cx,word ptr ds:[zaznamu+2]
         mov       dx,word ptr ds:[zaznamu]
         sub       dx,1
         sbb       cx,0
dbv44:   jmp       short dbv1

dbv3:    cmp       ah,49h                   ; PageUp
         jne       dbv4
         mov       ax,cx
         or        ax,dx
         jz        dbv2                     ; je jië zaá†tek
         sub       dx,1
         sbb       cx,0
         jmp       short dbv44

dbv4:    cmp       ah,47h                   ; Home
         je        dbv11

         cmp       ah,3fh                   ; F5 - GOTO
         jne       dbv5

         push      dx
         call      topclear                 ; vymaz†n° horn°ho ©†dku
         xor       dx,dx
         lea       si,[txtzad]
         call      outtxt                   ; zobrazen° vòzvy
         lea       di,[outbuf]              ; prazovn° buffer
         call      inpnum                   ; vstup á°sla BX:AX
         pop       dx
         jc        dbv44

         sub       ax,1
         sbb       bx,0
         jc        dbv44

         mov       cx,bx
         mov       dx,ax

         jmp       short dbv27

dbv5:    cmp       ah,50h                   ; ®ipka dolñ
         jne       dbv6

         add       byte ptr ds:[offsety],8  ; o 8 ©†dkñ dolñ
         jnc       dbv78
         sub       byte ptr ds:[offsety],8
         jmp       short dbva

dbv6:    cmp       ah,48h                   ; ®ipka nahoru
         jne       dbv7
         cmp       byte ptr ds:[offsety],0
         je        dbva
dbv61:   sub       byte ptr ds:[offsety],8
         jmp       short dbv78

dbv7:    cmp       ah,4dh                   ; ®ipka vpravo
         jne       dbv8
         add       byte ptr ds:[offsetx],8
         jnc       dbv78
         sub       byte ptr ds:[offsetx],8
         jmp       short dbva

dbv78:   call      windret
         jmp       dbv1

dbv8:    cmp       ah,4bh                   ; ®ipka vlevo
         jne       dbva
         sub       byte ptr ds:[offsetx],8
         jnc       dbv78
         add       byte ptr ds:[offsetx],8
dbva:
         jmp       dbv2


konec:
         mov       byte ptr cs:[atrib],7
         xor       dx,dx
         mov       cx,word ptr cs:[pozice]
         add       cx,101h
         call      wclear

         lds       dx,cs:[old1b]
         mov       ax,251bh
         int       21h
         lds       dx,cs:[old09]
         mov       ax,2509h
         int       21h

         mov       ax,4c00h
         int       21h


; -----------------------------------------------------------------------------
;                         Obsluhy poloëek
; -----------------------------------------------------------------------------
zobzazn:                                  ;* zobrazen° celÇho z†znamu
                                            ; VSTUP: CX:DX=á°slo z†znamu

         push      ax
         push      cx
         push      dx
         push      si
         push      di

         call      readzaz                  ; naáten° á°sla z†znamu

         mov       al,10
         call      setatrib
         mov       dx,20eh
         sub       dh,ds:[offsety]

         lea       di,[popis]               ; tabulka popisovaáñ
         mov       si,ds:[adrbuf]           ; adresa z†znamu
zobzazn1:inc       di
         cmp       di,ds:[adrbuf]
         jae       zobzazn2
         dec       di

         push      dx
         push      si
         push      di
         xor       ch,ch
         mov       cl,ds:[di+16]            ; dÇlka poloëky
         push      cx
         cmp       dh,2
         jl        zobzazn4

         cmp       byte ptr ds:[di+11],"D"  ; je datovÇ pole ?
         jne       zobzazn3                 ; nen° datovÇ pole
         cmp       cl,8                     ; je dÇlka = 8 ?
         jne       zobzazn3                 ; nespr†vn† dÇlka
                                          ;* zobrazen° data
         mov       ax,ds:[si+6]             ; den
         call      zobzazn8
         mov       ax,ds:[si+4]             ; màs°c
         call      zobzazn8
         mov       cl,4                     ; dÇlka roku

zobzazn3:
         call      outstxt                  ; zobrazen° poloëky
zobzazn4:pop       cx
         pop       di
         pop       si
         pop       dx
         add       si,cx                    ; nov† adresa
         add       di,32                    ; dal®° popisovaá
         inc       dh
         mov       al,ds:[radek]
         dec       al
         cmp       dh,al
         jl        zobzazn1

zobzazn2:pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

zobzazn8:call      outchs1
         xchg      al,ah
         call      outchs1
         mov       al,"."
         call      outchs1
         ret

; -----------------------------------------------------------------------------
getpopis:                                 ;* poskytnut° adresy popisovaáe
                                            ; VSTUP: AL=á°slo popisovaáe 1...
                                            ; VùSTUP: DS:SI=adresa popisovaáe
                                            ;         CY=chybnÇ á°slo popisovaáe

         push      ax
         lea       si,[zahlavi]             ; z†hlav° souboru
         mov       ah,32                    ; dÇlka jednoho popisovaáe
         mul       ah                       ; offset od zaá†tku z†hlav°
         add       si,ax                    ; adresa popisovaáe
         cmp       byte ptr ds:[si],0dh
         je        getpop2
         inc       si
         cmp       si,ds:[adrbuf]
         je        getpop2
         dec       si
         cmp       si,ds:[adrbuf]           ; p©ekroáen konec popisovaáñ ?
getpop2: cmc
         pop       ax
         ret

; -----------------------------------------------------------------------------
zobpopis:                                 ;* zobrazen° popisovaáe
                                            ; VSTUP: AL=á°slo popisovaáe 1...
                                            ; VùSTUP: CY=neplatnò popisovaá
         push      ax
         push      cx
         push      dx
         push      si
         mov       dh,al
         inc       dh                       ; ©†dek k zobrazen° popisovaáe
         sub       dh,ds:[offsety]
         cmp       dh,2
         jl        zobpop7
         mov       dl,ds:[radek]
         dec       dl
         cmp       dh,dl
         cmc
         jc        zobpop2                  ; popisovaá je mimo displej

         call      getpopis                 ; poskytnut° popisovaáe
         jc        zobpop2

         mov       dl,1
         mov       al,2
         call      setatrib

         call      lensi                    ; zji®tàn° dÇlky textu
         mov       cx,11
         cmp       ax,cx
         push      ax
         jbe       zobpop1
         mov       ax,cx
zobpop1: sub       cx,ax                    ; poáet zbylòch mezer
         mov       al," "
         call      outch                    ; oddàlovac° mezery
         pop       cx
         jcxz      zobpop3
         lodsb
         call      outch1
         dec       cx
         jz        zobpop3
zobpop4: lodsb
         cmp       al,"A"
         jb        zobpop5
         cmp       al,"Z"
         ja        zobpop5
         add       al,32
zobpop5: call      outch1
         loop      zobpop4
zobpop3:
         mov       al,":"
         call      outch1
;         call      outstxt                  ; zobrazen° textu o danÇ dÇlce
zobpop7: clc
zobpop2: pop       si
         pop       dx
         pop       cx
         pop       ax
         ret
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------



; -----------------------------------------------------------------------------
;                           Inicializace
; -----------------------------------------------------------------------------
rozbor:                                   ;* rozbor povelovÇho ©†dku
                                            ; VùSTUP: SI=adresa textu

         mov       si,81h
         xor       cx,cx
         mov       cl,ds:[si-1]             ; poáet zadanòch znakñ
rozbor1:                                  ;* nalezen° zaá†tku textu
         call      commch                   ; znak z povelovÇho ©†dku
         jc        rozbor2                  ; konec textu
         cmp       al," "
         jbe       rozbor1                  ; je oddàlovaá - dal®° znak
         dec       si
         inc       cx
rozbor2:                                  ;* oznaáen° konce textu
         push      si                       ; £schova zaá†tku textu
rozbor5:
         call      commch                   ; znak z povelovÇho ©†dku
         jc        rozbor3                  ; konec textu
         cmp       al," "                   ; je oddàlovaá ?
         ja        rozbor5                  ; nen° oddàlovaá - dal®° znak
         dec       si                       ; n†vrat adresy konce textu
rozbor3: mov       byte ptr ds:[si],0       ; oznaáen° konce textu
         pop       si
rozbor4: ret
; -----------------------------------------------------------------------------
commch:                                   ;* znak z povelovÇho ©†dku
         stc
         jcxz      commch2
         lodsb
         dec       cx
         or        al,al
commch2: ret
; -----------------------------------------------------------------------------
initmod:                                  ;* inicializace programu
         mov       ah,0fh
         int       10h
         dec       ah
         mov       ds:[pozice],ah           ; posledn° pozice na ©†dku
         mov       ds:[stranka],bh          ; aktivn° str†nka displeje
         cmp       al,7                     ; je MDA displej ?
         jne       initmod1
         or        byte ptr ds:[config],1   ; p©°znak displeje MDA
         jmp       short initmod3
initmod1:cmp       al,3
         jbe       initmod3                 ; je textovò m¢d
         or        byte ptr ds:[config],2   ; p©°znak grafickÇho videom¢du
initmod3:mov       ah,12h
         mov       bl,10h
         int       10h                      ; informace o EGA
         cmp       bl,10h                   ; je karta EGA ?
         je        initmod2                 ; nen° karta EGA
         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       al,ds:[484h]             ; á°slo posledn°ho ©†dku
         pop       ds
         mov       ds:[radek],al            ; á°slo posledn°ho ©†dku
initmod2:
         ret
; -----------------------------------------------------------------------------
initfile:                                 ;* inicializace souboru
                                            ; VSTUP: DS:DX=jmÇno souboru
                                            ; VùSTUP: CY=chyba - nen° .DBF

                                          ;* otev©en° souboru pro áten°
         mov       dx,si                    ; specifikace souboru
         mov       ax,3d00h                 ; otev©en° pro áten°
         int       21h                      ; otev©en° souboru pro áten°
         jc        initfil5                 ; chyba otev©en° souboru
         mov       ds:[ident],ax            ; £schova identifik†toru souboru
         mov       bx,ax                    ; identifik†tor souboru
                                          ;* naáten° z†hlav° souboru
         mov       cx,32                    ; dÇlka z†hlav°
         lea       dx,[zahlavi]             ; adresa z†hlav°
         mov       ah,3fh
         int       21h                      ; naáten° z†hlav°
         jc        initfil5                 ; chyba
         cmp       ax,32                    ; dÇlka z†hlav°
         jne       initfil5                 ; dÇlka z†hlav° nesouhlas° - chyba
                                          ;* kontrola z†hlav°
;         mov       al,ds:[verze]            ; verze DBASE
;         cmp       al,3
;         jne       initfil5                 ; nen° verze 3.0 - chyba
                                          ;* naáten° popisovaáñ
         lea       dx,[popis]               ; tabulka popisovaáñ
         mov       cx,ds:[delkazah]         ; dÇlka z†hlav°
         sub       cx,32
         jb        initfil5
         mov       ah,3fh
         int       21h                      ; naáten° z†hlav°
         jc        initfil5                 ; chyba áten°
         add       dx,ax                    ; adresa datovÇho bufferu
         mov       ds:[adrbuf],dx           ; adresa datovÇho bufferu
         jc        initfil5
         add       ax,32
         cmp       ax,ds:[delkazah]
         stc
         jne       initfil5                 ; nesouhlas° dÇlka naátenòch dat
         clc
initfil5:ret
; -----------------------------------------------------------------------------
;                          ZnakovÇ vstupy/vòstupy
; -----------------------------------------------------------------------------
inpnum:                                   ;* vstup á°sla BX:AX
                                            ; VSTUP: DX=pozice na displeji
                                            ; VùSTUP: CY=p©eru®en°


         push      dx
         push      cx
         xor       cx,cx                    ; st©adaá á°sla - LOW
         xor       bx,bx                    ; st©adaá á°sla - HIGH
inpnum1: call      aktkurz                  ; aktualizace kurzoru
         xor       ax,ax
         int       16h
         cmp       al,1bh
         stc
         je        inpnum4
         cmp       al,0dh
         je        inpnum4
         cmp       al,"9"
         ja        inpnum1
         cmp       al,"0"
         jb        inpnum1
         call      outch1
         sub       al,"0"

         push      ax
         push      dx
         mov       ax,10
         mul       cx                       ; vyn†soben° nië®°ho á°sla
         mov       cx,ax                    ; novÇ nië®° á°slo
         push      dx                       ; p©enos
         mov       ax,10
         mul       bx                       ; vyn†soben° vy®®°ho á°sla
         pop       dx
         add       ax,dx                    ; p©enos z nië®°ho á°sla
         mov       bx,ax
         pop       dx
         pop       ax
         xor       ah,ah
         add       cx,ax
         adc       bx,0
         jmp       short inpnum1

inpnum4: mov       ax,cx                    ; nië®° slovo á°sla
         pop       cx
         pop       dx
         ret
; -----------------------------------------------------------------------------
windret:                                  ;* n†vrat zobrazen° celÇho okna

         push      ax
         push      cx
         push      dx

         call      topline
         call      zobpodkl                   ; plocha
         call      outhelp

         xor       al,al
windret1:inc       al
         call      zobpopis
         jnc       windret1

         pop       dx
         pop       cx
         pop       ax
         ret
; -----------------------------------------------------------------------------
zobpodkl:                                 ;* zobrazen° celÇ plochy
         push      ax
         push      cx
         push      dx
         mov       al,1
         call      setatrib
         mov       dx,100h
         mov       cx,word ptr cs:[pozice]
         dec       cl
         sub       ch,3
                                          ;* horn° linka
         push      cx
         mov       al,201                   ; znak "…"
         call      outch1
         mov       al,205                   ; znak "Õ"
         xor       ch,ch
         call      outch
         mov       al,187                   ; znak "ª"
         call      outch1
         pop       cx
                                          ;* vnit©n° plochy
         mov       dx,200h
zoball2: push      cx
         push      dx
         mov       al,186                   ; znak "∫"
         call      outch1
         xor       ch,ch
         mov       al," "
         call      outch
         mov       al,186                   ; znak "∫"
         call      outch1
         pop       dx
         pop       cx
         inc       dh
         dec       ch
         jnz       zoball2
                                          ;* spodn° linka
         mov       al,200                   ; znak "»"
         call      outch1
         mov       al,205                   ; znak "Õ"
         xor       ch,ch
         call      outch
         mov       al,188                   ; znak "º"
         call      outch1

         pop       dx
         pop       cx
         pop       ax
         ret
; -----------------------------------------------------------------------------
topline:                                  ;* zobrazen° horn°ho ©†dku
                                            ; VSTUP: CX:DX=á°slo z†znamu

         push      ax
         push      si
         push      cx
         push      dx

         xor       dx,dx
         call      topclear                 ; vymaz†n° horn°ho ©†dku
         lea       si,[nadpis]
         call      outtxt                   ; zobrazen° textu "DBASE:"
         mov       si,[soubor]
         call      outtxt

         pop       ax
         pop       bx
         push      bx
         push      ax

         add       ax,1
         adc       bx,0

         lea       di,[outbuf]              ; pracovn° buffer
         push      di
         call      deknum                   ; zobrazen° á°sla z†znamu
         mov       al,"/"
         stosb
         mov       ax,word ptr ds:[zaznamu]
         mov       bx,word ptr ds:[zaznamu+2]
         call      deknum
         pop       si
         call      lensi                    ; dÇlka textu
         mov       dl,[pozice]
         sub       dl,al
         xor       dh,dh
         call      outtxt                   ; zobrazen° textu

         pop       dx
         pop       cx
         pop       si
         pop       ax
         ret


topclear:                                 ;* vymaz†n° horn°ho ©†dku

         push      ax
         push      cx
         push      dx

         mov       al,3                     ; atributy displeje
         call      setatrib                 ; nastaven° atributñ displeje
         xor       dx,dx
         mov       cl,ds:[pozice]           ; posledn° pozice na ©†dku
         inc       cl                       ; ®°©ka ©†dku
         mov       al," "
         call      outch                    ; vymaz†n° ©†dku
;         mov       ch,1                     ; vò®ka = 1 ©†dek
;         call      wclear                   ; vymaz†n° okna

         pop       dx
         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
outhelp:                                  ;* zobrazen° n†povàdy
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      ds
         push      cs
         pop       ds

         xor       dl,dl                    ; poá†teán° pozice
         mov       dh,cs:[radek]            ; á°slo posledn°ho ©†dku
         lea       si,[tabhlp]              ; texty n†povàdy
         mov       cx,10                    ; poáet kl†ves
         mov       bl,"1"                   ; á°slo kl†vesy F1
         mov       al,9
         call      setatrib                 ; nastaven° atributu displeje
outhlp1: mov       al,bl
         call      outch1                   ; zobrazen° á°sla fn. kl†vesy
         mov       al,8
         call      setatrib                 ; nastaven° atributu kl†vesy
         call      outtxt                   ; zobrazen° textu funkán° kl†vesy
         mov       al,9
         call      setatrib
         mov       al," "
         call      outch1
         inc       bl
         cmp       bl,"9"+1
         jne       outhlp2
         mov       al,"1"
         call      outch1
         mov       bl,"0"
outhlp2: loop      outhlp1                  ; dal®° kl†vesa

         pop       ds
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret
; -----------------------------------------------------------------------------
wclear:                                   ;* vymaz†n° okna
                                            ; VSTUP: DX=poá†teán° pozice okna
                                            ;        CX=rozmàry okna

         push      ax
         push      bx
         push      cx
         push      dx
         mov       al," "
         or        ch,ch
         jz        wclear2
wclear1: push      cx
         push      dx
         xor       ch,ch
         call      outch
         pop       dx
         pop       cx
         inc       dh
         dec       ch
         jnz       wclear1
wclear2:
;         mov       ax,600h
;         mov       bh,cs:[atrib]            ; atributy barev
;         xchg      dx,cx                    ; CX<-poá†teán° roh, DX<-rozmàry
;         add       dx,cx                    ; DX<-koncovò roh
;         sub       dx,101h
;         call      int10h                   ; vymaz†n° okna
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret
; -----------------------------------------------------------------------------
lensi:                                    ;* dÇlka textu DS:SI -> AX
         push      si
         xor       ax,ax
lensi1:  cmp       byte ptr ds:[si],0
         je        lensi2
         inc       si
         inc       ax
         jnz       lensi1
         dec       ax
lensi2:  pop       si
         ret
; -----------------------------------------------------------------------------
deknum:                                   ;* dek¢dov†n° á°sla BX:AX
                                            ; VSTUP: ES:DI=ukl†dac° adresa

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

         xor       cx,cx                    ; á°taá á°sel
         mov       si,10                    ; dàlitel
                                          ;* p©ek¢dov†n° á°sla BX
deknum1: xchg      ax,bx                    ; BX<-nië®° slovo, AX<-vy®®° slovo
         xor       dx,dx                    ; DX <- 0
         div       si                       ; vydàlen° vy®®°ho slova
         xchg      bx,ax                    ; BX<-vy®®° slovo, AX<-nië®° slovo
         div       si                       ; vydàlen° nië®°ho slova
         add       dl,"0"                   ; korekce zbytku na á°slici ASCII
         push      dx                       ; £schova á°slice do z†sobn°ku
         inc       cx                       ; zvò®en° á°taáe á°slic
         mov       dx,bx                    ; vy®®° slovo novÇho á°sla
         or        dx,ax                    ; je jië = 0 ?
         jnz       deknum1                  ; nen° je®tà 0
deknum2:                                  ;* uloëen° á°sla
         pop       ax                       ; n†vrat á°sla z bufferu
         stosb                              ; uloëen° znaku do bufferu
         loop      deknum2                  ; dal®° znak
         mov       byte ptr es:[di],0       ; koncov† 0

         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret
; -----------------------------------------------------------------------------
outstxt:                                  ;* zobrazen° specifikovanÇho textu
                                            ; VSTUP: DS:SI=text k zobrazen°
                                            ;        DX=sou©adnice na displeji
                                            ;        CX=poáet znakñ k zobrazen°
         push      ax
         push      cx
         jcxz      outstxt2
outstxt1:lodsb
         call      outchs1
         loop      outstxt1
outstxt2:pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
outtxt:                                   ;* zobrazen° textu
                                            ; VSTUP: DS:SI=text k zobrazen°
                                            ;        DX=sou©adnice na displeji
         push      ax
outtxt1: lodsb
         or        al,al
         jz        outtxt2
         call      outch1
         jmp       short outtxt1
outtxt2: pop       ax
         ret
; -----------------------------------------------------------------------------

outchs1:
         push      ax
         push      dx
         sub       dl,ds:[offsetx]
         jc        outchs2
         cmp       dl,0eh
         jl        outchs2
         jne       outchs3
         cmp       byte ptr ds:[offsetx],0
         je        outchs3
         mov       al,174                   ; Æ
outchs3: cmp       dl,ds:[pozice]
         jae       outchs2
         call      outch1
outchs2: pop       dx
         pop       ax
         inc       dl
         ret

; -----------------------------------------------------------------------------


outch1:                                   ;* zobrazen° 1 znaku
                                            ; VSTUP: AL=znak k zobrazen°
                                            ;        DX=sou©adnice na displeji
         push      cx
         mov       cx,1
         call      outch
         pop       cx
         ret
; -----------------------------------------------------------------------------
outch:                                    ;* zobrazen° znaku
                                            ; VSTUP: AL=znak k zobrazen°
                                            ;        DX=sou©adnice na displeji
                                            ;        CX=poáet znakñ k zobrazen°

         cmp       dh,cs:[radek]            ; kontrola posledn°ho ©†dku
         ja        outch3                   ; neplatnÇ á°slo ©†dku
         cmp       dl,cs:[pozice]           ; kontrola pozice na ©†dku
         ja        outch3                   ; p©ekroáena pozice na ©†dku
                                          ;* poá†teán° pozice OK
         push      ax
         push      bx
         push      cx
         push      dx
                                          ;* nastaven° pozice na displeji
         mov       bx,word ptr cs:[atrib]   ; atributy, aktivn° videostr†nka
         mov       ah,2
         call      int10h                   ; nastaven° pozice kurzoru
                                          ;* omezen° poátu znakñ
         push      ax
         mov       al,cs:[pozice]           ; posledn° pozice na displeji
         inc       al
         sub       al,dl                    ; poáet pozic do konce ©†dku
         xor       ah,ah
         cmp       cx,ax                    ; je p©ekroáen poáet znakñ ?
         jbe       outch2                   ; nen° p©ekroáen poáet znakñ
         mov       cx,ax                    ; omezen° poátu znakñ
outch2:  pop       ax
                                          ;* zobrazen° znaku
         mov       ah,9
         jcxz      outch4
         call      int10h
outch4:
         pop       dx
         add       dl,cl
         pop       cx
         pop       bx
         pop       ax
outch3:  ret
; -----------------------------------------------------------------------------
aktkurz:
         push      dx
         jmp       short kurzout2

kurzout:                                  ;* vypnut° kurzoru
         push      dx
         mov       dx,word ptr cs:[pozice]
         inc       dh
kurzout2:push      ax
         push      bx
         mov       ah,2
         mov       bh,cs:[stranka]
         call      int10h
         pop       bx
         pop       ax
         pop       dx
         ret
; -----------------------------------------------------------------------------
int10h:                                   ;* vòstup na obsluhu INT 10h
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es
         int       10h                      ; obsluha INT 10h
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret
; -----------------------------------------------------------------------------
setatrib:                                 ;* nastaven° atributñ pro zobrazen°
                                            ; VSTUP: AL=á°slo atributu

         push      ax
         push      bx
         lea       bx,[tabatrg]             ; grafickò displej
         test      byte ptr cs:[config],2   ; je grafickò displej ?
         jnz       setatr1                  ; je grafickò displej
         lea       bx,[tabatrm]             ; monochorm. displej
         test      byte ptr cs:[config],1   ; je displej MDA ?
         jnz       setatr1                  ; je displej MDA
         lea       bx,[tabatrc]             ; barevnò displej
setatr1: xor       ah,ah
         dec       al
         add       bx,ax                    ; adresa atributu
         mov       al,cs:[bx]               ; atribut
         mov       cs:[atrib],al            ; novÇ atributy
         pop       bx
         pop       ax
         ret
; -----------------------------------------------------------------------------
readzaz:                                  ;* naáten° z†znamu do bufferu
                                            ; VSTUP: CX:DX=á°slo z†znamu
                                            ; VùSTUP: CY=chyba operace

         push      ax
         push      bx
         push      cx
         push      dx
                                          ;* vòpoáet offsetu z†znamu
         mov       bx,ds:[delkazaz]         ; dÇlka z†znamu
         mov       ax,dx                    ; nië®° slovo á°sla
         mul       bx                       ; vòpoáet nië®°ho slova adresy
         xchg      ax,cx                    ; AX<-vy®®° slovo, CX<-novÇ nië®° s.
         xchg      bx,dx
         mul       dx                       ; vyn†soben° vy®®°ho slova
         add       ax,bx                    ; p©iáten° p©enosu z nië®°ho slova
         mov       dx,cx                    ; nië®° slovo adresy
         mov       cx,ax                    ; vy®®° slovo
         add       dx,ds:[delkazah]         ; p©iáten° dÇlky z†hlav°
         adc       cx,0                     ; p©enos do vy®®°ho slova
         add       dx,1
         adc       cx,0

         mov       ax,4200h
         mov       bx,ds:[ident]            ; identifik†tor souboru
         int       21h                      ; p©em°stàn° ukazatele souboru
         mov       cx,ds:[delkazaz]         ; dÇlka z†znamu
         mov       dx,ds:[adrbuf]           ; adresa bufferu pro naáten° z†znamu
         mov       ah,3fh
         int       21h                      ; naáten° bloku dat
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret
; -----------------------------------------------------------------------------
int1b:                                    ;* obsluha INT 1bh
         iret


int09:

         push      ax
         push      bx
         push      ds
         mov       bx,40h                   ; datovò segment BIOS
         mov       ds,bx                    ; DS <- datovò segment BIOS
         mov       bx,ds:[1ch]              ; £schova ukazatele znakñ
         pushf
         call      dword ptr cs:[old09]     ; vol†n° pñvodn° obsluhy INT 09h
         cmp       ds:[1ch],bx              ; byl p©ijat znak ?
         je        int092                   ; nebyl p©ijat znak
                                          ;* kontrola, zda je rezerva 1 znak
         push      bx
         mov       bx,ds:[1ch]              ; nov† ukl†dac° adresa
         call      int09ins                 ; zvò®en° ukl†dac° adresy
         pop       bx                       ; n†vrat pñvodn°ho ukazatele
         jne       int092                   ; nebude p©esycen°
         mov       ds:[1ch],bx              ; p©esycen°, zru®en° znaku v bufferu
int092:  pop       ds
         pop       bx
         pop       ax
         iret

int09ins:                                 ;* zvò®en° ukl†dac° adresy BX
                                            ; VùSTUP: ZY=bude p©esycen°

         add       bx,2                     ; zvò®en° ukl†dac° adresy
         cmp       bx,3eh                   ; je p©ekroáen° konce bufferu ?
         jb        int09in2                 ; nen° je®tà p©ekroáen konec bufferu
         sub       bx,20h                   ; p©esun ukazatele na zaá†tek
int09in2:cmp       bx,ds:[1ah]              ; bude jië p©esycen° ?
         ret

; -----------------------------------------------------------------------------
;                                  Data
; -----------------------------------------------------------------------------
errtxt   db        'Chyba - nenalezen platny soubor DBASE (.DBF) !'
         db        13,10,'$'

txtzad   db        'Zadejte cislo noveho zaznamu: ',0

nadpis   db        ' DBASE view:  ',0

tabhlp   db        '      ',0               ; F1
         db        '      ',0               ; F2
         db        '      ',0               ; F3
         db        '      ',0               ; F4
         db        'Skok  ',0               ; F5
         db        '      ',0               ; F6
         db        '      ',0               ; F7
         db        '      ',0               ; F8
         db        '      ',0               ; F9
         db        'Konec ',0               ; F10

config   db        0                        ; konfigurace
                                            ;  bit 0: 1=monochromatickò displej
                                            ;  bit 1: 1=grafickò displej
                                            ;  bit 2: 1=zobrazen° BROWSE

tabatrc  label     byte                   ;* tabulka atributñ - barevnò displej

         db        1bh                      ; 1:norm†ln° text
         db        1eh                      ; 2:vysv°cenò text
         db        30h                      ; 3:negovanò text
         db        70h                      ; 4:informaán° okno
         db        74h                      ; 5:vysv°cenò text v inform. oknà
         db        30h                      ; 6:kurzor v informaán°m oknà
         db        4fh                      ; 7:chybovÇ hl†®en°
         db        30h                      ; 8:n†povàda k funkán°m kl†ves†m
         db        07h                      ; 9:text á°sla funkán°ch kl†ves
         db        0bh                      ;10:text poloëky

tabatrm  label     byte                   ;* tabulka atributñ - monochr. displej

         db        07h                      ; 1:norm†ln° text
         db        0fh                      ; 2:vysv°cenò text
         db        70h                      ; 3:negovanò text
         db        70h                      ; 4:informaán° okno
         db        70h                      ; 5:vysv°cenò text v inform. oknà
         db        07h                      ; 6:kurzor v informaán°m oknà
         db        0fh                      ; 7:chybovÇ hl†®en°
         db        70h                      ; 8:n†povàda k funkán°m kl†ves†m
         db        07h                      ; 9:text á°sla funkán°ch kl†ves
         db        70h                      ;10:text poloëky

tabatrg  label     byte                   ;* tabulka atributñ - grafickò. displej

         db        07h                      ; 1:norm†ln° text
         db        0fh                      ; 2:vysv°cenò text
         db        07h                      ; 3:negovanò text
         db        07h                      ; 4:informaán° okno
         db        07h                      ; 5:vysv°cenò text v inform. oknà
         db        0fh                      ; 6:kurzor v informaán°m oknà
         db        0fh                      ; 7:chybovÇ hl†®en°
         db        07h                      ; 8:n†povàda k funkán°m kl†ves†m
         db        07h                      ; 9:text á°sla funkán°ch kl†ves
         db        07h                      ;10:text poloëky

pozice   db        79                       ; posledn° pozice na ©†dku ƒƒƒƒø!
radek    db        24                       ; posledn° ©†dek na displeji ƒƒŸ

atrib    db        7                        ; atributy pro zobrazen° ƒƒƒø!
stranka  db        0                        ; aktivn° videostr†nka ƒƒƒƒƒŸ

old1b    dd        0                        ; pñvodn° adresa obsluhy INT 1bh
old09    dd        0                        ; pñvodn° adresa obsluhy INT 09h

offsetx  db        0                        ; offset pozice v horiz. smàru
offsety  db        0                        ; offset ©†dku ve vert. smàru

soubor   dw        ?                        ; adresa souboru v ©†dku
ident    dw        ?                        ; identifik†tor souboru
adrbuf   dw        offset buffer            ; adresa bufferu pro naáten° dat

outbuf   db        80 dup(0)                ; tiskovò buffer

zahlavi  label     byte                   ;* z†hlav° souboru DBF
verze    db        0                        ;  0:verze DBASE (03)
datumakt db        0,0,0                    ;  1:datum aktualizace
zaznamu  dd        0                        ;  4:poáet z†znamñ
delkazah dw        0                        ;  8:poáet bajtñ z†hlav°
delkazaz dw        0                        ; 10:poáet bajtñ z†znamu
         db        3 dup(0)                 ; 12:rezervov†no
         db        13 dup(0)                ; 15:rezervov†no pro multiuëivatele
         db        4 dup(0)                 ; 28:rezervov†no

popis    label     byte                   ;* popisovaáe souboru DBF

buffer   label     byte                     ; buffer pro naáten° souboru

code     ENDS
         END       dbv

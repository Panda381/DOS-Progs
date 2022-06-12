;------------------------------------------------------------------------------
;                     Program pro zobrazen¡ obsahu pamˆti
;------------------------------------------------------------------------------
code     SEGMENT 
         ASSUME    cs:code,ds:code
         org       100h
start:
         mov       ax,ds:[2]                ; konec pamˆti
         push      ax
                                          ;* zmen¨en¡ bloku pamˆti
         lea       bx,[konec]               ; konec programu MEMORY
         add       bx,15                    ; zaokrouhlen¡ na odstavec
         mov       cl,4
         shr       bx,cl                    ; p©epo‡et na odstavce
         mov       ah,4ah                   ; funkce modifikace bloku pamˆti
         int       21h                      ; zmen¨en¡ bloku pamˆti
                                          ;* zobrazen¡ nadpisu
         lea       bx,[txtnadp]
         call      outtxt                   ; zobrazen¡ nadpisu
         call      srcfrst                  ; nalezen¡ prvn¡ho aloka‡n¡ho bloku
         jc        mem9                     ; chyba pamˆti
                                          ;* zobrazen¡ obahu pamˆti
mem2:    mov       ds,ax                    ; segment alok. bloku
         mov       cl,2
         call      outtab                   ; nastaven¡ tabel toru
         push      ax
         inc       ax
         call      hexwrd                   ; zobrazen¡ slova HEX
         mov       cl,8
         call      outtab                   ; nastaven¡ na dal¨¡ zna‡ku tabel.
         call      vlastnik                 ; zobrazen¡ vlastn¡ka
         mov       cl,8
         call      outtab                   ; nastaven¡ na dal¨¡ zna‡ku tabel.
         mov       ax,ds:[3]                ; velikost bloku
         call      deknms                   ; zobrazen¡ velikosti segmentu
         mov       cl,8
         call      outtab                   ; nastaven¡ na dal¨¡ zna‡ku tabel.
         call      typ                      ; zobrazen¡ typu bloku
         mov       cl,11
         call      outtab                   ; nastaven¡ na dal¨¡ zna‡ku tabel.
         call      pathenv                  ; zobrazen¡ p©¡stupov‚ cesty
         call      outcr
         pop       ax
         mov       ds,ax
         cmp       byte ptr ds:[0],"Z"      ; je ji‘ posledn¡ blok ?
         je        mem9                     ; byl to ji‘ posledn¡ alok. blok
         call      srcnxt                   ; nastaven¡ na dal¨¡ alok. blok
         jmp       mem2                     ; dal¨¡ alok. blok
mem9:                                     ;* konec zobrazen¡ pamˆti
         push      cs
         pop       ds
         call      outcr
                                          ;* celkov  pamˆŸ
         lea       bx,[txtcelk]             ; text "Celkov  pamˆŸ"
         call      outtxt
         pop       ax                       ; konec pamˆti
         call      deknms                   ; zobrazen¡ informace o pamˆti
         call      outcr                    ; nov˜ © dek
                                          ;* voln  pamˆŸ
         lea       bx,[txtvoln]             ; text "Voln  pamˆŸ"
         call      outtxt
         mov       bx,ds                    ; segment programu
         sub       ax,bx                    ; voln  pamˆŸ
         call      deknms                   ; zobrazen¡ informace o voln‚ pamˆti
         call      outcr
         int       20h                      ; n vrat z programu
; -----------------------------------------------------------------------------
public   pathenv
pathenv:                                  ;* zobrazen¡ p©¡stupov‚ cesty
                                            ; VSTUP: DS=segment alok. bloku
         push      ax
         push      bx
         push      si
         push      ds
         mov       ah,30h
         int       21h                      ; poskytnut¡ ‡¡sla verze syst‚mu
         cmp       al,3                     ; je verze alespo¤ 3.00 ?
         jb        pathenv3                 ; je n¡zk  verze syst‚mu
         mov       ax,ds                    ; segment bloku
         call      testprog                 ; test, zda je program
         jc        pathenv3                 ; nen¡ to program
         inc       bx                       ; segment prost©ed¡
         mov       ds,bx                    ; segment prost©ed¡
         mov       si,3                     ; po‡ te‡n¡ offset prost©ed¡ + 3
         xor       ax,ax                    ; AX <- 0 (hledan‚ slovo)
                                          ;* nalezen¡ za‡ tku cesty
pathenv1:inc       si                       ; zv˜¨en¡ adresy textu
         cmp       ds:[si-4],ax             ; je konec ©etˆzc– prost©ed¡ (0) ?
         jne       pathenv1                 ; nen¡ konec ©etˆzc– prost©ed¡
         inc       ax
         cmp       ds:[si-2],ax             ; je nˆjak˜ ©etˆzec ?
         jne       pathenv3                 ; chybn˜ ©etˆzec
pathenv2:                                 ;* zobrazen¡ ©etˆzce cesty
         lodsb
         or        al,al
         jz        pathenv3
         call      outchh
         jmp       short pathenv2
pathenv3:pop       ds
         pop       si
         pop       bx
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   typ
typ:                                      ;* zobrazen¡ typu bloku
                                            ; VSTUP: DS=segment alok. bloku
         push      ax
         push      ds
         mov       ax,ds                    ; segment bloku
         mov       dx,ds:[1]                ; vlastn¡k bloku
         or        dx,dx
         je        vlast1                   ; je voln˜ blok
         call      testprog                 ; je to program ?
         lea       bx,[typprog]             ; text "PROGRAM"
         jnc       typ6                     ; je program
                                          ;* test, jestli je prost©ed¡
         mov       ax,dx                    ; nov˜ segment
         dec       ax
         call      testprog                 ; je to program ?
         jc        typ5                     ; pat©¡ syst‚mu
         mov       ax,ds
         cmp       bx,ax                    ; je to prost©ed¡ ?
         lea       bx,[typenv]              ; ozna‡en¡ - je to prost©ed¡
         je        typ6                     ; je to prost©ed¡
         lea       bx,[typdat]              ; jsou to data
         jmp       short typ6
typ5:    lea       bx,[typsys]              ; pat©¡ syst‚mu
typ6:    call      outtxt                   ; zobrazen¡ textu typu
typ9:    pop       ds
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   vlastnik
vlastnik:                                 ;* zobrazen¡ vlastn¡ka bloku
                                            ; VSTUP: DS=segment alok. bloku
         push      ax
         push      ds
                                          ;* voln˜ aloka‡n¡ blok
         mov       dx,ds:[1]                ; vlastn¡k bloku
         mov       ax,dx                    ; vlastn¡k bloku
         call      hexwrd                   ; zobrazen¡ slova HEX
         mov       cl,7
         call      outtab                   ; nastaven¡ na dal¨¡ zna‡ku tabel.
         or        dx,dx                    ; je voln˜ blok ?
         jne       vlast2                   ; nen¡ voln˜ blok
vlast1:  lea       bx,[vlsys]               ; vlastn¡k - system
         call      outtxt                   ; zobrazen¡ textu
         jmp       short vlast9
                                          ;* je to program
vlast2:  mov       ax,ds
         call      namprog                  ; zobrazen¡ jm‚na programu
         jnc       vlast9                   ; byl to program
vlast4:                                   ;* vlastn¡k jej nˆkdo jin˜
         mov       ax,dx                    ; segment jin‚ho vlastn¡ka
         dec       ax
         call      namprog                  ; zobrazen¡ jm‚na jin‚ho vlastn¡ka
vlast9:  pop       ds
         pop       ax
         ret
; -----------------------------------------------------------------------------
namprog:                                  ;* zobrazen¡ jm‚na programu
                                            ; VSTUP: AX=adresa alok. bloku
                                            ; VSTUP: CY=nen¡ program
         push      ax
         push      bx
         push      cx
         push      si
         push      ds
         mov       ds,ax                    ; segment bloku
         call      testprog                 ; je to program ?
         jc        namprg2                  ; nen¡ program
                                          ;* pro verzi 4.00 p©¡m‚ zobrazen¡
         push      ax
         mov       ah,30h
         int       21h                      ; poskytnut¡ ‡¡sla verze syst‚mu
         cmp       al,4                     ; je verze alespo¤ 4.00 ?
         pop       ax
         jae       namprg3                  ; je verze syst‚mu alespo¤ 4.00
                                          ;* nalezen¡ jm‚na programu pro DOS3.xx
         mov       ds,ds:[3ch]              ; segment prost©ed¡
         mov       si,3                     ; po‡ te‡n¡ offset prost©ed¡ + 3
         xor       ax,ax                    ; AX <- 0 (hledan‚ slovo)
                                          ;* nalezen¡ za‡ tku cesty
namprg4: inc       si                       ; zv˜¨en¡ adresy textu
         cmp       ds:[si-4],ax             ; je konec ©etˆzc– prost©ed¡ (0) ?
         jne       namprg4                  ; nen¡ konec ©etˆzc– prost©ed¡
         inc       ax
         cmp       ds:[si-2],ax             ; je nˆjak˜ ©etˆzec ?
         jne       namprg8                  ; chybn˜ ©etˆzec
                                          ;* nalezen¡ za‡ tku jm‚na
namprg5: mov       bx,si                    ; nov˜ za‡ tek jm‚na
namprg6: lodsb
         or        al,al
         jz        namprg7                  ; je konec jm‚na
         cmp       al,"\"                   ; je oddˆlova‡ cesty ?
         je        namprg5                  ; je nov˜ oddˆlova‡ cesty
         jmp       short namprg6            ; test dal¨¡ho znaku

namprg8:                                  ;* pokus o interpretaci jako COMMAND
         mov       bx,ds
         dec       bx
         mov       ds,bx                    ; popisova‡ bloku
         cmp       bx,ds:[1]                ; je blok nad vlastn¡kem ?
         jbe       namprg2                  ; blok je nad vlastn¡kem
         push      cs
         pop       ds                       ; DS <- CS
         lea       bx,[txtcomm]             ; text COMMAND

namprg7: mov       si,bx                    ; adresa jm‚na programu
         jmp       short namprg1            ; zobrazen¡ jm‚na
                                          ;* zobrazen¡ jm‚na pro DOS 4.xx
namprg3: mov       si,8                     ; adresa jm‚na programu
         mov       cx,8                     ; d‚lka jm‚na programu
namprg1: lodsb                              ; na‡ten¡ znaku jm‚na
         or        al,al                    ; konec jm‚na ?
         jz        namprg2                  ; konec jm‚na
         cmp       al,"."                   ; je konec jm‚na ?
         je        namprg2                  ; je konec jm‚na
         call      outchh                   ; zobrazen¡ znaku jm‚na
         loop      namprg1                  ; dal¨¡ znak jm‚na
         clc
namprg2: pop       ds
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret
; -----------------------------------------------------------------------------
;                      Operace s aloka‡n¡mi bloky pamˆti
; -----------------------------------------------------------------------------
public   testprog
testprog:                                 ;* test, zda je blok programem
                                            ; VSTUP: AX=adresa alok. bloku
                                            ; VSTUP: CY=nen¡ to program
                                            ;         BX=segment prost©ed¡-1
         push      ax
         push      ds
         mov       ds,ax
         cmp       byte ptr ds:[0],"M"      ; je vnit©n¡ blok ?
         je        testpr1                  ; je vnit©n¡ blok
         cmp       byte ptr ds:[0],"Z"      ; je posledn¡ blok ?
         stc
         jne       testpr2                  ; nen¡ to v–bec aloka‡n¡ blok
testpr1: inc       ax
         cmp       ax,ds:[1]                ; vlastn¡ s m sebe ?
         stc
         jne       testpr2                  ; nen¡ to program
         mov       bx,ds:[3ch]              ; adresa segmentu prost©ed¡
         dec       bx
         clc
testpr2: pop       ds
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   srcfrst
srcfrst:                                  ;* nalezen¡ prvn¡ho aloka‡n¡ho bloku
                                            ; VSTUP: AX=adresa prvn¡ho bloku
         push      cx
         mov       cx,cs                    ; po‡et segment– pamˆti
         mov       ax,300h                  ; po‡ te‡n¡ segment k hled n¡
srcfrst1:inc       ax                       ; zv˜¨en¡ adresy segmentu
         call      testblk                  ; test, zda je aloka‡n¡ blok
         jnc       srcfrst2                 ; nalezen prvn¡ aloka‡n¡ blok
         loop      srcfrst1                 ; test dal¨¡ho bloku
srcfrst2:pop       cx
         ret
; -----------------------------------------------------------------------------
public   testblk
testblk:                                  ;* test, zda je aloka‡n¡ blok
                                            ; VSTUP: AX=adresa alok. bloku
                                            ; VSTUP: CY=nen¡ alok. blok
         push      bx
         push      ds
         push      ax
testblk1:mov       ds,ax                    ; aloka‡n¡ blok
         cmp       byte ptr ds:[0],"M"      ; je vnit©n¡ alok. blok ?
         je        testblk3                 ; je vnit©n¡ blok pamˆti - OK
         cmp       byte ptr ds:[0],"Z"      ; je posledn¡ blok pamˆti ?
         stc
         jne       testblk2                 ; nen¡ aloka‡n¡ blok - chyba
         mov       bx,cs
         dec       bx
         cmp       ax,bx
;         jc        testblk2
;         pop       ax
;         push      ax                       ; segment bloku
;         mov       ds,ax
;         inc       ax
;         cmp       ax,ds:[1]
;         je        testblk2
;         mov       ax,ds:[1]                ; vlastn¡k bloku
;         call      testblk                  ; je aloka‡n¡ blok ?
         jmp       short testblk2           ; CY=nen¡ aloka‡n¡ blok
testblk3:call      srcnxt                   ; nastaven¡ na dal¨¡ alok. blok
         jnc       testblk1                 ; operace OK - dal¨¡ blok
testblk2:pop       ax
         pop       ds
         pop       bx
         ret
; -----------------------------------------------------------------------------
public   srcnxt
srcnxt:                                   ;* nastaven¡ na dal¨¡ aloka‡n¡ blok
                                            ; VSTUP: AX=segment bloku
                                            ; VSTUP: AX=segment dal¨¡ho bloku
                                            ;         CY=nen¡ dal¨¡ alok. blok
         push      bx
         push      ds
         mov       ds,ax                    ; segment aloka‡n¡ho bloku
         add       ax,ds:[3]                ; zv˜¨en¡ o velikost alok. bloku
         jc        srcnxt2                  ; p©ete‡en¡
         add       ax,1                     ; p©i‡ten¡ z hlav¡ bloku
         jc        srcnxt2                  ; p©ete‡en¡
         cmp       ax,0a000h                ; je nad segmentem konce pamˆti ?
         cmc                                ; CY=chyba
srcnxt2: pop       ds
         pop       bx
         ret
; -----------------------------------------------------------------------------
;                               Znakov‚ v˜stupy
; -----------------------------------------------------------------------------
public   outcr
outcr:                                    ;* od© dkov n¡
         push      ax
         mov       al,13
         call      outch
         mov       al,10
         call      outch
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   deknms
deknms:                                   ;* zobrazen¡ ‡¡sla segmentu
                                            ; VSTUP: AX=segment
         push      ax
         push      bx
         push      cx
         push      dx
         xor       dh,dh
         mov       dl,ah
         mov       cl,4
         shr       dx,cl
         shl       ax,cl
         call      deknum
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   deknum,deknum1,deknum0
deknum:                                   ;* zobrazen¡ dekadick‚ho ‡¡sla
                                            ; VSTUP: DX:AX=‡¡slo k p©ek¢dov n¡

         mov       bl,0fh                   ; vy¨¨¡ slovo ‡¡sla 1000 000
         mov       cx,4240h                 ; ni‘¨¡ slovo ‡¡sla 1000 000
         call      deknum0                  ; dek¢dov n¡ 1 ‡¡slice
         mov       bl,1                     ; vy¨¨¡ slovo ‡¡sla 100 000
         mov       cx,86a0h                 ; ni‘¨¡ slovo ‡¡sla 100 000
         call      deknum0                  ; dek¢dov n¡ 1 ‡¡slice
         mov       cx,10000                 ; ni‘¨¡ slovo ‡¡sla 10 000
         call      deknum1                  ; dek¢dov n¡ 1 ‡¡slice
         mov       cx,1000                  ; ni‘¨¡ slovo ‡¡sla 1 000
         call      deknum1                  ; dek¢dov n¡ 1 ‡¡slice
         mov       cx,100                   ; ni‘¨¡ slovo ‡¡sla 100
         call      deknum1                  ; dek¢dov n¡ 1 ‡¡slice
         mov       cx,10                    ; ni‘¨¡ slovo ‡¡sla 10
         call      deknum1                  ; dek¢dov n¡ 1 ‡¡slice
         add       al,"0"                   ; korekce na ‡¡slici
         call      outch                    ; zobrazen¡ ‡¡slice
         mov       byte ptr cs:[citdek],0   ; vynulov n¡ ‡¡ta‡e ‡¡slice
         ret

deknum1: xor       bl,bl                    ; BL <- 0
deknum0: xor       bh,bh                    ; BH <- 0
         mov       byte ptr cs:[citnum],2fh ; inicializace ‡¡ta‡e ‡¡slice
deknm1:  inc       byte ptr cs:[citnum]     ; zv˜¨en¡ ‡¡ta‡e ‡¡slice
         sub       ax,cx                    ; ode‡ten¡ ni‘¨¡ho slova ‡¡sla
         sbb       dx,bx                    ; ode‡ten¡ vy¨¨¡ho slova ‡¡sla
         jnc       deknm1                   ; nen¡ je¨tˆ p©ete‡en¡
         add       ax,cx                    ; n vrat ni‘¨¡ho slova ‡¡sla
         adc       dx,bx                    ; n vrat vy¨¨¡ho slova ‡¡sla
         cmp       byte ptr cs:[citnum],"0" ; je ‡¡slice 0 ?
         jne       deknm2                   ; nen¡ ‡¡slice 0 - dek¢dov n¡
         cmp       byte ptr cs:[citdek],0   ; byla ji‘ nˆjak  ‡¡slice ?
         jne       deknm2                   ; byla ji‘ nˆjak  ‡¡slice
         mov       byte ptr cs:[citnum]," " ; n hradn¡ znak mezery
         jmp       short deknm21
deknm2:  inc       byte ptr cs:[citdek]     ; zv˜¨en¡ ‡¡ta‡e ‡¡slic
deknm21: push      ax                       ; £schova AX
         mov       al,cs:[citnum]           ; dek¢dovan  ‡¡slice
         call      outch                    ; zobrazen¡ ‡¡slice
         pop       ax                       ; n vrat AX
deknm3:  ret
; -----------------------------------------------------------------------------
public   outtab
outtab:                                   ;* nastaven¡ na zna‡ku tabel toru
                                            ; VSTUP: CL=po‡et pozic pro tabel tor
         push      ax
         push      cx
         mov       al,cs:[poztab]           ; star  pozice tabel toru
         add       al,cl                    ; nov  pozice tabel toru
         mov       cs:[poztab],al           ; nastaven¡ nov‚ pozice tabel toru
         sub       al,cs:[pozice]           ; po‡et pozic pro tabelaci
         jbe       outtab2                  ; p©ekro¨en¡ pozice tabel toru
         mov       cl,al                    ; po‡et pozic
         xor       ch,ch
outtab1: mov       al," "
         call      outch                    ; zobrazen¡ mezery
         loop      outtab1                  ; dal¨¡ mezera
outtab2: pop       cx
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   hexwrd,hexbyte,hexchr
hexwrd:                                   ;* zobrazen¡ slova HEX
         push      ax
         mov       al,ah                    ; vy¨¨¡ bajt slova
         call      hexbyte                  ; zobrazen¡ vy¨¨¡ho bajtu slova
         pop       ax
;         call      hexbyte                  ; zobrazen¡ ni‘¨¡ho bajtu slova
;         mov       al,"h"
;         call      outch
;         ret
;
hexbyte:                                  ;* zobrazen¡ bajtu HEX
         push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         call      hexchr                   ; zobrazen¡ vy¨¨¡ tetr dy bajtu HEX
         pop       ax
hexchr:                                   ;* zobrazen¡ tetr dy bajtu
         push      ax
         and       al,0fh                   ; ni‘¨¡ tetr da bajtu
         cmp       al,10                    ; je znak HEX ?
         jb        hexchr2                  ; je ‡¡slice
         add       al,7                     ; korekce na znak HEX
hexchr2: add       al,"0"                   ; korekce na znak ASCII
         call      outch                    ; zobrazen¡ znaku
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   outtxt
outtxt:                                   ;* zobrazen¡ textu
                                            ; VSTUP: BX=adresa textu
         push      bx
         push      ax
outtx0:  mov       al,cs:[bx]
         inc       bx
         or        al,al
         jz        outtx1
         call      outch                    ; zobrazen¡ znaku
         jmp       short outtx0
outtx1:  pop       ax
         pop       bx
         ret
; -----------------------------------------------------------------------------
public   outchh

outchh:                                   ;* zobrazen¡ velk‚ho znaku
                                            ; VSTUP: AL=znak
         push      ax
         cmp       al,"a"
         jb        outchh1
         cmp       al,"z"
         ja        outchh1
         sub       al,32
outchh1: cmp       al," "
         jae       outchh2
         mov       al," "
outchh2: call      outch
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   outch
outch:                                    ;* zobrazen¡ znaku
                                            ; VSTUP: AL=znak
         push      ax
         push      dx
         cmp       al,10
         je        outch3                   ; je znak <LF>
         cmp       al,13
         jne       outch1
         mov       byte ptr cs:[pozice],0   ; vynulov n¡ pozice znaku
         mov       byte ptr cs:[poztab],0   ; vynulov n¡ pozice tabel toru
         jmp       short outch3
outch1:  cmp       al,32
         jae       outch2
         mov       al," "
outch2:  inc       byte ptr cs:[pozice]     ; zv˜¨en¡ pozice na © dku
outch3:  mov       dl,al
         mov       ah,2
         int       21h                      ; zobrazen¡ znaku
         pop       dx
         pop       ax
         ret
; -----------------------------------------------------------------------------
;                             Data
; -----------------------------------------------------------------------------
public   txtnadp
txtnadp  db        'Segment Vlastnik  Jmeno  Velikost   Typ',13,10
         db        '------------------------------------------',13,10,0
vlsys    db        '--------',0
typprog  db        '<PROGRAM>',0
typenv   db        'prostredi',0
typdat   db        'data',0
typsys   db        'system',0
txtcelk  db        'Celkova pamet: ',0
txtvoln  db        'Volna pamet  : ',0
txtcomm  db        'COMMAND',0

citnum   db        0                        ; ‡¡ta‡ ‡¡slice
citdek   db        0                        ; ‡¡ta‡ zobrazen˜ch ‡¡slic
pozice   db        0                        ; ‡¡ta‡ pozice na © dku
poztab   db        0                        ; pozice tabel toru

         db        23 DUP(0)

konec    label     byte                     ; konec programu MEMORY

code     ENDS
         END       start               ; startovac¡ adresa

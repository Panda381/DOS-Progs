
; *****************************************************************************
;
;                         Simul tor prost©ed¡ CP/M
;
; *****************************************************************************

code     SEGMENT
         ASSUME    cs:code,ds:code
         org       100h

start:                                      ; hlavn¡ tˆlo programu
         cli
         mov       sp,offset zasobnik       ; ukazatel z sobn¡ku
         mov       ax,cs                    ; segment programu
         mov       ss,ax                    ; segment z sobn¡ku
         sti                                ; povolen¡ p©eru¨en¡
                                          ;* instalace obsluhy p©eru¨en¡
         mov       dx,offset int23
         mov       ax,2523h
         int       21h
                                          ;* nastaven¡ adresy segmentu CP/M
         mov       ax,cs
         add       ax,(15+offset(konec-start)) SHR 4 ; segment konce programu
         mov       ds:[segcpm],ax           ; segment s porgramem CP/M
         mov       es,ax                    ; segment C/PM
                                          ;* vymaz n¡ segmentu CP/M
         xor       di,di                    ; offset za‡ tku segmentu 0
         mov       cx,8000h                 ; d‚lka pro vymaz n¡ pamˆti
         xor       ax,ax                    ; vymaz vac¡ bajt 0
         rep       stosw                    ; vymaz n¡ segmentu CP/M
                                          ;* p©enesen¡ vzoru prost©ed¡ CP/M
         mov       si,offset vzor           ; prost©ed¡ syst‚mu CP/M
         mov       di,offset(bdos-mem000)   ; adresa k ulo‘en¡ vzoru syst‚mu
         mov       cx,offset(endvzor-vzor)  ; d‚lka obrazu prozt©ed¡ CP/M
         rep       movsb                    ; ulo‘en¡ vzoru syst‚mu
                                          ;* na‡ten¡ souboru
         mov       si,81h                   ; p©¡kazov˜ © dek
         xor       cx,cx                    ; CX <- 0
         mov       cl,ds:[si-1]             ; po‡et znak– p©¡kaz. © dku
         call      outspc                   ; vypu¨tˆn¡ mezer
         jcxz      konec0                   ; nen¡ ‘ dn˜ znak
         push      si                       ; £schova za‡ tku textu
param2:  call      loadch                   ; na‡ten¡ dal¨¡ho znaku
         jc        param3                   ; konec textu
         cmp       al," "                   ; je platn˜ znak ?
         ja        param2                   ; p©esko‡en¡ platn‚ho znaku
         dec       si                       ; n vrat ukazatele znak–
param3:  mov       byte ptr ds:[si],0       ; ulo‘en¡ koncov‚ho bajtu 0
         inc       si
         pop       dx                       ; n vrat adresy jm‚na souboru
         mov       di,81h                   ; adresa pro ulo‘en¡ p©¡kaz. © dku
         mov       es:[di-1],cl             ; ulo‘en¡ d‚lky textu
         rep       movsb                    ; p©enos textu p©¡kaz. © dku
         mov       ax,3d00h                 ; otev©en¡ souboru pro ‡ten¡
         int       21h                      ; otev©en¡ souboru COM
         mov       bx,ax                    ; identifik tor souboru
         mov       dx,100h                  ; ukl dac¡ adresa souboru
         mov       cx,-100h                 ; maxim ln¡ d‚lka souboru ke ‡ten¡
         push      es
         pop       ds                       ; segment s programem CP/M
         mov       ah,3fh                   ; funkce ‡ten¡ ze souboru
         int       21h                      ; na‡ten¡ souboru
         jc        konec0                   ; chyba ‡ten¡ souboru
         or        ax,ax                    ; po‡et na‡ten˜ch bajt–
         jz        konec0                   ; nebyl ‘ dn˜ bajt - chyba
         mov       ah,3eh                   ; funkce uzav©en¡ souboru
         int       21h                      ; uzav©en¡ identifik toru souboru
         push      cs
         pop       ds

         mov       dx,80h                   ; adresa DMA
         call      setdma                   ; nastaven¡ adresy DMA
         mov       bx,offset(bdos-mem000)-2 ; vrchol z sobn¡ku
         mov       word ptr es:[bx],0       ; n vratov  adresa = 0
         mov       bp,100h                  ; startovac¡ adresa programu CP/M
         call      interpt                  ; interpretace programu

navrat:                                   ;* n vrat z programu CP/M


konec0:  mov       ah,4ch                   ; ukon‡en¡ programu
         int       21h

int23:   or        byte ptr cs:[parbrk],1
         iret

parbrk   db        0

outspc:                                   ;* vypu¨tˆn¡ mezer z p©¡kaz. © dku
         call      loadch                   ; na‡ten¡ dal¨¡ho znaku
         jc        outspc1                  ; nen¡ ji‘ dal¨¡ znak
         cmp       al," "                   ; je mezera nebo ©¡dic¡ znak ?
         jbe       outspc                   ; je mezera nebo ©¡dic¡ znak
         dec       si                       ; n vrat ukazatele znak–
         inc       cx                       ; n vrat ‡¡ta‡e znak–
outspc1: ret

loadch:                                   ;* na‡ten¡ dal¨¡ho znaku
         xor       al,al                    ; n hradn¡ znak konce
         stc                                ; p©¡znak konce © dku
         jcxz      loadch1                  ; nen¡ ji‘ dal¨¡ znak
         lodsb                              ; na‡ten¡ znaku
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         or        al,al                    ; na‡ten˜ znak
loadch1: ret


interpt:                                  ;* krokov n¡ programu
         mov       byte ptr ds:[parbrk],0
         call      zobrreg                  ; zobrazen¡ registr–
interp0: xor       ax,ax
         int       16h                      ; ‡ek n¡ na stisk kl vesy
         cmp       al,"a"
         jb        interp2
         cmp       al,"z"
         ja        interp2
         sub       al,32
interp2: cmp       al,"G"                   ; je start programu ?
         je        interpg
         cmp       al,"T"
         je        interp5
         cmp       al,"Q"
         je        konec0
         cmp       al,"P"
         je        step
         cmp       al,"B"
         jne       interp0
         int       3
         jmp       short interp0

interp5: mov       al,es:[bp]               ; na‡ten¡ instrukce programu
         inc       bp                       ; zv˜¨en¡ ukazatele programu
         inc       byte ptr ds:[regr]       ; inkrementace refresh registru (M1)
         xor       bh,bh                    ; BH <- 0
         mov       bl,al                    ; opera‡n¡ k¢d instrukce
         add       bx,bx                    ; BX * 2
         call      word ptr ds:[tabkod+bx]  ; vyvol n¡ obsluhy instrukce
         jmp       short interpt            ; interpretace dal¨¡ instrukce

step:    mov       al,es:[bp]               ; k¢d instrukce
         cmp       al,0cdh
         je        step1                    ; je CALL a
         and       al,0c7h
         cmp       al,0c4h
         je        step1
         cmp       al,0c7h
         jne       interp5
step1:   call      delins
         add       cx,bp
         mov       ds:[break],cx            ; bod p©eru¨en¡
         jmp       short interp             ; bˆh programu

break    dw        -1                       ; bod p©eru¨en¡

                                            ;
                                            ; BP = ukazatel programu (IP)
                                            ; ES = segment s programem CP/M

interpg: mov       word ptr ds:[break],-1
interp:  cmp       bp,ds:[break]            ; bod p©eru¨en¡
         je        interpt                  ; je p©eru¨en¡
         test      byte ptr ds:[parbrk],1
         jnz       interpt
         mov       al,es:[bp]               ; na‡ten¡ instrukce programu
         inc       bp                       ; zv˜¨en¡ ukazatele programu
         inc       byte ptr ds:[regr]       ; inkrementace refresh registru (M1)
         xor       bh,bh                    ; BH <- 0
         mov       bl,al                    ; opera‡n¡ k¢d instrukce
         add       bx,bx                    ; BX * 2
         call      word ptr ds:[tabkod+bx]  ; vyvol n¡ obsluhy instrukce
         jmp       short interp             ; interpretace dal¨¡ instrukce


zobrreg:                                  ;* zobrazen¡ registr–
         mov       dx,offset txtraf
         call      zobtxt
         mov       ax,ds:[regaf]
         call      zobword
         mov       dx,offset txtrbc
         call      zobtxt
         mov       ax,ds:[regbc]
         call      zobword
         mov       dx,offset txtrde
         call      zobtxt
         mov       ax,ds:[regde]
         call      zobword
         mov       dx,offset txtrhl
         call      zobtxt
         mov       ax,ds:[reghl]
         call      zobword
         mov       dx,offset txtrafx
         call      zobtxt
         mov       ax,ds:[regafx]
         call      zobword
         mov       dx,offset txtrbcx
         call      zobtxt
         mov       ax,ds:[regbcx]
         call      zobword
         mov       dx,offset txtrdex
         call      zobtxt
         mov       ax,ds:[regdex]
         call      zobword
         mov       dx,offset txtrhlx
         call      zobtxt
         mov       ax,ds:[reghlx]
         call      zobword
         call      zobnl

         mov       dx,offset txtrpc
         call      zobtxt
         mov       ax,bp
         call      zobword
         mov       dx,offset txtrsp
         call      zobtxt
         mov       ax,ds:[regsp]
         call      zobword
         mov       dx,offset txtrix
         call      zobtxt
         mov       ax,ds:[regix]
         call      zobword
         mov       dx,offset txtriy
         call      zobtxt
         mov       ax,ds:[regiy]
         call      zobword
         mov       dx,offset txtrri
         call      zobtxt
         mov       ax,ds:[regri]
         call      zobword

         mov       al,ds:[regf]
         mov       dx,offset txts
         call      zobflg
         mov       dx,offset txtz
         call      zobflg
         rcl       al,1
         mov       dx,offset txthc
         call      zobflg
         rcl       al,1
         mov       dx,offset txtpv
         call      zobflg
         mov       dx,offset txtn
         call      zobflg
         mov       dx,offset txtc
         call      zobflg
         call      zobnl

         mov       ax,bp
         call      zobword
         mov       dl,":"
         mov       ah,2
         int       21h
         call      delins                   ; d‚lka instrukce
         push      bp
zobins:  mov       al,es:[bp]
         call      zobbytes
         inc       bp
         loop      zobins
         pop       bp

         call      zobnl
         call      zobnl
         ret

zobflg:  push      ax
         call      zobtxt
         pop       ax
         rcl       al,1
         push      ax
         mov       dl,"0"
         jnc       zobflg1
         mov       dl,"1"
zobflg1: mov       ah,2
         int       21h
         pop       ax
         ret


zobnl:   mov       dx,offset txtnl
zobtxt:  mov       ah,9
         int       21h
         ret

zobbytes:call      zobbyte
         mov       dl," "
         mov       ah,2
         int       21h
         ret

zobword: push      ax
         mov       al,ah
         call      zobbyte
         pop       ax
zobbyte: push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         call      zobhex
         pop       ax
zobhex:  and       al,0fh
         cmp       al,10
         jb        zobhex1
         add       al,7
zobhex1: add       al,"0"
         mov       dl,al
         mov       ah,2
         int       21h
         ret

delins:                                   ;* d‚lka instrukce
                                            ; VSTUP: ES:BP=ukazatel instrukc¡
                                            ; VSTUP: CX=po‡et bajt–
         mov       cx,1                     ; d‚lka = 1 bajt
         mov       al,es:[bp]               ; k¢d instrukce
         cmp       al,40h
         jb        delins2                  ; jsou k¢dy 0-3fh
         cmp       al,0c0h
         jb        delins9                  ; jsou k¢dy 40h-0bfh
                                          ;* k¢dy 0c0h - 0ffh
         mov       cx,3                     ; d‚lka = 3 bajty
         cmp       al,0c3h
         je        delins9                  ; instrukce JP a
         cmp       al,0cdh
         je        delins9                  ; instrukce CALL a
         and       al,0c7h
         cmp       al,0c2h
         je        delins9                  ; instrukce JP podm,a
         cmp       al,0c4h
         je        delins9                  ; instrukce CALL podm,a
         dec       cl                       ; d‚lka = 2 bajty
         cmp       al,0c6h
         je        delins9                  ; aritmetick‚ operace
         mov       al,es:[bp]
         and       al,0f7h
         cmp       al,0d3h
         je        delins9                  ; instrukce OUT, IN
         dec       cl                       ; d‚lka = 1 bajt
         jmp       short delins9
delins2:                                  ;* k¢dy 0 - 03fh
         inc       cl                       ; d‚lka = 2 bajty
         and       al,0f7h
         cmp       al,10h
         je        delins9                  ; instrukce DJNZ a JR
         and       al,0e7h
         cmp       al,20h
         je        delins9                  ; instrukce JR podm,a
         inc       cl                       ; d‚lka = 3 bajty
         cmp       al,22h
         je        delins9                  ; instrukce LD (a),r, LD r,(a)
         mov       al,es:[bp]
         and       al,0cfh
         cmp       al,1                     ; instrukce LD r,a
         je        delins9
         dec       cl                       ; d‚lka = 2 bajty
         and       al,0c7h
         cmp       al,6
         je        delins9                  ; instrukce LD r,d
         dec       cl                       ; d‚lka = 1 bajt
delins9: ret

segcpm   dw        0                        ; segment s programem CP/M

txtraf   db        'AF=$'
txtrbc   db        ' BC=$'
txtrde   db        ' DE=$'
txtrhl   db        ' HL=$'
txtrafx  db        '  AF''=$'
txtrbcx  db        ' BC''=$'
txtrdex  db        ' DE''=$'
txtrhlx  db        ' HL''=$'
txtrpc   db        'PC=$'
txtrsp   db        ' SP=$'
txtrix   db        ' IX=$'
txtriy   db        ' IY=$'
txtrri   db        '  RI=$'

txts     db        ' S=$'
txtz     db        '  Z=$'
txthc    db        '  H=$'
txtpv    db        '  P=$'
txtn     db        '  N=$'
txtc     db        '  C=$'

txtnl    db        13,10,'$'


vzor     label     byte                     ; obraz opera‡n¡ho syst‚mu CP/M
                                          ;* modul BDOS (adresa D000h)
BDOS     db        0,0,0,0,0,0              ; £vodn¡ bajty BDOS
JMPBDOS  db        18h,8 ; JR ADRBDOS       ; instrukce skoku do obsluhy BDOS
         dw        0                        ; adresa obsluhy "Vadn˜ sektor"
         dw        0                        ; adresa obsluhy "Chybn˜ disk"
         dw        0                        ; adresa obsluhy "Disk je R/O"
         dw        0                        ; adresa obsluhy "Soubor je R/O"
adrbdos  db        76h  ; halt              ; proveden¡ obsluhy slu‘eb BDOS
         db        0c9h ; ret               ; n vrat ze slu‘by BDOS

         db        0e00h-18 dup(0)
                                          ;* modul BIOS (adresa DE00h)
BIOS     db        0c3h                     ; instrukce JP BOOT
         dw        $-offset mem000 + 50
         db        0c3h                     ; instrukce JP WBOOT
         dw        $-offset mem000 + 47
         db        0c3h                     ; instrukce JP CONST
         dw        $-offset mem000 + 44
         db        0c3h                     ; instrukce JP CONIN
         dw        $-offset mem000 + 41
         db        0c3h                     ; instrukce JP CONOUT
         dw        $-offset mem000 + 38
         db        0c3h                     ; instrukce JP LIST
         dw        $-offset mem000 + 35
         db        0c3h                     ; instrukce JP PUNCH
         dw        $-offset mem000 + 32
         db        0c3h                     ; instrukce JP READER
         dw        $-offset mem000 + 29
         db        0c3h                     ; instrukce JP HOME
         dw        $-offset mem000 + 26
         db        0c3h                     ; instrukce JP SELDSK
         dw        $-offset mem000 + 23
         db        0c3h                     ; instrukce JP SETTRK
         dw        $-offset mem000 + 20
         db        0c3h                     ; instrukce JP SETSEC
         dw        $-offset mem000 + 17
         db        0c3h                     ; instrukce JP SETDMA
         dw        $-offset mem000 + 14
         db        0c3h                     ; instrukce JP READ
         dw        $-offset mem000 + 11
         db        0c3h                     ; instrukce JP WRITE
         dw        $-offset mem000 + 8
         db        0c3h                     ; instrukce JP LISTST
         dw        $-offset mem000 + 5
         db        0c3h                     ; instrukce JP SECTRN
         dw        $-offset mem000 + 2

endbios  db        0c9h    ; ret

         db        2200h - 17*3 - 1 dup(0)

MEM000   label     byte                     ; za‡ tek pamˆti (adresa 0)
         db        0c3h
         dw        offset(bios-mem000)+3    ; skok do slu‘by BIOS - WBOOT
         db        0                        ; stavov  slabika V/V
         db        3                        ; ‡¡slo implicitn¡ho disku
         db        0c3h
         dw        offset(jmpbdos-mem000)   ; skok do slu‘by BDOS
         db        38h dup(0)               ; obsluhy RST
         db        5ch-40h dup(0)           ; data pro BIOS
fcb      db        80h-5ch dup(0)           ; bloky FCB
dma      db        80h dup(0)               ; oblast dat DMA

endvzor  label     byte                     ; konec vzoru dat CP/M


         include   kod00.asm                ; simulace instrukc¡ 00

         include   cpmbdos.asm              ; slu‘by syst‚mu CP/M - BDOS



tabkod   label     word                     ; tabulka adres k¢d–

         irpc      x,0123456789abcdef       ; cyklus © dku instrukce
          irpc      y,0123456789abcdef      ; cyklus sloupce instrukce
           public  kod&x&&y
           dw        offset kod&x&&y        ; generov n¡ adresy instrukce
          endm
         endm


regaf    label     word                     ; registr AF
regf     db        0                        ; registr F
rega     db        0                        ; registr A

regbc    label     word                     ; registr BC
regc     db        0                        ; registr C
regb     db        0                        ; registr B

regde    label     word                     ; registr DE
rege     db        0                        ; registr E
regd     db        0                        ; registr D

reghl    label     word                     ; registr HL
regl     db        0                        ; registr L
regh     db        0                        ; registr H

regafx   label     word                     ; registr AF'
regfx    db        0                        ; registr F'
regax    db        0                        ; registr A'

regbcx   label     word                     ; registr BC'
regcx    db        0                        ; registr C'
regbx    db        0                        ; registr B'

regdex   label     word                     ; registr DE'
regex    db        0                        ; registr E'
regdx    db        0                        ; registr D'

reghlx   label     word                     ; registr HL'
reglx    db        0                        ; registr L'
reghx    db        0                        ; registr H'

regri    label     word
regi     db        0                        ; registr I
regr     db        0                        ; registr R
regix    dw        0                        ; registr IX
regiy    dw        0                        ; registr IY
regsp    dw        100h                     ; registr SP


         dw        512 dup(?)               ; z sobn¡k
zasobnik label     word                     ; konec z sobn¡ku

konec    label     byte                     ; konec programu

code     ENDS

;zasob    segment   stack
;         dw        512 dup(?)
;zasob    ends


         END       start               ; startovac¡ adresa

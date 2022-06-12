
; *****************************************************************************
;
;                         Simul tor prost©ed¡ CP/M
;
; *****************************************************************************


;------------------------------------------------------------------------------
;                             Programov˜ segment
;------------------------------------------------------------------------------

code     SEGMENT
         ASSUME    cs:code,ds:code

         org       100h

start:                                      ; hlavn¡ tˆlo programu

         mov       bp,100h                  ; startovac¡ adresa programu CP/M
         call      interpt                  ; interpretace programu


         mov       ah,4ch                   ; ukon‡en¡ programu
         int       21h


interpt:                                  ;* krokov n¡ programu
         call      zobrreg                  ; zobrazen¡ registr–
         xor       ax,ax
         int       16h                      ; ‡ek n¡ na stisk kl vesy
         mov       al,es:[bp]               ; na‡ten¡ instrukce programu
         inc       bp                       ; zv˜¨en¡ ukazatele programu
         inc       byte ptr [regr]          ; inkrementace refresh registru (M1)
         xor       bh,bh                    ; BH <- 0
         mov       bl,al                    ; opera‡n¡ k¢d instrukce
         add       bx,bx                    ; BX * 2
         call      word ptr ds:[tabkod+bx]  ; vyvol n¡ obsluhy instrukce
         jmp       short interpt            ; interpretace dal¨¡ instrukce



                                            ;
                                            ; BP = ukazatel programu (IP)
                                            ; ES = segment s programem CP/M


interp:  mov       al,es:[bp]               ; na‡ten¡ instrukce programu
         inc       bp                       ; zv˜¨en¡ ukazatele programu
         inc       byte ptr [regr]          ; inkrementace refresh registru (M1)
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
         mov       dx,offset txthc
         call      zobflg
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
         mov       al,es:[bp]
         call      zobbytes
         mov       al,es:[bp+1]
         call      zobbytes
         mov       al,es:[bp+2]
         call      zobbytes
         mov       al,es:[bp+3]
         call      zobbytes


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

txtraf   db        'AF=$'
txtrbc   db        ' BC=$'
txtrde   db        ' DE=$'
txtrhl   db        ' HL=$'
txtrafx  db        ' AF''=$'
txtrbcx  db        ' BC''=$'
txtrdex  db        ' DE''=$'
txtrhlx  db        ' HL''=$'
txtrpc   db        'PC=$'
txtrsp   db        ' SP=$'
txtrix   db        ' IX=$'
txtriy   db        ' IY=$'
txtrri   db        ' RI=$'

txts     db        '  S=$'
txtz     db        ' Z=$'
txthc    db        ' HC=$'
txtpv    db        ' P/V=$'
txtn     db        ' N=$'
txtc     db        ' C=$'

txtnl    db        13,10,'$'









         include   kod00.asm ; simulace instrukc¡ 00





tabkod   label     word                     ; tabulka adres k¢d–

         irpc      x,0123456789abcdef       ; cyklus © dku instrukce
          irpc      y,0123456789abcdef      ; cyklus sloupce instrukce
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
regsp    dw        0                        ; registr SP


code     ENDS

         END       start               ; startovac¡ adresa

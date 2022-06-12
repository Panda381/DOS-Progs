
Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

KORIG    EQU       5Ch-103h

Start:   jmp       Init

RezidBeg label     near                     ; za‡ tek rezidentu

SegNul   dw        0                        ; segment 0

; -----------------------------------------------------------------------------
;        obsluha INT 08h
; -----------------------------------------------------------------------------

Int08    PROC      FAR

         push      bp                       ; SS:[BP+4] rezerva pro CS
         push      bp                       ; SS:[BP+2] rezerva pro IP

         push      bp                       ; SS:[BP+0] BP
         mov       bp,sp                    ; BP <- ukazatel dat v z sobn¡ku

         push      ax
         push      ds

         mov       ds,cs:[SegNul+KORIG]     ; DS <- 0
         mov       ax,ds:[08*4]
         mov       ss:[bp+2],ax             ; IP
         mov       ax,ds:[08*4+2]
         mov       ss:[bp+4],ax             ; CS

         pop       ds
         pop       ax
         pop       bp
         ret

Int08    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 09h
; -----------------------------------------------------------------------------

Int09    PROC      FAR

         push      bp                       ; SS:[BP+4] rezerva pro CS
         push      bp                       ; SS:[BP+2] rezerva pro IP

         push      bp                       ; SS:[BP+0] BP
         mov       bp,sp                    ; BP <- ukazatel dat v z sobn¡ku

         push      ax
         push      ds

         mov       ds,cs:[SegNul+KORIG]     ; DS <- 0
         mov       ax,ds:[09*4]
         mov       ss:[bp+2],ax             ; IP
         mov       ax,ds:[09*4+2]
         mov       ss:[bp+4],ax             ; CS

         pop       ds
         pop       ax
         pop       bp
         ret

Int09    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 0Ah
; -----------------------------------------------------------------------------

Int0A    PROC      FAR

         push      bp                       ; SS:[BP+4] rezerva pro CS
         push      bp                       ; SS:[BP+2] rezerva pro IP

         push      bp                       ; SS:[BP+0] BP
         mov       bp,sp                    ; BP <- ukazatel dat v z sobn¡ku

         push      ax
         push      ds

         mov       ds,cs:[SegNul+KORIG]     ; DS <- 0
         mov       ax,ds:[0Ah*4]
         mov       ss:[bp+2],ax             ; IP
         mov       ax,ds:[0Ah*4+2]
         mov       ss:[bp+4],ax             ; CS

         pop       ds
         pop       ax
         pop       bp
         ret

Int0A    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 0bh
; -----------------------------------------------------------------------------

Int0b    PROC      FAR

         push      bp                       ; SS:[BP+4] rezerva pro CS
         push      bp                       ; SS:[BP+2] rezerva pro IP

         push      bp                       ; SS:[BP+0] BP
         mov       bp,sp                    ; BP <- ukazatel dat v z sobn¡ku

         push      ax
         push      ds

         mov       ds,cs:[SegNul+KORIG]     ; DS <- 0
         mov       ax,ds:[0bh*4]
         mov       ss:[bp+2],ax             ; IP
         mov       ax,ds:[0bh*4+2]
         mov       ss:[bp+4],ax             ; CS

         pop       ds
         pop       ax
         pop       bp
         ret

Int0b    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 0ch
; -----------------------------------------------------------------------------

Int0c    PROC      FAR

         push      bp                       ; SS:[BP+4] rezerva pro CS
         push      bp                       ; SS:[BP+2] rezerva pro IP

         push      bp                       ; SS:[BP+0] BP
         mov       bp,sp                    ; BP <- ukazatel dat v z sobn¡ku

         push      ax
         push      ds

         mov       ds,cs:[SegNul+KORIG]     ; DS <- 0
         mov       ax,ds:[0ch*4]
         mov       ss:[bp+2],ax             ; IP
         mov       ax,ds:[0ch*4+2]
         mov       ss:[bp+4],ax             ; CS

         pop       ds
         pop       ax
         pop       bp
         ret

Int0c    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 0Dh
; -----------------------------------------------------------------------------

Int0D    PROC      FAR

         push      bp                       ; SS:[BP+4] rezerva pro CS
         push      bp                       ; SS:[BP+2] rezerva pro IP

         push      bp                       ; SS:[BP+0] BP
         mov       bp,sp                    ; BP <- ukazatel dat v z sobn¡ku

         push      ax
         push      ds

         mov       ds,cs:[SegNul+KORIG]     ; DS <- 0
         mov       ax,ds:[0Dh*4]
         mov       ss:[bp+2],ax             ; IP
         mov       ax,ds:[0Dh*4+2]
         mov       ss:[bp+4],ax             ; CS

         pop       ds
         pop       ax
         pop       bp
         ret

Int0D    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 0eh
; -----------------------------------------------------------------------------

Int0e    PROC      FAR

         push      bp                       ; SS:[BP+4] rezerva pro CS
         push      bp                       ; SS:[BP+2] rezerva pro IP

         push      bp                       ; SS:[BP+0] BP
         mov       bp,sp                    ; BP <- ukazatel dat v z sobn¡ku

         push      ax
         push      ds

         mov       ds,cs:[SegNul+KORIG]     ; DS <- 0
         mov       ax,ds:[0eh*4]
         mov       ss:[bp+2],ax             ; IP
         mov       ax,ds:[0eh*4+2]
         mov       ss:[bp+4],ax             ; CS

         pop       ds
         pop       ax
         pop       bp
         ret

Int0e    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 0fh
; -----------------------------------------------------------------------------

Int0f    PROC      FAR

         push      bp                       ; SS:[BP+4] rezerva pro CS
         push      bp                       ; SS:[BP+2] rezerva pro IP

         push      bp                       ; SS:[BP+0] BP
         mov       bp,sp                    ; BP <- ukazatel dat v z sobn¡ku

         push      ax
         push      ds

         mov       ds,cs:[SegNul+KORIG]     ; DS <- 0
         mov       ax,ds:[0fh*4]
         mov       ss:[bp+2],ax             ; IP
         mov       ax,ds:[0fh*4+2]
         mov       ss:[bp+4],ax             ; CS

         pop       ds
         pop       ax
         pop       bp
         ret

Int0f    ENDP

RezidEnd label     near                     ; konec rezidentu

; -----------------------------------------------------------------------------
;        instalace programu
; -----------------------------------------------------------------------------

; ------ £schova prvn¡ho znaku z kl vesnice

Init:    mov       al,ds:[82h]

; ------ p©esun programu dol–

         mov       si,offset RezidBeg
         mov       di,offset RezidBeg+KORIG
         mov       cx,offset(RezidEnd-RezidBeg)
         cld
         rep       movsb                    ; p©esun dol–

; ------ test, zda byl v parametrech zad n znak "A"

         mov       dx,offset InstTxt2
         cmp       al,"a"
         je        Init01
         cmp       al,"A"
         je        Init01

; ------ zobrazen¡ hl ¨en¡

         mov       dx,offset UvTxt
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu

; ------ vstup znaku z kl vesnice

         mov       ah,1
         int       21h

; ------ test potvrzen¡ operace

         cmp       al,"a"
         je        Init0
         cmp       al,"A"
         je        Init0

; ------ od© dkov n¡ textu, konec

         mov       ah,9
         mov       dx,offset CRTxt
         int       21h                      ; od© dkov n¡ textu
         int       20h

; ------ hl ¨en¡ o instalaci

Init0:   mov       dx,offset InstTxt
Init01:  mov       ah,9
         int       21h                      ; zobrazen¡ hl ¨en¡ o instalaci

; ------ p©einstalov n¡ vektor– p©eru¨en¡

         mov       dx,offset Int08+KORIG
         mov       cx,8
Init1:   mov       al,010h
         sub       al,cl
         mov       ah,25h
         int       21h                      ; instalace obsluhy p©eru¨en¡
         add       dx,offset(Int09-Int08)
         loop      Init1

; ------ p©edefinov n¡ ©adi‡e p©eru¨en¡

         cli
         mov       al,10001b                ; hrana, MASTER, ICW4
         out       [20h],al                 ; nastaven¡ ICW1
         jmp       short $+2

         mov       al,008h                  ; z kladn¡ adresa INT x
         out       [21h],al                 ; nastaven¡ ICW2
         jmp       short $+2

         mov       al,4                     ; SLAVE p©ipojen p©es IRQ 2
         out       [21h],al                 ; nastaven¡ ICW3
         jmp       short $+2

         mov       al,1                     ; m¢d 8086, MASTER, EOI, nen¡ buffer
         out       [21h],al                 ; nastaven¡ ICW4
         sti

; ------ uvolnˆn¡ segmentu prost©ed¡

         mov       es,ds:[2ch]
         mov       ah,49h
         int       21h                      ; uvolnˆn¡ prost©ed¡

; ------ instalace do pamˆti

         mov       dx,offset Init+KORIG
         int       27h

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

UvTxt    db        'GDEMOINT V1.0 - premapovani preruseni; (c) Miroslav Nemecek',13,10
         db        ' VAROVANI ..... hardwarova preruseni INT 8 az INT 0Fh (IRQ 0 az IRQ 7)',13,10
         db        '                budou premapovana na preruseni INT B8h az INT BFh !',13,10
         db        ' Chcete pokracovat (A=ano, jina klavesa prerusi operaci) ? $'

InstTxt  db        13,10
InstTxt2 db        'Vektory preruseni INT 8 az INT 0Fh byly premapovany na INT B8h az INT BFh.'
CRTxt    db        13,10,'$'

Code     ENDS
         END       Start

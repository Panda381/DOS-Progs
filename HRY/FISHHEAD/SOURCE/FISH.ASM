
code     segment

         assume    cs:code,ds:code

         org       100h

start:   jmp       init

Siz      dd        600h                     ; velikost souboru

         db        0
         db        200h dup(0)              ; z sobn¡k

init:    push      cs
         pop       ds
         push      cs
         pop       es

         mov       word ptr ds:[Zasob],sp
         mov       word ptr ds:[Zasob+2],ss

         mov       ax,0dh
         int       10h

         push      cs
         pop       ds

         mov       ax,word ptr ds:[Siz]
         mov       dx,word ptr ds:[Siz+2]
         mov       cx,16
         div       cx
         mov       bx,cs
         add       ax,bx
         sub       ax,32000/16 + 2 - 10h

         mov       bp,ax
         mov       ax,0a000h
         mov       es,ax
         xor       di,di
         cld

Init1:   mov       ds,bp

         xor       si,si
         mov       dx,3c4h
         mov       ah,1
init2:   mov       al,2
         out       dx,al
         inc       dx
         mov       al,ah
         out       dx,al
         dec       dx
         mov       cx,320/8*200/2
         push      di
         rep       movsw
         pop       di
         shl       ah,1
         cmp       ah,10h
         jne       init2

         sub       bp,32016/16
         add       di,2000h
         jnz       init1

         push      cs
         pop       ds

         mov       ax,3508h
         int       21h
         mov       word ptr ds:[old08],bx
         mov       word ptr ds:[old08+2],es

         mov       ax,3509h
         int       21h
         mov       word ptr ds:[old09],bx
         mov       word ptr ds:[old09+2],es

         in        al,[21h]
         mov       cs:[Old21],al

         cli

         mov       dx,offset int08
         mov       ax,2508h
         int       21h

         mov       dx,offset Int09
         mov       ax,2509h
         int       21h

         mov       al,not 3
         out       [21h],al

         mov       bp,word ptr ds:[Siz+1]
         sub       bp,1 + (offset(Konec-Start)/16 + 8*(32016/16)) / 16

         mov       al,36h
         out       [43h],al
         mov       al,75
         out       [40h],al
         mov       al,0
         out       [40h],al
         mov       al,92h
         out       [43h],al
         in        al,[61h]
         or        al,2
         out       [61h],al
;         mov       al,50h
;         out       [43h],al

         mov       ax,cs
         mov       cx,offset konec+40
         shr       cx,1
         shr       cx,1
         shr       cx,1
         shr       cx,1
         add       ax,cx
         mov       ds,ax
         mov       si,ax

         xor       bx,bx

         mov       di,offset Int081

         in        al,[61h]
         or        al,1
         mov       byte ptr cs:[Int08+1],al

         xor       cx,cx
         xor       dx,dx

         mov       al,20h
         out       [20h],al

cekint:  sti
         or        bp,bp
         jnz       CekInt

         jmp       Int09

; -----------------------------------------------------------------------------
;        obsluha INT 08h
; -----------------------------------------------------------------------------

Int08:   mov       al,4bh
         out       [61h],al
         dec       ax
         out       [61h],al

         mov       al,ah
         out       [42h],al

         mov       al,20h
;         out       [41h],al
         out       [20h],al
         jmp       di


; ------ vzorek 1 (star˜ a nov˜ bajt v pomˆru 3:1)

Int081:  mov       al,ds:[bx]
         shr       al,1
         shr       al,1
         shr       al,1

         and       al,1eh
         sub       al,16

         jc        Int0812
         add       ch,al
         jnc       Int0813
         mov       ch,255
         jmp       short Int0813

Int0812: neg       al
         sub       ch,al
         jnc       Int0813
         mov       ch,0

Int0813: mov       dh,dl                    ; £schova star‚ho bajtu
         mov       dl,ch                    ; nov˜ bajt

         mov       ah,0
         mov       al,dh                    ; star˜ bajt
         shl       ax,1                     ; star˜ bajt * 2
         add       al,dh
         adc       ah,0                     ; star˜ bajt * 3
         add       al,dl
         adc       ah,0                     ; pomˆr 3:1
         shr       ax,1
         shr       ax,1

         cmp       al,74
         jbe       Int0814
         mov       al,74
         dec       ch

Int0814: or        al,al
         jnz       Int0815
         inc       ax

Int0815: mov       ah,al                    ; pomˆr 3:1
         mov       di,offset Int082
         iret


; ------ vzorek 2 (star˜ a nov˜ bajt v pomˆru 2:2)

Int082:  mov       al,dh                    ; star˜ bajt
         add       al,dl                    ; + nov˜ bajt
         rcr       al,1                     ; pomˆr 2:2

         cmp       al,74
         jbe       Int0824
         mov       al,74

Int0824: or        al,al
         jnz       Int0825
         inc       ax

Int0825: mov       ah,al                    ; pomˆr 2:2
         mov       di,offset Int083
         iret

; ------ vzorek 3 (star˜ a nov˜ bajt v pomˆru 3:1)

Int083:  mov       ah,0
         mov       al,dl                    ; nov˜ bajt
         shl       ax,1                     ; nov˜ bajt * 2
         add       al,dl
         adc       ah,0                     ; nov˜ bajt * 3
         add       al,dh
         adc       ah,0                     ; pomˆr 1:3
         shr       ax,1
         shr       ax,1

         cmp       al,74
         jbe       Int0834
         mov       al,74

Int0834: or        al,al
         jnz       Int0835
         inc       ax

Int0835: mov       ah,al                    ; pomˆr 1:3
         mov       di,offset Int084
         iret

; ------ vzorek 4 (pouze nov˜ bajt)

Int084:  mov       ah,dl
         cmp       ah,74
         jbe       Int0844
         mov       ah,74

Int0844: or        ah,ah
         jnz       Int0845
         inc       ah

Int0845: mov       di,offset Int085
         iret


; ------ vzorek 5 (star˜ a nov˜ bajt v pomˆru 3:1)

Int085:  mov       al,ds:[bx]

         shl       al,1
         and       al,1eh
         sub       al,14

         jc        Int0852
         add       ch,al
         jnc       Int0853
         mov       ch,255
         jmp       short Int0853

Int0852: neg       al
         sub       ch,al
         jnc       Int0853
         mov       ch,0

Int0853: mov       dh,dl                    ; £schova star‚ho bajtu
         mov       dl,ch                    ; nov˜ bajt

         mov       ah,0
         mov       al,dh                    ; star˜ bajt
         shl       ax,1                     ; star˜ bajt * 2
         add       al,dh
         adc       ah,0                     ; star˜ bajt * 3
         add       al,dl
         adc       ah,0                     ; pomˆr 3:1
         shr       ax,1
         shr       ax,1

         cmp       al,74
         jbe       Int0854
         mov       al,74
         dec       ch

Int0854: or        al,al
         jnz       Int0855
         inc       ax

Int0855: mov       ah,al                    ; pomˆr 3:1
         mov       di,offset Int086
         iret


; ------ vzorek 6 (star˜ a nov˜ bajt v pomˆru 2:2)

Int086:  mov       al,dh                    ; star˜ bajt
         add       al,dl                    ; + nov˜ bajt
         rcr       al,1                     ; pomˆr 2:2

         cmp       al,74
         jbe       Int0864
         mov       al,74

Int0864: or        al,al
         jnz       Int0865
         inc       ax

Int0865: mov       ah,al                    ; pomˆr 2:2
         mov       di,offset Int087
         iret

; ------ vzorek 7 (star˜ a nov˜ bajt v pomˆru 3:1)

Int087:  mov       ah,0
         mov       al,dl                    ; nov˜ bajt
         shl       ax,1                     ; nov˜ bajt * 2
         add       al,dl
         adc       ah,0                     ; nov˜ bajt * 3
         add       al,dh
         adc       ah,0                     ; pomˆr 1:3
         shr       ax,1
         shr       ax,1

         cmp       al,74
         jbe       Int0874
         mov       al,74

Int0874: or        al,al
         jnz       Int0875
         inc       ax

Int0875: mov       ah,al                    ; pomˆr 1:3
         mov       di,offset Int088
         iret

; ------ vzorek 8 (pouze nov˜ bajt)

Int088:  mov       ah,dl
         cmp       ah,74
         jbe       Int0884
         mov       ah,74

Int0884: or        ah,ah
         jnz       Int0885
         inc       ah

Int0885: mov       di,offset Int081

         inc       bl
         jz        Int089                   ; zv˜¨en¡ adresy
         iret

Int089:  add       si,16
         mov       ds,si

         dec       byte ptr cs:[citpic]
         jnz       int0894

         push      ax
         push      bx
         push      dx

         mov       bx,cs:[citukaz]
         mov       ax,cs:[bx+2]
         mov       cs:[citpic],ax
         mov       bx,cs:[bx]
         add       word ptr cs:[citukaz],4

         mov       dx,3d4h
         mov       al,0ch
         out       dx,al
         inc       dx
         mov       al,bh
         out       dx,al

         pop       dx
         pop       bx
         pop       ax

Int0894:
         dec       bp
         js        Int0892
         iret

Int0892: xor       bp,bp
         iret

; -----------------------------------------------------------------------------
;        obsluha INT 09h
; -----------------------------------------------------------------------------

int09:   cli

         mov       ss,word ptr cs:[Zasob+2]
         mov       sp,word ptr cs:[Zasob]

         mov       al,0ffh
         out       [21h],al

;         mov       al,54h
;         out       [43h],al
;         mov       al,12h
;         out       [41h],al
         mov       al,36h
         out       [43h],al
         mov       al,0
         out       [40h],al
         out       [40h],al
         mov       al,0b6h
         out       [43h],al
         mov       ax,533h
         out       [42h],al
         mov       al,ah
         out       [42h],al

         mov       al,0adh
         out       [64h],al                 ; vysl n¡ povelu-uzam‡en¡ kl vesnice

         mov       cx,200
         loop      $

         in        al,[60h]

         mov       cx,200
         loop      $

         mov       al,0aeh
         out       [64h],al                 ; vysl n¡ povelu-uvolnˆn¡ kl vesnice


         mov       al,0c8h
         out       [61h],al

         jmp       $+2
         jmp       $+2
         jmp       $+2
         jmp       $+2
         jmp       $+2

         mov       al,48h
         out       [61h],al

         mov       al,20h
         out       [20h],al

         push      cs
         pop       ds
         lds       dx,ds:[Old08]
         mov       ax,2508h
         int       21h

         push      cs
         pop       ds
         lds       dx,ds:[Old09]
         mov       ax,2509h
         int       21h

         mov       al,cs:[old21]
         out       [21h],al

         sti
         int       09h

;         mov       al,20h
;         out       [20h],al

         mov       ah,1
         int       16h
         jz        intret
         mov       ah,0
         int       16h

intret:  mov       ax,3
         int       10h

         mov       dx,offset LicTxt
         push      cs
         pop       ds
         mov       ah,9
         int       21h

         mov       ax,4c00h
         int       21h

         EVEN

zasob    dd        0

old08    dd        0
old09    dd        0
old21    db        0

citpic   dw        55                       ; ‡¡ta‡ jednoho obr zku
citukaz  dw        tabcit                   ; ukazatel v tabulce ‡¡ta‡–

tabcit:

; ------ ref1

         dw        2000h,3
         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4
         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4
         dw        4000h,1                  ; "RO-"
         dw        2000h,1
         dw        4000h,1                  ; "-LY"
         dw        2000h,1
         dw        4000h,1                  ; "PO-"
         dw        2000h,1
         dw        4000h,1                  ; "-LY"
         dw        2000h,3
         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4

         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,3
         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4
         dw        4000h,1                  ; "EAT"
         dw        2000h,1
         dw        4000h,1                  ; "THEM"
         dw        2000h,1
         dw        4000h,1                  ; "UP"
         dw        2000h,5
         dw        4000h,1                  ; "YUM"
         dw        2000h,5

; ------ ref2

         dw        2000h,3
         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4
         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4
         dw        4000h,1                  ; "RO-"
         dw        2000h,1
         dw        4000h,1                  ; "-LY"
         dw        2000h,1
         dw        4000h,1                  ; "PO-"
         dw        2000h,1
         dw        4000h,1                  ; "-LY"
         dw        2000h,3
         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4

         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,3
         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4
         dw        4000h,1                  ; "EAT"
         dw        2000h,1
         dw        4000h,1                  ; "THEM"
         dw        2000h,1
         dw        4000h,1                  ; "UP"
         dw        2000h,5
         dw        4000h,1                  ; "YUM"
         dw        2000h,8

; ------ 1)

         dw        6000h,71

; ------ ref3

         dw        2000h,3
         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4
         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4
         dw        4000h,1                  ; "RO-"
         dw        2000h,1
         dw        4000h,1                  ; "-LY"
         dw        2000h,1
         dw        4000h,1                  ; "PO-"
         dw        2000h,1
         dw        4000h,1                  ; "-LY"
         dw        2000h,3
         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4

         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,3
         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4
         dw        4000h,1                  ; "EAT"
         dw        2000h,1
         dw        4000h,1                  ; "THEM"
         dw        2000h,1
         dw        4000h,1                  ; "UP"
         dw        2000h,5
         dw        4000h,1                  ; "YUM"
         dw        2000h,9

; ------ 2)

         dw        8000h,71

; ------ ref4

         dw        2000h,2
         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4
         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4
         dw        4000h,1                  ; "RO-"
         dw        2000h,1
         dw        4000h,1                  ; "-LY"
         dw        2000h,1
         dw        4000h,1                  ; "PO-"
         dw        2000h,1
         dw        4000h,1                  ; "-LY"
         dw        2000h,3
         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4

         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,3
         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4
         dw        4000h,1                  ; "EAT"
         dw        2000h,1
         dw        4000h,1                  ; "THEM"
         dw        2000h,1
         dw        4000h,1                  ; "UP"
         dw        2000h,5
         dw        4000h,1                  ; "YUM"
         dw        2000h,9

; ------ 3)

         dw        0a000h,70

; ------ ref5

         dw        2000h,2
         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4
         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4
         dw        4000h,1                  ; "RO-"
         dw        2000h,1
         dw        4000h,1                  ; "-LY"
         dw        2000h,1
         dw        4000h,1                  ; "PO-"
         dw        2000h,1
         dw        4000h,1                  ; "-LY"
         dw        2000h,3
         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4

         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,3
         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4
         dw        4000h,1                  ; "EAT"
         dw        2000h,1
         dw        4000h,1                  ; "THEM"
         dw        2000h,1
         dw        4000h,1                  ; "UP"
         dw        2000h,5
         dw        4000h,1                  ; "YUM"
         dw        2000h,9

; ------ 4)

         dw        0c000h,71

; ------ ref6

         dw        2000h,2
         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4
         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4
         dw        4000h,1                  ; "RO-"
         dw        2000h,1
         dw        4000h,1                  ; "-LY"
         dw        2000h,1
         dw        4000h,1                  ; "PO-"
         dw        2000h,1
         dw        4000h,1                  ; "-LY"
         dw        2000h,3
         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4

         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,3
         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4
         dw        4000h,1                  ; "EAT"
         dw        2000h,1
         dw        4000h,1                  ; "THEM"
         dw        2000h,1
         dw        4000h,1                  ; "UP"
         dw        2000h,5
         dw        4000h,1                  ; "YUM"
         dw        2000h,9

; ------ 5)

         dw        0e000h,70

; ------ ref7

         dw        2000h,2
         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4
         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4
         dw        4000h,1                  ; "RO-"
         dw        2000h,1
         dw        4000h,1                  ; "-LY"
         dw        2000h,1
         dw        4000h,1                  ; "PO-"
         dw        2000h,1
         dw        4000h,1                  ; "-LY"
         dw        2000h,3
         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4

         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,3
         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4
         dw        4000h,1                  ; "EAT"
         dw        2000h,1
         dw        4000h,1                  ; "THEM"
         dw        2000h,1
         dw        4000h,1                  ; "UP"
         dw        2000h,5
         dw        4000h,1                  ; "YUM"
         dw        2000h,9

; ------ ref8

         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4
         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4
         dw        4000h,1                  ; "RO-"
         dw        2000h,1
         dw        4000h,1                  ; "-LY"
         dw        2000h,1
         dw        4000h,1                  ; "PO-"
         dw        2000h,1
         dw        4000h,1                  ; "-LY"
         dw        2000h,3
         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4

         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,3
         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4
         dw        4000h,1                  ; "EAT"
         dw        2000h,1
         dw        4000h,1                  ; "THEM"
         dw        2000h,1
         dw        4000h,1                  ; "UP"
         dw        2000h,5
         dw        4000h,1                  ; "YUM"
         dw        2000h,4
         dw        4000h,1                  ;  ... "YUM"
         dw        2000h,4

; ------ ref9

         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4
         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4
         dw        4000h,1                  ; "RO-"
         dw        2000h,1
         dw        4000h,1                  ; "-LY"
         dw        2000h,1
         dw        4000h,1                  ; "PO-"
         dw        2000h,1
         dw        4000h,1                  ; "-LY"
         dw        2000h,3
         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4

         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,3
         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4
         dw        4000h,1                  ; "EAT"
         dw        2000h,1
         dw        4000h,1                  ; "THEM"
         dw        2000h,1
         dw        4000h,1                  ; "UP"
         dw        2000h,5
         dw        4000h,1                  ; "YUM"
         dw        2000h,8

; ------ ref10

         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4
         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4
         dw        4000h,1                  ; "RO-"
         dw        2000h,1
         dw        4000h,1                  ; "-LY"
         dw        2000h,1
         dw        4000h,1                  ; "PO-"
         dw        2000h,1
         dw        4000h,1                  ; "-LY"
         dw        2000h,3
         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4

         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,3
         dw        4000h,1                  ; "FISH"
         dw        2000h,3
         dw        4000h,1                  ; "HEADS"
         dw        2000h,4
         dw        4000h,1                  ; "EAT"
         dw        2000h,1
         dw        4000h,1                  ; "THEM"
         dw        2000h,1
         dw        4000h,1                  ; "UP"
         dw        2000h,5
         dw        4000h,1                  ; "YUM"
         dw        2000h,8

         dw        0000h,-1

LicTxt   db        'FISHHEADS - (c) Miroslav Nemecek 1993',13,10
         db        '     GOLEM Roznov pod Radhostem',13,10
         db        '            - FREEWARE -',13,10
         db        '$'
                                    ; konec programu

konec    label     byte

code     ends
                                            ; zde za‡¡naj¡ data
         end       start

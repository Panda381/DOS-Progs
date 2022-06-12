
Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ £vodn¡ text

Start:   mov       dx,offset UvTxt          ; £vodn¡ text
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu

; ------ £schova INT 08h

         mov       ax,3508h
         int       21h
         mov       word ptr ds:[Old08],bx
         mov       word ptr ds:[Old08+2],es

; ------ £schova INT 09h

         mov       ax,3509h
         int       21h
         mov       word ptr ds:[Old09],bx
         mov       word ptr ds:[Old09+2],es

; ------ proveden¡ mˆ©en¡

         call      InstInt                  ; instalace obsluh p©eru¨en¡
Start2:  sti
         test      byte ptr ds:[Param],1+8  ; konec mˆ©en¡ ?
         jz        Start2                   ; ‡ek n¡ na konec mˆ©en¡
         call      DInsInt                  ; n vrat obsluh p©eru¨en¡

; ------ p©eru¨en¡ operace

         mov       dx,offset PrerTxt        ; text - je p©eru¨en¡
         test      byte ptr ds:[Param],1    ; p©eru¨en¡ ?
         jnz       Start9                   ; p©eru¨en¡ operace

; ------ zobrazen¡ v˜zvy k uvolnˆn¡ mezern¡ku

         mov       dx,offset KonecTxt
         mov       ah,9
         int       21h

; ------ ‡ek n¡ na uvolnˆn¡ mezern¡ku

         call      InstInt                  ; instalace obsluh p©eru¨en¡
Start4:  sti
         test      byte ptr ds:[Param],1    ; p©eru¨en¡ ?
         jz        Start4                   ; ‡ek n¡ na p©eru¨en¡
         call      DInsInt                  ; n vrat obsluh p©eru¨en¡

; ------ £vodn¡ ‡ st textu

         mov       dx,offset MerTxt1
         mov       ah,9
         int       21h

; ------ zobrazen¡ £vodn¡ prodlevy

         mov       ax,ds:[Citac1]
         xor       dx,dx
         mov       cx,375
         div       cx
         xchg      ax,cx
         mov       ax,ds:[Citac1]
         sub       ax,cx                    ; korekce
         call      DispDNm                  ; zobrazen¡ prodlevy

; ------ druh  ‡ st textu

         mov       dx,offset MerTxt2
         mov       ah,9
         int       21h

; ------ zobrazen¡ rychlosti

         mov       ax,-1
         mov       cx,ds:[Citac2]
         cmp       cx,16
         jbe       Start5
         mov       ax,4cb1h                 ; 1002673 LOW
         mov       dx,0fh                   ; 1002673 HIGH
         div       cx
Start5:  call      DispDNm

; ------ zobrazen¡ konce textu

         mov       dx,offset MerTxt3
Start9:  mov       ah,9
         int       21h                      ; zobrazen¡ textu

; ------ vypr zdnˆn¡ bufferu kl vesnice

Start92: mov       ah,1
         int       16h
         jz        Start93
         mov       ah,0
         int       16h
         jmp       short Start92

Start93: int       20h

; -----------------------------------------------------------------------------
;        instalace obsluh p©eru¨en¡
; -----------------------------------------------------------------------------

InstInt  PROC      NEAR

         cli

; ------ instalace INT 08h

         mov       dx,offset Int08
         mov       ax,2508h
         int       21h

; ------ instalace INT 09h

         mov       dx,offset Int09
         mov       ax,2509h
         int       21h

; ------ inicializace ‡¡ta‡e INT 08h

         cli
         mov       al,34h
         out       [43h],al                 ; povel pro nastaven¡ hodin
         mov       al,119                   ; dˆlic¡ konstanta pro hodiny LOW
         out       [40h],al                 ; dˆlic¡ konstanta pro hodiny LOW
         mov       al,0
         out       [40h],al                 ; vy¨¨¡ bajt dˆlic¡ konstanty
         sti
         ret

InstInt  ENDP

; -----------------------------------------------------------------------------
;        n vrat obsluh p©eru¨en¡
; -----------------------------------------------------------------------------

DInsInt  PROC      NEAR

; ------ standardn¡ nastaven¡ hodin

         cli
         mov       al,34h
         out       [43h],al                 ; povel
         mov       al,0
         out       [40h],al                 ; konstanta - ni‘¨¡ bajt
         out       [40h],al                 ; konstanta - vy¨¨¡ bajt

; ------ n vrat obsluhy INT 08h

         push      ds
         lds       dx,ds:[Old08]
         mov       ax,2508h
         int       21h
         pop       ds

; ------ n vrat obsluhy INT 09h

         push      ds
         lds       dx,ds:[Old09]
         mov       ax,2509h
         int       21h
         pop       ds

; ------ n vrat p©eru¨en¡ INT 08h

         xor       ax,ax
         xchg      ax,word ptr ds:[Citac]   ; celkov  doba INT 08h
         xor       dx,dx
         xchg      dx,word ptr ds:[Citac+2]
         cmp       dx,550
         jbe       DInsInt2
         mov       dx,550
DInsInt2:mov       bx,551
         div       bx
         xchg      ax,cx
         jcxz      DInsInt4
DInsInt3:sti
         int       08h
         loop      DInsInt3
DInsInt4:sti
         ret

DInsInt  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ desetinn‚ho ‡¡sla AX (1 desetinn‚ m¡sto)
; -----------------------------------------------------------------------------

DispDNm  PROC      NEAR

         push      ax
         push      bx
         push      dx

         xor       dx,dx
         mov       bx,10
         div       bx
         call      DispNum                  ; zobrazen¡ cel‚ ‡ sti ‡¡sla

         mov       al,"."
         call      DispChr

         xchg      ax,dx
         call      DispNum

         pop       dx
         pop       bx
         pop       ax
         ret

DispDNm  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ‡¡sla AX
; -----------------------------------------------------------------------------

DispNum  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx

; ------ dek¢dov n¡ ‡¡sla AX

         xor       cx,cx                    ; ‡¡ta‡ znak–
         mov       bx,10
DispNum1:xor       dx,dx
         div       bx
         push      dx
         inc       cx
         or        ax,ax
         jnz       DispNum1

; ------ zobrazen¡ ‡¡sla

DispNum2:pop       ax
         add       al,"0"
         call      DispChr
         loop      DispNum2

; ------ n vrat registr–

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispNum  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku AL
; -----------------------------------------------------------------------------

DispChr  PROC      NEAR

         push      ax
         push      dx

         xchg      ax,dx
         mov       ah,2
         int       21h

         pop       dx
         pop       ax
         ret

DispChr  ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 08h - ‡¡t n¡ doby mˆ©en¡
; -----------------------------------------------------------------------------

Int08    PROC      FAR

; ------ £schova registr–

         push      ax

; ------ ‡¡t n¡ celkov‚ doby INT 08h

         inc       word ptr cs:[Citac]
         jnz       Int081
         inc       word ptr cs:[Citac+2]

; ------ test, zda je konec mˆ©en¡

Int081:  test      byte ptr cs:[Param],1+8  ; byl t©et¡ znak mezery/p©eru¨en¡ ?
         jnz       Int089                   ; byl ji‘ t©et¡ znak mezery/p©eru¨.

; ------ ‡¡t n¡ doby druh‚ kl vesy

         test      byte ptr cs:[Param],4    ; byl druh˜ znak mezery ?
         jz        Int083                   ; nebyl druh˜ znak mezery
         cmp       word ptr cs:[Citac2],-1  ; je p©ete‡en¡ doby ?
         je        Int089                   ; je p©ete‡en¡ doby
         inc       word ptr cs:[Citac2]     ; zv˜¨en¡ ‡¡ta‡e doby druh‚ho znaku
         jmp       short Int089

; ------ ‡¡t n¡ doby prvn¡ kl vesy

Int083:  test      byte ptr cs:[Param],2    ; byl prvn¡ znak mezery ?
         jz        Int089                   ; nebyl prvn¡ znak mezery
         cmp       word ptr cs:[Citac1],-1  ; je p©ete‡en¡ doby ?
         je        Int089                   ; je p©ete‡en¡ doby
         inc       word ptr cs:[Citac1]     ; zv˜¨en¡ ‡¡ta‡e doby prvn¡ho znaku

; ------ uvolnˆn¡ ©adi‡e p©eru¨en¡

Int089:  mov       al,20h
         out       [20h],al                 ; uvolnˆn¡ ©adi‡e p©eru¨en¡

; ------ n vrat registr–

         pop       ax
         iret

Int08    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 09h - test portu kl vesnice
; -----------------------------------------------------------------------------

Int09    PROC      FAR

; ------ £schova registr–

         push      ax

; ------ uvolnˆn¡ ©adi‡e p©eru¨en¡

         mov       al,20h
         out       [20h],al                 ; uvolnˆn¡ ©adi‡e p©eru¨en¡

; ------ uzam‡en¡ kl vesnice

         call      Cekej09                  ; ‡ek n¡ na p©ipravenost kl vesnice
         mov       al,0adh
         out       [64h],al                 ; vysl n¡ povelu-uzam‡en¡ kl vesnice

; ------ ‡ten¡ k¢du kl vesy

         call      Cekej09                  ; ‡ek n¡ na p©ipravenost kl vesnice
         in        al,[60h]

; ------ k¢d mezery

         test      byte ptr cs:[Param],1    ; je p©eru¨en¡ operace ?
         jnz       Int099                   ; p©eru¨en¡ operace
         cmp       al,39h
         je        Int092                   ; mezera

; ------ jin  kl vesa

         cmp       al,39h+80h
         je        Int098                   ; uvolnˆn¡ mezery
         test      al,80h
         jnz       Int099                   ; uvolnˆn¡ kl vesy
         jmp       short Int098             ; stisk jin‚ kl vesy

; ------ prvn¡ k¢d mezery

Int092:  test      byte ptr cs:[Param],2    ; byl prvn¡ k¢d mezery ?
         jnz       Int093                   ; byl ji‘ prvn¡ k¢d mezery
         or        byte ptr cs:[Param],2    ; p©¡znak prvn¡ho k¢du mezery
         jmp       short Int099

; ------ druh˜ k¢d mezery

Int093:  test      byte ptr cs:[Param],4    ; byl druh˜ k¢d mezery ?
         jnz       Int094                   ; byl ji‘ druh˜ k¢d mezery
         or        byte ptr cs:[Param],4    ; druh˜ k¢d mezery
         jmp       short Int099

; ------ dal¨¡ k¢d mezery

Int094:  cmp       byte ptr cs:[CitChr],0   ; byly ji‘ v¨echny znaky ?
         je        Int099
         dec       byte ptr cs:[CitChr]     ; ‡¡ta‡ znak–
         jnz       Int099
         or        byte ptr cs:[Param],8    ; p©¡znak t©et¡ho k¢du mezery
         jmp       short Int099

; ------ jin  kl vesa nebo uvolnˆn¡ mezern¡ku

Int098:  or        byte ptr cs:[Param],1    ; jin  kl vesa nebo uvolnˆn¡

; ------ uvolnˆn¡ kl vesnice

Int099:  call      Cekej09                  ; ‡ek n¡ na p©ipravenost kl vesnice
         mov       al,0aeh
         out       [64h],al                 ; vysl n¡ povelu-uvolnˆn¡ kl vesnice

; ------ n vrat registr–

         pop       ax
         iret

Int09    ENDP

; -----------------------------------------------------------------------------
;        ‡ek n¡ na p©ipravenost kl vesnice
; -----------------------------------------------------------------------------

Cekej09  PROC      NEAR

         push      ax
         push      cx
         mov       cx,5000
Cekej091:in        al,[64h]
         test      al,2
         loopnz    Cekej091
         pop       cx
         pop       ax
         ret

Cekej09  ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

Param    db        0                        ; parametry
                                            ;  bit 0: 1=uvolnˆn¡/jin  kl vesa
                                            ;  bit 1: 1=prvn¡ znak mezery
                                            ;  bit 2: 1=druh˜ znak mezery
                                            ;  bit 3: 1=posledn¡ znak mezery

Citac    dd        0                        ; ‡¡ta‡ celkov‚ doby INT 08h

CitChr   db        10                       ; ‡¡ta‡ znak– z kl vesnice

Citac1   dw        0                        ; ‡¡ta‡ doby znaku 1
Citac2   dw        0                        ; ‡¡ta‡ doby znaku 2

UvTxt    db        'TESTRATE V1.0 - test rychlosti klavesnice; (c) Miroslav Nemecek',13,10
         db        'Stisknete klavesu MEZERNIKU a ponechte ji stisknutou: $'

PrerTxt  db        13,'Operace mereni rychlosti klavesnice prerusena ...    ',13,10,'$'
KonecTxt db        13,'Konec mereni - muzete uvolnit klavesu MEZERNIKU ...   $'

MerTxt1  db        13,'Uvodni prodleva: $'
MerTxt2  db        ' ms, rychlost generovani: $'
MerTxt3  db        ' znaku za sekundu.',13,10,'$'

Old09    dd        ?                        ; adresa INT 09h
Old08    dd        ?                        ; adresa INT 08h

Code     ENDS
         END       Start

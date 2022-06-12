

; *****************************************************************************
;
;                               A N I M I
;
;                     anima‡n¡ program - interpreter
;
; *****************************************************************************


Code     SEGMENT
         ASSUME    cs:Code,ds:Code,ss:Stack

         dw        SEG SegProg              ; segment anima‡n¡ho programu

         db        'ANIM - pocitacova animace; (c) Miroslav Nemecek',13,10

Start:

; ------ p©edefinov n¡ z sobn¡ku na vrchol pamˆti

         cli                                ; z kaz p©eru¨en¡
         mov       ax,ds:[2]                ; segment s koncem pamˆti
         sub       ax,1000h                 ; rezerva 64 KB
         mov       ss,ax                    ; segment z sobn¡ku
         mov       sp,0fff8h                ; offset z sobn¡ku
         sti                                ; povolen¡ p©eru¨en¡

; ------ inicializace segmentov˜ch registr–

         mov       ax,cs                    ; datov˜ segment
         mov       ds,ax                    ; DS <- datov˜ segment
         mov       ds:[SegPSP],es           ; £schova segmentu PSP
         mov       es,ax                    ; datov˜ segment

; ------ nastaven¡ p©¡znaku karty EGA

         mov       ah,12h                   ; funkce poskytnut¡ informac¡ EGA
         mov       bx,05e10h                ; podfunkce informac¡
         int       10h                      ; poskytnut¡ informac¡ EGA/VGA
         cmp       bh,2                     ; m¢d displeje 0 nebo 1
         jae       Start2                   ; chyba - neplatn˜ obsah registru
         cmp       bl,5                     ; maxim ln¡ velikost pamˆti 1 MB
         jbe       Start3                   ; velikost pamˆti OK
Start2:  mov       byte ptr ds:[EgaVga],0   ; p©¡znak, ‘e nen¡ karta EGA/VGA

; ------ £schova videom¢du

Start3:  mov       ah,0fh
         call      Int10                    ; poskytnut¡ aktivn¡ho videom¢du
         mov       ds:[OldVMod],al          ; £schova aktivn¡ho videom¢du

; ------ ur‡en¡ segment– jednotliv˜ch blok–

         push      es
         mov       cl,4                     ; po‡et rotac¡ pro p©evod
         mov       ax,SEG SegProg           ; segment s daty programu
         mov       es,ax                    ; segment datov‚ho modulu
         mov       bx,es:[0]                ; d‚lka datov‚ho modulu
         add       bx,15                    ; zaokrouhlen¡ na odstavec
         shr       bx,cl                    ; p©epo‡et na odstavce
         add       ax,bx                    ; adresa segmentu s programem
         mov       ds:[ProgMem],ax          ; segment s programem
         mov       es,ax                    ; segment s programem
         mov       bx,es:[0]                ; d‚lka segmentu s programem
         add       bx,15                    ; zaokrouhlen¡ na odstavec
         shr       bx,cl                    ; p©epo‡et na odstavce
         add       ax,bx                    ; adresa segmentu s objekty
         mov       ds:[ObjMem],ax           ; segment s objekty
         pop       es

; ------ ur‡en¡ adresy konce tabulky blok–

         mov       word ptr ds:[TopMem],-1  ; p©ednastaven¡ - zru¨en¡ konce
         xor       ax,ax                    ; hledan˜ blok 0
         call      SrcObj
         mov       ds:[TopMem],dx           ; nov˜ konec pamˆti

; ------ definice obsluhy u‘ivatelsk‚ho p©eru¨en¡ Ctrl-Break

         push      ds
         push      cs
         pop       ds
         mov       ax,2523h
         mov       dx,offset Prerus
         int       21h                      ; adresa p©eru¨en¡ programu
         pop       ds

; ------ definice obsluhy hodin INT 08h

         push      es
         mov       ax,3508h
         int       21h
         mov       word ptr cs:[Old08],bx
         mov       word ptr cs:[Old08+2],es
         pop       es
         push      ds
         push      cs
         pop       ds
         mov       dx,offset Int08
         mov       ax,2508h
         int       21h
         pop       ds

; ------ definice obsluhy chyby dˆlen¡m INT 00h

         push      es
         mov       ax,3500h
         int       21h
         mov       word ptr cs:[Old00],bx
         mov       word ptr cs:[Old00+2],es
         pop       es
         push      ds
         push      cs
         pop       ds
         mov       dx,offset Int00
         mov       ax,2500h
         int       21h
         pop       ds

; ------ definice obsluhy chyby dˆlen¡m INT 1Bh

         push      es
         mov       ax,351Bh
         int       21h
         mov       word ptr cs:[Old1B],bx
         mov       word ptr cs:[Old1B+2],es
         pop       es
         push      ds
         push      cs
         pop       ds
         mov       dx,offset Int1B
         mov       ax,251Bh
         int       21h
         pop       ds

; ------ inicializace gener toru n hody

         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       ax,ds:[46ch]
         mov       dx,ds:[46eh]
         pop       ds
         mov       word ptr ds:[RandNum],ax
         mov       word ptr ds:[RandNum+2],dx

; ------ interpretace programu

         push      ds
         mov       ds,ds:[ProgMem]          ; segment s programem
         mov       ax,ds:[2]                ; startovac¡ adresa programu
         pop       ds
         mov       ds:[ProgUkaz],ax         ; inicializace ukazatele programu
         call      Anim                     ; interpretace programu (procedury)
         mov       byte ptr ds:[RetKod],al  ; n vratov˜ k¢d programu

; ------ ukon‡en¡ programu (nebo p©eru¨en¡)

Prerus:  mov       ax,cs                    ; datov˜ segment
         mov       ds,ax                    ; datov˜ segment
         mov       al,ds:[OldVMod]          ; p–vodn¡ videom¢d
         mov       ah,0
         call      Int10                    ; n vrat videom¢du

; ------ n vrat obsluhy p©eru¨en¡ INT 08h

Prerus2: push      ds
         lds       dx,cs:[Old08]
         mov       ax,2508h
         int       21h                      ; n vrat adresy obsluhy INT 08h
         pop       ds

; ------ n vrat obsluhy p©eru¨en¡ INT 00h

         push      ds
         lds       dx,cs:[Old00]
         mov       ax,2500h
         int       21h                      ; n vrat adresy obsluhy INT 00h
         pop       ds

; ------ n vrat obsluhy p©eru¨en¡ INT 1Bh

         push      ds
         lds       dx,cs:[Old1B]
         mov       ax,251Bh
         int       21h                      ; n vrat adresy obsluhy INT 1Bh
         pop       ds

; ------ vypnut¡ zvukov‚ho gener toru

         in        al,[61h]                 ; v˜stup na reproduktor
         and       al,not 3
         out       [61h],al                 ; vypnut¡ v˜stupu na reproduktor

; ------ n vrat z programu

         mov       al,ds:[RetKod]           ; n vratov˜ k¢d z programu
         mov       ah,4ch
         int       21h                      ; ukon‡en¡ programu

; -----------------------------------------------------------------------------
;        Obsluha p©eru¨en¡ INT 08h
; -----------------------------------------------------------------------------

Citac    dw        0                        ; ‡¡ta‡ ‡asu
Old08    dd        0                        ; p–vodn¡ adresa INT 08h

public   int08
INT08    PROC      FAR

         inc       word ptr cs:[Citac]
         jnz       Int082                   ; nen¡ p©ete‡en¡
         dec       word ptr cs:[Citac]      ; n vrat ‡¡sla -1
Int082:  jmp       dword ptr cs:[Old08]

Int08    ENDP

; -----------------------------------------------------------------------------
;        Obsluha p©eru¨en¡ INT 00h
; -----------------------------------------------------------------------------

Old00    dd        0                        ; p–vodn¡ adresa INT 00h

INT00    PROC      FAR

         iret

INT00    ENDP

; -----------------------------------------------------------------------------
;        Obsluha p©eru¨en¡ INT 1Bh
; -----------------------------------------------------------------------------

ParBreak db        0                        ; p©¡znak p©eru¨en¡ programu
Old1B    dd        0                        ; p–vodn¡ adresa INT 1Bh

INT1B    PROC      FAR

         mov       byte ptr cs:[ParBreak],1 ; p©¡znak p©eru¨en¡
         iret

INT1B    ENDP

; -----------------------------------------------------------------------------
;        Interpretace procedury programu (po p©¡kaz ENDPROC)
; -----------------------------------------------------------------------------

PUBLIC   Anim

Anim:    sti
         call      InpProg                  ; ‡ten¡ bajtu z programu
         jc        Anim9                    ; je konec bufferu

; ------ obsluha ENDPROC

         cmp       byte ptr cs:[ParBreak],0 ; je p©eru¨en¡ programu ?
         jne       Anim1                    ; je p©eru¨en¡ programu
         cmp       al,6                     ; je ENDPROC ?
         jne       Anim2                    ; nen¡ ENDPROC
Anim1:   xor       ax,ax                    ; n vratov˜ k¢d
         jmp       short Anim9              ; konec

; ------ obsluha RETURN

Anim2:   cmp       al,7                     ; je RETURN ?
         jne       Anim3                    ; nen¡ RETURN
         call      Vyraz                    ; v˜po‡et hodnoty v˜razu
         jmp       short Anim9              ; konec

; ------ obsluha intern¡ funkce

Anim3:   cmp       al,0ffh                  ; je u‘ivatelsk  procedura ?
         je        Anim4                    ; je u‘ivatelsk  procedura
         mov       bl,al                    ; ‡¡slo funkce
         mov       bh,0
         shl       bx,1
         call      word ptr ds:[TabFnc+bx]  ; vyvol n¡ obsluhy funkce
         jmp       short Anim               ; dal¨¡ p©¡kaz

; ------ obsluha u‘ivatelsk‚ procedury

Anim4:   call      InpWord                  ; adresa u‘ivatelsk‚ procedury
         push      word ptr ds:[ProgUkaz]   ; £schova ukazatele pogramu
         mov       word ptr ds:[ProgUkaz],ax ; nov  adresa programu (procedura)
         call      Anim                     ; proveden¡ obsluhy procedury
         pop       word ptr ds:[ProgUkaz]   ; n vrat ukazatele programu
         jmp       short Anim               ; dal¨¡ p©¡kaz

Anim9:   ret

; -----------------------------------------------------------------------------
;        V˜po‡et hodnoty v˜razu (CY=je hodnota 8000h = nenastavuje se)
; -----------------------------------------------------------------------------

PUBLIC   Vyraz
Vyraz:
         push      bx
         push      cx
         push      dx

; ------ prvn¡ operand v˜razu

         call      GetOper                  ; v˜po‡et prvn¡ho operandu
         mov       cx,ax                    ; prvn¡ operand
         jc        Vyraz7                   ; neplatn˜ operand

; ------ vnit©n¡ oper tor v˜razu

Vyraz1:  call      GetProm                  ; poskytnut¡ oper toru
         jc        Vyraz7                   ; nen¡ dal¨¡ oper tor
         cmp       dl,2                     ; je prav  z vorka ?
         je        Vyraz7                   ; je prav  z vorka - konec
         or        dl,dl                    ; je to operand ?
         js        Vyraz1                   ; je operand - chyba

; ------ v˜po‡et druh‚ho operandu

         call      GetOper                  ; v˜po‡et druh‚ho operandu
         jc        Vyraz7                   ; konec v˜razu
         mov       bl,dl
         mov       bh,0
         add       bx,bx                    ; ‡¡slo oper toru * 2
         call      word ptr ds:[TabOper+bx] ; obsluha oper toru
         jmp       short Vyraz1             ; v˜po‡et dal¨¡ho operandu

; ------ zhodnocen¡ v˜sledku operace

Vyraz7:  mov       ax,cx                    ; v˜sledek v˜po‡tu
         cmp       ax,8000h
         clc
         jne       Vyraz8
         stc                                ; p©¡znak hodnoty 8000h

Vyraz8:  pop       dx
         pop       cx
         pop       bx
         ret

; -----------------------------------------------------------------------------
;        V˜po‡et hodnoty jednoho operandu (AX, CY=konec)
; -----------------------------------------------------------------------------

PUBLIC   GetOper

GetOper: push      bx
         push      dx

; ------ ‡ten¡ parametr– operandu (un rn¡ho oper toru)

GetOper1:call      GetProm                  ; poskytnut¡ typu operandu
         jc        GetOper9                 ; nen¡ dal¨¡ operand

; ------ je v˜raz v z vorce

         cmp       dl,1                     ; je lev  z vorka ?
         jne       GetOper2                 ; nen¡ lev  z vorka
         call      Vyraz                    ; v˜po‡et v˜razu v z vorce
         jmp       short GetOper8

; ------ je un rn¡ m¡nus

GetOper2:cmp       dl,10                    ; je un rn¡ m¡nus ?
         jne       GetOper3                 ; nen¡ un rn¡ m¡nus
         call      GetOper                  ; v˜po‡et hodnoty operandu
         jc        GetOper9                 ; nen¡ platn˜ operand
         neg       ax                       ; negace hodnoty
         jmp       short GetOper8           ; konec

; ------ je un rn¡ NOT

GetOper3:cmp       dl,17                    ; je un rn¡ NOT ?
         jne       GetOper5                 ; nen¡ un rn¡ NOT
         call      GetOper                  ; v˜po‡et hodnoty operandu
         jc        GetOper9                 ; nen¡ platn˜ operand
         not       ax                       ; inverze k¢du
         jmp       short GetOper8           ; konec

; ------ je ‡¡seln  konstanta

GetOper5:or        dl,dl                    ; je operand ?
         jns       GetOPer1                 ; nen¡ operand (chyba kompil toru)
         mov       ax,bx                    ; hodnota konstanty
         cmp       dl,81h                   ; je ‡¡seln  konstanta ?
         je        GetOper8                 ; je ‡¡seln  konstanta

; ------ je intern¡ procedura

         cmp       dl,82h                   ; je intern¡ procedura ?
         jne       GetOper6                 ; nen¡ intern¡ procedura
         mov       bh,0
         shl       bx,1                     ; ‡¡slo funkce * 2
         call      word ptr ds:[TabFnc+bx]  ; vyvol n¡ obsluhy funkce
         jmp       short GetOper8

; ------ je u‘ivatelsk  procedura

GetOper6:cmp       dl,83h                   ; je u‘ivatelsk  procedura ?
         jne       GetOper7                 ; nen¡ u‘ivatelsk  procedura
         push      word ptr ds:[ProgUkaz]   ; £schova ukazatele pogramu
         mov       word ptr ds:[ProgUkaz],bx; nov  adresa programu (procedura)
         call      Anim                     ; proveden¡ obsluhy procedury
         pop       word ptr ds:[ProgUkaz]   ; n vrat ukazatele programu
         jmp       short GetOper8

; ------ je promˆnn  typu BYTE nebo WORD

GetOper7:push      ds
         mov       ds,ds:[DatMem]           ; datov˜ segment programu
         mov       al,ds:[bx]               ; ni‘¨¡ bajt
         mov       ah,ds:[bx+1]             ; vy¨¨¡ bajt
         pop       ds
         test      dl,1                     ; m  to b˜t bajt ?
         jnz       GetOper8                 ; je to slovo
         cbw                                ; p©evod na slovo

; ------ n vrat z obsluhy

GetOper8:or        ax,ax
GetOper9:pop       dx
         pop       bx
         ret

; -----------------------------------------------------------------------------
;        Zji¨tˆn¡ typu (=DL) a adresy (= BX) promˆnn‚ nebo oper toru (CY=konec)
; -----------------------------------------------------------------------------

PUBLIC   GetProm

GetProm: push      ax
         call      InpProg                  ; ‡ten¡ identifik toru promˆnn‚
         mov       dl,al                    ; £schova typu promˆnn‚

; ------ test, zda je konec v˜razu

         cmp       dl,0                     ; je konec v˜razu ?
         stc                                ; p©¡znak konce v˜razu
         je        GetProm3                 ; je konec v˜razu

; ------ test, zda je operand (zda n sleduje argument)

GetProm1:cmp       dl,80h                   ; je to operand ?
         jb        GetProm2                 ; nen¡ to operand

; ------ ‡ten¡ adresy promˆnn‚ nebo procedury

         call      InpProg                  ; ‡ten¡ prvn¡ho bajtu operandu
         mov       bl,al                    ; ni‘¨¡ bajt operandu
         cmp       dl,82h                   ; je intern¡ procedura ?
         je        GetProm2                 ; je intern¡ procedura
         call      InpProg                  ; ‡ten¡ druh‚ho bajtu operandu
         mov       bh,al                    ; vy¨¨¡ bajt operandu

; ------ v˜po‡et indexu indexovan‚ promˆnn‚

         cmp       dl,86h                   ; je promˆnn  s indexem ?
         jb        GetProm2                 ; nen¡ indexovan  promˆnn 
         call      Vyraz                    ; v˜po‡et indexu promˆnn‚
         add       bx,ax                    ; p©i‡ten¡ offsetu pro BYTE
         cmp       dl,87h                   ; je WORD ?
         jne       GetProm2                 ; nen¡ WORD
         add       bx,ax                    ; pro WORD je index dvojn sobn˜

GetProm2:clc
GetProm3:pop       ax
         ret

; -----------------------------------------------------------------------------
;        ^ mocnina
; -----------------------------------------------------------------------------

PUBLIC   OpMoc
OpMoc:   xchg      ax,cx
         jcxz      OpMoc3                   ; umocnˆno na 0

         push      bx
         mov       bx,ax                    ; t¡mto ‡¡slem se bude n sobit
OpMoc1:  dec       cx
         jcxz      OpMoc2
         mul       bx                       ; vyn soben¡
         jmp       short OpMoc1
OpMoc2:  pop       bx
         mov       cx,ax                    ; v˜sledek operace
         ret

OpMoc3:  mov       cx,1
         ret

; -----------------------------------------------------------------------------
;        * n soben¡
; -----------------------------------------------------------------------------

PUBLIC   OpMul
OpMul:   push      dx
         imul      cx                       ; n sobek
         mov       cx,ax                    ; v˜sledek
         pop       dx
         ret

; -----------------------------------------------------------------------------
;        / dˆlen¡
; -----------------------------------------------------------------------------

PUBLIC   OpDiv
OpDiv:   xchg      ax,cx
         jcxz      OpDiv1                   ; byla by chyba dˆlen¡ (p©ete‡en¡)
         push      dx
         cwd
         idiv      cx
         mov       cx,ax                    ; pod¡l
         pop       dx
         ret

OpDiv1:  mov       cx,8000h                 ; p©ete‡en¡
         ret

; -----------------------------------------------------------------------------
;        MOD
; -----------------------------------------------------------------------------

PUBLIC   OpMod
OpMod:   xchg      ax,cx
         jcxz      OpMod1                   ; byla by chyba dˆlen¡ (p©ete‡en¡)
         push      dx
         cwd
         idiv      cx
         mov       cx,dx                    ; zbytek
         pop       dx
         ret

OpMod1:  mov       cx,8000h                 ; p©ete‡en¡
         ret

; -----------------------------------------------------------------------------
;        <<
; -----------------------------------------------------------------------------

PUBLIC   OpShl
OpShl:   xchg      ax,cx
         cmp       cx,16
         jbe       OpShl1
         mov       cl,16
OpShl1:  shl       ax,cl
         mov       cx,ax
         ret

; -----------------------------------------------------------------------------
;        >>
; -----------------------------------------------------------------------------

PUBLIC   OpShr
OpShr:   xchg      ax,cx
         cmp       cx,16
         jbe       OpShr1
         mov       cl,16                    ; omezen¡ po‡tu rotac¡
OpShr1:  shr       ax,cl                    ; rotace o dan˜ po‡et bit–
         mov       cx,ax
         ret

; -----------------------------------------------------------------------------
;        +
; -----------------------------------------------------------------------------

PUBLIC   OpAdd
OpAdd:   add       cx,ax
         ret

; -----------------------------------------------------------------------------
;        -
; -----------------------------------------------------------------------------

PUBLIC   OpSub
OpSub:   sub       cx,ax
         ret

; -----------------------------------------------------------------------------
;        =
; -----------------------------------------------------------------------------

PUBLIC   OpEqu
OpEqu:   cmp       cx,ax
         mov       cx,-1
         je        OpEqu1
         xor       cx,cx
OpEqu1:  ret

; -----------------------------------------------------------------------------
;        <>
; -----------------------------------------------------------------------------

PUBLIC   OpNeq
OpNeq:   cmp       cx,ax
         mov       cx,-1
         jne       OpNeq1
         xor       cx,cx
OpNeq1:  ret

; -----------------------------------------------------------------------------
;        <
; -----------------------------------------------------------------------------

PUBLIC   OpLt
OpLt:    cmp       cx,ax
         mov       cx,-1
         jl        OpGt1
         xor       cx,cx
OpLt1:   ret

; -----------------------------------------------------------------------------
;        >
; -----------------------------------------------------------------------------

PUBLIC   OpGt
OpGt:    cmp       cx,ax
         mov       cx,-1
         jg        OpGt1
         xor       cx,cx
OpGt1:   ret

; -----------------------------------------------------------------------------
;        <=
; -----------------------------------------------------------------------------

PUBLIC   OpLte
OpLte:   cmp       cx,ax
         mov       cx,-1
         jle       OpLte1
         xor       cx,cx
OpLte1:  ret

; -----------------------------------------------------------------------------
;        >=
; -----------------------------------------------------------------------------

PUBLIC   OpGte
OpGte:   cmp       cx,ax
         mov       cx,-1                    ; podm¡nka splnˆna
         jge       OpGte1
         xor       cx,cx
OpGte1:  ret

; -----------------------------------------------------------------------------
;        NOT
; -----------------------------------------------------------------------------

PUBLIC   OpNot
OpNot:   not       ax
         mov       cx,ax
         ret

; -----------------------------------------------------------------------------
;        AND
; -----------------------------------------------------------------------------

PUBLIC   OpAnd
OpAnd:   and       cx,ax
         ret

; -----------------------------------------------------------------------------
;        OR
; -----------------------------------------------------------------------------

PUBLIC   OpOr
OpOr:    or        cx,ax
         ret

; -----------------------------------------------------------------------------
;        XOR
; -----------------------------------------------------------------------------

PUBLIC   OpXor
OpXor:   xor       cx,ax
         ret

; -----------------------------------------------------------------------------
;        ‡ten¡ slova z programu
; -----------------------------------------------------------------------------

PUBLIC   InpWord

InpWord: call      InpProg
         mov       ah,al
         call      InpProg
         xchg      ah,al
         ret

; -----------------------------------------------------------------------------
;        €ten¡ bajtu programu (ZY=je bajt 0)
; -----------------------------------------------------------------------------

PUBLIC   InpProg

InpProg: push      es
         push      di

         mov       es,cs:[ProgMem]          ; segment s na‡ten˜m programem
         mov       di,cs:[ProgUkaz]         ; ukazatel programu
         mov       al,es:[di]               ; p©e‡ten¡ bajtu programu
         clc
         inc       word ptr cs:[ProgUkaz]   ; zv˜¨en¡ ukazatele programu
         or        al,al                    ; test, zda je 0
         pop       di
         pop       es
         ret

; -----------------------------------------------------------------------------
;        Nalezen¡ objektu AX v pamˆti -> DX
; -----------------------------------------------------------------------------

PUBLIC   SrcObj

SrcObj:
         mov       dx,cs:[ObjMem]           ; segment s objekty

                                          ;* test, zda je je¨tˆ dal¨¡ objekt
SrcObj1: cmp       dx,cs:[TopMem]           ; dosa‘eno konce pamˆti ?
         cmc
         jc        SrcObj3                  ; objekt nenalezen

                                          ;* test, zda je to hledan˜ objekt
SrcObj2: push      ds
         mov       ds,dx                    ; segment objektu
         cmp       ax,ds:[0]                ; je to hledan˜ objekt ?
         pop       ds
         je        SrcObj3                  ; objekt nalezen

                                          ;* nastaven¡ na dal¨¡ objekt
         push      ds
         mov       ds,dx                    ; segment objektu
         add       dx,ds:[2]                ; zv˜¨en¡ adresy segmentu
         pop       ds
         jmp       short SrcObj1            ; test dal¨¡ho objektu

SrcObj3:
         ret

; -----------------------------------------------------------------------------
;        Zru¨en¡ objektu z pamˆti (DX=adresa objektu)
; -----------------------------------------------------------------------------

PUBLIC   DelObj

DelObj:  push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

         sti                                ; mus¡ b˜t povoleno p©eru¨en¡
         cld                                ; smˆr nahoru
         mov       es,dx                    ; c¡lov˜ segment k p©esunu
         mov       cx,es:[2]                ; velikost objektu
         add       dx,cx                    ; adresa dal¨¡ho objektu
         mov       bx,cs:[TopMem]           ; konec pamˆti s objekty
         sub       cs:[TopMem],cx           ; sn¡‘en¡ konce pamˆti
         sub       bx,dx                    ; velikost zbytku dat
         jz        DelObj5                  ; nejsou ‘ dn  data k p©esunu
         mov       ds,dx                    ; zdrojov  adresa p©esunu
         jmp       short DelObj3

; ------ P©enos dal¨¡ho bloku dat

DelObj2: mov       cx,es                    ; c¡lov˜ segment
         add       cx,1000h                 ; zv˜¨en¡ o 1 segment 64 KB
         mov       es,cx                    ; nov˜ c¡lov˜ segment
         mov       cx,ds                    ; zdrojov˜ segment
         add       cx,1000h                 ; zv˜¨en¡ o 1 segment 64 KB
         mov       ds,cx                    ; nov˜ zdrojov˜ segment

; ------ Nastaven¡ velikosti p©en ¨en‚ho bloku

DelObj3: mov       cx,1000h                 ; omezen¡ na 64 KB
         cmp       bx,cx                    ; je blok vˆt¨¡ ne‘ 1 segment ?
         jae       DelObj4                  ; je velk˜ segment
         mov       cx,bx                    ; velikost bloku v odstavc¡ch
DelObj4: shl       cx,1
         shl       cx,1
         shl       cx,1                     ; p©evod odstavc– na slova

; ------ P©enos jednoho bloku dat

         xor       si,si
         xor       di,di
         rep       movsw                    ; p©enos jednoho segmentu
         sub       bx,1000h                 ; je dal¨¡ segment k p©enosu ?
         ja        DelObj2                  ; p©enos dal¨¡ho segmentu

DelObj5: pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

; -----------------------------------------------------------------------------
;        Zobrazen¡ objektu ‡¡slo AX (pozice BX, linka DX)
; -----------------------------------------------------------------------------
; VSTUP: AX=‡¡slo objektu
;        BX=pozice
;        DX=linka
;        DS=datov˜ segment
; -----------------------------------------------------------------------------
; þ
PUBLIC   Objekt

; ------ £schova registr–

Objekt:  push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

; ------ nastaven¡ ukazatele lok ln¡ch promˆnn˜ch

         push      bp
         mov       bp,sp                    ; ukazatel promˆnn˜ch v z sobn¡ku
         sub       sp,28h                   ; rezerva pro lok ln¡ promˆnn‚

; ------ inicializace promˆnn˜ch v z sobn¡ku





; ------ nalezen¡ z hlav¡ objektu

         push      dx
         call      SrcObj                   ; nalezen¡ adresy objektu
         mov       ds,dx                    ; segment objektu
         pop       dx
         jc        Objekt9                  ; objekt nenalezen

; ------ £schova parametr– objektu

Objekt0: push      cs
         pop       es                       ; ES <- CS
         mov       si,4                     ; adresa ¨¡©ky objektu
         mov       di,offset Sirka          ; buffer k £schovˆ parametr–
         mov       cx,6                     ; d‚lka (slov)
         cld
         rep       movsw                    ; £schova z hlav¡ objektu

; ------ p©¡prava ukazatel– pro zobrazen¡ objektu

         call      GetVRAM                  ; poskytnut¡ adresy VRAM
         call      GetTabMod                ; adresa definice videom¢du
         mov       ax,ds                    ; segment objektu
         inc       ax
         mov       ds,ax                    ; segment prvn¡ roviny
         xor       si,si                    ; po‡ te‡n¡ offset
         xor       ax,ax                    ; ‡¡ta‡ rovin

; ------ maskov n¡ obr zku

         test      byte ptr cs:[Param],8    ; je maska obr zku ?
         jz        Objekt1                  ; nen¡ maska

         mov       word ptr cs:[AdrMask+2],ds ; segment masky pozad¡ (offset=0)

         call      word ptr cs:[bp+ModNext] ; nastaven¡ adresy SI dal¨¡ roviny

         push      ax
         push      dx
         mov       ax,si                    ; kone‡n˜ stav v bufferu
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©epo‡et na odstavce
         mov       dx,ds                    ; sou‡asn˜ segment
         add       ax,dx                    ; nov˜ segment
         mov       ds,ax                    ; nov˜ segment
         and       si,0fh                   ; offset
         pop       dx
         pop       ax


                                          ;* zobrazen¡ jedn‚ barevn‚ roviny
Objekt1: cld
         push      di                       ; £schova adresy videostr nky
         push      si                       ; £schova adresy obr zku
         mov       word ptr cs:[AdrMask],0  ; offset adresy masky

         call      word ptr cs:[bp+ModSet]  ; p©¡prava pro zobrazen¡ roviny

         mov       cx,cs:[bp+ModVys]        ; v˜¨ka displeje
         sub       cx,dx                    ; maxim ln¡ mo‘n  v˜¨ka objektu
         cmp       cx,cs:[Vyska]            ; je v˜¨ka objektu men¨¡ ?
         jbe       Objekt11                 ; v˜¨ka objektu nen¡ men¨¡
         mov       cx,cs:[Vyska]            ; v˜¨ka obr zku
Objekt11:jcxz      Objekt4                  ; v˜¨ka obr zku = 0

                                          ;* zobrazen¡ jedn‚ linky
Objekt2: push      cx

         mov       cx,cs:[bp+ModSir]        ; ¨¡©ka displeje
         sub       cx,bx                    ; maxim ln¡ mo‘n  ¨¡©ka objektu
         cmp       cx,cs:[Sirka]            ; je ¨¡©ka objektu men¨¡ ?
         jbe       Objekt22                 ; ¨¡©ka objektu nen¡ men¨¡
         mov       cx,cs:[Sirka]            ; ¨¡©ka obr zku
Objekt22:jcxz      Objekt3                  ; ¨¡©ka obr zku = 0
         call      word ptr cs:[bp+ModDisp] ; zobrazen¡ jedn‚ linky
Objekt3: pop       cx
         loop      Objekt2                  ; zobrazen¡ dal¨¡ linky

                                          ;* zv˜¨en¡ adresy pro dal¨¡ rovinu
Objekt4: pop       si                       ; n vrat adresy obr zku
         pop       di                       ; n vrat adresy videostr nky

         call      word ptr cs:[bp+ModNext] ; nastaven¡ adresy SI dal¨¡ roviny

         test      byte ptr cs:[Param],4    ; je paraleln¡ ulo‘en¡ barev ?
         jnz       Objekt9                  ; je paraleln¡ ulo‘en¡ barev - konec

         push      ax
         push      dx
         mov       ax,si                    ; kone‡n˜ stav v bufferu
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©epo‡et na odstavce
         mov       dx,ds                    ; sou‡asn˜ segment
         add       ax,dx                    ; nov˜ segment
         mov       ds,ax                    ; nov˜ segment
         and       si,0fh                   ; offset
         pop       dx
         pop       ax

         inc       ax                       ; zv˜¨en¡ ‡¡sla roviny
         cmp       ax,cs:[Rovin]            ; jsou ji‘ v¨echny roviny ?
         jb        Objekt1                  ; nejsou je¨tˆ v¨echny roviny

; ------ n vrat registr–

Objekt9: mov       sp,bp                    ; n vrat ukazatele z sobn¡ku
         pop       bp                       ; n vrat BP

         pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret


; -----------------------------------------------------------------------------
;        Poskytnut¡ adresy tabulky videom¢du
; -----------------------------------------------------------------------------

GetTabMod:
         push      ax
         push      dx

         xor       ax,ax
         mov       al,cs:[VMod]             ; aktu ln¡ videom¢d
         mov       bp,offset(TabMod0-TabMod); d‚lka jedn‚ polo‘ky tabulky
         mul       bp                       ; offset v tabulce
         add       ax,offset TabMod         ; tabulka parametr– displeje
         mov       bp,ax                    ; adresa parametr– displeje

         pop       dx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        Poskytnut¡ adresy v˜stupn¡ videostr nky ES:DI
; -----------------------------------------------------------------------------

GetVRAM:
         push      ax
         push      dx
         mov       ah,0
         mov       al,cs:[Page2]            ; v˜stupn¡ videostr nka
         mul       word ptr cs:[DelVRAM]    ; v˜po‡et offsetu videostr nky
         mov       di,ax                    ; offset adresy videostr nky
         mov       es,cs:[SegVRAM]          ; segment videopamˆti
         pop       dx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        Vymaz n¡ displeje v textov‚m m¢du
; -----------------------------------------------------------------------------

PUBLIC   ClrTXT

ClrTxt:  push      ax
         push      cx
         push      dx
         push      di
         push      es

         call      GetVRAM                  ; poskytnut¡ adresy videostr nky

                                          ;* ur‡en¡ d‚lky videostr nky
         push      ax
         mov       ax,cs:[bp+ModSir]        ; ¨¡©ka © dku (znak–)
         mul       word ptr cs:[bp+ModVys]  ; x v˜¨ka = po‡et znak– celkem
         mov       cx,ax                    ; celkov  d‚lka videostr nky
         pop       ax

         shl       al,1
         shl       al,1
         shl       al,1
         shl       al,1                     ; posun barvy jako pozad¡
         mov       ah,al                    ; barva
         mov       al," "                   ; mazac¡ znak - mezera

         cld
         rep       stosw                    ; vymaz n¡ obrazovky

         pop       es
         pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        P©¡prava textov‚ho m¢du
; -----------------------------------------------------------------------------

PUBLIC   SetTXT

SetTxt:  push      ax
         push      dx

         add       di,ax                    ; korekce pro po‘adovanou rovinu

         mov       ax,cs:[bp]               ; po‡et znak– na © dek
         mul       dx                       ; p©evod © dk– na pozici
         add       ax,bx                    ; p©i‡ten¡ pozice na © dku
         shl       ax,1                     ; po‡et bajt– na © dek
         add       di,ax                    ; adresa ve videopamˆti

         pop       dx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        Zobrazen¡ linky v textov‚m m¢du
; -----------------------------------------------------------------------------

PUBLIC   DispTXT

DispTXT: push      ax
         push      cx
         push      si
         push      di

DispTXT1:movsb
         inc       di
         loop      DispTXT1

         pop       di
         pop       si
         pop       cx
         pop       ax

         add       si,cs:[Sirka]
         add       di,cs:[bp]               ; p©i‡ten¡ po‡tu znak– na © dek
         add       di,cs:[bp]               ; (adresa dal¨¡ linky)
         ret

; -----------------------------------------------------------------------------
;        Nastaven¡ adresy dal¨¡ roviny textov‚ho m¢du
; -----------------------------------------------------------------------------

NextTXT: push      ax
         push      dx
         mov       ax,cs:[Vyska]            ; po‡et linek
         mul       word ptr cs:[Sirka]      ; po‡et bajt– na rovinu
         add       si,ax                    ; adresa dal¨¡ roviny
         pop       dx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        Vymaz n¡ displeje CGA
; -----------------------------------------------------------------------------

PUBLIC   ClrCGA
ClrCGA:  push      ax
         push      cx
         push      di
         push      es

         call      GetVRAM                  ; poskytnut¡ adresy videostr nky

         cmp       byte ptr cs:[VMod],6
         jae       ClrCGA2

         and       al,3
         mov       cl,al
         shl       cl,1
         shl       cl,1
         or        cl,al
         shl       cl,1
         shl       cl,1
         shl       cl,1
         shl       cl,1
         or        al,cl
         jmp       short ClrCGA3

ClrCGA2: shr       al,1
         mov       al,0
         jnc       ClrCGA3
         dec       al

ClrCGA3: mov       cx,2000h
         mov       ah,al
         cld
         rep       stosw                    ; vymaz n¡ obrazovky

         pop       es
         pop       di
         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        P©¡prava m¢du CGA
; -----------------------------------------------------------------------------

PUBLIC   SetCGA
SetCGA:
         push      ax
         push      bx
         push      dx

                                          ;* korekce pro videom¢d 4 nebo 5
         cmp       byte ptr cs:[VMod],6     ; je videom¢d 6 nebo vy¨¨¡ ?
         jae       SetCGA1
         add       bx,bx                    ; zdvojn soben¡ pozice

                                          ;* p©evod bitov‚ pozice na bajtovou
SetCGA1: shr       bx,1
         shr       bx,1
         shr       bx,1

                                          ;* korekce pro lichou linku
         cmp       byte ptr cs:[VMod],17    ; je videom¢d 17 (MCGA) ?
         je        SetCGA2                  ; je videom¢d 17 (MCGA)
         shr       dx,1                     ; po‡et © dk– / 2
         jnc       SetCGA2                  ; je sud  linka
         xor       di,2000h                 ; korekce pro lichou linku

                                          ;* v˜po‡et adresy
SetCGA2: mov       ax,80                    ; po‡et bajt– na © dek
         mul       dx                       ; p©evod © dk– na bajty
         add       ax,bx                    ; p©i‡ten¡ pozice na © dku
         add       di,ax                    ; adresa ve videopamˆti

         pop       dx
         pop       bx
         pop       ax
         ret


; -----------------------------------------------------------------------------
;        Zobrazen¡ linky v m¢du CGA
; -----------------------------------------------------------------------------

PUBLIC   DispCGA
DispCGA:
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

         add       cx,3
         shr       cx,1
         shr       cx,1

         cmp       byte ptr cs:[VMod],6
         jb        DispCGA2

         inc       cx
         shr       cx,1

DispCGA2:
         rep       movsb

         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx

                                          ;* zv˜¨en¡ adresy v bufferu
         mov       ax,cs:[Sirka]            ; ¨¡©ka objektu
         add       ax,3                     ; zaokrouhlen¡ na ‡tve©ice bit–
         shr       ax,1
         shr       ax,1                     ; ¨¡©ka / 4 (pro m¢dy 4 a 5)
         cmp       byte ptr cs:[VMod],6     ; je videom¢d 6 nebo 17 ?
         jb        DispCGA7                 ; nen¡ videom¢d 6 ani 17
         inc       ax                       ; zaokrouhlen¡
         shr       ax,1                     ; ¨¡©ka / 8
DispCGA7:add       si,ax                    ; zv˜¨en¡ adresy v bufferu

                                          ;* zv˜¨en¡ adresy displeje
         cmp       byte ptr cs:[VMod],17    ; je videom¢d 17 (MCGA) ?
         je        DispCGA8                 ; je videom¢d 17 (MCGA)
         xor       di,2000h
         test      di,2000h                 ; je sud  linka ?
         jnz       DispCGA9                 ; je lich  linka
DispCGA8:add       di,80                    ; p©i‡ten¡ po‡tu bajt– na © dek

DispCGA9:pop       ax
         ret

; -----------------------------------------------------------------------------
;        Adresa dal¨¡ roviny CGA
; -----------------------------------------------------------------------------

NextCGA:
         ret

; -----------------------------------------------------------------------------
;        Vymaz n¡ displeje EGA
; -----------------------------------------------------------------------------

PUBLIC   ClrEGA
ClrEGA:
         push      ax
         push      bx
         push      cx
         push      dx
         push      bp
         push      si
         push      di
         push      es

         call      GetVRAM                  ; poskytnut¡ adresy videostr nky
         call      GetTabMod                ; adresa tabulky videom¢du

         mov       cx,cs:[DelVRAM]          ; d‚lka videostr nky (bajt–)
         shr       cx,1                     ; d‚lka videostr nky (slov)
         mov       si,ax                    ; po‘adovan  barva
         mov       bx,1                     ; ukazatel a ‡¡ta‡ rovin
         mov       dx,3c4h                  ; port pro nastaven¡ barevn‚ roviny
         cld

                                          ;* cyklus vymaz n¡ jedn‚ roviny
ClrEGA1: push      di
         push      cx

                                          ;* nastaven¡ barevn‚ roviny
         mov       al,2
         out       dx,al                    ; registr 0 - volba barevn‚ roviny
         inc       dx
         mov       al,bl                    ; maska roviny
         out       dx,al                    ; volba barevn‚ roviny
         dec       dx

                                          ;* stanoven¡ z pisov‚ho vzorku
         xor       ax,ax                    ; rovina nebude nastavena
         shr       si,1                     ; je barevn  rovina nastavena ?
         jnc       ClrEGA2                  ; rovina nebude nastavena
         dec       ax                       ; rovina bude nastavena

ClrEGA2: rep       stosw                    ; vymaz n¡ barevn‚ roviny

         pop       cx
         pop       di

                                          ;* p©¡prava pro dal¨¡ rovinu
         shl       bl,1                     ; posun masky barevn‚ roviny
         inc       bh                       ; zv˜¨en¡ ‡¡ta‡e rovin
         cmp       bh,cs:[bp+ModRov]        ; jsou ji‘ v¨echny roviny ?
         jb        ClrEGA1                  ; vymaz n¡ dal¨¡ roviny

         pop       es
         pop       di
         pop       si
         pop       bp
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        P©¡prava m¢du EGA
; -----------------------------------------------------------------------------
; þ
PUBLIC   SetEGA
SetEGA:  push      ax
         push      bx
         push      cx
         push      dx

                                          ;* ur‡en¡ v˜stupn¡ roviny
         mov       cl,al                    ; ‡¡slo roviny
         mov       al,1
         shl       al,cl                    ; rotace na pozici
         mov       cl,al

                                          ;* p©evod bitov‚ pozice na bajtovou
         shr       bx,1
         shr       bx,1
         shr       bx,1

                                          ;* v˜po‡et adresy
         mov       ax,40                    ; po‡et bajt– na © dek
         cmp       byte ptr cs:[VMod],13
         je        SetEGA1
         mov       ax,80
SetEGA1: mul       dx                       ; p©evod linek na bajty
         add       ax,bx                    ; p©i‡ten¡ pozice na © dku
         add       di,ax                    ; adresa ve videopamˆti

                                          ;* nastaven¡ roviny pro v˜stup
         mov       dx,3c4h
         mov       al,2
         out       dx,al                    ; registr 0 - volba barevn‚ roviny
         inc       dx
         mov       al,cl                    ; maska roviny
         out       dx,al                    ; volba barevn‚ roviny

         mov       dx,3ceh
         mov       al,8
         out       dx,al
         inc       dx
         mov       al,0ffh
         out       dx,al

SetEGA2:
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        Zobrazen¡ linky v m¢du EGA
; -----------------------------------------------------------------------------
; VSTUP:
; -----------------------------------------------------------------------------

PUBLIC   DispEGA
DispEGA:

         cld

         shr       cx,1
         shr       cx,1
         shr       cx,1


         test      byte ptr cs:[Param],8    ; je maska ?
         jz        DispEGA4                 ; nen¡ maska

         jcxz      DispEGA5

         mov       bx,word ptr cs:[AdrMask] ; offset adresy masky
         mov       bp,word ptr cs:[AdrMask+2] ; segment adresy masky

; ------ p©¡prava registru masky

         mov       dx,3ceh
         mov       al,8
         out       dx,al
         inc       dx

; ------ zobrazen¡ prvn¡ho bajtu linky
                                            ; BX=adresa masky
                                            ; CL=po‡ te‡n¡ bitov  pozice
                                            ; DX=adresa portu masky (03cfh)
                                            ; SI=adresa zdroje (roviny)
                                            ; ES:DI=v˜stupn¡ adresa

         mov       ds,ObjMaskS              ; segment masky
         mov       al,ds:[bx]               ; maska
         and       al,ObjMaskF              ; zamaskov n¡ prvn¡ho bajtu
         shr       al,cl                    ; rotace na pozici
         out       dx,al                    ; nastaven¡ masky pro z pis
         mov       ds,ObjZdrjS              ; segment roviny
         mov       al,ds:[si]               ; rovina
         shr       al,cl                    ; rotace na pozici
         xchg      al,es:[di]               ; z pis bajtu na displej
         inc       di                       ; zv˜¨en¡ ukl dac¡ adresy

; ------ zobrazen¡ vnit©n¡ch bajt– linky
                                            ; BX=adresa masky
                                            ; CL=rotace vpravo
                                            ; CH=po‡et bajt–
                                            ; DX=adresa portu masky (03cfh)
                                            ; SI=adresa zdroje (roviny)
                                            ; ES:DI=v˜stupn¡ adresa

         or        ch,ch                    ; je nˆjak˜ vnit©n¡ bajt ?
         jz        DispEGA3                 ; nen¡ ‘ dn˜ vnit©n¡ bajt
DispEGA2:mov       ds,ObjMaskS              ; segment masky
         mov       ax,ds:[bx]               ; maska
         inc       bx                       ; zv˜¨en¡ ukazatele masky
         xchg      ah,al                    ; oprava bajt– na pozice
         ror       ax,cl                    ; rotace na pozici
         out       dx,al                    ; nastaven¡ masky pro z pis
         mov       ds,ObjZdrjS              ; segment roviny
         mov       ax,ds:[si]               ; rovina
         inc       si                       ; zv˜¨en¡ adresy roviny
         xchg      ah,al                    ; oprava bajt– na pozice
         ror       ax,cl                    ; rotace na pozici
         xchg      al,es:[di]               ; z pis bajtu na displej
         inc       di                       ; zv˜¨en¡ ukl dac¡ adresy
         dec       ch                       ; sn¡‘en¡ ‡¡ta‡e bajt–
         jnz       DispEGA2                 ; z pis dal¨¡ho bajtu


DispEGA3:





         jmp       short DispEGA5

DispEGA4:rep       movsb

DispEGA5:pop       dx
         pop       cx
         pop       bx
         pop       bp
         pop       di
         pop       si
         pop       ax

         add       di,40
         cmp       byte ptr cs:[VMod],13
         je        DispEGA8
         add       di,40

DispEGA8:push      ax
         mov       ax,cs:[Sirka]
         add       ax,7
         shr       ax,1
         shr       ax,1
         shr       ax,1
         add       si,ax
         add       word ptr cs:[AdrMask],ax ; zv˜¨en¡ adresy masky
         pop       ax


         pop       bp
         ret

; -----------------------------------------------------------------------------
;        Adresa dal¨¡ roviny EGA
; -----------------------------------------------------------------------------

NextEGA: push      ax
         push      dx
         mov       ax,cs:[sirka]            ; po‡et bod–
         add       ax,7
         shr       ax,1
         shr       ax,1
         shr       ax,1
         mul       word ptr cs:[Vyska]      ; v˜po‡et offsetu
         add       si,ax                    ; adresa dal¨¡ roviny

         mov       dx,3ceh
         mov       al,8
         out       dx,al
         inc       dx
         mov       al,0ffh
         out       dx,al

         pop       dx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        Vymaz n¡ displeje MCGA
; -----------------------------------------------------------------------------

ClrMCG:
         ret

; -----------------------------------------------------------------------------
;        P©¡prava m¢du MCGA
; -----------------------------------------------------------------------------

SetMCG:

         ret

; -----------------------------------------------------------------------------
;        Zobrazen¡ linky v m¢du MCGA
; -----------------------------------------------------------------------------

DispMCG:
         ret

; -----------------------------------------------------------------------------
;        Adresa dal¨¡ roviny MCGA
; -----------------------------------------------------------------------------

NextMCG:
         ret



ClrPCJ:
         ret

SetPCJ:
         ret

DispPCJ:
         ret

NextPCJ:
         ret




; þ

; -----------------------------------------------------------------------------
;        NOP - ‘ dn  funkce
; -----------------------------------------------------------------------------

PUBLIC   XNop
XNop:    xor       ax,ax
         ret

; -----------------------------------------------------------------------------
;        EXEC
; -----------------------------------------------------------------------------

PUBLIC   XExec
XExec:
         ret

; -----------------------------------------------------------------------------
;        IF
; -----------------------------------------------------------------------------

PUBLIC   XIf
XIf:     call      Vyraz                    ; v˜po‡et v˜razu
         mov       bx,ax                    ; £schova hodnoty v˜razu
         call      InpWord                  ; adresa, pokud podm¡nka nesplnˆna
         or        bx,bx                    ; je podm¡nka splnˆna ?
         jnz       XIf2                     ; podm¡nka je splnˆna - d le
         mov       word ptr ds:[ProgUkaz],ax ; jinak ELSE resp. ENDIF
XIf2:    ret

; -----------------------------------------------------------------------------
;        ELSE
; -----------------------------------------------------------------------------

PUBLIC   XElse
XElse:   call      InpWord                  ; adresa za ELSE
         mov       word ptr ds:[ProgUkaz],ax ; vˆtev s ELSE se p©esko‡¡
         ret

; -----------------------------------------------------------------------------
;        FOR
; -----------------------------------------------------------------------------

PUBLIC   XFor
XFor:
         ret

; -----------------------------------------------------------------------------
;        ON
; -----------------------------------------------------------------------------

PUBLIC   XOn
XOn:     call      Vyraz                    ; v˜po‡et v˜razu
         mov       bx,ax                    ; £schova hodnoty v˜razu
         call      InpWord                  ; adresa, pokud podm¡nka nesplnˆna
         or        bx,bx                    ; je podm¡nka splnˆna ?
         jz        XOn2                     ; podm¡nka nesplnˆna - d le
         mov       word ptr ds:[ProgUkaz],ax ; jinak ENDDO
XOn2:    ret

; -----------------------------------------------------------------------------
;        ENDDO
; -----------------------------------------------------------------------------

PUBLIC   XEndDo
XEndDo:  call      InpWord                  ; adresa skoku na za‡ tek cyklu
         mov       word ptr ds:[ProgUkaz],ax ; nepodm¡nˆn˜ skok na DO
         ret

; -----------------------------------------------------------------------------
;        CASE
; -----------------------------------------------------------------------------

PUBLIC   XCase
XCase:   call      Vyraz                    ; testovan˜ v˜raz
         mov       bx,ax                    ; testovan˜ v˜raz

; ------ na‡ten¡ parametr– vˆtve IN

XCase1:  call      InpProg                  ; ‡ten¡ bajtu IN
         cmp       al,21                    ; je k¢d IN ?
         jne       XCase5                   ; nen¡ dal¨¡ podm¡nka IN
         call      InpWord                  ; spodn¡ mez intervalu
         mov       cx,ax                    ; spodn¡ mez intervalu
         call      InpWord                  ; horn¡ mez intervalu
         mov       dx,ax                    ; horn¡ mez intervalu
         call      InpWord                  ; adresa p©i nesplnˆn‚ podm¡nce
         cmp       cx,dx                    ; je spodn¡ mez pod horn¡ ?
         ja        XCase2                   ; spodn¡ mez je nad horn¡

; ------ porovn n¡ bˆ‘n‚ho po©ad¡ mez¡

         cmp       bx,cx                    ; porovn n¡ se spodn¡ mez¡ intervalu
         jb        XCase4                   ; nen¡ v intervalu
         cmp       bx,dx                    ; porovn n¡ s horn¡ mez¡ intervalu
         ja        XCase4                   ; nen¡ v intervalu
         jmp       short XCase8             ; podm¡nka splnˆna

; ------ porovn n¡ obr cen‚ho po©ad¡ mez¡

XCase2:  cmp       bx,cx                    ; porovn n¡ se spodn¡ mez¡ intervalu
         jae       XCase8                   ; je v intervalu
         cmp       bx,dx                    ; porovn n¡ s horn¡ mez¡ intervalu
         jbe       XCase8                   ; je v intervalu

; ------ podm¡nka nesplnˆna - nastaven¡ na dal¨¡ vˆtev IN

XCase4:  mov       word ptr ds:[ProgUkaz],ax ; adresa dal¨¡ho p©¡kazu IN
         jmp       short XCase1             ; dal¨¡ p©¡kaz IN

; ------ p©¡padn‚ p©esko‡en¡ povelu OUT

XCase5:  cmp       al,22                    ; je vˆtev OUT ?
         je        XCase6                   ; je vˆtev OUT
         dec       word ptr ds:[ProgUkaz]   ; n vrat k¢du povelu
         jmp       short XCase8             ; pokra‡ov n¡ v programu
XCase6:  call      InpWord                  ; vyjmut¡ adresy konce CASE
XCase8:  ret

; -----------------------------------------------------------------------------
;        IN
; -----------------------------------------------------------------------------

PUBLIC   XIn
XIn:     call      InpWord                  ; p©esko‡en¡ spodn¡ meze
         call      InpWord                  ; p©esko‡en¡ horn¡ meze
         call      InpWord                  ; adresa dal¨¡ho pokra‡ov n¡
         mov       ds:[ProgUkaz],ax         ; adresa pokra‡ov n¡ v programu
         ret

; -----------------------------------------------------------------------------
;        OUT
; -----------------------------------------------------------------------------

PUBLIC   XOut
XOut:    call      InpWord                  ; adresa dal¨¡ho pokra‡ov n¡
         mov       ds:[ProgUkaz],ax         ; adresa pokra‡ov n¡ v programu
         ret

; -----------------------------------------------------------------------------
;        VAL
; -----------------------------------------------------------------------------

PUBLIC   XVal
XVal:
         ret

; -----------------------------------------------------------------------------
;        STR
; -----------------------------------------------------------------------------

PUBLIC   XStr
XStr:
         ret

; -----------------------------------------------------------------------------
;        LEN
; -----------------------------------------------------------------------------

PUBLIC   XLen
XLen:
         ret

; -----------------------------------------------------------------------------
;        CARD
; -----------------------------------------------------------------------------

PUBLIC   XCard
XCard:
         mov       ah,0
         mov       al,ds:[EgaVga]           ; p©¡znak karty EGA/VGA
         ret

; -----------------------------------------------------------------------------
;        VIDEO
; -----------------------------------------------------------------------------

PUBLIC   XVideo
XVideo:

; ------ nastaven¡ po‘adovan‚ho videom¢du

         call      Vyraz                    ; ‡ten¡ ‡¡sla videom¢du
         jc        XVideo1                  ; nem  se nastavit
         mov       ah,0                     ; funkce nastaven¡ videom¢du
         call      Int10                    ; nastaven¡ videom¢du
XVideo1: mov       ah,0fh                   ; funkce poskytnut¡ videom¢du
         call      Int10                    ; poskytnut¡ videom¢du
         mov       ds:[VMod],al             ; £schova videom¢du

; ------ stanoven¡ adresy videostr nky

         mov       bx,0b800h
         cmp       al,7
         jb        XVideo2
         mov       bh,0b0h
         cmp       al,13
         jb        XVideo2
         mov       bh,0a0h
XVideo2: mov       ds:[SegVRAM],bx          ; segment videopamˆti

; ------ stanoven¡ d‚lky videostr nky

         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       ax,ds:[44ch]             ; d‚lka videostr nky
         pop       ds
         mov       ds:[DelVRAM],ax          ; d‚lka videostr nky

; ------ nastaven¡ aktivn¡ videostr nky

         mov       al,ds:[Page1]            ; aktivn¡ videostr nka
         mov       bh,al
         mov       ah,5
         call      Int10                    ; nastaven¡ aktivn¡ str nky displeje

; ------ nastaven¡ p–vodn¡ pozice kurzoru

         mov       dx,ds:[KurzPoz]          ; aktu ln¡ pozice kurzoru
         mov       ah,2
         call      Int10                    ; nastaven¡ p–vodn¡ pozice kurzoru

; ------ stanoven¡ n vratov‚ho k¢du (‡¡slo videom¢du)

         mov       ah,0
         mov       al,ds:[VMod]             ; aktu ln¡ videom¢d
         ret

; -----------------------------------------------------------------------------
;        MODE
; -----------------------------------------------------------------------------

PUBLIC   XMode
XMode:
         call      Vyraz                    ; zji¨tˆn¡ m¢du displeje
         jc        XMode8                   ; nepo‘aduje se nastaven¡
         mov       ds:[BitDisp],ax          ; p©¡znakov‚ bity

         cmp       byte ptr ds:[VMod],4
         je        XMode1
         cmp       byte ptr ds:[VMod],5
         jne       XMode3
XMode1:  mov       ah,0bh
         mov       bh,1
         mov       bl,al
         call      Int10
         jmp       short XMode8


XMode3:

XMode8:  mov       ax,ds:[BitDisp]
         ret

; -----------------------------------------------------------------------------
;        PAGE
; -----------------------------------------------------------------------------

PUBLIC   XPage
XPage:

; ------ zji¨tˆn¡ ‡¡sel nov˜ch videostr nek

         call      Vyraz                    ; ‡ten¡ slova
         jc        XPage1                   ; nenastavuje se
         mov       byte ptr ds:[Page1],al   ; aktivn¡ videostr nka
XPage1:  call      Vyraz
         jc        XPage2                   ; nenastavuje se
         mov       byte ptr ds:[Page2],al   ; v˜stupn¡ videostr nka

; ------ nastaven¡ nov‚ aktivn¡ videostr nky

XPage2:  mov       al,ds:[Page1]
         mov       bh,al
         mov       ah,5
         call      Int10                    ; nastaven¡ aktivn¡ str nky displeje

; ------ nastaven¡ p–vodn¡ pozice kurzoru

         mov       dx,ds:[KurzPoz]          ; aktu ln¡ pozice kurzoru
         mov       ah,2
         call      Int10                    ; nastaven¡ p–vodn¡ pozice kurzoru

; ------ navr cen¡ aktivn¡ videostr nky

         mov       ah,0
         mov       al,ds:[Page1]            ; aktivn¡ videostr nka
         ret

; -----------------------------------------------------------------------------
;        XPAGE
; -----------------------------------------------------------------------------

PUBLIC   XXPage
XXPage:

; ------ z mˆna videostr nek

         mov       ax,word ptr ds:[Page1]
         xchg      ah,al                    ; z mˆna videostr nek
         mov       word ptr ds:[Page1],ax

; ------ nastaven¡ nov‚ aktivn¡ videostr nky

         mov       al,ds:[Page1]
         mov       bh,al
         mov       ah,5
         call      Int10                    ; nastaven¡ aktivn¡ str nky displeje

; ------ nastaven¡ p–vodn¡ pozice kurzoru

         mov       dx,ds:[KurzPoz]          ; aktu ln¡ pozice kurzoru
         mov       ah,2
         call      Int10                    ; nastaven¡ p–vodn¡ pozice kurzoru

; ------ navr cen¡ v˜stupn¡ videostr nky

         mov       ah,0
         mov       al,ds:[Page2]            ; v˜stupn¡ videostr nka
         ret

; -----------------------------------------------------------------------------
;        WINDOW
; -----------------------------------------------------------------------------

PUBLIC   XWind
XWind:   mov       di,offset Wind1          ; lev˜ okraj okna
         mov       cx,4                     ; po‡et parametr–
XWind1:  call      Vyraz                    ; parametr - rozmˆr okna
         jc        XWind2                   ; parametr se nenastavuje
         mov       ds:[di],ax               ; nastaven¡ parametru
XWind2:  add       di,2                     ; zv˜¨en¡ adresy
         loop      XWind1                   ; dal¨¡ parametr
         mov       ax,ds:[Wind1]            ; lev  pozice
         ret

; -----------------------------------------------------------------------------
;        PALETE
; -----------------------------------------------------------------------------

PUBLIC   XPal
XPal:
         mov       di,offset TabPal         ; tabulka palet
         mov       cx,17                    ; po‡et palet v definici

; ------ v˜po‡et hodnot paletov˜ch registr–

XPal1:   call      Vyraz                    ; ‡ten¡ hodnoty registru
         jc        XPal2                    ; hodnota se nemˆn¡
         mov       ds:[di],al               ; definice palety
XPal2:   inc       di
         loop      XPal1                    ; dal¨¡ registr

; ------ p©¡prava registr– pro p©edefinov n¡ palet

         mov       si,offset TabPal         ; ukazatel tabulky palet
         mov       cx,16                    ; po‡et palet k p©edefinov n¡
         mov       ah,0                     ; ‡¡slo registru 0
         cld                                ; smˆr nahoru
         push      ds
         xor       dx,dx
         mov       ds,dx
         mov       dx,ds:[463h]             ; adresa ©¡dic¡ho registru CRT
         pop       ds
         add       dx,6                     ; stavov˜ registr CRT

; ------ synchronizace na za‡ tek vertik ln¡ho synchroniza‡n¡ho impulsu

XPal4:   in        al,dx
         test      al,8
         jnz       XPal4                   ; ‡ek n¡ na konec synchroimpulsu
XPal5:   in        al,dx
         test      al,8
         jz        XPal5                   ; ‡ek n¡ na za‡ tek synchoimpulsu

; ------ definice v¨ech paletov˜ch registr–

         mov       dx,3c0h                  ; adresa portu ©adi‡e
XPal6:   mov       al,ah                    ; ‡¡slo registru
         out       dx,al                    ; nastaven¡ ‡¡sla registru
         lodsb                              ; po‘adovan  paleta registru
         out       dx,al                    ; definice palety
         inc       ah                       ; zv˜¨en¡ ‡¡sla registru
         loop      XPal6                   ; definice dal¨¡ho registru

; ------ p©edefinov n¡ paletov‚ho registru pozad¡

         mov       al,11h                   ; ‡¡slo registru palety pozad¡
         out       dx,al                    ; nastaven¡ ‡¡sla registru
         lodsb                              ; po‘adovan  paleta registru
         out       dx,al                    ; definice palety registru pozad¡

; ------ opˆtovn‚ zapnut¡ videosign lu

         mov       al,20h                   ; ukon‡ovac¡ bajt
         out       dx,al                    ; zapnut¡ videosign lu
         ret

; -----------------------------------------------------------------------------
;        XCOLOR
; -----------------------------------------------------------------------------

PUBLIC   XXCol
XXCol:
         ret

; -----------------------------------------------------------------------------
;        SETCURS
; -----------------------------------------------------------------------------

PUBLIC   XSetCur
XSetCur:
         call      Vyraz                    ; pozice kurzoru
         jc        XSetCur1
         mov       byte ptr ds:[KurzPoz],al ; pozice
XSetCur1:call      Vyraz                    ; © dek kurzoru
         jc        XSetCur2
         mov       byte ptr ds:[KurzPoz+1],al ; © dek

XSetCur2:mov       dx,ds:[KurzPoz]          ; aktu ln¡ pozice kurzoru
         mov       ah,2
         mov       bh,ds:[Page1]
         call      Int10                    ; nastaven¡ p–vodn¡ pozice kurzoru

         mov       ah,0
         mov       al,byte ptr ds:[KurzPoz] ; sou‡asn  pozice
         ret

; -----------------------------------------------------------------------------
;        CURSOFF
; -----------------------------------------------------------------------------

PUBLIC   XCurOff
XCurOff:
         mov       dh,ds:[MaxRad]           ; maxim ln¡ po‡et © dk–
         mov       dl,0
         mov       ah,2
         mov       bh,ds:[Page1]
         call      Int10
         mov       ah,0
         mov       al,ds:[MaxRad]           ; © dek, na kter‚m je kurzor
         ret

; -----------------------------------------------------------------------------
;        LOAD
; -----------------------------------------------------------------------------

PUBLIC   XLoad
XLoad:

; ------ pokud objekt existuje, jeho zru¨en¡

         call      InpWord                  ; ‡ten¡ ‡¡sla objektu
         call      SrcObj                   ; nalezen¡ objektu v pamˆti
         jc        XLoad1                   ; objekt nen¡ v pamˆti
         call      DelObj                   ; zru¨en¡ objektu DX z pamˆti

; ------ otev©en¡ po‘adovan‚ho souboru

XLoad1:  mov       si,ax                    ; £schova ‡¡sla objektu
         push      ds
         mov       dx,ds:[ProgUkaz]         ; ukazatel na jm‚no programu
         mov       ds,ds:[ProgMem]          ; segment s programem
         mov       ax,3d00h
         int       21h                      ; otev©en¡ souboru
         pop       ds
         mov       bx,ax                    ; identifik tor souboru
         jnc       XLoad6                   ; soubor otev©en OK

; ------ chyba - soubor nenalezen

         mov       al,ds:[OldVMod]          ; p–vodn¡ videom¢d
         mov       ah,0
         call      Int10                    ; n vrat videom¢du

         mov       dx,offset FndTxt         ; text - "Soubor"
         mov       ah,9
         int       21h                      ; zobrazen¡ prvn¡ ‡ sti hl ¨en¡

XLoad2:  call      InpProg                  ; ‡ten¡ znaku
         or        al,al
         jz        XLoad3                   ; konec textu
         mov       dl,al
         mov       ah,2
         int       21h                      ; zobrazen¡ znaku jm‚na souboru
         jmp       short XLoad2

XLoad3:  mov       dx,offset Fnd2Txt        ; text "nenalezen"
XLoad4:  mov       ah,9
         int       21h                      ; zobrazen¡ zbytku hl ¨en¡

         jmp       Prerus2                  ; n vrat z programu

; ------ chyba - nedostatek pamˆti

XLoad5:  mov       al,ds:[OldVMod]          ; p–vodn¡ videom¢d
         mov       ah,0
         call      Int10                    ; n vrat videom¢du

         mov       dx,offset MemTxt         ; text - nedostatek pamˆti
         jmp       short XLoad4

; ------ zji¨tˆn¡ voln‚ho m¡sta pro jeden blok

XLoad6:  mov       dx,ds:[TopMem]           ; adresa k na‡ten¡ bloku
XLoad7:  mov       cx,ss                    ; konec pamˆti
         add       cx,0f00h                 ; rezerva pro z sobn¡k 4 KB
         sub       cx,ds:[TopMem]           ; voln˜ prostor v pamˆti
         jbe       XLoad5                   ; nen¡ voln  pamˆŸ
         cmp       cx,0f00h                 ; je blok vˆt¨¡ ne‘ 0f000h bajt– ?
         jbe       XLoad8                   ; nen¡ vˆt¨¡
         mov       cx,0f00h                 ; omezen¡ na 0f000h bajt–

; ------ na‡ten¡ jednoho bloku ze souboru

XLoad8:  shl       cx,1
         shl       cx,1
         shl       cx,1
         shl       cx,1                     ; p©evod na bajty
         push      ds
         push      dx
         mov       ds,dx                    ; segment k na‡ten¡ bloku souboru
         xor       dx,dx                    ; offset ke ‡ten¡ souboru
         mov       ah,3fh
         int       21h                      ; na‡ten¡ bloku ze souboru
         pop       dx
         pop       ds
         jc        XLoada                   ; chyba ‡ten¡ - konec

; ------ zv˜¨en¡ adresy segmentu

         cmp       ax,cx                    ; navr ceno v¡ce bajt– ne‘ bylo ?
         jbe       XLoad9                   ; £daj je OK
         mov       ax,cx                    ; omezen¡ na po‘adovan‚ bajty
XLoad9:  add       ax,15                    ; zaokrouhlen¡
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©evod na odstavce
         add       dx,ax                    ; zv˜¨en¡ segmentu
         or        ax,ax                    ; bylo nˆco na‡teno ?
         jnz       XLoad7                   ; bylo nˆco na‡teno - dal¨¡

; ------ inicializace ukazatel– objektu a pamˆti

XLoada:  mov       ax,dx                    ; segment konce dat
         sub       ax,ds:[TopMem]           ; velikost nov‚ho bloku
         push      ds
         mov       ds,ds:[TopMem]           ; za‡ tek nov‚ho bloku
         mov       ds:[0],si                ; ‡¡slo objektu
         mov       ds:[2],ax                ; velikost bloku
         pop       ds
         mov       ds:[TopMem],dx           ; nov˜ konec pamˆti

; ------ uzav©en¡ souboru

         mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru

; ------ nalezen¡ konce textu v programu

XLoadb:  call      InpProg                  ; ‡ten¡ znaku
         or        al,al
         jnz       XLoadb                   ; nen¡ konec textu - dal¨¡ znak
         ret

; -----------------------------------------------------------------------------
;        OBJECT
; -----------------------------------------------------------------------------

PUBLIC   XObj
XObj:    call      InpWord                  ; ‡¡slo objektu
         push      ax                       ; £schova ‡¡sla objektu
         call      Vyraz                    ; ‡ten¡ slova - pozice X
         mov       bx,ax                    ; pozice X
         call      Vyraz                    ; ‡ten¡ slova - linka Y
         mov       dx,ax                    ; linka Y
         pop       ax                       ; ‡¡slo objektu
         call      Objekt                   ; zobrazen¡ objektu
         ret

; -----------------------------------------------------------------------------
;        UNLOAD
; -----------------------------------------------------------------------------

PUBLIC   XUnld
XUnld:
         call      InpWord                  ; ‡ten¡ ‡¡sla objektu
         call      SrcObj                   ; nalezen¡ objektu v pamˆti
         jc        XUnld2                   ; objekt nen¡ v pamˆti
         call      DelObj                   ; zru¨en¡ objektu DX z pamˆti
XUnld2:  ret

; -----------------------------------------------------------------------------
;        DISP
; -----------------------------------------------------------------------------

PUBLIC   XDisp
XDisp:
         call      Vyraz                    ; sou©adnice X
         mov       dl,al                    ; sou©adnice X
         call      Vyraz                    ; sou©adnice Y
         mov       dh,al                    ; sou©adnice Y
         call      Vyraz                    ; barva textu
         mov       bl,al                    ; barva

; ------ nastaven¡ pozice kurzoru

XDisp1:  push      dx
         push      bx
         mov       ah,2
         mov       bh,ds:[Page2]            ; v˜stupn¡ str nka
         int       10h                      ; nastaven¡ pozice kurzoru
         pop       bx
         pop       dx

; ------ zobrazen¡ jednoho znaku

         call      InpProg                  ; ‡ten¡ dal¨¡ho znaku
         jz        XDisp2                   ; konec textu
         push      dx
         push      bx
         mov       ah,9
         mov       cx,1
         int       10h                      ; zobrazen¡ znaku
         pop       bx
         pop       dx

; ------ zv˜¨en¡ pozice kurzoru

         inc       dl                       ; zv˜¨en¡ pozice na © dku
         cmp       dl,ds:[MaxPoz]           ; dosa‘eno maxim ln¡ pozice ?
         jb        XDisp1                   ; nen¡ je¨tˆ maxim ln¡ pozice
         xor       dl,dl                    ; pozice 0
         inc       dh                       ; zv˜¨en¡ ‡¡sla © dku
         jmp       short XDisp1             ; zobrazen¡ dal¨¡ho znaku

XDisp2:  ret

; -----------------------------------------------------------------------------
;        POINT
; -----------------------------------------------------------------------------

PUBLIC   XPoint
XPoint:
         ret

; -----------------------------------------------------------------------------
;        LINE
; -----------------------------------------------------------------------------

PUBLIC   XLine
XLine:
         ret

; -----------------------------------------------------------------------------
;        RLINE
; -----------------------------------------------------------------------------

PUBLIC   XRLine
XRLine:
         ret

; -----------------------------------------------------------------------------
;        BOX
; -----------------------------------------------------------------------------

PUBLIC   XBox
XBox:
         ret

; -----------------------------------------------------------------------------
;        FBOX
; -----------------------------------------------------------------------------

PUBLIC   XFBox
XFBox:
         call      InpWord                  ; ‡ten¡ slova - barva
         call      GetTabMod                ; poskytnut¡ tabulky videom¢du
         call      word ptr cs:[bp+ModCLR]  ; vymaz n¡ displeje zadanou barvou

         ret

; -----------------------------------------------------------------------------
;        CIRC
; -----------------------------------------------------------------------------

PUBLIC   XCirc
XCirc:
         ret

; -----------------------------------------------------------------------------
;        FCIRC
; -----------------------------------------------------------------------------

PUBLIC   XFCirc
XFCirc:
         ret

; -----------------------------------------------------------------------------
;        PRESS
; -----------------------------------------------------------------------------

PUBLIC   XPress
XPress:

         ret

; -----------------------------------------------------------------------------
;        TESTKEY
; -----------------------------------------------------------------------------

PUBLIC   XTstKey
XTstKey:
         mov       ah,1
         int       16h                      ; test stavu kl vesnice
         jnz       XTstKey1                 ; je p©ipraven nˆjak˜ znak
         xor       ax,ax                    ; nen¡ ‘ dn˜ znak
XTstKey1:ret

; -----------------------------------------------------------------------------
;        GETKEY
; -----------------------------------------------------------------------------

PUBLIC   XGtKey
XGtKey:
         xor       ax,ax
         int       16h                      ; vstup znaku z kl vesnice
         ret

; -----------------------------------------------------------------------------
;        FLUSHKEY
; -----------------------------------------------------------------------------

PUBLIC   XFlush
XFlush:  call      XTstKey                  ; test stavu kl vesnice
         jz        XFlush2                  ; nen¡ dal¨¡ znak
         call      XGtKey                   ; zru¨en¡ znaku
         jmp       short XFlush             ; dal¨¡ znak
XFlush2: ret

; -----------------------------------------------------------------------------
;        INPUT
; -----------------------------------------------------------------------------

PUBLIC   XInp
XInp:
         ret

; -----------------------------------------------------------------------------
;        SOUND
; -----------------------------------------------------------------------------

PUBLIC   XSound
XSound:
         call      Vyraz                    ; ‡ten¡ slova
         or        ax,ax                    ; vypnut¡ gener toru ?
         jnz       Sound2                   ; nen¡ vypnut¡ gener toru

         in        al,[61h]
         and       al,not 3
         out       [61h],al                 ; vypnut¡ gener toru
         ret


Sound2:  mov       bx,ax
         mov       al,0b6h
         out       [43h],al
         mov       al,bl
         out       [42h],al
         mov       al,bh
         out       [42h],al
         in        al,[61h]
         or        al,3
         out       [61h],al

         ret

; -----------------------------------------------------------------------------
;        TON
; -----------------------------------------------------------------------------

PUBLIC   XTon
XTon:
         ret

; -----------------------------------------------------------------------------
;        MUSIC
; -----------------------------------------------------------------------------

PUBLIC   XMusic
XMusic:
         ret

; -----------------------------------------------------------------------------
;        MUSICSTOP
; -----------------------------------------------------------------------------

PUBLIC   XMStop
XMStop:
         ret

; -----------------------------------------------------------------------------
;        MUSICGET
; -----------------------------------------------------------------------------

PUBLIC   XMusGet
XMusGet:
         ret

; -----------------------------------------------------------------------------
;        WAIT
; -----------------------------------------------------------------------------

PUBLIC   XWait
XWait:
         call      Vyraz                    ; ‡ten¡ slova
         sti                                ; povolen¡ p©eru¨en¡
XWait1:  cmp       word ptr cs:[Citac],ax
         jb        XWait1                   ; nen¡ je¨tˆ dosa‘en ‡as
         mov       word ptr cs:[Citac],0    ; inicializace ‡¡ta‡e
         ret

; -----------------------------------------------------------------------------
;        TIME
; -----------------------------------------------------------------------------

PUBLIC   XTime
XTime:
         ret

; -----------------------------------------------------------------------------
;        DATE
; -----------------------------------------------------------------------------

PUBLIC   XDate
XDate:
         ret

; -----------------------------------------------------------------------------
;        XMOUSE
; -----------------------------------------------------------------------------

PUBLIC   XXMous
XXMous:
         ret

; -----------------------------------------------------------------------------
;        YMOUSE
; -----------------------------------------------------------------------------

PUBLIC   XYMous
XYMous:
         ret

; -----------------------------------------------------------------------------
;        GETMOUSE
; -----------------------------------------------------------------------------

PUBLIC   XKMous
XKMous:
         ret

; -----------------------------------------------------------------------------
;        MOUSEON
; -----------------------------------------------------------------------------

PUBLIC   XMon
XMon:
         ret

; -----------------------------------------------------------------------------
;        MOUSEOFF
; -----------------------------------------------------------------------------

PUBLIC   XMoff
XMoff:
         ret

; -----------------------------------------------------------------------------
;        CURMOUSE
; -----------------------------------------------------------------------------

PUBLIC   XDefm
XDefm:
         ret

; -----------------------------------------------------------------------------
;        WINMOUSE
; -----------------------------------------------------------------------------

PUBLIC   XWinm
XWinm:
         ret

; -----------------------------------------------------------------------------
;        RND
; -----------------------------------------------------------------------------

PUBLIC   XRnd
XRnd:    call      Vyraz                    ; po‘adovan˜ interval
         mov       bx,ax                    ; interval
         or        ax,ax
         jz        XRnd2

         mov       ax,word ptr ds:[RandNum]
         mov       si,word ptr ds:[RandNum+2]
         rol       ax,1
         rol       si,1
         xor       ax,ss:[si]
         xor       si,ax
         mov       word ptr ds:[RandNum],ax
         mov       word ptr ds:[RandNum+2],si

         xor       dx,dx
         div       bx
         mov       ax,dx

XRnd2:   or        ax,ax
         ret

RandNum  dd        0



; -----------------------------------------------------------------------------
;        BYTE
; -----------------------------------------------------------------------------

PUBLIC   XUsrByte
XUsrByte:call      InpWord                  ; adresa promˆnn‚
         mov       bx,ax                    ; adresa promˆnn‚
         call      Vyraz                    ; v˜po‡et v˜razu
         push      ds
         mov       ds,ds:[DatMem]
         mov       ds:[bx],al               ; nastaven¡ promˆnn‚ BYTE
         pop       ds
         ret

; -----------------------------------------------------------------------------
;        WORD
; -----------------------------------------------------------------------------

PUBLIC   XUsrWord
XUsrWord:call      InpWord                  ; adresa promˆnn‚
         mov       bx,ax                    ; adresa promˆnn‚
         call      Vyraz                    ; v˜po‡et v˜razu
         push      ds
         mov       ds,ds:[DatMem]
         mov       ds:[bx],ax               ; nastaven¡ promˆnn‚ WORD
         pop       ds
         ret

; -----------------------------------------------------------------------------
;        BYTE index
; -----------------------------------------------------------------------------

PUBLIC   XUsrBytI
XUsrBytI:call      InpWord                  ; adresa promˆnn‚
         mov       bx,ax                    ; adresa promˆnn‚
         call      Vyraz                    ; v˜po‡et indexu
         add       bx,ax                    ; adresa promˆnn‚
         push      ds
         mov       ds,ds:[DatMem]
         mov       ds:[bx],al               ; nastaven¡ promˆnn‚ BYTE
         pop       ds
         ret

; -----------------------------------------------------------------------------
;        WORD index
; -----------------------------------------------------------------------------

PUBLIC   XUsrWorI
XUsrWorI:call      InpWord                  ; adresa promˆnn‚
         mov       bx,ax                    ; adresa promˆnn‚
         call      Vyraz                    ; v˜po‡et v˜razu
         add       bx,ax
         add       bx,ax                    ; skute‡n  adresa promˆnn‚
         push      ds
         mov       ds,ds:[DatMem]
         mov       ds:[bx],ax               ; nastaven¡ promˆnn‚ WORD
         pop       ds
         ret

; *****************************************************************************
;
;                          Obsluhy funkc¡ BIOS
;
; *****************************************************************************

PUBLIC   Int10
Int10:   pushf
         push      si
         push      di
         push      bp
         push      ds
         push      es
         int       10h
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         popf
         ret




; *****************************************************************************
;
;                         Datov˜ segment
;
; *****************************************************************************

TabOper  label     word                   ;* tabulka obsluh oper tor–

         dw        offset XNop              ; 0:
         dw        offset XNop              ; 1: (
         dw        offset XNop              ; 2: )
         dw        offset OpMoc             ; 3: ^
         dw        offset OpMul             ; 4: *
         dw        offset OpDiv             ; 5: /
         dw        offset OpMod             ; 6: MOD
         dw        offset OpShl             ; 7: <<
         dw        offset OpShr             ; 8: >>
         dw        offset OpAdd             ; 9: +
         dw        offset OpSub             ; 10: -
         dw        offset OpEqu             ; 11: =
         dw        offset OpNeq             ; 12: <>
         dw        offset OpLt              ; 13: <
         dw        offset OpGt              ; 14: >
         dw        offset OpLte             ; 15: <=
         dw        offset OpGte             ; 16: >=
         dw        offset OpNot             ; 17: NOT
         dw        offset OpAnd             ; 18: AND
         dw        offset OpOr              ; 19: OR
         dw        offset OpXor             ; 20: XOR


TabFnc   label     word                   ;* tabulka intern¡ch funkc¡

         dw        offset XNop              ; 0   (LINK)
         dw        offset XNop              ; 1   (INCLUDE)
         dw        offset XNop              ; 2   (BYTE)
         dw        offset XNop              ; 3   (WORD)
         dw        offset XNop              ; 4   (STRING)
         dw        offset XNop              ; 5   (PROC)
         dw        offset XNop              ; 6 ENDPROC
         dw        offset XNop              ; 7 RETURN
         dw        offset XExec             ; 8 EXEC
         dw        offset XIf               ; 9 IF
         dw        offset XNop              ; 10   (THEN)
         dw        offset XElse             ; 11   ELSE
         dw        offset XNop              ; 12   (ENDIF)
         dw        offset XFor              ; 13 FOR
         dw        offset XNop              ; 14   (TO)
         dw        offset XNop              ; 15   (STEP)
         dw        offset XNop              ; 16   (DO)
         dw        offset XOn               ; 17 ON
         dw        offset XEndDo            ; 18 ENDDO
         dw        offset XNop              ; 19   (EXIT)
         dw        offset XCase             ; 20 CASE
         dw        offset XIn               ; 21 IN
         dw        offset XOut              ; 22 OUT
         dw        offset XNop              ; 23   (ENDCASE)
         dw        offset XVal              ; 24 VAL
         dw        offset XStr              ; 25 STR
         dw        offset XLen              ; 26 LEN
         dw        offset XCard             ; 27 CARD
         dw        offset XVideo            ; 28 VIDEO
         dw        offset XNop              ; 29   (GVIDEO)
         dw        offset XMode             ; 30 MODE
         dw        offset XPage             ; 31 PAGE
         dw        offset XXPage            ; 32 XPAGE
         dw        offset XWind             ; 33 WINDOW
         dw        offset XPal              ; 34 PALETE
         dw        offset XXCol             ; 35 XCOLOR
         dw        offset XSetCur           ; 36 SETCURS
         dw        offset XCurOff           ; 37 CURSOFF
         dw        offset XLoad             ; 38 LOAD
         dw        offset XObj              ; 39 OBJECT
         dw        offset XUnld             ; 40 UNLOAD
         dw        offset XDisp             ; 41 DISP
         dw        offset XPoint            ; 42 POINT
         dw        offset XLine             ; 43 LINE
         dw        offset XRLine            ; 44 RLINE
         dw        offset XBox              ; 45 BOX
         dw        offset XFBox             ; 46 FBOX
         dw        offset XCirc             ; 47 CIRC
         dw        offset XFCirc            ; 48 FCIRC
         dw        offset XPress            ; 49 PRESS
         dw        offset XTstKey           ; 50 TESTKEY
         dw        offset XGtKey            ; 51 GETKEY
         dw        offset XFlush            ; 52 FLUSHKEY
         dw        offset XInp              ; 53 INPUT
         dw        offset XSound            ; 54 SOUND
         dw        offset XTon              ; 55 TON
         dw        offset XMusic            ; 56 MUSIC
         dw        offset XMStop            ; 57 MUSICSTOP
         dw        offset XMusGet           ; 58 MUSICGET
         dw        offset XWait             ; 59 WAIT
         dw        offset XTime             ; 60 TIME
         dw        offset XDate             ; 61 DATE
         dw        offset XXMous            ; 62 XMOUSE
         dw        offset XYMous            ; 63 YMOUSE
         dw        offset XKMous            ; 64 GETMOUSE
         dw        offset XMon              ; 65 MOUSEON
         dw        offset XMoff             ; 66 MOUSEOFF
         dw        offset XDefm             ; 67 CURMOUSE
         dw        offset XWinm             ; 68 WINMOUSE
         dw        offset XRnd              ; 69 XRND

         dw        0f8h - 69 - 1 dup(offset XNop)

         dw        offset XUsrByte          ; f8h BYTE
         dw        offset XUsrWord          ; f9h WORD
         dw        offset XUsrBytI          ; fah BYTE index
         dw        offset XUsrWorI          ; fbh WORD index

         dw        3 dup(offset XNop)

         dw        offset XNop              ; ffh u‘ivatelsk  procedura



; Struktura objekt–:
;                     0 (2) = ‡¡slo objektu
;                     2 (2) = velikost bloku pamˆti (v odstavc¡ch)
;                     4 (2) = rozmˆry X
;                     6 (2) = rozmˆry Y
;                     8 (2) = po‡et barevn˜ch rovin
;                    10 (2) = barva pozad¡
;                    12 (2) = po‡et bajt– definice palet
;                    14 (1) = videom¢d
;                    15 (1) = parametry
;                                bit 0: 1=komprese
;                                bit 1: 1=textov˜ m¢d
;                                bit 2: 1=paraleln¡ ulo‘en¡ barev
;                    10h    = data

ModSir   EQU       0                        ; ¨¡©ka © dku (bod–)
ModVys   EQU       2                        ; po‡et linek celkem
ModSirB  EQU       4                        ; po‡et bajt– na linku
ModRov   EQU       4                        ; po‡et barevn˜ch rovin
ModCLR   EQU       6                        ; obsluha vymaz n¡ displeje
ModSet   EQU       8                        ; nastaven¡ parametr– pro zobrazen¡
ModDisp  EQU       10                       ; obsluha zobrazen¡ linky
ModNext  EQU       12                       ; nastaven¡ adresy dal¨¡ roviny

TabMod   label     word                   ;* tabulka videom¢d–

                                          ;* 0: 40x25 text
         dw        40                       ; ¨¡©ka (jednotek)
         dw        25                       ; v˜¨ka (linek)
         dw        2                        ; po‡et barevn˜ch rovin
         dw        offset ClrTXT            ; vymaz n¡ nastavenou barvou
         dw        offset SetTXT            ; nastaven¡ parametr– pro zobrazen¡
         dw        offset DispTxt           ; zobrazen¡ linky
         dw        offset NextTxt           ; nastaven¡ adresy dal¨¡ roviny

TabMod0  label     word                     ; n vˆ¨t¡ pro v˜po‡et d‚lky polo‘ky

                                          ;* 1: 40x25 text
         dw        40,25,2
         dw        offset ClrTXT
         dw        offset SetTXT
         dw        offset DispTxt
         dw        offset NextTXT

                                          ;* 2: 80x25 text
         dw        80,25,2
         dw        offset ClrTXT
         dw        offset SetTXT
         dw        offset DispTxt
         dw        offset NextTXT

                                          ;* 3: 80x25 text
         dw        80,25,2
         dw        offset ClrTXT
         dw        offset SetTXT
         dw        offset DispTxt
         dw        offset NextTXT

                                          ;* 4: 320x200/4 graf
         dw        320,200,2
         dw        offset ClrCGA
         dw        offset SetCGA
         dw        offset DispCGA
         dw        offset NextCGA

                                          ;* 5: 320x200/4 graf
         dw        320,200,2
         dw        offset ClrCGA
         dw        offset SetCGA
         dw        offset DispCGA
         dw        offset NextCGA

                                          ;* 6: 640x200/2 graf
         dw        640,200,1
         dw        offset ClrCGA
         dw        offset SetCGA
         dw        offset DispCGA
         dw        offset NextCGA

                                          ;* 7: 80x25 text
         dw        80,25,2
         dw        offset ClrTXT
         dw        offset SetTXT
         dw        offset DispTXT
         dw        offset NextTXT

                                          ;* 8: 160x200/16 graf.
         dw        160,200,4
         dw        offset ClrPCJ
         dw        offset SetPCJ
         dw        offset DispPCJ
         dw        offset NextPCJ

                                          ;* 9: 320x200/16 graf.
         dw        320,200,4
         dw        offset ClrPCJ
         dw        offset SetPCJ
         dw        offset DispPCJ
         dw        offset NextPCJ

                                          ;* 10: 640x200/4 graf.
         dw        640,200,4
         dw        offset ClrPCJ
         dw        offset SetPCJ
         dw        offset DispPCJ
         dw        offset NextPCJ

                                          ;* 11: intern¡
         dw        80,25,2
         dw        offset ClrTXT
         dw        offset SetTXT
         dw        offset DispTxt
         dw        offset NextTXT

                                          ;* 12: intern¡
         dw        80,25,2
         dw        offset ClrTXT
         dw        offset SetTXT
         dw        offset DispTxt
         dw        offset NextTXT

                                          ;* 13: 320x200/16 graf
         dw        320,200,4
         dw        offset ClrEGA
         dw        offset SetEGA
         dw        offset DispEGA
         dw        offset NextEGA

                                          ;* 14: 640x200/16 graf
         dw        640,200,4
         dw        offset ClrEGA
         dw        offset SetEGA
         dw        offset DispEGA
         dw        offset NextEGA

                                          ;* 15: 640x350/2 graf
         dw        640,350,1
         dw        offset ClrEGA
         dw        offset SetEGA
         dw        offset DispEGA
         dw        offset NextEGA

                                          ;* 16: 640x350/16 graf
         dw        640,350,4
         dw        offset ClrEGA
         dw        offset SetEGA
         dw        offset DispEGA
         dw        offset NextEGA

                                          ;* 17: 640x480/2 graf
         dw        640,480,1
         dw        offset ClrCGA
         dw        offset SetCGA
         dw        offset DispCGA
         dw        offset NextCGA

                                          ;* 18: 640x480/16 graf
         dw        640,480,4
         dw        offset ClrEGA
         dw        offset SetEGA
         dw        offset DispEGA
         dw        offset NextEGA

                                          ;* 19: 320x200/256 graf
         dw        320,200,8
         dw        offset ClrMCG
         dw        offset SetMCG
         dw        offset DispMCG
         dw        offset NextMCG

TabPal   db        0,1,2,3,4,5,14h,7,38h,39h,3ah,3bh,3ch,3dh,3eh,3fh,0 ; palety

; ------ parametry pro zobrazen¡ objekt–

                                          ;* parametry ze z hlav¡ objektu
Sirka    dw        0                        ; ¨¡©ka v˜©ezu (pozic)
Vyska    dw        0                        ; v˜¨ka v˜©ezu (linek)
Rovin    dw        0                        ; po‡et barevn˜ch rovin
Pozadi   dw        0                        ; barva pozad¡
Palet    dw        0                        ; po‡et bajt– palet
Mod      db        0                        ; videom¢d displeje
Param    db        0                        ; parametry
                                            ;  bit 0: 1=komprese
                                            ;  bit 1: 1=textov˜ videom¢d
                                            ;  bit 2: 1=paraleln¡ ulo‘en¡ barev
                                            ;  bit 3: 1=je maska pozad¡

                                          ;* parametry pro zobrazen¡
ZdrojAdr dd        0                        ; zdrojov  adresa obr zku (roviny)
MaskAdr  dd        0                        ; adresa masky
MaskFrst db        0                        ; maska prvn¡ho bajtu linky
MaskLst  db        0                        ; maska posledn¡ho bajtu linky

; ------ obsluha kl vesnice

Keys     dw        0                        ; posledn¡ znak z kl vesnice

; ------ parametry pro pr ci s pamˆt¡

ProgUkaz dw        0                        ; ukazatel programu
DatMem   dw        SEG SegProg              ; segment s daty programu
ProgMem  dw        0                        ; segment s na‡ten˜m programem
ObjMem   dw        0                        ; segment s prvn¡m objektem
TopMem   dw        0                        ; segment za‡ tku voln‚ pamˆti

; ------ parametry displeje

Wind1    dw        0                        ; lev˜ okraj okna
Wind2    dw        0                        ; horn¡ okraj okna
Wind3    dw        0                        ; prav˜ okraj okna
Wind4    dw        0                        ; spodn¡ okraj okna

BitDisp  dw        0                        ; m¢d displeje (p©¡znakov‚ bity)
OldVMod  db        3                        ; p–vodn¡ videom¢d
VMod     db        3                        ; aktu ln¡ videom¢d
SegVRAM  dw        0b800h                   ; segment videopamˆti
DelVRAM  dw        2000h                    ; d‚lka videostr nky
EgaVga   db        1                        ; p©¡znak karty EGA/VGA
KurzPoz  dw        0                        ; aktu ln¡ pozice kurzoru
MaxPoz   db        80                       ; maxim ln¡ po‡et pozic
MaxRad   db        25                       ; maxim ln¡ po‡et © dk–

Page1    db        0                        ; aktivnˆ zobrazen  str nka
Page2    db        0                        ; v˜stupn¡ str nka


; ------ Chybov‚ texty

MemTxt   db        'Chyba - nedostatek pameti !',13,10,'$'

FndTxt   db        'Chyba - soubor $'
Fnd2Txt  db        ' nenalezen !',13,10,'$'

RetKod   db        -1                       ; n vrat. k¢d z programu (=p©eru¨.)
SegPSP   dw        0                        ; £schova adresy PSP


Code     ENDS

; *****************************************************************************
;
;                  P©echodn˜ z sobn¡k pro interpreter
;
; *****************************************************************************

Stack    SEGMENT   stack para

         db        20h dup(0)

Stack    ENDS

; *****************************************************************************
;
;                       Segment programu
;
; *****************************************************************************

SegProg  SEGMENT PARA


SegProg  ENDS

         END       Start

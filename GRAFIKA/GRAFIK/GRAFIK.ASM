
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                            G R A F I K
;
;                          grafick˜ editor
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

Code     SEGMENT
         ASSUME    cs:Code,ds:Data

; ------ inicializace segmentov˜ch registr–

Start:   sti
         mov       ax,SEG Data              ; datov˜ segment
         mov       ds,ax                    ; DS <- datov˜ segment
         mov       ds:[SegPSP],es           ; £schova segmentu PSP
         mov       es,ax                    ; ES <- datov˜ segment

; ------ £schova videom¢du

         mov       ah,0fh
         call      INT10                    ; poskytnut¡ videom¢du
         mov       ds:[OldVMod],al          ; £schova videom¢du

; ------ nastaven¡ pracovn¡ho videom¢du

         mov       ax,16
         call      INT10

; ------ test, zda je nainstalovan  my¨

         xor       ax,ax
         call      Mouse
         inc       ax
         jz        Inst11                   ; my¨ je nainstalovan 
         and       byte ptr ds:[Param],not 1 ; zru¨en¡ p©¡znaku my¨i


Inst11:
         call      ClrDisp

         mov       cx,14
         mov       bx,offset TabIkon
Inst14:  mov       si,ds:[bx]
         mov       di,ds:[bx+2]
         call      DispIkon
         add       bx,4
         loop      Inst14

         call      DispColr
         call      DispBarv

; ------ definice okna pro my¨

         xor       cx,cx
         mov       dx,ds:[MaxX]
         mov       ax,7
         call      Mouse
         xor       cx,cx
         mov       dx,ds:[MaxY]
         mov       ax,8
         call      Mouse

         mov       dx,offset Kurzor1
         call      DefMouse

         xor       dx,dx
         xor       cx,cx
         call      MouseSet

         call      MouseOn

         xor       ax,ax
         int       16h




; -----------------------------------------------------------------------------
;        n vrat z programu
; -----------------------------------------------------------------------------

Navrat   PROC      NEAR

; ------ n vrat videom¢du

         mov       al,ds:[OldVMod]          ; p–vodn¡ videom¢d
         mov       ah,0
         call      Int10                    ; n vrat p–vodn¡ho videom¢du

; ------ ukon‡en¡ programu

         mov       ax,4c00h
         int       21h

Navrat   ENDP

; *****************************************************************************
;
;                             Obsluha my¨i
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;        definice kurzoru my¨i
; -----------------------------------------------------------------------------
; VSTUP: DS:DX=adresa definice kurzoru my¨i
;        DS=datov˜ segment
; -----------------------------------------------------------------------------

DefMouse PROC      NEAR

         cmp       dx,ds:[KurzMous]         ; je ji‘ nadefinovan˜ ?
         je        DefMous9                 ; je ji‘ nadefinovan˜
         mov       ds:[KurzMous],dx         ; £schova adresy definice

; ------ definice kurzoru my¨i

         push      ax
         push      bx
         push      cx
         push      dx

         mov       ax,9
         mov       bx,1
         mov       cx,1
         call      Mouse

         pop       dx
         pop       cx
         pop       bx
         pop       ax

DefMous9:ret

DefMouse ENDP

; -----------------------------------------------------------------------------
;        vypnut¡ kurzoru my¨i
; -----------------------------------------------------------------------------

MouseOff PROC      NEAR

         push      ax
         mov       ax,2
         jmp       short MouseOn1

MouseOff ENDP

; -----------------------------------------------------------------------------
;        zapnut¡ kurzoru my¨i
; -----------------------------------------------------------------------------

MouseOn  PROC      NEAR

         push      ax
         mov       ax,1
MouseOn1:push      bx
         push      cx
         push      dx

         call      Mouse

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

MouseOn  ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ pozice my¨i
; -----------------------------------------------------------------------------

MouseSet PROC      NEAR

         push      ax
         mov       ax,4
         call      Mouse
         pop       ax
         ret

MouseSet ENDP

; -----------------------------------------------------------------------------
;        navr cen¡ pozice a stavu my¨i
; -----------------------------------------------------------------------------
; VSTUP:  DS=datov˜ segment
; VSTUP: BX=bit 0: lev‚ tla‡¡tko
;            bit 1: prav‚ tla‡¡tko
;            bit 2: prost©edn¡ tla‡¡tko
;         CX=sloupec
;         DX=© dek
;         CY=nebyla zmˆna
; -----------------------------------------------------------------------------

MouseGet PROC      NEAR

         push      ax
         mov       ax,3

         mov       bl,ds:[OldKey]
         mov       cx,ds:[OldX]
         mov       dx,ds:[OldY]

         call      Mouse
         and       bl,7
         cmp       cx,ds:[OldX]
         jne       MouseGt2
         cmp       dx,ds:[OldY]
         jne       MouseGt2
         cmp       bl,ds:[OldKey]
         stc
         je        MouseGt3
MouseGt2:clc
MouseGt3:pop       ax
         ret

MouseGet ENDP

; -----------------------------------------------------------------------------
;        £schova stavu my¨i (BX, CX a DX po n vratu z MouseGet)
; -----------------------------------------------------------------------------

MouseOld PROC      NEAR

         mov       ds:[OldX],cx
         mov       ds:[OldY],dx
         mov       ds:[OldKey],bl
         ret

MouseOld ENDP

; -----------------------------------------------------------------------------
;        obsluha my¨i
; -----------------------------------------------------------------------------

Mouse    PROC      NEAR

         test      byte ptr ds:[Param],1    ; je my¨ ?
         jz        Mouse4                   ; nen¡ my¨

         push      si
         push      di
         push      bp
         push      ds
         push      es

         sti
         int       33h
         sti

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
Mouse4:  ret

Mouse    ENDP

; *****************************************************************************
;
;                      Univerz ln¡ obsluha displeje
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;                     vymaz n¡ displeje
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; -----------------------------------------------------------------------------

ClrDisp  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      di
         push      es

; ------ vymaz n¡ obrazovky

         mov       ax,ds:[RozmerB]
         mul       word ptr ds:[RozmerY]
         mov       cx,ax
         shl       cx,1
         xor       di,di
         mov       es,ds:[SegVRAM]
         mov       ax,-1
         cld
         rep       stosw

; ------ n vrat registr–

         pop       es
         pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

ClrDisp  ENDP

;þ
; -----------------------------------------------------------------------------
;                  zobrazen¡ ikony (32*32 bod–, v¨echny roviny)
; -----------------------------------------------------------------------------
; VSTUP: DI=adresa ve videopamˆti
;        DS:SI=adresa obr zku
;        DS=datov˜ segment
; -----------------------------------------------------------------------------

DispIkon PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      es

; ------ inicializace registr– videokarty

         call      DeIniReg                 ; inicializace registr– videokarty
         mov       es,ds:[SegVRAM]          ; segment videopamˆti
         mov       bl,1                     ; maska z pisov‚ roviny
         mov       bh,ds:[Rovin]            ; ‡¡ta‡ rovin

; ------ p©¡prava barevn‚ roviny

DispIkn1:mov       dx,3c4h
         mov       al,2
         out       dx,al
         inc       dx
         mov       al,bl
         out       dx,al
         mov       dx,ds:[RozmerB]          ; d‚lka linky
         dec       dx
         dec       dx
         cld

; ------ zobrazen¡ jedn‚ roviny

         cld
         mov       cx,32                    ; po‡et linek
         push      di
DispIkn2:lodsw
         xchg      ah,al
         mov       es:[di+2],ax
         lodsw
         xchg      ah,al
         stosw
         add       di,dx
         loop      DispIkn2
         pop       di

; ------ p©¡prava pro dal¨¡ rovinu

         shl       bl,1
         dec       bh
         jnz       DispIkn1

; ------ n vrat registr–

         pop       es
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispIkon ENDP

; -----------------------------------------------------------------------------
;                        zobrazen¡ aktivn¡ch barev
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; -----------------------------------------------------------------------------

DispColr PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      bp
         push      si
         push      di
         push      es

; ------ inicializace registr– pro zobrazen¡ pozad¡

         mov       al,ds:[BarvaB]           ; barva pozad¡
         call      InitReg                  ; inicializace registr– videokarty
         mov       es,ds:[SegVRAM]          ; segment videopamˆti
         mov       dx,ds:[RozmerB]          ; d‚lka linky
         sub       dx,8
         cld

; ------ zobrazen¡ pozad¡

         mov       di,ds:[AdrColor]         ; adresa k zobrazen¡ barev
         cld
         mov       bx,32                    ; po‡et linek
         mov       ch,0
DispCol2:mov       al,7fh
         stosb
         mov       cl,7
         mov       al,0ffh
         rep       stosb
         add       di,dx
         dec       bx
         jnz       DispCol2

; ------ inicializace registr– pro zobrazen¡ pop©ed¡

         mov       al,ds:[BarvaF]           ; barva pop©ed¡
         call      InitReg                  ; inicializace registr– videokarty
         cld

; ------ zobrazen¡ pop©ed¡

         mov       di,ds:[AdrColor]         ; adresa k zobrazen¡ barev
         mov       ax,8
         mul       word ptr ds:[RozmerB]
         add       di,ax
         add       di,2                     ; adresa po‡ tku
         mov       dx,ds:[RozmerB]          ; d‚lka linky
         sub       dx,4

         cld
         mov       bx,16                    ; po‡et linek
         mov       ch,0
         mov       al,0ffh
DispCol3:mov       cl,4
         rep       stosb
         add       di,dx
         dec       bx
         jnz       DispCol3

; ------ n vrat registr–

         call      DeIniReg
         pop       es
         pop       di
         pop       si
         pop       bp
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispColr ENDP

; -----------------------------------------------------------------------------
;                        zobrazen¡ v¨ech barev
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; -----------------------------------------------------------------------------

DispBarv PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      bp
         push      si
         push      di
         push      es

; ------ inicializace registr– pro zobrazen¡ jedn‚ barvy

         mov       es,ds:[SegVRAM]          ; segment videopamˆti
         mov       di,ds:[AdrBarv]          ; adresa k zobrazen¡ barev
         mov       dx,ds:[RozmerB]          ; d‚lka linky
         sub       dx,4
         mov       bl,0                     ; ukazatel barev
DispBrv1:mov       al,bl                    ; barva
         call      InitReg                  ; inicializace registr– videokarty
         cld

; ------ zobrazen¡ jedn‚ barvy

         cld
         mov       cx,8                     ; po‡et linek
         push      di
DispBrv2:mov       al,7fh
         stosb
         mov       al,0ffh
         stosb
         stosb
         stosb
         add       di,dx
         loop      DispBrv2
         pop       di

; ------ p©¡prava pro zobrazen¡ dal¨¡ barvy

         add       di,4                     ; adresa pro prav˜ sloupec
         xor       bl,8                     ; zmˆna p©¡znaku vysv¡cen¡
         test      bl,8
         jnz       DispBrv1
         inc       bx
         add       di,8*80-8
         cmp       bl,8
         jne       DispBrv1

; ------ n vrat registr–

         call      DeIniReg
         pop       es
         pop       di
         pop       si
         pop       bp
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispBarv ENDP



;; -----------------------------------------------------------------------------
;;                          zobrazen¡ obr zku (2 barvy)
;; -----------------------------------------------------------------------------
;; VSTUP: AL=barva
;;        BX=po‡ te‡n¡ pozice
;;        CX=¨¡©ka obr zku (bod–)
;;        DX=po‡ te‡n¡ linka
;;        SI=v˜¨ka obr zku
;;        DI=adresa obr zku
;;        DS=datov˜ segment
;; -----------------------------------------------------------------------------
;
;Pict     PROC      NEAR
;
;; ------ £schova registr–
;
;         push      ax
;         push      bx
;         push      cx
;         push      dx
;         push      si
;         push      di
;         push      bp
;         push      es
;
;; ------ inicializace registr– videokarty
;
;         call      InitReg                  ; inicializace registr– videokarty
;
;; ------ v˜po‡et adresy ve videopamˆti
;
;         mov       ax,ds:[RozmerB]          ; po‡et bajt– na linku
;         mul       dx                       ; po‡ te‡n¡ offset linky
;         shr       bx,1
;         shr       bx,1
;         shr       bx,1                     ; p©epo‡et pozice na bajty
;         add       bx,ax                    ; adresa ve videopamˆti
;         xchg      bx,di                    ; DI<-adresa videopamˆti, BX<-obraz
;         xchg      si,bx                    ; BX <- v˜¨ka, SI <- obraz
;         mov       ax,0a000h
;         mov       es,ax                    ; segment videopamˆti
;
;; ------ inicializace registru masky
;
;         mov       dx,3ceh
;         mov       al,8
;         out       dx,al
;         inc       dx
;         mov       al,0ffh
;         out       dx,al                    ; maska - v¨echny bity
;
;; ------ korekce po‡tu bajt– na linku
;
;         add       cx,7                     ; zaokrouhlen¡ na bajty
;         shr       cx,1
;         shr       cx,1
;         shr       cx,1
;
;; ------ zobrazen¡ jedn‚ linky obr zku
;
;         cld
;Pict1:   push      di                       ; £schova ukl dac¡ adresy
;         push      cx                       ; £schova ¨¡©ky linky obr zku
;Pict2:   lodsb                              ; bajt k zobrazen¡
;         xchg      al,es:[di]
;         inc       di
;         loop      Pict2
;         pop       cx
;         pop       di
;         add       di,ds:[RozmerB]
;         dec       bx                       ; ‡¡ta‡ linek
;         jnz       Pict1                    ; dal¨¡ linka
;
;; ------ n vrat registr–
;
;         call      DeIniReg                 ; n vrat registr– videokarty
;         pop       es
;         pop       bp
;         pop       di
;         pop       si
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;
;Pict     ENDP
;
;; -----------------------------------------------------------------------------
;;                  Zobrazen¡ obd‚ln¡ku zadan‚ho sou©adnicemi
;; -----------------------------------------------------------------------------
;; VSTUP: AL=barva
;;        BX=po‡ te‡n¡ pozice
;;        CX=koncov  pozice
;;        DX=po‡ te‡n¡ linka
;;        SI=koncov  linka
;;        DS=datov˜ segment
;; -----------------------------------------------------------------------------
;
;Box0     PROC      NEAR
;
;; ------ £schova registr–
;
;         push      bx
;         push      cx
;         push      dx
;         push      si
;
;; ------ oprava po‡ te‡n¡ pozice
;
;         cmp       bx,cx
;         jle       Box01
;         xchg      bx,cx
;
;; ------ oprava po‡ te‡n¡ho © dku
;
;Box01:   cmp       dx,si
;         jle       Box02
;         xchg      dx,si
;
;; ------ v˜po‡et ¨¡©ky a v˜¨ky obd‚ln¡ku
;
;Box02:   sub       cx,bx
;         sub       si,dx
;         inc       cx
;         inc       si
;
;; ------ zobrazen¡ obd‚ln¡ku
;
;         call      Box
;
;; ------ n vrat registr–
;
;         pop       si
;         pop       dx
;         pop       cx
;         pop       bx
;         ret
;
;Box0     ENDP

;; -----------------------------------------------------------------------------
;;                       Zobrazen¡ obd‚ln¡ku
;; -----------------------------------------------------------------------------
;; VSTUP: AL=barva
;;        BX=pozice
;;        CX=¨¡©ka
;;        DX=linka
;;        SI=v˜¨ka
;;        DS=datov˜ segment
;; -----------------------------------------------------------------------------
;; lok ln¡ promˆnn‚: SS:[BP-1]=po‡ te‡n¡ maska
;;                   SS:[BP-2]=koncov  maska
;;                   SS:[BP-4]=po‡et vnit©n¡ch bajt–
;; -----------------------------------------------------------------------------
;
;Box      PROC      NEAR
;
;; ------ £schova registr–
;
;         push      ax
;         push      bx
;         push      cx
;         push      dx
;         push      si
;         push      di
;         push      bp
;         push      es
;         mov       bp,sp
;
;; ------ vytvo©en¡ bufferu pro lok ln¡ promˆnn‚
;
;         sub       sp,4
;
;; ------ inicializace registr– videokarty
;
;         call      InitReg                  ; inicializace registr– videokarty
;
;; ------ v˜po‡et adresy ve videopamˆti
;
;         mov       ax,dx                    ; hodn¡ okraj po‡ tku k zobrazen¡
;         mul       word ptr ds:[RozmerB]    ; v˜po‡et po‡ te‡n¡ho offsetu linky
;         mov       di,ax                    ; po‡ te‡n¡ adresa linky
;         mov       ax,bx                    ; lev˜ okraj za‡ tku zobrazen¡
;         shr       ax,1
;         shr       ax,1
;         shr       ax,1                     ; p©epo‡et na offset v bajtech
;         add       di,ax                    ; po‡ te‡n¡ adresa k zobrazen¡
;         mov       ax,0a000h                ; segment videopamˆti
;         mov       es,ax                    ; segment videopamˆti
;
;; ------ v˜po‡et prvn¡ masky objektu (lev˜ okraj)
;
;         xchg      cx,bx                    ; CL<-lev˜ okraj za‡ tku zobrazen¡
;         and       cl,7                     ; po‡ te‡n¡ bitov  pozice (0 a‘ 7)
;         mov       al,0ffh                  ; inicializa‡n¡ maska
;         shr       al,cl                    ; rotace masky vpravo (FF a‘ 01)
;         mov       ss:[bp-1],al             ; maska prvn¡ho bajtu
;
;; ------ v˜po‡et po‡tu zbyl˜ch bod–
;
;         mov       al,8                     ; po‡et bod– na bajt
;         sub       al,cl                    ; po‡et necel˜ch bod– vlevo (1 a‘ 8)
;         mov       ah,0                     ; BX=po‡et bod– zobrazen˜ch vlevo
;         sub       bx,ax                    ; po‡et zbyl˜ch bod–
;         js        Box1                     ; je mal˜ po‡et bod–
;
;; ------ v˜po‡et po‡tu cel˜ch bajt–
;
;         mov       dx,bx                    ; £schova po‡tu zbyl˜ch bod–
;         shr       bx,1
;         shr       bx,1
;         shr       bx,1                     ; po‡et cel˜ch vnit©n¡ch bajt–
;         mov       ss:[bp-4],bx             ; po‡et vnit©n¡ch bajt–
;
;; ------ v˜po‡et masky prav‚ho okraje
;
;         and       dl,7                     ; po‡et zbyl˜ch bod– vpravo (0 a‘ 7)
;         mov       cl,8                     ; po‡et bod– na bajt
;         sub       cl,dl                    ; po‡et nezobraz. bod– vpravo (1-8)
;         mov       al,0ffh                  ; maska prav‚ho okraje
;         shl       al,cl                    ; v˜po‡et masky prav‚ho okr. (00-FE)
;         mov       ss:[bp-2],al             ; maska prav‚ho okraje (00 - FE)
;         jmp       short Box2
;
;; ------ oprava prvn¡ masky pro mal˜ po‡et bod–
;
;Box1:    add       bx,ax
;         add       cl,bl                    ; koncov  bitov  pozice+1 (1 a‘ 6)
;         mov       al,8                     ; po‡et bod– na bajt
;         sub       al,cl                    ; po‡et nezobrazen˜ch bod– vpravo
;         mov       cl,al                    ; po‡et nezobrazen˜ch bod– vpravo
;         mov       al,0ffh                  ; maska
;         shl       al,cl                    ; rotace korek‡n¡ masky
;         and       ss:[bp-1],al             ; oprava prvn¡ masky
;         mov       byte ptr ss:[bp-2],0     ; nen¡ prav  maska
;         mov       word ptr ss:[bp-4],0     ; nen¡ ‘ dn˜ vnit©n¡ bajt
;
;; ------ nastaven¡ registry masky
;
;Box2:    mov       dx,3ceh                  ; ©¡dic¡ registr
;         mov       al,8
;         out       dx,al                    ; volba registru 8 - reg. masky
;         inc       dx                       ; 3cfh - adresa registru masky
;
;; ------ z pis obd‚ln¡ku
;
;         mov       bx,ss:[bp-2]             ; po‡ te‡n¡ a koncov  maska
;         mov       cx,ss:[bp-4]             ; po‡et vnit©n¡ch bajt–
;Box4:    call      FilLine                  ; z pis jedn‚ linky
;         add       di,ds:[RozmerB]          ; zv˜¨en¡ adresy ve videopamˆti
;         dec       si                       ; ‡¡ta‡ linek
;         jnz       Box4                     ; zobrazen¡ dal¨¡ linky
;
;; ------ n vrat registr–
;
;         mov       sp,bp
;         pop       es
;         pop       bp
;         pop       di
;         pop       si
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;
;Box      ENDP

;; -----------------------------------------------------------------------------
;;                         z pis linky
;; -----------------------------------------------------------------------------
;; VSTUP: BH=po‡ te‡n¡ maska
;;        BL=koncov  maska
;;        CX=po‡et vnit©n¡ch bajt–
;;        ES:DI=ukl dac¡ adresa
;;        DX=adresa registru 3cfh (nastaven registr 8)
; -----------------------------------------------------------------------------
;
;FilLine  PROC      NEAR
;
;; ------ £schova registr–
;
;         push      ax
;         push      cx
;         push      di
;         mov       ah,0ffh
;
;; ------ zobrazen¡ prvn¡ho bajtu linky
;
;         mov       al,bh                    ; maska prvn¡ho bajtu
;         and       al,es:[di+Maska]         ; maskov n¡
;         out       dx,al                    ; nastaven¡ masky pro z pis
;         mov       al,ah                    ; vzorek
;         xchg      al,es:[di]               ; z pis prvn¡ho bajtu linky
;         inc       di                       ; zv˜¨en¡ ukl dac¡ adresy
;
;; ------ zobrazen¡ vnit©n¡ch bajt– linky
;
;         cld                                ; smˆr nahoru
;         jcxz      FilLine2
;FilLine1:mov       al,0ffh                  ; maska - v¨echny bity
;         and       al,es:[di+Maska]         ; maskov n¡
;         out       dx,al                    ; povolen¡ z pisu pro v¨echny bity
;         mov       al,ah                    ; v˜pl¤
;         xchg      al,es:[di]
;         inc       di
;         loop      FilLine1                 ; z pis vnit©n¡ch bajt– linky
;
;; ------ zobrazen¡ posledn¡ho bajtu linky
;
;FilLine2:mov       al,bl                    ; maska posledn¡ho bajtu
;         and       al,es:[di+Maska]         ; maskov n¡
;         out       dx,al                    ; nastaven¡ masky pro z pis
;         mov       al,ah                    ; v˜pl¤
;         xchg      al,es:[di]               ; z pis posledn¡ho bajtu linky
;
;; ------ n vrat registr–
;
;         pop       di
;         pop       cx
;         pop       ax
;         ret
;
;FilLine  ENDP
;
; -----------------------------------------------------------------------------
;              Inicializace registr– videokarty pro z pis
; -----------------------------------------------------------------------------
; VSTUP: AL=barva k z pisu
;        DS=datov˜ segment
; -----------------------------------------------------------------------------

InitReg  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      dx
         mov       ah,al                    ; £schova po‘adovan‚ barvy

; ------ volba z pisov˜ch rovin

         mov       dx,3c4h
         mov       al,2
         out       dx,al
         mov       al,0fh
         inc       dx
         out       dx,al                    ; z pis do v¨ech rovin

; ------ nastaven¡ registru m¢du pro z pis

         mov       dx,3ceh
         mov       al,5
         out       dx,al
         inc       dx
         mov       al,0
         out       dx,al                    ; z pisov˜ m¢d 0
         dec       dx

; ------ ‡tec¡ registr

         mov       al,2
         out       dx,al
         inc       dx
         mov       al,0fh
         out       dx,al
         dec       dx

         mov       al,4
         out       dx,al
         inc       dx
         mov       al,0
         out       dx,al
         dec       dx

         mov       al,7
         out       dx,al
         inc       dx
         mov       al,0
         out       dx,al
         dec       dx

; ------ nastaven¡ registru barvy

         mov       al,0
         out       dx,al
         inc       dx
;         mov       al,ah                    ; po‘adovan  barva
         mov       al,0
;         mov       al,0fh
         out       dx,al                    ; barva
         dec       dx

; ------ nastaven¡ registru rovin

         mov       al,1
         out       dx,al
         inc       dx
;         mov       al,0ffh
         mov       al,ah
         not       al
;         mov       al,0
         out       dx,al                    ; v¨echny roviny po‘adovanou barvou
         dec       dx

; ------ nastaven¡ z pisov‚ho m¢du

         mov       al,3
         out       dx,al
         inc       dx
         mov       al,0                     ; re‘im "beze zmˆny"
         out       dx,al                    ; funkce z pisu beze zmˆny dat

; ------ n vrat registr–

         pop       dx
         pop       ax
         ret

InitReg  ENDP

; -----------------------------------------------------------------------------
;              n vrat nastaven¡ registr– videokarty
; -----------------------------------------------------------------------------

DeIniReg PROC      NEAR

; ------ £schova registr–

         push      ax
         push      dx

; ------ nastaven¡ z pisov˜ch rovin

         mov       dx,3c4h
         mov       al,2
         out       dx,al
         mov       al,0fh
         inc       dx
         out       dx,al                    ; z pis do v¨ech rovin

; ------ nastaven¡ registru m¢du pro z pis

         mov       dx,3ceh
         mov       al,5
         out       dx,al
         inc       dx
         mov       al,0
         out       dx,al                    ; z pisov˜ m¢d 0
         dec       dx

; ------ nastaven¡ z pisov‚ho m¢du

         mov       al,3
         out       dx,al
         inc       dx
         mov       al,0
         out       dx,al                    ; funkce z pisu beze zmˆny dat
         dec       dx

; ------ nastaven¡ registru masky

         mov       al,8
         out       dx,al
         inc       dx
         mov       al,0ffh                  ; maska - v¨echny bity
         out       dx,al                    ; povolen¡ masky pro v¨echny bity
         dec       dx

; ------ ‡tec¡ m¢d

         mov       al,2
         out       dx,al
         inc       dx
         mov       al,0fh
         out       dx,al
         dec       dx

; ------ registr p©ep¡na‡e rovin

         mov       al,1
         out       dx,al
         inc       dx
         xor       al,al
         out       dx,al                    ; v¨echny roviny podle dat
         dec       dx

; ------ ‡tec¡ rovina

         mov       al,4
         out       dx,al
         inc       dx
         mov       al,0
         out       dx,al
         dec       dx

; ------ maskov n¡ rovin

         mov       al,7
         out       dx,al
         inc       dx
         mov       al,0
         out       dx,al
;         dec       dx

; ------ n vrat registr–

         pop       dx
         pop       ax
         ret

DeIniReg ENDP

;; -----------------------------------------------------------------------------
;;        zobrazen¡ zes¡len‚ ‡ ry
;; -----------------------------------------------------------------------------
;; VSTUP: AL=barva
;;        BX=po‡ te‡n¡ pozice
;;        CX=koncov  pozice
;;        DX=po‡ te‡n¡ linka
;;        SI=koncov  linka
;; -----------------------------------------------------------------------------
;
;Line0    PROC      NEAR
;
;; ------ £schova registr–
;
;         push      ax
;         push      bx
;         push      cx
;         push      dx
;         push      si
;         push      di
;         push      bp
;
;; ------ oprava po©ad¡ sou©adnic (mus¡ platit Y2 >= Y1)
;
;         cmp       si,dx                    ; koncov  linka pod po‡ te‡n¡ ?
;         jge       Line01                   ; po©ad¡ sou©adnic je OK
;         xchg      si,dx                    ; z mˆna sou©adnic Y
;         xchg      bx,cx                    ; z mˆna sou©adnic X
;Line01:  mov       di,si
;         sub       di,dx                    ; rozd¡l sou©adnic Y
;
;; ------ zobrazen¡ zes¡len‚ho bodu po‡ tku a konce
;
;         call      Point0                   ; zes¡len˜ bod po‡ tku
;         push      bx
;         push      dx
;         mov       bx,cx
;         mov       dx,si
;         call      Point0                   ; zes¡len˜ bod konce
;         pop       dx
;         pop       bx
;
;; ------ absolutn¡ hodnota rozd¡lu sou©adnic X
;
;         mov       bp,bx                    ; po‡ te‡n¡ pozice
;         sub       bp,cx                    ; rozd¡l sou©adnic X2-X1
;         jns       Line02                   ; jde smˆrem vpravo
;         neg       bp                       ; absolutn¡ hodnota p©¡rustku
;
;; ------ stanoven¡ p©¡rustku sou©adnic
;
;Line02:  cmp       bp,di                    ; je vˆt¨¡ p©¡rustek ve smˆru X ?
;         mov       di,1                     ; p©¡rustek pro Y
;         mov       bp,0                     ; p©¡rustek pro X
;         jae       Line03                   ; jde m¡rnˆ dol–
;         xchg      bp,di                    ; bude p©¡rustek ve smˆru X
;
;; ------ nastaven¡ na v˜choz¡ pozici
;
;Line03:  mov       ah,ds:[Pero]             ; po‡et ‡ar pera
;         shr       ah,1
;         or        ah,ah
;         jz        Line05
;Line04:  sub       dx,di
;         sub       si,di
;         sub       bx,bp
;         sub       cx,bp
;         dec       ah
;         jnz       Line04
;
;; ------ zobrazen¡ ‡ar
;
;Line05:  mov       ah,ds:[Pero]
;Line06:  call      LineC                    ; zobrazen¡ ‡ ry
;         add       dx,di
;         add       si,di
;         add       bx,bp
;         add       cx,bp
;         dec       ah
;         jnz       Line06
;
;; ------ n vrat registr–
;
;         pop       bp
;         pop       di
;         pop       si
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;
;Line0    ENDP
;
;; -----------------------------------------------------------------------------
;;        zobrazen¡ ‡ ry s kontrolou
;; -----------------------------------------------------------------------------
;; -----------------------------------------------------------------------------
;
;LineC    PROC      NEAR
;
;         cmp       bx,ds:[MaxX]
;         ja        LineC9
;         cmp       cx,ds:[MaxX]
;         ja        LineC9
;         cmp       dx,ds:[IkonY]
;         jae       LineC9
;         cmp       si,ds:[IkonY]
;         jae       LineC9
;         call      Line
;LineC9:  ret
;
;LineC    ENDP
;
;; -----------------------------------------------------------------------------
;;        Zobrazen¡ ‡ ry
;; -----------------------------------------------------------------------------
;; VSTUP: AL=barva
;;        BX=po‡ te‡n¡ pozice
;;        CX=koncov  pozice
;;        DX=po‡ te‡n¡ linka
;;        SI=koncov  linka
;; -----------------------------------------------------------------------------
;
;Line     PROC      NEAR
;
;; ------ £schova registr–
;
;         push      ax
;         push      bx
;         push      cx
;         push      dx
;         push      si
;         push      di
;         push      bp
;         push      es
;         mov       ah,al
;
;; ------ oprava po©ad¡ sou©adnic (mus¡ platit Y2 >= Y1)
;
;         cmp       si,dx                    ; koncov  linka pod po‡ te‡n¡ ?
;         jge       Line1                    ; po©ad¡ sou©adnic je OK
;         xchg      si,dx                    ; z mˆna sou©adnic Y
;         xchg      bx,cx                    ; z mˆna sou©adnic X
;Line1:   sub       si,dx                    ; rozd¡l sou©adnic Y2-Y1
;
;; ------ inicializace registr– videokarty
;
;         call      InitReg                  ; inicializace registr– videokarty
;
;; ------ nastaven¡ registru barvy
;
;         push      dx
;         mov       dx,3ceh
;         mov       al,0
;         out       dx,al
;         inc       dx
;         mov       al,ah
;         out       dx,al
;         dec       dx
;
;         mov       al,1
;         out       dx,al
;         inc       dx
;         mov       al,0ffh
;         out       dx,al
;         pop       dx
;
;; ------ v˜po‡et po‡ te‡n¡ adresy ve videopamˆti
;
;         push      bx
;         push      cx
;         mov       ax,0a000h
;         mov       es,ax                    ; segment videopamˆti
;         mov       ax,ds:[RozmerB]          ; ¨¡©ka linky v bajtech
;         mul       dx                       ; v˜po‡et po‡ te‡n¡ho offsetu linky
;         mov       di,ax                    ; po‡ te‡n¡ adresa linky
;         mov       cl,bl                    ; pozice bodu - ni‘¨¡ slovo
;         shr       bx,1
;         shr       bx,1
;         shr       bx,1                     ; p©epo‡et na offset v bajtech
;         add       di,bx                    ; po‡ te‡n¡ adresa k zobrazen¡
;
;; ------ maskovac¡ bit za‡ tku
;
;         mov       dx,03ceh
;         and       cl,7                     ; po‡ te‡n¡ bitov  pozice v bajtu
;         mov       al,8
;         out       dx,al
;         inc       dx
;         mov       al,80h
;         shr       al,cl
;         pop       bx
;         pop       cx
;
;; ------ rozd¡l sou©adnic X a rozli¨en¡, zda jde shora vlevo nebo vpravo
;
;         sub       bx,cx                    ; rozd¡l sou©adnic X2-X1
;         jns       lin1ega0
;         jmp       Lin3EGA                  ; jde smˆrem vlevo
;
;; ------ ‡ ra jde shora vpravo
;
;
;; ------ rozli¨en¡, zda jde strmˆ vpravo
;
;lin1ega0:cmp       bx,si                    ; je vˆt¨¡ p©¡rustek ve smˆru X ?
;         jb        Lin2EGA                  ; jde strmˆ vpravo dol–
;
;; ------ ‡ ra jde m¡rnˆ vpravo dol–
;
;         mov       cx,bx                    ; ur‡uj¡c¡ je p©¡rustek X
;         inc       cx                       ; po‡et krok– ‡ ry
;         shl       si,1                     ; rozd¡l sou©adnic dY*2
;         mov       bp,si                    ; £schova dY*2
;         sub       bp,bx                    ; dY*2 - dX
;         shl       bx,1                     ; dX*2
;         sub       si,bx                    ; dY*2 - dX*2
;         add       bx,si                    ; dX*2 + dY*2 - dX*2 = dY*2
;         mov       ah,al                    ; maska po‡ te‡n¡ho bitu
;Lin1EGA1:or        al,ah
;         or        bp,bp
;         jns       Lin1EGA2
;         add       bp,bx
;         jmp       short Lin1EGA3
;Lin1EGA2:and       al,es:[di+Maska]         ; maskov n¡
;         out       dx,al
;         xchg      al,es:[di]
;         xor       al,al
;         add       di,ds:[RozmerB]
;         add       bp,si
;         ror       ah,1
;         adc       di,0
;         jmp       short Lin1EGA4
;Lin1EGA3:ror       ah,1
;         jnc       Lin1EGA4
;         and       al,es:[di+Maska]         ; maskov n¡
;         out       dx,al
;         xchg      al,es:[di]
;         inc       di
;         xor       al,al
;Lin1EGA4:loop      Lin1EGA1
;         and       al,es:[di+Maska]         ; maskov n¡
;         out       dx,al
;         xchg      al,es:[di]
;         jmp       LinEGA9
;
;; ------ ‡ ra jde strmˆ vpravo dol–
;
;Lin2EGA: mov       cx,si
;         inc       cx
;         shl       bx,1
;         mov       bp,bx
;         sub       bp,si
;         shl       si,1
;         sub       bx,si
;         add       si,bx
;Lin2EGA1:push      ax
;         and       al,es:[di+Maska]         ; maskov n¡
;         out       dx,al
;         pop       ax
;         xchg      ah,es:[di]
;         or        bp,bp
;         jns       Lin2EGA3
;         add       bp,si
;         jmp       short Lin2EGA4
;Lin2EGA3:ror       al,1
;         adc       di,0
;;         out       dx,al
;         add       bp,bx
;Lin2EGA4:add       di,ds:[RozmerB]
;         loop      Lin2EGA1
;         jmp       LinEGA9
;
;; ------ ‡ ra jde shora vlevo
;
;Lin3EGA: neg       bx
;         cmp       bx,si
;         jb        Lin4EGA
;
;; ------ ‡ ra jde m¡rnˆ vlevo
;
;         mov       cx,bx
;         inc       cx
;         shl       si,1
;         mov       bp,si
;         sub       bp,bx
;         shl       bx,1
;         sub       si,bx
;         add       bx,si
;         mov       ah,al
;Lin3EGA1:or        al,ah
;         or        bp,bp
;         jns       Lin3EGA3
;         add       bp,bx
;         jmp       short Lin3EGA4
;Lin3EGA3:and       al,es:[di+Maska]         ; maskov n¡
;         out       dx,al
;         xchg      al,es:[di]
;         xor       al,al
;         add       di,ds:[RozmerB]
;         add       bp,si
;         rol       ah,1
;         sbb       di,0
;         jmp       short Lin3EGA5
;Lin3EGA4:rol       ah,1
;         jnb       Lin3EGA5
;         and       al,es:[di+Maska]         ; maskov n¡
;         out       dx,al
;         xchg      al,es:[di]
;         dec       di
;         xor       al,al
;Lin3EGA5:loop      Lin3EGA1
;         and       al,es:[di+Maska]         ; maskov n¡
;         out       dx,al
;         xchg      al,es:[di]
;         jmp       LinEGA9
;
;; ------ ‡ ra jde strmˆ vlevo
;
;Lin4EGA: mov       cx,si
;         inc       cx
;         shl       bx,1
;         mov       bp,bx
;         sub       bp,si
;         shl       si,1
;         sub       bx,si
;         add       si,bx
;Lin4EGA1:push      ax
;         and       al,es:[di+Maska]         ; maskov n¡
;         out       dx,al
;         pop       ax
;         xchg      ah,es:[di]
;         or        bp,bp
;         jns       Lin4EGA2
;         add       bp,si
;         jmp       short Lin4EGA3
;Lin4EGA2:rol       al,1
;         sbb       di,0
;         and       al,es:[di+Maska]         ; maskov n¡
;;         out       dx,al
;         add       bp,bx
;Lin4EGA3:add       di,ds:[RozmerB]
;         loop      Lin4EGA1
;
;; ------ konec - n vrat registr–
;
;LinEGA9: call      DeIniReg                 ; n vrat registr– videokarty
;         pop       es
;         pop       bp
;         pop       di
;         pop       si
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;
;Line     ENDP
;
;; -----------------------------------------------------------------------------
;;        zobrazen¡ zes¡len‚ho bodu
;; -----------------------------------------------------------------------------
;; VSTUP: AL=barva
;;        BX=pozice
;;        DX=linka
;; -----------------------------------------------------------------------------
;
;Point0   PROC      NEAR
;
;; ------ £schova registr–
;
;         push      ax
;         push      bx
;         push      cx
;         push      dx
;         push      si
;         push      di
;
;; ------ kontrola sou©adnic
;
;         cmp       bx,ds:[MaxX]
;         ja        Point09
;         cmp       dx,ds:[IkonY]
;         jae       Point09
;
;; ------ rozmˆry n hradn¡ho ‡tverce
;
;         mov       di,word ptr ds:[Pero]
;         and       di,0ffh
;         shr       di,1
;         adc       di,0
;         jz        Point08
;         mov       cx,di
;         mov       si,di
;         shr       di,1
;         sub       bx,di
;         sub       dx,di
;
;; ------ kontrola sou©adnic
;
;         cmp       bx,ds:[MaxX]
;         ja        Point09
;         mov       di,cx
;         add       di,bx
;         cmp       di,ds:[MaxX]
;         ja        Point09
;         cmp       dx,ds:[IkonY]
;         jae       Point09
;         mov       di,si
;         add       di,dx
;         cmp       di,ds:[IkonY]
;         jae       Point09
;
;         call      Box
;         jmp       short Point09
;
;; ------ je m lo bod–
;
;Point08: call      Point
;
;; ------ n vrat registr–
;
;Point09: pop       di
;         pop       si
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;
;Point0   ENDP
;
;; -----------------------------------------------------------------------------
;;                       Zobrazen¡ bodu
;; -----------------------------------------------------------------------------
;; VSTUP: AL=barva
;;        BX=pozice
;;        DX=linka
;; -----------------------------------------------------------------------------
;
;Point    PROC      NEAR
;
;; ------ £schova registr–
;
;         push      ax
;         push      bx
;         push      cx
;         push      dx
;         push      di
;         push      es
;
;; ------ inicializace registr– videokarty
;
;;         mov       ch,al
;         call      InitReg                  ; inicializace registr– videokarty
;
;; ------ v˜po‡et adresy ve videopamˆti
;
;         mov       ax,0a000h
;         mov       es,ax                    ; segment videopamˆti
;         mov       ax,dx                    ; linka bodu
;         mul       word ptr ds:[RozmerB]    ; v˜po‡et po‡ te‡n¡ho offsetu linky
;         mov       di,ax                    ; po‡ te‡n¡ adresa linky
;         mov       cl,bl                    ; pozice bodu - ni‘¨¡ slovo
;         shr       bx,1
;         shr       bx,1
;         shr       bx,1                     ; p©epo‡et na offset v bajtech
;         add       di,bx                    ; po‡ te‡n¡ adresa k zobrazen¡
;
;; ------ nastaven¡ registru barvy
;
;;         mov       dx,3ceh
;;         mov       al,0
;;         out       dx,al
;;         inc       dx
;;         mov       al,ch
;;         out       dx,al
;;         dec       dx
;;
;;         mov       al,1
;;         out       dx,al
;;         inc       dx
;;         mov       al,0ffh
;;         out       dx,al
;
;; ------ nastaven¡ registru masky
;
;         mov       dx,3ceh
;         mov       al,8
;         out       dx,al                    ; volba registru 8 - reg. masky
;         inc       dx                       ; 3cfh - adresa registru masky
;         and       cl,7                     ; bitov  pozice (0 a‘ 7)
;         mov       al,80h                   ; inicializa‡n¡ maska
;         shr       al,cl                    ; rotace masky vpravo (80h a‘ 01h)
;
;; ------ z pis bodu
;
;         and       al,es:[di+Maska]         ; maskov n¡
;         out       dx,al                    ; nastaven¡ masky bodu
;         xchg      al,es:[di]               ; z pis bodu do roviny
;
;; ------ n vrat registr–
;
;         call      DeIniReg                 ; n vrat registr– videokarty
;         pop       es
;         pop       di
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;
;Point    ENDP
;
;; -----------------------------------------------------------------------------
;;        poskytnut¡ barvy bodu BX/DX -> AL
;; -----------------------------------------------------------------------------
;
;GetPoint PROC      NEAR
;
;; ------ £schova registr–
;
;         push      bx
;         push      ax
;         push      cx
;         push      dx
;         push      si
;         push      di
;         push      bp
;         push      ds
;         push      es
;
;;; ------ ‡ten¡ bodu
;;
;;         mov       ah,0dh
;;         mov       cx,bx                    ; pozice bodu
;;         xor       bh,bh                    ; videostr nka
;;         int       10h                      ; ‡ten¡ barvy bodu
;
;; ------ inicializace registr– videokarty
;
;;         xor       al,al
;;         call      InitReg                  ; inicializace registr– videokarty
;
;; ------ v˜po‡et adresy ve videopamˆti
;
;         mov       ax,0a000h
;         mov       es,ax                    ; segment videopamˆti
;         mov       ax,dx                    ; linka bodu
;         mul       word ptr ds:[RozmerB]    ; v˜po‡et po‡ te‡n¡ho offsetu linky
;         mov       di,ax                    ; po‡ te‡n¡ adresa linky
;         mov       cl,bl                    ; pozice bodu - ni‘¨¡ slovo
;         shr       bx,1
;         shr       bx,1
;         shr       bx,1                     ; p©epo‡et na offset v bajtech
;         add       di,bx                    ; po‡ te‡n¡ adresa k zobrazen¡
;
;; ------ nastaven¡ ‡tec¡ho m¢du
;
;         mov       dx,03ceh
;         mov       al,5
;         out       dx,al                    ; registr m¢du
;         inc       dx
;         mov       al,0
;         out       dx,al                    ; m¢d ‡ten¡ 0
;         dec       dx
;                                           ;* nastaven¡ ‡tec¡ roviny
;
;         mov       al,4
;         out       dx,al                    ; registr ‡tec¡ mapy
;         inc       dx
;
;; ------ nastaven¡ registru masky
;
;         and       cl,7                     ; bitov  pozice (0 a‘ 7)
;         mov       bh,80h                   ; inicializa‡n¡ maska
;         shr       bh,cl                    ; rotace masky vpravo (80h a‘ 01h)
;
;; ------ ‡ten¡ bodu
;
;         xor       ah,ah                    ; st©ada‡ bajtu
;         mov       cl,1
;         xor       bl,bl                    ; ukazatel roviny
;
;GetPo1:
;         mov       al,bl
;         out       dx,al
;         mov       al,es:[di]
;         and       al,bh
;         jz        GetPo2
;         or        ah,cl
;GetPo2:  shl       cl,1
;         inc       bl
;         cmp       bl,4
;         jb        GetPo1
;         mov       al,ah
;
;; ------ n vrat registr–
;
;         call      DeIniReg                 ; n vrat registr– videokarty
;
;; ------ n vrat registr–
;
;         pop       es
;         pop       ds
;         pop       bp
;         pop       di
;         pop       si
;         pop       dx
;         pop       cx
;         mov       bl,al
;         pop       ax
;         mov       al,bl
;         pop       bx
;         ret
;
;GetPoint ENDP
;

; -----------------------------------------------------------------------------
;        Obsluha INT 10h s £schovou registr–
; -----------------------------------------------------------------------------

INT10    PROC      NEAR

         push      bp
         push      si
         push      di
         push      ds
         push      es

         int       10h

         pop       es
         pop       ds
         pop       di
         pop       si
         pop       bp
         ret

INT10    ENDP


Code     ENDS

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                             Datov˜ segment
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

Data     SEGMENT

TabIkon  label     word                     ; defini‡n¡ tabulka ikon
         dw        ObrPero1                 ; pero
         dw        72                       ; pero

         dw        ObrBod1                  ; typ bodu
         dw        76                       ; typ bodu

         dw        ObrCar1                  ; typ ‡ ry 1
         dw        72+1*32*80               ; typ ‡ ry 1

         dw        ObrObl                   ; typ oblou‡ku 1
         dw        76+1*32*80               ; typ oblou‡ku 1

         dw        ObrPain                  ; vybarven¡
         dw        72+2*32*80               ; vybarven¡

         dw        ObrSprej                 ; sprej
         dw        76+2*32*80               ; sprej

         dw        ObrText                  ; text
         dw        72+3*32*80               ; text

         dw        ObrBlok                  ; blok
         dw        76+3*32*80               ; blok

         dw        ObrGum                   ; guma
         dw        72+4*32*80               ; guma

         dw        ObrUndo                  ; obnoven¡
         dw        76+4*32*80               ; obnoven¡

         dw        ObrDisk                  ; disketa
         dw        72+5*32*80               ; disketa

         dw        ObrTisk                  ; tisk rna
         dw        76+5*32*80               ; tisk rna

         dw        ObrOpt                   ; volby
         dw        72+6*32*80               ; volby

         dw        ObrLup                   ; lupa
         dw        76+6*32*80               ; lupa

AdrColor dw        72+7*32*80               ; adresa obd‚ln¡ku barev
BarvaF   db        0                        ; barva pop©ed¡ (hlavn¡ barva)
BarvaB   db        15                       ; barva pozad¡

AdrBarv  dw        72+8*32*80               ; adresa k zobrazen¡ barev

KurzMous dw        0                        ; adresa definice kurzoru my¨i

SegPSP   dw        ?                        ; uschovan˜ segment PSP
OldVMod  db        ?                        ; p–vodn¡ videom¢d

Rovin    db        4                        ; po‡et rovin videopamˆti

Param    db        1                        ; parametry
                                            ;   bit 0: 1=je nainstalovan  my¨

OldX     dw        0                        ; p–vodn¡ pozice my¨i X
OldY     dw        0                        ; p–vodn¡ pozice my¨i Y
OldKey   db        0                        ; p–vodn¡ tla‡¡tka my¨i

RozmerX  dw        640                      ; maxim ln¡ rozmˆr X
RozmerB  dw        80                       ; d‚lka linky v bajtech
RozmerY  dw        350                      ; maxim ln¡ rozmˆr Y
MaxX     dw        639
MaxY     dw        349

SegVRAM  dw        0a000h                   ; segment videopamˆti

INCLUDE  Obrazky.ASM                        ; obr zky ikon a pod.

Data     ENDS


; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                                Z sobn¡k
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

Zasob    SEGMENT   STACK

         dw        400h dup(?)

Zasob    ENDS

         END       Start

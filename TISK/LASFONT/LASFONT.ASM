
code     segment
         assume    cs:code,ds:code
         org       100h

start:

; ------ £schova videom¢du

         mov       ah,0fh
         int       10h
         mov       ds:[OldVMod],al

; ------ instalace my®i

         xor       ax,ax
         call      Mouse
         inc       ax
         jz        st1

; ------ chyba - nen° my®

         mov       dx,offset MouseErr
         mov       ah,9
         int       21h

; ------ nastaven° videom¢du

st1:     mov       ax,16
         int       10h

; ------ zobrazen° okna

         call      Podklad                  ; podklad kreslic° plochy
         call      DispMenu                 ; zobrazen° menu
         call      DispAkt                  ; zobrazen° aktivn°ch ikon

; ------ instalace obsluhy p©eru®en°

         mov       ax,2523h
         mov       dx,offset Konec
         int       21h

; ------ definice okna pro my®

         xor       cx,cx
         mov       dx,ds:[MaxX]
         mov       ax,7
         call      Mouse
         xor       cx,cx
         mov       dx,ds:[MaxY]
         mov       ax,8
         call      Mouse

; ------ definice kurzoru my®i

         mov       dx,offset KurzMap
         mov       ax,9
         xor       bx,bx
         xor       cx,cx
         call      Mouse

; ------ zapnut° kurzoru my®i

st55:    call      MouseOn

; ------ nastaven° kurzoru na novou pozici

st5:
         mov       ah,0bh
         int       21h

         call      MouseGet
         jc        st5

         test      bl,2
         jz        st53
         jmp       Konec

st53:
         call      MouseOld

         test      bl,1
         jz        st5
         cmp       cx,ds:[IkonX]
         jae       st5                      ; je v ikon†ch - neplat°

; ------ oznaáen° vòchoz° pozice á†ry

         mov       ds:[topx],cx
         mov       ds:[topy],dx

         call      MouseOff                 ; vypnut° my®i

; ------ zobrazen° doáasnÇ á†ry

         or        byte ptr ds:[rezim],1
         mov       bx,cx
         mov       si,dx
st7:     mov       al,0fh
         call      Line

         mov       di,offset Pattern0
;         call      Box0

         call      MouseOn

; ------ áek†n° na uvolnàn° tlaá°tka

st6:
         mov       ah,0bh
         int       21h

         call      MouseGet
         jc        st6

         test      bl,2
         jnz       Konec

; ------ vymaz†n° starÇ á†ry

         mov       ah,bl

         mov       si,dx
         mov       bx,ds:[topx]
         mov       dx,ds:[topy]

         call      MouseOff

         mov       al,0fh
         push      cx
         push      si
         mov       cx,ds:[OldX]
         mov       si,ds:[OldY]
         call      Line
;         call      Box0
         pop       si
         pop       cx

         mov       ds:[OldX],cx
         mov       ds:[OldY],si
         mov       ds:[OldKey],ah

         test      ah,1
         jnz       st7                      ; áek†n° na uvolnàn° tlaá°tka
         cmp       cx,ds:[IkonX]
         jb        st74
         jmp       st55                     ; je v ikon†ch - neplat°

; ------ p©i uvolnàn° tlaá°tka zobrazen° á†ry

st74:    and       byte ptr ds:[rezim],not 1
         mov       al,15
         call      Line
;         call      Box0
         call      MouseOn                  ; opàt zapnut° my®i
         jmp       st5                      ; áek†n° na dal®° á†ru



;         call      Point


Konec:
         push      cs
         pop       ds
;         call      MouseOff

         xor       ah,ah
         mov       al,ds:[OldVMod]
         int       10h                      ; pñvodn° videom¢d

         int       20h

; *****************************************************************************
;
;              Obsluha zobrazen° jednotlivòch á†st° displeje
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;                          zobrazen° podkladu
; -----------------------------------------------------------------------------

Podklad  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

; ------ podkladovò obdÇln°k

         xor       bx,bx
         xor       dx,dx
         mov       cx,ds:[IkonX]
         mov       si,ds:[RozmerY]
         mov       al,7
         mov       di,offset Pattern0
         call      Box

; ------ n†vrat registrñ

         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Podklad  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° menu
; -----------------------------------------------------------------------------

DispMenu PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp

; ------ menu

         mov       di,offset DefIkon        ; obr†zky ikon
         xor       bp,bp                    ; ukazatel á°sla ikony
         mov       bx,ds:[IkonX]
         mov       cx,24
         mov       dx,ds:[IkonY]
         mov       si,cx
         mov       al,15

DispMen1:cmp       bp,ds:[NumIkon]
         jae       DispMen9
         mov       ah,0
         cmp       bp,ds:[IkonAkt]
         jne       DispMen2
         not       ah
DispMen2:call      Pict
         inc       bp
         add       di,offset(DefIkon0-DefIkon)
         add       bx,cx
         test      bp,1
         jnz       DispMen3
         sub       bx,cx
         sub       bx,cx
         add       dx,si
DispMen3:jmp       short DispMen1

; ------ n†vrat registrñ

DispMen9:pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispMenu ENDP

; -----------------------------------------------------------------------------
;        zobrazen° aktivn°ch ikon
; -----------------------------------------------------------------------------

DispAkt  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

; ------ ikona - levÇ tlaá°tko

         mov       ax,offset(DefIkon0-DefIkon)
         mul       word ptr ds:[IkonL]
         add       ax,offset DefIkon        ; obr†zky ikon
         mov       di,ax

         mov       bx,ds:[IkonX]
         mov       cx,24
         mov       dx,ds:[IkonYM]
         mov       si,cx
         mov       ax,15
         call      Pict

; ------ ikona - pravÇ tlaá°tko

         mov       ax,offset(DefIkon0-DefIkon)
         mul       word ptr ds:[IkonR]
         add       ax,offset DefIkon        ; obr†zky ikon
         mov       di,ax

         add       bx,cx
         mov       dx,ds:[IkonYM]
         mov       ax,15
         call      Pict

; ------ á†ra - levÇ tlaá°tko

         mov       ax,offset(DefIkon0-DefIkon)
         mul       word ptr ds:[IkonLC]
         add       ax,offset DefIkon        ; obr†zky ikon
         mov       di,ax

         sub       bx,cx
         mov       dx,ds:[IkonYM]
         add       dx,si
         mov       ax,15
         call      Pict

; ------ á†ra - pravÇ tlaá°tko

         mov       ax,offset(DefIkon0-DefIkon)
         mul       word ptr ds:[IkonRC]
         add       ax,offset DefIkon        ; obr†zky ikon
         mov       di,ax

         add       bx,cx
         mov       dx,ds:[IkonYM]
         add       dx,si
         mov       ax,15
         call      Pict

; ------ n†vrat registrñ

         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispAkt  ENDP

; *****************************************************************************
;
;                             obsluha my®i
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;        vypnut° kurzoru my®i
; -----------------------------------------------------------------------------

MouseOff PROC      NEAR

         push      ax
         mov       ax,2
         jmp       short MouseOn1

MouseOff ENDP

; -----------------------------------------------------------------------------
;        zapnut° kurzoru my®i
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
;        nastaven° pozice my®i
; -----------------------------------------------------------------------------

MouseSet PROC      NEAR

         push      ax
         mov       ax,4
         call      Mouse
         pop       ax
         ret

MouseSet ENDP

; -----------------------------------------------------------------------------
;        navr†cen° pozice a stavu my®i
; -----------------------------------------------------------------------------
; VSTUP:  DS=datovò segment
; VùSTUP: BX=bit 0: levÇ tlaá°tko
;            bit 1: pravÇ tlaá°tko
;         CX=sloupec
;         DX=©†dek
;         CY=nebyla zmàna
; -----------------------------------------------------------------------------

MouseGet PROC      NEAR

         push      ax
         mov       ax,3
         call      Mouse
         and       bl,3
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
;        £schova stavu my®i (BX, CX a DX po n†vratu z MouseGet)
; -----------------------------------------------------------------------------

MouseOld PROC      NEAR

         mov       ds:[OldX],cx
         mov       ds:[OldY],dx
         mov       ds:[OldKey],bl
         ret

MouseOld ENDP

; -----------------------------------------------------------------------------
;        obsluha my®i
; -----------------------------------------------------------------------------

Mouse    PROC      NEAR

         push      si
         push      di
         push      bp
         push      ds
         push      es

         int       33h

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         ret

Mouse    ENDP


; *****************************************************************************
;
;                            obsluha displeje
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;                          zobrazen° obr†zku (2 barvy)
; -----------------------------------------------------------------------------
; VSTUP: AL=barva
;        AH=maska inverze
;        BX=poá†teán° pozice
;        CX=®°©ka obr†zku (bodñ)
;        DX=poá†teán° linka
;        SI=vò®ka obr†zku
;        DI=adresa obr†zku
;        DS=datovò segment
; -----------------------------------------------------------------------------

Pict     PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ inicializace registrñ videokarty

         call      InitReg                  ; inicializace registrñ videokarty

; ------ vòpoáet adresy ve videopamàti

         push      ax
         mov       ax,ds:[RozmerB]          ; poáet bajtñ na linku
         mul       dx                       ; poá†teán° offset linky
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; p©epoáet pozice na bajty
         add       bx,ax                    ; adresa ve videopamàti
         xchg      bx,di                    ; DI<-adresa videopamàti, BX<-obraz
         xchg      si,bx                    ; BX <- vò®ka, SI <- obraz
         mov       ax,0a000h
         mov       es,ax                    ; segment videopamàti
         pop       ax

; ------ inicializace registru masky

         mov       dx,3ceh
         mov       al,8
         out       dx,al
         inc       dx
         mov       al,0ffh
         out       dx,al                    ; maska - v®echny bity

; ------ korekce poátu bajtñ na linku

         add       cx,7                     ; zaokrouhlen° na bajty
         shr       cx,1
         shr       cx,1
         shr       cx,1

; ------ zobrazen° jednÇ linky obr†zku

         cld
Pict1:   push      di                       ; £schova ukl†dac° adresy
         push      cx                       ; £schova ®°©ky linky obr†zku
Pict2:   lodsb                              ; bajt k zobrazen°
         xor       al,ah                    ; inverze maskou
         xchg      al,es:[di]
         inc       di
         loop      Pict2
         pop       cx
         pop       di
         add       di,ds:[RozmerB]
         dec       bx                       ; á°taá linek
         jnz       Pict1                    ; dal®° linka

; ------ n†vrat registrñ

         call      DeIniReg                 ; n†vrat registrñ videokarty
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Pict     ENDP

; -----------------------------------------------------------------------------
;                  Zobrazen° obdÇln°ku zadanÇho sou©adnicemi
; -----------------------------------------------------------------------------
; VSTUP: AL=barva
;        BX=poá†teán° pozice
;        CX=koncov† pozice
;        DX=poá†teán° linka
;        SI=koncov† linka
;        DI=vòpl§
;        DS=datovò segment
; -----------------------------------------------------------------------------

Box0     PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      dx
         push      si

; ------ oprava poá†teán° pozice

         cmp       bx,cx
         jle       Box01
         xchg      bx,cx

; ------ oprava poá†teán°ho ©†dku

Box01:   cmp       dx,si
         jle       Box02
         xchg      dx,si

; ------ vòpoáet ®°©ky a vò®ky obdÇln°ku

Box02:   sub       cx,bx
         sub       si,dx
         inc       cx
         inc       si

; ------ zobrazen° obdÇln°ku

         call      Box

; ------ n†vrat registrñ

         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

Box0     ENDP

; -----------------------------------------------------------------------------
;                       Zobrazen° obdÇln°ku
; -----------------------------------------------------------------------------
; VSTUP: AL=barva
;        BX=pozice
;        CX=®°©ka
;        DX=linka
;        SI=vò®ka
;        DS:DI=vòpl§
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-1]=poá†teán° maska
;                   SS:[BP-2]=koncov† maska
;                   SS:[BP-4]=poáet vnit©n°ch bajtñ
;                   SS:[BP-6]=adresa vòplnà
;                   SS:[BP-8]=ukazatel linek vòplnà
; -----------------------------------------------------------------------------

Box      PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp

; ------ vytvo©en° bufferu pro lok†ln° promànnÇ

         sub       sp,8

; ------ £schova ukazatelñ vòplnà

         mov       ss:[bp-6],di             ; adresa vòplnà
         mov       ss:[bp-8],dx             ; linka

; ------ inicializace registrñ videokarty

         call      InitReg                  ; inicializace registrñ videokarty

; ------ vòpoáet adresy ve videopamàti

         mov       ax,dx                    ; hodn° okraj poá†tku k zobrazen°
         mul       word ptr ds:[RozmerB]    ; vòpoáet poá†teán°ho offsetu linky
         mov       di,ax                    ; poá†teán° adresa linky
         mov       ax,bx                    ; levò okraj zaá†tku zobrazen°
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©epoáet na offset v bajtech
         add       di,ax                    ; poá†teán° adresa k zobrazen°
         mov       ax,0a000h                ; segment videopamàti
         mov       es,ax                    ; segment videopamàti

; ------ vòpoáet prvn° masky objektu (levò okraj)

         xchg      cx,bx                    ; CL<-levò okraj zaá†tku zobrazen°
         and       cl,7                     ; poá†teán° bitov† pozice (0 aë 7)
         mov       al,0ffh                  ; inicializaán° maska
         shr       al,cl                    ; rotace masky vpravo (FF aë 01)
         mov       ss:[bp-1],al             ; maska prvn°ho bajtu

; ------ vòpoáet poátu zbylòch bodñ

         mov       al,8                     ; poáet bodñ na bajt
         sub       al,cl                    ; poáet necelòch bodñ vlevo (1 aë 8)
         mov       ah,0                     ; BX=poáet bodñ zobrazenòch vlevo
         sub       bx,ax                    ; poáet zbylòch bodñ
         js        Box1                     ; je malò poáet bodñ

; ------ vòpoáet poátu celòch bajtñ

         mov       dx,bx                    ; £schova poátu zbylòch bodñ
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; poáet celòch vnit©n°ch bajtñ
         mov       ss:[bp-4],bx             ; poáet vnit©n°ch bajtñ

; ------ vòpoáet masky pravÇho okraje

         and       dl,7                     ; poáet zbylòch bodñ vpravo (0 aë 7)
         mov       cl,8                     ; poáet bodñ na bajt
         sub       cl,dl                    ; poáet nezobraz. bodñ vpravo (1-8)
         mov       al,0ffh                  ; maska pravÇho okraje
         shl       al,cl                    ; vòpoáet masky pravÇho okr. (00-FE)
         mov       ss:[bp-2],al             ; maska pravÇho okraje (00 - FE)
         jmp       short Box2

; ------ oprava prvn° masky pro malò poáet bodñ

Box1:    add       bx,ax
         add       cl,bl                    ; koncov† bitov† pozice+1 (1 aë 6)
         mov       al,8                     ; poáet bodñ na bajt
         sub       al,cl                    ; poáet nezobrazenòch bodñ vpravo
         mov       cl,al                    ; poáet nezobrazenòch bodñ vpravo
         mov       al,0ffh                  ; maska
         shl       al,cl                    ; rotace korekán° masky
         and       ss:[bp-1],al             ; oprava prvn° masky
         mov       byte ptr ss:[bp-2],0     ; nen° prav† maska
         mov       word ptr ss:[bp-4],0     ; nen° ë†dnò vnit©n° bajt

; ------ nastaven° registry masky

Box2:    mov       dx,3ceh                  ; ©°dic° registr
         mov       al,8
         out       dx,al                    ; volba registru 8 - reg. masky
         inc       dx                       ; 3cfh - adresa registru masky

; ------ z†pis obdÇln°ku

         mov       bx,ss:[bp-2]             ; poá†teán° a koncov† maska
         mov       cx,ss:[bp-4]             ; poáet vnit©n°ch bajtñ
Box4:    push      si
         mov       si,ss:[bp-8]             ; ukazatel linky
         inc       word ptr ss:[bp-8]       ; zvò®en° ukazatele vòplnà
         and       si,7                     ; offset v tabulce vòplnà
         add       si,ss:[bp-6]             ; adresa vòplnà
         mov       ah,ds:[si]               ; vòpl§
         call      FilLine                  ; z†pis jednÇ linky
         pop       si
         add       di,ds:[RozmerB]          ; zvò®en° adresy ve videopamàti
         dec       si                       ; á°taá linek
         jnz       Box4                     ; zobrazen° dal®° linky

; ------ n†vrat registrñ

         mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Box      ENDP

; -----------------------------------------------------------------------------
;                         z†pis linky
; -----------------------------------------------------------------------------
; VSTUP: AH=vòpl§
;        BH=poá†teán° maska
;        BL=koncov† maska
;        CX=poáet vnit©n°ch bajtñ
;        ES:DI=ukl†dac° adresa
;        DX=adresa registru 3cfh (nastaven registr 8)
; -----------------------------------------------------------------------------

FilLine  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      di

; ------ zobrazen° prvn°ho bajtu linky

         mov       al,bh                    ; maska prvn°ho bajtu
         out       dx,al                    ; nastaven° masky pro z†pis
         mov       al,ah                    ; vzorek
         xchg      al,es:[di]               ; z†pis prvn°ho bajtu linky
         inc       di                       ; zvò®en° ukl†dac° adresy

; ------ zobrazen° vnit©n°ch bajtñ linky

         cld                                ; smàr nahoru
         jcxz      FilLine2
         mov       al,0ffh                  ; maska - v®echny bity
         out       dx,al                    ; povolen° z†pisu pro v®echny bity
FilLine1:mov       al,ah                    ; vòpl§
         xchg      al,es:[di]
         inc       di
         loop      FilLine1                 ; z†pis vnit©n°ch bajtñ linky

; ------ zobrazen° posledn°ho bajtu linky

FilLine2:mov       al,bl                    ; maska posledn°ho bajtu
         out       dx,al                    ; nastaven° masky pro z†pis
         mov       al,ah                    ; vòpl§
         xchg      al,es:[di]               ; z†pis posledn°ho bajtu linky

; ------ n†vrat registrñ

         pop       di
         pop       cx
         pop       ax
         ret

FilLine  ENDP

; -----------------------------------------------------------------------------
;              Inicializace registrñ videokarty pro z†pis
; -----------------------------------------------------------------------------
; VSTUP: AL=barva k z†pisu
;        DS=datovò segment
; -----------------------------------------------------------------------------

InitReg  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      dx
         mov       ah,al                    ; £schova poëadovanÇ barvy

; ------ volba z†pisovòch rovin

         mov       dx,3c4h
         mov       al,2
         out       dx,al
         mov       al,0fh
         inc       dx
         out       dx,al                    ; z†pis do v®ech rovin

; ------ nastaven° registru m¢du pro z†pis

         mov       dx,3ceh
         mov       al,5
         out       dx,al
         inc       dx
         mov       al,0
         out       dx,al                    ; z†pisovò m¢d 0
         dec       dx

; ------ átec° registr

;         mov       al,2
;         out       dx,al
;         inc       dx
;         mov       al,0fh
;         out       dx,al
;         dec       dx
;
;         mov       al,4
;         out       dx,al
;         inc       dx
;         mov       al,0
;         out       dx,al
;         dec       dx
;
;         mov       al,7
;         out       dx,al
;         inc       dx
;         mov       al,0
;         out       dx,al
;         dec       dx

; ------ nastaven° registru barvy

         mov       al,0
         out       dx,al
         inc       dx
;         mov       al,ah                    ; poëadovan† barva
         mov       al,0
;         mov       al,0fh
         out       dx,al                    ; barva
         dec       dx

; ------ nastaven° registru rovin

         mov       al,1
         out       dx,al
         inc       dx
;         mov       al,0ffh
         mov       al,ah
         not       al
;         mov       al,0
         out       dx,al                    ; v®echny roviny poëadovanou barvou
         dec       dx

; ------ nastaven° z†pisovÇho m¢du

         mov       al,3
         out       dx,al
         inc       dx
         mov       al,0                     ; reëim "beze zmàny"
         test      byte ptr ds:[Rezim],1    ; je reëim XOR ?
         jz        InitReg2                 ; nen° reëim XOR
         mov       al,18h                   ; reëim XOR
InitReg2:out       dx,al                    ; funkce z†pisu beze zmàny dat

; ------ n†vrat registrñ

         pop       dx
         pop       ax
         ret

InitReg  ENDP

; -----------------------------------------------------------------------------
;              n†vrat nastaven° registrñ videokarty
; -----------------------------------------------------------------------------

DeIniReg PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      dx

; ------ nastaven° z†pisovòch rovin

         mov       dx,3c4h
         mov       al,2
         out       dx,al
         mov       al,0fh
         inc       dx
         out       dx,al                    ; z†pis do v®ech rovin

; ------ nastaven° registru m¢du pro z†pis

         mov       dx,3ceh
         mov       al,5
         out       dx,al
         inc       dx
         mov       al,0

         mov       al,10h                   ; monochromn° videom¢d

         out       dx,al                    ; z†pisovò m¢d 0
         dec       dx

; ------ nastaven° z†pisovÇho m¢du

         mov       al,3
         out       dx,al
         inc       dx
         mov       al,0
         out       dx,al                    ; funkce z†pisu beze zmàny dat
         dec       dx

; ------ nastaven° registru masky

         mov       al,8
         out       dx,al
         inc       dx
         mov       al,0ffh                  ; maska - v®echny bity
         out       dx,al                    ; povolen° masky pro v®echny bity
         dec       dx

; ------ átec° m¢d

;         mov       al,2
;         out       dx,al
;         inc       dx
;         mov       al,0fh
;         out       dx,al
;         dec       dx

; ------ registr p©ep°naáe rovin

         mov       al,1
         out       dx,al
         inc       dx
         xor       al,al
         out       dx,al                    ; v®echny roviny podle dat

; ------ n†vrat registrñ

         pop       dx
         pop       ax
         ret

DeIniReg ENDP

;
;; -----------------------------------------------------------------------------
;;        P©°prava pro zobrazen° objektu v EGA
;; -----------------------------------------------------------------------------
;; VSTUP: DS=CS
;;        ES:DI=poá†teán° adresa videopamàti
;;        kromà SI a BP nemus° uchov†vat registry
;; -----------------------------------------------------------------------------
;; VùSTUP: ES:DI=poá†teán° adresa pro zobrazen° objektu
;; -----------------------------------------------------------------------------
;
;PUBLIC   PrepEGA
;PrepEGA:
;
;; ------ inicializace registrñ
;
;         call      InitREGA                 ; inicializace registrñ EGA
;
;; ------ vòpoáet poátu bajtñ na linku
;
;         mov       ax,ds:[Sirka]            ; ®°©ka vò©ezu (bodñ)
;         add       ax,7                     ; zaokrouhlen°
;         shr       ax,1
;         shr       ax,1
;         shr       ax,1                     ; p©epoáet na bajty
;         mov       ds:[SirkaB],ax           ; ®°©ka linky v batech
;
;; ------ vòpoáet poátu bajtñ na rovinu
;
;         mul       word ptr ds:[Vyska]      ; poáet bajtñ na rovinu
;         mov       ds:[RovinaB],ax          ; poáet bajtñ na rovinu
;
;; ------ vòpoáet prvn° masky objektu (levò okraj)
;
;         mov       cl,byte ptr ds:[ObjLD]   ; levò okraj zaá†tku zobrazen°
;         and       cl,7                     ; poá†teán° bitov† pozice (0 aë 7)
;         mov       al,0ffh                  ; inicializaán° maska
;         shr       al,cl                    ; rotace masky vpravo (FF aë 01)
;         mov       ds:[MaskFrst],al         ; maska prvn°ho bajtu
;
;; ------ vòpoáet rotace objektu
;
;         mov       ax,ds:[ObjLD]            ; levò okraj zaá†tku zobrazen°
;         sub       ax,ds:[ObjLO]            ; teoretickò levò okraj objektu
;         and       al,7                     ; rotace objektu vpravo (0 aë 7)
;         mov       ds:[MaskRot],al          ; rotace objektu vpravo
;
;; ------ vòpoáet poátu zbylòch bodñ
;
;         mov       bl,8                     ; poáet bodñ na bajt
;         sub       bl,cl                    ; poáet necelòch bodñ vlevo (1 aë 8)
;         mov       bh,0                     ; BX=poáet bodñ zobrazenòch vlevo
;         mov       ax,ds:[ObjS]             ; ®°©ka pro zobrazen° objektu
;         sub       ax,bx                    ; poáet zbylòch bodñ
;         js        PrepEGA3                 ; je malò poáet bodñ
;
;; ------ vòpoáet poátu celòch bajtñ
;
;         mov       bx,ax                    ; £schova poátu zbylòch bodñ
;         shr       ax,1
;         shr       ax,1
;         shr       ax,1                     ; poáet celòch vnit©n°ch bajtñ
;         mov       ds:[MaskNum],al          ; poáet vnit©n°ch bajtñ
;
;; ------ vòpoáet masky pravÇho okraje
;
;         and       bl,7                     ; poáet zbylòch bodñ vpravo (0 aë 7)
;         mov       cl,8                     ; poáet bodñ na bajt
;         sub       cl,bl                    ; poáet nezobraz. bodñ vpravo (1-8)
;         mov       al,0ffh                  ; maska pravÇho okraje
;         shl       al,cl                    ; vòpoáet masky pravÇho okr. (00-FE)
;         mov       ds:[MaskLst],al          ; maska pravÇho okraje (00 - FE)
;         jmp       short PrepEGA4
;
;; ------ oprava prvn° masky pro malò poáet bodñ
;
;PrepEGA3:add       cl,byte ptr ds:[ObjS]    ; koncov† bitov† pozice+1 (1 aë 6)
;         mov       al,8                     ; poáet bodñ na bajt
;         sub       al,cl                    ; poáet nezobrazenòch bodñ vpravo
;         mov       cl,al                    ; poáet nezobrazenòch bodñ vpravo
;         mov       al,0ffh                  ; maska
;         shl       al,cl                    ; rotace korekán° masky
;         and       ds:[MaskFrst],al         ; oprava prvn° masky
;         mov       byte ptr ds:[MaskLst],0  ; nen° prav† maska
;         mov       byte ptr ds:[MaskNum],0  ; nen° ë†dnò vnit©n° bajt
;
;; ------ vòpoáet poá†teán° adresy ve videopamàti
;
;PrepEGA4:mov       ax,ds:[ObjUD]            ; hodn° okraj poá†tku k zobrazen°
;         mul       word ptr ds:[bp+ModSirB] ; vòpoáet poá†teán°ho offsetu linky
;         add       di,ax                    ; poá†teán° adresa linky
;         mov       bx,ds:[ObjLD]            ; levò okraj zaá†tku zobrazen°
;         shr       bx,1
;         shr       bx,1
;         shr       bx,1                     ; p©epoáet na offset v bajtech
;         add       di,bx                    ; poá†teán° adresa k zobrazen°
;
;; ------ nastaven° adresy obsluhy zobrazen° linky
;
;         test      byte ptr ds:[Param],8    ; je maska ?
;         jz        PrepEGA5                 ; nen° maska
;         mov       word ptr ds:[bp+ModDisp],offset DispEG3 ; maska bez rotace
;         cmp       byte ptr ds:[MaskRot],0  ; je rotace ?
;         je        PrepEGA6                 ; nen° rotace
;         mov       word ptr ds:[bp+ModDisp],offset DispEG4 ; maska s rotac°
;         jmp       short PrepEGA6
;
;PrepEGA5:mov       word ptr ds:[bp+ModDisp],offset DispEG2 ; rotace bez masky
;         cmp       byte ptr ds:[MaskRot],0  ; je rotace ?
;         jne       PrepEGA6                 ; je rotace
;         mov       word ptr ds:[bp+ModDisp],offset DispEG1 ; bez rotace i masky
;PrepEGA6:
;         ret
;
;; -----------------------------------------------------------------------------
;;        P©°prava pro zobrazen° roviny EGA
;; -----------------------------------------------------------------------------
;; VSTUP: BL=rovina
;;        DS:SI=poá†teán° adresa prvn° linky
;; -----------------------------------------------------------------------------
;; VùSTUP: DS:SI=poá†teán° adresa k zobrazen°
;;        kromà BP a ES:DI nemus° uchov†vat registry
;; -----------------------------------------------------------------------------
;;
;PUBLIC   SetEGA
;SetEGA:
;
;; ------ uráen° vòstupn° roviny
;
;         mov       cl,bl                    ; á°slo roviny
;         mov       al,1
;         shl       al,cl                    ; rotace na pozici
;         mov       cl,al                    ; á°slo roviny (bitov† maska)
;
;; ------ nastaven° roviny pro vòstup
;
;         mov       dx,3c4h
;         mov       al,2
;         out       dx,al                    ; registr 0 - volba barevnÇ roviny
;         inc       dx
;         mov       al,cl                    ; maska roviny
;         out       dx,al                    ; volba barevnÇ roviny
;
;; ------ nastaven° v®ech bitñ pro z†pis
;
;         mov       dx,3ceh
;         mov       al,8
;         out       dx,al                    ; registr 8 - maska pro z†pis
;         inc       dx
;         mov       al,0ffh
;         out       dx,al                    ; z†pis moëny pro v®echny body
;
;; ------ nastaven° poá†teán° adresy roviny
;
;         mov       ax,cs:[ObjLO]            ; levò okraj poá†tku v objektu
;         add       al,cs:[MaskRot]          ; posun o masku
;         adc       ah,0                     ; p©enos do vy®®°ho bajtu
;         shr       ax,1
;         shr       ax,1
;         shr       ax,1                     ; p©epoáet na bajty
;         add       si,ax                    ; adresa poá†tku linky
;         add       word ptr cs:[MaskAdr],ax ; poá†teán° adresa masky
;
;         ret
;
;; -----------------------------------------------------------------------------
;;        Zobrazen° linky v m¢du EGA - bez rotace a bez masky
;; -----------------------------------------------------------------------------
;; VSTUP: ES:DI=ukl†dac° adresa
;;        DS:SI=adresa obr†zku
;; -----------------------------------------------------------------------------
;; VùSTUP: ES:DI=nov† ukl†dac° adresa
;;        kromà BP a DS nemus° uchov†vat registry
;; -----------------------------------------------------------------------------
;
;PUBLIC   DispEG1
;
;; ------ £schova registrñ
;
;DispEG1: push      di
;
;; ------ p©°prava registrñ
;
;         cld                                ; smàr nahoru
;         mov       cl,cs:[MaskNum]          ; poáet vnit©n°ch bajtñ linky
;         mov       ch,0                     ; CX=poáet bajtñ
;         mov       dx,3cfh                  ; registr masky
;
;; ------ zobrazen° prvn°ho bajtu linky
;
;         mov       al,cs:[MaskFrst]         ; maska prvn°ho bajtu
;         out       dx,al                    ; nastaven° masky pro z†pis
;         lodsb
;         xchg      al,es:[di]
;         inc       di
;
;; ------ zobrazen° vnit©n°ch bajtñ linky
;
;         mov       al,0ffh                  ; maska - v®echny bity
;         out       dx,al                    ; povolen° z†pisu pro v®echny bity
;         rep       movsb                    ; p©enos vnit©n°ch bajtñ
;
;; ------ zobrazen° posledn°ho bajtu linky
;
;         mov       al,cs:[MaskLst]          ; maska posledn°ho bajtu
;         out       dx,al                    ; nastaven° masky pro z†pis
;         lodsb
;         xchg      al,es:[di]
;
;; ------ n†vrat registrñ
;
;         mov       al,0ffh                  ; maska - v®echny bity
;         out       dx,al                    ; povolen° masky pro v®echny bity
;         pop       di
;         add       di,cs:[bp+ModSirB]       ; zvò®en° ukl†dac° adresy
;         ret
;
;
;; -----------------------------------------------------------------------------
;;        Zobrazen° linky v m¢du EGA - rotace bez masky
;; -----------------------------------------------------------------------------
;; VSTUP: ES:DI=ukl†dac° adresa
;;        DS:SI=adresa obr†zku
;; -----------------------------------------------------------------------------
;; VùSTUP: ES:DI=nov† ukl†dac° adresa
;;        kromà BP a DS nemus° uchov†vat registry
;; -----------------------------------------------------------------------------
;
;PUBLIC   DispEG2
;
;; ------ £schova registrñ
;
;DispEG2: push      di
;         push      bp
;
;; ------ p©°prava registrñ
;
;         cld                                ; smàr nahoru
;         mov       cl,cs:[MaskRot]          ; poáet rotac° bajtu
;         mov       ch,cs:[MaskNum]          ; poáet vnit©n°ch bajtñ linky
;         mov       dx,3cfh                  ; registr masky
;
;; ------ zobrazen° prvn°ho bajtu linky
;                                            ; CL=rotace bajtu vpravo
;                                            ; DX=adresa portu masky (03cfh)
;                                            ; DS:SI=adresa zdroje (roviny)
;                                            ; ES:DI=vòstupn° adresa
;
;         mov       al,cs:[MaskFrst]         ; maska prvn°ho bajtu
;         out       dx,al                    ; nastaven° masky pro z†pis
;         mov       ah,ds:[si-1]
;         mov       al,ds:[si]               ; rovina
;         ror       ax,cl                    ; rotace na pozici
;         xchg      al,es:[di]               ; z†pis bajtu na displej
;         inc       di                       ; zvò®en° ukl†dac° adresy
;
;; ------ zobrazen° vnit©n°ch bajtñ linky
;                                            ; CL=rotace vpravo
;                                            ; CH=poáet bajtñ
;                                            ; DX=adresa portu masky (03cfh)
;                                            ; DS:SI=adresa zdroje (roviny)
;                                            ; ES:DI=vòstupn° adresa
;
;         or        ch,ch                    ; je nàjakò vnit©n° bajt ?
;         jz        DispEG23                 ; nen° ë†dnò vnit©n° bajt
;         mov       al,0ffh                  ; maska - v®echny bity
;         out       dx,al                    ; povolen° masky pro v®echny bity
;DispEG22:mov       ah,ds:[si]               ; rovina
;         mov       al,ds:[si+1]
;         inc       si                       ; zvò®en° adresy roviny
;         ror       ax,cl                    ; rotace na pozici
;         xchg      al,es:[di]               ; z†pis bajtu na displej
;         inc       di                       ; zvò®en° ukl†dac° adresy
;         dec       ch                       ; sn°ëen° á°taáe bajtñ
;         jnz       DispEG22                 ; z†pis dal®°ho bajtu
;
;; ------ zobrazen° posledn°ho bajtu linky
;                                            ; CL=rotace bajtu vpravo
;                                            ; DX=adresa portu masky (03cfh)
;                                            ; DS:SI=adresa zdroje (roviny)
;                                            ; ES:DI=vòstupn° adresa
;
;DispEG23:mov       al,cs:[MaskLst]          ; maska posledn°ho bajtu
;         out       dx,al                    ; nastaven° masky pro z†pis
;         mov       al,ds:[si+1]
;         mov       ah,ds:[si]               ; rovina
;         ror       ax,cl                    ; rotace na pozici
;         xchg      al,es:[di]               ; z†pis bajtu na displej
;
;; ------ n†vrat registrñ
;
;         pop       bp
;         pop       di
;         mov       al,0ffh                  ; maska - v®echny bity
;         out       dx,al                    ; povolen° masky pro v®echny bity
;
;         add       di,cs:[bp+ModSirB]       ; zvò®en° ukl†dac° adresy
;         ret
;
;; -----------------------------------------------------------------------------
;;        Zobrazen° linky v m¢du EGA - maska bez rotace
;; -----------------------------------------------------------------------------
;; VSTUP: ES:DI=ukl†dac° adresa
;;        DS:SI=adresa obr†zku
;; -----------------------------------------------------------------------------
;; VùSTUP: ES:DI=nov† ukl†dac° adresa
;;        kromà BP a DS nemus° uchov†vat registry
;; -----------------------------------------------------------------------------
;
;PUBLIC   DispEG3
;
;; ------ £schova registrñ
;
;DispEG3: push      di
;         push      bp
;
;; ------ p©°prava registrñ
;
;         cld                                ; smàr nahoru
;         mov       cl,cs:[MaskNum]          ; poáet vnit©n°ch bajtñ linky
;         mov       ch,0                     ; CX=poáet vnit©n°ch bajtñ linky
;         mov       bx,word ptr cs:[MaskAdr] ; offset adresy masky
;         mov       bp,word ptr cs:[MaskAdr+2] ; segment adresy masky
;         mov       dx,3cfh                  ; registr masky
;
;; ------ zobrazen° prvn°ho bajtu linky
;                                            ; BP:BX=adresa masky
;                                            ; DX=adresa portu masky (03cfh)
;                                            ; DS:SI=adresa zdroje (roviny)
;                                            ; ES:DI=vòstupn° adresa
;
;         push      ds                       ; £schova DS
;         mov       ds,bp                    ; segment masky
;         mov       al,ds:[bx]               ; maska
;         inc       bx
;         pop       ds                       ; n†vrat DS
;         and       al,cs:[MaskFrst]         ; zamaskov†n° prvn°ho bajtu
;         out       dx,al                    ; nastaven° masky pro z†pis
;         lodsb                              ; rovina
;         xchg      al,es:[di]               ; z†pis bajtu na displej
;         inc       di                       ; zvò®en° ukl†dac° adresy
;
;; ------ zobrazen° vnit©n°ch bajtñ linky
;                                            ; BP:BX=adresa masky
;                                            ; CX=poáet bajtñ
;                                            ; DX=adresa portu masky (03cfh)
;                                            ; DS:SI=adresa zdroje (roviny)
;                                            ; ES:DI=vòstupn° adresa
;
;         jcxz      DispEG33                 ; nen° ë†dnò vnit©n° bajt
;DispEG32:push      ds                       ; £schova DS
;         mov       ds,bp                    ; segment masky
;         mov       al,ds:[bx]               ; maska
;         inc       bx                       ; zvò®en° ukazatele masky
;         pop       ds                       ; n†vrat DS
;         out       dx,al                    ; nastaven° masky pro z†pis
;         lodsb                              ; rovina
;         xchg      al,es:[di]               ; z†pis bajtu na displej
;         inc       di                       ; zvò®en° ukl†dac° adresy
;         loop      DispEG32                 ; z†pis dal®°ho bajtu
;
;; ------ zobrazen° posledn°ho bajtu linky
;                                            ; BP:BX=adresa masky
;                                            ; DX=adresa portu masky (03cfh)
;                                            ; DS:SI=adresa zdroje (roviny)
;                                            ; ES:DI=vòstupn° adresa
;
;DispEG33:push      ds                       ; £schova DS
;         mov       ds,bp                    ; segment masky
;         mov       al,ds:[bx]               ; maska
;         pop       ds                       ; n†vrat DS
;         and       al,cs:[MaskLst]          ; zamaskov†n° posledn°ho bajtu
;         out       dx,al                    ; nastaven° masky pro z†pis
;         lodsb                              ; rovina
;         xchg      al,es:[di]               ; z†pis bajtu na displej
;
;; ------ n†vrat registrñ
;
;         mov       al,0ffh                  ; maska - v®echny bity
;         out       dx,al                    ; povolen° masky pro v®echny bity
;         pop       bp
;         pop       di
;
;         add       di,cs:[bp+ModSirB]       ; zvò®en° ukl†dac° adresy
;         ret
;
;
;; -----------------------------------------------------------------------------
;;        Zobrazen° linky v m¢du EGA - rotace i maska
;; -----------------------------------------------------------------------------
;; VSTUP: ES:DI=ukl†dac° adresa
;;        DS:SI=adresa obr†zku
;; -----------------------------------------------------------------------------
;; VùSTUP: ES:DI=nov† ukl†dac° adresa
;;        kromà BP a DS nemus° uchov†vat registry
;; -----------------------------------------------------------------------------
;
;PUBLIC   DispEG4
;
;; ------ £schova registrñ
;
;DispEG4: push      di
;         push      bp
;
;; ------ p©°prava registrñ
;
;         cld                                ; smàr nahoru
;         mov       cl,cs:[MaskRot]          ; poáet rotac° bajtu
;         mov       ch,cs:[MaskNum]          ; poáet vnit©n°ch bajtñ linky
;         mov       bx,word ptr cs:[MaskAdr] ; offset adresy masky
;         mov       bp,word ptr cs:[MaskAdr+2] ; segment adresy masky
;         mov       dx,3cfh                  ; registr masky
;
;; ------ zobrazen° prvn°ho bajtu linky
;                                            ; BP:BX=adresa masky
;                                            ; CL=rotace bajtu vpravo
;                                            ; DX=adresa portu masky (03cfh)
;                                            ; DS:SI=adresa zdroje (roviny)
;                                            ; ES:DI=vòstupn° adresa
;
;         push      ds                       ; £schova DS
;         mov       ds,bp                    ; segment masky
;         mov       ah,ds:[bx-1]
;         mov       al,ds:[bx]               ; maska
;         pop       ds                       ; n†vrat DS
;         ror       ax,cl                    ; rotace na pozici
;         and       al,cs:[MaskFrst]         ; zamaskov†n° prvn°ho bajtu
;         out       dx,al                    ; nastaven° masky pro z†pis
;         mov       ah,ds:[si-1]
;         mov       al,ds:[si]               ; rovina
;         ror       ax,cl                    ; rotace na pozici
;         xchg      al,es:[di]               ; z†pis bajtu na displej
;         inc       di                       ; zvò®en° ukl†dac° adresy
;
;; ------ zobrazen° vnit©n°ch bajtñ linky
;                                            ; BP:BX=adresa masky
;                                            ; CL=rotace vpravo
;                                            ; CH=poáet bajtñ
;                                            ; DX=adresa portu masky (03cfh)
;                                            ; DS:SI=adresa zdroje (roviny)
;                                            ; ES:DI=vòstupn° adresa
;
;         or        ch,ch                    ; je nàjakò vnit©n° bajt ?
;         jz        DispEG43                 ; nen° ë†dnò vnit©n° bajt
;DispEG42:push      ds                       ; £schova DS
;         mov       ds,bp                    ; segment masky
;         mov       ah,ds:[bx]
;         mov       al,ds:[bx+1]             ; maska
;         inc       bx                       ; zvò®en° ukazatele masky
;         pop       ds                       ; n†vrat DS
;         ror       ax,cl                    ; rotace na pozici
;         out       dx,al                    ; nastaven° masky pro z†pis
;         mov       ah,ds:[si]
;         mov       al,ds:[si+1]             ; rovina
;         inc       si                       ; zvò®en° adresy roviny
;         ror       ax,cl                    ; rotace na pozici
;         xchg      al,es:[di]               ; z†pis bajtu na displej
;         inc       di                       ; zvò®en° ukl†dac° adresy
;         dec       ch                       ; sn°ëen° á°taáe bajtñ
;         jnz       DispEG42                 ; z†pis dal®°ho bajtu
;
;; ------ zobrazen° posledn°ho bajtu linky
;                                            ; BP:BX=adresa masky
;                                            ; CL=rotace bajtu vpravo
;                                            ; DX=adresa portu masky (03cfh)
;                                            ; DS:SI=adresa zdroje (roviny)
;                                            ; ES:DI=vòstupn° adresa
;
;DispEG43:push      ds                       ; £schova DS
;         mov       ds,bp                    ; segment masky
;         mov       al,ds:[bx+1]
;         mov       ah,ds:[bx]               ; maska
;         pop       ds                       ; n†vrat DS
;         ror       ax,cl                    ; rotace na pozici
;         and       al,cs:[MaskLst]          ; zamaskov†n° posledn°ho bajtu
;         out       dx,al                    ; nastaven° masky pro z†pis
;         mov       al,ds:[si+1]
;         mov       ah,ds:[si]               ; rovina
;         ror       ax,cl                    ; rotace na pozici
;         xchg      al,es:[di]               ; z†pis bajtu na displej
;
;; ------ n†vrat registrñ
;
;         mov       al,0ffh                  ; maska - v®echny bity
;         out       dx,al                    ; povolen° masky pro v®echny bity
;         pop       bp
;         pop       di
;
;         add       di,cs:[bp+ModSirB]       ; zvò®en° ukl†dac° adresy
;         ret
;

; -----------------------------------------------------------------------------
;        Zobrazen° á†ry
; -----------------------------------------------------------------------------
; VSTUP: AL=barva
;        BX=poá†teán° pozice
;        CX=koncov† pozice
;        DX=poá†teán° linka
;        SI=koncov† linka
; -----------------------------------------------------------------------------

Line     PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       ah,al

; ------ oprava po©ad° sou©adnic (mus° platit Y2 >= Y1)

         cmp       si,dx                    ; koncov† linka pod poá†teán° ?
         jge       Line1                    ; po©ad° sou©adnic je OK
         xchg      si,dx                    ; z†màna sou©adnic Y
         xchg      bx,cx                    ; z†màna sou©adnic X
Line1:   sub       si,dx                    ; rozd°l sou©adnic Y2-Y1

; ------ inicializace registrñ videokarty

         call      InitReg                  ; inicializace registrñ videokarty

; ------ nastaven° registru barvy

         push      dx
         mov       dx,3ceh
         mov       al,0
         out       dx,al
         inc       dx
         mov       al,ah
         out       dx,al
         dec       dx

         mov       al,1
         out       dx,al
         inc       dx
         mov       al,0ffh
         out       dx,al
         pop       dx

; ------ vòpoáet poá†teán° adresy ve videopamàti

         push      bx
         push      cx
         mov       ax,0a000h
         mov       es,ax                    ; segment videopamàti
         mov       ax,ds:[RozmerB]          ; ®°©ka linky v bajtech
         mul       dx                       ; vòpoáet poá†teán°ho offsetu linky
         mov       di,ax                    ; poá†teán° adresa linky
         mov       cl,bl                    ; pozice bodu - nië®° slovo
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; p©epoáet na offset v bajtech
         add       di,bx                    ; poá†teán° adresa k zobrazen°

; ------ maskovac° bit zaá†tku

         mov       dx,03ceh
         and       cl,7                     ; poá†teán° bitov† pozice v bajtu
         mov       al,8
         out       dx,al
         inc       dx
         mov       al,80h
         shr       al,cl
         pop       bx
         pop       cx

; ------ rozd°l sou©adnic X a rozli®en°, zda jde shora vlevo nebo vpravo

         sub       bx,cx                    ; rozd°l sou©adnic X2-X1
         js        Lin3EGA                  ; jde smàrem vlevo

; ------ á†ra jde shora vpravo


; ------ rozli®en°, zda jde strmà vpravo

         cmp       bx,si                    ; je vàt®° p©°rustek ve smàru X ?
         jb        Lin2EGA                  ; jde strmà vpravo dolñ

; ------ á†ra jde m°rnà vpravo dolñ

         mov       cx,bx                    ; uráuj°c° je p©°rustek X
         inc       cx                       ; poáet krokñ á†ry
         shl       si,1                     ; rozd°l sou©adnic dY*2
         mov       bp,si                    ; £schova dY*2
         sub       bp,bx                    ; dY*2 - dX
         shl       bx,1                     ; dX*2
         sub       si,bx                    ; dY*2 - dX*2
         add       bx,si                    ; dX*2 + dY*2 - dX*2 = dY*2
         mov       ah,al                    ; maska poá†teán°ho bitu
Lin1EGA1:or        al,ah
         or        bp,bp
         jns       Lin1EGA2
         add       bp,bx
         jmp       short Lin1EGA3
Lin1EGA2:out       dx,al
         xchg      al,es:[di]
         xor       al,al
         add       di,ds:[RozmerB]
         add       bp,si
         ror       ah,1
         adc       di,0
         jmp       short Lin1EGA4
Lin1EGA3:ror       ah,1
         jnc       Lin1EGA4
         out       dx,al
         xchg      al,es:[di]
         inc       di
         xor       al,al
Lin1EGA4:loop      Lin1EGA1
         out       dx,al
         xchg      al,es:[di]
         jmp       LinEGA9

; ------ á†ra jde strmà vpravo dolñ

Lin2EGA: mov       cx,si
         inc       cx
         shl       bx,1
         mov       bp,bx
         sub       bp,si
         shl       si,1
         sub       bx,si
         add       si,bx
         out       dx,al
Lin2EGA1:xchg      ah,es:[di]
         or        bp,bp
         jns       Lin2EGA3
         add       bp,si
         jmp       short Lin2EGA4
Lin2EGA3:ror       al,1
         adc       di,0
         out       dx,al
         add       bp,bx
Lin2EGA4:add       di,ds:[RozmerB]
         loop      Lin2EGA1
         jmp       LinEGA9

; ------ á†ra jde shora vlevo

Lin3EGA: neg       bx
         cmp       bx,si
         jb        Lin4EGA

; ------ á†ra jde m°rnà vlevo

         mov       cx,bx
         inc       cx
         shl       si,1
         mov       bp,si
         sub       bp,bx
         shl       bx,1
         sub       si,bx
         add       bx,si
         mov       ah,al
Lin3EGA1:or        al,ah
         or        bp,bp
         jns       Lin3EGA3
         add       bp,bx
         jmp       short Lin3EGA4
Lin3EGA3:out       dx,al
         xchg      al,es:[di]
         xor       al,al
         add       di,ds:[RozmerB]
         add       bp,si
         rol       ah,1
         sbb       di,0
         jmp       short Lin3EGA5
Lin3EGA4:rol       ah,1
         jnb       Lin3EGA5
         out       dx,al
         xchg      al,es:[di]
         dec       di
         xor       al,al
Lin3EGA5:loop      Lin3EGA1
         out       dx,al
         xchg      al,es:[di]
         jmp       LinEGA9

; ------ á†ra jde strmà vlevo

Lin4EGA: mov       cx,si
         inc       cx
         shl       bx,1
         mov       bp,bx
         sub       bp,si
         shl       si,1
         sub       bx,si
         add       si,bx
         out       dx,al
Lin4EGA1:xchg      ah,es:[di]
         or        bp,bp
         jns       Lin4EGA2
         add       bp,si
         jmp       short Lin4EGA3
Lin4EGA2:rol       al,1
         sbb       di,0
         out       dx,al
         add       bp,bx
Lin4EGA3:add       di,ds:[RozmerB]
         loop      Lin4EGA1

; ------ konec - n†vrat registrñ

LinEGA9: call      DeIniReg                 ; n†vrat registrñ videokarty
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Line     ENDP

; -----------------------------------------------------------------------------
;                       Zobrazen° bodu
; -----------------------------------------------------------------------------
; VSTUP: AL=barva
;        BX=pozice
;        DX=linka
; -----------------------------------------------------------------------------

Point    PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      es

; ------ inicializace registrñ videokarty

         call      InitReg                  ; inicializace registrñ videokarty

; ------ vòpoáet adresy ve videopamàti

         mov       ax,0a000h
         mov       es,ax                    ; segment videopamàti
         mov       ax,dx                    ; linka bodu
         mul       word ptr ds:[RozmerB]    ; vòpoáet poá†teán°ho offsetu linky
         mov       di,ax                    ; poá†teán° adresa linky
         mov       cl,bl                    ; pozice bodu - nië®° slovo
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; p©epoáet na offset v bajtech
         add       di,bx                    ; poá†teán° adresa k zobrazen°

; ------ nastaven° registru masky

         mov       dx,3ceh
         mov       al,8
         out       dx,al                    ; volba registru 8 - reg. masky
         inc       dx                       ; 3cfh - adresa registru masky
         and       cl,7                     ; bitov† pozice (0 aë 7)
         mov       al,80h                   ; inicializaán° maska
         shr       al,cl                    ; rotace masky vpravo (80h aë 01h)
         out       dx,al                    ; nastaven° masky bodu

; ------ z†pis bodu

         xchg      al,es:[di]               ; z†pis bodu do roviny

; ------ n†vrat registrñ

         call      DeIniReg                 ; n†vrat registrñ videokarty
         pop       es
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Point    ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

Rezim    db        0                        ; p©°znaky reëimu
                                            ;    bit 0: 1=je XOR

RozmerX  dw        640                      ; maxim†ln° rozmàr X
RozmerB  dw        80                       ; dÇlka linky v bajtech
RozmerY  dw        350                      ; maxim†ln° rozmàr Y
MaxX     dw        639
MaxY     dw        349

TopX     dw        0
TopY     dw        0

OldX     dw        0                        ; pñvodn° pozice my®i X
OldY     dw        0                        ; pñvodn° pozice my®i Y
OldKey   db        0                        ; pñvodn° tlaá°tka my®i

OldVMod  db        3

MouseErr db        'Nenainstalovan ovladac mysi !',13,10,'$'

; -----------------------------------------------------------------------------
;        definice ikon
; -----------------------------------------------------------------------------
;˛
NumIkon  dw        20                       ; poáet ikon menu
IkonX    dw        640-2*24                 ; poá†teán° pozice ikon
IkonY    dw        0                        ; poá†teán° linka ikon

IkonAkt  dw        -1                       ; aktivn° ikona

IkonYM   dw        12*24                    ; poá†teán° linka ikon my®i

IkonL    dw        0                        ; aktivn° ikona my®i - levÇ tlaá°tko
IkonR    dw        0                        ; aktivn° ikona my®i-pravÇ tlaá°tko
IkonLC   dw        4                        ; levÇ tlaá°tko - á†ra
IkonRC   dw        5                        ; levÇ tlaá°tko - á†ra

; ------ zaá†tek definice ikon

DefIkon  label     byte

         db        11111111b,11111111b,11111111b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000110b,00000000b,00000001b
         db        10001111b,00000000b,00000001b
         db        10001111b,00000000b,00000001b
         db        10000110b,01000000b,00000001b
         db        10000000b,01100000b,00000001b
         db        10000000b,01011000b,00000001b
         db        10000000b,01111101b,10000001b
         db        10000000b,00011011b,01000001b
         db        10000000b,00001111b,00100001b
         db        10000000b,00000111b,10010001b
         db        10000000b,00000011b,11001001b
         db        10000000b,00000001b,11100101b
         db        10000000b,00000000b,11110101b
         db        10000000b,00000000b,01111001b
         db        10000000b,00000000b,00011101b
         db        10000000b,00000000b,00001111b
         db        10000000b,00000000b,00000011b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        11111111b,11111111b,11111111b

DefIkon0 label     byte

         db        11111111b,11111111b,11111111b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000100b,00000000b,00000001b
         db        10000110b,00000000b,00000001b
         db        10000011b,00000000b,00000001b
         db        10000001b,10000000b,00000001b
         db        10000000b,11000000b,00000001b
         db        10000000b,01100000b,00000001b
         db        10000000b,00110000b,00000001b
         db        10000000b,00011000b,00000001b
         db        10000000b,00001100b,00000001b
         db        10000000b,00000110b,00000001b
         db        10000000b,00000011b,00000001b
         db        10000000b,00000001b,10000001b
         db        10000000b,00000000b,11000001b
         db        10000000b,00000000b,01100001b
         db        10000000b,00000000b,00100001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        11111111b,11111111b,11111111b

         db        11111111b,11111111b,11111111b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10011111b,11111111b,11100001b
         db        10011111b,11111111b,11100001b
         db        10011111b,11111111b,11111101b
         db        10011111b,11111111b,11100101b
         db        10011111b,11111111b,11100101b
         db        10011111b,11111111b,11100101b
         db        10011111b,11111111b,11100101b
         db        10011111b,11111111b,11100101b
         db        10011111b,11111111b,11100101b
         db        10011111b,11111111b,11100101b
         db        10011111b,11111111b,11100101b
         db        10011111b,11111111b,11100101b
         db        10000100b,00000000b,00000101b
         db        10000100b,00000000b,00000101b
         db        10000111b,11111111b,11111101b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        11111111b,11111111b,11111111b

         db        11111111b,11111111b,11111111b
         db        10000000b,00000000b,00000001b
         db        10001101b,10110110b,11000001b
         db        10001000b,00000000b,01000001b
         db        10000000b,00000000b,00000001b
         db        10001000b,00000000b,01000001b
         db        10001000b,00000000b,01000001b
         db        10000000b,00000000b,00000001b
         db        10001000b,00000000b,01000001b
         db        10001000b,00000000b,01000001b
         db        10000000b,00000000b,00000001b
         db        10001000b,00000000b,01000001b
         db        10001101b,10110110b,11000001b
         db        10000000b,00000000b,00000001b
         db        10001111b,00000100b,00010001b
         db        10011111b,10000110b,00110001b
         db        10011111b,10000011b,01100001b
         db        10001111b,00000001b,11000001b
         db        10000110b,00000000b,10000001b
         db        10000110b,00000111b,01110001b
         db        10011111b,10001001b,01001001b
         db        10111111b,11000110b,00110001b
         db        10000000b,00000000b,00000001b
         db        11111111b,11111111b,11111111b

         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11100000b,00000000b,00000111b
         db        11100000b,00000000b,00000111b
         db        11100111b,11111111b,11100111b
         db        11000100b,00000000b,00100111b
         db        10000000b,00000000b,00100111b
         db        11000000b,11111111b,00100111b
         db        11100000b,00111111b,00100111b
         db        11100100b,00000011b,00100111b
         db        11100100b,00000011b,00100111b
         db        11100100b,11000000b,00100111b
         db        11100100b,11000000b,00100111b
         db        11100100b,11111100b,00000111b
         db        11100100b,11111111b,00000011b
         db        11100100b,00000000b,00000001b
         db        11100100b,00000000b,00100011b
         db        11100111b,11111111b,11100111b
         db        11100000b,00000000b,00000111b
         db        11100000b,00000000b,00000111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b

         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11100000b,00000000b,00000111b
         db        11100000b,00000000b,00000111b
         db        11100111b,11111111b,11100111b
         db        11110100b,00000000b,00100111b
         db        11111100b,00000000b,00100111b
         db        11111111b,11111111b,00100111b
         db        11101111b,11111111b,00100111b
         db        11100111b,11110011b,00100111b
         db        11100100b,11111111b,00100111b
         db        11100100b,11111111b,00100111b
         db        11100100b,11001111b,11100111b
         db        11100100b,11111111b,11110111b
         db        11100100b,11111111b,11111111b
         db        11100100b,00000000b,00111111b
         db        11100100b,00000000b,00101111b
         db        11100111b,11111111b,11100111b
         db        11100000b,00000000b,00000111b
         db        11100000b,00000000b,00000111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b

         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11100000b,00000000b,00000111b
         db        11100000b,00000000b,00000111b
         db        11100111b,11111111b,11100111b
         db        11010100b,00000000b,00100111b
         db        10011000b,00000000b,00100111b
         db        11011011b,11111111b,00100111b
         db        11101011b,00111111b,00100111b
         db        11100111b,00110011b,00100111b
         db        11100100b,00111111b,00100111b
         db        11100100b,11111100b,00100111b
         db        11100100b,11001100b,11100111b
         db        11100100b,11111100b,11010111b
         db        11100100b,11111111b,11011011b
         db        11100100b,00000000b,00011001b
         db        11100100b,00000000b,00101011b
         db        11100111b,11111111b,11100111b
         db        11100000b,00000000b,00000111b
         db        11100000b,00000000b,00000111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b


         db        11111111b,11111111b,11111111b
         db        10000000b,00000000b,00000001b
         db        10000000b,00111100b,00000001b
         db        10000000b,11000011b,00000001b
         db        10000001b,00110000b,10000001b
         db        10000010b,11000000b,01000001b
         db        10000010b,10000000b,01000001b
         db        10000100b,00000000b,00100001b
         db        10000100b,00000000b,00100001b
         db        10000100b,00000000b,00100001b
         db        10000100b,00000000b,00100001b
         db        10000010b,00000000b,01000001b
         db        10000010b,00000000b,01000001b
         db        10000001b,00000000b,10000001b
         db        10000000b,11000011b,00000001b
         db        10000000b,00111100b,00000001b
         db        10000000b,00101100b,00000001b
         db        10000000b,00101100b,00000001b
         db        10000000b,00101100b,00000001b
         db        10000000b,00101100b,00000001b
         db        10000000b,00100100b,00000001b
         db        10000000b,00011000b,00000001b
         db        10000000b,00000000b,00000001b
         db        11111111b,11111111b,11111111b


         db        11111111b,11111111b,11111111b
         db        10000000b,00000000b,00000001b
         db        10000000b,00010000b,00000001b
         db        10000000b,00111000b,00000001b
         db        10000000b,01010100b,00000001b
         db        10000000b,00010000b,00000001b
         db        10000000b,00010000b,00000001b
         db        10000000b,00010000b,00000001b
         db        10000000b,00010000b,00000001b
         db        10001000b,00000000b,00100001b
         db        10010000b,00000000b,00010001b
         db        10111111b,10010011b,11111001b
         db        10010000b,00000000b,00010001b
         db        10001000b,00000000b,00100001b
         db        10000000b,00010000b,00000001b
         db        10000000b,00010000b,00000001b
         db        10000000b,00010000b,00000001b
         db        10000000b,00010000b,00000001b
         db        10000000b,01010100b,00000001b
         db        10000000b,00111000b,00000001b
         db        10000000b,00010000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        11111111b,11111111b,11111111b

         db        11111111b,11111111b,11111111b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,01000001b
         db        10000000b,00000000b,00100001b
         db        10000011b,11111111b,11110001b
         db        10000000b,00000000b,00100001b
         db        10000000b,00000000b,01000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000001b,00000001b
         db        10000000b,00000000b,10000001b
         db        10001111b,11111111b,11000001b
         db        10000000b,00000000b,10000001b
         db        10000000b,00000001b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000100b,00000001b
         db        10000000b,00000010b,00000001b
         db        10111111b,11111111b,00000001b
         db        10000000b,00000010b,00000001b
         db        10000000b,00000100b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        11111111b,11111111b,11111111b

         db        11111111b,11111111b,11111111b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000010b,00000000b,00000001b
         db        10000100b,00000000b,00000001b
         db        10001100b,00000000b,00000001b
         db        10011111b,11111111b,11111001b
         db        10001100b,00000000b,00000001b
         db        10000100b,00000000b,00000001b
         db        10000010b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        11111111b,11111111b,11111111b

         db        11111111b,11111111b,11111111b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,01000001b
         db        10000000b,00000000b,00100001b
         db        10000000b,00000000b,00110001b
         db        10011111b,11111111b,11111001b
         db        10000000b,00000000b,00110001b
         db        10000000b,00000000b,00100001b
         db        10000000b,00000000b,01000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        11111111b,11111111b,11111111b

         db        11111111b,11111111b,11111111b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00001000b,00000001b
         db        10000000b,00011100b,00000001b
         db        10000000b,00111110b,00000001b
         db        10000000b,01001001b,00000001b
         db        10000000b,00001000b,00000001b
         db        10000000b,00001000b,00000001b
         db        10000000b,00001000b,00000001b
         db        10000000b,00001000b,00000001b
         db        10000000b,00001000b,00000001b
         db        10000000b,00001000b,00000001b
         db        10000000b,00001000b,00000001b
         db        10000000b,00001000b,00000001b
         db        10000000b,00001000b,00000001b
         db        10000000b,00001000b,00000001b
         db        10000000b,00001000b,00000001b
         db        10000000b,00001000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        11111111b,11111111b,11111111b

         db        11111111b,11111111b,11111111b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00001000b,00000001b
         db        10000000b,00001000b,00000001b
         db        10000000b,00001000b,00000001b
         db        10000000b,00001000b,00000001b
         db        10000000b,00001000b,00000001b
         db        10000000b,00001000b,00000001b
         db        10000000b,00001000b,00000001b
         db        10000000b,00001000b,00000001b
         db        10000000b,00001000b,00000001b
         db        10000000b,00001000b,00000001b
         db        10000000b,00001000b,00000001b
         db        10000000b,00001000b,00000001b
         db        10000000b,01001001b,00000001b
         db        10000000b,00111110b,00000001b
         db        10000000b,00011100b,00000001b
         db        10000000b,00001000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        11111111b,11111111b,11111111b

         db        11111111b,11111111b,11111111b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,11110001b
         db        10000000b,00001111b,00010001b
         db        10000000b,11110000b,00010001b
         db        10000000b,10000000b,00010001b
         db        10000000b,10000000b,00010001b
         db        10111111b,11110011b,11110001b
         db        10011000b,10010010b,00010001b
         db        10011000b,10000000b,00010001b
         db        10011001b,10000000b,01010001b
         db        10011111b,10000000b,01110001b
         db        10011001b,10000000b,01010001b
         db        10011000b,10000000b,00010001b
         db        10011000b,10000000b,00010001b
         db        10011000b,10010010b,00010001b
         db        10111111b,11110011b,11110001b
         db        10000000b,10000000b,00010001b
         db        10000000b,10000000b,00010001b
         db        10000000b,11110000b,00010001b
         db        10000000b,00001111b,00010001b
         db        10000000b,00000000b,11110001b
         db        10000000b,00000000b,00000001b
         db        11111111b,11111111b,11111111b

         db        11111111b,11111111b,11111111b
         db        10000000b,00000000b,00000001b
         db        10011111b,11111111b,11111001b
         db        10010000b,01111111b,00001001b
         db        10010000b,01000011b,00001001b
         db        10010000b,00100110b,00001001b
         db        10001000b,00100110b,00010001b
         db        10001000b,00011100b,00010001b
         db        10001000b,00011100b,00010001b
         db        10001000b,00001000b,00010001b
         db        10000100b,00000000b,00100001b
         db        10000100b,00001000b,00100001b
         db        10000100b,00011100b,00100001b
         db        10000111b,11111111b,11100001b
         db        10000000b,00100110b,00000001b
         db        10000000b,00100011b,00000001b
         db        10000000b,01000011b,00000001b
         db        10000000b,01000001b,10000001b
         db        10000000b,11111111b,10000001b
         db        10000000b,10000000b,11000001b
         db        10000001b,00000000b,11000001b
         db        10000011b,10000001b,11100001b
         db        10000000b,00000000b,00000001b
         db        11111111b,11111111b,11111111b


         db        11111111b,11111111b,11111111b
         db        10000000b,00000000b,00000001b
         db        10000001b,00000011b,11111101b
         db        10000011b,10000010b,00001101b
         db        10000011b,10000000b,00011001b
         db        10000100b,11000000b,00110001b
         db        10000100b,11000000b,01100001b
         db        10001000b,01100000b,11000001b
         db        10001111b,11100001b,10000001b
         db        10010000b,00110011b,00000101b
         db        10111000b,01111011b,11111101b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000010b,00000000b,00100001b
         db        10000100b,00000000b,00010001b
         db        10001100b,00000000b,00011001b
         db        10011111b,11111111b,11111101b
         db        10001100b,00000000b,00011001b
         db        10000100b,00000000b,00010001b
         db        10000010b,00000000b,00100001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        11111111b,11111111b,11111111b

         db        11111111b,11111111b,11111111b
         db        10000000b,00001111b,11111111b
         db        10000000b,00001111b,11111111b
         db        10000000b,00010111b,11111111b
         db        10000000b,00110011b,11111111b
         db        10000000b,00110011b,11111111b
         db        10000000b,01010001b,11111111b
         db        10000000b,01010001b,11111111b
         db        10000000b,10000000b,11111111b
         db        10000000b,10000000b,11111111b
         db        10000001b,00001000b,01111111b
         db        10000001b,00001000b,01111111b
         db        10000010b,00001100b,00111111b
         db        10000010b,00001100b,00111111b
         db        10000111b,11110000b,00011111b
         db        10000100b,00001110b,00011111b
         db        10001000b,00001111b,00001111b
         db        10001000b,00001111b,00001111b
         db        10010000b,00001111b,10000111b
         db        10111000b,00001111b,00000011b
         db        10000000b,00001111b,11111111b
         db        10000000b,00001111b,11111111b
         db        10000000b,00001111b,11111111b
         db        11111111b,11111111b,11111111b

         db        11111111b,11111111b,11111111b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10011111b,11111111b,11111001b
         db        10011111b,11111111b,11111001b
         db        10011111b,11111111b,11111001b
         db        10011111b,11111111b,11111001b
         db        10011111b,11111111b,11111001b
         db        10011111b,11000011b,11111001b
         db        10011111b,10000001b,11111001b
         db        10011111b,00000000b,11111001b
         db        10011111b,00000000b,11111001b
         db        10011111b,10000001b,11111001b
         db        10011111b,11000011b,11111001b
         db        10011111b,11111111b,11111001b
         db        10011111b,11100111b,11111001b
         db        10011111b,11100111b,11111001b
         db        10011111b,11100111b,11111001b
         db        10011111b,11100111b,11111001b
         db        10011111b,11111111b,11111001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        11111111b,11111111b,11111111b


         db        11111111b,11111111b,11111111b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10010000b,00000000b,00001001b
         db        10001000b,00000000b,00010001b
         db        10000100b,00000000b,00100001b
         db        10000010b,00000000b,01000001b
         db        10000001b,00000000b,10000001b
         db        10000000b,10000001b,00000001b
         db        10000000b,01000010b,00000001b
         db        10000000b,00100100b,00000001b
         db        10000000b,00011000b,00000001b
         db        10000000b,00011000b,00000001b
         db        10000000b,00100100b,00000001b
         db        10000000b,01000010b,00000001b
         db        10000000b,10000001b,00000001b
         db        10000001b,00000000b,10000001b
         db        10000010b,00000000b,01000001b
         db        10000100b,00000000b,00100001b
         db        10001000b,00000000b,00010001b
         db        10010000b,00000000b,00001001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        11111111b,11111111b,11111111b



         db        11111111b,11111111b,11111111b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        11111111b,11111111b,11111111b

         db        11111111b,11111111b,11111111b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        10000000b,00000000b,00000001b
         db        11111111b,11111111b,11111111b








Pattern0 db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b

Pattern1 db        00100010b
         db        01000000b
         db        10001000b
         db        00000100b
         db        00100010b
         db        01000000b
         db        10001000b
         db        00000100b


KurzMap  dw        1111111111111111b
         dw        0001111111111111b
         dw        0000000111111111b
         dw        1000000000111111b
         dw        1000000001111111b
         dw        1000000011111111b
         dw        1100000011111111b
         dw        1100010001111111b
         dw        1100111000111111b
         dw        1111111100011111b
         dw        1111111110011111b
         dw        1111111111111111b
         dw        1111111111111111b
         dw        1111111111111111b
         dw        1111111111111111b
         dw        1111111111111111b

         dw        0000000000000000b
         dw        0110000000000000b
         dw        0111111000000000b
         dw        0011111111000000b
         dw        0011111100000000b
         dw        0011111000000000b
         dw        0001101100000000b
         dw        0001000110000000b
         dw        0000000011000000b
         dw        0000000001100000b
         dw        0000000000000000b
         dw        0000000000000000b
         dw        0000000000000000b
         dw        0000000000000000b
         dw        0000000000000000b
         dw        0000000000000000b

buffer   label     byte

code     ends
         end       start

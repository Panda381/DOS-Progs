
Code     SEGMENT
         ASSUME    cs:Code,ds:Code

; ------ konstanty

IncSour  EQU       6                        ; p©¡rustek sou©adnic interval
IncSour0 EQU       1                        ; p©¡rustek sou©adnic minim lnˆ
MaxLine  EQU       40                       ; po‡et zobrazen˜ch ‡ar demonstrace
RozmerB  EQU       80                       ; ¨¡©ka linky v bajtech
DimX     EQU       640                      ; rozmˆr X
DimY     EQU       350                      ; rozmˆr Y
NColor   EQU       16                       ; po‡et barev celkem

; ------ data - offsety od registru BP

XBuffUk  EQU       0                        ; ukazatel v z znamn¡c¡ch
XJMax    EQU       2                        ; po‡et ‡ar se stejnou barvou

XX1      EQU       4                        ; sou©adnice X bodu 1
XX2      EQU       6                        ; sou©adnice X bodu 2
XY1      EQU       8                        ; sou©adnice Y bodu 1
XY2      EQU       10                       ; sou©adnice Y bodu 2

XdX1     EQU       12                       ; p©¡rustek sou©adnice X bodu 1
XdX2     EQU       14                       ; p©¡rustek sou©adnice X bodu 2
XdY1     EQU       16                       ; p©¡rustek sou©adnice Y bodu 1
XdY2     EQU       18                       ; p©¡rustek sou©adnice Y bodu 2

XSegVRAM EQU       20                       ; segment videopamˆti

XRandNum EQU       22                       ; n hodn‚ ‡¡slo

XColor   EQU       26                       ; aktivn¡ barva ‡ ry

XOldVMod EQU       27                       ; p–vodn¡ videom¢d

                                          ;* zde by mˆla b˜t sud  adresa
XBufX1   EQU       28                       ; z znamn¡k sou©adnic X bodu 1
XBufX2   EQU       2*MaxLine+XBufX1         ; z znamn¡k sou©adnic X bodu 2
XBufY1   EQU       4*MaxLine+XBufX1         ; z znamn¡k sou©adnic Y bodu 1
XBufY2   EQU       6*MaxLine+XBufX1         ; z znamn¡k sou©adnic Y bodu 2

         org       100h

; ------ vymaz n¡ buffer– ‡ar

Start:   mov       di,offset BufX1
         mov       cx,MaxLine*4
         xor       ax,ax
         cld
         rep       stosw

; ------ inicializace videom¢du

         mov       ah,0fh
         int       10h
         mov       ds:[OldVMod],al          ; £schova p–vodn¡ho videom¢du
         mov       ax,16
         int       10h

; ------ ukazatel datov˜ch promˆnn˜ch

         mov       bp,offset Data
         mov       es,ss:[bp+XSegVRAM]      ; segment videopamˆti

; ------ inicializace gener toru n hody

         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       ax,ds:[46ch]
         mov       dx,ds:[46eh]
         pop       ds
         mov       word ptr ss:[bp+XRandNum],ax
         mov       word ptr ss:[bp+XRandNum+2],dx

; ------ obsluha zmˆny barvy

Start4:  dec       word ptr ss:[bp+XJMax]   ; ‡¡ta‡ stejn‚ barvy
         jnz       Shows1                   ; nen¡ zmˆna barvy

; ------ nov  barva

Shows02: mov       bl,NColor
         call      Random0
         test      al,7
         jz        Shows02                  ; z kaz ‡ern‚ a ¨ed‚ barvy
         mov       ss:[bp+XColor],al        ; barva

; ------ nov˜ po‡et ‡ar stejn‚ barvy

         mov       bl,80
         call      Random0
         add       ax,20
         mov       ss:[bp+XJMax],ax         ; po‡et ‡ar se stejnou barvou

; ------ vymaz n¡ star˜ch ‡ar

Shows1:  mov       ah,0
         call      DispLine                 ; vymaz n¡ star˜ch ‡ar

; ------ posun sou©adnice X bodu 1

         mov       ax,ss:[bp+XX1]
         add       ax,ss:[bp+XdX1]
         jns       Shows21                  ; nen¡ < 0

         call      RandDX
         jmp       short Shows23

Shows21: cmp       ax,DimX
         jl        Shows22                  ; nen¡ vˆt¨¡ ne‘ MaxX

         call      RandDX
         neg       ax
Shows23: mov       ss:[bp+XdX1],ax
         add       ax,ss:[bp+XX1]

Shows22: mov       ss:[bp+XX1],ax           ; nov  sou©adnice X

; ------ posun sou©adnice Y bodu 1

         mov       ax,ss:[bp+XY1]
         add       ax,ss:[bp+XdY1]
         jns       Shows31                  ; nen¡ < 0

         call      RandDX
         jmp       short Shows33

Shows31: cmp       ax,DimY
         jl        Shows32                  ; nen¡ vˆt¨¡ ne‘ MaxX

         call      RandDX
         neg       ax
Shows33: mov       ss:[bp+XdY1],ax
         add       ax,ss:[bp+XY1]

Shows32: mov       ss:[bp+XY1],ax           ; nov  sou©adnice X

; ------ posun sou©adnice X bodu 2

         mov       ax,ss:[bp+XX2]
         add       ax,ss:[bp+XdX2]
         jns       Shows41                  ; nen¡ < 0

         call      RandDX
         jmp       short Shows43

Shows41: cmp       ax,DimX
         jl        Shows42                  ; nen¡ vˆt¨¡ ne‘ MaxX

         call      RandDX
         neg       ax
Shows43: mov       ss:[bp+XdX2],ax
         add       ax,ss:[bp+XX2]

Shows42: mov       ss:[bp+XX2],ax           ; nov  sou©adnice X

; ------ posun sou©adnice Y bodu 2

         mov       ax,ss:[bp+XY2]
         add       ax,ss:[bp+XdY2]
         jns       Shows51                  ; nen¡ < 0

         call      RandDX
         jmp       short Shows53

Shows51: cmp       ax,DimY
         jl        Shows52                  ; nen¡ vˆt¨¡ ne‘ MaxX

         call      RandDX
         neg       ax
Shows53: mov       ss:[bp+XdY2],ax
         add       ax,ss:[bp+XY2]

Shows52: mov       ss:[bp+XY2],ax           ; nov  sou©adnice X

; ------ zobrazen¡ nov˜ch ‡ar + £schova sou©adnic

         mov       bx,ss:[bp+XX1]           ; po‡ te‡n¡ pozice
         mov       dx,ss:[bp+XY1]           ; po‡ te‡n¡ linka
         mov       cx,ss:[bp+XX2]           ; koncov  pozice
         mov       si,ss:[bp+XY2]           ; koncov  linka
         mov       ds:[di+BufX1],bx
         mov       ds:[di+BufY1],dx
         mov       ds:[di+BufX2],cx
         mov       ds:[di+BufY2],si

         mov       ah,ss:[bp+XColor]        ; barva
         call      DispLine

; ------ zv˜¨en¡ ukazatele v bufferu sou©adnic

         inc       di
         inc       di
         cmp       di,MaxLine*2
         jb        Shows6
         xor       di,di
Shows6:  mov       ss:[bp+XBuffUk],di       ; nov˜ ukazatel v bufferu

; ------ test p©eru¨en¡ programu

         mov       ah,1
         int       16h                      ; test stavu kl vesnice
         jnz       Start6                   ; konec programu
         jmp       Start4                   ; nen¡ ‘ dn  kl vesa

; ------ konec programu

Start6:  mov       ah,0
         int       16h                      ; zru¨en¡ kl vesy z bufferu

         mov       al,ss:[bp+XOldVMod]      ; p–vodn¡ videom¢d
         mov       ah,0
         int       10h                      ; n vrat p–vodn¡ho videom¢du

         mov       dx,offset UvTxt
         mov       ah,9
         int       21h

         int       20h

; -----------------------------------------------------------------------------
;        zobrazen¡ ‡ar v bufferu - barva AH
; -----------------------------------------------------------------------------

DispLine PROC      NEAR

         mov       di,ss:[bp+XBuffUk]       ; ukazatel v bufferu
         mov       bx,ds:[di+BufX1]         ; po‡ te‡n¡ pozice
         mov       dx,ds:[di+BufY1]         ; po‡ te‡n¡ linka
         mov       cx,ds:[di+BufX2]         ; koncov  pozice
         mov       si,ds:[di+BufY2]         ; koncov  linka
         call      Line                     ; vymaz n¡ prvn¡ ‡ ry

         sub       dx,DimY-1
         neg       dx
         sub       si,DimY-1
         neg       si
         call      Line                     ; vymaz n¡ druh‚ ‡ ry
         ret

DispLine ENDP

; *****************************************************************************
;                                   RandDX
;                      generov n¡ n hodn‚ho p©¡rustku
; -----------------------------------------------------------------------------
; *****************************************************************************

RandDX   PROC      NEAR

         mov       bl,IncSour
         call      Random0
         add       ax,IncSour0
         ret

RandDX   ENDP

; *****************************************************************************
;                                 Random
;                          gener tor n hody
; -----------------------------------------------------------------------------
; VSTUP: BX=interval (po‡et hodnot)
; VSTUP:AX=n hodn‚ ‡¡slo
; *****************************************************************************

Random0: mov       bh,0

Random   PROC      NEAR

         push      dx
         push      di

         mov       ax,word ptr ss:[bp+XRandNum]
         mov       di,word ptr ss:[bp+XRandNum+2]
         rol       ax,1
         rol       di,1
         xor       al,ss:[di]
         xor       ah,ss:[di+1]
         xor       di,ax
         mov       word ptr ss:[bp+XRandNum],ax
         mov       word ptr ss:[bp+XRandNum+2],di

         xor       dx,dx
         div       bx
         mov       ax,dx

Random9: pop       di
         pop       dx
         ret

Random   ENDP


; *****************************************************************************
;        Zobrazen¡ ‡ ry
; -----------------------------------------------------------------------------
; VSTUP: AH=barva
;        BX=po‡ te‡n¡ pozice
;        CX=koncov  pozice
;        DX=po‡ te‡n¡ linka
;        SI=koncov  linka
;        ES=segment videopamˆti
; *****************************************************************************

Line     PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp

; ------ oprava po©ad¡ sou©adnic (mus¡ platit Y2 >= Y1)

         cmp       si,dx                    ; koncov  linka pod po‡ te‡n¡ ?
         jge       Line1                    ; po©ad¡ sou©adnic je OK
         xchg      si,dx                    ; z mˆna sou©adnic Y
         xchg      bx,cx                    ; z mˆna sou©adnic X
Line1:   sub       si,dx                    ; rozd¡l sou©adnic Y2-Y1

; ------ nastaven¡ registru barvy

         push      dx
         mov       dx,3ceh
         mov       al,0
         out       dx,al
         inc       dx
         mov       al,ah                    ; po‘adovan  barva
         out       dx,al
         dec       dx

         mov       al,1
         out       dx,al
         inc       dx
         mov       al,0ffh
         out       dx,al
         pop       dx

; ------ v˜po‡et po‡ te‡n¡ adresy ve videopamˆti

         push      bx
         push      cx
         mov       ax,RozmerB               ; ¨¡©ka linky v bajtech
         mul       dx                       ; v˜po‡et po‡ te‡n¡ho offsetu linky
         mov       di,ax                    ; po‡ te‡n¡ adresa linky
         mov       cl,bl                    ; pozice bodu - ni‘¨¡ slovo
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; p©epo‡et na offset v bajtech
         add       di,bx                    ; po‡ te‡n¡ adresa k zobrazen¡

; ------ maskovac¡ bit za‡ tku

         mov       dx,03ceh
         and       cl,7                     ; po‡ te‡n¡ bitov  pozice v bajtu
         mov       al,8
         out       dx,al
         inc       dx
         mov       al,80h
         shr       al,cl
         pop       bx
         pop       cx

; ------ rozd¡l sou©adnic X a rozli¨en¡, zda jde shora vlevo nebo vpravo

         sub       bx,cx                    ; rozd¡l sou©adnic X2-X1
         jns       lin1ega0
         jmp       Lin3EGA                  ; jde smˆrem vlevo

; ------ ‡ ra jde shora vpravo


; ------ rozli¨en¡, zda jde strmˆ vpravo

lin1ega0:cmp       bx,si                    ; je vˆt¨¡ p©¡rustek ve smˆru X ?
         jb        Lin2EGA                  ; jde strmˆ vpravo dol–

; ------ ‡ ra jde m¡rnˆ vpravo dol–

         mov       cx,bx                    ; ur‡uj¡c¡ je p©¡rustek X
         inc       cx                       ; po‡et krok– ‡ ry
         shl       si,1                     ; rozd¡l sou©adnic dY*2
         mov       bp,si                    ; £schova dY*2
         sub       bp,bx                    ; dY*2 - dX
         shl       bx,1                     ; dX*2
         sub       si,bx                    ; dY*2 - dX*2
         add       bx,si                    ; dX*2 + dY*2 - dX*2 = dY*2
         mov       ah,al                    ; maska po‡ te‡n¡ho bitu
Lin1EGA1:or        al,ah
         or        bp,bp
         jns       Lin1EGA2
         add       bp,bx
         jmp       short Lin1EGA3
Lin1EGA2:out       dx,al
         xchg      al,es:[di]
         xor       al,al
         add       di,RozmerB
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

; ------ ‡ ra jde strmˆ vpravo dol–

Lin2EGA: mov       cx,si
         inc       cx
         shl       bx,1
         mov       bp,bx
         sub       bp,si
         shl       si,1
         sub       bx,si
         add       si,bx
Lin2EGA1:push      ax
         out       dx,al
         pop       ax
         xchg      ah,es:[di]
         or        bp,bp
         jns       Lin2EGA3
         add       bp,si
         jmp       short Lin2EGA4
Lin2EGA3:ror       al,1
         adc       di,0
;         out       dx,al
         add       bp,bx
Lin2EGA4:add       di,RozmerB
         loop      Lin2EGA1
         jmp       LinEGA9

; ------ ‡ ra jde shora vlevo

Lin3EGA: neg       bx
         cmp       bx,si
         jb        Lin4EGA

; ------ ‡ ra jde m¡rnˆ vlevo

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
         add       di,RozmerB
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

; ------ ‡ ra jde strmˆ vlevo

Lin4EGA: mov       cx,si
         inc       cx
         shl       bx,1
         mov       bp,bx
         sub       bp,si
         shl       si,1
         sub       bx,si
         add       si,bx
Lin4EGA1:push      ax
         out       dx,al
         pop       ax
         xchg      ah,es:[di]
         or        bp,bp
         jns       Lin4EGA2
         add       bp,si
         jmp       short Lin4EGA3
Lin4EGA2:rol       al,1
         sbb       di,0
;         out       dx,al
         add       bp,bx
Lin4EGA3:add       di,RozmerB
         loop      Lin4EGA1

; ------ konec - n vrat registr–

LinEGA9: pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Line     ENDP

; *****************************************************************************
;
;                            Data
;
; *****************************************************************************

UvTxt    db        'LINES - (c) Miroslav Nemecek 1993',13,10
         db        ' GEMA Soft  Roznov pod Radhostem',13,10
         db        '          - FREEWARE -',13,10
         db        '$'

Data     label     byte

BuffUkaz dw        0                        ; ukazatel v z znamn¡c¡ch

JMax     dw        1                        ; po‡et ‡ar se stejnou barvou

X1       dw        320                      ; sou©adnice X bodu 1
X2       dw        20                       ; sou©adnice X bodu 2
Y1       dw        20                       ; sou©adnice Y bodu 1
Y2       dw        200                      ; sou©adnice Y bodu 2

dX1      dw        6                        ; p©¡rustek sou©adnice X bodu 1
dX2      dw        6                        ; p©¡rustek sou©adnice X bodu 2
dY1      dw        6                        ; p©¡rustek sou©adnice Y bodu 1
dY2      dw        6                        ; p©¡rustek sou©adnice Y bodu 2

SegVRAM  dw        0a000h                   ; segment videopamˆti

RandNum  dd        ?                        ; n hodn‚ ‡¡slo

Color    db        ?                        ; aktivn¡ barva ‡ ry

OldVMod  db        ?                        ; p–vodn¡ videom¢d

BufX1    dw        MaxLine dup (?)          ; z znamn¡k sou©adnic X bodu 1
BufX2    dw        MaxLine dup (?)          ; z znamn¡k sou©adnic X bodu 2
BufY1    dw        MaxLine dup (?)          ; z znamn¡k sou©adnic Y bodu 1
BufY2    dw        MaxLine dup (?)          ; z znamn¡k sou©adnic Y bodu 2

Code     ENDS

         END       Start

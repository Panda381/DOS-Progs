
Code     SEGMENT
         ASSUME    cs:Code,ds:Code

; ------ konstanty

IncSour  EQU       2                        ; p©¡rustek sou©adnic interval
IncSour0 EQU       1                        ; p©¡rustek sou©adnic minim lnˆ
MaxLine  EQU       100                      ; po‡et zobrazen˜ch ‡ar demonstrace
RozmerB  EQU       320                      ; ¨¡©ka linky v bajtech
DimX     EQU       320                      ; rozmˆr X
DimY     EQU       200                      ; rozmˆr Y
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
         mov       ax,19
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

Start4:  ;dec       word ptr ss:[bp+XJMax]   ; ‡¡ta‡ stejn‚ barvy
         ;jnz       Shows1                   ; nen¡ zmˆna barvy

; ------ nov  barva

Shows02: mov       bl,NColor
         ;call      Random0
;         test      al,7
;         jz        Shows02                  ; z kaz ‡ern‚ a ¨ed‚ barvy
;         add       al,16
         mov       al,ds:[Color]
         mov       ss:[bp+XColor],al        ; barva
         inc       byte ptr ds:[Color]
         jnz       Sh22
         inc       byte ptr ds:[Color]
Sh22:

Sh221:   call      Random0
         and       al,4
         jz        Sh221
         sub       al,2
         add       ds:[Paleta],al
         cmp       byte ptr ds:[Paleta],20
         jae       Sh222
         mov       byte ptr ds:[Paleta],20

Sh222:   call      Random0
         and       al,4
         jz        Sh222
         sub       al,2
         add       ds:[Paleta+1],al
         cmp       byte ptr ds:[Paleta+1],20
         jae       Sh223
         mov       byte ptr ds:[Paleta+1],20

Sh223:   call      Random0
         and       al,4
         jz        Sh223
         sub       al,2
         add       ds:[Paleta+2],al
         cmp       byte ptr ds:[Paleta+2],20
         jae       Sh224
         mov       byte ptr ds:[Paleta+2],20
Sh224:

; ------ vymaz n¡ star˜ch ‡ar

Shows1:  mov       al,0
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

         mov       al,ss:[bp+XColor]        ; barva
         call      DispLine

; ------ zv˜¨en¡ ukazatele v bufferu sou©adnic

         inc       di
         inc       di
         cmp       di,MaxLine*2
         jb        Shows6
         xor       di,di
Shows6:  mov       ss:[bp+XBuffUk],di       ; nov˜ ukazatel v bufferu

         mov       dx,3dah
         xor       cx,cx
St1:     in        al,dx
         test      al,8
         loopnz    St1
         jcxz      St3
St2:     in        al,dx
         test      al,8
         loopz     St2

St3:

; ------ test p©eru¨en¡ programu

         mov       ah,1
         int       16h                      ; test stavu kl vesnice
         jnz       Start6                   ; konec programu
         jmp       Start4                   ; nen¡ ‘ dn  kl vesa

; ------ konec programu

Start6:  mov       ah,0
         int       16h                      ; zru¨en¡ kl vesy z bufferu

         mov       al,ds:[OldVMod]          ; p–vodn¡ videom¢d
         mov       ah,0
         int       10h                      ; n vrat p–vodn¡ho videom¢du

         mov       dx,offset UvTxt
         mov       ah,9
         int       21h

         int       20h

; -----------------------------------------------------------------------------
;        zobrazen¡ ‡ar v bufferu - barva AL
; -----------------------------------------------------------------------------

DispLine PROC      NEAR

         mov       di,ss:[bp+XBuffUk]       ; ukazatel v bufferu
         mov       bx,ds:[di+BufX1]         ; po‡ te‡n¡ pozice
         mov       dx,ds:[di+BufY1]         ; po‡ te‡n¡ linka
         mov       cx,ds:[di+BufX2]         ; koncov  pozice
         mov       si,ds:[di+BufY2]         ; koncov  linka

         push      ax
         push      si
         push      cx
         push      dx
         push      bx
         call      Line                     ; vymaz n¡ prvn¡ ‡ ry
         add       sp,5*2

         sub       dx,DimY-1
         neg       dx
         sub       si,DimY-1
         neg       si
         push      ax
         push      si
         push      cx
         push      dx
         push      bx
         call      Line                     ; vymaz n¡ druh‚ ‡ ry
         add       sp,5*2
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
; VSTUP: SS:[SP+10] (1) barva
;        SS:[SP+8] (2) Y2
;        SS:[SP+6] (2) X2
;        SS:[SP+4] (2) Y1
;        SS:[SP+2] (2) X1
; *****************************************************************************

ARGn     EQU       byte ptr [bp+26]
ARGy2    EQU       word ptr [bp+24]
ARGx2    EQU       word ptr [bp+22]
ARGy1    EQU       word ptr [bp+20]
ARGx1    EQU       word ptr [bp+18]

VARincr1 EQU       word ptr [bp-2]
VARincr2 EQU       word ptr [bp-4]
VARroutn EQU       word ptr [bp-6]
BytLine  EQU       320

; ------ £schova registr–

Line     PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp
         sub       sp,6

; check for vertical line

        mov    si,BytLine    ; initial y-increment

        mov    cx,ARGx2
        sub    cx,ARGx1    ; CX := x2 - x1
        jz    VertLine13    ; jump if vertical line

; force x1 < x2

        jns    L01        ; jump if x2 > x1

        neg    cx        ; CX := x1 - x2

        mov    bx,ARGx2    ; exchange x1 and x2
        xchg    bx,ARGx1
        mov    ARGx2,bx

        mov    bx,ARGy2    ; exchange y1 and y2
        xchg    bx,ARGy1
        mov    ARGy2,bx

; calculate dy = ABS(y2-y1)

L01:        mov    bx,ARGy2
        sub    bx,ARGy1    ; BX := y2 - y1
        jz    HorizLine13    ; jump if horizontal line

        jns    L03        ; jump if slope is positive

        neg    bx        ; BX := y1 - y2
        neg    si        ; negate y-increment

; select appropriate routine for slope of line

L03:        push    si        ; preserve y-increment

        mov    VARroutn,offset LoSlopeLine13
        cmp    bx,cx
        jle    L04        ; jump if dy <= dx (slope <= 1)
        mov    VARroutn,offset HiSlopeLine13
        xchg    bx,cx        ; exchange dy and dx

; calculate initial decision variable and increments

L04:        shl    bx,1        ; BX := 2 * dy
        mov    VARincr1,bx    ; incr1 := 2 * dy
        sub    bx,cx
        mov    si,bx        ; SI := d = 2 * dy - dx
        sub    bx,cx
        mov    VARincr2,bx    ; incr2 := 2 * (dy - dx)

; calculate first pixel address

        push    cx        ; preserve this register
        mov    ax,ARGy1    ; AX := y
        mov    bx,ARGx1    ; BX := x
                call    PixelAddr13     ; ES:BX -> buffer

        mov    di,bx        ; ES:DI -> buffer

        pop    cx        ; restore this register
        inc    cx        ; CX := # of pixels to draw

        pop    bx        ; BX := y-increment
        jmp    VARroutn    ; jump to appropriate routine for slope


; routine for vertical lines

VertLine13:    mov    ax,ARGy1    ; AX := y1
        mov    bx,ARGy2    ; BX := y2
        mov    cx,bx
        sub    cx,ax        ; CX := dy
        jge    L31        ; jump if dy >= 0

        neg    cx        ; force dy >= 0
        mov    ax,bx        ; AX := y2

L31:        inc    cx        ; CX := # of pixels to draw
        mov    bx,ARGx1    ; BX := x
        push    cx        ; preserve this register
                call    PixelAddr13     ; ES:BX -> video buffer
                pop     cx

        mov    di,bx        ; ES:DI -> video buffer
        dec    si        ; SI := bytes/line - 1

        mov    al,ARGn        ; AL := pixel value

L32:        stosb            ; set pixel value in buffer
        add    di,si        ; increment to next line
        loop    L32

        jmp    Lexit



; routine for horizontal lines (slope = 0)

HorizLine13:
        push    cx        ; preserve CX
        mov    ax,ARGy1
        mov    bx,ARGx1
                call    PixelAddr13     ; ES:BX -> video buffer
        mov    di,bx        ; ES:DI -> buffer

        pop    cx
        inc    cx        ; CX := number of pixels to draw

        mov    al,ARGn        ; AL := pixel value

        rep    stosb        ; update the video buffer

        jmp    short Lexit


; routine for dy <= dx (slope <= 1)    ; ES:DI -> video buffer
                    ; BX = y-increment
                    ; CX = #pixels to draw
                    ; SI = decision variable
LoSlopeLine13:

        mov    al,ARGn        ; AL := pixel value

L11:        stosb            ; store pixel, increment x

        or    si,si        ; test sign of d
        jns    L12        ; jump if d >= 0

        add    si,VARincr1    ; d := d + incr1
        loop    L11
        jmp    short Lexit

L12:        add    si,VARincr2    ; d := d + incr2
        add    di,bx        ; increment y
        loop    L11
        jmp    short Lexit


; routine for dy > dx (slope > 1)    ; ES:DI -> video buffer
                    ; BX = y-increment
                    ; CX = #pixels to draw
                    ; SI = decision variable
HiSlopeLine13:
        mov    al,ARGn        ; AL := pixel value

L21:        stosb            ; update next pixel, increment x

        add    di,bx        ; increment y

L22:        or    si,si        ; test sign of d
        jns    L23        ; jump if d >= 0

        add    si,VARincr1    ; d := d + incr1
        dec    di        ; decrement x (already incremented
                    ;  by stosb)
        loop    L21
        jmp    short Lexit


L23:        add    si,VARincr2    ; d := d + incr2
        loop    L21


Lexit:
        mov    sp,bp
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

OriginOffset     EQU     0          ; byte offset of (0,0)
VideoBufferSeg     EQU     0A000h

PixelAddr13     PROC     near

          xchg     ah,al          ; AX := 256*y
          add     bx,ax          ; BX := 256*y + x
          shr     ax,1
          shr     ax,1          ; AX := 64*y
          add     bx,ax          ; BX := 320*y + x

          add     bx,OriginOffset     ; BX := byte offset in video buffer

          mov     ax,VideoBufferSeg
          mov     es,ax          ; ES:BX := byte address of pixel
          ret

PixelAddr13     ENDP

; *****************************************************************************
;
;                            Data
;
; *****************************************************************************

UvTxt    db        'LINESVGA - (c) Miroslav Nemecek 1994',13,10
         db        '     GOLEM Roznov pod Radhostem',13,10
         db        '            - FREEWARE -',13,10
         db        '$'

Data     label     byte

BuffUkaz dw        0                        ; ukazatel v z znamn¡c¡ch

JMax     dw        1                        ; po‡et ‡ar se stejnou barvou

X1       dw        160                      ; sou©adnice X bodu 1
X2       dw        10                       ; sou©adnice X bodu 2
Y1       dw        10                       ; sou©adnice Y bodu 1
Y2       dw        100                      ; sou©adnice Y bodu 2

dX1      dw        3                        ; p©¡rustek sou©adnice X bodu 1
dX2      dw        3                        ; p©¡rustek sou©adnice X bodu 2
dY1      dw        3                        ; p©¡rustek sou©adnice Y bodu 1
dY2      dw        3                        ; p©¡rustek sou©adnice Y bodu 2

SegVRAM  dw        0a000h                   ; segment videopamˆti

RandNum  dd        ?                        ; n hodn‚ ‡¡slo

Color    db        1                        ; aktivn¡ barva ‡ ry

OldVMod  db        ?                        ; p–vodn¡ videom¢d

BufX1    dw        MaxLine dup (?)          ; z znamn¡k sou©adnic X bodu 1
BufX2    dw        MaxLine dup (?)          ; z znamn¡k sou©adnic X bodu 2
BufY1    dw        MaxLine dup (?)          ; z znamn¡k sou©adnic Y bodu 1
BufY2    dw        MaxLine dup (?)          ; z znamn¡k sou©adnic Y bodu 2

Paleta   db        8,8,8                    ; paleta aktivn¡ barvy

Code     ENDS

         END       Start

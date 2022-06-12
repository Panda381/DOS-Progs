
; Z sobn¡k na konci COM programu bez nutnosti rezervov n¡ m¡sta polem DW

code     segment
         assume    cs:code, ds:code
.386

VelPalBuf       equ     300h
VelZasob        equ     1024                ; D‚lka z sobn¡ku (v bajtech)
PalBuf1         equ     offset KonPrg
PalBuf2         equ     offset KonPrg+VelPalBuf
NovyKonPrg      equ     offset KonPrg+VelPalBuf+VelPalBuf+VelZasob

         org       100h
start:
; ------------- Z sobn¡k
                ifdef   DoExe
                mov     ax,cs
                mov     ds,ax
                mov     ss,ax
                else
; ------------- Kontrola m¡sta nad programem pro vytvo©en¡ z sobn¡ku
                mov     dx,offset ChPam
                cmp     sp,offset KonPrg+VelZasob
                call    Chyba
                endif

; ------------- Vytvo©en¡ z sobn¡ku nad programem
                mov     sp,NovyKonPrg

; ------------- Inicializace
                cld
                call    UvodInic

;; ------------- Nastaven¡ prozat¡mn¡ palety
;                mov     dx,3C8h
;                xor     ax,ax
;                out     dx,al
;                inc     dx
;NaPal01:        mov     al,ah
;                shr     al,2
;;xor al,al
;                out     dx,al
;                out     dx,al
;                out     dx,al
;                inc     ah
;                jnz     NaPal01

; ------------- Nastaven¡ palety
                call    RotujPaletu

; ------------- Prvn¡ obr zek

; ------------- P©¡prava kreslen¡
                mov     es,GeoBuf2Seg
                call    Priprav02
                mov     bx,offset Algor02
                xor     di,di

                mov     dx,-100
Kresli01:       mov     cx,-160
Kresli02:       push    bx
                push    cx
                push    dx
                push    di

                mov     _Xi,cx
                mov     _Yi,dx
                call    bx
                mov     al,byte ptr _Barvai
                or      al,al
                jnz     Kresli10
                inc     al
Kresli10:
                pop     di
                pop     dx
                pop     cx
                pop     bx

                stosb

                inc     cx
                cmp     cx,160
                jl      Kresli02

                inc     dx
                cmp     dx,100
                jl      Kresli01

; ------------- Jeden buffer ‡ern˜
                mov     es,GeoBuf1Seg
                xor     di,di
                mov     cx,32000
                xor     ax,ax
                rep     stosw

                call    InitProlinani
                call    InitGenerGeo

; ------------- Hlavn¡ smy‡ka
CekKl01:        call    TaskMan
                call    KrokPalety
                call    KrokGenerGeo
                call    KrokProlinani

                in      al,60h
                test    al,80h
                jnz      CekKl01

; ------------- Vyjmut¡ kl vesy z bufferu
                mov     ah,1
                int     16h
                jz      CekKl02
                mov     ah,0
                int     16h

CekKl02:        call    PripravKonec
                mov     ax,4C00h
                int     21h


; ------------------------------------------------------------------------------
; Koordinace £loh bˆ‘¡c¡ch na pozad¡
; ------------------------------------------------------------------------------
; Vstup:        DS = CS
; ------------------------------------------------------------------------------
TaskMan         proc    near

; ------------- €ek n¡ na dokon‡en¡ zobrazov n¡, v˜po‡tu a prodlevy
;               Prodleva se spou¨t¡ po dokon‡en¡ zobrazen¡
                test    Status,00000111b
                jnz     TaskMan99

                push    ax

; ------------- Ozna‡en¡ pr vˆ zobrazen‚ho bufferu
                mov     al,ZobrazenyBuf
                inc     al
                cmp     al,3
                jb      TaMan48
                xor     al,al
TaMan48:        mov     ZobrazenyBuf,al

; ------------- Start zobrazen¡ a nov‚ho v˜po‡tu
                call    InitProlinani
                call    InitGenerGeo

                pop     ax

TaskMan99:      ret

TaskMan         endp



; ******************************************************************************
;
;               Generov n¡ geometrick˜ch obrazc–                           [***]
;
; ******************************************************************************

;
; Pro pozad¡ jsou vyhrazeny 3 buffery velk‚ 64000 bajt–: GeoBuf1Seg-GeoBuf3Seg.
; V jednom bufferu je vygenerov n pr vˆ zobrazen˜ obrazec, kter˜ pomalu
; pohas¡n , v druh‚m bufferu obrazec, kter˜ sa pr vˆ rozsvˆc¡ a do t©et¡ho
; bufferu je generov n nov˜ obrazec. P©i tom v¨em se st le mˆn¡ paleta.
;
; Sou‡asn˜ bˆh je zaji¨Ÿˆn opakovan˜m vol n¡m procedur KrokPalety, KrokProlinani
; a KrokGenerGeo.
;
; Paleta rotuje nez visle na v¨ech ostatn¡ch ‡innostech.
; KrokProlinani po dokon‡en¡ prol¡n n¡ aktualizuje ukazatel zobrazen‚ho bufferu
; a ‡ek  na po‘adavek o zobrazen¡ nov‚ho obrazce. KrokGenerGeo po dokon‡en¡
; generov n¡ ‡ek  na dokon‡en¡ zobrazov n¡ a nastav¡ po‘adavek o zobrazen¡,
; na‡e‘ za‡ne znovu generovat. KrokProlinani obdr‘¡ po‘adavek o nov‚ zobrazen¡,
; zru¨¡ p©¡znak dokon‡en‚ho zobrazov n¡ a za‡ne zobrazovat
;
KrokGenerGeo    proc    near

; ------------- Kontrola dokon‡e¡ generov n¡
                test    Status,00000001b    ; Neprob¡h  generov n¡?
                jz      KroGen89
                call    KousekObrazce
KroGen89:       ret

KrokGenerGeo    endp


; ------------------------------------------------------------------------------
; Inicializace generov n¡ obrazce
; ------------------------------------------------------------------------------
; Vstup:        DS = CS
; ------------------------------------------------------------------------------
InitGenerGeo    proc    near

                push    ax
                push    bx
                push    cx
                push    dx

; ------------- P©¡prava index–
                mov     _Xi,-160
                mov     _Yi,-100
                xor     ax,ax
                mov     CilAdr[0],ax

; ------------- P©¡prava c¡lov‚ho segmentu
                xchg    bx,ax
                mov     bl,ZobrazenyBuf
                sub     bl,1
                jnc     IniGeGe11
                mov     bl,2
IniGeGe11:      shl     bx,1
                mov     ax,GeoBuf1Seg[bx]
                mov     cilAdr[2],ax

; ------------- P©¡prava pole varianty
IniGeGe12:      call    Random              ; 2 bity = smˆr ot ‡en¡ a posunu
                shrd    bx,ax,2
                call    RandomX             ; 4 bity = po‡et ramen
                shrd    bx,ax,4
                call    RandomX             ; 5 bit– = modulace atp.
                shrd    bx,ax,5
                call    RandomX             ; 5 bit– = stoup n¡ atp.
                shrd    bx,ax,5

                cmp     bx,2
                jb      IniGeGe12           ; Tady by to TEORETICKY mohlo
                                            ; i vytuhnout(?).
                mov     word ptr Varianta[0],bx
                call    RandomX
                mov     word ptr Varianta[2],ax  ; 16 bit– = r–zn‚

; ------------- Volba algoritmu
                mov     bx,PocetGeoRutin
                call    Random
                xor     dx,dx
                div     bx
                mov     bx,dx               ; BX<- €¡slo rutiny
                shl     bx,2                ; Index do tabulky 2*Word

; ------------- Inicializace konstant gener toru
                push    bx
                call    TabGeoRutin[bx+0]   ; PripravXX
                pop     bx

                mov     ax,TabGeoRutin[bx+2]
                mov     GeoRutina,ax        ; Adresa AlgorXX

; ------------- Nastaven¡ p©¡znak–
                or      Status,00000001b    ; Generov n¡ prob¡h 

                pop     dx
                pop     cx
                pop     bx
                pop     ax
                ret

InitGenerGeo    endp


; ------------------------------------------------------------------------------
; Vygenerov n¡ kous¡‡ku obrazce
; ------------------------------------------------------------------------------
; Vstup:        DS = CS
; Ni‡¡:         ES
; ------------------------------------------------------------------------------
KousekObrazce   proc    near

                push    ax
                push    bx
                push    cx
                push    dx
                push    di

; ------------- P©¡prava registr–
                les     di,dword ptr CilAdr

; ------------- V˜po‡et barvy pixelu
                call    word ptr [GeoRutina]
                mov     al,byte ptr _Barvai

;; ------------- Korekce ‡ern‚ barvy, ulo‘en¡ pixelu
;                or      al,al
;                jnz     KouO10
;                inc     al
; Odstranˆno - korekce se prov d¡ a‘ po vymaskov n¡ p©i prol¡n n¡
KouO10:         stosb

; ------------- Aktualizace index–
                mov     CilAdr[0],di
                cmp     di,64000            ; Konec kreslen¡?
                jb      KouO11

                and     Status,11111110b    ; P©¡znak dogenerov n¡ obr zku
                jmp     short KouO90

KouO11:         mov     ax,_Xi
                inc     ax
                cmp     ax,160
                jl      KouO12

                inc     _Yi
                mov     ax,-160

KouO12:         mov     _Xi,ax

KouO90:         pop     di
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                ret

KousekObrazce   endp


; ------------------------------------------------------------------------------
; V˜po‡et £hlu (0..255) ze sou©adnic - p©epo‡et na pol rn¡ sou©adnice
; ------------------------------------------------------------------------------
; Vstup:        ST = X,Y
; V˜stup:       ST(0) = —hel(0..255), POP Y
; ------------------------------------------------------------------------------
Uhel            proc    near

                fpatan
                fsub    Uhel_Cor2
                fmul    Uhel_Cor1
;                fwait
                ret

Uhel_Cor1        dq      4.07436654315252E1  ; 128/PI
Uhel_Cor2       dq      3.145               ; Posun - od oka nastaven na 320x200
Uhel            endp

; ------------------------------------------------------------------------------
; Algoritmus obrazce - spir la
; ------------------------------------------------------------------------------
; Varianta:     0000SSS-SSSRRRRDD ÄÄ> Smˆr posunu dovnit©/ven
;                   ³     ³³  ³ÀÄÄÄÄ> Smˆr ot ‡en¡ doleva/doprava
;                   ÀÄÄÄÄÄ´ÀÄÄÁÄÄÄÄÄ> Po‡et ramen
;                         ÀÄÄÄÄÄÄÄÄÄ> Stoup n¡
; Rozsah:       2-2047
; ------------------------------------------------------------------------------
Priprav00       proc    near

                mov     ax,word ptr Varianta[0]
                shr     ax,2
                mov     bx,ax
                and     ax,15
                mov     Var_Bi,ax           ; Po‡et ramen
                shr     bx,4
                and     bx,63
                mov     Var_Ai,bx           ; Stoup n¡
                ret

Priprav00       endp
Algor00         proc    near

; [+|-](Stoup n¡*sqrt(x*x+y*y)[+|-]Po‡et ramen*Uhel(x,y))

; ------------- Stoup n¡*sqrt(X*X+Y*Y)
                fild    _Xi
                fimul   _Xi
                fild    _Yi
                fimul   _Yi
                faddp                       ; X*X+Y*Y
                fsqrt                       ; sqrt(X*X+Y*Y)
                fimul   Var_Ai

; ------------- Po‡et ramen*Uhel(X,Y)
                fild    _Xi
                fild    _Yi
                call    Uhel
                fimul   Var_Bi

; ------------- Volba sou‡et/rozd¡l
                test    Varianta[0],00000010b
                jz      A0001
                fchs
A0001:          faddp

; ------------- Ulo‘en¡ v˜sledku
                fistp   _Barvai
                fwait

; ------------- Volba smˆru
                test    Varianta[0],00000001b
                jz      A0099
                neg     byte ptr _Barvai
A0099:          ret
Algor00         endp


; ------------------------------------------------------------------------------
; Algoritmus obrazce - pok©iven  spir la
; ------------------------------------------------------------------------------
; Varianta:     ZZZZZSSS-SSRRRRDD ÄÄ> Smˆr posunu dovnit©/ven
;               ÀÄÄÄ´³    ³³  ³ÀÄÄÄÄ> Smˆr ot ‡en¡ doleva/doprava
;                   ³ÀÄÄÄÄ´ÀÄÄÁÄÄÄÄÄ> Po‡et ramen
;                   ³     ÀÄÄÄÄÄÄÄÄÄ> Stoup n¡
;                   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ> Znam‚nka ‡len–
; Rozsah:       2-65535
; ------------------------------------------------------------------------------
Priprav01       proc    near

                mov     ax,word ptr Varianta[0]
                shr     ax,2
                mov     bx,ax
                and     ax,15
                mov     Var_Bi,ax
                shr     bx,4
                and     bx,31
                mov     Var_Ai,bx
                ret

Priprav01       endp
Algor01         proc    near

; [+|-](Stoup n¡*sqrt(sqr([+|-]x*x[+|-]x*y[+|-]y*y)+
; sqr([+|-]x*x[+|-]x*y[+|-]y*y))/10 [+|-]Po‡et ramen*Uhel(x,y))

; ------------- sqr([+|-]X*X[+|-]X*Y[+|-]Y*Y)
                fild    _Xi
                fimul   _Xi
                fild    _Xi
                fimul   _Yi
                test    Varianta[1],10000000b
                jz      A0102
                fchs
A0102:          faddp
                fild    _Yi
                fimul   _Yi
                test    Varianta[1],01000000b
                jz      A0103
                fchs
A0103:          faddp
                fst     A01_Ad
                fmul    A01_Ad

; ------------- sqr([+|-]X*X[+|-]X*Y[+|-]Y*Y)
                fild    _Xi
                fimul   _Xi
                test    Varianta[1],00100000b
                jz      A0111
                fchs
A0111:          fild    _Xi
                fimul   _Yi
                test    Varianta[1],00010000b
                jnz     A0112               ; Toto znam‚nko invertovat
                fchs
A0112:          faddp
                fild    _Yi
                fimul   _Yi
                test    Varianta[1],00001000b
                jz      A0113
                fchs
A0113:          faddp
                fst     A01_Ad
                fmul    A01_Ad

; ------------- Stoup n¡*sqrt(Sou‡et)
                faddp
                fsqrt
                fidiv   A01_Ai
                fimul   Var_Ai

; ------------- Po‡et ramen*Uhel(X,Y)
                fild    _Xi
                fild    _Yi
                call    Uhel
                fimul   Var_Bi

; ------------- Volba sou‡et/rozd¡l
                test    Varianta[0],00000010b
                jz      A0120
                fchs
A0120:          faddp

; ------------- Ulo‘en¡ v˜sledku
                fistp   _Barvai
                fwait

; ------------- Volba smˆru
                test    Varianta[0],00000001b
                jz      A0199
                neg     byte ptr _Barvai
A0199:          ret

A01_Ad          dq      0
A01_Ai          dw      80
Algor01         endp


; ------------------------------------------------------------------------------
; Algoritmus obrazce - zvlnˆn˜ cylinder
; ------------------------------------------------------------------------------
; Varianta:     PPPPPMM-MMMRRRRDD ÄÄ> Smˆr posunu dovnit©/ven
;               ÀÄÄÄ´³    ³³  ³ÀÄÄÄÄ> Smˆr ot ‡en¡ doleva/doprava
;                   ³ÀÄÄÄÄ´ÀÄÄÁÄÄÄÄÄ> Po‡et ramen
;                   ³     ÀÄÄÄÄÄÄÄÄÄ> Modulace/2
;                   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ> Perioda-1
; Rozsah:       2-65535
; ------------------------------------------------------------------------------
Priprav02       proc    near

                mov     ax,word ptr Varianta[0]
                shr     ax,2
                mov     bx,ax
                and     ax,15
                mov     Var_Bi,ax
                shr     bx,4
                mov     ax,bx
                and     bx,31
                shl     bx,1
                mov     Var_Ai,bx
                shr     ax,5
                inc     ax
                mov     Var_Ci,ax
                ret

Priprav02       endp
Algor02         proc    near

; [+|-](Stoup n¡*sin(sqrt(x*x+y*y)/Perioda)[+|-]Po‡et ramen*Uhel(x,y))

; ------------- Soup n¡*sin(sqrt(X*X+Y*Y)/Perioda)
                fild    _Xi
                fimul   _Xi
                fild    _Yi
                fimul   _Yi
                faddp
                fsqrt
                fidiv   Var_Ci
                fsin
                fimul   Var_Ai

; ------------- Po‡et ramen*Uhel(X,Y)
                fild    _Xi
                fild    _Yi
                call    Uhel
                fimul   Var_Bi

; ------------- Volba sou‡et/rozd¡l
                test    Varianta[0],00000010b
                jz      A0201
                fchs
A0201:          faddp

; ------------- Ulo‘en¡ v˜sledku
                fistp   _Barvai
                fwait

; ------------- Volba smˆru
                test    Varianta[0],00000001b
                jz      A0299
                neg     byte ptr _Barvai
A0299:          ret
Algor02         endp


; ------------------------------------------------------------------------------
; Algoritmus obrazce - zvlnˆn˜ v¡r 1
; ------------------------------------------------------------------------------
; Varianta:     PPPPPMM-MMMRRRRDD ÄÄ> Smˆr posunu dovnit©/ven
;               ÀÄÄÄ´³    ³³  ³ÀÄÄÄÄ> Smˆr ot ‡en¡ doleva/doprava
;                   ³ÀÄÄÄÄ´ÀÄÄÁÄÄÄÄÄ> Po‡et ramen
;                   ³     ÀÄÄÄÄÄÄÄÄÄ> Modulace/4
;                   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ> Perioda-1
; Rozsah:       2-65535
; ------------------------------------------------------------------------------
Priprav03       proc    near

                mov     ax,word ptr Varianta[0]
                shr     ax,2
                mov     bx,ax
                and     ax,15
                mov     Var_Bi,ax
                shr     bx,4
                mov     ax,bx
                and     bx,31
                shl     bx,2
                mov     Var_Ai,bx
                shr     ax,5
                add     ax,72

; ------------- Exponenci ln¡ mˆ©¡tko
                fld     A03_As
                fst     Var_Ad
                fwait
P0301:          fmul    Var_Ad
                fwait
                dec     ax
                jnz     P0301

                fstp    Var_Ad
                fwait
                ret

Priprav03       endp
Algor03         proc    near

; [+|-](Stoup n¡*sin(sqrt(x*x+y*y)/Perioda)[+|-]Po‡et ramen*Uhel(x,y))

; ------------- Soup n¡*sin(sqr(X*X+Y*Y)/Perioda)
                fild    _Xi
                fimul   _Xi
                fild    _Yi
                fimul   _Yi
                faddp
                fst     A03_Ad
                fwait
                fmul    A03_Ad              ; SQR
                fdiv    Var_Ad
                fsin
                fimul   Var_Ai

; ------------- Po‡et ramen*Uhel(X,Y)
                fild    _Xi
                fild    _Yi
                call    Uhel
                fimul   Var_Bi

; ------------- Volba sou‡et/rozd¡l
                test    Varianta[0],00000010b
                jz      A0301
                fchs
A0301:          faddp

; ------------- Ulo‘en¡ v˜sledku
                fistp   _Barvai
                fwait

; ------------- Volba smˆru
                test    Varianta[0],00000001b
                jz      A0399
                neg     byte ptr _Barvai
A0399:          ret
A03_Ad          dq      0
A03_As          dd      1.2
Algor03         endp


;         30:Algor:=255-lo(round( (200000/(20+sqrt(abs(ry)+abs(rx))))+Uhel(x-160,y-100) ));
;
;         40:Algor:=lo(round( ry+10*sin(rx/10) + 10*cos(ry/10) ));
;         41:Algor:=lo(round( ry+ 10*sin(ry/10+rx/20) + 20*cos(ry/20+rx/10) ));
;

; ------------------------------------------------------------------------------
; Algoritmus obrazce - zvlnˆn˜ v¡r 2
; ------------------------------------------------------------------------------
; Varianta:     FFFFFHH-HHHRRRRDD ÄÄ> Smˆr posunu dovnit©/ven
;               ÀÄÄÄ´³    ³³  ³ÀÄÄÄÄ> Smˆr ot ‡en¡ doleva/doprava
;                   ³ÀÄÄÄÄ´ÀÄÄÁÄÄÄÄÄ> Po‡et ramen
;                   ³     ÀÄÄÄÄÄÄÄÄÄ> Hustota
;                   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ> Diference
; Rozsah:       2-65535
; ------------------------------------------------------------------------------
Priprav04       proc    near

                mov     ax,word ptr Varianta[0]
                shr     ax,2
                mov     bx,ax
                and     ax,15
                mov     Var_Bi,ax
                shr     bx,4
                mov     ax,bx

                and     bx,31
                mov     Var_Ai,bx
                fild    Var_Ai
                fmul    A04_Ds
                fadd    A04_Cs
                fstp    Var_Ad

                shr     ax,5
                add     ax,16

; ------------- Exponenci ln¡ mˆ©¡tko
                fld     A04_Es
                fst     Var_Bd
                fwait
P0401:          fmul    Var_Bd
                fwait
                dec     ax
                jnz     P0401

                fstp    Var_Bd
                fwait
                ret

Priprav04       endp
Algor04         proc    near

; sin(sqr(x*x+y*y)/1E8)/(Diference+sin(sqr(x*x+y*y)/1E9)) *Hustota
; [+|-]Po‡et ramen*Uhel(x,y)

; ------------- sin(sqr(X*X+Y*Y)/1E08)
                fild    _Xi
                fimul   _Xi
                fild    _Yi
                fimul   _Yi
                faddp                       ; sqr(X)+sqr(Y)
                fst     A04_Ad
                fwait
                fmul    A04_Ad              ; sqr(sqr(X)+sqr(Y))
                fst     A04_Ad
                fdiv    A04_As
                fsin
                fwait

; ------------- Diference + sin(sqr(X*X+Y*Y)/1E09)
                fld     A04_Ad
                fdiv    A04_Bs
                fadd    Var_Ad

; ------------- Pod¡l * Hustota
                fdivp
                fmul    Var_Bd

; ------------- Po‡et ramen * Uhel(X,Y)
                fild    _Xi
                fild    _Yi
                call    Uhel
                fimul   Var_Bi

; ------------- Volba sou‡et/rozd¡l
                test    Varianta[0],00000010b
                jz      A0401
                fchs
A0401:          faddp

; ------------- Ulo‘en¡ v˜sledku
                fistp   _Barvai
                fwait

; ------------- Volba smˆru
                test    Varianta[0],00000001b
                jz      A0499
                neg     byte ptr _Barvai
A0499:          ret

A04_As          dd      1E08
A04_Bs          dd      1E09
A04_Cs          dd      0.001
A04_Ds          dd      0.01
A04_Es          dd      1.14
A04_Ad          dq      0
Algor04         endp


; ------------------------------------------------------------------------------
; Algoritmus obrazce - spir ln¡ mutace
; ------------------------------------------------------------------------------
; Varianta:     YYYYYXXX-XX0000DD ÄÄ> Smˆr posunu dovnit©/ven
;               ÀÄÄÄ´³    ³    ÀÄÄÄÄ> Smˆr ot ‡en¡ doleva/doprava
;                   ³ÀÄÄÄÄ´
;                   ³     ÀÄÄÄÄÄÄÄÄÄ> Po‡et X
;                   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ> Po‡et Y
;               00000000-00SSSSSS ÄÄ> Stoup n¡
; Rozsah:       2-65535*64
; ------------------------------------------------------------------------------
Priprav05       proc    near

                mov     ax,word ptr Varianta[0]
                shr     ax,6
                mov     bx,ax
                and     ax,31
                inc     ax
                mov     Var_Ai,ax           ; Po‡et X
                shr     bx,5
                and     bx,31
                inc     bx
                mov     Var_Bi,bx           ; Po‡et Y
                mov     ax,word ptr Varianta[2]
                and     ax,63
                mov     Var_Ci,ax           ; Stoup n¡
                ret

Priprav05       endp
Algor05         proc    near

; [+|-](Stoup n¡*sqrt(x*x+y*y)[+|-]—hel(sin(x/160*Po‡et X*pi),
; sin(y/100*Po‡et Y*pi)))

; ------------- Stoup n¡*sqrt(X*X+Y*Y)
                fild    _Xi
                fimul   _Xi
                fild    _Yi
                fimul   _Yi
                faddp                       ; X*X+Y*Y
                fsqrt                       ; sqrt(X*X+Y*Y)
                fimul   Var_Ci

; ------------- sin(x/160*pi*Po‡et X)
                fild    _Xi
                fidiv   _MaxXi
                fldpi
                fmulp
                fimul   Var_Ai
                fsin

; ------------- sin(y/100*pi*Po‡et Y)
                fild    _Yi
                fidiv   _MaxYi
                fldpi
                fmulp
                fimul   Var_Bi
                fsin

; ------------- —hel
                call    Uhel

; ------------- Volba sou‡et/rozd¡l
                test    Varianta[0],00000010b
                jz      A0501
                fchs
A0501:          faddp

; ------------- Ulo‘en¡ v˜sledku
                fistp   _Barvai
                fwait

; ------------- Volba smˆru
                test    Varianta[0],00000001b
                jz      A0599
                neg     byte ptr _Barvai
A0599:          ret

Algor05         endp



; ******************************************************************************
;
;               Zobrazov n¡ obrazce                                        [***]
;
; ******************************************************************************


; ------------------------------------------------------------------------------
; Prol¡n n¡ nezobrazen‚ho a zobrazen‚ho obr zku na pozad¡
; ------------------------------------------------------------------------------
; Vstup:        DS = CS
; ------------------------------------------------------------------------------
KrokProlinani   proc    near

; ------------- Kousek prol¡n n¡
                test    Status,00000010b    ; Neprob¡h  prol¡n n¡?
                jz      KrokPro89
                call    KousekProlinani
KrokPro89:      ret

KrokProlinani   endp


; ------------------------------------------------------------------------------
; Inicializace prol¡n n¡
; ------------------------------------------------------------------------------
InitProlinani   proc    near

; ------------- Inicializace segment–, p©¡prava nov‚ho prol¡n n¡
                push    ax
                push    bx

; ------------- Nulov n¡ f z¡
                mov     ax,DelkaProlinani
                mov     FazeProlinani1,ax
                xor     ax,ax
                mov     FazeProlinani2,ax
                mov     ZdrojProlinani1[0],ax

; ------------- P©¡prava segment–
                xchg    bx,ax               ; BX<- 0
                mov     bl,ZobrazenyBuf
                shl     bx,1
                mov     ax,GeoBuf1Seg[bx]   ; Segment pr vˆ zobrazen‚ho
                mov     ZdrojProlinani1[2],ax
                inc     bx
                inc     bx
                cmp     bx,6
                jb      InitPro10
                xor     bx,bx
InitPro10:      mov     ax,GeoBuf1Seg[bx]   ; Segment zobraziv¨¡ho se
                mov     ZdrojProlinani2[0],ax

; ------------- P©¡prava n pis– zobrazen˜ch p©es podklad
                mov     ax,ZobrObr1
                mov     ZobrObr2,ax
                dec     DelicZobrObr
                jnz     InitPro80

                mov     DelicZobrObr,DelConstZobrObr
                mov     ax,ObrBuf1Seg
                mov     ZobrObr1,ax
                xchg    ax,ObrBuf2Seg
                mov     ObrBuf1Seg,ax
                mov     ZobrObr2,ax

InitPro80:      or      Status,00000010b    ; P©¡znak prob¡haj¡c¡ho prol¡n n¡
                pop     bx
                pop     ax
                ret

InitProlinani   endp


; ------------------------------------------------------------------------------
; Zobrazen¡ kous¡‡ku obr zku p©i prol¡n n¡
; ------------------------------------------------------------------------------
; Ni‡¡:         ES,FS,GS
; ------------------------------------------------------------------------------
KousekProlinani proc    near

                push    ax
                push    bx
                push    cx
                push    dx
                push    si
                push    di
                push    bp

; ------------- P©¡prava registr–
                lfs     di,dword ptr ZdrojProlinani1
                mov     gs,ZdrojProlinani2
                push    0A000h
                pop     es
                mov     cx,320   ; Zpracovan˜ kousek - mus¡ b˜t zvolen tak, aby
                                 ; byl cel˜ obraz zpracov n jeho cel˜m n sobkem.
                push    ds
                mov     si,ZobrObr1
                mov     bp,ZobrObr2

; ------------- Zpracov n¡ kousku
KoProl10:       mov     al,fs:[di]          ; Barva mizej¡c¡ho
                xor     ah,ah
                mov     ds,bp
                add     al,[di]
                adc     ah,0
                mul     cs:FazeProlinani1   ; AX<- —rove¤ mizej¡c¡ho

                xchg    bx,ax

                mov     al,gs:[di]          ; Barva objevuj¡c¡ho se
                xor     ah,ah
                mov     ds,si
                add     al,[di]
                adc     ah,0
                mul     cs:FazeProlinani2   ; AX<- —rove¤ objevuj¡c¡ho se

                add     ax,bx
                adc     dx,0
                div     cs:DelkaProlinani   ; AX<- V˜sledn  £rove¤

; ------------- Korekce ‡ern‚ barcy, ulo‘en¡ pixelu
                or      al,al
                jnz     KoProl11
                inc     al
KoProl11:       stosb

                loop    KoProl10
                pop     ds

; ------------- Aktualizace index–
                cmp     di,64000            ; Byla zobrazena jedna f ze?
                jb      KoPro49

                xor     di,di               ; Ukazatel znovu na za‡ tek
                inc     FazeProlinani2
                sub     FazeProlinani1,1
                jnc     KoPro49

; ------------- Prol¡n n¡ dokon‡eno
                and     Status,11111101b    ; P©¡znak dokon‡en‚ho prol¡n n¡
                call    InitProdlevu        ; Zah jen¡ prodlevy

KoPro49:        mov     ZdrojProlinani1[0],di

                pop     bp
                pop     di
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                ret

KousekProlinani endp

; ******************************************************************************
;
;               Paleta, prodleva                                           [***]
;
; ******************************************************************************

; ------------------------------------------------------------------------------
; Inicializace prodlevy
; ------------------------------------------------------------------------------
; Vstup:        DS = CS
; ------------------------------------------------------------------------------
InitProdlevu    proc    near

                push    ax

                mov     ax,DelkaProdlevy
                mov     PocitadloProdl,ax
                or      Status,00000100b    ; P©¡znak prob¡haj¡c¡ prodlevy

                pop     ax
                ret

InitProdlevu    endp


; ------------------------------------------------------------------------------
; Rotov n¡ palety na pozad¡. Procedura by mˆla b˜t vol na co nej‡astˆji, aby
; mohla zachytit ka‘d˜ zpˆtn˜ bˆh a zavolat posun palety.
; ------------------------------------------------------------------------------
; Vstup:        DS = CS
; Ni‡¡:         Nic!
; ------------------------------------------------------------------------------
KrokPalety      proc    near

; ------------- Kontrola v˜skytu zpˆtn‚ho bˆhu
                push    ax
                push    dx

                mov     dx,3DAh
                in      al,dx
                test    al,8                ; Je zpˆtn˜ bˆh?
                jnz     KrokPal01

                mov     ZpetnyBeh,0         ; Zru¨en¡ p©¡znaku zpˆtn‚ho bˆhu
                jmp     short KrokPal99

KrokPal01:      cmp     ZpetnyBeh,0         ; Zpˆtn˜ bˆh byl obslou‘en?
                jne     KrokPal99

                mov     ZpetnyBeh,1         ; P©¡znak obslou‘en‚ho zpˆtn‚ho bˆhu

; ------------- Po‡¡tadlo prodlevy
                dec     PocitadloProdl
                jnz     KrokPal10
                inc     PocitadloProdl
                and     Status,11111011b   ; P©¡znak konce prodlevy

; ------------- Posun a nastaven¡ palety
KrokPal10:      test    Status,00001000b    ; Nerotovat paletu?
                jz      KrokPal99
                test    Status,00000010b    ; Prob¡h  prol¡n n¡ (= nerotovat)?
                jnz     KrokPal99
                call    RotujPaletu

KrokPal99:      pop     dx
                pop     ax
                ret

KrokPalety      endp


; ------------------------------------------------------------------------------
; Jeden krok rotov n¡ palety na pozad¡
; ------------------------------------------------------------------------------
; Vstup:        DS = CS
; Ni‡¡:         AX a DX
; ------------------------------------------------------------------------------
RotujPaletu     proc    near

                push    bx
                push    cx

; ------------- P©¡prava nastaven¡ palety
                mov     bx,offset PalTab    ; Tabulka k©ivky palety
                mov     cx,255              ; Po‡et nastavovan˜ch barev
                mov     dx,3C8h
;                xor     al,al
;                out     dx,al               ; Prvn¡ nastavovan  barva = 0
;                inc     dx
;                out     dx,al               ; Barva 0 je ‡ern 
;                out     dx,al
;                out     dx,al
                mov     al,1                ; Prvn¡ nastavovan  barva = 1
                out     dx,al
                inc     dx

; ------------- Nastaven¡ palety
RoPa10:         mov     al,byte ptr StavZacPal[1+2*0] ; Za‡ tek R
                xlat                                  ; Slo‘ka R
                out     dx,al                         ; Nastaven¡ slo‘ky R
                mov     al,byte ptr StavZacPal[1+2*1] ; Za‡ tek G
                xlat                                  ; Slo‘ka G
                out     dx,al                         ; Nastaven¡ slo‘ky G
                mov     al,byte ptr StavZacPal[1+2*2] ; Za‡ tek B
                xlat                                  ; Slo‘ka B
                out     dx,al                         ; Nastaven¡ slo‘ky B

                inc     bx
                loop    RoPa10

; ------------- Aktualizace za‡ tk– slo‘ek
                xor     bx,bx

RoPa40:         mov     ax,word ptr RychSlozPal[bx]
                add     word ptr StavZacPal[bx],ax
                inc     bx
                inc     bx
                cmp     bx,6
                jb      RoPa40

                pop     cx
                pop     bx
                ret

RotujPaletu     endp



; ******************************************************************************
;
;               Syst‚mov‚ z le‘itosti                                      [***]
;
; ******************************************************************************

; ------------------------------------------------------------------------------
; Gener tor 16-bitov‚ho n hodn‚ho ‡¡sla, p©i‡em‘ bit 0 je s 50% pravdˆpodobnost¡
; 1, bit 1 s 25%, bit 2 s 12.5% atd.
; ------------------------------------------------------------------------------
; V˜stup:       AX = n hodn‚ ‡¡slo
; ------------------------------------------------------------------------------
RandomX         proc    near

                push    bx
                push    cx
                push    dx

                xor     bx,bx               ; Mˆ©idlo mˆn¡c¡ se pravdˆpodobnosti
                mov     cx,16               ; Po‡et bit–

RanX01:         stc
                rcl     bx,1

                call    Random
                and     ax,bx               ; Pravdˆpodobnostn¡ m¡ra
                cmp     ax,1
                rcr     dx,1                ; Bit s ravdˆpodobnost¡ do BH

                loop    RanX01

                call    Random
                and     al,1
                or      dl,al

                xchg    ax,dx
                pop     dx
                pop     cx
                pop     bx
                ret

RandomX         endp


; ------------------------------------------------------------------------------
; Gener tor n hodn‚ho ‡¡sla
; ------------------------------------------------------------------------------
; Vstup:        BX = Rozsah >0!
; V˜stup:       AX = n hodn‚ ‡¡slo (0..Rozsah-1)
; ------------------------------------------------------------------------------
RandomN         proc    near

                push    dx

                call    Random
                xor     dx,dx
                div     bx
                xchg    ax,dx

                pop     dx
                ret

RandomN         endp


; ------------------------------------------------------------------------------
; Gener tor n hodn‚ho ‡¡sla rozsahu word
; ------------------------------------------------------------------------------
; V˜stup:       AX = N hodn‚ ‡¡slo
; ------------------------------------------------------------------------------
Random          proc    near

                push    bx
                push    cx
                push    dx

                mov     ax,word ptr cs:RandSeed[0]
                mov     bx,word ptr cs:RandSeed[2]
                mov     cx,ax
                mul     cs:RandCoef
                shl     cx,3
                add     ch,cl
                add     dx,cx
                add     dx,bx
                shl     bx,2
                add     dx,bx
                add     dh,bl
                shl     bx,5
                add     dh,bl
                add     ax,1
                adc     dx,0
                mov     word ptr cs:RandSeed[0],ax
                mov     word ptr cs:RandSeed[2],dx

                pop     dx
                pop     cx
                pop     bx
                ret

                even
RandCoef        dw      8405h
RandSeed        dd      0
Random          endp


; ------------------------------------------------------------------------------
; Inicializace FPU, instalace obsluhy p©eru¨en¡ FPU
; ------------------------------------------------------------------------------
; Vstup:        DS=CS
; Ni‡¡:         AX,BX,DX
; ------------------------------------------------------------------------------
InicFPU         proc    near

                push    es

; ------------- Kontrola p©¡tomnosti FPU
                finit                       ; Inicializace
                fstsw   ax                  ; Status Word do AX
                or      al,al               ; Je-li FPU, je AL=0
                mov     dx,offset ChFPU
                call    ChybaNZ

; ------------- —schova p–vodn¡ho vektoru INT 75h
                mov     ax,3575h
                int     21h
                mov     word ptr OldInt75[0],bx  ; —schova offsetu
                mov     word ptr OldInt75[2],es  ; —schova segmentu

; ------------- Instalace nov‚ho cektoru INT 75h
                mov     ax,2575h
                mov     dx,offset NewInt75
                int     21h

                pop     es
                ret

InicFPU         endp


; ------------------------------------------------------------------------------
; Odinstalace p©eru¨en¡ FPU
; ------------------------------------------------------------------------------
; Vstup:        DS=CS
; Ni‡¡:         AX,DX
; ------------------------------------------------------------------------------
OffFPU          proc    near

                push    ds

; ------------- Kontrola instalace obsluhy
                cmp     word ptr OldInt75[2],0   ; Segment = 0?
                je      OffFPU90                 ; Obsluha nebyla instalov na

; ------------- Obnova p–vodn¡ hodnoty vektoru
                mov     ax,2575h
                lds     dx,OldInt75
                int     21h

OffFPU90:       pop     ds
                mov     word ptr OldInt75[2],0   ; P©¡znak odinstalovan‚ obsluhy
                ret

OffFPU          endp


; ******************************************************************************
; Obsluha p©eru¨en¡ FPU
; ******************************************************************************
NewInt75        proc    far

;                push    ax

                xor     al,al
                out     0F0h,al             ; Uvolnˆn¡ FPU

                mov     al,20h
                out     0A0h,al             ; Uvolnˆn¡ ©adi‡e p©eru¨en¡ #2
                out     020h,al             ; Uvolnˆn¡ ©adi‡e p©eru¨en¡ #1

; ------------- N siln‚ ukon‡en¡ programu
                sti
                mov     dx,offset ChExceptionFPU
                call    Chyba

;                pop     ax
;                iret
NewInt75        endp


; ------------------------------------------------------------------------------
; Zji¨tˆn¡ typu procesoru
; ------------------------------------------------------------------------------
; V˜stup:       BL=0 pro 86, 1 pro 286 a 2 pro 386
; ------------------------------------------------------------------------------
TypProcesoru    proc near

                push   ax
                pushf

                xor     bl,bl               ; BL<-Typ 0
                xor     ax,ax
                push    ax                  ; PUSH 0
                popf                        ; Flag<-0
                pushf
                pop     ax                  ; AX<-Flag
                and     ax,0F000h           ; Nechat pouze nejvy¨¨¡ bity
                cmp     ax,0F000h           ; Jsou v¨echny nastaveny?
                je      TyPro99             ; Pak je to 8086/8088

                inc     bl                  ; BL<-Typ 1
                mov     ax,0F000h
                push    ax                  ; PUSH 0F000h
                popf                        ; Flag<-0F000h
                pushf
                pop     ax                  ; AX<-Flag
                and     ax,0F000h           ; Nechat pouze nejvy¨¨¡ bity
                jz      TyPro99             ; Jsou-li nulov‚, pak je to 80286

                inc     bl                  ; Jinak je to 80386/80386SX/80486
TyPro99:        popf
                pop     ax

                ret
TypProcesoru    endp


; ------------------------------------------------------------------------------
; —vodn¡ inicializace v¨eho pot©ebn‚ho
; ------------------------------------------------------------------------------
; Vstup:        DS = CS
; Ni‡¡:         Cokoliv kromˆ DS a ES
; ------------------------------------------------------------------------------
UvodInic        proc    near

; ------------- Kontrola CPU
                call    TypProcesoru        ; Zji¨tˆn¡ typu procesoru
                cmp     bl,2                ; 386+?
                mov     dx,offset ChCPU
                call    ChybaB

; ------------- Zmen¨en¡ segmentu programu na minimum
                ifdef   DoEXE
                mov     ax,es
                mov     bx,cs
                sub     bx,ax
                shl     bx,4

                add     bx,offset NovyKonPrg
                else
                mov     bx,offset NovyKonPrg
                endif
                mov     ah,4Ah              ; Zmen¨en¡ bloku pamˆti

                shr     bx,4
                inc     bx
                int     21h
                mov     dx,offset ChPrPam   ; Chybov‚ hl ¨en¡
                call    Chyba               ; O¨et©en¡ p©¡padn‚ chyby
                ifdef   DoEXE
                push    cs
                pop     es
                endif

; ------------- Inicializace FPU
                call    InicFPU

; ------------- Alokov n¡ buffer–
                mov     ah,48h
                mov     bx,64000/16
                int     21h
                mov     dx,offset ChPam
                call    Chyba
                mov     GeoBuf1Seg,ax

                mov     ah,48h
                int     21h
                call    Chyba
                mov     GeoBuf2Seg,ax

                mov     ah,48h
                int     21h
                call    Chyba
                mov     GeoBuf3Seg,ax

                mov     ah,48h
                int     21h
                call    Chyba
                mov     ObrBuf1Seg,ax

                mov     ah,48h
                int     21h
                call    Chyba
                mov     ObrBuf2Seg,ax

; ------------- Nata‘en¡ obr zk–
                push    es
                mov     dx,offset ObrJmS1
                mov     es,ObrBuf1Seg
                call    NactiJBM

                mov     dx,offset ObrJmS2
                mov     es,ObrBuf2Seg
                call    NactiJBM
                pop     es

; ------------- N hodizace n hodn‚ho ‡¡sla
                push    es
                push    0
                pop     es
                mov     ax,es:[46Ch+0]      ; €as - lo
                mov     word ptr RandSeed[0],ax
                mov     ax,es:[46Ch+2]      ; €as - hi
                mov     word ptr RandSeed[2],ax
                call    Random
                pop     es

; ------------- Videom¢d 13h
                mov     ax,13h
                int     10h

                ret

UvodInic        endp

; ------------------------------------------------------------------------------
; Nata‘en¡ jednoho obr zku do pamˆti
; ------------------------------------------------------------------------------
; Vstup:        DS = CS
;               DS:DX - Jm‚no souboru
;               ES:0 = Buffer pro obr zek
; Ni‡¡:         Cokoliv kromˆ segment–
; ------------------------------------------------------------------------------
NactiJBM        proc    near

; ------------- Otev©en¡ souboru
                mov     ax,3D00h            ; Open
                int     21h
                mov     dx,offset ChOtevSou
                call    Chyba
                xchg    bx,ax

; ------------- Seek
                mov     ax,4200h
                xor     cx,cx
                mov     dx,6
                int     21h
                mov     dx,offset ChCtSou
                call    Chyba

; ------------- €ten¡ dat
                mov     ah,3Fh
                mov     cx,64000
                xor     dx,dx
                push    ds
                push    es
                pop     ds
                int     21h
                mov     dx,offset ChCtSou
                call    Chyba
                cmp     cx,ax
                call    ChybaNE
                pop     ds

; ------------- Zav©en¡ souboru
                mov     ah,3Eh
                int     21h

                ret

NactiJbm        endp

; ------------------------------------------------------------------------------
; P©¡prava na ukon‡en¡ programu
; Nesm¡ volat Chybu!
; ------------------------------------------------------------------------------
; Vstup:        DS=CS
; Ni‡¡:         Cokoliv kromˆ DS a ES
; ------------------------------------------------------------------------------
PripravKonec    proc    near

; ------------- Textov˜ videom¢d
                mov     ax,3
                int     10h

; ------------- Odinstalace p©eru¨en¡ FPU
                call    OffFPU

                ret

PripravKonec    endp


; ------------------------------------------------------------------------------
; Zobrazen¡ ©etˆzce ukon‡en‚ho znakem '$'
; ------------------------------------------------------------------------------
; Vstup:        DS:DX - žetˆzec zakon‡en˜ znakem '$'
; ------------------------------------------------------------------------------
ZobrASCIID      proc    near

                push    ax

                mov     ah,9
                int     21h

                pop     ax
                ret

ZobrASCIID      endp


; ------------------------------------------------------------------------------
; Zobrazen¡ ©etˆzce ukon‡en‚ho znakem '$'
; ------------------------------------------------------------------------------
; Vstup:        CS:DX - žetˆzec zakon‡en˜ znakem '$'
; ------------------------------------------------------------------------------
ZobrASCIIC      proc    near

                push    ax
                push    ds
                push    cs
                pop     ds

                mov     ah,9
                int     21h

                pop     ds
                pop     ax
                ret

ZobrASCIIC      endp


; ------------------------------------------------------------------------------
; Klasick‚ o¨et©en¡ chyb
; ------------------------------------------------------------------------------
; Vstup:        CS:DX = Hl ¨en¡
; ------------------------------------------------------------------------------
ChybaNE:
ChybaNZ:        jnz     Chyba01
                ret
ChybaE:
ChybaZ:         jz      Chyba01
                ret
ChybaNB:        jnb     Chyba01
                ret
Chyba:          jc      Chyba01
ChybaB:
                retn
Chyba01:        push    cs
                pop     ds
                push    dx
                call    PripravKonec

                mov     dx,offset ChTxt01
                call    ZobrASCIID
                pop     dx
                call    ZobrASCIID
                mov     dx,offset ChTxt99
                call    ZobrASCIID

                mov     ax,4C01h
                int     21h



; ******************************************************************************
;
;               Data                                                       [***]
;
; ******************************************************************************

; ------------- Chybov  hl ¨en¡
ChTxt01         db      10,10,13,'$'
ChTxt99         db      '!'
CRLFTxt         db      10,13,'$'

ChPam           db      'Nedostatek pamˆti$'
ChPrPam         db      'Chyba pr ce s pamˆt¡$'
ChCPU           db      'Program vy‘aduje k ‡innosti procesor 386 nebo vy¨¨¡$'
ChFPU           db      'Program vy‘aduje k ‡innosti matematick˜ koprocesor$'

ChOtevSou       db      'Soubor s obr zkem nenalezen$'
ChCtSou         db      'Chyba ‡ten¡ souboru s obr zkem$'

ChExceptionFPU  db      'Chyba operace matematick‚ho koprocesoru$'

; ------------- Koordinace
Status          db      8     ; P©¡znaky bˆhu jednotliv˜ch rutin
                              ; Bit 0 -> Prob¡h  generov n¡
                              ; Bit 1 -> Prob¡h  zobrazov n¡
                              ; Bit 2 -> Prob¡h  odpo‡et prodlevy
                              ; Bit 3 -> Prob¡h  rotace palety

ZobrazenyBuf    db      0     ; €¡slo pr vˆ zobrazen‚ho bufferu (0..3)

; ------------- Paleta
ZpetnyBeh       db      0                   ; Flip-flop kontrola zpˆtn‚ho bˆhu
RychSlozPal     db     40,1 ; 0,1           ; Rychlost posunu slo‘ek palety
                db     20,1 ; 228,0
                db     10,1 ; 200,0
StavZacPal      db      0,0                 ; Stav posunu slo‘ek palety
                db      0,0
                db      0,0
;[***]
; ------------- Prodleva
DelkaProdlevy   dw      8*70
PocitadloProdl  dw      0

                even
; ------------- Geometrick‚ obrazce
GeoBuf1Seg      dw      0                   ; Segmenty buffer– pro geometrick‚
GeoBuf2Seg      dw      0                   ; obrazce.
GeoBuf3Seg      dw      0

CilAdr          dw      0,0                 ; C¡lov  adresa generovan‚ho obrazce
GeoRutina       dw      0                   ; Rutina generuj¡c¡ obrazec

_Xi             dw      0                   ; X a Y na obrazovce - word integer
_Yi             dw      0
_Barvai         dw      0                   ; V˜sledn  barva
_MaxXi          dw      160                 ; Maxim ln¡ sou©adnice
_MaxYi          dw      100

;[***]
Varianta        label   byte                ; K¢d varianty obrazce
;                       ÚÄÄÄ¿ÚÄÄÄ¿ÚÄÄ¿Ú¿
                dw      0001111111000100b
;                                 ÚÄÄÄÄ¿
                dw      0000000000000001b
Var_Ai          dw      0                   ; Promˆnn‚ z visl‚ na variantˆ
Var_Bi          dw      0
Var_Ci          dw      0
Var_Di          dw      0

Var_Ad          dq      0
Var_Bd          dq      0

; ------------- Tabulka adres geometrick˜ch rutin
PocetGeoRutin   equ     6
TabGeoRutin     dw      offset Priprav00,offset Algor00
                dw      offset Priprav01,offset Algor01
                dw      offset Priprav02,offset Algor02
                dw      offset Priprav03,offset Algor03
                dw      offset Priprav04,offset Algor04
                dw      offset Priprav05,offset Algor05

; ------------- Prol¡n n¡ obr zku
ZdrojProlinani1 dw      0,0                 ; Zdroj a c¡l prol¡nan‚ho obr zku
ZdrojProlinani2 dw      0
DelkaProlinani  dw      32                  ; D‚lka prol¡nac¡ho cyklu - max 256
FazeProlinani1  dw      0                   ; F ze prol¡n n¡ - negovan 
FazeProlinani2  dw      0                   ; F ze prol¡n n¡


; ------------- Nata‘en‚ obr zky
DelConstZobrObr equ     2                   ; Po‡et zmˆn pozad¡ na zmˆnu n pisu
DelicZobrObr    db      1
ZobrObr1        dw      0                   ; Segmenty pr vˆ zobrazen˜ch obr.
ZobrObr2        dw      0
ObrBuf1Seg      dw      0                   ; Segmenty obr zk–
ObrBuf2Seg      dw      0
ObrJmS1         db      'I01.JBM',0         ; Jm‚na soubor– s obr zky
ObrJmS2         db      'I02.JBM',0

; ------------- Ostatn¡
OldInt75        dd      0                   ; P–vodn¡ vektor INT 75h

; ------------- K©ivka pr–bˆhu palety
PalTab          label   byte
                include PALTAB.INC
                include PALTAB.INC

                even
; ------------- Nealokovan‚ buffery na konci programu
KonPrg:
                ifdef   DoExe
                db      VelZasob dup (0)
                endif

code            ends
                end     start

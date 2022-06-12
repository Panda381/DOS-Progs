
target          EQU   'T3'                      ; Target assembler: TASM-3.2


; P©ijat‚ k¢dy:
;         1 = p©¡jem OK, plotter p©ipraven
;         2 = p©¡jem OK, plotter zanepr zdnˆn
;         4 = chyba p©¡jmu
;
; Vyslan‚ k¢dy:
;         1 = po‘adavek hl ¨en¡ o stavu (stav p©¡jmu zpr vy)
;       0Dh = konec zpr vy
;       16h = synchronizace (p©ed za‡ tkem zpr vy)
;       20h = zah jen¡ zpr vy, pr zdn  operace

include  srmacros.inc

; The following equates show data references outside the range of the program.

;------------------------------------------------------------  seg_a   ----

seg_a           segment byte public
                assume cs:seg_a  , ds:seg_a , ss:stack_seg_b

; -----------------------------------------------------------------------------
;        obsluha INT 14h
; -----------------------------------------------------------------------------

int_14h_entry   proc    far

; ------------ test, zda je port COM

                cmp     dl,cs:l_1E83        ; ‡¡slo portu COM
                je      l_001A
                jmp     dword ptr cs:l_2290 ; p–vodn¡ adresa INT 14h

                db      'HIGL ver. 2.14'    ; identifika‡n¡ text


; ------ p©edefinov n¡ ukazatele z sobn¡ku

l_001A:         mov     cs:l_1E84,ss        ; uschovan˜ ukazatel z sobn¡ku DOS
                mov     cs:l_1E86,sp
                push    cs
                pop     ss
                mov     sp,offset l_2290    ; pracovn¡ z sobn¡k

                push    bx
                push    cx
                push    dx
                push    bp
                push    si
                push    di
                push    ds
                push    cs
                pop     ds
                cmp     ah,0
                je      l_0049              ; inicializace
                cmp     ah,1
                je      l_0051              ; vysl n¡ znaku
                cmp     ah,2
                je      l_0070              ; p©¡jem znaku
                cmp     ah,3
                je      l_0091              ; test p©ipravenosti
                jmp     short l_00A4
                db      90h

; ---- inicializace portu

l_0049:         mov     al,0FAh             ; 9600 Bd, 7 bit–, 1 STOP, sud  p.
                call    l_0134              ; Vol n¡ obsluhy INT 14h - inicial.
                jmp     short l_00A4
                db      90h

; ----- vysl n¡ znaku

l_0051:         mov     l_29E0,al           ; znak k vysl n¡ od DOS
                dec     l_1E82              ; 1=p©¡znak ‡ek n¡ na dal¨¡ znak
                cmp     byte ptr l_1E82,0   ; 1=p©¡znak ‡ek n¡ na dal¨¡ znak
                jne     l_00B6              ; ne‡ekalo se na dal¨¡ znak
                mov     si,l_1E8A           ; £schova registru SI
                mov     di,l_1E8C           ; £schova registru DI
                mov     bp,l_1E8E           ; £schova registru BP
                mov     sp,l_1E88           ; £schova registru SP
                retn

int_14h_entry   endp

; ------ p©¡jem znaku

l_0070:         mov     ax,l_291D           ; ‡¡ta‡ bajt– ‡ten˜ch dat ke ‡ten¡
                and     ax,ax               ; jsou nˆjak  data ?
                jz      l_008B              ; nejsou
                dec     ax
                mov     l_291D,ax           ; ‡¡ta‡ bajt– ‡ten˜ch dat ke ‡ten¡
                mov     bx,l_29FD           ; ukazatel ‡ten¡ p©ijat˜ch dat
                mov     al,[bx]             ; znak z bufferu
                mov     ah,0
                inc     bx
                mov     l_29FD,bx           ; ukazatel ‡ten¡ p©ijat˜ch dat
                jmp     short l_00A4
                db      90h

l_008B:         mov     ax,11h              ; p©¡znak - nejsou data
                jmp     short l_00A4
                db      90h

; ----- test stavu portu

l_0091:         mov     ax,l_291D           ; ‡¡ta‡ bajt– ‡ten˜ch dat ke ‡ten¡
                and     ax,ax
                jz      l_009E
                mov     ax,61B0h
                jmp     short l_00A4        ; data p©ipravena
                db      90h
l_009E:
                mov     ax,60B0h
                jmp     short l_00A4        ; data nep©ipravena
                db      90h

; ------ n vrat registr–

l_00A4:         pop     ds
                pop     di
                pop     si
                pop     bp
                pop     dx
                pop     cx
                pop     bx
                mov     ss,cs:l_1E84        ; uschovan˜ ukazatel z sobn¡ku DOS
                mov     sp,cs:l_1E86
                iret

; ------ zah jen¡ zpracov n¡ p©¡kazu z DOS

l_00B6:         mov     sp,offset l_227C
                mov     byte ptr l_1E82,0   ; 1=p©¡znak ‡ek n¡ na dal¨¡ znak
                jmp     l_013A              ; zpracov n¡ znaku z DOS

;==========================================================================
;        ‡ek n¡ na dal¨¡ znak z DOS
;==========================================================================

l_00C1      proc    near
                mov     l_1E8A,si           ; £schova registru SI
                mov     l_1E8C,di           ; £schova registru DI
                mov     l_1E8E,bp           ; £schova registru BP
                mov     l_1E88,sp           ; £schova registru SP
                mov     sp,offset l_2290-14 ; pracovn¡ z sobn¡k
                mov     ah,0
                inc     l_1E82              ; 1=p©¡znak ‡ek n¡ na dal¨¡ znak
                jmp     short l_00A4        ; n vrat z obsluhy

l_00C1      endp

;==========================================================================
;               p©¡jem znaku z COM
;==========================================================================

l_00DC      proc    near

                push    si
                push    di
                push    bp

                xor     dx,dx
                mov     dl,l_1E83           ; ‡¡slo portu COM
                mov     ah,2
                call    l_0134              ; ‡ten¡ znaku
                and     ah,80h
                jz      l_0111              ; nen¡ TIME-OUT

                xor     dx,dx
                mov     dl,l_1E83           ; ‡¡slo portu COM
                mov     ah,2
                call    l_0134              ; Vol n¡ obsluhy INT 14h
                and     ah,80h
                jz      l_0111

                xor     dx,dx
                mov     dl,l_1E83           ; ‡¡slo portu COM
                mov     ah,2
                call    l_0134              ; Vol n¡ obsluhy INT 14h
                and     ah,80h
                jz      l_0111

                xor     ax,ax               ; nen¡ znak
l_0111:
                mov     l_2928,al           ; znak p©ijat˜ z COM
                pop     bp
                pop     di
                pop     si
                retn

l_00DC      endp

;==========================================================================
;               vysl n¡ znaku na COM
;==========================================================================

l_0118      proc    near

                push    si
                push    di
                push    bp
                xor     dx,dx
                mov     dl,l_1E83           ; ‡¡slo portu COM
                mov     ah,1
                mov     al,l_28F8           ; znak k vysl n¡ na COM
                call    l_0134              ; Vol n¡ obsluhy INT 14h
                and     ax,8000h            ; ponech  p©¡znak TIME-OUT
                mov     l_28F8,ah           ; znak k vysl n¡ na COM
                pop     bp
                pop     di
                pop     si
                retn
l_0118      endp

; ----------------------------------------------------------------------------
;               vol n¡ obsluhy INT 14h
; ----------------------------------------------------------------------------

l_0134      proc    near
                pushf
                call    dword ptr l_2290    ; p–vodn¡ adresa INT 14h
                retn
l_0134      endp

; ----------------------------------------------------------------------------
;               zpracov n¡ znaku z DOS - skok na obsluhu podle prvn¡ho znaku
; ----------------------------------------------------------------------------

l_013A:         push    si
                push    di
                push    bp

                mov     bp,sp
;*              sub     sp,0Eh
                db       83h,0ECh, 0Eh
                call    l_00DC              ; p©¡jem znaku z COM
                call    l_1C31              ; nulov n¡ parametr– a buffer–

l_0148:         mov     al,l_29E0           ; znak k vysl n¡ od DOS
                mov     ah,0
                sub     ax,"+"              ; minim ln¡ znak
                cmp     ax,"z"-"+"          ; maxim ln¡ znak
                jbe     l_0158              ; znak je OK
                jmp     l_0C2E              ; mimo rozsah
l_0158:
                mov     bx,ax
                shl     bx,1
                jmp     word ptr cs:l_0161[bx] ; skok na obsluhu znaku
;þ
l_0161     dw      offset l_0BFF            ; "+"
l_0163     dw      offset l_0C2E            ; ","
l_0165     dw      offset l_0BFF            ; "-"
l_0167     dw      offset l_0C2E            ; "."
l_0169     dw      offset l_0C2E            ; "/"
l_016B     dw      offset l_0BFF            ; "0"
l_016D     dw      offset l_0BFF            ; "1"
l_016F     dw      offset l_0BFF            ; "2"
l_0171     dw      offset l_0BFF            ; "3"
l_0173     dw      offset l_0BFF            ; "4"
l_0175     dw      offset l_0BFF            ; "5"
l_0177     dw      offset l_0BFF            ; "6"
l_0179     dw      offset l_0BFF            ; "7"
l_017B     dw      offset l_0BFF            ; "8"
l_017D     dw      offset l_0BFF            ; "9"
l_017F     dw      offset l_0C2E            ; ":"
l_0181     dw      offset l_0B3D            ; ";"
l_0183     dw      offset l_0C2E            ; "<"
l_0185     dw      offset l_0C2E            ; "="
l_0187     dw      offset l_0C2E            ; ">"
l_0189     dw      offset l_0C2E            ; "?"
l_018B     dw      offset l_0B43            ; "@"
l_018D     dw      offset l_0201            ; "A"
l_018F     dw      offset l_0C2E            ; "B"
l_0191     dw      offset l_0209            ; "C"
l_0193     dw      offset l_02C9            ; "D"
l_0195     dw      offset l_02DF            ; "E"
l_0197     dw      offset l_0570            ; "F"
l_0199     dw      offset l_0C2E            ; "G"
l_019B     dw      offset l_068B            ; "H"
l_019D     dw      offset l_0691            ; "I"
l_019F     dw      offset l_0C2E            ; "J"
l_01A1     dw      offset l_0C2E            ; "K"
l_01A3     dw      offset l_06A9            ; "L"
l_01A5     dw      offset l_06B3            ; "M"
l_01A7     dw      offset l_0C2E            ; "N"
l_01A9     dw      offset l_07DF            ; "O"
l_01AB     dw      offset l_0823            ; "P"
l_01AD     dw      offset l_0866            ; "Q"
l_01AF     dw      offset l_0875            ; "R"
l_01B1     dw      offset l_087D            ; "S"
l_01B3     dw      offset l_0A04            ; "T"
l_01B5     dw      offset l_0A07            ; "U"
l_01B7     dw      offset l_0A1D            ; "V"
l_01B9     dw      offset l_0A27            ; "W"
l_01BB     dw      offset l_0C2E            ; "X"
l_01BD     dw      offset l_0C2E            ; "Y"
l_01BF     dw      offset l_0639            ; "Z"
l_01C1     dw      offset l_0C2E            ; "["
l_01C3     dw      offset l_0C2E            ; "\"
l_01C5     dw      offset l_0C2E            ; "]"
l_01C7     dw      offset l_0C2E            ; "^"
l_01C9     dw      offset l_0C2E            ; "_"
l_01CB     dw      offset l_0C2E            ; "`"
l_01CD     dw      offset l_0C2E            ; "a"
l_01CF     dw      offset l_0C2E            ; "b"
l_01D1     dw      offset l_0C2E            ; "c"
l_01D3     dw      offset l_0C2E            ; "d"
l_01D5     dw      offset l_0C2E            ; "e"
l_01D7     dw      offset l_0C2E            ; "f"
l_01D9     dw      offset l_0C2E            ; "g"
l_01DB     dw      offset l_0C2E            ; "h"
l_01DD     dw      offset l_0C2E            ; "i"
l_01DF     dw      offset l_0C2E            ; "j"
l_01E1     dw      offset l_0C2E            ; "k"
l_01E3     dw      offset l_0C2E            ; "l"
l_01E5     dw      offset l_0C2E            ; "m"
l_01E7     dw      offset l_0C2E            ; "n"
l_01E9     dw      offset l_0C2E            ; "o"
l_01EB     dw      offset l_0B49            ; "p"
l_01ED     dw      offset l_0B5E            ; "q"
l_01EF     dw      offset l_0B73            ; "r"
l_01F1     dw      offset l_0B8A            ; "s"
l_01F3     dw      offset l_0BA4            ; "t"
l_01F5     dw      offset l_0BBA            ; "u"
l_01F7     dw      offset l_0BD0            ; "v"
l_01F9     dw      offset l_0BE6            ; "w"
l_01FB     dw      offset l_0C2E            ; "x"
l_01FD     dw      offset l_0A07            ; "y"
l_01FF     dw      offset l_02C9            ; "z"

; ----------------------------------------------------------------------------
;               "A" absolutn¡ sou©adnice
; ----------------------------------------------------------------------------

l_0201:         mov     byte ptr l_2906,1   ; 1=absolutn¡ sou©adnice
                jmp     l_0C2E

; ----------------------------------------------------------------------------
;               "C" ("CA" oblouk, "CC" kru‘nice, "CE" elipsa, "CG" k©ivka, "CS")
; ----------------------------------------------------------------------------

l_0209:         call    l_00C1              ; ‡ek n¡ na dal¨¡ znak z DOS

                mov     al,l_29E0           ; znak k vysl n¡ od DOS (2. znak)
                mov     ah,0
                mov     cx,5
                mov     bx,offset l_0227

l_0217:         cmp     ax,cs:[bx]
                je      l_0223
                inc     bx
                inc     bx
                loop    l_0217
                jmp     l_02C6

l_0223:         jmp     word ptr cs:[bx+0Ah]    ; 4 entries

l_0227          dw      "A"                 ; "CA"
                dw      "C"                 ; "CC"
                dw      "E"                 ; "CE"
                dw      "G"                 ; "CG"
                dw      "S"                 ; "CS"

           dw      offset l_023B
           dw      offset l_0276
           dw      offset l_02B1
           dw      offset l_02C4
           dw      offset l_02C4

; ------ "CA" oblouk

                                          ;* sou©adnice X
l_023B:  mov       ax,1                     ; 1 znak vypustit
         push      ax
         call      l_1876                   ; na‡ten¡ ‡¡sla - sou©adnice X
         pop       cx
         mov       [bp-0Ah],dx              ; sou©adnice X oblouku
         mov       [bp-0Ch],ax

                                          ;* sou©adnice Y
         mov       ax,1                     ; 1 znak vypustit
         push      ax
         call      l_1876                   ; na‡ten¡ ‡¡sla - sou©adnice Y
         pop       cx
         mov     [bp-6],dx                  ; sou©adnice Y oblouku
         mov     [bp-8],ax

                                          ;* d‚lka oblouku (-360 a‘ +360 stup¤–)
         mov       ax,1                     ; 1 znak vypustit
         push      ax
         call      l_1876                   ; na‡ten¡ ‡¡sla - d‚lka oblouku
         pop       cx

                                          ;* vykreslen¡ oblouku
         mov       si,ax                    ; d‚lka oblouku
         push      si
         push      word ptr ss:[bp-6]       ; sou©adnice Y oblouku
         push      word ptr ss:[bp-8]
         push      word ptr ss:[bp-10]      ; sou©adnice X oblouku
         push      word ptr ss:[bp-12]
         call      l_0C3A                   ; vykreslen¡ oblouku
         add       sp,10
         jmp       short l_02C6

; ------ "CC" kru‘nice

                                          ;* sou©adnice X
l_0276:         mov     ax,1                ; 1 znak vypustit
                push    ax
                call    l_1876              ; na‡ten¡ ‡¡sla - sou©adnice X
                pop     cx
                mov     [bp-0Ah],dx         ; sou©adnice X kru‘nice
                mov     [bp-0Ch],ax

                                          ;* sou©adnice Y
                mov     ax,1                ; 1 znak vypustit
                push    ax
                call    l_1876              ; na‡ten¡ ‡¡sla - sou©adnice Y
                pop     cx
                mov     [bp-6],dx
                mov     [bp-8],ax

                                          ;* polomˆr kru‘nice
                mov     ax,1                ; 1 znak vypustit
                push    ax
                call    l_1876              ; na‡ten¡ ‡¡sla - polomˆr
                pop     cx

                                          ;* vykreslen¡ kru‘nice
                mov     si,ax               ; polomˆr
                push    si
                push    word ptr [bp-6]     ; sou©adnice Y
                push    word ptr [bp-8]
                push    word ptr [bp-0Ah]   ; sou©adnice X
                push    word ptr [bp-0Ch]
                call    l_0E8D              ; vykreslen¡ kru‘nice
;*              add     sp,0Ah
                db       83h,0C4h, 0Ah
                jmp     short l_02C6

; ------- "CE" elipsa

l_02B1:         xor     di,di
                jmp     short l_02BD

l_02B5:         mov     al,','              ; znak oddˆlova‡e
                push    ax
                call    l_191F              ; ‡ek n¡ na oddˆlova‡ mezi ‡¡sly
                pop     cx
                inc     di
l_02BD:         cmp     di,6                ; 6 parametr– se ignoruje
;                db       83h,0FFh, 06h
                jl      l_02B5
                jmp     short l_02C6

; ------- "CG" za‡ tek k©ivky, "CS" konec k©ivky (ignorov no)

l_02C4:         jmp     short l_02C6

; ------ "C"

l_02C6:         jmp     l_0C2E

; -----------------------------------------------------------------------------
;        "D" "z" pero dol–
; -----------------------------------------------------------------------------

l_02C9:         mov     bx,2A0Bh            ; buffer jednoho p©¡kazu
                mov     byte ptr [bx],22h   ; povel pro spu¨tˆn¡ pera
                mov     ax,1
                push    ax
                call    l_1945              ; ulo‘en¡ povelu do bufferu
                pop     cx
                mov     byte ptr l_28F9,0   ; 1=pero je zvednuto
                jmp     l_0C2E

; -----------------------------------------------------------------------------
;        "E" ("EB", "EC", "ED", "EF", "EH", "EL", "EM", "ER", "ET", "EU")
; -----------------------------------------------------------------------------

l_02DF:         call    l_00C1              ; ‡ek n¡ na dal¨¡ znak z DOS
                mov     al,l_29E0           ; znak k vysl n¡ od DOS
                mov     ah,0
                sub     ax,"B"
                cmp     ax,"U"-B"
                jbe     l_02F2
                jmp     l_056D

l_02F2:         mov     bx,ax
                shl     bx,1
                jmp     word ptr cs:l_02FB[bx] ; 20 entries

l_02FB     dw      offset l_0323            ; "EB"
l_02FD     dw      offset l_032D            ; "EC"
l_02FF     dw      offset l_056D            ; "ED"
l_0301     dw      offset l_056D            ; "EE"
l_0303     dw      offset l_0391            ; "EF"
l_0305     dw      offset l_056D            ; "EG"
l_0307     dw      offset l_0399            ; "EH"
l_0309     dw      offset l_056D            ; "EI"
l_030B     dw      offset l_056D            ; "EJ"
l_030D     dw      offset l_056D            ; "EK"
l_030F     dw      offset l_03A1            ; "EL"
l_0311     dw      offset l_056D            ; "EM"
l_0313     dw      offset l_056D            ; "EN"
l_0315     dw      offset l_056D            ; "EO"
l_0317     dw      offset l_056D            ; "EP"
l_0319     dw      offset l_056D            ; "EQ"
l_031B     dw      offset l_03B2            ; "ER"
l_031D     dw      offset l_056D            ; "ES"
l_031F     dw      offset l_051F            ; "ET"
l_0321     dw      offset l_0564            ; "EU"

; ------ "EB" komunika‡n¡ m¢d 2 prompty

l_0323:         mov     al,","              ; oddˆlova‡
                push    ax
                call    l_191F              ; ‡ek n¡ na oddˆlova‡ mezi ‡¡sly
                pop     cx
                jmp     l_056D

; ------ "EC" velikost kroku zapisova‡e

l_032D:         call    l_00C1              ; ‡ek n¡ na dal¨¡ znak z DOS
                mov     al,l_29E0           ; znak k vysl n¡ od DOS
                mov     ah,0
                mov     cx,4
                mov     bx,offset l_034A
l_033B:         cmp     ax,cs:[bx]
                je      l_0346
                inc     bx
                inc     bx
                loop    l_033B
                jmp     short l_0369

l_0346:         jmp     word ptr cs:[bx+8]      ; 3 entries

l_034A   dw        "1"
         dw        "5"
         dw        "M"
         dw        "N"

         dw        offset l_035A            ; "1"
         dw        offset l_035F            ; "5"
         dw        offset l_0364            ; "M"
         dw        offset l_035A            ; "N"

; ------ "EC1" krok 0.001" (0.025 mm)

l_035A:         mov     si,1                ; po‡et mikrokrok–
                jmp     short l_036C

; ------ "EC5" krok 0.005" (0.125 mm)

l_035F:         mov     si,5                ; po‡et mikrokrok–
                jmp     short l_036C

; ------ "ECM" krok 0.1 mm

l_0364:         mov     si,4                ; po‡et mikrokrok–
                jmp     short l_036C

; ------ "ECN" krok 0.025 mm

l_0369:         mov     si,1                ; po‡et mikrokrok–

                                          ;* z pis povelu pro krokov n¡
l_036C:         mov     bx,2A0Bh            ; buffer jednoho p©¡kazu
                mov     byte ptr [bx],29h   ; povel pro n soben¡ krok–
                mov     ax,si
;*              add     al,20h                  ; ' '
                db       80h,0C0h, 20h
                mov     bx,offset l_2A0B+1
                mov     [bx],al
                mov     ax,2
                push    ax
                call    l_1945              ; ulo‘en¡ povelu do bufferu
                pop     cx

                                          ;* vypu¨tˆn¡ parametru
                mov     al,","
                push    ax
                call    l_191F              ; ‡ek n¡ na oddˆlova‡ mezi ‡¡sly
                pop     cx
                call    l_1CC4              ; inicializace parametr–
                jmp     l_056D

; ------ "EF" velk˜ form t

l_0391:         mov     byte ptr l_291F,1   ; 1=velk˜ form t
                jmp     l_056D

; ------ "EH" mal˜ form t

l_0399:         mov     byte ptr l_291F,0   ; 1=velk˜ form t
                jmp     l_056D

; ------ "EL" pauza

l_03A1:         mov     bx,2A0Bh            ; buffer jednoho p©¡kazu
                mov     byte ptr [bx],2Ah   ; povel pro zastaven¡ zapisova‡e
                mov     ax,1
                push    ax
                call    l_1945              ; ulo‘en¡ povelu do bufferu
                pop     cx
                jmp     l_056D

; ------ "ER" vysl n¡ zpr vy o stavu

l_03B2:         mov     l_29FD,2929h        ; ukazatel ‡ten¡ p©ijat˜ch dat
                mov     bx,2929h            ; buffer p©ijat˜ch dat (pro DOS)
                mov     byte ptr [bx],"("   ; £vodn¡ z vorka

                                          ;* ‡¡slo vybran‚ho pera
                mov     al,l_291B           ; ‡¡slo aktivn¡ho pera
                mov     ah,0
                mov     si,ax

                                          ;* p©¡znak spu¨tˆn¡ pera
                cmp     byte ptr l_28F9,0   ; 1=pero je zvednuto
                jne     l_03D0
;*              or      si,10h              ; pero spu¨tˆno
                db       81h,0CEh, 10h, 00h
l_03D0:
                                          ;* p©¡znak mimo okno
                cmp     byte ptr l_28FA,0   ; 1=je v oknˆ
                jne     l_03DB
;*              or      si,20h              ; mimo okno
                db       81h,0CEh, 20h, 00h

                                          ;* mal˜ form t
l_03DB:         cmp     byte ptr l_291F,0   ; 1=velk˜ form t
                jne     l_03E6
;*              or      si,40h              ; mal˜ form t
                db       81h,0CEh, 40h, 00h

                                          ;* dek¢dov n¡ stavov‚ho bajtu
l_03E6:         mov     al,0
                push    ax
                mov     ax,si
                cwd
                push    dx
                push    ax
                mov     ax,3                ; 3 znaky
                push    ax
                mov     ax,1
                push    ax
                call    l_17EC              ; dek¢dov n¡ ‡¡sla na ASCII
;*              add     sp,0Ah
                db       83h,0C4h, 0Ah

                                          ;* dek¢dov n¡ 2.stavov‚ho bajtu
                mov     al,0                ; znak 0
                push    ax
                xor     ax,ax
                push    ax
                push    ax
                mov     ax,3
                push    ax
                mov     ax,5
                push    ax
                call    l_17EC              ; dek¢dov n¡ ‡¡sla na ASCII
;*              add     sp,0Ah
                db       83h,0C4h, 0Ah

                                          ;* sou‡asn  pozice X
                mov     al,1
                push    ax
                push    l_2A05              ; aktu ln¡ pozice X (HIGH)
                push    l_2A03              ; aktu ln¡ pozice X (LOW)
                mov     ax,5                ; 5 znak–
                push    ax
                mov     ax,9
                push    ax
                call    l_17EC              ; dek¢dov n¡ ‡¡sla na ASCII
;*              add     sp,0Ah
                db       83h,0C4h, 0Ah

                                          ;* sou‡asn  pozice Y
                mov     al,1
                push    ax
                push    l_29DE              ; aktu ln¡ pozice Y (HIGH)
                push    l_29DC              ; aktu ln¡ pozice Y (LOW)
                mov     ax,5
                push    ax
                mov     ax,10h
                push    ax
                call    l_17EC              ; dek¢dov n¡ ‡¡sla na ASCII
;*              add     sp,0Ah
                db       83h,0C4h, 0Ah

                                         ;* lev˜ doln¡ roh okna - X
                mov     al,1
                push    ax
                push    l_2A01              ; lev˜ doln¡ roh okna X (HIGH)
                push    l_29FF              ; lev˜ doln¡ roh okna X (LOW)
                mov     ax,5
                push    ax
                mov     ax,17h
                push    ax
                call    l_17EC              ; dek¢dov n¡ ‡¡sla na ASCII
;*              add     sp,0Ah
                db       83h,0C4h, 0Ah

                                          ;* lev˜ doln¡ roh okna - Y
                mov     al,1
                push    ax
                push    l_29FB              ; lev˜ doln¡ roh okna Y (HIGH)
                push    l_29F9              ; lev˜ doln¡ roh okna Y (LOW)
                mov     ax,5
                push    ax
                mov     ax,1Eh
                push    ax
                call    l_17EC              ; dek¢dov n¡ ‡¡sla na ASCII
;*              add     sp,0Ah
                db       83h,0C4h, 0Ah

                                          ;* prav˜ horn¡ roh okna - X
                mov     al,1
                push    ax
                push    l_2902              ; prav˜ horn¡ roh okna X (HIGH)
                push    l_2900              ; prav˜ horn¡ roh okna X (LOW)
                mov     ax,5
                push    ax
                mov     ax,25h
                push    ax
                call    l_17EC              ; dek¢dov n¡ ‡¡sla na ASCII
;*              add     sp,0Ah
                db       83h,0C4h, 0Ah

                                          ;* prav˜ horn¡ roh okna - Y
                mov     al,1
                push    ax
                push    l_28F6              ; prav˜ horn¡ roh okna Y (HIGH)
                push    l_28F4              ; prav˜ horn¡ roh okna Y (LOW)
                mov     ax,5
                push    ax
                mov     ax,2Ch
                push    ax
                call    l_17EC              ; dek¢dov n¡ ‡¡sla na ASCII
;*              add     sp,0Ah
                db       83h,0C4h, 0Ah

                                          ;* lev˜ doln¡ roh okna ZOOM - X
                mov     al,1
                push    ax
                push    l_2919              ; lev˜ doln¡ roh okna X ZOOM (HIGH)
                push    l_2917              ; lev˜ doln¡ roh okna X ZOOM (LOW)
                mov     ax,5
                push    ax
                mov     ax,33h
                push    ax
                call    l_17EC              ; dek¢dov n¡ ‡¡sla na ASCII
;*              add     sp,0Ah
                db       83h,0C4h, 0Ah

                                          ;* lev˜ doln¡ roh okna ZOOM - Y
                mov     al,1
                push    ax
                push    l_29ED              ; lev˜ doln¡ roh okna Y ZOOM (HIGH)
                push    l_29EB              ; lev˜ doln¡ roh okna Y ZOOM (LOW)
                mov     ax,5
                push    ax
                mov     ax,3Ah
                push    ax
                call    l_17EC
;*              add     sp,0Ah
                db       83h,0C4h, 0Ah

                                          ;* prav˜ horn¡ roh okna ZOOM - X
                mov     al,1
                push    ax
                push    l_29E9              ; prav˜ horn¡ roh okna X ZOOM (HIGH)
                push    l_29E7              ; prav˜ horn¡ roh okna X ZOOM (LOW)
                mov     ax,5
                push    ax
                mov     ax,41h
                push    ax
                call    l_17EC              ; dek¢dov n¡ ‡¡sla na ASCII
;*              add     sp,0Ah
                db       83h,0C4h, 0Ah

                                          ;* prav˜ horn¡ roh okna ZOOM - Y
                mov     al,1
                push    ax
                push    l_2911              ; prav˜ horn¡ roh okna Y ZOOM (HIGH)
                push    l_290F              ; prav˜ horn¡ roh okna Y ZOOM (LOW)
                mov     ax,5
                push    ax
                mov     ax,48h
                push    ax
                call    l_17EC              ; dek¢dov n¡ ‡¡sla na ASCII
;*              add     sp,0Ah
                db       83h,0C4h, 0Ah

                                          ;* koncov  z vorka
                mov     bx,2977h
                mov     byte ptr [bx],")"
                mov     bx,2978h
                mov     byte ptr [bx],0Dh   ; ozna‡en¡ konce dat
                mov     l_291D,50h          ; ‡¡ta‡ bajt– ‡ten˜ch dat ke ‡ten¡
                jmp     short l_056D

; ------ "ET" znak konce textu

l_051F:         call    l_00C1              ; ‡ek n¡ na dal¨¡ znak z DOS
                mov     al,l_29E0           ; znak k vysl n¡ od DOS
                mov     [bp-4],al           ; 1. znak
                call    l_00C1              ; ‡ek n¡ na dal¨¡ znak z DOS
                mov     al,l_29E0           ; znak k vysl n¡ od DOS
                mov     [bp-3],al           ; 2. znak

                                          ;* konverze znak– na bin rn¡ tvar
                sub     byte ptr [bp-4],"0" ; korekce na ‡¡slo
                sub     byte ptr [bp-3],"0" ; korekce na ‡¡slo
                cmp     byte ptr [bp-4],9
                jbe     l_0543
                sub     byte ptr [bp-4],7   ; korekce p¡smene HEX
l_0543:         cmp     byte ptr [bp-3],9
                jbe     l_054D
                sub     byte ptr [bp-3],7   ; korekce p¡smene HEX

                                          ;* £schova znaku
l_054D:         mov     al,[bp-4]
                mov     cx,4
                shl     al,cl
                add     al,[bp-3]
                mov     l_2905,al           ; znak ozna‡uj¡c¡ konec ASCII textu
                mov     al,","              ; znak oddˆlova‡e
                push    ax
                call    l_191F              ; ‡ek n¡ na oddˆlova‡ mezi ‡¡sly
                pop     cx
                jmp     short l_056D

; ------ "EU"

l_0564:         mov     al,2Ch                  ; ','
                push    ax
                call    l_191F              ; ‡ek n¡ na oddˆlova‡ mezi ‡¡sly
                pop     cx
                jmp     short l_056D

; ------ neobsluhovan˜ p©¡kaz "E"

l_056D:        jmp     l_0C2E

; -----------------------------------------------------------------------------
;        "F" nastaven¡ posunut‚ho po‡ tku
; -----------------------------------------------------------------------------

                                          ;* na‡ten¡ ‡¡sla
l_0570:         mov     ax,1
                push    ax
                call    l_1876              ; na‡ten¡ ‡¡sla
                pop     cx
                mov     [bp-0Ah],dx         ; zadan‚ ‡¡slo
                mov     [bp-0Ch],ax

                                          ;* nen¡ ‡¡slo 0, je velk˜ form t
                or      ax,dx
                jz      l_05B5              ; je zad no ‡¡slo 0
                cmp     byte ptr l_291F,0   ; 1=velk˜ form t
                je      l_059F              ; nen¡ velk˜ form t
                mov     dx,l_2A05           ; aktu ln¡ pozice X (HIGH)
                mov     ax,l_2A03           ; aktu ln¡ pozice X (LOW)
                sub     ax,[bp-0Ch]         ; nov˜ HOME bude X+n
                sbb     dx,[bp-0Ah]
                mov     l_2A05,dx           ; aktu ln¡ pozice X (HIGH)
                mov     l_2A03,ax           ; aktu ln¡ pozice X (LOW)
                jmp     short l_05B3

                                          ;* nen¡ ‡¡slo 0, je mal˜ form t
l_059F:         mov     dx,l_29DE           ; aktu ln¡ pozice Y (HIGH)
                mov     ax,l_29DC           ; aktu ln¡ pozice Y (LOW)
                sub     ax,[bp-0Ch]         ; nov˜ HOME bude Y+n
                sbb     dx,[bp-0Ah]
                mov     l_29DE,dx           ; aktu ln¡ pozice Y (HIGH)
                mov     l_29DC,ax           ; aktu ln¡ pozice Y (LOW)
l_05B3:         jmp     short l_05D6

                                          ;* je ‡¡slo 0, je velk˜ form t
l_05B5:         cmp     byte ptr l_291F,0   ; 1=velk˜ form t
                je      l_05CA              ; nen¡ velk˜ form t
                mov     l_2A05,0            ; aktu ln¡ pozice X (HIGH)
                mov     l_2A03,0            ; aktu ln¡ pozice X (LOW)
                jmp     short l_05D6

                                          ;* je ‡¡slo 0, je mal˜ form t
l_05CA:         mov     l_29DE,0            ; aktu ln¡ pozice Y (HIGH)
                mov     l_29DC,0            ; aktu ln¡ pozice Y (LOW)

l_05D6:         mov     dx,l_2A09
                mov     ax,l_2A07
                mov     cx,l_2A05           ; aktu ln¡ pozice X (HIGH)
                mov     bx,l_2A03           ; aktu ln¡ pozice X (LOW)
                sub     bx,l_290B           ; skute‡n  pozice zapisova‡e X (LOW)
                sbb     cx,l_290D           ; skute‡n  pozice zapisova‡e X (HIGH)
                sub     ax,bx
                sbb     dx,cx
                mov     l_2A09,dx
                mov     l_2A07,ax

                mov     dx,l_29F7
                mov     ax,l_29F5
                mov     cx,l_29DE           ; aktu ln¡ pozice Y (HIGH)
                mov     bx,l_29DC           ; aktu ln¡ pozice Y (LOW)
                sub     bx,l_2924           ; skute‡n  pozice zapisova‡e Y (LOW)
                sbb     cx,l_2926           ; skute‡n  pozice zapisova‡e Y (HIGH)
                sub     ax,bx
                sbb     dx,cx
                mov     l_29F7,dx
                mov     l_29F5,ax

                mov     dx,l_2A05           ; aktu ln¡ pozice X (HIGH)
                mov     ax,l_2A03           ; aktu ln¡ pozice X (LOW)
                mov     l_290D,dx           ; skute‡n  pozice zapisova‡e X (HIGH)
                mov     l_290B,ax           ; skute‡n  pozice zapisova‡e X (LOW)

                mov     dx,l_29DE           ; aktu ln¡ pozice Y (HIGH)
                mov     ax,l_29DC           ; aktu ln¡ pozice Y (LOW)
                mov     l_2926,dx           ; skute‡n  pozice zapisova‡e Y (HIGH)
                mov     l_2924,ax           ; skute‡n  pozice zapisova‡e Y (LOW)

                jmp     l_0C2E

; -----------------------------------------------------------------------------
;        "Z" reset zapisova‡e
; -----------------------------------------------------------------------------

                                          ;* zvednut¡ pera
l_0639:         mov     bx,2A0Bh            ; buffer jednoho p©¡kazu
                mov     byte ptr [bx],23h   ; povel pro zvednut¡ pera
                mov     ax,1
                push    ax
                call    l_1945              ; ulo‘en¡ povelu do bufferu
                pop     cx

                call    l_1CC4              ; inicializace parametr–

                mov     byte ptr l_2906,1   ; 1=absolutn¡ sou©adnice
                mov     byte ptr l_28F9,1   ; 1=pero je zvednuto
                mov     l_2926,0            ; skute‡n  pozice zapisova‡e Y (HIGH)
                mov     l_2924,0            ; skute‡n  pozice zapisova‡e Y (LOW)
                xor     dx,dx
                mov     ax,dx
                mov     l_290D,dx           ; skute‡n  pozice zapisova‡e X (HIGH)
                mov     l_290B,ax           ; skute‡n  pozice zapisova‡e X (LOW)
                mov     l_29DE,dx           ; aktu ln¡ pozice Y (HIGH)
                mov     l_29DC,ax           ; aktu ln¡ pozice Y (LOW)
                mov     l_2A05,dx           ; aktu ln¡ pozice X (HIGH)
                mov     l_2A03,ax           ; aktu ln¡ pozice X (LOW)
                mov     l_29F7,ax
                mov     l_29F5,ax
                mov     dx,ax
                mov     l_2A09,dx
                mov     l_2A07,ax
                jmp     l_0C2E

; -----------------------------------------------------------------------------
;        "H" v˜choz¡ pozice
; -----------------------------------------------------------------------------

l_068B:         call    l_1306              ; nastaven¡ v˜choz¡ pozice HOME
                jmp     l_0C2E

; -----------------------------------------------------------------------------
;        "I"
; -----------------------------------------------------------------------------

l_0691:         call    l_00C1              ; ‡ek n¡ na dal¨¡ znak z DOS
                cmp     byte ptr l_29E0,28h ; znak k vysl n¡ od DOS ; '('
                jne     l_06A2
                mov     al,")"
                push    ax
                call    l_191F              ; ‡ek n¡ na oddˆlova‡ mezi ‡¡sly
                pop     cx
l_06A2:         mov     al,2Ch                  ; ','
                push    ax
                call    l_191F              ; ‡ek n¡ na oddˆlova‡ mezi ‡¡sly
                pop     cx

; -----------------------------------------------------------------------------
;        "L" nastaven¡ typu ‡ ry
; -----------------------------------------------------------------------------

l_06A9:         mov     al,2Ch                  ; ','
                push    ax
                call    l_191F              ; ‡ek n¡ na oddˆlova‡ mezi ‡¡sly
                pop     cx
                jmp     l_0C2E

; -----------------------------------------------------------------------------
;        "M" nakreslen¡ zna‡ky
; -----------------------------------------------------------------------------

                                          ;* test, zda je roz¨¡©en˜ m¢d
l_06B3:         call    l_00C1              ; ‡ek n¡ na dal¨¡ znak z DOS
                cmp     byte ptr l_29E0,"(" ; znak k vysl n¡ od DOS ; '('
                jne     l_06E2

                                          ;* test, zda n sleduje znak "S"
                call    l_00C1              ; ‡ek n¡ na dal¨¡ znak z DOS
                cmp     byte ptr l_29E0,"S" ; znak k vysl n¡ od DOS ; 'S'
                jne     l_06D6

                                          ;* na‡ten¡ ‡¡sla velikosti
                mov     ax,1
                push    ax
                call    l_1876              ; na‡ten¡ ‡¡sla
                pop     cx
                shl     ax,1
                mov     l_28F2,ax           ; velikost zna‡ky "M"
                jmp     short l_06DD

                                          ;* ‡ek n¡ na konec p©¡kazu
l_06D6:         mov     al,29h                  ; ')'
                push    ax
                call    l_191F              ; ‡ek n¡ na oddˆlova‡ mezi ‡¡sly
                pop     cx

l_06DD:         call    l_00C1              ; ‡ek n¡ na dal¨¡ znak z DOS
                jmp     short l_0722

                                          ;* na‡ten¡ velikosti zna‡ky
l_06E2:         mov     si,2
                cmp     byte ptr l_29E0,"5" ; znak k vysl n¡ od DOS ; '5'
                jbe     l_06F1
                mov     byte ptr l_29E0,"5" ; znak k vysl n¡ od DOS ; '5'
l_06F1:         mov     di,"1"
                jmp     short l_06F9

                                          ;* p©¡prava n sobitele velikosti
l_06F6:         add     si,si
                inc     di
l_06F9:         mov     al,l_29E0           ; znak k vysl n¡ od DOS
                mov     ah,0
                cmp     ax,di
                jg      l_06F6

                                          ;* zv˜¨en¡ o polovinu "+"
                call    l_00C1              ; ‡ek n¡ na dal¨¡ znak z DOS
                cmp     byte ptr l_29E0,"+" ; znak k vysl n¡ od DOS ; '+'
                jne     l_071E
                mov     ax,si
                mov     bx,2
                cwd
                idiv    bx
                mov     dx,3
                mul     dx
                mov     si,ax
                call    l_00C1              ; ‡ek n¡ na dal¨¡ znak z DOS
l_071E:         mov     l_28F2,si           ; velikost zna‡ky "M"

                                          ;* skok podle typu zna‡ky
l_0722:         mov     al,l_29E0           ; znak k vysl n¡ od DOS
                mov     ah,0
                sub     ax,"1"
                cmp     ax,4
                ja      l_0765
                mov     bx,ax
                shl     bx,1
                jmp     word ptr cs:l_0738[bx] ; 5 entries

l_0738     dw      offset l_0742
l_073A     dw      offset l_0749
l_073C     dw      offset l_0750
l_073E     dw      offset l_0757
l_0740     dw      offset l_075E

; ------ zna‡ka "x"

l_0742:         mov     word ptr [bp-2],2814h    ; zna‡ka "x"
                jmp     short l_076A

; ----- zna‡ka ‡tvere‡ek

l_0749:         mov     word ptr [bp-2],281Bh    ; zna‡ka ‡tvere‡ek
                jmp     short l_076A

; ----- zna‡ka osmi£heln¡k

l_0750:         mov     word ptr [bp-2],2823h    ; zna‡ka osmi£heln¡k
                jmp     short l_076A

; ----- zna‡ka troj£heln¡k

l_0757:         mov     word ptr [bp-2],282Fh    ; zna‡ka troj£heln¡k
                jmp     short l_076A

; ----- zna‡ka p©es˜pac¡ hodiny

l_075E:         mov     word ptr [bp-2],2836h    ; zna‡ka p©es˜pac¡ hodiny
                jmp     short l_076A

; ----- plus

l_0765:         mov     word ptr [bp-2],283Dh    ; implicitn¡ zna‡ka

; ----- p©¡prava jednoho znaku

l_076A:         mov     bx,[bp-2]
                mov     al,[bx]             ; znak
                mov     [bp-4],al

; ----- ukon‡en¡ p©¡kazu

;*              cmp     al,24h                  ; '$'
                db       80h,0F8h, 24h
                jz      l_07D9              ; nastaven¡ pera

; ----- nastaven¡ pera

                cmp     byte ptr [bp-4],40h     ; '@'
                jbe     l_0785
                mov     bx,2A0Bh            ; buffer jednoho p©¡kazu
                mov     byte ptr [bx],22h   ; povel pro spu¨tˆn¡ pera
                jmp     short l_078B
l_0785:         mov     bx,2A0Bh            ; buffer jednoho p©¡kazu
                mov     byte ptr [bx],23h   ; povel pro zvednut¡ pera
l_078B:         mov     ax,1
                push    ax
                call    l_1945              ; ulo‘en¡ povelu do bufferu
                pop     cx

; ------ v˜po‡et posunu X

                mov     al,[bp-4]
                mov     ah,0
                mov     bx,8
                cwd
                idiv    bx                  ; AL = posun X 0 a‘ 7
                cwd
                idiv    bx                  ; DL = posun X 0 a‘ 7
                mov     ax,dx
                add     ax,0FFFCh           ; -4 (tj posun -4 a‘ +3)
                mul     l_28F2              ; velikost zna‡ky "M"
                mov     di,ax               ; posun X

; ------ v˜po‡et posunu Y

                mov     al,[bp-4]
                mov     ah,0
                cwd
                idiv    bx                  ; DL = posun Y 0 a‘ 7
                mov     ax,dx
                add     ax,0FFFCh           ; -4 (tj. posun -4 a‘ +3)
                mul     l_28F2              ; velikost zna‡ky "M"
                mov     [bp-0Eh],ax         ; posun Y

; ------ posun pera

                mov     al,0
                push    ax
                mov     ax,[bp-0Eh]         ; posun Y
                cwd
                push    dx                  ; p©¡rustek Y
                push    ax
                mov     ax,di               ; posun X
                cwd
                push    dx                  ; p©¡rustek X
                push    ax
                call    l_1016              ; posun sou©adnic pera relativnˆ
;*              add     sp,0Ah
                db       83h,0C4h, 0Ah
                inc     word ptr [bp-2]     ; zv˜¨en¡ ukazatele znak–
                jmp     short l_076A

; ------ konec

l_07D9:         call    l_19A3              ; vysl n¡ povelu pro nastaven¡ pera
                jmp     l_0C2E

; -----------------------------------------------------------------------------
;        "O" posunut˜ po‡ tek
; -----------------------------------------------------------------------------

l_07DF:         mov     dx,l_290D           ; skute‡n  pozice zapisova‡e X (HIGH)
                mov     ax,l_290B           ; skute‡n  pozice zapisova‡e X (LOW)
                mov     l_2A09,dx
                mov     l_2A07,ax

                mov     dx,l_2926           ; skute‡n  pozice zapisova‡e Y (HIGH)
                mov     ax,l_2924           ; skute‡n  pozice zapisova‡e Y (LOW)
                mov     l_29F7,dx
                mov     l_29F5,ax

                mov     l_2926,0            ; skute‡n  pozice zapisova‡e Y (HIGH)
                mov     l_2924,0            ; skute‡n  pozice zapisova‡e Y (LOW)

                xor     dx,dx
                mov     ax,dx
                mov     l_290D,dx           ; skute‡n  pozice zapisova‡e X (HIGH)
                mov     l_290B,ax           ; skute‡n  pozice zapisova‡e X (LOW)
                mov     l_29DE,dx           ; aktu ln¡ pozice Y (HIGH)
                mov     l_29DC,ax           ; aktu ln¡ pozice Y (LOW)
                mov     l_2A05,dx           ; aktu ln¡ pozice X (HIGH)
                mov     l_2A03,ax           ; aktu ln¡ pozice X (LOW)
                jmp     l_0C2E

; -----------------------------------------------------------------------------
;        "P" volba pera
; -----------------------------------------------------------------------------

l_0823:         mov     ax,1
                push    ax
                call    l_1876              ; na‡ten¡ ‡¡sla
                pop     cx
                mov     si,ax               ; SI <- zvolen‚ pero

                or      si,si               ; je zru¨en¡ pera ?
                jz      l_085B

;*              cmp     si,3
                db       83h,0FEh, 03h
                jle     l_0839
                mov     si,3                ; omezen¡ ‡¡sla pera

l_0839:         mov     bx,2A0Bh            ; buffer jednoho p©¡kazu
                mov     byte ptr [bx],24h   ; povel pro volbu pera
                mov     ax,si
;*              add     al,20h                  ; ' '
                db       80h,0C0h, 20h
                mov     bx,offset l_2A0B+1
                mov     [bx],al             ; zvolen‚ pero
                mov     ax,2                ; 2 znaky
                push    ax
                call    l_1945              ; ulo‘en¡ povelu do bufferu
                pop     cx

                mov     ax,si
                mov     l_291B,al           ; ‡¡slo aktivn¡ho pera
                call    l_19A3              ; vysl n¡ povelu pro nastaven¡ pera
                jmp     short l_0863

; ------ zru¨en¡ v˜bˆru pera, navr cen¡ HOME

l_085B:         call    l_1306              ; nastaven¡ v˜choz¡ pozice HOME
                mov     byte ptr l_291B,0   ; ‡¡slo aktivn¡ho pera
l_0863:        jmp     l_0C2E

; -----------------------------------------------------------------------------
;        "Q" informace o zapisova‡i
; -----------------------------------------------------------------------------

l_0866:         mov     l_29FD,offset l_2844 ; identifika‡n¡ text zapisova‡e
                mov     l_291D,10h          ; ‡¡ta‡ bajt– ‡ten˜ch dat ke ‡ten¡
                jmp     l_0C2E

; -----------------------------------------------------------------------------
;        "R" relativn¡ adresov n¡ sou©adnic
; -----------------------------------------------------------------------------

l_0875:         mov     byte ptr l_2906,0   ; 1=absolutn¡ sou©adnice
                jmp     l_0C2E

; -----------------------------------------------------------------------------
;        "S" v˜pis textu
; -----------------------------------------------------------------------------

l_087D:         call    l_00C1              ; ‡ek n¡ na dal¨¡ znak z DOS
                cmp     byte ptr l_29E0,28h ; znak k vysl n¡ od DOS ; '('
                je      l_088A
                jmp     l_093A              ; nen¡ roz¨¡©en˜ m¢d textu

l_088A:         cmp     byte ptr l_29E0,29h ; znak k vysl n¡ od DOS ; ')'
                jne     l_0894
                jmp     l_0934

l_0894:         mov     al,l_29E0           ; znak k vysl n¡ od DOS
                mov     ah,0
                sub     ax,"I"
                cmp     ax,10h
                jbe     l_08A4
                jmp     l_092E

l_08A4:         mov     bx,ax
                shl     bx,1
                jmp     word ptr cs:l_08AD[bx] ; 17 entries

l_08AD     dw      offset l_08E6            ; "I" italic
l_08AF     dw      offset l_092E            ; "J"
l_08B1     dw      offset l_092E            ; "K"
l_08B3     dw      offset l_092E            ; "L"
l_08B5     dw      offset l_092E            ; "M"
l_08B7     dw      offset l_08F0            ; "N" ne-italic
l_08B9     dw      offset l_092E            ; "O"
l_08BB     dw      offset l_092E            ; "P"
l_08BD     dw      offset l_092E            ; "Q"
l_08BF     dw      offset l_092E            ; "R"
l_08C1     dw      offset l_08CF            ; "S" v˜¨ka znaku
l_08C3     dw      offset l_092E            ; "T"
l_08C5     dw      offset l_092E            ; "U"
l_08C7     dw      offset l_092E            ; "V"
l_08C9     dw      offset l_08FD            ; "W" ¨¡©ka znaku
l_08CB     dw      offset l_0914            ; "X" smˆrnice X
l_08CD     dw      offset l_0921            ; "Y" zmˆrnice Y

; ------ "S" v˜¨ka znaku

l_08CF:         mov     ax,1
                push    ax
                call    l_1876              ; na‡ten¡ ‡¡sla
                pop     cx
                xor     cx,cx
                mov     bx,7                ; n sobitel 7*N
                calls   far ptr l_1E5D      ; vyn soben¡ ‡¡sel
                mov     l_2979,ax           ; v˜¨ka znaku (krok–)
                jmp     short l_0931

; ------ p¡smo Italic

l_08E6:         mov     byte ptr l_29DB,1   ; 1=p©¡znak p¡sma Italic
                call    l_00C1              ; ‡ek n¡ na dal¨¡ znak z DOS
                jmp     short l_0931

; ----- p¡smo Normal

l_08F0:
                call    l_00C1              ; ‡ek n¡ na dal¨¡ znak z DOS
                mov     byte ptr l_29DB,0   ; 1=p©¡znak p¡sma Italic - je Normal
                call    l_00C1              ; ‡ek n¡ na dal¨¡ znak z DOS
                jmp     short l_0931

; ----- ¨¡©ka znaku

l_08FD:         mov     ax,1
                push    ax
                call    l_1876              ; na‡ten¡ ‡¡sla
                pop     cx
                xor     cx,cx
                mov     bx,6                ; n sobitel 6*N
                calls   far ptr l_1E5D      ; vyn soben¡ ‡¡sel
                mov     l_28FD,ax           ; ¨¡©ka znaku (krok–)
                jmp     short l_0931

; ------ smˆrnice textu X

l_0914:
                mov     ax,1
                push    ax
                call    l_1876              ; na‡ten¡ ‡¡sla
                pop     cx
                mov     word ptr ds:[29F3h],ax ; smˆrnice textu X
                jmp     short l_0931

; ----- smˆrnice textu Y

l_0921:         mov     ax,1
                push    ax
                call    l_1876              ; na‡ten¡ ‡¡sla
                pop     cx
                mov     word ptr l_2907,ax  ; smˆrnice textu Y
                jmp     short l_0931

; ----- neobsluhovan˜ povel

l_092E:        call    l_00C1              ; ‡ek n¡ na dal¨¡ znak z DOS
l_0931:        jmp     l_088A

; ----- konec povelu

l_0934:        call    l_00C1              ; ‡ek n¡ na dal¨¡ znak z DOS
               jmp     l_09DF

; ----- je m¢d jednoduch‚ho textu

l_093A:         mov     al,l_29E0           ; znak k vysl n¡ od DOS
                mov     ah,0
                sub     ax,"2"
                cmp     ax,2
                ja      l_0980
                mov     bx,ax
                shl     bx,1
                jmp     word ptr cs:l_0950[bx] ; 3 entries

l_0950     dw      offset l_0956            ; "2" 90 stup¤–
l_0952     dw      offset l_0964            ; "3" 180 stup¤–
l_0954     dw      offset l_0972            ; "4" 270 stup¤–

; ------ £hel nato‡en¡ 90

l_0956:         mov     word ptr ds:[29F3h],0 ; smˆrnice textu X
                mov     word ptr l_2907,1   ; smˆrnice textu Y
                jmp     short l_098C

; ------ £hel nato‡en¡ 180

l_0964:         mov     word ptr ds:[29F3h],0FFFFh ; smˆrnice textu X
                mov     word ptr l_2907,0   ; smˆrnice textu Y
                jmp     short l_098C

; ------ £hel nato‡en¡ 270

l_0972:         mov     word ptr ds:[29F3h],0 ; smˆrnice textu X
                mov     word ptr l_2907,0FFFFh ; smˆrnice textu Y
                jmp     short l_098C

; ----- £hel nato‡en¡ 0

l_0980:         mov     word ptr ds:[29F3h],1 ; smˆrnice textu X
                mov     word ptr l_2907,0   ; smˆrnice textu Y

; ----- na‡ten¡ velikosti textu

l_098C:         call    l_00C1              ; ‡ek n¡ na dal¨¡ znak z DOS
                mov     si,2
                cmp     byte ptr l_29E0,35h ; znak k vysl n¡ od DOS ; '5'
                jbe     l_099E
                mov     byte ptr l_29E0,35h ; znak k vysl n¡ od DOS ; '5'
l_099E:         mov     di,31h
                jmp     short l_09A6

l_09A3:         add     si,si
                inc     di
l_09A6:         mov     al,l_29E0           ; znak k vysl n¡ od DOS
                mov     ah,0
                cmp     ax,di
                jg      l_09A3
                call    l_00C1              ; ‡ek n¡ na dal¨¡ znak z DOS
                cmp     byte ptr l_29E0,2Bh ; znak k vysl n¡ od DOS ; '+'
                jne     l_09C8
                mov     ax,si
                mov     bx,2
                cwd
                idiv    bx
                mov     dx,3
                mul     dx
                mov     si,ax

; ----- v˜po‡et ¨¡©ky a v˜¨ky

l_09C8:         call    l_00C1              ; ‡ek n¡ na dal¨¡ znak z DOS
                mov     ax,si
                mov     dx,7
                mul     dx
                mov     l_2979,ax           ; v˜¨ka znaku (krok–)
                mov     ax,si
                mov     dx,6
                mul     dx
                mov     l_28FD,ax           ; ¨¡©ka znaku (krok–)

; ----- korekce £daj–

l_09DF:         cmp     word ptr ds:[29F3h],0 ; smˆrnice textu X
                jne     l_09F1
                cmp     word ptr l_2907,0   ; smˆrnice textu Y
                jne     l_09F1
                inc     word ptr ds:[29F3h] ; smˆrnice textu X

l_09F1:         cmp     l_2979,0            ; v˜¨ka znaku (krok–)
                jne     l_09FE
                mov     l_2979,8            ; v˜¨ka znaku (krok–)

; ----- v˜stup textu

l_09FE:         call    l_137B              ; v˜stup textu
                jmp     l_0C2E

; -----------------------------------------------------------------------------
;        "T" test zapisova‡e
; -----------------------------------------------------------------------------

l_0A04:         jmp     l_0C2E

; -----------------------------------------------------------------------------
;        "U" "y" pero nahoru
; -----------------------------------------------------------------------------

l_0A07:         mov     bx,2A0Bh            ; buffer jednoho p©¡kazu
                mov     byte ptr [bx],23h       ; '#'
                mov     ax,1
                push    ax
                call    l_1945              ; ulo‘en¡ povelu do bufferu
                pop     cx
                mov     byte ptr l_28F9,1   ; 1=pero je zvednuto
                jmp     l_0C2E

; -----------------------------------------------------------------------------
;        "V" nastaven¡ rychlosti
; -----------------------------------------------------------------------------

l_0A1D:         mov     al,2Ch                  ; ','
                push    ax
                call    l_191F              ; ‡ek n¡ na oddˆlova‡ mezi ‡¡sly
                pop     cx
                jmp     l_0C2E

; -----------------------------------------------------------------------------
;        "W" nastaven¡ velikosti okna a zvˆt¨en¡
; -----------------------------------------------------------------------------

; ------ lev˜ doln¡ roh okna X

l_0A27:         mov     ax,1
                push    ax
                call    l_1876              ; na‡ten¡ ‡¡sla
                pop     cx
                mov     l_2A01,dx           ; lev˜ doln¡ roh okna X (HIGH)
                mov     l_29FF,ax           ; lev˜ doln¡ roh okna X (LOW)

; ------ lev˜ doln¡ roh okna Y

                mov     ax,1
                push    ax
                call    l_1876              ; na‡ten¡ ‡¡sla
                pop     cx
                mov     l_29FB,dx           ; lev˜ doln¡ roh okna Y (HIGH)
                mov     l_29F9,ax           ; lev˜ doln¡ roh okna Y (LOW)

; ------ prav˜ horn¡ roh okna X

                mov     ax,1
                push    ax
                call    l_1876              ; na‡ten¡ ‡¡sla
                pop     cx
                mov     l_2902,dx           ; prav˜ horn¡ roh okna X (HIGH)
                mov     l_2900,ax           ; prav˜ horn¡ roh okna X (LOW)

; ------ prav˜ horn¡ roh okna Y

                mov     ax,1
                push    ax
                call    l_1876              ; na‡ten¡ ‡¡sla
                pop     cx
                mov     l_28F6,dx           ; prav˜ horn¡ roh okna Y (HIGH)
                mov     l_28F4,ax           ; prav˜ horn¡ roh okna Y (LOW)

; ------ test, zda je okno platn‚ (zda m  nulov‚ rozmˆry)

                mov     dx,l_2A01           ; lev˜ doln¡ roh okna X (HIGH)
                mov     ax,l_29FF           ; lev˜ doln¡ roh okna X (LOW)
                cmp     dx,l_2902           ; prav˜ horn¡ roh okna X (HIGH)
                jne     l_0A76
                cmp     ax,l_2900           ; prav˜ horn¡ roh okna X (LOW)
                je      l_0A89

l_0A76:         mov     dx,l_29FB           ; lev˜ doln¡ roh okna Y (HIGH)
                mov     ax,l_29F9           ; lev˜ doln¡ roh okna Y (LOW)
                cmp     dx,l_28F6           ; prav˜ horn¡ roh okna Y (HIGH)
                jne     l_0A90
                cmp     ax,l_28F4           ; prav˜ horn¡ roh okna Y (LOW)
                jne     l_0A90

l_0A89:         mov     byte ptr l_291C,0   ; 1=okno je platn‚ (0=neplat¡ rozmˆr)
                jmp     short l_0A95

l_0A90:         mov     byte ptr l_291C,1   ; 1=okno je platn‚ (0=neplat¡ rozmˆr)

; ------ lev˜ doln¡ roh ZOOM X

l_0A95:         mov     ax,1
                push    ax
                call    l_1876              ; na‡ten¡ ‡¡sla
                pop     cx
                mov     l_2919,dx           ; lev˜ doln¡ roh okna X ZOOM (HIGH)
                mov     l_2917,ax           ; lev˜ doln¡ roh okna X ZOOM (LOW)

; ------ lev˜ doln¡ roh ZOOM Y

                mov     ax,1
                push    ax
                call    l_1876              ; na‡ten¡ ‡¡sla
                pop     cx
                mov     l_29ED,dx           ; lev˜ doln¡ roh okna Y ZOOM (HIGH)
                mov     l_29EB,ax           ; lev˜ doln¡ roh okna Y ZOOM (LOW)

; ----- prav˜ horn¡ roh ZOOM X

                mov     ax,1
                push    ax
                call    l_1876              ; na‡ten¡ ‡¡sla
                pop     cx
                mov     l_29E9,dx           ; prav˜ horn¡ roh okna X ZOOM (HIGH)
                mov     l_29E7,ax           ; prav˜ horn¡ roh okna X ZOOM (LOW)
                sub     ax,l_2917           ; lev˜ doln¡ roh okna X ZOOM (LOW)
                sbb     dx,l_2919           ; lev˜ doln¡ roh okna X ZOOM (HIGH)
                mov     l_29F1,dx           ; ¨¡©ka okna X ZOOM (HIGH)
                mov     l_29EF,ax           ; ¨¡©ka okna X ZOOM (LOW)

; ------- prav˜ horn¡ roh ZOOM Y

                mov     ax,1
                push    ax
                call    l_1876              ; na‡ten¡ ‡¡sla
                pop     cx
                mov     l_2911,dx           ; prav˜ horn¡ roh okna Y ZOOM (HIGH)
                mov     l_290F,ax           ; prav˜ horn¡ roh okna Y ZOOM (LOW)
                sub     ax,l_29EB           ; lev˜ doln¡ roh okna Y ZOOM (LOW)
                sbb     dx,l_29ED           ; lev˜ doln¡ roh okna Y ZOOM (HIGH)
                mov     l_29E5,dx           ; v˜¨ka okna Y ZOOM (HIGH)
                mov     l_29E3,ax           ; v˜¨ka okna Y ZOOM (LOW)

; ----- ¨¡©ka okna X

                mov     dx,l_2902           ; prav˜ horn¡ roh okna X (HIGH)
                mov     ax,l_2900           ; prav˜ horn¡ roh okna X (LOW)
                sub     ax,l_29FF           ; lev˜ doln¡ roh okna X (LOW)
                sbb     dx,l_2A01           ; lev˜ doln¡ roh okna X (HIGH)
                mov     l_2915,dx           ; ¨¡©ka okna X (HIGH)
                mov     l_2913,ax           ; ¨¡©ka okna X (LOW)

; ----- v˜¨ka okna Y

                mov     dx,l_28F6           ; prav˜ horn¡ roh okna Y (HIGH)
                mov     ax,l_28F4           ; prav˜ horn¡ roh okna Y (LOW)
                sub     ax,l_29F9           ; lev˜ doln¡ roh okna Y (LOW)
                sbb     dx,l_29FB           ; lev˜ doln¡ roh okna Y (HIGH)
                mov     l_2922,dx           ; v˜¨ka okna Y (HIGH)
                mov     l_2920,ax           ; v˜¨ka okna Y (LOW)

; ------ test, zda jsou rozmˆry ZOOM platn‚

                mov     ax,l_29EF           ; ¨¡©ka okna X ZOOM (LOW)
                or      ax,l_29F1           ; ¨¡©ka okna X ZOOM (HIGH)
                jz      l_0B35
                mov     ax,l_29E3           ; v˜¨ka okna Y ZOOM (LOW)
                or      ax,l_29E5           ; v˜¨ka okna Y ZOOM (HIGH)
                jz      l_0B35
                mov     al,l_291C           ; 1=okno je platn‚ (0=neplat¡ rozmˆr)
                mov     l_2904,al           ; 1=okno je platn‚ (0=neplatn‚ ZOOM)
                jmp     short l_0B3A

l_0B35:         mov     byte ptr l_2904,0   ; 1=okno je platn‚ (0=neplatn‚ ZOOM)
l_0B3A:         jmp     l_0C2E

; -----------------------------------------------------------------------------
;        ";" volba komunika‡n¡ho m¢du zapisova‡e
; -----------------------------------------------------------------------------

l_0B3D:         call    l_00C1              ; ‡ek n¡ na dal¨¡ znak z DOS
                jmp     l_0C2E

; -----------------------------------------------------------------------------
;        "@" vypr zdnˆn¡ buffer–
; -----------------------------------------------------------------------------

l_0B43:         call    l_1AB1              ; vypr zdnˆn¡ buffer–
                jmp     l_0C2E

; -----------------------------------------------------------------------------
;        "p" posun o 1 krok X+
; -----------------------------------------------------------------------------

l_0B49:         mov     al,0                ; posun Y = 0
                push    ax
                xor     dx,dx
                mov     ax,1
                push    dx
                push    ax                  ; posun X = +1
                push    dx
                push    dx
                call    l_1016              ; posun sou©adnic pera relativnˆ
;*              add     sp,0Ah
                db       83h,0C4h, 0Ah
                jmp     l_0C2E

; -----------------------------------------------------------------------------
;        "q" posun o 1 krok X+ Y+
; -----------------------------------------------------------------------------

l_0B5E:         mov     al,0
                push    ax
                xor     dx,dx
                mov     ax,1
                push    dx
                push    ax
                push    dx
                push    ax
                call    l_1016              ; posun sou©adnic pera relativnˆ
;*              add     sp,0Ah
                db       83h,0C4h, 0Ah
                jmp     l_0C2E

; -----------------------------------------------------------------------------
;        "r" posun o 1 krok X+
; -----------------------------------------------------------------------------

l_0B73:         mov     al,0
                push    ax
                xor     ax,ax
                push    ax
                push    ax
                mov     dx,ax
                mov     ax,1
                push    dx
                push    ax
                call    l_1016              ; posun sou©adnic pera relativnˆ
;*              add     sp,0Ah
                db       83h,0C4h, 0Ah
                jmp     l_0C2E

; -----------------------------------------------------------------------------
;        "s" posun o 1 krok X+ Y-
; -----------------------------------------------------------------------------

l_0B8A:         mov     al,0
                push    ax
                mov     dx,0FFFFh
                mov     ax,dx
                push    dx
                push    ax
                xor     dx,dx
                mov     ax,1
                push    dx
                push    ax
                call    l_1016              ; posun sou©adnic pera relativnˆ
;*              add     sp,0Ah
                db       83h,0C4h, 0Ah
                jmp     l_0C2E

; -----------------------------------------------------------------------------
;        "t" posun o 1 krok Y-
; -----------------------------------------------------------------------------

l_0BA4:         mov     al,0
                push    ax
                mov     dx,0FFFFh
                mov     ax,dx
                push    dx
                push    ax
                xor     ax,ax
                push    ax
                push    ax
                call    l_1016              ; posun sou©adnic pera relativnˆ
;*              add     sp,0Ah
                db       83h,0C4h, 0Ah
                jmp     short l_0C2E

; -----------------------------------------------------------------------------
;        "u" posun o 1 krok X- Y-
; -----------------------------------------------------------------------------

l_0BBA:         mov     al,0
                push    ax
                mov     dx,0FFFFh
                mov     ax,dx
                push    dx
                push    ax
                mov     dx,ax
                push    dx
                push    ax
                call    l_1016              ; posun sou©adnic pera relativnˆ
;*              add     sp,0Ah
                db       83h,0C4h, 0Ah
                jmp     short l_0C2E

; -----------------------------------------------------------------------------
;        "v" posun o 1 krok X-
; -----------------------------------------------------------------------------

l_0BD0:         mov     al,0
                push    ax
                xor     ax,ax
                push    ax
                push    ax
                mov     dx,0FFFFh
                mov     ax,dx
                push    dx
                push    ax
                call    l_1016              ; posun sou©adnic pera relativnˆ
;*              add     sp,0Ah
                db       83h,0C4h, 0Ah
                jmp     short l_0C2E

; -----------------------------------------------------------------------------
;        "w" posun o 1 krok X- Y+
; -----------------------------------------------------------------------------

l_0BE6:         mov     al,0
                push    ax
                xor     dx,dx
                mov     ax,1
                push    dx
                push    ax
                mov     dx,0FFFFh
                mov     ax,dx
                push    dx
                push    ax
                call    l_1016              ; posun sou©adnic pera relativnˆ
;*              add     sp,0Ah
                db       83h,0C4h, 0Ah
                jmp     short l_0C2E

; -----------------------------------------------------------------------------
;        "+", "-" posun pera
; -----------------------------------------------------------------------------

l_0BFF:         xor     ax,ax
                push    ax
                call    l_1876              ; na‡ten¡ ‡¡sla
                pop     cx
                mov     [bp-0Ah],dx         ; sou©adnice X
                mov     [bp-0Ch],ax

                mov     ax,1
                push    ax
                call    l_1876              ; na‡ten¡ ‡¡sla
                pop     cx
                mov     [bp-6],dx           ; sou©adnice Y
                mov     [bp-8],ax

                push    l_2906              ; 1=absolutn¡ sou©adnice
                push    dx                  ; Y
                push    ax
                push    word ptr [bp-0Ah]   ; X
                push    word ptr [bp-0Ch]
                call    l_1016              ; posun sou©adnic pera relativnˆ
;*              add     sp,0Ah
                db       83h,0C4h, 0Ah
                jmp     short l_0C2E

; -----------------------------------------------------------------------------
;        neplatn˜ znak - ignorov n¡
; -----------------------------------------------------------------------------

l_0C2E:         call    l_00C1              ; ‡ek n¡ na dal¨¡ znak z DOS
                jmp     l_0148

l_0C34:         mov     sp,bp
                pop     bp
                pop     di
                pop     si
                retn

; -----------------------------------------------------------------------------
;        vykreslen¡ oblouku (X,Y,d)
; -----------------------------------------------------------------------------
;þ
l_0C3A:         push    si
                push    di
                push    bp
                mov     bp,sp
;*              sub     sp,1Ch
                db       83h,0ECh, 1Ch
                mov     word ptr [bp-0Eh],1 ; kladn˜ smˆr kreslen¡ oblouku

; ------ £schova v˜choz¡ pozice (=aktu ln¡ sou©adnice)

                mov     dx,l_2A05           ; aktu ln¡ pozice X (HIGH)
                mov     ax,l_2A03           ; aktu ln¡ pozice X (LOW)
                mov     [bp-0Ah],dx
                mov     [bp-0Ch],ax
                mov     dx,l_29DE           ; aktu ln¡ pozice Y (HIGH)
                mov     ax,l_29DC           ; aktu ln¡ pozice Y (LOW)
                mov     [bp-6],dx
                mov     [bp-8],ax

; ------ stanoven¡ vzd lenosti v˜choz¡ho bodu od st©edu

                cmp     byte ptr l_2906,0   ; 1=absolutn¡ sou©adnice
                je      l_0C76
                mov     si,l_2A03           ; aktu ln¡ pozice X (LOW)
                sub     si,[bp+8]           ; vzd lenost pozice a st©edu X
                mov     di,ax
                sub     di,[bp+0Ch]         ; vzd lenost pozice a st©edu Y
                jmp     short l_0C80

l_0C76:         mov     si,[bp+8]           ; vzd lenost st©edu X relativnˆ
                neg     si
                mov     di,[bp+0Ch]         ; vzd lenost st©edu Y relativnˆ
                neg     di

; ------ vzd lenost X*X

l_0C80:         mov     ax,si
                cwd
                push    dx
                push    ax
                mov     ax,si
                cwd
                pop     bx
                pop     cx
                calls   far ptr l_1E5D      ; vyn soben¡ ‡¡sel

; ------- vzd lenost Y*Y

                push    dx
                push    ax
                mov     ax,di
                cwd
                push    dx
                push    ax
                mov     ax,di
                cwd
                pop     bx
                pop     cx
                calls   far ptr l_1E5D      ; vyn soben¡ ‡¡sel
                pop     bx
                pop     cx

; ------ polomˆr oblouku = odmocnina ze sou‡tu X*X + Y*Y

                add     bx,ax               ; X*X + Y*Y
                adc     cx,dx
                push    cx
                push    bx
                call    l_19C1              ; odmocnina ‡¡sla
                pop     cx
                pop     cx
                mov     [bp-1Ch],ax         ; polomˆr oblouku

; ------ korekce pro z porn˜ £hel

                cmp     word ptr [bp+10h],0 ; je £hel z porn˜
                jge     l_0CC3
                mov     word ptr [bp-0Eh],0 ; z porn˜ smˆr kreslen¡ oblouku
                mov     ax,[bp+10h]
                neg     ax                  ; korekce £hlu na kladnou hodnotu
                mov     [bp+10h],ax

; ----- omezen¡ velikosti £hlu

l_0CC3:         cmp     word ptr [bp+10h],360
                jle     l_0CCF
                mov     word ptr [bp+10h],360

; ------ vyn soben¡:   polomˆr * £hel

l_0CCF:         mov     ax,l_28FB           ; vydˆlen¡ v˜sledku odmocniny
                cwd
                push    dx
                push    ax
                xor     dx,dx

                mov     ax,360
                push    dx
                push    ax

                mov     ax,[bp-1Ch]         ; polomˆr oblouku
                cwd
                push    dx
                push    ax
                mov     ax,[bp+10h]         ; £hel
                cwd
                pop     bx
                pop     cx
                calls   far ptr l_1E5D      ; vyn soben¡ ‡¡sel POLOM‰R *  —HEL

; ------ sou‡in * 8

                mov     cx,3
                calls   far ptr l_1E23      ; rotace DX:AX o CL bit– vlevo

; ------ vydˆlen¡ v˜sledku / 360

                push    dx
                push    ax
                calls   far ptr l_1DA9      ; vydˆlen¡ ‡¡sel

; ------ oprava podle v˜po‡tu odmocniny

                push    dx
                push    ax
                calls   far ptr l_1DA9      ; vydˆlen¡ ‡¡sel
                mov     [bp-2],dx           ; pomˆrn  ‡ st £hlu oblouku
                mov     [bp-4],ax

; ----- spu¨tˆn¡ pera

                mov     bx,2A0Bh            ; buffer jednoho p©¡kazu
                mov     byte ptr [bx],22h       ; '"'
                mov     ax,1
                push    ax
                call    l_1945              ; ulo‘en¡ povelu do bufferu
                pop     cx

; ------ test, zda zb˜v  je¨tˆ £hel

                mov     word ptr [bp-16h],0 ; promˆnn  SI
l_0D1C:         mov     ax,[bp-4]
                or      ax,[bp-2]
                jnz     l_0D27
                jmp     l_0E72

; ----- p©¡rustek sou©adnice X

l_0D27:         or      di,di               ; je sou©adnice Y kladn  ?
                jge     l_0D31              ; sou©adnice Y je kladn 
                cmp     word ptr [bp-0Eh],0 ; je z porn˜ smˆr kreslen¡ ?
                jne     l_0D3B              ; je kladn˜ smˆr kreslen¡

l_0D31:         or      di,di               ; je sou©adnice Y kladn  ?
                jl      l_0D40              ; sou©adnice Y je z porn 
                cmp     word ptr [bp-0Eh],0 ; je z porn˜ smˆr kreslen¡ ?
                jne     l_0D40              ; je kladn˜ smˆr kreslen¡

l_0D3B:         mov     ax,1                ; kladn˜ smˆr X
                jmp     short l_0D43

l_0D40:         mov     ax,0FFFFh           ; z porn˜ smˆr p©¡rustku X

l_0D43:         mov     [bp-1Ah],ax         ; p©¡rustek X

; ----- p©¡rustek sou©adnice Y

                or      si,si               ; je sou©adnice X kladn  ?
                jl      l_0D50              ; je z porn 
                cmp     word ptr [bp-0Eh],0 ; je z porn˜ smˆr kreslen¡ ?
                jne     l_0D5A              ; je kladn˜ smˆr kreslen¡

l_0D50:         or      si,si               ; je sou©adnice X kladn  ?
                jge     l_0D5F              ; je kladn 
                cmp     word ptr [bp-0Eh],0 ; je z porn˜ smˆr kreslen¡ ?
                jne     l_0D5F              ; je kladn˜ smˆr kreslen¡

l_0D5A:         mov     ax,1                ; kladn˜ smˆr Y
                jmp     short l_0D62

l_0D5F:         mov     ax,0FFFFh           ; z porn˜ smˆr Y
l_0D62:         mov     [bp-18h],ax         ; p©¡rustek Y

; ------ pomocn  promˆnn  X = 2 * p©¡rustek X * pozice X

                mov     ax,2
                mul     si                  ; * pozice X
                mul     word ptr [bp-1Ah]   ; p©¡rustek X
                add     ax,[bp-16h]         ; + SI
                inc     ax                  ; + 1
                mov     [bp-14h],ax         ; pomocn  promˆnn  X

; ------ pomocn  promˆnn  Y = 2 * p©¡rustek Y * pozice Y

                mov     ax,2
                mul     di                  ; * pozice Y
                mul     word ptr [bp-18h]   ; * p©¡rustek Y
                add     ax,[bp-16h]         ; + SI
                inc     ax                  ; + 1
                mov     [bp-12h],ax         ; pomocn  promˆnn  Y

; ------ pomocn  promˆnn  X+Y = 2*X + 2*Y + SI + 2

                mov     ax,[bp-14h]         ; pomocn  promˆnn  X
                add     ax,[bp-12h]         ; + promˆnn  Y
                sub     ax,[bp-16h]         ; - SI
                mov     [bp-10h],ax         ; pomocn  promˆnn  X + Y

; ------- porovn n¡ pomocn‚ promˆnn‚ Y a X

                push    word ptr [bp-12h]   ; pomocn  promˆnn  Y
                call    l_1A9B              ; absolutn¡ hodnota slova
                pop     cx
                push    ax
                push    word ptr [bp-14h]   ; pomocn  promˆnn  X
                call    l_1A9B              ; absolutn¡ hodnota slova
                pop     cx
                pop     dx
                cmp     dx,ax
                jge     l_0DC5

; ------ porovn n¡ promˆnn‚ Y a Y+X

                push    word ptr [bp-12h]   ; pomocn  promˆnn  Y
                call    l_1A9B              ; absolutn¡ hodnota slova
                pop     cx
                push    ax
                push    word ptr [bp-10h]   ; pomocn  promˆnn  X + Y
                call    l_1A9B              ; absolutn¡ hodnota slova
                pop     cx
                pop     dx
                cmp     dx,ax
                jg      l_0DC5

; ------ nen¡ posun X

                mov     word ptr [bp-1Ah],0 ; p©¡rustek X
                mov     ax,[bp-12h]         ; pomocn  promˆnn  Y
                mov     [bp-16h],ax         ; promˆnn  SI
                jmp     l_0E3A

; ------ porovn n¡ X a Y

l_0DC5:         push    word ptr [bp-14h]   ; pomocn  promˆnn  X
                call    l_1A9B              ; absolutn¡ hodnota slova
                pop     cx
                push    ax
                push    word ptr [bp-12h]   ; pomocn  promˆnn  Y
                call    l_1A9B              ; absolutn¡ hodnota slova
                pop     cx
                pop     dx
                cmp     dx,ax
                jg      l_0DFA

; ------- porovn n¡ X a X+Y

                push    word ptr [bp-14h]   ; pomocn  promˆnn  X
                call    l_1A9B              ; absolutn¡ hodnota slova
                pop     cx
                push    ax
                push    word ptr [bp-10h]   ; pomocn  promˆnn  X + Y
                call    l_1A9B              ; absolutn¡ hodnota slova
                pop     cx
                pop     dx
                cmp     dx,ax
                jg      l_0DFA

; ------ nen¡ posun Y

                mov     word ptr [bp-18h],0 ; p©¡rustek Y
                mov     ax,[bp-14h]         ; pomocn  promˆnn  X
                mov     [bp-16h],ax         ; promˆnn  SI
                jmp     short l_0E3A

; ------ posun ‡¡ta‡e £hlu - sn¡‘en¡ o 1

l_0DFA:         mov     dx,[bp-2]
                mov     ax,[bp-4]
                add     ax,0FFFFh
;*              adc     dx,0FFFFh
                db       83h,0D2h,0FFh
                mov     [bp-2],dx
                mov     [bp-4],ax

; ------ porovn n¡ X+Y a X

                push    word ptr [bp-10h]   ; pomocn  promˆnn  X + Y
                call    l_1A9B              ; absolutn¡ hodnota slova
                pop     cx
                push    ax
                push    word ptr [bp-14h]   ; pomocn  promˆnn  X
                call    l_1A9B              ; absolutn¡ hodnota slova
                pop     cx
                pop     dx
                cmp     dx,ax
                jge     l_0E3A

; ----- porovn n¡ X+Y a Y

                push    word ptr [bp-10h]   ; pomocn  promˆnn  X + Y
                call    l_1A9B              ; absolutn¡ hodnota slova
                pop     cx
                push    ax
                push    word ptr [bp-12h]   ; pomocn  promˆnn  Y
                call    l_1A9B              ; absolutn¡ hodnota slova
                pop     cx
                pop     dx
                cmp     dx,ax
                jge     l_0E3A

; ------- nov  hodnota promˆnn‚ SI

                mov     ax,[bp-10h]         ; pomocn  promˆnn  X + Y
                mov     [bp-16h],ax         ; promˆnn  SI

; ------- posun ukazatele relativn¡ pozice

l_0E3A:         add     si,[bp-1Ah]         ; p©¡rustek X
                add     di,[bp-18h]         ; p©¡rustek Y

; ------- posun pera

                mov     al,0
                push    ax
                mov     ax,[bp-18h]         ; p©¡rustek Y
                cwd
                push    dx
                push    ax
                mov     ax,[bp-1Ah]         ; p©¡rustek X
                cwd
                push    dx
                push    ax
                call    l_1016              ; posun sou©adnic pera relativnˆ
;*              add     sp,0Ah
                db       83h,0C4h, 0Ah

; ------ sn¡‘en¡ ‡¡ta‡e £hlu o 1

                mov     ax,[bp-4]
                or      ax,[bp-2]
                jz      l_0E6F
                mov     dx,[bp-2]
                mov     ax,[bp-4]
                add     ax,0FFFFh
;*              adc     dx,0FFFFh
                db       83h,0D2h,0FFh
                mov     [bp-2],dx
                mov     [bp-4],ax

l_0E6F:         jmp     l_0D1C

; ------ n vrat pera na v˜choz¡ pozici

l_0E72:         mov     al,1
                push    ax
                push    word ptr [bp-6]
                push    word ptr [bp-8]
                push    word ptr [bp-0Ah]
                push    word ptr [bp-0Ch]
                call    l_1979              ; p©esun pera na zadanou pozici
;*              add     sp,0Ah
                db       83h,0C4h, 0Ah
                mov     sp,bp
                pop     bp
                pop     di
                pop     si
                retn

;==========================================================================
;        vykreslen¡ kru‘nice (X,Y,r)
;==========================================================================
;þ
l_0E8D      proc    near
                push    si
                push    di
                push    bp
                mov     bp,sp
;*              sub     sp,14h
                db       83h,0ECh, 14h
                push    l_2906              ; 1=absolutn¡ sou©adnice

; ----- p©esun pera na v˜choz¡ pozici (po‡ tek kru‘nice - spodn¡ okraj)

                mov     ax,[bp+10h]         ; polomˆr kru‘nice
                cwd
                add     ax,[bp+0Ch]         ; + sou©adnice Y
                adc     dx,[bp+0Eh]
                push    dx
                push    ax
                push    word ptr [bp+0Ah]   ; sou©adnice X
                push    word ptr [bp+8]
                call    l_1979              ; p©esun pera na zadanou pozici
;*              add     sp,0Ah
                db       83h,0C4h, 0Ah

; ----- £schova sou©adnic st©edu

                mov     dx,l_2A05           ; aktu ln¡ pozice X (HIGH)
                mov     ax,l_2A03           ; aktu ln¡ pozice X (LOW)
                mov     [bp-6],dx           ; pozice st©edu X
                mov     [bp-8],ax
                mov     dx,l_29DE           ; aktu ln¡ pozice Y (HIGH)
                mov     ax,l_29DC           ; aktu ln¡ pozice Y (LOW)
                push    dx
                push    ax
                mov     ax,[bp+10h]         ; polomˆr
                cwd
                pop     bx
                pop     cx
                sub     bx,ax               ; pozice Y - polomˆr
                sbb     cx,dx
                mov     [bp-2],cx           ; sou©adnice st©edu Y
                mov     [bp-4],bx

; ----- spu¨tˆn¡ pera

                mov     bx,2A0Bh            ; buffer jednoho p©¡kazu
                mov     byte ptr [bx],22h   ; spu¨tˆn¡ pera
                mov     ax,1
                push    ax
                call    l_1945              ; ulo‘en¡ povelu do bufferu
                pop     cx

; ----- p©¡prava ukazatele relativn¡ pozice

                mov     word ptr [bp-14h],0 ; relativn¡ pozice X
                mov     ax,[bp+10h]         ; polomˆr
                mov     [bp-12h],ax         ; relativn¡ pozice Y
                xor     si,si               ; SI <- 0

; ----- koeficient smˆru X

l_0EF2:         cmp     word ptr [bp-12h],0 ; je kladn  ‡ st Y ?
                jge     l_0EFD              ; je kladn  ‡ st Y
                mov     ax,1                ; smˆr X = 1
                jmp     short l_0F00
l_0EFD:         mov     ax,0FFFFh           ; smˆr X = -1
l_0F00:         mov     [bp-10h],ax         ; relativn¡ posun X

; ------ koeficient smˆru Y

                cmp     word ptr [bp-14h],0 ; je kladn  ‡ st X ?
                jl      l_0F0E              ; je z porn  ‡ st X
                mov     ax,1                ; smˆr Y = 1
                jmp     short l_0F11
l_0F0E:         mov     ax,0FFFFh           ; smˆr Y = -1
l_0F11:         mov     [bp-0Eh],ax         ; relativn¡ posun Y

; ------ 2 * pozice X + SI + 1

                mov     ax,2                ; 2
                mul     word ptr [bp-14h]   ; * relativn¡ pozice X
                mul     word ptr [bp-10h]   ; * koeficient smˆru X
                mov     di,ax
                add     di,si
                inc     di                  ; 2*pozice X + SI + 1

; ----- 2 * pozice Y + SI + 1

                mov     ax,2                ; 2
                mul     word ptr [bp-12h]   ; * relativn¡ pozice Y
                mul     word ptr [bp-0Eh]   ; * koeficient smˆru Y
                add     ax,si
                inc     ax
                mov     [bp-0Ch],ax         ; 2*pozice Y + SI + 1

; ------ 2*X + 2*Y + SI + 2

                mov     ax,di
                add     ax,[bp-0Ch]         ; 2*pozice X + SI + 2*pozice Y + SI
                sub     ax,si               ; 2*pozice X + 2*pozice Y + SI + 2
                mov     [bp-0Ah],ax         ; 2*X + 2*Y + SI + 2

; ------ absolutn¡ hodnota 2*Y + SI + 1

                push    word ptr [bp-0Ch]
                call    l_1A9B              ; absolutn¡ hodnota slova
                pop     cx

; ------ absolutn¡ hodnota 2*X + SI + 1

                push    ax
                push    di                  ; 2*X + SI + 1
                call    l_1A9B              ; absolutn¡ hodnota slova
                pop     cx
                pop     dx

; ----- ?

                cmp     dx,ax
                jge     l_0F6B

; ------ absolutn¡ hodnota 2*Y + SI + 1

                push    word ptr [bp-0Ch]
                call    l_1A9B              ; absolutn¡ hodnota slova
                pop     cx

; ------ absolutn¡ hodnota 2*X + 2*Y + SI + 2

                push    ax
                push    word ptr [bp-0Ah]
                call    l_1A9B              ; absolutn¡ hodnota slova
                pop     cx
                pop     dx

; ----- ?

                cmp     dx,ax
                jg      l_0F6B

; ------ nen¡ posun X

                mov     word ptr [bp-10h],0 ; relativn¡ posun X

; ------ SI <- 2*Y + SI + 1

                mov     si,[bp-0Ch]
                jmp     short l_0FC1

; ------ absolutn¡ hodnota 2*X + SI + 1

l_0F6B:         push    di
                call    l_1A9B              ; absolutn¡ hodnota slova
                pop     cx

; ------ absolutn¡ hodnota 2*Y + SI + 1

                push    ax
                push    word ptr [bp-0Ch]
                call    l_1A9B              ; absolutn¡ hodnota slova
                pop     cx
                pop     dx

; ------ ?

                cmp     dx,ax
                jg      l_0F98

; ------ absolutn¡ hodnota 2*X + SI + 1

                push    di
                call    l_1A9B              ; absolutn¡ hodnota slova
                pop     cx

; ------ absolutn¡ hodnota 2*X + 2*Y + SI + 2

                push    ax
                push    word ptr [bp-0Ah]
                call    l_1A9B              ; absolutn¡ hodnota slova
                pop     cx
                pop     dx

; ----- ?

                cmp     dx,ax
                jg      l_0F98

; ----- nen¡ posun Y

                mov     word ptr [bp-0Eh],0 ; relativn¡ posun Y

; ----- SI <- 2*X + SI + 1

                mov     si,di
                jmp     short l_0FC1

; ----- absolutn¡ hodnota 2*X + 2*Y + SI + 2

l_0F98:         push    word ptr [bp-0Ah]
                call    l_1A9B              ; absolutn¡ hodnota slova
                pop     cx

; ----- absolutn¡ hodnota 2*X + SI + 1

                push    ax
                push    di
                call    l_1A9B              ; absolutn¡ hodnota slova
                pop     cx
                pop     dx

; ----- ?

                cmp     dx,ax
                jge     l_0FC1

; ----- absolutn¡ hodnota 2*X + 2*Y + SI + 2

                push    word ptr [bp-0Ah]
                call    l_1A9B              ; absolutn¡ hodnota slova
                pop     cx

; ------ absolutn¡ hodnota 2*Y + SI + 1

                push    ax
                push    word ptr [bp-0Ch]
                call    l_1A9B              ; absolutn¡ hodnota slova
                pop     cx
                pop     dx

; ------ ?

                cmp     dx,ax
                jge     l_0FC1

; ------ SI <- 2*X + 2*Y + SI + 2

                mov     si,[bp-0Ah]

; ----- zv˜¨en¡ ukazatele relativn¡ pozice

l_0FC1:         mov     ax,[bp-10h]         ; relativn¡ posun X
                add     [bp-14h],ax         ; posun relativn¡ pozice X
                mov     ax,[bp-0Eh]         ; relativn¡ posun Y
                add     [bp-12h],ax         ; posun relativn¡ pozice Y

; ------ relativn¡ posun pera

                mov     al,0                ; relativn¡ adresov n¡
                push    ax
                mov     ax,[bp-0Eh]         ; relativn¡ posun Y
                cwd
                push    dx
                push    ax
                mov     ax,[bp-10h]         ; relativn¡ posun X
                cwd
                push    dx
                push    ax
                call    l_1016              ; posun sou©adnic pera relativnˆ
;*              add     sp,0Ah
                db       83h,0C4h, 0Ah

; ------ test, zda je dosa‘eno opˆt v˜choz¡ho bodu

                cmp     word ptr [bp-14h],0 ; relativn¡ pozice X = 0 ?
                je      l_0FEB              ; X=0, nohl by to b˜t v˜choz¡ bod
                jmp     l_0EF2              ; dal¨¡ bod

l_0FEB:         mov     ax,[bp-12h]         ; relativn¡ pozice Y
                cmp     ax,[bp+10h]         ; = polomˆr ?
                jge     l_0FF6              ; dosa‘eno v˜choz¡ pozice
                jmp     l_0EF2              ; dal¨¡ bod

; ----- nastaven¡ pera na st©ed kru‘nice

l_0FF6:         mov     byte ptr l_28F9,1   ; 1=pero je zvednuto
                mov     al,1                ; absolutn¡ adresov n¡
                push    ax
                push    word ptr [bp-2]     ; sou©adnice st©edu Y
                push    word ptr [bp-4]
                push    word ptr [bp-6]     ; sou©adnice st©edu X
                push    word ptr [bp-8]
                call    l_1979              ; p©esun pera na zadanou pozici
;*              add     sp,0Ah
                db       83h,0C4h, 0Ah
                mov     sp,bp
                pop     bp
                pop     di
                pop     si
                retn
l_0E8D      endp

;==========================================================================
;        posun sou©adnic pera relativnˆ (nebo absolutnˆ)
;==========================================================================

l_1016      proc    near

                push    si
                push    di
                push    bp
                mov     bp,sp
;*              sub     sp,6
                db       83h,0ECh, 06h

                mov     si,1                ; SI <- 1 p©¡rustek X
                mov     di,si               ; DI <- 1 p©¡rustek Y
                cmp     byte ptr [bp+10h],0 ; je absolutn¡ adresa ?
                jne     l_1051              ; je absolutn¡ adresa

; ----- nov  sou©adnice X

                mov     dx,[bp+0Ah]         ; po‘adovan˜ posun ve smˆru X
                mov     ax,[bp+8]
                add     ax,l_2A03           ; aktu ln¡ pozice X (LOW)
                adc     dx,l_2A05           ; aktu ln¡ pozice X (HIGH)
                mov     [bp+0Ah],dx         ; nov  pozice ve smˆru X
                mov     [bp+8],ax

; ----- nov  sou©adnice Y

                mov     dx,[bp+0Eh]         ; po‘adovan˜ posun ve smˆru Y
                mov     ax,[bp+0Ch]
                add     ax,l_29DC           ; aktu ln¡ pozice Y (LOW)
                adc     dx,l_29DE           ; aktu ln¡ pozice Y (HIGH)
                mov     [bp+0Eh],dx
                mov     [bp+0Ch],ax

; ------ ulo‘en¡ nov‚ sou©adnice X

l_1051:         mov     dx,[bp+0Ah]         ; pozice X
                mov     ax,[bp+8]
                mov     l_2A05,dx           ; aktu ln¡ pozice X (HIGH)
                mov     l_2A03,ax           ; aktu ln¡ pozice X (LOW)

; ----- ulo‘en¡ nov‚ sou©adnice Y

                mov     dx,[bp+0Eh]         ; pozice Y
                mov     ax,[bp+0Ch]
                mov     l_29DE,dx           ; aktu ln¡ pozice Y (HIGH)
                mov     l_29DC,ax           ; aktu ln¡ pozice Y (LOW)

; ----- posun ve smˆru X

                mov     dx,l_2A05           ; aktu ln¡ pozice X (HIGH)
                mov     ax,l_2A03           ; aktu ln¡ pozice X (LOW)
                sub     ax,l_290B           ; skute‡n  pozice zapisova‡e X (LOW)
                sbb     dx,l_290D           ; skute‡n  pozice zapisova‡e X (HIGH)
                mov     [bp+0Ah],dx         ; posun X
                mov     [bp+8],ax

; ----- posun ve smˆru Y

                mov     dx,l_29DE           ; aktu ln¡ pozice Y (HIGH)
                mov     ax,l_29DC           ; aktu ln¡ pozice Y (LOW)
                sub     ax,l_2924           ; skute‡n  pozice zapisova‡e Y (LOW)
                sbb     dx,l_2926           ; skute‡n  pozice zapisova‡e Y (HIGH)
                mov     [bp+0Eh],dx         ; posun Y
                mov     [bp+0Ch],ax

                cmp     byte ptr l_28FF,0   ; 1=p©¡znak oto‡en¡
                je      l_10F1              ; nen¡ oto‡en¡

; ----- je oto‡en¡ X a Y

                mov     byte ptr [bp-1],3Ah ;

; ------ test, zda je posun X z porn˜

                cmp     word ptr [bp+0Ah],0 ; posun X
                jg      l_10C8
                jl      l_10AE              ; posun X je z porn˜
                cmp     word ptr [bp+8],0
                jae     l_10C8

; ----- posun X je z porn˜

l_10AE:         sub     byte ptr [bp-1],2   ; <- 38h posun X z porn˜
                mov     dx,[bp+0Ah]
                mov     ax,[bp+8]
                neg     dx
                neg     ax                  ; negace posunu
;*              sbb     dx,0                ; posun DX, pokud AX nebylo = 0
                db       83h,0DAh, 00h
                mov     [bp+0Ah],dx         ; absolutn¡ hodnota posunu X
                mov     [bp+8],ax
                mov     si,0FFFFh           ; p©¡rustek X = -1

; ------ test, zda je posun Y z porn˜

l_10C8:         cmp     word ptr [bp+0Eh],0 ; posun Y
                jg      l_10EF
                jl      l_10D6
                cmp     word ptr [bp+0Ch],0
                jae     l_10EF

; ------ posun Y je z porn˜

l_10D6:         inc     byte ptr [bp-1]     ; <- 3Bh, 39h posun Y z porn˜
                mov     dx,[bp+0Eh]
                mov     ax,[bp+0Ch]
                neg     dx
                neg     ax
;*              sbb     dx,0
                db       83h,0DAh, 00h
                mov     [bp+0Eh],dx         ; absolutn¡ hodnota posunu Y
                mov     [bp+0Ch],ax
                mov     di,0FFFFh           ; p©¡rustek Y = -1
l_10EF:         jmp     short l_1144

; ------ nen¡ oto‡en¡ X a Y

l_10F1:         mov     byte ptr [bp-1],38h ; posun X i Y kladn˜, 1 znak na X i Y

; ------ test, zda je posun X z porn˜

                cmp     word ptr [bp+0Ah],0 ; posun X
                jg      l_111C
                jl      l_1103
                cmp     word ptr [bp+8],0
                jae     l_111C

; ------ posun X je z porn˜

l_1103:         inc     byte ptr [bp-1]     ; bit 0: 1=posun X je z porn˜
                mov     dx,[bp+0Ah]
                mov     ax,[bp+8]
                neg     dx
                neg     ax
;*              sbb     dx,0
                db       83h,0DAh, 00h
                mov     [bp+0Ah],dx         ; absolutn¡ hodnota posunu X
                mov     [bp+8],ax
                mov     si,0FFFFh           ; p©¡rustek X = -1

; ------ test, zda je posun Y z porn˜

l_111C:         cmp     word ptr [bp+0Eh],0 ; posun Y
                jg      l_1144
                jl      l_112A
                cmp     word ptr [bp+0Ch],0
                jae     l_1144

; ------ posun Y je z porn˜

l_112A:         add     byte ptr [bp-1],2   ; bit 1: 1=posun Y je z porn˜
                mov     dx,[bp+0Eh]
                mov     ax,[bp+0Ch]
                neg     dx
                neg     ax
;*              sbb     dx,0
                db       83h,0DAh, 00h
                mov     [bp+0Eh],dx         ; absolutn¡ hodnota p©¡rustku Y
                mov     [bp+0Ch],ax
                mov     di,0FFFFh           ; p©¡rustek Y = -1

; ------ zarovn n¡ posunu X na sudou hodnotu

l_1144:         mov     dx,[bp+0Ah]         ; posun X
                mov     ax,[bp+8]
                and     ax,0FFFEh           ; zarovn n¡ na sudou hodnotu
;*              and     dx,0FFFFh
                db       81h,0E2h,0FFh,0FFh
                mov     [bp+0Ah],dx
                mov     [bp+8],ax

; ------ zarovn n¡ posunu Y na sudou hodnotu

                mov     dx,[bp+0Eh]         ; posun Y
                mov     ax,[bp+0Ch]
                and     ax,0FFFEh           ; zarovn n¡ na sudou hodnotu
;*              and     dx,0FFFFh
                db       81h,0E2h,0FFh,0FFh
                mov     [bp+0Eh],dx
                mov     [bp+0Ch],ax

; ----- stanoven¡ nov‚ skute‡n‚ sou©adnice X

                mov     ax,si               ; smˆr X
                cwd                         ; DX:AX <- p©¡rustek X
                mov     cx,[bp+0Ah]         ; posun X
                mov     bx,[bp+8]
                calls   far ptr l_1E5D      ; vyn soben¡ znam‚nkem
                add     ax,l_290B           ; skute‡n  pozice zapisova‡e X (LOW)
                adc     dx,l_290D           ; skute‡n  pozice zapisova‡e X (HIGH)
                mov     l_290D,dx           ; skute‡n  pozice zapisova‡e X (HIGH)
                mov     l_290B,ax           ; skute‡n  pozice zapisova‡e X (LOW)

; ------ stanoven¡ nov‚ skute‡n‚ sou©adnice Y

                mov     ax,di               ; smˆr Y
                cwd
                mov     cx,[bp+0Eh]         ; posun Y
                mov     bx,[bp+0Ch]
                calls   far ptr l_1E5D      ; vyn soben¡ znam‚nkem
                add     ax,l_2924           ; skute‡n  pozice zapisova‡e Y (LOW)
                adc     dx,l_2926           ; skute‡n  pozice zapisova‡e Y (HIGH)
                mov     l_2926,dx           ; skute‡n  pozice zapisova‡e Y (HIGH)
                mov     l_2924,ax           ; skute‡n  pozice zapisova‡e Y (LOW)

; ----- posun X / 2

                mov     dx,[bp+0Ah]         ; posun X
                mov     ax,[bp+8]
                mov     cx,1
                calls   far ptr l_1E37      ; rotace DX:AX o CL bit– vpravo
                mov     [bp+0Ah],dx         ; posun X / 2
                mov     [bp+8],ax

; ----- posun Y / 2

                mov     dx,[bp+0Eh]         ; posun Y
                mov     ax,[bp+0Ch]
                mov     cx,1
                calls   far ptr l_1E37      ; rotace DX:AX o CL bit– vpravo
                mov     [bp+0Eh],dx         ; posun Y / 2
                mov     [bp+0Ch],ax

; ----- test, zda je okno platn‚

                cmp     byte ptr l_2904,0   ; 1=okno je platn‚ (0=neplatn‚ ZOOM)
                jne     l_11D6              ; okno je platn‚ OK
                jmp     l_125E              ; okno neplatn‚

; ----- p©epo‡et mˆ©¡tka ZOOM sou©adnice X

                                          ;* vyn soben¡ POSUN X * ¨¡©ka ZOOM X
l_11D6:         push    l_2915              ; ¨¡©ka okna X (HIGH)
                push    l_2913              ; ¨¡©ka okna X (LOW)
                mov     dx,[bp+0Ah]         ; posun X
                mov     ax,[bp+8]
                mov     cx,l_29F1           ; ¨¡©ka okna X ZOOM (HIGH)
                mov     bx,l_29EF           ; ¨¡©ka okna X ZOOM (LOW)
                calls   far ptr l_1E5D      ; vyn soben¡ ‡¡sel
                push    dx                  ; ¨¡©ka okna X ZOOM * posun X
                push    ax

                                          ;* sou©adnice X st©edu okna
                xor     dx,dx
                mov     ax,2
                push    dx
                push    ax
                push    l_2915              ; ¨¡©ka okna X (HIGH)
                push    l_2913              ; ¨¡©ka okna X (LOW)
                calls   far ptr l_1DA9      ; vydˆlen¡ ‡¡sel / 2
                pop     bx
                pop     cx
                add     bx,ax               ; sou©adnice X
                adc     cx,dx

                                          ;* posun X p©epo‡¡tan˜ na ZOOM
                push    cx
                push    bx
                calls   far ptr l_1DA9      ; vydˆlen¡ ‡¡sel
                mov     [bp+0Ah],dx         ; p©epo‡¡tan˜ p©¡rustek X
                mov     [bp+8],ax

; ------ p©epo‡et mˆ©¡tka ZOOM sou©adnice Y

                                          ;* vyn soben¡ POSUN Y * ¨¡©ka ZOOM Y
                push    l_2922              ; v˜¨ka okna Y (HIGH)
                push    l_2920              ; v˜¨ka okna Y (LOW)
                mov     dx,[bp+0Eh]         ; posun Y
                mov     ax,[bp+0Ch]
                mov     cx,l_29E5           ; v˜¨ka okna Y ZOOM (HIGH)
                mov     bx,l_29E3           ; v˜¨ka okna Y ZOOM (LOW)
                calls   far ptr l_1E5D      ; vyn soben¡ ‡¡sel
                push    dx                  ; v˜¨ka okna Y ZOOM * posun Y
                push    ax

                                          ;* sou©adnice Y st©edu okna
                xor     dx,dx
                mov     ax,2
                push    dx
                push    ax
                push    l_2922              ; v˜¨ka okna Y (HIGH)
                push    l_2920              ; v˜¨ka okna Y (LOW)
                calls   far ptr l_1DA9      ; vydˆlen¡ ‡¡sel
                pop     bx
                pop     cx
                add     bx,ax
                adc     cx,dx

                                          ;* posun Y p©epo‡¡tan˜ na ZOOM
                push    cx
                push    bx
                calls   far ptr l_1DA9      ; vydˆlen¡ ‡¡sel
                mov     [bp+0Eh],dx         ; p©epo‡¡tan˜ p©¡rustek Y
                mov     [bp+0Ch],ax

; ------ z mˆna sou©adnic X a Y p©i oto‡en¡ okna

l_125E:         cmp     byte ptr l_28FF,0   ; 1=p©¡znak oto‡en¡
                je      l_1289              ; nen¡ oto‡en¡
                mov     dx,[bp+0Ah]         ; posun X
                mov     ax,[bp+8]
                mov     [bp-4],dx           ; £schova X
                mov     [bp-6],ax
                mov     dx,[bp+0Eh]         ; posun Y
                mov     ax,[bp+0Ch]
                mov     [bp+0Ah],dx         ; X <- Y
                mov     [bp+8],ax
                mov     dx,[bp-4]
                mov     ax,[bp-6]
                mov     [bp+0Eh],dx         ; Y <- X
                mov     [bp+0Ch],ax

; ------ test, zda posun X i Y lze zadat 1 znakem (mus¡ b˜t men¨¡ ne‘ 64)

l_1289:         cmp     word ptr [bp+0Ah],0
                jg      l_12CD
                jl      l_1297
                cmp     word ptr [bp+8],40h ; je posun vˆt¨¡ ne‘ 64 ?
                jae     l_12CD              ; posun je vˆt¨¡ ne‘ 64

l_1297:         cmp     word ptr [bp+0Eh],0
                jg      l_12CD
                jl      l_12A5
                cmp     word ptr [bp+0Ch],40h
                jae     l_12CD

; ------ posun X i Y zad n 1 znakem

l_12A5:         mov     al,[bp-1]           ; p©ipraven˜ povel pro posun
                mov     bx,offset l_2A0B    ; buffer jednoho p©¡kazu
                mov     [bx],al             ; povel pro posun

                mov     al,[bp+8]           ; po‘adovan˜ posun ve smˆru X
;*              add     al,20h
                db       80h,0C0h, 20h
                mov     bx,offset l_2A0B+1
                mov     [bx],al             ; posun ve smˆru X

                mov     al,[bp+0Ch]         ; po‘adovan˜ posun ve smˆru Y
;*              add     al,20h                  ; ' '
                db       80h,0C0h, 20h
                mov     bx,offset l_2A0B+2
                mov     [bx],al             ; posun ve smˆru Y

                mov     ax,3                ; 3 bajty
                push    ax
                call    l_1945              ; ulo‘en¡ povelu do bufferu
                pop     cx
                jmp     short l_1300

; ----- posun X i Y zad n 3 znaky

                                          ;* povel pro 3 znaky
l_12CD:         mov     al,[bp-1]
;*              add     al,0F8h             ; povel 30h ...
                db       80h,0C0h,0F8h
                mov     bx,offset l_2A0B    ; buffer jednoho p©¡kazu
                mov     [bx],al             ; povel

                                          ;* dek¢dov n¡ posunu X (3 znaky)
                mov     ax,1                ; offset
                push    ax
                push    word ptr [bp+0Ah]   ; posun X
                push    word ptr [bp+8]
                call    l_17A5              ; dek¢dov n¡ ‡¡sla na intern¡ tvar
;*              add     sp,6
                db       83h,0C4h, 06h

                                          ;* dek¢dov n¡ posunu Y (3 znaky)
                mov     ax,4                ; offset
                push    ax
                push    word ptr [bp+0Eh]   ; posun Y
                push    word ptr [bp+0Ch]
                call    l_17A5              ; dek¢dov n¡ ‡¡sla na intern¡ tvar
;*              add     sp,6
                db       83h,0C4h, 06h

                                          ;* ulo‘en¡ povelu do bufferu (7 znak–)
                mov     ax,7
                push    ax
                call    l_1945              ; ulo‘en¡ povelu do bufferu
                pop     cx

l_1300:         mov     sp,bp
                pop     bp
                pop     di
                pop     si
                retn

l_1016      endp

;==========================================================================
;        nastaven¡ v˜choz¡ pozice HOME
;==========================================================================

l_1306      proc    near
                mov     byte ptr l_28F9,1   ; 1=pero je zvednuto
                mov     al,1
                push    ax                  ; 1=absolutn¡ pozice
                xor     ax,ax
                push    ax                  ; pozice 0
                push    ax
                push    ax
                push    ax
                call    l_1979              ; p©esun pera na zadanou pozici
;*              add     sp,0Ah
                db       83h,0C4h, 0Ah

                mov     al,0
                push    ax                  ; relativn¡ pozice
                mov     dx,l_29F7
                mov     ax,l_29F5
                neg     dx
                neg     ax
;*              sbb     dx,0
                db       83h,0DAh, 00h
                push    dx
                push    ax
                mov     dx,l_2A09
                mov     ax,l_2A07
                neg     dx
                neg     ax
;*              sbb     dx,0
                db       83h,0DAh, 00h
                push    dx
                push    ax
                call    l_1016              ; posun sou©adnic pera relativnˆ
;*              add     sp,0Ah
                db       83h,0C4h, 0Ah

                call    l_1AB1              ; vypr zdnˆn¡ buffer–
                mov     l_2926,0            ; skute‡n  pozice zapisova‡e Y (HIGH)
                mov     l_2924,0            ; skute‡n  pozice zapisova‡e Y (LOW)
                xor     dx,dx
                mov     ax,dx
                mov     l_290D,dx           ; skute‡n  pozice zapisova‡e X (HIGH)
                mov     l_290B,ax           ; skute‡n  pozice zapisova‡e X (LOW)
                mov     l_29DE,dx           ; aktu ln¡ pozice Y (HIGH)
                mov     l_29DC,ax           ; aktu ln¡ pozice Y (LOW)
                mov     l_2A05,dx           ; aktu ln¡ pozice X (HIGH)
                mov     l_2A03,ax           ; aktu ln¡ pozice X (LOW)
                mov     l_29F7,ax           ; pozice po‡ tku X (LOW)
                mov     l_29F5,ax
                mov     dx,ax
                mov     l_2A09,dx
                mov     l_2A07,ax
                retn
l_1306      endp


;==========================================================================
;        v˜stup textu
;==========================================================================
;þ
l_137B      proc    near

                push    si
                push    di
                push    bp
                mov     bp,sp
;*              sub     sp,2Eh
                db       83h,0ECh, 2Eh
                mov     word ptr [bp-20h],0

; ------ p©¡prava ukazatele pozice (pro n vrat na za‡ tek © dku)

                mov     dx,l_2A05           ; aktu ln¡ pozice X (HIGH)
                mov     ax,l_2A03           ; aktu ln¡ pozice X (LOW)
                mov     [bp-10h],dx         ; ukazatel pozice X (HIGH)
                mov     [bp-12h],ax         ; ukazatel pozice X (LOW)

                mov     dx,l_29DE           ; aktu ln¡ pozice Y (HIGH)
                mov     ax,l_29DC           ; aktu ln¡ pozice Y (LOW)
                mov     [bp-0Ch],dx         ; ukazatel pozice Y (HIGH)
                mov     [bp-0Eh],ax         ; ukazatel pozice Y (LOW)

; ------ smˆrnice textu X^2

                mov     ax,word ptr ds:[29F3h] ; smˆrnice textu X
                cwd
                push    dx
                push    ax
                cwd
                pop     bx
                pop     cx
                calls   far ptr l_1E5D      ; vyn soben¡ ‡¡sel (smˆrnice X*X)
                push    dx
                push    ax

; ------ smˆrnice textu Y^2

                mov     ax,word ptr l_2907  ; smˆrnice textu Y
                cwd
                push    dx
                push    ax
                cwd
                pop     bx
                pop     cx
                calls   far ptr l_1E5D      ; vyn soben¡ ‡¡sel (smˆrnice Y*Y)

; ------ sou‡et X*X + Y*Y

                pop     bx
                pop     cx
                add     bx,ax               ; sou‡et X*X + Y*Y
                adc     cx,dx

; ------ v˜po‡et odmocniny - d‚lka smˆrn¡ku

                push    cx
                push    bx
                call    l_19C1              ; odmocnina ‡¡sla
                pop     cx
                pop     cx
                mov     [bp-2Ch],ax         ; d‚lka smˆrn¡ku
                cwd
                push    dx                  ; d‚lka smˆrn¡ku
                push    ax

; ------ smˆrnice Y * 10000

                mov     ax,word ptr l_2907  ; smˆrnice textu Y
                cwd
                xor     cx,cx
                mov     bx,10000
                calls   far ptr l_1E5D      ; vyn soben¡ ‡¡sel
                push    dx                  ; smˆrnice Y * 10000
                push    ax

; ------ smˆrnice Y * 10000 * oprava odmocniny

                mov     ax,l_28FB           ; vydˆlen¡ v˜sledku odmocniny
                cwd
                pop     bx                  ; smˆrnice Y * 10000
                pop     cx
                calls   far ptr l_1E5D      ; vyn soben¡ ‡¡sel

; ------ smˆrnice Y * 10000 * oprava odmocniny / d‚lka smˆrn¡ku -> p©¡rustek Y

                push    dx                  ; smˆrnice Y * 10000 * oprava odmocniny
                push    ax
                calls   far ptr l_1DA9      ; vydˆlen¡ ‡¡sel
                mov     [bp-24h],ax         ; p©¡rustek Y se smˆrn¡kem

; ----- smˆrnice X * 10000

                mov     ax,[bp-2Ch]         ; d‚lka smˆrn¡ku
                cwd
                push    dx                  ; d‚lka smˆrn¡ku
                push    ax
                mov     ax,word ptr ds:[29F3h] ; smˆrnice textu X
                cwd
                xor     cx,cx
                mov     bx,10000
                calls   far ptr l_1E5D      ; vyn soben¡ ‡¡sel

; ------ smˆrnice X * 10000 * oprava odmocniny

                push    dx                  ; smˆrnice X * 10000
                push    ax
                mov     ax,l_28FB           ; vydˆlen¡ v˜sledku odmocniny
                cwd
                pop     bx                  ; smˆrnice X * 10000
                pop     cx
                calls   far ptr l_1E5D      ; vyn soben¡ ‡¡sel

; ------ smˆrnice X * 10000 * oprava odmocniny / d‚lka smˆrn¡ku -> p©¡rustek X

                push    dx                  ; smˆrnice X * 10000 * oprava odmocniny
                push    ax
                calls   far ptr l_1DA9      ; vydˆlen¡ ‡¡sel
                mov     [bp-22h],ax         ; p©¡rustek X se smˆrn¡kem

; ----- test, zda se budou prov dˆt p©epo‡ty p¡sma

                cmp     byte ptr l_29DB,0   ; 1=p©¡znak p¡sma Italic
                jne     l_1438              ; je p¡smo Italic
                cmp     word ptr l_2907,0   ; smˆrnice textu Y
                jne     l_1438              ;
                cmp     word ptr ds:[29F3h],0 ; smˆrnice textu X
                jge     l_143C

l_1438:         mov     al,1
                jmp     short l_143E
l_143C:         mov     al,0
l_143E:         mov     [bp-1],al           ; p©¡znak p©epo‡t–

; ----- v˜po‡et n sobku krokov n¡ p¡smen

                mov     ax,l_28FD           ; ¨¡©ka znaku (krok–)
                add     ax,11               ; zaokrouhlen¡ nahoru
                mov     bx,12               ; ¨¡©ka p¡smene (bod–)
                cwd
                idiv    bx
                cwd
                mov     [bp-1Ch],dx         ; po‡et krok– na krok p¡smene
                mov     [bp-1Eh],ax

; ------ test, zda je dal¨¡ znak k v˜stupu

l_1454:         mov     al,l_29E0           ; znak k vysl n¡ od DOS
                cmp     al,l_2905           ; znak ozna‡uj¡c¡ konec ASCII textu
                jne     l_1460              ; nen¡ je¨tˆ konec textu
                jmp     l_1704              ; nen¡ dal¨¡ znak

; ----- n vrat ukazatele na za‡ tek © dku

l_1460:         cmp     byte ptr l_29E0,0Dh ; znak k vysl n¡ od DOS
                jne     l_1497
                mov     al,1
                push    ax
                push    word ptr [bp-0Ch]   ; uschovan˜ po‡ tek © dku
                push    word ptr [bp-0Eh]
                push    word ptr [bp-10h]
                push    word ptr [bp-12h]
                call    l_1979              ; p©esun pera na zadanou pozici
;*              add     sp,0Ah
                db       83h,0C4h, 0Ah

                mov     word ptr [bp-20h],0
                mov     ax,l_28FD           ; ¨¡©ka znaku (krok–)
                add     ax,11
                mov     bx,12
                cwd
                idiv    bx
                cwd
                mov     [bp-1Ch],dx
                mov     [bp-1Eh],ax
                jmp     l_16FE

; ----- p©esun ukazatele na dal¨¡ © dek

l_1497:         cmp     byte ptr l_29E0,0Ah ; znak k vysl n¡ od DOS
                je      l_14A1
                jmp     l_153C

l_14A1:         mov     ax,[bp-2Ch]         ; d‚lka smˆrn¡ku
                cwd
                push    dx
                push    ax
                mov     ax,l_2979           ; v˜¨ka znaku (krok–)
                cwd
                push    dx
                push    ax
                mov     ax,word ptr l_2907  ; smˆrnice textu Y
                cwd
                pop     bx
                pop     cx
                calls   far ptr l_1E5D      ; vyn soben¡: v˜¨ka znak–*smˆrn¡k Y
                push    dx
                push    ax
                mov     ax,l_28FB           ; vydˆlen¡ v˜sledku odmocniny
                cwd
                pop     bx
                pop     cx
                calls   far ptr l_1E5D      ; vyn soben¡ ‡¡sel
                push    dx
                push    ax
                calls   far ptr l_1DA9      ; vydˆlen¡ ‡¡sel
                mov     [bp-28h],ax

                mov     ax,[bp-2Ch]
                cwd
                push    dx
                push    ax
                mov     ax,l_2979           ; v˜¨ka znaku (krok–)
                cwd
                push    dx
                push    ax
                mov     ax,word ptr ds:[29F3h] ; smˆrnice textu X
                cwd
                pop     bx
                pop     cx
                calls   far ptr l_1E5D      ; vyn soben¡ ‡¡sel
                push    dx
                push    ax
                mov     ax,l_28FB           ; vydˆlen¡ v˜sledku odmocniny
                cwd
                pop     bx
                pop     cx
                calls   far ptr l_1E5D      ; vyn soben¡ ‡¡sel
                neg     dx
                neg     ax
;*              sbb     dx,0
                db       83h,0DAh, 00h
                push    dx
                push    ax
                calls   far ptr l_1DA9      ; vydˆlen¡ ‡¡sel
                mov     [bp-26h],ax

                mov     al,0
                push    ax
                mov     ax,[bp-26h]
                cwd
                push    dx
                push    ax
                mov     ax,[bp-28h]
                cwd
                push    dx
                push    ax
                call    l_1979              ; p©esun pera na zadanou pozici
;*              add     sp,0Ah
                db       83h,0C4h, 0Ah
                mov     ax,[bp-28h]
                cwd
                add     ax,[bp-12h]
                adc     dx,[bp-10h]
                mov     [bp-10h],dx
                mov     [bp-12h],ax
                mov     ax,[bp-26h]
                cwd
                add     ax,[bp-0Eh]
                adc     dx,[bp-0Ch]
                mov     [bp-0Ch],dx
                mov     [bp-0Eh],ax
                jmp     l_16FE

; ----- povoleny pouze znaky 32 a‘ 127

l_153C:         cmp     byte ptr l_29E0,20h ; znak k vysl n¡ od DOS ; ' '
                jae     l_1546
                jmp     l_16FE

l_1546:         cmp     byte ptr l_29E0,7Fh ; znak k vysl n¡ od DOS
                jbe     l_1550
                jmp     l_16FE

; ------ p©¡prava znaku k dek¢dov n¡

l_1550:         mov     al,l_29E0           ; znak k vysl n¡ od DOS
                mov     ah,0
                add     ax,0FFE0h           ; offset znaku (znak - 32)
                mov     [bp-2Eh],ax         ; offset znaku v tabulce znak–
                mov     si,offset l_2294    ; tabulka znak–
                jmp     short l_156C

; ------ nalezen¡ definice po‘adovan‚ho znaku

l_1560:         mov     al,[si]             ; d‚lka definice znaku
                mov     ah,0
                mov     dx,2
                mul     dx                  ; * 2
                inc     ax                  ; v‡etnˆ bajtu d‚lky
                add     si,ax               ; adresa dal¨¡ho znaku
l_156C:         mov     ax,[bp-2Eh]         ; znak k dek¢dov n¡
                dec     word ptr [bp-2Eh]   ; sn¡‘en¡ ‡¡sla znaku
                or      ax,ax               ; nalezen znak ?
                jnz     l_1560              ; nen¡ po‘adovan˜ znak - dal¨¡

; ----- p©¡prava k dek¢dov n¡ znaku

                mov     al,[si]             ; d‚lka definice znaku
                mov     ah,0
                mov     [bp-2Eh],ax         ; ‡¡ta‡ d‚lky definice znaku
                inc     si                  ; adresa definice znaku
                jmp     l_16E2

; -----

l_1581:         mov     al,[si]             ; vodorovn˜ posun pera
                mov     ah,0
                mov     di,ax
                inc     si
                mov     al,[si]             ; svisl˜ posun pera
                mov     ah,0
                mov     [bp-2Ah],ax         ; svisl˜
                inc     si

; ------- p©¡prava povelu pro nastaven¡ pera

;*              cmp     di,7Fh              ; m  b˜t pero spu¨tˆno ?
                db       83h,0FFh, 7Fh
                jle     l_1599              ; pero m  b˜t spu¨tˆno
                mov     al,23h              ; povel pro zvednut¡ pera
                jmp     short l_159B
l_1599:         mov     al,22h              ; povel pro spu¨tˆn¡ pera
l_159B:         mov     [bp-2],al           ; povel pro nastaven¡ pera

                xor     dx,dx
                mov     ax,300h
                push    dx
                push    ax

; ------ vodorovn˜ posun pera

                mov     ax,di
                and     ax,7Fh
                cwd
                push    dx
                push    ax
                mov     ax,l_28FD           ; ¨¡©ka znaku (krok–)
                cwd
                pop     bx
                pop     cx
                calls   far ptr l_1E5D      ; vyn soben¡ ‡¡sel

; ------ vodorovn˜ posun * 5/300h (tj. /153.6)

                xor     cx,cx
                mov     bx,5
                calls   far ptr l_1E5D      ; vyn soben¡ ‡¡sel
                push    dx
                push    ax
                calls   far ptr l_1DA9      ; vydˆlen¡ ‡¡sel
                mov     di,ax               ; DI <- vodorovn˜ posun


                xor     dx,dx
                mov     ax,80h
                push    dx
                push    ax
                mov     ax,[bp-2Ah]         ; svisl˜ posun pera
                cwd

; ------ svisl˜ posun pera

                push    dx
                push    ax
                mov     ax,l_2979           ; v˜¨ka znaku (krok–)
                cwd
                pop     bx
                pop     cx
                calls   far ptr l_1E5D      ; vyn soben¡ ‡¡sel

; ------ svisl˜ posun / 80h

                push    dx
                push    ax
                calls   far ptr l_1DA9      ; vydˆlen¡ ‡¡sel
                mov     [bp-2Ah],ax         ; svisl˜ posun

; ------ test, jestli se dˆl  ze¨ikmen¡

                cmp     byte ptr [bp-1],0
                jne     l_15F6
                jmp     l_1695

; ----- ze¨ikmen¡ p¡sma

l_15F6:         cmp     byte ptr l_29DB,0   ; 1=p©¡znak p¡sma Italic
                je      l_1608              ; nen¡ Italic
                mov     bx,5
                cwd
                idiv    bx                  ; svisl˜ posun / 5
                add     ax,[bp-1Eh]         ; + horizont ln¡ pozice
                jmp     short l_160B

l_1608:         mov     ax,[bp-1Eh]         ; horizont ln¡ pozice

l_160B:         add     di,ax               ; oprava vodorovn‚ho posunu

; ------ vodorovn˜ p©¡rustek X

                xor     dx,dx
                mov     ax,10000
                push    dx
                push    ax
                mov     ax,di               ; vodorovn˜ posun
                cwd
                push    dx
                push    ax
                mov     ax,[bp-22h]         ; p©¡rustek X se smˆrn¡kem
                cwd
                pop     bx
                pop     cx
                calls   far ptr l_1E5D      ; vyn soben¡ ‡¡sel
                push    dx
                push    ax

; ------ svisl˜ p©¡rustek Y

                mov     ax,[bp-2Ah]         ; svisl˜ posun
                cwd
                push    dx
                push    ax
                mov     ax,[bp-24h]         ; p©¡rustek Y se smˆrn¡kem
                cwd
                pop     bx
                pop     cx
                calls   far ptr l_1E5D      ; vyn soben¡ ‡¡sel

; ------ skute‡n˜ p©¡rustek X (p©¡rustek X - p©¡rustek Y) / 10000

                pop     bx                  ; p©¡rustek X
                pop     cx

                sub     bx,ax               ; p©¡rustek X - p©¡rustek Y
                sbb     cx,dx
                push    cx
                push    bx
                calls   far ptr l_1DA9      ; vydˆlen¡ ‡¡sel
                add     ax,[bp-12h]         ; pozice X za‡ tku © du
                adc     dx,[bp-10h]
                mov     [bp-18h],dx
                mov     [bp-1Ah],ax         ; posun X

; ----- svisl˜ p©¡rustek X

                xor     dx,dx
                mov     ax,10000
                push    dx
                push    ax
                mov     ax,[bp-2Ah]         ; svisl˜ posun
                cwd
                push    dx
                push    ax
                mov     ax,[bp-22h]         ; p©¡rustek X se smˆrn¡kem
                cwd
                pop     bx
                pop     cx
                calls   far ptr l_1E5D      ; vyn soben¡ ‡¡sel

; ----- vodorovn˜ p©¡rustek Y

                push    dx
                push    ax
                mov     ax,di               ; vodorovn˜ posun
                cwd
                push    dx
                push    ax
                mov     ax,[bp-24h]         ; p©¡rustek Y se smˆrn¡kem
                cwd
                pop     bx
                pop     cx
                calls   far ptr l_1E5D      ; vyn soben¡ ‡¡sel


; ------- skute‡n˜ p©¡rustek Y (p©¡rustek X + p©¡rustek Y) / 10000

                pop     bx
                pop     cx
                add     bx,ax
                adc     cx,dx
                push    cx
                push    bx
                calls   far ptr l_1DA9      ; vydˆlen¡ ‡¡sel

; ------ v˜sledn  pozice Y

                add     ax,[bp-0Eh]         ; + uschovan˜ po‡ tek © dku
                adc     dx,[bp-0Ch]
                mov     [bp-14h],dx         ; v˜sledn  pozice Y
                mov     [bp-16h],ax         ; promˆnn  SI
                jmp     short l_16BA

; ----- v˜po‡et posunu, nen¡-li se¨ikmen¡

l_1695:         mov     ax,di               ; vodorovn˜ posun
                cwd
                add     ax,[bp-12h]
                adc     dx,[bp-10h]
                add     ax,[bp-1Eh]
                adc     dx,[bp-1Ch]
                mov     [bp-18h],dx         ; posun X
                mov     [bp-1Ah],ax
                mov     ax,[bp-2Ah]         ; svisl˜ posun
                cwd
                add     ax,[bp-0Eh]
                adc     dx,[bp-0Ch]
                mov     [bp-14h],dx         ; posun Y
                mov     [bp-16h],ax         ; promˆnn  SI

; ------ spu¨tˆn¡/zvednut¡ pera

l_16BA:         mov     al,[bp-2]
                mov     bx,offset l_2A0B    ; buffer jednoho p©¡kazu
                mov     [bx],al
                mov     ax,1
                push    ax
                call    l_1945              ; ulo‘en¡ povelu do bufferu
                pop     cx

; ------ posun pera

                mov     al,1
                push    ax
                push    word ptr [bp-14h]   ; posun Y
                push    word ptr [bp-16h]
                push    word ptr [bp-18h]   ; posun X
                push    word ptr [bp-1Ah]
                call    l_1016              ; posun sou©adnic pera relativnˆ
;*              add     sp,0Ah
                db       83h,0C4h, 0Ah

; ----- p©¡prava k dal¨¡mu bodu

                dec     word ptr [bp-2Eh]   ; ‡¡ta‡ bod– znaku
l_16E2:         cmp     word ptr [bp-2Eh],0 ; jsou ji‘ v¨echny ?
                je      l_16EB              ; jsou ji‘ v¨echny
                jmp     l_1581              ; dal¨¡ bod

; ----- posun sou©adnice X

l_16EB:         mov     ax,l_28FD           ; ¨¡©ka znaku (krok–)
                cwd
                add     ax,[bp-1Eh]         ; posun sou©adnice
                adc     dx,[bp-1Ch]
                mov     [bp-1Ch],dx         ; nov  sou©adnice znaku
                mov     [bp-1Eh],ax
                inc     word ptr [bp-20h]   ; ‡¡ta‡ znak–

l_16FE:         call    l_00C1              ; ‡ek n¡ na dal¨¡ znak z DOS
                jmp     l_1454

l_137B      endp

; ------ nen¡ dal¨¡ znak

l_1704:         mov     ax,[bp-2Ch]         ; d‚lka smˆrn¡ku
                cwd
                push    dx
                push    ax
                mov     ax,l_28FD           ; ¨¡©ka znaku (krok–)
                cwd
                push    dx
                push    ax
                mov     ax,word ptr ds:[29F3h] ; smˆrnice textu X
                cwd
                pop     bx
                pop     cx
                calls   far ptr l_1E5D      ; vyn soben¡ ‡¡sel

                push    dx
                push    ax
                mov     ax,[bp-20h]
                cwd
                pop     bx
                pop     cx
                calls   far ptr l_1E5D      ; vyn soben¡ ‡¡sel


                push    dx
                push    ax
                mov     ax,l_28FB           ; vydˆlen¡ v˜sledku odmocniny
                cwd
                pop     bx
                pop     cx
                calls   far ptr l_1E5D      ; vyn soben¡ ‡¡sel


                push    dx
                push    ax
                calls   far ptr l_1DA9      ; vydˆlen¡ ‡¡sel
                add     ax,[bp-12h]
                adc     dx,[bp-10h]
                mov     [bp-8],dx
                mov     [bp-0Ah],ax
                mov     ax,[bp-2Ch]
                cwd
                push    dx
                push    ax
                mov     ax,l_28FD           ; ¨¡©ka znaku (krok–)
                cwd
                push    dx
                push    ax
                mov     ax,word ptr l_2907  ; smˆrnice textu Y
                cwd
                pop     bx
                pop     cx
                calls   far ptr l_1E5D      ; vyn soben¡ ‡¡sel
                push    dx
                push    ax
                mov     ax,[bp-20h]
                cwd
                pop     bx
                pop     cx
                calls   far ptr l_1E5D      ; vyn soben¡ ‡¡sel
                push    dx
                push    ax
                mov     ax,l_28FB           ; vydˆlen¡ v˜sledku odmocniny
                cwd
                pop     bx
                pop     cx
                calls   far ptr l_1E5D      ; vyn soben¡ ‡¡sel
                push    dx
                push    ax
                calls   far ptr l_1DA9      ; vydˆlen¡ ‡¡sel
                add     ax,[bp-0Eh]
                adc     dx,[bp-0Ch]
                mov     [bp-4],dx
                mov     [bp-6],ax
                mov     al,1
                push    ax
                push    dx
                push    word ptr [bp-6]
                push    word ptr [bp-8]
                push    word ptr [bp-0Ah]
                call    l_1979              ; p©esun pera na zadanou pozici
;*              add     sp,0Ah
                db       83h,0C4h, 0Ah
                mov     sp,bp
                pop     bp
                pop     di
                pop     si
                retn

;==========================================================================
;        dek¢dov n¡ ‡¡sla na intern¡ tvar zapisova‡e (3 znaky)
;==========================================================================

l_17A5      proc    near
                push    si
                push    bp
                mov     bp,sp
                mov     si,2                ; SI <- 2 po‡et znak– k dek¢dov n¡-1
                jmp     short l_17E5
l_17AE:
                xor     dx,dx
                mov     ax,40h
                push    dx
                push    ax
                push    word ptr [bp+8]
                push    word ptr [bp+6]
                calls   far ptr l_1DA1      ; vydˆlen¡ ‡¡sel
;*              add     al,20h                  ; ' '
                db       80h,0C0h, 20h
                mov     bx,[bp+0Ah]
                add     bx,si
                mov     l_2A0B[bx],al       ; buffer jednoho p©¡kazu

                xor     dx,dx
                mov     ax,40h
                push    dx
                push    ax
                push    word ptr [bp+8]
                push    word ptr [bp+6]
                calls   far ptr l_1DA9      ; vydˆlen¡ ‡¡sel
                mov     [bp+8],dx
                mov     [bp+6],ax
                dec     si
l_17E5:
                or      si,si
                jge     l_17AE
                pop     bp
                pop     si
                retn
l_17A5      endp

;==========================================================================
;        dek¢dov n¡ ‡¡sla na ASCII
;==========================================================================

l_17EC      proc    near

                push    si
                push    di
                push    bp
                mov     bp,sp
                mov     si,[bp+8]
                cmp     byte ptr [bp+10h],0
                je      l_1828
                cmp     word ptr [bp+0Eh],0
                jg      l_1822
                jl      l_1808
                cmp     word ptr [bp+0Ch],0
                jae     l_1822

                                          ;* z porn‚ znam‚nko
l_1808:          mov     byte ptr l_2929[si],2Dh ; '-' ; buffer p©ijat˜ch dat (pro DOS)
                mov     dx,[bp+0Eh]
                mov     ax,[bp+0Ch]
                neg     dx
                neg     ax
;*              sbb     dx,0
                db       83h,0DAh, 00h
                mov     [bp+0Eh],dx
                mov     [bp+0Ch],ax
                jmp     short l_1827

                                          ;* kladn‚ znam‚nko
l_1822:         mov     byte ptr l_2929[si],20h ; ' '
l_1827:         inc     si
l_1828:         mov     di,[bp+0Ah]
                dec     di
                jmp     short l_1864

                                          ;* dek¢dov n¡ jedn‚ ‡¡slice
l_182E:         xor     dx,dx
                mov     ax,10               ; dˆlitel
                push    dx
                push    ax
                push    word ptr [bp+0Eh]
                push    word ptr [bp+0Ch]
                calls   far ptr l_1DA1      ; vydˆlen¡ ‡¡sel
;*              add     al,30h                  ; '0'
                db       80h,0C0h, 30h
                mov     bx,si
                add     bx,di
                mov     l_2929[bx],al

                                          ;* posun ‡¡sla o © d
                xor     dx,dx
                mov     ax,0Ah
                push    dx
                push    ax
                push    word ptr [bp+0Eh]
                push    word ptr [bp+0Ch]
                calls   far ptr l_1DA9      ; vydˆlen¡ ‡¡sel
                mov     [bp+0Eh],dx
                mov     [bp+0Ch],ax
                dec     di

                                          ;* dal¨¡ ‡¡slice
l_1864:         or      di,di
                jge     l_182E

                                          ;* koncov˜ oddˆlova‡
                mov     bx,si
                add     bx,[bp+0Ah]
                mov     byte ptr l_2929[bx],2Ch ; ','
                pop     bp
                pop     di
                pop     si
                retn
l_17EC      endp

; -----------------------------------------------------------------------------
;        na‡ten¡ ‡¡sla
; -----------------------------------------------------------------------------

l_1876         proc    near

                push    si
                push    di
                push    bp
                mov     bp,sp
;*              sub     sp,4
                db       83h,0ECh, 04h

; ----- p©¡prava st©ada‡e ‡¡sla

                mov     di,1
                mov     word ptr [bp-2],0
                mov     word ptr [bp-4],0
                xor     si,si
                jmp     short l_1893

; ------ vypu¨tˆn¡ dan‚ho po‡tu znak–

l_188F:         call    l_00C1              ; ‡ek n¡ na dal¨¡ znak z DOS
                inc     si
l_1893:         cmp     si,[bp+8]
                jl      l_188F

; ----- vypu¨tˆn¡ oddˆlova‡– p©ed ‡¡slem

l_1898:         cmp     byte ptr l_29E0,20h ; znak k vysl n¡ od DOS ; ' '
                je      l_18A6
                cmp     byte ptr l_29E0,0Ah ; znak k vysl n¡ od DOS
                jne     l_18AB
l_18A6:         call    l_00C1              ; ‡ek n¡ na dal¨¡ znak z DOS
                jmp     short l_1898

; ------ rozli¨en¡ znam‚nka p©ed ‡¡slem

l_18AB:         cmp     byte ptr l_29E0,"+" ; znak k vysl n¡ od DOS
                je      l_18B9
                cmp     byte ptr l_29E0,"-" ; znak k vysl n¡ od DOS
                jne     l_18CB

l_18B9:         cmp     byte ptr l_29E0,"+" ; znak k vysl n¡ od DOS ; '+'
                jne     l_18C5
                mov     di,1                ; kladn‚ ‡¡slo
                jmp     short l_18C8

l_18C5:         mov     di,0FFFFh           ; z porn‚ ‡¡slo

; ------ na‡ten¡ dal¨¡ho znaku, pokud bylo znam‚nko

l_18C8:         call    l_00C1              ; ‡ek n¡ na dal¨¡ znak z DOS

; ------ test, zda je znak platn  ‡¡slice

l_18CB:         cmp     byte ptr l_29E0,"0" ; znak k vysl n¡ od DOS ; '0'
                jb      l_190B
                cmp     byte ptr l_29E0,"9" ; znak k vysl n¡ od DOS ; '9'
                ja      l_190B

; ------ vyn soben¡ st©ada‡e 10x

                xor     dx,dx
                mov     ax,10
                mov     cx,[bp-2]
                mov     bx,[bp-4]
                calls   far ptr l_1E5D      ; vyn soben¡ ‡¡sel

; ----- p©i‡ten¡ ‡¡sla ke st©ada‡i

                mov     bl,l_29E0           ; znak k vysl n¡ od DOS
                mov     bh,0
                push    dx
                push    ax
                mov     ax,bx
                cwd
                pop     bx
                pop     cx
                add     bx,ax
                adc     cx,dx
;*              add     bx,0FFD0h
                db       83h,0C3h,0D0h
;*              adc     cx,0FFFFh
                db       83h,0D1h,0FFh
                mov     [bp-2],cx
                mov     [bp-4],bx
                call    l_00C1              ; ‡ek n¡ na dal¨¡ znak z DOS
                jmp     short l_18CB

; ----- konec dek¢dov n¡ ‡¡sla - oprava znam‚nka

l_190B:         mov     ax,di               ; znam‚nko (n sobitel)
                cwd
                mov     cx,[bp-2]
                mov     bx,[bp-4]
                calls   far ptr l_1E5D      ; vyn soben¡ znam‚nkem

                mov     sp,bp
                pop     bp
                pop     di
                pop     si
                retn
l_1876      endp

; -----------------------------------------------------------------------------
;        ‡ek n¡ na oddˆlova‡ mezi ‡¡sly
; -----------------------------------------------------------------------------

l_191F      proc    near

                push    bp
                mov     bp,sp
l_1922:         mov     al,l_29E0           ; znak k vysl n¡ od DOS
                cmp     al,[bp+4]           ; je koncov˜ znak ?
                je      l_1943              ; je koncov˜ znak
                cmp     byte ptr l_29E0,0Ah ; znak k vysl n¡ od DOS
                je      l_1943
                cmp     byte ptr [bp+4],2Ch     ; ','
                jne     l_193E
                cmp     byte ptr l_29E0,20h ; znak k vysl n¡ od DOS ; ' '
                je      l_1943
l_193E:         call    l_00C1              ; ‡ek n¡ na dal¨¡ znak z DOS
                jmp     short l_1922

l_1943:         pop     bp
                retn
l_191F      endp

;==========================================================================
;        ulo‘en¡ povelu do bufferu
;==========================================================================

l_1945      proc    near

                push    si
                push    di
                push    bp
                mov     bp,sp

; ------ vypr zdnˆn¡ v˜stupn¡ho bufferu, je-li pln˜

                mov     di,[bp+8]           ; d‚lka textu povelu k vysl n¡
                mov     ax,l_29E1           ; po‡et znak– ve v˜stupn¡m bufferu
                add     ax,di
                cmp     ax,60h              ; je v˜stupn¡ buffer pln˜ ?
                jle     l_195A              ; d‚lka je OK
                call    l_1AB1              ; vypr zdnˆn¡ buffer–

; ------ p©¡prava k p©enesen¡ textu

l_195A:         xor     si,si
                jmp     short l_196D

; ------ p©enesen¡ textu do bufferu

l_195E:         mov     al,l_2A0B[si]       ; buffer jednoho p©¡kazu
                mov     bx,l_29E1           ; po‡et znak– ve v˜stupn¡m bufferu
                add     bx,si
                mov     byte ptr l_297B[bx],al ; ulo‘en¡ znaku do bufferu
                inc     si
l_196D:         cmp     si,di
                jl      l_195E
                add     l_29E1,di           ; po‡et znak– ve v˜stupn¡m bufferu

                pop     bp
                pop     di
                pop     si
                retn
l_1945      endp

;==========================================================================
;        p©esun pera na zadanou pozici (bez kreslen¡)
;==========================================================================

l_1979      proc    near

                push    bp
                mov     bp,sp

; ----- povel pro zvednut¡ pera

                mov     bx,offset l_2A0B    ; buffer jednoho p©¡kazu
                mov     byte ptr [bx],23h   ; povel pro zvednut¡ pera
                mov     ax,1
                push    ax
                call    l_1945              ; ulo‘en¡ povelu do bufferu
                pop     cx

                push    word ptr [bp+0Ch]
                push    word ptr [bp+0Ah]
                push    word ptr [bp+8]
                push    word ptr [bp+6]
                push    word ptr [bp+4]
                call    l_1016              ; posun sou©adnic pera relativnˆ

; ----- navr cen¡ pera

                mov     sp,bp
                call    l_19A3              ; vysl n¡ povelu pro nastaven¡ pera
                pop     bp
                retn
l_1979      endp

;==========================================================================
;        vysl n¡ povelu pro nastaven¡ pera
;==========================================================================

l_19A3      proc    near

                cmp     byte ptr l_28F9,0   ; 1=pero je zvednuto
                je      l_19B2              ; pero je spu¨tˆno
                mov     bx,2A0Bh            ; buffer jednoho p©¡kazu
                mov     byte ptr [bx],23h        ; zvednut¡ pera
                jmp     short l_19B8

l_19B2:         mov     bx,2A0Bh            ; buffer jednoho p©¡kazu
                mov     byte ptr [bx],22h   ; pero dol–

l_19B8:         mov     ax,1                ; d‚lka povelu - 1 znak
                push    ax
                call    l_1945              ; ulo‘en¡ povelu do bufferu
                pop     cx
                retn
l_19A3      endp

;==========================================================================
;        v˜po‡et odmocniny ‡¡sla
;==========================================================================
;þ
l_19C1      proc    near

                push    si
                push    bp
                mov     bp,sp
;*              sub     sp,8
                db       83h,0ECh, 08h
                mov     word ptr [bp-2],0   ; v˜sledek operace
                mov     word ptr [bp-4],0

; ----- test, zda je ‡¡slo vˆt¨¡ ne‘ 10000

                cmp     word ptr [bp+8],0
                jg      l_19FF              ; ‡¡slo dostate‡nˆ velk‚
                jl      l_19E1              ; ‡¡slo je z porn‚ (?!?)
                cmp     word ptr [bp+6],10000
                jae     l_19FF              ; ‡¡slo je dostate‡nˆ velk‚

; ------ vyn soben¡ mal‚ho (nebo z porn‚ho) ‡¡sla, aby bylo vˆt¨¡ ne‘ 10000

l_19E1:         mov     dx,[bp+8]
                mov     ax,[bp+6]
                xor     cx,cx
                mov     bx,10000            ; n sobek, aby bylo dost velk‚
                calls   far ptr l_1E5D      ; vyn soben¡ ‡¡sel
                mov     [bp+8],dx           ; nov‚ vstupn¡ ‡¡slo
                mov     [bp+6],ax
                mov     l_28FB,100          ; vydˆlen¡ v˜sledku odmocniny
                jmp     short l_1A05

l_19FF:         mov     l_28FB,1            ; vydˆlen¡ v˜sledku odmocniny

; ------ test, zda je ‡¡slo <= 1 (potom se ‡¡slo nemˆn¡)

l_1A05:         cmp     word ptr [bp+8],0
                jge     l_1A0E              ; ‡¡slo je kladn‚
                jmp     l_1A87              ; ‡¡slo je z porn‚ - nemˆn¡ se

l_1A0E:         jg      l_1A16
                cmp     word ptr [bp+6],1
                jbe     l_1A87              ; ‡¡slo je 0 nebo 1

; ------ vstupn¡ ‡¡slo - 1

l_1A16:         mov     dx,[bp+8]           ; vstupn¡ ‡¡slo
                mov     ax,[bp+6]
                add     ax,0FFFFh           ; vstupn¡ ‡¡slo - 1
;*              adc     dx,0FFFFh
                db       83h,0D2h,0FFh
                mov     [bp+8],dx           ; vstupn¡ ‡¡slo - 1
                mov     [bp+6],ax

; ----- p©ednastaven¡ meziv˜sledku na 1

                mov     word ptr [bp-2],0
                mov     word ptr [bp-4],1   ; meziv˜sledek = 1
                xor     si,si               ; SI <- 0 ‡¡ta‡ pr–chod–
                jmp     short l_1A80

; ------ p©¡prava registru meziv˜sledku

l_1A36:         mov     dx,[bp-2]           ; v˜sledek operace
                mov     ax,[bp-4]
                mov     [bp-6],dx           ; pracovn¡ meziv˜sledek
                mov     [bp-8],ax

                xor     dx,dx
                mov     ax,2
                push    dx                  ; dˆlitel 2
                push    ax

; ------ vydˆlen¡ POD‹L <- vstupn¡_‡¡slo/meziv˜sledek

                push    word ptr [bp-6]     ; meziv˜sledek
                push    word ptr [bp-8]
                push    word ptr [bp+8]     ; vstupn¡ ‡¡slo
                push    word ptr [bp+6]
                calls   far ptr l_1DA9      ; vydˆlen¡ ‡¡sel

; ----- sou‡et <- POD‹L + meziv˜sledek + 1

                add     ax,[bp-8]           ; pod¡l + meziv˜sledek
                adc     dx,[bp-6]
                add     ax,1                ; + korekce 1
;*              adc     dx,0
                db       83h,0D2h, 00h

; ----- nov˜_v˜sledek <- ((vstupn¡_‡¡slo-1)/meziv˜sledek+meziv˜sledek+1)/2

                push    dx
                push    ax
                calls   far ptr l_1DA9      ; vydˆlen¡ ‡¡sel / 2
                mov     [bp-2],dx           ; nov˜ v˜sledek operace
                mov     [bp-4],ax

; ----- test, zda je ji‘ v˜sledek operace stabiln¡

                cmp     dx,[bp-6]
                jne     l_1A7F
                cmp     ax,[bp-8]
                jne     l_1A7F
                jmp     short l_1A85        ; v˜sledek se ji‘ nemˆn¡

; ----- ‡¡t n¡ dal¨¡ho pr–chodu

l_1A7F:         inc     si                  ; ‡¡ta‡ pr–chod–

l_1A80:         cmp     si,14h              ; maxim ln¡ po‡et pr–chod–
;                db       83h,0FEh, 14h
                jle     l_1A36
l_1A85:         jmp     short l_1A93

; ------ ‡¡slo <= 1 se nemˆn¡ (tj. i z porn‚ ‡¡slo ?)

l_1A87:         mov     dx,[bp+8]           ; vstupn¡ ‡¡slo
                mov     ax,[bp+6]
                mov     [bp-2],dx           ; je v˜sledkem operace
                mov     [bp-4],ax

; ----- v˜sledek operace

l_1A93:         mov     ax,[bp-4]           ; v˜sledek operace
                mov     sp,bp
                pop     bp
                pop     si
                retn
l_19C1      endp

; -----------------------------------------------------------------------------
;        absolutn¡ hodnota slova
; -----------------------------------------------------------------------------

l_1A9B      proc    near

                push    si
                push    bp
                mov     bp,sp
                mov     si,[bp+6]
                or      si,si
                jge     l_1AAC
                mov     ax,si
                neg     ax
                mov     si,ax
l_1AAC:         mov     ax,si
                pop     bp
                pop     si
                retn
l_1A9B      endp

; -----------------------------------------------------------------------------
;        vypr zdnˆn¡ bufferu (l_297B)
; -----------------------------------------------------------------------------

l_1AB1      proc    near

                push    si
                push    di
                push    bp
                mov     bp,sp
                dec     sp
                dec     sp
                mov     word ptr [bp-2],offset l_2855 ; £vod zpr vy (parametry)

; ------ p©¡jem znaku (potvrzen¡ minul‚ zpr vy)

                call    l_00DC              ; p©¡jem znaku z COM

; ------ test, zda byl nˆjak˜ znak p©ijat (jinak vysl n¡ pr zdn‚ zpr vy)

l_1AC0:         cmp     byte ptr l_2928,0   ; znak p©ijat˜ z COM
                je      l_1ACA              ; nebylo nic p©ijato - pr zdn  zpr va
                jmp     l_1B50

; ------ vysl n¡ prvn¡ho synchroniza‡n¡ho znaku

l_1ACA:         mov     di,[bp-2]           ; adresa £vodu zpr vy
                mov     al,16h              ; 1. synchroniza‡n¡ znak
                push    ax
                call    l_1C0B              ; vysl n¡ znaku zpr vy
                pop     cx

; ----- vysl n¡ druh‚ho synchroniza‡n¡ho znaku

                mov     al,16h              ; 2. synchroniza‡n¡ znak
                push    ax
                call    l_1C0B              ; vysl n¡ znaku zpr vy
                pop     cx
                mov     l_2909,0            ; pr–bˆ‘n˜ kontroln¡ sou‡et

; ------- vysl n¡ £vodn¡ho znaku zpr vy

                mov     al,20h                  ; ' '
                push    ax
                call    l_1C0B              ; vysl n¡ znaku zpr vy
                pop     cx

; ------ vysl n¡ £vodu zpr vy (nastaven¡ parametr–)

l_1AE8:         cmp     byte ptr [di],0
                je      l_1AF6
                push    word ptr [di]       ; znak k vysl n¡
                call    l_1C0B              ; vysl n¡ znaku zpr vy
                pop     cx
                inc     di
                jmp     short l_1AE8

; ------ p©¡prava k vysl n¡ textu zpr vy

l_1AF6:         xor     si,si
                jmp     short l_1B02

; ------ vysl n¡ mezer (pr zdn  zpr va)

l_1AFA:         mov     al,20h                  ; ' '
                push    ax
                call    l_1C0B              ; vysl n¡ znaku zpr vy
                pop     cx
                inc     si
l_1B02:         cmp     si,60h
;                db       83h,0FEh, 60h
                jl      l_1AFA

; ------ vysl n¡ znaku kontroln¡ho sou‡tu

                mov     al,byte ptr l_2909  ; pr–bˆ‘n˜ kontroln¡ sou‡et
                neg     al
;*              and     al,1Fh              ; zarovn n¡ MODULO 31
                db       80h,0E0h, 1Fh
;*              add     al,40h              ; korekce
                db       80h,0C0h, 40h
                push    ax
                call    l_1C0B              ; vysl n¡ znaku zpr vy
                pop     cx

; ------ vysl n¡ znaku ukon‡en¡ zpr vy

                mov     al,0Dh
                push    ax
                call    l_1C0B              ; vysl n¡ znaku zpr vy
                pop     cx

; ------ 1. po‘adavek o hl ¨en¡ stavu

                mov     al,1                ; znak po‘adavku o hl ¨en¡ stavu
                push    ax
                call    l_1C0B              ; vysl n¡ znaku zpr vy
                pop     cx

; ----- 1. p©¡jem znaku potvrzen¡ stavu

                call    l_00DC              ; p©¡jem znaku z COM
                cmp     byte ptr l_2928,0   ; znak p©ijat˜ z COM
                jne     l_1B4E              ; bylo nˆco p©ijato

; ----- 2. po‘adavek o hl ¨en¡ stavu

                mov     al,1                ; znak po‘adavku o hl ¨en¡ stavu
                push    ax
                call    l_1C0B              ; vysl n¡ znaku zpr vy
                pop     cx

; ------ 2. p©¡jem znaku o potvrzen¡ stavu

                call    l_00DC              ; p©¡jem znaku z COM

; ------ chyba - zapisova‡ neodpov¡d 

                cmp     byte ptr l_2928,0   ; znak p©ijat˜ z COM
                jne     l_1B4E
                mov     ax,offset l_2874    ; text - neodpov¡d 
                push    ax
                call    l_1BF0              ; zobrazen¡ textu DOS ASCIIZ
                pop     cx
                call    l_1C31              ; nulov n¡ parametr– a buffer–
                jmp     l_1AC0

l_1B4E:         jmp     short l_1B83        ; vysl n¡ zpr vy

; ------ ‡ek n¡ na p©ipravenost plotteru

l_1B50:         cmp     byte ptr l_2928,2   ; znak p©ijat˜ z COM
                jne     l_1B63              ; nen¡ ‡ek n¡ na p©ipravenost
                mov     al,1                ; po‘adavek hl ¨en¡ o stavu
                push    ax
                call    l_1C0B              ; vysl n¡ znaku zpr vy
                pop     cx
                call    l_00DC              ; p©¡jem znaku z COM
                jmp     short l_1B50

; ------ test, zda byla chyba p©¡jmu

l_1B63:         cmp     byte ptr l_2928,4   ; znak p©ijat˜ z COM
                jne     l_1B74              ; nebyla chyba
                mov     ax,offset l_288D    ; text - chyba v komunikaci
                push    ax
                call    l_1BF0              ; zobrazen¡ textu DOS ASCIIZ
                pop     cx
                jmp     short l_1B83

; ------ test, zda bylo kladn‚ potvrzen¡ p©¡jmu

l_1B74:         cmp     byte ptr l_2928,1   ; znak p©ijat˜ z COM
                je      l_1B83              ; je OK
                mov     ax,offset l_28A4    ; text - chybn  odpovˆƒ
                push    ax
                call    l_1BF0              ; zobrazen¡ textu DOS ASCIIZ
                pop     cx

; ------ vysl n¡ prvn¡ho synchroniza‡n¡ho znaku

l_1B83:         mov     al,16h              ; 1. synchroniza‡n¡ znak
                push    ax
                call    l_1C0B              ; vysl n¡ znaku zpr vy
                pop     cx

; ----- vysl n¡ druh‚ho synchroniza‡n¡ho znaku

                mov     al,16h              ; 2. synchroniza‡n¡ znak
                push    ax
                call    l_1C0B              ; vysl n¡ znaku zpr vy
                pop     cx

; ----- vysl n¡ znaku za‡ tku zpr vy

                mov     l_2909,0            ; pr–bˆ‘n˜ kontroln¡ sou‡et <- 0
                mov     al,20h              ; znak za‡ tku zpr vy
                push    ax
                call    l_1C0B              ; vysl n¡ znaku zpr vy
                pop     cx

; ----- vysl n¡ £vodu zpr vy (nastaven¡ parametr–)

                mov     di,[bp-2]           ; adresa £vodu zpr vy
l_1BA1:         cmp     byte ptr [di],0
                je      l_1BAF
                push    word ptr [di]
                call    l_1C0B              ; vysl n¡ znaku zpr vy
                pop     cx
                inc     di
                jmp     short l_1BA1

; ----- p©¡prava k vysl n¡ obsahu zpr vy

l_1BAF:         xor     si,si               ; ukazatel zpr vy
                jmp     short l_1BC1

; ----- vysl n¡ textu zpr vy (96 znak–)

l_1BB3:         push    l_297B[si]          ; znak zpr vy k vysl n¡
                call    l_1C0B              ; vysl n¡ znaku zpr vy
                pop     cx
                mov     byte ptr l_297B[si],20h ; vymaz n¡ znaku
                inc     si                  ; zv˜¨en¡ ukazatele textu
l_1BC1:         cmp     si,60h              ; je zpr va ji‘ pln  ?
;                db       83h,0FEh, 60h
                jl      l_1BB3              ; dal¨¡ znak zpr vy

; ----- vysl n¡ kontroln¡ho sou‡tu zpr vy

                mov     al,byte ptr l_2909  ; pr–bˆ‘n˜ kontroln¡ sou‡et
                neg     al                  ; - kontroln¡ sou‡et (doplnˆk)
;*              and     al,1Fh              ; zarovn n¡ MODULO 31
                db       80h,0E0h, 1Fh
;*              add     al,40h              ; korekce na znak 40h ... 5Fh
                db       80h,0C0h, 40h
                push    ax
                call    l_1C0B              ; vysl n¡ znaku zpr vy
                pop     cx

; ----- vysl n¡ znaku ukon‡en¡ zpr vy

                mov     al,0Dh              ; znak ukon‡en¡ zpr vy
                push    ax
                call    l_1C0B              ; vysl n¡ znaku zpr vy
                pop     cx

; ----- vysl n¡ v˜zvy k potvrzen¡

                mov     al,1                ; znak v˜zvy k potvrzen¡ p©¡jmu
                push    ax
                call    l_1C0B              ; vysl n¡ znaku zpr vy
                pop     cx
                mov     l_29E1,0            ; po‡et znak– ve v˜stupn¡m bufferu

                mov     sp,bp
                pop     bp
                pop     di
                pop     si
                retn
l_1AB1      endp

; -----------------------------------------------------------------------------
;        zobrazen¡ textu DOS ASCIIZ
; -----------------------------------------------------------------------------

l_1BF0      proc    near

                push    si
                push    bp
                mov     bp,sp
                mov     si,[bp+6]
l_1BF7:
                cmp     byte ptr [si],0
                je      l_1C08
                mov     al,[si]
                mov     ah,0
                push    ax
                call    l_1E76              ; zobrazen¡ znaku DOS
                pop     cx
                inc     si
                jmp     short l_1BF7
l_1C08:
                pop     bp
                pop     si
                retn
l_1BF0      endp

; -----------------------------------------------------------------------------
;        vysl n¡ znaku zpr vy
; -----------------------------------------------------------------------------

l_1C0B      proc    near
                push    bp
                mov     bp,sp

                mov     al,[bp+4]           ; znak k vysl n¡
                mov     ah,0
                add     l_2909,ax           ; pr–bˆ‘n˜ kontroln¡ sou‡et

                mov     al,[bp+4]
                mov     l_28F8,al           ; znak k vysl n¡ na COM
                call    l_0118              ; vysl n¡ znaku na COM

                cmp     byte ptr l_28F8,0   ; znak k vysl n¡ na COM
                je      l_1C2F              ; znak vysl n OK
                mov     ax,28C2h            ; text - zapisovac nepripojen
                push    ax
                call    l_1BF0              ; zobrazen¡ textu DOS ASCIIZ
                pop     cx
l_1C2F:
                pop     bp
                retn
l_1C0B      endp

; -----------------------------------------------------------------------------
;        nulov n¡ parametr– a buffer–
; -----------------------------------------------------------------------------

l_1C31      proc    near

                push    si
                call    l_1CC4              ; inicializace parametr–
                mov     byte ptr l_2905,'_' ; znak ozna‡uj¡c¡ konec ASCII textu
                mov     byte ptr l_291B,1   ; ‡¡slo aktivn¡ho pera
                mov     byte ptr l_2906,1   ; 1=absolutn¡ sou©adnice
                mov     byte ptr l_28F9,1   ; 1=pero je zvednuto
                mov     byte ptr l_291F,1   ; 1=velk˜ form t
                mov     l_2926,0            ; skute‡n  pozice zapisova‡e Y (HIGH)
                mov     l_2924,0            ; skute‡n  pozice zapisova‡e Y (LOW)
                xor     dx,dx
                mov     ax,dx
                mov     l_290D,dx           ; skute‡n  pozice zapisova‡e X (HIGH)
                mov     l_290B,ax           ; skute‡n  pozice zapisova‡e X (LOW)
                mov     l_29DE,dx           ; aktu ln¡ pozice Y (HIGH)
                mov     l_29DC,ax           ; aktu ln¡ pozice Y (LOW)
                mov     l_2A05,dx           ; aktu ln¡ pozice X (HIGH)
                mov     l_2A03,ax           ; aktu ln¡ pozice X (LOW)
                mov     l_291D,ax           ; ‡¡ta‡ bajt– ‡ten˜ch dat ke ‡ten¡
                mov     l_28F2,2            ; velikost zna‡ky "M"
                mov     l_2979,38h          ; v˜¨ka znaku (krok–)
                mov     l_28FD,30h          ; ¨¡©ka znaku (krok–)
                mov     word ptr ds:[29F3h],1 ; smˆrnice textu X
                mov     word ptr l_2907,ax  ; smˆrnice textu Y
                mov     byte ptr l_29DB,0   ; 1=p©¡znak p¡sma Italic
                mov     l_29E1,ax           ; po‡et znak– ve v˜stupn¡m bufferu
                mov     si,ax
                jmp     short l_1CA3

; ----- vymaz n¡ bufferu

l_1C9D:         mov     byte ptr l_297B[si],20h ; vymaz n¡ znaku v bufferu
                inc     si
l_1CA3:         cmp     si,60h
;                db       83h,0FEh, 60h
                jl      l_1C9D

; ------ volba pera 1

                mov     bx,offset l_2A0B    ; buffer jednoho p©¡kazu ; buffer jednoho p©¡kazu
                mov     byte ptr [bx],23h   ; povel pro zvednut¡ pera
                mov     bx,offset l_2A0B+1
                mov     byte ptr [bx],24h   ; povel pro volbu pera
                mov     bx,offset l_2A0B+2
                mov     byte ptr [bx],21h   ; zvoleno pero 1
                mov     ax,3
                push    ax
                call    l_1945              ; ulo‘en¡ povelu do bufferu
                pop     cx
                pop     si
                retn
l_1C31      endp

;==========================================================================
;        inicializace parametr–
;==========================================================================

l_1CC4      proc    near

                cmp     byte ptr l_28FF,0   ; 1=p©¡znak oto‡en¡
                je      l_1D2D
                mov     l_2A01,0FFFFh       ; lev˜ doln¡ roh okna X (HIGH)
                mov     l_29FF,0C180h       ; lev˜ doln¡ roh okna X (LOW)
                mov     l_2902,0            ; prav˜ horn¡ roh okna X (HIGH)
                mov     l_2900,3E80h        ; prav˜ horn¡ roh okna X (LOW)
                mov     l_29FB,0FFFFh       ; lev˜ doln¡ roh okna Y (HIGH)
                mov     l_29F9,0D120h       ; lev˜ doln¡ roh okna Y (LOW)
                mov     l_28F6,0            ; prav˜ horn¡ roh okna Y (HIGH)
                mov     l_28F4,2EE0h        ; prav˜ horn¡ roh okna Y (LOW)
                mov     l_2919,0FFFFh       ; lev˜ doln¡ roh okna X ZOOM (HIGH)
                mov     l_2917,0C180h       ; lev˜ doln¡ roh okna X ZOOM (LOW)
                mov     l_29E9,0            ; prav˜ horn¡ roh okna X ZOOM (HIGH)
                mov     l_29E7,3E80h        ; prav˜ horn¡ roh okna X ZOOM (LOW)
                mov     l_29ED,0FFFFh       ; lev˜ doln¡ roh okna Y ZOOM (HIGH)
                mov     l_29EB,0D120h       ; lev˜ doln¡ roh okna Y ZOOM (LOW)
                mov     l_2911,0            ; prav˜ horn¡ roh okna Y ZOOM (HIGH)
                mov     l_290F,2EE0h        ; prav˜ horn¡ roh okna Y ZOOM (LOW)
                jmp     short l_1D8D

l_1D2D:         mov     l_2A01,0FFFFh       ; lev˜ doln¡ roh okna X (HIGH)
                mov     l_29FF,0D120h       ; lev˜ doln¡ roh okna X (LOW)
                mov     l_2902,0            ; prav˜ horn¡ roh okna X (HIGH)
                mov     l_2900,2EE0h        ; prav˜ horn¡ roh okna X (LOW)
                mov     l_29FB,0FFFFh       ; lev˜ doln¡ roh okna Y (HIGH)
                mov     l_29F9,0C180h       ; lev˜ doln¡ roh okna Y (LOW)
                mov     l_28F6,0            ; prav˜ horn¡ roh okna Y (HIGH)
                mov     l_28F4,3E80h        ; prav˜ horn¡ roh okna Y (LOW)
                mov     l_2919,0FFFFh       ; lev˜ doln¡ roh okna X ZOOM (HIGH)
                mov     l_2917,0D120h       ; lev˜ doln¡ roh okna X ZOOM (LOW)
                mov     l_29E9,0            ; prav˜ horn¡ roh okna X ZOOM (HIGH)
                mov     l_29E7,2EE0h        ; prav˜ horn¡ roh okna X ZOOM (LOW)
                mov     l_29ED,0FFFFh       ; lev˜ doln¡ roh okna Y ZOOM (HIGH)
                mov     l_29EB,0C180h       ; lev˜ doln¡ roh okna Y ZOOM (LOW)
                mov     l_2911,0            ; prav˜ horn¡ roh okna Y ZOOM (HIGH)
                mov     l_290F,3E80h        ; prav˜ horn¡ roh okna Y ZOOM (LOW)
l_1D8D:
                mov     byte ptr l_291C,0   ; 1=okno je platn‚ (0=neplat¡ rozmˆr)
                mov     byte ptr l_28FA,1   ; 1=je v oknˆ
                mov     byte ptr l_2904,0   ; 1=okno je platn‚ (0=neplatn‚ ZOOM)
                retn
l_1CC4      endp

                db      0B1h, 03h,0EBh, 0Ah

;==========================================================================
;        vydˆlen¡ ‡¡sel
;==========================================================================

l_1DA1      proc    far
                mov     cl,2
                jmp     short l_1DAB
                db      0B1h, 01h,0EBh, 02h

; ------ vydˆlen¡ ‡¡sel

l_1DA9:         xor     cx,cx

l_1DAB:         push    bp
                push    si
                push    di
                mov     bp,sp
                mov     ax,[bp+0Ah]
                mov     dx,[bp+0Ch]
                mov     bx,[bp+0Eh]
                mov     bp,[bp+10h]
                xor     si,si
                test    cl,1
                jnz     l_1DDD
                or      dx,dx
                jns     l_1DD0
                neg     dx
                neg     ax
                sbb     dx,si
                or      cl,4
l_1DD0:
                or      bp,bp
                jns     l_1DDD
                neg     bp
                neg     bx
                sbb     bp,si
                xor     cl,4
l_1DDD:
                mov     di,bp
                or      di,dx
                jnz     l_1DE9
                div     bx
                xchg    si,dx
                jmp     short l_1E09
l_1DE9:
                push    cx
                mov     cx,20h
                mov     di,si

l_1DEF:
                shl     ax,1
                rcl     dx,1
                rcl     si,1
                rcl     di,1
                cmp     di,bp
                jb      l_1E06
                ja      l_1E01
                cmp     si,bx
                jb      l_1E06
l_1E01:
                sub     si,bx
                sbb     di,bp
                inc     ax
l_1E06:
                loop    l_1DEF

                pop     cx
l_1E09:
                test    cl,2
                jz      l_1E11
                xchg    si,ax
                mov     dx,di
l_1E11:
                test    cl,4
                jz      l_1E1D
                neg     dx
                neg     ax
;*              sbb     dx,0
                db       83h,0DAh, 00h
l_1E1D:
                pop     di
                pop     si
                pop     bp
                retf    8
l_1DA1      endp

;==========================================================================
;        rotace DX:AX o CL bit– vlevo
;==========================================================================

l_1E23      proc    far
;*              cmp     cx,20h
                db       83h,0F9h, 20h
                jbe     l_1E2D
                xor     ax,ax
                xor     dx,dx
                retf
l_1E2D:
                dec     cx
                jl      l_1E36
                shl     ax,1
                rcl     dx,1
                jmp     short l_1E2D

l_1E36:
                retf
l_1E23      endp

;==========================================================================
;        rotace DX:AX o CL bit– vpravo
;==========================================================================

l_1E37      proc    far
;*              cmp     cx,20h
                db       83h,0F9h, 20h
                jbe     l_1E3F
                mov     cx,20h
l_1E3F:
                dec     cx
                jl      l_1E48
                sar     dx,1
                rcr     ax,1
                jmp     short l_1E3F

l_1E48:
                retf

l_1E37      endp

                                                ;* No entry point to code
;*              cmp     cx,20h
                db       83h,0F9h, 20h
                jbe     l_1E53
                xor     ax,ax
                xor     dx,dx
                retf
l_1E53:
                dec     cx
                jl      l_1E5C
                shr     dx,1
                rcr     ax,1
                jmp     short l_1E53

l_1E5C:
                retf

;==========================================================================
;        vyn soben¡ ‡¡sel DX:AX * CX:BX -> DX:AX
;==========================================================================

l_1E5D          proc    far

                push    si
                xchg    si,ax
                xchg    dx,ax
                test    ax,ax
                jz      l_1E66
                mul     bx

l_1E66:         xchg    cx,ax
                test    ax,ax
                jz      l_1E6F
                mul     si
                add     cx,ax

l_1E6F:         xchg    si,ax
                mul     bx
                add     dx,cx
                pop     si
                retf

l_1E5D      endp

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku DOS
; -----------------------------------------------------------------------------

l_1E76      proc    near

                push    bp
                mov     bp,sp
                mov     dl,[bp+4]
                mov     ah,2
                int     21h
                pop     bp
                retn

l_1E76      endp

l_1E82     db      0                        ; 1=p©¡znak ‡ek n¡ na dal¨¡ znak
l_1E83     db      0                        ; ‡¡slo portu COM
l_1E84     dw      0                        ; uschovan˜ ukazatel z sobn¡ku DOS
l_1E86     dw      0
l_1E88     dw      0                        ; £schova registru SP
l_1E8A     dw      0                        ; £schova registru SI
l_1E8C     dw      0                        ; £schova registru DI
l_1E8E     dw      0                        ; £schova registru BP

           db      1024 dup (0)   ; z sobn¡k

l_2290     dd      00000h                   ; p–vodn¡ adresa INT 14h

; ------ tabulka font– znak–
; 1. bajt ka‘d‚ho znaku ud v  po‡et dvojic sou©adnic X a Y
; V sou©adnici X ud v  bit 7 zvednut¡ pera

l_2294          db      0                                  ; mezera
                db      4,0C0h,7Fh,40h,20h,0C0h,0Eh,40h,0  ; !
                db      4,0ABh,7Fh,2Bh,60h,0D5h,7Fh,55h,60h; "
                db      8,80h,50h,7Fh,50h,0FFh,30h,0,30h   ; #
                db        0ABh,10h,2Bh,70h,0D5h,70h,55h,10h
                db     12,0EAh,70h,16h,70h,0,60h,0,50h     ; $
                db        16h,40h,6Ah,40h,7Fh,30h,7Fh,20h
                db        6Ah,10h,16h,10h,0C0h,7Fh,40h,0
                db     12,80h,50h,0,70h,2Bh,70h,2Bh,50h    ; %
                db        0,50h,80h,10h,7Fh,70h,0FFh,10h
                db        55h,10h,55h,30h,7Fh,30h,7Fh,10h
                db     12,0FFh,30h,40h,0,2Bh,0,0,20h       ; &
                db        0,30h,40h,60h,40h,70h,2Bh,7Fh
                db        16h,7Fh,0,70h,0,60h,7Fh,0
                db      3,0D5h,7Fh,55h,70h,40h,60h         ; '
                db      4,0D5h,7Fh,2Bh,60h,2Bh,20h,55h,0   ; (
                db      4,0ABh,7Fh,55h,60h,55h,20h,2Bh,0   ; )
                db      8,96h,40h,6Ah,40h,0EAh,60h,16h,20h ; *
                db        0C0h,20h,40h,60h,96h,60h,6Ah,20h
                db      4,96h,40h,6Ah,40h,0C0h,60h,40h,20h ; +
                db      6,0C0h,20h,55h,20h,55h,30h,40h,30h ; ,
                db        40h,10h,2Bh,0
                db      2,96h,40h,6Ah,40h                  ; -
                db      5,0D5h,0,55h,10h,40h,10h,40h,0     ; .
                db        55h,0
                db      2,0FFh,70h,0,10h                   ; /
                db      12,80h,20h,2Bh,0,55h,0,7Fh,20h     ; 0
                db         7Fh,60h,55h,7Fh,2Bh,7Fh,0,60h
                db         0,20h,16h,20h,6Ah,60h,7Fh,60h
                db       5,96h,60h,40h,7Fh,40h,0,0ABh,0    ; 1
                db         55h,0
                db      11,80h,60h,0,70h,16h,7Fh,6Ah,7Fh   ; 2
                db         7Fh,70h,7Fh,50h,6Ah,40h,2Bh,40h
                db         0,20h,0,0,7Fh,0
                db      13,80h,70h,16h,7Fh,6Ah,7Fh,7Fh,70h ; 3
                db         7Fh,60h,55h,40h,40h,40h,55h,40h
                db         7Fh,20h,7Fh,10h,6Ah,0,16h,0
                db         0,10h
                db       5,0EAh,0,6Ah,7Fh,0,30h,0,20h      ; 4
                db         7fh,20h
                db      10,80h,10h,16h,0,55h,0,7fh,20h     ; 5
                db         7fh,30h,55h,50h,16h,50h,0,40h
                db         0,7Fh,6Ah,7Fh
                db      11,80h,30h,2bh,50h,55h,50h,7fh,30h ; 6
                db         7fh,20h,55h,0,2bh,0,0,20h
                db         0,60h,2Bh,7Fh,6Ah,7Fh
                db       5,80h,60h,0,7Fh,7Fh,7Fh,7Fh,50h   ; 7
                db         16h,0
                db      16,0ABh,50h,16h,60h,16h,70h,2Bh,7Fh ; 8
                db         55h,7Fh,6Ah,70h,6Ah,60h,55h,50h
                db         2Bh,50h,0,30h,0,20h,2Bh,0
                db         55h,0,7Fh,20h,7Fh,30h,55h,50h
                db      11,0FFh,50h,55h,30h,2Bh,30h,0,50h  ; 9
                db         0,60h,2Bh,7Fh,55h,7Fh,7Fh,60h
                db         7Fh,20h,55h,0,16h,0
                db      10,0D5h,30h,40h,30h,40h,40h,55h,40h ; :
                db         55h,30h,0D5h,10h,55h,0,40h,0
                db         40h,10h,55h,10h
                db      11,0C0h,50h,55h,50h,55h,60h,40h,60h ; ;
                db         40h,50h,0C0h,20h,55h,20h,55h,30h
                db         40h,30h,40h,10h,2Bh,0
                db       3,0EAh,7Fh,16h,40h,6Ah,0          ; <
                db       4,96h,50h,6Ah,50h,96h,30h,6Ah,30h ; =
                db       3,96h,7Fh,6Ah,40h,16h,0           ; >
                db      11,80h,70h,16h,7Fh,6Ah,7Fh,7Fh,70h ; ?
                db         7Fh,60h,6Ah,50h,55h,50h,40h,40h
                db         40h,20h,0C0h,0Eh,40h,0
                db      14,0ABh,0,40h,10h,40h,30h,2Bh,40h  ; @
                db         16h,40h,0,30h,0,10h,16h,0
                db         55h,0,7Fh,20h,7Fh,60h,55h,7Fh
                db         2Bh,7Fh,0,60h
                db       7,80h,0,0,50h,40h,7Fh,7Fh,50h     ; A
                db         7Fh,0,80h,30h,7Fh,30h

,0Ch,80h
           , 00h, 00h, 7Fh, 55h
                db       7Fh, 6Ah, 70h, 6Ah, 50h, 55h
                db       40h, 00h, 40h, 6Ah, 40h, 7Fh
                db       30h, 7Fh, 10h, 6Ah, 00h, 00h
                db       00h, 08h,0FFh, 70h, 6Ah, 7Fh
                db       2Bh, 7Fh, 00h, 60h, 00h, 20h
                db       2Bh, 00h, 6Ah, 00h, 7Fh, 10h
                db       07h, 80h, 00h, 00h, 7Fh, 55h
                db       7Fh, 7Fh, 60h, 7Fh, 20h, 55h
                db       00h, 00h, 00h
l_24E7:
                push    es
                db      0FFh, 7Fh, 00h, 7Fh, 00h, 00h
                db       7Fh, 00h, 80h, 40h, 6Ah, 40h
                db       05h,0FFh, 7Fh, 00h, 7Fh, 00h
                db       00h, 80h, 40h, 6Ah, 40h, 0Ah
                db      0FFh, 70h, 6Ah, 7Fh, 2Bh, 7Fh
                db       00h, 60h, 00h, 20h, 2Bh, 00h
                db       6Ah, 00h, 7Fh, 10h, 7Fh, 30h
                db       55h, 30h, 06h, 80h, 00h, 00h
                db       7Fh, 80h, 40h, 7Fh, 40h,0FFh
                db       7Fh, 7Fh, 00h, 06h,0ABh, 7Fh
                db       55h, 7Fh,0C0h, 7Fh, 40h, 00h
                db      0ABh, 00h, 55h, 00h, 06h, 80h
                db       30h, 00h, 20h, 2Bh, 00h, 55h
                db       00h, 7Fh, 20h, 7Fh, 7Fh, 06h
                db       80h, 00h, 00h, 7Fh,0FFh, 7Fh
                db       00h, 20h,0ABh, 40h, 7Fh, 00h
                db       03h, 80h, 7Fh, 00h, 00h, 7Fh
                db       00h, 05h, 80h, 00h, 00h, 7Fh
                db       40h, 50h, 7Fh, 7Fh, 7Fh, 00h
                db       06h, 80h, 00h, 00h, 7Fh, 80h
                db       70h, 7Fh, 10h,0FFh, 00h, 7Fh
                db       7Fh, 09h, 80h
l_2569:
                and     [bp+di],ch
;*              add     [di+0],dl
                db       00h, 55h, 00h
                db       7Fh, 20h, 7Fh, 60h, 55h, 7Fh
                db       2Bh, 7Fh, 00h, 60h, 00h, 20h
                db       07h, 80h, 00h, 00h, 7Fh, 6Ah
                db       7Fh, 7Fh, 70h, 7Fh, 50h, 6Ah
                db       40h, 00h, 40h, 0Bh, 80h, 20h
                db       2Bh, 00h, 40h, 00h, 7Fh, 30h
                db       7Fh, 60h, 55h, 7Fh, 2Bh, 7Fh
                db       00h, 60h, 00h, 20h,0D5h, 20h
                db       7Fh, 00h, 09h, 80h, 00h, 00h
                db       7Fh, 6Ah, 7Fh, 7Fh, 70h, 7Fh
                db       50h, 6Ah, 40h, 00h, 40h,0ABh
                db       40h, 7Fh, 00h, 0Ah, 96h, 00h
                db       6Ah, 00h, 7Fh, 10h, 7Fh, 30h
                db       6Ah, 40h, 16h, 40h, 00h, 50h
                db       00h, 70h, 16h, 7Fh, 6Ah, 7Fh
                db       04h, 80h, 7Fh, 7Fh, 7Fh,0C0h
                db       7Fh, 40h, 00h, 06h, 80h, 7Fh
                db       00h, 20h, 2Bh, 00h, 55h, 00h
                db       7Fh, 20h, 7Fh, 7Fh, 05h, 80h
                db       7Fh
l_25E1:
                add     [bx+si],dh
                inc     ax
                add     [bx+30h],bh
;*              jg      l_2668
                db       7Fh, 7Fh
                pop     es
;*              cmp     byte ptr [bx+0],10h
                db       80h, 7Fh, 00h, 10h
                db       16h, 00h, 40h, 20h, 6Ah, 00h
                db       7Fh, 10h, 7Fh, 7Fh, 08h, 80h
                db       00h, 00h, 10h, 7Fh, 70h, 7Fh
                db       7Fh, 80h, 7Fh, 00h, 70h, 7Fh
                db       10h, 7Fh, 00h, 08h, 80h, 7Fh
                db       00h, 60h, 2Bh, 40h, 55h, 40h
                db       7Fh, 60h, 7Fh, 7Fh,0C0h, 40h
                db       40h, 00h, 06h, 80h, 7Fh, 7Fh
                db       7Fh, 7Fh, 70h, 00h, 10h, 00h
                db       00h, 7Fh, 00h, 04h,0D5h, 7Fh
                db       2Bh, 7Fh, 2Bh, 00h, 55h, 00h
                db       02h, 80h, 70h, 7Fh, 10h, 04h
                db      0ABh, 7Fh, 55h, 7Fh, 55h, 00h
                db       2Bh, 00h, 03h, 80h, 50h, 40h
                db       7Fh, 7Fh, 50h, 02h, 80h, 00h
                db       7Fh, 00h, 02h,0ABh, 7Fh, 55h
                db       60h, 0Dh,0ABh, 50h, 55h, 50h
                db       6Ah, 40h, 6Ah, 10h, 55h, 00h
                db       2Bh, 00h, 16h, 10h, 16h, 20h
                db       2Bh, 30h, 55h, 30h, 6Ah, 20h
                db      0EAh, 10h
l_2668:
                jg      $+2
                pop     es
                xchg    si,ax
;*              jg      l_2684
                db       7Fh, 16h
;*              add     [bp+si+0],ch
                db       00h, 6Ah, 00h
                db       7Fh, 10h, 7Fh, 30h, 6Ah, 40h
                db       16h, 40h, 06h,0FFh, 40h, 2Bh
                db       40h, 16h, 30h, 16h, 10h, 2Bh
                db       00h
l_2684:
                jg      $+2
                pop     es
                db      0FFh, 7Fh, 7Fh, 00h, 2Bh, 00h
                db       16h, 10h, 16h
                db      30h
l_2691:
                sub     ax,[bx+si+7Fh]
                inc     ax
;*              or      dx,bp
                db       09h,0EAh
                add     [bp+di],ch
                add     byte ptr ds:[1610h],dl
                xor     [bp+di],ch
                inc     ax
                db       6Ah, 40h, 7Fh, 30h, 7Fh, 20h
                db       16h, 20h, 07h,0ABh, 00h, 2Bh
                db       70h, 40h, 7Fh, 55h, 7Fh, 6Ah
                db       70h, 96h, 40h, 55h, 40h, 0Ah
                db      0ABh, 00h, 6Ah, 00h, 7Fh, 10h
                db       7Fh, 40h, 6Ah, 50h, 2Bh, 50h
                db       16h, 40h, 16h, 30h, 2Bh, 20h
                db       7Fh, 20h, 06h, 96h, 00h, 16h
                db       7Fh, 96h, 40h, 55h, 40h, 7Fh
                db       20h, 7Fh, 00h, 07h,0BCh, 60h
                db       44h, 60h,0ABh, 40h, 40h, 40h
                db       40h, 00h,0ABh, 00h, 55h, 00h
                db       06h,0D0h, 70h, 5Ah, 70h,0C0h
l_26EE:
                push    ax
                push    bp
                push    ax
                push    bp
;*              adc     [bx+si+0],al
                db       10h, 40h, 00h
                db       07h, 96h, 00h, 16h, 7Fh,0FFh
                db       60h, 40h, 30h, 16h, 30h,0C0h
                db       30h, 7Fh, 00h, 05h
l_2705:
                stosw
                jg      $+42h
                jg      $+42h
                add     byte ptr ss:[5500h][bp+di],ch
                add     [bp+di],cl
                add     byte ptr [bx+si],0
                xor     ds:[2B40h],dl
                inc     ax
                inc     ax
;*              xor     [bx+si+0],al
                db       30h, 40h, 00h
                db      0C0h, 30h, 55h, 40h, 6Ah, 40h
                db       7Fh, 30h, 7Fh, 00h, 05h, 96h
                db       00h, 16h, 40h, 55h, 40h, 6Ah
                db       30h, 6Ah, 00h, 09h,0D5h, 00h
                db       2Bh, 00h, 16h, 10h, 16h
                db      '0+@U@j0j'
                db       10h, 55h, 00h, 07h, 96h, 00h
                db       16h
                db      '`U`jPj@U0'
                db       16h, 30h, 07h,0EAh, 00h, 6Ah
                db       60h, 2Bh, 60h, 16h, 50h, 16h
                db       40h, 2Bh, 30h, 6Ah, 30h, 06h
                db       96h, 00h, 16h, 40h, 96h
                db      ' @@U@j0', 8
                db      0EAh, 40h, 2Bh, 40h, 16h, 30h
                db       2Bh, 20h, 6Ah, 20h, 7Fh, 10h
                db       6Ah, 00h, 2Bh, 00h, 07h,0FFh
                db       20h, 55h, 00h, 40h, 00h, 2Bh
                db       10h, 2Bh, 7Fh, 96h, 40h, 55h
                db       40h, 06h, 96h, 40h, 16h, 10h
                db       2Bh, 00h, 55h, 00h, 6Ah, 10h
                db       6Ah, 40h, 05h, 96h, 40h, 16h
                db       20h, 40h, 00h, 6Ah, 20h, 6Ah
                db       40h, 07h, 80h, 40h, 00h, 10h
                db       16h, 00h, 40h, 20h, 6Ah, 00h
                db       7Fh, 10h, 7Fh, 40h, 04h, 96h
                db       00h, 6Ah, 40h, 96h, 40h, 6Ah
                db       00h, 08h, 96h, 50h, 16h
                db      '@+0U0j@jP'
                db      0C0h, 30h, 40h, 00h, 04h, 96h
                db       40h, 6Ah, 40h, 16h, 00h, 6Ah
                db       00h, 09h,0D5h, 7Fh, 40h, 7Fh
                db       2Bh, 70h, 2Bh, 50h, 16h, 40h
                db       2Bh, 30h, 2Bh, 10h, 40h, 00h
                db       55h, 00h, 02h,0C0h, 7Fh, 40h
                db       00h, 09h,0ABh, 7Fh, 40h, 7Fh
                db      'UpUPj@U0U'
                db       10h, 40h, 00h, 2Bh, 00h, 07h
                db       80h, 40h, 16h
                db      'P+P@@U0j0'
                db       7Fh, 40h, 00h,

l_2814          db       1Bh,76h,22h,56h,2Bh,24h,0 ; zna‡ka "x"
l_281B          db       2Dh,54h,62h,74h,66h,1Bh,24h,0 ; zna‡ka ‡tvere‡ek
l_2823          db       2eh,54h,5bh,62h,6bh,74h ; zna‡ka osmi£heln¡k
                db       6dh,66h,5dh,1ah,24h,0
l_282F          db       25h,5Ah,74h,5Eh,23h,24h,0 ; zna‡ka troj£heln¡k
l_2836          db       6Eh,54h,70h,54h,6eh,24h,0 ; zna‡ka p©es˜pac¡ hodiny
l_283D          db       1Ch,74h,1bh,66h,23h,24h,0 ; jin  zna‡ka
l_2844          db      '(DMP51 0375001)', 0Dh, 0

; ------ £vod zpr vy (nastaven¡ parametr– p©enosu)

l_2855          db      28h,21h,28h,24h,21h,20h,21h,28h,25h,21h,20h,24h
                db      28h,28h,21h,20h,22h,28h,26h,21h,20h,21h,28h,23h
                db      21h,28h,27h,21h,27h,5fh,0

l_2874          db      'Zapisovac neodpovida !', 0Dh, 0Ah,0
l_288D          db      'Chyba v komunikaci !',0Dh,0Ah,0
l_28A4          db      'Chybna odpoved zapisovace !', 0Dh,0Ah,0
l_28C2          db      'Zapisovac nepripojen nebo chyba v kabelazi !',0Dh,0Ah,0

                db      0

l_28F2     dw      0                        ; velikost zna‡ky "M"
l_28F4     dw      0                        ; prav˜ horn¡ roh okna Y (LOW)
l_28F6     dw      0                        ; prav˜ horn¡ roh okna Y (HIGH)
l_28F8     db      0                        ; znak k vysl n¡ na COM
l_28F9     db      0                        ; 1=pero je zvednuto
l_28FA     db      0                        ; 1=je v oknˆ
l_28FB     dw      0                        ; vydˆlen¡ v˜sledku odmocniny
l_28FD     dw      0                        ; ¨¡©ka znaku (krok–)
l_28FF     db      0                        ; 1=p©¡znak oto‡en¡
l_2900     dw      0                        ; prav˜ horn¡ roh okna X (LOW)
l_2902     dw      0                        ; prav˜ horn¡ roh okna X (HIGH)
l_2904     db      0                        ; 1=okno je platn‚ (0=neplatn‚ ZOOM)
l_2905     db      0                        ; znak ozna‡uj¡c¡ konec ASCII textu
l_2906     db      0                        ; 1=absolutn¡ sou©adnice
l_2907     dw      0                        ; smˆrnice textu Y
l_2909     dw      0                        ; pr–bˆ‘n˜ kontroln¡ sou‡et
l_290B     dw      0                        ; skute‡n  pozice zapisova‡e X (LOW)
l_290D     dw      0                        ; skute‡n  pozice zapisova‡e X (HIGH)
l_290F     dw      0                        ; prav˜ horn¡ roh okna Y ZOOM (LOW)
l_2911     dw      0                        ; prav˜ horn¡ roh okna Y ZOOM (HIGH)
l_2913     dw      0                        ; ¨¡©ka okna X (LOW)
l_2915     dw      0                        ; ¨¡©ka okna X (HIGH)
l_2917     dw      0                        ; lev˜ doln¡ roh okna X ZOOM (LOW)
l_2919     dw      0                        ; lev˜ doln¡ roh okna X ZOOM (HIGH)
l_291B     db      0                        ; ‡¡slo aktivn¡ho pera
l_291C     db      0                        ; 1=okno je platn‚ (0=neplat¡ rozmˆr)
l_291D     dw      0                        ; ‡¡ta‡ bajt– ‡ten˜ch dat ke ‡ten¡
l_291F     db      0                        ; 1=velk˜ form t
l_2920     dw      0                        ; v˜¨ka okna Y (LOW)
l_2922     dw      0                        ; v˜¨ka okna Y (HIGH)
l_2924     dw      0                        ; skute‡n  pozice zapisova‡e Y (LOW)
l_2926     dw      0                        ; skute‡n  pozice zapisova‡e Y (HIGH)
l_2928     db      0                        ; znak p©ijat˜ z COM
l_2929     db      80 dup(0)                ; buffer p©ijat˜ch dat (pro DOS)
l_2979     dw      0                        ; v˜¨ka znaku (krok–)

l_297B     db      96 dup(0)                ; buffer textu zpr vy

l_29DB     db      0                        ; 1=p©¡znak p¡sma Italic
l_29DC     dw      0                        ; aktu ln¡ pozice Y (LOW)
l_29DE     dw      0                        ; aktu ln¡ pozice Y (HIGH)
l_29E0     db      0                        ; znak k vysl n¡ od DOS
l_29E1     dw      0                        ; po‡et znak– ve v˜stupn¡m bufferu
l_29E3     dw      0                        ; v˜¨ka okna Y ZOOM (LOW)
l_29E5     dw      0                        ; v˜¨ka okna Y ZOOM (HIGH)
l_29E7     dw      0                        ; prav˜ horn¡ roh okna X ZOOM (LOW)
l_29E9     dw      0                        ; prav˜ horn¡ roh okna X ZOOM (HIGH)
l_29EB     dw      0                        ; lev˜ doln¡ roh okna Y ZOOM (LOW)
l_29ED     dw      0                        ; lev˜ doln¡ roh okna Y ZOOM (HIGH)
l_29EF     dw      0                        ; ¨¡©ka okna X ZOOM (LOW)
l_29F1     dw      0                        ; ¨¡©ka okna X ZOOM (HIGH)
l_29F3   dw        0                        ; smˆrnice textu X
l_29F5     dw      0
l_29F7     dw      0
l_29F9     dw      0                        ; lev˜ doln¡ roh okna Y (LOW)
l_29FB     dw      0                        ; lev˜ doln¡ roh okna Y (HIGH)
l_29FD     dw      0                        ; ukazatel ‡ten¡ p©ijat˜ch dat
l_29FF     dw      0                        ; lev˜ doln¡ roh okna X (LOW)
l_2A01     dw      0                        ; lev˜ doln¡ roh okna X (HIGH)
l_2A03     dw      0                        ; aktu ln¡ pozice X (LOW)
l_2A05     dw      0                        ; aktu ln¡ pozice X (HIGH)
l_2A07     dw      0
l_2A09     dw      0


l_2A0B     db      20 dup(0)                ; buffer jednoho p©¡kazu
         db        0

; ============================================================================
;
;                       Start a instalace programu
;
; ============================================================================
;þ
; ----- test instalace programu

start:          call    l_2AB0              ; test instalace programu

; ----- dek¢dov n¡ zad n¡ - prvn¡ parametr

                mov     ax,ds:[5Dh]         ; zadan˜ soubor 1
                mov     bx,ds:[6Dh]         ; zadan˜ soubor 2
                push    cs
                pop     ds
                cmp     ah,20h              ; bylo nˆco zad no 2 znaky ?
                jne     l_2AA4              ; bylo nˆco zad no 2 znaky - chyba
                cmp     al,20h
                je      l_2A45              ; prvn¡ znak nezad n
                cmp     al,"1"
                jb      l_2AA4              ; neplatn‚ ‡¡slo portu
                cmp     al,"9"+1
                jae     l_2AA4              ; chyba zad n¡
                mov     byte ptr l_2B4D+6,al ; ‡¡slo portu COM
                sub     al,31h
                mov     l_1E83,al           ; ‡¡slo portu COM

; ------- dek¢dov n¡ zad n¡ - druh˜ parametr

l_2A45:         mov     al,0
                cmp     bh,20h              ; byl zad n druh˜ znak 2. parametru ?
                jne     l_2AA4              ; chyba zad n¡
                cmp     bl,20h
                je      l_2A5D              ; druh˜ znak nezad n
                mov     al,1                ; p©¡znak oto‡en¡
                cmp     bl,"r"
                je      l_2A5D
                cmp     bl,"R"
                jne     l_2AA4
l_2A5D:         mov     l_28FF,al           ; 1=p©¡znak oto‡en¡

; -------- zobrazen¡ £vodn¡ho textu

                mov     dx,offset l_2B12    ; £vodn¡ text
                mov     ah,9
                int     21h

; ------- informace o oto‡en¡

                cmp     l_28FF,0            ; 1=p©¡znak oto‡en¡
                je      l_2A75
                mov     dx,offset l_2B44    ; text - oto‡eno
                mov     ah,9
                int     21h

; ------ informace o COM

l_2A75:         mov     dx,offset l_2B4D    ; text "Na COM1"
                mov     ah,9
                int     21h

; ------ nastaven¡ parametr– portu COM

                xor     dx,dx
                mov     dl,l_1E83           ; ‡¡slo portu COM
                mov     ah,0
                mov     al,0FAh             ; 9600 Bd, 7 bit–, 1 STOP, sud  p.
                int     14h                 ; nastaven¡ COM

; ------- £schova adresy INT 14h

                mov     ah,35h                  ; '5'
                mov     al,14h
                int     21h
                mov     word ptr l_2290,bx  ; p–vodn¡ adresa INT 14h
                mov     word ptr l_2290+2,es; p–vodn¡ adresa INT 14h

; ------ instalace INT 14h

                mov     dx,offset int_14h_entry
                mov     ah,25h                  ; '%'
                mov     al,14h
                int     21h

; ------ instalace programu

                mov     dx,offset Start + 100h
                int     27h

; ------ chyba zad n¡ parametr–

l_2AA4:         mov     ah,9
                mov     dx,offset l_2ADD    ; text "INPUT ERROR !"
                int     21h
                mov     ax,4C01h
                int     21h

; -----------------------------------------------------------------------------
;        test, zda je program ji‘ nainstalov n
; -----------------------------------------------------------------------------

l_2AB0      proc    near

                push    ds
                mov     ah,35h
                mov     al,14h
                int     21h                 ; adresa INT 14h
                mov     ax,es
                mov     ds,ax
                mov     cx,[bx+0Ch]
                mov     dx,[bx+0Eh]
                pop     ds
                cmp     cx,"IH"
                jne     l_2ACE
                cmp     dx,"LG"
                je      l_2ACF
l_2ACE:         retn

l_2ACF:         push    cs
                pop     ds
                mov     ah,9
                mov     dx,offset l_2AF0    ; text - je ji‘ v pamˆti
                int     21h
                mov     ax,4C01h
                int     21h

l_2ADD     db      0Dh, 0Ah, 'INPUT ERROR !', 0Dh, 0Ah,7, '$'

l_2AF0     db      0Dh,0Ah, 'Driver HIGL je jiz zaveden !',0Dh,0Ah,7,'$'

l_2B12     db      0Dh, 0Ah, 'HOUSTON INSTRUMENT XON/XOFF protokol ver. 2.14 $'
l_2B44     db      'otoceno $'
l_2B4D     db      'na COM1',0Dh,0Ah,'$'
           db      9 dup (0)

l_2AB0      endp

seg_a           ends

;------------------------------------------------------  stack_seg_b   ----

stack_seg_b     segment word stack 'stack'
                db      256 dup (0)
stack_seg_b     ends

                end     start

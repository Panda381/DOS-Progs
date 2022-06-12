seg_a           segment byte public
                assume  cs:seg_a, ds:seg_a
                org     0
mtmcdae         proc    far

header          dd      0FFFFFFFFh
attributes      dw      0C800h
pointers        dw      offset strategy
                dw      offset commands

char_dev        db      '12345678'          ; jm‚no za©¡zen¡
                db      0, 0, 0, 1
d_0016          dd      00000h
copyright       db      'Copyright (C) MITSUMI ELECTRIC C'

                db      'O.,LTD. 1989-1993. All right'
                db      's reserved.'
                db       90h                ; (=EVEN)

d_0062                                      ; adresy obsluh povel–
         dw        3b90h                    ; 00h: inicializace ovlada‡e
         dw        0b1eh                    ; 01h: kontrola v˜mˆny m‚dia
         dw        083ah                    ; 02h: ... (vystavˆn¡ BPB)
         dw        0881h                    ; 03h: vstup IOCTL
         dw        083ah                    ; 04h: ... (vstup)
         dw        083ah                    ; 05h: ... (nedestruktivn¡ vstup)
         dw        083ah                    ; 06h: ... (stav vstupu)
         dw        132dh                    ; 07h: vypr zdnˆn¡ vstupu
         dw        083ah                    ; 08h: ... (v˜stup)
         dw        083ah                    ; 09h: ... (v˜stup s verifikac¡)
         dw        083ah                    ; 0Ah: ... (stav v˜stupu)
         dw        083ah                    ; 0Bh: ... (vypr zdnˆn¡ v˜stupu)
         dw        135bh                    ; 0Ch: v˜stup IOCTL
         dw        134bh                    ; 0Dh: otev©en¡ za©¡zen¡
         dw        134bh                    ; 0Eh: uzav©en¡ za©¡zen¡
         dw        083ah                    ; 0Fh: ... (v˜mˆna m‚dia)
d_0082   dw        15b9h                    ; 80h: dlouh‚ ‡ten¡ CD
         dw        083ah                    ; 81h: ... (rezervov no)
         dw        15b9h                    ; 82h: dlouh‚ ‡ten¡ PREFETCH CD
         dw        1ee7h                    ; 83h: vystaven¡ hlav
         dw        2038h                    ; 84h: p©ehr v n¡
         dw        2382h                    ; 85h: zastaven¡ p©ehr v n¡
         dw        083ah                    ; 86h: ... (dlouh˜ z pis)
         dw        083ah                    ; 87h: ... (dlouh˜ z pis s verifikac¡)
         dw        2471h                    ; 88h: pokra‡ov n¡ p©ehr v n¡

                db      ':', 8, ':', 8, ':', 8, ':', 8, ':'
                db      8, ':', 8, ':', 8

; ------ tabulka obsluh funkc¡ v˜stup IOCTL

d_00A2   dw        1377h                    ; 00h: vysunut¡ disku EJECT
         dw        13adh                    ; 01h: uzamknut¡/odemknut¡ dv¡©ek
         dw        13f1h                    ; 02h: reset disku
         dw        142fh                    ; 03h: ©¡zen¡ audio kan lu
         dw        083ah                    ; 04h: ... (z pis ©¡dic¡ho ©etˆzce)
         dw        1584h                    ; 05h: uzav©en¡ cesty
         dw        083ah                    ; 06h: ...

; ------ tabulka obsluh funkc¡ vstup IOCTL

d_00B0   dw        089ch                    ; 00h: adresa z hlav¡ za©¡zen¡
         dw        08b6h                    ; 01h: aktu ln¡ pozice hlav
         dw        083ah                    ; 02h: ... (rezervov no)
         dw        083ah                    ; 03h: ... (statistika chyb)
         dw        0954h                    ; 04h: informace o audio kan lech
         dw        0a44h                    ; 05h: bajty RAW disku
         dw        0a4bh                    ; 06h: stav za©¡zen¡
         dw        0ac5h                    ; 07h: velikost sektoru
         dw        0ae6h                    ; 08h: velikost disku
         dw        0b25h                    ; 09h: stav v˜mˆny m‚dia
         dw        0bc1h                    ; 0Ah: informace o disku
         dw        0c12h                    ; 0Bh: informace o stopˆ
         dw        0fffh                    ; 0Ch: informace o Q-kan lu
         dw        3140h                    ; 0Dh: informace o sub-kan lu
         dw        1059h                    ; 0Eh: UPC k¢d
         dw        128ch                    ; 0Fh: informace o stavu audio

                db      512 dup (0)         ; z sobn¡k
d_02D0                                      ; konec z sobn¡ku

d_02D0          dd      0

d_02D4          dw      300h                ; b zov  adresa ©adi‡e CD (data)
                                            ;  ‡ten¡ - data
                                            ;  z pis:
                                            ;         10h - ‡ten¡ parametr– disku
                                            ;               (max. a min. stopa)
                                            ;         11h - ‡ten¡ aktu ln¡ pozice hlavy
                                            ;         20h - dotaz na stav ©adi‡e
                                            ;               (vr t¡ 11 bajt–)
                                            ;         40h - test, zda je vlo‘en disk
                                            ;         60h - RESET disku
                                            ;         70h - PAUZA (zastaven¡)
                                            ;         8eh - ‡ten¡ stavu audio kan l–
                                            ;         90h -
                                            ;         B0h -
                                            ;         DCh - detekce regulace hlasitosti
                                            ;         F0h -
                                            ;         F6h - EJECT
                                            ;         FEh - n sleduje 1 bajt:
                                            ;               0 = odemknut¡ dv¡©ek
                                            ;               1 = uzamknut¡ dv¡©ek

d_02D6          dw      301h                ; b zov  adresa ©adi‡e CD + 1 (stav)
                                            ;   bit 1: 1=p©ipravena data ke ‡ten¡
                                            ;   bit 2: 1=©adi‡ zanepr zdnˆn
                                            ;            (nep©ipravena data)
d_02D8          dw      301h                ; b zov  adresa ©adi‡e CD + 1
d_02DA          dw      302h                ; b zov  adresa ©adi‡e CD + 2
                                            ;  z pis: 8=p©eru¨en¡ p©enosu DMA
d_02DC          dw      303h                ; b zov  adresa ©adi‡e CD + 3
d_02DE          dw      21h                 ; adresa masky ©adi‡e p©eru¨en¡
d_02E0          dw      0
d_02E2          dw      0                       ; segment storage
d_02E4          dw      0                   ; po‡et sektor– ke ‡ten¡
d_02E6          dw      0FFFFh              ; velikost disku v sektorech LOW
d_02E8          dw      0FFFFh              ; velikost disku v sektorech HIGH
d_02EA          dw      0
d_02EC          dw      0
d_02EE          dw      0FFFFh
d_02F0          dw      0FFFFh
d_02F2          dw      0                   ; ukazatel absolutn¡ho ‡¡sla sektoru
d_02F4          dw      0                   ; ukazatel absolutn¡ho ‡¡sla sektoru
d_02F6          dw      2                   ; po‡et buffer– 2 KB
d_02F8          dw      0
                db      0, 0
d_02FC          dw      0
d_02FE          dw      0
                db      0, 0, 0, 0
d_0304          dw      0
d_0306          dw      0
d_0308          dw      0FFFFh
d_030A          dw      0FFFFh
d_030C          dw      0
d_030E          dw      0
d_0310          dw      0
d_0312          dw      0
d_0314          dw      0
d_0316          dw      0
d_0318          dw      0                   ; p©enosov  adresa - offset
d_031A          dw      0                   ; p©enosov  adresa - segment
d_031C          dw      0
d_031E          dw      0
d_0320          dw      0
d_0322          dw      800h
d_0324          dw      0                       ; Data table (indexed access)
                db      126 dup (0)
d_03A4          dw      0                       ; Data table (indexed access)
                db      126 dup (0)

; ------ tabulka adres buffer– sektor–

d_0424          dw      64 dup(0)               ; Data table (indexed access)

; ------ tabulka ‡¡sel blok– 64 KB buffer– sektor– (0 nebo 1)

d_04A4          dw      64 dup(0)               ; Data table (indexed access)

d_0524          dw      0
d_0526          dw      0
d_0528          dw      0
d_052A          dw      0
d_052C          dw      0
d_052E          dw      0                   ; ‡asov  konstanta pro 0.25 ms HIGH
d_0530          dw      0                   ; ‡asov  konstanta pro 0.25 ms LOW
d_0532          dw      0                   ; sektor absolutnˆ HIGH
d_0534          dw      0                   ; sektor absolutnˆ LOW
d_0536          dw      0
d_0538          dw      0
d_053A          dd      00000h              ; adresa ovlada‡e extended pamˆti
d_053E          dw      0
d_0540          db      0
                db      15 dup (0)
d_0550          db      0
                db      15 dup (0)
d_0560          dw      0
d_0562          dw      82h                 ; adresa str nkov‚ho registru DMA
                db      0
                db      0
d_0566          dw      0
d_0568          dw      0
d_056A          dw      0
d_056C          dw      0
d_056E          dw      0

d_0570          dw      0
d_0572          dw      800h                ; velikost sektoru ke ‡ten¡ (bajt–)
d_0574          dw      0
d_0576          dw      0                       ; segment storage
d_0578          dw      0
d_057A          dw      0
d_057C          db      0
d_057D          db      0
d_057E          db      0
d_057F          db      0
d_0580          db      0
d_0581          db      0
d_0582          db      0
d_0583          db      0                   ; ‡¡slo nejni‘¨¡ stopy disku
d_0584          db      0                   ; ‡¡slo nejvy¨¨¡ stopy disku
d_0585          db      0                   ; minuta adresy v˜bˆhov‚ stopy
d_0586          db      0                   ; sekunda adresy v˜bˆhov‚ stopy
d_0587          db      0                   ; r me‡ek adresy v˜bˆhov‚ stopy
d_0588          db      0
d_0589          db      0
d_058A          db      0
d_058B          db      0                   ; po‘adovan  pozice - minuta
d_058C          db      0                   ; po‘adovan  pozice - sekunda
d_058D          db      0                   ; po‘adovan  pozice - r me‡ek
d_058E          db      0                   ; p©ijat˜ ©¡dic¡ a adresovac¡ bajt
d_058F          db      0                   ; aktu ln¡ ‡¡slo stopy
d_0590          db      0                   ; ukazatel nebo index
d_0591          db      0                   ; aktu ln¡ pozice na stopˆ - minuta
d_0592          db      0                   ; aktu ln¡ pozice na stopˆ - sekunda
d_0593          db      0                   ; aktu ln¡ pozice na stopˆ - r me‡ek
d_0594          db      0
d_0595          db      0                   ; aktu ln¡ pozice hlavy - minuta
d_0596          db      0                   ; aktu ln¡ pozice hlavy - sekunda
d_0597          db      0                   ; aktu ln¡ pozice hlavy - r me‡ek
                db      0
d_0599          db      0                   ; ‡¡slo kan lu ©adi‡e DMA
d_059A          db      2                   ; maska kan lu DMA (port 00DEh)
d_059B          db      45h                 ; povel pro ‡ten¡ kan lem DMA
d_059C          db      40h
d_059D          db      0
d_059E          db      40h                 ; k¢d podle ‡¡sla p©eru¨en¡
d_059F          db      2                   ; po‡et buffer– 2 KB
d_05A0          db      2
d_05A1          db      0
d_05A2          db      0
d_05A3          db      0
d_05A4          db      1
d_05A5          db      0
d_05A6          db      0
d_05A7          db      0
d_05A8          db      0
                db      0
d_05AA          db      0                   ; 80h=dv¡©ka otev©ena

; ------ buffer parametr– jednotliv˜ch stop (ka‘d  3 bajty)
; Struktura:  0: (1) minuta po‡ tku stopy
;             1: (1) sekunda po‡ tku stopy
;             2: (1) r me‡ek po‡ tku stopy

d_05AB          db      3*100 dup(0)

; ------ tabulka parametr– stop
;  bit 4: 1=pou‘ita preemf ze
;  bit 5: 1=z kaz digit ln¡ kopie
;  bit 6: 1=datov  stopa
;  bit 7: 1=4 kan ly audio, 0=2 kan ly audio

d_06D7          db      100 dup(0)

d_073B          db      0                   ; po‘adovan  stopa
d_073C          db      0                       ; Data table (indexed access)
                db      12 dup (0)
d_0749          db      0                       ; Data table (indexed access)
                db      12 dup (0)

d_0756          db      0                   ; 1=p©¡znak proveden¡ instalace
d_0757          db      0
d_0758          db      0
d_0759          db      0                   ; 1=disk je zn m˜ (zaveden˜)
d_075A          db      0
d_075B          db      0                   ; vstupn¡ kan l 0-3 pro v˜stup 0
d_075C          db      0                   ; vstupn¡ kan l 0-3 pro v˜stup 1
d_075D          db      0FFh
d_075E          db      0
d_075F          db      0FFh
d_0760          db      0
d_0761          db      0
d_0762          db      0
d_0763          db      0
d_0764          db      0
d_0765          db      0                   ; 1=uzamknut¡ dv¡©ek
d_0766          db      0                   ; rozsah regulace hlasitosti CD (44h)
d_0767          db      0
d_0768          db      0
d_0769          db      0                   ; hlasitost kan lu 0
d_076A          db      0                   ; hlasitost kan lu 1
d_076B          db      0
d_076C          db      0                   ; velikost skupiny prokl d n¡
d_076D          db      0                   ; velikost skupiny prokl d n¡
d_076E          db      0                   ; mezera mezi skupinami prokl d n¡
d_076F          db      0                   ; mezera mezi skupinami prokl d n¡
d_0770          db      0
d_0771          db      0                   ; 1=p©¡znak MONO m¢du
d_0772          db      0
d_0773          db      0                   ; typ procesoru
d_0774          db      0
d_0775          db      0                   ; 1=nen¡ podporov no prokl d n¡
d_0776          db      0
d_0777          db      0
d_0778          db      0                   ; 1=p©¡znak ‡ek n¡ na p©ipravenost ©adi‡e
d_0779          db      1
d_077A          db      0                   ; p©¡znak extended pamˆti
d_077B          db      0
d_077C          db      2
d_077D          db      0
d_077E          db      0
d_077F          db      0
d_0780          db      0
d_0781          db      0
d_0782          db      0
d_0783          db      0                   ; po‘adovan  pozice vystaven¡ - minuty
d_0784          db      0                   ; po‘adovan  pozice vystaven¡ - sekundy
d_0785          db      0                   ; po‘adovan  pozice vystaven¡ - r me‡ky
d_0786          db      0
d_0787          db      0

d_0788          db      0
d_0789          db      0
d_078A          db      1
d_078B          db      0                   ; 1=podporov ny sub-kan ly
d_078C          db      0                   ; 1=m‚dium nezmˆnˆno
d_078D          db      0
d_078E          db      0FBh                ; maska pro uvolnˆn¡ ©adi‡e p©eru¨en¡
d_078F          db      62h                 ; povel pro uvolnˆn¡ ©adi‡e p©eru¨en¡
d_0790          db      0
d_0791          db      0
d_0792          db      0

mtmcdae         endp

;==========================================================================
;
;                       External Entry Point
;
;==========================================================================

strategy        proc    far
                mov     word ptr cs:d_0016,bx   ; (=0)
                mov     word ptr cs:d_0016+2,es ; (=8535h)
                retf                            ; Return far
strategy        endp


;==========================================================================
;
;                       External Entry Point
;
;==========================================================================

commands        proc    far
                pushf                           ; Push flags
                push    ax
                push    bx
                push    cx
                push    dx
                push    si
                push    di
                push    bp
                push    ds
                push    es
                mov     ax,cs
                mov     ds,ax
                cld                             ; Clear direction
                cli                             ; Disable interrupts
                mov     d_02E0,sp               ; (=0)
                mov     d_02E2,ss               ; (=0CD7h)
                mov     ss,ax
                mov     sp,2D0h
                sti                             ; Enable interrupts
                mov     d_0758,0                ; (=0)
                les     bx,d_0016               ; (=0) Load 32 bit ptr
                mov     al,es:[bx+2]
                or      al,al                   ; Zero ?

                jnz     l_07DC                  ; Jump if not zero
                cmp     d_0756,1                ; 1=p©¡znak proveden¡ instalace
                je      l_07F9                  ; Jump if equal
                mov     d_0756,1            ; 1=p©¡znak proveden¡ instalace
                jmp     l_3B90

l_07DC:         mov     si,62h              ; tabulka povel– 0 a‘ 0fh
                mov     cl,10h              ; max. povel
                cmp     al,80h
                jb      l_07EC                  ; Jump if below
                mov     si,offset d_0082        ; tabulka povel– 80h a‘ 88h
                mov     cl,9
                sub     al,80h
l_07EC:
                cmp     al,cl
                jb      l_07F2                  ; Jump if below
                jmp     short l_07F9
l_07F2:
                cbw                             ; Convrt byte to word
                shl     ax,1                    ; Shift w/zeros fill
                add     si,ax
                jmp     word ptr [si]           ; obsluha funkce

l_07F9:
                mov     ax,8003h
                jmp     short l_0801
l_07FE:
                or      ax,200h
l_0801:
                or      ax,100h
                test    ax,8000h
                jz      l_080E                  ; Jump if zero
                mov     bl,2
                call    s_3076              ; odemknut¡/uzamknut¡ dv¡©ek
l_080E:
                cmp     byte ptr ds:d_0000_0776_e,0 ; (=80h)
                je      l_081D                  ; Jump if equal
                mov     byte ptr ds:d_0000_0776_e,0 ; (=80h)
                and     ax,7FF0h
l_081D:
                les     bx,dword ptr ds:d_0000_0016_e ; (=0F000h) Load 32 bit ptr
                mov     es:[bx+3],ax
                cli                             ; Disable interrupts
                mov     sp,ds:d_0000_02E0_e     ; (=0)
                mov     ss,ds:d_0000_02E2_e     ; (=0)
                sti                             ; Enable interrupts
                pop     es
                pop     ds
                pop     bp
                pop     di
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                popf                            ; Pop flags
                retf                            ; Return far
commands        endp


l_083A:
                call    s_2E74              ; ukon‡en¡ v¨ech p©enos– s CD
                call    s_2B4D              ; test, zda je vlo‘en disk
                cmp     al,1
                je      l_0849                  ; Jump if equal
                mov     ax,8003h
                jmp     short l_0801
l_0849:
                mov     ax,8003h
                jmp     short l_07FE
l_084E:
                mov     ax,800Ch
                jmp     short l_0801
l_0853:
                mov     ax,800Ch
                jmp     short l_07FE
l_0858:
                mov     ax,8006h
                jmp     short l_0801
l_085D:
                mov     ax,800Bh
                jmp     short l_0801
l_0862:
                cmp     d_05A8,0                ; (=0)
                je      l_086E                  ; Jump if equal
l_0869:
                mov     ax,8008h
                jmp     short l_07FE
l_086E:
                mov     ax,8008h
                jmp     short l_0801
l_0873:
                mov     ax,8002h
                jmp     short l_0801
l_0878:
                xor     ax,ax                   ; Zero register
                jmp     short l_0801
l_087C:
                xor     ax,ax                   ; Zero register
                jmp     l_07FE

; -----------------------------------------------------------------------------
;        funkce 03h: VSTUP IOCTL
; -----------------------------------------------------------------------------
;þ
l_0881:

                                                ;* No entry point to code
                mov     si,offset d_00B0        ; tabulka skok–
                mov     cl,0Fh
                les     di,dword ptr es:[bx+0Eh] ; adresa po‘adavku
                xor     ah,ah                   ; Zero register
                mov     al,es:[di]          ; povel
                inc     di
                cmp     al,cl
                jbe     l_0896                  ; Jump if below or =
                jmp     short l_083A
l_0896:
                shl     ax,1                    ; Shift w/zeros fill
                add     si,ax
                jmp     word ptr [si]           ;*

; -----------------------------------------------------------------------------
;        funkce VSTUP IOCTL 00h: adresa z hlav¡ za©¡zen¡
; -----------------------------------------------------------------------------
;þ
l_089C:
                mov     ax,0
                mov     es:[di],ax          ; offset
                mov     ax,cs
                mov     es:[di+2],ax        ; segment

l_08A8:         call    s_2E74              ; ukon‡en¡ v¨ech p©enos– s CD
                call    s_2B4D              ; test, zda je vlo‘en disk
                cmp     al,1
                je      l_08B4                  ; Jump if equal
                jmp     short l_0878

l_08B4:         jmp     short l_087C

; -----------------------------------------------------------------------------
;        funkce VSTUP IOCTL 01h: aktu ln¡ pozice hlav
; -----------------------------------------------------------------------------
;þ
l_08B6:
                call    s_2E74              ; ukon‡en¡ v¨ech p©enos– s CD ;
                mov     d_05A5,1                ; (=0)
                mov     d_076B,3                ; (=0)
l_08C3:
                call    s_2B1A              ; p©eru¨en¡ p©enosu DMA
                call    s_2BD6              ; na‡ten¡ stavu ©adi‡e CD
                or      al,al                   ; Zero ?
                jz      l_08E9              ; v¨e je OK
                cmp     al,0FFh
                jne     l_08E3                  ; Jump if not equal
                dec     d_076B                  ; (=0)
                jnz     l_08C3                  ; Jump if not zero
                mov     d_05A6,0                ; (=0)
                mov     d_05A7,0                ; (=0)
                jmp     short l_0873

l_08E3:
                cmp     al,2
                jne     l_08F8                  ; Jump if not equal
                jmp     short l_0873

; ------ rozli¨en¡ adresov n¡

l_08E9:         cmp     byte ptr es:[di],0  ; je adresov n¡ HSG ?
                je      l_0928              ; adresov n¡ HSG
                cmp     byte ptr es:[di],1
                je      l_08F8              ; adresov n¡ Red Book
                jmp     l_083A

; ------ je adresov n¡ Red Book

l_08F8:         inc     di
                mov     al,d_0597           ; aktu ln¡ pozice hlavy - r me‡ek
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                mov     es:[di],al          ; aktu ln¡ pozice hlavy - r me‡ek
                inc     di
                mov     al,d_0596           ; aktu ln¡ pozice hlavy - sekunda
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                mov     es:[di],al          ; aktu ln¡ pozice hlavy - sekunda
                inc     di
                mov     al,d_0595           ; aktu ln¡ pozice hlavy - minuta
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                mov     es:[di],al          ; aktu ln¡ pozice hlavy - minuta
                inc     di
                mov     byte ptr es:[di],0  ; nepou‘it˜ bajt

l_091B:
                test    d_05AA,2            ; 80h=dv¡©ka otev©ena
                jnz     l_0925                  ; Jump if not zero
                jmp     l_0878
l_0925:
                jmp     l_087C

; ----- adresov n¡ HSG

l_0928:         mov     al,d_0595           ; aktu ln¡ pozice hlavy - minuta
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                mov     dl,al               ; DL <- minuta
                mov     al,d_0596           ; aktu ln¡ pozice hlavy - sekunda
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                mov     dh,al               ; DH <- sekunda
                mov     al,d_0597           ; aktu ln¡ pozice hlavy - r me‡ek
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                mov     ah,dh               ; sekunda
                call    s_2DFB              ; p©epo‡et MM:SS:FF na r me‡ek DX:AX
                sub     ax,96h              ; korekce - 150
                sbb     dx,0
                inc     di
                mov     es:[di],ax          ; aktu ln¡ pozice hlavy v m¢du HSG
                inc     di
                inc     di
                mov     es:[di],dx
                jmp     short l_091B

; -----------------------------------------------------------------------------
;        funkce VSTUP IOCTL 04h: informace o audio kan lech
; -----------------------------------------------------------------------------

l_0954:
                                                ;* No entry point to code
                xor     ax,ax                   ; Zero register
                mov     d_075B,al           ; vstupn¡ kan l 0-3 pro v˜stup 0
                mov     d_075C,1            ; vstupn¡ kan l 0-3 pro v˜stup 1
                mov     d_0769,al           ; hlasitost kan lu 0
                mov     d_076A,al           ; hlasitost kan lu 1
                call    s_2E74              ; ukon‡en¡ v¨ech p©enos– s CD
                mov     d_076B,3                ; (=0)
l_096C:
                call    s_2B1A              ; p©eru¨en¡ p©enosu DMA
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,8Eh              ; povel pro ‡ten¡ stavu audio kan l–
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                jne     l_0986                  ; Jump if not equal
                dec     d_076B                  ; (=0)
                jnz     l_096C                  ; Jump if not zero
                jmp     l_0873
l_0986:
                call    s_2DC7              ; vstup datov‚ho bajtu z ©adi‡e CD
                cmp     al,0FFh
                jne     l_0990                  ; Jump if not equal
                jmp     l_0873
l_0990:
                or      bl,bl                   ; Zero ?
                jz      l_099D                  ; Jump if zero
                mov     d_0769,bl           ; hlasitost kan lu 0
                mov     d_075B,0            ; vstupn¡ kan l 0-3 pro v˜stup 0
l_099D:
                call    s_2DC7              ; vstup datov‚ho bajtu z ©adi‡e CD
                cmp     al,0FFh
                jne     l_09A7                  ; Jump if not equal
                jmp     l_0873
l_09A7:
                or      bl,bl                   ; Zero ?
                jz      l_09B4                  ; Jump if zero

                mov     d_076A,bl           ; hlasitost kan lu 1
                mov     d_075C,0            ; vstupn¡ kan l 0-3 pro v˜stup 1
l_09B4:
                call    s_2DC7              ; vstup datov‚ho bajtu z ©adi‡e CD
                cmp     al,0FFh
                jne     l_09BE                  ; Jump if not equal
                jmp     l_0873
l_09BE:
                or      bl,bl                   ; Zero ?
                jz      l_09CB                  ; Jump if zero
                mov     d_076A,bl           ; hlasitost kan lu 1
                mov     d_075C,1            ; vstupn¡ kan l 0-3 pro v˜stup 1
l_09CB:
                call    s_2DC7              ; vstup datov‚ho bajtu z ©adi‡e CD
                cmp     al,0FFh
                jne     l_09D5                  ; Jump if not equal
                jmp     l_0873
l_09D5:
                or      bl,bl                   ; Zero ?
                jz      l_09E2                  ; Jump if zero
                mov     d_0769,bl           ; hlasitost kan lu 0
                mov     d_075B,1            ; vstupn¡ kan l 0-3 pro v˜stup 0
l_09E2:
                cmp     d_0787,1                ; (=0)
                jne     l_0A01                  ; Jump if not equal
                cmp     d_0769,0            ; hlasitost kan lu 0
                jne     l_0A01                  ; Jump if not equal
                cmp     d_076A,0            ; hlasitost kan lu 1
                jne     l_0A01                  ; Jump if not equal
                mov     al,d_075B           ; vstupn¡ kan l 0-3 pro v˜stup 0
                xchg    d_075C,al           ; vstupn¡ kan l 0-3 pro v˜stup 1
                mov     d_075B,al           ; vstupn¡ kan l 0-3 pro v˜stup 0
l_0A01:
                mov     al,d_075B           ; vstupn¡ kan l 0-3 pro v˜stup 0
                stosb                           ; vstup 0-3 pro v˜stup 0
                mov     al,d_0769           ; hlasitost kan lu 0
                cmp     d_0766,44h          ; rozsah regulace hlasitosti CD (44h)
                je      l_0A15                  ; Jump if equal
                or      al,al                   ; Zero ?
                jz      l_0A15                  ; Jump if zero
                mov     al,0FFh
l_0A15:
                stosb                           ; hlasitost kan lu 0
                mov     al,d_075C           ; vstupn¡ kan l 0-3 pro v˜stup 1
                stosb                           ; Store al to es:[di]
                mov     al,d_076A           ; hlasitost kan lu 1
                cmp     d_0766,44h          ; rozsah regulace hlasitosti CD (44h)
                je      l_0A2A                  ; Jump if equal
                or      al,al                   ; Zero ?
                jz      l_0A2A                  ; Jump if zero
                mov     al,0FFh
l_0A2A:
                stosb                       ; hlasitost kan lu 1
                mov     al,2                ; vstupn¡ kan l 2 pro v˜stup 2
                stosb                           ; Store al to es:[di]
                xor     al,al               ; hlasitost kan lu 2
                stosb                           ; Store al to es:[di]

                mov     al,3                ; vstupn¡ kan l 3 pro v˜stup 3
                stosb                           ; Store al to es:[di]
                xor     al,al               ; hlasitost kan lu 3
                stosb                           ; Store al to es:[di]
                test    d_05AA,2            ; 80h=dv¡©ka otev©ena
                jnz     l_0A41                  ; Jump if not zero
                jmp     l_0878
l_0A41:
                jmp     l_087C

; -----------------------------------------------------------------------------
;        funkce VSTUP IOCTL 05h: bajtu RAW disku
; -----------------------------------------------------------------------------
;þ
l_0A44:
                                                ;* No entry point to code
                mov     byte ptr es:[di],0
                jmp     l_08A8

; -----------------------------------------------------------------------------
;        funkce VSTUP IOCTL 06h: stav za©¡zen¡
; -----------------------------------------------------------------------------
;þ
l_0A4B:
                call    s_2E74              ; ukon‡en¡ v¨ech p©enos– s CD
                call    s_2B4D              ; test, zda je vlo‘en disk
                cmp     al,0FFh
                jne     l_0A58                  ; Jump if not equal
                jmp     l_0873
l_0A58:
                cmp     al,2
                jne     l_0A61                  ; Jump if not equal
                mov     cx,0C00h            ; p©ehr v  se
                jmp     short l_0A64
l_0A61:
                mov     cx,400h             ; je disk, p©ehr v  se
l_0A64:
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,0FEh
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,2
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                je      l_0A96                  ; Jump if equal
                call    s_2DC7              ; vstup datov‚ho bajtu z ©adi‡e CD
                cmp     al,0FFh
                je      l_0A96                  ; Jump if equal
                cmp     bl,1
                jne     l_0A87                  ; Jump if not equal
                or      cx,520h             ; dv¡©ka uzamknuta
                jmp     short l_0A8B
l_0A87:         or      cx,522h             ; dv¡©ka odemknuta

l_0A8B:         test    d_05AA,80h          ; 80h=dv¡©ka otev©ena
                jz      l_0A96                  ; Jump if zero
                or      cx,521h             ; dv¡©ka otev©ena

l_0A96:
                mov     ax,1694h            ; parametry
                or      ax,cx

                cmp     d_0775,0            ; 1=nen¡ podporov no prokl d n¡
                je      l_0AA5                  ; Jump if equal
                and     ax,0FFDFh           ; nen¡ podporov no prokl d n¡
l_0AA5:
                cmp     d_078B,1            ; 1=podporov ny sub-kan ly
                je      l_0AAF                  ; Jump if equal
                and     ax,0EFFFh           ; nen¡ podpora subkan l–

l_0AAF:
                mov     es:[di],ax          ; parametry za©¡zen¡
                mov     word ptr es:[di+2],0
                test    d_05AA,2            ; 80h=dv¡©ka otev©ena
                jz      l_0AC2                  ; Jump if zero
                jmp     l_087C
l_0AC2:
                jmp     l_0878

; -----------------------------------------------------------------------------
;        funkce VSTUP IOCTL 07h: velikost sektoru
; -----------------------------------------------------------------------------
;þ
l_0AC5:
                cmp     byte ptr es:[di],0
                je      l_0ADD                  ; Jump if equal
                cmp     byte ptr es:[di],1
                je      l_0AD4                  ; Jump if equal
                jmp     l_083A
l_0AD4:
                mov     word ptr es:[di+1],930h  ; 2352 B
                jmp     l_08A8
l_0ADD:
                mov     word ptr es:[di+1],800h  ; 2048 B
                jmp     l_08A8

; -----------------------------------------------------------------------------
;        funkce VSTUP IOCTL 08h: velikost disku
; -----------------------------------------------------------------------------
;þ
l_0AE6:
                                                ;* No entry point to code
                mov     d_05A5,1                ; (=0)
                call    s_2E74              ; ukon‡en¡ v¨ech p©enos– s CD
                call    s_2AB6              ; zji¨tˆn¡ velikosti disku (v sektorech)
                cmp     al,0FFh
                jne     l_0B02                  ; Jump if not equal
                mov     d_05A6,0                ; (=0)
                mov     d_05A7,0                ; (=0)
                jmp     l_0873
l_0B02:
                cmp     al,2
                jne     l_0B09                  ; Jump if not equal
                jmp     l_0873
l_0B09:
                mov     ax,d_02E6           ; velikost disku v sektorech LOW
                stosw                           ; Store ax to es:[di]
                mov     ax,d_02E8           ; velikost disku v sektorech HIGH
                stosw                           ; Store ax to es:[di]
                test    d_05AA,2            ; 80h=dv¡©ka otev©ena
                jnz     l_0B1B                  ; Jump if not zero
                jmp     l_0878
l_0B1B:
                jmp     l_087C

; -----------------------------------------------------------------------------
;        funkce 01h: kontrola v˜mˆny m‚dia
; -----------------------------------------------------------------------------
;þ
l_0B1E:
                                                ;* No entry point to code
                mov     d_078C,1            ; 1=m‚dium nezmˆnˆno
                jmp     short l_0B2A

; -----------------------------------------------------------------------------
;        funkce VSTUP IOCTL 09h: stav v˜mˆny m‚dia
; -----------------------------------------------------------------------------
;þ
l_0B25:
                db      0C6h, 06h, 8Ch, 07h, 00h

l_0B2A:
                cmp     d_05A4,1                ; (=1)
                je      l_0B3A                  ; Jump if equal
                cmp     d_0757,1                ; (=0)
                je      l_0B8D                  ; Jump if equal
                jmp     short l_0BA6
l_0B3A:
                mov     d_05A5,1                ; (=0)
                call    s_2E74              ; ukon‡en¡ v¨ech p©enos– s CD
                call    s_2B4D              ; test, zda je vlo‘en disk

                cmp     al,2
                jne     l_0B60                  ; Jump if not equal
                cmp     d_078C,1            ; 1=m‚dium nezmˆnˆno
                je      l_0B53                  ; Jump if equal
                mov     al,0FFh
                stosb                           ; Store al to es:[di]
l_0B53:
                cmp     d_078C,1            ; 1=m‚dium nezmˆnˆno
                je      l_0B5D                  ; Jump if equal
                jmp     l_0878
l_0B5D:
                jmp     l_083A
l_0B60:
                cmp     d_0757,1                ; (=0)
                je      l_0B8D                  ; Jump if equal
                mov     cx,d_02E6           ; velikost disku v sektorech LOW
                mov     bx,d_02E8           ; velikost disku v sektorech HIGH
                push    cx
                push    bx
                call    s_2AB6              ; zji¨tˆn¡ velikosti disku (v sektorech)
                pop     bx
                pop     cx
                cmp     al,0FFh
                je      l_0B8D                  ; Jump if equal
                cmp     d_0757,1                ; (=0)
                je      l_0B8D                  ; Jump if equal
                cmp     cx,d_02E6           ; velikost disku v sektorech LOW
                jne     l_0B8D                  ; Jump if not equal
                cmp     bx,d_02E8           ; velikost disku v sektorech HIGH
                je      l_0BA6                  ; Jump if equal
l_0B8D:
                cmp     d_078C,1            ; 1=m‚dium nezmˆnˆno
                je      l_0B97                  ; Jump if equal
                mov     al,0FFh             ; m‚dium vymˆnˆno
                stosb                           ; Store al to es:[di]
l_0B97:
                mov     d_0757,0                ; (=0)
                cmp     d_078C,1            ; 1=m‚dium nezmˆnˆno
                je      l_0BBE                  ; Jump if equal
                jmp     l_0878
l_0BA6:
                cmp     d_078C,1            ; 1=m‚dium nezmˆnˆno
                je      l_0BBE                  ; Jump if equal
                mov     ax,1                ; m‚dium nezmˆnˆno
                stosb                           ; Store al to es:[di]
                test    d_05AA,2            ; 80h=dv¡©ka otev©ena
                jnz     l_0BBB                  ; Jump if not zero
                jmp     l_0878
l_0BBB:
                jmp     l_087C
l_0BBE:
                jmp     l_083A

; -----------------------------------------------------------------------------
;        funkce VSTUP IOCTL 0Ah: informace o disku
; -----------------------------------------------------------------------------
;þ
l_0BC1:
                                                ;* No entry point to code
                call    s_2E74              ; ukon‡en¡ v¨ech p©enos– s CD
                call    s_2AB6              ; zji¨tˆn¡ velikosti disku (v sektorech)
                cmp     al,0FFh
                jne     l_0BD8                  ; Jump if not equal

                mov     d_05A6,0                ; (=0)
                mov     d_05A7,0                ; (=0)
                jmp     l_0873
l_0BD8:
                cmp     al,2
                jne     l_0BDF                  ; Jump if not equal
                jmp     l_0873
l_0BDF:
                mov     al,d_0583           ; ‡¡slo nejni‘¨¡ stopy disku
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                stosb                       ; ‡¡slo nejni‘¨¡ stopy disku

                mov     al,d_0584           ; ‡¡slo nejvy¨¨¡ stopy disku
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                stosb                       ; ‡¡slo nejvy¨¨¡ stopy disku

                mov     al,d_0587           ; r me‡ek adresy v˜bˆhov‚ stopy
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                stosb                       ; r me‡ek adresy v˜bˆhov‚ stopy

                mov     al,d_0586           ; sekunda adresy v˜bˆhov‚ stopy
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                stosb                       ; sekunda adresy v˜bˆhov‚ stopy

                mov     al,d_0585           ; minuta adresy v˜bˆhov‚ stopy
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                stosb                       ; minuta adresy v˜bˆhov‚ stopy

                xor     ax,ax                   ; Zero register
                stosb                       ; neplatn  0

                test    d_05AA,2            ; 80h=dv¡©ka otev©ena
                jnz     l_0C0F                  ; Jump if not zero
                jmp     l_0878
l_0C0F:
                jmp     l_087C

; -----------------------------------------------------------------------------
;        funkce VSTUP IOCTL 0Bh: informace o stopˆ
; -----------------------------------------------------------------------------
;þ
l_0C12:
                                                ;* No entry point to code
                call    s_2E74              ; ukon‡en¡ v¨ech p©enos– s CD
                call    s_2B4D              ; test, zda je vlo‘en disk
                or      al,al                   ; Zero ?
                jz      l_0C23                  ; Jump if zero
                cmp     al,1
                je      l_0C23                  ; Jump if equal
                jmp     l_0873
l_0C23:
                xor     si,si                   ; Zero register
                mov     al,d_073C[si]
                mov     cx,0Ch

l_0C2C:
                inc     si
                and     al,d_073C[si]           ; (=0)
                loop    l_0C2C                  ; Loop if cx > 0

                cmp     al,0FFh
                je      l_0C4B                  ; Jump if equal
                call    s_0CA9              ; na‡ten¡ informac¡ o stopˆ
                mov     d_05A6,0                ; (=0)
                mov     d_05A7,0                ; (=0)
                or      al,al                   ; Zero ?
                jz      l_0C4B                  ; Jump if zero
                jmp     l_0873

l_0C4B:         mov     al,es:[di]          ; po‘adovan  stopa
                mov     d_073B,al           ; po‘adovan  stopa
                xor     cx,cx                   ; Zero register
                mov     cl,al
                mov     al,d_0584           ; ‡¡slo nejvy¨¨¡ stopy disku
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                mov     ah,cl
                cmp     ah,al               ; kontrola ‡¡sla stopy
                jbe     l_0C64                  ; Jump if below or =
                jmp     l_083A
l_0C64:
                mov     al,ah
                mov     cl,3
                mul     cl                      ; ax = reg * al
                inc     ax
                inc     ax
                mov     bp,ax

                mov     al,ds:d_05AB[bp]    ; buffer parametr– stop
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                inc     di
                stosb                       ; r me‡ek adresy po‡ tku stopy

                dec     bp
                mov     al,ds:d_05AB[bp]    ; buffer parametr– stop
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                stosb                       ; sekunda adresy po‡ tku stopy

                dec     bp
                mov     al,ds:d_05AB[bp]    ; buffer parametr– stop     ; (=0)
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                stosb                       ; minuta adresy po‡ tku stopy

                xor     ax,ax                   ; Zero register
                stosb                       ; nepou‘it˜ bajt

                xor     bx,bx                   ; Zero register
                mov     bl,d_073B           ; po‘adovan  stopa
                mov     al,d_06D7[bx]       ; tabulka parametr– stop
                and     al,0F0h
                stosb                           ; Store al to es:[di]
                test    d_05AA,2            ; 80h=dv¡©ka otev©ena
                jnz     l_0CA6                  ; Jump if not zero
                jmp     l_0878
l_0CA6:
                jmp     l_087C

;==========================================================================
;                              SUBROUTINE
;==========================================================================

s_0CA9          proc    near
                call    s_2B4D              ; test, zda je vlo‘en disk
                cmp     al,0FFh
                jne     l_0CB1                  ; Jump if not equal
                retn
l_0CB1:
                cmp     al,2
                jne     l_0CB6                  ; Jump if not equal
                retn
l_0CB6:
                call    s_2AB6              ; zji¨tˆn¡ velikosti disku (v sektorech)

                cmp     al,0FFh
                jne     l_0CBE                  ; Jump if not equal
                retn
l_0CBE:
                cmp     al,2
                jne     l_0CC3                  ; Jump if not equal
                retn
l_0CC3:
                mov     bp,73Ch
                mov     dl,d_0583           ; ‡¡slo nejni‘¨¡ stopy disku
                mov     dh,d_0584           ; ‡¡slo nejvy¨¨¡ stopy disku
                call    s_0F3C
                mov     d_077B,0                ; (=0)
                mov     d_077C,2                ; (=2)
                mov     d_077D,0                ; (=0)
l_0CE0:
                mov     d_077E,0                ; (=0)
                mov     d_076B,6                ; (=0)
l_0CEA:
                mov     al,d_077B               ; (=0)
                mov     d_057C,al               ; (=0)
                mov     al,d_077C               ; (=2)
                mov     d_057D,al               ; (=0)
                mov     al,d_077D               ; (=0)
                mov     d_057E,al               ; (=0)
                mov     d_057F,0                ; (=0)
                mov     d_0580,0                ; (=0)
                mov     d_0581,0                ; (=0)
                mov     bl,1
                call    s_3076              ; odemknut¡/uzamknut¡ dv¡©ek
                call    s_2D1C
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,2
                jne     l_0D1B                  ; Jump if not equal
                retn
l_0D1B:
                test    bl,5
                jnz     l_0D24                  ; Jump if not zero
                cmp     al,0FFh
                jne     l_0D2B                  ; Jump if not equal
l_0D24:
                dec     d_076B                  ; (=0)
                jnz     l_0CEA                  ; Jump if not zero
                retn
l_0D2B:
                mov     bl,0
                call    s_3076              ; odemknut¡/uzamknut¡ dv¡©ek
                mov     d_076B,3                ; (=0)
l_0D35:
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,50h                  ; 'P'
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,5
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                jne     l_0D4D                  ; Jump if not equal

l_0D46:
                dec     d_076B                  ; (=0)
                jnz     l_0D35                  ; Jump if not zero
                retn
l_0D4D:
                test    bl,1
                jz      l_0D54                  ; Jump if zero
                jmp     short l_0D46
l_0D54:
                mov     d_0320,7D0h             ; (=0)
l_0D5A:
                dec     d_0320                  ; (=0)
                jnz     l_0D63                  ; Jump if not zero
                jmp     l_0E80
l_0D63:
                mov     d_076B,3                ; (=0)
l_0D68:
                call    s_2BD6              ; na‡ten¡ stavu ©adi‡e CD
                cmp     al,2
                jne     l_0D70                  ; Jump if not equal
                retn
l_0D70:
                cmp     al,0FFh
                jne     l_0D7D                  ; Jump if not equal
                dec     d_076B                  ; (=0)
                jnz     l_0D68                  ; Jump if not zero
                jmp     l_0E80
l_0D7D:
                mov     al,d_058F           ; aktu ln¡ ‡¡slo stopy
                or      al,al                   ; Zero ?
                jnz     l_0D5A                  ; Jump if not zero
                cmp     d_077E,7                ; (=0)
                jne     l_0D8E                  ; Jump if not equal
                jmp     l_0E19
l_0D8E:
                cmp     d_077E,3                ; (=0)
                je      l_0DD9                  ; Jump if equal
                cmp     d_0590,0A0h         ; ukazatel nebo index
                jne     l_0DB0                  ; Jump if not equal
                mov     al,d_0595           ; aktu ln¡ pozice hlavy - minuta
                mov     d_077F,al               ; (=0)
                or      d_077E,1                ; (=0)
                cmp     d_077E,3                ; (=0)
                je      l_0DC9                  ; Jump if equal
                jmp     short l_0D5A
l_0DB0:
                cmp     d_0590,0A1h         ; ukazatel nebo index
                jne     l_0DD7                  ; Jump if not equal
                mov     al,d_0595           ; aktu ln¡ pozice hlavy - minuta
                mov     d_0780,al               ; (=0)
                or      d_077E,2                ; (=0)
                cmp     d_077E,3                ; (=0)
                jne     l_0DD7                  ; Jump if not equal
l_0DC9:
                mov     bp,749h
                mov     dl,d_077F               ; (=0)
                mov     dh,d_0780               ; (=0)

                call    s_0F3C
l_0DD7:
                jmp     short l_0D5A
l_0DD9:
                mov     al,d_0590           ; ukazatel nebo index
                cmp     al,99h
                ja      l_0DD7                  ; Jump if above
                mov     bp,749h
                call    s_0EF2
                mov     bp,73Ch
                call    s_0EF2
                call    s_0EAA              ; ukazatel parametr– do tabulky stop
                xor     si,si                   ; Zero register
                mov     al,d_0749[si]           ; (=0)
                mov     cx,0Ch

l_0DF8:
                inc     si
                and     al,d_0749[si]           ; (=0)
                loop    l_0DF8                  ; Loop if cx > 0

                cmp     al,0FFh
                je      l_0E06                  ; Jump if equal
                jmp     l_0D5A
l_0E06:
                mov     al,d_0584           ; ‡¡slo nejvy¨¨¡ stopy disku
                cmp     d_0780,al               ; (=0)
                jne     l_0E11                  ; Jump if not equal
                jmp     short l_0E5E
l_0E11:
                mov     d_077E,7                ; (=0)
l_0E16:
                jmp     l_0D5A
l_0E19:
                cmp     d_0590,0B0h         ; ukazatel nebo index
                jne     l_0E16                  ; Jump if not equal
                mov     al,d_0591           ; aktu ln¡ pozice na stopˆ - minuta
                mov     d_077B,al               ; (=0)
                mov     al,d_0592           ; aktu ln¡ pozice na stopˆ - sekunda
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                add     al,2
                cmp     al,3Bh                  ; ';'
                jbe     l_0E44                  ; Jump if below or =
                push    ax
                mov     al,d_077B               ; (=0)
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                add     al,1
                call    s_2E28              ; p©evod bin rn¡ho ‡¡sla v AL na BCD ‡¡slo
                mov     d_077B,al               ; (=0)
                pop     ax
                sub     al,3Ch                  ; '<'
l_0E44:
                call    s_2E28              ; p©evod bin rn¡ho ‡¡sla v AL na BCD ‡¡slo
                mov     d_077C,al               ; (=2)
                mov     al,d_0593           ; aktu ln¡ pozice na stopˆ - r me‡ek
                mov     d_077D,al               ; (=0)
                call    s_0E8D

                cmp     al,0FFh
                jne     l_0E58                  ; Jump if not equal
                retn
l_0E58:
                call    s_3068
                jmp     l_0CE0
l_0E5E:
                xor     si,si                   ; Zero register
                mov     al,d_073C[si]           ; (=0)
                mov     cx,0Ch

l_0E67:
                inc     si
                and     al,d_073C[si]           ; (=0)
                loop    l_0E67                  ; Loop if cx > 0

                cmp     al,0FFh
                je      l_0E75                  ; Jump if equal
                jmp     l_0D5A
l_0E75:
                call    s_0E8D
                cmp     al,0FFh
                jne     l_0E7D                  ; Jump if not equal
                retn
l_0E7D:
                xor     al,al                   ; Zero register
                retn
l_0E80:
                call    s_305B
                call    s_0E8D
                cmp     al,0FFh
                je      l_0E8C                  ; Jump if equal
                mov     al,1

l_0E8C:
                retn
s_0CA9          endp


;==========================================================================
;                              SUBROUTINE
;==========================================================================

s_0E8D          proc    near
                mov     d_076B,3                ; (=0)
l_0E92:
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,50h                  ; 'P'
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,1
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                jne     l_0EA9                  ; Jump if not equal
                dec     d_076B                  ; (=0)
                jnz     l_0E92                  ; Jump if not zero


l_0EA9:
                retn
s_0E8D          endp


;==========================================================================
;        ukazatel parametr– do tabulky stop
;==========================================================================

s_0EAA          proc    near
                mov     ax,5ABh
                mov     d_0524,ax           ; ukazatel v tabulce parametr–
                xor     bx,bx                   ; Zero register
                mov     al,d_0590           ; ukazatel nebo index
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                mov     bl,al
                mov     al,d_058E           ; p©ijat˜ ©¡dic¡ a adresovac¡ bajt
                mov     d_06D7[bx],al           ; (=0)
                mov     al,d_0590           ; ukazatel nebo index
                jz      l_0ED3                  ; Jump if zero
                mov     ax,d_0524               ; (=0)
l_0EC9:
                add     ax,3
                mov     d_0524,ax               ; (=0)
                dec     bl
                jnz     l_0EC9                  ; Jump if not zero
l_0ED3:
                mov     bx,d_0524               ; (=0)
                mov     cx,5ABh
                sub     bx,cx
                mov     al,d_0595           ; aktu ln¡ pozice hlavy - minuta
                mov     d_05AB[bx],al       ; buffer parametr– stop
                mov     al,d_0596           ; aktu ln¡ pozice hlavy - sekunda
                mov     d_05AC[bx],al           ; (=0)
                mov     al,d_0597           ; aktu ln¡ pozice hlavy - r me‡ek
                mov     d_05AD[bx],al           ; (=0)
                retn
s_0EAA          endp

;==========================================================================
;                              SUBROUTINE
;==========================================================================

s_0EF2          proc    near
                mov     ax,bp
                mov     d_0524,ax               ; (=0)
                mov     al,d_0590           ; ukazatel nebo index
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                mov     cl,8
                div     cl                      ; al, ah rem = ax/reg
                mov     cl,al
                mov     bl,ah
                mov     ax,d_0524               ; (=0)
                xor     ch,ch                   ; Zero register
                or      cl,cl                   ; Zero ?
                jz      l_0F14                  ; Jump if zero

                or      bl,bl                   ; Zero ?
                jnz     l_0F14                  ; Jump if not zero
                dec     cl
l_0F14:
                add     ax,cx
                mov     d_0524,ax               ; (=0)
                or      bl,bl                   ; Zero ?
                jz      l_0F38                  ; Jump if zero
                mov     cl,1
l_0F1F:
                dec     bl
                jz      l_0F27                  ; Jump if zero
                shl     cl,1                    ; Shift w/zeros fill
                jmp     short l_0F1F
l_0F27:
                mov     bx,d_0524               ; (=0)
                mov     dx,bp
                sub     bx,dx
                mov     si,bx
                mov     al,[bp+si]
                or      al,cl
                mov     [bp+si],al
                retn
l_0F38:
                mov     cl,80h
                jmp     short l_0F27
s_0EF2          endp


;==========================================================================
;                              SUBROUTINE
;==========================================================================

s_0F3C          proc    near
                mov     ax,bp
                mov     d_0524,ax               ; (=0)
                mov     al,dl
                push    dx
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                call    s_0FEC
                or      bh,bh                   ; Zero ?
                jz      l_0F84                  ; Jump if zero
                xor     cl,cl                   ; Zero register
l_0F50:
                dec     bh
                jz      l_0F5B                  ; Jump if zero
                shl     cl,1                    ; Shift w/zeros fill
                add     cl,1
                jmp     short l_0F50
l_0F5B:
                mov     ax,d_0524               ; (=0)
                mov     dx,bp
                sub     ax,dx
                mov     si,ax
                mov     al,[bp+si]
                or      al,cl
                mov     [bp+si],al

l_0F6A:
                or      bl,bl                   ; Zero ?
                jz      l_0F98                  ; Jump if zero
l_0F6E:
                dec     d_0524                  ; (=0)
                mov     ax,d_0524               ; (=0)
                mov     dx,bp
                sub     ax,dx
                mov     si,ax
                mov     byte ptr [bp+si],0FFh
                dec     bl
                jnz     l_0F6E                  ; Jump if not zero
                jmp     short l_0F98
l_0F84:
                dec     d_0524                  ; (=0)
                dec     bl
                mov     ax,d_0524               ; (=0)
                mov     dx,bp
                sub     ax,dx
                mov     si,ax
                mov     byte ptr [bp+si],7Fh
                jmp     short l_0F6A
l_0F98:
                mov     ax,bp
                mov     d_0524,ax               ; (=0)
                pop     dx
                mov     al,dh
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                call    s_0FEC
                or      bh,bh                   ; Zero ?
                jz      l_0FDD                  ; Jump if zero
                mov     cl,0FFh
l_0FAC:
                shl     cl,1                    ; Shift w/zeros fill
                and     cl,0FEh
                dec     bh
                jnz     l_0FAC                  ; Jump if not zero
                mov     ax,d_0524               ; (=0)
                mov     dx,bp
                sub     ax,dx
                mov     si,ax
                mov     al,[bp+si]
                or      al,cl
                mov     [bp+si],al
l_0FC4:
                cmp     bl,0Ch
                je      l_0FEB                  ; Jump if equal
                inc     d_0524                  ; (=0)
                mov     ax,d_0524               ; (=0)
                mov     dx,bp
                sub     ax,dx
                mov     si,ax
                mov     byte ptr [bp+si],0FFh
                inc     bl
                jmp     short l_0FC4
l_0FDD:
                mov     ax,d_0524               ; (=0)

                mov     dx,bp
                sub     ax,dx
                mov     si,ax
                mov     byte ptr [bp+si],0FFh
                jmp     short l_0FC4

l_0FEB:
                retn
s_0F3C          endp


;==========================================================================
;                              SUBROUTINE
;==========================================================================

s_0FEC          proc    near
                mov     cl,8
                div     cl                      ; al, ah rem = ax/reg
                mov     bx,ax
                mov     ax,d_0524               ; (=0)
                mov     dl,bl
                xor     dh,dh                   ; Zero register
                add     ax,dx
                mov     d_0524,ax               ; (=0)
                retn
s_0FEC          endp

; -----------------------------------------------------------------------------
;        funkce VSTUP IOCTL 0Ch: informace o Q-kan lu
; -----------------------------------------------------------------------------
;þ
l_0FFF:

                                                ;* No entry point to code
                call    s_2E74              ; ukon‡en¡ v¨ech p©enos– s CD
                call    s_2B1A              ; p©eru¨en¡ p©enosu DMA
                call    s_2BD6              ; na‡ten¡ stavu ©adi‡e CD
                or      al,al                   ; Zero ?
                jnz     l_1056                  ; Jump if not zero

                mov     al,d_058E           ; p©ijat˜ ©¡dic¡ a adresovac¡ bajt
                stosb                           ; Store al to es:[di]
                mov     al,d_058F           ; aktu ln¡ ‡¡slo stopy
                stosb                       ; aktu ln¡ ‡¡slo stopy

                mov     al,d_0590           ; ukazatel nebo index
                stosb                       ; ukazatel nebo index

                mov     al,d_0591           ; aktu ln¡ pozice na stopˆ - minuta
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                stosb                       ; aktu ln¡ pozice na stopˆ - minuta

                mov     al,d_0592           ; aktu ln¡ pozice na stopˆ - sekunda
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                stosb                       ; aktu ln¡ pozice na stopˆ - sekunda

                mov     al,d_0593           ; aktu ln¡ pozice na stopˆ - r me‡ek
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                stosb                       ; aktu ln¡ pozice na stopˆ - r me‡ek

                mov     al,d_0594               ; (=0)
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                stosb                           ; Store al to es:[di]

                mov     al,d_0595           ; aktu ln¡ pozice hlavy - minuta
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                stosb                           ; Store al to es:[di]

                mov     al,d_0596           ; aktu ln¡ pozice hlavy - sekunda
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                stosb                           ; Store al to es:[di]

                mov     al,d_0597           ; aktu ln¡ pozice hlavy - r me‡ek
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                stosb                           ; Store al to es:[di]

                test    d_05AA,2            ; 80h=dv¡©ka otev©ena
                jnz     l_1053                  ; Jump if not zero
                jmp     l_0878
l_1053:
                jmp     l_087C
l_1056:
                jmp     l_0873

; -----------------------------------------------------------------------------
;      funkce VSTUP IOCTL 0Eh: UPC k¢d
; -----------------------------------------------------------------------------
;þ
l_1059:
                                                ;* No entry point to code
                call    s_2E74              ; ukon‡en¡ v¨ech p©enos– s CD
                call    s_2B4D              ; test, zda je vlo‘en disk
                cmp     al,0FFh
                jne     l_1066                  ; Jump if not equal
                jmp     l_0873
l_1066:
                cmp     al,2
                jne     l_106D                  ; Jump if not equal
                jmp     l_0873
l_106D:
                call    s_109E
                cmp     al,0FFh
                jne     l_1081                  ; Jump if not equal
                mov     d_05A6,0                ; (=0)
                mov     d_05A7,0                ; (=0)
                jmp     l_0873
l_1081:
                or      al,al                   ; Zero ?
                jz      l_1088                  ; Jump if zero
                jmp     l_0862
l_1088:
                cld                             ; Clear direction
                mov     si,offset d_058E    ; p©ijat˜ ©¡dic¡ a adresovac¡ bajt
                mov     cx,0Ah
                rep     movsb                   ; Rep when cx >0 Mov [si] to es:[di]
                cmp     d_05A8,0                ; (=0)
                je      l_109B                  ; Jump if equal
                jmp     l_087C
l_109B:
                jmp     l_0878

;==========================================================================
;                              SUBROUTINE
;==========================================================================

s_109E          proc    near
                test    d_05AA,2            ; 80h=dv¡©ka otev©ena
                jz      l_10AD                  ; Jump if zero
                mov     d_05A8,1                ; (=0)
                jmp     l_1130
l_10AD:
                mov     d_05A8,0                ; (=0)
                mov     d_076B,3                ; (=0)
l_10B7:
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,50h                  ; 'P'

                out     dx,al                   ; port 300h, POST checkpoint
                xor     al,al                   ; Zero register
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                jne     l_10CF                  ; Jump if not equal
                dec     d_076B                  ; (=0)
                jnz     l_10B7                  ; Jump if not zero
                retn
l_10CF:
                mov     d_057C,0                ; (=0)
                mov     d_057D,1                ; (=0)
                mov     d_057E,60h              ; (=0) '`'
                mov     d_0580,0                ; (=0)
                mov     d_057F,0                ; (=0)
                mov     d_0581,0                ; (=0)
                call    s_2D1C
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                jne     l_10F8                  ; Jump if not equal
                retn
l_10F8:
                test    bl,8
                jnz     l_1115                  ; Jump if not zero
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,0A2h
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                jne     l_1130                  ; Jump if not equal
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                jne     l_1130                  ; Jump if not equal
                mov     al,1
                retn
l_1115:
                mov     d_0580,6                ; (=0)
                mov     d_076B,3                ; (=0)
l_111F:
                call    s_2D1C
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                jne     l_1130                  ; Jump if not equal
                dec     d_076B                  ; (=0)
                jnz     l_111F                  ; Jump if not zero
                retn
l_1130:
                mov     d_076B,3                ; (=0)
l_1135:
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,90h
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,4
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,1
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD

                cmp     al,0FFh
                jne     l_1150                  ; Jump if not equal
                dec     d_076B                  ; (=0)
                jnz     l_1135                  ; Jump if not zero
                retn
l_1150:
                mov     d_0320,1F4h             ; (=0)
l_1156:
                mov     d_076B,3                ; (=0)
l_115B:
                call    s_2BD6              ; na‡ten¡ stavu ©adi‡e CD
                or      al,al                   ; Zero ?
                jz      l_116B                  ; Jump if zero
                dec     d_076B                  ; (=0)
                jnz     l_115B                  ; Jump if not zero
                jmp     l_1204
l_116B:
                test    d_058E,2            ; p©ijat˜ ©¡dic¡ a adresovac¡ bajt
                jnz     l_117B                  ; Jump if not zero
                dec     d_0320                  ; (=0)
                jnz     l_1156                  ; Jump if not zero
                jmp     l_1204
l_117B:
                cmp     d_05A8,0                ; (=0)
                je      l_1184                  ; Jump if equal
                jmp     short l_11BB
l_1184:
                mov     d_076B,3                ; (=0)
l_1189:
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,70h                  ; 'p'
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                jne     l_119E                  ; Jump if not equal
                dec     d_076B                  ; (=0)
                jnz     l_1189                  ; Jump if not zero
                retn
l_119E:
                mov     d_076B,3                ; (=0)
l_11A3:
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,50h                  ; 'P'
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,1
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                jne     l_11BB                  ; Jump if not equal
                dec     d_076B                  ; (=0)
                jnz     l_11A3                  ; Jump if not zero
                retn
l_11BB:
                mov     d_076B,3                ; (=0)
l_11C0:
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,90h

                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,4
                out     dx,al                   ; port 300h, POST checkpoint
                xor     al,al                   ; Zero register
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                jne     l_11DB                  ; Jump if not equal
                dec     d_076B                  ; (=0)
                jnz     l_11C0                  ; Jump if not zero
                retn
l_11DB:
                mov     al,d_058F           ; aktu ln¡ ‡¡slo stopy
                or      al,d_0590           ; ukazatel nebo index
                or      al,d_0591           ; aktu ln¡ pozice na stopˆ - minuta
                or      al,d_0592           ; aktu ln¡ pozice na stopˆ - sekunda
                or      al,d_0593           ; aktu ln¡ pozice na stopˆ - r me‡ek
                or      al,d_0594               ; (=0)
                or      al,d_0595           ; aktu ln¡ pozice hlavy - minuta
                or      al,d_0596           ; aktu ln¡ pozice hlavy - sekunda
                or      al,al                   ; Zero ?
                jnz     l_1201                  ; Jump if not zero
                jmp     l_1289
l_1201:
                xor     al,al                   ; Zero register
                retn
l_1204:
                cmp     d_05A8,0                ; (=0)
                jne     l_1242                  ; Jump if not equal
                mov     d_076B,3                ; (=0)
l_1210:
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,70h                  ; 'p'
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                jne     l_1225                  ; Jump if not equal
                dec     d_076B                  ; (=0)
                jnz     l_1210                  ; Jump if not zero
                retn
l_1225:
                mov     d_076B,3                ; (=0)
l_122A:
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,50h                  ; 'P'
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,1
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                jne     l_1242                  ; Jump if not equal
                dec     d_076B                  ; (=0)
                jnz     l_122A                  ; Jump if not zero
                retn
l_1242:
                mov     d_076B,3                ; (=0)
l_1247:

                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,90h
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,4
                out     dx,al                   ; port 300h, POST checkpoint
                xor     al,al                   ; Zero register
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                jne     l_1262                  ; Jump if not equal
                dec     d_076B                  ; (=0)
                jnz     l_1247                  ; Jump if not zero
                retn
l_1262:
                cmp     al,2
                jne     l_1269                  ; Jump if not equal
                mov     al,0FFh
                retn
l_1269:
                xor     al,al                   ; Zero register
                mov     d_058E,al           ; p©ijat˜ ©¡dic¡ a adresovac¡ bajt
                mov     d_058F,al           ; aktu ln¡ ‡¡slo stopy
                mov     d_0590,al           ; ukazatel nebo index
                mov     d_0591,al           ; aktu ln¡ pozice na stopˆ - minuta
                mov     d_0592,al           ; aktu ln¡ pozice na stopˆ - sekunda
                mov     d_0593,al           ; aktu ln¡ pozice na stopˆ - r me‡ek
                mov     d_0594,al               ; (=0)
                mov     d_0595,al           ; aktu ln¡ pozice hlavy - minuta
                mov     d_0596,al           ; aktu ln¡ pozice hlavy - sekunda
                mov     d_0597,al           ; aktu ln¡ pozice hlavy - r me‡ek
l_1289:
                mov     al,1
                retn
s_109E          endp

; -----------------------------------------------------------------------------
;        funkce VSTUP IOCTL 0Fh: informace o stavu audio
; -----------------------------------------------------------------------------
;þ
l_128C:
                                                ;* No entry point to code
                call    s_2E74              ; ukon‡en¡ v¨ech p©enos– s CD
                call    s_2B4D              ; test, zda je vlo‘en disk
                cmp     al,0FFh
                jne     l_12AC                  ; Jump if not equal
                xor     ax,ax                   ; Zero register
                mov     d_05A6,al               ; (=0)
                mov     d_05A7,al               ; (=0)
                mov     d_05A4,1                ; (=1)
                mov     d_0308,ax               ; (=0FFFFh)
                mov     d_030A,ax               ; (=0FFFFh)
                jmp     l_0873
l_12AC:
                cmp     al,2
                jne     l_12B3                  ; Jump if not equal
                jmp     l_0873
l_12B3:
                cmp     al,1
                je      l_12BE                  ; Jump if equal
                mov     d_05A6,0                ; (=0)
                jmp     short l_12C8
l_12BE:

                mov     d_05A6,1                ; (=0)
                mov     d_05A7,0                ; (=0)
l_12C8:
                cmp     d_05A6,1                ; (=0)
                je      l_12E7                  ; Jump if equal
                cmp     d_05A7,1                ; (=0)
                jne     l_12E0                  ; Jump if not equal
                mov     ax,1
                mov     d_05A8,0                ; (=0)
                jmp     short l_1322
l_12E0:
                xor     ax,ax                   ; Zero register
                mov     d_05A8,al               ; (=0)
                jmp     short l_1322
l_12E7:
                xor     ax,ax                   ; Zero register
                mov     d_05A8,1                ; (=0)
                stosw                           ; Store ax to es:[di]
                mov     al,d_057E               ; (=0)
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                stosb                           ; Store al to es:[di]
                mov     al,d_057D               ; (=0)
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                stosb                           ; Store al to es:[di]
                mov     al,d_057C               ; (=0)
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                stosb                           ; Store al to es:[di]
                xor     al,al                   ; Zero register
                stosb                           ; Store al to es:[di]
                mov     al,d_0581               ; (=0)
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                stosb                           ; Store al to es:[di]
                mov     al,d_0580               ; (=0)
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                stosb                           ; Store al to es:[di]
                mov     al,d_057F               ; (=0)
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                stosb                           ; Store al to es:[di]
                xor     al,al                   ; Zero register
                stosb                           ; Store al to es:[di]
                jmp     l_087C
l_1322:
                stosw                           ; Store ax to es:[di]
                xor     al,al                   ; Zero register
                mov     cx,8
                rep     stosb                   ; Rep when cx >0 Store al to es:[di]
                jmp     l_0878

; -----------------------------------------------------------------------------
;        funkce 07h: vypr zdnˆn¡ vstupu
; -----------------------------------------------------------------------------
;þ
l_132D:

                                                ;* No entry point to code
                xor     ax,ax                   ; Zero register
                mov     d_05A4,al               ; (=1)
                mov     d_0314,ax               ; (=0)
                mov     d_0316,ax               ; (=0)
                mov     d_0786,al               ; (=0)
                call    s_2E74              ; ukon‡en¡ v¨ech p©enos– s CD
                call    s_2B4D              ; test, zda je vlo‘en disk
                cmp     al,1
                je      l_1348                  ; Jump if equal

                jmp     l_0878
l_1348:
                jmp     l_087C

; -----------------------------------------------------------------------------
;        funkce 0Dh, 0Eh: otev©en¡/uzav©en¡ za©¡zen¡
; -----------------------------------------------------------------------------
;þ
l_134B:

                                                ;* No entry point to code
                call    s_2E74              ; ukon‡en¡ v¨ech p©enos– s CD
                call    s_2B4D              ; test, zda je vlo‘en disk
                cmp     al,1
                je      l_1358                  ; Jump if equal
                jmp     l_0878
l_1358:
                jmp     l_087C

; -----------------------------------------------------------------------------
;        funkce 0Ch: v˜stup IOCTL
; -----------------------------------------------------------------------------
;þ
l_135B:
                                       ;* No entry point to code
                mov     si,offset d_00A2        ; tabulka skok–
                mov     cl,6
                les     di,dword ptr es:[bx+0Eh] ; Load 32 bit ptr
                xor     ah,ah                   ; Zero register
                mov     al,es:[di]
                inc     di
                cmp     al,cl
                jbe     l_1371                  ; Jump if below or =
                jmp     l_083A
l_1371:
                shl     ax,1                    ; Shift w/zeros fill
                add     si,ax
                jmp     word ptr [si]           ;*

; -----------------------------------------------------------------------------
;        funkce OUT IOCTL 00h: vysunut¡ disku EJECT
; -----------------------------------------------------------------------------
;þ
l_1377:
                                                ;* No entry point to code
                call    s_2E74              ; ukon‡en¡ v¨ech p©enos– s CD
                call    s_2B1A              ; p©eru¨en¡ p©enosu DMA
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,0F6h             ; povel pro EJECT
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                jne     l_138E                  ; Jump if not equal
                jmp     l_0873
l_138E:
                test    bl,1
                jz      l_1396                  ; Jump if zero
                jmp     l_083A
l_1396:
                cmp     d_0766,46h          ; rozsah regulace hlasitosti CD (44h)
                jne     l_13AA                  ; Jump if not equal
                cmp     d_0767,4                ; (=0)
                ja      l_13AA                  ; Jump if above

; ----- prodleva 3 sekundy

                mov     cx,2EE0h
                call    s_2E56              ; prodleva CX * 0.25 ms
l_13AA:
                jmp     l_0878

; -----------------------------------------------------------------------------
;        funkce OUT IOCTL 01h: uzamknut¡/odemknut¡ dv¡©ek
; -----------------------------------------------------------------------------
;þ
l_13AD:
                                                ;* No entry point to code
                call    s_2E74              ; ukon‡en¡ v¨ech p©enos– s CD
                mov     al,es:[di]          ; povel
                mov     d_0765,al           ; 1=uzamknut¡ dv¡©ek
                cmp     al,1                ; uzamknut¡ dv¡©ek
                je      l_13C6                  ; Jump if equal
                cmp     al,0                ; odemknut¡ dv¡©ek
                je      l_13C6                  ; Jump if equal
                mov     d_0765,0            ; 1=uzamknut¡ dv¡©ek

                jmp     l_083A

l_13C6:         call    s_2B1A              ; p©eru¨en¡ p©enosu DMA
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,0FEh             ; povel pro uzamknut¡/odemknut¡
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,d_0765           ; 1=uzamknut¡ dv¡©ek
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                jne     l_13DE                  ; Jump if not equal
                jmp     l_0873
l_13DE:
                test    bl,1
                jz      l_13E6                  ; Jump if zero
                jmp     l_083A
l_13E6:
                test    bl,2
                jz      l_13EE                  ; Jump if zero
                jmp     l_087C
l_13EE:
                jmp     l_0878

; -----------------------------------------------------------------------------
;        funkce OUT IOCTL 02h: reset disku
; -----------------------------------------------------------------------------
;þ
l_13F1:
                mov     d_0768,0                ; (=0)
                call    s_13FC              ; reset disku
                jmp     l_0878

;==========================================================================
;        RESET disku
;==========================================================================

s_13FC          proc    near
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,60h              ; povel pro RESET disku
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                je      l_140F                  ; Jump if equal
                test    bl,0C0h
                jnz     l_1424                  ; Jump if not zero
l_140F:
                xor     ax,ax                   ; Zero register
                mov     dx,d_02D8           ; b zov  adresa ©adi‡e CD + 1
                out     dx,al                   ; port 301h ??i/o non-standard
                mov     cx,2
l_1419:
                call    s_2B4D              ; test, zda je vlo‘en disk
                cmp     al,0FFh
                jne     l_1424                  ; Jump if not equal
                dec     cx
                jnz     l_1419                  ; Jump if not zero
                retn
l_1424:
                cmp     al,2
                je      l_142E                  ; Jump if equal
                call    s_2ED8              ; vystaven¡ hlav na zadanou pozici
                call    s_1DF3


l_142E:
                retn
s_13FC          endp

; -----------------------------------------------------------------------------
;        funkce OUT IOCTL 03h: ©¡zen¡ audio kan lu
; -----------------------------------------------------------------------------
;þ
l_142F:
                                                ;* No entry point to code
                xor     ax,ax                   ; Zero register
                mov     d_075D,al               ; (=0FFh)
                mov     d_075E,al               ; (=0)
                mov     d_075F,al               ; (=0FFh)
                mov     d_0760,al               ; (=0)
                mov     d_0787,al               ; (=0)
                call    s_2E74              ; ukon‡en¡ v¨ech p©enos– s CD
                mov     al,es:[di]
                cmp     al,0
                jne     l_1453                  ; Jump if not equal
                inc     di
                mov     al,es:[di]
                mov     d_075D,al               ; (=0FFh)
                jmp     short l_147A
l_1453:
                cmp     al,1
                jne     l_1469                  ; Jump if not equal
                inc     di
                mov     al,es:[di]
                mov     d_0760,al               ; (=0)
                or      al,al                   ; Zero ?
                jnz     l_147A                  ; Jump if not zero
                mov     d_0787,1                ; (=0)
                jmp     short l_147A
l_1469:
                cmp     al,2
                jne     l_1470                  ; Jump if not equal
                jmp     l_1559
l_1470:
                cmp     al,3
                jne     l_1477                  ; Jump if not equal
                jmp     l_1559
l_1477:
                jmp     l_083A
l_147A:
                inc     di
                mov     al,es:[di]
                cmp     al,0
                jne     l_1494                  ; Jump if not equal
                inc     di
                mov     al,es:[di]
                mov     d_075E,al               ; (=0)
                or      al,al                   ; Zero ?
                jz      l_14B2                  ; Jump if zero
                mov     d_0787,0                ; (=0)
                jmp     short l_14B2
l_1494:
                cmp     al,1
                jne     l_14A1                  ; Jump if not equal
                inc     di
                mov     al,es:[di]

                mov     d_075F,al               ; (=0FFh)
                jmp     short l_14B2
l_14A1:
                cmp     al,2
                jne     l_14A8                  ; Jump if not equal
                jmp     l_1559
l_14A8:
                cmp     al,3
                jne     l_14AF                  ; Jump if not equal
                jmp     l_1559
l_14AF:
                jmp     l_083A
l_14B2:
                cmp     d_0771,0            ; 1=p©¡znak MONO m¢du
                je      l_150F                  ; Jump if equal
                cmp     d_075D,0                ; (=0FFh)
                je      l_14D6                  ; Jump if equal
                cmp     d_075F,0                ; (=0FFh)
                jne     l_150F                  ; Jump if not equal
                cmp     d_075E,0                ; (=0)
                jne     l_150F                  ; Jump if not equal
                mov     al,d_075D               ; (=0FFh)
                mov     d_075E,al               ; (=0)
                jmp     short l_150F
l_14D6:
                cmp     d_0760,0                ; (=0)
                je      l_14F3                  ; Jump if equal
                cmp     d_075F,0                ; (=0FFh)
                jne     l_150F                  ; Jump if not equal
                cmp     d_075E,0                ; (=0)
                jne     l_150F                  ; Jump if not equal
                mov     al,d_0760               ; (=0)
                mov     d_075F,al               ; (=0FFh)
                jmp     short l_150F
l_14F3:
                cmp     d_075E,0                ; (=0)
                je      l_1502                  ; Jump if equal
                mov     al,d_075E               ; (=0)
                mov     d_075D,al               ; (=0FFh)
                jmp     short l_150F
l_1502:
                cmp     d_075F,0                ; (=0FFh)
                je      l_150F                  ; Jump if equal
                mov     al,d_075F               ; (=0FFh)
                mov     d_0760,al               ; (=0)
l_150F:
                call    s_1566
                cmp     al,0FFh
                jne     l_1519                  ; Jump if not equal
                jmp     l_0873
l_1519:
                test    bl,1
                jz      l_1521                  ; Jump if zero
                jmp     l_084E
l_1521:
                call    s_2DC7              ; vstup datov‚ho bajtu z ©adi‡e CD
                cmp     al,0FFh

                jne     l_152B                  ; Jump if not equal
                jmp     l_0873
l_152B:
                mov     d_0761,bl               ; (=0)
                call    s_2DC7              ; vstup datov‚ho bajtu z ©adi‡e CD
                cmp     al,0FFh
                jne     l_1539                  ; Jump if not equal
                jmp     l_0873
l_1539:
                mov     d_0762,bl               ; (=0)
                call    s_2DC7              ; vstup datov‚ho bajtu z ©adi‡e CD
                cmp     al,0FFh
                jne     l_1547                  ; Jump if not equal
                jmp     l_0873
l_1547:
                mov     d_0763,bl               ; (=0)
                call    s_2DC7              ; vstup datov‚ho bajtu z ©adi‡e CD
                cmp     al,0FFh
                jne     l_1555                  ; Jump if not equal
                jmp     l_0873
l_1555:
                mov     d_0764,bl               ; (=0)
l_1559:
                test    d_05AA,2            ; 80h=dv¡©ka otev©ena
                jz      l_1563                  ; Jump if zero
                jmp     l_087C
l_1563:
                jmp     l_0878

;==========================================================================
;                              SUBROUTINE
;==========================================================================

s_1566          proc    near
                call    s_2B1A              ; p©eru¨en¡ p©enosu DMA
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,0AEh
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,d_075D               ; (=0FFh)
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,d_075E               ; (=0)
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,d_075F               ; (=0FFh)
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,d_0760               ; (=0)
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                retn
s_1566          endp

; -----------------------------------------------------------------------------
;        funkce OUT IOCTL 05h: uzav©en¡ cesty
; -----------------------------------------------------------------------------
;þ
l_1584:
                                                ;* No entry point to code
                call    s_2E74              ; ukon‡en¡ v¨ech p©enos– s CD
                mov     d_076B,6                ; (=0)
l_158C:
                call    s_2B1A              ; p©eru¨en¡ p©enosu DMA
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,0F8h

                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                jne     l_15A6                  ; Jump if not equal
                dec     d_076B                  ; (=0)
                jnz     l_158C                  ; Jump if not zero
                jmp     l_0873
l_15A6:
                test    bl,1
                jz      l_15AE                  ; Jump if zero
                jmp     l_083A
l_15AE:
                test    bl,2
                jz      l_15B6                  ; Jump if zero
                jmp     l_087C
l_15B6:
                jmp     l_0878

; -----------------------------------------------------------------------------
;        funkce 80h a 82h: dlouh‚ ‡ten¡ z CD
; -----------------------------------------------------------------------------
;þ
l_15B9:
                                                ;* No entry point to code
                mov     d_075A,0                ; (=0)
                cmp     d_0779,0                ; (=1)
                je      l_1608                  ; Jump if equal
l_15C5:
                call    s_2E74              ; ukon‡en¡ v¨ech p©enos– s CD
                call    s_2B4D              ; test, zda je vlo‘en disk
                cmp     al,0FFh
                jne     l_15E3                  ; Jump if not equal
                mov     d_05A4,1                ; (=1)
                mov     d_0308,0FFFFh           ; (=0FFFFh)
                mov     d_030A,0FFFFh           ; (=0FFFFh)
                jmp     l_1B73
l_15E3:
                cmp     al,2
                jne     l_15EA                  ; Jump if not equal
                jmp     l_1B5F
l_15EA:
                cmp     d_0772,0                ; (=0)
                je      l_1608                  ; Jump if equal
l_15F1:
                call    s_2AB6              ; zji¨tˆn¡ velikosti disku (v sektorech)
                cmp     al,0FFh
                jne     l_15FB                  ; Jump if not equal
                jmp     l_1B5F
l_15FB:
                cmp     al,2
                jne     l_1602                  ; Jump if not equal
                jmp     l_1B5F
l_1602:
                call    s_2ED8              ; vystaven¡ hlav na zadanou pozici
                call    s_1DF3
l_1608:
                cmp     d_0772,0                ; (=0)
                je      l_1611                  ; Jump if equal
                jmp     short l_15F1
l_1611:
                xor     ax,ax                   ; Zero register
                mov     d_031C,ax               ; (=0)
                mov     d_0789,al               ; (=0)

                mov     d_05A6,0                ; (=0)
                mov     d_05A7,0                ; (=0)
                call    s_2E74              ; ukon‡en¡ v¨ech p©enos– s CD
                les     bx,d_0016               ; (=0) Load 32 bit ptr

                mov     al,es:[bx+19h]      ; velikost skupiny prokl d n¡
                mov     d_076D,al           ; velikost skupiny prokl d n¡
                mov     d_076C,al           ; velikost skupiny prokl d n¡

                mov     al,es:[bx+1Ah]      ; mezera mezi skupinami prokl d n¡
                mov     d_076F,al           ; mezera mezi skupinami prokl d n¡
                mov     d_076E,al           ; mezera mezi skupinami prokl d n¡

                cmp     d_076C,0            ; velikost skupiny prokl d n¡
                je      l_165A                  ; Jump if equal
                cmp     d_076E,0            ; mezera mezi skupinami prokl d n¡
                je      l_165A                  ; Jump if equal

                mov     d_0770,1                ; (=0)
                cmp     d_0775,1            ; 1=nen¡ podporov no prokl d n¡
                je      l_165A                  ; Jump if equal
                jmp     short l_165F
l_165A:
                mov     d_0770,0                ; (=0)
l_165F:
                mov     cx,es:[bx+12h]      ; po‡et sektor– ke ‡ten¡
                mov     ax,es:[bx+0Eh]      ; p©enosov  adresa - offset
                mov     d_0318,ax           ; p©enosov  adresa - offset
                mov     ax,es:[bx+10h]      ; p©enosov  adresa - segment
                mov     d_031A,ax           ; p©enosov  adresa - segment

                or      ax,d_0318           ; p©enosov  adresa - offset
                jnz     l_1683                  ; Jump if not zero
                mov     d_0789,1                ; (=0)
                or      cx,cx                   ; Zero ?
                jnz     l_168A                  ; Jump if not zero
                jmp     l_1EE7
l_1683:
                or      cx,cx                   ; Zero ?
                jnz     l_168A                  ; Jump if not zero
                jmp     l_0878
l_168A:
                mov     al,es:[bx+18h]      ; ‡tec¡ m¢d
                cmp     d_0781,0
                je      l_16A7                  ; Jump if equal
                mov     d_0572,800h         ; velikost sektoru (po‡et bajt–)
                or      al,al                   ; Zero ?
                jz      l_16A5                  ; Jump if zero
                mov     d_0572,930h         ; velikost sektoru ke ‡ten¡ (bajt–)     ; (=800h)
l_16A5:
                mov     al,1
l_16A7:
                cmp     al,d_0777               ; (=0)
                jne     l_16B0                  ; Jump if not equal
                jmp     l_1759
l_16B0:
                mov     d_05A4,1                ; (=1)
                mov     d_0308,0FFFFh           ; (=0FFFFh)
                mov     d_030A,0FFFFh           ; (=0FFFFh)
                xor     cx,cx                   ; Zero register
                mov     d_0316,cx               ; (=0)
                mov     d_0314,cx               ; (=0)

                mov     d_0786,cl               ; (=0)
                cmp     al,1
                je      l_16E6                  ; Jump if equal
                or      al,al                   ; Zero ?
                jz      l_16DA                  ; Jump if zero
                jmp     l_083A
l_16DA:
                mov     d_0322,800h             ; (=800h)
                mov     cl,d_059F           ; po‡et buffer– 2 KB     ; (=2)
                jmp     short l_16F0
l_16E6:
                mov     d_0322,930h             ; (=800h)
                mov     cl,d_05A0               ; (=2)
l_16F0:
                mov     d_02F6,cx           ; po‡et buffer– 2 KB
                dec     cx
                mov     d_031E,cx               ; (=0)
                inc     cx
                mov     d_0777,al               ; (=0)
                mov     ax,d_0566               ; (=0)
                xor     bx,bx                   ; Zero register
                xor     bp,bp                   ; Zero register
                cmp     d_077A,1            ; p©¡znak extended pamˆti
                je      l_1710                  ; Jump if equal
                call    s_1E37
                jmp     short l_1759
l_1710:
                xor     di,di                   ; Zero register
                xor     cx,cx                   ; Zero register
                xor     dx,dx                   ; Zero register
                mov     d_04A4[di],0        ; tabulka ‡¡sel blok– 64 KB buffer–
                mov     d_0424[di],0            ; tabulka adres buffer– sektor–
                cmp     d_0322,800h             ; (=800h)
                je      l_1739                  ; Jump if equal
                mov     cl,d_05A2               ; (=0)
                mov     d_02F6,cx           ; po‡et buffer– 2 KB
                dec     cx
                mov     d_031E,cx               ; (=0)
                jmp     short l_1746
l_1739:
                mov     cl,d_05A1               ; (=0)
                mov     d_02F6,cx           ; po‡et buffer– 2 KB
                dec     cx
                mov     d_031E,cx               ; (=0)

l_1746:
                inc     di
                inc     di
                add     bx,d_0322               ; (=800h)
                jnc     l_174F                  ; Jump if carry=0
                inc     dx
l_174F:
                mov     d_04A4[di],dx       ; tabulka ‡¡sel blok– 64 KB buffer– sektor–
                mov     d_0424[di],bx           ; tabulka adres buffer– sektor–
                loop    l_1746                  ; Loop if cx > 0

l_1759:

                les     bx,d_0016               ; (=0) Load 32 bit ptr
                mov     ax,es:[bx+14h]
                mov     dx,es:[bx+16h]
                cmp     byte ptr es:[bx+0Dh],0
                jne     l_1774                  ; Jump if not equal
                add     ax,96h
                adc     dx,0
                jmp     short l_1781
l_1774:
                cmp     byte ptr es:[bx+0Dh],1
                je      l_177E                  ; Jump if equal
                jmp     l_083A
l_177E:
                call    s_2DFB              ; p©epo‡et MM:SS:FF r me‡ek DX:AX
l_1781:
                cmp     d_0782,0                ; (=0)
                je      l_17A1                  ; Jump if equal
                cmp     ax,0A6h
                jl      l_17A1                  ; Jump if <
                cmp     dx,d_0570               ; (=0)
                ja      l_17A1                  ; Jump if above
                cmp     ax,d_056E               ; (=0)
                ja      l_17A1                  ; Jump if above
                add     ax,d_056A               ; (=0)
                adc     dx,d_056C               ; (=0)
l_17A1:
                mov     d_0304,ax               ; (=0)
                mov     d_0306,dx               ; (=0)
                mov     d_030C,ax               ; (=0)
                mov     d_030E,dx               ; (=0)
l_17AF:
                mov     d_02F4,ax           ; ukazatel absolutn¡ho ‡¡sla sektoru
                mov     d_02F2,dx           ; ukazatel absolutn¡ho ‡¡sla sektoru
                call    s_2E19              ; p©epo‡et r me‡ku DX:AX na MM:SS:FF
                mov     al,dl
                call    s_2E28              ; p©evod bin rn¡ho ‡¡sla v AL na BCD ‡¡slo
                mov     d_057C,al               ; (=0)
                mov     al,ch
                call    s_2E28              ; p©evod bin rn¡ho ‡¡sla v AL na BCD ‡¡slo
                mov     d_057D,al               ; (=0)
                mov     al,cl
                call    s_2E28              ; p©evod bin rn¡ho ‡¡sla v AL na BCD ‡¡slo
                mov     d_057E,al               ; (=0)
                mov     ax,es:[bx+12h]      ; po‡et sektor– ke ‡ten¡
                mov     d_02E4,ax           ; po‡et sektor– ke ‡ten¡
                mov     d_057F,0F0h             ; (=0)
                mov     d_0580,0                ; (=0)
                mov     d_0581,0                ; (=0)
                mov     ax,d_030E               ; (=0)
                cmp     ax,d_030A               ; (=0FFFFh)
                jne     l_17FC                  ; Jump if not equal
                mov     ax,d_030C               ; (=0)
                cmp     ax,d_0308               ; (=0FFFFh)
                jne     l_17FC                  ; Jump if not equal
                jmp     l_19E3
l_17FC:
                mov     d_05A4,1                ; (=1)

                cmp     d_0776,1                ; (=0)
                je      l_1813                  ; Jump if equal
                xor     ax,ax                   ; Zero register
                mov     d_0314,ax               ; (=0)
                mov     d_0316,ax               ; (=0)
                mov     d_0786,al               ; (=0)
l_1813:
                call    s_2B4D              ; test, zda je vlo‘en disk
                cmp     al,0FFh
                jne     l_182E                  ; Jump if not equal
                mov     d_05A4,1                ; (=1)
                mov     d_0308,0FFFFh           ; (=0FFFFh)
                mov     d_030A,0FFFFh           ; (=0FFFFh)
                jmp     l_1B73
l_182E:
                cmp     al,2
                jne     l_1835                  ; Jump if not equal
                jmp     l_1B5F
l_1835:
                cmp     d_0772,0                ; (=0)
                je      l_1853                  ; Jump if equal
                call    s_2AB6              ; zji¨tˆn¡ velikosti disku (v sektorech)
                cmp     al,0FFh
                jne     l_1846                  ; Jump if not equal
                jmp     l_1B5F
l_1846:
                cmp     al,2
                jne     l_184D                  ; Jump if not equal
                jmp     l_1B5F
l_184D:
                call    s_2ED8              ; vystaven¡ hlav na zadanou pozici
                call    s_1DF3
l_1853:
                cmp     d_0766,46h          ; rozsah regulace hlasitosti CD (44h)
                jne     l_1861                  ; Jump if not equal
                cmp     d_0767,4                ; (=0)
                jb      l_186A                  ; Jump if below
l_1861:
                test    d_05AA,8            ; 80h=dv¡©ka otev©ena
                jnz     l_186A                  ; Jump if not zero
                jmp     short l_18DD
l_186A:
                call    s_2B9C              ; test, zda je ji‘ konec disku
                cmp     al,2Dh                  ; '-'
                je      l_1874                  ; Jump if equal
                jmp     l_0862
l_1874:
                mov     d_05A4,1                ; (=1)
                mov     d_076B,3                ; (=0)
                mov     bl,1
                call    s_3076              ; odemknut¡/uzamknut¡ dv¡©ek
l_1883:
                mov     d_0779,0                ; (=1)
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,0C0h
                cmp     d_0766,44h          ; rozsah regulace hlasitosti CD (44h)
                jne     l_1897                  ; Jump if not equal

                mov     al,0C1h
l_1897:
                cli                             ; Disable interrupts
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,d_057C               ; (=0)
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,d_057D               ; (=0)
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,d_057E               ; (=0)
                out     dx,al                   ; port 300h, POST checkpoint
                xor     al,al                   ; Zero register
                out     dx,al                   ; port 300h, POST checkpoint
                nop
                out     dx,al                   ; port 300h, POST checkpoint
                nop
                out     dx,al                   ; port 300h, POST checkpoint
                sti                             ; Enable interrupts
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                jne     l_18BD                  ; Jump if not equal
                dec     d_076B                  ; (=0)
                jnz     l_1883                  ; Jump if not zero
                jmp     l_1B73
l_18BD:
                mov     bl,0
                call    s_3076              ; odemknut¡/uzamknut¡ dv¡©ek
                test    d_05AA,8            ; 80h=dv¡©ka otev©ena
                jz      l_18DD                  ; Jump if zero
                mov     d_05A4,1                ; (=1)
                mov     d_0308,0FFFFh           ; (=0FFFFh)
                mov     d_030A,0FFFFh           ; (=0FFFFh)
                jmp     l_0862
l_18DD:
                call    s_2B9C              ; test, zda je ji‘ konec disku
                cmp     al,2Dh                  ; '-'
                je      l_18E7                  ; Jump if equal
                jmp     l_0862
l_18E7:
                cmp     d_0781,0                ; (=0)
                je      l_18FD                  ; Jump if equal
                cmp     d_0572,930h         ; velikost sektoru ke ‡ten¡ (bajt–)
                je      l_18FD                  ; Jump if equal
                mov     d_059D,41h              ; (=0) 'A'
                jmp     short l_191D
l_18FD:
                cmp     d_0322,930h             ; (=800h)
                jne     l_190C                  ; Jump if not equal
                mov     d_059D,61h              ; (=0) 'a'
                jmp     short l_191D
l_190C:
                mov     d_059D,1                ; (=0)
                cmp     d_0599,0            ; ‡¡slo kan lu ©adi‡e DMA
                jne     l_191D                  ; Jump if not equal
                mov     d_059D,81h              ; (=0)
l_191D:
                mov     d_076B,3                ; (=0)
l_1922:

                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,50h                  ; 'P'
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,d_059D               ; (=0)
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                jne     l_193D                  ; Jump if not equal
                dec     d_076B                  ; (=0)
                jnz     l_1922                  ; Jump if not zero
                jmp     l_1B73
l_193D:
                mov     cx,2
l_1940:
                mov     d_076B,3                ; (=0)
l_1945:
                cmp     d_0599,0            ; ‡¡slo kan lu ©adi‡e DMA
                jne     l_1957                  ; Jump if not equal
                xor     al,al                   ; Zero register
                mov     d_05A4,al               ; (=1)
                mov     d_05A5,al               ; (=0)
                mov     d_05A3,al               ; (=0)
l_1957:
                cmp     d_0599,5            ; ‡¡slo kan lu ©adi‡e DMA
                jb      l_1970                  ; Jump if below
                mov     dx,d_02DC           ; b zov  adresa ©adi‡e CD + 3
                mov     al,d_059C               ; (=40h)
                and     al,0F0h
                out     dx,al                   ; port 303h ??i/o non-standard
                mov     al,d_059C               ; (=40h)
                mov     dx,d_02DC           ; b zov  adresa ©adi‡e CD + 3
                out     dx,al                   ; port 303h ??i/o non-standard
l_1970:
                call    s_2EB7              ; povolen¡ p©eru¨en¡
                call    s_2D1C
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                jne     l_1986                  ; Jump if not equal
                dec     d_076B                  ; (=0)
                jnz     l_1945                  ; Jump if not zero
                jmp     l_1B73
l_1986:
                cmp     al,2
                jne     l_198D                  ; Jump if not equal
                jmp     l_1B5F
l_198D:
                test    bl,1
                jz      l_199A                  ; Jump if zero
                dec     cx
                jnz     l_1998                  ; Jump if not zero
                jmp     l_084E
l_1998:
                jmp     short l_1940
l_199A:
                cmp     d_0599,0            ; ‡¡slo kan lu ©adi‡e DMA
                je      l_19E3                  ; Jump if equal
                mov     d_05A3,1                ; (=0)

                xor     al,al                   ; Zero register
                mov     d_05A4,al               ; (=1)
                mov     d_05A5,al               ; (=0)
                mov     al,d_059E           ; k¢d podle ‡¡sla p©eru¨en¡    ; (=40h)
                cmp     al,10h
                je      l_19CD                  ; Jump if equal
                cmp     al,30h                  ; '0'
                je      l_19D1                  ; Jump if equal
                cmp     al,40h                  ; '@'
                je      l_19D5                  ; Jump if equal
                cmp     al,50h                  ; 'P'
                je      l_19D9                  ; Jump if equal
                cmp     al,60h                  ; '`'
                je      l_19DD                  ; Jump if equal
                cmp     al,70h                  ; 'p'
                je      l_19E1                  ; Jump if equal
                int     0Bh                     ; Serial COM2
                jmp     short l_19E3
l_19CD:
                int     0Ah                     ; LAN adapter
                jmp     short l_19E3
l_19D1:
                int     0Dh                     ; Disk services
                jmp     short l_19E3
l_19D5:
                int     72h                     ; ??int non-standard interrupt
                jmp     short l_19E3
l_19D9:
                int     73h                     ; ??int non-standard interrupt
                jmp     short l_19E3
l_19DD:
                int     74h                     ; ??int non-standard interrupt
                jmp     short l_19E3
l_19E1:
                int     77h                     ; ??int non-standard interrupt
l_19E3:
                cmp     d_0789,1                ; (=0)
                jne     l_19FB                  ; Jump if not equal
                mov     ax,d_030C               ; (=0)
                mov     dx,d_030E               ; (=0)
                mov     d_0308,ax               ; (=0FFFFh)
                mov     d_030A,dx               ; (=0FFFFh)
                jmp     l_0878
l_19FB:
                cmp     d_0776,1                ; (=0)
                jne     l_1A05                  ; Jump if not equal
                jmp     l_0878
l_1A05:
                mov     ax,d_02E4           ; po‡et sektor– ke ‡ten¡
                cmp     ax,d_031C               ; (=0)
                jne     l_1A10                  ; Jump if not equal
                jmp     short l_1A84
l_1A10:
                mov     d_0792,0                ; (=0)
                mov     bx,8CA0h
l_1A18:
                mov     al,d_0786               ; (=0)

                cmp     al,1
                jge     l_1A76                  ; Jump if > or =
                cmp     d_05A4,1                ; (=1)
                jne     l_1A29                  ; Jump if not equal
                jmp     l_1B08
l_1A29:
                cmp     d_05A5,1                ; (=0)
                jne     l_1A74                  ; Jump if not equal
                jmp     l_1B08
                                                ;* No entry point to code
                mov     cx,1
                call    s_2E56              ; prodleva CX * 0.25 ms
                dec     bx
                jnz     l_1A50                  ; Jump if not zero
                mov     d_05A4,1                ; (=1)
                mov     d_0308,0FFFFh           ; (=0FFFFh)
                mov     d_030A,0FFFFh           ; (=0FFFFh)
                jmp     l_1AFA
l_1A50:
                mov     dx,d_02D6           ; b zov  adresa ©adi‡e CD + 1
                in      al,dx                   ; port 301h ??i/o non-standard
                test    al,4
                jnz     l_1A5C                  ; Jump if not zero
                jmp     l_1AE9
l_1A5C:
                mov     dx,d_02D6           ; b zov  adresa ©adi‡e CD + 1
                in      al,dx                   ; port 301h ??i/o non-standard
                test    al,2
                jnz     l_1A74                  ; Jump if not zero
                cmp     d_0792,1                ; (=0)
                je      l_1A74                  ; Jump if equal
                mov     d_0792,1                ; (=0)
                mov     bx,offset d_00C8        ; (=0FFh)
l_1A74:
                jmp     short l_1A18
l_1A76:
                call    s_1B91
                mov     ax,d_031C               ; (=0)
                cmp     ax,d_02E4           ; po‡et sektor– ke ‡ten¡
                je      l_1A84                  ; Jump if equal
                jmp     short l_1A10
l_1A84:
                mov     ax,d_02E4           ; po‡et sektor– ke ‡ten¡
                cmp     d_0770,0                ; (=0)
                je      l_1A95                  ; Jump if equal
                mov     cx,d_02E4           ; po‡et sektor– ke ‡ten¡
                call    s_1E05
l_1A95:
                xor     dx,dx                   ; Zero register
                add     ax,d_030C               ; (=0)
                adc     dx,d_030E               ; (=0)
                mov     d_0308,ax               ; (=0FFFFh)
                mov     d_030A,dx               ; (=0FFFFh)
                cmp     d_05A4,1                ; (=1)
                jne     l_1AE6                  ; Jump if not equal
                xor     ah,ah                   ; Zero register
                mov     al,d_0786               ; (=0)

                cmp     ax,d_02F6           ; po‡et buffer– 2 KB
                jae     l_1AE6                  ; Jump if above or =
                add     ax,d_0308               ; (=0FFFFh)
                adc     dx,0
                mov     d_0304,ax               ; (=0)
                mov     d_0306,dx               ; (=0)
                les     bx,d_0016               ; (=0) Load 32 bit ptr
                mov     d_0776,1                ; (=0)
                cmp     d_05A5,1                ; (=0)
                jne     l_1AD9                  ; Jump if not equal
                jmp     l_17AF
l_1AD9:
                cmp     d_0599,0            ; ‡¡slo kan lu ©adi‡e DMA
                je      l_1AE3                  ; Jump if equal
                jmp     l_199A
l_1AE3:
                jmp     l_17AF
l_1AE6:
                jmp     l_0878
l_1AE9:
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                jne     l_1AF2                  ; Jump if not equal
                jmp     short l_1B5F
l_1AF2:
                test    bl,4
                jz      l_1AFA                  ; Jump if zero
                jmp     l_085D
l_1AFA:
                mov     ax,d_02E4           ; po‡et sektor– ke ‡ten¡
                mov     dx,d_031C               ; (=0)
                sub     ax,dx
                jnz     l_1B08                  ; Jump if not zero
                jmp     l_0878
l_1B08:
                inc     d_075A                  ; (=0)
                cmp     d_075A,7                ; (=0)
                jb      l_1B15                  ; Jump if below
                jmp     short l_1B7D
l_1B15:
                mov     d_05A4,1                ; (=1)
                cmp     d_0599,0            ; ‡¡slo kan lu ©adi‡e DMA
                je      l_1B37                  ; Jump if equal
                mov     dx,d_0560               ; (=0)
                or      dx,dx                   ; Zero ?
                jz      l_1B2E                  ; Jump if zero
                mov     dx,0D4h
                jmp     short l_1B31
l_1B2E:
                mov     dx,0Ah
l_1B31:
                mov     al,d_0599           ; ‡¡slo kan lu ©adi‡e DMA
                or      al,4
                out     dx,al                   ; port 0Ah, DMA-1 mask reg bit
l_1B37:
                mov     d_0308,0FFFFh           ; (=0FFFFh)
                mov     d_030A,0FFFFh           ; (=0FFFFh)

                mov     ax,d_030C               ; (=0)
                mov     dx,d_030E               ; (=0)
                add     ax,d_031C               ; (=0)
                adc     dx,0
                mov     d_0304,ax               ; (=0)
                mov     d_0306,dx               ; (=0)
                les     bx,d_0016               ; (=0) Load 32 bit ptr
                jmp     l_17AF
l_1B5F:
                mov     d_05A4,1                ; (=1)
                mov     d_0308,0FFFFh           ; (=0FFFFh)
                mov     d_030A,0FFFFh           ; (=0FFFFh)
                jmp     l_0873
l_1B73:
                call    s_2B77              ; test v˜mˆny disku
                cmp     al,1
                je      l_1B5F                  ; Jump if equal
                jmp     l_15C5
l_1B7D:
                mov     d_05A4,1                ; (=1)
                mov     d_0308,0FFFFh           ; (=0FFFFh)
                mov     d_030A,0FFFFh           ; (=0FFFFh)
                jmp     l_085D

;==========================================================================
;                              SUBROUTINE
;==========================================================================

s_1B91          proc    near
                push    es
                push    ds
                push    bx
                cmp     d_0770,0                ; (=0)
                je      l_1BC0                  ; Jump if equal
                cmp     d_076D,0            ; velikost skupiny prokl d n¡     ; (=0)
                je      l_1BA4                  ; Jump if equal
                jmp     short l_1BC0
l_1BA4:
                cmp     d_076F,0            ; mezera mezi skupinami prokl d n¡
                jne     l_1BB9                  ; Jump if not equal
                mov     al,d_076C           ; velikost skupiny prokl d n¡
                mov     d_076D,al           ; velikost skupiny prokl d n¡
                mov     al,d_076E           ; mezera mezi skupinami prokl d n¡
                mov     d_076F,al           ; mezera mezi skupinami prokl d n¡
                jmp     short l_1BC0
l_1BB9:
                dec     d_076F              ; mezera mezi skupinami prokl d n¡
                jmp     l_1DDC
l_1BC0:
                dec     d_076D              ; velikost skupiny prokl d n¡
                mov     di,d_0318           ; p©enosov  adresa - offset
                mov     ax,d_031A           ; p©enosov  adresa - segment
                mov     es,ax
                mov     cx,d_0322               ; (=800h)
                cmp     cs:d_0781,0             ; (=0)
                je      l_1BDE                  ; Jump if equal
                mov     cx,cs:d_0572        ; velikost sektoru ke ‡ten¡ (bajt–)

l_1BDE:
                mov     bx,d_0314               ; (=0)
                shl     bl,1                    ; Shift w/zeros fill
                mov     si,d_0324[bx]           ; (=0)
                mov     ax,d_03A4[bx]           ; (=0)
                cmp     d_077A,1            ; p©¡znak extended pamˆti
                jne     l_1C67                  ; Jump if not equal
                mov     ax,cs
                mov     es,ax
                mov     ax,d_053E               ; (=0)
                mov     dx,d_04A4[bx]       ; tabulka ‡¡sel blok– 64 KB buffer– sektor–
                mov     cx,d_0424[bx]       ; tabulka adres buffer– sektor–
                cmp     cs:d_0781,0             ; (=0)
                je      l_1C16                  ; Jump if equal
                cmp     cs:d_0572,930h      ; velikost sektoru ke ‡ten¡ (bajt–)
                je      l_1C16                  ; Jump if equal
                add     cx,18h
l_1C16:
                mov     bx,offset d_0540        ; (=0)
                mov     es:[bx+4],ax
                mov     es:[bx+8],dx
                mov     es:[bx+6],cx
                mov     bx,offset d_0540        ; (=0)
                mov     ax,d_0322               ; (=800h)
                cmp     cs:d_0781,0             ; (=0)
                je      l_1C37                  ; Jump if equal
                mov     ax,cs:d_0572        ; velikost sektoru ke ‡ten¡ (bajt–)
l_1C37:
                mov     es:[bx],ax
                mov     word ptr es:[bx+2],0
                mov     word ptr es:[bx+0Ah],0
                mov     ax,d_031A           ; p©enosov  adresa - segment
                mov     es:[bx+0Eh],ax
                mov     ax,d_0318           ; p©enosov  adresa - offset
                mov     es:[bx+0Ch],ax
                mov     ax,cs
                mov     ds,ax
                mov     ax,540h
                mov     si,ax
                mov     ax,0B00h
                call    d_053A              ; adresa ovlada‡e extended pamˆti
                jmp     l_1DA7
l_1C67:
                cmp     cs:d_0781,0             ; (=0)
                je      l_1C7B                  ; Jump if equal
                cmp     cs:d_0572,930h      ; velikost sektoru ke ‡ten¡ (bajt–)
                je      l_1C7B                  ; Jump if equal
                add     si,18h
l_1C7B:
                mov     ds,ax
                cld                             ; Clear direction
                xor     ax,ax                   ; Zero register
                mov     cs:d_0774,al            ; (=0)
                sub     ax,di
                mov     bx,ax
                push    ax
                and     ax,3

                mov     cs:d_0528,ax            ; (=0)
                pop     ax
                cmp     cs:d_0781,0             ; (=0)
                je      l_1CA2                  ; Jump if equal
                cmp     ax,cs:d_0572        ; velikost sektoru ke ‡ten¡ (bajt–)
                jb      $+38h                   ; Jump if below
                jmp     short l_1CA9
l_1CA2:
                cmp     ax,cs:d_0322            ; (=800h)
                jb      $+2Fh                   ; Jump if below
l_1CA9:
                mov     ax,4
                sub     ax,cs:d_0528            ; (=0)
                mov     cs:d_052C,ax            ; (=0)
                mov     ax,cs:d_0322            ; (=800h)
                cmp     cs:d_0781,0             ; (=0)
                je      $+6                     ; Jump if equal
                mov     ax,cs:d_0572        ; velikost sektoru ke ‡ten¡ (bajt–)
                db      0C1h,0E8h, 02h, 48h, 2Eh,0A3h
                db       26h, 05h, 2Eh,0C7h, 06h, 2Ah
                db       05h, 00h, 00h,0EBh, 29h,0C1h
                db      0E8h, 02h, 2Eh,0A3h, 26h, 05h
                db       2Eh,0A1h, 22h, 03h, 2Eh, 80h
                db       3Eh, 81h, 07h, 00h, 74h, 04h
                db       2Eh,0A1h, 72h, 05h, 2Bh,0C3h
                db       50h, 83h,0E0h, 03h, 2Eh,0A3h
                db       2Ch, 05h, 58h,0C1h,0E8h, 02h
                db       2Eh,0A3h, 2Ah, 05h, 2Eh, 8Bh
                db       0Eh, 28h, 05h, 0Bh,0C9h, 74h
                db       18h

l_1D08:
                movsb                           ; Mov [si] to es:[di]
                or      di,di                   ; Zero ?
                jz      l_1D11                  ; Jump if zero
                loop    l_1D08                  ; Loop if cx > 0

                jmp     short l_1D20
l_1D11:
                mov     cs:d_0774,1             ; (=0)
                mov     ax,es
                add     ax,1000h
                mov     es,ax
                loop    l_1D08                  ; Loop if cx > 0

l_1D20:
                mov     cx,cs:d_0526            ; (=0)
                or      cx,cx                   ; Zero ?
                jz      l_1D53                  ; Jump if zero
                cmp     cs:d_0773,3             ; (=0) ; typ procesoru
                jae     $+8                     ; Jump if above or =
                shl     cx,1                    ; Shift w/zeros fill
                rep     movsw                   ; Rep when cx >0 Mov [si] to es:[di]
                jmp     short l_1D3A
                db      0F3h, 66h,0A5h
l_1D3A:
                cmp     cs:d_0774,1             ; (=0)

                je      l_1D53                  ; Jump if equal
                or      di,di                   ; Zero ?
                jnz     l_1D53                  ; Jump if not zero
                mov     cs:d_0774,1             ; (=0)
                mov     ax,es
                add     ax,1000h
                mov     es,ax
l_1D53:
                mov     cx,cs:d_052A            ; (=0)
                or      cx,cx                   ; Zero ?
                jz      l_1D6D                  ; Jump if zero
                cmp     cs:d_0773,3             ; (=0) ; typ procesoru
                jae     $+8                     ; Jump if above or =
                shl     cx,1                    ; Shift w/zeros fill
                rep     movsw                   ; Rep when cx >0 Mov [si] to es:[di]
                jmp     short l_1D6D
                db      0F3h, 66h,0A5h
l_1D6D:
                mov     cx,cs:d_052C            ; (=0)
                or      cx,cx                   ; Zero ?
                jz      l_1DA7                  ; Jump if zero
                cmp     cs:d_0774,1             ; (=0)
                je      l_1D8F                  ; Jump if equal
                or      di,di                   ; Zero ?
                jnz     l_1D8F                  ; Jump if not zero
                mov     cs:d_0774,1             ; (=0)
                mov     ax,es
                add     ax,1000h
                mov     es,ax

l_1D8F:
                movsb                           ; Mov [si] to es:[di]
                or      di,di                   ; Zero ?
                jz      l_1D98                  ; Jump if zero
                loop    l_1D8F                  ; Loop if cx > 0

                jmp     short l_1DA7
l_1D98:
                mov     cs:d_0774,1             ; (=0)
                mov     ax,es
                add     ax,1000h
                mov     es,ax
                loop    l_1D8F                  ; Loop if cx > 0

l_1DA7:
                mov     ax,cs
                mov     ds,ax
                inc     d_031C                  ; (=0)
                cmp     d_077A,1            ; p©¡znak extended pamˆti
                jne     l_1DD3                  ; Jump if not equal
                mov     ax,d_0322               ; (=800h)
                cmp     cs:d_0781,0             ; (=0)
                je      l_1DC5                  ; Jump if equal
                mov     ax,cs:d_0572        ; velikost sektoru ke ‡ten¡ (bajt–)
l_1DC5:
                add     d_0318,ax           ; p©enosov  adresa - offset
                jnc     l_1DD1                  ; Jump if carry=0

                add     d_031A,1000h        ; p©enosov  adresa - segment
l_1DD1:
                jmp     short l_1DDC
l_1DD3:
                mov     d_0318,di           ; p©enosov  adresa - offset
                mov     ax,es
                mov     d_031A,ax           ; p©enosov  adresa - segment
l_1DDC:
                mov     ax,d_0314               ; (=0)
                inc     ax
                cmp     ax,d_031E               ; (=0)
                jbe     l_1DE8                  ; Jump if below or =
                xor     ax,ax                   ; Zero register
l_1DE8:
                mov     d_0314,ax               ; (=0)
                dec     d_0786                  ; (=0)
                pop     bx
                pop     ds
                pop     es
                retn
s_1B91          endp


;==========================================================================
;                              SUBROUTINE
;==========================================================================

s_1DF3          proc    near
                mov     d_030A,0FFFFh           ; (=0FFFFh)
                mov     d_0308,0FFFFh           ; (=0FFFFh)
                mov     d_0772,0                ; (=0)
                retn
s_1DF3          endp


;==========================================================================
;                              SUBROUTINE
;==========================================================================

s_1E05          proc    near
                push    bx
                push    cx
                xor     ax,ax                   ; Zero register
                mov     bx,ax
                mov     al,d_076C           ; velikost skupiny prokl d n¡
l_1E0E:
                sub     cx,ax
                jbe     l_1E15                  ; Jump if below or =
                inc     bx
                jmp     short l_1E0E
l_1E15:
                xor     ah,ah                   ; Zero register
                mov     al,d_076C           ; velikost skupiny prokl d n¡
                mul     bx                      ; dx:ax = reg * ax
                pop     cx
                sub     cx,ax
                xor     dh,dh                   ; Zero register

                mov     dl,d_076C           ; velikost skupiny prokl d n¡
                add     dl,d_076E           ; mezera mezi skupinami prokl d n¡
                adc     dh,0
                mov     ax,bx
                mul     dx                      ; dx:ax = reg * ax
                add     ax,cx
                adc     dx,0
                pop     bx
                retn
s_1E05          endp


;==========================================================================
;                              SUBROUTINE
;==========================================================================

s_1E37          proc    near
                cmp     d_0599,0            ; ‡¡slo kan lu ©adi‡e DMA
                jne     $+4                     ; Jump if not equal
                jmp     short l_1EBC
                                                ;* No entry point to code
                mov     dh,ah
                and     dh,0F0h
                db      0C1h,0E0h, 04h, 03h,0D8h, 89h
                db       1Eh,0FEh, 02h, 72h, 02h,0EBh
                db       04h
l_1E52:
                clc                             ; Clear carry flag
                add     dh,10h
l_1E56:
                mov     ah,dh
                xor     al,al                   ; Zero register
                mov     d_02FC,ax               ; (=0)
                mov     bx,d_02FE               ; (=0)
                mov     dx,d_02FC               ; (=0)
                add     bx,d_0322               ; (=800h)
                jc      l_1E6D                  ; Jump if carry Set
                jmp     short l_1E76
l_1E6D:
                clc                             ; Clear carry flag
                add     dx,1000h
                xor     bx,bx                   ; Zero register
                jmp     short l_1E7A
l_1E76:
                mov     bx,d_02FE               ; (=0)
l_1E7A:
                mov     ds:d_0324[bp],bx        ; (=0)
                mov     ds:d_03A4[bp],dx        ; (=0)
                dec     cx
                jnz     l_1E88                  ; Jump if not zero
                retn

l_1E88:
                add     bx,d_0322               ; (=800h)
                mov     ax,bx
                add     bx,d_0322               ; (=800h)
                inc     bp

                inc     bp
                jc      l_1E98                  ; Jump if carry Set
                jmp     short l_1EA5
l_1E98:
                clc                             ; Clear carry flag
                or      bx,bx                   ; Zero ?
                jz      l_1EA5                  ; Jump if zero
                add     dx,1000h
                xor     bx,bx                   ; Zero register
                jmp     short l_1EAF
l_1EA5:
                or      ax,ax                   ; Zero ?
                jnz     l_1EAD                  ; Jump if not zero
                add     dx,1000h
l_1EAD:
                mov     bx,ax
l_1EAF:
                mov     ds:d_0324[bp],bx        ; (=0)
                mov     ds:d_03A4[bp],dx        ; (=0)
                loop    l_1E88                  ; Loop if cx > 0

                retn
l_1EBC:
                mov     dx,ax
                mov     ds:d_0324[bp],bx        ; (=0)
                mov     ds:d_03A4[bp],dx        ; (=0)
                dec     cl
                jnz     l_1ECD                  ; Jump if not zero
                retn

l_1ECD:
                inc     bp
                inc     bp
                add     bx,d_0322               ; (=800h)
                jnc     l_1EDA                  ; Jump if carry=0
                clc                             ; Clear carry flag
                add     dx,1000h
l_1EDA:
                mov     ds:d_0324[bp],bx        ; (=0)
                mov     ds:d_03A4[bp],dx        ; (=0)
                loop    l_1ECD                  ; Loop if cx > 0

                retn
s_1E37          endp

; -----------------------------------------------------------------------------
;        funkce 83h: vystaven¡ hlav
; -----------------------------------------------------------------------------
;þ
l_1EE7:
                cmp     d_0772,0                ; (=0)
                je      l_1F05                  ; Jump if equal
                call    s_2AB6              ; zji¨tˆn¡ velikosti disku (v sektorech)
                cmp     al,2
                jne     l_1EF8                  ; Jump if not equal
                jmp     l_0873
l_1EF8:
                cmp     al,0FFh
                jne     l_1EFF                  ; Jump if not equal
                jmp     l_0873
l_1EFF:

                call    s_2ED8              ; vystaven¡ hlav na zadanou pozici
                call    s_1DF3
l_1F05:
                call    s_2E74              ; ukon‡en¡ v¨ech p©enos– s CD
                mov     d_05A6,0                ; (=0)
                mov     d_05A7,0                ; (=0)
                mov     ax,es:[bx+14h]
                mov     dx,es:[bx+16h]
                cmp     byte ptr es:[bx+0Dh],0
                jne     l_1F29                  ; Jump if not equal
                add     ax,96h
                adc     dx,0
                jmp     short l_1F36
l_1F29:
                cmp     byte ptr es:[bx+0Dh],1
                je      l_1F33                  ; Jump if equal
                jmp     l_083A
l_1F33:
                call    s_2DFB              ; p©epo‡et MM:SS:FF r me‡ek DX:AX
l_1F36:
                mov     d_02F2,dx           ; ukazatel absolutn¡ho ‡¡sla sektoru
                mov     d_02F4,ax           ; ukazatel absolutn¡ho ‡¡sla sektoru
                call    s_2E19              ; p©epo‡et r me‡ku DX:AX na MM:SS:FF
                mov     al,dl
                call    s_2E28              ; p©evod bin rn¡ho ‡¡sla v AL na BCD ‡¡slo
                mov     d_057C,al               ; (=0)
                mov     al,ch
                call    s_2E28              ; p©evod bin rn¡ho ‡¡sla v AL na BCD ‡¡slo
                mov     d_057D,al               ; (=0)
                mov     al,cl
                call    s_2E28              ; p©evod bin rn¡ho ‡¡sla v AL na BCD ‡¡slo
                mov     d_057E,al               ; (=0)
                xor     ax,ax                   ; Zero register
                mov     d_057F,al               ; (=0)
                mov     d_0580,al               ; (=0)
                mov     d_0581,al               ; (=0)
                mov     d_05A4,1                ; (=1)
                mov     d_0314,ax               ; (=0)
                mov     d_0316,ax               ; (=0)
                mov     d_0786,al               ; (=0)
                call    s_2B4D              ; test, zda je vlo‘en disk
                cmp     al,0FFh
                jne     l_1F7B                  ; Jump if not equal
                jmp     l_2028
l_1F7B:
                cmp     al,2
                jne     l_1F82                  ; Jump if not equal
                jmp     l_0873
l_1F82:
                cmp     d_0772,0                ; (=0)
                je      l_1FA0                  ; Jump if equal
                call    s_2AB6              ; zji¨tˆn¡ velikosti disku (v sektorech)
                cmp     al,0FFh
                jne     l_1F93                  ; Jump if not equal
                jmp     l_1B5F
l_1F93:
                cmp     al,2

                jne     l_1F9A                  ; Jump if not equal
                jmp     l_1B5F
l_1F9A:
                call    s_2ED8              ; vystaven¡ hlav na zadanou pozici
                call    s_1DF3
l_1FA0:
                call    s_2B9C              ; test, zda je ji‘ konec disku
                cmp     al,2Dh                  ; '-'
                je      l_1FAA                  ; Jump if equal
                jmp     l_0858
l_1FAA:
                mov     d_076B,6                ; (=0)
                mov     bl,1
                call    s_3076              ; odemknut¡/uzamknut¡ dv¡©ek
l_1FB4:
                call    s_2D1C
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                jne     l_1FC6                  ; Jump if not equal
                dec     d_076B                  ; (=0)
                jnz     l_1FB4                  ; Jump if not zero
                jmp     short l_202B
l_1FC6:
                cmp     al,2
                je      l_2028                  ; Jump if equal
                mov     bl,0
                call    s_3076              ; odemknut¡/uzamknut¡ dv¡©ek
                call    s_2BD6              ; na‡ten¡ stavu ©adi‡e CD
                cmp     al,0FFh
                jne     l_1FD9                  ; Jump if not equal
                jmp     l_0873
l_1FD9:
                mov     al,d_0595           ; aktu ln¡ pozice hlavy - minuta
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                mov     dl,al
                mov     al,d_0596           ; aktu ln¡ pozice hlavy - sekunda
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                mov     dh,al
                mov     al,d_0597           ; aktu ln¡ pozice hlavy - r me‡ek
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                mov     ah,dh
                call    s_2DFB              ; p©epo‡et MM:SS:FF r me‡ek DX:AX
                mov     cx,d_02F2           ; ukazatel absolutn¡ho ‡¡sla sektoru
                mov     bx,d_02F4           ; ukazatel absolutn¡ho ‡¡sla sektoru
                cmp     dx,cx
                ja      l_200E                  ; Jump if above
                jc      l_200B                  ; Jump if carry Set
                cmp     ax,bx
                ja      l_200E                  ; Jump if above
                jc      l_200B                  ; Jump if carry Set
                jmp     l_0878
l_200B:
                xchg    dx,cx
                xchg    bx,ax
l_200E:
                sub     dx,cx
                cmp     dx,1

                ja      l_201F                  ; Jump if above
                sub     ax,bx
                cmp     ax,10h
                ja      l_201F                  ; Jump if above
                jmp     l_0878
l_201F:
                dec     d_076B                  ; (=0)
                jnz     l_1FB4                  ; Jump if not zero
                jmp     l_084E
l_2028:
                jmp     l_0873
l_202B:
                call    s_2B77              ; test v˜mˆny disku
                cmp     al,1
                je      l_2028                  ; Jump if equal
                jmp     l_1F7B
l_2035:
                jmp     l_0873

; -----------------------------------------------------------------------------
;        funkce 84h: p©ehr v n¡
; -----------------------------------------------------------------------------
;þ
l_2038:


                                              ;* No entry point to code
                call    s_2E74              ; ukon‡en¡ v¨ech p©enos– s CD
                cmp     d_0772,0                ; (=0)
                je      l_2053                  ; Jump if equal
                call    s_2AB6              ; zji¨tˆn¡ velikosti disku (v sektorech)
                cmp     al,2
                je      l_2035                  ; Jump if equal
                cmp     al,0FFh
                je      l_2035                  ; Jump if equal
                call    s_2ED8              ; vystaven¡ hlav na zadanou pozici
                call    s_1DF3
l_2053:
                mov     ax,es:[bx+0Eh]
                mov     dx,es:[bx+10h]
                test    byte ptr es:[bx+0Dh],1
                jnz     l_206A                  ; Jump if not zero
                add     ax,96h
                adc     dx,0
                jmp     short l_206D
l_206A:
                call    s_2DFB              ; p©epo‡et MM:SS:FF r me‡ek DX:AX
l_206D:
                mov     d_02F2,dx           ; ukazatel absolutn¡ho ‡¡sla sektoru
                mov     d_02F4,ax           ; ukazatel absolutn¡ho ‡¡sla sektoru
                mov     d_0310,ax               ; (=0)
                mov     d_0312,dx               ; (=0)
                call    s_2E19              ; p©epo‡et r me‡ku DX:AX na MM:SS:FF
                mov     al,dl
                call    s_2E28              ; p©evod bin rn¡ho ‡¡sla v AL na BCD ‡¡slo
                mov     d_057C,al               ; (=0)
                mov     al,ch
                call    s_2E28              ; p©evod bin rn¡ho ‡¡sla v AL na BCD ‡¡slo
                mov     d_057D,al               ; (=0)
                mov     al,cl
                call    s_2E28              ; p©evod bin rn¡ho ‡¡sla v AL na BCD ‡¡slo
                mov     d_057E,al               ; (=0)
                mov     ax,es:[bx+12h]
                mov     dx,es:[bx+14h]
                add     ax,d_0310               ; (=0)

                adc     dx,d_0312               ; (=0)
                mov     d_0578,ax               ; (=0)
                mov     d_057A,dx               ; (=0)
                jnc     l_20B6                  ; Jump if carry=0
                mov     ax,d_02F0               ; (=0FFFFh)
                mov     dx,d_02EE               ; (=0FFFFh)
l_20B6:
                call    s_2E19              ; p©epo‡et r me‡ku DX:AX na MM:SS:FF
                mov     al,dl
                call    s_2E28              ; p©evod bin rn¡ho ‡¡sla v AL na BCD ‡¡slo
                mov     d_057F,al               ; (=0)
                mov     al,ch
                call    s_2E28              ; p©evod bin rn¡ho ‡¡sla v AL na BCD ‡¡slo
                mov     d_0580,al               ; (=0)
                mov     al,cl
                call    s_2E28              ; p©evod bin rn¡ho ‡¡sla v AL na BCD ‡¡slo
                mov     d_0581,al               ; (=0)
                cmp     d_078B,1            ; 1=podporov ny sub-kan ly
                je      l_20DB                  ; Jump if equal
                jmp     l_21DF
l_20DB:
                mov     byte ptr d_3B88,0       ; (=0)
                mov     al,es:[bx+0Dh]
                test    al,2
                jz      l_20ED                  ; Jump if zero
                mov     byte ptr d_3B88,1       ; (=0)
l_20ED:
                mov     d_0768,1                ; (=0)
                xor     ax,ax                   ; Zero register
                mov     d_3AAA,ax               ; (=0)
                mov     d_3AAC,ax               ; (=0)
                mov     d_3ABA,al           ; ukazatel ‡¡sla © dku v sektoru
                mov     d_3ABB,al               ; (=0)
                mov     byte ptr d_3AB9,62h     ; (=62h) 'b'
                mov     d_05A4,1                ; (=1)
                mov     d_0308,0FFFFh           ; (=0FFFFh)
                mov     d_030A,0FFFFh           ; (=0FFFFh)
                xor     ax,ax                   ; Zero register
                mov     d_0316,ax               ; (=0)
                mov     d_0314,ax               ; (=0)
                mov     d_0786,al               ; (=0)
                mov     ax,d_02F4           ; ukazatel absolutn¡ho ‡¡sla sektoru
                mov     dx,d_02F2           ; ukazatel absolutn¡ho ‡¡sla sektoru
                cmp     d_0766,4Dh          ; rozsah regulace hlasitosti CD (44h)
                je      l_2142                  ; Jump if equal
                cmp     d_0766,44h          ; rozsah regulace hlasitosti CD (44h)
                jne     l_213D                  ; Jump if not equal
                test    d_0767,10h              ; (=0)
                jnz     l_2142                  ; Jump if not zero
l_213D:
                sub     ax,0Ah
                jmp     short l_2145
l_2142:
                sub     ax,4Bh              ; 75
l_2145:
                sbb     dx,0
                call    s_2E19              ; p©epo‡et r me‡ku DX:AX na MM:SS:FF

                mov     al,dl
                call    s_2E28              ; p©evod bin rn¡ho ‡¡sla v AL na BCD ‡¡slo
                mov     d_057C,al               ; (=0)
                mov     al,ch
                call    s_2E28              ; p©evod bin rn¡ho ‡¡sla v AL na BCD ‡¡slo
                mov     d_057D,al               ; (=0)
                mov     al,cl
                call    s_2E28              ; p©evod bin rn¡ho ‡¡sla v AL na BCD ‡¡slo
                mov     d_057E,al               ; (=0)
                mov     ax,es:[bx+12h]
                mov     dx,es:[bx+14h]
                add     ax,2
                adc     dx,0
                add     ax,d_0310               ; (=0)
                adc     dx,d_0312               ; (=0)
                jnc     l_2182                  ; Jump if carry=0
                mov     ax,d_02F0               ; (=0FFFFh)
                mov     dx,d_02EE               ; (=0FFFFh)
l_2182:
                call    s_2E19              ; p©epo‡et r me‡ku DX:AX na MM:SS:FF
                mov     al,dl
                call    s_2E28              ; p©evod bin rn¡ho ‡¡sla v AL na BCD ‡¡slo
                mov     d_057F,al               ; (=0)
                mov     al,ch
                call    s_2E28              ; p©evod bin rn¡ho ‡¡sla v AL na BCD ‡¡slo
                mov     d_0580,al               ; (=0)
                mov     al,cl
                call    s_2E28              ; p©evod bin rn¡ho ‡¡sla v AL na BCD ‡¡slo
                mov     d_0581,al               ; (=0)
                mov     ax,d_02F4           ; ukazatel absolutn¡ho ‡¡sla sektoru
                mov     dx,d_02F2           ; ukazatel absolutn¡ho ‡¡sla sektoru
                mov     d_0534,ax           ; sektor absolutnˆ LOW
                mov     d_0532,dx           ; sektor absolutnˆ HIGH
                call    s_2E19              ; p©epo‡et r me‡ku DX:AX na MM:SS:FF
                mov     al,dl
                call    s_2E28              ; p©evod bin rn¡ho ‡¡sla v AL na BCD ‡¡slo
                mov     d_3AB0,al               ; (=0)
                mov     al,ch
                call    s_2E28              ; p©evod bin rn¡ho ‡¡sla v AL na BCD ‡¡slo
                mov     d_3AB1,al               ; (=0)
                mov     al,cl
                call    s_2E28              ; p©evod bin rn¡ho ‡¡sla v AL na BCD ‡¡slo
                mov     d_3AB2,al               ; (=0)
                mov     ax,es:[bx+12h]
                mov     dx,es:[bx+14h]
                add     ax,2
                adc     dx,0
                mov     d_3AB3,dl               ; (=0)
                mov     d_3AB4,ah               ; (=0)
                mov     d_3AB5,al               ; (=0)
l_21DF:
                call    s_2B4D              ; test, zda je vlo‘en disk
                cmp     al,0FFh
                jne     l_21E9                  ; Jump if not equal
                jmp     l_236B
l_21E9:
                cmp     al,2

                jne     l_21F0                  ; Jump if not equal
                jmp     l_2375
l_21F0:
                cmp     d_0772,0                ; (=0)
                je      l_2213                  ; Jump if equal
                call    s_2AB6              ; zji¨tˆn¡ velikosti disku (v sektorech)
                cmp     al,0FFh
                jne     l_2201                  ; Jump if not equal
                jmp     l_2375
l_2201:
                cmp     al,2
                jne     l_2208                  ; Jump if not equal
                jmp     l_2375
l_2208:
                call    s_2ED8              ; vystaven¡ hlav na zadanou pozici
                call    s_1DF3
                call    s_2B4D              ; test, zda je vlo‘en disk
                jmp     short l_2224
l_2213:
                cmp     al,1
                jne     l_2224                  ; Jump if not equal
                mov     d_05A6,1                ; (=0)
                mov     d_05A7,0                ; (=0)
                jmp     l_0853
l_2224:
                call    s_2B9C              ; test, zda je ji‘ konec disku
                cmp     al,2Dh                  ; '-'
                je      l_222E                  ; Jump if equal
                jmp     l_0862
l_222E:
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,50h                  ; 'P'
                out     dx,al                   ; port 300h, POST checkpoint
                xor     al,al                   ; Zero register
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                jne     l_2242                  ; Jump if not equal
                jmp     l_0873
l_2242:
                mov     bl,1
                call    s_3076              ; odemknut¡/uzamknut¡ dv¡©ek
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,0C0h
                cmp     d_0766,44h          ; rozsah regulace hlasitosti CD (44h)
                jne     l_2256                  ; Jump if not equal
                mov     al,0C1h
l_2256:
                cli                             ; Disable interrupts
                mov     al,0C0h
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,d_057C               ; (=0)
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,d_057D               ; (=0)
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,d_057E               ; (=0)
                out     dx,al                   ; port 300h, POST checkpoint

                xor     al,al                   ; Zero register
                out     dx,al                   ; port 300h, POST checkpoint
                nop
                out     dx,al                   ; port 300h, POST checkpoint
                nop
                out     dx,al                   ; port 300h, POST checkpoint
                sti                             ; Enable interrupts
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                jne     l_2278                  ; Jump if not equal
                jmp     l_236B
l_2278:
                mov     bl,0
                call    s_3076              ; odemknut¡/uzamknut¡ dv¡©ek
                test    d_05AA,8            ; 80h=dv¡©ka otev©ena
                jnz     l_2291                  ; Jump if not zero
                mov     d_05A6,0                ; (=0)
                mov     d_05A7,0                ; (=0)
                jmp     l_0873
l_2291:
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,50h                  ; 'P'
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,1
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                jne     l_22A5                  ; Jump if not equal
                jmp     l_0873
l_22A5:
                cmp     d_0768,1                ; (=0)
                jne     l_22DE                  ; Jump if not equal
                mov     cx,6
l_22AF:
                test    d_05AA,2            ; 80h=dv¡©ka otev©ena
                jz      l_22BF                  ; Jump if zero
                call    s_2B4D              ; test, zda je vlo‘en disk
                dec     cx
                jnz     l_22AF                  ; Jump if not zero
                jmp     l_084E
l_22BF:
                xor     bx,bx                   ; Zero register
                mov     bl,d_3ABB               ; (=0)
                shl     bx,1                    ; Shift w/zeros fill
                mov     ax,d_3A5C[bx]           ; (=0)
                mov     d_3AAE,ax               ; (=0)
                call    s_3A32
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                jne     l_22DE                  ; Jump if not equal
                dec     cx
                jnz     l_22AF                  ; Jump if not zero
                jmp     l_0873
l_22DE:
                mov     d_05A4,1                ; (=1)
                mov     d_0790,0                ; (=0)
                call    s_2D1C

                cmp     d_0766,44h          ; rozsah regulace hlasitosti CD (44h)
                jne     l_22F7                  ; Jump if not equal
                mov     d_0790,1                ; (=0)
l_22F7:
                mov     dx,d_02D6           ; b zov  adresa ©adi‡e CD + 1
                mov     bx,8CA0h
l_22FE:
                in      al,dx                   ; port 301h ??i/o non-standard
                test    al,2
                jz      l_2312                  ; Jump if zero
                test    al,4
                jz      l_2334                  ; Jump if zero
                mov     cx,1
                call    s_2E56              ; prodleva CX * 0.25 ms
                dec     bx
                jnz     l_22FE                  ; Jump if not zero
                jmp     short l_236B
l_2312:
                cmp     d_0768,0                ; (=0)
                je      l_2375                  ; Jump if equal
                mov     d_0768,0                ; (=0)
                call    s_2B4D              ; test, zda je vlo‘en disk
                mov     d_0768,1                ; (=0)
                cmp     al,1
                je      l_2337                  ; Jump if equal
                cmp     al,0FFh
                jne     l_2331                  ; Jump if not equal
                jmp     l_0873
l_2331:
                jmp     l_084E
l_2334:
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
l_2337:
                cmp     al,0FFh
                jne     l_2345                  ; Jump if not equal
                cmp     d_0768,1                ; (=0)
                jne     l_2345                  ; Jump if not equal
                jmp     l_087C
l_2345:
                test    bl,8
                jnz     l_2357                  ; Jump if not zero
                mov     d_05A6,0                ; (=0)
                mov     d_05A7,0                ; (=0)
                jmp     l_0862
l_2357:
                test    bl,2
                jnz     l_235E                  ; Jump if not zero
                jmp     short l_236B
l_235E:
                mov     d_05A6,1                ; (=0)
                mov     d_05A7,0                ; (=0)
                jmp     l_087C
l_236B:
                call    s_2B77              ; test v˜mˆny disku
                cmp     al,1
                je      l_2375                  ; Jump if equal
                jmp     l_21E9

l_2375:
                mov     d_05A6,0                ; (=0)
                mov     d_05A7,0                ; (=0)
                jmp     l_0873

; -----------------------------------------------------------------------------
;        funkce 85h: zastaven¡ p©ehr v n¡
; -----------------------------------------------------------------------------
;þ
l_2382:
                                                ;* No entry point to code
                call    s_2E74              ; ukon‡en¡ v¨ech p©enos– s CD
                call    s_2B4D              ; test, zda je vlo‘en disk
                cmp     al,0FFh
                jne     l_2399                  ; Jump if not equal
                mov     d_05A6,0                ; (=0)
                mov     d_05A7,0                ; (=0)
                jmp     l_0873
l_2399:
                cmp     al,1
                je      l_23A3                  ; Jump if equal
                call    s_2456
                jmp     l_0878
l_23A3:
                mov     d_076B,3                ; (=0)
l_23A8:
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,70h                  ; 'p'
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                jne     l_23C2                  ; Jump if not equal
                dec     d_076B                  ; (=0)
                jnz     l_23A8                  ; Jump if not zero
                call    s_2456
                jmp     l_0873
l_23C2:
                call    s_2BD6              ; na‡ten¡ stavu ©adi‡e CD
                cmp     al,0FFh
                jne     l_23D6                  ; Jump if not equal
                mov     d_05A6,0                ; (=0)
                mov     d_05A7,0                ; (=0)
                jmp     l_0873
l_23D6:
                mov     al,d_057F               ; (=0)
                mov     d_058B,al           ; po‘adovan  pozice - minuta
                mov     al,d_0580               ; (=0)
                mov     d_058C,al           ; po‘adovan  pozice - sekunda
                mov     al,d_0581               ; (=0)
                mov     d_058D,al           ; po‘adovan  pozice - r me‡ek
                call    s_243A              ; po‘adovan  pozice DX:AX
                mov     d_02EC,dx               ; (=0)
                mov     d_02EA,ax               ; (=0)
                mov     al,d_0595           ; aktu ln¡ pozice hlavy - minuta
                mov     d_058B,al           ; po‘adovan  pozice - minuta
                mov     al,d_0596           ; aktu ln¡ pozice hlavy - sekunda
                mov     d_058C,al           ; po‘adovan  pozice - sekunda
                mov     al,d_0597           ; aktu ln¡ pozice hlavy - r me‡ek
                mov     d_058D,al           ; po‘adovan  pozice - r me‡ek
                call    s_243A              ; po‘adovan  pozice DX:AX
                cmp     dx,d_02EC               ; (=0)
                ja      l_2434                  ; Jump if above
                jc      l_2415                  ; Jump if carry Set

                cmp     ax,d_02EA               ; (=0)
                ja      l_2434                  ; Jump if above
l_2415:
                mov     al,d_0595           ; aktu ln¡ pozice hlavy - minuta
                mov     d_057C,al               ; (=0)
                mov     al,d_0596           ; aktu ln¡ pozice hlavy - sekunda
                mov     d_057D,al               ; (=0)
                mov     al,d_0597           ; aktu ln¡ pozice hlavy - r me‡ek
                mov     d_057E,al               ; (=0)
                mov     d_05A6,0                ; (=0)
                mov     d_05A7,1                ; (=0)
                jmp     l_0878
l_2434:
                call    s_2456
                jmp     l_0878

; -----------------------------------------------------------------------------
;        po‘adovan  pozice DX:AX
; -----------------------------------------------------------------------------

s_243A          proc    near
                mov     al,d_058B           ; po‘adovan  pozice - minuta
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                mov     dl,al
                mov     al,d_058C           ; po‘adovan  pozice - sekunda
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                mov     ch,al
                mov     al,d_058D           ; po‘adovan  pozice - r me‡ek
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                mov     ah,ch
                call    s_2DFB              ; p©epo‡et MM:SS:FF na r me‡ek DX:AX
                retn
s_243A          endp


;==========================================================================
;                              SUBROUTINE
;==========================================================================

s_2456          proc    near
                xor     ax,ax                   ; Zero register
                mov     d_05A6,al               ; (=0)
                mov     d_05A7,al               ; (=0)
                mov     d_057C,al               ; (=0)
                mov     d_057D,al               ; (=0)
                mov     d_057E,al               ; (=0)
                mov     d_057F,al               ; (=0)
                mov     d_0580,al               ; (=0)
                mov     d_0581,al               ; (=0)
                retn
s_2456          endp

; -----------------------------------------------------------------------------
;        funkce 88h: pokra‡ov n¡ v p©ehr v n¡
; -----------------------------------------------------------------------------
;þ
l_2471:
                                                ;* No entry point to code
                cmp     d_05A7,1                ; (=0)
                je      l_2485                  ; Jump if equal
                cmp     d_05A6,1                ; (=0)
                je      l_2482                  ; Jump if equal

                jmp     l_084E
l_2482:
                jmp     l_0853
l_2485:
                call    s_2B4D              ; test, zda je vlo‘en disk
                cmp     al,0FFh
                je      l_249C                  ; Jump if equal
                test    bl,20h                  ; ' '
                jz      l_2494                  ; Jump if zero
                jmp     l_084E
l_2494:
                test    bl,8
                jnz     l_24A9                  ; Jump if not zero
                jmp     l_084E
l_249C:
                mov     d_05A6,0                ; (=0)
                mov     d_05A7,0                ; (=0)
                jmp     l_084E
l_24A9:
                test    bl,40h                  ; '@'
                jnz     l_24B1                  ; Jump if not zero
                jmp     l_084E
l_24B1:
                test    bl,2
                jz      l_24B9                  ; Jump if zero
                jmp     l_0853
l_24B9:
                jmp     l_222E

; -----------------------------------------------------------------------------
;        obsluha p©eru¨en¡
; -----------------------------------------------------------------------------

l_24BC:
                                                ;* No entry point to code
                pushf                           ; Push flags
                push    ax
                push    bx
                push    cx
                push    dx
                push    ds
                push    es
                push    di
                push    si
                push    bp
                mov     ax,cs
                mov     ds,ax
                cmp     d_0768,1                ; (=0)
                je      l_24D4                  ; Jump if equal
                jmp     l_2590
l_24D4:
                mov     es,d_3AA4           ; segment bufferu na‡ten‚ho sektoru
                mov     ax,d_3AAE               ; (=0)
                mov     di,ax
                cld                             ; Clear direction
                xor     cx,cx                   ; Zero register
                cmp     d_0766,4Dh          ; rozsah regulace hlasitosti CD (44h)
                je      l_24FF                  ; Jump if equal
                cmp     d_0766,44h          ; rozsah regulace hlasitosti CD (44h)
                jne     l_24F5                  ; Jump if not equal
                test    d_0767,10h              ; (=0)
                jnz     l_24FF                  ; Jump if not zero
l_24F5:

                call    s_2845              ; na‡ten¡ 96 bajt– z ©adi‡e CD
                or      al,al                   ; Zero ?
                jz      l_252E                  ; Jump if zero
                jmp     l_25C7
l_24FF:
                mov     cl,20h                  ; ' '
l_2501:
                mov     bx,0FFFFh
l_2504:
                mov     dx,d_02D6           ; b zov  adresa ©adi‡e CD + 1
                in      al,dx                   ; port 301h ??i/o non-standard
                test    al,4
                jz      $+8                     ; Jump if zero
                dec     bx
                jnz     l_2504                  ; Jump if not zero
                jmp     l_25C7
                                                ;* No entry point to code
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                db       6Ch, 49h, 3Ch, 9Fh, 74h, 0Ch
                db      0FEh, 0Eh,0B9h, 3Ah, 74h, 06h
                db       0Bh,0C9h, 75h,0DAh,0EBh, 60h
                db      0C6h, 06h,0B9h
                db       3Ah, 62h
l_252E:
                mov     al,d_3ABB               ; (=0)
                inc     al
                cmp     al,21h                  ; '!'
                jbe     l_2539                  ; Jump if below or =
                xor     al,al                   ; Zero register
l_2539:
                mov     d_3ABB,al               ; (=0)
                cmp     al,d_3ABA           ; ukazatel ‡¡sla © dku v sektoru
                jne     l_256C                  ; Jump if not equal
                cmp     byte ptr d_3ABD,0       ; (=0)
                je      l_2557                  ; Jump if equal
                cmp     byte ptr d_3ABD,1       ; (=0)
                je      l_255C                  ; Jump if equal
                mov     byte ptr d_3ABD,3       ; (=0)
                jmp     short l_255C
l_2557:
                mov     byte ptr d_3ABD,1       ; (=0)
l_255C:
                inc     d_3ABA              ; ukazatel ‡¡sla © dku v sektoru
                cmp     byte ptr d_3ABA,21h ; ukazatel ‡¡sla © dku v sektoru
                jbe     l_256C                  ; Jump if below or =
                mov     byte ptr d_3ABA,0   ; ukazatel ‡¡sla © dku v sektoru
l_256C:
                inc     d_0534              ; sektor absolutnˆ LOW
                jnz     l_2576                  ; Jump if not zero
                inc     d_0532              ; sektor absolutnˆ HIGH
l_2576:
                xor     bx,bx                   ; Zero register
                mov     bl,d_3ABB               ; (=0)
                shl     bx,1                    ; Shift w/zeros fill
                mov     di,d_3A5C[bx]           ; (=0)
                or      cx,cx                   ; Zero ?
                jz      l_2589                  ; Jump if zero

                jmp     l_2501
l_2589:
                mov     ax,di
                mov     d_3AAE,ax               ; (=0)
                jmp     short l_25C7
l_2590:
                mov     dx,d_02D6           ; b zov  adresa ©adi‡e CD + 1
                in      al,dx                   ; port 301h ??i/o non-standard
                test    al,4
                jz      l_259B                  ; Jump if zero
                jmp     short l_25D1
l_259B:
                cmp     d_0778,1            ; 1=p©¡znak ‡ek n¡ na p©ipravenost ©adi‡e
                je      l_25C7                  ; Jump if equal
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                in      al,dx                   ; port 300h, POST checkpoint
                test    al,20h                  ; ' '
                jz      l_25C7                  ; Jump if zero
                mov     d_0772,1                ; (=0)
                mov     d_0757,1                ; (=0)
                mov     d_078A,1                ; (=1)
                call    s_305B
                mov     d_05A6,0                ; (=0)
                mov     d_05A7,0                ; (=0)
l_25C7:
                mov     d_0779,1                ; (=1)
                mov     d_05A4,1                ; (=1)
l_25D1:
                cmp     d_05A4,1                ; (=1)
                jne     l_25E4                  ; Jump if not equal
                cmp     d_0599,0            ; ‡¡slo kan lu ©adi‡e DMA
                jne     l_25E2                  ; Jump if not equal
                jmp     l_27C2
l_25E2:
                jmp     short l_2611
l_25E4:
                cmp     d_05A3,1                ; (=0)
                jne     l_25EE                  ; Jump if not equal
                jmp     l_268A
l_25EE:
                cmp     d_0599,0            ; ‡¡slo kan lu ©adi‡e DMA
                jne     l_25F8                  ; Jump if not equal
                jmp     l_2747
l_25F8:
                mov     dx,d_0560               ; (=0)
                or      dx,dx                   ; Zero ?
                jz      l_2605                  ; Jump if zero
                mov     dx,0D0h
                jmp     short l_2608
l_2605:
                mov     dx,8
l_2608:
                in      al,dx                   ; port 8, DMA-1 status reg
                test    al,d_059A           ; maska kan lu DMA (port 00DEh)
                jz      l_2611                  ; Jump if zero
                jmp     short l_262F
l_2611:

                mov     d_05A4,1                ; (=1)
                mov     al,d_0599           ; ‡¡slo kan lu ©adi‡e DMA
                or      al,4
                mov     dx,d_0560               ; (=0)
                or      dx,dx                   ; Zero ?
                jz      l_2628                  ; Jump if zero
                mov     dx,0D4h
                jmp     short l_262B
l_2628:
                mov     dx,0Ah
l_262B:
                out     dx,al                   ; port 0Ah, DMA-1 mask reg bit
                jmp     l_27C2
l_262F:
                cmp     d_077A,1            ; p©¡znak extended pamˆti
                jne     l_2639                  ; Jump if not equal
                call    s_27DF
l_2639:
                inc     d_0786                  ; (=0)
                mov     ax,d_0316               ; (=0)
                inc     ax
                cmp     ax,d_031E               ; (=0)
                jbe     l_2649                  ; Jump if below or =
                xor     ax,ax                   ; Zero register
l_2649:
                mov     d_0316,ax               ; (=0)
                cmp     ax,d_0314               ; (=0)
                je      l_265E                  ; Jump if equal
                cmp     d_0599,0            ; ‡¡slo kan lu ©adi‡e DMA
                jne     l_265C                  ; Jump if not equal
                jmp     l_27C2
l_265C:
                jmp     short l_268A
l_265E:
                mov     d_05A4,1                ; (=1)
                cmp     d_0599,0            ; ‡¡slo kan lu ©adi‡e DMA
                jne     l_2687                  ; Jump if not equal
                dec     d_0786                  ; (=0)
                mov     d_05A4,1                ; (=1)
                cmp     d_0316,0                ; (=0)
                je      l_2681                  ; Jump if equal
                dec     d_0316                  ; (=0)
                jmp     l_27C2
l_2681:
                mov     ax,d_031E               ; (=0)
                mov     d_0316,ax               ; (=0)
l_2687:
                jmp     l_27C2
l_268A:
                mov     d_05A4,0                ; (=1)
                mov     bx,d_0316               ; (=0)
                shl     bl,1                    ; Shift w/zeros fill
                cmp     d_077A,1            ; p©¡znak extended pamˆti
                jne     l_269E                  ; Jump if not equal
                xor     bx,bx                   ; Zero register
l_269E:
                mov     ax,d_0324[bx]           ; (=0)

                mov     word ptr ds:[2FAh],ax   ; (8535:02FA=0)
                mov     ax,d_03A4[bx]           ; (=0)
                mov     d_02F8,ax               ; (=0)
                cmp     d_0560,0                ; (=0)
                jne     $+4                     ; Jump if not equal
                jmp     short $+58h
                                                ;* No entry point to code
                mov     ax,word ptr ds:[2FAh]   ; (8535:02FA=0)
                shr     ax,1                    ; Shift w/zeros fill
                mov     bx,d_02F8               ; (=0)
                db      0C0h,0EFh, 05h, 73h, 03h, 80h
                db      0CCh, 80h, 8Bh,0D8h, 33h,0C0h
                db      0E6h,0D8h,0A0h, 99h, 05h, 24h
                db       03h,0C0h,0E0h, 02h,0BAh,0C0h
                db       00h, 03h,0D0h, 8Ah,0C3h,0EEh
                db       8Ah,0C7h,0EEh, 42h, 42h,0A1h
                db       22h, 03h,0D1h,0E8h, 48h,0EEh
                db       8Ah,0C4h,0EEh, 8Bh, 16h, 62h
                db       05h,0A1h,0F8h, 02h, 8Ah,0C4h
                db      0C0h,0E8h, 04h,0EEh,0A0h, 9Bh
                db       05h,0E6h,0D6h,0A0h, 99h, 05h
                db       24h, 03h,0E6h,0D4h, 32h,0C0h
                db      0E6h,0D0h,0E9h,0B7h, 00h, 33h
                db      0C0h,0E6h, 0Ch,0A0h, 99h, 05h
                db       24h, 03h,0D0h,0E0h, 8Bh,0D0h
                db      0A1h,0FAh, 02h,0EEh, 8Ah,0C4h
                db      0EEh, 42h,0A1h, 22h, 03h, 48h
                db      0EEh, 8Ah,0C4h,0EEh, 8Bh, 16h
                db       62h, 05h,0A1h,0F8h, 02h, 8Ah
                db      0C4h,0C0h,0E8h, 04h,0EEh,0A0h
                db       9Bh, 05h,0E6h, 0Bh,0A0h, 99h
                db       05h, 24h, 03h,0E6h, 0Ah, 32h
                db      0C0h,0E6h, 08h,0EBh
                db      7Bh
l_2747:
                mov     bx,d_0316               ; (=0)
                shl     bl,1                    ; Shift w/zeros fill
                cmp     d_077A,1            ; p©¡znak extended pamˆti
                jne     $+4                     ; Jump if not equal
                xor     bx,bx                   ; Zero register
                mov     ax,d_0324[bx]           ; (=0)
                mov     word ptr ds:[2FAh],ax   ; (8535:02FA=0)
                mov     ax,d_03A4[bx]           ; (=0)
                mov     d_02F8,ax               ; (=0)
                mov     cx,d_0322               ; (=800h)
                cld                             ; Clear direction
                push    es
                push    di
                mov     es,d_02F8               ; (=0)
                mov     di,word ptr ds:[2FAh]   ; (8535:02FA=0)
                mov     dx,d_02DA           ; b zov  adresa ©adi‡e CD + 2
                mov     al,0
                out     dx,al                   ; port 302h ??i/o non-standard
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                db      0F3h, 6Ch, 8Bh, 16h,0DAh, 02h
                db      0B0h, 08h,0EEh, 8Bh, 16h,0D6h
                db       02h,0ECh,0A8h, 02h, 75h, 16h

                db       8Bh, 16h,0DAh, 02h,0B0h, 00h
                db      0EEh, 8Bh, 16h,0D4h, 02h,0ECh
                db      0ECh, 8Bh, 16h,0DAh, 02h,0B0h
                db       08h,0EEh,0EBh, 0Dh, 81h, 3Eh
                db       22h, 03h, 30h, 09h, 74h, 05h
                db       5Fh, 07h,0E9h,0ABh,0FEh
l_27B3:
                cmp     d_077A,1            ; p©¡znak extended pamˆti
                jne     l_27BD                  ; Jump if not equal
                call    s_27DF
l_27BD:
                pop     di
                pop     es
                jmp     l_2639
l_27C2:
                mov     al,20h                  ; ' '
                cmp     d_059E,30h          ; k¢d podle ‡¡sla p©eru¨en¡
                jbe     l_27CD                  ; Jump if below or =
                out     0A0h,al                 ; port 0A0h  al = 20h, end of interrup
l_27CD:
                out     20h,al                  ; port 20h, 8259-1 int command
                                                ;  al = 20h, end of interrupt
                mov     d_05A3,0                ; (=0)
                pop     bp
                pop     si
                pop     di
                pop     es
                pop     ds
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                popf                            ; Pop flags
                iret                            ; Interrupt return

;==========================================================================
;                              SUBROUTINE
;==========================================================================

s_27DF          proc    near
                mov     ax,cs
                mov     ds,ax
                mov     es,ax
                mov     d_0574,sp               ; (=0)
                mov     d_0576,ss               ; (=0CD7h)
                mov     ax,d_0566               ; (=0)
                mov     ss,ax
                mov     sp,d_0568               ; (=0)
                mov     bx,d_0316               ; (=0)
                shl     bl,1                    ; Shift w/zeros fill
                mov     ax,d_053E               ; (=0)
                mov     dx,d_04A4[bx]       ; tabulka ‡¡sel blok– 64 KB buffer– sektor–
                mov     cx,d_0424[bx]       ; tabulka adres buffer– sektor–
                mov     bx,offset d_0550        ; (=0)
                mov     es:[bx+0Ah],ax
                mov     es:[bx+0Eh],dx
                mov     es:[bx+0Ch],cx

                mov     ax,d_0322               ; (=800h)
                mov     es:[bx],ax
                mov     word ptr es:[bx+4],0
                mov     ax,d_03A4               ; (=0)
                mov     es:[bx+8],ax
                mov     ax,d_0324               ; (=0)
                mov     es:[bx+6],ax
                mov     ax,550h
                mov     si,ax
                mov     ax,0B00h
                call    d_053A              ; adresa ovlada‡e extended pamˆti
                mov     sp,d_0574               ; (=0)
                mov     ss,d_0576               ; (=0CD7h)
                retn
s_27DF          endp


;==========================================================================
;        na‡ten¡ 96 bajt– z ©adi‡e CD
;==========================================================================

s_2845          proc    near
                mov     cl,60h                  ; '`'
                mov     bx,0FFFFh
l_284A:
                mov     dx,d_02D6           ; b zov  adresa ©adi‡e CD + 1
                in      al,dx                   ; port 301h ??i/o non-standard
                test    al,2
                jz      l_2858                  ; Jump if zero
                dec     bx
                jnz     l_284A                  ; Jump if not zero
                jmp     short l_2869
l_2858:
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                in      al,dx                   ; port 300h, POST checkpoint
                stosb                           ; Store al to es:[di]
                dec     cx
                jnz     l_284A                  ; Jump if not zero
                mov     d_078D,1                ; (=0)
                xor     al,al                   ; Zero register
                retn
l_2869:
                mov     al,1
                retn
s_2845          endp


;==========================================================================
;                              SUBROUTINE
;==========================================================================

s_286C          proc    near
                mov     d_0791,0                ; (=0)
                mov     d_076B,3Ch              ; (=0) '<'
l_2876:
                push    bx
                call    s_2CD5              ; ‡ten¡ aktu ln¡ pozice hlavy

                pop     bx
                or      al,al                   ; Zero ?
                jz      l_288A                  ; Jump if zero
                cmp     al,0FFh
                jne     l_2889                  ; Jump if not equal
                dec     d_076B                  ; (=0)
                jnz     l_2876                  ; Jump if not zero

l_2889:
                retn
l_288A:
                cmp     d_0782,2                ; (=0)
                je      l_289D                  ; Jump if equal
                cmp     d_0782,1                ; (=0)
                je      l_289D                  ; Jump if equal
                mov     d_0784,2            ; po‘adovan  pozice vystaven¡ - sekundy
l_289D:
                mov     al,d_0783           ; po‘adovan  pozice vystaven¡ - minuty
                or      al,d_0784           ; po‘adovan  pozice vystaven¡ - sekundy
                or      al,d_0785           ; po‘adovan  pozice vystaven¡ - r me‡ky
                jnz     l_28D7                  ; Jump if not zero
                dec     d_076B                  ; (=0)
                mov     d_0784,2            ; po‘adovan  pozice vystaven¡ - sekundy
                jnz     l_28BA                  ; Jump if not zero
                mov     d_078A,0                ; (=1)
l_28BA:
                cmp     d_078A,0                ; (=1)
                je      l_28D7                  ; Jump if equal
                test    d_05AA,10h          ; 80h=dv¡©ka otev©ena
                jnz     l_28CF                  ; Jump if not zero
                mov     d_078A,0                ; (=1)
                jmp     short l_28D7
l_28CF:

; ---- prodleva 0.5 sekundy

                mov     cx,7D0h
                call    s_2E56              ; prodleva CX * 0.25 ms
                jmp     short l_2876
l_28D7:
                cmp     d_078A,0                ; (=1)
                jne     l_2916                  ; Jump if not equal
                mov     cx,6
l_28E1:
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,0C0h
                cmp     d_0766,44h          ; rozsah regulace hlasitosti CD (44h)
                jne     l_28F0                  ; Jump if not equal
                mov     al,0C1h
l_28F0:
                cli                             ; Disable interrupts
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,0
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,2
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,10h
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,0
                out     dx,al                   ; port 300h, POST checkpoint

                mov     al,0
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,0
                out     dx,al                   ; port 300h, POST checkpoint
                sti                             ; Enable interrupts
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                test    bl,5
                jnz     l_2911                  ; Jump if not zero
                cmp     al,0FFh
                jne     l_2916                  ; Jump if not equal
l_2911:
                dec     cx
                jnz     l_28E1                  ; Jump if not zero
                jmp     short l_2980
l_2916:
                mov     d_076B,1Eh              ; (=0)
l_291B:
                mov     cx,3
l_291E:
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,50h                  ; 'P'
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,1
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                jne     l_2934                  ; Jump if not equal
                dec     cx
                jnz     l_291E                  ; Jump if not zero
                jmp     short l_2980
l_2934:
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,90h
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,2
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,0
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                mov     cx,3
l_2947:
                mov     bl,d_0781               ; (=0)
                inc     bl
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,0A0h
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,bl
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                jne     l_2963                  ; Jump if not equal
                dec     cx
                jnz     l_2947                  ; Jump if not zero
                jmp     short l_2980
l_2963:
                mov     al,d_0783           ; po‘adovan  pozice vystaven¡ - minuty
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo

                mov     dl,al
                mov     al,d_0784           ; po‘adovan  pozice vystaven¡ - sekundy
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                mov     ch,al
                mov     al,d_0785           ; po‘adovan  pozice vystaven¡ - r me‡ky
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                mov     ah,ch
                call    s_2DFB              ; p©epo‡et MM:SS:FF r me‡ek DX:AX
                jmp     short l_2983
l_2980:
                mov     al,0FFh
                retn
l_2983:
                mov     d_0778,1            ; 1=p©¡znak ‡ek n¡ na p©ipravenost ©adi‡e
                add     ax,10h
                adc     dx,0
                mov     d_056A,ax               ; (=0)
                mov     d_056E,ax               ; (=0)
                mov     d_056C,dx               ; (=0)
                mov     d_0570,dx               ; (=0)
l_299C:
                mov     ax,d_056E               ; (=0)
                mov     dx,d_0570               ; (=0)
                call    s_2E19              ; p©epo‡et r me‡ku DX:AX na MM:SS:FF
                mov     al,dl
                call    s_2E28              ; p©evod bin rn¡ho ‡¡sla v AL na BCD ‡¡slo
                mov     bh,al
                mov     al,ch
                call    s_2E28              ; p©evod bin rn¡ho ‡¡sla v AL na BCD ‡¡slo
                mov     bl,al
                mov     al,cl
                call    s_2E28              ; p©evod bin rn¡ho ‡¡sla v AL na BCD ‡¡slo
                mov     cl,al
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,0C0h
                cmp     d_0766,44h          ; rozsah regulace hlasitosti CD (44h)
                jne     l_29CA                  ; Jump if not equal
                mov     al,0C1h
l_29CA:
                cli                             ; Disable interrupts
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,bh
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,bl
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,cl
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,0
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,0
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,1
                out     dx,al                   ; port 300h, POST checkpoint
                sti                             ; Enable interrupts
                mov     bx,0BB80h
                mov     dx,d_02D6           ; b zov  adresa ©adi‡e CD + 1
l_29E6:

                in      al,dx                   ; port 301h ??i/o non-standard
                test    al,4
                jnz     l_29ED                  ; Jump if not zero
                jmp     short l_2A65
l_29ED:
                test    al,2
                jz      l_29FC                  ; Jump if zero
                mov     cx,1
                call    s_2E56              ; prodleva CX * 0.25 ms
                dec     bx
                jnz     l_29E6                  ; Jump if not zero
                jmp     short l_2A6D
l_29FC:
                mov     dx,d_02DA           ; b zov  adresa ©adi‡e CD + 2
                mov     al,0
                out     dx,al                   ; port 302h ??i/o non-standard
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     cx,9
                cmp     d_0781,0                ; (=0)
                jne     l_2A14                  ; Jump if not equal
                mov     cx,1

l_2A14:
                in      al,dx                   ; port 300h, POST checkpoint
                loop    l_2A14                  ; Loop if cx > 0

                push    ax
                mov     cx,7F7h
                cmp     d_0781,0                ; (=0)
                jne     l_2A25                  ; Jump if not equal
                mov     cx,7FFh

l_2A25:
                in      al,dx                   ; port 300h, POST checkpoint
                loop    l_2A25                  ; Loop if cx > 0

                mov     dx,d_02DA           ; b zov  adresa ©adi‡e CD + 2
                mov     al,8
                out     dx,al                   ; port 302h ??i/o non-standard
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                pop     ax
                cmp     d_0782,0                ; (=0)
                je      l_2A86                  ; Jump if equal
                cmp     al,0FFh
                je      l_2A5E                  ; Jump if equal
                cmp     d_0791,1                ; (=0)
                jne     l_2A51                  ; Jump if not equal
                sub     d_056E,1                ; (=0)
                sbb     d_0570,0                ; (=0)
                jmp     short l_2A86
l_2A51:
                add     d_056E,1                ; (=0)
                adc     d_0570,0                ; (=0)
                jmp     l_299C
l_2A5E:
                mov     d_0791,1                ; (=0)
                jmp     short l_2A51

l_2A65:
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                test    bl,8
                jnz     l_2A86                  ; Jump if not zero
l_2A6D:
                mov     d_0778,0            ; 1=p©¡znak ‡ek n¡ na p©ipravenost ©adi‡e
                dec     d_076B                  ; (=0)
                jnz     l_2A7B                  ; Jump if not zero
                jmp     l_2980
l_2A7B:
                mov     al,d_0781               ; (=0)
                xor     al,1
                mov     d_0781,al               ; (=0)
                jmp     l_291B
l_2A86:
                mov     d_0778,0            ; 1=p©¡znak ‡ek n¡ na p©ipravenost ©adi‡e
                mov     ax,d_056E               ; (=0)
                sub     ax,d_056A               ; (=0)
                mov     d_056E,ax               ; (=0)
                mov     ax,d_0570               ; (=0)
                sbb     ax,d_056C               ; (=0)
                mov     d_0570,ax               ; (=0)
                sub     d_056A,0A6h             ; (=0)
                sbb     d_056C,0                ; (=0)
                add     d_056E,0A6h             ; (=0)
                adc     d_0570,0                ; (=0)
                retn
s_286C          endp


;==========================================================================
;        zji¨tˆn¡ velikosti disku (v sektorech)
;==========================================================================

s_2AB6          proc    near

                mov     d_076B,3            ; po‡et pokus–
l_2ABB:
                push    bx
                call    s_2C60              ; na‡ten¡ parametr– disku
                pop     bx
                or      al,al                   ; Zero ?
                jz      l_2ACF                  ; Jump if zero
                cmp     al,0FFh
                jne     l_2ACE                  ; Jump if not equal
                dec     d_076B                  ; (=0)
                jnz     l_2ABB                  ; Jump if not zero
l_2ACE:         retn

l_2ACF:         mov     al,d_0585           ; minuta adresy v˜bˆhov‚ stopy
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                mov     dl,al
                mov     al,d_0586           ; sekunda adresy v˜bˆhov‚ stopy
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                mov     ch,al
                mov     al,d_0587           ; r me‡ek adresy v˜bˆhov‚ stopy
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                mov     ah,ch
                call    s_2DFB              ; p©epo‡et MM:SS:FF r me‡ek DX:AX

                mov     d_02F0,ax               ; (=0FFFFh)
                mov     d_02E6,ax           ; velikost disku v sektorech LOW
                mov     d_02E8,dx           ; velikost disku v sektorech HIGH
                mov     d_02EE,dx               ; (=0FFFFh)
                cmp     d_02E8,0            ; velikost disku v sektorech HIGH
                jne     l_2B17                  ; Jump if not equal
                cmp     d_02E6,0            ; velikost disku v sektorech LOW
                jne     l_2B17                  ; Jump if not equal
                dec     d_076B                  ; (=0)
                jnz     l_2B0F                  ; Jump if not zero
                mov     al,0FFh
                retn

l_2B0F:
; ----- prodleva 5 sekund

                mov     cx,4E20h
                call    s_2E56              ; prodleva CX * 0.25 ms
                jmp     short l_2ABB
l_2B17:
                xor     al,al                   ; Zero register
                retn
s_2AB6          endp

;==========================================================================
;        p©eru¨en¡ p©enosu DMA
;==========================================================================

s_2B1A          proc    near
                cmp     d_0599,5            ; ‡¡slo kan lu ©adi‡e DMA
                jb      l_2B43                  ; Jump if below
                test    d_05AA,40h          ; 80h=dv¡©ka otev©ena
                jz      l_2B43                  ; Jump if zero
                test    d_05AA,8            ; 80h=dv¡©ka otev©ena
                jnz     l_2B43                  ; Jump if not zero
                mov     d_05A4,1                ; (=1)
                mov     al,d_0599           ; ‡¡slo kan lu ©adi‡e DMA
                or      al,4                ; bit bude nastaven
                mov     dx,0D4h
                out     dx,al                   ; port 0D4h, DMA-2 mask reg bit
                mov     cx,1
                call    s_2E56              ; prodleva CX * 0.25 ms
l_2B43:
                mov     dx,d_02DA           ; b zov  adresa ©adi‡e CD + 2
                mov     al,8                ; povel pro p©eru¨en¡ p©enosu DMA
                out     dx,al                   ; port 302h ??i/o non-standard
                xor     al,al                   ; Zero register
                retn
s_2B1A          endp


;==========================================================================
;        test, zda je vlo‘en disk
;==========================================================================

s_2B4D          proc    near

                mov     d_076B,3                ; (=0)
l_2B52:
                call    s_2B1A              ; p©eru¨en¡ p©enosu DMA
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,40h                  ; '@'
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                or      al,al                   ; Zero ?
                jz      l_2B6E                  ; Jump if zero
                cmp     al,0FFh
                jne     l_2B76                  ; Jump if not equal
                dec     d_076B                  ; (=0)
                jnz     l_2B52                  ; Jump if not zero
                retn
l_2B6E:
                test    bl,2
                jz      l_2B76                  ; Jump if zero
                mov     ax,1
l_2B76:         retn

s_2B4D          endp

;==========================================================================
;        test v˜mˆny disku
;==========================================================================

s_2B77          proc    near
                cmp     d_0759,1            ; 1=disk je zn m˜ (zaveden˜)
                je      l_2B8C                  ; Jump if equal
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,40h                  ; '@'
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                jne     l_2B94                  ; Jump if not equal
l_2B8C:
                mov     al,1
                mov     d_0759,0            ; 1=disk je zn m˜ (zaveden˜)
                retn
l_2B94:
                mov     d_0759,1            ; 1=disk je zn m˜ (zaveden˜)
                xor     al,al                   ; Zero register
                retn
s_2B77          endp

;==========================================================================
;        test, zda je ji‘ konec disku -> AL
;==========================================================================

s_2B9C          proc    near
                mov     ax,d_02EE               ; (=0FFFFh)
                mov     dx,d_02F2           ; ukazatel absolutn¡ho ‡¡sla sektoru
                sub     ax,dx
                ja      l_2BB4                  ; Jump if above

                jc      l_2BB7                  ; Jump if carry Set
                mov     ax,d_02F0               ; (=0FFFFh)
                mov     dx,d_02F4           ; ukazatel absolutn¡ho ‡¡sla sektoru
                sub     ax,dx
                jbe     l_2BB7                  ; Jump if below or =
l_2BB4:
                mov     al,2Dh                  ; '-'
                retn
l_2BB7:
                call    s_2AB6              ; zji¨tˆn¡ velikosti disku (v sektorech)
                mov     ax,d_02EE               ; (=0FFFFh)
                mov     dx,d_02F2           ; ukazatel absolutn¡ho ‡¡sla sektoru
                sub     ax,dx
                ja      l_2BB4                  ; Jump if above
                jc      l_2BD2                  ; Jump if carry Set
                mov     ax,d_02F0               ; (=0FFFFh)
                mov     dx,d_02F4           ; ukazatel absolutn¡ho ‡¡sla sektoru
                sub     ax,dx
                ja      l_2BB4                  ; Jump if above
l_2BD2:
                clc                             ; Clear carry flag
                mov     al,2Bh                  ; '+'
                retn
s_2B9C          endp

;==========================================================================
;        na‡ten¡ stavu ©adi‡e CD
;==========================================================================

s_2BD6          proc    near

                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,20h              ; funkce dotazu na stav
                out     dx,al                   ; port 300h, POST checkpoint

                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                or      al,al                   ; Zero ?
                jz      l_2BE5                  ; Jump if zero
                retn

; ------ na‡ten¡

l_2BE5:         call    s_2DC7              ; vstup datov‚ho bajtu z ©adi‡e CD
                cmp     al,0FFh
                jne     l_2BED                  ; Jump if not equal
                retn
l_2BED:         mov     d_058E,bl           ; p©ijat˜ ©¡dic¡ a adresovac¡ bajt

; ------ na‡ten¡ aktu ln¡ho ‡¡sla stopy

                call    s_2DC7              ; vstup datov‚ho bajtu z ©adi‡e CD
                cmp     al,0FFh
                jne     l_2BF9                  ; Jump if not equal
                retn
l_2BF9:         mov     d_058F,bl           ; aktu ln¡ ‡¡slo stopy

; ------ na‡ten¡

                call    s_2DC7              ; vstup datov‚ho bajtu z ©adi‡e CD
                cmp     al,0FFh
                jne     l_2C05                  ; Jump if not equal
                retn
l_2C05:         mov     d_0590,bl           ; ukazatel nebo index

; ------ na‡ten¡ aktu ln¡ pozice na stopˆ - minuta

                call    s_2DC7              ; vstup datov‚ho bajtu z ©adi‡e CD
                cmp     al,0FFh
                jne     l_2C11                  ; Jump if not equal
                retn
l_2C11:         mov     d_0591,bl           ; aktu ln¡ pozice na stopˆ - minuta

; ------ na‡ten¡ aktu ln¡ pozice na stopˆ - sekunda

                call    s_2DC7              ; vstup datov‚ho bajtu z ©adi‡e CD
                cmp     al,0FFh
                jne     l_2C1D                  ; Jump if not equal
                retn
l_2C1D:         mov     d_0592,bl           ; aktu ln¡ pozice na stopˆ - sekunda

; ----- na‡ten¡ aktu ln¡ pozice na stopˆ - r me‡ek

                call    s_2DC7              ; vstup datov‚ho bajtu z ©adi‡e CD
                cmp     al,0FFh
                jne     l_2C29                  ; Jump if not equal
                retn
l_2C29:         mov     d_0593,bl           ; aktu ln¡ pozice na stopˆ - r me‡ek

; ------ na‡ten¡

                call    s_2DC7              ; vstup datov‚ho bajtu z ©adi‡e CD
                cmp     al,0FFh
                jne     l_2C35                  ; Jump if not equal
                retn
l_2C35:         mov     d_0594,bl               ; (=0)

; ------ na‡ten¡ aktu ln¡ pozice - minuta

                call    s_2DC7              ; vstup datov‚ho bajtu z ©adi‡e CD
                cmp     al,0FFh
                jne     l_2C41                  ; Jump if not equal
                retn
l_2C41:         mov     d_0595,bl           ; aktu ln¡ pozice hlavy - minuta

; ------ na‡ten¡ aktu ln¡ pozice - sekunda

                call    s_2DC7              ; vstup datov‚ho bajtu z ©adi‡e CD
                cmp     al,0FFh
                jne     l_2C4D                  ; Jump if not equal
                retn
l_2C4D:         mov     d_0596,bl           ; aktu ln¡ pozice hlavy - sekunda

; ----- na‡ten¡ aktu ln¡ pozice - r me‡ek

                call    s_2DC7              ; vstup datov‚ho bajtu z ©adi‡e CD
                cmp     al,0FFh
                jne     l_2C59                  ; Jump if not equal
                retn
l_2C59:         mov     d_0597,bl           ; aktu ln¡ pozice hlavy - r me‡ek
                xor     ax,ax                   ; Zero register
                retn
s_2BD6          endp

;==========================================================================
;        na‡ten¡ parametr– disku (max. a min. stopa)
;==========================================================================

s_2C60          proc    near

                call    s_2B1A              ; p©eru¨en¡ p©enosu DMA
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,10h              ; funkce ‡ten¡ parametr– disku
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                or      al,al                   ; Zero ?
                jz      l_2C72                  ; Jump if zero
                retn

; ------ nejni‘¨¡ stopa disku

l_2C72:         call    s_2DC7              ; vstup datov‚ho bajtu z ©adi‡e CD
                cmp     al,0FFh
                jne     l_2C7A                  ; Jump if not equal
                retn
l_2C7A:         mov     d_0583,bl           ; ‡¡slo nejni‘¨¡ stopy disku

; ------ nejvy¨¨¡ stopa disku

                call    s_2DC7              ; vstup datov‚ho bajtu z ©adi‡e CD
                cmp     al,0FFh
                jne     l_2C86                  ; Jump if not equal
                retn
l_2C86:         mov     d_0584,bl           ; ‡¡slo nejvy¨¨¡ stopy disku

; ------ minuta adresy v˜bˆhov‚ stopa

                call    s_2DC7              ; vstup datov‚ho bajtu z ©adi‡e CD
                cmp     al,0FFh
                jne     l_2C92                  ; Jump if not equal
                retn
l_2C92:         mov     d_0585,bl           ; minuta adresy v˜bˆhov‚ stopy

; ------ sekunda adresy v˜bˆhov‚ stopy

                call    s_2DC7              ; vstup datov‚ho bajtu z ©adi‡e CD
                cmp     al,0FFh
                jne     l_2C9E                  ; Jump if not equal
                retn
l_2C9E:         mov     d_0586,bl           ; sekunda adresy v˜bˆhov‚ stopy

; ------ r me‡ek adresy v˜bˆhov‚ stopy

                call    s_2DC7              ; vstup datov‚ho bajtu z ©adi‡e CD
                cmp     al,0FFh
                jne     l_2CAA                  ; Jump if not equal
                retn
l_2CAA:         mov     d_0587,bl           ; r me‡ek adresy v˜bˆhov‚ stopy

; ------

                call    s_2DC7              ; vstup datov‚ho bajtu z ©adi‡e CD
                cmp     al,0FFh
                jne     l_2CB6                  ; Jump if not equal
                retn
l_2CB6:         mov     d_0588,bl               ; (=0)

; ------

                call    s_2DC7              ; vstup datov‚ho bajtu z ©adi‡e CD
                cmp     al,0FFh
                jne     l_2CC2                  ; Jump if not equal
                retn
l_2CC2:         mov     d_0589,bl               ; (=0)

; ------

                call    s_2DC7              ; vstup datov‚ho bajtu z ©adi‡e CD
                cmp     al,0FFh
                jne     l_2CCE                  ; Jump if not equal
                retn
l_2CCE:         mov     d_058A,bl               ; (=0)
                xor     al,al                   ; Zero register
                retn
s_2C60          endp

;==========================================================================
;        ‡ten¡ aktu ln¡ pozice hlavy
;==========================================================================

s_2CD5          proc    near
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,11h
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                or      al,al                   ; Zero ?
                jz      l_2CE4                  ; Jump if zero
                retn
l_2CE4:
                call    s_2DC7              ; vstup datov‚ho bajtu z ©adi‡e CD
                cmp     al,0FFh
                jne     l_2CEC                  ; Jump if not equal
                retn
l_2CEC:
                mov     d_0782,bl               ; (=0)
                mov     d_0781,0                ; (=0)
                call    s_2DC7              ; vstup datov‚ho bajtu z ©adi‡e CD
                cmp     al,0FFh
                jne     l_2CFD                  ; Jump if not equal
                retn
l_2CFD:
                mov     d_0783,bl           ; po‘adovan  pozice vystaven¡ - minuty
                call    s_2DC7              ; vstup datov‚ho bajtu z ©adi‡e CD
                cmp     al,0FFh
                jne     l_2D09                  ; Jump if not equal
                retn
l_2D09:
                mov     d_0784,bl           ; po‘adovan  pozice vystaven¡ - sekundy
                call    s_2DC7              ; vstup datov‚ho bajtu z ©adi‡e CD
                cmp     al,0FFh
                jne     l_2D15                  ; Jump if not equal
                retn
l_2D15:
                mov     d_0785,bl           ; po‘adovan  pozice vystaven¡ - r me‡ky
                xor     al,al                   ; Zero register
                retn
s_2CD5          endp


;==========================================================================
;                              SUBROUTINE
;==========================================================================

s_2D1C          proc    near
                mov     d_0779,0                ; (=1)
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,0C0h
                cmp     d_0790,1                ; (=0)
                jne     l_2D30                  ; Jump if not equal
                mov     al,0C1h
l_2D30:
                cli                             ; Disable interrupts
                out     dx,al                   ; port 300h, POST checkpoint

                mov     al,d_057C               ; (=0)
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,d_057D               ; (=0)
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,d_057E               ; (=0)
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,d_057F               ; (=0)
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,d_0580               ; (=0)
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,d_0581               ; (=0)
                out     dx,al                   ; port 300h, POST checkpoint
                sti                             ; Enable interrupts
                retn
s_2D1C          endp


;==========================================================================
;        potvrzen¡ p©evzet¡ povelu CD
;==========================================================================

s_2D4C          proc    near
                push    cx
                mov     d_0778,1            ; 1=p©¡znak ‡ek n¡ na p©ipravenost ©adi‡e
                mov     bx,2EE0h
                mov     dx,d_02D6           ; b zov  adresa ©adi‡e CD + 1
l_2D59:
                in      al,dx                   ; port 301h ??i/o non-standard
                test    al,4
                jz      l_2D70                  ; Jump if zero
                mov     cx,1
                call    s_2E56              ; prodleva CX * 0.25 ms
                dec     bx
                jnz     l_2D59                  ; Jump if not zero
                mov     al,0FFh
                pop     cx
                mov     d_0778,0            ; 1=p©¡znak ‡ek n¡ na p©ipravenost ©adi‡e
                retn
l_2D70:
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                in      al,dx                   ; port 300h, POST checkpoint
                mov     d_05AA,al           ; 80h=dv¡©ka otev©ena
                mov     bl,al
                xor     al,al                   ; Zero register
                test    bl,1
                jnz     l_2DC0                  ; Jump if not zero
                test    bl,80h
                jz      l_2D8D                  ; Jump if zero
                and     bl,0BFh
                mov     d_05AA,bl           ; 80h=dv¡©ka otev©ena
l_2D8D:
                test    bl,40h                  ; '@'
                jnz     l_2D96                  ; Jump if not zero
                mov     al,2
                jmp     short l_2DA4
l_2D96:
                xor     al,al                   ; Zero register

                test    bl,20h                  ; ' '
                jz      l_2DC0                  ; Jump if zero
                push    ax
                push    bx
                call    s_30C6
                pop     bx
                pop     ax
l_2DA4:
                mov     d_0772,1                ; (=0)
                mov     d_0757,1                ; (=0)
                mov     d_078A,1                ; (=1)
                call    s_305B
                mov     d_05A6,0                ; (=0)
                mov     d_05A7,0                ; (=0)
l_2DC0:
                pop     cx
                mov     d_0778,0            ; 1=p©¡znak ‡ek n¡ na p©ipravenost ©adi‡e
                retn
s_2D4C          endp


;==========================================================================
;        vstup datov‚ho bajtu z ©adi‡e CD (‡ek  se max. 200 ms)
;==========================================================================

s_2DC7          proc    near
                push    cx
                mov     d_0778,1            ; 1=p©¡znak ‡ek n¡ na p©ipravenost ©adi‡e
                mov     dx,d_02D6           ; b zov  adresa ©adi‡e CD + 1
                mov     bx,320h             ; max. 200 ms
l_2DD4:
                in      al,dx                   ; port 301h ??i/o non-standard
                test    al,4                ; je zanepr zdnˆn (nejsou data) ?
                jz      l_2DEB                  ; Jump if zero
                mov     cx,1
                call    s_2E56              ; prodleva CX * 0.25 ms
                dec     bx
                jnz     l_2DD4                  ; Jump if not zero
                mov     al,0FFh
                pop     cx
                mov     d_0778,0            ; 1=p©¡znak ‡ek n¡ na p©ipravenost ©adi‡e
                retn
l_2DEB:
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD (data)
                in      al,dx                   ; port 300h, POST checkpoint
                mov     bl,al
                xor     al,al                   ; Zero register
                pop     cx
                mov     d_0778,0            ; 1=p©¡znak ‡ek n¡ na p©ipravenost ©adi‡e
                retn
s_2DC7          endp

;==========================================================================
;        p©epo‡et minuty DL, sekundy AH a r me‡ku AL na r me‡ek DX:AX
;==========================================================================

s_2DFB          proc    near
                push    bx
                xor     dh,dh                   ; Zero register
                mov     bx,ax
                mov     al,dl
                mov     cl,3Ch                  ; 60
                mul     cl                      ; ax = reg * al
                add     al,bh
                adc     ah,0
                mov     cx,4Bh              ; 75
                mul     cx                      ; dx:ax = reg * ax
                xor     bh,bh                   ; Zero register
                add     ax,bx
                adc     dx,0
                pop     bx
                retn
s_2DFB          endp

;==========================================================================
;  p©epo‡et r me‡ku DX:AX na minutu (->DX), sekundu (->CH) a r me‡ek (->CL)
;==========================================================================

s_2E19          proc    near
                mov     cx,1194h            ; 4500 = 75*60
                div     cx                      ; ax,dx rem=dx:ax/reg
                xchg    dx,ax
                mov     cl,4Bh                  ; 75
                div     cl                      ; al, ah rem = ax/reg
                xchg    ah,al
                mov     cx,ax
                retn
s_2E19          endp

;==========================================================================
;        p©evod bin rn¡ho ‡¡sla v AL na BCD ‡¡slo
;==========================================================================

s_2E28          proc    near
                push    bx
                push    cx
                aam                             ; Ascii adjust
                push    ax
                db      0C1h,0E8h, 04h, 8Ah,0D8h, 58h
                db       02h,0C3h, 59h, 5Bh,0C3h

; -----------------------------------------------------------------------------
;        p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
; -----------------------------------------------------------------------------

s_2E38:
                push    bx
                push    cx
                xor     ah,ah                   ; Zero register
                mov     bl,10h
                div     bl                      ; al, ah rem = ax/reg
                push    ax
                db      0C0h,0E0h, 04h, 02h,0C4h, 8Ah

                db      0D8h, 58h, 8Ah,0C8h,0B0h, 06h
                db      0F6h,0E1h, 2Ah,0D8h, 8Ah,0C3h
                db       59h, 5Bh,0C3h

;==== External Entry into Subroutine ======================================

; -----------------------------------------------------------------------------
;        prodleva CX * 0.25 ms
; -----------------------------------------------------------------------------

s_2E56:
                push    bx

l_2E57:
                mov     ax,d_0530               ; ‡asov  konstanta LOW
                mov     bx,d_052E               ; ‡asov  konstanta pro 0.25 ms
                mov     ax,ax
l_2E60:
                sub     ax,1
                nop
                sbb     bx,0
                nop
                or      ax,ax                   ; Zero ?
                jnz     l_2E60                  ; Jump if not zero
                or      bx,bx                   ; Zero ?
                jnz     l_2E60                  ; Jump if not zero
                loop    l_2E57                  ; Loop if cx > 0

                pop     bx
                retn
s_2E28          endp

;==========================================================================
;        ukon‡en¡ v¨ech p©enos– s CD
;==========================================================================
;þ
s_2E74          proc    near

                cmp     d_0768,0                ; (=0)
                je      l_2EB6                  ; Jump if equal
                cmp     d_078B,1            ; 1=podporov ny sub-kan ly
                jne     l_2EB6                  ; Jump if not equal
                push    ax
                push    bx
                push    cx
                call    s_2B1A              ; p©eru¨en¡ p©enosu DMA
                mov     d_0768,0                ; (=0)
                mov     cx,3
l_2E90:
                mov     d_078D,0                ; (=0)
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,0DCh
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                je      l_2EA8                  ; Jump if equal
                test    bl,4
                jz      l_2EAD                  ; Jump if zero
l_2EA8:
                dec     cx
                jnz     l_2E90                  ; Jump if not zero

                jmp     short l_2EB3
l_2EAD:
                call    s_2DC7              ; vstup datov‚ho bajtu z ©adi‡e CD
                call    s_2DC7              ; vstup datov‚ho bajtu z ©adi‡e CD
l_2EB3:
                pop     cx
                pop     bx
                pop     ax

l_2EB6:
                retn
s_2E74          endp


;==========================================================================
;        povolen¡ p©eru¨en¡
;==========================================================================

s_2EB7          proc    near
                cmp     d_059E,30h          ; k¢d podle ‡¡sla p©eru¨en¡
                jbe     l_2EC8                  ; Jump if below or =
                in      al,21h                  ; port 21h, 8259-1 int IMR
                and     al,0FBh
                out     21h,al                  ; port 21h, 8259-1 int comands
                mov     al,62h                  ; 'b'
                out     20h,al                  ; port 20h, 8259-1 int command
l_2EC8:
                mov     dx,d_02DE           ; adresa masky ©adi‡e p©eru¨en¡
                in      al,dx                   ; port 21h, 8259-1 int IMR
                and     al,d_078E           ; maska pro uvolnˆn¡ ©adi‡e p©eru¨en¡
                out     dx,al                   ; port 21h, 8259-1 int comands
                mov     al,d_078F           ; povel pro uvolnˆn¡ ©adi‡e p©eru¨en¡
                dec     dx
                out     dx,al                   ; port 20h, 8259-1 int command
                retn
s_2EB7          endp


;==========================================================================
;        vystaven¡ hlav na zadanou pozici
;==========================================================================

s_2ED8          proc    near
                push    bx
                push    es
                mov     dx,d_02DA           ; b zov  adresa ©adi‡e CD + 2
                mov     al,8
                out     dx,al                   ; port 302h ??i/o non-standard

                mov     bl,1                ; funkce uzamknut¡ dv¡©ek
                call    s_3076              ; odemknut¡/uzamknut¡ dv¡©ek
                call    s_286C              ;
                mov     bl,0                ; funkce odemknut¡ dv¡©ek
                call    s_3076              ; odemknut¡/uzamknut¡ dv¡©ek

                cmp     d_0782,0                ; (=0)
                je      l_2F05                  ; Jump if equal

                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,90h
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,20h                  ; ' '
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,3
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD

l_2F05:         cmp     d_0599,0            ; ‡¡slo kan lu ©adi‡e DMA
                jne     l_2F42                  ; Jump if not equal
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,90h
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,2
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,0
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD

                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,90h
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,10h
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,5
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD

                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,90h
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,1
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,8
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,1
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                jmp     l_3048

l_2F42:         test    d_05AA,40h          ; 80h=dv¡©ka otev©ena
                jnz     l_2F4C                  ; Jump if not zero
                jmp     l_3028
l_2F4C:
                cmp     d_0599,5            ; ‡¡slo kan lu ©adi‡e DMA
                jae     l_2F56                  ; Jump if above or =
                jmp     l_3028
l_2F56:
                cmp     d_0781,0                ; (=0)
                je      l_2F6C                  ; Jump if equal

                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,0A0h
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,2
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                jmp     short l_2F79

l_2F6C:         mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,0A0h
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,1
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD

l_2F79:         mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,90h
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,2
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,1
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD

                mov     al,d_0783           ; po‘adovan  pozice vystaven¡ - minuty
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                mov     dl,al
                mov     al,d_0784           ; po‘adovan  pozice vystaven¡ - sekundy
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                mov     ch,al
                mov     al,d_0785           ; po‘adovan  pozice vystaven¡ - r me‡ky
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                mov     ah,ch
                call    s_2DFB              ; p©epo‡et MM:SS:FF na r me‡ek DX:AX
                add     ax,10h              ; korekce + 16 (=pevn‚ z hlav¡ disku)
                adc     dx,0
                call    s_2E19              ; p©epo‡et r me‡ku DX:AX na MM:SS:FF
                mov     al,dl
                call    s_2E28              ; p©evod bin rn¡ho ‡¡sla v AL na BCD ‡¡slo
                mov     bh,al
                mov     al,ch
                call    s_2E28              ; p©evod bin rn¡ho ‡¡sla v AL na BCD ‡¡slo
                mov     bl,al
                mov     al,cl
                call    s_2E28              ; p©evod bin rn¡ho ‡¡sla v AL na BCD ‡¡slo
                mov     cl,al

                push    bx
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,0C0h
                cmp     d_0766,44h          ; rozsah regulace hlasitosti CD (44h)
                jne     l_2FD2                  ; Jump if not equal
                mov     al,0C1h
l_2FD2:         cli                             ; Disable interrupts
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,bh
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,bl
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,cl
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,0
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,0
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,0
                out     dx,al                   ; port 300h, POST checkpoint
                sti                             ; Enable interrupts
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                pop     bx

                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,0C0h
                cmp     d_0766,44h          ; rozsah regulace hlasitosti CD (44h)
                jne     l_2FFA                  ; Jump if not equal
                mov     al,0C1h
l_2FFA:
                cli                             ; Disable interrupts
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,bh
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,bl
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,cl
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,0
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,0
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,1
                out     dx,al                   ; port 300h, POST checkpoint
                sti                             ; Enable interrupts

                mov     bx,8CA0h
l_3012:         mov     dx,d_02D6           ; b zov  adresa ©adi‡e CD + 1
                in      al,dx                   ; port 301h ??i/o non-standard
                test    al,4
                jz      l_3028                  ; Jump if zero
                test    al,2
                jz      l_3028                  ; Jump if zero
                mov     cx,1
                call    s_2E56              ; prodleva CX * 0.25 ms
                dec     bx
                jnz     l_3012                  ; Jump if not zero

l_3028:         mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,90h
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,2
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,1
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD

                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,90h
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,10h
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,6
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD

l_3048:         mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,90h
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,8
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,12h
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD

                pop     es
                pop     bx
                retn
s_2ED8          endp

;==========================================================================
;                              SUBROUTINE
;==========================================================================

s_305B          proc    near
                xor     si,si                   ; Zero register
                mov     cx,0Dh

l_3060:
                mov     d_073C[si],0            ; (=0)
                inc     si
                loop    l_3060                  ; Loop if cx > 0


;==== External Entry into Subroutine ======================================

s_3068:
                xor     si,si                   ; Zero register
                mov     cx,0Dh

l_306D:
                mov     d_0749[si],0            ; (=0)
                inc     si
                loop    l_306D                  ; Loop if cx > 0

                retn
s_305B          endp


;==========================================================================
;        odemknut¡/uzamknut¡ dv¡©ek
;==========================================================================

s_3076          proc    near
                cmp     byte ptr ds:d_0000_0766_e,46h ; (=43h) 'F'; rozsah regulace hlasitosti CD (44h)
                jne     l_30C5                  ; Jump if not equal
                cmp     byte ptr ds:d_0000_0767_e,4 ; (=4Bh)
                jae     l_30C5                  ; Jump if above or =
                cmp     byte ptr ds:d_0000_0765_e,1 ; (=4Fh) ; 1=uzamknut¡ dv¡©ek
                je      l_30C5                  ; Jump if equal
                push    ax
                mov     cl,bl
                cmp     bl,2
                jne     l_3095                  ; Jump if not equal
l_3093:
                mov     bl,0
l_3095:

                mov     dx,ds:d_0000_02D4_e ; b zov  adresa ©adi‡e CD
                mov     al,0FEh
                out     dx,al                   ; port 0, DMA-1 bas&add ch 0
                mov     al,bl
                out     dx,al                   ; port 0, DMA-1 bas&add ch 0
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     cl,2
                jne     l_30C4                  ; Jump if not equal
                mov     dx,ds:d_0000_02D4_e ; b zov  adresa ©adi‡e CD
                mov     al,0FEh
                out     dx,al                   ; port 0, DMA-1 bas&add ch 0
                mov     al,2
                out     dx,al                   ; port 0, DMA-1 bas&add ch 0
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                je      l_3093                  ; Jump if equal
                call    s_2DC7              ; vstup datov‚ho bajtu z ©adi‡e CD
                cmp     al,0FFh
                je      l_3093                  ; Jump if equal
                cmp     bl,0
                jne     l_3093                  ; Jump if not equal
l_30C4:
                pop     ax

l_30C5:
                retn
s_3076          endp


;==========================================================================
;                              SUBROUTINE
;==========================================================================

s_30C6          proc    near
                cmp     d_0766,46h          ; rozsah regulace hlasitosti CD (44h)
                jne     l_30F6                  ; Jump if not equal
                cmp     d_0767,6                ; (=0)
                jae     l_30F6                  ; Jump if above or =

; ----- prodleva 3 sekundy

                mov     cx,2EE0h
                call    s_2E56              ; prodleva CX * 0.25 ms

                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,0F0h
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_3111              ; na‡ten¡ bajtu z ©adi‡e CD
                cmp     al,0FFh
                je      l_30F7                  ; Jump if equal
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,70h              ; povel pro zastaven¡ PAUZA
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_3111              ; na‡ten¡ bajtu z ©adi‡e CD
                cmp     al,0FFh
                je      l_30F7                  ; Jump if equal
l_30F6:         retn

l_30F7:         mov     dx,d_02D8           ; b zov  adresa ©adi‡e CD + 1
                out     dx,al                   ; port 301h ??i/o non-standard
                mov     cx,2
l_30FF:
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,40h                  ; '@'
                out     dx,al                   ; port 300h, POST checkpoint
                call    s_3111              ; na‡ten¡ bajtu z ©adi‡e CD
                cmp     al,0FFh
                jne     l_3110                  ; Jump if not equal
                dec     cx
                jnz     l_30FF                  ; Jump if not zero

l_3110:
                retn
s_30C6          endp

;==========================================================================
;        na‡ten¡ bajtu z ©adi‡e CD
;==========================================================================

s_3111          proc    near
                mov     bx,2EE0h
                mov     dx,d_02D6           ; b zov  adresa ©adi‡e CD + 1
l_3118:
                in      al,dx                   ; port 301h ??i/o non-standard
                test    al,4
                jz      l_3129                  ; Jump if zero
                mov     cx,1
                call    s_2E56              ; prodleva CX * 0.25 ms
                dec     bx
                jnz     l_3118                  ; Jump if not zero
                mov     al,0FFh
                retn
l_3129:
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                in      al,dx                   ; port 300h, POST checkpoint
                mov     bl,al
                xor     al,al                   ; Zero register
                retn
s_3111          endp

; -----------------------------------------------------------------------------
;        funkce VSTUP IOCTL 0Dh: informace o sub-kan lu
; -----------------------------------------------------------------------------
;þ
l_3140:

                                                ;* No entry point to code
                db       2Eh, 8Bh,0C0h, 2Eh, 8Bh,0C0h
                db       2Eh, 8Bh,0C0h, 2Eh, 8Bh,0C0h
                db       90h, 80h, 3Eh, 8Bh, 07h, 01h
                db       74h, 03h,0E9h,0F0h,0D6h,0C6h
                db       06h,0BCh, 3Ah, 00h,0C6h, 06h
                db      0BDh, 3Ah, 00h, 80h, 3Eh, 88h
                db       3Bh, 01h, 75h, 06h, 47h, 47h
                db       47h, 47h,0EBh
                db      36h
l_3161:
                mov     ax,es:[di]          ; po‡ te‡n¡ sektor LOW
                inc     di
                inc     di
                mov     dx,es:[di]          ; po‡ te‡n¡ sektor HIGH
                inc     di
                inc     di
                call    s_2DFB              ; p©epo‡et MM:SS:FF na r me‡ek DX:AX
                mov     d_02F2,dx           ; ukazatel absolutn¡ho ‡¡sla sektoru
                mov     d_02F4,ax           ; ukazatel absolutn¡ho ‡¡sla sektoru
                sub     ax,d_0534           ; sektor absolutnˆ LOW
                sbb     dx,d_0532           ; sektor absolutnˆ HIGH
                jnc     l_3187                  ; Jump if carry=0
                mov     byte ptr d_3ABC,2       ; (=0)
                jmp     l_32A9
l_3187:
                cmp     ax,21h
                jbe     l_3194                  ; Jump if below or =
                mov     byte ptr d_3ABC,2       ; (=0)
                jmp     l_32A9
l_3194:
                mov     d_3B87,al               ; (=0)
l_3197:
                mov     ax,es:[di]          ; p©enosov  adresa - offset
                mov     d_0318,ax           ; p©enosov  adresa - offset
                inc     di
                inc     di
                mov     ax,es:[di]          ; p©enosov  adresa - segment
                mov     d_031A,ax           ; p©enosov  adresa - segment
                inc     di
                inc     di

                mov     al,es:[di]          ; po‡et sektor–
                mov     d_3ABE,al           ; po‡et sektor– k na‡ten¡
                inc     di
                mov     al,es:[di]
                mov     d_3ABF,al               ; (=0)
                inc     di
                mov     al,es:[di]
                mov     d_3AC0,al               ; (=0)
                inc     di

                mov     al,d_3ABE           ; po‡et sektor– k na‡ten¡
                or      al,d_3ABF               ; (=0)
                or      al,d_3AC0               ; (=0)
                or      al,al                   ; Zero ?
                jnz     l_31D8                  ; Jump if not zero
                cmp     d_05A6,1                ; (=0)
                jne     l_31D5                  ; Jump if not equal
                jmp     l_0853
l_31D5:
                jmp     l_084E
l_31D8:
                mov     al,d_3ABE           ; po‡et sektor– k na‡ten¡
                mov     ah,d_3ABF               ; (=0)
                mov     d_02E4,ax           ; po‡et sektor– ke ‡ten¡
                xor     dh,dh                   ; Zero register
                mov     dl,d_3AC0               ; (=0)
                mov     d_0582,dl               ; (=0)
                add     d_3AAA,ax               ; (=0)
                adc     d_3AAC,dx               ; (=0)
                clc                             ; Clear carry flag
                sub     ax,d_0578               ; (=0)
                sbb     dx,d_057A               ; (=0)

                jnc     l_3207                  ; Jump if carry=0
                clc                             ; Clear carry flag
                mov     byte ptr d_3AC1,1       ; (=0)
                jmp     short l_320C
l_3207:
                mov     byte ptr d_3AC1,0       ; (=0)
l_320C:
                mov     d_076B,4                ; (=0)
l_3211:
                mov     dx,0FA0h
l_3214:
                mov     byte ptr d_3B86,0       ; (=0)
                cmp     byte ptr d_3ABD,3       ; (=0)
                jne     l_3223                  ; Jump if not equal
                jmp     l_32A9
l_3223:
                call    s_334C
                cmp     d_0766,4Dh          ; rozsah regulace hlasitosti CD (44h)
                je      l_3244                  ; Jump if equal
                cmp     d_0766,44h          ; rozsah regulace hlasitosti CD (44h)
                jne     l_323B                  ; Jump if not equal
                test    d_0767,10h              ; (=0)
                jnz     l_3244                  ; Jump if not zero
l_323B:
                call    s_3938
                or      al,al                   ; Zero ?
                jnz     l_3248                  ; Jump if not zero
                jmp     short l_325E
l_3244:
                cmp     al,3
                jae     l_325E                  ; Jump if above or =
l_3248:
                mov     cx,1
                call    s_2E56              ; prodleva CX * 0.25 ms
                dec     dx
                jnz     l_3214                  ; Jump if not zero
                dec     d_076B                  ; (=0)
                jnz     l_3211                  ; Jump if not zero
                mov     byte ptr d_3ABC,2       ; (=0)
                jmp     short l_32A9
l_325E:
                cmp     byte ptr d_3B88,1       ; (=0)
                je      l_326C                  ; Jump if equal
                call    s_3900
                or      ax,ax                   ; Zero ?
                jnz     l_3214                  ; Jump if not zero
l_326C:
                call    s_3412
                call    s_34FD
                or      al,al                   ; Zero ?
                jz      l_3282                  ; Jump if zero
                cmp     byte ptr d_3B88,0       ; (=0)
                je      l_3282                  ; Jump if equal
                mov     byte ptr d_3B86,1       ; (=0)
l_3282:
                call    s_336B              ; na‡ten¡ informa‡n¡ho pole sektoru
                cmp     byte ptr d_3B86,1       ; (=0)

                je      l_32A6                  ; Jump if equal
                dec     d_02E4              ; po‡et sektor– ke ‡ten¡
                jz      l_3295                  ; Jump if zero
                jmp     l_3211
l_3295:
                cmp     d_0582,0                ; (=0)
                je      l_32A9                  ; Jump if equal
                dec     d_0582                  ; (=0)
                mov     d_02E4,0FFFFh       ; po‡et sektor– ke ‡ten¡
l_32A6:
                jmp     l_3211
l_32A9:
                cmp     byte ptr d_3B88,1       ; (=0)
                je      l_32B2                  ; Jump if equal
                jmp     short l_330C
l_32B2:
                cmp     byte ptr d_3ABC,2       ; (=0)
                jne     l_32D3                  ; Jump if not equal
                dec     di
                dec     di
                dec     di
                mov     al,d_3ABE           ; po‡et sektor– k na‡ten¡
                mov     ah,d_3ABF               ; (=0)
                mov     dl,d_3AC0               ; (=0)
                sub     ax,d_02E4           ; po‡et sektor– ke ‡ten¡
                sbb     dl,d_0582               ; (=0)
                stosw                           ; Store ax to es:[di]
                mov     al,dl
                stosb                           ; Store al to es:[di]
l_32D3:
                xor     ah,ah                   ; Zero register
                mov     al,22h                  ; 34
                inc     di
                stosw                           ; Store ax to es:[di]
                call    s_334C
                cmp     al,2
                jb      l_32E4                  ; Jump if below
                sub     al,2
                jmp     short l_32E6
l_32E4:
                xor     ax,ax                   ; Zero register
l_32E6:
                stosw                           ; Store ax to es:[di]
                xor     dx,dx                   ; Zero register
                mov     al,d_3AB6           ; sektor - r me‡ek
                mov     ah,d_3AB7           ; sektor - sekunda
                mov     dl,d_3AB8           ; sektor - minuta
                cmp     byte ptr d_3AC2,1       ; (=0)
                je      l_3304                  ; Jump if equal
                call    s_2DFB              ; p©epo‡et MM:SS:FF r me‡ek DX:AX
                sub     ax,150              ; korekce na absolutn¡ sektor
                sbb     dx,0
l_3304:
                stosw                           ; Store ax to es:[di]
                mov     al,dl
                xor     ah,ah                   ; Zero register
                stosw                           ; Store ax to es:[di]

                xor     al,al                   ; Zero register
l_330C:
                cmp     byte ptr d_3ABC,2       ; (=0)
                je      l_331A                  ; Jump if equal
                cmp     byte ptr d_3AC1,1       ; (=0)
                je      l_333E                  ; Jump if equal
l_331A:
                mov     d_0768,0                ; (=0)
                call    s_2B4D              ; test, zda je vlo‘en disk
                cmp     al,0FFh
                jne     l_3329                  ; Jump if not equal
                jmp     l_0873
l_3329:
                cmp     byte ptr d_3ABC,2       ; (=0)
                je      l_3341                  ; Jump if equal
                cmp     al,2
                jne     l_3337                  ; Jump if not equal
                jmp     l_0873
l_3337:
                cmp     al,1
                je      l_333E                  ; Jump if equal
                jmp     l_0878
l_333E:
                jmp     l_087C
l_3341:
                test    bl,2
                jnz     l_3349                  ; Jump if not zero
                jmp     l_086E
l_3349:
                jmp     l_0869

;==========================================================================
;                              SUBROUTINE
;==========================================================================

s_334C          proc    near
                xor     ax,ax                   ; Zero register
                mov     al,d_3ABA           ; ukazatel ‡¡sla © dku v sektoru
                cmp     al,d_3ABB               ; (=0)
                ja      l_3360                  ; Jump if above
                mov     al,d_3ABB               ; (=0)
                sub     al,d_3ABA           ; ukazatel ‡¡sla © dku v sektoru
                jmp     short l_336A
l_3360:
                mov     al,21h                  ; '!'
                sub     al,d_3ABA           ; ukazatel ‡¡sla © dku v sektoru
                add     al,d_3ABB               ; (=0)

l_336A:
                retn
s_334C          endp


;==========================================================================
;        na‡ten¡ informa‡n¡ho pole sektoru
;==========================================================================

s_336B          proc    near

                push    es
                push    ds
                push    di
                push    si
                cmp     byte ptr d_3B86,1       ; (=0)
                jne     l_3378                  ; Jump if not equal
                jmp     short l_33BC
l_3378:
                cmp     byte ptr d_3B88,1       ; (=0)
                jne     l_33BC                  ; Jump if not equal
                cmp     byte ptr d_3ABC,0       ; (=0)
                je      l_3388                  ; Jump if equal
                jmp     short l_33BC
l_3388:
                mov     ax,d_0534           ; sektor absolutnˆ LOW
                mov     dx,d_0532           ; sektor absolutnˆ HIGH
                call    s_2E19              ; p©epo‡et r me‡ku DX:AX na MM:SS:FF
                mov     al,dl               ; minuta
                mov     d_3AB8,al           ; sektor - minuta
                mov     al,ch
                mov     d_3AB7,al           ; sektor - sekunda
                mov     al,cl
                mov     d_3AB6,al           ; sektor - r me‡ek
                mov     byte ptr d_3ABC,1       ; (=0)
                mov     byte ptr d_3ABD,2       ; (=0)
                mov     al,d_3ABE           ; po‡et sektor– k na‡ten¡
                or      al,d_3ABF               ; (=0)
                or      al,d_3AC0               ; (=0)
                or      al,al                   ; Zero ?
                jnz     l_33BC                  ; Jump if not zero
                jmp     short l_340D

l_33BC:         mov     di,d_0318           ; p©enosov  adresa - offset
                mov     ax,d_031A           ; p©enosov  adresa - segment
                mov     es,ax
                cmp     byte ptr d_3B86,1       ; (=0)
                je      l_33E6                  ; Jump if equal
                mov     cx,60h              ; d‚lka sektoru
                mov     si,d_3AA6           ; offset bufferu na‡ten‚ho sektoru
                mov     ds,d_3AA4           ; segment bufferu na‡ten‚ho sektoru
                cld                             ; Clear direction

; ---- p©enos informa‡n¡ho pole sektoru

l_33D8:         movsb                           ; Mov [si] to es:[di]
                or      di,di                   ; Zero ?
                jnz     l_33E4                  ; Jump if not zero
                mov     ax,es
                add     ax,1000h            ; posun adresy segmentu
                mov     es,ax
l_33E4:         loop    l_33D8                  ; Loop if cx > 0

; ----- zv˜¨en¡ ‡¡sla sektoru

l_33E6:         mov     ax,cs
                mov     ds,ax
                inc     d_0534              ; sektor absolutnˆ LOW
                jnz     l_33F4                  ; Jump if not zero
                inc     d_0532              ; sektor absolutnˆ HIGH

; ------ zv˜¨en¡ ‡¡sla © dk– sektoru

l_33F4:         xor     ax,ax                   ; Zero register
                mov     al,d_3ABA           ; ukazatel ‡¡sla © dku v sektoru
                inc     al
                cmp     al,21h                  ; '!'
                jbe     l_3401                  ; Jump if below or =
                xor     ax,ax                   ; Zero register
l_3401:         mov     d_3ABA,al           ; ukazatel ‡¡sla © dku v sektoru

; ------ nov  ukl dac¡ adresa

                mov     d_0318,di           ; p©enosov  adresa - offset
                mov     ax,es
                mov     d_031A,ax           ; p©enosov  adresa - segment
l_340D:
                pop     si
                pop     di
                pop     ds
                pop     es
                retn
s_336B          endp

;==========================================================================
;                              SUBROUTINE
;==========================================================================

s_3412          proc    near
                push    di
                push    si
                push    es
                push    ds
                xor     bx,bx                   ; Zero register
                mov     bl,d_3ABA           ; ukazatel ‡¡sla © dku v sektoru
                shl     bx,1                    ; Shift w/zeros fill
                cmp     d_0766,4Dh          ; rozsah regulace hlasitosti CD (44h)
                je      l_3433                  ; Jump if equal
                cmp     d_0766,44h          ; rozsah regulace hlasitosti CD (44h)
                jne     l_3452                  ; Jump if not equal
                test    d_0767,10h              ; (=0)
                jz      l_3452                  ; Jump if zero
l_3433:
                mov     di,d_3A5C[bx]           ; (=0)
                inc     di
                mov     si,d_3AA6           ; offset bufferu na‡ten‚ho sektoru
                mov     cx,4
                mov     byte ptr d_3AD6,0       ; (=0)

l_3444:
                call    s_346A
                add     di,18h
                inc     d_3AD6                  ; (=0)
                loop    l_3444                  ; Loop if cx > 0

                jmp     short l_3465
l_3452:
                mov     si,d_3A5C[bx]           ; (=0)

                mov     di,d_3AA6           ; offset bufferu na‡ten‚ho sektoru
                mov     ax,cs
                mov     es,ax
                mov     ds,ax
                mov     cx,60h
                rep     movsb                   ; Rep when cx >0 Mov [si] to es:[di]
l_3465:
                pop     ds
                pop     es
                pop     si
                pop     di
                retn
s_3412          endp


;==========================================================================
;                              SUBROUTINE
;==========================================================================

s_346A          proc    near
                push    cx
                push    es
                mov     dh,18h
                xor     cx,cx                   ; Zero register
l_3470:
                mov     bx,offset d_3B56        ; (=0)
                mov     al,cl
                xlat                            ; al=[al+[bx]] table
                call    s_34AA
                mul     dh                      ; ax = reg * al
                add     bp,di
                xor     ah,ah                   ; Zero register
                add     bp,ax
                cmp     bp,d_3AA6           ; offset bufferu na‡ten‚ho sektoru
                jle     l_348B                  ; Jump if < or =
                sub     bp,0D04h
l_348B:
                mov     bx,offset d_3B6E        ; (=0)
                mov     al,cl
                xlat                            ; al=[al+[bx]] table
                xor     ah,ah                   ; Zero register
                add     bp,ax
                mov     es,d_3AA4           ; segment bufferu na‡ten‚ho sektoru
                mov     al,es:[bp]
                mov     es:[si],al
                inc     si
                inc     cx
                cmp     cx,17h
                jbe     l_3470                  ; Jump if below or =
                pop     es
                pop     cx
                retn
s_346A          endp


;==========================================================================
;                              SUBROUTINE

;==========================================================================

s_34AA          proc    near
                xor     bp,bp                   ; Zero register
                cmp     byte ptr d_3AD6,0       ; (=0)
                je      l_34C8                  ; Jump if equal
                cmp     byte ptr d_3AD6,1       ; (=0)
                je      l_34D0                  ; Jump if equal
                cmp     byte ptr d_3AD6,2       ; (=0)
                je      l_34DF                  ; Jump if equal
                cmp     byte ptr d_3AD6,3       ; (=0)
                je      l_34EE                  ; Jump if equal
l_34C8:
                cmp     al,3
                jbe     l_34CF                  ; Jump if below or =
                add     bp,2

l_34CF:
                retn
l_34D0:
                cmp     al,2
                jbe     l_34DE                  ; Jump if below or =
                add     bp,2
                cmp     al,6
                jbe     l_34DE                  ; Jump if below or =
                add     bp,2

l_34DE:
                retn
l_34DF:
                cmp     al,1
                jbe     l_34ED                  ; Jump if below or =
                add     bp,2
                cmp     al,5
                jbe     l_34ED                  ; Jump if below or =
                add     bp,2

l_34ED:
                retn
l_34EE:
                or      al,al                   ; Zero ?
                jz      l_34FC                  ; Jump if zero
                add     bp,2
                cmp     al,4
                jbe     l_34FC                  ; Jump if below or =
                add     bp,2

l_34FC:
                retn
s_34AA          endp


;==========================================================================
;                              SUBROUTINE
;==========================================================================

s_34FD          proc    near

                push    es
                push    di
                push    si
                mov     si,d_3AA6           ; offset bufferu na‡ten‚ho sektoru
                mov     es,d_3AA4           ; segment bufferu na‡ten‚ho sektoru
                cld                             ; Clear direction
                mov     bx,3F3Fh
                mov     cx,30h
                push    si

l_3510:
                mov     ax,es:[si]
                inc     si
                inc     si
                and     ax,bx
                mov     es:[si-2],ax
                loop    l_3510                  ; Loop if cx > 0

                pop     si
                mov     cx,4
                mov     byte ptr d_3AD6,0       ; (=0)
                mov     byte ptr d_3AD2,0       ; (=0)
                mov     byte ptr d_3AD3,0       ; (=0)

l_3530:
                call    s_3563
                or      al,al                   ; Zero ?
                jz      l_353A                  ; Jump if zero
                mov     d_3AD2,al               ; (=0)
l_353A:
                call    s_3639
                or      al,al                   ; Zero ?
                jz      l_3544                  ; Jump if zero
                mov     d_3AD3,al               ; (=0)
l_3544:
                add     si,18h
                inc     d_3AD6                  ; (=0)
                loop    l_3530                  ; Loop if cx > 0

                cmp     byte ptr d_3AD2,0       ; (=0)
                je      l_3556                  ; Jump if equal
                mov     al,1
l_3556:
                cmp     byte ptr d_3AD3,0       ; (=0)
                je      l_355F                  ; Jump if equal
                mov     al,1
l_355F:
                pop     si
                pop     di
                pop     es
                retn
s_34FD          endp


;==========================================================================
;                              SUBROUTINE
;==========================================================================


s_3563          proc    near
                push    cx
                mov     cx,18h
                call    s_37D3              ; kontroln¡ sou‡et dat SI/CX bajt–
                mov     d_3AC3,dl               ; (=0)
                mov     cx,17h
                mov     byte ptr d_3AD5,1       ; (=0)
                call    s_37F2
                mov     d_3AC4,dl               ; (=0)
                mov     cx,17h
                mov     byte ptr d_3AD5,2       ; (=0)
                call    s_37F2
                mov     d_3AC5,dl               ; (=0)
                mov     cx,17h
                mov     byte ptr d_3AD5,3       ; (=0)
                call    s_37F2
                mov     d_3AC6,dl               ; (=0)
                cmp     byte ptr d_3AC3,0       ; (=0)
                jne     l_35BB                  ; Jump if not equal
                cmp     byte ptr d_3AC4,0       ; (=0)
                jne     l_35BB                  ; Jump if not equal
                cmp     byte ptr d_3AC5,0       ; (=0)
                jne     l_35BB                  ; Jump if not equal
                cmp     byte ptr d_3AC6,0       ; (=0)
                jne     l_35BB                  ; Jump if not equal
                xor     al,al                   ; Zero register
                pop     cx
                retn
l_35BB:
                mov     ah,d_3AC3               ; (=0)
                mov     al,d_3AC5               ; (=0)
                call    s_385E
                mov     d_3AC9,al               ; (=0)
                mov     ah,d_3AC4               ; (=0)
                mov     al,d_3AC4               ; (=0)
                call    s_385E
                xor     d_3AC9,al               ; (=0)
                mov     ah,d_3AC4               ; (=0)
                mov     al,d_3AC5               ; (=0)
                call    s_385E
                mov     d_3ACA,al               ; (=0)
                mov     ah,d_3AC3               ; (=0)
                mov     al,d_3AC6               ; (=0)
                call    s_385E
                xor     d_3ACA,al               ; (=0)
                mov     ah,d_3AC4               ; (=0)
                mov     al,d_3AC6               ; (=0)
                call    s_385E
                mov     d_3ACB,al               ; (=0)
                mov     ah,d_3AC5               ; (=0)
                mov     al,d_3AC5               ; (=0)
                call    s_385E
                xor     d_3ACB,al               ; (=0)
                cmp     byte ptr d_3AC9,0       ; (=0)
                jne     l_3630                  ; Jump if not equal
                cmp     byte ptr d_3ACA,0       ; (=0)

                jne     l_3635                  ; Jump if not equal
                cmp     byte ptr d_3ACB,0       ; (=0)
                jne     l_3635                  ; Jump if not equal
                mov     ah,d_3AC4               ; (=0)
                mov     al,d_3AC3               ; (=0)
                mov     bx,17h
                call    s_3674
                pop     cx
                retn
l_3630:
                call    s_369E
                pop     cx
                retn
l_3635:
                mov     al,1
                pop     cx
                retn
s_3563          endp


;==========================================================================
;                              SUBROUTINE
;==========================================================================

s_3639          proc    near
                push    cx
                mov     cx,4
                call    s_37D3              ; kontroln¡ sou‡et dat SI/CX bajt–
                mov     d_3AC7,dl               ; (=0)
                mov     cx,3
                mov     byte ptr d_3AD5,1       ; (=0)
                call    s_37F2
                mov     d_3AC8,dl               ; (=0)
                cmp     byte ptr d_3AC7,0       ; (=0)
                jne     l_3665                  ; Jump if not equal
                cmp     byte ptr d_3AC8,0       ; (=0)
                jne     l_3665                  ; Jump if not equal
                xor     al,al                   ; Zero register
                pop     cx
                retn
l_3665:
                mov     ah,d_3AC8               ; (=0)
                mov     al,d_3AC7               ; (=0)
                mov     bx,3
                call    s_3674
                pop     cx
                retn
s_3639          endp


;==========================================================================
;                              SUBROUTINE
;==========================================================================

s_3674          proc    near
                mov     es,d_3AA4           ; segment bufferu na‡ten‚ho sektoru
                mov     dl,al

                or      al,al                   ; Zero ?
                jz      l_369B                  ; Jump if zero
                call    s_384E
                cmp     al,bl
                ja      l_369B                  ; Jump if above
                sub     bl,al
                mov     ah,bl
                xor     bh,bh                   ; Zero register
                add     bx,si
                mov     al,es:[bx]
                xor     al,dl
                mov     es:[bx],al
                call    s_3880
                xor     al,al                   ; Zero register
                retn
l_369B:
                mov     al,1
                retn
s_3674          endp


;==========================================================================
;                              SUBROUTINE
;==========================================================================

s_369E          proc    near
                mov     byte ptr d_3ACD,0       ; (=0)
                mov     ah,d_3ACA               ; (=0)
                mov     al,d_3AC9               ; (=0)
                call    s_384E
                mov     d_3ACA,al               ; (=0)
                mov     ah,d_3ACB               ; (=0)
                mov     al,d_3AC9               ; (=0)
                call    s_384E
                mov     d_3ACB,al               ; (=0)
                cmp     byte ptr d_3ACB,2Dh     ; (=0) '-'
                ja      l_36CE                  ; Jump if above
                call    s_375A
                cmp     byte ptr d_3ACD,0       ; (=0)
                je      l_36D1                  ; Jump if equal
l_36CE:
                mov     al,1
                retn
l_36D1:
                mov     al,d_3AC4               ; (=0)
                mov     d_3AD0,al               ; (=0)
                mov     al,d_3ACF               ; (=0)
                mov     bx,offset d_3AD7        ; (=1)
                xlat                            ; al=[al+[bx]] table
                mov     ah,d_3AC3               ; (=0)
                call    s_385E
                xor     d_3AD0,al               ; (=0)
                mov     ah,d_3AD0               ; (=0)
                mov     al,d_3ACA               ; (=0)
                xlat                            ; al=[al+[bx]] table
                call    s_384E
                xlat                            ; al=[al+[bx]] table

                mov     d_3AD0,al               ; (=0)
                mov     al,d_3AC4               ; (=0)
                mov     d_3AD1,al               ; (=0)
                mov     al,d_3ACE               ; (=0)
                mov     bx,offset d_3AD7        ; (=1)
                xlat                            ; al=[al+[bx]] table
                mov     ah,d_3AC3               ; (=0)
                call    s_385E
                xor     d_3AD1,al               ; (=0)
                mov     ah,d_3AD1               ; (=0)
                mov     al,d_3ACA               ; (=0)
                xlat                            ; al=[al+[bx]] table
                call    s_384E
                xlat                            ; al=[al+[bx]] table
                mov     d_3AD1,al               ; (=0)
                mov     es,d_3AA4           ; segment bufferu na‡ten‚ho sektoru
                mov     al,d_3ACE               ; (=0)
                mov     ah,17h
                sub     ah,al
                mov     bl,ah
                xor     bh,bh                   ; Zero register
                add     bx,si
                mov     al,es:[bx]
                xor     al,d_3AD0               ; (=0)
                mov     es:[bx],al
                call    s_3880
                mov     al,d_3ACF               ; (=0)
                mov     ah,17h
                sub     ah,al
                mov     bl,ah
                xor     bh,bh                   ; Zero register
                add     bx,si
                mov     al,es:[bx]
                xor     al,d_3AD1               ; (=0)
                mov     es:[bx],al
                call    s_3880
                xor     al,al                   ; Zero register
                retn
s_369E          endp


;==========================================================================
;                              SUBROUTINE
;==========================================================================

s_375A          proc    near
                mov     byte ptr d_3ACC,0       ; (=0)
                mov     byte ptr d_3ACE,0FFh    ; (=0)
                mov     byte ptr d_3ACF,0FFh    ; (=0)
                mov     byte ptr d_3ACD,0       ; (=0)
                mov     cx,17h
                mov     bx,offset d_3AD7        ; (=1)
l_3774:
                mov     al,cl
                add     al,al
                cmp     al,3Fh                  ; '?'
                jb      l_377E                  ; Jump if below

                sub     al,3Fh                  ; '?'
l_377E:
                xlat                            ; al=[al+[bx]] table
                mov     dl,al
                mov     al,cl
                add     al,d_3ACA               ; (=0)
                cmp     al,3Fh                  ; '?'
                jb      l_378D                  ; Jump if below
                sub     al,3Fh                  ; '?'
l_378D:
                xlat                            ; al=[al+[bx]] table
                xor     dl,al
                mov     al,d_3ACB               ; (=0)
                xlat                            ; al=[al+[bx]] table
                xor     dl,al
                jnz     l_37B9                  ; Jump if not zero
                cmp     byte ptr d_3ACC,0       ; (=0)
                jne     l_37AA                  ; Jump if not equal
                mov     d_3ACE,cl               ; (=0)
                mov     byte ptr d_3ACC,1       ; (=0)
                jmp     short l_37B9
l_37AA:
                cmp     byte ptr d_3ACC,1       ; (=0)
                jne     l_37CD                  ; Jump if not equal
                mov     d_3ACF,cl               ; (=0)
                inc     d_3ACC                  ; (=0)
l_37B9:
                dec     cx
                cmp     cx,0
                jge     l_3774                  ; Jump if > or =
                cmp     byte ptr d_3ACE,0       ; (=0)
                jge     l_37D2                  ; Jump if > or =
                cmp     byte ptr d_3ACF,0       ; (=0)
                jge     l_37D2                  ; Jump if > or =
l_37CD:
                mov     byte ptr d_3ACD,1       ; (=0)

l_37D2:
                retn
s_375A          endp


;==========================================================================
;        kontroln¡ sou‡et dat SI/CX bajt–
;==========================================================================

s_37D3          proc    near
                push    si
                mov     es,d_3AA4           ; segment bufferu na‡ten‚ho sektoru
                mov     ax,es:[si]
                inc     si
                inc     si
                xor     ah,al
                mov     dl,ah
                sub     cx,2

l_37E4:         mov     ax,es:[si]
                inc     si
                inc     si
                xor     ah,al
                xor     dl,ah
                dec     cx
                loop    l_37E4                  ; Loop if cx > 0

                pop     si
                retn
s_37D3          endp

;==========================================================================
;                              SUBROUTINE
;==========================================================================

s_37F2          proc    near
                push    si
                mov     es,d_3AA4           ; segment bufferu na‡ten‚ho sektoru
                mov     al,cl
                mul     d_3AD5                  ; (=0) ax = data * al
                mov     d_3AD4,al               ; (=0)
                mov     al,es:[si]
                inc     si
                dec     cx
                and     al,al
                jz      l_381F                  ; Jump if zero
                mov     bx,offset d_3B16        ; (=0)
                xlat                            ; al=[al+[bx]] table
                add     al,d_3AD4               ; (=0)
                mov     bx,offset d_3AD7        ; (=1)
                cmp     al,3Fh                  ; '?'
                jb      l_381A                  ; Jump if below
                sub     al,3Fh                  ; '?'
l_381A:
                xlat                            ; al=[al+[bx]] table
                mov     dl,al
                jmp     short l_3821
l_381F:
                xor     dl,dl                   ; Zero register
l_3821:
                mov     al,cl
                mul     d_3AD5                  ; (=0) ax = data * al
                mov     d_3AD4,al               ; (=0)
                mov     al,es:[si]
                inc     si
                and     al,al
                jz      l_3846                  ; Jump if zero
                mov     bx,offset d_3B16        ; (=0)
                xlat                            ; al=[al+[bx]] table
                add     al,d_3AD4               ; (=0)
                mov     bx,offset d_3AD7        ; (=1)
                cmp     al,3Fh                  ; '?'
                jb      l_3843                  ; Jump if below
                sub     al,3Fh                  ; '?'
l_3843:

                xlat                            ; al=[al+[bx]] table
                xor     dl,al
l_3846:
                dec     cx
                cmp     cx,0
                jge     l_3821                  ; Jump if > or =
                pop     si
                retn
s_37F2          endp


;==========================================================================
;                              SUBROUTINE
;==========================================================================

s_384E          proc    near
                push    bx
                mov     bx,offset d_3B16        ; (=0)
                xlat                            ; al=[al+[bx]] table
                xchg    al,ah
                xlat                            ; al=[al+[bx]] table
                sub     al,ah
                jnc     l_385C                  ; Jump if carry=0
                add     al,3Fh                  ; '?'
l_385C:
                pop     bx
                retn
s_384E          endp


;==========================================================================
;                              SUBROUTINE
;==========================================================================

s_385E          proc    near
                push    bx
                and     al,al
                jz      l_387C                  ; Jump if zero
                and     ah,ah
                jz      l_387C                  ; Jump if zero
                mov     bx,offset d_3B16        ; (=0)
                xlat                            ; al=[al+[bx]] table
                xchg    ah,al
                xlat                            ; al=[al+[bx]] table
                add     al,ah
                mov     bx,offset d_3AD7        ; (=1)
                cmp     al,3Fh                  ; '?'
                jb      l_3879                  ; Jump if below
                sub     al,3Fh                  ; '?'
l_3879:
                xlat                            ; al=[al+[bx]] table
                pop     bx
                retn
l_387C:
                xor     al,al                   ; Zero register
                pop     bx
                retn

s_385E          endp


;==========================================================================
;                              SUBROUTINE
;==========================================================================

s_3880          proc    near
                push    bp
                push    di
                mov     es,d_3AA4           ; segment bufferu na‡ten‚ho sektoru
                xor     bx,bx                   ; Zero register
                mov     bl,d_3ABA           ; ukazatel ‡¡sla © dku v sektoru
                shl     bx,1                    ; Shift w/zeros fill
                mov     di,d_3A5C[bx]           ; (=0)
                cmp     byte ptr d_3AD6,0       ; (=0)
                je      l_38AE                  ; Jump if equal
                cmp     byte ptr d_3AD6,1       ; (=0)
                je      l_38B7                  ; Jump if equal
                cmp     byte ptr d_3AD6,2       ; (=0)
                je      l_38C0                  ; Jump if equal
                cmp     byte ptr d_3AD6,3       ; (=0)
                je      l_38C9                  ; Jump if equal
l_38AE:
                add     di,1
                mov     d_3AA8,di               ; (=0)
                jmp     short l_38D2
l_38B7:
                add     di,19h
                mov     d_3AA8,di               ; (=0)
                jmp     short l_38D2
l_38C0:
                add     di,31h
                mov     d_3AA8,di               ; (=0)
                jmp     short l_38D2
l_38C9:
                add     di,49h
                mov     d_3AA8,di               ; (=0)
                jmp     short l_38D2
l_38D2:
                xchg    ah,al
                push    ax
                mov     bx,offset d_3B56        ; (=0)
                xlat                            ; al=[al+[bx]] table
                call    s_34AA
                mov     ah,18h
                mul     ah                      ; ax = reg * al
                add     bp,ax
                pop     ax
                push    ax
                xor     ah,ah                   ; Zero register
                mov     bx,offset d_3B6E        ; (=0)
                xlat                            ; al=[al+[bx]] table
                add     bp,ax
                add     bp,d_3AA8               ; (=0)
                pop     ax
                mov     al,es:[bp]

                and     al,0C0h
                or      ah,al
                mov     es:[bp],ah
                pop     di
                pop     bp
                retn
s_3880          endp


;==========================================================================
;                              SUBROUTINE
;==========================================================================

s_3900          proc    near
                cmp     byte ptr d_3B87,0       ; (=0)
                jne     l_390A                  ; Jump if not equal
                xor     ax,ax                   ; Zero register
                retn
l_390A:
                inc     d_0534              ; sektor absolutnˆ LOW
                jnz     l_3914                  ; Jump if not zero
                inc     d_0532              ; sektor absolutnˆ HIGH
l_3914:
                xor     ax,ax                   ; Zero register
                mov     al,d_3ABA           ; ukazatel ‡¡sla © dku v sektoru
                inc     al
                cmp     al,21h                  ; '!'
                jbe     l_3921                  ; Jump if below or =
                xor     ax,ax                   ; Zero register
l_3921:
                mov     d_3ABA,al           ; ukazatel ‡¡sla © dku v sektoru
                dec     d_3B87                  ; (=0)
                jnz     l_3934                  ; Jump if not zero
                call    s_334C
                cmp     al,3
                jb      l_3934                  ; Jump if below
                xor     ax,ax                   ; Zero register
                retn
l_3934:
                mov     ax,1
                retn
s_3900          endp


;==========================================================================
;                              SUBROUTINE
;==========================================================================

s_3938          proc    near
                cmp     al,1
                jb      l_393F                  ; Jump if below
                xor     al,al                   ; Zero register
                retn
l_393F:
                push    dx
                push    bx
                mov     dx,d_02D6           ; b zov  adresa ©adi‡e CD + 1

                in      al,dx                   ; port 301h ??i/o non-standard
                test    al,4
                jz      l_394C                  ; Jump if zero
                jmp     short l_3954
l_394C:
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                in      al,dx                   ; port 300h, POST checkpoint
                call    s_3959
l_3954:
                pop     bx
                pop     dx
                mov     al,1
                retn
s_3938          endp


;==========================================================================
;                              SUBROUTINE
;==========================================================================

s_3959          proc    near
l_3959:
                mov     d_078D,0                ; (=0)
                mov     cx,3
l_3961:
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                jne     l_396C                  ; Jump if not equal
                dec     cx
                jnz     l_3961                  ; Jump if not zero
                retn
l_396C:
                cmp     bl,5Ah                  ; 'Z'
                jne     l_3959                  ; Jump if not equal
l_3971:
                call    s_2BD6              ; na‡ten¡ stavu ©adi‡e CD
                xor     dh,dh                   ; Zero register
                mov     al,d_0595           ; aktu ln¡ pozice hlavy - minuta
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                mov     dl,al
                mov     al,d_0596           ; aktu ln¡ pozice hlavy - sekunda
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                mov     bl,al
                mov     al,d_0597           ; aktu ln¡ pozice hlavy - r me‡ek
                call    s_2E38              ; p©evod BCD ‡¡sla AL na bin rn¡ ‡¡slo
                mov     ah,bl
                call    s_2DFB              ; p©epo‡et MM:SS:FF r me‡ek DX:AX
                mov     bx,ax
                mov     cx,dx
                push    bx
                push    cx
                mov     ax,d_0538               ; (=0)
                mov     dx,d_0536               ; (=0)
                sub     ax,bx
                sbb     dl,cl
                mov     d_3AB3,dl               ; (=0)
                mov     d_3AB4,ah               ; (=0)

                mov     d_3AB5,al               ; (=0)
                pop     cx
                pop     bx
                mov     ax,bx
                mov     dx,cx
                mov     d_02F4,ax           ; ukazatel absolutn¡ho ‡¡sla sektoru
                mov     d_02F2,dx           ; ukazatel absolutn¡ho ‡¡sla sektoru
                call    s_2E19              ; p©epo‡et r me‡ku DX:AX na MM:SS:FF
                mov     al,dl
                call    s_2E28              ; p©evod bin rn¡ho ‡¡sla v AL na BCD ‡¡slo
                mov     d_3AB0,al               ; (=0)
                mov     al,ch
                call    s_2E28              ; p©evod bin rn¡ho ‡¡sla v AL na BCD ‡¡slo
                mov     d_3AB1,al               ; (=0)
                mov     al,cl
                call    s_2E28              ; p©evod bin rn¡ho ‡¡sla v AL na BCD ‡¡slo
                mov     d_3AB2,al               ; (=0)
                xor     ax,ax                   ; Zero register
                mov     d_3AAA,ax               ; (=0)
                mov     d_3AAC,ax               ; (=0)
                mov     d_3ABA,al           ; ukazatel ‡¡sla © dku v sektoru
                mov     d_3ABB,al               ; (=0)
                mov     d_078D,al               ; (=0)
                call    s_3A32
                call    s_39F9              ; ‡ten¡ bajtu z ©adi‡e CD
                cmp     al,0FFh
                je      l_39F8                  ; Jump if equal
                test    bl,4
                jz      l_39F8                  ; Jump if zero
                jmp     l_3971

l_39F8:
                retn
s_3959          endp


;==========================================================================
;        ‡ten¡ bajtu z ©adi‡e CD
;==========================================================================

s_39F9          proc    near
                push    cx
                mov     d_0778,1            ; 1=p©¡znak ‡ek n¡ na p©ipravenost ©adi‡e
                mov     bx,2EE0h
                mov     dx,d_02D6           ; b zov  adresa ©adi‡e CD + 1
l_3A06:
                in      al,dx                   ; port 301h ??i/o non-standard
                test    al,4
                jz      l_3A24                  ; Jump if zero
                cmp     d_078D,1                ; (=0)
                je      l_3A1B                  ; Jump if equal
                mov     cx,1
                call    s_2E56              ; prodleva CX * 0.25 ms
                dec     bx
                jnz     l_3A06                  ; Jump if not zero
l_3A1B:
                mov     al,0FFh

                pop     cx
                mov     d_0778,0            ; 1=p©¡znak ‡ek n¡ na p©ipravenost ©adi‡e
                retn
l_3A24:
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                in      al,dx                   ; port 300h, POST checkpoint
                mov     bl,al
                pop     cx
                mov     d_0778,0            ; 1=p©¡znak ‡ek n¡ na p©ipravenost ©adi‡e
                retn
s_39F9          endp


;==========================================================================
;                              SUBROUTINE
;==========================================================================

s_3A32          proc    near
                mov     byte ptr d_3ABC,0       ; (=0)
                mov     byte ptr d_3ABD,0       ; (=0)
                mov     dx,d_02D4           ; b zov  adresa ©adi‡e CD
                mov     al,0B0h
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,d_3AB0               ; (=0)
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,d_3AB1               ; (=0)
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,d_3AB2               ; (=0)
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,d_3AB3               ; (=0)
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,d_3AB4               ; (=0)
                out     dx,al                   ; port 300h, POST checkpoint
                mov     al,d_3AB5               ; (=0)
                out     dx,al                   ; port 300h, POST checkpoint
                retn
s_3A32          endp

d_3A5C          dw      0                       ; Data table (indexed access)
                db      70 dup (0)
d_3AA4          dw      0                   ; segment bufferu na‡ten‚ho sektoru
d_3AA6          dw      0                   ; offset bufferu na‡ten‚ho sektoru
d_3AA8          dw      0
d_3AAA          dw      0
d_3AAC          dw      0
d_3AAE          dw      0
d_3AB0          db      0
d_3AB1          db      0
d_3AB2          db      0
d_3AB3          db      0
d_3AB4          db      0
d_3AB5          db      0
d_3AB6          db      0                   ; sektor - r me‡ek
d_3AB7          db      0                   ; sektor - sekunda
d_3AB8          db      0                   ; sektor - minuta
d_3AB9          db      62h
d_3ABA          db      0                   ; ukazatel ‡¡sla © dku v sektoru

d_3ABB          db      0
d_3ABC          db      0
d_3ABD          db      0
d_3ABE          db      0                   ; po‡et sektor– k na‡ten¡
d_3ABF          db      0
d_3AC0          db      0
d_3AC1          db      0
d_3AC2          db      0
d_3AC3          db      0
d_3AC4          db      0
d_3AC5          db      0
d_3AC6          db      0
d_3AC7          db      0
d_3AC8          db      0
d_3AC9          db      0
d_3ACA          db      0
d_3ACB          db      0
d_3ACC          db      0
d_3ACD          db      0
d_3ACE          db      0
d_3ACF          db      0
d_3AD0          db      0
d_3AD1          db      0
d_3AD2          db      0
d_3AD3          db      0
d_3AD4          db      0
d_3AD5          db      0
d_3AD6          db      0
d_3AD7          db      1
                db       02h, 04h, 08h, 10h, 20h, 03h
                db       06h, 0Ch, 18h, 30h, 23h, 05h
                db       0Ah, 14h, 28h, 13h, 26h, 0Fh
                db       1Eh, 3Ch, 3Bh, 35h, 29h, 11h
                db       22h, 07h, 0Eh, 1Ch, 38h, 33h
                db       25h, 09h, 12h, 24h, 0Bh, 16h
                db       2Ch, 1Bh, 36h, 2Fh, 1Dh, 3Ah
                db       37h, 2Dh, 19h, 32h, 27h, 0Dh
                db       1Ah, 34h, 2Bh, 15h, 2Ah, 17h
                db       2Eh, 1Fh
                db       3Eh, 3Fh, 3Dh, 39h, 31h, 21h
d_3B16          db      0
                db       00h, 01h, 06h, 02h, 0Ch, 07h
                db       1Ah, 03h, 20h, 0Dh, 23h, 08h
                db       30h, 1Bh, 12h, 04h, 18h, 21h
                db       10h, 0Eh, 34h, 24h, 36h, 09h
                db       2Dh, 31h, 26h, 1Ch, 29h, 13h
                db       38h, 05h, 3Eh, 19h, 0Bh, 22h
                db       1Fh, 11h, 2Fh, 0Fh, 17h
                db      '53%,7(', 0Ah, '=.'
                db       1Eh, 32h, 16h, 27h, 2Bh, 1Dh
                db       3Ch, 2Ah, 15h, 14h
                db       3Bh, 39h, 3Ah
d_3B56          db      0
                db      2, 5, 7, 4, 2, 6
                db      7, 0, 1, 2, 3, 4
                db      5, 6, 7, 0, 1, 1

                db      3, 4, 5, 6, 3
d_3B6E          db      0
                db       12h, 05h, 17h, 04h, 02h, 06h
                db       07h, 08h, 09h, 0Ah, 0Bh, 0Ch
                db       0Dh, 0Eh, 0Fh, 10h, 11h, 01h
                db       13h, 14h, 15h, 16h, 03h
d_3B86          db      0
d_3B87          db      0
d_3B88          db      0
                db       2Eh, 8Bh,0C0h, 2Eh, 8Bh,0C0h
                db       90h

; -----------------------------------------------------------------------------
;        start a inicializace ovlada‡e
; -----------------------------------------------------------------------------
;þ
l_3B90:
                call    s_4417              ; detekce typu procesoru
                call    s_4476              ; cejchov n¡ hodin

                les     bx,d_0016               ; (=0) Load 32 bit ptr
                les     si,dword ptr es:[bx+12h] ; Load 32 bit ptr
                mov     ax,0Ah
                mov     di,ax               ; buffer jm‚na za©¡zen¡
l_3BA3:
                inc     si
                mov     al,es:[si]
                cmp     al,0Dh
                jne     l_3BAE                  ; Jump if not equal
                jmp     l_3C39
l_3BAE:
                cmp     al,0Ah
                jne     l_3BB5                  ; Jump if not equal
                jmp     l_3C39
l_3BB5:
                cmp     al,2Fh                  ; '/'
                jne     l_3BA3                  ; Jump if not equal
l_3BB9:
                inc     si
                mov     al,es:[si]
                and     al,0DFh

; ------ "/P:nnn" b zov  adresa ©adi‡e CD

                cmp     al,50h                  ; 'P'
                jne     l_3BC8                  ; Jump if not equal
                call    s_40C9
                jmp     short l_3BB9

; ----- "/D:jm‚no" jm‚no za©¡zen¡

l_3BC8:
                cmp     al,44h                  ; 'D'
                jne     l_3BD1                  ; Jump if not equal
                call    s_4188
                jmp     short l_3BB9

; ----- "/T:n" kan l DMA ("/T:S" = softwarov  obsluha)

l_3BD1:         cmp     al,54h                  ; 'T'
                jne     l_3BDA                  ; Jump if not equal
                call    s_41B1
                jmp     short l_3BB9

; ------ "/I:n" ‡¡slo p©eru¨en¡ (3,5,9,10,11)

l_3BDA:         cmp     al,49h                  ; 'I'
                jne     l_3BE3                  ; Jump if not equal
                call    s_422D
                jmp     short l_3BB9

; ------ "/M:nn" po‡et buffer– 2 KB

l_3BE3:         cmp     al,4Dh                  ; 'M'
                jne     l_3BEC                  ; Jump if not equal
                call    s_42FF
                jmp     short l_3BB9

; ------ "/U:n" uzamknut¡/odemknut¡ dv¡©ek

l_3BEC:         cmp     al,55h                  ; 'U'
                jne     l_3BFA                  ; Jump if not equal
                mov     byte ptr d_43DE,1       ; 1=je parametr "/U:n"
                call    s_437A
                jmp     short l_3BB9

; ------ "/A:n" p©ehr vac¡ m¢d (0=stereo, 1=mono)

l_3BFA:         cmp     al,41h                  ; 'A'
                jne     l_3C03                  ; Jump if not equal
                call    s_43DF
                jmp     short l_3BB9

; ------ "/N" nepodporovat prokl d n¡

l_3C03:         cmp     al,4Eh                  ; 'N'
                jne     l_3C0E                  ; Jump if not equal
                mov     d_0775,1            ; 1=nen¡ podporov no prokl d n¡
                jmp     short l_3BB9

; ------ "/X" pou‘¡t extended pamˆŸ

l_3C0E:         cmp     al,58h                  ; 'X'
                jne     l_3C17                  ; Jump if not equal
                call    s_4598
                jmp     short l_3BB9

; ------ "/S:n" podporov ny subkan ly

l_3C17:         cmp     al,53h                  ; 'S'
                jne     l_3C20                  ; Jump if not equal
                call    s_43FB
                jmp     short l_3BB9

; ------ "/V"

l_3C20:         cmp     al,56h                  ; 'V'
                jne     l_3C2B                  ; Jump if not equal
                mov     byte ptr d_474D,1       ; parametr "/V"
                jmp     short l_3BB9

l_3C2B:         cmp     al,0Dh
                je      l_3C39                  ; Jump if equal
                cmp     al,0Ah
                je      l_3C39                  ; Jump if equal
                cmp     al,5Eh                  ; '^'
                je      l_3C39                  ; Jump if equal
                jmp     short l_3BB9

l_3C39:         mov     d_0772,1                ; (=0)
                mov     d_078A,1                ; (=1)
                mov     ax,3B90h
                cmp     d_078B,1            ; 1=podporov ny sub-kan ly
                je      $+0Ch                   ; Jump if equal
                mov     ax,3140h
                mov     bx,83Ah
                mov     d_00CA,bx               ; (=3140h)
                db      0C1h,0E8h, 04h, 8Ch,0CBh, 03h
                db      0C3h,0A3h, 66h, 05h, 81h, 3Eh
                db       66h, 05h, 00h,0A0h, 72h, 60h

; ------ nalezen¡ instalace ovlada‡e v pamˆti

                db      0C6h, 06h, 88h, 07h, 01h,0FCh
                db       1Eh, 56h, 06h, 57h, 8Ch,0CBh
l_3C75:
                cmp     bx,0A000h

                ja      l_3C82                  ; Jump if above
                mov     d_0788,0                ; (=0)
                jmp     short l_3CB0
l_3C82:
                dec     bx
                mov     ds,bx
                xor     si,si                   ; Zero register
                lodsb                           ; String [si] to al
                cmp     al,5Ah                  ; 'Z'
                je      l_3C90                  ; Jump if equal
                cmp     al,4Dh                  ; 'M'
                jne     l_3C75                  ; Jump if not equal
l_3C90:
                inc     si
                inc     si
                lodsw                           ; String [si] to ax
                push    bx
                inc     bx
                add     bx,ax
                mov     cs:d_4756,bx            ; (=0)
                pop     bx
                inc     si
                inc     si
                inc     si
                mov     ax,cs
                mov     es,ax
                mov     di,offset d_4758        ; (='UMB')
                mov     cx,3
                repe    cmpsb                   ; Rep zf=1+cx >0 Cmp [si] to es:[di]
                or      cx,cx                   ; Zero ?
                jnz     l_3C75                  ; Jump if not zero
l_3CB0:
                pop     di
                pop     es
                pop     si
                pop     ds
                cmp     byte ptr ds:d_0000_0788_e,0 ; (=31h)
                je      l_3CC9                  ; Jump if equal
                mov     ax,ds:d_0000_4756_e     ; (=0FFCDh)
                cmp     ax,ds:d_0000_0566_e     ; (=2056h)
                ja      l_3CC9                  ; Jump if above
                mov     byte ptr ds:d_0000_0788_e,0 ; (=31h)
l_3CC9:
                mov     dx,d_0000_475B_e    ; text "CD-ROM device driver MTMCDAE Version 01.13"
                call    s_458E              ; zobrazen¡ textu DS:DX
                mov     dx,d_0000_478A_e    ;
                call    s_458E              ; zobrazen¡ textu DS:DX
                mov     al,ds:d_0000_059F_e ; po‡et buffer– 2 KB
                cmp     al,40h                  ; '@'
                jbe     l_3CF2                  ; Jump if below or =
                mov     ah,2
                mov     ds:d_0000_4754_e,ah     ; (=25h)
                mov     ah,0
                mov     ds:d_0000_4755_e,ah     ; (=0)
                mov     al,2
                xor     ah,ah                   ; Zero register
                mov     ds:d_0000_059F_e,al ; po‡et buffer– 2 KB

                mov     ds:d_0000_02F6_e,ax ; po‡et buffer– 2 KB
l_3CF2:
                cmp     byte ptr ds:d_0000_077A_e,1 ; (=0); p©¡znak extended pamˆti
                je      l_3D0F                  ; Jump if equal
                cmp     byte ptr ds:d_0000_077A_e,2 ; (=0) ; p©¡znak extended pamˆti
                jne     l_3D0C                  ; Jump if not equal
                mov     dx,d_0000_48CC_e    ;
                call    s_458E              ; zobrazen¡ textu DS:DX
                mov     dx,d_0000_491B_e        ; (=0FDh)
                call    s_458E              ; zobrazen¡ textu DS:DX
l_3D0C:
                jmp     l_3E03
l_3D0F:
                mov     ax,ds:d_0000_474E_e     ; (=1773h)
                shr     ax,1                    ; Shift w/zeros fill
                mov     dx,ds:d_0000_02F6_e ; po‡et buffer– 2 KB
                cmp     dx,2
                ja      l_3D1E                  ; Jump if above
                inc     dx
l_3D1E:
                cmp     ax,dx
                jae     l_3D30                  ; Jump if above or =
                mov     ds:d_0000_059F_e,al ; po‡et buffer– 2 KB
                xor     ah,ah                   ; Zero register
                mov     ds:d_0000_02F6_e,ax ; po‡et buffer– 2 KB
                mov     dx,d_0000_494E_e        ; (=0)
                call    s_458E              ; zobrazen¡ textu DS:DX
l_3D30:
                mov     ax,ds:d_0000_02F6_e ; po‡et buffer– 2 KB
                aam                             ; Ascii adjust
                or      al,al                   ; Zero ?
                jnz     l_3D3B                  ; Jump if not zero
                mov     al,30h                  ; '0'
l_3D3B:
                or      ah,ah                   ; Zero ?
                jz      l_3D41                  ; Jump if zero
                xchg    al,ah
l_3D41:
                mov     ds:d_0000_4754_e,al     ; (=25h)
                mov     ds:d_0000_4755_e,ah     ; (=0)
                mov     ah,9
                xor     dx,dx                   ; Zero register
                mov     dl,ds:d_0000_059F_e ; po‡et buffer– 2 KB
                cmp     dl,2
                ja      l_3D57                  ; Jump if above
                inc     dl
l_3D57:
                shl     dl,1                    ; Shift w/zeros fill
                call    dword ptr ds:d_0000_053A_e ; (=0Ch); adresa ovlada‡e extended pamˆti
                or      ax,ax                   ; Zero ?
                jnz     l_3D75                  ; Jump if not zero
                mov     byte ptr ds:d_0000_077A_e,0 ; (=0) ; p©¡znak extended pamˆti
                mov     dx,d_0000_48F5_e        ; (=0BDh)
                call    s_458E              ; zobrazen¡ textu DS:DX
                mov     dx,d_0000_491B_e        ; (=0FDh)
                call    s_458E              ; zobrazen¡ textu DS:DX
                jmp     l_3E03

; ----- p©¡prava tabulky adres sektor– 2 KB

l_3D75:
                mov     ds:d_0000_053E_e,dx     ; (=0)
                xor     di,di                   ; Zero register
                mov     word ptr ds:d_0000_04A4_e[di],0 ; (=0) ; tabulka ‡¡sel blok– 64 KB buffer– sektor–
                mov     word ptr ds:d_0000_0424_e[di],0 ; (=1970h) ; tabulka adres buffer– sektor–
                xor     bx,bx                   ; Zero register
                xor     dx,dx                   ; Zero register
                mov     cl,ds:d_0000_059F_e ; po‡et buffer– 2 KB
                mov     ds:d_0000_05A1_e,cl     ; (=44h)
                dec     cl

l_3D95:
                inc     di
                inc     di
                add     bx,800h             ; zv˜¨en¡ adresy sektoru
                jnc     l_3D9E                  ; Jump if carry=0
                inc     dx
l_3D9E:
                mov     ds:d_0000_04A4_e[di],dx ; (=0) ; tabulka ‡¡sel blok– 64 KB buffer– sektor–
                mov     ds:d_0000_0424_e[di],bx ; (=1970h) ; tabulka adres buffer– sektor–
                loop    l_3D95                  ; Loop if cx > 0

                mov     ax,800h
                xor     bh,bh                   ; Zero register
                mov     bl,ds:d_0000_05A1_e     ; (=44h)
                mul     bx                      ; dx:ax = reg * ax
                mov     bx,930h
                div     bx                      ; ax,dx rem=dx:ax/reg
                cmp     al,1
                jne     l_3DBE                  ; Jump if not equal
                inc     al
l_3DBE:
                mov     ds:d_0000_05A2_e,al     ; (=53h)
                xor     ax,ax                   ; Zero register
                mov     al,ds:d_0000_059F_e ; po‡et buffer– 2 KB
                mov     ds:d_0000_02F6_e,ax ; po‡et buffer– 2 KB
                mov     byte ptr ds:d_0000_059F_e,1 ; (=0); po‡et buffer– 2 KB
                mov     byte ptr ds:d_0000_05A0_e,1 ; (=33h)
                xor     cx,cx                   ; Zero register
                mov     cl,1
                mov     ax,ds:d_0000_0566_e     ; (=2056h)
                xor     bx,bx                   ; Zero register
                mov     word ptr ds:d_0000_0322_e,930h ; (=0)
                xor     bp,bp                   ; Zero register
                call    s_45D0
                mov     word ptr ds:d_0000_0322_e,800h ; (=0)
                mov     dx,ds:d_0000_0566_e     ; (=2056h)
                mov     ax,0B30h
                cmp     byte ptr ds:d_0000_078B_e,0 ; (=20h) ; 1=podporov ny sub-kan ly
                je      l_3DFE                  ; Jump if equal
                add     ax,236h
l_3DFE:
                mov     ds:d_0000_0568_e,ax     ; (=2020h)
                jmp     short l_3E4E
l_3E03:
                xor     cx,cx                   ; Zero register
                mov     cl,ds:d_0000_059F_e ; po‡et buffer– 2 KB

                call    s_45D0
                or      al,al                   ; Zero ?
                jnz     l_3E5B                  ; Jump if not zero
                cmp     byte ptr ds:d_0000_0599_e,0 ; (=1Eh) ; ‡¡slo kan lu ©adi‡e DMA
                je      l_3E26                  ; Jump if equal
                call    s_46BB
                cmp     cl,2
                jae     l_3E44                  ; Jump if above or =
                mov     ds:d_0000_0568_e,ax     ; (=2020h)
                mov     cl,2
                jmp     short l_3E44
l_3E26:
                xor     bx,bx                   ; Zero register
                mov     ax,ds:d_0000_0568_e     ; (=2020h)
                sub     ax,ds:d_0000_0566_e     ; (=2056h)
                mov     bl,93h
                div     bl                      ; al, ah rem = ax/reg
                mov     cl,al
                cmp     al,2
                jae     l_3E44                  ; Jump if above or =
                mov     ax,ds:d_0000_0566_e     ; (=2056h)
                add     ax,126h
                mov     ds:d_0000_0568_e,ax     ; (=2020h)
                mov     cl,2
l_3E44:
                mov     ds:d_0000_05A0_e,cl     ; (=33h)
                xor     ax,ax                   ; Zero register
                mov     dx,ds:d_0000_0568_e     ; (=2020h)
l_3E4E:
                cmp     byte ptr ds:d_0000_0788_e,0 ; (=31h)
                je      l_3EC5                  ; Jump if equal
                cmp     ds:d_0000_4756_e,dx     ; (=0FFCDh)
                ja      l_3EC5                  ; Jump if above
l_3E5B:
                cmp     byte ptr ds:d_0000_077A_e,1 ; (=0) ; p©¡znak extended pamˆti
                je      l_3EB6                  ; Jump if equal
                cmp     byte ptr ds:d_0000_059F_e,2 ; (=0); po‡et buffer– 2 KB
                je      l_3EB6                  ; Jump if equal
                mov     ax,ds:d_0000_4756_e     ; (=0FFCDh)
                sub     ax,ds:d_0000_0566_e     ; (=2056h)
                jbe     l_3EB6                  ; Jump if below or =
                mov     bl,80h
                div     bl                      ; al, ah rem = ax/reg
                dec     al
                xor     ah,ah                   ; Zero register
                mov     ds:d_0000_059F_e,al ; po‡et buffer– 2 KB
                mov     ds:d_0000_02F6_e,ax ; po‡et buffer– 2 KB
                aam                             ; Ascii adjust
                or      al,al                   ; Zero ?
                jnz     l_3E88                  ; Jump if not zero
                mov     al,30h                  ; '0'
l_3E88:
                or      ah,ah                   ; Zero ?
                jz      l_3E8E                  ; Jump if zero
                xchg    al,ah
l_3E8E:
                mov     ds:d_0000_4754_e,al     ; (=25h)

                mov     ds:d_0000_4755_e,ah     ; (=0)
                mov     al,ds:d_0000_059F_e ; po‡et buffer– 2 KB
                mov     bx,80h
                mul     bl                      ; ax = reg * al
                add     ax,ds:d_0000_0566_e     ; (=2056h)
                push    ax
                mov     dx,d_0000_4982_e        ; (=20h)
                call    s_458E              ; zobrazen¡ textu DS:DX
                mov     dx,d_0000_499A_e        ; (=0)
                call    s_458E              ; zobrazen¡ textu DS:DX
                pop     ax
                mov     dx,ax
                xor     ax,ax                   ; Zero register
                jmp     l_3E03
l_3EB6:
                mov     dx,d_0000_4982_e        ; (=20h)
                call    s_458E              ; zobrazen¡ textu DS:DX
                mov     dx,d_0000_48B3_e        ; (=32h)
                call    s_458E              ; zobrazen¡ textu DS:DX
                jmp     l_40A6
l_3EC5:
                les     bx,dword ptr ds:d_0000_0016_e ; (=0F000h) Load 32 bit ptr
                mov     es:[bx+0Eh],ax
                mov     es:[bx+10h],dx
                mov     byte ptr es:[bx+1],0
                mov     ax,ds:d_0000_02F6_e ; po‡et buffer– 2 KB
                dec     ax
                mov     ds:d_0000_031E_e,ax     ; (=0)
                mov     dx,d_0000_47B1_e        ; (=0Ch)
                call    s_458E              ; zobrazen¡ textu DS:DX
                mov     al,ds:d_0000_4754_e     ; (=25h)
                or      al,al                   ; Zero ?
                jz      l_3F05                  ; Jump if zero
                add     al,30h                  ; '0'
                mov     dl,al
                call    s_4593              ; zobrazen¡ znaku DL
                mov     al,ds:d_0000_4755_e     ; (=0)
                or      al,al                   ; Zero ?
                jz      l_3F0A                  ; Jump if zero
                cmp     al,30h                  ; '0'
                je      l_3EFE                  ; Jump if equal
                add     al,30h                  ; '0'
l_3EFE:
                mov     dl,al
                call    s_4593              ; zobrazen¡ znaku DL
                jmp     short l_3F0A
l_3F05:
                mov     dl,32h                  ; '2'
                call    s_4593              ; zobrazen¡ znaku DL
l_3F0A:
                cmp     byte ptr ds:d_0000_077A_e,1 ; (=0) ; p©¡znak extended pamˆti
                jne     l_3F17                  ; Jump if not equal
                mov     dx,d_0000_4947_e        ; (=45h)
                call    s_458E              ; zobrazen¡ textu DS:DX
l_3F17:
                mov     dx,d_0000_47D3_e        ; (=0C3h)
                call    s_458E              ; zobrazen¡ textu DS:DX

                cmp     byte ptr ds:d_0000_0599_e,0 ; (=1Eh) ; ‡¡slo kan lu ©adi‡e DMA
                jne     l_3F2C                  ; Jump if not equal
                mov     dx,d_0000_47F2_e        ; (=0C5h)
                call    s_458E              ; zobrazen¡ textu DS:DX
                jmp     short l_3F36
l_3F2C:
                mov     al,ds:d_0000_0599_e ; ‡¡slo kan lu ©adi‡e DMA
                add     al,30h                  ; '0'
                mov     dl,al
                call    s_4593              ; zobrazen¡ znaku DL
l_3F36:
                mov     dx,d_0000_480D_e        ; (=74h)
                call    s_458E              ; zobrazen¡ textu DS:DX
                mov     al,ds:d_0000_4753_e ; ‡¡slo p©eru¨en¡ IRQ
                cmp     al,0Ah
                jae     l_3F4C                  ; Jump if above or =
                add     al,30h                  ; '0'
                mov     dl,al
                call    s_4593              ; zobrazen¡ znaku DL
                jmp     short l_3F5B
l_3F4C:
                mov     bl,al
                mov     dl,31h                  ; '1'
                call    s_4593              ; zobrazen¡ znaku DL
                add     bl,26h                  ; '&'
                mov     dl,bl
                call    s_4593              ; zobrazen¡ znaku DL
l_3F5B:
                mov     dx,d_0000_4889_e        ; (=0E3h)
                call    s_458E              ; zobrazen¡ textu DS:DX
                cmp     byte ptr ds:d_0000_0771_e,0 ; (=0F5h); 1=p©¡znak MONO m¢du
                je      l_3F74                  ; Jump if equal
                mov     dx,d_0000_486E_e        ; (=0ACh)
                call    s_458E              ; zobrazen¡ textu DS:DX
                mov     dx,d_0000_4889_e        ; (=0E3h)
                call    s_458E              ; zobrazen¡ textu DS:DX
l_3F74:
                cmp     byte ptr ds:d_0000_078B_e,0 ; (=20h) ; 1=podporov ny sub-kan ly
                je      l_3FAB                  ; Jump if equal
                xor     di,di                   ; Zero register
                mov     ds:d_0000_3AA4_e,cs ; segment bufferu na‡ten‚ho sektoru
                mov     bx,3B90h
                mov     ds:d_0000_3A5C_e[di],bx ; (=0)
                xor     ah,ah                   ; Zero register
                mov     cx,21h

l_3F8D:
                inc     di
                inc     di
                add     bx,62h
                mov     ds:d_0000_3A5C_e[di],bx ; (=0)
                loop    l_3F8D                  ; Loop if cx > 0

                add     bx,62h
                mov     ds:d_0000_3AA6_e,bx ; offset bufferu na‡ten‚ho sektoru
                mov     dx,d_0000_49B7_e        ; (=44h)
                call    s_458E              ; zobrazen¡ textu DS:DX

                mov     dx,d_0000_4889_e        ; (=0E3h)
                call    s_458E              ; zobrazen¡ textu DS:DX
l_3FAB:

; ----- reset disku

                mov     dx,ds:d_0000_02D4_e ; b zov  adresa ©adi‡e CD
                mov     al,60h                  ; '`'
                out     dx,al                   ; port 0, DMA-1 bas&add ch 0
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                je      l_3FBE                  ; Jump if equal
                test    bl,0C0h
                jnz     l_3FDB                  ; Jump if not zero
l_3FBE:
                mov     dx,ds:d_0000_02D8_e ; b zov  adresa ©adi‡e CD + 1
                xor     al,al                   ; Zero register
                out     dx,al                   ; port 0, DMA-1 bas&add ch 0
                mov     cx,4

l_3FC8:
                mov     dx,ds:d_0000_02D4_e ; b zov  adresa ©adi‡e CD
                mov     al,40h                  ; '@'
                out     dx,al                   ; port 0, DMA-1 bas&add ch 0
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                jne     l_3FDB                  ; Jump if not equal
                loop    l_3FC8                  ; Loop if cx > 0

                jmp     l_4089
l_3FDB:
                call    s_4535              ; detekce regulace hlasitosti audiokan lu
                or      al,al                   ; Zero ?
                jz      l_3FE5                  ; Jump if zero
                jmp     l_4089
l_3FE5:
                cmp     byte ptr ds:d_0000_0599_e,0 ; (=1Eh) ; ‡¡slo kan lu ©adi‡e DMA
                jne     l_3FF2                  ; Jump if not equal
                call    s_2ED8              ; vystaven¡ hlav na zadanou pozici
                call    s_1DF3
l_3FF2:
                mov     dx,ds:d_0000_02DC_e ; b zov  adresa ©adi‡e CD + 3
                mov     al,ds:d_0000_059C_e     ; (=0)
                out     dx,al                   ; port 0, DMA-1 bas&add ch 0
                test    byte ptr ds:d_0000_05AA_e,40h ; (=20h) '@' ; 80h=dv¡©ka otev©ena
                jz      l_4011                  ; Jump if zero
                call    s_2AB6              ; zji¨tˆn¡ velikosti disku (v sektorech)
                cmp     byte ptr ds:d_0000_0772_e,0 ; (=6)
                je      l_4011                  ; Jump if equal
                call    s_2ED8              ; vystaven¡ hlav na zadanou pozici
                call    s_1DF3
l_4011:
                call    s_4396              ; odemknut¡/uzamknut¡ dv¡©ek
                cmp     al,0FFh
                je      l_4089                  ; Jump if equal
                call    s_470A
                mov     dx,d_0000_4889_e        ; (=0E3h)
                call    s_458E              ; zobrazen¡ textu DS:DX
;*              mov     dx,offset l_0000_24BC   ; obsluha p©eru¨en¡
                db      0BAh,0BCh, 24h

; ------ instalace obsluhy p©eru¨en¡

                mov     ah,25h                  ; '%'
                mov     al,ds:d_0000_059E_e ; k¢d podle ‡¡sla p©eru¨en¡
                cmp     al,10h
                je      l_4047                  ; Jump if equal
                cmp     al,30h                  ; '0'
                je      l_404D                  ; Jump if equal
                cmp     al,40h                  ; '@'
                je      l_4053                  ; Jump if equal
                cmp     al,50h                  ; 'P'
                je      l_405F                  ; Jump if equal
                cmp     al,60h                  ; '`'
                je      l_406B                  ; Jump if equal
                cmp     al,70h                  ; 'p'
                je      l_4077                  ; Jump if equal
                mov     al,0Bh
                int     21h                     ; DOS Services  ah=function 25h
                                                ;  set intrpt vector al to ds:dx
                jmp     short l_4083
l_4047:
                mov     al,0Ah
                int     21h                     ; DOS Services  ah=function 25h
                                                ;  set intrpt vector al to ds:dx
                jmp     short l_4083
l_404D:
                mov     al,0Dh
                int     21h                     ; DOS Services  ah=function 25h
                                                ;  set intrpt vector al to ds:dx
                jmp     short l_4083
l_4053:
                mov     word ptr ds:d_0000_02DE_e,0A1h ; adresa masky ©adi‡e p©eru¨en¡
                mov     al,72h                  ; 'r'
                int     21h                     ; DOS Services  ah=function 25h
                                                ;  set intrpt vector al to ds:dx
                jmp     short l_4083
l_405F:
                mov     word ptr ds:d_0000_02DE_e,0A1h ; adresa masky ©adi‡e p©eru¨en¡
                mov     al,73h                  ; 's'
                int     21h                     ; DOS Services  ah=function 25h
                                                ;  set intrpt vector al to ds:dx
                jmp     short l_4083
l_406B:
                mov     word ptr ds:d_0000_02DE_e,0A1h ; adresa masky ©adi‡e p©eru¨en¡
                mov     al,74h                  ; 't'
                int     21h                     ; DOS Services  ah=function 25h
                                                ;  set intrpt vector al to ds:dx
                jmp     short l_4083
l_4077:
                mov     word ptr ds:d_0000_02DE_e,0A1h ; adresa masky ©adi‡e p©eru¨en¡
                mov     al,77h                  ; 'w'
                int     21h                     ; DOS Services  ah=function 25h
                                                ;  set intrpt vector al to ds:dx
                jmp     short l_4083
l_4083:
                call    s_2EB7              ; povolen¡ p©eru¨en¡
                jmp     l_0878
l_4089:
                mov     dx,d_0000_488D_e        ; (=0DFh)

                call    s_458E              ; zobrazen¡ textu DS:DX
                mov     dx,d_0000_48B3_e        ; (=32h)
                call    s_458E              ; zobrazen¡ textu DS:DX
                cmp     byte ptr ds:d_0000_077A_e,1 ; (=0) ; p©¡znak extended pamˆti
                jne     l_40A6                  ; Jump if not equal
                mov     dx,ds:d_0000_053E_e     ; (=0)
                mov     ah,0Ah
                call    dword ptr ds:d_0000_053A_e ; (=0Ch); adresa ovlada‡e extended pamˆti
l_40A6:
                mov     word ptr ds:d_0000_0004_e,7FFFh ; (=6F4h)
                les     bx,dword ptr ds:d_0000_0016_e ; (=0F000h) Load 32 bit ptr
                xor     ax,ax                   ; Zero register
                mov     es:[bx+0Eh],ax
                mov     ax,cs
                mov     es:[bx+10h],ax
                mov     byte ptr es:[bx+1],0
                mov     byte ptr es:[bx+0Dh],0
                jmp     l_0878

;==========================================================================
;        parametr "P:n" - b zov  adresa ©adi‡e
;==========================================================================

s_40C9          proc    near
                inc     si
                mov     al,es:[si]
                cmp     al,3Ah                  ; ':'
                jne     l_40DD                  ; Jump if not equal
                inc     si
                mov     al,es:[si]
                cmp     al,33h                  ; '3'
                ja      l_40DD                  ; Jump if above
                cmp     al,31h                  ; '1'
                jae     $+3                     ; Jump if above or =

l_40DD:
                retn
s_40C9          endp

                                                ;* No entry point to code
                and     al,0Fh
                mov     d_4752,al               ; (=0)
                inc     si
                mov     al,es:[si]
                mov     byte ptr ds:[4750h],al  ; (8535:4750=0)
                inc     si
                mov     al,es:[si]
                mov     byte ptr ds:[4751h],al  ; (8535:4751=0)
                mov     al,byte ptr ds:[4750h]  ; (8535:4750=0)
                db      0C0h,0E8h, 04h, 3Ch, 03h, 74h
                db       0Bh, 3Ch, 04h, 74h, 14h, 3Ch
                db       06h, 74h, 10h,0E9h, 81h, 00h
                db       33h,0C0h,0A0h, 50h, 47h,0C0h
                db      0E0h, 04h,0A2h, 50h, 47h,0EBh
                db       0Dh, 33h,0C0h,0A0h, 50h, 47h
                db      0C0h,0E0h, 04h, 04h, 90h,0A2h
                db       50h, 47h,0A0h, 51h, 47h,0C0h

                db      0E8h, 04h, 3Ch, 03h, 74h, 0Ah
                db       3Ch, 04h, 74h, 12h, 3Ch, 06h
                db       74h, 0Eh,0EBh, 53h, 33h,0C0h
                db      0A0h, 51h, 47h, 24h, 0Fh,0A2h
                db       51h, 47h,0EBh, 0Ch, 33h,0C0h
                db      0A0h, 51h, 47h, 24h, 0Fh, 04h
                db       09h,0A2h, 51h, 47h, 33h,0C0h
                db       33h,0DBh,0A0h, 50h, 47h, 8Ah
                db       1Eh, 51h, 47h, 8Ah, 3Eh, 52h
                db       47h, 03h,0C3h, 80h,0FCh, 01h
                db       75h, 07h, 3Dh,0F0h, 01h, 73h
                db       20h,0EBh
                db      0Ch
l_4169:
                cmp     ah,2
                jne     l_4170                  ; Jump if not equal
                jmp     short l_4175
l_4170:
                cmp     ax,3B0h
                jae     l_4187                  ; Jump if above or =
l_4175:
                mov     d_02D4,ax           ; b zov  adresa ©adi‡e CD  CD
                inc     ax
                mov     d_02D6,ax           ; b zov  adresa ©adi‡e CD + 1
                mov     d_02D8,ax           ; b zov  adresa ©adi‡e CD + 1
                inc     ax
                mov     d_02DA,ax           ; b zov  adresa ©adi‡e CD + 2
                inc     ax
                mov     d_02DC,ax           ; b zov  adresa ©adi‡e CD + 3

l_4187:
                retn

;==========================================================================
;        parametr "D:" - jm‚no za©¡zen¡ CD
;==========================================================================

s_4188          proc    near
                mov     cx,8
                inc     si
                mov     al,es:[si]
                cmp     al,3Ah                  ; ':'
                jne     l_41A9                  ; Jump if not equal

l_4193:
                inc     si
                mov     al,es:[si]
                cmp     al,20h                  ; ' '
                je      l_41A9                  ; Jump if equal
                cmp     al,0Dh
                je      l_41A9                  ; Jump if equal
                cmp     al,0Ah
                je      l_41A9                  ; Jump if equal
                mov     [di],al
                inc     di
                loop    l_4193                  ; Loop if cx > 0


                retn

l_41A9:
                mov     al,20h                  ; ' '
                mov     [di],al
                inc     di
                loop    l_41A9                  ; Loop if cx > 0

                retn
s_4188          endp


;==========================================================================
;        parametr "/T:" ‡¡slo kan lu DMA
;==========================================================================

s_41B1          proc    near
                inc     si
                mov     al,es:[si]
                cmp     al,3Ah                  ; ':'
                je      l_41BA                  ; Jump if equal
                retn
l_41BA:
                inc     si
                mov     al,es:[si]
                cmp     al,35h                  ; '5'
                je      l_41CB                  ; Jump if equal
                cmp     al,36h                  ; '6'
                je      l_41E8                  ; Jump if equal
                cmp     al,37h                  ; '7'
                je      l_4205                  ; Jump if equal
                retn

; ------ DMA 5

l_41CB:         mov     d_0599,5            ; ‡¡slo kan lu ©adi‡e DMA
                mov     d_059A,2            ; maska kan lu DMA (port 00DEh)
                mov     d_0562,8Bh          ; adresa str nkov‚ho registru DMA
                mov     d_059B,45h          ; povel pro ‡ten¡ kan lem DMA
                mov     d_0560,0C0h             ; (=0)
                jmp     short l_4220

; ------ DMA 6

l_41E8:         mov     d_0599,6            ; ‡¡slo kan lu ©adi‡e DMA
                mov     d_059A,4            ; maska kan lu DMA (port 00DEh)
                mov     d_0562,89h          ; adresa str nkov‚ho registru DMA
                mov     d_059B,46h          ; povel pro ‡ten¡ kan lem DMA
                mov     d_0560,0C0h
                jmp     short l_4220

; ------ DMA 7

l_4205:         mov     d_0599,7            ; ‡¡slo kan lu ©adi‡e DMA
                mov     d_059A,8            ; maska kan lu DMA (port 00DEh)
                mov     d_0562,8Ah          ; adresa str nkov‚ho registru DMA
                mov     d_059B,47h          ; povel pro ‡ten¡ kan lem DMA
                mov     d_0560,0C0h             ; (=0)

l_4220:         mov     al,d_059C               ; (=40h)
                and     al,0F8h
                or      al,d_0599           ; ‡¡slo kan lu ©adi‡e DMA
                mov     d_059C,al               ; (=40h)

                retn
s_41B1          endp

;==========================================================================
;        parametr "I:n" ‡¡slo p©eru¨en¡ IRQ
;==========================================================================

s_422D          proc    near

                inc     si
                mov     al,es:[si]
                cmp     al,3Ah                  ; ':'
                je      l_4236                  ; Jump if equal
                retn

l_4236:         inc     si
                mov     al,es:[si]
                cmp     al,32h                  ; '2'
                je      l_4266                  ; Jump if equal
                cmp     al,33h                  ; '3'
                je      l_424F                  ; Jump if equal
                cmp     al,39h                  ; '9'
                je      l_4266                  ; Jump if equal
                cmp     al,35h                  ; '5'
                je      l_4287                  ; Jump if equal
                cmp     al,31h                  ; '1'
                je      l_429D                  ; Jump if equal
                retn

; ------ p©eru¨en¡ IRQ 3

l_424F:         mov     d_059E,20h          ; k¢d podle ‡¡sla p©eru¨en¡
                mov     d_078F,63h          ; povel pro uvolnˆn¡ ©adi‡e p©eru¨en¡
                mov     d_078E,0F7h         ; maska pro uvolnˆn¡ ©adi‡e p©eru¨en¡
                mov     byte ptr d_4753,3   ; ‡¡slo p©eru¨en¡ IRQ
                jmp     l_42F2

; ------ p©eru¨en¡ IRQ 2, 9

l_4266:         mov     d_059E,10h          ; k¢d podle ‡¡sla p©eru¨en¡
                mov     d_078F,62h          ; povel pro uvolnˆn¡ ©adi‡e p©eru¨en¡
                mov     d_078E,0FBh         ; maska pro uvolnˆn¡ ©adi‡e p©eru¨en¡
                cmp     al,39h                  ; '9'
                je      l_4280                  ; Jump if equal
                mov     byte ptr d_4753,2   ; ‡¡slo p©eru¨en¡ IRQ
                jmp     short l_42F2
l_4280:
                mov     byte ptr d_4753,9   ; ‡¡slo p©eru¨en¡ IRQ
                jmp     short l_42F2

; ------ p©eru¨en¡ IRQ 5

l_4287:         mov     d_059E,30h          ; k¢d podle ‡¡sla p©eru¨en¡
                mov     d_078F,65h          ; povel pro uvolnˆn¡ ©adi‡e p©eru¨en¡
                mov     d_078E,0DFh         ; maska pro uvolnˆn¡ ©adi‡e p©eru¨en¡
                mov     byte ptr d_4753,5   ; ‡¡slo p©eru¨en¡ IRQ
                jmp     short l_42F2

l_429D:         inc     si
                mov     al,es:[si]
                cmp     al,30h                  ; '0'
                je      l_42B1                  ; Jump if equal
                cmp     al,31h                  ; '1'
                je      l_42B2                  ; Jump if equal
                cmp     al,32h                  ; '2'
                je      l_42C8                  ; Jump if equal
                cmp     al,35h                  ; '5'
                je      l_42DE                  ; Jump if equal
l_42B1:         retn

; ------ p©eru¨en¡ IRQ 11

l_42B2:         mov     d_059E,50h          ; k¢d podle ‡¡sla p©eru¨en¡
                mov     d_078F,63h          ; povel pro uvolnˆn¡ ©adi‡e p©eru¨en¡
                mov     d_078E,0F7h         ; maska pro uvolnˆn¡ ©adi‡e p©eru¨en¡
                mov     byte ptr d_4753,0Bh ; ‡¡slo p©eru¨en¡ IRQ
                jmp     short l_42F2

; ------ p©eru¨en¡ IRQ 12

l_42C8:         mov     d_059E,60h          ; k¢d podle ‡¡sla p©eru¨en¡
                mov     d_078F,64h          ; povel pro uvolnˆn¡ ©adi‡e p©eru¨en¡
                mov     d_078E,0EFh         ; maska pro uvolnˆn¡ ©adi‡e p©eru¨en¡
                mov     byte ptr d_4753,0Ch ; ‡¡slo p©eru¨en¡ IRQ
                jmp     short l_42F2

; ------ p©eru¨en¡ IRQ 15

l_42DE:         mov     d_059E,70h          ; k¢d podle ‡¡sla p©eru¨en¡
                mov     d_078F,67h          ; povel pro uvolnˆn¡ ©adi‡e p©eru¨en¡
                mov     d_078E,7Fh          ; maska pro uvolnˆn¡ ©adi‡e p©eru¨en¡
                mov     byte ptr d_4753,0Fh ; ‡¡slo p©eru¨en¡ IRQ

l_42F2:         mov     al,d_059C               ; (=40h)
                and     al,8Fh
                or      al,d_059E           ; k¢d podle ‡¡sla p©eru¨en¡
                mov     d_059C,al               ; (=40h)
                retn

s_422D          endp

;==========================================================================
;        parametr "M:n" - po‡et buffer–
;==========================================================================

s_42FF          proc    near
                inc     si
                mov     al,es:[si]
                cmp     al,3Ah                  ; ':'
                jne     l_4338                  ; Jump if not equal
                inc     si
                mov     al,es:[si]
                cmp     al,30h                  ; '0'
                jb      l_4338                  ; Jump if below
                cmp     al,39h                  ; '9'
                ja      l_4338                  ; Jump if above
                sub     al,30h                  ; '0'
                mov     byte ptr ds:[4754h],al  ; (8535:4754=0)
                inc     si
                mov     al,es:[si]
                or      al,al                   ; Zero ?
                jz      l_432E                  ; Jump if zero
                cmp     al,20h                  ; ' '
                je      l_432E                  ; Jump if equal

                cmp     al,0FFh
                je      l_432E                  ; Jump if equal
                cmp     al,0Dh
                je      l_432E                  ; Jump if equal
                jmp     short $+0Dh
l_432E:
                dec     si
                mov     al,byte ptr ds:[4754h]  ; (8535:4754=0)
                cmp     al,2
                jb      $+31h                   ; Jump if below
;*              jmp     short l_4371            ;*
                db      0EBh, 39h

l_4338:
                retn
                                                ;* No entry point to code
                cmp     al,30h                  ; '0'
                jb      $+2Ah                   ; Jump if below
                cmp     al,39h                  ; '9'
                ja      $+26h                   ; Jump if above
                sub     al,30h                  ; '0'
                mov     byte ptr ds:[4755h],al  ; (8535:4755=0)
                mov     ah,byte ptr ds:[4754h]  ; (8535:4754=0)
                db      0C0h,0E4h, 04h,0A0h, 55h, 47h
                db       0Ah,0C4h,0E8h,0E3h,0EAh, 8Ah
                db       26h, 55h, 47h, 0Ah,0E4h, 75h
                db       14h,0B4h, 30h, 88h, 26h, 55h
                db       47h,0EBh, 0Ch,0B8h, 02h, 00h
                db      0A2h, 54h, 47h,0B4h, 00h, 88h
                db       26h, 55h, 47h
l_4371:
                xor     ah,ah                   ; Zero register
                mov     d_059F,al           ; po‡et buffer– 2 KB
                mov     d_02F6,ax           ; po‡et buffer– 2 KB
                retn
s_42FF          endp


;==========================================================================
;        parametr "/U:n" uzamknut¡/odemknut¡ dv¡©ek
;==========================================================================

s_437A          proc    near
                inc     si
                mov     al,es:[si]
                cmp     al,3Ah                  ; ':'
                jne     l_4390                  ; Jump if not equal
                inc     si
                mov     al,es:[si]
                cmp     al,31h                  ; '1'
                jne     l_4390                  ; Jump if not equal
                mov     d_0765,1            ; 1=uzamknut¡ dv¡©ek
                retn
l_4390:
                mov     d_0765,0            ; 1=uzamknut¡ dv¡©ek
                retn
s_437A          endp



;==========================================================================
;        odemknut¡/uzamknut¡ dv¡©ek
;==========================================================================

s_4396          proc    near
                mov     dx,ds:d_0000_02D4_e ; b zov  adresa ©adi‡e CD
                mov     al,0FEh
                out     dx,al                   ; port 0, DMA-1 bas&add ch 0
                mov     al,ds:d_0000_0765_e ; 1=uzamknut¡ dv¡©ek
                out     dx,al                   ; port 0, DMA-1 bas&add ch 0
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                je      l_43CF                  ; Jump if equal
                test    bl,1
                jnz     l_43D0                  ; Jump if not zero
                cmp     byte ptr ds:d_0000_0765_e,1 ; (=4Fh) ; 1=uzamknut¡ dv¡©ek
                jne     l_43C2                  ; Jump if not equal
                cmp     byte ptr ds:d_0000_43DE_e,0 ; (=43h) ; 1=je parametr "/U:n"
                je      l_43CF                  ; Jump if equal
                mov     dx,d_0000_482C_e        ; (=0B8h)
                call    s_458E              ; zobrazen¡ textu DS:DX
                retn
l_43C2:
                cmp     byte ptr ds:d_0000_43DE_e,0 ; (=43h) ; 1=je parametr "/U:n"
                je      l_43CF                  ; Jump if equal
                mov     dx,d_0000_4840_e        ; (=0ACh)
                call    s_458E              ; zobrazen¡ textu DS:DX

l_43CF:
                retn
l_43D0:
                cmp     byte ptr ds:d_0000_43DE_e,0 ; (=43h) ; 1=je parametr "/U:n"
                je      l_43CF                  ; Jump if equal
                mov     dx,d_0000_4856_e        ; (=74h)
                call    s_458E              ; zobrazen¡ textu DS:DX
                retn
s_4396          endp

d_43DE          db      0                   ; 1=je parametr "/U:n"

;==========================================================================
;        parametr "/A:n"
;==========================================================================

s_43DF          proc    near
                inc     si
                mov     al,es:[si]
                cmp     al,3Ah                  ; ':'
                jne     l_43F5                  ; Jump if not equal
                inc     si
                mov     al,es:[si]
                cmp     al,31h                  ; '1'
                jne     l_43F5                  ; Jump if not equal
                mov     d_0771,1            ; 1=p©¡znak MONO m¢du
                retn

l_43F5:
                mov     d_0771,0            ; 1=p©¡znak MONO m¢du
                retn
s_43DF          endp


;==========================================================================
;        parametr "/S:n"
;==========================================================================

s_43FB          proc    near
                inc     si
                mov     al,es:[si]
                cmp     al,3Ah                  ; ':'
                jne     l_4411                  ; Jump if not equal
                inc     si
                mov     al,es:[si]
                cmp     al,31h                  ; '1'
                jne     l_4411                  ; Jump if not equal
                mov     d_078B,1            ; 1=podporov ny sub-kan ly
                retn
l_4411:
                mov     d_078B,0            ; 1=podporov ny sub-kan ly
                retn
s_43FB          endp


;==========================================================================
;        detekce typu procesoru
;==========================================================================

s_4417          proc    near
                mov     bp,sp
                pushf                           ; Push flags
                xor     cl,cl                   ; Zero register
                xor     ax,ax                   ; Zero register
                push    ax
                popf                            ; Pop flags
                pushf                           ; Push flags
                pop     ax
                and     ax,0F000h
                cmp     ax,0F000h
                je      l_446E                  ; Jump if equal
                inc     cl
                push    sp
                pop     bx
                cmp     bx,sp
                jne     l_446E                  ; Jump if not equal
                inc     cl
                mov     ax,0F000h
                push    ax
                popf                            ; Pop flags
                pushf                           ; Push flags
                pop     ax
                test    ax,0F000h
                jz      l_446E                  ; Jump if zero
                inc     cl

                db       66h, 8Bh,0D4h, 66h, 83h,0E4h
                db      0FCh, 66h, 9Ch, 66h, 58h, 66h
                db       8Bh,0D8h, 66h, 35h, 00h, 00h
                db       04h, 00h, 66h, 50h, 66h, 9Dh
                db       66h, 9Ch, 66h, 58h, 66h, 8Bh
                db      0E2h, 66h, 33h,0C3h, 66h,0A9h
                db       00h, 00h, 04h, 00h, 74h, 02h
                db      0FEh,0C1h
l_446E:
                mov     d_0773,cl               ; typ procesoru
                popf                            ; Pop flags
                mov     sp,bp
                retn
s_4417          endp


; -----------------------------------------------------------------------------
;        cejchov n¡ hodin
; -----------------------------------------------------------------------------

s_4476          proc    near
                mov     ax,40h
                mov     bx,d_0040_006C_e        ; (=43h)
                mov     es,ax               ; ES <- 40h
                mov     ax,es:[bx]          ; ‡¡ta‡ hodin
                db       2Eh, 8Bh,0C0h
l_4484:
                mov     cx,es:[bx]
                cmp     ax,cx
                je      l_4484                  ; Jump if equal
                xor     ax,ax                   ; Zero register
                xor     dx,dx                   ; Zero register
                nop
l_4490:
                cmp     cx,es:[bx]
                jne     l_44A4                  ; Jump if not equal
                add     ax,1
                jnc     l_4490                  ; Jump if carry=0
                adc     dx,0
                jnc     l_4490                  ; Jump if carry=0
                mov     ax,0FFFFh
                mov     dx,ax
l_44A4:
                call    s_44AB              ; ulo‘en¡ ‡asov‚ konstanty DX:AX
                call    s_44DD              ; proveden¡ korekce ‡asov‚ prodlevy
                retn
s_4476          endp

; -----------------------------------------------------------------------------
;    ulo‘en¡ ‡asov‚ konstanty (doba pro 55 ms se vyn sob¡ *37/256/64) = 0.25 ms
; -----------------------------------------------------------------------------

s_44AB          proc    near

; ------ ‡asov  konstanta / 256 (32 d¡l–)

                mov     cx,8
l_44AE:         shr     dx,1                    ; Shift w/zeros fill
                rcr     ax,1                    ; Rotate thru carry
                loop    l_44AE                  ; Loop if cx > 0
                mov     d_052E,dx               ; ‡asov  konstanta pro 0.25 ms
                mov     d_0530,ax               ; (=0)

; ------ p©i‡ten¡ konstanty / 256 / 8 (4 d¡ly)

                mov     cx,3
l_44BE:         shr     dx,1                    ; Shift w/zeros fill
                rcr     ax,1                    ; Rotate thru carry
                loop    l_44BE                  ; Loop if cx > 0
                add     d_0530,ax               ; (=0)
                adc     d_052E,dx               ; ‡asov  konstanta HIGH

; ------ p©i‡ten¡ konstanty / 256 / 8 / 4  (1 d¡l)

                shr     dx,1                    ; Shift w/zeros fill
                rcr     ax,1                    ; Rotate thru carry
                shr     dx,1                    ; Shift w/zeros fill
                rcr     ax,1                    ; Rotate thru carry
                add     d_0530,ax               ; (=0)
                adc     d_052E,dx               ; ‡asov  konstanta HIGH
                retn

s_44AB          endp

; -----------------------------------------------------------------------------
;        proveden¡ korekce ‡asov‚ prodlevy
; -----------------------------------------------------------------------------

s_44DD          proc    near
                mov     ax,40h
                mov     bx,d_0040_006C_e        ; (=44h)
                mov     es,ax
l_44E5:
                xor     si,si                   ; ‡¡ta‡ pr–chod–
                mov     ax,es:[bx]
                mov     ax,ax
l_44EC:
                mov     dx,es:[bx]
                cmp     ax,dx
                je      l_44EC                  ; Jump if equal
                nop
l_44F4:
                cmp     dx,es:[bx]          ; zmˆna ?
                jne     l_4504                  ; Jump if not equal
                mov     cx,1                ; 1 impuls
                call    s_2E56              ; prodleva CX * 0.25 ms
                add     si,1
                jmp     short l_44F4
l_4504:

                mov     dx,d_052E           ; ‡asov  konstanta pro 0.25 ms
                mov     ax,d_0530               ; (=0)
                mov     cx,5

l_450E:         shr     dx,1                    ; Shift w/zeros fill
                rcr     ax,1                    ; Rotate thru carry

                loop    l_450E                  ; Loop if cx > 0

                cmp     si,0DCh             ; 220
                jae     l_4521                  ; Jump if above or =
                cmp     si,0D2h             ; 210
                jbe     l_452B                  ; Jump if below or =
                retn
l_4521:
                add     d_0530,ax               ; (=0)
                adc     d_052E,dx           ; ‡asov  konstanta pro 0.25 ms
                jmp     short l_44E5
l_452B:
                sub     d_0530,ax               ; (=0)
                sbb     d_052E,dx           ; ‡asov  konstanta pro 0.25 ms
                jmp     short l_44E5
s_44DD          endp

;==========================================================================
;        detekce regulace hlasitosti audiokan lu
;==========================================================================

s_4535          proc    near
                mov     dx,ds:d_0000_02D4_e ; b zov  adresa ©adi‡e CD
                mov     al,0DCh
                out     dx,al                   ; port 0, DMA-1 bas&add ch 0
                call    s_2D4C              ; potvrzen¡ p©evzet¡ povelu CD
                cmp     al,0FFh
                jne     l_4544                  ; Jump if not equal
                retn
l_4544:
                test    bl,1
                jz      l_454C                  ; Jump if zero
                mov     al,1
                retn
l_454C:
                call    s_2DC7              ; vstup datov‚ho bajtu z ©adi‡e CD
                cmp     al,0FFh
                jne     l_4554                  ; Jump if not equal
                retn
l_4554:
                mov     ds:d_0000_0766_e,bl ; rozsah regulace hlasitosti CD (44h)
                call    s_2DC7              ; vstup datov‚ho bajtu z ©adi‡e CD
                cmp     al,0FFh
                jne     l_4560                  ; Jump if not equal
                retn
l_4560:
                mov     ds:d_0000_0767_e,bl     ; (=4Bh)
                cmp     byte ptr ds:d_0000_0766_e,4Dh ; (=43h) 'M'; rozsah regulace hlasitosti CD (44h)
                je      l_4581                  ; Jump if equal
                cmp     byte ptr ds:d_0000_0766_e,46h ; (=43h) 'F' ; rozsah regulace hlasitosti CD (44h)
                je      l_457E                  ; Jump if equal
                cmp     byte ptr ds:d_0000_0766_e,44h ; (=43h) 'D' ; rozsah regulace hlasitosti CD (44h)
                jne     l_458B                  ; Jump if not equal
                mov     byte ptr ds:d_0000_0790_e,1 ; (=0)
l_457E:
                xor     al,al                   ; Zero register

                retn
l_4581:
                cmp     byte ptr ds:d_0000_0767_e,14h ; (=4Bh)
                jb      l_458B                  ; Jump if below
                xor     al,al                   ; Zero register
                retn
l_458B:
                mov     al,1
                retn
s_4535          endp


;==========================================================================
;        zobrazen¡ textu DS:DX
;==========================================================================

s_458E          proc    near
                mov     ah,9
                int     21h                     ; DOS Services  ah=function 09h
                                                ;  display char string at ds:dx
                retn
s_458E          endp


;==========================================================================
;        zobrazen¡ znaku DL
;==========================================================================

s_4593          proc    near
                mov     ah,2
                int     21h                     ; DOS Services  ah=function 02h
                                                ;  display char dl
                retn
s_4593          endp


;==========================================================================
;        parametr "/X" - pou‘¡t extended pamˆŸ
;==========================================================================

s_4598          proc    near
                push    es
                mov     d_077A,0            ; p©¡znak extended pamˆti
                mov     ax,4300h
                int     2Fh                     ; HIMEM.SYS installed state, al
                cmp     al,80h
                jne     l_45C9                  ; Jump if not equal
                mov     ax,4310h
                int     2Fh                     ; Get HIMEM entrypoint ptr,es:bx
                mov     word ptr d_053A,bx   ; adresa ovlada‡e extended pamˆti
                mov     word ptr d_053A+2,es; adresa ovlada‡e extended pamˆti
                mov     ah,8
                call    d_053A              ; adresa ovlada‡e extended pamˆti
                mov     d_474E,ax               ; (=0)
                cmp     ax,5
                jb      l_45C7                  ; Jump if below
                mov     d_077A,1            ; p©¡znak extended pamˆti

l_45C7:
                pop     es
                retn
l_45C9:
                mov     d_077A,2            ; p©¡znak extended pamˆti
                pop     es
                retn
s_4598          endp


;==========================================================================
;                              SUBROUTINE
;==========================================================================

s_45D0          proc    near
                mov     ax,ds:d_0000_0566_e     ; (=2056h)
                xor     bx,bx                   ; Zero register
                mov     word ptr ds:d_0000_0322_e,800h ; (=0)
                xor     bp,bp                   ; Zero register
                cmp     byte ptr ds:d_0000_0599_e,0 ; (=1Eh) ; ‡¡slo kan lu ©adi‡e DMA
                jne     $+5                     ; Jump if not equal
                jmp     l_466C
                                                ;* No entry point to code
                mov     dh,ah
                and     dh,0F0h
                db      0C1h,0E0h, 04h, 03h,0D8h, 89h
                db       1Eh,0FEh, 02h, 72h, 02h,0EBh
                db       04h
l_45F9:
                clc                             ; Clear carry flag
                add     dh,10h
l_45FD:
                mov     ah,dh
                xor     al,al                   ; Zero register
                mov     ds:d_0000_02FC_e,ax     ; (=0)
                mov     bx,ds:d_0000_02FE_e     ; (=0)
                mov     dx,ds:d_0000_02FC_e     ; (=0)
                add     bx,ds:d_0000_0322_e     ; (=0)
                jc      l_4614                  ; Jump if carry Set
                jmp     short l_4622
l_4614:
                clc                             ; Clear carry flag
                add     dx,1000h
                jnc     l_461E                  ; Jump if carry=0
                jmp     l_46B2
l_461E:
                xor     bx,bx                   ; Zero register
                jmp     short l_4626
l_4622:
                mov     bx,ds:d_0000_02FE_e     ; (=0)
l_4626:
                mov     ds:d_0000_0324_e[bp],bx ; (=0)
                mov     ds:d_0000_03A4_e[bp],dx ; (=6000h)
                dec     cx
                jnz     l_4635                  ; Jump if not zero
                jmp     short l_4697


l_4635:
                add     bx,ds:d_0000_0322_e     ; (=0)
                mov     ax,bx
                add     bx,ds:d_0000_0322_e     ; (=0)
                inc     bp
                inc     bp
                jc      l_4645                  ; Jump if carry Set
                jmp     short l_4652
l_4645:
                clc                             ; Clear carry flag
                or      bx,bx                   ; Zero ?
                jz      l_4652                  ; Jump if zero
                add     dx,1000h
                xor     bx,bx                   ; Zero register
                jmp     short l_465E
l_4652:
                or      ax,ax                   ; Zero ?
                jnz     l_465C                  ; Jump if not zero
                add     dx,1000h
                jc      l_46B2                  ; Jump if carry Set
l_465C:
                mov     bx,ax
l_465E:
                mov     ds:d_0000_0324_e[bp],bx ; (=0)
                mov     ds:d_0000_03A4_e[bp],dx ; (=6000h)
                loop    l_4635                  ; Loop if cx > 0

                jmp     short l_4697
l_466C:
                mov     dx,ax
                mov     ds:d_0000_0324_e[bp],bx ; (=0)
                mov     ds:d_0000_03A4_e[bp],dx ; (=6000h)
                dec     cl
                jz      l_4697                  ; Jump if zero

l_467C:
                inc     bp
                inc     bp
                add     bx,ds:d_0000_0322_e     ; (=0)
                jnc     l_468B                  ; Jump if carry=0
                clc                             ; Clear carry flag
                add     dx,1000h
                jc      l_46B2                  ; Jump if carry Set
l_468B:
                mov     ds:d_0000_0324_e[bp],bx ; (=0)
                mov     ds:d_0000_03A4_e[bp],dx ; (=6000h)
                loop    l_467C                  ; Loop if cx > 0

l_4697:
                add     bx,ds:d_0000_0322_e     ; (=0)
                jnc     $+9                     ; Jump if carry=0
                clc                             ; Clear carry flag
                add     dx,1000h
                jc      l_46B2                  ; Jump if carry Set
                mov     ax,bx
                db      0C1h,0E8h, 04h, 03h,0D0h, 89h
                db       16h, 68h, 05h, 32h,0C0h,0C3h

l_46B2:
                mov     ax,ds:d_0000_4756_e     ; (=0FFCDh)
                mov     ds:d_0000_0568_e,ax     ; (=2020h)
                mov     al,1
                retn
s_45D0          endp


;==========================================================================
;                              SUBROUTINE
;==========================================================================

s_46BB          proc    near
                xor     cx,cx                   ; Zero register
                xor     bx,bx                   ; Zero register
                mov     ax,ds:d_0000_0566_e     ; (=2056h)
                mov     dh,ah
                and     dh,0F0h
                db      0C1h,0E0h, 04h, 03h,0D8h, 89h
                db       1Eh,0FEh, 02h, 72h, 02h,0EBh
                db       04h
l_46D4:
                clc                             ; Clear carry flag
                add     dh,10h
l_46D8:
                mov     ah,dh
                xor     al,al                   ; Zero register
                mov     ds:d_0000_02FC_e,ax     ; (=0)
                mov     bx,ds:d_0000_02FE_e     ; (=0)
                mov     dx,ds:d_0000_02FC_e     ; (=0)
                add     bx,930h
                jc      l_46EF                  ; Jump if carry Set
                jmp     short $+0Bh
l_46EF:
                clc                             ; Clear carry flag
                add     dx,1000h
                xor     bx,bx                   ; Zero register
                dec     cl
                mov     ax,bx
                db      0C1h,0E8h, 04h, 03h,0C2h, 3Bh
                db       06h, 68h, 05h, 77h, 04h,0FEh
                db      0C1h,0EBh,0DEh,0C3h

;==== External Entry into Subroutine ======================================

s_470A:
                cmp     byte ptr ds:d_0000_474D_e,0 ; (=3Eh) ; parametr "/V"
                je      l_4746                  ; Jump if equal
                mov     dx,d_0000_4A04_e        ; (=0Ch)
                call    s_458E              ; zobrazen¡ textu DS:DX
                mov     dl,ds:d_0000_0766_e     ; (=43h); rozsah regulace hlasitosti CD (44h)
                call    s_4593              ; zobrazen¡ znaku DL
                mov     al,ds:d_0000_0767_e     ; (=4Bh)
                push    ax
                and     al,0F0h
                db      0C0h,0E8h, 04h, 24h, 0Fh, 04h
                db       30h, 3Ch, 3Ah, 72h, 02h, 04h

                db       07h, 8Ah,0D0h,0E8h, 5Dh,0FEh
                db       58h, 24h, 0Fh, 04h, 30h, 3Ch
                db       3Ah, 72h, 02h, 04h, 07h
l_4741:
                mov     dl,al
                call    s_4593              ; zobrazen¡ znaku DL
l_4746:
                mov     dx,d_0000_4889_e        ; (=0E3h)
                call    s_458E              ; zobrazen¡ textu DS:DX
                retn
s_46BB          endp

d_474D          db      0                   ; parametr "/V"
d_474E          dw      0
                db      0
                db      0
d_4752          db      0
d_4753          db      0Ah                 ; ‡¡slo p©eru¨en¡ IRQ
                db      0
                db      0
d_4756          dw      0
d_4758          db      'UMB', 0Dh, 0Ah, 'CD-ROM device d'
                db      'river MTMCDAE Version 01.13', 0Dh
                db      0Ah, '$'
                db      0Dh, 0Ah, '# Installed CD-ROM Dri'
                db      've       : 1', 0Dh, 0Ah, '$'
                db      '# Stock Buffer Memory (Sector) :'
                db      ' $'
                db      0Dh, 0Ah, '# Installed DMA channe'
                db      'l : CH$'
                db      '    DMA channel not in use$'
                db      0Dh, 0Ah, '# Installed IRQ channe'

                db      'l : CH$'
                db      '# Door  : Locked ', 0Dh, 0Ah, '$'
                db      '# Door  : Unlocked ', 0Dh, 0Ah, '$'
                db      '# Lock/Unlock Skipped', 0Dh, 0Ah
                db      '$'
                db      '# Monaural Audio Play Mode$'
                db      ' ', 0Dh, 0Ah, '$'
                db      0Dh, 0Ah, 'CD-ROM is not detected'
                db      ' or different$'
                db      ', driver not loaded.', 0Dh, 0Ah, 0Dh
                db      0Ah, '$'
                db      '  Extended Memory Manager not pr'
                db      'esent.', 0Dh, 0Ah, '$'
                db      '  Extended Memory allocation err'
                db      'or.', 0Dh, 0Ah, '$'
                db      '  CD-ROM driver not used Extende'

                db      'd Memory.', 0Dh, 0Ah, '$'
                db      ' (XMS)$'
                db      '  Free Extended Memory is less t'
                db      'han /M paramater.', 0Dh, 0Ah, '$'
                db      '  UMB size is too small$'
                db      ', Buffer size is adjusted.', 0Dh
                db      0Ah, '$'
                db      '# Sub channel information comman'
                db      'd is supported.$'
                db      '# Detected CD-ROM drive FX00$'
                db      '# F/W Version : $'

seg_a           ends

d_0000_0004_e   equ     4                       ; (=6F4h)
d_0000_0016_e   equ     16h                     ; (=0F000h)
d_0000_02E0_e   equ     2E0h                    ; (=0)
d_0000_02E2_e   equ     2E2h                    ; (=0)
d_0000_02FC_e   equ     2FCh                    ; (=0)
d_0000_02FE_e   equ     2FEh                    ; (=0)
d_0000_031E_e   equ     31Eh                    ; (=0)
d_0000_0322_e   equ     322h                    ; (=0)
d_0000_0324_e   equ     324h                    ; (=0)
d_0000_03A4_e   equ     3A4h                    ; (=6000h)
d_0000_053E_e   equ     53Eh                    ;*(=0)
d_0000_0566_e   equ     566h                    ;*(=2056h)
d_0000_0568_e   equ     568h                    ;*(=2020h)
d_0000_059C_e   equ     59Ch                    ;*(=0)
d_0000_05A0_e   equ     5A0h                    ;*(=33h)
d_0000_05A1_e   equ     5A1h                    ;*(=44h)
d_0000_05A2_e   equ     5A2h                    ;*(=53h)
d_0000_0767_e   equ     767h                    ;*(=4Bh)
d_0000_0772_e   equ     772h                    ;*(=6)
d_0000_0776_e   equ     776h                    ;*(=80h)
d_0000_0788_e   equ     788h                    ;*(=31h)

d_0000_0790_e   equ     790h                    ;*(=0)
d_0000_3A5C_e   equ     3A5Ch                   ;*(=0)
d_0000_474E_e   equ     474Eh                   ;*(=1773h)
d_0000_4754_e   equ     4754h                   ;*(=25h)
d_0000_4755_e   equ     4755h                   ;*(=0)
d_0000_4756_e   equ     4756h                   ;*(=0FFCDh)
d_0000_475B_e   equ     475Bh                   ;*(=0FFh)
d_0000_478A_e   equ     478Ah                   ;*(=58h)
d_0000_47B1_e   equ     47B1h                   ;*(=0Ch)
d_0000_47D3_e   equ     47D3h                   ;*(=0C3h)
d_0000_47F2_e   equ     47F2h                   ;*(=0C5h)
d_0000_480D_e   equ     480Dh                   ;*(=74h)
d_0000_482C_e   equ     482Ch                   ;*(=0B8h)
d_0000_4840_e   equ     4840h                   ;*(=0ACh)
d_0000_4856_e   equ     4856h                   ;*(=74h)
d_0000_486E_e   equ     486Eh                   ;*(=0ACh)
d_0000_4889_e   equ     4889h                   ;*(=0E3h)
d_0000_488D_e   equ     488Dh                   ;*(=0DFh)
d_0000_48B3_e   equ     48B3h                   ;*(=32h)
d_0000_48CC_e   equ     48CCh                   ;*(=72h)
d_0000_48F5_e   equ     48F5h                   ;*(=0BDh)
d_0000_491B_e   equ     491Bh                   ;*(=68h)
d_0000_4947_e   equ     4947h                   ;*(=45h)
d_0000_494E_e   equ     494Eh                   ;*(=0)
d_0000_4982_e   equ     4982h                   ;*(=20h)
d_0000_499A_e   equ     499Ah                   ;*(=0)
d_0000_49B7_e   equ     49B7h                   ;*(=44h)
d_0000_4A04_e   equ     4A04h                   ;*(=0Ch)
d_0040_006C_e   equ     6Ch                     ; (=0D4h)



                end

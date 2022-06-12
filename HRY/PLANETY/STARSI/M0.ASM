
; -----------------------------------------------------------------------------
;
;
;
; -----------------------------------------------------------------------------

; Vyladˆno pro p©eklad pomoc¡ TASM verze 2.01 !!!!!
; Vy‘aduje k provozu procesor 386 a vy¨¨¡ !

; ------ definice zobrazen¡

MAXSKLON EQU       30                       ; maxim ln¡ bo‡n¡ sklon (linek)
VYSKA    EQU       210;200                      ; pracovn¡ v˜¨ka obr zku (linek)
SIRKA    EQU       280;256                      ; ¨¡©ka obr zku (n sobek 4 !)
VYSKAD   EQU       VYSKA-MAXSKLON-1         ; zobrazen  v˜¨ka obr zku (linek)
SIRKAD   EQU       SIRKA-MAXSKLON           ; zobrazen  ¨¡©ka obr zku

TOPLINE  EQU       (200 - VYSKAD)/2         ; po‡ te‡n¡ linka obr zku
TOPPOZ   EQU       (320 - SIRKA)/2          ; po‡ te‡n¡ pozice obr zku (sud  !)
POSUN    EQU       320 - SIRKA              ; vz jemn˜ posun adres linek

HORIZ    EQU       114 ;100                 ; linka s horizontem
POZADL   EQU       40                       ; po‡et linek pozad¡

RYCHLX   EQU       256                      ; rychlost X
RYCHLY   EQU       256                      ; rychlost Y

; ------ jemnost pohybu

KROKU    EQU       16                       ; po‡et krok– na jeden bod mapy
KROKUC   EQU       4                        ; po‡et rotac¡ po‡tu krok–
KROKUM   EQU       0fh                      ; maska po‡tu krok–

; ------ definice barev

ColTeren EQU       0                        ; po‡ te‡n¡ barva ter‚nu
ColTerN  EQU       64                       ; po‡et barev ter‚nu

ColObloh EQU       64                       ; po‡ te‡n¡ barva oblohy
ColOblN  EQU       32                       ; po‡et barev oblohy
ColOblC  EQU       3                        ; po‡et rotac¡ pro p©evod 256->barev

ColPozad EQU       42                       ; barva pozad¡ v d lce

HI       EQU       256                      ; koeficient pro vy¨¨¡ bajt

; *****************************************************************************
;
;                         Programov˜ segment
;
; *****************************************************************************

Code     SEGMENT
         ASSUME    cs:Code,ds:Data,ss:Zasob

; ------ inicializace segmentov˜ch registr–

Start:   mov       ax,SEG Data
         mov       ds,ax
         mov       es,ax
         cld

; ------ inicializace gener toru n hody

         xor       ah,ah
         int       1ah                      ; poskytnut¡ aktu ln¡ho ‡¡ta‡e ‡asu
         and       dh,7fh
         mov       ds:[RndNum],dx           ; inicializace gener toru n hody

; ------ inicializace videom¢du

         mov       ax,13h
         int       10h                      ; nastaven¡ videom¢du VGA

; ------ test instalace my¨i

         xor       ax,ax
         int       33h                      ; test instalace my¨i
         inc       ax                       ; je my¨ (-1=je) ?
         mov       byte ptr ds:[d_035b],0   ; nen¡ my¨
         jnz       Start1                   ; nen¡ my¨
         dec       byte ptr ds:[d_035b]     ; -1 = je my¨

         mov       ax,7
         xor       cx,cx
         mov       dx,RYCHLX
         int       33h                      ; horizont ln¡ rozsah

         mov       ax,8
         xor       cx,cx
         mov       dx,RYCHLY
         int       33h                      ; vertik ln¡ rozsah

         mov       ax,4
         mov       cx,RYCHLX/2
         mov       dx,RYCHLY/2
         int       33h

Start1:  mov       word ptr ds:[PosunX],0
         mov       word ptr ds:[PosunY],0
         mov       byte ptr ds:[Vyska0],120

; ------ inicializace palet barev

         mov       si,offset d_020A         ; tabulka palet
         cli
         mov       dx,3c8h
         xor       al,al
         out       dx,al
         inc       dx
         mov       cx,3*256                 ; po‡et barev (platn‚ jen 96 barev)
Start2:  lodsb
         out       dx,al
         loop      Start2
         sti

; ------ inicializace buffer– a ukazatel–

         call      GenOblh                  ; vygenerov n¡ mapy oblohy
         push      ds
         pop       es
         call      GenTern                  ; vygenerov n¡ mapy ter‚nu
         push      ds
         pop       es
         mov       byte ptr ds:[d_035f],0   ; nulov n¡ p©¡znaku p©eru¨en¡
         mov       word ptr ds:[d_0351],1000 ; aktu ln¡ pozice my¨i X
         mov       word ptr ds:[d_0353],1000 ; aktu ln¡ pozice my¨i Y

; ------ obsluha my¨i, dek¢dov n¡ obr zku

l_00BC:  call      l_0408                   ; obsluha my¨i a kl vesnice
         call      DekOblh                  ; dek¢dov n¡ oblohy a pozad¡
         call      l_0A1F                   ; dek¢dov n¡ ter‚nu


         call      Zobraz                   ; zobrazen¡ obsahu bufferu obr zku


; ------ test, zda je p©eru¨en¡ programu

         push      ds
         pop       es
         cmp       byte ptr ds:[d_035F],0   ; je p©eru¨en¡ programu ?
         je        short l_00BC             ; nen¡ p©eru¨en¡ programu

; ------ n vrat videom¢du

         mov       ax,3
         int       10h                      ; nastaven¡ videom¢du 3

; ------ konec programu

         mov       ax,4c00h
         int       21h

; *****************************************************************************
;
;                        Obsluha generov n¡ mapy
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;                       vygenerov n¡ mapy oblohy
; -----------------------------------------------------------------------------

GenOblh  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      di
         push      es

; ------ vygenerov n¡ mapy oblohy

         mov       es,ds:[SegMapO]          ; segment mapy oblohy
         mov       ax,ds:[RndNum]
         call      GenMap                   ; vygenerov n¡ mapy oblohy
         mov       ds:[RndNum],ax

; ------ korekce na barvu oblohy

         cld
         xor       di,di                    ; DI <- 0 ukazatel adresy v mapˆ
         xor       cx,cx                    ; ‡¡ta‡ dat
GenOblh1:mov       al,es:[di]               ; bajt z mapy 0 a‘ 255

         REPT      ColOblC
         shr       al,1                     ; zmen¨en¡ rozkmitu na 0 a‘ 31
         ENDM

         add       al,ColObloh              ; korekce na z kladn¡ barvu oblohy
         stosb                              ; ulo‘en¡ zkorigovan‚ barvy
         loop      GenOblh1

; ------ n vrat registr–

         pop       es
         pop       di
         pop       cx
         pop       ax
         ret

GenOblh  ENDP

; -----------------------------------------------------------------------------
;        vygenerov n¡ mapy ter‚nu a mapy barev ter‚nu
; -----------------------------------------------------------------------------

GenTern  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      es

; ------ vygenerov n¡ mapy ter‚nu a mapy barev ter‚nu

         mov       es,ds:[SegMapT]          ; segment mapy ter‚nu
         mov       ax,ds:[RndNum]
         call      GenMap                   ; vygenerov n¡ mapy ter‚nu
         mov       ds:[RndNum],ax
         mov       cl,1                     ; stupe¤ ostrosti
         call      Zjemni                   ; zjemnˆn¡ mapy ter‚nu
         call      GenColT                  ; generov n¡ barev mapy ter‚nu

; ------ n vrat registr–

         pop       es
         pop       cx
         pop       ax
         ret

GenTern  ENDP

; -----------------------------------------------------------------------------
;                  vygenerov n¡ mapy v bufferu 64 KB
; -----------------------------------------------------------------------------
; VSTUP: ES=segment bufferu mapy
;        AX=promˆnn  n hodn‚ho ‡¡sla
; VSTUP:AX=nov  promˆnn  gener toru n hody
; -----------------------------------------------------------------------------
;  Procedura generuje n hodnou mapu ter‚nu v bufferu o matici 256 © dk– po
; 256 sloupc¡ch. P©i generov n¡ se pou‘¡vaj¡ jako v˜choz¡ rohov‚ body oblasti.
; Nejd©¡ve se vygeneruj¡ st©edov‚ body na hran ch oblasti a potom st©edov˜ bod
; ve st©edu oblasti. Potom procedura zjmen¡ krok na polovinu a opakuje
; operaci pro v¨echny podoblasti. Postupnˆ zjem¤uje krok a‘ na 1.
; P©i generov n¡ nov‚ho st©edn¡ho bodu se vypo‡te z krajn¡ch bod– st©edn¡
; hodnota a tato hodnota se rozm¡t  n hodn˜m ‡¡slem. Velikost rozm¡t n¡ z vis¡
; na velikosti £seku oblasti.
; -----------------------------------------------------------------------------

GenMap   PROC      NEAR

; ------ £schova registr–

         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds

; ------ p©¡prava registr–

         xchg      ax,si                    ; promˆnn  gener toru n hody
         cld
         push      es
         pop       ds                       ; DS <- segment bufferu
         xor       bx,bx                    ; po‡ te‡n¡ bod oblasti
         mov       cx,256                   ; ¨¡©ka oblasti
         mov       byte ptr ds:[bx],128

; ====== st©edn¡ bod linky (1,0) - (1,1)

; ------ st©edn¡ hodnota linky (1,0) - (1,1)

GenMap0: add       bl,cl
         add       bl,cl
         mov       al,ds:[bx]
         add       bh,cl
         mov       di,bx                    ; adresa st©edn¡ho bodu
         add       bh,cl
         add       al,ds:[bx]
         rcr       al,1                     ; AL = st©edn¡ hodnota bod–
         mov       ah,0
         xchg      ax,bp                    ; BP <- st©edn¡ hodnota bod–

; ------ vygenerov n¡ n hodn‚ho ‡¡sla

         xchg      ax,si
         ror       ax,1
         xor       ax,23511
         add       ax,1127
         xor       ax,bx
         mov       si,ax                    ; SI <- nov  promˆnn  gener toru

; ------ m hodn‚ zvlnˆn¡ bodu

         imul      cx                       ; p©¡mo £mˆrn‚ ¨¡©ce oblasti 1-128
         mov       al,ah                    ; AL <- ‡¡slo +/- (0 a‘ CL-1)
         mov       ah,dl                    ; AH <- ‡¡slo HIGH
         sar       ax,1
         sar       ax,1
         sar       ax,1
         sar       ax,1
         sar       ax,1                     ; n hodn‚ zvlnˆn¡
         cbw

; ------ nov  hodnota bodu

         add       ax,bp                    ; sou‡et bod– se zvlnˆn¡m
         jns       short GenMap1            ; nen¡ podte‡en¡ hodnoty
         xor       ax,ax                    ; omezen¡ p©i podte‡en¡ hodnoty
GenMap1: or        ah,ah
         jz        short GenMap2            ; nen¡ p©ete‡en¡ hodnoty
         mov       al,255                   ; omezen¡ p©i p©ete‡en¡ hodnoty
GenMap2: stosb


; ====== st©edn¡ bod linky (1,1) - (0,1)

; ------ st©edn¡ hodnota linky (1,1) - (0,1)

         mov       al,ds:[bx]
         sub       bl,cl
         mov       di,bx
         sub       bl,cl
         add       al,ds:[bx]
         rcr       al,1                     ; AL = st©edn¡ hodnota bod–
         mov       ah,0
         xchg      ax,bp                    ; BP <- st©edn¡ hodnota bod–

; ------ vygenerov n¡ n hodn‚ho ‡¡sla

         xchg      ax,si
         ror       ax,1
         xor       ax,23511
         add       ax,1127
         xor       ax,bx
         mov       si,ax                    ; SI <- nov  promˆnn  gener toru

; ------ m hodn‚ zvlnˆn¡ bodu

         imul      cx                       ; p©¡mo £mˆrn‚ ¨¡©ce oblasti 1-128
         mov       al,ah                    ; AL <- ‡¡slo +/- (0 a‘ CL-1)
         mov       ah,dl                    ; AH <- ‡¡slo HIGH
         sar       ax,1
         sar       ax,1
         sar       ax,1
         sar       ax,1
         sar       ax,1                     ; n hodn‚ zvlnˆn¡
         cbw

; ------ nov  hodnota bodu

         add       ax,bp                    ; sou‡et bod– se zvlnˆn¡m
         jns       short GenMap3            ; nen¡ podte‡en¡ hodnoty
         xor       ax,ax                    ; omezen¡ p©i podte‡en¡ hodnoty
GenMap3: or        ah,ah
         jz        short GenMap4            ; nen¡ p©ete‡en¡ hodnoty
         mov       al,255                   ; omezen¡ p©i p©ete‡en¡ hodnoty
GenMap4: stosb


; ====== st©edn¡ bod cel‚ oblasti

; ------ st©edn¡ hodnoty okraj–

         sub       bh,cl
         sub       bh,cl

         mov       al,ds:[bx]
         add       bh,cl
         add       bh,cl
         add       al,ds:[bx]
         rcr       al,1                     ; st©edn¡ hodnota 1

         add       bl,cl
         add       bl,cl
         mov       ah,ds:[bx]
         sub       bh,cl
         sub       bh,cl
         add       ah,ds:[bx]
         rcr       ah,1                     ; st©edn¡ hodnota 2

         sub       bl,cl
         add       bh,cl
         mov       di,bx

; ------ st©edn¡ hodnota oblasti

         add       al,ah
         rcr       al,1
         mov       ah,0
         xchg      ax,bp                    ; BP <- st©edn¡ hodnota bod–

; ------ vygenerov n¡ n hodn‚ho ‡¡sla

         xchg      ax,si
         ror       ax,1
         xor       ax,23511
         add       ax,1127
         xor       ax,bx
         mov       si,ax                    ; SI <- nov  promˆnn  gener toru

; ------ m hodn‚ zvlnˆn¡ bodu

         imul      cx                       ; p©¡mo £mˆrn‚ ¨¡©ce oblasti 1-128
         mov       al,ah                    ; AL <- ‡¡slo +/- (0 a‘ CL-1)
         mov       ah,dl                    ; AH <- ‡¡slo HIGH
         sar       ax,1
         sar       ax,1
         sar       ax,1
         sar       ax,1
         sar       ax,1                     ; n hodn‚ zvlnˆn¡
         cbw

; ------ nov  hodnota bodu

         add       ax,bp                    ; sou‡et bod– se zvlnˆn¡m
         jns       short GenMap5            ; nen¡ podte‡en¡ hodnoty
         xor       ax,ax                    ; omezen¡ p©i podte‡en¡ hodnoty
GenMap5: or        ah,ah
         jz        short GenMap6            ; nen¡ p©ete‡en¡ hodnoty
         mov       al,255                   ; omezen¡ p©i p©ete‡en¡ hodnoty
GenMap6: stosb

; ------ posun do dal¨¡ oblasti

         sub       bh,cl
         add       bl,cl
         jnz       short GenMap8

         add       bh,cl
         add       bh,cl
         jnz       short GenMap8

         shr       cx,1
         jz        short GenMap9

GenMap8: jmp       GenMap0

; ------ n vrat registr–

GenMap9: xchg      ax,si
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

GenMap   ENDP

; -----------------------------------------------------------------------------
;        zjemnˆn¡ mapy 64 KB
; -----------------------------------------------------------------------------
; VSTUP: CL=stupen ostrosti 0... (0 nejvˆt¨¡ zjemnˆn¡)
;        ES=segment bufferu mapy
; -----------------------------------------------------------------------------

Zjemni   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      ds

; ------ p©¡prava registr–

         push      es
         pop       ds                       ; DS <- segment bufferu
         xor       bx,bx                    ; ukazatel adresy v bufferu
         mov       ch,cl                    ; stupe¤ ostrosti
         add       ch,8                     ; dˆlitel ‡¡sla

; ------ st©edn¡ bod

Zjemni1: mov       al,ds:[bx]               ; st©edn¡ bod
         mul       cl                       ; v ha st©edn¡ho bodu

; ------ p©i‡ten¡ okoln¡ch 8 bod–

         dec       bl
         add       al,ds:[bx]               ; (-1,0)
         adc       ah,0

         dec       bh
         add       al,ds:[bx]               ; (-1,-1)
         adc       ah,0

         inc       bl
         add       al,ds:[bx]               ; (0,-1)
         adc       ah,0

         inc       bl
         add       al,ds:[bx]               ; (1,-1)
         adc       ah,0

         inc       bh
         add       al,ds:[bx]               ; (1,0)
         adc       ah,0

         inc       bh
         add       al,ds:[bx]               ; (1,1)
         adc       ah,0

         dec       bl
         add       al,ds:[bx]               ; (0,1)
         adc       ah,0

         dec       bl
         add       al,ds:[bx]               ; (-1,1)
         adc       ah,0

; ------ st©edn¡ hodnota bodu

         dec       bh
         inc       bl
         div       ch
         mov       ds:[bx],al               ; nov  st©edn¡ hodnota

; ------ p©¡prava pro dal¨¡ bod

         inc       bx
         jnz       short Zjemni1

; ------ n vrat registr–

         pop       ds
         pop       cx
         pop       bx
         pop       ax
         ret

Zjemni   ENDP

; -----------------------------------------------------------------------------
;        vygenerov n¡ mapy barev ter‚nu
; -----------------------------------------------------------------------------

GenColT  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      ds
         push      es

; ------ p©¡prava registr–

         mov       es,ds:[SegMapC]          ; segment mapy barev ter‚nu
         mov       ds,ds:[SegMapT]          ; segment mapy ter‚nu
         xor       bx,bx                    ; ukazatel v map ch

; ------ stanoven¡ sklonu hrany v ter‚nu

GenColT2:mov       ah,0
         dec       bl
         mov       al,ds:[bx]               ; p©ede¨l˜ bod
         inc       bl
         inc       bl
         sub       al,ds:[bx]               ; rozd¡l s n sleduj¡c¡m bodem
         sbb       ah,0
         dec       bl

; ------ stanoven¡ barvy

         add       ax,ColTerN/2             ; posun na st©edn¡ hodnotu barvy
         jns       short GenColT3           ; nen¡ podte‡en¡
         xor       ax,ax                    ; omezen¡ barvy p©i podte‡en¡
GenColT3:cmp       ax,ColTerN-1             ; je p©ete‡en¡ barvy ?
         jb        short GenColT4           ; nen¡ p©ete‡en¡ barvy
         mov       al,ColTerN-1             ; omezen¡ barvy p©i p©ete‡en¡
GenColT4:add       al,ColTeren              ; p©i‡ten¡ z kladn¡ barvy ter‚nu
         mov       es:[bx],al               ; ulo‘en¡ barvy bodu

; ------ p©¡prava pro dal¨¡ bod

         inc       bx                       ; zv˜¨en¡ ukazatele bodu
         jnz       short GenColT2           ; dal¨¡ bod

; ------ n vrat registr–

         pop       es
         pop       ds
         pop       bx
         pop       ax
         ret

GenColT  ENDP

; *****************************************************************************
;
;                           Obsluha zobrazen¡
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;                 zobrazen¡ obsahu bufferu obr zku
; -----------------------------------------------------------------------------

Zobraz   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ p©esun obr zku do videopamˆti

         mov       es,ds:[SegmVRAM]         ; segment videopamˆti

         mov       ax,ds:[SklonY]
         cmp       ax,-MAXSKLON
         jg        Zobraz2
         mov       ax,-MAXSKLON
Zobraz2: cmp       ax,MAXSKLON
         jle       Zobraz3
         mov       ax,MAXSKLON

Zobraz3: mov       dx,-SIRKA
         imul      dx
         add       ax,offset BuffObr+(MAXSKLON/2)*SIRKA+MAXSKLON/2
         xchg      ax,si

         mov       ax,ds:[SklonX]
         cmp       ax,-MAXSKLON
         jg        Zobraz32
         mov       ax,-MAXSKLON
Zobraz32:cmp       ax,MAXSKLON
         jle       Zobraz33
         mov       ax,MAXSKLON

Zobraz33:push      ax
         sar       ax,1
         mov       dx,-SIRKA
         imul      dx
         add       si,ax
         pop       dx

         mov       bp,SIRKA
         mov       cx,-1
         or        dx,dx
         jns       Zobraz4
         neg       bp
         neg       dx
         neg       cx
Zobraz4: ;cmp       dx,MAXSKLON
         ;jbe       Zobraz5
         ;mov       dl,MAXSKLON

Zobraz5: mov       ax,dx
         sar       ax,1
         add       si,ax
         or        cx,cx
         js        Zobraz52
         sub       si,ax
         sub       si,ax
Zobraz52:


Zobraz34:or        si,si
         js        Zobrz342
         cmp       si,offset BuffObr
         jae       Zobraz35
Zobrz342:add       si,SIRKA
         jmp       short Zobraz34

Zobraz35:cmp       si,offset BuffObr0-VYSKAD*SIRKA
         jbe       Zobraz36
         sub       si,SIRKA
         jmp       short Zobraz35

Zobraz36:push      dx
         mov       ax,-SIRKA
         imul      dx
         imul      cx
         pop       dx

         add       ax,si
         js        Zobraz37
         cmp       ax,offset BuffObr
         jae       Zobraz38
Zobraz37:add       si,SIRKA
         jmp       short Zobraz36

Zobraz38:push      dx
         mov       ax,-SIRKA
         imul      dx
         imul      cx
         pop       dx

         add       ax,si
         cmp       ax,offset BuffObr0-VYSKAD*SIRKA
         jbe       Zobraz3a
Zobraz39:sub       si,SIRKA
         jmp       short Zobraz38

Zobraz3a:

         mov       ah,0
         mov       bh,-1
         mov       di,TOPPOZ+320*TOPLINE    ; po‡ te‡n¡ adresa obr zku

         mov       bl,VYSKAD                ; v˜¨ka obr zku (linek)
Zobraz7: mov       bh,SIRKAD                ; ¨¡©ka obr zku
         mov       dh,0
         add       ah,dl
         jnc       Zobraz72
         add       si,cx
Zobraz72:push      si
Zobraz8: movsb
         add       dh,dl
         jnc       Zobraz9
         add       si,bp
Zobraz9: dec       bh
         jnz       Zobraz8
         pop       si
         add       si,SIRKA
         add       di,POSUN+(SIRKA-SIRKAD)  ; adresa dal¨¡ linky
         dec       bl                       ; ‡¡ta‡ linek k zobrazen¡
         jnz       short Zobraz7            ; zobrazen¡ dal¨¡ linky

; ------ n vrat registr–

         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Zobraz   ENDP

; -----------------------------------------------------------------------------
;                dek¢dov n¡ oblohy a pozad¡ do bufferu
; -----------------------------------------------------------------------------
;þ
DekOblh  PROC      NEAR

; ------ maxim ln¡ zobrazen  ¨¡©ka oblohy

         mov       ax,ds:[VyskaZ]           ; aktu ln¡ v˜¨ka 1 a‘ FFFFh
         neg       ax                       ; FFFFh a‘ 1
         shr       ax,1
         shr       ax,1                     ; 3FFFh a‘ 0
         add       ax,8000h                 ; BFFFh a‘ 8000h
         mov       ds:[ReferZ],ax           ; SI <- zobrazen  ¨¡©ka BFFFh-8000h

; ------ p©¡prava ‡¡ta‡e sklonu

;         mov       cx,ds:[SklonX]
;         and       cl,not 1
;         cmp       cx,-MAXSKLON
;         jge       DekObl02
;         mov       cx,-MAXSKLON
;DekObl02:cmp       cx,MAXSKLON
;         jle       DekObl03
;         mov       cx,MAXSKLON
;DekObl03:mov       ax,SIRKA/2
;         imul      cx
;         add       ax,offset BuffObr+MAXSKLON*SIRKA/2 ; buffer k dek¢d. obr zku
;         xchg      ax,di
;         mov       bp,-SIRKA
;         or        cl,cl
;         jns       DekOblh0
;         neg       cl
;         neg       bp

; ------ p©¡prava registr– k dek¢dov n¡ oblohy

DekOblh0:cld
         push      ds
         mov       ds,ds:[SegMapO]          ; segment mapy oblohy
         mov       si,HORIZ+5               ; po‡et linek k zobrazen¡ + 5
         mov       di,offset BuffObr

; ------ v˜po‡et zobrazen‚ ¨¡©ky pole / 2 (v sou©adnic¡ch)

DekOblh1:mov       ax,es:[ReferZ]           ; AX <- zobrazen  ¨¡©ka oblohy
         xor       dx,dx                    ; DX <- 0
         div       si                       ; polovina zobrazen‚ ¨¡©ky

; ------ v˜choz¡ sou©adnice po‡ tku linky X a Y

         mov       bx,es:[AktPozX]          ; aktu ln¡ pozice X
         shr       bx,1
         shr       bx,1
         shr       bx,1
         mov       dx,es:[AktPozY]          ; aktu ln¡ pozice Y
         shr       dx,1
         shr       dx,1
         shr       dx,1
         sub       bx,ax                    ; posun X o polovinu zobraz. ¨¡©ky
         add       dx,ax                    ; posun Y o polovinu zobraz. ¨¡©ky

; ------ p©¡rustek adresy pro 1 bod

         push      cx
         push      dx

         mov       cx,32
         mul       cx
         mov       cx,SIRKA
         div       cx

         pop       dx
         pop       cx

;         shr       ax,1
;         shr       ax,1
;         shr       ax,1                     ; (polovina * 2)/256 / 16 * 256
         xchg      ax,dx                    ; DX <- p©¡rustek, AX <- pozice Y

; ------ p©epo‡et na adresu po‡ te‡n¡ho bodu v mapˆ

         push      bx                       ; pozice X

         shr       bx,1
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; BL = aktu ln¡ pozice X

         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1
         mov       bh,al                    ; BH <- aktu ln¡ pozice Y

         pop       ax                       ; pozice X
         shl       ax,1
         shl       ax,1
         shl       ax,1
         shl       ax,1
         mov       ah,al                    ; AH <- desetinn  ‡ st pozice X

; ------ dek¢dov n¡ linky oblohy

         mov       ch,0
;         push      di
         push      si
         mov       si,SIRKA
DekOblh2:mov       al,ds:[bx]
         stosb
         add       ah,dl                    ; ‡¡t n¡ p©¡rustku desetin
         adc       bl,dh                    ; zv˜¨en¡ ukazatele adresy
;         add       ch,cl                    ; ‡¡ta‡ p©¡rustku sklonu
;         jnc       DekOblh3
;         add       di,bp
DekOblh3:dec       si
         jnz       DekOblh2
         pop       si
;         pop       di
;         add       di,SIRKA

; ------ ‡¡t n¡ po‡tu linek

         dec       si
         cmp       si,5
         ja        DekOblh1                 ; dek¢dov n¡ dal¨¡ linky
         pop       ds

; ------ dek¢dov n¡ pozad¡ v d lce

         mov       ax,ColPozad*HI + ColPozad
         mov       cx,POZADL*SIRKA/2
         rep       stosw

;         mov       dx,POZADL
;DekOblh4:mov       ch,0
;         push      di
;         mov       si,256
;         mov       al,ColPozad              ; barva linek
;DekOblh5:stosb
;         add       ch,cl                    ; ‡¡ta‡ p©¡rustku sklonu
;         jnc       DekOblh6
;         add       di,bp
;DekOblh6:dec       si
;         jnz       DekOblh5
;         pop       di
;         add       di,SIRKA
;         dec       dx
;         jnz       DekOblh4
         ret

DekOblh  ENDP

; *****************************************************************************
;
;
;
; *****************************************************************************
;þ
.386c
; -----------------------------------------------------------------------------
;        obsluha my¨i a kl vesnice
; -----------------------------------------------------------------------------

l_0408   PROC      NEAR

; ------ ‡ten¡ posunu my¨i

         xor       cx,cx                    ; p©ednastaven¡ - nen¡ horiz. posun
         xor       dx,dx                    ; p©ednastaven¡ - nen¡ vert. posun
         xor       ax,ax                    ; p©ednastaven¡ - nejsou tla‡¡tka
         cmp       byte ptr ds:[d_035B],0   ; 1=p©¡znak instalace my¨i
         je        short l_0423             ; nen¡ nainstalovan  my¨

         mov       ax,3
         int       33h                      ; ‡ten¡ posunu my¨i

         sub       cx,RYCHLX/2
         sub       dx,RYCHLY/2

         sar       dx,1
         sar       dx,1
         sar       cx,1
         sar       cx,1

; ------ ‡ten¡ tla‡¡tek my¨i

l_04082: ;push      cx
         ;push      dx
         ;mov       ax,5
         ;int       33h                      ; poskytnut¡ tla‡¡tek my¨i
         ;pop       dx
         ;pop       cx

; ------ posun ukazatele aktu ln¡ pozice
;þ
l_0423:  add       cx,ds:[PosunX]
         add       dx,ds:[PosunY]

;         mov       ax,dx
;         sub       ax,ds:[PosunY0]
         mov       ds:[SklonY],dx
;         mov       ds:[PosunY0],dx
         mov       ds:[SklonX],cx           ; sklon ve smˆru X

         add       ds:[d_0351],cx           ; posun pozice my¨i X
         sub       ds:[d_0353],dx           ; posun pozice my¨i Y
         mov       cx,ds:[d_0351]           ; aktu ln¡ pozice my¨i X
         mov       dx,ds:[d_0353]           ; aktu ln¡ pozice my¨i Y
         mov       ds:[AktPozX],cx          ; aktu ln¡ pozice X
         mov       ds:[AktPozY],dx          ; aktu ln¡ pozice Y

; ------ ur‡en¡ nov‚ v˜¨ky nad ter‚nem

         call      l_105C                   ; poskytnut¡ v˜¨ky v bodˆ DX/CX->AX

         cmp       ah,ds:[Vyska0]
         jae       short l_04462
         mov       ah,ds:[Vyska0]
         mov       al,0
l_04462: add       ah,2
         jnc       short l_0446
         mov       ax,-1
l_0446:  or        ax,ax
         jnz       l_04467
         inc       ax
l_04467:
         mov       ds:[VyskaZ],ax           ; v˜¨ka nad ter‚nem Z

; ------ p©eru¨en¡ programu stiskem kl vesy

         mov       ah,1
         int       16h                      ; test kl vesnice
         jz        l_0458
         mov       byte ptr ds:[d_035F],1   ; p©¡znak p©eru¨en¡ programu
         xor       ah,ah
         int       16h                      ; vypr zdnˆn¡ bufferu kl vesnice
         push      dx
         push      cx

         mov       cx,ds:[PosunX]
         or        cx,cx
         jns       aaa12
         neg       cx
aaa12:   shr       cx,1
         shr       cx,1
         shr       cx,1
         jnz       aaa13
         inc       cx

aaa13:   mov       dx,ds:[PosunY]
         or        dx,dx
         jns       aaa14
         neg       dx
aaa14:   shr       dx,1
         shr       dx,1
         shr       dx,1
         jnz       aaa15
         inc       dx
aaa15:
         cmp       ax,4800h
         jne       aaaa1
         sub       word ptr ds:[PosunY],dx
         jmp       short aaaa32

aaaa1:   cmp       ax,5000h
         jne       aaaa2
         add       word ptr ds:[PosunY],dx
         jmp       short aaaa32

aaaa2:   cmp       ax,4b00h
         jne       aaaa3
         sub       word ptr ds:[PosunX],cx
         jmp       short aaaa32

aaaa3:   cmp       ax,4d00h
         jne       aaaa4
         add       word ptr ds:[PosunX],cx
aaaa32:  ;cmp       byte ptr ds:[Vyska0],0
         ;jne       aaaa4
         ;mov       byte ptr ds:[Vyska0],4

aaaa4:   cmp       al,27
         je        aaaa5
         dec       byte ptr ds:[d_035f]

aaaa5:   cmp       al,"+"
         jne       aaaa6
         add       byte ptr ds:[Vyska0],4
         jnc       aaaa6
         mov       byte ptr ds:[Vyska0],255

aaaa6:   cmp       al,"-"
         jne       aaaa7
         sub       byte ptr ds:[Vyska0],4
         ja        aaaa7
         mov       byte ptr ds:[Vyska0],0
;         mov       word ptr ds:[PosunX],0
;         mov       word ptr ds:[PosunY],0
;
;         push      ax
;         push      bx
;         push      cx
;         push      dx
;         push      es
;
;         mov       ax,4
;         mov       cx,RYCHLX/2
;         mov       dx,RYCHLY/2
;         int       33h
;
;         pop       es
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax

aaaa7:   call      Barvy

aaaa8:   mov       ah,1
         int       16h
         jz        aaaa9
         mov       ah,0
         int       16h
         jmp       short aaaa8

aaaa9:
         pop       cx
         pop       dx

l_0458:  ret

l_0408   ENDP

NulMous  PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx
         push      es

         mov       ax,3
         int       33h                      ; ‡ten¡ posunu my¨i
         mov       ax,4
         mov       dx,RYCHLY/2
         int       33h

         pop       es
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

NulMous  ENDP


Barvy    PROC      NEAR

         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

         mov       si,offset Slunce
         cmp       al,"0"
         je        Barvy4
         mov       si,offset Merkur
         cmp       al,"1"
         je        Barvy4
         mov       si,offset Venuse
         cmp       al,"2"
         je        Barvy4
         mov       si,offset Zeme
         cmp       al,"3"
         je        Barvy4
         mov       si,offset Mars
         cmp       al,"4"
         je        Barvy4
         mov       si,offset Jupiter
         cmp       al,"5"
         je        Barvy4
         mov       si,offset Saturn
         cmp       al,"6"
         je        Barvy4
         mov       si,offset Uran
         cmp       al,"7"
         je        Barvy4
         mov       si,offset Neptun
         cmp       al,"8"
         je        Barvy4
         mov       si,offset Pluto
         cmp       al,"9"
         je        Barvy4

         cmp       al,9
         jne       Barvy333
         mov       es,ds:[SegMapT]          ; segment mapy ter‚nu
         mov       cl,2
         call      Zjemni
         jmp       short Barvy9

Barvy333:

         cmp       al,13
         jne       Barvy9
         call      Voda
         jmp       short Barvy9

Barvy4:  mov       cx,3*97
         mov       di,offset d_020A
Barvy5:  mov       al,cs:[si]
         mov       ds:[di],al
         inc       si
         inc       di
         loop      Barvy5

         push      si
         mov       ax,13h
         int       10h

         mov       dx,12*HI + 16
         mov       ah,2
         mov       bh,0
         int       10h

         pop       si

Barvy6:  mov       al,cs:[si]
         cmp       al,0
         je        Barvy7
         inc       si
         push      si
         mov       ah,0eh
         mov       bx,7
         int       10h
         pop       si
         jmp       short Barvy6

Barvy7:
         call      GenOblh                  ; vygenerov n¡ mapy oblohy
         push      ds
         pop       es
         call      GenTern                  ; vygenerov n¡ mapy ter‚nu
         push      ds
         pop       es
         call      DekOblh                  ; dek¢dov n¡ oblohy a pozad¡
;         call      l_0A1F                   ; dek¢dov n¡ ter‚nu

         mov       si,offset d_020A         ; tabulka palet
         cli
         cld
         mov       dx,3c8h
         xor       al,al
         out       dx,al
         inc       dx
         mov       cx,3*256                 ; po‡et barev (platn‚ jen 96 barev)
         rep       outsb                    ; nastaven¡ palet barev
         sti

; ------ p©esun obr zku do videopamˆti

         call      Zobraz

Barvy9:  pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

Barvy    ENDP
;þ
; ------ p©¡prava k zaplnˆn¡ dolinky vodou

Voda:    mov       es,ds:[SegMapT]          ; segment mapy ter‚nu
         mov       fs,ds:[SegMapC]          ; barva ter‚nu
         mov       bx,ds:[AktPozX]          ; pozice X
         mov       di,ds:[AktPozY]          ; pozice Y
         shr       bx,KROKUC                ; X
         shl       di,KROKUC                ; Y
         and       di,0ff00h
         mov       bh,0
         or        di,bx
Voda11:  mov       bl,es:[di]               ; aktu ln¡ v˜¨ka

; ------ nalezen¡ nejni‘¨¡ho m¡sta

Voda12:  cmp       bl,es:[di-1]
         jbe       Voda13
         dec       di
         jmp       short Voda11

Voda13:  cmp       bl,es:[di+1]
         jbe       Voda14
         inc       di
         jmp       short Voda11

Voda14:  cmp       bl,es:[di+256]
         jbe       Voda15
         add       di,256
         jmp       short Voda11

Voda15:  cmp       bl,es:[di-256]
         jbe       Voda16
         sub       di,256
         jmp       short Voda11

Voda16:  cmp       bl,es:[di-2*256-2]
         jbe       Voda17
         sub       di,2*256+2
         jmp       short Voda11

Voda17:  cmp       bl,es:[di+2*256+2]
         jbe       Voda18
         add       di,2*256+2
         jmp       short Voda11

Voda18:  cmp       bl,es:[di-2*256+2]
         jbe       Voda19
         sub       di,2*256-2
         jmp       short Voda11

Voda19:  cmp       bl,es:[di+2*256-2]
         jbe       Voda1a
         add       di,2*256-2
         jmp       short Voda11

Voda1a:
         cmp       bl,160
         ja        Voda5
         add       bl,4                     ; asi tak v˜¨ka hladiny vody

         call      Zapln

Voda5:   ret

Zapln:   mov       cx,256
Zapln1:  cmp       byte ptr es:[di-1],bl
         ja        Zapln2
         dec       di
         loop      Zapln1

Zapln2:  mov       cx,256
Zapln3:  cmp       byte ptr es:[di],bl
         ja        Zapln9
         mov       byte ptr fs:[di],64

         cmp       sp,400
         jb        Zapln5

         cmp       byte ptr es:[di-256],bl
         ja        Zapln4
         cmp       byte ptr fs:[di-256],64
         je        Zapln4

         push      di
         push      cx
         sub       di,256
         call      Zapln
         pop       cx
         pop       di

Zapln4:

         cmp       byte ptr es:[di+256],bl
         ja        Zapln5
         cmp       byte ptr fs:[di+256],64
         je        Zapln5

         push      di
         push      cx
         add       di,256
         call      Zapln
         pop       cx
         pop       di

Zapln5:
         inc       di
         loop      Zapln3

Zapln9:  ret

Slunce   label     byte
                                          ;* 0 a‘ 63 = barva ter‚nu
         db        42,29, 4                 ; 0          0, 0, 0
         db        43,30, 5                 ; 1          0, 1, 0
         db        43,30, 5                 ; 2          0, 2, 0
         db        43,30, 5                 ; 3          0, 3, 0
         db        44,31, 6                 ; 4          1, 3, 0
         db        44,31, 6                 ; 5          0, 4, 0
         db        44,31, 6                 ; 6          0, 5, 0
         db        45,32, 7                 ; 7          0, 6, 0
         db        45,32, 7                 ; 8          0, 7, 0
         db        45,32, 7                 ; 9          0, 8, 0
         db        46,33, 8                 ; 10         0, 9, 0
         db        46,33, 8                 ; 11         0,10, 0
         db        46,33, 8                 ; 12         0,11, 0
         db        47,34, 9                 ; 13         0,12, 0
         db        47,34, 9                 ; 14         0,13, 0
         db        47,34, 9                 ; 15         0,14, 0
         db        48,35,10                 ; 16         0,15, 0
         db        48,35,10                 ; 17         0,16, 0
         db        48,35,10                 ; 18         0,17, 0
         db        49,36,11                 ; 19         0,18, 0
         db        49,36,11                 ; 20         0,19, 0
         db        49,36,11                 ; 21         0,20, 0
         db        50,37,12                 ; 22         0,21, 0
         db        50,37,12                 ; 23         0,22, 0
         db        50,37,12                 ; 24         0,23, 0
         db        51,38,13                 ; 25         0,24, 0
         db        51,38,13                 ; 26         0,25, 0
         db        51,38,13                 ; 27         0,26, 0
         db        52,39,14                 ; 28         0,27, 0
         db        52,39,14                 ; 29         0,28, 0
         db        52,39,14                 ; 30         1,29, 0
         db        53,40,15                 ; 31         2,30, 0
         db        53,40,15                 ; 32         3,31, 0
         db        53,40,15                 ; 33         4,32, 0
         db        54,41,16                 ; 34         5,33, 0
         db        54,41,16                 ; 35         6,34, 0
         db        54,41,16                 ; 36         7,35, 1
         db        55,42,17                 ; 37         8,36, 2
         db        55,42,17                 ; 38         9,37, 3
         db        55,42,17                 ; 39        10,38, 4
         db        56,43,18                 ; 40        11,39, 5
         db        56,43,18                 ; 41        12,40, 6
         db        56,43,18                 ; 42        13,41, 7
         db        57,44,19                 ; 43        14,42, 8
         db        57,44,19                 ; 44        15,43, 9
         db        57,44,19                 ; 45        16,44,10
         db        58,45,20                 ; 46        17,45,11
         db        58,45,20                 ; 47        18,46,12
         db        58,45,20                 ; 48        19,47,13
         db        59,46,21                 ; 49        20,48,14
         db        59,46,21                 ; 50        21,49,15
         db        59,46,21                 ; 51        22,50,16
         db        60,47,22                 ; 52        23,51,17
         db        60,47,22                 ; 53        24,52,18
         db        60,47,22                 ; 54        25,53,19
         db        61,48,23                 ; 55        26,54,20
         db        61,48,23                 ; 56        27,55,21
         db        61,48,23                 ; 57        28,56,22
         db        62,49,24                 ; 58        29,57,23
         db        62,49,24                 ; 59        30,58,24
         db        62,49,24                 ; 60        31,59,25
         db        63,50,25                 ; 61        32,60,26
         db        63,50,25                 ; 62        33,61,27
         db        63,50,25                 ; 63        34,62,28

                                          ;* 64 a‘ 95 = barva oblohy
         db        53,33, 5                 ; 64
         db        53,33, 5                 ; 65
         db        54,34, 6                 ; 66
         db        54,34, 6                 ; 67
         db        54,34, 6                 ; 68
         db        55,35, 7                 ; 69
         db        55,35, 7                 ; 70
         db        55,35, 7                 ; 71
         db        56,36, 8                 ; 72
         db        56,36, 8                 ; 73
         db        56,36, 8                 ; 74
         db        57,37, 9                 ; 75
         db        57,37, 9                 ; 76
         db        57,37, 9                 ; 77
         db        58,38,10                 ; 78
         db        58,38,10                 ; 79
         db        58,38,10                 ; 80 (linka horizontu)
         db        59,39,11                 ; 81
         db        59,39,11                 ; 82
         db        59,39,11                 ; 83
         db        60,40,12                 ; 84
         db        60,40,12                 ; 85
         db        60,40,12                 ; 86
         db        61,41,13                 ; 87
         db        61,41,13                 ; 88
         db        61,41,13                 ; 89
         db        62,42,14                 ; 90
         db        62,42,14                 ; 91
         db        62,42,14                 ; 92
         db        63,43,15                 ; 93
         db        63,43,15                 ; 94
         db        63,43,15                 ; 95
         db        63,44,18                 ; 96

         db        'Slunce',0

Merkur   label     byte
                                          ;* 0 a‘ 63 = barva ter‚nu
         db        22, 1, 0                 ; 0          0, 0, 0
         db        24, 2, 0                 ; 1          0, 1, 0
         db        25, 3, 0                 ; 2          0, 2, 0
         db        26, 4, 0                 ; 3          0, 3, 0
         db        27, 6, 0                 ; 4          1, 3, 0
         db        28, 7, 0                 ; 5          0, 4, 0
         db        29, 8, 0                 ; 6          0, 5, 0
         db        30, 9, 0                 ; 7          0, 6, 0
         db        31,10, 0                 ; 8          0, 7, 0
         db        32,11, 0                 ; 9          0, 8, 0
         db        33,12, 0                 ; 10         0, 9, 0
         db        34,13, 0                 ; 11         0,10, 0
         db        35,14, 0                 ; 12         0,11, 0
         db        36,15, 0                 ; 13         0,12, 0
         db        37,16, 0                 ; 14         0,13, 0
         db        38,17, 0                 ; 15         0,14, 0
         db        39,18, 0                 ; 16         0,15, 0
         db        39,19, 0                 ; 17         0,16, 0
         db        40,20, 0                 ; 18         0,17, 0
         db        40,21, 1                 ; 19         0,18, 0
         db        41,22, 1                 ; 20         0,19, 0
         db        41,23, 1                 ; 21         0,20, 0
         db        42,23, 2                 ; 22         0,21, 0
         db        42,24, 2                 ; 23         0,22, 0
         db        43,25, 2                 ; 24         0,23, 0
         db        43,25, 3                 ; 25         0,24, 0
         db        44,26, 3                 ; 26         0,25, 0
         db        44,27, 3                 ; 27         0,26, 0
         db        45,27, 4                 ; 28         0,27, 0
         db        45,28, 4                 ; 29         0,28, 0
         db        46,29, 4                 ; 30         1,29, 0
         db        46,29, 5                 ; 31         2,30, 0
         db        48,30, 5                 ; 32         3,31, 0
         db        48,31, 5                 ; 33         4,32, 0
         db        49,31, 6                 ; 34         5,33, 0
         db        49,32, 6                 ; 35         6,34, 0
         db        50,34, 6                 ; 36         7,35, 1
         db        50,34, 7                 ; 37         8,36, 2
         db        51,35, 7                 ; 38         9,37, 3
         db        51,36, 7                 ; 39        10,38, 4
         db        52,37, 8                 ; 40        11,39, 5
         db        52,37, 8                 ; 41        12,40, 6
         db        53,38, 8                 ; 42        13,41, 7
         db        53,38, 9                 ; 43        14,42, 8
         db        54,39, 9                 ; 44        15,43, 9
         db        54,39, 9                 ; 45        16,44,10
         db        55,40,10                 ; 46        17,45,11
         db        55,40,10                 ; 47        18,46,12
         db        56,41,10                 ; 48        19,47,13
         db        56,41,11                 ; 49        20,48,14
         db        57,42,11                 ; 50        21,49,15
         db        57,42,11                 ; 51        22,50,16
         db        58,43,12                 ; 52        23,51,17
         db        58,43,12                 ; 53        24,52,18
         db        59,44,12                 ; 54        25,53,19
         db        59,44,13                 ; 55        26,54,20
         db        60,45,13                 ; 56        27,55,21
         db        60,45,13                 ; 57        28,56,22
         db        61,46,14                 ; 58        29,57,23
         db        61,46,14                 ; 59        30,58,24
         db        62,47,14                 ; 60        31,59,25
         db        62,47,15                 ; 61        32,60,26
         db        63,48,15                 ; 62        33,61,27
         db        63,48,15                 ; 63        34,62,28

                                          ;* 64 a‘ 95 = barva oblohy
         db         0, 0, 0                 ; 64
         db         1, 0, 0                 ; 65
         db         2, 0, 0                 ; 66
         db         4, 0, 0                 ; 67
         db         5, 0, 0                 ; 68
         db         6, 0, 0                 ; 69
         db         7, 0, 0                 ; 70
         db         8, 0, 0                 ; 71
         db         9, 0, 0                 ; 72
         db        10, 0, 0                 ; 73
         db        11, 0, 0                 ; 74
         db        12, 0, 0                 ; 75
         db        13, 0, 0                 ; 76
         db        14, 0, 0                 ; 77
         db        15, 0, 0                 ; 78
         db        16, 1, 1                 ; 79
         db        17, 2, 2                 ; 80 (linka horizontu)
         db        18, 3, 3                 ; 81
         db        19, 4, 4                 ; 82
         db        20, 5, 5                 ; 83
         db        21, 6, 6                 ; 84
         db        22, 7, 7                 ; 85
         db        23, 8, 8                 ; 86
         db        24, 9, 9                 ; 87
         db        25,10,10                 ; 88
         db        26,11,11                 ; 89
         db        27,12,12                 ; 90
         db        28,13,13                 ; 91
         db        29,14,14                 ; 92
         db        30,15,15                 ; 93
         db        31,16,16                 ; 94
         db        32,17,17                 ; 95
         db        33,18,18                 ; 96

         db        'Merkur',0

Venuse   label     byte
                                          ;* 0 a‘ 63 = barva ter‚nu
         db         0, 0, 0                 ; 0          0, 0, 0
         db         3, 2, 0                 ; 1          0, 1, 0
         db         6, 3, 0                 ; 2          0, 2, 0
         db         9, 4, 0                 ; 3          0, 3, 0
         db        12, 5, 0                 ; 4          1, 3, 0
         db        15, 6, 0                 ; 5          0, 4, 0
         db        17, 7, 0                 ; 6          0, 5, 0
         db        19, 8, 0                 ; 7          0, 6, 0
         db        21, 9, 0                 ; 8          0, 7, 0
         db        22,10, 0                 ; 9          0, 8, 0
         db        23,10, 0                 ; 10         0, 9, 0
         db        23,11, 0                 ; 11         0,10, 0
         db        24,12, 0                 ; 12         0,11, 0
         db        24,12, 0                 ; 13         0,12, 0
         db        25,13, 0                 ; 14         0,13, 0
         db        25,13, 0                 ; 15         0,14, 0
         db        26,14, 0                 ; 16         0,15, 0
         db        26,14, 0                 ; 17         0,16, 0
         db        27,15, 0                 ; 18         0,17, 0
         db        27,15, 1                 ; 19         0,18, 0
         db        28,16, 1                 ; 20         0,19, 0
         db        28,16, 1                 ; 21         0,20, 0
         db        29,17, 2                 ; 22         0,21, 0
         db        29,18, 2                 ; 23         0,22, 0
         db        30,18, 2                 ; 24         0,23, 0
         db        31,19, 3                 ; 25         0,24, 0
         db        32,20, 3                 ; 26         0,25, 0
         db        33,20, 3                 ; 27         0,26, 0
         db        34,21, 4                 ; 28         0,27, 0
         db        35,21, 4                 ; 29         0,28, 0
         db        36,22, 4                 ; 30         1,29, 0
         db        37,23, 5                 ; 31         2,30, 0
         db        38,24, 5                 ; 32         3,31, 0
         db        39,24, 5                 ; 33         4,32, 0
         db        40,25, 6                 ; 34         5,33, 0
         db        41,26, 6                 ; 35         6,34, 0
         db        42,27, 6                 ; 36         7,35, 1
         db        43,27, 7                 ; 37         8,36, 2
         db        44,28, 7                 ; 38         9,37, 3
         db        45,29, 7                 ; 39        10,38, 4
         db        46,30, 8                 ; 40        11,39, 5
         db        47,30, 8                 ; 41        12,40, 6
         db        48,31, 8                 ; 42        13,41, 7
         db        49,32, 9                 ; 43        14,42, 8
         db        50,33, 9                 ; 44        15,43, 9
         db        51,33, 9                 ; 45        16,44,10
         db        52,34,10                 ; 46        17,45,11
         db        53,35,10                 ; 47        18,46,12
         db        54,36,10                 ; 48        19,47,13
         db        55,36,11                 ; 49        20,48,14
         db        56,37,11                 ; 50        21,49,15
         db        57,38,11                 ; 51        22,50,16
         db        58,39,12                 ; 52        23,51,17
         db        59,39,12                 ; 53        24,52,18
         db        60,40,12                 ; 54        25,53,19
         db        61,41,13                 ; 55        26,54,20
         db        62,42,13                 ; 56        27,55,21
         db        63,42,13                 ; 57        28,56,22
         db        63,43,14                 ; 58        29,57,23
         db        63,44,14                 ; 59        30,58,24
         db        63,45,14                 ; 60        31,59,25
         db        63,46,15                 ; 61        32,60,26
         db        63,47,15                 ; 62        33,61,27
         db        63,48,15                 ; 63        34,62,28

                                          ;* 64 a‘ 95 = barva oblohy
         db        30,15, 0                 ; 64
         db        31,16, 0                 ; 65
         db        32,17, 0                 ; 66
         db        34,18, 0                 ; 67
         db        35,19, 0                 ; 68
         db        36,20, 1                 ; 69
         db        37,21, 2                 ; 70
         db        38,22, 3                 ; 71
         db        39,23, 4                 ; 72
         db        40,24, 5                 ; 73
         db        41,25, 6                 ; 74
         db        42,26, 7                 ; 75
         db        43,27, 8                 ; 76
         db        44,28, 9                 ; 77
         db        45,29,10                 ; 78
         db        46,30,11                 ; 79
         db        47,31,12                 ; 80 (linka horizontu)
         db        48,32,13                 ; 81
         db        49,33,14                 ; 82
         db        50,34,15                 ; 83
         db        51,35,16                 ; 84
         db        52,36,17                 ; 85
         db        53,37,18                 ; 86
         db        54,38,19                 ; 87
         db        55,39,20                 ; 88
         db        56,40,21                 ; 89
         db        57,41,22                 ; 90
         db        58,42,23                 ; 91
         db        59,43,24                 ; 92
         db        60,44,25                 ; 93
         db        61,45,26                 ; 94
         db        62,46,27                 ; 95
         db        63,58,28                 ; 96

         db        'Venuse',0

Zeme     label     byte
                                          ;* 0 a‘ 63 = barva ter‚nu
         db         0, 0, 0                 ; 0          0, 0, 0
         db         3, 2, 0                 ; 1          0, 1, 0
         db         6, 3, 0                 ; 2          0, 2, 0
         db         9, 4, 0                 ; 3          0, 3, 0
         db        12, 5, 0                 ; 4          1, 3, 0
         db        15, 6, 0                 ; 5          0, 4, 0
         db        17, 7, 0                 ; 6          0, 5, 0
         db        19, 8, 0                 ; 7          0, 6, 0
         db        21, 9, 0                 ; 8          0, 7, 0
         db        22,10, 0                 ; 9          0, 8, 0
         db        23,10, 0                 ; 10         0, 9, 0
         db        23,11, 0                 ; 11         0,10, 0
         db        24,12, 0                 ; 12         0,11, 0
         db        24,12, 0                 ; 13         0,12, 0
         db        25,13, 0                 ; 14         0,13, 0
         db        25,13, 0                 ; 15         0,14, 0
         db        26,14, 0                 ; 16         0,15, 0
         db        26,14, 0                 ; 17         0,16, 0
         db        27,15, 0                 ; 18         0,17, 0
         db        27,15, 1                 ; 19         0,18, 0
         db        28,16, 1                 ; 20         0,19, 0
         db        28,16, 1                 ; 21         0,20, 0
         db        29,17, 2                 ; 22         0,21, 0
         db        29,18, 2                 ; 23         0,22, 0
         db        30,18, 2                 ; 24         0,23, 0
         db        31,19, 3                 ; 25         0,24, 0
         db        32,20, 3                 ; 26         0,25, 0
         db        20,20, 3                 ; 27         0,26, 0
         db        21,21, 4                 ; 28         0,27, 0
         db        21,21, 4                 ; 29         0,28, 0
         db        22,22, 4                 ; 30         1,29, 0
         db        23,23, 5                 ; 31         2,30, 0
         db        24,24, 5                 ; 32         3,31, 0
         db        24,24, 5                 ; 33         4,32, 0
         db        25,25, 6                 ; 34         5,33, 0
         db        26,26, 6                 ; 35         6,34, 0
         db        27,27, 6                 ; 36         7,35, 1
         db        27,27, 7                 ; 37         8,36, 2
         db        28,28, 7                 ; 38         9,37, 3
         db        29,29, 7                 ; 39        10,38, 4
         db        30,30, 8                 ; 40        11,39, 5
         db        30,30, 8                 ; 41        12,40, 6
         db        31,31, 8                 ; 42        13,41, 7
         db        32,32, 9                 ; 43        14,42, 8
         db        33,33, 9                 ; 44        15,43, 9
         db        33,33, 9                 ; 45        16,44,10
         db        34,34,10                 ; 46        17,45,11
         db        35,35,10                 ; 47        18,46,12
         db        36,36,10                 ; 48        19,47,13
         db        36,36,11                 ; 49        20,48,14
         db        37,37,11                 ; 50        21,49,15
         db        38,38,11                 ; 51        22,50,16
         db        39,39,12                 ; 52        23,51,17
         db        39,39,12                 ; 53        24,52,18
         db        40,40,12                 ; 54        25,53,19
         db        41,41,13                 ; 55        26,54,20
         db        42,42,13                 ; 56        27,55,21
         db        42,42,13                 ; 57        28,56,22
         db        43,43,14                 ; 58        29,57,23
         db        44,44,14                 ; 59        30,58,24
         db        45,45,14                 ; 60        31,59,25
         db        46,46,15                 ; 61        32,60,26
         db        47,47,15                 ; 62        33,61,27
         db        48,48,15                 ; 63        34,62,28

                                          ;* 64 a‘ 95 = barva oblohy
         db        10,10,50                 ; 64
         db        11,11,50                 ; 65
         db        12,12,50                 ; 66
         db        13,13,50                 ; 67
         db        14,14,50                 ; 68
         db        15,15,50                 ; 69
         db        16,16,50                 ; 70
         db        17,17,50                 ; 71
         db        18,18,50                 ; 72
         db        19,19,50                 ; 73
         db        20,20,50                 ; 74
         db        21,21,50                 ; 75
         db        22,22,50                 ; 76
         db        23,23,50                 ; 77
         db        24,24,50                 ; 78
         db        25,25,50                 ; 79
         db        26,26,50                 ; 80 (linka horizontu)
         db        27,27,50                 ; 81
         db        28,28,50                 ; 82
         db        29,29,50                 ; 83
         db        30,30,50                 ; 84
         db        31,31,50                 ; 85
         db        32,32,50                 ; 86
         db        33,33,50                 ; 87
         db        34,34,50                 ; 88
         db        35,35,50                 ; 89
         db        36,36,50                 ; 90
         db        37,37,50                 ; 91
         db        38,38,50                 ; 92
         db        39,39,50                 ; 93
         db        40,40,50                 ; 94
         db        41,41,50                 ; 95
         db        63,63,63                 ; 96

         db        'Zeme',0

Mars     label     byte
                                          ;* 0 a‘ 63 = barva ter‚nu
         db        0,0,0                    ; 0
         db        1,0,0                    ; 1
         db        2,0,0                    ; 2
         db        3,0,0                    ; 3
         db        3,1,0                    ; 4
         db        4,0,0                    ; 5
         db        5,0,0                    ; 6
         db        6,0,0                    ; 7
         db        7,0,0                    ; 8
         db        8,0,0                    ; 9
         db        9,0,0                    ; 10
         db        10,0,0                   ; 11
         db        11,0,0                   ; 12
         db        12,0,0                   ; 13
         db        13,0,0                   ; 14
         db        14,0,0                   ; 15
         db        15,0,0                   ; 16
         db        16,0,0                   ; 17
         db        17,0,0                   ; 18
         db        18,0,0                   ; 19
         db        19,0,0                   ; 20
         db        20,0,0                   ; 21
         db        21,0,0                   ; 22
         db        22,0,0                   ; 23
         db        23,0,0                   ; 24
         db        24,0,0                   ; 25
         db        25,0,0                   ; 26
         db        26,0,0                   ; 27
         db        27,0,0                   ; 28
         db        28,0,0                   ; 29
         db        29,1,0                   ; 30
         db        30,2,0                   ; 31
         db        31,3,0                   ; 32
         db        32,4,0                   ; 33
         db        33,5,0                   ; 34
         db        34,6,0                   ; 35
         db        35,7,1                   ; 36
         db        36,8,2                   ; 37
         db        37,9,3                   ; 38
         db        38,10,4                  ; 39
         db        39,11,5                  ; 40
         db        40,12,6                  ; 41
         db        41,13,7                  ; 42
         db        42,14,8                  ; 43
         db        43,15,9                  ; 44
         db        44,16,10                 ; 45
         db        45,17,11                 ; 46
         db        46,18,12                 ; 47
         db        47,19,13                 ; 48
         db        48,20,14                 ; 49
         db        49,21,15                 ; 50
         db        50,22,16                 ; 51
         db        51,23,17                 ; 52
         db        52,24,18                 ; 53
         db        53,25,19                 ; 54
         db        54,26,20                 ; 55
         db        55,27,21                 ; 56
         db        56,28,22                 ; 57
         db        57,29,23                 ; 58
         db        58,30,24                 ; 59
         db        59,31,25                 ; 60
         db        60,32,26                 ; 61
         db        61,33,27                 ; 62
         db        62,34,28                 ; 63

                                          ;* 64 a‘ 95 = barva oblohy
         db        50,10,10                 ; 64
         db        50,11,11                 ; 65
         db        50,12,12                 ; 66
         db        50,13,13                 ; 67
         db        50,14,14                 ; 68
         db        50,15,15                 ; 69
         db        50,16,16                 ; 70
         db        50,17,17                 ; 71
         db        50,18,18                 ; 72
         db        50,19,19                 ; 73
         db        50,20,20                 ; 74
         db        50,21,21                 ; 75
         db        50,22,22                 ; 76
         db        50,23,23                 ; 77
         db        50,24,24                 ; 78
         db        50,25,25                 ; 79
         db        50,26,26                 ; 80 linka horizontu
         db        50,27,27                 ; 81
         db        50,28,28                 ; 82
         db        50,29,29                 ; 83
         db        50,30,30                 ; 84
         db        50,31,31                 ; 85
         db        50,32,32                 ; 86
         db        50,33,33                 ; 87
         db        50,34,34                 ; 88
         db        50,35,35                 ; 89
         db        50,36,36                 ; 90
         db        50,37,37                 ; 91
         db        50,38,38                 ; 92
         db        50,39,39                 ; 93
         db        50,40,40                 ; 94
         db        50,41,41                 ; 95
         db        63,63,63                 ; 96

         db        'Mars',0

Jupiter  label     byte
                                          ;* 0 a‘ 63 = barva ter‚nu
         db         0, 0, 0                 ; 0          0, 0, 0
         db         3, 2, 0                 ; 1          0, 1, 0
         db         6, 3, 0                 ; 2          0, 2, 0
         db         9, 4, 0                 ; 3          0, 3, 0
         db        12, 5, 0                 ; 4          1, 3, 0
         db        15, 6, 0                 ; 5          0, 4, 0
         db        17, 7, 0                 ; 6          0, 5, 0
         db        19, 8, 0                 ; 7          0, 6, 0
         db        21, 9, 0                 ; 8          0, 7, 0
         db        22,10, 0                 ; 9          0, 8, 0
         db        23,10, 0                 ; 10         0, 9, 0
         db        23,11, 1                 ; 11         0,10, 0
         db        24,12, 2                 ; 12         0,11, 0
         db        24,12, 2                 ; 13         0,12, 0
         db        25,13, 3                 ; 14         0,13, 0
         db        25,13, 3                 ; 15         0,14, 0
         db        26,14, 4                 ; 16         0,15, 0
         db        26,14, 4                 ; 17         0,16, 0
         db        27,15, 5                 ; 18         0,17, 0
         db        27,15, 5                 ; 19         0,18, 0
         db        28,16, 6                 ; 20         0,19, 0
         db        28,16, 6                 ; 21         0,20, 0
         db        29,17, 7                 ; 22         0,21, 0
         db        29,18, 8                 ; 23         0,22, 0
         db        30,18, 8                 ; 24         0,23, 0
         db        31,19, 9                 ; 25         0,24, 0
         db        32,20,10                 ; 26         0,25, 0
         db        33,20,10                 ; 27         0,26, 0
         db        34,21,11                 ; 28         0,27, 0
         db        35,21,11                 ; 29         0,28, 0
         db        36,22,12                 ; 30         1,29, 0
         db        37,23,13                 ; 31         2,30, 0
         db        38,24,14                 ; 32         3,31, 0
         db        39,24,14                 ; 33         4,32, 0
         db        40,25,15                 ; 34         5,33, 0
         db        41,26,16                 ; 35         6,34, 0
         db        42,27,17                 ; 36         7,35, 1
         db        43,27,17                 ; 37         8,36, 2
         db        44,28,18                 ; 38         9,37, 3
         db        45,29,19                 ; 39        10,38, 4
         db        46,30,20                 ; 40        11,39, 5
         db        47,30,20                 ; 41        12,40, 6
         db        48,31,21                 ; 42        13,41, 7
         db        49,32,22                 ; 43        14,42, 8
         db        50,33,23                 ; 44        15,43, 9
         db        51,33,23                 ; 45        16,44,10
         db        52,34,24                 ; 46        17,45,11
         db        53,35,25                 ; 47        18,46,12
         db        54,36,26                 ; 48        19,47,13
         db        55,36,26                 ; 49        20,48,14
         db        56,37,27                 ; 50        21,49,15
         db        57,38,28                 ; 51        22,50,16
         db        58,39,29                 ; 52        23,51,17
         db        59,39,29                 ; 53        24,52,18
         db        60,40,30                 ; 54        25,53,19
         db        61,41,31                 ; 55        26,54,20
         db        62,42,32                 ; 56        27,55,21
         db        63,42,32                 ; 57        28,56,22
         db        63,43,33                 ; 58        29,57,23
         db        63,44,34                 ; 59        30,58,24
         db        63,45,35                 ; 60        31,59,25
         db        63,46,36                 ; 61        32,60,26
         db        63,47,37                 ; 62        33,61,27
         db        63,48,38                 ; 63        34,62,28

                                          ;* 64 a‘ 95 = barva oblohy
         db        15, 5, 0                 ; 64
         db        16, 6, 0                 ; 65
         db        17, 7, 0                 ; 66
         db        18, 8, 0                 ; 67
         db        19, 9, 0                 ; 68
         db        20,10, 1                 ; 69
         db        21,11, 2                 ; 70
         db        22,12, 3                 ; 71
         db        23,13, 4                 ; 72
         db        24,14, 5                 ; 73
         db        25,15, 6                 ; 74
         db        26,16, 7                 ; 75
         db        27,17, 8                 ; 76
         db        28,18, 9                 ; 77
         db        29,19,10                 ; 78
         db        30,20,11                 ; 79
         db        31,21,12                 ; 80 (linka horizontu)
         db        32,22,13                 ; 81
         db        33,23,14                 ; 82
         db        34,24,15                 ; 83
         db        35,25,16                 ; 84
         db        36,26,17                 ; 85
         db        37,27,18                 ; 86
         db        38,28,19                 ; 87
         db        39,29,20                 ; 88
         db        40,30,21                 ; 89
         db        41,31,22                 ; 90
         db        42,32,23                 ; 91
         db        43,33,24                 ; 92
         db        44,34,25                 ; 93
         db        45,35,26                 ; 94
         db        46,36,27                 ; 95
         db        58,48,28                 ; 96

         db        'Jupiter',0

Saturn   label     byte
                                          ;* 0 a‘ 63 = barva ter‚nu
         db         0, 0, 0                 ; 0          0, 0, 0
         db         3, 2, 0                 ; 1          0, 1, 0
         db         6, 3, 0                 ; 2          0, 2, 0
         db         9, 4, 0                 ; 3          0, 3, 0
         db        12, 5, 0                 ; 4          1, 3, 0
         db        15, 6, 0                 ; 5          0, 4, 0
         db        17, 7, 0                 ; 6          0, 5, 0
         db        19, 8, 0                 ; 7          0, 6, 0
         db        21, 9, 0                 ; 8          0, 7, 0
         db        22,10, 0                 ; 9          0, 8, 0
         db        23,10, 0                 ; 10         0, 9, 0
         db        23,11, 0                 ; 11         0,10, 0
         db        24,12, 0                 ; 12         0,11, 0
         db        24,12, 0                 ; 13         0,12, 0
         db        25,13, 0                 ; 14         0,13, 0
         db        25,13, 0                 ; 15         0,14, 0
         db        26,14, 0                 ; 16         0,15, 0
         db        26,14, 0                 ; 17         0,16, 0
         db        27,15, 0                 ; 18         0,17, 0
         db        27,15, 1                 ; 19         0,18, 0
         db        28,16, 1                 ; 20         0,19, 0
         db        28,16, 1                 ; 21         0,20, 0
         db        29,17, 2                 ; 22         0,21, 0
         db        29,18, 2                 ; 23         0,22, 0
         db        30,18, 2                 ; 24         0,23, 0
         db        31,19, 3                 ; 25         0,24, 0
         db        32,20, 3                 ; 26         0,25, 0
         db        33,20, 3                 ; 27         0,26, 0
         db        34,21, 4                 ; 28         0,27, 0
         db        35,21, 4                 ; 29         0,28, 0
         db        36,22, 4                 ; 30         1,29, 0
         db        37,23, 5                 ; 31         2,30, 0
         db        38,24, 5                 ; 32         3,31, 0
         db        39,24, 5                 ; 33         4,32, 0
         db        40,25, 6                 ; 34         5,33, 0
         db        41,26, 6                 ; 35         6,34, 0
         db        42,27, 6                 ; 36         7,35, 1
         db        43,27, 7                 ; 37         8,36, 2
         db        44,28, 7                 ; 38         9,37, 3
         db        45,29, 7                 ; 39        10,38, 4
         db        46,30, 8                 ; 40        11,39, 5
         db        47,30, 8                 ; 41        12,40, 6
         db        48,31, 8                 ; 42        13,41, 7
         db        49,32, 9                 ; 43        14,42, 8
         db        50,33, 9                 ; 44        15,43, 9
         db        51,33, 9                 ; 45        16,44,10
         db        52,34,10                 ; 46        17,45,11
         db        53,35,10                 ; 47        18,46,12
         db        54,36,10                 ; 48        19,47,13
         db        55,36,11                 ; 49        20,48,14
         db        56,37,11                 ; 50        21,49,15
         db        57,38,11                 ; 51        22,50,16
         db        58,39,12                 ; 52        23,51,17
         db        59,39,12                 ; 53        24,52,18
         db        60,40,12                 ; 54        25,53,19
         db        61,41,13                 ; 55        26,54,20
         db        62,42,13                 ; 56        27,55,21
         db        63,42,13                 ; 57        28,56,22
         db        63,43,14                 ; 58        29,57,23
         db        63,44,14                 ; 59        30,58,24
         db        63,45,14                 ; 60        31,59,25
         db        63,46,15                 ; 61        32,60,26
         db        63,47,15                 ; 62        33,61,27
         db        63,48,15                 ; 63        34,62,28

                                          ;* 64 a‘ 95 = barva oblohy
         db        30,15, 0                 ; 64
         db        31,16, 0                 ; 65
         db        32,17, 0                 ; 66
         db        34,18, 0                 ; 67
         db        35,19, 0                 ; 68
         db        36,20, 1                 ; 69
         db        37,21, 2                 ; 70
         db        38,22, 3                 ; 71
         db        39,23, 4                 ; 72
         db        40,24, 5                 ; 73
         db        41,25, 6                 ; 74
         db        42,26, 7                 ; 75
         db        43,27, 8                 ; 76
         db        44,28, 9                 ; 77
         db        45,29,10                 ; 78
         db        46,30,11                 ; 79
         db        47,31,12                 ; 80 (linka horizontu)
         db        48,32,13                 ; 81
         db        49,33,14                 ; 82
         db        50,34,15                 ; 83
         db        51,35,16                 ; 84
         db        52,36,17                 ; 85
         db        53,37,18                 ; 86
         db        54,38,19                 ; 87
         db        55,39,20                 ; 88
         db        56,40,21                 ; 89
         db        57,41,22                 ; 90
         db        58,42,23                 ; 91
         db        59,43,24                 ; 92
         db        60,44,25                 ; 93
         db        61,45,26                 ; 94
         db        62,46,27                 ; 95
         db        63,58,28                 ; 96

         db        'Saturn',0

Uran     label     byte
                                          ;* 0 a‘ 63 = barva ter‚nu
         db         0, 0, 8                 ; 0          0, 0, 0
         db         0, 0,10                 ; 1          0, 1, 0
         db         0, 0,12                 ; 2          0, 2, 0
         db         0, 0,14                 ; 3          0, 3, 0
         db         0, 0,16                 ; 4          1, 3, 0
         db         0, 0,18                 ; 5          0, 4, 0
         db         0, 0,20                 ; 6          0, 5, 0
         db         0, 0,22                 ; 7          0, 6, 0
         db         0, 1,24                 ; 8          0, 7, 0
         db         0, 2,25                 ; 9          0, 8, 0
         db         0, 3,26                 ; 10         0, 9, 0
         db         0, 4,27                 ; 11         0,10, 0
         db         0, 5,28                 ; 12         0,11, 0
         db         0, 6,29                 ; 13         0,12, 0
         db         0, 6,30                 ; 14         0,13, 0
         db         0, 8,31                 ; 15         0,14, 0
         db         0, 9,32                 ; 16         0,15, 0
         db         0,10,33                 ; 17         0,16, 0
         db         0,11,34                 ; 18         0,17, 0
         db         1,12,35                 ; 19         0,18, 0
         db         1,13,36                 ; 20         0,19, 0
         db         1,14,37                 ; 21         0,20, 0
         db         2,15,38                 ; 22         0,21, 0
         db         2,16,39                 ; 23         0,22, 0
         db         2,17,39                 ; 24         0,23, 0
         db         3,18,40                 ; 25         0,24, 0
         db         3,19,40                 ; 26         0,25, 0
         db         3,20,41                 ; 27         0,26, 0
         db         4,21,41                 ; 28         0,27, 0
         db         4,22,42                 ; 29         0,28, 0
         db         4,23,42                 ; 30         1,29, 0
         db         5,23,43                 ; 31         2,30, 0
         db         5,24,43                 ; 32         3,31, 0
         db         5,25,44                 ; 33         4,32, 0
         db         6,25,44                 ; 34         5,33, 0
         db         6,26,45                 ; 35         6,34, 0
         db         6,27,45                 ; 36         7,35, 1
         db         7,27,46                 ; 37         8,36, 2
         db         7,28,46                 ; 38         9,37, 3
         db         7,29,48                 ; 39        10,38, 4
         db         8,29,48                 ; 40        11,39, 5
         db         8,30,49                 ; 41        12,40, 6
         db         8,31,49                 ; 42        13,41, 7
         db         9,31,50                 ; 43        14,42, 8
         db         9,32,50                 ; 44        15,43, 9
         db         9,34,51                 ; 45        16,44,10
         db        10,34,51                 ; 46        17,45,11
         db        10,35,52                 ; 47        18,46,12
         db        10,36,52                 ; 48        19,47,13
         db        11,37,53                 ; 49        20,48,14
         db        11,37,53                 ; 50        21,49,15
         db        11,38,54                 ; 51        22,50,16
         db        12,38,54                 ; 52        23,51,17
         db        12,39,55                 ; 53        24,52,18
         db        12,39,55                 ; 54        25,53,19
         db        13,40,56                 ; 55        26,54,20
         db        13,40,56                 ; 56        27,55,21
         db        13,41,57                 ; 57        28,56,22
         db        14,41,57                 ; 58        29,57,23
         db        14,42,58                 ; 59        30,58,24
         db        14,42,58                 ; 60        31,59,25
         db        15,43,59                 ; 61        32,60,26
         db        15,43,59                 ; 62        33,61,27
         db        15,44,60                 ; 63        34,62,28

                                          ;* 64 a‘ 95 = barva oblohy
         db         0, 0, 0                 ; 64
         db         0, 0, 0                 ; 65
         db         0, 0, 0                 ; 66
         db         0, 0, 0                 ; 67
         db         0, 0, 0                 ; 68
         db         0, 0, 0                 ; 69
         db         0, 0, 0                 ; 70
         db         0, 0, 0                 ; 71
         db         0, 0, 0                 ; 72
         db         0, 0, 0                 ; 73
         db         0, 0, 0                 ; 74
         db         0, 0, 0                 ; 75
         db         0, 0, 0                 ; 76
         db         0, 0, 0                 ; 77
         db         0, 0, 0                 ; 78
         db         0, 0, 1                 ; 79
         db         0, 0, 2                 ; 80 (linka horizontu)
         db         0, 0, 3                 ; 81
         db         0, 0, 4                 ; 82
         db         0, 0, 5                 ; 83
         db         0, 0, 6                 ; 84
         db         0, 0, 7                 ; 85
         db         0, 0, 8                 ; 86
         db         0, 0, 9                 ; 87
         db         0, 0,10                 ; 88
         db         1, 1,11                 ; 89
         db         2, 2,12                 ; 90
         db         3, 3,13                 ; 91
         db         4, 4,14                 ; 92
         db         5, 5,15                 ; 93
         db         6, 6,16                 ; 94
         db         7, 7,17                 ; 95
         db         8, 8,18                 ; 96

         db        'Uran',0

Neptun   label     byte
                                          ;* 0 a‘ 63 = barva ter‚nu
         db         0, 1,22                 ; 0          0, 0, 0
         db         0, 2,24                 ; 1          0, 1, 0
         db         0, 3,25                 ; 2          0, 2, 0
         db         0, 4,26                 ; 3          0, 3, 0
         db         0, 6,27                 ; 4          1, 3, 0
         db         0, 7,28                 ; 5          0, 4, 0
         db         0, 8,29                 ; 6          0, 5, 0
         db         0, 9,30                 ; 7          0, 6, 0
         db         0,10,31                 ; 8          0, 7, 0
         db         0,11,32                 ; 9          0, 8, 0
         db         0,12,33                 ; 10         0, 9, 0
         db         0,13,34                 ; 11         0,10, 0
         db         0,14,35                 ; 12         0,11, 0
         db         0,15,36                 ; 13         0,12, 0
         db         0,16,37                 ; 14         0,13, 0
         db         0,17,38                 ; 15         0,14, 0
         db         0,18,39                 ; 16         0,15, 0
         db         0,19,39                 ; 17         0,16, 0
         db         0,20,40                 ; 18         0,17, 0
         db         1,21,40                 ; 19         0,18, 0
         db         1,22,41                 ; 20         0,19, 0
         db         1,23,41                 ; 21         0,20, 0
         db         2,23,42                 ; 22         0,21, 0
         db         2,24,42                 ; 23         0,22, 0
         db         2,25,43                 ; 24         0,23, 0
         db         3,25,43                 ; 25         0,24, 0
         db         3,26,44                 ; 26         0,25, 0
         db         3,27,44                 ; 27         0,26, 0
         db         4,27,45                 ; 28         0,27, 0
         db         4,28,45                 ; 29         0,28, 0
         db         4,29,46                 ; 30         1,29, 0
         db         5,29,46                 ; 31         2,30, 0
         db         5,30,48                 ; 32         3,31, 0
         db         5,31,48                 ; 33         4,32, 0
         db         6,31,49                 ; 34         5,33, 0
         db         6,32,49                 ; 35         6,34, 0
         db         6,34,50                 ; 36         7,35, 1
         db         7,34,50                 ; 37         8,36, 2
         db         7,35,51                 ; 38         9,37, 3
         db         7,36,51                 ; 39        10,38, 4
         db         8,37,52                 ; 40        11,39, 5
         db         8,37,52                 ; 41        12,40, 6
         db         8,38,53                 ; 42        13,41, 7
         db         9,38,53                 ; 43        14,42, 8
         db         9,39,54                 ; 44        15,43, 9
         db         9,39,54                 ; 45        16,44,10
         db        10,40,55                 ; 46        17,45,11
         db        10,40,55                 ; 47        18,46,12
         db        10,41,56                 ; 48        19,47,13
         db        11,41,56                 ; 49        20,48,14
         db        11,42,57                 ; 50        21,49,15
         db        11,42,57                 ; 51        22,50,16
         db        12,43,58                 ; 52        23,51,17
         db        12,43,58                 ; 53        24,52,18
         db        12,44,59                 ; 54        25,53,19
         db        13,44,59                 ; 55        26,54,20
         db        13,45,60                 ; 56        27,55,21
         db        13,45,60                 ; 57        28,56,22
         db        14,46,61                 ; 58        29,57,23
         db        14,46,61                 ; 59        30,58,24
         db        14,47,62                 ; 60        31,59,25
         db        15,47,62                 ; 61        32,60,26
         db        15,48,63                 ; 62        33,61,27
         db        15,48,63                 ; 63        34,62,28

                                          ;* 64 a‘ 95 = barva oblohy
         db         0, 0, 0                 ; 64
         db         0, 0, 0                 ; 65
         db         0, 0, 0                 ; 66
         db         0, 0, 0                 ; 67
         db         0, 0, 0                 ; 68
         db         0, 0, 0                 ; 69
         db         0, 0, 0                 ; 70
         db         0, 0, 0                 ; 71
         db         0, 0, 0                 ; 72
         db         0, 0, 0                 ; 73
         db         0, 0, 0                 ; 74
         db         0, 0, 0                 ; 75
         db         0, 0, 0                 ; 76
         db         0, 0, 0                 ; 77
         db         0, 0, 0                 ; 78
         db         1, 1, 1                 ; 79
         db         2, 2, 2                 ; 80 (linka horizontu)
         db         3, 3, 3                 ; 81
         db         4, 4, 4                 ; 82
         db         5, 5, 5                 ; 83
         db         6, 6, 6                 ; 84
         db         7, 7, 7                 ; 85
         db         8, 8, 8                 ; 86
         db         9, 9, 9                 ; 87
         db        10,10,10                 ; 88
         db        11,11,11                 ; 89
         db        12,12,12                 ; 90
         db        13,13,13                 ; 91
         db        14,14,14                 ; 92
         db        15,15,15                 ; 93
         db        16,16,16                 ; 94
         db        17,17,17                 ; 95
         db        18,18,18                 ; 96

         db        'Neptun',0

Pluto    label     byte
                                          ;* 0 a‘ 63 = barva ter‚nu
         db         1, 1, 1                 ; 0          0, 0, 0
         db         2, 2, 2                 ; 1          0, 1, 0
         db         3, 3, 3                 ; 2          0, 2, 0
         db         4, 4, 4                 ; 3          0, 3, 0
         db         6, 6, 6                 ; 4          1, 3, 0
         db         7, 7, 7                 ; 5          0, 4, 0
         db         8, 8, 8                 ; 6          0, 5, 0
         db         9, 9, 9                 ; 7          0, 6, 0
         db        10,10,10                 ; 8          0, 7, 0
         db        11,11,11                 ; 9          0, 8, 0
         db        12,12,12                 ; 10         0, 9, 0
         db        13,13,13                 ; 11         0,10, 0
         db        14,14,14                 ; 12         0,11, 0
         db        15,15,15                 ; 13         0,12, 0
         db        16,16,16                 ; 14         0,13, 0
         db        17,17,17                 ; 15         0,14, 0
         db        18,18,18                 ; 16         0,15, 0
         db        19,19,19                 ; 17         0,16, 0
         db        20,20,20                 ; 18         0,17, 0
         db        21,21,21                 ; 19         0,18, 0
         db        22,22,22                 ; 20         0,19, 0
         db        23,23,23                 ; 21         0,20, 0
         db        23,23,23                 ; 22         0,21, 0
         db        24,24,24                 ; 23         0,22, 0
         db        25,25,25                 ; 24         0,23, 0
         db        25,25,25                 ; 25         0,24, 0
         db        26,26,26                 ; 26         0,25, 0
         db        27,27,27                 ; 27         0,26, 0
         db        27,27,27                 ; 28         0,27, 0
         db        28,28,28                 ; 29         0,28, 0
         db        29,29,29                 ; 30         1,29, 0
         db        29,29,29                 ; 31         2,30, 0
         db        30,30,30                 ; 32         3,31, 0
         db        31,31,31                 ; 33         4,32, 0
         db        31,31,31                 ; 34         5,33, 0
         db        32,32,32                 ; 35         6,34, 0
         db        34,34,34                 ; 36         7,35, 1
         db        34,34,34                 ; 37         8,36, 2
         db        35,35,35                 ; 38         9,37, 3
         db        36,36,36                 ; 39        10,38, 4
         db        37,37,37                 ; 40        11,39, 5
         db        37,37,37                 ; 41        12,40, 6
         db        38,38,38                 ; 42        13,41, 7
         db        38,38,38                 ; 43        14,42, 8
         db        39,39,39                 ; 44        15,43, 9
         db        39,39,39                 ; 45        16,44,10
         db        40,40,40                 ; 46        17,45,11
         db        40,40,41                 ; 47        18,46,12
         db        41,41,42                 ; 48        19,47,13
         db        41,41,42                 ; 49        20,48,14
         db        42,42,43                 ; 50        21,49,15
         db        42,42,43                 ; 51        22,50,16
         db        43,43,44                 ; 52        23,51,17
         db        43,43,44                 ; 53        24,52,18
         db        44,44,45                 ; 54        25,53,19
         db        44,44,45                 ; 55        26,54,20
         db        45,45,46                 ; 56        27,55,21
         db        45,45,46                 ; 57        28,56,22
         db        46,46,47                 ; 58        29,57,23
         db        46,46,48                 ; 59        30,58,24
         db        47,47,49                 ; 60        31,59,25
         db        47,47,50                 ; 61        32,60,26
         db        48,48,51                 ; 62        33,61,27
         db        48,48,52                 ; 63        34,62,28

                                          ;* 64 a‘ 95 = barva oblohy
         db         0, 0, 0                 ; 64
         db         0, 0, 0                 ; 65
         db         0, 0, 0                 ; 66
         db         0, 0, 0                 ; 67
         db         0, 0, 0                 ; 68
         db         0, 0, 0                 ; 69
         db         0, 0, 0                 ; 70
         db         0, 0, 0                 ; 71
         db         0, 0, 0                 ; 72
         db         0, 0, 0                 ; 73
         db         0, 0, 0                 ; 74
         db         0, 0, 0                 ; 75
         db         0, 0, 0                 ; 76
         db         0, 0, 0                 ; 77
         db         0, 0, 0                 ; 78
         db         1, 1, 1                 ; 79
         db         2, 2, 2                 ; 80 (linka horizontu)
         db         3, 3, 3                 ; 81
         db         4, 4, 4                 ; 82
         db         5, 5, 5                 ; 83
         db         6, 6, 6                 ; 84
         db         7, 7, 7                 ; 85
         db         8, 8, 8                 ; 86
         db         9, 9, 9                 ; 87
         db        10,10,10                 ; 88
         db        11,11,11                 ; 89
         db        12,12,12                 ; 90
         db        13,13,13                 ; 91
         db        14,14,14                 ; 92
         db        15,15,15                 ; 93
         db        16,16,16                 ; 94
         db        17,17,17                 ; 95
         db        18,18,18                 ; 96

         db        'Pluto',0

; -----------------------------------------------------------------------------
;        dek¢dov n¡ ter‚nu do bufferu obr zku
; -----------------------------------------------------------------------------
;þ
l_0A1F   PROC      NEAR

; ------ inicializace bufferu star˜ch koncov˜ch pozic

         mov       fs,ds:[SegMapT]          ; segment mapy ter‚nu
         mov       gs,ds:[SegMapC]          ; segment mapy barev ter‚nu
         mov       eax,(125*HI*HI+125)*HI   ; inicializa‡n¡ sou©adnice
         mov       di,offset d_03AA         ; buffer star˜ch sou©adnic
         mov       cx,SIRKA/2
         rep       stosd                    ; inicializace bufferu star˜ch sou©.

; ------ inicializace bufferu barev star˜ch bod–

         xor       eax,eax                  ; EAX <- 0 barva
         mov       di,offset d_05AA         ; buffer barvy star˜ch bod–
         mov       cx,SIRKA/2
         rep       stosd                    ; inicializace bufferu barev

; ------ ur‡en¡ ‡¡sla linky k dek¢dov n¡

         mov       word ptr ds:[d_03A0],120 ; po‡et linek k dek¢dov n¡ * 2
l_0A48:  mov       si,ds:[d_03A0]           ; ‡¡slo dek¢dovan‚ linky * 2
         mov       si,ds:[si+d_0190]        ; koeficient vzd lenosti
         shl       si,KROKUC                ; koeficient * 16
         mov       ax,ds:[AktPozY]          ; aktu ln¡ pozice Y
         and       ax,KROKUM                ; nejni‘¨¡ 4 bity pozice Y
         xor       al,KROKUM                ; budou se ode‡¡tat
         add       si,ax                    ; vzd lenost od pozorovatele

; ------ ur‡en¡ koeficientu v˜¨ky ©ady

         mov       ax,ds:[VyskaZ]           ; v˜¨ka nad ter‚nem Z
         xor       dx,dx                    ; DX <- 0
         div       si                       ; relativn¡ v˜¨ka podle linky
         add       ax,100                   ; jak si z kladn¡ hodnota koefic.
         mov       ds:[d_03A2],ax           ; koeficient relativn¡ v˜¨ky

         xor       eax,eax                  ; EAX <- 0
         mov       ax,si                    ; AX <- ‡¡slo po‡ te‡n¡ linky
         shl       eax,6                    ; vzd lenost * 64
         mov       ds:[d_03A6],eax          ; vzd lenost * 64

; ------ korekce pro posledn¡ linku

         cmp       word ptr ds:[d_03A0],2   ; je posledn¡ linka ?
         jne       short l_0A8C             ; nen¡ posledn¡ linka
         mov       word ptr ds:[d_03A2],7d00h ; koeficient relativn¡ v˜¨ky
         mov       word ptr ds:[d_03A4],0   ;
         jmp       short l_0A96

; ------ p©¡rustek pozice Y linky v mapˆ

l_0A8C:  xor       ax,ax
         mov       dx,1                     ; zobraz¡ se 256 linek
         div       si
         mov       ds:[d_03A4],ax           ; p©¡rustek adresy linky

; ------ koeficient zmen¨en¡ v z vislosti na vzd lenosti od pozorovatele

l_0A96:  xor       ecx,ecx                  ; ECX <- 0
         mov       cx,ds:[AktPozX]          ; aktu ln¡ pozice X
         shl       ecx,16-KROKUC            ; ECX <- pozice X ^ 12
         mov       eax,ds:[d_03A6]          ; EAX <- vzd lenost * 64
         shl       eax,11-KROKUC            ; vzd lenost ^ 13
         sub       ecx,eax                  ; ECX <- koeficient zmen¨en¡

; ------ sou©adnice X a Y linky v mapˆ

         mov       dx,ds:[AktPozY]          ; aktu ln¡ pozice Y
         shl       dx,8-KROKUC              ; DH <- sou©adnice Y linky v mapˆ
         mov       ebx,ecx
         shr       ebx,16                   ; BL = sou©adnice X linky v mapˆ
         mov       bh,dh                    ; BH <- sou©adnice Y linky v mapˆ
         mov       ax,si
         shr       ax,KROKUC
         add       bh,al

; ------ p©¡prava registr– k dek¢dov n¡ jedn‚ linky (roviny)

         shr       cx,1
         mov       si,2*(SIRKA-1)           ; offset v bufferu sou©adnic a barev
         mov       word ptr ds:[d_0364],offset BuffObr ; adresa bufferu obr zku

; ------ skute‡n  v˜¨ka mezisloupe‡ku

l_0ACE:  shl       cx,1                     ; koeficient zmen¨en¡ * 2
         add       cx,word ptr ds:[d_03A6]
         adc       bl,byte ptr ds:[d_03A6+2]
         shr       cx,1                     ; n vrat koeficientu zmen¨en¡

; ------ v˜po‡et v˜¨ky aktu ln¡ho bodu interpolac¡ ze sousedn¡ch bod–

         mov       al,fs:[bx+1]             ; n sleduj¡c¡ bod
         xor       ah,ah
         sub       al,fs:[bx]               ; rozd¡l v˜¨ek s aktu ln¡m bodem
         sbb       ah,0
         imul      cx                       ; rozd¡l v˜¨ek * koeficient zmen¨en¡
         shrd      ax,dx,7                  ; / 128 p©epo‡ten¡ p©¡rustek v˜¨ky
         add       ah,fs:[bx]               ; relativn¡ v˜¨ka mezisloupe‡ku
         mul       word ptr ds:[d_03A4]     ;

; ------ ur‡en¡ koncov‚ linky k dek¢dov n¡ sloupe‡ku

         mov       di,ds:[d_03A2]           ; po‡ te‡n¡ linka k dek¢dov n¡
         sub       di,dx                    ; posun o v˜¨ku sloupe‡ku
         jns       short l_0AFE             ; podte‡en¡
         mov       di,-1                    ; omezen¡ p©i podte‡en¡
l_0AFE:  cmp       di,VYSKA                 ; maxim ln¡ ‡¡slo linky
         jl        short l_0B07             ; nen¡ p©ete‡en¡
         mov       di,VYSKA-1               ; omezen¡ p©i p©ete‡en¡

; ------ ur‡en¡ v˜¨ky sloupe‡ku a koncov‚ adresy k dek¢dov n¡

l_0B07:  mov       bp,ds:[si+d_03AA]        ; star˜ koncov˜ bod Z
         mov       ds:[si+d_03AA],di        ; £schova nov‚ koncov‚ linky Z
         sub       bp,di                    ; zobraz¡ se sloupe‡ek ?
         jns       l_101A                   ; sloupe‡ek je zezadu - nezobraz¡ se

         push      ax
         push      dx
         mov       ax,SIRKA
         mul       di
         xchg      ax,di
         pop       dx
         pop       ax

;         shl       di,8                     ; * 256 -> offset v bufferu
         add       di,word ptr ds:[d_0364]  ; p©i‡ten¡ adresy bufferu obr zku

; ------ ur‡en¡ koncov‚ barvy sloupe‡ku (CH=horizont ln¡ interpolace 0 a‘ 127)

         mov       al,gs:[bx+1]             ; barva n sleduj¡c¡ho bodu
         sub       al,gs:[bx]               ; p©¡rustek barvy od aktu ln¡ho bodu
         imul      ch                       ; p©¡m  £mˆrnost interpolace pro X
         shl       ax,1                     ; AH = rozd¡l * CH/128
         add       ah,gs:[bx]               ; koncov  barva sloupe‡ku

; ------ ur‡en¡ p©¡rustku barvy (podle d‚lky sloupe‡ku - vertik ln¡ interpolace)

         mov       dx,ax                    ; £schova nov‚ barvy
         xchg      ax,ds:[si+d_05AA]        ; buffer barvy bodu
         push      ax                       ; star  barva k zobrazen¡
         sub       ax,dx                    ; AX = - rozd¡l star‚ a nov‚ barvy
         cwd
         idiv      bp                       ; AX <- p©¡rustek barvy bodu
         pop       dx                       ; v˜choz¡ (star ) barva sloupe‡ku
         shl       bp,1                     ; d‚lka sloupe‡ku * 2 -> offset
         jmp       word ptr ds:[bp+d_00002] ; dek¢dov n¡ sloupe‡ku

; ------ dek¢dov n¡ jednoho sloupe‡ku do bufferu obr zku

l_0B3E   label     NEAR

X = VYSKA-1
         REPT      VYSKA-1
         mov       ds:[di-X*SIRKA],dh       ; ulo‘en¡ barvy bodu
         add       dx,ax                    ; posun barvy bodu
X = X-1
         ENDM
         mov       ds:[di],dh               ; posledn¡ (nejni‘¨¡) bod

; ------ p©¡prava pro dal¨¡ sloupe‡ek na lince (pokud se zobrazil)

         inc       word ptr ds:[d_0364]     ; adresa bufferu obr zku
         sub       si,2                     ; ‡¡ta‡ sloupe‡k–
         jns       l_0ACE                   ; je dal¨¡ sloupe‡ek

; ------ p©¡prava pro dal¨¡ linku

         sub       word ptr ds:[d_03A0],2   ; sn¡‘en¡ ‡¡sla dek¢dovan‚ linky * 2
         mov       si,ds:[d_03A0]           ; ‡¡slo dek¢dovan‚ linky * 2
         mov       si,ds:[si+d_0190]        ; koeficient zmen¨en¡
         test      si,3
         jnz       short l_1010
         shr       si,2
         cmp       si,0fh
         ja        short l_1010
                                          ;* tady nˆco mˆlo b˜t, ale ji‘ nen¡
l_1010:  cmp       word ptr ds:[d_03A0],0   ; jsou ji‘ v¨echny linky ?
         jne       l_0A48                   ; dek¢dov n¡ dal¨¡ linky
         ret


; ====== sloupe‡ek se nezobraz¡ (je na odlehl‚ stranˆ kopce)

; ------ ur‡en¡ koncov‚ barvy sloupe‡ku (CH=horizont ln¡ interpolace 0 a‘ 127)

l_101A:  mov       al,gs:[bx+1]             ; barva n sleduj¡c¡ho bodu
         sub       al,gs:[bx]               ; p©¡rustek barvy od aktu ln¡ho bodu
         imul      ch                       ; p©¡m  £mˆrnost interpolace pro X
         shl       ax,1                     ; AH = rozd¡l * CH/128
         add       ah,gs:[bx]               ; koncov  barva sloupe‡ku
         mov       ds:[si+d_05AA],ax        ; ulo‘en¡ koncov‚ barvy sloupe‡ku

; ------ p©¡prava pro dal¨¡ sloupe‡ek

         inc       word ptr ds:[d_0364]     ; adresa bufferu obr zku
         sub       si,2                     ; ‡¡ta‡ sloupe‡k– k zobrazen¡
         jns       l_0ACE                   ; zobrazen¡ dal¨¡ho sloupe‡ku

; ------ p©¡prava pro dal¨¡ linku

         sub       word ptr ds:[d_03A0],2   ; sn¡‘en¡ ‡¡sla dek¢dovan‚ linky * 2
         mov       si,ds:[d_03A0]           ; ‡¡slo dek¢dovan‚ linky * 2
         mov       si,ds:[si+d_0190]        ; koeficient zmen¨en¡
         test      si,3
         jnz       short l_1052
         shr       si,2
         cmp       si,0fh
         ja        short l_1052
                                          ;* tady nˆco mˆlo b˜t, ale ji‘ nen¡
l_1052:  cmp       word ptr ds:[d_03A0],0   ; ‡¡slo dek¢dovan‚ linky
         jne       l_0A48                   ; dek¢dov n¡ dal¨¡ linky
         ret

l_0A1F   ENDP

; -----------------------------------------------------------------------------
;        ur‡en¡ v˜¨ky v ter‚nu v bodˆ DX (=Y) / CX (=X) -> AX
; -----------------------------------------------------------------------------

l_105C   PROC      NEAR

; ------ adresa po‘adovan‚ pozice v mapˆ ter‚nu

         mov       fs,ds:[SegMapT]          ; segment mapy ter‚nu
         ror       cx,KROKUC                ; pozice X / 16
         ror       dx,KROKUC                ; pozice Y / 16
         mov       bl,cl                    ; pozice X
         mov       bh,dl                    ; pozice Y
         shr       cx,16-KROKUC             ; CX <- pozice X MOD 16
         shr       dx,16-KROKUC             ; DX <- pozice Y MOD 16

; ------ rozd¡l v˜¨ek mezi body ve smˆru X

         inc       bl                       ; n sleduj¡c¡ bod ve smˆru X
         mov       al,fs:[bx]               ; sou©adnice Z n sleduj¡c¡ho bodu X
         xor       ah,ah                    ; AH <- 0
         dec       bl
         sub       al,fs:[bx]               ; rozd¡l v˜¨ek Z bod–
         sbb       ah,0

; ------ interpolace ve smˆru X

         push      dx
         imul      cx                       ; rozd¡l v˜¨ek * koeficient £mˆry
         mov       dl,fs:[bx]               ; aktu ln¡ v˜¨ka bodu
         xor       dh,dh
         shl       dx,8-KROKUC              ; v˜¨ka * 16
         add       ax,dx                    ; v˜¨ka interpolovan  v X
         pop       dx
         mov       si,ax                    ; v˜¨ka * 16

; ------ rozd¡l v˜¨ek mezi body ve smˆru X pro n sleduj¡c¡ pozici Y

         inc       bh                       ; n sleduj¡c¡ pozice Y
         inc       bl                       ; n sleduj¡c¡ pozice X
         mov       al,fs:[bx]               ; sou©adnice Z p©¡‡n‚ho bodu
         xor       ah,ah
         dec       bl                       ; n vrat pozice X
         sub       al,fs:[bx]               ; rozd¡l v˜¨ek Z dal¨¡ pozice Y
         sbb       ah,0

; ------ interpolace ve smˆru X pro dal¨¡ pozici Y

         push      dx
         imul      cx                       ; rozd¡l v˜¨ek * koeficient £mˆry
         mov       dl,fs:[bx]               ; aktu ln¡ v˜¨ka bodu
         xor       dh,dh                    
         shl       dx,8-KROKUC              ; v˜¨ka * 16
         add       ax,dx                    ; v˜¨ka interpolovan  v X
         pop       dx                       
         mov       di,ax                    ; v˜¨ka * 16 dal¨¡ho bodu Y

; ------ interpolace pro aktu ln¡ pozici Y

         mov       ax,di                    ; v˜¨ka dal¨¡ho bodu Y
         sub       ax,si                    ; rozd¡l v˜¨ek pro smˆr Y
         imul      dx                       ; p©¡m  £mˆra pozici Y MOD 16
         shl       si,8-KROKUC              ; v˜¨ka * 16
         add       ax,si                    ; v˜sledn  v˜¨ka bodu
         ret

l_105C   ENDP

.8086

Code     ENDS

; *****************************************************************************
;
;                            Data
;
; *****************************************************************************
;þ
Data     SEGMENT   PARA

; ------ tabulka skok– na obsluhu zobrazen¡ vertik ln¡ ‡ ry

d_0000   label     word                     ; tabulka skok– vertik ln¡ linky
X = 0
         REPT      VYSKA
         dw        l_0B3E + X
X = X + 6
         ENDM
d_00002  label     word

; ------ tabulka koeficient– vzd lenost¡ od pozorovatele

d_0190   label     word
X = 0
         REPT      41
         dw        X
X = X + 1
         ENDM
X = 42
         REPT      10
         dw        X
X = X + 2
         ENDM

X = 64
         REPT      10
         dw        X
X = X + 4
         ENDM

; ------ definice palet barev

d_020A   label     byte

                                          ;* 0 a‘ 63 = barva ter‚nu
         db         0, 0, 0                 ; 0          0, 0, 0
         db         3, 2, 0                 ; 1          0, 1, 0
         db         6, 3, 0                 ; 2          0, 2, 0
         db         9, 4, 0                 ; 3          0, 3, 0
         db        12, 5, 0                 ; 4          1, 3, 0
         db        15, 6, 0                 ; 5          0, 4, 0
         db        17, 7, 0                 ; 6          0, 5, 0
         db        19, 8, 0                 ; 7          0, 6, 0
         db        21, 9, 0                 ; 8          0, 7, 0
         db        22,10, 0                 ; 9          0, 8, 0
         db        23,10, 0                 ; 10         0, 9, 0
         db        23,11, 0                 ; 11         0,10, 0
         db        24,12, 0                 ; 12         0,11, 0
         db        24,12, 0                 ; 13         0,12, 0
         db        25,13, 0                 ; 14         0,13, 0
         db        25,13, 0                 ; 15         0,14, 0
         db        26,14, 0                 ; 16         0,15, 0
         db        26,14, 0                 ; 17         0,16, 0
         db        27,15, 0                 ; 18         0,17, 0
         db        27,15, 1                 ; 19         0,18, 0
         db        28,16, 1                 ; 20         0,19, 0
         db        28,16, 1                 ; 21         0,20, 0
         db        29,17, 2                 ; 22         0,21, 0
         db        29,18, 2                 ; 23         0,22, 0
         db        30,18, 2                 ; 24         0,23, 0
         db        31,19, 3                 ; 25         0,24, 0
         db        32,20, 3                 ; 26         0,25, 0
         db        20,20, 3                 ; 27         0,26, 0
         db        21,21, 4                 ; 28         0,27, 0
         db        21,21, 4                 ; 29         0,28, 0
         db        22,22, 4                 ; 30         1,29, 0
         db        23,23, 5                 ; 31         2,30, 0
         db        24,24, 5                 ; 32         3,31, 0
         db        24,24, 5                 ; 33         4,32, 0
         db        25,25, 6                 ; 34         5,33, 0
         db        26,26, 6                 ; 35         6,34, 0
         db        27,27, 6                 ; 36         7,35, 1
         db        27,27, 7                 ; 37         8,36, 2
         db        28,28, 7                 ; 38         9,37, 3
         db        29,29, 7                 ; 39        10,38, 4
         db        30,30, 8                 ; 40        11,39, 5
         db        30,30, 8                 ; 41        12,40, 6
         db        31,31, 8                 ; 42        13,41, 7
         db        32,32, 9                 ; 43        14,42, 8
         db        33,33, 9                 ; 44        15,43, 9
         db        33,33, 9                 ; 45        16,44,10
         db        34,34,10                 ; 46        17,45,11
         db        35,35,10                 ; 47        18,46,12
         db        36,36,10                 ; 48        19,47,13
         db        36,36,11                 ; 49        20,48,14
         db        37,37,11                 ; 50        21,49,15
         db        38,38,11                 ; 51        22,50,16
         db        39,39,12                 ; 52        23,51,17
         db        39,39,12                 ; 53        24,52,18
         db        40,40,12                 ; 54        25,53,19
         db        41,41,13                 ; 55        26,54,20
         db        42,42,13                 ; 56        27,55,21
         db        42,42,13                 ; 57        28,56,22
         db        43,43,14                 ; 58        29,57,23
         db        44,44,14                 ; 59        30,58,24
         db        45,45,14                 ; 60        31,59,25
         db        46,46,15                 ; 61        32,60,26
         db        47,47,15                 ; 62        33,61,27
         db        48,48,15                 ; 63        34,62,28

                                          ;* 64 a‘ 95 = barva oblohy
         db        10,10,50                 ; 64
         db        11,11,50                 ; 65
         db        12,12,50                 ; 66
         db        13,13,50                 ; 67
         db        14,14,50                 ; 68
         db        15,15,50                 ; 69
         db        16,16,50                 ; 70
         db        17,17,50                 ; 71
         db        18,18,50                 ; 72
         db        19,19,50                 ; 73
         db        20,20,50                 ; 74
         db        21,21,50                 ; 75
         db        22,22,50                 ; 76
         db        23,23,50                 ; 77
         db        24,24,50                 ; 78
         db        25,25,50                 ; 79
         db        26,26,50                 ; 80 (linka horizontu)
         db        27,27,50                 ; 81
         db        28,28,50                 ; 82
         db        29,29,50                 ; 83
         db        30,30,50                 ; 84
         db        31,31,50                 ; 85
         db        32,32,50                 ; 86
         db        33,33,50                 ; 87
         db        34,34,50                 ; 88
         db        35,35,50                 ; 89
         db        36,36,50                 ; 90
         db        37,37,50                 ; 91
         db        38,38,50                 ; 92
         db        39,39,50                 ; 93
         db        40,40,50                 ; 94
         db        41,41,50                 ; 95
         db        63,63,63                 ; 96

; ------ segmenty

SegmVRAM dw        0a000h                   ; segment videopamˆti
SegMapT  dw        SEG MapaT                ; segment mapy ter‚nu
SegMapC  dw        SEG MapaC                ; segment mapy barev ter‚nu
SegMapO  dw        SEG MapaO                ; segment mapy oblohy

; ------ aktu ln¡ pozice (16 krok– = 1 bod v mapˆ ter‚nu)

d_0351   dw        ?                        ; aktu ln¡ pozice my¨i X
d_0353   dw        ?                        ; aktu ln¡ pozice my¨i Y
AktPozX  dw        ?                        ; aktu ln¡ pozice X
AktPozY  dw        ?                        ; aktu ln¡ pozice Y
VyskaZ   dw        ?                        ; v˜¨ka nad ter‚nem Z (1 a‘ FFFFh)
d_035B   db        ?                        ; 0ffh=p©¡znak instalace my¨i

ReferZ   dw        ?                        ; pomocn˜ registr zobrazen¡ oblohy
SklonX   dw        ?                        ; sklon ve smˆru X (+/-)
SklonY   dw        ?                        ; sklon ve smˆru Y
SklonY2  dw        ?                        ; st©edn¡ sklon

Vyska0   db        ?                        ; v˜¨ka nad ter‚nem

RndNum   dw        ?                        ; registr gener toru n hody
d_035F   db        ?                        ; 1=p©¡znak p©eru¨en¡ programu

d_0360   dd        ?                        ; koeficient £hlu pohledu oblohy Z
d_0364   dd        ?                        ; pozice k zobrazen¡ oblohy X
                                            ; adresa bufferu k dek¢dov n¡ obr zku
d_0368   dd        ?                        ; pozice k zobrazen¡ Y
d_03A0   dw        ?                        ; ‡¡slo dek¢dovan‚ linky
d_03A2   dw        ?
d_03A4   dw        ?
d_03A6   dd        ?

         EVEN

d_03AA   dw        SIRKA dup(?)               ; buffer sou©adnice Z sloupe‡k–
d_05AA   dw        SIRKA dup(?)               ; buffer barvy sloupe‡k–

BuffObr  db        SIRKA*VYSKA dup(?)       ; buffer k dek¢dov n¡ obr zku
BuffObr0 label     byte

POSUNX   dw        ?
POSUNY   dw        ?
POSUNY0  dw        ?                        ; uschovan  star  rychlost

Data     ENDS

; *****************************************************************************
;
;                       mapa ter‚nu (rozmˆr 256 x 256)
;
;                       1 bod v mapˆ = 16 krok– pohybu
; *****************************************************************************

MapaT    SEGMENT   PARA
         db        0ffffh dup(?)
MapaT    ENDS

; *****************************************************************************
;
;                      mapa barev ter‚nu (rozmˆr 256 x 256)
;
;                          1 bod v mapˆ = 16 krok– pohybu
; *****************************************************************************

MapaC    SEGMENT   PARA
         db        0ffffh dup(?)
MapaC    ENDS

; *****************************************************************************
;
;                        mapa oblohy (rozmˆr 256 x 256)
;
;                        1 bod v mapˆ = 16 krok– pohybu
; *****************************************************************************

MapaO    SEGMENT   PARA
         db        0ffffh dup(?)
MapaO    ENDS

; *****************************************************************************
;
;                                Z sobn¡k
;
; *****************************************************************************

Zasob    SEGMENT   STACK 'STACK'
         dw        4000h dup(?)
Zasob    ENDS

         END       Start

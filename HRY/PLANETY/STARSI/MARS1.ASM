
; -----------------------------------------------------------------------------
;
;                                 MARS 1
;
; -----------------------------------------------------------------------------

; Vyladˆno pro p©eklad pomoc¡ TASM verze 2.01 !!!!!
; Vy‘aduje k provozu procesor 386 a vy¨¨¡ !

.386c

; ------ parametry - konstanty

SIRKA    EQU       256                      ; ¨¡©ka obr zku (n sobek 4 !)
TOPPOZ   EQU       (320 - SIRKA)/2          ; po‡ te‡n¡ pozice obr zku
VYSKA    EQU       200                      ; v˜¨ka obr zku (linek)
POSUN    EQU       320 - SIRKA              ; vz jemn˜ posun adres linek

HI       EQU       256                      ; koeficient pro vy¨¨¡ bajt

RNDK1    EQU       171                      ; konstanta gener toru n hody 1
RNDK2    EQU       11213                    ; konstanta gener toru n hody 2
RNDK3    EQU       53125                    ; konstanta gener toru n hody 3
RNDK4    EQU       26562                    ; konstanta gener toru n hody 4

; *****************************************************************************
;
;                         Programov˜ segment
;
; *****************************************************************************

Code     SEGMENT   use16
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
         mov       ds:[d_035d],dx           ; inicializace gener toru n hody

; ------ inicializace videom¢du

         mov       ax,13h
         int       10h                      ; nastaven¡ videom¢du VGA

; ------ test instalace my¨i

         xor       ax,ax
         int       33h                      ; test instalace my¨i
         cmp       ax,-1                    ; je my¨ (-1=je) ?
         sete      byte ptr ds:[d_035b]     ; 1=p©¡znak instalace my¨i

; ------ inicializace palet barev

         mov       si,offset d_020A         ; tabulka palet
         cli
         mov       dx,3c8h
         xor       al,al
         out       dx,al
         inc       dx
         mov       cx,3*256                 ; po‡et barev (platn‚ jen 96 barev)
         rep       outsb                    ; nastaven¡ palet barev
         sti

; ------ zobrazen¡ zna‡ky COPYRIGHT

         mov       fs,ds:[d_033D]           ; segment videopamˆti
         mov       byte ptr fs:[0F9FFh],60h
         mov       byte ptr fs:[0F9FEh],60h
         mov       byte ptr fs:[0F9FDh],60h
         mov       byte ptr fs:[0F8BDh],60h
         mov       byte ptr fs:[0F77Dh],60h
         mov       byte ptr fs:[0F77Eh],60h
         mov       byte ptr fs:[0F77Fh],60h
         mov       byte ptr fs:[0F77Bh],60h
         mov       byte ptr fs:[0F77Ah],60h
         mov       byte ptr fs:[0F779h],60h
         mov       byte ptr fs:[0F8BAh],60h
         mov       byte ptr fs:[0F9FAh],60h
         mov       byte ptr fs:[0F9F9h],60h
         mov       byte ptr fs:[0F777h],60h
         mov       byte ptr fs:[0F776h],60h
         mov       byte ptr fs:[0F775h],60h
         mov       byte ptr fs:[0F8B6h],60h
         mov       byte ptr fs:[0F9F6h],60h

; ------ inicializace buffer– a ukazatel–

         call      l_00F3                   ; vygenerov n¡ mapy oblohy
         call      l_0153                   ; vygenerov n¡ mapy ter‚nu
         mov       byte ptr ds:[d_035f],0   ; nulov n¡ p©¡znaku p©eru¨en¡
         mov       word ptr ds:[d_0351],1000 ; aktu ln¡ pozice my¨i X
         mov       word ptr ds:[d_0353],1000 ; aktu ln¡ pozice my¨i Y

; ------ obsluha my¨i, dek¢dov n¡ obr zku

l_00BC:  call      l_0408                   ; obsluha my¨i a kl vesnice
         call      l_0459                   ; dek¢dov n¡ oblohy a pozad¡
         call      l_0A1F                   ; dek¢dov n¡ ter‚nu

; ------ p©esun obr zku do videopamˆti

         mov       si,offset d_07AA         ; buffer k dek¢dov n¡ obr zku
         mov       es,ds:[d_033D]           ; segment videopamˆti
         mov       di,TOPPOZ                ; po‡ te‡n¡ pozice obr zku
         mov       bl,VYSKA                 ; v˜¨ka obr zku (linek)
l_00D1:  mov       cx,SIRKA/4               ; ¨¡©ka obr zku ve dvouslovech
         rep       movsd                    ; p©esun jedn‚ linky obr zku
         add       di,POSUN                 ; adresa dal¨¡ linky
         dec       bl                       ; ‡¡ta‡ linek k zobrazen¡
         jnz       short l_00D1             ; zobrazen¡ dal¨¡ linky

; ------ test, zda je p©eru¨en¡ programu

         mov       es,ds:[d_0345]           ; datov˜ segment
         cmp       byte ptr ds:[d_035F],0   ; je p©eru¨en¡ programu ?
         je        short l_00BC             ; nen¡ p©eru¨en¡ programu

; ------ n vrat videom¢du

         mov       ax,3
         int       10h                      ; nastaven¡ videom¢du 3

; ------ konec programu

         mov       ax,4c00h
         int       21h

; -----------------------------------------------------------------------------
;        inicializace mapy oblohy
; -----------------------------------------------------------------------------

l_00F3   PROC      NEAR

; ------ inicializace mapy oblohy

         mov       es,ds:[d_034B]           ; segment mapy oblohy
         xor       di,di
         mov       eax,-1                   ; nulovac¡ 2-slovo
         mov       cx,4000h                 ; velikost mapy ter‚nu
         rep       stosd                    ; vymaz n¡ mapy oblohy

; ------ inicializace gener toru n hody

         mov       ax,RNDK1                 ; n hodn  konstanta
         mul       word ptr ds:[d_035D]     ; ukazatel gener toru n hody
         add       ax,RNDK2                 ; + n hodn  konstanta
         adc       dx,0
         div       word ptr ds:[d_034D]     ; dˆlen¡ konstantou RNDK3
         mov       ds:[d_035D],dx           ; ukazatel gener toru n hody
         mov       si,dx                    ; konstanta gener toru n hody

; ------ inicializace rohov˜ch a st©edn¡ch bod– oblasti

         mov       byte ptr es:[0],0        ; rohov˜ bod pro v¨echny 4 smˆry
         mov       byte ptr es:[80h],254    ; st©ed ve smˆru X
         mov       byte ptr es:[8000h],254  ; st©ed ve smˆru Y
         mov       byte ptr es:[8080h],0    ; st©ed cel‚ oblasti

; ------ inicializace mapy oblohy

         push      0                        ; sou©adnice v˜choz¡ho bodu oblasti
         push      100h                     ; rozmˆry oblasti
         call      l_0219                   ; vygenerov n¡ mapy
         add       sp,4

; ------ korekce mapy na barvu oblohy

         xor       di,di                    ; DI <- 0 ukazatel adresy v mapˆ
l_0141:  mov       al,es:[di]               ; bajt z mapy 0 a‘ 254
         shr       al,3                     ; zmen¨en¡ rozkmitu na 0 a‘ 31
         add       al,64                    ; korekce na z kladn¡ barvu oblohy
         stosb                              ; ulo‘en¡ zkorigovan‚ barvy
         or        di,di
         jnz       short l_0141             ; dek¢dov n¡ 64 KB bufferu
         mov       es,ds:[d_0345]           ; datov˜ segment
         ret

l_00F3   ENDP

; -----------------------------------------------------------------------------
;        vygenerov n¡ mapy ter‚nu a mapy barev ter‚nu
; -----------------------------------------------------------------------------

l_0153   PROC      NEAR

; ------ inicializace mapy ter‚nu (na nedefinovan‚ hodnoty)

         mov       es,ds:[d_0347]           ; segment mapy ter‚nu
         mov       fs,ds:[d_0349]           ; segment mapy barev ter‚nu
         xor       di,di                    ; DI <- 0
         mov       eax,-1                   ; nulovac¡ 2-slovo
         mov       cx,4000h                 ; velikost mapy ter‚nu
         rep       stosd                    ; inicializace mapy ter‚nu

; ------ inicializace gener toru n hody

         mov       ax,RNDK1                 ; n hodn  konstanta
         mul       word ptr ds:[d_035D]     ; ukazatel gener toru n hody
         add       ax,RNDK2                 ; + n hodn  konstanta
         adc       dx,0
         div       word ptr ds:[d_034D]     ; dˆlen¡ konstantou RNDK3
         mov       ds:[d_035D],dx           ; ukazatel gener toru n hody
         mov       si,dx                    ; konstanta gener toru n hody

; ------ vygenerov n¡ mapy ter‚nu

         mov       byte ptr es:[0],128      ; inicializace rohov˜ch bod–
         push      0                        ; sou©adnice v˜choz¡ho bodu
         push      100h                     ; v˜choz¡ ¨¡©ka oblasti
         call      l_0219                   ; vygenerov n¡ mapy ter‚nu
         add       sp,4

; ------ zjemnˆn¡ zvlnˆn¡ ter‚nu

         xor       si,si
         mov       di,ds:[d_034F]           ; DI <- 1 (index do tabulky zvlnˆn¡)
         shl       di,4                     ; DI * 16 (=16)
l_019A:  mov       bx,word ptr ds:[di+d_032F-16]
         mov       al,es:[bx+si]
         xor       ah,ah
         mov       bx,word ptr ds:[di+d_0331-16]
         add       al,es:[bx+si]
         adc       ah,0
         mov       bx,word ptr ds:[di+d_0333-16]
         add       al,es:[bx+si]
         adc       ah,0
         mov       bx,word ptr ds:[di+d_0335-16]
         add       al,es:[bx+si]
         adc       ah,0
         shr       ax,2                     ; aritmetick˜ st©ed bod– okolo
         mov       es:[si],al               ; ulo‘en¡ zjemnˆn‚ho bodu
         inc       si
         jnz       short l_019A             ; dal¨¡ bod

; ------ vygenerov n¡ mapy barev ter‚nu

         xor       si,si                    ; ukazatel v map ch
l_01CC:  mov       al,es:[si]               ; bajt z mapy ter‚nu
         xor       ah,ah
         sub       al,es:[si+3]             ; p©¡rustek v˜¨ky ter‚nu
         sbb       ah,0
         add       ax,32                    ; posun na st©edn¡ hodnotu barvy
         jns       short l_01DF             ; nen¡ podte‡en¡
         xor       ax,ax                    ; omezen¡ barvy p©i podte‡en¡

l_01DF:  cmp       ax,63                    ; je p©ete‡en¡ barvy ?
         jbe       short l_01E7             ; barva je OK
         mov       ax,63                    ; omezen¡ barvy p©i p©ete‡en¡

l_01E7:  mov       fs:[si],al               ; ulo‘en¡ barvy bodu
         inc       si
         jnz       short l_01CC             ; dal¨¡ bod

; ------ zjemnˆn¡ mapy barev ter‚nu

         xor       si,si                    ; ukazatel v mapˆ barev ter‚nu
l_01EF:  mov       al,es:[si]               ; z kladn¡ bod
         xor       ah,ah
         add       al,es:[si+1]             ; bod ve smˆru X
         adc       ah,0
         add       al,es:[si+1*HI]          ; bod ve smˆru Y
         adc       ah,0
         add       al,es:[si+1*HI+1]        ; bod ve smˆru X a Y
         adc       ah,0
         shr       ax,2                     ; aritmetick˜ st©ed bod–
         mov       es:[si],al               ; ulo‘en¡ nov‚ hodnoty bodu
         inc       si
         jnz       short l_01EF             ; zjemnˆn¡ dal¨¡ho bodu

         mov       es,ds:[d_0345]           ; datov˜ segment
         ret

l_0153   ENDP

; -----------------------------------------------------------------------------
;              vygenerov n¡ n hodn‚ mapy (ter‚nu nebo oblohy)
; -----------------------------------------------------------------------------
; VSTUP: SS:[SP+5] (1) v˜choz¡ © dek Y v segmentu mapy
;        SS:[SP+4] (1) v˜choz¡ pozice X v segmentu mapy
;        SS:[SP+2] (2) ¨¡©ka £seku oblasti ke generov n¡ (1 a‘ 256)
;        ES=segment bufferu
;        SI=st©ada‡ ‡¡sla gener toru n hody
; -----------------------------------------------------------------------------
; Pou‘it  metoda:
;  Procedura generuje n hodnou mapu ter‚nu v bufferu o matici 256 © dk– po
; 256 sloupc¡ch. P©i generov n¡ se pou‘¡vaj¡ jako v˜choz¡ rohov‚ body oblasti.
; Nejd©¡ve se vygeneruj¡ st©edov‚ body na hran ch oblasti a potom st©edov˜ bod
; ve st©edu oblasti. Potom procedura zjmen¡ krok na polovinu a vyvol  sama sebe
; (‡ty©ikr t) pro vygenerov n¡ bod– ve v¨ech ‡ty©ech vznikl˜ch kvadrantech.
; P©i generov n¡ nov‚ho st©edn¡ho bodu se vypo‡te z krajn¡ch bod– st©edn¡
; hodnota a tato hodnota se rozm¡t  n hodn˜m ‡¡slem. Velikost rozm¡t n¡ z vis¡
; na rozd¡lu hodnot krajn¡ch bod–. Na po‡ tku p©ed generov n¡m mus¡ b˜t
; cel  oblast inicializov na na hodnotu 255, kter  indikuje negenerovan˜ bajt.
; V˜sledn  vygenerovan  hodnota je omezena na rozsah 0 a‘ 254.
; -----------------------------------------------------------------------------

l_0219   PROC      NEAR

; ------ p©¡prava registr–

         mov       bp,sp
         mov       bx,ss:[bp+4]             ; v˜choz¡ pozice
         mov       cx,ss:[bp+2]             ; ¨¡©ka v˜©ezu oblasti
         shr       cx,1                     ; povolina ¨¡©ky oblasti


; ====== inicializace st©edn¡ho bodu ve smˆru X

; ------ test, zda je st©edn¡ bajt ji‘ inicializov n

         mov       dl,es:[bx]               ; v˜choz¡ hodnota bajtu
         add       bl,cl                    ; posun ve smˆru X
         mov       di,bx                    ; £schova adresy st©edn¡ho bodu
         add       bl,cl                    ; adresa koncov‚ pozice
         cmp       byte ptr es:[di],255     ; je bajt inicializov n ?
         jne       short l_0276             ; je ji‘ inicializov n

; ------ st©edn¡ hodnota krajn¡ch bod–

         xor       dh,dh                    ; DH <- 0
         add       dl,es:[bx]               ; sou‡et krajn¡ch hodnot
         adc       dh,0
         shr       dx,1                     ; st©edn¡ hodnota okraj–
         mov       ch,dl                    ; CH <- £schova st©edn¡ hodnoty

; ------ vygenerov n¡ n hodn‚ho ‡¡sla

         mov       ax,RNDK1                 ; asi tak nˆjak  konstanta
         mul       si                       ; vyn soben¡ n hodn˜m ‡¡slem
         add       ax,RNDK2                 ; + asi tak nˆjak  jin  konstanta
         adc       dx,0
         div       word ptr ds:[d_034D]     ; konstanta RNDK3 gener toru n hody
         mov       si,dx                    ; £schova konstanty pro p©¡¨tˆ
         sub       dx,RNDK4                 ; zas nˆjak  vymy¨len  konstanta

; ------ v˜po‡et n hodn‚ho zvlnˆn¡ (p©¡mo £mˆrn‚ st©edn¡ hodnotˆ)

         mov       al,cl                    ; polovina ¨¡©ky okna
         xor       ah,ah
         imul      dx                       ; * n hodn‚ ‡¡slo
         mov       al,ah                    ; AL <- n hodn‚ ‡¡slo
         mov       ah,dl                    ; AH <- st©edn¡ hodnota okraj–
         sar       ax,5                     ; AL = st©edn¡ hodnota se zvlnˆn¡m
         cbw

; ------ p©i‡ten¡ zvlnˆn¡ ke st©edn¡ hodnotˆ

         add       al,ch
         adc       ah,0
         js        short l_0271             ; podte‡en¡ ter‚nu

; ------ omezen¡ a ulo‘en¡ hodnoty bajtu mapy

         cmp       ax,254                   ; je p©ete‡en¡ hodnoty ?
         jbe       short l_0273             ; hodnota je OK
         mov       al,254                   ; omezen¡ hodnoty
         jmp       short l_0273
l_0271:  xor       al,al                    ; omezen¡ hodnoty p©i podte‡en¡
l_0273:  mov       es:[di],al               ; ulo‘en¡ hodnoty


; ====== inicializace st©edn¡ho bodu ve smˆru X a Y (1)

; ------ test, zda je st©edov˜ bajt ji‘ inicializov n

l_0276:  mov       dl,es:[bx]               ; v˜choz¡ bod intervalu
         add       bh,cl                    ; posun ve smˆru Y
         mov       di,bx                    ; £schova adresy st©edn¡ho bodu
         add       bh,cl                    ; koncov˜ bod intervalu
         cmp       byte ptr es:[di],0ffh    ; je bod ji‘ inicializov n ?
         jne       short l_02C9             ; bod je ji‘ inicializov n

; ------ st©edn¡ hodnota krajn¡ch bod–

         xor       dh,dh                    ; DH <- 0
         add       dl,es:[bx]               ; sou‡et krajn¡ch bod–
         adc       dh,0
         shr       dx,1                     ; st©edn¡ hodnota krajn¡ch bod–
         mov       ch,dl                    ; CH <- £schova st©edn¡ hodnoty

; ------ vygenerov n¡ n hodn‚ho ‡¡sla

         mov       ax,RNDK1                 ; asi tak nˆjak  konstanta
         mul       si                       ; vyn soben¡ n hodn˜m ‡¡slem
         add       ax,RNDK2                 ; + asi tak nˆjak  jin  konstanta
         adc       dx,0
         div       word ptr ds:[d_034D]     ; konstanta RNDK3 gener toru n hody
         mov       si,dx                    ; £schova konstanty pro p©¡¨tˆ
         sub       dx,RNDK4                 ; zas nˆjak  vymy¨len  konstanta

; ------ v˜po‡et n hodn‚ho zvlnˆn¡ (p©¡mo £mˆrn‚ st©edn¡ hodnotˆ)

         mov       al,cl                    ; polovina ¨¡©ky okna
         xor       ah,ah
         imul      dx                       ; * n hodn‚ ‡¡slo
         mov       al,ah                    ; AL <- n hodn‚ ‡¡slo
         mov       ah,dl                    ; AH <- st©edn¡ hodnota okraj–
         sar       ax,5                     ; AL = st©edn¡ hodnota se zvlnˆn¡m
         cbw

; ------ p©i‡ten¡ zvlnˆn¡ ke st©edn¡ hodnotˆ

         add       al,ch
         adc       ah,0
         js        short l_02C4             ; je podte‡en¡ hodnoty

; ------ omezen¡ a ulo‘en¡ hodnoty bodu mapy

         cmp       ax,254                   ; je p©ete‡en¡ hodnoty ?
         jbe       short l_02C6             ; hodnota je OK
         mov       al,254                   ; omezen¡ hodnoty
         jmp       short l_02C6
l_02C4:  xor       al,al                    ; omezen¡ hodnoty p©i podte‡en¡
l_02C6:  mov       es:[di],al               ; ulo‘en¡ hodnoty


; ====== inicializace st©edn¡ho bodu ve smˆru X a Y (2)

; ------ test, zda je st©edov˜ bajt ji‘ inicializov n

l_02C9:  mov       dl,es:[bx]               ; v˜choz¡ bod intervalu
         sub       bl,cl                    ; posun ve smˆru X zpˆt
         mov       di,bx                    ; £schova adresy st©edn¡ho bodu
         sub       bl,cl                    ; koncov˜ bod intervalu
         cmp       byte ptr es:[di],0ffh    ; je bod ji‘ inicializov n ?
         jne       short l_031C             ; bod je ji‘ inicializov n

; ------ st©edn¡ hodnota krajn¡ch bod–

         xor       dh,dh                    ; DH <- 0
         add       dl,es:[bx]               ; sou‡et krajn¡ch bod–
         adc       dh,0
         shr       dx,1                     ; st©edn¡ hodnota krajn¡ch bod–
         mov       ch,dl                    ; CH <- £schova st©edn¡ hodnoty

; ------ vygenerov n¡ n hodn‚ho ‡¡sla

         mov       ax,RNDK1                 ; asi tak nˆjak  konstanta
         mul       si                       ; vyn soben¡ n hodn˜m ‡¡slem
         add       ax,RNDK2                 ; + asi tak nˆjak  jin  konstanta
         adc       dx,0
         div       word ptr ds:[d_034D]     ; konstanta RNDK3 gener toru n hody
         mov       si,dx                    ; £schova konstanty pro p©¡¨tˆ
         sub       dx,RNDK4                 ; zas nˆjak  vymy¨len  konstanta

; ------ v˜po‡et n hodn‚ho zvlnˆn¡ (p©¡mo £mˆrn‚ st©edn¡ hodnotˆ)

         mov       al,cl                    ; polovina ¨¡©ky okna
         xor       ah,ah
         imul      dx                       ; * n hodn‚ ‡¡slo
         mov       al,ah                    ; AL <- n hodn‚ ‡¡slo
         mov       ah,dl                    ; AH <- st©edn¡ hodnota okraj–
         sar       ax,5                     ; AL = st©edn¡ hodnota se zvlnˆn¡m
         cbw

; ------ p©i‡ten¡ zvlnˆn¡ ke st©edn¡ hodnotˆ

         add       al,ch
         adc       ah,0
         js        short l_0317             ; je podte‡en¡ hodnoty

; ------ omezen¡ a ulo‘en¡ hodnoty bodu mapy

         cmp       ax,254                   ; je p©ete‡en¡ hodnoty ?
         jbe       short l_0319             ; hodnota je OK
         mov       al,254                   ; omezen¡ hodnoty
         jmp       short l_0319
l_0317:  xor       al,al                    ; omezen¡ hodnoty p©i podte‡en¡
l_0319:  mov       es:[di],al               ; ulo‘en¡ hodnoty


; ====== inicializace st©edn¡ho bodu ve smˆru X

; ------ test, zda je st©edov˜ bajt dal¨¡ linky ji‘ inicializov n

l_031C:  mov       dl,es:[bx]               ; v˜choz¡ bod intervalu
         sub       bh,cl                    ; adresa st©edu
         mov       di,bx                    ; £schova adresy st©edn¡ho bodu
         sub       bh,cl                    ; koncov˜ bod intervalu
         cmp       byte ptr es:[di],0ffh    ; je bod ji‘ inicializov n ?
         jne       short l_036F             ; bod je ji‘ inicializov n

; ------ st©edn¡ hodnota krajn¡ch bod–

         xor       dh,dh                    ; DH <- 0
         add       dl,es:[bx]               ; sou‡et krajn¡ch bod–
         adc       dh,0
         shr       dx,1                     ; st©edn¡ hodnota krajn¡ch bod–
         mov       ch,dl                    ; CH <- £schova st©edn¡ hodnoty

; ------ vygenerov n¡ n hodn‚ho ‡¡sla

         mov       ax,RNDK1                 ; asi tak nˆjak  konstanta
         mul       si                       ; vyn soben¡ n hodn˜m ‡¡slem
         add       ax,RNDK2                 ; + asi tak nˆjak  jin  konstanta
         adc       dx,0
         div       word ptr ds:[d_034D]     ; konstanta RNDK3 gener toru n hody
         mov       si,dx                    ; £schova konstanty pro p©¡¨tˆ
         sub       dx,RNDK4                 ; zas nˆjak  vymy¨len  konstanta

; ------ v˜po‡et n hodn‚ho zvlnˆn¡ (p©¡mo £mˆrn‚ st©edn¡ hodnotˆ)

         mov       al,cl                    ; polovina ¨¡©ky okna
         xor       ah,ah
         imul      dx                       ; * n hodn‚ ‡¡slo
         mov       al,ah                    ; AL <- n hodn‚ ‡¡slo
         mov       ah,dl                    ; AH <- st©edn¡ hodnota okraj–
         sar       ax,5                     ; AL = st©edn¡ hodnota se zvlnˆn¡m
         cbw

; ------ p©i‡ten¡ zvlnˆn¡ ke st©edn¡ hodnotˆ

         add       al,ch
         adc       ah,0
         js        short l_036A             ; je podte‡en¡ hodnoty

; ------ omezen¡ a ulo‘en¡ hodnoty bodu mapy

         cmp       ax,254                   ; je p©ete‡en¡ hodnoty ?
         jbe       short l_036C             ; hodnota je OK
         mov       al,254                   ; omezen¡ hodnoty
         jmp       short l_036C
l_036A:  xor       al,al                    ; omezen¡ hodnoty p©i podte‡en¡
l_036C:  mov       es:[di],al               ; ulo‘en¡ hodnoty


; ====== inicializace st©edn¡ho bodu ve st©edu oblasti

; ------ v˜po‡et st©edn¡ hodnoty cel‚ oblasti

l_036F:  mov       dl,es:[bx]               ; v˜choz¡ bod intervalu
         xor       dh,dh

         add       bl,cl
         add       bl,cl                    ; posun ve smˆru X
         add       dl,es:[bx]               ; p©i‡ten¡ bodu
         adc       dh,0

         add       bh,cl
         add       bh,cl                    ; posun ve smˆru Y
         add       dl,es:[bx]               ; p©i‡ten¡ bodu
         adc       dh,0

         sub       bl,cl                    ; posun ve smˆru X zpˆt
         sub       bl,cl
         add       dl,es:[bx]               ; p©i‡ten¡ bodu
         adc       dh,0

         shr       dx,2                     ; DL = st©edn¡ hodnota
         mov       ch,dl                    ; CH <- £schova st©edn¡ hodnoty

; ------ vygenerov n¡ n hodn‚ho ‡¡sla

         mov       ax,RNDK1                 ; asi tak nˆjak  konstanta
         mul       si                       ; vyn soben¡ n hodn˜m ‡¡slem
         add       ax,RNDK2                 ; + asi tak nˆjak  jin  konstanta
         adc       dx,0
         div       word ptr ds:[d_034D]     ; konstanta RNDK3 gener toru n hody
         mov       si,dx                    ; £schova konstanty pro p©¡¨tˆ
         sub       dx,RNDK4                 ; zas nˆjak  vymy¨len  konstanta

; ------ v˜po‡et n hodn‚ho zvlnˆn¡ (p©¡mo £mˆrn‚ st©edn¡ hodnotˆ)

         mov       al,cl                    ; polovina ¨¡©ky okna
         xor       ah,ah                    
         imul      dx                       ; * n hodn‚ ‡¡slo
         mov       al,ah                    ; AL <- n hodn‚ ‡¡slo
         mov       ah,dl                    ; AH <- st©edn¡ hodnota okraj–
         sar       ax,5                     ; AL = st©edn¡ hodnota se zvlnˆn¡m
         cbw

; ------ p©i‡ten¡ zvlnˆn¡ ke st©edn¡ hodnotˆ

         add       al,ch
         adc       ah,0
         js        short l_03CA             ; je podte‡en¡ hodnoty

; ------ omezen¡ hodnoty bodu mapy

         cmp       ax,254                   ; je p©ete‡en¡ hodnoty ?
         jbe       short l_03CC             ; hodnota je OK
         mov       al,254                   ; omezen¡ hodnoty
         jmp       short l_03CC             
l_03CA:  xor       al,al                    ; omezen¡ hodnoty p©i podte‡en¡

; ------ ulo‘en¡ bodu

l_03CC:  add       bl,cl                    ; posun ve smˆru X
         sub       bh,cl                    ; posun ve smˆru Y
         mov       es:[bx],al               ; ulo‘en¡ hodnoty bodu

; ------ p©¡prava pro zjemnˆn¡ generace

         cmp       cl,1                     ; je ji‘ minim ln¡ interval ?
         je        short l_0407             ; je ji‘ minim ln¡ interval - konec
         xor       ch,ch                    ; CH <- 0
         sub       bl,cl                    ; n vrat pozice X
         sub       bh,cl                    ; n vrat © dku Y

; ------ generov n¡ mapy ve 4 kvadrantech oblasti

         push      bx
         push      cx
         call      l_0219                   ; generov n¡ mapy v kvadrantu 1

         mov       bp,sp                    ; ukazatel dat v z sobn¡ku
         mov       cl,ss:[bp]               ; p–vodn¡ ¨¡©ka oblasti
         add       ss:[bp+2],cl             ; posun ve smˆru X
         call      l_0219                   ; generov n¡ mapy v kvadrantu 2

         mov       bp,sp                    ; ukazatel dat v z sobn¡ku
         mov       cl,ss:[bp]               ; p–vodn¡ ¨¡©ka oblasti
         add       ss:[bp+3],cl             ; posun ve smˆru Y
         call      l_0219                   ; generov n¡ mapy v kvadrantu 3

         mov       bp,sp                    ; ukazatel dat v z sobn¡ku
         mov       cl,ss:[bp]               ; p–vodn¡ ¨¡©ka oblasti
         sub       ss:[bp+2],cl             ; posun ve smˆru X zpˆt
         call      l_0219                   ; generov n¡ mapy v kvadrantu 4
         add       sp,4                     ; n vrat ukazatele z sobn¡ku

l_0407:  ret

l_0219   ENDP

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

         mov       ax,0bh
         int       33h                      ; ‡ten¡ posunu my¨i

; ------ ‡ten¡ tla‡¡tek my¨i

         push      cx
         push      dx
         mov       ax,5
         int       33h                      ; poskytnut¡ tla‡¡tek my¨i
         pop       dx
         pop       cx

; ------ posun ukazatele aktu ln¡ pozice

l_0423:  add       ds:[d_0351],cx           ; posun pozice my¨i X
         sub       ds:[d_0353],dx           ; posun pozice my¨i Y
         mov       cx,ds:[d_0351]           ; aktu ln¡ pozice my¨i X
         mov       dx,ds:[d_0353]           ; aktu ln¡ pozice my¨i Y
         mov       ds:[d_0355],cx           ; aktu ln¡ pozice X
         mov       ds:[d_0357],dx           ; aktu ln¡ pozice Y

; ------ ur‡en¡ nov‚ v˜¨ky nad ter‚nem

         call      l_105C                   ; poskytnut¡ v˜¨ky v bodˆ DX/CX->AX
         add       ah,25
         jnc       short l_0446
         mov       ax,-1
l_0446:  mov       ds:[d_0359],ax           ; v˜¨ka nad ter‚nem Z

; ------ p©eru¨en¡ programu stiskem kl vesy

         mov       ah,1
         int       16h                      ; test kl vesnice
         jz        short l_0458             ; nen¡ znak z kl vesnice
         mov       byte ptr ds:[d_035F],1   ; p©¡znak p©eru¨en¡ programu
         xor       ah,ah
         int       16h                      ; vypr zdnˆn¡ bufferu kl vesnice
l_0458:  ret

l_0408   ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ oblohy a pozad¡ do bufferu
; -----------------------------------------------------------------------------

l_0459   PROC      NEAR

; ------ p©¡prava registr–

         mov       di,offset d_07AA         ; buffer k dek¢dov n¡ obr zku
         mov       ecx,99                   ; po‡et linek k zobrazen¡

; ------ koeficient £hlu pohledu na oblohu Z

         xor       eax,eax                  ; EAX <- 0
         mov       ax,ds:[d_0359]           ; v˜¨ka nad ter‚nem Z
         neg       ax
         shr       ax,3                     ; v˜¨ka nad ter‚nem / 8
         add       ax,4000h                 ; + konstanta
         shl       eax,13
         mov       ds:[d_0360],eax          ; koeficient £hlu pohledu oblohy

; ------ pozice k zobrazen¡ oblohy X

         xor       eax,eax                  ; EAX <- 0
         mov       ax,ds:[d_0355]           ; aktu ln¡ pozice X
         shl       eax,9                    ; pozice oblohy X * 512
         mov       ds:[d_0364],eax          ; pozice k zobrazen¡ X

; ------ pozice k zobrazen¡ oblohy Y

         xor       eax,eax                  ; EAX <- 0
         mov       ax,ds:[d_0357]           ; aktu ln¡ pozice Y
         shl       eax,9                    ; pozice oblohy Y * 512
         mov       ds:[d_0368],eax          ; pozice k zobrazen¡ Y

; ------ p©¡prava registr– k dek¢dov n¡ oblohy

         push      ds
         mov       gs,ds:[d_0345]           ; datov˜ segment
         mov       ds,ds:[d_034B]           ; segment mapy oblohy

; ------ v˜po‡et sou©adnice a p©¡rustku sou©adnic

l_049D:  mov       eax,gs:[d_0360]          ; koeficient £hlu pohledu oblohy
         xor       edx,edx                  ; EDX <- 0
         div       ecx                      ; koeficient £hlu / vzd lenost

         mov       esi,gs:[d_0364]          ; pozice k zobrazen¡ X
         mov       ebp,gs:[d_0368]          ; pozice k zobrazen¡ Y
         sub       esi,eax                  ; sou©adnice X bodu
         add       ebp,eax                  ; v˜choz¡ pozice k zobrazen¡ Y
         shr       eax,7                    ; EAX = p©¡rustek adresy bodu
         mov       bx,si                    ; sou©adnice X (desetinn  ‡ st)
         shr       esi,16                   ; SI <- sou©adnice X (cel  ‡ st)
         and       si,0ffh                  ; sou©adnice X (cel  ‡ st)
         shr       ebp,8                    ; sou©adnice Y
         and       bp,0ff00h                ; sou©adnice Y * 255
         or        si,bp                    ; adresa bodu v mapˆ
         mov       ebp,eax                  ; p©¡rustek adresy LOW a HIGH
         shr       ebp,16                   ; BP <- vy¨¨¡ slovo EBP
         dec       bp                       ; cel  ‡ st p©¡rustku adresy - 1

; ------ dek¢dov n¡ linky oblohy

         movsb                              ; prvn¡ bod
         REPT      255
         add       bx,ax                    ; p©¡rustek adresy bodu (desetiny)
         adc       si,bp                    ; p©¡rustek adresy bodu (cel  ‡ st)
         movsb                              ; p©enos bodu
         ENDM

; ------ ‡¡t n¡ po‡tu linek

         dec       cl                       ; ‡¡ta‡ po‡tu linek
         jnz       l_049D                   ; dek¢dov n¡ dal¨¡ linky
         pop       ds

; ------ dek¢dov n¡ linky horizontu

         mov       eax,((((80*HI)+80)*HI+80)*HI+80) ; barva linky horizontu
         mov       cx,SIRKA/4
         rep       stosd                    ; z pis linky horizontu

; ------ p©¡prava registr– pro dek¢dov n¡ pozad¡

         mov       si,ds:[d_0359]           ; v˜¨ka nad ter‚nem Z
         shr       si,1                     ; v˜¨ka / 2
         add       si,10
         mov       bx,4                     ; ukazatel ‡¡sla linky

; ------ ur‡en¡ barvy linky pozad¡

l_09F5:  mov       ax,si                    ; ukazatel v˜¨ky
         xor       dx,dx
         div       bx                       ; p©¡rustek barvy
         shr       ax,7                     ; p©¡rustek / 128
         cmp       ax,63                    ; je barva OK ?
         jbe       short l_0A05             ; barva je OK
         mov       al,63                    ; omezen¡ ‡¡sla barvy

; ------ z pis linky pozad¡

l_0A05:  mov       ah,al                    ; barva k z pisu
         mov       dl,al                    ; £schova barvy k z pisu
         shl       eax,16                   ; rotace barvy do EAX HIGH
         mov       al,dl                    ; barva k z pisu
         mov       ah,al
         mov       cx,SIRKA/4
         rep       stosd                    ; z pis linky pozad¡
         inc       bl                       ; ‡¡ta‡ linek
         cmp       bl,44                    ; po‡et linek
         jne       l_09F5                   ; dek¢dov n¡ dal¨¡ linky
         ret

l_0459   ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ ter‚nu do bufferu obr zku
; -----------------------------------------------------------------------------

l_0A1F   PROC      NEAR

; ------ inicializace bufferu star˜ch koncov˜ch pozic

         mov       fs,ds:[d_0347]           ; segment mapy ter‚nu
         mov       gs,ds:[d_0349]           ; segment mapy barev ter‚nu
         mov       eax,(125*HI*HI+125)*HI   ; inicializa‡n¡ sou©adnice
         mov       di,offset d_03AA         ; buffer star˜ch sou©adnic
         mov       cx,80h
         rep       stosd                    ; inicializace bufferu star˜ch sou©.

; ------ inicializace bufferu barev star˜ch bod–

         xor       eax,eax                  ; EAX <- 0 barva
         mov       di,offset d_05AA         ; buffer barvy star˜ch bod–
         mov       cx,80h
         rep       stosd                    ; inicializace bufferu barev

; ------ ur‡en¡ ‡¡sla linky k dek¢dov n¡

         mov       word ptr ds:[d_03A0],120 ; po‡et linek k dek¢dov n¡ * 2
l_0A48:  mov       si,ds:[d_03A0]           ; ‡¡slo dek¢dovan‚ linky * 2
         mov       si,ds:[si+d_0190]        ; koeficient vzd lenosti
         shl       si,4                     ; koeficient * 16
         mov       ax,ds:[d_0357]           ; aktu ln¡ pozice Y
         and       ax,0fh                   ; nejni‘¨¡ 4 bity pozice Y
         xor       al,0fh                   ; budou se ode‡¡tat
         add       si,ax                    ; vzd lenost od pozorovatele

; ------ ur‡en¡ koeficientu v˜¨ky ©ady

         mov       ax,ds:[d_0359]           ; v˜¨ka nad ter‚nem Z
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
         mov       word ptr ds:[d_03A4],0   ; p©¡rustek adresy linky
         jmp       short l_0A96

; ------ p©¡rustek pozice Y linky v mapˆ

l_0A8C:  xor       ax,ax
         mov       dx,1                     ; zobraz¡ se 256 linek
         div       si
         mov       ds:[d_03A4],ax           ; p©¡rustek adresy linky

; ------ koeficient zmen¨en¡ v z vislosti na vzd lenosti od pozorovatele

l_0A96:  xor       ecx,ecx                  ; ECX <- 0
         mov       cx,ds:[d_0355]           ; aktu ln¡ pozice X
         shl       ecx,12                   ; ECX <- pozice X ^ 12
         mov       eax,ds:[d_03A6]          ; EAX <- vzd lenost * 64
         shl       eax,7                    ; vzd lenost ^ 13
         sub       ecx,eax                  ; ECX <- koeficient zmen¨en¡

; ------ sou©adnice X a Y linky v mapˆ

         mov       dx,ds:[d_0357]           ; aktu ln¡ pozice Y
         shl       dx,4                     ; DH <- sou©adnice Y linky v mapˆ
         mov       ebx,ecx
         shr       ebx,16                   ; BL = sou©adnice X linky v mapˆ
         mov       bh,dh                    ; BH <- sou©adnice Y linky v mapˆ
         mov       ax,si
         shr       ax,4
         add       bh,al

; ------ p©¡prava registr– k dek¢dov n¡ jedn‚ linky (roviny)

         shr       cx,1
         mov       si,2*255                 ; offset v bufferu sou©adnic a barev
         mov       word ptr ds:[d_0364],offset d_07AA ; adresa bufferu obr zku

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
         mul       word ptr ds:[d_03A4]     ; p©¡rustek adresy linky

; ------ ur‡en¡ koncov‚ linky k dek¢dov n¡ sloupe‡ku

         mov       di,ds:[d_03A2]           ; po‡ te‡n¡ linka k dek¢dov n¡
         sub       di,dx                    ; posun o v˜¨ku sloupe‡ku
         jns       short l_0AFE             ; podte‡en¡
         mov       di,-1                    ; omezen¡ p©i podte‡en¡
l_0AFE:  cmp       di,200                   ; maxim ln¡ ‡¡slo linky
         jl        short l_0B07             ; nen¡ p©ete‡en¡
         mov       di,199                   ; omezen¡ p©i p©ete‡en¡

; ------ ur‡en¡ v˜¨ky sloupe‡ku a koncov‚ adresy k dek¢dov n¡

l_0B07:  mov       bp,ds:[si+d_03AA]        ; star˜ koncov˜ bod Z
         mov       ds:[si+d_03AA],di        ; £schova nov‚ koncov‚ linky Z
         sub       bp,di                    ; zobraz¡ se sloupe‡ek ?
         jns       l_101A                   ; sloupe‡ek je zezadu - nezobraz¡ se
         shl       di,8                     ; * 256 -> offset v bufferu
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

X = 199
         REPT      199
         mov       ds:[di-X*256],dh         ; ulo‘en¡ barvy bodu
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

         mov       fs,ds:[d_0347]           ; segment mapy ter‚nu
         ror       cx,4                     ; pozice X / 16
         ror       dx,4                     ; pozice Y / 16
         mov       bl,cl                    ; pozice X
         mov       bh,dl                    ; pozice Y
         shr       cx,12                    ; CX <- pozice X MOD 16
         shr       dx,12                    ; DX <- pozice Y MOD 16

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
         shl       dx,4                     ; v˜¨ka * 16
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
         shl       dx,4                     ; v˜¨ka * 16
         add       ax,dx                    ; v˜¨ka interpolovan  v X
         pop       dx                       
         mov       di,ax                    ; v˜¨ka * 16 dal¨¡ho bodu Y

; ------ interpolace pro aktu ln¡ pozici Y

         mov       ax,di                    ; v˜¨ka dal¨¡ho bodu Y
         sub       ax,si                    ; rozd¡l v˜¨ek pro smˆr Y
         imul      dx                       ; p©¡m  £mˆra pozici Y MOD 16
         shl       si,4                     ; v˜¨ka * 16
         add       ax,si                    ; v˜sledn  v˜¨ka bodu
         ret

l_105C   ENDP

Code     ENDS

; *****************************************************************************
;
;                            Data
;
; *****************************************************************************
;þ
Data     SEGMENT   PARA use16

; ------ tabulka skok– na obsluhu zobrazen¡ vertik ln¡ ‡ ry

d_0000   label     word                     ; tabulka skok– vertik ln¡ linky
X = 0
         REPT      200
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

d_032D   dw        309dh

; ------ offset pro zjemnˆn¡ zvlnˆn¡ ter‚nu

d_032F   db        0,0
d_0331   db        4,0
d_0333   db        2,2
d_0335   db        -1,-2

d_0337   db        0,0,0,0,0,0

; ------ segmentov‚ adresy

d_033D   dw        0a000h                   ; segment videopamˆti
         dw        0                        ; segment 0
         dw        40h                      ; segment dat BIOS
d_0343   dw        SEG Code                 ; programov˜ segment
d_0345   dw        SEG Data                 ; datov˜ segment
d_0347   dw        SEG Mapa1                ; segment mapy ter‚nu
d_0349   dw        SEG Mapa2                ; segment mapy barev ter‚nu
d_034B   dw        SEG Mapa3                ; segment mapy oblohy

d_034D   dw        RNDK3                    ; konstanta pro gener tor n hody
d_034F   dw        1

; ------ aktu ln¡ pozice (16 krok– = 1 bod v mapˆ ter‚nu)

d_0351   dw        ?                        ; aktu ln¡ pozice my¨i X
d_0353   dw        ?                        ; aktu ln¡ pozice my¨i Y
d_0355   dw        ?                        ; aktu ln¡ pozice X
d_0357   dw        ?                        ; aktu ln¡ pozice Y
d_0359   dw        ?                        ; v˜¨ka nad ter‚nem Z
d_035B   db        ?                        ; 0ffh=p©¡znak instalace my¨i
         db        ?
d_035D   dw        ?                        ; registr gener toru n hody
d_035F   db        ?                        ; 1=p©¡znak p©eru¨en¡ programu

d_0360   dd        ?                        ; koeficient £hlu pohledu oblohy Z
d_0364   dd        ?                        ; pozice k zobrazen¡ oblohy X
                                            ; adresa bufferu k dek¢dov n¡ obr zku
d_0368   dd        ?                        ; pozice k zobrazen¡ Y
         dd        13 dup(?)
d_03A0   dw        ?                        ; ‡¡slo dek¢dovan‚ linky
d_03A2   dw        ?                        ; koeficient relativn¡ v˜¨ky
d_03A4   dw        ?                        ; p©¡rustek adresy linky
d_03A6   dd        ?
d_03AA   dw        256 dup(?)               ; buffer sou©adnice Z sloupe‡k–
d_05AA   dw        256 dup(?)               ; buffer barvy sloupe‡k–

d_07AA   db        SIRKA*VYSKA dup(?)       ; buffer k dek¢dov n¡ obr zku

Data     ENDS

; *****************************************************************************
;
;                       mapa ter‚nu (rozmˆr 256 x 256)
;
;                       1 bod v mapˆ = 16 krok– pohybu
; *****************************************************************************

Mapa1    SEGMENT   PARA use16
         db        0ffffh dup(?)
Mapa1    ENDS

; *****************************************************************************
;
;                      mapa barev ter‚nu (rozmˆr 256 x 256)
;
;                          1 bod v mapˆ = 16 krok– pohybu
; *****************************************************************************

Mapa2    SEGMENT   PARA use16
         db        0ffffh dup(?)
Mapa2    ENDS

; *****************************************************************************
;
;                        mapa oblohy (rozmˆr 256 x 256)
;
;                        1 bod v mapˆ = 16 krok– pohybu
; *****************************************************************************

Mapa3    SEGMENT   PARA use16
         db        0ffffh dup(?)
Mapa3    ENDS

; *****************************************************************************
;
;                                Z sobn¡k
;
; *****************************************************************************

Zasob    SEGMENT   STACK 'STACK' use16
         dw        200h dup(?)
Zasob    ENDS

         END       Start

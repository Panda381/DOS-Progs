

; ****************************************************************************
;             Grafickò driver karty VGA pro program KONTEXT.COM
;              po p©ekladu od adresy 0 m† soubor jmÇno VGA.OVL
; ****************************************************************************

code     SEGMENT   page
         ASSUME    cs:code,ds:code

         ORG       0                        ; poá†teán° adresa driveru

start:                                      ; vstup do driveru

ega      PROC      FAR                      ; vstupn° bod do driveru
                                            ; - á°slo funkce je v BX
         push      ds
         mov       dx,cs
         mov       ds,dx                    ; datovò segment = program. segment
         shl       bx,1                     ; á°slo funkce BX * 2
         call      word ptr ds:[bx+adrsub]  ; vyvol†n° podprogramu podle tabulky
         pop       ds
         ret                                ; n†vrat z driveru RET FAR

ega      ENDP

tabega   db        0
         db        3                        ; poáet fontñ
         db        8                        ; font 8x8
         dw        fnt8x8
         db        14                       ; font 14x8
         dw        fnt14x8
         db        19
         dw        fnt19x8

karta    db        'VGA/EGA/CGA/HGC'        ; identifikace karty EGA

TypCard  db        0                        ; typ videokarty
                                            ;   1=HGC (Hercules)
                                            ;   2=CGA
                                            ;   3=EGA
                                            ;   4=VGA

chrbuf   db        0,0,0,0,0,0,0,0,0,0      ; buffer pro vòstup znaku
         db        0,0,0,0,0,0,0,0,0,0
         db        0,0,0,0,0,0,0,0,0,0      ; prav† polovina ®irokÇho znaku
         db        0,0,0,0,0,0,0,0,0,0

invmsk   db        0                        ; maska znakñ (pro inverzi)
whide    db        0                        ; p©°znak dvojn†sobnÇ ®°©ky znaku
mode     db        0                        ; reëim obrazovky (1,2,3)
vyska    db        0                        ; poáet linek na textovò ©†dek

planng   db        0                        ; roviny pro negaci znaku (kurzor)
planes   db        0                        ; roviny EGA pro vòstup znaku

adrrow   dw        82 DUP (0)               ; tabulka adres ©†dkñ na displeji

                                            ; ADRESY PODPROGRAM¶
adrsub   dw        offset fnc00             ; funkce 00 - vòstup znaku
         dw        offset fnc01             ; funkce 01 - kurzor, maz†n°
         dw        offset fnc02             ; funkce 02 - rolov†n° nahoru
         dw        offset fnc03             ; funkce 03 - rolov†n° dolñ
         dw        offset fnc04             ; funkce 04 - pravò okraj (á†ra)
         dw        offset fnc05             ; funkce 05 - inicializace parametrñ
         dw        offset fnc06             ; funkce 06 - nastaven° text. m¢du
         dw        offset fnc07             ; funkce 07 - adr. n†povàdy (ES:SI)
         dw        offset fnc08             ; funkce 08 - adr. chybovòch hl†®en°
         dw        offset fnc09             ; funkce 09 - rozdàlov†n° slov
         dw        offset fnc10             ; funkce 10 - dek¢dov†n° k¢du kl†ves
         dw        offset fnc11             ; funkce 11 - vòpis k¢du kl†vesy



                                            ; zdvojn†soben° ®°©ky znaku
                                            ; VSTUP SI=adresa, CX=poáet linek
widchr:  push      si                       ; adresa znaku v bufferu
widch1:  mov       bh,8                     ; poáet bitñ znaku = 8
         mov       al,[si]                  ; linka znaku
widch2:  shr       al,1                     ; rotace linky vpravo, kopie do CF
         rcr       dx,1                     ; rotace bitu CF do reg. DX
         sar       dx,1                     ; rotace vpravo ze znamÇnkovÇho bitu
         dec       bh                       ; á°taá bitñ k rotaci
         jnz       widch2                   ; dal®° bit k rotaci
         mov       [si],dh                  ; lev† polovina znaku
         mov       [si+19],dl               ; prav† polovina znaku
         inc       si                       ; dal®° linka znaku
         loop      widch1
         dec       word ptr [bp+6]          ; sn°ëen° pozice znaku na displeji
         mov       [whide],cl               ; p©°znak dvojn†sobnÇho znaku = 0
         pop       si                       ; adresa znaku v bufferu
         ret

                                            ; VSTUP SI=adresa, CX=poáet linek
rozdelchr:push      si                      ; adresa znaku v bufferu
rozdch1: or        byte ptr [si],1          ; oznaáen° rozdàlen° znaku
         inc       si
         loop      rozdch1                  ; dal®° linka znaku
         pop       si
         ret


                                            ; zvòraznàn° znaku
                                            ; VSTUP SI=adresa, CX=poáet linek
fetchr:  push      si                       ; adresa znaku v bufferu
fetch1:  mov       al,[si]                  ; 1 linka znaku
         shr       al,1
         or        [si],al                  ; zvòraznàn° znaku
         inc       si
         loop      fetch1                   ; dal®° linka znaku
         pop       si
         ret

                                            ; inicializace displeje EGA

iniega:  mov       dx,03ceh                 ; adresovò registr EGA
         mov       al,0
         out       dx,al                    ; nastaven° registru 0
         inc       dx                       ; datovò registr
         mov       al,[planes]              ; roviny EGA pro vòstup
         mov       bl,al
         out       dx,al                    ; nastaven° rovin EGA pro vòstup
         dec       dx                       ; adresovò registr EGA
         mov       al,1
         out       dx,al                    ; nastaven° registru 1
         inc       dx                       ; datovò registr
         mov       al,[planng]              ; roviny pro negaci znaku
         xor       al,bl
         not       al
         out       dx,al                    ; nastaven° rovin EGA pro negaci
         dec       dx                       ; adresovò registr EGA
         mov       al,3                     ; registr 3
         out       dx,al                    ; nastaven° registru 3
         inc       dx                       ; datovò registr EGA
         mov       al,0
         out       dx,al                    ; nastaven° reëimu z†pisu bez zmàny
         dec       dx                       ; adresovò registr
         mov       al,8                     ; registr 8
         out       dx,al                    ; nastaven° registru 8
         inc       dx                       ; datovò registr
         mov       al,0ffh
         out       dx,al                    ; nastaven° masky bitñ v®ech rovin
         ret       

                                            ; FUNKCE 00 - vòstup znaku

                                            ; SS:BP = ukazatel parametrñ znaku
                                            ;   +4 = pozice znaku (v link†ch)
                                            ;   +6 = pozice znaku na ©†dku
                                            ;   +8 = znak k vòstupu
                                            ; AH = m¢d znaku
                                            ;   01 = nadsazenÇ p°smo
                                            ;   02 = podsazenÇ p°smo
                                            ;   04 = ®ikmÇ p°smo
                                            ;   08 = podtrëenò text
                                            ;   10 = zvòraznànÇ p°smo
                                            ;   20 = inverzn° p°smo
                                            ;   40 = rozdàlovac° znamÇnko
                                            ;   80 = dvojn†sobn† ®°©ka znaku

fnc00:   xor       cx,cx                    ; zru®en° p©°znaku dvojitÇ ®°©ky
         mov       dx,[bp+6]                ; pozice znaku na ©†dku
         or        dx,dx                    
         jng       fnc001                   ; pozice z†porn†
         cmp       dx,word ptr 80
         ja        fnc001                   ; p©ekroáen° poátu znakñ (>80)
         mov       bl,[bp+8]                ; znak k vòstupu
         cmp       bl,0ffh                  ; je znak pro dvojn†sobnou ®°©ku
         jnz       fnc002                   ; nen° dvojn†sobn† ®°©ka
         mov       cl,80h                   ; nastaven° p©°znaku dvojitÇ ®°©ky
fnc001:  mov       [whide],cl               ; p©°znak dvojn†sobnÇho znaku
         ret                                
fnc002:  mov       dx,ds                    
         mov       es,dx                    ; ES = DS
         cld                                ; smàr p©enosu dat nahoru
         mov       bh,0                     
         mov       si,bx                    ; BL = znak k vòstupu
         shl       si,1                     
         shl       si,1                     
         shl       si,1                     ; SI = znak * 8
         cmp       [mode],2                 ; reëim obrazovky (1,2,3)
         jz        out8x8                   ; reëim 14x8 bodñ
         jnc       out6x8                   ; reëim 8x8 bodñ
         jmp       out14x8                  ; reëim 16x8 bodñ

                                            ; nastaven reëim 3 (8x8)
out6x8:  add       si,offset fnt8x8         ; adresa znaku v tabulce fontñ 6x8
         mov       di,offset chrbuf         ; buffer pro vòstup znaku
         mov       cl,4
         repnz     movsw                    ; p©enos fontu znaku
         mov       si,offset chrbuf         ; buffer pro vòstup znaku
         test      ah,4                     ; je ®ikmÇ p°smo
         jz        out6x81                  
         mov       cl,2                     ; vytvo©en° ®ikmÇho znaku
         shr       byte ptr [si],cl         ; >> 2
         shr       byte ptr [si+1],1        ; >> 1
         shr       byte ptr [si+2],1        ; >> 1
                                            ;    0
                                            ;    0
         shl       byte ptr [si+5],1        ; << 1
         shl       byte ptr [si+06],1       ; << 1
         shl       byte ptr [si+07],cl      ; << 2
out6x81: test      ah,10h
         jz        out6x82
         mov       cl,8                     ; poáet bajtñ znaku
         call      fetchr                   ; zvòraznàn° znaku
out6x82: or        ah,[whide]               ; p©°znak dvojn†sobnÇho znaku
         jns       out6x83                  ; nen° dvojn†sobn† ®°©ka znaku
         mov       cl,8                     ; poáet bajtñ znaku
         call      widchr                   ; zdvojn†soben° ®°©ky znaku
out6x83: test      ah,40h                   ; je rozdàlovac° znamÇnko ?
         jz        out6x89
         mov       cl,8                     ; poáet bajtñ znaku
         call      rozdelchr                ; rozdàlen° znaku
out6x89: mov       cl,8                     ; poáet bajtñ k p©enosu = 8
         jmp       outx8                    ; vykreslen° znaku

                                            ; nastaven reëim 2 (8x14 bodñ)
out8x8:  mov       di,offset chrbuf         ; buffer pro vòstup znaku
         test      ah,3
         jnz       out8x81                  ; je nadsazen° nebo podsazen°

         sub       si,bx                    ; znak * 14
         shl       si,1
         add       si,offset fnt14x8        ; tabulka fontñ 8x14 bodñ
         mov       cl,7                     ; p©enos znaku do bufferu
         repnz     movsw                    ; p©enos fontu znaku
         jmp       short out8x82            ; dal®° korekce znaku

out8x81: add       si,offset fnt8x8         ; tabulka fontñ 8x8 bodñ
         mov       al,0                     ; nulovac° bajt
         test      ah,2                     ; podsazen°
         jnz       out8x80                  ; je podsazen°
         mov       cl,4                     ; poáet bajtñ = 8
         repnz     movsw                    ; p©enos fontu znaku
         mov       cl,6
         rep       stosb
         jmp       short out8x82

out8x80: mov       cl,6                     ; vynulov†n° 6 bajtñ mezery
         repnz     stosb
         mov       cl,4                     ; poáet bajtñ znaku = 8
         repnz     movsw                    ; p©enos fontu znaku

out8x82: mov       si,offset chrbuf         ; buffer pro vòstup znaku
         test      ah,4                     ; ®ikmÇ p°smo
         jz        out8x83
         mov       cl,2                     ; vytvo©en° ®ikmÇho znaku
         shr       byte ptr [si],cl         ; >> 2
         shr       byte ptr [si+1],cl       ; >> 2
         shr       byte ptr [si+2],cl       ; >> 2
         shr       byte ptr [si+3],1        ; >> 1
         shr       byte ptr [si+4],1        ; >> 1
         shr       byte ptr [si+5],1        ; >> 1
                                            ;    0
                                            ;    0
         shl       byte ptr [si+8],1        ; >> 1
         shl       byte ptr [si+9],1        ; << 1
         shl       byte ptr [si+10],1       ; << 1
         shl       byte ptr [si+11],cl      ; << 2
         shl       byte ptr [si+12],cl      ; << 2
         shl       byte ptr [si+13],cl      ; << 2
out8x83: test      ah,10h                   ; zvòraznànÇ p°smo
         jz        out8x84
         mov       cl,14                    ; poáet bajtñ znaku
         call      fetchr                   ; zvòraznàn° znaku
out8x84: or        ah,[whide]               ; p©°znak dvojn†sobnÇho znaku
         jns       out8x85                  ; nen° dvojn†sobn† ®°©ka znaku
         mov       cl,14                    ; poáet bajtñ znaku
         call      widchr                   ; zdvojn†soben° ®°©ky znaku

out8x85: test      ah,40h                   ; je rozdàlovac° znamÇnko ?
         jz        out8x89
         mov       cl,14                    ; poáet bajtñ znaku
         call      rozdelchr                ; rozdàlen° znaku
out8x89:
         mov       cl,14                    ; poáet bajtñ k p©enosu = 14
         jmp       outx8
                                            ; nastaven reëim 1  (19x8)
out14x8: mov       di,offset chrbuf         ; buffer pro vòstup znaku
         test      ah,3                     ; nadsazen° nebo podsazen°
         jz        out4x82                  ; nen°

         sub       si,bx
         shl       si,1
         add       si,offset fnt14x8        ; tabulka fontñ 8x14 bodñ
         mov       al,0                     ; nulovac° bajt
         test      ah,2                     ; podsazen°
         jnz       out4x81                  ; je podsazen°
         mov       cl,7                     ; poáet bajtñ = 14
         repnz     movsw                    ; p©enos fontu znaku
         mov       cl,5
         rep       stosb
         jmp       short out4x83

out4x81: mov       cl,5
         rep       stosb
         mov       cl,7                     ; poáet bajtñ znaku = 8
         repnz     movsw                    ; p©enos fontu znaku
         jmp       short out4x83

out4x82: add       si,bx
         shl       si,1                     ;         SI = znak * 16
         add       si,bx                    ; znak * 19
         add       si,offset fnt19x8        ; adresa znaku v tabulce 16x8 bodñ
         mov       cl,19                    ; poáet bajtñ k p©enosu = 19
         repnz     movsb                    ; p©enos fontu znaku

out4x83: mov       si,offset chrbuf         ; buffer pro vòstup znaku
         test      ah,4
         jz        out4x84                  ; nen° ®ikmÇ p°smo
         mov       cl,2                     ; vytvo©en° ®ikmÇho znaku
         shr       byte ptr [si],cl         ; >> 2
         shr       byte ptr [si+1],cl       ; >> 2
         shr       byte ptr [si+2],cl       ; >> 2
         shr       byte ptr [si+3],cl       ; >> 2
         shr       byte ptr [si+4],1        ; >> 1
         shr       byte ptr [si+5],1        ; >> 1
         shr       byte ptr [si+6],1        ; >> 1
                                            ;    0
                                            ;    0
                                            ;    0
                                            ;    0
                                            ;    0
         shl       byte ptr [si+12],1       ; << 1
         shl       byte ptr [si+13],1       ; << 1
         shl       byte ptr [si+14],1       ; << 1
         shl       byte ptr [si+15],cl      ; << 2
         shl       byte ptr [si+16],cl      ; << 2
         shl       byte ptr [si+17],cl      ; << 2
         shl       byte ptr [si+18],cl      ; << 2
out4x84: test      ah,10h
         jz        out4x85                  ; nen° zvòraznànÇ p°smo
         mov       cl,19
         call      fetchr                   ; zvòraznàn° znaku
out4x85: or        ah,[whide]               ; p©°znak dvojn†sobnÇho znaku
         jns       out4x86                  ; nen° dvojn†sobn† ®°©ka znaku
         mov       cl,19                    ; poáet bajtñ znaku
         call      widchr                   ; zdvojn†soben° ®°©ky znaku
out4x86: test      ah,40h                   ; je rozdàlovac° znamÇnko ?
         jz        out4x89
         mov       cl,19                    ; poáet bajtñ znaku
         call      rozdelchr                ; rozdàlen° znaku
out4x89: mov       cl,19
                                            ; vykreslen° znaku na displej
outx8:   mov       di,[bp+4]                ; pozice znaku (v link†ch)
         shl       di,1                     ; DI = poáet linek * 2
         mov       di,[di+adrrow]           ; p©eáten° adresy linky
         add       di,[bp+6]                ; pozice znaku na ©†dku
         mov       dx,0a000h                ; videopamàü EGA
         mov       es,dx                    ; nastaven° segmentu ES
         mov       bh,[invmsk]              ; maska pro vòstup (pro inverzi)
         test      ah,20H                   ; p©°znak inverzn°ho znaku
         jz        outx81
         not       bh                       ; inverzn° znak
outx81:  lodsb                              ; p©eáten° bajtu k vòstupu DS:SI
         xor       al,bh                    ; filtrace barvy (inverze)
         stosb                              ; uloëen° sudÇho bajtu do VRAM ES:DI
         add       di,79                    ; dal®° ©†dek (zvò®en° o 80)
;         lodsb                              ; p©eáten° druhÇho bajtu k vòstupu
;         xor       al,bh                    ; filtrace barvy
;         stosb                              ; uloëen° lichÇho bajtu do VRAM
;         add       di,79                    ; dal®° ©†dek (zvò®en o 80)
         loop      outx81                   ; dal®° dva bajty znaku
         test      ah,8                     ; p©°znak podtrëenÇho znaku
         jz        outx82                   ; nen° podtrëenò text
         sub       di,80                    ; p©edchoz° ©†dek
         mov       al,bh                    ; barva znakñ
         not       al                       ; negace bajtu
         stosb                              ; uloëen° plnÇ linky (á†ra)(XOR)
outx82:  xor       ah,80h
         jns       outx83                   ; je ®irokÇ p°smo-p©enos pravÇ á†sti
         ret

outx83:  inc       word ptr [BP+6]          ; zvò®en° pozice
         mov       si,offset chrbuf + 19    ; adresa pravÇ poloviny znaku
         cmp       [mode],2                 ; reëim obrazovky (1,2,3)
         jb        out4x86                  ; reëim 1 (14x8 bodñ)
         ja        outx832                  ; reëim 3 (6x8 bodñ)
         jmp       out8x85                  ; reëim 2 (8x8 bodñ)

outx832: jmp       out6x83
                                            ; FUNKCE 01 - kurzor a maz†n°

                                            ; SS:BP = ukazatel parametrñ
                                            ;    + 4 = parametr pro z†pis okna
                                            ;          = 0 negace okna
                                            ;          = 1 vymaz†n° okna
                                            ;    + 6 = poá†teán° pozice (pozice)
                                            ;    + 8 = ®°©ka okna (pozic)
                                            ;    +10 = poá†teán° pozice (linka)
                                            ;    +12 = vò®ka okna (v bajtech)

fnc01:   mov       ax,[bp+10]               ; poá†t. pozice (linka)
         mov       di,ax
         shl       di,1
         shl       di,1
         add       di,ax                    ; DI = AX * 5
         mov       cl,4                     ; poáet rotac°
         shl       di,cl                    ; DI = AX * 80 - poá†t. linka
         mov       bx,[bp+6]                ; poá†teán° pozice (pozic)
         sub       bx,ax
         inc       bx                       ; - poá†teán° pozice (v bajtech)
         mov       ax,[bp+12]               ; vò®ka okna (linek)
         or        ax,ax
         jg        fnc011                   ; kladn†
         mov       ax,1                     ; z†porn† - ë†dnÇ okno
fnc011:  mov       cx,[bp+8]                ; ®°©ka okna (pozic)
         cmp       cx,word ptr 80           ; kontrola ®°©ky okna
         jng       fnc012
         mov       cx,word ptr 80           ; omezen° na max. poáet znakñ 80
fnc012:  dec       ax                       ; vò®ka okna (v bajtech)
         sub       cx,ax                    ; zaá†tek posledn° linky
         jng       fnc019                   ; nen° ë†dnÇ okno
         add       di,ax                    ; koneán† linka (v bajtech)
         mov       dx,03CEh                 ; adresovò registr grafiky EGA
         mov       al,1                     ; nastaven° registru á°slo 1
         out       dx,al
         inc       dx                       ; adresa dat registru
         mov       al,0fh                   ; nastaven° bitñ pro set/reset
         out       dx,al
         dec       dx                       ; adresovò registr grafiky EGA
         mov       al,0
         out       dx,al                    ; nastaven° registru á°slo 0
         inc       dx                       ; adresa dat registru
         mov       ah,[invmsk]              ; maska znakñ pro vòstup
         cmp       byte ptr [bp+4],1        ; parametr pro z†pis okna
         jnc       fnc013                   ; je vymaz†n° okna
         not       ah                       ; negace masky pro vòstup
         jmp       short fnc014
fnc013:  mov       al,0ffh                  ; maz†n° v®ech rovin
         jnz       fnc015
fnc014:  mov       al,[planes]              ; roviny pro vòstup znaku
         or        ah,ah                    ; negovan† maska znakñ pro vòstup
         jnz       fnc015                   ; je negace zpàt
         mov       al,[planng]              ; roviny pro negaci znaku (kurzor)
fnc015:  out       dx,al                    ; vòbàr rovin pro vòstup
         push      ds
         mov       si,0a000h                ; adresa VRAM karty EGA
         mov       es,si
         mov       ds,si                    ; nastaven° segmentovòch registrñ
         cld                                ; smàr p©enosu dat vzhñru
         inc       al                       ; roviny pro z†pis
         jnz       fnc017                   ; nejsou v®echny roviny (tj. maz†n°)
         dec       dx                       ; adresovò registr grafiky EGA
         mov       al,3
         out       dx,al                    ; nastaven° registru 3
         inc       dx                       ; datovò registr
         mov       al,18h                   ; z†pisovò m¢d XOR
         out       dx,al
fnc016:  mov       si,di
         push      cx                       ; ®°©ka okna k vymaz†n°
         push      di                       ; ukazatel okna
         repnz     movsb                    ; vymaz†n° bajtñ obrazovky
         pop       di
         pop       cx
         add       di,80                    ; dal®° linka
         dec       bx                       ; á°taá linek okna
         jnz       fnc016                   ; dal®° linka okna
         jmp       short fnc018             ; konec
fnc017:  push      cx
         push      di
         repnz     stosb                    ; uloëen° negovac°ho bajtu
         pop       di
         pop       cx
         add       di,80                    ; dal®° linka
         dec       bx                       ; á°taá linek
         jnz       fnc017                   ; dal®° linka k negaci
fnc018:  pop       ds
         call      iniega                   ; inicializace displeje
fnc019:  ret


                                            ; FUNKCE 02 - rolov†n° okna nahoru

                                            ; SS:BP = ukazatel parametrñ
                                            ;    + 4 = koneánò ©†dek rolov†n°
                                            ;    + 6 = ®°©ka okna (pozic)
                                            ;    + 8 = poá†teán° ©†dek k rol.
                                            ;    +10 = poá†teán° pozice okna

fnc02:   mov       ax,[bp+4]                ; koneánò ©†dek k rolov†n°
         mov       si,[bp+8]                ; poá†teán° ©†dek k rolov†n°
         sub       ax,si                    ; poáet ©†dkñ k rolov†n°
         jz        fnc022                   ; nen° ë†dnò ©†dek k rolov†n°
         mul       byte ptr [vyska]         ; vyn†soben° poátem linek na ©†dek
         mov       bx,ax                    ; celkovò poáet linek k rolov†n°
         mov       dx,03ceh                 ; adresovò registr grafiky EGA
         mov       al,8
         out       dx,al                    ; nastaven° registru 08
         inc       dx                       ; datovò registr grafiky EGA
         mov       al,0
         out       dx,al                    ; nastaven° masky pro v®echny roviny
         shl       si,1                     ; poá†teán° ©†dek k rolov†n°
         add       si,offset adrrow         ; tabulka adres ©†dkñ na displeji
         mov       di,[si]                  ; p©eáten° adresy ©†dku
         inc       si
         inc       si
         mov       si,[si]                  ; adresa n†sleduj°c°ho ©†dku
         mov       ax,[bp+10]               ; poá†teán° pozice okna k rolov†n°
         add       di,ax                    ; koncovÇ adresy okna
         add       si,ax
         mov       cx,[bp+6]                ; ®°©ka okna (pozic)
         sub       cx,ax
         inc       cx                       ; - koneán† pozice okna
         push      ds
         mov       ax,0a000h                ; segment pamàti EGA
         mov       es,ax                    ; nastaven° segmentñ pamàti EGA
         mov       ds,ax
         cld                                ; smàr p©enosu dat nahoru
fnc021:  push      si
         push      di
         push      cx                       ; poáet bajtñ k p©enosu
         repnz     movsb                    ; p©enos jednÇ linky okna
         pop       cx
         pop       di
         pop       si
         add       di,80                    ; dal®° linka
         add       si,80
         dec       bx                       ; á°taá linek
         jnz       fnc021
         pop       ds
         call      iniega                   ; inicializace displeje EGA
fnc022:  ret





                                            ; FUNKCE 03 - rolov†n° okna dolñ

                                            ; SS:BP = ukazatel parametrñ
                                            ;    + 4 = koneánò ©†dek rolov†n°
                                            ;    + 6 = ®°©ka okna (pozic)
                                            ;    + 8 = poá†teán° ©†dek k rol.
                                            ;    +10 = poá†teán° pozice okna


fnc03:   mov       ax,[bp+4]                ; koneánò ©†dek k rolov†n°
         mov       di,ax
         sub       ax,[bp+8]                ; poá†teán° ©†dek k rolov†n°
         jz        fnc032                   ; je nulovò poáet ©†dkñ k rolov†n°
         mul       byte ptr [vyska]         ; vypoáten° poátu linek k rolov†n°
         mov       bx,ax                    ; poáet linek k rolov†n°
         mov       dx,03ceh                 ; adresovò registr grafiky EGA
         mov       al,8
         out       dx,al                    ; nastaven° registru 08
         inc       dx
         mov       al,0
         out       dx,al                    ; nastaven° bitovÇ masky v®ech rovin
         shl       di,1                     ; koneánò ©†dek k rolov†n° * 2
         add       di,offset adrrow         ; tabulka adres ©†dkñ na displeji
         mov       si,[di]                  ; adresa koneánÇho ©†dku k rolov†n°
         inc       di
         inc       di
         mov       di,[di]                  ; adresa poá†teán°ho ©†dku k rol.
         mov       ax,[bp+10]               ; poá†teán° pozice okna
         add       di,ax                    ; adresa pravÇho doln°ho rohu
         add       si,ax                    ; adresa pravÇho horn°ho rohu
         mov       cx,[bp+6]                ; ®°©ka okna (pozic)
         sub       cx,ax
         inc       cx                       ; - koneán† pozice okna
         push      ds
         mov       ax,0a000h                ; poá†teán° adresa pamàti EGA
         mov       es,ax                    ; nastaven° segmentu pro EGA
         mov       ds,ax
         cld                                ; smàr p©enosu dat nahoru
fnc031:  sub       di,80
         sub       si,80
         push      si
         push      di
         push      cx
         repnz     movsb                    ; p©enos jednÇ linky
         pop       cx
         pop       di
         pop       si
         dec       bx
         jnz       fnc031                   ; dal®° linka k p©enosu
         pop       ds
         call      iniega                   ; inicializace displeje EGA
fnc032:  ret


                                            ; FUNKCE 04 - pravò okraj (á†ra)

                                            ; SS:BP = ukazatel parametrñ
                                            ;    + 4 = k¢d á†ry
                                            ;    + 6 = koneánò ©†dek
                                            ;    + 8 = poá†teán° ©†dek
                                            ;    +10 = pozice á†ry

fnc04:   mov       si,[bp+10]               ; pozice á†ry
         or        si,si
         jng       fnc042                   ; z†porn† pozice
         cmp       si,word ptr 80           ; kontrola p©ekroáen° 80 znakñ
         ja        fnc042                   ; p©ekroáen poáet znakñ 80
         mov       ax,[bp+6]                ; koneánò ©†dek
         mov       di,[bp+8]                ; poá†teán° ©†dek
         sub       ax,di
         inc       ax                       ; poáet ©†dkñ okna
         mul       byte ptr [vyska]         ; poáet linek na ©†dek
         mov       cx,ax                    ; á°taá linek
         shl       di,1                     ; poá†teán° ©†dek * 2
         mov       di,[di+adrrow]           ; adresa ©†dku (v bajtech)
         add       di,si                    ; adresa zaá†tku okna (v bajtech)
         mov       dx,03ceh                 ; adresovò registr grafiky EGA
         mov       al,1
         out       dx,al                    ; nastaven° registru 01
         inc       dx                       ; datovò registr grafiky EGA
         mov       al,0                     ; nastaven° bodñ
         out       dx,al
         dec       dx                       ; adresovò registr grafiky EGA
         mov       al,3
         out       dx,al                    ; nastaven° registru 03
         inc       dx                       ; datovò registr grafiky EGA
         mov       al,18h                   ; nastaven° reëimu pro z†pis XOR
         out       dx,al
         mov       al,[bp+04]               ; znak á†ry
         push      ds
         mov       dx,0a000h                ; adresa pamàti EGA
         mov       ds,dx                    ; datovò segment na pamàü EGA
fnc041:  mov       ah,[di]                  ; p©eáten° bajtu
         mov       [di],al                  ; z†pis znaku á†ry
         add       di,80
         loop      fnc041                   ; dal®° linka
         pop       ds
         call      iniega                   ; inicializace displeje EGA
fnc042:  ret

; -----------------------------------------------------------------------------
;        Funkce 5: Inicializace parametrñ
; -----------------------------------------------------------------------------
;˛
                                            ; FUNKCE 05 - inicializace parametrñ

                                            ; SS:BP = ukazatel parametrñ znaku
                                            ;   +4 = barva okol° (borderu)
                                            ;   +6 = pozice znaku na ©†dku
                                            ;   +8 = reëim obrazovky (©†dkov†n°)

fnc05:   mov       ax,ds
         mov       es,ax                    ; nastaven° segmentu ES = DS
         mov       di,offset chrbuf         ; buffer pro vòstup znaku
         mov       cx,32                    ; poáet bajtñ bufferu
         mov       al,0                     ; nulovac° bajt
         cld                                ; smàr nahoru
         repnz     stosb                    ; vynulov†n° bufferu pro vòstup
         mov       ax,18                    ; nastaven° grafickÇho m¢du 640x480
         int       10h
         mov       al,[bp+6]
         mov       bl,[bp+4]                ; barva okol° (borderu)
         mov       bh,bl
         mov       ah,0
         or        bh,al
         cmp       bh,bl
         jnz       fnc051
         not       ah
         xchg      al,bl
fnc051:  or        al,bl
         mov       [planng],al              ; roviny pro negaci znaku (kurzor)
         mov       [planes],bl              ; roviny EGA pro vòstup znaku
         mov       [invmsk],ah              ; maska znakñ pro inverzi
         mov       ax,1001h                 ; povel pro nastaven° barvy borderu
         mov       bh,bl                    ; barva borderu
         int       10h                      ; nastaven° barvy borderu
         call      iniega                   ; inicializace displeje EGA
         mov       al,[bp+8]                ; reëim obrazovky (©†dkov†n°)
         mov       [mode],al                ; reëim obrazovky (1,2,3)
         cmp       al,2
         mov       bx,19                    ; vò®ka ©†dku 19 bodñ
         mov       cx,24                    ; posledn° á°slo ©†dku 33 (34 ©†dkñ)
         jc        fnc052                   ; je reëim 1
         mov       bx,14                    ; vò®ka ©†dku 10 bodñ
         mov       cx,33                    ; posledn° á°slo ©†dku 47 (48 ©†dkñ)
         jz        fnc052                   ; je reëim 2
         mov       bx,8                     ; vò®ka ©†dku 6 bodñ
         mov       cx,59                    ; posledn° á°slo ©†dku 79 (80 ©†dkñ)
fnc052:  push      cx                       ; á°slo posledn°ho ©†dku
         mov       di,offset adrrow         ; tabulka adres ©†dkñ na displeji
         mov       al,80                    ; poáet znakñ na ©†dek
         mul       bl                       ; poáet bajtñ na ©†dek
         mov       dx,0ffffh                ; adresa 0. ©†dku
         inc       cx
fnc053:  mov       [di],dx                  ; uloëen° adresy ©†dku
         inc       di
         inc       di                       ; zvò®en° ukazatele pro ukl†d†n°
         add       dx,ax                    ; zvò®en° adresy
         dec       cx                       ; á°taá ©†dkñ
         jns       fnc053                   ; dal®° ©†dek
         mov       [vyska],bl               ; poáet linek na ©†dek

                                          ;* vymaz†n° spodn°ch linek
         push      di
         mov       di,476*80
         mov       cx,0a000h                ; videopamàü EGA
         mov       es,cx                    ; nastaven° segmentu ES
         mov       al,[invmsk]              ; maska pro vòstup (pro inverzi)
         mov       cx,4*80
         cld
         rep       stosb                    ; vymaz†n° linek
         pop       di

         pop       cx                       ;
         mov       ax,80                    ; poáet znakñ na ©†dek
         mov       si,offset karta          ; adresa oznaáen° displeje

         ret

                                            ; FUNKCE 06 - nastaven° text. m¢du
fnc06:   mov       ax,3
         int       10h                      ; nastaven° textovÇho m¢du 80x25
         ret

                                            ; slovn°k 1
slov1    db        'ANA ANI ABE ALTR EINI DEST GEI INI INS '
         db        'NACHT UNIV ZEITEN ZEITU ',0ffh

                                            ; slovn°k 2
slov2    db        'AB AN AUF AUS NACH UN VER VOR ',0ffh

                                            ; slovn°k 3
slov3    db        'ALT ALP BETT BERG DES EIN ERD ERNST FETT FEST '
         db        'GELD HAUS KREUZ LANG LEIT MACHT MAUS MENSCH NORD '
         db        'NéCHST NETZ OBER OST REIT RöCK SCHUL SPIEL SöD '
         db        'TEST TIEF VOLL WACHS WASCH WEIT WETT WEG WEST ',0ffh

                                            ; slovn°k 4
slov4    db        'DURCH LETZTEND SPORT TRANS ',0ffh

                                            ; slovn°k 5
slov5    db        'DORT HOCH ZEIT öBER ',0ffh

                                            ; slovn°k 6
slov6    db        'CHA CURS DAR EMPF ENT HIN HER KOMP MIT SYN ',0ffh

                                            ; slovn°k 7
slov7    db        'ABL ABR ALLEIN ANEI ANER ANORD ANS AT BEEH BEEI '
         db        'BEEN BEERD BEIRR BEOB BEUN BEUR ER GE IN KOOR '
         db        'OKT UM UR ZUGABE ',0ffh

                                            ; slovn°k 8
slov8    db        'AI AU AY EI EU EY éU ',0ffh

                                            ; slovn°k 9
slov9    db        'EA Eé Eô Eö II Ié Iô Iö OA OE UE UI UU ',0ffh

                                            ; slovn°k 10
slov10   db        'BL BR CH DR FL FR GL GR KL KN KR PFL PH PF '
         db        'PL PR SCHL SCHM SCHN SCHR SCHW STR SPR SCH '
         db        'SP ST TH TR ZW ',0ffh

                                            ; slovn°k 11
slov11   db        'BS B CHTS CHS CHT CKT CH CK D FF FS F GS G '
         db        'HRS HL HM HN HR HT H KT K LBST LSCH LCH LFS '
         db        'LKS LTS LB LD LF LG LK LL LP LS LT L '
         db        'MPF MTS MM MP MT M NSCH NGS NDS NST ND NN NF '
         db        'NG NK NS NT NZ N PF PP PT P '
         db        'RSCH RCH RKT RST RB RD RF RG RK RM RN RS RT '
         db        'RZ R SCH ST S TSCH TZT TS TT TZ T XT Z '
         db        '· ',0ffh

                                            ; slovn°k 12
slov12   db        'EITS IONS LLGE NSGE UNGS ',0ffh

                                            ; slovn°k 13
slov13   db        'HAUS HEIT LICH LADE LAND LER LIG LOS PHA PREIS '
         db        'PUNKT RAND RAUM RECHT RECHN REICH RIG ROUT '
         db        'RUF ',0ffh

                                            ; slovn°k 14
slov14   db        'AUS AUF AUGE AUTO AMT ART AB ARZT ARBEIT AKT '
         db        'ALGO ANALY ANDER ANF ANGAB ANGEB ANL ANOR '
         db        'ANSA ANTEIL ANWA ANWEN ANZAHL ANZEIG ANTW '
         db        'APFEL AFRI AMERI ADR APP ARGU EBENE ECK EDITO '
         db        'EIN EFF EURO ELEM ENERG ENTW EIMER ERDA '
         db        'ERGEBN ERFA ERLEB ERFO ERHAL ERKENN ETW EXP '
         db        'INDU INF INH INS IMP OBER ORDN ORDEN OPER ORGA '
         db        'ORIENT ORT UHR UMBRU UNFALL UNTER UMSATZ '
         db        'URLAUB URSACH URTEIL éRZT éNDER éMT ôFFN '
         db        'ôKO öB ',0ffh

b0aa4    db        0                        ; povolen† dÇlka ©†dku
b0aa5    dw        0                        ; adresa p©evodn° tabulky znakñ
w0aa7    dw        0
                                            ; test, zda jde o oddàlovac° znak
                                            ; vstup:  DS:[BX+DI] = ukaz. textu
                                            ;         ES:[CS:[B0AA5]] p©ev.tab.
                                            ; vòstup: ZF = 0 je oddàlovac° znak

tst04:   mov       ah,4
         jmp       short tst401

                                            ; test, zda jde o ©°d°c° znak
                                            ; vstup:  DS:[BX+DI] = ukaz. textu
                                            ;         ES:[CS:[B0AA5]] p©ev.tab.
                                            ; vòstup: ZF = 0 je ©°d°c° znak

tst40:   mov       ah,40h
tst401:  mov       al,[bx+di]               ; znak z textu k otestov†n°
         push      bx
         mov       bx,cs:[b0aa5]            ; adresa tabulky oddàlovac°ch znakñ
         db        26h
         xlat                               ; transformace podle tab. ES:BX
         test      ah,al
         pop       bx
         ret

                                            ; nalezen° zaá†tku slova v textu
                                            ; vstup:  DS:[BX+DI] = ukaz.textu

endwrd:  dec       bx                       ; ukazatel textu
endwrd1: inc       bx
         call      tst40                    ; test, zda jde o ©°d°c° znak
         jnz       endwrd2                  ; je ©°d°c° znak - konec
         test      al,4                     ; jde o oddàlovac° znak slova ?
         jnz       endwrd1                  ; je oddàlovac° znak slova - dal®°
endwrd2: ret

                                            ; nalezen° slova ve slovn°ku

                                            ; vstup:  CS:[SI] = ukazatel tabulky
                                            ;         DS:[BX+DI] = ukaz. textu
                                            ; vòstup: AX = dÇlka shodnÇho slova
                                            ;         (AX = 0,ZF = 0 nenalezeno)

srcwrd:  mov       ah,32                    ; oddàlovac° znak slov (mezera)
srcwrd1: mov       al,cs:[si]               ; prvn° znak slova z tabulky
         cmp       al,[bx+di]               ; porovn†n° se znakem v textu
         ja        srcwrd5                  ; znak v tabulce vàt®° - nenalezeno
         jc        srcwrd3                  ; znak v tabulce men®° - dal®° slovo
         push      bx                       ; (shoda prvn°ho znaku) ukaz. textu
srcwrd2: inc       bx                       ; ukazatel zkoumanÇho textu
         inc       si                       ; ukazatel slovn°ku
         mov       al,cs:[si]               ; dal®° znak ze slovn°ku
         cmp       al,ah                    ; je mezera (konec slova) ?
         jz        srcwrd4                  ; je mezera = konec slova
         cmp       al,[bx+di]               ; porovn†n° dal®°ho znaku slova
         jz        srcwrd2                  ; shoda - dal®° znak
         pop       bx                       ; (nen° shoda) ukazatel textu
srcwrd3: inc       si                       ; nalezen° dal®°ho slova v tabulce
         cmp       ah,cs:[si]               ; je oddàlovac° mezera ?
         jnz       srcwrd3                  ; je®tà ne - dal®° znak v tabulce
         inc       si
         jmp       short srcwrd1            ; test dal®°ho slova
srcwrd4: mov       ax,bx                    ; slova se shoduj°
         pop       bx                       ; adresa slova ve slovn°ku
         sub       ax,bx                    ; dÇlka nalezenÇho slova
         ret
srcwrd5: xor       ax,ax                    ; slovo nenalezeno - konec (dÇlka 0)
         ret


lab0af5: push      bx                       ; adresa textu
         add       bx,ax                    ; adresa konce slabiky (rozdàlit)
         push      bx                       ; adresa konce slabiky
         call      endwrd                   ; nalezen° konce slova v textu
         mov       ax,bx                    ; konec slova v textu
         pop       bx                       ; adresa konce slabiky
         jz        lab0af51                 ; je jië konec ©†dku
         sub       ax,bx                    ; poáet znakñ do konec slova
         cmp       al,1                     ; dÇlka zbylÇ á†sti slova
         jna       lab0af52                 ; nen° jië ë†dnò znak
         push      ax                       ; dÇlka zbylÇ á†sti slova
         mov       si,offset slov10         ; slovn°k 10
         call      srcwrd                   ; nalezen° slova ve slovn°ku
         pop       si                       ; dÇlka zbylÇ á†sti slova
         cmp       ax,si                    ; nalezeno stejnà dlouhÇ slovo ?
         jz        lab0af52                 ; je celÇ slovo
         xor       ax,ax                    
lab0af51:pop       bx                       
         ret                                
lab0af52:pop       si                       
lab0af53:cmp       bl,cs:[b0aa4]             ; povolen† dÇlka ©†dku
         jnc       lab0af55                  ; p©ekroáen okraj ©†dku
         inc       dx                       
         cmp       dx,bx                    
         mov       dx,bx                    
         jz        lab0af54                 
         mov       cs:[w0aa7],bx
lab0af54:ret                                
lab0af55:jmp       fnc097

                                            ;
lab0b2f: mov       si,offset slov1          ; slovn°k 1 - nelze rozdàlit
         call      srcwrd                   ; nalezen° slova ve slovn°ku
         jnz       lab0b2f5                 ; slovo nalezeno - konec
lab0b2f1:mov       si,offset slov2          ; slovn°k 2 - lze rozdàlit
         call      srcwrd                   ; nalezen° slova ve slovn°ku
         jz        lab0b2f2                 ; slovo nenalezeno - slovn°k 3
         call      lab0af5                 
         jnz       lab0b2f1                
lab0b2f2:mov       si,offset slov3          ; slovn°k 3
         call      srcwrd                   ; nalezen° slova ve slovn°ku
         jz        lab0b2f3                
         mov       si,di                   
         add       si,ax                   
         cmp       byte ptr [bx+si],"E"     ; je znak "E" ?
         jnz       lab0b2f4                
lab0b2f3:mov       si,offset slov4          ; slovn°k 4
         call      srcwrd                   ; nalezen° slova ve slovn°ku
         mov       ax,5                    
         jnz       lab0b2f4                
         mov       si,offset slov5          ; slovn°k 5
         call      srcwrd                   ; nalezen° slova ve slovn°ku
         mov       ax,4                    
         jnz       lab0b2f4                
         mov       si,offset slov6          ; slovn°k 6
         call      srcwrd                   ; nalezen° slova ve slovn°ku
         mov       ax,3                    
         jnz       lab0b2f4                
         mov       si,offset slov7          ; slovn°k 7
         call      srcwrd                   ; nalezen° slova ve slovn°ku
         mov       ax,2                    
         jz        lab0b2f5                
lab0b2f4:call      lab0af5                 
lab0b2f5:ret

lab0b85: mov       ax,bx                   
         sub       ax,cx                   
         cmp       ax,2                    
         xchg      bx,cx                   
         jc        lab0b853                
         jz        lab0b851                
         mov       si,offset slov8          ; slovn°k 8
         call      srcwrd                   ; nalezen° slova ve slovn°ku
         jz        lab0b851                
         inc       bx                      
         jmp       short lab0b852          
lab0b851:mov       si,offset slov9          ; slovn°k 9
         call      srcwrd                   ; nalezen° slova ve slovn°ku
         jz        lab0b853                
         cmp       byte ptr [bx+di-1],"Q"   ; je znak "Q" ?
         jz        lab0b853                
lab0b852:inc       bx                      
         call      lab0af53                
lab0b853:xchg      bx,cx                   
         ret       

lab0bb2: cmp       bx,cx
         jz        lab0bb27
         push      bx
         push      dx
         mov       dx,bx
         dec       dx
         mov       bx,cx
         dec       bx
lab0bb21:inc       bx
         cmp       bx,dx
         jz        lab0bb22
         mov       si,offset slov10         ; slovn°k 10
         call      srcwrd                   ; nalezen° slova ve slovn°ku
         jz        lab0bb21
         add       ax,bx
         dec       ax
         cmp       ax,dx
         jnz       lab0bb21
         cmp       byte ptr [bx+di-1],"C"   ; byl p©edchoz° znak "C" ?
         jz        lab0bb21
lab0bb22:xchg      bx,cx
         mov       si,offset slov11         ; slovn°k 11
         call      srcwrd                   ; nalezen° slova ve slovn°ku
         add       bx,ax
         xchg      bx,cx
         cmp       bx,cx
         jnc       lab0bb26
         mov       dx,bx
lab0bb23:mov       si,offset slov12         ; slovn°k 12
         push      bx
         sub       bx,4
         call      srcwrd                   ; nalezen° slova ve slovn°ku
         pop       bx
         jz        lab0bb24
         cmp       byte ptr cs:[w0aa7],0
         jnz       lab0bb26
lab0bb24:call      tst40                    ; test, zda jde o ©°d°c° znak
         mov       si,offset slov14         ; slovn°k 14
         jnz       lab0bb25
         mov       si,offset slov13         ; slovn°k 13
lab0bb25:call      srcwrd                   ; nalezen° slova ve slovn°ku
         jnz       lab0bb26
         inc       bx
         cmp       bx,cx
         jna       lab0bb23
         mov       bx,dx
lab0bb26:pop       dx
         call      lab0af53
         pop       bx
lab0bb27:ret

                                            ; FUNKCE 09 - rozdàlov†n° slov
                                            ; vstup:  DS = datovò segment textu
                                            ;         CX = pozice v ©†dku

fnc09:   mov       [w0aa7],0
         mov       [b0aa4],al               ; povolen† dÇlka ©†dku
         mov       [b0aa5],si               ; adresa transformaán° tabulky znakñ
         pop       dx                       ; n†vratov† adresa programu
         pop       ds                       ; datovò segment textu
         push      ds                       ; datovò segment textu
         push      dx                       ; n†vratov† adresa programu
         push      bp                       
         mov       bp,sp                    
fnc091:  mov       bx,cx                    ; aktu†ln° pozice v ©†dku
         dec       bx                       
fnc092:  inc       bx                       ; dal®° znak
         cmp       bl,cs:[b0aa4]            ; povolen† dÇlka ©†dku
         jnc       fnc097                   ; p©ekroáen okraj ©†dku - konec
         call      tst04                    ; test, zda jde o oddàlovac° znak
         jz        fnc092                   ; nenalezeno - dal®°
         mov       cx,bx                    ; nov† pozice rozdàlen° slova
         dec       bx                       
fnc093:  inc       bx                       
         call      tst04                    ; test, zda jde o oddàlovac° znak
         jnz       fnc093                   ; nalezeno - dal®° pokus
         xchg      bx,cx                    
         mov       ax,cx                    
         sub       ax,bx                    
         cmp       ax,4                     
         jc        fnc091                   
         mov       dx,bx                    
         call      lab0b2f                  
         call      endwrd                   ; nalezen° zaá†tku slova v textu
         jz        fnc091                   
         push      cx                       
fnc094:  mov       cx,bx                    
         dec       bx                       
fnc095:  inc       bx                       
         call      tst40                    ; test, zda jde o ©°d°c° znak
         jnz       fnc095                   
         call      lab0b85                  
         mov       cx,bx                    
         call      endwrd                   ; nalezen° zaá†tku slova v textu
         jz        fnc096                   
         call      lab0bb2                  
         jmp       short fnc094             
fnc096:  pop       cx                       
         jmp       short fnc091             
fnc097:  mov       ax,cs:[w0aa7]            
         mov       sp,bp                    
         pop       bp                       
         ret                                


                                            ; tabulka pro p©ek¢dov†n° kl†ves

tabkey   db        0c1h,1eh                 ; ALT A
         db        0c2h,30h                 ; ALT B
         db        0c3h,2eh                 ; ALT C
         db        0c4h,20h                 ; ALT D
         db        0c5h,12h                 ; ALT E
         db        0c6h,21h                 ; ALT F
         db        0c7h,22h                 ; ALT G
         db        0c8h,23h                 ; ALT H
         db        0c9h,17h                 ; ALT I
         db        0cah,24h                 ; ALT J
         db        0cbh,25h                 ; ALT K
         db        0cch,26h                 ; ALT L
         db        0cdh,32h                 ; ALT M
         db        0ceh,31h                 ; ALT N
         db        0cfh,18h                 ; ALT O
         db        0d0h,19h                 ; ALT P
         db        0d1h,10h                 ; ALT Q
         db        0d2h,13h                 ; ALT R
         db        0d3h,1fh                 ; ALT S
         db        0d4h,14h                 ; ALT T
         db        0d5h,16h                 ; ALT U
         db        0d6h,2fh                 ; ALT V
         db        0d7h,11h                 ; ALT W
         db        0d8h,2dh                 ; ALT X
         db        0d9h,15h                 ; ALT Y
         db        0dah,2ch                 ; ALT Z
         db        0f0h,81h                 ; ALT 0
         db        0f1h,78h                 ; ALT 1
         db        0f2h,79h                 ; ALT 2
         db        0f3h,7ah                 ; ALT 3
         db        0f4h,7bh                 ; ALT 4
         db        0f5h,7ch                 ; ALT 5
         db        0f6h,7dh                 ; ALT 6
         db        0f7h,7eh                 ; ALT 7
         db        0f8h,7fh                 ; ALT 8
         db        0f9h,80h                 ; ALT 9
         db        1bh,3bh                  ; F1
         db        1ch,3ch                  ; F2
         db        1dh,3dh                  ; F3
         db        1eh,3eh                  ; F4
         db        1fh,3fh                  ; F5
         db        20h,40h                  ; F6
         db        21h,41h                  ; F7
         db        22h,42h                  ; F8
         db        23h,43h                  ; F9
         db        24h,44h                  ; F10
         db        5bh,54h                  ; SHIFT F1
         db        5ch,55h                  ; SHIFT F2
         db        5dh,56h                  ; SHIFT F3
         db        5eh,57h                  ; SHIFT F4
         db        5fh,58h                  ; SHIFT F5
         db        60h,59h                  ; SHIFT F6
         db        61h,5ah                  ; SHIFT F7
         db        62h,5bh                  ; SHIFT F8
         db        63h,5ch                  ; SHIFT F9
         db        64h,5dh                  ; SHIFT F10
         db        9bh,5eh                  ; CTRL F1
         db        9ch,5fh                  ; CTRL F2
         db        9dh,60h                  ; CTRL F3
         db        9eh,61h                  ; CTRL F4
         db        9fh,62h                  ; CTRL F5
         db        0a0h,63h                 ; CTRL F6
         db        0a1h,64h                 ; CTRL F7
         db        0a2h,65h                 ; CTRL F8
         db        0a3h,66h                 ; CTRL F9
         db        0a4h,67h                 ; CTRL F10
         db        0dbh,68h                 ; ALT F1
         db        0dch,69h                 ; ALT F2
         db        0ddh,6ah                 ; ALT F3
         db        0deh,6bh                 ; ALT F4
         db        0dfh,6ch                 ; ALT F5
         db        0e0h,6dh                 ; ALT F6
         db        0e1h,6eh                 ; ALT F7
         db        0e2h,6fh                 ; ALT F8
         db        0e3h,70h                 ; ALT F9
         db        0e4h,71h                 ; ALT F10
         db        0a5h,73h                 ; CTRL <-
         db        0a6h,74h                 ; CTRL ->
         db        0a7h,77h                 ; CTRL HOME
         db        0a8h,75h                 ; CTRL END
         db        0a9h,84h                 ; CTRL PGUP
         db        0aah,76h                 ; CTRL PGDN
         db        6bh,0fh                  ; SHIFT TAB
         db        0,0                      


tabshf   db        6                        ; dÇlka jednÇ poloëky
         db        0,'     '                ; 00h
         db        5,'SHIFT'                ; 40h
         db        4,'CTRL '                ; 80h
         db        3,'ALT  '                ; C0h
         db        0ffh                     

tabhome  db        5                        ; dÇlka jednÇ poloëky
         db        2,'<-  '                 ; 25h
         db        2,'->  '                 ; 26h
         db        4,'HOME'                 ; 27h
         db        3,'END '                 ; 28h
         db        4,'PGUP'                 ; 29h
         db        4,'PGDN'                 ; 2Ah
         db        3,'TAB '                 ; 2Bh
         db        0ffh                     

tabfn    db        4                        ; dÇlka jednÇ poloëky
         db        2,'F1 '                  ; 1Bh
         db        2,'F2 '                  ; 1Ch
         db        2,'F3 '                  ; 1Dh
         db        2,'F4 '                  ; 1Eh
         db        2,'F5 '                  ; 1Fh
         db        2,'F6 '                  ; 20h
         db        2,'F7 '                  ; 21h
         db        2,'F8 '                  ; 22h
         db        2,'F9 '                  ; 23h
         db        3,'F10'                  ; 24h
         db        0ffh                     

                                            ; p©evod textu na velk† p°smena

                                            ; vstup:  ES:SI = ukazatel na text
                                            ;         BL = nejmen®° znak
                                            ; vòstup: ES:[BX+SI] = zaá†tek textu
                                            ;         CX = poáet znakñ textu
                                            ;         CF=0,ZF=0 je konec textu
                                            ;         CF=0,ZF=1 nen° je®tà konec

upper:   xor       cx,cx                    ; vynulov†n° á°taáe znakñ
upper1:  cmp       bl,es:[si]               ; porovn†n° znaku s BL
         ja        upper6                   ; znak je men®° neë BL - konec
         cmp       byte ptr es:[bx+si]," "  ; je mezera ?
         jnz       upper2                   ; nen° - konec hled†n°
         inc       bx                       ; dal®° pozice
         jmp       short upper1             ; dal®° znak
upper2:  push      bx                       
upper3:  cmp       bl,es:[si]               ; kontrola koncovÇho znaku
         ja        upper5                   ; znak je men®° neë BL - konec
         mov       al,es:[bx+si]            ; p©eáten° znaku k p©ek¢dov†n°
         cmp       al," "                   ; je mezera ?
         jz        upper5                   ; je mezera - konec
         cmp       al,"|"                   ; "|"
         jz        upper5                   ; je znak "|" - konec
         cmp       al,"a"                   ; "a"
         jc        upper4                   ; je znak men®° neë "a"
         and       al,0dfh                  ; p©evod na velkÇ p°smeno
         mov       es:[bx+si],al            ; uloëen° p©evedenÇho znaku
upper4:  inc       bx                       ; dal®° znak
         inc       cx                       ; zvò®en° á°taáe nalezenòch znakñ
         jmp       upper3                   ; p©evod dal®°ho znaku na velkò
upper5:  pop       bx                       
upper6:  ret                                

                                            ; nalezen° textovÇ poloëky v tabulce

                                            ; vstup:  ES:[BX+SI] ukazatel textu
                                            ;         DS:DI = ukazatel tabulky
                                            ;         CX = dÇlka hled. textu
                                            ; vòstup: ES:[BX+SI] nov† pozice
                                            ;         DL = po©ad. á°slo poloëky
                                            ;         AX = dÇlka poloëky tabulky

srctab:  mov       al,[di]                  ; p©eáten° dÇlky jednÇ poloëky
         mov       ah,0                     
         inc       di                       ; ukazatel tabulky - prvn° poloëka
         xor       dl,dl                    ; á°taá poloëek
srctab1: inc       dx                       ; zvò®en° á°taáe poloëek
         cmp       cl,[di]                  ; porovn†n° dÇlky textu
         jnz       srctab4                  ; nesouhlas° - dal®° poloëka
         push      ax                       ; dÇlka jednÇ poloëky
         push      bx                       ; ukazatel textu
         push      cx                       ; dÇlka textu
         push      di                       ; ukazatel tabulky
         inc       di                       ; prvn° znak poloëky
srctab2: mov       al,es:[bx+si]            ; zkoumanò znak
         cmp       al,[di]                  ; porovn†n° se znakem z tabulky
         jnz       srctab3                  ; nesouhlas° - dal®° poloëka
         inc       bx                       ; zvò®en° ukazatele textu
         inc       di                       ; zvò®en° ukazatele tabulky
         loop      srctab2                  ; dal®° znak k testu
         pop       di                       ; ukazatel tabulky - nalezeno
         pop       cx                       ; dÇlka textu
         pop       ax                       ; zru®en° pñvodn° pozice textu BX
         pop       ax                       ; dÇlka jednÇ poloëky
         or        dl,dl                    ; po©adovÇ á°slo poloëky
         ret                                
srctab3: pop       di                       ; ukazatel tabulky
         pop       cx                       ; dÇlka textu
         pop       bx                       ; ukazatel zkoumanÇho textu
         pop       ax                       ; dÇlka jednÇ poloëky
srctab4: add       di,ax                    ; adresa dal®° poloëky
         cmp       byte ptr [di],0ffh       ; je koncovò znak tabulky ?
         jnz       srctab1                  ; nen° je®tà konec
         xor       dl,dl                    ; nenalezen - á°slo poloëky = 0
         ret                                


                                            ; FUNKCE 10 - dek¢dov†n° kl†vesy

                                            ; vstup:  ES:SI = ukazatel textu
                                            ; vòstup: ES:SI = nov† pozice
                                            ;         AX = k¢d kl†vesy

fnc10:   mov       bx,1                     ; koncovò znak = 00
         call      upper                    ; p©evod textu na velk† p°smena
         jcxz      fnc106                   ; je jië konec textu
         mov       di,offset tabshf         ; tabulka kl†ves SHIFT,CTRL,ALT
         call      srctab                   ; nalezen° textovÇ poloëky v tabulce
         mov       dh,dl                    ; po©adovÇ á°slo poloëky - £schova
         jz        fnc103                   ; text nebyl nalezen
         dec       dh                       ; po©ad. á°slo poloëky - 1
         call      upper                    ; p©evod textu na velk† p°smena
         jcxz      fnc106                   ; je jië konec textu
         cmp       cx,1                     ; je pouze jeden znak ?
         jnz       fnc102                   ; nen° pr†và jeden znak
         mov       al,es:[bx+si]            ; znak k p©ek¢dov†n°
         cmp       al,"@"                   ; = "@"
         jc        fnc101                   ; men®° neë "@"
         cmp       al,"Z"                   ; = "Z"
         ja        fnc106                   ; vàt®° neë "Z"
         sub       al,40h                   ; p©evod na ©°d°c° znak
fnc101:  mov       dl,al                    ; p©ek¢dovanò znak
         jmp       short fnc104             
fnc102:  mov       di,offset tabhome        ; tabulka ©°d°c°ch kl†ves HOME,...
         call      srctab                   ; nalezen° textovÇ poloëky v tabulce
         jz        fnc103                   ; poloëka nenalezena
         add       dl,24h                   ; korekce
         jmp       short fnc104
fnc103:  mov       di,offset tabfn          ; tabulka funkán°ch kl†ves Fn
         call      srctab                   ; nalezen° textovÇ poloëky v tabulce
         jz        fnc106                   ; nenalezena
         add       dl,1ah                   ; korekce
fnc104:  ror       dh,1                     
         ror       dh,1                     
         or        dl,dh                    ; kl†vesy SHIFT,.. jako bity 6 a 7
         mov       di,offset tabkey         ; tabulka pro dek¢dov†n° k¢dñ kl†ves
fnc105:  mov       al,[di]                  ; k¢d kl†vesy
         inc       di                       
         inc       di                       
         or        al,al                    ; je posledn° k¢d ?
         jz        fnc106                   ; k¢d kl†vesy nenalezen
         cmp       al,dl                    ; porovn†n° s hledanòm k¢dem
         jnz       fnc105                   ; dal®° pokus
         dec       di                       
         mov       al,[di]                  ; p©ek¢dov†n° k¢du kl†vesy
         mov       ah,0                     
         ret                                
fnc106:  xor       ax,ax                    ; k¢d kl†vesy nenalezen
         ret                                

                                            ; vòpis k¢du kl†vesy

                                            ; vstup:  CS:SI tabulka kl†ves
                                            ;         DL = po©ad. á°slo kl†vesy
                                            ;         DS:[BX+DI] = vòst. buffer
                                            ;         CH = 0
                                            ; vòstup: DS:[BX+DI] = nov† pozice

outkey:  push      ax                       
         mov       al,cs:[si]               ; dÇlka jednÇ poloëky v tabulce
         mul       dl                       ; rel. adresa poloëky v tabulce
         add       si,ax                    ; adresa poloëky v tabulce
         inc       si                       
         mov       cl,cs:[si]               ; dÇlka textu v poloëce
         jcxz      outkey2                  
outkey1: inc       si                       ; znak poloëky textu kl†vesy
         inc       bx                       ; ukazatel vòstupn°ho textu
         mov       al,cs:[si]               ; p©eáten° znaku poloëky
         mov       [bx+di],al               ; uloëen° do bufferu
         loop      outkey1                  ; dal®° znak
         inc       bx                       ; n†sleduj°c° pozice
         mov       byte ptr [bx+di]," "     ; oddàlovac° mezera
outkey2: pop       ax                       
         ret                                

adrtab   dw        offset tabkey            ; ukazatel dek¢dovac° tabulky kl†ves


                                            ; FUNKCE 11 - vòpis k¢du kl†vesy

                                            ; vstup:  DS:[BX+DI] = vòst. buffer
                                            ;         AX = k¢d kl†vesy
                                            ; vòstup: DS:[BX+DI] = nov† adresa

fnc11:   mov       dx,ax                    ; k¢d kl†vesy
         xor       cx,cx                    ; á°taá znakñ
         mov       bx,[adrtab]              ; ukazatel dek¢dovac° tabulky kl†ves
         inc       bx                       ; dal®° kl†vesa
fnc111:  mov       al,[bx]                  ; k¢d kl†vesy
         or        al,al                    ; je ukonáovac° znak 00 ?
         jnz       fnc112                   ; nen° je®tà konec
         mov       [adrtab],offset tabkey   ; nastav. zaá. dek¢d. tabulky kl†ves
         mov       es,dx
         mov       es:[di],ch               ;
         ret       
fnc112:  push      si                       ; ukazatel tabulky kl†ves
fnc113:  mov       ah,es:[si]               ; k¢d kl†vesy
         or        ah,ah
         jz        fnc114                   ; je jië posledn°
         cmp       al,ah                    ; porovn†n° s hledanou kl†vesou
         jz        fnc115                   ; je nalezen k¢d kl†vesy
         inc       si                       ; dal®° kl†vesa
         mov       cl,es:[si]               ;
         inc       cx
         add       si,cx                    ; adresa n†sleduj°c°ho textu
         jmp       short fnc113             ; novò pokus
fnc114:  pop       si
         inc       bx
         inc       bx
         jmp       short fnc111
fnc115:  inc       bx
         mov       [adrtab],bx              ; nov† adresa ukazatele tabulky
         mov       al,[bx-2]                ; k¢d kl†vesy
         inc       si
         pop       bx
         push      si
         push      dx
         pop       ds
         xor       bx,bx
         mov       dl,al
         and       dl,0c0h
         rol       dl,1
         rol       dl,1
         mov       si,offset tabshf         ; tabulka kl†ves SHIFT,CTRL,ALT
         call      outkey                   ; vòpis k¢du kl†vesy
         mov       dl,al
         and       dl,3fh
         cmp       dl,1ah
         ja        fnc116
         add       dl,40h
         inc       bx
         mov       [bx+di],dl
         jmp       short fnc119
fnc116:  cmp       dl,24h
         ja        fnc117
         sub       dl,1bh
         mov       si,offset tabfn          ; tabulka funkán°ch kl†ves
         call      outkey                   ; vòpis k¢du kl†vesy
         jmp       short fnc119
fnc117:  cmp       dl,2bh                   ; znak "+"
         ja        fnc118
         sub       dl,25h
         mov       si,offset tabhome        ; tabulka ©°d°c°ch kl†ves
         call      outkey                   ; vòpis k¢du kl†vesy
         jmp       short fnc119
fnc118:  inc       bx
         mov       [bx+di],dl
fnc119:  cmp       bx,9
         ja        fnc11a
         inc       bx
         mov       byte ptr [bx+di]," "     ; oddàlovac° znak mezery
         jmp       short fnc119
fnc11a:  inc       bx
         mov       byte ptr [bx+di],"|"     ; znak "|"
         pop       si
         mov       cl,es:[si]
fnc11b:  inc       si
         mov       al,es:[si]               ; p©eáten° znaku k vyti®tàn°
         inc       bx
         cmp       al," "
         jnc       fnc11c                   ; nen° ©°d°c° znak
         mov       byte ptr [bx+di],"^"     ; uloëen° znaku "^" (znak s CTRL-)
         inc       bx                       ; zvò®en° ukazatele
         or        al,40h                   ; p©evod znaku na tisknutelnò znak
fnc11c:  mov       [bx+di],al               ; uloëen° znaku
         loop      fnc11b                   ; p©evod dal®°ho znaku
         inc       bx
         mov       byte ptr [bx+di],"|"     ; znak "|"
         mov       [di],bl
         ret       

tab01:                                      ; povely s CTRL-
         db        1
         db        27
         db        1
         db        80
         db        18
         db        17,'$$',15
         db        ' Povely s CTRL- ',31
         db        2,'$Kurzor...$ '
         db        4,'$Obrazovka...$'
         db        5,'$Zvl†®tn°...$',31
         db        ' S vlevo',2,'(',0fbh,')'
         db        4,'C str†nka dolñ'
         db        5,'B form†tuj',31
         db        ' X dolñ',3,'(',0f9h,')'
         db        6,'(PgDn)',13,'odstavec',31
         db        ' D vpravo (',0fah,')'
         db        4,'R str†nka nahoru'
         db        3,'L pokraáuj',31
         db        ' E nahoru (',0f8h,')'
         db        6,'(PgUp)',13,'v hled†n°',31
         db        ' A slovo vlevo'
         db        3,'Z ©†dek dolñ'
         db        7,'M konec odstavce',31
         db        ' F slovo vpravo'
         db        2,'W ©†dek nahoru'
         db        7,'<Enter>',31
         db        ' I na dal®°'
         db        25,'N vloëen°',31
         db        3,'tabel†tor'
         db        6,'$Podmenu...$'
         db        8,'©†dku',31
         db        17,'J info/displej'
         db        5,'V vkl†d†n°',31
         db        2,'$Maz†n°...$'
         db        4,'K blok/soubor'
         db        8,'zap/vyp',31
         db        ' G znaku nad'
         db        5,'O form†tov†n°/'
         db        7,'<Insert>',31
         db        3,'kurzorem'
         db        8,'nastavov†n°'
         db        6,'\ zvl†®tn° znaky',31
         db        ' H znaku vlevo'
         db        3,'P typy p°sma'
         db        7,'- z†màna znakñ',31
         db        ' T slova vpravo'
         db        2,'Q p©esuny kurzoru/'
         db        1,'] text do buff.',31
         db        ' Y ©†dku'
         db        11,'hled†n°/z†màna'
         db        3,'^ text z buff.'
         db        0

tab02:                                      ; ^J
         db        0
         db        58
         db        1
         db        80
         db        16
         db        11,' CTRL J ',31
         db        ' B',2,'©†dky displeje',31
         db        ' C',2,'barvy displeje',31
         db        ' F',2,'blik†n° zap/vyp',31
         db        ' H',2,'pomoc zap/vyp',31
         db        ' -------------------',31
         db        ' G',2,'graf.editor',31
         db        ' I',2,'pracovn° prostor',31
         db        ' D',2,'z†pis data',31
         db        ' T',2,'z†pis áasu',31
         db        ' K',2,'kalend†©/hodiny',31
         db        ' -------------------',31
         db        ' R',2,'vòpoáty v textu',31
         db        ' S',2,'sloupcovÇ souáty',31
         db        ' M',2,'sloupcovò prñmàr'
         db        0

tab03:                                      ; ^K
         db        0
         db        35
         db        1
         db        80
         db        14
         db        14,'$$'
         db        17,' CTRL K ',31
         db        17,'$Blok....$',31
         db        ' B',2,'oznaáen° zaá†tku'
         db        6,'C',2,'kop°rov†n° ',31
         db        ' K',2,'oznaáen° konce'
         db        8,'V',2,'p©esunut°',31
         db        ' N',2,'sloupcovò blok'
         db        8,'Y',2,'maz†n°',31
         db        ' H',2,'zobrazen° zap/vyp'
         db        5,'R',2,'áten°',31
         db        ' T',2,'zmàna p°sma'
         db        11,'W',2,'uloëen°',31
         db        ' G',2,'p©enos z'
         db        ' jinÇho pracovn°ho prostoru',31
         db        ' ------------------------------------------',31
         db        ' D',2,'menu souboru'
         db        10,'E',2,'maz†n° textu',31
         db        ' P',2,'menu tisku'
         db        12,'L',2,'áten° textu',31
         db        '1-5 zmàna prac. prostoru'
         db        2,'S',2,'uloëen° textu',31
         db        ' Q',2,'ukonáen° KonTextu'
         db        5,'X',2,'start programu'
         db        0

tab04:                                      ; ^O
         db        0
         db        23
         db        1
         db        80
         db        15
         db        24,'$$'
         db        20,' CTRL O ',31
         db        3,'$P©ep°naáe zap/vyp'
         db        8,'Form†tov†n°$',31
         db        ' J',2,'zarovn†v†n°'
         db        11,'B',2,'form†t. po konec textu',31
         db        ' H',2,'dàlen° slov'
         db        11,'C',2,'centrov†n° ©†dku',31
         db        ' Q',2,'dàlen° s dotazem'
         db        6,'Z',2,'dvousloupcovÇ form†tov†n°',31
         db        ' V',2,'automat.tabel†tor',31
         db        ' M',2,'<Enter>=kon.odst.'
         db        7,'$Nastaven° str†nky$',31
         db        ' P',2,'zobrazen° str†nky'
         db        5,'I',2,'menu line†lu ©†dku',31
         db        ' T',2,'zobrazen° line†lu'
         db        5,'F',2,'pravò okraj=konec ©†dku',31
         db        ' N',2,'nedokumentn° m¢d'
         db        6,'L',2,'levò okraj=pozice kurzoru',31
         db        26,'R',2,'pravò okraj=pozice kurzoru',31
         db        26,'S',2,'poáet ©†dkñ na str†nku',31
         db        ' A',2,'zaá†tek odstavce',2,0f0h
         db        3,'E',2,'zobrazen° z†hlav°/paty',31
         db        ' U',2,'neform†tovat',6,0ffh
         db        3,'O',2,'blok jako z†hlav°/pata'
         db        0

tab05:                                      ; ^P
         db        0
         db        59
         db        1
         db        80
         db        9
         db        10,' CTRL P ',31
         db        ' N=norm†ln°',31
         db        ' F=zvòraznànÇ',31
         db        ' U=podtrëenÇ',31
         db        ' K=kurz°va',31
         db        ' B=®irokÇ',31
         db        ' H=nadsazenÇ',31
         db        ' T=podsazenÇ'
         db        0,0,0,0,0,0,0,0

tab06:                                      ; ^Q
         db        0
         db        39
         db        1
         db        80
         db        13
         db        30,' CTRL Q ',31
         db        ' A',2,'hled†n°/z†màna'
         db        5,'F',2,'hled†n°',31
         db        ' M',2,'nastaven° znaáky'
         db        3,'T',2,'makrokl†vesy',31
         db        ' L',2,'navr†cen° posledn°ch zmàn   ',31
         db        10,'$Pozice kurzoru...$',31
         db        ' S',2,'zaá†tek ©†dku'
         db        6,'D',2,'konec ©†dku',31
         db        ' E',2,'horn° okraj'
         db        8,'X',2,'doln° okraj',31
         db        ' R',2,'zaá†tek textu'
         db        6,'C',2,'konec textu',31
         db        ' B',2,'zaá†tek bloku'
         db        6,'K',2,'konec bloku',31
         db        ' P',2,'na znaáku'
         db        10,'Z',2,'pozice',31
         db        14,'$Maz†n°...$',31
         db        ' H',2,'po zaá†tek ©†dku'
         db        3,'Y',2,'po konec ©†dku'
         db        0,0

tab07:                                      ; ^JC
         db        1
         db        52
         db        1
         db        80
         db        10
         db        16,' CTRL JC ',31,31
         db        2,'--- Nastaven° barev ---',31
         db        ' Zadejte á°slo barvy nebo',31
         db        ' zvolte <Enter>=beze zmàny',31,31
         db        ' Barva p°sma (0..15):',31
         db        ' Barva okol° (0..15):'
         db        0

tab08:                                      ; ^JI
         db        1
         db        54
         db        1
         db        80
         db        13
         db        13,' CTRL JI ',31,31
         db        ' - Pracovn° prostor : - ',31
         db        '$   obsah          ©†dkñ$',31
         db        31,31,31,31,31,31
         db        ' text :'
         db        7,'B volnòch',31
         db        ' makra:'
         db        7,'B volnòch'
         db        0

tab09:                                      ; ^JK
         db        1
         db        49
         db        1
         db        80
         db        16
         db        19,' CTRL JK ',31
         db        31,31,31
         db        2,'PO',2,'óT',2,'ST',2,'ÄT',2,'Pè',2,'SO',2,'NE',31
         db        ' ============================',31
         db        31,31,31,31,31,31
         db        ' ============================',31
         db        1,0fbh,2,'p©edch.'
         db        2,0fah,' n†sled.  màs°c',31
         db        1,0f9h,2,'p©edch.',2,0f8h,' n†sled.  rok '
         db        0

tab10:                                      ; ^KD
         db        1
         db        61
         db        1
         db        80
         db        17
         db        8,' CTRL KD ',31
         db        ' áti text',31
         db        ' uloë text',31
         db        ' áti blok',31
         db        ' uloë blok',31
         db        ' zru® soubor',31
         db        ' p©ejmenuj soubor',31
         db        ' kop°ruj soubor',31
         db        ' start programu',31
         db        ' uloë nastaven°',31
         db        ' konec KonTextu',31
         db        ' ----------------',31
         db        ' form†t KonText',31
         db        ' form†t Layout',31
         db        ' form†t ASCII',31
         db        ' z†loha BAK'
         db        0

tab11:
         db        0
         db        52
         db        1
         db        80
         db        3
         db        'a'
         db        0

tab12:                                      ; zad†n° str†nek k tisku
         db        1
         db        52
         db        1
         db        80
         db        11
         db        31
         db        4,'-- tisk textu   --',31
         db        2,'  Zadejte á°sla nebo     ',31
         db        '   <Enter> = ë†dn† zmàna ',31,31
         db        ' prvn° str†nka:  ',5,'1',31
         db        ' koneán† str†nka:',31
         db        ' prvn° á°slo strany:',2,'1',31
         db        ' exempl†©ñ:',11,'1'
         db        0

tab13:                                      ; ^KP
         db        1
         db        55
         db        1
         db        80
         db        7
         db        13,' CTRL KP ',31,31
         db        ' - prob°h† tisk textu -',31,31
         db        9,'d†le',31
         db        9,'p©eru®en°'
         db        0

tab14:                                      ; ^KQ
         db        1
         db        25
         db        6
         db        54
         db        14
         db        16,' CTRL KQ ',31,31
         db        3,'T°mto povelem ukoná°te',31
         db        ' KonText a navr†t°te se zpàt',31
         db        2,'do operaán°ho systÇmu !!!',31,31
         db        2,'Stisknàte <Enter> = konec',31
         db        3,'nebo <Esc> = pokraáuj'
         db        0

tab15:                                      ; ^OE
         db        0
         db        58
         db        1
         db        80
         db        7
         db        10,' CTRL OE ',31
         db        31
         db        'Jako blok se zobraz°:',31,31
         db        4,'K = z†hlav°',31
         db        4,'F = pata '
         db        0

tab16:                                      ; ^OI
         db        0
         db        53
         db        1
         db        80
         db        15
         db        14,' CTRL OI ',31
         db        2,'-- Tabel†tory/okraje --',31,31
         db        2,0fah,3,'kurzor vpravo',31
         db        2,0fbh,3,'kurzor vlevo',31
         db        ' End',2,'...k pravÇmu okraji',31
         db        ' Home ...k levÇmu okraji',31
         db        2,'L',3,'levò okraj',31
         db        2,'R',3,'pravò okraj',31
         db        ' Tab',2,'nastav/zru® tabel.',31
         db        2,'#',3,'dekadickò tabel†tor',31
         db        ' Del',2,'ru®en°/n†vrat tabel.',31
         db        ' Ret',2,'ukonáen° volby',31
         db        ' Esc',2,'p©eru®en° volby'
         db        0

tab17:                                      ; ^OO
         db        0
         db        58
         db        1
         db        80
         db        7
         db        10,' CTRL OO ',31,31
         db        ' Blok se uloë° jako: ',31,31
         db        4,'K = z†hlav° ',31
         db        4,'F = pata'
         db        0

tab18:                                      ; ^OS
         db        1
         db        46
         db        1
         db        80
         db        11
         db        22,' CTRL OS ',31,31
         db        '   Zadejte novÇ nastaven° nebo',31
         db        2,'stisknàte <Enter>=beze zmàny: ',31,31
         db        ' ©†dkñ na str†nku (4..99):',31
         db        ' z toho: z†hlav°  (0..10):',31
         db        7,'  pata   ',2,'(0..10):',31,31
         db        ' rozteá ©†dkñ :',9,'cm'
         db        0

tab19:                                      ; ^OZ
         db        1
         db        25
         db        4
         db        54
         db        14
         db        17,' CTRL OZ ',31,31
         db        3,'Tento povel zform†tuje',31
         db        4,'text na tÇto stranà',31
         db        4,'dvousloupcovà. NovÇ',31
         db        3,'form†tov†n° jië nad†le',31
         db        7,'nebude moënÇ !',31
         db        10,'Zvolte:',31
         db        5,'<Enter> = potvrzen°',31
         db        2,'<Esc> = p©eru®en° povelu'
         db        0

tab20:                                      ; volby pro hled†n°
         db        0
         db        58
         db        1
         db        80
         db        9
         db        10,' VOLBY ',31
         db        ' B',2,'zpàtnò smàr',31
         db        ' G',2,'v celÇm textu',31
         db        ' L',2,'v celÇm bloku',31
         db        ' W',2,'pouze celÇ slovo',31
         db        ' U',2,'nerozli®uje velk†',31
         db        4,'a mal† p°smena'
         db        0

tab21:                                      ; hl†®en° - Text nebude uloëen
         db        1
         db        27
         db        7
         db        54
         db        13
         db        31
         db        2,' Text v prac.prost.',31
         db        2,'nebude uloëen na disk !',31,31
         db        3,'<Enter>=pokraáov†n°',31
         db        5,'<Esc>=p©eru®en°'
         db        0

tab22:                                      ; zvl†®tn° znaky
         db        1
         db        34
         db        1
         db        80
         db        15
         db        28,' Zvl†®tn° znaky '
         db        0

tab23:                                      ; hl†®en° SETUP
         db        1
         db        25
         db        4
         db        54
         db        13
         db        19,' SETUP ',31,31
         db        ' Tato volba zpñsob°, ëe p©i',31
         db        2,'dal®°m spu®tàn° KonTextu',31
         db        2,'bude opàt pouëito stejnÇ',31
         db        3,'nastaven° parametrñ.',31,31
         db        3,'Zvolte <Enter>=uloëen°',31
         db        4,'nebo <Esc>=p©eru®en°.'
         db        0

tab24:                                      ; CTRL-KN
         db        0
         db        50
         db        1
         db        80
         db        8
         db        18,' CTRL KN ',31,31
         db        3,'Nastaven° sloupc.bloku:',31,31
         db        ' B',2,'zaá†tek (levò horn° roh)',31
         db        ' K',2,'konec (pravò doln° roh) '
         db        0

tab25:                                      ; sÇriovò tisk
         db        1
         db        50
         db        1
         db        80
         db        10
         db        31
         db        5,'--- SÇriovò tisk --',31
         db        ' Pros°m, zadejte novou volbu',31
         db        2,'nebo <Enter> = beze zmàny:',31,31
         db        ' Datovò prostor',2,'(1..5):',31
         db        ' P©eform†tov†n° ',2,'(J/N):',31
         db        0

tab26:                                      ; pauza sÇriovÇho tisku
         db        1
         db        30
         db        7
         db        51
         db        13
         db        31
         db        ' SÇriovò tisk-pauza',31
         db        ' pro',2,'vòmànu pap°ru',31,31
         db        ' pokraáov†n° = <Enter> ,',31
         db        4,'p©eru®en° = <ESC>'
         db        0
;˛
tab27:                                      ; volba KURZOR
         db        1                        ; ©†dek
         db        1                        ; pozice
         db        1                        ; aktivn° poloëka
         db        30 ;21                   ; ®°©ka okna
         db        12                       ; ©†dkñ
         db        31
         db        ' zaá†tek textu     Ctrl-PgUp',31
         db        ' konec textu       Ctrl-PgDn',31
         db        ' zaá†tek bloku     Ctrl-QB',31
         db        ' konec bloku       Ctrl-QK',31
         db        ' na znaáku         Ctrl-QP',31
         db        ' nastaven° znaáky  Ctrl-QM',31
         db        ' na danou pozici   Ctrl-QZ',31
         db        ' vyhled†n° textu   Ctrl-QF',31
         db        ' hled†n°/z†màna    Ctrl-QA',31
         db        ' dal®° hled†n°     Ctrl-L'
         db        0

tab28:                                      ; volba MAZèNã
         db        1
         db        3
         db        1
         db        28 ;21
         db        9
         db        31
         db        ' slovo vpravo    Ctrl-T',31
         db        ' po kurzor       Ctrl-QH',31
         db        ' od kurzoru      Ctrl-QY',31
         db        ' celò ©†dek      Ctrl-Y',31
         db        ' celò blok       Ctrl-KY',31
         db        ' obnoven° zmàn   Ctrl-QL',31
         db        ' celò text       Ctrl-KE'
         db        0

tab29:                                      ; volba BLOK
         db        1
         db        12
         db        1
         db        38 ;29
         db        14
         db        31
         db        ' zaá†tek bloku   Ctrl-KB',31
         db        ' konec bloku     Ctrl-KK',31
         db        ' sloupc.blok ',0dah,0c4h,' Ctrl-KNB',31
         db        ' sloupc.blok',2,0c4h,0d9h,' Ctrl-KNK',31
         db        ' maz†n°          Ctrl-KY',31
         db        ' p©em°stàn°      Ctrl-KV',31
         db        ' kop°rov†n°      Ctrl-KC',31
         db        ' p©enos z prost. Ctrl-KG',31
         db        ' áten° z disku   Ctrl-KR',31
         db        ' uloëen° na disk Ctrl-KW',31
         db        ' zmàna p°sma     Ctrl-KT',31
         db        ' oznaáen° bloku  Ctrl-KH'
         db        0

tab30:                                      ; volba PãSMO
         db        1
         db        19
         db        1
         db        37
         db        9
         db        31
         db        ' norm†ln°',31
         db        ' zvòraznànÇ',31
         db        ' podtrëenÇ',31
         db        ' kurz°va',31
         db        ' ®irokÇ',31
         db        ' nadsazenÇ',31
         db        ' podsazenÇ'
         db        0

tab31:                                      ; volba FORMèT.
         db        1
         db        26
         db        1
         db        46
         db        14
         db        31
         db        ' po konec odstav.',31
         db        ' po konec textu',31
         db        ' dvousloupcovà',31
         db        ' centruj ©†dek',31
         db        ' zarovn†v†n°',31
         db        ' rozdàlov†n°',31
         db        ' s dotazem',31
         db        ' auto-tabel†tor',31
         db        ' <Enter>=odstavec',31
         db        ' zaá†t. odstavce ',0f0h,31
         db        ' konec odstavce',2,0f1h,31
         db        ' neform†tovat',4,0ffh
         db        0

tab32:                                      ; volba STRèNKA
         db        1
         db        32
         db        1
         db        56
         db        14
         db        31
         db        ' ©†dkñ na str†nku',31
         db        ' menu line†lu ©†dkñ',31
         db        ' levò okraj=kurzor',31
         db        ' pravò okraj=kurzor',31
         db        ' pravò okraj=konec ©†d.',31
         db        ' zobrazen° z†hlav°',31
         db        ' zobrazen° paty',31
         db        ' blok jako z†hlav°',31
         db        ' blok jako pata',31
         db        ' zobraz. str†nkov†n°',31
         db        ' zobr. line†lu ©†dku',31
         db        ' nedokumentn° m¢d'
         db        0

tab33:                                      ; volba DISPLEJ
         db        1
         db        43
         db        1
         db        61
         db        8
         db        31
         db        ' 25 ©†dkñ',31
         db        ' 34 ©†dkñ',31
         db        ' 60 ©†dkñ',31
         db        ' zmàna barev',31
         db        ' n†povàda',31
         db        ' blik†n° kurz.'
         db        0

tab34:                                      ; volba EXTRA
         db        1
         db        51
         db        1
         db        69
         db        14
         db        31
         db        ' prac. prostor',31
         db        ' text do bufferu',31
         db        ' text z bufferu',31
         db        ' z†pis áasu',31
         db        ' z†pis data',31
         db        ' kalend†©',31
         db        ' grafickò editor',31
         db        ' zvl†®tn° znaky',31
         db        ' makrokl†vesy',31
         db        ' kalkul†tor',31
         db        ' sloupc. souáet',31
         db        ' sloupc. prñmàr'
         db        0

tab35:                                      ; volba TISK, ^KP
         db        1
         db        59
         db        1
         db        77
         db        15
         db        6,' CTRL KP ',31
         db        ' tisk textu',31
         db        ' sÇriovò tisk',31
         db        ' áten° instalace',31
         db        ' zmàna instalace',31
         db        ' ---------------',31
         db        ' vy®®° kvalita',31
         db        ' p°smo Elite',31
         db        ' £zkÇ p°smo',31
         db        ' proporcion†l.',31
         db        ' dvoj. p©etisk',31
         db        ' hustÇ ©†dkov.',31
         db        ' samostat.list',31
         db        ' vòmàna pap°ru'
         db        0


tabhlp   dw        offset tab01
         dw        offset tab02
         dw        offset tab03
         dw        offset tab04
         dw        offset tab05
         dw        offset tab06
         dw        offset tab07
         dw        offset tab08
         dw        offset tab09
         dw        offset tab10
         dw        offset tab11
         dw        offset tab12
         dw        offset tab13
         dw        offset tab14
         dw        offset tab15
         dw        offset tab16
         dw        offset tab17
         dw        offset tab18
         dw        offset tab19
         dw        offset tab20
         dw        offset tab21
         dw        offset tab22
         dw        offset tab23
         dw        offset tab24
         dw        offset tab25
         dw        offset tab26
         dw        offset tab27
         dw        offset tab28
         dw        offset tab29
         dw        offset tab30
         dw        offset tab31
         dw        offset tab32
         dw        offset tab33
         dw        offset tab34
         dw        offset tab35

                                            ; funkce 07 - adresa n†povàdy ES:SI
fnc07:   mov       bx,[bp+4]
         shl       bx,1
         mov       si,[bx+tabhlp]
         push      ds
         pop       es
         ret

taberr:                                     ; tabulka chybovòch hl†®en°
         db        1,'Soubor nebyl nalezen',0
         db        2,'Äten° souboru nen° moënÇ',0
         db        3,'Z†pis do souboru nen° moënò',0
         db        4,'Poëadovanò adres†© nenalezen',0
         db        5,'Nedostatek m°sta v pamàti',0
         db        6,'P©ekroáen maxim†ln° poáet ©†dkñ',0
         db        7,'" nebyl nalezen',0
         db        8,'û†dek je moc dlouhò',0
         db        9,'NepovolenÇ zad†n°',0
         db        10,'Nen° oznaáen ë†dnò blok',0
         db        11,'Pamàü makrokl†ves je pln†',0
         db        12,'Tisk†rna nen° v provozu',0
         db        13,'Chybnò form†t dat',0
         db        15,'Soubor s t°mto jmÇnem jië existuje',0
         db        16,'Zdrojovò a c°lovò soubor jsou identickÇ',0
         db        17,'Prostor @ nen° dosud vytistàn.',0
         db        18,'Sloupcovò blok nemñëe bòt zaps†n do souboru',0
         db        19,'Nen° oznaáen ë†dnò sloupcovò blok',0
         db        20,'Kurzor se mus° nach†zet vpravo od pravÇho okraje',0
         db        21,'Mus° bòt zad†n soubor EXE nebo COM',0
         db        50,'Nepovolenò matematickò vòraz',0
         db        51,'P©eteáen° desetinnÇ teáky',0
         db        52,'Dàlen° nulou',0
         db        53,'Chybnò argument',0
         db        54,'Chyba argumentu',0
         db        99,'Intern° chyba',0
         db        100,'Disketov† mechanika nepracuje',0
         db        153,'Neoáek†vanò konec souboru',0
         db        196,'P©eteáen° á°sla Integer',0
         db        240,'Disk je plnò',0
         db        241,'NepovolenÇ jmÇno souboru',0
         db        0,'Bl°ëe neuráiteln† chyba',0


                                            ; FUNKCE 08 - adresa chybovòch hl†®en°

fnc08:   mov       si,offset taberr         ; tabulka hl†®en°
         push      ds                       ; nastaven° ES = DS
         pop       es
         ret

;˛
                                            ; fonty 8x8 bodñ
fnt8x8   db        0,0,0,0,0,0,0,0                         ; 0
         db        7eh,0c3h,0a5h,81h,0a5h,99h,0c3h,7eh     ; 1
         db        7eh,0ffh,0dbh,0ffh,0dbh,0e7h,0ffh,7eh   ; 2
         db        0,6ch,0feh,0feh,7ch,38h,10h,0           ; 3
         db        0,10h,38h,7ch,0feh,7ch,38h,10h          ; 4
         db        0,38h,38h,0d6h,0feh,0d6h,10h,38h        ; 5
         db        0,10h,38h,7ch,0feh,0d6h,10h,38h         ; 6
         db        0,0,18h,3ch,3ch,18h,0,0                 ; 7
         db        0ffh,0ffh,0e7h,0c3h,0c3h,0e7h,0ffh,0ffh ; 8
         db        0,3ch,66h,42h,42h,66h,3ch,0             ; 9
         db        0ffh,0c3h,99h,0bdh,0bdh,99h,0c3h,0ffh   ; 10
         db        0fh,7,0fh,7dh,0cch,0cch,0cch,78h        ; 11
         db        3ch,66h,66h,66h,3ch,18h,7eh,18h         ; 12
         db        30h,38h,3ch,34h,30h,0d0h,0f0h,60h       ; 13
         db        3fh,33h,3fh,33h,33h,0ddh,0ffh,66h       ; 14
         db        99h,5ah,24h,0c3h,0c3h,24h,5ah,99h       ; 15
         db        40h,70h,7ch,7eh,7ch,70h,40h,0           ; 16
         db        2h,0eh,3eh,7eh,3eh,0eh,2,0              ; 17
         db        18h,3ch,7eh,18h,18h,7eh,3ch,18h         ; 18
         db        6ch,6ch,6ch,6ch,6ch,0,6ch,0             ; 19
         db        7eh,0f4h,0f4h,74h,34h,34h,34h,0         ; 20
         db        3ch,60h,38h,6ch,6ch,38h,0ch,78h         ; 21  " "
         db        0,0,0,0,7eh,7eh,7eh,0                   ; 22
         db        18h,3ch,7eh,18h,7eh,3ch,18h,7eh         ; 23
         db        18h,3ch,7eh,18h,18h,18h,18h,18h         ; 24
         db        18h,18h,18h,18h,18h,7eh,3ch,18h         ; 25
         db        0,4,6,0ffh,0ffh,6,4,0                   ; 26
         db        0,20h,60h,0ffh,0ffh,60h,20h,0           ; 27
         db        0,60h,60h,60h,60h,7eh,0,0               ; 28
         db        0,24h,66h,0ffh,0ffh,66h,24h,0           ; 29
         db        0,8,1ch,3eh,7fh,7fh,7fh,0               ; 30
         db        0,7fh,7fh,7fh,3eh,1ch,8,0               ; 31
         db        0,0,0,0,0,0,0,0                         ; 32  " "
         db        18h,18h,18h,18h,18h,0,18h,0             ; 33  "!"
         db        6ch,6ch,6ch,0,0,0,0,0                   ; 34  "
         db        6ch,6ch,0feh,6ch,0feh,6ch,6ch,0         ; 35  "#"
         db        18h,3eh,58h,3ch,1ah,7ch,18h,0           ; 36  "$"
         db        0,63h,66h,0ch,18h,33h,63h,0             ; 37  "%"
         db        1ch,36h,1ch,3bh,6eh,66h,3bh,0           ; 38  "&"
         db        18h,18h,30h,0,0,0,0,0                   ; 39  "'"
         db        0ch,18h,30h,30h,30h,18h,0ch,0           ; 40  "("
         db        30h,18h,0ch,0ch,0ch,18h,30h,0           ; 41  ")"
         db        0,66h,3ch,0ffh,3ch,66h,0,0              ; 42  "*"
         db        0,18h,18h,7eh,18h,18h,0,0               ; 43  "+"
         db        0,0,0,0,0,18h,18h,30h                   ; 44  ","
         db        0,0,0,7eh,0,0,0,0                       ; 45  "-"
         db        0,0,0,0,0,18h,18h,0                     ; 46  "."
         db        6h,0ch,18h,30h,60h,0c0h,80h,0           ; 47  "/"
         db        7ch,0c6h,0ceh,0d6h,0e6h,0c6h,7ch,0      ; 48  "0"
         db        18h,38h,18h,18h,18h,18h,18h,0           ; 49  "1"
         db        3ch,66h,6,0ch,18h,30h,7eh,0             ; 50  "2"
         db        3ch,66h,6,1ch,6,66h,3ch,0               ; 51  "3"
         db        1ch,3ch,6ch,0cch,0feh,0ch,0ch,0         ; 52  "4"
         db        7eh,60h,7ch,6,6,66h,3ch,0               ; 53  "5"
         db        3ch,66h,60h,7ch,66h,66h,3ch,0           ; 54  "6"
         db        7eh,6,6,0ch,18h,18h,18h,0               ; 55  "7"
         db        3ch,66h,66h,3ch,66h,66h,3ch,0           ; 56  "8"
         db        3ch,66h,66h,3eh,0ch,18h,30h,0           ; 57  "9"
         db        0,0,18h,18h,0,18h,18h,0                 ; 58  ":"
         db        0,0,18h,18h,0,18h,18h,30h               ; 59  ";"
         db        0ch,18h,30h,60h,30h,18h,0ch,0           ; 60  "<"
         db        0,0,7eh,0,0,7eh,0,0                     ; 61  "="
         db        60h,30h,18h,0ch,18h,30h,60h,0           ; 62  ">"
         db        3ch,66h,6,0ch,18h,0,18h,0               ; 63  "?"
         db        7ch,0c6h,0deh,0deh,0deh,0c0h,7ch,0      ; 64  "@"
         db        38h,6ch,0c6h,0c6h,0feh,0c6h,0c6h,0      ; 65  "A"
         db        0fch,0c6h,0c6h,0fch,0c6h,0c6h,0fch,0    ; 66  "B"
         db        3ch,66h,0c0h,0c0h,0c0h,66h,3ch,0        ; 67  "C"
         db        0f8h,0cch,0c6h,0c6h,0c6h,0cch,0f8h,0    ; 68  "D"
         db        0feh,0c0h,0c0h,0f8h,0c0h,0c0h,0feh,0    ; 69  "E"
         db        0feh,0c0h,0c0h,0f8h,0c0h,0c0h,0c0h,0    ; 70  "F"
         db        3ch,66h,0c0h,0c0h,0ceh,66h,3eh,0        ; 71  "G"
         db        0c6h,0c6h,0c6h,0feh,0c6h,0c6h,0c6h,0    ; 72  "H"
         db        78h,30h,30h,30h,30h,30h,78h,0           ; 73  "I"
         db        6h,6,6,6,0c6h,0c6h,7ch,0                ; 74  "J"
         db        0c6h,0cch,0d8h,0f0h,0d8h,0cch,0c6h,0    ; 75  "K"
         db        0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,0feh,0    ; 76  "L"
         db        0c6h,0eeh,0feh,0d6h,0c6h,0c6h,0c6h,0    ; 77  "M"
         db        0c6h,0e6h,0f6h,0deh,0ceh,0c6h,0c6h,0    ; 78  "N"
         db        38h,6ch,0c6h,0c6h,0c6h,6ch,38h,0        ; 79  "O"
         db        0fch,0c6h,0c6h,0fch,0c0h,0c0h,0c0h,0    ; 80  "P"
         db        38h,6ch,0c6h,0c6h,0dah,6ch,36h,0        ; 81  "Q"
         db        0fch,0c6h,0c6h,0fch,0cch,0c6h,0c6h,0    ; 82  "R"
         db        7ch,0c6h,0c0h,7ch,6,0c6h,7ch,0          ; 83  "S"
         db        0fch,30h,30h,30h,30h,30h,30h,0          ; 84  "T"
         db        0c6h,0c6h,0c6h,0c6h,0c6h,0c6h,7ch,0     ; 85  "U"
         db        0c6h,0c6h,0c6h,0c6h,0c6h,6ch,38h,0      ; 86  "V"
         db        0c6h,0c6h,0c6h,0d6h,0feh,0eeh,0c6h,0    ; 87  "W"
         db        0c6h,0c6h,6ch,38h,6ch,0c6h,0c6h,0       ; 88  "X"
         db        66h,66h,66h,3ch,18h,18h,18h,0           ; 89  "Y"
         db        0feh,6,0ch,18h,30h,60h,0feh,0           ; 90  "Z"
         db        3ch,30h,30h,30h,30h,30h,3ch,0           ; 91  "["
         db        0c0h,60h,30h,18h,0ch,6,2,0              ; 92  "\"
         db        3ch,0ch,0ch,0ch,0ch,0ch,3ch,0           ; 93  "]"
         db        8h,1ch,36h,63h,0,0,0,0                  ; 94  "^"
         db        0,0,0,0,0,0,0,0ffh                      ; 95  "_"
         db        30h,18h,0ch,0,0,0,0,0                   ; 96  "`"
         db        0,0,7ch,6,7eh,0c6h,7eh,0                ; 97  "a"
         db        0c0h,0c0h,0fch,0c6h,0c6h,0c6h,0fch,0    ; 98  "b"
         db        0,0,7ch,0c6h,0c0h,0c6h,7ch,0            ; 99  "c"
         db        6h,6,7eh,0c6h,0c6h,0c6h,7eh,0           ; 100 "d"
         db        0,0,7ch,0c6h,0feh,0c0h,7ch,0            ; 101 "e"
         db        3ch,66h,60h,0f8h,60h,60h,60h,0          ; 102 "f"
         db        0,0,7eh,0c6h,0c6h,7eh,6,0fch            ; 103 "g"
         db        0c0h,0c0h,0fch,0c6h,0c6h,0c6h,0c6h,0    ; 104 "h"
         db        18h,0,18h,18h,18h,18h,18h,0             ; 105 "i"
         db        0ch,0,0ch,0ch,0ch,0ch,0cch,78h          ; 106 "j"
         db        0c0h,0c0h,0c6h,0cch,0f8h,0cch,0c6h,0    ; 107 "k"
         db        18h,18h,18h,18h,18h,18h,18h,0           ; 108 "l"
         db        0,0,6ch,0feh,0d6h,0c6h,0c6h,0           ; 109 "m"
         db        0,0,0fch,0c6h,0c6h,0c6h,0c6h,0          ; 110 "n"
         db        0,0,7ch,0c6h,0c6h,0c6h,7ch,0            ; 111 "o"
         db        0,0,0fch,0c6h,0c6h,0fch,0c0h,0c0h       ; 112 "p"
         db        0,0,7eh,0c6h,0c6h,7eh,6,6               ; 113 "q"
         db        0,0,0fch,0c6h,0c0h,0c0h,0c0h,0          ; 114 "r"
         db        0,0,7ch,0c0h,7ch,6,0fch,0               ; 115 "s"
         db        60h,60h,0fch,60h,60h,66h,3ch,0          ; 116 "t"
         db        0,0,0c6h,0c6h,0c6h,0c6h,7eh,0           ; 117 "u"
         db        0,0,0c6h,0c6h,0c6h,6ch,38h,0            ; 118 "v"
         db        0,0,0c6h,0c6h,0d6h,0feh,6ch,0           ; 119 "w"
         db        0,0,0c6h,6ch,38h,6ch,0c6h,0             ; 120 "x"
         db        0,0,0c6h,0c6h,0c6h,7eh,6,0fch           ; 121 "y"
         db        0,0,7eh,0ch,18h,30h,7eh,0               ; 122 "z"
         db        0eh,18h,18h,70h,18h,18h,0eh,0           ; 123 "{"
         db        18h,18h,18h,0,18h,18h,18h,0             ; 124 "|"
         db        70h,18h,18h,0eh,18h,18h,70h,0           ; 125 "}"
         db        32h,4ch,0,0,0,0,0,0                     ; 126 "~"
         db        0,18h,3ch,66h,0c3h,0c3h,0ffh,0          ; 127 ""
         db        66h,3ch,66h,0c0h,0c0h,66h,3ch,0         ; 128 "Ä"
         db        66h,0,0c6h,0c6h,0c6h,0c6h,7eh,0         ; 129 "Å"
         db        0ch,18h,7ch,0c6h,0feh,0c0h,7ch,0        ; 130 "Ç"
         db        96h,66h,6,7eh,0c6h,0c6h,7eh,0           ; 131 "É"
         db        66h,0,7ch,6,7eh,0c6h,7eh,0              ; 132 "Ñ"
         db        0cch,78h,0f8h,0cch,0c6h,0cch,0f8h,0     ; 133 "Ö"
         db        66h,3ch,7eh,18h,18h,18h,18h,0           ; 134 "Ü"
         db        66h,3ch,7ch,0c6h,0c0h,0c6h,7ch,0        ; 135 "á"
         db        66h,3ch,7ch,0c6h,0feh,0c0h,7ch,0        ; 136 "à"
         db        0cch,78h,0fch,0c0h,0f0h,0c0h,0fch,0     ; 137 "â"
         db        0cch,0cch,0d8h,0c0h,0c0h,0c0h,0feh,0    ; 138 "ä"
         db        0ch,18h,3ch,18h,18h,18h,3ch,0           ; 139 "ã"
         db        35h,32h,30h,30h,30h,30h,30h,0           ; 140 "å"
         db        1bh,1bh,18h,18h,18h,18h,18h,0           ; 141 "ç"
         db        0c6h,38h,6ch,0c6h,0feh,0c6h,0c6h,0      ; 142 "é"
         db        13h,3bh,6ch,0c6h,0feh,0c6h,0c6h,0       ; 143 "è"
         db        0ch,18h,7eh,60h,78h,60h,7eh,0           ; 144 "ê"
         db        66h,3ch,7eh,0ch,18h,30h,7eh,0           ; 145 "ë"
         db        6ch,0feh,0ch,18h,30h,60h,0feh,0         ; 146 "í"
         db        3ch,66h,0,7ch,0c6h,0c6h,7ch,0           ; 147 "ì"
         db        66h,0,7ch,0c6h,0c6h,0c6h,7ch,0          ; 148 "î"
         db        3h,3bh,6ch,0c6h,0c6h,6ch,38h,0          ; 149 "ï"
         db        3ch,66h,3ch,0c6h,0c6h,0c6h,7eh,0        ; 150 "ñ"
         db        0ch,0dah,0c6h,0c6h,0c6h,0c6h,7ch,0      ; 151 "ó"
         db        0ch,18h,0c6h,0c6h,0c6h,7eh,6,0fch       ; 152 "ò"
         db        0c6h,38h,6ch,0c6h,0c6h,6ch,38h,0        ; 153 "ô"
         db        66h,0,0c6h,0c6h,0c6h,0c6h,7ch,0         ; 154 "ö"
         db        24h,7eh,0c0h,7ch,6,0c6h,7ch,0           ; 155 "õ"
         db        0dbh,0ceh,0c0h,0c0h,0c0h,0c0h,0feh,0    ; 156 "ú"
         db        0ch,5ah,66h,3ch,18h,18h,18h,0           ; 157 "ù"
         db        0cch,78h,0fch,0c6h,0fch,0c6h,0c6h,0     ; 158 "û"
         db        66h,66h,0f4h,60h,60h,66h,3ch,0          ; 159 "ü"
         db        0ch,18h,7ch,6,7eh,0c6h,7eh,0            ; 160 "†"
         db        0ch,18h,0,18h,18h,18h,18h,0             ; 161 "°"
         db        0ch,18h,0,7ch,0c6h,0c6h,7ch,0           ; 162 "¢"
         db        18h,30h,0,0c6h,0c6h,0c6h,7eh,0          ; 163 "£"
         db        6ch,38h,0fch,0c6h,0c6h,0c6h,0c6h,0      ; 164 "§"
         db        66h,3ch,0e6h,0f6h,0deh,0ceh,0c6h,0      ; 165 "•"
         db        18h,0a4h,0dah,0c6h,0c6h,0c6h,7ch,0      ; 166 "¶"
         db        7ch,82h,38h,6ch,0c6h,6ch,38h,0          ; 167 "ß"
         db        66h,3ch,7eh,0c0h,7ch,6,0fch,0           ; 168 "®"
         db        0cch,78h,0fch,0c6h,0c0h,0c0h,0c0h,0     ; 169 "©"
         db        18h,30h,0dch,0e6h,0c0h,0c0h,0c0h,0      ; 170 "™"
         db        18h,30h,0fch,0c6h,0fch,0c6h,0c6h,0      ; 171 "´"
         db        40h,0c0h,44h,4ch,54h,1eh,4,0            ; 172 "¨"
         db        3ch,60h,38h,6ch,6ch,38h,0ch,78h         ; 173 "≠"
         db        0,36h,6ch,0d8h,6ch,36h,0,0              ; 174 "Æ"
         db        0,0d8h,6ch,36h,6ch,0d8h,0,0             ; 175 "Ø"
         db        22h,88h,22h,88h,22h,88h,22h,88h         ; 176 "∞"
         db        55h,0aah,55h,0aah,55h,0aah,55h,0aah     ; 177 "±"
         db        0ddh,77h,0ddh,77h,0ddh,77h,0ddh,77h     ; 178 "≤"
         db        18h,18h,18h,18h,18h,18h,18h,18h         ; 179 "≥"
         db        18h,18h,18h,18h,0f8h,18h,18h,18h        ; 180 "¥"
         db        18h,18h,0f8h,18h,0f8h,18h,18h,18h       ; 181 "µ"
         db        66h,66h,66h,66h,0e6h,66h,66h,66h        ; 182 "∂"
         db        0,0,0,0,0feh,66h,66h,66h                ; 183 "∑"
         db        0,0,0f8h,18h,0f8h,18h,18h,18h           ; 184 "∏"
         db        66h,66h,0e6h,6,0e6h,66h,66h,66h         ; 185 "π"
         db        66h,66h,66h,66h,66h,66h,66h,66h         ; 186 "∫"
         db        0,0,0feh,6,0e6h,66h,66h,66h             ; 187 "ª"
         db        66h,66h,0e6h,6,0feh,0,0,0               ; 188 "º"
         db        66h,66h,66h,66h,0feh,0,0,0              ; 189 "Ω"
         db        18h,18h,0f8h,18h,0f8h,0,0,0             ; 190 "æ"
         db        0,0,0,0,0f8h,18h,18h,18h                ; 191 "ø"
         db        18h,18h,18h,18h,1fh,0,0,0               ; 192 "¿"
         db        18h,18h,18h,18h,0ffh,0,0,0              ; 193 "¡"
         db        0,0,0,0,0ffh,18h,18h,18h                ; 194 "¬"
         db        18h,18h,18h,18h,1fh,18h,18h,18h         ; 195 "√"
         db        0,0,0,0,0ffh,0,0,0                      ; 196 "ƒ"
         db        18h,18h,18h,18h,0ffh,18h,18h,18h        ; 197 "≈"
         db        18h,18h,1fh,18h,1fh,18h,18h,18h         ; 198 "∆"
         db        66h,66h,66h,66h,67h,66h,66h,66h         ; 199 "«"
         db        66h,66h,67h,60h,7fh,0,0,0               ; 200 "»"
         db        0,0,7fh,60h,67h,66h,66h,66h             ; 201 "…"
         db        66h,66h,0e7h,0,0ffh,0,0,0               ; 202 " "
         db        0,0,0ffh,0,0e7h,66h,66h,66h             ; 203 "À"
         db        66h,66h,67h,60h,67h,66h,66h,66h         ; 204 "Ã"
         db        0,0,0ffh,0,0ffh,0,0,0                   ; 205 "Õ"
         db        66h,66h,0e7h,0,0e7h,66h,66h,66h         ; 206 "Œ"
         db        18h,18h,0ffh,0,0ffh,0,0,0               ; 207 "œ"
         db        66h,66h,66h,66h,0ffh,0,0,0              ; 208 "–"
         db        0,0,0ffh,0,0ffh,18h,18h,18h             ; 209 "—"
         db        0,0,0,0,0ffh,66h,66h,66h                ; 210 "“"
         db        66h,66h,66h,66h,7fh,0,0,0               ; 211 "”"
         db        18h,18h,1fh,18h,1fh,0,0,0               ; 212 "‘"
         db        0,0,1fh,18h,1fh,18h,18h,18h             ; 213 "’"
         db        0,0,0,0,7fh,66h,66h,66h                 ; 214 "÷"
         db        66h,66h,66h,66h,0ffh,66h,66h,66h        ; 215 "◊"
         db        18h,18h,0ffh,18h,0ffh,18h,18h,18h       ; 216 "ÿ"
         db        18h,18h,18h,18h,0f8h,0,0,0              ; 217 "Ÿ"
         db        0,0,0,0,1fh,18h,18h,18h                 ; 218 "⁄"
         db        0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh ; 219 "€"
         db        0,0,0,0,0ffh,0ffh,0ffh,0ffh             ; 220 "‹"
         db        0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h ; 221 "›"
         db        0fh,0fh,0fh,0fh,0fh,0fh,0fh,0fh         ; 222 "ﬁ"
         db        0ffh,0ffh,0ffh,0ffh,0,0,0,0             ; 223 "ﬂ"
         db        0,0,76h,0dch,0cch,0dch,76h,0            ; 224 "‡"
         db        3ch,66h,7ch,66h,66h,7ch,60h,60h         ; 225 "·"
         db        7eh,66h,60h,60h,60h,60h,60h,0           ; 226 "‚"
         db        0,0,0feh,6ch,6ch,6ch,66h,0              ; 227 "„"
         db        0feh,0c6h,60h,30h,60h,0c6h,0feh,0       ; 228 "‰"
         db        0,0,0,7eh,0d8h,0d8h,70h,0               ; 229 "Â"
         db        0,0,66h,66h,66h,7ch,60h,0c0h            ; 230 "Ê"
         db        0,0,7eh,18h,18h,18h,0ch,0               ; 231 "Á"
         db        7eh,18h,3ch,66h,66h,3ch,18h,7eh         ; 232 "Ë"
         db        38h,6ch,0c6h,0feh,0c6h,6ch,38h,0        ; 233 "È"
         db        7ch,0c6h,0c6h,0c6h,0c6h,6ch,0eeh,0      ; 234 "Í"
         db        3ch,66h,30h,7ch,0c6h,0c6h,7ch,0         ; 235 "Î"
         db        0,0,66h,0dbh,0dbh,0dbh,66h,0            ; 236 "Ï"
         db        3h,6,3ch,66h,66h,3ch,60h,0c0h           ; 237 "Ì"
         db        1eh,30h,60h,7eh,60h,30h,1eh,0           ; 238 "Ó"
         db        3ch,66h,66h,66h,66h,66h,66h,0           ; 239 "Ô"
         db        0,7eh,0,7eh,0,7eh,0,0                   ; 240 ""
         db        18h,18h,7eh,18h,18h,0,7eh,0             ; 241 "Ò"
         db        30h,18h,0ch,18h,30h,0,7eh,0             ; 242 "Ú"
         db        0ch,18h,30h,18h,0ch,0,7eh,0             ; 243 "Û"
         db        0eh,1bh,18h,18h,18h,18h,18h,18h         ; 244 "Ù"
         db        18h,18h,18h,18h,18h,18h,0d8h,70h        ; 245 "ı"
         db        0,18h,0,7eh,0,18h,0,0                   ; 246 "ˆ"
         db        0,72h,9ch,0,72h,9ch,0,0                 ; 247 "˜"
         db        0,3ch,66h,66h,3ch,0,0,0                 ; 248 "¯"
         db        0,0,0,18h,18h,0,0,0                     ; 249 "˘"
         db        0,0,0,0,18h,0,0,0                       ; 250 "˙"
         db        7h,7,0ch,0ch,98h,0d8h,70h,30h           ; 251 "˚"
         db        78h,6ch,6ch,6ch,6ch,0,0,0               ; 252 "¸"
         db        38h,6ch,18h,30h,7ch,0,0,0               ; 253 "˝"
         db        0,0,78h,78h,78h,78h,0,0                 ; 254 "˛"
         db        0,0,0,0,0,0,0,0                         ; 255

                                            ; fonty 14x8 bodñ
;˛
fnt14x8  db        0,0,0,0,0,0,0                           ; 0
         db        0,0,0,0,0,0,0                      
         db        0,0,7eh,81h,0a5h,81h,81h                ; 1
         db        0bdh,99h,81h,7eh,0,0,0             
         db        0,0,7eh,0ffh,0dbh,0ffh,0ffh             ; 2
         db        0c3h,0e7h,0ffh,7eh,0,0,0           
         db        0,0,0,6ch,0feh,0feh,0feh                ; 3
         db        0feh,7ch,38h,10h,0,0,0             
         db        0,0,0,10h,38h,7ch,0feh                  ; 4
         db        7ch,38h,10h,0,0,0,0                
         db        0,0,18h,3ch,3ch,0e7h,0e7h               ; 5
         db        0e7h,18h,18h,3ch,0,0,0             
         db        0,0,18h,3ch,7eh,0ffh,0ffh               ; 6
         db        7eh,18h,18h,3ch,0,0,0              
         db        0,0,0,0,0,18h,3ch                       ; 7
         db        3ch,18h,0,0,0,0,0                  
         db        0ffh,0ffh,0ffh,0ffh,0ffh,0e7h,0c3h      ; 8
         db        0c3h,0e7h,0ffh,0ffh,0ffh,0ffh,0ffh 
         db        0,0,0,0,3ch,66h,42h                     ; 9
         db        42h,66h,3ch,0,0,0,0                
         db        0ffh,0ffh,0ffh,0ffh,0c3h,99h,0bdh       ; 10
         db        0bdh,99h,0c3h,0ffh,0ffh,0ffh,0ffh  
         db        0,0,1eh,0eh,1ah,32h,78h                 ; 11
         db        0cch,0cch,0cch,78h,0,0,0           
         db        0,0,3ch,66h,66h,66h,3ch                 ; 12
         db        18h,7eh,18h,18h,0,0,0              
         db        0,0,3fh,33h,3fh,30h,30h                 ; 13
         db        30h,70h,0f0h,0e0h,0,0,0            
         db        0,0,7fh,63h,7fh,63h,63h                 ; 14
         db        63h,67h,0e7h,0e6h,0c0h,0,0         
         db        0,0,18h,18h,0dbh,3ch,0e7h               ; 15
         db        3ch,0dbh,18h,18h,0,0,0             
         db        0,0,80h,0c0h,0e0h,0f8h,0feh             ; 16
         db        0f8h,0e0h,0c0h,80h,0,0,0           
         db        0,0,2,6,0eh,3eh,0feh                    ; 17
         db        3eh,0eh,6,2,0,0,0                  
         db        0,0,18h,3ch,7eh,18h,18h                 ; 18
         db        18h,7eh,3ch,18h,0,0,0              
         db        0,0,66h,66h,66h,66h,66h                 ; 19
         db        66h,0,66h,66h,0,0,0                
         db        0,0,7fh,0dbh,0dbh,0dbh,7bh              ; 20
         db        1bh,1bh,1bh,1bh,0,0,0              
         db        0,7ch,0c6h,60h,38h,6ch,0c6h             ; 21  " "
         db        0c6h,6ch,38h,0ch,0c6h,7ch,0        
         db        0,0,0,0,0,0,0                           ; 22
         db        0,0feh,0feh,0feh,0,0,0             
         db        0,0,18h,3ch,7eh,18h,18h                 ; 23
         db        18h,7eh,3ch,18h,7eh,0,0            
         db        0,0,18h,3ch,7eh,18h,18h                 ; 24
         db        18h,18h,18h,18h,0,0,0              
         db        0,0,18h,18h,18h,18h,18h                 ; 25
         db        18h,7eh,3ch,18h,0,0,0              
         db        0,0,0,0,18h,0ch,0feh                    ; 26
         db        0ch,18h,0,0,0,0,0                  
         db        0,0,0,0,30h,60h                         ; 27
         db        0feh,60h,30h,0,0,0,0,0             
         db        0,0,0,0,0,0c0h,0c0h                     ; 28
         db        0c0h,0feh,0,0,0,0,0                
         db        0,0,0,0,28h,6ch,0feh                    ; 29
         db        6ch,28h,0,0,0,0,0                  
         db        0,0,0,10h,38h,38h,7ch                   ; 30
         db        7ch,0feh,0feh,0,0,0,0              
         db        0,0,0,0feh,0feh,7ch,7ch                 ; 31
         db        38h,38h,10h,0,0,0,0                
         db        0,0,0,0,0,0,0                           ; 32  " "
         db        0,0,0,0,0,0,0                      
         db        0,0,18h,3ch,3ch,3ch,18h                 ; 33  "!"
         db        18h,0,18h,18h,0,0,0                
         db        0,66h,66h,66h,24h,0,0                   ; 34  "
         db        0,0,0,0,0,0,0                      
         db        0,0,6ch,6ch,0feh,6ch,6ch                ; 35  "#"
         db        6ch,0feh,6ch,6ch,0,0,0             
         db        18h,18h,7ch,0c6h,0c2h,0c0h,7ch          ; 36  "$"
         db        6,86h,0c6h,7ch,18h,18h,0           
         db        0,0,0,0,0c2h,0c6h,0ch                   ; 37  "%"
         db        18h,30h,66h,0c6h,0,0,0             
         db        0,0,38h,6ch,6ch,38h,76h                 ; 38  "&"
         db        0dch,0cch,0cch,76h,0,0,0           
         db        0,30h,30h,30h,60h,0,0                   ; 39  "'"
         db        0,0,0,0,0,0,0                      
         db        0,0,0ch,18h,30h,30h,30h                 ; 40  "("
         db        30h,30h,18h,0ch,0,0,0              
         db        0,0,30h,18h,0ch,0ch,0ch                 ; 41  ")"
         db        0ch,0ch,18h,30h,0,0,0              
         db        0,0,0,0,66h,3ch,0ffh                    ; 42  "*"
         db        3ch,66h,0,0,0,0,0                  
         db        0,0,0,0,18h,18h,7eh                     ; 43  "+"
         db        18h,18h,0,0,0,0,0                  
         db        0,0,0,0,0,0,0                           ; 44  ","
         db        0,18h,18h,18h,30h,0,0              
         db        0,0,0,0,0,0                             ; 45  "-"
         db        0feh,0,0,0,0,0,0,0                 
         db        0,0,0,0,0,0,0                           ; 46  "."
         db        0,0,18h,18h,0,0,0                  
         db        0,0,2,6,0ch,18h,30h                     ; 47  "/"
         db        60h,0c0h,80h,0,0,0,0               
         db        0,0,7ch,0c6h,0ceh,0deh,0f6h             ; 48  "0"
         db        0e6h,0c6h,0c6h,7ch,0,0,0           
         db        0,0,18h,38h,78h,18h,18h                 ; 49  "1"
         db        18h,18h,18h,7eh,0,0,0              
         db        0,0,7ch,0c6h,6,0ch,18h                  ; 50  "2"
         db        30h,60h,0c6h,0feh,0,0,0            
         db        0,0,7ch,0c6h,6,6,3ch                    ; 51  "3"
         db        6,6,0c6h,7ch,0,0,0                 
         db        0,0,0ch,1ch,3ch,6ch,0cch                ; 52  "4"
         db        0feh,0ch,0ch,1eh,0,0,0             
         db        0,0,0feh,0c0h,0c0h,0c0h,0fch            ; 53  "5"
         db        6,6,0c6h,7ch,0,0,0                 
         db        0,0,38h,60h,0c0h,0c0h,0fch              ; 54  "6"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0,0,0feh,0c6h,6,0ch,18h                 ; 55  "7"
         db        30h,30h,30h,30h,0,0,0              
         db        0,0,7ch,0c6h,0c6h,0c6h,7ch              ; 56  "8"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0,0,7ch,0c6h,0c6h,0c6h,7eh              ; 57  "9"
         db        6,6,0ch,78h,0,0,0                  
         db        0,0,0,18h,18h,0,0                       ; 58  ":"
         db        0,18h,18h,0,0,0,0                  
         db        0,0,0,18h,18h,0,0                       ; 59  ";"
         db        0,18h,18h,30h,0,0,0                
         db        0,0,6,0ch,18h,30h,60h                   ; 60  "<"
         db        30h,18h,0ch,6,0,0,0                
         db        0,0,0,0,0,7eh,0                         ; 61  "="
         db        0,7eh,0,0,0,0,0                    
         db        0,0,60h,30h,18h,0ch,6                   ; 62  ">"
         db        0ch,18h,30h,60h,0,0,0              
         db        0,0,7ch,0c6h,0c6h,0ch,18h               ; 63  "?"
         db        18h,0,18h,18h,0,0,0                
         db        0,0,7ch,0c6h,0c6h,0deh,0deh             ; 64  "@"
         db        0deh,0dch,0c0h,7ch,0,0,0           
         db        0,0,10h,38h,6ch,0c6h,0c6h               ; 65  "A"
         db        0feh,0c6h,0c6h,0c6h,0,0,0          
         db        0,0,0fch,66h,66h,66h,7ch                ; 66  "B"
         db        66h,66h,66h,0fch,0,0,0             
         db        0,0,3ch,66h,0c2h,0c0h,0c0h              ; 67  "C"
         db        0c0h,0c2h,66h,3ch,0,0,0            
         db        0,0,0f8h,6ch,66h,66h,66h                ; 68  "D"
         db        66h,66h,6ch,0f8h,0,0,0             
         db        0,0,0feh,66h,62h,68h,78h                ; 69  "E"
         db        68h,62h,66h,0feh,0,0,0             
         db        0,0,0feh,66h,62h,68h,78h                ; 70  "F"
         db        68h,60h,60h,0f0h,0,0,0             
         db        0,0,3ch,66h,0c2h,0c0h,0c0h              ; 71  "G"
         db        0deh,0c6h,66h,3ah,0,0,0            
         db        0,0,0c6h,0c6h,0c6h,0c6h,0feh            ; 72  "H"
         db        0c6h,0c6h,0c6h,0c6h,0,0,0          
         db        0,0,3ch,18h,18h,18h,18h                 ; 73  "I"
         db        18h,18h,18h,3ch,0,0,0              
         db        0,0,1eh,0ch,0ch,0ch,0ch                 ; 74  "J"
         db        0ch,0cch,0cch,78h,0,0,0            
         db        0,0,0e6h,66h,6ch,6ch,78h                ; 75  "K"
         db        6ch,6ch,66h,0e6h,0,0,0             
         db        0,0,0f0h,60h,60h,60h,60h                ; 76  "L"
         db        60h,62h,66h,0feh,0,0,0             
         db        0,0,0c6h,0eeh,0feh,0feh,0d6h            ; 77  "M"
         db        0c6h,0c6h,0c6h,0c6h,0,0,0          
         db        0,0,0c6h,0e6h,0f6h,0feh,0deh            ; 78  "N"
         db        0ceh,0c6h,0c6h,0c6h,0,0,0          
         db        0,0,38h,6ch,0c6h,0c6h,0c6h              ; 79  "O"
         db        0c6h,0c6h,6ch,38h,0,0,0            
         db        0,0,0fch,66h,66h,66h,7ch                ; 80  "P"
         db        60h,60h,60h,0f0h,0,0,0             
         db        0,0,7ch,0c6h,0c6h,0c6h,0c6h             ; 81  "Q"
         db        0d6h,0deh,7ch,0ch,0eh,0,0          
         db        0,0,0fch,66h,66h,66h,7ch                ; 82  "R"
         db        6ch,66h,66h,0e6h,0,0,0             
         db        0,0,7ch,0c6h,0c6h,60h,38h               ; 83  "S"
         db        0ch,0c6h,0c6h,7ch,0,0,0            
         db        0,0,7eh,7eh,5ah,18h,18h                 ; 84  "T"
         db        18h,18h,18h,3ch,0,0,0              
         db        0,0,0c6h,0c6h,0c6h,0c6h,0c6h            ; 85  "U"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0,0,0c6h,0c6h,0c6h,0c6h,0c6h            ; 86  "V"
         db        0c6h,6ch,38h,10h,0,0,0             
         db        0,0,0c6h,0c6h,0c6h,0c6h,0d6h            ; 87  "W"
         db        0d6h,0feh,7ch,6ch,0,0,0            
         db        0,0,0c6h,0c6h,6ch,38h,38h               ; 88  "X"
         db        38h,6ch,0c6h,0c6h,0,0,0            
         db        0,0,66h,66h,66h,66h,3ch                 ; 89  "Y"
         db        18h,18h,18h,3ch,0,0,0              
         db        0,0,0feh,0c6h,8ch,18h,30h               ; 90  "Z"
         db        60h,0c2h,0c6h,0feh,0,0,0           
         db        0,0,3ch,30h,30h,30h,30h                 ; 91  "["
         db        30h,30h,30h,3ch,0,0,0              
         db        0,0,80h,0c0h,0e0h,70h,38h               ; 92  "\"
         db        1ch,0eh,6,2,0,0,0                  
         db        0,0,3ch,0ch,0ch,0ch,0ch                 ; 93  "]"
         db        0ch,0ch,0ch,3ch,0,0,0              
         db        10h,38h,6ch,0c6h,0,0,0                  ; 94  "^"
         db        0,0,0,0,0,0,0                      
         db        0,0,0,0,0,0,0                           ; 95  "_"
         db        0,0,0,0,0,0ffh,0                   
         db        30h,30h,18h,0,0,0,0                     ; 96  "`"
         db        0,0,0,0,0,0,0                      
         db        0,0,0,0,0,78h,0ch                       ; 97  "a"
         db        7ch,0cch,0cch,76h,0,0,0            
         db        0,0,0e0h,60h,60h,78h,6ch                ; 98  "b"
         db        66h,66h,66h,7ch,0,0,0              
         db        0,0,0,0,0,7ch,0c6h                      ; 99  "c"
         db        0c0h,0c0h,0c6h,7ch,0,0,0           
         db        0,0,1ch,0ch,0ch,3ch,6ch                 ; 100 "d"
         db        0cch,0cch,0cch,76h,0,0,0           
         db        0,0,0,0,0,7ch,0c6h                      ; 101 "e"
         db        0feh,0c0h,0c6h,7ch,0,0,0           
         db        0,0,38h,6ch,64h,60h,0f0h                ; 102 "f"
         db        60h,60h,60h,0f0h,0,0,0             
         db        0,0,0,0,0,76h,0cch                      ; 103 "g"
         db        0cch,0cch,7ch,0ch,0cch,78h,0       
         db        0,0,0e0h,60h,60h,6ch,76h                ; 104 "h"
         db        66h,66h,66h,0e6h,0,0,0             
         db        0,0,18h,18h,0,38h,18h                   ; 105 "i"
         db        18h,18h,18h,3ch,0,0,0              
         db        0,0,6,6,0,0eh,6                         ; 106 "j"
         db        6,6,6,66h,66h,3ch,0                
         db        0,0,0e0h,60h,60h,66h,6ch                ; 107 "k"
         db        78h,6ch,66h,0e6h,0,0,0             
         db        0,0,38h,18h,18h,18h,18h                 ; 108 "l"
         db        18h,18h,18h,3ch,0,0,0              
         db        0,0,0,0,0,0ech,0feh                     ; 109 "m"
         db        0d6h,0d6h,0d6h,0c6h,0,0,0          
         db        0,0,0,0,0,0dch,66h                      ; 110 "n"
         db        66h,66h,66h,66h,0,0,0              
         db        0,0,0,0,0,7ch,0c6h                      ; 111 "o"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0,0,0,0,0,0dch,66h                      ; 112 "p"
         db        66h,66h,7ch,60h,60h,0f0h,0         
         db        0,0,0,0,0,76h,0cch                      ; 113 "q"
         db        0cch,0cch,7ch,0ch,0ch,1eh,0        
         db        0,0,0,0,0,0dch,76h                      ; 114 "r"
         db        66h,60h,60h,0f0h,0,0,0             
         db        0,0,0,0,0,7ch,0c6h                      ; 115 "s"
         db        70h,1ch,0c6h,7ch,0,0,0             
         db        0,0,10h,30h,30h,0fch,30h                ; 116 "t"
         db        30h,30h,36h,1ch,0,0,0              
         db        0,0,0,0,0,0cch,0cch                     ; 117 "u"
         db        0cch,0cch,0cch,76h,0,0,0           
         db        0,0,0,0,0,66h,66h                       ; 118 "v"
         db        66h,66h,3ch,18h,0,0,0              
         db        0,0,0,0,0,0c6h,0c6h                     ; 119 "w"
         db        0d6h,0d6h,0feh,6ch,0,0,0           
         db        0,0,0,0,0,0c6h,6ch                      ; 120 "x"
         db        38h,38h,6ch,0c6h,0,0,0             
         db        0,0,0,0,0,0c6h,0c6h                     ; 121 "y"
         db        0c6h,0c6h,7eh,6,0ch,0f8h,0         
         db        0,0,0,0,0,0feh,0cch                     ; 122 "z"
         db        18h,30h,66h,0feh,0,0,0             
         db        0,0,0eh,18h,18h,18h,70h                 ; 123 "{"
         db        18h,18h,18h,0eh,0,0,0              
         db        0,0,18h,18h,18h,18h,0                   ; 124 "|"
         db        18h,18h,18h,18h,0,0,0              
         db        0,0,70h,18h,18h,18h,0eh                 ; 125 "}"
         db        18h,18h,18h,70h,0,0,0              
         db        0,0,76h,0dch,0,0,0                      ; 126 "~"
         db        0,0,0,0,0,0,0                      
         db        0,0,0,0,10h,38h,6ch                     ; 127 ""
         db        0c6h,0c6h,0feh,0,0,0,0             
         db        66h,3ch,3ch,66h,0c2h,0c0h,0c0h          ; 128 "Ä"
         db        0c0h,0c2h,66h,3ch,0,0,0            
         db        0,0,0cch,0cch,0,0cch,0cch               ; 129 "Å"
         db        0cch,0cch,0cch,76h,0,0,0           
         db        0,0ch,18h,30h,0,7ch,0c6h                ; 130 "Ç"
         db        0feh,0c0h,0c6h,7ch,0,0,0           
         db        68h,30h,1ch,0ch,0ch,3ch,6ch             ; 131 "É"
         db        0cch,0cch,0cch,7eh,0,0,0           
         db        0,0,0cch,0cch,0,78h,0ch                 ; 132 "Ñ"
         db        7ch,0cch,0cch,76h,0,0,0            
         db        0cch,78h,0f8h,6ch,66h,66h,66h           ; 133 "Ö"
         db        66h,66h,6ch,0f8h,0,0,0             
         db        66h,3ch,7eh,7eh,5ah,18h,18h             ; 134 "Ü"
         db        18h,18h,18h,3ch,0,0,0              
         db        0,0,66h,3ch,0,7ch,0c6h                  ; 135 "á"
         db        0c0h,0c0h,0c6h,7ch,0,0,0           
         db        0,0,66h,3ch,0,7ch,0c6h                  ; 136 "à"
         db        0feh,0c0h,0c6h,7ch,0,0,0           
         db        66h,3ch,0feh,66h,62h,68h,78h            ; 137 "â"
         db        68h,62h,66h,0feh,0,0,0             
         db        0,6,0f6h,64h,60h,60h,60h                ; 138 "ä"
         db        60h,62h,66h,0feh,0,0,0             
         db        0ch,18h,3ch,18h,18h,18h,18h             ; 139 "ã"
         db        18h,18h,18h,3ch,0,0,0              
         db        36h,1ch,70h,30h,30h,30h,30h             ; 140 "å"
         db        30h,30h,30h,78h,0,0,0              
         db        6h,6,74h,30h,30h,30h,30h                ; 141 "ç"
         db        30h,30h,30h,78h,0,0,0              
         db        0,0c6h,0c6h,10h,38h,6ch,0c6h            ; 142 "é"
         db        0c6h,0feh,0c6h,0c6h,0,0,0          
         db        6h,0ch,10h,38h,6ch,0c6h,0c6h            ; 143 "è"
         db        0feh,0c6h,0c6h,0c6h,0,0,0          
         db        18h,30h,60h,0,0feh,66h,60h              ; 144 "ê"
         db        7ch,60h,66h,0feh,0,0,0             
         db        0,0,0cch,78h,0,0feh,0cch                ; 145 "ë"
         db        18h,30h,66h,0feh,0,0,0             
         db        66h,3ch,0feh,0c6h,8ch,18h,30h           ; 146 "í"
         db        60h,0c2h,0c6h,0feh,0,0,0           
         db        0,10h,38h,6ch,0,7ch,0c6h                ; 147 "ì"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0,0,0c6h,0c6h,0,7ch,0c6h                ; 148 "î"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0ch,18h,38h,6ch,0c6h,0c6h,0c6h          ; 149 "ï"
         db        0c6h,0c6h,6ch,38h,0,0,0            
         db        0,38h,6ch,38h,0,0cch,0cch               ; 150 "ñ"
         db        0cch,0cch,0cch,76h,0,0,0           
         db        0ch,18h,0c6h,0c6h,0c6h,0c6h,0c6h        ; 151 "ó"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0,0,0ch,18h,0,0c6h,0c6h                 ; 152 "ò"
         db        0c6h,0c6h,7eh,6,0ch,0f8h,0         
         db        0,0c6h,0c6h,38h,6ch,0c6h,0c6h           ; 153 "ô"
         db        0c6h,0c6h,6ch,38h,0,0,0            
         db        0,0c6h,0c6h,0,0c6h,0c6h,0c6h            ; 154 "ö"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        66h,3ch,7ch,0c6h,0c6h,60h,38h           ; 155 "õ"
         db        0ch,0c6h,0c6h,7ch,0,0,0            
         db        36h,1ch,0f0h,60h,60h,60h,60h            ; 156 "ú"
         db        60h,62h,66h,0feh,0,0,0             
         db        6h,0ch,66h,66h,66h,66h,3ch              ; 157 "ù"
         db        18h,18h,18h,3ch,0,0,0              
         db        66h,3ch,0fch,66h,66h,66h,7ch            ; 158 "û"
         db        6ch,66h,66h,0f6h,0,0,0             
         db        36h,1ch,10h,30h,30h,0fch,30h            ; 159 "ü"
         db        30h,30h,36h,1ch,0,0,0              
         db        0,18h,30h,60h,0,78h,0ch                 ; 160 "†"
         db        7ch,0cch,0cch,76h,0,0,0            
         db        0,0ch,18h,30h,0,38h,18h                 ; 161 "°"
         db        18h,18h,18h,3ch,0,0,0              
         db        0,18h,30h,60h,0,7ch,0c6h                ; 162 "¢"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0,18h,30h,60h,0,0cch,0cch               ; 163 "£"
         db        0cch,0cch,0cch,76h,0,0,0           
         db        0,0,66h,3ch,0,0dch,66h                  ; 164 "§"
         db        66h,66h,66h,66h,0,0,0              
         db        66h,3ch,0c6h,0e6h,0f6h,0feh,0deh        ; 165 "•"
         db        0ceh,0c6h,0c6h,0c6h,0,0,0          
         db        3ch,66h,3ch,0c6h,0c6h,0c6h,0c6h         ; 166 "¶"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        7ch,0c6h,38h,6ch,0c6h,0c6h,0c6h         ; 167 "ß"
         db        0c6h,0c6h,6ch,38h,0,0,0            
         db        0,0,66h,3ch,0,7ch,0c6h                  ; 168 "®"
         db        70h,1ch,0c6h,7ch,0,0,0             
         db        0,0,0cch,78h,0,0dch,76h                 ; 169 "©"
         db        66h,60h,60h,0f0h,0,0,0             
         db        0,0,0ch,18h,0,0dch,76h                  ; 170 "™"
         db        66h,60h,60h,0f0h,0,0,0             
         db        0ch,18h,0fch,66h,66h,66h,7ch            ; 171 "´"
         db        6ch,66h,66h,0e6h,0,0,0             
         db        0,0c0h,0c0h,0c6h,0cch,0d8h,30h          ; 172 "¨"
         db        66h,0ceh,9eh,3eh,6,6,0             
         db        0,0,7ch,0c6h,60h,38h,6ch                ; 173 "≠"
         db        0c6h,6ch,38h,0ch,0c6h,7ch,0        
         db        0,0,0,0,36h,6ch,0d8h                    ; 174 "Æ"
         db        6ch,36h,0,0,0,0,0                  
         db        0,0,0,0,0d8h,6ch,36h                    ; 175 "Ø"
         db        6ch,0d8h,0,0,0,0,0                 
         db        11h,44h,11h,44h,11h,44h,11h             ; 176 "∞"
         db        44h,11h,44h,11h,44h,11h,44h        
         db        55h,0aah,55h,0aah,55h,0aah,55h          ; 177 "±"
         db        0aah,55h,0aah,55h,0aah,55h,0aah    
         db        0ddh,77h,0ddh,77h,0ddh,77h,0ddh         ; 178 "≤"
         db        77h,0ddh,77h,0ddh,77h,0ddh,77h     
         db        18h,18h,18h,18h,18h,18h,18h             ; 179 "≥"
         db        18h,18h,18h,18h,18h,18h,18h        
         db        18h,18h,18h,18h,18h,18h,18h             ; 180 "¥"
         db        0f8h,18h,18h,18h,18h,18h,18h       
         db        18h,18h,18h,18h,18h,0f8h,18h            ; 181 "µ"
         db        0f8h,18h,18h,18h,18h,18h,18h       
         db        36h,36h,36h,36h,36h,36h,36h             ; 182 "∂"
         db        0f6h,36h,36h,36h,36h,36h,36h       
         db        0,0,0,0,0,0,0                           ; 183 "∑"
         db        0feh,36h,36h,36h,36h,36h,36h       
         db        0,0,0,0,0,0f8h,18h                      ; 184 "∏"
         db        0f8h,18h,18h,18h,18h,18h,18h       
         db        36h,36h,36h,36h,36h,0f6h,6              ; 185 "π"
         db        0f6h,36h,36h,36h,36h,36h,36h       
         db        36h,36h,36h,36h,36h,36h,36h             ; 186 "∫"
         db        36h,36h,36h,36h,36h,36h,36h        
         db        0,0,0,0,0,0feh,6                        ; 187 "ª"
         db        0f6h,36h,36h,36h,36h,36h,36h       
         db        36h,36h,36h,36h,36h,0f6h,6              ; 188 "º"
         db        0feh,0,0,0,0,0,0                   
         db        36h,36h,36h,36h,36h,36h,36h             ; 189 "Ω"
         db        0feh,0,0,0,0,0,0                   
         db        18h,18h,18h,18h,18h,0f8h,18h            ; 190 "æ"
         db        0f8h,0,0,0,0,0,0                   
         db        0,0,0,0,0,0,0                           ; 191 "ø"
         db        0f8h,18h,18h,18h,18h,18h,18h       
         db        18h,18h,18h,18h,18h,18h,18h             ; 192 "¿"
         db        1fh,0,0,0,0,0,0                    
         db        18h,18h,18h,18h,18h,18h,18h             ; 193 "¡"
         db        0ffh,0,0,0,0,0,0                   
         db        0,0,0,0,0,0,0                           ; 194 "¬"
         db        0ffh,18h,18h,18h,18h,18h,18h       
         db        18h,18h,18h,18h,18h,18h,18h             ; 195 "√"
         db        1fh,18h,18h,18h,18h,18h,18h        
         db        0,0,0,0,0,0,0                           ; 196 "ƒ"
         db        0ffh,0,0,0,0,0,0                   
         db        18h,18h,18h,18h,18h,18h,18h             ; 197 "≈"
         db        0ffh,18h,18h,18h,18h,18h,18h       
         db        18h,18h,18h,18h,18h,1fh,18h             ; 198 "∆"
         db        1fh,18h,18h,18h,18h,18h,18h        
         db        36h,36h,36h,36h,36h,36h,36h             ; 199 "«"
         db        37h,36h,36h,36h,36h,36h,36h        
         db        36h,36h,36h,36h,36h,37h,30h             ; 200 "»"
         db        3fh,0,0,0,0,0,0                    
         db        0,0,0,0,0,3fh,30h                       ; 201 "…"
         db        37h,36h,36h,36h,36h,36h,36h        
         db        36h,36h,36h,36h,36h,0f7h,0              ; 202 " "
         db        0ffh,0,0,0,0,0,0                   
         db        0,0,0,0,0,0ffh,0                        ; 203 "À"
         db        0f7h,36h,36h,36h,36h,36h,36h       
         db        36h,36h,36h,36h,36h,37h,30h             ; 204 "Ã"
         db        37h,36h,36h,36h,36h,36h,36h        
         db        0,0,0,0,0,0ffh,0                        ; 205 "Õ"
         db        0ffh,0,0,0,0,0,0                   
         db        36h,36h,36h,36h,36h,0f7h,0              ; 206 "Œ"
         db        0f7h,36h,36h,36h,36h,36h,36h       
         db        18h,18h,18h,18h,18h,0ffh,0              ; 207 "œ"
         db        0ffh,0,0,0,0,0,0                   
         db        36h,36h,36h,36h,36h,36h,36h             ; 208 "–"
         db        0ffh,0,0,0,0,0,0                   
         db        0,0,0,0,0,0ffh,0                        ; 209 "—"
         db        0ffh,18h,18h,18h,18h,18h,18h       
         db        0,0,0,0,0,0,0                           ; 210 "“"
         db        0ffh,36h,36h,36h,36h,36h,36h       
         db        36h,36h,36h,36h,36h,36h,36h             ; 211 "”"
         db        3fh,0,0,0,0,0,0                    
         db        18h,18h,18h,18h,18h,1fh,18h             ; 212 "‘"
         db        1fh,0,0,0,0,0,0                    
         db        0,0,0,0,0,1fh,18h                       ; 213 "’"
         db        1fh,18h,18h,18h,18h,18h,18h        
         db        0,0,0,0,0,0,0                           ; 214 "÷"
         db        3fh,36h,36h,36h,36h,36h,36h        
         db        36h,36h,36h,36h,36h,36h,36h             ; 215 "◊"
         db        0ffh,36h,36h,36h,36h,36h,36h       
         db        18h,18h,18h,18h,18h,0ffh,18h            ; 216 "ÿ"
         db        0ffh,18h,18h,18h,18h,18h,18h       
         db        18h,18h,18h,18h,18h,18h,18h             ; 217 "Ÿ"
         db        0f8h,0,0,0,0,0,0                   
         db        0,0,0,0,0,0,0                           ; 218 "⁄"
         db        1fh,18h,18h,18h,18h,18h,18h        
         db        0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh      ; 219 "€"
         db        0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh 
         db        0,0,0,0,0,0,0                           ; 220 "‹"
         db        0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh 
         db        0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h      ; 221 "›"
         db        0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h 
         db        0fh,0fh,0fh,0fh,0fh,0fh,0fh             ; 222 "ﬁ"
         db        0fh,0fh,0fh,0fh,0fh,0fh,0fh        
         db        0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh      ; 223 "ﬂ"
         db        0,0,0,0,0,0,0                      
         db        0,0,0,0,0,76h,0dch                      ; 224 "‡"
         db        0d8h,0d8h,0dch,76h,0,0,0           
         db        0,0,0,0,7ch,0c6h,0fch                   ; 225 "·"
         db        0c6h,0c6h,0fch,0c0h,0c0h,40h,0     
         db        0,0,0feh,0c6h,0c6h,0c0h,0c0h            ; 226 "‚"
         db        0c0h,0c0h,0c0h,0c0h,0,0,0          
         db        0,0,0,0,0feh,6ch,6ch                    ; 227 "„"
         db        6ch,6ch,6ch,6ch,0,0,0              
         db        0,0,0feh,0c6h,60h,30h,18h               ; 228 "‰"
         db        30h,60h,0c6h,0feh,0,0,0            
         db        0,0,0,0,0,7eh,0d8h                      ; 229 "Â"
         db        0d8h,0d8h,0d8h,70h,0,0,0           
         db        0,0,0,0,66h,66h,66h                     ; 230 "Ê"
         db        66h,7ch,60h,60h,0c0h,0,0           
         db        0,0,0,0,76h,0dch,18h                    ; 231 "Á"
         db        18h,18h,18h,18h,0,0,0              
         db        0,0,7eh,18h,3ch,66h,66h                 ; 232 "Ë"
         db        66h,3ch,18h,7eh,0,0,0              
         db        0,0,38h,6ch,0c6h,0c6h,0feh              ; 233 "È"
         db        0c6h,0c6h,6ch,38h,0,0,0            
         db        0,0,38h,6ch,0c6h,0c6h,0c6h              ; 234 "Í"
         db        6ch,6ch,6ch,0eeh,0,0,0             
         db        0,0,1eh,30h,18h,0ch,3eh                 ; 235 "Î"
         db        66h,66h,66h,3ch,0,0,0              
         db        0,0,0,0,0,7eh,0dbh                      ; 236 "Ï"
         db        0dbh,7eh,0,0,0,0,0                 
         db        0,0,3,6,7eh,0dbh,0dbh                   ; 237 "Ì"
         db        0f3h,7eh,60h,0c0h,0,0,0            
         db        0,0,1ch,30h,60h,60h,7ch                 ; 238 "Ó"
         db        60h,60h,30h,1ch,0,0,0              
         db        0,0,0,7ch,0c6h,0c6h,0c6h                ; 239 "Ô"
         db        0c6h,0c6h,0c6h,0c6h,0,0,0          
         db        0,0,0,0feh,0,0,0feh                     ; 240 ""
         db        0,0,0feh,0,0,0,0                   
         db        0,0,0,18h,18h,7eh,18h                   ; 241 "Ò"
         db        18h,0,0,0ffh,0,0,0                 
         db        0,0,30h,18h,0ch,6,0ch                   ; 242 "Ú"
         db        18h,30h,0,7eh,0,0,0                
         db        0,0,0ch,18h,30h,60h,30h                 ; 243 "Û"
         db        18h,0ch,0,7eh,0,0,0                
         db        0,0,0eh,1bh,1bh,18h,18h                 ; 244 "Ù"
         db        18h,18h,18h,18h,18h,18h,18h        
         db        18h,18h,18h,18h,18h,18h,18h             ; 245 "ı"
         db        18h,0d8h,0d8h,70h,0,0,0            
         db        0,0,0,18h,18h,0,7eh                     ; 246 "ˆ"
         db        0,18h,18h,0,0,0,0                  
         db        0,0,0,0,76h,0dch,0                      ; 247 "˜"
         db        76h,0dch,0,0,0,0,0                 
         db        0,38h,6ch,6ch,38h,0,0                   ; 248 "¯"
         db        0,0,0,0,0,0,0                      
         db        0,0,0,0,0,0,18h                         ; 249 "˘"
         db        18h,0,0,0,0,0,0                    
         db        0,0,0,0,0,0,0                           ; 250 "˙"
         db        18h,0,0,0,0,0,0                    
         db        0,0fh,0ch,0ch,0ch,0ch,0ch               ; 251 "˚"
         db        0ech,6ch,3ch,1ch,0,0,0             
         db        0,0d8h,6ch,6ch,6ch,6ch,6ch              ; 252 "¸"
         db        0,0,0,0,0,0,0                      
         db        0,70h,0d8h,30h,60h,0c8h,0f8h            ; 253 "˝"
         db        0,0,0,0,0,0,0                      
         db        0,0,0,0,7ch,7ch,7ch                     ; 254 "˛"
         db        7ch,7ch,7ch,0,0,0,0                
         db        0,0,0,0,0,0,0                           ; 255
         db        0,0,0,0,0,0,0
;˛
fnt19x8  label     byte
         db        00000000b                ; 0
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 1
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111110b
         db        10000001b
         db        10000001b
         db        10100101b
         db        10000001b
         db        10000001b
         db        10111101b
         db        10011001b
         db        10000001b
         db        10000001b
         db        01111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 2
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111110b
         db        11111111b
         db        11111111b
         db        11011011b
         db        11111111b
         db        11111111b
         db        11000011b
         db        11100111b
         db        11111111b
         db        11111111b
         db        01111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 3
         db        00000000b
         db        00000000b
         db        00000000b
         db        01101100b
         db        11111110b
         db        11111110b
         db        11111110b
         db        11111110b
         db        11111110b
         db        11111110b
         db        11111110b
         db        01111100b
         db        00111000b
         db        00010000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 4
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00010000b
         db        00111000b
         db        01111100b
         db        11111110b
         db        11111110b
         db        01111100b
         db        00111000b
         db        00010000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 5
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00111100b
         db        00111100b
         db        00011000b
         db        11100111b
         db        11100111b
         db        11100111b
         db        11011011b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 6
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00111100b
         db        01111110b
         db        11111111b
         db        11111111b
         db        11111111b
         db        01111110b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 7
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00111100b
         db        01111110b
         db        01111110b
         db        00111100b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        11111111b                ; 8
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11100111b
         db        11000011b
         db        11000011b
         db        11000011b
         db        11100111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b

         db        00000000b                ; 9
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00111100b
         db        01100110b
         db        01000010b
         db        01000010b
         db        01000010b
         db        01100110b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        11111111b                ; 10
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11000011b
         db        10011001b
         db        10111101b
         db        10111101b
         db        10111101b
         db        10011001b
         db        11000011b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b

         db        00000000b                ; 11
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011110b
         db        00001110b
         db        00011010b
         db        00110010b
         db        01111000b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01111000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 12
         db        00000000b
         db        00000000b
         db        00111100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        00111100b
         db        00011000b
         db        00011000b
         db        01111110b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 13
         db        00000000b
         db        00000000b
         db        00000000b
         db        00111111b
         db        00110011b
         db        00111111b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        01110000b
         db        11110000b
         db        11100000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 14
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111111b
         db        01100011b
         db        01111111b
         db        01100011b
         db        01100011b
         db        01100011b
         db        01100011b
         db        01100111b
         db        11100111b
         db        11100110b
         db        11000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 15
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        11011011b
         db        00111100b
         db        11100111b
         db        00111100b
         db        11011011b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 16
         db        00000000b
         db        10000000b
         db        11000000b
         db        11100000b
         db        11110000b
         db        11111000b
         db        11111100b
         db        11111110b
         db        11111100b
         db        11111000b
         db        11110000b
         db        11100000b
         db        11000000b
         db        10000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 17
         db        00000000b
         db        00000010b
         db        00000110b
         db        00001110b
         db        00011110b
         db        00111110b
         db        01111110b
         db        11111110b
         db        01111110b
         db        00111110b
         db        00011110b
         db        00001110b
         db        00000110b
         db        00000010b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 18
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00111100b
         db        01111110b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        01111110b
         db        00111100b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 19
         db        00000000b
         db        00000000b
         db        00000000b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        00000000b
         db        01100110b
         db        01100110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 20
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111111b
         db        11011011b
         db        11011011b
         db        11011011b
         db        01111011b
         db        00011011b
         db        00011011b
         db        00011011b
         db        00011011b
         db        00011011b
         db        00011011b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 21
         db        00000000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        01100000b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        01101100b
         db        00111000b
         db        00001100b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 22
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111110b
         db        11111110b
         db        11111110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 23
         db        00000000b
         db        00000000b
         db        00011000b
         db        00111100b
         db        01111110b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        01111110b
         db        00111100b
         db        00011000b
         db        01111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 24
         db        00000000b
         db        00000000b
         db        00011000b
         db        00111100b
         db        01111110b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 25
         db        00000000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        01111110b
         db        00111100b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 26
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00010000b
         db        00011000b
         db        00011100b
         db        11111110b
         db        00011100b
         db        00011000b
         db        00010000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 27
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00010000b
         db        00110000b
         db        01110000b
         db        11111110b
         db        01110000b
         db        00110000b
         db        00010000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 28
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 29
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00100100b
         db        01100110b
         db        11100111b
         db        11111111b
         db        11100111b
         db        01100110b
         db        00100100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 30
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00010000b
         db        00010000b
         db        00111000b
         db        00111000b
         db        01111100b
         db        01111100b
         db        11111110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 31
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111110b
         db        11111110b
         db        01111100b
         db        01111100b
         db        00111000b
         db        00111000b
         db        00010000b
         db        00010000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 32 " "
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 33 "!"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00111100b
         db        00111100b
         db        00111100b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 34 """
         db        00000000b
         db        00000000b
         db        01100110b
         db        01100110b
         db        01100110b
         db        00100100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 35 "#"
         db        00000000b
         db        00000000b
         db        00000000b
         db        01101100b
         db        01101100b
         db        11111110b
         db        01101100b
         db        01101100b
         db        01101100b
         db        01101100b
         db        01101100b
         db        11111110b
         db        01101100b
         db        01101100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 36 "$"
         db        00000000b
         db        00011000b
         db        00011000b
         db        01111100b
         db        11000110b
         db        11000010b
         db        11000000b
         db        11100000b
         db        01111000b
         db        00001110b
         db        00000110b
         db        10000110b
         db        11000110b
         db        01111100b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 37 "%"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11000110b
         db        11000110b
         db        00001100b
         db        00011000b
         db        00011000b
         db        00110000b
         db        01100000b
         db        01100000b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 38 "&"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00111000b
         db        01101100b
         db        01101100b
         db        01101100b
         db        00111000b
         db        01110110b
         db        11011110b
         db        11011100b
         db        11001100b
         db        11001100b
         db        01110110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 39 "'"
         db        00000000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        01100000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 40 "("
         db        00000000b
         db        00000000b
         db        00000000b
         db        00001100b
         db        00011000b
         db        00011000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00011000b
         db        00011000b
         db        00001100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 41 ")"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00110000b
         db        00011000b
         db        00011000b
         db        00001100b
         db        00001100b
         db        00001100b
         db        00001100b
         db        00001100b
         db        00011000b
         db        00011000b
         db        00110000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 42 "*"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        01101100b
         db        00111000b
         db        11111110b
         db        00111000b
         db        01101100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 43 "+"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        01111110b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 44 ","
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00110000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 45 "-"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 46 "."
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 47 "/"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000010b
         db        00000110b
         db        00001100b
         db        00001100b
         db        00011000b
         db        00110000b
         db        00110000b
         db        01100000b
         db        11000000b
         db        10000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 48 "0"
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000110b
         db        11001110b
         db        11001110b
         db        11010110b
         db        11100110b
         db        11100110b
         db        11000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 49 "1"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00111000b
         db        01111000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        01111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 50 "2"
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000110b
         db        00000110b
         db        00001100b
         db        00011000b
         db        00110000b
         db        01100000b
         db        11000000b
         db        11000110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 51 "3"
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        00000110b
         db        00000110b
         db        00000110b
         db        00111100b
         db        00000110b
         db        00000110b
         db        00000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 52 "4"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00001100b
         db        00011100b
         db        00111100b
         db        01101100b
         db        11001100b
         db        11001100b
         db        11111110b
         db        00001100b
         db        00001100b
         db        00001100b
         db        00011110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 53 "5"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111110b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11111100b
         db        00000110b
         db        00000110b
         db        00000110b
         db        00000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 54 "6"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00111100b
         db        01100000b
         db        11000000b
         db        11000000b
         db        11111100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 55 "7"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111110b
         db        11000110b
         db        00000110b
         db        00000110b
         db        00001100b
         db        00011000b
         db        00011000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 56 "8"
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 57 "9"
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111110b
         db        00000110b
         db        00000110b
         db        00000110b
         db        00001100b
         db        01111000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 58 ":"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 59 ";"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00110000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 60 "<"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000110b
         db        00001100b
         db        00011000b
         db        00110000b
         db        01100000b
         db        11000000b
         db        01100000b
         db        00110000b
         db        00011000b
         db        00001100b
         db        00000110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 61 "="
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111110b
         db        00000000b
         db        00000000b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 62 ">"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11000000b
         db        01100000b
         db        00110000b
         db        00011000b
         db        00001100b
         db        00000110b
         db        00001100b
         db        00011000b
         db        00110000b
         db        01100000b
         db        11000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 63 "?"
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000110b
         db        00001100b
         db        00001100b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 64 "@"
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11011110b
         db        11011110b
         db        11011110b
         db        11011100b
         db        11000000b
         db        11000000b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 65 "A"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00010000b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11111110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 66 "B"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01111100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        11111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 67 "C"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00111100b
         db        01100110b
         db        11000010b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000010b
         db        01100110b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 68 "D"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111000b
         db        01101100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01101100b
         db        11111000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 69 "E"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111110b
         db        01100110b
         db        01100010b
         db        01100000b
         db        01101000b
         db        01111000b
         db        01101000b
         db        01100000b
         db        01100010b
         db        01100110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 70 "F"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111110b
         db        01100110b
         db        01100010b
         db        01100000b
         db        01101000b
         db        01111000b
         db        01101000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        11110000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 71 "G"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00111100b
         db        01100110b
         db        11000010b
         db        11000000b
         db        11000000b
         db        11011110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01100110b
         db        00111010b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 72 "H"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11111110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 73 "I"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00111100b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 74 "J"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011110b
         db        00001100b
         db        00001100b
         db        00001100b
         db        00001100b
         db        00001100b
         db        00001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01111000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 75 "K"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11100110b
         db        01100110b
         db        01101100b
         db        01101100b
         db        01111000b
         db        01111000b
         db        01111000b
         db        01101100b
         db        01101100b
         db        01100110b
         db        11100110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 76 "L"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11110000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100010b
         db        01100110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 77 "M"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11000110b
         db        11101110b
         db        11111110b
         db        11111110b
         db        11010110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 78 "N"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11000110b
         db        11000110b
         db        11100110b
         db        11110110b
         db        11110110b
         db        11011110b
         db        11011110b
         db        11001110b
         db        11001110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 79 "O"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01101100b
         db        00111000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 80 "P"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01111100b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        11110000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 81 "Q"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11010110b
         db        01111100b
         db        00111100b
         db        00001100b
         db        00001110b
         db        00000000b
         db        00000000b

         db        00000000b                ; 82 "R"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01111100b
         db        01101100b
         db        01101100b
         db        01100110b
         db        01100110b
         db        11100110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 83 "S"
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000110b
         db        11000000b
         db        01100000b
         db        00111000b
         db        00001100b
         db        00000110b
         db        11000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 84 "T"
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111110b
         db        01111110b
         db        01011010b
         db        01011010b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 85 "U"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 86 "V"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01101100b
         db        00111000b
         db        00010000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 87 "W"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11010110b
         db        11010110b
         db        11010110b
         db        11010110b
         db        11111110b
         db        01101100b
         db        01101100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 88 "X"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11000110b
         db        11000110b
         db        01101100b
         db        01111100b
         db        00111000b
         db        00111000b
         db        00111000b
         db        01101100b
         db        01101100b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 89 "Y"
         db        00000000b
         db        00000000b
         db        00000000b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        00111100b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 90 "Z"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111110b
         db        11000110b
         db        10000110b
         db        00001100b
         db        00001100b
         db        00011000b
         db        00110000b
         db        00110000b
         db        01100010b
         db        11000110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 91 "["
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111100b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 92 "\"
         db        00000000b
         db        00000000b
         db        00000000b
         db        10000000b
         db        11000000b
         db        01100000b
         db        01100000b
         db        00110000b
         db        00011000b
         db        00011000b
         db        00001100b
         db        00000110b
         db        00000110b
         db        00000010b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 93 "]"
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111100b
         db        00001100b
         db        00001100b
         db        00001100b
         db        00001100b
         db        00001100b
         db        00001100b
         db        00001100b
         db        00001100b
         db        00001100b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 94 "^"
         db        00010000b
         db        00111000b
         db        01101100b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 95 "_"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 96 "`"
         db        00110000b
         db        00110000b
         db        00110000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 97 "a"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111000b
         db        00001100b
         db        00001100b
         db        01111100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01110110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 98 "b"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01111000b
         db        01101100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        11011100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 99 "c"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 100 "d"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011100b
         db        00001100b
         db        00001100b
         db        00001100b
         db        00111100b
         db        01101100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01110110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 101 "e"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000110b
         db        11111110b
         db        11000000b
         db        11000000b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 102 "f"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00111000b
         db        01101100b
         db        01100100b
         db        01100000b
         db        01100000b
         db        11110000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        11110000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 103 "g"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        01110110b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01111100b
         db        00001100b
         db        11001100b
         db        01111000b
         db        00000000b

         db        00000000b                ; 104 "h"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11100000b
         db        01100000b
         db        01100000b
         db        01101100b
         db        01110110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        11100110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 105 "i"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00111000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 106 "j"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000110b
         db        00000110b
         db        00000000b
         db        00001110b
         db        00000110b
         db        00000110b
         db        00000110b
         db        00000110b
         db        00000110b
         db        00000110b
         db        00000110b
         db        01100110b
         db        01100110b
         db        00111100b
         db        00000000b

         db        00000000b                ; 107 "k"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11100000b
         db        01100000b
         db        01100000b
         db        01100110b
         db        01101100b
         db        01101100b
         db        01111000b
         db        01111000b
         db        01101100b
         db        01101100b
         db        11100110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 108 "l"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00111000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 109 "m"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11101100b
         db        11111110b
         db        11010110b
         db        11010110b
         db        11010110b
         db        11010110b
         db        11010110b
         db        11010110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 110 "n"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11011100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 111 "o"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 112 "p"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11011100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01111100b
         db        01100000b
         db        01100000b
         db        11110000b
         db        00000000b

         db        00000000b                ; 113 "q"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        01110110b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01111100b
         db        00001100b
         db        00001100b
         db        00011110b
         db        00000000b

         db        00000000b                ; 114 "r"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11011100b
         db        01110110b
         db        01100010b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        11110000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 115 "s"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000000b
         db        01110000b
         db        00011100b
         db        00000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 116 "t"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00010000b
         db        00110000b
         db        00110000b
         db        11111100b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110110b
         db        00011100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 117 "u"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01110110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 118 "v"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        00111100b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 119 "w"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11010110b
         db        11010110b
         db        11111110b
         db        01101100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 120 "x"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11000110b
         db        01101100b
         db        01101100b
         db        00111000b
         db        00111000b
         db        01101100b
         db        01101100b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 121 "y"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111110b
         db        00000110b
         db        00001100b
         db        11111000b
         db        00000000b

         db        00000000b                ; 122 "z"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111110b
         db        11000110b
         db        00001100b
         db        00011000b
         db        00110000b
         db        01100000b
         db        11000110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 123 "{"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011100b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        11100000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00011100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 124 "|"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 125 "}"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11100000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00011100b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        11100000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 126 "~"
         db        00000000b
         db        00000000b
         db        01110110b
         db        11011100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 127 ""
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00010000b
         db        00111000b
         db        01101100b
         db        01101100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        01100110b                ; 128 "Ä"
         db        00111100b
         db        00011000b
         db        00000000b
         db        00111100b
         db        01100110b
         db        11000010b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000010b
         db        01100110b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 129 "Å"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11001100b
         db        11001100b
         db        00000000b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01110110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 130 "Ç"
         db        00000000b
         db        00000000b
         db        00001100b
         db        00011000b
         db        00110000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000110b
         db        11111110b
         db        11000000b
         db        11000000b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 131 "É"
         db        00000011b
         db        00000011b
         db        00000001b
         db        00011101b
         db        00001110b
         db        00001100b
         db        00001100b
         db        00111100b
         db        01101100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01110110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 132 "Ñ"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11001100b
         db        11001100b
         db        00000000b
         db        01111000b
         db        00001100b
         db        00001100b
         db        01111100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01110110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        11001100b                ; 133 "Ö"
         db        01111000b
         db        00110000b
         db        00000000b
         db        11111000b
         db        01101100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01101100b
         db        11111000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        01100110b                ; 134 "Ü"
         db        00111100b
         db        00011000b
         db        00000000b
         db        01111110b
         db        01111110b
         db        01011010b
         db        01011010b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 135 "á"
         db        00000000b
         db        00000000b
         db        01100110b
         db        00111100b
         db        00011000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 136 "à"
         db        00000000b
         db        00000000b
         db        01100110b
         db        00111100b
         db        00011000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000110b
         db        11111110b
         db        11000000b
         db        11000000b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        01100110b                ; 137 "â"
         db        00111100b
         db        00011000b
         db        00000000b
         db        11111110b
         db        01100110b
         db        01100010b
         db        01100000b
         db        01101000b
         db        01111000b
         db        01101000b
         db        01100000b
         db        01100010b
         db        01100110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00001100b                ; 138 "ä"
         db        00011000b
         db        00110000b
         db        00000000b
         db        11110000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100010b
         db        01100110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000110b                ; 139 "ã"
         db        00001100b
         db        00011000b
         db        00000000b
         db        00111100b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 140 "å"
         db        00000011b
         db        00000011b
         db        00000001b
         db        00111001b
         db        00011010b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000110b                ; 141 "ç"
         db        00001100b
         db        00011000b
         db        00000000b
         db        00111000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 142 "é"
         db        11000110b
         db        11000110b
         db        00000000b
         db        00010000b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11111110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000011b                ; 143 "è"
         db        00000110b
         db        00001100b
         db        00010000b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11111110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00001100b                ; 144 "ê"
         db        00011000b
         db        00110000b
         db        00000000b
         db        11111110b
         db        01100110b
         db        01100010b
         db        01100000b
         db        01101000b
         db        01111000b
         db        01101000b
         db        01100000b
         db        01100010b
         db        01100110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 145 "ë"
         db        00000000b
         db        00000000b
         db        01100110b
         db        00111100b
         db        00011000b
         db        00000000b
         db        11111110b
         db        11000110b
         db        00001100b
         db        00011000b
         db        00110000b
         db        01100000b
         db        11000110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        01100110b                ; 146 "í"
         db        00111100b
         db        00011000b
         db        00000000b
         db        11111110b
         db        11000110b
         db        10000110b
         db        00001100b
         db        00001100b
         db        00011000b
         db        00110000b
         db        00110000b
         db        01100010b
         db        11000110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 147 "ì"
         db        00000000b
         db        00000000b
         db        00010000b
         db        00111000b
         db        01101100b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 148 "î"
         db        00000000b
         db        00000000b
         db        00000000b
         db        11000110b
         db        11000110b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000110b                ; 149 "ï"
         db        00001100b
         db        00011000b
         db        00000000b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01101100b
         db        00111000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 150 "ñ"
         db        00000000b
         db        00000000b
         db        00111000b
         db        01101100b
         db        00111000b
         db        00000000b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01110110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000110b                ; 151 "ó"
         db        00001100b
         db        00011000b
         db        00000000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 152 "ò"
         db        00000000b
         db        00000000b
         db        00001100b
         db        00011000b
         db        00110000b
         db        00000000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111110b
         db        00000110b
         db        00001100b
         db        11111000b
         db        00000000b

         db        00000000b                ; 153 "ô"
         db        11000110b
         db        11000110b
         db        00000000b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01101100b
         db        00111000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 154 "ö"
         db        11000110b
         db        11000110b
         db        00000000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        01100110b                ; 155 "õ"
         db        00111100b
         db        00011000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000110b
         db        11000000b
         db        01100000b
         db        00111000b
         db        00001100b
         db        00000110b
         db        11000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 156 "ú"
         db        00000011b
         db        00000011b
         db        00000001b
         db        11110001b
         db        01100010b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100010b
         db        01100110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000110b                ; 157 "ù"
         db        00001100b
         db        00011000b
         db        00000000b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        00111100b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        01100110b                ; 158 "û"
         db        00111100b
         db        00011000b
         db        00000000b
         db        11111100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01111100b
         db        01101100b
         db        01101100b
         db        01100110b
         db        01100110b
         db        11100110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 159 "ü"
         db        00000011b
         db        00000011b
         db        00000001b
         db        00010001b
         db        00110010b
         db        00110000b
         db        11111100b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110110b
         db        00011100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 160 "†"
         db        00000000b
         db        00000000b
         db        00000110b
         db        00001100b
         db        00011000b
         db        00000000b
         db        01111000b
         db        00001100b
         db        00001100b
         db        01111100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01110110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 161 "°"
         db        00000000b
         db        00000000b
         db        00000110b
         db        00001100b
         db        00011000b
         db        00000000b
         db        00111000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 162 "¢"
         db        00000000b
         db        00000000b
         db        00000110b
         db        00001100b
         db        00011000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 163 "£"
         db        00000000b
         db        00000000b
         db        00001100b
         db        00011000b
         db        00110000b
         db        00000000b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        11001100b
         db        01110110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 164 "§"
         db        00000000b
         db        00000000b
         db        01100110b
         db        00111100b
         db        00011000b
         db        00000000b
         db        11011100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        01100110b                ; 165 "•"
         db        00111100b
         db        00011000b
         db        00000000b
         db        11000110b
         db        11000110b
         db        11100110b
         db        11100110b
         db        11110110b
         db        11110110b
         db        11011110b
         db        11011110b
         db        11001110b
         db        11001110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00111000b                ; 166 "¶"
         db        01101100b
         db        00111000b
         db        00000000b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00111000b                ; 167 "ß"
         db        01101100b
         db        11000110b
         db        00000000b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01101100b
         db        00111000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 168 "®"
         db        00000000b
         db        00000000b
         db        01100110b
         db        00111100b
         db        00011000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000000b
         db        01110000b
         db        00011100b
         db        00000110b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 169 "©"
         db        00000000b
         db        00000000b
         db        01100110b
         db        00111100b
         db        00011000b
         db        00000000b
         db        11011100b
         db        01110110b
         db        01100010b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        11110000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 170 "™"
         db        00000000b
         db        00000000b
         db        00001100b
         db        00011000b
         db        00110000b
         db        00000000b
         db        11011100b
         db        01110110b
         db        01100010b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        11110000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000110b                ; 171 "´"
         db        00001100b
         db        00011000b
         db        00000000b
         db        11111100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01111100b
         db        01101100b
         db        01101100b
         db        01100110b
         db        01100110b
         db        11100110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 172 "¨"
         db        00000000b
         db        11000000b
         db        11000000b
         db        11000010b
         db        11000110b
         db        11001100b
         db        00001100b
         db        00011000b
         db        00110000b
         db        00110000b
         db        01100110b
         db        11001110b
         db        10011010b
         db        00111111b
         db        00000110b
         db        00001111b
         db        00000000b
         db        00000000b

         db        00000000b                ; 173 "≠"
         db        00000000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        01100000b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01101100b
         db        00111000b
         db        00001100b
         db        11000110b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 174 "Æ"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00110011b
         db        01100110b
         db        11001100b
         db        01100110b
         db        00110011b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 175 "Ø"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11001100b
         db        01100110b
         db        00110011b
         db        01100110b
         db        11001100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000010b                ; 176 "∞"
         db        01000101b
         db        00010000b
         db        10101000b
         db        00000000b
         db        01000101b
         db        00010010b
         db        10101000b
         db        00000000b
         db        01000101b
         db        00010010b
         db        10101000b
         db        00000000b
         db        01000101b
         db        00010010b
         db        10101000b
         db        00000000b
         db        01000101b
         db        00010010b

         db        01010101b                ; 177 "±"
         db        10101010b
         db        01010101b
         db        10101010b
         db        01010101b
         db        10101010b
         db        01010101b
         db        10101010b
         db        01010101b
         db        10101010b
         db        01010101b
         db        10101010b
         db        01010101b
         db        10101010b
         db        01010101b
         db        10101010b
         db        01010101b
         db        10101010b
         db        01010101b

         db        11011101b                ; 178 "≤"
         db        01110111b
         db        11011101b
         db        01110111b
         db        11011101b
         db        01110111b
         db        11011101b
         db        01110111b
         db        11011101b
         db        01110111b
         db        11011101b
         db        01110111b
         db        11011101b
         db        01110111b
         db        11011101b
         db        01110111b
         db        11011101b
         db        01110111b
         db        11011101b

         db        00011000b                ; 179 "≥"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00011000b                ; 180 "¥"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        11111000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00011000b                ; 181 "µ"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        11111000b
         db        00011000b
         db        11111000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00110110b                ; 182 "∂"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        11110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00000000b                ; 183 "∑"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00000000b                ; 184 "∏"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111000b
         db        00011000b
         db        11111000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00110110b                ; 185 "π"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        11110110b
         db        00000110b
         db        11110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00110110b                ; 186 "∫"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00000000b                ; 187 "ª"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111110b
         db        00000110b
         db        11110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00110110b                ; 188 "º"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        11110110b
         db        00000110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00110110b                ; 189 "Ω"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00011000b                ; 190 "æ"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        11111000b
         db        00011000b
         db        11111000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 191 "ø"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00011000b                ; 192 "¿"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00011000b                ; 193 "¡"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 194 "¬"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00011000b                ; 195 "√"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011111b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00000000b                ; 196 "ƒ"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00011000b                ; 197 "≈"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        11111111b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00011000b                ; 198 "∆"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011111b
         db        00011000b
         db        00011111b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00110110b                ; 199 "«"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110111b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00110110b                ; 200 "»"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110111b
         db        00110000b
         db        00111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 201 "…"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00111111b
         db        00110000b
         db        00110111b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00110110b                ; 202 " "
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        11110111b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 203 "À"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00000000b
         db        11110111b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00110110b                ; 204 "Ã"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110111b
         db        00110000b
         db        00110111b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00000000b                ; 205 "Õ"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00110110b                ; 206 "Œ"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        11110111b
         db        00000000b
         db        11110111b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00011000b                ; 207 "œ"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        11111111b
         db        00000000b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00110110b                ; 208 "–"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 209 "—"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00000000b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00000000b                ; 210 "“"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00110110b                ; 211 "”"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00111111b
         db        00111111b
         db        00111111b
         db        00111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00011000b                ; 212 "‘"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011111b
         db        00011000b
         db        00011111b
         db        00011111b
         db        00011111b
         db        00011111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 213 "’"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011111b
         db        00011000b
         db        00011111b
         db        00011111b
         db        00011111b
         db        00011111b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00000000b                ; 214 "÷"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00111111b
         db        00111111b
         db        00111111b
         db        00111111b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00110110b                ; 215 "◊"
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b
         db        00110110b

         db        00011000b                ; 216 "ÿ"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        11111111b
         db        00011000b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00011000b                ; 217 "Ÿ"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        11111000b
         db        11111000b
         db        11111000b
         db        11111000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 218 "⁄"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011111b
         db        00011111b
         db        00011111b
         db        00011111b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        11111111b                ; 219 "€"
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b

         db        00000000b                ; 220 "‹"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b

         db        11110000b                ; 221 "›"
         db        11110000b
         db        11110000b
         db        11110000b
         db        11110000b
         db        11110000b
         db        11110000b
         db        11110000b
         db        11110000b
         db        11110000b
         db        11110000b
         db        11110000b
         db        11110000b
         db        11110000b
         db        11110000b
         db        11110000b
         db        11110000b
         db        11110000b
         db        11110000b

         db        00001111b                ; 222 "ﬁ"
         db        00001111b
         db        00001111b
         db        00001111b
         db        00001111b
         db        00001111b
         db        00001111b
         db        00001111b
         db        00001111b
         db        00001111b
         db        00001111b
         db        00001111b
         db        00001111b
         db        00001111b
         db        00001111b
         db        00001111b
         db        00001111b
         db        00001111b
         db        00001111b

         db        11111111b                ; 223 "ﬂ"
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 224 "‡"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        01110110b
         db        11011100b
         db        11011000b
         db        11011000b
         db        11011000b
         db        11011000b
         db        11011000b
         db        11011000b
         db        11011100b
         db        01110110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 225 "·"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111100b
         db        11000110b
         db        11111100b
         db        11111100b
         db        11111100b
         db        11111100b
         db        11000110b
         db        11000110b
         db        11111100b
         db        11000000b
         db        11000000b
         db        11000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 226 "‚"
         db        00000000b
         db        11111110b
         db        11000110b
         db        11000110b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        11000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 227 "„"
         db        00000000b
         db        00000000b
         db        00000000b
         db        10000000b
         db        11111110b
         db        01101100b
         db        01101100b
         db        01101100b
         db        01101100b
         db        01101100b
         db        01101100b
         db        01101100b
         db        01101100b
         db        01101100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 228 "‰"
         db        00000000b
         db        00000000b
         db        11111110b
         db        11000110b
         db        01100000b
         db        00110000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00110000b
         db        01100000b
         db        11000110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 229 "Â"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111110b
         db        11011000b
         db        11011000b
         db        11011000b
         db        11011000b
         db        11011000b
         db        11011000b
         db        11011000b
         db        11011000b
         db        01110000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 230 "Ê"
         db        00000000b
         db        00000000b
         db        00000000b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01111100b
         db        01100000b
         db        01100000b
         db        11000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 231 "Á"
         db        00000000b
         db        00000000b
         db        00000000b
         db        01110110b
         db        11011100b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 232 "Ë"
         db        00000000b
         db        00000000b
         db        01111110b
         db        00011000b
         db        00111100b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        00111100b
         db        00011000b
         db        01111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 233 "È"
         db        00000000b
         db        00000000b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        11111110b
         db        11111110b
         db        11111110b
         db        11111110b
         db        11000110b
         db        11000110b
         db        01101100b
         db        00111000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 234 "Í"
         db        00000000b
         db        00111000b
         db        01101100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        01101100b
         db        01101100b
         db        01101100b
         db        01101100b
         db        01101100b
         db        01101100b
         db        01101100b
         db        11101110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 235 "Î"
         db        00000000b
         db        00011110b
         db        00110000b
         db        00011000b
         db        00001100b
         db        00111110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        01100110b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 236 "Ï"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111110b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        01111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 237 "Ì"
         db        00000000b
         db        00000000b
         db        00000011b
         db        00000110b
         db        01111110b
         db        11001111b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11011011b
         db        11110011b
         db        01111110b
         db        01100000b
         db        11000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 238 "Ó"
         db        00000000b
         db        00011100b
         db        00110000b
         db        01100000b
         db        01100000b
         db        01111100b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        01100000b
         db        00110000b
         db        00011100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 239 "Ô"
         db        00000000b
         db        00000000b
         db        01111100b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        11000110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 240 ""
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111110b
         db        00000000b
         db        00000000b
         db        11111110b
         db        11111110b
         db        11111110b
         db        11111110b
         db        00000000b
         db        00000000b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 241 "Ò"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        11111111b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 242 "Ú"
         db        00000000b
         db        00000000b
         db        00110000b
         db        00011000b
         db        00001100b
         db        00000110b
         db        00001100b
         db        00001100b
         db        00001100b
         db        00001100b
         db        00011000b
         db        00110000b
         db        00000000b
         db        01111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 243 "Û"
         db        00000000b
         db        00000000b
         db        00001100b
         db        00011000b
         db        00110000b
         db        01100000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00110000b
         db        00011000b
         db        00001100b
         db        00000000b
         db        01111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 244 "Ù"
         db        00000000b
         db        00001110b
         db        00011011b
         db        00011011b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b

         db        00011000b                ; 245 "ı"
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        11011000b
         db        11011000b
         db        11011000b
         db        01110000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 246 "ˆ"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        11111111b
         db        11111111b
         db        11111111b
         db        11111111b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 247 "˜"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        01110110b
         db        11011100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        01110110b
         db        11011100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 248 "¯"
         db        00111000b
         db        01101100b
         db        01101100b
         db        00111000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 249 "˘"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 250 "˙"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 251 "˚"
         db        00001111b
         db        00001100b
         db        00001100b
         db        00001100b
         db        00001100b
         db        00001100b
         db        11101100b
         db        11101100b
         db        11101100b
         db        11101100b
         db        01101100b
         db        01101100b
         db        00111100b
         db        00011100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 252 "¸"
         db        11011000b
         db        01101100b
         db        01101100b
         db        01101100b
         db        01101100b
         db        01101100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 253 "˝"
         db        01110000b
         db        10011000b
         db        00110000b
         db        01100000b
         db        11001000b
         db        11111000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 254 "˛"
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111100b
         db        01111100b
         db        01111100b
         db        01111100b
         db        01111100b
         db        01111100b
         db        01111100b
         db        01111100b
         db        01111100b
         db        01111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

         db        00000000b                ; 255 "ˇ"
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

code     ENDS

         end       start


; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                     Ovladaá displeje pro KONTEXT
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

; Po p©ekladu od adresy 0 m† jmÇno SCREEN.OVL

bit0     EQU       1
bit1     EQU       2
bit2     EQU       4
bit3     EQU       8
bit4     EQU       10h
bit5     EQU       20h
bit6     EQU       40h
bit7     EQU       80h
HI       EQU       256

Code     SEGMENT
         ASSUME    cs:code,ds:code

; *****************************************************************************
;
;                         vstupn° bod do ovladaáe
;
; *****************************************************************************

Screen   PROC      FAR                      ; vstupn° bod do ovladaáe
                                            ; - á°slo funkce je v BX
         push      ds

         push      cs
         pop       ds                       ; DS <- segment programu
         shl       bx,1                     ; á°slo funkce BX * 2
         call      word ptr ds:[bx+AdrSub]  ; vyvol†n° podprogramu podle tabulky

         pop       ds
         ret                                ; n†vrat z driveru RET FAR

Screen   ENDP

AdrSub   dw        Fnc00                    ; funkce 00 - vòstup znaku
         dw        Fnc01                    ; funkce 01 - kurzor, maz†n°
         dw        Fnc02                    ; funkce 02 - rolov†n° nahoru
         dw        Fnc03                    ; funkce 03 - rolov†n° dolñ
         dw        Fnc04                    ; funkce 04 - pravò okraj (á†ra)
         dw        Fnc05                    ; funkce 05 - inicializace parametrñ
         dw        Fnc06                    ; funkce 06 - nastaven° text. m¢du
         dw        Fnc07                    ; funkce 07 - adr. n†povàdy (ES:SI)
         dw        Fnc08                    ; funkce 08 - adr. chybovòch hl†®en°
         dw        Fnc09                    ; funkce 09 - rozdàlov†n° slov
         dw        Fnc10                    ; funkce 10 - dek¢dov†n° k¢du kl†ves
         dw        Fnc11                    ; funkce 11 - vòpis k¢du kl†vesy

; *****************************************************************************
;
;                                  data
;
; *****************************************************************************
;˛
TypCard  db        0                        ; typ videokarty
                                            ;   0=neinicializov†no
                                            ;   1=HGC (Hercules)
                                            ;   2=CGA
                                            ;   3=EGA
                                            ;   4=VGA

Karta    db        'TXT',0
         db        'HGC',0
         db        'CGA',0
         db        'EGA',0
         db        'VGA',0

OldVMod  db        3                        ; uschovanò pñvodn° videom¢d
AktVMod  db        6                        ; grafickò videom¢d
TxtVMod  db        3                        ; textovò videom¢d

AdrVRAM  dw        0b800h                   ; segment videopamàti
Pozic    dw        80                       ; poáet pozic na ©†dek
Radku    dw        25                       ; poáet ©†dkñ displeje
Vyska    db        8                        ; poáet linek na textovò ©†dek

AdrLFont dw        Fnt6x8                   ; font pro zmen®enÇ p°smo
VyskaL   db        6                        ; poáet linek na zmen®enò font
AdrFont  dw        Fnt8x8                   ; adresa fontu

ChrBuf   db        0,0,0,0,0,0,0,0,0,0      ; buffer pro vòstup znaku
         db        0,0,0,0,0,0,0,0,0
ChrBuf2  db        0,0,0,0,0,0,0,0,0,0      ; prav† polovina ®irokÇho znaku
         db        0,0,0,0,0,0,0,0,0

Whide    db        0                        ; 80h=dvojn†sobn† ®°©ka znaku
Mode     db        0                        ; reëim obrazovky (1,2,3)

; ------ definice barevnòch rovin pro m¢d EGA a VGA

InvMsk   db        0                        ; maska znakñ (pro inverzi)
PlanNg   db        0                        ; roviny pro negaci znaku (kurzor)
Planes   db        0                        ; roviny EGA pro vòstup znaku

; ------ barvy p°sma pro textovò videom¢d

Normal   db        0                        ; barva norm†ln°ho textu
Invert   db        0                        ; barva textu menu
Cara     db        0                        ; barva okraje (hnàd†)
Zvyraz   db        0                        ; zvòraznànÇ p°smo (ëlutÇ)
Sikme    db        0                        ; ®ikmÇ p°smo (zelen†)
Podtrz   db        0                        ; podtrëenÇ p°smo (fialov†)
Jine     db        0                        ; jinÇ kombinace typñ (b°l†)

AdrRow   dw        61 DUP (0)               ; tabulka adres ©†dkñ na displeji

; *****************************************************************************
;
;                       Funkce 00: Vòstup znaku
;
; -----------------------------------------------------------------------------
; VSTUP: SS:[BP+4] (2) ©†dek (0...)
;        SS:[BP+6] (2) pozice (1...)
;        SS:[BP+8] (2) znak k zobrazen°
;        AH=m¢d zobrazen° znaku
;                       bit 0: 1=nadsazen°
;                       bit 1: 1=podsazen°
;                       bit 2: 1=kurz°va
;                       bit 3: 1=podtrëen°
;                       bit 4: 1=zvòraznàn°
;                       bit 5: 1=inverze
;                       bit 6: 1=rozdàlen°
;                       bit 7: 1=®irokÇ p°smo
; *****************************************************************************
;˛
Fnc00    PROC      NEAR

; ------ kontrola, zda je povolen† pozice znaku

         xor       cx,cx                    ; CX <- 0
         mov       dx,[bp+6]                ; pozice znaku na ©†dku
         dec       dx
         js        Fnc001                   ; nepovolen† pozice
         cmp       dx,ds:[Pozic]            ; je povolen† pozice ?
         jae       Fnc001                   ; nen° povolen† pozice

; ------ p©°znak dvojn†sobnÇ ®°©ky znaku

         mov       al,ss:[bp+8]             ; znak k vòstupu
         cmp       al,0ffh                  ; je znak pro dvojn†sobnou ®°©ku ?
         jne       Fnc0013                  ; nen° dvojn†sobn† ®°©ka
         cmp       byte ptr ds:[Mode],1     ; je textovò m¢d ?
         je        Fnc0012                  ; je textovò m¢d
         mov       cl,80h                   ; nastaven° p©°znaku dvojitÇ ®°©ky
Fnc001:  mov       [Whide],cl               ; p©°znak dvojn†sobnÇho znaku
         ret                                

; ------ v textovÇm m¢du se zobraz° n†hradn° znak "_"

Fnc0012: mov       al,"_"                   ; n†hradn° znak (nebo mñëe bòt 22)

; ------ zobrazen° znaku v textovÇm reëimu

Fnc0013: cmp       byte ptr ds:[Mode],1     ; je textovò m¢d ?
         jne       Fnc002                   ; nen° textovò m¢d

         cld
         mov       di,[bp+4]                ; ©†dek znaku
         shl       di,1                     ; DI = poáet linek * 2
         mov       di,[di+AdrRow]           ; p©eáten° adresy linky
         dec       di
         dec       di
         add       di,[bp+6]
         add       di,[bp+6]                ; pozice znaku na ©†dku
         mov       es,ds:[AdrVRAM]          ; adresa videopamàti
         stosb                              ; uloëen° znaku

         mov       al,ds:[Normal]           ; bàën† barva
         test      ah,bit0+bit1+bit2+bit3+bit4+bit5 ; jsou nàjakÇ atributy ?
         jz        Fnc0016                  ; je norm†ln° barva

         mov       al,ds:[Invert]           ; inverzn° p°smo
         test      ah,bit5                  ; je inverzn° p°smo ?
         jnz       Fnc0016                  ; je inverzn° p°smo

         mov       al,ds:[Zvyraz]           ; zvòraznànÇ
         test      ah,bit4
         jnz       Fnc0016                  ; je zvòraznànÇ p°smo

         mov       al,ds:[Sikme]            ; kurz°va
         test      ah,bit2
         jnz       Fnc0016                  ; je kurz°va

         mov       al,ds:[Podtrz]           ; podtrëenÇ
         test      ah,bit3                  ; je podtrëenÇ ?
         jnz       Fnc0016                  ; je podtrëenÇ

         mov       al,ds:[Jine]             ; jinÇ p°smo
Fnc0016: stosb                              ; uloëen° barvy znaku
         ret

; ------ p©°prava k dek¢dov†n° znaku

Fnc002:  push      cs
         pop       es                       ; ES = DS
         cld                                ; smàr p©enosu dat nahoru
         mov       di,offset ChrBuf         ; buffer k dek¢dov†n° znaku
         test      ah,bit0+bit1             ; je nadsazen° nebo podsazen° ?
         jnz       Fnc003                   ; je nadsazen° nebo podsazen°

; ------ p©°prava znaku v bàënÇm fontu

         mov       cl,ds:[Vyska]            ; poáet bajtñ na znak
         push      ax
         mul       cl                       ; offset v tabulce fontu
         add       ax,ds:[AdrFont]          ; adresa znaku v tabulce fontñ
         xchg      ax,si                    ; SI <- adresa fontu
         rep       movsb                    ; p©enos znaku do bufferu
         pop       ax
         jmp       short Fnc005

; ------ adresa zmen®enÇho fontu

Fnc003:  mov       cl,ds:[VyskaL]           ; poáet bajtñ na zmen®enò font
         push      ax
         mul       cl                       ; offset zmen®enÇho znaku
         add       ax,ds:[ADrLFont]         ; adresa zmen®enÇho fontu
         xchg      ax,si                    ; SI <- adresa fontu
         pop       ax

; ------ dek¢dov†n° nadsazen°

         mov       al,0                     ; nulovac° bajt
         test      ah,bit0                  ; je nadsazen° ?
         jz        Fnc004                   ; nen° nadsazen°
         rep       movsb                    ; p©enos zmen®enÇho znaku
         mov       cl,ds:[Vyska]            ; vò®ka znaku
         sub       cl,ds:[VyskaL]           ; zbòvaj°c° poáet linek
         rep       stosb                    ; vymaz†n° zbytku znaku
         jmp       short Fnc005

; ------ dek¢dov†n° podsazen°

Fnc004:  mov       cl,ds:[Vyska]            ; vò®ka znaku
         sub       cl,ds:[VyskaL]           ; zbòvaj°c° poáet linek
         rep       stosb                    ; vymaz†n° zbytku znaku
         mov       cl,ds:[VyskaL]           ; vò®ka zmen®enÇho znaku
         rep       movsb                    ; p©enos zmen®enÇho znaku

; ------ kurz°va

Fnc005:  mov       si,offset ChrBuf         ; buffer znaku
         mov       cl,ds:[Vyska]            ; vò®ka znaku
         test      ah,bit2                  ; je kurz°va ?
         jz        Fnc006                   ; nen° kurz°va
         push      cx
         mov       cl,2
Fnc005K: call      Kurziv8                  ; proveden° kurz°vy
         pop       cx

; ------ zvòraznàn°

Fnc006:  test      ah,bit4
         jz        Fnc0062

         push      cx
         push      si                       ; adresa znaku v bufferu

Fnc0061: lodsb                              ; 1 linka znaku
         shr       al,1
         or        [si-1],al                ; zvòraznàn° znaku
         loop      Fnc0061                  ; dal®° linka znaku

         pop       si
         pop       cx

; ------ podtrëen°

Fnc0062: test      ah,bit3
         jz        Fnc0063

         push      si
         add       si,cx
         mov       byte ptr ds:[si-1],-1
         mov       byte ptr ds:[si-1+ChrBuf2-ChrBuf],-1
         pop       si

; ------ dvojn†sobn† ®°©ka p°sma

Fnc0063: or        ah,[Whide]               ; p©°znak dvojn†sobnÇho znaku
         jns       Fnc0066                  ; nen° dvojn†sobn† ®°©ka znaku

         push      cx
         push      si                       ; adresa znaku v bufferu

Fnc0064: mov       bh,8                     ; poáet bitñ znaku = 8
         lodsb                              ; linka znaku
Fnc0065: shr       al,1                     ; rotace linky vpravo, kopie do CF
         rcr       dx,1                     ; rotace bitu CF do reg. DX
         sar       dx,1                     ; rotace vpravo ze znamÇnkovÇho bitu
         dec       bh                       ; á°taá bitñ k rotaci
         jnz       Fnc0065                  ; dal®° bit k rotaci
         mov       [si-1],dh                ; lev† polovina znaku
         mov       [si+ChrBuf2-ChrBuf-1],dl ; prav† polovina znaku
         loop      Fnc0064
         dec       word ptr ss:[bp+6]       ; sn°ëen° pozice znaku na displeji
         mov       [Whide],cl               ; p©°znak dvojn†sobnÇho znaku = 0

         pop       si
         pop       cx

; ------ rozdàlen° znaku

Fnc0066: test      ah,bit6                  ; je rozdàlovac° znamÇnko ?
         jz        Fnc007                   ; nen° rozdàlovac° znamÇnko

         push      cx
         push      si                       ; adresa znaku v bufferu

         mov       al,1
Fnc0067: or        ds:[si],al               ; oznaáen° rozdàlen° znaku
         inc       si
         loop      Fnc0067                  ; dal®° linka znaku

         pop       si
         pop       cx

; ------ p©°prava adresy na displeji

Fnc007:  mov       di,[bp+4]                ; ©†dek znaku
         shl       di,1                     ; DI = poáet linek * 2
         mov       di,[di+adrrow]           ; p©eáten° adresy linky
         add       di,[bp+6]                ; pozice znaku na ©†dku
         mov       es,ds:[AdrVRAM]          ; adresa videopamàti
         mov       bh,[InvMsk]              ; maska pro vòstup (pro inverzi)

; ------ rozli®en°, zda je videom¢d EGA/VGA

         push      cx
         test      ah,bit5                  ; p©°znak inverzn°ho znaku
         jz        Fnc0071
         not       bh                       ; inverzn° znak
Fnc0071: cmp       byte ptr ds:[TypCard],2
         jbe       Fnc008                   ; je CGA nebo HGC

; ------ zobrazen° znaku v m¢du EGA/VGA

Fnc0072: lodsb                              ; p©eáten° bajtu k vòstupu DS:SI
         xor       al,bh                    ; filtrace barvy (inverze)
         stosb                              ; uloëen° sudÇho bajtu do VRAM ES:DI
         add       di,80-1                  ; dal®° ©†dek (zvò®en° o 80)
         loop      Fnc0072                  ; dal®° dva bajty znaku

; ------ test, zda n†sleduje druh† polovina ®irokÇho znaku

Fnc0074: pop       cx

         xor       ah,80h
         jns       Fnc0075                  ; je ®irokÇ p°smo-p©enos pravÇ á†sti
         ret

Fnc0075: inc       word ptr [BP+6]          ; zvò®en° pozice
         mov       si,offset ChrBuf2        ; adresa pravÇ poloviny znaku
         jmp       short Fnc0066

; ------ zobrazen° znaku v m¢du CGA

Fnc008:  jb        Fnc009                   ; je HGC
         shr       cx,1                     ; poáet slov k p©enosu
Fnc0082: lodsb                              ; p©eáten° bajtu k vòstupu DS:SI
         xor       al,bh                    ; filtrace barvy (inverze)
         stosb                              ; uloëen° sudÇho bajtu do VRAM ES:DI
         add       di,2000h-1               ; dal®° ©†dek
         lodsb                              ; p©eáten° druhÇho bajtu k vòstupu
         xor       al,bh                    ; filtrace barvy
         stosb                              ; uloëen° lichÇho bajtu do VRAM
         add       di,80 - 2000h - 1        ; dal®° ©†dek
         loop      Fnc0082                  ; dal®° dva bajty znaku
         jmp       short Fnc0074

; ------ HGC

Fnc009:  lodsb                              ; p©eáten° bajtu k vòstupu DS:SI
         xor       al,bh                    ; filtrace barvy (inverze)
         stosb                              ; uloëen° sudÇho bajtu do VRAM ES:DI
         dec       cx                       ; sn°ëen° á°taáe bajtñ
         jz        Fnc0074
         add       di,2000h-1               ; dal®° ©†dek
         jns       Fnc009
         add       di,90 - 4*2000h          ; adresa dal®°ho ©†dku
         jmp       short Fnc009             ; dal®° dva bajty znaku

Fnc00    ENDP

; -----------------------------------------------------------------------------
;        kurz°va 6 linek
; -----------------------------------------------------------------------------

Kurziv6  PROC      NEAR

         shr       byte ptr [si],1          ; >> 1
         shr       byte ptr [si+1],1        ; >> 1
                                            ;    0
                                            ;    0
         shl       byte ptr [si+4],1        ; << 1
         shl       byte ptr [si+5],1        ; << 1
         ret

Kurziv6  ENDP

; -----------------------------------------------------------------------------
;        kurz°va 8 linek
; -----------------------------------------------------------------------------

Kurziv8  PROC      NEAR

         shr       byte ptr [si],cl         ; >> 2
         shr       byte ptr [si+1],1        ; >> 1
         shr       byte ptr [si+2],1        ; >> 1
                                            ;    0
                                            ;    0
         shl       byte ptr [si+5],1        ; << 1
         shl       byte ptr [si+6],1        ; << 1
         shl       byte ptr [si+7],cl       ; << 2
         ret

Kurziv8  ENDP

; -----------------------------------------------------------------------------
;        kurz°va 14 linek
; -----------------------------------------------------------------------------

Kurziv14 PROC      NEAR

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
         ret

Kurziv14 ENDP

; -----------------------------------------------------------------------------
;        kurz°va 19 linek
; -----------------------------------------------------------------------------

Kurziv19 PROC      NEAR

         shr       byte ptr [si],cl         ; >> 2
         shr       byte ptr [si+1],cl       ; >> 2
         shr       byte ptr [si+2],cl       ; >> 2
         shr       byte ptr [si+3],cl       ; >> 2
         shr       byte ptr [si+4],1        ; >> 1
         shr       byte ptr [si+5],1        ; >> 1
         shr       byte ptr [si+6],1        ; >> 1
         shr       byte ptr [si+7],1        ; >> 1
                                            ;    0
                                            ;    0
                                            ;    0
                                            ;    0
         shl       byte ptr [si+12],1       ; << 1
         shl       byte ptr [si+13],1       ; << 1
         shl       byte ptr [si+14],1       ; << 1
         shl       byte ptr [si+15],1       ; << 1
         shl       byte ptr [si+16],cl      ; << 2
         shl       byte ptr [si+17],cl      ; << 2
         shl       byte ptr [si+18],cl      ; << 2
         ret

Kurziv19 ENDP

; *****************************************************************************
;
;                         Funkce 01: Kurzor a maz†n°
;
; -----------------------------------------------------------------------------
; VSTUP: SS:[BP+4] typ operace
;                       0 = norm†ln° okno
;                       1 = inverzn° okno
;                       2 = kurzor
;        SS:[BP+6] koncov† linka
;        SS:[BP+8] koncov† pozice
;        SS:[BP+10] poá†teán° linka
;        SS:[BP+12] poá†teán° pozice
; *****************************************************************************
;˛
Fnc01    PROC      NEAR

; ------ poá†teán° a koncovò ©†dek

         mov       ax,ss:[bp+10]            ; poá†teán° ©†dek
         mov       bx,ss:[bp+6]             ; koncovò ©†dek
         cmp       ax,bx
         jbe       Fnc011
         cmp       byte ptr ss:[bp+4],2
         jne       Fnc011
         dec       ax
         mov       bx,ax
Fnc011:  sub       bx,ax
         inc       bx                       ; vò®ka okna (©†dkñ)

; ------ adresa ©†dku na obrazovce

         mov       di,80                    ; poáet znakñ na ©†dek
         cmp       byte ptr ds:[Mode],1     ; je textovò m¢d ?
         je        Fnc0112                  ; je textovò m¢d
         cmp       byte ptr ds:[TypCard],3  ; je m¢d EGA/VGA ?
         jae       Fnc0112                  ; je m¢d EGA/VGA
         mov       di,40                    ; p©°rustek adresy pro CGA a HGC
Fnc0112: mul       di                       ; poá†teán° adresa
         xchg      ax,di                    ; poá†teán° adresa
         mov       es,ds:[AdrVRAM]          ; adresa videopamàti

; ------ poá†teán° pozice

         mov       ax,ss:[bp+12]            ; poá†teán° pozice
         dec       ax                       ; korekce pozice
         jns       Fnc012                   ; pozice je OK
         xor       ax,ax                    ; omezen° poá†teán° pozice

; ------ ®°©ka okna

Fnc012:  mov       cx,ss:[bp+8]             ; koncov† pozice
         cmp       cx,ds:[Pozic]            ; je pozice OK ?
         jbe       Fnc013                   ; pozice je OK
         mov       cx,ds:[Pozic]            ; omezen° koncovÇ pozice
Fnc013:  sub       cx,ax                    ; ®°©ka okna
         jbe       Fnc0149                  ; nen° okno
         add       di,ax                    ; poá†teán° adresa okna

; ------ test, zda je textovò m¢d

         cld
         cmp       byte ptr ds:[Mode],1     ; je textovò m¢d ?
         jne       Fnc015                   ; nen° textovò m¢d

; ------ norm†ln° a inverzn° okno

         shl       di,1
         cmp       byte ptr ss:[bp+4],1     ; parametr
         ja        Fnc0143                  ; je kurzor
         mov       ah,ds:[Normal]           ; je norm†ln° text
         jb        Fnc0141                  ; je inverzn° text
         mov       ah,ds:[Invert]           ; inverzn° text
Fnc0141: mov       al," "
Fnc0142: push      di
         push      cx
         rep       stosw
         pop       cx
         pop       di

         add       di,ds:[Pozic]
         add       di,ds:[Pozic]
         dec       bx
         jnz       Fnc0142
         jmp       short Fnc0149

; ------ zobrazen° kurzoru

Fnc0143: push      di
         push      cx                       ; á°taá znakñ na ©†dek

Fnc0144: inc       di
         mov       al,es:[di]               ; nastavenò atribut
         not       al
         cmp       byte ptr ds:[TypCard],1  ; je MDA ?
         jne       Fnc0145
         not       al
         ror       al,1
         ror       al,1
         ror       al,1
         ror       al,1
Fnc0145: stosb
         loop      Fnc0144

         pop       cx
         pop       di

         add       di,ds:[Pozic]
         add       di,ds:[Pozic]
         dec       bx                       ; á°taá ©†dkñ
         jnz       Fnc0143                  ; dal®° ©†dek
Fnc0149: jmp       short Fnc019

; ------ test, zda je m¢d EGA/VGA


Fnc015:  cmp       byte ptr ds:[TypCard],2  ; je karta EGA/VGA ?
         ja        Fnc0152                  ; je karta EGA/VGA
         je        Fnc0151                  ; je karta CGA
         jmp       Fnc015H                  ; je karta HGC
Fnc0151: jmp       Fnc015C                  ; CGA

; ------ nastaven° registrñ pro m¢d EGA

Fnc0152: mov       dx,03CEh                 ; adresovò registr grafiky EGA
         mov       al,1                     ; nastaven° registru á°slo 1
         out       dx,al
         inc       dx                       ; adresa dat registru
         mov       al,0fh                   ; nastaven° bitñ pro set/reset
         out       dx,al
         dec       dx                       ; adresovò registr grafiky EGA
         mov       al,0
         out       dx,al                    ; nastaven° registru á°slo 0
         inc       dx                       ; adresa dat registru
         mov       ah,[InvMsk]              ; maska znakñ pro vòstup
         cmp       byte ptr [bp+4],1        ; parametr pro z†pis okna
         jnc       fnc016                   ; je vymaz†n° okna
         not       ah                       ; negace masky pro vòstup
         jmp       short fnc017

Fnc016:  mov       al,0ffh                  ; maz†n° v®ech rovin
         jne       fnc018
fnc017:  mov       al,[Planes]              ; roviny pro vòstup znaku
         or        ah,ah                    ; negovan† maska znakñ pro vòstup
         jnz       fnc018                   ; je negace zpàt
         mov       al,[PlanNg]              ; roviny pro negaci znaku (kurzor)
fnc018:  out       dx,al                    ; vòbàr rovin pro vòstup

         push      ds
         mov       es,ds:[AdrVRAM]
         mov       ds,ds:[AdrVRAM]          ; nastaven° segmentovòch registrñ
         cld                                ; smàr p©enosu dat vzhñru
         inc       al                       ; roviny pro z†pis
         jnz       fnc01A                   ; nejsou v®echny roviny (tj. maz†n°)
         dec       dx                       ; adresovò registr grafiky EGA
         mov       al,3
         out       dx,al                    ; nastaven° registru 3
         inc       dx                       ; datovò registr
         mov       al,18h                   ; z†pisovò m¢d XOR
         out       dx,al

fnc0182: mov       si,di
         push      cx                       ; ®°©ka okna k vymaz†n°
         push      di                       ; ukazatel okna
         repnz     movsb                    ; vymaz†n° bajtñ obrazovky
         pop       di
         pop       cx
         add       di,80                    ; dal®° linka
         dec       bx                       ; á°taá linek okna
         jnz       fnc0182                  ; dal®° linka okna
         jmp       short fnc01B             ; konec

fnc01A:  push      cx
         push      di
         repnz     stosb                    ; uloëen° negovac°ho bajtu
         pop       di
         pop       cx
         add       di,80                    ; dal®° linka
         dec       bx                       ; á°taá linek
         jnz       fnc01A                   ; dal®° linka k negaci

fnc01B:  pop       ds
         call      iniega                   ; inicializace displeje
fnc019:  ret

; ------ CGA

Fnc015C: cmp       byte ptr [bp+4],1        ; parametr pro z†pis okna
         jbe       fnc015C5                 ; je vymaz†n° okna

fnc015C2:push      cx
         push      di
fnc015C3:not       byte ptr es:[di]         ; invereze kurzoru
         inc       di
         loop      fnc015C3
         pop       di
         pop       cx
         sub       di,1fb0h
         jns       fnc015C4
         add       di,3fb0h
fnc015C4:dec       bx
         jnz       fnc015C2
         jmp       fnc015C9


fnc015C5:mov       al,ds:[invmsk]
         jnz       fnc015C6
         not       al
fnc015C6:push      cx
         push      di
         repnz     stosb                    ; uloëen° negovac°ho bajtu
         pop       di
         pop       cx
         sub       di,1fb0h                 ; dal®° linka
         jns       fnc015C7                 ; dal®° linka k negaci
         add       di,3fb0h
fnc015C7:dec       bx
         jnz       fnc015C6
fnc015C9:ret

; ------ HGC

Fnc015H: mov       ax,[bp+10]               ; poá†teán° linka
         mov       di,ax                    ; DI <- poá†teán° linka
         mov       dx,ax                    ; DX <- poá†teán° linka
         and       dx,3                     ; á°slo podlinky
         ror       dx,1
         ror       dx,1
         ror       dx,1                     ; adresa linky 0,2000h,4000h,6000h
         shr       ax,1
         shr       ax,1                     ; á°slo ©†dku
         mov       cl,90                    ; poáet bajtñ na ©†dek
         mul       cl                       ; adresa ©†dku
         add       ax,dx                    ; poá†teán° adresa linky

         mov       dx,[bp+6]                ; koncov† linka
         sub       dx,di                    ; vò®ka okna - 1
         inc       dx                       ; vò®ka okna
         mov       di,ax                    ; DI <- poá†teán° adresa linky

         mov       ax,[bp+12]               ; poá†teán° pozice
         or        ax,ax                    ; je pozice OK ?
         jg        fnc015h1                 ; pozice je OK
         mov       ax,1                     ; omezen° poá†teán° pozice

fnc015h1:mov       cx,[bp+8]                ; koncov† pozice
         cmp       cx,90                    ; kontrola ®°©ky okna
         jng       fnc015h2
         mov       cx,90                    ; omezen° na max. poáet znakñ 90

fnc015h2:dec       ax
         sub       cx,ax                    ; ®°©ka okna
         jng       fnc015h24                ; nen° ë†dnÇ okno

         add       di,ax                    ; poá†teán° adresa okna
         mov       es,ds:[AdrVRAM]          ; adresa videopamàti
         cld
         cmp       byte ptr [bp+4],1
         jna       fnc015h23                ; je norm†ln° nebo inverzn° okno

; ------ zobrazen° kurzoru HGC

fnc015h20:push      cx
         push      di
fnc015h21:not       byte ptr es:[di]
         inc       di
         loop      fnc015h21
         pop       di
         pop       cx
         add       di,2000h
         jns       fnc015h22
         sub       di,7fa6h
fnc015h22:dec       dx
         jnz       fnc015h20
         jmp       short fnc015h24

; ------ zobrazen° norm†ln°ho nebo inverzn°ho okna HGC

fnc015h23:mov       al,[invmsk]
         jnz       fnc015h25
         not       al
fnc015h25:push      cx
         push      di
         repnz     stosb
         pop       di
         pop       cx
         add       di,2000h
         jns       fnc015h26
         sub       di,7fa6h
fnc015h26:dec       dx
         jnz       fnc015h25
fnc015h24:ret

Fnc01    ENDP

; *****************************************************************************
;
;                    Funkce 02: rolov†n° okna nahoru
;
; *****************************************************************************
;˛
                                            ; FUNKCE 02 - rolov†n° okna nahoru

                                            ; SS:BP = ukazatel parametrñ
                                            ;    + 4 = koneánò ©†dek rolov†n°
                                            ;    + 6 = ®°©ka okna (pozic)
                                            ;    + 8 = poá†teán° ©†dek k rol.
                                            ;    +10 = poá†teán° pozice okna

fnc02:   cmp       byte ptr ds:[Mode],1
         jne       Fnc020                   ; nen° textovò m¢d

         mov       ax,[bp+4]                ; koneánò ©†dek k rolov†n°
         sub       ax,[bp+8]                ; poá†teán° ©†dek k rol.-poáet ©†dkñ
         jz        fnc0219                  ; nen° ë†dnò ©†dek - konec
         mov       bx,ax                    ; poáet ©†dkñ k rolov†n°
         mov       ax,[bp+8]                ; poá†teán° ©†dek k rolov†n°
         mov       cx,ds:[Pozic]
         add       cx,cx
         mul       cx                       ; poá†teán° adresa poá†t. ©†dku
         mov       si,ax                    ; poá†teán° adresa poá†t. ©†dku
         mov       di,ax                    ; adresa n†sleduj°c°ho ©†dku
         add       si,ds:[Pozic]
         add       si,ds:[Pozic]
         mov       ax,[bp+10]               ; poá†teán° pozice okna
         dec       ax
         add       di,ax                    ; poá†teán° adresa
         add       di,ax
         add       si,ax
         add       si,ax
         mov       cx,[bp+6]                ; koneán† pozice
         sub       cx,ax                    ; poáet pozic okna k rolov†n°
         add       cx,cx
         push      es
         push      ds
;         add       si,word ptr ds:[AdrVRAM]
;         add       di,word ptr ds:[AdrVRAM]
         mov       ax,ds:[AdrVRAM] ; segment displeje
         mov       es,ax
         mov       ds,ax
         cld                                ; p©enos nahoru
fnc0212: push      si
         push      di
         push      cx
         repnz     movsb
         pop       cx
         pop       di
         pop       si
         add       di,cs:[Pozic]
         add       di,cs:[Pozic]
         add       si,cs:[Pozic]
         add       si,cs:[Pozic]
         dec       bx
         jnz       fnc0212
         pop       ds
         pop       es
fnc0219: ret


fnc020:  cmp       byte ptr ds:[TypCard],2
         jbe       fnc023

         mov       ax,[bp+4]                ; koneánò ©†dek k rolov†n°
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

fnc023:  jb        fnc024                   ; je MDA

         mov       ax,[bp+4]                ; koneánò ©†dek k rolov†n°
         mov       si,[bp+8]                ; poá†teán° ©†dek k rolov†n°
         sub       ax,si                    ; poáet ©†dkñ k rolov†n°
         jbe       fnc0232                  ; nen° ë†dnò ©†dek k rolov†n°
         mul       byte ptr [vyska]         ; vyn†soben° poátem linek na ©†dek
         shr       ax,1
         shl       si,1                     ; poá†teán° ©†dek k rolov†n°
         add       si,offset adrrow         ; tabulka adres ©†dkñ na displeji
         mov       di,[si]                  ; p©eáten° adresy ©†dku
         inc       si
         inc       si
         mov       si,[si]                  ; adresa n†sleduj°c°ho ©†dku
         mov       bx,[bp+10]               ; poá†teán° pozice okna k rolov†n°
         add       si,bx
         add       di,bx                    ; koncovÇ adresy okna
         mov       cx,[bp+6]                ; ®°©ka okna (pozic)
         sub       cx,bx
         inc       cx                       ; - koneán† pozice okna
         mov       bx,0b800h                ; segment pamàti EGA
         mov       es,bx                    ; nastaven° segmentñ pamàti EGA
         mov       ds,bx
         cld                                ; smàr p©enosu dat nahoru
fnc0231: push      si
         push      di
         push      cx                       ; poáet bajtñ k p©enosu
         repnz     movsb                    ; p©enos jednÇ linky okna
         pop       cx
         pop       di
         pop       si
         add       di,2000h                 ; dal®° linka
         add       si,2000h
         push      si
         push      di
         push      cx                       ; poáet bajtñ k p©enosu
         repnz     movsb                    ; p©enos jednÇ linky okna
         pop       cx
         pop       di
         pop       si
         sub       di,1fb0h
         sub       si,1fb0h
         dec       ax                       ; á°taá linek
         jnz       fnc0231
fnc0232: ret

fnc024:  mov       ax,[bp+4]                ; koneánò ©†dek k rolov†n°
         mov       si,[bp+8]                ; poá†teán° ©†dek k rolov†n°
         sub       ax,si                    ; poáet ©†dkñ k rolov†n°
         jz        fnc0242                  ; nen° ë†dnò ©†dek k rolov†n°
         mul       byte ptr [vyska]         ; vyn†soben° poátem linek na ©†dek
         mov       bx,ax                    ; celkovò poáet linek k rolov†n°
         shl       si,1
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
         mov       ax,0b000h                ; segment pamàti HGC
         mov       es,ax                    ; nastaven° segmentñ pamàti EGA
         mov       ds,ax
         cld                                ; smàr p©enosu dat nahoru
fnc0241: push      si
         push      di
         push      cx                       ; poáet bajtñ k p©enosu
         repnz     movsb                    ; p©enos jednÇ linky okna
         pop       cx
         pop       di
         pop       si
         add       di,2000h                 ; dal®° linka
         jns       fnc02417
         sub       di,7fa6h
fnc02417:add       si,2000h
         jns       fnc02418
         sub       si,7fa6h
fnc02418:
         dec       bx                       ; á°taá linek
         jnz       fnc0241
fnc0242: ret

; *****************************************************************************
;
;                    Funkce 03: rolov†n° okna dolñ
;
; *****************************************************************************
;˛
                                            ; FUNKCE 03 - rolov†n° okna dolñ

                                            ; SS:BP = ukazatel parametrñ
                                            ;    + 4 = koneánò ©†dek rolov†n°
                                            ;    + 6 = ®°©ka okna (pozic)
                                            ;    + 8 = poá†teán° ©†dek k rol.
                                            ;    +10 = poá†teán° pozice okna


fnc03:   cmp       byte ptr ds:[Mode],1
         jne       Fnc032                   ; nen° textovò m¢d

         mov       ax,[bp+4]                ; koneánò ©†dek k rolov†n°
         sub       ax,[bp+8]                ; poá†teán° ©†dek k rol.-poáet ©†dkñ
         jz        fnc0319                   ; nen° ë†dnò ©†dek - konec
         mov       bx,ax                    ; poáet ©†dkñ k rolov†n°
         mov       ax,[bp+4]                ; koneánò ©†dek k rolov†n°
         mov       cx,ds:[Pozic]
         add       cx,cx
         mul       cx                       ; poá†teán° adresa koneánÇho ©†dku
         mov       si,ax                    ; poá†teán° adresa koneánÇho ©†dku
         mov       di,ax                    ; adresa n†sleduj°c°ho ©†dku
         add       di,ds:[Pozic]
         add       di,ds:[Pozic]
         mov       ax,[bp+10]               ; poá†teán° pozice okna
         dec       ax
         add       di,ax                    ; poá†teán° adresa
         add       di,ax
         add       si,ax
         add       si,ax
         mov       cx,[bp+6]                ; koneán† pozice
         sub       cx,ax                    ; poáet pozic okna k rolov†n°
         add       cx,cx
         push      es
         push      ds
         mov       ax,word ptr ds:[AdrVRAM] ; segment displeje
         mov       es,ax
         mov       ds,ax
         cld                                ; p©enos nahoru
fnc0312:
         sub       di,cs:[Pozic]
         sub       di,cs:[Pozic]
         sub       si,cs:[Pozic]
         sub       si,cs:[Pozic]
         push      si
         push      di
         push      cx
         repnz     movsb
         pop       cx
         pop       di
         pop       si
         dec       bx
         jnz       fnc0312
         pop       ds
         pop       es
fnc0319:  ret


fnc032:  cmp       byte ptr ds:[TypCard],2
         jbe       fnc033

         mov       ax,[bp+4]                ; koneánò ©†dek k rolov†n°
         mov       di,ax
         sub       ax,[bp+8]                ; poá†teán° ©†dek k rolov†n°
         jz        fnc0322                   ; je nulovò poáet ©†dkñ k rolov†n°
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
fnc0321:  sub       di,80
         sub       si,80
         push      si
         push      di
         push      cx
         repnz     movsb                    ; p©enos jednÇ linky
         pop       cx
         pop       di
         pop       si
         dec       bx
         jnz       fnc0321                   ; dal®° linka k p©enosu
         pop       ds
         call      iniega                   ; inicializace displeje EGA
fnc0322:  ret

fnc033: jb        fnc034                   ; je MDA

         mov       ax,[bp+4]                ; koneánò ©†dek k rolov†n°
         mov       di,ax
         sub       ax,[bp+8]                ; poáet ©†dkñ k rolov†n°
         jbe       fnc0332                   ; nen° ë†dnò ©†dek k rolov†n°
         mul       byte ptr [vyska]         ; vyn†soben° poátem linek na ©†dek
         shr       ax,1
         shl       di,1                     ; poá†teán° ©†dek k rolov†n°
         add       di,offset adrrow         ; tabulka adres ©†dkñ na displeji
         mov       si,[di]                  ; p©eáten° adresy ©†dku
         inc       di
         inc       di
         mov       di,[di]                  ; adresa n†sleduj°c°ho ©†dku
         mov       bx,[bp+10]               ; poá†teán° pozice okna k rolov†n°
         add       di,bx                    ; koncovÇ adresy okna
         add       si,bx
         mov       cx,[bp+6]                ; ®°©ka okna (pozic)
         sub       cx,bx
         inc       cx                       ; - koneán† pozice okna
         mov       bx,0b800h                ; segment pamàti EGA
         mov       es,bx                    ; nastaven° segmentñ pamàti EGA
         mov       ds,bx
         cld                                ; smàr p©enosu dat nahoru
fnc0331:
         add       di,1fb0h
         add       si,1fb0h
         push      si
         push      di
         push      cx                       ; poáet bajtñ k p©enosu
         repnz     movsb                    ; p©enos jednÇ linky okna
         pop       cx
         pop       di
         pop       si
         sub       di,2000h                 ; dal®° linka
         sub       si,2000h
         push      si
         push      di
         push      cx                       ; poáet bajtñ k p©enosu
         repnz     movsb                    ; p©enos jednÇ linky okna
         pop       cx
         pop       di
         pop       si
         dec       ax                       ; á°taá linek
         jnz       fnc0331
fnc0332:  ret

fnc034:   mov       ax,[bp+4]                ; koneánò ©†dek k rolov†n°
         mov       di,ax
         sub       ax,[bp+8]                ; poá†teán° ©†dek k rolov†n°
         jna       fnc0342                   ; je nulovò poáet ©†dkñ k rolov†n°
         mul       byte ptr [vyska]         ; vypoáten° poátu linek k rolov†n°
         mov       bx,ax                    ; poáet linek k rolov†n°
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
         mov       ax,0b000h                ; poá†teán° adresa pamàti EGA
         mov       es,ax                    ; nastaven° segmentu pro EGA
         mov       ds,ax
         cld                                ; smàr p©enosu dat nahoru
fnc0341:  sub       di,2000h
         jns       fnc03415
         add       di,7fa6h
fnc03415: sub       si,2000h
         jns       fnc03416
         add       si,7fa6h
fnc03416: push      si
         push      di
         push      cx
         repnz     movsb                    ; p©enos jednÇ linky
         pop       cx
         pop       di
         pop       si
         dec       bx
         jnz       fnc0341                   ; dal®° linka k p©enosu
fnc0342:  ret

; *****************************************************************************
;
;                        Funkce 04: pravò okraj (á†ra)
;
; *****************************************************************************
;˛
                                            ; FUNKCE 04 - pravò okraj (á†ra)

                                            ; SS:BP = ukazatel parametrñ
                                            ;    + 4 = k¢d á†ry
                                            ;    + 6 = koneánò ©†dek
                                            ;    + 8 = poá†teán° ©†dek
                                            ;    +10 = pozice á†ry

fnc04:   cmp       byte ptr ds:[Mode],1
         jne       Fnc042                   ; nen° textovò m¢d

         cld
         mov       si,[bp+10]               ; pozice á†ry
         dec       si
         jl        fnc0412                   ; z†porn† pozice
         cmp       si,ds:[Pozic]
         jae       fnc0412
         mov       ax,[bp+6]                ; koneánò ©†dek
         mov       di,[bp+8]                ; poá†teán° ©†dek
         sub       ax,di
         inc       ax                       ; poáet ©†dkñ
         mov       cx,ax                    ; poáet ©†dkñ
         mov       ax,ds:[Pozic]
         mul       di
         mov       di,ax
         add       di,si
         add       di,di
         push      es
         mov       ax,word ptr ds:[AdrVRAM]
         mov       es,ax
         mov       dl,ds:[cara]             ; barva okraje
         mov       dh,ds:[normal]           ; barva norm†ln°ho textu
fnc0411:  mov       al,es:[di+1]

         xor       al,dl
         xor       al,dh
;         cmp       al,dl
;         mov       al,dl
;         jnz       fnc0413
;         mov       al,dh
fnc0413:  mov       es:[di+1],al
         add       di,ds:[Pozic]
         add       di,ds:[Pozic]
         loop      fnc0411
         pop       es
fnc0412: ret


Fnc042:  cmp       byte ptr ds:[TypCard],2
         jbe       fnc043

         mov       si,[bp+10]               ; pozice á†ry
         or        si,si
         jng       fnc0422                   ; z†porn† pozice
         cmp       si,word ptr 80           ; kontrola p©ekroáen° 80 znakñ
         ja        fnc0422                   ; p©ekroáen poáet znakñ 80
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
fnc0421:  mov       ah,[di]                  ; p©eáten° bajtu
         mov       [di],al                  ; z†pis znaku á†ry
         add       di,80
         loop      fnc0421                   ; dal®° linka
         pop       ds
         call      iniega                   ; inicializace displeje EGA
fnc0422:  ret

fnc043:  jb        fnc044                   ; je MDA

         mov       si,[bp+10]               ; pozice á†ry
         or        si,si
         jng       fnc0432                   ; z†porn† pozice
         cmp       si,word ptr 80           ; kontrola p©ekroáen° 80 znakñ
         ja        fnc0432                   ; p©ekroáen poáet znakñ 80
         mov       ax,[bp+6]                ; koneánò ©†dek
         mov       di,[bp+8]                ; poá†teán° ©†dek
         sub       ax,di
         inc       ax                       ; poáet ©†dkñ okna
         mul       byte ptr [vyska]         ; poáet linek na ©†dek
         mov       cx,ax                    ; á°taá linek
         shr       cx,1
         shl       di,1                     ; poá†teán° ©†dek * 2
         add       si,[di+adrrow]           ; adresa ©†dku (v bajtech)
         mov       al,[bp+04]               ; znak á†ry
         mov       dx,0b800h                ; adresa pamàti CGA
         mov       ds,dx                    ; datovò segment na pamàü CGA
fnc0431:  xor       ds:[si],al
         add       si,2000h
         xor       ds:[si],al
         sub       si,1fb0h
         loop      fnc0431                   ; dal®° linka
fnc0432:  ret

fnc044:   mov       si,[bp+10]               ; pozice á†ry
         or        si,si
         jng       fnc0442                   ; z†porn† pozice
         cmp       si,word ptr 90           ; kontrola p©ekroáen° 90 znakñ
         ja        fnc0442                   ; p©ekroáen poáet znakñ 90
         mov       ax,[bp+6]                ; koneánò ©†dek
         mov       di,[bp+8]                ; poá†teán° ©†dek
         sub       ax,di
         inc       ax                       ; poáet ©†dkñ okna
         mul       byte ptr [vyska]         ; poáet linek na ©†dek
         mov       cx,ax                    ; á°taá linek
         shl       di,1                     ; poá†teán° ©†dek * 2
         mov       di,[di+adrrow]           ; adresa ©†dku (v bajtech)
         add       di,si                    ; adresa zaá†tku okna (v bajtech)
         mov       ax,0b000h                ; adresa pamàti HGC
         mov       ds,ax                    ; datovò segment na pamàü HGC
fnc0441:  mov       al,[bp+4]                ; p©eáten° bajtu
         xor       [di],al                  ; z†pis znaku á†ry
         add       di,2000h
         jns       fnc04415
         sub       di,7fa6h
fnc04415: loop      fnc0441                   ; dal®° linka
fnc0442:  ret

; *****************************************************************************
;
;                    Funkce 05: inicializace displeje
;
; *****************************************************************************
;˛
; -----------------------------------------------------------------------------
;        Funkce 5: Inicializace parametrñ
; -----------------------------------------------------------------------------
; VSTUP: SS:[BP+4] (1) barva podkladu
;        SS:[BP+6] (1) barva p°sma
;        SS:[BP+8] (1) reëim obrazovky
;                         1=textovò m¢d
;                         2=norm†ln° reëim
;                         3=hustò reëim (PREVIEW)
; VùSTUP: AX=poáet pozic na ©†dek
;         BX=poáet linek na ©†dek
;         CX=á°slo posledn°ho ©†dku (=poáet ©†dkñ - 1)
;         ES:SI=jmÇno karty (3 znaky ASCII)
; -----------------------------------------------------------------------------

Fnc05    PROC      NEAR

         mov       al,[bp+8]                ; reëim obrazovky (©†dkov†n°)
         mov       ds:[Mode],al             ; reëim obrazovky (1,2,3)

; ------ detekce typu videokarty

         push      bp
         call      DetCard                  ; detekce typu videokarty
         pop       bp

; ------ inicializace videom¢du

         mov       al,ds:[AktVMod]          ; videom¢d pro grafickò reëim
         cmp       byte ptr ds:[Mode],1     ; je textovò videom¢d ?
         jne       Fnc051                   ; nen° textovò videom¢d
         mov       al,ds:[TxtVMod]          ; videom¢d pro textovò reëim
Fnc051:  mov       ah,0
         call      Int10                    ; nastaven° videom¢du

; ------ inicializace pro grafickò videom¢d HGC

         cmp       byte ptr ds:[Mode],1     ; je textovò videom¢d ?
         je        Fnc052                   ; je textovò videom¢d
         cmp       byte ptr ds:[TypCard],1  ; je karta HGC ?
         jne       Fnc052                   ; nen° karta HGC
         call      InitHGC                  ; inicializace grafickÇho m¢du HGC

         mov       ax,0b000h
         mov       es,ax
         xor       ax,ax
         xor       di,di
         mov       cx,8000h/2
         rep       stosw

; ------ p©°prava adresy videopamàti

Fnc052:  mov       word ptr ds:[AdrVRAM],0b000h ; adresa karty HGC
         cmp       byte ptr ds:[TypCard],2  ; je karta CGA ?
         jb        Fnc053                   ; je karta HGC
         mov       word ptr ds:[AdrVRAM],0b800h ; textovÇ videom¢dy a m¢d CGA
         je        Fnc053                   ; je karta CGA
         cmp       byte ptr ds:[Mode],1     ; je textovò videom¢d ?
         je        Fnc053                   ; je textovò videom¢d
         mov       word ptr ds:[AdrVRAM],0a000h ; adresa pro EGA/VGA graf. m¢d

; ------ p©°prava barev displeje

Fnc053:  mov       al,[bp+6]                ; barva p°sma
         mov       bl,[bp+4]                ; barva podkladu
         call      InitCols                 ; inicializace barev displeje

; ------ p©°prava poátu ©†dkñ a vò®ky znaku

         call      InitRows                 ; inicializace poátu ©†dkñ

; ------ vypnut° kurzoru v textovÇm m¢du

         cmp       byte ptr ds:[Mode],1     ; je textovò videom¢d ?
         jne       Fnc056                   ; nen° textovò videom¢d
         mov       dx,25*HI
         mov       ah,2
         mov       bh,0
         call      Int10                    ; nastaven° kurzoru za roh

; ------ vymaz†n° displeje

Fnc056:

;         call      InitClr                  ; inicializaán° vymaz†n° displeje
;                                        ;* vymaz†n° spodn°ch linek
;        push      di
;        mov       di,476*80
;        mov       cx,0a000h                ; videopamàü EGA
;        mov       es,cx                    ; nastaven° segmentu ES
;        mov       al,[invmsk]              ; maska pro vòstup (pro inverzi)
;        mov       cx,4*80
;        cld
;        rep       stosb                    ; vymaz†n° linek
;        pop       di
;
;        pop       cx                       ;

; ------ adresa textu karty

Fnc058:  mov       al,ds:[TypCard]          ; typ karty
         mov       ah,0
         shl       ax,1
         shl       ax,1
         add       ax,offset Karta          ; adresa textu karty
         xchg      ax,si                    ; SI <- adresa textu karty

; ------ parametry displeje

Fnc059:  mov       ax,ds:[Pozic]            ; poáet pozic na ©†dek
         mov       bh,0
         mov       bl,ds:[Vyska]            ; poáet linek na ©†dek
         mov       cx,ds:[Radku]            ; poáet ©†dkñ displeje celkem
         dec       cx                       ; á°slo posledn°ho ©†dku
         push      cs
         pop       es                       ; ES <- segment ovladaáe
         ret

Fnc05    ENDP

; -----------------------------------------------------------------------------
;        p©°prava parametrñ ©†dkñ
; -----------------------------------------------------------------------------

InitRows PROC      NEAR

; ------ poáet ©†dkñ displeje celkem

         mov       al,ds:[TypCard]          ; typ karty (1 aë 4)
         mov       ah,al
         shl       al,1
         add       al,ah                    ; offset karty
         add       al,ds:[Mode]             ; offset v tabulce
         mov       ah,0
         xchg      ax,bx                    ; BX <- offset v tabulce
         mov       al,ds:[bx+TabRows-3-1]   ; poáet ©†dkñ displeje
         mov       byte ptr ds:[Radku],al   ; poáet ©†dkñ displeje

; ------ poáet linek na ©†dek

         mov       al,ds:[bx+TabLines-3-1]  ; poáet linek na ©†dek
         mov       [Vyska],al               ; poáet linek na ©†dek

; ------ poáet pozic na ©†dek

         mov       al,80                    ; poáet znakñ na ©†dek
         cmp       byte ptr ds:[TypCard],1  ; je karta HGC ?
         jne       InitRws2                 ; nen° karta HGC
         cmp       byte ptr ds:[Mode],1     ; je textovò reëim MDA ?
         je        InitRws2                 ; je textovò reëim MDA
         mov       al,90                    ; jinak 90 znakñ na ©†dek
InitRws2:mov       byte ptr ds:[Pozic],al   ; poáet pozic na ©†dek

; ------ inicializace adres ©†dkñ

         cld
         push      cs
         pop       es
         mov       cx,ds:[Radku]            ; poáet ©†dkñ displeje
         inc       cx                       ; ©†dek + 1
         mov       di,offset AdrRow         ; tabulka adres ©†dkñ na displeji

         xor       ax,ax                    ; poá†teán° adresa
         mov       dx,160                   ; poáet bajtñ na ©†dek pro text. m¢d
         cmp       byte ptr ds:[Mode],1     ; je to textovò m¢d ?
         je        InitRws4                 ; je to textovò m¢d

         mov       al,80                    ; poáet bajtñ na linku EGA/VGA
         mul       byte ptr ds:[Vyska]      ; poáet bajtñ na ©†dek pro EGA/VGA
         xchg      ax,dx                    ; DX <- p©°rustek adresy
         cmp       byte ptr ds:[TypCard],3  ; je karta EGA/VGA ?
         jae       initRws3                 ; je karta EGA/VGA
         shr       dx,1                     ; pro CGA je polovián° poáet
         cmp       byte ptr ds:[TypCard],2  ; je to karta CGA ?
         jb        InitRws5                 ; je to karta HGC

; ------ adresy ©†dkñ pro textovÇ m¢dy a pro m¢dy CGA, EGA a VGA

InitRws3:mov       ax,-1                    ; ukazatel adresy ©†dku
InitRws4:stosw                              ; uloëen° adresy ©†dku
         add       ax,dx                    ; zvò®en° adresy ©†dku
         loop      InitRws4
         jmp       short InitRws8

; ------ adresy ©†dkñ pro grafickò m¢d HGC

InitRws5:mov       ax,-1
         mov       dx,90                    ; poáet bajtñ na ©†dek
         mov       bl,ds:[Vyska]            ; vò®ka ©†dku
InitRws6:mov       al,dh                    ; ukazatel á°sla ©†dku
         mul       bl                       ; á°slo linky absolutnà
         mov       si,ax                    ; SI <- absolutn° á°slo linky
         and       si,3                     ; á°slo linky relativnà v ©†dku
         ror       si,1
         ror       si,1
         ror       si,1                     ; adresa 0, 2000h, 4000h
         shr       ax,1
         shr       ax,1                     ; á°slo ©†dku
         mul       dl                       ; poá†teán° adresa ©†dku
         add       ax,si                    ; p©iáten° korekce pro podlinku
         dec       ax                       ; p©ednastaven° - 1
         stosw                              ; uloëen° adresy linky
         inc       dh                       ; zvò®en° ukazatele á°sla linky
         loop      InitRws6                 ; dal®° ©†dek

; ------ adresa fontu

InitRws8:mov       al,ds:[Vyska]            ; vò®ka ©†dku
         mov       ah,6                     ; vò®ka zmen®enÇho fontu
         mov       bx,offset Fnt6x8         ; zmen®enò font 6x8
         mov       si,offset Fnt6x8         ; hlavn° font
         mov       word ptr ds:[Fnc005K+1],offset(Kurziv6-Fnc005K-3)
         cmp       al,6
         jbe       InitRws9
         mov       si,offset Fnt8x8
         mov       word ptr ds:[Fnc005K+1],offset(Kurziv8-Fnc005K-3)
         cmp       al,8
         jbe       InitRws9
         mov       ah,8                     ; vò®ka zmen®enÇho fontu
         mov       bx,si                    ; zmen®enò font 8x8
         mov       si,offset Fnt14x8        ; 14x8
         mov       word ptr ds:[Fnc005K+1],offset(Kurziv14-Fnc005K-3)
         cmp       al,14
         jbe       InitRws9
         mov       si,offset Fnt19x8        ; 19x8
         mov       word ptr ds:[Fnc005K+1],offset(Kurziv19-Fnc005K-3)

InitRws9:mov       ds:[AdrLFont],bx         ; zmen®enò font
         mov       ds:[AdrFont],si          ; hlavn° font
         mov       ds:[VyskaL],ah           ; poáet bajtñ na zmen®enò font
         ret

InitRows ENDP

; ------ poáet ©†dkñ displeje

TabRows  db        25,25,43                 ; MDA
         db        25,25,33                 ; CGA
         db        25,25,43                 ; EGA
         db        25,25,60                 ; VGA

; ------ poáty linek na ©†dek

TabLines db        1,14,8                   ; MDA
         db        1,8,6                    ; CGA
         db        1,14,8                   ; EGA
         db        1,19,8                   ; VGA

; -----------------------------------------------------------------------------
;        inicializace barev displeje
; -----------------------------------------------------------------------------
; VSTUP: AL=barva p°sma
;        BL=barva podkladu
; -----------------------------------------------------------------------------

InitCols PROC      NEAR

; ------ inicializace pro textovò m¢d

         cmp       byte ptr ds:[Mode],1     ; je textovò m¢d ?
         jne       InitCls3                 ; nen° textovò m¢d

; ------ barvy pro MDA reëim

         cmp       byte ptr ds:[TypCard],1  ; je karta HGC ?
         jne       InitCls1                 ; nen° karta HGC

         mov       byte ptr ds:[Normal],7
         mov       byte ptr ds:[Cara],70h
         mov       byte ptr ds:[Invert],0f0h
         mov       byte ptr ds:[Zvyraz],0fh
         mov       byte ptr ds:[Sikme],70h
         mov       byte ptr ds:[Podtrz],70h
         mov       byte ptr ds:[Jine],70h

;         cmp       al,7
;         mov       al,7
;         je        IniCls12
;         mov       al,0
;         jb        IniCls12
;         mov       al,15
;
;IniCls12:cmp       bl,7
;         mov       bl,7
;         je        InitCls1
;         mov       bl,0
;         jb        InitCls1
;         mov       bl,15
         jmp       short InitCls8

InitCls1:mov       cl,4
         shl       bl,cl                    ; p©°prava barvy podkladu
         and       al,0fh                   ; barva p°sma
         or        al,bl                    ; zadan† barva textu
         mov       bl,al                    ; £schova barvy textu
         mov       [Normal],al              ; barva norm†ln°ho textu

         push      ax
         xor       al,77h                   ; negace barvy
         mov       [Cara],al                ; barva á†ry okraje
         pop       ax

         ror       al,cl
         mov       [Invert],al              ; barva invertovanÇho textu

;         cmp       byte ptr ds:[TypCard],1  ; je karta HGC ?
;         jne       InitCls2                 ; nen° karta HGC
;
;         or        al,8
;         mov       ds:[Zvyraz],al
;         mov       ds:[Sikme],al
;         mov       ds:[Podtrz],al
;         jmp       short IniCls24
;
;InitCls2:
         and       bl,0f0h                  ; barva podkladu
         mov       al,bl
         or        al,14                    ; ëlut† barva
         mov       [Zvyraz],al              ; zvòraznànÇ p°smo
         mov       al,bl
         or        al,10                    ; zelen† barva
         mov       [Sikme],al               ; ®ikmÇ p°smo
         mov       al,bl
         or        al,13                    ; fialovÇ p°smo
         mov       [Podtrz],al              ; podtrëenÇ p°smo
         mov       al,bl
         or        al,15                    ; b°lÇ p°smo
         mov       [Jine],al                ; jinÇ p°smo
         shr       bl,cl                    ; barva podkladu
         jmp       short InitCls8

; ------ inicializace pro grafickò reëim EGA/VGA

InitCls3:cmp       byte ptr ds:[TypCard],2  ; je karta EGA nebo VGA ?
         jbe       InitCls5                 ; nen° karta EGA/VGA
         mov       bh,bl                    ; barva podkladu
         mov       ah,0                     ; maska pro inverzi - nedàl† se
         or        bh,al                    ; p©id†n° rovin barvy p°sma
         cmp       bh,bl                    ; je p°smo podmnoëinou pozad° ?
         jne       InitCls4                 ; nen° podmnoëinou pozad°
         mov       ah,-1                    ; maska pro inverzi - dàl† se
         xchg      al,bl                    ; z†màna pozad° a pop©ed°
InitCls4:or        al,bl                    ; spoleánÇ barvy pro p°smo
         mov       [PlanNg],al              ; roviny pro negaci znaku (kurzor)
         mov       [Planes],bl              ; roviny EGA pro vòstup znaku
         mov       [InvMsk],ah              ; maska znakñ pro inverzi
         call      IniEga                   ; inicializace displeje EGA/VGA
IniCls44:jmp       short InitCls9

; ------ inicializace pro grafickò reëim CGA a HGC

InitCls5:mov       byte ptr ds:[InvMsk],0ffh ; prov†d° se inverze p°sma
         cmp       al,bl                    ; je barva p°sma vy®®° neë pozad° ?
         jbe       InitCls8                 ; prov†d° se inverze
         mov       byte ptr ds:[InvMsk],0   ; inverze p°sma se neprov†d°
         mov       bl,al                    ; jinak plat° barva p°sma

; ------ nastaven° barvy okol°

InitCls8:;cmp       byte ptr ds:[TypCard],1  ; je karta HGC ?
         ;je        InitCls9                 ; okol° se pro HGC nenastavuje
         mov       ah,0bh
         mov       bh,0
         call      Int10                    ; nastaven° barvy okol°

         cmp       byte ptr ds:[Mode],1     ; je textovò reëim ?
         jne       InitCls9                 ; nen° textovò reëim

IniCls82:mov       ax,1003h
         mov       bl,0                     ; p©°znak - intezivn° podklad
         call      Int10                    ; nastaven° atributu s jasem

         xor       ax,ax
         mov       es,ax
         mov       dx,es:[463h]             ; port CRT
         add       dl,4                     ; ©°dic° port
         mov       al,bit0 + bit3
         out       dx,al                    ; vypnut° blik†n°

InitCls9:ret

InitCols ENDP

; -----------------------------------------------------------------------------
;        Inicializace displeje EGA v grafickÇm m¢du
; -----------------------------------------------------------------------------

IniEga   PROC      NEAR

         cmp       byte ptr ds:[TypCard],3  ; je karta EGA/VGA ?
         jb        IniEga9                  ; nen° karta EGA/VGA

         cli
         mov       dx,03ceh                 ; adresovò registr EGA
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
         sti

IniEga9: ret

IniEga   ENDP

; -----------------------------------------------------------------------------
;        Detekce videokarty
; -----------------------------------------------------------------------------

DetCard  PROC      NEAR

; ------ test, zda jië probàhla detekce

         cmp       byte ptr ds:[TypCard],0  ; byl jië typ karty detekov†n ?
         je        DetCard1                 ; typ karty je®tà nebyl detekov†n
         ret

; ------ £schova videom¢du

DetCard1:mov       ah,0fh
         call      Int10                    ; poskytnut° aktivn°ho videom¢du
         mov       ds:[OldVMod],al          ; £schova videom¢du

; ------ test, zda je videokarta EGA/VGA

         mov       ah,12h
         mov       bx,0ff10h
         call      Int10                    ; test, zda je karta EGA/VGA
         cmp       bh,1
         ja        DetCard3                 ; nen° karta EGA/VGA
         cmp       bl,5
         ja        DetCard3                 ; nen° karta EGA/VGA

; ------ test, zda je videokarta VGA

         mov       byte ptr ds:[TypCard],3  ; p©ednastaven° - karta EGA
         mov       ax,1a00h
         call      Int10                    ; dotaz na instalaci videokarty
         cmp       al,1ah                   ; je funkce obsluhovan† ?
         jne       DetCard4                 ; funkce nen° obsluhovan†
         cmp       bl,7
         je        DetCard2                 ; je karta VGA
         cmp       bl,8
         je        DetCard2                 ; je karta VGA
         cmp       bl,11
         je        DetCard2                 ; je karta VGA
         cmp       bl,12
         jne       DetCard4                 ; nen° karta VGA
DetCard2:mov       byte ptr ds:[TypCard],4  ; je karta VGA
         jmp       short DetCard4

; ------ test, zda je videokarta HGC

DetCard3:mov       byte ptr ds:[TypCard],1  ; je karta HGC
         cmp       byte ptr ds:[OldVMod],7  ; je videom¢d 7 (=HGC) ?
         je        DetCard4                 ; je karta HGC
         mov       byte ptr ds:[TypCard],2  ; jinak je karta CGA

; ------ p©°prava á°sla videom¢du

DetCard4:mov       bl,ds:[TypCard]          ; typ videokarty
         mov       bh,0
         dec       bx
         mov       al,ds:[bx+TabTVMod]      ; videom¢d pro textovò reëim
         mov       ds:[TxtVMod],al          ; textovò videom¢d
         mov       al,ds:[bx+TabGVMod]      ; videom¢d pro grafickò reëim
         mov       ds:[AktVMod],al          ; grafickò videom¢d
         ret

DetCard  ENDP

TabTVMod db        7,3,3,3                  ; videom¢dy pro textovò reëim
TabGVMod db        7,6,16,18                ; videom¢dy pro grafickò reëim

; -----------------------------------------------------------------------------
;        inicializace grafickÇho reëimu karty HGC
; -----------------------------------------------------------------------------

InitHGC  PROC      NEAR

         cli

; ------ nastaven° registru m¢du karty HGC

         mov       dx,3b8h
         mov       al,2
         out       dx,al                    ; grafickò m¢d

; ------ inicializace registrñ HGC

         mov       ah,0
         mov       si,offset HGCTabR        ; tabulka registrñ karty HGC
         mov       dx,3b4h                  ; adresa portu karty HGC
         cld
InitHGC2:mov       al,ah                    ; á°slo registru
         out       dx,al                    ; nastaven° á°sla registru
         inc       dx
         lodsb                              ; volba á°sla registru
         out       dx,al                    ; nastaven° registru
         dec       dx
         inc       ah                       ; zvò®en° ukazatele registrñ
         cmp       ah,16
         jb        InitHGC2                 ; dal®° registr

; ------ povolen° druhÇ str†nky videopamàti (od adresy B800h)

         mov       dx,3bfh
         mov       al,1
         out       dx,al

; ------ zapnut° videosign†lu

         mov       dx,03b8h
         mov       al,1010b                 ; grafickò m¢d, videosign†l zapnut
         out       dx,al
         sti
         ret

InitHgc  ENDP

; ------ registry pro inicializaci grafickÇho reëimu karty HGC

HGCTabR  db        53                       ; 0: horizont†lnà celkem
         db        45                       ; 1: horizont†lnà zobrazeno
         db        46                       ; 2: pozice HSYNC
         db        7                        ; 3: ®°©ka HSYNC
         db        91                       ; 4: vertik†lnà celkem
         db        2                        ; 5: vertik†ln° korekce
         db        88                       ; 6: vertik†lnà zobrazeno
         db        88                       ; 7: vertik†ln° pozice
         db        2                        ; 8: m¢d prokl†d†n°
         db        3                        ; 9: poáet linek na ©†dek
         db        0                        ; 10: poá†tek kurzoru
         db        0                        ; 11: konec kurzoru
         db        0                        ; 12: adresa poá†tku HIGH
         db        0                        ; 13: adresa poá†tku LOW
         db        0                        ; 14: kurzor HIGH
         db        0                        ; 15: kurzor LOW

; -----------------------------------------------------------------------------
;        obsluha INT 10h s £schovou registrñ
; -----------------------------------------------------------------------------

Int10    PROC      NEAR

         pushf
         push      si
         push      di
         push      bp
         push      ds
         push      es

         int       10h

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         popf
         ret

Int10    ENDP

; *****************************************************************************
;
;                   Funkce 06: n†vrat textovÇho videom¢du
;
; *****************************************************************************
;˛
                                            ; FUNKCE 06 - nastaven° text. m¢du
fnc06:   mov       al,ds:[OldVMod]
         mov       ah,0
         call      Int10                    ; nastaven° textovÇho m¢du 80x25
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

; *****************************************************************************
;
;                        Funkce 09: rozdàlov†n° slov
;
; *****************************************************************************
;˛
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

; *****************************************************************************
;
;                     Funkce 10: dek¢dov†n° kl†vesy
;
; *****************************************************************************
;˛
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

; *****************************************************************************
;
;                   Funkce 11: vòpis k¢du kl†vesy
;
; *****************************************************************************
;˛
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

; *****************************************************************************
;
;                   Funkce 07: poskytnut° adresy definice okna
;
; *****************************************************************************
;˛
; -----------------------------------------------------------------------------
;        Poskytnut° adresy definice okna menu
; -----------------------------------------------------------------------------
; VSTUP: SS:[BP+4] (2) á°slo poëadovanÇho okna
; VùSTUP: ES:SI=adresa definice okna
; -----------------------------------------------------------------------------

Fnc07    PROC      NEAR

         mov       bx,[bp+4]
         shl       bx,1
         mov       si,[bx+TabHlp]
         push      ds
         pop       es
         ret

Fnc07    ENDP

INCLUDE  SCREENWN.ASM                       ; definice oken

; *****************************************************************************
;
;                   Funkce 08: poskytnut° adresy textu hl†®en°
;
; *****************************************************************************
;˛
; -----------------------------------------------------------------------------
;        Poskytnut° adresy tabulky chybovòch hl†®en°
; -----------------------------------------------------------------------------
; VùSTUP: ES:SI=adresa tabulky chybovòch hl†®en°
; -----------------------------------------------------------------------------

Fnc08    PROC      NEAR

         mov       si,offset TabErr         ; tabulka hl†®en°
         push      ds                       ; nastaven° ES = DS
         pop       es
         ret

Fnc08    ENDP

TabErr   LABEL     BYTE
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

; *****************************************************************************
;
;                                Fonty
;
; *****************************************************************************
;˛
; Pro grafickò m¢d CGA a HGC mus° bòt sudò poáet linek na znak !

INCLUDE  SCREEN06.ASM                       ; fonty 8x6
INCLUDE  SCREEN08.ASM                       ; fonty 8x8
INCLUDE  SCREEN14.ASM                       ; fonty 8x14
INCLUDE  SCREEN19.ASM                       ; fonty 8x19

Code     ENDS
         END       Screen

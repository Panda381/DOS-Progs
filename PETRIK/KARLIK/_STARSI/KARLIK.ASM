
; *****************************************************************************
;
;                                    Karl¡k
;
; -----------------------------------------------------------------------------
; Velikost pol¡Ÿek: 32*32 bod…/16 barev (ikony WINDOWS)
; Pou§itì videom¢d: 640*480/16 barev (videom¢d VGA)
;                     Pro jin‚ videokarty ne§ VGA jsou ikony
;                     redukov ny na menç¡ rozliçen¡
; Velikost plochy:  14*14 pol¡Ÿek, kolem plochy r m o ç¡ýce 8 bod…,
;                   pod plochou textovì a ovl dac¡ ý dek o vìçce 16 linek
;                   (d‚lka 80 znak…=640 bod…), vpravo od plochy ovl dac¡ p s
;                   5*14 pol¡Ÿek (resp. ç¡ýka 20 znak…) s r mem 8 bod…
; -----------------------------------------------------------------------------
; Intern¡ souýadnice se ud vaj¡ po n sobc¡ch 8 bod…: tj. max. X=80 a Y=60
; -----------------------------------------------------------------------------
; N vratov‚ k¢dy programu: 0=vçe OK
;                          1=chyba syntaxe vstupn¡ho programu nebo soubor nenalezen
;                          2=nedostatek pamØti
; *****************************************************************************

PSIRKA   EQU       18                       ; ç¡ýka hrac¡ho pole (pol¡Ÿek)
PVYSKA   EQU       14                       ; vìçka hrac¡ho pole (pol¡Ÿek)
MSIRKA   EQU       1                        ; ç¡ýka okna menu (pol¡Ÿek)
MVYSKA   EQU       14                       ; vìçka okna menu (pol¡Ÿek)

BUFFSIZE EQU       1024                     ; vstupn¡ buffer programu

bit0     EQU       1
bit1     EQU       2
bit2     EQU       4
bit3     EQU       8
bit4     EQU       10h
bit5     EQU       20h
bit6     EQU       40h
bit7     EQU       80h

ICOSize  EQU       32*32*5/8                ; velikost ikony v bajtech

HercSir  EQU       90                       ; ç¡ýka ý dku pro Hercules

; ------ intern¡ k¢dy

KOD_OBR  EQU       1                        ; 1: kreslen¡ obr zku
KOD_OPAK EQU       2                        ; 2: OPAKUJ
KOD_LZAV EQU       3                        ; 3: lev  z vorka
KOD_RZAV EQU       4                        ; 4: prav  z vorka
KOD_PROC EQU       5                        ; 5: definice/proveden¡ pý¡kazu
KOD_POZ  EQU       6                        ; 6: POZICE
KOD_KROK EQU       7                        ; 7: KROK
KOD_VLEV EQU       8                        ; 8: VLEVO
KOD_VPRA EQU       9                        ; 9: VPRAVO
KOD_VZAD EQU       10                       ; 10: VZAD
KOD_CEK  EQU       11                       ; 11: CEKEJ
KOD_RYCH EQU       12                       ; 12: RYCHLE
KOD_POM  EQU       13                       ; 13: POMALU
KOD_SEV  EQU       14                       ; 14: SEVER
KOD_JIH  EQU       15                       ; 15: JIH
KOD_VYCH EQU       16                       ; 16: VYCHOD
KOD_ZAP  EQU       17                       ; 17: ZAPAD
KOD_JEST EQU       18                       ; 18: JESTLI
KOD_JIN  EQU       19                       ; 19: JINAK
KOD_NENI EQU       20                       ; 20: NENI
KOD_PRER EQU       21                       ; 21: PRERUS
KOD_DOK  EQU       22                       ; 22: DOKUD

; -----------------------------------------------------------------------------
;        noty pro hran¡ melodie
; -----------------------------------------------------------------------------

MC       EQU       0                        ; C
MCI      EQU       1                        ; C#
MD       EQU       2                        ; D
MDI      EQU       3                        ; D#
ME       EQU       4                        ; E
MF       EQU       5                        ; F
MFI      EQU       6                        ; F#
MG       EQU       7                        ; G
MGI      EQU       8                        ; G#
MA       EQU       9                        ; A
MAI      EQU       10                       ; A#
MH       EQU       11                       ; H

M32      EQU       1                        ; d‚lka 1/32
M16      EQU       2                        ; d‚lka 1/16
M8       EQU       4                        ; d‚lka 1/8
M4       EQU       8                        ; d‚lka 1/4
M2       EQU       16                       ; d‚lka 1/2
M1       EQU       32                       ; d‚lka cel 

MO0      EQU       1                        ; okt va 0
MO1      EQU       13                       ; okt va 1
MO2      EQU       25                       ; okt va 2
MO3      EQU       37                       ; okt va 3
MO4      EQU       49                       ; okt va 4
MO5      EQU       61                       ; okt va 5
MO6      EQU       73                       ; okt va 6
MO7      EQU       85                       ; okt va 7
MO8      EQU       97                       ; okt va 8
MO9      EQU       109                      ; okt va 9

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ pýedefinov n¡ z sobn¡ku

Start:   cmp       sp,offset Zasob          ; je pamØœ OK ?
         jb        ChybaMem                 ; chyba pamØti
         mov       sp,offset Zasob          ; pýedefinov n¡ z sobn¡ku

; ------ zmençen¡ bloku programu

         mov       bx,(offset(Zasob-Start)+10fh)/16 ; nov  velikost programu
         mov       ah,4ah
         int       21h                      ; zmençen¡ alokaŸn¡ho bloku

; ------ vytvoýen¡ datov‚ho bloku

         mov       bx,-1
         mov       ah,48h
         int       21h
         mov       ah,48h
         int       21h                      ; pýidØlen¡ bloku pamØti
         jnc       Start1                   ; je to OK

; ------ chyba - nedostatek pamØti

ChybaMem:mov       bp,offset MemErr         ; chyba - nedostatek pamØti
;Chyba1:  mov       ah,9
;         mov       dx,offset UvTxt
;         int       21h
         mov       ah,9
         mov       dx,bp                    ; text chyby
         int       21h
         mov       ax,4c02h
         int       21h

;Chyba:   jc        Chyba1                   ; je chyba
;         ret

; ------ ukazatele pamØœov‚ho bloku

Start1:  mov       ds:[DataSegm],ax         ; adresa datov‚ho segmentu
         mov       ds:[DataProg],ax         ; adresa zaŸ tku programu
         cmp       bx,200h                  ; asi tak minim lnØ 8 KB
         jb        ChybaMem                 ; chyba - m lo pamØti
         add       ax,bx                    ; adresa konce pamØti
         mov       ds:[DataEnd],ax          ; adresa konce pamØti
         mov       ds:[DataICO],ax          ; adresa zaŸ tku ikon


Start2:


; ------ naŸten¡ vçech ikon do bufferu

         call      ReadICO                  ; naŸten¡ vçech ikon
         jc        ChybaMem                 ; chyba pamØti

; ------ inicializace implicitn¡ch ikon

         call      IniICOD                  ; inicializace implicitn¡ch ikon

; ------ naŸten¡ programu

         call      ReadPrg                  ; naŸten¡ programu
         jc        ChybaMem                 ; chyba pamØti

         cmp       word ptr ds:[CitChyb],0
         je        Start22
         mov       ax,4c01h
         int       21h

; ------ inicializace pozad¡ ikon

Start22: call      IniPozad                 ; inicializace pozad¡ ikon

; ------ inicializace videom¢du

         call      IniCard                  ; inicializace videokarty

; ------ inicializace palet displeje

         call      InitPal                  ; inicializace palet displeje

; ------ inicializace myçi

         call      InitMous                 ; inicializace myçi

; ------ instalace obsluhy INT 23h a INT 24h

         mov       dx,offset INT24
         mov       ax,2524h
         int       21h
         mov       dx,offset INT23
         mov       ax,2523h
         int       21h

; ------ instalace obsluhy INT 08h

         mov       ax,3508h
         int       21h                      ; poskytnut¡ adresy INT 08h
         mov       word ptr ds:[Old08],bx
         mov       word ptr ds:[Old08+2],es
         mov       dx,offset Int08          ; nov  obsluha INT 08h
         mov       ax,2508h
         int       21h                      ; nastaven¡ nov‚ obsluhy INT 08h

; ------ vymaz n¡ obrazovky

         call      IniVymaz                 ; inicializaŸn¡ vymaz n¡ obrazovky

Start3:  call      DispPole
         call      DispKar                  ; zobrazen¡ Karla

         call      ExecPrg                  ; proveden¡ programu

         call      KarPom                   ; nastaven¡ pomal‚ho Karla
         call      CekKrokD                 ; zobrazen¡ Karla

Start32: mov       word ptr ds:[BlokIf],0   ; odblokov n¡ pý¡kaz…
         and       byte ptr ds:[Param],not bit4 ; nen¡ pýeruçen¡ cyklu
Start4:  call      FlushChr                 ; vypr zdnØn¡ bufferu kl vesnice

Start402:call      MouseOn
         call      TestChr                  ; test znaku z kl vesnice
         jnc       Start408
         call      IntHlas                  ; maz n¡ hl çen¡
         call      GetMouse
         jc        Start402

         mov       ax,4800h                 ; vpýed
         cmp       dx,300h
         je        Start409
         mov       ax,5000h                 ; vzad
         cmp       dx,100h
         je        Start409
         mov       ax,4b00h
         or        dx,dx                    ; vlevo
         je        Start409
         mov       ax,4d00h                 ; vpravo
         cmp       dx,200h
         je        Start409
         mov       ax," "
         cmp       dx,400h
         je        Start409
         mov       ax,13
         cmp       dx,500h
         je        Start409
;         mov       al,"1"
;         cmp       dx,700h
;         je        Start409

         mov       ax,27
         cmp       dx,0d00h
         je        Start409

         jmp       short Start402

Start408:call      InpChr                   ; vstup znaku z kl vesnice

Start409: cmp       al,27
         jne       Start411
         jmp       Konec

Start411:cmp       ax,4800h
         jne       Start42
         call      KarKrok
Start418:jmp       Start32

Start42: cmp       ax,5000h
         jne       Start43
         call      KarVzad
         jmp       short Start418

Start43: cmp       ax,4b00h
         jne       Start44
         call      KarVlevo
         jmp       short Start418

Start44: cmp       ax,4d00h
         jne       Start45
         call      KarVprav
         jmp       short Start418

Start45: mov       bx,ds:[ICONic]
         cmp       al," "
         je        Start46
         mov       bx,ds:[ICOZed]
         cmp       al,13
         je        Start46

         call      UpCase
         sub       al,"A"
         jb        Start418
         cmp       al,26
         ja        Start418
         mov       ah,ICOSize/16
         mul       ah
         add       ax,ds:[DataICO]
         xchg      ax,bx
Start46: xchg      ax,bx
         call      KarPredm                 ; polo§en¡ pýedmØtu
         jmp       short Start418


Konec:   mov       ax,3
         int       10h

         mov       ah,9
         mov       dx,offset UvTxt
         int       21h

; ------ zobrazen¡ zbìvaj¡c¡ voln‚ pamØti

         mov       ax,ds:[DataICO]          ; segment poŸ tku ikon
         mov       bx,ds:[DataNum]          ; poŸet bajt… programu
         mov       cl,4
         shr       bx,cl
         sub       ax,bx                    ; odeŸten¡ programu
         sub       ax,ds:[DataProg]
         jnc       Konec12
         xor       ax,ax
Konec12: mov       cl,10-4
         shr       ax,cl                    ; pýevod na KB
         push      ds
         pop       es
         mov       di,offset ZbyvMem2
         call      DekNumR                  ; dek¢dov n¡ Ÿ¡sla

         mov       dx,offset ZbyvMem
         mov       ah,9
         int       21h

; ------ konec

Konec1:
         push      ds
         mov       ax,2508h
         lds       dx,ds:[Old08]            ; p…vodn¡ adresa INT 08h
         int       21h                      ; navr cen¡ adresy INT 08h
         pop       ds

         mov       ax,4c00h
         int       21h

; *****************************************************************************
;
;                             Obsluha Karla
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        vykreslen¡ obr zku programem -> CY=pýeruçen¡
; -----------------------------------------------------------------------------

KarKresl PROC      NEAR

         call      WordPrg                  ; naŸten¡ adresy ikony
         jc        KarKres9                 ; chyba
         test      byte ptr ds:[Param],bit4 ; je pýeruçen¡ cyklu ?
         jnz       KarKres9                 ; je pýeruçen¡ cyklu
         cmp       word ptr ds:[BlokIf],0   ; je blokov n¡ pý¡kaz… IF ?
         jne       KarKres9                 ; je blokov n¡ pý¡kaz…
         call      KarPredm                 ; vykreslen¡ pýedmØtu
         jc        KarKres9                 ; chyba
         test      byte ptr ds:[Param],bit0 ; je TURBO re§im ?
         jnz       KarKres9                 ; je TURBO re§im
         call      CekKrokD                 ; Ÿek n¡ na jeden krok (CY=pýeruçen¡)
KarKres9:ret

KarKresl ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ nov‚ pozice Karla -> CY=pýeruçen¡
; -----------------------------------------------------------------------------

KarPoz   PROC      NEAR

         call      WordPrg                  ; naŸten¡ pozice
         jc        KarKres9                 ; chyba

         cmp       al,PSIRKA                ; je pozice OK ?
         jb        KarPoz2                  ; pozice je OK
         mov       al,PSIRKA-1              ; omezen¡ pozice

KarPoz2: cmp       ah,PVYSKA                ; je ý dek OK ?
         jb        KarPoz4                  ; ý dek je OK
         mov       ah,PVYSKA-1              ; omezen¡ ý dku

KarPoz4: cmp       ax,ds:[KarelPoz]         ; zmØnila se pozice ?
         je        KarPoz9                  ; pozice se nezmØnila
         mov       ds:[KarelPoz],ax         ; nov  pozice Karla

         test      byte ptr ds:[Param],bit0 ; je TURBO re§im ?
         jnz       KarPoz9                  ; je TURBO re§im
         call      CekKrokD                 ; Ÿek n¡ na jeden krok (CY=pýeruçen¡)
KarPoz9: ret

KarPoz   ENDP

; -----------------------------------------------------------------------------
;        polo§en¡ pýedmØtu AX pýed Karla -> CY=chyba, je okraj
; -----------------------------------------------------------------------------

KarPredm PROC      NEAR

; ------ £schova registr…

         push      bx
         push      dx
         xchg      ax,dx                    ; DX <- pýedmØt

; ------ ukazatel pozice Karla

         mov       ah,0
         mov       al,ds:[KarelSme]         ; smØr Karla
         mov       bx,ds:[KarelPoz]         ; ý dek a pozice Karla

; ------ smØr dol…

         or        ax,ax                    ; 0 = dol…
         jnz       KarPred1
         inc       bh                       ; smØr dol…

; ------ smØr vpravo

KarPred1:dec       ax                       ; 1 = vpravo
         jnz       KarPred2                 ; nen¡ vpravo
         inc       bx                       ; smØr vpravo

; ------ smØr nahoru

KarPred2:dec       ax                       ; 2 = nahoru
         jnz       KarPred3
         dec       bh                       ; smØr nahoru

; ------ smØr vlevo

KarPred3:dec       ax                       ; 3 = vlevo
         jnz       KarPred4
         dec       bx                       ; smØr vlevo

; ------ kontrola pýeteŸen¡ pozice a ý dku

KarPred4:cmp       bl,PSIRKA-1              ; kontrola pozice
         ja        KarPred8                 ; chyba
         cmp       bh,PVYSKA-1
         ja        KarPred8                 ; chyba

; ------ ulo§en¡ pýedmØtu na novou pozici

         mov       al,PSIRKA                ; poŸet pozic na ý dek
         mul       bh                       ; pýepoŸet ý dku na pozici
         add       al,bl                    ; pýiŸten¡ pozice
         adc       ah,0
         shl       ax,1                     ; offset v tabulce pole
         xchg      ax,bx                    ; BX <- offset v poli
         cmp       word ptr ds:[bx+Pole],dx ; je pýedmØt zmØnØn ?
         je        KarPred7                 ; pýedmØt je ji§ ulo§en
         mov       ds:[bx+Pole],dx          ; ulo§en¡ pýedmØtu

; ------ zobrazen¡ nov‚ho pýedmØtu

         xchg      ax,dx                    ; AX <- pýedmØt, DX <- souýadnice
         call      PoleIcon                 ; zobrazen¡ pýedmØtu na nov‚ pozici
         xchg      ax,dx
KarPred7:clc                                ; pý¡znak operace OK
         jmp       short KarPred9

; ------ chyba operace - je okraj

KarPred8:push      si
         push      cx

         mov       si,offset OkrajTxt
         mov       ah,9bh                   ; barva
         mov       cx,2*18                  ; po§adovan  doba
         call      DispHlas                 ; zobrazen¡ hl çen¡
         mov       word ptr ds:[UkazMel],offset OkrajTon ; melodie

         pop       cx
         pop       si
         stc                                ; pý¡znak chyby operace

; ------ n vrat registr…

KarPred9:xchg      ax,dx                    ; AX <- n vrat pýedmØtu
         pop       dx
         pop       bx
         ret

KarPredm ENDP

; -----------------------------------------------------------------------------
;        otoŸen¡ na sever (-> CY=pýeruçen¡)
; -----------------------------------------------------------------------------

KarSev   PROC      NEAR

         test      byte ptr ds:[Param],bit4 ; je pýeruçen¡ cyklu ?
         jnz       KarSev9                  ; je pýeruçen¡ cyklu
         cmp       word ptr ds:[BlokIf],0   ; je blokov n¡ pý¡kaz… IF ?
         jne       KarSev9                  ; je blokov n¡ pý¡kaz…
         cmp       byte ptr ds:[KarelSme],2 ; je ji§ otoŸen ?
         je        KarSev9                  ; je ji§ otoŸen
         mov       byte ptr ds:[KarelSme],2 ; nahoru = sever
         jmp       KarVlev3

KarSev9: ret

KarSev   ENDP

; -----------------------------------------------------------------------------
;        otoŸen¡ na jih (-> CY=pýeruçen¡)
; -----------------------------------------------------------------------------

KarJih   PROC      NEAR

         test      byte ptr ds:[Param],bit4 ; je pýeruçen¡ cyklu ?
         jnz       KarJih9                  ; je pýeruçen¡ cyklu
         cmp       word ptr ds:[BlokIf],0   ; je blokov n¡ pý¡kaz… IF ?
         jne       KarJih9                  ; je blokov n¡ pý¡kaz…
         cmp       byte ptr ds:[KarelSme],0 ; je ji§ otoŸen ?
         je        KarJih9                  ; je ji§ otoŸen
         mov       byte ptr ds:[KarelSme],0 ; dol… = jih
         jmp       short KarVlev3

KarJih9: ret

KarJih   ENDP

; -----------------------------------------------------------------------------
;        otoŸen¡ na vìchod (-> CY=pýeruçen¡)
; -----------------------------------------------------------------------------

KarVych  PROC      NEAR

         test      byte ptr ds:[Param],bit4 ; je pýeruçen¡ cyklu ?
         jnz       KarVych9                 ; je pýeruçen¡ cyklu
         cmp       word ptr ds:[BlokIf],0   ; je blokov n¡ pý¡kaz… IF ?
         jne       KarVych9                 ; je blokov n¡ pý¡kaz…
         cmp       byte ptr ds:[KarelSme],1 ; je ji§ otoŸen ?
         je        KarVych9                 ; je ji§ otoŸen
         mov       byte ptr ds:[KarelSme],1 ; vpravo = vìchod
         jmp       short KarVlev3

KarVych9:ret

KarVych  ENDP

; -----------------------------------------------------------------------------
;        otoŸen¡ na z pad (-> CY=pýeruçen¡)
; -----------------------------------------------------------------------------

KarZap   PROC      NEAR

         test      byte ptr ds:[Param],bit4 ; je pýeruçen¡ cyklu ?
         jnz       KarZap9                  ; je pýeruçen¡ cyklu
         cmp       word ptr ds:[BlokIf],0   ; je blokov n¡ pý¡kaz… IF ?
         jne       KarZap9                  ; je blokov n¡ pý¡kaz…
         cmp       byte ptr ds:[KarelSme],3 ; je ji§ otoŸen ?
         je        KarZap9                  ; je ji§ otoŸen
         mov       byte ptr ds:[KarelSme],3 ; vlevo = z pad
         jmp       short KarVlev3

KarZap9: ret

KarZap   ENDP

; -----------------------------------------------------------------------------
;        otoŸen¡ vzad (-> CY=pýeruçen¡)
; -----------------------------------------------------------------------------

KarVzad  PROC      NEAR

         test      byte ptr ds:[Param],bit4 ; je pýeruçen¡ cyklu ?
         jnz       KarVlev9                 ; je pýeruçen¡ cyklu
         cmp       word ptr ds:[BlokIf],0   ; je blokov n¡ pý¡kaz… IF ?
         jne       KarVlev9                 ; je blokov n¡ pý¡kaz…
         sub       byte ptr ds:[KarelSme],2 ; posun smØru vzad
         jmp       short KarVlev2

KarVzad  ENDP

; -----------------------------------------------------------------------------
;        otoŸen¡ vlevo (-> CY=pýeruçen¡)
; -----------------------------------------------------------------------------

KarVlevo PROC      NEAR

         test      byte ptr ds:[Param],bit4 ; je pýeruçen¡ cyklu ?
         jnz       KarVlev9                 ; je pýeruçen¡ cyklu
         cmp       word ptr ds:[BlokIf],0   ; je blokov n¡ pý¡kaz… IF ?
         jne       KarVlev9                 ; je blokov n¡ pý¡kaz…
         sub       byte ptr ds:[KarelSme],3 ; posun o 3 kroky
KarVlev2:jns       KarVlev3                 ; nen¡ podteŸen¡
         add       byte ptr ds:[KarelSme],4 ; posun nahoru
KarVlev3:test      byte ptr ds:[Param],bit0 ; je TURBO re§im ?
         jnz       KarVlev9                 ; je TURBO re§im
         call      CekKrokD                 ; Ÿek n¡ na jeden krok
KarVlev9:ret

KarVlevo ENDP

; -----------------------------------------------------------------------------
;        otoŸen¡ vpravo (-> CY=pýeruçen¡)
; -----------------------------------------------------------------------------

KarVprav PROC      NEAR

         test      byte ptr ds:[Param],bit4 ; je pýeruçen¡ cyklu ?
         jnz       KarVlev9                 ; je pýeruçen¡ cyklu
         cmp       word ptr ds:[BlokIf],0   ; je blokov n¡ pý¡kaz… IF ?
         jne       KarVlev9                 ; je blokov n¡ pý¡kaz…
         dec       byte ptr ds:[KarelSme]   ; zmØna smØru vpravo
         jmp       short KarVlev2

KarVprav ENDP

; -----------------------------------------------------------------------------
;        krok vpýed -> CY=chyba, je zeÔ
; -----------------------------------------------------------------------------

KarKrok  PROC      NEAR

         test      byte ptr ds:[Param],bit4 ; je pýeruçen¡ cyklu ?
         jnz       KarVlev9                 ; je pýeruçen¡ cyklu
         cmp       word ptr ds:[BlokIf],0   ; je blokov n¡ pý¡kaz… IF ?
         jne       KarVlev9                 ; je blokov n¡ pý¡kaz…

; ------ £schova registr…

         push      ax
         push      bx

; ------ test, zda je pýed Karlem zeÔ

         call      TestZed                  ; test zdi pýed Karlem
         jc        KarKrok0                 ; nen¡ zeÔ

; ------ chyba - n raz do zdi

         push      cx
         push      si

         mov       si,offset NarazTxt
         mov       ah,9bh                   ; barva
         mov       cx,2*18                  ; po§adovan  doba
         call      DispHlas                 ; zobrazen¡ hl çen¡
         mov       word ptr ds:[UkazMel],offset NarazTon ; melodie

         pop       si
         pop       cx
         stc                                ; pý¡znak chyby - je zeÔ
         jmp       KarKrok9

; ------ ukazatel pozice Karla

KarKrok0:mov       bx,ds:[KarelPoz]         ; ý dek a pozice Karla
         mov       ah,0
         mov       al,ds:[KarelSme]         ; smØr Karla

; ------ krok dol…

         or        ax,ax                    ; 0 = dol…
         jnz       KarKrok1
         inc       bh                       ; krok dol…

; ------ krok vpravo

KarKrok1:dec       ax                       ; 1 = vpravo
         jnz       KarKrok2                 ; nen¡ vpravo
         inc       bx                       ; krok vpravo

; ------ krok nahoru

KarKrok2:dec       ax                       ; 2 = nahoru
         jnz       KarKrok3
         dec       bh                       ; krok nahoru

; ------ krok vlevo

KarKrok3:dec       ax                       ; 3 = vlevo
         jnz       KarKrok4
         dec       bx                       ; krok vlevo

; ------ nastaven¡ nov‚ pozice Karla

KarKrok4:xchg      bx,ds:[KarelPoz]         ; nov  pozice Karla

; ------ test, zda se m  Karel zobrazovat

         test      byte ptr ds:[Param],bit0 ; je TURBO re§im ?
         jnz       KarKrok9                 ; je TURBO re§im
         cmp       bx,ds:[KarelOPz]         ; byl zobrazen na pýedeçl‚ pozici ?
         jne       KarKrok7                 ; nebyl na pýedeçl‚ pozici

; ------ vymaz n¡ Karla na pýedeçl‚ pozici

         call      MazKar                   ; vymaz n¡ Karla na pýedeçl‚ pozici

; ------ £schova registr…

         push      cx
         push      dx
         push      es

         mov       dx,bx                    ; DX <- star  pozice Karla

; ------ urŸen¡ ikony k zobrazen¡ kroku -> ES

         mov       ah,0
         mov       al,ds:[KarelSme]         ; smØr Karla
         or        ax,ax                    ; 0 = dol…
         jnz       KarKrk42
         mov       es,ds:[ICOKarP]          ; pohle zepýedu
KarKrk42:dec       ax                       ; 1 = vpravo
         jnz       KarKrk44                 ; nen¡ vpravo
         mov       es,ds:[ICOKarR]          ; pohled zprava
KarKrk44:dec       ax                       ; 2 = nahoru
         jnz       KarKrk46
         mov       es,ds:[ICOKarZ]          ; pohled zezadu
KarKrk46:dec       ax                       ; 3 = vlevo
         jnz       KarKrk48
         mov       es,ds:[ICOKarL]          ; pohled vlevo

; ------ urŸen¡ pý¡rustku kroku -> BX

KarKrk48:mov       bx,ds:[KarelPoz]
         sub       bl,dl                    ; zmØna pozice
         sub       bh,dh                    ; zmØna ý dku

         shl       dx,1
         shl       dx,1
         add       dx,101h

; ------ zobrazen¡ posouvan‚ho Karla

         mov       cx,3                     ; poŸet krok…
KarKrok5:add       dl,bl                    ; zvìçen¡ pozice
         add       dh,bh                    ; zvìçen¡ ý dku
         call      MaskIcon                 ; zobrazen¡ Karla na nov‚ pozici

; ------ Ÿek n¡ po dobu jednoho kroku

         call      CekKrok                  ; Ÿek n¡ na jeden krok

; ------ vymaz n¡ Karla na mezipozici

         pushf
         push      dx
         mov       dx,ds:[KarelOPz]         ; star  pozice
         call      PoleIcon                 ; zobrazen¡ pýedmØtu na star‚ pozici
         mov       dx,ds:[KarelPoz]         ; nov  pozice
         call      PoleIcon                 ; zobrazen¡ pýedmØtu na nov‚ pozici
         pop       dx
         popf

; ------ dalç¡ krok

         jc        KarKrok6                 ; pýeruçen¡

         loop      KarKrok5                 ; dalç¡ krok

; ------ n vrat registr…

KarKrok6:pop       es
         pop       dx
         pop       cx
         jc        KarKrok9                 ; pýeruçen¡

; ------ zobrazen¡ Karla na nov‚ pozici

KarKrok7:call      CekKrokD                 ; Ÿek n¡ na jeden krok (CY=pýeruçen¡)

; ------ n vrat registr…

KarKrok9:pop       bx
         pop       ax
         ret

KarKrok  ENDP

; -----------------------------------------------------------------------------
;        test pr…chodnosti, zda je pýed Karlem zeÔ -> NC=je zeÔ
; -----------------------------------------------------------------------------

TestZed  PROC      NEAR

; ------ £schova registr…

         push      ax
         push      bx

; ------ ukazatel pozice Karla

         mov       ah,0
         mov       bx,ds:[KarelPoz]         ; ý dek a pozice Karla
         mov       al,ds:[KarelSme]         ; smØr Karla

; ------ krok dol…

         or        ax,ax                    ; 0 = dol…
         jnz       TestZed1
         inc       bh                       ; krok dol…

; ------ krok vpravo

TestZed1:dec       ax                       ; 1 = vpravo
         jnz       TestZed2                 ; nen¡ vpravo
         inc       bx                       ; krok vpravo

; ------ krok nahoru

TestZed2:dec       ax                       ; 2 = nahoru
         jnz       TestZed3
         dec       bh                       ; krok nahoru

; ------ krok vlevo

TestZed3:dec       ax                       ; 3 = vlevo
         jnz       TestZed4
         dec       bx                       ; krok vlevo

; ------ kontrola pýeteŸen¡ pozice a ý dku

TestZed4:cmp       bl,PSIRKA-1              ; kontrola pozice
         ja        TestZed8                 ; chyba
         cmp       bh,PVYSKA-1
         ja        TestZed8                 ; chyba

; ------ kontrola, zda je na nov‚ pozici zeÔ

         test      byte ptr ds:[Param],bit0 ; je TURBO ?
         jnz       TestZed5                 ; je TURBO

         mov       al,PSIRKA                ; poŸet pozic na ý dek
         mul       bh                       ; pýepoŸet ý dku na pozici
         mov       bh,0
         add       ax,bx                    ; pýiŸten¡ pozice
         shl       ax,1                     ; offset v tabulce pole
         xchg      ax,bx                    ; BX <- offset v poli
         mov       ax,ds:[ICOZed]           ; ikona zdi
         cmp       ax,ds:[bx+Pole]          ; je to zeÔ ?
TestZed5:stc                                ; pý¡znak, §e nen¡ zeÔ
         jne       TestZed9                 ; nen¡ zeÔ

; ------ je zeÔ

TestZed8:clc                                ; pý¡znak, §e je zeÔ

; ------ n vrat registr…

TestZed9:pop       bx
         pop       ax
         ret

TestZed  ENDP

; -----------------------------------------------------------------------------
;        naŸten¡ pýedmØtu pýed Karlem -> AX (0=je mimo okraj)
; -----------------------------------------------------------------------------

GetPred  PROC      NEAR

; ------ £schova registr…

         push      bx

; ------ ukazatel pozice Karla

         mov       ah,0
         mov       al,ds:[KarelSme]         ; smØr Karla
         mov       bx,ds:[KarelPoz]         ; ý dek a pozice Karla

; ------ krok dol…

         or        ax,ax                    ; 0 = dol…
         jnz       GetPred1
         inc       bh                       ; krok dol…

; ------ krok vpravo

GetPred1:dec       ax                       ; 1 = vpravo
         jnz       GetPred2                 ; nen¡ vpravo
         inc       bx                       ; krok vpravo

; ------ krok nahoru

GetPred2:dec       ax                       ; 2 = nahoru
         jnz       GetPred3
         dec       bh                       ; krok nahoru

; ------ krok vlevo

GetPred3:dec       ax                       ; 3 = vlevo
         jnz       GetPred4
         dec       bx                       ; krok vlevo

; ------ kontrola pýeteŸen¡ pozice a ý dku

GetPred4:xor       ax,ax                    ; pý¡znak neplatn‚ pozice
         cmp       bl,PSIRKA                ; kontrola pozice
         jae       GetPred9                 ; chyba
         cmp       bh,PVYSKA
         jae       GetPred9                 ; chyba

; ------ naŸten¡ pýedmØtu pýed Karlem

         mov       al,PSIRKA                ; poŸet pozic na ý dek
         mul       bh                       ; pýepoŸet ý dku na pozici
         mov       bh,0
         add       ax,bx                    ; pýiŸten¡ pozice
         shl       ax,1                     ; offset v tabulce pole
         xchg      ax,bx                    ; BX <- offset v poli
         mov       ax,ds:[bx+Pole]          ; naŸten¡ pýedmØtu

; ------ n vrat registr…

GetPred9:pop       bx
         ret

GetPred  ENDP

; -----------------------------------------------------------------------------
;        zapnut¡ rychl‚ho re§imu
; -----------------------------------------------------------------------------

KarRych  PROC      NEAR

         test      byte ptr ds:[Param],bit4 ; je pýeruçen¡ cyklu ?
         jnz       KarRych9                 ; je pýeruçen¡ cyklu
         cmp       word ptr ds:[BlokIf],0   ; je blokov n¡ pý¡kaz… IF ?
         jne       KarRych9                 ; je blokov n¡ pý¡kaz…
         or        byte ptr ds:[Param],bit0 ; zapnut¡ TURBO
KarRych9:ret

KarRych  ENDP

; -----------------------------------------------------------------------------
;        zapnut¡ pomal‚ho re§imu
; -----------------------------------------------------------------------------

KarPom   PROC      NEAR

         test      byte ptr ds:[Param],bit4 ; je pýeruçen¡ cyklu ?
         jnz       KarPom9                  ; je pýeruçen¡ cyklu
         cmp       word ptr ds:[BlokIf],0   ; je blokov n¡ pý¡kaz… IF ?
         jne       KarPom9                  ; je blokov n¡ pý¡kaz…
         and       byte ptr ds:[Param],not bit0 ; vypnut¡ TURBO
KarPom9: ret

KarPom   ENDP

; -----------------------------------------------------------------------------
;        vymaz n¡ Karla na star‚ pozici
; -----------------------------------------------------------------------------

MazKar   PROC      NEAR

         push      dx

         test      byte ptr ds:[Param],bit3 ; je Karel zobrazen ?
         jz        MazKar6                  ; Karel nen¡ zobrazen
         mov       dx,ds:[KarelOPz]         ; star  pozice Karla
         call      PoleIcon                 ; zobrazen¡ pýedmØtu na star‚ pozici

MazKar6: pop       dx
         ret

MazKar   ENDP

; -----------------------------------------------------------------------------
;        podm¡nØn‚ zobrazen¡ Karla na aktu ln¡ pozici (s pý¡padnìm vymaz n¡m)
; -----------------------------------------------------------------------------

DispKar  PROC      NEAR

; ------ £schova registr…

         push      dx
         push      es

; ------ kontrola, zda je potýeba Karla vymazat na star‚ pozici

         test      byte ptr ds:[Param],bit3 ; je Karel zobrazen ?
         jz        DispKar3                 ; Karel nen¡ zobrazen
         mov       dx,ds:[KarelOPz]         ; star  pozice Karla
         cmp       dx,ds:[KarelPoz]         ; byla pozice zmØnØna ?
         jne       DispKar2                 ; pozice byla zmØnØna

; ------ kontrola, zda je potýeba Karla pýekreslovat

         mov       dl,ds:[KarelSme]         ; smØr Karla
         cmp       dl,ds:[KarelOSm]         ; je zmØnØn smØr ?
         je        DispKar8                 ; nen¡ potýeba pýekreslen¡

; ------ vymaz n¡ Karla na star‚ pozici

DispKar2:call      MazKar                   ; vymaz n¡ Karla na star‚ pozici

; ------ zobrazen¡ Karla

DispKar3:mov       dh,0
         mov       dl,ds:[KarelSme]         ; smØr Karla
         mov       ds:[KarelOSm],dl         ; £schova smØru Karla

; ------ smØr dol…

         or        dx,dx                    ; 0 = dol…
         jnz       DispKar4
         mov       es,ds:[ICOKarP]          ; pohle zepýedu

; ------ smØr vpravo

DispKar4:dec       dx                       ; 1 = vpravo
         jnz       DispKar5                 ; nen¡ vpravo
         mov       es,ds:[ICOKarR]          ; pohled zprava

; ------ smØr nahoru

DispKar5:dec       dx                       ; 2 = nahoru
         jnz       DispKar6
         mov       es,ds:[ICOKarZ]          ; pohled zezadu

; ------ smØr vlevo

DispKar6:dec       dx                       ; 3 = vlevo
         jnz       DispKar7
         mov       es,ds:[ICOKarL]          ; pohled vlevo

; ------ £schova aktu ln¡ho stavu

DispKar7:or        byte ptr ds:[Param],bit3 ; pý¡znak zobrazen¡ Karla
         mov       dx,ds:[KarelPoz]         ; aktu ln¡ pozice
         mov       ds:[KarelOPz],dx         ; £schova zobrazen‚ pozice

; ------ zobrazen¡ Karla na nov‚ pozici

         shl       dx,1
         shl       dx,1
         add       dx,101h
         call      MaskIcon

; ------ n vrat registr…

DispKar8:pop       es
         pop       dx
         ret

DispKar  ENDP

; *****************************************************************************
;
;                              Obsluha programu
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        proveden¡ programu
; -----------------------------------------------------------------------------

ExecPrg  PROC      NEAR

         and       byte ptr ds:[Param],not bit4 ; nen¡ pýeruçen¡ cyklu
         mov       word ptr ds:[BlokIf],0   ; odblokov n¡ pý¡kaz…

; ------ pý¡prava minim ln¡ho povolen‚ho SP

         mov       cl,4
         mov       ax,ds:[DataNum]          ; poŸet bajt… v bufferu programu
         add       ax,0fh                   ; zarovn n¡ na odstavec
         shr       ax,cl                    ; pýevod na odstavce
         add       ax,ds:[DataProg]         ; zaŸ tek voln‚ho bloku (segment)
         mov       bx,ds:[DataICO]          ; buffer ikon
         sub       bx,ax                    ; voln‚ m¡sto v bufferu
         jc        ExecPrg9                 ; pýeteŸen¡ pamØti
         cmp       bx,0e80h                 ; je v¡ce voln‚ pamØti ?
         jb        ExecPrg2                 ; nen¡ v¡ce pamØti
         mov       bx,0e80h                 ; omezen¡ velikosti pamØti
ExecPrg2:shl       bx,cl                    ; pýevod na bajty
         mov       ax,0f200h                ; to se nastav¡ pro SP + rezerva
         sub       ax,bx                    ; minim ln¡ nutn  adresa
         mov       ds:[MinSP],ax            ; minim ln¡ povolen  adresa SP
         cmp       ax,0ef00h                ; je dost voln‚ pamØti ?
         ja        ExecPrg9                 ; je m lo voln‚ pamØti

; ------ £schova ukazatele z sobn¡ku

         mov       ds:[RegSS],ss            ; £schova ukazatele SS
         mov       ds:[RegSP],sp            ; £schova ukazatele SP

; ------ pýedefinov n¡ ukazatele z sobn¡ku

         cli
         mov       ax,ds:[DataICO]          ; buffer ikon
         sub       ax,0f10h                 ; buffer pro SS
         mov       ss,ax                    ; buffer z sobn¡ku
         mov       sp,0f000h                ; ukazatel z sobn¡ku
         sti

; ------ prov dØn¡ pý¡kaz…

         mov       ax,ds:[MainProg]         ; offset hlavn¡ho programu
         mov       word ptr ds:[UkazProg],ax ; nulov n¡ ukazatele programu

ExecPrg6:call      ExePrik                  ; proveden¡ jednoho pý¡kazu
         jnc       ExecPrg6                 ; dalç¡ pý¡kaz

; ------ n vrat ukazatele z sobn¡ku

         cli
         mov       ss,ds:[RegSS]            ; n vrat registru SS
         mov       sp,ds:[RegSP]            ; n vrat registru SP
         sti
ExecPrg9:ret

ExecPrg  ENDP

RegSS    dw        0                        ; £schova registru SS
RegSP    dw        0                        ; £schova registru SP
MinSP    dw        0                        ; minim ln¡ povolenì SP

; -----------------------------------------------------------------------------
;        lev  z vorka
; -----------------------------------------------------------------------------

KarLZav  PROC      NEAR

KarLZav2:call      BytePrg                  ; naŸten¡ dalç¡ho bajtu
         jc        KarLZav8                 ; nen¡ dalç¡ bajt
         cmp       al,KOD_RZAV              ; je prav  z vorka ?
         je        KarLZav8                 ; je prav  z vorka - konec
         dec       word ptr ds:[UkazProg]   ; n vrat ukazatele programu
         call      ExePrik                  ; dalç¡ pý¡kaz
         jnc       KarLZav2                 ; dalç¡ pý¡kaz
KarLZav8:ret

KarLZav  ENDP

; -----------------------------------------------------------------------------
;        pr zdn  operace
; -----------------------------------------------------------------------------

KarNop   PROC      NEAR

         clc
         ret

KarNop   ENDP

; -----------------------------------------------------------------------------
;        proveden¡ jednoho pý¡kazu (CY=konec nebo chyba) (niŸ¡ AX a BX !)
; -----------------------------------------------------------------------------

ExePrik  PROC      NEAR

         cmp       sp,ds:[MinSP]            ; je pýeteŸen¡ z sobn¡ku ?
         jb        ExePrik2                 ; je pýeteŸen¡ z sobn¡ku

         call      BytePrg                  ; naŸten¡ jednoho bajtu
         jc        ExePrik2                 ; konec programu
         mov       ah,0
         shl       ax,1
         xchg      ax,bx                    ; BX <- offset v tabulce
         jmp       word ptr ds:[PrikazX+bx-2] ; skok na obsluhu pý¡kazu

ExePrik2:ret

ExePrik  ENDP

; -----------------------------------------------------------------------------
;        vyvol n¡ procedury
; -----------------------------------------------------------------------------

KarProc  PROC      NEAR

         call      WordPrg                  ; naŸten¡ parametru (slovo)
         jc        KarProc9                 ; chyba

         push      word ptr ds:[UkazProg]   ; £schova ukazatele programu

         mov       ds:[UkazProg],ax         ; novì ukazatel programu
         mov       al,ds:[Param]            ; parametry (pý¡znak TURBO)

         push      ax                       ; £schova pý¡znaku TURBO
         call      ExePrik                  ; proveden¡ jednoho pý¡kazu
         pop       ax                       ; n vrat pý¡znaku TURBO

         pop       word ptr ds:[UkazProg]   ; n vrat ukazatele programu

         jc        KarProc9                 ; pýeruçen¡ operace

         mov       ah,ds:[Param]            ; pý¡znak TURBO po operaci
         and       al,bit0                  ; pý¡znak TURBO pýed operac¡
         and       byte ptr ds:[Param],not bit0 ; nulov n¡ souŸasn‚ho pý¡znaku
         or        ds:[Param],al            ; navr cen¡ pý¡znaku TURBO

         test      ah,bit0                  ; mØla procedura TURBO zapnut‚ ?
         jz        KarProc9                 ; nemØla TURBO zapnut‚
         test      al,bit0                  ; navr til se bØ§nì re§im ?
         jnz       KarProc9                 ; navr til se re§im TURBO
         call      CekKrokD                 ; prodleva po operaci

KarProc9:ret

KarProc ENDP

; -----------------------------------------------------------------------------
;        opakov n¡ s poŸtem
; -----------------------------------------------------------------------------

KarOpak  PROC      NEAR

         call      WordPrg                  ; naŸten¡ parametru (slovo)
         jc        KarOpak9                 ; chyba
         test      byte ptr ds:[Param],bit4 ; je pýeruçen¡ cyklu ?
         jnz       KarOpak1                 ; je pýeruçen¡ cyklu
         cmp       word ptr ds:[BlokIf],0   ; je blokov n¡ pý¡kaz… IF ?
         jne       KarOpak1                 ; je blokov n¡ pý¡kaz…
         xchg      ax,cx                    ; CX <- Ÿ¡taŸ opakov n¡
         jmp       short KarOpak6           ; bude to bez posledn¡ho cyklu

KarOpak1:call      ExePrik                  ; pýeskoŸen¡ pý¡kazu pýi pýeruçen¡
         ret

; ------ prov dØn¡ pý¡kaz… uvnitý smyŸky (bez posledn¡ho pr…chodu)

KarOpak2:push      word ptr ds:[UkazProg]   ; £schova ukazatele programu
         push      cx
         call      ExePrik                  ; proveden¡ jednoho pý¡kazu
         pop       cx
         pop       word ptr ds:[UkazProg]   ; n vrat ukazatele programu
         jc        KarOpak8                 ; chyba nebo pýeruçen¡
         test      byte ptr ds:[Param],bit4 ; je pýeruçen¡ cyklu ?
         jnz       KarOpak7                 ; je pýeruçen¡ cyklu
KarOpak6:loop      KarOpak2                 ; dalç¡ cyklus

; ------ posledn¡ proveden¡ pý¡kazu

KarOpak7:call      ExePrik                  ; proveden¡ posledn¡ho pý¡kazu

; ------ ukonŸen¡ pýeruçen¡ cyklu (pýedt¡m nebyl pýeruçen)

KarOpak8:pushf
         and       byte ptr ds:[Param],not bit4 ; konec pýeruçen¡ cyklu
         popf
KarOpak9:ret

KarOpak  ENDP

; -----------------------------------------------------------------------------
;        podm¡nØn‚ opakov n¡
; -----------------------------------------------------------------------------

KarDok   PROC      NEAR

         test      byte ptr ds:[Param],bit4 ; je pýeruçen¡ cyklu ?
         jnz       KarDok1                  ; je pýeruçen¡ cyklu
         cmp       word ptr ds:[BlokIf],0   ; je blokov n¡ pý¡kaz… IF ?
         je        KarDok2                  ; nen¡ blokov n¡ pý¡kaz… IF
KarDok1: call      ExePrik                  ; pýeskoŸen¡ pý¡kazu pýi pýeruçen¡
         ret

; ------ prov dØn¡ pý¡kaz… uvnitý smyŸky (bez posledn¡ho pr…chodu)

KarDok2: push      word ptr ds:[UkazProg]   ; £schova ukazatele programu

         call      TestPodm                 ; test podm¡nky
         jnc       KarDok3                  ; podm¡nka splnØna OK
         or        byte ptr ds:[Param],bit4 ; pýeruçen¡ cyklu
KarDok3: call      ExePrik                  ; proveden¡ jednoho pý¡kazu

KarDok4: mov       ax,ds:[UkazProg]         ; dosa§enì ukazatel
         pop       word ptr ds:[UkazProg]   ; n vrat ukazatele programu
         jc        KarDok7                  ; chyba nebo pýeruçen¡
         test      byte ptr ds:[Param],bit4 ; je pýeruçen¡ cyklu ?
         jz        KarDok2                  ; nen¡ pýeruçen¡ - dalç¡ cyklus

; ------ ukonŸen¡ pýeruçen¡ cyklu (pýedt¡m nebyl pýeruçen)

KarDok7: mov       ds:[UkazProg],ax         ; novì dosa§enì ukazatel programu
         pushf
         and       byte ptr ds:[Param],not bit4 ; konec pýeruçen¡ cyklu
         popf
KarDok9: ret

KarDok  ENDP

; -----------------------------------------------------------------------------
;        pýeruçen¡ cyklu nebo programu
; -----------------------------------------------------------------------------

KarPrer  PROC      NEAR

         cmp       word ptr ds:[BlokIf],0   ; je blokov n¡ pý¡kaz… IF ?
         jne       KarPrer9                 ; je blokov n¡ pý¡kaz…
         or        byte ptr ds:[Param],bit4 ; pý¡znak pýeruçen¡ cyklu
KarPrer9:ret

KarPrer  ENDP

; -----------------------------------------------------------------------------
;        podm¡nka JESTLI
; -----------------------------------------------------------------------------

KarJest  PROC      NEAR

; ------ test splnØn¡ podm¡nky

         call      TestPodm                 ; test podm¡nky
         jc        KarJest4                 ; podm¡nka nesplnØna

; ------ proveden¡ pý¡kazu, je-li splnØna podm¡nka

KarJest2:call      ExePrik                  ; proveden¡ pý¡kazu bez blokov n¡
         jc        KarJest9                 ; pýeruçen¡ programu

; ------ test, zda n sleduje pý¡kaz JINAK

         call      BytePrg                  ; naŸten¡ dalç¡ho bajtu
         jc        KarJest8                 ; chyba
         cmp       al,KOD_JIN               ; je JINAK ?
         jne       KarJest7                 ; nen¡ JINAK

; ------ neproveden¡ pý¡kazu za JINAK

         inc       word ptr ds:[BlokIf]     ; blokov n¡ pý¡kazu
         call      ExePrik                  ; proveden¡ jednoho pý¡kazu
         dec       word ptr ds:[BlokIf]     ; odblokov n¡ pý¡kazu
         jmp       short KarJest9

; ------ neproveden¡ pý¡kazu, podm¡nka nen¡ splnØna

KarJest4:inc       word ptr ds:[BlokIf]     ; blokov n¡ pý¡kazu
         call      ExePrik                  ; proveden¡ jednoho pý¡kazu
         dec       word ptr ds:[BlokIf]     ; odblokov n¡ pý¡kazu
         jc        KarJest9                 ; pýeruçen¡ programu

; ------ test, zda n sleduje pý¡kaz JINAK

KarJest5:call      BytePrg                  ; naŸten¡ dalç¡ho bajtu
         jc        KarJest8                 ; chyba
         cmp       al,KOD_JIN               ; je JINAK ?
         jne       KarJest7                 ; nen¡ JINAK

; ------ proveden¡ pý¡kazu za JINAK

         call      ExePrik                  ; proveden¡ pý¡kazu bez blokov n¡
         jmp       short KarJest9

KarJest7:dec       word ptr ds:[UkazProg]   ; n vrat bajtu
KarJest8:clc                                ; pý¡znak operace OK
KarJest9:ret

KarJest  ENDP

BlokIf   dw        0                        ; Ÿ¡taŸ blokov n¡ IF (0=nen¡ blok)

; -----------------------------------------------------------------------------
;        test podm¡nky -> CY=nen¡ podm¡nka splnØna
; -----------------------------------------------------------------------------

TestPodm PROC      NEAR

; ------ £schova registr…

         push      ax
         push      cx

; ------ kontrola ukazatele z sobn¡ku

         cmp       sp,ds:[MinSP]            ; je pýeteŸen¡ z sobn¡ku ?
         jb        TestPod9                 ; je pýeteŸen¡ z sobn¡ku

; ------ naŸten¡ identifikaŸn¡ho bajtu

         call      BytePrg                  ; naŸten¡ bajtu
         jc        TestPod9                 ; chyba

; ------ negace podm¡nky

         cmp       al,KOD_NENI              ; je negace podm¡nky ?
         jne       TestPod0                 ; nen¡ negace podm¡nky
         call      TestPodm                 ; test dalç¡ podm¡nky
         cmc                                ; negace vìsledku
         jmp       short TestPod9

; ------ test pýedmØtu

TestPod0:cmp       al,KOD_OBR               ; je obr zek ?
         jne       TestPod1                 ; nen¡ obr zek
         call      WordPrg                  ; naŸten¡ adresy ikony
         jc        TestPod9                 ; chyba
         xchg      ax,cx                    ; CX <- £schova pýedmØtu
         call      GetPred                  ; naŸten¡ pýedmØtu
         cmp       ax,cx                    ; souhlas¡ pýedmØt ?
         je        TestPod9                 ; pýedmØt souhlas¡ OK
         or        ax,ax                    ; je r m ?
         jnz       TestPod8                 ; nen¡ r m
         cmp       cx,ds:[ICOZed]           ; je test zdi ?
         je        TestPod9                 ; je zeÔ
         cmp       cx,ds:[ICORam]           ; je test r mu ?
         je        TestPod9                 ; je r m
         jmp       short TestPod8           ; podm¡nka nesplnØna

; ------ test smØru

TestPod1:mov       ah,2                     ; k¢d pro SEVER
         cmp       al,KOD_SEV               ; SEVER
         je        TestPod2
         mov       ah,0                     ; k¢d pro JIH
         cmp       al,KOD_JIH               ; JIH
         je        TestPod2
         mov       ah,1                     ; k¢d pro VíCHOD
         cmp       al,KOD_VYCH              ; VíCHOD
         je        TestPod2
         mov       ah,3                     ; k¢d pro ZµPAD
         cmp       al,KOD_ZAP               ; ZµPAD
         jne       TestPod3
TestPod2:cmp       al,ds:[KarelSme]         ; kontrola smØru Karla
         je        TestPod9                 ; podm¡nka splnØna
         jmp       short TestPod8

; ------ ignorov n¡ pý¡kazu s argumentem

TestPod3:cmp       al,KOD_OPAK              ; opakov n¡
         je        TestPod6                 ; ignorov n¡ poŸtu opakov n¡
         cmp       al,KOD_PROC              ; procedura
         je        TestPod6                 ; ignorov n¡ procedury
         cmp       al,KOD_POZ               ; pozice
         jne       TestPod8
TestPod6:call      WordPrg                  ; naŸten¡ slovn¡ho parametru

; ------ n vrat registr…

TestPod8:stc                                ; pý¡znak nesplnØn¡ podm¡nky
TestPod9:pop       cx
         pop       ax
         ret

TestPodm ENDP

; -----------------------------------------------------------------------------
;        naŸten¡ slova programu -> AX, CY=nen¡
; -----------------------------------------------------------------------------

WordPrg  PROC      NEAR

         call      BytePrg                  ; naŸten¡ prvn¡ho bajtu
         jc        WordPrg2                 ; nen¡ dalç¡ bajt
         xchg      al,ah                    ; AH <- ni§ç¡ bajt
         call      BytePrg                  ; naŸten¡ druh‚ho bajtu
         xchg      al,ah
WordPrg2:ret

WordPrg  ENDP

; -----------------------------------------------------------------------------
;        naŸten¡ jednoho bajtu programu -> AL, CY=nen¡
; -----------------------------------------------------------------------------

BytePrg  PROC      NEAR

         push      si
         push      es

         mov       es,ds:[DataProg]         ; segment adresy programu
         mov       si,ds:[UkazProg]         ; ukazatel pro Ÿten¡ programu
         cmp       si,ds:[DataNum]          ; je konec programu ?
         cmc                                ; CY = nen¡ dalç¡ bajt
         jc        BytePrg2                 ; nen¡ dalç¡ bajt
         cld
         lods      byte ptr es:[si]         ; naŸten¡ dalç¡ho bajtu
         mov       ds:[UkazProg],si         ; novì ukazatel programu

BytePrg2:pop       es
         pop       si
         ret

BytePrg  ENDP

; -----------------------------------------------------------------------------
;        naŸten¡ programu (-> CY=chyba pamØti)
; -----------------------------------------------------------------------------
;þ
ReadPrg  PROC      NEAR

         mov       word ptr ds:[CitRad],1   ; ukazatel Ÿ¡sla ý dku

; ------ otevýen¡ vstupn¡ho souboru

         mov       dx,offset ProgFile       ; vstupn¡ soubor
         mov       ax,3d00h
         int       21h
         jnc       ReadPrg1

; ------ chyba - vstupn¡ soubor nenalezen

         mov       bp,offset FndErr
         call      DispErr                  ; obsluha chyby
         clc
         ret

; ------ ulo§en¡ identifik toru souboru

ReadPrg1:mov       ds:[ProgIdnt],ax         ; identifik tor vstupn¡ho souboru

; ------ definice procedur

ReadPrg3:mov       ax,ds:[DataNum]          ; konec programu
         mov       ds:[MainProg],ax         ; startovac¡ adresa
         call      ReadStr                  ; naŸten¡ ýetØzce
         jnc       ReadPr30
         jmp       ReadPrg8                 ; konec souboru

ReadPr30:cmp       byte ptr ds:[ProgStr+1],"!" ; je definice procedury ?
         jne       ReadPrg6                 ; nen¡ definice procedury

; ------ naŸten¡ jm‚na procedury

         call      ReadStr                  ; naŸten¡ dalç¡ho ýetØzce
         jc        ReadPrg8                 ; konec souboru

; ------ rezerva m¡sta pro adresu dalç¡ procedury

         push      word ptr ds:[DataNum]    ; £schova ukazatele

         xor       ax,ax
         call      StorPrg                  ; rezerva m¡sta pro adresu
         jc        ReadPr38                 ; chyba pamØti
         call      StorPrg
         jc        ReadPr38                 ; chyba pamØti

; ------ ulo§en¡ jm‚na procedury

         mov       ch,0
         mov       cl,ds:[ProgStr]          ; d‚lka jm‚na procedury
         inc       cx                       ; vŸetnØ d‚lky
         mov       si,offset ProgStr        ; jm‚no procedury s d‚lkou
ReadPr31:cld
         lodsb                              ; naŸten¡ bajtu
         call      UpCase                   ; konverze na velk‚ p¡smeno
         call      StorPrg                  ; ulo§en¡ bajtu
         jc        ReadPr38                 ; chyba pamØti
         loop      ReadPr31                 ; dalç¡ bajt

         inc       word ptr ds:[ProcNum]    ; Ÿ¡taŸ procedur

; ------ naŸten¡ a zpracov n¡ dalç¡ho pý¡kazu

         xor       cx,cx                    ; ukazatel hladiny z vorek
ReadPr33:call      ReadStr                  ; naŸten¡ dalç¡ho ýetØzce
         jc        ReadPr37                 ; konec souboru
         cmp       byte ptr ds:[ProgStr+1],"!"
         je        ReadPr33                 ; definice procedur se ignoruje
         push      cx
         call      ReadPrik                 ; zpracov n¡ pý¡kazu
         pop       cx
         jc        ReadPr38                 ; chyba pamØti

; ------ test, zda je lev  z vorka

         cmp       byte ptr ds:[ProgStr+1],"(" ; je lev  z vorka ?
         jne       ReadPr34                 ; nen¡ lev  z vorka
         inc       cx                       ; zvìçen¡ ukazatele z vorek

; ------ test, zda je prav  z vorka

ReadPr34:cmp       byte ptr ds:[ProgStr+1],")" ; je prav  z vorka ?
         jne       ReadPr35                 ; nen¡ prav  z vorka
         jcxz      ReadPr37                 ; je ji§ nulov  hladina
         dec       cx                       ; sn¡§en¡ Ÿ¡taŸe z vorek

; ------ test, zda je konec pý¡kazu

ReadPr35:or        cx,cx                    ; je nulov  hladina z vorek ?
         jnz       ReadPr33                 ; dalç¡ pý¡kaz

; ------ ulo§en¡ adresy dalç¡ procedury

ReadPr37:clc                                ; pý¡znak operace OK

ReadPr38:pop       di                       ; DI <- ukazatel v bufferu

         push      es
         mov       es,ds:[DataProg]         ; segment adresy bufferu
         mov       ax,ds:[DataNum]          ; novì ukazatel
         cld
         stosw                              ; ulo§en¡ adresy dalç¡ procedury
         pop       es

         jc        ReadPrg9                 ; pýeteŸen¡ pamØti

         jmp       short ReadPrg3           ; dalç¡ procedura

; ------ naŸten¡ ýetØzce ze souboru

ReadPrg4:call      ReadStr                  ; naŸten¡ ýetØzce
         jc        ReadPrg8                 ; konec souboru

; ------ chyba, je-li definice procedury

         cmp       byte ptr ds:[ProgStr+1],"!" ; je definice procedury ?
         jne       ReadPrg6                 ; nen¡ definice procedury
         call      DispErr                  ; chybov‚ hl çen¡
         jmp       short ReadPrg4           ; dalç¡ pý¡kaz

; ------ zpracov n¡ jednoho pý¡kazu

ReadPrg6:call      ReadPrik                 ; zpracov n¡ jednoho pý¡kazu
         jc        ReadPrg9                 ; pýeteŸen¡ pamØti
         jmp       short ReadPrg4           ; dalç¡ pý¡kaz

; ------ uzavýen¡ vstupn¡ho souboru (CY=chyba pamØti)

ReadPrg8:clc                                ; NC = pý¡znak operace OK
ReadPrg9:pushf
         mov       bx,ds:[ProgIdnt]
         mov       ah,3eh
         int       21h                      ; uzavýen¡ vstupn¡ho souboru
         popf
         ret

ReadPrg  ENDP

; -----------------------------------------------------------------------------
;  zpracov n¡ jednoho pý¡kazu programu, ýetØzec je v bufferu -> CY=chyba pamØti
; -----------------------------------------------------------------------------

ReadPrik PROC      NEAR

; ------ nalezen¡ ýetØzce v intern¡ch pý¡kazech

         mov       si,offset ProgStr        ; naŸten¡ ýetØzec
         call      HledStr                  ; nalezen¡ ýetØzce v tabulce
         jc        ReadPri3                 ; ýetØzec nenalezen

; ------ ulo§en¡ intern¡ho pý¡kazu do bufferu programu

         call      StorPrg                  ; ulo§en¡ intern¡ho pý¡kazu
         jc        ReadPri9                 ; pýeteŸen¡ pamØti

; ------ naŸten¡ parametru pro nastaven¡ pozice

         cmp       al,KOD_POZ               ; je nastaven¡ pozice ?
         jne       ReadPri2                 ; nen¡ nastaven¡ pozice
         call      ReadPNm                  ; naŸten¡ Ÿ¡sla - pozice
         mov       cl,al                    ; £schova pozice
         call      ReadPNm                  ; naŸten¡ Ÿ¡sla - ý dek
         mov       ah,al                    ; ý dek
         mov       al,cl                    ; pozice
         jmp       short ReadPri4           ; ulo§en¡ Ÿ¡sla

; ------ naŸten¡ parametru pro opakov n¡

ReadPri2:cmp       al,KOD_OPAK              ; je opakov n¡ ?
         jne       ReadPri8                 ; nen¡ opakov n¡
         call      ReadPNm                  ; naŸten¡ Ÿ¡sla
         jmp       short ReadPri4           ; ulo§en¡ Ÿ¡sla

; ------ nalezen¡ obr zku k vykreslen¡

ReadPri3:call      SrcICO                   ; nalezen¡ obr zku
         jc        ReadPri5                 ; obr zek nenalezen

; ------ ulo§en¡ pý¡kazu pro vykreslen¡ obr zku

         mov       al,KOD_OBR               ; pý¡kaz pro vykreslen¡ obr zku
         call      StorPrg                  ; ulo§en¡ intern¡ho pý¡kazu
         jc        ReadPri9                 ; pýeteŸen¡ pamØti
         mov       ax,es                    ; AX <- adresa obr zku

; ------ ulo§en¡ slova AX jako parametr

ReadPri4:call      StorPrg                  ; ulo§en¡ intern¡ho pý¡kazu
         jc        ReadPri9                 ; pýeteŸen¡ pamØti
         xchg      al,ah                    ; AL <- adresa obr zku HIGH
         call      StorPrg                  ; ulo§en¡ intern¡ho pý¡kazu
         jmp       short ReadPri9           ; konec nebo chyba pamØti

; ------ nalezen¡ procedury

ReadPri5:call      SrcPrik                  ; nalezen¡ pý¡kazu
         jc        ReadPri6                 ; nenalezen

; ------ ulo§en¡ identifik toru pý¡kazu

         push      ax
         mov       al,KOD_PROC
         call      StorPrg                  ; ulo§en¡ pý¡kazu
         pop       ax
         jc        ReadPri9                 ; chyba pamØti
         jmp       short ReadPri4           ; ulo§en¡ adresy

; ------ chyba - nezn mì povel

ReadPri6:mov       si,offset ProgStr+1      ; pý¡kaz
         mov       cl,ds:[si-1]             ; d‚lka pý¡kazu
         mov       ch,0
         push      ds
         pop       es
         mov       di,offset NeznErr2
         mov       ax,30
         cmp       cx,ax
         jb        ReadPri7
         mov       cx,ax
ReadPri7:cld
         sub       ax,cx
         rep       movsb
         xchg      ax,cx
         mov       al," "
         rep       stosb

         mov       bp,offset NeznErr        ; chyba - nezn mì pý¡kaz
         call      DispErr                  ; chybov‚ hl çen¡

ReadPri8:clc                                ; pý¡znak operace OK
ReadPri9:ret

ReadPrik ENDP

; -----------------------------------------------------------------------------
;        vyhled n¡ pý¡kazu DS:SI -> AX=adresa
; -----------------------------------------------------------------------------

SrcPrik  PROC      NEAR

; ------ £schova registr…

         push      bx
         push      cx
         push      di
         push      es

; ------ pý¡prava registr…

         xor       di,di                    ; poŸ tek procedur
         mov       es,ds:[DataProg]         ; segment programu
         mov       bx,ds:[ProcNum]          ; poŸet procedur
         mov       ch,0

; ------ test, zda je dalç¡ procedura

SrcPrik2:or        bx,bx                    ; je dalç¡ procedura ?
         stc                                ; pý¡znak nenalezen¡
         jz        SrcPrik8                 ; nenalezeno

; ------ porovn n¡ jm‚na procedury

         push      si
         push      di
         inc       di
         inc       di                       ; zaŸ tek jm‚na
         mov       cl,es:[di]               ; d‚lka jm‚na procedury
         inc       cx                       ; vŸetnØ bajtu d‚lky
         repe      cmpsb                    ; porovn n¡ jm‚na
         pop       di
         pop       si
         je        SrcPrik6                 ; procedura nalezena OK

; ------ dalç¡ procedura

         mov       di,es:[di]               ; adresa dalç¡ procedury
         dec       bx                       ; Ÿ¡taŸ procedur
         jmp       short SrcPrik2           ; dalç¡ hled n¡

; ------ adresa procedury -> AX

SrcPrik6:mov       ax,di
         add       al,es:[di+2]             ; pýiŸten¡ d‚lky jm‚na
         adc       ah,0
         add       ax,3                     ; pýeskoŸen¡ offsetu a bajtu d‚lky
         clc                                ; pý¡znak operace OK

; ------ n vrat registr…

SrcPrik8:pop       es
         pop       di
         pop       cx
         pop       bx
         ret

SrcPrik  ENDP

; -----------------------------------------------------------------------------
;        ulo§en¡ bajtu AL do bufferu programu -> CY=chyba pamØti
; -----------------------------------------------------------------------------

StorPrg  PROC      NEAR

; ------ £schova registr…

         push      di
         push      es

; ------ ulo§en¡ bajtu do bufferu

         mov       es,ds:[DataProg]         ; segment adresy bufferu
         mov       di,ds:[DataNum]          ; poŸet bajt… v bufferu
         cld
         stosb                              ; ulo§en¡ bajtu do bufferu
         mov       ds:[DataNum],di          ; novì poŸet bajt… v bufferu

; ------ kontrola pýeteŸen¡ pamØti

         add       di,18h                   ; zarovn n¡ na odstavec + rezerva
         jc        StorPrg9                 ; mohlo by bìt pýeteŸen¡
         shr       di,1
         shr       di,1
         shr       di,1
         shr       di,1                     ; pýevod na odstavce
         add       di,ds:[DataProg]         ; adresa konce programu
         cmp       di,ds:[DataICO]          ; je pýeteŸen¡ pamØti ?
         cmc                                ; CY = je pýeteŸen¡ pamØti

; ------ n vrat registr…

StorPrg9:pop       es
         pop       di
         ret

StorPrg  ENDP

; -----------------------------------------------------------------------------
;        nalezen¡ ýetØzce DS:SI v tabulce pý¡kaz… -> AX=Ÿ¡slo pý¡kazu, CY=nen¡
; -----------------------------------------------------------------------------

HledStr  PROC      NEAR

; ------ £schova pý¡kaz…

         push      di
         push      cx
         push      es

; ------ pý¡prava k vyhled n¡ ýetØzce

         cld
         push      ds
         pop       es                       ; ES <- datovì segment
         mov       di,offset Prikazy        ; tabulka intern¡ch pý¡kaz…
         mov       ch,0
HledStr1:xor       ax,ax                    ; ukazatel Ÿ¡sla pý¡kazu

; ------ kontrola jednoho ýetØzce

HledStr2:inc       ax                       ; zvìçen¡ ukazatele Ÿ¡sla pý¡kazu
         mov       cl,ds:[di]               ; d‚lka porovn van‚ho ýetØzce
         inc       cx                       ; vŸetnØ bajtu d‚lky
         push      si
         push      di
         push      cx
         repe      cmpsb                    ; porovn n¡ ýetØzce (i s d‚lkou)
         pop       cx
         pop       di
         pop       si
         je        HledStr8                 ; ýetØzez nalezen OK

; ------ dalç¡ ýetØzec -> CY=nenalezen

HledStr4:add       di,cx                    ; dalç¡ ýetØzec
         cmp       byte ptr ds:[di],0       ; je dalç¡ ýetØzec ?
         jne       HledStr2                 ; je dalç¡ ýetØzec OK

; ------ hled n¡ v tabulce zkratek

         cmp       di,offset Prikazy0       ; je prvn¡ tabulka ?
         mov       di,offset Prikazy2       ; tabulka zkratek
         je        HledStr1                 ; prohled n¡ tabulky zkratek
         stc                                ; pý¡znak nenalezen¡ ýetØzce

; ------ n vrat pý¡kaz…

HledStr8:pop       es
         pop       cx
         pop       di
         ret

HledStr  ENDP

; -----------------------------------------------------------------------------
;        naŸten¡ Ÿ¡sla ze souboru -> AX
; -----------------------------------------------------------------------------

ReadPNm  PROC      NEAR

; ------ £schova registr…

         push      bx
         push      dx

; ------ vypuçtØn¡ mezer pýed ýetØzcem

         xor       bx,bx                    ; stýadaŸ
         call      ReadSpc                  ; vypuçtØn¡ mezer
         jc        ReadPNm9                 ; konec souboru

; ------ naŸten¡ Ÿ¡slice

ReadPNm2:call      ReadChr                  ; naŸten¡ znaku
         jc        ReadPNm9                 ; nen¡ dalç¡ znak
         cmp       al,"0"
         jb        ReadPNm8                 ; nen¡ to Ÿ¡slice
         cmp       al,"9"
         ja        ReadPNm8                 ; nen¡ to Ÿ¡slice

; ------ pýid n¡ Ÿ¡slice ke stýadaŸi

         sub       al,"0"
         mov       ah,0
         xchg      ax,bx                    ; AX <- stýadaŸ
         mov       dx,10                    ; n sobitel
         mul       dx                       ; posun stýadaŸe o ý d
         add       bx,ax                    ; pýid n¡ Ÿ¡slice ke stýadaŸi
         adc       dx,dx                    ; je pýeteŸen¡ ?
         jz        ReadPNm2                 ; nen¡ pýeteŸen¡
         mov       bx,-1                    ; omezen¡ pýi pýeteŸen¡
         jmp       short ReadPNm2           ; dalç¡ Ÿ¡slice

; ------ n vrat registr…

ReadPNm8:call      ReadRet                  ; n vrat znaku AL do bufferu
ReadPNm9:xchg      ax,bx                    ; AX <- naŸten‚ Ÿ¡slo
         pop       dx
         pop       bx
         ret

ReadPNm  ENDP

; -----------------------------------------------------------------------------
;        naŸten¡ ýetØzce ze souboru -> CY=nen¡ dalç¡ ýetØzec
; -----------------------------------------------------------------------------

ReadStr  PROC      NEAR

; ------ £schova registr…

         push      ax
         push      di

; ------ pý¡prava ukazatel…

         mov       byte ptr ds:[ProgStr],0  ; nulov n¡ d‚lky ýetØzce programu
         mov       di,offset ProgStr+1      ; buffer ýetØzce programu

; ------ vypuçtØn¡ mezer pýed ýetØzcem

         call      ReadSpc                  ; vypuçtØn¡ mezer
         jc        ReadStr8                 ; konec souboru

; ------ jako prvn¡ znak m…§e bìt jakìkoliv znak (mezera je ji§ vypuçtØna)

         call      ReadChr                  ; naŸten¡ znaku
         call      UpCase                   ; konverze na velk‚ p¡smeno
         mov       ds:[di],al               ; ulo§en¡ prvn¡ho znaku do bufferu
         inc       di                       ; zvìçen¡ ukazatele v bufferu
         inc       byte ptr ds:[ProgStr]    ; zvìçen¡ Ÿ¡taŸe d‚lky ýetØzce

; ------ test prvn¡ho znaku, zda m…§e ýetØzec pokraŸovat

         cmp       al,"_"
         je        ReadStr2                 ; je podtr§¡tko - m…§e pokraŸovat
         cmp       al,"0"
         jb        ReadStr1                 ; nen¡ Ÿ¡slice
         cmp       al,"9"
         jbe       ReadStr2                 ; je Ÿ¡slice - m…§e pokraŸovat
ReadStr1:cmp       al,"A"
         jb        ReadStr6                 ; nen¡ p¡smeno - konec
         cmp       al,"Z"
         ja        ReadStr6                 ; nen¡ p¡smeno - konec

; ------ naŸten¡ dalç¡ho znaku

ReadStr2:call      ReadChr                  ; naŸten¡ dalç¡ho znaku
         jc        ReadStr6                 ; konec souboru
         call      UpCase                   ; konverze na velk‚ p¡smeno

; ------ test, zda je znak povolenì

         cmp       al,"_"
         je        ReadStr4                 ; je podtr§¡tko - m…§e pokraŸovat
         cmp       al,"0"
         jb        ReadStr3                 ; nen¡ Ÿ¡slice
         cmp       al,"9"
         jbe       ReadStr4                 ; je Ÿ¡slice - m…§e pokraŸovat
ReadStr3:cmp       al,"A"
         jb        ReadStr5                 ; nen¡ p¡smeno - konec
         cmp       al,"Z"
         ja        ReadStr5                 ; nen¡ p¡smeno - konec

; ------ ulo§en¡ znaku do bufferu

ReadStr4:cmp       byte ptr ds:[ProgStr],255 ; je buffer plnì ?
         jae       ReadStr2                 ; buffer je plnì
         mov       ds:[di],al               ; ulo§en¡ znaku do bufferu
         inc       di                       ; zvìçen¡ ukazatele v bufferu
         inc       byte ptr ds:[ProgStr]    ; zvìçen¡ Ÿ¡taŸe d‚lky ýetØzce
         jmp       short ReadStr2           ; naŸten¡ dalç¡ho znaku

; ------ navr cen¡ neplatn‚ho znaku

ReadStr5:call      ReadRet                  ; navr cen¡ oddØlovaŸe zpØt
ReadStr6:clc                                ; pý¡znak operace OK

; ------ navr cen¡ registr…

ReadStr8:pop       di
         pop       ax
         ret

ReadStr  ENDP

; -----------------------------------------------------------------------------
;        vypuçtØn¡ mezer ze souboru -> CY=je konec souboru
; -----------------------------------------------------------------------------

ReadSpc  PROC      NEAR

         push      ax
ReadSpc1:call      ReadChr                  ; naŸten¡ znaku ze souboru
         jc        ReadSpc8                 ; konec souboru
         cmp       al," "                   ; je oddØlovaŸ ?
         jbe       ReadSpc1                 ; oddØlovaŸ se vypust¡
         call      ReadRet                  ; navr cen¡ znaku do bufferu
ReadSpc8:pop       ax
         ret

ReadSpc  ENDP

; -----------------------------------------------------------------------------
;        navr cen¡ znaku AL do bufferu -> NC
; -----------------------------------------------------------------------------

ReadRet  PROC      NEAR

         mov       ds:[InpRetB],al          ; navr cen¡ znaku do bufferu
         cmp       al,10                    ; je LF ?
         jne       ReadRet2                 ; nen¡ LF
         dec       word ptr ds:[CitRad]     ; sn¡§en¡ ukazatele Ÿ¡sla ý dku
ReadRet2:clc
         ret

ReadRet  ENDP

; -----------------------------------------------------------------------------
;        naŸten¡ znaku ze vstupn¡ho souboru -> AL, CY=konec souboru
; -----------------------------------------------------------------------------

ReadChr  PROC      NEAR

; ------ £schova registr…

         push      si

; ------ test, zda je znak v navracec¡m bufferu

         mov       al,0                     ; nulovac¡ bajt
         xchg      al,ds:[InpRetB]          ; znak z navracec¡ho bufferu
         or        al,al                    ; byl v bufferu znak ?
         jnz       ReadChr4                 ; v bufferu byl znak

; ------ test, zda je v bufferu pýipraven dalç¡ znak

         mov       si,ds:[InpRead]          ; Ÿtec¡ offset z bufferu
         cmp       si,ds:[InpNum]           ; bude dalç¡ bajt ?
         jb        ReadChr3                 ; bude dalç¡ bajt

; ------ naŸten¡ bufferu ze souboru

         call      ReadBuff                 ; naŸten¡ bufferu ze souboru
         jc        ReadChr6                 ; konec souboru
         xor       si,si                    ; ukazatel na zaŸ tek bufferu

; ------ naŸten¡ znaku z bufferu

ReadChr3:mov       al,ds:[si+InpBuff]       ; naŸten¡ znaku z bufferu
         inc       word ptr ds:[InpRead]    ; zvìçen¡ ukazatele v bufferu

; ------ navr cen¡ registr…

ReadChr4:cmp       al,10                    ; je LF ?
         jne       ReadChr5                 ; nen¡ LF
         inc       word ptr ds:[CitRad]     ; zvìçen¡ ukazatele Ÿ¡sla ý dku
ReadChr5:clc                                ; pý¡znak operace OK

ReadChr6:pop       si
         ret

ReadChr  ENDP

; -----------------------------------------------------------------------------
;        naŸten¡ bufferu ze vstupn¡ho souboru -> CY=konec souboru
; -----------------------------------------------------------------------------

ReadBuff PROC      NEAR

; ------ £schova registr…

         push      ax
         push      bx
         push      cx
         push      dx

; ------ naŸten¡ bufferu

         mov       ah,3fh
         mov       bx,ds:[ProgIdnt]         ; identifik tor souboru
         mov       cx,BUFFSIZE              ; velikost bufferu
         mov       dx,offset InpBuff        ; vstupn¡ buffer
         int       21h                      ; naŸten¡ bufferu ze souboru

; ------ £schova poŸtu bajt…

         jnc       ReadBuf2                 ; operace byla OK
         xor       ax,ax                    ; pý¡znak, §e nebylo nic naŸteno
ReadBuf2:mov       ds:[InpNum],ax           ; poŸet bajt… v bufferu
         mov       word ptr ds:[InpRead],0  ; Ÿtec¡ offset v bufferu
         cmp       ax,1                     ; bylo nØco naŸteno ? (CY=nebylo)

; ------ n vrat registr…

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ReadBuff ENDP

; *****************************************************************************
;
;                                Obsluha ikon
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        naŸten¡ vçech ikon -> CY=chyba pamØti
; -----------------------------------------------------------------------------

ReadICO  PROC      NEAR

; ------ nastaven¡ adresy DTA

         mov       dx,offset DTA            ; buffer DTA
         mov       ah,1ah
         int       21h                      ; nastaven¡ adresy DTA

; ------ nalezen¡ souboru ikony

         mov       dx,offset ICOAll         ; specifikace - vçechny ICO
         mov       ah,4eh
         xor       cx,cx                    ; atributy
ReadICO1:int       21h                      ; nalezen¡ souboru
         jnc       ReadICO2                 ; nalezen dalç¡ soubor
         clc                                ; pý¡znak operace OK
ReadIC19:ret

; ------ otevýen¡ souboru ikony

ReadICO2:mov       dx,offset DTA+1eh        ; jm‚no souboru
         mov       ax,3d00h
         int       21h                      ; otevýen¡ souboru
         jnc       ReadIC22
         jmp       ReadICO8                 ; nØjak  chyba

ReadIC22:xchg      ax,bx                    ; BX <- identifik tor souboru

; ------ naŸten¡ souboru do pamØti

         mov       dx,offset SoubICO        ; buffer k naŸten¡ ikony
         mov       cx,offset(SoubICO2-SoubICO) ; d‚lka souboru
         mov       ah,3fh
         int       21h                      ; naŸten¡ souboru

; ------ uzavýen¡ souboru

         mov       ah,3eh
         int       21h                      ; uzavýen¡ souboru

; ------ korekce naŸten‚ ikony

         call      KorIcon                  ; korekce naŸten‚ ikony

; ------ adresa bufferu

         mov       ax,ds:[DataICO]          ; adresa poŸ tku ikon
         sub       ax,ICOSize/16            ; novì poŸ te ikon
         cmp       ax,ds:[DataProg]         ; je pýeteŸen¡ ?
         jb        ReadIC19                 ; pýeteŸen¡ pamØti
         mov       ds:[DataICO],ax          ; novì poŸ tek
         mov       es,ax                    ; ES <- adresa bufferu

; ------ vymaz n¡ bufferu

         xor       di,di
         mov       cx,ICOSize/2             ; velikost bufferu
         xor       ax,ax
         rep       stosw                    ; vymaz n¡ bufferu

; ------ konverze obr zku ikony

         cld
         xor       di,di                    ; ukl dac¡ adresa
         mov       si,offset IcoBuff+31*32/2 ; buffer dat ikony - posledn¡ linka
         mov       bx,32                    ; poŸet linek ke konverzi
         mov       ah,80h                   ; maska pro nastaven¡ bitu
ReadICO3:mov       cx,32/2                  ; poŸet bajt… na lince
ReadICO4:lodsb                              ; naŸten¡ jednoho bajtu

         shl       al,1                     ; test jednoho bitu
         jnc       ReadIC42                 ; nen¡ nastaven
         or        byte ptr es:[di+3*4*32],ah
ReadIC42:shl       al,1
         jnc       ReadIC43
         or        byte ptr es:[di+2*4*32],ah
ReadIC43:shl       al,1
         jnc       ReadIC44
         or        byte ptr es:[di+4*32],ah
ReadIC44:shl       al,1
         jnc       ReadIC45
         or        byte ptr es:[di],ah      ; nastaven¡ bitu
ReadIC45:ror       ah,1                     ; posun ukl dac¡ masky

         shl       al,1                     ; test jednoho bitu
         jnc       ReadIC46                 ; nen¡ nastaven
         or        byte ptr es:[di+3*4*32],ah
ReadIC46:shl       al,1
         jnc       ReadIC47
         or        byte ptr es:[di+2*4*32],ah
ReadIC47:shl       al,1
         jnc       ReadIC48
         or        byte ptr es:[di+4*32],ah
ReadIC48:shl       al,1
         jnc       ReadIC49
         or        byte ptr es:[di],ah      ; nastaven¡ bitu
ReadIC49:ror       ah,1
         cmp       ah,80h
         jne       ReadICO5
         inc       di                       ; zvìçen¡ ukl dac¡ adresy

ReadICO5:loop      ReadICO4                 ; dalç¡ bajt na lince
         sub       si,2*(32/2)              ; pýedeçl  linka

         dec       bx                       ; Ÿ¡taŸ linek k ulo§en¡
         jnz       ReadICO3                 ; dalç¡ linka

; ------ pýenesen¡ masky ikony

         add       di,3*4*32
         mov       si,offset IcoMask+31*32/8 ; maska ikony
         mov       cx,32                    ; poŸet linek
ReadIC52:lodsw
         not       ax
         stosw
         lodsw
         not       ax
         stosw
         sub       si,2*(32/8)
         loop      ReadIC52

; ------ ulo§en¡ jm‚na ikony

         cld
         mov       es,ds:[DataSegm]         ; adresa zaŸ tku bufferu
         mov       si,offset DTA+1eh        ; jm‚no souboru
         mov       di,ds:[DataICOE]         ; offset konce symbol… ikon
         mov       bx,di                    ; BX <- d‚lka jm‚na ikony
         mov       al,0                     ; d‚lka jm‚na ikony
         stosb                              ; d‚lka jm‚na ikony

         lodsb                              ; naŸten¡ prvn¡ho znaku
         jmp       short ReadIC66           ; kontrola, zda to je p¡smeno

ReadICO6:lodsb
         cmp       al,0                     ; je konec jm‚na ?
         je        ReadIC69                 ; konec jm‚na
         cmp       al,"."
         je        ReadIC69                 ; konec jm‚na
         cmp       al,"_"                   ; je to podtr§¡tko ?
         je        ReadIC68                 ; podtr§¡tko je povoleno
         cmp       al,"0"                   ; je to Ÿ¡slice ?
         jb        ReadIC66                 ; nen¡ to Ÿ¡slice
         cmp       al,"9"                   ; je to Ÿ¡slice ?
         jbe       ReadIC68                 ; je to Ÿ¡slice

ReadIC66:call      UpCase                   ; konverze na velk‚ p¡smeno
         cmp       al,"A"                   ; je to p¡smeno ?
         jb        ReadICO9                 ; nen¡ to p¡smeno - chyba
         cmp       al,"Z"                   ; je to p¡smeno ?
         ja        ReadICO9                 ; nen¡ to p¡smeno - chyba
ReadIC68:cmp       byte ptr es:[bx],8       ; je ji§ maxim ln¡ d‚lka jm‚na ?
         jae       ReadICO6                 ; je ji§ maxim ln¡ d‚lka jm‚na
         stosb                              ; ulo§en¡ p¡smene
         inc       byte ptr es:[bx]         ; Ÿ¡taŸ d‚lky jm‚na ikony
         jmp       short ReadICO6           ; dalç¡ znak

ReadIC69:mov       ax,ds:[DataICO]          ; adresa ikony
         stosw                              ; ulo§en¡ adresy ikony

; ------ nov  adresa konce symbol… (AX=adresa ikony)

         inc       word ptr ds:[DataICON]   ; zvìçen¡ Ÿ¡taŸe ikon

         mov       ds:[DataICOE],di         ; nov  adresa konce symbol…
         add       di,0fh                   ; zaokrouhlen¡ nahoru
         mov       cl,4
         shr       di,cl                    ; pýevod na odstavce
         add       di,ds:[DataSegm]
         mov       ds:[DataProg],di         ; nov  adresa programu
         cmp       ax,di                    ; je pýeteŸen¡ pamØti ?
         jae       ReadICO8                 ; je to v poý dku
         ret                                ; CY=chyba pýeteŸen¡ pamØti

; ------ chybn‚ jm‚no ikony

ReadICO9:push      ds
         pop       es                       ; ES <- datovì segment
         mov       di,offset ICOErr2        ; buffer jm‚na ikony
         cld
         mov       cx,13                    ; maxim ln¡ d‚lka jm‚na
         mov       si,offset DTA+1eh        ; jm‚no souboru
ReadIC92:lodsb
         stosb                              ; ulo§en¡ znaku
         cmp       al,0
         loopne    ReadIC92                 ; dalç¡
         dec       di                       ; n vrat na koncovou 0
         mov       al," "
         rep       stosb                    ; vymaz n¡ zbytku bufferu

         add       word ptr ds:[DataICO],ICOSize/16 ; n vrat adresy ikon
         mov       bp,offset ICOErr
         call      DispErr                  ; zobrazen¡ chyby

; ------ dalç¡ soubor ikony

ReadICO8:mov       ah,4fh                   ; bude dalç¡ soubor
         jmp       ReadICO1                 ; dalç¡ soubor

ReadICO  ENDP

; -----------------------------------------------------------------------------
;        inicializace implicitn¡ch ikon
; -----------------------------------------------------------------------------

IniICOD  PROC      NEAR

; ------ nalezen¡ implicitn¡ ikony

         mov       si,offset ICODef         ; implicitn¡ ikony
IniICOD2:call      SrcICO                   ; nalezen¡ ikony
         jnc       IniICOD6                 ; ikona nalezena OK

; ------ chyba - ikona nenalezena

         push      ds
         pop       es
         mov       di,offset ICODErr2
         cld

         push      si
         mov       cl,ds:[si]               ; d‚lka jm‚na ikony
         inc       si
         mov       ch,0
         rep       movsb                    ; pýenesen¡ jm‚na ikony
         pop       si

         mov       ax,"I."
         stosw
         mov       ax,"OC"
         stosw
         mov       cl,13-4
         sub       cl,ds:[si]               ; zbytek bufferu
         mov       al," "
         rep       stosb                    ; vymaz n¡ zbytku bufferu

         mov       bp,offset ICODErr
         call      DispErr                  ; zobrazen¡ chyby

; ------ ulo§en¡ adresy ikony

IniICOD6:cld
         lodsb                              ; d‚lka jm‚na ikony
         mov       ah,0
         add       si,ax                    ; pýeskoŸen¡ jm‚na
         mov       ds:[si],es               ; adresa ikony

; ------ dalç¡ ikona

         inc       si
         inc       si                       ; pýeskoŸen¡ adresy ikony
         cmp       si,offset ICODef0        ; je konec tabulky ?
         jb        IniICOD2                 ; bude dalç¡ ikona
         ret

IniICOD  ENDP

; -----------------------------------------------------------------------------
;        nalezen¡ ikony DS:SI -> ES (CY=nenalezeno)
; -----------------------------------------------------------------------------

SrcICO   PROC      NEAR

; ------ £schova registr…

         push      bx
         push      cx
         push      di

; ------ pý¡prava k prohled n¡ tabulky

         cld
         xor       di,di                    ; ukazatel v tabulce ikon
         mov       bx,ds:[DataICON]         ; poŸet ikon
         mov       es,ds:[DataSegm]         ; segment symbol… ikon
         xor       cx,cx                    ; CX <- 0

; ------ test, zda je dalç¡ ikona

SrcICO2: or        bx,bx                    ; je dalç¡ ikona ?
         stc                                ; pý¡znak chyby
         jz        SrcICO9                  ; nen¡ dalç¡ ikona

; ------ porovn n¡ jm‚na ikony

         mov       cl,es:[di]               ; d‚lka jm‚na jedn‚ ikony
         inc       cx                       ; vŸetnØ bajtu d‚lky
         push      cx
         push      si
         push      di
         repe      cmpsb
         pop       di
         pop       si
         pop       cx
         je        SrcICO4                  ; ikona nalezena OK

; ------ dalç¡ ikona

         add       di,cx                    ; pýiŸten¡ d‚lky jm‚na ikony + 1
         inc       di
         inc       di                       ; pýeskoŸen¡ adresy ikony
         dec       bx                       ; Ÿ¡taŸ ikon
         jmp       short SrcICO2            ; dalç¡ ikona

; ------ adresa ikony -> ES

SrcICO4: add       di,cx                    ; pýiŸten¡ d‚lky jm‚na ikony + 1
         mov       es,es:[di]               ; adresa ikony
         clc                                ; pý¡znak operace OK

; ------ n vrat registr…

SrcICO9: pop       di
         pop       cx
         pop       bx
         ret

SrcICO   ENDP

; -----------------------------------------------------------------------------
;        inicializace pozad¡ ikon
; -----------------------------------------------------------------------------

IniPozad PROC      NEAR

         push      ds

         mov       es,ds:[DataICO]          ; zaŸ tek ikon
         mov       dx,ds:[DataICON]         ; poŸet ikon

         mov       ds,ds:[ICONic]           ; pozad¡ plochy

IniPoza2:xor       si,si                    ; ukazatel v datech
         mov       bp,4                     ; poŸet barevnìch rovin
IniPoza3:mov       cx,32*32/8               ; poŸet bajt… v jedn‚ rovinØ
         mov       bx,32*32*4/8             ; ukazatel v masce
IniPoza4:mov       al,es:[bx]               ; bajt masky
         and       byte ptr es:[si],al      ; zruçen¡ maskovanìch dat
         not       al
         and       al,ds:[si]               ; nov  data
         or        es:[si],al               ; nastaven¡ novìch dat
         inc       si                       ; zvìçen¡ ukazatele dat
         inc       bx                       ; zvìçen¡ ukazatele masky
         loop      IniPoza4                 ; dalç¡ bajt dat

         dec       bp                       ; Ÿ¡taŸ rovin
         jnz       IniPoza3                 ; dalç¡ rovina

         mov       ax,es
         add       ax,ICOSize/16            ; dalç¡ ikona
         mov       es,ax
         dec       dx                       ; Ÿ¡taŸ ikon
         jnz       IniPoza2                 ; dalç¡ ikona

         pop       ds
         ret

IniPozad ENDP

; -----------------------------------------------------------------------------
;        korekce naŸten‚ ikony
; -----------------------------------------------------------------------------

KorIcon  PROC      NEAR

; ------ sestaven¡ korekŸn¡ tabulky barev

         mov       bx,offset PalKonv        ; konverzn¡ tabulka barev
         mov       si,offset PalIco         ; tabulka palet
KorIcon1:mov       di,offset PalVGA         ; tabulka normovanìch palet VGA
         mov       bp,-1                    ; BP=nejmenç¡ nalezen  vzd lenost
         xor       cx,cx                    ; ukazatel Ÿ¡sla barvy

KorIcon2:mov       al,ds:[si]               ; skuteŸn  modr 
         shr       al,1
         inc       ax                       ; zaokrouhlen¡ nahoru
         shr       al,1                     ; pýevod na modul 64
         sub       al,ds:[di]               ; vzd lenost od standardn¡ modr‚
         inc       di
         imul      al                       ; absolutn¡ hodnota
         xchg      ax,dx                    ; DX <- £schova vzd lenosti

         mov       al,ds:[si+1]             ; skuteŸn  zelen 
         shr       al,1
         inc       ax                       ; zaokrouhlen¡ nahoru
         shr       al,1                     ; pýevod na modul 64
         sub       al,ds:[di]               ; vzd lenost od standardn¡ zelen‚
         inc       di
         imul      al                       ; absolutn¡ hodnota
         add       dx,ax                    ; DX <- pýid n¡ ke stýadaŸi

         mov       al,ds:[si+2]             ; skuteŸn  Ÿerven 
         shr       al,1
         inc       ax                       ; zaokrouhlen¡ nahoru
         shr       al,1                     ; pýevod na modul 64
         sub       al,ds:[di]               ; vzd lenost od standardn¡ Ÿerven‚
         inc       di
         imul      al                       ; absolutn¡ hodnota
         add       ax,dx                    ; AX <- pýid n¡ ke stýadaŸi (v AX !)

         cmp       ax,bp                    ; je menç¡ vzd lenost ?
         jae       KorIco22                 ; nen¡ menç¡ vzd lenost
         xchg      ax,bp                    ; BP <- £schova vzd lenosti
         mov       ds:[bx],cl               ; nalezen  nejbli§ç¡ barva

KorIco22:inc       cx                       ; zvìçen¡ ukazatele Ÿ¡sla barvy
         cmp       cl,16                    ; jsou ji§ vçechny barvy ?
         jb        KorIcon2                 ; dalç¡ barva

         add       si,4                     ; dalç¡ paleta
         inc       bx                       ; zvìçen¡ ukazatele tabulky barev
         cmp       bx,offset PalKonv + 16   ; je konec tabulky ?
         jb        KorIcon1                 ; nen¡ jeçtØ konec tabulky

; ------ korekce barev

         mov       bx,offset PalKonv        ; konverzn¡ tabulka barev
         mov       si,offset IcoBuff        ; buffer dat ikony
         mov       dx,32*32/2               ; poŸet bajt… ke korekci
         mov       cl,4                     ; poŸet rotac¡
         cld
KorIcon3:lodsb                              ; naŸten¡ bajtu
         mov       ah,al                    ; AH <- £schova bajtu
         and       ax,0f00fh                ; AH=prvn¡ bajt, AL=druhì bajt
         xlat                               ; konverze bajtu v AL
         xchg      al,ah
         shr       al,cl                    ; rotace dol…
         xlat                               ; konverze bajtu z AH
         shl       al,cl                    ; rotace zpØt nahoru
         or        al,ah                    ; slouŸen¡ bod… zpØt
         mov       ds:[si-1],al             ; navr cen¡ bajtu zpØt
         dec       dx
         jnz       KorIcon3                 ; dalç¡ bajt
         ret

KorIcon  ENDP

; *****************************************************************************
;
;                       Obsluha displeje a zobrazen¡
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        vymaz n¡ pole
; -----------------------------------------------------------------------------

Vymaz    PROC      NEAR

; ------ £schova registr…

         push      ax
         push      cx
         push      di
         push      es

; ------ vymaz n¡ hrac¡ho pole

         mov       di,offset Pole           ; hrac¡ pole
         mov       ax,ds:[ICONic]           ; adresa ikony plochy
         mov       cx,PSIRKA*PVYSKA         ; velikost plochy
         push      ds
         pop       es
         cld
         rep       stosw                    ; vymaz n¡ plochy

; ------ n vrat registr…

         pop       es
         pop       di
         pop       cx
         pop       ax
         ret

Vymaz    ENDP

; -----------------------------------------------------------------------------
;        inicializaŸn¡ vymaz n¡ plochy
; -----------------------------------------------------------------------------

IniVymaz PROC      NEAR

; ------ zobrazen¡ r mu kolem hrac¡ plochy

         call      DispRam                  ; zobrazen¡ r mu kolem hrac¡ plochy

; ------ zobrazen¡ r mu kolem menu

         call      MenuRam                  ; zobrazen¡ r mu kolem menu

; ------ zobrazen¡ r mu textu (s vymaz n¡m textu)

         call      TextRam                  ; zobrazen¡ r mu kolem textu

; ------ vymaz n¡ plochy

         call      Vymaz                    ; vymaz n¡ plochy
         call      DispPole                 ; zobrazen¡ pole

; ------ vymaz n¡ menu

         call      DispMenu                 ; zobrazen¡ menu
         ret

IniVymaz ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ menu
; -----------------------------------------------------------------------------

DispMenu PROC      NEAR

         push      bx
         push      dx
         push      es

         mov       dh,1
         mov       bh,0
DispMen2:mov       dl,1+PSIRKA*4+1+1
         mov       bl,0
DispMen3:mov       es,ds:[ICOMenu]
         or        bx,bx
         jnz       DispMen4
         mov       es,ds:[ICOVlevo]
DispMen4:cmp       bx,100h
         jne       DispMen5
         mov       es,ds:[ICOVzad]
DispMen5:cmp       bx,200h
         jne       DispMen6
         mov       es,ds:[ICOVprav]
DispMen6:cmp       bx,300h
         jne       DispMen7
         mov       es,ds:[ICOKrok]
DispMen7:cmp       bx,400h
         jne       DispMen8
         mov       es,ds:[ICONic]
DispMen8:cmp       bx,500h
         jne       DispMen9
         mov       es,ds:[ICOZed]
DispMen9:
;cmp       bx,102h
;         jne       DispMn92
;         mov       es,ds:[ICODomek]
DispMn92:
         cmp       bx,0d00h
         jne       DispMenA
         mov       es,ds:[ICOKonec]
DispMenA:cmp       bx,0c00h
         jne       DispMenB
         mov       es,ds:[ICODisk]
DispMenB:cmp       bx,0b00h
         jne       DispMenC
         mov       es,ds:[ICOMaluj]
DIspMenC:

         call      DispIcon
         inc       bx
         add       dl,4
         cmp       dl,1+PSIRKA*4+1+1+MSIRKA*4
         jb        DispMen3
         inc       bh
         add       dh,4
         cmp       dh,1+MVYSKA*4
         jb        DispMen2

         pop       es
         pop       dx
         pop       bx
         ret

DispMenu ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ r mu kolem textu (s vymaz n¡m textu)
; -----------------------------------------------------------------------------

TextRam  PROC      NEAR

; ------ £schova registr…

         call      MouseOff                 ; vypnut¡ kurzoru myçi
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

; ------ pý¡prava registr…

         mov       ax,8+PVYSKA*32+8         ; poŸet linek
         mul       word ptr ds:[DispSirB]   ; * d‚lka linky v bajtech
         xchg      ax,bp                    ; BP <- poŸ teŸn¡ adresa r mu
         mov       es,ds:[AdrVRAM]          ; ES <- adresa videopamØti
         mov       ds,ds:[ICORamT]          ; adresa ikony r mu kolem textu
         mov       ch,0
         xor       si,si                    ; SI <- 0 poŸ tek dat ikony
         cld

; ------ nastaven¡ registr… barvy a masky

         mov       dx,3ceh
         mov       al,8                     ; registr 8
         out       dx,al                    ; volba registru 8
         inc       dx
         mov       al,0ffh                  ; maska - vçechny bity
         out       dx,al                    ; vçechny bity
         dec       dx
         mov       al,1                     ; registr 1
         out       dx,al                    ; volba registru 1
         mov       al,0                     ; vçechny roviny podle dat
         inc       dx
         out       dx,al                    ; volba rovin

; ------ nastaven¡ z pisov‚ roviny

         mov       ah,bit0                  ; ukazatel z pisov‚ roviny
TextRam1:mov       di,bp                    ; ukl dac¡ adresa
         mov       dx,3c4h
         mov       al,2
         out       dx,al                    ; volba registru 2
         inc       dx                       ; datovì registr
         mov       al,ah                    ; z pisov  rovina
         out       dx,al                    ; volba z pisov‚ roviny

; ------ levì okraj

         mov       bx,16                    ; poŸet linek k pýenesen¡
TextRam5:movsb                              ; pýenos lev‚ho okraje

; ------ stýedn¡ Ÿ st

         mov       cx,(80-2)/2              ; d‚lka linky ve slovech
TextRam6:movsw
         dec       si
         dec       si
         loop      TextRam6

; ------ pravì okraj

         inc       si
         inc       si
         movsb                              ; pýenos prav‚ho okraje

; ------ pý¡prava pro dalç¡ linku

         dec       bx
         jnz       TextRam5                 ; dalç¡ linka

; ------ pý¡prava pro dalç¡ rovinu

         add       si,16*4                  ; pýeskoŸen¡ nevyu§it‚ spodn¡ Ÿ sti
         shl       ah,1                     ; posun masky barevn‚ roviny
         cmp       ah,bit4                  ; jsou ji§ vçechny roviny ?
         jne       TextRam1                 ; z pis dalç¡ roviny

; ------ n vrat z pisu do vçech rovin

         mov       al,1111b
         out       dx,al                    ; z pis do vçech rovin

; ------ n vrat registr…

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         mov       word ptr ds:[TimeTxt],0  ; nulov n¡ Ÿ¡taŸe pro vypnut¡
         ret

TextRam  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ r mu kolem menu
; -----------------------------------------------------------------------------

MenuRam  PROC      NEAR

; ------ £schova registr…

         call      MouseOff                 ; vypnut¡ kurzoru myçi
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

; ------ pý¡prava registr…

         mov       bp,ds:[DispSirB]         ; d‚lka linky v bajtech
         sub       bp,MSIRKA*4+2            ; pý¡rustek adresy mezi linkami
         mov       es,ds:[AdrVRAM]          ; ES <- adresa videopamØti
         mov       ds,ds:[ICORamM]          ; adresa ikony r mu kolem menu
         mov       ch,0
         xor       si,si                    ; SI <- 0 poŸ tek dat ikony
         cld

; ------ nastaven¡ registr… barvy a masky

         mov       dx,3ceh
         mov       al,8                     ; registr 8
         out       dx,al                    ; volba registru 8
         inc       dx
         mov       al,0ffh                  ; maska - vçechny bity
         out       dx,al                    ; vçechny bity
         dec       dx
         mov       al,1                     ; registr 1
         out       dx,al                    ; volba registru 1
         mov       al,0                     ; vçechny roviny podle dat
         inc       dx
         out       dx,al                    ; volba rovin

; ------ nastaven¡ z pisov‚ roviny

         mov       ah,bit0                  ; ukazatel z pisov‚ roviny
MenuRam1:mov       di,1+PSIRKA*4+1          ; ukl dac¡ adresa
         mov       dx,3c4h
         mov       al,2
         out       dx,al                    ; volba registru 2
         inc       dx                       ; datovì registr
         mov       al,ah                    ; z pisov  rovina
         out       dx,al                    ; volba z pisov‚ roviny

; ------ levì horn¡ roh

         mov       bx,8                     ; poŸet linek k z pisu
MenuRam2:movsb                              ; levì horn¡ roh

; ------ horn¡ okraj

         mov       cx,MSIRKA*2              ; poŸet slov k pýenesen¡
MenuRam3:movsw                              ; pýenesen¡ linky
         dec       si
         dec       si
         loop      MenuRam3

; ------ pravì horn¡ roh

         inc       si
         inc       si
         movsb                              ; pravì horn¡ roh

; ------ pý¡prava pro dalç¡ linku horn¡ho okraje

         add       di,bp                    ; adresa dalç¡ linky
         dec       bx                       ; Ÿ¡taŸ linek
         jnz       MenuRam2                 ; dalç¡ linka

; ------ levì okraj

         mov       bx,MVYSKA*2              ; poŸet ý dk… k pýenesen¡
MenuRam4:mov       cx,16                    ; poŸet linek v jednom ý dku
MenuRam5:movsb                              ; pýenos lev‚ho okraje
         inc       si
         inc       si

; ------ pravì okraj

         add       di,MSIRKA*4              ; aresa prav‚ho okraje
         movsb                              ; pýenos prav‚ho okraje

; ------ pý¡prava pro dalç¡ linku stýedn¡ Ÿ sti

         add       di,bp                    ; adresa dalç¡ linky
         loop      MenuRam5                 ; dalç¡ linka

; ------ pý¡prava pro dalç¡ ý dek stýedn¡ Ÿ sti

         sub       si,16*4                  ; n vrat poŸ tku ý dku
         dec       bx                       ; Ÿ¡taŸ ý dk…
         jnz       MenuRam4                 ; dalç¡ ý dek
         add       si,16*4                  ; adresa spodn¡ho okraje

; ------ levì doln¡ roh

         mov       bx,8                     ; poŸet linek k z pisu
MenuRam6:movsb                              ; levì doln¡ roh

; ------ doln¡ okraj

         mov       cx,MSIRKA*2              ; poŸet slov k pýenesen¡
MenuRam7:movsw                              ; pýenesen¡ linky
         dec       si
         dec       si
         loop      MenuRam7

; ------ pravì doln¡ roh

         inc       si
         inc       si
         movsb                              ; pravì doln¡ roh

; ------ pý¡prava pro dalç¡ linku doln¡ho okraje

         add       di,bp                    ; adresa dalç¡ linky
         dec       bx                       ; Ÿ¡taŸ linek
         jnz       MenuRam6                 ; dalç¡ linka

; ------ pý¡prava pro dalç¡ rovinu

         shl       ah,1                     ; posun masky barevn‚ roviny
         cmp       ah,bit4                  ; jsou ji§ vçechny roviny ?
         jne       MenuRam1                 ; z pis dalç¡ roviny

; ------ n vrat z pisu do vçech rovin

         mov       al,1111b
         out       dx,al                    ; z pis do vçech rovin

; ------ n vrat registr…

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

MenuRam  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ r mu kolem hrac¡ plochy
; -----------------------------------------------------------------------------

DispRam  PROC      NEAR

; ------ £schova registr…

         call      MouseOff                 ; vypnut¡ kurzoru myçi
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

; ------ pý¡prava registr…

         mov       bp,ds:[DispSirB]         ; d‚lka linky v bajtech
         sub       bp,PSIRKA*4+2            ; pý¡rustek adresy mezi linkami
         mov       es,ds:[AdrVRAM]          ; ES <- adresa videopamØti
         mov       ds,ds:[ICORam]           ; adresa ikony r mu
         mov       ch,0
         xor       si,si                    ; SI <- 0 poŸ tek dat ikony
         cld

; ------ nastaven¡ registr… barvy a masky

         mov       dx,3ceh
         mov       al,8                     ; registr 8
         out       dx,al                    ; volba registru 8
         inc       dx
         mov       al,0ffh                  ; maska - vçechny bity
         out       dx,al                    ; vçechny bity
         dec       dx
         mov       al,1                     ; registr 1
         out       dx,al                    ; volba registru 1
         mov       al,0                     ; vçechny roviny podle dat
         inc       dx
         out       dx,al                    ; volba rovin

; ------ nastaven¡ z pisov‚ roviny

         mov       ah,bit0                  ; ukazatel z pisov‚ roviny
DispRam1:xor       di,di                    ; ukl dac¡ adresa
         mov       dx,3c4h
         mov       al,2
         out       dx,al                    ; volba registru 2
         inc       dx                       ; datovì registr
         mov       al,ah                    ; z pisov  rovina
         out       dx,al                    ; volba z pisov‚ roviny

; ------ levì horn¡ roh

         mov       bx,8                     ; poŸet linek k z pisu
DispRam2:movsb                              ; levì horn¡ roh

; ------ horn¡ okraj

         mov       cx,PSIRKA*2              ; poŸet slov k pýenesen¡
DispRam3:movsw                              ; pýenesen¡ linky
         dec       si
         dec       si
         loop      DispRam3

; ------ pravì horn¡ roh

         inc       si
         inc       si
         movsb                              ; pravì horn¡ roh

; ------ pý¡prava pro dalç¡ linku horn¡ho okraje

         add       di,bp                    ; adresa dalç¡ linky
         dec       bx                       ; Ÿ¡taŸ linek
         jnz       DispRam2                 ; dalç¡ linka

; ------ levì okraj

         mov       bx,PVYSKA*2              ; poŸet ý dk… k pýenesen¡
DispRam4:mov       cx,16                    ; poŸet linek v jednom ý dku
DispRam5:movsb                              ; pýenos lev‚ho okraje
         inc       si
         inc       si

; ------ pravì okraj

         add       di,PSIRKA*4              ; aresa prav‚ho okraje
         movsb                              ; pýenos prav‚ho okraje

; ------ pý¡prava pro dalç¡ linku stýedn¡ Ÿ sti

         add       di,bp                    ; adresa dalç¡ linky
         loop      DispRam5                 ; dalç¡ linka

; ------ pý¡prava pro dalç¡ ý dek stýedn¡ Ÿ sti

         sub       si,16*4                  ; n vrat poŸ tku ý dku
         dec       bx                       ; Ÿ¡taŸ ý dk…
         jnz       DispRam4                 ; dalç¡ ý dek
         add       si,16*4                  ; adresa spodn¡ho okraje

; ------ levì doln¡ roh

         mov       bx,8                     ; poŸet linek k z pisu
DispRam6:movsb                              ; levì doln¡ roh

; ------ doln¡ okraj

         mov       cx,PSIRKA*2              ; poŸet slov k pýenesen¡
DispRam7:movsw                              ; pýenesen¡ linky
         dec       si
         dec       si
         loop      DispRam7

; ------ pravì doln¡ roh

         inc       si
         inc       si
         movsb                              ; pravì doln¡ roh

; ------ pý¡prava pro dalç¡ linku doln¡ho okraje

         add       di,bp                    ; adresa dalç¡ linky
         dec       bx                       ; Ÿ¡taŸ linek
         jnz       DispRam6                 ; dalç¡ linka

; ------ pý¡prava pro dalç¡ rovinu

         shl       ah,1                     ; posun masky barevn‚ roviny
         cmp       ah,bit4                  ; jsou ji§ vçechny roviny ?
         jne       DispRam1                 ; z pis dalç¡ roviny

; ------ n vrat z pisu do vçech rovin

         mov       al,1111b
         out       dx,al                    ; z pis do vçech rovin

; ------ n vrat registr…

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispRam  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ cel‚ho pole
; -----------------------------------------------------------------------------

DispPole PROC      NEAR

; ------ £schova registr…

         push      dx

; ------ zobrazen¡ plochy

         mov       dh,0                     ; poŸ teŸn¡ ý dek
DispPol1:mov       dl,0                     ; poŸ teŸn¡ pozice
DispPol2:call      PoleIcon                 ; zobrazen¡ ikony
         inc       dx
         cmp       dl,PSIRKA
         jb        DispPol2
         inc       dh
         cmp       dh,PVYSKA
         jb        DispPol1

; ------ n vrat registr…

         pop       dx
         ret

DispPole ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ polo§ky pole (DH=linka, DL=pozice, mohou bìt mimo rozsah)
; -----------------------------------------------------------------------------

PoleIcon PROC      NEAR

; ------ £schova registr…

         push      ax
         push      bx
         push      dx
         push      es

; ------ kontrola ukazatel…

         cmp       dh,PVYSKA
         jae       PoleIco9                 ; chybnì ý dek
         cmp       dl,PSIRKA
         jae       PoleIco9                 ; chybn  pozice

; ------ kontrola, zda se t¡m vyma§e Karel

         cmp       dx,ds:[KarelOPz]         ; je to star  pozice Karla ?
         jne       PoleIco4                 ; nen¡ to star  pozice Karla
         and       byte ptr ds:[Param],not bit3 ; Karel nen¡ zobrazen

; ------ adresa ikony -> ES

PoleIco4:mov       al,PSIRKA                ; poŸet pozic na ý dek
         mul       dh                       ; pýepoŸet ý dku na pozici
         add       al,dl                    ; pýiŸten¡ pozice
         adc       ah,0
         shl       ax,1                     ; offset v tabulce
         xchg      ax,bx                    ; BX <- offset v tabulce
         mov       es,ds:[bx+Pole]          ; ES <- adresa ikony

; ------ pozice k zobrazen¡ -> DX

         shl       dx,1
         shl       dx,1
         add       dx,101h

; ------ zobrazen¡ ikony

         call      DispIcon                 ; zobrazen¡ ikony

; ------ n vrat registr…

PoleIco9:pop       es
         pop       dx
         pop       bx
         pop       ax
         ret

PoleIcon ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ikony na adrese ES:0, linka DH, pozice DL
; -----------------------------------------------------------------------------

DispIcon PROC      NEAR

; ------ £schova registr…

         call      MouseOff                 ; vypnut¡ kurzoru myçi
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

; ------ ukl dac¡ adresa do videopamØti -> DI

         push      dx
         mov       al,8
         mul       dh                       ; pýepoŸet ý dku na linku
         mul       word ptr ds:[DispSirB]   ; pýepoŸet na bajty
         pop       dx
         mov       dh,0
         add       ax,dx                    ; adresa k ulo§en¡
         xchg      ax,di                    ; DI <- adresa ve videopamØti

; ------ pý¡prava registr…

         mov       bx,ds:[DispSirB]         ; ç¡ýka linky v bajtech
         sub       bx,4                     ; pý¡rustek adresy linek ikony
         push      es
         mov       es,ds:[AdrVRAM]          ; adresa videopamØti
         pop       ds                       ; DS <- segment ikony
         xor       si,si                    ; SI <- 0 poŸ tek dat ikony
         mov       ch,0

; ------ nastaven¡ registr… barvy a masky

         mov       dx,3ceh
         mov       al,8                     ; registr 8
         out       dx,al                    ; volba registru 8
         inc       dx
         mov       al,0ffh                  ; maska - vçechny bity
         out       dx,al                    ; vçechny bity
         dec       dx
         mov       al,1                     ; registr 1
         out       dx,al                    ; volba registru 1
         mov       al,0                     ; vçechny roviny podle dat
         inc       dx
         out       dx,al                    ; volba rovin

; ------ nastaven¡ z pisov‚ roviny

         mov       ah,bit0                  ; maska volby z pisov‚ roviny
DispIco2:mov       dx,3c4h
         mov       al,2
         out       dx,al                    ; volba registru 2
         inc       dx                       ; datovì registr
         mov       al,ah                    ; z pisov  rovina
         out       dx,al                    ; volba z pisov‚ roviny

; ------ pýenos roviny obr zku

         mov       cl,32                    ; vìçka ikony v link ch
         push      di
DispIco3:movsw
         movsw
         add       di,bx                    ; adresa dalç¡ linky
         loop      DispIco3                 ; dalç¡ linka
         pop       di

; ------ pý¡prava pro dalç¡ rovinu

         shl       ah,1                     ; posun masky barevn‚ roviny
         cmp       ah,bit4                  ; jsou ji§ vçechny roviny ?
         jne       DispIco2                 ; z pis dalç¡ roviny

; ------ n vrat z pisu do vçech rovin

         mov       al,1111b
         out       dx,al                    ; z pis do vçech rovin

; ------ n vrat registr…

         pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispIcon ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ikony s maskou na adrese ES:0, linka DH, pozice DL
; -----------------------------------------------------------------------------

MaskIcon PROC      NEAR

; ------ £schova registr…

         call      MouseOff                 ; vypnut¡ kurzoru myçi
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

; ------ ukl dac¡ adresa do videopamØti -> DI

         push      dx
         mov       al,8
         mul       dh                       ; pýepoŸet ý dku na linku
         mul       word ptr ds:[DispSirB]   ; pýepoŸet na bajty
         pop       dx
         mov       dh,0
         add       ax,dx                    ; adresa k ulo§en¡
         xchg      ax,di                    ; DI <- adresa ve videopamØti

; ------ pý¡prava registr…

         mov       bp,ds:[DispSirB]         ; ç¡ýka linky v bajtech
         sub       bp,4                     ; pý¡rustek adresy linek ikony
         push      es
         mov       es,ds:[AdrVRAM]          ; adresa videopamØti
         pop       ds                       ; DS <- segment ikony
         xor       si,si                    ; SI <- 0 poŸ tek dat ikony
         mov       ch,0

; ------ nastaven¡ registru barvy

         mov       dx,3ceh
         mov       al,1                     ; registr 1
         out       dx,al                    ; volba registru 1
         mov       al,0                     ; vçechny roviny podle dat
         inc       dx
         out       dx,al                    ; volba rovin

; ------ nastaven¡ z pisov‚ roviny

         mov       ah,bit0                  ; maska volby z pisov‚ roviny
MaskIco2:mov       dx,3c4h
         mov       al,2
         out       dx,al                    ; volba registru 2
         inc       dx                       ; datovì registr
         mov       al,ah                    ; z pisov  rovina
         out       dx,al                    ; volba z pisov‚ roviny

; ------ pýednastaven¡ registru bitov‚ masky

         mov       dx,3ceh
         mov       al,8                     ; registr 8
         out       dx,al                    ; volba registru 8
         inc       dx

; ------ pýenos roviny obr zku

         mov       bx,32*32*4/8             ; offset masky ikony
         mov       cl,32                    ; vìçka ikony v link ch
         push      di
MaskIco3:mov       al,ds:[bx]               ; maska
         inc       bx
         out       dx,al                    ; nastaven¡ masky
         mov       al,es:[di]               ; naŸten¡ bajtu
         movsb                              ; ulo§en¡ bajtu

         mov       al,ds:[bx]               ; maska
         inc       bx
         out       dx,al                    ; nastaven¡ masky
         mov       al,es:[di]               ; naŸten¡ bajtu
         movsb                              ; ulo§en¡ bajtu

         mov       al,ds:[bx]               ; maska
         inc       bx
         out       dx,al                    ; nastaven¡ masky
         mov       al,es:[di]               ; naŸten¡ bajtu
         movsb                              ; ulo§en¡ bajtu

         mov       al,ds:[bx]               ; maska
         inc       bx
         out       dx,al                    ; nastaven¡ masky
         mov       al,es:[di]               ; naŸten¡ bajtu
         movsb                              ; ulo§en¡ bajtu

         add       di,bp                    ; adresa dalç¡ linky
         loop      MaskIco3                 ; dalç¡ linka
         pop       di

; ------ pý¡prava pro dalç¡ rovinu

         shl       ah,1                     ; posun masky barevn‚ roviny
         cmp       ah,bit4                  ; jsou ji§ vçechny roviny ?
         jne       MaskIco2                 ; z pis dalç¡ roviny

; ------ n vrat videoregistr…

         mov       al,0ffh                  ; maska - vçechny bity
         out       dx,al                    ; vçechny bity
         mov       dx,3c4h
         mov       al,1111b
         out       dx,al                    ; z pis do vçech rovin

; ------ n vrat registr…

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

MaskIcon ENDP

; -----------------------------------------------------------------------------
;        Ÿasov  obsluha maz n¡ hl çen¡
; -----------------------------------------------------------------------------

IntHlas  PROC      NEAR

         cmp       word ptr ds:[TimeTxt],1  ; je potýeba vymazat ?
         jne       IntHlas9                 ; nen¡ potýeba vymazat
         call      TextRam                  ; vymaz n¡ hl çen¡
IntHlas9:ret

IntHlas  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ hl çen¡ DS:SI, barva AH, doba CX
; -----------------------------------------------------------------------------

DispHlas PROC      NEAR

         push      bx
         push      cx
         push      dx
         push      si

         cmp       word ptr ds:[TimeTxt],0  ; je nØco zobrazeno ?
         je        DispHls2                 ; nen¡ nic zobrazeno
         call      TextRam                  ; vymaz n¡ textu

DispHls2:mov       ds:[TimeTxt],cx          ; novì Ÿ¡taŸ doby

         mov       cl,ds:[si]               ; d‚lka textu
         inc       si
         mov       ch,0
         mov       bx,80
         sub       bx,cx
         jnc       DispHls3
         xor       bx,bx
         mov       cl,80
DispHls3:shr       bx,1

         mov       dx,480-15

         call      DispTxt

         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

DispHlas ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ textu DS:SI, barva AH, linka DX, pozice BX, CX znak…
; -----------------------------------------------------------------------------

DispTxt  PROC      NEAR

         push      ax
         push      cx
         push      si

DispTxt1:cld
         cmp       ah,0fh
         jbe       DispTxt6

         push      ax
         shr       ah,1
         shr       ah,1
         shr       ah,1
         shr       ah,1
         mov       al,219
         call      DispChr
         dec       bx
         pop       ax

DispTxt6:lodsb
         push      ax
         and       ah,0fh
         call      DispChr
         pop       ax
         loop      DispTxt1

         pop       si
         pop       cx
         pop       ax
         ret

DispTxt  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku AL, barva AH, linka DX, pozice BX
; -----------------------------------------------------------------------------

DispChr  PROC      NEAR

; ------ £schova registr…

         call      MouseOff                 ; vypnut¡ kurzoru myçi
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ adresa znaku -> SI

         push      ax                       ; £schova barvy znaku

         mov       ah,byte ptr ds:[VysFont] ; vìçka pou§it‚ho fontu
         mul       ah                       ; offset znaku
         add       ax,ds:[AdrFont]          ; adresa znaku
         xchg      ax,si                    ; SI <- adresa znaku

; ------ vìpoŸet adresy ve videopamØti -> DI

         xor       di,di                    ; DI <- 0 nen¡ korekce
         cmp       byte ptr ds:[TypCard],2  ; je videokarta CGA ?
         ja        DispChr2                 ; nen¡ videokarta CGA ani Hercules
         shr       dx,1                     ; je lich  linka ?
         jnc       DispChr1                 ; nen¡ lich  linka
         add       di,2000h                 ; korekce pro lichou linku CGA
DispChr1:cmp       byte ptr ds:[TypCard],1  ; je videokarta Hercules ?
         jne       DispChr2                 ; nen¡ videokarta Hercules
         shr       dx,1                     ; je lichì p r linek ?
         jnc       DispChr2                 ; nen¡ lichì p r linek
         add       di,4000h                 ; korekce pro lichì p r linek
DispChr2:mov       ax,ds:[DispSirB]         ; poŸet bajt… na linku
         mul       dx                       ; pýepoŸet linky na adresu
         add       di,ax                    ; adresa linky
         add       di,bx                    ; pýiŸten¡ pozice

         pop       ax                       ; po§adovan  barva znaku

; ------ pý¡prava k operaci

         cld
         cli                                ; z kaz pýeruçen¡ bØhem operace
         mov       es,ds:[AdrVRAM]          ; adresa videopamØti
         mov       cx,ds:[VysFont]          ; vìçka znaku v link ch

; ------ zobrazen¡ znaku pro Hercules a CGA

         cmp       byte ptr ds:[TypCard],2  ; je videokarta CGA ?
         ja        DispChr7                 ; nen¡ videokarta CGA ani Hercules
DispChr4:lodsb                              ; naŸten¡ bajtu
         or        byte ptr es:[di],al      ; b¡l‚ p¡smo
         cmp       ah,0fh                   ; je b¡l  barva ?
         jne       DispCh41                 ; nen¡ b¡l  barva
;         cmp       byte ptr ds:[Barva],0    ; je pozad¡ Ÿern‚ ?
;         je        DispCh41                 ; pozad¡ je Ÿern‚
;         xor       byte ptr es:[di],al      ; zmØna na Ÿernou barvu
DispCh41:;call      IncAdr                   ; zvìçen¡ adresy DI
         loop      DispChr4                 ; dalç¡ bajt
         jmp       short DispChr9

; ------ nastaven¡ z pisu do vçech rovin

DispChr7:mov       dx,3c4h
         mov       al,2
         out       dx,al                    ; volba registru 2
         inc       dx                       ; datovì registr
         mov       al,0fh                   ; z pisov  rovina - vçe
         out       dx,al                    ; volba z pisov‚ roviny

; ------ nastaven¡ barvy znaku

         mov       dx,3ceh
         mov       al,0                     ; registr 0
         out       dx,al                    ; volba registru 0
         inc       dx
         mov       al,ah                    ; po§adovan  barva znaku
;         cmp       al,0fh                   ; je b¡l  barva ?
;         jne       DispCh72                 ; nen¡ b¡l  barva
;         cmp       byte ptr ds:[Barva],8    ; je svØtl  barva ?
;         jb        DispCh72                 ; nen¡ svØtl  barva
;         cmp       byte ptr ds:[Barva],9
;         je        DispCh72                 ; je Ÿerven  barva
;         cmp       byte ptr ds:[Barva],12
;         je        DispCh72                 ; je modr  barva
;         cmp       byte ptr ds:[Barva],13
;         je        DispCh72                 ; je fialov  barva
;         mov       al,0                     ; bude Ÿern  barva
DispCh72:out       dx,al                    ; nastaven¡ barvy znaku
         dec       dx

; ------ nastaven¡ volby rovin

         mov       al,1                     ; registr 1
         out       dx,al                    ; volba registru 1
         mov       al,1111b                 ; vçechny roviny podle registru 0
         inc       dx
         out       dx,al                    ; volba rovin
         dec       dx

; ------ pýednastaven¡ registru bitov‚ masky

         mov       al,8                     ; registr 8
         out       dx,al                    ; volba registru 8
         inc       dx

; ------ z pis obr zku do roviny

DispChr8:lodsb
         out       dx,al                    ; nastaven¡ masky
         xchg      al,es:[di]               ; z pis znaku
         add       di,640/8
         loop      DispChr8

; ------ n vrat videoregistr…

         mov       al,0ffh                  ; maska - vçechny bity
         out       dx,al                    ; vçechny bity
         dec       dx
         mov       al,1                     ; registr 1
         out       dx,al                    ; volba registru 1
         mov       al,0                     ; vçechny roviny podle dat
         inc       dx
         out       dx,al                    ; volba rovin

; ------ n vrat registr…

DispChr9:sti                                ; pýeruçen¡ opØt povoleno
         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         inc       bx                       ; zvìçen¡ ukazatele pozice
         ret

DispChr  ENDP

; -----------------------------------------------------------------------------
;        inicializace videokarty
; -----------------------------------------------------------------------------

IniCard  PROC      NEAR

; ------ test zad n¡ karty Hercules

         mov       ah,0
         mov       al,ds:[TypCard]          ; zadan  videokarta
         dec       ax
         jnz       IniCrd01                 ; nen¡ Hercules
         mov       al,7
         call      TestVMod                 ; test videom¢du
         jnz       IniCrd08                 ; nen¡ Hercules
         jmp       IniCrd52                 ; je Hercules OK

; ------ test zad n¡ karty CGA

IniCrd01:dec       ax
         jnz       IniCrd02                 ; nen¡ CGA
         mov       al,6                     ; m¢d pro CGA
         call      TestVMod                 ; test videom¢du
         jnz       IniCrd08                 ; nen¡ CGA
         jmp       IniCrd62                 ; je CGA OK

; ------ test zad n¡ EGA

IniCrd02:dec       ax
         jnz       IniCrd03                 ; nen¡ EGA
         mov       al,16
         call      TestVMod                 ; test videom¢du
         jnz       IniCrd08                 ; nen¡ EGA
         jmp       IniCrd42                 ; je EGA OK

; ------ test zad n¡ VGA

IniCrd03:dec       ax
         jnz       IniCrd08                 ; nen¡ VGA
         mov       al,18
         call      TestVMod                 ; test videom¢du
         jz        IniCrd32                 ; je VGA OK

; ------ test videokarty EGA/VGA

IniCrd08:mov       ah,12h                   ; slu§ba EGA/VGA - informace o EGA
         mov       bx,4510h                 ; poskytnut¡ informac¡ o EGA
         call      Int10                    ; poskytnut¡ informac¡ o EGA/VGA
         cmp       bh,2                     ; kontrola navr cen‚ho m¢du displeje
         ja        IniCard1                 ; nen¡ to karta EGA/VGA
         cmp       bl,5                     ; maxim lnØ povolen 1 MB pamØti
         jbe       IniCard2                 ; je to EGA/VGA
IniCard1:jmp       IniCard5                 ; nen¡ to karta EGA/VGA

; ------ rozliçen¡ videokarty EGA a VGA

IniCard2:mov       ax,1a00h
         call      Int10                    ; dotaz na instalaci karty
         cmp       al,1ah
         jne       IniCard4                 ; funkce nen¡ obsluhovan  - je EGA
         cmp       bl,7
         je        IniCard3                 ; je karta VGA
         cmp       bl,8
         je        IniCard3                 ; je karta VGA
         cmp       bl,11
         je        IniCard3                 ; je karta VGA
         cmp       bl,12
         jne       IniCard4                 ; nen¡ karta VGA

; ------ je karta VGA

IniCard3:mov       al,18                    ; videom¢d VGA: 640*480
IniCrd32:mov       byte ptr ds:[TypCard],4  ; je karta VGA
         mov       word ptr ds:[AdrVRAM],0a000h ; adresa videopamØti
         mov       word ptr ds:[DispSirX],640 ; ç¡ýka obrazovky (bod…)
         mov       word ptr ds:[DispSirB],80  ; ç¡ýka obrazovky (bajt…)
         mov       word ptr ds:[DispVysY],480 ; vìçka obrazovky (bod…)
         mov       word ptr ds:[AdrFont],offset Font16 ; adresa pou§it‚ho fontu
         mov       word ptr ds:[VysFont],16 ; vìçka pou§it‚ho fontu
         jmp       IniCard7

; ------ je karta EGA

IniCard4:mov       al,16                    ; videom¢d EGA: 640*350
IniCrd42:mov       byte ptr ds:[TypCard],3  ; je EGA
         mov       word ptr ds:[AdrVRAM],0a000h ; adresa videopamØti
         mov       word ptr ds:[DispSirX],640 ; ç¡ýka obrazovky (bod…)
         mov       word ptr ds:[DispSirB],80  ; ç¡ýka obrazovky (bajt…)
         mov       word ptr ds:[DispVysY],350 ; vìçka obrazovky (bod…)
         mov       word ptr ds:[AdrFont],offset Font14 ; adresa pou§it‚ho fontu
         mov       word ptr ds:[VysFont],14 ; vìçka pou§it‚ho fontu
         jmp       IniCard7

; ------ rozliçen¡ karet CGA/Hercules

IniCard5:mov       ah,0fh
         call      Int10                    ; poskytnut¡ aktivn¡ho videom¢du
         cmp       al,7                     ; je videom¢d 7 (Hercules) ?
         jne       IniCard6                 ; nen¡ Hercules - je CGA

; ------ je karta Hercules (AL=7 nebo AL=0 ji§ je inicializov no)

IniCrd52:mov       byte ptr ds:[TypCard],1  ; Hercules
         mov       word ptr ds:[AdrVRAM],0b000h ; adresa videopamØti
         mov       word ptr ds:[DispSirX],HercSir*8 ; ç¡ýka obrazovky (bod…)
         mov       word ptr ds:[DispSirB],HercSir  ; ç¡ýka obrazovky (bajt…)
         mov       word ptr ds:[DispVysY],350 ; vìçka obrazovky (bod…)
         mov       word ptr ds:[AdrFont],offset Font14 ; adresa pou§it‚ho fontu
         mov       word ptr ds:[VysFont],14 ; vìçka pou§it‚ho fontu
         mov       ah,0
         or        ax,ax
         jz        IniCrd54                 ; je ji§ nastaven
         call      Int10                    ; nastaven¡ videom¢du
IniCrd54:call      InitHGC                  ; inicializace grafick‚ho m¢du HGC

         cld
         mov       es,ds:[AdrVRAM]          ; adresa videopamØti
         xor       ax,ax
         xor       di,di
         mov       cx,8000h/2
         rep       stosw                    ; vymaz n¡ videopamØti Hercules
         ret

; ------ je karta CGA

IniCard6:mov       al,6                     ; videom¢d CGA: 640*200
IniCrd62:mov       byte ptr ds:[TypCard],2  ; CGA
         mov       word ptr ds:[AdrVRAM],0b800h ; adresa videopamØti
         mov       word ptr ds:[DispSirX],640 ; ç¡ýka obrazovky (bod…)
         mov       word ptr ds:[DispSirB],80  ; ç¡ýka obrazovky (bajt…)
         mov       word ptr ds:[DispVysY],200 ; vìçka obrazovky (bod…)
         mov       word ptr ds:[AdrFont],offset Font08 ; adresa pou§it‚ho fontu
         mov       word ptr ds:[VysFont],8 ; vìçka pou§it‚ho fontu

; ------ nastaven¡ videom¢du AL

IniCard7:mov       ah,0
         or        ax,ax                    ; je ji§ nastaven ?
         jz        IniCrd72                 ; videom¢d je ji§ nastaven
         call      Int10                    ; nastaven¡ videom¢du
IniCrd72:ret

IniCard  ENDP

; ------ testovac¡ nastaven¡ videom¢du AX -> NZ=nen¡, BX=zniŸen, AL=0 pro ZY

TestVMod PROC      NEAR

         mov       bx,ax                    ; BX <- £schova
         call      Int10                    ; nastaven¡ m¢du
         mov       ah,0fh
         call      Int10                    ; poskytnut¡ aktivn¡ho videom¢du
         sub       al,bl                    ; OK ?
         ret

TestVMod ENDP

; -----------------------------------------------------------------------------
;        inicializace palet displeje
; -----------------------------------------------------------------------------

InitPal  PROC      NEAR

; ------ test, zda je videokarta EGA nebo VGA

         cmp       byte ptr ds:[TypCard],3  ; je videokarta EGA nebo VGA ?
         jb        InitPal8                 ; nen¡ videokarta EGA ani VGA

; ------ inicializace palet EGA

         mov       ax,1002h
         push      ds
         pop       es                       ; ES <- datovì segment
         mov       dx,offset PalEGA         ; tabulka palet EGA
         call      Int10                    ; nastaven¡ palet EGA

; ------ test, zda je videokarta VGA

         cmp       byte ptr ds:[TypCard],4  ; je videokarta VGA ?
         jb        InitPal8                 ; nen¡ videokarta VGA

; ------ inicializace palet VGA

         mov       si,offset PalVGA         ; tabulka palet VGA
         mov       di,offset PalEGA         ; tabulka palet EGA
         mov       bp,16                    ; poŸet palet k inicializaci
InitPal2:cld
         lodsw                              ; modr  a zelen 
         xchg      ax,cx                    ; CL <- modr , CH <- zelen 
         lodsb                              ; Ÿerven 
         mov       dh,al                    ; DH <- Ÿerven 
         xchg      si,di
         lodsb
         xchg      si,di
         mov       ah,0
         xchg      ax,bx                    ; BX <- index barvy
         mov       ax,1010h
         call      Int10                    ; nastaven¡ paletov‚ho registru
         dec       bp
         jnz       InitPal2                 ; dalç¡ registr
InitPal8:ret

InitPal  ENDP

; -----------------------------------------------------------------------------
;        inicializace grafick‚ho re§imu karty HGC
; -----------------------------------------------------------------------------

InitHGC  PROC      NEAR

; ------ nastaven¡ registru m¢du karty HGC

         cli
         mov       al,3
         mov       dx,3bfh
         out       dx,al

         mov       al,2
         mov       dx,3b8h
         out       dx,al                    ; grafickì m¢d

; ------ inicializace registr… HGC

         mov       ah,0
         mov       si,offset HGCTabR        ; tabulka registr… karty HGC
         mov       dx,3b4h                  ; adresa portu karty HGC
         cld
InitHGC2:mov       al,ah                    ; Ÿ¡slo registru
         out       dx,al                    ; nastaven¡ Ÿ¡sla registru
         inc       dx
         lodsb                              ; volba Ÿ¡sla registru
         out       dx,al                    ; nastaven¡ registru
         dec       dx
         inc       ah                       ; zvìçen¡ ukazatele registr…
         cmp       ah,16
         jb        InitHGC2                 ; dalç¡ registr

; ------ zapnut¡ videosign lu

         mov       al,1010b            ; graf.m¢d, sign l zap
         mov       dx,03b8h
         out       dx,al
         sti
         ret

InitHgc  ENDP

; -----------------------------------------------------------------------------
;        vol n¡ INT 10h s £schovou registr…
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
;                               Obsluha myçi
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        naŸten¡ stavu myçi -> CY=nen¡ volba, DX=pozice a ý dek ikony menu
; -----------------------------------------------------------------------------

GetMouse PROC      NEAR

         push      ax
         push      bx
         push      cx

         mov       al,5
         xor       bx,bx                    ; lev‚ tlaŸ¡tko myçi
         call      Mouse                    ; test lev‚ho tlaŸ¡tka myçi
         or        bx,bx                    ; bylo lev‚ tlaŸ¡tko myçi ?
         stc
         jz        GetMous9                 ; nebylo lev‚ tlaŸ¡tko

         shr       cx,1
         shr       cx,1
         shr       cx,1                     ; bajtov  pozice kurzoru
         sub       cx,1+PSIRKA*4+1+1
         jc        GetMous9
         shr       cx,1
         shr       cx,1

         shr       dx,1
         shr       dx,1
         shr       dx,1
         dec       dx
         shr       dx,1
         shr       dx,1

         mov       dh,dl                    ; ý dek
         mov       dl,cl                    ; pozice

         clc

GetMous9:pop       cx
         pop       bx
         pop       ax
         ret

GetMouse ENDP

; -----------------------------------------------------------------------------
;        inicializace myçi
; -----------------------------------------------------------------------------

InitMous PROC      NEAR

         and       byte ptr ds:[Param],not bit1+bit2 ; pý¡znak, §e nen¡ myç

; ------ z kaz obsluhy pro Hercules

         cmp       byte ptr ds:[TypCard],1  ; je Hercules ?
         je        IniMous9                 ; je Hercules - z kaz

; ------ test platnosti adresy INT 33h

         mov       ax,3533h
         int       21h                      ; poskytnut¡ adresy INT 33h
         cmp       bx,-2
         je        IniMous9                 ; neplatn  adresa INT 33h
         mov       ax,es
         cmp       ax,70h
         jb        IniMous9                 ; neplatn  adresa INT 33h

; ------ test instalace myçi

         mov       al,0
         call      Mouse                    ; reset a test myçi
         inc       ax
         jnz       IniMous9                 ; nen¡ myç
         or        byte ptr ds:[Param],bit1 ; pý¡znak instalace myçi

; ------ definice okna pro myç

         xor       cx,cx
         mov       dx,ds:[DispSirX]         ; ç¡ýka obrazovky
         dec       dx
         mov       al,7
         call      Mouse                    ; horizont ln¡ rozmØry obrazovky
         xor       cx,cx
         mov       dx,ds:[DispVysY]         ; vìçka obrazovky
         dec       dx                       ; posledn¡ linka obrazovky
         mov       al,8
         call      Mouse                    ; vertik ln¡ rozmØry obrazovky

; ------ definice obr zku myçi

         mov       al,9
         xor       bx,bx
         xor       cx,cx
         mov       dx,offset KurzMous       ; obr zek kurzoru myçi
         push      ds
         pop       es
         call      Mouse                    ; definice obr zku kurzoru myçi

; ------ definice polohy kurzoru myçi (doprostýed obrazovky)

         mov       cx,ds:[DispSirX]         ; ç¡ýka obrazovky
         shr       cx,1                     ; stýed obrazovky
         mov       dx,ds:[DispVysY]         ; vìçka obrazovky
         shr       dx,1                     ; stýed obrazovky
         mov       al,4
         call      Mouse                    ; nastaven¡ pozice kurzoru my¨i

; ------ vypr zdØn¡ Ÿ¡taŸe stisk… tlaŸ¡tek myçi

         mov       al,5
         xor       bx,bx                    ; lev‚ tlaŸ¡tko
         call      Mouse                    ; test lev‚ho tlaŸ¡tka

         mov       al,5
         mov       bx,1                     ; prav‚ tlaŸ¡tko
         call      Mouse                    ; test prav‚ho tlaŸ¡tka

IniMous9:ret

InitMous ENDP

; -----------------------------------------------------------------------------
;        zapnut¡ kurzoru myçi
; -----------------------------------------------------------------------------

MouseOn  PROC      NEAR

         test      byte ptr ds:[Param],bit2 ; je kurzor myçi ji§ zapnut ?
         jnz       MouseOn2                 ; kurzor myçi je ji§ zapnut
         or        byte ptr ds:[Param],bit2 ; pý¡znak zapnut¡ kurzoru myçi
         test      byte ptr ds:[Param],bit1 ; je myç nainstalov na ?
         jz        MouseOn2                 ; myç nen¡ nainstalov na
         push      ax
         mov       al,1
         call      Mouse                    ; zapnut¡ kurzoru
         pop       ax
MouseOn2:ret

MouseOn  ENDP

; -----------------------------------------------------------------------------
;        vypnut¡ kurzoru myçi
; -----------------------------------------------------------------------------

MouseOff PROC      NEAR

         test      byte ptr ds:[Param],bit2 ; je kurzor myçi ji§ zapnut ?
         jz        MouseOf2                 ; kurzor myçi nen¡ zapnut
         and       byte ptr ds:[Param],not bit2 ; pý¡znak vypnut¡ kurzoru myçi
         test      byte ptr ds:[Param],bit1 ; je myç nainstalov na ?
         jz        MouseOf2                 ; myç nen¡ nainstalov na
         push      ax
         mov       al,2
         call      Mouse                    ; vypnut¡ kurzoru
         pop       ax
MouseOf2:ret

MouseOff ENDP

; -----------------------------------------------------------------------------
;        obsluha myçi (INT 33h)
; -----------------------------------------------------------------------------

Mouse    PROC      NEAR

         push      si
         push      di
         push      bp
         push      ds
         push      es

         sti
         mov       ah,0
         int       33h
         sti

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         ret

Mouse    ENDP

; *****************************************************************************
;
;                            R…zn‚ procedury
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        zobrazen¡ chybov‚ho hl çen¡ BP
; -----------------------------------------------------------------------------

DispErr  PROC      NEAR

         push      ax
         push      dx

         cmp       word ptr ds:[CitChyb],0  ; je to prvn¡ chyba ?
         jne       DispErr2                 ; nen¡ to prvn¡ chyba

         mov       dx,offset UvTxt
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu

DispErr2:push      di
         push      es
         mov       di,offset ChybErr2
         mov       word ptr ds:[di-3],"  "
         mov       byte ptr ds:[di-4]," "
         mov       ax,ds:[CitRad]           ; ukazatel Ÿ¡sla ý dku
         call      DekNumR                  ; dek¢dov n¡ Ÿ¡sla ý dku
         pop       es
         pop       di

         mov       dx,offset ChybErr
         mov       ah,9
         int       21h                      ; zobrazen¡ prvn¡ Ÿ sti hl çen¡

         mov       dx,bp
         mov       ah,9
         int       21h                      ; chybov‚ hl çen¡

         inc       word ptr ds:[CitChyb]    ; Ÿ¡taŸ chyb

         pop       dx
         pop       ax
         ret

DispErr  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ Ÿ¡sla AX od prav‚ho okraje ES:DI
; -----------------------------------------------------------------------------

DekNumR  PROC      NEAR

         push      ax
         push      cx
         push      dx
         push      di

         mov       cx,10
DekNumR1:xor       dx,dx
         div       cx
         add       dl,"0"
         dec       di
         mov       es:[di],dl
         or        ax,ax
         jnz       DekNumR1

         pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

DekNumR  ENDP

; -----------------------------------------------------------------------------
;        konverze na velk‚ p¡smeno
; -----------------------------------------------------------------------------

UpCase   PROC      NEAR

         cmp       al,"a"
         jb        UpCase2
         cmp       al,"z"
         ja        UpCase2
         sub       al,32
UpCase2: ret

UpCase   ENDP

; *****************************************************************************
;
;                             Obsluha kl vesnice
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        test pýeruçen¡ -> CY=je pýeruçen¡
; -----------------------------------------------------------------------------

TestEsc  PROC      NEAR

         push      ax
         mov       ah,1
         int       16h

TestEsc2:pop       ax
         ret

TestEsc  ENDP

; -----------------------------------------------------------------------------
;        vstup znaku z kl vesnice -> AX
; -----------------------------------------------------------------------------

InpChr   PROC      NEAR

         mov       ah,0
         int       16h
         ret

InpChr   ENDP

; -----------------------------------------------------------------------------
;        test znaku z kl vesnice -> AX znak, CY=nen¡ znak
; -----------------------------------------------------------------------------

TestChr  PROC      NEAR

         mov       ah,1
         int       16h
         clc
         jnz       TestChr2
         stc
TestChr2:ret

TestChr  ENDP

; -----------------------------------------------------------------------------
;        vypr zdnØn¡ bufferu kl vesnice
; -----------------------------------------------------------------------------

FlushChr PROC      NEAR

         push      ax

FlshChr1:call      TestChr                  ; test znaku z kl vesnice
         jc        FlshChr2                 ; nen¡ znak z kl vesnice
         call      InpChr                   ; vypr zdnØn¡ bufferu kl vesnice
         jmp       short FlshChr1

FlshChr2:pop       ax
         ret

FlushChr ENDP

; *****************************************************************************
;
;                         Obsluha hodin a zvuku
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        zapnut¡ vìstupu na reproduktor - dØlic¡ konstanta BX
; -----------------------------------------------------------------------------

SoundOn  PROC      NEAR

; ------ £schova registr…

         cli
         push      ax

; ------ nastaven¡ frekvence

         mov       al,0b6h                  ; povel pro nastaven¡ dØliŸky
         out       [43h],al                 ; nastaven¡ m¢du dØliŸky

         mov       al,bl                    ; dØlic¡ konstanta LOW
         out       [42h],al                 ; nastaven¡ konstanty LOW
         mov       al,bh                    ; dØlic¡ konstanta HIGH
         out       [42h],al                 ; nastaven¡ konstanty HIGH

; ------ zapnut¡ vìstupu na reproduktor

         in        al,[61h]
         or        al,bit0+bit1             ; zapnut¡ vìstupu na reproduktor
         out       [61h],al

; ------ n vrat registr…

         pop       ax
         sti
         ret

SoundOn  ENDP

; -----------------------------------------------------------------------------
;        vypnut¡ vìstupu na reproduktor
; -----------------------------------------------------------------------------

SoundOff PROC      NEAR

; ------ £schova registr…

         cli
         push      ax

; ------ vypnut¡ vìstupu na reproduktor

         in        al,[61h]
         and       al,not bit0+bit1
         out       [61h],al                 ; vypnut¡ vìstupu na reproduktor

; ------ nastaven¡ standardn¡ frekvence gener toru

         mov       al,0b6h                  ; povel pro nastaven¡ dØliŸky
         out       [43h],al                 ; nastaven¡ m¢du dØliŸky
         mov       al,5                     ; konstanta asi tak 920 Hz
         out       [42h],al                 ; konstanta - n¡§ç¡ bajt
         out       [42h],al                 ; konstanta - vyçç¡ bajt

; ------ n vrat registr…

         pop       ax
         sti
         ret

SoundOff ENDP

; -----------------------------------------------------------------------------
;        tabulka dØlic¡ch konstant t¢n…
; -----------------------------------------------------------------------------

TabTon   label     word                     ; tabulka pro nastaven¡ t¢n…
         dw        36485,34437,32505,30680,28958,27333 ; okt va 0 (1 a§ 12)
         dw        25799,24351,22984,21694,20477,19327
         dw        18243,17219,16252,15340,14479,13667 ; okt va 1 (13 a§ 24)
         dw        12899,12175,11492,10847,10238,9664
         dw        9121,8609,8126,7670,7240,6833       ; okt va 2 (25 a§ 36)
         dw        6450,6088,5746,5424,5119,4832
         dw        4561,4305,4063,3835,3620,3417       ; okt va 3 (37 a§ 48)
         dw        3225,3044,2873,2712,2560,2416
         dw        2280,2152,2032,1918,1810,1708       ; okt va 4 (49 a§ 60)
         dw        1612,1522,1437,1356,1280,1208
         dw        1140,1076,1016,959,905,854          ; okt va 5 (61 a§ 72)
         dw        806,761,718,678,640,604
         dw        570,538,508,479,452,427             ; okt va 6 (73 a§ 84)
         dw        403,380,359,339,320,302
         dw        285,269,254,240,226,214             ; okt va 7 (85 a§ 96)
         dw        202,190,180,169,160,151
         dw        143,135,127,120,113,107             ; okt va 8 (97 a§ 108)
         dw        101,95,90,85,80,75
         dw        71,67,63,60,57,53,50,48,45,42,40,38 ; okt va 9 (109 a§ 120)

; -----------------------------------------------------------------------------
;        Ÿek n¡ na impuls hodin s aktualizac¡ zobrazen¡ Karla
; -----------------------------------------------------------------------------

CekKrokD PROC      NEAR

         test      byte ptr ds:[Param],bit4 ; je pýeruçen¡ cyklu ?
         jnz       CekKrkD3                 ; je pýeruçen¡ cyklu
         cmp       word ptr ds:[BlokIf],0   ; je blokov n¡ pý¡kaz… IF ?
         jne       CekKrkD3                 ; je blokov n¡ pý¡kaz…

         test      byte ptr ds:[Param],bit0 ; je re§im TURBO ?
         jz        CekKrkD2                 ; nen¡ re§im TURBO
         call      MazKar                   ; vymaz n¡ Karla
         jmp       short CekKrok

CekKrkD2:call      DispKar                  ; zobrazen¡ Karla
CekKrkD3:jmp       short CekKrok

CekKrokD ENDP

; -----------------------------------------------------------------------------
;        Ÿek n¡ na jeden impuls hodin (pro jeden krok) -> CY=pýeruçen¡ operace
; -----------------------------------------------------------------------------

CekKrok  PROC      NEAR

         test      byte ptr ds:[Param],bit4 ; je pýeruçen¡ cyklu ?
         jnz       CekKrok8                 ; je pýeruçen¡ cyklu
         cmp       word ptr ds:[BlokIf],0   ; je blokov n¡ pý¡kaz… IF ?
         jne       CekKrok8                 ; je blokov n¡ pý¡kaz…

         call      MouseOn                  ; zapnut¡ kurzoru myçi

         push      ax
         mov       ah,1
         int       16h
         clc
         jz        CekKrok5                 ; nen¡ znak z kl vesnice
         mov       ah,0
         int       16h                      ; naŸten¡ znaku z kl vesnice
         cmp       al,27
         je        CekKrok4                 ; pýeruçen¡ ESC
         or        ax,ax
         jnz       CekKrok5
CekKrok4:stc                                ; pý¡znak pýeruçen¡
CekKrok5:pop       ax
         jc        CekKrok8                 ; pýeruçen¡ operace

         push      ax
         push      es
         xor       ax,ax
         mov       es,ax
         test      byte ptr es:[417h],bit0+bit1 ; je pýesmykaŸ SHIFT ?
         pop       es
         pop       ax
         jnz       CekKrok8                 ; je pýesmykaŸ SHIFT

         mov       byte ptr cs:[TimeKrok],1 ; nastaven¡ Ÿ¡taŸe
CekKrok6:sti
         cmp       byte ptr cs:[TimeKrok],0
         jne       CekKrok6
         clc
CekKrok8:ret

CekKrok  ENDP

; -----------------------------------------------------------------------------
;        obsluha NT 23h a INT 24h
; -----------------------------------------------------------------------------

INT24    PROC      FAR

         mov       al,0                     ; ignorovat chyby
INT23:   iret

INT24    ENDP

; -----------------------------------------------------------------------------
;        Obsluha Ÿasov n¡ INT 08h
; -----------------------------------------------------------------------------

Int08    PROC      FAR

; ------ Ÿ¡taŸ kroku pohybu Karla

         cmp       byte ptr cs:[TimeKrok],0 ; je Ÿ¡taŸ Ÿasu pro jeden krok ?
         je        Int081                   ; nen¡ Ÿ¡taŸ Ÿasu pro krok
         dec       byte ptr cs:[TimeKrok]   ; sn¡§en¡ Ÿ¡taŸe Ÿasu

; ------ Ÿ¡taŸ zobrazen¡ textu hl çen¡

Int081:  cmp       word ptr cs:[TimeTxt],1
         jbe       Int082
         dec       word ptr cs:[TimeTxt]

; ------ Ÿ¡taŸ d‚lky t¢nu

Int082:  cmp       byte ptr cs:[CitTon],0   ; je Ÿ¡taŸ doby t¢nu vynulov n ?
         je        Int083                   ; Ÿ¡taŸ doby t¢nu je ji§ vynulov n
         dec       byte ptr cs:[CitTon]     ; sn¡§en¡ Ÿ¡taŸe doby t¢nu
         jnz       Int085                   ; dalç¡ Ÿek n¡
         call      SoundOff                 ; konec t¢nu-vypnut¡ zvuk.gener toru

; ------ naŸten¡ dalç¡ho t¢nu k pýehr t¡

Int083:  push      ax
         push      bx
         push      si
         push      ds

         push      cs
         pop       ds
         mov       si,ds:[UkazMel]          ; ukazatel melodie
         or        si,si                    ; je melodie ?
         jz        Int084                   ; nen¡ melodie

         cld
         lodsw                              ; naŸten¡ t¢nu a d‚lky
         mov       ds:[UkazMel],si          ; novì ukazatel melodie
         cmp       al,0                     ; je konec ?
         jne       Int0831                  ; nen¡ konce
         mov       word ptr ds:[UkazMel],0  ; pý¡znak konce
         jmp       short Int084

Int0831: mov       ds:[CitTon],al           ; Ÿ¡taŸ pro vypnut¡ t¢nu
         mov       bl,ah                    ; vìçka t¢nu
         mov       bh,0
         shl       bx,1                     ; Ÿ¡slo t¢nu * 2
         jz        Int084                   ; je mezera
         mov       bx,ds:[bx+TabTon-2]      ; dØlic¡ konstanta
         call      SoundOn                  ; zapnut¡ t¢nu

Int084:  pop       ds
         pop       si
         pop       bx
         pop       ax

Int085:

         jmp       dword ptr cs:[Old08]

Int08    ENDP

Old08    dd        0
TimeKrok db        0                        ; Ÿ¡taŸ Ÿasu pro jeden krok
TimeTxt  dw        0                        ; Ÿ¡taŸ pro vypnut¡ textu
CitTon   db        0                        ; Ÿ¡taŸ pro vypnut¡ t¢nu hudby
UkazMel  dw        0                        ; ukazatel melodie (0=nen¡)
                                            ; melodie: 1 bajt d‚lka, 0=konec
                                            ;          1 bajt t¢n, 0=mezera

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                                  Data
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
; ------ fonty

Font08   label     byte
INCLUDE  font08.asm

Font14   label     byte
INCLUDE  font14.asm

Font16   label     byte
INCLUDE  font16.asm

AdrFont  dw        Font16                   ; adresa pou§it‚ho fontu
VysFont  dw        16                       ; vìçka pou§it‚ho fontu

; ------ texty hl çen¡

UvTxt    db        'KARLIK V1.0; (c) Miroslav Nemecek 1997',13,10,'$'
ZbyvMem  db        'Zbyvajici volna pamet:    '
ZbyvMem2 db        ' KB',13,10,'$'

MemErr   db        'nedostatek pameti ke startu programu !',13,10,'$'
ICOErr   db        'nepovolene znaky ve jmenu ikony '
 ICOErr2  db        13 dup(" "),13,10,'$'
ICODErr  db        'nenalezena implicitni ikona '
 ICODErr2 db        13 dup(" "),13,10,'$'
NeznErr  db        'neznamy prikaz '
 NeznErr2 db        30 dup(" "),13,10,'$'
FndErr   db        'Nenalezen vstupni soubor programu !',13,10,'$'
ProcErr  db        'prikazy musi byt definovany pred hlavnim programem !',13,10,'$'

ChybErr  db        'CHYBA [    '
ChybErr2 db        ']: $'

CitRad   dw        0                        ; ukazatel Ÿ¡sla ý dku

; ------ n raz do zdi

NarazTxt db        35,'  ****  AU - NARAZIL JSEM !  ****  '
NarazTon db        M32,MG+MO4
         db        M32,ME+MO4
         db        M32,MC+MO4
         db        M32,ME+MO4
         db        M32,MG+MO4
         db        0

; ------ polo§en¡ pýedmØtu na okraj

OkrajTxt db        39,'  ****  NEMOHU - JE TAM OKRAJ !  ****  '
OkrajTon db        M32,MG+MO4
         db        M32,ME+MO4
         db        M32,MC+MO4
         db        M32,MG+MO3
         db        M32,ME+MO3
         db        0

; ------ implicitn¡ ikony

ICODef   label     byte
         db        3,'RAM'                  ; r m kolem hrac¡ plochy
ICORam   dw        0
         db        8,'RAM_MENU'             ; r m kolem menu
ICORamM  dw        0
         db        8,'RAM_TEXT'             ; r m kolem textu
ICORamT  dw        0
         db        3,'NIC'                  ; plocha (uprostýed)
ICONic   dw        0
         db        4,'MENU'                 ; plocha menu
ICOMenu  dw        0
         db        8,'KARLIK_P'             ; Karl¡k zepýedu
ICOKarP  dw        0
         db        8,'KARLIK_Z'             ; Karl¡k zezadu
ICOKarZ  dw        0
         db        8,'KARLIK_L'             ; Karl¡k zleva
ICOKarL  dw        0
         db        8,'KARLIK_R'             ; Karl¡k zprava
ICOKarR  dw        0
         db        3,'ZED'                  ; zeÔ
ICOZed   dw        0
         db        5,'VLEVO'                ; ikona vlevo
ICOVlevo dw        0
         db        6,'VPRAVO'               ; ikona vpravo
ICOVprav dw        0
         db        4,'VZAD'                 ; ikona vzad
ICOVzad  dw        0
         db        4,'KROK'                 ; ikona kroku
ICOKrok  dw        0
         db        5,'KONEC'                ; konec programu
ICOKonec dw        0
         db        4,'DISK'                 ; disketa - souborov‚ funkce
ICODisk  dw        0
         db        5,'MALUJ'                ; ikona menu pro malov n¡
ICOMaluj dw        0

ICODef0  label     byte

; ------ pý¡kazy

Prikazy  label     byte
         db        1,' '                    ; 1: kreslen¡ obr zku
         db        6,'OPAKUJ'               ; 2: OPAKUJ
         db        1,'('                    ; 3: lev  z vorka
         db        1,')'                    ; 4: prav  z vorka
         db        1,'!'                    ; 5: definice/proveden¡ pý¡kazu
         db        6,'POZICE'               ; 6: POZICE
         db        4,'KROK'                 ; 7: KROK
         db        5,'VLEVO'                ; 8: VLEVO
         db        6,'VPRAVO'               ; 9: VPRAVO
         db        4,'VZAD'                 ; 10: VZAD
         db        5,'CEKEJ'                ; 11: CEKEJ
         db        6,'RYCHLE'               ; 12: RYCHLE
         db        6,'POMALU'               ; 13: POMALU
         db        5,'SEVER'                ; 14: SEVER
         db        3,'JIH'                  ; 15: JIH
         db        6,'VYCHOD'               ; 16: VYCHOD
         db        5,'ZAPAD'                ; 17: ZAPAD
         db        6,'JESTLI'               ; 18: JESTLI
         db        5,'JINAK'                ; 19: JINAK
         db        4,'NENI'                 ; 20: NENI
         db        6,'PRERUS'               ; 21: PRERUS
         db        5,'DOKUD'                ; 22: DOKUD
Prikazy0 db        0

Prikazy2 label     byte
         db        1,' '                    ; 1: kreslen¡ obr zku
         db        1,'@'                    ; 2: OPAKUJ
         db        1,'('                    ; 3: lev  z vorka
         db        1,')'                    ; 4: prav  z vorka
         db        1,'!'                    ; 5: definice/proveden¡ pý¡kazu
         db        1,'P'                    ; 6: POZICE
         db        1,'K'                    ; 7: KROK
         db        1,'L'                    ; 8: VLEVO
         db        1,'R'                    ; 9: VPRAVO
         db        1,'A'                    ; 10: VZAD
         db        1,'C'                    ; 11: CEKEJ
         db        1,'Y'                    ; 12: RYCHLE
         db        1,'U'                    ; 13: POMALU
         db        1,'S'                    ; 14: SEVER
         db        1,'J'                    ; 15: JIH
         db        1,'V'                    ; 16: VYCHOD
         db        1,'Z'                    ; 17: ZAPAD
         db        1,'I'                    ; 18: JESTLI
         db        1,'E'                    ; 19: JINAK
         db        1,'~'                    ; 20: NENI
         db        1,'B'                    ; 21: PRERUS
         db        1,'D'                    ; 22: DOKUD
         db        0

; ------ obsluha pý¡kaz… pýi prov dØn¡ programu

PrikazX  label     word
         dw        KarKresl                 ; 1: kreslen¡ obr zku
         dw        KarOpak                  ; 2: OPAKUJ
         dw        KarLZav                  ; 3: lev  z vorka
         dw        KarNop                   ; 4: prav  z vorka
         dw        KarProc                  ; 5: definice/proveden¡ pý¡kazu
         dw        KarPoz                   ; 6: POZICE
         dw        KarKrok                  ; 7: KROK
         dw        KarVlevo                 ; 8: VLEVO
         dw        KarVprav                 ; 9: VPRAVO
         dw        KarVzad                  ; 10: VZAD
         dw        CekKrokD                 ; 11: CEKEJ
         dw        KarRych                  ; 12: RYCHLE
         dw        KarPom                   ; 13: POMALU
         dw        KarSev                   ; 14: SEVER
         dw        KarJih                   ; 15: JIH
         dw        KarVych                  ; 16: VYCHOD
         dw        KarZap                   ; 17: ZAPAD
         dw        KarJest                  ; 18: JESTLI
         dw        KarNop                   ; 19: JINAK
         dw        KarNop                   ; 20: NENI
         dw        KarPrer                  ; 21: PRERUS
         dw        KarDok                   ; 22: DOKUD

; ------ pracovn¡ ukazatele

Pole     dw        PSIRKA*PVYSKA dup(0)     ; hrac¡ pole (obsahuje adresy ikon)

KarelOPz dw        0                        ; star  zobrazen  pozice Karla
KarelPoz dw        0                        ; aktu ln¡ ý dek a pozice Karla
KarelOSm db        0                        ; starì smØr Karla
KarelSme db        0                        ; smØr Karla
                                            ;  0 = dol… (jih)
                                            ;  1 = vpravo (vìchod)
                                            ;  2 = nahoru (sever)
                                            ;  3 = vlevo (z pad)

Param    db        0                        ; parametry
                                            ;   bit 0: 1=je TURBO re§im
                                            ;   bit 1: 1=je myç
                                            ;   bit 2: 1=kurzor myçi zapnut
                                            ;   bit 3: 1=KAREL je zobrazen
                                            ;   bit 4: 1=je pýeruçen¡ cyklu

                                            ;   bit 7: 1=je pýeruçen¡ ESC

TypCard  db        0                        ; typ videokarty
                                            ;   0=nezadan
                                            ;   1=Hercules
                                            ;   2=CGA
                                            ;   3=EGA
                                            ;   4=VGA
AdrVRAM  dw        0                        ; adresa videopamØti (segment)
;Hrana1   db        2                        ; hranice Mono pro çedou barvu
;Hrana1X  db        20h                      ; hranice Mono pro çedou barvu * 16
;Hrana2   db        8                        ; hranice Mono pro b¡lou barvu
;Hrana2X  db        80h                      ; hranice Mono pro b¡lou barvu * 16

DispSirX dw        0                        ; ç¡ýka obrazovky (bod…)
DispSirB dw        0                        ; ç¡ýka obrazovky (bajt…)
DispVysY dw        0                        ; vìçka obrazovky (bod…)

CitBarev dw        16 dup(0)                ; Ÿ¡taŸ rozlo§en¡ barev

; ------ registry pro inicializaci grafick‚ho re§imu karty HGC

HGCTabR  db        53                       ; 0: horizont lnØ celkem-1
         db        HercSir/2   ;40          ; 1: horizont lnØ zobrazeno
         db        HercSir/2+1 ;44          ; 2: pozice HSYNC
         db        7                        ; 3: ç¡ýka HSYNC
         db        91                       ; 4: vertik lnØ celkem
         db        2           ;1           ; 5: vertik ln¡ korekce
         db        88                       ; 6: vertik lnØ zobrazeno
         db        88                       ; 7: vertik ln¡ pozice
         db        2                        ; 8: m¢d prokl d n¡
         db        3                        ; 9: poŸet linek na ý dek
         db        0                        ; 10: poŸ tek kurzoru
         db        0           ;3           ; 11: konec kurzoru
         db        0                        ; 12: adresa poŸ tku HIGH
         db        0                        ; 13: adresa poŸ tku LOW
         db        0                        ; 14: kurzor HIGH
         db        0                        ; 15: kurzor LOW

; ------ obr zek kurzoru myçi

KurzMous dw        0111111111111111b        ; obr zek kurzoru myçi
         dw        0011111111111111b
         dw        0001111111111111b
         dw        0000111111111111b
         dw        0000011111111111b
         dw        0000001111111111b
         dw        0000000111111111b
         dw        0000000011111111b
         dw        0000000001111111b
         dw        0000001111111111b
         dw        0010001111111111b
         dw        0110000111111111b
         dw        1111000111111111b
         dw        1111000011111111b
         dw        1111100011111111b
         dw        1111100011111111b

         dw        0000000000000000b
         dw        0000000000000000b
         dw        0100000000000000b
         dw        0110000000000000b
         dw        0111000000000000b
         dw        0111100000000000b
         dw        0111110000000000b
         dw        0111111000000000b
         dw        0111100000000000b
         dw        0100100000000000b
         dw        0000100000000000b
         dw        0000010000000000b
         dw        0000010000000000b
         dw        0000001000000000b
         dw        0000001000000000b
         dw        0000000000000000b

; -----------------------------------------------------------------------------
; Na zaŸ tku bufferu je seznam jmen ikon (vçe velk  p¡smena):
;                0: (1) d‚lka jm‚na ikony
;                1: (x) jm‚no ikony
;              1+x: (2) adresa ikony v pamØti (segment)
;
; Za seznamem jmen ikon n sleduje pýelo§enì program.
;
; Od konce datov‚ho bufferu jsou ukl d ny ikony. Ka§d  zab¡r  640 Bajt…
; (4 barevn‚ roviny + maska 32*32, horizont lnØ 4 bajty, 1 rovina=32*32/8=128 B)
; -----------------------------------------------------------------------------
; Ve f z¡ naŸ¡t n¡ programu je za seznam ikon ukl d n pýelo§enì program.
; Na zaŸ tku programu jsou definice procedur:
;       (2) adresa dalç¡ procedury v bufferu
;       (1) d‚lka jm‚na procedury
;       (x) jm‚no procedury
;       (...) pý¡kaz nebo v¡ce pý¡kaz… v z vorce
; -----------------------------------------------------------------------------
; Pýi prov dØn¡ programu je mezi koncem programu a zaŸ tkem symbol… buffer
; n vratovìch adres cykl… OPAKUJ a DOKUD
; -----------------------------------------------------------------------------

DataSegm dw        0                        ; adresa zaŸ tku datov‚ho segmentu
DataEnd  dw        0                        ; adresa konce datov‚ho segmentu
DataProg dw        0                        ; adresa zaŸ tku programu (segment)
UkazProg dw        0                        ; ukazatel zpracov n¡ programu (offset)
DataNum  dw        0                        ; poŸet bajt… programu v bufferu
MainProg dw        0                        ; offset hlavn¡ho programu
ProcNum  dw        0                        ; poŸet procedur v programu
DataICOE dw        0                        ; konec symbol… ikon (offset)
DataICO  dw        0                        ; adresa zaŸ tku bufferu ikon (segment)
                                            ;  (posouv  se shora dol…, ikony
                                            ;   se ukl daj¡ shora dol…)
DataICON dw        0                        ; poŸet ikon v segmentu
                                            ;  (640 B na ikonu)

DataStru dw        0                        ; adresa bufferu struktur

ICOAll   db        '*.ICO',0                ; hled n¡ vçech ikon
DTA      db        44 dup(0)                ; buffer DTA souboru

CitChyb  dw        0                        ; Ÿ¡taŸ chyb pýekladu

VnorIf   dw        0                        ; Ÿ¡taŸ vnoýen¡ IF pro blokov n¡
VnorCas  dw        0                        ; Ÿ¡taŸ vnoýen¡ CASE pro blokov n¡
VnorFor  dw        0                        ; Ÿ¡taŸ vnoýen¡ FOR pro blokov n¡
VnorPrik dw        0                        ; Ÿ¡taŸ vnoýen¡ z vorek pro 1 pý¡kaz

; -----------------------------------------------------------------------------
;        soubor naŸten‚ho obr zku ICO
; -----------------------------------------------------------------------------

SoubICO  label     byte
                                           ;* z hlav¡ souboru
         dw        0                        ; (rezervov no)
         dw        1                        ; verze souboru
         dw        1                        ; poŸet obr zk… v souboru
         db        32                       ; ç¡ýka ikony (bod…)
         db        32                       ; vìçka ikony (bod…)
         db        16                       ; poŸet barev ikony
         db        0                        ; (rezervov no)
         dw        0,0                      ; (rezervov no)
         dd        744                      ; velikost dat
         dd        22                       ; velikost z hlav¡ souboru
                                          ;* z hlav¡ obr zku
         dd        40                       ; velikost z hlav¡ obr zku
         dd        32                       ; ç¡ýka a vìçka plochy obr zku
         dd        64                       ; velikost tabulky palet
         dw        1
         dd        4                        ; poŸet bit… na bod
         dw        0
         dd        640                      ; velikost data+maska obr zku
         dd        0,0,0,0
                                          ;* tabulka palet (poýad¡ B/G/R/0)
PalIco   db          0,  0,  0,  0          ;  0: Ÿern 
         db          0,  0,128,  0          ;  1: tmavØ Ÿerven 
         db          0,128,  0,  0          ;  2: tmavØ zelen 
         db          0,128,128,  0          ;  3: tmavØ §lut 
         db        128,  0,  0,  0          ;  4: tmavØ modr 
         db        128,  0,128,  0          ;  5: tmavØ purpurov 
         db        128,128,  0,  0          ;  6: tmavØ azurov 
         db        128,128,128,  0          ;  7: tmavØ çed 
         db        192,192,192,  0          ;  8: svØtle çed 
         db          0,  0,255,  0          ;  9: svØtle Ÿerven 
         db          0,255,  0,  0          ; 10: svØtle zelen 
         db          0,255,255,  0          ; 11: svØtle §lut 
         db        255,  0,  0,  0          ; 12: svØtle modr 
         db        255,  0,255,  0          ; 13: svØtle purpurov 
         db        255,255,  0,  0          ; 14: svØtle azurov 
         db        255,255,255,  0          ; 15: b¡l 

IcoBuff  db        512 dup(0)               ; buffer dat ikony

IcoMask  db        128 dup(0)               ; maska ikony

SoubIco2 label     byte

; ------ konverzn¡ tabulka barev (pýi konverzi palet)

PalKonv  db        16 dup(0)                ; konverze barev

; ------ palety

PalVGA   label     byte                     ; palety VGA
;                    modr 
;                    ³   zelen 
;                    ³   ³   Ÿerven 
;                    ³   ³   ³
         db          0,  0,  0              ;  0: Ÿern 
         db          0,  0, 32              ;  1: tmavØ Ÿerven 
         db          0, 32,  0              ;  2: tmavØ zelen 
         db          0, 32, 32              ;  3: tmavØ §lut 
         db         32,  0,  0              ;  4: tmavØ modr 
         db         32,  0, 32              ;  5: tmavØ purpurov 
         db         32, 32,  0              ;  6: tmavØ azurov 
         db         32, 32, 32              ;  7: tmavØ çed 
         db         48, 48, 48              ;  8: svØtle çed 
         db          0,  0, 63              ;  9: svØtle Ÿerven 
         db          0, 63,  0              ; 10: svØtle zelen 
         db          0, 63, 63              ; 11: svØtle §lut 
         db         63,  0,  0              ; 12: svØtle modr 
         db         63,  0, 63              ; 13: svØtle purpurov 
         db         63, 63,  0              ; 14: svØtle azurov 
         db         63, 63, 63              ; 15: b¡l 

; ------ palety EGA

PalEGA   label     byte
;                  sek.Ÿerven 
;                  ³sek.zelen 
;                  ³³sek.modr 
;                  ³³³Ÿerven 
;                  ³³³³zelen 
;                  ³³³³³modr 
;                  ³³³³³³
         db        000000b                  ;  0: Ÿern 
         db        000100b                  ;  1: tmavØ Ÿerven 
         db        000010b                  ;  2: tmavØ zelen 
         db        000110b                  ;  3: tmavØ §lut 
         db        000001b                  ;  4: tmavØ modr 
         db        000101b                  ;  5: tmavØ purpurov 
         db        000011b                  ;  6: tmavØ azurov 
         db        111000b                  ;  7: tmavØ çed 
         db        000111b                  ;  8: svØtle çed 
         db        100100b                  ;  9: svØtle Ÿerven 
         db        010010b                  ; 10: svØtle zelen 
         db        110110b                  ; 11: svØtle §lut 
         db        001001b                  ; 12: svØtle modr 
         db        101101b                  ; 13: svØtle purpurov 
         db        011011b                  ; 14: svØtle azurov 
         db        111111b                  ; 15: b¡l 
         db        000000b                  ; okol¡ obrazovky

; ------ obsluha vstupn¡ho programu

ProgStr  db        0,255 dup(0)             ; buffer ýetØzce programu + d‚lka
ProgFile db        'START.KAR',0            ; program
ProgIdnt dw        0                        ; identifik tor vstupn¡ho souboru
InpRead  dw        0                        ; offset ve Ÿtec¡m bufferu
InpNum   dw        0                        ; poŸet bajt… v bufferu
InpBuff  db        BUFFSIZE dup(?)          ; vstupn¡ buffer programu
InpRetB  db        0                        ; navr cenì znak do bufferu (0=nen¡)

         dw        256 dup(?)               ; pracovn¡ z sobn¡k
Zasob    label     word                     ; konec z sobn¡ku

Code     ENDS
         END       Start


Syntaxe:
-------
         KROK (K) ................... krok vpýed
         VLEVO (L) .................. vlevo vbok
         VPRAVO (R) ................. vpravo vbok
         VZAD (A) ................... Ÿelem vzad
         PRIKAZ jm‚no pý¡kaz (!) .... definice pý¡kazu
         jm‚no ...................... polo§en¡ pýedmØtu dan‚ho jm‚na (pýed n¡m)
                                      nebo vyvol n¡ pý¡kazu dan‚ho jm‚na
                                      (NIC=pr zdn‚ pol¡Ÿko, ZED=zeÔ, RAM=r m)
         RYCHLE (Y) ................. rychlì m¢d (nen¡ vidØt), "SuperKarl¡k"
         POMALU (U) ................. bØ§nì m¢d
         HUDBA melodie (H) .......... zahr n¡ zadan‚ melodie
         TICHO (O) .................. vypnut¡ zvuku
         JESTLI podm¡nka pý¡kaz (I) . podm¡nØnì pý¡kaz
         JESTLI podm¡nka pý¡kaz JINAK pý¡kaz (E) .. podm¡nØnì pý¡kaz (2. vØtev)
         OPAKUJ poŸet pý¡kaz (@) .... opakov n¡ pý¡kazu podle poŸtu
         DOKUD podm¡nka pý¡kaz (D) .. opakov n¡ pý¡kazu, dokud plat¡ podm¡nka
         PRERUS (B) ................. pýeruçen¡ prov dØn¡ cyklu OPAKUJ a DOKUD
         CEKEJ (C) .................. Ÿek n¡ po dobu 55 ms
         POZICE pozice ý dek (P) .... nastaven¡ pozice a ý dku
         () ......................... pr zdnì pý¡kaz
         (* text *) ................. pozn mka

                   V¡ce pý¡kaz… se zapisuje do z vorek ().

Podm¡nka:   jm‚no ...... pýedmØt zadan‚ho jm‚na (pýed Karl¡kem)
            NIC ........ pr zdn‚ pole
            ZED ........ pýed Karlem je zeÔ (nepr…chodnì pýedmØt) nebo r m
            RAM ........ pýed Karlem je r m plochy (popý. obr zek r mu)
            SEVER (S) .. otoŸenì na sever (nahoru)
            JIH (J) .... otoŸenì na jih (dol…)
            VYCHOD (V) . otoŸenì na vìchod (vpravo)
            ZAPAD (Z) .. otoŸenì na z pad (vlevo)
            JEKLAVESA .. byla stisknuta nØjak  kl vesa

            vìraz oper tor vìraz .... porovn n¡ dvou vìraz…
                       oper tor:   =, >, <, >=, <=, <>

Operace s podm¡nkami:  NENI (~)  negace n sleduj¡c¡ podm¡nky
                       A (&) ... operace AND
                       NEBO (|). operace NEBO

Z adres ýe se naŸtou vçechny soubory ICO a pou§ij¡ se jako pýedmØty - lze se
na nØ odkazovat jm‚nem (max. 8. znak… - p¡smena+Ÿ¡slice+_).

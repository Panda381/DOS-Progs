
; *****************************************************************************
;
;                                    Petý¡k
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

CPOZADI  EQU       3                        ; barva pozad¡

BUFFSIZE EQU       1024                     ; vstupn¡ buffer programu

bit0     EQU       1
bit1     EQU       2
bit2     EQU       4
bit3     EQU       8
bit4     EQU       10h
bit5     EQU       20h
bit6     EQU       40h
bit7     EQU       80h

HI       EQU       256

ICOSize  EQU       32*32*5/8                ; velikost ikony v bajtech

HistEdiM EQU       5                        ; velikost historie editace

HercSir  EQU       90                       ; ç¡ýka ý dku pro Hercules

; ------ intern¡ k¢dy

KOD_OBR  EQU       1                        ; 1: kreslen¡ obr zku
KOD_OPAK EQU       2                        ; 2: OPAKUJ
KOD_LZAV EQU       3                        ; 3: lev  z vorka
KOD_RZAV EQU       4                        ; 4: prav  z vorka
KOD_PROC EQU       5                        ; 5: definice/proveden¡ pý¡kazu
KOD_CARK EQU       6                        ; 6: Ÿ rka
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
KOD_MASK EQU       23                       ; 23: MASKA
KOD_VSYN EQU       24                       ; 24: VSYN
KOD_PROM EQU       25                       ; 25: PROMENNA
KOD_CISL EQU       26                       ; 26: CISLO
KOD_ROVN EQU       27                       ; 27: ROVNITKO
KOD_PLUS EQU       28                       ; 28: PLUS
KOD_MIN  EQU       29                       ; 29: MINUS
KOD_KRAT EQU       30                       ; 30: KRAT
KOD_DEL  EQU       31                       ; 31: DELENO
KOD_MENS EQU       32                       ; 32: MENSI
KOD_VETS EQU       33                       ; 33: VETSI
KOD_NAH  EQU       34                       ; 34: NAHODA
KOD_VEKT EQU       35                       ; 35: VEKTOR
KOD_MIST EQU       36                       ; 36: MISTNI
KOD_AND  EQU       37                       ; 37: A
KOD_OR   EQU       38                       ; 38: NEBO
KOD_POZX EQU       39                       ; 39: POZICEX
KOD_POZY EQU       40                       ; 40: POZICEY
KOD_KLAV EQU       41                       ; 41: KLAVESA
KOD_OBN  EQU       42                       ; 42: OBNOV
KOD_SMER EQU       43                       ; 43: SMER
KOD_HLAS EQU       44                       ; 44: HLASENI
KOD_PRED EQU       45                       ; 45: PREDMET
KOD_TEXT EQU       46                       ; 46: TEXT
KOD_POLE EQU       47                       ; 47: POLE
KOD_MOD  EQU       48                       ; 48: MOD
KOD_MUS  EQU       49                       ; 49: HUDBA

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

; ------ vytvoýen¡ bloku vektoru

         mov       bx,1000h                 ; velikost vektoru
         mov       ah,48h
         int       21h                      ; vytvoýen¡ vektoru
         jc        ChybaMem                 ; chyba pamØti
         mov       ds:[DataVekt],ax         ; adresa vektoru

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

; ------ inicializace gener toru n hody

         call      InitRnd                  ; inicializace gener toru n hody


Start2:


; ------ naŸten¡ vçech ikon do bufferu

         call      ReadICO                  ; naŸten¡ vçech ikon
         jc        ChybaMem                 ; chyba pamØti

; ------ inicializace implicitn¡ch ikon

         call      IniICOD                  ; inicializace implicitn¡ch ikon

         mov       ax,ds:[ICOZed]           ; ikona pro zeÔ
         mov       ds:[ICOLast],ax          ; naposledy zvolen  ikona
         mov       ax,ds:[ICONic]           ; pr zdn  ikona
         mov       ds:[EdiIHist],ax         ; historie editace ikon
         mov       ds:[EdiIHist+2],ax
         mov       ds:[EdiIHist+4],ax
         mov       ds:[EdiIHist+6],ax
         mov       ds:[EdiIHist+8],ax

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

; ------ instalace obsluhy INT 09h

         mov       ax,3509h
         int       21h                      ; poskytnut¡ adresy INT 09h
         mov       word ptr ds:[Old09],bx
         mov       word ptr ds:[Old09+2],es
         mov       dx,offset Int09
         mov       ax,2509h
         int       21h                      ; nastaven¡ nov‚ obsluhy INT 09h

; ------ instalace obsluhy INT 1Bh

         mov       ax,351Bh
         int       21h                      ; poskytnut¡ adresy INT 1Bh
         mov       word ptr ds:[Old1B],bx
         mov       word ptr ds:[Old1B+2],es
         mov       dx,offset Int1B
         mov       ax,251Bh
         int       21h                      ; nastaven¡ nov‚ obsluhy INT 1Bh

; ------ vymaz n¡ obrazovky

         call      Vymaz                    ; vymaz n¡ plochy
StartPrg:call      IniVymaz                 ; inicializaŸn¡ vymaz n¡ obrazovky

         mov       byte ptr ds:[TextRad],-1 ; neplatn‚ Ÿ¡slo ý dku pro text
         mov       byte ptr ds:[Rezim],1    ; pý¡znak bØhu programu
         call      DispMenu                 ; nov‚ zobrazen¡ menu
         call      NulBreak                 ; nulov n¡ pý¡znaku pýeruçen¡
         call      ExecPrg                  ; proveden¡ programu

         call      TstBreak                 ; bylo pýeruçen¡ programu ?
         jc        Start311                 ; bylo pýeruçen¡ programu
         test      byte ptr ds:[Param],bit4 ; je pýeruçen¡ programu ?
         jz        Start312                 ; nen¡ pýeruçen¡ programu

Start311:mov       ax,3
         int       10h                      ; inicializace videom¢du
         jmp       Konec1                   ; konec programu

Start312:

         call      TextRam                  ; vymaz n¡ textu hl çen¡
         call      PetPom                   ; nastaven¡ pomal‚ho Petra
         call      CekKrokD                 ; zobrazen¡ Petra

Start32: mov       word ptr ds:[BlokIf],0   ; odblokov n¡ pý¡kaz…
         and       byte ptr ds:[Param],not bit4 ; nen¡ pýeruçen¡ cyklu
         mov       byte ptr ds:[Rezim],2    ; pý¡znak bØ§n‚ho provozu
         call      DispMenu                 ; nov‚ zobrazen¡ menu
         call      DispPet                  ; zobrazen¡ Petra
Start4:  call      InpChar                  ; vstup znaku z kl vesnice
         jnc       Start4                   ; vypr zdnØn¡ bufferu kl vesnice

Start402:call      MouseOn
         call      NulBreak                 ; nulov n¡ pý¡znaku pýeruçen¡
         call      InpChar                  ; vstup znaku z kl vesnice
         jnc       Start408                 ; je znak z kl vesnice
         call      IntHlas                  ; maz n¡ hl çen¡
         call      GetMouse
         jc        Start402

         mov       ax,4800h                 ; vpýed
         cmp       dx,312h
         je        Start409
         mov       ax,5000h                 ; vzad
         cmp       dx,112h
         je        Start409
         mov       ax,4b00h
         cmp       dx,012h                  ; vlevo
         je        Start409
         mov       ax,4d00h                 ; vpravo
         cmp       dx,212h
         je        Start409
         mov       ax," "
         cmp       dx,412h
         je        Start409
         mov       ax,13
         cmp       dx,512h
         je        Start409
;         mov       al,"1"
;         cmp       dx,713h
;         je        Start409
         mov       ax,4300h                 ; F9: start
         cmp       dx,0b12h
         je        Start409

         mov       ax,3e00h                 ; F4: editace
         cmp       dx,0c12h
         je        Start409

         mov       ax,27
         cmp       dx,0d12h
         je        Start409

         cmp       dl,PSIRKA
         jae       Start402
         cmp       dh,PVYSKA
         jae       Start402
         mov       byte ptr ds:[TextRad],-1 ; neplatn‚ Ÿ¡slo ý dku pro text
         mov       ds:[PetrPoz],dx         ; nov  pozice Petra
         call      DispPet                  ; nov‚ zobrazen¡ Petra
         jmp       short Start402

Start408:

Start409: cmp       al,27
         jne       Start411
         jmp       Konec

Start411:cmp       ax,4800h
         jne       Start42
         call      PetKrok
Start418:jmp       Start32

Start42: cmp       ax,5000h
         jne       Start43
         call      PetVzad
         jmp       short Start418

Start43: cmp       ax,4b00h
         jne       Start44
         call      PetVlevo
         jmp       short Start418

Start44: cmp       ax,4d00h
         jne       Start45
         call      PetVprav
         jmp       short Start418

Start45: cmp       al,13                    ; ENTER
         je        Start5

         cmp       ax,3e00h                 ; F4: editace ikon
         je        Start6                   ; editace ikon

         cmp       ax,4300h                 ; F9
         jne       Start452
         jmp       StartPrg                 ; novì start programu

Start452:

         mov       bx,ds:[ICOLast]          ; naposledy zvolen  ikona
         cmp       al," "
         je        Start46

         call      UpCase
         sub       al,"A"
         jb        Start418
         cmp       al,26
         ja        Start418
         mov       ah,0                     ; AX = Ÿ¡slo ikony
         xchg      ax,bx
Start46: xchg      ax,bx
Start47: call      PetPredm                 ; polo§en¡ pýedmØtu AX
         jmp       short Start418

; ------ volba ikony

Start5:  call      VolIcon                  ; volba ikony
         jc        Start52                  ; pýeruçen¡ operace
         mov       ds:[ICOLast],ax          ; £schova ikony
         call      IniVymaz                 ; inicializaŸn¡ vymaz n¡ obrazovky
         jmp       short Start47            ; polo§en¡ pýedmØtu

Start52: call      IniVymaz                 ; inicializaŸn¡ vymaz n¡ obrazovky
         jmp       Start32

; ------ editace ikon

Start6:

         call      VolIcon                  ; volba ikony
         jc        Start52                  ; pýeruçen¡ operace
         call      EditIcon                 ; editace ikony AX
         jmp       short Start6             ; dalç¡ ikona


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

; ------ konec (sem se vrac¡ pýi pýeruçen¡ programu)

Konec1:  push      ds
         mov       ax,2508h
         lds       dx,ds:[Old08]            ; p…vodn¡ adresa INT 08h
         int       21h                      ; navr cen¡ adresy INT 08h
         pop       ds

         push      ds
         mov       ax,2509h
         lds       dx,ds:[Old09]            ; p…vodn¡ adresa INT 09h
         int       21h                      ; navr cen¡ adresy INT 09h
         pop       ds

         push      ds
         mov       ax,251Bh
         lds       dx,ds:[Old1B]            ; p…vodn¡ adresa INT 1Bh
         int       21h                      ; navr cen¡ adresy INT 1Bh
         pop       ds

         mov       ax,4c00h
         int       21h

; *****************************************************************************
;
;                             Obsluha Petra
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        nastaven¡ prvku pole
; -----------------------------------------------------------------------------

PetPole  PROC      NEAR

; ------ naŸten¡ souýadnice X pole -> CX

         call      VyrazPrg                 ; naŸten¡ souýadnice X pole
         jc        PetPole9                 ; chyba
         cmp       ax,PSIRKA                ; je platn  souýadnice ?
         jb        PetPole1                 ; souýadnice je OK
         mov       al,PSIRKA                ; pý¡znak pýeteŸen¡ souýadnice X

; ------ naŸten¡ souýadnice Y pole -> CX

PetPole1:push      ax                       ; AL = souýadnice X pole
         call      VyrazPrg                 ; naŸten¡ souýadnice Y pole
         pop       dx                       ; DL <- souýadnice X pole
         jc        PetPole9                 ; chyba
         mov       dh,al                    ; DH <- souýadnice Y pole
         cmp       ax,PVYSKA                ; je platn  souýadnice ?
         jb        PetPole2                 ; souýadnice je OK
         mov       dh,PVYSKA                ; pý¡znak pýeteŸen¡ souýadnice Y

; ------ vypuçtØn¡ znaku rovn¡tka

PetPole2:call      PetRovn                  ; vypuçtØn¡ znaku rovn¡tka

; ------ naŸten¡ Ÿ¡sla pýedmØtu

PetPole3:push      dx
         call      VyrazPrg                 ; naŸten¡ Ÿ¡sla pýedmØtu
         pop       dx
         jc        PetPole8                 ; nen¡ dalç¡ pýedmØt
         cmp       ax,ds:[DataICON]         ; je to platn‚ Ÿ¡slo ?
         jae       PetPole4                 ; nen¡ platn‚ Ÿ¡slo pýedmØtu

; ------ kontrola pýeteŸen¡ ukazatel… pole

         cmp       dh,PVYSKA                ; je platn  souýadnice Y ?
         jae       PetPole5                 ; souýadnice mimo rozsah
         cmp       dl,PSIRKA                ; je platn  souýadnice X ?
         jae       PetPole5                 ; souýadnice mimo rozsah

; ------ test blokov n¡ pý¡kaz…

         call      TestBlok                 ; test blokov n¡ programu
         jnz       PetPole4                 ; je blokov n¡ pý¡kaz…

; ------ ulo§en¡ pýedmØtu AX na pozici DX

         xchg      ax,bx                    ; BX <- pýedmØt
         mov       al,PSIRKA                ; poŸet pozic na ý dek
         mul       dh                       ; pýepoŸet ý dku na pozici
         add       al,dl                    ; pýiŸten¡ pozice
         adc       ah,0
         shl       ax,1                     ; offset v tabulce pole
         xchg      ax,bx                    ; BX <- offset v poli, AX <- pýedmØt
         mov       ds:[bx+Pole],ax          ; ulo§en¡ pýedmØtu

; ------ zobrazen¡ nov‚ho pýedmØtu

         call      PoleIcon                 ; zobrazen¡ pýedmØtu na nov‚ pozici

; ------ zvìçen¡ ukazatele pozice

PetPole4:inc       dx                       ; zvìçen¡ ukazatele pozice

; ------ test, zda bude dalç¡ polo§ka

PetPole5:call      PetCark                  ; naŸten¡ znaku Ÿ rky
         jnc       PetPole3                 ; je Ÿ rka - bude dalç¡ pýedmØt
PetPole8:clc                                ; pý¡znak operace OK
PetPole9:ret

PetPole  ENDP

; -----------------------------------------------------------------------------
;        obnoven¡ obr zku pýed Petý¡kem
; -----------------------------------------------------------------------------

PetObn   PROC      NEAR

         call      GetPred                  ; naŸten¡ pýedmØtu
         jnc       PetKres2                 ; je platnì pýedmØt
         clc                                ; pý¡znak operace OK
         ret

PetObn   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ obr zku zadan‚ho Ÿ¡slem -> CY=pýeruçen¡
; -----------------------------------------------------------------------------

PetNPre  PROC      NEAR

         call      VyrazPrg                 ; naŸten¡ Ÿ¡sla pýedmØtu
         jc        PetKres9                 ; chyba
         cmp       ax,ds:[DataICON]         ; je to platn‚ Ÿ¡slo ?
         jb        PetKres2                 ; je to platn‚ Ÿ¡slo
         mov       ax,ds:[ICONic]           ; pr zdn‚ pol¡Ÿko
         jmp       short PetKres2

PetNPre  ENDP

; -----------------------------------------------------------------------------
;        vykreslen¡ obr zku programem -> CY=pýeruçen¡
; -----------------------------------------------------------------------------

PetKresl PROC      NEAR

         call      WordPrg                  ; naŸten¡ adresy ikony
         jc        PetKres9                 ; chyba
PetKres2:call      TestBlok                 ; test blokov n¡ programu
         jnz       PetKres9                 ; je blokov n¡ programu
         call      PetPredm                 ; vykreslen¡ pýedmØtu
         jc        PetKres9                 ; chyba
         test      byte ptr ds:[Param],bit0 ; je TURBO re§im ?
         jnz       PetKres9                 ; je TURBO re§im
         call      CekKrokD                 ; Ÿek n¡ na jeden krok (CY=pýeruçen¡)
PetKres9:ret

PetKresl ENDP

; -----------------------------------------------------------------------------
;        vykreslen¡ obr zku s maskou -> CY=pýeruçen¡
; -----------------------------------------------------------------------------

PetMask  PROC      NEAR

         call      WordPrg                  ; naŸten¡ adresy ikony
         jc        PetMask9                 ; chyba
         call      TestBlok                 ; test blokov n¡ programu
         jnz       PetMask9                 ; je blokov n¡ programu
         call      PetMPred                 ; vykreslen¡ pýedmØtu
         jc        PetMask9                 ; chyba
         test      byte ptr ds:[Param],bit0 ; je TURBO re§im ?
         jnz       PetMask9                 ; je TURBO re§im
         call      CekKrokD                 ; Ÿek n¡ na jeden krok (CY=pýeruçen¡)
PetMask9:ret

PetMask ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ horizont ln¡ nov‚ pozice Petra -> CY=pýeruçen¡
; -----------------------------------------------------------------------------

PetPozX  PROC      NEAR

         call      PetRovn                  ; pýeskoŸen¡ znaku rovn¡tka

         call      VyrazPrg                 ; naŸten¡ pozice
         jc        PetPozX9                 ; chyba

         cmp       ax,PSIRKA                ; je pozice OK ?
         jb        PetPozX2                 ; pozice je OK
         mov       al,PSIRKA-1              ; omezen¡ pozice

PetPozX2:call      TestBlok                 ; test blokov n¡ programu
         jnz       PetPozX9                 ; je blokov n¡ programu

         mov       byte ptr ds:[TextRad],-1 ; neplatn‚ Ÿ¡slo ý dku pro text
         cmp       al,byte ptr ds:[PetrPoz] ; zmØnila se pozice ?
         je        PetPozX9                 ; pozice se nezmØnila
         mov       byte ptr ds:[PetrPoz],al ; nov  pozice Petra

         test      byte ptr ds:[Param],bit0 ; je TURBO re§im ?
         jnz       PetPozX9                 ; je TURBO re§im
         call      CekKrokD                 ; Ÿek n¡ na jeden krok (CY=pýeruçen¡)
PetPozX9:ret

PetPozX  ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ vertik ln¡ nov‚ pozice Petra -> CY=pýeruçen¡
; -----------------------------------------------------------------------------

PetPozY  PROC      NEAR

         call      PetRovn                  ; pýeskoŸen¡ znaku rovn¡tka

         call      VyrazPrg                 ; naŸten¡ pozice
         jc        PetPozY9                 ; chyba

         cmp       ax,PVYSKA                ; je ý dek OK ?
         jb        PetPozY2                 ; ý dek je OK
         mov       al,PVYSKA-1              ; omezen¡ ý dku

PetPozY2:call      TestBlok                 ; test blokov n¡ programu
         jnz       PetPozY9                 ; je blokov n¡ programu

         mov       byte ptr ds:[TextRad],-1 ; neplatn‚ Ÿ¡slo ý dku pro text
         cmp       al,byte ptr ds:[PetrPoz+1] ; zmØnil se ý dek ?
         je        PetPozY9                 ; ý dek se nezmØnil
         mov       byte ptr ds:[PetrPoz+1],al ; novì ý dek Petra

         test      byte ptr ds:[Param],bit0 ; je TURBO re§im ?
         jnz       PetPozY9                 ; je TURBO re§im
         call      CekKrokD                 ; Ÿek n¡ na jeden krok (CY=pýeruçen¡)
PetPozY9:ret

PetPozY  ENDP

; -----------------------------------------------------------------------------
;        polo§en¡ pýedmØtu AX pýed Petra -> CY=chyba, je okraj
; -----------------------------------------------------------------------------

PetPredm PROC      NEAR

; ------ £schova registr…

         push      bx
         push      dx
         xchg      ax,dx                    ; DX <- pýedmØt

; ------ pý¡çt¡ pozice Petra -> BX

         call      NextPoz                  ; pý¡çt¡ pozice -> BX
         jc        PetPred8                 ; chyba

; ------ ulo§en¡ pýedmØtu na novou pozici

         mov       al,PSIRKA                ; poŸet pozic na ý dek
         mul       bh                       ; pýepoŸet ý dku na pozici
         add       al,bl                    ; pýiŸten¡ pozice
         adc       ah,0
         shl       ax,1                     ; offset v tabulce pole
         xchg      ax,bx                    ; BX <- offset v poli
         mov       ds:[bx+Pole],dx          ; ulo§en¡ pýedmØtu

; ------ zobrazen¡ nov‚ho pýedmØtu

         xchg      ax,dx                    ; AX <- pýedmØt, DX <- souýadnice
         call      PoleIcon                 ; zobrazen¡ pýedmØtu na nov‚ pozici
         xchg      ax,dx
         clc                                ; pý¡znak operace OK
         jmp       short PetPred9

; ------ chyba operace - je okraj

PetPred8:push      si
         push      cx

         mov       si,offset OkrajTxt
         mov       ax,9b9bh                 ; barva
         mov       cx,2*18                  ; po§adovan  doba
         call      DispHlas                 ; zobrazen¡ hl çen¡
         cli
         mov       word ptr ds:[UkazMel],offset OkrajTon ; melodie
         mov       word ptr ds:[CitacMel],5 ; poŸet t¢n…
         sti

         pop       cx
         pop       si
         stc                                ; pý¡znak chyby operace

; ------ n vrat registr…

PetPred9:xchg      ax,dx                    ; AX <- n vrat pýedmØtu
         pop       dx
         pop       bx
         ret

PetPredm ENDP

; -----------------------------------------------------------------------------
;        n sleduj¡c¡ pozice -> BX, CY=je okraj (BH nebo BL je mimo rozsah)
; -----------------------------------------------------------------------------

NextPoz  PROC      NEAR

; ------ £schova registr…

         push      ax

; ------ ukazatel pozice Petra

         mov       ah,0
         mov       al,ds:[PetrSme]         ; smØr Petra
         mov       bx,ds:[PetrPoz]         ; ý dek a pozice Petra

; ------ smØr vpravo

         dec       ax                       ; 1 = vpravo
         jnz       NextPoz1                 ; nen¡ vpravo
         inc       bl                       ; smØr vpravo

; ------ smØr dol…

NextPoz1:dec       ax                       ; 2 = dol…
         jnz       NextPoz2
         inc       bh                       ; smØr dol…

; ------ smØr vlevo

NextPoz2:dec       ax                       ; 3 = vlevo
         jnz       NextPoz3
         dec       bl                       ; smØr vlevo

; ------ smØr nahoru

NextPoz3:dec       ax                       ; 4 = nahoru
         jnz       NextPoz4
         dec       bh                       ; smØr nahoru

; ------ kontrola pýeteŸen¡ pozice a ý dku

NextPoz4:cmp       bl,PSIRKA                ; kontrola pozice
         jae       NextPoz5                 ; chyba
         cmp       bh,PVYSKA                ; kontrola ý dku
NextPoz5:cmc                                ; CY=pýeteŸen¡ okraje

; ------ n vrat registr…

NextPoz9:pop       ax
         ret

NextPoz  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ pýedmØtu AX s maskou pýed Petra -> CY=chyba, je okraj
; -----------------------------------------------------------------------------

PetMPred PROC      NEAR

; ------ £schova registr…

         push      bx
         push      dx

; ------ pý¡çt¡ pozice Petra -> BX

         call      NextPoz                  ; pý¡çt¡ pozice -> BX
         jc        PetMPre4                 ; chyba

; ------ zobrazen¡ nov‚ho pýedmØtu

         mov       dx,bx                    ; DX <- souýadnice
         call      PoleMask                 ; zobrazen¡ pýedmØtu na nov‚ pozici
         clc                                ; pý¡znak operace OK
         jmp       short PetMPre8

; ------ chyba operace - je okraj

PetMPre4:push      si
         push      cx
         push      ax

         mov       si,offset OkrajTxt
         mov       ax,9b9bh                 ; barva
         mov       cx,2*18                  ; po§adovan  doba
         call      DispHlas                 ; zobrazen¡ hl çen¡
         cli
         mov       word ptr ds:[UkazMel],offset OkrajTon ; melodie
         mov       word ptr ds:[CitacMel],5 ; poŸet t¢n…
         sti

         pop       ax
         pop       cx
         pop       si
         stc                                ; pý¡znak chyby operace

; ------ n vrat registr…

PetMPre8:pop       dx
         pop       bx
         ret

PetMPred ENDP

; -----------------------------------------------------------------------------
;        otoŸen¡ na sever (-> CY=pýeruçen¡)
; -----------------------------------------------------------------------------

PetSev   PROC      NEAR

         call      TestBlok                 ; test blokov n¡ programu
         jnz       PetSev9                  ; je blokov n¡
         mov       byte ptr ds:[TextRad],-1 ; neplatn‚ Ÿ¡slo ý dku pro text
         cmp       byte ptr ds:[PetrSme],4  ; je ji§ otoŸen ?
         je        PetSev9                  ; je ji§ otoŸen
         mov       byte ptr ds:[PetrSme],4 ; nahoru = sever
         jmp       PetVlev3

PetSev9: ret

PetSev   ENDP

; -----------------------------------------------------------------------------
;        otoŸen¡ na jih (-> CY=pýeruçen¡)
; -----------------------------------------------------------------------------

PetJih   PROC      NEAR

         call      TestBlok                 ; test blokov n¡ programu
         jnz       PetJih9                  ; je blokov n¡ pý¡kaz…
         mov       byte ptr ds:[TextRad],-1 ; neplatn‚ Ÿ¡slo ý dku pro text
         cmp       byte ptr ds:[PetrSme],2  ; je ji§ otoŸen ?
         je        PetJih9                  ; je ji§ otoŸen
         mov       byte ptr ds:[PetrSme],2  ; dol… = jih
         jmp       short PetVlev3

PetJih9: ret

PetJih   ENDP

; -----------------------------------------------------------------------------
;        otoŸen¡ na vìchod (-> CY=pýeruçen¡)
; -----------------------------------------------------------------------------

PetVych  PROC      NEAR

         call      TestBlok                 ; test blokov n¡ programu
         jnz       PetVych9                 ; je blokov n¡ pý¡kaz…
         mov       byte ptr ds:[TextRad],-1 ; neplatn‚ Ÿ¡slo ý dku pro text
         cmp       byte ptr ds:[PetrSme],1  ; je ji§ otoŸen ?
         je        PetVych9                 ; je ji§ otoŸen
         mov       byte ptr ds:[PetrSme],1  ; vpravo = vìchod
         jmp       short PetVlev3

PetVych9:ret

PetVych  ENDP

; -----------------------------------------------------------------------------
;        otoŸen¡ na z pad (-> CY=pýeruçen¡)
; -----------------------------------------------------------------------------

PetZap   PROC      NEAR

         call      TestBlok                 ; test blokov n¡ programu
         jnz       PetZap9                  ; je blokov n¡ pý¡kaz…
         mov       byte ptr ds:[TextRad],-1 ; neplatn‚ Ÿ¡slo ý dku pro text
         cmp       byte ptr ds:[PetrSme],3  ; je ji§ otoŸen ?
         je        PetZap9                  ; je ji§ otoŸen
         mov       byte ptr ds:[PetrSme],3  ; vlevo = z pad
         jmp       short PetVlev3

PetZap9: ret

PetZap   ENDP

; -----------------------------------------------------------------------------
;        otoŸen¡ vzad (-> CY=pýeruçen¡)
; -----------------------------------------------------------------------------

PetVzad  PROC      NEAR

         call      TestBlok                 ; test blokov n¡ programu
         jnz       PetVlev9                 ; je blokov n¡ pý¡kaz…
         mov       byte ptr ds:[TextRad],-1 ; neplatn‚ Ÿ¡slo ý dku pro text
         sub       byte ptr ds:[PetrSme],2  ; posun smØru vzad
         jmp       short PetVlev2

PetVzad  ENDP

; -----------------------------------------------------------------------------
;        otoŸen¡ vlevo (-> CY=pýeruçen¡)
; -----------------------------------------------------------------------------

PetVlevo PROC      NEAR

         call      TestBlok                 ; test blokov n¡ programu
         jnz       PetVlev9                 ; je blokov n¡ pý¡kaz…
         mov       byte ptr ds:[TextRad],-1 ; neplatn‚ Ÿ¡slo ý dku pro text
         sub       byte ptr ds:[PetrSme],1  ; posun vlevo
PetVlev2:ja        PetVlev3                 ; nen¡ podteŸen¡
         add       byte ptr ds:[PetrSme],4  ; posun nahoru
PetVlev3:test      byte ptr ds:[Param],bit0 ; je TURBO re§im ?
         jnz       PetVlev9                 ; je TURBO re§im
         call      CekKrokD                 ; Ÿek n¡ na jeden krok
PetVlev9:ret

PetVlevo ENDP

; -----------------------------------------------------------------------------
;        otoŸen¡ vpravo (-> CY=pýeruçen¡)
; -----------------------------------------------------------------------------

PetVprav PROC      NEAR

         call      TestBlok                 ; test blokov n¡ programu
         jnz       PetVlev9                 ; je blokov n¡ pý¡kaz…
         mov       byte ptr ds:[TextRad],-1 ; neplatn‚ Ÿ¡slo ý dku pro text
         sub       byte ptr ds:[PetrSme],3  ; zmØna smØru vpravo
         jmp       short PetVlev2

PetVprav ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ smØru Petra -> CY=pýeruçen¡
; -----------------------------------------------------------------------------

PetSmer  PROC      NEAR

         call      PetRovn                  ; pýeskoŸen¡ znaku rovn¡tka

         call      VyrazPrg                 ; naŸten¡ smØru
         jc        PetSmer9                 ; chyba

         dec       ax
         and       ax,3                     ; maskov n¡ smØru
         inc       ax

         call      TestBlok                 ; test blokov n¡ programu
         jnz       PetSmer9                 ; je blokov n¡ programu

         mov       byte ptr ds:[TextRad],-1 ; neplatn‚ Ÿ¡slo ý dku pro text
         cmp       al,ds:[PetrSme]          ; je smØr ji§ nastaven ?
         je        PetSmer9                 ; nen¡ potýeba nastavovat
         mov       ds:[PetrSme],al          ; nastaven¡ nov‚ho smØru

         test      byte ptr ds:[Param],bit0 ; je TURBO re§im ?
         jnz       PetSmer9                 ; je TURBO re§im
         call      CekKrokD                 ; Ÿek n¡ na jeden krok (CY=pýeruçen¡)
PetSmer9:ret

PetSmer  ENDP

; -----------------------------------------------------------------------------
;        krok vpýed -> CY=chyba, je zeÔ
; -----------------------------------------------------------------------------

PetKrok  PROC      NEAR

         call      TestBlok                 ; test blokov n¡ programu
         jnz       PetVlev9                 ; je blokov n¡ pý¡kaz…

; ------ £schova registr…

         push      ax
         push      bx

; ------ test, zda je pýed Petrem zeÔ

         call      TestZed                  ; test zdi pýed Petrem
         jc        PetKrok0                 ; nen¡ zeÔ

; ------ chyba - n raz do zdi

         push      cx
         push      si

         mov       si,offset NarazTxt
         mov       ax,9b9bh                 ; barva
         mov       cx,2*18                  ; po§adovan  doba
         call      DispHlas                 ; zobrazen¡ hl çen¡
         cli
         mov       word ptr ds:[UkazMel],offset NarazTon ; melodie
         mov       word ptr ds:[CitacMel],5 ; poŸet t¢n…
         sti

         pop       si
         pop       cx
         stc                                ; pý¡znak chyby - je zeÔ
         jmp       PetKrok9

; ------ nastaven¡ nov‚ pozice Petra

PetKrok0:call      NextPoz                  ; pý¡çt¡ pozice -> BX
         xchg      bx,ds:[PetrPoz]         ; nov  pozice Petra
         mov       byte ptr ds:[TextRad],-1 ; neplatn‚ Ÿ¡slo ý dku pro text

; ------ test, zda se m  Petr zobrazovat

         test      byte ptr ds:[Param],bit0 ; je TURBO re§im ?
         jnz       PetKrok9                 ; je TURBO re§im
         cmp       bx,ds:[PetrOPz]         ; byl zobrazen na pýedeçl‚ pozici ?
         jne       PetKrok7                 ; nebyl na pýedeçl‚ pozici

; ------ vymaz n¡ Petra na pýedeçl‚ pozici

         call      MazPet                   ; vymaz n¡ Petra na pýedeçl‚ pozici

; ------ £schova registr…

         push      cx
         push      dx

         mov       dx,bx                    ; DX <- star  pozice Petra

; ------ urŸen¡ ikony k zobrazen¡ kroku -> AX

         mov       bh,0
         mov       bl,ds:[PetrSme]          ; smØr Petra
         dec       bx                       ; 1 = vpravo
         jnz       PetKrk42
         mov       ax,ds:[ICOPetR]          ; pohle zprava
PetKrk42:dec       bx                       ; 2 = dol…
         jnz       PetKrk44                 ; nen¡ vpravo
         mov       ax,ds:[ICOPetP]          ; pohled zepýedu
PetKrk44:dec       bx                       ; 3 = vlevo
         jnz       PetKrk46
         mov       ax,ds:[ICOPetL]          ; pohled zleva
PetKrk46:dec       bx                       ; 4 = nahoru
         jnz       PetKrk48
         mov       ax,ds:[ICOPetZ]          ; pohled zezadu

; ------ urŸen¡ pý¡rustku kroku -> BX

PetKrk48:mov       bx,ds:[PetrPoz]
         sub       bl,dl                    ; zmØna pozice
         sub       bh,dh                    ; zmØna ý dku

         shl       dx,1
         shl       dx,1
         add       dx,101h

; ------ zobrazen¡ posouvan‚ho Petra (ikona AX)

         mov       cx,3                     ; poŸet krok…
PetKrok5:add       dl,bl                    ; zvìçen¡ pozice
         add       dh,bh                    ; zvìçen¡ ý dku
         call      MaskIcon                 ; zobrazen¡ Petra na nov‚ pozici

; ------ Ÿek n¡ po dobu jednoho kroku

         call      CekKrok                  ; Ÿek n¡ na jeden krok

; ------ vymaz n¡ Petra na mezipozici

         pushf
         push      dx
         mov       dx,ds:[PetrOPz]          ; star  pozice
         call      PoleIcon                 ; zobrazen¡ pýedmØtu na star‚ pozici
         mov       dx,ds:[PetrPoz]          ; nov  pozice
         call      PoleIcon                 ; zobrazen¡ pýedmØtu na nov‚ pozici
         pop       dx
         popf

; ------ dalç¡ krok

         jc        PetKrok6                 ; pýeruçen¡
         loop      PetKrok5                 ; dalç¡ krok

; ------ n vrat registr…

PetKrok6:pop       dx
         pop       cx
         jc        PetKrok9                 ; pýeruçen¡

; ------ zobrazen¡ Petra na nov‚ pozici

PetKrok7:call      CekKrokD                 ; Ÿek n¡ na jeden krok (CY=pýeruçen¡)

; ------ n vrat registr…

PetKrok9:pop       bx
         pop       ax
         ret

PetKrok  ENDP

; -----------------------------------------------------------------------------
;        test pr…chodnosti, zda je pýed Petrem zeÔ -> NC=je zeÔ
; -----------------------------------------------------------------------------

TestZed  PROC      NEAR

; ------ £schova registr…

         push      ax
         push      bx

; ------ pý¡çt¡ pozice

         call      NextPoz                  ; pý¡çt¡ pozice -> BX
         jc        TestZed8                 ; chyba

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
;        naŸten¡ pýedmØtu pýed Petrem -> AX (CY=je mimo okraj, AX nezmØnØn)
; -----------------------------------------------------------------------------

GetPred  PROC      NEAR

; ------ £schova registr…

         push      bx

; ------ pý¡çt¡ pozice

         call      NextPoz                  ; pý¡çt¡ pozice -> BX
         jc        GetPred9                 ; chyba

; ------ naŸten¡ pýedmØtu pýed Petrem

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

PetRych  PROC      NEAR

         call      TestBlok                 ; test blokov n¡ programu
         jnz       PetRych9                 ; je blokov n¡ pý¡kaz…
         or        byte ptr ds:[Param],bit0 ; zapnut¡ TURBO
PetRych9:ret

PetRych  ENDP

; -----------------------------------------------------------------------------
;        zapnut¡ pomal‚ho re§imu
; -----------------------------------------------------------------------------

PetPom   PROC      NEAR

         call      TestBlok                 ; test blokov n¡ programu
         jnz       PetPom9                  ; je blokov n¡ pý¡kaz…
         and       byte ptr ds:[Param],not bit0 ; vypnut¡ TURBO
PetPom9: ret

PetPom   ENDP

; -----------------------------------------------------------------------------
;        vymaz n¡ Petra na star‚ pozici
; -----------------------------------------------------------------------------

MazPet   PROC      NEAR

         push      dx

         test      byte ptr ds:[Param],bit3 ; je Petr zobrazen ?
         jz        MazPet6                  ; Petr nen¡ zobrazen
         mov       dx,ds:[PetrOPz]          ; star  pozice Petra
         call      PoleIcon                 ; zobrazen¡ pýedmØtu na star‚ pozici

MazPet6: pop       dx
         ret

MazPet   ENDP

; -----------------------------------------------------------------------------
;        podm¡nØn‚ zobrazen¡ Petra na aktu ln¡ pozici (s pý¡padnìm vymaz n¡m)
; -----------------------------------------------------------------------------

DispPet  PROC      NEAR

; ------ £schova registr…

         push      ax
         push      dx
         push      es

; ------ kontrola, zda je potýeba Petra vymazat na star‚ pozici

         test      byte ptr ds:[Param],bit3 ; je Petr zobrazen ?
         jz        DispPet3                 ; Petr nen¡ zobrazen
         mov       dx,ds:[PetrOPz]         ; star  pozice Petra
         cmp       dx,ds:[PetrPoz]         ; byla pozice zmØnØna ?
         jne       DispPet2                 ; pozice byla zmØnØna

; ------ kontrola, zda je potýeba Petra pýekreslovat

         mov       dl,ds:[PetrSme]         ; smØr Petra
         cmp       dl,ds:[PetrOSm]         ; je zmØnØn smØr ?
         je        DispPet8                 ; nen¡ potýeba pýekreslen¡

; ------ vymaz n¡ Petra na star‚ pozici

DispPet2:call      MazPet                   ; vymaz n¡ Petra na star‚ pozici

; ------ zobrazen¡ Petra

DispPet3:mov       dh,0
         mov       dl,ds:[PetrSme]         ; smØr Petra
         mov       ds:[PetrOSm],dl         ; £schova smØru Petra

; ------ smØr vpravo

         dec       dx                       ; 1 = vpravo
         jnz       DispPet4                 ; nen¡ vpravo
         mov       ax,ds:[ICOPetR]          ; pohled zprava

; ------ smØr dol…

DispPet4:dec       dx                       ; 2 = dol…
         jnz       DispPet5
         mov       ax,ds:[ICOPetP]          ; pohle zepýedu

; ------ smØr vlevo

DispPet5:dec       dx                       ; 3 = vlevo
         jnz       DispPet6
         mov       ax,ds:[ICOPetL]          ; pohled vlevo

; ------ smØr nahoru

DispPet6:dec       dx                       ; 4 = nahoru
         jnz       DispPet7
         mov       ax,ds:[ICOPetZ]          ; pohled zezadu

; ------ £schova aktu ln¡ho stavu

DispPet7:or        byte ptr ds:[Param],bit3 ; pý¡znak zobrazen¡ Petra
         mov       dx,ds:[PetrPoz]         ; aktu ln¡ pozice
         mov       ds:[PetrOPz],dx         ; £schova zobrazen‚ pozice

; ------ zobrazen¡ Petra na nov‚ pozici

         shl       dx,1
         shl       dx,1
         add       dx,101h
         call      MaskIcon

; ------ n vrat registr…

DispPet8:pop       es
         pop       dx
         pop       ax
         ret

DispPet  ENDP

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
         call      NulBreak                 ; nulov n¡ pý¡znaku pýeruçen¡

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

         xor       bp,bp                    ; inicializace lok ln¡ promØnn‚
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
;        test blokov n¡ programu -> NZ=je blokov n¡, vrac¡ v§dy NC
; -----------------------------------------------------------------------------

TestBlok PROC      NEAR

         test      byte ptr ds:[Param],bit4 ; je pýeruçen¡ cyklu ?
         jnz       TestBlk9                 ; je pýeruçen¡ cyklu
         cmp       word ptr ds:[BlokIf],0   ; je blokov n¡ pý¡kaz… IF ?
;         jne       PetBlk9                  ; je blokov n¡ pý¡kaz…
TestBlk9:ret

TestBlok ENDP

; -----------------------------------------------------------------------------
;        lev  z vorka
; -----------------------------------------------------------------------------

PetLZav  PROC      NEAR

PetLZav2:call      BytePrg                  ; naŸten¡ dalç¡ho bajtu
         jc        PetLZav8                 ; nen¡ dalç¡ bajt
         cmp       al,KOD_RZAV              ; je prav  z vorka ?
         je        PetLZav8                 ; je prav  z vorka - konec
         dec       word ptr ds:[UkazProg]   ; n vrat ukazatele programu
         call      ExePrik                  ; dalç¡ pý¡kaz
         jnc       PetLZav2                 ; dalç¡ pý¡kaz
PetLZav8:ret

PetLZav  ENDP

; -----------------------------------------------------------------------------
;        pr zdn  operace
; -----------------------------------------------------------------------------

PetNop   PROC      NEAR

         clc
         ret

PetNop   ENDP

; -----------------------------------------------------------------------------
;        proveden¡ jednoho pý¡kazu (CY=konec nebo chyba) (niŸ¡ AX a BX !)
; -----------------------------------------------------------------------------

ExePrik  PROC      NEAR

         cmp       sp,ds:[MinSP]            ; je pýeteŸen¡ z sobn¡ku ?
         jb        ExePrik2                 ; je pýeteŸen¡ z sobn¡ku

         call      TstBreak                 ; test pýeruçen¡ programu
         jc        ExePrik2                 ; je pýeruçen¡ programu

         call      BytePrg                  ; naŸten¡ jednoho bajtu
         jc        ExePrik2                 ; konec programu
         mov       ah,0
         shl       ax,1
         xchg      ax,bx                    ; BX <- offset v tabulce
         jmp       word ptr ds:[PrikazX+bx-2] ; skok na obsluhu pý¡kazu

ExePrik2:ret

ExePrik  ENDP

; -----------------------------------------------------------------------------
;        vyvol n¡ procedury -> AX = n vratov  hodnota (z lok ln¡ promØnn‚)
; -----------------------------------------------------------------------------

PetProc  PROC      NEAR

         push      bp                       ; £schova lok ln¡ promØnn‚
; BP z…st v  nastaveno z extern¡ho programu !

         call      WordPrg                  ; naŸten¡ parametru (slovo)
         jc        PetProc9                 ; chyba

         push      word ptr ds:[UkazProg]   ; £schova ukazatele programu

         mov       ds:[UkazProg],ax         ; novì ukazatel programu
         mov       al,ds:[Param]            ; parametry (pý¡znak TURBO)

         push      ax                       ; £schova pý¡znaku TURBO
         call      ExePrik                  ; proveden¡ jednoho pý¡kazu
         pop       ax                       ; n vrat pý¡znaku TURBO

         pop       word ptr ds:[UkazProg]   ; n vrat ukazatele programu

         jc        PetProc9                 ; pýeruçen¡ operace

         mov       ah,ds:[Param]            ; pý¡znak TURBO po operaci
         and       al,bit0                  ; pý¡znak TURBO pýed operac¡
         and       byte ptr ds:[Param],not bit0 ; nulov n¡ souŸasn‚ho pý¡znaku
         or        ds:[Param],al            ; navr cen¡ pý¡znaku TURBO

         test      ah,bit0                  ; mØla procedura TURBO zapnut‚ ?
         jz        PetProc9                 ; nemØla TURBO zapnut‚
         test      al,bit0                  ; navr til se bØ§nì re§im ?
         jnz       PetProc9                 ; navr til se re§im TURBO
         call      CekKrokD                 ; prodleva po operaci

PetProc9:xchg      ax,bp                    ; n vratov  hodnota procedury
         pop       bp
         ret

PetProc  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ hl çen¡
; -----------------------------------------------------------------------------

PetHlas  PROC      NEAR

; ------ pý¡prava textu hl çen¡

         call      IniHlas                  ; pý¡prava textu hl çen¡
         jc        PetHlas9                 ; chyba

; ------ test, zda je blokov n¡ pý¡kazu

         call      TestBlok                 ; test blokov n¡ programu
         jnz       PetHlas9                 ; je blokov n¡ pý¡kaz…

; ------ zobrazen¡ textu hl çen¡

         mov       si,offset ProgStr        ; text hl çen¡
         mov       ax,99h                   ; barva textu - Ÿern /Ÿerven 
         mov       cx,-1                    ; doba = -1
         call      DispHlas                 ; zobrazen¡ hl çen¡
         clc
PetHlas9:ret

PetHlas  ENDP

; -----------------------------------------------------------------------------
;        inicializace textu pro pý¡kazy HLASENI a TEXT -> CY=pýeruçen¡
; -----------------------------------------------------------------------------

IniHlas  PROC      NEAR

; ------ naŸten¡ d‚lky textu hl çen¡ -> AX, CX

         call      BytePrg                  ; naŸten¡ n sleduj¡c¡ho bajtu
         jc        IniHlas9                 ; chyba
         mov       ah,0                     ; AX = d‚lka textu
         xchg      ax,cx                    ; CX <- d‚lka textu
         mov       di,offset ProgStr+1      ; buffer k ulo§en¡ textu
         mov       byte ptr ds:[di-1],0     ; inicializace Ÿ¡taŸe d‚lky

; ------ pý¡prava ukazatele parametr… za programem -> DX

         mov       dx,ds:[UkazProg]         ; ukazatel programu
         add       dx,cx                    ; adresa za ýetØzcem
         jcxz      IniHlas8                 ; d‚lka textu = 0

; ------ ulo§en¡ ýetØzce hl çen¡

IniHlas2:call      BytePrg                  ; naŸten¡ dalç¡ho bajtu
         mov       ds:[di],al               ; ulo§en¡ znaku do bufferu
         inc       di                       ; zvìçen¡ ukl dac¡ adresy

; ------ test, zda je Ÿ¡selnì parametr

         cmp       word ptr ds:[di-2],"#%"  ; je Ÿ¡selnì parametr ?
         jne       IniHlas5                 ; nen¡ Ÿ¡selnì parametr
         sub       byte ptr ds:[ProgStr],2  ; 2 znaky se nepoŸ¡taj¡
         dec       di
         dec       di                       ; zruçen¡ znak… z bufferu

; ------ vìpoŸet Ÿ¡seln‚ho parametru -> AX

         xchg      dx,ds:[UkazProg]         ; ukazatel parametr…
         push      cx
         push      dx
         push      di
         call      VyrazPrg                 ; naŸten¡ hodnoty vìrazu -> AX
         pop       di
         pop       dx
         pop       cx
         xchg      dx,ds:[UkazProg]         ; n vrat ukazatele parametr…

; ------ ulo§en¡ znam‚nka Ÿ¡sla

         or        ax,ax                    ; je z porn‚ Ÿ¡slo ?
         jns       IniHlas3                 ; nen¡ z porn‚ Ÿ¡slo
         mov       byte ptr ds:[di],"-"     ; znam‚nko Ÿ¡sla
         inc       di                       ; zvìçen¡ ukazatele
         inc       byte ptr ds:[ProgStr]    ; zvìçen¡ Ÿ¡taŸe d‚lky ýetØzce
         neg       ax                       ; oprava znam‚nka Ÿ¡sla

; ------ dek¢dov n¡ Ÿ¡sla AX do bufferu DS:DI

IniHlas3:mov       bx,di                    ; BX <- £schova ukl dac¡ adresy
         call      DekNum                   ; dek¢dov n¡ Ÿ¡sla AX
         sub       bx,di                    ; BX <- -d‚lka textu
         neg       bx                       ; oprava znam‚nka d‚lky
         add       byte ptr ds:[ProgStr],bl ; zvìçen¡ Ÿ¡taŸe d‚lky
         jmp       short IniHlas7           ; dalç¡ znak

; ------ test, zda je nastaven¡ barvy

IniHlas5:cmp       word ptr ds:[di-2],"$%"  ; je nastaven¡ barvy ?
         jne       IniHlas6                 ; nen¡ nastaven¡ barvy
         sub       byte ptr ds:[ProgStr],3  ; 3 znaky se nepoŸ¡taj¡

; ------ test, zda je zmØna barvy

IniHlas6:cmp       word ptr ds:[di-2],"*%"  ; je pýep¡naŸ barvy ?
         jne       IniHlas7                 ; nen¡ pýep¡naŸ barvy
         sub       byte ptr ds:[ProgStr],2  ; 2 znaky se nepoŸ¡taj¡
IniHlas7:inc       byte ptr ds:[ProgStr]    ; zvìçen¡ Ÿ¡taŸe d‚lky
         loop      IniHlas2                 ; dalç¡ bajt

; ------ n vrat ukazatele programu

IniHlas8:mov       ds:[UkazProg],dx         ; n vrat ukazatele programu
         clc                                ; pý¡znak operace OK
IniHlas9:ret

IniHlas  ENDP

; -----------------------------------------------------------------------------
;        hudba
; -----------------------------------------------------------------------------

PetMus   PROC      NEAR

; ------ naŸten¡ d‚lky textu hl çen¡ -> CX

         call      BytePrg                  ; n sleduj¡c¡ bajt
         jc        PetMus1                  ; konec programu
         mov       ah,0                     ; AX = d‚lka textu
         xchg      ax,cx                    ; CX <- d‚lka textu

; ------ blokov n¡ programu

         call      TestBlok                 ; test blokov n¡ programu
         jz        PetMus2                  ; nen¡ blokov n¡ pý¡kaz…
         add       ds:[UkazProg],cx         ; zvìçen¡ ukazatele programu
PetMus1: jmp       PetMus8

; ------ inicializace ukazatel… pýehr v n¡ (nejdý¡ve Ÿ¡taŸ, kdyby bylo INT 08h!)

PetMus2: mov       word ptr ds:[CitacMel],0 ; nulov n¡ Ÿ¡taŸe melodie
         mov       word ptr ds:[UkazMel],offset BuffMel ; ukazatel melodie
         mov       di,offset BuffMel        ; buffer melodie
         mov       dx,49 + 8*HI             ; DL <- okt va=4, DH <- d‚lka t¢nu=4
         jcxz      PetMus1                  ; nen¡ § dn  melodie
         mov       bl,0                     ; BL <- 0 nejsou pý¡znaky

; ------ naŸten¡ jednoho znaku

PetMus3: call      BytePrg                  ; naŸten¡ jednoho bajtu
         jc        PetMus1                  ; konec programu
         call      UpCase                   ; konverze na velk‚ p¡smeno

; ------ nastaven¡ d‚lky t¢nu "1" a§ "8"

         cmp       al,"1"                   ; je Ÿ¡slice 1 a§ 8 ?
         jb        PetMus4                  ; nen¡ platn  Ÿ¡slice
         cmp       al,"8"
         ja        PetMus4                  ; nen¡ platn  Ÿ¡slice
         sub       al,"1"                   ; relativn¡ d‚lka t¢nu (0 a§ 7)
         push      cx
         xchg      ax,cx                    ; CL <- relativn¡ d‚lka t¢nu
         mov       dh,bit0                  ; d‚lka t¢nu
         shl       dh,cl                    ; vìpoŸet d‚lky t¢nu
         pop       cx
         jmp       short PetMus54           ; dalç¡ znak

; ------ zvìçen¡ okt vy "+"

PetMus4: cmp       al,"+"                   ; je zvìçen¡ okt vy ?
         jne       PetMs42                  ; nen¡ zvìçen¡ okt vy
         cmp       dl,9*12                  ; maxim ln¡ okt va
         jae       PetMus54                 ; je ji§ maxim ln¡ okt va
         add       dl,12                    ; zvìçen¡ okt vy
         jmp       short PetMus54           ; dalç¡ znak

; ------ sn¡§en¡ okt vy "-"

PetMs42: cmp       al,"-"                   ; je sn¡§en¡ okt vy ?
         jne       PetMs44                  ; nen¡ sn¡§en¡ okt vy
         or        dl,dl                    ; minim ln¡ okt va
         jz        PetMus54                 ; je ji§ minim ln¡ okt va
         sub       dl,12                    ; sn¡§en¡ okt vy
         jmp       short PetMus54           ; dalç¡ znak

; ------ prodlou§en¡ t¢nu o polovinu "." (BL <- bit0)

PetMs44: cmp       al,"."                   ; je prodlou§en¡ d‚lky t¢nu ?
         jne       PetMus5                  ; nen¡ prodlou§en¡ d‚lky t¢nu
         or        bl,bit0                  ; pý¡znak prodlou§en¡ d‚lky t¢nu
         jmp       short PetMus54           ; dalç¡ znak

; ------ zvìçen¡ t¢nu o p…lt¢n "#" (BL <- bit1)

PetMus5: cmp       al,"#"                   ; je zvìçen¡ o p…lt¢n ?
         jne       PetMus6                  ; nen¡ zvìçen¡ o p…lt¢n
         or        bl,bit1                  ; pý¡znak zvìçen¡ t¢nu o p…lt¢n
PetMus54:jmp       short PetMus7            ; dalç¡ znak

; ------ mezera "R"

PetMus6: mov       ah,0                     ; vìçka t¢nu pro prodlevu
         cmp       al,"R"                   ; je prodleva ?
         je        PetMs64                  ; je prodleva

; ------ vìçka t¢nu -> AH

         cmp       al,"C"
         je        PetMs62                  ; "C"

         mov       ah,2
         cmp       al,"D"
         je        PetMs62

         mov       ah,4
         cmp       al,"E"
         je        PetMs62

         mov       ah,5
         cmp       al,"F"
         je        PetMs62

         mov       ah,7
         cmp       al,"G"
         je        PetMs62

         mov       ah,9
         cmp       al,"A"
         je        PetMs62

         mov       ah,11
         cmp       al,"H"
         jne       PetMus7                  ; je nepovolenì znak

PetMs62: add       ah,dl                    ; pýiŸten¡ okt vy
         test      bl,bit1                  ; je zvìçen¡ o p…lt¢n ?
         jz        PetMs64                  ; nen¡ zvìçen¡ o p…lt¢n
         inc       ah                       ; zvìçen¡ o p…lt¢n

; ------ urŸen¡ d‚lky t¢nu

PetMs64: mov       al,0
         test      bl,bit0                  ; je prodlou§en¡ o polovinu ?
         jz        PetMs65                  ; nen¡ prodlou§en¡ o polovinu
         mov       al,dh                    ; d‚lka t¢nu
         shr       al,1                     ; poloviŸn¡ d‚lka
PetMs65: add       al,dh                    ; d‚lka t¢nu

; ------ ulo§en¡ t¢nu

         mov       ds:[di],ax               ; ulo§en¡ t¢nu
         inc       di
         inc       di                       ; zvìçen¡ ukl dav¡ adresy
         inc       word ptr ds:[CitacMel]   ; zvìçen¡ Ÿ¡taŸe hudby

; ------ dalç¡ znak

PetMus7: dec       cx                       ; Ÿ¡taŸ znak…
         jz        PetMus8                  ; konec
         jmp       PetMus3                  ; dalç¡ znak

PetMus8: clc                                ; pý¡znak operace OK
PetMus9: ret

PetMus   ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ hodnoty vektoru
; -----------------------------------------------------------------------------

PetVekt  PROC      NEAR

; ------ naŸten¡ indexu vektoru -> BX

         call      VyrazNum                 ; naŸten¡ indexu vektoru
         jc        PetVekt9                 ; chyba - nen¡ index
         shl       ax,1                     ; index * 2
         xchg      ax,bx                    ; BX <- adresa polo§ky vektoru

; ------ vypuçtØn¡ znaku rovn¡tka

         call      PetRovn                  ; pýeskoŸen¡ znaku rovn¡tka

; ------ naŸten¡ vìrazu

PetVekt2:push      bx                       ; adresa polo§ky
         call      VyrazPrg                 ; naŸten¡ hodnoty vìrazu -> AX
         pop       bx
         jc        PetVekt8                 ; chyba

; ------ test blokov n¡ pý¡kaz…

         call      TestBlok                 ; test blokov n¡ programu
         jnz       PetVekt5                 ; je blokov n¡ pý¡kaz…

; ------ ulo§en¡ hodnoty vektoru

         push      es
         mov       es,ds:[DataVekt]         ; segment vektoru
         mov       es:[bx],ax               ; nastaven¡ hodnoty vektoru
         pop       es

; ------ zvìçen¡ indexu vektoru

PetVekt5:inc       bx
         inc       bx                       ; zvìçen¡ indexu vektoru

; ------ test, zda bude dalç¡ polo§ka

         call      PetCark                  ; naŸten¡ znaku Ÿ rky
         jnc       PetVekt2                 ; je Ÿ rka - bude dalç¡ polo§ka
PetVekt8:clc                                ; pý¡znak operace OK
PetVekt9:ret

PetVekt  ENDP

; -----------------------------------------------------------------------------
;        vypr zdnØn¡ bufferu kl vesnice
; -----------------------------------------------------------------------------

PetKlav  PROC      NEAR

         call      TestBlok                 ; test blokov n¡ programu
         jnz       PetKlav4                 ; je blokov n¡ pý¡kaz…

PetKlav2:call      InpChar                  ; vstup znaku z kl vesnice
         jnc       PetKlav2                 ; je nØjakì znak - zruçen¡
PetKlav4:clc                                ; pý¡znak operace OK
         ret

PetKlav  ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ hodnoty lok ln¡ promØnn‚
; -----------------------------------------------------------------------------

PetMist  PROC      NEAR

         call      PetRovn                  ; pýeskoŸen¡ znaku rovn¡tka
         call      VyrazPrg                 ; naŸten¡ hodnoty vìrazu

         call      TestBlok                 ; test blokov n¡ programu
         jnz       PetMist9                 ; je blokov n¡ pý¡kaz…

         mov       bp,ax                    ; BP <- nastaven¡ hodnoty promØnn‚
PetMist9:clc
         ret

PetMist  ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ hodnoty promØnn‚
; -----------------------------------------------------------------------------

PetProm  PROC      NEAR

         call      WordPrg                  ; naŸten¡ adresy Ÿ¡sla
         jc        PetProm9                 ; konec programu
         mov       di,ax                    ; DI <- adresa Ÿ¡sla

         call      PetRovn                  ; pýeskoŸen¡ znaku rovn¡tka

         push      di
         call      VyrazPrg                 ; naŸten¡ hodnoty vìrazu
         pop       di

         call      TestBlok                 ; test blokov n¡ programu
         jnz       PetProm9                 ; je blokov n¡ pý¡kaz…

         push      es
         mov       es,ds:[DataProg]         ; segment programu
         mov       es:[di],ax               ; nastaven¡ hodnoty promØnn‚
         pop       es
                                          ;* zde je CY=konec programu
PetProm9:ret

PetProm  ENDP

; -----------------------------------------------------------------------------
;        pýeskoŸen¡ znaku rovn¡tka
; -----------------------------------------------------------------------------

PetRovn  PROC      NEAR

         push      ax
         call      BytePrg                  ; n sleduj¡c¡ bajt
         jc        PetRovn2                 ; konec programu
         cmp       al,KOD_ROVN              ; je rovn¡tko ?
         je        PetRovn2                 ; je rovn¡tko - vypust¡ se
         dec       word ptr ds:[UkazProg]   ; n vrat ukazatele programu

PetRovn2:pop       ax
         clc                                ; pý¡znak operace OK
         ret

PetRovn  ENDP

; -----------------------------------------------------------------------------
;        pýeskoŸen¡ znaku Ÿ rky -> CY=nebyla Ÿ rka
; -----------------------------------------------------------------------------

PetCark  PROC      NEAR

         push      ax
         call      BytePrg                  ; n sleduj¡c¡ bajt
         jc        PetCark                  ; konec programu
         cmp       al,KOD_CARK              ; je Ÿ rka ?
         je        PetCark2                 ; je Ÿ rka - vypust¡ se
         dec       word ptr ds:[UkazProg]   ; n vrat ukazatele programu
         stc                                ; pý¡znak, §e nen¡ Ÿ rka
PetCark2:pop       ax
         ret

PetCark  ENDP

; -----------------------------------------------------------------------------
;        Ÿ¡slo - jako opakov n¡
; -----------------------------------------------------------------------------

PetCisl  PROC      NEAR

         call      WordPrg                  ; naŸten¡ hodnoty Ÿ¡sla
         jmp       short PetOpak0

PetCisl  ENDP

; -----------------------------------------------------------------------------
;        opakov n¡ s poŸtem
; -----------------------------------------------------------------------------

PetOpak  PROC      NEAR

         call      VyrazPrg                 ; naŸten¡ parametru
PetOpak0:jc        PetOpak9                 ; chyba
         call      TestBlok                 ; test blokov n¡ programu
         jnz       PetOpak1                 ; je blokov n¡ pý¡kaz…
         xchg      ax,cx                    ; CX <- Ÿ¡taŸ opakov n¡
         jmp       short PetOpak6           ; bude to bez posledn¡ho cyklu

PetOpak1:call      ExePrik                  ; pýeskoŸen¡ pý¡kazu pýi pýeruçen¡
         ret

; ------ prov dØn¡ pý¡kaz… uvnitý smyŸky (bez posledn¡ho pr…chodu)

PetOpak2:push      word ptr ds:[UkazProg]   ; £schova ukazatele programu
         push      cx
         call      ExePrik                  ; proveden¡ jednoho pý¡kazu
         pop       cx
         pop       word ptr ds:[UkazProg]   ; n vrat ukazatele programu
         jc        PetOpak8                 ; chyba nebo pýeruçen¡
         test      byte ptr ds:[Param],bit4 ; je pýeruçen¡ cyklu ?
         jnz       PetOpak7                 ; je pýeruçen¡ cyklu
PetOpak6:jcxz      PetOpak2                 ; nekoneŸnì cyklus
         loop      PetOpak2                 ; dalç¡ cyklus

; ------ posledn¡ proveden¡ pý¡kazu

PetOpak7:call      ExePrik                  ; proveden¡ posledn¡ho pý¡kazu

; ------ ukonŸen¡ pýeruçen¡ cyklu (pýedt¡m nebyl pýeruçen)

PetOpak8:pushf
         and       byte ptr ds:[Param],not bit4 ; konec pýeruçen¡ cyklu
         popf
PetOpak9:ret

PetOpak  ENDP

; -----------------------------------------------------------------------------
;        podm¡nØn‚ opakov n¡
; -----------------------------------------------------------------------------

PetDok   PROC      NEAR

         call      TestBlok                 ; test blokov n¡ programu
         jz        PetDok2                  ; nen¡ blokov n¡ pý¡kaz… IF
PetDok1: call      ExePrik                  ; pýeskoŸen¡ pý¡kazu pýi pýeruçen¡
         ret

; ------ prov dØn¡ pý¡kaz… uvnitý smyŸky (bez posledn¡ho pr…chodu)

PetDok2: push      word ptr ds:[UkazProg]   ; £schova ukazatele programu

         call      TestPodm                 ; test podm¡nky
         jnc       PetDok3                  ; podm¡nka splnØna OK
         or        byte ptr ds:[Param],bit4 ; pýeruçen¡ cyklu
PetDok3: call      ExePrik                  ; proveden¡ jednoho pý¡kazu

PetDok4: mov       ax,ds:[UkazProg]         ; dosa§enì ukazatel
         pop       word ptr ds:[UkazProg]   ; n vrat ukazatele programu
         jc        PetDok7                  ; chyba nebo pýeruçen¡
         test      byte ptr ds:[Param],bit4 ; je pýeruçen¡ cyklu ?
         jz        PetDok2                  ; nen¡ pýeruçen¡ - dalç¡ cyklus

; ------ ukonŸen¡ pýeruçen¡ cyklu (pýedt¡m nebyl pýeruçen)

PetDok7: mov       ds:[UkazProg],ax         ; novì dosa§enì ukazatel programu
         pushf
         and       byte ptr ds:[Param],not bit4 ; konec pýeruçen¡ cyklu
         popf
PetDok9: ret

PetDok  ENDP

; -----------------------------------------------------------------------------
;        pýeruçen¡ cyklu nebo programu
; -----------------------------------------------------------------------------

PetPrer  PROC      NEAR

         call      TestBlok                 ; test blokov n¡ programu
         jnz       PetPrer9                 ; je blokov n¡ pý¡kaz…
         or        byte ptr ds:[Param],bit4 ; pý¡znak pýeruçen¡ cyklu
PetPrer9:ret

PetPrer  ENDP

; -----------------------------------------------------------------------------
;        synchronizace na VSYN (vol  se t‚§ pýi editaci ikony !)
; -----------------------------------------------------------------------------

PetVSyn  PROC      NEAR

         push      ax
         push      dx

         call      TestBlok                 ; test blokov n¡ programu
         jnz       PetVSyn4                 ; je blokov n¡ programu

         mov       byte ptr ds:[TimeKrok],2 ; nastaven¡ Ÿ¡taŸe
         mov       dx,3dah
PetVSyn2:sti
         cmp       byte ptr cs:[TimeKrok],0
         je        PetVSyn4                 ; pýeteŸen¡ doby
         in        al,dx
         test      al,bit3
         jz        PetVSyn2                 ; Ÿek n¡ na impuls

PetVSyn4:pop       dx
         pop       ax
         clc
         ret

PetVSyn  ENDP

; -----------------------------------------------------------------------------
;        podm¡nka JESTLI
; -----------------------------------------------------------------------------

PetJest  PROC      NEAR

; ------ test splnØn¡ podm¡nky

         call      TestPodm                 ; test podm¡nky
         jc        PetJest4                 ; podm¡nka nesplnØna

; ------ proveden¡ pý¡kazu, je-li splnØna podm¡nka

PetJest2:call      ExePrik                  ; proveden¡ pý¡kazu bez blokov n¡
         jc        PetJest9                 ; pýeruçen¡ programu

; ------ test, zda n sleduje pý¡kaz JINAK

         call      BytePrg                  ; naŸten¡ dalç¡ho bajtu
         jc        PetJest8                 ; chyba
         cmp       al,KOD_JIN               ; je JINAK ?
         jne       PetJest7                 ; nen¡ JINAK

; ------ neproveden¡ pý¡kazu za JINAK

         inc       word ptr ds:[BlokIf]     ; blokov n¡ pý¡kazu
         call      ExePrik                  ; proveden¡ jednoho pý¡kazu
         dec       word ptr ds:[BlokIf]     ; odblokov n¡ pý¡kazu
         jmp       short PetJest9

; ------ neproveden¡ pý¡kazu, podm¡nka nen¡ splnØna

PetJest4:inc       word ptr ds:[BlokIf]     ; blokov n¡ pý¡kazu
         call      ExePrik                  ; proveden¡ jednoho pý¡kazu
         dec       word ptr ds:[BlokIf]     ; odblokov n¡ pý¡kazu
         jc        PetJest9                 ; pýeruçen¡ programu

; ------ test, zda n sleduje pý¡kaz JINAK

PetJest5:call      BytePrg                  ; naŸten¡ dalç¡ho bajtu
         jc        PetJest8                 ; chyba
         cmp       al,KOD_JIN               ; je JINAK ?
         jne       PetJest7                 ; nen¡ JINAK

; ------ proveden¡ pý¡kazu za JINAK

         call      ExePrik                  ; proveden¡ pý¡kazu bez blokov n¡
         jmp       short PetJest9

PetJest7:dec       word ptr ds:[UkazProg]   ; n vrat bajtu
PetJest8:clc                                ; pý¡znak operace OK
PetJest9:ret

PetJest  ENDP

BlokIf   dw        0                        ; Ÿ¡taŸ blokov n¡ IF (0=nen¡ blok)

; -----------------------------------------------------------------------------
;        test podm¡nky -> CY=nen¡ podm¡nka splnØna
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;        naŸten¡ £rovnØ OR -> CY=nen¡ podm¡nka splnØna
; -----------------------------------------------------------------------------

TestPodm:

TestOr   PROC      NEAR

         push      cx

; ------ naŸten¡ operandu

         mov       cl,1                     ; pý¡znak nesplnØn¡ podm¡nky
TestOr1: call      TestAnd                  ; naŸten¡ operandu
         jc        TestOr2                  ; podm¡nka nesplnØna
         mov       cl,0                     ; pý¡znak splnØn¡ podm¡nky

; ------ naŸten¡ dalç¡ho bajtu

TestOr2: call      BytePrg                  ; naŸten¡ dalç¡ho bajtu
         jc        TestOr8                  ; nen¡ dalç¡ bajt
         cmp       al,KOD_OR                ; je OR ?
         je        TestOr1                  ; je OR - dalç¡ operand

         dec       word ptr ds:[UkazProg]   ; n vrat bajtu

TestOr8: shr       cl,1                     ; CY=podm¡nka nesplnØna
         pop       cx
         ret

TestOr   ENDP

; -----------------------------------------------------------------------------
;        naŸten¡ £rovnØ AND -> CY=nen¡ podm¡nka splnØna
; -----------------------------------------------------------------------------

TestAnd  PROC      NEAR

         push      cx

; ------ naŸten¡ operandu

         mov       cl,0                     ; pý¡znak splnØn¡ podm¡nky
TestAnd1:call      Test1Pod                 ; naŸten¡ operandu
         jnc       TestAnd2                 ; podm¡nka splnØna
         mov       cl,1                     ; pý¡znak nesplnØn¡ podm¡nky

; ------ naŸten¡ dalç¡ho bajtu

TestAnd2:call      BytePrg                  ; naŸten¡ dalç¡ho bajtu
         jc        TestAnd8                 ; nen¡ dalç¡ bajt
         cmp       al,KOD_AND               ; je AND ?
         je        TestAnd1                 ; je AND - dalç¡ operand

         dec       word ptr ds:[UkazProg]   ; n vrat bajtu

TestAnd8:shr       cl,1                     ; CY=podm¡nka nesplnØna
         pop       cx
         ret

TestAnd  ENDP

; -----------------------------------------------------------------------------
;        test jedn‚ podm¡nky -> CY=nen¡ podm¡nka splnØna
; -----------------------------------------------------------------------------

Test1Pod PROC      NEAR

; ------ £schova registr…

         push      ax
         push      cx

; ------ kontrola ukazatele z sobn¡ku

         cmp       sp,ds:[MinSP]            ; je pýeteŸen¡ z sobn¡ku ?
         jb        Test1Pd9                 ; je pýeteŸen¡ z sobn¡ku

; ------ naŸten¡ identifikaŸn¡ho bajtu

         call      BytePrg                  ; naŸten¡ bajtu
         jc        Test1Pd9                 ; chyba

; ------ negace podm¡nky

         cmp       al,KOD_NENI              ; je negace podm¡nky ?
         jne       Test1Pd1                 ; nen¡ negace podm¡nky
         call      Test1Pod                 ; test dalç¡ podm¡nky
         cmc                                ; negace vìsledku
         jmp       short Test1Pd9

; ------ test pýedmØtu

Test1Pd1:cmp       al,KOD_OBR               ; je obr zek ?
         jne       Test1Pd2                 ; nen¡ obr zek
         call      WordPrg                  ; naŸten¡ Ÿ¡sla ikony
         jc        Test1Pd9                 ; chyba
         xchg      ax,cx                    ; CX <- £schova pýedmØtu
         call      GetPred                  ; naŸten¡ pýedmØtu -> AX
         jc        Test1P12                 ; je r m
         cmp       ax,cx                    ; souhlas¡ pýedmØt ?
         je        Test1Pd9                 ; pýedmØt souhlas¡ OK
         jmp       short Test1Pd8           ; pýedmØt nesouhlas¡
Test1P12:cmp       cx,ds:[ICOZed]           ; je test zdi ?
         je        Test1Pd9                 ; je zeÔ
         cmp       cx,ds:[ICORam]           ; je test r mu ?
         je        Test1Pd9                 ; je r m
         jmp       short Test1Pd8           ; podm¡nka nesplnØna

; ------ test smØru

Test1Pd2:mov       ah,4                     ; k¢d pro SEVER
         cmp       al,KOD_SEV               ; SEVER
         je        Test1Pd3
         mov       ah,2                     ; k¢d pro JIH
         cmp       al,KOD_JIH               ; JIH
         je        Test1Pd3
         mov       ah,1                     ; k¢d pro VíCHOD
         cmp       al,KOD_VYCH              ; VíCHOD
         je        Test1Pd3
         mov       ah,3                     ; k¢d pro ZµPAD
         cmp       al,KOD_ZAP               ; ZµPAD
         jne       Test1Pd4
Test1Pd3:cmp       ah,ds:[PetrSme]          ; kontrola smØru Petra
         je        Test1Pd9                 ; podm¡nka splnØna
         jmp       short Test1Pd8

; ------ naŸten¡ podm¡nky v z vorce

Test1Pd4:cmp       al,KOD_LZAV              ; je lev  z vorka ?
         jne       Test1Pd6                 ; nen¡ lev  z vorka
         call      TestPodm                 ; naŸten¡ podm¡nky v z vorce

; ------ test, zda je prav  z vorka

         pushf
         call      BytePrg                  ; naŸten¡ dalç¡ho bajtu
         jc        Test1Pd5                 ; nen¡ dalç¡ bajt
         cmp       al,KOD_RZAV              ; je prav  z vorka ?
         je        Test1Pd5                 ; je prav  z vorka
         dec       word ptr ds:[UkazProg]   ; n vrat bajtu
Test1Pd5:popf
         jmp       short Test1Pd9

; ------ porovn n¡ vìraz…

Test1Pd6:dec       word ptr ds:[UkazProg]   ; n vrat bajtu
         call      TestCmp                  ; porovn n¡ dvou vìraz…
         jmp       short Test1Pd9

; ------ n vrat registr…

Test1Pd8:stc                                ; pý¡znak nesplnØn¡ podm¡nky
Test1Pd9:pop       cx
         pop       ax
         ret

Test1Pod ENDP

; -----------------------------------------------------------------------------
;        naŸten¡ £rovnØ porovn n¡ dvou vìraz… -> CY=podm¡nka nesplnØna
; -----------------------------------------------------------------------------

TestCmp  PROC      NEAR

; ------ £schova registr…

         push      bx
         push      cx

; ------ naŸten¡ prvn¡ho operandu

         call      VyrazPrg                 ; naŸten¡ vìrazu
         jc        TestCmp8                 ; chyba
         xchg      ax,cx                    ; CX <- £schova operandu

; ------ naŸten¡ n sleduj¡c¡ho bajtu

         mov       bl,0                     ; stýadaŸ oper toru
TestCmp2:call      BytePrg                  ; naŸten¡ dalç¡ho bajtu
         jc        TestCmp6                 ; nen¡ dalç¡ bajt

; ------ oper tor "="

         cmp       al,KOD_ROVN              ; je "=" ?
         jne       TestCmp3                 ; nen¡ "="
         or        bl,bit0                  ; pý¡znak "="
         jmp       short TestCmp2           ; dalç¡ bajt

; ------ oper tor "="

TestCmp3:cmp       al,KOD_MENS              ; je "<" ?
         jne       TestCmp4                 ; nen¡ "<"
         or        bl,bit1                  ; pý¡znak "<"
         jmp       short TestCmp2

; ------ oper tor ">"

TestCmp4:cmp       al,KOD_VETS              ; je ">" ?
         jne       TestCmp5                 ; nen¡ ">"
         or        bl,bit2                  ; pý¡znak ">"
         jmp       short TestCmp2

; ------ n vrat neplatn‚ho znaku

TestCmp5:dec       word ptr ds:[UkazProg]   ; n vrat bajtu

; ------ test, zda je nØjakì oper tor

TestCmp6:or        bl,bl                    ; je nØjakì oper tor ?
         jnz       TestCm62                 ; je nØjakì oper tor
         shr       cx,1                     ; test bitu 0
         cmc
         jmp       short TestCmp9           ; CY=podm¡nka nesplnØna

; ------ naŸten¡ druh‚ho operandu

TestCm62:call      VyrazPrg                 ; naŸten¡ druh‚ho operandu
         jnc       TestCmp7                 ; operace OK
         xor       ax,ax                    ; pýi chybØ se porovn  s nulou

; ------ shoda

TestCmp7:test      bl,bit0                  ; je "=" ?
         jz        TestCm72                 ; nen¡ "="
         cmp       cx,ax                    ; je shoda ?
         je        TestCmp8                 ; je shoda

; ------ menç¡

TestCm72:test      bl,bit1                  ; je "<" ?
         jz        TestCm74                 ; nen¡ "<"
         cmp       cx,ax                    ; je menç¡ ?
         jl        TestCmp8                 ; je menç¡

; ------ vØtç¡

TestCm74:test      bl,bit2                  ; je ">" ?
         jz        TestCm76                 ; nen¡ ">"
         cmp       cx,ax                    ; je vØtç¡ ?
         jg        TestCmp8                 ; je vØtç¡

; ------ podm¡nka nesplnØna

TestCm76:stc                                ; pý¡znak nesplnØn¡ podm¡nky
         jmp       short TestCmp9

; ------ podm¡nka splnØna

TestCmp8:clc                                ; pý¡znak splnØn¡ podm¡nky

; ------ n vrat registr…

TestCmp9:pop       cx
         pop       bx
         ret

TestCmp  ENDP

; -----------------------------------------------------------------------------
;        naŸten¡ £rovnØ souŸtu/rozd¡lu -> AX, CY=nen¡
; -----------------------------------------------------------------------------

VyrazPrg:

VyrazAdd PROC      NEAR

; ------ £schova registr…

         push      cx

; ------ naŸten¡ prvn¡ho operandu -> CX

         call      VyrazMul                 ; naŸten¡ prvn¡ho operandu
         jc        VyrazAd9                 ; chyba
         xchg      ax,cx                    ; CX <- prvn¡ operand

; ------ naŸten¡ n sleduj¡c¡ho identifik toru

VyrazAd2:call      BytePrg                  ; naŸten¡ dalç¡ho bajtu
         jc        VyrazAd8                 ; nen¡ oper tor

; ------ oper tor souŸtu "+"

         cmp       al,KOD_PLUS              ; je souŸet ?
         jne       VyrazAd4                 ; nen¡ souŸet

; ------ naŸten¡ druh‚ho operandu

         call      VyrazMul                 ; naŸten¡ druh‚ho operandu
         jc        VyrazAd8                 ; nen¡ druhì operand

; ------ proveden¡ operace souŸtu

         add       cx,ax                    ; souŸet
         jmp       short VyrazAd2           ; dalç¡ operand

; ------ oper tor rozd¡lu "-"

VyrazAd4:cmp       al,KOD_MIN               ; je rozd¡l ?
         jne       VyrazAd7                 ; nen¡ rozd¡l

; ------ naŸten¡ druh‚ho operandu

         call      VyrazMul                 ; naŸten¡ druh‚ho operandu
         jc        VyrazAd8                 ; nen¡ druhì operand

; ------ proveden¡ operace rozd¡lu

         sub       cx,ax                    ; rozd¡l
         jmp       short VyrazAd2           ; dalç¡ operand

; ------ n vrat registr…

VyrazAd7:dec       word ptr ds:[UkazProg]   ; n vrat bajtu
VyrazAd8:clc                                ; pý¡znak operace OK
         xchg      ax,cx                    ; AX <- stýadaŸ vìsledku
VyrazAd9:pop       cx
         ret

VyrazAdd ENDP

; -----------------------------------------------------------------------------
;        naŸten¡ £rovnØ n soben¡/dØlen¡ -> AX, CY=nen¡
; -----------------------------------------------------------------------------

VyrazMul PROC      NEAR

; ------ £schova registr…

         push      cx

; ------ naŸten¡ prvn¡ho operandu -> CX

         call      VyrazNum                 ; naŸten¡ prvn¡ho operandu
         jc        VyrazMl9                 ; chyba
VyrazMl2:xchg      ax,cx                    ; CX <- prvn¡ operand

; ------ naŸten¡ n sleduj¡c¡ho identifik toru

         call      BytePrg                  ; naŸten¡ dalç¡ho bajtu
         jc        VyrazMl8                 ; nen¡ oper tor

; ------ oper tor n soben¡ "*"

         cmp       al,KOD_KRAT              ; je n soben¡ ?
         jne       VyrazMl3                 ; nen¡ n soben¡

; ------ naŸten¡ druh‚ho operandu

         call      VyrazNum                 ; naŸten¡ druh‚ho operandu
         jc        VyrazMl8                 ; nen¡ druhì operand

; ------ proveden¡ operace n soben¡

         push      dx
         imul      cx                       ; proveden¡ operace n soben¡
         pop       dx
         jmp       short VyrazMl2           ; dalç¡ operand

; ------ oper tor dØlen¡ "/"

VyrazMl3:cmp       al,KOD_DEL               ; je dØlen¡ ?
         jne       VyrazMl5                 ; nen¡ dØlen¡

; ------ naŸten¡ druh‚ho operandu

         call      VyrazNum                 ; naŸten¡ druh‚ho operandu
         jc        VyrazMl8                 ; nen¡ druhì operand

; ------ proveden¡ operace dØlen¡

         push      dx
         xchg      ax,cx                    ; AX <- dØlenec, CX <- dØlitel
         xor       dx,dx                    ; DX <- 0
         jcxz      VyrazMl4                 ; dØlen¡ nulou
         idiv      cx                       ; proveden¡ operace dØlen¡
VyrazMl4:pop       dx
         jmp       short VyrazMl2           ; dalç¡ operand

; ------ oper tor MOD

VyrazMl5:cmp       al,KOD_MOD               ; je MODulo ?
         jne       VyrazMl7                 ; nen¡ MODulo

; ------ naŸten¡ druh‚ho operandu

         call      VyrazNum                 ; naŸten¡ druh‚ho operandu
         jc        VyrazMl8                 ; nen¡ druhì operand

; ------ proveden¡ operace dØlen¡

         push      dx
         xchg      ax,cx                    ; AX <- dØlenec, CX <- dØlitel
         xor       dx,dx                    ; DX <- 0
         jcxz      VyrazMl6                 ; dØlen¡ nulou
         idiv      cx                       ; proveden¡ operace dØlen¡
VyrazMl6:xchg      ax,dx                    ; AX <- zbytek po dØlen¡
         pop       dx
         jmp       short VyrazMl2           ; dalç¡ operand

; ------ n vrat registr…

VyrazMl7:dec       word ptr ds:[UkazProg]   ; n vrat bajtu
VyrazMl8:clc                                ; pý¡znak operace OK
         xchg      ax,cx                    ; AX <- stýadaŸ vìsledku
VyrazMl9:pop       cx
         ret

VyrazMul ENDP

; -----------------------------------------------------------------------------
;        naŸten¡ jednoho Ÿ¡sla/promØnn‚ ve vìrazu -> AX, CY=nen¡
; -----------------------------------------------------------------------------

VyrazNum PROC      NEAR

; ------ kontrola pýeteŸen¡ z sobn¡ku

         cmp       sp,ds:[MinSP]            ; je pýeteŸen¡ z sobn¡ku ?
         jb        VyrazN29                 ; je pýeteŸen¡ z sobn¡ku

; ------ naŸten¡ identifik toru

VyrazNm1:call      BytePrg                  ; naŸten¡ identifikaŸn¡ho bajtu
         jc        VyrazN29                 ; konec programu

; ------ un rn¡ znam‚nko "+" se ignoruje

         cmp       al,KOD_PLUS              ; je "+" ?
         je        VyrazNm1                 ; znam‚nko se ignoruje

; ------ pý¡kaz PREDMET se ignoruje (n sleduje vìraz jako Ÿ¡slo pýedmØtu)

         cmp       al,KOD_PRED              ; je pýedmØt ?
         je        VyrazNm1                 ; pýedmØt se ignoruje

; ------ negace Ÿ¡sla

         cmp       al,KOD_MIN               ; je "-" ?
         jne       VyrazNm2                 ; nen¡ "-"
         call      VyrazNum                 ; naŸten¡ Ÿ¡sla
         jc        VyrazN29                 ; nen¡ platn‚ Ÿ¡slo
         neg       ax                       ; negace vìsledku
         clc
         jmp       short VyrazN29

; ------ promØnn 

VyrazNm2:cmp       al,KOD_PROM              ; je promØnn  ?
         jne       VyrazNm3                 ; nen¡ promØnn 
         call      WordPrg                  ; naŸten¡ adresy promØnn‚
         jc        VyrazN29                 ; konec programu

         push      bx
         push      es
         mov       es,ds:[DataProg]
         mov       bx,ax                    ; BX <- adresa promØnn‚
         mov       ax,es:[bx]               ; hodnota promØnn‚
         pop       es
         pop       bx
VyrazN29:jmp       VyrazNm9           ; zde je NC

; ------ vektor

VyrazNm3:cmp       al,KOD_VEKT              ; je vektor ?
         jne       VyrazN31                 ; nen¡ vektor
         call      VyrazNum                 ; naŸten¡ n sleduj¡c¡ho Ÿ¡sla

         push      di
         push      es
         shl       ax,1                     ; index * 2
         xchg      ax,di                    ; DI <- index
         mov       es,ds:[DataVekt]         ; segment vektoru
         mov       ax,es:[di]               ; hodnota vektoru
         pop       es
         pop       di
         clc
         jmp       VyrazNm9

; ------ Ÿ¡slo nebo obr zek

VyrazN31:cmp       al,KOD_OBR               ; je obr zek ?
         je        VyrzN312                 ; je obr zek - naŸten¡ Ÿ¡sla
         cmp       al,KOD_CISL              ; je Ÿ¡slo ?
         jne       VyrazN32                 ; nen¡ Ÿ¡slo
VyrzN312:call      WordPrg                  ; naŸten¡ hodnoty Ÿ¡sla
         jmp       VyrazNm9

; ------ funkce

VyrazN32:cmp       al,KOD_PROC              ; je funkce ?
         jne       VyrazN33                 ; nen¡ funkce
         push      bx
         push      cx
         push      dx
         call      PetProc                  ; vyvol n¡ funkce
         pop       dx
         pop       cx
         pop       bx
         clc
         jmp       short VyrazNm9

; ------ m¡stn¡ promØnn 

VyrazN33:cmp       al,KOD_MIST              ; je m¡stn¡ promØnn  ?
         jne       VyrazN34                 ; nen¡ m¡stn¡ promØnn 
         mov       ax,bp                    ; hodnota m¡stn¡ promØnn‚
         jmp       short VyrazNm8

; ------ n hodn‚ Ÿ¡slo

VyrazN34:cmp       al,KOD_NAH               ; je n hodn‚ Ÿ¡slo ?
         jne       VyrazN35                 ; nen¡ n hodn‚ Ÿ¡slo
         call      VyrazPrg                 ; naŸten¡ vìrazu
         call      RandomN                  ; vìpoŸet n hodn‚ho Ÿ¡sla
         jmp       short VyrazNm8

; ------ pozice X

VyrazN35:cmp       al,KOD_POZX              ; je pozice X ?
         jne       VyrazN36                 ; nen¡ pozice X
         mov       al,byte ptr ds:[PetrPoz] ; pozice X
         jmp       short VyrzN362

; ------ pozice Y

VyrazN36:cmp       al,KOD_POZY              ; je pozice Y ?
         jne       VyrazN37                 ; nen¡ pozice Y
         mov       al,byte ptr ds:[PetrPoz+1] ; pozice Y
VyrzN362:mov       ah,0
         jmp       short VyrazNm8

; ------ kl vesa

VyrazN37:cmp       al,KOD_KLAV
         jne       VyrazN38
         call      TestBlok                 ; test blokov n¡ programu
         jnz       VyrazNm9                 ; je blokov n¡ programu
         call      InpChar                  ; vstup znaku z kl vesnice
         jmp       short VyrazNm8

; ------ smØr

VyrazN38:cmp       al,KOD_SMER
         jne       VyrazN39
         mov       al,ds:[PetrSme]          ; nastavenì smØr
         jmp       short VyrzN362

; ------ obsah pole

VyrazN39:cmp       al,KOD_POLE              ; je pole ?
         jne       VyrazN3A                 ; nen¡ pole

         call      VyrazPrg                 ; naŸten¡ souýadnice X pole
         push      ax                       ; AL = souýadnice X pole
         call      VyrazPrg                 ; naŸten¡ souýadnice Y pole
         pop       dx                       ; DL <- souýadnice X pole
         mov       dh,al                    ; DH <- souýadnice Y pole
         call      GetPole                  ; poskytnut¡ pýedmØtu z DX
         jmp       short VyrazNm8           ; operace OK

; ------ HUDBA

VyrazN3A:cmp       al,KOD_MUS               ; je HUDBA ?
         jne       VyrazNm4                 ; nen¡ HUDBA
         mov       ax,ds:[CitacMel]         ; Ÿ¡taŸ melodie
         jmp       short VyrazNm8           ; operace OK

; ------ lev  z vorka - vìraz

VyrazNm4:cmp       al,KOD_LZAV              ; je lev  z vorka ?
         jne       VyrazNm7                 ; nen¡ lev  z vorka
         call      VyrazPrg                 ; naŸten¡ vìrazu v z vorce

; ------ test, zda je prav  z vorka

         push      ax
         call      BytePrg                  ; naŸten¡ dalç¡ho bajtu
         cmc
         jnc       VyrazNm5                 ; nen¡ dalç¡ bajt
         cmp       al,KOD_RZAV              ; je prav  z vorka ?
         je        VyrazNm5                 ; je prav  z vorka
         stc                                ; pý¡znak pro navr cen¡ znaku
VyrazNm5:pop       ax
         jnc       VyrazNm9

; ------ n vrat neplatn‚ho identifikaŸn¡ho bajtu

VyrazNm7:dec       word ptr ds:[UkazProg]   ; n vrat bajtu
VyrazNm8:clc                                ; pý¡znak operace OK
VyrazNm9:ret

VyrazNum ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ pýedmØtu ze souýadnice DX -> AX (pýi chybØ AX=r m, CY)
; -----------------------------------------------------------------------------

GetPole  PROC      NEAR

; ------ £schova registr…

         push      bx

; ------ kontrola pýeteŸen¡ okraj…

         mov       ax,ds:[ICORam]           ; r m
         cmp       dh,PVYSKA                ; je platn  souýadnice Y ?
         jae       GetPole4                 ; souýadnice mimo rozsah
         cmp       dl,PSIRKA                ; je platn  souýadnice X ?
         jae       GetPole4                 ; souýadnice mimo rozsah

; ------ naŸten¡ pýedmØtu

         mov       al,PSIRKA                ; poŸet pozic na ý dek
         mul       dh                       ; pýepoŸet ý dku na pozici
         add       al,dl                    ; pýiŸten¡ pozice
         adc       ah,0
         shl       ax,1                     ; offset v tabulce pole
         xchg      ax,bx                    ; BX <- offset v poli, AX <- pýedmØt
         mov       ax,ds:[bx+Pole]          ; naŸten¡ pýedmØtu

; ------ n vrat registr…

         stc                                ; pý¡znak operace OK
GetPole4:cmc                                ; CY = neplatn‚ souýadnice
GetPole6:pop       bx
         ret

GetPole  ENDP

; -----------------------------------------------------------------------------
;        inicializace gener toru n hody
; -----------------------------------------------------------------------------

InitRnd  PROC      NEAR

         push      ax
         push      es

         xor       ax,ax
         mov       es,ax
         mov       ax,es:[46ch]             ; Ÿ¡taŸ syst‚mov‚ho ŸasovaŸe
         mov       word ptr ds:[RandomR],ax ; inicializaŸn¡ konstanta

         pop       es
         pop       ax
         ret

InitRnd  ENDP

; -----------------------------------------------------------------------------
;        n hodn‚ Ÿ¡slo o rozsahu AX -> AX
; -----------------------------------------------------------------------------

RandomN  PROC      NEAR

; ------ pro 0 je jak‚koliv Ÿ¡slo

         or        ax,ax                    ; je 0 ?
         jz        Random                   ; je 0

; ------ £schova registr…

         push      bx
         push      cx

; ------ pý¡prava masky -> CX

         xor       cx,cx
RandomN2:stc
         rcl       cx,1                     ; naŸten¡ bitu
         cmp       ax,cx                    ; je rozah OK ?
         ja        RandomN2

; ------ n hodn‚ Ÿ¡slo -> AX

         xchg      ax,bx                    ; BX <- £schova rozsahu
RandomN3:call      Random                   ; vìpoŸet n hodn‚ho Ÿ¡sla
         and       ax,cx                    ; maskov n¡ Ÿ¡sla
         cmp       ax,bx                    ; je pýeteŸen¡ rozsahu ?
         jae       RandomN3                 ; je pýeteŸen¡ rozsahu

; ------ n vrat registr…

RandomN4:pop       cx
         pop       bx
         clc
         ret

RandomN  ENDP

; -----------------------------------------------------------------------------
;        n hodn‚ Ÿ¡slo -> AX
; -----------------------------------------------------------------------------

Random   PROC      NEAR

         push      bx
         push      cx
         push      dx

         mov       ax,word ptr ds:[RandomR]
         mov       bx,word ptr ds:[RandomR+2]
         mov       cx,ax
         mul       word ptr ds:[RandomD]
         shl       cx,1
         shl       cx,1
         shl       cx,1
         add       ch,cl
         add       dx,cx
         add       dx,bx
         shl       bx,1
         shl       bx,1
         add       dx,bx
         add       dh,bl
         mov       cl,5
         shl       bx,cl
         add       dh,bl
         add       ax,1
         adc       dx,0
         mov       word ptr ds:[RandomR],ax
         mov       word ptr ds:[RandomR+2],dx
         xchg      ax,dx

         pop       dx
         pop       cx
         pop       bx
         clc
         ret

Random   ENDP

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

; ------ definice Ÿ¡sel

ReadPrg2:mov       ax,ds:[DataNum]          ; konec programu
         mov       ds:[MainProg],ax         ; startovac¡ adresa
         mov       ds:[ProcBeg],ax          ; zaŸ tek procedur
         call      ReadStr                  ; naŸten¡ ýetØzec
         jc        ReadP302                 ; konec programu
         cmp       byte ptr ds:[ProgStr+1],"#" ; je definice promØnn‚ ?
         jne       ReadPr30                 ; nen¡ definice promØnn‚

; ------ naŸten¡ jm‚na promØnn‚

         call      ReadStr                  ; naŸten¡ dalç¡ho ýetØzce
         jc        ReadP302                 ; konec souboru

; ------ ulo§en¡ jm‚na promØnn‚

         mov       ch,0
         mov       cl,ds:[ProgStr]          ; d‚lka jm‚na promØnn‚
         inc       cx                       ; vŸetnØ d‚lky
         mov       si,offset ProgStr        ; jm‚no promØnn‚ s d‚lkou
ReaPrg21:cld
         lodsb                              ; naŸten¡ bajtu
         call      UpCase                   ; konverze na velk‚ p¡smeno
         call      StorPrg                  ; ulo§en¡ bajtu
         loop      ReaPrg21                 ; dalç¡ bajt

; ------ ulo§en¡ promØnn‚

         xor       ax,ax                    ; AX <- 0 inicializaŸn¡ hodnota
         call      StorPrg                  ; ni§ç¡ bajt
         call      StorPrg                  ; vyçç¡ bajt
         inc       word ptr ds:[PromNum]    ; Ÿ¡taŸ promØnnìch
         jmp       short ReadPrg2           ; dalç¡ promØnn 

; ------ definice procedur

ReadPrg3:mov       ax,ds:[DataNum]          ; konec programu
         mov       ds:[MainProg],ax         ; startovac¡ adresa
         call      ReadStr                  ; naŸten¡ ýetØzce
         jnc       ReadPr30
ReadP302:jmp       ReadPrg8                 ; konec souboru

ReadPr30:cmp       byte ptr ds:[ProgStr+1],"!" ; je definice procedury ?
         jne       ReadPr41                 ; nen¡ definice procedury

; ------ naŸten¡ jm‚na procedury

         call      ReadStr                  ; naŸten¡ dalç¡ho ýetØzce
         jc        ReadP302                 ; konec souboru

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
         cmp       byte ptr ds:[ProgStr+1],"#"
         je        ReadPr33                 ; definice Ÿ¡sla se ignoruje
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

         jmp       ReadPrg3                 ; dalç¡ procedura

; ------ naŸten¡ ýetØzce ze souboru

ReadPrg4:call      ReadStr                  ; naŸten¡ ýetØzce
         jc        ReadPrg8                 ; konec souboru

; ------ chyba, je-li definice procedury

ReadPr41:cmp       byte ptr ds:[ProgStr+1],"#"
         je        ReadPr42                 ; definice Ÿ¡sla
         cmp       byte ptr ds:[ProgStr+1],"!" ; je definice procedury ?
         jne       ReadPrg6                 ; nen¡ definice procedury
ReadPr42:mov       bp,offset ProcErr
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

; ------ vykreslen¡ obr zku s maskou

         cmp       al,KOD_MASK              ; je maska ?
         jne       ReadPri1                 ; nen¡ maska
         call      ReadStr                  ; naŸten¡ dalç¡ho ýetØzce
         jnc       ReadPr32                 ; ulo§en¡ definice obr zku
         jmp       ReadPri8                 ; konec souboru

; ------ ulo§en¡ intern¡ho pý¡kazu do bufferu programu

ReadPri1:call      StorPrg                  ; ulo§en¡ intern¡ho pý¡kazu
         jc        ReadPr19                 ; pýeteŸen¡ pamØti
         cmp       al,KOD_MUS               ; je hudba ?
         je        ReadPri2                 ; je hudba
         cmp       al,KOD_HLAS              ; je hl çen¡ ?
         je        ReadPri2                 ; je hl çen¡
         cmp       al,KOD_TEXT              ; je text ?
         je        ReadPri2                 ; je text
ReadPr18:clc                                ; pý¡znak operace OK
ReadPr19:ret                                ; CY = pýeteŸen¡ pamØti

; ------ ulo§en¡ ASCII textu pro hl çen¡ a text

ReadPri2:call      ReadStr                  ; naŸten¡ dalç¡ho ýetØzce
         jc        ReadPr19                 ; nen¡ ýetØzec
         mov       si,offset ProgStr+1      ; buffer s ýetØzcem
         mov       ch,0
         mov       cl,ds:[si-1]             ; d‚lka ýetØzce
         cmp       byte ptr ds:[si],'"'     ; je oznaŸen¡ textu " ?
         jne       ReadPr21                 ; nen¡ oznaŸen¡ textu
         inc       si                       ; pýeskoŸen¡ znaku "
         dec       cx                       ; sn¡§en¡ Ÿ¡taŸe d‚lky textu
ReadPr21:mov       al,cl                    ; AL <- d‚lka textu
         call      StorPrg                  ; ulo§en¡ bajtu do bufferu
         jc        ReadPr19                 ; chyba pamØti
         jcxz      ReadPr18                 ; je pr zdnì ýetØzec
ReadPr22:cld
         lodsb                              ; naŸten¡ znaku z bufferu
         call      StorPrg                  ; ulo§en¡ bajtu do bufferu
         jc        ReadPr19                 ; chyba pamØti
         loop      ReadPr22                 ; dalç¡ znak
         jmp       short ReadPr18           ; operace OK

; ------ nalezen¡ obr zku k vykreslen¡

ReadPri3:mov       al,KOD_OBR               ; pý¡kaz pro vykreslen¡ obr zku
ReadPr32:xchg      ax,cx                    ; CL <- £schova pý¡kazu
         call      SrcICO                   ; nalezen¡ obr zku
         xchg      ax,cx                    ; CX <- Ÿ¡slo ikony, AL <- pý¡kaz
         jc        ReadPri5                 ; obr zek nenalezen

; ------ ulo§en¡ pý¡kazu pro vykreslen¡ obr zku

         call      StorPrg                  ; ulo§en¡ intern¡ho pý¡kazu
         jc        ReadPri9                 ; pýeteŸen¡ pamØti
         xchg      ax,cx                    ; AX <- Ÿ¡slo obr zku

; ------ ulo§en¡ slova AX jako parametr

ReadPri4:call      StorPrg                  ; ulo§en¡ intern¡ho pý¡kazu
         jc        ReadPri9                 ; pýeteŸen¡ pamØti
         xchg      al,ah                    ; AL <- adresa obr zku HIGH
         call      StorPrg                  ; ulo§en¡ intern¡ho pý¡kazu
         jmp       short ReadPri9           ; konec nebo chyba pamØti

; ------ nalezen¡ procedury

ReadPri5:call      SrcPrik                  ; nalezen¡ pý¡kazu
         jc        ReadPr54                 ; nenalezen

; ------ ulo§en¡ identifik toru pý¡kazu

         push      ax
         mov       al,KOD_PROC
ReadPr52:call      StorPrg                  ; ulo§en¡ pý¡kazu
         pop       ax
         jc        ReadPri9                 ; chyba pamØti
         jmp       short ReadPri4           ; ulo§en¡ adresy

; ------ nalezen¡ promØnn‚

ReadPr54:call      SrcProm                  ; nalezen¡ promØnn‚
         jc        ReadPri6                 ; nenalezena

; ------ ulo§en¡ identifik toru promØnn‚

         push      ax
         mov       al,KOD_PROM              ; promØnn‚
         jmp       short ReadPr52           ; ulo§en¡ promØnn‚

; ------ naŸten¡ jako k¢d kl vesy

ReadPri6:call      ReadPKlv                 ; naŸten¡ jako k¢d kl vesy
         jnc       ReadP612                 ; k¢d kl vesy nalezen OK

; ------ naŸten¡ jako Ÿ¡slo - textovì parametr

         cmp       byte ptr ds:[ProgStr+1],'"' ; je text ?
         jne       ReadPr61                 ; nen¡ text
         xor       ax,ax                    ; pr zdnì pý¡kaz
         cmp       byte ptr ds:[ProgStr],2  ; je nØjakì znak ?
         jb        ReadP612                 ; nen¡ znak - pr zdnì ýetØzec
         mov       al,ds:[ProgStr+2]        ; znak ýetØzce
         jmp       short ReadP612

; ------ naŸten¡ jako Ÿ¡slo

ReadPr61:call      ReadPNum                 ; naŸten¡ jako Ÿ¡slo
         jc        ReadPr62                 ; chyba

; ------ ulo§en¡ hodnoty Ÿ¡sla

ReadP612:push      ax
         mov       al,KOD_CISL              ; k¢d pro Ÿ¡slo
         jmp       short ReadPr52           ; ulo§en¡ hodnoty Ÿ¡sla

; ------ chyba - nezn mì povel

ReadPr62:mov       si,offset ProgStr+1      ; pý¡kaz
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
;        naŸten¡ jako k¢d kl vesy -> AX, CY=nenalezeno
; -----------------------------------------------------------------------------

ReadPKlv PROC      NEAR

; ------ £schova registr…

         push      cx
         push      si
         push      di
         push      es

         push      ds
         pop       es                       ; ES <- datovì segment

; ------ test, zda je zaŸ tek k¢du kl vesy

         cmp       byte ptr ds:[ProgStr],3  ; minim ln¡ d‚lka
         jb        ReadPKl8                 ; je mal  d‚lka
         cmp       word ptr ds:[ProgStr+1],"_K" ; je k¢d kl vesy ?
         jne       ReadPKl8                 ; nen¡ k¢d kl vesy

; ------ pý¡prava k vyhled n¡ k¢du kl vesy

         cld
         mov       ch,0
         mov       di,offset KodKlav        ; tabulka k¢d… kl ves

; ------ pý¡prava k porovn n¡ jedn‚ kl vesy

ReadPKl2:mov       si,offset ProgStr+3      ; zaŸ tek textu kl vesy
         mov       al,ds:[ProgStr]          ; d‚lka ýetØzce
         sub       al,2                     ; bez zaŸ tku k¢du

; ------ porovn n¡ d‚lky kl vesy

         mov       cl,ds:[di]               ; d‚lka textu kl vesy
         inc       di                       ; zaŸ tek textu kl vesy
         cmp       al,cl                    ; souhlas¡ d‚lka textu kl vesy ?
         jne       ReadPKl6                 ; d‚lka textu kl vesy nesouhlas¡

; ------ porovn n¡ textu kl vesy

         push      cx
         push      di
         repe      cmpsb                    ; porovn n¡ textu kl vesy
         pop       di
         pop       cx
         jne       ReadPKl6                 ; text kl vesy nesouhlas¡

; ------ k¢d kl vesy nalezen OK

         add       di,cx                    ; adresa k¢du kl vesy
         mov       ax,ds:[di]               ; AX <- k¢d kl vesy
         clc                                ; pý¡znak operace OK
         jmp       short ReadPKl9

; ------ k¢d dalç¡ kl vesy

ReadPKl6:add       di,cx                    ; adresa k¢du kl vesy
         inc       di
         inc       di                       ; pýeskoŸen¡ k¢du kl vesy
         cmp       byte ptr ds:[di],0       ; je konec tabulky ?
         jne       ReadPKl2                 ; porovn n¡ dalç¡ kl vesy

; ------ n vrat registr…

ReadPKl8:stc                                ; pý¡znak neplatn‚ho k¢du
ReadPKl9:pop       es
         pop       di
         pop       si
         pop       cx
         ret

ReadPKlv ENDP

; -----------------------------------------------------------------------------
;        vyhled n¡ pý¡kazu DS:SI -> AX=adresa, CY=nenalezeno
; -----------------------------------------------------------------------------

SrcPrik  PROC      NEAR

; ------ £schova registr…

         push      bx
         push      cx
         push      di
         push      es

; ------ pý¡prava registr…

         mov       di,ds:[ProcBeg]          ; poŸ tek procedur
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
;        vyhled n¡ promØnn‚ DS:SI -> AX=adresa, CY=nenalezena
; -----------------------------------------------------------------------------

SrcProm  PROC      NEAR

; ------ £schova registr…

         push      bx
         push      cx
         push      di
         push      es

; ------ pý¡prava registr…

         xor       di,di                    ; poŸ tek promØnnìch
         mov       es,ds:[DataProg]         ; segment programu
         mov       bx,ds:[PromNum]          ; poŸet promØnnìch
         mov       ch,0

; ------ test, zda je dalç¡ promØnn 

SrcProm2:or        bx,bx                    ; je dalç¡ promØnn  ?
         stc                                ; pý¡znak nenalezen¡
         jz        SrcProm8                 ; nenalezena

; ------ porovn n¡ jm‚na promØnn‚

         mov       cl,es:[di]               ; d‚lka jm‚na procedury
         inc       cx                       ; vŸetnØ bajtu d‚lky
         push      cx
         push      si
         push      di
         repe      cmpsb                    ; porovn n¡ jm‚na
         pop       di
         pop       si
         pop       cx
         je        SrcProm6                 ; Ÿ¡slo nalezeno OK

; ------ dalç¡ promØnn 

         add       di,cx                    ; pýiŸten¡ d‚lky jm‚na
         inc       di
         inc       di                       ; pýeskoŸen¡ hodnoty promØnn‚
         dec       bx                       ; Ÿ¡taŸ promØnnìch
         jmp       short SrcProm2           ; dalç¡ hled n¡

; ------ adresa procedury -> AX

SrcProm6:mov       ax,di
         add       ax,cx                    ; pýiŸten¡ d‚lky jm‚na
         clc                                ; pý¡znak operace OK

; ------ n vrat registr…

SrcProm8:pop       es
         pop       di
         pop       cx
         pop       bx
         ret

SrcProm  ENDP

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
;        naŸten¡ parametru jako Ÿ¡slo -> AX, CY=nen¡ platn‚ Ÿ¡slo
; -----------------------------------------------------------------------------

ReadPNum PROC      NEAR

; ------ £schova registr…

         push      bx
         push      cx
         push      dx
         push      si

; ------ pý¡prava registr…

         xor       bx,bx                    ; nulov n¡ stýadaŸe
         mov       si,offset ProgStr+1      ; buffer
         mov       cl,ds:[si-1]             ; d‚lka ýetØzce
         mov       ch,0

; ------ naŸten¡ dalç¡ho znaku

ReadPNm2:clc                                ; pý¡znak operace OK
         jcxz      ReadPNm9                 ; je konec ýetØzce
         cld
         lodsb                              ; naŸten¡ dalç¡ho znaku
         dec       cx                       ; sn¡§en¡ Ÿ¡taŸe znak…

; ------ test, zda je znak Ÿ¡slice

         sub       al,"0"
         jb        ReadPNm8                 ; nen¡ to Ÿ¡slice
         cmp       al,9
         ja        ReadPNm8                 ; nen¡ to Ÿ¡slice

; ------ pýid n¡ Ÿ¡slice ke stýadaŸi

         mov       ah,0
         xchg      ax,bx                    ; AX <- stýadaŸ, BX <- Ÿ¡slice
         mov       dx,10                    ; n sobitel
         mul       dx                       ; posun stýadaŸe o ý d
         add       bx,ax                    ; pýid n¡ Ÿ¡slice ke stýadaŸi
         adc       dx,dx                    ; je pýeteŸen¡ ?
         jz        ReadPNm2                 ; nen¡ pýeteŸen¡
         mov       bx,-1                    ; omezen¡ pýi pýeteŸen¡
         jmp       short ReadPNm2           ; dalç¡ Ÿ¡slice

; ------ n vrat registr…

ReadPNm8:stc                                ; pý¡znak neplatn‚ho znaku
ReadPNm9:xchg      ax,bx                    ; AX <- naŸten‚ Ÿ¡slo
         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

ReadPNum ENDP

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

; ------ naŸten¡ textov‚ho ýetØzce

         cmp       al,"'"
         je        ReadSt11
         cmp       al,'"'
         jne       ReadSt16                 ; nen¡ ýetØzec
ReadSt11:mov       ah,al                    ; £schova ukonŸovac¡ho znaku
         mov       byte ptr ds:[ProgStr+1],'"' ; oznaŸen¡ textu
ReadSt12:call      ReadChr                  ; naŸten¡ dalç¡ho znaku
         jc        ReadStr6                 ; konec souboru
         cmp       al,ah                    ; je konec ýetØzce ?
         je        ReadStr6
         cmp       byte ptr ds:[ProgStr],255 ; je buffer plnì ?
         jae       ReadSt12                 ; buffer je plnì
         mov       ds:[di],al               ; ulo§en¡ znaku do bufferu
         inc       di                       ; zvìçen¡ ukazatele v bufferu
         inc       byte ptr ds:[ProgStr]    ; zvìçen¡ Ÿ¡taŸe d‚lky ýetØzce
         jmp       short ReadSt12           ; naŸten¡ dalç¡ho znaku

; ------ test prvn¡ho znaku, zda m…§e ýetØzec pokraŸovat

ReadSt16:cmp       al,"_"
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
;        vypuçtØn¡ mezer a koment ý… ze souboru -> CY=je konec souboru
; -----------------------------------------------------------------------------

ReadSpc  PROC      NEAR

; ------ vypuçtØn¡ mezer

         push      ax
ReadSpc1:call      ReadChr                  ; naŸten¡ znaku ze souboru
         jc        ReadSpc8                 ; konec souboru
         cmp       al," "                   ; je oddØlovaŸ ?
         jbe       ReadSpc1                 ; oddØlovaŸ se vypust¡

; ------ test, zda je zaŸ tek koment ýe

         cmp       al,"("                   ; m…§e to bìt koment ý ?
         jne       ReadSpc7                 ; nen¡ to koment ý
         call      ReadChr                  ; naŸten¡ dalç¡ho znaku
         jc        ReadSpc6                 ; nen¡ dalç¡ znak
         cmp       al,"*"                   ; je to koment ý ?
         jne       ReadSpc5                 ; nen¡ to koment ý

; ------ nalezen¡ konce koment ýe

ReadSpc2:call      ReadChr                  ; naŸten¡ dalç¡ho znaku
         jc        ReadSpc8                 ; konec souboru
ReadSpc3:cmp       al,"*"                   ; m…§e to bìt konec koment ýe ?
         jne       ReadSpc2                 ; nen¡ to konec koment ýe
         call      ReadChr                  ; naŸten¡ dalç¡ho znaku
         jc        ReadSpc8                 ; konec souboru
         cmp       al,")"                   ; je to konec koment ýe ?
         jne       ReadSpc3                 ; nen¡ to konec koment ýe
         jmp       short ReadSpc1           ; vypuçtØn¡ dalç¡ch mezer

; ------ n vrat znak…

ReadSpc5:call      ReadRet                  ; navr cen¡ znaku
ReadSpc6:mov       al,"("                   ; navracenì znak
ReadSpc7:call      ReadRet                  ; navr cen¡ znaku do bufferu
ReadSpc8:pop       ax
         ret

ReadSpc  ENDP

; -----------------------------------------------------------------------------
;        navr cen¡ znaku AL do bufferu -> NC
; -----------------------------------------------------------------------------

ReadRet  PROC      NEAR

         xchg      al,ds:[InpRetB]          ; navr cen¡ znaku do bufferu
         mov       ds:[InpRetB+1],al        ; druhì znak
         mov       al,ds:[InpRetB]
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
         xchg      al,ds:[InpRetB+1]
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
;        editace ikony AX (nutno inicializovat historii zmØn !!!)
; -----------------------------------------------------------------------------

EditIcon PROC      NEAR

; ------ £schova registr…

         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bl,ds:[Rezim]            ; aktu ln¡ re§im
         push      bx
         mov       byte ptr ds:[Rezim],4    ; re§im editace ikon

; ------ aktivnØ editovan  ikona

         mov       ds:[EditIcoC],ax         ; Ÿ¡slo editovan‚ ikony
         mov       word ptr ds:[EdiIHAkt],0 ; aktivn¡ ikona
         mov       word ptr ds:[BlokSize],0 ; nen¡ blok

; ------ zaýazen¡ ikony do historie ikon

         mov       cx,HistEdiM
         mov       si,offset EdiIHist-2
EdiIco12:inc       si
         inc       si
         xchg      ax,ds:[si]               ; vlo§en¡ ikony
         cmp       ax,ds:[EdiIHist]         ; je to aktivn¡ ikona ?
         je        EdiIco13                 ; je to aktivn¡ ikona - zruç¡ se
         loop      EdiIco12

; ------ pý¡prava ukazatel… ikon zmØn

EdiIco13:mov       ax,ds:[DataICO]          ; zaŸ tek ikon
         mov       ds:[BegHICO],ax          ; adresa prvn¡ ikony v historii
         mov       ds:[AktHICO],ax          ; aktu ln¡ ikona v historii
         mov       ax,ds:[DataNum]          ; poŸet bajt… programu
         add       ax,10h
         mov       cl,4
         shr       ax,cl                    ; pýepoŸet na odstavce
         add       ax,ds:[DataProg]         ; adresa konce programu
         mov       ds:[MinHICO],ax          ; minim ln¡ adresa ikon

; ------ zobrazen¡ r mu kolem hrac¡ plochy

         call      DispRam                  ; zobrazen¡ r mu kolem hrac¡ plochy

; ------ zobrazen¡ r mu kolem menu

         call      MenuRam                  ; zobrazen¡ r mu kolem menu

; ------ zobrazen¡ menu

         call      DispMenu                 ; zobrazen¡ menu

         call      EdiIDNam                 ; zobrazen¡ jm‚na ikony

; ------ vymaz n¡ plochy voleb

         call      MouseOff                 ; vypnut¡ kurzoru myçi

         mov       dh,1                     ; ukazatel ý dku
         mov       ax,ds:[ICOMenu]          ; plocha menu
EdiIco14:mov       dl,1+32*2                ; pozice
         call      DispIcon                 ; zobrazen¡ ikony plochy
         add       dl,4
         call      DispIcon
         add       dh,4
         cmp       dh,1+PVYSKA*4
         jb        EdiIco14
         mov       word ptr ds:[MousZPoz],-1 ; kurzor myçi neplatnì

; ------ zobrazen¡ editovan‚ plochy

EdiIcon3:call      EdiIDisp                 ; zobrazen¡ editovan‚ ikony
         call      EdiVDis                  ; zobrazen¡ voleb editoru
         call      EdiIPush                 ; ulo§en¡ zmØn

; ------ Ÿek n¡ na stisk kl vesy nebo stisk myçi

EdiIcon4:call      BlokKDis                 ; obsluha zobrazov n¡ kurzoru bloku
;         call      MouseOn                  ; zapnut¡ kurzoru myçi
         call      MousDPoz                 ; zobrazen¡ pozice kurzoru myçi
         call      InpChar                  ; vstup znaku z kl vesnice
         jnc       EdiIcon7                 ; je kl vesa

; ------ Ÿten¡ tlaŸ¡tka myçi

         call      IntMouse                 ; obsluha myçi
         jc        EdiIcon4                 ; nen¡ zmØna

; ------ test, zda je vyvol n¡ akce stiskem tlaŸ¡tka myçi

         test      byte ptr ds:[MouseK],bit2+bit3 ; je stisk tlaŸ¡tka ?
         jz        EdiIcon4                 ; nen¡ stisk tlaŸ¡tka myçi

; ------ souýadnice X

         mov       cx,ds:[MouseX]
         shr       cx,1
         shr       cx,1
         shr       cx,1

; ------ obsluha editace

         cmp       cx,1+32*2
         jae       EdiIcon5                 ; nen¡ editaŸn¡ pole
         call      EdiEdit                  ; obsluha editace
;         call      EdiIPush                 ; ulo§en¡ zmØn
         jmp       short EdiIcon3

; ------ souýadnice X

EdiIcon5:dec       cx
         js        EdiIcon4                 ; neplatn  souýadnice X

; ------ souýadnice Y -> DX = (Y-1)

         mov       dx,ds:[MouseY]
         sub       dx,8
         jb        EdiIcon4                 ; neplatn  souýadnice Y
         cmp       dx,PVYSKA*32
         jae       EdiIcon4                 ; neplatn  souýadnice Y

; ------ menu volby barev

         cmp       cx,32*2+8
         jae       EdiIcon6                 ; nen¡ volba barev
         call      EdiVCol                  ; menu volby barev a ikony
         jmp       short EdiIcon3           ; nov‚ zobrazen¡ vçeho

; ------ menu volby funkce

EdiIcon6:mov       cl,5
         shr       dx,cl                    ; DL = Ÿ¡slo ikony

         call      Edi7EEnd                 ; ukonŸen¡ editace bloku
         cmp       dl,5                     ; je volba funkce ?
         ja        EdiIco62                 ; nen¡ volba funkce
         mov       ds:[FunkceEd],dl         ; je volba funkce
         jmp       EdiIcon3                 ; zobrazen¡ vçeho

EdiIco62:shl       dx,1
         mov       bx,dx                    ; BX <- ikona * 2
         jmp       word ptr cs:[bx+EdiIMTbl-2*6] ; skok na funkci ikony

; ------ vstup znaku z kl vesnice

EdiIcon7:;call      VolKVyp                  ; vypnut¡ kurzoru

         call      Edi7EEnd                 ; ukonŸen¡ editace bloku

; ------ n vrat registr…

EdiIcon9:pop       bx
         mov       ds:[Rezim],bl            ; n vrat re§imu
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

EditIcon ENDP

EdiIMTbl label     word
         dw        EdiIBRet                 ; 6: naŸten¡ blok
         dw        EdiIFlip                 ; 7: pýevr cen¡
         dw        EdiIRot                  ; 8: rotace
         dw        EdiIXCol                 ; 9: z mØna barev
         dw        EdiIUndo                 ; 10: obnoven¡
         dw        EdiIRedo                 ; 11: navr cen¡ obnoven¡
         dw        EdiISave                 ; 12: ulo§en¡
         dw        EdiIcon9                 ; 13: konec

; ------ UNDO

EdiIUndo:mov       ax,ds:[AktHICO]          ; aktu ln¡ ikona v historii
         add       ax,ICOSize/16            ; adresa dalç¡ ikony
         cmp       ax,ds:[DataICO]          ; je dalç¡ ikona ?
         jae       EdiIUnd8                 ; nen¡ dalç¡ ikona
EdiIUnd6:mov       ds:[AktHICO],ax          ; nov  aktivn¡ ikona
         call      EdiIPop                  ; n vrat ikony
EdiIUnd8:jmp       EdiIcon3

; ------ REDO

EdiIRedo:mov       ax,ds:[AktHICO]          ; aktu ln¡ ikona v historii
         sub       ax,ICOSize/16            ; adresa pýedeçl‚ ikony
         cmp       ax,ds:[BegHICO]          ; je pýedeçl  ikona ?
         jb        EdiIUnd8                 ; nen¡ pýedeçl  ikona
         jmp       short EdiIUnd6

; ------ navr cen¡ bloku

EdiIBRet:mov       ax,ds:[BlokSiz2]         ; uschovan  velikost bloku
         or        ax,ax                    ; je nØjakì blok ?
         jz        EdiIUnd8                 ; nen¡ blok
         mov       ds:[BlokSize],ax         ; navr cen¡ velikosti bloku
         mov       byte ptr ds:[FunkceEd],6 ; pý¡znak oznaŸen¡ bloku
         jmp       short EdiIUnd8

; ------ pýevr cen¡

EdiIFlip:mov       dh,0                     ; ukazatel ý dku
EdiIFlp2:mov       dl,0                     ; ukazatel stoupaj¡c¡ pozice
         mov       bl,31                    ; ukazatel klesaj¡c¡ pozice
EdiIFlp3:call      EdiGetB                  ; naŸten¡ bodu z DX
         mov       ah,al                    ; AH <- £schova bodu
         xchg      bl,dl                    ; z mØna souýadnic
         call      EdiGetB                  ; naŸten¡ bodu z BX
         xchg      al,ah                    ; z mØna bod…
         call      EdiSetB                  ; nastaven¡ bodu do BX
         xchg      bl,dl                    ; n vrat souýadnic
         xchg      al,ah                    ; z mØna bod…
         call      EdiSetB                  ; nastaven¡ bodu do DX
         inc       dx                       ; zvìçen¡ stoupaj¡c¡ho ukazatele
         dec       bx                       ; sn¡§en¡ klesaj¡c¡ho ukazatele
         cmp       dl,16
         jb        EdiIFlp3
         inc       dh
         cmp       dh,32
         jb        EdiIFlp2
         jmp       short EdiIUnd8

; ------ rotace

EdiIRot: mov       dh,0                     ; ukazatel ý dku Y
EdiIRot2:mov       dl,dh                    ; ukazatel pozice X
EdiIRot3:call      EdiGetB                  ; naŸten¡ bodu
         mov       ah,al                    ; AH <- £schova bodu

         mov       cx,4
EdiIRot4:xchg      dl,dh
         sub       dh,31
         neg       dh
         call      EdiGetB
         xchg      al,ah
         call      EdiSetB
         loop      EdiIRot4

         inc       dx
         mov       al,31
         sub       al,dh
         cmp       dl,al
         jb        EdiIRot3
         inc       dh
         cmp       dh,16
         jb        EdiIRot2
         jmp       EdiIcon3

; ------ z mØna barev

EdiIXCol:mov       dh,0                     ; ukazatel ý dku
EdiIXCl2:mov       dl,0                     ; ukazatel pozice
EdiIXCl3:call      EdiGetB                  ; naŸten¡ bodu
         cmp       al,ds:[ColLeft]          ; je barva pro lev‚ tlaŸ¡tko ?
         jne       EdiIXCl4
         mov       al,ds:[ColRight]
         jmp       short EdiIXCl5

EdiIXCl4:cmp       al,ds:[ColRight]         ; je barva pro prav‚ tlaŸ¡tko ?
         jne       EdiIXCl6
         mov       al,ds:[ColLeft]
EdiIXCl5:call      EdiSetB                  ; nastaven¡ bodu

EdiIXCl6:inc       dl
         cmp       dl,32
         jb        EdiIXCl3
         inc       dh
         cmp       dh,32
         jb        EdiIXCl2
         jmp       EdiIcon3

; -----------------------------------------------------------------------------
;        zobrazen¡ jm‚na aktivn¡ ikony
; -----------------------------------------------------------------------------

EdiIDNam PROC      NEAR

         push      ax
         push      cx
         push      si

         mov       ax,ds:[EditIcoC]         ; Ÿ¡slo aktivn¡ ikony
         call      GetIName                 ; naŸten¡ jm‚na ikony AX
         xor       ax,ax                    ; barva textu = Ÿern 
         mov       cx,-1                    ; doba
         mov       si,offset ProgStr        ; buffer s textem
         call      DispHlas                 ; zobrazen¡ jm‚na ikony

         pop       si
         pop       cx
         pop       ax
         ret

EdiIDNam ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ aktu ln¡ pozice kurzoru myçi
; -----------------------------------------------------------------------------

MousDPoz PROC      NEAR

; ------ £schova registr…

         push      ax
         push      bx
         push      cx
         push      dx

; ------ aktu ln¡ souýadnice kurzoru myçi -> DX

         call      EdiGetM                  ; poskytnut¡ pozice kurzoru
         cmp       dx,ds:[MousZPoz]         ; je pozice zmØnØna ?
         je        MousDPz9                 ; pozice nen¡ zmØnØna
         mov       ds:[MousZPoz],dx         ; £schova zobrazen‚ pozice
         mov       cx,dx                    ; CX <- £schova souýadnic

; ------ vymaz n¡ pol¡Ÿka

         mov       dx,(1+32*2+2) + (1 + 5*4 + 2)*HI
         mov       ax,ds:[ICOMenu]          ; plocha menu
         call      DispIcon                 ; zobrazen¡ ikony plochy

; ------ zobrazen¡ souýadnice X

         mov       al,"X"                   ; oznaŸen¡ souýadnice X
         mov       dx,(1 + 5*4 + 2)*8       ; linka k zobrazen¡ textu
         call      MousDPz2                 ; zobrazen¡ souýadnice X

; ------ zobrazen¡ souýadnice Y

         mov       cl,ch                    ; souýadnice Y
         mov       al,"Y"                   ; oznaŸen¡ souýadnice Y
         mov       dx,(1 + 5*4 + 4)*8       ; linka k zobrazen¡ textu
         call      MousDPz2                 ; zobrazen¡ souýadnice Y

; ------ n vrat registr…

MousDPz9:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

MousDPoz ENDP

; ------ zobrazen¡ souýadnice

MousDPz2:mov       ah,0                     ; barva k zobrazen¡ textu
         mov       bx,1+32*2+2              ; pozice k zobrazen¡
         call      DispChr                  ; zobrazen¡ znaku "X" nebo "Y"
         mov       al,"="
         call      DispChr                  ; zobrazen¡ znaku "="

         mov       al,cl                    ; pozice nebo ý dek
         aam                                ; rozdØlen¡ na Ÿ¡slice
         push      ax
         xchg      al,ah
         or        al,al                    ; jsou des¡tky ?
         jz        MousDPz4                 ; nejsou des¡tky
         add       al,"0"                   ; korekce na ASCII znak
         mov       ah,0                     ; barva
         call      DispChr                  ; zobrazen¡ des¡tek
MousDPz4:pop       ax
         add       al,"0"                   ; korekce na ASCII znak
         mov       ah,0                     ; barva
         call      DispChr                  ; zobrazen¡ jednotek
         ret

; -----------------------------------------------------------------------------
;        ulo§en¡ ikony na disk
; -----------------------------------------------------------------------------

; ------ ukonŸen¡ obsluhy bloku

EdiISave:call      Edi7EEnd                 ; ukonŸen¡ editace bloku

; ------ pý¡prava jm‚na ikony

         mov       ax,ds:[EditIcoC]         ; Ÿ¡slo aktivn¡ ikony
         call      GetIName                 ; naŸten¡ jm‚na ikony AX
         jnc       EdiISav0
         jmp       EdiIcon3                 ; jm‚no ikony nenalezeno

; ------ pý¡prava z hlav¡ ikony

EdiISav0:push      ds
         pop       es
         mov       di,offset SoubICO        ; soubor ikony
         mov       si,offset VzorICO        ; vzor ikony
         mov       cx,offset(IcoBuff-SoubICO) ; d‚lka z hlav¡
         cld
         rep       movsb                    ; pýenesen¡ z hlav¡ ikony

; ------ pýenesen¡ dat ikony

         push      ds
         mov       cx,128                   ; poŸet bajt… k pýenesen¡

         push      es
         mov       ax,ds:[EditIcoC]         ; Ÿ¡slo ikony
         call      AdrICO                   ; adresa ikony -> ES
         push      es
         pop       ds                       ; DS <- adresa ikonu
         pop       es
         cld

         mov       si,31*32/8               ; adresa posledn¡ho ý dku
         mov       dh,32/8                  ; poŸet bajt… na ý dek
EdiISv04:mov       dl,bit7                  ; bitov  maska
EdiISav1:mov       al,0                     ; stýadaŸ dat

         test      byte ptr ds:[si+4*128],dl ; je pozad¡ ?
         jz        EdiISav5                 ; je pozad¡
         test      byte ptr ds:[si],dl      ; je bit nastaven ?
         jz        EdiISav2                 ; nen¡ nastaven
         or        al,bit4
EdiISav2:test      byte ptr ds:[si+128],dl
         jz        EdiISav3
         or        al,bit5
EdiISav3:test      byte ptr ds:[si+2*128],dl
         jz        EdiISav4
         or        al,bit6
EdiISav4:test      byte ptr ds:[si+3*128],dl
         jz        EdiISav5
         or        al,bit7

EdiISav5:shr       dl,1

         test      byte ptr ds:[si+4*128],dl ; je pozad¡ ?
         jz        EdiISav9                 ; je pozad¡
         test      byte ptr ds:[si],dl      ; je bit nastaven ?
         jz        EdiISav6                 ; nen¡ nastaven
         or        al,bit0
EdiISav6:test      byte ptr ds:[si+128],dl
         jz        EdiISav7
         or        al,bit1
EdiISav7:test      byte ptr ds:[si+2*128],dl
         jz        EdiISav8
         or        al,bit2
EdiISav8:test      byte ptr ds:[si+3*128],dl
         jz        EdiISav9
         or        al,bit3

EdiISav9:shr       dl,1
         stosb                              ; ulo§en¡ bajtu
         jnz       EdiISav1                 ; dalç¡ ukl danì bajt
         inc       si                       ; zvìçen¡ Ÿtec¡ adresy
         dec       dh
         jnz       EdiISv92
         mov       dh,32/8
         sub       si,2*32/8
EdiISv92:loop      EdiISv04                 ; dalç¡ bajt

         mov       cl,128
         mov       si,4*32*32/8+31*32/8     ; posledn¡ ý dek masky
         mov       dh,32/8
EdiISavA:lodsb
         not       al
         stosb                              ; ulo§en¡ masky
         dec       dh
         jnz       EdiISavB
         mov       dh,32/8
         sub       si,2*32/8
EdiISavB:loop      EdiISavA

         pop       ds

; ------ otevýen¡ souboru pro z pis

         mov       byte ptr ds:[ProgStr],"\" ; oddØlovaŸ adres re
         mov       dx,offset JmenoICO       ; jm‚no souboru
         mov       ah,3ch
         xor       cx,cx
         int       21h                      ; vytvoýen¡ souboru
         jc        EdiISav9                 ; chyba
         xchg      ax,bx                    ; BX <- identifik tor souboru

; ------ z pis dat ikony

         mov       dx,offset SoubICO        ; soubor ikony
         mov       cx,offset(SoubICO2-SoubICO) ; velikost ikony
         mov       ah,40h
         int       21h                      ; z pis ikony na disk

; ------ uzavýen¡ souboru ikony

         mov       ah,3eh
         int       21h                      ; uzavýen¡ souboru ikony
         jmp       EdiIcon3

; -----------------------------------------------------------------------------
;        souýadnice kurzoru myçi -> DX (s omezen¡m na editovan‚ pole)
; -----------------------------------------------------------------------------

EdiGetM  PROC      NEAR

; ------ £schova registr…

         push      ax
         push      cx

; ------ souýadnice X

         mov       cx,ds:[MouseX]           ; souýadnice myçi X
         shr       cx,1
         shr       cx,1
         shr       cx,1                     ; pýevod na bajty
         dec       cx                       ; odeŸten¡ poŸ tku
         jns       EdiGetM2                 ; nen¡ podteŸen¡
         xor       cx,cx                    ; CX <- omezen¡ pýi podteŸen¡
EdiGetM2:shr       cx,1                     ; pýevod na body
         cmp       cl,32                    ; je pozice OK ?
         jb        EdiGetM3
         mov       cl,31                    ; omezen¡ pozice

; ------ souýadnice Y

EdiGetM3:mov       dx,ds:[MouseY]           ; souýadnice myçi Y
         sub       dx,8                     ; odeŸten¡ poŸ tku
         jnc       EdiGetM4                 ; nen¡ podteŸen¡
         xor       dx,dx                    ; DX <- omezen¡ pýi podteŸen¡
EdiGetM4:xchg      ax,dx                    ; AX <- souýadnice Y relativnØ
         mov       ch,14                    ; poŸet linek na ý dek
         div       ch                       ; pýepoŸet na ý dek
         cmp       al,32                    ; je pýeteŸen¡ ?
         jb        EdiGetM5                 ; nen¡ pýeteŸen¡
         mov       al,31                    ; omezen¡ ý dku
EdiGetM5:mov       dh,al                    ; DH <- ý dek v ikonØ
         mov       dl,cl                    ; DL <- pozice v ikonØ

; ------ n vrat registr…

         pop       cx
         pop       ax
         ret

EdiGetM  ENDP

; -----------------------------------------------------------------------------
;        ulo§en¡ ikony do historie zmØn (je-li zmØnØn )
; -----------------------------------------------------------------------------

EdiIPush PROC      NEAR

; ------ £schova registr…

         push      ax
         push      cx
         push      si
         push      di
         push      ds
         push      es

; ------ test, zda je ikona ulo§ena

         cld
         mov       ax,ds:[AktHICO]          ; aktu ln¡ ikona
         cmp       ax,ds:[DataICO]          ; je nØjak  ikona ?
         jae       EdiIPsh2                 ; nen¡ § dn  ikona

         push      ds

         push      ax
         mov       ax,ds:[EditIcoC]         ; Ÿ¡slo editovan‚ ikony
         call      AdrICO                   ; adresa ikony -> ES
         pop       ax
         mov       ds,ax                    ; DS <- aktu ln¡ ikona v historii
         mov       cx,ICOSize/2             ; veliksot ikony ve slovech
         xor       si,si
         xor       di,di
         repe      cmpsw                    ; porovn n¡ ikony
         pop       ds
         je        EdiIPsh6                 ; ikona nen¡ zmØnØna

; ------ adresa nov‚ ikony (AX=aktivn¡ ikona)

EdiIPsh2:sub       ax,ICOSize/16            ; adresa pýedeçl‚ ikony
         cmp       ax,ds:[MinHICO]          ; je platn  adresa ?
         jae       EdiIPsh4                 ; adresa je OK

; ------ zkr cen¡ historie

         call      EdiIDel                  ; zkr cen¡ historie
         mov       ax,ds:[BegHICO]          ; adresa prvn¡ ikony
         sub       ax,ICOSize/16            ; adresa pýedeçl‚ ikony

; ------ pýenos ikony

EdiIPsh4:mov       ds:[BegHICO],ax          ; adresa prvn¡ ikony
         mov       ds:[AktHICO],ax          ; aktu ln¡ ikona

         push      ax                       ; AX = adresa nov‚ ikony
         mov       ax,ds:[EditIcoC]         ; Ÿ¡slo editovan‚ ikony
         call      AdrICO                   ; adresa ikony -> ES
         push      es
         pop       ds                       ; DS <- adresa ikony
         pop       es                       ; ES <- nov  ikona

         mov       cx,ICOSize/2             ; veliksot ikony ve slovech
         xor       si,si
         xor       di,di
         rep       movsw                    ; pýenos dat ikony

; ------ n vrat registr…

EdiIPsh6:pop       es
         pop       ds
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

EdiIPush ENDP

; -----------------------------------------------------------------------------
;        n vrat ikony z historie
; -----------------------------------------------------------------------------

EdiIPop  PROC      NEAR

; ------ £schova registr…

         push      ax
         push      cx
         push      si
         push      di
         push      ds
         push      es

; ------ pýenos ikony

         mov       ax,ds:[EditIcoC]         ; AX <- Ÿ¡slo editovan‚ ikony
         call      AdrICO                   ; adresa ikony -> ES
         mov       ds,ds:[AktHICO]          ; adresa aktivn¡ ikony v historii
         mov       cx,ICOSize/2             ; veliksot ikony ve slovech
         xor       si,si
         xor       di,di
         rep       movsw                    ; pýenos dat ikony

; ------ n vrat registr…

         pop       es
         pop       ds
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

EdiIPop  ENDP

; -----------------------------------------------------------------------------
;        zkr cen¡ historie zmØn na polovinu
; -----------------------------------------------------------------------------

EdiIDel  PROC      NEAR

; ------ £schova registr…

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

; ------ vìpoŸet zbylìch ikon -> AX

         mov       ax,ds:[DataICO]          ; adresa ikon
         sub       ax,ds:[AktHICO]          ; velikost ikon
         shr       ax,1                     ; polovina
         xor       dx,dx                    ; DX <- 0
         mov       cx,ICOSize/16            ; velikost v odstavc¡ch
         div       cx                       ; pýepoŸet na poŸet ikon

; ------ adresa nov‚ho poŸ tku -> DX

         xchg      ax,cx                    ; CX <- poŸet ikon, AX <- velikost
         mul       cx                       ; pýepoŸet na velikost ikon
         mov       dx,ds:[DataICO]          ; adresa ikon
         sub       dx,ax                    ; DX <- adresa poŸ tku

; ------ nov‚ ukazatele ikon

         mov       bx,dx                    ; BX <- novì poŸ tek
         mov       ds:[AktHICO],dx          ; aktu ln¡ ikona v historii
         xchg      ds:[BegHICO],dx          ; novì poŸ tek ikon, DX <- starì
         jcxz      EdiIDel9                 ; nezbyla § dn  ikona
         mov       bp,cx                    ; BP <- poŸet ikon

; ------ pýenos ikon

         cld
EdiIDel2:mov       ds,dx                    ; DS <- starì poŸ tek ikon
         mov       es,bx                    ; ES <- novì poŸ tek ikon
         mov       cx,ICOSize/2             ; veliksot ikony ve slovech
         xor       si,si
         xor       di,di
         rep       movsw                    ; pýenos dat jedn‚ ikony
         add       dx,ICOSize/16            ; dalç¡ star  ikona
         add       bx,ICOSize/16            ; dalç¡ nov  ikona
         dec       bp                       ; Ÿ¡taŸ ikon
         jnz       EdiIDel2                 ; dalç¡ ikona

; ------ n vrat registr…

EdiIDel9:pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

EdiIDel  ENDP

; -----------------------------------------------------------------------------
;        obsluha editace - tu§ka
; -----------------------------------------------------------------------------

EdiEdit  PROC      NEAR

         cmp       byte ptr ds:[FunkceEd],0 ; je pero ?
         jne       Edi2Edit                 ; nen¡ pero

         call      EdiGetM                  ; adresa pozice kurzoru myçi -> DX
         mov       ds:[EdiBegPz],dx         ; vìchoz¡ pozice kurzoru

EdiEdit0:mov       bx,ds:[EdiBegPz]         ; BX <- poŸ teŸn¡ bod
         call      EditLine                 ; nakreslen¡ Ÿ ry
         mov       ds:[EdiBegPz],dx         ; nov  pozice kurzoru

; ------ zobrazen¡ ikony

         call      EdiEdDis                 ; zobrazen¡ ikony pýi editaci

; ------ Ÿek n¡ na zmØnu myçi

EdiEdit1:
;         call      MouseOn                  ; zapnut¡ kurzoru myçi
         call      MousDPoz                 ; zobrazen¡ pozice kurzoru myçi
         call      InpChar                  ; vstup znaku z kl vesnice
         jnc       EdiEdit8                 ; je znak z kl vesnice
         call      IntMouse                 ; obsluha myçi
         jc        EdiEdit1                 ; nen¡ zmØna

         call      EdiGetM                  ; adresa pozice kurzoru myçi -> DX
         test      byte ptr ds:[MouseK],bit2+bit3 ; je stisk dalç¡ho tlaŸ¡tka ?
         jnz       EdiEdit0                 ; je stisk dalç¡ho tlaŸ¡tka

         test      byte ptr ds:[MouseK],bit4+bit5 ; je konec ?
         jnz       EdiEdit8                 ; je uvolnØn¡ tlaŸ¡tka myçi

         test      byte ptr ds:[MouseK],bit7
         jz        EdiEdit1                 ; nen¡ posun myç¡

         cmp       dx,ds:[EdiBegPz]         ; je zmØna pozice ?
         je        EdiEdit1                 ; nen¡ zmØna pozice
         jmp       short EdiEdit0

EdiEdit8:ret

EdiEdit  ENDP

; ------ zobrazen¡ ikon pýi editaci

EdiEdDis PROC      NEAR

         call      EdiIDisp                 ; zobrazen¡ editovan‚ ikony
         call      EdiVDis                  ; zobrazen¡ voleb editoru

;         push      bx
;         push      dx
;         push      es
;
;         mov       bx,ds:[EdiIHAkt]         ; aktu ln¡ ikona v historii
;         mov       dh,bl                    ; aktu ln¡ ikona v historii
;         shl       dh,1
;         shl       dh,1                     ; * 4
;         add       dh,2
;         mov       dl,1+32*2+2
;         shl       bx,1
;         mov       es,ds:[EdiIHist+bx]      ; adresa aktivn¡ ikony
;         call      DispIcon                 ; zobrazen¡ mal‚ ikony
;
;         pop       es
;         pop       dx
;         pop       bx

         ret

EdiEdDis ENDP

; -----------------------------------------------------------------------------
;        obsluha editace - Ÿ ra
; -----------------------------------------------------------------------------

Edi2Edit PROC      NEAR

         cmp       byte ptr ds:[FunkceEd],1 ; je Ÿ ra ?
         jne       Edi3Edit                 ; nen¡ Ÿ ra

         call      EdiGetM                  ; adresa pozice kurzoru myçi -> DX
         mov       ds:[EdiBegPz],dx         ; £schova pozice poŸ tku operace
         jmp       short Edi2Edi3

Edi2Edi2:call      EdiGetM                  ; adresa pozice kurzoru myçi -> DX
         cmp       dx,ds:[EdiOldPz]         ; byla pozice zmØnØna ?
         je        Edi2Edi4                 ; pozice nebyla zmØnØna
         call      EdiIPop                  ; n vrat ikony
Edi2Edi3:mov       ds:[EdiOldPz],dx         ; £schova nov‚ pozice
         mov       bx,ds:[EdiBegPz]         ; BX <- poŸ teŸn¡ bod
         call      EditLine                 ; nakreslen¡ Ÿ ry

; ------ zobrazen¡ ikony

         call      EdiEdDis                 ; zobrazen¡ ikony pýi editaci

; ------ Ÿek n¡ na zmØnu myçi

Edi2Edi4:
;         call      MouseOn                  ; zapnut¡ kurzoru myçi
         call      MousDPoz                 ; zobrazen¡ pozice kurzoru myçi
         call      InpChar                  ; vstup znaku z kl vesnice
         jnc       Edi2Edi8                 ; je znak z kl vesnice
         call      IntMouse                 ; obsluha myçi
         jc        Edi2Edi4                 ; nen¡ zmØna

         test      byte ptr ds:[MouseK],bit2+bit3 ; je stisk dalç¡ho tlaŸ¡tka ?
         jnz       Edi2Edi2                 ; je stisk dalç¡ho tlaŸ¡tka

         test      byte ptr ds:[MouseK],bit4+bit5 ; je konec ?
         jnz       Edi2Edi8                 ; je uvolnØn¡ tlaŸ¡tka myçi

         test      byte ptr ds:[MouseK],bit7
         jnz       Edi2Edi2                 ; obsluha myçi
         jmp       short Edi2Edi4

Edi2Edi8:ret

Edi2Edit ENDP

; -----------------------------------------------------------------------------
;        obsluha editace - Ÿtverec
; -----------------------------------------------------------------------------

Edi3Edit PROC      NEAR

         cmp       byte ptr ds:[FunkceEd],2 ; je Ÿtverec ?
         jne       Edi4Edit                 ; nen¡ Ÿtverec

         call      EdiGetM                  ; adresa pozice kurzoru myçi -> DX
         mov       ds:[EdiBegPz],dx         ; £schova pozice poŸ tku operace
         jmp       short Edi3Edi3

Edi3Edi2:call      EdiGetM                  ; adresa pozice kurzoru myçi -> DX
         cmp       dx,ds:[EdiOldPz]         ; byla pozice zmØnØna ?
         je        Edi3Edi4                 ; pozice nebyla zmØnØna
         call      EdiIPop                  ; n vrat ikony
Edi3Edi3:mov       ds:[EdiOldPz],dx         ; £schova nov‚ pozice
         mov       bx,ds:[EdiBegPz]         ; BX <- poŸ teŸn¡ bod
         call      EditCtve                 ; nakreslen¡ Ÿtverce

; ------ zobrazen¡ ikony

         call      EdiEdDis                 ; zobrazen¡ ikony pýi editaci

; ------ Ÿek n¡ na zmØnu myçi

Edi3Edi4:
;         call      MouseOn                  ; zapnut¡ kurzoru myçi
         call      MousDPoz                 ; zobrazen¡ pozice kurzoru myçi
         call      InpChar                  ; vstup znaku z kl vesnice
         jnc       Edi3Edi8                 ; je znak z kl vesnice
         call      IntMouse                 ; obsluha myçi
         jc        Edi3Edi4                 ; nen¡ zmØna

         test      byte ptr ds:[MouseK],bit2+bit3 ; je stisk dalç¡ho tlaŸ¡tka ?
         jnz       Edi3Edi2                 ; je stisk dalç¡ho tlaŸ¡tka

         test      byte ptr ds:[MouseK],bit4+bit5 ; je konec ?
         jnz       Edi3Edi8                 ; je uvolnØn¡ tlaŸ¡tka myçi

         test      byte ptr ds:[MouseK],bit7
         jnz       Edi3Edi2                 ; obsluha myçi
         jmp       short Edi3Edi4

Edi3Edi8:ret

Edi3Edit ENDP

; -----------------------------------------------------------------------------
;        obsluha editace - kruh
; -----------------------------------------------------------------------------

Edi4Edit PROC      NEAR

         cmp       byte ptr ds:[FunkceEd],3 ; je kruh ?
         jne       Edi5Edit                 ; nen¡ kruh

         call      EdiGetM                  ; adresa pozice kurzoru myçi -> DX
         mov       ds:[EdiBegPz],dx         ; £schova pozice poŸ tku operace
         jmp       short Edi4Edi3

Edi4Edi2:call      EdiGetM                  ; adresa pozice kurzoru myçi -> DX
         cmp       dx,ds:[EdiOldPz]         ; byla pozice zmØnØna ?
         je        Edi4Edi4                 ; pozice nebyla zmØnØna
         call      EdiIPop                  ; n vrat ikony
Edi4Edi3:mov       ds:[EdiOldPz],dx         ; £schova nov‚ pozice
         mov       bx,ds:[EdiBegPz]         ; BX <- poŸ teŸn¡ bod
         call      EditKruh                 ; nakreslen¡ kruhu

; ------ zobrazen¡ ikony

         call      EdiEdDis                 ; zobrazen¡ ikony pýi editaci

; ------ Ÿek n¡ na zmØnu myçi

Edi4Edi4:
;         call      MouseOn                  ; zapnut¡ kurzoru myçi
         call      MousDPoz                 ; zobrazen¡ pozice kurzoru myçi
         call      InpChar                  ; vstup znaku z kl vesnice
         jnc       Edi4Edi8                 ; je znak z kl vesnice
         call      IntMouse                 ; obsluha myçi
         jc        Edi4Edi4                 ; nen¡ zmØna

         test      byte ptr ds:[MouseK],bit2+bit3 ; je stisk dalç¡ho tlaŸ¡tka ?
         jnz       Edi4Edi2                 ; je stisk dalç¡ho tlaŸ¡tka

         test      byte ptr ds:[MouseK],bit4+bit5 ; je konec ?
         jnz       Edi4Edi8                 ; je uvolnØn¡ tlaŸ¡tka myçi

         test      byte ptr ds:[MouseK],bit7
         jnz       Edi4Edi2                 ; obsluha myçi
         jmp       short Edi4Edi4

Edi4Edi8:ret

Edi4Edit ENDP

; -----------------------------------------------------------------------------
;        naplnØn¡ plochy
; -----------------------------------------------------------------------------

Edi5Edit PROC      NEAR

         cmp       byte ptr ds:[FunkceEd],4 ; je plocha ?
         je        Edi5Edi1                 ; je plocha
         jmp       Edi6Edit                 ; nen¡ plocha

; ------ naŸten¡ pozice kurzoru myçi -> DX

Edi5Edi1:call      EdiGetM                  ; adresa pozice kurzoru myçi -> DX

; ------ pý¡prava pln¡c¡ barvy -> BL=aktu ln¡ (sud ), BH=doplåkov  (lich )

         mov       bl,ds:[ColLeft]          ; barva pro lev‚ tlaŸ¡tko
         mov       bh,ds:[ColRight]         ; barva pro prav‚ tlaŸ¡tko
         test      byte ptr ds:[MouseK],bit1 ; je prav‚ tlaŸ¡tko ?
         jz        Edi5Edi4                 ; nen¡ prav‚ tlaŸ¡tko, je jen lev‚
         test      byte ptr ds:[MouseK],bit0 ; je lev‚ tlaŸ¡tko ?
         jz        Edi5Edi3                 ; nen¡ lev‚ tlaŸ¡tko, je jen prav‚
         mov       al,dl                    ; pozice bodu
         xor       al,dh                    ; test lichosti bodu
         test      al,bit0                  ; je lichì bod ?
         jz        Edi5Edi4                 ; je sudì bod
Edi5Edi3:xchg      bl,bh                    ; aktivn¡ je lichì bod = prav‚ tlaŸ.

; ------ test, zda jsou obØ tlaŸ¡tka myçi

Edi5Edi4:mov       al,ds:[MouseK]           ; stav myçi
         and       al,bit0+bit1             ; stisknut  tlaŸ¡tka myçi
         cmp       al,bit0+bit1             ; jsou obØ tlaŸ¡tka myçi ?
         jne       Edi5Edi5                 ; nejsou obØ tlaŸ¡tka myçi

; ------ £schova doplåkov‚ barvy, jsou-li obØ tlaŸ¡tka myçi
; Neuchov v  se barva pod kurzorem, proto§e ta je zýejmØ ji§ zmØnØna
; pýedeçlìm stiskem pouze jednoho z obou tlaŸ¡tek

         dec       dl                       ; bod vlevo
         call      EdiGetB                  ; naŸten¡ bodu vlevo
         jc        Edi5Edi5                 ; chyba
         mov       ch,al                    ; CH <- doplåkov  barva (lich )

         dec       dh                       ; bod vlevo nahoýe
         call      EdiGetB                  ; naŸten¡ bodu vlevo nahoýe
         jc        Edi5Edi5                 ; chyba
         mov       cl,al                    ; CL <- barva pod kurzorem (sud )

; ------ kontrola okol¡ bodu, zda m…§e bìt doplåkov  barva

         inc       dl                       ; bod nahoýe
         call      Edi5Lich                 ; kontrola lich‚ barvy
         jc        Edi5Edi5                 ; nesouhlas¡

         inc       dl                       ; bod vpravo nahoýe
         call      Edi5Suda                 ; kontrola sud‚ barvy
         jc        Edi5Edi5                 ; nesouhlas¡

         inc       dh                       ; bod vpravo
         call      Edi5Lich                 ; kontrola lich‚ barvy
         jc        Edi5Edi5                 ; nesouhlas¡

         inc       dh                       ; bod vpravo dole
         call      Edi5Suda                 ; kontrola sud‚ barvy
         jc        Edi5Edi5                 ; nesouhlas¡

         dec       dl                       ; bod dole
         call      Edi5Lich                 ; kontrola lich‚ barvy
         jc        Edi5Edi5                 ; nesouhlas¡

         dec       dl                       ; bod vlevo dole
         call      Edi5Suda                 ; kontrola sud‚ barvy
         jnc       Edi5Edi6                 ; vçe souhlas¡ OK

; ------ nebude doplåkov  barva

Edi5Edi5:call      EdiGetM                  ; adresa pozice kurzoru myçi -> DX
         call      EdiGetB                  ; naŸten¡ barvy bodu pod kurzorem
         mov       cl,al                    ; CL <- £schova barvy
         mov       ch,al                    ; barva pod kurzorem nen¡ doplåkov 
         mov       bh,bl                    ; pln¡c¡ barva nen¡ doplåkov 

; ------ test, zda je pln¡c¡ barva shodn  s barvou pod kurzorem

Edi5Edi6:cmp       cx,bx                    ; je to barva kurzoru ?
         je        Edi5Edi9                 ; je to barva kurzoru

; ------ vyplnØn¡ plochy

         call      EdiGetM                  ; adresa pozice kurzoru myçi -> DX
         call      EditFill                 ; vyplnØn¡ plochy

; ------ zobrazen¡ ikony

         call      EdiEdDis                 ; zobrazen¡ ikony pýi editaci

Edi5Edi9:ret

Edi5Edit ENDP

; ------ kontrola sud‚ barvy (CL)

Edi5Suda:call      EdiGetB                  ; naŸten¡ bodu vlevo nahoýe
         jc        Edi5Sud2                 ; chyba
         cmp       al,cl                    ; sud  barva
         je        Edi5Sud4                 ; souhlas¡ OK
Edi5Sud2:stc                                ; pý¡znak nesouhlasn‚ barvy
Edi5Sud4:ret

; ------ kontrola lich‚ barvy (CH)

Edi5Lich:call      EdiGetB                  ; naŸten¡ bodu vlevo nahoýe
         jc        Edi5Lch2                 ; chyba
         cmp       al,ch                    ; sud  barva
         je        Edi5Lch4                 ; souhlas¡ OK
Edi5Lch2:stc                                ; pý¡znak nesouhlasn‚ barvy
Edi5Lch4:ret

; -----------------------------------------------------------------------------
;        oznaŸen¡ bloku
; -----------------------------------------------------------------------------

Edi6Edit PROC      NEAR

         cmp       byte ptr ds:[FunkceEd],5 ; je blok ?
         je        Edi6Edi1
         jmp       Edi7Edit                 ; nen¡ blok

Edi6Edi1:call      EdiGetM                  ; adresa pozice kurzoru myçi -> DX
         mov       ds:[EdiBegPz],dx         ; £schova pozice poŸ tku operace
         jmp       short Edi6Edi3

Edi6Edi2:call      EdiGetM                  ; adresa pozice kurzoru myçi -> DX
         cmp       dx,ds:[EdiOldPz]         ; byla pozice zmØnØna ?
         je        Edi6Edi4                 ; pozice nebyla zmØnØna
Edi6Edi3:mov       ds:[EdiOldPz],dx         ; £schova nov‚ pozice
         mov       bx,ds:[EdiBegPz]         ; BX <- poŸ teŸn¡ bod

         call      PetVSyn                  ; synchronizace kv…li blik n¡
         call      BlokKMaz                 ; vypnut¡ kurzoru

; ------ £schova souýadnic bloku

         cmp       dl,bl                    ; DL mus¡ bìt poŸ tek vlevo
         jbe       Edi6Ed32
         xchg      bl,dl                    ; oprava poýad¡
Edi6Ed32:cmp       dh,bh                    ; DH mus¡ bìt poŸ tek nahoýe
         jbe       Edi6Ed33
         xchg      bh,dh
Edi6Ed33:mov       ds:[BLokPoz],dx          ; souýadnice poŸ tku bloku
         sub       bl,dl                    ; ç¡ýka bloku
         inc       bl                       ; korekce
         sub       bh,dh                    ; vìçka bloku
         inc       bh                       ; korekce
         mov       ds:[BlokSize],bx         ; velikost oznaŸen‚ho bloku
         mov       ds:[BlokSiz2],bx         ; uschovan  velikost bloku

; ------ zobrazen¡ kurzoru

         call      BlokKDis                 ; zobrazen¡ kurzoru

; ------ £schova bloku do bufferu

         mov       di,offset BlokBuff       ; buffer k ulo§en¡ bloku
         push      ds
         pop       es
Edi6Ed34:push      bx
         push      dx

Edi6Ed35:call      EdiGetB                  ; naŸten¡ bodu
         cld
         stosb                              ; ulo§en¡ bodu do bufferu

Edi6Ed38:inc       dx                       ; zvìçen¡ ukazatele pozice na ý dku
         dec       bl
         jnz       Edi6Ed35                 ; dalç¡ pozice na ý dku

         pop       dx
         pop       bx
         inc       dh                       ; zvìçen¡ ukazatele ý dku
         dec       bh
         jnz       Edi6Ed34                 ; dalç¡ ý dek

; ------ Ÿek n¡ na zmØnu myçi

Edi6Edi4:
;         call      MouseOn                  ; zapnut¡ kurzoru myçi
         call      MousDPoz                 ; zobrazen¡ pozice kurzoru myçi
         call      InpChar                  ; vstup znaku z kl vesnice
         jnc       Edi6Edi8                 ; je znak z kl vesnice
         mov       cl,ds:[MouseK]           ; £schova stavu myçi
         call      IntMouse                 ; obsluha myçi
         jc        Edi6Edi4                 ; nen¡ zmØna

         test      byte ptr ds:[MouseK],bit2+bit3 ; je stisk dalç¡ho tlaŸ¡tka ?
         jnz       Edi6Edi5                 ; je stisk dalç¡ho tlaŸ¡tka

         test      byte ptr ds:[MouseK],bit4+bit5 ; je konec ?
         jnz       Edi6Edi8                 ; je uvolnØn¡ tlaŸ¡tka myçi

         test      byte ptr ds:[MouseK],bit7
         jz        Edi6Edi4
Edi6Edi5:jmp       Edi6Edi2                 ; obsluha myçi

; ------ vymaz n¡ plochy pod blokem

Edi6Edi8:cmp       word ptr ds:[BlokSize],101h ; je jen malì blok ?
         jne       Edi6Edi9                 ; nen¡ malì blok
         mov       word ptr ds:[BlokSize],0 ; takovì blok se zruç¡
         ret

Edi6Edi9:mov       byte ptr ds:[FunkceEd],6 ; pý¡znak oznaŸen¡ bloku

         mov       ch,ds:[MouseK]           ; novì stav myçi
         mov       ds:[MouseK],cl           ; starì stav (kv…li barvØ podkladu)

         mov       dx,ds:[EdiOldPz]
         mov       bx,ds:[EdiBegPz]         ; BX <- poŸ teŸn¡ bod
         call      EditCtve                 ; nakreslen¡ Ÿtverce

         mov       ds:[MouseK],ch           ; navr cen¡ stavu myçi
         ret

Edi6Edit ENDP

; -----------------------------------------------------------------------------
;        ukonŸen¡ editace bloku, blok se ulo§¡
; -----------------------------------------------------------------------------

Edi7EEnd PROC      NEAR

; ------ £schova registr…

         push      ax
         push      bx
         push      dx
         push      si

         call      BlokKMaz                 ; vymaz n¡ kurzoru bloku

         cmp       word ptr ds:[BlokSize],0
         je        Edi7EEn9

; ------ zruçen¡ ikony s vymazanìm blokem

         mov       ax,ds:[AktHICO]          ; aktu ln¡ ikona v historii
         add       ax,ICOSize/16            ; adresa dalç¡ ikony
         cmp       ax,ds:[DataICO]          ; je dalç¡ ikona ?
         jae       Edi7EEn2                 ; nen¡ dalç¡ ikona
         mov       ds:[AktHICO],ax          ; nov  aktivn¡ ikona
         mov       ds:[BegHICO],ax

; ------ pýenesen¡ bloku do obr zku

Edi7EEn2:mov       dh,byte ptr ds:[BlokPoz+1] ; poŸ teŸn¡ pozice bloku
         mov       bh,byte ptr ds:[BlokSize+1] ; velikost bloku
         or        bh,bh
         jz        Edi7EEn9                 ; nen¡ blok
         mov       si,offset BlokBuff       ; buffer s blokem
Edi7EEn3:mov       dl,byte ptr ds:[BlokPoz] ; poŸ teŸn¡ pozice bloku
         mov       bl,byte ptr ds:[BlokSize] ; ç¡ýka bloku
         or        bl,bl
         jz        Edi7EEn9
Edi7EEn4:cld
         lodsb                              ; naŸten¡ jednoho bodu
         call      EdiSetB                  ; nastaven¡ bodu do obr zku
         inc       dl                       ; zvìçen¡ ukazatele pozice
         dec       bl                       ; Ÿ¡taŸ ç¡ýky bloku
         jnz       Edi7EEn4                 ; dalç¡ bod na ý dku
         inc       dh                       ; zvìçen¡ ukazatele ý dku
         dec       bh                       ; Ÿ¡taŸ vìçky bloku
         jnz       Edi7EEn3                 ; dalç¡ ý dek

; ------ ulo§en¡ obr zku do historie

         mov       word ptr ds:[BlokSize],0 ; zruçen¡ bloku
         call      EdiIPush                 ; ulo§en¡ zmØn

; ------ n vrat registr…

Edi7EEn9:pop       si
         pop       dx
         pop       bx
         pop       ax
         ret

Edi7EEnd ENDP

; -----------------------------------------------------------------------------
;        obsluha oznaŸen‚ho bloku
; -----------------------------------------------------------------------------

Edi7Edit:call      EdiGetM                  ; adresa pozice kurzoru myçi -> DX
         mov       ds:[EdiBegPz],dx         ; £schova pozice poŸ tku operace

         mov       ax,ds:[BlokPoz]
         cmp       dl,al
         jl        Edi7Edi1
         add       al,byte ptr ds:[BlokSize]
         cmp       dl,al
         jge       Edi7Edi1

         cmp       dh,ah
         jl        Edi7Edi1
         add       ah,byte ptr ds:[BlokSize+1]
         cmp       dh,ah
         jl        Edi7Edi2

Edi7Edi1:mov       byte ptr ds:[FunkceEd],5 ; n vrat z kladn¡ho re§imu bloku

         call      Edi7EEnd                 ; ukonŸen¡ editace bloku

         jmp       Edi6Edit                 ; obsluha oznaŸov n¡ bloku

; ------ posunut¡ bloku

Edi7Edi2:call      EdiGetM                  ; adresa pozice kurzoru myçi -> DX
         cmp       dx,ds:[EdiBegPz]         ; je zmØna pozice ?
         je        Edi7Edi4                 ; nen¡ zmØna pozice

;         call      BlokKMaz                 ; vymaz n¡ kurzoru bloku
;
         push      dx
         sub       dl,byte ptr ds:[EdiBegPz] ; zmØna pozice
         add       byte ptr ds:[BlokPoz],dl  ; posun pozice bloku
         sub       dh,byte ptr ds:[EdiBegPz+1]
         add       byte ptr ds:[BlokPoz+1],dh ; posun ý dku bloku
         pop       dx
         mov       ds:[EdiBegPz],dx         ; £schova pozice poŸ tku operace

;         call      BlokKDis                 ; zobrazen¡ kurzoru
         call      EdiEdDis                 ; zobrazen¡ ikony pýi editaci

; ------ Ÿek n¡ na zmØnu myçi

Edi7Edi4:
;         call      MouseOn                  ; zapnut¡ kurzoru myçi
         call      MousDPoz                 ; zobrazen¡ pozice kurzoru myçi
         call      InpChar                  ; vstup znaku z kl vesnice
         jnc       Edi7Edi8                 ; je znak z kl vesnice
         mov       cl,ds:[MouseK]           ; £schova stavu myçi
         call      IntMouse                 ; obsluha myçi
         jc        Edi7Edi4                 ; nen¡ zmØna

         test      byte ptr ds:[MouseK],bit4+bit5 ; je konec ?
         jnz       Edi7Edi8                 ; je uvolnØn¡ tlaŸ¡tka myçi

         test      byte ptr ds:[MouseK],bit7
         jz        Edi7Edi4
         jmp       Edi7Edi2                 ; obsluha myçi


Edi7Edi8:ret

; -----------------------------------------------------------------------------
;        obsluha zobrazov n¡ kurzoru bloku
; -----------------------------------------------------------------------------

BlokKDis PROC      NEAR

         push      ax
         cmp       word ptr ds:[BlokSize],0
         je        BlokKDs8
         test      byte ptr ds:[Param],bit5 ; je kurzor zobrazen ?
         jnz       BlokKDs8                 ; je zobrazen
         cmp       byte ptr ds:[FunkceEd],5
         jb        BlokKDs8
         call      EdiBKDis                 ; nov‚ zobrazen¡ kurzoru
BlokKDs8:pop       ax
         ret

BlokKDis ENDP

; -----------------------------------------------------------------------------
;        vymaz n¡ zobrazen¡ kurzoru bloku
; -----------------------------------------------------------------------------

BlokKMaz PROC      NEAR

         push      ax
         test      byte ptr ds:[Param],bit5 ; je kurzor vypnut ?
         jz        BlokKMz2                 ; kurzor je vypnut
         call      EdiBKDis                 ; zobrazen¡ kurzoru bloku
BlokKMz2:pop       ax
         ret

BlokKMaz ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ oznaŸen¡ bloku
; -----------------------------------------------------------------------------

EdiBKDis PROC      NEAR

; ------ £schova registr…

         xor       byte ptr ds:[Param],bit5 ; zmØna pý¡znaku kurzoru
         call      MouseOff                 ; vypnut¡ kurzoru myçi

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ vìpoŸet adresy ve videopamØti -> DI

         mov       al,14                    ; poŸet linek na ý dek
         imul      byte ptr ds:[BlokPoz+1]  ; poŸ teŸn¡ linka s blokem
         mov       si,ax                    ; SI <- poŸ teŸn¡ linka bloku
         add       ax,8                     ; pýiŸten¡ poŸ tku
         imul      word ptr ds:[DispSirB]   ; pýepoŸet na adresu ve videopamØti
         mov       bh,0
         mov       bl,byte ptr ds:[BlokPoz]
         or        bl,bl
         jns       EdiBKD02
         dec       bh
EdiBKD02:shl       bx,1                     ; pýepoŸet na bajtovou pozici
         inc       bx                       ; pýiŸten¡ poŸ tku
         add       ax,bx                    ; pýiŸten¡ pozice
         xchg      ax,di                    ; DI <- adresa ve videopamØti

; ------ pý¡prava k operaci

         cld
         cli                                ; z kaz pýeruçen¡ bØhem operace
         xor       cx,cx                    ; CX <- 0
         mov       es,ds:[AdrVRAM]          ; adresa videopamØti

; ------ nastaven¡ z pisov‚ roviny

         mov       dx,3c4h
         mov       al,2
         out       dx,al                    ; volba registru 2
         inc       dx                       ; datovì registr
         mov       al,0fh                   ; z pisov  rovina - vçechno
         out       dx,al                    ; volba z pisov‚ roviny

; ------ nastaven¡ z pisov‚ho m¢du XOR

         mov       dx,3ceh
         mov       al,3
         out       dx,al
         inc       dx
         mov       al,18h
         out       dx,al                    ; z pisovì m¢d XOR

; ------ z pis horn¡ linky

         cld
         call      EdiBKDsV
         call      EdiBKDsV
         call      EdiBKDsV
         call      EdiBKDsV

; ------ z pis okraj…

         mov       dl,byte ptr ds:[BlokPoz]
         mov       dh,0
         shl       dx,1
         mov       al,byte ptr ds:[BLokSize] ; ç¡ýka bloku
         mov       ah,0
         shl       ax,1                     ; ç¡ýka bloku v bajtech
         dec       ax
         xchg      ax,bp

         mov       al,14                    ; poŸet linek na ý dek
         mul       byte ptr ds:[BlokSize+1]
         xchg      ax,cx
         sub       cx,9
         jbe       EdiBKDs4

EdiBKDs1:cmp       si,14*32                 ; je platn  linka bloku ?
         jae       EdiBKD14                 ; nen¡ platn  linka bloku

         mov       al,0f8h
         cmp       dl,64
         jae       EdiBKD12
         xchg      al,es:[di]
EdiBKD12:mov       al,3eh
         add       dx,bp
         cmp       dl,64
         jae       EdiBKD13
         xchg      al,es:[di+bp]
EdiBKD13:sub       dx,bp
EdiBKD14:add       di,80
         inc       si
         loop      EdiBKDs1

; ------ z pis spodn¡ linky

EdiBKDs4:call      EdiBKDsV
         call      EdiBKDsV
         call      EdiBKDsV
         call      EdiBKDsV

; ------ n vrat bØ§n‚ho z pisov‚ho m¢du

EdiBKDs5:mov       dx,3cfh
         mov       al,0
         out       dx,al                    ; nastaven¡ bØ§n‚ho m¢du

; ------ n vrat registr…

         sti                                ; pýeruçen¡ opØt povoleno
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

EdiBKDis ENDP

; ------ z pis linky EGA a VGA

EdiBKDsV PROC      NEAR

         mov       dl,byte ptr ds:[BlokPoz] ; poŸ teŸn¡ pozice bloku
         shl       dl,1
         mov       cl,byte ptr ds:[BLokSize] ; ç¡ýka bloku
         mov       ch,0
         shl       cx,1                     ; ç¡ýka bloku v bajtech
         push      di
         dec       cx
         jcxz      EdiBKDV4

         cmp       si,14*32                 ; je platn  linka bloku ?
         jae       EdiBKDV6                 ; nen¡ platn  linka bloku

EdiBKDV2:mov       al,-1
         cmp       dl,64
         jae       EdiBKDV3
         xchg      al,es:[di]
EdiBKDV3:inc       di
         inc       dl
         loop      EdiBKDV2

EdiBKDV4:cmp       dl,64
         jae       EdiBKDV6
         mov       al,0feh
         xchg      al,es:[di]

EdiBKDV6:pop       di
         add       di,80
         inc       si                       ; zvìçen¡ ukazatele linky bloku
         ret

EdiBKDsV ENDP

; -----------------------------------------------------------------------------
;     vyplnØn¡ plochy od souýadnice DX (vol  se rekurzivnØ !)
; -----------------------------------------------------------------------------
; VSTUP: DX=aktu ln¡ souýadnice
;        BL=aktu ln¡ pln¡c¡ barva (sud )
;        BH=doplåkov  pln¡c¡ barva (lich )
;        CL=aktu ln¡ plnØn  barva (sud )
;        CH=doplåkov  plnØn  barva (lich )
; -----------------------------------------------------------------------------

EditFill PROC      NEAR

; ------ £schova registr… (zachovat poýad¡ - navrac¡ se v proceduýe !)

         push      bx                       ; pln¡c¡ barva
         push      cx                       ; barva pod kurzorem
         push      dx                       ; souýadnice

; ------ test pýeteŸen¡ z sobn¡ku

         cmp       sp,offset Zasob0+2*50    ; je z sobn¡k bezpeŸnì ?
         jbe       EditFil9                 ; pýeteŸen¡ z sobn¡ku

; ------ nastaven¡ barvy bodu pod kurzorem

EditFil2:mov       al,bl                    ; AL <- aktu ln¡ pln¡c¡ barva
         call      EdiSetB                  ; nastaven¡ bodu pod kurzorem

; ------ test bodu smØrem dol…

         inc       dh                       ; bod smØrem dol…
         xchg      bl,bh                    ; zmØna pln¡c¡ barvy
         xchg      cl,ch                    ; zmØna plnØn‚ barvy
         call      EdiGetB                  ; naŸten¡ bodu smØrem dol…
         cmp       al,cl                    ; je to plnØn  barva ?
         jne       EditFil3                 ; nen¡ to plnØn  barva
         call      EditFill                 ; vyplnØn¡ dalç¡ linky
EditFil3:dec       dh                       ; n vrat ý dku

; ------ test bodu smØrem nahoru (CL/CH a BL/BH nejsou nyn¡ zamØnØny !)

         dec       dh                       ; bod smØrem nahoru
         call      EdiGetB                  ; naŸten¡ bodu smØrem dol…
         cmp       al,cl                    ; je to plnØn  barva ?
         jne       EditFil4                 ; nen¡ to plnØn  barva
         call      EditFill                 ; vyplnØn¡ dalç¡ linky
EditFil4:inc       dh                       ; n vrat ý dku

; ------ test dalç¡ho bodu (CL/CH a BL/BH nejsou nyn¡ zamØnØny !)

         inc       dl                       ; zvìçen¡ pozice
         call      EdiGetB                  ; naŸten¡ dalç¡ho bodu
         cmp       al,cl                    ; je to plnØn  barva ?
         je        EditFil2                 ; naplnØn¡ dalç¡ho bodu

; ------ n vrat ukazatel…

         pop       dx                       ; n vrat ukazatele linky
         pop       cx                       ; n vrat plnØn‚ barvy
         pop       bx                       ; n vrat pln¡c¡ barvy

         push      bx
         push      cx
         push      dx

; ------ test pýedeçl‚ho bodu

         xchg      bl,bh                    ; zmØna pln¡c¡ barvy
         xchg      cl,ch                    ; zmØna plnØn‚ barvy
EditFil6:dec       dl                       ; sn¡§en¡ pozice
         call      EdiGetB                  ; naŸten¡ dalç¡ho bodu
         cmp       al,cl                    ; je to plnØn  barva ?
         jne       EditFil9                 ; nen¡ to plnØn  barva

; ------ nastaven¡ barvy bodu pod kurzorem

         mov       al,bl                    ; AL <- aktu ln¡ pln¡c¡ barva
         call      EdiSetB                  ; nastaven¡ bodu pod kurzorem

; ------ test bodu smØrem dol…

         inc       dh                       ; bod smØrem dol…
         xchg      bl,bh                    ; zmØna pln¡c¡ barvy
         xchg      cl,ch                    ; zmØna plnØn‚ barvy
         call      EdiGetB                  ; naŸten¡ bodu smØrem dol…
         cmp       al,cl                    ; je to plnØn  barva ?
         jne       EditFil7                 ; nen¡ to plnØn  barva
         call      EditFill                 ; vyplnØn¡ dalç¡ linky
EditFil7:dec       dh                       ; n vrat ý dku

; ------ test bodu smØrem nahoru (CL/CH a BL/BH nejsou nyn¡ zamØnØny !)

         dec       dh                       ; bod smØrem nahoru
         call      EdiGetB                  ; naŸten¡ bodu smØrem dol…
         cmp       al,cl                    ; je to plnØn  barva ?
         jne       EditFil8                 ; nen¡ to plnØn  barva
         call      EditFill                 ; vyplnØn¡ dalç¡ linky
EditFil8:inc       dh                       ; n vrat ý dku
         jmp       short EditFil6           ; dalç¡ bod (BX,CX nejsou zamØnØny!)

; ------ n vrat registr…

EditFil9:pop       dx
         pop       cx
         pop       bx
         ret

EditFill ENDP

;; -----------------------------------------------------------------------------
;;        naŸten¡ aktu ln¡ barvy myçi -> AL
;; -----------------------------------------------------------------------------
;
;GetACol  PROC      NEAR
;
;         mov       al,ds:[ColLeft]          ; barva pro lev‚ tlaŸ¡tko
;         test      byte ptr ds:[MouseK],bit0 ; je lev‚ tlaŸ¡tko ?
;         jnz       GetACol2                 ; je lev‚ tlaŸ¡tko
;         mov       al,ds:[ColRight]         ; barva pro prav‚ tlaŸ¡tko
;GetACol2:ret
;
;GetACol  ENDP

; -----------------------------------------------------------------------------
;        pole volby barvy a ikony
; -----------------------------------------------------------------------------

EdiVCol  PROC      NEAR

; ------ volba ikony

         cmp       dx,HistEdiM*32           ; je ikona z historie ?
         jae       EdiVCol2                 ; nen¡ historie
         sub       dx,8
         jb        EdiVCol1                 ; nen¡ platn  ikona
         mov       cl,5
         shr       dx,cl                    ; DL = Ÿ¡slo ikony
         mov       bx,dx                    ; BX <- Ÿ¡slo ikony
         cmp       bx,ds:[EdiIHAkt]         ; je ji§ aktivn¡ ?
         je        EdiVCol1                 ; je ji§ aktivn¡

         call      Edi7EEnd                 ; ukonŸen¡ editace bloku

         mov       ds:[EdiIHAkt],bx         ; aktivn¡ ikona
         shl       bx,1
         mov       ax,ds:[bx+EdiIHist]      ; Ÿ¡slo ikony
         mov       ds:[EditIcoC],ax         ; Ÿ¡slo editovan‚ ikony

         mov       ax,ds:[DataICO]          ; zaŸ tek ikon
         mov       ds:[BegHICO],ax          ; adresa prvn¡ ikony v historii
         mov       ds:[AktHICO],ax          ; aktu ln¡ ikona v historii

         call      EdiIPush                 ; ulo§en¡ ikony do historie

         call      EdiIDNam                 ; zobrazen¡ jm‚na ikony

EdiVCol1:ret

; ------ volba barvy

EdiVCol2:
         cmp       dx,PVYSKA*32-5*32
         jb        EdiIco45

         mov       al,-1
         sub       dx,PVYSKA*32-4*32-8
         jc        EdiIc446
         shr       dx,1
         shr       dx,1
         shr       dx,1
         shr       dx,1
         and       dl,7
         cmp       cx,32*2+4
         jb        EdiIc444
         add       dl,8
EdiIc444:mov       al,dl
EdiIc446:test      byte ptr ds:[MouseK],bit2
         jz        EdiIc447
         mov       ds:[ColLeft],al
EdiIc447:test      byte ptr ds:[MouseK],bit3
         jz        EdiIc448
         mov       ds:[ColRight],al
EdiIc448:ret




EdiIco45:
         ret


EdiVCol  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ editovan‚ ikony
; -----------------------------------------------------------------------------

EdiIDisp PROC      NEAR

; ------ £schova registr…

         push      ax
         push      bx
         push      dx

         and       byte ptr ds:[Param],not bit5 ; kurzor bloku nen¡ zobrazen

; ------ zobrazen¡ plochy

         mov       bx,ds:[BlokPoz]           ; pozice bloku
         add       bl,byte ptr ds:[BlokSize] ; pozice konce bloku
         add       bh,byte ptr ds:[BlokSize+1]

         mov       dh,0                     ; ukazatel ý dku
EdiIDis2:mov       dl,0
EdiIDis4:call      EdiGetB                  ; naŸten¡ barvy bodu

         cmp       byte ptr ds:[FunkceEd],5
         jb        EdiIDis8                 ; nen¡ obsluha bloku
         cmp       dl,bl
         jge       EdiIDis8
         cmp       dh,bh
         jge       EdiIDis8
         cmp       dl,byte ptr ds:[BlokPoz]
         jl        EdiIDis8                 ; nen¡ blok
         cmp       dh,byte ptr ds:[BlokPoz+1]
         jl        EdiIDis8

         push      bx
         mov       al,dh                    ; aktu ln¡ ý dek
         sub       al,byte ptr ds:[BlokPoz+1] ; ý dek relativnØ v bloku
         mul       byte ptr ds:[BlokSize] ; pýepoŸet na offset v bloku
         xchg      ax,bx                    ; BX <- offset ý dku v bloku
         mov       al,dl                    ; aktu ln¡ pozice
         sub       al,byte ptr ds:[BlokPoz] ; pozice relativnØ v bloku
         mov       ah,0
         add       bx,ax                    ; BX <- offset bodu v bloku
         mov       al,ds:[bx+BlokBuff]      ; bod z bufferu
         pop       bx

EdiIDis8:call      EdiDispB                 ; zobrazen¡ bodu
         inc       dx
         cmp       dl,32
         jb        EdiIDis4
         inc       dh
         cmp       dh,32
         jb        EdiIDis2

; ------ n vrat registr…

         pop       dx
         pop       bx
         pop       ax

         call      BlokKDis                 ; obsluha zobrazov n¡ kurzoru bloku

         ret

EdiIDisp ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ Ÿtverce mezi souýadnicemi BX/DX na aktu ln¡ barvu
; -----------------------------------------------------------------------------

EditCtve PROC      NEAR

; ------ £schova registr…

         push      dx

; ------ oprava souýadnic, aby byl v§dy zleva doprava -> DX=poŸ tek, BX=konec

         cmp       dl,bl                    ; je DX vpravo od BX ?
         jbe       EditCtv1                 ; DX je OK
         xchg      bx,dx                    ; DX bude jako poŸ tek vlevo

; ------ nakreslen¡ Ÿtverce

EditCtv1:push      bx
         mov       bl,dl                    ; pozice konce = pozice zaŸ tku
         call      EditLine                 ; nakreslen¡ jedn‚ Ÿ ry
         pop       bx
         inc       dx                       ; zvìçen¡ ukazatele pozice
         cmp       dl,bl                    ; je ji§ koncov  pozice ?
         jbe       EditCtv1                 ; nen¡ jeçtØ pýekroŸen¡ pozice

; ------ n vrat registr…

EditCtv9:pop       dx
         ret

EditCtve ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ kruhu mezi souýadnicemi BX/DX (max. 32 !) na aktu ln¡ barvu
; -----------------------------------------------------------------------------
;þ
EditKruh PROC      NEAR

; ------ £schova registr…

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp

; ------ kvadr t rozd¡lu vzd lenosti X -> CX (=max. 1024)

         cmp       dl,bl                    ; je DL pýed BL ?
         jbe       EditKrh1                 ; DL je pýed BL
         xchg      dl,bl                    ; oprava poýad¡
EditKrh1:inc       bl                       ; vŸetnØ koncov‚ho bodu
         mov       al,bl                    ; AL <- druhì bod X
         sub       al,dl                    ; rozd¡l vzd lenost¡ X (max. 32)
         mul       al                       ; rozd¡l vzd lenosti X^2
         xchg      ax,cx                    ; CX <- rozd¡l vzd lenosti X^2

; ------ kvadr t rozd¡lu vzd lenosti Y -> AX (=max. 1024)

         cmp       dh,bh                    ; je DH pýed BH ?
         jbe       EditKrh2                 ; DH je pýed BH
         xchg      dh,bh                    ; oprava poýad¡
EditKrh2:inc       bh                       ; vŸetnØ koncov‚ho bodu
         mov       al,bh                    ; AL <- druhì bod Y
         sub       al,dh                    ; rozd¡l vzd lenosti Y (max. 32)
         mul       al                       ; rozd¡l vzd lenosti Y^2

; ------ vìpoŸet pr…mØru kruhu -> SI (= ç¡ýka kruhu vŸetnØ koncovìch bod…)

         add       ax,cx                    ; AX <- souŸet X^2 + Y^2 (=max. 2048)
         mov       cl,4
         shl       ax,cl                    ; * 16 pro zvìçen¡ pýesnosti
         call      Odmocn                   ; vìpoŸet odmocniny z AX
         shr       ax,1
         shr       ax,1                     ; AX = pr…mØr kruhu
         mov       si,ax                    ; SI <- pr…mØr kruhu (max. 46)

; ------ vìpoŸet 4*polomØr^2 -> BP

         mul       al                       ; AX <- pr…mØr^2
         test      si,1
         jnz       EditKr22
         add       ax,si                    ; + mal  korekce pro zaokrouhlen¡
         add       ax,si
         add       ax,si
EditKr22:xchg      ax,bp                    ; BP <- 4*polomØr^2

; ------ vìpoŸet stýedu kru§nice -> DX

         add       dl,bl                    ; poŸ teŸn¡ + koncovì bod X
         sar       dl,1                     ; DL <- poŸ tek X
         add       dh,bh                    ; DH <- stýed Y * 2
         sar       dh,1                     ; DH <- stýed Y

; ------ vìpoŸet poŸtu bod… k malov n¡ -> CX (tj. pr…mØr/2 * 1/sqrt2)

         mov       ax,si                    ; AX <- pr…mØr
;         mov       ah,91                    ; 256*(1/2)*(1/sqrt(2)) (trochu v¡c)
         mov       ah,96
         mul       ah                       ; vìpoŸet poŸtu bod… * 256
         mov       ch,0
         mov       cl,ah                    ; CX <- poŸet bod… k malov n¡
         inc       cx

; ------ vìpoŸet stýedu pro sud‚ body -> BX

         mov       bx,dx                    ; BX <- stýed kruhu
         mov       ax,si                    ; AX <- pr…mØr
         not       ax
         and       al,bit0                  ; 1=sudì pr…mØr
         sub       bl,al                    ; posun X
         sub       bh,al                    ; posun Y

; ------ ukazatel vzd lenosti 2*X

         xor       si,si                    ; SI <- 0 Ÿ¡taŸ vzd lenosti X
EditKrh3:mov       ax,si                    ; AL <- 2*vzd lenost X
         mul       al                       ; 4*vzd lenost X^2
         sub       ax,bp                    ; - 4*polomØr^2 + 4*vzd lenost X^2
         jnc       EditKrh8                 ; je pýeteŸen¡
         neg       ax                       ; oprava znam‚nka
         call      Odmocn                   ; vìpoŸet odmocniny
         shr       ax,1                     ; vìçka Y
         xchg      ax,di                    ; DI <- vìçka Y

; ------ nakreslen¡ Ÿ ry vlevo od stýedu

         push      bx
         push      dx
         mov       ax,si                    ; AX <- vzd lenost * 2
         shr       ax,1                     ; polovina vzd lenosti
         sub       dl,al                    ; souýadnice X
         js        EditKrh4                 ; pozice X je z porn 
         mov       bl,dl                    ; BL <- souýadnice X
         mov       ax,di                    ; AX <- vìçka Y
         sub       dh,al                    ; poŸ teŸn¡ souýadnice Y
         add       bh,al                    ; koncov  souýadnice Y
         call      EditLine                 ; zobrazen¡ Ÿ ry
EditKrh4:pop       dx
         pop       bx

; ------ nakreslen¡ Ÿ ry vpravo od stýedu

         push      bx
         push      dx
         mov       ax,si                    ; AX <- vzd lenost * 2
         shr       ax,1                     ; polovina vzd lenosti
         add       bl,al                    ; souýadnice X
         js        EditKrh5                 ; pozice X je z porn 
         mov       dl,bl                    ; DL <- souýadnice X
         mov       ax,di                    ; AX <- vìçka Y
         sub       dh,al                    ; poŸ teŸn¡ souýadnice Y
         add       bh,al                    ; koncov  souýadnice Y
         call      EditLine                 ; zobrazen¡ Ÿ ry
EditKrh5:pop       dx
         pop       bx

; ------ nakreslen¡ Ÿ ry nahoru od stýedu

         push      bx
         push      dx
         mov       ax,si                    ; AX <- vzd lenost * 2
         shr       ax,1                     ; polovina vzd lenosti
         sub       dh,al                    ; souýadnice Y
         js        EditKrh6                 ; pozice Y je z porn 
         mov       bh,dh                    ; BH <- souýadnice Y
         mov       ax,di                    ; AX <- vìçka Y
         sub       dl,al                    ; poŸ teŸn¡ souýadnice X
         add       bl,al                    ; koncov  souýadnice X
         call      EditLine                 ; zobrazen¡ Ÿ ry
EditKrh6:pop       dx
         pop       bx

; ------ nakreslen¡ Ÿ ry dol… od stýedu

         push      bx
         push      dx
         mov       ax,si                    ; AX <- vzd lenost * 2
         shr       ax,1                     ; polovina vzd lenosti
         add       bh,al                    ; souýadnice Y
         js        EditKrh7                 ; pozice Y je z porn 
         mov       dh,bh                    ; DH <- souýadnice Y
         mov       ax,di                    ; AX <- vìçka Y
         sub       dl,al                    ; poŸ teŸn¡ souýadnice X
         add       bl,al                    ; koncov  souýadnice X
         call      EditLine                 ; zobrazen¡ Ÿ ry
EditKrh7:pop       dx
         pop       bx

EditKrh8:inc       si
         inc       si                       ; ukazatel vzd lenosti * 2
         loop      EditKrh3                 ; dalç¡ bod

; ------ n vrat registr…

EditKrh9:pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

EditKruh ENDP

;; -----------------------------------------------------------------------------
;;   nastaven¡ kruhu mezi souýadnicemi BX (=okraj)/DX (=stýed) na aktu ln¡ barvu
;; -----------------------------------------------------------------------------
;
;EditKruh PROC      NEAR
;
;         cmp       bx,dx
;         jne       EditKrh0
;         jmp       EditLine
;
;; ------ £schova registr…
;
;EditKrh0:push      ax
;         push      bx
;         push      cx
;         push      dx
;         push      bp
;
;; ------ vìpoŸet polomØru kruhu -> CX
;
;         mov       al,dl                    ; AL <- stýed X
;         sub       al,bl                    ; AL <- rozd¡l vzd lenosti X
;         imul      al                       ; rozd¡l X^2
;         xchg      ax,cx                    ; CX <- rozd¡l X^2
;
;         mov       al,dh                    ; AH <- stýed Y
;         sub       al,bh                    ; AL <- rozd¡l vzd lenosti Y
;         imul      al                       ; rozd¡l Y^2
;
;         add       ax,cx                    ; AX <- souŸet X^2 + Y^2
;         call      Odmocn                   ; vìpoŸet odmocniny z AX
;         mov       cx,ax                    ; CX <- polomØr kruhu
;         mul       al
;         add       ax,cx                    ; korekce
;         xchg      ax,bp                    ; BP <- polomØr kruhu^2
;
;; ------ vìpoŸet okraje X a Y
;
;         sub       dl,cl                    ; novì okraj X
;         inc       cx
;
;; ------ nakreslen¡ kruhu
;
;EditKrh3:push      bx
;         push      dx
;
;         mov       al,cl                    ; zbyl  vzd lenost
;         dec       ax
;         mul       al                       ; zbyl  vzd lenost X^2
;         sub       ax,bp                    ; polomØr^2 - rozd¡l X^2
;         neg       ax
;         or        ax,ax                    ; je platn‚ Ÿ¡slo ?
;         jns       EditKrh4
;         xor       ax,ax                    ; omezen¡
;EditKrh4:call      Odmocn                   ; vìpoŸet odmocniny
;         mov       bh,dh                    ; BH <- stýed Y
;         sub       dh,al                    ; poŸ tek Y
;         add       bh,al                    ; konec Y
;         mov       bl,dl                    ; pozice konce = pozice zaŸ tku
;         cmp       dl,32
;         jae       EditKrh5
;         call      EditLine                 ; nakreslen¡ jedn‚ Ÿ ry
;
;EditKrh5:mov       ax,cx                    ; AX <- zbyl‚ Ÿ ry
;         dec       ax                       ; zbyl‚ Ÿ ry - 1
;         jz        EditKrh6                 ; je posledn¡ Ÿ ra
;         shl       ax,1
;         add       dl,al
;         mov       bl,dl
;         cmp       dl,32
;         jae       EditKrh6
;         call      EditLine                 ; zrcadlov  Ÿ ra
;
;EditKrh6:pop       dx
;         pop       bx
;
;         inc       dl                       ; zvìçen¡ ukazatele pozice
;         loop      EditKrh3
;
;; ------ n vrat registr…
;
;EditKrh9:pop       bp
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;
;EditKruh ENDP

; -----------------------------------------------------------------------------
;        vìpoŸet odmocniny z AX -> AX
; -----------------------------------------------------------------------------

Odmocn   PROC      NEAR

; ------ £schova registr…

         push      bx
         push      cx
         push      dx
         push      bp

; ------ kontrola povolen‚ hodnoty

         cmp       ax,1                     ; minim ln¡ hodnota = 2
         jbe       Odmocn9                  ; pý¡liç mal  hodnota

; ------ inicializace registr…

         mov       bp,ax                    ; BP <- p…vodn¡ Ÿ¡slo
         shr       ax,1
         xchg      ax,bx                    ; BX <- vìsledek (zde jeçtØ nen¡ 0)

; ------ vìpoŸet jedn‚ hodnoty

         mov       cx,100                   ; asi tak maxim lnØ pokus…
Odmocn2: xor       dx,dx                    ; DX <- 0
         mov       ax,bp                    ; AX <- p…vodn¡ Ÿ¡slo
         div       bx                       ; vydØlen¡ mezivìsledkem
         cmp       ax,bx                    ; je ji§ Ÿ¡slo nemØnn‚ ?
         je        Odmocn8                  ; Ÿ¡slo je ji§ nemØnn‚
         add       ax,bx                    ; + mezivìsledek
         shr       ax,1                     ; stýedn¡ hodnota
         xchg      ax,bx                    ; BX <- novì mezivìsledek
         loopnz    Odmocn2                  ; vìsledek nen¡ = 0

; ------ n vrat registr…

Odmocn8: xchg      ax,bx                    ; AX <- vypoŸten‚ Ÿ¡slo
Odmocn9: pop       bp
         pop       dx
         pop       cx
         pop       bx
         ret

Odmocn   ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ linky mezi souýadnicemi BX/DX na aktu ln¡ barvu
; -----------------------------------------------------------------------------

EditLine PROC      NEAR

; ------ £schova registr…

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

; ------ omezen¡ souýadnic

         or        dl,dl
         jns       EditLn02
         mov       dl,0
EditLn02:cmp       dl,32
         jb        EditLn03
         mov       dl,31
EditLn03:or        dh,dh
         jns       EditLn04
         mov       dh,0
EditLn04:cmp       dh,32
         jb        EditLn05
         mov       dh,31

EditLn05:or        bl,bl
         jns       EditLn06
         mov       bl,0
EditLn06:cmp       bl,32
         jb        EditLn07
         mov       bl,31
EditLn07:or        bh,bh
         jns       EditLn08
         mov       bh,0
EditLn08:cmp       bh,32
         jb        EditLin0
         mov       bh,31

; ------ oprava souýadnic, aby byl v§dy zleva doprava -> DX=poŸ tek, BX=konec

EditLin0:cmp       dl,bl                    ; je DX vpravo od BX ?
         jbe       EditLin1                 ; DX je OK
         xchg      bx,dx                    ; DX bude jako poŸ tek vlevo

; ------ pý¡rustek souýadnice X -> BL (bude v§dy kladnì nebo minim lnØ 0)

EditLin1:sub       bl,dl                    ; BL <- pý¡rustek souýadnice X
         mov       ch,0
         mov       cl,bl                    ; CL <- poŸet bod… k zobrazen¡ - 1
         mov       si,-1                    ; SI <- Ÿ¡taŸ pý¡rustku pro 1/1
         inc       cx                       ; vŸetnØ koncov‚ho bodu
         mov       di,40                    ; DI <- Ÿ¡taŸ pý¡rustku
                                            ;  (mal  hodnota je pro pý¡pad 1/1)

; ------ test, zda je smØr Ÿ ry nahoru nebo dol…

         sub       bh,dh                    ; pý¡rustek souýadnice Y
         jb        EditLin5                 ; pý¡rustek je nahoru

; ====== pý¡rustek je rovnØ nebo dol… (tj. pý¡rustek DH je kladnì)

; ------ rozliçen¡, zda je vØtç¡ pý¡rustek ve smØru X nebo Y

         cmp       bl,bh                    ; je vØtç¡ pý¡rustek Y nebo X ?
         jb        EditLin3                 ; je vØtç¡ pý¡rustek Y
         je        EditLin2                 ; pý¡rustky jsou stejn‚

; ====== Ÿ ra jde m lo strmØ dol…

; ------ vìpoŸet zlomku pý¡rustku -> SI

         call      EditLiY                  ; vìpoŸet pý¡rustku pro Y

; ------ zobrazen¡ Ÿ ry

EditLin2:call      EdiSetA                  ; nastaven¡ bodu
         inc       dx                       ; zvìçen¡ souýadnice X
         add       di,si                    ; zvìçen¡ Ÿ¡taŸe pý¡rustku Y
         jnc       EditLn22                 ; nen¡ zvìçen¡ souýadnice Y
         inc       dh                       ; zvìçen¡ souýadnice Y
EditLn22:loop      EditLin2                 ; dalç¡ bod
         jmp       short EditLin9

; ====== Ÿ ra jde hodnØ strmØ dol…

EditLin3:mov       cl,bh                    ; CX <- poŸet bod… k zobrazen¡
         inc       cx                       ; vŸetnØ koncov‚ho bodu

; ------ vìpoŸet zlomku pý¡rustku -> SI

         call      EditLiX                  ; vìpoŸet pý¡rustku pro X

; ------ zobrazen¡ Ÿ ry

EditLin4:call      EdiSetA                  ; nastaven¡ bodu
         inc       dh                       ; zvìçen¡ souýadnice Y
         add       di,si                    ; zvìçen¡ Ÿ¡taŸe pý¡rustku X
         jnc       EditLn42                 ; nen¡ zvìçen¡ souýadnice X
         inc       dx                       ; zvìçen¡ souýadnice X
EditLn42:loop      EditLin4                 ; dalç¡ bod
         jmp       short EditLin9

; ====== pý¡rustek je nahoru (tj. pý¡rustek DH je z pornì)

EditLin5:neg       bh                       ; oprava pý¡rustku BH

; ------ rozliçen¡, zda je vØtç¡ pý¡rustek ve smØry X nebo Y

         cmp       bl,bh                    ; je vØtç¡ pý¡rustek Y nebo X ?
         jb        EditLin7                 ; je vØtç¡ pý¡rustek Y
         je        EditLin6                 ; pý¡rustky jsou stejn‚

; ====== Ÿ ra jde m lo strmØ nahoru

; ------ vìpoŸet zlomku pý¡rustku -> SI

         call      EditLiY                  ; vìpoŸet pý¡rustku pro Y

; ------ zobrazen¡ Ÿ ry

EditLin6:call      EdiSetA                  ; nastaven¡ bodu
         inc       dx                       ; zvìçen¡ souýadnice X
         add       di,si                    ; zvìçen¡ Ÿ¡taŸe pý¡rustku Y
         jnc       EditLn62                 ; nen¡ zvìçen¡ souýadnice Y
         dec       dh                       ; sn¡§en¡ souýadnice Y
EditLn62:loop      EditLin6                 ; dalç¡ bod
         jmp       short EditLin9

; ====== Ÿ ra jde hodnØ strmØ nahoru

EditLin7:mov       cl,bh                    ; CL <- poŸet bod… k zobrazen¡
         inc       cx                       ; vŸetnØ koncov‚ho bodu

; ------ vìpoŸet zlomku pý¡rustku -> SI

         call      EditLiX                  ; vìpoŸet pý¡rustku pro X

; ------ zobrazen¡ Ÿ ry

EditLin8:call      EdiSetA                  ; nastaven¡ bodu
         dec       dh                       ; sn¡§en¡ souýadnice Y
         add       di,si                    ; zvìçen¡ Ÿ¡taŸe pý¡rustku X
         jnc       EditLn82                 ; nen¡ zvìçen¡ souýadnice X
         inc       dx                       ; zvìçen¡ souýadnice X
EditLn82:loop      EditLin8                 ; dalç¡ bod

; ------ n vrat registr…

EditLin9:pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

EditLine ENDP

; ------ vìpoŸet pý¡rustku -> SI

EditLiY: push      dx
         mov       dl,bh                    ; AX <- rozd¡l souýadnic Y * HI
         jmp       short EditLiX2

EditLiX: push      dx
         mov       dl,bl                    ; AX <- rozd¡l souýadnic X * HI

EditLiX2:push      ax

         mov       ax,-1
         mov       dh,0
         div       cx                       ; / (poŸet pý¡rustk…)
         mov       si,ax                    ; SI <- pý¡rustek * HI
         shr       ax,1
         add       di,ax

         pop       ax

         pop       dx
         ret

;; -----------------------------------------------------------------------------
;;  nastaven¡ bodu na souýadnic¡ch DX na aktu ln¡ hodnotu -> CY=chyba souýadnic
;; -----------------------------------------------------------------------------
;
;EditBod  PROC      NEAR
;
;; ------ £schova registr…
;
;         push      ax
;
;; ------ pý¡prava po§adovan‚ barvy -> AH
;
;         mov       ah,ds:[ColLeft]          ; barva pro lev‚ tlaŸ¡tko
;         test      byte ptr ds:[MouseK],bit0 ; je lev‚ tlaŸ¡tko ?
;         jnz       EditBod2                 ; je lev‚ tlaŸ¡tko
;         mov       ah,ds:[ColRight]         ; barva pro prav‚ tlaŸ¡tko
;
;; ------ test, zda je bod ji§ nastaven
;
;EditBod2:call      EdiGetB                  ; poskytnut¡ bodu
;         jc        EditBod8                 ; neplatn‚ souýadnice
;         cmp       al,ah                    ; je bod ji§ nastaven ?
;         je        EditBod8                 ; bod je ji§ nastaven
;
;; ------ nastaven¡ a zobrazen¡ nov‚ho bodu
;
;         mov       al,ah                    ; AL <- po§adovanì bod
;         call      EdiSetB                  ; nastaven¡ nov‚ho bodu
;         call      EdiDispB                 ; zobrazen¡ bodu
;
;; ------ zobrazen¡ editovan‚ ikony
;
;         push      bx
;         push      dx
;         push      es
;
;         mov       bx,ds:[EdiIHAkt]         ; aktu ln¡ ikona v historii
;         mov       dh,bl                    ; aktu ln¡ ikona v historii
;         shl       dh,1
;         shl       dh,1                     ; * 4
;         add       dh,2
;         mov       dl,1+32*2+2
;         shl       bx,1
;         mov       es,ds:[EdiIHist+bx]      ; adresa aktivn¡ ikony
;         call      DispIcon                 ; zobrazen¡ ikony
;
;         pop       es
;         pop       dx
;         pop       bx
;
;; ------ n vrat registr…
;
;         clc
;EditBod8:pop       ax
;         ret
;
;EditBod  ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ bodu DX na aktu ln¡ barvu (-> AL=pou§it  barva, CY=chyba)
; -----------------------------------------------------------------------------

EdiSetA  PROC      NEAR

         mov       al,ds:[ColLeft]          ; barva pro lev‚ tlaŸ¡tko
         test      byte ptr ds:[MouseK],bit1 ; je prav‚ tlaŸ¡tko ?
         jz        EdiSetB                  ; nen¡ prav‚ tlaŸ¡tko, je jen lev‚
         test      byte ptr ds:[MouseK],bit0 ; je lev‚ tlaŸ¡tko ?
         jz        EdiSetA2                 ; nen¡ lev‚ tlaŸ¡tko, je jen prav‚
         mov       al,dl                    ; pozice bodu
         xor       al,dh                    ; test lichosti bodu
         test      al,bit0                  ; je lichì bod ?
         mov       al,ds:[ColLeft]          ; barva pro sudì bod
         jz        EdiSetB                  ; je sudì bod
EdiSetA2:mov       al,ds:[ColRight]         ; jinak lichì bod
         jmp       short EdiSetB

EdiSetA  ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ bodu se souýadnic¡ DX na AL (-1=pozad¡) -> CY=mimo rozsah
; -----------------------------------------------------------------------------

EdiSetB  PROC      NEAR

; ------ £schova registr…

         push      ax
         push      cx
         push      dx
         push      si
         push      ds
         push      es

; ------ kontrola pýeteŸen¡ souýadnic

         cmp       dl,32                    ; pýeteŸen¡ pozice ?
         jae       EdiSetB1                 ; je pýeteŸen¡ pozice
         cmp       dh,32                    ; pýeteŸen¡ ý dku ?
EdiSetB1:cmc
         jc        EdiSetB3                 ; je pýeteŸen¡ ý dku

; ------ vìpoŸet bitov‚ masky -> CH

         mov       cl,dl                    ; CL <- pozice na ý dku
         and       cl,bit0+bit1+bit2        ; bitov  pozice v bajtu
         mov       ch,bit7
         shr       ch,cl                    ; CH <- maska bodu

; ------ vìpoŸet adresy bajtu -> DS:SI

         shr       dl,1
         shr       dl,1
         shr       dl,1                     ; DL = Ÿ¡slo bajtu na ý dku 0...3
         shl       dh,1
         shl       dh,1
         or        dl,dh                    ; DL <- offset bajtu v rovinØ
         mov       dh,0
         mov       si,dx                    ; SI <- offset bajtu v rovinØ

         push      ax
         mov       ax,ds:[ICONic]           ; ikona pozad¡
         call      AdrICO                   ; adresa ikony -> ES

         push      es

         mov       ax,ds:[EditIcoC]         ; AX <- Ÿ¡slo ikony
         call      AdrICO                   ; adresa ikony -> ES
         push      es
         pop       ds                       ; DS <- adresa ikony

         pop       es

         pop       ax

; ------ vynulov n¡ bodu, nastaven¡ jako pozad¡

         not       ch
         and       ds:[si],ch               ; rovina 0
         and       ds:[si+128],ch           ; rovina 1
         and       ds:[si+2*128],ch         ; rovina 2
         and       ds:[si+3*128],ch         ; rovina 3

; ------ test, je-li po§adov no pozad¡

         cmp       al,-1                    ; je pozad¡ ?
         jne       EdiSetB4                 ; nen¡ pozad¡
         and       ds:[si+4*128],ch         ; maska - pozad¡

         not       ch
         test      es:[si],ch
         jz        EdiSetB2
         or        ds:[si],ch

EdiSetB2:test      es:[si+128],ch
         jz        EdiStB22
         or        ds:[si+128],ch

EdiStB22:test      es:[si+2*128],ch
         jz        EdiStB24
         or        ds:[si+2*128],ch

EdiStB24:test      es:[si+3*128],ch
         jz        EdiSetB3
         or        ds:[si+3*128],ch

EdiSetB3:jmp       short EdiSetB9

; ------ nastaven¡ bit… bodu

EdiSetB4:not       ch                       ; maska bodu

         shr       al,1
         jnc       EdiSetB5
         or        ds:[si],ch

EdiSetB5:shr       al,1
         jnc       EdiSetB6
         or        ds:[si+128],ch

EdiSetB6:shr       al,1
         jnc       EdiSetB7
         or        ds:[si+2*128],ch

EdiSetB7:shr       al,1
         jnc       EdiSetB8
         or        ds:[si+3*128],ch

EdiSetB8:or        ds:[si+4*128],ch         ; maska - je platnì bit

; ------ n vrat registr…

EdiSetB9:pop       es
         pop       ds
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

EdiSetB  ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ bodu se souýadnic¡ DX -> AL (-2/CY=mimo rozsah, -1=pozad¡)
; -----------------------------------------------------------------------------

EdiGetB  PROC      NEAR

; ------ £schova registr…

         push      cx
         push      dx
         push      si
         push      es

; ------ kontrola pýeteŸen¡ souýadnic

         mov       al,-2                    ; n hradn¡ barva pro okol¡
         cmp       dl,32                    ; pýeteŸen¡ pozice ?
         jae       EdiGetB1                 ; je pýeteŸen¡ pozice
         cmp       dh,32                    ; pýeteŸen¡ ý dku ?
EdiGetB1:cmc
         jc        EdiGetB9                 ; je pýeteŸen¡ ý dku

; ------ vìpoŸet bitov‚ masky -> CH

         mov       cl,dl                    ; CL <- pozice na ý dku
         and       cl,bit0+bit1+bit2        ; bitov  pozice v bajtu
         mov       ch,bit7
         shr       ch,cl                    ; CH <- maska bodu

; ------ vìpoŸet adresy bajtu -> DS:SI

         shr       dl,1
         shr       dl,1
         shr       dl,1                     ; DL = Ÿ¡slo bajtu na ý dku 0...3
         shl       dh,1
         shl       dh,1
         or        dl,dh                    ; DL <- offset bajtu v rovinØ
         mov       dh,0
         mov       si,dx                    ; SI <- offset bajtu v rovinØ

         push      ax
         mov       ax,ds:[EditIcoC]         ; Ÿ¡slo ikony
         call      AdrICO                   ; adresa ikony -> ES
         pop       ax

; ------ test pozad¡

         mov       al,-1
         test      byte ptr es:[si+4*128],ch ; je pozad¡ ?
         jz        EdiGetB9                 ; je pozad¡

; ------ naŸten¡ barevnìch rovin

         mov       al,0                     ; inicializace stýadaŸe
         test      byte ptr es:[si],ch      ; je bit v rovinØ 0 ?
         jz        EdiGetB2                 ; nen¡ bit v rovinØ 0
         inc       ax                       ; nastaven¡ bitu roviny 0

EdiGetB2:test      byte ptr es:[si+128],ch  ; je bit v rovinØ 1 ?
         jz        EdiGetB3                 ; nen¡ bit v rovinØ 1
         or        al,bit1                  ; nastaven¡ bitu 1

EdiGetB3:test      byte ptr es:[si+2*128],ch ; je bit v rovinØ 2 ?
         jz        EdiGetB4                 ; nen¡ bit v rovinØ 2
         or        al,bit2                  ; nastaven¡ bitu 2

EdiGetB4:test      byte ptr es:[si+3*128],ch ; je bit v rovinØ 3 ?
         jz        EdiGetB9                 ; nen¡ bit v rovinØ 3
         or        al,bit3                  ; nastaven¡ bitu 3

; ------ n vrat registr…

EdiGetB9:pop       es
         pop       si
         pop       dx
         pop       cx
         ret

EdiGetB  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ bodu se souýadnic¡ DX na AL (-1=pozad¡) -> CY=mimo rozsah
; -----------------------------------------------------------------------------

EdiDispB PROC      NEAR

; ------ £schova registr…

         call      MouseOff                 ; vypnut¡ kurzoru myçi

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      es

; ------ kontrola pýeteŸen¡ souýadnic

         cmp       dl,32                    ; pýeteŸen¡ pozice ?
         jae       EdiDisB1                 ; je pýeteŸen¡ pozice
         cmp       dh,32                    ; pýeteŸen¡ ý dku ?
EdiDisB1:
         jb        EdiDsB12
         stc
         jmp       EdiDisB9                 ; je pýeteŸen¡ ý dku

; ------ pý¡prava adresy ve videopamØti -> ES:DI

EdiDsB12:xchg      ax,bx                    ; BL <- po§adovan  barva
         mov       al,14                    ; poŸet linek na bod
         mul       dh                       ; pýepoŸet ý dku na linku
         mov       dh,0
         shl       dl,1                     ; pýepoŸet pozice na bajty
         mov       di,dx                    ; DI <- bajtov  pozice na ý dku
         mov       dx,80                    ; poŸet bajt… na ý dek
         mul       dx                       ; pýepoŸet linky na offset
         add       di,ax                    ; DI <- adresa bajtu
         add       di,8*80 + 1              ; korekce poŸ tku
         mov       es,ds:[AdrVRAM]          ; adresa videopamØti
         cli
         cld

; ------ nastaven¡ z pisu do vçech rovin

         mov       dx,3c4h
         mov       al,2
         out       dx,al                    ; volba registru 2
         inc       dx                       ; datovì registr
         mov       al,1111b                 ; vçechny z pisov‚ roviny
         out       dx,al                    ; volba z pisov‚ roviny

; ------ nastaven¡ registr… barvy a masky

         mov       dx,3ceh
         mov       al,8                     ; registr 8
         out       dx,al                    ; volba registru 8
         inc       dx
         mov       al,0ffh                  ; maska - vçechny bity
         out       dx,al                    ; vçechny bity
         dec       dx
         mov       al,0
         out       dx,al                    ; volba registru 0
         inc       dx
         out       dx,al                    ; registr 0 nastaven na Ÿernou barvu
         dec       dx
         mov       al,1                     ; registr 1
         out       dx,al                    ; volba registru 1
         inc       dx

; ------ z pis pozad¡

         mov       cx,13                    ; poŸet linek k z pisu - 1

         cmp       bl,-1                    ; je pozad¡ ?
         jne       EdiDisB3                 ; nen¡ pozad¡

         mov       al,NOT CPOZADI           ; barva pro pozad¡
         out       dx,al                    ; nastaven¡ barvy pro pozad¡

         mov       bx,4444h
EdiDisB2:mov       ax,bx
         and       ah,not bit0
         stosw                              ; ulo§en¡ vzorku
         add       di,80-2                  ; adresa dalç¡ linky
         rol       bx,1
         loop      EdiDisB2                 ; dalç¡ linka
         jmp       short EdiDisB7

; ------ z pis Ÿern‚ barvy

EdiDisB3:cmp       bl,0                     ; je Ÿern  barva ?
         jne       EdiDisB5                 ; nen¡ Ÿern  barva

         mov       al,NOT 7                 ; barva pro r meŸek Ÿern‚
         out       dx,al                    ; nastaven¡ barvy pro Ÿernou

         mov       ax,100h                  ; zapisovan  hodnota
EdiDisB4:stosw                              ; ulo§en¡ vzorku
         add       di,80-2                  ; adresa dalç¡ linky
         loop      EdiDisB4                 ; dalç¡ linka
         mov       ax,-1                    ; spodn¡ linka
         jmp       short EdiDisB8

; ------ z pis bØ§n‚ barvy

EdiDisB5:mov       al,bl                    ; po§adovan  barva
         not       al
         out       dx,al                    ; nastaven¡ po§adovan‚ barvy

         mov       ax,0feffh                ; zapisovanì vzorek
EdiDisB6:stosw                              ; ulo§en¡ vzorku
         add       di,80-2                  ; adresa dalç¡ linky
         loop      EdiDisB6                 ; dalç¡ linka

; ------ z pis spodn¡ linky

EdiDisB7:xor       ax,ax                    ; spodn¡ linka
EdiDisB8:stosw                              ; oddØlovac¡ Ÿ ra

; ------ n vrat nastaven¡ barvy podle dat

         mov       al,0
         out       dx,al                    ; vçechny roviny podle dat
         clc                                ; pý¡znak operace OK

; ------ n vrat registr…

EdiDisB9:pop       es
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

EdiDispB ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ voleb editoru
; -----------------------------------------------------------------------------

EdiVDis  PROC      NEAR

         call      MouseOff                 ; vypnut¡ kurzoru myçi

; ------ pý¡prava ikony aktivn¡ch barev

         mov       ax,ds:[ICOBarv1]         ; ikona zvolen‚ barvy
         call      AdrICO                   ; adresa ikony -> ES
         mov       bl,bit0                  ; maska rovin
         xor       di,di                    ; ukl dac¡ adresa
EdiVDs12:mov       si,32*32*4/8             ; tabulka masky
         mov       cx,32                    ; poŸet linek k nastaven¡
EdiVDs13:mov       bh,ds:[ColLeft]          ; barva pro lev‚ tlaŸ¡tko
         call      EdiVDMsk                 ; maskov n¡
         mov       bh,ds:[ColRight]         ; barva pro prav‚ tlaŸ¡tko
         call      EdiVDMsk                 ; maskov n¡
         loop      EdiVDs13
         shl       bl,1                     ; pý¡prava pro dalç¡ rovinu
         cmp       bl,bit4                  ; jsou ji§ vçechny roviny ?
         jne       EdiVDs12                 ; dalç¡ rovina

; ------ zobrazen¡ malìch ikon (historie)

         mov       si,offset EdiIHist       ; historie ikon
         mov       dx,2*HI + 1+32*2+2       ; pozice k zobrazen¡ ikony
         mov       cx,HistEdiM              ; poŸet ikon v historii
EdiVDis4:mov       ax,ds:[si]               ; Ÿ¡slo ikony
         call      DispIcon                 ; zobrazen¡ editovan‚ ikony
         inc       si
         inc       si
         add       dh,4                     ; ukazatel ý dku
         loop      EdiVDis4

; ------ zobrazen¡ aktivn¡ funkce

         mov       ch,0
         mov       cl,ds:[FunkceEd]         ; funkce
         mov       dx,28*HI + 1+32*2+2
         mov       ax,ds:[ICOPero]          ; pero
         jcxz      EdiVDis5                 ; je pero
         mov       ax,ds:[ICOCara]
         dec       cx
         jz        EdiVDis5                 ; je Ÿ ra
         mov       ax,ds:[ICOCtve]
         dec       cx
         jz        EdiVDis5                 ; je Ÿtverec
         mov       ax,ds:[ICOKruh]
         dec       cx
         jz        EdiVDis5                 ; je kruh
;         mov       ax,ds:[ICOText]
;         dec       cx
;         jz        EdiVDis5                 ; je text
         mov       ax,ds:[ICOFill]
         dec       cx
         jz        EdiVDis5                 ; je naplnØn¡
         mov       ax,ds:[ICOBlok]
EdiVDis5:call      DispIcon

; ------ zobrazen¡ volby barev

         mov       dx,32*HI + 1+32*2+2
         mov       ax,ds:[ICOBarv1]
         call      DispIcon
         add       dh,4
         mov       ax,ds:[ICOBarv2]
         call      DispIcon
         add       dh,4
         mov       ax,ds:[ICOBarv3]
         call      DispIcon
         add       dh,4
         mov       ax,ds:[ICOBarv4]
         call      DispIcon
         add       dh,4
         mov       ax,ds:[ICOBarv5]
         call      DispIcon
         add       dh,4
         mov       ax,ds:[ICOBarv6]
         call      DispIcon

         ret

EdiVDis  ENDP

; ------ maska se slovem AX

EdiVDMsk:xor       ax,ax                    ; barva nen¡ nastavena
         test      bh,bl                    ; je bit nastaven ?
         jz        EdiVDMs2                 ; bit nen¡ nastaven
         dec       ax                       ; AX <- -1 bit nastaven

EdiVDMs2:cmp       bh,-1                    ; je pozad¡ ?
         jne       EdiVDMs5                 ; nen¡ pozad¡
         mov       ax,4444h                 ; barva pro pozad¡
         test      di,bit2                  ; je lich  linka ?
         jz        EdiVDMs3                 ; nen¡ lich  linka
         rol       ax,1                     ; vzorek pro lichou linku
EdiVDMs3:test      di,bit3
         jz        EdiVDMs4
         rol       ax,1
         rol       ax,1
EdiVDMs4:cmp       bl,bit0
         je        EdiVDMs5
         cmp       bl,bit1
         je        EdiVDMs5
         xor       ax,ax

EdiVDMs5:mov       dx,es:[si]               ; maska
         and       es:[di],dx               ; zruçen¡ starìch dat
         not       dx                       ; inverze
         and       dx,ax                    ; nov  data
         or        es:[di],dx               ; ulo§en¡ novìch dat

         inc       di
         inc       di                       ; zvìçen¡ ukazatele v datech

         inc       si
         inc       si                       ; zvìçen¡ ukazatele v masce
         ret

; -----------------------------------------------------------------------------
;        volba ikony -> AX=Ÿ¡slo ikony, CY=pýeruçen¡
; -----------------------------------------------------------------------------

VolIcon  PROC      NEAR

; ------ £schova registr…

         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bl,ds:[Rezim]            ; aktu ln¡ re§im
         push      bx
         mov       byte ptr ds:[Rezim],3    ; re§im volby ikon

; ------ zobrazen¡ r mu kolem hrac¡ plochy

         call      DispRam                  ; zobrazen¡ r mu kolem hrac¡ plochy

; ------ zobrazen¡ r mu kolem menu

         call      MenuRam                  ; zobrazen¡ r mu kolem menu

; ------ zobrazen¡ menu

         call      DispMenu                 ; zobrazen¡ menu

; ------ zobrazen¡ ikon

         mov       dh,1                     ; ukazatel Ÿ¡sla ý dku
         xor       ax,ax                    ; ukazatel Ÿ¡sla ikony
VolIcon2:mov       dl,1                     ; ukazatel pozice

VolIcon3:push      ax
         cmp       ax,ds:[DataICON]         ; je platn‚ Ÿ¡slo ikony ?
         jb        VolIco32                 ; je platn‚ Ÿ¡slo ikony
         mov       ax,ds:[ICONic]           ; pr zdn  plocha
VolIco32:call      DispIcon                 ; zobrazen¡ ikony
         pop       ax

         inc       ax                       ; zvìçen¡ Ÿ¡sla ikony
         add       dl,4                     ; zvìçen¡ ukazatele pozice
         cmp       dl,1+4*PSIRKA            ; jsou vçechny pozice ?
         jb        VolIcon3                 ; dalç¡ pozice
         add       dh,4                     ; zvìçen¡ ukazatele ý dku
         cmp       dh,1+4*PVYSKA            ; jsou vçechny ý dky ?
         jb        VolIcon2                 ; dalç¡ ý dek

; ------ zobrazen¡ jm‚na ikony (BX=souýadnice ikony !!!)

VolIcon4:mov       bx,ds:[VolILast]         ; ukazatel ý dku a pozice
         call      VolKZap                  ; zapnut¡ kurzoru
         call      TextRam                  ; zobrazen¡ r mu kolem textu

         mov       word ptr ds:[ProgStr]," "*HI + 1 ; pr zdnì ýetØzec

         mov       al,PSIRKA                ; poŸet pozic na ý dek
         mul       bh                       ; pýepoŸet ý dku na pozice
         add       al,bl                    ; pýiŸten¡ pozice
         adc       ah,0
         cmp       ax,ds:[DataICON]         ; je to platn‚ Ÿ¡slo ikony ?
         jae       VolIco48                 ; nen¡ to platn‚ Ÿ¡slo ikony
         call      GetIName                 ; naŸten¡ jm‚na ikony AX

VolIco48:xor       ax,ax                    ; barva textu = Ÿern 
         mov       cx,-1                    ; doba
         mov       si,offset ProgStr        ; buffer s textem
         call      DispHlas                 ; zobrazen¡ jm‚na ikony

; ------ obsluha blik n¡ kurzoru

VolIcon5:push      es
         xor       ax,ax
         mov       es,ax                    ; ES <- 0
         test      byte ptr es:[46ch],4     ; m  bìt kurzor zapnut ?
         pop       es
         jnz       VolIco51                 ; zapnut¡ kurzoru
         call      VolKVyp                  ; vypnut¡ kurzoru volby
         jmp       short VolIco52

VolIco51:call      VolKZap                  ; zapnut¡ kurzoru volby

; ------ Ÿek n¡ na stisk kl vesy nebo stisk myçi

VolIco52:call      MouseOn                  ; zapnut¡ kurzoru myçi
         call      InpChar                  ; vstup znaku z kl vesnice
         jnc       VolIcon7                 ; je kl vesa
         call      GetMouse                 ; naŸten¡ stavu myçi
         jc        VolIcon5                 ; nen¡ stisk myçi

; ------ obsluha stisku myçi

         cmp       dl,PSIRKA                ; je pozice OK ?
         jae       VolIcon6                 ; pýekroŸen¡ pozice
         cmp       dh,PVYSKA                ; je ý dek OK ?
         jae       VolIcon5                 ; pýekroŸen¡ ý dku

         mov       bx,dx                    ; BX <- nastaven¡ ý dku a pozice
         jmp       VolIc772                 ; zvolen¡ polo§ky

VolIcon6:jmp       VolIcon8                 ; pýeruçen¡ operace

; ------ vstup znaku z kl vesnice

VolIcon7:call      VolKVyp                  ; vypnut¡ kurzoru

; ------ kurzor nahoru

         cmp       ah,48h                   ; nahoru
         je        VolIco71                 ; je nahoru

; ------ Home

         cmp       ah,47h                   ; HOME
         je        VolIco72                 ; je Home

; ------ kurzor vlevo

         cmp       ah,4bh                   ; vlevo
         jne       VolIco73
         dec       bl                       ; sn¡§en¡ pozice na ý dku
         jns       VolIco79                 ; pozice je OK
         mov       bl,PSIRKA-1              ; posledn¡ polo§ka na ý dku
VolIco71:dec       bh                       ; sn¡§en¡ ý dku
         jns       VolIco79                 ; ý dek je OK
VolIco72:xor       bx,bx                    ; ukazatel na poŸ tek
         jmp       short VolIco79

; ------ END - posledn¡ polo§ka

VolIco73:cmp       ah,4fh                   ; End
         je        VolIco76                 ; je End

; ------ dol…

         cmp       ah,50h                   ; dol…
         je        VolIco74                 ; je dol…

; ------ vpravo

         cmp       ah,4dh                   ; vpravo
         jne       VolIco77                 ; nen¡ vpravo
         inc       bl                       ; zvìçen¡ pozice na ý dku
         cmp       bl,PSIRKA
         jb        VolIco75                 ; je to OK
         mov       bl,0                     ; poŸ tek ý dku
VolIco74:inc       bh                       ; zvìçen¡ ukazatele ý dku

; ------ kontrola pýeteŸen¡

VolIco75:mov       al,PSIRKA                ; poŸet polo§ek na ý dek
         mul       bh                       ; pýepoŸet ý dku na polo§ky
         add       al,bl                    ; pýiŸten¡ pozcie
         adc       ah,0
         cmp       ax,ds:[DataICON]         ; pýeteŸen¡ poŸtu polo§ek ?
         jae       VolIco76                 ; je pýeteŸen¡ poŸtu polo§ek
         cmp       ax,PSIRKA*PVYSKA         ; pýeteŸen¡ obrazovky ?
         jb        VolIco79                 ; vçe OK

; ------ nastaven¡ maxim ln¡ polo§ky

VolIco76:mov       ax,ds:[DataICON]         ; poŸet polo§ek
         cmp       ax,PSIRKA*PVYSKA         ; je v¡ce str nek ?
         jbe       VolIc762                 ; nen¡ v¡ce str nek
         mov       ax,PSIRKA*PVYSKA         ; omezen¡
VolIc762:dec       ax                       ; posledn¡ polo§ka
         mov       cl,PSIRKA                ; poŸet polo§ek na ý dek
         div       cl                       ; pýepoŸet na ý dek a pozici
         xchg      al,ah                    ; oprava poýad¡ polo§ek
         xchg      ax,bx                    ; BX <- maxim ln¡ polo§ka
         jmp       short VolIco79

; ------ proveden¡ volby ENTER

VolIco77:cmp       al,13                    ; je ENTER ?
         jne       VolIco78                 ; nen¡ ENTER

VolIc772:mov       ds:[VolILast],bx         ; nov  pozice kurzoru
         mov       al,PSIRKA                ; poŸet pozic na ý dek
         mul       bh                       ; pýepoŸet ý dku na pozice
         add       al,bl                    ; pýiŸten¡ pozice
         adc       ah,0
         cmp       ax,ds:[DataICON]         ; je to platn‚ Ÿ¡slo ikony ?
         jae       VolIco76                 ; nen¡ to platn‚ Ÿ¡slo ikony
         clc                                ; pý¡znak operace OK
         jmp       short VolIcon9           ; AX = Ÿ¡slo zvolen‚ ikony

; ------ pýeruçen¡ volby ESC nebo Ctrl-Break

VolIco78:cmp       al,27                    ; ESC
         je        VolIcon8                 ; pýeruçen¡ ESC
         or        ax,ax                    ; Ctrl-Break
         jz        VolIcon8                 ; pýeruçen¡ Ctrl-Break
VolIco79:mov       ds:[VolILast],bx         ; nov  pozice kurzoru
         jmp       VolIcon4                 ; nov‚ zobrazen¡ kurzoru
VolIcon8:stc                                ; pý¡znak pýeruçen¡ operace

; ------ n vrat registr…

VolIcon9:pop       bx
         mov       ds:[Rezim],bl            ; n vrat re§imu
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

VolIcon  ENDP

; -----------------------------------------------------------------------------
;        naŸten¡ jm‚na ikony (+.ICO) AX do bufferu PROGSTR -> CY=nenalezeno
; -----------------------------------------------------------------------------

GetIName PROC      NEAR

; ------ £schova registr…

         push      ax
         push      bx
         push      cx
         push      si
         push      di
         push      ds
         push      es

         mov       word ptr ds:[ProgStr],0  ; pýednastaven¡ - nen¡ jm‚no

; ------ nalezen¡ jm‚na ikony

         mov       cx,ds:[DataICON]         ; poŸet ikon
         push      ds
         mov       ds,ds:[DataSegm]         ; segment symbol… ikon
         pop       es
         xor       si,si                    ; zaŸ tek jmen
         cld
GetINam2:mov       bl,ds:[si]               ; d‚lka jm‚na ikony
         mov       bh,0
         cmp       ax,ds:[si+bx+1]          ; souhlas¡ Ÿ¡slo ikony ?
         je        GetINam4                 ; Ÿ¡slo ikony souhlas¡
         add       si,bx                    ; pýeskoŸen¡ jm‚na ikony
         add       si,3                     ; pýeskoŸen¡ d‚lky a adresy
         loop      GetINam2
         stc                                ; pý¡znak chyby
         jmp       short GetINam8

; ------ pýenesen¡ jm‚na ikony do bufferu

GetINam4:mov       di,offset ProgStr        ; buffer pro text
         mov       cx,bx                    ; CX <- d‚lka jm‚na ikony
         movsb                              ; pýenesen¡ d‚lky
         rep       movsb                    ; pýenesen¡ jm‚na

; ------ pýenesen¡ pý¡padn‚ pý¡pony ".ICO"

         mov       ax,"I."
         stosw
         mov       ax,"OC"
         stosw
         mov       al,0
         stosb
         clc                                ; pý¡znak operace OK

; ------ n vrat registr…

GetINam8:pop       es
         pop       ds
         pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

GetIName ENDP

; -----------------------------------------------------------------------------
;        zapnut¡ kurzoru volby (souýadnice BX)
; -----------------------------------------------------------------------------

VolKZap  PROC      NEAR

         test      byte ptr ds:[Param],bit5 ; je kurzor zapnut ?
         jz        VolKurz                  ; kurzor nen¡ zapnut - zapnut¡
         ret

VolKZap  ENDP

; -----------------------------------------------------------------------------
;        vypnut¡ kurzoru volby (souýadnice BX)
; -----------------------------------------------------------------------------

VolKVyp  PROC      NEAR

         test      byte ptr ds:[Param],bit5 ; je kurzor zapnut ?
         jnz       VolKurz                  ; kurzor je zapnut - vypnut¡
         ret

VolKVyp  ENDP

; -----------------------------------------------------------------------------
;        inverze kurzoru volby (souýadnice BX)
; -----------------------------------------------------------------------------

VolKurz  PROC      NEAR

; ------ £schova registr…

         call      MouseOff                 ; vypnut¡ kurzoru myçi

         xor       byte ptr ds:[Param],bit5 ; zmØna pý¡znaku kurzoru
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ vìpoŸet adresy ve videopamØti -> DI

         shl       bh,1
         shl       bh,1                     ; pýepoŸet na ý dek
         inc       bh                       ; pýiŸten¡ poŸ tku
         mov       al,8                     ; poŸet linek na ý dek
         mul       bh                       ; pýepoŸet ý dku na linku
         mul       word ptr ds:[DispSirB]   ; pýepoŸet na adresu ve videopamØti
         shl       bl,1
         shl       bl,1                     ; pýepoŸet na bajtovou pozici
         inc       bx                       ; pýiŸten¡ poŸ tku
         mov       bh,0
         add       ax,bx                    ; pýiŸten¡ pozice
         xchg      ax,di                    ; DI <- adresa ve videopamØti

; ------ pý¡prava k operaci

         cld
         cli                                ; z kaz pýeruçen¡ bØhem operace
         xor       cx,cx                    ; CX <- 0
         mov       es,ds:[AdrVRAM]          ; adresa videopamØti
         mov       bx,1001h                 ; maska barevn‚ roviny

; ------ nastaven¡ z pisov‚ roviny

         mov       dx,3c4h
         mov       al,2
         out       dx,al                    ; volba registru 2
         inc       dx                       ; datovì registr
         mov       al,0fh                   ; z pisov  rovina - vçechno
         out       dx,al                    ; volba z pisov‚ roviny

; ------ nastaven¡ z pisov‚ho m¢du XOR

         mov       dx,3ceh
         mov       al,3
         out       dx,al
         inc       dx
         mov       al,18h
         out       dx,al                    ; z pisovì m¢d XOR

; ------ z pis horn¡ linky

         cld
         call      DispKrV
         call      DispKrV

; ------ z pis okraj…

         mov       cx,28
VolKurz4:mov       al,0c0h
         xchg      al,es:[di]
         mov       al,3
         xchg      al,es:[di+3]
         add       di,80
         loop      VolKurz4

; ------ z pis spodn¡ linky

         call      DispKrV
         call      DispKrV

; ------ n vrat bØ§n‚ho z pisov‚ho m¢du

         mov       al,0
         out       dx,al                    ; nastaven¡ bØ§n‚ho m¢du

; ------ n vrat registr…

         sti                                ; pýeruçen¡ opØt povoleno
         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

VolKurz  ENDP

; ------ z pis linky EGA a VGA

DispKrV  PROC      NEAR

DispKrV2:mov       al,-1
         xchg      al,es:[di]
         inc       di

         mov       al,-1
         xchg      al,es:[di]
         inc       di

         mov       al,-1
         xchg      al,es:[di]
         inc       di

         mov       al,-1
         xchg      al,es:[di]
         inc       di

         add       di,80-4
         ret

DispKrV  ENDP

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

ReadICO2:mov       word ptr ds:[DTA+1eh-4],"CI"
         mov       word ptr ds:[DTA+1eh-2],"\O"
         mov       dx,offset DTA+1eh - 4    ; jm‚no souboru
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

ReadIC69:mov       ax,ds:[DataICON]         ; starì poŸet ikon
         stosw                              ; ulo§en¡ Ÿ¡sla ikony

; ------ nov  adresa konce symbol…

         inc       word ptr ds:[DataICON]   ; zvìçen¡ Ÿ¡taŸe ikon

         mov       ds:[DataICOE],di         ; nov  adresa konce symbol…
         add       di,0fh                   ; zaokrouhlen¡ nahoru
         mov       cl,4
         shr       di,cl                    ; pýevod na odstavce
         add       di,ds:[DataSegm]
         mov       ds:[DataProg],di         ; nov  adresa programu
         mov       ax,ds:[DataICO]          ; adresa ikony
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

; ------ ulo§en¡ Ÿ¡sla ikony

IniICOD6:cld
         push      ax
         lodsb                              ; d‚lka jm‚na ikony
         mov       ah,0
         add       si,ax                    ; pýeskoŸen¡ jm‚na
         pop       ax
         mov       ds:[si],ax               ; Ÿ¡slo ikony

; ------ dalç¡ ikona

         inc       si
         inc       si                       ; pýeskoŸen¡ adresy ikony
         cmp       si,offset ICODef0        ; je konec tabulky ?
         jb        IniICOD2                 ; bude dalç¡ ikona
         ret

IniICOD  ENDP

; -----------------------------------------------------------------------------
;        vìpoŸet adresy ikony AX -> ES (CY=chybn‚ jm‚no ikony, ES nezmØnØno
; -----------------------------------------------------------------------------

AdrICO   PROC      NEAR

; ------ £schova registr…

         push      ax
         push      dx

; ------ kontrola Ÿ¡sla ikony

         mov       dx,ds:[DataICON]         ; poŸet ikon celkem
         cmp       ax,dx                    ; kontrola Ÿ¡sla ikony
         cmc                                ; CY = chybn‚ Ÿ¡slo
         jc        AdrICO9                  ; neplatn‚ Ÿ¡slo ikony

; ------ vìpoŸet adresy ikony

         dec       dx                       ; DX <- Ÿ¡slo posledn¡ ikony
         sub       dx,ax                    ; DX <- doplåkov‚ Ÿ¡slo ikony
         mov       ax,ICOSize/16            ; velikost ikony v odstavc¡ch
         mul       dx                       ; vìpoŸet offsetu ikony
         add       ax,ds:[DataICO]          ; adresa ikony
         mov       es,ax                    ; ES <- adresa ikony

; ------ n vrat registr…

AdrICO9: pop       dx
         pop       ax
         ret

AdrICO   ENDP

; -----------------------------------------------------------------------------
;        nalezen¡ ikony DS:SI -> AX (CY=nenalezeno, AX nezmØnØno)
; -----------------------------------------------------------------------------

SrcICO   PROC      NEAR

; ------ £schova registr…

         push      cx
         push      dx
         push      di

; ------ pý¡prava k prohled n¡ tabulky

         cld
         xor       di,di                    ; ukazatel v tabulce ikon
         mov       dx,ds:[DataICON]         ; DX <- poŸet ikon
         mov       es,ds:[DataSegm]         ; segment symbol… ikon
         xor       cx,cx                    ; CX <- 0

; ------ test, zda je dalç¡ ikona

SrcICO2: or        dx,dx                    ; je dalç¡ ikona ?
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
         dec       dx                       ; Ÿ¡taŸ ikon
         jmp       short SrcICO2            ; dalç¡ ikona

; ------ Ÿ¡slo ikony -> AX

SrcICO4: add       di,cx                    ; pýiŸten¡ d‚lky jm‚na ikony + 1
         mov       ax,es:[di]               ; Ÿ¡slo ikony
         clc                                ; pý¡znak operace OK

; ------ n vrat registr…

SrcICO9: pop       di
         pop       dx
         pop       cx
         ret

SrcICO   ENDP

; -----------------------------------------------------------------------------
;        inicializace pozad¡ ikon
; -----------------------------------------------------------------------------

IniPozad PROC      NEAR

         push      ds

         mov       ax,ds:[ICONic]           ; ikona pozad¡
         call      AdrICO                   ; adresa ikony -> ES

         push      es

         mov       es,ds:[DataICO]          ; zaŸ tek ikon
         mov       dx,ds:[DataICON]         ; poŸet ikon

         pop       ds                       ; adresa pozad¡ plochy

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
         mov       ax,ds:[ICONic]           ; Ÿ¡slo ikony plochy
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

; ------ zobrazen¡ plochy

         call      DispPole                 ; zobrazen¡ pole

; ------ zobrazen¡ menu

         call      DispMenu                 ; zobrazen¡ menu
         ret

IniVymaz ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ menu
; -----------------------------------------------------------------------------

DispMenu PROC      NEAR

         push      ax
         push      bx
         push      dx

         mov       dh,1
         mov       bh,0
DispMen2:mov       dl,1+PSIRKA*4+1+1
         mov       bl,0
DispMen3:mov       ax,ds:[ICOMenu]

         cmp       byte ptr ds:[Rezim],1    ; je prov dØn¡ programu ?
         jne       DispM301
         jmp       DispMenD                 ; je prov dØn¡ programu

DispM301:
         cmp       byte ptr ds:[Rezim],3    ; je re§im volby ikon
         jne       DispMn30
         jmp       DispMn38

DispMn30:cmp       byte ptr ds:[Rezim],4    ; je re§im editace ikon
         je        DispM302
         jmp       DispMn39

DispM302:
         or        bx,bx
         jnz       DispMn31
         mov       ax,ds:[ICOPero]
DispMn31:cmp       bx,100h
         jne       DispMn32
         mov       ax,ds:[ICOCara]
DispMn32:cmp       bx,200h
         jne       DispMn33
         mov       ax,ds:[ICOCtve]
DispMn33:cmp       bx,300h
         jne       DispMn34
         mov       ax,ds:[ICOKruh]
DispMn34:
;         cmp       bx,400h
;         jne       DispM342
;         mov       ax,ds:[ICOText]
DispM342:cmp       bx,400h
         jne       DispMn35
         mov       ax,ds:[ICOFill]
DispMn35:cmp       bx,500h
         jne       DispM352
         mov       ax,ds:[ICOBlok]
DispM352:
;         cmp       bx,600h
;         jne       DispM354
;         mov       ax,ds:[ICOBlokS]
DispM354:cmp       bx,600h
         jne       DispMn36
         mov       ax,ds:[ICOBlokL]
DispMn36:cmp       bx,700h
         jne       DispMn37
         mov       ax,ds:[ICOFlip]
DispMn37:cmp       bx,800h
         jne       DispM371
         mov       ax,ds:[ICORot]
DispM371:cmp       bx,900h
         jne       DispM372
         mov       ax,ds:[ICOXCol]
DispM372:cmp       bx,0a00h
         jne       DispM373
         mov       ax,ds:[ICOUndo]
DispM373:cmp       bx,0b00h
         jne       DispM374
         mov       ax,ds:[ICORedo]
DispM374:

;         cmp       bx,0b00h
;         jne       DispM377
;         mov       ax,ds:[ICOLoad]
;DispM377:

         cmp       bx,0c00h
         jne       DispM378
         mov       ax,ds:[ICOSave]
DispM378:


DispMn38:jmp       short DispMenC

DispMn39:or        bx,bx
         jnz       DispMen4
         mov       ax,ds:[ICOVlevo]
DispMen4:cmp       bx,100h
         jne       DispMen5
         mov       ax,ds:[ICOVzad]
DispMen5:cmp       bx,200h
         jne       DispMen6
         mov       ax,ds:[ICOVprav]
DispMen6:cmp       bx,300h
         jne       DispMen7
         mov       ax,ds:[ICOKrok]
DispMen7:cmp       bx,400h
         jne       DispMen8
         mov       ax,ds:[ICOLast]
DispMen8:cmp       bx,500h
         jne       DispMen9
         mov       ax,ds:[ICOIkony]
DispMen9:
;         cmp       bx,600h
;         jne       DispMn92
;         mov       ax,ds:[ICOStart]
DispMn92:

DispMenA:cmp       bx,0b00h
         jne       DispMenB
;         mov       ax,ds:[ICODisk]
         mov       ax,ds:[ICOStart]
DispMenB:cmp       bx,0c00h
         jne       DispMenC
         mov       ax,ds:[ICOMaluj]

DIspMenC:cmp       bx,0d00h
         jne       DispMenD
         mov       ax,ds:[ICOKonec]

DispMenD:call      DispIcon
         inc       bx
         add       dl,4
         cmp       dl,1+PSIRKA*4+1+1+MSIRKA*4
         jae       DispMnD2
         jmp       DispMen3

DispMnD2:inc       bh
         add       dh,4
         cmp       dh,1+MVYSKA*4
         jae       DispMenX
         jmp       DispMen2

DispMenX:
         pop       dx
         pop       bx
         pop       ax
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

         mov       ax,ds:[ICORamT]          ; Ÿ¡slo ikony r mu kolem textu
         call      AdrICO                   ; adresa ikony -> ES
         push      es
         mov       es,ds:[AdrVRAM]          ; ES <- adresa videopamØti
         pop       ds                       ; adresa ikony r mu kolem textu

         mov       ch,0
         xor       si,si                    ; SI <- 0 poŸ tek dat ikony
         cld
         cli

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

         sti
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

         mov       ax,ds:[ICORamM]          ; Ÿ¡slo ikony r mu kolem menu
         call      AdrICO                   ; adresa ikony -> ES
         push      es
         mov       es,ds:[AdrVRAM]          ; ES <- adresa videopamØti
         pop       ds                       ; adresa ikony r mu kolem menu

         mov       ch,0
         xor       si,si                    ; SI <- 0 poŸ tek dat ikony
         cld
         cli

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

         sti
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

         mov       ax,ds:[ICORam]           ; Ÿ¡slo ikony r mu
         call      AdrICO                   ; adresa ikony -> ES
         push      es
         mov       es,ds:[AdrVRAM]          ; ES <- adresa videopamØti
         pop       ds                       ; adresa ikony r mu

         mov       ch,0
         xor       si,si                    ; SI <- 0 poŸ tek dat ikony
         cld
         cli

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

         sti
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

; ------ kontrola ukazatel…

         cmp       dh,PVYSKA
         jae       PoleIco9                 ; chybnì ý dek
         cmp       dl,PSIRKA
         jae       PoleIco9                 ; chybn  pozice

; ------ kontrola, zda se t¡m vyma§e Petr

         cmp       dx,ds:[PetrOPz]         ; je to star  pozice Petra ?
         jne       PoleIco4                 ; nen¡ to star  pozice Petra
         and       byte ptr ds:[Param],not bit3 ; Petr nen¡ zobrazen

; ------ Ÿ¡slo ikony -> AX

PoleIco4:mov       al,PSIRKA                ; poŸet pozic na ý dek
         mul       dh                       ; pýepoŸet ý dku na pozici
         add       al,dl                    ; pýiŸten¡ pozice
         adc       ah,0
         shl       ax,1                     ; offset v tabulce
         xchg      ax,bx                    ; BX <- offset v tabulce
         mov       ax,ds:[bx+Pole]          ; AX <- Ÿ¡slo ikony

; ------ pozice k zobrazen¡ -> DX

         shl       dx,1
         shl       dx,1
         add       dx,101h

; ------ zobrazen¡ ikony

         call      DispIcon                 ; zobrazen¡ ikony

; ------ n vrat registr…

PoleIco9:pop       dx
         pop       bx
         pop       ax
         ret

PoleIcon ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ikony AX, linka DH, pozice DL
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

; ------ adresa ikony AX -> ES

         call      AdrICO                   ; adresa ikony -> ES

; ------ ukl dac¡ adresa do videopamØti -> DI

         push      dx
         mov       al,8
         mul       dh                       ; pýepoŸet ý dku na linku
         mul       word ptr ds:[DispSirB]   ; pýepoŸet na bajty
         pop       dx
         mov       dh,0
         add       ax,dx                    ; adresa k ulo§en¡
         xchg      ax,di                    ; DI <- adresa ve videopamØti
         cld
         cli

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

         sti
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
; zobrazen¡ pýedmØtu s maskou (AX=pýedmØt, DH=linka, DL=pozice, mohou bìt mimo rozsah)
; -----------------------------------------------------------------------------

PoleMask PROC      NEAR

; ------ £schova registr…

         push      dx

; ------ kontrola ukazatel…

         cmp       dh,PVYSKA
         jae       PoleMsk9                 ; chybnì ý dek
         cmp       dl,PSIRKA
         jae       PoleMsk9                 ; chybn  pozice

; ------ kontrola, zda se t¡m vyma§e Petr

         cmp       dx,ds:[PetrOPz]         ; je to star  pozice Petra ?
         jne       PoleMsk4                 ; nen¡ to star  pozice Petra
         and       byte ptr ds:[Param],not bit3 ; Petr nen¡ zobrazen

; ------ pozice k zobrazen¡ -> DX

PoleMsk4:shl       dx,1
         shl       dx,1
         add       dx,101h

; ------ zobrazen¡ ikony

         call      MaskIcon                 ; zobrazen¡ ikony

; ------ n vrat registr…

PoleMsk9:pop       dx
         ret

PoleMask ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ikony s maskou AX, linka DH, pozice DL
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

; ------ adresa ikony AX -> ES

         call      AdrICO                   ; adresa ikony -> ES

; ------ ukl dac¡ adresa do videopamØti -> DI

         push      dx
         mov       al,8
         mul       dh                       ; pýepoŸet ý dku na linku
         mul       word ptr ds:[DispSirB]   ; pýepoŸet na bajty
         pop       dx
         mov       dh,0
         add       ax,dx                    ; adresa k ulo§en¡
         xchg      ax,di                    ; DI <- adresa ve videopamØti
         cld
         cli

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

         sti
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
;        zobrazen¡ hl çen¡ DS:SI, barva AH (=bØ§nì)/AL (=vìraznì), doba CX
; -----------------------------------------------------------------------------
; d‚lka textu DS:SI se ud v  jako zobrazen  d‚lka (bez pýep¡nac¡ch znak…):
;             %* ........ zmØna zvìraznØn  (=AL) / norm ln¡ (=AH) barva
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
         mov       bx,78                    ; maxim ln¡ d‚lka textu
         sub       bx,cx
         jnc       DispHls3
         xor       bx,bx
         mov       cl,78
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
;        zobrazen¡ textu programem
; -----------------------------------------------------------------------------

PetText  PROC      NEAR

; ------ pý¡prava textu hl çen¡

         call      IniHlas                  ; pý¡prava textu hl çen¡
         jc        PetText9                 ; chyba

; ------ test, zda je blokov n¡ pý¡kazu

         call      TestBlok                 ; test blokov n¡ programu
         jnz       PetText9                 ; je blokov n¡ pý¡kaz…

; ------ inicializace Ÿ¡sla ý dku a pozice -> BX

         call      NextPoz                  ; pý¡çt¡ pozice -> BX
         shl       bh,1                     ; budou 2 ý dky na ikonu
         cmp       byte ptr ds:[TextRad],-1 ; je platn‚ Ÿ¡slo ý dku ?
         je        PetText6                 ; Ÿ¡slo ý dku nen¡ platn‚
         mov       bh,ds:[TextRad]          ; plat¡ uschovanì ý dek
PetText6:mov       ds:[TextRad],bh          ; £schova Ÿ¡sla ý dku

; ------ kontrola platnosti Ÿ¡sla ý dku

         cmp       byte ptr ds:[TextRad],PVYSKA*2 ; je platn‚ Ÿ¡slo ý dku ?
         jae       PetText8                 ; pýeteŸen¡ Ÿ¡sla ý dku

; ------ vìpoŸet Ÿ¡sla videolinky -> DX

         mov       al,16                    ; poŸet linek na ý dek
         mul       bh                       ; pýepoŸet ý dku na linku
         add       ax,8                     ; pýiŸten¡ poŸ teŸn¡ linky
         xchg      ax,dx                    ; DX <- Ÿ¡slo videolinky

; ------ vìpoŸet Ÿ¡sla pozice -> BX

         xchg      ax,bx                    ; AL <- pozice ikony
         cbw                                ; konverze na slovo
         shl       ax,1
         shl       ax,1                     ; AX <- offset v bajtech
         inc       ax                       ; pýiŸten¡ poŸ teŸn¡ pozice
         xchg      ax,bx                    ; BX <- ukazatel pozice

; ------ omezen¡ d‚lky textu

         mov       ax,PSIRKA*4+1            ; konec za plochou
         sub       ax,bx                    ; zbìvaj¡c¡ poŸet znak…
         js        PetText8                 ; text je za koncem ý dku
         cmp       al,byte ptr ds:[ProgStr] ; je pýeteŸen¡ d‚lky textu ?
         jae       PetText7                 ; d‚lka textu je OK
         mov       ds:[ProgStr],al          ; omezen¡ d‚lky textu

; ------ zobrazen¡ textu

PetText7:mov       si,offset ProgStr+1      ; text hl çen¡
         mov       cl,ds:[si-1]             ; d‚lka textu
         mov       ch,0
         mov       ax,99h                   ; barva textu - Ÿern /Ÿerven 
         call      DispTxt                  ; zobrazen¡ textu
PetText8:inc       byte ptr ds:[TextRad]    ; zvìçen¡ ukazatele ý dku
         clc
PetText9:ret

PetText  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ textu DS:SI, barva AH/AL, linka DX, pozice BX, CX znak…
; -----------------------------------------------------------------------------
; d‚lka textu v CX se ud v  jako zobrazen  d‚lka (bez pýep¡nac¡ch znak…):
;             %* ........ zmØna zvìraznØn  (=AL) / norm ln¡ (=AH) barva
;             %$N ....... nastaven¡ barvy textu ("0" a§ "9", "A" a§ "F")
;                         "G" a§ "V" = barva pozad¡ (pýi nastaven¡ textu a
;                         pozad¡ na stejnou barvu je ponech no p…vodn¡ pozad¡)
; -----------------------------------------------------------------------------

DispTxt  PROC      NEAR

         push      ax
         push      cx
         push      si

         jcxz      DispTxt8                 ; nen¡ § dnì text

; ------ zmØna zvìraznØn¡

DispTxt1:cmp       word ptr ds:[si],"*%"    ; je zmØna barvy ?
         jne       DispTxt2                 ; nen¡ zmØna barvy
         xchg      ah,al                    ; zmØna barvy
         inc       si
         inc       si                       ; pýeskoŸen¡ znak…
         jmp       short DispTxt1

; ------ nastaven¡ barvy textu

DispTxt2:cmp       word ptr ds:[si],"$%"    ; je nastaven¡ barvy ?
         jne       DispTxt4                 ; nen¡ nastaven¡ barvy

         inc       si
         inc       si                       ; pýeskoŸen¡ znak…

         push      dx

         mov       dl,ds:[si]               ; znak pro barvu
         xchg      ax,dx
         call      UpCase                   ; konverze na velk‚ p¡smeno
         xchg      ax,dx
         cmp       dl,"G"                   ; je barva pozad¡ ?
         jb        DispTx32                 ; nen¡ barva pozad¡
         sub       dl,"G"                   ; Ÿ¡slo barvy
         jmp       short DispTx33

DispTx32:cmp       dl,"9"                   ; je Ÿ¡slice ?
         jbe       DispTxt3                 ; je Ÿ¡slice
         sub       dl,7                     ; korekce p¡smene
DispTxt3:and       dl,0fh                   ; po§adovan  barva
         mov       ah,dl                    ; AH <- po§adovan  barva

DispTx33:shl       dl,1
         shl       dl,1
         shl       dl,1
         shl       dl,1                     ; DL <- Ÿ¡slo barvy * 16
         and       ah,0fh                   ; Ÿ¡slo barvy popýed¡
         or        ah,dl                    ; nastaven¡ barvy pozad¡

DispTx34:inc       si                       ; pýeskoŸen¡ znaku

         pop       dx
         jmp       short DispTxt1           ; dalç¡ znak

; ------ zobrazen¡ pozad¡ (je-li pozad¡ a popýed¡ jin‚)

DispTxt4:push      ax
         mov       al,ah
         and       al,0fh                   ; barva popýed¡
         shr       ah,1
         shr       ah,1
         shr       ah,1
         shr       ah,1
         cmp       al,ah                    ; je stejn  barva ?
         je        DispTx42                 ; je stejn  barva

         mov       al,219
         call      DispChr
         dec       bx

DispTx42:pop       ax

; ------ zobrazen¡ znaku

DispTxt7:push      ax
         cld
         lodsb
         and       ah,0fh
         call      DispChr                  ; zobrazen¡ znaku
         pop       ax
         loop      DispTxt1

DispTxt8:pop       si
         pop       cx
         pop       ax
         ret

DispTxt  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku AL, barva AH, linka DX, pozice BX
; -----------------------------------------------------------------------------

DispChr  PROC      NEAR

; ------ kontrola bajtov‚ pozice

         or        bx,bx                    ; prvn¡ pozice nepovolena
         jz        DispCh02                 ; nepovoleno
         cmp       bx,79                    ; maxim ln¡ pozice (bez konce)
         jb        DispChr0                 ; pozice je OK
DispCh02:inc       bx
         ret

; ------ £schova registr…

DispChr0:call      MouseOff                 ; vypnut¡ kurzoru myçi
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

         call      IntMouse                 ; obsluha myçi
         jc        GetMous9                 ; nen¡ zmØna

         test      byte ptr ds:[MouseK],bit2+bit3 ; je stisk tlaŸ¡tka ?
         stc
         jz        GetMous9                 ; nen¡ stisk tlaŸ¡tka

         mov       cx,ds:[MouseX]           ; souýadnice X
         mov       dx,ds:[MouseY]           ; souýadnice Y

         shr       cx,1
         shr       cx,1
         shr       cx,1                     ; bajtov  pozice kurzoru
         dec       cx
         shr       cx,1
         shr       cx,1
         cmp       cx,13h
         jne       GetMous2
         dec       cx
GetMous2:
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
;        obsluha myçi -> CY=§ dn  zmØna
; -----------------------------------------------------------------------------

IntMouse PROC      NEAR

         call      MouseOn                  ; zapnut¡ kurzoru myçi

; ------ £schova registr…

         push      ax
         push      bx
         push      cx
         push      dx

; ------ test, zda je myç nainstalov na

         test      byte ptr ds:[Param],bit1 ; je myç nainstalov na ?
         jz        IntMous8                 ; myç nen¡ nainstalov na

; ------ naŸten¡ aktu ln¡ho stavu myçi

         mov       al,3
         xor       bx,bx                    ; pýednastaven¡ - tlaŸ¡tka
         xor       cx,cx                    ; pýednastaven¡ - sloupec
         xor       dx,dx                    ; pýednastaven¡ - ý dek
         call      Mouse                    ; naŸten¡ stavu myçi

; ------ aktualizace stisku tlaŸ¡tek

         and       bl,bit0+bit1             ; novì stav tlaŸ¡tek
         mov       bh,bl                    ; BH <- £schova nov‚ho stavu
         xchg      bl,ds:[MouseK]           ; ulo§en¡ nov‚ho stavu tlaŸ¡tek
         and       bl,bit0+bit1             ; BL <- starì stav tlaŸ¡tek

; ------ test zmØny tlaŸ¡tek

         mov       al,bh                    ; AL <- novì stav tlaŸ¡tek
         xor       al,bl                    ; AL <- zmØnØn  tlaŸ¡tka
         mov       bl,bh                    ; BL <- novì stav tlaŸ¡tek
         and       bh,al                    ; BH <- novØ stisknut  tlaŸ¡tka
         not       bl                       ; BL <- novì stav uvolnØnìch tlaŸ¡tek
         and       bl,al                    ; BL <- novØ uvolnØn  tlaŸ¡tka
         shl       bx,1
         shl       bx,1
         or        ds:[MouseK],bh           ; stisknut  tlaŸ¡tka
         shl       bl,1
         shl       bl,1
         or        ds:[MouseK],bl           ; uvolnØn  tlaŸ¡tka

; ------ ulo§en¡ novìch souýadnic

         xchg      cx,ds:[MouseX]           ; nov  pozice X
         xchg      dx,ds:[MouseY]           ; nov  pozice Y

; ------ test, zda byl pohyb myç¡ s dr§en¡m

         test      byte ptr ds:[MouseK],bit0+bit1 ; stisknuto tlaŸ¡tko ?
         jz        IntMous7                 ; nen¡ stisknuto tlaŸ¡tko
         cmp       cx,ds:[MouseX]           ; je zmØna X ?
         jne       IntMous6                 ; je zmØna X
         cmp       dx,ds:[MouseY]           ; je zmØna Y ?
         je        IntMous7                 ; nen¡ zmØna Y
IntMous6:or        byte ptr ds:[MouseK],bit7 ; pý¡znak pohyb myçi

; ------ test, zda byla nØjak  zmØna

IntMous7:test      byte ptr ds:[MouseK],bit2+bit3+bit4+bit5+bit7 ; byla zmØna ?
         jnz       IntMous9                 ; byla nØjak  zmØna
IntMous8:stc                                ; pý¡znak, §e nen¡ zmØna

; ------ n vrat registr…

IntMous9:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

IntMouse ENDP

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

         xor       cx,cx                    ; poŸ teŸn¡ pozice
         mov       dx,ds:[DispSirX]         ; ç¡ýka obrazovky
         dec       dx
         mov       al,7
         call      Mouse                    ; horizont ln¡ rozmØry obrazovky
         xor       cx,cx                    ; poŸ teŸn¡ linka
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
;    dek¢dov n¡ Ÿ¡sla AX do bufferu DS:DI (od lev‚ho okraje) -> DI=nov  adresa
; -----------------------------------------------------------------------------

DekNum   PROC      NEAR

; ------ £schova registr…

         push      ax
         push      bx
         push      cx
         push      dx

; ------ pý¡prava registr…

         xor       cx,cx                    ; Ÿ¡taŸ znak… v bufferu
         mov       bx,10                    ; dØlitel Ÿ¡sla

; ------ vìpoŸet Ÿ¡slic

DekNum2: xor       dx,dx                    ; DX <- 0
         div       bx                       ; vìpoŸet jedn‚ Ÿ¡slice
         inc       cx                       ; Ÿ¡taŸ Ÿ¡slic v z sobn¡ku
         push      dx                       ; £schova Ÿ¡slice do z sobn¡ku
         or        ax,ax                    ; bude dalç¡ Ÿ¡slice ?
         jnz       DekNum2                  ; vìpoŸet dalç¡ Ÿ¡slice

; ------ ulo§en¡ Ÿ¡slic do bufferu

DekNum3: pop       ax                       ; AL <- Ÿ¡slice
         add       al,"0"                   ; korekce na ASCII znak
         mov       ds:[di],al               ; ulo§en¡ znaku do bufferu
         inc       di                       ; zvìçen¡ ukl dac¡ adresy
         loop      DekNum3                  ; dalç¡ Ÿ¡slice

; ------ n vrat registr…

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DekNum   ENDP

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
;        vstup znaku z kl vesnice -> AX (CY=nen¡ § dnì znak, AX=0)
; -----------------------------------------------------------------------------

InpChar  PROC      NEAR

         call      MouseOn                  ; zapnut¡ kurzoru myçi

; ------ test, zda je pýipraven znak z kl vesnice

InpChar0:mov       ah,1
         int       16h                      ; test znaku z kl vesnice
         stc                                ; pý¡znak, §e nen¡ § dn  kl vesa
         mov       ax,0                     ; nen¡ kl vesa
         jz        InpChar2                 ; nen¡ § dn  kl vesa

; ------ vstup znaku z kl vesnice

         mov       ah,0
         int       16h                      ; vstup znaku z kl vesnice

; ------ korekce ASCII znak…

         cmp       al,0                     ; je ý¡dic¡ kl vesa ?
         je        InpChar1                 ; je ý¡dic¡ kl vesa
         mov       ah,0                     ; je ASCII kl vesa

; ------ test, zda je pýeruçen¡ programu Ctrl-Break

InpChar1:or        ax,ax                    ; je pýeruçen¡ Ctrl-Break ?
         jnz       InpChar2                 ; nen¡ pýeruçen¡ Ctrl-Break
         or        byte ptr ds:[ParBreak],bit0 ; pý¡znak pýeruçen¡ programu
         jmp       short InpChar0           ; test dalç¡ kl vesy

InpChar2:ret

InpChar  ENDP

; -----------------------------------------------------------------------------
;        nulov n¡ pý¡znaku pýeruçen¡ programu
; -----------------------------------------------------------------------------

NulBreak PROC      NEAR

         and       byte ptr ds:[ParBreak],not bit0 ; nulov n¡ pý¡znaku pýeruçen¡
         ret

NulBreak ENDP

; -----------------------------------------------------------------------------
;        test, zda je pýeruçen¡ programu -> CY=je pýeruçen¡
; -----------------------------------------------------------------------------

TstBreak PROC      NEAR

         sti                                ; pýeruçen¡ mus¡ bìt povoleno
         test      byte ptr ds:[ParBreak],bit0 ; je pýeruçen¡ programu ?
         jz        TstBrea2                 ; nen¡ pýeruçen¡ programu
         stc                                ; pý¡znak pýeruçen¡ programu
TstBrea2:ret

TstBreak ENDP

; -----------------------------------------------------------------------------
;        obsluha kl vesnice INT 09h
; -----------------------------------------------------------------------------

Int09    PROC      FAR

; ------ £schova registr…

         push      bx
         push      ds

; ------ zajiçtØn¡ opakov n¡ kl vesy Insert

         mov       bx,40h                   ; BX <- datovì segment BIOS
         mov       ds,bx                    ; DS <- datovì segment BIOS
         and       byte ptr ds:[18h],not bit7 ; nulov n¡ pý¡znaku kl vesy Insert

; ------ test, zda nastane pýesycen¡ bufferu kl vesnice

         mov       bx,ds:[1ch]              ; BX <- ukl dac¡ adresa do bufferu
         inc       bx
         inc       bx                       ; zvìçen¡ ukl dac¡ adresy
         cmp       bx,3eh                   ; bude pýekroŸen¡ konce bufferu ?
         jb        Int091                   ; nen¡ jeçtØ pýekroŸen konec bufferu
         sub       bx,20h                   ; pýesun ukazatele na zaŸ tek
Int091:  cmp       bx,ds:[1ah]              ; bude pýesycen¡ bufferu ?
         jne       Int094                   ; nebude pýesycen¡ bufferu

; ------ zruçen¡ naposledy pýijat‚ho znaku v bufferu

         mov       bx,ds:[1ch]              ; BX <- ukl dac¡ adresa do bufferu
         dec       bx
         dec       bx                       ; sn¡§en¡ ukl dac¡ adresy
         cmp       bx,1eh                   ; je podteŸen¡ poŸ tku bufferu ?
         jae       Int092                   ; nen¡ podteŸen¡ poŸ tku bufferu
         add       bx,20h                   ; pýesun ukazatele na konec
Int092:  mov       ds:[1ch],bx              ; nov  ukl dac¡ adresa do bufferu

; ------ vol n¡ p…vodn¡ obsluhy INT 09h

Int094:  pushf
         call      dword ptr cs:[Old09]     ; p…vodn¡ obsluha INT 09h

; ------ test, zda je v bufferu nØjakì znak

         mov       bx,ds:[1ch]              ; BX <- ukl dac¡ adresa do bufferu
         cmp       bx,ds:[1ah]              ; je v bufferu nØjakì znak ?
         je        Int098                   ; v bufferu nen¡ § dnì znak

; ------ adresa naposledy ulo§en‚ho znaku -> BX

         dec       bx
         dec       bx                       ; sn¡§en¡ ukl dac¡ adresy
         cmp       bx,1eh                   ; je podteŸen¡ poŸ tku bufferu ?
         jae       Int096                   ; nen¡ podteŸen¡ poŸ tku bufferu
         add       bx,20h                   ; pýesun ukazatele na konec

; ------ test, zda byla kl vesa Ctrl-Break

Int096:  cmp       word ptr ds:[bx],0       ; byla to kl vesa Ctrl-Break ?
         jne       Int098                   ; nebyla to kl vesa Ctrl-Break
         or        byte ptr cs:[ParBreak],bit0 ; pý¡znak pýeruçen¡ programu

; ------ n vrat registr…

Int098:  pop       ds
         pop       bx
         iret

Int09    ENDP

Old09    dd        0                        ; p…vodn¡ obsluha INT 09h
ParBreak db        0                        ; bit 0 = pý¡znak pýeruçen¡ programu

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

         dw        36                       ; to je pro "#" posledn¡ho t¢nu

; -----------------------------------------------------------------------------
;        Ÿek n¡ na impuls hodin s aktualizac¡ zobrazen¡ Petra
; -----------------------------------------------------------------------------

CekKrokD PROC      NEAR

         call      TestBlok                 ; test blokov n¡ programu
         jnz       CekKrkD3                 ; je blokov n¡ pý¡kaz…

         test      byte ptr ds:[Param],bit0 ; je re§im TURBO ?
         jz        CekKrkD2                 ; nen¡ re§im TURBO
         call      MazPet                   ; vymaz n¡ Petra
         jmp       short CekKrok

CekKrkD2:call      DispPet                  ; zobrazen¡ Petra
CekKrkD3:jmp       short CekKrok

CekKrokD ENDP

; -----------------------------------------------------------------------------
;        Ÿek n¡ na jeden impuls hodin (pro jeden krok) -> CY=pýeruçen¡ operace
; -----------------------------------------------------------------------------

CekKrok  PROC      NEAR

         call      TestBlok                 ; test blokov n¡ programu
         jnz       CekKrok8                 ; je blokov n¡ pý¡kaz…

         call      MouseOn                  ; zapnut¡ kurzoru myçi

         call      TstBreak                 ; test pýeruçen¡ z kl vesnice
         jc        CekKrok8                 ; pýeruçen¡ operace

         mov       byte ptr cs:[TimeKrok],1 ; nastaven¡ Ÿ¡taŸe
CekKrok6:sti
         cmp       byte ptr cs:[TimeKrok],0
         jne       CekKrok6
         clc
CekKrok8:ret

CekKrok  ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 1Bh, INT 23h a INT 24h
; -----------------------------------------------------------------------------

INT24    PROC      FAR

         mov       al,0                     ; ignorovat chyby
INT1B:
INT23:   iret

INT24    ENDP

Old1B    dd        0                        ; p…vodn¡ obsluha INT 1Bh

; -----------------------------------------------------------------------------
;        Obsluha Ÿasov n¡ INT 08h
; -----------------------------------------------------------------------------

Int08    PROC      FAR

; ------ Ÿ¡taŸ kroku pohybu Petra

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

Int0832: cmp       word ptr ds:[CitacMel],0 ; je dalç¡ t¢n ?
         je        Int084                   ; nen¡ dalç¡ t¢n
         dec       word ptr ds:[CitacMel]   ; sn¡§en¡ Ÿ¡taŸe melodie

         cld
         mov       si,ds:[UkazMel]          ; ukazatel melodie
         lodsw                              ; naŸten¡ t¢nu a d‚lky
         mov       ds:[UkazMel],si          ; novì ukazatel melodie

         mov       ds:[CitTon],al           ; Ÿ¡taŸ pro vypnut¡ t¢nu
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

Int085:  jmp       dword ptr cs:[Old08]

Int08    ENDP

Old08    dd        0                        ; p…vodn¡ adresa INT 08h
TimeKrok db        0                        ; Ÿ¡taŸ Ÿasu pro jeden krok
                                            ;  (pou§¡v  se t‚§ pro VSYN)
TimeTxt  dw        0                        ; Ÿ¡taŸ pro vypnut¡ textu
CitTon   db        0                        ; Ÿ¡taŸ pro vypnut¡ t¢nu hudby
UkazMel  dw        0                        ; ukazatel melodie
                                            ; melodie: 1 bajt d‚lka
                                            ;          1 bajt t¢n, 0=mezera
CitacMel dw        0                        ; Ÿ¡taŸ zbyl‚ melodie (0=nen¡)
BuffMel  dw        256 dup(0)               ; buffer melodie pro u§ivatele

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

UvTxt    db        'Petr V1.0; (c) Miroslav Nemecek 1997',13,10,'$'
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

; ------ polo§en¡ pýedmØtu na okraj

OkrajTxt db        39,'  ****  NEMOHU - JE TAM OKRAJ !  ****  '
OkrajTon db        M32,MG+MO4
         db        M32,ME+MO4
         db        M32,MC+MO4
         db        M32,MG+MO3
         db        M32,ME+MO3

; ------ k¢dy kl ves (zaŸ¡naj¡ textem "K_")

KodKlav  label     byte
         db        3,'ESC'
         dw        1bh
         db        2,'BS'
         dw        8
         db        9,'BACKSPACE'
         dw        8
         db        7,'CTRL_BS'
         dw        7fh
         db        14,'CTRL_BACKSPACE'
         dw        7fh
         db        3,'TAB'
         dw        9
         db        9,'SHIFT_TAB'
         dw        0f00h
         db        5,'ENTER'
         dw        0dh
         db        10,'CTRL_ENTER'
         dw        0ah
         db        5,'SPACE'
         dw        " "
         db        6,'MEZERA'
         dw        " "
         db        2,'F1'
         dw        3b00h
         db        2,'F2'
         dw        3c00h
         db        2,'F3'
         dw        3d00h
         db        2,'F4'
         dw        3e00h
         db        2,'F5'
         dw        3f00h
         db        2,'F6'
         dw        4000h
         db        2,'F7'
         dw        4100h
         db        2,'F8'
         dw        4200h
         db        2,'F9'
         dw        4300h
         db        3,'F10'
         dw        4400h
         db        8,'SHIFT_F1'
         dw        5400h
         db        8,'SHIFT_F2'
         dw        5500h
         db        8,'SHIFT_F3'
         dw        5600h
         db        8,'SHIFT_F4'
         dw        5700h
         db        8,'SHIFT_F5'
         dw        5800h
         db        8,'SHIFT_F6'
         dw        5900h
         db        8,'SHIFT_F7'
         dw        5a00h
         db        8,'SHIFT_F8'
         dw        5b00h
         db        8,'SHIFT_F9'
         dw        5c00h
         db        9,'SHIFT_F10'
         dw        5d00h
         db        7,'CTRL_F1'
         dw        5e00h
         db        7,'CTRL_F2'
         dw        5f00h
         db        7,'CTRL_F3'
         dw        6000h
         db        7,'CTRL_F4'
         dw        6100h
         db        7,'CTRL_F5'
         dw        6200h
         db        7,'CTRL_F6'
         dw        6300h
         db        7,'CTRL_F7'
         dw        6400h
         db        7,'CTRL_F8'
         dw        6500h
         db        7,'CTRL_F9'
         dw        6600h
         db        8,'CTRL_F10'
         dw        6700h
         db        6,'ALT_F1'
         dw        6800h
         db        6,'ALT_F2'
         dw        6900h
         db        6,'ALT_F3'
         dw        6a00h
         db        6,'ALT_F4'
         dw        6b00h
         db        6,'ALT_F5'
         dw        6c00h
         db        6,'ALT_F6'
         dw        6d00h
         db        6,'ALT_F7'
         dw        6e00h
         db        6,'ALT_F8'
         dw        6f00h
         db        6,'ALT_F9'
         dw        7000h
         db        7,'ALT_F10'
         dw        7100h
         db        4,'HOME'
         dw        4700h
         db        9,'CTRL_HOME'
         dw        7700h
         db        2,'UP'
         dw        4800h
         db        6,'NAHORU'
         dw        4800h
         db        6,'PAGEUP'
         dw        4900h
         db        11,'CTRL_PAGEUP'
         dw        8400h
         db        4,'LEFT'
         dw        4b00h
         db        5,'VLEVO'
         dw        4b00h
         db        9,'CTRL_LEFT'
         dw        7300h
         db        10,'CTRL_VLEVO'
         dw        7300h
         db        5,'RIGHT'
         dw        4d00h
         db        6,'VPRAVO'
         dw        4d00h
         db        10,'CTRL_RIGHT'
         dw        7400h
         db        11,'CTRL_VPRAVO'
         dw        7400h
         db        3,'END'
         dw        4f00h
         db        8,'CTRL_END'
         dw        7500h
         db        4,'DOWN'
         dw        5000h
         db        4,'DOLU'
         dw        5000h
         db        8,'PAGEDOWN'
         dw        5100h
         db        13,'CTRL_PAGEDOWN'
         dw        7600h
         db        6,'INSERT'
         dw        5200h
         db        6,'DELETE'
         dw        5300h
         db        5,'ALT_Q'
         dw        1000h
         db        5,'ALT_W'
         dw        1100h
         db        5,'ALT_E'
         dw        1200h
         db        5,'ALT_R'
         dw        1300h
         db        5,'ALT_T'
         dw        1400h
         db        5,'ALT_Y'
         dw        1500h
         db        5,'ALT_U'
         dw        1600h
         db        5,'ALT_I'
         dw        1700h
         db        5,'ALT_O'
         dw        1800h
         db        5,'ALT_P'
         dw        1900h
         db        5,'ALT_A'
         dw        1e00h
         db        5,'ALT_S'
         dw        1f00h
         db        5,'ALT_D'
         dw        2000h
         db        5,'ALT_F'
         dw        2100h
         db        5,'ALT_G'
         dw        2200h
         db        5,'ALT_H'
         dw        2300h
         db        5,'ALT_J'
         dw        2400h
         db        5,'ALT_K'
         dw        2500h
         db        5,'ALT_L'
         dw        2600h
         db        5,'ALT_Z'
         dw        2c00h
         db        5,'ALT_X'
         dw        2d00h
         db        5,'ALT_C'
         dw        2e00h
         db        5,'ALT_V'
         dw        2f00h
         db        5,'ALT_B'
         dw        3000h
         db        5,'ALT_N'
         dw        3100h
         db        5,'ALT_M'
         dw        3200h
         db        6,'CTRL_A'
         dw        1
         db        6,'CTRL_B'
         dw        2
         db        6,'CTRL_C'
         dw        3
         db        6,'CTRL_D'
         dw        4
         db        6,'CTRL_E'
         dw        5
         db        6,'CTRL_F'
         dw        6
         db        6,'CTRL_G'
         dw        7
         db        6,'CTRL_H'
         dw        8
         db        6,'CTRL_I'
         dw        9
         db        6,'CTRL_J'
         dw        10
         db        6,'CTRL_K'
         dw        11
         db        6,'CTRL_L'
         dw        12
         db        6,'CTRL_M'
         dw        13
         db        6,'CTRL_N'
         dw        14
         db        6,'CTRL_O'
         dw        15
         db        6,'CTRL_P'
         dw        16
         db        6,'CTRL_Q'
         dw        17
         db        6,'CTRL_R'
         dw        18
         db        6,'CTRL_S'
         dw        19
         db        6,'CTRL_T'
         dw        20
         db        6,'CTRL_U'
         dw        21
         db        6,'CTRL_V'
         dw        22
         db        6,'CTRL_W'
         dw        23
         db        6,'CTRL_X'
         dw        24
         db        6,'CTRL_Y'
         dw        25
         db        6,'CTRL_Z'
         dw        26
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
         db        7,'MNU_NIC'              ; plocha menu
ICOMenu  dw        0
         db        7,'PETRIKP'              ; Petý¡k zepýedu
ICOPetP  dw        0
         db        7,'PETRIKZ'              ; Petý¡k zezadu
ICOPetZ  dw        0
         db        7,'PETRIKL'              ; Petý¡k zleva
ICOPetL  dw        0
         db        7,'PETRIKR'              ; Petý¡k zprava
ICOPetR  dw        0
         db        3,'ZED'                  ; zeÔ
ICOZed   dw        0
         db        8,'MNU_VLEV'             ; ikona vlevo
ICOVlevo dw        0
         db        8,'MNU_PRAV'             ; ikona vpravo
ICOVprav dw        0
         db        8,'MNU_VZAD'             ; ikona vzad
ICOVzad  dw        0
         db        8,'MNU_KROK'             ; ikona kroku
ICOKrok  dw        0
         db        7,'MNU_KON'               ; konec programu
ICOKonec dw        0
;         db        4,'DISK'                 ; disketa - souborov‚ funkce
;ICODisk  dw        0
         db        7,'MNU_MAL'              ; ikona menu pro malov n¡
ICOMaluj dw        0
         db        8,'MNU_IKON'             ; volba ikon
ICOIkony dw        0
         db        8,'MNU_STRT'             ; start programu
ICOStart dw        0
         db        8,'RAM_BAR1'             ; volba barvy 1
ICOBarv1 dw        0
         db        8,'RAM_BAR2'             ; volba barvy 2
ICOBarv2 dw        0
         db        8,'RAM_BAR3'             ; volba barvy 3
ICOBarv3 dw        0
         db        8,'RAM_BAR4'             ; volba barvy 4
ICOBarv4 dw        0
         db        8,'RAM_BAR5'             ; volba barvy 5
ICOBarv5 dw        0
         db        8,'RAM_BAR6'             ; volba barvy 6
ICOBarv6 dw        0
         db        8,'MNU_PERO'             ; pero
ICOPero  dw        0
         db        8,'MNU_CTVE'             ; Ÿtverec
ICOCtve  dw        0
         db        8,'MNU_KRUH'             ; kruh
ICOKruh  dw        0
         db        8,'MNU_BLOK'             ; blok
ICOBlok  dw        0
;         db        8,'MNU_BLOS'             ; blok SAVE
;ICOBlokS dw        0
         db        8,'MNU_BLOL'             ; blok LOAD
ICOBlokL dw        0
         db        8,'MNU_CARA'             ; Ÿ ra
ICOCara  dw        0
         db        8,'MNU_UNDO'             ; UNDO
ICOUndo  dw        0
         db        8,'MNU_REDO'             ; REDO
ICORedo  dw        0
         db        8,'MNU_FILL'             ; vìplå
ICOFill  dw        0
         db        8,'MNU_FLIP'             ; pýevr cen¡
ICOFlip  dw        0
         db        7,'MNU_ROT'              ; rotace
ICORot   dw        0
         db        8,'MNU_XCOL'             ; z mØna barev
ICOXCol  dw        0
         db        8,'MNU_SAVE'             ; save
ICOSave  dw        0
;         db        8,'MNU_LOAD'             ; load
;ICOLoad  dw        0

ICODef0  label     byte

ICOLast  dw        0                        ; naposledy zvolen  ikona

; ------ pý¡kazy

Prikazy  label     byte
         db        1,' '                    ; 1: kreslen¡ obr zku
         db        6,'OPAKUJ'               ; 2: OPAKUJ
         db        1,'('                    ; 3: lev  z vorka
         db        1,')'                    ; 4: prav  z vorka
         db        1,'!'                    ; 5: definice/proveden¡ pý¡kazu
         db        1,','                    ; 6: Ÿ rka
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
         db        5,'MASKA'                ; 23: MASKA
         db        4,'VSYN'                 ; 24: VSYN
         db        1,'#'                    ; 25: PROMENNA
         db        1,' '                    ; 26: CISLO
         db        1,'='                    ; 27: ROVNITKO
         db        1,'+'                    ; 28: PLUS
         db        1,'-'                    ; 29: MINUS
         db        1,'*'                    ; 30: KRAT
         db        1,'/'                    ; 31: DELENO
         db        1,'<'                    ; 32: MENSI
         db        1,'>'                    ; 33: VETSI
         db        6,'NAHODA'               ; 34: NAHODA
         db        6,'VEKTOR'               ; 35: VEKTOR
         db        6,'MISTNI'               ; 36: MISTNI
         db        1,'A'                    ; 37: A
         db        4,'NEBO'                 ; 38: NEBO
         db        7,'POZICEX'              ; 39: POZICEX
         db        7,'POZICEY'              ; 40: POZICEY
         db        7,'KLAVESA'              ; 41: KLAVESA
         db        5,'OBNOV'                ; 42: OBNOV
         db        4,'SMER'                 ; 43: SMER
         db        7,'HLASENI'              ; 44: HLASENI
         db        7,'PREDMET'              ; 45: PREDMET
         db        4,'TEXT'                 ; 46: TEXT
         db        4,'POLE'                 ; 47: POLE
         db        3,'MOD'                  ; 48: MOD
         db        5,'HUDBA'                ; 49: HUDBA
Prikazy0 db        0

Prikazy2 label     byte
         db        1,' '                    ; 1: kreslen¡ obr zku
         db        1,'@'                    ; 2: OPAKUJ
         db        1,'('                    ; 3: lev  z vorka
         db        1,')'                    ; 4: prav  z vorka
         db        1,'!'                    ; 5: definice/proveden¡ pý¡kazu
         db        1,','                    ; 6: Ÿ rka
         db        1,'K'                    ; 7: KROK
         db        1,'L'                    ; 8: VLEVO
         db        1,'P'                    ; 9: VPRAVO
         db        1,'V'                    ; 10: VZAD
         db        1,'C'                    ; 11: CEKEJ
         db        1,'R'                    ; 12: RYCHLE
         db        1,'U'                    ; 13: POMALU
         db        2,'SS'                   ; 14: SEVER
         db        2,'SJ'                   ; 15: JIH
         db        2,'SV'                   ; 16: VYCHOD
         db        2,'SZ'                   ; 17: ZAPAD
         db        1,'J'                    ; 18: JESTLI
         db        1,'I'                    ; 19: JINAK
         db        1,'~'                    ; 20: NENI
         db        1,'B'                    ; 21: PRERUS
         db        1,'D'                    ; 22: DOKUD
         db        1,'M'                    ; 23: MASKA
         db        1,' '                    ; 24: VSYN
         db        1,'#'                    ; 25: PROMENNA
         db        1,' '                    ; 26: CISLO
         db        1,'='                    ; 27: ROVNITKO
         db        1,'+'                    ; 28: PLUS
         db        1,'-'                    ; 29: MINUS
         db        1,'*'                    ; 30: KRAT
         db        1,'/'                    ; 31: DELENO
         db        1,'<'                    ; 32: MENSI
         db        1,'>'                    ; 33: VETSI
         db        1,' '                    ; 34: NAHODA
         db        1,'^'                    ; 35: VEKTOR
         db        1,'$'                    ; 36: MISTNI
         db        1,'&'                    ; 37: A
         db        1,'|'                    ; 38: NEBO
         db        1,'X'                    ; 39: POZICEX
         db        1,'Y'                    ; 40: POZICEY
         db        1,' '                    ; 41: KLAVESA
         db        1,' '                    ; 42: OBNOV
         db        1,' '                    ; 43: SMER
         db        1,' '                    ; 44: HLASENI
         db        1,' '                    ; 45: PREDMET
         db        1,' '                    ; 46: TEXT
         db        1,' '                    ; 47: POLE
         db        1,' '                    ; 48: MOD
         db        1,' '                    ; 49: HUDBA
         db        0

; ------ obsluha pý¡kaz… pýi prov dØn¡ programu

PrikazX  label     word
         dw        PetKresl                 ; 1: kreslen¡ obr zku
         dw        PetOpak                  ; 2: OPAKUJ
         dw        PetLZav                  ; 3: lev  z vorka
         dw        PetNop                   ; 4: prav  z vorka
         dw        PetProc                  ; 5: definice/proveden¡ pý¡kazu
         dw        PetNop                   ; 6: Ÿ rka
         dw        PetKrok                  ; 7: KROK
         dw        PetVlevo                 ; 8: VLEVO
         dw        PetVprav                 ; 9: VPRAVO
         dw        PetVzad                  ; 10: VZAD
         dw        CekKrokD                 ; 11: CEKEJ
         dw        PetRych                  ; 12: RYCHLE
         dw        PetPom                   ; 13: POMALU
         dw        PetSev                   ; 14: SEVER
         dw        PetJih                   ; 15: JIH
         dw        PetVych                  ; 16: VYCHOD
         dw        PetZap                   ; 17: ZAPAD
         dw        PetJest                  ; 18: JESTLI
         dw        PetNop                   ; 19: JINAK
         dw        PetNop                   ; 20: NENI
         dw        PetPrer                  ; 21: PRERUS
         dw        PetDok                   ; 22: DOKUD
         dw        PetMask                  ; 23: MASKA
         dw        PetVSyn                  ; 24: VSYN
         dw        PetProm                  ; 25: PROMENNA
         dw        PetCisl                  ; 26: CISLO
         dw        PetNop                   ; 27: ROVNITKO
         dw        PetNop                   ; 28: PLUS
         dw        PetNop                   ; 29: MINUS
         dw        PetNop                   ; 30: KRAT
         dw        PetNop                   ; 31: DELENO
         dw        PetNop                   ; 32: MENSI
         dw        PetNop                   ; 33: VETSI
         dw        PetNop                   ; 34: NAHODA
         dw        PetVekt                  ; 35: VEKTOR
         dw        PetMist                  ; 36: MISTNI
         dw        PetNop                   ; 37: A
         dw        PetNop                   ; 38: NEBO
         dw        PetPozX                  ; 39: POZICEX
         dw        PetPozY                  ; 40: POZICEY
         dw        PetKlav                  ; 41: KLAVESA
         dw        PetObn                   ; 42: OBNOV
         dw        PetSmer                  ; 43: SMER
         dw        PetHlas                  ; 44: HLASENI
         dw        PetNPre                  ; 45: PREDMET
         dw        PetText                  ; 46: TEXT
         dw        PetPole                  ; 47: POLE
         dw        PetNop                   ; 48: MOD
         dw        PetMus                   ; 49: HUDBA

; ------ pracovn¡ ukazatele

Pole     dw        PSIRKA*PVYSKA dup(0)     ; hrac¡ pole (obsahuje adresy ikon)

TextRad  db        -1                       ; ukazatel ý dku textu (-1=neplatnì)
PetrOPz  dw        0                        ; star  zobrazen  pozice Petra
PetrPoz  dw        0                        ; aktu ln¡ ý dek a pozice Petra
PetrOSm  db        2                        ; starì smØr Petra
PetrSme  db        2                        ; smØr Petra
                                            ;  1 = vpravo (vìchod)
                                            ;  2 = dol… (jih)
                                            ;  3 = vlevo (z pad)
                                            ;  4 = nahoru (sever)

RandomR  dd        21510d31h                ; promØnn  pro gener tor n hody
RandomD  dw        8405h                    ; pomocn  konstanta

Param    db        0                        ; parametry
                                            ;   bit 0: 1=je TURBO re§im
                                            ;   bit 1: 1=je myç
                                            ;   bit 2: 1=kurzor myçi zapnut
                                            ;   bit 3: 1=Petr je zobrazen
                                            ;   bit 4: 1=je pýeruçen¡ cyklu
                                            ;   bit 5: 1=kurzor volby zapnut

                                            ;   bit 7:

Rezim    db        0                        ; aktu ln¡ re§im
                                            ;    0 = inicializace
                                            ;    1 = bØh programu
                                            ;    2 = z kladn¡ ovl d n¡
                                            ;    3 = volba ikon
                                            ;    4 = editace ikon

FunkceEd db        0                        ; funkce pýi editaci
                                            ;    0: pero
                                            ;    1: Ÿ ra
                                            ;    2: Ÿtverece
                                            ;    3: kruh
                                            ;    4: naplnØn¡
                                            ;    5: blok
                                            ;    6: je oznaŸen blok

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

EditIcoC dw        0                        ; Ÿ¡slo editovan‚ ikony

MinHICO  dw        0                        ; adresa minim ln¡ ikony v historii
BegHICO  dw        0                        ; adresa prvn¡ ikony v historii
AktHICO  dw        0                        ; aktu ln¡ ikona v historii

MousZPoz dw        -1                       ; zobrazen  pozice myçi pýi editaci

MouseX   dw        0                        ; bitov  souýadnice kurzoru myçi X
MouseY   dw        0                        ; bitov  souýadnice kurzoru myçi Y
MouseK   db        0                        ; tlaŸ¡tka myçi
                                            ;   bit 0: 1=dr§eno lev‚ tlaŸ¡tko
                                            ;   bit 1: 1=dr§eno prav‚ tlaŸ¡tko
                                            ;   bit 2: 1=lev‚ tlaŸ¡tko stisknuto
                                            ;   bit 3: 1=prav‚ tlaŸ¡tko stisknuto
                                            ;   bit 4: 1=lev‚ tlaŸ¡tko uvolnØno
                                            ;   bit 5: 1=prav‚ tlaŸ¡tko uvolnØno
                                            ;   bit 6:
                                            ;   bit 7: 1=pohyb s myç¡ s dr§en¡m

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
; Na zaŸ tku programu jsou definice promØnnìch:
;       (1) d‚lka jm‚na promØnn‚
;       (x) jm‚no promØnn‚
;       (2) promØnn 
; Za definicemi Ÿ¡sel jsou definice procedur:
;       (2) adresa dalç¡ procedury v bufferu
;       (1) d‚lka jm‚na procedury
;       (x) jm‚no procedury
;       (...) pý¡kaz nebo v¡ce pý¡kaz… v z vorce
; -----------------------------------------------------------------------------
; Pýi prov dØn¡ programu je mezi koncem programu a zaŸ tkem symbol… buffer
; n vratovìch adres cykl… OPAKUJ a DOKUD
; -----------------------------------------------------------------------------

DataVekt dw        0                        ; adresa vektoru
DataSegm dw        0                        ; adresa zaŸ tku datov‚ho segmentu
DataEnd  dw        0                        ; adresa konce datov‚ho segmentu
DataProg dw        0                        ; adresa zaŸ tku programu (segment)
UkazProg dw        0                        ; ukazatel zpracov n¡ programu (offset)
DataNum  dw        0                        ; poŸet bajt… programu v bufferu
MainProg dw        0                        ; offset hlavn¡ho programu
ProcBeg  dw        0                        ; offset zaŸ tku procedur
ProcNum  dw        0                        ; poŸet procedur v programu
PromNum  dw        0                        ; poŸet promØnnìch v programu
DataICOE dw        0                        ; konec symbol… ikon (offset)
DataICO  dw        0                        ; adresa zaŸ tku bufferu ikon (segment)
                                            ;  (posouv  se shora dol…, ikony
                                            ;   se ukl daj¡ shora dol…)
DataICON dw        0                        ; poŸet ikon v segmentu
                                            ;  (640 B na ikonu)

DataStru dw        0                        ; adresa bufferu struktur

ICOAll   db        'ICO\*.ICO',0            ; hled n¡ vçech ikon
DTA      db        44 dup(0)                ; buffer DTA souboru

CitChyb  dw        0                        ; Ÿ¡taŸ chyb pýekladu

VnorIf   dw        0                        ; Ÿ¡taŸ vnoýen¡ IF pro blokov n¡
VnorCas  dw        0                        ; Ÿ¡taŸ vnoýen¡ CASE pro blokov n¡
VnorFor  dw        0                        ; Ÿ¡taŸ vnoýen¡ FOR pro blokov n¡
VnorPrik dw        0                        ; Ÿ¡taŸ vnoýen¡ z vorek pro 1 pý¡kaz

VolILast dw        0                        ; ukazatel pýi volbØ ikon

EdiIHist dw        HistEdiM dup(0)          ; historie editovanìch ikon

EdiIHAkt dw        0                        ; aktu ln¡ ikona v historii

ColLeft  db        0                        ; barva pro lev‚ tlaŸ¡tko
ColRight db        8                        ; barva pro prav‚ tlaŸ¡tko

EdiBegPz dw        0                        ; pozice poŸ tku operace
EdiOldPz dw        0                        ; uschovan  pozice kurzoru

BlokBuff db        32*32 dup(0)             ; buffer k ulo§en¡ bloku v editoru
BlokPoz  dw        0                        ; souýadnice poŸ tku bloku
BlokSize dw        0                        ; velikost bloku (0=nen¡ blok)
BlokSiz2 dw        0                        ; uschovan  velikost bloku

; -----------------------------------------------------------------------------
;        vzor z hlav¡ pro z pis ikony
; -----------------------------------------------------------------------------

VzorICO  label     byte
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

         db          0,  0,  0,  0          ;  0: Ÿern 
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

; nemØnit poýad¡ - pou§¡v  se spolu !!!
JmenoICO db        'ICO'                    ; pýipravenì odkaz do adres ýe ICO
ProgStr  db        0,255 dup(0)             ; buffer ýetØzce programu + d‚lka
                                            ;  (pou§¡v  se t‚§ pro zobrazen¡
                                            ;   textu pýi volbØ ikony a
                                            ;   v programu - pý¡kaz "Hlaseni")
ProgFile db        'PROGRAM.PRG',0          ; program
ProgIdnt dw        0                        ; identifik tor vstupn¡ho souboru
InpRead  dw        0                        ; offset ve Ÿtec¡m bufferu
InpNum   dw        0                        ; poŸet bajt… v bufferu
InpBuff  db        BUFFSIZE dup(0)          ; vstupn¡ buffer programu
InpRetB  db        0,0                      ; navr cenì znak do bufferu (0=nen¡)

Zasob0   label     word                     ; spodn¡ hranice z sobn¡ku
         dw        4096 dup(0)              ; pracovn¡ z sobn¡k
Zasob    label     word                     ; konec z sobn¡ku


Code     ENDS
         END       Start

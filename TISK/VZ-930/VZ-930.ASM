
; *****************************************************************************
;
;                           Ovlada‡ zapisova‡e VZ-930
;
; ------------------ V cel‚m programu se dodr‘uje DS=ES=CS !!! ---------------
;
; *****************************************************************************

GLOBAL   STOP

PRIJEMOK EQU       1                        ; hl ¨en¡ o p©ipravenosti
CEKEJ    EQU       2                        ; hl ¨en¡ o zanepr zdnˆnosti
VYZVA    EQU       3                        ; znak v˜zvy o hl ¨en¡ stavu
PRIJCHYB EQU       4                        ; hl ¨en¡ o chybˆ p©¡jmu
ZNAKSYN  EQU       16h                      ; synchroniza‡n¡ znak
ZNAKEOT  EQU       0dh                      ; znak konce textu zpr vu

NRADIX   EQU       64                       ; z klad ‡¡seln‚ soustavy
PAKSIZE  EQU       120                      ; velikost paketu (bez CRC)

BuffSize EQU       1000h                    ; vstupn¡ buffer

bit0     EQU       1
bit1     EQU       2
bit2     EQU       4
bit3     EQU       8
bit4     EQU       10h
bit5     EQU       20h
bit6     EQU       40h
bit7     EQU       80h

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ £vodn¡ text

Start:   mov       si,offset UvTxt
         call      DispTxt

; ------ dek¢dov n¡ parametr– p©¡kazov‚ho © dku (mus¡ b˜t ES=DS=CS)

         call      DekParm                  ; dek¢dov n¡ zad n¡ parametr–
         jnc       Start1                   ; operace OK

; ------ chyba

         mov       si,offset HelpTxt        ; text n povˆdy
Chyba:   call      DispTxt                  ; zobrazen¡ textu n povˆdy
Chyba0:  mov       ax,4c01h
         int       21h

; ------ test, zda je port COM platn˜

Start1:  mov       bx,ds:[Kanal]            ; ‡¡slo v˜stupn¡ho kan lu
         shl       bx,1                     ; ‡¡slo kan lu * 2
         push      ds
         xor       ax,ax
         mov       ds,ax                    ; ES <- 0
         cmp       word ptr ds:[bx+400h],0  ; je kan l COM platn˜ ?
         pop       ds
         mov       si,offset ComTxt         ; text - kan l nenalezen
         je        Chyba                    ; chyba - COM nenalezen

; ------ otev©en¡ souboru pro ‡ten¡

         mov       dx,offset Soubor         ; jm‚no souboru
         mov       ax,3d00h
         int       21h                      ; otev©en¡ souboru pro ‡ten¡
         mov       si,offset FndTxt         ; text - chyba zad n¡
         jc        Chyba                    ; soubor nenalezen
         mov       ds:[SoubIdnt],ax         ; identifik tor souboru

; ------ inicializace portu COM

         mov       ax,7*bit5 + 3*bit3 + 0*bit2 + 2*bit0 ; nastaven¡ portu COM
         call      Int14                    ; nastaven¡ portu COM

; ------ vypr zdnˆn¡ znaku ze vstupu COM

         call      InpFlush                 ; vypr zdnˆn¡ vstupu INT 14h

; ------ vysl n¡ inicializa‡n¡ho paketu

         call      NulPaket                 ; nulov n¡ paketu
         mov       di,offset InitPak        ; inicializa‡n¡ data paketu
         call      OutPovel                 ; z pis povelu
         call      PenUp                    ; zvednut¡ pera
         call      FlshPakt                 ; vysl n¡ paketu

         mov       di,offset InitPak        ; inicializa‡n¡ data paketu
         call      OutPovel                 ; z pis povelu
         call      PenUp                    ; zvednut¡ pera
         call      FlshPakt                 ; vysl n¡ paketu

; ------ dek¢dov n¡ souboru

         mov       si,offset Buffer         ; ukazatel vstupn¡ch dat
         call      DekVZ                    ; dek¢dov n¡ souboru

; ------ vypr zdnˆn¡ paketu

         call      DekVZU                   ; z vˆre‡n‚ zvednut¡ pera
         call      FlshPakt                 ; vypr zdnˆn¡ paketu

; ------ uzav©en¡ vstupn¡ho souboru

         mov       bx,ds:[SoubIdnt]         ; identifik tor vstupn¡ho souboru
         mov       ah,3eh
         int       21h                      ; uzav©en¡ vstupn¡ho souboru

; ------ konec programu

         mov       ax,4c00h
         int       21h

; *****************************************************************************
;
;                                R–zn‚
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;                   Vyn soben¡ dvou dvouslov se znam‚nkem
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=prvn¡ operand
;        BX:CX=druh˜ operand
; VSTUP: DX:AX=v˜sledek (nekontroluje se p©ete‡en¡)
; -----------------------------------------------------------------------------

MulSDWrd PROC      NEAR

; ------ £schova registr–

         push      bx
         push      cx

; ------ test, zda je druh˜ operand z porn˜

         or        bx,bx                    ; je druh˜ operand z porn˜ ?
         jns       MulSDWr3                 ; druh˜ operand nen¡ z porn˜

; ------ negace druh‚ho operandu

         not       bx
         not       cx
         add       cx,1
         adc       bx,0

; ------ test, zda je prvn¡ operand z porn˜

         or        dx,dx                    ; je prvn¡ operand z porn˜ ?
         jns       MulSDWr6                 ; 1.operand kladn˜-v˜sledek z porn˜
         call      NegNum                   ; negace prvn¡ho operandu
         jmp       short MulSDWr7           ; v˜sledek bude kladn˜

; ------ druh˜ operand kladn˜ - test, zda je prvn¡ operand kladn˜

MulSDWr3:or        dx,dx                    ; je prvn¡ operand z porn˜ ?
         jns       MulSDWr7                 ; 1.operand kladn˜ - v˜sledek kladn˜
         call      NegNum                   ; negace prvn¡ho operandu

; ------ v˜sledek bude z porn˜

MulSDWr6:call      MulDWrd                  ; vyn soben¡ ‡¡sel
         call      NegNum                   ; negace v˜sledku
         jmp       short MulSDWr8

; ------ v˜sledek bude kladn˜

MulSDWr7:call      MulDWrd                  ; vyn soben¡ ‡¡sel

; ------ n vrat registr–

MulSDWr8:pop       cx
         pop       bx
         ret

MulSDWrd ENDP

; -----------------------------------------------------------------------------
;                   Vydˆlen¡ dvou dvouslov se znam‚nkem
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=prvn¡ operand
;        BX:CX=druh˜ operand
; VSTUP: DX:AX=v˜sledek (nekontroluje se p©ete‡en¡, pouze 0 v dˆliteli)
; -----------------------------------------------------------------------------

DivSDWrd PROC      NEAR

; ------ £schova registr–

         push      bx
         push      cx

; ------ test, zda je druh˜ operand z porn˜

         or        bx,bx                    ; je druh˜ operand z porn˜ ?
         jns       DivSDWr3                 ; druh˜ operand nen¡ z porn˜

; ------ negace druh‚ho operandu

         not       bx
         not       cx
         add       cx,1
         adc       bx,0

; ------ test, zda je prvn¡ operand z porn˜

         or        dx,dx                    ; je prvn¡ operand z porn˜ ?
         jns       DivSDWr6                 ; 1.operand kladn˜-v˜sledek z porn˜
         call      NegNum                   ; negace prvn¡ho operandu
         jmp       short DivSDWr7           ; v˜sledek bude kladn˜

; ------ druh˜ operand kladn˜ - test, zda je prvn¡ operand kladn˜

DivSDWr3:or        dx,dx                    ; je prvn¡ operand z porn˜ ?
         jns       DivSDWr7                 ; 1.operand kladn˜ - v˜sledek kladn˜
         call      NegNum                   ; negace prvn¡ho operandu

; ------ v˜sledek bude z porn˜

DivSDWr6:call      DivDWrd                  ; vyndˆlen¡ ‡¡sel
         call      NegNum                   ; negace v˜sledku
         jmp       short DivSDWr8

; ------ v˜sledek bude kladn˜

DivSDWr7:call      DivDWrd                  ; vydˆlen¡ ‡¡sel

; ------ n vrat registr–

DivSDWr8:pop       cx
         pop       bx
         ret

DivSDWrd ENDP

; -----------------------------------------------------------------------------
;                     Vyn soben¡ dvou dvojslov bez znam‚nka
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=prvn¡ operand
;        BX:CX=druh˜ operand
; VSTUP: DX:AX=v˜sledek (nekontroluje se p©ete‡en¡)
; -----------------------------------------------------------------------------

MulDWrd  PROC      NEAR

; ------ £schova registr–

         push      bx
         push      si

; ------ vyn soben¡ HIGH1*LOW2

         xchg      ax,si                    ; SI <- LOW1
         xchg      ax,dx                    ; AX <- HIGH1
         mul       cx                       ; vyn soben¡ HIGH1*LOW2

; ------ vyn soben¡ LOW1*HIGH2

         xchg      ax,bx                    ; BX <- nov‚ HIGH, AX <- HIGH2
         mul       si                       ; vyn soben¡ HIGH2*LOW1
         add       bx,ax                    ; BX <- nov‚ HIGH

; ------ vyn soben¡ LOW1*LOW2

         xchg      ax,si                    ; AX <- LOW1
         mul       cx                       ; vyn soben¡ LOW1*LOW2
         add       dx,bx                    ; DX <- nov‚ HIGH

; ------ n vrat registr–

         pop       si
         pop       bx
         ret

MulDWrd  ENDP

; -----------------------------------------------------------------------------
;                  Vydˆlen¡ dvou dvouslov bez znam‚nka
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=prvn¡ operand
;        BX:CX=druh˜ operand
; VSTUP: DX:AX=v˜sledek (nekontroluje se p©ete‡en¡, pouze 0 v dˆliteli)
; -----------------------------------------------------------------------------

DivDWrd  PROC      NEAR

; ------ £schova registr–

         push      bx
         push      cx

; ------ test, zda je dˆlitel > slovo

DivDWrd2:or        bx,bx                    ; je dˆlitel vˆt¨¡ ne‘ slovo ?
         jz        DivDWrd4                 ; dˆlitel je OK

; ------ normalizace operand–

         shr       dx,1
         rcr       ax,1
         shr       bx,1
         rcr       cx,1
         jmp       short DivDWrd2

; ------ vydˆlen¡ operand–

DivDWrd4:call      DivWord                  ; vydˆlen¡ operand–

; ------ n vrat registr–

         pop       cx
         pop       bx
         ret

DivDWrd  ENDP

; -----------------------------------------------------------------------------
;        vyn soben¡ dvojslova DX:AX slovem CX -> DX:AX
; -----------------------------------------------------------------------------

MulWord  PROC      NEAR

; ------ £schova registr–

         push      bx

; ------ vyn soben¡ HIGH1*LOW2

         xchg      ax,bx                    ; BX <- LOW1
         xchg      ax,dx                    ; AX <- HIGH1
         mul       cx                       ; vyn soben¡ HIGH1*LOW2

; ------ vyn soben¡ LOW1*LOW2

         xchg      ax,bx                    ; AX <- LOW1, BX <- nov‚ HIGH
         mul       cx                       ; vyn soben¡ LOW1*LOW2
         add       dx,bx                    ; DX <- nov‚ HIGH

; ------ n vrat registr–

         pop       bx
         ret

MulWord  ENDP

; -----------------------------------------------------------------------------
;        vydˆlen¡ dvojslova DX:AX slovem CX -> DX:AX
; -----------------------------------------------------------------------------

DivWord  PROC      NEAR

; ------ £schova registr–

         push      bx
         jcxz      DivWord9                 ; p©ete‡en¡

; ------ vydˆlen¡ slova HIGH1

         xchg      ax,bx                    ; BX <- LOW1
         xor       ax,ax                    ; AX <- 0
         xchg      ax,dx                    ; AX <- HIGH1, DX <- 0
         div       cx                       ; vydˆlen¡ slova HIGH1

; ------ vydˆlen¡ slova LOW

         xchg      ax,bx                    ; BX <- nov‚ HIGH, AX <- LOW1
         div       cx                       ; vydˆlen¡ slova LOW1
         mov       dx,bx                    ; DX <- nov‚ HIGH

; ------ n vrat registr–

DivWord9:pop       bx
         ret

DivWord  ENDP

; -----------------------------------------------------------------------------
;        v˜po‡et odmocniny ‡¡sla DX:AX -> DX:AX=odmocnina * 65K
;   ‡¡slo mus¡ b˜t men¨¡ ne‘ 4000:0000h (aby v˜sledek nebylo z porn‚ ‡¡slo)
; -----------------------------------------------------------------------------
; lok ln¡ promˆnn‚: SS:[BP-1] (1) ‡¡ta‡ pokus–
;                   SS:[BP-2] (1) proveden˜ po‡et rotac¡ v˜sledku
;                   SS:[BP-4] (2) zadan‚ ‡¡slo HIGH
;                   SS:[BP-6] (2) zadan‚ ‡¡slo LOW
; -----------------------------------------------------------------------------

OdmNum   PROC      NEAR

; ------ obsluha z porn‚ho ‡¡sla

         or        dx,dx                    ; je z porn‚ ‡¡slo ?
         jns       OdmNum1                  ; nen¡ z porn‚ ‡¡slo
         call      NegNum                   ; negace ‡¡sla
         call      OdmNum1                  ; odmocnina ‡¡sla
         call      NegNum                   ; n vrat negace ‡¡sla
         ret

; ------ £schova registr–

OdmNum1: push      bx
         push      cx
         push      si
         push      di
         push      bp
         mov       bp,sp
         sub       sp,6

; ------ inicializace lok ln¡ch promˆnn˜ch

         mov       word ptr ds:[bp-2],50*256 + 0 ; ‡¡ta‡ pokus– a po‡et rotac¡

; ------ test, zda je ‡¡slo <= 1

         or        dx,dx
         jnz       OdmNum2                  ; ‡¡slo je velk‚
         cmp       ax,1
         jbe       OdmNum9                  ; ‡¡slo je <= 1

; ------ zaji¨tˆn¡ dostate‡n‚ velikosti ‡¡sla (>= 1000:0000h a < 4000:0000h)

OdmNum2: cmp       dx,1000h
         jae       OdmNum3                  ; ‡¡slo je dostate‡nˆ velik‚
         shl       ax,1
         rcl       dx,1
         shl       ax,1
         rcl       dx,1
         inc       byte ptr ss:[bp-2]       ; ‡¡ta‡ proveden˜ch rotac¡
         jmp       short OdmNum2

OdmNum3: mov       ss:[bp-4],dx             ; £schova zadan‚ho ‡¡sla
         mov       ss:[bp-6],ax

; ------ p©¡prava meziv˜sledku

         shr       dx,1
         rcr       ax,1                     ; polovina zadan‚ho ‡¡sla
OdmNum4: mov       di,dx                    ; £schova meziv˜sledku
         mov       si,ax

; ------ vydˆlen¡ vstupn¡_‡¡slo/meziv˜sledek

         mov       ax,ss:[bp-6]             ; vstupn¡ ‡¡slo
         mov       dx,ss:[bp-4]
         mov       cx,si                    ; meziv˜sledek
         mov       bx,di
         call      DivDWrd                  ; vydˆlen¡ ‡¡sel

; ------ aritmetick˜ pr–mˆr pod¡lu s meziv˜sledkem

         add       ax,si                    ; p©i‡ten¡ meziv˜sledku
         adc       dx,di
         shr       dx,1
         rcr       ax,1                     ; sou‡et / 2 -> aritmetick˜ pr–mˆr

; ------ test, zda je v˜sledek ji‘ stabiln¡

         cmp       dx,di                    ; je v˜sledek ji‘ nemˆnn˜ ?
         jne       OdmNum5                  ; v˜sledek se zmˆnil
         cmp       ax,si
         je        OdmNum7                  ; v˜sledek je ji‘ stabiln¡

; ------ ‡¡t n¡ pokus–

OdmNum5: dec       byte ptr ss:[bp-1]       ; ‡¡ta‡ pokus–
         jnz       OdmNum4                  ; dal¨¡ pokus

; ------ rotace v˜sledku na pozici, aby to byl n sobek 65K

OdmNum7: mov       cx,16                    ; po‘adovan˜ po‡et rotac¡
         sub       cl,ss:[bp-2]             ; ode‡ten¡ ji‘ proveden˜ch rotac¡
         jbe       OdmNum9                  ; nen¡ co rotovat
OdmNum8: shl       ax,1
         rcl       dx,1
         loop      OdmNum8

; ------ n vrat registr–

OdmNum9: mov       sp,bp
         pop       bp
         pop       di
         pop       si
         pop       cx
         pop       bx
         ret

OdmNum   ENDP

; -----------------------------------------------------------------------------
;                    skok na obsluhu podle AL
; -----------------------------------------------------------------------------
; Procedura se vol  instrukc¡ CALL JumpAL, za kterou n sleduje tabulka
; skok–. Procedura zmˆn¡ svou n vratovou adresu na adresu podle nalezen‚
; polo‘ky v tabulce (nebo podle polo‘ky pro nenalezenou hodnotu).
; -----------------------------------------------------------------------------
; VSTUP: v z sobn¡ku 1 slovo (n vratov  adresa NEAR) = za‡ tek tabulky skok–
;            struktura tabulky: 1 bajt testovan  hodnota AL
;                               1 slovo adresa NEAR obsluhy
;             konec tabulky: 1 bajt = 0 (p©¡znak konce tabulky)
;                            1 slovo adresa NEAR obsluhy p©i nenalezen¡ k¢du
; -----------------------------------------------------------------------------

JumpAL   PROC      NEAR

; ------ £schova registr–

                                            ; SS:[BP+4] = IP
         push      si                       ; SS:[BP+2] = SI
         push      bp                       ; SS:[BP+0] = BP
         mov       bp,sp

; ------ nalezen¡ hodnoty v tabulce

         mov       si,ss:[bp+4]             ; offset adresy tabulky
JumpAL1: cmp       byte ptr ds:[si],0       ; je konec tabulky ?
         je        JumpAL2                  ; konec tabulky - nenalezeno
         cmp       byte ptr ds:[si],al      ; je to hledan  hodnota ?
         je        JumpAL2                  ; hodnota nalezena
         add       si,3                     ; adresa dal¨¡ polo‘ky
         jmp       short JumpAL1            ; test dal¨¡ polo‘ky

; ------ nastaven¡ n vratov‚ adresy podle tabulky

JumpAL2: mov       si,ds:[si+1]             ; adresa skoku
         mov       ss:[bp+4],si             ; nov  n vratov  adresa

; ------ n vrat registr–

         pop       bp
         pop       si
         ret

JumpAL   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ textu DS:SI
; -----------------------------------------------------------------------------

DispTxt  PROC      NEAR

         push      ax
         push      dx

         mov       dx,si                    ; DX <- adresa textu
         mov       ah,9
         int       21h

         pop       dx
         pop       ax
         ret

DispTxt  ENDP

; -----------------------------------------------------------------------------
;        absolutn¡ hodnota ‡¡sla DX:AX
; -----------------------------------------------------------------------------

AbsNum   PROC      NEAR

         or        dx,dx
         jns       NegNum2                  ; je to kladn‚ ‡¡slo

AbsNum   ENDP

; -----------------------------------------------------------------------------
;        negace ‡¡sla DX:AX
; -----------------------------------------------------------------------------

NegNum   PROC      NEAR

         not       ax
         not       dx
         add       ax,1
         adc       dx,0
NegNum2: ret

NegNum   ENDP

; -----------------------------------------------------------------------------
;        konverze znaku AL na velk‚ p¡smeno
; -----------------------------------------------------------------------------

UpCase   PROC      NEAR

         cmp       al,"a"
         jb        UpCase2
         cmp       al,"z"
         ja        UpCase2
         sub       al,32                    ; konverze na velk‚ p¡smeno
UpCase2: ret

UpCase   ENDP

; -----------------------------------------------------------------------------
;        obsluha p©eru¨en¡ programu Ctrl-Break
; -----------------------------------------------------------------------------

CBreak   PROC      NEAR

         push      ax
         mov       ah,0bh
         int       21h                      ; test p©eru¨en¡ programu Ctrl-Break
         pop       ax
         ret

CBreak   ENDP

; *****************************************************************************
;
;                           Dek¢dov n¡ souboru
;
; *****************************************************************************
;þ
DekVZ    PROC      NEAR

; ------ na‡ten¡ prvn¡ho znaku p©¡kazu

DekVZ1:  call      InpSpc                   ; vypu¨tˆn¡ mezer
         jnc       DekVZ2                   ; je dal¨¡ znak
         ret

DekVZ2:  call      InpChr                   ; na‡ten¡ prvn¡ho znaku

; ------ skok na obsluhu znaku

         call      DekVZ3                   ; obsluha znaku
         jmp       short DekVZ1             ; dal¨¡ povel

DekVZ3:  test      byte ptr ds:[Param],bit5 ; je HP ?
         jz        DekVZ32
         jmp       DekVZ4                   ; je HP

DekVZ32: call      JumpAL                   ; skok na obsluhu znaku

         db        "A"                      ; "A" absolutn¡ sou©adnice
         dw        DekVZA

         db        "C"                      ; "C" kru‘nice, k©ivky, elipsy
         dw        DekVZC

         db        "D"                      ; "D" spu¨tˆn¡ pera
         dw        DekVZD

         db        "E"                      ; "E" ©¡zen¡
         dw        DekVZE

         db        "F"                      ; "F" posunut˜ po‡ tek
         dw        DekVZF

         db        "H"                      ; "H" v˜choz¡ pozice
         dw        DekVZH

;         db        "I"                      ; "I" ?
;         dw        DekVZI

         db        "L"                      ; "L" nastaven¡ typu ‡ ry
         dw        DekVZL

         db        "M"                      ; "M" nakreslen¡ zna‡ky
         dw        DekVZM

         db        "O"                      ; "O" posunut˜ po‡ tek
         dw        DekVZO

         db        "P"                      ; "P" volba pera
         dw        DekVZP

         db        "Q"                      ; "Q" informace o zapisova‡i
         dw        DekVZQ

         db        "R"
         dw        DekVZR                   ; "R" relativn¡ adresov n¡

         db        "S"                      ; "S" v˜pis textu
         dw        DekVZS

         db        "T"                      ; "T" test zapisova‡e
         dw        DekVZT

         db        "U"                      ; "U" zvednut¡ pera
         dw        DekVZU

         db        "V"                      ; "V" nastaven¡ rychlosti
         dw        DekVZV

         db        "W"                      ; "W" nastaven¡ velikosti okna a ZOOM
         dw        DekVZW

         db        "Z"                      ; "Z" reset zapisova‡e
         dw        DekVZZ

         db        "p"                      ; "p" posun o 1 krok Y+
         dw        DekVZ_P

         db        "q"                      ; "q" posun o 1 krok X+ Y+
         dw        DekVZ_Q

         db        "r"                      ; "r" posun o 1 krok X+
         dw        DekVZ_R

         db        "s"                      ; "s" posun o 1 krok X+ Y-
         dw        DekVZ_S

         db        "t"                      ; "t" posun o 1 krok Y-
         dw        DekVZ_T

         db        "u"                      ; "u" posun o 1 krok X- Y-
         dw        DekVZ_U

         db        "v"                      ; "v" posun o 1 krok X-
         dw        DekVZ_V

         db        "w"                      ; "w" posun o 1 krok X- Y+
         dw        DekVZ_W

         db        "y"                      ; "y" pero nahoru
         dw        PenUp

         db        "z"                      ; "z" pero dol–
         dw        PenDown

         db        ";"                      ; ";:" volba komunika‡n¡ho m¢du
         dw        DekVZ_1

         db        "@"                      ; "@" vypr zdnˆn¡ buffer–
         dw        DekVZ_2

         db        0
         dw        DekVZMov

DekVZ    ENDP

; -----------------------------------------------------------------------------
;        form t HP
; -----------------------------------------------------------------------------

DekVZ4:  call      JumpAL                   ; skok na obsluhu znaku

         db        "I"                      ; "I" volba okna
         dw        DekVZ4I

         db        "P"
         dw        DekVZ4P                  ; "P" ovl d n¡ pera

         db        "S"
         dw        DekVZ4S                  ; "S" volba pera

         db        "C"                      ; "C"
         dw        DekVZ4C

         db        "D"                      ; "D"
         dw        DekVZ4D

         db        "V"
         dw        DekVZ4V

         db        0
         dw        DekVZMov

; -----------------------------------------------------------------------------
;        znak "S" - v˜bˆr pera
; -----------------------------------------------------------------------------

DekVZ4S: call      InpChr                   ; na‡ten¡ dal¨¡ho znaku
         jnc       DekVZ4S2
         ret

DekVZ4S2:call      JumpAL                   ; skok na obsluhu znaku

         db        "P"                      ; "P" volba pera
         dw        DekVZP

         db        0
         dw        DekVZMov

; -----------------------------------------------------------------------------
;        znak "C"
; -----------------------------------------------------------------------------

DekVZ4C: call      InpChr
         jnc       DekVZ4C2
         ret

DekVZ4C2:call      JumpAL

         db        "A"                      ; "CA"
         dw        DekVZ4CA

         db        0
         dw        DekVZMov

DekVZ4CA:call      InpBNum                  ; vstup ‡¡sla
         ret

; -----------------------------------------------------------------------------
;        "D"
; -----------------------------------------------------------------------------

DekVZ4D: call      InpChr
         jnc       DekVZ4D2
         ret

DekVZ4D2:call      JumpAL

         db        "I"                      ; "DI"
         dw        DekVZ4DI

         db        0
         dw        DekVZMov

DekVZ4DI:call      InpSNum
         call      InpSNum
         ret

; -----------------------------------------------------------------------------
;        znak "I" - volba okna
; -----------------------------------------------------------------------------

DekVZ4I: call      InpChr                   ; na‡ten¡ dal¨¡ho znaku
         jnc       DekVZ4I2
DekVZ4I1:ret

DekVZ4I2:call      JumpAL                   ; skok na obsluhu znaku

         db        "N"                      ; "IN" zaveden¡ pap¡ru
         dw        DekVZ4I1

         db        "P"                      ; "P" volba okna
         dw        DekVZW

         db        0
         dw        DekVZMov

; -----------------------------------------------------------------------------
;        znak "V"
; -----------------------------------------------------------------------------

DekVZ4V: call      InpChr                   ; na‡ten¡ dal¨¡ho znaku
         jnc       DekVZ4V2
DekVZ4V1:ret

DekVZ4V2:call      JumpAL                   ; skok na obsluhu znaku

         db        "S"
         dw        DekVZ4V1

         db        0
         dw        DekVZMov

; -----------------------------------------------------------------------------
;        znak "P" - obsluha pera
; -----------------------------------------------------------------------------

DekVZ4P: call      InpChr                   ; na‡ten¡ dal¨¡ho znaku
         jnc       DekVZ4P2                 ; je dal¨¡ znak
         ret

DekVZ4P2:call      JumpAL                   ; skok na obsluhu znaku

         db        "A"                      ; "A" absolutn¡ sou©adnice
         dw        DekVZA

;         db        "C"                      ; "C" kru‘nice, k©ivky, elipsy
;         dw        DekVZC

         db        "D"                      ; "D" spu¨tˆn¡ pera
         dw        DekVZD

;         db        "E"                      ; "E" ©¡zen¡
;         dw        DekVZE

;         db        "F"                      ; "F" posunut˜ po‡ tek
;         dw        DekVZF

;         db        "H"                      ; "H" v˜choz¡ pozice
;         dw        DekVZH

;         db        "I"                      ; "I" ?
;         dw        DekVZI

;         db        "L"                      ; "L" nastaven¡ typu ‡ ry
;         dw        DekVZL

;         db        "M"                      ; "M" nakreslen¡ zna‡ky
;         dw        DekVZM

;         db        "O"                      ; "O" posunut˜ po‡ tek
;         dw        DekVZO

;         db        "P"                      ; "P" volba pera
;         dw        DekVZP
;
;         db        "Q"                      ; "Q" informace o zapisova‡i
;         dw        DekVZQ

         db        "R"
         dw        DekVZR                   ; "R" relativn¡ adresov n¡

;         db        "S"                      ; "S" v˜pis textu
;         dw        DekVZS

;         db        "T"                      ; "T" test zapisova‡e
;         dw        DekVZT

         db        "U"                      ; "U" zvednut¡ pera
         dw        DekVZU

;         db        "V"                      ; "V" nastaven¡ rychlosti
;         dw        DekVZV

;         db        "W"                      ; "W" nastaven¡ velikosti okna a ZOOM
;         dw        DekVZW

;         db        "Z"                      ; "Z" reset zapisova‡e
;         dw        DekVZZ

;         db        "p"                      ; "p" posun o 1 krok Y+
;         dw        DekVZ_P

;         db        "q"                      ; "q" posun o 1 krok X+ Y+
;         dw        DekVZ_Q

;         db        "r"                      ; "r" posun o 1 krok X+
;         dw        DekVZ_R

;         db        "s"                      ; "s" posun o 1 krok X+ Y-
;         dw        DekVZ_S

;         db        "t"                      ; "t" posun o 1 krok Y-
;         dw        DekVZ_T

;         db        "u"                      ; "u" posun o 1 krok X- Y-
;         dw        DekVZ_U

;         db        "v"                      ; "v" posun o 1 krok X-
;         dw        DekVZ_V

;         db        "w"                      ; "w" posun o 1 krok X- Y+
;         dw        DekVZ_W

;         db        "y"                      ; "y" pero nahoru
;         dw        PenUp

;         db        "z"                      ; "z" pero dol–
;         dw        PenDown

;         db        ";"                      ; ";:" volba komunika‡n¡ho m¢du
;         dw        DekVZ_1

;         db        "@"                      ; "@" vypr zdnˆn¡ buffer–
;         dw        DekVZ_2

         db        0
         dw        DekVZMov

; -----------------------------------------------------------------------------
;        jin˜ znak - posun pera
; -----------------------------------------------------------------------------

DekVZMov:call      RetChr                   ; n vrat znaku
         call      InpSNum                  ; vstup ‡¡sla X se znam‚nkem
         jnc       DekVZMv1                 ; je ‡¡slo
         call      InpChr                   ; zru¨en¡ znaku
         ret

DekVZMv1:xchg      ax,cx
         mov       bx,dx

         call      InpSNum                  ; vstup ‡¡sla Y se znam‚nkem

         xchg      ax,cx
         xchg      bx,dx

         test      byte ptr ds:[Param],bit0 ; je absolutn¡ adresov n¡ ?
         jz        DekVZMv2                 ; nen¡ absolutn¡ adresov n¡

         call      MoveAbs                  ; p©esun na absolutn¡ pozici
         ret

DekVZMv2:call      MoveRel                  ; relativn¡ p©esun
         ret

; -----------------------------------------------------------------------------
;        "A" - absolutn¡ sou©adnice
; -----------------------------------------------------------------------------

DekVZA:  or        byte ptr ds:[Param],bit0 ; absolutn¡ adresov n¡
         ret

; -----------------------------------------------------------------------------
;        "C" - kru‘nice, k©ivky, elipsy
; -----------------------------------------------------------------------------
;þ
DekVZC:  call      InpChr                   ; na‡ten¡ dal¨¡ho znaku
         jnc       DekVZC2
DekVZC1: ret

DekVZC2: call      JumpAL

         db        'A'                      ; oblouk
         dw        DekVZCA

         db        'C'                      ; kru‘nice
         dw        DekVZCC

         db        'E'                      ; elipsa
         dw        DekVZCE

         db        'G'                      ; za‡ tek k©ivky
         dw        DekVZC1

         db        'S'                      ; konec k©ivky
         dw        DekVZC1

         db        0
         dw        RetChr

; ------ "CA" oblouk

DekVZCA: call      InpSNum                  ; na‡ten¡ sou©adnice X st©edu
         jc        DekVZCA9
         xchg      ax,cx                    ; sou©adnice X
         mov       bx,dx

         call      InpSNum                  ; na‡ten¡ sou©adnice Y
         jc        DekVZCA9
         push      ax
         push      dx

         call      InpSNum                  ; na‡ten¡ £hlu oblouku

         pushf
         or        dx,dx
         jz        DekVZCA2
         inc       dx
         jz        DekVZCA2                 ; je z porn‚ ‡¡slo
         mov       ax,360
DekVZCA2:xchg      ax,di                    ; DI <- £hel
         popf

         xchg      ax,cx                    ; AX <- sou©adnice X LOW
         mov       dx,bx                    ; DX <- sou©adnice X HIGH

         pop       bx                       ; sou©adnice Y
         pop       cx
         jc        DekVZCA9                 ; chyba zad n¡

         or        di,di                    ; je nˆjak˜ £hel ?
         jz        DekVZCA9                 ; nen¡ ‘ dn˜ £hel

         test      byte ptr ds:[Param],bit0 ; jsou absolutn¡ sou©adnice ?
         jnz       DekVZCA8                 ; jsou absolutn¡ sou©adnice
         call      RelToAbs                 ; p©evod na absolutn¡ sou©adnice
DekVZCA8:call      Oblouk                   ; vykreslen¡ oblouku

DekVZCA9:ret

; ------ "CC" kru‘nice

DekVZCC: call      InpSNum                  ; na‡ten¡ sou©adnice X
         jc        DekVZCC9
         xchg      ax,cx                    ; sou©adnice X
         mov       bx,dx

         call      InpSNum                  ; na‡ten¡ sou©adnice Y
         jc        DekVZCC9
         push      ax
         push      dx

         call      InpSNum                  ; na‡ten¡ polomˆru

         pushf
         or        dx,dx
         jz        DekVZCC2
         mov       ax,10
DekVZCC2:or        ax,ax
         jnz       DekVZCC3
         inc       ax
DekVZCC3:xchg      ax,di                    ; DI <- polomˆr
         popf

         xchg      ax,cx                    ; AX <- sou©adnice X LOW
         mov       dx,bx                    ; DX <- sou©adnice X HIGH

         pop       bx                       ; sou©adnice Y
         pop       cx
         jc        DekVZCC9                 ; chyba zad n¡

         test      byte ptr ds:[Param],bit0 ; jsou absolutn¡ sou©adnice ?
         jnz       DekVZCC8                 ; jsou absolutn¡ sou©adnice
         call      RelToAbs                 ; p©evod na absolutn¡ sou©adnice
DekVZCC8:call      Kruznice                 ; vykreslen¡ kru‘nice

DekVZCC9:ret

; ------ "CE" elipsa

DekVZCE: call      InpSNum                  ; X
         call      InpSNum                  ; Y
         call      InpSNum                  ; X1
         call      InpSNum                  ; Y1
         call      InpSNum                  ; X2
         call      InpSNum                  ; Y2
         ret

; -----------------------------------------------------------------------------
;        "D", "z" - spu¨tˆn¡ pera
; -----------------------------------------------------------------------------

DekVZD:  test      byte ptr ds:[Param],bit1 ; je pero ji‘ spu¨tˆno ?
         jz        DekVZD2                  ; pero je ji‘ spu¨tˆno

PenDown: push      di
         mov       di,offset PovelDwn       ; povel pro spu¨tˆn¡ pera
         and       byte ptr ds:[Param],not bit1 ; pero spu¨tˆno
         call      OutPovel                 ; vysl n¡ povelu
         pop       di
DekVZD2: ret

; -----------------------------------------------------------------------------
;        "E" - ©¡zen¡
; -----------------------------------------------------------------------------

DekVZE:  call      InpChr                   ; na‡ten¡ dal¨¡ho znaku
         jnc       DekVZE2                  ; je znak
DekVZE1: ret
DekVZE2: call      JumpAL                   ; vˆtven¡ podle znaku

         db        "B"                      ; "EB" komunika‡n¡ m¢d
         dw        InpNum                   ; vypu¨tˆn¡ ‡¡sla (ignoruje se)

         db        "C"                      ; "EC" velikost kroku zapisova‡e
         dw        DekVZEC

         db        "D"                      ; "ED" digitalizace (ignoruje se)
         dw        DekVZE1

         db        "F"                      ; "EF" velk˜ form t
         dw        DekVZEF

         db        "H"                      ; "EH" mal˜ form t
         dw        DekVZEH

         db        "L"                      ; "EL" zastaven¡ zapisova‡e
         dw        DekVZEL

         db        "M"                      ; "EM" maskov n¡ kl vesnice (ignoruje se)
         dw        DekVZE1

         db        "R"                      ; "ER" hl ¨en¡ o stavu
         dw        DekVZE1

         db        "T"                      ; "ET" znak konce textu
         dw        DekVZET

         db        "U"                      ; "EU" nastaven¡ UART (ignorov no)
         dw        InpNum                   ; vypu¨tˆn¡ ‡¡sla

         db        0
         dw        RetChr                   ; jinak n vrat znaku

; ------ "EC" velikost kroku zapisova‡e

DekVZEC: call      InpChr                   ; na‡ten¡ dal¨¡ho znaku
         jc        DekVZE1
         call      JumpAL                   ; vˆtven¡ podle znaku

         db        "1"                      ; "EC1" krok 0.001" (0.025 mm)
         dw        DekEC1

         db        "5"                      ; "EC5" krok 0.005" (0.125 mm)
         dw        DekEC5

         db        "M"                      ; "ECM" krok 0.1 mm
         dw        DekECM

         db        "N"                      ; "ECN" krok 0.025 mm
         dw        DekECN

         db        0
         dw        RetChr                   ; jinak n vrat znaku

; ------ "EC1" krok 0.001" (0.0254 mm)

DekEC1:  mov       ax,127                   ; n sobek
         mov       bx,250                   ; dˆlitel
         jmp       short DekECN2

; ------ "EC5" krok 0.005" (0.127 mm)

DekEC5:  mov       ax,127                   ; n sobek
         mov       bx,50                    ; dˆlitel
         jmp       short DekECN2

; ------ "ECM" krok 0.1 mm

DekECM:  mov       ax,2                     ; n sobek
         mov       bx,1                     ; dˆlitel
         jmp       short DekECN2

; ------ "ECN" krok 0.025 mm

DekECN:  mov       ax,1                     ; n sobek
         mov       bx,2                     ; dˆlitel
DekECN2: mov       ds:[NasKrok],ax          ; n sobek krokov n¡
         mov       ds:[DelKrok],bx          ; dˆlitel krokov n¡
         ret

; ------ "EF" nastaven¡ velk‚ho form tu

DekVZEF: or        byte ptr ds:[Param],bit2 ; p©¡znak velk‚ho form tu
         ret

; ------ "EH" nastaven¡ mal‚ho form tu

DekVZEH: and       byte ptr ds:[Param],not bit2 ; je mal˜ form t
         ret

; ------ "EL" pauza

DekVZEL: mov       di,offset PovelStp       ; povel pro zastaven¡ zapisova‡e
         call      OutPovel                 ; vysl n¡ povelu
         ret

; ------ "ET" znak konce textu

DekVZET: call      InpHex                   ; na‡ten¡ 1. HEX ‡¡slice
         jc        DekVZET8                 ; nen¡ HEX ‡¡slice
         mov       ds:[EOTChr],al           ; ulo‘en¡ znaku
         call      InpHex                   ; na‡ten¡ 2. HEX ‡¡slice
         jc        DekVZET8                 ; nen¡ HEX ‡¡slice
         mov       ah,ds:[EOTChr]
         mov       cl,4
         shl       ah,cl
         or        al,ah
         mov       ds:[EOTChr],al           ; nov˜ znak konce textu
DekVZET8:ret

; -----------------------------------------------------------------------------
;        "F" - posunut˜ po‡ tek
; -----------------------------------------------------------------------------

DekVZF:  call      InpSNum                  ; na‡ten¡ ‡¡sla

; ------ test, zda ‡¡slo je = 0

         mov       cx,ax
         or        cx,dx                    ; je ‡¡slo = 0 ?
         jcxz      DekVZF3                  ; ‡¡slo = 0

; ------ ‡¡slo nen¡ = 0; test, zda je velk˜ form t

         test      byte ptr ds:[Param],bit2 ; je velk˜ form t ?
         jz        DekVZF2                  ; nen¡ velk˜ form t

; ------ ‡¡slo nen¡ = 0, je velk˜ form t

         add       word ptr ds:[HomeX],ax   ; posun po‡ tku X
         adc       word ptr ds:[HomeX+2],dx
         jmp       short DekVZF6

; ------ ‡¡slo nen¡ = 0, je mal˜ form t

DekVZF2: add       word ptr ds:[HomeY],ax   ; posun po‡ tku Y
         adc       word ptr ds:[HomeY+2],dx
         jmp       short DekVZF6

; ------ ‡¡slo je = 0; test, zda je velk˜ form t

DekVZF3: test      byte ptr ds:[Param],bit2 ; je velk˜ form t ?
         jz        DekVZF4                  ; nen¡ velk˜ form t

; ------ ‡¡slo = 0, je velk˜ form t

         mov       ax,word ptr ds:[AktX]    ; aktu ln¡ sou©adnice X
         mov       word ptr ds:[HomeX],ax   ; bude to nov˜ po‡ tek
         mov       ax,word ptr ds:[AktX+2]
         mov       word ptr ds:[HomeX+2],ax
         jmp       short DekVZF6

; ------ ‡¡slo = 0, je mal˜ form t

DekVZF4: mov       ax,word ptr ds:[AktY]    ; aktu ln¡ sou©adnice Y
         mov       word ptr ds:[HomeY],ax   ; bude to nov˜ po‡ tek
         mov       ax,word ptr ds:[AktY+2]
         mov       word ptr ds:[HomeY+2],ax

DekVZF6: ret

; -----------------------------------------------------------------------------
;        "H" - nastaven¡ v˜choz¡ pozice
; -----------------------------------------------------------------------------

DekVZH:  call      SetHome                  ; nastaven¡ v˜choz¡ pozice
         ret

; -----------------------------------------------------------------------------
;        "L" - nastaven¡ typu ‡ ry
; -----------------------------------------------------------------------------
;þ
DekVZL:  call      InpBNum                  ; vstup ‡¡sla typu ‡ ry
         jc        DekVZL9


DekVZL9: ret

; -----------------------------------------------------------------------------
;        "M" - nakreslen¡ zna‡ky
; -----------------------------------------------------------------------------

DekVZM:  call      InpChr                   ; na‡ten¡ dal¨¡ho znaku
         jnc       DekVZM11
         ret

DekVZM11:mov       word ptr ds:[MarkSize],2 ; implicitn¡ velikost zna‡ky
         mov       byte ptr ds:[TypMark],0  ; implicitn¡ typ zna‡ky
         cmp       al,"("                   ; je roz¨¡©en˜ p©¡kaz ?
         jne       DekVZM2                  ; nen¡ roz¨¡©en˜ p©¡kaz

         call      InpUChr                  ; na‡ten¡ dal¨¡ho znaku
         jc        DekVZM4
         cmp       al,"S"                   ; je roz¨¡©en˜ p©¡kaz ?
         jne       DekVZM1                  ; nen¡ roz¨¡©en˜ p©¡kaz

; ------ na‡ten¡ velikosti zna‡ky

         call      InpWNum                  ; na‡ten¡ velikosti zna‡ky
         jc        DekVZM12
         shl       ax,1
         mov       ds:[MarkSize],ax         ; velikost zna‡ky

; ------ zvˆt¨en¡ zna‡ky o polovinu

DekVZM12:call      InpChr                   ; na‡ten¡ dal¨¡ho znaku
         jc        DekVZM1
         cmp       al,"+"
         je        DekVZM13
         call      RetChr
         jmp       short DekVZM1

DekVZM13:mov       ax,ds:[MarkSize]         ; velikost zna‡ky
         shr       ax,1                     ; polovina
         add       ds:[MarkSize],ax         ; zvˆt¨en¡ o polovinu

; ------ nalezen¡ konce z vorky

DekVZM1: call      InpChr                   ; na‡ten¡ dal¨¡ho znaku
         jc        DekVZM4
         cmp       al,")"
         jne       DekVZM1                  ; ‡ek n¡ na konec p©¡kazu
         jmp       short DekVZM4

; ------ na‡ten¡ velikosti zna‡ky

DekVZM2: call      RetChr                   ; navr cen¡ znaku
         call      Inp0Num                  ; na‡ten¡ jedn‚ ‡¡slice
         jc        DekVZM3                  ; nen¡ ‡¡slice
         xchg      ax,cx
         mov       ax,1
         shl       ax,cl
         mov       ds:[MarkSize],ax         ; velikost zna‡ky

; ------ zvˆt¨en¡ zna‡ky o polovinu

DekVZM3: call      InpChr                   ; na‡ten¡ dal¨¡ho znaku
         jc        DekVZM4
         cmp       al,"+"
         je        DekVZM32
         call      RetChr
         jmp       short DekVZM4

DekVZM32:mov       ax,ds:[MarkSize]         ; velikost zna‡ky
         shr       ax,1                     ; polovina
         add       ds:[MarkSize],ax         ; zvˆt¨en¡ o polovinu

; ------ omezen¡ velikosti zna‡ky

DekVZM4: cmp       word ptr ds:[MarkSize],0 ; minim ln¡ velikost zna‡ky
         jne       DekVZM5
         mov       word ptr ds:[MarkSize],2 ; minim ln¡ velikost zna‡ky

; ------ vypu¨tˆn¡ mezer

DekVZM5: call      InpSpc                   ; vypu¨tˆn¡ mezer

; ------ na‡ten¡ typu zna‡ky

         call      Inp0Num                  ; na‡ten¡ typu zna‡ky
         jc        DekVZM6
         cmp       al,5
         ja        DekVZM6
         mov       ds:[TypMark],al          ; typ zna‡ky

; ------ adresa definice zna‡ky

DekVZM6: mov       bl,ds:[TypMark]          ; typ zna‡ky
         mov       bh,0
         shl       bx,1
         mov       bx,ds:[AdrMark+bx]       ; adresa definice zna‡ky

; ------ p©¡prava k vykreslen¡ zna‡ky

         mov       ch,0
         mov       cl,ds:[bx]               ; po‡et bajt–
         inc       bx

; ------ na‡ten¡ jednoho bajtu definice

DekVZM7: mov       al,ds:[bx]               ; jeden bajt definice
         inc       bx
         push      bx
         push      cx

; ------ nastaven¡ pera

         mov       di,offset PovelDwn       ; povel pro spu¨tˆn¡ pera
         cmp       al,40h                   ; m  b˜t pero zvednuto ?
         ja        DekVZM8                  ; pero m  b˜t spu¨tˆno
         mov       di,offset PovelUp        ; povel pro zvednut¡ pera
DekVZM8: call      OutPovel                 ; vysl n¡ povelu pro nastaven¡ pera

; ------ v˜po‡et posunu X

         push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         and       al,7
         mov       ah,0
         sub       ax,4
         cwd
         mov       cx,ds:[MarkSize]
         xor       bx,bx
         call      MulSDWrd                 ; vyn soben¡ velikost¡
         pop       bx

; ------ v˜po‡et posunu Y

         push      ax
         push      dx
         mov       al,bl
         and       al,7
         mov       ah,0
         sub       ax,4
         cwd
         xor       bx,bx
         call      MulSDWrd                 ; vyn soben¡ velikost¡

; ------ posun pera

         xchg      ax,cx                    ; CX <- posun Y
         mov       bx,dx
         pop       dx
         pop       ax
         call      MoveRel                  ; p©esun pera

; ------ p©¡prava k dal¨¡mu bajtu definice

         pop       cx
         pop       bx
         loop      DekVZM7

; ------ n vrat nastaven¡ pera

         mov       di,offset PovelDwn       ; povel pro spu¨tˆn¡ pera
         test      byte ptr ds:[Param],bit1 ; m  b˜t pero zvednuto ?
         jz        DekVZM9                  ; pero m  b˜t spu¨tˆno
         mov       di,offset PovelUp        ; povel pro zvednut¡ pera
DekVZM9: call      OutPovel                 ; vysl n¡ povelu pro nastaven¡ pera
         ret

; -----------------------------------------------------------------------------
;        "O" - posunut˜ po‡ tek
; -----------------------------------------------------------------------------

DekVZO:  mov       ax,word ptr ds:[AktX]
         mov       word ptr ds:[HomeX],ax
         mov       ax,word ptr ds:[AktX+2]
         mov       word ptr ds:[HomeX+2],ax

         mov       ax,word ptr ds:[AktY]
         mov       word ptr ds:[HomeY],ax
         mov       ax,word ptr ds:[AktY+2]
         mov       word ptr ds:[HomeY+2],ax
         ret

; -----------------------------------------------------------------------------
;        "P" - volba pera
; -----------------------------------------------------------------------------

DekVZP:  call      InpBNum                  ; na‡ten¡ bajtu
         jc        DekVZP3                  ; chyba
         cmp       al,0                     ; je ukon‡en¡ v˜bˆru ?
         je        DekVZP4                  ; je ukon‡en¡ v˜bˆru P0
         cmp       al,3
         jbe       DekVZP2                  ; ‡¡slo pera je OK
         mov       al,3                     ; omezen¡ ‡¡sla pera
DekVZP2: mov       di,offset PovelPen       ; povel pro volbu pera
         mov       ds:[di+2],al             ; zvolen‚ pero
         call      OutPovel                 ; vysl n¡ povelu
DekVZP3: ret

DekVZP4: call      SetHome                  ; navr cen¡ pera
         ret

; -----------------------------------------------------------------------------
;        "Q" - informace o zapisova‡i
; -----------------------------------------------------------------------------

DekVZQ:  ret

; -----------------------------------------------------------------------------
;        "R" - relativn¡ adresov n¡ sou©adnic
; -----------------------------------------------------------------------------

DekVZR:  and       byte ptr ds:[Param],not bit0 ; relativn¡ adresov n¡
         ret

; -----------------------------------------------------------------------------
;        "S" - v˜pis textu
; -----------------------------------------------------------------------------
;þ
DekVZS:
         ret

; -----------------------------------------------------------------------------
;        "T" - test zapisova‡e
; -----------------------------------------------------------------------------

DekVZT:  ret

; -----------------------------------------------------------------------------
;        "U", "y" - zvednut¡ pera
; -----------------------------------------------------------------------------

DekVZU:  test      byte ptr ds:[Param],bit1 ; je pero ji‘ zvednuto ?
         jnz       DekVZU2                  ; pero je ji‘ zvednuto

PenUp:   push      di
         mov       di,offset PovelUp        ; povel pro zvednut¡ pera
         or        byte ptr ds:[Param],bit1 ; pero zvednuto
         call      OutPovel                 ; vysl n¡ povelu
         pop       di
DekVZU2: ret

; -----------------------------------------------------------------------------
;        "V" - nastaven¡ rychlosti
; -----------------------------------------------------------------------------

DekVZV:  call      InpNum                   ; ‡¡slo se ignoruje
         ret

; -----------------------------------------------------------------------------
;        "W" - nastaven¡ velikosti okna a zvˆt¨en¡ ZOOM
; -----------------------------------------------------------------------------

; ------ lev˜ okraj okna

DekVZW:  call      InpSNum
         jnc       DekVZW2
DekVZW1: ret

DekVZW2: mov       word ptr ds:[MinXWin],ax
         mov       word ptr ds:[MinXWin+2],dx
         mov       word ptr ds:[MinXZoom],ax
         mov       word ptr ds:[MinXZoom+2],dx

; ------ doln¡ okraj okna

         call      InpSNum
         jc        DekVZW22
         mov       word ptr ds:[MinYWin],ax
         mov       word ptr ds:[MinYWin+2],dx
         mov       word ptr ds:[MinYZoom],ax
         mov       word ptr ds:[MinYZoom+2],dx

; ------ prav˜ okraj okna

         call      InpSNum
         jc        DekVZW22
         mov       word ptr ds:[MaxXWin],ax
         mov       word ptr ds:[MaxXWin+2],dx
         mov       word ptr ds:[MaxXZoom],ax
         mov       word ptr ds:[MaxXZoom+2],dx

; ------ horn¡ okraj okna

         call      InpSNum
         jc        DekVZW22
         mov       word ptr ds:[MaxYWin],ax
         mov       word ptr ds:[MaxYWin+2],dx
         mov       word ptr ds:[MaxYZoom],ax
         mov       word ptr ds:[MaxYZoom+2],dx

; ------ lev˜ okraj podokna

         test      byte ptr ds:[Param],bit5 ; je HP ?
         jnz       DekVZW22                 ; je form t HP

         call      InpSNum
         jc        DekVZW22
         mov       word ptr ds:[MinXZoom],ax
         mov       word ptr ds:[MinXZoom+2],dx

; ------ doln¡ okraj podokna

         call      InpSNum
         jc        DekVZW22
         mov       word ptr ds:[MinYZoom],ax
         mov       word ptr ds:[MinYZoom+2],dx

; ------ prav˜ okraj podokna

         call      InpSNum
         jc        DekVZW22
         mov       word ptr ds:[MaxXZoom],ax
         mov       word ptr ds:[MaxXZoom+2],dx

; ------ horn¡ okraj podokna

         call      InpSNum
         jc        DekVZW22
         mov       word ptr ds:[MaxYZoom],ax
         mov       word ptr ds:[MaxYZoom+2],dx

; ------ ¨¡©ka okna

DekVZW22:mov       ax,word ptr ds:[MaxXWin]
         mov       dx,word ptr ds:[MaxXWin+2]
         sub       ax,word ptr ds:[MinXWin]
         sbb       dx,word ptr ds:[MinXWin+2]
         call      AbsNum
         mov       word ptr ds:[DltXWin],ax
         mov       word ptr ds:[DltXWin+2],dx
         or        ax,dx                    ; je ¨¡©ka okna = 0 ?
         jnz       DekVZW3
         inc       word ptr ds:[DltXWin]    ; minim ln¡ ¨¡©ka okna

; ------ v˜¨ka okna

DekVZW3: mov       ax,word ptr ds:[MaxYWin]
         mov       dx,word ptr ds:[MaxYWin+2]
         sub       ax,word ptr ds:[MinYWin]
         sbb       dx,word ptr ds:[MinYWin+2]
         call      AbsNum
         mov       word ptr ds:[DltYWin],ax
         mov       word ptr ds:[DltYWin+2],dx
         or        ax,dx                    ; je v˜¨ka okna = 0 ?
         jnz       DekVZW4
         inc       word ptr ds:[DltYWin]    ; minim ln¡ v˜¨ka okna

; ------ ¨¡©ka podokna

DekVZW4: mov       ax,word ptr ds:[MaxXZoom]
         mov       dx,word ptr ds:[MaxXZoom+2]
         sub       ax,word ptr ds:[MinXZoom]
         sbb       dx,word ptr ds:[MinXZoom+2]
         call      AbsNum
         mov       word ptr ds:[DltXZoom],ax
         mov       word ptr ds:[DltXZoom+2],dx
         or        ax,dx                    ; je ¨¡©ka podokna = 0 ?
         jnz       DekVZW5
         inc       word ptr ds:[DltXZoom]   ; minim ln¡ ¨¡©ka podokna

; ------ v˜¨ka podokna

DekVZW5: mov       ax,word ptr ds:[MaxYZoom]
         mov       dx,word ptr ds:[MaxYZoom+2]
         sub       ax,word ptr ds:[MinYZoom]
         sbb       dx,word ptr ds:[MinYZoom+2]
         call      AbsNum
         mov       word ptr ds:[DltYZoom],ax
         mov       word ptr ds:[DltYZoom+2],dx
         or        ax,dx                    ; je v˜¨ka podokna = 0 ?
         jnz       DekVZW6
         inc       word ptr ds:[DltYZoom]   ; minim ln¡ v˜¨ka podokna

; ------ stanoven¡ n sobku a dˆlitele X ZOOM

DekVZW6: mov       ax,word ptr ds:[DltXZoom]
         mov       dx,word ptr ds:[DltXZoom+2]
         mov       cx,word ptr ds:[DltXWin]
         mov       bx,word ptr ds:[DltXWin+2]
DekVZW7: or        bx,bx
         jnz       DekVZW72
         or        dx,dx
         jz        DekVZW74
DekVZW72:shr       dx,1
         rcr       ax,1
         shr       bx,1
         rcr       cx,1
         jmp       short DekVZW7

DekVZW74:or        cx,cx
         jnz       DekVZW76
         inc       cx
DekVZW76:mov       ds:[NasXZoom],ax
         mov       ds:[DelXZoom],cx

; ------ stanoven¡ n sobku a dˆlitele Y ZOOM

         mov       ax,word ptr ds:[DltYZoom]
         mov       dx,word ptr ds:[DltYZoom+2]
         mov       cx,word ptr ds:[DltYWin]
         mov       bx,word ptr ds:[DltYWin+2]
DekVZW8: or        bx,bx
         jnz       DekVZW82
         or        dx,dx
         jz        DekVZW84
DekVZW82:shr       dx,1
         rcr       ax,1
         shr       bx,1
         rcr       cx,1
         jmp       short DekVZW8

DekVZW84:or        cx,cx
         jnz       DekVZW86
         inc       cx
DekVZW86:mov       ds:[NasYZoom],ax
         mov       ds:[DelYZoom],cx
         ret

; -----------------------------------------------------------------------------
;        "Z" - reset zapisova‡e
; -----------------------------------------------------------------------------

DekVZZ:  call      PenUp                    ; zvednut¡ pera
         mov       al,1
         call      DekVZP2                  ; volba pera 1
         call      DekVZA                   ; absolutn¡ sou©adnice

         xor       ax,ax
         mov       word ptr ds:[HomeX],ax
         mov       word ptr ds:[HomeX+2],ax
         mov       word ptr ds:[HomeY],ax
         mov       word ptr ds:[HomeY+2],ax

         mov       word ptr ds:[AktX],ax
         mov       word ptr ds:[AktX+2],ax
         mov       word ptr ds:[AktY],ax
         mov       word ptr ds:[AktY+2],ax

         mov       word ptr ds:[SkutX],ax
         mov       word ptr ds:[SkutX+2],ax
         mov       word ptr ds:[SkutY],ax
         mov       word ptr ds:[SkutY+2],ax

         call      NulWin                   ; nulov n¡ okna

         mov       word ptr ds:[NasKrok],1
         mov       word ptr ds:[DelKrok],2

         mov       byte ptr ds:[EOTChr],"_"
         ret

; -----------------------------------------------------------------------------
;        nulov n¡ okna
; -----------------------------------------------------------------------------

NulWin   PROC      NEAR

         push      ax
         xor       ax,ax
         mov       word ptr ds:[MinXWin],ax
         mov       word ptr ds:[MinXWin+2],ax
         mov       word ptr ds:[MinYWin],ax
         mov       word ptr ds:[MinYWin+2],ax

         mov       word ptr ds:[MinXZoom],ax
         mov       word ptr ds:[MinXZoom+2],ax
         mov       word ptr ds:[MinYZoom],ax
         mov       word ptr ds:[MinYZoom+2],ax

         mov       ax,7777h                 ; AX <- 7777h
         mov       word ptr ds:[MaxXWin],ax
         mov       word ptr ds:[MaxXWin+2],ax
         mov       word ptr ds:[MaxYWin],ax
         mov       word ptr ds:[MaxYWin+2],ax

         mov       word ptr ds:[MaxXZoom],ax
         mov       word ptr ds:[MaxXZoom+2],ax
         mov       word ptr ds:[MaxYZoom],ax
         mov       word ptr ds:[MaxYZoom+2],ax

         mov       word ptr ds:[DltXWin],ax
         mov       word ptr ds:[DltXWin+2],ax
         mov       word ptr ds:[DltYWin],ax
         mov       word ptr ds:[DltYWin+2],ax

         mov       word ptr ds:[DltXZoom],ax
         mov       word ptr ds:[DltXZoom+2],ax
         mov       word ptr ds:[DltYZoom],ax
         mov       word ptr ds:[DltYZoom+2],ax

         mov       ax,1
         mov       ds:[NasXZoom],ax
         mov       ds:[DelXZoom],ax
         mov       ds:[NasYZoom],ax
         mov       ds:[DelYZoom],ax

         pop       ax
         ret

NulWin   ENDP

; -----------------------------------------------------------------------------
;        ";" - volba komunika‡n¡ho m¢du
; -----------------------------------------------------------------------------

DekVZ_1: call      InpChr                   ; na‡ten¡ dal¨¡ho znaku
         jc        DekVZ_14
         cmp       al,":"
         je        DekVZ_14
         call      RetChr                   ; jin˜ znak - navr cen¡
DekVZ_14:ret

; -----------------------------------------------------------------------------
;        "@" - vypr zdnˆn¡ buffer–
; -----------------------------------------------------------------------------

DekVZ_2: call      FlshPakt                 ; vypr zdnˆn¡ buffer–
         ret

; -----------------------------------------------------------------------------
;        "p" - posun o 1 krok Y+
; -----------------------------------------------------------------------------

DekVZ_P: mov       al,0
         mov       cl,1
         jmp       short DekVZ_W2

; -----------------------------------------------------------------------------
;        "q" - posun o 1 krok X+ Y+
; -----------------------------------------------------------------------------

DekVZ_Q: mov       al,1
         mov       cl,1
         jmp       short DekVZ_W2

; -----------------------------------------------------------------------------
;        "r" - posun o 1 krok X+
; -----------------------------------------------------------------------------

DekVZ_R: mov       al,1
         mov       cl,0
         jmp       short DekVZ_W2

; -----------------------------------------------------------------------------
;        "s" - posun o 1 krok X+ Y-
; -----------------------------------------------------------------------------

DekVZ_S: mov       al,1
         mov       cl,-1
         jmp       short DekVZ_W2

; -----------------------------------------------------------------------------
;        "t" - posun o 1 krok Y-
; -----------------------------------------------------------------------------

DekVZ_T: mov       al,0
         mov       cl,-1
         jmp       short DekVZ_W2

; -----------------------------------------------------------------------------
;        "u" - posun o 1 krok X- Y-
; -----------------------------------------------------------------------------

DekVZ_U: mov       al,-1
         mov       cl,-1
         jmp       short DekVZ_W2

; -----------------------------------------------------------------------------
;        "v" - posun o 1 krok X-
; -----------------------------------------------------------------------------

DekVZ_V: mov       al,-1
         mov       cl,0
         jmp       short DekVZ_W2

; -----------------------------------------------------------------------------
;        "w" - posun o 1 krok X- Y+
; -----------------------------------------------------------------------------

DekVZ_W: mov       al,-1
         mov       cl,1

DekVZ_W2:cbw
         cwd
         xor       bx,bx
         mov       ch,0
         or        cl,cl
         jns       DekVZ_W3
         mov       ch,-1
         dec       bx
DekVZ_W3:call      MoveRel                  ; posun pera
         ret

; *****************************************************************************
;
;                          Obsluha bufferu souboru
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        vypu¨tˆn¡ mezer v souboru
; -----------------------------------------------------------------------------

InpSpc   PROC      NEAR

InpSpc2: call      InpChr                   ; na‡ten¡ znaku
         jc        InpSpc9                  ; konec souboru
         cmp       al," "
         jbe       InpSpc2
         cmp       al,","
         je        InpSpc2
         call      RetChr                   ; n vrat znaku
         clc

InpSpc9: ret

InpSpc   ENDP

; -----------------------------------------------------------------------------
;        vstup bajtu AL
; -----------------------------------------------------------------------------

InpBNum  PROC      NEAR

         push      bx
         push      ax
         call      InpWNum                  ; vstup slova

         jc        InpBNum4                 ; chyba
         or        ah,ah                    ; je v¡ce ne‘ bajt ?
         jz        InpBNum4
         mov       al,255                   ; omezen¡ velikosti ‡¡sla
InpBNum4:xchg      ax,bx                    ; BL <- £schova bajtu
         pop       ax
         mov       al,bl                    ; AL <- na‡ten˜ bajt
         pop       bx
         ret

InpBNum  ENDP

; -----------------------------------------------------------------------------
;        vstup slova AX
; -----------------------------------------------------------------------------

InpWNum  PROC      NEAR

         push      dx
         call      InpNum                   ; vstup ‡¡sla DX:AX
         jc        InpWNum9                 ; chyba
         or        dx,dx                    ; je v¡ce ne‘ slovo ?
         jz        InpWNum9                 ; ‡¡slo je OK
         mov       ax,0ffffh                ; omezen¡ velikosti ‡¡sla
InpWNum9:pop       dx
         ret

InpWNum  ENDP

; -----------------------------------------------------------------------------
;        vstup ‡¡sla DX:AX se znam‚nkem
; -----------------------------------------------------------------------------

InpSNum  PROC      NEAR

         call      InpSpc                   ; vypu¨tˆn¡ mezer

; ------ bude kladn‚ ‡¡slo

InpSNum1:call      InpChr                   ; na‡ten¡ znaku
         jc        InpSNum9                 ; nen¡ dal¨¡ znak
         cmp       al,"+"                   ; bude kladn‚ ‡¡slo ?
         je        InpSNum1                 ; znam‚nko "+" se ignoruje
         cmp       al,"-"                   ; je zmˆna znam‚nka ?
         je        InpSNum3                 ; bude z porn‚ ‡¡slo
         call      RetChr                   ; n vrat znaku do bufferu

; ------ na‡ten¡ ‡¡sla

         call      InpNum                   ; na‡ten¡ ‡¡sla
         jc        InpSNum9                 ; chyba
         cmp       dx,8000h                 ; je p©ete‡en¡ velikosti ‡¡sla ?
         jb        InpSNum7                 ; nen¡ p©ete‡en¡ velikosti ‡¡sla
         mov       ax,0ffffh
         mov       dx,7fffh                 ; omezen¡ velikosti ‡¡sla
         jmp       short InpSNum7

; ------ bude z porn‚ ‡¡slo

InpSNum3:call      InpChr                   ; na‡ten¡ znaku
         jc        InpSNum9                 ; nen¡ dal¨¡ znak
         cmp       al,"+"
         je        InpSNum3                 ; znam‚nko "+" se ignoruje
         cmp       al,"-"                   ; je zmˆna znam‚nka ?
         je        InpSNum1                 ; bude kladn‚ ‡¡slo
         call      RetChr                   ; n vrat znaku do bufferu

; ------ na‡ten¡ ‡¡sla

         call      InpNum                   ; na‡ten¡ ‡¡sla
         jc        InpSNum9                 ; chyba
         cmp       dx,8000h                 ; je p©ete‡en¡ velikosti ‡¡sla ?
         jb        InpSNum4                 ; nen¡ p©ete‡en¡ velikosti ‡¡sla
         mov       ax,0ffffh
         mov       dx,7fffh                 ; omezen¡ velikosti ‡¡sla

; ------ negace ‡¡sla

InpSNum4:call      NegNum                   ; negace ‡¡sla DX:AX

InpSNum7:clc                                ; p©¡znak operace OK

InpSNum9:ret

InpSNum  ENDP

; -----------------------------------------------------------------------------
;        vstup ‡¡sla DX:AX ze souboru
; -----------------------------------------------------------------------------

InpNum   PROC      NEAR

; ------ £schova registr–

         push      bx
         push      cx

; ------ p©¡prava registr–

         xor       bx,bx                    ; st©ada‡ ‡¡sla HIGH
         xor       cx,cx                    ; st©ada‡ ‡¡sla LOW

; ------ na‡ten¡ prvn¡ho znaku

         call      Inp0Num                  ; na‡ten¡ prvn¡ho znaku
         jc        InpNum9                  ; chyba - nen¡ ‡¡slo

; ------ vyn soben¡ st©ada‡e 10x

InpNum2: push      ax
         mov       ax,10
         mul       cx                       ; vyn soben¡ st©ada‡e LOW
         xchg      ax,cx                    ; CX <- nov˜ st©ada‡ LOW
         xchg      dx,bx                    ; BX <- nov˜ st©ada‡ HIGH
         mov       ax,10
         mul       dx                       ; vyn soben¡ st©ada‡e HIGH
         add       bx,ax                    ; BX <- nov˜ st©ada‡ HIGH
         pop       ax

; ------ p©i‡ten¡ ‡¡sla

         adc       dx,dx                    ; je p©ete‡en¡ ?
         jnz       InpNum3                  ; je p©ete‡en¡
         mov       ah,0
         add       cx,ax                    ; p©i‡ten¡ ‡¡slice
         adc       bx,dx                    ; p©enos
         adc       dx,dx                    ; je p©ete‡en¡ ?
         jz        InpNum4                  ; nen¡ p©ete‡en¡

; ------ omezen¡ st©ada‡e p©i p©ete‡en¡

InpNum3: mov       cx,-1                    ; omezen¡ st©ada‡e p©i p©ete‡en¡
         mov       bx,cx

; ------ na‡ten¡ dal¨¡ho znaku

InpNum4: call      Inp0Num                  ; na‡ten¡ dal¨¡ ‡¡slice
         jnc       InpNum2                  ; je dal¨¡ ‡¡slice
         clc                                ; p©¡znak operace OK

; ------ n vrat registr–

InpNum9: xchg      ax,cx                    ; AX <- na‡ten‚ ‡¡slo LOW
         mov       dx,bx                    ; DX <- na‡ten‚ ‡¡slo HIGH

         pop       cx
         pop       bx
         ret

InpNum   ENDP

; -----------------------------------------------------------------------------
;        vstup znaku dekadick‚ ‡¡slice
; -----------------------------------------------------------------------------

Inp0Num  PROC      NEAR

         call      InpChr                   ; vstup znaku
         jc        Inp0Num9                 ; nen¡ dal¨¡ znak

         cmp       al,"0"
         jb        Inp0Num8                 ; neplatn˜ znak
         cmp       al,"9"
         ja        Inp0Num8                 ; neplatn˜ znak
         sub       al,"0"                   ; ‡¡slo
         ret

Inp0Num8:call      RetChr                   ; n vrat znaku
         stc                                ; p©¡znak neplatnosti znaku
Inp0Num9:ret

Inp0Num  ENDP

; -----------------------------------------------------------------------------
;        vstup znaku HEX -> AL
; -----------------------------------------------------------------------------

InpHex   PROC      NEAR

         call      InpUChr                  ; na‡ten¡ znaku
         jc        InpHex9                  ; nen¡ dal¨¡ znak

         cmp       al,"0"
         jb        InpHex8                  ; neplatn˜ znak
         cmp       al,"9"
         jbe       InpHex4                  ; je ‡¡slice OK
         cmp       al,"A"
         jb        InpHex8                  ; nen¡ HEX ‡¡slice
         cmp       al,"F"
         ja        InpHex8                  ; nen¡ HEX ‡¡slice

         sub       al,7                     ; korekce
InpHex4: sub       al,"0"                   ; korekce na ‡¡slo
         ret

InpHex8: call      RetChr                   ; n vrat znaku
         stc                                ; p©¡znak neplatnosti znaku
InpHex9: ret

InpHex   ENDP

; -----------------------------------------------------------------------------
;        vstup znaku ze vstupn¡ho bufferu s konverz¡ na velk‚ p¡smeno
; -----------------------------------------------------------------------------

InpUChr  PROC      NEAR

         call      InpChr                   ; vstup znaku ze souboru
         jc        InpUChr2                 ; konec souboru
         call      UpCase                   ; konverze na velk‚ p¡smeno
         clc                                ; p©¡znak platnosti znaku
InpUChr2:ret

InpUChr  ENDP

; -----------------------------------------------------------------------------
;        vstup znaku ze vstupn¡ho bufferu (ukazatel DS:SI) CY=chyba
; -----------------------------------------------------------------------------

InpChr   PROC      NEAR

; ------ na‡ten¡ znaku z p©echodn‚ho bufferu

         mov       al,0
         xchg      al,ds:[BuffChr]          ; uschovan˜ znak
         cmp       al,0                     ; byl nˆjak˜ znak ?
         jne       InpChr9                  ; byl nˆjak˜ znak

; ------ test, zda je dal¨¡ znak

         cmp       si,ds:[BuffEnd]          ; jsou dal¨¡ data ?
         jb        InpChr4                  ; jsou nˆjak  data
         call      ReadBuff                 ; na‡ten¡ bufferu
         mov       al,0                     ; neplatn˜ znak
         jc        InpChr9                  ; konec nebo chyba

; ------ na‡ten¡ znaku z bufferu

InpChr4: cld
         lodsb                              ; na‡ten¡ znaku
         clc                                ; p©¡znak operace OK
InpChr9: ret

InpChr   ENDP

; -----------------------------------------------------------------------------
;        navr cen¡ znaku do vstupn¡ho bufferu
; -----------------------------------------------------------------------------

RetChr   PROC      NEAR

         mov       ds:[BuffChr],al          ; navr cen¡ znaku
         ret

RetChr   ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ obsahu vstupn¡ho bufferu (CY=konec)
; -----------------------------------------------------------------------------

ReadBuff PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx

         mov       dx,offset Buffer         ; vstupn¡ bufferu
         mov       si,dx                    ; SI <- adresa za‡ tku bufferu
         mov       cx,BuffSize              ; velikost vstupn¡ho bufferu
         mov       ah,3fh
         mov       bx,ds:[SoubIdnt]         ; identifik tor souboru
         int       21h                      ; na‡ten¡ vstupn¡ho bufferu

         jnc       ReadBuf2
         xor       ax,ax                    ; nic nena‡teno
ReadBuf2:or        ax,ax                    ; bylo nˆco na‡teno ?
         stc                                ; p©¡znak chyby
         jz        ReadBuf5                 ; konec souboru
         add       ax,si                    ; adresa konce bufferu
         mov       ds:[BuffEnd],ax          ; adresa konce bufferu

ReadBuf5:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ReadBuff ENDP

; *****************************************************************************
;
;                           Obsluha paketu
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        v˜pis textu SI (podle nastaven˜ch parametr–)
; -----------------------------------------------------------------------------
; lok ln¡ promˆnn‚: SS:[BP-2] (2) ukazatel textu SI
;                   SS:[BP-6] (4) ukazatel sou©adnice X po‡ tku © dku
;                   SS:[BP-10] (4) ukazatel sou©adnice Y po‡ tku © dku
;                   SS:[BP-14] (4) ukazatel aktu ln¡ sou©adnice znak– X
;                   SS:[BP-18] (4) ukazatel aktu ln¡ sou©adnice znak– Y
;                   SS:[BP-20] (2) smˆrnice textu X
;                   SS:[BP-22] (2) smˆrnice textu Y
;                   SS:[BP-24] (2) d‚lka smˆrn¡ku (v rozsahu 1000h a‘ 7fffh)
;                   SS:[BP-26] (2) p©¡rustek X se smˆrn¡kem
;                   SS:[BP-28] (2) p©¡rustek Y se smˆrn¡kem
;                   SS:[BP-30] (2) po‡et bod– na krok p¡smene (vodorovn  pozice)
;                   SS:[BP-32] (2) ukazatel definice znaku
;                   SS:[BP-33] (1) ‡¡ta‡ bod– definice znaku
;                   SS:[BP-34] (1)
;                   SS:[BP-36] (2) horizont ln¡ posun (bod–)
;                   SS:[BP-38] (2) vertik ln¡ posun (bod–)
; -----------------------------------------------------------------------------

Text     PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      bp
         mov       bp,sp
         sub       sp,38

; ------ inicializace lok ln¡ch promˆnn˜ch

         mov       ss:[bp-2],si             ; ukazatel textu
         call      GetAbs                   ; poskytnut¡ aktu ln¡ sou©adnice
         mov       ss:[bp-6+2],dx
         mov       ss:[bp-6],ax             ; ukazatel sou©adnice X po‡ tku
         mov       ss:[bp-10+2],bx
         mov       ss:[bp-10],cx            ; ukazatel sou©adnice Y po‡ tku

; ------ inicializace ukazatele sou©adnic

         mov       ax,ss:[bp-6]
         mov       ss:[bp-14],ax
         mov       ax,ss:[bp-6+2]
         mov       ss:[bp-14+2],ax
         mov       ax,ss:[bp-10]
         mov       ss:[bp-18],ax
         mov       ax,ss:[bp-10+2]
         mov       ss:[bp-18+2],ax

; ------ p©¡prava smˆrnice textu

         mov       ax,word ptr ds:[TextSmX] ; smˆrnice X
         mov       dx,word ptr ds:[TextSmX+2]
         mov       cx,word ptr ds:[TextSmY] ; smˆrnice Y
         mov       bx,word ptr ds:[TextSmY+2]

; ------ omezen¡ smˆrnice shora

Text2:   or        dx,dx
         jnz       Text21
         cmp       ax,4000h
         jae       Text24
         jmp       short Text22

Text21:  cmp       dx,-1
         jne       Text24
         cmp       ax,-4000h
         jbe       Text24

Text22:  or        bx,bx
         jnz       Text23
         cmp       cx,4000h
         jae       Text24
         jmp       short Text25

Text23:  cmp       bx,-1
         jne       Text24
         cmp       cx,-4000h
         ja        Text25

Text24:  sar       dx,1
         rcr       ax,1
         sar       bx,1
         rcr       cx,1
         jmp       short Text2

; ------ omezen¡ smˆrnice zdola

Text25:  mov       dx,ax
         or        dx,cx
         jnz       Text26
         inc       ax                       ; implicitn¡ smˆrnice smˆrem X

Text26:  cmp       ax,1000h
         jge       Text28
         cmp       ax,-1000h
         jg        Text27
         cmp       cx,1000h
         jge       Text28
         cmp       cx,-1000h
         jle       Text28
Text27:  shl       ax,1
         shl       cx,1
         jmp       short Text26

Text28:  mov       ss:[bp-20],ax            ; smˆrnice textu X
         mov       ss:[bp-22],cx            ; smˆrnice textu Y

; ------ smˆrnice textu X*X

         imul      ax                       ; smˆrnice textu X*X

; ------ smˆrnice textu Y*Y

         xchg      ax,cx
         mov       bx,dx
         imul      ax                       ; smˆrnice textu Y*Y

; ------ sou‡et X*X + Y*Y

         add       ax,cx
         adc       dx,bx

; ------ v˜po‡et d‚lky smˆrn¡ku (je v rozsahu asi tak 1000h a‘ 7fffh)

         call      OdmNum                   ; odmocnina ‡¡sla * 65K
         or        dx,dx
         jnz       Text29
         inc       dx
Text29:  mov       ss:[bp-24],dx            ; d‚lka smˆrn¡ku

; ------ p©¡rustek X se smˆrn¡kem

         mov       cx,dx                    ; CX <- d‚lka smˆrn¡ku
         xor       bx,bx
         mov       ax,ss:[bp-20]            ; smˆrnice textu X
         cwd
         idiv      cx                       ; v˜po‡et p©¡rustku X
         mov       ss:[bp-26],ax            ; p©¡rustek X se smˆrn¡kem

; ------ p©¡rustek Y se smˆrn¡kem

         mov       ax,ss:[bp-22]            ; smˆrnice textu Y
         cwd
         idiv      cx                       ; v˜po‡et p©¡rustku Y
         mov       ss:[bp-28],ax            ; p©¡rustek Y se smˆrn¡kem

; ------ po‡et bod– na krok p¡smene

         mov       ax,ds:[TextSir]          ; ¨¡©ka textu (bod–)
         add       ax,11
         mov       bx,12
         cwd
         idiv      bx
         mov       ss:[bp-30],ax            ; po‡et bod– na krok p¡smene

; ------ na‡ten¡ dal¨¡ho znaku k zobrazen¡

Text3:   mov       si,ss:[bp-2]             ; ukazatel textu
         call      InpChr                   ; na‡ten¡ dal¨¡ho znaku
         mov       ss:[bp-2],si             ; nov˜ ukazatel textu
         jnc       Text34

Text32:  jmp       Text9

Text34:  cmp       al,ds:[EOTChr]
         je        Text32

; ------ n vrat ukazatele na za‡ tek © dku CR

         cmp       al,0Dh
         jne       Text4
         call      PenUp                    ; zvednut¡ pera
         mov       ax,ss:[bp-6]             ; sou©adnice X po‡ tku © dku
         mov       dx,ss:[bp-6+2]
         mov       cx,ss:[bp-10]            ; sou©adnice Y po‡ tku © dku
         mov       bx,ss:[bp-10+2]
         call      MoveAbs                  ; p©esun pera na pozici

; ------ n vrat ukazatele znak–

         mov       ss:[bp-14],ax
         mov       ss:[bp-14+2],dx
         mov       ss:[bp-18],cx
         mov       ss:[bp-18+2],bx
         jmp       short Text3              ; dal¨¡ znak

; ------ p©esun ukazatele na dal¨¡ © dek LF

Text4:   cmp       al,0Ah
         jne       Text5

; ------ vyn soben¡: v˜¨ka znak– * smˆrn¡k






; ------ kontrola povolen˜ch znak–

Text5:   sub       al,32                    ; minim ln¡ povolen˜ znak
         jc        Text51                   ; zak zan˜ znak - ignoruje se
         cmp       al,127-32                ; maxim ln¡ povolen˜ znak
         jbe       Text52                   ; znak vyhovuje

Text51:  jmp       Text8                    ; znak nepovolen - dal¨¡

; ------ adresa znaku v defini‡n¡ tabulce znak–

Text52:  mov       si,offset TabChr
         mov       ah,0
         mov       cx,ax
         jcxz      Text54
         cld
Text53:  lodsb
         add       si,ax
         add       si,ax
         loop      Text53
Text54:  lodsb
         mov       ss:[bp-32],si            ; ukazatel definice znaku
         mov       ss:[bp-33],al            ; ‡¡ta‡ bod– definice znaku

; ------ test, zda je dal¨¡ bod

Text6:   cmp       byte ptr ss:[bp-33],0    ; je dal¨¡ bod ?
         jne       Text62                   ; je dal¨¡ bod
Text61:  jmp       Text8                    ; dal¨¡ znak na © dku

; ------ nastaven¡ pera

Text62:  mov       al,ds:[si]
         mov       di,offset PovelDwn       ; povel pro spu¨tˆn¡ pera
         test      al,80h                   ; m  b˜t pero zvednuto ?
         jz        Text63                   ; pero m  b˜t spu¨tˆno
         mov       di,offset PovelUp        ; povel pro zvednut¡ pera
Text63:  call      OutPovel                 ; vysl n¡ povelu pro nastaven¡ pera

; ------ vodorovn˜ posun pera

         and       ax,7fh                   ; vodorovn˜ posun pera
         mul       word ptr ds:[TextSir]    ; vodorovn˜ posun pera
         mov       cx,5
         xor       bx,bx
         call      MulDWrd                  ; * 5
         mov       cx,300h
         call      DivDWrd                  ; /300h
         mov       ss:[bp-36],ax            ; horizont ln¡ posun

; ------ svisl˜ posun pera

         mov       al,ds:[si+1]             ; svisl˜ posun pera
         cwd
         mul       word ptr ds:[TextVys]    ; svisl˜ posun pera
         mov       cx,80h
         call      DivDWrd                  ; /80h
         mov       ss:[bp-38],ax            ; vertik ln¡ posun

; ------ ze¨ikmen¡ p¡sma

         mov       cl,5                     ; ze¨ikmen¡ p¡sma
         div       cx                       ; svisl  pozice / 5
         test      byte ptr ds:[Param],bit6 ; je p¡smo Italic ?
         jnz       Text64                   ; je Italic
         xor       ax,ax                    ; nen¡ ze¨ikmen¡
Text64:  add       ax,ss:[bp-30]            ; aktu ln¡ vodorovn  pozice
         add       ss:[bp-36],ax            ; oprava vodorvn‚ho posunu

; ------ vodorovn˜ p©¡rustek X

         mov       ax,ss:[bp-36]            ; vodorovn˜ posun
         mul       word ptr ss:[bp-26]      ; * p©¡rustek X se smˆrn¡kem
         xchg      ax,cx
         mov       bx,dx
         mov       ax,ss:[bp-38]            ; vertik ln¡ posun
         mul       word ptr ss:[bp-28]      ; * p©¡rustek Y se smˆrn¡kem
         sub       cx,ax
         sbb       bx,dx














; ------ p©¡prava pro dal¨¡ bod p¡smene

Text7:   add       word ptr ss:[bp-32],2    ; zv˜¨en¡ ukazatele definice znak–
         dec       byte ptr ss:[bp-33]      ; sn¡‘en¡ ‡¡ta‡e znak–
         jmp       Text6                    ; dal¨¡ bod p¡smene

; ------ p©¡prava pro dal¨¡ znak na © dku

Text8:



; ------ n vrat registr–

Text9:   mov       si,ss:[bp-2]             ; ukazatel textu
         mov       sp,bp
         pop       bp
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Text     ENDP

; -----------------------------------------------------------------------------
;        vykreslen¡ oblouku (DX:AX=st©ed X, BX:CX=st©ed Y, DI=£hel)
; -----------------------------------------------------------------------------
; lok ln¡ promˆnn‚: SS:[BP-2] (2) zadan˜ £hel oblouku (absolutn¡ hodnota)
;
;                   SS:[BP-4] (2) zadan˜ st©ed X HIGH
;                   SS:[BP-6] (2) zadan˜ st©ed X LOW
;                   SS:[BP-8] (2) zadan˜ st©ed Y HIGH
;                   SS:[BP-10] (2) zadan˜ st©ed Y LOW
;
;                   SS:[BP-12] (2) v˜choz¡ bod X HIGH
;                   SS:[BP-14] (2) v˜choz¡ bod X LOW
;                   SS:[BP-16] (2) v˜choz¡ bod Y HIGH
;                   SS:[BP-18] (2) v˜choz¡ bod Y LOW
;
;                   SS:[BP-20] (2) relativn¡ ukazatel X
;                   SS:[BP-22] (2) relativn¡ ukazatel Y
;                   SS:[BP-24] (2) polomˆr oblouku
;
;                   SS:[BP-26] (2) p©¡rustek £hlu (1=kladn˜ smˆr, -1=z porn˜)
;
;                   SS:[BP-30] (4) pomˆrn  ‡ st £hlu oblouku (polomˆr*8*£hel/360)
;                   SS:[BP-32] (2) SI
;
;                   SS:[BP-34] (2) relativn¡ posun X (p©i jednom kroku)
;                   SS:[BP-36] (2) relativn¡ posun Y (p©i jednom kroku)
;                   SS:[BP-38] (2) pomocn  promˆnn  X (2*X + SI + 1)
;                   SS:[BP-40] (2) pomocn  promˆnn  Y (2*Y + SI + 1)
;                   SS:[BP-42] (2) pomocn  promˆnn  X+Y (2*X + 2*Y + SI + 2)
;                   SS:[BP-44] (2) absolutn¡ hodnota promˆnn‚ X (2*X + SI + 1)
;                   SS:[BP-46] (2) absolutn¡ hodnota promˆnn‚ Y (2*Y + SI + 1)
;                   SS:[BP-48] (2) absolutn¡ hodnota promˆnn‚ X+Y (2*X+2*Y+SI+2)
;                   SS:[BP-50] (2) st©ada‡ posunu X
;                   SS:[BP-52] (2) st©ada‡ posunu Y
;                   SS:[BP-53] (1) po‡et krok– pro posun
;                   SS:[BP-54] (1) ‡¡ta‡ krok– pro posun
; -----------------------------------------------------------------------------

Oblouk   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         mov       bp,sp
         sub       sp,54

; ------ rozli¨en¡ smˆru kreslen¡ oblouku

         mov       word ptr ss:[bp-26],1    ; kladn˜ smˆr kreslen¡
         or        di,di                    ; je kladn˜ £hel ?
         jns       Oblouk11                 ; je kladn˜ £hel
         neg       di                       ; oprava znam‚nka
         neg       word ptr ss:[bp-26]      ; je z porn˜ smˆr kreslen¡

; ------ omezen¡ velikosti £hlu na -360 a‘ +360

Oblouk11:cmp       di,360
         jb        Oblouk12
         mov       di,360
Oblouk12:mov       ss:[bp-2],di             ; zadan˜ £hel oblouku

; ------ inicializace lok ln¡ch promˆnn˜ch

         mov       ss:[bp-4],dx             ; st©ed X HIGH
         mov       ss:[bp-6],ax             ; st©ed X LOW
         mov       ss:[bp-8],bx             ; st©ed Y HIGH
         mov       ss:[bp-10],cx            ; st©ed Y LOW

; ------ aktu ln¡ pozice

         call      GetAbs                   ; poskytnut¡ aktu ln¡ pozice
         mov       ss:[bp-12],dx            ; v˜choz¡ bod X HIGH
         mov       ss:[bp-14],ax            ; v˜choz¡ bod X LOW
         mov       ss:[bp-16],bx            ; v˜choz¡ bod Y HIGH
         mov       ss:[bp-18],cx            ; v˜choz¡ bod Y LOW

; ------ vzd lenost v˜choz¡ho bodu od st©edu

         sub       ax,ss:[bp-6]             ; vzd lenost od st©edu X
         mov       ss:[bp-20],ax            ; relativn¡ ukazatel X
         sub       cx,ss:[bp-10]            ; vzd lenost od st©edu Y
         mov       ss:[bp-22],cx            ; relativn¡ ukazatel Y

; ------ v˜po‡et polomˆru oblouku (odmocnina ze sou‡tu X*X + Y*Y)

         imul      ax                       ; vzd lenost X*X
         xchg      ax,cx                    ; AX <- vzd lenost X*X LOW
         mov       bx,dx                    ; BX <- vzd lenost X*X HIGH
         imul      ax                       ; vzd lenost Y*Y
         add       ax,cx                    ; sou‡et X*X + Y*Y
         adc       dx,bx
         call      OdmNum                   ; odmocnina z ‡¡sla
         mov       ss:[bp-24],dx            ; polomˆr oblouku
         or        dx,dx                    ; je polomˆr platn˜ ?
         jnz       Oblouk15
Oblouk16:jmp       Oblouk9

; ------ vyn soben¡ polomˆr * £hel * 8

Oblouk15:mov       ax,ss:[bp-2]             ; zadan˜ £hel
         or        ax,ax
         jz        Oblouk16                 ; £hel nula se nekresl¡
         mul       dx                       ; polomˆr * £hel
         shl       ax,1
         rcl       dx,1
         shl       ax,1
         rcl       dx,1
         shl       ax,1
         rcl       dx,1                     ; polomˆr * £hel * 8

; ------ vydˆlen¡ v˜sledku / 360 (=polomˆr * 8 * pomˆrn  ‡ st £hlu)

         mov       cx,360
         xor       bx,bx
         call      DivSDWrd                 ; v˜po‡et pomˆrn‚ ‡ sti £hlu
         mov       ss:[bp-30+2],dx          ; pomˆrn  ‡ st oblouku
         mov       ss:[bp-30],ax

; ------ spu¨tˆn¡ pera

         call      PenDown                  ; spu¨tˆn¡ pera
         mov       word ptr ss:[bp-32],0    ; registr SI

; ------ p©¡prava po‡tu krok– pro posun

         mov       ax,ss:[bp-24]            ; polomˆr oblouku
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; asi tak 8 krok–
         jnz       Oblouk13
         inc       ax                       ; minim lnˆ 1 krok
Oblouk13:cmp       ax,30                    ; maxim lnˆ 30 krok–
         jbe       Oblouk14
         mov       al,30                    ; maxim lnˆ 30 krok–
Oblouk14:mov       ss:[bp-53],al            ; po‡et krok– pro posun

; ------ p©¡prava ‡¡ta‡e krok–

Oblouk1: mov       al,ss:[bp-53]            ; po‡et krok– pro posun
         mov       ss:[bp-54],al            ; ‡¡ta‡ krok– pro posun
         mov       word ptr ss:[bp-50],0    ; nulov n¡ st©ada‡e posunu X
         mov       word ptr ss:[bp-52],0    ; nulov n¡ st©ada‡e posunu Y

; ------ test, zda je dal¨¡ £hel

Oblouk2: mov       ax,ss:[bp-30]            ; ‡¡ta‡ £hlu
         or        ax,ss:[bp-30+2]
         jnz       Oblouk21
         jmp       Oblouk8                  ; konec kreslen¡

; ------ p©¡prava p©¡rustku X

Oblouk21:mov       ax,ss:[bp-26]            ; smˆr p©¡rustku £hlu
         cmp       byte ptr ss:[bp-22+1],0  ; je kladn  ‡ st Y ?
         jl        Oblouk22                 ; je z porn  ‡ st Y
         neg       ax                       ; opa‡n˜ smˆr X
Oblouk22:mov       ss:[bp-34],ax            ; p©¡rustek X

; ------ pomocn  promˆnn  X (2*X + SI + 1)

         shl       ax,1                     ; smˆr * 2
         mul       word ptr ss:[bp-20]      ; p©¡rustek X * relativn¡ pozice X
         add       ax,ss:[bp-32]            ; p©i‡ten¡ SI
         inc       ax                       ; 2*X + SI + 1
         mov       ss:[bp-38],ax            ; pomocn  promˆnn  X

; ------ absolutn¡ hodnota pomocn‚ promˆnn‚ X

         or        ax,ax                    ; je to z porn‚ ‡¡slo ?
         jns       Oblouk23                 ; nen¡ to z porn‚ ‡¡slo
         neg       ax                       ; negace AX
Oblouk23:mov       ss:[bp-44],ax            ; absolutn¡ hodnota promˆnn‚ X

; ------ p©¡prava p©¡rustku Y

         mov       ax,ss:[bp-26]            ; smˆr p©¡rustku £hlu
         cmp       byte ptr ss:[bp-20+1],0  ; je kladn  ‡ st X ?
         jge       Oblouk24                 ; je kladn  ‡ st X
         neg       ax                       ; smˆr Y = -1
Oblouk24:mov       ss:[bp-36],ax            ; p©¡rustek Y

; ------ pomocn  promˆnn  Y (2*Y + SI + 1)

         shl       ax,1                     ; smˆr * 2
         mul       word ptr ss:[bp-22]      ; p©¡rustek Y * relativn¡ pozice Y
         add       ax,ss:[bp-32]            ; p©i‡ten¡ SI
         inc       ax                       ; 2*Y + SI + 1
         mov       ss:[bp-40],ax            ; pomocn  promˆnn  Y

; ------ absolutn¡ hodnota pomocn‚ promˆnn‚ Y

         or        ax,ax                    ; je to z porn‚ ‡¡slo ?
         jns       Oblouk25                 ; nen¡ to z porn‚ ‡¡slo
         neg       ax                       ; negace AX
Oblouk25:mov       ss:[bp-46],ax            ; absolutn¡ hodnota promˆnn‚ Y

; ------ pomocn  promˆnn  X+Y (2*X + 2*Y + SI + 2)

         mov       ax,ss:[bp-38]            ; pomocn  promˆnn  X
         add       ax,ss:[bp-40]            ; p©i‡ten¡ pomocn‚ promˆnn‚ Y
         sub       ax,ss:[bp-32]            ; - SI
         mov       ss:[bp-42],ax            ; pomocn  promˆnn  X+Y (2*X+2*Y+SI+2)

; ------ absolutn¡ hodnota pomocn‚ promˆnn‚ X + Y

         or        ax,ax                    ; je to z porn‚ ‡¡slo ?
         jns       Oblouk26                 ; nen¡ to z porn‚ ‡¡slo
         neg       ax                       ; negace AX
Oblouk26:mov       ss:[bp-48],ax            ; absolutn¡ hodnota promˆnn‚ X + Y

; ------ porovn n¡ pomocn‚ promˆnn‚ X a Y

         mov       ax,ss:[bp-46]            ; pomocn  promˆnn  Y
         cmp       ax,ss:[bp-44]            ; pomocn  promˆnn  X
         jge       Oblouk32

; ------ porovn n¡ pomocn‚ promˆnn‚ X+Y a Y

         cmp       ax,ss:[bp-48]            ; pomocn  promˆnn  X + Y
         jg        Oblouk32

; ------ nen¡ posun X

         mov       word ptr ss:[bp-34],0    ; nen¡ posun X
         mov       ax,ss:[bp-40]            ; pomocn  promˆnn  Y
         mov       ss:[bp-32],ax            ; nov  hodnota SI
         jmp       short Oblouk36

; ------ porovn n¡ pomocn‚ promˆnn‚ X a Y

Oblouk32:mov       ax,ss:[bp-44]            ; pomocn  promˆnn  X
         cmp       ax,ss:[bp-46]            ; pomocn  promˆnn  Y
         jg        Oblouk34

; ------ porovn n¡ pomocn‚ promˆnn‚ X+Y a X

         cmp       ax,ss:[bp-48]            ; pomocn  promˆnn  X + Y
         jg        Oblouk34

; ------ nen¡ posun Y

         mov       word ptr ss:[bp-36],0    ; nen¡ posun Y
         mov       ax,ss:[bp-38]            ; pomocn  promˆnn  X
         mov       ss:[bp-32],ax            ; registr SI
         jmp       short Oblouk36

; ------ posun ‡¡ta‡e £hlu o 1

Oblouk34:sub       word ptr ss:[bp-30],1
         sbb       word ptr ss:[bp-30+2],0

; ------ porovn n¡ pomocn‚ promˆnn‚ X+Y s X

         mov       ax,ss:[bp-48]            ; pomocn  promˆnn  X+Y
         cmp       ax,ss:[bp-44]            ; pomocn  promˆnn  X
         jge       Oblouk36

; ------ porovn n¡ pomocn‚ promˆnn‚ X+Y s Y

         cmp       ax,ss:[bp-46]            ; pomocn  promˆnn  Y
         jge       Oblouk36

; ------ SI <- X+Y

         mov       ax,ss:[bp-42]            ; pomocn  promˆnn  X+Y
         mov       ss:[bp-32],ax            ; nov  hodnota SI

; ------ zv˜¨en¡ ukazatele relativn¡ pozice

Oblouk36:mov       ax,ss:[bp-34]            ; p©¡rustek krok– X
         add       ss:[bp-50],ax            ; st©ada‡ posun– X
         add       ss:[bp-20],ax            ; ukazatel pozice X

         mov       ax,ss:[bp-36]            ; p©¡rustek krok– Y
         add       ss:[bp-52],ax            ; st©ada‡ posun– Y
         add       ss:[bp-22],ax            ; ukazatel pozice Y

; ------ ‡¡t n¡ posunu

         dec       byte ptr ss:[bp-54]      ; ‡¡ta‡ krok– pro posun
         jnz       Oblouk6                  ; nebude posun

; ------ relativn¡ posun pera na novou pozici

         mov       ax,ss:[bp-52]            ; st©ada‡ posun– Y
         cwd
         xchg      ax,cx
         mov       bx,dx
         mov       ax,ss:[bp-50]            ; st©ada‡ posun– X
         cwd
         call      MoveRel                  ; p©esun pera relativnˆ

; ------ posun ‡¡ta‡e £hlu

Oblouk6: mov       ax,ss:[bp-30]
         or        ax,ss:[bp-30+2]          ; je £hel ji‘ = 0 ?
         jz        Oblouk7
         sub       word ptr ss:[bp-30],1
         sbb       word ptr ss:[bp-30+2],0

Oblouk7: cmp       byte ptr ss:[bp-54],0    ; je nov˜ krok ?
         jne       Oblouk72                 ; nen¡ nov˜ krok
         jmp       Oblouk1                  ; dal¨¡ krok

Oblouk72:jmp       Oblouk2                  ; dal¨¡ bod

; ------ vykreslen¡ posledn¡ho kroku

Oblouk8: mov       ax,ss:[bp-52]            ; st©ada‡ posun– Y
         cwd
         xchg      ax,cx
         mov       bx,dx
         mov       ax,ss:[bp-50]            ; st©ada‡ posun– X
         cwd
         call      MoveRel                  ; p©esun pera relativnˆ

; ------ n vrat na v˜choz¡ pozici

         call      PenUp                    ; zvednut¡ pera
         mov       dx,ss:[bp-12]            ; st©ed X HIGH
         mov       ax,ss:[bp-14]            ; st©ed X LOW
         mov       bx,ss:[bp-16]            ; st©ed Y HIGH
         mov       cx,ss:[bp-18]            ; st©ed Y LOW
         call      MoveAbs                  ; p©esun na v˜choz¡ pozici

; ------ n vrat registr–

Oblouk9: mov       sp,bp
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Oblouk   ENDP

; -----------------------------------------------------------------------------
;        vykreslen¡ kru‘nice (DX:AX=st©ed X, BX:CX=st©ed Y, DI=polomˆr)
; -----------------------------------------------------------------------------
; lok ln¡ promˆnn‚: SS:[BP-2] (2) polomˆr kru‘nice
;                   SS:[BP-4] (2) st©ed X HIGH
;                   SS:[BP-6] (2) st©ed X LOW
;                   SS:[BP-8] (2) st©ed Y HIGH
;                   SS:[BP-10] (2) st©ed Y LOW
;                   SS:[BP-12] (2) relativn¡ ukazatel X
;                   SS:[BP-14] (2) relativn¡ ukazatel Y
;                   SS:[BP-16] (2) relativn¡ posun X (p©i jednom kroku)
;                   SS:[BP-18] (2) relativn¡ posun Y (p©i jednom kroku)
;                   SS:[BP-20] (2) pomocn  promˆnn  X (2*X + SI + 1)
;                   SS:[BP-22] (2) pomocn  promˆnn  Y (2*Y + SI + 1)
;                   SS:[BP-24] (2) pomocn  promˆnn  X+Y (2*X + 2*Y + SI + 2)
;                   SS:[BP-26] (2) absolutn¡ hodnota promˆnn‚ X (2*X + SI + 1)
;                   SS:[BP-28] (2) absolutn¡ hodnota promˆnn‚ Y (2*Y + SI + 1)
;                   SS:[BP-30] (2) absolutn¡ hodnota promˆnn‚ X+Y (2*X+2*Y+SI+2)
;                   SS:[BP-32] (2) st©ada‡ posunu X
;                   SS:[BP-34] (2) st©ada‡ posunu Y
;                   SS:[BP-35] (1) po‡et krok– pro posun
;                   SS:[BP-36] (1) ‡¡ta‡ krok– pro posun
; -----------------------------------------------------------------------------

Kruznice PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         mov       bp,sp
         sub       sp,36

; ------ inicializace lok ln¡ch promˆnn˜ch

         mov       ss:[bp-2],di             ; polomˆr
         mov       ss:[bp-4],dx             ; st©ed X HIGH
         mov       ss:[bp-6],ax             ; st©ed X LOW
         mov       ss:[bp-8],bx             ; st©ed Y HIGH
         mov       ss:[bp-10],cx            ; st©ed Y LOW
         mov       word ptr ss:[bp-12],0    ; relativn¡ ukazatel X
         mov       word ptr ss:[bp-14],di   ; relativn¡ ukazatel Y

; ------ p©esun pera na v˜choz¡ pozici (na horn¡m okraji kru‘nice)

         add       cx,di                    ; v˜choz¡ sou©adnice Y (+polomˆr)
         adc       bx,0
         call      PenUp                    ; zvednut¡ pera
         call      MoveAbs                  ; p©esun na v˜choz¡ pozici
         call      PenDown                  ; spu¨tˆn¡ pera

         xor       si,si                    ; pomocn  promˆnn 

; ------ p©¡prava po‡tu krok– pro posun

         xchg      ax,di
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; asi tak 8 krok–
         jnz       Kruzn12
         inc       ax                       ; minim lnˆ 1 krok
Kruzn12: cmp       ax,30                    ; maxim lnˆ 30 krok–
         jbe       Kruzn14
         mov       al,30                    ; maxim lnˆ 30 krok–
Kruzn14: mov       ss:[bp-35],al            ; po‡et krok– pro posun

; ------ p©¡prava ‡¡ta‡e krok–

Kruzn1:  mov       al,ss:[bp-35]            ; po‡et krok– pro posun
         mov       ss:[bp-36],al            ; ‡¡ta‡ krok– pro posun
         mov       word ptr ss:[bp-32],0    ; nulov n¡ st©ada‡e posunu X
         mov       word ptr ss:[bp-34],0    ; nulov n¡ st©ada‡e posunu Y

; ------ p©¡prava p©¡rustku X

Kruzn2:  mov       ax,1                     ; smˆr X = 1
         cmp       byte ptr ss:[bp-14+1],0  ; je kladn  ‡ st Y ?
         jl        Kruzn22                  ; je z porn  ‡ st Y
         neg       ax                       ; smˆr X = -1
Kruzn22: mov       ss:[bp-16],ax            ; p©¡rustek X

; ------ pomocn  promˆnn  X (2*X + SI + 1)

         shl       ax,1                     ; smˆr * 2
         mul       word ptr ss:[bp-12]      ; p©¡rustek X * relativn¡ pozice X
         add       ax,si                    ; p©i‡ten¡ SI
         inc       ax                       ; 2*X + SI + 1
         mov       ss:[bp-20],ax            ; pomocn  promˆnn  X

; ------ absolutn¡ hodnota pomocn‚ promˆnn‚ X

         or        ax,ax                    ; je to z porn‚ ‡¡slo ?
         jns       Kruzn23                  ; nen¡ to z porn‚ ‡¡slo
         neg       ax                       ; negace AX
Kruzn23: mov       ss:[bp-26],ax            ; absolutn¡ hodnota promˆnn‚ X

; ------ p©¡prava p©¡rustku Y

         mov       ax,1                     ; smˆr Y = 1
         cmp       byte ptr ss:[bp-12+1],0  ; je kladn  ‡ st X ?
         jge       Kruzn24                  ; je kladn  ‡ st X
         neg       ax                       ; smˆr Y = -1
Kruzn24: mov       ss:[bp-18],ax            ; p©¡rustek Y

; ------ pomocn  promˆnn  Y (2*Y + SI + 1)

         shl       ax,1                     ; smˆr * 2
         mul       word ptr ss:[bp-14]      ; p©¡rustek Y * relativn¡ pozice Y
         add       ax,si                    ; p©i‡ten¡ SI
         inc       ax                       ; 2*Y + SI + 1
         mov       ss:[bp-22],ax            ; pomocn  promˆnn  Y

; ------ absolutn¡ hodnota pomocn‚ promˆnn‚ Y

         or        ax,ax                    ; je to z porn‚ ‡¡slo ?
         jns       Kruzn25                  ; nen¡ to z porn‚ ‡¡slo
         neg       ax                       ; negace AX
Kruzn25: mov       ss:[bp-28],ax            ; absolutn¡ hodnota promˆnn‚ Y

; ------ pomocn  promˆnn  X+Y (2*X + 2*Y + SI + 2)

         mov       ax,ss:[bp-20]            ; pomocn  promˆnn  X
         add       ax,ss:[bp-22]            ; p©i‡ten¡ pomocn‚ promˆnn‚ Y
         sub       ax,si                    ; - SI
         mov       ss:[bp-24],ax            ; pomocn  promˆnn  X+Y (2*X+2*Y+SI+2)

; ------ absolutn¡ hodnota pomocn‚ promˆnn‚ X + Y

         or        ax,ax                    ; je to z porn‚ ‡¡slo ?
         jns       Kruzn26                  ; nen¡ to z porn‚ ‡¡slo
         neg       ax                       ; negace AX
Kruzn26: mov       ss:[bp-30],ax            ; absolutn¡ hodnota promˆnn‚ X + Y

; ------ porovn n¡ pomocn‚ promˆnn‚ X a Y

         mov       ax,ss:[bp-28]            ; pomocn  promˆnn  Y
         cmp       ax,ss:[bp-26]            ; pomocn  promˆnn  X
         jge       Kruzn32

; ------ porovn n¡ pomocn‚ promˆnn‚ X+Y a Y

         cmp       ax,ss:[bp-30]            ; pomocn  promˆnn  X + Y
         jg        Kruzn32

; ------ nen¡ posun X

         mov       word ptr ss:[bp-16],0    ; nen¡ posun X
         mov       si,ss:[bp-22]            ; pomocn  promˆnn  Y
         jmp       short Kruzn36

; ------ porovn n¡ pomocn‚ promˆnn‚ X a Y

Kruzn32: mov       ax,ss:[bp-26]            ; pomocn  promˆnn  X
         cmp       ax,ss:[bp-28]            ; pomocn  promˆnn  Y
         jg        Kruzn34

; ------ porovn n¡ pomocn‚ promˆnn‚ X+Y a X

         cmp       ax,ss:[bp-30]            ; pomocn  promˆnn  X + Y
         jg        Kruzn34

; ------ nen¡ posun Y

         mov       word ptr ss:[bp-18],0    ; nen¡ posun Y
         mov       si,ss:[bp-20]            ; pomocn  promˆnn  X
         jmp       short Kruzn36

; ------ porovn n¡ pomocn‚ promˆnn‚ X+Y s X

Kruzn34: mov       ax,ss:[bp-30]            ; pomocn  promˆnn  X+Y
         cmp       ax,ss:[bp-26]            ; pomocn  promˆnn  X
         jge       Kruzn36

; ------ porovn n¡ pomocn‚ promˆnn‚ X+Y s Y

         cmp       ax,ss:[bp-28]            ; pomocn  promˆnn  Y
         jge       Kruzn36

; ------ SI <- X+Y

         mov       si,ss:[bp-24]            ; pomocn  promˆnn  X+Y

; ------ zv˜¨en¡ ukazatele relativn¡ pozice

Kruzn36: mov       ax,ss:[bp-16]            ; p©¡rustek krok– X
         add       ss:[bp-32],ax            ; st©ada‡ posun– X
         add       ss:[bp-12],ax            ; ukazatel pozice X

         mov       ax,ss:[bp-18]            ; p©¡rustek krok– Y
         add       ss:[bp-34],ax            ; st©ada‡ posun– Y
         add       ss:[bp-14],ax            ; ukazatel pozice Y

; ------ ‡¡t n¡ posunu

         dec       byte ptr ss:[bp-36]      ; ‡¡ta‡ krok– pro posun
         jnz       Kruzn6                   ; nebude posun

; ------ relativn¡ posun pera na novou pozici

         mov       ax,ss:[bp-34]            ; st©ada‡ posun– Y
         cwd
         xchg      ax,cx
         mov       bx,dx
         mov       ax,ss:[bp-32]            ; st©ada‡ posun– X
         cwd
         call      MoveRel                  ; p©esun pera relativnˆ

; ------ test, zda bylo dosa‘eno v˜choz¡ pozice

Kruzn6:  cmp       word ptr ss:[bp-12],0    ; relativn¡ pozice X = 0 ?
         jne       Kruzn7
         mov       ax,ss:[bp-14]            ; relativn¡ pozice Y
         cmp       ax,ss:[bp-2]             ; je polomˆr ?
         je        Kruzn8                   ; jsou v¨echny body

Kruzn7:  cmp       byte ptr ss:[bp-36],0    ; je nov˜ krok ?
         jne       Kruzn72                  ; nen¡ nov˜ krok
         jmp       Kruzn1                   ; dal¨¡ krok

Kruzn72: jmp       Kruzn2                   ; dal¨¡ bod

; ------ vykreslen¡ posledn¡ho kroku

Kruzn8:  mov       ax,ss:[bp-34]            ; st©ada‡ posun– Y
         cwd
         xchg      ax,cx
         mov       bx,dx
         mov       ax,ss:[bp-32]            ; st©ada‡ posun– X
         cwd
         call      MoveRel                  ; p©esun pera relativnˆ

; ------ n vrat na pozici st©edu

         call      PenUp                    ; zvednut¡ pera
         mov       dx,ss:[bp-4]             ; st©ed X HIGH
         mov       ax,ss:[bp-6]             ; st©ed X LOW
         mov       bx,ss:[bp-8]             ; st©ed Y HIGH
         mov       cx,ss:[bp-10]            ; st©ed Y LOW
         call      MoveAbs                  ; p©esun na pozici st©edu

; ------ n vrat registr–

         mov       sp,bp
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Kruznice ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ v˜choz¡ pozice HOME
; -----------------------------------------------------------------------------

SetHome  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      di

; ------ zaji¨tˆn¡ zvednut¡ pera

         test      byte ptr ds:[Param],bit1 ; je pero zvednuto ?
         jnz       SetHome2                 ; pero je ji‘ zvednuto
         call      PenUp                    ; zvednut¡ pera

; ------ nulov n¡ posunut‚ho po‡ tku

SetHome2:xor       ax,ax
         mov       word ptr ds:[HomeX],ax
         mov       word ptr ds:[HomeX+2],ax
         mov       word ptr ds:[HomeY],ax
         mov       word ptr ds:[HomeY+2],ax

; ------ nulov n¡ okna

         call      NulWin                   ; nulov n¡ definice okna

; ------ posun na po‡ tek

         xor       dx,dx
         xor       bx,bx
         xor       cx,cx
         call      MoveAbs                  ; p©esun na inicializa‡n¡ pozici

; ------ vypr zdnˆn¡ buffer–

         call      FlshPakt                 ; vypr zdnˆn¡ paketu

; ------ n vrat registr–

         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

SetHome  ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ aktu ln¡ absolutn¡ sou©adnice DX:AX=X, BX:CX=Y
; -----------------------------------------------------------------------------

GetAbs   PROC      NEAR

         xor       ax,ax                    ; jako relativn¡ posun 0
         xor       bx,bx
         xor       cx,cx
         xor       dx,dx
                                          ;* pokra‡uje RelToAbs !!!
GetAbs   ENDP

; -----------------------------------------------------------------------------
;        p©evod relativn¡ch sou©adnic na absolutn¡
; -----------------------------------------------------------------------------

RelToAbs PROC      NEAR

; ------ v˜po‡et absolutn¡ pozice

         add       ax,word ptr ds:[AktX]    ; nov  aktu ln¡ pozice X
         adc       dx,word ptr ds:[AktX+2]
         add       cx,word ptr ds:[AktY]    ; nov  aktu ln¡ pozice Y
         adc       bx,word ptr ds:[AktY+2]

; ------ korekce o posunut˜ po‡ tek

         sub       ax,word ptr ds:[HomeX]
         sbb       dx,word ptr ds:[HomeX+2]
         sub       cx,word ptr ds:[HomeY]
         sbb       bx,word ptr ds:[HomeY+2]
         ret

RelToAbs ENDP

; -----------------------------------------------------------------------------
;                 Relativn¡ p©esun pera (ve zvolen‚m mˆ©¡tku)
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=po‘adovan˜ posun X
;        BX:CX=po‘adovan˜ posun Y
; -----------------------------------------------------------------------------

MoveRel  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx

; ------ p©esun na novou absolutn¡ pozici

         call      RelToAbs                 ; p©evod na absolutn¡ sou©adnice
         call      MoveAbs                  ; p©esun na absolutn¡ pozici

; ------ n vrat registr–

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

MoveRel  ENDP

; -----------------------------------------------------------------------------
;                 P©esun pera na absolutn¡ pozici (ve zvolen‚m mˆ©¡tku)
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=po‘adovan  sou©adnice X
;        BX:CX=po‘adovan  sou©adnice Y
; -----------------------------------------------------------------------------

MoveAbs  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx

; ------ korekce o posunut˜ po‡ tek

         add       ax,word ptr ds:[HomeX]
         adc       dx,word ptr ds:[HomeX+2]
         add       cx,word ptr ds:[HomeY]
         adc       bx,word ptr ds:[HomeY+2]

; ------ ulo‘en¡ nov˜ch sou©adnic

         mov       word ptr ds:[AktX],ax    ; aktu ln¡ sou©adnice X LOW
         mov       word ptr ds:[AktX+2],dx  ; aktu ln¡ sou©adnice X HIGH
         mov       word ptr ds:[AktY],cx    ; aktu ln¡ sou©adnice Y LOW
         mov       word ptr ds:[AktY+2],bx  ; aktu ln¡ sou©adnice Y HIGH

; ------ ode‡ten¡ po‡ tku okna

         sub       ax,word ptr ds:[MinXWin]
         sbb       dx,word ptr ds:[MinXWin+2]
         sub       cx,word ptr ds:[MinYWin]
         sbb       bx,word ptr ds:[MinYWin+2]

; ------ p©epo‡et mˆ©¡tka X

         push      bx
         push      cx
         xor       bx,bx
         mov       cx,ds:[NasXZoom]         ; n sobek mˆ©¡tka X
         call      MulSDWrd                 ; vyn soben¡ mˆ©¡tkem
         mov       cx,ds:[DelXZoom]         ; dˆlitel mˆ©¡tka X
         call      DivSDWrd
         pop       cx
         pop       bx

; ------ p©epo‡et mˆ©¡tka Y

         push      ax
         push      dx
         xchg      ax,cx
         xchg      dx,bx
         xor       bx,bx
         mov       cx,ds:[NasYZoom]         ; n sobek mˆ©¡tka Y
         call      MulSDWrd                 ; vyn soben¡ mˆ©¡tkem
         mov       cx,ds:[DelYZoom]         ; dˆlitel mˆ©¡tka Y
         call      DivSDWrd
         xchg      ax,cx
         xchg      dx,bx
         pop       dx
         pop       ax

; ------ p©i‡ten¡ po‡ tku podokna

         add       ax,word ptr ds:[MinXZoom]
         adc       dx,word ptr ds:[MinXZoom+2]
         add       cx,word ptr ds:[MinYZoom]
         adc       bx,word ptr ds:[MinYZoom+2]

; ------ p©epo‡et sou©adnice X na intern¡ mˆ©¡tko

         call      AbsToZap                 ; p©epo‡et na intern¡ mˆ©¡tko X

; ------ p©epo‡et sou©adnice Y na intern¡ mˆ©¡tko

         xchg      ax,cx
         xchg      dx,bx
         call      AbsToZap                 ; p©epo‡et na intern¡ mˆ©¡tko Y
         xchg      ax,cx
         xchg      dx,bx

; ------ posun na po‘adovanou pozici

         sub       ax,word ptr ds:[SkutX]   ; odchylka od skute‡n‚ sou©adnice X
         sbb       dx,word ptr ds:[SkutX+2]
         sub       cx,word ptr ds:[SkutY]   ; odchylka od skute‡n‚ sou©adnice Y
         sbb       bx,word ptr ds:[SkutY+2]
         call      MoveZap                  ; p©esun pera zapisova‡e

; ------ n vrat registr–

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

MoveAbs  ENDP

; -----------------------------------------------------------------------------
;        p©epo‡et absolutn¡ch sou©adnic DX:AX na sou©adnice zapisova‡e DX:AX
; -----------------------------------------------------------------------------

AbsToZap PROC      NEAR

         push      bx
         push      cx
         xor       bx,bx                    ; BX <- 0

         mov       cx,ds:[NasMer]           ; n sobitel mˆ©¡tka
         call      MulSDWrd                 ; vyn soben¡ mˆ©¡tka
         mov       cx,ds:[DelMer]           ; dˆlitel mˆ©¡tka
         call      DivSDWrd                 ; vydˆlen¡ mˆ©¡tka

         mov       cx,ds:[NasKrok]          ; n sobitel mˆ©¡tka krokov n¡
         call      MulSDWrd                 ; vyn soben¡ mˆ©¡tka
         mov       cx,ds:[DelKrok]          ; dˆlitel mˆ©¡tka krokov n¡
         call      DivSDWrd                 ; vydˆlen¡ mˆ©¡tka

         pop       cx
         pop       bx
         ret

AbsToZap ENDP

; -----------------------------------------------------------------------------
;       Posun pera zapisova‡e relativnˆ v intern¡m mˆ©¡tku (skute‡n‚ kroky)
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=posun pera ve smˆru X
;        BX:CX=posun pera ve smˆru Y
; -----------------------------------------------------------------------------

MoveZap  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      di

; ------ posun ukazatele skute‡n˜ch sou©adnic

         add       word ptr ds:[SkutX],ax   ; posun skute‡n‚ sou©adnice X
         adc       word ptr ds:[SkutX+2],dx
         add       word ptr ds:[SkutY],cx   ; posun skute‡n‚ sou©adnice X
         adc       word ptr ds:[SkutY+2],bx

; ------ zaji¨tˆn¡ rotace v˜kresu

         test      byte ptr ds:[Param],bit3 ; je rotace v˜kresu ?
         jz        MoveZap2                 ; nen¡ rotace v˜kresu
         call      NegNum                   ; negace smˆru X
         xchg      ax,cx                    ; z mˆna smˆr– X a Y
         xchg      dx,bx

; ------ dek¢dov n¡ posunu ve smˆru X

MoveZap2:push      bx

         mov       di,offset PovelMov+2     ; buffer k ulo‘en¡ posun–
         call      DekSNum                  ; dek¢dov n¡ posunu X
         mov       bh,bl                    ; BH <- po‡et ‡¡slic X

         pop       dx                       ; DX <- posun ve smˆru Y HIGH

; ------ dek¢dov n¡ posunu ve smˆru Y

         xchg      ax,cx                    ; AX <- posun ve smˆru Y LOW
         call      DekSNum                  ; dek¢dov n¡ ‡¡sla

; ------ stanoven¡ k¢du pro posun

         shl       bl,1                     ; po‡et ‡¡slic Y
         shl       bl,1
         shl       bl,1
         or        bl,bh                    ; offset v tabulce k¢d–
         mov       bh,0                     ; BX = index v tabulce povel–
         mov       al,ds:[bx+TabDelt]       ; tabulka Delta-povel–
         cmp       al,0                     ; je nˆjak˜ posun ?
         je        MoveZap9                 ; neplatn˜ smˆr
         mov       ds:[PovelMov+1],al       ; delta povel

; ------ vysl n¡ povelu

         xchg      ax,di                    ; AX <- konec dek¢dovan˜ch ‡¡sel
         sub       ax,offset PovelMov+1     ; d‚lka povelu
         mov       di,offset PovelMov
         mov       ds:[di],al               ; d‚lka povelu
         call      OutPovel                 ; vysl n¡ povelu pro posun

; ------ n vrat registr–

MoveZap9:pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

MoveZap  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ ‡¡sla DX:AX se znam‚nkem do bufferu DI
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=‡¡slo
;        DI=buffer
; VSTUP: BL=bit 0 a‘ bit 1 po‡et znak–, bit 2 znam‚nko
;         DI=nov  adresa v bufferu (je-li ‡¡slo 0, nic se nedek¢duje)
; -----------------------------------------------------------------------------

DekSNum  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si

; ------ stanoven¡ znam‚nka, absolutn¡ hodnota ‡¡sla

         mov       si,di                    ; SI <- adresa bufferu
         mov       bl,0                     ; kladn‚ znam‚nko
         or        dx,dx                    ; je z porn‚ ‡¡slo ?
         jns       DekSNum1                 ; je kladn‚ ‡¡slo
         call      NegNum                   ; negace ‡¡sla
         mov       bl,bit2                  ; je z porn‚ ‡¡slo

; ------ omezen¡ velikosti ‡¡sla (na 64^3-1 = 3ffffh = 262143)

DekSNum1:cmp       dx,4
         jb        DekSNum2
         mov       ax,0ffffh                ; omezen¡ velikosti ‡¡sla
         mov       dx,4

; ------ test, zda je ‡¡slo ji‘ = 0

DekSNum2:or        ax,ax
         jnz       DekSNum3                 ; ‡¡slo je¨tˆ nen¡ = 0
         or        dx,dx
         jz        DekSNum9                 ; ‡¡slo je ji‘ = 0

; ------ ulo‘en¡ dal¨¡ho znaku do bufferu

DekSNum3:push      si
         mov       cl,al                    ; CL <- dal¨¡ znak
         and       cl,3fh                   ; ‡¡slo omezeno na 63
         dec       si
DekSNum4:inc       si
         xchg      cl,ds:[si]               ; z mˆna ‡¡sla
         cmp       si,di
         jb        DekSNum4
         pop       si
         inc       di                       ; zv˜¨en¡ koncov‚ adresy ‡¡sla
         inc       bx                       ; zv˜¨en¡ ‡¡ta‡e znak–

; ------ rotace ‡¡sla

         shr       dx,1
         rcr       ax,1
         shr       dx,1
         rcr       ax,1
         mov       cl,4
         shr       ax,cl
         jmp       short DekSNum2           ; dal¨¡ ‡¡slice

; ------ n vrat registr–

DekSNum9:pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DekSNum  ENDP

; -----------------------------------------------------------------------------
;        z pis povelu DI do bufferu paketu (1. bajt = d‚lka povelu)
; -----------------------------------------------------------------------------

OutPovel PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      si
         push      di

; ------ test, zda bude buffer ji‘ pln˜

         mov       si,di
         mov       ch,0
         mov       cl,ds:[si]               ; d‚lka textu
         jcxz      OutPovl9                 ; pr zdn  zpr va
         inc       si

         mov       ax,ds:[WritPak]          ; ukl dac¡ adresa do bufferu
         add       ax,cx                    ; nov  ukl dac¡ adresa do paketu
         cmp       ax,offset BuffPak+PAKSIZE ; bylo by p©eplnˆn¡ bufferu ?
         jb        OutPovl1                 ; nebylo by p©eplnˆn¡ bufferu

; ------ vypr zdnˆn¡ bufferu paketu

         call      OutPaket                 ; vypr zdnˆn¡ bufferu

; ------ ulo‘en¡ povelu do bufferu paketu

OutPovl1:cld
         mov       di,ds:[WritPak]          ; ukl dac¡ adresa do bufferu
OutPovl2:lodsb                              ; na‡ten¡ znaku zpr vy
         add       al,20h                   ; korekce hodnoty
         stosb                              ; ulo‘en¡ znaku zpr vy
         loop      OutPovl2                 ; dal¨¡ znak
         mov       ds:[WritPak],di          ; nov  ukl dac¡ adresa do bufferu

; ------ n vrat registr–

OutPovl9:pop       di
         pop       si
         pop       cx
         pop       ax
         ret

OutPovel ENDP

; -----------------------------------------------------------------------------
;        vymaz n¡ paketu
; -----------------------------------------------------------------------------

NulPaket PROC      NEAR

         push      ax
         push      cx
         push      di

         mov       di,offset BuffPak        ; buffer paketu
         mov       cx,PAKSIZE               ; velikost paketu
         mov       al," "                   ; mazac¡ znak
         cld
         rep       stosb                    ; vymaz n¡ paketu
         mov       word ptr ds:[WritPak],offset BuffPak+1 ; ukl dac¡ adresa

         pop       di
         pop       cx
         pop       ax
         ret

NulPaket ENDP

; -----------------------------------------------------------------------------
;        vypr zdnˆn¡ paketu
; -----------------------------------------------------------------------------

FlshPakt PROC      NEAR

         cmp       word ptr ds:[WritPak],offset BuffPak+1 ; je nˆco v bufferu ?
         je        FlshPak2                 ; nen¡ nic v bufferu
         call      OutPaket                 ; vysl n¡ paketu
FlshPak2:ret

FlshPakt ENDP

; -----------------------------------------------------------------------------
;        vysl n¡ paketu na port COM
; -----------------------------------------------------------------------------

OutPaket PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      si
         push      bp

; ------ vysl n¡ synchroniza‡n¡ch znak–

         call      InpFlush                 ; vypr zdnˆn¡ vstupu

OutPakt1:mov       al,ZNAKSYN               ; synchroniza‡n¡ znak
         call      OutByte                  ; v˜stup 1. znaku na port
         call      OutByte                  ; v˜stup 2. znaku na port

; ------ p©¡prava k vysl n¡ paketu

         mov       ah,0                     ; st©ada‡ kontroln¡ho sou‡tu
         mov       si,offset BuffPak        ; buffer paketu
         mov       cx,PAKSIZE               ; d‚lka paketu

; ------ vysl n¡ textu zpr vy paketu

OutPakt2:cld
         lodsb                              ; bajt k vysl n¡
         add       ah,al                    ; kontroln¡ sou‡et
         call      OutByte                  ; vysl n¡ bajtu na port COM
         loop      OutPakt2                 ; dal¨¡ bajt paketu

; ------ vysl n¡ kontroln¡ho sou‡tu zpr vy

         mov       al,ah                    ; kontroln¡ sou‡et
         neg       al                       ; doplnˆk kontroln¡ho sou‡tu
         and       al,1fh                   ; zarovn n¡ MODULO 32
         add       al,40h                   ; korekce hodnoty
         call      OutByte                  ; vysl n¡ kontroln¡ho sou‡tu

; ------ vysl n¡ znaku ukon‡en¡ zpr vy

         call      InpFlush                 ; vypr zdnˆn¡ vstupu

         mov       al,ZNAKEOT               ; znak konce textu zpr vy
         call      OutByte                  ; vysl n¡ znaku konce textu zpr vy

         mov       cx,9
         call      CekTime

         call      InpFlush                 ; vypr zdnˆn¡ vstupu

; ------ vysl n¡ v˜zvy k potvrzen¡ p©¡jmu

OutPak24:;mov       bp,3                     ; ‡¡ta‡ pokus– o p©¡jem

OutPak26:mov       al,VYZVA                 ; znak v˜zvy k potvrzen¡ p©¡jmu
         call      OutByte                  ; vysl n¡ v˜zvy k potvrzen¡

; ------ ‡ek n¡ na potvrzen¡ operace

OutPakt3:call      InpByte                  ; ‡ek n¡ na p©¡jem znaku
         jnc       OutPakt7                 ; bylo nˆco p©ijato

; ------ dal¨¡ pokus p©i chybˆ

;         dec       bp
;         jnz       OutPak26                 ; dal¨¡ pokus

; ------ hl ¨en¡ TIME-OUT

OutPakt4:mov       si,offset InpCek         ; chybov‚ hl ¨en¡
         call      DispTxt                  ; zobrazen¡ hl ¨en¡

; ------ ‡ek n¡ na zad n¡ znaku

         mov       ax,0c01h
         int       21h                      ; vstup znaku z kl vesnice

; ------ od© dkov n¡ textu

         mov       si,offset CRTxt
         call      DispTxt                  ; od© dkov n¡ textu

; ------ konverze znaku na velk‚ p¡smeno

         call      UpCase                   ; konverze na velk‚ p¡smeno

; ------ pokra‡ov n¡ v ‡ek n¡

         cmp       al,"D"
         je        OutPak24                 ; pokra‡ov n¡ v ‡ek n¡

; ------ p©eru¨en¡ operace

         cmp       al,27
         jne       OutPakt6
         jmp       Chyba0                   ; p©eru¨en¡ operace

; ------ vysl n¡ v˜zvy

OutPakt6:cmp       al,"V"
         jne       OutPakt4                 ; neplatn˜ znak - opakov n¡ zad n¡
         call      NulPaket                 ; vynulov n¡ paketu
         mov       di,offset InitPak        ; inicializa‡n¡ data paketu
         call      OutPovel                 ; z pis povelu
         jmp       OutPakt1                 ; vysl n¡ v˜zvy

; ------ ‡ek n¡ na p©ipravenost zapisova‡e

OutPakt7:cmp       al,CEKEJ                 ; je ‡ek n¡ ?
         je        OutPak24                 ; je ‡ek n¡

; ------ chyba p©¡jmu

OutPakt8:cmp       al,PRIJCHYB              ; je chyba p©¡jmu ?
         jne       OutPakt9                 ; nen¡ chyba p©¡jmu
         jmp       OutPakt1                 ; opakov n¡ vys¡l n¡

; ------ potvrzen¡ p©¡jmu

OutPakt9:cmp       al,PRIJEMOK              ; byl p©¡jem OK ?
         jne       OutPakt3                 ; chybn˜ znak - dal¨¡ ‡ek n¡

; ------ operace OK - vynulov n¡ paketu

         call      NulPaket                 ; vynulov n¡ paketu

; ------ n vrat registr–

         pop       bp
         pop       si
         pop       cx
         pop       ax
         ret

OutPaket ENDP

; *****************************************************************************
;
;                         Obsluha komunikace
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        vypr zdnˆn¡ vstupu
; -----------------------------------------------------------------------------

InpFlush PROC      NEAR

         push      ax

         mov       ah,3
         call      Int14                    ; test stavu portu
         test      ah,bit1                  ; bylo nˆco p©ijato ?
         jz        InpFlsh2                 ; nejsou p©ipravena data
         call      InpByte                  ; vstup znaku

InpFlsh2:pop       ax
         ret

InpFlush ENDP

; -----------------------------------------------------------------------------
;        v˜stup bajtu AL na port COM
; -----------------------------------------------------------------------------

OutByte  PROC      NEAR

; ------ vysl n¡ bajtu AL na port

         push      ax
         mov       ah,1
         call      Int14                    ; vysl n¡ znaku na port COM

; ------ test, zda byl TIME-OUT operace

         test      ah,bit7                  ; je chyba TIME-OUT ?
         jz        OutByte2                 ; nen¡ chyba TIME-OUT

; ------ chyba v˜stup na port COM

         mov       si,offset OutErr         ; text - chyba v˜stupu
         jmp       Chyba

OutByte2:pop       ax
         ret

OutByte  ENDP

; -----------------------------------------------------------------------------
;        vstup bajtu z portu COM (CY=TIME-OUT)
; -----------------------------------------------------------------------------

InpByte  PROC      NEAR

         call      InitTOut                 ; inicializace ‡asova‡e

; ------ ‡ek n¡ na p©ipravenost znaku

InpByte1:push      ax
         mov       ah,3
         call      Int14                    ; test stavu portu
         test      ah,bit0                  ; bylo nˆco p©ijato ?
         pop       ax
         jnz       InpByte2                 ; jsou p©ipravena data
         call      CBreak                   ; obsluha p©eru¨en¡ programu
         call      TimeOut                  ; obsluha TIME-OUT
         mov       al,0
         jc        InpByte4                 ; chyba TIME-OUT
         jmp       short InpByte1

; ------ p©¡jem bajtu z portu

InpByte2:push      bx
         push      ax
         mov       ah,2
         call      Int14                    ; p©¡jem znaku z portu COM

; ------ test, zda byl TIME-OUT operace

         test      ah,bit7                  ; je chyba TIME-OUT ?
         jz        InpByte3                 ; nen¡ TIME-OUT
         stc                                ; p©¡znak TIME-OUT
         mov       al,0

; ------ p©ijat˜ znak

InpByte3:xchg      ax,bx                    ; BL <- p©ijat˜ znak
         pop       ax
         mov       al,bl                    ; AL <- p©ijat˜ znak
         pop       bx
InpByte4:ret

InpByte  ENDP

; -----------------------------------------------------------------------------
;        obsluha p©eru¨en¡ INT 14h
; -----------------------------------------------------------------------------

Int14    PROC      NEAR

         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

         mov       dx,ds:[Kanal]            ; ‡¡slo v˜stupn¡ho kan lu
         int       14h                      ; obsluha COM

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

Int14    ENDP

; -----------------------------------------------------------------------------
;        inicializace ‡asova‡e TIME-OUT
; -----------------------------------------------------------------------------

InitTOut PROC      NEAR

         push      ax
         push      es

         xor       ax,ax
         mov       es,ax                    ; ES <- 0
         mov       ax,es:[46ch]             ; syst‚mov˜ ‡asova‡
         mov       ds:[OldTime],ax          ; £schova ‡asova‡e

         pop       es
         pop       ax
         ret

InitTOut ENDP

; -----------------------------------------------------------------------------
;        test TIME-OUT (CY=je Time-Out)
; -----------------------------------------------------------------------------

TimeOut  PROC      NEAR

         push      ax
         push      es

         xor       ax,ax
         mov       es,ax
         mov       ax,es:[46ch]             ; aktu ln¡ syst‚mov˜ ‡asova‡
         sub       ax,ds:[OldTime]          ; uplynul˜ ‡as

         cmp       al,-10
         jae       TimeOut2                 ; ‡¡t n¡ zpˆt - ignoruje se

         cmp       ax,60*18                 ; ‡as pro TIME-OUT
         cmc

TimeOut2:pop       es
         pop       ax
         ret

TimeOut  ENDP

; -----------------------------------------------------------------------------
;        ‡ek n¡ po zadanou dobu (CX impuls– 1/1 sek.)
; -----------------------------------------------------------------------------

CekTime  PROC      NEAR

         push      ax
         push      cx
         push      ds

         jcxz      CekTime9
         xor       ax,ax
         mov       ds,ax

CekTime2:mov       ax,ds:[46ch]
         sti
CekTime4:cmp       ax,ds:[46ch]
         je        CekTime4
         loop      CekTime2

CekTime9:pop       ds
         pop       cx
         pop       ax
         ret

CekTime  ENDP

; *****************************************************************************
;
;                         Dek¢dov n¡ zad n¡ parametr–
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        dek¢dov n¡ parametr– (DS=ES=CS !)
; -----------------------------------------------------------------------------

DekParm  PROC      NEAR

; ------ p©¡prava p©¡kazov‚ho © dku

         mov       si,81h
         mov       bl,ds:[si-1]             ; d‚lka p©¡kazov‚ho © dku
         mov       bh,0
         mov       ds:[si+bx],bh            ; ozna‡en¡ konce p©¡kazov‚ho © dku

; ------ nalezen¡ za‡ tku prvn¡ho parametru

         call      DekSpc                   ; vypu¨tˆn¡ mezer
         jnc       DekParm2                 ; nalezen prvn¡ parametr
DekParm1:ret                                ; n vrat, pokus nebylo nic zad no

; ------ na‡ten¡ prvn¡ho znaku parametru

DekParm2:call      DekChar                  ; na‡ten¡ znaku
         cmc
         jnc       DekParm1                 ; konec p©¡kazov‚ho © dku

; ------ dek¢dov n¡ jm‚na souboru

         mov       di,offset Soubor         ; buffer jm‚na souboru
DekParm3:cmp       al,"/"
         je        DekParm5                 ; je zad n parametr
         cld
         stosb                              ; ulo‘en¡ znaku do bufferu
         mov       byte ptr ds:[di],0       ; p©¡padn‚ ozna‡en¡ konce jm‚na
         call      DekChar                  ; na‡ten¡ dal¨¡ho znaku
         ja        DekParm3                 ; je platn˜ znak - ulo‘en¡
DekParm4:call      DekSpc                   ; vypu¨tˆn¡ mezer
         jmp       short DekParm2           ; dal¨¡ rozbor

; ------ na‡ten¡ druh‚ho znaku parametru

DekParm5:call      DekChar                  ; na‡ten¡ druh‚ho znaku
         jc        DekParm1                 ; chyba zad n¡

; ------ ‡¡slo kan lu COM "1" a‘ "4"

         cmp       al,"1"
         jb        DekParm6
         cmp       al,"4"
         ja        DekParm6
         mov       ds:[ComTxt1],al          ; ozna‡en¡ portu
         mov       ds:[OutErr1],al          ; ozna‡en¡ portu
         sub       al,"1"
         mov       byte ptr ds:[Kanal],al   ; ‡¡slo v˜stupn¡ho kan lu
         jmp       short DekParm4           ; dal¨¡ parametr

; ------ rotace v˜kresu "@"

DekParm6:cmp       al,"@"
         jne       DekParm7                 ; nen¡ rotace
         or        byte ptr ds:[Param],bit3 ; p©¡znak rotace v˜kresu
         jmp       short DekParm4           ; dal¨¡ parametr

; ------ zmˆna mˆ©¡tka v˜kresu

DekParm7:cmp       al,"&"                   ; je zmˆna mˆ©¡tka ?
         jne       DekParm8                 ; nen¡ zmˆna mˆ©¡tka
         call      DekNum                   ; na‡ten¡ n sobku mˆ©¡tka
         jc        DekParm8
         xchg      ax,cx                    ; £schova n sobku mˆ©¡tka
         mov       bx,dx

         call      DekSpc
         call      DekChar                  ; na‡ten¡ dal¨¡ho znaku
         cmp       al,":"
         jne       DekParm8
         call      DekNum                   ; na‡ten¡ dˆlitele mˆ©¡tka
         jc        DekParm8

DekPrm72:or        dx,dx
         jnz       DekPrm74
         cmp       ax,4000h
         jae       DekPrm74
         or        bx,bx
         jnz       DekPrm74
         cmp       cx,4000h
         jb        DekPrm76
DekPrm74:shr       dx,1
         rcr       ax,1
         shr       bx,1
         rcr       cx,1
         jmp       short DekPrm72

DekPrm76:or        cx,cx
         jnz       DekPrm77
         inc       cx
DekPrm77:or        ax,ax
         jnz       DekPrm78
         inc       ax
DekPrm78:mov       ds:[DelMer],ax           ; dˆlitel mˆ©¡tka
         mov       ds:[NasMer],cx           ; n sobitel mˆ©¡tka
DekPrm79:jmp       short DekParm4           ; dal¨¡ parametr

; ------ form t HI "I"

DekParm8:cmp       al,"I"
         jne       DekPrm81
         and       byte ptr ds:[Param],not bit5 ; form t HI
         jmp       short DekPrm79

; ------ form t HP "P"

DekPrm81:cmp       al,"P"
         jne       DekPrm82
         or        byte ptr ds:[Param],bit5 ; form t HP
         jmp       short DekPrm79

DekPrm82:
         stc                                ; p©¡znak chyby zad n¡
         ret

DekParm  ENDP

;; -----------------------------------------------------------------------------
;;        na‡ten¡ slova AX
;; -----------------------------------------------------------------------------
;
;DekWNum  PROC      NEAR
;
;         push      dx
;         call      DekNum
;         jc        DekWNum2
;         or        dx,dx
;         jz        DekWNum2
;         mov       ax,-1
;DekWNum2:pop       dx
;         ret
;
;DekWNum  ENDP
;
; -----------------------------------------------------------------------------
;        na‡ten¡ ‡¡sla DX:AX
; -----------------------------------------------------------------------------

DekNum   PROC      NEAR

         push      bx
         push      cx

         xor       bx,bx
         xor       cx,cx

         call      DekSpc                   ; vypu¨tˆn¡ mezer
         call      Dek0Num                  ; na‡ten¡ prvn¡ ‡¡slice
         jc        DekNum9

DekNum1: push      ax
         mov       ax,10
         mul       bx
         xchg      ax,bx
         mov       ax,10
         mul       cx
         xchg      ax,cx
         add       bx,dx
         pop       ax
         mov       ah,0
         add       cx,ax
         adc       bx,0
         call      Dek0Num
         jnc       DekNum1
         clc

DekNum9: xchg      ax,cx
         mov       dx,bx

         pop       cx
         pop       bx
         ret

DekNum   ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ ‡¡slice
; -----------------------------------------------------------------------------

Dek0Num  PROC      NEAR

         call      DekChar
         jc        Dek0Num4

         cmp       al,"9"
         ja        Dek0Num3
         sub       al,"0"
         jae       Dek0Num4

Dek0Num3:dec       si
         stc
Dek0Num4:ret

Dek0Num  ENDP

; -----------------------------------------------------------------------------
;        vypu¨tˆn¡ mezer z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

DekSpc   PROC      NEAR

DekSpc2: call      DekChar                  ; na‡ten¡ znaku z p©¡kazov‚ho © dku
         jc        DekSpc4                  ; konec p©¡kazov‚ho © dku
         je        DekSpc2                  ; je mezera - vypu¨tˆn¡
         dec       si                       ; n vrat platn‚ho znaku
DekSpc4: ret

DekSpc   ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ znaku z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

DekChar  PROC      NEAR

         cld
         lodsb

         cmp       al,9
         jne       DekChar1
         mov       al," "                   ; n hrada tabul toru mezerou

DekChar1:call      UpCase                   ; konverze na velk‚ p¡smeno

         cmp       al," "
         jae       DekChar6
         dec       si
DekChar6:ret

DekChar  ENDP

; *****************************************************************************
;
;                                      data
;
; *****************************************************************************
;þ
Kanal    dw        0                        ; ‡¡slo kan lu COM (0 a‘ 3)

OldTime  dw        0                        ; uschovan˜ syst‚mov˜ ‡asova‡ LOW

UvTxt    db        'VZ-930 V1.10 - ovladac zapisovace VZ-930; (c) Miroslav Nemecek',13,10,'$'
HelpTxt  db        'Zadejte:   soubor ........ jmeno souboru k vystupu na zapisovac',13,10
         db        '           /I ............ Soubor je ve formatu jazyka HI-GL zapisovace',13,10
         db        '                           DMP-51 firmy HOUSTON INSTRUMENT (implicitne)',13,10
         db        '           /P ............ Soubor je ve formatu HEWLETT PACKARD',13,10
         db        '           /n ............ cislo vystupniho kanalu COMn (n=1 az 4)',13,10
         db        '                           Implicitne nastaven kanal COM1.',13,10
         db        '           /@ ............ otoceni vykresu o 90 stupnu',13,10
         db        '           /& m:n ........ zmena meritka vykresu (napr. 254:250',13,10
         db        '                           zkoriguje metrickou miru na palcovou)',13,10
         db        '$'

FndTxt   db        'Nezadano platne jmeno souboru k vystupu na zapisovac !',13,10,'$'
ComTxt   db        'Port COM'
ComTxt1  db        '1 neni k dispozici !',13,10,'$'
InpCek   db        'Zapisovac neodpovida !  Zvolte ... D=cekat dale, V=vyslat vyzvu, ESC=konec: $'
OutErr   db        'Chyba vystupu na port COM'
OutErr1  db        '1 (nepripojen kabel zapisovace) !'
CRTxt    db        13,10,'$'

; ------ tabulka font– znak–
; 1. bajt ka‘d‚ho znaku ud v  po‡et dvojic sou©adnic X a Y
; V sou©adnici X ud v  bit 7 zvednut¡ pera

TabChr   db         0                                      ; mezera
         db         4,0C0h,7Fh,40h,20h,0C0h,0Eh,40h,0      ; !
         db         4,0ABh,7Fh,2Bh,60h,0D5h,7Fh,55h,60h    ; "
         db         8,80h,50h,7Fh,50h,0FFh,30h,0,30h       ; #
         db           0ABh,10h,2Bh,70h,0D5h,70h,55h,10h    
         db        12,0EAh,70h,16h,70h,0,60h,0,50h         ; $
         db           16h,40h,6Ah,40h,7Fh,30h,7Fh,20h      
         db           6Ah,10h,16h,10h,0C0h,7Fh,40h,0       
         db        12,80h,50h,0,70h,2Bh,70h,2Bh,50h        ; %
         db           0,50h,80h,10h,7Fh,70h,0FFh,10h       
         db           55h,10h,55h,30h,7Fh,30h,7Fh,10h      
         db        12,0FFh,30h,40h,0,2Bh,0,0,20h           ; &
         db           0,30h,40h,60h,40h,70h,2Bh,7Fh        
         db           16h,7Fh,0,70h,0,60h,7Fh,0            
         db         3,0D5h,7Fh,55h,70h,40h,60h             ; '
         db         4,0D5h,7Fh,2Bh,60h,2Bh,20h,55h,0       ; (
         db         4,0ABh,7Fh,55h,60h,55h,20h,2Bh,0       ; )
         db         8,96h,40h,6Ah,40h,0EAh,60h,16h,20h     ; *
         db           0C0h,20h,40h,60h,96h,60h,6Ah,20h     
         db         4,96h,40h,6Ah,40h,0C0h,60h,40h,20h     ; +
         db         6,0C0h,20h,55h,20h,55h,30h,40h,30h     ; ,
         db           40h,10h,2Bh,0                        
         db         2,96h,40h,6Ah,40h                      ; -
         db         5,0D5h,0,55h,10h,40h,10h,40h,0         ; .
         db           55h,0                                
         db         2,0FFh,70h,0,10h                       ; /
         db        12,80h,20h,2Bh,0,55h,0,7Fh,20h          ; 0
         db           7Fh,60h,55h,7Fh,2Bh,7Fh,0,60h
         db           0,20h,16h,20h,6Ah,60h,7Fh,60h
         db         5,96h,60h,40h,7Fh,40h,0,0ABh,0         ; 1
         db           55h,0
         db        11,80h,60h,0,70h,16h,7Fh,6Ah,7Fh        ; 2
         db           7Fh,70h,7Fh,50h,6Ah,40h,2Bh,40h
         db           0,20h,0,0,7Fh,0
         db        13,80h,70h,16h,7Fh,6Ah,7Fh,7Fh,70h      ; 3
         db           7Fh,60h,55h,40h,40h,40h,55h,40h
         db           7Fh,20h,7Fh,10h,6Ah,0,16h,0
         db           0,10h
         db         5,0EAh,0,6Ah,7Fh,0,30h,0,20h           ; 4
         db           7fh,20h
         db        10,80h,10h,16h,0,55h,0,7fh,20h          ; 5
         db           7fh,30h,55h,50h,16h,50h,0,40h
         db           0,7Fh,6Ah,7Fh
         db        11,80h,30h,2bh,50h,55h,50h,7fh,30h      ; 6
         db           7fh,20h,55h,0,2bh,0,0,20h
         db           0,60h,2Bh,7Fh,6Ah,7Fh
         db         5,80h,60h,0,7Fh,7Fh,7Fh,7Fh,50h        ; 7
         db           16h,0
         db        16,0ABh,50h,16h,60h,16h,70h,2Bh,7Fh     ; 8
         db           55h,7Fh,6Ah,70h,6Ah,60h,55h,50h
         db           2Bh,50h,0,30h,0,20h,2Bh,0
         db           55h,0,7Fh,20h,7Fh,30h,55h,50h
         db        11,0FFh,50h,55h,30h,2Bh,30h,0,50h       ; 9
         db           0,60h,2Bh,7Fh,55h,7Fh,7Fh,60h
         db           7Fh,20h,55h,0,16h,0
         db        10,0D5h,30h,40h,30h,40h,40h,55h,40h     ; :
         db           55h,30h,0D5h,10h,55h,0,40h,0
         db           40h,10h,55h,10h
         db        11,0C0h,50h,55h,50h,55h,60h,40h,60h     ; ;
         db           40h,50h,0C0h,20h,55h,20h,55h,30h
         db           40h,30h,40h,10h,2Bh,0
         db         3,0EAh,7Fh,16h,40h,6Ah,0               ; <
         db         4,96h,50h,6Ah,50h,96h,30h,6Ah,30h      ; =
         db         3,96h,7Fh,6Ah,40h,16h,0                ; >
         db        11,80h,70h,16h,7Fh,6Ah,7Fh,7Fh,70h      ; ?
         db           7Fh,60h,6Ah,50h,55h,50h,40h,40h
         db           40h,20h,0C0h,0Eh,40h,0
         db        14,0ABh,0,40h,10h,40h,30h,2Bh,40h       ; @
         db           16h,40h,0,30h,0,10h,16h,0
         db           55h,0,7Fh,20h,7Fh,60h,55h,7Fh
         db           2Bh,7Fh,0,60h
         db         7,80h,0,0,50h,40h,7Fh,7Fh,50h          ; A
         db           7Fh,0,80h,30h,7Fh,30h
         db        12,80h,0,0,7Fh,55h,7Fh,6Ah,70h          ; B
         db           6Ah,50h,55h,40h,0,40h,6Ah,40h
         db           7Fh,30h,7Fh,10h,6Ah,0,0,0
         db         8,0FFh,70h,6Ah,7Fh,2Bh,7Fh,0,60h       ; C
         db           0,20h,2Bh,0,6Ah,0,7Fh,10h
         db         7,80h,0,0,7Fh,55h,7Fh,7Fh,60h          ; D
         db           7Fh,20h,55h,0,0,0
         db         6,0FFh,7Fh,0,7Fh,0,0,7Fh,0             ; E
         db           80h,40h,6Ah,40h
         db         5,0FFh,7Fh,0,7Fh,0,0,80h,40h           ; F
         db           6Ah,40h
         db        10,0FFh,70h,6Ah,7Fh,2Bh,7Fh,0,60h       ; G
         db           0,20h,2Bh,0,6Ah,0,7Fh,10h
         db           7Fh,30h,55h,30h
         db         6,80h,0,0,7Fh,80h,40h,7Fh,40h          ; H
         db           0FFh,7Fh,7Fh,0
         db         6,0ABh,7Fh,55h,7Fh,0C0h,7Fh,40h,0      ; I
         db           0ABh,0,55h,0
         db         6,80h,30h,0,20h,2Bh,0,55h,0            ; J
         db           7Fh,20h,7Fh,7Fh
         db         6,80h,0,0,7Fh,0FFh,7Fh,0,20h           ; K
         db           0ABh,40h,7Fh,0
         db         3,80h,7Fh,0,0,7Fh,0                    ; L
         db         5,80h,0,0,7Fh,40h,50h,7Fh,7Fh          ; M
         db           7Fh,0
         db         6,80h,0,0,7Fh,80h,70h,7Fh,10h          ; N
         db           0FFh,0,7Fh,7Fh
         db         9,80h,20h,2bh,0,55h,0,7Fh,20h          ; O
         db           7Fh,60h,55h,7Fh,2Bh,7Fh,0,60h
         db           0,20h
         db         7,80h,0,0,7Fh,6Ah,7Fh,7Fh,70h          ; P
         db           7Fh,50h,6Ah,40h,00h,40h
         db        11,80h,20h,2Bh,0,40h,0,7Fh,30h          ; Q
         db           7Fh,60h,55h,7Fh,2Bh,7Fh,0,60h
         db           0,20h,0D5h,20h,7Fh,0
         db         9,80h,0,0,7Fh,6Ah,7Fh,7Fh,70h          ; R
         db           7Fh,50h,6Ah,40h,0,40h,0ABh,40h
         db           7Fh,0
         db        10,96h,0,6Ah,0,7Fh,10h,7Fh,30h          ; S
         db           6Ah,40h,16h,40h,0,50h,0,70h
         db           16h,7Fh,6Ah,7Fh
         db         4,80h,7Fh,7Fh,7Fh,0C0h,7Fh,40h,0       ; T
         db         6,80h,7Fh,0,20h,2Bh,0,55h,0            ; U
         db           7Fh,20h,7Fh,7Fh
         db         5,80h,7Fh,0,30h,40h,0,7Fh,30h          ; V
         db           7Fh,7Fh
         db         7,80h,7Fh,0,10h,16h,0,40h,20h          ; W
         db           6Ah,0,7Fh,10h,7Fh,7Fh
         db         8,80h,0,0,10h,7Fh,70h,7Fh,7Fh          ; X
         db           80h,7Fh,0,70h,7Fh,10h,7Fh,0
         db         8,80h,7Fh,0,60h,2Bh,40h,55h,40h        ; Y
         db           7Fh,60h,7Fh,7Fh,0C0h,40h,40h,0
         db         6,80h,7Fh,7Fh,7Fh,7Fh,70h,0,10h        ; Z
         db           0,0,7Fh,0
         db         4,0D5h,7Fh,2Bh,7Fh,2Bh,0,55h,0         ; [
         db         2,80h,70h,7Fh,10h                      ; \
         db         4,0ABh,7Fh,55h,7Fh,55h,0,2Bh,0         ; ]
         db         3,80h,50h,40h,7Fh,7Fh,50h              ; ^
         db         2,80h,0,7Fh,00h                        ; _
         db         2,0ABh,7Fh,55h,60h                     ; `
         db        13,0ABh,50h,55h,50h,6Ah,40h,6Ah,10h     ; a
         db           55h,0,2Bh,0,16h,10h,16h,20h
         db           2Bh,30h,55h,30h,6Ah,20h,0EAh,10h
         db           7fh,0
         db         7,96h,7Fh,16h,0,6Ah,0,7Fh,10h          ; b
         db           7Fh,30h,6Ah,40h,16h,40h
         db         6,0FFh,40h,2Bh,40h,16h,30h,16h,10h     ; c
         db           2Bh,0,7Fh,0
         db         7,0FFh,7Fh,7Fh,0,2Bh,0,16h,10h         ; d
         db           16h,30h,2Bh,40h,7Fh,40h
         db         9,0EAh,0,2Bh,0,16h,10h,16h,30h         ; e
         db           2Bh,40h,6Ah,40h,7Fh,30h,7Fh,20h
         db           16h,20h
         db         7,0ABh,0,2Bh,70h,40h,7Fh,55h,7Fh       ; f
         db           6Ah,70h,96h,40h,55h,40h
         db        10,0ABh,0,6Ah,0,7Fh,10h,7Fh,40h         ; g
         db           6Ah,50h,2Bh,50h,16h,40h,16h,30h
         db           2Bh,20h,7Fh,20h
         db         6,96h,0,16h,7Fh,96h,40h,55h,40h        ; h
         db           7Fh,20h,7Fh,0
         db         7,0BCh,60h,44h,60h,0ABh,40h,40h,40h    ; i
         db           40h,0,0ABh,0,55h,0
         db         6,0D0h,70h,5Ah,70h,0C0h,50h,55h,50h    ; j
         db           55h,10h,40h,0
         db         7,96h,0,16h,7Fh,0FFh,60h,40h,30h       ; k
         db           16h,30h,0C0h,30h,7Fh,0
         db         5,0ABh,7Fh,40h,7Fh,40h,0,0ABh,0        ; l
         db           55h,0
         db        11,80h,0,0,30h,16h,40h,2Bh,40h          ; m
         db           40h,30h,40h,0,0C0h,30h,55h,40h
         db           6Ah,40h,7Fh,30h,7Fh,0
         db         5,96h,0,16h,40h,55h,40h,6Ah,30h        ; n
         db           6Ah,0
         db         9,0D5h,0,2Bh,0,16h,10h,16h,30h         ; o
         db           2Bh,40h,55h,40h,6Ah,30h,6Ah,10h
         db           55h,0
         db         7,96h,0,16h,60h,55h,60h,6Ah,50h        ; p
         db           6Ah,40h,55h,30h,16h,30h
         db         7,0EAh,0,6Ah,60h,2Bh,60h,16h,50h       ; q
         db           16h,40h,2Bh,30h,6Ah,30h
         db         6,96h,0,16h,40h,96h,20h,40h,40h        ; r
         db           55h,40h,6Ah,30h
         db         8,0EAh,40h,2Bh,40h,16h,30h,2Bh,20h     ; s
         db           6Ah,20h,7Fh,10h,6Ah,0,2Bh,0
         db         7,0FFh,20h,55h,0,40h,0,2Bh,10h         ; t
         db           2Bh,7Fh,96h,40h,55h,40h
         db         6,96h,40h,16h,10h,2Bh,0,55h,0          ; u
         db           6Ah,10h,6Ah,40h
         db         5,96h,40h,16h,20h,40h,0,6Ah,20h        ; v
         db           6Ah,40h
         db         7,80h,40h,0,10h,16h,0,40h,20h          ; w
         db           6Ah,0,7Fh,10h,7Fh,40h
         db         4,96h,0,6Ah,40h,96h,40h,6Ah,0          ; x
         db         8,96h,50h,16h,40h,2Bh,30h,55h,30h      ; y
         db           6Ah,40h,6Ah,50h,0C0h,30h,40h,0
         db         4,96h,40h,6Ah,40h,16h,0,6Ah,0          ; z
         db         9,0D5h,7Fh,40h,7Fh,2Bh,70h,2Bh,50h     ; {
         db           16h,40h,2Bh,30h,2Bh,10h,40h,0
         db           55h,0
         db         2,0C0h,7Fh,40h,0                       ; |
         db         9,0ABh,7Fh,40h,7Fh,55h,70h,55h,50h     ; }
         db           6Ah,40h,55h,30h,55h,10h,40h,0
         db           2Bh,0
         db         7,80h,40h,16h,50h,2Bh,50h,40h,40h      ; ~
         db           55h,30h,6Ah,30h,7Fh,40h
         db         0                                      ; 

; ------ definice zna‡ek

AdrMark  dw        Mark0                    ; 0: plus
         dw        Mark1                    ; 1: x
         dw        Mark2                    ; 2: ‡tvere‡ek
         dw        Mark3                    ; 3: osmi£heln¡k
         dw        Mark4                    ; 4: troj£heln¡k
         dw        Mark5                    ; 5: p©es˜pac¡ hodiny

Mark0    db        5,1Ch,74h,1bh,66h,23h    ; plus
Mark1    db        5,1Bh,76h,22h,56h,2Bh    ; x
Mark2    db        6,2Dh,54h,62h,74h,66h,1Bh; ‡tvere‡ek
Mark3    db        10,2eh,54h,5bh,62h,6bh   ; osmi£heln¡k
         db           74h,6dh,66h,5dh,1ah
Mark4    db        5,25h,5Ah,74h,5Eh,23h    ; troj£heln¡k
Mark5    db        5,6Eh,54h,70h,54h,6eh    ; p©es˜pac¡ hodiny

; ------ tabulka delta povel–

TabDelt  label     byte
         db        0                        ; X=0,  Y=0
         db        26h                      ; X=1,  Y=0
         db        22h                      ; X=2,  Y=0
         db        1Eh                      ; X=3,  Y=0
         db        0                        ; X=-0, Y=0
         db        25h                      ; X=-1, Y=0
         db        21h                      ; X=-2, Y=0
         db        1Dh                      ; X=-3, Y=0

         db        24h                      ; X=0,  Y=1
         db        18h                      ; X=1,  Y=1
         db        3Ch                      ; X=2,  Y=1
         db        34h                      ; X=3,  Y=1
         db        24h                      ; X=-0, Y=1
         db        19h                      ; X=-1  Y=1
         db        3Dh                      ; X=-2, Y=1
         db        35h                      ; X=-3, Y=1

         db        20h                      ; X=0,  Y=2
         db        38h                      ; X=1,  Y=2
         db        14h                      ; X=2,  Y=2
         db        30h                      ; X=3,  Y=2
         db        20h                      ; X=-0, Y=2
         db        39h                      ; X=-1  Y=2
         db        15h                      ; X=-2, Y=2
         db        31h                      ; X=-3, Y=2

         db        1Ch                      ; X=0,  Y=3
         db        2Ch                      ; X=1,  Y=3
         db        28h                      ; X=2,  Y=3
         db        10h                      ; X=3,  Y=3
         db        1Ch                      ; X=-0, Y=3
         db        2Dh                      ; X=-1  Y=3
         db        29h                      ; X=-2, Y=3
         db        11h                      ; X=-3, Y=3

         db        0                        ; X=0,  Y=-0
         db        26h                      ; X=1,  Y=-0
         db        22h                      ; X=2,  Y=-0
         db        1Eh                      ; X=3,  Y=-0
         db        0                        ; X=-0, Y=-0
         db        25h                      ; X=-1, Y=-0
         db        21h                      ; X=-2, Y=-0
         db        1Dh                      ; X=-3, Y=-0

         db        27h                      ; X=0,  Y=-1
         db        1Ah                      ; X=1,  Y=-1
         db        3Eh                      ; X=2,  Y=-1
         db        36h                      ; X=3,  Y=-1
         db        27h                      ; X=-0, Y=-1
         db        1Bh                      ; X=-1  Y=-1
         db        3Fh                      ; X=-2, Y=-1
         db        37h                      ; X=-3, Y=-1

         db        23h                      ; X=0,  Y=-2
         db        3Ah                      ; X=1,  Y=-2
         db        16h                      ; X=2,  Y=-2
         db        32h                      ; X=3,  Y=-2
         db        23h                      ; X=-0, Y=-2
         db        3Bh                      ; X=-1  Y=-2
         db        17h                      ; X=-2, Y=-2
         db        33h                      ; X=-3, Y=-2

         db        1Fh                      ; X=0,  Y=-3
         db        2Eh                      ; X=1,  Y=-3
         db        2Ah                      ; X=2,  Y=-3
         db        12h                      ; X=3,  Y=-3
         db        1Fh                      ; X=-0, Y=-3
         db        2Fh                      ; X=-1  Y=-3
         db        2Bh                      ; X=-2, Y=-3
         db        13h                      ; X=-3, Y=-3

; ------ definice ukazatel– zapisova‡e

Param    db        bit1+bit0                ; parametry
                                            ;   bit 0: 1=absolutn¡ adresov n¡
                                            ;   bit 1: 1=pero zvednuto
                                            ;   bit 2: 1=velk˜ form t
                                            ;   bit 3: 1=rotace v˜kresu
                                            ;   bit 5: 1=format HP (0=format HI)
                                            ;   bit 6: 1=text Italic

; ------ ukazatele sou©adnic

HomeX    dd        0                        ; sou©adnice posunut‚ho po‡ tku X
AktX     dd        0                        ; aktu ln¡ sou©adnice X absolutn¡
SkutX    dd        0                        ; skute‡n  sou©adnice X zapisova‡e

HomeY    dd        0                        ; sou©adnice posunut‚ho po‡ tku Y
AktY     dd        0                        ; aktu ln¡ sou©adnice Y absolutn¡
SkutY    dd        0                        ; skute‡n  sou©adnice Y zapisova‡e

NasMer   dw        1                        ; n sobitel mˆ©¡tka
DelMer   dw        1                        ; dˆlitel mˆ©¡tka

NasKrok  dw        1                        ; n sobitel mˆ©¡tka krokov n¡
DelKrok  dw        2                        ; dˆlitel mˆ©¡tka krokov n¡
MarkSize dw        1                        ; velikost zna‡ky
TypMark  db        0                        ; typ zna‡ky

; ------ definice okna a podokna

MinXWin  dd        0                        ; lev˜ okraj okna
MaxXWin  dd        77777777h                ; prav˜ okraj okna
DltXWin  dd        77777777h                ; ¨¡©ka okna

MinYWin  dd        0                        ; spodn¡ okraj okna
MaxYWin  dd        77777777h                ; horn¡ okraj okna
DltYWin  dd        77777777h                ; v˜¨ka okna

MinXZoom dd        0                        ; lev˜ okraj podokna
MaxXZoom dd        77777777h                ; prav˜ okraj podokna
DltXZoom dd        77777777h                ; ¨¡©ka podokna

MinYZoom dd        0                        ; spodn¡ okraj podokna
MaxYZoom dd        77777777h                ; horn¡ okraj podokna
DltYZoom dd        77777777h                ; v˜¨ka podokna

NasXZoom dw        1                        ; n sobek X ZOOM
DelXZoom dw        1                        ; dˆlitel X ZOOM
NasYZoom dw        1                        ; n sobek Y ZOOM
DelYZoom dw        1                        ; dˆlitel Y ZOOM

; ------ definice textu

TextVys  dw        8*7                      ; v˜¨ka znaku (bod–)
TextSir  dw        8*6                      ; ¨¡©ka znaku (bod–)
TextSmX  dd        1000h                    ; smˆrnice X
TextSmY  dd        0                        ; smˆrnice Y
EOTChr   db        "_"                      ; znak konce ASCII textu

; ------ inicializa‡n¡ paket

InitPak  db        InitPak0-InitPak-1
         db        8,1                      ; povolen dvojit˜ buffer
         db        8,3,10                   ; opo‘dˆn¡ odpovˆdi zapisova‡e (20ms)
         db        8,4,1,0,PRIJEMOK         ; definice zpr vy p©i p©¡jmu OK (01)
         db        8,5,1,0,PRIJCHYB         ; definice zpr vy p©i chybˆ (04)
         db        8,6,1,0,VYZVA            ; definice ‡ dosti o odpovˆƒ (03)
         db        8,7,2                    ; maxim ln¡ ‡ekac¡ doba (1 sekunda)
         db        8,8,1,0,CEKEJ            ; definice zpr vy p©i ‡ek n¡ (02)
         db        7,NRADIX-1               ; z klad ‡¡seln‚ soustavy (64)
         db        9,1                      ; n soben¡ krok– (x1)
InitPak0 label     byte

; ------ povely

PovelDwn db        1,2                      ; spu¨tˆn¡ pera
PovelUp  db        1,3                      ; zvednut¡ pera
PovelPen db        2,4,1                    ; volba pera
PovelTxt db        3,5,1,NRADIX dup(" ")    ; text
PovelDef db        4,6,1,26h,10,0,0,0,0,0   ; definice p¡sma
PovelStp db        1,10                     ; zastaven¡ zapisova‡e
PovelMov db        2,26h,10,0,0,0,0,0       ; delta povel (p©esun)

; ------ buffer paketu

WritPak  dw        BuffPak+1                ; ukl dac¡ adresa do bufferu paketu
BuffPak  db        PAKSIZE dup(" ")         ; buffer paketu

; ------ vstupn¡ buffer souboru

SoubIdnt dw        0                        ; identifik tor souboru
Soubor   db        128 dup(0)               ; jm‚no souboru

BuffChr  db        0                        ; navr cen˜ uschovan˜ znak (0=nen¡)
BuffEnd  dw        Buffer                   ; konec dat ve vstupn¡m bufferu
Buffer   db        BuffSize dup(0)          ; vstupn¡ buffer

Code     ENDS
         END       Start

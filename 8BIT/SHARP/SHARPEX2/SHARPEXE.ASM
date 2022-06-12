; -----------------------------------------------------------------------------
;        konstanty
; -----------------------------------------------------------------------------

HI       EQU       256

bit0     EQU       1
bit1     EQU       2
bit2     EQU       4
bit3     EQU       8
bit4     EQU       10h
bit5     EQU       20h
bit6     EQU       40h
bit7     EQU       80h
bit8     EQU       100h
bit9     EQU       200h
bit10    EQU       400h
bit11    EQU       800h
bit12    EQU       1000h
bit13    EQU       2000h
bit14    EQU       4000h
bit15    EQU       8000h

; -----------------------------------------------------------------------------
;                        vìstupn¡ konektor LPT
; -----------------------------------------------------------------------------
; poŸ¡taŸ CANON25                             tisk rna CANON25
;  pin 1  )ÄÄÄÄÄÄÄÄÄoÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ( pin 1     STROBE
;                   ³
;  pin 15 )ÄÄÄÄÄÄÄ¿ ³             (pýeruçit) XÄÄÄÄÄÄÄ( pin 15    ERROR
;                 ³ ³
;  pin 18 )ÄÄÄÄÄoÄÅÄÅÄÄÄÄoÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ( pin 18    GND
;               ³ ³ ³    ³
;  pin 16 )ÄÄÄÄÄÅÄÅÄÅÄÄÄÄÅÄÄÄÄÄÄÄoÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ( pin 16    INIT
;               ³ ³ ³ R1 ³ R2    ³ R3
;               ³ ³ÚÁ¿  ÚÁ¿     ÚÁ¿
;               ³ ³³ ³  ³ ³ 2K2 ³ ³ 68K
;               ³ ³ÀÂÙ  ÀÂÙ     ÀÂÙ
;               ³ ³ ³5K6 ³       ³
;               ³ ³ ³    ³       ³          SHARP MZ800 - NF konektor
;               ³ ³ ÀÄÄÄÄoÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄ>ÄÄÄÄ(         READ
;               ³ ³              ³     C1
;               ³ ³              ³     68n
;               ³ ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄoÄÄÄÄÄ´ ÃÄÄÄÄÄÄ<ÄÄÄÄ(         WRITE
;               ³           R4  ÚÁ¿
;               ³               ³ ³ 22K
;               ³               ÀÂÙ
;               ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄoÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ(         zem (st¡nØn¡)
; Odpory R3 a R4 je vhodn‚ ze zaŸ tku nahradit odporovìm trimrem 100K a nastavit
; stýedn¡ polohu sign lu pýi pýenosu do poŸ¡taŸe (testovac¡m programem)
; -----------------------------------------------------------------------------

code     segment
         assume    cs:code,ds:code
         org       100h

; ------ zmençen¡ souŸasn‚ho konce bloku programu

start:   mov       bx,offset(Konec-Start+10fh)/16 ; velikost programu v odstav.
         mov       ah,4ah
         int       21h                      ; zmençen¡ bloku pamØti
         mov       dx,offset MemTxt
         jc        Chyba2                   ; nedostatek pamØti

; ------ inicializace z sobn¡ku

         mov       sp,offset Zasob

; ------ vytvoýen¡ datov‚ho bloku

         mov       bx,1000h                 ; velikost datov‚ho bloku
         mov       ah,48h
         int       21h                      ; vytvoýen¡ datov‚ho bloku
         jc        Chyba2                   ; nedostatek pamØti
         mov       ds:[DatSegm],ax          ; adresa datov‚ho bloku

; ------ zaŸ tek jm‚na souboru

         mov       si,81h
         mov       cl,ds:[si-1]
         mov       ch,0
         cld
Start1:  jcxz      chyba
         mov       dx,si
         lodsb
         dec       cx
         cmp       al," "
         je        Start1
         cmp       al,9
         je        Start1
         cmp       al,13
         jne       Start2

; ------ chyba - nen¡ nic zad no

Chyba:   mov       dx,offset HlpTxt
Chyba2:  mov       ah,9
         int       21h
         int       20h

; ------ oznaŸen¡ konce jm‚na souboru

Start2:  jcxz      Start3
         lodsb
         dec       cx
         cmp       al," "
         ja        Start2
         dec       si
Start3:  mov       byte ptr ds:[si],0

; ------ otevýen¡ souboru

         mov       ax,3d00h
         int       21h                      ; otevýen¡ souboru pro Ÿten¡
         jc        Chyba                    ; chybn‚ zad n¡ souboru
         mov       bx,ax                    ; identifik tor souboru

; ------ naŸten¡ hlaviŸky souboru

         mov       cx,offset(HlavaEnd-Hlava) ; d‚lka hlaviŸky
         mov       dx,offset Hlava          ; zaŸ tek hlaviŸky
         mov       ah,3fh
         int       21h                      ; naŸten¡ hlaviŸky souboru

; ------ naŸten¡ souboru do pamØti

         push      ds
         mov       ds,ds:[DatSegm]          ; datovì segment
         mov       cx,0ffffh                ; velikost dat
         xor       dx,dx                    ; adresa k naŸten¡ dat
         mov       ah,3fh
         int       21h                      ; naŸten¡ 1. Ÿ sti souboru do pamØti
         pop       ds
         mov       ds:[DatNum],ax           ; poŸet bajt…

; ------ uzavýen¡ souboru

         pushf
         mov       ah,3eh
         int       21h                      ; uzavýen¡ souboru
         popf
         jc        Chyba                    ; chyba Ÿten¡

; ------ hl çen¡ o vys¡l n¡ souboru

         mov       dx,offset TextVys
         mov       ah,9
         int       21h

; ------ zobrazen¡ jm‚na souboru

         mov       cx,17                    ; max. d‚lka textu
         mov       si,offset HlavaNam
Start6:  mov       dl,ds:[si]
         inc       si
         cmp       dl,13
         je        Start62
         mov       ah,2
         int       21h
         loop      Start6
Start62:

; ------ parametry zavadØŸe

         push      ds
         pop       es
         mov       si,offset HlavaDel
         mov       di,offset LoadHlav
         mov       cx,13
         cld
         rep       movsb                    ; pýenos parametr… souboru

         mov       si,offset HlavaNam
         mov       di,offset LoadNam
         mov       cx,17
         rep       movsb                    ; pýenos jm‚na

         mov       si,offset HlavaCom+7
         mov       di,offset LoadComm+7
         mov       cx,offset(HlavaEnd-HlavaCom)-7
         rep       movsb                    ; pýenos pozn mky

; ------ vysl n¡ z hlav¡ zavadØŸe

         mov       di,4000                  ; d‚lka t¢nu
         mov       bh,40
         mov       bl,40
         mov       cx,offset (LoadPrg-Loader) ; d‚lka z hlav¡ zavadØŸe
         mov       si,offset Loader         ; z hlav¡ zavadØŸe
         call      SaveHD                   ; vysl n¡ z hlav¡ zavadØŸe
         jc        StartX                   ; pýeruçen¡ programu

; ------ vysl n¡ programu zavadØŸe

         shr       bh,1                     ; synchronizace 1
         shr       bl,1                     ; synchronizace 2
         mov       cx,offset(LoadEnd-LoadPrg) ; d‚lka programu zavadØŸe
         mov       si,offset LoadPrg        ; program zavadØŸe
         call      SaveHD                   ; vysl n¡ zavadØŸe
         jc        StartX                   ; pýeruçen¡ programu

; ------ vysl n¡ dat souboru

         mov       byte ptr ds:[Konst08],55
         mov       byte ptr ds:[DelImp],2
         mov       di,10000
         mov       cx,ds:[HlavaDel]         ; d‚lka souboru
         xor       si,si                    ; poŸ teŸn¡ adresa
         mov       es,ds:[DatSegm]          ; datovì segment
         call      SaveHD                   ; vysl n¡ dat souboru

; ------ konec programu

StartX:
         mov       dx,offset CRTxt
         mov       ah,9
         int       21h

         int       20h

; -----------------------------------------------------------------------------
;        vysl n¡ hlaviŸky nebo dat
; -----------------------------------------------------------------------------
; VSTUP: BH=d‚lka synchronizace 1
;        BL=d‚lka synchronizace 2
;        CX=d‚lka bloku dat
;        DI=d‚lka £vodn¡ho t¢nu
;        ES:SI=poŸ teŸn¡ adresa dat
;        DS=datovì segment
; VíSTUP:CY=pýeruçen¡ programu
; -----------------------------------------------------------------------------

SaveHD   PROC      NEAR

; ------ £schova registr…

         push      ax
         push      dx
         call      InitPort                 ; instalace a inicializace port…

; ------ kontroln¡ souŸet dat (do registru DX)

         call      KontrS                   ; kontroln¡ souŸet hlaviŸky souboru

; ------ vysl n¡ £vodu pýed z pisem

         call      SaveUvod                 ; vysl n¡ £vodn¡ho t¢nu a synchron.
         jc        SaveHD9                  ; pýeruçen¡ programu

; ------ vysl n¡ obsahu dat

         call      SavBlok                  ; vysl n¡ obsahu dat
         jc        SaveHD9                  ; pýeruçen¡ programu

; ------ vysl n¡ kontroln¡ho souŸtu

         mov       al,dh                    ; vyçç¡ bajt kontroln¡ho souŸtu
         call      SavByte                  ; vysl n¡ vyçç¡ho bajtu kontr.souŸtu
         mov       al,dl                    ; ni§ç¡ bajt kontroln¡ho souŸtu
         call      SavByte                  ; vysl n¡ ni§ç¡ho bajtu kontr.souŸtu

; ------ vysl n¡ STOP bitu "1"

         stc                                ; pý¡znak bitu "1"
         call      SavBit                   ; vysl n¡ stop bitu "1"

; ------ n vrat registr…

SaveHD9: pushf
         call      DeInit                   ; n vrat port… a pýeruçen¡
         popf
         pop       dx
         pop       ax
         ret

SaveHD   ENDP

; -----------------------------------------------------------------------------
;        kontroln¡ souŸet bloku dat
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=adresa bloku dat
;        CX=poŸet bajt… dat
;        DS=datovì segment
; VíSTUP:DX=kontroln¡ souŸet dat
; -----------------------------------------------------------------------------

KontrS   PROC      NEAR

; ------ £schova registr…

         push      ax
         push      cx
         push      si

; ------ kontrola, zda jsou nØjak  data

         xor       dx,dx                    ; stýadaŸ kontroln¡ho souŸtu
         jcxz      KontrS9                  ; nejsou § dn  data

; ------ pýiŸten¡ jednoho bajtu dat

KontrS1: mov       al,es:[si]               ; datovì bajt k pýiŸten¡
         inc       si                       ; zvìçen¡ ukazatele dat
         mov       ah,8                     ; poŸet bit… bajtu
KontrS2: shl       al,1                     ; jeden bit k pýiŸten¡
         adc       dx,0                     ; pýiŸten¡ bitu ke stýadaŸi
         dec       ah                       ; Ÿ¡taŸ bit…
         jnz       KontrS2                  ; pýiŸten¡ dalç¡ho bitu bajtu
         loop      KontrS1                  ; pýiŸten¡ dalç¡ho bajtu

; ------ n vrat registr…

KontrS9: pop       si
         pop       cx
         pop       ax
         ret

KontrS   ENDP

; -----------------------------------------------------------------------------
;        vysl n¡ £vodu dat
; -----------------------------------------------------------------------------
; VSTUP: DI=poŸet bit… £vodn¡ho t¢nu ("0") (22000=hlaviŸka, 11000=data)
;        BH=poŸet bit… synchronizace 1 ("1") (40=hlaviŸka, 20=data)
;        BL=poŸet bit… synchronizace 2 ("0") (40=hlaviŸka, 20=data)
;        DS=datovì segment
; VíSTUP:CY=pýeruçen¡ programu
; -----------------------------------------------------------------------------

SaveUvod PROC      NEAR

; ------ £schova registr…

         push      ax
         push      bx
         push      di

; ------ vysl n¡ £vodn¡ho t¢nu

         or        di,di
         jz        SaveUv11                 ; nen¡ § dnì bit
SaveUv1: clc                                ; vyçle se bit 0
         call      SavBit                   ; vysl n¡ bitu 0
         jc        SaveUv9                  ; pýeruçen¡ programu
         dec       di                       ; Ÿ¡taŸ bit… £vodn¡ho t¢nu
         jnz       SaveUv1                  ; vysl n¡ dalç¡ho bitu

; ------ vysl n¡ synchronizace 1

SaveUv11:cmp       bh,0                     ; jsou nØjak‚ bity ?
         je        SaveUv22                 ; nejsou § dn‚ bity
SaveUv2: stc                                ; vyçle se bit 1
         call      SavBit                   ; vysl n¡ bitu 1
         dec       bh                       ; poŸet bit… synchronizace
         jnz       SaveUv2                  ; vysl n¡ synchronizace 1

; ------ vysl n¡ synchronizace 2

SaveUv22:cmp       bl,0                     ; jsou nØjak‚ bity ?
         je        SaveUv4                  ; nejsou § dn‚ bity
SaveUv3: clc                                ; vyçle se bit 0
         call      SavBit                   ; vysl n¡ bitu 0
         dec       bl                       ; poŸet bit… synchronizace
         jnz       SaveUv3                  ; vysl n¡ synchronizace 2

; ------ vysl n¡ startovac¡ho bitu

SaveUv4: stc                                ; vyçle se bit 1
         call      SavBit                   ; vysl n¡ bitu 1

; ------ n vrat registr…

SaveUv9: pop       di
         pop       bx
         pop       ax
         ret

SaveUvod ENDP

; -----------------------------------------------------------------------------
;        vysl n¡ bloku dat
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=adresa bloku dat
;        CX=poŸet bajt… k vysl n¡
;        DS=datovì segment
; VíSTUP:CY=pýeruçen¡ programu
; -----------------------------------------------------------------------------

SavBlok  PROC      NEAR

; ------ £schova registr…

         push      ax
         push      cx
         push      si

; ------ kontrola, zda jsou nØjak  data k vysl n¡

         clc
         jcxz      SavBlok9                 ; nejsou § dn  data

; ------ vysl n¡ bloku dat

         cld
SavBlok1:mov       al,es:[si]               ; bajt k vysl n¡
         inc       si                       ; zvìçen¡ ukazatele
         call      SavByte                  ; vysl n¡ jednoho bajtu dat
         jc        SavBlok9                 ; pýeruçen¡ programu
         loop      SavBlok1                 ; vysl n¡ dalç¡ho bajtu

; ------ n vrat registr…

SavBlok9:pop       si
         pop       cx
         pop       ax
         ret

SavBlok  ENDP

; -----------------------------------------------------------------------------
;        vysl n¡ jednoho bajtu
; -----------------------------------------------------------------------------
; VSTUP: AL=bajt k vysl n¡
;        DS=datovì segment
; VíSTUP:CY=pýeruçen¡
; niŸ¡ registr AX !
; -----------------------------------------------------------------------------

SavByte  PROC      NEAR

         stc                                ; start bit "1"
         call      SavBit                   ; vysl n¡ startovac¡ho bitu "1"
         shl       al,1
         call      SavBit                   ; bit 7
         shl       al,1
         call      SavBit                   ; bit 6
         shl       al,1
         call      SavBit                   ; bit 5
         shl       al,1
         call      SavBit                   ; bit 4
         shl       al,1
         call      SavBit                   ; bit 3
         shl       al,1
         call      SavBit                   ; bit 2
         shl       al,1
         call      SavBit                   ; bit 1
         shl       al,1
         call      SavBit                   ; bit 0
         ret

SavByte  ENDP

; -----------------------------------------------------------------------------
;        vysl n¡ jednoho bitu
; -----------------------------------------------------------------------------
; VSTUP: CY=bit je 1 (NC=bit je 0)
;        DS=datovì segment
; VíSTUP:CY=pýeruçen¡
; niŸ¡ registr AH !
; -----------------------------------------------------------------------------

SavBit   PROC      NEAR

; ------ stanoven¡ d‚lky impulsu

         mov       ah,ds:[DelImp]           ; d‚lka impulsu "0"
         jnc       SavBit1                  ; je bit 0
         shl       ah,1                     ; jinak impuls "1"

; ------ vysl n¡ dvou impuls…

SavBit1: call      SavImp                   ; vysl n¡ impulsu "+"
         call      SavImp                   ; vysl n¡ impulsu "-"
         ret

SavBit   ENDP

; -----------------------------------------------------------------------------
;        zah jen¡ vys¡l n¡ jednoho impulsu
; -----------------------------------------------------------------------------
; VSTUP: AH=d‚lka impulsu
;        DS=datovì segment
; VíSTUP:CY=pýeruçen¡ programu
; -----------------------------------------------------------------------------

SavImp   PROC      NEAR

; ------ test, zda je pýeruçen¡ porgramu

         sti                                ; pýeruçen¡ mus¡ bìt povoleno
SavImp1: test      byte ptr ds:[Param],bit0 ; je pýeruçen¡ programu ?
         stc                                ; pý¡znak pýeruçen¡
         jnz       SavImp9                  ; je pýeruçen¡ programu

; ------ Ÿek n¡ na ukonŸen¡ jednoho impulsu

         cmp       byte ptr ds:[CitImp],0   ; je ji§ celì impuls ?
         jne       SavImp1                  ; Ÿek n¡ na ukonŸen¡ impulsu

; ------ zaŸ tek nov‚ho impulsu

         mov       ds:[CitImp],ah           ; d‚lka nov‚ho impulsu
                                            ; zde je pý¡znak NC
SavImp9: ret

SavImp   ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 08h
; -----------------------------------------------------------------------------

INT08    PROC      FAR

; ------ £schova registr…

         push      ax

; ------ Ÿ¡t n¡ zmØny vìstupu

         mov       al,cs:[CitImp]           ; Ÿ¡taŸ impuls…
         cmp       al,0                     ; Ÿ¡t  se impuls ?
         je        Int089                   ; neŸ¡t  se impuls
         dec       al                       ; sn¡§en¡ Ÿ¡taŸe
         mov       cs:[CitImp],al           ; novì stav Ÿ¡taŸe
         jnz       Int089                   ; nen¡ dosa§eno 0

; ------ zmØna portu LPT

         push      dx
         mov       al,cs:[OutPort]          ; vìstup na port LPT
         xor       al,bit0                  ; zmØna sign lu STROBE
         mov       cs:[OutPort],al          ; £schova nov‚ hodnoty
PortLPT: mov       dx,37ah                  ; vìstupn¡ port
         out       dx,al                    ; vìstup bajtu LPT
         pop       dx

; ------ uvolnØn¡ ýadiŸe pýeruçen¡

Int089:  mov       al,20h
         out       [20h],al                 ; uvolnØn¡ ýadiŸe pýeruçen¡

; ------ n vrat registr…

         pop       ax
         iret

INT08    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 09h
; -----------------------------------------------------------------------------

INT09    PROC      FAR

; ------ £schova registr…

         push      ax
         push      cx

; ------ uvolnØn¡ ýadiŸe pýeruçen¡

         mov       al,20h
         out       [20h],al                 ; uvolnØn¡ ýadiŸe pýeruçen¡
         sti

; ------ uzamŸen¡ kl vesnice

         call      Cekej09                  ; Ÿek n¡ na pýipravenost kl vesnice
         mov       al,0adh
         out       [64h],al                 ; vysl n¡ povelu-uzamŸen¡ kl vesnice

; ------ Ÿten¡ k¢du kl vesy

         call      Cekej09                  ; Ÿek n¡ na pýipravenost kl vesnice
         in        al,[60h]

; ------ pýeruçen¡ programu

         cmp       al,1
         jne       Int095
         or        byte ptr cs:[Param],bit0 ; pý¡znak pýeruçen¡ programu ESC

; ------ uvolnØn¡ kl vesnice

Int095:  call      Cekej09                  ; Ÿek n¡ na pýipravenost kl vesnice
         mov       al,0aeh
         out       [64h],al                 ; vysl n¡ povelu-uvolnØn¡ kl vesnice

; ------ n vrat registr…

         pop       cx
         pop       ax
         iret

Int09    ENDP

; -----------------------------------------------------------------------------
;        Ÿek n¡ na pýipravenost kl vesnice (niŸ¡ registry CX a AL !)
; -----------------------------------------------------------------------------

Cekej09  PROC      NEAR

         cli
         mov       cx,5000
Cekej091:in        al,[64h]
         test      al,bit1
         loopnz    Cekej091
         ret

Cekej09  ENDP

; *****************************************************************************
;                             InitPort
;                        inicializace port…
; -----------------------------------------------------------------------------
; VSTUP: DS=datovì segment
; *****************************************************************************

InitPort PROC      NEAR

; ------ £schova registr…

         push      ax
         push      bx
         push      cx
         push      dx
         push      es

; ------ vypnut¡ motor… disketovìch mechanik

         mov       dx,3f2h
         mov       al,0ch
         out       dx,al                    ; vypnut¡ motor… mechanik
         push      ds
         xor       ax,ax
         mov       ds,ax
         and       byte ptr ds:[43fh],not bit0+bit1+bit2+bit3+bit4+bit5 ; motory

; ------ inicializace adres port…

         mov       ax,ds:[408h]
         or        ax,ax
         jnz       InitPrt1
         mov       ax,ds:[40ah]
         or        ax,ax
         jnz       InitPrt1
         mov       ax,ds:[40ch]
         or        ax,ax
         jnz       InitPrt1
         mov       ax,ds:[40eh]
         or        ax,ax
         jnz       InitPrt1
         mov       ax,378h
InitPrt1:inc       ax
         inc       ax
         mov       word ptr cs:[PortLPT+1],ax    ; adresa portu LPT
         pop       ds
         mov       byte ptr ds:[OutPort],00000101b ; vìstupn¡ slovo na port

; ------ £schova vektoru INT 08h

         mov       ax,3508h
         int       21h                      ; poskytnut¡ adresy INT 08h
         mov       word ptr ds:[Old08],bx
         mov       word ptr ds:[Old08+2],es ; £schova adresy INT 08h

; ------ £schova vektoru INT 09h

         mov       ax,3509h
         int       21h                      ; poskytnut¡ adresy INT 09h
         mov       word ptr ds:[Old09],bx
         mov       word ptr ds:[Old09+2],es ; £schova adresy INT 09h

; ------ £schova registru masky pýeruçen¡

         in        al,[21h]                 ; registr masky pýeruçen¡
         mov       ds:[OldMask],al          ; £schova masky pýeruçen¡

; ------ pýechodnì z kaz vçech pýeruçen¡

         cli                                ; z kaz pýeruçen¡
         mov       al,0ffh
         out       [21h],al                 ; z kaz vçech pýeruçen¡

; ------ instalace INT 08h

         mov       dx,offset Int08          ; obsluha INT 08h
         mov       ax,2508h
         int       21h                      ; instalace obsluhy INT 08h

; ------ instalace INT 09h

         mov       dx,offset Int09          ; obsluha INT 09h
         mov       ax,2509h
         int       21h                      ; instalace obsluhy INT 09h

; ------ inicializace hodin INT 08h

         mov       al,34h
         out       [43h],al                 ; povel pro nastaven¡ hodin
         mov       al,ds:[Konst08]          ; dØlic¡ konstanta pro hodiny
         out       [40h],al                 ; dØlic¡ konstanta pro hodiny
         mov       al,0
         out       [40h],al                 ; vyçç¡ bajt dØlic¡ konstanty

; ------ uvolnØn¡ pýeruçen¡ od kl vesnice a hodin

         mov       al,0fch
         out       [21h],al                 ; uvolnØn¡ pýeruçen¡
         sti                                ; povolen¡ pýeruçen¡

; ------ n vrat registr…

         pop       es
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InitPort ENDP

; *****************************************************************************
;                                DeInit
;                         odinstalov n¡ port…
; -----------------------------------------------------------------------------
; VSTUP: DS=datovì segment
; *****************************************************************************

DeInit   PROC      NEAR

; ------ £schova registr…

         push      ax
         push      bx
         push      cx
         push      dx
         push      es

; ------ pýechodnì z kaz vçech pýeruçen¡

         mov       al,0ffh
         out       [21h],al                 ; z kaz vçech pýeruçen¡
         cli                                ; z kaz pýeruçen¡

; ------ vypnut¡ vìstupu na reproduktor

         in        al,[61h]
         and       al,not 3
         out       [61h],al                 ; vypnut¡ vìstupu na reproduktor

; ------ standardn¡ nastaven¡ hodin

         mov       al,34h
         out       [43h],al                 ; povel
         mov       al,0
         out       [40h],al                 ; konstanta - n¡§ç¡ bajt
         out       [40h],al                 ; konstanta - vyçç¡ bajt

; ------ standardn¡ nastaven¡ Ÿ¡taŸe reproduktoru

         mov       al,0b6h                  ; povel
         out       [43h],al
         mov       al,5                     ; konstanta asi tak 920 Hz
         out       [42h],al                 ; konstanta - n¡§ç¡ bajt
         out       [42h],al                 ; konstanta - vyçç¡ bajt

; ------ n vrat adresy INT 08h

         push      ds
         lds       dx,ds:[Old08]            ; p…vodn¡ adresa INT 08h
         mov       ax,2508h
         int       21h                      ; n vrat adresy INT 08h
         pop       ds

; ------ n vrat adresy INT 09h

         push      ds
         lds       dx,ds:[Old09]            ; p…vodn¡ adresa INT 09h
         mov       ax,2509h
         int       21h                      ; n vrat adresy INT 09h
         pop       ds

; ------ n vrat registru pýeruçen¡

         mov       al,ds:[OldMask]          ; p…vodn¡ registr masky pýeruçen¡
         out       [21h],al                 ; n vrat registru masky pýeruçen¡
         sti                                ; povolen¡ pýeruçen¡

; ------ Ÿten¡ hodin syst‚mov‚ho Ÿasu (AT)

         mov       dl,8ah                   ; pýednastaven¡ na nesmysl
         mov       ah,2
         int       1ah                      ; Ÿten¡ hodin
         cmp       dl,1                     ; pýeteŸen¡ pýes p…lnoc ?
         ja        Deinit3                  ; hodiny neplat¡

; ------ n vrat pý¡znaku pýeteŸen¡ pýes p…lnoc

         jne       DeInit2                  ; nen¡ pýeteŸen¡ pýes p…lnoc
         xor       ax,ax
         mov       es,ax
         mov       byte ptr es:[470h],dl    ; n vrat pý¡znaku pýeteŸen¡ p…lnoci

; ------ konverze z BCD form tu na bin rn¡

DeInit2: mov       al,ch                    ; hodina
         call      BcdBin                   ; konverze na bin rn¡ tvar
         mov       ch,al
         mov       al,cl                    ; minuta
         call      BcdBin                   ; konverze na bin rn¡ tvar
         mov       cl,al
         mov       al,dh                    ; sekunda
         call      BcdBin                   ; konverze na bin rn¡ tvar
         mov       dh,al

; ------ nastaven¡ Ÿasu

         xor       dl,dl                    ; setina sekundy
         mov       ah,2dh
         int       21h                      ; nastaven¡ syst‚mov‚ho Ÿasu

DeInit3:

; ------ n vrat registr…

         pop       es
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DeInit   ENDP

; -----------------------------------------------------------------------------
;        Konverze Ÿ¡sla z BCD tvaru na bin rn¡
; -----------------------------------------------------------------------------

BcdBin   PROC      NEAR

         push      cx
         mov       ch,al
         and       ch,0fh
         and       al,0f0h
         mov       cl,4
         shr       al,cl
         mov       cl,10
         mul       cl
         add       al,ch
         pop       cx
         ret

BcdBin   ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

MemTxt   db        'Nedostatek pameti !',13,10,'$'
hlptxt   db        'Zadejte platne jmeno souboru k vyslani !'
CRTxt    db        13,10,'$'

; -----------------------------------------------------------------------------
;        zavadØŸ TURBO
; -----------------------------------------------------------------------------

Loader   label     byte
         db        1                        ; typ
LoadNam  db        17 dup(13)               ; jm‚no souboru
LoadDel  dw        5ah                      ; d‚lka zavadØŸe
LoadZac  dw        0d400h                   ; zaŸ tek zavadØŸe
LoadStrt dw        0d400h                   ; start zavadØŸe
LoadComm db        5bh,96h,0a5h,9dh,9ah,0b7h,5dh ; text "[turbo]"
         db        95 dup(0), 0cdh,0        ; zbytek koment ýe
LoadPrg  label     byte                     ; program
         db        3eh,8                    ; D400: LD A,8
         db        0d3h,0ceh                ; D402: OUT (0ceh),A
         db        0e5h                     ; D404: PUSH HL
         db        21h,0,0                  ; D405: LD HL,0
         db        0d3h,0e4h                ; D408: OUT (0e4h),A
         db        7eh                      ; D40A: LD A,(HL)
         db        0d3h,0e0h                ; D40B: OUT (0e0h),A
         db        77h                      ; D40D: LD (HL),A
         db        23h                      ; D40E: INC HL
         db        7ch
         db        0feh,10h
         db        20h,0f4h
         db        3ah,4bh,0d4h
         db        32h,4bh,0ah
         db        3ah,4ch,0d4h
         db        32h,12h,5
         db        21h,4dh,0d4h
         db        11h,2,11h
         db        1,0dh,0
         db        0edh,0b0h
         db        0e1h
         db        7ch
         db        0feh,0d4h
         db        28h,12h
         db        2ah,4,11h
         db        0d9h
         db        21h,0,12h
         db        22h,4,11h
         db        0cdh,2ah,0
         db        0d3h,0e4h
         db        0c3h,9ah,0e9h
         db        0cdh,2ah,0
         db        0d3h,0e4h
         db        0c3h,24h,1
LoadKon1 db        15h
LoadKon2 db        1
LoadHlav db        13 dup(0)                ; hlaviŸka od offsetu poŸtu bajt…
LoadEnd  label     byte

TextVys  db        'Vysilam $'

Param    db        0                        ; parametry
                                            ;  bit 0: 1=pýeruçen¡ ESC

CitImp   db        0                        ; Ÿ¡taŸ impuls… ke zmØnØ sign lu

SegmVRAM dw        0b000h                   ; segment videopamØti

Konst08  db        75                       ; dØlic¡ konstanta hodin
                                            ;     (16.57 kHz / 60.34 us)
                                            ;      hodiny 1 193 182 Hz
DelImp   db        4                        ; z kladn¡ d‚lka impulsu

; ------ z hlav¡ souboru (80h bajt…)

Hlava    label     byte
HlavaTyp db        1                        ; typ souboru (1=stroj., 5=BASIC)
HlavaNam db        17 dup(" ")              ; jm‚no souboru
HlavaDel dw        0                        ; d‚lka souboru
HlavaBeg dw        1200h                    ; poŸ teŸn¡ adresa souboru
HlavaExe dw        1200h                    ; startovac¡ adresa programu
HlavaCom db        80h - 24 dup(0)          ; pozn mka souboru
HlavaEnd label     byte

Old08    dd        ?                        ; p…vodn¡ adresa INT 08h
Old09    dd        ?                        ; p…vodn¡ adresa INT 09h
OldMask  db        ?                        ; p…vodn¡ maska pýeruçen¡

DatSegm  dw        ?                        ; adresa datov‚ho bloku
DatNum   dw        ?                        ; poŸet bajt… v bufferu

OutPort  db        ?                        ; vìstup na port LPT

         dw        200h dup(?)              ; z sobn¡k
zasob    label     byte                     ; konec z sobn¡ku

konec    label     byte                     ; konec programu

code     ends
         end       start

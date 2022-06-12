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

code     segment
         assume    cs:code,ds:code
         org       100h

; ------ zmen®en° souáasnÇho konce bloku programu

start:   mov       bx,offset(Konec-Start+10fh)/16 ; velikost programu v odstav.
         mov       ah,4ah
         int       21h                      ; zmen®en° bloku pamàti
         mov       dx,offset MemTxt
         jc        Chyba2                   ; nedostatek pamàti

; ------ inicializace z†sobn°ku

         mov       sp,offset Zasob

; ------ vytvo©en° datovÇho bloku

         mov       bx,1000h                 ; velikost datovÇho bloku
         mov       ah,48h
         int       21h                      ; vytvo©en° datovÇho bloku
         jc        Chyba2                   ; nedostatek pamàti
         mov       ds:[DatSegm],ax          ; adresa datovÇho bloku

; ------ zaá†tek jmÇna souboru

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

; ------ chyba - nen° nic zad†no

Chyba:   mov       dx,offset HlpTxt
Chyba2:  mov       ah,9
         int       21h
         int       20h

; ------ oznaáen° konce jmÇna souboru

Start2:  jcxz      Start3
         lodsb
         dec       cx
         cmp       al," "
         ja        Start2
         dec       si
Start3:  mov       byte ptr ds:[si],0

; ------ otev©en° souboru

         mov       ax,3d00h
         int       21h                      ; otev©en° souboru pro áten°
         jc        Chyba                    ; chybnÇ zad†n° souboru
         mov       bx,ax                    ; identifik†tor souboru

; ------ naáten° hlaviáky souboru

         mov       cx,offset(HlavaEnd-Hlava) ; dÇlka hlaviáky
         mov       dx,offset Hlava          ; zaá†tek hlaviáky
         mov       ah,3fh
         int       21h                      ; naáten° hlaviáky souboru

; ------ naáten° souboru do pamàti

         push      ds
         mov       ds,ds:[DatSegm]          ; datovò segment
         mov       cx,0ffffh                ; velikost dat
         xor       dx,dx                    ; adresa k naáten° dat
         mov       ah,3fh
         int       21h                      ; naáten° 1. á†sti souboru do pamàti
         pop       ds
         mov       ds:[DatNum],ax           ; poáet bajtñ

; ------ uzav©en° souboru

         pushf
         mov       ah,3eh
         int       21h                      ; uzav©en° souboru
         popf
         jc        Chyba                    ; chyba áten°

; ------ hl†®en° o vys°l†n° souboru

         mov       dx,offset TextVys
         mov       ah,9
         int       21h

; ------ zobrazen° jmÇna souboru

         mov       cx,17                    ; max. dÇlka textu
         mov       si,offset HlavaNam
Start6:  mov       dl,ds:[si]
         inc       si
         cmp       dl,13
         je        Start62
         mov       ah,2
         int       21h
         loop      Start6
Start62:

; ------ vysl†n° hlaviáky souboru

         mov       di,8000                  ; dÇlka £vodn°ho t¢nu
         mov       bh,40                    ; dÇlka synchronizace 1
         mov       bl,40                    ; dÇlka synchronizace 2
         mov       cx,offset(HlavaEnd-Hlava) ; dÇlka hlaviáky
         push      ds
         pop       es                       ; segment adresy hlaviáky
         mov       si,offset Hlava          ; hlaviáka
         call      SaveHD                   ; vysl†n° hkaviáky
         jc        StartX                   ; p©eru®en° programu

; ------ vysl†n° dat souboru

         shr       bh,1                     ; synchronizace 1
         shr       bl,1                     ; synchronizace 2
         mov       cx,ds:[HlavaDel]         ; dÇlka souboru
         xor       si,si                    ; poá†teán° adresa
         mov       es,ds:[DatSegm]          ; datovò segment
         call      SaveHD                   ; vysl†n° dat souboru

; ------ konec programu

StartX:
         mov       dx,offset CRTxt
         mov       ah,9
         int       21h

         int       20h

; -----------------------------------------------------------------------------
;        vysl†n° hlaviáky nebo dat
; -----------------------------------------------------------------------------
; VSTUP: BH=dÇlka synchronizace 1
;        BL=dÇlka synchronizace 2
;        CX=dÇlka bloku dat
;        DI=dÇlka £vodn°ho t¢nu
;        ES:SI=poá†teán° adresa dat
;        DS=datovò segment
; VùSTUP:CY=p©eru®en° programu
; -----------------------------------------------------------------------------

SaveHD   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      dx
         call      InitPort                 ; instalace a inicializace portñ

; ------ kontroln° souáet dat (do registru DX)

         call      KontrS                   ; kontroln° souáet hlaviáky souboru

; ------ vysl†n° £vodu p©ed z†pisem

         call      SaveUvod                 ; vysl†n° £vodn°ho t¢nu a synchron.
         jc        SaveHD9                  ; p©eru®en° programu

; ------ vysl†n° obsahu dat

         call      SavBlok                  ; vysl†n° obsahu dat
         jc        SaveHD9                  ; p©eru®en° programu

; ------ vysl†n° kontroln°ho souátu

         mov       al,dh                    ; vy®®° bajt kontroln°ho souátu
         call      SavByte                  ; vysl†n° vy®®°ho bajtu kontr.souátu
         mov       al,dl                    ; nië®° bajt kontroln°ho souátu
         call      SavByte                  ; vysl†n° nië®°ho bajtu kontr.souátu

; ------ vysl†n° STOP bitu "1"

         stc                                ; p©°znak bitu "1"
         call      SavBit                   ; vysl†n° stop bitu "1"

; ------ n†vrat registrñ

SaveHD9: pushf
         call      DeInit                   ; n†vrat portñ a p©eru®en°
         popf
         pop       dx
         pop       ax
         ret

SaveHD   ENDP

; -----------------------------------------------------------------------------
;        kontroln° souáet bloku dat
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=adresa bloku dat
;        CX=poáet bajtñ dat
;        DS=datovò segment
; VùSTUP:DX=kontroln° souáet dat
; -----------------------------------------------------------------------------

KontrS   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si

; ------ kontrola, zda jsou nàjak† data

         xor       dx,dx                    ; st©adaá kontroln°ho souátu
         jcxz      KontrS9                  ; nejsou ë†dn† data

; ------ p©iáten° jednoho bajtu dat

KontrS1: mov       al,es:[si]               ; datovò bajt k p©iáten°
         inc       si                       ; zvò®en° ukazatele dat
         mov       ah,8                     ; poáet bitñ bajtu
KontrS2: shl       al,1                     ; jeden bit k p©iáten°
         adc       dx,0                     ; p©iáten° bitu ke st©adaái
         dec       ah                       ; á°taá bitñ
         jnz       KontrS2                  ; p©iáten° dal®°ho bitu bajtu
         loop      KontrS1                  ; p©iáten° dal®°ho bajtu

; ------ n†vrat registrñ

KontrS9: pop       si
         pop       cx
         pop       ax
         ret

KontrS   ENDP

; -----------------------------------------------------------------------------
;        vysl†n° £vodu dat
; -----------------------------------------------------------------------------
; VSTUP: DI=poáet bitñ £vodn°ho t¢nu ("0") (22000=hlaviáka, 11000=data)
;        BH=poáet bitñ synchronizace 1 ("1") (40=hlaviáka, 20=data)
;        BL=poáet bitñ synchronizace 2 ("0") (40=hlaviáka, 20=data)
;        DS=datovò segment
; VùSTUP:CY=p©eru®en° programu
; -----------------------------------------------------------------------------

SaveUvod PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      di

; ------ vysl†n° £vodn°ho t¢nu

         or        di,di
         jz        SaveUv11                 ; nen° ë†dnò bit
SaveUv1: clc                                ; vy®le se bit 0
         call      SavBit                   ; vysl†n° bitu 0
         jc        SaveUv9                  ; p©eru®en° programu
         dec       di                       ; á°taá bitñ £vodn°ho t¢nu
         jnz       SaveUv1                  ; vysl†n° dal®°ho bitu

; ------ vysl†n° synchronizace 1

SaveUv11:cmp       bh,0                     ; jsou nàjakÇ bity ?
         je        SaveUv22                 ; nejsou ë†dnÇ bity
SaveUv2: stc                                ; vy®le se bit 1
         call      SavBit                   ; vysl†n° bitu 1
         dec       bh                       ; poáet bitñ synchronizace
         jnz       SaveUv2                  ; vysl†n° synchronizace 1

; ------ vysl†n° synchronizace 2

SaveUv22:cmp       bl,0                     ; jsou nàjakÇ bity ?
         je        SaveUv4                  ; nejsou ë†dnÇ bity
SaveUv3: clc                                ; vy®le se bit 0
         call      SavBit                   ; vysl†n° bitu 0
         dec       bl                       ; poáet bitñ synchronizace
         jnz       SaveUv3                  ; vysl†n° synchronizace 2

; ------ vysl†n° startovac°ho bitu

SaveUv4: stc                                ; vy®le se bit 1
         call      SavBit                   ; vysl†n° bitu 1

; ------ n†vrat registrñ

SaveUv9: pop       di
         pop       bx
         pop       ax
         ret

SaveUvod ENDP

; -----------------------------------------------------------------------------
;        vysl†n° bloku dat
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=adresa bloku dat
;        CX=poáet bajtñ k vysl†n°
;        DS=datovò segment
; VùSTUP:CY=p©eru®en° programu
; -----------------------------------------------------------------------------

SavBlok  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si

; ------ kontrola, zda jsou nàjak† data k vysl†n°

         clc
         jcxz      SavBlok9                 ; nejsou ë†dn† data

; ------ vysl†n° bloku dat

         cld
SavBlok1:mov       al,es:[si]               ; bajt k vysl†n°
         inc       si                       ; zvò®en° ukazatele
         call      SavByte                  ; vysl†n° jednoho bajtu dat
         jc        SavBlok9                 ; p©eru®en° programu
         loop      SavBlok1                 ; vysl†n° dal®°ho bajtu

; ------ n†vrat registrñ

SavBlok9:pop       si
         pop       cx
         pop       ax
         ret

SavBlok  ENDP

; -----------------------------------------------------------------------------
;        vysl†n° jednoho bajtu
; -----------------------------------------------------------------------------
; VSTUP: AL=bajt k vysl†n°
;        DS=datovò segment
; VùSTUP:CY=p©eru®en°
; niá° registr AX !
; -----------------------------------------------------------------------------

SavByte  PROC      NEAR

         stc                                ; start bit "1"
         call      SavBit                   ; vysl†n° startovac°ho bitu "1"
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
;        vysl†n° jednoho bitu
; -----------------------------------------------------------------------------
; VSTUP: CY=bit je 1 (NC=bit je 0)
;        DS=datovò segment
; VùSTUP:CY=p©eru®en°
; niá° registr AH !
; -----------------------------------------------------------------------------

SavBit   PROC      NEAR

; ------ stanoven° dÇlky impulsu

         mov       ah,ds:[DelImp]           ; dÇlka impulsu "0"
         jnc       SavBit1                  ; je bit 0
         shl       ah,1                     ; jinak impuls "1"

; ------ vysl†n° dvou impulsñ

SavBit1: call      SavImp                   ; vysl†n° impulsu "+"
         call      SavImp                   ; vysl†n° impulsu "-"
         ret

SavBit   ENDP

; -----------------------------------------------------------------------------
;        zah†jen° vys°l†n° jednoho impulsu
; -----------------------------------------------------------------------------
; VSTUP: AH=dÇlka impulsu
;        DS=datovò segment
; VùSTUP:CY=p©eru®en° programu
; -----------------------------------------------------------------------------

SavImp   PROC      NEAR

; ------ test, zda je p©eru®en° porgramu

         sti                                ; p©eru®en° mus° bòt povoleno
SavImp1: test      byte ptr ds:[Param],bit0 ; je p©eru®en° programu ?
         stc                                ; p©°znak p©eru®en°
         jnz       SavImp9                  ; je p©eru®en° programu

; ------ áek†n° na ukonáen° jednoho impulsu

         cmp       byte ptr ds:[CitImp],0   ; je jië celò impuls ?
         jne       SavImp1                  ; áek†n° na ukonáen° impulsu

; ------ zaá†tek novÇho impulsu

         mov       ds:[CitImp],ah           ; dÇlka novÇho impulsu
                                            ; zde je p©°znak NC
SavImp9: ret

SavImp   ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 08h
; -----------------------------------------------------------------------------

INT08    PROC      FAR

; ------ £schova registrñ

         push      ax

; ------ á°t†n° zmàny vòstupu

         mov       al,cs:[CitImp]           ; á°taá impulsñ
         cmp       al,0                     ; á°t† se impuls ?
         je        Int089                   ; neá°t† se impuls
         dec       al                       ; sn°ëen° á°taáe
         mov       cs:[CitImp],al           ; novò stav á°taáe
         jnz       Int089                   ; nen° dosaëeno 0

; ------ zmàna portu LPT

         push      dx
         mov       al,cs:[OutPort]          ; vòstup na port LPT
         xor       al,bit0                  ; zmàna sign†lu STROBE
         mov       cs:[OutPort],al          ; £schova novÇ hodnoty
PortLPT: mov       dx,37ah                  ; vòstupn° port
         out       dx,al                    ; vòstup bajtu LPT
         pop       dx

; ------ uvolnàn° ©adiáe p©eru®en°

Int089:  mov       al,20h
         out       [20h],al                 ; uvolnàn° ©adiáe p©eru®en°

; ------ n†vrat registrñ

         pop       ax
         iret

INT08    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 09h
; -----------------------------------------------------------------------------

INT09    PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx

; ------ uvolnàn° ©adiáe p©eru®en°

         mov       al,20h
         out       [20h],al                 ; uvolnàn° ©adiáe p©eru®en°
         sti

; ------ uzamáen° kl†vesnice

         call      Cekej09                  ; áek†n° na p©ipravenost kl†vesnice
         mov       al,0adh
         out       [64h],al                 ; vysl†n° povelu-uzamáen° kl†vesnice

; ------ áten° k¢du kl†vesy

         call      Cekej09                  ; áek†n° na p©ipravenost kl†vesnice
         in        al,[60h]

; ------ p©eru®en° programu

         cmp       al,1
         jne       Int095
         or        byte ptr cs:[Param],bit0 ; p©°znak p©eru®en° programu ESC

; ------ uvolnàn° kl†vesnice

Int095:  call      Cekej09                  ; áek†n° na p©ipravenost kl†vesnice
         mov       al,0aeh
         out       [64h],al                 ; vysl†n° povelu-uvolnàn° kl†vesnice

; ------ n†vrat registrñ

         pop       cx
         pop       ax
         iret

Int09    ENDP

; -----------------------------------------------------------------------------
;        áek†n° na p©ipravenost kl†vesnice (niá° registry CX a AL !)
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
;                       inicializace portñ
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

InitPort PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      es

; ------ vypnut° motorñ disketovòch mechanik

         mov       dx,3f2h
         mov       al,0ch
         out       dx,al                    ; vypnut° motorñ mechanik
         push      ds
         xor       ax,ax
         mov       ds,ax
         and       byte ptr ds:[43fh],not bit0+bit1+bit2+bit3+bit4+bit5 ; motory

; ------ inicializace adres portñ

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
         mov       byte ptr ds:[OutPort],00000101b ; vòstupn° slovo na port

; ------ £schova vektoru INT 08h

         mov       ax,3508h
         int       21h                      ; poskytnut° adresy INT 08h
         mov       word ptr ds:[Old08],bx
         mov       word ptr ds:[Old08+2],es ; £schova adresy INT 08h

; ------ £schova vektoru INT 09h

         mov       ax,3509h
         int       21h                      ; poskytnut° adresy INT 09h
         mov       word ptr ds:[Old09],bx
         mov       word ptr ds:[Old09+2],es ; £schova adresy INT 09h

; ------ £schova registru masky p©eru®en°

         in        al,[21h]                 ; registr masky p©eru®en°
         mov       ds:[OldMask],al          ; £schova masky p©eru®en°

; ------ p©echodnò z†kaz v®ech p©eru®en°

         cli                                ; z†kaz p©eru®en°
         mov       al,0ffh
         out       [21h],al                 ; z†kaz v®ech p©eru®en°

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
         out       [43h],al                 ; povel pro nastaven° hodin
         mov       al,ds:[Konst08]          ; dàlic° konstanta pro hodiny
         out       [40h],al                 ; dàlic° konstanta pro hodiny
         mov       al,0
         out       [40h],al                 ; vy®®° bajt dàlic° konstanty

; ------ uvolnàn° p©eru®en° od kl†vesnice a hodin

         mov       al,0fch
         out       [21h],al                 ; uvolnàn° p©eru®en°
         sti                                ; povolen° p©eru®en°

; ------ n†vrat registrñ

         pop       es
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InitPort ENDP

; *****************************************************************************
;                                DeInit
;                          odinstalov†n° portñ
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

DeInit   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      es

; ------ p©echodnò z†kaz v®ech p©eru®en°

         mov       al,0ffh
         out       [21h],al                 ; z†kaz v®ech p©eru®en°
         cli                                ; z†kaz p©eru®en°

; ------ standardn° nastaven° hodin

         mov       al,34h
         out       [43h],al                 ; povel
         mov       al,0
         out       [40h],al                 ; konstanta - n°ë®° bajt
         out       [40h],al                 ; konstanta - vy®®° bajt

; ------ n†vrat adresy INT 08h

         push      ds
         lds       dx,ds:[Old08]            ; pñvodn° adresa INT 08h
         mov       ax,2508h
         int       21h                      ; n†vrat adresy INT 08h
         pop       ds

; ------ n†vrat adresy INT 09h

         push      ds
         lds       dx,ds:[Old09]            ; pñvodn° adresa INT 09h
         mov       ax,2509h
         int       21h                      ; n†vrat adresy INT 09h
         pop       ds

; ------ n†vrat registru p©eru®en°

         mov       al,ds:[OldMask]          ; pñvodn° registr masky p©eru®en°
         out       [21h],al                 ; n†vrat registru masky p©eru®en°
         sti                                ; povolen° p©eru®en°

; ------ áten° hodin systÇmovÇho áasu (AT)

         mov       dl,8ah                   ; p©ednastaven° na nesmysl
         mov       ah,2
         int       1ah                      ; áten° hodin
         cmp       dl,1                     ; p©eteáen° p©es pñlnoc ?
         ja        Deinit3                  ; hodiny neplat°

; ------ n†vrat p©°znaku p©eteáen° p©es pñlnoc

         jne       DeInit2                  ; nen° p©eteáen° p©es pñlnoc
         xor       ax,ax
         mov       es,ax
         mov       byte ptr es:[470h],dl    ; n†vrat p©°znaku p©eteáen° pñlnoci

; ------ konverze z BCD form†tu na bin†rn°

DeInit2: mov       al,ch                    ; hodina
         call      BcdBin                   ; konverze na bin†rn° tvar
         mov       ch,al
         mov       al,cl                    ; minuta
         call      BcdBin                   ; konverze na bin†rn° tvar
         mov       cl,al
         mov       al,dh                    ; sekunda
         call      BcdBin                   ; konverze na bin†rn° tvar
         mov       dh,al

; ------ nastaven° áasu

         xor       dl,dl                    ; setina sekundy
         mov       ah,2dh
         int       21h                      ; nastaven° systÇmovÇho áasu

DeInit3:

; ------ n†vrat registrñ

         pop       es
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DeInit   ENDP

; -----------------------------------------------------------------------------
;        Konverze á°sla z BCD tvaru na bin†rn°
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

TextVys  db        'Vysilam $'

Param    db        0                        ; parametry
                                            ;  bit 0: 1=p©eru®en° ESC

CitImp   db        0                        ; á°taá impulsñ ke zmànà sign†lu

SegmVRAM dw        0b000h                   ; segment videopamàti

Konst08  db        77                       ; dàlic° konstanta hodin
                                            ;     (16.57 kHz / 60.34 us)
                                            ;      hodiny 1 193 182 Hz
DelImp   db        2                        ; z†kladn° dÇlka impulsu

; ------ z†hlav° souboru (80h bajtñ)

Hlava    label     byte
HlavaTyp db        1                        ; typ souboru (1=stroj., 5=BASIC)
HlavaNam db        17 dup(" ")              ; jmÇno souboru
HlavaDel dw        0                        ; dÇlka souboru
HlavaBeg dw        1200h                    ; poá†teán° adresa souboru
HlavaExe dw        1200h                    ; startovac° adresa programu
HlavaCom db        80h - 24 dup(0)          ; pozn†mka souboru
HlavaEnd label     byte

Old08    dd        ?                        ; pñvodn° adresa INT 08h
Old09    dd        ?                        ; pñvodn° adresa INT 09h
OldMask  db        ?                        ; pñvodn° maska p©eru®en°

DatSegm  dw        ?                        ; adresa datovÇho bloku
DatNum   dw        ?                        ; poáet bajtñ v bufferu

OutPort  db        ?                        ; vòstup na port LPT

         dw        200h dup(?)              ; z†sobn°k
zasob    label     byte                     ; konec z†sobn°ku

konec    label     byte                     ; konec programu

code     ends
         end       start

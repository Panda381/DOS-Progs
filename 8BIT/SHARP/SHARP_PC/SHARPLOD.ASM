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

Code     segment
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
         mov       ds:[SoubName],dx         ; £schova adresy jmÇna souboru

; ------ test, zda soubor jië existuje

         mov       cx,7
         mov       ah,4eh
         int       21h                      ; existuje jië soubor ?
         mov       dx,offset ExTxt
         jnc       Chyba2                   ; chyba - soubor neexistuje

; ------ hl†®en° o zah†jen° p©°jmu

         mov       dx,offset Text1
         mov       ah,9
         int       21h

; ------ p©°jem hlaviáky souboru

         mov       di,100                   ; dÇlka £vodn°ho t¢nu
         mov       bh,40                    ; dÇlka synchronizace 1
         mov       bl,40                    ; dÇlka synchronizace 2
         mov       cx,offset(HlavaEnd-Hlava) ; dÇlka hlaviáky
         push      ds
         pop       es                       ; segment adresy hlaviáky
         mov       si,offset Hlava          ; hlaviáka
         call      LoadHD                   ; p©°jem hlaviáky
         jc        StartX                   ; p©eru®en° programu

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

; ------ p©°jem dat souboru

         mov       di,100                   ; dÇlka £vodn°ho t¢nu
         mov       bh,20                    ; synchronizace 1
         mov       bl,20                    ; synchronizace 2
         mov       cx,ds:[HlavaDel]         ; dÇlka souboru
         xor       si,si                    ; poá†teán° adresa
         mov       es,ds:[DatSegm]          ; datovò segment
         call      LoadHD                   ; p©°jem dat souboru
         jc        StartX                   ; p©eru®en° programu

; ------ od©†dkov†n°

         mov       dx,offset CRTxt
         mov       ah,9
         int       21h

; ------ test, zda byla chyba CRC

         test      byte ptr ds:[Param],bit1
         jz        Start8

         mov       dx,offset CRCTxt
StartCh1:mov       ah,9
         int       21h
         jmp       short StartX

; ------ vytvo©en° souboru

Start8:  xor       cx,cx
         mov       dx,ds:[SoubName]         ; adresa jmÇna souboru
         mov       ah,3ch
         int       21h                      ; vytvo©en° souboru
         mov       dx,offset CreaTxt
         jc        StartCh1                 ; chyba - nelze vytvo©it
         mov       bx,ax                    ; identifik†tor souboru

; ------ uloëen° hlaviáky souboru

         mov       cx,offset(HlavaEnd-Hlava) ; dÇlka hlaviáky
         mov       dx,offset Hlava          ; zaá†tek hlaviáky
         mov       ah,40h
         int       21h                      ; z†pis hlaviáky souboru

; ------ z†pis dat souboru

         push      ds
         mov       cx,ds:[HlavaDel]         ; velikost dat
         mov       ds,ds:[DatSegm]          ; datovò segment
         xor       dx,dx                    ; adresa k z†pisu dat
         mov       ah,40h
         int       21h                      ; z†pis souboru do souboru
         pop       ds
         mov       dx,offset WrTxt
         jc        StartCh1
         cmp       ax,cx
         jne       StartCh1

; ------ uzav©en° souboru

         mov       ah,3eh
         int       21h                      ; uzav©en° souboru
         jc        StartCh1

; ------ konec programu

StartX:
         int       20h

; -----------------------------------------------------------------------------
;        p©°jem hlaviáky nebo dat
; -----------------------------------------------------------------------------
; VSTUP: BH=dÇlka synchronizace 1
;        BL=dÇlka synchronizace 2
;        CX=dÇlka bloku dat
;        DI=dÇlka £vodn°ho t¢nu
;        ES:SI=poá†teán° adresa dat
;        DS=datovò segment
; VùSTUP:CY=p©eru®en° programu
; -----------------------------------------------------------------------------

LoadHD   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      dx
         call      InitPort                 ; instalace a inicializace portñ

; ------ p©°jem £vodu p©ed daty

         call      LoadUvod                 ; p©°jem £vodn°ho t¢nu a synchron.
         jc        LoadHD9                  ; p©eru®en° programu

; ------ p©°jem dat

         call      LoadBlok                 ; vysl†n° obsahu dat
         jc        LoadHD9                  ; p©eru®en° programu

; ------ p©°jem kontroln°ho souátu

         call      LoadByte                 ; p©°jem prvn°ho bajtu CRC
         jc        LoadHD9                  ; p©eru®en° programu
         mov       ah,al                    ; £schova kontroln°ho souátu HIGH
         call      LoadByte                 ; p©°jem druhÇho bajtu CRC
         jc        LoadHD9                  ; p©eru®en° programu

; ------ kontrola kontroln°ho souáet dat

         call      KontrS                   ; kontroln° souáet dat
         cmp       ax,dx                    ; souhlas° kontroln° souáet ?
         je        LoadHD9                  ; kontroln° souáet je OK
         or        byte ptr ds:[Param],bit1 ; p©°znak chyby CRC

; ------ n†vrat registrñ

LoadHD9: pushf
         call      DeInit                   ; n†vrat portñ a p©eru®en°
         popf
         pop       dx
         pop       ax
         ret

LoadHD   ENDP

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
;        synchronizace na £vod dat
; -----------------------------------------------------------------------------
; VSTUP: BH=poáet bitñ synchronizace 1 ("1") (40=hlaviáka, 20=data)
;        BL=poáet bitñ synchronizace 2 ("0") (40=hlaviáka, 20=data)
;        DS=datovò segment
; VùSTUP:CY=p©eru®en° programu
; -----------------------------------------------------------------------------

LoadUvod PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      bx

; ------ n†vrat registrñ p©i chybà

LoadUv1: pop       bx
         push      bx

; ------ áek†n° na £vodn° hranu sign†lu "1"

         call      LoadImp                  ; áek†n° na £vodn° hranu sign†lu
         jc        LoadUv9                  ; p©eru®en° programu

; ------ mà©en° dÇlky impulsu "1"

         mov       ah,bit3
         mov       cx,-1
         call      Cekej                    ; áek†n° na zaá†tek impulsu "0"
         jc        LoadUv9                  ; p©eru®en° programu
         jcxz      LoadUv1                  ; p©eteáen° áasu

; ------ vòpoáet konstanty

         neg       cx                       ; poáet cyklñ
         mov       ax,cx
         shr       ax,1
         add       cx,ax                    ; doba * 1.5
         jc        LoadUv1
         jcxz      LoadUv1                  ; p©eteáen°
         mov       ds:[Delka0],cx           ; dÇlka impulsu "0"
         shl       cx,1
         jc        LoadUv1                  ; p©eteáen°
         mov       ds:[Delka1],cx           ; dÇlka impulsu "1"

; ------ p©°jem £vodn°ho t¢nu

LoadUv2: call      LoadBit                  ; p©°jem jednoho bitu
         jc        LoadUv9                  ; p©eru®en° programu
         jz        LoadUv2                  ; je bit "0" - OK
         dec       bh                       ; prvn° bit se ztratil

; ------ p©°jem synchronizace 1

         cmp       bh,0                     ; jsou nàjakÇ bity ?
         je        LoadUv5                  ; nejsou ë†dnÇ bity
LoadUv4: call      LoadBit                  ; p©°jem dal®°ho bitu
         jc        LoadUv9                  ; p©eru®en° programu
         jz        LoadUv1                  ; nen° bit "1"
         dec       bh                       ; á°taá poëadovanòch bitñ
         jnz       LoadUv4                  ; p©°jem dal®°ho bitu

; ------ p©°jem synchronizace 2

LoadUv5: cmp       bl,0                     ; jsou nàjakÇ bity ?
         je        LoadUv7                  ; nejsou ë†dnÇ bity
LoadUv6: call      LoadBit                  ; p©°jem dal®°ho bitu
         jc        LoadUv9                  ; p©eru®en° programu
         jnz       LoadUv1                  ; nen° bit "0"
         dec       bl                       ; á°taá poëadovanòch bitñ
         jnz       LoadUv6                  ; p©°jem dal®°ho bitu

; ------ p©°jem startovac°ho bitu

LoadUv7: call      LoadBit                  ; p©°jem startovac°ho bitu
         jc        LoadUv9                  ; p©eru®en° programu
         jz        LoadUv1                  ; nen° startovac° bit "1"

; ------ n†vrat registrñ

LoadUv9: pop       bx
         pop       cx
         pop       ax
         ret

LoadUvod ENDP

; -----------------------------------------------------------------------------
;        p©°jem bloku dat
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=adresa k naáten° bloku dat
;        CX=poáet bajtñ k naáten° bloku dat
;        DS=datovò segment
; VùSTUP:CY=p©eru®en° programu
; -----------------------------------------------------------------------------

LoadBlok PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si

; ------ kontrola, zda jsou nàjak† data k vysl†n°

         clc
         jcxz      LoadBlk9                 ; nejsou ë†dn† data

; ------ p©°jem bloku dat

LoadBlk1:call      LoadByte                 ; p©°jem jednoho datovÇho bajtu
         jc        LoadBlk9                 ; p©eru®en° programu
         mov       es:[si],al               ; uloëen° bajtu
         inc       si                       ; zvò®en° adresy v bufferu
         loop      LoadBlk1                 ; p©°jem dal®°ho bajtu

; ------ n†vrat registrñ

LoadBlk9:pop       si
         pop       cx
         pop       ax
         ret

LoadBlok ENDP

; -----------------------------------------------------------------------------
;        p©°jem jednoho bajtu
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:CY=p©eru®en°
;        AL=p©ijatò bajt
; -----------------------------------------------------------------------------

LoadByte PROC      NEAR

         call      LoadBit
         mov       al,1

LoadByt1:call      LoadBit
         jc        LoadByt9                 ; p©eru®en° programu
         jz        LoadByt2                 ; je bit "0"
         stc                                ; je bit "1"
LoadByt2:rcl       al,1                     ; rotace bitu do AL
         jnc       LoadByt1                 ; p©°jem dal®°ho bitu
         clc

LoadByt9:ret

LoadByte ENDP

; -----------------------------------------------------------------------------
;        p©°jem jednoho bitu
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:NZ=je bit 1
;        CY=je p©eru®en° programu
; -----------------------------------------------------------------------------

LoadBit  PROC      NEAR

         push      ax
         push      cx
         push      dx

; ------ áek†n° na £vodn° hranu sign†lu

         xor       dx,dx                    ; st©adaá doby
LoadBit1:call      LoadImp                  ; áek†n° na £vodn° hranu sign†lu
         jc        LoadBit9                 ; p©eru®en° programu

; ------ zmà©en° dÇlky impulsu

         mov       ah,bit3
         mov       cx,-1
         call      Cekej                    ; áek†n° na zaá†tek impulsu "0"
         jc        LoadBit9                 ; p©eru®en° programu
         neg       cx                       ; poáet cyklñ
         add       cx,dx                    ; p©iáten° st©adaáe
         mov       dx,cx                    ; £schova do st©adaáe

; ------ filtrace kr†tkòch impulsñ

         mov       ax,ds:[Delka0]           ; krat®° impuls
         shr       ax,1                     ; minim†ln° doba
         cmp       cx,ax                    ; je minim†ln° doba ?
         jb        LoadBit1                 ; je p©°li® kr†tkò impuls

; ------ vòpoáet namà©enÇ doby

         mov       ax,cx
         shr       ax,1
         add       cx,ax                    ; doba * 1.5

; ------ vòpoáet st©edn° doby

         mov       ax,ds:[Delka0]
         add       ax,ds:[Delka1]
         shr       ax,1                     ; st©edn° hodnota

; ------ rozli®en°, zda je bit 0 nebo 1

         cmp       cx,ax                    ; je bit 0 nebo 1 ?
         jb        LoadBit3                 ; je bit 0

; ------ je bit 1

         shr       cx,1                     ; korekce na z†kladn° dÇlku "0"
         add       cx,ds:[Delka0]
         add       cx,ds:[Delka1]
         shr       cx,1
         mov       ds:[Delka1],cx
         shr       cx,1
         mov       ds:[Delka0],cx
         or        cx,cx
         jmp       short LoadBit9

; ------ je bit 0

LoadBit3:add       cx,ds:[Delka0]
         add       cx,ds:[Delka1]
         shr       cx,1
         mov       ds:[Delka1],cx
         shr       cx,1
         mov       ds:[Delka0],cx
         cmp       cx,cx

; ------ n†vrat registrñ

LoadBit9:pop       dx
         pop       cx
         pop       ax
         ret

LoadBit  ENDP

; -----------------------------------------------------------------------------
;        áek†n° na £vodn° hranu sign†lu (CY=p©eru®en°)
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:CY=p©eru®en°
; -----------------------------------------------------------------------------

LoadImp  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      dx
PortLPT: mov       dx,379h                  ; port LPT

; ------ test, zda je p©eru®en° porgramu

         sti                                ; p©eru®en° mus° bòt povoleno
LoadImp1:test      byte ptr ds:[Param],bit0 ; je p©eru®en° programu ?
         stc                                ; p©°znak p©eru®en°
         jnz       LoadImp9                 ; je p©eru®en° programu

; ------ áek†n° na konec stavu 1

         in        al,dx                    ; áten° stavu portu
         test      al,bit3                  ; test stavovÇho bitu
         jz        LoadImp1                 ; je stav 1 - áek†n° na konec

; ------ test, zda je p©eru®en° porgramu

LoadImp2:test      byte ptr ds:[Param],bit0 ; je p©eru®en° programu ?
         stc                                ; p©°znak p©eru®en°
         jnz       LoadImp9                 ; je p©eru®en° programu

; ------ áek†n° na zaá†tek novÇho stavu 1

         in        al,dx                    ; áten° stavu portu
         test      al,bit3                  ; test stavovÇho bitu
         jnz       LoadImp2                 ; je stav 0 - áek†n° na konec

; ------ n†vrat registrñ

LoadImp9:pop       dx
         pop       ax
         ret

LoadImp  ENDP

; -----------------------------------------------------------------------------
;        áek†n° po dobu CX na stav portu LPT AH (vrac° CX=zbytek konstanty)
; -----------------------------------------------------------------------------
; VSTUP: CX=max. doba pro áek†n°
;        AH=poëadovanò stav portu LPT (bit 3)
; VùSTUP:CX=zbylò poáet taktñ
;        CY=p©eru®en° programu
; -----------------------------------------------------------------------------

Cekej    PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      dx
         sti
PortLPT3:mov       dx,379h                  ; port LPT

; ------ test, zda je p©eru®en° programu

Cekej1:  test      byte ptr ds:[Param],bit0 ; je p©eru®en° programu ?
         stc                                ; p©°znak p©eru®en°
         jnz       Cekej9                   ; je p©eru®en° programu

; ------ test stavu portu LPT

         in        al,dx
         and       al,bit3
         cmp       al,ah
         loopne    Cekej1
         clc

; ------ n†vrat registrñ

Cekej9:  pop       dx
         pop       ax
         ret

Cekej    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 08h
; -----------------------------------------------------------------------------

INT08    PROC      FAR

; ------ £schova registrñ

         push      ax

; ------ uvolnàn° ©adiáe p©eru®en°

         mov       al,20h
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

         jmp       dword ptr cs:[Old09]
;         iret

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
         mov       word ptr cs:[PortLPT+1],ax    ; adresa portu LPT
;         mov       word ptr cs:[PortLPT2+1],ax   ; adresa portu LPT
         mov       word ptr cs:[PortLPT3+1],ax   ; adresa portu LPT
         pop       ds

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

; ------ uvolnàn° p©eru®en° od kl†vesnice a hodin

         mov       al,20h
         out       [20h],al
         mov       al,0fdh
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
;                         odinstalov†n° portñ
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

MemTxt   db        7,'Nedostatek pameti !',13,10,'$'
ExTxt    db        7,'Soubor jiz existuje !',13,10,'$'

CreaTxt  db        7,'Soubor nelze vytvorit !',13,10,'$'

WrTxt    db        7,'Chyba zapisu souboru !',13,10,'$'

hlptxt   db        7,'Zadejte jmeno souboru k prijmu !'
CRTxt    db        13,10,'$'

CRCTxt   db        7,'Chyba pri prenosu souboru !',13,10,'$'

Text1    db        'Prijimam $'

Param    db        0                        ; parametry
                                            ;  bit 0: 1=p©eru®en° ESC
                                            ;  bit 1: 1=chyba kontroln°ho souátu

CitImp   db        0                        ; á°taá impulsu k rozhodov†n°

Delka0   dw        100                      ; dÇlka impulsu "0"
Delka1   dw        100                      ; dÇlka impulsu "1"

SegmVRAM dw        0b000h                   ; segment videopamàti

Konst08  db        72                       ; áasov† konstanta hodin
                                            ;     (16.57 kHz / 60.34 us)
                                            ;      hodiny 1 193 182 Hz
DelImp   db        6                        ; dÇlka impulsu pro rozhodov†n°

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

SoubName dw        ?                        ; adresa jmÇna souboru

         dw        200h dup(?)              ; z†sobn°k
zasob    label     byte                     ; konec z†sobn°ku

konec    label     byte                     ; konec programu

code     ends
         end       start

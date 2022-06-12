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
         mov       ds:[SoubName],dx         ; £schova adresy jm‚na souboru

; ------ test, zda soubor ji§ existuje

         mov       cx,7
         mov       ah,4eh
         int       21h                      ; existuje ji§ soubor ?
         mov       dx,offset ExTxt
         jnc       Chyba2                   ; chyba - soubor neexistuje

; ------ hl çen¡ o zah jen¡ pý¡jmu

         mov       dx,offset Text1
         mov       ah,9
         int       21h

; ------ pý¡jem hlaviŸky souboru

         mov       di,100                   ; d‚lka £vodn¡ho t¢nu
         mov       bh,40                    ; d‚lka synchronizace 1
         mov       bl,40                    ; d‚lka synchronizace 2
         mov       cx,offset(HlavaEnd-Hlava) ; d‚lka hlaviŸky
         push      ds
         pop       es                       ; segment adresy hlaviŸky
         mov       si,offset Hlava          ; hlaviŸka
         call      LoadHD                   ; pý¡jem hlaviŸky
         jc        StartX                   ; pýeruçen¡ programu

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

; ------ pý¡jem dat souboru

         mov       di,100                   ; d‚lka £vodn¡ho t¢nu
         mov       bh,20                    ; synchronizace 1
         mov       bl,20                    ; synchronizace 2
         mov       cx,ds:[HlavaDel]         ; d‚lka souboru
         xor       si,si                    ; poŸ teŸn¡ adresa
         mov       es,ds:[DatSegm]          ; datovì segment
         call      LoadHD                   ; pý¡jem dat souboru
         jc        StartX                   ; pýeruçen¡ programu

; ------ odý dkov n¡

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

; ------ vytvoýen¡ souboru

Start8:  xor       cx,cx
         mov       dx,ds:[SoubName]         ; adresa jm‚na souboru
         mov       ah,3ch
         int       21h                      ; vytvoýen¡ souboru
         mov       dx,offset CreaTxt
         jc        StartCh1                 ; chyba - nelze vytvoýit
         mov       bx,ax                    ; identifik tor souboru

; ------ ulo§en¡ hlaviŸky souboru

         mov       cx,offset(HlavaEnd-Hlava) ; d‚lka hlaviŸky
         mov       dx,offset Hlava          ; zaŸ tek hlaviŸky
         mov       ah,40h
         int       21h                      ; z pis hlaviŸky souboru

; ------ z pis dat souboru

         push      ds
         mov       cx,ds:[HlavaDel]         ; velikost dat
         mov       ds,ds:[DatSegm]          ; datovì segment
         xor       dx,dx                    ; adresa k z pisu dat
         mov       ah,40h
         int       21h                      ; z pis souboru do souboru
         pop       ds
         mov       dx,offset WrTxt
         jc        StartCh1
         cmp       ax,cx
         jne       StartCh1

; ------ uzavýen¡ souboru

         mov       ah,3eh
         int       21h                      ; uzavýen¡ souboru
         jc        StartCh1

; ------ konec programu

StartX:
         int       20h

; -----------------------------------------------------------------------------
;        pý¡jem hlaviŸky nebo dat
; -----------------------------------------------------------------------------
; VSTUP: BH=d‚lka synchronizace 1
;        BL=d‚lka synchronizace 2
;        CX=d‚lka bloku dat
;        DI=d‚lka £vodn¡ho t¢nu
;        ES:SI=poŸ teŸn¡ adresa dat
;        DS=datovì segment
; VíSTUP:CY=pýeruçen¡ programu
; -----------------------------------------------------------------------------

LoadHD   PROC      NEAR

; ------ £schova registr…

         push      ax
         push      dx
         call      InitPort                 ; instalace a inicializace port…

; ------ pý¡jem £vodu pýed daty

         call      LoadUvod                 ; pý¡jem £vodn¡ho t¢nu a synchron.
         jc        LoadHD9                  ; pýeruçen¡ programu

; ------ pý¡jem dat

         call      LoadBlok                 ; vysl n¡ obsahu dat
         jc        LoadHD9                  ; pýeruçen¡ programu

; ------ pý¡jem kontroln¡ho souŸtu

         call      LoadByte                 ; pý¡jem prvn¡ho bajtu CRC
         jc        LoadHD9                  ; pýeruçen¡ programu
         mov       ah,al                    ; £schova kontroln¡ho souŸtu HIGH
         call      LoadByte                 ; pý¡jem druh‚ho bajtu CRC
         jc        LoadHD9                  ; pýeruçen¡ programu

; ------ kontrola kontroln¡ho souŸet dat

         call      KontrS                   ; kontroln¡ souŸet dat
         cmp       ax,dx                    ; souhlas¡ kontroln¡ souŸet ?
         je        LoadHD9                  ; kontroln¡ souŸet je OK
         or        byte ptr ds:[Param],bit1 ; pý¡znak chyby CRC

; ------ n vrat registr…

LoadHD9: pushf
         call      DeInit                   ; n vrat port… a pýeruçen¡
         popf
         pop       dx
         pop       ax
         ret

LoadHD   ENDP

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
;        synchronizace na £vod dat
; -----------------------------------------------------------------------------
; VSTUP: BH=poŸet bit… synchronizace 1 ("1") (40=hlaviŸka, 20=data)
;        BL=poŸet bit… synchronizace 2 ("0") (40=hlaviŸka, 20=data)
;        DS=datovì segment
; VíSTUP:CY=pýeruçen¡ programu
; -----------------------------------------------------------------------------

LoadUvod PROC      NEAR

; ------ £schova registr…

         push      ax
         push      cx
         push      bx

; ------ n vrat registr… pýi chybØ

LoadUv1: pop       bx
         push      bx

; ------ Ÿek n¡ na £vodn¡ hranu sign lu "1"

         call      LoadImp                  ; Ÿek n¡ na £vodn¡ hranu sign lu
         jc        LoadUv9                  ; pýeruçen¡ programu

; ------ mØýen¡ d‚lky impulsu "1"

         mov       ah,bit3
         mov       cx,-1
         call      Cekej                    ; Ÿek n¡ na zaŸ tek impulsu "0"
         jc        LoadUv9                  ; pýeruçen¡ programu
         jcxz      LoadUv1                  ; pýeteŸen¡ Ÿasu

; ------ vìpoŸet konstanty

         neg       cx                       ; poŸet cykl…
         mov       ax,cx
         shr       ax,1
         add       cx,ax                    ; doba * 1.5
         jc        LoadUv1
         jcxz      LoadUv1                  ; pýeteŸen¡
         mov       ds:[Delka0],cx           ; d‚lka impulsu "0"
         shl       cx,1
         jc        LoadUv1                  ; pýeteŸen¡
         mov       ds:[Delka1],cx           ; d‚lka impulsu "1"

; ------ pý¡jem £vodn¡ho t¢nu

LoadUv2: call      LoadBit                  ; pý¡jem jednoho bitu
         jc        LoadUv9                  ; pýeruçen¡ programu
         jz        LoadUv2                  ; je bit "0" - OK
         dec       bh                       ; prvn¡ bit se ztratil

; ------ pý¡jem synchronizace 1

         cmp       bh,0                     ; jsou nØjak‚ bity ?
         je        LoadUv5                  ; nejsou § dn‚ bity
LoadUv4: call      LoadBit                  ; pý¡jem dalç¡ho bitu
         jc        LoadUv9                  ; pýeruçen¡ programu
         jz        LoadUv1                  ; nen¡ bit "1"
         dec       bh                       ; Ÿ¡taŸ po§adovanìch bit…
         jnz       LoadUv4                  ; pý¡jem dalç¡ho bitu

; ------ pý¡jem synchronizace 2

LoadUv5: cmp       bl,0                     ; jsou nØjak‚ bity ?
         je        LoadUv7                  ; nejsou § dn‚ bity
LoadUv6: call      LoadBit                  ; pý¡jem dalç¡ho bitu
         jc        LoadUv9                  ; pýeruçen¡ programu
         jnz       LoadUv1                  ; nen¡ bit "0"
         dec       bl                       ; Ÿ¡taŸ po§adovanìch bit…
         jnz       LoadUv6                  ; pý¡jem dalç¡ho bitu

; ------ pý¡jem startovac¡ho bitu

LoadUv7: call      LoadBit                  ; pý¡jem startovac¡ho bitu
         jc        LoadUv9                  ; pýeruçen¡ programu
         jz        LoadUv1                  ; nen¡ startovac¡ bit "1"

; ------ n vrat registr…

LoadUv9: pop       bx
         pop       cx
         pop       ax
         ret

LoadUvod ENDP

; -----------------------------------------------------------------------------
;        pý¡jem bloku dat
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=adresa k naŸten¡ bloku dat
;        CX=poŸet bajt… k naŸten¡ bloku dat
;        DS=datovì segment
; VíSTUP:CY=pýeruçen¡ programu
; -----------------------------------------------------------------------------

LoadBlok PROC      NEAR

; ------ £schova registr…

         push      ax
         push      cx
         push      si

; ------ kontrola, zda jsou nØjak  data k vysl n¡

         clc
         jcxz      LoadBlk9                 ; nejsou § dn  data

; ------ pý¡jem bloku dat

LoadBlk1:call      LoadByte                 ; pý¡jem jednoho datov‚ho bajtu
         jc        LoadBlk9                 ; pýeruçen¡ programu
         mov       es:[si],al               ; ulo§en¡ bajtu
         inc       si                       ; zvìçen¡ adresy v bufferu
         loop      LoadBlk1                 ; pý¡jem dalç¡ho bajtu

; ------ n vrat registr…

LoadBlk9:pop       si
         pop       cx
         pop       ax
         ret

LoadBlok ENDP

; -----------------------------------------------------------------------------
;        pý¡jem jednoho bajtu
; -----------------------------------------------------------------------------
; VSTUP: DS=datovì segment
; VíSTUP:CY=pýeruçen¡
;        AL=pýijatì bajt
; -----------------------------------------------------------------------------

LoadByte PROC      NEAR

         call      LoadBit
         mov       al,1

LoadByt1:call      LoadBit
         jc        LoadByt9                 ; pýeruçen¡ programu
         jz        LoadByt2                 ; je bit "0"
         stc                                ; je bit "1"
LoadByt2:rcl       al,1                     ; rotace bitu do AL
         jnc       LoadByt1                 ; pý¡jem dalç¡ho bitu
         clc

LoadByt9:ret

LoadByte ENDP

; -----------------------------------------------------------------------------
;        pý¡jem jednoho bitu
; -----------------------------------------------------------------------------
; VSTUP: DS=datovì segment
; VíSTUP:NZ=je bit 1
;        CY=je pýeruçen¡ programu
; -----------------------------------------------------------------------------

LoadBit  PROC      NEAR

         push      ax
         push      cx
         push      dx

; ------ Ÿek n¡ na £vodn¡ hranu sign lu

         xor       dx,dx                    ; stýadaŸ doby
LoadBit1:call      LoadImp                  ; Ÿek n¡ na £vodn¡ hranu sign lu
         jc        LoadBit9                 ; pýeruçen¡ programu

; ------ zmØýen¡ d‚lky impulsu

         mov       ah,bit3
         mov       cx,-1
         call      Cekej                    ; Ÿek n¡ na zaŸ tek impulsu "0"
         jc        LoadBit9                 ; pýeruçen¡ programu
         neg       cx                       ; poŸet cykl…
         add       cx,dx                    ; pýiŸten¡ stýadaŸe
         mov       dx,cx                    ; £schova do stýadaŸe

; ------ filtrace kr tkìch impuls…

         mov       ax,ds:[Delka0]           ; kratç¡ impuls
         shr       ax,1                     ; minim ln¡ doba
         cmp       cx,ax                    ; je minim ln¡ doba ?
         jb        LoadBit1                 ; je pý¡liç kr tkì impuls

; ------ vìpoŸet namØýen‚ doby

         mov       ax,cx
         shr       ax,1
         add       cx,ax                    ; doba * 1.5

; ------ vìpoŸet stýedn¡ doby

         mov       ax,ds:[Delka0]
         add       ax,ds:[Delka1]
         shr       ax,1                     ; stýedn¡ hodnota

; ------ rozliçen¡, zda je bit 0 nebo 1

         cmp       cx,ax                    ; je bit 0 nebo 1 ?
         jb        LoadBit3                 ; je bit 0

; ------ je bit 1

         shr       cx,1                     ; korekce na z kladn¡ d‚lku "0"
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

; ------ n vrat registr…

LoadBit9:pop       dx
         pop       cx
         pop       ax
         ret

LoadBit  ENDP

; -----------------------------------------------------------------------------
;        Ÿek n¡ na £vodn¡ hranu sign lu (CY=pýeruçen¡)
; -----------------------------------------------------------------------------
; VSTUP: DS=datovì segment
; VíSTUP:CY=pýeruçen¡
; -----------------------------------------------------------------------------

LoadImp  PROC      NEAR

; ------ £schova registr…

         push      ax
         push      dx
PortLPT: mov       dx,379h                  ; port LPT

; ------ test, zda je pýeruçen¡ porgramu

         sti                                ; pýeruçen¡ mus¡ bìt povoleno
LoadImp1:test      byte ptr ds:[Param],bit0 ; je pýeruçen¡ programu ?
         stc                                ; pý¡znak pýeruçen¡
         jnz       LoadImp9                 ; je pýeruçen¡ programu

; ------ Ÿek n¡ na konec stavu 1

         in        al,dx                    ; Ÿten¡ stavu portu
         test      al,bit3                  ; test stavov‚ho bitu
         jz        LoadImp1                 ; je stav 1 - Ÿek n¡ na konec

; ------ test, zda je pýeruçen¡ porgramu

LoadImp2:test      byte ptr ds:[Param],bit0 ; je pýeruçen¡ programu ?
         stc                                ; pý¡znak pýeruçen¡
         jnz       LoadImp9                 ; je pýeruçen¡ programu

; ------ Ÿek n¡ na zaŸ tek nov‚ho stavu 1

         in        al,dx                    ; Ÿten¡ stavu portu
         test      al,bit3                  ; test stavov‚ho bitu
         jnz       LoadImp2                 ; je stav 0 - Ÿek n¡ na konec

; ------ n vrat registr…

LoadImp9:pop       dx
         pop       ax
         ret

LoadImp  ENDP

; -----------------------------------------------------------------------------
;        Ÿek n¡ po dobu CX na stav portu LPT AH (vrac¡ CX=zbytek konstanty)
; -----------------------------------------------------------------------------
; VSTUP: CX=max. doba pro Ÿek n¡
;        AH=po§adovanì stav portu LPT (bit 3)
; VíSTUP:CX=zbylì poŸet takt…
;        CY=pýeruçen¡ programu
; -----------------------------------------------------------------------------

Cekej    PROC      NEAR

; ------ £schova registr…

         push      ax
         push      dx
         sti
PortLPT3:mov       dx,379h                  ; port LPT

; ------ test, zda je pýeruçen¡ programu

Cekej1:  test      byte ptr ds:[Param],bit0 ; je pýeruçen¡ programu ?
         stc                                ; pý¡znak pýeruçen¡
         jnz       Cekej9                   ; je pýeruçen¡ programu

; ------ test stavu portu LPT

         in        al,dx
         and       al,bit3
         cmp       al,ah
         loopne    Cekej1
         clc

; ------ n vrat registr…

Cekej9:  pop       dx
         pop       ax
         ret

Cekej    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 08h
; -----------------------------------------------------------------------------

INT08    PROC      FAR

; ------ £schova registr…

         push      ax

; ------ uvolnØn¡ ýadiŸe pýeruçen¡

         mov       al,20h
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

         jmp       dword ptr cs:[Old09]
;         iret

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
;                       inicializace port…
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
         mov       word ptr cs:[PortLPT+1],ax    ; adresa portu LPT
;         mov       word ptr cs:[PortLPT2+1],ax   ; adresa portu LPT
         mov       word ptr cs:[PortLPT3+1],ax   ; adresa portu LPT
         pop       ds

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

; ------ uvolnØn¡ pýeruçen¡ od kl vesnice a hodin

         mov       al,20h
         out       [20h],al
         mov       al,0fdh
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

MemTxt   db        7,'Nedostatek pameti !',13,10,'$'
ExTxt    db        7,'Soubor jiz existuje !',13,10,'$'

CreaTxt  db        7,'Soubor nelze vytvorit !',13,10,'$'

WrTxt    db        7,'Chyba zapisu souboru !',13,10,'$'

hlptxt   db        7,'Zadejte jmeno souboru k prijmu !'
CRTxt    db        13,10,'$'

CRCTxt   db        7,'Chyba pri prenosu souboru !',13,10,'$'

Text1    db        'Prijimam $'

Param    db        0                        ; parametry
                                            ;  bit 0: 1=pýeruçen¡ ESC
                                            ;  bit 1: 1=chyba kontroln¡ho souŸtu

CitImp   db        0                        ; Ÿ¡taŸ impulsu k rozhodov n¡

Delka0   dw        100                      ; d‚lka impulsu "0"
Delka1   dw        100                      ; d‚lka impulsu "1"

SegmVRAM dw        0b000h                   ; segment videopamØti

Konst08  db        72                       ; Ÿasov  konstanta hodin
                                            ;     (16.57 kHz / 60.34 us)
                                            ;      hodiny 1 193 182 Hz
DelImp   db        6                        ; d‚lka impulsu pro rozhodov n¡

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

SoubName dw        ?                        ; adresa jm‚na souboru

         dw        200h dup(?)              ; z sobn¡k
zasob    label     byte                     ; konec z sobn¡ku

konec    label     byte                     ; konec programu

code     ends
         end       start

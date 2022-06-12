
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                              H E L P
;
;                              n†povàda
;
; =============================================================================
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

INCLUDE  ASM\DEF.ASM

HelpMSiz EQU       1000h                    ; velikost segmentu n†povàdy (=4 KB)

CodeHlp  SEGMENT   BYTE PUBLIC
         ASSUME    cs:CodeHlp,ds:Data

; *****************************************************************************
;                             InitFHlp
;               inicializace koment†©ñ k funkán°m kl†ves†m
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY=nedostatek pamàti
; -----------------------------------------------------------------------------
; zniáenÇ registry: AX, BX, CX, DI, ES
; *****************************************************************************

InitFHlp PROC      FAR

; ------ vytvo©en° segmentu koment†©ñ

         call      far ptr CreatSeg         ; vytvo©en° segmentu
         jc        InitFHl9                 ; chyba
         mov       ds:[HelpFSeg],ax         ; segment koment†©ñ

; ------ nastaven° velikosti segmentu

         mov       bx,2 + 2*7*12            ; inicializaán° velikost segmentu
         call      far ptr ModiSegS         ; nastaven° velikosti segmentu
         jc        InitFHl9                 ; chyba

; ------ inicializace dat

         call      far ptr GetDat           ; adresa segmentu
         xor       di,di
         xchg      ax,bx                    ; AX <- velikost dat
         cld
         stosw                              ; velikost dat
         xor       ax,ax
         mov       cx,2*7*12 / 2            ; poáet n†povàd
         rep       stosw                    ; vynulov†n° dat
;         clc                                ; p©°znak operace OK

InitFHl9:ret

InitFHlp ENDP

; *****************************************************************************
;                                MenuFnK
;                    obsluha menu funkán°ch kl†ves
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY=funkce nebyla provedena
;         ZY (a NC)=funkce byla vyvol†na, nebyla ë†dn† kl†vesa zvolena
;         NZ (a NC)=zvolena kl†vesa BX
;         BX=zvolen† kl†vesa (p©i nezvolen° je BX=0)
; *****************************************************************************

MenuFnK  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si

; ------ test, zda je zobrazena mal† n†povàda

MenuFK02:test      byte ptr ds:[HelpPar],bit0 ; je mal† n†povàda ?
         jz        MenuFnK0                 ; nen° mal† n†povàda

; ------ test, zda je stisk my®i na funkán°ch kl†ves†ch

         mov       dh,ds:[MaxRow]           ; posledn° ©†dek
         mov       dl,0                     ; poá†teán° pozice
         mov       ch,1                     ; vò®ka okna
         mov       cl,ds:[Pozic]            ; ®°©ka menu
         call      far ptr MouseTst         ; je stisk tlaá°tka v oknà ?
         jnc       MenuFnK1                 ; je stisk tlaá°tka
MenuFnK0:jmp       MenuFnK6                 ; nen° stisk tlaá°tka

; ------ adresa definice menu

MenuFnK1:call      far ptr DispFHlp         ; aktualizace n†povàdy ke kl†ves†m

         mov       si,offset HelpKeyA       ; text n†povàdy
         test      byte ptr ds:[WindPar],bit6 ; je reëim editoru ?
         jz        MenuFK11                 ; nen° reëim editoru
         mov       si,offset HelpKeyE       ; n†povàda k editoru

; ------ uráen° aktivn° ©ady kl†ves

MenuFK11:mov       al,ds:[Presmyk]          ; aktu†ln° p©esmykaáe
         and       al,bit0+bit1+bit2        ; stav p©esmykaáñ
         mov       bx,1                     ; z†kladn° ©ada
         jz        MenFK112                 ; je z†kladn° ©ada
         cmp       al,bit0+bit1+bit2        ; je platn† ©ada ?
         je        MenFK112                 ; nen° platn† ©ada
         mov       ah,12                    ; poáet kl†ves na ©†dek
         mul       ah                       ; p©epoáet na offset kl†ves
         add       bx,ax                    ; posun á°sla kl†vesy
         push      dx
         mov       dx,7                     ; poáet pozic na kl†vesu
         mul       dx                       ; p©epoáet na offset n†povàdy
         add       si,ax                    ; offset n†povàdy
         pop       dx
         jmp       short MenuFK12

MenFK112:mov       al,ds:[MouseKey]         ; tlaá°tka my®i
         test      al,bit1                  ; pravÇ tlaá°tko ?
         jz        MenuFK12                 ; levÇ tlaá°tko - je z†kladn° ©ada
         mov       bx,1+1*12                ; ©ada se Shift-
         add       si,7*12                  ; n†povàda ke kl†vese Shift-
         test      al,bit0                  ; levÇ tlaá°tko ?
         jnz       MenuFK12                 ; je st©edn° tlaá°tko
         mov       bx,1+3*12                ; ©ada s Alt-
         add       si,2*7*12                ; n†povàda ke kl†vese Alt-

; ------ poáet zobrazenòch kl†ves

MenuFK12:mov       cl,12                    ; je 12 kl†ves
         test      byte ptr ds:[HelpPar],bit1 ; zobraz° se 12 poloëek ?
         jnz       MenuFK13                 ; zobraz° se 12 poloëek
         mov       cl,10                    ; jinak 10 kl†ves

; ------ uráen° aktivn° poloëky

MenuFK13:call      FKeyMPoz                 ; á°slo poloëky na ©†dku
         mov       ds:[GMnuFn],al           ; aktivn° funkán° kl†vesa
         add       bx,ax                    ; up©esnàn° aktivn° poloëky
         mov       ds:[GMNuAkt],bx          ; aktivn° kl†vesa

; ------ zobrazen° ©†dku funkán°ch kl†ves

;         and       byte ptr ds:[HelpPar],not bit3 ; nen° menu
;         mov       dh,ds:[MaxRow]           ; ©†dek k zobrazen°
;         xor       ax,ax                    ; hladina k zobrazen°
;         call      DispLFn                  ; zobrazen° ©†dku funkán°ch kl†ves

; ------ áek†n° na posun my®i nebo na uvolnàn° tlaá°tka

;MenuFnK2:
         call      far ptr DispTime         ; obsluha zobrazen° áasu
         call      far ptr MouseInt         ; obsluha p©eru®en° my®i
         call      far ptr MouseGet         ; áek†n° na zmànu my®i
         jc        MenuFnK1                 ; áek†n° na zmànu my®i

; ------ obsluha akce my®i

         test      bl,bit2+bit3             ; je stisk tlaá°tka ?
         jnz       MenuFnK1                 ; stisk nàkterÇho tlaá°tka
         test      bl,bit4+bit5             ; uvolnàn° tlaá°tek ?
         jnz       MenuFnK3                 ; uvolnàn° tlaá°tek
         mov       al,byte ptr ds:[MousePoz+1] ; ©†dek my®i
         cmp       al,ds:[MaxRow]           ; zmànàn ©†dek ?
         jne       MenuFnK7                 ; rozbalen° menu
;         test      bl,bit7                  ; zmànàna pozice ?
;         jz        MenuFnK2                 ; pozice nezmànàna
MenuFK24:jmp       MenuFnK1                 ; pozice byla zmànàna

; ------ uráen° zvolenÇ kl†vesy

MenuFnK3:mov       bx,ds:[GMnuAkt]          ; aktivn° volba 1...84
         shl       bx,1                     ; volba * 2
         mov       bx,ds:[bx+GMnuKeyT-2]    ; zvolen† kl†vesa
         jmp       short MenuFK72

; ------ test, zda jsou p©esmykaáe Ctrl-Alt-Shift-

MenuFnK6:mov       al,ds:[Presmyk]          ; stav p©esmykaáñ
         cmp       al,-1
         je        MenuFnK8                 ; nezn†mÇ p©esmykaáe
         and       al,bit0+bit1+bit2        ; pot©ebnÇ p©esmykaáe
         cmp       al,7                     ; je kombinace Ctrl-Alt-Shift- ?
         jne       MenuFnK8                 ; nen° kombinace Ctrl-Alt-Shift-

; ------ obsluha menu funkán°ch kl†ves

MenuFnK7:mov       si,offset GMnuVert       ; menu volby funkán°ch kl†ves
         call      far ptr FKeyMenu         ; obsluha menu funkán°ch kl†ves
MenuFK72:or        bx,bx                    ; je nàjak† kl†vesa ?
         jnz       MenuFnK9                 ; je nàjak† kl†vesa
         mov       al,byte ptr ds:[MousePoz+1] ; ©†dek my®i
         cmp       al,ds:[MaxRow]           ; je spodn° ©†dek ?
         je        MenuFK74                 ; je spodn° ©†dek OK
         or        bx,bx                    ; nastaven° p©°znaku ZY
         jmp       short MenuFnK9

MenuFK74:test      byte ptr ds:[MouseKey],bit0+bit1 ; je nàkterÇ tlaá°tko ?
         jz        MenuFnK9                 ; nen° tlaá°tko
         test      byte ptr ds:[HelpPar],bit0 ; je mal† n†povàda ?
         jz        MenuFnK9                 ; nen° mal† n†povàda
         jmp       short MenuFK24

; ------ nen° ë†dn† obsluha

MenuFnK8:stc                                ; p©°znak, ëe nen° obsluha

; ------ n†vrat registrñ

MenuFnK9:pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

MenuFnK  ENDP

; *****************************************************************************
;                                FKeyMenu
;                         menu funkán°ch kl†ves
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=definice menu
; VùSTUP: BX=zvolen† funkán° kl†vesa
;         CY=p©eru®en° operace, kl†vesa nebyla zvolena (BX=0)
; *****************************************************************************

FKeyMenu PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx

; ------ otev©en° menu funkán°ch kl†ves

         call      far ptr OpenMnu          ; otev©en° menu funkán°ch kl†ves

; ------ áek†n° na zad†n° kl†vesy nebo posun my®i

FKeyMnu1:call      far ptr DispMnu          ; zobrazen° menu
         call      far ptr KurzOff          ; vypnut° kurzoru
         call      far ptr InpChar          ; vstup znaku z kl†vesnice -> BX

; ------ p©°prava ukazatelñ menu

         mov       ax,ds:[GMnuAkt]          ; aktivn° volba
         mov       dx,ax                    ; DX <- aktivn° volba
         dec       ax                       ; korekce na 0...
         mov       cx,12                    ; poáet kl†ves na ©†dek
         div       cl                       ; vòpoáet ©†dku a pozice
         xchg      ah,al                    ; AH=©†dek, AL=pozice
         test      byte ptr ds:[HelpPar],bit1 ; zobraz° se 12 poloëek ?
         jnz       FKeyMn18                 ; zobraz° se 12 poloëek
         mov       cl,10                    ; 10 poloëek

; ------ obsluha kl†vesy

FKeyMn18:call      far ptr JumpBX           ; skok na obsluhu kl†vesy

         dw        4b00h,FKeyMnu2           ; vlevo
         dw        1f13h,FKeyMnu2           ; Ctrl-S vlevo

         dw        4d00h,FKeyMnu3           ; vpravo
         dw        2004h,FKeyMnu3           ; Ctrl-D vpravo

         dw        4800h,FKeyMnu5           ; nahoru
         dw        1205h,FKeyMnu5           ; Ctrl-E nahoru

         dw        5000h,FKeyMnu4           ; dolñ
         dw        2d18h,FKeyMnu4           ; Ctrl-X dolñ

         dw        7300h,FKeyMn62           ; Ctrl-vlevo levò okraj
         dw        7400h,FKeyMn64           ; Ctrl-vpravo pravò okraj
         dw        8d00h,FKeyMn68           ; Ctrl-nahoru horn° okraj
         dw        9100h,FKeyMn66           ; Ctrl-dolñ doln° okraj

         dw        4700h,FKeyMn62           ; Home levò okraj
         dw        4f00h,FKeyMn64           ; End pravò okraj
         dw        7700h,FKeyMn60           ; Ctrl-Home zaá†tek
         dw        7500h,FKeyMn61           ; Ctrl-End konec

         dw        4900h,FKeyMn68           ; PageUp horn° okraj
         dw        5100h,FKeyMn66           ; PageDown doln° okraj
         dw        8400h,FKeyMn60           ; Ctrl-PageUp zaá†tek
         dw        7600h,FKeyMn61           ; Ctrl-PageDn konec

         dw        0f09h,FKeyMn72           ; Tab dal®° poloëka
         dw        0f00h,FKeyMn74           ; Shift-Tab p©ede®l† poloëka

         dw        MousXKod+MousXRP,FKeyMnu8 ; stisk pravÇho tlaá°tka - p©eru®en°
         dw        MousXKod+MousXLR,FKeyMn84 ; uvolnàn° levÇho tlaá°tka
         dw        MousXKod+MousXRR,FKeyMn84 ; uvolnàn° pravÇho tlaá°tka
         dw        MousXKod+MousXMR,FKeyMn84 ; uvolnàn° st©edn°ho tlaá°tka

         dw        MousXKod+MousXLP,FKeyMn19 ; stisk levÇho tlaá°tka
         dw        MousXKod+MousXMov,FKeyMn19 ; posun my®i

         dw        11bh,FKeyMnu8            ; Esc
         dw        1c0dh,FKeyMn82           ; Enter
         dw        0,FKeyMnu1

; ------ posun my®i

FKeyMn19:mov       al,byte ptr ds:[MousePoz+1] ; ©†dek my®i
         cmp       al,ds:[MaxRow]           ; je posun pod menu ?
         jb        FKeyM192                 ; nen° posun pod menu
         jmp       FKeyMnu8                 ; p©eru®en° ESC

FKeyM192:mov       al,byte ptr ds:[MousePoz+1] ; ©†dek my®i
         sub       al,ds:[si+MnuRad]        ; ©†dek relativnà
         jnc       FKeyM194
         mov       al,0
FKeyM194:sub       al,6
         neg       al
         mov       ah,12
         mul       ah                       ; p©epoáet na poloëku
         xchg      ax,dx
         call      FKeyMPoz                 ; vòpoáet poloëky na ©†dku
         add       dx,ax                    ; aktivn° poloëka
         inc       dx
         jmp       short FKeyMn22           ; nov† aktivn° poloëka

; ------ vlevo

FKeyMnu2:dec       dx                       ; sn°ëen° aktivn° poloëky
         dec       al                       ; sn°ëen° pozice na ©†dku
         jns       FKeyMn22                 ; nen° je®tà podteáen°
         add       dx,cx                    ; kurzor na konec ©†dku

FKeyMn22:mov       ds:[GMnuAkt],dx          ; nov† aktivn° volba
         jmp       FKeyMnu1

; ------ vpravo

FKeyMnu3:inc       dx                       ; zvò®en° aktivn° poloëky
         inc       ax                       ; zvò®en° pozice na ©†dku
         cmp       al,cl                    ; p©eteáen° konce ©†dku ?
         jb        FKeyMn22                 ; pozice je je®tà OK
         sub       dx,cx                    ; kurzor na zaá†tek ©†dku
         jmp       short FKeyMn22

; ------ nahoru

FKeyMnu4:sub       dx,12                    ; sn°ëen° aktivn° poloëky
         ja        FKeyMn22                 ; je je®tà platn† poloëka
         add       dx,7*12                  ; kurzor na posledn° ©†dek
         jmp       short FKeyMn22

; ------ dolñ

FKeyMnu5:add       dx,12                    ; zvò®en° aktivn° poloëky
         cmp       ah,6                     ; byl to posledn° ©†dek ?
         jb        FKeyMn22                 ; nebyl je®tà posledn° ©†dek
         sub       dx,7*12                  ; kurzor na prvn° ©†dek
         jmp       short FKeyMn22

; ------ zaá†tek - prvn° poloëka

FKeyMn60:mov       dx,1                     ; prvn° poloëka
         jmp       short FKeyMn22

; ------ konec - posledn° poloëka

FKeyMn61:mov       dl,7*12                  ; posledn° poloëka pro 12 kl†ves
         cmp       cl,12                    ; je 12 kl†ves ?
         je        FKeyMn22                 ; je 12 kl†ves
         dec       dx
         dec       dx                       ; omezen° na kl†vesu F10
         jmp       short FKeyMn22

; ------ levò okraj

FKeyMn62:sub       dl,al                    ; posun k levÇmu okraji
         jmp       short FKeyMn22

; ------ pravò okraj

FKeyMn64:sub       cl,al                    ; zbytek do konce ©†dku
         dec       cx                       ; korekce
         add       dl,cl                    ; posun k pravÇmu okraji
         jmp       short FKeyMn22

; ------ horn° okraj

FKeyMn66:mov       dl,al                    ; plat° pozice
         inc       dx                       ; korekce
         jmp       short FKeyMn22

; ------ doln° okraj

FKeyMn68:mov       dl,al                    ; plat° pouze pozice
         add       dl,6*12 + 1              ; posun na spodn° ©†dek
         jmp       short FKeyMn22

; ------ dal®° poloëka

FKeyMn72:inc       dx                       ; zvò®en° á°sla poloëky
         inc       ax                       ; zvò®en° pozice na ©†dku
         cmp       al,cl                    ; je jië konec ©†dku ?
         jb        FKeyMn22                 ; nen° je®tà konec ©†dku
         sub       dx,cx                    ; posun na zaá†tek ©†dku
         jmp       short FKeyMnu5           ; posun o ©†dek dolñ

; ------ p©ede®l† poloëka

FKeyMn74:dec       dx                       ; sn°ëen° á°sla poloëky
         dec       al                       ; sn°ëen° pozice na ©†dku
         jns       FKeyMn22                 ; nebyl je®tà zaá†tek ©†dku
         add       dx,cx                    ; posun na konec ©†dku
         jmp       short FKeyMnu4           ; posun o ©†dek nahoru

; ------ uvolnàn° tlaá°tka my®i

FKeyMn84:call      far ptr MouseMnu         ; test, zda je my® v menu
         jc        FKeyMnu8                 ; nen° v oknà - p©eru®en°

; ------ Enter

FKeyMn82:call      far ptr ClosMnu          ; uzav©en° okna menu
         mov       bx,ds:[GMnuAkt]          ; aktivn° volba 1...84
         shl       bx,1                     ; volba * 2
         mov       bx,ds:[bx+GMnuKeyT-2]    ; zvolen† kl†vesa
         clc                                ; p©°znak operace OK
         jmp       short FKeyMnu9

; ------ p©eru®en° operace ESC

FKeyMnu8:call      far ptr ClosMnu          ; uzav©en° okna menu
         call      far ptr NulBreak         ; nulov†n° p©°znaku p©eru®en°
         xor       bx,bx                    ; kl†vesa neplatn†
         stc                                ; nezvolena ë†dn† kl†vesa

; ------ n†vrat registrñ

FKeyMnu9:pop       dx
         pop       cx
         pop       ax
         ret

FKeyMenu ENDP

; -----------------------------------------------------------------------------
;        vòpoáet kl†vesy na ©†dku z pozice my®i -> AX
; -----------------------------------------------------------------------------

FKeyMPoz PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      cx

; ------ poáet poloëek na ©†dku

         mov       cl,12                    ; je 12 kl†ves
         test      byte ptr ds:[HelpPar],bit1 ; zobraz° se 12 poloëek ?
         jnz       FKeyMPz2                 ; zobraz° se 12 poloëek
         mov       cl,10                    ; jinak 10 kl†ves
FKeyMPz2:
         ;mul       cl

; ------ poáet pozic na poloëku

         mov       al,ds:[Pozic]            ; poáet pozic na ©†dek
         mov       ah,0
         div       cl                       ; poáet pozic na poloëku
         xchg      ax,cx                    ; CL <- poáet pozic, CH <- zbytek

; ------ nalezen° kl†vesy

         xor       bx,bx                    ; á°taá á°sla kl†vesy
         mov       al,byte ptr ds:[MousePoz] ; pozice na ©†dku
         dec       bx
FKeyMPz4:inc       bx
         sub       al,cl
         jc        FKeyMPz9
         or        ch,ch                    ; je zbytek ?
         jz        FKeyMPz4
         dec       ch
         sub       al,1
         jnc       FKeyMPz4

; ------ n†vrat registrñ

FKeyMPz9:xchg      ax,bx                    ; AX <- kl†vesa
         pop       cx
         pop       bx
         ret

FKeyMPoz ENDP

; *****************************************************************************
;                                InitGMnu
;                      inicializace menu funkán°ch kl†ves
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=definice menu
; *****************************************************************************

InitGMnu PROC      FAR

         push      ax

         mov       al,ds:[Radku]            ; poáet ©†dkñ celkem
         sub       al,8                     ; ©†dek k zobrazen° menu
         mov       ds:[si+MnuRad],al        ; ©†dek k zobrazen° menu

         mov       al,ds:[Pozic]            ; poáet pozic celkem
         mov       ds:[si+MnuSir],al        ; ®°©ka menu

         pop       ax
         ret

InitGMnu ENDP

; *****************************************************************************
;                               DispGMnu
;                   zobrazen° menu funkán°ch kl†ves
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=definice menu
; *****************************************************************************

DispGMnu PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

         push      si                       ; definice menu

; ------ p©°prava registrñ

         cld
         push      ds
         pop       es                       ; ES <- datovò segment
         xor       cx,cx                    ; CX <- 0
         mov       ax,ds:[GMnuAkt]          ; aktivn° kl†vesa
         mov       di,offset GMnuVHl1+2     ; buffer k dek¢dov†n° n†povàdy

; ------ dek¢dov†n° textu p©esmykaáñ kl†vesy

         mov       si,offset GMnuVHlT       ; tabulka textñ p©esmykaáñ
DispGMn1:mov       cl,ds:[si]               ; dÇlka textu
         inc       si                       ; p©eskoáen° bajtu dÇlky textu
         cmp       al,12                    ; nalezen text kl†vesy ?
         jbe       DispGMn2                 ; text nalezen OK
         add       si,cx                    ; adresa dal®°ho textu
         sub       al,12
         jmp       short DispGMn1
DispGMn2:rep       movsb                    ; p©enos textu kl†vesy

; ------ dek¢dov†n° oznaáen° a á°sla kl†vesy

         mov       byte ptr ds:[di],"F"     ; oznaáen° funkán° kl†vesy "F"
         inc       di
         call      far ptr DekNumB          ; dek¢dov†n° á°sla kl†vesy

; ------ oddàlovac° znak ":" za kl†vesou

         cld
         mov       ax,":"*HI + ""          ; zmàna barvy a oddàlovaá ":"
         stosw
         mov       al," "
         stosb                              ; oddàlovac° mezera

; ------ p©°prava k dek¢dov†n° n†povàdy ke kl†vese

         mov       bx,ds:[GMnuAkt]          ; aktivn° kl†vesa
         test      byte ptr ds:[WindPar],bit6 ; je reëim editoru ?
         jz        DispGMn3                 ; nen° reëim editoru
         add       bx,7*12                  ; posun na n†povàdy editoru
DispGMn3:mov       ax,ds:[HelpFSeg]         ; segment n†povàd ke kl†ves†m
         call      far ptr GetSgAdr         ; adresa segmentu -> DX

; ------ nalezen° n†povàdy ke kl†vese

         push      ds
         mov       ds,dx                    ; DS <- adresa segmentu n†povàd
         cld
         mov       ah,0                     ; AH <- 0
         mov       si,2                     ; zaá†tek n†povàd
DispGMn4:lodsb                              ; dÇlka textu n†povàdy
         dec       bx                       ; á°taá aktivn° n†povàdy
         jz        DispGMn5                 ; n†povàda nalezena OK
         add       si,ax                    ; adresa dal®° n†povàdy
         jmp       short DispGMn4           ; dal®° n†povàda

; ------ dek¢dov†n° textu n†povàdy

DispGMn5:xchg      ax,cx                    ; CX <- dÇlka textu
         jcxz      DispGM55                 ; nen° ë†dnò znak n†povàdy
DispGM52:lodsb                              ; naáten° znaku n†povàdy
         cmp       di,offset GMnuVHl2       ; je jië konec bufferu ?
         jae       DispGM55                 ; je jië konec bufferu
         stosb                              ; uloëen° znaku
DispGM53:loop      DispGM52                 ; dal®° znak n†povàdy
DispGM55:pop       ds

; ------ nastaven° parametrñ textu n†povàdy

         pop       si                       ; adresa definice menu
         sub       di,offset GMnuVHl1+1     ; dÇlka textu
         xchg      ax,di
         mov       ds:[GMnuVHl1],al         ; dÇlka textu

; ------ p©°prava parametrñ k zobrazen° ©†dkñ kl†ves

         mov       dl,0                     ; ukazatel á°sla ©†dku
         mov       dh,ds:[si+MnuRad]        ; ©†dek na obrazovce
         add       dh,6                     ; posledn° ©†dek
         mov       ah,0
         mov       al,ds:[si+MnuLev]        ; hladina k zobrazen° menu
         mov       cx,7                     ; poáet ©†dkñ kl†ves k zobrazen°

; ------ adresa aktivn°ho menu

         mov       si,offset HelpKeyA       ; adres†©
         test      byte ptr ds:[WindPar],bit6 ; je reëim editoru ?
         jz        DispGMn6                 ; nen° reëim editoru
         mov       si,offset HelpKeyE       ; n†povàda k editoru

; ------ test, zda je ©†dek s aktivn° kl†vesou

DispGMn6:push      ax                       ; hladina k zobrazen° menu

         mov       ax,ds:[GMnuAkt]          ; aktivn° kl†vesa
         dec       ax                       ; korekce na 0...
         mov       bh,12                    ; poáet kl†ves na ©†dek
         div       bh                       ; vòpoáet ©†dku a kl†vesy
         mov       byte ptr ds:[GMnuFn],-1  ; neaktivn° ©†dek menu
         cmp       al,dl                    ; je to aktivn° ©†dek ?
         jne       DispGMn7                 ; nen° to aktivn° ©†dek
         mov       ds:[GMnuFn],ah           ; aktivn° kl†vesa

DispGMn7:pop       ax

; ------ zobrazen° jednÇ ©ady kl†ves

         or        byte ptr ds:[HelpPar],bit3 ; zobraz° se jako menu
         call      DispLFn                  ; zobrazen° kl†ves
         inc       dx                       ; zvò®en° ukazatele á°sla ©†dku
         dec       dh                       ; sn°ëen° ©†dku na displeji
         add       si,12*7                  ; zvò®en° ukazatele textu kl†ves
         loop      DispGMn6                 ; dal®° ©†dek kl†ves

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispGMnu ENDP

; *****************************************************************************
;                             Disp0Hlp
;            nepodm°nànÇ zobrazen° n†povàdy k funkán°m kl†ves†m
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

Disp0Hlp PROC      FAR

         mov       byte ptr ds:[Presmyk],-1 ; p©°znak, ëe nen° zobrazena
                                          ;* pokraáuje procedura DispFHlp !

Disp0Hlp ENDP

; *****************************************************************************
;                              DispFHlp
;                    zobrazen° n†povàdy k funkán°m kl†ves†m
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

DispFHlp PROC      FAR

; ------ £schova registrñ

         push      ax
         push      dx
         push      si

; ------ test, zda se m† n†povàda ke kl†ves†m zobrazit

         test      byte ptr ds:[ParMenu],bit2 ; je zobrazeno nàjakÇ menu ?
         jnz       DispFHl9                 ; je zobrazeno menu - nen° n†povàda
         test      byte ptr ds:[WindPar],bit2 ; je nastaven° vò®ky oken ?
         jnz       DispFHl9                 ; je nastaven° vò®ky oken
         call      far ptr InpPresm         ; vstup stavu p©esmykaáñ
         jc        DispFHl9                 ; stav p©esmykaáñ nebyl zmànàn
         test      byte ptr ds:[HelpPar],bit0 ; n†povàda k funkán°m kl†ves†m ?
         jz        DispFHl9                 ; mal† n†povàda nezobrazena
         test      byte ptr ds:[InfoPar],bit0 ; je informaán° ©†dek ?
         jnz       DispFHl9                 ; je informaán° ©†dek

; ------ adresa tabulky textñ funkán°ch kl†ves -> SI

         and       al,bit0+bit1+bit2        ; stav p©esmykaáñ
         cmp       al,7                     ; je Ctrl-Alt-Del- ?
         jb        DispFHl2                 ; je to OK
         mov       al,0                     ; z†kladn° ©ada
DispFHl2:mov       ah,12*7                  ; dÇlka jednÇ popisky kl†ves
         mul       ah
         mov       si,offset HelpKeyA       ; text n†povàdy
         test      byte ptr ds:[WindPar],bit6 ; je reëim editoru ?
         jz        DispFHl3                 ; nen° reëim editoru
         mov       si,offset HelpKeyE       ; n†povàda k editoru
DispFHl3:add       si,ax                    ; adresa n†povàdy

; ------ zobrazen° n†povàdy ke kl†ves†m

         mov       dh,ds:[MaxRow]           ; ©†dek k zobrazen°
         xor       ax,ax                    ; hladina k zobrazen°
         mov       byte ptr ds:[GMnuFn],-1  ; nen° funkán° kl†vesa - bàënò m¢d
         and       byte ptr ds:[HelpPar],not bit3 ; nen° menu
         call      DispLFn                  ; zobrazen° ©†dku funkán°ch kl†ves

; ------ n†vrat registrñ

DispFHl9:pop       si
         pop       dx
         pop       ax
         ret

DispFHlp ENDP

; -----------------------------------------------------------------------------
;        zobrazen° jednoho ©†dku funkán°ch kl†ves
; -----------------------------------------------------------------------------
; VSTUP: AX=hladina k zobrazen°
;        DH=©†dek k zobrazen°
;        DS:SI=adresa definice funkán°ch kl†ves
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) hladina k zobrazen°
;                   SS:[BP-3] (1) á°taá poloëek k zobrazen°
;                   SS:[BP-4] (1) ©†dek k zobrazen°
;                   SS:[BP-5] (1) zbytek k rozdàlen° na poloëky
;                   SS:[BP-6] (1) dÇlka textu jednÇ poloëky
;                   SS:[BP-8] (2) ukazatel textu poloëky
; -----------------------------------------------------------------------------

DispLFn  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp

; ------ p©°prava bufferu a lok†ln°ch promànnòch

         sub       sp,8
         sub       sp,ds:[ByteRow]          ; buffer k dek¢dov†n° textu
         mov       ss:[bp-2],ax             ; hladina k zobrazen°
         mov       ss:[bp-4],dh             ; ©†dek k zobrazen°
         mov       ss:[bp-8],si             ; ukazatel adresy poloëky

; ------ poáet poloëek k zobrazen°

         mov       al,10                    ; 10 poloëek
         test      byte ptr ds:[HelpPar],bit1 ; zobraz° se 12 poloëek ?
         jz        DispLFn1                 ; zobraz° se 10 poloëek
         mov       al,12                    ; 12 poloëek k zobrazen°
DispLFn1:mov       ss:[bp-3],al             ; á°taá poloëek k zobrazen°

; ------ stanoven° ®°©ky jednÇ poloëky

         mov       al,ds:[Pozic]            ; poáet pozic na ©†dek
         mov       ah,0
         div       byte ptr ss:[bp-3]       ; vòpoáet poátu pozic na kl†vesu
         dec       ax                       ; 1 pozice na á°slo kl†vesy
         mov       ss:[bp-6],ax             ; dÇlka textu a zbytek

; ------ buffer v z†sobn°ku k dek¢dov†n° textu

         mov       di,sp                    ; buffer v z†sobn°ku
         push      ss
         pop       es                       ; ES <- segment bufferu
         cld                                ; smàr nahoru

; ------ uloëen° á°sla funkán° kl†vesy

         xor       bx,bx                    ; BX <- 0 ukazatel á°sla poloëky
DispLFn2:mov       ah,ds:[HelpColM]         ; bàën† barva textu
         mov       al,"≥"                   ; znak "≥" mezi kl†vesami
         test      byte ptr ds:[HelpPar],bit3 ; je zobrazeno menu ?
         jnz       DispLFn3                 ; je to menu
         mov       ah,ds:[HelpColN]         ; barva á°sla kl†vesy
         mov       al,bl ;ds:[ZnakFKey+bx]      ; znak funkán° kl†vesy
         add       al,"1"
         cmp       al,"9"
         jbe       DispLFn3
         sub       al,10
DispLFn3:stosw                              ; uloëen° á°sla kl†vesy

; ------ p©°prava dÇlky poloëky -> CL

         mov       dl,ss:[bp-6]             ; dÇlka textu jednÇ poloëky
         cmp       byte ptr ss:[bp-5],0     ; je nàjakò zbytek ?
         je        DispLFn4                 ; nen° zbytek
         inc       dx                       ; korekce dÇlky poloëky
         dec       byte ptr ss:[bp-5]       ; á°taá zbytku
DispLFn4:mov       cl,dl                    ; dÇlka textu

; ------ stanoven° poátu mezer na zbytek poloëky -> DL

         cmp       cl,7                     ; p©ekroáena max. dÇlka poloëky ?
         jb        DispLFn5                 ; dÇlka poloëky je OK
         mov       cl,7                     ; omezen° dÇlky poloëky
DispLFn5:sub       dl,cl                    ; zbytek na mezery

; ------ dek¢dov†n° textu poloëky

         mov       ch,0
         mov       si,ss:[bp-8]             ; adresa textu poloëky
         mov       ah,ds:[HelpColK]         ; barva kurzoru
         cmp       bl,ds:[GMnuFn]           ; je to aktivn° kl†vesa ?
         je        DispLFn6                 ; je to aktivn° kl†vesa
         mov       ah,ds:[HelpColT]         ; barva textu kl†vesy
         test      byte ptr ds:[HelpPar],bit3 ; je zobrazeno menu ?
         jz        DispLFn6                 ; nen° menu
         mov       ah,ds:[HelpColM]         ; bàën† barva textu
DispLFn6:lodsb
         stosw
         loop      DispLFn6

; ------ vymaz†n° zbytku poloëky mezerami

         mov       cl,dl                    ; zbytek na mezery
         mov       al," "
         rep       stosw                    ; vymaz†n° zbytku poloëky

; ------ p©°prava pro dal®° poloëku

         add       word ptr ss:[bp-8],7     ; adresa dal®° poloëky
         inc       bx                       ; zvò®en° ukazatele á°sla poloëky
         dec       byte ptr ss:[bp-3]       ; á°taá poloëek
         jnz       DispLFn2                 ; dek¢dov†n° dal®° poloëky

; ------ zobrazen° ©†dku textu

         mov       dl,0                     ; pozice
         mov       dh,ss:[bp-4]             ; ©†dek k zobrazen°
         mov       si,sp                    ; dek¢dovanò text
         mov       cl,ds:[Pozic]            ; poáet pozic textu
         mov       ax,ss:[bp-2]             ; AX <- hladina k zobrazen°
         call      far ptr DispKStr         ; z†pis ©†dku na displej

; ------ n†vrat registrñ

         mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispLFn  ENDP

; *****************************************************************************
;                               DispMHlp
;                      zobrazen° n†povàdy menu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
;        DS=datovò segment
; *****************************************************************************

DispMHlp PROC      FAR

; ------ £schova registrñ

         push      ax
         push      dx
         push      si
         push      es

; ------ p©°prava registrñ

         mov       es,ds:[HelpSeg]          ; ES <- segment n†povàdy
         mov       dx,ds:[si+MnuAkt]        ; aktivn° poloëka menu
         mov       al,ds:[si+MnuTyp]        ; typ okna menu
         mov       si,ds:[si+MnuHlp]        ; adresa n†povàd

; ------ n†povàda k menu volby diskñ

         cmp       al,4                     ; je menu volby diskñ ?
;         jne       DispMHl2                 ; nen° menu volby diskñ
;         test      byte ptr ds:[DiskInfP],bit1 ; prov†d° se editace ?
         jz        DispMHl6                 ; neprov†d° se editace
;         mov       si,offset DiskMHl2       ; n†povàda pro editaci koment†©e
;         jmp       short DispMHl6

; ------ nàkter† menu nemaj° v°ce n†povàd

DispMHl2:cmp       al,5                     ; je ASCII tabulka ?
         je        DispMHl6                 ; ASCII tabulka m† jednu n†povàdu
         cmp       al,6                     ; je okno hodin ?
         je        DispMHl6                 ; jsou hodiny
         cmp       al,9                     ; okno volby souborñ ?
         je        DispMHl6                 ; vòbàr souborñ

; ------ nalezen° adresy textu (nen°-li segment n†povàdy, to nevad°)

         dec       dx                       ; korekce á°sla n†povàdy
         jz        DispMHl6                 ; je prvn° poloëka
         mov       ah,0
DispMHl4:mov       al,es:[si]               ; dÇlka textu n†povàdy
         inc       si                       ; p©eskoáen° bajtu dÇlky texty
         add       si,ax                    ; adresa dal®°ho textu
         dec       dx                       ; á°taá aktivn° poloëky
         jnz       DispMHl4                 ; dal®° text

; ------ zobrazen° textu n†povàdy

DispMHl6:push      cs
         call      near ptr DispHTxt        ; zobrazen° textu n†povàdy

; ------ n†vrat registrñ

         pop       es
         pop       si
         pop       dx
         pop       ax
         ret

DispMHlp ENDP

; *****************************************************************************
;                      zobrazen° textu n†povàdy
; -----------------------------------------------------------------------------
; VSTUP: SI=text n†povàdy v segmenut HELPS (1. bajt = dÇlka textu)
;        DS=datovò segment
; *****************************************************************************

DispHTxt PROC      FAR

; ------ test, zda se n†povàda zobraz°

         test      byte ptr ds:[ParInt24],bit5 ; prob°h† INT 24h ?
         jnz       DispHTx1                 ; prob°h† INT 24h
         test      byte ptr ds:[ParMenu],bit3 ; p©echodnÇ vypnut° oken ?
         jnz       DispHTx1                 ; je p©echodnÇ vypnut° oken
         test      byte ptr ds:[InfoPar],bit0 ; zobrazen informaán° ©†dek ?
         jz        DispHTx1                 ; nen° informaán° ©†dek
         ret

; ------ £schova registrñ

DispHTx1:push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp

; ------ vymaz†n° bufferu

         mov       cx,ds:[ByteRow]          ; poáet pozic na ©†dek
         sub       sp,cx                    ; vytvo©en° bufferu v z†sobn°ku
         mov       ah,ds:[HelpColH]         ; barva textu n†povàdy
         mov       al," "                   ; mazac° znak mezery
         cld
         shr       cx,1                     ; poáet znakñ na ©†dek
         push      ss
         pop       es
         mov       di,sp                    ; buffer v z†sobn°ku
         dec       cx                       ; korekce dÇlky
         stosw                              ; uloëen° prvn° mezery
         mov       dl,cl                    ; DX <- dÇlka ©†dku
         push      di
         rep       stosw                    ; vymaz†n° bufferu
         pop       di

; ------ p©°prava k dek¢dov†n° textu

         mov       dh,ds:[HelpClH2]         ; vysv°cen† barva

         push      ds
         mov       byte ptr es:[di],"*"
         test      byte ptr ds:[HelpPar],bit2 ; je n†povàda ?
         jnz       DispHTx8                 ; nen° n†povàda
         mov       ds,ds:[HelpSeg]          ; segment n†povàdy
         lodsb                              ; dÇlka textu
         mov       cl,al                    ; CL <- dÇlka textu
         jcxz      DispHTx8                 ; nen° n†povàda

; ------ naáten° znaku

DispHTx2:lodsb                              ; naáten° znaku

; ------ zmàna barvy textu

         cmp       al,""                   ; je p©ep°naá barvy ?
         jne       DispHTx3                 ; nen° p©ep°naá barvy
         xchg      ah,dh                    ; zmàna barvy
         jmp       short DispHTx7

; ------ test, zda je vno©en° textu z datovÇho segmentu

DispHTx3:cmp       al,1                     ; je vno©enò text ?
         jne       DispHTx6                 ; nen° vno©enò text

; ------ adresa vno©enÇho textu

         push      ds
         push      si
         mov       si,ds:[si]               ; adresa textu
         push      cx
         mov       ds,cs:[DatSeg]           ; datovò segment

; ------ dÇlka vno©enÇho textu

         lodsb                              ; dÇlka textu
         mov       cl,al                    ; CX <- dÇlka textu
         jcxz      DispHTx5                 ; konec vno©enÇho textu

; ------ naáten° znaku vno©enÇho textu

DispHTx4:lodsb

; ------ zmàna barvy vno©enÇho textu

         cmp       al,""                   ; je p©ep°naá barvy ?
         jne       DispHT42                 ; nen° p©ep°naá barvy
         xchg      ah,dh                    ; zmàna barvy textu
         jmp       short DispHT44           ; dal®° znak

; ------ uloëen° znaku vno©enÇho textu

DispHT42:stosw                              ; uloëen° znaku
         dec       dl                       ; á°taá zbylòch znakñ
         jz        DispHTx5                 ; ©†dek je jië plnò
DispHT44:loop      DispHTx4                 ; dal®° znak

; ------ n†vrat registrñ

DispHTx5:pop       cx
         pop       si

; ------ p©eskoáen° ukazatelñ vno©enÇho textu

         inc       si
         inc       si
         dec       cx
         dec       cx

; ------ test, zda je jië konec ©†dku

         pop       ds
         or        dl,dl                    ; je jië konec ©†dku ?
         jz        DispHTx8                 ; je jië konec ©†dku
         jmp       short DispHTx7           ; dal®° znak

; ------ uloëen° znaku

DispHTx6:stosw                              ; uloëen° znaku
         dec       dl                       ; á°taá pozic
         jz        DispHTx8                 ; ©†dek je jië plnò
DispHTx7:loop      DispHTx2                 ; dal®° znak

; ------ zobrazen° textu n†povàdy (s p©ek¢dov†n°m fontñ)

DispHTx8:pop       ds

         mov       dl,0                     ; poá†teán° pozice 0
         mov       dh,ds:[MaxRow]           ; posledn° ©†dek
         mov       cl,ds:[Pozic]            ; poáet pozic na ©†dek
         mov       si,sp                    ; buffer s textem
;         xor       ax,ax                    ; hladina k zobrazen° 0
         mov       al,255                   ; maxim†ln° hladina k zobrazen°
         call      far ptr DispKStr         ; zobrazen° textu n†povàdy

; ------ n†vrat registrñ

         mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
DispHTx9:ret

DispHTxt ENDP

DatSeg   dw        SEG Data                 ; datovò segment

; *****************************************************************************
;                                 HelpAF
;                       obsluha aktivn° n†povàdy
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

HelpAF   PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx

; ------ á°slo n†povàdy, nen°-li menu

         mov       ax,Hlp@Main              ; n†povàda pro adres†©ovÇ okno
         test      byte ptr ds:[WindPar],bit2 ; je nastaven° vò®ku oken ?
         jz        HelpAF1                  ; nen° nastaven° vò®ky oken
         mov       ax,Hlp@NastaveniVyskyOken ; n†povàda pro nastaven° vò®ky oken
HelpAF1: test      byte ptr ds:[WindPar],bit6 ; je editace souborñ ?
         jz        HelpAF2                  ; nen° editace souborñ
         mov       ax,Hlp@Editor            ; n†povàda pro editor

; ------ á°slo n†povàdy, je-li menu

HelpAF2: cmp       word ptr ds:[NumMenu],0  ; je nàjakÇ menu ?
         je        HelpAF4                  ; nen° ë†dnÇ menu
         mov       bx,ds:[AktMenu]          ; aktivn° menu
         mov       ax,ds:[bx+MnuHelp]       ; á°slo n†povàdy

; ------ obsluha n†povàdy

HelpAF4: call      far ptr HelpF            ; obsluha n†povàdy AX

; ------ n†vrat registrñ

         pop       bx
         pop       ax
         ret

HelpAF   ENDP

; -----------------------------------------------------------------------------
;        hlavn° n†povàda
; -----------------------------------------------------------------------------

HelpMH:  mov       ax,Hlp@Main              ; hlavn° n†povàda

HelpMH4: add       sp,4                     ; zru®en° n†vratovÇ adresy
         call      far ptr ClosMnuA         ; uzav©en° v®ech oken menu
         call      far ptr HelpF            ; obsluha n†povàdy
         jmp       far ptr Main0

; -----------------------------------------------------------------------------
;        tÇmatick† n†povàda
; -----------------------------------------------------------------------------

HelpMT:  mov       ax,Hlp@TematickeCleneniNapovedy ; tÇmatick† n†povàda
         jmp       short HelpMH4

; -----------------------------------------------------------------------------
;        abecedn° n†povàda
; -----------------------------------------------------------------------------

HelpMA:  mov       ax,Hlp@AbecedniCleneniNapovedy ; abecedn° n†povàda
         jmp       short HelpMH4

; -----------------------------------------------------------------------------
;        posledn° n†povàda
; -----------------------------------------------------------------------------

HelpMP:  mov       ax,ds:[HlpAStrn]         ; posledn° n†povàda
         jmp       short HelpMH4

; -----------------------------------------------------------------------------
;        volba Odkazy
; -----------------------------------------------------------------------------

HelpMO   PROC      FAR

         xor       byte ptr ds:[HelpPar],bit5 ; zmàna p©°znaku odkazñ
         xor       dl,bit0                  ; zmàna p©ep°naáe
         call      far ptr SetSwch          ; nastaven° p©ep°naáñ
         call      far ptr DispMnu          ; novÇ zobrazen° okna menu
         ret

HelpMO   ENDP

; -----------------------------------------------------------------------------
;        export n†povàdy
; -----------------------------------------------------------------------------

HelpME:  add       sp,4                     ; zru®en° n†vratovÇ adresy
         call      far ptr ClosMnuA         ; uzav©en° menu
         or        byte ptr ds:[HelpPar],bit6 ; poëadavek exportu
         push      word ptr ds:[HlpAStrn]   ; £schova á°sla str†nky
         xor       ax,ax                    ; á°slo poá†teán° str†nky
         call      far ptr HelpF00          ; proveden° exportu
         pop       word ptr ds:[HlpAStrn]   ; n†vrat á°sla str†nky
         jmp       far ptr Main0

; *****************************************************************************
;                                MenKlHlp
;                        menu kl†ves malÇ n†povàdy
;                      uchov†v† registr p©°znakñ !
; -----------------------------------------------------------------------------
; VSTUP: DS:DI=menu kl†ves malÇ n†povàdy
;        DS=datovò segment
;        BX=kl†vesa (testuje se, zda je k¢d "MousXKod+MousXLP" nebo "+MousXLH")
; VùSTUP: BX=kl†vesa z menu, pokud plat° (jinak BX nezmànàn)
; *****************************************************************************

MenKlHlp PROC      FAR

; ------ £schova registrñ

         pushf
         push      ax
         push      di

; ------ kontrola, zda je my® na ©†dku malÇ n†povàdy

         mov       al,byte ptr ds:[MousePoz+1] ; ©†dek s kurzorem my®i
         cmp       al,ds:[MaxRow]           ; je posledn° ©†dek na displeji ?
         jne       MenKlHl8                 ; nen° posledn° ©†dek na displeji

; ------ kontrola, zda je k¢d my®i

         cmp       bh,MousXKod/HI           ; je k¢d my®i ?
         jne       MenKlHl8                 ; nen° k¢d my®i

; ------ stisk pravÇho tlaá°tka my®i se nahrad° kl†vesou Esc

         test      bl,bit3                  ; je stisk pravÇho tlaá°tka my®i ?
         jz        MenKlHl1                 ; nen° stisk pravÇho tlaá°tka my®i
         mov       bx,11bh                  ; n†hrada kl†vesou Esc
         jmp       short MenKlHl8

; ------ kontrola, zda je stisk levÇho tlaá°tka my®i

MenKlHl1:test      bl,bit2                  ; je stisk levÇho tlaá°tka my®i ?
         mov       bl,0                     ; k¢d tlaá°tka se zru®°
         jz        MenKlHl8                 ; nen° stisk levÇho tlaá°tka my®i

; ------ p©°prava registrñ

         mov       al,byte ptr ds:[MousePoz] ; pozice kurzoru my®i
MenKlHl2:add       di,3                     ; zvò®en° ukazatele v menu
         sub       al,ds:[di-3]             ; sn°ëen° ukazatele pozice
         jnc       MenKlHl2                 ; nen° je®tà pole s my®°
         mov       bx,ds:[di-2]             ; k¢d nalezenÇ kl†vesy

; ------ n†vrat registrñ

MenKlHl8:pop       di
         pop       ax
         popf
         ret

MenKlHlp ENDP

; *****************************************************************************
;                                HelpF
;                          obsluha n†povàdy
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo str†nky n†povàdy (0...)
;        DS=datovò segment
; *****************************************************************************
;˛
HelpF    PROC      FAR

         and       byte ptr ds:[HelpPar],not bit6 ; nen° export n†povàdy

; ------ test, zda je aktivn° INT 24h

HelpF00: test      byte ptr ds:[ParInt24],bit3 ; prob°h† obsluha INT 24h ?
         jnz       HelpF01                  ; je obsluha INT 24h - z†kaz

; ------ kontrola, zda je n†povàda jië vyvol†na

         test      byte ptr ds:[HelpPar],bit4 ; je n†povàda jië vyvol†na ?
         jz        HelpF0                   ; n†povàda nen° vyvol†na
HelpF01: ret

; ------ £schova registrñ

HelpF0:  push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         sub       sp,FileMax+10            ; buffer k uloëen° jmÇna n†povàdy
         mov       ds:[HlpAStrn],ax         ; á°slo poëadovanÇ str†nky

; ------ £schova kurzoru

         call      far ptr GetKurz          ; poskytnut° kurzoru
         mov       ds:[HelpOKur],dx         ; £schova kurzoru

; ------ p©°znak otev©en° menu n†povàdy

         or        byte ptr ds:[HelpPar],bit4 ; p©°znak otev©en° menu n†povàdy

; ------ sestaven° jmÇna souboru n†povàdy

         push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku
         mov       di,sp                    ; DI <- buffer v z†sobn°ku
         mov       si,offset HelpFile       ; jmÇno souboru n†povàdy
         call      far ptr HomeFile         ; sestaven° jmÇna souboru

; ------ p©°prava ukazatele pro hl†®en° chyby

         sub       di,sp                    ; dÇlka jmÇna souboru
         xchg      ax,di                    ; AX <- dÇlka jmÇna souboru
         mov       ds:[HelpChP2],al         ; dÇlka jmÇna souboru
         mov       ds:[HelpREr2],al
         mov       word ptr ds:[HelpChP3],sp ; offset adresy jmÇna souboru
         mov       word ptr ds:[HelpREr3],sp
         mov       word ptr ds:[HelpChP3+2],ss ; segment adresy jmÇna souboru
         mov       word ptr ds:[HelpREr3+2],ss

; ------ otev©en° souboru n†povàdy pro áten°

         mov       si,sp                    ; SI <- jmÇno souboru
         call      far ptr OpenR            ; otev©en° souboru n†povàdy
         jnc       HelpF13                  ; soubor otev©en OK

; ------ chyba - soubor n†povàdy nenalezen

         mov       si,offset HelpChyb       ; chybovÇ hl†®en°
HelpF12: call      far ptr Lin0MenF         ; chybovÇ hl†®en°
         jmp       HelpF9

; ------ naáten° z†hlav° souboru do z†sobn°ku

HelpF13: mov       ds:[HelpIdnt],ax         ; identifik†tor souboru
         mov       di,sp                    ; DI <- buffer v z†sobn°ku
         add       di,FileMax               ; konec bufferu pro naáten° dat
         mov       cx,10                    ; poáet bajtñ k naáten°
         call      far ptr Read0Fil         ; naáten° z†hlav° souboru
         jnc       HelpF15                  ; z†hlav° naáteno OK

; ------ chyba - soubor n†povàdy nespr†vnò

HelpF14: mov       si,offset HelpRErr
         jmp       short HelpF12            ; chybovÇ hl†®en°

; ------ kontrola z†hlav° souboru

HelpF15: mov       si,offset HelpIden       ; identifikaán° text
         cld
         dec       cx
         dec       cx                       ; poáet str†nek se nekontroluje
         rep       cmpsb                    ; porovn†n° z†hlav°
         jne       HelpF14                  ; chyba - z†hlav° nesouhlas°

; ------ £schova poátu str†nek (aby se mohl podhodit help z jinÇ verze)

         mov       ax,es:[di]               ; naátenò poáet str†nek
         or        ax,ax                    ; je nàjak† str†nka ?
         jz        HelpF14                  ; chyba - neplatnò poáet str†nek
         js        HelpF14                  ; chyba - neplatnò poáet str†nek
         mov       ds:[HelpStrn],ax         ; poáet str†nek n†povàdy
         xchg      ax,bx                    ; BX <- poáet str†nek v souboru

; ------ vytvo©en° bufferu k naáten° indexñ souboru

         call      far ptr CreatSeg         ; vytvo©en° segmentu
         jc        HelpF2                   ; chyba pamàti
         mov       ds:[HelpISeg],ax         ; segment indexñ n†povàdy

; ------ nastaven° velikosti segmentu indexñ

         shl       bx,1                     ; dÇlka indexovÇ tabulky
         call      far ptr ModiSegS         ; nastaven° velikosti segmentu
         jc        HelpF2

; ------ naáten° tabulky indexñ ze souboru

         call      far ptr GetDat           ; adresa tabulky indexñ -> ES
         mov       cx,bx                    ; CX <- poáet bajtñ k naáten°
         xor       di,di                    ; offset zaá†tku tabulky
         mov       ax,ds:[HelpIdnt]         ; identifik†tor souboru n†povàdy
         call      far ptr Read0Fil         ; naáten° indexovÇ tabulky
         jc        HelpF14                  ; chyba áten° ze souboru

; ------ vytvo©en° segmentu menu n†povàdy

         call      far ptr CreatSeg         ; vytvo©en° segmentu n†povàdy
         jc        HelpF2                   ; chyba
         mov       ds:[HelpMSeg],ax         ; segment n†povàdy

; ------ nastaven° velikosti segmentu n†povàdy

         mov       bx,HelpMSiz              ; poëadovan† velikost segmentu
         call      far ptr ModiSegS         ; nastaven° velikosti segmentu
         jnc       HelpF22

; ------ chyba - nedostatek pamàti k proveden° operace

HelpF2:  call      far ptr MemErr           ; hl†®en° - nedostatek pamàti
         jmp       HelpF9

; ------ vynulov†n° segmentu bufferu n†povàdy (pro £vodn° zobrazen°)

HelpF22: call      far ptr GetDat           ; adresa bufferu -> ES
         xor       di,di                    ; zaá†tek bufferu
         mov       al,HlpChLin              ; znak konce ©†dku
         mov       cx,bx                    ; CX <- poáet bajtñ v bufferu
         cld
         rep       stosb                    ; vynulov†n° bufferu
         mov       ds:[HlpMnTit],cl         ; nen° titulek n†povàdy

; ------ proveden° exportu n†povàdy

         test      byte ptr ds:[HelpPar],bit6 ; prov†d° se export ?
         jz        HelpF24                  ; nen° export
         call      HelpFExp                 ; proveden° exportu
         jmp       HelpF9                   ; konec

; ------ otev©en° menu n†povàdy

HelpF24: mov       si,offset HelpMenu
         call      far ptr OpenMnu          ; otev©en° menu n†povàdy

; ------ naáten° aktivn° str†nky n†povàdy

HelpF3:  mov       word ptr ds:[HlpAPol],1  ; aktivn° poloëka voleb str†nky
HelpF31: call      HelpRead                 ; naáten° str†nky ze souboru
         jnc       HelpF32                  ; str†nka naátena OK

; ------ chyba áten°

         call      far ptr ClosMnu          ; uzav©en° menu p©i chybà
         jmp       HelpF14                  ; chyba - neplatnò soubor n†povàdy

; ------ zobrazen° menu n†povàdy

HelpF32: mov       si,offset HelpMenu
         call      far ptr DispMnu

; ------ zobrazen° kurzoru na poloëce

HelpF34: mov       ax,ds:[HlpAPol]          ; aktivn° poloëka
         mov       si,offset HelpMenu
         call      HelpSrc                  ; nalezen° pozice poloëky
         jc        HelpF35                  ; nen° ë†dn† poloëka
         add       dx,word ptr ds:[si+MnuPoz] ; p©iáten° pozice okna helpu
         add       dx,2 + 1*HI
         call      far ptr SetKurz          ; nastaven° pozice kurzoru
         jmp       short HelpF36

HelpF35: call      far ptr KurzOff          ; kurzor vypnut

; ------ vstup znaku z kl†vesnice

HelpF36: call      far ptr InpChar          ; vstup znaku z kl†vesnice
         mov       di,offset HelpF40T       ; menu pro malou n†povàdy
         call      far ptr MenKlHlp         ; menu kl†ves malÇ n†povàdy
         call      far ptr NulBreak         ; nulov†n° p©°znaku p©eru®en°

; ------ skok na obsluhu kl†vesy

         mov       ax,ds:[HlpAStrn]         ; aktivn° str†nka
         call      far ptr JumpBX           ; obsluha kl†vesy

         dw        4900h,HelpF41            ; PageUp
         dw        5100h,HelpF42            ; PageDown

         dw        8400h,HelpF43            ; Ctrl-PageUp
         dw        7700h,HelpF43            ; Ctrl-Home

         dw        7600h,HelpF44            ; Ctrl-PageDown
         dw        7500h,HelpF44            ; Ctrl-End

         dw        4d00h,HelpF45            ; vpravo
         dw        0f09h,HelpF45            ; TAB

         dw        4b00h,HelpF46            ; vlevo
         dw        0f00h,HelpF46            ; Shift-TAB

         dw        4700h,HelpF47            ; Home
         dw        4f00h,HelpF48            ; End

         dw        5000h,HelpF51            ; dolñ
         dw        4800h,HelpF52            ; nahoru

         dw        0e08h,HelpF6             ; BS
         dw        1c0dh,HelpF7             ; ENTER
         dw        11bh,HelpF8              ; ESC
         dw        3b00h,HelpF71            ; F1
         dw        5400h,HelpF82            ; Shift-F1

         dw        4100h,HelpFH             ; F7
         dw        260Ch,HelpFH4            ; Ctrl-L

         dw        MousXKod+MousXRP,HelpF8  ; stisk pravÇho tlaá°tka my®i
         dw        MousXKod+MousXLR,HelpF7  ; uvolnàn° levÇho tlaá°tka my®i
         dw        MousXKod+MousXMov,HelpF40 ; pohyb my®°
         dw        MousXKod+MousXLP,HelpF40 ; stisk levÇho tlaá°tka my®i

         dw        0,HelpF34                ; neplatn† kl†vesa

; ------ veden° kurzoru my®°

HelpF40: mov       bx,ds:[MousePoz]         ; pozice kurzoru my®i
         sub       bx,word ptr ds:[HelpMenu+MnuPoz]  ; BL <- relativn° pozice v oknà
         sub       bx,2 + 1*HI  + 5         ; odeáten° okraje + korekce pozice
         xor       si,si                    ; ukazatel á°sla poloëky
         mov       dx,-1                    ; p©°znak neplatnÇ vzd†lenosti
HelpF401:mov       ax,si                    ; £schova á°sla poloëky
         mov       cx,dx                    ; £schova vzd†lenosti poloëky
HelpF402:inc       si                       ; zvò®en° ukazatele á°sla poloëky
         xchg      ax,si                    ; AX <- aktu†ln° poloëka, SI <- nalezen†
         push      bx
         call      HelpSrc                  ; nalezen° pozice poloëky
         pop       bx
         xchg      ax,si                    ; AX <- nalezen†, SI <- aktu†ln° poloëka
         jc        HelpF454                 ; nen° dal®° poloëka
         sub       dh,bh                    ; vzd†lenost ©†dku
         jns       HelpF403                 ; vzd†lenost je kladn† OK
         neg       dh                       ; absolutn° hodnota vzd†lenosti
HelpF403:sub       dl,bl                    ; vzd†lenost pozice
         jns       HelpF404                 ; vzd†lenost je kladn† OK
         neg       dl                       ; absolutn° hodnota vzd†lenosti
HelpF404:cmp       dx,cx                    ; je blië®° poloëka ?
         jb        HelpF401                 ; nalezena blië®° poloëka
         jmp       short HelpF402           ; dal®° poloëka

; ------ posledn° str†nka

HelpF44: mov       ax,ds:[HelpStrn]         ; poáet str†nek

; ------ p©ede®l† str†nka

HelpF41: or        ax,ax                    ; je jië str†nka 0 ?
         jz        HelpF419                 ; je jië str†nka 0
         dec       ax                       ; posun na p©ede®lou str†nku
HelpF418:cmp       ax,ds:[HlpAStrn]         ; màn° se á°slo str†nky ?
         je        HelpF419                 ; á°slo str†nky se nemàn°
         mov       ds:[HlpAStrn],ax         ; nov† aktivn° str†nka
         jmp       HelpF3                   ; nov† str†nka

HelpF419:jmp       HelpF34                  ; nic se nedàje

; ------ dal®° str†nka

HelpF42: inc       ax                       ; zvò®en° á°sla str†nky
         cmp       ax,ds:[HelpStrn]         ; je je®tà platnÇ á°slo str†nky ?
         jae       HelpF419                 ; nen° platnÇ á°slo str†nky
         jmp       short HelpF418           ; nov† aktivn° str†nka

; ------ prvn° str†nka

HelpF43: xor       ax,ax                    ; prvn° str†nka
         jmp       short HelpF418           ; nov† aktivn° str†nka

; ------ dal®° poloëka voleb

HelpF45: mov       ax,ds:[HlpAPol]          ; aktivn° poloëka
         inc       ax                       ; á°slo dal®° poloëky
         call      HelpSrc                  ; test dal®° poloëky
         jc        HelpF47                  ; nen° dal®° poloëka -> prvn°
HelpF454:mov       ds:[HlpAPol],ax          ; nov† aktivn° poloëka voleb
         jmp       HelpF32                  ; novÇ zobrazen°

; ------ p©ede®l† poloëka voleb

HelpF46: mov       ax,ds:[HlpAPol]          ; aktivn° poloëka
         dec       ax                       ; á°slo p©ede®lÇ poloëky
         jz        HelpF48                  ; je jië prvn° poloëka -> posledn°
         jmp       short HelpF454           ; nov† aktivn° poloëka voleb

; ------ prvn° poloëka voleb

HelpF47: mov       ax,1
         jmp       short HelpF454           ; nastaven° poloëky

; ------ posledn° poloëka voleb

HelpF48: mov       ax,ds:[HlpAPol]          ; aktivn° poloëka voleb
HelpF482:inc       ax                       ; zvò®en° á°sla poloëky
         call      HelpSrc                  ; je poloëka platn† ?
         jnc       HelpF482                 ; je platn† - dal®° poloëka
         dec       ax                       ; n†vrat á°sla poloëky
         jmp       short HelpF454           ; nastaven° á°sla poloëky

; ------ poloëka voleb nahoru

HelpF52: mov       si,-1                    ; posun nahoru
         jmp       short HelpF511

; ====== poloëka voleb dolñ

; ------ £schova parametrñ aktivn° poloëky

HelpF51: mov       si,1                     ; posun dolñ
HelpF511:mov       ax,ds:[HlpAPol]          ; aktivn° poloëka voleb
         call      HelpSrc                  ; naáten° parametrñ poloëky
         jc        HelpF519                 ; poloëka nenalezena
         mov       cx,dx                    ; £schova ©†dku a pozice poloëky

; ------ prvn° pokus o nalezen° poloëky na jinÇm ©†dku

HelpF512:add       ax,si                    ; dal®° poloëka
         call      HelpSrc                  ; dal®° poloëka
         jc        HelpF513                 ; nen° dal®° poloëka
         cmp       dh,ch                    ; je to jinò ©†dek ?
         je        HelpF512
         jmp       short HelpF516           ; nalezen° nejblië®° poloëky

; ------ p©eteáen° ukazatele p©ed okraj okna

HelpF513:mov       ax,1                     ; prvn° poloëka
         call      HelpSrc                  ; parametry prvn° poloëky
         cmp       si,1                     ; je posun dolñ ?
         je        HelpF515                 ; je posun dolñ

HelpF514:inc       ax
         call      HelpSrc                  ; test, zda je dal®° poloëka
         jnc       HelpF514                 ; test dal®° poloëky
         dec       ax                       ; posledn° poloëka
         call      HelpSrc                  ; parametry posledn° poloëky

; ------ mus° to bòt jinò ©†dek

HelpF515:cmp       dh,ch                    ; je to jinò ©†dek ?
         je        HelpF519                 ; nen° to jinò ©†dek

HelpF516:mov       ch,dh                    ; na tomto ©†dku se bude hledat
         mov       bl,255                   ; vzd†lenost nalezenÇ poloëky

; ------ nalezen° nejblië®° poloëky na ©†dku

HelpF517:sub       dl,cl                    ; vzd†lenost od pñvodn° poloëky
         jns       HelpF518                 ; je kladnÇ á°slo OK
         neg       dl                       ; absolutn° hodnota á°sla
HelpF518:cmp       dl,bl                    ; je men®° vzd†lenost ?
         jae       HlpF5182                 ; nen° men®° vzd†lenost
         mov       ds:[HlpAPol],ax          ; nov† aktivn° poloëka voleb
         mov       bl,dl                    ; BL <- nov† vzd†lenost

HlpF5182:add       ax,si                    ; dal®° poloëka
         push      bx
         call      HelpSrc                  ; dal®° poloëka
         pop       bx
         jc        HelpF519                 ; nen° dal®° poloëka
         cmp       ch,dh                    ; je to prohled†vanò ©†dek ?
         je        HelpF517                 ; je to prohled†vanò ©†dek OK

HelpF519:jmp       HelpF32                  ; novÇ zobrazen°

; ------ BS: n†vrat k p©ede®lÇ str†nce

HelpF6:  call      HelpFPop                 ; n†vrat str†nky z historie
         jc        HelpF519                 ; nen° dal®° str†nka
HelpF62: jmp       HelpF31                  ; naáten° novÇ str†nky

; ------ ENTER: vno©en° do volby

HelpF7:  mov       ax,ds:[HlpAPol]          ; aktivn° poloëka
         call      HelpSrc                  ; nalezen° poloëky
         jnc       HelpF72                  ; poloëka nalezena OK
         jmp       HelpF32                  ; poloëka nenalezena

; ------ F1: ovl†d†n° n†povàdy

HelpF71: mov       bx,Hlp@OvladaniNapovedy  ; str†nka ovl†d†n° n†povàdy
HelpF72: call      HelpFPsh                 ; £schova str†nky do historie
         mov       ds:[HlpAStrn],bx         ; nov† aktivn° str†nka
         jmp       HelpF3                   ; naáten° novÇ str†nky

; ------ je ESC: uzav©en° menu n†povàdy

HelpF8:  cmp       word ptr ds:[HlpAStrn],Hlp@OvladaniNapovedy ; ovl†d†n° n†povàdy ?
         jne       HelpF82                  ; nen° ovl†d†n° n†povàdy
         call      HelpFPop                 ; n†vrat str†nky z historie
         jnc       HelpF62                  ; naáten° str†nky

; ------ Shift-F1: konec n†povàdy

HelpF82: call      far ptr ClosMnu          ; uzav©en° okna n†povàdy

; ------ zru®en° segmentu n†povàdy

HelpF9:  mov       ax,ds:[HelpMSeg]         ; segment menu velkÇ n†povàdy
         call      far ptr DelSeg           ; zru®en° segmentu n†povàdy
         mov       ds:[HelpMSeg],ax         ; p©°znak zru®en° segmentu

; ------ zru®en° segmentu indexñ n†povàdy

         mov       ax,ds:[HelpISeg]         ; segment indexñ n†povàdy
         call      far ptr DelSeg           ; zru®en° segmentu indexñ n†povàdy
         mov       ds:[HelpISeg],ax         ; p©°znak zru®en° segmentu indexñ

; ------ uzav©en° souboru n†povàdy

         mov       ax,ds:[HelpIdnt]         ; identifik†tor souboru n†povàdy
         call      far ptr ClosFile         ; uzav©en° souboru n†povàdy
         mov       ds:[HelpIdnt],ax         ; p©°znak uzav©en° souboru

; ------ zru®en° p©°znaku otev©en° n†povàdy

         and       byte ptr ds:[HelpPar],not bit4 ; zru®en° p©°znaku otev©en°

; ------ n†vrat kurzoru

         call      far ptr NulBreak         ; nulov†n° p©°znaku p©eru®en°

         mov       dx,ds:[HelpOKur]         ; uschovanò pñvodn° kurzor
         call      far ptr SetKurz          ; navr†cen° kurzoru

; ------ n†vrat registrñ

         add       sp,FileMax+10            ; n†vrat SP
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

HelpF    ENDP

; -----------------------------------------------------------------------------
;        uloëen° aktu†ln° str†nky do historie
; -----------------------------------------------------------------------------

HelpFPsh PROC      NEAR

         push      ax
         push      si

         mov       si,ds:[HelpHisU]         ; ukazatel v historii n†povàdy
         mov       ax,ds:[HlpAStrn]         ; aktivn° str†nka
         mov       ds:[si],ax               ; £schova aktivn° str†nky
         inc       si
         inc       si
         mov       ax,ds:[HlpAPol]          ; aktivn° poloëka
         mov       ds:[si],ax               ; £schova aktivn° poloëky
         inc       si
         inc       si                       ; posun ukazatele
         cmp       si,offset HelpHis+4*HelpHMax ; je ukazatel OK ?
         jb        HelpFPs2                 ; ukazatel je OK
         mov       si,offset HelpHis        ; posun na zaá†tek
HelpFPs2:mov       ds:[HelpHisU],si         ; £schova ukazatele
         mov       word ptr ds:[si],-1      ; nulov†n° dal®° poloëky (str†nka)

         pop       si
         pop       ax
         ret

HelpFPsh ENDP

; -----------------------------------------------------------------------------
;        n†vrat uschovanÇ str†nky z historie (CY=nen°)
; -----------------------------------------------------------------------------

HelpFPop PROC      NEAR

         push      ax
         push      si

         mov       si,ds:[HelpHisU]         ; ukazatel v historii poloëek
         sub       si,4                     ; posun ukazatele
         cmp       si,offset HelpHis        ; podteáen° zaá†tku ?
         jae       HelpFPo2                 ; ukazatel je OK
         mov       si,offset HelpHis+4*HelpHMax-4 ; posun ukazatele na konec
HelpFPo2:mov       ax,-1                    ; p©°znak neplatnÇ str†nky
         xchg      ax,ds:[si]               ; naáten° á°sla uschovanÇ str†nky
         cmp       ax,-1                    ; je dal®° str†nka v historii ?
         cmc
         jc        HelpFPo9                 ; nen° dal®° str†nka

         mov       ds:[HelpHisU],si         ; novò ukazatel v historii
         mov       ds:[HlpAStrn],ax         ; nov† aktivn° str†nka
         mov       ax,ds:[si+2]             ; á°slo poloëky
         mov       ds:[HlpAPol],ax          ; nov† aktivn° poloëka
                                          ;* zde je NC
HelpFPo9:pop       si
         pop       ax
         ret

HelpFPop ENDP

; -----------------------------------------------------------------------------
;        F7: vyhled†n° textu v n†povàdà (Ctrl-L = d†le)
; -----------------------------------------------------------------------------
;˛
; ------ zad†n° textu k vyhled†n°

HelpFH:  mov       si,offset ZZHMnLin
         call      far ptr Lin0Menu         ; zad†n° textu k hled†n°
         jnc       HelpFH2                  ; zad†n° OK
HelpFH1: jmp       HelpF34                  ; p©eru®en° operace

HelpFH2: call      far ptr KurzOff          ; vypnut° kurzoru
         call      far ptr EdiZUsch         ; £schova zadanÇho textu
         jc        HelpFH1                  ; nen° zad†n ë†dnò text

; ------ £schova aktu†ln° str†nky a kurzoru

         call      HelpFPsh                 ; £schova aktu†ln° str†nky
         mov       word ptr ds:[HlpAStrn],-1 ; inicializace ukazatele str†nek
         jmp       short HelpFH44

; ------ pokraáov†n° v hled†n°

HelpFH4: cmp       byte ptr ds:[TextFndN],0 ; je nàjakò text ?
         je        HelpFH1                  ; nen° zad†n ë†dnò text
         call      HelpFPsh                 ; £schova aktu†ln° str†nky

; ------ test, zda bude dal®° str†nka

HelpFH44:mov       si,offset HelpHled       ; text hl†®en°
         call      far ptr InfDisp0         ; zobrazen° hl†®en°

HelpFH5: inc       word ptr ds:[HlpAStrn]   ; zvò®en° ukazatele á°sla str†nky

HelpFH6: call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jc        HelpFH62                 ; p©eru®en° operace
         mov       ax,ds:[HlpAStrn]         ; aktu†ln° str†nka k hled†n°
         cmp       ax,ds:[HelpStrn]         ; je je®tà platnÇ á°slo str†nky ?
         jb        HelpFH7                  ; je to platn† str†nka OK

; ------ p©i chybà n†vrat pñvodn° str†nky

HelpFH62:call      HelpFPop                 ; n†vrat str†nky z historie
         call      HelpRead                 ; naáten° str†nky ze souboru

; ------ hl†®en° - text nenalezen (p©edpoklad - pñvodn° str†nka je®tà zobrazena)

         mov       al,byte ptr ds:[TextFndN] ; dÇlka hledanÇho textu
         mov       ds:[ZZ2MnPl2],al         ; dÇlka textu hl†®en°
         mov       si,offset ZZ2MnLin       ; chybovÇ hl†®en°
         call      far ptr Lin0MenF         ; hl†®en° - text nenalezen
         jmp       HelpF32

; ------ naáten° dal®° prohled†vanÇ str†nky

HelpFH7: call      far ptr FlushChr         ; vypr†zdnàn° bufferu kl†vesnice
         call      HelpRead                 ; naáten° str†nky ze souboru
         jc        HelpFH5                  ; chyba - dal®° str†nka

; ------ p©°prava k vyhled†n° textu ve str†nce

         mov       ax,ds:[HelpMSeg]         ; segment n†povàdy
         call      far ptr GetDat           ; adresa bufferu -> ES
         mov       bx,ds:[HelpMEnd]         ; poáet bajtñ v bufferu
         xor       di,di                    ; ukazatel dat v bufferu
         sub       bx,ds:[TextFndN]         ; bez posledn°ho ©etàzce
         jc        HelpFH5                  ; m†lo dat
         inc       bx                       ; p©ednastaven°

; ------ porovn†n° textu na jednÇ adrese

HelpFH8: push      di
         mov       si,offset TextFnd-1      ; hledanò text
         mov       cx,ds:[TextFndN]         ; dÇlka hledanÇho textu
HelpFH82:mov       al,es:[di]               ; prohled†vanò buffer
         inc       di
         inc       si
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         cmp       al,ds:[si]               ; souhlas° znak ?
         loope     HelpFH82                 ; dal®° znak
         pop       di
         je        HelpFH9                  ; text nalezen OK

; ------ p©°prava pro dal®° ©etàzec

         inc       di                       ; zvò®en° ukazatele adres
         dec       bx                       ; á°taá pokusñ
         jnz       HelpFH8                  ; dal®° pokus
         jmp       short HelpFH5            ; text nenalezen - dal®° str†nka

; ------ str†nka nalezena OK

HelpFH9: mov       word ptr ds:[HlpAPol],1  ; aktivn° poloëka voleb str†nky
         call      far ptr InfoClos         ; uzav©en° informaán°ho ©†dku
         jmp       HelpF32                  ; zobrazen° nalezenÇ str†nky

; -----------------------------------------------------------------------------
;        proveden° exportu dat (neuchov†v† registry)
; -----------------------------------------------------------------------------
;˛
HelpFExp PROC      NEAR

; ------ p©°prava bufferu v z†sobn°ku (pro 1 ©†dek asi tak maxim†lnà 200 znakñ)

         push      bp
         mov       bp,sp
         sub       bp,20                    ; asi tolik maxim†ln° konec bufferu
         sub       sp,200

; ------ hl†®en° o exportu

         mov       si,offset HlasExp
         call      far ptr InfDisp0         ; zobrazen° hl†®en°

; ------ sestaven° plnÇho jmÇna souboru k exportu

         push      ss
         pop       es                       ; ES <- segment bufferu
         mov       di,sp                    ; DI <- offset bufferu
         mov       si,offset HelpExpF       ; soubor k exportu
         mov       cx,offset(HelpEx0F-HelpExpF)+1 ; dÇlka jmÇna + koncov† 0
         cld
         rep       movsb                    ; £schova do z†sobn°ku
         mov       cl,offset(HelpEx0F-HelpExpF)
         mov       si,sp                    ; SI <- jmÇno souboru
         call      far ptr FullFile         ; normalizace jmÇna

; ------ vytvo©en° souboru

         call      far ptr CreatFil         ; vytvo©en° souboru
         jnc       HelpFEx1                 ; soubor vytvo©en OK
         jmp       HelpFEx9

HelpFEx1:mov       ds:[HelpExpI],ax         ; identifik†tor souboru k exportu
         call      far ptr ModiWDir         ; aktualizace okna

; ------ naáten° aktu†ln° str†nky do pamàti

HelpFEx2:call      HelpRead                 ; naáten° str†nky ze souboru
         jnc       HelpFEx3                 ; operace OK
         jmp       HelpFEx8                 ; nàjak† chyba

HelpFEx3:inc       word ptr ds:[HlpAStrn]   ; zvò®en° á°sla str†nky

; ------ p©°prava á†ry pro nadpis

         push      ss
         pop       es                       ; ES <- buffer v z†sobn°ku
         mov       di,sp
         push      di
         mov       cx,76                    ; dÇlka ©†dku
         cld
         mov       al,"ƒ"
         rep       stosb                    ; uloëen° á†ry

; ------ dek¢dov†n° á°sla str†nky

         test      byte ptr ds:[HelpPar],bit5 ; jsou odkazy ?
         jz        HelpFE32                 ; nejsou odkazy
         mov       al," "                   ; mezera
         stosb                              ; £vodn° mezera
         mov       ax,ds:[HlpAStrn]         ; á°slo str†nky + 1
         xor       bx,bx                    ; nen° barva ani oddàlovaá
         call      far ptr DekNumW          ; dek¢dov†n° á°sla str†nky
         cld

; ------ uloëen° konce ©†dku CR/LF

HelpFE32:mov       ax,CR + LF*HI
         stosw                              ; uloëen° koncovÇho CR/LF
         mov       dx,di                    ; DX <- £schova adresy konce textu
         pop       di                       ; zaá†tek bufferu

; ------ p©°prava adresy k dek¢dov†n° nadpisu

         mov       cl,ds:[HlpMnTit]         ; dÇlka nadpisu
         mov       ch,0
         mov       ax,76-2                  ; dÇlka ©†dku bez mezer
         sub       ax,cx                    ; zbytek na okraje
         shr       ax,1                     ; polovina na okraje
         add       di,ax                    ; adresa k uloëen° textu nadpisu

; ------ dek¢dov†n° nadpisu

         push      dx
         push      ds
         mov       ax,ds:[HelpMSeg]         ; segment n†povàdy
         call      far ptr GetSgAdr         ; adresa segmentu n†povàdy -> DX
         mov       ds,dx                    ; DS <- segment bufferu
         xor       si,si                    ; SI <- zaá†tek textu nadpisu
         cld
         mov       al," "                   ; mezera
         stosb                              ; £vodn° mezera
         rep       movsb                    ; p©enos titulku
         stosb                              ; koncov† mezera
         pop       ds
         pop       dx

; ------ z†pis ©†dku nadpisu do souboru

         mov       ax,ds:[HelpExpI]         ; identifik†tor souboru
         mov       si,sp                    ; buffer
         mov       cx,dx                    ; CX <- konec textu
         sub       cx,si                    ; dÇlka nadpisu
         call      far ptr WritFile         ; z†pis ©†dku nadpisu

; ------ p©°prava k dek¢dov†n° jednoho ©†dku (ES=SS)

         mov       bh,ds:[HelpPar]          ; parametry
         mov       bl,22                    ; poáet ©†dkñ k dek¢dov†n°
HelpFEx4:mov       di,sp                    ; DI <- buffer v z†sobn°ku
         mov       si,ds:[HelpMTop]         ; adresa zaá†tku dat v bufferu

HelpFE42:push      ds

         mov       ax,ds:[HelpMSeg]         ; segment n†povàdy
         call      far ptr GetSgAdr         ; adresa segmentu n†povàdy -> DX
         mov       ds,dx                    ; DS <- segment bufferu
         cld

; ------ dek¢dov†n° jednoho ©†dku

HelpFEx5:lodsb                              ; naáten° bajtu
         cmp       al,HlpChLin              ; je konec ©†dku ?
         je        HelpFEx7                 ; je konec ©†dku
         ja        HelpFE54                 ; je platnò znak nebo mezery

; ------ obsluha odkazu

         cmp       al,HlpChSym              ; je odkaz ?
         jne       HelpFEx5                 ; nen° odkaz
         lodsw                              ; p©eskoáen° str†nky odkazu
         test      bh,bit5                  ; jsou odkazy ?
         jz        HelpFEx5                 ; nejsou odkazy

; ------ dek¢dov†n° á°sla odkazu

         mov       al,"{"                   ; lev† z†vorka
         stosb

         dec       si
         dec       si
         lodsw                              ; naáten° á°sla podstr†nky
         pop       ds

         inc       ax                       ; korekce á°sla odkazu
         push      bx
         xor       bx,bx                    ; neukl†d† se barva ani oddàlovaá
         call      far ptr DekNumW          ; dek¢dov†n° á°sla str†nky
         pop       bx

         cld
         mov       ax," }"
         stosw                              ; pravò okraj z†vorky a mezera

         jmp       short HelpFE42           ; obnoven° adresy

; ------ dek¢dov†n° mezery

HelpFE54:mov       cx,1                     ; zap°®e se 1 znak
         cmp       al," "                   ; jsou mezery ?
         jae       HelpFEx6                 ; je platnò znak
         sub       al,6                     ; korekce poátu mezer
         mov       cl,al                    ; CL <- poáet mezer k z†pisu
         mov       al," "                   ; znak mezery k z†pisu

; ------ uloëen° CX znakñ

HelpFEx6:cmp       di,bp                    ; je je®tà platn† adresa ?
         jae       HelpFEx7                 ; je jië konec bufferu
         stosb                              ; uloëen° znaku
         loop      HelpFEx6                 ; dal®° znak
         jmp       short HelpFEx5           ; dal®° znak

; ------ z†pis konce ©†dku

HelpFEx7:mov       ax,CR + LF*HI            ; znak konce ©†dku
         stosw                              ; uloëen° konce ©†dku

; ------ z†pis ©†dku

         pop       ds

         mov       ds:[HelpMTop],si         ; novò ukazatel dat v bufferu
         mov       si,sp                    ; buffer v z†sobn°ku
         mov       cx,di                    ; CX <- konec dat v bufferu
         sub       cx,si                    ; dÇlka dat k z†pisu
         mov       ax,ds:[HelpExpI]         ; identifik†tor souboru
         call      far ptr WritFile         ; z†pis ©†dku

; ------ p©°prava pro dal®° ©†dek

         dec       bl                       ; á°taá ©†dkñ
         jnz       HelpFEx4                 ; dal®° ©†dek

; ------ p©°prava pro dal®° str†nku

         mov       ax,ds:[HlpAStrn]         ; á°slo poëadovanÇ str†nky
         cmp       ax,ds:[HelpStrn]         ; je á°slo str†nky OK ?
         jae       HelpFEx8                 ; jsou jië v®echny str†nky
         jmp       HelpFEx2                 ; obsluha dal®° str†nky

; ------ uzav©en° souboru k exportu

HelpFEx8:mov       ax,ds:[HelpExpI]         ; identifik†tor souboru
         call      far ptr ClosFile         ; uzav©en° souboru

; ------ n†vrat registrñ v z†sobn°ku

HelpFEx9:add       bp,20
         mov       sp,bp
         pop       bp
         call      far ptr InfoClos         ; uzav©en° informaán°ho ©†dku
         ret

HelpFExp ENDP

; -----------------------------------------------------------------------------
;        nalezen° volby AX (1...) -> DH=©†dek, DL=pozice, BX=str†nka, CY=nen°
; -----------------------------------------------------------------------------

HelpSrc  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      es
         xchg      ax,cx                    ; CX <- poëadovan† volba 1...

; ------ adresa bufferu -> ES

         mov       ax,ds:[HelpMSeg]         ; segment bufferu
         call      far ptr GetDat           ; adresa bufferu -> ES

; ------ p©°prava registrñ k operaci

         mov       si,ds:[HelpMTop]         ; adresa dat v bufferu
         xor       dx,dx                    ; ukazatel ©†dku a pozice
         cld

; ------ naáten° znaku z bufferu

HelpSrc1:lods      byte ptr es:[si]         ; naáten° dal®°ho znaku z bufferu

; ------ zvò®en° ukazatele ©†dku

         cmp       al,HlpChLin              ; je konec ©†dku ?
         jne       HelpSrc3                 ; nen° konec ©†dku
         inc       dh                       ; zvò®en° ukazatele ©†dku
         mov       dl,0                     ; pozice na zaá†tek ©†dku

; ------ test, zda jsou jië v®echny ©†dky (22 ©†dkñ)

         cmp       dh,22                    ; jsou jië v®echny ©†dky ?
         jb        HelpSrc1                 ; nejsou je®tà v®echny ©†dky
         stc                                ; p©°znak nenalezen° volby
         jmp       short HelpSrc9           ; konec

; ------ test, zda je p©ep°naá barev

HelpSrc3:jb        HelpSrc4                 ; je p©ep°naá barvy

; ------ test, zda je bàënò znak

         inc       dx                       ; zvò®en° pozice pro bàënò znak
         cmp       al," "                   ; je bàënò znak ?
         jae       HelpSrc1                 ; je bàënò znak

; ------ zvò®en° pozice pro oddàlovaá mezer

         sub       al,6+1                   ; korekce pro oddàlovaá
         add       dl,al                    ; zvò®en° pozice pro oddàlovaá
         jmp       short HelpSrc1           ; dal®° znak

; ------ test, zda je p©ep°naá symbolu

HelpSrc4:cmp       al,HlpChSym              ; je symbol ?
         jne       HelpSrc1                 ; nen° symbol (pozice se nezvò®°)

; ------ test, zda to je hledanò symbol (zde je NC !)

         mov       bx,es:[si]               ; p©°padnò odkaz symbolu
         inc       si                       ; p©eskoáen° á°sla str†nky
         inc       si
         loop      HelpSrc1                 ; dal®° symbol
                                          ;* zde je NC !
; ------ n†vrat registrñ

HelpSrc9:pop       es
         pop       si
         pop       cx
         pop       ax
         ret

HelpSrc  ENDP

; -----------------------------------------------------------------------------
;        naáten° aktivn° str†nky n†povàdy (neuchov†v† registry !) -> CY=chyba
; -----------------------------------------------------------------------------

HelpRead PROC      NEAR

         call      far ptr NulBreak         ; nulov†n° p©°znaku p©eru®en°

; ------ p©°prava á°sla poëadovanÇ str†nky -> CX

         mov       ax,ds:[HlpAStrn]         ; á°slo poëadovanÇ str†nky
         cmp       ax,ds:[HelpStrn]         ; je á°slo str†nky OK ?
         jb        HlpRead1                 ; á°slo str†nky je OK
         xor       ax,ax                    ; AX <- 0 n†hradn° str†nka
         mov       ds:[HlpAStrn],ax         ; nov† aktivn° str†nka
HlpRead1:xchg      ax,cx                    ; CX <- poëadovan† str†nka

; ------ adresa tabulky indexñ -> ES:SI

         mov       ax,ds:[HelpISeg]         ; segment indexñ n†povàdy
         call      far ptr GetDat           ; adresa segmentu indexñ -> ES
         xor       si,si                    ; SI <- offset zaá†tku tabulky

; ------ p©°prava á°taáe offsetu str†nky v souboru

         xor       dx,dx                    ; DX <- 0 offset HIGH
         mov       ax,ds:[HelpStrn]         ; poáet str†nek v souboru celkem
         shl       ax,1                     ; dÇlka indexovÇ tabulky
         add       ax,10                    ; p©iáten° z†hlav° = offset LOW
         adc       dx,dx                    ; p©enos

; ------ nalezen° str†nky v tabulce indexñ -> DX:AX=offset str†nky v souboru

         jcxz      HlpRead3                 ; je str†nka 0
HlpRead2:add       ax,es:[si]               ; p©iáten° dÇlky str†nky
         adc       dx,0                     ; p©enos
         inc       si                       ; zvò®en° ukazatele v tabulce
         inc       si
         loop      HlpRead2                 ; dal®° index v tabulce

; ------ nastaven° ukazatele v souboru

HlpRead3:xchg      ax,cx                    ; CX <- offset v souboru LOW
         mov       ax,ds:[HelpIdnt]         ; identifik†tor souboru
         call      far ptr SetUFile         ; nastaven° ukazatele v souboru
         jc        HlpRea49                 ; nàjak† chyba

; ------ p©°prava dÇlky str†nky -> CX

         mov       cx,es:[si]               ; dÇlka poëadovanÇ str†nky
         cmp       cx,4                     ; asi tak minim†ln° velikost
         jb        HlpRea49                 ; chybn† velikost str†nky
         cmp       cx,HelpMSiz              ; je velikost str†nky OK ?
         jbe       HlpRead4                 ; velikost str†nky je OK
         mov       cx,HelpMSiz              ; omezen° dÇlky str†nky

; ------ datovò segment k naáten° str†nky -> ES

HlpRead4:push      ax
         mov       ax,ds:[HelpMSeg]         ; datovò segment n†povàdy
         call      far ptr GetDat           ; adresa bufferu -> ES
         pop       ax

; ------ offset k naáten° str†nky -> DI

         mov       di,HelpMSiz              ; velikost bufferu
         sub       di,cx                    ; zaá†tek k naáten° dat str†nky

; ------ naáten° str†nky do buffferu ES:DI (CX bajtñ)

         call      far ptr Read0Fil         ; naáten° str†nky do pamàti
HlpRea49:jc        HlpRead9                 ; chyba operace

; ------ dekomprimace dat str†nky

         mov       si,di                    ; SI <- zaá†tek komprim. dat
         xor       di,di                    ; DI <- 0 zaá†tek k uloëen° dat
         call      HlpDek                   ; dekomprimace str†nky

; ------ p©°prava titulku okna (ES=buffer) (zñst†v† v k¢du Kamenickòch !)

         push      di

         xor       si,si
         mov       di,offset HlpMnTit+1     ; buffer k uloëen° titulku
         mov       byte ptr ds:[di-1],0     ; nulov†n° dÇlky titulku
HlpRead5:lods      byte ptr es:[si]         ; naáten° znaku
         cmp       al,HlpChLin              ; je konec ©†dku ?
         je        HlpRead6                 ; nalezen konec ©†dku
         cmp       di,offset HlpMnTit+1+50  ; je konec bufferu ?
         jae       HlpRead5                 ; buffer je jië plnò
         inc       byte ptr ds:[HlpMnTit]   ; zvò®en° á°taáe dÇlky titulku
         mov       ds:[di],al               ; uloëen° znaku
         inc       di                       ; zvò®en° ukazatele textu
         jmp       short HlpRead5           ; dal®° znak

HlpRead6:mov       ds:[HelpMTop],si         ; adresa zaá†tku dat v bufferu

         pop       di                       ; konec dat v bufferu
         mov       ds:[HelpMEnd],di         ; adresa konce dat v bufferu

; ------ p©ek¢dov†n° n†rodn°ho k¢du n†povàdy (DI=konec dat v bufferu)

;˛
; !!!!!!!!!!! Pouë°t proceduru KonvFChr nebo tabulku KodFntTb !!!!!!!!!!!


         mov       bl,ds:[CodePage]         ; aktivn° k¢dov† str†nka
         push      ds

         xor       si,si                    ; SI <- ukazatel dat
         mov       bh,0
         shl       bx,1
         mov       ax,SEG CodeDek           ; k¢dovac° segment
         mov       ds,ax                    ; DS <- k¢dovac° segment

ASSUME   ds:CodeDek

         mov       bx,ds:[bx+KonvFntT+6*2-2] ; adresa tabulky
         or        bx,bx                    ; je tabulka platn† ?
         jz        HlpRea46                 ; nen° platn†

         cld
HlpRea42:cmp       si,di
         jae       HlpRea46
         lods      byte ptr es:[si]
         cmp       al,HlpChSym              ; je to symbol ?
         jne       HlpRea43                 ; je to symbol
         inc       si
         inc       si                       ; p©eskoáen° á°sla str†nky
HlpRea43:cmp       al,128
         jb        HlpRea42
         xlat
         mov       es:[si-1],al
         jmp       short HlpRea42

HlpRea46:pop       ds

ASSUME   ds:Data

         clc                                ; p©°znak operace OK
HlpRead9:ret

HelpRead ENDP

; -----------------------------------------------------------------------------
;        dekomprimace dat v bufferu (ES=segment, SI -> DI, konec dat "HelpMSiz")
; -----------------------------------------------------------------------------

MAXLENX  EQU       25                       ; min. dÇlka dlouhÇho ©etàzce
MAXLEN   EQU       MAXLENX+254              ; maxim†ln° dÇlka ©etàzce

SUBSTLEN EQU       7                        ; dÇlka nahrazen† dlouhòm k¢dem

HlpDek   PROC      NEAR

; ------ £schova registrñ

         push      ds
         push      es
         pop       ds                       ; DS <- segment bufferu

; ------ p©°prava k dek¢dov†n°

         cld                                ; smàr nahoru
         mov       ax,1                     ; p©°znak, ëe nen° dal®° bit

; ------ prvn° p©°znakovò bit

HlpDek1: call      HlpDkB                   ; prvn° p©°znakovò bit
         jz        HlpDek2                  ; konec dat
         jc        HlpDek3                  ; je komprese ©etàzce

; ------ p©esun jednoho bajtu dat bez komprese

         call      HlpDkByt                 ; naáten° bajtu -> DH
         jz        HlpDek2                  ; konec dat
         cmp       di,si
         jae       HlpDek2                  ; chyba p©eteáen°
         mov       ds:[di],dh               ; uloëen° bajtu
         inc       di                       ; zvò®en° ukl†dac° adresy
         jmp       short HlpDek1            ; nen° p©eteáen° bufferu

; ------ n†vrat registrñ

HlpDek2: pop       ds
         ret

; ------ p©°prava k opakov†n° ©etàzce

HlpDek3: xor       bx,bx                    ; BX <- 0 offset ©etàzce
         xor       cx,cx                    ; dÇlka ©etàzce k opakov†n°

; -----------------------------------
;        stanoven° dÇlky ©etàzce
; -----------------------------------

; ------ prvn° bit dÇlky

         mov       dl,1                     ; poáet bitñ ke áten°
         call      HlpDkBC                  ; áten° prvn°ho a druhÇho bitu dÇlky
         jz        HlpDek2                  ; p©eteáen° bufferu
                                            ; (zde je stav 0 aë 1)

; ------ zvò®en° á°taáe dÇlky

HlpDek32:inc       cx
         inc       cx                       ; dÇlka 2 aë 3

; ------ naáten° p©°znaku konce k¢du

         call      HlpDkB                   ; p©°znakovò bit
         jz        HlpDek2                  ; p©eteáen° bufferu
         jnc       HlpDek38                 ; konec k¢du

; ------ p©°padnÇ pokraáov†n° k¢du

         cmp       cl,MAXLENX-4+1           ; je jië maxim†ln° dÇlka ?
         jb        HlpDek32                 ; pokraáov†n° k¢du
         inc       cx
         inc       cx                       ; korekce posledn°ch 2 k¢dñ

; ------ korekce pro n†hradn° k¢d

HlpDek38:cmp       cl,SUBSTLEN              ; je n†hradn° dÇlka ?
         jb        HlpDek7                  ; dÇlka je OK
         ja        HlpDek39                 ; je dlouh† dÇlka

; ------ dlouhÇ opakov†n°

         call      HlpDkByt                 ; naáten° bajtu
HlpDek51:jz        HlpDek2                  ; konec
         mov       cl,dh                    ; dÇlka (stav 0 aë 255)
         cmp       cl,255                   ; konec dek¢dov†n° ?
         je        HlpDek51                 ; je konec
         add       cx,MAXLENX+1             ; zvò®en° dÇlky

; ------ korekce dÇlky pro dlouhò k¢d

HlpDek39:dec       cx

; ------------------------------------
;        stanoven° offsetu ©etàzce
; ------------------------------------

; ------ dÇlka 2 nem† offset HIGH

HlpDek7: cmp       cx,2                     ; je dÇlka 2 ?
         je        HlpDek9                  ; je dÇlka 2

; ------ prvn° p©°znakovò bit - p©°znak offsetu HIGH=0

         call      HlpDkB                   ; áten° p©°znakovÇho bitu
         jz        HlpDek51                 ; p©eteáen° bufferu
         jc        HlpDek9                  ; offset HIGH = 0

; ------ 3 bity offsetu HIGH

         mov       dl,3                     ; naátou se 3 bity
         call      HlpDkBB                  ; naáten° 3 bitñ offsetu
         jz        HlpDek51                 ; p©eteáen° bufferu

; ------ stav 0,1: offset HIGH = 1,2

         cmp       bh,1                     ; je stav 0,1 ?
         jbe       HlpDek8                  ; offset HIGH = 1,2

; ------ átvrtò bit offsetu

         call      HlpDkBB                  ; naáten° 1 bitu offsetu
         jz        HlpDek51                 ; p©eteáen° bufferu

; ------ stav 4,7: offset HIGH=3 aë 6

         dec       bh                       ; stav 3 aë 14
         cmp       bh,6                     ; je stav 3 aë 6 ?
         jbe       HlpDek9                  ; je offset 3 aë 6
                                            ; jinak stav 7 aë 14

; ------ p†tò bit offsetu

         call      HlpDkBB                  ; naáten° 1 bitu offsetu
         jz        HlpDek51                 ; p©eteáen° bufferu

; ------ stav 14 aë 23: offset HIGH=7 aë 13

         sub       bh,7                     ; stav 7 aë 22
         cmp       bh,13
         jbe       HlpDek9                  ; je offset 7 aë 13
                                            ; jinak stav 14 aë 22

; ------ ®estò bit offsetu: offset HIGH=14 aë 31

         call      HlpDkBB                  ; naáten° 1 bitu offsetu
         jz        HlpDek51                 ; p©eteáen° bufferu
         sub       bh,15                    ; stav 13 aë 30

; ------ offset ©etàzce LOW

HlpDek8: inc       bh                       ; korekce BH
HlpDek9: call      HlpDkByt                 ; naáten° offsetu dÇlky LOW
         mov       bl,dh                    ; offset dÇlky LOW
         jz        HlpDek51                 ; p©eteáen° bufferu

; ------ malÇ o®et©en° proti p©eteáen°

         cmp       di,si
         jae       HlpDek51                 ; chyba p©eteáen°

; ------ p©enos ©etàzce

         push      si                       ; £schova SI
         mov       si,di                    ; souáasnò ukazatel
         sub       si,bx                    ; posun zaá†tku ©etàzce
         jc        HlpDekA                  ; chyba
         rep       movsb                    ; p©enos dat
HlpDekA: pop       si
         jmp       HlpDek1                  ; dal®° dek¢dov†n°

HlpDek   ENDP

; -----------------------------------------------------------------------------
;        poskytnut° bitu ze stavovÇho slova do registru BH
; -----------------------------------------------------------------------------
; VSTUP: AX=stavovÇ slovo (nastaven nejvy®®° bit jako p©°znak konce slova)
;        DS:SI=ukazatel zkomprimovanòch dat
;        BH=pñvodn° stav registru BH
;        DL=poáet bitñ k naáten° do registru BH (nesm° bòt = 0 !)
; VùSTUP:ZY=konec dat
;        BH=novò stav registru BH
;        DL=1 (p©ipraveno pro áten° 1 bitu)
;        AX=novÇ stavovÇ slovo
;        DS:SI=novò ukazatel dat
; niá° registr DH
; -----------------------------------------------------------------------------

HlpDkBB  PROC      NEAR

         call      HlpDkB                   ; áten° bitu stavovÇho slova
         jz        HlpDkBB9                 ; konec dat
         rcl       bh,1                     ; rotace bitu do registru BH
         dec       dl                       ; sn°ëen° á°taáe bitñ DL
         jnz       HlpDkBB                  ; áten° dal®°ho bitu
         inc       dx                       ; nastaven° p©°znaku NZ
HlpDkBB9:ret

HlpDkBB  ENDP

; -----------------------------------------------------------------------------
;        poskytnut° bitu ze stavovÇho slova do registru CX
; -----------------------------------------------------------------------------
; VSTUP: AX=stavovÇ slovo (nastaven nejvy®®° bit jako p©°znak konce slova)
;        DS:SI=ukazatel zkomprimovanòch dat
;        CX=pñvodn° stav registru CX
;        DL=poáet bitñ k naáten° do registru CX (nesm° bòt = 0 !)
; VùSTUP:ZY=konec dat
;        CX=novò stav registru CX
;        DL=1 (p©ipraveno pro áten° 1 bitu)
;        AX=novÇ stavovÇ slovo
;        DS:SI=novò ukazatel dat
; niá° registr DH
; -----------------------------------------------------------------------------

HlpDkBC  PROC      NEAR

         call      HlpDkB                   ; áten° bitu stavovÇho slova
         jz        HlpDkBC9                 ; konec dat
         rcl       cx,1                     ; rotace bitu do registru CX
         dec       dl                       ; sn°ëen° á°taáe bitñ DL
         jnz       HlpDkBC                  ; áten° dal®°ho bitu
         inc       dx                       ; nastaven° p©°znaku NZ
HlpDkBC9:ret

HlpDkBC  ENDP

; -----------------------------------------------------------------------------
;        poskytnut° bitu ze stavovÇho slova
; -----------------------------------------------------------------------------
; VSTUP: AX=stavovÇ slovo (nastaven nejvy®®° bit jako p©°znak konce slova)
;        DS:SI=ukazatel zkomprimovanòch dat
; VùSTUP:CF=bit ze stavovÇho slova
;        ZY=konec dat
;        AX=novÇ stavovÇ slovo
;        DS:SI=novò ukazatel dat
; niá° registr DH
; -----------------------------------------------------------------------------

HlpDkB   PROC      NEAR

; ------ poskytnut° jednoho bitu stavovÇho slova

         shr       ax,1                     ; poskytnut° bitu ze stav. slova
         jnz       HlpDkB3                  ; nen° je®tà konec slova

; ------ naáten° dal®°ho stavovÇho slova

         call      HlpDkByt                 ; naáten° bajtu -> DH
         jz        HlpDkB3                  ; konec dat
         mov       al,dh                    ; AL <- nië®° bajt stavovÇho slova
         call      HlpDkByt                 ; naáten° bajtu -> DH
         mov       ah,dh                    ; vy®®° bajt stavovÇho slova
         stc                                ; p©°znak konce stavovÇho slova
         rcr       ax,1                     ; prvn° bit stavovÇho slova
                                          ;* zde zñst†v† p©°znak ZY=konec dat
HlpDkB3: ret

HlpDkB   ENDP

; -----------------------------------------------------------------------------
;     áten° bajtu ze souboru (ukazatel DS:SI, ZY=konec dat, DH=bajt)
; -----------------------------------------------------------------------------

HlpDkByt PROC      NEAR

         cmp       si,HelpMSiz              ; je konec dat v bufferu ?
         je        HlpDkBt2                 ; je konec bufferu
         mov       dh,ds:[si]               ; naáten° bajtu z bufferu
         inc       si                       ; (nastaven° p©°znaku NZ)
HlpDkBt2:ret

HlpDkByt ENDP

; *****************************************************************************
;                                InitHMnu
;                          inicializace menu n†povàdy
; -----------------------------------------------------------------------------
; VSTUP: SI=adresa menu
;        DS=datovò segment
; *****************************************************************************

InitHMnu PROC      FAR

         call      far ptr CentMenu         ; vyst©edàn° okna menu
         ret

InitHMnu ENDP

; *****************************************************************************
;                                  DispHMnu
;                          zobrazen° menu n†povàdy
; -----------------------------------------------------------------------------
; VSTUP: SI=adresa menu
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) adresa menu
;                   SS:[BP-3] (1) ukazatel ©†dku
;                   SS:[BP-4] (1) poá†teán° pozice menu
;                   SS:[BP-5] (1) á°taá ©†dkñ
;                   SS:[BP-6] (1) ®°©ka okna (pozic)
;                   SS:[BP-8] (2) adresa bufferu (segment)
;                   SS:[BP-10] (2) ukazatel dat v bufferu
;                   SS:[BP-12] (2) á°taá aktivn° volby (kurzor)
;                   SS:[BP-14] (2) hladina k zobrazen° menu
; *****************************************************************************

DispHMnu PROC      FAR

; ------ zobrazen° r†mu menu n†povàdy

         call      far ptr DispRamM

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp
         sub       sp,14

; ------ p©°prava lok†ln°ch promànnòch

         mov       ss:[bp-2],si             ; adresa menu
         mov       ax,word ptr ds:[si+MnuPoz] ; pozice a ©†dek okna
         inc       ah                       ; korekce na druhò ©†dek
         mov       ss:[bp-4],ax             ; ukazatel ©†dku a pozice

         mov       ax,word ptr ds:[si+MnuSir] ; ®°©ka a vò®ka okna
         sub       ah,2                     ; bez ©†dkñ okrajñ
         mov       ss:[bp-6],ax             ; á°taá ©†dkñ a ®°©ka okna
         mov       ah,0                     ; AX = ®°©ka okna
         shl       ax,1                     ; poáet bajtñ na ©†dek
         sub       sp,ax                    ; m°sto pro buffer

         mov       ax,ds:[HelpMSeg]         ; segment menu n†povàdy
         call      far ptr GetDat           ; adresa bufferu -> ES
         mov       ss:[bp-8],es             ; adresa bufferu
         mov       ax,ds:[HelpMTop]         ; zaá†tek dat v bufferu
         mov       ss:[bp-10],ax            ; ukazatel dat v bufferu
         mov       ax,ds:[HlpAPol]          ; aktivn° poloëka 1...
         mov       ss:[bp-12],ax            ; á°taá aktivn° poloëky
         mov       al,ds:[si+MnuLev]        ; hladina k zobrazen° menu
         mov       ah,0
         mov       ss:[bp-14],ax            ; hladina k zobrazen° menu

; ------ vymaz†n° jednoho ©†dku v bufferu

DispHMn1:push      ss
         pop       es                       ; ES <- segment bufferu
         mov       di,sp                    ; DI <- offset bufferu
         mov       al,"≥"                   ; levò okraj
         mov       ah,ds:[ColHlp9]          ; barva - levò okraj
         cld
         stosw                              ; levò okraj
         push      di
         mov       al," "                   ; vnit©n° mezera
         mov       ch,0
         mov       cl,ss:[bp-6]             ; ®°©ka okna
         dec       cx
         dec       cx                       ; bez okrajñ
         mov       ah,ds:[ColHlp1]          ; bàën† barva textu
         rep       stosw                    ; vymaz†n° textu ©†dku
         mov       al,"≥"                   ; pravò okraj
         mov       ah,ds:[ColHlp8]          ; barva pravÇho okraje
         stosw                              ; pravò okraj
         pop       di

; ------ p©°prava k dek¢dov†n° jednoho ©†dku

         inc       di
         inc       di                       ; 2. znak na ©†dku
         mov       ch,0
         mov       cl,ss:[bp-6]             ; ®°©ka okna
         sub       cl,4                     ; vnit©ek okna
         mov       si,ss:[bp-10]            ; ukazatel dat v bufferu
         mov       ah,ds:[ColHlp1]          ; bàën† barva textu

; ------ naáten° jednoho znaku (je CLD !)

         push      ds
         mov       ds,ss:[bp-8]             ; adresa bufferu (segment)
DispHMn2:lodsb                              ; naáten° jednoho znaku

; ------ uloëen° bàënÇho znaku

         cmp       al," "                   ; je bàënò znak ?
         jb        DispHMn3                 ; nen° bàënò znak
         jcxz      DispHMn2                 ; nen° voln† dal®° pozice
         dec       cx                       ; á°taá volnÇho m°sta
         stosw                              ; uloëen° znaku
         jmp       short DispHMn2           ; dal®° znak

; ------ test, zda je konec ©†dku

DispHMn3:cmp       al,HlpChLin              ; je konec ©†dku ?
         je        DispHMn7                 ; je konec ©†dku
         jb        DispHMn5                 ; jsou p©ep°naáe

; ------ dek¢dov†n° mezer

         sub       al,6                     ; poáet mezer
DispHMn4:jcxz      DispHMn2                 ; nen° dal®° voln† pozice
         inc       di
         inc       di                       ; zvò®en° ukl†dac° adresy
         dec       cx                       ; á°taá volnÇho m°sta
         dec       al                       ; sn°ëen° á°taáe mezer
         jnz       DispHMn4                 ; dal®° mezera
         jmp       short DispHMn2           ; dal®° znak

; ------ test, zda je p©ep°naá odkazu

DispHMn5:pop       ds                       ; n†vrat DS

         cmp       al,HlpChSym              ; je to symbol ?
         jne       DispHMn6                 ; nen° to symbol
         inc       si
         inc       si                       ; p©eskoáen° á°sla str†nky odkazu
         mov       ah,ds:[ColHlp6]          ; barva odkazu bez kurzoru
         dec       word ptr ss:[bp-12]      ; á°taá kurzoru
         jnz       DispHM68                 ; nen° kurzor
         mov       ah,ds:[ColHlp7]          ; barva kurzoru
         jmp       short DispHM68           ; dal®° znak

; ------ p©ep°naá barvy

DispHMn6:mov       ah,ds:[ColHlp1]          ; bàën† barva
         cmp       al,HlpChNul              ; je bàën† barva ?
         je        DispHM68                 ; je bàën† barva

         mov       ah,ds:[ColHlp2]          ; zvòraznàn† barva
         cmp       al,HlpChBld              ; je zvòraznàn† barva ?
         je        DispHM68                 ; je zvòraznàn† barva

         mov       ah,ds:[ColHlp3]          ; barva kl†vesy
         cmp       al,HlpChHey              ; je kl†vesa ?
         je        DispHM68                 ; je kl†vesa

         mov       ah,ds:[ColHlp4]          ; barva menu
         cmp       al,HlpChMnu              ; je menu ?
         je        DispHM68                 ; je menu

         mov       ah,ds:[ColHlp5]          ; barva menu zvòraznàn†
         cmp       al,HlpChHot              ; je menu zvòraznànÇ ?
         je        DispHM68                 ; je menu zvòraznànÇ

         mov       ah,ds:[ColHlpB]          ; jinak barva st°nu

DispHM68:push      ds                       ; £schova DS
         mov       ds,ss:[bp-8]             ; adresa bufferu (segment)
         jmp       short DispHMn2

; ------ konec dek¢dov†n° textu

DispHMn7:pop       ds
         mov       ss:[bp-10],si            ; novò ukazatel textu

; ------ zobrazen° ©†dku (ES=segment z†sobn°ku)

DispHMn8:mov       si,sp                    ; SI <- adresa bufferu
         mov       ax,ss:[bp-14]            ; hladina k zobrazen°
         mov       cl,ss:[bp-6]             ; ®°©ka okna
         mov       dx,ss:[bp-4]             ; ©†dek a pozice okna
         call      far ptr DispMStr         ; zobrazen° ©†dku okna

; ------ posun ukazatelñ na dal®° ©†dek

         inc       byte ptr ss:[bp-3]       ; zvò®en° ukazatele ©†dku
         dec       byte ptr ss:[bp-5]       ; posun á°taáe ©†dkñ
         jz        DispHMn9                 ; jsou jië v®echny ©†dky
         jmp       DispHMn1                 ; dal®° ©†dek

; ------ n†vrat registrñ

DispHMn9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispHMnu ENDP

CodeHlp  ENDS

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;
;                                 Data
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
Data     SEGMENT

;HelpPar  db        bit0                     ; parametry napovàdy
;                                            ;   bit 0: 1=zapnuta mal† n†povàda
;                                            ;   bit 1: 1=zobraz° se 12 Fn kl†ves
;                                            ;   bit 2: 1=n†povàda k menu nen°
;                                            ;   bit 3: 1=FN kl†vesy jako menu
;                                            ;   bit 4: 1=otev©eno menu n†povàdy
;                                            ;   bit 5: 1=odkazy p©i exportu
;                                            ;   bit 6: 1=prob°h† export n†povàdy

HelpHisU dw        HelpHis                  ; ukazatel v historii str†nek HELP
HelpHis  dw        2*HelpHMax dup(-1)       ; historie str†nek HELP

HlpAStrn dw        0                        ; naposledy zvolen† str†nka

HelpSeg  dw        SEG HelpS                ; segment n†povàdy

HelpFSeg dw        0                        ; segm. n†povàdy k funkán°m kl†ves†m

;HelpColN db        7                        ; barva á°sla kl†vesy
;HelpColM db        70h                      ; barva menu kl†ves
;HelpColT db        30h                      ; barva textu n†povàdy kl†vesy
;HelpColK db        4eh                      ; barva kurzoru funkán°ch kl†ves
;
;HelpColH db        30h                      ; barva textu n†povàdy k volb†m
;HelpClH2 db        34h                      ; vysv°cen† barva n†povàdy

;ColHlp1  db        2fh                      ; bàën† barva
;ColHlp2  db        2eh                      ; zvòraznàn†
;ColHlp3  db        29h                      ; kl†vesa
;ColHlp4  db        70h                      ; volba menu
;ColHlp5  db        74h                      ; volba menu zvòraznàn†
;ColHlp6  db        2ch                      ; odkaz
;ColHlp7  db        0ch                      ; odkaz s kurzorem
;ColHlp8  db        2ch                      ; r†m - svàtlo
;ColHlp9  db        24h                      ; r†m - st°n
;ColHlpA  db        2eh                      ; r†m - titulek
;ColHlpB  db        07h                      ; barva st°nu

; ------ obsluha menu velkÇ n†povàdy

HelpFile db        10,'DOSMAN.HLP'          ; jmÇno souboru n†povàdy
HelpIdnt dw        0                        ; identifik†tor souboru n†povàdy (0=nen°)
HelpISeg dw        0                        ; segment indexñ n†povàdy
HelpMSeg dw        0                        ; segment menu velkÇ n†povàdy (0=nen°)
HelpMTop dw        0                        ; adresa zaá†tku dat v bufferu
HlpAPol  dw        1                        ; á°slo aktivn° volby 1..
HelpMEnd dw        0                        ; konec dat v bufferu
HelpOKur dw        0                        ; uschovanò pñvodn° kurzor

; ------ identifikaán° z†hlav° souboru n†povàdy (pro kontrolu) - 10 bajtñ

HelpIden db        'DMHLP'                  ; identifikaán° text
         db        DMVerze1+"0",DMVerze2+"0",DMVerze3+"0" ; á°slo verze

HelpStrn dw        0                        ; poáet str†nek n†povàdy celkem

; ------ jmÇno souboru k exportu n†povàdy

HelpExpF db        'DOSMAN.HL$'
HelpEx0F db        0

HelpExpI dw        0                        ; identifik†tor souboru

HlasExp  db        21,'Exportuji n†povàdu...'

HelpHled db        15,'Prohled†v†m....'

; -----------------------------------------------------------------------------
;        chybovÇ hl†®en° - soubor n†povàdy nenalezen
; -----------------------------------------------------------------------------

HelpChyb label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        HelpChbP                 ; zaá†tek definice poloëek menu
         dw        ChbLnMeH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@PodmenuNapoveda      ; á°slo str†nky velkÇ n†povàdy
         dw        HelpChbB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        HelpChbT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        50                       ; ®°©ka okna
         db        9                        ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; historie
         db        0                        ; poáet p©edvoleb

HelpChbP db        bit6,6,0,'CHYBA'
         db        bit6,26,'Soubor n†povàdy nenalezen:'
         db        bit6,7,0,3
HelpChP2 db        0                        ; dÇlka jmÇna souboru
HelpChP3 dd        0                        ; adresa jmÇna souboru
         db        bit6+bit7,0
         db        1,6,'N†vrat'

HelpChbB db        0                        ; blokovac° tabulka

HelpChbT db        19,'n†povàda nenalezena'

; -----------------------------------------------------------------------------
;        chybovÇ hl†®en° - chyba áten° souboru n†povàdy nebo je neplatnò
; -----------------------------------------------------------------------------

HelpRErr label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        HelpRErP                 ; zaá†tek definice poloëek menu
         dw        ChbLnMeH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@PodmenuNapoveda      ; á°slo str†nky velkÇ n†povàdy
         dw        HelpRErB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        HelpRErT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        50                       ; ®°©ka okna
         db        9                        ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; historie
         db        0                        ; poáet p©edvoleb

HelpRErP db        bit6,6,0,'CHYBA'
         db        bit6,33,'Nespr†vn† verze souboru n†povàdy:'
         db        bit6,7,0,3
HelpREr2 db        0                        ; dÇlka jmÇna souboru
HelpREr3 dd        0                        ; adresa jmÇna souboru
         db        bit6+bit7,0
         db        1,6,'N†vrat'

HelpRErB db        0                        ; blokovac° tabulka

HelpRErT db        18,'nespr†vn† n†povàda'

; -----------------------------------------------------------------------------
;        menu n†povàdy
; -----------------------------------------------------------------------------

HelpMenu label     byte
         db        20                       ; typ menu - n†povàda

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka volby
         dw        1                        ; poáet platnòch poloëek menu
         dw        1                        ; celkovò poáet poloëek menu

         dw        HlpMnPol                 ; definián° tabulka poloëek
         dw        HlpMnHlp                 ; n†povàda
         dw        Hlp@PodmenuNapoveda      ; á°slo str†nky velkÇ n†povàdy
         dw        0                        ; blokovac° tabulka
         dw        0                        ; p©ep°naáe
         dw        HlpMnTit                 ; adresa titulu okna
         dw        0                        ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        0                        ; poá†teán° pozice
         db        0                        ; poá†teán° ©†dek
         db        80                       ; ®°©ka okna
         db        24                       ; vò®ka okna

HlpMnPol db        bit6,0

HlpMnTit db        0,50 dup(" ")            ; titulek okna

HelpS    SEGMENT   BYTE PUBLIC
HlpMnHlp db        88,'Tab, Enter=odkaz  BS=zpàt  PgUp/PgDown=listov†n°  F7=hled†n°  Ctrl-L=d†le'
HelpS    ENDS

; ------ menu pro malou n†povàdu

HelpF40T label     byte
         db        5
         dw        0f09h                    ; Tab
         db        12
         dw        1c0dh                    ; Enter
         db        9
         dw        0e08h                    ; BS
         db        6
         dw        4900h                    ; Page Up
         db        17
         dw        5100h                    ; Page Down
         db        12
         dw        4100h                    ; F7
         db        -1
         dw        260ch                    ; Ctrl-L

; -----------------------------------------------------------------------------
;        menu volby funkán°ch kl†ves
; -----------------------------------------------------------------------------

GMnuAkt  dw        1                        ; aktivn° kl†vesa 1...84
;GMnuSwc  db        0                        ; aktivn° p©ep°naá funkán°ch kl†ves
GMnuFn   db        0                        ; aktivn° funkán° kl†vesa 0...
                                            ;   -1 = nen° aktivn° kl†vesa

GMnuVert label     byte

         db        17                       ; typ menu - funkán° kl†vesy

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet platnòch poloëek menu
         dw        1                        ; celkovò poáet poloëek menu

         dw        0                        ; adresa definice poloëek menu
         dw        GMnuVHlp                 ; adresa n†povàd
         dw        Hlp@Main                 ; á°slo str†nky velkÇ n†povàdy
         dw        0                        ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        0                        ; adresa titulu okna
         dw        0                        ; tabulka obsluh voleb menu
         dw        0                        ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        0                        ; poá†teán° pozice
         db        17                       ; poá†teán° ©†dek
         db        80                       ; ®°©ka
         db        7                        ; vò®ka

HelpS    SEGMENT   BYTE PUBLIC
GMnuVHlp db        3,1
         dw        GMnuVHl1
HelpS    ENDS

GMnuVHl1 db        80,'',78 dup(" ")      ; buffer n†povàdy k funkán° kl†vese
GMnuVHl2 label     byte

GMnuVHlT db        0
         db        6,'Shift-'
         db        5,'Ctrl-'
         db        4,'Alt-'
         db        11,'Shift-Ctrl-'
         db        10,'Shift-Alt-'
         db        9,'Ctrl-Alt-'

; ------ tabulka k¢dñ funkán°ch kl†ves

GMnuKeyT dw        3b00h,3c00h,3d00h,3e00h,3f00h,4000h ; F1 aë F12
         dw        4100h,4200h,4300h,4400h,8500h,8600h

         dw        5400h,5500h,5600h,5700h,5800h,5900h ; Shift-F1 aë Shift-F12
         dw        5a00h,5b00h,5c00h,5d00h,8700h,8800h

         dw        5e00h,5f00h,6000h,6100h,6200h,6300h ; Ctrl-F1 aë Ctrl-F12
         dw        6400h,6500h,6600h,6700h,8900h,8a00h

         dw        6800h,6900h,6a00h,6b00h,6c00h,6d00h ; Alt-F1 aë Alt-F12
         dw        6e00h,6f00h,7000h,7100h,8b00h,8c00h

         dw        5e04h,5f04h,6004h,6104h,6204h,6304h ; Shift-Ctrl-F1 aë F12
         dw        6404h,6504h,6604h,6704h,8904h,8a04h

         dw        6805h,6905h,6a05h,6b05h,6c05h,6d05h ; Shift-Alt-F1 aë F12
         dw        6e05h,6f05h,7005h,7105h,8b05h,8c05h

         dw        6806h,6906h,6a06h,6b06h,6c06h,6d06h ; Ctrl-Alt-F1 aë F12
         dw        6e06h,6f06h,7006h,7106h,8b06h,8c06h

; -----------------------------------------------------------------------------
;        Definice vertik†ln°ho menu - n†povàda
; -----------------------------------------------------------------------------

NMnuVert label     byte                   ;* menu n†povàdy

         db        1                        ; typ menu - vertik†ln° menu hlavn°

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        6                        ; poáet platnòch poloëek menu
         dw        7                        ; celkovò poáet poloëek menu

         dw        NMnuVPol                 ; adresa definice poloëek menu
         dw        NMnuVHlp                 ; adresa n†povàd
         dw        Hlp@PodmenuNapoveda      ; á°slo str†nky velkÇ n†povàdy
         dw        NMnuVBlk                 ; adresa blokovac° tabulky
         dw        NMnuVSwc                 ; adresa tabulky p©ep°naáñ
         dw        NMnuVTit                 ; adresa titulu okna
         dw        NMnuVExe                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        46                       ; poá†teán° pozice
         db        1                        ; poá†teán° ©†dek
         db        20                       ; ®°©ka
         db        9                        ; vò®ka

NMnuVPol db        1,6,'Hlavn°'
         db        1,9,'TÇmatick†'
         db        1,8,'Abecedn°'
         db        1,8,'Posledn°'
         db        bit6+bit7,0
         db        1,6,'Export'
         db        1+bit7,6,'Odkazy'

NMnuVBlk db        0,0,0,0,0,0

NMnuVSwc db        0

NMnuVTit db        8,'n†povàda'

HelpS    SEGMENT   BYTE PUBLIC
NMnuVHlp db        52,'Hlavn° str†nka n†povàdy (jako F1 v z†kladn°m oknà)'
         db        42,'N†povàda rozálenàn† do tÇmatickòch oblast°'
         db        27,'Abecednà set©°dàn† n†povàda'
         db        67,'OpakovanÇ vyvol†n° poslednà zobrazenÇ n†povàdy (kl†vesa Shift-F1)'
         db        81,'Export n†povàdy do souboru DOSMAN.HL$ v aktu†ln°m adres†©i (str†nka=23 ©†dkñ)'
         db        66,'P©i exportu n†povàdy budou tÇë uv†dàny odkazy ve formà {str†nka}'
HelpS    ENDS

NMnuVExe label     dword                    ; tabulka obsluh menu
         dd        HelpMH                   ; Hlavn°
         dd        HelpMT                   ; TÇmatick†
         dd        HelpMA                   ; Abecedn°
         dd        HelpMP                   ; Posledn°
         dd        HelpME                   ; Export
         dd        HelpMO                   ; Odkazy

; -----------------------------------------------------------------------------
;        N†povàda k funkán°m kl†ves†m - adres†©ovÇ okno
; -----------------------------------------------------------------------------

HelpKeyA label     byte

; ------ bez p©esmykaáñ

         db        'Pomoc  '                ; F1
         db        'Uë.menu'                ; F2
         db        'Zobraz '                ; F3
         db        'Edituj '                ; F4
         db        'Kop°ruj'                ; F5
         db        'P©esu§ '                ; F6
         db        'Adres†©'                ; F7
         db        'Zru®   '                ; F8
         db        'Atribut'                ; F9
         db        'Menu   '                ; F10
         db        'F11    '                ; F11
         db        'F12    '                ; F12

; ------ Shift-

         db        '*Pomoc '                ; Shift-F1
         db        'P©°kazy'                ; Shift-F2
         db        '*Zobraz'                ; Shift-F3
         db        '*Edituj'                ; Shift-F4
         db        '*Kop°r.'                ; Shift-F5
         db        '*P©esu§'                ; Shift-F6
         db        'Obnov  '                ; Shift-F7
         db        '*Zru®  '                ; Shift-F8
         db        'T©iÉ   '                ; Shift-F9
         db        'EGA/VGA'                ; Shift-F10
         db        '       '                ; Shift-F11
         db        '       '                ; Shift-F12

; ------ Ctrl-

         db        'LevÇ   '                ; Ctrl-F1
         db        'PravÇ  '                ; Ctrl-F2
         db        'ZobrDsk'                ; Ctrl-F3
         db        'EditHex'                ; Ctrl-F4
         db        'KopDisk'                ; Ctrl-F5
         db        'JmenDsk'                ; Ctrl-F6
         db        '       '                ; Ctrl-F7
;         db        'Funkce '                ; Ctrl-F7
         db        'FormDsk'                ; Ctrl-F8
         db        'Srovnej'                ; Ctrl-F9
         db        'Konec  '                ; Ctrl-F10
         db        '       '                ; Ctrl-F11
         db        '       '                ; Ctrl-F12

; ------ Alt-

         db        'LevÇ   '                ; Alt-F1
         db        'PravÇ  '                ; Alt-F2
         db        'Zobraz!'                ; Alt-F3
         db        'Edituj!'                ; Alt-F4
         db        '1Kop°r.'                ; Alt-F5
         db        '1P©esu§'                ; Alt-F6
         db        'Hledej '                ; Alt-F7
         db        '1Zru®  '                ; Alt-F8
         db        'SrovAdr'                ; Alt-F9
         db        'Strom  '                ; Alt-F10
         db        '       '                ; Alt-F11
         db        '       '                ; Alt-F12

; ------ Shift-Ctrl-

         db        '       '                ; Shift-Ctrl-F1
         db        '       '                ; Shift-Ctrl-F2
         db        '       '                ; Shift-Ctrl-F3
         db        '       '                ; Shift-Ctrl-F4
         db        '       '                ; Shift-Ctrl-F5
         db        '       '                ; Shift-Ctrl-F6
         db        '       '                ; Shift-Ctrl-F7
         db        '       '                ; Shift-Ctrl-F8
         db        '       '                ; Shift-Ctrl-F9
         db        '       '                ; Shift-Ctrl-F10
         db        '       '                ; Shift-Ctrl-F11
         db        '       '                ; Shift-Ctrl-F12

; ------ Shift-Alt-

         db        '       '                ; Shift-Alt-F1
         db        '       '                ; Shift-Alt-F2
         db        '       '                ; Shift-Alt-F3
         db        '       '                ; Shift-Alt-F4
         db        '       '                ; Shift-Alt-F5
         db        '       '                ; Shift-Alt-F6
         db        '       '                ; Shift-Alt-F7
         db        '       '                ; Shift-Alt-F8
         db        '       '                ; Shift-Alt-F9
         db        '       '                ; Shift-Alt-F10
         db        '       '                ; Shift-Alt-F11
         db        '       '                ; Shift-Alt-F12

; ------ Ctrl-Alt-

         db        '       '                ; Ctrl-Alt-F1
         db        '       '                ; Ctrl-Alt-F2
         db        '       '                ; Ctrl-Alt-F3
         db        '       '                ; Ctrl-Alt-F4
         db        '       '                ; Ctrl-Alt-F5
         db        '       '                ; Ctrl-Alt-F6
         db        '       '                ; Ctrl-Alt-F7
         db        '       '                ; Ctrl-Alt-F8
         db        '       '                ; Ctrl-Alt-F9
         db        '       '                ; Ctrl-Alt-F10
         db        '       '                ; Ctrl-Alt-F11
         db        '       '                ; Ctrl-Alt-F12

; -----------------------------------------------------------------------------
;        N†povàda k funkán°m kl†ves†m - editor
; -----------------------------------------------------------------------------

HelpKeyE label     byte

; ------ bez p©esmykaáñ

         db        'Pomoc  '                ; F1
         db        'Uloë   '                ; F2
         db        'Zaá†tek'                ; F3
         db        'Konec  '                ; F4
         db        'Kop°ruj'                ; F5
         db        'P©esu§ '                ; F6
         db        'Hledej '                ; F7
         db        'Zru®   '                ; F8
HelpKZob db        '-Zobraz'                ; F9
         db        'Menu   '                ; F10
         db        '       '                ; F11
         db        '       '                ; F12

; ------ Shift-                             

         db        '*Pomoc '                ; Shift-F1
         db        'Uloë...'                ; Shift-F2
         db        'Uloë b.'                ; Shift-F3
         db        'Äti... '                ; Shift-F4
         db        'Äti b. '                ; Shift-F5
         db        'Uzav©i '                ; Shift-F6
         db        'NahraÉ '                ; Shift-F7
         db        '       '                ; Shift-F8
;         db        'Obnov  '                ; Shift-F8
HelpKTyp db        '-TypBlk'                ; Shift-F9
         db        'EgaVga '                ; Shift-F10
         db        '       '                ; Shift-F11
         db        '       '                ; Shift-F12

; ------ Ctrl-

HelpKEdi db        '-Edit  '                ; Ctrl-F1
HelpKBin db        '-Binar '                ; Ctrl-F2
HelpKHex db        '-Hexa  '                ; Ctrl-F3
         db        '       '                ; Ctrl-F4
HelpKTab db        '-Tabul '                ; Ctrl-F5
HelpKOpt db        '-Optim '                ; Ctrl-F6
         db        '       '                ; Ctrl-F7
;         db        'Funkce '                ; Ctrl-F7
         db        'ModiBlk'                ; Ctrl-F8
         db        'Nahoru '                ; Ctrl-F9
         db        'Dolñ   '                ; Ctrl-F10
         db        '       '                ; Ctrl-F11
         db        '       '                ; Ctrl-F12

; ------ Alt-

         db        'Okno '
HelpKOkn db        '1 '                     ; Alt-F1
         db        17,'P©edch'              ; Alt-F2
         db        16,'Dal®° '              ; Alt-F3
         db        'Oken '
HelpKNum db        '1 '                     ; Alt-F4
         db        'SystObr'                ; Alt-F5
HelpKVer db        '-Vertik'                ; Alt-F6
HelpKSyn db        '-Synchr'                ; Alt-F7
         db        'Znaáka '                ; Alt-F8
         db        17,'P©edZn'              ; Alt-F9
         db        16,'DalZn '              ; Alt-F10
         db        '       '                ; Alt-F11
         db        '       '                ; Alt-F12

; ------ Shift-Ctrl-

         db        '       '                ; Shift-Ctrl-F1
         db        '       '                ; Shift-Ctrl-F2
         db        '       '                ; Shift-Ctrl-F3
         db        '       '                ; Shift-Ctrl-F4
         db        '       '                ; Shift-Ctrl-F5
         db        '       '                ; Shift-Ctrl-F6
         db        '       '                ; Shift-Ctrl-F7
         db        '       '                ; Shift-Ctrl-F8
         db        '       '                ; Shift-Ctrl-F9
         db        '       '                ; Shift-Ctrl-F10
         db        '       '                ; Shift-Ctrl-F11
         db        '       '                ; Shift-Ctrl-F12

; ------ Shift-Alt-

         db        '       '                ; Shift-Alt-F1
         db        '       '                ; Shift-Alt-F2
         db        '       '                ; Shift-Alt-F3
         db        '       '                ; Shift-Alt-F4
         db        '       '                ; Shift-Alt-F5
         db        '       '                ; Shift-Alt-F6
         db        '       '                ; Shift-Alt-F7
         db        '       '                ; Shift-Alt-F8
         db        '       '                ; Shift-Alt-F9
         db        '       '                ; Shift-Alt-F10
         db        '       '                ; Shift-Alt-F11
         db        '       '                ; Shift-Alt-F12

; ------ Ctrl-Alt-

         db        '       '                ; Ctrl-Alt-F1
         db        '       '                ; Ctrl-Alt-F2
         db        '       '                ; Ctrl-Alt-F3
         db        '       '                ; Ctrl-Alt-F4
         db        '       '                ; Ctrl-Alt-F5
         db        '       '                ; Ctrl-Alt-F6
         db        '       '                ; Ctrl-Alt-F7
         db        '       '                ; Ctrl-Alt-F8
         db        '       '                ; Ctrl-Alt-F9
         db        '       '                ; Ctrl-Alt-F10
         db        '       '                ; Ctrl-Alt-F11
         db        '       '                ; Ctrl-Alt-F12

Data     ENDS

         END

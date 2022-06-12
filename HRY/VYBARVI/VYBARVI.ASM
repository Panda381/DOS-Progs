
BuffSize EQU       1000h                    ; velikost bufferu

MaxSirX  EQU       1000h                    ; maxim ln¡ d‚lka linky obr zku
MaxVysY  EQU       1000h                    ; maxim ln¡ v˜¨ka obr zku

SirkaSCR EQU       320                      ; ¨¡©ka displeje
VyskaSCR EQU       200                      ; v˜¨ka displeje

TopCol   EQU       32                       ; ‡¡slo po‡ te‡n¡ barvy
NumCols  EQU       41                       ; po‡et barev
XC       EQU       33                       ; n hradn¡ barva obr zku pastelky

SirBar   EQU       6                        ; ¨¡©ka jedn‚ barvy
VysBar   EQU       20                       ; v˜¨ka jedn‚ barvy

SirSipky EQU       21                       ; ¨¡©ka jedn‚ ¨ipky
VysSipky EQU       11                       ; v˜¨ka jedn‚ ¨ipky

CERNA    EQU       32                       ; ‡ern  barva pro obrysy
BILA     EQU       37                       ; b¡l  barva

MaxSoub  EQU       500                      ; maxim ln¡ po‡et soubor–

SIRKA    EQU       SirkaSCR                 ; ¨¡©ka obr zku
VYSKA    EQU       VyskaSCR-VysBar          ; v˜¨ka obr zku

SirMouse EQU       16                       ; ¨¡©ka kurzoru my¨i
VysMouse EQU       16                       ; v˜¨ka kurzoru my¨i
MaxXMous EQU       SirkaSCR-1               ; maxim ln¡ sou©adnice my¨i X
MaxYMous EQU       VyskaSCR-1               ; maxim ln¡ sou©adnice my¨i Y

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ zobrazen¡ £vodn¡ho textu

Start:   mov       dx,offset UvTxt          ; £vodn¡ text
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu

; ------ ‡ek n¡ na stisk kl vesy

         mov       ah,8
         int       21h                      ; ‡ek n¡ na stisk kl vesy
         cmp       al,0                     ; bude druh˜ bajt ?
         jne       Start02
         mov       ah,8
         int       21h                      ; na‡ten¡ druh‚ho bajtu kl vesy
         jmp       short Start03            ; to nen¡ kl vesa ESC

Start02: cmp       al,27                    ; je ESC ?
         je        Chyba2                   ; je p©eru¨en¡ programu

; ------ kontrola konce pamˆti

Start03: cmp       sp,offset Konec          ; je pamˆŸ OK ?
         jae       Start1                   ; pamˆŸ je OK

         mov       dx,offset MemTxt         ; text - chyba pamˆti
Chyba:   mov       ah,9
         int       21h                      ; chybov‚ hl ¨en¡
Chyba2:  int       20h

; ------ instalace karty VGA

Start1:  call      InitVGA                  ; inicializace karty VGA
         mov       dx,offset CardTxt        ; text - nen¡ VGA
         jc        Chyba                    ; chyba - nen¡ VGA
         call      InitMous                 ; instalace my¨i
         call      MouseOff
         call      DispCols                 ; zobrazen¡ barev
         call      MouseOn

; ------ na‡ten¡ seznamu soubor–

         call      InitSezn                 ; na‡ten¡ seznamu soubor–

; ------ otev©en¡ a zobrazen¡ aktivn¡ho souboru

Start3:  call      MouseOff
         and       byte ptr ds:[Param],not 10h+80h ; nen¡ modifikace ani korekce
         call      DispName                 ; zobrazen¡ jm‚na souboru
         call      OpenFile                 ; otev©en¡ aktivn¡ho souboru
         cmp       word ptr ds:[SoubIdnt],0 ; je soubor otev©en ?
         jz        Start4                   ; soubor nen¡ otev©en
         call      InitPal                  ; p©¡prava konverzn¡ tabulky
         call      Zobraz                   ; zobrazen¡ aktivn¡ho souboru
         mov       bx,ds:[SoubIdnt]         ; identifik tor souboru
         mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru
Start4:  call      MouseOn

; ------ ‡ek n¡ na stisk kl vesy

Start5:  call      MouseInt                 ; obsluha p©eru¨en¡ od my¨i
         jc        Start6                   ; je stisk tla‡¡tka my¨i
         mov       ah,1
         int       16h
         jz        Start5

         mov       ah,0
         int       16h                      ; vstup znaku z kl vesnice

; ------ ukon‡en¡ programu ESC

         or        ax,ax
         jz        Start52
         cmp       al,27
         jne       Start7
         call      Uloz                     ; ulo‘en¡ souboru
Start52: mov       ax,3
         int       10h
         int       20h

; ------ obsluha stisku tla‡¡tka my¨i

Start6:  mov       ax,ds:[MouseY]           ; sou©adnice my¨i Y
         cmp       ax,VYSKA                 ; je li¨ta menu ?
         jb        Start64                  ; nen¡ li¨ta menu

; ------ volba barvy

         mov       ax,ds:[MouseX]           ; pozice my¨i X
         cmp       ax,SirBar*(NumCols-1)    ; je volba barvy ?
         jae       Start62                  ; nen¡ volba barvy
         mov       cl,SirBar                ; ¨¡©ka jedn‚ barvy
         div       cl                       ; v˜po‡et ‡¡sla barvy
         add       al,TopCol+1              ; ‡¡slo zvolen‚ barvy
         call      MouseOff                 ; vypnut¡ kurzoru my¨i
         mov       ds:[AktCol],al           ; nov  aktivn¡ barva
         call      MouseOn                  ; nov‚ zapnut¡ kurzoru my¨i
         jmp       short Start5             ; dal¨¡ obsluha

; ------ posun k p©ede¨l‚mu obr zku

Start62: cmp       ax,(SirkaSCR-(SirBar*(NumCols-1)))/2 + SirBar*(NumCols-1)
         jb        Start71                  ; je p©edchoz¡ soubor
         jmp       short Start75            ; jinak dal¨¡ soubor

Start64: call      MouseOff                 ; vypnut¡ kurzoru my¨i
         call      Vybarvi                  ; vybarven¡ plochy
         call      MouseOn                  ; zapnut¡ kurzoru my¨i
         jmp       short Start5

; ------ Ctrl-F1 n vrat zmˆn v souboru

Start7:  cmp       ax,5E00h                 ; Ctrl-F1
         je        Start723                 ; nov‚ na‡ten¡ obr zku

; ------ p©edchoz¡ soubor

         cmp       ax,4b00h                 ; vlevo
         je        Start71
         cmp       ax,7300h                 ; Ctrl-vlevo
         je        Start71
         cmp       ax,0f00h                 ; Shift-TAB
         jne       Start74
Start71: dec       word ptr ds:[AktSoub]    ; sn¡‘en¡ ‡¡sla souboru
         jns       Start72                  ; nen¡ je¨tˆ podte‡en¡
         mov       ax,ds:[NumSoub]          ; po‡et soubor–
         dec       ax                       ; ‡¡slo posledn¡ho souboru
         mov       ds:[AktSoub],ax          ; posun na konec
Start72: call      Uloz                     ; ulo‘en¡ souboru
Start722:mov       ah,1
         int       16h
         jz        Start723
         mov       ah,0
         int       16h
         jmp       short Start722
Start723:jmp       Start3                   ; zobrazen¡ dal¨¡ho souboru

; ------ dal¨¡ soubor

Start74: cmp       ax,4d00h                 ; vpravo
         je        Start75
         cmp       ax,7400h                 ; Ctrl-vpravo
         je        Start75
         cmp       ax,0f09h                 ; TAB
         jne       Start76
Start75: inc       word ptr ds:[AktSoub]    ; zv˜¨en¡ ‡¡sla souboru
         mov       ax,ds:[AktSoub]          ; aktivn¡ soubor
         cmp       ax,ds:[NumSoub]          ; je to je¨tˆ platn˜ soubor ?
         jb        Start72                  ; je to je¨tˆ platn˜ soubor
         mov       word ptr ds:[AktSoub],0  ; posun na po‡ tek
         jmp       short Start72

; ------ Ctrl-F9 odbarven¡ obr zku

Start76: cmp       ax,6600h                 ; Ctrl-F9
         jne       Start77
         call      MouseOff
         call      Odbarvi                  ; odbarven¡ obr zku
         call      MouseOn
         jmp       Start5

; ------ Ctrl-F5 m¢d opravy obrys–

Start77: cmp       ax,6200h                 ; Ctrl-F5
         jne       Start78
         call      MouseOff
         xor       byte ptr ds:[Param],10h  ; zmˆna p©¡znaku opravy obrys–
         call      MouseOn
         jmp       Start5

Start78: jmp       Start5                   ; ‡ek n¡ na dal¨¡ kl vesu

; *****************************************************************************
;
;                             Obsluha displeje
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        inicializace videom¢du (CY=nen¡ VGA)
; -----------------------------------------------------------------------------

InitVGA  PROC      NEAR

; ------ test, zda je karta VGA

         mov       ax,1a00h
         call      Int10                    ; test karty VGA
         cmp       al,1ah                   ; je karta VGA ?
         jne       InitVGA1                 ; chyba - nen¡ VGA

; ------ nastaven¡ videom¢du

         mov       ax,13h
         call      Int10                    ; nastaven videom¢du
         mov       ah,0fh
         call      Int10                    ; poskytnut¡ videom¢du
         cmp       al,13h                   ; byl videom¢d nastaven ?
InitVGA1:stc
         jne       InitVGA9                 ; chyba - nen¡ VGA

; ------ nastaven¡ palet displeje

         xor       bx,bx
         mov       cx,256
         push      ds
         pop       es
         mov       dx,offset TabPal         ; tabulka vlastn¡ch palet
         mov       ax,1012h
         call      Int10                    ; inicializace palet

; ------ konverze na palety pro PCX

         mov       si,offset TabPal
         mov       cx,256*3
InitVGA6:shl       byte ptr ds:[si],1
         shl       byte ptr ds:[si],1
         inc       si
         loop      InitVGA6

; ------ vymaz n¡ obr zku

         mov       ax,0a000h
         mov       es,ax                    ; adresa videopamˆti
         xor       di,di
         mov       ax,BILA*256 + BILA       ; b¡l  barva
         cld
         mov       cx,SIRKA*VYSKA/2
         rep       stosw                    ; vymaz n¡ videopamˆti

         clc                                ; p©¡znak operace OK
InitVGA9:ret

InitVGA  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ li¨ty barev a ¨ipek
; -----------------------------------------------------------------------------

DispCols PROC      NEAR

; ------ p©¡prava adresy videopamˆti

         mov       ax,0a000h
         mov       es,ax
         mov       di,VYSKA*SirkaSCR
         cld

; ------ p©¡prava registr– k zobrazen¡ barev

         mov       ah,TOPCOL+1
         mov       ch,0
         mov       dx,VysBar
         mov       si,offset ObrBar

; ------ zobrazen¡ barev

DispCol1:mov       bx,NumCols-1
         push      ax

DispCol2:push      si
         mov       cl,SirBar
DispCol3:lodsb
         cmp       al,XC
         jne       DispCol4
         mov       al,ah
DispCol4:stosb
         loop      DispCol3
         inc       ah
         pop       si
         dec       bx
         jnz       DispCol2

         pop       ax

         add       si,SirBar
         add       di,SirkaSCR - (NumCols-1)*SirBar
         dec       dx
         jnz       DispCol1

; ------ zobrazen¡ ¨ipek

         mov       si,offset ObrSipek       ; obr zek ¨ipek
         mov       di,VYSKA*SirkaSCR + NumCols*SirBar + 2
         mov       bx,(VYSKA+1)*SirkaSCR - 10

         mov       dx,VysSipky              ; v˜¨ka ¨ipky
DispCol5:mov       cx,SirSipky              ; ¨¡©ka ¨ipky
DispCol6:lodsb                              ; na‡ten¡ bajtu k zobrazen¡
         stosb                              ; lev  ¨ipka
         mov       es:[bx],al               ; prav  ¨ipka
         dec       bx                       ; ‡¡ta‡ ¨¡©ky ¨ipky
         loop      DispCol6
         add       di,SirkaSCR-SirSipky     ; adresa dal¨¡ videolinky
         add       bx,SirkaSCR+SirSipky
         dec       dx
         jnz       DispCol5
         ret

DispCols ENDP

; -----------------------------------------------------------------------------
;        odbarven¡ obr zku
; -----------------------------------------------------------------------------

Odbarvi  PROC      NEAR

         cld
         or        byte ptr ds:[Param],80h  ; p©¡znak modifikace souboru
         mov       ax,0a000h
         mov       es,ax
         xor       di,di
         mov       cx,VYSKA*SIRKA
         mov       ax,CERNA + BILA*256
Odbarvi2:scasb
         je        Odbarvi3
         mov       es:[di-1],ah
Odbarvi3:loop      Odbarvi2
         ret

Odbarvi  ENDP

; -----------------------------------------------------------------------------
;        vybarven¡ plochy obr zku
; -----------------------------------------------------------------------------
;þ
Vybarvi  PROC      NEAR

         or        byte ptr ds:[Param],80h  ; p©¡znak modifikace souboru

; ------ p©¡prava registr–

         mov       si,ds:[MouseX]           ; pozice my¨i X
         mov       bp,ds:[MouseY]           ; pozice my¨i Y
         mov       ax,SirkaSCR              ; ¨¡©ka displeje
         mul       bp                       ; p©epo‡et linky na offset
         add       ax,si                    ; p©i‡ten¡ pozice X
         xchg      ax,di                    ; DI <- adresa ve videopamˆti
         mov       dl,ds:[AktCol]           ; aktivn¡ barva


; ------ p©¡prava segmentov˜ch registr–

         test      byte ptr ds:[Param],10h  ; je m¢d opravy obrys– ?

         push      ds
         mov       ax,0a000h                ; adresa videopamˆti
         mov       es,ax
         mov       ds,ax
         mov       dh,ds:[di]               ; barva pod kurzorem

; ------ m¢d opravy obrys–

         jz        Vybarvi7                 ; nen¡ m¢d opravy obrys–
         cmp       dh,CERNA                 ; je pod kurzorem ‡ern  barva ?
         mov       al,BILA                  ; nahrad¡ se b¡lou barvou
         je        Vybarvi6                 ; pod kurzorem je ‡ern  barva
         mov       al,CERNA                 ; jinak se nastav¡ ‡ern  barva
Vybarvi6:mov       ds:[di],al               ; ulo‘en¡ bodu
         jmp       short Vybarvi9

; ------ £schova barvy pod kurzorem

Vybarvi7:cmp       dh,CERNA                 ; je ‡ern  barva ?
         je        Vybarvi9                 ; ‡ern  se nevybarvuje
         cmp       dh,dl
         je        Vybarvi9                 ; je ji‘ vybarveno

; ------ vybarven¡ plochy

         call      VybarvL                  ; vybarven¡ linky

; ------ n vrat registr–

Vybarvi9:pop       ds
         ret

Vybarvi  ENDP

; -----------------------------------------------------------------------------
;        vybarven¡ linky - adresa DS:DI, pozice SI, barva DH na barvu DL
; -----------------------------------------------------------------------------

VybarvL  PROC      NEAR

; ------ vybarven¡ linky ve smˆru +

         push      di
         mov       cx,SirkaSCR              ; ¨¡©ka obrazovky
         sub       cx,si                    ; zbytek pozic
         jz        VybarvL3                 ; nen¡ voln  pozice
VybarvL2:cmp       ds:[di],dh               ; je to hledan  barva ?
         jne       VybarvL3                 ; nen¡ to hledan  barva - konec
         mov       ds:[di],dl               ; vybarven¡ bodu
         inc       di                       ; zv˜¨en¡ adresy ve videopamˆti
         loop      VybarvL2                 ; dal¨¡ bod linky
VybarvL3:pop       di

; ------ vybarven¡ linky ve smˆru -

         push      di
         mov       cx,si                    ; po‡ te‡n¡ pozice
         jcxz      VybarvL5                 ; nen¡ dal¨¡ bod na lince
VybarvL4:dec       di                       ; sn¡‘en¡ adresy ve videopamˆti
         cmp       ds:[di],dh               ; je to hledan  barva ?
         jne       VybarvL5                 ; nen¡ to hledan  barva - konec
         mov       ds:[di],dl               ; vybarven¡ bodu
         loop      VybarvL4                 ; dal¨¡ bod linky
VybarvL5:pop       di

         cmp       sp,offset Zasobnik       ; je ji‘ minimum z sobn¡ku ?
         jbe       VybarvL9                 ; je ji‘ minimum z sobn¡ku

; ------ nalezen¡ sousedn¡ho bodu k ni‘¨¡m link m

VybarL52:push      si
         push      di

         or        bp,bp                    ; je ji‘ minim ln¡ linka ?
         jz        VybarvL6                 ; nen¡ ji‘ p©edch zej¡c¡ linka
         call      VybarvN                  ; nalezen¡ ni‘¨¡ linky
         jc        VybarvL6                 ; ni‘¨¡ linka nenalezena

         dec       bp
         call      VybarvL                  ; vybarven¡ ni‘¨¡ linky
         inc       bp

         pop       di
         pop       si
         jmp       short VybarL52

VybarvL6:pop       di
         pop       si

; ------ nalezen¡ sousedn¡ho bodu k vy¨¨¡m link m

VybarL62:push      si
         push      di

         cmp       bp,VYSKA-1               ; je ji‘ maxim ln¡ linka ?
         jae       VybarvL7                 ; nen¡ ji‘ dal¨¡ linka
         call      VybarvV                  ; nalezen¡ vy¨¨¡ linky
         jc        VybarvL7                 ; vy¨¨¡ linka nenalezena

         inc       bp
         call      VybarvL                  ; vybarven¡ vy¨¨¡ linky
         dec       bp

         pop       di
         pop       si
         jmp       short VybarL62

VybarvL7:pop       di
         pop       si
VybarvL9:ret

VybarvL  ENDP

; -----------------------------------------------------------------------------
;        nalezen¡ sousedn¡ho bodu na ni‘¨¡ lince (CY=nenalezen) -> DI, SI
; -----------------------------------------------------------------------------

VybarvN  PROC      NEAR

; ------ hled n¡ smˆrem +

         push      si
         push      di
         mov       cx,SirkaSCR              ; ¨¡©ka obrazovky
         sub       cx,si                    ; zbytek pozic
         jz        VybarvN2                 ; nen¡ voln  pozice
VybarvN1:cmp       ds:[di],dl               ; je to vybarven˜ bod
         jne       VybarvN2                 ; konec linky
         cmp       ds:[di-SirkaSCR],dh      ; je sousedn¡ hledan˜ bod ?
         je        VybarvN5                 ; nalezen hledan˜ bod
         inc       si
         inc       di                       ; zv˜¨en¡ ukazatelele ve videopamˆti
         loop      VybarvN1
VybarvN2:pop       di
         pop       si

; ------ hled n¡ smˆrem -

         push      si
         push      di
         mov       cx,si                    ; po‡ te‡n¡ pozice
         jcxz      VybarvN4                 ; nen¡ dal¨¡ bod na lince
VybarvN3:dec       di                       ; sn¡‘en¡ ukazatelele ve videopamˆti
         dec       si
         cmp       ds:[di],dl               ; je to vybarven˜ bod
         jne       VybarvN4                 ; konec linky
         cmp       ds:[di-SirkaSCR],dh      ; je sousedn¡ hledan˜ bod ?
         je        VybarvN5                 ; nalezen hledan˜ bod
         loop      VybarvN3

VybarvN4:pop       di
         pop       si
         stc
         ret

; ------ vedlej¨¡ bod nalezen

VybarvN5:sub       di,SirkaSCR
         add       sp,2*2                   ; zru¨en¡ registr– SI a DI
         clc
         ret

VybarvN  ENDP

; -----------------------------------------------------------------------------
;        nalezen¡ sousedn¡ho bodu na vy¨¨¡ lince (CY=nenalezen) -> DI, SI
; -----------------------------------------------------------------------------

VybarvV  PROC      NEAR

         push      cx

; ------ hled n¡ smˆrem +

         push      si
         push      di
         mov       cx,SirkaSCR              ; ¨¡©ka obrazovky
         sub       cx,si                    ; zbytek pozic
         jz        VybarvV2                 ; nen¡ voln  pozice
VybarvV1:cmp       ds:[di],dl               ; je to vybarven˜ bod
         jne       VybarvV2                 ; konec linky
         cmp       ds:[di+SirkaSCR],dh      ; je sousedn¡ hledan˜ bod ?
         je        VybarvV5                 ; nalezen hledan˜ bod
         inc       si
         inc       di                       ; zv˜¨en¡ ukazatelele ve videopamˆti
         loop      VybarvV1
VybarvV2:pop       di
         pop       si

; ------ hled n¡ smˆrem -

         push      si
         push      di
         mov       cx,si                    ; po‡ te‡n¡ pozice
         jcxz      VybarvV4                 ; nen¡ dal¨¡ bod na lince
VybarvV3:dec       di                       ; sn¡‘en¡ ukazatelele ve videopamˆti
         dec       si
         cmp       ds:[di],dl               ; je to vybarven˜ bod
         jne       VybarvV4                 ; konec linky
         cmp       ds:[di+SirkaSCR],dh      ; je sousedn¡ hledan˜ bod ?
         je        VybarvV5                 ; nalezen hledan˜ bod
         loop      VybarvV3

VybarvV4:pop       di
         pop       si
         pop       cx
         stc
         ret

; ------ vedlej¨¡ bod nalezen

VybarvV5:add       di,SirkaSCR
         add       sp,2*2                   ; zru¨en¡ registr– SI a DI
         pop       cx
         clc
         ret

VybarvV  ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 10h s £schovou registr–
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
;                               obsluha na‡ten¡ souboru
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        inicializace seznamu soubor–
; -----------------------------------------------------------------------------

InitSezn PROC      NEAR

         push      ds
         pop       es

; ------ nastaven¡ tabulky DTA

         mov       dx,offset TabDTA         ; tabulka DTA
         mov       ah,1ah
         int       21h                      ; nastaven¡ tabulky DTA

; ------ nalezen¡ souboru PCX

         xor       cx,cx                    ; atributy
         mov       dx,offset AllPCX         ; specifikace *.PCX
         mov       ah,4eh
InitSzn2:int       21h                      ; nalezen¡ prvn¡ho/dal¨¡ho souboru
         jc        InitSzn4                 ; nen¡ dal¨¡ soubor

; ------ £schova jm‚na souboru

         mov       ax,14                    ; d‚lka jm‚na jednoho souboru
         mul       word ptr ds:[NumSoub]    ; offset v tabulce
         add       ax,offset BuffSoub       ; adresa k ulo‘en¡ jm‚na souboru
         xchg      ax,di                    ; DI <- adresa k ulo‘en¡ jm‚na souboru
         mov       cx,13                    ; d‚lka jm‚na souboru
         cld
         mov       si,offset TabDTA + 1eh   ; jm‚no souboru
         rep       movsb                    ; £schova jm‚na soubour
         mov       al,ds:[TabDTA+15h]       ; atributy souboru
         stosb                              ; £schova atribut– souboru

; ------ p©¡prava pro dal¨¡ soubor

         inc       word ptr ds:[NumSoub]    ; zv˜¨en¡ po‡tu soubor–
         mov       ah,4fh                   ; funkce - hled n¡ dal¨¡ho
         cmp       word ptr ds:[NumSoub],MaxSoub ; je ji‘ maximum soubor– ?
         jb        InitSzn2                 ; nalezen¡ dal¨¡ho souboru

; ------ implicitn¡ jm‚no, nen¡-li ‘ dn˜ soubor

InitSzn4:cmp       word ptr ds:[NumSoub],0  ; nalezen nˆjak˜ soubor ?
         jne       InitSzn5                 ; byl nalezen soubor

         or        byte ptr ds:[Param],40h  ; p©¡znak souboru NONAME
         mov       cx,14                    ; d‚lka jm‚na NONAME.PCX
         mov       si,offset NoNamPCX       ; jm‚no souboru NONAME.PCX
         mov       di,offset BuffSoub       ; buffer soubor–
         cld
         rep       movsb                    ; £schova jm‚na souboru
         inc       word ptr ds:[NumSoub]    ; 1 soubor implicitnˆ

; ------ set©¡dˆn¡ soubor– v seznamu (pozor - zjednodu¨eno - "." jako znak !)

InitSzn5:mov       si,offset BuffSoub-14    ; buffer soubor–
         cld
         mov       bx,ds:[NumSoub]          ; po‡et soubor–
InitSzn6:dec       bx                       ; ‡¡ta‡ soubor–
         jz        InitSzn9                 ; nen¡ dal¨¡ soubor
         add       si,14
InitSzn7:mov       di,si
         add       di,14

; ------ porovn n¡ jmen soubor– (zjednodu¨eno, znaky < "." budou p©ed mezerou !)

         push      si
         push      di
         mov       cx,13
         repe      cmpsb                    ; porovn n¡ jmen
         pop       di
         pop       si
         jbe       InitSzn6                 ; po©ad¡ je OK

; ------ z mˆna jmen soubor–

         push      si
         push      di
         mov       cx,14
InitSzn8:lodsb
         xchg      al,ds:[di]
         mov       ds:[si-1],al
         inc       di
         loop      InitSzn8
         pop       di
         pop       si

; ------ posun ukazatele soubor– k p©edchoz¡ dvojici

         cmp       si,offset BuffSoub       ; je ji‘ prvn¡ soubor ?
         jbe       InitSzn6                 ; je prvn¡ soubor
         sub       si,14                    ; posun dol–
         inc       bx
         jmp       short InitSzn7           ; p©edchoz¡ dvojice soubor–

InitSzn9:ret

InitSezn ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ jm‚na souboru
; -----------------------------------------------------------------------------

DispName PROC      NEAR

; ------ vymaz n¡ pole k zobrazen¡ jm‚na souboru

         mov       ax,0a000h
         mov       es,ax                    ; segment videopamˆti
         mov       di,24*40*8*8 + 31*8      ; adresa k zobrazen¡ textu
         xor       ax,ax
         mov       bx,8
DispNam1:mov       cx,8*8/2                 ; po‡et znak–
DispNam2:rep       stosw
         add       di,320-8*8
         dec       bx
         jnz       DispNam1

; ------ adresa aktivn¡ho souboru

         mov       ax,14                    ; d‚lka textu jednoho souboru
         mul       word ptr ds:[AktSoub]    ; offset aktivn¡ho souboru
         add       ax,offset BuffSoub       ; adresa jm‚na souboru
         mov       ds:[AktSoubA],ax         ; adresa jm‚na souboru
         xchg      ax,si                    ; SI <- jm‚no souboru

; ------ zji¨tˆn¡ d‚lky jm‚na souboru

         cld
         push      si
         mov       cx,-1                    ; p©ednastaven¡
DispNam5:inc       cx
         lodsb
         cmp       al,"."
         je        DispNam6
         cmp       al,0
         jne       DispNam5
DispNam6:pop       bp                       ; jm‚no souboru

; ------ omezen¡ d‚lky jm‚na

         cmp       cx,8
         jb        DispNam7
         mov       cx,8

; ------ pozice k zobrazen¡ jm‚na souboru

DispNam7:mov       dx,24*256 + 8+1          ; posledn¡ © dek, ¨¡©ka pole
         sub       dl,cl                    ; zbytek na okraje
         shr       dl,1                     ; polovina na lev˜ okraj
         add       dl,31                    ; po‡ te‡n¡ pozice

; ------ zobrazen¡ jm‚na souboru

         mov       bx,15                    ; barva a str nka
         push      ds
         pop       es
         mov       ax,1300h
         call      Int10                    ; zobrazen¡ textu
         ret

DispName ENDP

; -----------------------------------------------------------------------------
;        otev©en¡ aktivn¡ho souboru pro ‡ten¡
; -----------------------------------------------------------------------------

OpenFile PROC      NEAR

; ------ otev©en¡ souboru pro ‡ten¡

         mov       dx,ds:[AktSoubA]         ; jm‚no aktivn¡ho souboru
         mov       word ptr ds:[SoubIdnt],0 ; p©¡znak, ‘e nen¡ otev©en
         mov       ax,3d00h
         int       21h
         jnc       OpenFil1
OpenFil0:ret
OpenFil1:mov       ds:[SoubIdnt],ax         ; identifik tor vstupn¡ho souboru

; ------ na‡ten¡ z hlav¡ souboru

         xchg      ax,bx                    ; identifik tor souboru
         mov       dx,offset HeadPCX        ; buffer na‡ten‚ho z hlav¡
         mov       ah,3fh
         mov       cx,offset(HeadPCX0-HeadPCX)
         int       21h

; ------ minim lnˆ 1 bit na bod

         cmp       byte ptr ds:[PCXBits],0
         jne       OpnFil13
         inc       byte ptr ds:[PCXBits]    ; 1 bit

; ------ minim lnˆ 1 rovina barev

OpnFil13:cmp       byte ptr ds:[PCXRovin],0
         jne       OpnFil14
         inc       byte ptr ds:[PCXRovin]   ; 1 rovina

; ------ ¨¡©ka obr zku

OpnFil14:mov       ax,ds:[PCXX2]            ; koncov  sou©adnice X2
         sub       ax,ds:[PCXX1]            ; v˜po‡et ¨¡©ky obr zku
         inc       ax
         jnz       OpnFil15
         inc       ax                       ; minim ln¡ ¨¡©ka 1
OpnFil15:cmp       ax,MaxSirX               ; maxim ln¡ ¨¡©ka
         jbe       OpnFil16                 ; ¨¡©ka je OK
         mov       ax,MaxSirX               ; omezen¡ ¨¡©ky obr zku
OpnFil16:mov       ds:[PCXSirka],ax         ; ¨¡©ka obr zku

; ------ koeficient zkr cen¡ ve smˆru X

         mov       cx,SIRKA                 ; CX <- ¨¡©ka obrazovky
         xor       dx,dx
         div       cx                       ; v˜po‡et koeficientu zkr cen¡
         mov       ds:[KoefXHgh],ax         ; koeficient - cel  ‡ st
         xor       ax,ax                    ; DX:AX = zbytek * 65K
         div       cx
         mov       ds:[KoefXLow],ax         ; koeficient - desetinn  ‡ st

; ------ v˜¨ka obr zku

         mov       ax,ds:[PCXY2]            ; koncov  sou©adnice Y2
         sub       ax,ds:[PCXY1]            ; v˜po‡et v˜¨ky obr zku
         inc       ax
         jnz       OpnFil17
         inc       ax                       ; minim ln¡ v˜¨ka 1
OpnFil17:cmp       ax,MaxVysY               ; maxim ln¡ v˜¨ka
         jbe       OpnFil18
         mov       ax,MaxVysY               ; maxim ln¡ v˜¨ka obr zku
OpnFil18:mov       ds:[PCXVyska],ax         ; v˜¨ka obr zku

; ------ koeficient zkr cen¡ ve smˆru Y

         mov       cx,VYSKA                 ; CX <- v˜¨ka obrazovky
         xor       dx,dx
         div       cx                       ; v˜po‡et koeficientu zkr cen¡
         mov       ds:[KoefYHgh],ax         ; koeficient - cel  ‡ st
         xor       ax,ax                    ; DX:AX = zbytek * 65K
         div       cx
         mov       ds:[KoefYLow],ax         ; koeficient - desetinn  ‡ st

; ------ p©¡prava palet pro m¢d 16 barev

         mov       di,offset PCXVga
         mov       si,offset PCXEga
         push      ds
         pop       es
         mov       cx,3*16/2
         cld
         rep       movsw

; ------ na‡ten¡ palet barev

         cmp       byte ptr ds:[PCXVerze],5 ; je paleta VGA ?
         jb        OpenFil3                 ; nen¡ paleta VGA

         mov       dx,-(3*256+1)            ; offset palet od konce souboru
         mov       cx,-1
         mov       ax,4202h
         int       21h                      ; nastaven¡ ukazatele na palety

         mov       dx,offset PCXVgaX        ; buffer oddˆlova‡e palet
         mov       cx,1                     ; na‡te se 1 bajt
         mov       ah,3fh
         int       21h                      ; na‡ten¡ oddˆlova‡e palet
         cmp       byte ptr ds:[PCXVgaX],12 ; je to spr vn˜ oddˆlova‡ ?
         jne       OpenFil2                 ; nen¡ paleta

         mov       dx,offset PCXVga         ; buffer palet VGA
         mov       cx,3*256                 ; velikost palet
         mov       ah,3fh
         int       21h                      ; na‡ten¡ palet VGA

OpenFil2:mov       dx,128
         xor       cx,cx
         mov       ax,4200h
         int       21h                      ; resetov n¡ ukazatele souboru

; ------ korekce palet pro 2 barvy

OpenFil3:mov       al,ds:[PCXBits]          ; po‡et bit– na bod
         mul       byte ptr ds:[PCXRovin]   ; celkem po‡et bit– na bod
         dec       ax                       ; je 1 bit na bod ?
         jnz       OpenFil4                 ; nen¡ 1 bit na bod
         mov       word ptr ds:[PCXVga],0   ; 1. barva je ‡ern 
         mov       word ptr ds:[PCXVga+2],0ff00h
         mov       word ptr ds:[PCXVga+4],0ffffh ; 2. barva je b¡l 
OpenFil4:ret

OpenFile ENDP

; -----------------------------------------------------------------------------
;        p©¡prava konverzn¡ tabulky palet
; -----------------------------------------------------------------------------

InitPal  PROC      NEAR

; ------ inicializace registr–

         push      ds
         pop       es
         mov       si,offset PCXVga         ; tabulka palet souboru
         mov       di,offset KonvPal        ; konverzn¡ tabulka barev
         cld

; ------ p©¡prava k vyhled n¡ barvy

InitPal1:push      di
         push      si
         mov       dx,-1                    ; nejbli‘¨¡ nalezen  shoda
         mov       di,offset TabPal + TopCol*3 ; adresa po‡ tku vlastn¡ barvy
         mov       ch,TopCol                ; ukazatel ‡¡sla barvy

; ------ v˜po‡et vzd lenosti ‡erven‚ barvy

InitPal2:mov       al,ds:[si]               ; ‡erven 
         mov       ah,ds:[di]
         shr       al,1
         shr       al,1
         shr       ah,1
         shr       ah,1
         sub       al,ah                    ; odchylka ‡erven‚
;         jnc       InitPal3
;         neg       al
;InitPal3:mov       ah,0
         imul      al                       ; kvadr t odchylky
         xchg      ax,bx                    ; BX <- odchylka ‡erven‚

; ------ v˜po‡et vzd lenosti zelen‚ barvy

         mov       al,ds:[si+1]             ; zelen 
         mov       ah,ds:[di+1]
         shr       al,1
         shr       al,1
         shr       ah,1
         shr       ah,1
         sub       al,ah                    ; odchylka zelen‚
;         jnc       InitPal4
;         neg       al
;InitPal4:mov       ah,0
         imul      al                       ; kvadr t odchylky
         add       bx,ax                    ; p©id n¡ ke st©ada‡i odchylek

; ------ v˜po‡et vzd lenosti modr‚ barvy

         mov       al,ds:[si+2]             ; modr 
         mov       ah,ds:[di+2]
         shr       al,1
         shr       al,1
         shr       ah,1
         shr       ah,1
         sub       al,ah                    ; odchylka modr‚
;         jnc       InitPal5
;         neg       al
;InitPal5:mov       ah,0
         imul      al                       ; kvadr t odchylky
         add       ax,bx                    ; p©id n¡ ke st©ada‡i odchylek

; ------ test, zda je barva bli‘¨¡ ne‘ dosud nalezen 

         cmp       ax,dx                    ; je odchylka men¨¡ ?
         jae       InitPal7                 ; odchylka nen¡ men¨¡
         xchg      ax,dx                    ; DX <- nov  odchylka
         mov       cl,ch                    ; CL <- nov  nalezen  barva

; ------ p©¡prava k testu dal¨¡ barvy

InitPal7:inc       ch                       ; zv˜¨en¡ ukazatele ‡¡sla barvy
         add       di,3                     ; dal¨¡ testovan  barva
         cmp       ch,TopCol+NumCols        ; jsou ji‘ v¨echny barvy ?
         jb        InitPal2                 ; test dal¨¡ barvy

; ------ ulo‘en¡ n hradn¡ barvy

         xchg      ax,cx                    ; AL <- nalezen  barva
         pop       si
         pop       di
         stosb                              ; ulo‘en¡ n hradn¡ barvy

; ------ p©¡prava pro dal¨¡ barvu

         add       si,3                     ; dal¨¡ paleta
         cmp       di,offset KonvPal+256
         jb        InitPal1                 ; dal¨¡ paleta
         ret

InitPal  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ souboru
; -----------------------------------------------------------------------------
;þ
Zobraz   PROC      NEAR

; ------ p©¡prava ukl dac¡ adresy

         mov       ax,0a000h
         mov       es,ax
         xor       di,di

; ------ p©¡prava ukazatel– k na‡¡t n¡ dat

         cld
         mov       word ptr ds:[ReadAX],100h ; byl posledn¡ bajt
         mov       word ptr ds:[ReadBX],0   ; nen¡ ‘ dn˜ bit
         mov       word ptr ds:[ReadSI],offset Buffer0 ; ukazatel na konec bufferu

; ------ p©¡prava registr–

         xor       bp,bp                    ; p©¡rustek ‡¡sla linky LOW
         mov       cx,VYSKA                 ; v˜¨ka obr zku

; ------ na‡ten¡ prvn¡ linky

         call      ReadLine                 ; na‡ten¡ linky

; ------ zobrazen¡ jedn‚ linky

Zobraz1: push      bx
         push      cx
         push      dx
         push      si
         push      bp

         xor       bp,bp                    ; p©¡rustek adresy LOW
         mov       cx,ds:[KoefXLow]         ; koeficient zkr cen¡ LOW
         mov       dx,ds:[KoefXHgh]         ; koeficient zkr cen¡ HIGH
         mov       bx,offset KonvPal        ; konverzn¡ tabulka barev

         mov       si,offset Linka
         mov       ah,SIRKA/2               ; po‡et bod– na ¨¡©ku

Zobraz2: lodsb                              ; na‡ten¡ bodu
         xlat                               ; konverze barvy
         stosb                              ; ulo‘en¡ bodu
         dec       si                       ; n vrat adresy bodu
         add       bp,cx                    ; zv˜¨en¡ adresy LOW
         jnc       Zobraz21

         lodsb
         xlat
         cmp       al,CERNA                 ; je ‡ern  ?
         jne       Zobraz21                 ; nen¡ ‡ern 
         mov       es:[di-1],al             ; p©ede¨l  barva ‡ern 
Zobraz21:or        dx,dx
         jz        Zobraz23

         push      dx
Zobraz22:lodsb
         xlat
         cmp       al,CERNA
         jne       Zobr222
         mov       es:[di-1],al
Zobr222: dec       dx
         jnz       Zobraz22
         pop       dx


Zobraz23:

         lodsb                              ; na‡ten¡ bodu
         xlat                               ; konverze barvy
         stosb                              ; ulo‘en¡ bodu
         dec       si                       ; n vrat adresy bodu
         add       bp,cx                    ; zv˜¨en¡ adresy LOW
         jnc       ZobrzX21

         lodsb
         xlat
         cmp       al,CERNA                 ; je ‡ern  ?
         jne       ZobrzX21                 ; nen¡ ‡ern 
         mov       es:[di-1],al             ; p©ede¨l  barva ‡ern 
ZobrzX21:or        dx,dx
         jz        ZobrzX23

         push      dx
ZobrzX22:lodsb
         xlat
         cmp       al,CERNA
         jne       ZobrX222
         mov       es:[di-1],al
ZobrX222:dec       dx
         jnz       ZobrzX22
         pop       dx

ZobrzX23:
         dec       ah                       ; ‡¡ta‡ bod– na ¨¡©ku
         jnz       Zobraz2                  ; dal¨¡ bod

         pop       bp
         pop       si
         pop       dx
         pop       cx
         pop       bx

; ------ ‡¡t n¡ po‡tu linek

         dec       cx                       ; ‡¡ta‡ linek
         jz        Zobraz9                  ; jsou ji‘ v¨echny linky

; ------ test kl vesnice

         test      cl,0fh                   ; asi tak ka‘d˜ch 16 linek
         jnz       Zobraz24

         mov       ah,1
         int       16h
         jz        Zobraz24

         or        ax,ax
         jz        Zobraz9
         cmp       al,27
         je        Zobraz9
         cmp       ax,4b00h                 ; vlevo
         je        Zobraz9
         cmp       ax,7300h                 ; Ctrl-vlevo
         je        Zobraz9
         cmp       ax,0f00h                 ; Shift-TAB
         je        Zobraz9
         cmp       ax,4d00h                 ; vpravo
         je        Zobraz9
         cmp       ax,7400h                 ; Ctrl-vpravo
         je        Zobraz9
         cmp       ax,0f09h                 ; TAB
         je        Zobraz9
         mov       ah,0
         int       16h

; ------ zv˜¨en¡ ‡¡ta‡e linek

Zobraz24:xor       bx,bx                    ; ‡¡ta‡ linek HIGH
         add       bp,ds:[KoefYLow]         ; zv˜¨en¡ ‡¡ta‡e linek LOW
         adc       bx,ds:[KoefYHgh]         ; zv˜¨en¡ ‡¡ta‡e linek HIGH
         jnz       Zobraz3
         jmp       Zobraz1                  ; zobraz¡ se stejn  linka

; ------ p©esko‡en¡ linek

Zobraz3: call      ReadLine                 ; na‡ten¡ dal¨¡ linky
         dec       bx
         jz        Zobraz32

         call      Zobr5
         jmp       short Zobraz3            ; p©esko‡en¡ dal¨¡ linky

Zobraz32:jmp       Zobraz1            ; zobrazen¡ linky

Zobraz9: ret

Zobraz   ENDP

; ------ p©esko‡en¡ jedn‚ linky

Zobr5:   push      bx
         push      cx
         push      dx
         push      si
         push      bp

         sub       di,SirkaSCR

         xor       bp,bp                    ; p©¡rustek adresy LOW
         mov       cx,ds:[KoefXLow]         ; koeficient zkr cen¡ LOW
         mov       dx,ds:[KoefXHgh]         ; koeficient zkr cen¡ HIGH
         mov       bx,offset KonvPal        ; konverzn¡ tabulka barev

         mov       si,offset Linka
         mov       ah,SIRKA/2               ; po‡et bod– na ¨¡©ku

Zobr52:  lodsb                              ; na‡ten¡ bodu
         xlat                               ; konverze barvy
         cmp       al,CERNA
         jne       Zobr520
         stosb                              ; ulo‘en¡ bodu
         dec       di
Zobr520: inc       di

         dec       si                       ; n vrat adresy bodu
         add       bp,cx                    ; zv˜¨en¡ adresy LOW
         jnc       Zobr521

         lodsb
         xlat
         cmp       al,CERNA                 ; je ‡ern  ?
         jne       Zobr521                 ; nen¡ ‡ern 
         mov       es:[di-1],al             ; p©ede¨l  barva ‡ern 
Zobr521: or        dx,dx
         jz        Zobr523

         push      dx
Zobr522:lodsb
         xlat
         cmp       al,CERNA
         jne       Zobr5222
         mov       es:[di-1],al
Zobr5222: dec       dx
         jnz       Zobr522
         pop       dx


Zobr523:

         lodsb                              ; na‡ten¡ bodu
         xlat                               ; konverze barvy
         cmp       al,CERNA
         jne       Zobr5x20
         stosb                              ; ulo‘en¡ bodu
         dec       di
Zobr5x20: inc       di

         dec       si                       ; n vrat adresy bodu
         add       bp,cx                    ; zv˜¨en¡ adresy LOW
         jnc       Zobr5X21

         lodsb
         xlat
         cmp       al,CERNA                 ; je ‡ern  ?
         jne       Zobr5X21                 ; nen¡ ‡ern 
         mov       es:[di-1],al             ; p©ede¨l  barva ‡ern 
Zobr5X21:or        dx,dx
         jz        Zobr5X23

         push      dx
Zobr5X22:lodsb
         xlat
         cmp       al,CERNA
         jne       Zobr5y22
         mov       es:[di-1],al
Zobr5y22:dec       dx
         jnz       Zobr5X22
         pop       dx

Zobr5X23:
         dec       ah                       ; ‡¡ta‡ bod– na ¨¡©ku
         jnz       Zobr52                  ; dal¨¡ bod

         pop       bp
         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret


; -----------------------------------------------------------------------------
;        na‡ten¡ jedn‚ linky obr zku (uchov vat CLD, AX a SI !)
; -----------------------------------------------------------------------------

ReadLine PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ p©¡prava registr–

         push      ds
         pop       es
         mov       ax,ds:[ReadAX]
         mov       si,ds:[ReadSI]
         mov       bx,ds:[ReadBX]
         mov       di,offset Linka          ; buffer linky
         mov       cx,ds:[PCXSirka]         ; ¨¡©ka obr zku
         mov       bp,ds:[PCXByte]          ; po‡et bajt– na linku
         mov       dl,ds:[PCXRovin]         ; po‡et barevn˜ch rovin
         mov       dh,1                     ; maska barevn‚ roviny

         mov       bh,0

; ------ rozli¨en¡ po‡tu bit– na bod

         cmp       byte ptr ds:[PCXBits],2  ; jsou 2 bity na bod (=CGA) ?
         jbe       ReadLin2                 ; je 2 nebo 1 bit

; ------ na‡ten¡ linky v m¢du 8 bit–

ReadLin1:dec       bp
         call      ReadByte                 ; na‡ten¡ dal¨¡ho bajtu
         stosb                              ; ulo‘en¡ bajtu do bufferu
         loop      ReadLin1                 ; dal¨¡ bod
         jmp       short ReadLin8

; ------ na‡ten¡ linky v m¢du 1 bit

ReadLin2:je        ReadLin6                 ; jsou 2 bity na bod

; ------ £vodn¡ vymaz n¡ bufferu

         push      di
         push      cx
         push      ax
         mov       al,0
         rep       stosb
         pop       ax
         pop       cx
         pop       di

; ------ na‡ten¡ linky

ReadLn32:mov       bp,ds:[PCXByte]          ; po‡et bajt– na linku
ReadLin3:or        bh,bh                    ; je nˆjak˜ bit ?
         jnz       ReadLin4                 ; je nˆjak˜ bit
         dec       bp
         call      ReadByte                 ; na‡ten¡ dal¨¡ho bajtu
         mov       bh,8                     ; po‡et bit– na bajt
         mov       bl,al                    ; BL <- na‡ten˜ bajt
ReadLin4:shl       bl,1                     ; je bit nastaven ?
         jnc       ReadLin5                 ; bit nen¡ nastaven
         or        byte ptr ds:[di],dh      ; nastaven¡ bitu
ReadLin5:inc       di                       ; zv˜¨en¡ ukl dac¡ adresy
         dec       bh                       ; ‡¡ta‡ bit–
         loop      ReadLin3                 ; dal¨¡ bit

; ------ p©¡prava pro dal¨¡ rovinu

         or        bp,bp
         jle       ReadLn54
ReadLn52:call      ReadByte
         dec       bp
         jnz       ReadLn52

ReadLn54:mov       di,offset Linka          ; buffer linky
         mov       cx,ds:[PCXSirka]         ; ¨¡©ka obr zku

         mov       bh,0

         shl       dh,1                     ; rotace masky
         dec       dl                       ; ‡¡ta‡ rovin
         jnz       ReadLn32                 ; dal¨¡ rovina
         jmp       short ReadLin8

; ------ dek¢dov n¡ linky v m¢du 2 bity

ReadLin6:or        bh,bh                    ; je nˆjak˜ bit ?
         jnz       ReadLin7                 ; je nˆjak˜ bit
         dec       bp
         call      ReadByte                 ; na‡ten¡ bajtu
         mov       bh,4                     ; po‡et dvojic bit–
         mov       bl,al
ReadLin7:rol       bl,1
         rol       bl,1
         mov       ds:[di],bl               ; ulo‘en¡ bajtu
         and       byte ptr ds:[di],3       ; maskov n¡ hodnoty
         inc       di                       ; zv˜¨en¡ ukl dac¡ adresy
         dec       bh
         loop      ReadLin6                 ; dal¨¡ bod

; ------ zru¨en¡ p©ebyte‡n˜ch bajt–

ReadLin8:or        bp,bp
         jle       ReadLin9
ReadLn82:call      ReadByte
         dec       bp
         jnz       ReadLn82

; ------ n vrat registr–

ReadLin9:mov       ds:[ReadAX],ax
         mov       ds:[ReadSI],si
         mov       ds:[ReadBX],bx

         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ReadLine ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ jednoho bajtu ze vstupn¡ho bufferu (je CLD !)
; -----------------------------------------------------------------------------
; VSTUP: AL=star  hodnota bajtu
;        AH=‡¡ta‡ opakov n¡ bajtu (1=bude dal¨¡ bajt)
;        DS:SI=adresa bufferu
;        CLD=smˆr nahoru
; -----------------------------------------------------------------------------

ReadByte PROC      NEAR

; ------ dal¨¡ opakov n¡ bajtu AL

         dec       ah                       ; ‡¡ta‡ opakov n¡ bajtu
         jnz       ReadByt7                 ; je dal¨¡ opakov n¡ bajtu

; ------ na‡ten¡ dal¨¡ho bajtu z bufferu

ReadByt0:cmp       si,offset Buffer0        ; je ji‘ konec bufferu ?
         jae       ReadByt8                 ; je ji‘ konec bufferu
ReadByt1:lodsb                              ; na‡ten¡ dal¨¡ho bajtu

; ------ test, zda je opakov n¡ bajtu

         mov       ah,1                     ; bajt se nebude opakovat
         cmp       al,0c0h                  ; je platn˜ datov˜ bajt ?
         jb        ReadByt7                 ; je platn˜ datov˜ bajt

; ------ £schova po‡tu opakov n¡ bajtu

         and       al,3fh                   ; po‡et opakov n¡ bajtu
         mov       ah,al                    ; po‡et opakov n¡ bajtu

; ------ na‡ten¡ bajtu k opakov n¡

         cmp       si,offset Buffer0        ; je ji‘ konec bufferu ?
         jae       ReadByt9                 ; je ji‘ konec bufferu
ReadByt2:lodsb                              ; na‡ten¡ bajtu k opakov n¡
         or        ah,ah                    ; je nˆjak˜ bajt ?
         jz        ReadByt0                 ; nen¡ bajt
ReadByt7:ret

; ------ na‡ten¡ dal¨¡ch dat ze souboru do bufferu - ‡ st 1

ReadByt8:call      ReadBuff                 ; na‡ten¡ dal¨¡ ‡ sti souboru
         jmp       short ReadByt1

; ------ na‡ten¡ dal¨¡ch dat ze souboru do bufferu - ‡ st 2

ReadByt9:call      ReadBuff                 ; na‡ten¡ dal¨¡ ‡ sti souboru
         jmp       short ReadByt2

ReadByte ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ obsahu vstupn¡ho bufferu -> SI adresa za‡ tku buff.
; -----------------------------------------------------------------------------

ReadBuff PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx

         mov       si,offset Buffer
         mov       dx,si
         mov       ah,3fh
         mov       bx,ds:[SoubIdnt]         ; identifik tor souboru
         mov       cx,BuffSize              ; velikost bufferu
         int       21h

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         cld
         ret

ReadBuff ENDP

; -----------------------------------------------------------------------------
;        ulo‘en¡ aktivn¡ho souboru
; -----------------------------------------------------------------------------
;þ
Uloz     PROC      NEAR

; ------ test, zda byl soubor modifikov n

         test      byte ptr ds:[Param],80h  ; byl soubor modifikov n ?
         jnz       Uloz1                    ; soubor byl modifikov n
Uloz0:   ret

Uloz1:   and       byte ptr ds:[Param],not 80h ; zru¨en¡ p©¡znaku modifikace

; ------ test, zda je z kaz z pisu do souboru

         mov       si,ds:[AktSoubA]         ; adresa jm‚na souboru
         test      byte ptr ds:[si+13],1    ; je z kaz z pisu do souboru ?
         jnz       Uloz0                    ; je z kaz z pisu do souboru

; ------ test verze syst‚mu

         mov       ah,30h
         int       21h
         cmp       al,3
         jb        Uloz0                    ; n¡zk  verze syst‚mu

; ------ vytvo©en¡ v˜stupn¡ho souboru (vy‘aduje DOS verze minim lnˆ 3.0)

         mov       byte ptr ds:[OutSoub+2],0 ; useknut¡ cesty k adres ©i
         mov       dx,offset OutSoub        ; buffer jm‚na souboru
         xor       cx,cx                    ; atributy souboru
         mov       ah,5ah
         stc                                ; p©ednastaven¡ pro nekompat. DOS
         int       21h                      ; vytvo©en¡ v˜stupn¡ho souboru
         jc        Uloz0                    ; chyba - soubor nelze vytvo©it
         mov       ds:[SoubIdnt],ax         ; identifik tor souboru
         xchg      ax,bx                    ; BX <- identifik tor souboru

; ------ vypnut¡ kurzoru my¨i

         call      MouseOff                 ; vypnut¡ kurzoru my¨i

; ------ z pis z hlav¡ souboru

         mov       dx,offset HeadPCXW       ; z hlav¡ souboru pro z pis
         mov       cx,offset(HeaPCXW0-HeadPCXW) ; d‚lka z hlav¡ souboru
         mov       ah,40h
         int       21h                      ; z pis z hlav¡ souboru
         jc        Uloz6

; ------ z pis obsahu souboru

         mov       ax,0a000h
         mov       es,ax                    ; ES <- adresa videopamˆti
         mov       dx,VYSKA                 ; v˜¨ka obr zku
         xor       si,si                    ; adresa za‡ tku obr zku
         mov       di,offset Buffer         ; v˜stupn¡ buffer
         mov       ah,0c0h                  ; nen¡ ‘ dn˜ bajt
Uloz2:   mov       cx,SIRKA                 ; ¨¡©ka obr zku

Uloz3:   cmp       ah,0c0h                  ; bude prvn¡ bajt ?
         je        Uloz32                   ; je prvn¡ bajt
         cmp       al,es:[si]               ; je stejn˜ bajt ?
         je        Uloz4                    ; je stejn˜ bajt
         call      WritFlsh                 ; vypr zdnˆn¡ st©ada‡e opakov n¡
         jc        Uloz6
Uloz32:  mov       al,es:[si]               ; bajt k ulo‘en¡
         inc       si                       ; zv˜¨en¡ adresy ve videopamˆti
         mov       ah,0c1h                  ; v bufferu je 1 bajt
         jmp       short Uloz5

Uloz4:   inc       si                       ; zv˜¨en¡ adresy ve videopamˆti
         inc       ah                       ; zv˜¨en¡ st©ada‡e
         cmp       ah,0ffh                  ; je ji‘ maximum ?
         jne       Uloz5                    ; nen¡ je¨tˆ maximum
         call      WritFlsh                 ; vypr zdnˆn¡ st©ada‡e
         jc        Uloz6
Uloz5:   loop      Uloz3                    ; dal¨¡ bajt
         call      WritFlsh                 ; vypr zdnˆn¡ st©ada‡e opakov n¡
         jc        Uloz6
         dec       dx                       ; ‡¡ta‡ linek
         jnz       Uloz2                    ; z pis dal¨¡ linky
         call      WritBuff                 ; z pis obsahu bufferu
         jc        Uloz6

; ------ z pis palety barev

         mov       dx,offset TabPal0        ; tabulka palet barev
         mov       cx,3*256+1               ; velikost tabulky
         mov       bx,ds:[SoubIdnt]         ; identifik tor souboru
         mov       ah,40h
         int       21h                      ; z pis palet
         jc        Uloz6                    ; chyba
         cmp       ax,cx                    ; bylo zaps no v¨e ?

; ------ uzav©en¡ v˜stupn¡ho souboru

Uloz6:   pushf
         mov       ah,3eh
         mov       bx,ds:[SoubIdnt]         ; identifik tor souboru
         int       21h                      ; uzav©en¡ souboru
         popf

; ------ p©i chybˆ zru¨en¡ souboru

         jnc       Uloz8                    ; z pis je OK
Uloz7:   mov       ah,41h
         mov       dx,offset OutSoub        ; jm‚no v˜stupn¡ho souboru
         xor       cx,cx                    ; maska atribut– pro s¡Ÿ
         int       21h                      ; zru¨en¡ souboru p©i chybˆ
         jmp       short Uloz9

; ------ zru¨en¡ p–vodn¡ho souboru

Uloz8:   mov       dx,ds:[AktSoubA]         ; adresa jm‚na souboru
         xor       cx,cx                    ; maska atribut– pro s¡Ÿ
         test      byte ptr ds:[Param],40h  ; je soubor NONAME ?
         jnz       Uloz82                   ; je soubor NONAME
         mov       ah,41h
         int       21h                      ; zru¨en¡ p–vodn¡ho souboru
         jc        Uloz7                    ; chyba - soubor nelze zru¨it

; ------ p©ejmenov n¡ souboru

Uloz82:  xor       cx,cx                    ; maska atribut– pro s¡Ÿ
         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       dx,offset OutSoub        ; p–vodn¡ jm‚no souboru
         mov       di,ds:[AktSoubA]         ; nov‚ jm‚no souboru
         mov       ah,56h
         int       21h                      ; p©ejmenov n¡ souboru

Uloz9:   call      MouseOn                  ; zapnut¡ kurzoru my¨i
         ret

Uloz     ENDP

; -----------------------------------------------------------------------------
;        vypr zdnˆn¡ st©ada‡e opakov n¡ (AH bajt– AL) CY=chyba
; -----------------------------------------------------------------------------

WritFlsh PROC      NEAR

         cmp       ah,0c0h                  ; je nˆjak˜ bajt ?
         je        WritFls3                 ; nen¡ ‘ dn˜ bajt

         cmp       al,0c0h                  ; je povolen˜ bajt ?
         jae       WritFls1                 ; nen¡ povolen˜ bajt
         cmp       ah,0c1h                  ; je 1 bajt ?
         je        WritFls2                 ; je 1 bajt - nen¡ opakov n¡

WritFls1:xchg      al,ah                    ; AL <- po‡et bajt–
         call      WritByte                 ; z pis po‡tu opakov n¡
         xchg      al,ah                    ; AL <- bajt
         jc        WritFls3                 ; chyba z pisu
WritFls2:call      WritByte                 ; z pis bajtu k opakov n¡

WritFls3:mov       ah,0c0h                  ; nen¡ ‘ dn˜ bajt
         ret

WritFlsh ENDP

; -----------------------------------------------------------------------------
;        z pis bajtu AL (buffer DI)
; -----------------------------------------------------------------------------

WritByte PROC      NEAR

         cmp       di,offset Buffer0        ; je buffer ji‘ pln˜ ?
         jb        WritByt2                 ; buffer je¨tˆ nen¡ pln˜
         call      WritBuff                 ; vypr zdnˆn¡ bufferu
         jc        WritByt4                 ; chyba

WritByt2:mov       ds:[di],al               ; ulo‘en¡ znaku AL do bufferu
         inc       di                       ; zv˜¨en¡ ukl dac¡ adresy
         clc                                ; p©¡znak operace OK
WritByt4:ret

WritByte ENDP

; -----------------------------------------------------------------------------
;        z pis obsahu bufferu (ukl dac¡ adresa DI)
; -----------------------------------------------------------------------------

WritBuff PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx

         mov       cx,di                    ; CX <- ukl dac¡ adresa do bufferu
         mov       dx,offset Buffer         ; adresa za‡ tku bufferu
         mov       di,dx                    ; ukazatel na za‡ tek bufferu
         sub       cx,dx                    ; po‡et bajt– v bufferu
         je        WritBuf1                 ; nejsou ‘ dn  data
         mov       bx,ds:[SoubIdnt]         ; identifik tor souboru
         mov       ah,40h
         int       21h                      ; z pis dat do souboru
         jc        WritBuf1                 ; chyba
         cmp       ax,cx                    ; bylo zaps no v¨e ?

WritBuf1:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

WritBuff ENDP

; *****************************************************************************
;
;                          Obsluha my¨i
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        inicializace obsluhy my¨i
; -----------------------------------------------------------------------------

InitMous PROC      NEAR

; ------ kontrola, zda lze my¨ testovat

         mov       ax,3533h
         int       21h                      ; poskytnut¡ adresy INT 33h
         mov       ax,es
         cmp       ax,60h                   ; je segment OK ?
         jb        InitMou9                 ; my¨ asi nen¡
         cmp       bx,0ffe0h
         jae       InitMou9                 ; my¨ asi nen¡

; ------ test instalace my¨i

         mov       al,0
         call      Int33                    ; test instalace my¨i
         inc       ax                       ; je my¨ nainstalovan  ?
         jnz       InitMou9                 ; my¨ nen¡ nainstalov na
         or        byte ptr ds:[Param],1    ; p©¡znak nainstalov n¡ my¨i

; ------ definice vertik ln¡ch rozmˆr– okna

         xor       cx,cx                    ; minim ln¡ sou©adnice Y
         mov       dx,MaxYMous              ; maxim ln¡ sou©adnice Y
         mov       al,8
         call      Int33                    ; definice © dk– okna

; ------ definice horizont ln¡ch rozmˆr– okna

         xor       cx,cx                    ; minim ln¡ sou©adnice X
         mov       dx,MaxXMous              ; maxim ln¡ sou©adnice X
         mov       al,7
         call      Int33                    ; definov n¡ pozic okna

; ------ nastaven¡ pozice kurzoru my¨i

         mov       cx,SirkaSCR/2
         mov       dx,VyskaSCR/2
         mov       al,4
         call      Int33                    ; nastaven¡ pozice kurzoru my¨i

; ------ zapnut¡ my¨i

         call      MouseOn                  ; zapnut¡ kurzoru my¨i
InitMou9:ret

InitMous ENDP

; -----------------------------------------------------------------------------
;        zapnut¡ kurzoru my¨i
; -----------------------------------------------------------------------------

MouseOn  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ test, zda bude kurzor zapnut

         test      byte ptr ds:[Param],1    ; je my¨ nainstalov na ?
         jz        MousOn02                 ; my¨ nen¡ nainstalov na
         test      byte ptr ds:[Param],2    ; je kurzor my¨i zapnut ?
         jz        MousOn04
MousOn02:jmp       MouseOn9

; ------ adresa my¨i ve videopamˆti

MousOn04:mov       ax,SirkaSCR              ; ¨¡©ka obrazovky
         mul       word ptr ds:[MouseY]     ; p©epo‡et linky na offset
         add       ax,ds:[MouseX]           ; p©i‡ten¡ pozice X
         xchg      ax,si                    ; SI <- adresa ve videopamˆti
         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       ax,0a000h
         mov       ds,ax

; ------ £schova podkladu my¨i

         cld
         push      si
         mov       di,offset MousBuff       ; buffer my¨i
         mov       bx,VysMouse              ; v˜¨ka kurzoru my¨i
MouseOn1:mov       cx,SirMouse              ; ¨¡©ka kurzoru my¨i
         rep       movsb                    ; £schova jedn‚ linky
         add       si,SirkaSCR-SirMouse     ; adresa dal¨¡ linky
         dec       bx
         jnz       MouseOn1
         pop       di                       ; adresa ve videopamˆti

; ------ p©¡prava k zobrazen¡ kurzoru

         push      ds
         push      es
         pop       ds                       ; DS <- datov˜ segment
         pop       es                       ; ES <- segment videopamˆti
         mov       bx,VysMouse              ; BX <- v˜¨ka kurzoru my¨i
         mov       cx,SirMouse              ; CX <- ¨¡©ka kurzoru my¨i
         mov       si,offset ObrMouse       ; obr zek kurzoru my¨i
         test      byte ptr ds:[Param],10h  ; je m¢d opravy obrys– ?
         jz        MousOn12
         mov       si,offset ObrMous2       ; kurzor p©i opravˆ obrys–
MousOn12:mov       dl,ds:[AktCol]           ; aktivn¡ barva

; ------ omezen¡ v˜¨ky kurzoru my¨i

         mov       ax,VyskaSCR              ; v˜¨ka obrazovky
         sub       ax,ds:[MouseY]           ; vzd lenost od okraje Y
         cmp       ax,bx                    ; je v˜¨ka OK ?
         jae       MouseOn2                 ; je dost m¡sta
         xchg      ax,bx                    ; BX <- omezen¡ v˜¨ky kurzoru

; ------ omezen¡ ¨¡©ky kurzoru my¨i

MouseOn2:mov       ax,SirkaSCR              ; ¨¡©ka obrazovky
         sub       ax,ds:[MouseX]           ; vzd lenost od okraje X
         cmp       ax,cx
         jae       MouseOn3                 ; je dost m¡sta
         xchg      ax,cx                    ; CX <- omezen¡ ¨¡©ky kurzoru

; ------ ulo‘en¡ obr zku kurzoru

MouseOn3:push      cx
         push      si
         push      di

MouseOn4:lodsb                              ; bajt kurzoru my¨i
         cmp       al,0                     ; je platn˜ bajt ?
         je        MouseOn6                 ; nen¡ platn˜ bajt
         cmp       al,XC                    ; je n hradn¡ bajt ?
         jne       MouseOn5                 ; nen¡ n hradn¡ bajt
         mov       al,dl                    ; n hradn¡ bajt
MouseOn5:stosb                              ; ulo‘en¡ bajtu
         dec       di                       ; n vrat adresy
MouseOn6:inc       di
         loop      MouseOn4                 ; dal¨¡ bajt

         pop       di
         pop       si
         pop       cx

         add       si,SirMouse              ; adresa dal¨¡ linky
         add       di,SirkaSCR              ; adresa dal¨¡ linky
         dec       bx
         jnz       MouseOn3

; ------ p©¡znak zapnut¡ kurzoru my¨i

MouseOn9:or        byte ptr ds:[Param],2    ; p©¡znak zapnut¡ kurzoru my¨i

; ------ n vrat registr–

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

MouseOn  ENDP

; -----------------------------------------------------------------------------
;        vypnut¡ kurzoru my¨i
; -----------------------------------------------------------------------------

MouseOff PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ test, zda m–‘e b˜t kurzor my¨i vypnut

         test      byte ptr ds:[Param],1    ; je my¨ nainstalov na ?
         jz        MouseOf9                 ; my¨ nen¡ nainstalov na
         test      byte ptr ds:[Param],2    ; je kurzor my¨i zapnut ?
         jz        MouseOf9                 ; kurzor my¨i je ji‘ vypnut

; ------ adresa my¨i ve videopamˆti

         mov       ax,SirkaSCR              ; ¨¡©ka obrazovky
         mul       word ptr ds:[MouseY]     ; p©epo‡et linky na offset
         add       ax,ds:[MouseX]           ; p©i‡ten¡ pozice X
         xchg      ax,di                    ; DI <- adresa ve videopamˆti
         mov       ax,0a000h
         mov       es,ax

; ------ n vrat podkladu my¨i

         cld
         mov       si,offset MousBuff       ; buffer my¨i
         mov       bx,VysMouse              ; v˜¨ka kurzoru my¨i
MouseOf2:mov       cx,SirMouse              ; ¨¡©ka kurzoru my¨i
         rep       movsb                    ; £schova jedn‚ linky
         add       di,SirkaSCR-SirMouse     ; adresa dal¨¡ linky
         dec       bx
         jnz       MouseOf2

; ------ p©¡znak vypnut¡ kurzoru my¨i

MouseOf9:and       byte ptr ds:[Param],not 2 ; p©¡znak vypnut¡ kurzoru my¨i

; ------ n vrat registr–

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

MouseOff ENDP

; -----------------------------------------------------------------------------
;        obsluha p©eru¨en¡ od my¨i (CY=je stisk tla‡¡tka my¨i)
; -----------------------------------------------------------------------------

MouseInt PROC      NEAR

; ------ test, zda je my¨ nainstalov na

         test      byte ptr ds:[Param],1    ; je my¨ nainstalov na ?
         jz        MouseIn9                 ; my¨ nen¡ nainstalov na

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx

; ------ ‡ten¡ pohybu my¨i od posledn¡ho vol n¡

         and       byte ptr ds:[Param],not 8 ; nen¡ stisk tla‡¡tka my¨i
         xor       cx,cx                    ; p©ednastaven¡
         xor       dx,dx
         mov       al,0bh
         call      Int33                    ; test pohybu my¨i

; ------ test, zda byla my¨ posunuta

         or        dx,dx                    ; byl vertik ln¡ pohyb ?
         jnz       MouseIn1                 ; byl vertik ln¡ pohyb
         or        cx,cx                    ; byl horizont ln¡ pohyb ?
         jz        MouseIn6                 ; nebyl posun my¨i

; ------ vypnut¡ kurzoru my¨i

MouseIn1:call      MouseOff                 ; vypnut¡ kurzoru my¨i

; ------ nov  pozice my¨i X

         add       cx,ds:[MouseX]           ; nov  sou©adnice X
         jns       MouseIn2                 ; nen¡ podte‡en¡
         xor       cx,cx                    ; omezen¡ p©i podte‡en¡
MouseIn2:cmp       cx,MaxXMous              ; je p©ete‡en¡ ?
         jbe       MouseIn3                 ; nen¡ p©ete‡en¡
         mov       cx,MaxXMous              ; omezen¡ p©i p©ete‡en¡
MouseIn3:mov       ds:[MouseX],cx           ; nov  pozice kurzoru my¨i X

; ------ nov˜ © dek my¨i Y

         add       dx,ds:[MouseY]           ; nov  sou©adnice Y
         jns       MouseIn4                 ; nen¡ podte‡en¡
         xor       dx,dx                    ; omezen¡ p©i podte‡en¡
MouseIn4:cmp       dx,MaxYMous              ; je p©ete‡en¡ ?
         jbe       MouseIn5                 ; nen¡ p©ete‡en¡
         mov       dx,MaxYMous              ; omezen¡ p©i p©ete‡en¡
MouseIn5:mov       ds:[MouseY],dx           ; nov  pozice kurzoru my¨i Y

; ------ nov‚ zobrazen¡ kurzoru

         call      MouseOn                  ; zapnut¡ kurzoru na nov‚ pozici

; ------ nastaven¡ pozice kurzoru my¨i na nov˜ch sou©adnic¡ch DX/CX

         mov       al,4
         call      Int33                    ; nastaven¡ pozice kurzoru my¨i

; ------ my¨ nebyla posunuta - obsluha tla‡¡tek my¨i

MouseIn6:xor       bx,bx                    ; p©ednastaven¡
         mov       al,3
         call      Int33                    ; ‡ten¡ tla‡¡tek my¨i
         test      bl,7                     ; je stisk tla‡¡tka ?
         jnz       MouseIn7                 ; je stisk tla‡¡tka
         and       byte ptr ds:[Param],not 4 ; nen¡ tla‡¡tko my¨i
         jmp       short MouseIn8

MouseIn7:mov       al,ds:[Param]            ; parametry
         or        byte ptr ds:[Param],4    ; p©¡znak tla‡¡tka my¨i
         test      al,4                     ; bylo tla‡¡tko ji‘ stisknuto ?
         jnz       MouseIn8                 ; tla‡¡tko bylo ji‘ stisknuto
         or        byte ptr ds:[Param],8    ; p©¡znak stisku tla‡¡tka my¨i
         stc                                ; p©¡znak stisku tla‡¡tka my¨i

; ------ n vrat registr–

MouseIn8:pop       dx
         pop       cx
         pop       bx
         pop       ax
MouseIn9:ret

MouseInt ENDP

; -----------------------------------------------------------------------------
;        vol n¡ obsluhy INT 33h (obsluha my¨i)
; -----------------------------------------------------------------------------

Int33    PROC      NEAR

         pushf
         push      si
         push      di
         push      bp
         push      ds
         push      es

         mov       ah,0
         int       33h

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         popf
         ret

Int33    ENDP

; *****************************************************************************
;
;                                       data
;
; *****************************************************************************
;þ
MemTxt   db        'Nedostatek pameti ke spusteni programu !',13,10,'$'
CardTxt  db        'Lituji, program vyzaduje grafickou kartu VGA !',13,10,'$'
UvTxt    db        'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»',13,10
         db        'º                        VYBARVI                   v 1.1 º',13,10
         db        'º            vybarvovani obrazku pro nejmensi            º',13,10
         db        'º                  (c) Miroslav Nemecek                  º',13,10
         db        'ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹',13,10
         db        'º Program  VYBARVI  slouzi k vybarvovani barevnych ploch º',13,10
         db        'º obrazku  ve  formatu PCX (soubory nacitany z aktivniho º',13,10
         db        'º adresare). Obrazky se importuji na format 320x180/256. º',13,10
         db        'º Soubory  lze  chranit  proti modifikaci atributem R/O. º',13,10
         db        'º Program  vyzaduje  grafickou kartu VGA a 32 KB pameti. º',13,10
         db        'ºÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº',13,10
         db        'º                ESC = preruseni programu                º',13,10
         db        'º          sipky vlevo a vpravo = volba obrazku          º',13,10
         db        'º       Ctrl-F1 = navrat provedenych zmen v obrazku      º',13,10
         db        'º           Ctrl-F5 = mod opravy obrysu obrazku          º',13,10
         db        'º               Ctrl-F9 = odbarveni obrazku              º',13,10
         db        'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼',13,10
         db        'Tento program je FREEWARE = lze jej neomezene volne sirit.',13,10
         db        '      Stisknete libovolnou klavesu, ESC=preruseni...',13,10
         db        '$'

AllPCX   db        '*.PCX',0                ; specifikace soubor– k hled n¡
NoNamPCX db        'NONAME.PCX',0,0,0,0
OutSoub  db        '.\            ',0       ; jm‚no v˜stupn¡ho souboru

; ------ parametry

Param    db        0                        ; parametry
                                            ;   bit 0: 1=je my¨
                                            ;   bit 1: 1=kurzor my¨i zapnut
                                            ;   bit 2: 1=je tla‡¡tko my¨i
                                            ;   bit 3: 1=je stisk tla‡¡tka my¨i
                                            ;   bit 4: 1=m¢d opravy obrys–
                                            ;   bit 6: 1=je soubor NONAME
                                            ;   bit 7: 1=modifikov n soubor
MouseX   dw        SirkaSCR/2               ; sou©adnice my¨i X
MouseY   dw        VyskaSCR/2               ; sou©adnice my¨i Y
AktCol   db        BILA                     ; ‡¡slo aktivn¡ barvy

AktSoubA dw        0                        ; adresa jm‚na aktivn¡ho souboru
AktSoub  dw        0                        ; aktivn¡ soubor 0...
NumSoub  dw        0                        ; po‡et soubor– v tabulce
SoubIdnt dw        0                        ; identifik tor souboru
KoefXLow dw        0                        ; zkr cen¡ X - desetinn  ‡ st
KoefXHgh dw        1                        ; zkr cen¡ X - cel  ‡ st
KoefYLow dw        0                        ; zkr cen¡ Y - desetinn  ‡ st
KoefYHgh dw        1                        ; zkr cen¡ Y - cel  ‡ st

ReadAX   dw        0                        ; uschovan˜ registr AX p©i na‡¡t n¡
ReadBX   dw        0                        ; uschovan˜ registr BX p©i na‡¡t n¡
ReadSI   dw        0                        ; uschovan˜ registr SI p©i na‡¡t n¡

; ------ obr zek pastelky

ObrBar   db         0, 0,XC, 0, 0, 0
         db         0,XC,XC,XC, 0, 0
         db        XC,XC,XC,XC,XC, 0
         db        XC,XC,XC,XC,XC, 0
         db        XC,XC,XC,XC,XC, 0
         db        XC,XC,XC,XC,XC, 0
         db        XC,XC,XC,XC,XC, 0
         db        XC,XC,XC,XC,XC, 0
         db        XC,XC,XC,XC,XC, 0
         db        15,15,15,15,15, 0
         db        12,12,12,12,12, 0
         db        12,15,15,15,15, 0
         db        15,15,15,12,15, 0
         db        12,12,12,15,12, 0
         db        12,12,15,12,15, 0
         db        15,12,12,15,12, 0
         db        12,12,15,15,12, 0
         db        12,12,15,12,12, 0
         db        15,15,15,15,15, 0
         db        XC,XC,XC,XC,XC, 0

; ------ obr zek kurzoru my¨i

ObrMouse db        XC,32,32,32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
         db        32,XC,XC,XC,32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
         db        32,XC,XC,XC,XC,32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
         db        32,XC,XC,XC,XC,XC,32, 0, 0, 0, 0, 0, 0, 0, 0, 0
         db         0,32,XC,XC,XC,15,12,32, 0, 0, 0, 0, 0, 0, 0, 0
         db         0, 0,32,XC,15,12,12,15,32, 0, 0, 0, 0, 0, 0, 0
         db         0, 0, 0,32,12,12,15,15,12,32, 0, 0, 0, 0, 0, 0
         db         0, 0, 0, 0,32,15,15,15,15,15,32, 0, 0, 0, 0, 0
         db         0, 0, 0, 0, 0,32,15,12,15,12,15,32, 0, 0, 0, 0
         db         0, 0, 0, 0, 0, 0,32,15,12,12,15,15,32, 0, 0, 0
         db         0, 0, 0, 0, 0, 0, 0,32,12,12,15,12,12,32, 0, 0
         db         0, 0, 0, 0, 0, 0, 0, 0,32,12,15,15,15,XC,32, 0
         db         0, 0, 0, 0, 0, 0, 0, 0, 0,32,12,15,XC,XC,32, 0
         db         0, 0, 0, 0, 0, 0, 0, 0, 0, 0,32,XC,XC,32, 0, 0
         db         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,32,32, 0, 0, 0
         db         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

; ------ obr zek kurzoru my¨i - opravy obrys–

ObrMous2 db         0,32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
         db        32,15,32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
         db        32,15,15,32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
         db        32,15,15,15,32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
         db        32,15,15,15,15,32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
         db        32,15,15,15,15,15,32, 0, 0, 0, 0, 0, 0, 0, 0, 0
         db         0,32,15,15,15,15,15,32, 0, 0, 0, 0, 0, 0, 0, 0
         db         0, 0,32,15,15,15,15,15,32,32, 0, 0, 0, 0, 0, 0
         db         0, 0, 0,32,15,15,15,15,32,32,32, 0, 0, 0, 0, 0
         db         0, 0, 0, 0,32,32,32,32,32,32,32,32, 0, 0, 0, 0
         db         0, 0, 0, 0, 0, 0, 0,32,32,32,32,32,32, 0, 0, 0
         db         0, 0, 0, 0, 0, 0, 0, 0,32,32,32,32,10, 9, 0, 0
         db         0, 0, 0, 0, 0, 0, 0, 0, 0,32,32,10, 9,12,32, 0
         db         0, 0, 0, 0, 0, 0, 0, 0, 0, 0,10, 9,12,32,32, 0
         db         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,12,32,32,32, 0
         db         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,32,32, 0, 0

; ------ obr zek ¨ipek

ObrSipek db         0, 0, 0, 0, 0, 7, 7, 0, 0, 0, 0, 0, 6, 6, 0, 0, 0, 0, 0, 7, 7
         db         0, 0, 0, 0, 7,15, 7, 0, 0, 0, 0, 6,14, 6, 0, 0, 0, 0, 7,15, 7
         db         0, 0, 0, 7,15,15, 7, 0, 0, 0, 6,14,14, 6, 0, 0, 0, 7,15,15, 7
         db         0, 0, 7,15,15,15, 7, 0, 0, 6,14,14,14, 6, 0, 0, 7,15,15,15, 7
         db         0, 7,15,15,15,15, 7, 0, 6,14,14,14,14, 6, 0, 7,15,15,15,15, 7
         db         7,15,15,15,15,15, 7, 6,14,14,14,14,14, 6, 7,15,15,15,15,15, 7
         db         0, 7,15,15,15,15, 7, 0, 6,14,14,14,14, 6, 0, 7,15,15,15,15, 7
         db         0, 0, 7,15,15,15, 7, 0, 0, 6,14,14,14, 6, 0, 0, 7,15,15,15, 7
         db         0, 0, 0, 7,15,15, 7, 0, 0, 0, 6,14,14, 6, 0, 0, 0, 7,15,15, 7
         db         0, 0, 0, 0, 7,15, 7, 0, 0, 0, 0, 6,14, 6, 0, 0, 0, 0, 7,15, 7
         db         0, 0, 0, 0, 0, 7, 7, 0, 0, 0, 0, 0, 6, 6, 0, 0, 0, 0, 0, 7, 7

; ------ z hlav¡ PCX pro z pis

HeadPCXW label     byte                     ; z hlav¡ PCX pro z pis
         db        10                       ; 0: identifikace souboru
         db        5                        ; 1: verze soub. 3.0 s paletou 3*256
         db        1                        ; 2: metoda k¢dov n¡ PCX
         db        8                        ; 3: po‡et bit–/bod v jedn‚ rovinˆ
         dw        0                        ; 4: po‡ te‡n¡ sou©adnice X1
         dw        0                        ; 6: po‡ te‡n¡ sou©adnice Y1
         dw        SIRKA-1                  ; 8: koncov  sou©adnice X2
         dw        VYSKA-1                  ; 10: koncov  sou©adnice Y2
         dw        SirkaSCR                 ; 12: horiz. rozli¨itelnost displeje
         dw        VyskaSCR                 ; 14: vert. rozli¨itelnost displeje
                                            ; 16: paleta barev (nepou‘ito)
PCXEgaW  db           0,   0,   0           ;        ‡ern 
         db           0,   0,4*42           ;        modr 
         db           0,4*42,   0           ;        zelen 
         db           0,4*42,4*42           ;        modrozelen 
         db        4*42,   0,   0           ;        ‡erven 
         db        4*42,   0,4*42           ;        purpurov 
         db        4*42,4*21,   0           ;        hnˆd 
         db        4*42,4*42,4*42           ;        b¡l 
         db        4*21,4*21,4*21           ;        ¨ed 
         db        4*21,4*21,4*63           ;        svˆtle modr 
         db        4*21,4*63,4*21           ;        svˆtle zelen 
         db        4*21,4*63,4*63           ;        svˆtle modrozelen 
         db        4*63,4*21,4*21           ;        svˆtle ‡erven 
         db        4*63,4*21,4*63           ;        svˆtle purpurov 
         db        4*63,4*63,4*21           ;        ‘lut 
         db        4*63,4*63,4*63           ;        svˆtle b¡l 

         db        0                        ; 64: ... nevyu‘ito
         db        1                        ; 65: po‡et barevn˜ch rovin
         dw        320                      ; 66: po‡et bajt– na © dek obr zku
         dw        1                        ; 68: interpretace palety barev
         db        58 dup(0)                ; 70: ... nevyu‘ito
HeaPCXW0 label     byte

; ------ vlastn¡ paleta barev (‡erven , zelen , modr )

TabPal0  db        12                       ; oddˆlova‡ palet (zachovat po©ad¡ !)
TabPal   label     byte                     ; tabulka vlastn¡ch palet

; standardn¡ barvy (0 a‘ 15)
         db         0, 0, 0                 ; ‡ern 
         db         0, 0,42                 ; modr 
         db         0,42, 0                 ; zelen 
         db         0,42,42                 ; modrozelen 
         db        42, 0, 0                 ; ‡erven 
         db        42, 0,42                 ; purpurov 
         db        42,21, 0                 ; hnˆd 
         db        42,42,42                 ; b¡l 
         db        21,21,21                 ; ¨ed 
         db        21,21,63                 ; svˆtle modr 
         db        21,63,21                 ; svˆtle zelen 
         db        21,63,63                 ; svˆtle modrozelen 
         db        63,21,21                 ; svˆtle ‡erven 
         db        63,21,63                 ; svˆtle purpurov 
         db        63,63,21                 ; ‘lut 
         db        63,63,63                 ; svˆtle b¡l 

; standardn¡ ¨ed  (16 a‘ 31)
         db        0,0,0
         db        5,5,5
         db        8,8,8
         db        11,11,11
         db        14,14,14
         db        17,17,17
         db        20,20,20
         db        24,24,24
         db        28,28,28
         db        32,32,32
         db        36,36,36
         db        40,40,40
         db        45,45,45
         db        50,50,50
         db        56,56,56
         db        63,63,63

; ------ definovan‚ barvy (32...)
;þ
         db         0, 0, 0                 ; 32: ‡ern  (pro obrysy)
         db        22,22,22                 ; 33: tmavˆ ¨ed 
         db        32,32,32                 ; 34: ¨ed 
         db        44,44,44                 ; 35: svˆtle ¨ed 
         db        56,56,56                 ; 36:
         db        63,63,63                 ; 37: b¡l 

         db        34, 0, 0                 ; tmavˆ ‡erven 
         db        48, 0, 0                 ; ‡erven 
         db        63, 0, 0                 ; ‡erven 
         db        63,30,30                 ; svˆtle ‡erven 
         db        63,45,45                 ; r–‘ov 

         db        63,49,34                 ; bˆ‘ov 

         db        63,42, 0                 ; oran‘ov 
         db        63,50,18                 ; svˆtle oran‘ov 
         db        57,51, 0                 ; tmavˆ ‘lut 
         db        63,63, 0                 ; ‘lut 
         db        63,63,42                 ; svˆtle ‘lut 

         db         0, 0,34                 ; tmavˆ modr 
         db         0, 0,47
         db         0, 0,63                 ; modr 
         db        10,36,63                 ; svˆtle modr 
         db        21,51,63                 ; svˆtle modr 
         db         0,63,63                 ; modrozelen 
         db         0,42,42                 ; tmavˆ modrozelen 

         db        27, 0,32                 ; je¨tˆ tmav¨¡ purpurov 
         db        42, 0,42                 ; tmavˆ purpurov 
         db        63, 0,63                 ; purpurov 
         db        63,42,63                 ; svˆtle purpurov 
         db        63, 0,42                 ; mod©e purpurov 

         db         0,30, 0                 ; je¨tˆ tmav¨¡ zelen 
         db         0,42, 0                 ; tmavˆ zelen 
         db         0,63, 0                 ; zelen 
         db        40,63,40                 ; svˆtle zelen 
         db        48,63,10                 ; ‘lutozelen 
         db        30,35, 0                 ; tmavˆ ‘lutozelen 

         db        32,15, 0                 ; tmavˆ hnˆd  (ka‘tanov )
         db        40,22, 0                 ; hnˆd 
         db        50,30, 0                 ; hnˆd 
         db        63,32, 0                 ; svˆtlej¨¡ hnˆd 
         db        63,42,21                 ; svˆtle hnˆd 

         db        38,34,22                 ; ¨edohnˆd 

         db        3*(256-TopCol-NumCols) dup(0)

; ------ na‡ten‚ z hlav¡ PCX

PCXSirka dw        ?                        ; vypo‡ten  ¨¡©ka obr zku
PCXVyska dw        ?                        ; vypo‡ten  v˜¨ka obr zku

HeadPCX  label     byte                     ; na‡ten‚ z hlav¡ PCX
PCXIdent db        ?                        ; 0: identifikace souboru
PCXVerze db        ?                        ; 1: verze soub. 3.0 s paletou 3*256
PCXMetod db        ?                        ; 2: metoda k¢dov n¡ PCX
PCXBits  db        ?                        ; 3: po‡et bit–/bod v jedn‚ rovinˆ
PCXX1    dw        ?                        ; 4: po‡ te‡n¡ sou©adnice X1
PCXY1    dw        ?                        ; 6: po‡ te‡n¡ sou©adnice Y1
PCXX2    dw        ?                        ; 8: koncov  sou©adnice X2
PCXY2    dw        ?                        ; 10: koncov  sou©adnice Y2
PCXHoriz dw        ?                        ; 12: horiz. rozli¨itelnost displeje
PCXVert  dw        ?                        ; 14: vert. rozli¨itelnost displeje
PCXEga   db        3*16 dup(?)              ; 16: paleta barev EGA
         db        ?                        ; 64: ... nevyu‘ito
PCXRovin db        ?                        ; 65: po‡et barevn˜ch rovin
PCXByte  dw        ?                        ; 66: po‡et bajt– na © dek obr zku
PCXInter dw        ?                        ; 68: interpretace palety barev
         db        58 dup(?)                ; 70: ... nevyu‘ito
HeadPCX0 label     byte

PCXVgaX  db        ?                        ; m¡sto pro oddˆlova‡ palet 12

PCXVga   db        3*256 dup(?)             ; na‡ten  paleta barev VGA
                                            ; (1) ‡erven  0 a‘ 255
                                            ; (1) zelen  0 a‘ 255
                                            ; (1) modr  0 a‘ 255

BuffSoub db        MaxSoub*14 dup(?)        ; buffer jmen soubor– ASCIIZ

TabDTA   db        43 dup(?)                ; tabulka DTA pro hled n¡ soubor–

Linka    db        MaxSirX dup(?)           ; buffer na‡ten‚ linky obr zku

KonvPal  db        256 dup(?)               ; konverzn¡ tabulka palet

MousBuff db        SirMouse*VysMouse dup(?) ; buffer k £schovˆ my¨i

Buffer   db        BUFFSIZE dup(?)          ; vstupnˆ/v˜stupn¡ buffer
Buffer0  label     byte

         dw        200 dup(?)               ; je¨tˆ mal  rezerva
Zasobnik label     word                     ; minimum pro z sobn¡k
         dw        4000 dup(?)              ; rezerva pro z sobn¡k
                                            ; (pro vno©en¡ p©i vybarvov n¡)

Konec    label     byte                     ; konec programu

Code     ENDS
         END       Start


; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                              U N D E L E T E
;
;                              Obnoven¡ soubor–
;
; =============================================================================
;
;
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

INCLUDE  ASM\DEF.ASM

CodeUnd  SEGMENT   BYTE PUBLIC
         ASSUME    cs:CodeUnd,ds:Data

; *****************************************************************************
;                                   Undelete
;                           obsluha obnoven¡ soubor–
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; *****************************************************************************

Undelete PROC      FAR

; ------ kontrola, zda je operace povolena

         test      byte ptr ds:[SMnuVBlk+9],bit0 ; povoleno obnoven¡ soubor– ?
         jnz       Undel0                   ; z kaz operace

; ------ inicializace ukazatel–

         xor       ax,ax                    ; AX <- 0
         mov       ds:[UndParm],al          ; nulov n¡ parametr–
         mov       ds:[UndAdrS],ax          ; velikost segm. adres ©e celkem
         mov       ds:[UndInfS],ax          ; velikost segmentu informac¡
         mov       ds:[UndNum],ax           ; po‡et zobrazen˜ch polo‘ek
         mov       ds:[UndKurz],ax          ; kurzor v seznamu
         mov       ds:[UndTop],ax           ; po‡ te‡n¡ zobrazen  polo‘ka

         call      far ptr CreatSeg         ; vytvo©en¡ segmentu adres ©e
         jc        Undel0                   ; chyba
         mov       ds:[UndInf],ax           ; ‡¡slo segmentu informac¡

         call      far ptr CreatSeg         ; vytvo©en¡ segmentu adres ©e
         jc        Undel0                   ; chyba
         mov       ds:[UndAdr],ax           ; ‡¡slo segmentu adres ©e

         call      far ptr CreatSeg         ; vytvo©en¡ segmentu index–
         mov       ds:[UndInd],ax           ; ‡¡slo segmentu index–
         jnc       Undel01                  ; OK

Undel0:  jmp       Undel9

; ------ otev©en¡ okna menu obnoven¡ soubor–

Undel01: call      far ptr ClosMnuA         ; uzav©en¡ v¨ech menu
         mov       si,offset UndMnLin       ; menu obnoven¡ soubor–
         call      far ptr OpenMnu          ; otev©en¡ okna menu
         call      far ptr KurzOff          ; vypnut¡ kurzoru

; ------ inicializace parametr– disku

         call      far ptr InitLDsk         ; inicializace parametr– log. disku
         jc        Undel0

; ------ otev©en¡ bufferu tabulky FAT

         call      far ptr OpenLFat         ; otev©en¡ bufferu tabulky FAT
         jc        Undel0

; ------ stanoven¡ aktivn¡ho aloka‡n¡ho bloku

         call      far ptr GetAClus         ; poskytnut¡ aktivn¡ho alok. bloku
         jc        Undel0
         mov       ds:[UndAClus],ax         ; ‡¡slo po‡ te‡n¡ho alok. bloku

; ------ na‡ten¡ obsahu eviden‡n¡ho souboru

         call      UndSLoad                 ; na‡ten¡ eviden‡n¡ho souboru
         jc        Undel0


; ****** zde kon‡¡ p©¡stup DOS a za‡¡n  obsluha pomoc¡ INT 25h/26h !

         call      far ptr ResDisk          ; resetov n¡ diskov‚ho syst‚mu

; ------ na‡ten¡ obsahu aktivn¡ho adres ©e do bufferu

         call      UndALoad                 ; na‡ten¡ aktivn¡ho adres ©e
         jc        Undel0                   ; nˆjak  chyba
         call      UndAInd                  ; inicializace tabulky index–
         jc        Undel0                   ; nˆjak  chyba
         call      UndSInd                  ; inicializace index– seznamu
         jc        Undel0                   ; nˆjak  chyba

; ------ ovˆ©en¡ obnovitelnosti soubor–

         call      UndSTest                 ; test souboru z evidence
         call      UndATest                 ; test soubor– z adres ©e
         or        byte ptr ds:[UndParm],bit0 ; p©¡znak na‡ten¡ informac¡

; ------ zobrazen¡ okna

Undel4:  mov       si,offset UndMnLin
         call      far ptr DispMnu

; ------ nastaven¡ pozice kurzoru

         mov       dx,word ptr ds:[si+MnuPoz]        ; pozice a © dek okna
         add       dx,303h                  ; korekce
         add       dh,byte ptr ds:[UndKurz] ; kurzor
         sub       dh,byte ptr ds:[UndTop]  ; offset od po‡ tku
         call      far ptr SetKurz          ; nastaven¡ kurzoru

; ------ ‡ek n¡ na zad n¡ znaku

Undel62: call      far ptr InpChar
         jc        Undel8                   ; p©eru¨en¡ ESC

; ------ p©eru¨en¡ operace my¨¡

         cmp       bh,MousXKod/HI           ; je k¢d my¨i ?
         jne       Undel65                  ; nen¡ k¢d my¨i
         cmp       bl,MousXRP               ; je stisk prav‚ho tla‡¡tka ?
         je        Undel8                   ; p©eru¨en¡ prav˜m tla‡¡tkem
         cmp       bl,MousXLP               ; je stisk lev‚ho tla‡¡tka ?
         jne       Undel63                  ; nen¡ stisk lev‚ho tla‡¡tka
         call      far ptr MouseMnu         ; test, zda je kurzor my¨i v oknˆ
         jc        Undel8                   ; p©eru¨en¡ stiskem mimo okno
Undel63: cmp       bl,MousXLD               ; dvoj¡ stisk lev‚ho tla‡¡tka ?
         jne       Undel68                  ; nen¡ dvoj¡ stisk lev‚ho tla‡¡tka
         mov       bl,CR                    ; n hrada kl vesou ENTER

; ------ rozli¨en¡, zda je platn˜ znak

Undel65: cmp       bl,CR
         je        Undel66                  ; ENTER - automatick‚ ur‡en¡
         cmp       bl," "
         jbe       Undel7                   ; neplatn˜ znak
Undel66: call      UndObn                   ; obnoven¡ aktivn¡ polo‘ky
         jmp       short Undel4             ; dal¨¡ kl vesa

; ------ obsluha okna

Undel68: mov       bl,MousXMov              ; n hradn¡ k¢d pro veden¡ my¨i
Undel7:  push      cs
         call      near ptr EditUMnu
         jmp       short Undel4

; ------ p©eru¨en¡ operace ESC

Undel8:
         call      far ptr ResDisk          ; resetov n¡ diskov‚ho syst‚mu

; ------ zru¨en¡ segment– a uzav©en¡ okna

Undel9:  mov       ax,ds:[UndInf]
         call      far ptr DelSeg           ; zru¨en¡ bloku informac¡
         mov       ds:[UndInf],ax

         mov       ax,ds:[UndAdr]
         call      far ptr DelSeg           ; zru¨en¡ bloku adres ©e
         mov       ds:[UndAdr],ax

         mov       ax,ds:[UndInd]
         call      far ptr DelSeg           ; zru¨en¡ bloku index–
         mov       ds:[UndInd],ax

         call      far ptr ClosLFat         ; uzav©en¡ bufferu s FAT tabulkou

         call      far ptr ClosMnuA         ; uzav©en¡ okna

         test      byte ptr ds:[UndParm],bit2
         jz        Undel992

         jmp       far ptr AWCtrlN

Undel992:jmp       far ptr Main0

Undelete ENDP

; -----------------------------------------------------------------------------
;                                UndObn
;                      obnoven¡ aktivn¡ polo‘ky
; -----------------------------------------------------------------------------
; VSTUP: BL=kl vesa (".", "?" nebo 13 = automatick  volba p¡smene)
;        DS=datov˜ segment
; -----------------------------------------------------------------------------
; lok ln¡ promˆnn‚: SS:[BP-1] (1) p©¡znaky
;                                     bit 0: 1=existuje adres ©ov  polo‘ka
;                                     bit 1: 1=existuje informa‡n¡ polo‘ka
;                                     bit 2: 1=je uschov n p–vodn¡ znak
;                                     bit 3: 1=p©ednastaven znak z inform. pol.
;                                     bit 4: 1=je automatick  volba
;                                     bit 5: 1=nalezen prvn¡ voln˜ blok
;                                     bit 6: 1=je spojit˜ £sek blok–
;                                     bit 7: 1=posledn¡ blok byl voln˜
;                   SS:[BP-2] (1) uschovan˜ p–vodn¡ znak polo‘ky
;                   SS:[BP-4] (2) uschovan  adresa adres ©ov‚ polo‘ky
;                   SS:[BP-6] (2) uschovan  adresa informa‡n¡ polo‘ky
;                   SS:[BP-8] (2) adresa pracovn¡ polo‘ky (se zmˆnˆn˜m znakem)
;                   SS:[BP-10] (2) segment adres ©e
;                   SS:[BP-14] (4) zb˜vaj¡c¡ velikost polo‘ky k obnoven¡
;                   SS:[BP-16] (2) ‡¡ta‡ blok– k obnoven¡
;                   SS:[BP-18] (2) ukazatel polo‘ek bloku (v informa‡n¡ polo‘ce)
;                   SS:[BP-20] (2) ‡¡slo bloku
;                   SS:[BP-22] (2) ‡¡ta‡ spojit‚ho £seku blok–
;                   SS:[BP-24] (2) uschovan‚ ‡¡slo minul‚ho bloku (0=nebylo)
;                   SS:[BP-26] (2) ‡¡ta‡ polo‘ek blok– v informa‡n¡ polo‘ce
; -----------------------------------------------------------------------------
;þ
UndObn   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp
         sub       sp,26

; ------ £schova zadan‚ho znaku

         mov       byte ptr ss:[bp-1],0     ; nulov n¡ p©¡znak–
         mov       ss:[bp-2],bl             ; £schova zadan‚ho znaku

; ------ segment adres ©e

         mov       ax,ds:[UndAdr]           ; ‡¡slo segmentu adres ©e
         call      far ptr GetSgAdr
         mov       ss:[bp-10],dx            ; segment adres ©e

; ------ adresa indexu aktivn¡ polo‘ky

         mov       di,ds:[UndKurz]          ; kurzor
         cmp       di,ds:[UndNum]           ; je platn‚ ‡¡slo kurzoru ?
         jb        UndObn10                 ; kurzor je OK
         jmp       UndObn9                  ; nen¡ platn‚ ‡¡slo kurzoru
UndObn10:shl       di,1
         shl       di,1
         add       di,ds:[UndKurz]          ; kurzor * 5 = offset indexu
         mov       ax,ds:[UndInd]           ; ‡¡slo segmentu index–
         call      far ptr GetDat           ; ES <- adresa segmentu index–

; ------ inicializace parametr– polo‘ky

         mov       al,es:[di]               ; parametry polo‘ky
         and       al,bit0+bit1             ; pouze pot©ebn‚ p©¡znaky
         mov       ss:[bp-1],al             ; p©¡prava p©¡znak–

; ------ adresa informa‡n¡ polo‘ky

         test      al,bit1                  ; je informa‡n¡ polo‘ka ?
         jz        UndObn11                 ; nen¡ informa‡n¡ polo‘ka
         mov       ax,ds:[UndInf]           ; informa‡n¡ segment
         call      far ptr GetSgAdr         ; adresa segmentu informac¡
         add       dx,es:[di+3]             ; informa‡n¡ polo‘ka
         mov       ss:[bp-6],dx             ; adresa informa‡n¡ polo‘ky

; ------ adresa adres ©ov‚ polo‘ky

UndObn11:test      byte ptr es:[di],bit0    ; je adres ©ov  polo‘ka ?
         jz        UndObn12                 ; nen¡ adres ©ov  polo‘ka
         mov       dx,ss:[bp-10]            ; segment adres ©e
         add       dx,es:[di+1]             ; adres ©ov  polo‘ka
         mov       ss:[bp-4],dx             ; adresa adres ©ov‚ polo‘ky

; ------ adresa pracovn¡ polo‘ky

UndObn12:mov       es,dx                    ; ES <- adresa pracovn¡ polo‘ky
         mov       ss:[bp-8],dx             ; adresa pracovn¡ polo‘ky

; ------ £schova p–vodn¡ho znaku

         xor       si,si                    ; SI <- 0
         mov       ah,es:[si]               ; prvn¡ znak polo‘ky
         xchg      ah,ss:[bp-2]             ; £schova p–vodn¡ho znaku
         or        byte ptr ss:[bp-1],bit2  ; p©¡znak £schovy prvn¡ho znaku

; ------ test, zda m  b˜t implicitn¡ znak

         mov       al,ah                    ; zadan˜ znak
         cmp       ah,"."
         je        UndObn13                 ; je implicitn¡ znak
         cmp       ah,"?"
         je        UndObn13
         cmp       ah,13
         jne       UndObn15

; ------ stanoven¡ implicitn¡ho znaku

UndObn13:mov       al,"1"                   ; implicitn¡ znak, nen¡-li inf.
         test      byte ptr ss:[bp-1],bit1  ; je informa‡n¡ segment ?
         jz        UndObn14                 ; nen¡ informa‡n¡ segment
         push      es
         mov       es,ss:[bp-6]             ; adresa informa‡n¡ polo‘ky
         mov       al,es:[si]               ; prvn¡ znak informa‡n¡ polo‘ky
         pop       es
         cmp       ah,13                    ; je ENTER ?
         je        UndObn15                 ; je ENTER - nen¡ automat.
         or        byte ptr ss:[bp-1],bit3  ; p©¡znak znaku z inf. polo‘ky
UndObn14:or        byte ptr ss:[bp-1],bit4  ; p©¡znak automatick‚ volby

; ------ test, zda je znak povolen˜, ulo‘en¡ znaku

UndObn15:call      far ptr SUpCase          ; konverze znaku na velk‚ p¡smeno
         cmp       al," "
         jbe       UndObn19
         cmp       al,"*"
         je        UndObn19
         cmp       al,"?"
         je        UndObn19

         push      ds

         mov       bx,SEG CodeDek
         mov       ds,bx
         mov       bl,al                    ; BL <- zadan˜ znak
         mov       bh,0

         ASSUME    ds:CodeDek
         test      byte ptr ds:[bx+TabTypCh],bit3 ; je znak povolen ?
         ASSUME    ds:Data

         pop       ds

         jnz       UndObn1A                 ; znak je povolen OK
UndObn19:jmp       UndObn9
UndObn1A:mov       es:[si],al               ; nastaven¡ prvn¡ho znaku

; ------ test, zda polo‘ka ES ji‘ existuje

UndObn2: xor       bx,bx                    ; offset v segmentu adres ©e
         mov       dx,es                    ; segment testovan‚ polo‘ky
         cld
UndObn21:cmp       bx,ds:[UndAdrS]          ; je ji‘ konec adres ©e ?
         jae       UndObn3                  ; polo‘ka nenalezena OK

         mov       ax,bx                    ; offset polo‘ky k porovn n¡
         add       ax,ss:[bp-10]            ; adresa polo‘ky k porovn n¡
         cmp       ax,dx                    ; je to stejn  polo‘ka ?
         je        UndObn22                 ; je to stejn  polo‘ka

         push      ds
         mov       ds,ax                    ; DS <- porovn van  polo‘ka
         xor       si,si
         xor       di,di
         mov       cx,11                    ; d‚lka jm‚na s p©¡ponou
         repe      cmpsb                    ; porovn n¡ polo‘ek
         pop       ds
         je        UndObn24                 ; polo‘ka ji‘ existuje
UndObn22:inc       bx
         inc       bx                       ; adresa dal¨¡ polo‘ky
         jmp       short UndObn21           ; test dal¨¡ polo‘ky

; ------ polo‘ka ji‘ existuje - dal¨¡ pokus

UndObn24:test      byte ptr ss:[bp-1],bit4  ; je automatick  volba ?
         jz        UndObn19                 ; nen¡ automatick  volba
         test      byte ptr ss:[bp-1],bit3  ; je p©ednastaven˜ znak ?
         jz        UndObn25                 ; nen¡ p©ednastaven˜ znak
         and       byte ptr ss:[bp-1],not bit3 ; zru¨en¡ p©¡znaku p©ednast.znaku
         mov       al,"1"                   ; implicitn¡ prvn¡ znak
         jmp       short UndObn27           ; nov˜ test polo‘ky

UndObn25:mov       al,es:[0]
         inc       ax                       ; zv˜¨en¡ ukazatele znaku
         cmp       al,"9"+1                 ; p©ete‡en¡ ‡¡sla ?
         jne       UndObn26                 ; nen¡ p©ete‡en¡ ‡¡sla
         mov       al,"A"                   ; korekce na p¡smeno
UndObn26:cmp       al,"Z"+1                 ; p©ete‡en¡ p¡smene ?
         jae       UndObn19                 ; nelze nal‚zt polo‘ku

UndObn27:mov       es:[0],al                ; ulo‘en¡ znaku
         jmp       short UndObn2            ; nov˜ test polo‘ky

; ------ p©¡prava ‡¡ta‡e velikosti polo‘ky

UndObn3: mov       ax,-1
         mov       dx,ax
         mov       ss:[bp-12],dx            ; velikost HIGH
         mov       ss:[bp-14],ax            ; velikost LOW
         mov       ss:[bp-16],ax            ; ‡¡ta‡ blok–
         test      byte ptr es:[11],DIR     ; je to adres © ?
         jnz       UndObn32                 ; je to adres ©
         mov       ax,es:[28]               ; velikost LOW
         mov       dx,es:[30]               ; velikost HIGH
         mov       ss:[bp-12],dx            ; velikost HIGH
         mov       ss:[bp-14],ax            ; velikost LOW
         mov       cx,ds:[DskLBBlk]         ; po‡et bajt– na aloka‡n¡ blok
         dec       cx
         add       ax,cx                    ; zaokrouhlen¡ nahoru
         adc       dx,0
         jc        UndObn32
         inc       cx
         cmp       dx,cx
         jae       UndObn32
         div       cx                       ; v˜po‡et po‡tu blok–
         mov       ss:[bp-16],ax            ; po‡et blok– k obnoven¡

; ------ p©¡prava ukazatele blok–

UndObn32:mov       word ptr ss:[bp-18],34   ; ukazatel polo‘ek ‡¡sel blok–
         test      byte ptr ss:[bp-1],bit1  ; je informa‡n¡ polo‘ka ?
         jz        UndOb322                 ; nen¡ informa‡n¡ polo‘ka
         push      es
         mov       es,ss:[bp-6]             ; adresa informa‡n¡ polo‘ky
         mov       ax,es:[16]               ; po‡et polo‘ek aloka‡n¡ch blok–
         or        ax,ax
         jz        UndOb321
         dec       ax
UndOb321:mov       ss:[bp-26],ax            ; ‡¡ta‡ polo‘ek blok–
         pop       es
UndOb322:mov       bx,es:[26]               ; po‡ te‡n¡ aloka‡n¡ blok
         mov       ss:[bp-20],bx            ; ‡¡slo prvn¡ho bloku

; ------ test, zda je voln˜ aloka‡n¡ blok

UndObn33:and       byte ptr ss:[bp-1],not bit7 ; nen¡ voln˜ blok
         cmp       word ptr ss:[bp-16],0    ; je dal¨¡ blok ?
         je        UndOb331                 ; nen¡ dal¨¡ blok - konec
         mov       bx,ss:[bp-20]            ; ukazatel ‡¡sla bloku
         cmp       bx,ds:[DskLMBlk]         ; kontrola ‡¡sla bloku
         ja        UndOb331                 ; konec - nen¡ dal¨¡ blok
         call      far ptr GetClust         ; test prvn¡ho alok. bloku
         jz        UndOb332                 ; aloka‡n¡ blok je voln˜
         test      byte ptr es:[11],DIR     ; je to adres © ?
         jz        UndObn38                 ; nen¡ to adres © - dal¨¡ blok
UndOb331:jmp       UndObn4                  ; ukon‡en¡ polo‘ky

; ------ test aloka‡n¡ho bloku adres ©e

UndOb332:test      byte ptr es:[11],DIR     ; je to adres © ?
         jz        UndObn35                 ; nen¡ to adres ©
         test      byte ptr ss:[bp-1],bit5  ; byl prvn¡ aloka‡n¡ blok ?
         jnz       UndObn34                 ; byl ji‘ prvn¡ aloka‡n¡ blok
         call      Und1Adr                  ; test adres ©e
         jc        UndOb331                 ; nen¡ blok adres ©e
         jmp       short UndObn35

UndObn34:call      Und2Adr                  ; test adres ©e
         jc        UndOb331                 ; nen¡ blok adres ©e

; ------ za©azen¡ nov‚ho bloku

UndObn35:or        byte ptr ss:[bp-1],bit7  ; nalezen voln˜ blok
         test      byte ptr ss:[bp-1],bit5  ; je to prvn¡ blok ?
         jnz       UndObn36                 ; nen¡ to prvn¡ blok
         mov       es:[26],bx               ; ulo‘en¡ ‡¡sla bloku
         or        byte ptr ss:[bp-1],bit5  ; ozna‡en¡, ‘e byl prvn¡ blok
         jmp       short UndObn37

UndObn36:xchg      ax,bx                    ; AX <- ‡¡slo nov‚ho bloku
         mov       bx,ss:[bp-24]            ; ‡¡slo minul‚ho bloku
         call      far ptr SetClust         ; nastaven¡ n vaznosti na dal¨¡ blok
         xchg      ax,bx                    ; BX <- ‡¡slo nov‚ho bloku

UndObn37:mov       ss:[bp-24],bx            ; £schova ‡¡sla bloku

; ------ sn¡‘en¡ ‡¡ta‡e zbyl‚ velikosti polo‘ky

         mov       ax,ds:[DskLBBlk]         ; po‡et bajt– na aloka‡n¡ blok
         xor       dx,dx
         sub       ss:[bp-14],ax            ; sn¡‘en¡ ‡¡ta‡e velikosti
         sbb       ss:[bp-12],dx
         jnc       UndObn38
         mov       ss:[bp-14],dx
         mov       ss:[bp-12],dx

; ------ p©¡prava ‡¡sla dal¨¡ho bloku

UndObn38:inc       word ptr ss:[bp-20]      ; zv˜¨en¡ ‡¡sla bloku
         test      byte ptr ss:[bp-1],bit6  ; je spojit˜ £sek blok– ?
         jz        UndOb382                 ; nen¡ spojit˜ £sek blok–
         dec       word ptr ss:[bp-22]      ; ‡¡ta‡ spojit‚ho £seku blok–
         jnz       UndOb388
         and       byte ptr ss:[bp-1],not bit6 ; konec spojit‚ho bloku
         jmp       short UndOb388

UndOb382:test      byte ptr ss:[bp-1],bit1  ; je informa‡n¡ polo‘ka ?
         jz        UndOb388                 ; nen¡ informa‡n¡ polo‘ka
         cmp       word ptr ss:[bp-26],0    ; je dal¨¡ polo‘ka ?
         je        UndOb388                 ; nen¡ dal¨¡ polo‘ka
         mov       si,ss:[bp-18]            ; ukazatel polo‘ek bloku
         push      es
         mov       es,ss:[bp-6]             ; adresa informa‡n¡ polo‘ky
         mov       ax,es:[si]
         pop       es
         inc       si
         inc       si
         mov       ss:[bp-18],si            ; nov˜ ukazatel polo‘ky
         dec       word ptr ss:[bp-26]      ; sn¡‘en¡ ‡¡ta‡e polo‘ek
         or        ax,ax                    ; je za‡ tek £seku ?
         jnz       UndOb384                 ; nen¡ za‡ tek £seku

         cmp       word ptr ss:[bp-26],0    ; je dal¨¡ polo‘ka ?
         je        UndOb388                 ; nen¡ dal¨¡ polo‘ka
         push      es
         mov       es,ss:[bp-6]             ; adresa informa‡n¡ polo‘ky
         mov       ax,es:[si]
         pop       es
         inc       si
         inc       si
         mov       ss:[bp-18],si            ; nov˜ ukazatel polo‘ky
         dec       word ptr ss:[bp-26]      ; sn¡‘en¡ ‡¡ta‡e polo‘ek

         sub       ax,ss:[bp-20]            ; po‡et blok– £seku
         jbe       UndOb389                 ; neplatn‚ ‡¡slo bloku
         mov       ss:[bp-22],ax            ; ‡¡ta‡ spojit‚ho £seku blok–
         or        byte ptr ss:[bp-1],bit6  ; p©¡znak spojit‚ho £seku
         jmp       short UndOb389

UndOb384:mov       ss:[bp-20],ax            ; nov‚ ‡¡slo bloku

UndOb388:test      byte ptr ss:[bp-1],bit7  ; nalezen voln˜ blok ?
         jnz       UndOb389                 ; nalezen voln˜ blok
         test      byte ptr ss:[bp-1],bit1  ; je informa‡n¡ polo‘ka ?
         jz        UndObn39                 ; nen¡ informa‡n¡ polo‘ka
UndOb389:dec       word ptr ss:[bp-16]      ; ‡¡ta‡ blok–
         jz        UndObn4                  ; nen¡ dal¨¡ blok
UndObn39:jmp       UndObn33                 ; dal¨¡ blok

; ------ ozna‡en¡ konce ©etˆzce blok–

UndObn4: mov       bx,ss:[bp-24]            ; BX <- posledn¡ blok
         mov       ax,-1
         test      byte ptr ss:[bp-1],bit5  ; byl prvn¡ blok ?
         jnz       UndObn42                 ; byl prvn¡ blok
         test      byte ptr es:[11],DIR     ; je to adres © ?
         jnz       UndObn6                  ; pr zdn˜ adres © se neobnov¡
         inc       ax
         mov       es:[26],ax               ; ozna‡en¡ konce
         jmp       short UndObn44

UndObn42:call      far ptr SetClust         ; ozna‡en¡ konce ©etˆzce

; ------ ulo‘en¡ adres ©e

UndObn44:mov       ax,ss:[bp-14]
         mov       dx,ss:[bp-12]
         sub       es:[28],ax
         sub       es:[30],dx

         test      byte ptr ss:[bp-1],bit0 ; existuje adres ©ov  polo‘ka ?
         jnz       UndObn46                 ; adres ©ov  polo‘ka existuje
         call      UndCreat                 ; vytvo©en¡ nov‚ polo‘ky podle ES
         jc        UndObn6                  ; nˆjak  chyba

UndObn46:call      UndASave                 ; ulo‘en¡ adres ©e na disk
         test      byte ptr ss:[bp-1],bit0  ; je adres ©ov  polo‘ka ?
         jnz       UndObn47
         and       byte ptr ss:[bp-1],not bit2
UndObn47:or        byte ptr ds:[UndParm],bit2 ; p©¡znak z pisu do adres ©e

UndObn6:



UndObn9:

; ------ n vrat p–vodn¡ho znaku polo‘ky

         test      byte ptr ss:[bp-1],bit2  ; je uschov n p–vodn¡ znak ?
         jz        UndObn92                 ; nen¡ uschov n p–vodn¡ znak
         mov       es,ss:[bp-8]             ; adresa pracovn¡ polo‘ky
         mov       al,ss:[bp-2]             ; uschovan˜ p–vodn¡ znak
         mov       es:[0],al                ; n vrat p–vodn¡ho znaku

UndObn92:

; ------ p©¡padn‚ ulo‘en¡ tabulky FAT

         call      far ptr WritFat          ; ulo‘en¡ tabulky FAT na disk

         mov       ax,ds:[UndAdr]
         xor       bx,bx
         call      far ptr ModiSeg          ; vypr zdnˆn¡ segmentu
         mov       ds:[UndAdrS],bx

         mov       ax,ds:[UndInd]           ; segment s indexy
         call      far ptr ModiSeg          ; vypr zdnˆn¡ segmentu
         mov       ds:[UndNum],bx

         call      UndALoad                 ; nov‚ na‡ten¡ adres ©e
         call      UndAInd                  ; inicializace tabulky index–
         call      UndSInd                  ; inicializace index– seznamu
         call      UndSTest                 ; test souboru z evidence
         call      UndATest                 ; test soubor– z adres ©e


; ------ n vrat registr–

UndObn99:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

UndObn   ENDP

; -----------------------------------------------------------------------------
;                                 UndCreat
;          vytvo©en¡ nov‚ polo‘ky adres ©e podle vzoru ES (CY=chyba)
; -----------------------------------------------------------------------------
; VSTUP: ES=vzor polo‘ky 32 B k vytvo©en¡
;        DS=datov˜ segment
; VSTUP: CY=chyba
; -----------------------------------------------------------------------------
; lok ln¡ promˆnn‚: SS:[BP-2] (2) adresa polo‘ky
; -----------------------------------------------------------------------------

UndCreat PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp
         sub       sp,2+32

; ------ £schova polo‘ky do z sobn¡ku

         mov       ss:[bp-2],es             ; £schova adresy polo‘ky
         mov       di,sp
         push      ds
         push      es
         pop       ds
         push      ss
         pop       es
         xor       si,si
         mov       cx,32/2
         cld
         rep       movsw                    ; £schova polo‘ky
         pop       ds

; ------ adresa tabulky index–

         mov       ax,ds:[UndInd]           ; ‡¡slo segmentu index–
         call      far ptr GetDat           ; adresa segmentu index–

; ------ pokus o nalezen¡ neobnoviteln‚ polo‘ky

         xor       si,si
         mov       cx,ds:[UndNum]           ; po‡et polo‘ek (nesm¡ b˜t = 0 !)
UndCrea1:test      byte ptr es:[si],bit0    ; je adres ©ov  polo‘ka ?
         jz        UndCrea2                 ; nen¡ adres ©ov  polo‘ka
         test      byte ptr es:[si],bit5    ; je obnoviteln  ?
         jz        UndCrea7                 ; nalezena neobnoviteln  polo‘ka OK
UndCrea2:add       si,5
         loop      UndCrea1                 ; test dal¨¡ polo‘ky

; ------ pokus o nalezen¡ ‡ ste‡nˆ neobnoviteln‚ polo‘ky

         xor       si,si
         mov       cx,ds:[UndNum]           ; po‡et polo‘ek (nesm¡ b˜t = 0 !)
UndCrea3:test      byte ptr es:[si],bit0    ; je adres ©ov  polo‘ka ?
         jz        UndCrea4                 ; nen¡ adres ©ov  polo‘ka
         test      byte ptr es:[si],bit6    ; nalezen pou‘it˜ blok ?
         jnz       UndCrea7                 ; nalezena polo‘ka s pou‘it˜m blokem
UndCrea4:add       si,5
         loop      UndCrea3                 ; test dal¨¡ polo‘ky

; ------ pokus o nalezen¡ jak‚koliv zru¨en‚ polo‘ky

         xor       si,si
         mov       cx,ds:[UndNum]           ; po‡et polo‘ek (nesm¡ b˜t = 0 !)
UndCrea5:test      byte ptr es:[si],bit0    ; je adres ©ov  polo‘ka ?
         jnz       UndCrea7                 ; nalezena adres ©ov  polo‘ka
         add       si,5
         loop      UndCrea5                 ; test dal¨¡ polo‘ky

; ------ nalezen¡ nepou‘it‚ polo‘ky v adres ©i

         mov       ax,ds:[UndAdr]
         call      far ptr GetSgAdr         ; DX <- adresa segmentu adres ©e
         mov       cx,ds:[UndAdrS]          ; velikost adres ©e celkem
         shr       cx,1                     ; po‡et polo‘ek v adres ©i
UndCrea6:mov       es,dx
         cmp       byte ptr es:[0],0        ; nalezena nepou‘it  polo‘ka ?
         je        UndCrea8                 ; nalezena nepou‘it  polo‘ka
         inc       dx
         inc       dx
         loop      UndCrea6                 ; dal¨¡ polo‘ka

; ------ zvˆt¨en¡ velikosti adres ©e





         stc
         jmp       short UndCrea9

; ------ nalezena vyhovuj¡c¡ polo‘ka v adres ©i

UndCrea7:mov       ax,ds:[UndAdr]           ; segment adres ©e
         call      far ptr GetSgAdr         ; adresa segmentu
         add       dx,es:[si+1]             ; adresa polo‘ky v adres ©i
         mov       es,dx                    ; ES <- adresa polo‘ky
         cmp       word ptr ds:[UndKurz],0
         je        UndCrea8
         dec       word ptr ds:[UndKurz]    ; korekce kurzoru
         cmp       word ptr ds:[UndTop],0
         je        UndCrea8
         dec       word ptr ds:[UndTop]     ; korekce po‡ tku

; ------ ulo‘en¡ polo‘ky do adres ©e

UndCrea8:mov       si,sp
         xor       di,di
         push      ds
         push      ss
         pop       ds
         mov       cx,12/2
         rep       movsw                    ; p©enos prvn¡ ‡ sti
         xor       ax,ax
         mov       cl,10/2
         rep       stosw                    ; vymaz n¡ rezervovan‚ ‡ sti
         add       si,10
         mov       cl,10/2
         rep       movsw                    ; p©enos zbyl‚ ‡ sti
         pop       ds
         clc

; ------ n vrat adres ©e

UndCrea9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

UndCreat ENDP

; -----------------------------------------------------------------------------
;                                 UndASave
;                 z pis aktivn¡ho adres ©e z bufferu na disk
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; VSTUP: CY=nedostatek pamˆti
; -----------------------------------------------------------------------------
;þ
UndASave PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ na‡ten¡ adres ©e ROOT

         mov       ax,ds:[UndAdr]           ; segment adres ©e
         call      far ptr GetDat           ; adresa bufferu
         xor       si,si                    ; ‡tec¡ adresa z bufferu

         mov       ax,ds:[UndAClus]         ; ‡¡slo po‡ te‡n¡ho alok. bloku
         or        ax,ax                    ; je ROOT ?
         jnz       UndASav2                 ; nen¡ ROOT
         mov       ax,ds:[DskLBRot]         ; po‡ te‡n¡ sektor ROOT
         xor       dx,dx                    ; po‡ te‡n¡ sektor HIGH
         mov       cx,ds:[DskLSRot]         ; po‡et sektor– ROOT
         call      far ptr WritLDsk         ; z pis adres ©e ROOT
         jmp       short UndASav9           ; CY=chyba z pisu

; ------ absolutn¡ sektor zapisovan‚ho aloka‡n¡ho bloku

UndASav2:xchg      ax,bx                    ; BX <- ukazatel blok–
         call      far ptr ClstSekt         ; p©epo‡et na absolutn¡ sektor
         jc        UndASav8                 ; konec ©etˆzce - neplatn˜ blok

; ------ z pis aloka‡n¡ho bloku na disk

         mov       cx,ds:[DskLSBlk]         ; po‡et sektor– na aloka‡n¡ blok
         call      far ptr WritLDsk         ; z pis aloka‡n¡ho bloku dat
         jc        UndASav9                 ; chyba

; ------ zv˜¨en¡ adresy dat

         mov       ax,es
         add       ax,ds:[DskLOBlk]         ; po‡et odstavc– na blok
         mov       es,ax

; ------ ‡¡slo dal¨¡ho aloka‡n¡ho bloku

         call      far ptr GetClust         ; poskytnut¡ dal¨¡ho alok. bloku
         jc        UndASav8                 ; nen¡ dal¨¡ aloka‡n¡ blok
         jnz       UndASav2                 ; je platn˜ aloka‡n¡ blok
UndASav8:clc                                ; p©¡znak operace OK

; ------ n vrat registr–

UndASav9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

UndASave ENDP

; -----------------------------------------------------------------------------
;                                 UndALoad
;                 na‡ten¡ aktivn¡ho adres ©e do bufferu
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; VSTUP: CY=nedostatek pamˆti
; -----------------------------------------------------------------------------
;þ
UndALoad PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ na‡ten¡ adres ©e ROOT

         mov       ax,ds:[UndAClus]         ; ‡¡slo po‡ te‡n¡ho alok. bloku
         or        ax,ax                    ; je ROOT ?
         jnz       UndALoa2                 ; nen¡ ROOT
         mov       ax,ds:[DskLNRot]         ; po‡et polo‘ek ROOT
         shl       ax,1                     ; po‡et odstavc– pro ROOT
         jc        UndALoa9                 ; chyba
         xchg      ax,bx                    ; BX <- velikost bufferu
         mov       ax,ds:[UndAdr]           ; segment adres ©e
         call      far ptr ModiSeg          ; nastaven¡ velikosti bufferu
         jc        UndALoa9                 ; nedostatek pamˆti
         mov       ds:[UndAdrS],bx          ; nov  velikost bloku
         call      far ptr GetDat           ; adresa bufferu
         xor       di,di                    ; ukl dac¡ adresa do bufferu
         mov       ax,ds:[DskLBRot]         ; po‡ te‡n¡ sektor ROOT
         xor       dx,dx                    ; po‡ te‡n¡ sektor HIGH
         mov       cx,ds:[DskLSRot]         ; po‡et sektor– ROOT
         call      far ptr ReadLDsk         ; na‡ten¡ adres ©e ROOT
         jmp       short UndALoa9           ; CY=chyba ‡ten¡

; ------ absolutn¡ sektor na‡¡tan‚ho aloka‡n¡ho bloku

UndALoa2:xchg      ax,bx                    ; BX <- ukazatel blok–
         call      far ptr ClstSekt         ; p©epo‡et na absolutn¡ sektor
         jc        UndALoa8                 ; konec ©etˆzce - neplatn˜ blok

; ------ zvˆt¨en¡ bufferu pro dal¨¡ aloka‡n¡ blok

         push      ax
         push      bx
         mov       bx,ds:[UndAdrS]          ; velikost segmentu adres ©e
         mov       cx,bx                    ; £schova star‚ velikosti bloku
         add       bx,ds:[DskLOBlk]         ; p©i‡ten¡ velikosti bloku
         mov       ax,ds:[UndAdr]           ; segment adres ©e
         call      far ptr ModiSeg          ; zvˆt¨en¡ aloka‡n¡ho bloku
         mov       ds:[UndAdrS],bx          ; nov  velikost bloku
         pop       bx
         pop       ax
         jc        UndALoa9                 ; chyba - nedostatek pamˆti

; ------ adresa k na‡ten¡ aloka‡n¡ho bloku

         push      ax
         push      dx
         mov       ax,ds:[UndAdr]           ; segment adres ©e
         call      far ptr GetSgAdr         ; poskytnut¡ adresy segmentu
         add       dx,cx                    ; adresa konce na‡ten˜ch dat
         mov       es,dx                    ; ES <- buffer k na‡ten¡ bloku
         pop       dx
         pop       ax

; ------ na‡ten¡ aloka‡n¡ho bloku do pamˆti

         xor       di,di                    ; DI <- offset
         mov       cx,ds:[DskLSBlk]         ; po‡et sektor– na aloka‡n¡ blok
         call      far ptr ReadLDsk         ; na‡ten¡ aloka‡n¡ho bloku dat
         jc        UndALoa9                 ; chyba

; ------ ‡¡slo dal¨¡ho aloka‡n¡ho bloku

         call      far ptr GetClust         ; poskytnut¡ dal¨¡ho alok. bloku
         jc        UndALoa8                 ; nen¡ dal¨¡ aloka‡n¡ blok
         jnz       UndALoa2                 ; je platn˜ aloka‡n¡ blok
UndALoa8:clc                                ; p©¡znak operace OK

; ------ n vrat registr–

UndALoa9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

UndALoad ENDP

; -----------------------------------------------------------------------------
;                                 UndAInd
;             inicializace tabulky index– seznamu soubor– z adres ©e
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; VSTUP: CY=nedostatek pamˆti
; -----------------------------------------------------------------------------
; lok ln¡ promˆnn‚: SS:[BP-2] (2) adresa segmentu index–
;                   SS:[BP-4] (2) ukl dac¡ adresa do segmentu index– (bajty)
;                   SS:[BP-6] (2) velikost segmentu index– (v bajtech)
;                   SS:[BP-8] (2) segment adres ©e
;                   SS:[BP-10] (2) offset polo‘ky adres ©e (v odstavc¡ch)
; -----------------------------------------------------------------------------

UndAInd  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp
         sub       sp,10

; ------ inicializace segmentu index–

         call      far ptr GetDFree         ; poskytnut¡ voln‚ pamˆti (bajt–)
         mov       dx,ds:[UndAdrS]          ; velikost segmentu adres ©e
         mov       ax,dx                    ; po‡et polo‘ek * 2
         shl       dx,1                     ; po‡et polo‘ek * 4
         jc        UndAInd0
         shr       ax,1                     ; po‡et polo‘ek
         add       dx,ax                    ; po‡et polo‘ek * 5
         jnc       UndAInd1
UndAInd0:mov       dx,-10                   ; omezen¡
UndAInd1:cmp       bx,dx
         jb        UndAInd2
         mov       bx,dx
UndAInd2:cmp       bx,-10
         jb        UndAInd3
         mov       bx,-10
UndAInd3:mov       ax,ds:[UndInd]           ; segment s indexy
         call      far ptr ModiSegS         ; modifikace segmentu
         jnc       UndAInd4
         jmp       UndAInd9                 ; chyba
UndAInd4:mov       ss:[bp-6],bx             ; velikost segmentu index–
         call      far ptr GetSgAdr         ; adresa segmentu index–
         mov       ss:[bp-2],dx             ; adresa segmentu index–
         mov       word ptr ss:[bp-4],0     ; ukl dac¡ adresa do bufferu

; ------ inicializace ukazatel– adres ©e

         mov       ax,ds:[UndAdr]           ; segment adres ©e
         call      far ptr GetSgAdr         ; adresa segmentu adres ©e
         mov       ss:[bp-8],dx             ; segment adres ©e
         mov       word ptr ss:[bp-10],0    ; ukazatel polo‘ek adres ©e

; ------ p©¡prava adresy polo‘ky v adres ©i

UndAInd5:mov       bx,ss:[bp-10]            ; ukazatel polo‘ek adres ©e
         cmp       bx,ds:[UndAdrS]          ; jsou ji‘ v¨echny polo‘ky ?
         jae       UndAInd8                 ; jsou ji‘ v¨echny polo‘ky
         mov       ax,ss:[bp-8]             ; segment adres ©e
         add       ax,bx                    ; segment adresy polo‘ky
         mov       es,ax                    ; ES <- segment adresy polo‘ky

; ------ test, zda je to povolen  polo‘ka

         mov       ax,es:[0]                ; prvn¡ 2 znaky jm‚na polo‘ky
         cmp       al,0                     ; je konec adres ©e ?
         je        UndAInd8                 ; konec adres ©e
         cmp       al,0e5h                  ; je to zru¨en  polo‘ka ?
         jne       UndAInd7                 ; nen¡ to zru¨en  polo‘ka
         mov       al,ah                    ; druh˜ znak jm‚na
         cmp       al,0e5h                  ; druh˜ znak nesm¡ b˜t E5
         je        UndAInd7                 ; nepovolen  polo‘ka
         cmp       al,0f6h                  ; druh˜ znak nesm¡ b˜t F6 = zform t.
         je        UndAInd7                 ; nepovolen  polo‘ka
         cmp       al,"."
         je        UndAInd7                 ; nepovolen  polo‘ka
         test      byte ptr es:[11],VOL     ; je to n vˆ¨t¡ ?
         jnz       UndAInd7                 ; n vˆ¨t¡ nepovoleno

; ------ ulo‘en¡ indexu na polo‘ku

         mov       di,ss:[bp-4]             ; ukl dac¡ adresa do segmentu index–
         cmp       di,ss:[bp-6]             ; je segment ji‘ pln˜ ?
         jae       UndAInd7                 ; segment je ji‘ pln˜
         mov       es,ss:[bp-2]             ; adresa segmentu index–
         mov       byte ptr es:[di],bit0+bit6 ; parametry-je polo‘ka v adres ©i
         mov       es:[di+1],bx             ; offset v segmentu adres ©e
         add       di,5                     ; zv˜¨en¡ ukl dac¡ adresy
         mov       ss:[bp-4],di             ; nov  ukl dac¡ adresa
         inc       word ptr ds:[UndNum]     ; zv˜¨en¡ ‡¡ta‡e polo‘ek k zobrazen¡

; ------ p©¡prava pro dal¨¡ polo‘ku v adres ©i

UndAInd7:add       word ptr ss:[bp-10],2    ; zv˜¨en¡ ukazatele polo‘ek adres.
         jmp       short UndAInd5           ; test dal¨¡ polo‘ky

; ------ minimalizace segmentu undex–

UndAInd8:mov       bx,ss:[bp-4]             ; v˜sledn  velikost index–
         mov       ax,ds:[UndInd]           ; segment index–
         call      far ptr ModiSegS         ; velikost segmentu index–

; ------ n vrat registr–

UndAInd9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

UndAInd  ENDP

; -----------------------------------------------------------------------------
;                                UndATest
;                    test soubor– adres ©ov‚ho okna
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; -----------------------------------------------------------------------------
; lok ln¡ promˆnn‚: SS:[BP-2] (2) segment adres ©e
;                   SS:[BP-4] (2) ‡¡ta‡ polo‘ek index–
; -----------------------------------------------------------------------------

UndATest PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp
         sub       sp,4

; ------ inicializace lok ln¡ch promˆnn˜ch

         mov       ax,ds:[UndAdr]           ; segment adres ©e
         call      far ptr GetSgAdr         ; adresa segmentu
         mov       ss:[bp-2],dx             ; adresa segmentu adres ©e

         mov       ax,ds:[UndInd]           ; segment index–
         call      far ptr GetDat           ; ES <- adresa segmentu
         xor       si,si                    ; ukazatel polo‘ek
         xor       di,di                    ; vzta‡n˜ offset 0
         mov       ax,ds:[UndNum]           ; po‡et polo‘ek
         mov       ss:[bp-4],ax             ; ‡¡ta‡ polo‘ek
         or        ax,ax
         jz        UndATst9

; ------ p©¡prava adresy jedn‚ polo‘ky

UndATst1:test      byte ptr es:[si],bit1    ; je informa‡n¡ polo‘ka ?
         jnz       UndATst8                 ; je informa‡n¡ polo‘ka
         mov       ax,es:[si+1]             ; adresa bˆ‘n‚ polo‘ky
         add       ax,ss:[bp-2]             ; adresa polo‘ky

; ------ p©¡prava parametr– polo‘ky

         push      es
         mov       es,ax                    ; ES <- adresa polo‘ky
         mov       ax,es:[di+28]            ; velikost polo‘ky LOW
         mov       dx,es:[di+30]            ; velikost polo‘ky HIGH
         mov       bx,es:[di+26]            ; po‡ te‡n¡ aloka‡n¡ blok
         test      byte ptr es:[di+11],DIR  ; je to adres © ?
         pop       es

; ------ test obnovitelnosti adres ©e

         jz        UndATst3                 ; nen¡ to adres ©
         call      far ptr GetClust         ; poskytnut¡ aloka‡n¡ho bloku BX
         jnz       UndATst2                 ; nen¡ obnoviteln  polo‘ka
         call      Und1Adr                  ; test platnosti bloku adres ©e
         mov       dh,bit5                  ; p©¡znaky - obnoviteln  polo‘ka
         jnc       UndATst7                 ; je obnoviteln  polo‘ka OK
UndATst2:mov       dh,bit6                  ; p©¡znaky - neobnoviteln  polo‘ka
         jmp       short UndATst7

; ------ v˜po‡et po‡tu blok– k obnoven¡

UndATst3:mov       cx,ds:[DskLBBlk]         ; po‡et bajt– na aloka‡n¡ blok
         dec       cx                       ; po‡et bajt– - 1
         add       ax,cx                    ; zarovn n¡ velikosti nahoru
         adc       dx,0                     ; p©enos HIGH
         jc        UndATst2                 ; p©ete‡en¡ - nelze obnovit
         inc       cx
         cmp       dx,cx                    ; je p©ete‡en¡ ?
         jae       UndATst2                 ; p©ete‡en¡ - nelze obnovit
         div       cx                       ; v˜po‡et po‡tu blok– celkem
         xchg      ax,cx                    ; CX <- ‡¡ta‡ po‘adovan˜ch blok–

; ------ polo‘ka s velikost¡ 0 je v‘dy plnˆ obnoviteln 

         mov       dh,bit5                  ; p©¡znaky - lze plnˆ obnovit
         jcxz      UndATst7                 ; polo‘ku lze plnˆ obnovit

; ------ test aloka‡n¡ho bloku

         mov       dh,0
UndATst4:call      far ptr GetClust         ; test dal¨¡ho aloka‡n¡ho bloku
         jz        UndATst5                 ; aloka‡n¡ blok je voln˜
         or        dh,bit6                  ; nalezen obsazen˜ blok
         jmp       short UndATst6           ; dal¨¡ aloka‡n¡ blok

UndATst5:or        dh,bit5                  ; nalezen voln˜ blok

; ------ zv˜¨en¡ ukazatele blok–

UndATst6:inc       bx                       ; zv˜¨en¡ ukazatele blok–
         loop      UndATst4           ; dal¨¡ aloka‡n¡ blok

; ------ ulo‘en¡ bajtu p©¡znak–

UndATst7:and       byte ptr es:[si],not bit5+bit6
         or        es:[si],dh

; ------ p©¡prava pro dal¨¡ polo‘ku

UndATst8:add       si,5                     ; zv˜¨en¡ ukazatele index–
         dec       word ptr ss:[bp-4]       ; ‡¡ta‡ polo‘ek index–
         jnz       UndATst1                 ; test dal¨¡ polo‘ky

; ------ n vrat registr–

UndATst9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

UndATest ENDP

; -----------------------------------------------------------------------------
;                              Und1Adr
;                     test prvn¡ho bloku adres ©e
; -----------------------------------------------------------------------------
; VSTUP: BX=‡¡slo aloka‡n¡ho bloku
;        DS=datov˜ segment
; VSTUP: CY=nedostatek pamˆti, chyba nebo to nen¡ adres ©ov˜ blok
; -----------------------------------------------------------------------------

Und1Adr  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ vytvo©en¡ datov‚ho segmentu

         call      far ptr CreatSeg         ; vytvo©en¡ datov‚ho bloku
         jnc       Und1Adr0
         jmp       Und1Adr9                 ; chyba

; ------ nastaven¡ velikosti datov‚ho bloku

Und1Adr0:push      bx                       ; ‡¡slo aloka‡n¡ho bloku
         mov       bx,ds:[DskLBBlk]         ; po‡et bajt– na aloka‡n¡ blok
         mov       cx,ds:[DskLSBlk]         ; po‡et sektor– na alok. blok
Und1Adr1:cmp       bx,64                    ; minim lnˆ 64 bajt–
         jae       Und1Adr2                 ; velikost bloku je OK
         shl       cx,1                     ; po‡et sektor– * 2
         shl       bx,1                     ; po‡et bajt– * 2
         jmp       short Und1Adr1
Und1Adr2:call      far ptr ModiSegS         ; nastaven¡ velikosti bloku
         pop       bx
         jc        Und1Adr8                 ; chyba

; ------ adresa datov‚ho bufferu

         call      far ptr GetDat           ; adresa datov‚ho bufferu
         xor       di,di                    ; ukl dac¡ adresa do bufferu
         xchg      ax,si                    ; SI <- £schova ‡¡sla bloku

; ------ ‡¡slo sektoru po‡ tku datov‚ho bloku -> DX:AX

         call      far ptr ClstSekt         ; v˜po‡et ‡¡sla sektoru
         jc        Und1Adr7                 ; neplatn‚ ‡¡slo bloku

; ------ na‡ten¡ aloka‡n¡ho bloku do bufferu (CX sektor–)

         call      far ptr ReadLDsk         ; ‡ten¡ bloku z disku
         jc        Und1Adr7                 ; chyba

; ------ kontrola prvn¡ polo‘ky "."

         cmp       word ptr es:[di]," ."    ; prvn¡ polo‘ka "."
         jne       Und1Adr6                 ; nen¡ polo‘ka "."
         test      byte ptr es:[di+11],DIR  ; mus¡ b˜t adres ©
         jz        Und1Adr6                 ; nen¡ to adres ©
         cmp       es:[di+26],bx            ; vlastn¡ aloka‡n¡ blok
         jne       Und1Adr6                 ; nen¡ to tento blok

; ------ kontrola druh‚ polo‘ky ".."

         add       di,32                    ; adresa druh‚ polo‘ky
         cmp       word ptr es:[di],".."    ; druh  polo‘ka ".."
         jne       Und1Adr6                 ; nen¡ druh  polo‘ka ".."
         test      byte ptr es:[di+11],DIR  ; mus¡ b˜t adres ©
         jz        Und1Adr6                 ; nen¡ to adres ©
         mov       ax,ds:[UndAClus]         ; alok. blok otcovsk‚ho adres ©e
         cmp       ax,es:[di+26]            ; mus¡ ukazovat na otcovsk˜ adres ©
         jne       Und1Adr6                 ; nen¡ to OK

; ------ zru¨en¡ polo‘ek v bloku

         xor       ax,ax                    ; p©¡znak modifikace
Und1Adr4:add       di,32                    ; zv˜¨en¡ ukazatele polo‘ek
         cmp       di,ds:[DskLBBlk]         ; je je¨tˆ platn  adresa ?
         jae       Und1Adr5                 ; konec bloku
         cmp       byte ptr es:[di],0       ; konec polo‘ek ?
         je        Und1Adr5                 ; konec polo‘ek
         cmp       byte ptr es:[di],0e5h    ; je zru¨en  polo‘ka ?
         je        Und1Adr4                 ; je to zru¨en  polo‘ka
         mov       byte ptr es:[di],0e5h    ; zru¨en¡ polo‘ky
         inc       ax                       ; p©¡znak modifikace
         jmp       short Und1Adr4           ; dal¨¡ polo‘ka

; ------ z pis bloku na disk

Und1Adr5:or        ax,ax                    ; byl adres © modifikov n ?
         jz        Und1Adr7                 ; nebyl modifikov n
         push      si
         xor       si,si                    ; SI <- 0 po‡ tek bufferu
         call      far ptr ClstSekt         ; v˜po‡et ‡¡sla sektoru
         call      far ptr WritLDsk         ; z pis bloku na disk
         pop       si
         jnc       Und1Adr7                 ; v¨e je OK

; ------ zru¨en¡ datov‚ho bloku

Und1Adr6:stc                                ; p©¡znak chyby struktury
Und1Adr7:xchg      ax,si                    ; AX <- ‡¡slo datov‚ho bloku
Und1Adr8:pushf
         call      far ptr DelSeg           ; zru¨en¡ datov‚ho bloku
         popf

; ------ n vrat registr–

Und1Adr9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Und1Adr  ENDP

; -----------------------------------------------------------------------------
;                              Und2Adr
;                     test dal¨¡ho bloku adres ©e
; -----------------------------------------------------------------------------
; VSTUP: BX=‡¡slo aloka‡n¡ho bloku
;        DS=datov˜ segment
; VSTUP: CY=nedostatek pamˆti, chyba nebo to nen¡ adres ©ov˜ blok
; -----------------------------------------------------------------------------

Und2Adr  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ vytvo©en¡ datov‚ho segmentu

         call      far ptr CreatSeg         ; vytvo©en¡ datov‚ho bloku
         jc        Und2Adr9                 ; chyba

; ------ nastaven¡ velikosti datov‚ho bloku

         push      bx                       ; ‡¡slo aloka‡n¡ho bloku
         mov       bx,ds:[DskLBBlk]         ; po‡et bajt– na aloka‡n¡ blok
         mov       cx,ds:[DskLSBlk]         ; po‡et sektor– na alok. blok
Und2Adr3:cmp       bx,64                    ; minim lnˆ 64 bajt–
         jae       Und2Adr4                 ; velikost bloku je OK
         shl       cx,1                     ; po‡et sektor– * 2
         shl       bx,1                     ; po‡et bajt– * 2
         jmp       short Und2Adr3
Und2Adr4:call      far ptr ModiSegS         ; nastaven¡ velikosti bloku
         pop       bx
         jc        Und2Adr8                 ; chyba

; ------ adresa datov‚ho bufferu

         call      far ptr GetDat           ; adresa datov‚ho bufferu
         xor       di,di                    ; ukl dac¡ adresa do bufferu
         xchg      ax,si                    ; SI <- £schova ‡¡sla bloku

; ------ ‡¡slo sektoru po‡ tku datov‚ho bloku

         call      far ptr ClstSekt         ; v˜po‡et ‡¡sla sektoru
         jc        Und2Adr7                 ; neplatn‚ ‡¡slo bloku

; ------ na‡ten¡ aloka‡n¡ho bloku do bufferu

         call      far ptr ReadLDsk         ; ‡ten¡ bloku z disku
         jc        Und2Adr7                 ; chyba

; ------ kontrola obsahu bloku

         cmp       byte ptr es:[di],0       ; cel˜ blok pr zdn˜ ?
         je        Und2Adr6                 ; to je neplatn‚

         mov       cx,ds:[DskLOBlk]         ; po‡et odstavc– na aloka‡n¡ blok
         shr       cx,1                     ; po‡et polo‘ek na aloka‡n¡ blok
Und2Adr5:cmp       byte ptr es:[di],0       ; neexistuj¡c¡ polo‘ka ?
         je        Und2Ad52                 ; to je OK
         cmp       byte ptr es:[di],0e5h    ; zru¨en  polo‘ka ?
         jne       Und2Adr6                 ; neplatn  polo‘ka
         test      byte ptr es:[di+11],bit6+bit7 ; platn‚ atributy ?
         jnz       Und2Adr6                 ; neplatn‚ atributy
Und2Ad52:add       di,32                    ; adresa dal¨¡ polo‘ky
         loop      Und2Adr5                 ; dal¨¡ polo‘ka
         jmp       short Und2Adr7           ; v¨e je OK (zde je NC)

; ------ zru¨en¡ datov‚ho bloku

Und2Adr6:stc                                ; p©¡znak chyby struktury
Und2Adr7:xchg      ax,si                    ; AX <- ‡¡slo datov‚ho bloku
Und2Adr8:pushf
         call      far ptr DelSeg           ; zru¨en¡ datov‚ho bloku
         popf

; ------ n vrat registr–

Und2Adr9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Und2Adr  ENDP

; -----------------------------------------------------------------------------
;                                  UndSLoad
;                        na‡ten¡ eviden‡n¡ho souboru
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; VSTUP: CY=nedostatek pamˆti
; -----------------------------------------------------------------------------
; lok ln¡ promˆnn‚: SS:[BP-2] (2) ukazatel ‡¡sla polo‘ky k na‡¡t n¡
;                   SS:[BP-4] (2) segment ukl dan‚ prvn¡ polo‘ky
;                   SS:[BP-6] (2) segment seznamu informac¡
;                   SS:[BP-8] (2) ...
;                   SS:[BP-9] (1) ...
;                   SS:[BP-22] (13) uschovan‚ z hlav¡ polo‘ky
;                   SS:[BP-204] (182) na‡ten  polo‘ka ze souboru
; -----------------------------------------------------------------------------
;þ
UndSLoad PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp
         sub       sp,204                   ; buffer v z sobn¡ku

; ------ p©¡prava lok ln¡ch promˆnn˜ch

         mov       ax,ds:[UndInf]           ; segment informac¡
         call      far ptr GetSgAdr         ; poskytnut¡ adresy segmentu
         mov       ss:[bp-6],dx             ; segment informac¡

; ------ otev©en¡ souboru

         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       si,offset UndSoub        ; soubor
         mov       al,ds:[AktPath]          ; disk aktivn¡ho adres ©e
         mov       ds:[si],al               ; disk
         call      far ptr OpenR            ; otev©en¡ souboru pro ‡ten¡
         jc        UndSLo04                 ; soubor nenalezen
         mov       ds:[UndIdent],ax         ; identifik tor souboru

; ------ na‡ten¡ z hlav¡ souboru

         mov       di,offset UndEvSum       ; za‡ tek z hlav¡
         mov       cx,4                     ; 4 bajty
         call      far ptr ReadFile         ; na‡ten¡ z hlav¡ souboru
         jc        UndSLo04
         cmp       cx,4
         jne       UndSLo04

; ------ kontrola ukazatele polo‘ek

         mov       ax,ds:[UndEvPoz]         ; pozice ukazatele v souboru
         cmp       ax,ds:[UndEvSum]         ; kontrola pozice ukazatele
         jb        UndSLo06                 ; ukazatel je OK
UndSLo04:jmp       UndSLoa8                 ; neplatn˜ ukazatel
UndSLo06:or        byte ptr ds:[UndParm],bit1 ; p©¡znak nalezen¡ souboru

; ------ posun ukazatele polo‘ek AX

UndSLoa1:or        ax,ax                    ; je ukazatel na za‡ tku seznamu ?
         jnz       UndSLo12                 ; nen¡ prvn¡ polo‘ka
         mov       ax,ds:[UndEvSum]         ; posun na posledn¡ polo‘ku
UndSLo12:dec       ax                       ; posledn¡ ukl dan  polo‘ka
         mov       ss:[bp-2],ax             ; ukazatel polo‘ky k testov n¡

; ------ nastaven¡ ukazatele na testovanou polo‘ku

         mov       dx,182                   ; po‡et bajt– na polo‘ku
         mul       dx                       ; offset polo‘ky v souboru
         add       ax,4                     ; p©i‡ten¡ z hlav¡
         adc       dx,0                     ; p©enos HIGH
         xchg      ax,cx                    ; CX <- ukazatel LOW
         mov       ax,ds:[UndIdent]         ; identifik tor souboru
         call      far ptr SetUFile         ; nastaven¡ ukazatele v souboru
         jnc       UndSLoa2                 ; operace OK
UndSLo14:jmp       UndSLoa7                 ; dal¨¡ polo‘ka

; ------ na‡ten¡ polo‘ky do bufferu

UndSLoa2:push      ss
         pop       es                       ; ES <- segment bufferu
         mov       di,sp                    ; DI <- adresa bufferu
         mov       cx,182                   ; po‡et bajt– ke ‡ten¡
         call      far ptr ReadFile         ; na‡ten¡ polo‘ky ze souboru
         jc        UndSLo14                 ; nˆjak  chyba
         cmp       cx,182
         jne       UndSLo14                 ; asi konec souboru

; ------ test, zda je to platn  polo‘ka

         test      byte ptr es:[di],20h     ; je platn  polo‘ka ?
         jnz       UndSLo14                 ; nen¡ platn  polo‘ka
         test      byte ptr es:[di],80h     ; je to prvn¡ polo‘ka ©ady ?
         jz        UndSLo14                 ; nen¡ prvn¡ polo‘ka ©ady

; ------ konverze cesty v bufferu na velk  p¡smena a nalezen¡ konce cesty

         push      ds
         push      ss
         pop       ds                       ; DS <- segment bufferu
         cld
         add       di,14                    ; za‡ tek jm‚na polo‘ky
         mov       si,di                    ; SI <- adresa bufferu
UndSLo31:mov       dx,si                    ; £schova za‡ tku jm‚na
UndSLo32:lodsb
         cmp       al,"a"
         jb        UndSLo33
         cmp       al,"z"
         ja        UndSLo33
         sub       al,32                    ; konverze na velk‚ p¡smeno
UndSLo33:stosb                              ; ulo‘en¡ znaku
         cmp       al,"\"                   ; oddˆlova‡ cesty ?
         je        UndSLo31                 ; £schova za‡ tku jm‚na
         cmp       al,0                     ; konec cesty ?
         jne       UndSLo32
         pop       ds

; ------ stanoven¡ d‚lky cesty

         mov       di,dx                    ; DI <- konec cesty
         cmp       byte ptr es:[di-2],":"   ; je to ROOT ?
         je        UndSLo34                 ; je to ROOT
         dec       di                       ; odstranˆn¡ koncov‚ho znaku "\"
UndSLo34:sub       di,sp                    ; d‚lka cesty
         sub       di,14                    ; korekce

; ------ porovn n¡ cesty s aktivn¡m adres ©em

         mov       cx,di                    ; CX <- d‚lka cesty
         cmp       cx,ds:[AktPathN]         ; souhlas¡ d‚lka cesty ?
         jne       UndSLo14                 ; nesouhlas¡ d‚lka cesty - dal¨¡
         dec       cx                       ; bez ozna‡en¡ disku
         lea       di,[bp-204+14+1]         ; za‡ tek jm‚na polo‘ky + 1
         mov       si,offset AktPath+1      ; aktivn¡ cesta
         repe      cmpsb                    ; porovn n¡ cesty
         jne       UndSLo14                 ; cesta nesouhlas¡

; ------ £schova parametr– polo‘ky

         push      ds
         lea       si,[bp-204+1]            ; za‡ tek parametr–
         lea       di,[bp-22]               ; buffer k uschov n¡ z hlav¡
         push      ss
         pop       ds
         mov       cl,13                    ; d‚lka parametr–
         rep       movsb                    ; £schova z hlav¡ polo‘ky
         pop       ds

; ------ vytvo©en¡ m¡sta v bufferu pro polo‘ku

         mov       bx,ds:[UndInfS]          ; velikost seznamu
         mov       cx,bx                    ; £schova velikosti seznamu
         inc       bx
         inc       bx                       ; m¡sto pro 2 odstavce
         mov       ds:[UndInfS],bx          ; nov  velikost seznamu
         mov       ax,ds:[UndInf]           ; segment informac¡
         call      far ptr ModiSeg          ; nastaven¡ nov‚ velikosti bloku
         jnc       UndSLo44
UndSLo42:jmp       UndSLoa9                 ; chyba pamˆti

; ------ adresa k ulo‘en¡ polo‘ky

UndSLo44:add       cx,ss:[bp-6]             ; adresa polo‘ky
         mov       es,cx                    ; ES <- segment bufferu

; ------ p©¡prava ukazatel– k p©enosu parametr–

         mov       si,sp                    ; SI <- za‡ tek polo‘ky v bufferu
         push      ds
         push      ss
         pop       ds                       ; DS <- segment na‡ten‚ polo‘ky

; ------ po‡ te‡n¡ aloka‡n¡ blok

         mov       ax,ds:[si+142]           ; prvn¡ aloka‡n¡ blok
         mov       es:[26],ax               ; po‡ te‡n¡ aloka‡n¡ blok
         mov       word ptr es:[16],0       ; po‡et aloka‡n¡ch blok–

; ------ p©enos parametr– polo‘ky

         cld
         inc       si                       ; p©esko‡en¡ p©¡znak–
         lodsb                              ; atributy
         mov       es:[11],al               ; ulo‘en¡ atribut–
         mov       di,22                    ; adresa k ulo‘en¡ ‡asu
         movsw                              ; ‡as polo‘ky
         movsw                              ; datum polo‘ky
         mov       di,28                    ; adresa k ulo‘en¡ velikosti
         movsw                              ; velikost LOW
         movsw                              ; velikost HIGH
         mov       di,12                    ; adresa k ulo‘en¡ ‡asu zru¨en¡
         movsw                              ; ‡as zru¨en¡
         movsw                              ; datum zru¨en¡

; ------ vymaz n¡ jm‚na

         xor       di,di                    ; buffer k ulo‘en¡ jm‚na
         mov       al," "                   ; znak mezery k vymaz n¡
         mov       cx,11                    ; d‚lka jm‚na s p©¡ponou
         rep       stosb                    ; inicializa‡n¡ vymaz n¡ jm‚na

; ------ dek¢dov n¡ jm‚na polo‘ky (DX=adresa za‡ tku jm‚na)

         xor       di,di                    ; buffer k ulo‘en¡ jm‚na
         mov       cl,8                     ; d‚lka jm‚na polo‘ky
         mov       si,dx                    ; SI <- jm‚no
UndSLo52:lodsb
         cmp       al,0
         je        UndSLo56                 ; konec jm‚na
         cmp       al,"."
         jne       UndSLo54
         mov       cl,3                     ; d‚lka p©¡pony
         mov       di,8                     ; adresa k ulo‘en¡ p©¡pony
         jmp       short UndSLo52           ; dal¨¡ znak
UndSLo54:jcxz      UndSLo52                 ; buffer je pln˜
         stosb                              ; ulo‘en¡ znaku
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         jmp       short UndSLo52           ; dal¨¡ znak

UndSLo56:pop       ds


; ====== £schova ‡¡sel blok– polo‘ky

; ------ p©¡prava k uschov n¡ ostatn¡ch aloka‡n¡ch blok–

         mov       di,32                    ; p©¡znak - je konec polo‘ky
         lea       si,[bp-204+142]          ; ‡tec¡ adresa
         mov       ss:[bp-4],es             ; £schova segmentu polo‘ky

; ------ na‡ten¡ dal¨¡ polo‘ky

UndSLoa6:lea       ax,[bp-204+182]          ; konec polo‘ky
         cmp       si,ax                    ; konec ?
         jae       UndSLo64                 ; konec polo‘ky
         mov       ax,ss:[si]               ; dal¨¡ blok
         inc       si
         inc       si                       ; zv˜¨en¡ ‡tec¡ adresy

; ------ ulo‘en¡ dal¨¡ polo‘ky

         cmp       ax,-1                    ; konec ©etˆzce ?
         je        UndSLoa7                 ; konec ©etˆzce
UndSLo61:cmp       di,32
         jae       UndSLo62                 ; nov  ukl dac¡ polo‘ka
         cld
         stosw

; ------ zv˜¨en¡ ‡¡ta‡e blok–

         push      es
         mov       es,ss:[bp-4]             ; segment p–vodn¡ polo‘ky
         inc       word ptr es:[16]         ; zv˜¨en¡ ‡¡ta‡e polo‘ek
         pop       es
         jmp       short UndSLoa6           ; dal¨¡ polo‘ka

; ------ vytvo©en¡ dal¨¡ ukl dac¡ polo‘ky

UndSLo62:push      ax
         mov       bx,ds:[UndInfS]          ; velikost seznamu
         mov       cx,bx                    ; £schova velikosti seznamu
         inc       bx
         inc       bx                       ; m¡sto pro 2 odstavce
         mov       ax,ds:[UndInf]           ; segment informac¡
         call      far ptr ModiSeg          ; nastaven¡ nov‚ velikosti bloku
         jc        UndSLo63                 ; chyba pamˆti
         mov       ds:[UndInfS],bx          ; nov  velikost seznamu

; ------ adresa k ulo‘en¡ polo‘ky

         add       cx,ss:[bp-6]             ; adresa bufferu
         mov       es,cx                    ; ES <- segment bufferu
         xor       di,di                    ; ukl dac¡ adresa
UndSLo63:pop       ax
         jc        UndSLoa9                 ; chyba pamˆti
         jmp       short UndSLo61

; ------ na‡ten¡ nov‚ polo‘ky

UndSLo64:push      di
         push      es
         lea       di,[bp-204]              ; buffer k na‡ten¡ polo‘ky
         push      ss
         pop       es                       ; ES <- segment bufferu
         mov       cx,182                   ; po‡et bajt– ke ‡ten¡
         mov       ax,ds:[UndIdent]         ; identifik tor souboru
         call      far ptr ReadFile         ; na‡ten¡ polo‘ky ze souboru
         jc        UndSLo65                 ; nˆjak  chyba
         cmp       cx,182
         jb        UndSLo65                 ; asi konec souboru

; ------ porovn n¡ nov‚ polo‘ky

         push      ds
         inc       di                       ; za‡ tek z hlav¡ polo‘ky
         lea       si,[bp-22]               ; uschovan‚ z hlav¡
         push      ss
         pop       ds                       ; DS <- segment bufferu s polo‘kou
         mov       cl,13                    ; d‚lka parametr–
         cld
         repe      cmpsb                    ; porovn n¡ z hlav¡ polo‘ky
         pop       ds
         je        UndSLo65                 ; polo‘ka je OK
         stc                                ; p©¡znak konce
UndSLo65:pop       es
         pop       di
         lea       si,[bp-204+14]           ; za‡ tek blok–
         jnc       UndSLoa6                 ; dal¨¡ blok

; ------ p©¡prava pro dal¨¡ polo‘ku

UndSLoa7:mov       ax,ss:[bp-2]             ; ukazatel polo‘ky
         cmp       ax,ds:[UndEvPoz]         ; jsou ji‘ v¨echny polo‘ky ?
         je        UndSLoa8                 ; jsou ji‘ v¨echny polo‘ky
         jmp       UndSLoa1                 ; nejsou v¨echny-test dal¨¡ polo‘ky

; ------ uzav©en¡ souboru

UndSLoa8:clc                                ; p©¡znak operace OK
UndSLoa9:pushf
         mov       ax,ds:[UndIdent]         ; identifik tor souboru
         call      far ptr ClosFile         ; uzav©en¡ souboru
         mov       word ptr ds:[UndIdent],0 ; p©¡znak uzav©en¡ souboru
         popf

; ------ n vrat registr–

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

UndSLoad ENDP

; -----------------------------------------------------------------------------
;                                 UndSInd
;      inicializace tabulky index– seznamu soubor– z eviden‡n¡ho souboru
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; VSTUP: CY=nedostatek pamˆti
; -----------------------------------------------------------------------------
; lok ln¡ promˆnn‚: SS:[BP-2] (2) adresa segmentu index–
;                   SS:[BP-4] (2) ukl dac¡ adresa do segmentu index– (bajty)
;                   SS:[BP-6] (2) velikost segmentu index– (v bajtech)
;                   SS:[BP-8] (2) segment informac¡
;                   SS:[BP-10] (2) offset polo‘ky informac¡ (v odstavc¡ch)
;                   SS:[BP-12] (2) segment adres ©e
; -----------------------------------------------------------------------------
;þ
UndSInd  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp
         sub       sp,12

; ------ inicializace segmentu index–

         call      far ptr GetDFree         ; poskytnut¡ voln‚ pamˆti (bajt–)
         mov       ax,ds:[UndNum]           ; po‡et polo‘ek v tabulce index–
         shl       ax,1
         shl       ax,1                     ; po‡et polo‘ek * 4
         add       ax,ds:[UndNum]           ; po‡et polo‘ek * 5
         mov       ss:[bp-4],ax             ; ukl dac¡ adresa do bufferu
         add       bx,ax                    ; zvˆt¨en¡ o star‚ polo‘ky
         jnc       UndSIn02
         mov       bx,-10                   ; omezen¡
UndSIn02:mov       dx,ds:[UndInfS]          ; velikost segmentu informac¡
         add       dx,ds:[UndAdrS]          ; p©i‡ten¡ velikosti adres ©e
         mov       ax,dx                    ; po‡et polo‘ek * 2
         shl       dx,1                     ; po‡et polo‘ek * 4
         jc        UndSInd0
         shr       ax,1                     ; po‡et polo‘ek
         add       dx,ax                    ; po‡et polo‘ek * 5
         jnc       UndSInd1
UndSInd0:mov       dx,-10                   ; omezen¡
UndSInd1:cmp       bx,dx
         jb        UndSInd2
         mov       bx,dx
UndSInd2:cmp       bx,-10
         jb        UndSInd3
         mov       bx,-10
UndSInd3:mov       ax,ds:[UndInd]           ; segment s indexy
         call      far ptr ModiSegS         ; modifikace segmentu
         jnc       UndSInd4
         jmp       UndSInd9                 ; chyba
UndSInd4:mov       ss:[bp-6],bx             ; velikost segmentu index–
         call      far ptr GetSgAdr         ; adresa segmentu index–
         mov       ss:[bp-2],dx             ; adresa segmentu index–

; ------ inicializace ukazatel– adres ©e

         mov       ax,ds:[UndAdr]           ; segment adres ©e
         call      far ptr GetSgAdr         ; adresa segmentu
         mov       ss:[bp-12],dx            ; segment adres ©e
         mov       ax,ds:[UndInf]           ; segment adres ©e
         call      far ptr GetSgAdr         ; adresa segmentu adres ©e
         mov       ss:[bp-8],dx             ; segment informac¡
         mov       word ptr ss:[bp-10],0    ; ukazatel polo‘ek informac¡

; ------ p©¡prava adresy polo‘ky v segmentu

UndSInd5:mov       bx,ss:[bp-10]            ; ukazatel polo‘ek informac¡
         cmp       bx,ds:[UndInfS]          ; jsou ji‘ v¨echny polo‘ky ?
         jb        UndSIn51
         jmp       UndSInd8                 ; jsou ji‘ v¨echny polo‘ky
UndSIn51:mov       ax,ss:[bp-8]             ; segment informac¡
         add       ax,bx                    ; segment adresy polo‘ky
         mov       es,ax                    ; ES <- segment adresy polo‘ky

; ------ p©¡prava k vyhled n¡ stejn‚ polo‘ky v adres ©i

         push      bx                       ; offset polo‘ky
         xor       bx,bx                    ; ukazatel index–
UndSIn52:push      es                       ; segment polo‘ky
         mov       es,ss:[bp-2]             ; segment index–
         mov       al,es:[bx]               ; parametry
         mov       dx,es:[bx+1]             ; adresa v adres ©i
         pop       es
         test      al,bit1                  ; je ji‘ polo‘ka informac¡ ?
         jnz       UndSIn58                 ; je ji‘ polo‘ka informac¡

; ------ porovn n¡ polo‘ky, zda se shoduje

         cld
         push      ds
         add       dx,ss:[bp-12]            ; adresa porovn van‚ polo‘ky
         mov       ds,dx                    ; DS <- porovn van  polo‘ka
         mov       si,1
         mov       di,si
         mov       cx,12-1
         repe      cmpsb
         jne       UndSIn54
         mov       si,22
         mov       di,si
         mov       cl,32-22
         repe      cmpsb
UndSIn54:pop       ds
         jne       UndSIn58                 ; polo‘ka neodpov¡d 

; ------ polo‘ka odpov¡d  - ulo‘en¡ odkazu

         pop       ax                       ; adresa polo‘ky
         push      es
         mov       es,ss:[bp-2]             ; segment index–
         mov       es:[bx+3],ax             ; adresa v adres ©i
         or        byte ptr es:[bx],bit1
         pop       es
         jmp       short UndSInd7

; ------ polo‘ka neodpov¡d  - dal¨¡

UndSIn58:add       bx,5                     ; zv˜¨en¡ ukazatele index–
         cmp       bx,ss:[bp-4]             ; konec ?
         jb        UndSIn52                 ; dal¨¡ index
         pop       bx

; ------ test, zda je polo‘ka ji‘ obnoven 

         call      UndSExi                  ; test, zda polo‘ka ji‘ existuje
         jnc       UndSInd7                 ; polo‘ka ji‘ existuje

; ------ ulo‘en¡ indexu na polo‘ku

         mov       di,ss:[bp-4]             ; ukl dac¡ adresa do segmentu index–
         cmp       di,ss:[bp-6]             ; je segment ji‘ pln˜ ?
         jae       UndSInd7                 ; segment je ji‘ pln˜
         push      es
         mov       es,ss:[bp-2]             ; adresa segmentu index–
         mov       byte ptr es:[di],bit1+bit6 ; parametry-je polo‘ka v adres ©i
         mov       es:[di+3],bx             ; offset v segmentu adres ©e
         add       di,5                     ; zv˜¨en¡ ukl dac¡ adresy
         mov       ss:[bp-4],di             ; nov  ukl dac¡ adresa
         inc       word ptr ds:[UndNum]     ; zv˜¨en¡ ‡¡ta‡e polo‘ek k zobrazen¡
         pop       es

; ------ p©¡prava pro dal¨¡ polo‘ku v adres ©i

UndSInd7:mov       ax,es:[16]               ; po‡et aloka‡n¡ch blok–
         add       ax,15                    ; zaokrouhlen¡
UndSIn72:add       word ptr ss:[bp-10],2    ; zv˜¨en¡ ukazatele polo‘ek adres.
         sub       ax,16
         jnc       UndSIn72
         jmp       UndSInd5                 ; test dal¨¡ polo‘ky

; ------ minimalizace segmentu undex–

UndSInd8:mov       bx,ss:[bp-4]             ; v˜sledn  velikost index–
         mov       ax,ds:[UndInd]           ; segment index–
         call      far ptr ModiSegS         ; velikost segmentu index–

; ------ n vrat registr–

UndSInd9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

UndSInd  ENDP

; -----------------------------------------------------------------------------
;                                 UndSExi
;                  test, zda je polo‘ka ze seznamu ji‘ obnoven 
; -----------------------------------------------------------------------------
; VSTUP: ES=polo‘ka z informa‡n¡ho seznamu
;        DS=datov˜ segment
; VSTUP: CY=polo‘ka nenalezena
; -----------------------------------------------------------------------------

UndSExi  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds

; ------ p©¡prava registr–

         mov       ax,ds:[UndAdr]           ; segment adres ©e
         call      far ptr GetSgADr         ; adresa segmentu adres ©e
         mov       bx,ds:[UndAdrS]          ; velikost segmentu adres ©e
         shr       bx,1                     ; po‡et polo‘ek v segmentu

; ------ porovn n¡ jedn‚ polo‘ky

         cld
UndSExi2:mov       ds,dx                    ; DS <- adresa polo‘ky
         xor       si,si
         xor       di,di
         mov       cx,12/2                  ; d‚lka prvn¡ ‡ sti parametr–
         repe      cmpsw                    ; porovn n¡ prvn¡ ‡ sti parametr–
         jne       UndSExi4
         mov       si,22                    ; za‡ tek druh‚ ‡ sti
         mov       di,si
         mov       cl,10/2                  ; d‚lka druh‚ ‡ sti
         repe      cmpsw                    ; porovn n¡ druh‚ ‡ sti
         je        UndSExi9                 ; polo‘ka existuje OK
UndSExi4:inc       dx
         inc       dx                       ; adresa dal¨¡ polo‘ky
         dec       bx
         jnz       UndSExi2                 ; test dal¨¡ polo‘ky
         stc                                ; p©¡znak, ‘e nen¡ polo‘ka

; ------ n vrat registr–

UndSExi9:pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

UndSExi  ENDP

; -----------------------------------------------------------------------------
;                                UndSTest
;                   test soubor– z eviden‡n¡ho seznamu
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; -----------------------------------------------------------------------------
; lok ln¡ promˆnn‚: SS:[BP-2] (2) adresa segmentu index–
;                   SS:[BP-4] (2) ukazatel v segmentu index–
;                   SS:[BP-6] (2) ‡¡ta‡ polo‘ek index–
;                   SS:[BP-8] (2) adresa segmentu informac¡
;                   SS:[BP-10] (2) ukazatel blok– v bufferu
;                   SS:[BP-12] (2) ‡¡ta‡ zbyl˜ch blok–
;                   SS:[BP-14] (2) ukazatel ‡¡sla bloku
;                   SS:[BP-16] (2) ‡¡ta‡ blok– £seku
;                   SS:[BP-17] (1) p©¡znaky
;                                     bit 0: 1=je spojit˜ £sek
;                                     bit 1: 1=‡ek  se na 2. slovo £seku
;                                     bit 5: 1=nalezen alespo¤ 1 voln˜ blok
;                                     bit 6: 1=nalezen alespo¤ 1 obsazen˜ blok
; -----------------------------------------------------------------------------
;þ
UndSTest PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp
         sub       sp,18

; ------ inicializace lok ln¡ch promˆnn˜ch

         mov       ax,ds:[UndInd]           ; segment index–
         call      far ptr GetSgAdr         ; adresa segmentu
         mov       ss:[bp-2],dx             ; adresa segmentu index–
         mov       word ptr ss:[bp-4],0     ; ukazatel v segmentu index–
         mov       ax,ds:[UndNum]           ; po‡et zobrazen˜ch polo‘ek
         mov       ss:[bp-6],ax             ; ‡¡ta‡ polo‘ek index–
         or        ax,ax                    ; je nˆjak  polo‘ka
         jnz       UndSTs04                 ; je nˆjak  polo‘ka
UndSTs02:jmp       UndSTst9
UndSTs04:mov       ax,ds:[UndInf]           ; segment informac¡
         call      far ptr GetSgAdr         ; adresa segmentu
         mov       ss:[bp-8],dx             ; adresa segmentu informac¡

; ------ p©¡prava adresy jedn‚ polo‘ky

UndSTst1:mov       es,ss:[bp-2]             ; segment index–
         mov       si,ss:[bp-4]             ; ukazatel v segmentu index–
         test      byte ptr es:[si],bit1    ; je informa‡n¡ polo‘ka ?
         jnz       UndSTs12                 ; je informa‡n¡ polo‘ka
UndSTs11:jmp       UndSTst8                 ; dal¨¡ polo‘ka

UndSTs12:mov       ax,es:[si+3]             ; offset informa‡n¡ polo‘ky
         add       ax,ss:[bp-8]             ; adresa polo‘ky
         mov       es,ax                    ; ES <- segment polo‘ky

; ------ p©¡prava ukazatel– blok–

         mov       ax,es:[16]               ; po‡et polo‘ek aloka‡n¡ch blok–
         mov       ss:[bp-12],ax            ; ‡¡ta‡ zbyl˜ch blok–
         mov       word ptr ss:[bp-10],32   ; ukazatel polo‘ek blok–
         mov       byte ptr ss:[bp-17],0    ; inicializace p©¡znak–

; ------ spojit˜ £sek

UndSTst2:test      byte ptr ss:[bp-17],bit0 ; je spojit˜ £sek ?
         jz        UndSTst3                 ; nen¡ spojit˜ £sek
         inc       word ptr ss:[bp-14]      ; zv˜¨en¡ ukazatele blok–
         dec       word ptr ss:[bp-16]      ; ‡¡ta‡ blok– £seku
         jnz       UndSTst4                 ; nen¡ konec £seku
         and       byte ptr ss:[bp-17],not bit0+bit1 ; zru¨en¡ p©¡znak– £seku
         jmp       short UndSTst4

; ------ test, zda je p©ipraveno ‡¡slo dal¨¡ho bloku

UndSTst3:cmp       word ptr ss:[bp-12],0    ; je p©ipraven dal¨¡ blok ?
         je        UndSTst7                 ; nen¡ dal¨¡ blok

; ------ p©¡prava dal¨¡ polo‘ky z bufferu

         mov       si,ss:[bp-10]            ; ukazatel blok– v bufferu
         mov       ax,es:[si]               ; dal¨¡ aloka‡n¡ blok
         inc       si
         inc       si
         mov       ss:[bp-10],si            ; zv˜¨en¡ ukazatel blok–
         dec       word ptr ss:[bp-12]      ; sn¡‘en¡ ‡¡ta‡e blok–

; ------ druh‚ slovo spojit‚ho £seku

         test      byte ptr ss:[bp-17],bit1 ; je druh‚ slovo spojit‚ho £seku ?
         jz        UndSTs36                 ; nen¡ druh‚ slovo spoj. £seku
         cmp       ax,ss:[bp-14]            ; je ni‘¨¡ ne‘ v˜choz¡ hodnota ?
         jbe       UndSTs36                 ; polo‘ka je neplatn 
         sub       ax,ss:[bp-14]            ; po‡et krok–
         mov       ss:[bp-16],ax            ; ‡¡ta‡ blok– £seku
         or        byte ptr ss:[bp-17],bit0 ; p©¡znak spojit‚ho £seku
         and       byte ptr ss:[bp-17],not bit1 ; zru¨en¡ p©¡znaku 2. slova
         jmp       short UndSTst2

; ------ za‡ tek spojit‚ho £seku

UndSTs36:or        ax,ax
         jnz       UndSTs38
         or        byte ptr ss:[bp-17],bit1 ; p©¡znak - ‡ek  se na 2. slovo
         jmp       UndSTst2                 ; dal¨¡ blok

UndSTs38:mov       ss:[bp-14],ax            ; ukazatel ‡¡sla bloku
         and       byte ptr ss:[bp-17],not bit1 ; zru¨en¡ p©¡znaku 2. slova

; ------ test, zda je aloka‡n¡ blok voln˜

UndSTst4:mov       ax,ss:[bp-14]            ; ‡¡slo bloku
UndSTst5:xchg      ax,bx                    ; BX <- ‡¡slo bloku
         call      far ptr GetClust         ; poskytnut¡ aloka‡n¡ho bloku
         jz        UndSTst6                 ; aloka‡n¡ blok je voln˜ OK
         or        byte ptr ss:[bp-17],bit6 ; nalezen obsazen˜ blok
         jmp       short UndSTst2           ; dal¨¡ blok

UndSTst6:or        byte ptr ss:[bp-17],bit5 ; nalezen voln˜ blok
         jmp       short UndSTst2           ; dal¨¡ blok

; ------ nastaven¡ p©¡znak– polo‘ky

UndSTst7:mov       al,ss:[bp-17]            ; p©¡znaky
         and       al,bit5+bit6
         jnz       UndSTs72                 ; byl nˆjak˜ blok
         mov       al,bit5                  ; p©¡znak - lze obnovit OK
UndSTs72:mov       es,ss:[bp-2]             ; segment index–
         mov       si,ss:[bp-4]             ; ukazatel v segmentu index–
         and       byte ptr es:[si],not bit5+bit6
         or        es:[si],al               ; nastaven¡ p©¡znak–

; ------ p©¡prava pro dal¨¡ polo‘ku

UndSTst8:add       word ptr ss:[bp-4],5     ; zv˜¨en¡ ukazatele index–
         dec       word ptr ss:[bp-6]       ; ‡¡ta‡ polo‘ek index–
         jz        UndSTst9                 ; jsou ji‘ v¨echny polo‘ky
         jmp       UndSTst1                 ; test dal¨¡ polo‘ky

; ------ n vrat registr–

UndSTst9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

UndSTest ENDP

; *****************************************************************************
;                              InitUMnu
;                   inicializace okna obnoven¡ soubor–
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
;        DS=datov˜ segment
; *****************************************************************************

InitUMnu PROC      FAR

         push      ax
         mov       al,ds:[Radku]            ; po‡et © dk– displeje
         sub       al,5
         mov       ds:[si+MnuVys],al        ; v˜¨ka okna
         pop       ax
         ret

InitUMnu ENDP

; *****************************************************************************
;                                DispUMnu
;                    zobrazen¡ okna obnoven¡ soubor–
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
;        DS=datov˜ segment
; -----------------------------------------------------------------------------
; lok ln¡ promˆnn‚: SS:[BP-1] (1) ukazatel © dku na displeji
;                   SS:[BP-2] (1) po‡ te‡n¡ pozice okna
;                   SS:[BP-3] (1) ‡¡ta‡ © dk– k zobrazen¡
;                   SS:[BP-4] (1) ¨¡©ka okna
;                   SS:[BP-6] (2) hladina k zobrazen¡ menu
;                   SS:[BP-8] (2) ‡¡ta‡ aktivn¡ polo‘ky
;                   SS:[BP-10] (2) ukazatel ‡¡sla polo‘ky
;                   SS:[BP-12] (2) ‡¡ta‡ zbyl˜ch polo‘ek
;                   SS:[BP-14] (2) segment adres ©–
;                   SS:[BP-16] (2) segment index–
;                   SS:[BP-18] (2) segment informac¡
; *****************************************************************************
;þ
DispUMnu PROC      FAR

         call      far ptr DispRamM         ; zobrazen¡ horn¡ a doln¡ linky
         call      KorUMnu                  ; korekce kurzoru okna obnoven¡

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp
         sub       sp,18+2*80               ; buffer pro lok ln¡ promˆnn‚

; ------ p©¡prava lok ln¡ch promˆnn˜ch

         mov       al,ds:[si+MnuPoz]        ; po‡ te‡n¡ pozice okna
         mov       ss:[bp-2],al             ; po‡ te‡n¡ pozice okna
         xchg      ax,dx                    ; DL <- pozice k zobrazen¡
         mov       al,ds:[si+MnuRad]        ; po‡ te‡n¡ © dek okna
         inc       ax                       ; korekce
         mov       dh,al                    ; DH <- © dek k zobrazen¡
         inc       ax                       ;
         mov       ss:[bp-1],al             ; ukazatel © dku na displeji
         mov       al,ds:[si+MnuSir]        ; ¨¡©ka okna
         mov       ss:[bp-4],al             ; ¨¡©ka okna
         xchg      ax,cx                    ; CL <- ¨¡©ka okna
         mov       al,ds:[si+MnuVys]        ; v˜¨ka okna
         sub       al,4                     ; bez okraj–
         mov       ss:[bp-3],al             ; ‡¡ta‡ © dk– k zobrazen¡
         mov       ax,ds:[UndTop]           ; po‡ te‡n¡ polo‘ka
         mov       ss:[bp-10],ax            ; ukazatel ‡¡sla polo‘ky
         xchg      ax,bx                    ; BX <- £schova ‡¡sla polo‘ky
         mov       ax,ds:[UndKurz]          ; kurzor v seznamu
         sub       ax,bx                    ; korekce o po‡ te‡n¡ polo‘ku
         cmp       word ptr ds:[UndNum],0   ; je nˆco zobrazeno ?
         je        DispUM02                 ; nen¡ nic zobrazeno
         inc       ax                       ; p©ednastaven¡
DispUM02:mov       ss:[bp-8],ax             ; ‡¡ta‡ kurzoru
         mov       ax,ds:[UndNum]           ; po‡et polo‘ek
         sub       ax,bx                    ; po‡et zbyl˜ch polo‘ek
         mov       ss:[bp-12],ax            ; po‡et zbyl˜ch polo‘ek
         mov       ax,ds:[UndAdr]           ; segment adres ©–
         call      far ptr GetDat
         mov       ss:[bp-14],es            ; segment adres ©–
         mov       ax,ds:[UndInd]           ; segment index–
         call      far ptr GetDat
         mov       ss:[bp-16],es            ; segment index–
         mov       ax,ds:[UndInf]           ; segment informac¡
         call      far ptr GetDat
         mov       ss:[bp-18],es            ; segment informac¡
         mov       ah,0
         mov       al,ds:[si+MnuLev]        ; hladina k zobrazen¡ okna
         mov       ss:[bp-6],ax             ; hladina k zobrazen¡ okna

; ------ zobrazen¡ horn¡ho © dku

         mov       si,offset UndMnPl1
         test      byte ptr ds:[UndParm],bit0 ; jsou informace na‡teny ?
         jz        DispUM03                 ; informace nejsou na‡teny
         mov       si,offset UndMnPl2
         test      byte ptr ds:[UndParm],bit1 ; eviden‡n¡ soubor nalezen ?
         jz        DispUM03                 ; eviden‡n¡ soubor nenalezen
         mov       si,offset UndMnPl3
DispUM03:call      far ptr DispTxtM         ; zobrazen¡ textov‚ho © dku

; ------ dek¢dov n¡ © dku nadpisu

         cld
         mov       di,sp                    ; buffer v z sobn¡ku
         push      ss
         pop       es                       ; ES <- segment z sobn¡ku
         mov       ah,ds:[ColMnu1]          ; barva r mu menu
         mov       al,"³"                   ; "³"
         stosw                              ; lev˜ okraj okna
         mov       cx,71                    ; d‚lka textu
         mov       si,offset UndMnTop       ; text nadpisu
         mov       dh,ds:[ColUnd1]          ; bˆ‘n  barva © dku nadpisu
         mov       dl,ds:[ColUnd2]          ; barva oddˆlovac¡ch ‡ar
DispUMn1:mov       ah,dh                    ; barva © dku nadpisu
         lodsb                              ; na‡ten¡ znaku k zobrazen¡
         cmp       al,"³"                   ; oddˆlovac¡ ‡ ra ?
         jne       DispUM12                 ; nen¡ oddˆlovac¡ ‡ ra
         mov       ah,dl                    ; barva oddˆlovac¡ ‡ ry
DispUM12:stosw                              ; ulo‘en¡ znaku
         loop      DispUMn1                 ; dal¨¡ znak
         mov       ah,ds:[ColMnu1]          ; barva r mu menu
         mov       al,"³"                   ; "³"
         stosw                              ; prav˜ okraj okna

; ------ zobrazen¡ © dku nadpisu

         mov       dx,ss:[bp-2]             ; pozice a © dek k zobrazen¡
         mov       cl,ss:[bp-4]             ; ¨¡©ka okna
         mov       si,sp                    ; text v z sobn¡ku
         mov       ax,ss:[bp-6]             ; hladina k zobrazen¡
         call      far ptr DispKStr         ; zobrazen¡ © dku
         inc       byte ptr ss:[bp-1]       ; zv˜¨en¡ ukazatele © dku

; ------ dek¢dov n¡ okraj–

DispUMn2:mov       di,sp                    ; buffer v z sobn¡ku
         push      ss
         pop       es
         mov       ah,ds:[ColMnu1]          ; barva r mu menu
         mov       al,"³"                   ; "³"
         stosw                              ; lev˜ okraj okna
         mov       es:[di+2*71],ax          ; prav˜ okraj okna

; ------ p©¡prava barvy © dku

         mov       ah,ds:[ColUnd3]          ; bˆ‘n  barva polo‘ky
         dec       word ptr ss:[bp-8]       ; ‡¡ta‡ kurzoru
         jnz       DispUMn3                 ; nen¡ to kurzor
         mov       ah,ds:[ColUnd4]          ; barva kurzoru

; ------ inicializa‡n¡ vymaz n¡ © dku

DispUMn3:mov       si,offset UndMnSir       ; ¨¡©ky jednotliv˜ch pol¡
         mov       ch,0
DispUM32:lodsb                              ; na‡ten¡ ¨¡©ky pole
         mov       cl,al                    ; CL <- ¨¡©ka pole
         mov       al," "                   ; znak mezery
         rep       stosw                    ; vymaz n¡ pole
         cmp       byte ptr ds:[si],cl      ; je konec ?
         je        DispUM33                 ; je konec
         mov       al,"³"                   ; oddˆlovac¡ ‡ ra
         stosw                              ; ulo‘en¡ oddˆlovac¡ ‡ ry
         jmp       short DispUM32           ; dal¨¡ pole

; ------ test, zda je platn  polo‘ka

DispUM33:cmp       word ptr ss:[bp-12],0    ; je to platn  polo‘ka ?
         jne       DispUM34                 ; je to platn  polo‘ka
         jmp       DispUMn8                 ; nen¡ to platn  polo‘ka
DispUM34:dec       word ptr ss:[bp-12]      ; ‡¡ta‡ zb˜vaj¡c¡ch polo‘ek
         mov       di,sp
         inc       di
         inc       di                       ; adresa za‡ tku k dek¢dov n¡

; ------ adresa polo‘ky k dek¢dov n¡

         push      ds
         mov       dx,ds                    ; DX <- datov˜ segment
         mov       bx,ss:[bp-10]            ; ‡¡slo polo‘ky
         shl       bx,1
         shl       bx,1                     ; ‡¡slo polo‘ky * 4
         add       bx,ss:[bp-10]            ; ‡¡slo polo‘ky * 5
         mov       es,ss:[bp-16]            ; segment index–
         mov       cx,es:[bx+3]             ; adresa polo‘ky ze seznamu
         add       cx,ss:[bp-18]            ; adresa polo‘ky
         test      byte ptr es:[bx],bit1    ; platn  polo‘ka ?
         jnz       DispUM35                 ; je to platn  polo‘ka
         mov       cx,es:[bx+1]             ; adresa polo‘ky
         add       cx,ss:[bp-14]            ; adresa polo‘ky
DispUM35:mov       ds,cx                    ; DS <- segment polo‘ky
         mov       bl,es:[bx]               ; p©¡znaky polo‘ky

; ------ dek¢dov n¡ p©¡znaku typu polo‘ky

         push      ss
         pop       es
         mov       al,"."
         test      bl,bit5                  ; nalezen voln˜ blok ?
         jz        DispUM36                 ; nen¡ voln˜ blok
         mov       al,"o"
         test      bl,bit6                  ; nalezen obsazen˜ blok ?
         jz        DispUM36                 ; plnˆ obnoviteln‚
         mov       al,"-"                   ; jinak ‡ ste‡nˆ obnoviteln‚
DispUM36:stosw
         inc       di
         inc       di

; ------ dek¢dov n¡ jm‚na a p©¡pony polo‘ky

         xor       si,si
         lodsb
         cmp       al,0e5h
         jne       DispUM3A
         mov       al,"."
DispUM3A:stosw
         mov       cx,7
DispUM37:lodsb
         stosw
         loop      DispUM37
         inc       di
         inc       di
         lodsb
         stosw
         lodsb
         stosw
         lodsb
         stosw
         inc       di
         inc       di

; ------ dek¢dov n¡ velikosti polo‘ky

         push      ds
         test      byte ptr ds:[11],DIR     ; je to adres © ?
         mov       ds,dx                    ; DS <- datov˜ segment
         jnz       DispUM38                 ; je to adres ©
         mov       bl,ds:[OddelRad]         ; oddˆlovac¡ znak © d–
         pop       ds
         add       di,2*10
         mov       bh,ah                    ; BH <- barva textu
         push      ax
         push      dx
         mov       ax,ds:[28]               ; velikost souboru LOW
         mov       dx,ds:[30]               ; velikost souboru HIGH
         call      far ptr Dek10Num         ; dek¢dov n¡ velikosti souboru
         pop       dx
         pop       ax
         jmp       short DispUMn4

; ------ dek¢dov n¡ textu "<POD--ADR>"

DispUM38:mov       si,offset DskTxtP        ; text "<POD--ADR>"
         mov       cx,10                    ; d‚lka textu
DispUM39:lodsb
         stosw
         loop      DispUM39
         pop       ds
DispUMn4:inc       di
         inc       di

; ------ dek¢dov n¡ data polo‘ky

         mov       si,24 - FileDate         ; fiktivn¡ za‡ tek polo‘ky
         call      far ptr DekA4Dat         ; dek¢dov n¡ data polo‘ky
         inc       di
         inc       di

; ------ dek¢dov n¡ ‡asu polo‘ky

         mov       si,22 - FileTime         ; fiktivn¡ za‡ tek polo‘ky
         call      far ptr DekATmS          ; dek¢dov n¡ ‡asu polo‘ky
         inc       di
         inc       di

; ------ dek¢dov n¡ atribut– polo‘ky

         mov       si,11 - FileAtr          ; fiktivn¡ za‡ tek polo‘ky
         call      far ptr DekAAtr          ; dek¢dov n¡ atribut– polo‘ky
         inc       di
         inc       di

; ------ adresa informa‡n¡ polo‘ky

         mov       bx,ss:[bp-10]            ; ‡¡slo polo‘ky
         shl       bx,1
         shl       bx,1                     ; ‡¡slo polo‘ky * 4
         add       bx,ss:[bp-10]            ; ‡¡slo polo‘ky * 5
         mov       es,ss:[bp-16]            ; segment index–
         mov       al,es:[bx]               ; p©¡znaky
         mov       bx,es:[bx+3]             ; adresa polo‘ky ze seznamu
         push      ss
         pop       es
         test      al,bit1                  ; informa‡n¡ polo‘ka ?
         jz        DispUMn5                 ; nen¡ informa‡n¡ polo‘ka
         add       bx,ss:[bp-18]            ; adresa polo‘ky
         mov       ds,bx                    ; DS <- segment polo‘ky

; ------ dek¢dov n¡ data zru¨en¡ polo‘ky

         mov       si,14 - FileDate         ; fiktivn¡ za‡ tek polo‘ky
         call      far ptr DekA4Dat         ; dek¢dov n¡ data polo‘ky
         inc       di
         inc       di

; ------ dek¢dov n¡ ‡asu zru¨en¡ polo‘ky

         mov       si,12 - FileTime         ; fiktivn¡ za‡ tek polo‘ky
         call      far ptr DekATmS          ; dek¢dov n¡ ‡asu polo‘ky

DispUMn5:pop       ds

; ------ zobrazen¡ © dku

DispUMn8:mov       dx,ss:[bp-2]             ; © dek a pozice k zobrazen¡
         mov       cl,ss:[bp-4]             ; ¨¡©ka okna
         mov       ax,ss:[bp-6]             ; hladina k zobrazen¡
         mov       si,sp                    ; adresa bufferu
         call      far ptr DispMStr         ; zobrazen¡ © dku

; ------ p©¡prava pro dal¨¡ © dek

         dec       byte ptr ss:[bp-3]       ; ‡¡ta‡ © dk– k zobrazen¡
         jz        DispUMn9                 ; jsou ji‘ v¨echny © dky
         inc       byte ptr ss:[bp-1]       ; zv˜¨en¡ ukazatele © dku
         inc       word ptr ss:[bp-10]      ; zv˜¨en¡ ‡¡sla polo‘ky
         jmp       DispUMn2                 ; zobrazen¡ dal¨¡ho © dku

; ------ n vrat registr–

DispUMn9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispUMnu ENDP

; -----------------------------------------------------------------------------
;                                  KorUMnu
;                     korekce kurzoru okna obnoven¡ soubor–
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
;        DS:SI=definice okna
; -----------------------------------------------------------------------------

KorUMnu  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx

; ------ ur‡en¡ po‡tu zobrazen˜ch © dk–

         mov       ch,0
         mov       cl,ds:[si+MnuVys]        ; celkov  v˜¨ka okna
         sub       cl,4                     ; vnit©n¡ v˜¨ka okna

; ------ ostatn¡ parametry okna

         mov       ax,ds:[UndKurz]          ; pozice kurzoru
         mov       bx,ds:[UndTop]           ; prvn¡ zobrazen  polo‘ka
         mov       dx,ds:[UndNum]           ; celkov˜ po‡et soubor– v oknˆ

; ------ omezen¡ pozice kurzoru

         cmp       ax,dx                    ; je pozice kurzoru OK ?
         jb        KorUMnu4                 ; pozice kurzoru je OK
         mov       ax,dx                    ; omezen¡ pozice kurzoru
         or        ax,ax                    ; jsou nˆjak‚ polo‘ky ?
         jz        KorUMnu3                 ; nejsou ‘ dn‚ polo‘ky
         dec       ax                       ; ‡¡slo posledn¡ polo‘ky
KorUMnu3:mov       ds:[UndKurz],ax          ; opraven  pozice kurzoru

; ------ stanoven¡ maxim ln¡ho za‡ tku okna

KorUMnu4:sub       dx,cx                    ; maxim ln¡ za‡ tek okna
         jbe       KorUMnu6                 ; je mal˜ po‡et © dk–

; ------ ohrani‡en¡ shora

         sub       ax,1                     ; rezerva na horn¡m okraji
         jbe       KorUMnu6                 ; je © dek 1 nebo 0 - je za‡ tek
         cmp       ax,bx                    ; je nad horn¡m okrajem ?
         jb        KorUMnu7                 ; je nad horn¡m okrajem

; ------ ohrani‡en¡ zdola

         add       ax,3                     ; rezerva 1 © dek
         sub       ax,cx                    ; korekce, pokud je pod doln¡m okr.
         jbe       KorUMnu5                 ; nen¡ je¨tˆ pod doln¡m okrajem
         cmp       ax,bx                    ; je pod doln¡m okrajem ?
         jae       KorUMnu7                 ; je pod doln¡m okrajem
KorUMnu5:mov       ax,bx                    ; p–vodn¡ za‡ tek
         jmp       short KorUMnu7           ; je konec okna

; ------ je za‡ tek okna

KorUMnu6:xor       ax,ax                    ; n hradn¡ za‡ tek okna
         xor       dx,dx                    ; maxim ln¡ za‡ tek okna

; ------ kontrola maxim ln¡ho za‡ tku

KorUMnu7:cmp       ax,dx                    ; p©ekro‡en maxim ln¡ za‡ tek ?
         jbe       KorUMnu8                 ; nen¡ p©ekro‡en maxim ln¡ za‡ tek
         xchg      ax,dx                    ; AX <- maxim ln¡ za‡ tek

; ------ nastaven¡ nov‚ho za‡ tku okna

KorUMnu8:mov       ds:[UndTop],ax           ; nov˜ po‡ tek okna

; ------ n vrat registr–

KorUMnu9:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

KorUMnu  ENDP

; *****************************************************************************
;                                EditUMnu
;                    editace okna obnoven¡ soubor–
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
;        BX=kl vesa
;        DS=datov˜ segment
; kl vesa neobslou‘ena: CY=p©¡znak pokra‡ov n¡ editace, BX nezmˆnˆno
; kl vesa OK, nen¡ volba: CY=p©¡znak pokra‡ov n¡ editace, BX=0
; provedena volba: NC=p©¡znak proveden¡ editace, BX=‡¡slo volby
; *****************************************************************************
;þ
EditUMnu PROC      FAR

         push      ax
         push      cx
         push      dx
         push      di

         mov       ax,ds:[UndKurz]          ; kurzor
         mov       dx,ds:[UndNum]           ; po‡et polo‘ek
         mov       di,dx                    ; DI <- po‡et polo‘ek
         mov       cl,ds:[si+MnuVys]        ; v˜¨ka okna
         sub       cl,4                     ; vnit©n¡ v˜¨ka okna
         sub       di,cx                    ; maxim ln¡ po‡ te‡n¡ polo‘ka
         jnc       EditUMn0
         xor       di,di                    ; omezen¡ maxim ln¡ho po‡ tku
EditUMn0:dec       cx                       ; korekce v˜¨ky
         call      far ptr JumpBX


         dw        4800h,EditUMn1           ; nahoru
         dw        5000h,EditUMn2           ; dol–
         dw        4700h,EditUMn3           ; Home
         dw        4f00h,EditUMn4           ; End
         dw        8400h,EditUMn3           ; Ctrl-PageUp
         dw        7600h,EditUMn4           ; Ctrl-PageDown
         dw        4900h,EditUMn5           ; PageUp
         dw        5100h,EditUMn6           ; PageDown
         dw        MousXKod+MousXMov,EditUM04 ; veden¡ kurzoru my¨¡

         dw        0,EditUMn9

; ------ veden¡ kurzoru my¨¡
;þ
EditUM04:mov       al,byte ptr ds:[MousePoz+1] ; © dek s kurzorem my¨i
         sub       al,ds:[si+MnuRad]        ; © dek s kurzorem my¨i relativnˆ
         jc        EditUM05                 ; podte‡en¡
         sub       al,3                     ; ode‡ten¡ horn¡ho okraje
         jnc       EditUM06                 ; nen¡ podte‡en¡
EditUM05:mov       al,0                     ; omezen¡ p©i podte‡en¡
EditUM06:cmp       al,cl                    ; je p©ete‡en¡ v˜¨ky okna ?
         jbe       EditUM07                 ; nen¡ p©ete‡en¡ v˜¨ky okna
         mov       al,cl                    ; omezen¡ p©i p©ete‡en¡
EditUM07:mov       ah,0
         add       ax,ds:[UndTop]           ; nov  po‡ te‡n¡ polo‘ka
         cmp       ax,dx                    ; je p©ete‡en¡ po‡tu polo‘ek ?
         jae       EditUMn4                 ; omezen¡ p©i p©ete‡en¡
         jmp       short EditUMn8           ; nov˜ kurzor

; ------ str nka nahoru

EditUMn5:cmp       word ptr ds:[UndTop],0   ; je ji‘ po‡ tek ?
         je        EditUMn3                 ; za‡ tek
         dec       dx
         cmp       ax,dx                    ; je posledn¡ polo‘ka
         jne       EditUM51                 ; nen¡ posledn¡ polo‘ka
         dec       ax                       ; korekce kurzoru
EditUM51:cmp       cx,ds:[UndTop]           ; je v¡c ne‘ str nka ?
         jb        EditUM52                 ; je v¡c ne‘ str nka
         mov       cx,ds:[UndTop]           ; omezen¡ posunu
EditUM52:sub       ds:[UndTop],cx           ; posun po‡ tku
         sub       ax,cx                    ; posun kurzoru
         jmp       short EditUMn8

; ------ str nka dol–

EditUMn6:sub       di,ds:[UndTop]           ; je ji‘ konec okna ?
         je        EditUMn4                 ; konec
         or        ax,ax                    ; je prvn¡ polo‘ka ?
         jnz       EditUM61                 ; nen¡ prvn¡ polo‘ka
         inc       ax                       ; korekce prvn¡ polo‘ky
EditUM61:cmp       cx,di                    ; je v¡c ne‘ str nka ?
         jb        EditUM62                 ; je v¡c ne‘ str nka
         mov       cx,di                    ; omezen¡ posunu
EditUM62:add       ds:[UndTop],cx           ; posun po‡ tku
         add       ax,cx                    ; posun kurzoru
         jmp       short EditUMn8

; ------ konec

EditUMn4:mov       ax,dx

; ------ nahoru

EditUMn1:or        ax,ax
         jz        EditUMn9
         dec       ax
         jmp       short EditUMn8

; ------ dol–

EditUMn2:inc       ax
         cmp       ax,dx
         jb        EditUMn8
         jmp       short EditUMn9

; ------ za‡ tek

EditUMn3:xor       ax,ax

EditUMn8:mov       ds:[UndKurz],ax          ; nov˜ kurzor
EditUMn9:stc
         pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

EditUMnu ENDP

CodeUnd  ENDS

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;
;                                 Data
;
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
Data     SEGMENT

; -----------------------------------------------------------------------------
; Struktura souboru PCTRACKR.DEL (um¡stˆn v ROOT disku):
;
;  0: (2) celkem polo‘ek v souboru (=velikost souboru)
;  2: (2) ‡¡slo polo‘ky, do kter‚ se bude zapisovat
;  4: (N*182) uschovan‚ zru¨en‚ polo‘ky
;               0: (1) p©¡znaky polo‘ky  C0h=polo‘ka o d‚lce 1 pole
;                                        80h=prvn¡ pole dlouh‚ polo‘ky
;                                        40h=posledn¡ pole dlouh‚ polo‘ky
;                                        20h=nepou‘it‚ pole
;                                        00h=st©edn¡ pole dlouh‚ polo‘ky
;                            bit 4: 1=polo‘ka zru¨en‚ho adres ©e
;                            bit 5: 1=dosud nepou‘it  polo‘ka
;                            bit 6: 1=posledn¡ polo‘ka ©etˆzce
;                            bit 7: 1=prvn¡ polo‘ka ©etˆzce
;               1: (1) atributy polo‘ky
;               2: (2) ‡as polo‘ky
;               4: (2) datum polo‘ky
;               6: (4) velikost polo‘ky
;              10: (2) ‡as zru¨en¡ polo‘ky
;              12: (2) datum zru¨en¡ polo‘ky
;              14: (128) jm‚no polo‘ky ASCIIZ
;             142: (2*20) buffer aloka‡n¡ch blok–
;                       ‡¡slo = ‡¡slo aloka‡n¡ho bloku
;                           0 = spojit˜ ©etˆzec ‡¡sel blok– a‘ po dal¨¡ ‡¡slo
;                          -1 = posledn¡ aloka‡n¡ blok
;
; Jm‚no polo‘ky m–‘e b˜t ulo‘eno s oddˆlovac¡mi mezerami mezi jm‚nem a
; oddˆlovac¡ te‡kou (tvar FCB - 8 znak– jm‚no, te‡ka, 3 znaky p©¡pona).
; Pokud po‡et polo‘ek v bufferu aloka‡n¡ch blok– p©es hne 20, n sleduje
; dal¨¡ polo‘ka 182 bajt– jako pokra‡ov n¡ ©etˆzce. Parametry polo‘ky
; (tj. polo‘ky 1: a‘ 12:) mus¡ b˜t shodn‚ s p–vodn¡ polo‘kou.
;
;               0: (1) p©¡znaky polo‘ky  C0h=polo‘ka o d‚lce 1 pole
;                                        80h=prvn¡ pole dlouh‚ polo‘ky
;                                        40h=posledn¡ pole dlouh‚ polo‘ky
;                                        20h=nepou‘it‚ pole
;                                        00h=st©edn¡ pole dlouh‚ polo‘ky
;                            bit 4: 1=polo‘ka zru¨en‚ho adres ©e
;                            bit 5: 1=dosud nepou‘it  polo‘ka
;                            bit 6: 1=posledn¡ polo‘ka ©etˆzce
;                            bit 7: 1=prvn¡ polo‘ka ©etˆzce
;               1: (1) atributy polo‘ky
;               2: (2) ‡as polo‘ky
;               4: (2) datum polo‘ky
;               6: (4) velikost polo‘ky
;              10: (2) ‡as zru¨en¡ polo‘ky
;              12: (2) datum zru¨en¡ polo‘ky
;              14: (2*74) buffer aloka‡n¡ch blok–
;                       ‡¡slo = ‡¡slo aloka‡n¡ho bloku
;                           0 = spojit˜ ©etˆzec ‡¡sel blok– a‘ po dal¨¡ ‡¡slo
;                          -1 = posledn¡ aloka‡n¡ blok
;             162: (20) (???)
;
; Ka‘d  polo‘ka m  182 bajt–. Offset polo‘ky se vypo‡¡t  (N*182 + 4).
; P©i zru¨en¡ souboru se informace o ru¨en‚m souboru zap¡¨¡ do PCTRACKR.DEL
; do polo‘ky podle ukazatele na offsetu 2:. Po z pisu se ukazatel zv˜¨¡.
; Po dosa‘en¡ konce se ukazatel vynuluje.
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
; Index polo‘ky (jeden index 5 B):
;     0: (1) parametry
;                bit 0: 1=je polo‘ka v adres ©i
;                bit 1: 1=je polo‘ka v seznamu
;                bit 2:
;                bit 3:
;                bit 4:
;                bit 5: 1=nalezen alespo¤ 1 voln˜ blok
;                bit 6: 1=nalezen alespo¤ 1 obsazen˜ blok
;                bit 7: 1=polo‘ka ozna‡ena
;     1: (2) offset v segmentu adres ©e (offset v odstavc¡ch)
;     3: (2) offset dopl¤uj¡c¡ch informac¡ (offset v odstavc¡ch)
;
; Polo‘ka adres ©e (ka‘d  polo‘ka 32 B):
;     0: (8) jm‚no polo‘ky
;     8: (3) p©¡pona jm‚na polo‘ky
;    11: (1) atributy
;    12: (10) ... rezervov no
;    22: (2) ‡as polo‘ky
;    24: (2) datum polo‘ky
;    26: (2) po‡ te‡n¡ aloka‡n¡ blok
;    28: (4) velikost polo‘ky
;
; Polo‘ka dopl¤uj¡c¡ch informac¡ (za‡ tek MOD 32 B)
;     0: (8) jm‚no polo‘ky
;     8: (3) p©¡pona jm‚na polo‘ky
;    11: (1) atributy
;    12:      (2) ‡as zru¨en¡ polo‘ky
;    14:      (2) datum zru¨en¡ polo‘ky
;    16:      (2) po‡et polo‘ek aloka‡n¡ch blok– celkem (v‡etnˆ po‡ te‡n¡ho)
;    18:      (4)
;    22: (2) ‡as polo‘ky
;    24: (2) datum polo‘ky
;    26: (2) po‡ te‡n¡ aloka‡n¡ blok
;    28: (4) velikost polo‘ky
;    32: (2*x) polo‘ky aloka‡n¡ch blok– (v‡etnˆ prvn¡ho)
;                 0 = spojit˜ £sek po n sleduj¡c¡ ‡¡slo bloku
;                -1 = konec
; -----------------------------------------------------------------------------

UndSoub  db        'A:\PCTRACKR.DEL',0      ; jm‚no souboru evidence
UndIdent dw        0                        ; identifik tor eviden‡n¡ho souboru

; ------ z hlav¡ souboru - nemˆnit po©ad¡ polo‘ek "UndEvSum" a "UndEvPoz" !

UndEvSum dw        0                        ; celkov˜ po‡et polo‘ek souboru
UndEvPoz dw        0                        ; ukl dac¡ pozice v souboru

UndParm  db        0                        ; parametry
                                            ;   bit 0: informace na‡teny
                                            ;   bit 1: eviden‡n¡ soubor nalezen
                                            ;   bit 2: byl z pis do adres ©e

UndAdr   dw        0                        ; segment s na‡ten˜m adres ©em
UndAdrS  dw        0                        ; velikost segm. adres ©e celkem

UndInf   dw        0                        ; segment dopl¤uj¡c¡ch informac¡
UndInfS  dw        0                        ; velikost segm. dopl¤. informac¡

UndInd   dw        0                        ; segment s indexy
UndNum   dw        0                        ; po‡et zobrazen˜ch polo‘ek
UndKurz  dw        0                        ; kurzor v seznamu polo‘ek
UndTop   dw        0                        ; po‡ te‡n¡ zobrazen  polo‘ka

UndAClus dw        0                        ; ‡¡slo po‡ te‡n¡ho alok. bloku adr.

;ColUnd1  db        0fh                      ; © dek nadpisu
;ColUnd2  db        7                        ; © dek nadpisu - oddˆlovac¡ ‡ ry
;ColUnd3  db        1bh                      ; bˆ‘n  barva polo‘ky
;ColUnd4  db        30h                      ; barva kurzoru

; -----------------------------------------------------------------------------
;        definice okna obnovov n¡ soubor–
; -----------------------------------------------------------------------------

UndMnLin label     byte

         db        11                       ; typ menu - okno obnoven¡ soubor–

         db        0                        ; hladina k zobrazen¡ okna
         dw        1                        ; aktivn¡ polo‘ka
         dw        1                        ; po‡et platn˜ch polo‘ek
         dw        1                        ; celkov˜ po‡et polo‘ek

         dw        UndMnPl1                 ; adresa definice polo‘ek
         dw        UndMnHl1                 ; adresa n povˆdy
         dw        Hlp@ObnoveniSouboru      ; ‡¡slo str nky velk‚ n povˆdy
         dw        0                        ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        UndMnTit                 ; adresa titulu okna
         dw        0                        ; adresa obsluh voleb
         dw        0                        ; adresa podmenu
         dd        0                        ; uschovan  n vratov  adresa z menu

         db        3                        ; po‡ te‡n¡ pozice okna
         db        1                        ; po‡ te‡n¡ © dek okna
         db        73                       ; ¨¡©ka okna
         db        20                       ; v˜¨ka okna

UndMnPl1 db        bit6,20,'na‡¡t m informace...'
UndMnPl2 db        bit6,45,'Soubor evidence zru¨en˜ch soubor– nep©¡tomen.'
UndMnPl3 db        bit6,64,0,'*',0,' Informace doplnˆny ze souboru evidence zru¨en˜ch soubor–. ',0,'*'

HelpS    SEGMENT   BYTE PUBLIC
UndMnHl1 db        87,'Prvn¡ znak, ?, . nebo <Enter> = obnoven¡. Obnoven¡: o pln‚, - ‡ st, . nelze'
HelpS    ENDS

UndMnTop db        ' ³   jm‚no    ³ velikost ³  datum   ³  ‡as   ³ atr.³datum a ‡as zru¨en¡'

UndMnSir db        1,12,10,10,8,5,10,8,0    ; ¨¡©ky jednotliv˜ch pol¡

UndMnTit db        8,'obnoven¡'

Data     ENDS
         END

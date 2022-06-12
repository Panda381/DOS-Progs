
; N mˆty:
;  - mo‘nost pou‘¡t extern¡ ovlada‡ kl vesnice (co s rozm¡stˆn¡m kl ves ?)
;  - mo‘nost zvolit vstupnˆ/v˜stupn¡ k¢d programu (Kamen., Latin2) - k¢d,
;    v jak‚m bude vstupn¡ a v˜stupn¡ text pro testy a cvi‡en¡, p©¡pd. i
;    v jak‚m bude k¢d extern¡ kl vesnice (pozor - opravit t‚‘ ‡¡sla k¢d–
;    pro znaky zad van‚ s ALT - viz znak paragrafu ­ v lekci 41 !). Internˆ
;    by z©ejmˆ pracoval v Kam. nebo by se asi i fonty p©ep¡naly.

; v cel‚m programu se udr‘uje DS=datov˜ segment ! (ES je pracovn¡ a mˆn¡ se)

;(DEBUG                                       ; p©¡znak lad¡c¡ho re‘imu)
;(DEMO                                        ; p©¡znak DEMO verze)

HELPNUM  EQU       12                       ; po‡et str nek n povˆdy

INCLUDE  DEF.ASM

Code     SEGMENT
         ASSUME    cs:Code,ds:Data

; ------ inicializace registr–

Start:   mov       ax,SEG Data
         mov       ds,ax
         mov       ds:[SegmPSP],es          ; adresa PSP

; ------ test licen‡n¡ho ‡¡sla

IFNDEF   DEMO
         mov       ax,es:[0fah]
         mov       dx,es:[0fch]

IFNDEF   DEBUG
         cmp       dx,18811                 ; licen‡n¡ ‡¡slo HIGH
         je        TestLic4                 ; licen‡n¡ ‡¡slo je OK

; ------ chyba licen‡n¡ho ‡¡sla

         push      cs
         pop       es
         mov       al,90h
         cld
         mov       di,offset TestLic4
         mov       cx,offset(CodeEnd-TestLic4)
         rep       stosb
         mov       di,offset Start
         mov       cx,offset(TestLic2-Start)+1
TestLic2:rep       stosb

         mov       dx,offset LicTxt
         mov       ah,9
         int       21h
         mov       ax,4c01h
         int       21h
ENDIF
; ------ dek¢dov n¡ licen‡n¡ho ‡¡sla

TestLic4:;push      ds
         ;pop       es
;         mov       di,offset LicCis1+10
;         call      DekLic
;         mov       cx,SEG HelpSeg
;         mov       es,cx
;         mov       di,offset LicCis2
;         call      DekLic

; ------ vymaz n¡ programu k dek¢dov n¡ licen‡n¡ho ‡¡sla

         push      cs
         pop       es
         mov       al,90h
         mov       di,offset DekLic
         mov       cx,offset(DekLic0-DekLic)
         cld
         rep       stosb
         mov       di,offset Start
         mov       cx,offset(StartMaz-Start)+1
StartMaz:rep       stosb

ENDIF

; ------ ovˆ©en¡ text– lekc¡ (aby se dalo zastavit v debuggeru na adrese STOP)
IFDEF    DEBUG
         call      Over                     ; ovˆ©en¡ text– lekc¡
ENDIF
; ------ inicializace videom¢du

         call      InitVMod                 ; inicializace videom¢du
         jnc       Start2                   ; vydeom¢d nastaven OK

; ------ chyba - nepovolen  videokarta

         mov       dx,offset CardTxt        ; text - nen¡ karta

Chyba:   push      dx
         mov       ah,0fh
         call      Int10                    ; poskytnut¡ aktivn¡ho videom¢du
         cmp       al,7
         je        Chyba1
         mov       al,3
Chyba1:  mov       ah,0
         call      Int10                    ; inicializace videom¢du
         pop       dx

         mov       ah,9
         int       21h                      ; zobrazen¡ textu
         mov       ax,4c01h
         int       21h

; ------ p©¡prava implicitn¡ch cest

Start2:  call      InitHome                 ; p©¡prava implicitn¡ch cest

; ------ rozbor parametr– z p©¡kazov‚ho © dku

         call      Rozbor                   ; rozbor parametr– z p©¡kazov‚ho © dku
         mov       dx,offset HelpTxt        ; text n povˆdy
         jc        Chyba                    ; chyba zad n¡ parametr–

; ------ instalace CSKEY a KEYB

         call      InitCSK                  ; instalace CSKEY a KEYB

; ------ instalace obsluh p©eru¨en¡

         call      InitInt                  ; instalace obsluh p©eru¨en¡

; ------ na‡ten¡ konfigurace programu

         call      ReadCnf                  ; na‡ten¡ konfigurace programu

; ------ inicializace obsluhy hodin

         call      CekInit                  ; inicializace hodin

; ------ inicializace zvukov‚ho gener toru

         call      TonOff                   ; vypnut¡ zvukov‚ho gener toru

; ------ inicializace palet displeje

         mov       si,offset Palety         ; standardn¡ displej
         call      SetPal                   ; nastaven¡ palet

; ------ ovˆ©en¡ text– lekc¡
IFDEF    DEBUG
         call      Over                     ; ovˆ©en¡ text– lekc¡
         jnc       Start3                   ; v¨echno je OK
         jmp       Vyuka                    ; nastaven¡ na chybnou lekci
ENDIF
; ====== nov‚ zobrazen¡ v¨eho (pap¡r, prav¡tko, kl vesnice)

; ------ vymaz n¡ pap¡ru pro v˜stup

Start3:  call      NovyPap                  ; nov˜ pap¡r

; ------ zobrazen¡ prav¡tka

         call      Lineal                   ; zobrazen¡ prav¡tka

; ------ inicializace parametr– kl vesnice

         call      InitKeyb                 ; inicializace parametr– kl vesnice

; ------ zobrazen¡ kl vesnice

         mov       word ptr ds:[AktLekce],0 ; zobraz¡ se v¨echny kl vesy
         call      PodkKlav                 ; vymaz n¡ podkladu kl vesnice
         call      DispKlav                 ; zobrazen¡ kl vesnice


; ====== obsluha hlavn¡ho menu

; ------ vymaz n¡ pap¡ru pro v˜stup

Start4:  call      NovyPap                  ; nov˜ pap¡r

; ------ vymaz n¡ ukazatele £hoz–

         call      NulUhoz                  ; nulov n¡ ‡¡ta‡e £hoz–

; ------ vymaz n¡ ukazatele ‡asu

         call      NulTime                  ; nulov n¡ ‡¡ta‡e ‡asu
         call      MazTime                  ; vymaz n¡ plochy k zobrazen¡ ‡asu

; ------ vypnut¡ kurzoru

         call      MazKurz                  ; vypnut¡ kurzoru

; ------ zobrazen¡ £vodn¡ho textu menu

         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       si,offset UvText         ; £vodn¡ text
         call      DispTTxt                 ; zobrazen¡ £vodn¡ho textu

; ------ obsluha hlavn¡ho menu
;þ
Start40: mov       si,offset UvMenu         ; £vodn¡ menu
         call      Menu                     ; obsluha £vodn¡ho menu
         jc        Start40                  ; kl vesa ESC nen¡ povolena

; ------ 1: v˜uka

         dec       bx
         jnz       Start41
         jmp       Vyuka                    ; v˜uka

; ------ 2: procvi‡ov n¡

Start41: dec       bx
         jnz       Start42
         jmp       Procv                    ; procvi‡ov n¡

; ------ 3: test

Start42: dec       bx
         jnz       Start43
         jmp       Testy                    ; proveden¡ test–

; ------ 4: nastaven¡

Start43: dec       bx
         jnz       Start44
         jmp       Nastav                   ; nastaven¡

; ------ 5: pomoc

Start44: dec       bx
         jnz       Start45
         jmp       Pomoc                    ; n povˆda

; ====== 6: KONEC

; ------ vypnut¡ zvukov‚ho gener toru

Start45: call      TonOff                   ; vypnut¡ zvukov‚ho gener toru

; ------ n vrat p–vodn¡ho videom¢du

         mov       al,ds:[OldVMod]          ; p–vodn¡ videom¢d
         mov       ah,0
         call      Int10                    ; n vrat videom¢du

; ------ n vrat CSKEY a KEYB

         call      DIniCSK                  ; odinstalov n¡ CSKEY a KEYB

; ------ n vrat obsluhy p©eru¨en¡ INT 1Bh

         push      ds
         lds       dx,ds:[Old1B]            ; p–vodn¡ adresa INT 1Bh
         mov       ax,251bh
         int       21h                      ; n vrat adresy INT 1Bh
         pop       ds

; ------ konec programu

         mov       ax,4c00h
         int       21h

; -----------------------------------------------------------------------------
;        dek¢dov n¡ licen‡n¡ho ‡¡sla DX:AX
; -----------------------------------------------------------------------------

DekLic   PROC      NEAR

         xchg      ax,dx
         call      DekLic2
         inc       di
         xchg      ax,dx

DekLic2: add       di,5
         push      ax
         push      cx
         push      dx
         push      di

         mov       cx,10
DekLic3: xor       dx,dx
         div       cx
         dec       di
         add       dl,"0"
         mov       es:[di],dl
         or        ax,ax
         jnz       DekLic3

         pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

DekLic0:                                    ; konec

DekLic   ENDP

; *****************************************************************************
;
;                          Ovˆ©en¡ text– lekc¡ (jen pro ladˆn¡)
;
; *****************************************************************************
IFDEF    DEBUG
;þ
; -----------------------------------------------------------------------------
;        ovˆ©en¡ text– lekc¡ -> CY je chyba (sk ‡e na menu v˜uky)
; -----------------------------------------------------------------------------

Over     PROC      NEAR

; ------ £schova aktu ln¡ho nastaven¡ p©ep¡na‡–

         push      word ptr ds:[AktKlav]    ; £schova aktivn¡ kl vesnice

; ------ nastaven¡ aktivn¡ kl vesnice

         mov       byte ptr ds:[AktKlav],0  ; aktivn¡ kl vesnice - IBM
Over1:   call      InitKeyb                 ; inicializace parametr– kl vesnice
         xor       bx,bx                    ; ukazatel ‡¡sla lekce

; ------ nulov n¡ tabulky p©¡znak– povolen¡ znak–

         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       di,offset HighKeyT       ; tabulka povolen¡ znak–
         mov       cx,256                   ; velikost tabulky
         mov       al,0                     ; nulovac¡ slovo
         cld
         rep       stosb                    ; vynulov n¡ tabulky
         mov       di,ds:[AdrHghCh]         ; tabulka povolen˜ch znak–

; ------ test, zda je dal¨¡ lekce

Over2:   inc       bx                       ; zv˜¨en¡ ukazatele ‡¡sla lekce
         mov       si,ds:[AdrMenS]          ; skupinov‚ menu
         cmp       bl,ds:[si]               ; jsou ji‘ v¨echny lekce ?
         jae       Over7                    ; jsou ji‘ v¨echny lekce

; ------ p©id n¡ povolen˜ch znak– do tabulky

         push      bx
         mov       bh,0
Over3:   mov       bl,ds:[di]               ; znak z tabulky povolen˜ch znak–
         inc       di                       ; zv˜¨en¡ ukazatele v tabulce
         or        byte ptr ds:[bx+HighKeyT],1 ; p©¡znak povolen¡ znaku
         or        bx,bx                    ; je konec jedn‚ lekce ?
         jnz       Over3                    ; dal¨¡ znak
         pop       bx

; ------ adresa definice lekce

         push      bx
         shl       bx,1
         shl       bx,1                     ; ‡¡slo lekce * 4
         add       bx,ds:[AdrTLDat]         ; tabulka adres definic lekc¡
         les       si,ds:[bx]               ; adresa definice lekc¡
         pop       bx

; ------ test textu lekce

Over4:   cmp       word ptr es:[si],"  "    ; 2 mezery zak z ny
         je        Over8                    ; chyba - 2 mezery
         cmp       word ptr es:[si]," " + LF*256 ; mezera na konci © dku
         je        Over8

; ------ mezery na za‡ tku © dku jsou povoleny

         cmp       word ptr es:[si],LF + " "*256
         jne       Over5
Over44:  inc       si
         cmp       byte ptr es:[si]," "
         je        Over44

Over5:   mov       al,es:[si]               ; na‡ten¡ dal¨¡ho znaku
         inc       si                       ; zv˜¨en¡ ukazatele znak–
         cmp       al,EOT                   ; je konec textu lekce ?
         je        Over2                    ; test dal¨¡ lekce
         cmp       al," "
         jbe       Over4                    ; znak je povolen OK

; ------ test, zda je znak povolen

         push      bx
         xchg      ax,bx                    ; BL <- znak
         mov       bh,0
         cmp       byte ptr ds:[bx+HighKeyT],0 ; je znak povolen ?
         pop       bx
         jne       Over4                    ; znak je povolen OK
STOP:
; ------ n vrat p©i chybˆ

Over8:   mov       si,ds:[AdrMenS]          ; skupinov‚ menu
         inc       bx                       ; korekce cisla lekce
         mov       ds:[si+1],bl             ; nastaven¡ ‡¡sla lekce s chybou
         pop       ax                       ; zru¨en¡ uschovan‚ aktivn¡ kl vesnice
         stc                                ; p©¡znak chyby
         ret

; ------ p©¡prava pro dal¨¡ kl vesnici

Over7:   inc       byte ptr ds:[AktKlav]    ; zv˜¨en¡ ‡¡sla kl vesnice
         cmp       byte ptr ds:[AktKlav],3  ; je je¨tˆ platn  kl vesnice ?
         ja        Over9                    ; jsou ji‘ v¨echny kl vesnice
         jmp       Over1                    ; test dal¨¡ kl vesnice

; ------ n vrat p©i operaci OK

Over9:   pop       word ptr ds:[AktKlav]    ; n vrat aktivn¡ kl vesnice
         clc                                ; p©¡znak operace OK
         ret

Over     ENDP

ENDIF

; *****************************************************************************
;
;                                 N povˆda
;
; *****************************************************************************
;þ
; ------ vymaz n¡ plochy k zobrazen¡ n povˆdy

Pomoc:   mov       ah,2                     ; barva
         mov       di,(350-10)*80           ; adresa
         mov       bx,10                    ; v˜¨ka obd‚ln¡ku
         mov       cx,80                    ; ¨¡©ka obd‚ln¡ku
         call      DispBox                  ; vymaz n¡ obd‚ln¡ku

; ------ zobrazen¡ textu n povˆdy

         call      SetFnt08
         mov       di,(350-9)*80
         mov       si,offset HlpTxt
         cmp       byte ptr ds:[Hercules],0 ; je karta Hercules ?
         je        Pomoc02                  ; nen¡ Hercules
         mov       si,offset HlpTxtH        ; text pro Hercules
Pomoc02: call      DispTxt                  ; zobrazen¡ textu n povˆdy

; ------ nalezen¡ aktivn¡ str nky n povˆdy -> ES:SI

Pomoc1:  mov       cx,ds:[HelpAkt]          ; aktivn¡ str nka n povˆdy
         mov       ax,SEG HelpSeg           ; segment n povˆdy
         mov       es,ax                    ; ES <- segment n povˆdy
         mov       si,offset HelpDat        ; offset n povˆdy
         jcxz      Pomoc12                  ; je prvn¡ str nka
         cld
Pomoc11: lods      byte ptr es:[si]         ; na‡ten¡ znaku
         cmp       al,FF                    ; je konec str nky ?
         jne       Pomoc11                  ; nen¡ konec str nky
         loop      Pomoc11                  ; dal¨¡ str nka

; ------ vymaz n¡ plochy k zobrazen¡ textu

Pomoc12: mov       ah,15                    ; b¡l  barva
         xor       di,di                    ; po‡ tek k zobrazen¡
         mov       bx,350-10                ; v˜¨ka obd‚ln¡ku
         mov       cx,80                    ; ¨¡©ka obd‚ln¡ku
         call      DispBox                  ; vymaz n¡ obrazovky

; ------ zobrazen¡ ‡¡sla aktivn¡ str nky

         call      SetFnt08                 ; nastaven¡ fontu 8 linek
         mov       di,2*80 - 2 - 2
         xor       dx,dx                    ; DX <- 0
         mov       ax,ds:[HelpAkt]          ; aktivn¡ str nka
         inc       ax
         mov       bh,0                     ; barva
         call      DispNum                  ; zobrazen¡ ‡¡sla
         mov       ax,"/"
         inc       di
         call      DispChr0                 ; oddˆlovac¡ znak "/"
         mov       ax,HELPNUM               ; po‡et str nek
         call      DispLNum                 ; zobrazen¡ po‡tu str nek

; ------ zobrazen¡ str nky n povˆdy ES:SI

         call      SetFNT16                 ; nastaven¡ fontu 16 linek
         xor       bp,bp                    ; BP <- ukazatel adresy © dku
         inc       bp                       ; 1. pozice
Pomoc4:  mov       di,bp                    ; DI <- adresa za‡ tku © dku textu
         mov       ah,ds:[TColNorm]         ; norm ln¡ barva textu
         mov       bl,0                     ; p©¡znaky atribut– barev
Pomoc42: cld
         lods      byte ptr es:[si]         ; na‡ten¡ znaku k zobrazen¡
         cmp       al,CR                    ; n vrat na za‡ tek © dku ?
         je        Pomoc4                   ; n vrat na za‡ tek © dku
         cmp       al,BS                    ; krok zpˆt
         jne       Pomoc43
         dec       di                       ; sn¡‘en¡ pozice
         jmp       short Pomoc42
Pomoc43: cmp       al,FF                    ; je konec str nky ?
         je        Pomoc5                   ; je konec str nky
         cmp       al,LF                    ; je konec © dku ?
         je        Pomoc49                  ; je konec © dku
         call      DispXAtr                 ; zmˆna atribut– barev
         jnc       Pomoc42                  ; byl to atribut barvy
         call      DispChr0                 ; zobrazen¡ znaku
         jmp       short Pomoc42            ; dal¨¡ znak textu
Pomoc49: add       bp,ds:[RadFont]          ; zv˜¨en¡ ukl dac¡ adresy
         jmp       short Pomoc4             ; dal¨¡ © dek textu

; ------ ‡ek n¡ na vstup znaku z kl vesnice

Pomoc5:  call      InpKey                   ; vstup znaku z kl vesnice
         mov       bx,ds:[HelpAkt]          ; aktivn¡ str nka

; ------ dal¨¡ str nka PageDown

         cmp       al,13                    ; ENTER
         je        Pomoc52
         cmp       ax,5000h                 ; kurzor dol–
         je        Pomoc52
         cmp       ax,5100h                 ; PageDown
         jne       Pomoc6
Pomoc52: inc       bx                       ; zv˜¨en¡ ‡¡sla str nky
         cmp       bx,HELPNUM               ; p©ekro‡ena maxim ln¡ str nka ?
         jae       Pomoc5                   ; p©ekro‡ena maxim ln¡ str nka
         jmp       short Pomoc84

; ------ p©edchoz¡ str nka PageUp

Pomoc6:  cmp       ax,4800h                 ; kurzor nahoru
         je        Pomoc62
         cmp       ax,4900h                 ; PageUp
         jne       Pomoc7
Pomoc62: dec       bx                       ; sn¡‘en¡ ‡¡sla str nky
         js        Pomoc5                   ; nen¡ dal¨¡ str nka
         jmp       short Pomoc84

; ------ prvn¡ str nka Home

Pomoc7:  cmp       ax,8400h                 ; Ctrl-PageUp
         je        Pomoc72
         cmp       ax,4700h                 ; Home
         jne       Pomoc8
Pomoc72: xor       bx,bx                    ; prvn¡ str nka
         jmp       short Pomoc84

; ------ posledn¡ str nka End

Pomoc8:  cmp       ax,7600h                 ; Ctrl-PageDown
         je        Pomoc82
         cmp       ax,4f00h                 ; End
         jne       Pomoc9
Pomoc82: mov       bx,HELPNUM-1             ; ‡¡slo posledn¡ str nky

Pomoc84: cmp       bx,ds:[HelpAkt]          ; byla str nka zmˆnˆna ?
         je        Pomoc5                   ; str nka nebyla zmˆnˆna
         mov       ds:[HelpAkt],bx          ; ulo‘en¡ nov‚ str nky
         jmp       Pomoc1                   ; zobrazen¡ nov‚ str nky

; ------ p©eru¨en¡ ESC

Pomoc9:  cmp       al,27                    ; ESC
         jne       Pomoc5
         jmp       Start3                   ; nov‚ zobrazen¡ v¨eho

; *****************************************************************************
;
;                              Procvi‡ov n¡
;
; *****************************************************************************
;þ
; ------ zad n¡ jm‚na u‘ivatele

Procv:   call      Jmeno                    ; zad n¡ jm‚na u‘ivatele
         jnc       Procv1                   ; jm‚no zad no OK
         jmp       Start4                   ; p©eru¨en¡ operace

; ------ vymaz n¡ pap¡ru

Procv1:  call      NovyPap                  ; nov˜ pap¡r

; ------ ‡ek n¡ na zad n¡ prvn¡ho znaku

         call      DispKurz                 ; zobrazen¡ kurzoru
         call      NulMetr                  ; nulov n¡ metronomu
         call      NulUhoz                  ; nulov n¡ ‡¡ta‡e £hoz–
Procv12: call      LupMetr                  ; obsluha metronomu
         call      TestKey                  ; test kl vesy
         jc        Procv12                  ; ‡ek n¡ na stisk kl vesy

; ------ nulov n¡ ukazatel–

         call      NulTime                  ; nulov n¡ ‡¡ta‡e ‡asu
         call      MazTime                  ; vymaz n¡ plochy k zobrazen¡ ‡asu
         mov       word ptr ds:[VystupN],0  ; po‡et bajt– ve v˜stupn¡m bufferu
         mov       word ptr ds:[ProtPoz],0  ; nulov n¡ pozice na © dku
         mov       word ptr ds:[CitChyb],0  ; ‡¡ta‡ chyb
         mov       word ptr ds:[Opravy],0   ; ‡¡ta‡ proveden˜ch oprav
         and       byte ptr ds:[ParTest],not bit0+bit3 ; neprov d¡ se kontrola

; ------ z pis jednoho © dku

Procv2:  call      EditLine                 ; z pis jednoho © dku

; ------ z pis obsahu © dku do bufferu, z pis po‡tu znak– na © dku

         pushf
         xor       bx,bx                    ; ukazatel znak– v bufferu
Procv3:  cmp       bx,ds:[PozTxt]           ; jsou ji‘ v¨echny znaky ?
         jae       Procv34                  ; nen¡ dal¨¡ znak
         mov       al,ds:[bx+LinBuff]       ; znak z bufferu
         cmp       al,LF
         je        Procv32                  ; znak LF se neukl d 
         call      OutProt                  ; v˜stup znaku do bufferu
Procv32: inc       bx                       ; zv˜¨en¡ ukazatele v bufferu
         jmp       short Procv3             ; dal¨¡ znak
Procv34: call      UhoLProt                 ; z pis po‡tu £hoz– do bufferu
         popf
         jc        Procv5                   ; p©eru¨en¡ cvi‡en¡

; ------ test, zda je v˜stupn¡ buffer ji‘ pln˜

         mov       di,ds:[VystupN]          ; po‡et bajt– ve v˜stupn¡m bufferu
         inc       di                       ; je buffer ji‘ pln˜ ?
         jz        Procv5                   ; buffer je ji‘ pln˜

; ------ posun textu p©i zad n¡ ENTER

         mov       word ptr ds:[CitLUhoz],0 ; nulov n¡ ‡¡ta‡e £hoz–
         mov       word ptr ds:[CitChybL],0 ; nulov n¡ ‡¡ta‡e chyb na © dku
         call      RollText                 ; rolov n¡ textu
         jmp       short Procv2             ; dal¨¡ © dek

; ------ vypnut¡ kurzoru

Procv5:  call      MazKurz                  ; vymaz n¡ kurzoru

; ------ v˜po‡et a zobrazen¡ v˜konu

         call      GetVykon                 ; v˜po‡et v˜konu
         jnc       Procv6                   ; lze vypo‡¡tat OK
         jmp       Start4                   ; n vrat do hlavn¡ho menu
Procv6:  call      DispVykn                 ; zobrazen¡ aktu ln¡ho v˜konu

; ------ vymaz n¡ str nky k zobrazen¡ v˜sledk–

         call      ClrTest                  ; maz n¡ textu
         call      SetFNT16                 ; nastaven¡ fontu 16 linek
         push      ds
         pop       es

; ------ text, ‘e uplynula doba k proveden¡ testu

         mov       ax,60                    ; po‡et sekund na minutu
         mul       word ptr ds:[Omezeni]    ; omezen¡ d‚lky testu v sekund ch
         cmp       ax,ds:[AktDoba]          ; uplynula doba pro test ?
         ja        Procv62                  ; nen¡ je¨tˆ dosa‘ena doba
         mov       di,TOPKLAV + (80-offset(TOutTxt0-TOutTxt)+3)/2 + 15*80
         mov       si,offset TOutTxt
         call      DispTxt                  ; zobrazen¡ hl ¨en¡

; ------ nadpis "Hodnocen¡"

Procv62: mov       di,TOPKLAV + (80-offset(TestTxt2-TestTxt1)+3)/2 + 45*80
         mov       si,offset TestTxt1
         call      DispTxt                  ; zobrazen¡ nadpisu

; ------ v˜kon

         mov       di,TOPKLAV + (80-offset(TestTxt4-TestTxt2)+2-3)/2 + 75*80
         mov       si,offset TestTxt2
         call      DispTxt
         mov       ax,ds:[Vykon]
         xor       dx,dx
         mov       bh,ds:[TColBold]
         call      DispLNum
         call      DispTxt
         mov       si,offset TestTx52       ; koncov  te‡ka
         call      DispTxt

; ------ z pis souboru protokolu

         call      CreaProt                 ; vytvo©en¡ souboru protokolu
         jc        Procv7                   ; chyba vytvo©en¡ souboru
         call      HeadProt                 ; z pis z hlav¡ souboru protokolu
         jc        Procv7                   ; chyba z pisu
         call      CarProt                  ; z pis ‡ ry
         jc        Procv7                   ; chyba z pisu
         call      VystProt                 ; z pis v˜stupn¡ho textu
         jc        Procv7                   ; chyba z pisu
         call      CarProt                  ; z pis ‡ ry
Procv7:  call      ClosProt                 ; uzav©en¡ souboru protokolu
         push      ds
         pop       es                       ; ES <- datov˜ segment
         jnc       Procv8                   ; operace z pisu OK

; ------ zobrazen¡ hl ¨en¡, ‘e je chyba z pisu do souboru

         mov       di,TOPKLAV + (80-offset(WritTxt2-WritTxt1)+3)/2 + 125*80
         mov       si,offset WritTxt1
         call      DispTxt                  ; zobrazen¡ hl ¨en¡
         mov       bp,3                     ; ‡ek  se 3 sekundy
         jmp       short Procv82            ; chybov‚ p¡pnut¡

; ------ test, zda je p©ekro‡en¡ doby

Procv8:  mov       bp,1                     ; ‡ek  se 1 sekunda
         mov       ax,60                    ; po‡et sekund na minutu
         mul       word ptr ds:[Omezeni]    ; omezen¡ d‚lky testu v sekund ch
         cmp       ax,ds:[AktDoba]          ; uplynula doba pro test ?
         ja        Procv83                  ; nen¡ je¨tˆ dosa‘ena doba
         mov       bp,2                     ; ‡ek  se 2 sekundy

; ------ test, zda bude zapnut zvuk

         mov       al,ds:[Sound]            ; p©¡znak zapnut¡ zvuku
         or        al,ds:[Metron]           ; je zvuk nebo metronom ?
         jz        Procv83                  ; zvuk je vypnut

; ------ zapnut¡ zvuku

Procv82: mov       bx,2280                  ; t¢n
         call      Ton                      ; zapnut¡ zvuku

; ------ nulov n¡ ‡¡ta‡e ‡asu

Procv83: call      NulTime                  ; nulov n¡ ‡¡ta‡e ‡asu

; ------ vypr zdnˆn¡ bufferu kl vesnice

Procv84: call      TestKey                  ; test, zda je znak z kl vesnice
         jc        Procv85                  ; nen¡ znak z kl vesnice
         mov       ah,0
         int       16h                      ; vypr zdnˆn¡ bufferu kl vesnice

; ------ test, zda je ji‘ dosa‘eno po‘adovan‚ doby

Procv85: call      GetTime                  ; aktualizace ‡¡ta‡e ‡asu
         cmp       bp,ds:[Doba]             ; je ji‘ po‘adovan  doba ?
         ja        Procv84                  ; ‡ek n¡ na dosa‘en¡ doby

; ------ vypnut¡ zvukov‚ho gener toru

         call      TonOff

; ------ ‡ek n¡ na stisk kl vesy

         mov       ah,0
         int       16h

; ------ n vrat do hlavn¡ho menu

         jmp       Start3                   ; n vrat do hlavn¡ho menu

; -----------------------------------------------------------------------------
;        zad n¡ © dku p©i testu nebo cvi‡en¡ (CY=ukon‡en¡ testu) ES:SI=porovn n¡
; -----------------------------------------------------------------------------

EditLine PROC      NEAR

; ------ £schova adresy za‡ tku © dku

         push      si

; ------ zapnut¡ kurzoru

EditLin1:call      DispKurz                 ; zobrazen¡ kurzoru

; ------ zobrazen¡ aktu ln¡ho stavu £hoz– na © dku

         call      DispLUhz                 ; zobrazen¡ £hoz– na © dku

; ------ zobrazen¡ v˜konu

         call      DispVykn                 ; zobrazen¡ v˜konu

; ------ test, zda je ji‘ dosa‘eno maxim ln¡ doby

EditLin2:call      GetTime                  ; poskytnut¡ ubˆhl‚ho ‡asu
         call      DispTime                 ; obsluha zobrazen¡ ‡asu
         mov       ax,60                    ; po‡et sekund na minutu
         mul       word ptr ds:[Omezeni]    ; omezen¡ d‚lky testu v sekund ch
         cmp       ax,ds:[Doba]             ; je ji‘ maxim ln¡ doba ?
         ja        EditLin4                 ; nen¡ je¨tˆ maxim ln¡ doba
         mov       ds:[AktDoba],ax          ; maxim ln¡ doba je aktu ln¡ dobou
         mov       byte ptr ds:[AktDobaS],0 ; setiny sekundy doby
EditLin3:stc                                ; p©¡znak ukon‡en¡ testu
         jmp       EditLin9                 ; p©eru¨en¡ testu

; ------ ‡ek n¡ na zad n¡ kl vesy

EditLin4:call      LupMetr                  ; obsluha metronomu
         call      TestKey                  ; test stisku kl vesy
         jc        EditLin2                 ; ‡ek n¡ na zad n¡ kl vesy

; ------ vstup znaku z kl vesnice

         call      InpKey                   ; vstup znaku z kl vesnice
         jc        EditLin3                 ; p©eru¨en¡ testu

; ------ na‡ten¡ fale¨n‚ho znaku pro Ctrl-F9

         cmp       ax,6600h                 ; Ctrl-F9
         jne       EditLn42                 ; nen¡ Ctrl-F9
         test      byte ptr ds:[ParTest],bit0 ; prov d¡ se kontrola chyb ?
         jz        EditLin2                 ; kontrola se neprov d¡
         inc       word ptr ds:[Opravy]     ; ‡¡ta‡ proveden˜ch oprav
         mov       al,es:[si]               ; po‘adovan˜ znak
         cmp       al," "
         jae       EditLn42
         mov       al,CR

; ------ vypnut¡ kurzoru

EditLn42:call      MazKurz                  ; vymaz n¡ kurzoru

; ------ krok zpˆt BS, DELETE a kurzor VLEVO

         cmp       ax,4b00h                 ; VLEVO
         je        EditLin5
         cmp       ax,5300h                 ; DELETE
         je        EditLin5
         cmp       al,8                     ; BS
         jne       EditLin7
EditLin5:cmp       byte ptr ds:[Editace],0  ; je editace povolena ?
         je        EditLin1                 ; editace nen¡ povolena
         test      byte ptr ds:[ParTest],bit3 ; z kaz editace ?
         jnz       EditLin1                 ; je z kaz editace

         mov       bx,ds:[PozTxt]           ; po‡et bajt– v bufferu © dku
         or        bx,bx                    ; je ji‘ po‡ tek © dku ?
         jz        EditLin1                 ; je ji‘ po‡ tek © dku

         dec       bx                       ; sn¡‘en¡ po‡tu znak– v bufferu
         mov       ds:[PozTxt],bx           ; nov˜ po‡et znak–
         mov       al,ds:[bx+LinBuff]       ; zru¨en¡ znak z bufferu
         call      DecUhoz                  ; sn¡‘en¡ ‡¡ta‡e £hoz– o znak AL
         inc       word ptr ds:[Opravy]     ; ‡¡ta‡ proveden˜ch oprav

         mov       al,"Û"                   ; znak k vymaz n¡
         mov       ah,ds:[TColPap]          ; barva pap¡ru
         call      DispChT0                 ; vymaz n¡ znaku

         call      LupKey                   ; lupnut¡ psac¡ho stroje
EditLin6:jmp       EditLin1

; ------ n hrada znaku CR znakem LF

EditLin7:cmp       al,CR                    ; je znak CR (=ENTER) ?
         jne       EditLn72                 ; nen¡ ENTER
         mov       al,LF                    ; n hrada znakem LF
         jmp       short EditLn73           ; znak je platn˜ OK

; ------ test platnosti znaku

EditLn72:cmp       byte ptr ds:[PozTxt],SIRTEXT ; je ji‘ doraz ?
         jae       EditLin6                 ; je ji‘ doraz
         cmp       al," "                   ; je platn˜ znak ?
         jb        EditLin6                 ; nen¡ platn˜ znak

; ------ aktualizace ‡asu stisku kl vesy

EditLn73:call      AktTime                  ; aktualizace ‡asu stisku kl vesy
         call      IncUhoz                  ; zv˜¨en¡ ‡¡ta‡e £hoz–
         call      LupKey                   ; lupnut¡ psac¡ho stroje

; ------ kontrola spr vn‚ho zad n¡ znaku

         test      byte ptr ds:[ParTest],bit0 ; prov d¡ se kontrola chyb ?
         jz        EditLn78                 ; kontrola se neprov d¡
         call      EditTest                 ; test zadan‚ho znaku
         jnc       EditLn78                 ; znak byl OK
         call      TestBErr                 ; p¡pnut¡ p©i chybˆ

; ------ ulo‘en¡ platn‚ho znaku

EditLn78:cmp       al,LF                    ; je ENTER ?
         je        EditLin8                 ; je ENTER
         mov       ah,0                     ; barva znaku
         call      DispChT                  ; zobrazen¡ znaku AL
         jmp       short EditLin6

; ------ nov˜ © dek ENTER

EditLin8:call      DispLUhz                 ; zobrazen¡ £hoz–
         mov       bx,ds:[PozTxt]           ; po‡et znak– v bufferu
         mov       ds:[bx+LinBuff],al       ; ulo‘en¡ konce © dku LF do bufferu
         inc       word ptr ds:[PozTxt]     ; zv˜¨en¡ ukazatele pozice
         clc                                ; p©¡znak ukon‡en¡ zad n¡ © dku

EditLin9:pop       si
         ret

EditLine ENDP

; -----------------------------------------------------------------------------
;        test spr vnosti zadan‚ho znaku AL (ES:SI=text testu) -> CY=chyba
; -----------------------------------------------------------------------------

EditTest PROC      NEAR

; ------ kontrola znaku pod kurzorem

         cmp       al,es:[si]               ; je znak shodn˜ ?
         je        EditTst8                 ; znak je shodn˜ OK

; ------ test, zda to je prvn¡ chybn˜ znak

         test      byte ptr ds:[ParTest],bit1 ; byl minul˜ znak chybn˜ ?
         jz        EditTst5                 ; minul˜ znak nebyl chybn˜
         mov       ah,ds:[LastTErr]         ; minul˜ chybn˜ znak

; ------ test, zda jsou znaky zamˆnˆn‚

         cmp       si,2
         jb        EditTst3
         cmp       ax,es:[si-2]             ; byly znaky zamˆnˆny ?
         jne       EditTst3                 ; znaky nebyly zamˆnˆny

; ------ znaky jsou zamˆnˆn‚

         dec       si                       ; n vrat ukazatele znak–
         call      TestDMaz                 ; vymaz n¡ minul‚ho znaku
         call      TestDPod                 ; podtr‘en¡ chybn‚ho znaku
         call      TestDObl                 ; zobrazen¡ oblou‡ku
         jmp       short EditTst8           ; tato chyba se nepo‡¡t 

; ------ test, zda je znak nav¡c

EditTst3:cmp       al,es:[si-1]             ; je to minul˜ znak ?
         jne       EditTst5                 ; nen¡ to minul˜ znak - p©eklep

; ------ je znak nav¡c - n vrat zpˆt

         dec       si                       ; n vrat ukazatele znak–
         call      TestDMaz                 ; vymaz n¡ minul‚ho znaku
         call      TestDNav                 ; zobrazen¡ minul‚ho znaku nav¡c
         jmp       short EditTst8           ; znak je spr vn˜

; ------ je prvn¡ chybn˜ znak - test, zda je vypu¨tˆn˜ znak

EditTst5:cmp       al,es:[si+1]             ; byl vypu¨tˆn znak ?
         jne       EditTst6                 ; nebyl vypu¨tˆn znak
         call      TestDVyp                 ; zobrazen¡ vypu¨tˆn¡ znaku
         call      TestDDis                 ; zobrazen¡ o‡ek van‚ho znaku
         call      EditTInc                 ; p©esko‡en¡ vypu¨tˆn‚ho znaku
         jmp       short EditTst7

; ------ znak je chybn˜

EditTst6:call      TestDDis                 ; zobrazen¡ o‡ek van‚ho znaku
EditTst7:or        byte ptr ds:[ParTest],bit1 ; p©¡znak chyby
         call      TestDPod                 ; podtr‘en¡ chybn‚ho znaku
         inc       word ptr ds:[CitChyb]    ; ‡¡ta‡ chyb
         inc       word ptr ds:[CitChybL]   ; ‡¡ta‡ chyb na © dku
         mov       ds:[LastTErr],al         ; £schova chybn‚ho znaku

; ------ ulo‘en¡ p©¡znaku chyby do protokolu

         push      ax
         mov       al,"_"
         call      OutProt
         pop       ax
         cmp       al,LF
         je        EditTs74                 ; znak LF se neukl d 
         call      OutProt                  ; v˜stup znaku do bufferu
EditTs74:stc                                ; p©¡znak chyby
         jmp       short EditTst9

; ------ znak je spr vn˜

EditTst8:cmp       al,LF
         je        EditTs82                 ; znak LF se neukl d 
         call      OutProt                  ; v˜stup znaku do bufferu
EditTs82:and       byte ptr ds:[ParTest],not bit1 ; nebyla chyba
                                          ;* zde je NC
; ------ zv˜¨en¡ ukazatele znak–

EditTst9:call      EditTInc                 ; zv˜¨en¡ ukazatele znak–
         ret

EditTest ENDP

; -----------------------------------------------------------------------------
;        zv˜¨en¡ ukazatele textu ES:SI (uchov v  registr p©¡znak– !)
; -----------------------------------------------------------------------------

EditTInc PROC      NEAR

         pushf
         cmp       byte ptr es:[si],LF
         je        EditTIn2
         cmp       byte ptr es:[si],EOT
         je        EditTIn2
         cmp       byte ptr es:[si],FF
         je        EditTIn2
         inc       si
EditTIn2:popf
         ret

EditTInc ENDP

; -----------------------------------------------------------------------------
;        podtr‘en¡ chybn‚ho znaku
; -----------------------------------------------------------------------------

TestDPod PROC      NEAR

; ------ £schova registr–

         push      ax
         push      di

; ------ zobrazen¡ podtr‘en¡ na pozici chyby

         call      SetFNT16                 ; nastaven¡ fontu 16 linek
         mov       ah,ds:[TColErr]          ; barva chybn‚ho znaku
         mov       di,ENDTEXT-FONTEXT*80 + LFTTEXT - LINKURZ*80 ; adresa © dku
         add       di,ds:[PozTxt]           ; p©i‡ten¡ pozice na © dku
         mov       al,"_"                   ; znak podtr‘¡tka
         call      DispChr                  ; zobrazen¡ znaku podtr‘¡tka

; ------ n vrat registr–

         pop       di
         pop       ax
         ret

TestDPod ENDP

; -----------------------------------------------------------------------------
;        vymaz n¡ minul‚ho o‡ek van‚ho znaku
; -----------------------------------------------------------------------------

TestDMaz PROC      NEAR

; ------ £schova registr–

         push      ax
         push      di

; ------ vymaz n¡ naposledy zapsan‚ho znaku

         dec       word ptr ds:[PozTxt]     ; zru¨en¡ znaku z bufferu
         mov       al,"Û"                   ; znak k vymaz n¡
         mov       ah,ds:[TColPap]          ; barva pap¡ru
         call      DispChT0                 ; vymaz n¡ znaku

; ------ vymaz n¡ o‡ek van‚ho znaku

         call      SetFNT08                 ; nastaven¡ fontu 8 linek
         mov       al,"Û"                   ; znak k vymaz n¡
         mov       ah,ds:[TColPap]          ; barva pap¡ru
         mov       di,ENDTEXT-FONTEXT*80 + LFTTEXT - LINKURZ*80 - 7*80 ; adresa
         add       di,ds:[PozTxt]           ; p©i‡ten¡ pozice na © dku
         call      DispChr                  ; vymaz n¡ o‡ek van‚ho znaku

; ------ zobrazen¡ podtr‘en¡ na pozici chyby

         call      SetFNT16                 ; nastaven¡ fontu 16 linek
         mov       ah,ds:[TColErr]          ; barva chybn‚ho znaku
         mov       di,ENDTEXT-FONTEXT*80 + LFTTEXT - LINKURZ*80 ; adresa © dku
         add       di,ds:[PozTxt]           ; p©i‡ten¡ pozice na © dku
         mov       al,"_"                   ; znak podtr‘¡tka
         call      DispChr                  ; zobrazen¡ znaku podtr‘¡tka

; ------ zobrazen¡ naposledy zapsan‚ho znaku

         mov       al,ds:[LastTErr]         ; minul˜ chybn˜ znak
         mov       ah,0                     ; barva znaku
         call      DispChT                  ; zobrazen¡ znaku AL

; ------ n vrat registr–

         pop       di
         pop       ax
         ret

TestDMaz ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ oblou‡ku p©es 2 znaky
; -----------------------------------------------------------------------------

TestDObl PROC      NEAR

; ------ £schova registr–

         push      ax
         push      di

; ------ zobrazen¡ o‡ek van‚ho znaku

         mov       ah,ds:[TColErr]          ; barva chybn‚ho znaku
         call      SetFNT08                 ; nastaven¡ fontu 8 linek
         mov       di,ENDTEXT-FONTEXT*80 + LFTTEXT - LINKURZ*80 - 7*80 - 1 ; adresa
         add       di,ds:[PozTxt]           ; p©i‡ten¡ pozice na © dku
         mov       al,"Ö"                   ; za‡ tek oblou‡ku
         call      DispChr0                 ; zobrazen¡ za‡ tku oblou‡ku
         mov       al,"Ó"                   ; konec oblou‡ku
         call      DispChr                  ; zobrazen¡ konce oblou‡ku

; ------ n vrat registr–

         pop       di
         pop       ax
         ret

TestDObl ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡, ‘e je minul˜ znak nav¡c
; -----------------------------------------------------------------------------

TestDNav PROC      NEAR

; ------ £schova registr–

         push      ax
         push      di

; ------ zobrazen¡ p©¡znaku nav¡c

         mov       ah,ds:[TColErr]          ; barva chybn‚ho znaku
         call      SetFNT08                 ; nastaven¡ fontu 8 linek
         mov       di,ENDTEXT-FONTEXT*80 + LFTTEXT - LINKURZ*80 - 7*80 + 4*80 - 1 ; adresa
         add       di,ds:[PozTxt]           ; p©i‡ten¡ pozice na © dku
         mov       al,"Æ"                   ; znak nav¡c
         call      DispChr                  ; zobrazen¡ vypu¨tˆn¡ znaku

; ------ n vrat registr–

         pop       di
         pop       ax
         ret

TestDNav ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ vypu¨tˆn¡ znaku
; -----------------------------------------------------------------------------

TestDVyp PROC      NEAR

; ------ £schova registr–

         push      ax
         push      di

; ------ zobrazen¡ vypu¨tˆn¡

         mov       ah,ds:[TColErr]          ; barva chybn‚ho znaku
         call      SetFNT08                 ; nastaven¡ fontu 8 linek
         mov       di,ENDTEXT-FONTEXT*80 + LFTTEXT - LINKURZ*80 - 7*80 + 5*80 ; adresa
         add       di,ds:[PozTxt]           ; p©i‡ten¡ pozice na © dku
         mov       al,"û"                   ; znak vypu¨tˆn¡
         call      DispChr                  ; zobrazen¡ vypu¨tˆn¡ znaku

; ------ n vrat registr–

         pop       di
         pop       ax
         ret

TestDVyp ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ o‡ek van‚ho znaku ES:SI
; -----------------------------------------------------------------------------

TestDDis PROC      NEAR

; ------ £schova registr–

         push      ax
         push      di

; ------ zobrazen¡ o‡ek van‚ho znaku

         mov       ah,ds:[TColErr]          ; barva chybn‚ho znaku
         call      SetFNT08                 ; nastaven¡ fontu 8 linek
         mov       di,ENDTEXT-FONTEXT*80 + LFTTEXT - LINKURZ*80 - 7*80 ; adresa
         add       di,ds:[PozTxt]           ; p©i‡ten¡ pozice na © dku
         mov       al,es:[si]               ; o‡ek van˜ znak
         cmp       al,EOT
         je        TestDDs1                 ; je konec textu
         cmp       al,LF                    ; je konec © dku LF ?
         jne       TestDDs2                 ; nen¡ konec © dku LF
TestDDs1:mov       al,EnterChr              ; n hradn¡ znak pro konec © dku
TestDDs2:call      DispChr                  ; zobrazen¡ o‡ek van‚ho znaku

; ------ n vrat registr–

         pop       di
         pop       ax
         ret

TestDDis ENDP

; -----------------------------------------------------------------------------
;        chybov‚ p¡pnut¡
; -----------------------------------------------------------------------------

TestBErr PROC      NEAR

; ------ test, zda je zapnut zvuk

         cmp       byte ptr ds:[Sound],0    ; je zvuk zapnut ?
         je        TestBEr9                 ; zvuk vypnut

; ------ £schova registr–

         push      bx
         push      cx

; ------ p¡pnut¡ p©i chybˆ

         mov       bx,4561
         call      Ton
         mov       cx,10
         call      Cekej
         mov       bx,6088
         call      Ton
         call      Cekej
         call      TonOff

; ------ n vrat registr–

         pop       cx
         pop       bx
TestBEr9:ret

TestBErr ENDP

; -----------------------------------------------------------------------------
;        vytvo©en¡ souboru protokolu (CY=chyba z pisu)
; -----------------------------------------------------------------------------

CreaProt PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ p©¡prava k sestaven¡ jm‚na souboru

         push      ds
         pop       es
         mov       di,offset PROTFIL0       ; buffer k ulo‘en¡ jm‚na
         mov       si,offset ProtNamB       ; buffer jm‚na u‘ivatele
         mov       cx,ds:[ProtNamN]         ; d‚lka jm‚na u‘ivatele

; ------ sestaven¡ jm‚na souboru

         cld
CreaPro1:jcxz      CreaPro4                 ; nen¡ dal¨¡ znak
         lodsb                              ; na‡ten¡ znaku jm‚na
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         cmp       al," "
         je        CreaPro4                 ; mezera - konec p©¡jmen¡

         cmp       al,"a"
         jb        CreaPro2
         cmp       al,"z"
         ja        CreaPro2
         sub       al,32                    ; konverze na velk‚ p¡smeno

CreaPro2:cmp       al,"0"
         jb        CreaPro1                 ; nen¡ platn˜ znak
         cmp       al,"9"
         jbe       CreaPro3                 ; je ‡¡slice - to je platn˜ znak

         cmp       al,"A"
         jb        CreaPro1                 ; nen¡ platn˜ znak
         cmp       al,"Z"
         jbe       CreaPro3                 ; je p¡smeno - to je platn˜ znak

         cmp       al,128
         jb        CreaPro1                 ; nen¡ platn˜ znak
         cmp       al,171
         ja        CreaPro1                 ; nen¡ platn˜ znak
         mov       bx,offset SoubChar-128   ; konverzn¡ tabulka
         xlat                               ; konverze na p¡smeno bez diakritiky

CreaPro3:stosb                              ; ulo‘en¡ znaku
         cmp       di,offset PROTFIL0+8     ; je konec jm‚na ?
         jb        CreaPro1                 ; dal¨¡ znak

; ------ implicitn¡ jm‚no, nen¡-li nic zad no

CreaPro4:cmp       di,offset PROTFIL0       ; je nˆco ulo‘eno ?
         ja        CreaPro5                 ; je nˆjak˜ znak
         mov       al,"$"                   ; ozna‡en¡ implicitn¡ho jm‚na
         stosb                              ; implicitn¡ jm‚no

; ------ doplnˆn¡ mezer

CreaPro5:cmp       di,offset PROTFIL0+8     ; je ji‘ jm‚no cel‚ ?
         jae       CreaPro6                 ; jm‚no je ji‘ cel‚
         mov       al," "
         stosb                              ; doplnˆn¡ znaku mezery
         jmp       short CreaPro5

; ------ oddˆlovac¡ te‡ka

CreaPro6:mov       al,"."
         stosb

; ------ dek¢dov n¡ p©¡pony - mˆs¡c

         mov       al,ds:[BegDateM]         ; po‡ te‡n¡ datum - mˆs¡c
         add       al,"0"                   ; korekce na znak ASCII
         cmp       al,"9"
         jbe       CreaPr62                 ; je platn˜ znak OK
         add       al,7                     ; korekce na p¡smeno
         cmp       al,"Z"
         jbe       CreaPr62
         mov       al,"Z"
CreaPr62:stosb                              ; ulo‘en¡ znaku mˆs¡ce

; ------ dek¢dov n¡ p©¡pony - den

         mov       al,ds:[BegDateD]         ; po‡ te‡n¡ datum - den
         add       al,"0"                   ; korekce na znak ASCII
         cmp       al,"9"
         jbe       CreaPr64                 ; je platn˜ znak OK
         add       al,7                     ; korekce na p¡smeno
         cmp       al,"Z"
         jbe       CreaPr64
         mov       al,"Z"
CreaPr64:stosb                              ; ulo‘en¡ znaku dne

; ------ po©adov‚ ‡¡slo souboru a koncov  0

         mov       ax,"0"                   ; ‡¡slo 0 + koncov  0
         stosw                              ; ulo‘en¡ po©adov‚ho ‡¡sla souboru

; ------ vytvo©en¡ v˜stupn¡ho adres ©e

         mov       dx,offset ProtSpec       ; adres © s protokoly
         mov       ah,39h
         int       21h                      ; vytvo©en¡ adres ©e

; ------ nastaven¡ adresy bufferu DTA

         mov       dx,offset BuffDTA        ; buffer DTA
         mov       ah,1ah
         int       21h                      ; nastaven¡ adresy bufferu DTA

; ------ zv˜¨en¡ ‡¡sla p©¡pony

CreaPro7:mov       di,offset PROTFIL0+8+1+3 ; konec jm‚na s p©¡ponou
         clc                                ; p©¡znak, ‘e je pot©eba zv˜¨en¡
         call      CreaProD                 ; zv˜¨en¡ 1. znaku
         call      CreaProD                 ; zv˜¨en¡ 2. znaku
         call      CreaProD                 ; zv˜¨en¡ 3. znaku

; ------ sestaven¡ jm‚na souboru

         mov       di,ds:[ProtSpcA]         ; konec cesty protokol–
         mov       si,offset PROTFIL1       ; buffer se jm‚nem souboru
         mov       cx,1+8+1+3+1             ; d‚lka jm‚na souboru
         cld
         rep       movsb                    ; p©enesen¡ jm‚na souboru

; ------ test, zda soubor ji‘ existuje

         mov       dx,offset ProtSpec       ; adres © s protokoly
         mov       cx,110111b               ; atributy - v¨echny soubory
         mov       ah,4eh
         int       21h                      ; test, zda soubor ji‘ existuje
         jnc       CreaPro7                 ; soubor ji‘ existuje - dal¨¡ pokus

; ------ vytvo©en¡ v˜stupn¡ho souboru

         xor       cx,cx                    ; atributy vytvo©en‚ho souboru
         mov       ah,3ch
         int       21h                      ; vytvo©en¡ v˜stupn¡ho souboru
         jc        CreaPro9                 ; chyba vytvo©en¡ souboru
         mov       ds:[ProtIdnt],ax         ; identifik tor souboru protokolu

; ------ n vrat registr–

CreaPro9:pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

CreaProt ENDP

; ------ dek¢dov n¡ jednoho znaku p©¡pony (CY=neprov d¡ se zv˜¨en¡ znaku)

CreaProD:dec       di                       ; sn¡‘en¡ ukazatele znak–
         jc        CreaPrD8                 ; neprov d¡ se zv˜¨en¡ znaku
         inc       byte ptr ds:[di]         ; zv˜¨en¡ znaku
         cmp       byte ptr ds:[di],"9"+1
         jne       CreaPrD2                 ; nen¡ p©ete‡en¡
         add       byte ptr ds:[di],7       ; oprava na p¡smeno
CreaPrD2:cmp       byte ptr ds:[di],"Z"+1   ; je platn‚ p¡smeno ?
         jb        CreaPrD8                 ; je je¨tˆ platn‚ p¡smeno
         mov       byte ptr ds:[di],"1"     ; p©ete‡en¡ na 1
CreaPrD8:ret

; -----------------------------------------------------------------------------
;        z pis z hlav¡ protokolu
; -----------------------------------------------------------------------------

HeadProt PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      es

; ------ z pis jm‚na u‘ivatele

         push      ds
         pop       es                       ; ES <- datov˜ segment

         mov       dx,offset ProtName       ; buffer jm‚na u‘ivatele
         mov       cx,ds:[ProtNamN]         ; d‚lka jm‚na u‘ivatele
         add       cx,offset(ProtNamB-ProtName) + 2 ; + text + CR/LF
         call      WritProt                 ; z pis jm‚na u‘ivatele
         jc        HeadPro3                 ; chyba z pisu

; ------ z pis data

         mov       si,offset ProtTxt2
         call      AsciProt                 ; z pis nadpisu data
         jc        HeadPro3                 ; chyba z pisu
         mov       al,ds:[BegDateD]         ; po‡ te‡n¡ datum - den
         call      NumProt0                 ; z pis dne, z pis oddˆlovac¡ te‡ky
         jc        HeadPro3                 ; chyba z pisu
         mov       al,ds:[BegDateM]         ; po‡ te‡n¡ datum - mˆs¡c
         call      NumProt2                 ; z pis mˆs¡ce, z pis oddˆlovac¡ te‡ky
         jc        HeadPro3                 ; chyba z pisu
         mov       ax,ds:[BegDateY]         ; po‡ te‡n¡ datum - rok
         call      NumProtA                 ; z pis roku, z pis nadpisu ‡asu
         jc        HeadPro3                 ; chyba z pisu

; ------ z pis ‡asu

         mov       al,ds:[BegTimeH]         ; po‡ te‡n¡ ‡as - hodina
         call      NumProt0                 ; z pis hodiny, z pis dvojte‡ky
         jc        HeadPro3                 ; chyba z pisu
         mov       al,ds:[BegTimeM]         ; po‡ te‡n¡ ‡as - minuta
         call      NumProt2                 ; z pis minuty, z pis nadpisu d‚lky
HeadPro3:jc        HeadPro9                 ; chyba z pisu

; ------ z pis d‚lky testu

         mov       ax,ds:[AktDoba]          ; d‚lka testu
         xor       dx,dx
         mov       cx,60                    ; po‡et sekund na minutu
         div       cx                       ; p©epo‡et na minuty a sekundy
         call      NumProtA                 ; z pis d‚lky (minut)
         jc        HeadPro9                 ; chyba z pisu
         xchg      ax,dx                    ; AX <- d‚lka sekund
         call      NumProtA                 ; z pis d‚lky (sekund)
         jc        HeadPro9                 ; chyba z pisu
         mov       al,ds:[AktDobaS]         ; d‚lka testu - setiny sekundy
         mov       ah,0
         add       ax,5                     ; zaokrouhlen¡ nahoru
         cmp       ax,100
         jb        HeadPro4
         mov       ax,99
HeadPro4:mov       cl,10
         div       cl                       ; v˜po‡et desetin sekundy
         call      NumProt0                 ; z pis desetin sekundy
         jc        HeadPro9                 ; chyba z pisu

; ------ z pis po‡tu £hoz–

         mov       ax,ds:[Uhozy]            ; po‡et £hoz– celkem
         call      NumProtA                 ; z pis po‡tu £hoz–
         jc        HeadPro9                 ; chyba z pisu

; ------ z pis v˜konu

         mov       ax,ds:[Vykon]            ; v˜kon
         call      NumProtA                 ; z pis v˜konu
         jc        HeadPro9                 ; chyba z pisu

; ------ z pis po‡tu oprav

         mov       ax,ds:[Opravy]           ; po‡et oprav
         call      NumProtA                 ; z pis po‡tu oprav
         jc        HeadPro9                 ; chyba z pisu

; ------ z pis typu kl vesnice

         mov       ax,ds:[AktKlav]          ; aktivn¡ kl vesnice
         mov       si,offset ProtKlvC       ; ‡esk 
         or        ax,ax
         jz        HeadPro5
         mov       si,offset ProtKlv1       ; program torsk  1
         dec       ax
         jz        HeadPro5
         mov       si,offset ProtKlv2       ; program torsk  2
         dec       ax
         jz        HeadPro5
         mov       si,offset ProtKlvI       ; kl vesnice IBM
HeadPro5:call      AsciProt                 ; z pis textu

; ------ n vrat registr–

HeadPro9:pop       es
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

HeadProt ENDP

; ------ z pis ‡¡sla AL 2 ‡¡slice

NumProt2:cmp       al,10
         jae       NumProt0                 ; nebudou 2 ‡¡slice
         push      ax
         xor       ax,ax
         call      NumProt                  ; z pis ‡¡sla 0
         pop       ax

; ------ z pis ‡¡sla AX (AL) a potom textu ES:SI

NumProt0:mov       ah,0                     ; bude z pis bajtu AL
NumProtA:call      NumProt                  ; z pis ‡¡sla AX
         jc        NumProtB
         call      AsciProt                 ; z pis textu ES:SI
NumProtB:ret

; -----------------------------------------------------------------------------
;        z pis v˜sledku testu do protokolu
; -----------------------------------------------------------------------------

TestProt PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      es

; ------ z pis jm‚na souboru

         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       si,offset ProtTest
         call      AsciProt                 ; z pis za‡ tku textu
         jc        TestPro9                 ; chyba z pisu

; ------ z pis po‡tu chyb

         mov       ax,ds:[CitChyb]          ; po‡et chyb
         call      NumProtA                 ; z pis po‡tu chyb
         jc        TestPro9                 ; chyba z pisu

; ------ v˜po‡et % chyb

         xor       dx,dx                    ; DX <- 0
         mov       cx,ds:[Uhozy]            ; po‡et £hoz–
         jcxz      TestPro4
         div       cx
         xor       ax,ax
         div       cx                       ; desetiny ‡ sti chyb
         add       ax,3                     ; zaokrouhlen¡ nahoru
         mov       dx,10000
         mul       dx                       ; ‡ st chyb
         xor       ax,ax
         xchg      ax,dx
         mov       cx,100
         div       cx                       ; rozdˆlen¡ na celou ‡ st a setiny

; ------ zobrazen¡ % chyb - cel  ‡ st

TestPro4:push      dx
         call      NumProtA                 ; zobrazen¡ % chyb - cel  ‡ st
         pop       ax
         jc        TestPro9

; ------ zobrazen¡ % chyb - setiny

         call      NumProt2

; ------ n vrat registr–

TestPro9:pop       es
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

TestProt ENDP

; -----------------------------------------------------------------------------
;        z pis ‡¡sla AX do souboru protokolu
; -----------------------------------------------------------------------------

NumProt  PROC      NEAR

; ------ £schova registr–

         push      cx
         push      dx
         push      di
         push      es

; ------ dek¢dov n¡ ‡¡sla do bufferu

         mov       di,offset ProtBuff       ; buffer k dek¢dov n¡ ‡¡sla
         push      di                       ; £schova adresu bufferu
         push      ds
         pop       es                       ; ES <- datov˜ segment
         xor       dx,dx                    ; DX <- ‡¡slo HIGH
         call      DekNum                   ; dek¢dov n¡ ‡¡sla do bufferu
         pop       dx                       ; za‡ tek bufferu

; ------ z pis ‡¡sla do souboru

         mov       cx,di                    ; CX <- konec textu
         sub       cx,dx                    ; d‚lka textu

IFDEF    DEMO
         push      ax
         push      cx
         push      di

         mov       di,dx
         cld
         mov       al,"?"
         rep       stosb                    ; vymaz n¡ ‡¡sla p©i DEMO

         pop       di
         pop       cx
         pop       ax
ENDIF
         call      WritProt                 ; z pis ‡¡sla do souboru

; ------ n vrat registr–

         pop       es
         pop       di
         pop       dx
         pop       cx
         ret

NumProt  ENDP

; -----------------------------------------------------------------------------
;        z pis po‡tu £hoz– © dku a konce © dku CR/LF do bufferu protokolu
; -----------------------------------------------------------------------------

UhoLProt PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      di
         push      es

; ------ pozice na © dku protokolu

         mov       di,ds:[ProtPoz]          ; pozice na © dku
         or        di,di                    ; je nˆco v bufferu ?
         jz        UhoLPrt9                 ; nen¡ nic v bufferu

; ------ po‡et mezer k z pisu do bufferu

         mov       cx,SIRTEXT+2             ; po‘adovan  pozice
         sub       cx,di                    ; chybˆj¡c¡ po‡et pozic
         mov       al," "                   ; znak mezery
         ja        UhoLPrt2                 ; jsou nˆjak‚ mezery
         mov       cx,1                     ; alespo¤ 1 mezera se ulo‘¡

; ------ doplnˆn¡ mezer do konce © dku

UhoLPrt2:call      OutProt                  ; v˜stup bajtu do bufferu
         loop      UhoLPrt2

; ------ p©¡prava bufferu k dek¢dov n¡ ‡¡sla

UhoLPrt4:push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       di,offset ProtBuff       ; buffer k dek¢dov n¡ ‡¡sla
         cld

; ------ dek¢dov n¡ po‡tu £hoz– do bufferu

         push      di
         stosb                              ; 1. mezera
         stosb                              ; 2. mezera
         mov       ax,ds:[CitLUhoz]         ; po‡et £hoz– na © dku
         cmp       ax,10                    ; bude 1 znak ?
         jb        UhoLPrt5                 ; bude 1 znak
         dec       di
         cmp       ax,100                   ; budou 2 znaky ?
         jb        UhoLPrt5                 ; budou 2 znaky
         dec       di
UhoLPrt5:xor       dx,dx                    ; DX <- 0
         call      DekNum                   ; dek¢dov n¡ ‡¡sla do bufferu
         pop       di

; ------ ulo‘en¡ ‡¡sla do bufferu

         mov       cx,3                     ; 3 znaky
UhoLPrt6:mov       al,ds:[di]               ; znak k ulo‘en¡
IFDEF    DEMO
         mov       al,"?"
ENDIF
         inc       di
         call      OutProt                  ; ulo‘en¡ znaku
         loop      UhoLPrt6

; ------ p©¡znak cbyb na © dku

         cmp       word ptr ds:[CitChybL],0 ; byla chyba ?
         je        UhoLPrt8                 ; nebyla chyba
         mov       al,"/"                   ; p©¡znak chyby
         call      OutProt                  ; ulo‘en¡ znaku

; ------ dek¢dov n¡ po‡tu chyb do bufferu

         mov       di,offset ProtBuff       ; buffer k dek¢dov n¡ ‡¡sla
         mov       ax,ds:[CitChybL]         ; po‡et chyb
         xor       dx,dx
         push      di
         call      DekNum                   ; dek¢dov n¡ ‡¡sla do bufferu
         mov       cx,di                    ; konec textu
         pop       di
         sub       cx,di                    ; d‚lka textu

; ------ ulo‘en¡ ‡¡sla do v˜stupu

UhoLPrt7:mov       al,ds:[di]
IFDEF    DEMO
         mov       al,"?"
ENDIF
         inc       di
         call      OutProt
         loop      UhoLPrt7

; ------ z pis konce © dku CR/LF

UhoLPrt8:mov       al,13
         call      OutProt
         mov       al,10
         call      OutProt

; ------ n vrat registr–

UhoLPrt9:pop       es
         pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

UhoLProt ENDP

; -----------------------------------------------------------------------------
;        z pis v˜stupn¡ho textu protokolu (CY=chyba)
; -----------------------------------------------------------------------------

VystProt PROC      NEAR

; ------ £schova registr–

         push      cx
         push      dx
         push      es

; ------ z pis v˜stupn¡ho textu

         mov       cx,ds:[VystupN]          ; po‡et bajt– v bufferu
         mov       dx,SEG VystupS           ; segment bufferu
         mov       es,dx
         xor       dx,dx                    ; DX <- 0 offsetr bufferu
         call      WritProt                 ; z pis v˜stupn¡ho textu

; ------ n vrat registr–

         pop       es
         pop       dx
         pop       cx
         ret

VystProt ENDP

; -----------------------------------------------------------------------------
;        z pis oddˆlovac¡ ‡ ry do v˜stupn¡ho protokolu (CY=chyba)
; -----------------------------------------------------------------------------

CarProt  PROC      NEAR

; ------ £schova registr–

         push      cx
         push      dx
         push      es

; ------ z pis oddˆlovac¡ ‡ ry

         mov       dx,offset ProtTxt6       ; text ‡ ry
         mov       cx,offset(ProtTxt7-ProtTxt6) ; d‚lka ‡ ry
         push      ds
         pop       es                       ; ES <- datov˜ segment
         call      WritProt                 ; z pis ‡ ry

; ------ n vrat registr–

         pop       es
         pop       dx
         pop       cx
         ret

CarProt  ENDP

; -----------------------------------------------------------------------------
;        z pis ASCIIZ textu od adresy ES:SI (CY=chyba, SI=nov  adresa)
; -----------------------------------------------------------------------------

AsciProt PROC      NEAR

; ------ £schova registr–

         push      cx
         push      dx
         mov       dx,si                    ; DX <- za‡ tek textu

; ------ stanoven¡ d‚lky textu

         xor       cx,cx                    ; CX <- 0 ‡¡ta‡ d‚lky textu
         dec       cx
AsciPrt2:inc       cx                       ; zv˜¨en¡ ‡¡ta‡e d‚lky textu
         inc       si                       ; zv˜¨en¡ ukazatele textu
         cmp       byte ptr es:[si-1],0     ; je konec textu ?
         jne       AsciPrt2                 ; nalezen¡ konce textu

; ------ z pis dat do souboru

         call      WritProt                 ; z pis dat do souboru

; ------ n vrat registr–

         pop       dx
         pop       cx
         ret

AsciProt ENDP

; -----------------------------------------------------------------------------
; z pis CX bajt– od adresy ES:DX do souboru protokolu (CY=chyba, DX=nov  adresa)
; -----------------------------------------------------------------------------

WritProt PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      ds

; ------ z pis dat

         mov       bx,ds:[ProtIdnt]         ; identifik tor souboru
         push      es
         pop       ds                       ; DS <- segment bufferu
         mov       ah,40h
         int       21h                      ; z pis dat

; ------ kontrola operace z pisu

         jc        WritPrt9                 ; chyba z pisu
         add       dx,ax                    ; posun adresy
         cmp       ax,cx                    ; zaps no v¨e ?
                                          ;* (CY=disk pln˜)
; ------ n vrat registr–

WritPrt9:pop       ds
         pop       bx
         pop       ax
         ret

WritProt ENDP

; -----------------------------------------------------------------------------
;        uzav©en¡ souboru protokolu (uchov v  p©¡znaky !)
; -----------------------------------------------------------------------------

ClosProt PROC      NEAR

; ------ £schova registr–

         pushf
         push      ax
         push      bx
         push      cx
         push      dx

; ------ uzav©en¡ souboru

         xor       bx,bx                    ; BX <- 0
         xchg      bx,ds:[ProtIdnt]         ; identifik tor souboru
         or        bx,bx                    ; je otev©en ?
         jz        ClosPrt9                 ; nen¡ otev©en
         mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru

; ------ nastaven¡ atributu R/O

         mov       dx,offset Soubor         ; jm‚no souboru
         mov       cx,bit0                  ; atributy - R/O
         mov       ax,4301h
         int       21h                      ; nastaven¡ atribut– souboru R/O

; ------ n vrat registr–

ClosPrt9:pop       dx
         pop       cx
         pop       bx
         pop       ax
         popf
         ret

ClosProt ENDP

; -----------------------------------------------------------------------------
;        zad n¡ jm‚na u‘ivatele (CY=p©eru¨en¡)
; -----------------------------------------------------------------------------

Jmeno    PROC      NEAR

; ------ vymaz n¡ pap¡ru

         call      NovyPap                  ; nov˜ pap¡r

; ------ zobrazen¡ v˜zvy k zad n¡ jm‚na

         push      ds
         pop       es
         mov       si,offset JmenTxt
         call      DispTTxt

; ------ zobrazen¡ doby omezen¡ testu

         xor       dx,dx
         mov       ax,ds:[Omezeni]          ; omezen¡ doby (minut)
         mov       bh,ds:[TColBold]         ; zv˜raznˆn‚ p¡smo
         call      DispTNum                 ; zobrazen¡ doby omezen¡

; ------ zbytek textu

         mov       si,offset JmenTxt1
         dec       ax                       ; je 1 minuta ?
         jz        Jmeno1                   ; je 1 minuta
         mov       si,offset JmenTxt2
         sub       ax,4-1
         jbe       Jmeno1                   ; 2 a‘ 4 minut
         mov       si,offset JmenTxt3
Jmeno1:  call      DispTTxt

; ------ p©¡prava k zad n¡ jm‚na u‘ivatele

         mov       si,offset ProtNamB       ; buffer jm‚na
         mov       byte ptr ds:[ProtNamN],0 ; nulov n¡ d‚lky jm‚na
         mov       di,5*FONTEXT*80 + LFTTEXT + 4 ; pozice k zobrazen¡ kurzoru

; ------ zobrazen¡ kurzoru

Jmeno2:  mov       al,"Û"
         mov       ah,ds:[TColKeys]         ; zv˜raznˆn  barva
         call      DispChr                  ; zobrazen¡ kurzoru

; ------ ‡ek n¡ na zad n¡ znaku

         call      InpKey                   ; vstup znaku z kl vesnice
         jnc       Jmeno21
         ret                                ; p©eru¨en¡ volby ESC

; ------ vypnut¡ kurzoru

Jmeno21: push      ax
         mov       al,"Û"
         mov       ah,ds:[TColPap]          ; barva pap¡ru
         call      DispChr                  ; vymaz n¡ kurzoru
         pop       ax

; ------ zru¨en¡ textu HOME

         cmp       ax,4700h                 ; HOME
         jne       Jmeno3
Jmeno22: cmp       byte ptr ds:[ProtNamN],0 ; je ji‘ za‡ tek jm‚na ?
         je        Jmeno2                   ; je ji‘ za‡ tek jm‚na
         dec       byte ptr ds:[ProtNamN]   ; sn¡‘en¡ d‚lky jm‚na
         dec       si                       ; sn¡‘en¡ ukazatele v bufferu
         dec       di
         mov       al,"Û"
         mov       ah,ds:[TColPap]          ; barva pap¡ru
         call      DispChr                  ; vymaz n¡ znaku
         jmp       short Jmeno22

; ------ zru¨en¡ znaku BS nebo DELETE

Jmeno3:  cmp       ax,4b00h                 ; kurzor vlevo
         je        Jmeno4
         cmp       al,8
         je        Jmeno4
         cmp       ax,5300h                 ; DELETE
         jne       Jmeno5
Jmeno4:  cmp       byte ptr ds:[ProtNamN],0 ; je ji‘ za‡ tek jm‚na ?
         je        Jmeno2                   ; je ji‘ za‡ tek jm‚na
         dec       byte ptr ds:[ProtNamN]   ; sn¡‘en¡ d‚lky jm‚na
         dec       si                       ; sn¡‘en¡ ukazatele v bufferu
         dec       di
Jmeno42: jmp       short Jmeno2

; ------ ukon‡en¡ volby ENTER

Jmeno5:  cmp       al,13                    ; je ENTER ?
         je        Jmeno9                   ; je ENTER

; ------ obnoven¡ znaku z bufferu

         cmp       ax,4d00h                 ; kurzor vpravo
         jne       Jmeno6
         mov       al,ds:[si]               ; znak v bufferu

; ------ obnoven¡ cel‚ho textu END

Jmeno6:  cmp       ax,4f00h                 ; END
         jne       Jmeno7
Jmeno62: cmp       byte ptr ds:[ProtNamN],62 ; maxim ln¡ d‚lka jm‚na
         jae       Jmeno42                  ; d‚lka jm‚na p©ekro‡ena
         mov       al,ds:[si]               ; znak k obnoven¡
         cmp       al," "
         jb        Jmeno42                  ; nepovolen˜ znak
         inc       si                       ; zv˜¨en¡ ukazatele textu
         inc       byte ptr ds:[ProtNamN]   ; zv˜¨en¡ ‡¡ta‡e d‚lky jm‚na
         mov       ah,ds:[TColKeys]         ; zv˜raznˆn  barva
         call      DispChr0                 ; zobrazen¡ znaku
         jmp       short Jmeno62

; ------ kontrola platnosti znaku

Jmeno7:  cmp       al," "
         jb        Jmeno42                  ; nepovolen˜ znak
         ja        Jmeno8                   ; nen¡ mezera
         cmp       byte ptr ds:[ProtNamN],0 ; je prvn¡ znak ?
         je        Jmeno42                  ; mezera nepovolena pro prvn¡ znak

; ------ vlo‘en¡ znaku do bufferu

Jmeno8:  cmp       byte ptr ds:[ProtNamN],62 ; maxim ln¡ d‚lka jm‚na
         jae       Jmeno42                  ; d‚lka jm‚na p©ekro‡ena
         mov       ds:[si],al               ; ulo‘en¡ znaku do bufferu
         inc       si                       ; zv˜¨en¡ ukazatele textu
         inc       byte ptr ds:[ProtNamN]   ; zv˜¨en¡ ‡¡ta‡e d‚lky jm‚na
         mov       ah,ds:[TColKeys]         ; zv˜raznˆn  barva
         call      DispChr0                 ; zobrazen¡ znaku
         jmp       short Jmeno42

; ------ ukon‡en¡ volby ENTER

Jmeno9:  mov       word ptr ds:[si],13 + 10*256 ; ozna‡en¡ CR/LF
         ret

Jmeno    ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ‡¡ta‡e £hoz– na © dku
; -----------------------------------------------------------------------------

DispLUhz PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      di

; ------ p©¡prava k zobrazen¡

         call      SetFNT08                 ; nastaven¡ fontu 8 linek
         mov       di,ENDTEXT-FONTEXT*80 - LINKURZ*80 + 4*80 + 77 ; adresa k zobrazen¡

; ------ vymaz n¡ pole

         mov       al,"Û"
         mov       ah,14                    ; svˆtle ‘lut  barva
         cmp       word ptr ds:[CitLUhoz],100
         jae       DispLUh2                 ; je velk˜ po‡et znak–
         mov       ah,ds:[TColPap]          ; barva pap¡ru
DispLUh2:call      DispChr0
         mov       ah,14                    ; svˆtle ‘lut  barva
         call      DispChr0
         call      DispChr

; ------ zobrazen¡ ‡¡ta‡e £hoz–

         xor       dx,dx
         mov       bh,1                     ; modr  barva
         mov       ax,ds:[CitLUhoz]         ; ‡¡ta‡ £hoz–
         call      DispNum                  ; zobrazen¡ ‡¡sla

; ------ n vrat registr–

         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispLUhz ENDP

; -----------------------------------------------------------------------------
;        ulo‘en¡ bajtu AL do bufferu v˜stupn¡ho protokolu (CY=p©ete‡en¡)
; -----------------------------------------------------------------------------

OutProt  PROC      NEAR

; ------ £schova registr–

         push      di
         push      es

; ------ p©¡prava ukazatele dat

         mov       di,SEG VystupS           ; v˜stupn¡ buffer
         mov       es,di                    ; ES <- v˜stupn¡ buffer
         mov       di,ds:[VystupN]          ; po‡et bajt– ve v˜stupn¡m bufferu

; ------ test, zda je buffer ji‘ pln˜

         inc       di                       ; je buffer ji‘ pln˜ ?
         stc                                ; p©¡znak p©ete‡en¡
         jz        OutProt8                 ; p©ete‡en¡ bufferu

; ------ ulo‘en¡ bajtu AL do bufferu

         mov       ds:[VystupN],di          ; nov˜ po‡et bajt– v bufferu
         dec       di
         cld
         stosb                              ; ulo‘en¡ bajtu AL do bufferu

; ------ znak CR neposunuje pozic¡

         cmp       al,CR
         je        OutProt7                 ; znak CR neposouv  pozici

; ------ znak LF nuluje pozici na © dku

         cmp       al,LF
         jne       OutProt3                 ; nen¡ LF
         mov       word ptr ds:[ProtPoz],-1 ; nulov n¡ pozice na © dku

; ------ jin˜ znak zv˜¨¡ pozici na © dku

OutProt3:inc       word ptr ds:[ProtPoz]    ; zv˜¨en¡ pozice na © dku
OutProt7:clc                                ; p©¡znak operace OK

; ------ n vrat registr–

OutProt8:pop       es
         pop       di
         ret

OutProt  ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ po‡tu £hoz– znaku AL -> DX
; -----------------------------------------------------------------------------

GetUhoz  PROC      NEAR

; ------ £schova registr–

         push      bx

; ------ po‡et £hoz– pro CR

         xor       dx,dx                    ; DX <- 0
         cmp       al,CR
         je        GetUhoz9

; ------ po‡et £hoz– pro LF (=ENTER !)

         inc       dx                       ; DX <- 1
         cmp       al,LF
         je        GetUhoz9

; ------ £hozy pro znaky < 32 (tj. s Ctrl-)

         inc       dx                       ; DX <- 2
         cmp       al," "
         jb        GetUhoz9

; ------ £hozy pro znaky > 175

         mov       dl,5                     ; po‡et £hoz– pro grafick‚ znaky
         cmp       al,175
         ja        GetUhoz9

; ------ £hozy pro bˆ‘n‚ znaky

         mov       bx,ds:[AdrUhoz]          ; tabulka £hoz–
         add       bl,al                    ; BL <- znak
         adc       bh,0
         mov       dl,ds:[bx-32]            ; po‡et £hoz– znaku

; ------ n vrat registr–

GetUhoz9:pop       bx
         ret

GetUhoz  ENDP

; -----------------------------------------------------------------------------
;        v˜po‡et v˜konu (CY=nelze vypo‡¡tat, m lo £hoz–)
; -----------------------------------------------------------------------------

GetVykon PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx

; ------ p©¡prava doby v setin ch sekundy -> BX:CX

         mov       ax,100                   ; konstanta pro p©epo‡et
         mul       word ptr ds:[AktDoba]    ; doba v setin ch sekundy
         add       al,ds:[AktDobaS]         ; p©i‡ten¡ setin sekundy
         adc       ah,0
         adc       dx,0
         xchg      ax,cx                    ; CX <- doba LOW
         mov       bx,dx                    ; BX <- doba HIGH

; ------ kontrola, zda lze v˜kon vypo‡¡tat

         mov       word ptr ds:[Vykon],0    ; p©ednastaven¡ - neplatn˜ v˜kon
         cmp       word ptr ds:[Uhozy],2    ; jsou minim lnˆ 2 £hozy ?
         jb        GetVykn9                 ; je m lo £hoz–

; ------ trestn‚ £hozy

         mov       ax,10                    ; 10 £hoz– na 1 chybu
         mul       word ptr ds:[CitChyb]    ; po‡et trestn˜ch £hoz–
         xchg      ax,dx                    ; DX <- po‡et trestn˜ch £hoz–

; ------ po‡et ‡ist˜ch £hoz–

         mov       ax,ds:[Uhozy]            ; po‡et £hoz–
         dec       ax                       ; bez prvn¡ho £hozu
         sub       ax,dx                    ; bez trestn˜ch £hoz–
         jnc       GetVykn1                 ; je to OK
         xor       ax,ax                    ; po‡et £hoz– = 0

; ------ po‡et ‡ist˜ch £hoz– * 6000

GetVykn1:mov       dx,6000                  ; pro p©epo‡et na minutu
         mul       dx                       ; po‡et £hoz– * 6000

; ------ normalizace dˆlitele

GetVykn2:or        bx,bx                    ; je ji‘ dˆlitel < 64K ?
         jz        GetVykn4                 ; dˆlitel je ji‘ OK
         shr       dx,1
         rcr       ax,1                     ; dˆlenec / 2
         shr       bx,1
         rcr       cx,1                     ; dˆlitel / 2
         jmp       short GetVykn2

; ------ test, zda je dˆlitel = 0

GetVykn4:stc                                ; p©¡znak chyby
         jcxz      GetVykn9                 ; chyba - dˆlitel je = 0

; ------ zaokrouhlen¡

         mov       bx,cx
         shr       bx,1
         add       ax,bx
         adc       dx,0

; ------ omezen¡ dˆlence (pro ochranu proti p©ete‡en¡)

         cmp       dx,cx                    ; bylo by p©ete‡en¡ ?
         jb        GetVykn6                 ; nebylo by p©ete‡en¡
         mov       dx,cx
         dec       dx
         mov       ax,-1

; ------ v˜po‡et v˜konu pro 1 minutu

GetVykn6:div       cx                       ; po‡et £hoz– za minutu
         mov       ds:[Vykon],ax            ; v˜kon (£hoz– za minutu)
         clc                                ; p©¡znak operace OK

; ------ n vrat registr–

GetVykn9:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

GetVykon ENDP

; *****************************************************************************
;
;                               Test
;
; *****************************************************************************
;þ
; ------ zad n¡ jm‚na u‘ivatele

Testy:   call      Jmeno                    ; zad n¡ jm‚na u‘ivatele
         jnc       Testy1
         jmp       Start4                   ; p©eru¨en¡ operace

; ------ na‡ten¡ seznamu soubor–

Testy1:  call      VyberRea                 ; na‡ten¡ seznamu soubor–

; ------ chybov‚ hl ¨en¡, ‘e nebyl nalezen ‘ dn˜ soubor

         cmp       word ptr ds:[FileNum],0  ; bylo nˆco nalezeno ?
         jne       Testy4                   ; bylo nˆco nalezeno
         mov       di,(80-offset(NFndTxt0-NFndTxt)+3)/2 + 160*80
         mov       si,offset NFndTxt
Testy32: call      VyberRam                 ; vymaz n¡ obrazovky pro v˜bˆr
         call      SetFNT16                 ; nastaven¡ fontu 16 linek
         push      ds
         pop       es
         call      DispTxt                  ; zobrazen¡ chybov‚ho hl ¨en¡
         mov       ah,0
         int       16h                      ; ‡ek n¡ na stisk kl vesy
Testy34: jmp       Start3                   ; n vrat do hlavn¡ho menu

; ------ v˜bˆr souboru ze seznamu

Testy4:  call      VyberSrt                 ; set©¡dˆn¡ seznamu soubor–
         call      VyberVol                 ; v˜bˆr souboru ze seznamu
         jc        Testy34                  ; p©eru¨en¡ operace

; ------ na‡ten¡ zvolen‚ho souboru do bufferu

         call      VyberOpn                 ; na‡ten¡ souboru do bufferu
         jnc       Testy6                   ; soubor na‡ten OK

; ------ chyba otev©en¡ souboru testu

         mov       di,(80-offset(ReadTxt0-ReadTxt)+3)/2 + 160*80
         mov       si,offset ReadTxt
         jmp       short Testy32            ; chybov‚ hl ¨en¡

; ------ obnoven¡ zobrazen¡ prav¡tka

Testy6:  call      NovyPap                  ; nov˜ pap¡r
         call      Lineal                   ; zobrazen¡ prav¡tka

; ------ korekce dat v bufferu

         call      VyberKor                 ; korekce dat v bufferu

; ------ proveden¡ testu

         and       byte ptr ds:[ParTest],not bit0+bit1+bit3 ; inic. parametr–
         cmp       byte ptr ds:[Editace],0  ; povolena editace ?
         jne       Testy61                  ; ne povolena editace
         or        byte ptr ds:[ParTest],bit0 ; nen¡ editace - je kontrola
Testy61: mov       ax,SEG VstupS
         mov       es,ax                    ; ES <- segment bufferu
         xor       si,si                    ; po‡ tek dat
         call      TestT                    ; test
         jc        Testy1                   ; p©eru¨en¡ operace

; ------ z pis souboru protokolu

         call      CreaProt                 ; vytvo©en¡ souboru protokolu
         jc        Testy7                   ; chyba vytvo©en¡ souboru
         call      HeadProt                 ; z pis z hlav¡ souboru protokolu
         jc        Testy7                   ; chyba z pisu
         call      TestProt                 ; z pis v˜sledku testu
         jc        Testy7                   ; chyba z pisu
         call      CarProt                  ; z pis ‡ ry
         jc        Testy7                   ; chyba z pisu
         call      VystProt                 ; z pis v˜stupn¡ho textu
         jc        Testy7                   ; chyba z pisu
         call      CarProt                  ; z pis ‡ ry
Testy7:  jmp       Procv7

; -----------------------------------------------------------------------------
;        proveden¡ testu ES:SI (CY=p©eru¨en¡, ES:SI=nov  adresa textu) CY=p©eru¨en¡
; -----------------------------------------------------------------------------
; v procedu©e se udr‘uje: ES:SI=ukazatel vzoru textu
;                         DL=ukazatel © dku na obrazovce (0 a‘ 8)
;                         BP=adresa za‡ tku textu (navr t¡ se p©i p©eru¨en¡)
; -----------------------------------------------------------------------------
; 1 chyba:
;           - zmˆnˆn˜ znak
;           - zamˆnˆn‚ 2 sousedn¡ znaky
;           - chybˆj¡c¡ znak
;           - p©idan˜ znak
;
;           - chybˆj¡c¡ slovo
;           - p©idan‚ slovo
;           (- zamˆnˆn  2 sousedn¡ slova)
;
;           (- chybˆj¡c¡ © dek)
;           (- p©idan˜ © dek)
;           (- zamˆnˆn‚ 2 © dky)
;
; Chyba v posledn¡ch 10 £hozech napsan‚ho textu se nepo‡¡t . Po‡et hrub˜ch £hoz–
; kon‡¡ posledn¡m spr vn˜m £hozem.
;
; hrub‚_£hozy = sou‡et v¨ech £hoz–
;
; trestn‚_£hozy = po‡et_chyb * 10
;
; ‡ist‚_£hozy = hrub‚_£hozy - trestn‚_£hozy
;
; v˜kon = ‡ist‚_£hozy / minut_opisu
;
; p©esnost (chybovost) = po‡et_chyb * 100 / hrub‚_£hozy
;
; Zn mky: v˜born˜ (0.00 a‘ 0.20% chyb)
;         chvalitebn˜ (0.21 a‘ 0.40% chyb)
;         dobr˜ (0.41 a‘ 0.60% chyb)
;         dostate‡n˜ (0.61 a‘ 0.80% chyb)
;         nedostate‡n˜ (0.81 a v¡ce % chyb)
; -----------------------------------------------------------------------------

TestT    PROC      NEAR

; ------ £schova aktu ln¡ho nastaven¡ rolov n¡ pap¡ru

         push      bp
         push      word ptr ds:[IncRoll]    ; p©¡rustek adresy pro rolov n¡
         push      word ptr ds:[LinRoll]    ; po‡et linek na v˜¨ku © dku

; ------ nastaven¡ rolov n¡ pap¡ru a inicializace ukazatel–

         mov       word ptr ds:[IncRoll],(FONTEXT + 8)*80 ; p©¡rustek adresy
         mov       word ptr ds:[LinRoll],FONTEXT + 8 ; po‡et linek na v˜¨ku © dku

; ------ vymaz n¡ pap¡ru pro v˜stup textu

         call      NovyPap                  ; nov˜ pap¡r

; ------ zobrazen¡ textu p©edlohy

         mov       bp,si                    ; £schova adresy za‡ tku testu
         mov       bx,si                    ; adresa textu testu
         call      DispTest                 ; zobrazen¡ textu testu

; ------ podtr‘en¡ prvn¡ho © dku textu p©edlohy

         mov       dl,0                     ; ukazatel ‡¡sla © dku
         call      Podtrh                   ; zobrazen¡ podtr‘en¡

; ------ nulov n¡ ukazatel–

         call      NulMetr                  ; nulov n¡ metronomu
         call      DispKurz                 ; zobrazen¡ kurzoru
         call      MazTime                  ; vymaz n¡ plochy k zobrazen¡ ‡asu
         call      NulUhoz                  ; nulov n¡ ‡¡ta‡e £hoz–

; ------ ‡ek n¡ na zad n¡ prvn¡ho znaku (a odstartov n¡ testu)

TestT1:  call      LupMetr                  ; obsluha metronomu
         call      TestKey                  ; test znaku z kl vesnice
         jc        TestT1                   ; ‡ek n¡ na prvn¡ stisk kl vesy

; ------ nulov n¡ ukazatel–

         call      NulTime                  ; nulov n¡ ‡¡ta‡e ‡asu
         call      MazTime                  ; vymaz n¡ plochy k zobrazen¡ ‡asu
         mov       word ptr ds:[ProtPoz],0  ; nulov n¡ pozice na © dku
         mov       word ptr ds:[VystupN],0  ; nulov n¡ v˜stupn¡ho bufferu
         mov       word ptr ds:[CitChyb],0  ; ‡¡ta‡ chyb
         mov       word ptr ds:[Opravy],0   ; ‡¡ta‡ proveden˜ch oprav

; ------ z pis jednoho © dku

TestT2:  push      dx                       ; DL = ‡¡slo © dku
         push      bx                       ; BX = za‡ tek © dku
         call      EditLine                 ; z pis jednoho © dku
         pop       bx
         pop       dx

; ------ z pis obsahu © dku do bufferu, z pis po‡tu znak– na © dku

         pushf
         push      bx
         push      cx
         test      byte ptr ds:[ParTest],bit0 ; kontrola chyb p©i z pisu ?
         jnz       TestT35                  ; byla okam‘it  kontrola chyb
         xor       bx,bx                    ; ukazatel znak– v bufferu
         mov       cx,ds:[PozTxt]           ; po‡et ulo‘en˜ch znak–
         mov       ds:[PozTxt],bx           ; nulov n¡ ukazatele pozice na © dku
         jcxz      TestT34                  ; nen¡ ‘ dn˜ znak
TestT3:  mov       al,ds:[bx+LinBuff]       ; znak z bufferu
         call      EditTest                 ; test zadan‚ho znaku
         inc       bx                       ; zv˜¨en¡ ukazatele v bufferu
         inc       word ptr ds:[PozTxt]     ; zv˜¨en¡ ukazatele znak– na © dku
         loop      TestT3                   ; dal¨¡ znak
TestT34: cmp       word ptr ds:[CitChybL],0 ; byla chyba na © dku ?
         je        TestT35                  ; nebyla chyba na © dku
         call      TestBErr                 ; p¡pnut¡ p©i chybˆ
TestT35: call      UhoLProt                 ; z pis po‡tu £hoz– do bufferu
         call      ClrPod                   ; vymaz n¡ podtr‘en¡

; ------ nalezen¡ za‡ tku dal¨¡ho © dku

TestT36: cmp       byte ptr es:[si],EOT     ; konec textu ?
         je        TestT37
         cmp       byte ptr es:[si],FF      ; nov  str nka ?
         je        TestT37                  ; nov  str nka
         inc       si                       ; zv˜¨en¡ ukazatele textu
         cmp       byte ptr es:[si-1],LF    ; byl konec © dku ?
         jne       TestT36                  ; nalezen¡ konce © dku
TestT37: pop       cx
         pop       bx
         popf
         jc        TestT5                   ; p©eru¨en¡ testu

; ------ test, zda je ji‘ konec textu

         cmp       byte ptr es:[si],EOT     ; je konec textu ?
         je        TestT5                   ; je konec textu
         cmp       byte ptr es:[si],FF      ; nov  str nka ?
         je        TestT5                   ; je konec textu

; ------ test, zda je v˜stupn¡ buffer ji‘ pln˜

         mov       di,ds:[VystupN]          ; po‡et bajt– ve v˜stupn¡m bufferu
         inc       di                       ; je buffer ji‘ pln˜ ?
         jz        TestT5                   ; buffer je ji‘ pln˜

; ------ posun textu o jeden © dek

         mov       word ptr ds:[CitChybL],0 ; nulov n¡ ‡¡ta‡e chyb na © dku
         mov       word ptr ds:[CitLUhoz],0 ; nulov n¡ ‡¡ta‡e £hoz–
         call      RollText                 ; rolov n¡ textu
         inc       dx                       ; zv˜¨en¡ ukazatele © dku
         cmp       dl,TESTLINE-2            ; je ji‘ posledn¡ © dek ?
         jb        TestT4                   ; nen¡ je¨tˆ posledn¡ © dek
         dec       dx                       ; n vrat na posledn¡ © dek
         call      NextTest                 ; dal¨¡ © dek textu
TestT4:  call      Podtrh                   ; zobrazen¡ podtr‘en¡
         jmp       TestT2                   ; dal¨¡ © dek

; ------ vypnut¡ kurzoru

TestT5:  call      MazKurz                  ; vypnut¡ kurzoru

; ------ v˜po‡et a zobrazen¡ v˜konu

         call      GetVykon                 ; v˜po‡et v˜konu
         jnc       TestT52                  ; lze vypo‡¡tat OK
         mov       si,bp                    ; p©i p©eru¨en¡ n vrat adresy testu
         jmp       TestT9                   ; p©eru¨en¡
TestT52: call      DispVykn                 ; zobrazen¡ aktu ln¡ho v˜konu

; ------ £schova adresy textu

         push      si
         push      es

; ------ vymaz n¡ str nky k zobrazen¡ v˜sledk–

         call      ClrTest                  ; maz n¡ textu
         call      SetFNT16                 ; nastaven¡ fontu 16 linek
         push      ds
         pop       es                       ; ES <- datov˜ segment

; ------ text, ‘e uplynula doba k proveden¡ testu

         mov       ax,60                    ; po‡et sekund na minutu
         mul       word ptr ds:[Omezeni]    ; omezen¡ d‚lky testu v sekund ch
         cmp       ax,ds:[AktDoba]          ; uplynula doba pro test ?
         ja        TestT54                  ; nen¡ je¨tˆ dosa‘ena doba
         mov       di,TOPKLAV + (80-offset(TOutTxt0-TOutTxt)+3)/2 + 15*80
         mov       si,offset TOutTxt
         call      DispTxt                  ; zobrazen¡ hl ¨en¡

; ------ nadpis "Hodnocen¡"

TestT54: mov       di,TOPKLAV + (80-offset(TestTxt2-TestTxt1)+3)/2 + 45*80
         mov       si,offset TestTxt1
         call      DispTxt                  ; zobrazen¡ nadpisu

; ------ v˜kon

         mov       di,TOPKLAV + (80-offset(TestTxt4-TestTxt2)+2-3)/2 + 75*80
         mov       si,offset TestTxt2
         call      DispTxt
         mov       ax,ds:[Vykon]
         xor       dx,dx
         mov       bh,ds:[TColBold]
         call      DispLNum
         call      DispTxt

; ------ po‡et chyb

         mov       di,TOPKLAV + (80-offset(TestTxt6-TestTxt4)+2-3)/2 + 95*80
         mov       si,offset TestTxt4
         call      DispTxt


         mov       ax,ds:[CitChyb]          ; po‡et chyb
         xor       dx,dx                    ; DX <- 0
         mov       cx,ds:[Uhozy]            ; po‡et £hoz–
         jcxz      TestT61
         div       cx
         xor       ax,ax
         div       cx                       ; desetiny ‡ sti chyb
         add       ax,3                     ; zaokrouhlen¡ nahoru
         mov       dx,10000
         mul       dx                       ; ‡ st chyb
         xor       ax,ax
         xchg      ax,dx
         mov       ds:[Chyby],ax            ; po‡et chyb v setin ch procent
         mov       cx,100
         div       cx                       ; rozdˆlen¡ na celou ‡ st a setiny

; ------ zobrazen¡ % chyb - cel  ‡ st

TestT61: push      dx
         mov       bh,ds:[TColBold]
         xor       dx,dx
         call      DispLNum                 ; zobrazen¡ % chyb - cel  ‡ st

; ------ oddˆlovac¡ ‡ rka

         mov       al,","
         mov       ah,bh
         call      DispChr0
         pop       ax                       ; setiny chyb

; ------ zobrazen¡ % chyb - setiny

         cmp       al,10                    ; m‚nˆ ne‘ 10 ?
         jae       TestT62                  ; budou 2 ‡¡slice
         push      ax
         mov       ah,bh
         mov       al,"0"
         call      DispChr0
         pop       ax
TestT62: call      DispLNum                 ; zobrazen¡ setin chyb

; ------ zbytek textu

         call      DispTxt

; ------ n vrat ukazatele textu

TestT79: pop       es
         pop       si
         clc                                ; p©¡znak operace OK

; ------ n vrat nastaven¡ rolov n¡ pap¡ru

TestT9:  pop       word ptr ds:[LinRoll]    ; po‡et linek na v˜¨ku © dku
         pop       word ptr ds:[IncRoll]    ; p©¡rustek adresy pro rolov n¡
         pop       bp
         ret

TestT    ENDP

; -----------------------------------------------------------------------------
;        korekce dat v bufferu na‡ten‚ho souboru k testu
; -----------------------------------------------------------------------------

VyberKor PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      si
         push      di
         push      es

; ------ p©¡prava registr–

         mov       cx,ds:[VstupN]           ; po‡et bajt– v bufferu
         mov       ax,SEG VstupS            ; segment bufferu
         mov       es,ax                    ; ES <- segment bufferu
         xor       si,si
         xor       di,di
         xor       bx,bx                    ; ukazatel d‚lky © dku
         cld

; ------ na‡ten¡ bajtu dat

VyberKr2:jcxz      VyberKr8                 ; nejou dal¨¡ data
         lods      byte ptr es:[si]         ; na‡ten¡ bajtu dat
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e dat

; ------ znak LF je platn˜ znak

VyberKr3:cmp       al,LF                    ; je LF ?
         jne       VyberKr4                 ; nen¡ znak LF
         xor       bx,bx                    ; nov˜ ukazatel d‚lky © dku
         jmp       short VyberKr7           ; ulo‘en¡ znaku LF

; ------ znak TAB se nahrad¡ mezerou

VyberKr4:cmp       al,9                     ; je tabul tor ?
         jne       VyberKr5                 ; nen¡ tabul tor
         mov       al," "                   ; n hrada tabul toru mezerou

; ------ ostatn¡ znaky < 32 jsou neplatn‚

VyberKr5:cmp       al," "
         jb        VyberKr2                 ; znak < 32 je neplatn˜

; ------ omezen¡ d‚lky © dku

VyberKr6:cmp       bl,SIRTEXT               ; je maxim ln¡ d‚lka © dku ?
         jae       VyberKr2                 ; je ji‘ maxim ln¡ d‚lka © dku
         inc       bx                       ; zv˜¨en¡ ukazatele d‚lky © dku

; ------ ulo‘en¡ znaku do bufferu

VyberKr7:stosb                              ; ulo‘en¡ znaku do bufferu
         jmp       short VyberKr2           ; dal¨¡ znak

; ------ zaji¨tˆn¡ LF, nen¡-li © dek ukon‡en

VyberKr8:or        bx,bx                    ; je © dek ukon‡en ?
         jz        VyberKr9                 ; © dek je ukon‡en OK
         mov       al,LF
         stosb                              ; ulo‘en¡ znaku LF

; ------ ozna‡en¡ konce dat

VyberKr9:mov       al,EOT                   ; znak konce dat
         stosb                              ; ozna‡en¡ konce dat

; ------ nov˜ po‡et bajt– v bufferu

         mov       ds:[VstupN],di           ; nov˜ po‡et bajt– v bufferu

; ------ n vrat registr–

         pop       es
         pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

VyberKor ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ seznamu soubor–
; -----------------------------------------------------------------------------

VyberRea PROC      NEAR

; ------ nastaven¡ pracovn¡ adresy DTA

         mov       dx,offset BuffDTA        ; buffer DTA
         mov       ah,1ah
         int       21h                      ; nastaven¡ adresy DTA

; ------ sestaven¡ specifikace soubor– test–

         cld
         mov       di,ds:[TestSpcA]         ; konec cesty test–
         push      ds
         pop       es
         mov       ax,"*\"
         stosw
         mov       al,"."
         stosw
         mov       al,0
         stosb

; ------ nalezen¡ prvn¡ho/dal¨¡ho souboru

         mov       word ptr ds:[FileNum],0  ; nen¡ ‘ dn˜ soubor
         mov       word ptr ds:[VstupN],0   ; v bufferu nic nen¡
         mov       dx,offset TestSpec       ; specifikace test–
         mov       ah,4eh
         xor       cx,cx                    ; atributy soubor–
VyberRe2:int       21h                      ; nalezen¡ prvn¡ho/dal¨¡ho souboru
         jc        VyberRe9                 ; chyba - nen¡ dal¨¡ soubor

; ------ ukl dac¡ adresa do bufferu

         mov       ax,SEG VstupS            ; vstupn¡ buffer
         mov       es,ax                    ; ES <- vstupn¡ buffer
         mov       di,ds:[VstupN]           ; po‡et bajt– v bufferu
         cmp       di,-50                   ; je buffer ji‘ pln˜ ?
         jae       VyberRe9                 ; buffer je ji‘ pln˜

; ------ vymaz n¡ polo‘ky v bufferu

         mov       cx,11                    ; d‚lka polo‘ky
         mov       al," "
         cld
         rep       stosb                    ; vymaz n¡ polo‘ky
         xchg      di,ds:[VstupN]           ; nov  ukl dac¡ adresa
         inc       word ptr ds:[FileNum]    ; zv˜¨en¡ po‡tu soubor–

; ------ dek¢dov n¡ polo‘ky do bufferu

         mov       si,offset BuffDTA+1eh    ; buffer DTA
         push      di
VyberRe3:lodsb
         cmp       al,0                     ; je konec jm‚na ?
         je        VyberRe5
         cmp       al,"."
         jne       VyberRe4
         pop       di
         push      di
         add       di,8                     ; adresa k dek¢dov n¡ p©¡pony
         jmp       short VyberRe3
VyberRe4:stosb
         jmp       short VyberRe3
VyberRe5:pop       di

; ------ p©¡prava pro dal¨¡ polo‘ku

         mov       ah,4fh
         jmp       short VyberRe2           ; hled n¡ dal¨¡ polo‘ky

VyberRe9:ret

VyberRea ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ zvolen‚ho souboru do bufferu (CY=chyba)
; -----------------------------------------------------------------------------

VyberOpn PROC      NEAR

; ------ adresa aktivn¡ zvolen‚ polo‘ky -> ES:SI

         mov       ax,11                    ; po‡et bajt– na polo‘ku
         mul       word ptr ds:[FileAkt]    ; offset zvolen‚ polo‘ky
         xchg      ax,si                    ; SI <- offset zvolen‚ polo‘ky
         mov       ax,SEG VstupS            ; vstupn¡ segment
         mov       es,ax                    ; ES <- segment

; ------ £schova jm‚na polo‘ky

         push      si
         mov       cx,11
         mov       di,offset ProtTstA
VyberOp1:lods      byte ptr es:[si]
         mov       ds:[di],al
         inc       di
         loop      VyberOp1
         pop       si

; ------ £schova jm‚na polo‘ky

         mov       di,offset ProtTstB       ; buffer jm‚na souboru
         mov       cl,11                    ; d‚lka jm‚na souboru
VyberOp2:lods      byte ptr es:[si]         ; znak jm‚na souboru
         mov       ds:[di],al
         inc       di
         cmp       cl,3+1
         jne       VyberOp4
         inc       di                       ; p©esko‡en¡ znaku te‡ky
VyberOp4:loop      VyberOp2

; ------ sestaven¡ jm‚na souboru

         cld
         mov       di,ds:[TestSpcA]         ; konec cesty k test–m
         push      ds
         pop       es
         mov       al,"\"                   ; oddˆlova‡ cesty
         stosb
         mov       si,offset ProtTstB       ; buffer jm‚na souboru
         mov       cx,11+1                  ; d‚lka jm‚na souboru (+te‡ka)
         rep       movsb                    ; p©id n¡ jm‚na souboru
         mov       al,0
         stosb                              ; ukon‡ovac¡ 0

; ------ otev©en¡ souboru k na‡ten¡

         mov       dx,offset TestSpec       ; buffer cesty
         mov       ax,3d00h
         int       21h                      ; otev©en¡ souboru
         jc        VyberOp8                 ; chyba
         xchg      ax,bx                    ; BX <- identifik tor souboru

; ------ na‡ten¡ souboru do bufferu

         push      ds
         mov       ax,SEG VstupS            ; segment bufferu
         mov       ds,ax                    ; DS <- segment bufferu
         xor       dx,dx                    ; po‡ tek bufferu
         mov       cx,-20                   ; maxim lnˆ dat
         mov       ah,3fh
         int       21h                      ; na‡ten¡ souboru do bufferu
         pop       ds
         mov       ds:[VstupN],ax           ; po‡et na‡ten˜ch dat souboru

; ------ uzav©en¡ souboru

         pushf
         mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru
         popf
VyberOp8:ret

VyberOpn ENDP

; -----------------------------------------------------------------------------
;        v˜bˆr souboru ze seznamu (CY=p©eru¨en¡ operace)
; -----------------------------------------------------------------------------

VyberVol PROC      NEAR

; ------ omezen¡ aktivn¡ polo‘ky

         mov       ax,ds:[FileNum]          ; po‡et polo‘ek
         dec       ax                       ; maxim ln¡ polo‘ka
         cmp       ax,ds:[FileAkt]          ; je aktivn¡ polo‘ka platn  ?
         jae       VyberV11                 ; aktivn¡ polo‘ka je platn  OK
         mov       ds:[FileAkt],ax          ; omezen¡ aktivn¡ polo‘ky

; ------ omezen¡ po‡ te‡n¡ polo‘ky

VyberV11:cmp       ax,ds:[FileTop]          ; je po‡ te‡n¡ polo‘ka platn  ?
         jae       VyberV12                 ; po‡ te‡n¡ polo‘ka je platn 
         mov       ds:[FileTop],ax          ; omezen¡ po‡ te‡n¡ polo‘ky

; ------ normalizace po‡ te‡n¡ polo‘ky

VyberV12:mov       ax,ds:[FileAkt]          ; aktivn¡ polo‘ka
         cmp       ax,ds:[FileTop]          ; je podte‡en¡ pod po‡ tkem ?
         jae       VyberV13                 ; nen¡ podte‡en¡ pod po‡ tkem
         sub       word ptr ds:[FileTop],VYBERMAX ; posun po‡ tku
         jnc       VyberV12

VyberV13:mov       ax,ds:[FileTop]          ; po‡ tek str nky
         add       ax,VYBERMAX              ; konec str nky
         cmp       ax,ds:[FileAkt]          ; je p©ete‡en¡ za konec ?
         ja        VyberVl2                 ; nen¡ p©ete‡en¡ za konec
         add       word ptr ds:[FileTop],VYBERMAX ; posun po‡ tku
         jnc       VyberV13

; ------ zobrazen¡ seznamu soubor–

VyberVl2:call      VyberDis                 ; zobrazen¡ seznamu soubor–

; ------ zapnut¡ kurzoru

VyberVl3:call      VyberZap                 ; zapnut¡ kurzoru v˜bˆru

; ------ ‡ek n¡ na kl vesu

         mov       ah,0
         int       16h

; ------ vypnut¡ kurzoru

         call      VyberVyp                 ; vypnut¡ kurzoru v˜bˆru

; ------ nahoru

         mov       bx,1                     ; posun o 1 zpˆt
         cmp       ax,4800h
         je        VyberVl4

; ------ vlevo

         mov       bl,VYBERRAD              ; posun o sloupec
         cmp       ax,4b00h
         je        VyberVl4

; ------ str nka zpˆt

         mov       bl,VYBERMAX              ; posun o str nku
         cmp       ax,4900h
         je        VyberVl4

; ------ za‡ tek HOME nebo Ctrl-PageUp

         mov       bx,ds:[FileAkt]          ; bude posun o aktivn¡ polo‘ku
         cmp       ax,4700h
         je        VyberVl4
         cmp       ax,8400h
         jne       VyberVl5

; ------ posun aktivn¡ polo‘ku o BX polo‘ek vp©ed

VyberVl4:sub       ds:[FileAkt],bx          ; posun o BX polo‘ek zpˆt
         jnc       VyberV42
         mov       word ptr ds:[FileAkt],0  ; omezen¡ p©i p©ete‡en¡
VyberV42:mov       ax,ds:[FileAkt]          ; nov  aktivn¡ polo‘ka
         cmp       ax,ds:[FileTop]          ; je podte‡en¡ po‡ tku ?
         jae       VyberVl3                 ; jen zapnut¡ kurzoru
VyberV44:jmp       short VyberV12           ; normalizace po‡ tku

; ------ dol–

VyberVl5:mov       bx,1                     ; posun o 1 vp©ed
         cmp       ax,5000h
         je        VyberVl6

; ------ vpravo

         mov       bl,VYBERRAD              ; posun o sloupec
         cmp       ax,4d00h
         je        VyberVl6

; ------ str nka vp©ed

         mov       bl,VYBERMAX
         cmp       ax,5100h
         je        VyberVl6

; ------ konec END nebo Ctrl-PageDown

         mov       bx,ds:[FileNum]          ; po‡et polo‘ek
         dec       bx                       ; ‡¡slo posledn¡ polo‘ky
         sub       bx,ds:[FileAkt]          ; zb˜vaj¡c¡ polo‘ky do konce
         cmp       ax,4f00h
         je        VyberVl6
         cmp       ax,7600h
         jne       VyberVl7

; ------ posun aktivn¡ polo‘ky o BX polo‘ek vp©ed

VyberVl6:add       ds:[FileAkt],bx          ; posun vp©ed
         mov       ax,ds:[FileAkt]          ; nov  aktivn¡ polo‘ka
         cmp       ax,ds:[FileNum]          ; je p©ete‡en¡ konce ?
         jb        VyberV62                 ; je to OK
         mov       ax,ds:[FileNum]          ; po‡et polo‘ek
         dec       ax                       ; posledn¡ polo‘ka
         mov       ds:[FileAkt],ax          ; opraven  posledn¡ polo‘ka

VyberV62:mov       ax,ds:[FileTop]          ; po‡ te‡n¡ polo‘ka
         add       ax,VYBERMAX              ; konec str nky
         cmp       ax,ds:[FileAkt]          ; je p©ete‡en¡ za konec ?
         jbe       VyberV44                 ; je p©ete‡en¡ p©es konec
VyberV66:jmp       VyberVl3                 ; nen¡ p©ete‡en¡ za konec

; ------ proveden¡ volby ENTER

VyberVl7:cmp       al,13
         je        VyberVl9

; ------ p©eru¨en¡ operace ESC

         or        ax,ax
         jz        VyberVl8
         cmp       al,27
         jne       VyberV66
VyberVl8:stc                                ; p©¡znak p©eru¨en¡ operace

VyberVl9:ret

VyberVol ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ r mu pro v˜bˆr soubor–
; -----------------------------------------------------------------------------

VyberRam PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      di

; ------ vymaz n¡ obrazovky

         mov       ah,15                    ; b¡l  barva
         mov       di,5*80 + 1              ; po‡ tek k zobrazen¡
         mov       bx,350-10                ; v˜¨ka obd‚ln¡ku
         mov       cx,80-2                  ; ¨¡©ka obd‚ln¡ku
         call      DispBox                  ; vymaz n¡ obrazovky

; ------ zobrazen¡ r mu kolem obrazovky

         xor       di,di
         mov       ah,2                     ; barva
         mov       cx,80                    ; ¨¡©ka
         mov       bx,5                     ; v˜¨ka
         call      DispBox                  ; horn¡ okraj
         mov       di,(350-5)*80
         call      DispBox                  ; doln¡ okraj
         mov       di,5*80
         mov       cx,1
         mov       bx,350-10
         call      DispBox                  ; lev˜ okraj
         mov       di,5*80+79               ; prav˜ okraj
         call      DispBox                  ; prav˜ okraj

; ------ n vrat registr–

         pop       di
         pop       cx
         pop       bx
         pop       ax
         ret

VyberRam ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ seznamu soubor–
; -----------------------------------------------------------------------------

VyberDis PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ vymaz n¡ obrazovky pro v˜bˆr

         call      VyberRam                 ; vymaz n¡ obrazovky pro v˜bˆr

; ------ zobrazen¡ v˜zvy k v˜bˆru souboru

         call      SetFNT16                 ; nastaven¡ fontu 16 linek
         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       di,(80-offset(VyberTx0-VyberTxt)+3)/2 + 12*80
         mov       si,offset VyberTxt
         call      DispTxt                  ; zobrazen¡ v˜zvy

; ------ p©¡prava k zobrazen¡ soubor–

         call      SetFNT08                 ; nastaven¡ fontu 8 linek
         mov       ax,11                    ; po‡et bajt– na polo‘ku
         mul       word ptr ds:[FileTop]    ; offset po‡ te‡n¡ polo‘ky
         xchg      ax,si                    ; SI <- offset po‡ te‡n¡ polo‘ky
         mov       ax,SEG VstupS            ; segment bufferu
         mov       es,ax                    ; ES <- segment bufferu
         mov       di,VYBERADR              ; po‡ tek k zobrazen¡
         mov       dx,VYBERCOL              ; po‡et sloupc– (po 14 pozic¡ch)
VyberDs2:mov       bx,VYBERRAD              ; po‡et © dk–

; ------ zobrazen¡ jednoho souboru

         push      di
VyberDs3:mov       cx,11                    ; d‚lka jednoho souboru
         mov       ah,0                     ; barva textu
         push      di
         cmp       si,ds:[VstupN]           ; je platn  adresa ?
         jae       VyberDs5                 ; nen¡ ji‘ dal¨¡ soubor
VyberDs4:lods      byte ptr es:[si]         ; znak k zobrazen¡
         call      DispChr0                 ; zobrazen¡ znaku
         loop      VyberDs4                 ; dal¨¡ znak
VyberDs5:pop       di

; ------ dal¨¡ © dek se souborem

         add       di,VYBERVYS*80           ; adresa dal¨¡ho © dku
         dec       bx                       ; ‡¡ta‡ © dk–
         jnz       VyberDs3                 ; zobrazen¡ dal¨¡ho © dku
         pop       di

; ------ dal¨¡ sloupec se soubory

         add       di,VYBERSIR              ; adresa dal¨¡ho sloupce
         dec       dx                       ; ‡¡ta‡ sloupc–
         jnz       VyberDs2                 ; zobrazen¡ dal¨¡ho sloupce

; ------ n vrat registr–

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

VyberDis ENDP

; -----------------------------------------------------------------------------
;        set©¡dˆn¡ seznamu soubor–
; -----------------------------------------------------------------------------

VyberSrt PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

; ------ p©¡prava registr–

         mov       dx,ds:[VstupN]           ; po‡et bajt– v bufferu
         mov       ax,SEG VstupS            ; segment bufferu
         mov       es,ax                    ; ES <- segment bufferu
         mov       ds,ax                    ; DS <- segment bufferu
         mov       si,-11                   ; adresa prvn¡ polo‘ky - 11
         cld

; ------ test, zda je ji‘ konec bufferu

VyberSr1:add       si,11                    ; adresa dal¨¡ polo‘ky
VyberSr2:mov       di,si                    ; DI <- adresa polo‘ky
         add       di,11                    ; adresa n sleduj¡c¡ polo‘ky
         cmp       di,dx                    ; je dal¨¡ polo‘ka ?
         jae       VyberSr9                 ; nen¡ dal¨¡ polo‘ka

; ------ porovn n¡ jednoho p ru polo‘ek

VyberSr4:mov       cx,11                    ; d‚lka polo‘ky
         push      si
         push      di
         repe      cmpsb                    ; porovn n¡ polo‘ek
         pop       di
         pop       si
         jbe       VyberSr1                 ; po©ad¡ polo‘ek je OK

; ------ polo‘ky nesouhlas¡ - z mˆna polo‘ek

         mov       cx,11
         push      si
VyberSr5:lodsb
         xchg      al,ds:[di]
         inc       di
         mov       ds:[si-1],al
         loop      VyberSr5
         pop       si

; ------ posun k p©ede¨l‚ polo‘ce

         sub       si,11                    ; posun k p©ede¨l‚ polo‘ce
         jnc       VyberSr2                 ; nen¡ je¨tˆ podte‡en¡
         jmp       short VyberSr1           ; polo‘ka se neposouv 

; ------ n vrat registr–

VyberSr9:pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

VyberSrt ENDP

; -----------------------------------------------------------------------------
;        vypnut¡ kurzoru v˜bˆru
; -----------------------------------------------------------------------------

VyberVyp PROC      NEAR

         push      ax
         mov       ah,15                    ; barva podkladu
         jmp       short VyberZp1

VyberVyp ENDP

; -----------------------------------------------------------------------------
;        zapnut¡ kurzoru v˜bˆru
; -----------------------------------------------------------------------------

VyberZap PROC      NEAR

; ------ £schova registr–

         push      ax
         mov       ah,12                    ; barva kurzoru
VyberZp1:push      bx
         push      cx
         push      dx
         push      di

; ------ adresa aktivn¡ polo‘ky ve videopamˆti

         push      ax
         mov       ax,ds:[FileAkt]          ; aktivn¡ polo‘ka
         sub       ax,ds:[FileTop]          ; aktivn¡ polo‘ka relativnˆ
         mov       cl,VYBERRAD              ; po‡et © dk– se soubory
         div       cl                       ; v˜po‡et © dku a sloupce
         mov       di,ax                    ; £schova © dku
         mov       ah,VYBERSIR              ; ¨¡©ka jednoho sloupce
         mul       ah                       ; v˜po‡et relativn¡ pozice
         add       ax,VYBERADR - 1 - 4*80   ; p©i‡ten¡ po‡ te‡n¡ adresy
         xchg      ax,di                    ; DI <- adresa sloupce
         mov       al,VYBERVYS              ; v˜¨ka jedn‚ polo‘ky
         mul       ah                       ; v˜po‡et ‡¡sla linky
         mov       cx,80                    ; po‡et bajt– na linku
         mul       cx                       ; v˜po‡et adresy linky
         add       di,ax                    ; adresa ve videopamˆti
         pop       ax

; ------ zobrazen¡ horn¡ho okraje

         push      di
         mov       al,"Ú"
         call      DispChr0                 ; lev˜ horn¡ roh
         mov       al,"Ñ"
         mov       cx,11
VyberZp2:call      DispChr0                 ; horn¡ linka
         loop      VyberZp2
         mov       al,"¿"
         call      DispChr0                 ; prav˜ horn¡ roh
         pop       di

; ------ zobrazen¡ doln¡ho okraje

         add       di,7*80
         mov       al,"À"
         call      DispChr0                 ; lev˜ doln¡ roh
         mov       al,"Ï"
         mov       cx,11
VyberZp4:call      DispChr0                 ; doln¡ linka
         loop      VyberZp4
         mov       al,"Ù"
         call      DispChr0                 ; prav˜ doln¡ roh

; ------ n vrat registr–

         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

VyberZap ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ podtr‘en¡ textu testu ES:SI, © dek DL (0 a‘ 8)
; -----------------------------------------------------------------------------

Podtrh   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      dx
         push      si
         push      di
         call      SetFNT16                 ; nastaven¡ fontu 16 linek

; ------ v˜po‡et adresy videopamˆti

         mov       ax,(FONTEXT+1)*80        ; po‡et bajt– na © dek
         mov       dh,0
         mul       dx                       ; p©epo‡et na offset
         add       ax,TOPKLAV+LFTTEXT + 3*80 ; po‡ te‡n¡ adresa
         xchg      ax,di

; ------ zobrazen¡ podtr‘en¡ (nekontroluje se p©ete‡en¡ d‚lky © dku)

         mov       ah,ds:[TColErr]          ; barva chyby
         mov       al,"_"                   ; znak podtr‘en¡
         cmp       byte ptr es:[si],LF      ; je pr zdn˜ © dek ?
         je        Podtrh2                  ; je pr zdn˜ © dek - 1 podtr‘en¡
Podtrh1: cmp       byte ptr es:[si],LF      ; je konec © dku ?
         je        Podtrh3                  ; je konec © dku - konec
         inc       si                       ; zv˜¨en¡ ukazatele textu
Podtrh2: call      DispChr0                 ; zobrazen¡ podtr‘en¡
         jmp       short Podtrh1            ; dal¨¡ znak

; ------ n vrat registr–

Podtrh3: pop       di
         pop       si
         pop       dx
         pop       ax
         ret

Podtrh   ENDP

; -----------------------------------------------------------------------------
;        vymaz n¡ podtr‘en¡ textu testu © dek DL (0 a‘ 8)
; -----------------------------------------------------------------------------

ClrPod   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      di
         call      SetFNT16                 ; nastaven¡ fontu 16 linek

; ------ v˜po‡et adresy videopamˆti

         mov       ax,(FONTEXT+1)*80        ; po‡et bajt– na © dek
         mov       dh,0                     ; DX = ‡¡slo © dku 0 a‘ 8
         mul       dx                       ; p©epo‡et na offset
         add       ax,TOPKLAV+LFTTEXT + 3*80 ; po‡ te‡n¡ adresa
         xchg      ax,di                    ; DI <- adresa k ulo‘en¡ linky

; ------ vymaz n¡ podtr‘en¡ (cel  linka)

         mov       ah,ds:[TColPap]          ; barva pap¡ru
         mov       al,"_"
         mov       cx,SIRTEXT               ; po‡et znak– na © dek
ClrPod1: call      DispChr0
         loop      ClrPod1

; ------ n vrat registr–

         pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

ClrPod   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ textu testu ES:BX -> BX nov˜ ukazatel
; -----------------------------------------------------------------------------

DispTest PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      di

; ------ p©¡prava k zobrazen¡ textu

         call      SetFNT16                 ; nastaven¡ fontu 16 linek
         call      ClrTest                  ; vymaz n¡ plochy testu
         mov       di,TOPKLAV+LFTTEXT       ; po‡ tek k zobrazen¡ textu
         mov       cx,TESTLINE              ; po‡et © dk– k zobrazen¡
         mov       ah,ds:[TColNorm]         ; norm ln¡ barva textu

; ------ zobrazen¡ textu

DispTst1:xor       dx,dx                    ; ‡¡ta‡ pozice na © dku
DispTst2:mov       al,es:[bx]               ; p©ipraven˜ znak
         cmp       al,FF
         je        DispTst8
         cmp       al,EOT                   ; je konec textu ?
         je        DispTst8                 ; je konec testu
         inc       bx                       ; zv˜¨en¡ ukazatele textu
         cmp       al,LF                    ; konec © dku ?
         je        DispTst5                 ; je konec © dku
         cmp       dx,SIRTEXT               ; je voln  pozice ?
         jae       DispTst4                 ; je konec © dku
         call      DispChr0                 ; zobrazen¡ znaku
         inc       dx                       ; ukazate pozice
DispTst4:jmp       short DispTst2           ; dal¨¡ znak

; ------ nov˜ © dek

DispTst5:sub       di,dx                    ; n vrat po‡ tku © dku
         add       di,(FONTEXT+1)*80        ; adresa dal¨¡ho © dku
         loop      DispTst1                 ; zobrazen¡ dal¨¡ho © dku

; ------ n vrat registr–

DispTst8:pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

DispTest ENDP

; -----------------------------------------------------------------------------
;        dal¨¡ © dek textu testu ES:BX -> BX nov˜ ukazatel
; -----------------------------------------------------------------------------

NextTest PROC      NEAR

; ------ £schova registr–

         push      ax
         push      dx
         push      di

; ------ rolov n¡ textu o © dek

         call      RollTest                 ; rolov n¡ textu
         call      SetFNT16                 ; nastaven¡ fontu 16 linek
         mov       ah,ds:[TColNorm]         ; norm ln¡ barva textu

; ------ zobrazen¡ textu

         mov       di,TOPKLAV+LFTTEXT + (TESTLINE-1)*(FONTEXT+1)*80
         xor       dx,dx                    ; ukazatel pozice
NextTst2:mov       al,es:[bx]               ; p©ipraven˜ znak
         cmp       al,FF
         je        NextTst8
         cmp       al,EOT                   ; je konec textu ?
         je        NextTst8                 ; je konec testu
         inc       bx                       ; zv˜¨en¡ ukazatele textu
         cmp       al,LF                    ; konec © dku ?
         je        NextTst8                 ; je konec © dku
         cmp       dx,SIRTEXT               ; je voln  pozice ?
         jae       NextTst4                 ; je konec © dku
         call      DispChr0                 ; zobrazen¡ znaku
         inc       dx                       ; ukazate pozice
NextTst4:jmp       short NextTst2           ; dal¨¡ znak

; ------ n vrat registr–

NextTst8:pop       di
         pop       dx
         pop       ax
         ret

NextTest ENDP

; -----------------------------------------------------------------------------
;        vymaz n¡ str nky testu
; -----------------------------------------------------------------------------

ClrTest  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      di

; ------ plocha pro zobrazen¡ textu

         mov       di,TOPKLAV               ; po‡ te‡n¡ adresa
         mov       bx,LINKLAV               ; po‡et linek
         mov       ah,ds:[TColPodk]         ; barva podkladu
         mov       cx,80                    ; ¨¡©ka
         call      DispBox                  ; vymaz n¡ plochy k zobrazen¡ textu

; ------ zobrazen¡ pap¡ru

         mov       di,TOPKLAV+LFTPAPIR      ; po‡. k zobr.pap¡ru
         mov       bx,LINKLAV               ; po‡et linek
         mov       ah,ds:[TColPap]          ; barva
         mov       cx,SIRPAPIR              ; ¨¡©ka pap¡ru
         call      DispBox                  ; zobrazen¡ pap¡ru

; ------ n vrat registr–

         pop       di
         pop       cx
         pop       bx
         pop       ax
         ret

ClrTest  ENDP

; -----------------------------------------------------------------------------
;        rolov n¡ textu testu o © dek
; -----------------------------------------------------------------------------

RollTest PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ test, zda je displej Hercules

         mov       es,ds:[SegmVRAM]         ; ES <- segment videopamˆti
         cmp       byte ptr ds:[Hercules],0 ; je karta Hercules ?
         jne       RollTst3                 ; je karta Hercules

; ------ nastaven¡ z pisov‚ho m¢du

         cli
         mov       dx,3ceh
         mov       al,5
         out       dx,al                    ; volba registru z pisov‚ho m¢du
         mov       al,1
         inc       dx
         out       dx,al                    ; nastaven¡ m¢du sp©a‘en˜ch rovin

; ------ rolov n¡ obrazovky

         push      ds
         mov       di,TOPKLAV               ; DI <- 0
         mov       si,TOPKLAV+(FONTEXT+1)*80 ; adresa druh‚ho © dku
         mov       cx,(TESTLINE-1)*(FONTEXT+1)*80 ; d‚lka dat k rotaci
         cld
         push      es
         pop       ds                       ; DS <- segment videopamˆti
         rep       movsb                    ; rolov n¡ obrazovky
         pop       ds

; ------ n vrat bˆ‘n‚ho z pisov‚ho m¢du

         mov       al,0
         out       dx,al                    ; n vrat z pisov‚ho m¢du
         sti
         jmp       short RollTst8

; ------ p©¡prava k rolov n¡ okna

RollTst3:mov       di,TOPKLAV+(FONTEXT+1)*80 ; adresa druh‚ho © dku
         call      KorVRAM                  ; korekce adresy pro Hercules
         xchg      si,di                    ; SI <- adresa druh‚ho © dku
         mov       di,TOPKLAV               ; adresa prvn¡ho © dku
         call      KorVRAM                  ; korekce adresy pro Hercules
         mov       dx,(TESTLINE-1)*(FONTEXT+1) ; po‡et videolinek

; ------ rolov n¡ obrazovky

         push      ds                       ; £schova DS
         push      es
         pop       ds                       ; DS <- segment videopamˆti

RollTst4:push      si
         push      di
         cld
         mov       cx,80/2                  ; d‚lka jedn‚ linky
         rep       movsw                    ; kopie jedn‚ linky
         pop       di
         pop       si

         add       di,2000h
         jns       RollTst5
         sub       di,8000h-80
RollTst5:add       si,2000h
         jns       RollTst6
         sub       si,8000h-80
RollTst6:dec       dx
         jnz       RollTst4                 ; dal¨¡ videolinka

         pop       ds                       ; n vrat DS

; ------ vymaz n¡ novˆ vytvo©en‚ho © dku

RollTst8:mov       di,TOPKLAV + (FONTEXT+1)*(TESTLINE-1)*80 + LFTTEXT; po‡.textu
         mov       ah,15                    ; barva
         mov       cx,SIRTEXT               ; ¨¡©ka obd‚ln¡ku
         mov       bx,FONTEXT+1             ; v˜¨ka obd‚ln¡ku
         call      DispBox                  ; vymaz n¡ obd‚ln¡ku textu

; ------ n vrat registr–

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

RollTest ENDP

; *****************************************************************************
;
;                              Nastaven¡
;
; *****************************************************************************
;þ
; ------ zobrazen¡ menu volby nastaven¡

Nastav:  call      NovyPap                  ; vymaz n¡ pap¡ru
         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       si,offset NastText       ; menu volby nastaven¡
         call      DispTTxt                 ; zobrazen¡ menu volby nastaven¡

; ------ zobrazen¡ nastaven¡ metronomu

Nastav1: call      DispMetr                 ; zobrazen¡ nastaven¡ metronomu

; ------ zobrazen¡ nastaven¡ omezen¡ doby testu

         call      DispOmez                 ; zobrazen¡ nastaven¡ omezen¡ doby

; ------ zobrazen¡ aktu ln¡ kl vesnice

         call      InitKeyb                 ; inicializace parametr– kl vesnice
         call      DispKlav                 ; zobrazen¡ kl vesnice

; ------ zobrazen¡ p©ep¡na‡– volby kl vesnice

         mov       si,offset NastMenu
         mov       al,1                     ; polo‘ka 1
         mov       bx,ds:[AktKlav]          ; aktivn¡ kl vesnice
         inc       bx
Nastav11:mov       ah,15                    ; barva pro vypnut¡
         dec       bx
         jnz       Nastav12                 ; nen¡ aktivn¡ kl vesnice
         mov       ah,0                     ; barva pro zapnut¡
Nastav12:call      DispSwc                  ; zobrazen¡ p©ep¡na‡e
         inc       ax
         cmp       al,4
         jbe       Nastav11

; ------ zobrazen¡ p©ep¡na‡e nastaven¡ metronomu

         mov       ah,0                     ; barva pro zapnut¡
         cmp       byte ptr ds:[Metron],0   ; je p©ep¡na‡ zapnut˜ ?
         jne       Nastav2                  ; p©ep¡na‡ je zapnut˜
         mov       ah,15                    ; barva pro vypnut¡
Nastav2: call      DispSwc                  ; zobrazen¡ p©ep¡na‡e

; ------ zobrazen¡ p©ep¡na‡e zapnut¡ zvuku

         inc       ax
         inc       ax

         mov       ah,0                     ; barva pro zapnut¡
         cmp       byte ptr ds:[Sound],0    ; je zvuk zapnut˜ ?
         jne       Nastav3                  ; zvuk je zapnut˜
         mov       ah,15                    ; barva pro vypnut¡
Nastav3: call      DispSwc                  ; zobrazen¡ p©ep¡na‡e

; ------ zobrazen¡ p©ep¡na‡e editace

         inc       ax
         inc       ax
         mov       ah,0
         cmp       byte ptr ds:[Editace],0  ; je editace povolena ?
         jne       Nastav32                 ; editace je povolena
         mov       ah,15                    ; barva pro vypnut¡
Nastav32:call      DispSwc                  ; zobrazen¡ p©ep¡na‡e

; ------ obsluha menu volby nastaven¡

         call      Menu                     ; obsluha menu
         jc        Nastav9                  ; p©eru¨en¡ volby

; ------ 1 a‘ 4: volba kl vesnice

         cmp       bl,4
         ja        Nastav4
         dec       bx
         mov       ds:[AktKlav],bx          ; aktivn¡ kl vesnice
         inc       bx

; ------ 5: zmˆna p©ep¡na‡e zapnut¡ metronomu

Nastav4: cmp       bl,5
         jne       Nastav5
         xor       byte ptr ds:[Metron],1   ; zmˆna p©¡znaku metronomu

; ------ 6: nastaven¡ metronomu

Nastav5: cmp       bl,6
         jne       Nastav6
         call      SetMetr                  ; nastaven¡ metronomu

; ------ 7: zapnut¡/vypnut¡ zvuku

Nastav6: cmp       bl,7
         jne       Nastav7
         xor       byte ptr ds:[Sound],1    ; zmˆna p©¡znaku zapnut¡ zvuku

; ------ 8: omezen¡ d‚lky testu

Nastav7: cmp       bl,8
         jne       Nastv72
         call      SetOmez                  ; nastaven¡ omezen¡ d‚lky testu

; ------ 9: povolena editace

Nastv72: cmp       bl,9
         jne       Nastav8
         xor       byte ptr ds:[Editace],1  ; zmˆna p©¡znaku povolen¡ editace

; ------ ulo‘en¡ novˆ nastaven‚ konfigurace

Nastav8: call      WritCnf                  ; ulo‘en¡ konfigurace
         call      ReadCnf                  ; na‡ten¡ konfigurace pro p©¡pad R/O
         jmp       Nastav1                  ; nov‚ zobrazen¡ p©ep¡na‡–

; ------ n vrat do hlavn¡ho menu

Nastav9: jmp       Start4                   ; n vrat do hlavn¡ho menu

; -----------------------------------------------------------------------------
;        inicializace ukazatel– aktu ln¡ kl vesnice
; -----------------------------------------------------------------------------

InitKeyb PROC      NEAR

         push      ax

; ------ 0: ‡esk  kl vesnice

         mov       ax,ds:[AktKlav]          ; aktivn¡ kl vesnice
         or        ax,ax
         jnz       InitKey1
         mov       word ptr ds:[AdrXchg],offset KlavXchC
         mov       word ptr ds:[AdrKlavR],offset KlavesC
         mov       word ptr ds:[AdrTLekc],offset TabLekC
         mov       word ptr ds:[AdrTLDat],offset TabDatC
         mov       word ptr ds:[AdrSkup],offset SkupTxtC
         mov       word ptr ds:[AdrMenS],offset SkupMenC
         mov       word ptr ds:[AdrHghK],offset HighKeyC
         mov       word ptr ds:[AdrUhoz],offset UhozKeyC
         mov       word ptr ds:[AdrHghCh],offset HighChrC

; ------ 1: program torsk  1 (CSKEY)

InitKey1:dec       ax
         jnz       InitKey2
         mov       word ptr ds:[AdrXchg],offset KlavXch1
         mov       word ptr ds:[AdrKlavR],offset Klaves1
         mov       word ptr ds:[AdrTLekc],offset TabLek1
         mov       word ptr ds:[AdrTLDat],offset TabDat1
         mov       word ptr ds:[AdrSkup],offset SkupTxt1
         mov       word ptr ds:[AdrMenS],offset SkupMen1
         mov       word ptr ds:[AdrHghK],offset HighKey1
         mov       word ptr ds:[AdrUhoz],offset UhozKey1
         mov       word ptr ds:[AdrHghCh],offset HighChr1

; ------ 2: program torsk  2 (T602)

InitKey2:dec       ax
         jnz       InitKey3
         mov       word ptr ds:[AdrXchg],offset KlavXch2
         mov       word ptr ds:[AdrKlavR],offset Klaves2
         mov       word ptr ds:[AdrTLekc],offset TabLek2
         mov       word ptr ds:[AdrTLDat],offset TabDat2
         mov       word ptr ds:[AdrSkup],offset SkupTxt2
         mov       word ptr ds:[AdrMenS],offset SkupMen2
         mov       word ptr ds:[AdrHghK],offset HighKey2
         mov       word ptr ds:[AdrUhoz],offset UhozKey2
         mov       word ptr ds:[AdrHghCh],offset HighChr2

; ------ 3: kl vesnice IBM

InitKey3:dec       ax
         jnz       InitKey4
         mov       word ptr ds:[AdrXchg],offset KlavXchI
         mov       word ptr ds:[AdrKlavR],offset KlavesI
         mov       word ptr ds:[AdrTLekc],offset TabLekI
         mov       word ptr ds:[AdrTLDat],offset TabDatI
         mov       word ptr ds:[AdrSkup],offset SkupTxtI
         mov       word ptr ds:[AdrMenS],offset SkupMenI
         mov       word ptr ds:[AdrHghK],offset HighKeyI
         mov       word ptr ds:[AdrUhoz],offset UhozKeyI
         mov       word ptr ds:[AdrHghCh],offset HighChrI

InitKey4:pop       ax
         ret

InitKeyb ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ rychlosti metronomu
; -----------------------------------------------------------------------------

SetMetr  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      bp

         mov       al,ds:[Metron]           ; p©¡znak zapnut¡ metronomu
         push      ax
         mov       byte ptr ds:[Metron],1   ; zapnut¡ metronomu

; ------ nulov n¡ aktu ln¡ hodnoty metronomu

         call      NulMetr                  ; inicializace metronomu
         mov       bp,ds:[MetrSet]          ; aktu ln¡ hodnota metronomu
         mov       word ptr ds:[MetrSet],0  ; nulov n¡ nastaven¡ metronomu

; ------ zobrazen¡ nuly metronomu

         mov       di,6*FONTEXT*80 + LFTTEXT + 40 ; pozice k zobrazen¡ kurzoru
         call      DispMetr                 ; zobrazen¡ metronomu
         mov       al,"Û"
         mov       ah,ds:[TColKeys]         ; zv˜raznˆn  barva
         call      DispChr                  ; zobrazen¡ kurzoru
         jmp       short SetMetr2

; ------ zobrazen¡ aktu ln¡ho nastaven¡ a kurzoru

SetMetr1:call      DispMetr                 ; zobrazen¡ rychlosti metronomu
         mov       al,"Û"
         mov       ah,ds:[TColKeys]         ; zv˜raznˆn  barva
         call      DispChr                  ; zobrazen¡ kurzoru

; ------ ‡ek n¡ na zad n¡ kl vesy

         call      NulMetr                  ; nulov n¡ ‡¡t n¡ metronomu
SetMetr2:call      LupMetr                  ; obsluha metronomu
         call      TestKey                  ; je p©ipravena kl vesa ?
         jc        SetMetr2                 ; ‡ek n¡ na stisk kl vesy
         mov       ah,0
         int       16h                      ; vstup znaku z kl vesnice

; ------ konverze znaku (nen¡-li ‡¡slice)

         cmp       al,"0"
         jb        SetMet22
         cmp       al,"9"
         jbe       SetMet24                 ; je ‡¡slice
SetMet22:call      KonvXchg                 ; konverze znaku

; ------ p©eru¨en¡ zad v n¡

SetMet24:or        ax,ax
         jz        SetMet26
         cmp       al,27
         jne       SetMetr3

; ------ p©eru¨en¡ zad n¡

SetMet26:mov       ds:[MetrSet],bp          ; navr cen¡ p–vodn¡ hodnoty
         call      DispMetr                 ; zobrazen¡ p–vodn¡ hodnoty
         jmp       short SetMetr9

; ------ ukon‡en¡ zad n¡ ENTER

SetMetr3:cmp       al,13
         jne       SetMetr4
         cmp       word ptr ds:[MetrSet],0  ; je platn‚ ‡¡slo ?
         je        SetMet26                 ; nen¡ platn‚ ‡¡slo
         call      DispMetr                 ; zobrazen¡ nastaven¡
         jmp       short SetMetr9

; ------ zru¨en¡ znaku BS nebo DEL

SetMetr4:cmp       al,8
         je        SetMetr5
         cmp       ax,5300h
         jne       SetMetr6
SetMetr5:mov       ax,ds:[MetrSet]
         or        ax,ax                    ; je ‡¡slo ji‘ = 0 ?
         jz        SetMetr2                 ; nen¡ dal¨¡ ‡¡slice
         xor       dx,dx
         mov       cx,10
         div       cx                       ; vydˆlen¡ ‡¡sla o © d
         mov       ds:[MetrSet],ax          ; nov‚ nastaven¡ ‡¡sla
         dec       di                       ; n vrat ukazatele
SetMet54:jmp       short SetMetr1           ; nov‚ zobrazen¡ ukazatele

; ------ test, zda je ‡¡slice

SetMetr6:sub       al,"0"
         jb        SetMetr2                 ; nen¡ ‡¡slice
         cmp       al,9
         ja        SetMetr2                 ; nen¡ ‡¡slice
         cmp       word ptr ds:[MetrSet],99 ; maxim ln¡ hodnota
         ja        SetMetr2                 ; p©ekro‡ena maxim ln¡ hodnota

; ------ z kaz zad n¡ nuly, nen¡-li je¨tˆ nic zad no

         cmp       al,0
         jne       SetMetr7
         cmp       word ptr ds:[MetrSet],0  ; je nˆco ?
         je        SetMetr2

; ------ p©id n¡ ‡¡slice

SetMetr7:mov       ah,0
         push      ax
         mov       ax,10
         mul       word ptr ds:[MetrSet]
         pop       dx
         add       ax,dx
         mov       ds:[MetrSet],ax          ; nov‚ nastaven¡
         inc       di                       ; zv˜¨en¡ ukazatele
         jmp       short SetMet54

; ------ n vrat registr–

SetMetr9:pop       ax
         mov       ds:[Metron],al           ; n vrat p©¡znaku metronomu

         pop       bp
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

SetMetr  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ rychlosti metronomu
; -----------------------------------------------------------------------------

DispMetr PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      dx
         push      di

; ------ vymaz n¡ pole pro zobrazen¡ rychlosti metronomu

         call      SetFNT16                 ; nastaven¡ fontu 16 linek
         mov       di,6*FONTEXT*80 + LFTTEXT + 40 ; pozice k zobrazen¡ nastaven¡
         push      di
         mov       al,"Û"                   ; znak k vymaz n¡
         mov       ah,ds:[TColPap]          ; barva pap¡ru
         call      DispChr0
         call      DispChr0
         call      DispChr0
         call      DispChr0
         pop       di

; ------ zobrazen¡ ‡¡sla metronomu

         mov       ax,ds:[MetrSet]          ; nastaven  rychlost metronomu
         xor       dx,dx
         mov       bh,ds:[TColKeys]         ; barva
         or        ax,ax                    ; je platn‚ ‡¡slo ?
         jz        DispMtr3                 ; nen¡ platn‚ ‡¡slo
         call      DispLNum                 ; zobrazen¡ ‡¡sla

; ------ n vrat registr–

DispMtr3:pop       di
         pop       dx
         pop       bx
         pop       ax
         ret

DispMetr ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ omezen¡ d‚lky testu
; -----------------------------------------------------------------------------

SetOmez  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      bp

; ------ nulov n¡ aktu ln¡ hodnoty omezen¡

         mov       bp,ds:[Omezeni]          ; aktu ln¡ hodnota omezen¡
         mov       word ptr ds:[Omezeni],0  ; nulov n¡ nastaven¡ omezen¡

; ------ zobrazen¡ aktu ln¡ho nastaven¡ a kurzoru

         mov       di,8*FONTEXT*80 + LFTTEXT + 49 ; pozice k zobrazen¡ kurzoru
SetOmez1:call      DispOmez                 ; zobrazen¡ nastaven¡ omezen¡
         mov       al,"Û"
         mov       ah,ds:[TColKeys]         ; zv˜raznˆn  barva
         call      DispChr                  ; zobrazen¡ kurzoru

; ------ ‡ek n¡ na zad n¡ kl vesy

SetOmez2:mov       ah,0
         int       16h                      ; vstup znaku z kl vesnice

; ------ konverze znaku (nen¡-li ‡¡slice)

         cmp       al,"0"
         jb        SetOmz22
         cmp       al,"9"
         jbe       SetOmz24                 ; je ‡¡slice
SetOmz22:call      KonvXchg                 ; konverze znaku

; ------ p©eru¨en¡ zad v n¡

SetOmz24:or        ax,ax
         jz        SetOmz26
         cmp       al,27
         jne       SetOmez3

; ------ p©eru¨en¡ zad n¡

SetOmz26:mov       ds:[Omezeni],bp          ; navr cen¡ p–vodn¡ hodnoty
         call      DispOmez                 ; zobrazen¡ p–vodn¡ hodnoty
         jmp       short SetOmez9

; ------ ukon‡en¡ zad n¡ ENTER

SetOmez3:cmp       al,13
         jne       SetOmez4
         cmp       word ptr ds:[Omezeni],0  ; je platn‚ ‡¡slo ?
         je        SetOmz26                 ; nen¡ platn‚ ‡¡slo
         call      DispOmez                 ; zobrazen¡ nastaven¡
         jmp       short SetOmez9

; ------ zru¨en¡ znaku BS nebo DEL

SetOmez4:cmp       al,8
         je        SetOmez5
         cmp       ax,5300h
         jne       SetOmez6
SetOmez5:mov       ax,ds:[Omezeni]
         or        ax,ax                    ; je ‡¡slo ji‘ = 0 ?
         jz        SetOmez2                 ; nen¡ dal¨¡ ‡¡slice
         xor       dx,dx
         mov       cx,10
         div       cx                       ; vydˆlen¡ ‡¡sla o © d
         mov       ds:[Omezeni],ax          ; nov‚ nastaven¡ ‡¡sla
         dec       di                       ; n vrat ukazatele
SetOmz54:jmp       short SetOmez1           ; nov‚ zobrazen¡ ukazatele

; ------ test, zda je ‡¡slice

SetOmez6:sub       al,"0"
         jb        SetOmez2                 ; nen¡ ‡¡slice
         cmp       al,9
         ja        SetOmez2                 ; nen¡ ‡¡slice
         cmp       word ptr ds:[Omezeni],99 ; maxim ln¡ hodnota
         ja        SetOmez2                 ; p©ekro‡ena maxim ln¡ hodnota

; ------ z kaz zad n¡ nuly, nen¡-li je¨tˆ nic zad no

         cmp       al,0
         jne       SetOmez7
         cmp       word ptr ds:[Omezeni],0  ; je nˆco ?
         je        SetOmez2

; ------ p©id n¡ ‡¡slice

SetOmez7:mov       ah,0
         push      ax
         mov       ax,10
         mul       word ptr ds:[Omezeni]
         pop       dx
         add       ax,dx
         mov       ds:[Omezeni],ax          ; nov‚ nastaven¡
         inc       di                       ; zv˜¨en¡ ukazatele
         jmp       short SetOmz54

; ------ n vrat registr–

SetOmez9:pop       bp
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

SetOmez  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ omezen¡ doby
; -----------------------------------------------------------------------------

DispOmez PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      dx
         push      di

; ------ vymaz n¡ pole pro zobrazen¡ omezen¡ doby

         call      SetFNT16                 ; nastaven¡ fontu 16 linek
         mov       di,8*FONTEXT*80 + LFTTEXT + 49 ; pozice k zobrazen¡ nastaven¡
         push      di
         mov       al,"Û"                   ; znak k vymaz n¡
         mov       ah,ds:[TColPap]          ; barva pap¡ru
         call      DispChr0
         call      DispChr0
         call      DispChr0
         call      DispChr0
         call      DispChr0
         call      DispChr0
         pop       di

; ------ zobrazen¡ omezen¡ doby testu

         mov       ax,ds:[Omezeni]          ; nastaven‚ omezen¡ doby testu
         xor       dx,dx
         mov       bh,ds:[TColKeys]         ; barva
         or        ax,ax                    ; je platn‚ ‡¡slo ?
         jz        DispOmz3                 ; nen¡ platn‚ ‡¡slo
         call      DispLNum                 ; zobrazen¡ ‡¡sla

; ------ n vrat registr–

DispOmz3:pop       di
         pop       dx
         pop       bx
         pop       ax
         ret

DispOmez ENDP

; -----------------------------------------------------------------------------
;        z pis konfigurace do aktivn¡ho adres ©e
; -----------------------------------------------------------------------------

WritCnf  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

; ------ nastaven¡ kontroln¡ho sou‡tu konfigurace

         mov       si,offset KONFIG         ; buffer konfigurace
         mov       cx,offset(CheckSum-KONFIG) ; d‚lka dat
         xor       ax,ax
WritCnf2:rol       ax,1
         xor       al,ds:[si]
         inc       si
         loop      WritCnf2
         mov       ds:[si],ax               ; £schova kontroln¡ho sou‡tu

; ------ vytvo©en¡ souboru

         mov       dx,offset KonfSpec       ; konfigura‡n¡ soubor
         mov       ah,3ch
         xor       cx,cx
         int       21h                      ; vytvo©en¡ souboru
         jc        WritCnf9

; ------ z pis dat do souboru

         xchg      ax,bx                    ; BX <- identifik tor souboru
         mov       dx,offset KONFIG
         mov       cx,offset(KONFIG0-KONFIG)
         mov       ah,40h
         int       21h                      ; z pis dat do souboru

; ------ uzav©en¡ souboru

         mov       ah,3eh
         int       21h

; ------ n vrat registr–

WritCnf9:pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

WritCnf  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ konfigurace
; -----------------------------------------------------------------------------

ReadCnf  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ otev©en¡ souboru pro ‡ten¡

         mov       dx,offset KonfSpec       ; konfigura‡n¡ soubor
         mov       ax,3d00h
         int       21h                      ; otev©en¡ souboru pro ‡ten¡
         jc        ReadCnf9                 ; chyba - soubor nenalezen

; ------ na‡ten¡ souboru do bufferu

         mov       word ptr ds:[KONFIGR],0  ; p©ednastaven¡ - neplatn˜ soubor
         xchg      ax,bx                    ; BX <- identifik tor souboru
         mov       dx,offset KONFIGR        ; buffer k na‡ten¡ konfigurace
         mov       cx,offset(KONFIG0-KONFIG) ; d‚lka konfigurace
         mov       ah,3fh
         int       21h                      ; na‡ten¡ souboru do bufferu
         jc        ReadCnf2                 ; chyba operace
         cmp       ax,cx                    ; bylo na‡teno v¨e ?

; ------ uzav©en¡ souboru

ReadCnf2:pushf
         mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru
         popf
         jc        ReadCnf9                 ; chyba ‡ten¡

; ------ ovˆ©en¡ dat

         mov       si,offset KONFIGR        ; na‡ten  konfigurace
         cmp       word ptr ds:[si],"SV"    ; identifik tor
         jne       ReadCnf9                 ; cbyba
         cmp       word ptr ds:[si+2],"01"  ; identifik tor
         jne       ReadCnf9                 ; chyba
         cmp       byte ptr ds:[si+4],3     ; aktivn¡ kl vesnice
         ja        ReadCnf9                 ; chyba
         test      byte ptr ds:[si+6],not 1 ; p©¡znak zvuku
         jnz       ReadCnf9                 ; chyba
         test      byte ptr ds:[si+7],not 1 ; p©¡znak metronomu
         jnz       ReadCnf9                 ; chyba
         test      byte ptr ds:[si+12],not 1 ; p©¡znak editace
         jnz       ReadCnf9

; ------ ovˆ©en¡ kontroln¡ho sou‡tu konfigurace

         push      si
         mov       cx,offset(CheckSum-KONFIG) ; d‚lka dat
         xor       ax,ax
ReadCnf6:rol       ax,1
         xor       al,ds:[si]
         inc       si
         loop      ReadCnf6
         cmp       ds:[si],ax               ; kontrola kontroln¡ho sou‡tu
         pop       si
         jne       ReadCnf9                 ; nen¡ platn  konfigurace

; ------ p©enesen¡ konfigurace do bufferu

         push      ds
         pop       es
         mov       di,offset KONFIG         ; buffer konfigurace
         mov       cx,offset(KONFIG0-KONFIG) ; d‚lka konfigurace
         cld
         rep       movsb                    ; ulo‘en¡ konfigurace

; ------ n vrat registr–

ReadCnf9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ReadCnf  ENDP

; -----------------------------------------------------------------------------
;        rozbor p©¡kazov‚ho © dku (CY=chyba)
; -----------------------------------------------------------------------------

Rozbor   PROC      NEAR

; ------ p©¡prava p©¡kazov‚ho © dku

         mov       es,ds:[SegmPSP]          ; segment PSP
         mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         mov       bh,0
         mov       bl,es:[si-1]             ; d‚lka p©¡kazov‚ho © dku
         mov       es:[si+bx],bh            ; ozna‡en¡ konce p©¡kazov‚ho © dku

; ------ na‡ten¡ prvn¡ho znaku parametru

Rozbor1: call      RozbSpc                  ; vypu¨tˆn¡ mezer
         call      RozbChr                  ; na‡ten¡ znaku
         jnc       Rozbor2                  ; je dal¨¡ znak OK
         clc                                ; p©¡znak operace OK
         ret

; ------ vypu¨tˆn¡ oddˆlova‡e parametr–

Rozbor2: cmp       al,"/"                   ; je to oddˆlova‡ parametr– ?
         je        Rozbor1                  ; oddˆlova‡ parametr– se vypou¨t¡
         cmp       al,"-"
         je        Rozbor1                  ; jin˜ typ oddˆlova‡e se vypou¨t¡

; ------ parametr "C" - konfigura‡n¡ soubor

         cmp       al,"C"                   ; je konfigura‡n¡ soubor ?
         jne       Rozbor3                  ; nen¡ konfigura‡n¡ soubor
         mov       di,offset KonfSpec       ; buffer pro konfigura‡n¡ soubor
         call      RozbFile                 ; rozbor jm‚na souboru
         jmp       short Rozbor1            ; dal¨¡ parametr

; ------ parametr "T" - adres © s testy

Rozbor3: cmp       al,"T"                   ; je adres © s testy ?
         jne       Rozbor4                  ; nen¡ adres © s testy
         mov       di,offset TestSpec       ; buffer pro adres © s testy
         call      RozbFile                 ; rozbor jm‚na adres ©e
         mov       ds:[TestSpcA],di         ; adresa konce textu
         jmp       short Rozbor1            ; dal¨¡ parametr

; ------ parametr "P" - adres © s protokoly

Rozbor4: cmp       al,"P"                   ; je adres © s protokoly ?
         jne       Rozbor5                  ; nen¡ adres © s protokoly
         mov       di,offset ProtSpec       ; buffer pro adres © s protokoly
         call      RozbFile                 ; rozbor jm‚na adres ©e
         mov       ds:[ProtSpcA],di         ; adresa konce textu
         jmp       short Rozbor1            ; dal¨¡ parametr

; ------ chyba - neplatn˜ parametr

Rozbor5: stc                                ; p©¡znak chyby parametru
         ret

Rozbor   ENDP

; -----------------------------------------------------------------------------
;      na‡ten¡ specifikace souboru/adres ©e SI do bufferu DI (ni‡¡ AX, BX)
; VSTUP: ES:DI=ukazatel na koncovou 0 (je odstranˆn koncov˜ znak "\" - i pro ROOT)
; -----------------------------------------------------------------------------

RozbFile PROC      NEAR

; ------ p©¡prava registr–

         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       bx,di                    ; BX <- za‡ tek bufferu

; ------ vypu¨tˆn¡ mezer p©ed za‡ tkem textu

         call      RozbSpc                  ; vypu¨tˆn¡ mezer

; ------ p©enos textu souboru

RozbFil1:call      RozbChr                  ; na‡ten¡ znaku
         jb        RozbFil6                 ; konec textu
         je        RozbFil5                 ; mezera je jako konec jm‚na
         cmp       al,"/"                   ; je dal¨¡ parametr ?
         je        RozbFil5                 ; je dal¨¡ parametr
         stosb                              ; ulo‘en¡ znaku
         jmp       short RozbFil1           ; dal¨¡ znak

; ------ n vrat neplatn‚ho znaku

RozbFil5:dec       si                       ; n vrat neplatn‚ho znaku

; ------ vypu¨tˆn¡ znaku "\" z konce textu

RozbFil6:cmp       di,bx                    ; byl nˆjak˜ text ?
         je        RozbFil7                 ; nebyl ‘ dn˜ text
         mov       al,"\"                   ; hledan˜ znak konce
         dec       di                       ; n vrat na posledn¡ znak
         scasb                              ; je koncov˜ znak "\" ?
         jne       RozbFil7                 ; nen¡ koncov˜ znak "\"
         dec       di                       ; zru¨en¡ koncov‚ho znaku "\"

; ------ ulo‘en¡ koncov‚ 0

RozbFil7:mov       al,0
         stosb                              ; ulo‘en¡ koncov‚ 0
         dec       di                       ; n vrat na koncovou 0
         ret

RozbFile ENDP

; -----------------------------------------------------------------------------
;        vypu¨tˆn¡ mezer z p©¡kazov‚ho © dku SI
; -----------------------------------------------------------------------------

RozbSpc  PROC      NEAR

         call      RozbChr                  ; na‡ten¡ znaku
         jb        RozbSpc2                 ; konec textu
         je        RozbSpc                  ; vypu¨tˆn¡ mezery
         dec       si                       ; n vrat posledn¡ho znaku
RozbSpc2:ret

RozbSpc  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ znaku z p©¡kazov‚ho © dku SI
; -----------------------------------------------------------------------------

RozbChr  PROC      NEAR

; ------ na‡ten¡ znaku z p©¡kazov‚ho © dku

         push      ds
         mov       ds,ds:[SegmPSP]          ; segment PSP
         cld
         lodsb                              ; na‡ten¡ znaku
         pop       ds

; ------ n hrada tabul toru mezerou

         cmp       al,9                     ; je tabul tor ?
         jne       RozbChr2                 ; nen¡ tabul tor
         mov       al," "                   ; n hrada mezerou

; ------ konverze na velk‚ p¡smeno

RozbChr2:cmp       al,"a"
         jb        RozbChr4
         cmp       al,"z"
         ja        RozbChr4
         sub       al,32                    ; konverze na velk‚ p¡smeno

; ------ test, zda je platn˜ znak

RozbChr4:cmp       al," "                   ; je to platn˜ znak ?
         jae       RozbChr6                 ; je to platn˜ znak
         dec       si                       ; n vrat neplatn‚ho znaku
RozbChr6:ret

RozbChr  ENDP

; -----------------------------------------------------------------------------
;        inicializace implicitn¡ch cest k soubor–m
; -----------------------------------------------------------------------------

InitHome PROC      NEAR

; ------ p©¡prava specifikace konfigura‡n¡ho souboru

         mov       si,offset KONFFILE       ; SI <- konfigura‡n¡ soubor
         mov       di,offset KonfSpec       ; buffer konfigura‡n¡ho souboru
         call      HomeFile                 ; sestaven¡ jm‚na souboru

; ------ p©¡prava specifikace adres ©e s testy

         mov       si,offset TESTFILE       ; adres © test–
         mov       di,offset TestSpec       ; buffer adres ©e test–
         call      HomeFile                 ; sestaven¡ jm‚na adres ©e
         mov       ds:[TestSpcA],di         ; adresa konce cesty

; ------ p©¡prava specifikace adres ©e s protokoly

         mov       si,offset PROTFILE       ; adres © protokol– test–
         mov       di,offset ProtSpec       ; buffer adres ©e protokol–
         call      HomeFile                 ; sestaven¡ jm‚na adres ©e
         mov       ds:[ProtSpcA],di         ; adresa konce cesty
         ret

InitHome ENDP

; -----------------------------------------------------------------------------
;        sestaven¡ jm‚na souboru v domovsk‚m adres ©i
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=jm‚no souboru ASCIIZ k sestaven¡
;        DI=buffer k ulo‘en¡ jm‚na souboru
; VSTUP: ES:DI=ukazatel na koncovou 0 specifikace souboru
; ni‡¡ registry AX, BX a SI !
; -----------------------------------------------------------------------------

HomeFile PROC      NEAR

; ------ test verze syst‚mu

         push      si
         push      di
         mov       ah,30h
         int       21h                      ; test verze syst‚mu
         pop       di
         pop       si
         cmp       al,3                     ; je DOS verze minim lnˆ 3.00 ?

; ------ kontrola adresy prost©ed¡

         mov       es,ds:[SegmPSP]          ; ES <- segment PSP
         mov       ax,es:[2ch]              ; AX <- segment prost©ed¡
         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       bx,di                    ; BX <- konec cesty
         mov       cx,0                     ; CX <- 0 ‡¡ta‡ d‚lky cesty
         cld
         jb        HomeFil7                 ; je n¡zk  verze syst‚mu

         cmp       ax,50h                   ; je platn‚ prost©ed¡ ?
         jb        HomeFil7                 ; neplatn‚ prost©ed¡

; ------ nalezen¡ konce prost©ed¡

         push      si
         push      ds
         mov       ds,ax                    ; DS <- segment prost©ed¡
         xor       si,si                    ; ukazatel prost©ed¡
HomeFil1:inc       si                       ; zv˜¨en¡ ukazatele v prost©ed¡
         js        HomeFil2                 ; p©ete‡en¡
         cmp       word ptr ds:[si-1],0     ; je konec prost©ed¡ ?
         jne       HomeFil1                 ; nalezen¡ konce prost©ed¡

; ------ nastaven¡ na za‡ tek cesty

HomeFil2:inc       si                       ; p©esko‡en¡ koncov‚ 0
         inc       si
         inc       si                       ; p©esko‡en¡ po‡tu ©etˆzc–

; ------ p©enesen¡ specifikace souboru

HomeFil3:lodsb
         cmp       al,0
         je        HomeFil6                 ; je konec textu
         stosb
         inc       cx                       ; ‡¡ta‡ d‚lky ©etˆzce
         cmp       al,":"
         je        HomeFil4
         cmp       al,"\"
         jne       HomeFil5
HomeFil4:mov       bx,di                    ; BX <- £schova konce cesty
HomeFil5:cmp       cx,128                   ; je buffer ji‘ pln˜ ?
         jb        HomeFil3                 ; dal¨¡ znak
HomeFil6:pop       ds
         pop       si

; ------ p©id n¡ jm‚na souboru ASCIIZ

HomeFil7:mov       di,bx                    ; DI <- konec cesty
HomeFil8:lodsb
         stosb
         cmp       al,0
         jne       HomeFil8
         dec       di                       ; n vrat na koncovou 0
         ret

HomeFile ENDP

; *****************************************************************************
;
;                              v˜uka
;
; *****************************************************************************
;þ
Vyuka:

; ------ zobrazen¡ kl vesnice s norm ln¡m vysv¡cen¡m

Vyuka1:  mov       word ptr ds:[AktLekce],0 ; nen¡ ‘ dn  lekce aktivn¡
         call      DispKlav                 ; zobrazen¡ kl vesnice

; ------ vymaz n¡ pap¡ru

         call      NovyPap                  ; vymaz n¡ pap¡ru

; ------ zobrazen¡ prav¡tka

         call      Lineal                   ; zobrazen¡ prav¡tka

; ------ zobrazen¡ textu k volbˆ skupiny

         push      ds
         pop       es
         mov       si,ds:[AdrSkup]          ; text k volbˆ skupin
         call      DispTTxt                 ; zobrazen¡ £vodn¡ho textu

; ------ volba lekce

         mov       si,ds:[AdrMenS]          ; skupinov‚ menu
         call      Menu                     ; obsluha menu
         jnc       Vyuka12                  ; byla provedena nˆjak  volba
         jmp       Start4                   ; p©eru¨en¡

; ------ zobrazen¡ aktivn¡ch kl ves lekce

Vyuka12: mov       ds:[AktLekce],bx         ; £schova ‡¡sla lekce (1=£vod)
         mov       word ptr ds:[AktCvic],0  ; aktivn¡ str nka/cvi‡en¡
         call      DispKlav                 ; zobrazen¡ kl ves
         call      NovyPap                  ; nov˜ pap¡r
         dec       bx
         jz        Vyuka14                  ; je £vod

; ------ pro DEMO nen¡ pot©eba p©ipravovat ‡¡slo (pro lekce 5...)

IFDEF    DEMO
         cmp       bl,5
         ja        Vyuka14                  ; je nepovolen  lekce DEMO
ENDIF
; ------ p©¡prava ‡¡sla lekce

         mov       al,bl                    ; ‡¡slo lekce
         aam                                ; rozdˆlen¡ na 2 znaky
         xchg      al,ah                    ; oprava po©ad¡ znak–
         add       ax,"00"                  ; korekce na znaky ASCII
         mov       word ptr ds:[LekcTxtN+7],ax ; ‡¡slo lekce

; ------ zobrazen¡ ‡¡sla lekce

         push      ds
         pop       es                       ; ES <- DS
         mov       si,offset LekcTxtN       ; ‡¡slo lekce
         call      DispTTxt                 ; zobrazen¡ ‡¡sla lekce

; ------ adresa definice lekce

Vyuka14: shl       bx,1
         shl       bx,1                     ; ‡¡slo lekce * 4

; ------ zobrazen¡ textu lekce

         push      bx
         add       bx,ds:[AdrTLekc]         ; tabulka adres lekc¡
         les       si,ds:[bx]               ; adresa definice lekce
         call      DispTTxt                 ; zobrazen¡ textu lekce
         pop       bx
         jc        Vyuka1                   ; p©eru¨en¡ lekce

; ------ adresa definice lekc¡

         add       bx,ds:[AdrTLDat]         ; tabulka adres definic lekc¡
         les       si,ds:[bx]               ; adresa definice lekc¡
         mov       bp,si                    ; BP <- adresa za‡ tku definic lekc¡

; ------ test, zda je v¡ce© dkov˜ test

Vyuka22: cmp       byte ptr es:[si-1],FF    ; je za‡ tek v¡ce© dkov‚ho testu ?
         je        Vyuka22A
         cmp       byte ptr es:[si],FF      ; je dal¨¡ © dek ?
         jne       Vyuka222                 ; je dal¨¡ © dek
         inc       si                       ; p©esko‡en¡ znaku FF

; ------ proveden¡ v¡ce© dkov‚ho testu

Vyuka22A:push      si
         and       byte ptr ds:[ParTest],not bit1 ; inic. parametr–
         or        byte ptr ds:[ParTest],bit0+bit3 ; je kontrola, z kaz editace
         call      TestT                    ; test
         pop       si
         jc        Vyuka22C                 ; p©eru¨en¡ testu

         push      si
         push      di
         push      es

         push      ds
         pop       es
         mov       di,TOPKLAV + (80-36)/2 + 130*80
         mov       si,offset TestErr
         cmp       word ptr ds:[Vykon],100
         cmc
         jnc       Vyuka22B
         cmp       word ptr ds:[Chyby],80
         jnc        Vyuka22B
         mov       si,offset TestOK
Vyuka22B:pushf
         call      DispTxt
         popf

         pop       es
         pop       di
         pop       si

Vyuka22C:pushf
         cmp       word ptr ds:[Uhozy],2
         jb        Vyuka22D
Vyuka22E:call      InpKey
Vyuka22D:popf
         jnc       Vyuka221                 ; je opakov n¡ lekce

Vyuka220:inc       si
         cmp       byte ptr es:[si],FF
         je        Vyuka224
         cmp       byte ptr es:[si],EOT
         jne       Vyuka220
Vyuka224:stc

Vyuka221:cmp       byte ptr es:[si],FF
         je        Vyuka225
         cmp       byte ptr es:[si-1],FF
         je        Vyuka225
         call      PodkKlav                 ; vymaz n¡ podkladu kl vesnice
         call      DispKlav
Vyuka225:jmp       short Vyuka22

; ------ test, zda je konec v˜ukov˜ch text–

Vyuka222:cmp       byte ptr es:[si],EOT     ; zbyl nˆjak˜ v˜ukov˜ text ?
         jne       Vyuka3                   ; je dal¨¡ © dek textu

; ------ zv˜¨en¡ ukazatele lekc¡

         push      si
         mov       si,ds:[AdrMenS]          ; skupinov‚ menu
         mov       al,ds:[si]               ; aktivn¡ polo‘ka
         cmp       al,ds:[si+1]             ; je ji‘ posledn¡ polo‘ka ?
         jbe       Vyuka23                  ; je ji‘ posledn¡ polo‘ka
         inc       byte ptr ds:[si+1]       ; zv˜¨en¡ ukazatele lekc¡
Vyuka23: pop       si


Vyuka24:
         jmp       Vyuka1                   ; n vrat do menu volby lekce

Vyuka3:  call      VyukLin                  ; jedno© dkov˜ test
         jc        Vyuka24                  ; p©eru¨en¡
         jmp       Vyuka22                  ; dal¨¡ test

; -----------------------------------------------------------------------------
;    jedno© dkov˜ test p©i v˜uce (ES:SI=text) -> CY=p©eru¨en¡, ES:SI=dal¨¡ test
; -----------------------------------------------------------------------------

VyukLin  PROC      NEAR

; ------ £schova registr– (SI jako posledn¡ !)

         push      si                       ; adresa za‡ tku © dku

; ------ vymaz n¡ © dku

         mov       di,ENDTEXT+LFTTEXT - (FONTEXT+LINKURZ)*80 ; po‡. k zobr.textu
         mov       ah,15                    ; barva
         mov       cx,SIRTEXT               ; ¨¡©ka obd‚ln¡ku
         mov       bx,FONTEXT               ; v˜¨ka obd‚ln¡ku
         call      DispBox                  ; vymaz n¡ obd‚ln¡ku textu

; ------ zobrazen¡ © dku v˜ukov‚ho textu

         mov       byte ptr ds:[PozTxt],0   ; ukazatel pozice na © dku
         mov       ah,ds:[TColVyuk]         ; barva textu
         push      si
VyukLin1:mov       al,es:[si]               ; znak k zobrazen¡
         call      DispChT                  ; zobrazen¡ znaku
         inc       si                       ; zv˜¨en¡ ukazatele textu
         cmp       byte ptr es:[si]," "     ; je konec © dku ?
         jae       VyukLin1                 ; nen¡ je¨tˆ konec © dku - dal¨¡ znak
         mov       al,CR                    ; znak konce © dku
         call      DispChT                  ; zobrazen¡ znaku CR
         pop       si

; ------ inicializace ukazatel–

         mov       byte ptr ds:[PozTxt],0   ; nulov n¡ ukazatele pozice na © dku
         mov       word ptr ds:[CitChyb],0  ; ‡¡ta‡ chyb
         call      NulUhoz                  ; nulov n¡ ‡¡ta‡e £hoz–
         call      NulMetr                  ; nulov n¡ metronomu

; ------ ‡ek n¡ na zad n¡ prvn¡ho znaku

         call      DispKurz                 ; zobrazen¡ kurzoru
VyukLn14:call      LupMetr                  ; obsluha metronomu
         call      TestKey                  ; test kl vesy
         jc        VyukLn14                 ; ‡ek n¡ na stisk kl vesy

; ------ nulov n¡ ukazatel–

         call      NulTime                  ; nulov n¡ ‡¡ta‡e ‡asu
         call      MazTime                  ; vymaz n¡ plochy k zobrazen¡ ‡asu

; ------ zapnut¡ kurzoru

VyukLin2:call      DispKurz                 ; zobrazen¡ kurzoru

; ------ zobrazen¡ v˜konu

         call      DispVykn                 ; zobrazen¡ v˜konu

; ------ zad n¡ kl vesy

VyukLin3:call      GetTime                  ; poskytnut¡ ubˆhl‚ho ‡asu
         call      DispTime                 ; obsluha zobrazen¡ ‡asu
         call      LupMetr                  ; obsluha metronomu
         call      TestKey                  ; byla stisknuta kl vesa ?
         jc        VyukLin3                 ; nen¡ kl vesa - ‡ek n¡
         call      InpKey                   ; vstup znaku z kl vesnice
         jnc       VyukLn32                 ; znak je OK
VyukLn31:jmp       VyukLin8                 ; p©eru¨en¡ operace

; ------ vypnut¡ kurzoru

VyukLn32:call      MazKurz                  ; vymaz n¡ kurzoru

; ------ HOME - opakov n¡ cvi‡en¡

         cmp       ax,4700h                 ; HOME ?
         je        VyukLn31                 ; HOME - opakov n¡ cvi‡en¡

; ------ na‡ten¡ fale¨n‚ho znaku pro Ctrl-F9

         cmp       ax,6600h                 ; Ctrl-F9
         jne       VyukLn34                 ; nen¡ Ctrl-F9
         mov       al,es:[si]               ; po‘adovan˜ znak
         cmp       al," "
         jae       VyukLn34
         mov       al,CR

; ------ PAGEDOWN - dal¨¡ © dek testu

VyukLn34:cmp       ax,5100h                 ; je str nka dol– ?
         jne       VyukLn46                 ; nen¡ str nka dol–

VyukLin4:pop       si                       ; adresa za‡ tku © dku
VyukLn42:inc       si                       ; zv˜¨en¡ ukazatele textu
         cmp       byte ptr es:[si-1]," "   ; je za‡ tek dal¨¡ho © dku ?
         jae       VyukLn42                 ; nalezen¡ dal¨¡ho © dku
VyukLn44:clc
         jmp       short VyukLin9           ; n vrat

; ------ PAGEUP - p©ede¨l˜ © dek testu

VyukLn46:cmp       ax,4900h                 ; je str nka nahoru ?
         jne       VyukLin5                 ; nen¡ str nka nahoru

         pop       si                       ; adresa za‡ tku © dku
         cmp       byte ptr es:[si-1],LF    ; bude dal¨¡ © dek ?
         stc                                ; p©¡znak chyby - nen¡ p©ede¨l˜ © dek
         jne       VyukLin9                 ; nebude dal¨¡ © dek
VyukLn48:dec       si                       ; sn¡‘en¡ ukazatele textu
         cmp       byte ptr es:[si-1]," "   ; je za‡ tek p©ede¨l‚ho © dku ?
         jae       VyukLn48                 ; nalezen¡ p©ede¨l‚ho © dku
         jmp       short VyukLn44

; ------ test povolen‚ho znaku

VyukLin5:cmp       al,CR                    ; je ENTER ?
         jne       VyukLn52                 ; nen¡ ENTER
         mov       al,LF                    ; n hrada znakem LF
         jmp       short VyukLn54           ; znak je povolen

VyukLn52:cmp       al," "                   ; je znak platn˜ ?
         jb        VyukLin2                 ; znak nen¡ platn˜

; ------ aktualizace ‡asu stisku kl vesy

VyukLn54:call      AktTime                  ; aktualizace ‡asu stisku kl vesy
         call      IncUhoz                  ; zv˜¨en¡ ‡¡ta‡e £hoz–
         call      LupKey                   ; lupnut¡ psac¡ho stroje

; ------ test, zda byl zad n spr vn˜ znak

         cmp       al,es:[si]               ; souhlas¡ znak ?
         jne       VyukLin7                 ; znak nesouhlas¡
         inc       si                       ; zv˜¨en¡ ukazatele textu

; ------ zobrazen¡ spr vn‚ho znaku

         cmp       al,LF                    ; je LF ?
         jne       VyukLn56                 ; nen¡ LF
         mov       al,CR                    ; n hradn¡ znak
VyukLn56:mov       ah,ds:[TColOK]           ; barva spr vn‚ho znaku
         call      DispChT                  ; zobrazen¡ znaku

; ------ test, zda je konec testu

         cmp       al,CR                    ; je konec ?
         jne       VyukLn74                 ; nen¡ konec - dal¨¡ znak

; ------ konec - test, zda byla nˆjak  chyba

         cmp       word ptr ds:[CitChyb],0  ; byla nˆjak  chyba ?
         je        VyukLin4                 ; nen¡ chyba - dal¨¡ test
         jmp       short VyukLin8           ; jinak opakov n¡ testu

; ------ zobrazen¡ chybn‚ho znaku

VyukLin7:mov       al,es:[si]               ; po‘adovan˜ znak
         cmp       al,LF                    ; je konec © dku ?
         jne       VyukLn72                 ; nen¡ konec © dku
         mov       al,CR                    ; n hrada znakem CR
VyukLn72:mov       ah,ds:[TColErr]          ; barva chybn‚ho znaku
         call      DispChT0                 ; zobrazen¡ znaku
         inc       word ptr ds:[CitChyb]    ; ‡¡ta‡ chyb
         call      TestBErr                 ; chybov‚ p¡pnut¡
VyukLn74:jmp       VyukLin2                 ; dal¨¡ znak

VyukLin8:pop       si                       ; n vrat adresy za‡ tku © dku
VyukLin9:ret

VyukLin  ENDP

; *****************************************************************************
;
;                           Obsluha menu
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        obsluha menu podle definice DS:SI -> BX=zvolen  volba, CY=p©eru¨en¡
; -----------------------------------------------------------------------------

Menu     PROC      NEAR

; ------ £schova registr–

         push      ax

; ------ zapnut¡ kurzoru

Menu1:   call      DispMKur                 ; zobrazen¡ kurzoru menu

; ------ ‡ek n¡ na stisk kl vesy

Menu2:   call      InpKey                   ; vstup znaku z kl vesnice
         mov       bx,ds:[si]
         xchg      bh,bl                    ; BL <- polo‘ka, BH <- po‡et pol.
         pushf
         call      MazMKur                  ; vypnut¡ kurzoru
         popf
         jnc       Menu22
Menu21:  jmp       Menu9                    ; p©eru¨en¡ obsluhy ESC

; ------ proveden¡ volby ENTER (nebo mezera)

Menu22:  cmp       al,13
         je        Menu21
         cmp       al," "
         je        Menu21

; ------ kurzor dol–

         cmp       ax,5000h
         jne       Menu32
         inc       bx                       ; zv˜¨en¡ ‡¡sla polo‘ky
         cmp       bl,bh                    ; p©ekro‡en konec ?
         jbe       Menu3
Menu30:  mov       bl,1                     ; posun na po‡ tek
Menu3:   mov       ds:[si+1],bl             ; nov  aktivn¡ polo‘ka
         jmp       short Menu1

; ------ kurzor nahoru

Menu32:  cmp       ax,4800h
         jne       Menu34
         dec       bx
         cmp       bl,0
         jne       Menu3
Menu33:  mov       bl,bh
         jmp       short Menu3

; ------ prvn¡ polo‘ka

Menu34:  cmp       ax,4700h
         je        Menu30

; ------ posledn¡ polo‘ka

         cmp       ax,4f00h
         je        Menu33

; ------ kurzor vlevo

         cmp       ax,4b00h
         jne       Menu36
         sub       bl,ds:[si+2]
         ja        Menu3
Menu35:  add       bl,ds:[si+2]
         cmp       bl,bh
         jb        Menu35
         je        Menu3
         sub       bl,ds:[si+2]
         jmp       short Menu3

; ------ kurzor vpravo

Menu36:  cmp       ax,4d00h
         jne       Menu38
         add       bl,ds:[si+2]
         cmp       bl,bh
         jbe       Menu3
Menu37:  sub       bl,ds:[si+2]
         ja        Menu37
         add       bl,ds:[si+2]
         jmp       short Menu3

; ------ p©ep¡n n¡ nastaven¡

Menu38:  cmp       si,offset NastMenu       ; je nastaven¡ menu ?
         jne       Menu39
         cmp       ax,3d00h                 ; F3
         jne       Menu382
Menu381: xor       bx,bx
         jmp       short Menu9

Menu382: cmp       ax,3c00h                 ; F2
         je        Menu381

; ------ nalezen¡ hork‚ kl vesy

Menu39:  cmp       al,"a"
         jb        Menu4
         cmp       al,"z"
         ja        Menu4
         sub       al,32

Menu4:   push      si
         mov       bl,1
Menu42:  add       si,3
         cmp       al,ds:[si+2]
         je        Menu48
         inc       bx
         dec       bh
         jnz       Menu42
         pop       si
         jmp       Menu1

Menu48:  pop       si
         mov       ds:[si+1],bl             ; nov  aktivn¡ volba

; ------ n vrat registr–

Menu9:   mov       bh,0
         pop       ax
         ret

Menu     ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ p©ep¡na‡e polo‘ky AL menu DS:SI (barva AH)
; -----------------------------------------------------------------------------

DispSwc  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      dx
         push      si
         push      di
         call      SetFNT16

; ------ adresa k zobrazen¡ p©ep¡na‡e

         push      ax
         mov       ah,0                     ; AX = po‘adovan  polo‘ka
         add       si,ax
         shl       ax,1
         add       si,ax                    ; adresa pozice
         mov       al,FONTEXT               ; po‡et linek na znak
         mul       byte ptr ds:[si+1]       ; p©epo‡et © dku na linky
         mov       dx,80
         mul       dx                       ; p©epo‡et na offset
         mov       dl,ds:[si]               ; pozice
         mov       dh,0
         add       ax,dx                    ; adresa ve videopamˆti
         add       ax,LFTTEXT
         xchg      ax,di
         pop       ax

; ------ zobrazen¡ p©ep¡na‡e

         mov       al,"û"
         call      DispChr

; ------ n vrat registr–

         pop       di
         pop       si
         pop       dx
         pop       ax
         ret

DispSwc  ENDP

; -----------------------------------------------------------------------------
;        vymaz n¡ kurzoru menu DS:SI
; -----------------------------------------------------------------------------

MazMKur  PROC      NEAR

         push      ax
         mov       ah,15                    ; barva pro vymaz n¡
         jmp       short DispMKr1

MazMKur  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ kurzoru menu DS:SI
; -----------------------------------------------------------------------------

DispMKur PROC      NEAR

; ------ £schova registr–

         push      ax
         mov       ah,2                     ; barva pro zobrazen¡

DispMKr1:push      dx
         push      si
         push      di
         call      SetFNT16                 ; nastaven¡ fontu 16 linek

; ------ adresa k zobrazen¡ kurzoru

         push      ax
         mov       al,ds:[si+1]             ; aktivn¡ polo‘ka
         mov       ah,0
         add       si,ax
         shl       ax,1
         add       si,ax                    ; adresa pozice
         mov       al,FONTEXT               ; po‡et linek na znak
         mul       byte ptr ds:[si+1]       ; p©epo‡et © dku na linky
         mov       dx,80
         mul       dx                       ; p©epo‡et na offset
         mov       dl,ds:[si]               ; pozice
         mov       dh,0
         add       ax,dx                    ; adresa ve videopamˆti
         add       ax,LFTTEXT-4             ; posun o lev˜ okraj pap¡ru
         xchg      ax,di                    ; DI <- adresa ve videopamˆti
         pop       ax

; ------ zobrazen¡ kurzoru

         mov       al,"Ä"                   ; st©ed ‡ ry
         call      DispChr0
         call      DispChr
         dec       di
         mov       al,"Í"
         call      DispChr0                 ; okol¡ ‡ ry
         call      DispChr0
         mov       al,16
         call      DispChr                  ; znak ¨ipky

; ------ n vrat registr–

         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

DispMKur ENDP

; -----------------------------------------------------------------------------
;        nov˜ pap¡r
; -----------------------------------------------------------------------------

NovyPap  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

; ------ inicializace hodin

         call      CekInit                  ; inicializace hodin

; ------ plocha pro v˜stup textu

         xor       di,di                    ; po‡ te‡n¡ adresa
         mov       bx,LINTEXT               ; po‡et linek
         mov       ah,8                     ; barva podkladu
         mov       cx,80                    ; ¨¡©ka obrazovky
         call      DispBox                  ; vymaz n¡ podkladu

; ------ zobrazen¡ pap¡ru

         mov       di,ENDTEXT-LINKURZ*80+LFTPAPIR ; po‡. k zobr.pap¡ru
         sub       di,ds:[IncRoll]          ; bez jednoho © dku pro rolov n¡
         mov       bx,LINKURZ               ; po‡et linek
         add       bx,ds:[LinRoll]          ; plus jeden © dek textu
         mov       ah,15                    ; barva pap¡ru
         mov       cx,SIRPAPIR              ; ¨¡©ka pap¡ru
         call      DispBox                  ; zobrazen¡ pap¡ru

         mov       byte ptr ds:[PozTxt],0   ; ukazatel pozice kurzoru na © dku

; ------ n vrat registr–

         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

NovyPap  ENDP

; -----------------------------------------------------------------------------
;        nulov n¡ ‡¡ta‡e ‡asu
; -----------------------------------------------------------------------------

NulTime  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx

; ------ £schova po‡ te‡n¡ho data

         mov       ah,2ah
         int       21h                      ; poskytnut¡ syst‚mov‚ho data
         mov       word ptr ds:[BegDateD],dx ; den a mˆs¡c data
         mov       word ptr ds:[BegDateY],cx ; rok

; ------ £schova po‡ te‡n¡ho ‡asu

         mov       ah,2ch
         int       21h                      ; poskytnut¡ syst‚mov‚ho ‡asu
         mov       word ptr ds:[BegTimeT],dx ; sekundy a setiny sekundy
         mov       word ptr ds:[BegTimeM],cx ; minuta a hodina

; ------ nulov n¡ ‡¡ta‡e doby

         mov       word ptr ds:[Doba],0     ; celkovˆ ubˆhl  doba
         mov       word ptr ds:[AktDoba],0  ; aktu lnˆ ubˆhl  doba
         mov       word ptr ds:[LastDTim],-1 ; ‡as nen¡ zobrazen

; ------ n vrat registr–

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

NulTime  ENDP

; -----------------------------------------------------------------------------
;        vymaz n¡ plochy k zobrazen¡ ‡asu
; -----------------------------------------------------------------------------

MazTime  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      di

; ------ vymaz n¡ plochy k zobrazen¡ ‡asu

         mov       di,TOPLINE+6*80+80-5     ; po‡ te‡n¡ adresa
         mov       bx,LINLINE-6             ; po‡et linek
         mov       ah,9
         mov       cx,5                     ; ¨¡©ka
         call      DispBox

; ------ n vrat registr–

         pop       di
         pop       cx
         pop       bx
         pop       ax
         ret

MazTime  ENDP

; -----------------------------------------------------------------------------
;        aktualizace ‡¡ta‡e ubˆhl‚ho ‡asu
; -----------------------------------------------------------------------------

GetTime  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx

; ------ zji¨tˆn¡ aktu ln¡ho ‡asu

         mov       ah,2ch
         int       21h                      ; zji¨tˆn¡ aktu ln¡ho ‡asu

; ------ v˜po‡et ubˆhl‚ho ‡asu

         sub       dl,ds:[BegTimeT]         ; rozd¡l setin sekund
         jnc       GetTime1
         add       dl,100
GetTime1:sbb       dh,ds:[BegTimeS]         ; rozd¡l sekund
         jnc       GetTime2
         add       dh,60
GetTime2:sbb       cl,ds:[BegTimeM]         ; rozd¡l minut
         jnc       GetTime3
         add       cl,60
GetTime3:sbb       ch,ds:[BegTimeH]         ; rozd¡l hodin
         jnc       GetTime4
         add       ch,24

; ------ p©epo‡et ubˆhl‚ho ‡asu na sekundy

GetTime4:mov       ds:[DobaS],dl            ; ubˆhl  doba v setin ch sekundy
         mov       al,60                    ; po‡et minut na hodinu
         mul       ch                       ; p©epo‡et hodiny na minutu
         mov       ch,0
         add       ax,cx                    ; p©i‡ten¡ minuty
         mov       cl,dh                    ; CL <- sekundy
         mov       dx,60                    ; po‡et sekund na minutu
         mul       dx                       ; p©epo‡et minut na sekundy
         add       ax,cx                    ; p©i‡ten¡ sekundy
         mov       ds:[Doba],ax             ; ubˆhl  doba v sekund ch

; ------ n vrat registr–

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

GetTime  ENDP

; -----------------------------------------------------------------------------
;        aktualizace ‡asu p©i stisku kl vesy
; -----------------------------------------------------------------------------

AktTime  PROC      NEAR

         push      ax
         mov       ax,ds:[Doba]             ; celkovˆ ubˆhl  doba
         mov       ds:[AktDoba],ax          ; aktu lnˆ ubˆhl  doba
         mov       al,ds:[DobaS]            ; setiny sekundy ubˆhl‚ doby
         mov       ds:[AktDobaS],al         ; setiny sekundy
         pop       ax
         ret

AktTime  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ‡¡ta‡e ‡asu
; -----------------------------------------------------------------------------

DispTime PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      di

; ------ test, zda je pot©eba zobrazit ‡as

         mov       ax,ds:[Doba]             ; ubˆhl  doba v sekund ch
         cmp       ax,ds:[LastDTim]         ; je ‡as zobrazen ?
         je        DispTim9                 ; ‡as je ji‘ zobrazen
         mov       ds:[LastDTim],ax         ; £schova zobrazen‚ho ‡asu

; ------ vymaz n¡ plochy k zobrazen¡ ‡asu

         call      MazTime                  ; vymaz n¡ plochy k zobrazen¡ ‡asu

; ------ v˜po‡et po‡tu minut a sekund

         mov       cx,60
         xor       dx,dx
         div       cx                       ; v˜po‡et po‡tu minut
         push      dx                       ; £schova po‡tu sekund

; ------ zobrazen¡ po‡tu minut

         mov       di,TOPLINE+6*80+80-4     ; po‡ te‡n¡ adresa
         mov       bh,0                     ; barva
         cmp       ax,99
         jbe       DispTim7
         mov       ax,99
         pop       dx
         mov       dx,59
         push      dx
DispTim7:xor       dx,dx
         call      DispNum                  ; zobrazen¡ po‡tu minut

; ------ oddˆlovac¡ dvojte‡ka

         inc       di
         mov       ah,0
         mov       al,":"
         call      DispChr0

; ------ zobrazen¡ po‡tu sekund

         pop       ax                       ; po‡et sekund
         aam                                ; rozdˆlen¡ na ‡¡slice
         add       ax,"00"
         mov       cl,al
         mov       al,ah
         mov       ah,0
         call      DispChr0
         mov       al,cl
         call      DispChr0

; ------ n vrat registr–

DispTim9:pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispTime ENDP

; -----------------------------------------------------------------------------
;        nulov n¡ ‡¡ta‡e £hoz–
; -----------------------------------------------------------------------------

NulUhoz  PROC      NEAR

         mov       word ptr ds:[Uhozy],0
         mov       word ptr ds:[CitLUhoz],0 ; ‡¡ta‡ £hoz– na © dku
         mov       word ptr ds:[CitChybL],0 ; nulov n¡ ‡¡ta‡e chyb na © dku
         ret

NulUhoz  ENDP

; -----------------------------------------------------------------------------
;        zv˜¨en¡ ‡¡ta‡e £hoz– o znak AL
; -----------------------------------------------------------------------------

IncUhoz  PROC      NEAR

         push      dx
         call      GetUhoz                  ; poskytnut¡ po‡tu £hoz– znaku AL
         add       word ptr ds:[Uhozy],dx
         jnc       IncUhoz2
         mov       word ptr ds:[Uhozy],-1
IncUhoz2:add       ds:[CitLUhoz],dx         ; ‡¡ta‡ £hoz– na © dku
         pop       dx
         ret

IncUhoz  ENDP

; -----------------------------------------------------------------------------
;        sn¡‘en¡ ‡¡ta‡e £hoz– o znak AL
; -----------------------------------------------------------------------------

DecUhoz  PROC      NEAR

         push      dx
         call      GetUhoz                  ; poskytnut¡ po‡tu £hoz– znaku AL
         sub       word ptr ds:[Uhozy],dx
         jnc       DecUhoz2
         mov       word ptr ds:[Uhozy],0
DecUhoz2:sub       ds:[CitLUhoz],dx         ; ‡¡ta‡ £hoz– na © dku
         jnc       DecUhoz3
         mov       word ptr ds:[CitLUhoz],0
DecUhoz3:pop       dx
         ret

DecUhoz  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ v˜konu
; -----------------------------------------------------------------------------

DispVykn PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      di

; ------ plocha k zobrazen¡ v˜konu

         mov       di,TOPLINE+6*80          ; po‡ te‡n¡ adresa
         mov       bx,LINLINE-6             ; po‡et linek
         mov       ah,9
         mov       cx,10                    ; ¨¡©ka
         call      DispBox

; ------ v˜po‡et v˜konu

         call      GetVykon                 ; v˜po‡et v˜konu
         jc        DispVyk3                 ; v˜kon nelze ur‡it

; ------ p©¡prava k zobrazen¡ po‡tu £hoz–

         call      SetFNT08                 ; nastaven¡ fontu 08
         mov       di,TOPLINE+6*80
         mov       bh,0
         mov       ax,word ptr ds:[Vykon]
         xor       dx,dx
         cmp       ax,1000
         jae       DispVyk2
         inc       di
DispVyk2:call      DispLNum                 ; zobrazen¡ ‡¡sla vlevo

; ------ n vrat registr–

DispVyk3:pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispVykn ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ prav¡tka
; -----------------------------------------------------------------------------

Lineal   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      di

; ------ plocha k zobrazen¡ prav¡tka

         mov       di,TOPLINE               ; po‡ te‡n¡ adresa
         mov       bx,LINLINE               ; po‡et linek
         mov       ah,9                     ; barva prav¡tka
         mov       cx,80                    ; ¨¡©ka prav¡tka
         call      DispBox                  ; zobrazen¡ podkladu prav¡tka

; ------ p©¡prava k zobrazen¡ stupnice

         call      SetFNT08                 ; nastaven¡ fontu 08
         mov       di,TOPLINE-3*80+LFTTEXT  ; po‡ tek k zobrazen¡
         mov       cx,SIRTEXT-2             ; ¨¡©ka textu (pozic)
         mov       bl,1                     ; ukazatel ‡¡sla pozice
         mov       ah,0                     ; barva ‡ern 
         mov       al,249                   ; lev˜ roh (zobrazen¡ pro "1")
         jmp       short Lineal3

; ------ zobrazen¡ stupnice

Lineal1: mov       al,250                   ; bˆ‘n˜ bod
         cmp       bl,10                    ; je 10 ?
         jne       Lineal2
         mov       al,"Ò"                   ; zes¡len˜ bod pro des¡tky
         mov       bl,0                     ; ‡¡ta‡ stupnice zase na 0
Lineal2: cmp       bl,5                     ; je 5 ?
         jne       Lineal3
         mov       al,"Â"                   ; bod pro 5
Lineal3: call      DispChr0                 ; zobrazen¡ znaku
         inc       bx                       ; zv˜¨en¡ relativn¡ho ukazatele
         loop      Lineal1                  ; dal¨¡ znak

; ------ p©¡prava k zobrazen¡ ‡¡slic

         mov       di,TOPLINE+6*80+LFTTEXT + 8 ; po‡ tek k zobrazen¡
         mov       ah,4                     ; barva ‡¡slic prav¡tka (‡ern )
         mov       al,"1"                   ; ‡¡slice prav¡tka

; ------ zobrazen¡ ‡¡slic

Lineal4: call      DispChr0                 ; zobrazen¡ ‡¡slice des¡tek
         push      ax
         mov       al,"0"                   ; ‡¡slice "0"
         call      DispChr0                 ; zobrazen¡ ‡¡slice "0"
         pop       ax
         add       di,8                     ; zv˜¨en¡ adresy
         inc       ax                       ; zv˜¨en¡ ‡¡slice
         cmp       al,"7"                   ; jsou ji‘ v¨echny des¡tky ?
         jbe       Lineal4                  ; dal¨¡ ‡¡slice

; ------ n vrat registr–

         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Lineal   ENDP

; -----------------------------------------------------------------------------
;        vymaz n¡ podkladu kl vesnice
; -----------------------------------------------------------------------------

PodkKlav PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      di

; ------ plocha k zobrazen¡ kl vesnice

         mov       di,TOPKLAV               ; za‡ tek pole k zobrazen¡ kl vesnice
         mov       bx,LINKLAV               ; po‡et linek na kl vesnici
         mov       ah,14                    ; barva podkladu kl vesnice
         mov       cx,80                    ; ¨¡©ka kl vesnice
         call      DispBox                  ; plocha k zobrazen¡ kl vesnice

; ------ n vrat registr–

         pop       di
         pop       cx
         pop       bx
         pop       ax
         ret

PodkKlav ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ kl vesnice
; -----------------------------------------------------------------------------

DispKlav PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ p©¡prava k zobrazen¡ kl vesnice

         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       si,ds:[AdrKlavR]         ; definice rozm¡stˆn¡ kl ves

; ------ zobrazen¡ ©ady "E"

         mov       di,TOPKEY                ; po‡ tek k zobrazen¡ kl ves
         mov       bl,13                    ; po‡et bˆ‘n˜ch kl ves k zobrazen¡
         call      DispKRd4                 ; zobrazen¡ ©ady kl ves

; ------ zobrazen¡ kl vesy Back Space

         mov       cl,2*SIRKEY              ; ¨¡©ka kl vesy BS
         mov       ax,offset KlavBS         ; text kl vesy BS
         call      DispCKey                 ; zobrazen¡ kl vesy BS

; ------ zobrazen¡ kl vesy TAB

         mov       cl,SIRKEY + INCKEY       ; ¨¡©ka kl vesy TAB
         mov       di,TOPKEY + RADKEY       ; adresa k zobrazen¡ kl vesy TAB
         mov       ax,offset KlavTab        ; text kl vesy TAB - 1. ‡ st
         call      DispCKey                 ; zobrazen¡ kl vesy TAB

         push      si
         push      di
         mov       si,offset KlavTab0       ; text kl vesy TAB - 2. ‡ st
         add       di,12*80 - 4*80 - 3      ; posun k zobrazen¡ 2. ‡ sti TAB
;         mov       ah,0
         call      DispTxt                  ; zobrazen¡ 2. ‡ sti TAB
         pop       di
         pop       si

; ------ zobrazen¡ ©ady "D"

         mov       bx,10*256 + 2
         call      DispKRad                 ; zobrazen¡ kl ves

; ------ zobrazen¡ kl vesy ENTER

         push      si

         call      DispEnt                  ; zobrazen¡ kl vesy ENTER
         mov       di,TOPKEY + 2*RADKEY + 11*80 + 1 + SIRKEY+2*INCKEY + 11*SIRKEY
         mov       si,offset KlavEnt        ; text kl vesy ENTER
;         mov       ah,0                     ; barva
         call      DispTxt                  ; zobrazen¡ textu kl vesy ENTER

         pop       si

; ------ zobrazen¡ kl vesy CAPS LOCK

         mov       cl,SIRKEY + 2*INCKEY     ; ¨¡©ka kl vesy CAPS LOCK
         mov       di,TOPKEY + 2*RADKEY
         mov       ax,offset KlavCaps       ; adresa textu kl vesy CAPS LOCK
         call      DispCKey                 ; zobrazen¡ kl vesy CAPS LOCK

; ------ zobrazen¡ ©ady "C"

         mov       bx,9*256 + 2
         call      DispKRad

; ------ v˜stupek na kl vese "F"

         mov       di,TOPKEY + 2*RADKEY + SIRKEY+2*INCKEY + 3*SIRKEY + 2 + 16*80
         mov       al,"_"
         mov       ah,0
         call      DispChr

; ------ v˜stupek na kl vese "J"

         mov       di,TOPKEY + 2*RADKEY + SIRKEY+2*INCKEY + 6*SIRKEY + 2 + 16*80
         call      DispChr

; ------ zobrazen¡ kl vesy L-SHIFT

         mov       di,TOPKEY + 3*RADKEY
         mov       cl,SIRKEY + 3*INCKEY
         mov       ax,offset KlavShft
         call      DispCKey

; ------ zobrazen¡ ©ady "B"

         mov       bx,7*256 + 3
         call      DispKRad

; ------ zobrazen¡ kl vesy R-SHIFT

         mov       cl,15*SIRKEY - 10*SIRKEY - (SIRKEY+3*INCKEY)
         mov       ax,offset KlavShft
         call      DispCKey

; ------ zobrazen¡ kl vesy L-CTRL

         mov       di,TOPKEY + 4*RADKEY
         mov       cl,SIRKEY + INCKEY
         mov       ax,offset KlavCtrl
         call      DispCKey

; ------ zobrazen¡ kl vesy L-ALT

         add       di,3*INCKEY              ; mezera mezi ALT- a CTRL-
         mov       ax,offset KlavAlt        ; text kl vesy ALT-
         call      DispCKey                 ; zobrazen¡ kl vesy ALT-

; ------ zobrazen¡ ©ady "A"

         mov       ah,15                    ; barva kl vesy mezern¡ku
         mov       cl,15*SIRKEY - 4*(SIRKEY+INCKEY) - 2*3*INCKEY ; d‚lka mezern¡ku
         call      DispKey                  ; zobrazen¡ mezern¡ku

; ------ zobrazen¡ kl vesy R-ALT

         add       di,cx                    ; p©esko‡en¡ obr zku mezern¡ku
         mov       cl,SIRKEY + INCKEY       ; ¨¡©ka kl vesy ALT-
         mov       ax,offset KlavAlt        ; text kl vesy ALT-
         call      DispCKey                 ; zobrazen¡ kl vesy ALT-

; ------ zobrazen¡ kl vesy R-CTRL

         add       di,3*INCKEY              ; mezera mezi ALT- a CTRL-
         mov       ax,offset KlavCtrl       ; text kl vesy CTRL-
         call      DispCKey                 ; zobrazen¡ kl vesy CTRL-

; ------ n vrat registr–

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispKlav ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ©¡dic¡ kl vesy (adresa DI, d‚lka CL, text AX)
; -----------------------------------------------------------------------------

DispCKey PROC      NEAR

         push      si
         push      di
         xchg      ax,si                    ; SI <- adresa textu

         mov       ah,7
         call      DispKey                  ; kl vesa L-SHIFT
         add       di,12*80 + 1
;         mov       ah,0
         call      DispTxt

         pop       di
         pop       si
         add       di,cx                    ; posun adresy kl vesy
         ret

DispCKey ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ BH kl ves s popisem 1 znak a BL kl ves s popisem 2 znaky
; -----------------------------------------------------------------------------

DispKRad PROC      NEAR

DispKRd2:mov       ah,15                    ; barva kl ves - b¡l 
         mov       cl,SIRKEY                ; ¨¡©ka kl ves
         call      DispKey                  ; zobrazen¡ jedn‚ kl vesy
         call      Disp1Znk                 ; zobrazen¡ popisu kl vesy
         dec       bh                       ; ‡¡ta‡ kl ves
         jnz       DispKRd2                 ; zobrazen¡ dal¨¡ kl vesy

DispKRd4:mov       ah,15
         mov       cl,SIRKEY
         call      DispKey
         call      Disp2Znk
         dec       bl
         jnz       DispKRd4
         ret

DispKRad ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ popisu kl vesy 2 znaky (AH barva, SI=definice, DI=adresa)
; -----------------------------------------------------------------------------

Disp2Znk PROC      NEAR

         call      SetFNT08                 ; nastaven¡ font– 8 linek
         push      di
         add       di,16*80+2               ; posun na spodn¡ znak
         call      DispXZnk                 ; zobrazen¡ znaku DS:SI
         sub       di,10*80                 ; posun na horn¡ znak
         call      DispXZnk                 ; zobrazen¡ znaku DS:SI
         pop       di
         add       di,SIRKEY                ; posun adresy na dal¨¡ kl vesu
         ret

Disp2Znk ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ popisu kl vesy 1 znak (AH barva, SI=definice, DI=adresa)
; -----------------------------------------------------------------------------

Disp1Znk PROC      NEAR

         call      SetFNT16                 ; nastaven¡ fontu 16 linek
         push      di
         add       di,7*80+2                ; posun na st©ed kl vesy
         call      DispXZnk                 ; zobrazen¡ znaku DS:SI
         pop       di
         add       di,SIRKEY                ; posun adresy na dal¨¡ kl vesu
         ret

Disp1Znk ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku kl vesy DS:SI
; -----------------------------------------------------------------------------

DispXZnk PROC      NEAR

; ------ na‡ten¡ znaku k zobrazen¡

         cld
         lodsb

; ------ vyj¡me‡n‚ z kazy pro kl vesnici T602

         cmp       word ptr ds:[AktLekce],0
         je        DispXZn2
         cmp       si,offset KlavZak1
         je        DispXZn3                 ; znak ~ vlevo naho©e
         cmp       si,offset KlavZak2
         je        DispXZn3                 ; znak ' vpravo dole

; ------ ur‡en¡ barvy znaku

DispXZn2:mov       ah,12                    ; barva (kl vesa povolena)
         call      TestKlav                 ; test, zda je kl vesa AL povolen 
         je        DispXZn4                 ; kl vesa je povolen 
DispXZn3:mov       ah,10                    ; barva (kl vesa nepovolena)

; ------ zobrazen¡ znaku

DispXZn4:call      DispChr
         ret

DispXZnk ENDP

; -----------------------------------------------------------------------------
;        test, zda je kl vesa AL povolen 
; -----------------------------------------------------------------------------

TestKlav PROC      NEAR

         push      cx
         push      si

         mov       si,ds:[AdrHghK]          ; adresa definice kl ves
         mov       cx,ds:[AktLekce]
         jcxz      TestKlv4

TestKlv2:inc       si
         cmp       byte ptr ds:[si-1],0
         jne       TestKlv2
         loop      TestKlv2

TestKlv4:cmp       byte ptr ds:[si],0
         je        TestKlv5
         cmp       byte ptr ds:[si],-1
         je        TestKlv6
         cmp       byte ptr ds:[si],al
         je        TestKlv6
         inc       si
         jmp       short TestKlv4

TestKlv5:or        al,al

TestKlv6:pop       si
         pop       cx
         ret

TestKlav ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ kl vesy ENTER (adresa DI)
; -----------------------------------------------------------------------------

DispEnt  PROC      NEAR

; ------ horn¡ ‡ st kl vesy ENTER

         mov       ah,7                     ; barva - ¨ed 
         mov       cl,15*SIRKEY - 12*SIRKEY - (SIRKEY+INCKEY)
         call      DispKey                  ; zobrazen¡ horn¡ ‡ sti ENTER

; ------ spodn¡ ‡ st kl vesy ENTER

         push      di
         add       di,VYSKEY*80 - (SIRKEY-INCKEY)
         mov       cl,15*SIRKEY - 11*SIRKEY - (SIRKEY+2*INCKEY)
         call      DispKey                  ; zobrazen¡ spodn¡ ‡ sti ENTER
         pop       di

; ------ spojen¡ horn¡ a spodn¡ ‡ sti kl vesy

         add       di,(VYSKEY-4)*80

         push      di
         mov       al,"·"                   ; prav˜ horn¡ roh
         call      DispChr0
         mov       al,"Û"                   ; v˜pl¤
         mov       cx,15*SIRKEY - 12*SIRKEY - (SIRKEY+INCKEY) - 2
DispEnt2:call      DispChr0
         loop      DispEnt2
         mov       al,"Ý"                   ; prav˜ okraj
         call      DispChr0
         dec       di

         mov       ah,0
         mov       al,"¶"
         call      DispChr0
         pop       di
         mov       al,"µ"
         call      DispChr0
         ret

DispEnt  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ bˆ‘n‚ kl vesy (barva AH, adresa DI, ¨¡©ka CL -> CH=0)
; -----------------------------------------------------------------------------

DispKey  PROC      NEAR

; ------ £schova registr–

         mov       ch,0
         push      bx
         push      cx

         push      ax
         push      di

; ------ p©¡prava k zobrazen¡ kl vesy

         dec       cx
         dec       cx                       ; vnit©n¡ ¨¡©ka kl vesy
         mov       ah,0                     ; barva ‡ern 
         call      SetFNT08                 ; nastaven¡ fontu 8 linek

; ------ zobrazen¡ horn¡ho okraje (obrys)

         push      cx
         push      di

         mov       al,"Ú"                   ; lev˜ horn¡ roh
         call      DispChr0
         mov       al,"Ñ"
DispKey1:call      DispChr0                 ; horn¡ okraj
         loop      DispKey1                 ; dal¨¡ znak horn¡ho okraje
         mov       al,"¿"
         call      DispChr0                 ; prav˜ horn¡ roh

         pop       di
         pop       cx
         add       di,8*80                  ; zv˜¨en¡ ukl dac¡ adresy

; ------ zobrazen¡ st©edn¡ch © dk– (obrys)

         mov       bx,2                     ; po‡et © dk– k zobrazen¡
DispKey2:push      di
         mov       al,"Ç"                   ; lev  hrana
         call      DispChr0
         add       di,cx
         mov       al,"¶"                   ; prav  hrana
         call      DispChr0
         pop       di
         add       di,7*80                  ; zv˜¨en¡ ukl dac¡ adresy
         dec       bx
         jnz       DispKey2                 ; dal¨¡ © dek

; ------ zobrazen¡ spodn¡ho okraje (obrys)

         mov       al,"À"                   ; lev˜ doln¡ roh
         call      DispChr0
         mov       al,"Ï"                   ; spodn¡ okraj
         push      cx
DispKey3:call      DispChr0
         loop      DispKey3
         pop       cx
         mov       al,"Ù"
         call      DispChr0                 ; prav˜ doln¡ roh

; ------ n vrat adresy kl vesy a barvy podkladu

         pop       di                       ; adresa kl vesy
         pop       ax                       ; barva v˜plnˆ
         push      ax
         push      di

; ------ zobrazen¡ horn¡ho okraje (v˜pl¤)

         push      cx
         push      di

         mov       al,"Õ"                   ; lev˜ horn¡ roh
         call      DispChr0
         mov       al,"Ü"                   ; horn¡ okraj
DispKey4:call      DispChr0
         loop      DispKey4
         mov       al,"¸"                   ; prav˜ horn¡ roh
         call      DispChr0

         pop       di
         pop       cx
         add       di,8*80                  ; zv˜¨en¡ ukl dac¡ adresy

; ------ zobrazen¡ st©edn¡ch © dk– (v˜pl¤)

         mov       bl,2                     ; po‡et © dk–
DispKey5:push      di
         push      cx

         mov       al,"Þ"                   ; lev˜ okraj
         call      DispChr0
         mov       al,"Û"                   ; st©edn¡ v˜pl¤
DispKey6:call      DispChr0
         loop      DispKey6
         mov       al,"Ý"                   ; prav˜ okraj
         call      DispChr0

         pop       cx
         pop       di
         add       di,7*80                  ; zv˜¨en¡ ukl dac¡ adresy
         dec       bx
         jnz       DispKey5                 ; dal¨¡ © dek

; ------ zobrazen¡ spodn¡ho okraje (v˜pl¤)

         mov       al,"Ô"                   ; lev˜ doln¡ roh
         call      DispChr0
         mov       al,"ß"                   ; doln¡ okraj
DispKey7:call      DispChr0
         loop      DispKey7
         mov       al,"¾"                   ; prav˜ doln¡ roh
         call      DispChr0

; ------ n vrat registr–

         pop       di
         pop       ax

         pop       cx
         pop       bx
         ret

DispKey  ENDP

; -----------------------------------------------------------------------------
;        vymaz n¡ kurzoru v textu
; -----------------------------------------------------------------------------

MazKurz  PROC      NEAR

         push      ax
         push      di

         call      SetFNT08                 ; nastaven¡ fontu 8 linek
         mov       di,ENDTEXT + LFTTEXT - 8*80 - 1 ; po‡ te‡n¡ pozice © dku
         add       di,ds:[PozTxt]           ; aktu ln¡ pozice
         mov       al,21                    ; znak kurzoru - lev˜
         mov       ah,15                    ; barva podkladu
         call      DispChr0                 ; zobrazen¡ znaku
         mov       al,22                    ; znak kurzoru - st©edn¡
         call      DispChr0
         mov       al,23                    ; znak kurzoru - prav˜
         call      DispChr

         pop       di
         pop       ax
         ret

MazKurz  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ kurzoru v textu
; -----------------------------------------------------------------------------

DispKurz PROC      NEAR

         push      ax
         push      di

         call      SetFNT08                 ; nastaven¡ fontu 8 linek
         mov       di,ENDTEXT + LFTTEXT - 8*80 - 1 ; po‡ te‡n¡ pozice © dku
         add       di,ds:[PozTxt]           ; aktu ln¡ pozice
         mov       al,21                    ; znak kurzoru - lev˜
         mov       ah,6                     ; barva kurzoru
         call      DispChr0                 ; zobrazen¡ znaku
         mov       al,22                    ; znak kurzoru - st©edn¡
         call      DispChr0
         mov       al,23                    ; znak kurzoru - prav˜
         call      DispChr

         pop       di
         pop       ax
         ret

DispKurz ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ‡¡sla DWORD na pap¡r
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=‡¡slo k zobrazen¡
;        BH=barva textu
;        DS=datov˜ segment
; -----------------------------------------------------------------------------

DispTNum PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si
         push      bp

; ------ p©¡prava registr–

         mov       bp,10                    ; dˆlitel
         xchg      ax,si                    ; SI <- £schova ‡¡sla LOW
         xor       cx,cx                    ; ‡¡ta‡ ‡¡slic

; ------ vydˆlen¡ vy¨¨¡ho slova

DispTNm1:xor       ax,ax                    ; AX <- 0
         xchg      ax,dx                    ; DX <- 0, AX <- ‡¡slo HIGH
         div       bp                       ; vydˆlen¡ ‡¡sla HIGH

; ------ vydˆlen¡ ni‘¨¡ho slova

         xchg      ax,si                    ; AX <- star‚ LOW, SI <- nov‚ HIGH
         div       bp                       ; vydˆlen¡ ‡¡sla LOW
         xchg      ax,si                    ; SI <- nov‚ LOW, AX <- nov‚ HIGH
         xchg      ax,dx                    ; AX <- zbytek, DX <- nov‚ HIGH

; ------ zobrazen¡ ‡¡slice

         add       al,"0"                   ; p©evod na znak ASCII
         mov       ah,bh                    ; barva textu
         push      ax                       ; £schova znaku do z sobn¡ku
         inc       cx

; ------ test, zda je ji‘ konec ‡¡sla

         mov       ax,si                    ; ‡¡slo LOW
         or        ax,dx                    ; je ‡¡slo ji‘ 0 ?
         jnz       DispTNm1                 ; zobrazen¡ dal¨¡ho ‡¡sla

; ------ zobrazen¡ ‡¡sla

DispTNm2:pop       ax
         call      DispChT
         loop      DispTNm2

; ------ n vrat registr–

         pop       bp
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DispTNum ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku AL na pap¡r (barva AH, kurzor mus¡ b˜t vypnut˜)
;           - nezvy¨uje pozici a neukl d  do bufferu
; -----------------------------------------------------------------------------

DispChT0 PROC      NEAR

         cmp       byte ptr ds:[PozTxt],SIRTEXT ; je ji‘ doraz ?
         jae       DispChT4                 ; je ji‘ doraz

         push      di
         call      SetFNT16                 ; nastaven¡ fontu 16 linek
         mov       di,ds:[PozTxt]           ; aktu ln¡ pozice
         add       di,ENDTEXT-FONTEXT*80 + LFTTEXT - LINKURZ*80 ; pozice ve VRAM
         call      DispChr                  ; zobrazen¡ znaku
         pop       di
DispChT4:ret

DispChT0 ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku AL na pap¡r (barva AH, kurzor mus¡ b˜t vypnut˜)
; -----------------------------------------------------------------------------

DispChT  PROC      NEAR

         cmp       byte ptr ds:[PozTxt],SIRTEXT ; je ji‘ doraz ?
         jae       DispChT2                 ; je ji‘ doraz

         push      di
         call      SetFNT16                 ; nastaven¡ fontu 16 linek
         mov       di,ds:[PozTxt]           ; aktu ln¡ pozice
         mov       ds:[LinBuff+di],al       ; ulo‘en¡ znaku do bufferu
         add       di,ENDTEXT-FONTEXT*80 + LFTTEXT - LINKURZ*80 ; pozice ve VRAM
         call      DispChr                  ; zobrazen¡ znaku
         inc       byte ptr ds:[PozTxt]     ; zv˜¨en¡ ukazatele pozice
         pop       di
DispChT2:ret

DispChT  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ textu ES:SI na pap¡r (CY=p©eru¨en¡ v˜stupu)
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=text k zobrazen¡
; VSTUP: ES:SI=nov˜ ukazatel textu
; -----------------------------------------------------------------------------
; Struktura textu: EOT (0)   = konec textu
;                  LF (10)   = konec © dku, p©echod na dal¨¡ © dek
;                  FF (12)   = nov  str nka, ‡ek  se na kl vesu
;                  TSWCBOLD (4)  = zv˜raznˆn‚ p¡smo (‡erven‚) (zap i vyp)
;                  TSWCKEYS (3)  = kl vesy na kl vesnici (zap i vyp)
;                  TSWCNADP (2)  = nadpis (zelen˜) (zap i vyp)
;                  TSWCNAD2 (1)  = nadpis 2 (modr˜) (zap i vyp)
; pou‘it¡ p©¡znak– v BL:  bit 0: 1=zv˜raznˆn¡
;                         bit 1: 1=kl vesa na kl vesnici
;                         bit 2: 1=nadpis 1 (zelen˜)
;                         bit 3: 1=nadpis 2 (modr˜)
; -----------------------------------------------------------------------------

DispTTxt PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx

; ------ na‡ten¡ znaku textu

         xor       cx,cx                    ; ukazatel ‡¡sla str nky
         mov       dx,si                    ; DX <- £schova adresy za‡ tku textu
DispTTx1:mov       bl,0                     ; atributy pro nov˜ © dek
         mov       ah,ds:[TColNorm]         ; inicializa‡n¡ norm ln¡ barva
DispTTx2:mov       al,es:[si]               ; znak k zobrazen¡
         inc       si                       ; zv˜¨en¡ ukazatele textu

; ------ konec © dku LF

         cmp       al,LF                    ; je konec © dku ?
         jne       DispTTx3                 ; nen¡ konec © dku
         call      RollText                 ; rolov n¡ textu
         jmp       short DispTTx1           ; zobrazen¡ dal¨¡ho © dku

; ------ konec textu EOT

DispTTx3:cmp       al,EOT
         je        DispTTx9                 ; konec textu NULL

; ------ nov  str nka FF - ‡ek n¡ na stisk kl vesy

         cmp       al,FF
         jne       DispTTx4
         inc       cx                       ; zv˜¨en¡ ‡¡sla na dal¨¡ str nku
         call      InpKey                   ; vstup znaku z kl vesnice
         jc        DispTTx9                 ; p©eru¨en¡ operace
         cmp       ax,4900h                 ; PageUp ?
         jne       DispTT37                 ; nen¡ PageUp
         dec       cx                       ; n vrat ‡¡sla aktivn¡ str nky
         stc
         jcxz      DispTTx9                 ; je jako p©eru¨en¡ ESC

; ------ nalezen¡ p©ede¨l‚ str nky

         dec       cx                       ; sn¡‘en¡ ukazatele ‡¡sla str nky
         mov       si,dx                    ; SI <- n vrat za‡ tku textu
         jcxz      DispTT37                 ; m  b˜t prvn¡ str nka

         push      cx
DispTT32:mov       al,es:[si]               ; na‡ten¡ znaku
         inc       si                       ; zv˜¨en¡ ukazatele textu
         cmp       al,FF                    ; je nov  str nka ?
         jne       DispTT32                 ; nalezen¡ nov‚ str nky
         loop      DispTT32                 ; nalezen¡ po‘adovan‚ str nky
         pop       cx

DispTT37:call      NovyPap                  ; nov˜ pap¡r
         jmp       short DispTTx1

; ------ zmˆna barvy AH (aktu ln¡ atributy BL)

DispTTx4:call      DispXAtr                 ; zmˆna atribut–
         jnc       DispTTx2                 ; byl to atribut barvy

; ------ zobrazen¡ znaku

DispTTx8:call      DispChT                  ; zobrazen¡ znaku
         jmp       short DispTTx2           ; dal¨¡ bajt textu

; ------ n vrat registr–

DispTTx9:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispTTxt ENDP

; -----------------------------------------------------------------------------
;        zmˆna atribut– barvy AH podle AL (stav p©ep¡na‡– BL) -> CY=nen¡ atribut
; -----------------------------------------------------------------------------

DispXAtr PROC      NEAR

; ------ zmˆna font–

         cmp       al,TSWCFONT              ; je zmˆna fontu ?
         jne       DispXAt2                 ; nen¡ zmˆna fontu
         cmp       word ptr ds:[LinFont],10 ; je 16 nebo 8 linek ?
         jb        DispXAt1                 ; je 8 linek
         call      SetFnt08                 ; nastaven¡ fontu 8 linek
         jmp       short DispXAt8

DispXAt1:call      SetFnt16                 ; nastaven¡ fontu 16 linek
         jmp       short DispXAt8

; ------ zv˜raznˆn‚ p¡smo

DispXAt2:cmp       al,TSWCBOLD
         jne       DispXAt4
         xor       bl,bit0                  ; zmˆna p©¡znaku
         jmp       short DispXAt8

; ------ kl vesy na kl vesnici

DispXAt4:cmp       al,TSWCKEYS
         jne       DispXAt5
         xor       bl,bit1                  ; zmˆna p©¡znaku
         jmp       short DispXAt8

; ------ podklad (‘lut )

DispXAt5:cmp       al,TSWCPODK
         jne       DispXAt6
         xor       bl,bit4                  ; zmˆna p©¡znaku
         jmp       short DispXAt8

; ------ nadpis 1

DispXAt6:cmp       al,TSWCNADP
         jne       DispXAt7
         xor       bl,bit2                  ; zmˆna p©¡znaku
         jmp       short DispXAt8

; ------ nadpis 2

DispXAt7:cmp       al,TSWCNAD2
         stc                                ; p©¡znak, ‘e nen¡ atribut barvy
         jne       DispXAt9                 ; nen¡ atribut barvy
         xor       bl,bit3                  ; zmˆna p©¡znaku

; ------ nastaven¡ barvy

DispXAt8:mov       ah,ds:[TColNorm]         ; norm ln¡ barva
         test      bl,bit0+bit1+bit2+bit3+bit4 ;je norm ln¡ barva ?
         jz        DispXAt9                 ; je norm ln¡ barva

         mov       ah,ds:[TColBold]         ; zv˜raznˆn‚ p¡smo
         test      bl,bit0                  ; zv˜raznˆn¡ ?
         jnz       DispXAt9                 ; je zv˜raznˆn¡

         mov       ah,ds:[TColKeys]         ; kl vesy na kl vesnici
         test      bl,bit1                  ; kl vesy na kl vesnici ?
         jnz       DispXAt9                 ; je modr  barva

         mov       ah,ds:[TColNadp]         ; nadpis
         test      bl,bit2                  ; je nadpis 1 ?
         jnz       DispXAt9                 ; je nadpis 1

         mov       ah,ds:[TColPod2]         ; podklad 2
         test      bl,bit4                  ; je podklad 2 ?
         jnz       DispXAt9                 ; je podklad 2

         mov       ah,ds:[TColNad2]         ; jinak nadpis 2
DispXAt9:ret

DispXAtr ENDP

; -----------------------------------------------------------------------------
;        rolov n¡ textu o © dek
; -----------------------------------------------------------------------------

RollText PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ test, zda je displej Hercules

         mov       es,ds:[SegmVRAM]         ; ES <- segment videopamˆti
         cmp       byte ptr ds:[Hercules],0 ; je karta Hercules ?
         jne       RollTxt3                 ; je karta Hercules

; ------ nastaven¡ z pisov‚ho m¢du

         cli
         mov       dx,3ceh
         mov       al,5
         out       dx,al                    ; volba registru z pisov‚ho m¢du
         mov       al,1
         inc       dx
         out       dx,al                    ; nastaven¡ m¢du sp©a‘en˜ch rovin

; ------ rolov n¡ obrazovky

         push      ds
         xor       di,di                    ; DI <- 0
         mov       si,ds:[IncRoll]          ; adresa druh‚ho © dku
         mov       cx,RADTEXT*FONTEXT*80    ; d‚lka dat k rotaci
         sub       cx,ds:[IncRoll]          ; ode‡ten¡ v˜¨ky © dku
         cld
         push      es
         pop       ds                       ; DS <- segment videopamˆti
         rep       movsb                    ; rolov n¡ obrazovky
         pop       ds

; ------ n vrat bˆ‘n‚ho z pisov‚ho m¢du

         mov       al,0
         out       dx,al                    ; n vrat z pisov‚ho m¢du
         sti
         jmp       short RollTxt8

; ------ p©¡prava k rolov n¡ okna

RollTxt3:xor       di,di
         mov       si,ds:[IncRoll]
         shr       si,1
         shr       si,1
         mov       cx,RADTEXT*FONTEXT*80/4  ; d‚lka dat k rotaci
         sub       cx,si
         shr       cx,1

; ------ rolov n¡ obrazovky

         push      ds
         push      es
         pop       ds

RollTxt4:push      si
         push      di
         push      cx

         cld
         rep       movsw

         pop       cx
         pop       di
         pop       si

         add       di,2000h
         add       si,2000h
         jns       RollTxt4

         pop       ds

; ------ vymaz n¡ novˆ vytvo©en‚ho © dku

RollTxt8:mov       di,ENDTEXT+LFTPAPIR - LINKURZ*80 ; po‡. k zobr.textu
         sub       di,ds:[IncRoll]          ; ode‡ten¡ v˜¨ky © dku
         mov       ah,15                    ; barva
         mov       cx,SIRPAPIR              ; ¨¡©ka obd‚ln¡ku
         mov       bx,ds:[LinRoll]          ; v˜¨ka obd‚ln¡ku
         call      DispBox                  ; vymaz n¡ obd‚ln¡ku textu
         mov       byte ptr ds:[PozTxt],0   ; pozice ukazatele na za‡ tek © dku

; ------ n vrat registr–

RollTxt9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

RollText ENDP

; *****************************************************************************
;
;                   Univerz ln¡ obsluha displeje
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        zapnut¡ fontu 8 linek
; -----------------------------------------------------------------------------

SetFNT08 PROC      NEAR

         mov       word ptr ds:[AdrFont],offset Font08 ; adresa fontu
         mov       word ptr ds:[LinFont],8 ; po‡et linek na font
         mov       word ptr ds:[RadFont],8*80 ; p©¡rustek adresy ve VRAM
         ret

SetFNT08 ENDP

; -----------------------------------------------------------------------------
;        zapnut¡ fontu 16 linek
; -----------------------------------------------------------------------------

SetFNT16 PROC      NEAR

         mov       word ptr ds:[AdrFont],offset Font16 ; adresa fontu
         mov       word ptr ds:[LinFont],16 ; po‡et linek na font
         mov       word ptr ds:[RadFont],16*80 ; p©¡rustek adresy ve VRAM
         ret

SetFNT16 ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ‡¡sla DWORD se zarovn n¡m vlevo
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=‡¡slo k zobrazen¡
;        BH=barva textu
;        DI=offset ve videopamˆti po‡ tku
;        DS=datov˜ segment
; -----------------------------------------------------------------------------

DispLNum PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si
         push      bp

; ------ p©¡prava registr–

         mov       bp,10                    ; dˆlitel
         xchg      ax,si                    ; SI <- £schova ‡¡sla LOW
         xor       cx,cx                    ; ‡¡ta‡ ‡¡slic

; ------ vydˆlen¡ vy¨¨¡ho slova

DispLNm1:xor       ax,ax                    ; AX <- 0
         xchg      ax,dx                    ; DX <- 0, AX <- ‡¡slo HIGH
         div       bp                       ; vydˆlen¡ ‡¡sla HIGH

; ------ vydˆlen¡ ni‘¨¡ho slova

         xchg      ax,si                    ; AX <- star‚ LOW, SI <- nov‚ HIGH
         div       bp                       ; vydˆlen¡ ‡¡sla LOW
         xchg      ax,si                    ; SI <- nov‚ LOW, AX <- nov‚ HIGH
         xchg      ax,dx                    ; AX <- zbytek, DX <- nov‚ HIGH

; ------ zobrazen¡ ‡¡slice

         add       al,"0"                   ; p©evod na znak ASCII
         mov       ah,bh                    ; barva textu
         push      ax                       ; £schova znaku do z sobn¡ku
         inc       cx

; ------ test, zda je ji‘ konec ‡¡sla

         mov       ax,si                    ; ‡¡slo LOW
         or        ax,dx                    ; je ‡¡slo ji‘ 0 ?
         jnz       DispLNm1                 ; zobrazen¡ dal¨¡ho ‡¡sla

; ------ zobrazen¡ ‡¡sla

DispLNm2:pop       ax
         call      DispChr0
         loop      DispLNm2

; ------ n vrat registr–

         pop       bp
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DispLNum ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ‡¡sla DWORD
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=‡¡slo k zobrazen¡
;        BH=barva textu
;        DI=offset ve videopamˆti posledn¡ ‡¡slice
;        DS=datov˜ segment
; -----------------------------------------------------------------------------

DispNum  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si
         push      di

; ------ p©¡prava registr–

         mov       cx,10                    ; dˆlitel
         xchg      ax,si                    ; SI <- £schova ‡¡sla LOW

; ------ vydˆlen¡ vy¨¨¡ho slova

DispNum1:xor       ax,ax                    ; AX <- 0
         xchg      ax,dx                    ; DX <- 0, AX <- ‡¡slo HIGH
         div       cx                       ; vydˆlen¡ ‡¡sla HIGH

; ------ vydˆlen¡ ni‘¨¡ho slova

         xchg      ax,si                    ; AX <- star‚ LOW, SI <- nov‚ HIGH
         div       cx                       ; vydˆlen¡ ‡¡sla LOW
         xchg      ax,si                    ; SI <- nov‚ LOW, AX <- nov‚ HIGH
         xchg      ax,dx                    ; AX <- zbytek, DX <- nov‚ HIGH

; ------ zobrazen¡ ‡¡slice

         add       al,"0"                   ; p©evod na znak ASCII
         mov       ah,bh                    ; barva textu
         call      DispChr                  ; zobrazen¡ ‡¡slice
         dec       di                       ; posun ukazatele

; ------ test, zda je ji‘ konec ‡¡sla

         mov       ax,si                    ; ‡¡slo LOW
         or        ax,dx                    ; je ‡¡slo ji‘ 0 ?
         jnz       DispNum1                 ; zobrazen¡ dal¨¡ho ‡¡sla

; ------ n vrat registr–

         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DispNum  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ ‡¡sla DWORD do bufferu (zarovn n¡ doleva)
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=‡¡slo k dek¢dov n¡
;        ES:DI=buffer k dek¢dov n¡ ‡¡sla
;        DS=datov˜ segment
; VSTUP: ES:DI=nov  ukl dac¡ adresa
; -----------------------------------------------------------------------------

DekNum   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si
         push      bp

; ------ p©¡prava registr–

         mov       bp,10                    ; dˆlitel
         xchg      ax,si                    ; SI <- £schova ‡¡sla LOW
         xor       cx,cx                    ; ‡¡ta‡ ‡¡slic

; ------ vydˆlen¡ vy¨¨¡ho slova

DekNum1: xor       ax,ax                    ; AX <- 0
         xchg      ax,dx                    ; DX <- 0, AX <- ‡¡slo HIGH
         div       bp                       ; vydˆlen¡ ‡¡sla HIGH

; ------ vydˆlen¡ ni‘¨¡ho slova

         xchg      ax,si                    ; AX <- star‚ LOW, SI <- nov‚ HIGH
         div       bp                       ; vydˆlen¡ ‡¡sla LOW
         xchg      ax,si                    ; SI <- nov‚ LOW, AX <- nov‚ HIGH
         xchg      ax,dx                    ; AX <- zbytek, DX <- nov‚ HIGH

; ------ £schova ‡¡slice

         add       al,"0"                   ; p©evod na znak ASCII
         push      ax                       ; £schova znaku do z sobn¡ku
         inc       cx                       ; zv˜¨en¡ ‡¡ta‡e znak–

; ------ test, zda je ji‘ konec ‡¡sla

         mov       ax,si                    ; ‡¡slo LOW
         or        ax,dx                    ; je ‡¡slo ji‘ 0 ?
         jnz       DekNum1                  ; dek¢dov n¡ dal¨¡ ‡¡slice

; ------ ulo‘en¡ ‡¡sla

         cld
DekNum2: pop       ax
         stosb
         loop      DekNum2

; ------ n vrat registr–

         pop       bp
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DekNum   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ textu
; -----------------------------------------------------------------------------
; VSTUP: CX=max. po‡et © dk– textu k zobrazen¡
;        ES:SI=text k zobrazen¡
;        DI=offset ve videopamˆti EGA/VGA
; VSTUP:SI=adresa n sleduj¡c¡ho textu
;        DI=nov˜ offset ve videopamˆti
; -----------------------------------------------------------------------------
; Struktura textu: 0 (NULL)  = konec textu
;                  10 (LF)   = konec © dku, p©echod na dal¨¡ © dek
;                  13 (CR)   = ignoruje se
;                  "%0" = ‡ern  barva (implicitnˆ)
;                  "%1" = modr  barva
;                  "%2" = zelen  barva
;                  "%3" = modrozelen  barva
;                  "%4" = ‡erven  barva
;                  "%5" = fialov  barva
;                  "%6" = hnˆd  barva
;                  "%7" = b¡l  barva
;                  "%8" = ¨ed  barva
;                  "%9" = svˆtle modr  barva
;                  "%A" = svˆtle zelen  barva
;                  "%B" = svˆtle modrozelen  barva
;                  "%C" = svˆtle ‡erven  barva
;                  "%D" = svˆtle fialov  barva
;                  "%E" = ‘lut  barva
;                  "%F" = svˆtle b¡l  barva
;                  "%^@" a‘ "%^_" = speci ln¡ znak < 32
;                  "%%" = platn˜ znak %
; -----------------------------------------------------------------------------

DispTxt  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx

; ------ na‡ten¡ znaku textu

         mov       ah,0                     ; inicializa‡n¡ barva = 0
DispTxt1:mov       bx,di                    ; £schova za‡ tku © dku
DispTxt2:mov       al,es:[si]               ; znak k zobrazen¡
         inc       si

; ------ znak CR se ignoruje

DispTxt3:cmp       al,13
         je        DispTxt2                 ; znak CR se ignoruje

; ------ konec © dku LF

         cmp       al,LF                    ; je konec © dku ?
         jne       DispTxt4                 ; nen¡ konec © dku
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e © dk–
         jz        DispTxt9                 ; jsou ji‘ v¨echny © dky - konec
         mov       di,bx                    ; n vrat za‡ tku © dku
         add       di,ds:[RadFont]          ; adresa dal¨¡ho © dku
         jmp       short DispTxt1           ; zobrazen¡ dal¨¡ho © dku

; ------ konec textu EOT

DispTxt4:cmp       al,EOT
         je        DispTxt9                 ; konec textu NULL

; ------ test, zda je p©ep¡na‡ "%"

         cmp       al,"%"                   ; je znak p©ep¡na‡e ?
         jne       DispTxt8                 ; nen¡ p©ep¡na‡ - je platn˜ znak

; ------ na‡ten¡ dal¨¡ho znaku

         mov       al,es:[si]               ; dal¨¡ znak k zobrazen¡
         inc       si                       ; zv˜¨en¡ ukazatele textu

; ------ test, zda je platn˜ znak "%"

         cmp       al,"%"
         je        DispTxt8                 ; je platn˜ znak "%"

; ------ test, zda je speci ln¡ znak "%^"

         cmp       al,"^"                   ; je speci ln¡ znak "^" ?
         jne       DispTxt6                 ; nen¡ speci ln¡ znak "^"

; ------ na‡ten¡ dal¨¡ho znaku pro speci ln¡ znak

         mov       al,es:[si]               ; dal¨¡ znak k zobrazen¡
         inc       si                       ; zv˜¨en¡ ukazatele textu

; ------ kontrola, zda je platn˜ speci ln¡ znak

         cmp       al,"@"
         jb        DispTxt3                 ; nen¡ platn˜ znak
         cmp       al,"_"
         ja        DispTxt3                 ; nen¡ platn˜ znak
         sub       al,"@"
         jmp       short DispTxt8           ; zobrazen¡ znaku

; ------ kontrola, zda je p©ep¡na‡ barvy

DispTxt6:cmp       al,"0"
         jb        DispTxt3                 ; nen¡ platn˜ znak
         cmp       al,"9"
         jbe       DispTxt7                 ; je platn˜ znak p©ep¡na‡e barvy
         cmp       al,"A"
         jb        Disptxt3                 ; nen¡ platn˜ znak
         cmp       al,"F"
         ja        DispTxt3                 ; nen¡ platn˜ znak

; ------ zmˆna barvy

         sub       al,7                     ; korekce znaku
DispTxt7:sub       al,"0"
         mov       ah,al                    ; nov  barva textu
         jmp       short DispTxt2           ; dal¨¡ znak

; ------ zobrazen¡ znaku

DispTxt8:call      DispChr0                 ; zobrazen¡ znaku
         jmp       short DispTxt2           ; dal¨¡ bajt textu

; ------ n vrat registr–

DispTxt9:pop       cx
         pop       bx
         pop       ax
         ret

DispTxt  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku z posunem adresy
; -----------------------------------------------------------------------------

DispChr0:call      DispChr
         inc       di
         ret

; -----------------------------------------------------------------------------
;        zobrazen¡ jednoho znaku
; -----------------------------------------------------------------------------
; VSTUP: AL=znak k zobrazen¡
;        AH=barva znaku
;        DI=offset ve videopamˆti EGA/VGA (horn¡ linka)
; -----------------------------------------------------------------------------

DispChr  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      es
         mov       ch,ah                    ; barva

; ------ adresa znaku v tabulce font–

         mul       byte ptr ds:[LinFont]    ; offset znaku ve fontech
         add       ax,ds:[AdrFont]          ; adresa znaku ve fontech
         xchg      ax,si                    ; SI <- adresa znaku
         cld

; ------ rozli¨en¡, zda je karta Hercules

         mov       es,ds:[SegmVRAM]         ; segment videopamˆti
         cmp       byte ptr ds:[Hercules],0 ; je to karta Hercules ?
         je        DispChr5                 ; nen¡ karta Hercules

; ------ p©¡prava k zobrazen¡ znaku Hercules

         call      KorVRAM                  ; korekce adresy pro Hercules
         mov       ah,ch                    ; barva k zobrazen¡ znaku
         mov       cx,ds:[LinFont]          ; po‡et linek znaku

         cmp       ah,14
         jae       DispChr1
         cmp       ah,7
         jne       DispChr3

; ------ zobrazen¡ b¡l‚ barvy

DispChr1:lodsb                              ; bajt znaku
         or        es:[di],al               ; nastaven¡ b¡l‚ barvy
         add       di,2000h                 ; zv˜¨en¡ adresy videopamˆti
         jns       DispChr2                 ; nen¡ p©ete‡en¡ 4 linek
         and       di,7fffh                 ; korekce zpˆt na za‡ tek
         add       di,80                    ; adresa dal¨¡ linky znaku
DispChr2:loop      DispChr1                 ; zobrazen¡ dal¨¡ linky znaku
         jmp       short DispChr9

; ------ zobrazen¡ ostatn¡ch barev (inverznˆ)

DispChr3:lodsb                              ; bajt znaku
         not       al                       ; bude se nulovat
         and       es:[di],al               ; nastaven¡ ‡ern‚ barvy
         add       di,2000h                 ; zv˜¨en¡ adresy videopamˆti
         jns       DispChr4                 ; nen¡ p©ete‡en¡ 4 linek
         and       di,7fffh                 ; korekce zpˆt na za‡ tek
         add       di,80                    ; adresa dal¨¡ linky znaku
DispChr4:loop      DispChr3                 ; zobrazen¡ dal¨¡ linky znaku
         jmp       short DispChr9

; ------ nastaven¡ z pisu do v¨ech rovin

DispChr5:mov       dx,3c4h
         mov       al,2
         out       dx,al                    ; volba registru 2
         inc       dx
         mov       al,0fh                   ; z pis do v¨ech rovin
         out       dx,al                    ; nastaven¡ v¨ech rovin

; ------ nastaven¡ barvy znaku

         mov       dx,3ceh
         mov       al,0                     ; registr 0
         out       dx,al                    ; volba registru 0
         inc       dx
         mov       al,ch                    ; po‘adovan  barva znaku
         out       dx,al                    ; nastaven¡ barvy znaku
         dec       dx

; ------ nastaven¡ volby rovin

         mov       al,1                     ; registr 1
         out       dx,al                    ; volba registru 1
         mov       al,1111b                 ; v¨echny roviny podle registru 0
         inc       dx
         out       dx,al                    ; volba rovin
         dec       dx

; ------ p©ednastaven¡ registru bitov‚ masky

         mov       al,8                     ; registr 8
         out       dx,al                    ; volba registru 8
         inc       dx

; ------ zobrazen¡ znaku

         mov       cx,ds:[LinFont]          ; po‡et linek znaku
DispChr6:lodsb                              ; bajt znaku
         out       dx,al                    ; nastaven¡ masky znaku
         xchg      al,es:[di]               ; z pis znaku
         add       di,80                    ; adresa dal¨¡ linky znaku
         loop      DispChr6                 ; zobrazen¡ dal¨¡ linky znaku

; ------ n vrat videoregistr–

         mov       al,0ffh                  ; maska - v¨echny bity
         out       dx,al                    ; v¨echny bity
         dec       dx
         mov       al,1                     ; registr 1
         out       dx,al                    ; volba registru 1
         mov       al,0                     ; v¨echny roviny podle dat
         inc       dx
         out       dx,al                    ; volba rovin

; ------ n vrat registr–

DispChr9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DispChr  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ obd‚ln¡ku
; -----------------------------------------------------------------------------
; VSTUP: AH=barva obd‚ln¡ku
;        DI=offset ve videopamˆti EGA/VGA
;        BX=po‡et videolinek obd‚ln¡ku
;        CX=¨¡©ka obd‚ln¡ku v bajtech
; -----------------------------------------------------------------------------

DispBox  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      es

; ------ p©¡prava registr– k zobrazen¡

         mov       es,ds:[SegmVRAM]         ; segment videopamˆti
         cld

; ------ korekce adresy ve videopamˆti pro Hercules

         cmp       byte ptr ds:[Hercules],0 ; je Hercules karta ?
         je        DispBox3                 ; nen¡ Hercules karta
         call      KorVRAM                  ; korekce adresy pro Hercules

; ------ korekce barvy pro Hercules

         cmp       ah,8                     ; je to barva pozad¡ ?
         jne       DispBox0                 ; nen¡ barva pozad¡
         mov       ah,0                     ; korekce na barvu pozad¡
DispBox0:cmp       ah,4                     ; je ‡ern  barva ?
         mov       ax,-1                    ; b¡l  barva
         ja        DispBox1                 ; nen¡ ‡ern  barva
         inc       ax                       ; ‡ern  barva

; ------ z pis jedn‚ linky

DispBox1:push      di
         push      cx
         shr       cx,1                     ; po‡et slov k z pisu
         rep       stosw                    ; z pis linky po slovech
         adc       cx,cx                    ; lich˜ bajt
         rep       stosb                    ; z pis lich‚ho bajtu
         pop       cx
         pop       di

; ------ zv˜¨en¡ adresy ve videopamˆti

         add       di,2000h                 ; zv˜¨en¡ adresy
         jns       DispBox2                 ; nen¡ je¨tˆ p©ete‡en¡ 4 linek
         and       di,7fffh                 ; korekce adresy na po‡ tek
         add       di,80                    ; zv˜¨en¡ adresy linky
DispBox2:dec       bx                       ; sn¡‘en¡ ‡¡ta‡e linek
         jnz       DispBox1                 ; z pis dal¨¡ linky
         jmp       short DispBox9

; ------ nastaven¡ z pisu do v¨ech rovin

DispBox3:mov       dx,3c4h
         mov       al,2
         out       dx,al                    ; volba registru 2
         inc       dx
         mov       al,0fh                   ; z pis do v¨ech rovin
         out       dx,al                    ; nastaven¡ v¨ech rovin

; ------ nastaven¡ barvy obd‚ln¡ku (do registru 0)

         mov       dx,3ceh
         mov       al,0                     ; registr 0
         out       dx,al                    ; volba registru 0
         inc       dx
         mov       al,ah                    ; po‘adovan  barva obd‚ln¡ku
         out       dx,al                    ; nastaven¡ barvy obd‚ln¡ku
         dec       dx

; ------ nastaven¡ volby rovin (v¨echny roviny podle registru 0)

         mov       al,1                     ; registr 1
         out       dx,al                    ; volba registru 1
         mov       al,1111b                 ; v¨echny roviny podle registru 0
         inc       dx
         out       dx,al                    ; volba rovin

; ------ zobrazen¡ obd‚ln¡ku

         xor       ax,ax                    ; z pisov˜ bajt (nen¡ d–le‘it˜)
DispBox4:push      di
         push      cx
         shr       cx,1                     ; d‚lka linky ve slovech
         rep       stosw
         adc       cx,cx                    ; lich˜ bajt
         rep       stosb                    ; z pis lich‚ho bajtu
         pop       cx
         pop       di

         add       di,80                    ; zv˜¨en¡ adresy linky
         dec       bx                       ; sn¡‘en¡ ‡¡ta‡e linek
         jnz       DispBox4                 ; z pis dal¨¡ linky

; ------ n vrat registr– (AL=0)

         out       dx,al                    ; v¨echny roviny podle dat
DispBox9:pop       es
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispBox  ENDP

; -----------------------------------------------------------------------------
;        korekce adresy ve videopamˆti DI pro HERCULES
; -----------------------------------------------------------------------------

KorVRAM  PROC      NEAR

         push      bx
         push      dx
         push      ax

         xor       dx,dx                    ; DX <- 0
         xchg      ax,di                    ; AX <- adresa ve videopamˆti
         mov       bx,80                    ; po‡et bajt– na videolinku
         div       bx                       ; AX <- ‡¡slo videolinky
         mov       di,dx                    ; DI <- offset na videolince

         xor       dx,dx                    ; DX <- 0
         mov       bx,4
         div       bx                       ; AX <- ‡¡slo linky / 4, DX <- zbytek

         mov       bx,dx                    ; BX <- ‡¡slo linky 0 a‘ 3
         mov       dx,80                    ; po‡et bajt– na linku
         mul       dx                       ; p©epo‡et na adresu
         add       di,ax                    ; DI <- adresa ve videopamˆti

         mov       ax,bx                    ; AX <- ‡¡slo sekce po 2000h
         mov       dx,2000h                 ; po‡et bajt– na sekci
         mul       dx
         add       di,ax                    ; DI <- adresa sekce

         pop       ax
         pop       dx
         pop       bx
         ret

KorVRAM  ENDP

; -----------------------------------------------------------------------------
;             nastaven¡ paletov˜ch registr– DS:SI
; -----------------------------------------------------------------------------

SetPal   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      dx
         push      si

; ------ pro Hercules se nastaven¡ neprov d¡

         cmp       byte ptr ds:[Hercules],0 ; je karta Hercules ?
         jne       SetPal9                  ; je karta Hercules

; ------ synchronizace n slednosti registr–

         cli                                ; z kaz p©eru¨en¡
         mov       dx,3dah                  ; stavov˜ registr videokarty
         in        al,dx                    ; ‡ten¡ stavov‚ho registru

; ------ volba registru

         cld
         mov       ah,0                     ; ukazatel registr–
         mov       dl,0c0h                  ; port nastaven¡ palet
SetPal3: mov       al,ah                    ; paletov˜ registr
         out       dx,al                    ; volba paletov‚ho registru

; ------ nastaven¡ po‘adovan‚ hodnoty registru

         lodsb                              ; hodnota pro nastaven¡ registru
         out       dx,al                    ; nastaven¡ palety

; ------ p©¡prava pro dal¨¡ registr

         inc       ah                       ; zv˜¨en¡ ukazatele registr–
         cmp       ah,10h                   ; jsou ji‘ v¨echny registry ?
         jb        SetPal3                  ; nastaven¡ dal¨¡ho registru

; ------ p©edefinov n¡ paletov‚ho registru pozad¡

         mov       al,11h                   ; ‡¡slo registru palety pozad¡
         out       dx,al                    ; nastaven¡ ‡¡sla registru
         lodsb                              ; po‘adovan  paleta registru
         out       dx,al                    ; definice palety registru pozad¡

; ------ zapnut¡ videosign lu

         mov       al,20h                   ; hodnota pro rozsv¡cen¡ displeje
         out       dx,al                    ; rozsv¡cen¡ displeje
         sti                                ; p©eru¨en¡ zase povoleno

; ------ n vrat registr–

SetPal9: pop       si
         pop       dx
         pop       ax
         ret

SetPal   ENDP

; *****************************************************************************
;
;                         R–zn‚ procedury
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        z mˆna znaku AL podle tabulky
; -----------------------------------------------------------------------------

KonvXchg PROC      NEAR

         push      si
         mov       si,ds:[AdrXchg]
         dec       si
         dec       si
KonvXch2:inc       si
         inc       si
         cmp       byte ptr ds:[si],0
         je        KonvXch3
         cmp       al,ds:[si]
         jne       KonvXch2
         mov       al,ds:[si+1]
         mov       ah,0
KonvXch3:pop       si
         ret

KonvXchg ENDP

; -----------------------------------------------------------------------------
;        nulov n¡ ‡¡ta‡e metronomu
; -----------------------------------------------------------------------------

NulMetr  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      dx

; ------ ‡asovac¡ konstanta metronomu

         mov       ax,1092                  ; po‡et impuls– za minutu
         xor       dx,dx                    ; DX <- 0
         mov       bx,ds:[MetrSet]          ; po‡et £der– metronomu za minutu
         or        bx,bx                    ; nen¡ n hodou = 0 ?
         jnz       NulMetr1                 ; je to OK, nen¡ 0
         inc       bx                       ; oprava - alespo¤ 1
NulMetr1:div       bx                       ; v˜po‡et ‡asov‚ konstanty
         mov       ds:[Metronom],ax         ; ‡asovac¡ konstanta metronomu
;         xor       ax,ax                    ; AX <- 0
;         div       bx                       ; zbytek * 65K / 1092
;         mov       ds:[MetronoS],ax         ; ‡asovac¡ konstanta - zlomek
;         mov       ds:[NextMetS],ax         ; ‡as p©¡¨t¡ho tiku - zlomek

; ------ ‡as p©¡¨t¡ho tiku metronomu

         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       ax,ds:[46ch]
         mov       dx,ds:[46ch+2]
         pop       ds
         add       ax,ds:[Metronom]         ; ‡as p©¡¨t¡ho tiku
         adc       dx,0
         mov       word ptr ds:[NextMetr],ax ; ‡as p©¡¨t¡ho tiku
         mov       word ptr ds:[NextMetr+2],dx

; ------ n vrat registr–

         pop       dx
         pop       bx
         pop       ax
         ret

NulMetr  ENDP

; -----------------------------------------------------------------------------
;        obsluha metronomu
; -----------------------------------------------------------------------------

LupMetr  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx

; ------ zji¨tˆn¡ aktu ln¡ho ‡asu -> BX:AX

         push      ds
         xor       ax,ax                    ; AX <- 0
         mov       ds,ax                    ; DS <- 0
         mov       ax,ds:[46ch]             ; aktu ln¡ ‡as LOW
         mov       bx,ds:[46ch+2]           ; aktu ln¡ ‡as HIGH
         pop       ds

; ------ p©ete‡en¡ p©es dobu n sleduj¡c¡ho tiku

         push      ax
         push      bx
         sub       ax,word ptr ds:[NextMetr] ; p©ete‡en¡ p©es n sleduj¡c¡ tik
         sbb       bx,word ptr ds:[NextMetr+2]
         pop       bx
         pop       ax
         jnz       LupMetr6                 ; je¨tˆ nen¡ dosa‘en po‘adovan˜ ‡as

; ------ v˜po‡et doby dal¨¡ho tiku metronomu

LupMetr2:;mov       cx,ds:[MetronoS]         ; p©¡rustek metronomu - zlomek
         ;add       ds:[NextMetS],cx         ; p©¡¨t¡ tik metronomu - zlomek
         ;adc       ax,ds:[Metronom]         ; p©¡¨t¡ tik metronomu
         add       ax,ds:[Metronom]
         adc       bx,0

; ------ oprava ‡asu p©i p©ete‡en¡ p©es p–lnoc

         cmp       bx,18h                   ; p©ete‡en¡ p©es 1800B0h
         jne       LupMetr3
         cmp       ax,0b0h
LupMetr3:jb        LupMetr4                 ; nen¡ p©ete‡en¡ p©es p–lnoc
         sub       ax,0b0h
         sbb       bx,18h

; ------ ulo‘en¡ ‡asu p©¡¨t¡ho tiku

LupMetr4:mov       word ptr ds:[NextMetr],ax ; ‡as p©¡¨t¡ho tiku
         mov       word ptr ds:[NextMetr+2],bx

; ------ test, zda je povolen metronom

         cmp       byte ptr ds:[Metron],0   ; je metronom povolen ?
         je        LupMetr6                 ; nen¡ povolen

; ------ lupnut¡ metronomu

         mov       bx,4561
         call      Ton
         mov       cx,4
         call      Cekej
         mov       bx,3620
         call      Ton
         call      Cekej
         mov       bx,4561
         call      Ton
         call      Cekej
         call      TonOff

; ------ n vrat registr–

LupMetr6:pop       cx
         pop       bx
         pop       ax
         ret

LupMetr  ENDP

; -----------------------------------------------------------------------------
;        test znaku z kl vesnice (CY=nen¡)
; -----------------------------------------------------------------------------

TestKey  PROC      NEAR

         push      ax
         mov       ah,1
         int       16h
         clc                                ; p©¡znak - je kl vesa
         jnz       TestKey1                 ; je kl vesa
         stc                                ; p©¡znak - nen¡ kl vesa
TestKey1:pop       ax
         ret

TestKey  ENDP

; -----------------------------------------------------------------------------
;        vstup znaku z kl vesnice (CY=p©eru¨en¡ ESC nebo Ctrl-Break)
; -----------------------------------------------------------------------------

InpKey   PROC      NEAR

         push      si

; ------ vstup znaku z kl vesnice

InpKey1: call      InpKey0

; ------ obsluha kl vesnice IBM

         cmp       byte ptr ds:[AktKlav],3
         je        InpKey10                 ; je kl vesnice IBM

; ------ obsluha program. kl vesnice 1

         cmp       byte ptr ds:[AktKlav],1  ; je program. kl vesnice 1 ?
         jne       InpKey11
InpKey10:mov       si,offset PrefCh1        ; tabulka prefix–
         cmp       al,'`'
         je        InpKey13                 ; je prefixov  kl vesa

; ------ obsluha program. kl vesnice 2

InpKey11:cmp       byte ptr ds:[AktKlav],2  ; je program. kl vesnice 2 ?
         je        InpKey12

; ------ obsluha ‡esk‚ kl vesnice (psac¡ stroj)

         cmp       byte ptr ds:[AktKlav],0  ; je ‡esk  kl vesnice ?
         jne       InpKey2                  ; nen¡ ‡esk  kl vesnice
InpKey12:mov       si,offset PrefChC1       ; prefixov‚ kl vesy - ‡ rka
         or        ah,ah                    ; je to zkonvertovan˜ znak ?
         jnz       InpKey2                  ; nen¡ zkonvertovan˜ znak
         cmp       al,"'"                   ; bude ‡ rka ?
         je        InpKey13                 ; je ‡ rka
         mov       si,offset PrefChC2       ; prefixov‚ kl vesy - h ‡ek
         cmp       al,"~"                   ; bude h ‡ek ?
         jne       InpKey2                  ; nen¡ h ‡ek

; ------ n hrada druh‚ho znaku (po zad n¡ prefixu)

InpKey13:call      LupPref                  ; indikace prefixu
         call      InpKey0                  ; vstup druh‚ho znaku
         cmp       al,8
         je        InpKey1                  ; kl vesa BS - zru¨en¡ znaku
         cmp       ax,5300h
         je        InpKey1                  ; kl vesa Delete - zru¨en¡ znaku
;         cmp       ax,2827h                 ; kl vesa "'"
;         je        InpKey2                  ; nekonvertuje se
InpKey14:cmp       byte ptr ds:[si],0
         je        InpKey2
         inc       si
         inc       si
         cmp       byte ptr ds:[si-2],al
         jne       InpKey14
         mov       al,ds:[si-1]             ; n hradn¡ znak
         mov       ah,0
InpKey2:

; ------ zmˆna p©¡znaku v˜stup zvuku F3

InpKey4: cmp       ax,3d00h
         jne       InpKey5
         xor       byte ptr ds:[Sound],1    ; zmˆna p©¡znaku zvuku

; ------ zmˆna p©¡znaku metronomu F2

InpKey5: cmp       ax,3c00h
         jne       InpKey6
         xor       byte ptr ds:[Metron],1    ; zmˆna p©¡znaku metronomu

; ------ test, zda je p©eru¨en¡ ESC nebo Ctrl-Break

InpKey6: cmp       al,27                    ; je ESC ?
         stc                                ; p©¡znak - je p©eru¨en¡
         je        InpKey9                  ; je ESC
         clc                                ; p©¡znak - nen¡ p©eru¨en¡
InpKey9: pop       si
         ret

InpKey   ENDP

; ------ vstup znaku z kl vesnice

InpKey0: mov       ah,0
         int       16h

; ------ n hrada znaku Ctrl-Break znakem ESC

         or        ax,ax                    ; je Ctrl-Break ?
         jnz       InpKey01                 ; nen¡ Ctrl-Break
         mov       ax,011bh                 ; n hrada znakem ESC

; ------ z mˆna znaku podle tabulky

InpKey01:cmp       ah,37h                   ; je numerick‚ pole ?
         jae       InpKey02                 ; konverze se neprov d¡ (num. pole)
         cmp       ah,0                     ; je ©¡dic¡ kl vesa ?
         je        InpKey02                 ; ©¡dic¡ kl vesa - nen¡ konverze
         call      KonvXchg                 ; z mˆna znaku AL podle tabulky
InpKey02:ret

; -----------------------------------------------------------------------------
;        £der psac¡ho stroje
; -----------------------------------------------------------------------------

LupKey   PROC      NEAR

         cmp       byte ptr ds:[Sound],0
         je        LupKey2                  ; zvuk vypnut

         push      ax
         push      bx
         push      cx

         mov       bx,166
         call      Ton
         mov       cx,1
         call      Cekej
         mov       bx,254
         call      Ton
         call      Cekej
         mov       bx,365
         call      Ton
         call      Cekej
         call      TonOff

         pop       cx
         pop       bx
         pop       ax
LupKey2: ret

LupKey   ENDP

; -----------------------------------------------------------------------------
;        £der psac¡ho stroje p©i prefixu
; -----------------------------------------------------------------------------

LupPref  PROC      NEAR

         cmp       byte ptr ds:[Sound],0
         je        LupPref2                 ; zvuk vypnut

         push      ax
         push      bx
         push      cx

         mov       bx,570
         call      Ton
         mov       cx,4
         call      Cekej
         call      TonOff

         pop       cx
         pop       bx
         pop       ax
LupPref2:ret

LupPref  ENDP
; -----------------------------------------------------------------------------
;        zapnut¡ t¢nov‚ho gener toru (BX=dˆlic¡ konstanta)
; -----------------------------------------------------------------------------
;         dw        36485,34437,32505,30680,28958,27333 ; okt va 0
;         dw        25799,24351,22984,21694,20477,19327
;         dw        18243,17219,16252,15340,14479,13667 ; okt va 1
;         dw        12899,12175,11492,10847,10238,9664
;         dw        9121,8609,8126,7670,7240,6833       ; okt va 2
;         dw        6450,6088,5746,5424,5119,4832
;         dw        4561,4305,4063,3835,3620,3417       ; okt va 3
;         dw        3225,3044,2873,2712,2560,2416
;         dw        2280,2152,2032,1918,1810,1708       ; okt va 4
;         dw        1612,1522,1437,1356,1280,1208
;         dw        1140,1076,1016,959,905,854          ; okt va 5
;         dw        806,761,718,678,640,604
;         dw        570,538,508,479,452,427             ; okt va 6
;         dw        403,380,359,339,320,302
;         dw        285,269,254,240,226,214             ; okt va 7
;         dw        202,190,180,169,160,151
;         dw        143,135,127,120,113,107             ; okt va 8
;         dw        101,95,90,85,80,75
;         dw        71,67,63,60,57,53,50,48,45,42,40,38 ; okt va 9
; -----------------------------------------------------------------------------

Ton      PROC      NEAR

         cli
         push      ax
         mov       al,0b6h
         out       [43h],al                 ; volba dˆli‡ky pro reproduktor
         mov       al,bl
         out       [42h],al                 ; dˆlic¡ konstanta LOW
         mov       al,bh
         out       [42h],al                 ; dˆlic¡ konstanta HIGH
         in        al,[61h]
         or        al,3                     ; povolen¡ v˜stupu na reproduktor
         out       [61h],al
         pop       ax
         sti

Ton9:    ret

Ton      ENDP

; -----------------------------------------------------------------------------
;        vypnut¡ zvukov‚ho gener toru
; -----------------------------------------------------------------------------

TonOff   PROC      NEAR

         push      ax
         in        al,[61h]
         and       al,not 3
         out       [61h],al                 ; vypnut¡ gener toru
         pop       ax
         ret

TonOff   ENDP

; -----------------------------------------------------------------------------
;        cejchov n¡ hodin (zabere ‡asovˆ 1 a‘ 2 impulsy hodin)
; -----------------------------------------------------------------------------

CekInit  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      dx
         push      di

         push      ds

; ------ p©¡prava registr–

         sti

         xor       ax,ax                    ; AX <- 0
         mov       ds,ax
         xor       dx,dx                    ; DX <- 0
         mov       di,46ch                  ; ‡¡ta‡ hodin

; ------ ‡ek n¡ na za‡ tek impulsu hodin

         mov       bx,ds:[di]               ; v˜choz¡ hodnota hodin
CekInit1:cmp       bx,ds:[di]               ; p©i¨el impuls hodin ?
         je        CekInit1                 ; ‡ek n¡ na za‡ tek hodin

; ------ mˆ©en¡ ‡asu (po 1 impuls hodin - tj. asi 55 ms)

         mov       bx,ds:[di]               ; £schova stavu ‡¡ta‡e hodin
         EVEN                               ; zarovn n¡ na sudou adresu
CekInit2:add       ax,1                     ; ‡¡ta‡ ni‘¨¡ho slova ‡asu
         adc       dx,0                     ; p©enos do vy¨¨¡ho slova
         cmp       bx,ds:[di]               ; byla zmˆna ?
         je        CekInit2                 ; ‡ek n¡ na zmˆnu hodin

; ------ v˜po‡et konstanty pro 1 ms

         mov       bx,55                    ; dˆlitel
         cmp       dx,bx                    ; p©ete‡en¡ ‡¡sla ?
         jb        CekInit3                 ; nen¡ p©ete‡en¡ ‡¡sla
         mov       dx,54                    ; omezen¡ ‡¡sla
CekInit3:div       bx                       ; v˜po‡et konstanty
         or        ax,ax                    ; je = 0 ?
         jnz       CekInit4                 ; nen¡ = 0
         inc       ax                       ; korekce na 1

; ------ ulo‘en¡ zmˆ©en‚ konstanty

CekInit4:pop       ds
         mov       ds:[Cit1ms],ax           ; konstanta hodin

; ------ n vrat registr–

         pop       di
         pop       dx
         pop       bx
         pop       ax
         ret

CekInit  ENDP

; -----------------------------------------------------------------------------
;        ‡ek n¡ na uplynut¡ zadan‚ho ‡asu (CX=po‘adovan  doba v milisekund ch)
; -----------------------------------------------------------------------------

Cekej    PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      di

; ------ ‡ek n¡ po zadanou dobu

         jcxz      Cekej9                   ; nen¡ ‘ dn‚ ‡ek n¡
         mov       di,offset Cit1ms         ; konstanta hodin
Cekej1:  xor       ax,ax                    ; ni‘¨¡ slovo ‡¡ta‡e hodin
         xor       dx,dx                    ; vy¨¨¡ slovo ‡¡ta‡e hodin

; ------ ‡¡t n¡ doby 1 ms

         EVEN                               ; zarovn n¡ na sudou adresu
Cekej2:  add       ax,1                     ; ‡¡ta‡ ni‘¨¡ho slova ‡asu
         adc       dx,0                     ; p©enos do vy¨¨¡ho slova
         cmp       ax,ds:[di]               ; dosa‘eno doby 1 ms ?
         jne       Cekej2                   ; ‡¡t n¡ doby 1 ms

         loop      Cekej1                   ; ‡ek n¡ na dal¨¡ 1 ms

; ------ n vrat registr–

Cekej9:  pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

Cekej    ENDP

; -----------------------------------------------------------------------------
;        instalace obsluh p©eru¨en¡
; -----------------------------------------------------------------------------

InitInt  PROC      NEAR

; ------ £schova p©eru¨en¡ INT 1Bh

         mov       ax,351bh
         int       21h
         mov       word ptr ds:[Old1B],bx
         mov       word ptr ds:[Old1B+2],es ; £schova adresy INT 1Bh

; ------ p©edefinov n¡ p©eru¨en¡ INT 23h

         push      ds
         push      cs
         pop       ds                       ; DS <- segment programu
         mov       dx,offset INT23
         mov       ax,2523h
         int       21h                      ; p©edefinov n¡ p©eru¨en¡ INT 23h

; ------ p©edefinov n¡ p©eru¨en¡ INT 24h

         mov       dx,offset INT24
         mov       ax,2524h
         int       21h                      ; p©edefinov n¡ p©eru¨en¡ INT 24h

; ------ p©edefinov n¡ p©eru¨en¡ INT 1Bh

         mov       dx,offset INT23
         mov       ax,251bh
         int       21h                      ; instalace obsluhy INT 1Bh
         pop       ds
         ret

InitInt  ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 24h a INT 23h
; -----------------------------------------------------------------------------

Int24    PROC      FAR

         mov       al,0                     ; chyby se budou ignorovat
Int23:   iret

Int24    ENDP

; -----------------------------------------------------------------------------
;        instalace CSKEY a KEYB
; -----------------------------------------------------------------------------

InitCSK  PROC      NEAR

; ------ £schova stavu KEYB a nastaven¡ kl vesnice US

         push      ds
         mov       ax,0ad83h
         int       2fh                      ; poskytnut¡ stavu KEYB.COM
         pop       ds
         mov       ds:[OldKeyb],bl          ; £schova stavu KEYB.COM

; ------ nastaven¡ mapy kl vesnice US

         push      ds
         mov       bl,0                     ; mapa kl vesnice US
         mov       ax,0ad82h
         int       2fh                      ; nastaven¡ mapy kl vesnice US
         pop       ds

; ------ test, zda je kl vesnice CSKEY

         push      cs
         pop       es
         mov       ax,KLIC1
         mov       bx,KLIC2
         mov       cx,KLIC3
         push      ds
         int       16h                      ; test instalace programu
         pop       ds
         cmp       bx,KLIC4
         jne       InitCSK9                 ; nen¡ CSKEY

         mov       ax,es
         mov       bx,cs
         cmp       ax,bx
         je        InitCSK9                 ; nen¡ CSKEY

         mov       al,es:[KlavCSKY]         ; typ kl vesnice CSKEY
         cmp       al,7                     ; je typ kl vesnice OK ?
         ja        InitCSK9                 ; nen¡ to CSKEY

         mov       ds:[RezCSKEY],es         ; segment CSKEY
         inc       byte ptr ds:[ParCSKEY]   ; je CSKEY

; ------ vypnut¡ CSKEY

         mov       ds:[OldKCSKY],al         ; p–vodn¡ typ kl vesnice CSKEY
         mov       byte ptr es:[KlavCSKY],1 ; je z kladn¡ kl vesnice
         mov       al,es:[PrepCSKY]         ; p©ep¡na‡e CSKEY
         mov       ds:[OldPCSKY],al         ; £schova p©ep¡na‡–
         and       byte ptr es:[PrepCSKY],not bit0+bit1+bit3+bit4+bit7 ; nul.p©.
         mov       ax,es:[Prf1CSKY]         ; prefixy 1
         mov       ds:[OldF1CSK],ax         ; prefixy 1
         mov       word ptr es:[Prf1CSKY],-1 ; neplatn‚ prefixy
         mov       ax,es:[Prf2CSKY]         ; prefixy 2
         mov       ds:[OldF2CSK],ax         ; prefixy 2
         mov       word ptr es:[Prf2CSKY],-1 ; neplatn‚ prefixy

InitCSK9:ret

InitCSK  ENDP

; -----------------------------------------------------------------------------
;        odinstalov n¡ CSKEY
; -----------------------------------------------------------------------------

DIniCSK  PROC      NEAR

; ------ n vrat nastaven¡ KEYB

         mov       bl,ds:[OldKeyb]          ; p–vodn¡ stav KEYB
         push      ds
         mov       ax,0ad82h
         int       2fh                      ; n vrat p–vodn¡ho stavu KEYB
         pop       ds

; ------ n vrat nastaven¡ CSKEY

         cmp       byte ptr ds:[ParCSKEY],0 ; je CSKEY ?
         je        DIniCSK9                 ; nen¡ CSKEY
         mov       es,ds:[RezCSKEY]         ; segment CSKEY

         mov       al,ds:[OldKCSKY]         ; p–vodn¡ typ kl vesnice CSKEY
         mov       es:[KlavCSKY],al         ; n vrat typu kl vesnice

         mov       al,ds:[OldPCSKY]         ; £schova p©ep¡na‡–
         mov       es:[PrepCSKY],al         ; p©ep¡na‡e CSKEY

         mov       ax,ds:[OldF1CSK]         ; prefixy 1
         mov       es:[Prf1CSKY],ax         ; prefixy 1

         mov       ax,ds:[OldF2CSK]         ; prefixy 2
         mov       es:[Prf2CSKY],ax         ; prefixy 2
DIniCSK9:ret

DIniCSK  ENDP

; -----------------------------------------------------------------------------
;        inicializace videom¢du (CY=chyba, nepodporovan  videokarta)
; -----------------------------------------------------------------------------

InitVMod PROC      NEAR

; ------ £schova aktivn¡ho videom¢du

         mov       ah,0fh
         call      Int10                    ; poskytnut¡ aktivn¡ho videom¢du
         mov       ds:[OldVMod],al          ; £schova videom¢du

; ------ test, zda je grafick  karta EGA/VGA

         mov       ah,12h                   ; funkce poskytnut¡ informac¡ EGA
         mov       bx,5810h                 ; podslu‘ba informac¡ o EGA
         call      Int10                    ; poskytnut¡ informac¡ o EGA
         cmp       bh,2
         ja        InitVMd2                 ; nen¡ karta EGA/VGA
         cmp       bl,5
         ja        InitVMd2                 ; nen¡ karta EGA/VGA

; ------ nastaven¡ grafick‚ho m¢du pro EGA a VGA

         mov       ax,16                    ; po‘adovan˜ videom¢d 16
         call      Int10                    ; nastaven¡ videom¢du 16
         mov       ah,0fh
         call      Int10                    ; poskytnut¡ aktivn¡ho videom¢du
         cmp       al,16                    ; je po‘adovan˜ videom¢d ?
         je        InitVMd7                 ; videom¢d nastaven OK

; ------ nastaven¡ videom¢du pro Hercules

InitVMd2:cmp       byte ptr ds:[OldVMod],7  ; je videom¢d 7 ?
         je        InitVMd4                 ; je videom¢d 7

         push      ds
         xor       ax,ax
         mov       ds,ax
         cmp       word ptr ds:[463h],3b4h  ; je emul tor CGA pro Hercules ?
         pop       ds
         jne       InitVMd8                 ; chyba - je asi karta CGA

InitVMd4:mov       ax,7
         call      Int10                    ; nastaven¡ MONO videom¢du
         mov       ah,0fh
         call      Int10                    ; poskytnut¡ videom¢du
         cmp       al,7                     ; nastaven videom¢d 7 ?
         jne       InitVMd8                 ; chyba - videom¢d nenastaven

; ------ nastaven¡ grafick‚ho videom¢du Hercules

         mov       byte ptr ds:[TColNad2],0 ; oprava barvy nadpisu 2
         inc       byte ptr ds:[Hercules]   ; p©¡znak videokarty Hercules
         call      InitHerc                 ; inicializace videom¢du Hercules
InitVMd7:clc
         ret

InitVMd8:stc
InitVMd9:ret

InitVMod ENDP

; -----------------------------------------------------------------------------
;        inicializace videokarty HERCULES (neuchov v  registry, jen DS !)
; -----------------------------------------------------------------------------

InitHerc PROC      NEAR

         cli                                ; z kaz p©eru¨en¡

; ------ povolen¡ p©epnut¡ adresy pamˆti, adresa je 0b000h

         mov       al,3
         mov       dx,3bfh
         out       dx,al                    ; nastaven¡ registru kompatibility

; ------ nastaven¡ grafick‚ho m¢du, videosign l blokov n

         mov       al,2
         mov       dl,0b8h
         out       dx,al                    ; nastaven¡ ©¡dic¡ho registru m¢du

; ------ nastaven¡ ©¡dic¡ch registr– CRT

         mov       dl,0b4h
         mov       si,offset ITabHerc       ; inicializa‡n¡ tabulka pro Hercules
         xor       ah,ah                    ; ukazatel ‡¡sla registru
         cld
InitHrc2:mov       al,ah                    ; ‡¡slo registru
         out       dx,al                    ; nastaven¡ ‡¡sla registru
         lodsb
         inc       dx
         out       dx,al                    ; data pro nastaven¡ registru
         dec       dx
         inc       ah
         cmp       ah,12
         jb        InitHrc2                 ; dal¨¡ registr

; ------ povolen¡ videosign lu, nastaven¡ grafick‚ho m¢du

         mov       al,0ah
         mov       dx,3b8h
         out       dx,al                    ; nastaven¡ ©¡dic¡ho registru m¢du

; ------ vymaz n¡ videopamˆti (je CLD !)

         sti
         mov       cx,4000h                 ; d‚lka videopamˆti (ve slovech)
         mov       ax,0b000h                ; segment videopamˆti
         mov       ds:[SegmVRAM],ax         ; segment videopamˆti
         mov       es,ax
         xor       ax,ax                    ; mazac¡ slovo
         xor       di,di
         rep       stosw                    ; vymaz n¡ videopamˆti
         ret

InitHerc ENDP

; -----------------------------------------------------------------------------
;        slu‘ba INT 10h s £schovou registr–
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

CodeEnd:                                    ; konec programov‚ ‡ sti

Code     ENDS

; *****************************************************************************
;
;                               Data
;
; *****************************************************************************
;þ
Data     SEGMENT

; ------ tabulka pro nastaven¡ ©¡dic¡ch registr– CRT karty Hercules

ITabHerc LABEL     BYTE
         db        53                       ; 0:celkov˜ po‡et znak– na © dek-1
         db        40                       ; 1:po‡et vidit. znak– na © dek
         db        44                       ; 2:po‡ tek horiz. zatemnˆn¡
         db        7                        ; 3:po‡et znak– na synchronizaci

         db        91                       ; 4:celk. po‡et vert. © dk–-1 (363)
         db        1                        ; 5:po‡et linek + k po‡tu © dk–
         db        88                       ; 6:po‡et viditeln˜ch © dk– (300)
         db        88                       ; 7:© dka zpˆtn‚ho bˆhu (345)
         db        2                        ; 8:1=prokl d n¡, 2=normal
         db        3                        ; 9:po‡et linek na znak - 1 (3)

         db        0                        ; 0a:prvn¡ linka kurzoru
         db        3                        ; 0b:koncov  linka kurzoru

AdrTLekc dw        TabLekC
AdrTLDat dw        TabDatC

; ------ adresy definic lekc¡ - kl vesnice IBM

TabLekI  label     dword                    ; tabulka definic lekc¡
         dd        LekcI00
         dd        LekcI01
         dd        LekcI02
         dd        LekcI03
         dd        LekcI04
         dd        LekcI05
IFNDEF   DEMO
         dd        LekcI06
         dd        LekcI07
         dd        LekcI08
         dd        LekcI09
         dd        LekcI10
         dd        LekcI11
         dd        LekcI12
         dd        LekcI13
         dd        LekcI14
         dd        LekcI15
         dd        LekcI16
         dd        LekcI17
         dd        LekcI18
         dd        LekcI19
         dd        LekcI20
         dd        LekcI21
         dd        LekcI22
         dd        LekcI23
         dd        LekcI24
         dd        LekcI25
         dd        LekcI26
         dd        LekcI27
         dd        LekcI28
         dd        LekcI29
         dd        LekcI30
         dd        LekcI31
         dd        LekcI32
         dd        LekcI33
         dd        LekcI34
         dd        LekcI35
         dd        LekcI36
         dd        LekcI37
         dd        LekcI38
         dd        LekcI39
         dd        LekcI40
         dd        LekcI41
         dd        LekcI42
         dd        LekcI43
         dd        LekcI44
         dd        LekcI45
         dd        LekcI46
         dd        LekcI47
ELSE
         REPT      42
         dd        LekceD
         ENDM
ENDIF

TabDatI  label     dword                    ; tabulka definic lekc¡
         dd        LDatI00
         dd        LDatI01
         dd        LDatI02
         dd        LDatI03
         dd        LDatI04
         dd        LDatI05
IFNDEF   DEMO
         dd        LDatI06
         dd        LDatI07
         dd        LDatI08
         dd        LDatI09
         dd        LDatI10
         dd        LDatI11
         dd        LDatI12
         dd        LDatI13
         dd        LDatI14
         dd        LDatI15
         dd        LDatI16
         dd        LDatI17
         dd        LDatI18
         dd        LDatI19
         dd        LDatI20
         dd        LDatI21
         dd        LDatI22
         dd        LDatI23
         dd        LDatI24
         dd        LDatI25
         dd        LDatI26
         dd        LDatI27
         dd        LDatI28
         dd        LDatI29
         dd        LDatI30
         dd        LDatI31
         dd        LDatI32
         dd        LDatI33
         dd        LDatI34
         dd        LDatI35
         dd        LDatI36
         dd        LDatI37
         dd        LDatI38
         dd        LDatI39
         dd        LDatI40
         dd        LDatI41
         dd        LDatI42
         dd        LDatI43
         dd        LDatI44
         dd        LDatI45
         dd        LDatI46
         dd        LDatI47
ELSE
         REPT      42
         dd        LDatD
         ENDM
ENDIF

; ------ adresy definic lekc¡ - ‡esk  kl vesnice

TabLekC  label     dword                    ; tabulka definic lekc¡
         dd        LekcC00
         dd        LekcC01
         dd        LekcC02
         dd        LekcC03
         dd        LekcC04
         dd        LekcC05
IFNDEF   DEMO
         dd        LekcC06
         dd        LekcC07
         dd        LekcC08
         dd        LekcC09
         dd        LekcC10
         dd        LekcC11
         dd        LekcC12
         dd        LekcC13
         dd        LekcC14
         dd        LekcC15
         dd        LekcC16
         dd        LekcC17
         dd        LekcC18
         dd        LekcC19
         dd        LekcC20
         dd        LekcC21
         dd        LekcC22
         dd        LekcC23
         dd        LekcC24
         dd        LekcC25
         dd        LekcC26
         dd        LekcC27
         dd        LekcC28
         dd        LekcC29
         dd        LekcC30
         dd        LekcC31
         dd        LekcC32
         dd        LekcC33
         dd        LekcC34
         dd        LekcC35
         dd        LekcC36
         dd        LekcC37
         dd        LekcC38
         dd        LekcC39
         dd        LekcC40
         dd        LekcC41
         dd        LekcC42
         dd        LekcC43
         dd        LekcC44
         dd        LekcC45
         dd        LekcC46
         dd        LekcC47
ELSE
         REPT      42
         dd        LekceD
         ENDM
ENDIF

TabDatC  label     dword                    ; tabulka definic lekc¡
         dd        LDatC00
         dd        LDatC01
         dd        LDatC02
         dd        LDatC03
         dd        LDatC04
         dd        LDatC05
IFNDEF   DEMO
         dd        LDatC06
         dd        LDatC07
         dd        LDatC08
         dd        LDatC09
         dd        LDatC10
         dd        LDatC11
         dd        LDatC12
         dd        LDatC13
         dd        LDatC14
         dd        LDatC15
         dd        LDatC16
         dd        LDatC17
         dd        LDatC18
         dd        LDatC19
         dd        LDatC20
         dd        LDatC21
         dd        LDatC22
         dd        LDatC23
         dd        LDatC24
         dd        LDatC25
         dd        LDatC26
         dd        LDatC27
         dd        LDatC28
         dd        LDatC29
         dd        LDatC30
         dd        LDatC31
         dd        LDatC32
         dd        LDatC33
         dd        LDatC34
         dd        LDatC35
         dd        LDatC36
         dd        LDatC37
         dd        LDatC38
         dd        LDatC39
         dd        LDatC40
         dd        LDatC41
         dd        LDatC42
         dd        LDatC43
         dd        LDatC44
         dd        LDatC45
         dd        LDatC46
         dd        LDatC47
ELSE
         REPT      42
         dd        LDatD
         ENDM
ENDIF

; ------ adresy definic lekc¡ - program torsk  kl vesnice 1

TabLek1  label     dword                    ; tabulka definic lekc¡
         dd        Lekc100
         dd        Lekc101
         dd        Lekc102
         dd        Lekc103
         dd        Lekc104
         dd        Lekc105
IFNDEF   DEMO
         dd        Lekc106
         dd        Lekc107
         dd        Lekc108
         dd        Lekc109
         dd        Lekc110
         dd        Lekc111
         dd        Lekc112
         dd        Lekc113
         dd        Lekc114
         dd        Lekc115
         dd        Lekc116
         dd        Lekc117
         dd        Lekc118
         dd        Lekc119
         dd        Lekc120
         dd        Lekc121
         dd        Lekc122
         dd        Lekc123
         dd        Lekc124
         dd        Lekc125
         dd        Lekc126
         dd        Lekc127
         dd        Lekc128
         dd        Lekc129
         dd        Lekc130
         dd        Lekc131
         dd        Lekc132
         dd        Lekc133
         dd        Lekc134
         dd        Lekc135
         dd        Lekc136
         dd        Lekc137
         dd        Lekc138
         dd        Lekc139
         dd        Lekc140
         dd        Lekc141
         dd        Lekc142
         dd        Lekc143
         dd        Lekc144
         dd        Lekc145
         dd        Lekc146
         dd        Lekc147
ELSE
         REPT      42
         dd        LekceD
         ENDM
ENDIF

TabDat1  label     dword                    ; tabulka definic lekc¡
         dd        LDat100
         dd        LDat101
         dd        LDat102
         dd        LDat103
         dd        LDat104
         dd        LDat105
IFNDEF   DEMO
         dd        LDat106
         dd        LDat107
         dd        LDat108
         dd        LDat109
         dd        LDat110
         dd        LDat111
         dd        LDat112
         dd        LDat113
         dd        LDat114
         dd        LDat115
         dd        LDat116
         dd        LDat117
         dd        LDat118
         dd        LDat119
         dd        LDat120
         dd        LDat121
         dd        LDat122
         dd        LDat123
         dd        LDat124
         dd        LDat125
         dd        LDat126
         dd        LDat127
         dd        LDat128
         dd        LDat129
         dd        LDat130
         dd        LDat131
         dd        LDat132
         dd        LDat133
         dd        LDat134
         dd        LDat135
         dd        LDat136
         dd        LDat137
         dd        LDat138
         dd        LDat139
         dd        LDat140
         dd        LDat141
         dd        LDat142
         dd        LDat143
         dd        LDat144
         dd        LDat145
         dd        LDat146
         dd        LDat147
ELSE
         REPT      42
         dd        LDatD
         ENDM
ENDIF

; ------ adresy definic lekc¡ - program torsk  kl vesnice 2

TabLek2  label     dword                    ; tabulka definic lekc¡
         dd        Lekc200
         dd        Lekc201
         dd        Lekc202
         dd        Lekc203
         dd        Lekc204
         dd        Lekc205
IFNDEF   DEMO
         dd        Lekc206
         dd        Lekc207
         dd        Lekc208
         dd        Lekc209
         dd        Lekc210
         dd        Lekc211
         dd        Lekc212
         dd        Lekc213
         dd        Lekc214
         dd        Lekc215
         dd        Lekc216
         dd        Lekc217
         dd        Lekc218
         dd        Lekc219
         dd        Lekc220
         dd        Lekc221
         dd        Lekc222
         dd        Lekc223
         dd        Lekc224
         dd        Lekc225
         dd        Lekc226
         dd        Lekc227
         dd        Lekc228
         dd        Lekc229
         dd        Lekc230
         dd        Lekc231
         dd        Lekc232
         dd        Lekc233
         dd        Lekc234
         dd        Lekc235
         dd        Lekc236
         dd        Lekc237
         dd        Lekc238
         dd        Lekc239
         dd        Lekc240
         dd        Lekc241
         dd        Lekc242
         dd        Lekc243
         dd        Lekc244
         dd        Lekc245
         dd        Lekc246
         dd        Lekc247
ELSE
         REPT      42
         dd        LekceD
         ENDM
ENDIF


TabDat2  label     dword                    ; tabulka definic lekc¡
         dd        LDat200
         dd        LDat201
         dd        LDat202
         dd        LDat203
         dd        LDat204
         dd        LDat205
IFNDEF   DEMO
         dd        LDat206
         dd        LDat207
         dd        LDat208
         dd        LDat209
         dd        LDat210
         dd        LDat211
         dd        LDat212
         dd        LDat213
         dd        LDat214
         dd        LDat215
         dd        LDat216
         dd        LDat217
         dd        LDat218
         dd        LDat219
         dd        LDat220
         dd        LDat221
         dd        LDat222
         dd        LDat223
         dd        LDat224
         dd        LDat225
         dd        LDat226
         dd        LDat227
         dd        LDat228
         dd        LDat229
         dd        LDat230
         dd        LDat231
         dd        LDat232
         dd        LDat233
         dd        LDat234
         dd        LDat235
         dd        LDat236
         dd        LDat237
         dd        LDat238
         dd        LDat239
         dd        LDat240
         dd        LDat241
         dd        LDat242
         dd        LDat243
         dd        LDat244
         dd        LDat245
         dd        LDat246
         dd        LDat247
ELSE
         REPT      42
         dd        LDatD
         ENDM
ENDIF

Font08   label     BYTE
INCLUDE  FONT08.ASM                         ; font 8 linek

Font16   label     BYTE
INCLUDE  FONT16.ASM                         ; font 16 linek

AdrFont  dw        Font16                   ; adresa aktu ln¡ho fontu
LinFont  dw        16                       ; po‡et linek aktu ln¡ho fontu
RadFont  dw        16*80                    ; p©¡rustek adresy ve VRAM EGA/VGA

CardTxt  db        'Program vyzaduje grafickou kartu EGA, VGA nebo Hercules !',13,10,'$'

LicTxt   db        'VAROVANI - porusena licence programu VSEMI10, program nelze spustit !',13,10,'$'

; ------ definice barev

TColPodk db        8                        ; barva podkladu
TColPap  db        15                       ; barva pap¡ru textu
TColNorm db        0                        ; norm ln¡ barva textu
TColBold db        12                       ; zv˜raznˆn‚ p¡smo
TColKeys db        1                        ; kl vesy, nadpis (modr )
TColNadp db        2                        ; barva nadpisu textu (zelen )
TColNad2 db        7                        ; barva nadpisu textu 2 (¨ed )
TColPod2 db        14                       ; barva podkladu 2

TColVyuk db        1                        ; barva v˜ukov‚ho textu
TColOK   db        2                        ; barva znaku OK
TColErr  db        12                       ; barva chybn‚ho znaku

; ------ definice palet
;        0  = obrysy kl ves, stupnice prav¡tka, popis kl ves (‡ern )
;        1  = modr  barva v textu lekc¡
;        2  = zelen  barva v textu lekc¡, barva kurzoru, r m v˜bˆru soubor–
;        4  = ‡¡slice prav¡tka (‡erven‚)
;        6  = kurzor v textu (‡erven˜)
;        7  = ¨ed‚ kl vesy (¨ed ), nadpis 2
;        8  = pozad¡ (tmavˆ modr‚)
;        9  = podklad prav¡tka (modr )
;        10 = nev˜razn˜ popis kl vesnice (svˆtle ‡erven )
;        12 = popis kl vesnice (‡erven )
;        14 = podklad kl vesnice (‘lut )
;        15 = b¡l‚ kl vesy, pap¡r (b¡l )
;þ
Palety   db        0,1,2,3,4,5,20,7,8,11,39,3bh,36,3dh,55,63,8

; ------ tabulka prefixov˜ch znak–

PrefChC1 db        'e‚rªy˜u£i¡o¢a lER«YU—I‹O•ALŠ' ; ‡esk  kl v. - ‡ rky
         db        '+1ˆ2¨3‡4©5‘6˜7 8¡9‚0=-¤\'
         db        ';~1!2@3#4$5%6^7&8*9(0)%_ª|'
         db        '£[/{)](}–;":­',39,'!"?<:>-/_?\­',0
PrefChC2 db        'eˆr©tŸu–o“s¨dƒlŒz‘c‡n¤E‰RžT†U¦O§S›D…LœZ’C€N¥' ; ‡.k.-h ‡ky
         db        '+1ˆ2¨3‡4©5‘6˜7 8¡9‚0=-¤\'
         db        ';~1!2@3#4$5%6^7&8*9(0)%_ª|'
         db        '£[/{)](}–;":­',39,'!"?<:>-/_?\­',0
PrefCh1  db        '\­q„wˆe‚r©tŸy˜u£i¡o¢p”a s¨dƒfªhj–k“lŒz‘c‡bán¤m,®.¯'
         db          'QŽW‰ERžT†YU—I‹O•P™AS›D…F«HšJ¦K§LœZ’C€BáN¥MŠ'
         db        '–1ˆ2¨3‡4©5‘6˜7 8¡9‚0'
         db        0 ; progr.1 a IBM

; ------ rozm¡stˆn¡ kl ves - IBM

KlavesI  label     byte
         db        '`~1!2@3#4$5%6^7&8*9(0)-_=+' ; ©ada "E"
         db        'QWERTYUIOP[{]}'         ; ©ada "D"
         db        'ASDFGHJKL;:',39,'"'     ; ©ada "C"
         db        'ZXCVBNM,<.>/?'          ; ©ada "B"

; ------ rozm¡stˆn¡ kl ves - ‡esk 

KlavesC  label     byte
         db        '`;+1ˆ2¨3‡4©5‘6˜7 8¡9‚0=%',39,'~' ; ©ada "E"
         db        'QWERTZUIOP£/)('         ; ©ada "D"
         db        'ASDFGHJKL–"­!'          ; ©ada "C"
         db        'YXCVBNM,?.:-_'          ; ©ada "B"

; ------ rozm¡stˆn¡ kl ves - program. 1

Klaves1  label     byte
         db        '`~–!ˆ@¨#‡$©%‘^˜& *¡(‚)-_=+' ; ©ada "E"
         db        'QWERTYUIOP[{]}'         ; ©ada "D"
         db        'ASDFGHJKL;:',39,'"'     ; ©ada "C"
         db        'ZXCVBNM,<.>/?'          ; ©ada "B"

; ------ rozm¡stˆn¡ kl ves - program. 2

Klaves2  label     byte
         db        '`~'
KlavZak1 db        '+!ˆ@¨#‡$©%‘^˜& *¡(‚)-_',39,'~' ; ©ada "E"
         db        'QWERTYUIOP[{]}'         ; ©ada "D"
         db        'ASDFGHJKL;:',39
KlavZak2 db        '"'     ; ©ada "C"
         db        'ZXCVBNM,<.>/?'          ; ©ada "B"

AdrXchg  dw        KlavXchC
AdrKlavR dw        KlavesC

; ------ z mˆna kl ves - IBM kl vesnice

KlavXchI label     byte
         db        0

; ------ z mˆna kl ves - ‡esk  kl vesnice

KlavXchC label     byte
         db        '~;'
         db        '1+'
         db        '!1'
         db        '2ˆ'
         db        '@2'
         db        '3¨'
         db        '#3'
         db        '4‡'
         db        '$4'
         db        '5©'
         db        '%5'
         db        '6‘'
         db        '^6'
         db        '7˜'
         db        '&7'
         db        '8 '
         db        '*8'
         db        '9¡'
         db        '(9'
         db        '0‚'
         db        ')0'
         db        '-='
         db        '_%'
         db        '=',39
         db        '+~'
         db        '\¤'
         db        '|ª'
         db        'yz'
         db        'YZ'
         db        'zy'
         db        'ZY'
         db        '[£'
         db        '{/'
         db        '])'
         db        '}('
         db        ';–'
         db        ':"'
         db        39,'­'
         db        '"!'
         db        '<?'
         db        '>:'
         db        '/-'
         db        '?_'
         db        0

; ------ z mˆna kl ves - program torsk  1

KlavXch1 label     byte
         db        '1–'
         db        '2ˆ'
         db        '3¨'
         db        '4‡'
         db        '5©'
         db        '6‘'
         db        '7˜'
         db        '8 '
         db        '9¡'
         db        '0‚'
         db        0

; ------ z mˆna kl ves - program torsk  2

KlavXch2 label     byte
         db        '1+'
         db        '2ˆ'
         db        '3¨'
         db        '4‡'
         db        '5©'
         db        '6‘'
         db        '7˜'
         db        '8 '
         db        '9¡'
         db        '0‚'
         db        '=',39
         db        '+~'
         db        0

; ------ ©¡dic¡ kl vesy

KlavBS   db        27,'ØBckSpc',0
KlavTab  db        'Tab',0
KlavTab0 db        17,'Ø',10,'×',16,0
KlavCaps db        'CapsLck',0
KlavEnt  db        'Enter',27,'Ä',28,0
KlavShft db        24,' Shift',0
KlavCtrl db        'Ctrl',0
KlavAlt  db        'Alt',0

; ------ text menu nastaven¡

NastText db        LF
         db        '                     P¡sa©sk  kl vesnice (psac¡ stroj)',LF
         db        '                     1. program torsk  kl vesnice (CSKEY)',LF
         db        '                     2. program torsk  kl vesnice (T602)',LF
         db        '                     Anglick  kl vesnice (origin ln¡ IBM)',LF
         db        '                     Metronom (t‚‘ F2)',LF
         db        '                     Rychlost metronomu',LF
         db        '                     Zvukov  indikace (t‚‘ F3)',LF
         db        '                     Omezen¡ d‚lky testu (minut)',LF
         db        '                     Editace chyb',LF
         db        EOT

NastMenu db        9
         db        1
         db        1
         db        19,1,'P'
         db        19,2,'1'
         db        19,3,'2'
         db        19,4,'A'
         db        19,5,'M'
         db        19,6,'R'
         db        19,7,'Z'
         db        19,8,'O'
         db        19,9,'E'

; ------ zad n¡ jm‚na

JmenTxt  db        LF
         db        LF
         db        '        Zadejte sv‚ p©¡jmen¡ a jm‚no (a dal¨¡ p©¡padn‚ £daje):',LF
         db        LF
         db        '  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿',LF
         db        '  ³                                                                 ³',LF
         db        '  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ',LF
         db        LF
         db        '                  Doba testu je omezena na ',EOT

JmenTxt1 db        ' minutu.',LF
         db        LF
         db        EOT

JmenTxt2 db        ' minuty.',LF
         db        LF
         db        EOT

JmenTxt3 db        ' minut.',LF
         db        LF
         db        EOT

; ------ £vodn¡ text
;þ
IFDEF    DEMO
UvText   db        'VSEMI10 verze 2.22 DEMO      G E M A  Soft          (c) Miroslav Nˆme‡ek',LF
ELSE
UvText   db        'VSEMI10 v2.22 FREEWARE       G E M A  Soft          (c) Miroslav Nˆme‡ek',LF
ENDIF

;IFNDEF   DEBUG
         db        'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ',LF
;ELSE
;         db        'LAD‹C‹ M•D ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ',LF
;ENDIF
         db        '                   V˜uka psan¡ na kl vesnici po‡¡ta‡e',LF
         db        LF
         db        '                                V˜uka',LF
         db        '                                Cvi‡en¡',LF
         db        '                                Test',LF
         db        '                                Nastaven¡',LF
         db        '                                Pomoc',LF
         db        '                                Konec',LF
IFNDEF   DEMO
;LicCis1  db        'Licence: 00000-00000'
ENDIF
         db        EOT

; ------ £vodn¡ menu

UvMenu   db        6                        ; po‡et polo‘ek
         db        1                        ; aktivn¡ polo‘ka 1...po‡et
         db        1
         db        32,4,'V'
         db        32,5,'C'
         db        32,6,'T'
         db        32,7,'N'
         db        32,8,'P'
         db        32,9,'K'

AdrSkup  dw        SkupTxtC                 ; text k volbˆ skupin
AdrMenS  dw        SkupMenC                 ; menu volby skupin
AdrHghK  dw        HighKeyC                 ; vysv¡cen‚ kl vesy kl vesnice
AdrHghCh dw        HighChrC                 ; tabulka povolen˜ch znak–

AdrUhoz  dw        UhozKeyC                 ; tabulka £hoz–

; ------ text menu volby skupin - ‡esk  kl v.
;þ
SkupTxtC db        '                        Zvolte po‘adovanou lekci:',LF
         db        '  —vod  ³   10 z           ³   20 n         ³   30 ˜         ³   40 _',LF
         db        '  1 dfjk³   11 t           ³   21 b         ³   31 ‘         ³   41 58­',LF
         db        '  2 a–  ³   12 £           ³   22 x CapsLock³   32 ƒŸ¤       ³   42 49%',LF
         db        '  3 sl  ³   13 m           ³   23 ¡         ³   33 ‰ž†’¦›…€¥ ³   43 30;',LF
         db        '  4 ru  ³   14 ZUIOPHJKLM  ³   24 ‡         ³   34 ¢—‹•   ³   44 1+=',LF
         db        '  5 i,  ³   15 .           ³   25           ³   35 ?         ³   45 67',LF
         db        '  6 qp  ³   16 v           ³   26 ©         ³   36 !         ³   46 2',LF
         db        '  7 gh  ³   17 QWERTASDFGV ³   27 ‚         ³   37 :         ³   47 *\',LF
         db        '  8 e   ³   18 y-          ³   28 ¨         ³   38 ()/       ³',LF
         db        '  9 wo  ³   19 c           ³   29 ˆ         ³   39 "         ³'
         db        EOT

HighChrC db        'dfjk',0                 ; 1
         db        'a–',0                   ; 2
         db        'sl',0                   ; 3
         db        'ru',0                   ; 4
         db        'i,',0                   ; 5
         db        'qp',0                   ; 6
         db        'gh',0                   ; 7
         db        'e',0                    ; 8
         db        'wo',0                   ; 9
         db        'z',0                    ; 10
         db        't',0                    ; 11
         db        '£',0                    ; 12
         db        'm',0                    ; 13
         db        'ZUIOPHJKLM',0           ; 14
         db        '.',0                    ; 15
         db        'v',0                    ; 16
         db        'QWERTASDFGV',0          ; 17
         db        'yY-',0                  ; 18
         db        'cC',0                   ; 19
         db        'nN',0                   ; 20
         db        'bB',0                   ; 21
         db        'xX',0                   ; 22
         db        '¡',0                    ; 23
         db        '‡',0                    ; 24
         db        ' ',0                    ; 25
         db        '©',0                    ; 26
         db        '‚',0                    ; 27
         db        '¨',0                    ; 28
         db        'ˆ',0                    ; 29
         db        '˜',0                    ; 30
         db        '‘',0                    ; 31
         db        'ƒŸ¤',0                  ; 32
         db        '‰ž†’¦›…€¥',0            ; 33
         db        '¢—‹•',0              ; 34
         db        '?',0                    ; 35
         db        '!',0                    ; 36
         db        ':',0                    ; 37
         db        '()/',0                  ; 38
         db        '"',0                    ; 39
         db        '_',0                    ; 40
         db        '58­',0                  ; 41
         db        '49%',0                  ; 42
         db        '30;',0                  ; 43
         db        '1+=',0                  ; 44
         db        '67',0                   ; 45
         db        '2',0                    ; 46
         db        '*\',0                   ; 47

HighKeyC db        -1,0
         db        -1,0                     ; 0
         db        'FJDK',0                 ; 1
         db        '–A',0                   ; 2
         db        'LS',0                   ; 3
         db        'UR',0                   ; 4
         db        'I,',0                   ; 5
         db        'PQ',0                   ; 6
         db        'HG',0                   ; 7
         db        'E',0                    ; 8
         db        'OW',0                   ; 9
         db        'Z',0                    ; 10
         db        'T',0                    ; 11
         db        '£',0                    ; 12
         db        'M',0                    ; 13
         db        'ZUIOPHJKLM',0           ; 14
         db        '.',0                    ; 15
         db        'V',0                    ; 16
         db        'QWERTASDFGV',0          ; 17
         db        'Y-',0                   ; 18
         db        'C',0                    ; 19
         db        'N',0                    ; 20
         db        'B',0                    ; 21
         db        'X',0                    ; 22
         db        '¡',0                    ; 23
         db        '‡',0                    ; 24
         db        ' ',0                    ; 25
         db        '©',0                    ; 26
         db        '‚',0                    ; 27
         db        '¨',0                    ; 28
         db        'ˆ',0                    ; 29
         db        '˜',0                    ; 30
         db        '‘',0                    ; 31
         db        '~DTN',0                 ; 32
         db        '~ERTZUSDCN',0           ; 33
         db        39,'EUIOAY',0            ; 34
         db        '?',0                    ; 35
         db        '!',0                    ; 36
         db        ':',0                    ; 37
         db        '()/',0                  ; 38
         db        '"',0                    ; 39
         db        '_',0                    ; 40
         db        '58­',0                  ; 41
         db        '49%',0                  ; 42
         db        '30;–',39,0              ; 43
         db        '1+=',0                  ; 44
         db        '67',0                   ; 45
         db        '2',0                    ; 46
         db        '8',39,0                 ; 47

UhozKeyC label     byte                     ; tabulka £hoz–
         db        1,2,2,3,3,2,3,2,2,1,3,1,1,1,1,2 ; mezera a‘ /
         db        2,2,2,2,2,2,2,2,2,2,2,2,3,1,3,2 ; 0 a‘ ?
         db        3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2 ; @ a‘ O
         db        2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,2 ; P a‘ _
         db        1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 ; ` a‘ o
         db        1,1,1,1,1,1,1,1,1,1,1,3,3,3,3,2 ; p a‘ 
         db        4,3,1,3,3,4,4,1,1,4,3,3,3,2,4,3 ; € a‘ 
         db        3,1,4,3,3,3,1,3,1,4,4,4,4,3,4,3 ;  a‘ Ÿ
         db        1,1,2,1,3,4,4,4,1,1,2,3,5,1,2,2 ;   a‘ ¯

SkupMenC db        48
         db        1
         db        10
         db        3,1,-1
         db        3,2,-1
         db        3,3,-1
         db        3,4,-1
         db        3,5,-1
         db        3,6,-1
         db        3,7,-1
         db        3,8,-1
         db        3,9,-1
         db        3,10,-1

         db        13,1,-1
         db        13,2,-1
         db        13,3,-1
         db        13,4,-1
         db        13,5,-1
         db        13,6,-1
         db        13,7,-1
         db        13,8,-1
         db        13,9,-1
         db        13,10,-1

         db        32,1,-1
         db        32,2,-1
         db        32,3,-1
         db        32,4,-1
         db        32,5,-1
         db        32,6,-1
         db        32,7,-1
         db        32,8,-1
         db        32,9,-1
         db        32,10,-1

         db        49,1,-1
         db        49,2,-1
         db        49,3,-1
         db        49,4,-1
         db        49,5,-1
         db        49,6,-1
         db        49,7,-1
         db        49,8,-1
         db        49,9,-1
         db        49,10,-1

         db        66,1,-1
         db        66,2,-1
         db        66,3,-1
         db        66,4,-1
         db        66,5,-1
         db        66,6,-1
         db        66,7,-1
         db        66,8,-1

; ------ text menu volby skupin - IBM

SkupTxtI db        '                        Zvolte po‘adovanou lekci:',LF
         db        '  —vod  ³   10 z            ³   20 b         ³   30 ˜         ³   40 _',LF
         db        '  1 dfjk³   11 t            ³   21 x CapsLock³   31 ‘         ³   41 58­',LF
         db        '  2 a;  ³   12 m            ³   22 £–        ³   32 ƒŸ¤       ³   42 49%',LF
         db        '  3 sl  ³   13 UIOPHJKLM    ³   23 ¡         ³   33 ‰ž†›¦…’€¥ ³   43 30',LF
         db        '  4 ru  ³   14 .            ³   24 ‡         ³   34 ¢—‹•   ³   44 1+=',LF
         db        '  5 i,  ³   15 v            ³   25           ³   35 ?         ³   45 67',LF
         db        '  6 qp  ³   16 QWERTASDFGZV ³   26 ©         ³   36 !         ³   46 2',LF
         db        '  7 gh  ³   17 y-           ³   27 ‚         ³   37 :         ³   47 *\',LF
         db        '  8 e   ³   18 c            ³   28 ¨         ³   38 ()/       ³',LF
         db        '  9 wo  ³   19 n            ³   29 ˆ         ³   39 "         ³'
         db        EOT

HighChrI db        'dfjk',0                 ; 1
         db        'a;',0                   ; 2
         db        'sl',0                   ; 3
         db        'ru',0                   ; 4
         db        'i,',0                   ; 5
         db        'qp',0                   ; 6
         db        'gh',0                   ; 7
         db        'e',0                    ; 8
         db        'wo',0                   ; 9
         db        'z',0                    ; 10
         db        't',0                    ; 11
         db        'm',0                    ; 12
         db        'UIOPHJKLM',0            ; 13
         db        '.',0                    ; 14
         db        'v',0                    ; 15
         db        'QWERTASDFGZV',0         ; 16
         db        'yY-',0                  ; 17
         db        'cC',0                   ; 18
         db        'nN',0                   ; 19
         db        'bB',0                   ; 20
         db        'xX',0                   ; 21
         db        '£–',0                   ; 22
         db        '¡',0                    ; 23
         db        '‡',0                    ; 24
         db        ' ',0                    ; 25
         db        '©',0                    ; 26
         db        '‚',0                    ; 27
         db        '¨',0                    ; 28
         db        'ˆ',0                    ; 29
         db        '˜',0                    ; 30
         db        '‘',0                    ; 31
         db        'ƒŸ¤',0                  ; 32
         db        '‰ž†›¦…’€¥',0            ; 33
         db        '¢—‹•',0              ; 34
         db        '?',0                    ; 35
         db        '!',0                    ; 36
         db        ':',0                    ; 37
         db        '()/',0                  ; 38
         db        '"',0                    ; 39
         db        '_',0                    ; 40
         db        '58­',0                  ; 41
         db        '49%',0                  ; 42
         db        '30',0                   ; 43
         db        '1+=',0                  ; 44
         db        '67',0                   ; 45
         db        '2',0                    ; 46
         db        '*\',0                   ; 47

HighKeyI db        -1,0
         db        -1,0                     ; 0
         db        'DFJK',0                 ; 1
         db        'A;',0                   ; 2
         db        'SL',0                   ; 3
         db        'RU',0                   ; 4
         db        'I,',0                   ; 5
         db        'QP',0                   ; 6
         db        'GH',0                   ; 7
         db        'E',0                    ; 8
         db        'WO',0                   ; 9
         db        'Z',0                    ; 10
         db        'T',0                    ; 11
         db        'M',0                    ; 12
         db        'UIOPHJKLM',0            ; 13
         db        '.',0                    ; 14
         db        'V',0                    ; 15
         db        'QWERTASDFGZV',0         ; 16
         db        'Y-',0                   ; 17
         db        'C',0                    ; 18
         db        'N',0                    ; 19
         db        'B',0                    ; 20
         db        'X',0                    ; 21
         db        'UJ`',0                  ; 22
         db        'I`',0                   ; 23
         db        'C`',0                   ; 24
         db        'A`',0                   ; 25
         db        'R`',0                   ; 26
         db        'E`',0                   ; 27
         db        'S`',0                   ; 28
         db        'W`',0                   ; 29
         db        'Y`',0                   ; 30
         db        'Z`',0                   ; 31
         db        'DTN`',0                 ; 32
         db        'WRTSJDZCN`',0           ; 33
         db        'OEYUIA`',0              ; 34
         db        '?',0                    ; 35
         db        '!',0                    ; 36
         db        ':',0                    ; 37
         db        '()/',0                  ; 38
         db        '"',0                    ; 39
         db        '_',0                    ; 40
         db        '58`\',0                 ; 41
         db        '49%',0                  ; 42
         db        '30',0                   ; 43
         db        '1+=',0                  ; 44
         db        '67',0                   ; 45
         db        '2',0                    ; 46
         db        '*\',0                   ; 47

UhozKeyI label     byte                     ; tabulka £hoz–
         db        1,2,2,2,2,2,2,1,2,2,2,2,1,1,1,1 ; mezera a‘ /
         db        1,1,1,1,1,1,1,1,1,1,2,1,2,1,2,2 ; 0 a‘ ?
         db        2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2 ; @ a‘ O
         db        2,2,2,2,2,2,2,2,2,2,2,1,1,1,2,2 ; P a‘ _
         db        2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 ; ` a‘ o
         db        1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2 ; p a‘ 
         db        3,2,2,2,2,3,3,2,2,3,3,3,2,2,3,3 ; € a‘ 
         db        3,2,3,2,2,3,2,3,2,3,3,3,3,3,3,2 ;  a‘ Ÿ
         db        2,2,2,2,2,3,3,3,2,2,2,3,5,2,2,2 ;   a‘ ¯

SkupMenI db        48
         db        1
         db        10
         db        3,1,-1
         db        3,2,-1
         db        3,3,-1
         db        3,4,-1
         db        3,5,-1
         db        3,6,-1
         db        3,7,-1
         db        3,8,-1
         db        3,9,-1
         db        3,10,-1

         db        13,1,-1
         db        13,2,-1
         db        13,3,-1
         db        13,4,-1
         db        13,5,-1
         db        13,6,-1
         db        13,7,-1
         db        13,8,-1
         db        13,9,-1
         db        13,10,-1

         db        33,1,-1
         db        33,2,-1
         db        33,3,-1
         db        33,4,-1
         db        33,5,-1
         db        33,6,-1
         db        33,7,-1
         db        33,8,-1
         db        33,9,-1
         db        33,10,-1

         db        50,1,-1
         db        50,2,-1
         db        50,3,-1
         db        50,4,-1
         db        50,5,-1
         db        50,6,-1
         db        50,7,-1
         db        50,8,-1
         db        50,9,-1
         db        50,10,-1

         db        67,1,-1
         db        67,2,-1
         db        67,3,-1
         db        67,4,-1
         db        67,5,-1
         db        67,6,-1
         db        67,7,-1
         db        67,8,-1

; ------ text menu volby skupin - progr. 1

SkupTxt1 db        '                        Zvolte po‘adovanou lekci:',LF
         db        '  —vod  ³   10 z            ³   20 b         ³   30 ˜         ³   40 _',LF
         db        '  1 dfjk³   11 t            ³   21 x CapsLock³   31 ‘         ³   41 58­',LF
         db        '  2 a;  ³   12 m            ³   22 £–        ³   32 ƒŸ¤       ³   42 49%',LF
         db        '  3 sl  ³   13 UIOPHJKLM    ³   23 ¡         ³   33 ‰ž†›¦…’€¥ ³   43 30',LF
         db        '  4 ru  ³   14 .            ³   24 ‡         ³   34 ¢—‹•   ³   44 1+=',LF
         db        '  5 i,  ³   15 v            ³   25           ³   35 ?         ³   45 67',LF
         db        '  6 qp  ³   16 QWERTASDFGZV ³   26 ©         ³   36 !         ³   46 2',LF
         db        '  7 gh  ³   17 y-           ³   27 ‚         ³   37 :         ³   47 *\',LF
         db        '  8 e   ³   18 c            ³   28 ¨         ³   38 ()/       ³',LF
         db        '  9 wo  ³   19 n            ³   29 ˆ         ³   39 "         ³'
         db        EOT

HighChr1 db        'dfjk',0                 ; 1
         db        'a;',0                   ; 2
         db        'sl',0                   ; 3
         db        'ru',0                   ; 4
         db        'i,',0                   ; 5
         db        'qp',0                   ; 6
         db        'gh',0                   ; 7
         db        'e',0                    ; 8
         db        'wo',0                   ; 9
         db        'z',0                    ; 10
         db        't',0                    ; 11
         db        'm',0                    ; 12
         db        'UIOPHJKLM',0            ; 13
         db        '.',0                    ; 14
         db        'v',0                    ; 15
         db        'QWERTASDFGZV',0         ; 16
         db        'yY-',0                  ; 17
         db        'cC',0                   ; 18
         db        'nN',0                   ; 19
         db        'bB',0                   ; 20
         db        'xX',0                   ; 21
         db        '£–',0                   ; 22
         db        '¡',0                    ; 23
         db        '‡',0                    ; 24
         db        ' ',0                    ; 25
         db        '©',0                    ; 26
         db        '‚',0                    ; 27
         db        '¨',0                    ; 28
         db        'ˆ',0                    ; 29
         db        '˜',0                    ; 30
         db        '‘',0                    ; 31
         db        'ƒŸ¤',0                  ; 32
         db        '‰ž†›¦…’€¥',0            ; 33
         db        '¢—‹•',0              ; 34
         db        '?',0                    ; 35
         db        '!',0                    ; 36
         db        ':',0                    ; 37
         db        '()/',0                  ; 38
         db        '"',0                    ; 39
         db        '_',0                    ; 40
         db        '58­',0                  ; 41
         db        '49%',0                  ; 42
         db        '30',0                   ; 43
         db        '1+=',0                  ; 44
         db        '67',0                   ; 45
         db        '2',0                    ; 46
         db        '*\',0                   ; 47

HighKey1 db        -1,0
         db        -1,0                     ; 0
         db        'DFJK',0                 ; 1
         db        'A;',0                   ; 2
         db        'SL',0                   ; 3
         db        'RU',0                   ; 4
         db        'I,',0                   ; 5
         db        'QP',0                   ; 6
         db        'GH',0                   ; 7
         db        'E',0                    ; 8
         db        'WO',0                   ; 9
         db        'Z',0                    ; 10
         db        'T',0                    ; 11
         db        'M',0                    ; 12
         db        'UIOPHJKLM',0            ; 13
         db        '.',0                    ; 14
         db        'V',0                    ; 15
         db        'QWERTASDFGZV',0         ; 16
         db        'Y-',0                   ; 17
         db        'C',0                    ; 18
         db        'N',0                    ; 19
         db        'B',0                    ; 20
         db        'X',0                    ; 21
         db        '–U`',0                  ; 22
         db        '¡',0                    ; 23
         db        '‡',0                    ; 24
         db        ' ',0                    ; 25
         db        '©',0                    ; 26
         db        '‚',0                    ; 27
         db        '¨',0                    ; 28
         db        'ˆ',0                    ; 29
         db        '˜',0                    ; 30
         db        '‘',0                    ; 31
         db        'DTN`',0                 ; 32
         db        'WRTSJDZCN`',0           ; 33
         db        'OEYUIOA`',0             ; 34
         db        '?',0                    ; 35
         db        '!',0                    ; 36
         db        ':',0                    ; 37
         db        '()/',0                  ; 38
         db        '"',0                    ; 39
         db        '_',0                    ; 40
         db        '© `\',0                 ; 41
         db        '‡¡%`',0                 ; 42
         db        '¨‚`',0                  ; 43
         db        '–`+=',0                 ; 44
         db        '‘˜`',0                  ; 45
         db        'ˆ`',0                   ; 46
         db        '*\',0                   ; 47

UhozKey1 label     byte                     ; tabulka £hoz–
         db        1,2,2,2,2,2,2,1,2,2,2,2,1,1,1,1 ; mezera a‘ /
         db        2,2,2,2,2,2,2,2,2,2,2,1,2,1,2,2 ; 0 a‘ ?
         db        2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2 ; @ a‘ O
         db        2,2,2,2,2,2,2,2,2,2,2,1,1,1,2,2 ; P a‘ _
         db        2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 ; ` a‘ o
         db        1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2 ; p a‘ 
         db        3,2,1,2,2,3,3,1,1,3,3,3,2,2,3,3 ; € a‘ 
         db        3,1,3,2,2,3,1,3,1,3,3,3,3,3,3,2 ;  a‘ Ÿ
         db        1,1,2,2,2,3,3,3,1,1,2,3,5,2,2,2 ;   a‘ ¯

SkupMen1 db        48
         db        1
         db        10
         db        3,1,-1
         db        3,2,-1
         db        3,3,-1
         db        3,4,-1
         db        3,5,-1
         db        3,6,-1
         db        3,7,-1
         db        3,8,-1
         db        3,9,-1
         db        3,10,-1

         db        13,1,-1
         db        13,2,-1
         db        13,3,-1
         db        13,4,-1
         db        13,5,-1
         db        13,6,-1
         db        13,7,-1
         db        13,8,-1
         db        13,9,-1
         db        13,10,-1

         db        33,1,-1
         db        33,2,-1
         db        33,3,-1
         db        33,4,-1
         db        33,5,-1
         db        33,6,-1
         db        33,7,-1
         db        33,8,-1
         db        33,9,-1
         db        33,10,-1

         db        50,1,-1
         db        50,2,-1
         db        50,3,-1
         db        50,4,-1
         db        50,5,-1
         db        50,6,-1
         db        50,7,-1
         db        50,8,-1
         db        50,9,-1
         db        50,10,-1

         db        67,1,-1
         db        67,2,-1
         db        67,3,-1
         db        67,4,-1
         db        67,5,-1
         db        67,6,-1
         db        67,7,-1
         db        67,8,-1

; ------ text menu volby skupin - progr. 2

SkupTxt2 db        '                        Zvolte po‘adovanou lekci:',LF
         db        '  —vod  ³   10 z            ³   20 b         ³   30 ˜         ³   40 _',LF
         db        '  1 dfjk³   11 t            ³   21 x CapsLock³   31 ‘         ³   41 58­',LF
         db        '  2 a;  ³   12 m            ³   22 £–        ³   32 ƒŸ¤       ³   42 49%',LF
         db        '  3 sl  ³   13 UIOPHJKLM    ³   23 ¡         ³   33 ‰ž†¦›…’€¥ ³   43 30',LF
         db        '  4 ru  ³   14 .            ³   24 ‡         ³   34 ¢—‹•   ³   44 1+=',LF
         db        '  5 i,  ³   15 v            ³   25           ³   35 ?         ³   45 67',LF
         db        '  6 qp  ³   16 QWERTASDFGZV ³   26 ©         ³   36 !         ³   46 2',LF
         db        '  7 gh  ³   17 y-           ³   27 ‚         ³   37 :         ³   47 *\',LF
         db        '  8 e   ³   18 c            ³   28 ¨         ³   38 ()/       ³',LF
         db        '  9 wo  ³   19 n            ³   29 ˆ         ³   39 "         ³'
         db        EOT

HighChr2 db        'dfjk',0                 ; 1
         db        'a;',0                   ; 2
         db        'sl',0                   ; 3
         db        'ru',0                   ; 4
         db        'i,',0                   ; 5
         db        'qp',0                   ; 6
         db        'gh',0                   ; 7
         db        'e',0                    ; 8
         db        'wo',0                   ; 9
         db        'z',0                    ; 10
         db        't',0                    ; 11
         db        'm',0                    ; 12
         db        'UIOPHJKLM',0            ; 13
         db        '.',0                    ; 14
         db        'v',0                    ; 15
         db        'QWERTASDFGZV',0         ; 16
         db        'yY-',0                  ; 17
         db        'cC',0                   ; 18
         db        'nN',0                   ; 19
         db        'bB',0                   ; 20
         db        'xX',0                   ; 21
         db        '£–',0                   ; 22
         db        '¡',0                    ; 23
         db        '‡',0                    ; 24
         db        ' ',0                    ; 25
         db        '©',0                    ; 26
         db        '‚',0                    ; 27
         db        '¨',0                    ; 28
         db        'ˆ',0                    ; 29
         db        '˜',0                    ; 30
         db        '‘',0                    ; 31
         db        'ƒŸ¤',0                  ; 32
         db        '‰ž†›¦…’€¥',0            ; 33
         db        '¢—‹•',0              ; 34
         db        '?',0                    ; 35
         db        '!',0                    ; 36
         db        ':',0                    ; 37
         db        '()/',0                  ; 38
         db        '"',0                    ; 39
         db        '_',0                    ; 40
         db        '58­',0                  ; 41
         db        '49%',0                  ; 42
         db        '30',0                   ; 43
         db        '1+=',0                  ; 44
         db        '67',0                   ; 45
         db        '2',0                    ; 46
         db        '*\',0                   ; 47

HighKey2 db        -1,0
         db        -1,0                     ; 0
         db        'DFJK',0                 ; 1
         db        'A;',0                   ; 2
         db        'SL',0                   ; 3
         db        'RU',0                   ; 4
         db        'I,',0                   ; 5
         db        'QP',0                   ; 6
         db        'GH',0                   ; 7
         db        'E',0                    ; 8
         db        'WO',0                   ; 9
         db        'Z',0                    ; 10
         db        'T',0                    ; 11
         db        'M',0                    ; 12
         db        'UIOPHJKLM',0            ; 13
         db        '.',0                    ; 14
         db        'V',0                    ; 15
         db        'QWERTASDFGZV',0         ; 16
         db        'Y-',0                   ; 17
         db        'C',0                    ; 18
         db        'N',0                    ; 19
         db        'B',0                    ; 20
         db        'X',0                    ; 21
         db        'U~',39,0                ; 22
         db        '¡',0                    ; 23
         db        '‡',0                    ; 24
         db        ' ',0                    ; 25
         db        '©',0                    ; 26
         db        '‚',0                    ; 27
         db        '¨',0                    ; 28
         db        'ˆ',0                    ; 29
         db        '˜',0                    ; 30
         db        '‘',0                    ; 31
         db        'DTN~',0                 ; 32
         db        'ERTUSDZCN~',0           ; 33
         db        'OEUIAY',39,0            ; 34
         db        '?',0                    ; 35
         db        '!',0                    ; 36
         db        ':',0                    ; 37
         db        '()/',0                  ; 38
         db        '"',0                    ; 39
         db        '_',0                    ; 40
         db        '© \',39,0               ; 41
         db        '‡¡%',39,0               ; 42
         db        '¨‚',39,0                ; 43
         db        '++=',39,0               ; 44
         db        '‘˜',39,0                ; 45
         db        'ˆ',39,0                 ; 46
         db        '*\',0                   ; 47

UhozKey2 label     byte                     ; tabulka £hoz–
         db        1,2,2,2,2,2,2,1,2,2,2,1,1,1,1,1 ; mezera a‘ /
         db        2,2,2,2,2,2,2,2,2,2,2,1,2,2,2,2 ; 0 a‘ ?
         db        2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2 ; @ a‘ O
         db        2,2,2,2,2,2,2,2,2,2,2,1,1,1,2,2 ; P a‘ _
         db        1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 ; ` a‘ o
         db        1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2 ; p a‘ 
         db        4,3,1,3,3,4,4,1,1,4,3,3,3,2,4,3 ; € a‘ 
         db        3,1,4,3,3,3,2,3,1,4,4,4,4,3,4,3 ;  a‘ Ÿ
         db        1,1,2,2,3,4,4,4,1,1,2,3,5,2,2,2 ;   a‘ ¯

SkupMen2 db        48
         db        1
         db        10
         db        3,1,-1
         db        3,2,-1
         db        3,3,-1
         db        3,4,-1
         db        3,5,-1
         db        3,6,-1
         db        3,7,-1
         db        3,8,-1
         db        3,9,-1
         db        3,10,-1

         db        13,1,-1
         db        13,2,-1
         db        13,3,-1
         db        13,4,-1
         db        13,5,-1
         db        13,6,-1
         db        13,7,-1
         db        13,8,-1
         db        13,9,-1
         db        13,10,-1

         db        33,1,-1
         db        33,2,-1
         db        33,3,-1
         db        33,4,-1
         db        33,5,-1
         db        33,6,-1
         db        33,7,-1
         db        33,8,-1
         db        33,9,-1
         db        33,10,-1

         db        50,1,-1
         db        50,2,-1
         db        50,3,-1
         db        50,4,-1
         db        50,5,-1
         db        50,6,-1
         db        50,7,-1
         db        50,8,-1
         db        50,9,-1
         db        50,10,-1

         db        67,1,-1
         db        67,2,-1
         db        67,3,-1
         db        67,4,-1
         db        67,5,-1
         db        67,6,-1
         db        67,7,-1
         db        67,8,-1

IFDEF    DEBUG
HighKeyT db        256 dup(0)               ; tabulka povolen¡ znak– pro ovˆ©en¡
ENDIF

; ------ obsluha v˜stupn¡ho protokolu

ProtBuff db        10 dup(0)                ; buffer k dek¢dov n¡ ‡¡sla

ProtName db        'Jm‚no: '
ProtNamB db        80 dup(0)                ; buffer jm‚na
ProtNamN dw        0                        ; d‚lka jm‚na

ProtTxt2 label     byte
         db        'Datum: ',0              ; n sleduje DEN
         db        '.',0                    ; n sleduje M‰S‹C
         db        '.',0                    ; n sleduje ROK
         db        13,10
         db        '  €as: ',0              ; n sleduje HODINA
         db        ':',0                    ; n sleduje MINUTA
         db        13,10
         db        'D‚lka: ',0              ; n sleduje DLKA MINUT
         db        ' min ',0                ; n sleduje DLKA SEKUND
         db        '.',0                    ; n sleduje DESETINY SEKUND
         db        ' sek',13,10
         db        '—hoz–: ',0              ; n sleduje —HOZ¦
         db        13,10
         db        'V˜kon: ',0              ; n sleduje VKON
         db        ' £hoz–/min',13,10
         db        'Oprav: ',0              ; n sleduje OPRAVY
         db        13,10
         db        'Kl v.: ',0              ; n sleduje typ kl vesnice

ProtTest db        ' Test: '
ProtTstA db        '           ',13,10
         db        ' Chyb: ',0              ; n sleduje CITCHYB
         db        ' (',0                   ; n sleduje cel  ‡ st % chyb
         db        '.',0                    ; n sleduje desetinn  ‡ st % chyb
         db        '%)',13,10,0

ProtTxt6 db        SIRTEXT dup("-"),13,10   ; oddˆlovac¡ ‡ ra
ProtTxt7 label     byte

ProtTstB db        '        .   ',13,10     ; jm‚no souboru

ProtKlvC db        'p¡sa©sk ',13,10,0
ProtKlv1 db        'program torsk  1 (CSKEY)',13,10,0
ProtKlv2 db        'program torsk  2 (T602)',13,10,0
ProtKlvI db        'anglick ',13,10,0

TOutTxt  db        '%2Uplynula doba k proveden¡ testu !',EOT
TOutTxt0 label     byte

TestTxt1 db        '%1H o d n o c e n ¡',EOT
TestTxt2 db        'V ¨ v˜kon je ',EOT
TestTxt3 db        ' £hoz– za minutu',EOT
TestTxt4 db        'p©i ',EOT
TestTxt5 db        '%% chyb'
TestTx52 db        '.',EOT
TestTxt6 label     byte

WritTxt1 db        '%CCHYBA ZPISU DO SOUBORU PROTOKOLU TESTU !',EOT
WritTxt2 label     byte

TestOK   db        '%2M–‘ete pokra‡ovat dal¨¡m cvi‡en¡m...',EOT
TestErr  db        '%C       Cvi‡en¡ si zopakujte...',EOT

LekcTxtN db 'LEKCE 00 (',EOT                ; text ‡¡sla lekce

AktLekce dw        0                        ; aktivn¡ lekce
AktCvic  dw        0                        ; aktivn¡ cvi‡en¡ 0...

IncRoll  dw        FONTEXT*80               ; p©¡rustek pro rolov n¡ obrazovky
LinRoll  dw        FONTEXT                  ; po‡et linek na v˜¨ku

SegmVRAM dw        0a000h                   ; segment videopamˆti
OldVMod  db        0                        ; uschovan˜ p–vodn¡ videom¢d

SegmPSP  dw        0                        ; segment PSP
Old1B    dd        0                        ; uschovan  adresa p©eru¨en¡ INT 1Bh

Hercules db        0                        ; 0 <> p©¡znak videokarty Hercules

NextMetr dd        0                        ; ‡as p©¡¨t¡ho tiku metronomu
Metronom dw        9                        ; p©¡rustek metronomu (doba v 1/18 s)

PozTxt   dw        0                        ; ukazatel pozice na text. © dku

SoubChar label     byte                     ; konverze na znaky souboru
         db        'CUEDADTCEELILLAA'       ; "€" a‘ "" (128 a‘ 143)
         db        'EZZOOOUUYOUSLYRT'       ; "" a‘ "Ÿ" (144 a‘ 159)
         db        'AIOUNNUOSRRR'           ; "" a‘ "«" (160 a‘ 171)

KONFFILE db        'VSEMI10.CNF',0          ; konfigura‡n¡ soubor
TESTFILE db        'TESTY',0                ; adres © soubor– test–
PROTFILE db        'PROTOKOL',0             ; adres © soubor– protokol–

PROTFIL1 db        '\'                      ; oddˆlova‡ cesty
PROTFIL0 db        14 dup(0)                ; buffer k sestaven¡ jm‚na

ProtIdnt dw        0                        ; identifik tor souboru protokolu
ProtPoz  dw        0                        ; pozice na © dku protokolu

Soubor   db        120 dup(0)               ; buffer jm‚na souboru
VstupN   dw        0                        ; po‡et bajt– ve vstupn¡m bufferu
VystupN  dw        0                        ; po‡et bajt– ve v˜stupn¡m bufferu

BuffDTA  db        44 dup(0)                ; pracovn¡ buffer DTA

HelpTxt  db        'VSEMI10 v2.22 - vyuka psani na klavesnici; (c) Miroslav Nemecek',13,10
         db        'Zadejte:    ? ............. tato napoveda',13,10
         db        '            /Csoubor ...... konfiguracni soubor',13,10
         db        '            /Tadresar ..... adresar s testy',13,10
         db        '            /Padresar ..... adresar s protokoly',13,10
         db        '$'

KonfSpec db        142 dup(0)               ; konfigura‡n¡ soubor

TestSpcA dw        TestSpec                 ; adresa konce cesty
TestSpec db        142 dup(0)               ; adres © s testy

ProtSpcA dw        ProtSpec                 ; adresa konce cesty
ProtSpec db        142 dup(0)               ; adres © s protokoly

; ------ obsluha v˜bˆru soubor– testu

FileNum  dw        0                        ; po‡et soubor– v bufferu "VstupS"
FileTop  dw        0                        ; po‡ te‡n¡ zobrazen˜ soubor
FileAkt  dw        0                        ; aktivn¡ ozna‡en˜ soubor

NFndTxt  db        '%CNenalezen ‘ dn˜ soubor testu !',EOT
NFndTxt0 label     byte

VyberTxt db        '%1Zvolte po‘adovan˜ test:',EOT
VyberTx0 label     byte

ReadTxt  db        '%CChyba na‡ten¡ souboru testu !',EOT
ReadTxt0 label     byte

; ------ Konfigurace

KONFIG   LABEL     BYTE
Identif  db        'VS10'                   ; (0:) identifikace
AktKlav  dw        0                        ; (4:) aktivn¡ kl vesnice
                                            ;   0 = ‡esk 
                                            ;   1 = program torsk  1 (CSKEY)
                                            ;   2 = program torsk  2 (T602)
                                            ;   3 = IBM
Sound    db        1                        ; (6:) 0 <> p©¡znak zapnut¡ zvuku
Metron   db        0                        ; (7:) 0 <> p©¡znak metronomu
MetrSet  dw        120                      ; (8:) nastaven  rychlost metronomu
Omezeni  dw        5                        ; (10:) omezen¡ d‚lky testu (minut)
Editace  db        0                        ; (12:) 0 <> p©¡znak povolen¡ editace
CheckSum dw        0                        ; (13:) kontroln¡ sou‡et konfigurace
KONFIG0  LABEL     BYTE

; ------ buffer k na‡ten¡ konfigurace

KONFIGR  db        KONFIG0-KONFIG dup(0)

; ------ parametry testu

ParTest  db        0                        ; parametry testu
                                            ;   bit 0: 1=okam‘it  kontrola chyb
                                            ;   bit 1: 1=minul˜ znak byla chyba
                                            ;   bit 2:
                                            ;   bit 3: 1=z kaz editace p©i v˜uce
                                            ;   bit 4: 1=povoleno listov n¡ str nek
                                            ;   bit 5: 1=p©edchoz¡ test PAGEUP
                                            ;   bit 6: 1=n sleduj¡c¡ test PAGEDOWN

LastTErr db        0                        ; minul˜ chybnˆ zadan˜ znak

Uhozy    dw        0                        ; ‡¡ta‡ £hoz– celkem
CitChyb  dw        0                        ; ‡¡ta‡ chyb
CitChybL dw        0                        ; ‡¡ta‡ chyb na © dku
Opravy   dw        0                        ; ‡¡ta‡ oprav v textu

LinBuff  db        SIRTEXT+6 dup(0)         ; buffer textu © dku
CitLUhoz dw        0                        ; ‡¡ta‡ £hoz– na © dku

LastDTim dw        0                        ; naposledy zobrazen˜ ‡as (sekundy)

BegDateD db        0                        ; po‡ te‡n¡ datum - den
BegDateM db        0                        ; po‡ te‡n¡ datum - mˆs¡c
BegDateY dw        0                        ; po‡ te‡n¡ datum - rok

BegTimeT db        0                        ; po‡ te‡n¡ ‡as - setiny sekundy
BegTimeS db        0                        ; po‡ te‡n¡ ‡as - sekundy
BegTimeM db        0                        ; po‡ te‡n¡ ‡as - minuty
BegTimeH db        0                        ; po‡ te‡n¡ ‡as - hodiny

DobaS    db        0                        ; ubˆhl  doba - setiny sekundy
Doba     dw        0                        ; celkovˆ ubˆhl  doba (v sekund ch)

AktDobaS db        0                        ; aktu lnˆ ubˆhl  doba (setiny sekundy)
AktDoba  dw        0                        ; aktu lnˆ ubˆhl  doba (v sekund ch)

Vykon    dw        0                        ; v˜kon (£hoz– za minutu)
Chyby    dw        0                        ; chyby*10000 (v setin ch procent)

HelpAkt  dw        0                        ; aktivn¡ str nka n povˆdy 0...

HlpTxt   db        '  %EPageUp%0=zpˆt     %EPageDown%0=vp©ed     %EHome%0=prvn¡     %EEnd%0=posledn¡     %EESC%0=konec',0
HlpTxtH  db        '  %FPageUp=zpˆt     PageDown=vp©ed     Home=prvn¡     End=posledn¡     ESC=konec',0 ; pro Hercules

; ------ obsluha CSKEY

ParCSKEY db        0                        ; 0 <> p©¡znak, ‘e je CSKEY
RezCSKEY dw        0                        ; segment rezident. modulu CSKEY

OldKCSKY db        0                        ; p–vodn¡ typ kl vesnice CSKEY
OldPCSKY db        0                        ; p–vodn¡ p©ep¡na‡e CSKEY
OldF1CSK dw        0                        ; p–vodn¡ prefixy 1
OldF2CSK dw        0                        ; p–vodn¡ prefixy 2

OldKeyb  db        0                        ; p–vodn¡ p©¡znak KEYB.COM

         EVEN                               ; za‡¡n  na sud‚ adrese jako 0:46ch
Cit1ms   dw        0                        ; konstanta pro dobu 1 ms

Data     ENDS

LekSeg1  SEGMENT   BYTE PUBLIC
LekSeg1  ENDS

LekSeg2  SEGMENT   BYTE PUBLIC
LekSeg2  ENDS

LekSeg3  SEGMENT   BYTE PUBLIC
LekSeg3  ENDS

LekSeg4  SEGMENT   BYTE PUBLIC
LekSeg4  ENDS

HelpSeg  SEGMENT   BYTE PUBLIC
HelpSeg  ENDS

; *****************************************************************************
;
;                        Buffer v˜stupn¡ho protokolu
;
; *****************************************************************************

VystupS  SEGMENT   PARA
         db        0ffffh dup(?)
VystupS  ENDS

; *****************************************************************************
;
;                        Buffer vstupn¡ho textu k testu
;
; *****************************************************************************

VstupS   SEGMENT   PARA
         db        0ffffh dup(?)
VstupS   ENDS

; *****************************************************************************
;
;                            Z sobn¡k
;
; *****************************************************************************

Zasob    SEGMENT   STACK 'STACK'
         dw        200h dup(?)
Zasob    ENDS

         END       Start

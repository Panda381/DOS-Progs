
Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

KODJMP   EQU       0E9h                     ; k¢d instrukce JMP NEAR
KODPAX   EQU       50h                      ; k¢d instrukce PUSH AX
KODPBX   EQU       53h                      ; k¢d instrukce PUSH BX
KODPCX   EQU       51h                      ; k¢d instrukce PUSH CX
KODPDX   EQU       52h                      ; k¢d instrukce PUSH DX
OffsEXE  EQU       16                       ; offset adresy skoku v zavadàái EXE
OffsCOM  EQU       5                        ; offset adresy skoku v zavadàái COM

; ------ zobrazen° £vodn°ho textu

Start:   mov       dx,offset UvTxt          ; £vodn° text
         mov       ah,9
         int       21h                      ; zobrazen° £vodn°ho textu

; ------ p©edefinov†n° z†sobn°ku

         cmp       sp,offset Zasob
         jae       Start2                   ; pamàü je OK

; ------ chyba - nedostatek pamàti

Start1:  mov       dx,offset MemTxt         ; text - nedostatek pamàti
Chyba:   mov       ah,9
         int       21h                      ; zobrazen° textu n†povàdy
INT23:
Chyba2:  call      ClosErr                  ; uzav©en° souborñ p©i chybà
         mov       ax,4c01h
         int       21h

; ------ inicializace pamàüovòch bufferñ

Start2:  mov       sp,offset Zasob          ; novò konec z†sobn°ku
         call      InitMem                  ; inicializace pamàti
         jc        Start1                   ; chyba pamàti

; ------ p©edefinov†n° INT 23h

         mov       dx,offset INT23
         mov       ax,2523h
         int       21h

; ------ rozbor p©°kazovÇho ©†dku

         call      Rozbor                   ; rozbor p©°kazovÇho ©†dku
         mov       dx,offset HelpTxt        ; text n†povàdy
Chyba3:  jc        Chyba                    ; chyba zad†n° parametrñ

; ------ otev©en° vstupn°ho souboru

         call      OpenIn                   ; otev©en° vstupn°ho souboru
         jc        Chyba

; ------ sestaven° jmÇna vòstupn°ho souboru

         call      InitOut                  ; sestaven° jmÇna vòstup. souboru

; ------ p©i testu se vòstupn° soubor nevytv†©°

         test      byte ptr ds:[Param],10h  ; poëaduje se test souboru ?
         jnz       Start4                   ; je pouze test - nen° vòstup. soub.

; ------ test, zda vòstupn° soubor jië existuje

         mov       dx,offset Soubor2        ; jmÇno vòstupn°ho souboru
         mov       ah,4eh
         mov       cx,3fh                   ; atributy
         int       21h                      ; test vòstupn°ho souboru
         jc        Start3                   ; soubor nenalezen

; ------ dotaz, zda se m† soubor p©epsat

         mov       dx,offset ExTxt          ; text - existuje
         mov       ah,9
         int       21h                      ; zobrazen° textu

; ------ áek†n° na zad†n° znaku

         mov       ax,0c01h
         int       21h                      ; vstup znaku z konzoly
         push      ax
         mov       dx,offset CRTxt
         mov       ah,9
         int       21h
         pop       ax
         cmp       al,"a"
         je        Start3
         cmp       al,"A"
         jne       Chyba2                   ; p©eru®en° programu

; ------ vytvo©en° vòstupn°ho souboru

Start3:  mov       dx,offset Soubor2        ; jmÇno vòstupn°ho souboru
         mov       ah,3ch
         xor       cx,cx                    ; atributy
         int       21h                      ; vytvo©en° souboru
         mov       dx,offset CreatTxt       ; text - nelze vytvo©it
Chyba4:  jc        Chyba3                   ; chyba - soubor nelze vytvo©it
         mov       ds:[SouborI2],ax         ; identifik†tor souboru

; ------ test, zda je soubor typu EXE

Start4:  call      TestExe                  ; test souboru, zda je EXE
         jc        Chyba4                   ; chyba áten° ze souboru

; ------ test, zda je program jië chr†nàn pojistkou

         call      TestPoj                  ; test souboru, zda je pojistka
         jc        Chyba4                   ; chyba áten° ze souboru

; ------ rozli®en° operac° pro EXE a COM

         test      byte ptr ds:[Param],2    ; je program typu EXE ?
         jnz       Start6                   ; je typu EXE

; ------ odstranàn° pojistky COM

         test      byte ptr ds:[Param],8
         jz        Start52
         call      DInsC                    ; odstranàn° pojistky COM
         jmp       short Start58

; ------ test pojistky COM

Start52: test      byte ptr ds:[Param],10h
         jz        Start53
         call      TestC                    ; test pojistky COM
         jmp       short Start58

; ------ opraven° programu COM

Start53: test      byte ptr ds:[Param],20h
         jz        Start54
         call      OprC                     ; opraven° programu COM
         jmp       short Start58

; ------ instalace pojistky COM

Start54: call      InstC                    ; instalace pojistky COM
Start58: jc        Chyba4                   ; nàjak† chyba
         jmp       short Start7

; ------ inicializace parametrñ vstupn°ho souboru EXE

Start6:  call      InitXPar                 ; inicializace parametrñ EXE

; ------ odstranàn° pojistky EXE

         test      byte ptr ds:[Param],8
         jz        Start62
         call      DInsX                    ; odstranàn° pojistky EXE
         jmp       short Start68

; ------ test pojistky EXE

Start62: test      byte ptr ds:[Param],10h
         jz        Start63
         call      TestX                    ; test pojistky EXE
         jmp       short Start68

; ------ opraven° programu EXE

Start63: test      byte ptr ds:[Param],20h
         jz        Start64
         call      OprX                     ; opraven° programu EXE
         jmp       short Start68

; ------ instalace pojistky EXE

Start64: call      InstX                    ; instalace pojistky EXE
Start68: jc        Start58                  ; nàjak† chyba

; ------ nastaven° data a áasu souboru

Start7:  test      byte ptr ds:[Param],10h  ; je pouze test ?
         jnz       Start72                  ; je pouze test

         mov       bx,ds:[SouborI2]         ; identifik†tor souboru
         or        bx,bx
         jz        Start72
         mov       cx,ds:[FileTime]         ; áas souboru
         mov       dx,ds:[FileDate]         ; datum souboru
         mov       ax,5701h
         int       21h                      ; nastaven° data a áasu souboru

; ------ uzav©en° souborñ

Start72: mov       bx,ds:[SouborI1]         ; vstupn° soubor
         or        bx,bx
         jz        Start73
         mov       ah,3eh
         int       21h                      ; uzav©en° souboru
         mov       word ptr ds:[SouborI1],0

Start73: test      byte ptr ds:[Param],10h
         jnz       Start74                  ; je pouze test
         mov       bx,ds:[SouborI2]         ; vòstupn° soubor
         or        bx,bx
         jz        Start74
         mov       ah,3eh
         int       21h                      ; uzav©en° vòstupn°ho souboru
         mov       word ptr ds:[SouborI2],0

; ------ nastaven° atributñ vòstupn°ho souboru

Start74: test      byte ptr ds:[Param],10h
         jnz       Start75                  ; je pouze test
         mov       dx,offset Soubor2        ; jmÇno vòstupn°ho souboru
         mov       cx,ds:[FileAtr]          ; atributy souboru
         mov       ax,4301h
         int       21h                      ; nastaven° atributñ souboru

; ------ p©°padnÇ zru®en° vstupn°ho programu a p©ejmenov†n° p©echodnÇho souboru

Start75: test      byte ptr ds:[Param],11h  ; zad†n vòstupn° soubor nebo test ?
         jnz       Start8                   ; je vòstupn° soubor nebo jen test

         mov       dx,offset Soubor1        ; jmÇno vstupn°ho souboru
         mov       ah,41h
         int       21h                      ; zru®en° vstupn°ho souboru
         jnc       Start76

         mov       dx,offset Soubor2        ; vòstupn° soubor
         mov       ah,41h
         int       21h                      ; zru®en° vòstupn°ho souboru

         mov       dx,offset DelTxt         ; text - nelze nahradit
         jmp       Chyba

Start76: mov       ah,56h
         mov       dx,offset Soubor2        ; jmÇno vòstupn°ho souboru
         push      ds
         pop       es
         mov       di,offset Soubor1        ; jmÇno vstupn°ho souboru
         int       21h                      ; p©ejmenov†n° souboru

Start8:
Start9:  mov       ax,4c00h
         int       21h

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                         Obsluha souboru COM
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

;˛

; -----------------------------------------------------------------------------
;        odstranàn° pojistky COM
; -----------------------------------------------------------------------------

DInsC    PROC      NEAR

; ------ test, zda je pojistka

         mov       dx,offset NoPojTxt       ; text - nen° pojistka
         test      byte ptr ds:[Param],4    ; je pojistka ?
         stc
         jz        DInsC9                   ; nen° pojistka - chyba

; ------ naáten° souboru do pamàti

DInsC1:  call      ReadCOM                  ; naáten° souboru do pamàti
         jnc       DInsC2
         ret                                ; chyba áten° souboru

; ------ n†vrat pñvodn°ch 3 bajtñ

DInsC2:  mov       si,es:[1]                ; offset skoku
         add       si,3-5                   ; zaá†tek pojistky
         mov       al,es:[si+2]
         mov       dx,es:[si+2+1]
         mov       es:[0],al
         mov       es:[1],dx

; ------ z†pis souboru na disk

         mov       cx,si                    ; dÇlka programu
         xor       si,si
         call      WritFile                 ; z†pis souboru na disk
DInsC9:  ret

DInsC    ENDP

; -----------------------------------------------------------------------------
;        test pojistky COM
; -----------------------------------------------------------------------------

TestC    PROC      NEAR

; ------ test, zda je pojistka

         mov       dx,offset NoPojTxt       ; text - nen° pojistka
         test      byte ptr ds:[Param],4    ; je pojistka ?
         stc
         jz        TestC9                   ; nen° pojistka - chyba

; ------ naáten° souboru do pamàti

         call      ReadCOM                  ; naáten° souboru do pamàti
         jnc       TestC2
         ret                                ; chyba áten° souboru

; ------ kontroln° souáet souboru v pamàti

TestC2:  mov       cx,ax                    ; dÇlka programu (bajtñ)
         shr       cx,1                     ; dÇlka programu s pojist.(slov)
         xor       si,si                    ; poá†teán° adresa programu
         mov       dx,cx                    ; vòchoz° hodnota CRC
         cld
TestC3:  mov       ax,es:[si]               ; naáten° slova
         inc       si
         inc       si
         rol       dx,1                     ; rotace o 1 bit vlevo
         xor       dx,ax                    ; p©iáten° slova
         loop      TestC3                   ; dal®° slovo

; ------ vyhodnocen° vòsledku testu souboru

TestC7:  jnz       TestC8                   ; kontroln° souáet nesouhlas°

         mov       dx,offset CRCOkTxt       ; kontroln° souáet OK
         mov       ah,9
         int       21h
         clc
         ret

TestC8:  mov       dx,offset CRCErTxt       ; text - soubor po®kozen
         stc                                ; p©°znak chyby
TestC9:  ret

TestC    ENDP

; -----------------------------------------------------------------------------
;        oprava pojistky COM
; -----------------------------------------------------------------------------

OprC     PROC      NEAR

; ------ test, zda je pojistka

         test      byte ptr ds:[Param],4    ; je pojistka ?
         jz        OprC1                    ; nen° pojistka
         jmp       DInsC1                   ; bàënÇ odstranàn° pojistky

; ------ naáten° souboru do pamàti

OprC1:   call      ReadCOM                  ; naáten° souboru do pamàti
         jnc       OprC2
         ret                                ; chyba áten° souboru

; ------ pokus o nalezen° pojistky v programu

OprC2:   mov       dx,offset FndTxt         ; text - nenalezena
         mov       si,ax                    ; dÇlka programu
         sub       si,20                    ; asi tak zaá†tek k testu
         jc        OprC9                    ; nenalezeno
OprC3:   cmp       word ptr es:[si],"JP"    ; je pojistka ?
         jne       OprC4                    ; nen° pojistka
         cmp       word ptr es:[si+OffsCOM],KODPAX+KODPBX*256 ; je PUSH AX/BX ?
         jne       OprC4                    ; nen° pojistka
         cmp       word ptr es:[si+OffsCOM+2],KODPCX+KODPDX*256 ; je PUSH CX/DX ?
         je        OprC6                    ; je pojistka OK
OprC4:   dec       si                       ; sn°ëen° ukazatele v souboru
         cmp       si,3                     ; minim†ln° offset
         jae       OprC3                    ; dal®° test
         jmp       short OprC9              ; nenalezeno

; ------ n†vrat pñvodn°ch 3 bajtñ

OprC6:   mov       al,es:[si+2]
         mov       dx,es:[si+2+1]
         mov       es:[0],al
         mov       es:[1],dx

; ------ z†pis souboru na disk

         mov       cx,si                    ; dÇlka programu
         xor       si,si
         call      WritFile                 ; z†pis souboru na disk
         jc        OprC9

; ------ zobrazen° hl†®en°

         mov       dx,offset VirTxt
         mov       ah,9
         int       21h
         clc
OprC9:   ret

OprC     ENDP

; -----------------------------------------------------------------------------
;        instalace pojistky COM
; -----------------------------------------------------------------------------

InstC    PROC      NEAR

; ------ test, zda je pojistka

         mov       dx,offset PojTxt         ; text - je jië pojistka
         test      byte ptr ds:[Param],4    ; je pojistka ?
         stc
         jnz       InstC1                   ; je pojistka - chyba

; ------ naáten° souboru do pamàti

         call      ReadCOM                  ; naáten° souboru do pamàti
         jnc       InstC2
InstC1:  ret                                ; chyba áten° souboru

; ------ kontrola velikosti souboru

InstC2:  mov       dx,offset SizTxt         ; text - nelze ochr†nit
         cmp       ax,offset(CojBeg-CojEnd)-100h ; asi tak maxim†ln° velikost
         cmc
         jc        InstC1                   ; nelze ochr†nit pojistkou

; ------ £schova zaá†tku programu

         mov       al,ds:[ExeHead]          ; prvn° bajt programu
         mov       dx,word ptr ds:[ExeHead+1] ; druhò a t©et° bajt programu
         mov       byte ptr ds:[PojOld],al  ; prvn° bajt programu
         mov       word ptr ds:[PojOld+1],dx ; 2. a 3. bajt programu
         mov       byte ptr ds:[CojOld],al  ; prvn° bajt programu
         mov       word ptr ds:[CojOld+1],dx ; 2. a 3. bajt programu

; ------ relokace adres v zavadàái

         mov       ax,ds:[SoubNum]          ; velikost souboru
         mov       cx,ax                    ; adresa konce
         mov       byte ptr es:[0],KODJMP   ; k¢d instrukce JMP NEAR
         add       cx,OffsCOM-3
         mov       word ptr es:[1],cx       ; offset skoku
         mov       cx,ax                    ; adresa konce

         sub       ax,offset(PojIdn-Start)  ; korekce adres
         mov       di,offset(PojEnd-PojBeg) ; dÇlka zavadàáe ve slovech
         mov       si,offset PojBeg         ; bàën† pojistka

         test      byte ptr ds:[Param],40h  ; je pokraáov†n° ?
         jz        InstC3                   ; nen° pokraáov†n°

         sub       ax,offset(CojIdn-Start) - offset(PojIdn-Start) ; korekce
         mov       di,offset(CojEnd-CojBeg) ; dÇlka zavadàáe ve slovech
         mov       si,offset CojBeg         ; pojistka s pokraáov†n°m

InstC3:  add       cx,di                    ; p©iáten° dÇlky zavadàáe
         inc       cx
         and       cx,not 1                 ; zaokrouhlen°
         mov       word ptr ds:[PojDelk2+1],cx ; dÇlka programu v bajtech
         mov       word ptr ds:[CojDelk2+1],cx ; dÇlka programu v bajtech
         shr       cx,1                     ; dÇlka programu ve slovech
         mov       word ptr ds:[PojDelk1+1],cx ; dÇlka programu ve slovech
         mov       word ptr ds:[CojDelk1+1],cx ; dÇlka programu ve slovech

         add       word ptr ds:[PojS2+1],ax
         add       word ptr ds:[PojS7+3],ax
         add       word ptr ds:[PojS8+1],ax
         sub       word ptr ds:[PojJMPSt+1],ax

         add       word ptr ds:[CojS2+1],ax
         add       word ptr ds:[CojS7+3],ax
         add       word ptr ds:[CojS8+1],ax
         sub       word ptr ds:[CojJMPSt+1],ax

; ------ p©enesen° zavadàáe do bufferu

         cld
         mov       cx,di                    ; dÇlka zavadàáe
         mov       di,ds:[SoubNum]          ; velikost
         rep       movsb                    ; p©enos zavadàáe do bufferu
         mov       al,0
         stosb
         and       di,not 1

; ------ vòpoáet kontroln°ho souátu souboru

InstC4:  push      ds
         mov       cx,di                    ; velikost souboru
         mov       ds,ds:[SoubSegm]
         xor       si,si
         shr       cx,1                     ; velikost souboru ve slovech
         mov       dx,cx                    ; vòchoz° hodnota CRC
         dec       cx                       ; kromà posledn°ho slova
         cld
InstC5:  lodsw                              ; naáten° slova
         rol       dx,1                     ; rotace o 1 bit vlevo
         xor       dx,ax                    ; p©iáten° slova
         loop      InstC5                   ; dal®° slovo
         rol       dx,1                     ; rotace
         mov       ds:[si],dx               ; kontroln° souáet
         pop       ds

; ------ uloëen° souboru na disk

         xor       si,si
         mov       cx,di                    ; velikost souboru
         call      WritFile                 ; z†pis bloku na disk

InstC9:  ret

InstC    ENDP

; -----------------------------------------------------------------------------
;        naáten° souboru COM do pamàti
; -----------------------------------------------------------------------------

ReadCOM  PROC      NEAR

         mov       es,ds:[SoubSegm]         ; datovò buffer
         xor       si,si                    ; offset v bufferu
         mov       cx,0ffffh                ; maxim†ln° velikost
         xor       bx,bx                    ; offset v souboru LOW
         xor       dx,dx                    ; offset v souboru HIGH
         call      ReadFile                 ; naáten° souboru do bufferu
         mov       ds:[SoubNum],ax          ; poáet bajtñ v bufferu
         ret

ReadCOM  ENDP


; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                         Obsluha souboru EXE
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

;˛

; -----------------------------------------------------------------------------
;        odstranàn° pojistky EXE
; -----------------------------------------------------------------------------

DInsX    PROC      NEAR

; ------ test, zda je pojistka

         test      byte ptr ds:[Param],4    ; je pojistka ?
         jnz       DInsX2                   ; je pojistka - OK
         mov       dx,offset NoPojTxt       ; text - nen° pojistka
DInsX1:  stc
         ret

; ------ uráen° novÇ vnit©n° velikosti programu

DInsX2:  mov       ax,ds:[ExeCS]
         mov       cx,16
         mul       cx
         mov       cx,ds:[ExeIP]
         sub       cx,OffsEXE
         add       ax,cx
         adc       dx,0                     ; pñvodn° velikost programu
         mov       word ptr ds:[ProgNSiz],ax ; pñvodn° velikost programu
         mov       word ptr ds:[ProgNSiz+2],dx

; ------ adresa relokaán° tabulky

         mov       si,offset OldPoj
         mov       cx,ds:[ExeIP]
         sub       cx,OffsEXE               ; poá†tek pojistky
         mov       bx,ds:[si+PojXRelT-PojXBeg] ; offset relokaán° tabulky
         sub       bx,cx
         add       ax,bx
         adc       dx,0
         add       ax,word ptr ds:[HeadSize]
         adc       dx,word ptr ds:[HeadSize+2]
         mov       word ptr ds:[RelAdr],ax
         mov       word ptr ds:[RelAdr+2],dx

; ------ pñvodn° velikost z†hlav° programu

         mov       ax,ds:[si+PojXRel-PojXBeg] ; pñvodn° poáet relokaán°ch pol.
         mov       ds:[ExeRNum],ax          ; n†vrat poátu relokaán°ch poloëek
         shl       ax,1
         shl       ax,1                     ; pñvodn° velikost relok. tabulky
         mov       ds:[RelokSiz],ax         ; velikost relokaán° tabulky
         xor       dx,dx
         add       ax,ds:[ExeXRel]          ; + offset relokaán° tabulky
         adc       dx,0
         mov       cx,ax
         and       ax,not 0fh               ; zarovn†n° na odstavec
         or        dx,dx
         jnz       DInsX3
         cmp       ax,word ptr ds:[Head2Adr]
         jae       DInsX3
         xor       cx,cx
         mov       ax,word ptr ds:[Head2Adr]
DInsX3:  add       ax,word ptr ds:[Head2Siz] ; p©iáten° 2. á†sti z†hlav°
         adc       dx,word ptr ds:[Head2Siz+2]
         mov       word ptr ds:[HeadNSiz],ax ; nov† velikost z†hlav°
         mov       word ptr ds:[HeadNSiz+2],dx

; ------ oprava adresy druhÇ á†sti hlaviáky

         and       cx,0fh
         sub       word ptr ds:[Head2Siz],cx
         sbb       word ptr ds:[Head2Siz+2],0
         add       word ptr ds:[Head2Adr],cx
         adc       word ptr ds:[Head2Adr+2],0

; ------ nov† zav†dàc° velikost programu

         add       ax,word ptr ds:[ProgNSiz]
         adc       dx,word ptr ds:[ProgNSiz+2]
         mov       word ptr ds:[LoadNSiz],ax ; nov† zav†dàc° velikost programu
         mov       word ptr ds:[LoadNSiz+2],dx

; ------ p©epoáet zav†dàc° velikosti na str†nky

         mov       cx,ax
         and       cx,1ffh
         mov       ds:[ExeLast],cx          ; poáet bajtñ v posledn° str†nce
         add       ax,511
         adc       dx,0
         mov       cx,512
         and       dx,1ffh
         div       cx
         mov       ds:[ExePage],ax          ; poáet str†nek 512 bajtñ

; ------ nastaven° novÇ velikosti z†hlav°

         mov       ax,word ptr ds:[HeadNSiz]
         mov       dx,word ptr ds:[HeadNSiz+2]
         add       ax,0fh
         adc       dx,0
         mov       cx,16
         and       dx,0fh
         div       cx
         mov       ds:[ExeHSize],ax         ; velikost z†hlav°

; ------ n†vrat pñvodn°ch parametrñ programu

         mov       ax,ds:[si+PojXSP-PojXBeg] ; pñvodn° registr SP
         mov       ds:[ExeSP],ax            ; n†vrat registru SP
         mov       ax,ds:[si+PojXSS-PojXBeg] ; pñvodn° registr SS
         mov       ds:[ExeSS],ax            ; n†vrat registru SS
         mov       ax,ds:[si+PojXIP-PojXBeg] ; pñvodn° registr IP
         mov       ds:[ExeIP],ax            ; n†vrat registru IP
         mov       ax,ds:[si+PojXCS-PojXBeg] ; pñvodn° registr CS
         mov       ds:[ExeCS],ax            ; n†vrat registru CS
         mov       ax,ds:[si+PojXMin-PojXBeg] ; pñvodn° minim†ln° pamàü
         mov       ds:[ExeMin],ax           ; n†vrat minim†ln° pamàti

; ------ z†pis novÇho z†hlav° na disk

         mov       si,offset ExeHead
         mov       cx,28                    ; dÇlka z†hlav°
         push      ds
         pop       es
         call      WritFile                 ; z†pis z†hlav° na disk
         jnc       DInsX5
DInsX4:  ret

; ------ kopie prvn° á†sti z†hlav°

DInsX5:  xor       dx,dx
         mov       bx,28
         xor       di,di
         mov       cx,ds:[ExeXRel]
         sub       cx,bx                    ; velikost prvn° á†sti z†hlav°
         call      CopyFile                 ; kopie prvn° á†sti z†hlav°
         jc        DInsX4

; ------ kopie relokaán° tabulky

         mov       bx,word ptr ds:[RelAdr]  ; adresa relokaán° tabulky
         mov       dx,word ptr ds:[RelAdr+2]
         mov       cx,ds:[RelokSiz]         ; velikost relokaán° tabulky
         xor       di,di
         call      CopyFile                 ; kopie relokaán° tabulky
         jc        DInsX4

; ------ kopie p©°padnÇho zbytku prvn° á†sti z†hlav°

         mov       bx,ds:[ExeXRel]
         xor       dx,dx
         add       bx,cx
         adc       dx,di
         mov       cx,word ptr ds:[Head2Adr]
         mov       di,word ptr ds:[Head2Adr+2]
         sub       cx,bx
         sbb       di,dx
         jc        DInsX6
         call      CopyFile
         jc        DInsX4

; ------ kopie druhÇ á†sti z†hlav°

DInsX6:  mov       bx,word ptr ds:[Head2Adr] ; adresa druhÇ á†sti hlaviáky
         mov       dx,word ptr ds:[Head2Adr+2]
         mov       cx,word ptr ds:[Head2Siz] ; velikost druhÇ á†sti hlaviáky
         mov       di,word ptr ds:[Head2Siz+2]
         call      CopyFile                 ; kopie druhÇ á†sti hlaviáky
         jc        DInsX4

; ------ kopie tàla programu

         mov       bx,word ptr ds:[HeadSize] ; adresa za hlaviákou
         mov       dx,word ptr ds:[HeadSize+2]
         mov       cx,word ptr ds:[ProgNSiz] ; nov† velikost programu
         mov       di,word ptr ds:[ProgNSiz+2]
         call      CopyFile                 ; kopie tàla programu
         jc        DInsX4

; ------ kopie dat za programem

         mov       bx,word ptr ds:[LoadSize]
         mov       dx,word ptr ds:[LoadSize+2]
         mov       cx,word ptr ds:[OvlSize]
         mov       di,word ptr ds:[OvlSize+2]
         call      CopyFile                 ; zkop°rov†n° dat za programem
         jc        DInsX9

; ------ hl†®en° o odstranàn° pojistky

         test      byte ptr ds:[Param],20h
         jz        DInsX9                   ; nebyla oprava
         mov       dx,offset VirTxt
         mov       ah,9
         int       21h
         clc
DInsX9:  ret

DInsX    ENDP

; -----------------------------------------------------------------------------
;        test pojistky EXE
; -----------------------------------------------------------------------------

TestX    PROC      NEAR

; ------ test, zda je pojistka

         test      byte ptr ds:[Param],4    ; je pojistka ?
         jnz       TestX2                   ; je pojistka - OK
         mov       dx,offset NoPojTxt       ; text - nen° pojistka
         stc
TestX1:  ret

; ------ p©°prava k testu

TestX2:  mov       di,word ptr ds:[ProgSize+2]; velikost HIGH
         mov       bp,word ptr ds:[ProgSize] ; velikost LOW
         mov       bx,word ptr ds:[HeadSize] ; poá†teán° offset programu
         mov       dx,word ptr ds:[HeadSize+2]
         xor       ax,ax                    ; vòchoz° hodnota CRC
         mov       es,ds:[SoubSegm]         ; segment dat

; ------ uráen° velikosti bloku dat

TestX4:  mov       cx,0f000h
         or        di,di
         jnz       TestX5
         cmp       cx,bp
         jbe       TestX5
         mov       cx,bp
TestX5:  jcxz      TestX8                   ; konec dat

; ------ naáten° bloku programu

         xor       si,si                    ; offset v bufferu
         call      ReadFil0                 ; naáten° bloku dat
         jc        TestX1                   ; chyba áten°

; ------ posuny ukazatelñ

         add       bx,cx
         adc       dx,0
         sub       bp,cx
         sbb       di,0

; ------ kontroln° souáet bloku programu

         shr       cx,1                     ; dÇlka programu s pojist.(slov)
TestX6:  rol       ax,1                     ; rotace o 1 bit vlevo
         xor       ax,es:[si]
         inc       si
         inc       si
         loop      TestX6                   ; dal®° slovo
         jmp       short TestX4

; ------ vyhodnocen° vòsledku testu souboru

TestX8:  or        ax,ax                    ; je vòsledek = 0 ?
         jmp       TestC7                   ; vyhodnocen° vòsledku

;         jz        TestX9                   ; kontroln° souáet je OK
;         mov       dx,offset CRCErTxt       ; text - soubor po®kozen
;         stc                                ; p©°znak chyby
;TestX9:  ret

TestX    ENDP

; -----------------------------------------------------------------------------
;        oprava pojistky EXE
; -----------------------------------------------------------------------------

OprX     PROC      NEAR

; ------ test, zda je pojistka

         test      byte ptr ds:[Param],4    ; je pojistka ?
         jz        OprX1                    ; nen° pojistka
         xor       byte ptr ds:[Param],28h  ; zmàna na poëadavek odpojistkov†n°
         jmp       DInsX                    ; bàënÇ odstranàn° pojistky

; ------ p©°prava k vyhled†n° pojistky

OprX1:   mov       bp,word ptr ds:[ProgSize] ; vnit©n° velikost programu
         mov       di,word ptr ds:[ProgSize+2]
         mov       bx,word ptr ds:[HeadSize] ; velikost z†hlav°
         mov       dx,word ptr ds:[HeadSize+2]
         add       bx,bp                    ; adresa konce za programem
         adc       dx,di

; ------ velikost bloku k prohled†n°

         mov       cx,0ff00h
         or        di,di
         jnz       OprX2
         cmp       cx,bp
         jb        OprX2
         mov       cx,bp                    ; omezen° velikosti bloku
OprX2:   sub       bx,cx
         sbb       dx,0

; ------ naáten° bloku do pamàti

         mov       es,ds:[SoubSegm]
         xor       si,si
         call      ReadFil0                 ; naáten° souboru do pamàti
         jc        OprX9

; ------ prohled†n° bloku v pamàti

         mov       si,cx
         sub       si,100
         jbe       OprX8
OprX3:   cmp       word ptr es:[si],"JP"    ; je pojistka ?
         jne       OprX4                    ; nen° pojistka
         cmp       word ptr es:[si+OffsEXE],KODPAX+KODPBX*256 ; je PUSH AX/BX ?
         jne       OprX4                    ; nen° pojistka
         cmp       word ptr es:[si+OffsEXE+2],KODPCX+KODPDX*256 ; je PUSH CX/DX ?
         je        OprX6                    ; je pojistka OK
OprX4:   dec       si                       ; sn°ëen° ukazatele v souboru
         jne       OprX3
         jmp       short OprX8

; ------ pojistka nalezena - nastaven° ukazatelñ

OprX6:   add       bx,si                    ; offset v souboru
         adc       dx,0
         push      dx
         mov       ax,bx
         sub       ax,word ptr ds:[HeadSize] ; odeáten° z†hlav°
         sbb       dx,word ptr ds:[HeadSize+2]
         mov       cx,16
         and       dx,0fh
         div       cx                       ; p©epoáet na segment:offset
         add       dx,OffsEXE
         mov       ds:[ExeCS],ax
         mov       ds:[ExeIP],dx
         pop       dx

; ------ naáten° zaá†tku pojistky

         or        byte ptr ds:[Param],4    ; p©°znak nalezen° pojistky
         mov       cx,32                    ; velikost bufferu
         push      ds
         pop       es
         mov       si,offset OldPoj         ; buffer k naáten° starÇ pojistky
         call      ReadFil0                 ; naáten° zaá†tku pojistky
         jc        OprX9                    ; chyba áten°
         jmp       DInsX2                   ; odinstalov†n° pojistky

; ------ pojistka nenalezena

OprX8:   mov       dx,offset FndTxt
         stc
OprX9:   ret

OprX     ENDP

; -----------------------------------------------------------------------------
;        instalace pojistky EXE
; -----------------------------------------------------------------------------
;˛
InstX    PROC      NEAR

; ------ test, zda je pojistka

         test      byte ptr ds:[Param],4    ; je pojistka ?
         jz        InstX2                   ; nen° pojistka - OK
         mov       dx,offset PojTxt         ; text - je jië pojistka
InstX0:  stc
InstX1:  ret                                ; chyba áten° souboru

; ------ £schova pñvodn°ch parametrñ programu

InstX2:  mov       ax,ds:[ExeSP]
         mov       ds:[PojXSP],ax           ; registr SP
         mov       ds:[CojXSP],ax           ; registr SP
         mov       ax,ds:[ExeSS]
         mov       ds:[PojXSS],ax           ; registr SS
         mov       ds:[CojXSS],ax           ; registr SS
         mov       ax,ds:[ExeIP]
         mov       ds:[PojXIP],ax           ; registr IP
         mov       ds:[CojXIP],ax           ; registr IP
         mov       ax,ds:[ExeCS]
         mov       ds:[PojXCS],ax           ; registr CS
         mov       ds:[CojXCS],ax           ; registr CS
         mov       ax,ds:[ExeMin]
         mov       ds:[PojXMin],ax          ; minim†ln° pamàü
         mov       ds:[CojXMin],ax          ; minim†ln° pamàü
         mov       ax,ds:[ExeRNum]          ; poáet poloëek relokaán° tabulky
         mov       ds:[PojXRel],ax          ; poáet poloëek relok. tabulky
         mov       ds:[CojXRel],ax          ; poáet poloëek relok. tabulky

; ------ kontrola relokaán° tabulky

         mov       word ptr ds:[PojXRel1+1],ax ; poáet relok. poloëek
         mov       word ptr ds:[CojXRel1+1],ax ; poáet relok. poloëek
         add       word ptr ds:[PojXRel1+1],2
         add       word ptr ds:[CojXRel1+1],2
         cmp       ax,4000h-100h            ; asi tak maxim†ln° poáet poloëek
         jbe       InstX22
InstX21: mov       dx,offset SizTxt         ; text - nelze ochr†nit
         jmp       short InstX0

; ------ adresa poá†tku pojistky v programu

InstX22: mov       ax,word ptr ds:[ProgSize] ; velikost programu
         mov       dx,word ptr ds:[ProgSize+2]
         mov       cx,16                    ; dàlitel pro p©evod
         div       cx                       ; vòpoáet adresy pojistky
         mov       word ptr ds:[PojAdr],dx  ; offset adresy pojistky
         mov       word ptr ds:[PojAdr+2],ax ; segment adresy pojistky

; ------ nov† velikost z†hlav° programu

         mov       ax,word ptr ds:[Head2Siz] ; velikost druhÇ á†sti hlaviáky LOW
         mov       dx,word ptr ds:[Head2Siz+2]
         add       ax,ds:[Head1Siz]         ; p©iáten° 1. á†sti hlaviáky
         adc       dx,0                     ; p©enos
         and       dx,0fh                   ; poji®tàn°
         mov       cx,16                    ; dàlitel
         div       cx                       ; p©epoáet velikosti na odstavce
         mov       ds:[ExeHSize],ax         ; nov† velikost z†hlav° programu

; ------ novò poáet poloëek relokaán° tabulky

         mov       word ptr ds:[ExeRNum],0  ; nen° ë†dn† relokaán° poloëka

; ------ velikost pojistky s relokaán° tabulkou + CRC

         mov       ax,offset(PojXEnd-PojXBeg) ; z†kladn° velikost pojistky
         test      byte ptr ds:[Param],40h  ; je pokraáov†n° ?
         jz        InstX32                  ; nen° pokraáov†n°
         mov       ax,offset(CojXEnd-CojXBeg) ; pojistka s pokraáov†n°m
InstX32: add       ax,ds:[RelokSiz]         ; p©iáten° relokaán° tabulky
         mov       ds:[PojSize],ax          ; velikost pojistky s rel. tab.

; ------ nov† velikost programu

         xor       dx,dx
         inc       ax                       ; p©°prava pro zaokrouhlen°
         add       ax,word ptr ds:[ProgSize] ; p©iáten° velikosti programu
         adc       dx,word ptr ds:[ProgSize+2]
         and       ax,not 1                 ; zaokrouhlen° na sudou velikost
         mov       word ptr ds:[ProgNSiz],ax ; nov† velikost programu LOW
         mov       word ptr ds:[ProgNSiz+2],dx ; nov† velikost programu HIGH

; ------ nov† zav†dàc° velikost programu

         add       ax,ds:[Head1Siz]         ; p©iáten° 1. á†sti hlaviáky
         adc       dx,0
         add       ax,word ptr ds:[Head2Siz] ; p©iáten° 2. á†sti hlaviáky
         adc       dx,word ptr ds:[Head2Siz+2]
         mov       word ptr ds:[LoadNSiz],ax ; nov† zav†dàc° velikost
         mov       word ptr ds:[LoadNSiz+2],dx

; ------ nov† velikost souboru

         add       ax,word ptr ds:[OvlSize] ; p©iáten° datovÇ á†sti
         adc       dx,word ptr ds:[OvlSize+2]
         mov       word ptr ds:[SoubNSiz],ax ; nov† velikost souboru
         mov       word ptr ds:[SoubNSiz+2],dx
         mov       word ptr ds:[PojXDlk3+1],ax ; velikost programu
         mov       word ptr ds:[CojXDlk3+1],ax ; velikost programu

; ------ vòpoáet zav†dàc° velikosti ve str†nk†ch

         mov       ax,word ptr ds:[LoadNSiz] ; nov† zav†dàc° velikost
         mov       dx,word ptr ds:[LoadNSiz+2]
         mov       cx,ax
         and       cx,1ffh                  ; velikost v posledn° str†nce
         mov       ds:[ExeLast],cx          ; velikost posledn° str†nky
         add       ax,511                   ; zaokrouhlen° na 512 str†nky
         adc       dx,0
         and       dx,1ffh                  ; pojistka
         mov       cx,512
         div       cx                       ; vòpoáet poátu str†nek 512 B
         mov       ds:[ExePage],ax          ; poáet str†nek 512 B

; ------ startovac° adresa pojistky

         mov       ax,word ptr ds:[PojAdr]  ; offset pojistky
         mov       dx,word ptr ds:[PojAdr+2] ; segment pojistky
         mov       ds:[ExeCS],dx            ; segment CS
         add       ax,OffsEXE               ; offset zaá†tku pojistky
         mov       ds:[ExeIP],ax            ; offset IP

; ------ nastaven° segmentovòch adres v pojistce

         mov       word ptr ds:[PojXAdr4+4],dx ; kontrolovan† adresa CS
         mov       word ptr ds:[PojXRSS+2],dx ; relokaán° adresa SS
         mov       word ptr ds:[PojXRCS+2],dx ; relokaán° adresa CS

         mov       word ptr ds:[CojXAdr4+4],dx ; kontrolovan† adresa CS
         mov       word ptr ds:[CojXRSS+2],dx ; relokaán° adresa SS
         mov       word ptr ds:[CojXRCS+2],dx ; relokaán° adresa CS

; ------ adresa z†sobn°ku

         mov       ax,ds:[PojSize]          ; velikost pojistky
         mov       cl,4
         shr       ax,cl                    ; p©evod na odstavce
         add       ax,10h                   ; trochu rezerva
         mov       bx,ax                    ; £schova velikosti pojistky
         add       ax,word ptr ds:[PojAdr+2] ; segment z†sobn°ku
         mov       ds:[ExeSS],ax            ; adresa z†sobn°ku
         mov       word ptr ds:[ExeSP],400h ; offset z†sobn°ku

; ------ stanoven° minim†ln° poëadovanÇ pamàti

         mov       ax,ds:[ExeMin]           ; pñvodn° rezerva m°sta
         sub       ax,bx                    ; odeáten° pojistky
         jnc       InstX42
         xor       ax,ax
InstX42: cmp       ax,40h                   ; je m°sto pro z†sobn°k ?
         jae       InstX43                  ; je dost m°sta
         mov       ax,40h                   ; minim†lnà pro z†sobn°k
InstX43: mov       ds:[ExeMin],ax           ; nov† poëadovan† pamàü

; ------ relokace adres v pojistce

         mov       si,offset PojXTab
         cld
         mov       dx,word ptr ds:[PojAdr]  ; offset poá†tku pojistky
         mov       cx,(offset(CojXTab0-PojXTab))/2 ; poáet poloëek v tabulce
InstX46: lodsw                              ; adresa poloëky k relokaci
         mov       di,ax                    ; adresa poloëky
         add       word ptr ds:[di],dx      ; relokace adresy
         loop      InstX46                  ; dal®° poloëka

; ------ registry pro vòpoáet kontroln°ho souátu

         mov       ax,word ptr ds:[ProgNSiz] ; skuteán† velikost programu
         mov       dx,word ptr ds:[ProgNSiz+2]
         mov       cx,ax                    ; £schova velikosti
         add       ax,0ffffh
         adc       dx,0                     ; zaokrouhlen† velikost
         mov       word ptr ds:[PojXDel1+1],dx ; poáet blokñ 64 KB (i necelòch)
         mov       word ptr ds:[CojXDel1+1],dx ; poáet blokñ 64 KB (i necelòch)
         shr       cx,1                     ; velikost posledn°ho bloku
         jnz       instX47
         mov       cx,8000h
InstX47: mov       word ptr ds:[PojXDel2+1],cx ; velikost dat v posledn°m bloku
         mov       word ptr ds:[CojXDel2+1],cx ; velikost dat v posledn°m bloku

; ====== uloëen° souboru na disk

; ------ z†pis zaá†tku z†hlav° do souboru

         push      ds
         pop       es
         mov       si,offset ExeHead        ; z†hlav°
         mov       cx,28                    ; dÇlka z†hlav°
         call      WritFile                 ; z†pis z†hlav° do souboru
         jnc       InstX49                  ; operace OK
InstX48: ret

; ------ kopie prvn° á†sti hlaviáky

InstX49: mov       bx,cx                    ; offset poá†tku z†hlav° v souboru
         xor       dx,dx
         mov       cx,ds:[Head1Siz]         ; velikost prvn° á†sti z†hlav°
         sub       cx,bx                    ; odeáten° jië naátenÇho z†hlav°
         xor       di,di
         call      CopyFile                 ; zkop°rov†n° zaá†tku z†hlav°
         jc        InstX48

; ------ kopie druhÇ á†sti hlaviáky

         mov       bx,word ptr ds:[Head2Adr] ; offset zaá†tku 2. á†sti hlaviáky
         mov       dx,word ptr ds:[Head2Adr+2]
         mov       cx,word ptr ds:[Head2Siz] ; velikost 2. á†sti hlaviáky
         mov       di,word ptr ds:[Head2Siz+2]
         call      CopyFile                 ; zkop°rov†n° 2. á†sti hlaviáky
         jc        InstX48

; ------ zkop°rov†n° samotnÇho programu

         xor       ax,ax                    ; vòchoz° hodnota kontr. souátu
         add       bx,cx                    ; offset zaá†tku programu
         adc       dx,di
         mov       cx,word ptr ds:[ProgSize] ; velikost programu
         mov       di,word ptr ds:[ProgSize+2]
         and       cx,not 1                 ; kromà lichÇho bajtu
         call      CopyFile                 ; kopie samotnÇho programu
         jc        InstX48                  ; chyba

; ------ naáten° lichÇho bajtu do bufferu

         xor       si,si                    ; poá†teán° adresa v bufferu
         mov       es,ds:[SoubSegm]         ; buffer
         test      byte ptr ds:[ProgSize],1 ; je lich† velikost programu ?
         jz        InstX51                  ; je sud† velikost programu
         add       bx,cx
         adc       dx,di                    ; offset lichÇho bajtu
         mov       cx,1                     ; áten° 1 bajtu
         xor       di,di
         call      ReadFil0                 ; naáten° 1 bajtu
         jc        InstX48
         inc       si                       ; poá†teán° adresa = 1

; ------ p©enos zavadàáe do bufferu

InstX51: mov       di,si                    ; ukl†dac° adresa v bufferu
         mov       si,offset PojXBeg        ; zavadàá
         mov       cx,offset(PojXCRC-PojXBeg) ; dÇlka zavadàáe (po CRC)
         test      byte ptr ds:[Param],40h  ; je s pokraáov†n°m ?
         jz        InstX512
         mov       si,offset CojXBeg        ; zavadàá
         mov       cx,offset(CojXCRC-CojXBeg) ; dÇlka zavadàáe (po CRC)
InstX512:cld
         rep       movsb                    ; p©enos zavadàáe do bufferu

; ------ naáten° relokaán° tabulky

         mov       si,di                    ; adresa k naáten° tabulky
         mov       bx,ds:[ExeXRel]          ; offset relokaán° tabulky
         xor       dx,dx
         mov       cx,ds:[RelokSiz]         ; velikost relokaán° tabulky
         call      ReadFil0                 ; naáten° relokaán° tabulky
         jc        InstX528                 ; chyba

; ------ adresa konce zavadàáe

         add       si,cx                    ; adresa konce dat v bufferu
         mov       byte ptr es:[si],0       ; p©°padn† lich† 0
         inc       si                       ; p©°prava pro zaokrouhlen°
;         and       si,not 1                 ; zarovn†n° na sudou adresu

; ------ vòpoáet kontroln°ho souátu zavadàáe (s relokaán° tabulkou)

         mov       cx,si                    ; velikost zavadàáe (bajtñ)
         shr       cx,1                     ; velikost souboru ve slovech
         xor       si,si                    ; poá†teán° adresa
         cld
InstX52: rol       ax,1                     ; rotace o 1 bit vlevo
         xor       ax,es:[si]               ; p©iáten° slova
         inc       si
         inc       si
         loop      InstX52                  ; dal®° slovo
         rol       ax,1                     ; rotace
         mov       es:[si],ax               ; kontroln° souáet
         inc       si
         inc       si                       ; adresa konce

; ------ uloëen° zavadàáe do souboru

         mov       cx,si                    ; dÇlka
         xor       si,si                    ; poá†teán° adresa
         call      WritFile                 ; z†pis do souboru
         jc        InstX528                 ; chyba z†pisu

; ------ kopie dat za programem

         mov       cx,word ptr ds:[OvlSize] ; velikost dat LOW
         mov       di,word ptr ds:[OvlSize+2] ; velikost dat HIGH
         mov       bx,word ptr ds:[LoadSize] ; offset dat LOW
         mov       dx,word ptr ds:[LoadSize+2] ; offset dat HIGH
         call      CopyFile                 ; zkop°rov†n° dat za programem
InstX528:ret

InstX    ENDP

; -----------------------------------------------------------------------------
;        inicializace parametrñ programu EXE
; -----------------------------------------------------------------------------

InitXPar PROC      NEAR

; ------ velikost relokaán° tabulky

         mov       ax,ds:[ExeRNum]          ; poáet poloëek relokaán° tabulky
         shl       ax,1
         shl       ax,1                     ; velikost rel. tab. (bajtñ)
         mov       ds:[RelokSiz],ax         ; velikost relokaán° tabulky

; ------ velikost hlaviáky programu

         mov       ax,ds:[ExeHSize]         ; velikost z†hlav° (odstavcñ)
         cmp       ax,2
         jae       InitXP2
         mov       ax,2                     ; omezen° na minim†lnà 2 odstavce
InitXP2: mov       cx,16
         mul       cx                       ; p©epoáet na bajty
         mov       word ptr ds:[HeadSize],ax ; velikost z†hlav° LOW
         mov       word ptr ds:[HeadSize+2],dx ; velikost z†hlav° HIGH

; ------ velikost zav†dànÇ á†sti

         mov       bx,ds:[ExeLast]          ; dÇlka posledn° str†nky 512 B
         mov       ax,ds:[ExePage]          ; poáet str†nek 512 bajtñ
         or        bx,bx                    ; jsou data v posledn° str†nce ?
         jz        InitXP3                  ; nejsou data v posledn° str†nce
         dec       ax                       ; kromà posledn° str†nky
InitXP3: mov       dx,512                   ; dÇlka 1 str†nky
         mul       dx                       ; p©epoáet str†nek na bajty
         add       ax,bx                    ; p©iáten° posledn° str†nky
         adc       dx,0                     ; p©enos
         mov       word ptr ds:[LoadSize],ax ; zav†dàn† velikost souboru LOW
         mov       word ptr ds:[LoadSize+2],dx ; zav†dàn† velikost souboru HIGH

; ------ velikost zav†dànÇho programu

         sub       ax,word ptr ds:[HeadSize] ; odeáten° z†hlav°
         sbb       dx,word ptr ds:[HeadSize+2]
         jnc       InitXP4
         xor       ax,ax
         xor       dx,dx
InitXP4: mov       word ptr ds:[ProgSize],ax ; velikost programu
         mov       word ptr ds:[ProgSize+2],dx

; ------ celkov† velikost souboru

         xor       cx,cx
         xor       dx,dx
         mov       bx,ds:[SouborI1]         ; vstupn° soubor
         mov       ax,4202h
         int       21h                      ; vystaven° ukazatele na konec
         mov       word ptr ds:[SoubSize],ax ; velikost souboru LOW
         mov       word ptr ds:[SoubSize+2],dx ; velikost souboru HIGH

; ------ velikost dat za programem

         sub       ax,word ptr ds:[LoadSize] ; odeáten° zav†dànÇ á†sti
         sbb       dx,word ptr ds:[LoadSize+2]
         jnc       InitXP5
         xor       ax,ax
         xor       dx,dx
InitXP5: mov       word ptr ds:[OvlSize],ax
         mov       word ptr ds:[OvlSize+2],dx

; ------ kontrola offsetu relokaán° tabulky

         mov       ax,ds:[ExeRelok]         ; adresa relokaán° tabulky
         cmp       ax,28
         jae       InitXP6                  ; adresa OK
         mov       ax,28
InitXP6: cmp       word ptr ds:[HeadSize+2],0
         jne       InitXP7
         cmp       ax,word ptr ds:[HeadSize]
         jbe       InitXP7
         mov       ax,word ptr ds:[HeadSize]
InitXP7: mov       ds:[ExeXRel],ax          ; opravenò offset relokaán° tabulky

; ------ velikost prvn° á†sti hlaviáky (po relokaán° tabulku)

         mov       cx,ax                    ; £schova adresy
         add       ax,15                    ; zaokrouhlen° nahoru
         and       ax,not 0fh               ; zarovn†n° na odstavce
         jnz       InitXP8
         mov       ax,0fff0h
InitXP8: mov       ds:[Head1Siz],ax         ; velikost prvn° á†sti hlaviáky

; ------ adresa druhÇ á†sti hlaviáky

         xor       bx,bx
         add       cx,ds:[RelokSiz]         ; p©iáten° relokaán° tabulky
         adc       bx,0                     ; p©enos
         and       cx,not 0fh               ; zaokrouhlen° 2. á†sti dolñ
         or        bx,bx
         jnz       InitXP9
         cmp       cx,ax
         jae       InitXP9
         mov       cx,ax                    ; omezen° zaá†tku p©i m†lo poloëk†ch
InitXP9: mov       word ptr ds:[Head2Adr],cx ; adresa druhÇ á†sti relok. tab.
         mov       word ptr ds:[Head2Adr+2],bx

; ------ velikost druhÇ á†sti hlaviáky

         mov       ax,word ptr ds:[HeadSize] ; velikost hlaviáky LOW
         mov       dx,word ptr ds:[HeadSize+2] ; velikost hlaviáky HIGH
         sub       ax,cx
         sbb       dx,bx                    ; odeáten° poá†tku druhÇ á†sti hlav.
         jnc       InitXPA
         xor       ax,ax
         xor       dx,dx
InitXPA: mov       word ptr ds:[Head2Siz],ax ; velikost druhÇ á†sti hlaviáky LOW
         mov       word ptr ds:[Head2Siz+2],dx

         ret

InitXPar ENDP

; -----------------------------------------------------------------------------
;        inicializace pamàti (CY=nedostatek pamàti)
; -----------------------------------------------------------------------------

InitMem  PROC      NEAR

; ------ zmen®en° velikosti programu na minimum

         mov       bx,(offset(Zasob-Start)+10fh)/16 ; dÇlka programu
         mov       ah,4ah
         int       21h                      ; zmen®en° velikosti programu
         jc        InitMem9                 ; chyba pamàti

; ------ vytvo©en° datovÇho bufferu

         mov       bx,1000h                 ; velikost bloku 64 KB
         mov       ah,48h
         int       21h                      ; vytvo©en° datovÇho bufferu
         jc        InitMem9                 ; chyba - nedostatek pamàti
         mov       ds:[SoubSegm],ax         ; adresa datovÇho bufferu

InitMem9:ret

InitMem  ENDP

; -----------------------------------------------------------------------------
;        sestaven° jmÇna p©echodnÇho souboru
; -----------------------------------------------------------------------------

InitOut  PROC      NEAR

; ------ test, zda byl vòstupn° soubor zad†n

         test      byte ptr ds:[Param],1    ; byl vòstupn° soubor zad†n ?
         jnz       InitOut9                 ; vòstupn° soubor byl zad†n

; ------ n†hrada p©°pony p©echodnou p©°ponou "$$$"

         mov       si,ds:[SouborE2]         ; adresa p©°pony jmÇna souboru
         mov       word ptr ds:[si],"$$"
InitOut1:mov       word ptr ds:[si+2],"$"   ; n†hrada p©°ponou "$$$"

; ------ test, zda p©echodnò soubor existuje

InitOut2:mov       dx,offset Soubor2        ; jmÇno vòstupn°ho souboru
         mov       ah,4eh
         mov       cx,3fh                   ; atributy
         int       21h                      ; test, zda soubor existuje
         jc        InitOut3                 ; soubor neexistuje

; ------ zvò®en° á°sla p©°pony

         push      si
InitOu22:cmp       byte ptr ds:[si+2],"$"
         jne       InitOu21
         mov       byte ptr ds:[si+2],"0"
InitOu21:inc       byte ptr ds:[si+2]
         cmp       byte ptr ds:[si+2],"9"
         jne       InitOu24
         mov       byte ptr ds:[si+2],"0"
         dec       si
         jmp       short InitOu22
InitOu24:pop       si
         jmp       short InitOut2

InitOut3:

InitOut9:ret

InitOut  ENDP

; -----------------------------------------------------------------------------
;        test souboru, zda je typu EXE (CY=chyba áten° ze souboru)
; -----------------------------------------------------------------------------

TestExe  PROC      NEAR

; ------ naáten° z†hlav° ze souboru

         push      ds
         pop       es
         xor       dx,dx                    ; offset v souboru HIGH
         xor       bx,bx                    ; offset v souboru LOW
         mov       si,offset ExeHead        ; zaá†tek z†hlav°
         mov       cx,offset(ExeHead0-ExeHead) ; dÇlka z†hlav°
         call      ReadFile                 ; naáten° z†hlav° souboru
         jc        TestExe3                 ; nàjak† chyba

; ------ test, zda je to program EXE

         cmp       ax,cx                    ; poáet naátenòch bajtñ
         jb        TestExe2                 ; nen° program EXE
         cmp       word ptr ds:[ExeIdnt],"MZ" ; je to EXE ?
         je        TestExe1                 ; je to EXE
         cmp       word ptr ds:[ExeIdnt],"ZM"
         jne       TestExe2                 ; nen° to EXE

TestExe1:or        byte ptr ds:[Param],2    ; p©°znak programu EXE

TestExe2:clc
TestExe3:ret

TestExe  ENDP

; -----------------------------------------------------------------------------
;        test, zda je program jië chr†nàn pojistkou
; -----------------------------------------------------------------------------

TestPoj  PROC      NEAR

; ------ rozli®en°, zda je soubor COM nebo EXE

         test      byte ptr ds:[Param],2    ; je program typu EXE ?
         jnz       TestPoj4                 ; program je typu EXE

; ------ test programu COM, zda zaá°n† instrukc° JMP NEAR

         cmp       byte ptr ds:[ExeHead],KODJMP ; je instrukce JMP NEAR ?
         jne       TestPoj8                 ; nen° instrukce JMP NEAR

; ------ uráen° offset zaá†tku p©°padnÇ pojistky

         mov       bx,word ptr ds:[ExeHead+1] ; offset instrukce JMP
         add       bx,3-OffsCOM             ; korekce offsetu v souboru
         xor       dx,dx                    ; offset v souboru HIGH
         mov       di,OffsCOM               ; offset instrukc° PUSH AX/BX
         jmp       short TestPoj6           ; test pojistky

; ------ uráen° adresy zaá†tku pojistky v programu EXE

TestPoj4:mov       ax,ds:[ExeCS]            ; registr CS
         add       ax,ds:[ExeHSize]         ; p©iáten° velikosti z†hlav°
         mov       cx,16
         mul       cx                       ; p©epoáet na offset
         add       ax,ds:[ExeIP]            ; p©iáten° offsetu
         adc       dx,0                     ; p©enos HIGH
         sub       ax,OffsEXE               ; odeáten° z†hlav° pojistky
         sbb       dx,0                     ; p©enos HIGH
         mov       bx,ax                    ; offset LOW
         mov       di,OffsEXE               ; offset instrukc° PUSH AX/BX

; ------ naáten° zaá†tku p©°padnÇ pojistky

TestPoj6:mov       cx,32                    ; velikost bufferu
         push      ds
         pop       es
         mov       si,offset OldPoj         ; buffer k naáten° starÇ pojistky
         call      ReadFile                 ; naáten° zaá†tku pojistky
         jc        TestPoj9                 ; chyba áten°

; ------ kontrola, zda je to pojistka

         mov       bx,di                    ; offset instrukc° PUSH AX/BX
         cmp       word ptr ds:[si],"JP"    ; je pojistka ?
         jne       TestPoj8                 ; nen° pojistka
         cmp       word ptr ds:[si+bx],KODPAX+KODPBX*256 ; je PUSH AX/BX ?
         jne       TestPoj8                 ; nen° pojistka
         cmp       word ptr ds:[si+bx+2],KODPCX+KODPDX*256 ; je PUSH CX/DX ?
         jne       TestPoj8                 ; nen° pojistka
         or        byte ptr ds:[Param],4    ; p©°znak, ëe je jië pojistka
TestPoj8:clc
TestPoj9:ret

TestPoj  ENDP

; -----------------------------------------------------------------------------
;        uzav©en° souborñ p©i chybà
; -----------------------------------------------------------------------------

ClosErr  PROC      NEAR

; ------ uzav©en° vstupn°ho souboru

         mov       bx,ds:[SouborI1]
         or        bx,bx
         jz        ClosErr2
         mov       ah,3eh
         int       21h                      ; uzav©en° vstupn°ho souboru

; ------ uzav©en° vòstupn°ho souboru

ClosErr2:mov       bx,ds:[SouborI2]
         or        bx,bx
         jz        ClosErr3
         mov       ah,3eh
         int       21h                      ; uzav©en° vòstupn°ho souboru

; ------ zru®en° vòstupn°ho souboru

         mov       dx,offset Soubor2        ; vòstupn° soubor
         mov       ah,41h
         int       21h                      ; zru®en° vòstupn°ho souboru

ClosErr3:
         ret

ClosErr  ENDP

; -----------------------------------------------------------------------------
;        áten° dat s kontrolou poátu bajtñ
; -----------------------------------------------------------------------------

ReadFil0 PROC      NEAR

         push      ax
         call      ReadFile                 ; naáten° bloku dat
         jc        ReadFl02                 ; chyba áten°
         cmp       ax,cx                    ; bylo naáteno v®e ?
         je        ReadFl02
         stc
ReadFl02:pop       ax
         jnc       ReadFl03                 ; operace áten° OK
         mov       dx,offset ReadTxt        ; text - chyba áten°
ReadFl03:ret

ReadFil0 ENDP

; -----------------------------------------------------------------------------
;        áten° dat ze souboru
; -----------------------------------------------------------------------------
; VSTUP: DX:BX=offset v souboru
;        CX=poáet bajtñ ke áten°
;        ES:SI=adresa bufferu k naáten° dat
;        DS=datovò segment
; VùSTUP:AX=poáet skuteánà naátenòch bajtñ
; -----------------------------------------------------------------------------

ReadFile PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      dx
         push      ds

; ------ nastaven° ukazatele v souboru

         push      cx
         mov       cx,dx                    ; offset HIGH
         mov       dx,bx                    ; offset LOW
         mov       bx,ds:[SouborI1]         ; identifik†tor souboru
         mov       ax,4200h
         int       21h                      ; nastaven° ukazatele na zaá†tek
         pop       cx
         jc        ReadFil8                 ; chyba

; ------ naáten° dat ze souboru

         mov       dx,si                    ; offset adresy bufferu
         push      es
         pop       ds                       ; DS <- segment adresy bufferu
         mov       ah,3fh
         int       21h                      ; naáten° z†hlav° souboru

; ------ n†vrat registrñ

ReadFil8:pop       ds
         pop       dx
         pop       bx
         jnc       ReadFil9                 ; operace OK
         mov       dx,offset ReadTxt        ; text - chyba áten°
         mov       ax,0
ReadFil9:ret

ReadFile ENDP

; -----------------------------------------------------------------------------
;        uloëen° bloku ES:SI/CX do souboru (sekvenánà)
; -----------------------------------------------------------------------------

WritFile PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      dx
         push      ds

; ------ z†pis bloku na disk

         mov       bx,ds:[SouborI2]         ; identifik†tor souboru
         push      es
         pop       ds
         mov       dx,si                    ; adresa
         mov       ah,40h
         int       21h                      ; z†pis bloku na disk
         jc        WritFil2                 ; chyba z†pisu
         cmp       ax,cx                    ; bylo zaps†no v®e ?
         je        WritFil2
         stc                                ; p©°znak chyby z†pisu

; ------ n†vrat registrñ

WritFil2:pop       ds
         pop       dx
         pop       bx
         pop       ax
         jnc       WritFil9                 ; operace OK
         mov       dx,offset WritTxt        ; text - chyba z†pisu
WritFil9:ret

WritFile ENDP

; -----------------------------------------------------------------------------
;        zkop°rov†n° á†sti souboru
; -----------------------------------------------------------------------------
; VSTUP: DX:BX=offset poá†tku dat ve vstupn°m souboru
;        DI:CX=poáet bajtñ ke zkop°rov†n°
;        AX=vstupn° hodnota kontroln°ho souátu
; VùSTUP:AX=vòstupn° hodnota kontroln°ho souátu
;        CY=chyba operace (v DX je chybovò text)
; -----------------------------------------------------------------------------

CopyFile PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      dx
         push      cx
         push      si
         push      di
         push      bp
         push      es

; ------ p©°prava registrñ

         mov       es,ds:[SoubSegm]         ; datovò segment
         mov       bp,cx                    ; á°taá dat LOW

; ------ uráen° velikosti bloku dat ke zkop°rov†n°

CopyFil2:mov       cx,0f000h                ; p©ednastaven°
         or        di,di                    ; je je®tà v°ce neë 64 KB ?
         jnz       CopyFil3                 ; je je®tà v°ce neë 64 KB
         cmp       cx,bp                    ; zbòv† jië mÇnà dat neë 0f000h ?
         jbe       CopyFil3
         mov       cx,bp                    ; omezen° poátu bajtñ
CopyFil3:clc                                ; p©°znak operace OK
         jcxz      CopyFil8                 ; konec operace

; ------ naáten° bloku dat

         xor       si,si                    ; offset v bufferu k naáten° dat
         call      ReadFil0                 ; áten° bloku dat
         jc        CopyFil8                 ; chyba áten°

; ------ uloëen° bloku dat

         call      WritFile                 ; z†pis bloku dat
         jc        CopyFil8                 ; chyba z†pisu

; ------ posun ukazatele v souboru a á°taáe dat

         add       bx,cx
         adc       dx,0
         sub       bp,cx
         sbb       di,0

; ------ kontroln° souáet bloku dat

         shr       cx,1                     ; velikost bloku ve slovech
         jcxz      CopyFil6
CopyFil5:rol       ax,1                     ; rotace o 1 bit vlevo
         xor       ax,es:[si]               ; p©iáten° slova
         inc       si
         inc       si                       ; zvò®en° adresy
         loop      CopyFil5                 ; dal®° slovo
CopyFil6:jmp       short CopyFil2           ; dal®° blok dat

; ------ n†vrat registrñ

CopyFil8:pop       es
         pop       bp
         pop       di
         pop       si
         pop       cx
         jc        CopyFil9                 ; nàjak† chyba - ponech† DX
         pop       dx
         pop       bx
         ret

CopyFil9:pop       bx
         pop       bx
         ret

CopyFile ENDP

; -----------------------------------------------------------------------------
;        otev©en° vstupn°ho souboru
; -----------------------------------------------------------------------------

OpenIn   PROC      NEAR

; ------ £schova atributñ souboru

         mov       ax,4300h
         mov       dx,offset Soubor1        ; jmÇno vstupn°ho souboru
         int       21h                      ; poskytnut° atributñ souboru
         jc        OpenIn8
         mov       ds:[FileAtr],cx          ; atributy souboru
         test      byte ptr ds:[Param],1    ; je zad†n vòstupn° soubor ?
         jnz       OpenIn2                  ; je zad†n vòstupn° soubor
         mov       dx,offset ROTxt
         test      cl,1                     ; je R/O ?
         stc
         jnz       OpenIn9                  ; chyba - je atribut R/O

; ------ otev©en° souboru

OpenIn2: mov       dx,offset Soubor1        ; jmÇno vstupn°ho souboru
         mov       ax,3d00h
         int       21h                      ; otev©en° vstupn°ho souboru
         jc        OpenIn8                  ; chybnÇ zad†n° souboru
         mov       ds:[SouborI1],ax         ; identifik†tor souboru

; ------ £schova data a áasu souboru

         mov       bx,ax
         mov       ax,5700h
         int       21h                      ; poskytnut° data a áasu souboru
         jc        OpenIn8
         mov       ds:[FileDate],dx         ; datum
         mov       ds:[FileTime],cx         ; áas

OpenIn8: mov       dx,offset InpTxt         ; text - soubor nenalezen
OpenIn9: ret

OpenIn   ENDP


; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                       Rozbor p©°kazovÇho ©†dku
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

; -----------------------------------------------------------------------------
;        rozbor p©°kazovÇho ©†dku (CY=chyba zad†n°)
; -----------------------------------------------------------------------------

Rozbor   PROC      NEAR

; ------ p©°prava k dek¢dov†n° p©°kazovÇho ©†dku

         mov       si,81h                   ; zaá†tek textu parametru
         mov       bl,ds:[si-1]             ; poáet znakñ zadanÇho parametru
         and       bl,7fh                   ; ochrana proti chybà
         mov       bh,0
         mov       byte ptr ds:[si+bx],0    ; oznaáen° konce textu v bufferu

; ------ rozbor p©ep°naáñ

         call      ParPar                   ; rozbor zad†n° p©ep°naáñ
         jc        Rozbor9                  ; chyba zad†n°

; ------ rozbor jmÇna vstupn°ho souboru

         mov       di,offset Soubor1        ; buffer jmÇna vstupn°ho soubrou
         call      ParFile                  ; rozbor zad†n° vstupn°ho souboru
         jc        Rozbor9                  ; chyba - soubor nezad†n

; ------ kopie do jmÇna vòstupn°ho souboru

         push      si
         mov       si,offset Soubor1
         mov       di,offset Soubor2
         mov       cx,128+10
         cld
         rep       movsb                    ; kopie jmÇna souboru
         add       bx,offset(Soubor2-Soubor1) ; korekce adresy p©°pony
         mov       ds:[SouborE2],bx         ; p©°pona jmÇna p©echodnÇho souboru
         pop       si

; ------ rozbor p©ep°naáñ

         call      ParPar                   ; rozbor zad†n° p©ep°naáñ
         jc        Rozbor9                  ; chyba zad†n°

; ------ rozbor jmÇna vòstupn°ho souboru

         mov       di,offset Soubor2        ; buffer jmÇna vòstupn°ho souboru
         call      ParFile                  ; rozbor zad†n° vòstupn°ho souboru
         jc        Rozbor7                  ; vòstupn° soubor nen° zad†n
         mov       ds:[SouborE2],bx         ; p©°pona jmÇna souboru
         or        byte ptr ds:[Param],1    ; p©°znak zad†n° vòstupn°ho souboru

; ------ rozbor p©ep°naáñ

         call      ParPar                   ; rozbor zad†n° p©ep°naáñ
         jc        Rozbor9                  ; chyba zad†n°

; ------ test, zda je®tà nàco n†sleduje

Rozbor7: call      ParSpc                   ; nesm° nic n†sledovat
Rozbor8: cmc
Rozbor9: ret

Rozbor   ENDP

; -----------------------------------------------------------------------------
;        rozbor zad†n° p©ep°naáñ (CY=chyba)
; -----------------------------------------------------------------------------

ParPar   PROC      NEAR

; ------ nalezen° zaá†tku parametrñ

ParPar1: call      ParSpc                   ; nalezen° zaá†tku textu
         jc        ParPar8                  ; nen° ë†dnò dal®° text
         cmp       al,"/"                   ; je p©°znak parametru ?
         jne       ParPar8                  ; nen° parametr

; ------ naáten° znaku parametru

         call      ParChr                   ; naáten° p©°znaku parametru "/"
         call      ParChr                   ; naáten° znaku parametru
         jc        ParPar9                  ; nen° zad†n - to je chyba

; ------ parametr "/X" - odstranàn° pojistky z programu

         cmp       al,"X"                   ; je parametr "/X" ?
         jne       ParPar2                  ; nen° parametr "/X"
         test      byte ptr ds:[Param],10h+20h ; jsou jinÇ p©ep°naáe ?
         jnz       ParPar7                  ; jsou jinÇ p©ep°naáe - chyba
         or        byte ptr ds:[Param],8    ; p©°znak parametru "/X"
         jmp       short ParPar1            ; dal®° parametr

; ------ parametr "/T" - test neporu®enosti programu

ParPar2: cmp       al,"T"                   ; je parametr "/T" ?
         jne       ParPar3                  ; nen° parametr "/T"
         test      byte ptr ds:[Param],8+20h ; jsou jinÇ p©ep°naáe ?
         jnz       ParPar7                  ; jsou jinÇ p©ep°naáe - chyba
         or        byte ptr ds:[Param],10h  ; p©°znak parametru "/T"
         jmp       short ParPar1            ; dal®° parametr

; ------ parametr "/!" - oprava zavirovanÇho programu

ParPar3: cmp       al,"!"                   ; je parametr "/!" ?
         jne       ParPar4                  ; nen° parametr "/!"
         test      byte ptr ds:[Param],8+10h ; jsou jinÇ p©ep°naáe ?
         jnz       ParPar7                  ; jsou jinÇ p©ep°naáe - chyba
         or        byte ptr ds:[Param],20h  ; p©°znak parametru "/!"
         jmp       short ParPar1            ; dal®° parametr

; ------ parametr "/C" - pojistka s pokraáov†n°m

ParPar4: cmp       al,"C"                   ; je parametr "/C" ?
         jne       ParPar7                  ; nen° parametr "/C"
         or        byte ptr ds:[Param],40h  ; p©°znak pojistky s pokraáov†n°m
         jmp       short ParPar1            ; dal®° parametr

; ------ chyba zad†n° parametrñ

ParPar7: stc                                ; p©°znak chyby zad†n°
         ret

ParPar8: clc
ParPar9: ret

ParPar   ENDP

; -----------------------------------------------------------------------------
;        rozbor jmÇna souboru (ES:DI=buffer -> BX=p©°pona, DX=jmÇno)
; -----------------------------------------------------------------------------

ParFile  PROC      NEAR

; ------ nalezen° zaá†tku jmÇna souboru

         call      ParSpc                   ; nalezen° zaá†tku jmÇna souboru
         jc        ParFile9                 ; konec textu
         cmp       al,"/"                   ; oddàlovaá parametrñ ?
         stc                                ; p©°znak chyby
         je        ParFile9                 ; oddàlovaá parametrñ - nen° jmÇno

; ------ dek¢dov†n° jmÇna souboru

         mov       dx,di                    ; £schova zaá†tku jmÇna
         mov       bx,di                    ; £schova zaá†tku p©°pony
ParFile2:call      ParChr                   ; vstup znaku z p©°kazovÇho ©†dku
         cld
         jc        ParFile7                 ; konec p©°kazovÇho ©†dku
         je        ParFile6                 ; oddàlovaá - konec jmÇna
         cmp       al,"/"                   ; oddàlovaá parametrñ ?
         je        ParFile6                 ; oddàlovaá parametrñ - konec jmÇna

; ------ uloëen° znaku

         stosb                              ; uloëen° znaku do bufferu

; ------ test zaá†tku jmÇna

         cmp       al,":"                   ; oddàlovaá disku ?
         je        ParFile3                 ; oddàlovaá disku - zaá†tek jmÇna
         cmp       al,"\"                   ; oddàlovaá cesty ?
         jne       ParFile4                 ; nen° zaá†tek jmÇna
ParFile3:mov       dx,di                    ; £schova zaá†tku jmÇna

; ------ test zaá†tku p©°pony

ParFile4:cmp       al,"."                   ; oddàlovaá p©°pony ?
         jne       ParFile2                 ; nen° p©°pona
         mov       bx,di                    ; £schova zaá†tku p©°pony
         jmp       short ParFile2           ; dek¢dov†n° dal®°ho znaku

; ------ korekce adresy p©°pony jmÇna

ParFile6:dec       si                       ; n†vrat znaku oddàlovaáe
ParFile7:cmp       bx,dx                    ; byla p©°pona zad†na ?
         ja        ParFile8                 ; p©°pona byla zad†na OK
         mov       bx,di                    ; p©°pona na konci jmÇna

; ------ ukonáen° jmÇna souboru

ParFile8:mov       al,0                     ; ukonáovac° bajt 0
         stosb                              ; ukonáen° jmÇna souboru
         clc                                ; p©°znak operace OK

ParFile9:ret

ParFile  ENDP

; -----------------------------------------------------------------------------
;        vypu®tàn° mezer z p©°kazovÇho ©†dku
; -----------------------------------------------------------------------------

ParSpc   PROC      NEAR

         call      ParChr                   ; naáten° znaku z p©°kazovÇho ©†dku
         jc        ParSpc3                  ; nen° dal®° znak
         je        ParSpc                   ; mezera - vypu®tàn°
         dec       si                       ; n†vrat posledn°ho znaku
ParSpc3: ret

ParSpc   ENDP

; -----------------------------------------------------------------------------
;        vstup znaku z p©°kazovÇho ©†dku DS:SI
; -----------------------------------------------------------------------------

ParChr   PROC      NEAR

; ------ naáten° znaku z p©°kazovÇho ©†dku

         cld
         lodsb                              ; naáten° znaku z p©°kazovÇho ©†dku

; ------ n†hrada tabel†toru mezerou

         cmp       al,9
         jne       ParChr1                  ; nen° znak tabel†toru
         mov       al," "                   ; n†hrada tabel†toru mezerou

; ------ konverze na velkÇ p°smeno

ParChr1: cmp       al,"a"
         jb        ParChr2
         cmp       al,"z"
         ja        ParChr2
         sub       al,32                    ; konverze na velkÇ p°smeno

; ------ test, zda je konec ©†dku

ParChr2: cmp       al," "                   ; je platnò znak ?
         jae       ParChr4                  ; je platnò znak nebo mezera
         dec       si                       ; n†vrat ukazatele textu

ParChr4: ret

ParChr   ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                                   data
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

Param    db        0                        ; parametry, p©ep°naáe
                                            ;    bit 0: 1=zad†n vòstupn° soubor
                                            ;    bit 1: 1=program je typu EXE
                                            ;    bit 2: 1=nalezena pojistka
                                            ;    bit 3: 1=poëad. odpojistkov†n°
                                            ;    bit 4: 1=test programu
                                            ;    bit 5: 1=poëad. opraven° prog.
                                            ;    bit 6: 1=pojistka s pokraáov†n°m

; ------ texty a hl†®en°

UvTxt    db        'POJ V1.21 - antivirova pojistka programu; (c) Miroslav Nemecek',13,10,'$'
HelpTxt  db        'Zadejte: POJ  vstupni_soubor  [vystupni_soubor]  [/C | /X | /T | /!]',13,10
         db        '              vstupni_soubor .... jmeno programu k ochraneni pojistkou',13,10
         db        '              vystupni_soubor ... jmeno vystupniho souboru',13,10
         db        '              /C ................ pouzit pojistku s moznosti pokracovani',13,10
         db        '              /T ................ test programu na neporusenost',13,10
         db        '              /X ................ odstraneni pojistky z programu',13,10
         db        '              /! ................ odstraneni pojistky s odvirovanim programu',13,10
         db        '$'

MemTxt   db        'Nedostatek pameti !',13,10,'$'
PojTxt   db        'Program je jiz chranen pojistkou !',13,10,'$'
SizTxt   db        'Program nelze ochranit pojistkou !',13,10,'$'

InpTxt   db        'Chybne zadani souboru k ochraneni - soubor nenalezen !',13,10,'$'
CreatTxt db        'Chyba - vystupni soubor nelze vytvorit !',13,10,'$'
ReadTxt  db        'Chyba cteni ze vstupniho souboru !',13,10,'$'
WritTxt  db        'Chyba zapisu do vystupniho souboru !'
CRTxt    db        13,10,'$'
ExTxt    db        'Vystupni soubor jiz existuje - chcete jej prepsat (A=ano) ? $'

NoPojTxt db        'Program neni chranen pojistkou (nebo je napaden virem) !',13,10,'$'
CRCErTxt db        'Program je POSKOZEN (zrejme napaden virem) !',13,7,10,'$'

CRCOkTxt db        'Kontrolni soucet souboru souhlasi.',13,10,'$'

FndTxt   db        'Pojistka v programu nenalezena !',13,10,'$'
VirTxt   db        'Pojistka z programu odstranena. Funkcnost programu NEZARUCENA !',13,10,'$'

DelTxt   db        'Puvodni soubor nelze nahradit novym souborem !',13,10,'$'
ROTxt    db        'Soubor nesmi mit nastavenu ochranu proti zapisu !',13,10,'$'

; ------ vstupn° soubor

Soubor1  db        128+10 dup(0)            ; jmÇno vstupn°ho souboru
SouborI1 dw        0                        ; identifik. vstup. souboru (0=nen°)

; ------ vòstupn° soubor

Soubor2  db        128+10 dup(0)            ; jmÇno vòstupn°ho souboru
SouborE2 dw        0                        ; adresa p©°pony jmÇna souboru
SouborI2 dw        0                        ; identifik. vòstup.souboru (0=nen°)

; ------ datovò buffer

SoubSegm dw        0                        ; segment se souborem
SoubNum  dw        0                        ; poáet bajtñ v bufferu

; ------ parametry vstupn°ho souboru EXE

RelokSiz dw        0                        ; velikost relokaán° tabulky
HeadSize dd        0                        ; velikost z†hlav° souboru
LoadSize dd        0                        ; velikost zav†dànÇ á†sti programu
ProgSize dd        0                        ; velikost vnit©n°ho programu
SoubSize dd        0                        ; pñvodn° celkov† velikost souboru
OvlSize  dd        0                        ; velikost dat za programem

ExeXRel  dw        0                        ; opravenò offset relokaán° tabulky

Head1Siz dw        0                        ; velikost prvn° á†sti hlaviáky
Head2Adr dd        0                        ; adresa poá†tku 2. á†sti hlaviáky
Head2Siz dd        0                        ; velikost druhÇ á†sti hlaviáky

PojAdr   dd        0                        ; adresa pojistky v programu
RelAdr   dd        0                        ; adresa relokaán° tabulky v progr.

FileAtr  dw        0                        ; atributy souboru
FileDate dw        0                        ; datum souboru
FileTime dw        0                        ; áas souboru

; ------ parametry vòstupn°ho souboru EXE

SoubNSiz dd        0                        ; nov† velikost souboru EXE
LoadNSiz dd        0                        ; nov† zav†dàc° velikost programu
ProgNSiz dd        0                        ; nov† vnit©n° velikost programu
HeadNSiz dd        0                        ; nov† velikost hlaviáky programu
PojSize  dw        0                        ; velikost pojistky

; ------ z†hlav° programu EXE (COM) - sem se naáte prvn°ch 28 bajtñ souboru

ExeHead  label     byte                     ; z†hlav° souboru EXE
ExeIdnt  db        'MZ'                     ; identifik†tor souboru EXE
ExeLast  dw        0                        ; dÇlka posledn° str†nky 512 B
ExePage  dw        0                        ; poáet str†nek 512 bajtñ souboru
ExeRNum  dw        0                        ; poáet poloëek relokaán° tabulky
ExeHSize dw        0                        ; velikost z†hlav° (odstavcñ 16 B)
ExeMin   dw        0                        ; minim†ln° pamàü
ExeMax   dw        0                        ; maxim†ln° pamàü
ExeSS    dw        0                        ; registr SS
ExeSP    dw        0                        ; registr SP
ExeSum   dw        0                        ; kontroln° souáet souboru
ExeIP    dw        0                        ; registr IP
ExeCS    dw        0                        ; registr CS
ExeRelok dw        0                        ; offset relokaán° tabulky
ExeOvl   dw        0                        ; poáet modulñ OVL
ExeHead0 label     byte

; ------ zaá†tek starÇ pojistky v souboru

OldPoj   db        32 dup(0)                ; asi tak 32 bajtñ ze starÇ pojistky

;˛

; *****************************************************************************
;
;                              Pojistka COM
;                        (mus° m°t sudou dÇlku !)
;
; *****************************************************************************

         EVEN

PojBeg   label     byte                     ; zaá†tek pojistky

PojIdn   db        'PJ'                     ; identifik†tor pojistky

; !!!!!!!!
PojOld   db        0,0,0                    ; pñvodn° zaá†tek programu

; ------ £schova registrñ

PojStart:push      ax                       ;ƒøtyto 4 instrukce = identifikace !
         push      bx                       ; ≥
         push      cx                       ; ≥
         push      dx                       ;ƒŸ
         push      si
         push      di
         pushf

         mov       di,100h                  ; konstanta 100h

; ------ kontroln° souáet programu s pojistkou

; !!!!!!!
PojDelk1:mov       cx,offset(PojEnd-PojBeg)/2 ; dÇlka programu s pojist.(slov)
         mov       si,di                    ; poá†teán° adresa programu
         mov       dx,cx                    ; vòchoz° hodnota CRC
         cld
PojS1:   lodsw                              ; naáten° slova
         rol       dx,1                     ; rotace o 1 bit vlevo
         xor       dx,ax                    ; p©iáten° slova
         loop      PojS1                    ; dal®° slovo
         jz        PojS3                    ; kontroln° souáet je OK

; ------ chyba - program je po®kozen

; !!!!!!!
PojS2:   mov       dx,offset PojText1       ; text - program je po®kozen
         mov       ah,9
         int       21h
         mov       ax,4cfeh
         int       21h                      ; n†vrat programu s chybou

; ------ kontrola verze systÇmu

PojS3:   mov       ah,30h
         int       21h                      ; poskytnut° verze systÇmu
         cmp       al,3                     ; je verze systÇmu alespo§ 3.00 ?
         jb        PojS7                    ; je n°zk† verze systÇmu

; ------ p©°prava k nalezen° cesty

         mov       cx,ds:[2ch]              ; segment prost©ed°
         jcxz      PojS7                    ; nen° prost©ed°
         push      ds                       ; £schova DS
         mov       ds,cx                    ; segment prost©ed°
         xor       ax,ax                    ; hledanÇ slovo
         xor       si,si                    ; zaá†tek prost©ed°

; ------ nalezen° textu jmÇna souboru

PojS4:   inc       si                       ; zvò®en° ukazatele v prost©ed°
         cmp       ds:[si-1],ax             ; konec prost©ed° ?
         jne       PojS4                    ; nalezen° konce prost©ed°
         mov       cx,3                     ; poáet bajtñ ke áten°
         add       si,cx                    ; zaá†tek jmÇna souboru

; ------ otev©en° souboru

         mov       dx,si                    ; adresa textu jmÇna souboru
         mov       ah,3dh                   ; zde je AL=0
         int       21h                      ; otev©en° souboru
         pop       ds                       ; n†vrat DS
         jc        PojS7                    ; chyba otev©en° souboru
         xchg      ax,bx                    ; identifik†tor souboru

; ------ naáten° zaá†tku souboru

         mov       ah,3fh
         mov       dx,di                    ; zaá†tek programu 100h
         int       21h                      ; naáten° zaá†tku souboru

; ------ stanoven° velikosti souboru

         mov       ax,4202h
         xor       cx,cx
         xor       dx,dx
         int       21h                      ; vystaven° ukazatele na konec

; ------ kontrola velikosti souboru

; !!!!!!!!
PojDelk2:cmp       ax,offset(PojEnd-PojBeg) ; dÇlka programu s pojistkou
         jne       PojS2                    ; velikost nesouhlas°

; ------ uzav©en° souboru

PojS6:   mov       ah,3eh
         int       21h                      ; uzav©en° souboru

; ------ kontrola zaá†tku souboru

; !!!!!!!!
PojS7:   cmp       word ptr ds:[di+1],offset PojStart-103h ; souhlas° offs. skoku ?
         jne       PojS2                    ; nesouhlas° offset skoku

; ------ n†vrat zaá†tku programu

; !!!!!!!!
PojS8:   mov       si,offset PojOld         ; pñvodn° zaá†tek programu
         cld
         movsb
         movsw

; ------ n†vrat registrñ

         popf
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax

; !!!!!!!!
PojJMPSt:jmp       near ptr Start           ; start programu

PojText1 db        13,'Program POSKOZEN !',13,7,10,'$'

         EVEN

PojCRC   dw        0                        ; kontroln° souáet programu+pojistka

PojEnd   label     byte                     ; konec pojistky

; *****************************************************************************
;
;                         Cojistka COM s dotazem
;                        (mus° m°t sudou dÇlku !)
;
; *****************************************************************************

         EVEN

CojBeg   label     byte                     ; zaá†tek pojistky

CojIdn   db        'PJ'                     ; identifik†tor pojistky

; !!!!!!!!
CojOld   db        0,0,0                    ; pñvodn° zaá†tek programu

; ------ £schova registrñ

CojStart:push      ax                       ;ƒøtyto 4 instrukce = identifikace !
         push      bx                       ; ≥
         push      cx                       ; ≥
         push      dx                       ;ƒŸ
         push      si
         push      di
         pushf

         mov       di,100h                  ; konstanta 100h

; ------ kontroln° souáet programu s pojistkou

; !!!!!!!
CojDelk1:mov       cx,offset(CojEnd-CojBeg)/2 ; dÇlka programu s pojist.(slov)
         mov       si,di                    ; poá†teán° adresa programu
         mov       dx,cx                    ; vòchoz° hodnota CRC
         cld
CojS1:   lodsw                              ; naáten° slova
         rol       dx,1                     ; rotace o 1 bit vlevo
         xor       dx,ax                    ; p©iáten° slova
         loop      CojS1                    ; dal®° slovo
         jz        CojS3                    ; kontroln° souáet je OK

; ------ chyba - program je po®kozen

; !!!!!!!
CojS2:   mov       dx,offset CojText1       ; text - program je po®kozen
         mov       ah,9
         int       21h
         mov       ax,0c08h
         int       21h                      ; vstup znaku z kl†vesnice
         cmp       al,13                    ; je ENTER ?
         je        CojS8                    ; je ENTER - pokraáov†n°
         mov       ax,4cfeh
         int       21h                      ; n†vrat programu s chybou

; ------ kontrola verze systÇmu

CojS3:   mov       ah,30h
         int       21h                      ; poskytnut° verze systÇmu
         cmp       al,3                     ; je verze systÇmu alespo§ 3.00 ?
         jb        CojS7                    ; je n°zk† verze systÇmu

; ------ p©°prava k nalezen° cesty

         mov       cx,ds:[2ch]              ; segment prost©ed°
         jcxz      CojS7                    ; nen° prost©ed°
         push      ds                       ; £schova DS
         mov       ds,cx                    ; segment prost©ed°
         xor       ax,ax                    ; hledanÇ slovo
         xor       si,si                    ; zaá†tek prost©ed°

; ------ nalezen° textu jmÇna souboru

CojS4:   inc       si                       ; zvò®en° ukazatele v prost©ed°
         cmp       ds:[si-1],ax             ; konec prost©ed° ?
         jne       CojS4                    ; nalezen° konce prost©ed°
         mov       cx,3                     ; poáet bajtñ ke áten°
         add       si,cx                    ; zaá†tek jmÇna souboru

; ------ otev©en° souboru

         mov       dx,si                    ; adresa textu jmÇna souboru
         mov       ah,3dh                   ; zde je AL=0
         int       21h                      ; otev©en° souboru
         pop       ds                       ; n†vrat DS
         jc        CojS7                    ; chyba otev©en° souboru
         xchg      ax,bx                    ; identifik†tor souboru

; ------ naáten° zaá†tku souboru

         mov       ah,3fh
         mov       dx,di                    ; zaá†tek programu 100h
         int       21h                      ; naáten° zaá†tku souboru

; ------ stanoven° velikosti souboru

         mov       ax,4202h
         xor       cx,cx
         xor       dx,dx
         int       21h                      ; vystaven° ukazatele na konec

; ------ kontrola velikosti souboru

; !!!!!!!!
CojDelk2:cmp       ax,offset(CojEnd-CojBeg) ; dÇlka programu s pojistkou
         jne       CojS2                    ; velikost nesouhlas°

; ------ uzav©en° souboru

CojS6:   mov       ah,3eh
         int       21h                      ; uzav©en° souboru

; ------ kontrola zaá†tku souboru

; !!!!!!!!
CojS7:   cmp       word ptr ds:[di+1],offset CojStart-103h ; souhlas° offs. skoku ?
         jne       CojS2                    ; nesouhlas° offset skoku

; ------ n†vrat zaá†tku programu

; !!!!!!!!
CojS8:   mov       si,offset CojOld         ; pñvodn° zaá†tek programu
         cld
         movsb
         movsw

; ------ n†vrat registrñ

         popf
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax

; !!!!!!!!
CojJMPSt:jmp       near ptr Start           ; start programu

CojText1 db        13,'Program POSKOZEN !',13,10
         db           'Pokracovat (ENTER=ANO) ?',13,7,10,'$'

         EVEN

CojCRC   dw        0                        ; kontroln° souáet programu+pojistka

CojEnd   label     byte                     ; konec pojistky


PojXTab  label     word                     ; tabulka adres k relokaci
         dw        PojXRelT
         dw        PojXT1+1
         dw        PojXS2+1
         dw        PojXT2+1
;         dw        PojXDlk3+1
         dw        PojXT3+2
         dw        PojXT3+4                 ; (POZOR = je to BAJT !)
         dw        PojXAdr4+2
         dw        PojXT5+3
         dw        PojXT6+3
         dw        PojXT7+3
         dw        PojXRCS
         dw        PojXRSS
PojXTab0 label     word

; ------ NèSLEDUJE !!!

CojXTab  label     word                     ; tabulka adres k relokaci
         dw        CojXRelT
         dw        CojXT1+1
         dw        CojXS2+1
         dw        CojXT2+1
;         dw        CojXDlk3+1
         dw        CojXT3+2
         dw        CojXT3+4                 ; (POZOR = je to BAJT !)
         dw        CojXAdr4+2
         dw        CojXT5+3
         dw        CojXT6+3
         dw        CojXT7+3
         dw        CojXRCS
         dw        CojXRSS
CojXTab0 label     word

; *****************************************************************************
;
;                             Pojistka EXE
;                        (mus° m°t sudou dÇlku !)
;
; *****************************************************************************
;˛
         EVEN

PojXBeg  label     byte                     ; zaá†tek pojistky (offset = 0)

PojXIdn  db        'PJ'                     ; identifik†tor pojistky

; !!!!!!!!
PojXSP   dw        0                        ; pñvodn° SP programu
PojXSS   dw        0                        ; pñvodn° SS programu
PojXIP   dw        0                        ; pñvodn° IP programu ƒø po©ad° !!!
PojXCS   dw        0                        ; pñvodn° CS programu ƒŸ zachovat !
PojXRel  dw        0                        ; poáet relokaán°ch poloëek
PojXRelT dw        offset(PojXCRC-PojXBeg)  ; offset relokaán° tabulky
PojXMin  dw        0                        ; minim†ln° pamàü za programem

; ------ £schova registrñ

PojXStrt:push      ax                       ;ƒøtyto 4 instrukce = identifikace !
         push      bx                       ; ≥
         push      cx                       ; ≥
         push      dx                       ;ƒŸ
         push      si
         push      di
         push      ds
         pushf

; ------ inicializace segmentu poá†tku programu

         mov       bx,ds                    ; segment PSP
         add       bx,10h                   ; segment zaá†tku programu
         push      bx                       ; £schova relokaán° adresy
         mov       ds,bx                    ; poá†tek programu

; ------ vòpoáet kontroln°ho souátu dat

         cld
         xor       si,si                    ; vòchoz° offset dat
PojXDel1:mov       di,1234h                 ; poáet blokñ 64 KB (i necelòch)
         xor       dx,dx                    ; vòchoz° hodnota CRC
PojXDel2:mov       cx,1234h                 ; dÇlka posledn°ho bloku 0 aë 8000h
         dec       di                       ; á°taá blokñ 64 KB
         jz        PojXSum2                 ; je posledn° blok
         js        PojXSum6                 ; konec dat
         mov       cx,8000h                 ; dÇlka 64 KB
PojXSum2:lodsw                              ; naáten° slova
         rol       dx,1                     ; rotace o 1 bit vlevo
         xor       dx,ax                    ; p©iáten° slova
         loop      PojXSum2                 ; dal®° slovo
         add       bx,1000h                 ; zvò®en° segmentu adresy
         mov       ds,bx                    ; novò segment adresy
         jmp       short PojXDel2

; ------ relokace programu

PojXSum6:pop       bx                       ; relokaán° adresa
         push      cs
         pop       ds                       ; DS <- CS
PojXRel1:mov       cx,1234h                 ; poáet relokaán°ch poloëek v tab.
PojXT1:  mov       si,offset(PojXRTab-PojXBeg) ; relokaán° tabulka
PojXRl2: push      ds
         lodsw                              ; offset relokovanÇ poloëky
         mov       di,ax                    ; offset poloëky
         lodsw                              ; segment relokovanÇ poloëky
         add       ax,bx                    ; segment adresy poloëky
         mov       ds,ax                    ; segment adresy poloëky
         add       ds:[di],bx               ; relokace poloëky
         pop       ds
         loop      PojXRl2                  ; relokace dal®° poloëky

; ------ test vòsledku kontroln°ho souátu

         or        dx,dx                    ; je kontroln° souáet OK ?
         jz        PojXS3                   ; kontroln° souáet je OK

; ------ chyba - program je po®kozen

PojXS2:  mov       dx,offset(PojXTxt1-PojXBeg) ; text - program je po®kozen
         mov       ah,9
         int       21h
         mov       ax,4cfeh
         int       21h                      ; n†vrat programu s chybou

; ------ kontrola verze systÇmu

PojXS3:  mov       ah,30h
         int       21h                      ; poskytnut° verze systÇmu
         cmp       al,3                     ; je verze systÇmu alespo§ 3.00 ?
         jb        PojXS8                   ; je n°zk† verze systÇmu

; ------ p©°prava k nalezen° cesty

         mov       cx,es:[2ch]              ; segment prost©ed°
         jcxz      PojXS8                   ; nen° prost©ed°
         push      ds                       ; £schova DS
         mov       ds,cx                    ; segment prost©ed°
         xor       ax,ax                    ; hledanÇ slovo
         xor       si,si                    ; zaá†tek prost©ed°

; ------ nalezen° textu jmÇna souboru

PojXS4:  inc       si                       ; zvò®en° ukazatele v prost©ed°
         cmp       ds:[si-1],ax             ; konec prost©ed° ?
         jne       PojXS4                   ; nalezen° konce prost©ed°
         add       si,3                     ; zaá†tek jmÇna souboru

; ------ otev©en° souboru

         mov       dx,si                    ; adresa textu jmÇna souboru
         mov       ah,3dh                   ; zde je AL = 0
         int       21h                      ; otev©en° souboru
         pop       ds                       ; n†vrat DS
         jc        PojXS8                   ; chyba otev©en° souboru
         xchg      ax,bx                    ; identifik†tor souboru

; ------ naáten° zaá†tku souboru

         mov       cx,18h                   ; dÇlka dat k naáten°
         mov       ah,3fh
PojXT2:  mov       dx,offset(PojXRTab-PojXBeg) ; buffer k naáten° z†hlav°
         int       21h                      ; naáten° zaá†tku souboru

; ------ stanoven° velikosti souboru

         mov       ax,4202h
         xor       cx,cx
         xor       dx,dx
         int       21h                      ; vystaven° ukazatele na konec

; ------ kontrola velikosti souboru (LOW)

; !!!!!!!!
PojXDlk3:cmp       ax,offset(PojXEnd-PojXBeg) ; dÇlka programu celkem LOW
         jne       PojXS2                    ; velikost nesouhlas°

; ------ uzav©en° souboru

         mov       ah,3eh
         int       21h                      ; uzav©en° souboru

; ------ kontrola startovac° adresy programu

PojXT3:  cmp       word ptr ds:[PojXRTab-PojXBeg+14h],offset(PojXStrt-PojXBeg) ; offset ?
         jne       PojXS2                   ; nesouhlas° offset skoku
; !!!!!!!!
PojXADR4:cmp       word ptr ds:[PojXRTab-PojXBeg+16h],1234h ; souhlas° segment ?
         jne       PojXS2                   ; nesouhlas°

; ------ n†vrat registrñ

PojXS8:  popf
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax

; ------ skok do programu

PojXT5:  mov       ss,cs:[PojXSS-PojXBeg]
PojXT6:  mov       sp,cs:[PojXSP-PojXBeg]
PojXT7:  jmp       dword ptr cs:[PojXIP-PojXBeg]

PojXTxt1 db        13,'Program POSKOZEN !',13,7,10,'$'

         EVEN
PojXRTab label     word                     ; tabulka adres relok. poloëek
                                            ; - naá°t† se sem tÇë z†hlav° EXE !

PojXRCS  dd        offset(PojXCS-PojXBeg)   ; relokace registru CS
PojXRSS  dd        offset(PojXSS-PojXBeg)   ; relokace registru SS

PojXCRC  dw        0                        ; kontroln° souáet programu+pojistka
                                            ; - posouv† se za konec tabulky rel.
                                            ;   poloëek !!!

                                            ; (n†sleduje z†sobn°k)

PojXEnd  label     byte                     ; konec pojistky (+tabulka rek.pol.)

; *****************************************************************************
;
;                      Pojistka EXE s pokraáov†n°m
;                        (mus° m°t sudou dÇlku !)
;
; *****************************************************************************
;˛
         EVEN

CojXBeg  label     byte                     ; zaá†tek Pojistky (offset = 0)

CojXIdn  db        'PJ'                     ; identifik†tor Pojistky

; !!!!!!!!
CojXSP   dw        0                        ; pñvodn° SP programu
CojXSS   dw        0                        ; pñvodn° SS programu
CojXIP   dw        0                        ; pñvodn° IP programu ƒø po©ad° !!!
CojXCS   dw        0                        ; pñvodn° CS programu ƒŸ zachovat !
CojXRel  dw        0                        ; poáet relokaán°ch poloëek
CojXRelT dw        offset(CojXCRC-CojXBeg)  ; offset relokaán° tabulky
CojXMin  dw        0                        ; minim†ln° pamàü za programem

; ------ £schova registrñ

CojXStrt:push      ax                       ;ƒøtyto 4 instrukce = identifikace !
         push      bx                       ; ≥
         push      cx                       ; ≥
         push      dx                       ;ƒŸ
         push      si
         push      di
         push      ds
         pushf

; ------ inicializace segmentu poá†tku programu

         mov       bx,ds                    ; segment PSP
         add       bx,10h                   ; segment zaá†tku programu
         push      bx                       ; £schova relokaán° adresy
         mov       ds,bx                    ; poá†tek programu

; ------ vòpoáet kontroln°ho souátu dat

         cld
         xor       si,si                    ; vòchoz° offset dat
CojXDel1:mov       di,1234h                 ; poáet blokñ 64 KB (i necelòch)
         xor       dx,dx                    ; vòchoz° hodnota CRC
CojXDel2:mov       cx,1234h                 ; dÇlka posledn°ho bloku 0 aë 8000h
         dec       di                       ; á°taá blokñ 64 KB
         jz        CojXSum2                 ; je posledn° blok
         js        CojXSum6                 ; konec dat
         mov       cx,8000h                 ; dÇlka 64 KB
CojXSum2:lodsw                              ; naáten° slova
         rol       dx,1                     ; rotace o 1 bit vlevo
         xor       dx,ax                    ; p©iáten° slova
         loop      CojXSum2                 ; dal®° slovo
         add       bx,1000h                 ; zvò®en° segmentu adresy
         mov       ds,bx                    ; novò segment adresy
         jmp       short CojXDel2

; ------ relokace programu

CojXSum6:pop       bx                       ; relokaán° adresa
         push      cs
         pop       ds                       ; DS <- CS
CojXRel1:mov       cx,1234h                 ; poáet relokaán°ch poloëek v tab.
CojXT1:  mov       si,offset(CojXRTab-CojXBeg) ; relokaán° tabulka
CojXRl2: push      ds
         lodsw                              ; offset relokovanÇ poloëky
         mov       di,ax                    ; offset poloëky
         lodsw                              ; segment relokovanÇ poloëky
         add       ax,bx                    ; segment adresy poloëky
         mov       ds,ax                    ; segment adresy poloëky
         add       ds:[di],bx               ; relokace poloëky
         pop       ds
         loop      CojXRl2                  ; relokace dal®° poloëky

; ------ test vòsledku kontroln°ho souátu

         or        dx,dx                    ; je kontroln° souáet OK ?
         jz        CojXS3                   ; kontroln° souáet je OK

; ------ chyba - program je po®kozen

CojXS2:  mov       dx,offset(CojXTxt1-CojXBeg) ; text - program je po®kozen
         mov       ah,9
         int       21h
         mov       ax,0c08h
         int       21h                      ; vstup znaku z kl†vesnice
         cmp       al,13                    ; je ENTER ?
         je        CojXS8                   ; je ENTER - pokraáov†n°
         mov       ax,4cfeh
         int       21h                      ; n†vrat programu s chybou

; ------ kontrola verze systÇmu

CojXS3:  mov       ah,30h
         int       21h                      ; poskytnut° verze systÇmu
         cmp       al,3                     ; je verze systÇmu alespo§ 3.00 ?
         jb        CojXS8                   ; je n°zk† verze systÇmu

; ------ p©°prava k nalezen° cesty

         mov       cx,es:[2ch]              ; segment prost©ed°
         jcxz      CojXS8                   ; nen° prost©ed°
         push      ds                       ; £schova DS
         mov       ds,cx                    ; segment prost©ed°
         xor       ax,ax                    ; hledanÇ slovo
         xor       si,si                    ; zaá†tek prost©ed°

; ------ nalezen° textu jmÇna souboru

CojXS4:  inc       si                       ; zvò®en° ukazatele v prost©ed°
         cmp       ds:[si-1],ax             ; konec prost©ed° ?
         jne       CojXS4                   ; nalezen° konce prost©ed°
         add       si,3                     ; zaá†tek jmÇna souboru

; ------ otev©en° souboru

         mov       dx,si                    ; adresa textu jmÇna souboru
         mov       ah,3dh                   ; zde je AL = 0
         int       21h                      ; otev©en° souboru
         pop       ds                       ; n†vrat DS
         jc        CojXS8                   ; chyba otev©en° souboru
         xchg      ax,bx                    ; identifik†tor souboru

; ------ naáten° zaá†tku souboru

         mov       cx,18h                   ; dÇlka dat k naáten°
         mov       ah,3fh
CojXT2:  mov       dx,offset(CojXRTab-CojXBeg) ; buffer k naáten° z†hlav°
         int       21h                      ; naáten° zaá†tku souboru

; ------ stanoven° velikosti souboru

         mov       ax,4202h
         xor       cx,cx
         xor       dx,dx
         int       21h                      ; vystaven° ukazatele na konec

; ------ kontrola velikosti souboru (LOW)

; !!!!!!!!
CojXDlk3:cmp       ax,offset(CojXEnd-CojXBeg) ; dÇlka programu celkem LOW
         jne       CojXS2                    ; velikost nesouhlas°

; ------ uzav©en° souboru

         mov       ah,3eh
         int       21h                      ; uzav©en° souboru

; ------ kontrola startovac° adresy programu

CojXT3:  cmp       word ptr ds:[CojXRTab-CojXBeg+14h],offset(CojXStrt-CojXBeg) ; offset ?
         jne       CojXS2                   ; nesouhlas° offset skoku
; !!!!!!!!
CojXADR4:cmp       word ptr ds:[CojXRTab-CojXBeg+16h],1234h ; souhlas° segment ?
         jne       CojXS2                   ; nesouhlas°

; ------ n†vrat registrñ

CojXS8:  popf
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax

; ------ skok do programu

CojXT5:  mov       ss,cs:[CojXSS-CojXBeg]
CojXT6:  mov       sp,cs:[CojXSP-CojXBeg]
CojXT7:  jmp       dword ptr cs:[CojXIP-CojXBeg]

CojXTxt1 db        13,'Program POSKOZEN !',13,10
         db           'Pokracovat (ENTER=ANO) ?',13,7,10,'$'

         EVEN
CojXRTab label     word                     ; tabulka adres relok. poloëek
                                            ; - naá°t† se sem tÇë z†hlav° EXE !

CojXRCS  dd        offset(CojXCS-CojXBeg)   ; relokace registru CS
CojXRSS  dd        offset(CojXSS-CojXBeg)   ; relokace registru SS

CojXCRC  dw        0                        ; kontroln° souáet programu+Pojistka
                                            ; - posouv† se za konec tabulky rel.
                                            ;   poloëek !!!

                                            ; (n†sleduje z†sobn°k)

CojXEnd  label     byte                     ; konec Cojistky (+tabulka rek.pol.)

         dw        200h dup(?)              ; z†sobn°k
Zasob    label     word

Code     ENDS
         END       Start

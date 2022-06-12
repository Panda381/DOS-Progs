
; *****************************************************************************
;
;                              F I L T
;
;                     filtrace textovòch souborñ
;
; *****************************************************************************

code     SEGMENT
         ASSUME    cs:code,ds:code
         org       100h

; ------ zobrazen° £vodn°ho textu

Start:   mov       dx,offset UvTxt          ; £vodn° text
         mov       ah,9
         int       21h                      ; zobrazen° £vodn°ho textu

; ------ p©edefinov†n° z†sobn°ku

         mov       dx,offset MemTxt         ; text - nedostatek pamàti
         cmp       sp,offset Zasob          ; je dost pamàti ?
         jb        Chyba                    ; chyba - nedostatek pamàti
         mov       sp,offset Zasob          ; novò ukazatel z†sobn°ku

; ------ zmen®en° velikosti alokaán°ho bloku programu

         mov       ah,4ah
         mov       bx,(offset(Zasob-Start)+10fh)/16 ; velikost programu
         int       21h                      ; zmen®en° velikosti programu
         jc        Chyba                    ; nàjak† chyba

; ------ vytvo©en° bufferu souborñ

         mov       bx,1ffeh                 ; maxim†ln° velikost bufferñ
         mov       ah,48h
         int       21h                      ; p©idàlen° alokaán°ho bloku pamàti
         jnc       Start3                   ; buffery OK
         mov       ah,48h
         int       21h                      ; alespo§ zmen®enò blok
         jnc       Start3                   ; buffery OK

; ------ chyba

Chyba:   push      cs
         pop       ds
         mov       ah,9
         int       21h                      ; zobrazen° chybovÇho textu
         mov       ax,4c01h
         int       21h                      ; n†vrat z programu s chybou

; ------ £schova adresy bufferu souborñ

Start3:  cmp       bx,100h                  ; alespo§ 4 KB
         jb        Chyba                    ; to je m†lo pamàti
         mov       ds:[BuffSize],bx         ; velikost bufferu
         mov       ds:[AdrBuff1],ax         ; adresa bufferu

; ------ rozbor p©°kazovÇho ©†dku

         call      Rozbor                   ; rozbor p©°kazovÇho ©†dku
         mov       dx,offset HelpTxt        ; text n†povàdy
         jc        Chyba                    ; chyba zad†n°
         cmp       byte ptr ds:[Prep],0     ; bylo nàco zad†no ?
         je        Chyba                    ; nebylo nic zad†no
         call      InitTab                  ; inicializace konverzn°ch tabulek

; ------ inicializace bufferu souborñ

         mov       bx,ds:[BuffSize]         ; velikost bufferu
         test      byte ptr ds:[Prep],30h   ; je konverze tabel†torñ a mezer ?
         jz        Start4                   ; nejsou tabel†tory a mezery
         shr       bx,1                     ; pouze polovina bufferu
Start4:  cmp       bx,1000h                 ; je buffer p©°li® velkò ?
         jb        Start42                  ; buffer je OK
         mov       bx,0fffh                 ; omezen° velikosti bufferu
Start42: mov       cl,4
         mov       dx,bx                    ; £schova velikosti bufferu
         shl       bx,cl                    ; velikost bufferu v bajtech
         mov       ds:[BuffSize],bx         ; velikost bufferu v bajtech
         mov       ax,ds:[AdrBuff1]         ; adresa vstupn°ho bufferu
         test      byte ptr ds:[Prep],30h   ; je konverze tabel†torñ a mezer ?
         jz        Start44                  ; nejsou tabel†tory a mezery
         add       ax,dx                    ; p©iáten° vstupn°ho bufferu
Start44: mov       ds:[AdrBuff2],ax         ; adresa vòstupn°ho bufferu

; ------ otev©en° vstupn°ho souboru

         mov       dx,offset Soubor1        ; jmÇno vstupn°ho souboru
         mov       ax,3d00h
         int       21h                      ; otev©en° vstupn°ho souboru
         mov       dx,offset Soub1Txt       ; chyba - soubor nenalezen
         jc        Chyba2                   ; chyba - soubor nenalezen
         mov       ds:[Soubor1I],ax         ; identifik†tor souboru

; ------ £schova data a áasu souboru

         mov       bx,ax                    ; identifik†tor souboru
         mov       ax,5700h
         int       21h                      ; poskytnut° data a áasu souboru
         mov       ds:[SoubDate],dx         ; datum souboru
         mov       ds:[SoubTime],cx         ; áas souboru

; ------ £schova atributñ souboru

         mov       ax,4300h
         mov       dx,offset Soubor1        ; jmÇno souboru
         int       21h                      ; poskytnut° atributñ souboru
         mov       ds:[SoubAtr],cx          ; atributy souboru

; ------ test, zda vòstupn° soubor jië existuje

         mov       ax,3d01h
         mov       dx,offset Soubor2        ; jmÇno vòstupn°ho souboru
         int       21h                      ; otev©en° souboru pro z†pis
         mov       bx,ax                    ; identifik†tor souboru
         jc        Start56                  ; soubor neexistuje - to je OK

; ------ test, zda je souborem za©°zen°

         mov       ax,4400h
         int       21h                      ; poskytnut° informac° o souboru
         jc        Start54                  ; nàjak† chyba
         test      dl,80h                   ; je to znakovÇ za©°zen° ?
         jnz       Start57                  ; je to znakovÇ za©°zen°

; ------ nen° za©°zen° - uzav©en° souboru

Start54: mov       ah,3eh
         int       21h                      ; uzav©en° souboru

; ------ dotaz, zda se m† soubor p©epsat

         test      byte ptr ds:[Param],1    ; automativkÇ p©eps†n° ?
         jnz       Start56                  ; soubor se m† p©epsat
         mov       dx,offset ExistTxt
         mov       ah,9
         int       21h                      ; hl†®en° - soubor existuje
         mov       ah,1
         int       21h                      ; vstup znaku z kl†vesnice

         push      ax
         mov       dx,offset CRTxt
         mov       ah,9
         int       21h                      ; od©†dkov†n° textu
         pop       ax

         cmp       al,"a"
         je        Start56                  ; m† se p©epsat
         cmp       al,"A"
         je        Start56                  ; m† se p©epsat

; ------ nep©episuje se - ukonáen° programu

         mov       ax,4c01h
         int       21h                      ; n†vrat z programu s chybou

; ------ vytvo©en° novÇho souboru

Start56: mov       dx,offset Soubor2        ; jmÇno vòstupn°ho souboru
         mov       ah,3ch
         mov       cx,ds:[SoubAtr]          ; atributy souboru
         and       cl,not 1                 ; zru®en° atributu R/O
         int       21h                      ; vytvo©en° souboru
         mov       bx,ax                    ; identifik†tor souboru
         jnc       Start57                  ; soubor vytvo©en OK

; ------ chyba vytvo©en° souboru

Start562:mov       dx,offset Soub2Txt       ; chyba - nelze vytvo©it
Chyba2:  jmp       Chyba

; ------ soubor vytvo©en OK - p©°prava registrñ ke konverzi

Start57: mov       ds:[Soubor2I],bx         ; identifik†tor vòstup. souboru
         mov       es,ds:[AdrBuff2]         ; vòstupn° buffer
         mov       ds,ds:[AdrBuff1]         ; vstupn° buffer
         xor       di,di                    ; ukl†dac° adresa
         mov       dx,cs:[BuffSize]         ; velikost bufferu
         mov       bp,cs:[Tabel]            ; á°taá tabel†toru
         xor       bx,bx                    ; á°taá nevyslanòch mezer

; ------ naáten° bloku ze vstupn°ho souboru

Start6:  call      ReadBlk                  ; naáten° bloku dat ze souboru
         jnc       Start62                  ; áten° OK

; ------ chyba áten° dat ze souboru

         mov       dx,offset ReadTxt
         jmp       short Chyba2             ; chyba áten°

; ------ p©°prava ukazatelñ pro dal®° blok

Start62: jcxz      Start8                   ; konec souboru - nejsou dal®° data

; ------ konverze fontñ v bufferu

         call      KonvFnt                  ; konverze fontñ v bufferu

; ------ konverze tabel†toru na mezery

         test      byte ptr cs:[Prep],10h   ; konverze tabel†toru na mezery ?
         jz        Start65                  ; nen° konverze tabel. na mezery
         call      KonvSpc                  ; konverze tabel†torñ na mezery
         jc        Start69                  ; chyba z†pisu

; ------ konverze mezer na tabel†tory

Start65: test      byte ptr cs:[Prep],20h   ; je konverze mezer na tabel†tory ?
         jz        Start67                  ; nen° konverze mezer na tabel†tory
         call      KonvTab                  ; konverze mezer na tabel†tory
         jc        Start69                  ; chyba z†pisu

; ------ dal®° blok dat

Start67: test      byte ptr cs:[Prep],30h   ; mezery/tabel†tory ?
         jnz       Start6                   ; jsou mezery/tabel†tory
         mov       di,cx                    ; data ve vstupn°m bufferu
         call      WritBlk                  ; z†pis bloku dat do souboru
         jnc       Start6                   ; áten° dal®°ho bloku dat

; ------ chyba z†pisu do souboru

Start69: mov       dx,offset WritTxt
         jmp       short Chyba2             ; chyba áten°

; ------ vysl†n° mezer do souboru

Start8:  or        bx,bx                    ; je nàjak† mezera ?
         jz        Start89                  ; nejsou ë†dnÇ mezery
         mov       al," "                   ; znak mezery k vysl†n°
         cld
Start82: stosb                              ; uloëen° mezery do bufferu
         dec       dx                       ; á°taá volnÇho m°sta
         jz        Start84                  ; buffer je plnò
Start83: dec       bx                       ; á°taá mezer k uloëen°
         jnz       Start82                  ; uloëen° dal®° mezery
         jmp       short Start89            ; uloëen° posledn°ho bloku dat

Start84: call      WritBlk                  ; uloëen° bufferu
         jnc       Start83                  ; z†pis OK
         jmp       short Start69            ; chyba z†pisu

; ------ uloëen° obsahu vòstupn°ho bufferu do souboru

Start89: call      WritBlk                  ; z†pis bloku do souboru
         jc        Start69                  ; chyba z†pisu

         push      cs
         pop       ds
         push      cs
         pop       es

; ------ uzav©en° vstupn°ho souboru

         mov       bx,ds:[Soubor1I]         ; vstupn° soubor
         mov       ah,3eh
         int       21h                      ; uzav©en° vstupn°ho souboru

; ------ nastaven° data a áasu vòstupn°ho souboru

         mov       dx,ds:[SoubDate]         ; datum souboru
         mov       cx,ds:[SoubTime]         ; áas souboru
         mov       bx,ds:[Soubor2I]         ; vòstupn° soubor
         mov       ax,5701h
         int       21h                      ; nastaven° data a áasu souboru

; ------ uzav©en° vòstupn°ho souboru

         mov       ah,3eh
         int       21h                      ; uzav©en° vòstupn°ho souboru

; ------ nastaven° atributñ vòstupn°ho souboru

         mov       cx,ds:[SoubAtr]          ; atributy souboru
         mov       dx,offset Soubor2        ; vòstupn° soubor
         mov       ax,4301h
         int       21h                      ; nastaven° atributñ souboru

; ------ konec programu

         mov       ax,4c00h
         int       21h                      ; konec programu




; -----------------------------------------------------------------------------
;        naáten° bloku ze souboru
; -----------------------------------------------------------------------------
; VSTUP:  DS=buffer souboru
; VùSTUP: CX=poáet naátenòch bajtñ (pouze pokud je NC)
;         SI=novò ukazatel v bufferu (=0)
;         CY=chyba áten° ze souboru (CX nedefinov†no)
; -----------------------------------------------------------------------------

ReadBlk  PROC      NEAR

; ------ £schova registrñ

         xor       si,si                    ; ukazatel v bufferu na zaá†tek
         push      ax
         push      bx
         push      dx

; ------ naáten° bloku ze souboru

         xor       dx,dx                    ; adresa v bufferu
         mov       cx,cs:[BuffSize]         ; velikost bufferu
         mov       bx,cs:[Soubor1I]         ; vstupn° soubor
         mov       ah,3fh
         int       21h                      ; áten° bloku ze souboru
         mov       cx,ax                    ; poáet naátenòch bajtñ

; ------ n†vrat registrñ

         pop       dx
         pop       bx
         pop       ax
         ret

ReadBlk  ENDP

; -----------------------------------------------------------------------------
;        uloëen° bloku do souboru
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=konec dat v bufferu
; VùSTUP:DI=ukazatel dat na zaá†tek (=0)
;        DX=á°taá bajtñ k uloëen° do bufferu
;        CY=chyba z†pisu do souboru
; -----------------------------------------------------------------------------

WritBlk  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      ds

; ------ uloëen° bloku do vòstupn°ho souboru

         mov       cx,di                    ; poáet bajtñ v bufferu
         xor       di,di                    ; nov† ukl†dac° adresa
         xor       dx,dx                    ; zaá†tek bufferu
         jcxz      WritBlk2                 ; nen° nic k z†pisu
         push      es
         pop       ds                       ; DS <- ES adresa bufferu
         mov       ah,40h
         mov       bx,cs:[Soubor2I]         ; identifik†tor
         int       21h                      ; z†pis souboru do bufferu
         jc        WritBlk2                 ; chyba z†pisu
         cmp       ax,cx                    ; bylo zaps†no v®e ?
WritBlk2:mov       dx,cs:[BuffSize]         ; velikost bufferu

; ------ n†vrat registrñ

         pop       ds
         pop       cx
         pop       bx
         pop       ax
         cld
         ret

WritBlk  ENDP

; -----------------------------------------------------------------------------
;        konverze fontñ a velk†/mal† p°smena ve vstupn°m bufferu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa naátenÇho bloku v pamàti
;        CX=velikost bloku (nesm° bòt 0 !)
; -----------------------------------------------------------------------------

KonvFnt  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      si
         push      di
         push      es

; ------ p©°prava registrñ

         push      ds
         pop       es
         mov       di,si
         mov       bh,0
         cld

; ------ dek¢dov†n° fontñ v bloku

KonvFnt1:lodsb                              ; naáten° znaku z bufferu
         mov       bl,al                    ; znak
         mov       bl,cs:[bx+FiltrU]        ; konverze velkÇ/malÇ p°smeno
         mov       al,cs:[bx+Filtr]         ; konverze znaku podle k¢du
         stosb                              ; uloëen° znaku do bufferu
         loop      KonvFnt1                 ; dek¢dov†n° dal®°ho znaku

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

KonvFnt  ENDP

; -----------------------------------------------------------------------------
;        konverze tabel†torñ na mezery
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa naátenÇho bloku v pamàti
;        CX=poáet bajtñ ve vstupn°m bufferu
;        ES:DI=ukl†dac° adresa do vòstupn°ho bufferu
;        DX=á°taá zbylòch bajtñ do konce vòstupn°ho bufferu
;        BP=á°taá zbylòch pozic do konce tabel†toru
; VùSTUP:CY=chyba z†pisu do vòstupn°ho souboru
; -----------------------------------------------------------------------------

KonvSpc  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      si
         push      cx
         cld

; ------ naáten° znaku z bufferu

KonvSpc2:clc
         jcxz      KonvSpc9                 ; konec dat
         lodsb                              ; naáten° znaku z bufferu
         dec       cx                       ; sn°ëen° á°taáe zbylòch znakñ

; ------ znak CR - inicializace ukazatele tabel†toru

         cmp       al,13                    ; je znak CR ?
         je        KonvSpc7                 ; je znak CR - novò tabel†tor

; ------ znak LF se ignoruje

         cmp       al,10
         je        KonvSpc8                 ; je LF - ignoruje se pozice

; ------ obsluha tabel†toru - vysl†n° mezer do zbytku tabel†toru

         cmp       al,9                     ; je tabel†tor ?
         jne       KonvSpc6                 ; nen° tabel†tor
         mov       al," "                   ; n†hradn° znak mezery
KonvSpc3:stosb                              ; uloëen° znaku do bufferu
         dec       dx                       ; á°taá zbylòch znakñ
         jz        KonvSpc5                 ; buffer je plnò
KonvSpc4:dec       bp                       ; á°taá pozic tabel†toru
         jnz       KonvSpc3                 ; uloëen° dal®°ho znaku
         mov       bp,cs:[Tabel]            ; novò á°taá tabel†toru
         jmp       short KonvSpc2           ; dal®° znak

KonvSpc5:call      WritBlk                  ; uloëen° obsahu bufferu
         jnc       KonvSpc4                 ; dal®° znak
         jmp       short KonvSpc9           ; chyba z†pisu do souboru

; ------ ostatn° znaky - á°t†n° pozice

KonvSpc6:dec       bp                       ; sn°ëen° á°taáe pozic tabel†toru
         jnz       KonvSpc8                 ; nen° konec
KonvSpc7:mov       bp,cs:[Tabel]            ; novò ukazatel tabel†toru

; ------ uloëen° znaku do bufferu

KonvSpc8:stosb                              ; uloëen° znaku do bufferu
         dec       dx                       ; á°taá zbylòch znakñ
         jnz       KonvSpc2                 ; dal®° znak
         call      WritBlk                  ; z†pis bufferu do souboru
         jnc       KonvSpc2                 ; dal®° bajt

; ------ n†vrat registrñ

KonvSpc9:pop       cx
         pop       si
         pop       ax
         ret

KonvSpc  ENDP

; -----------------------------------------------------------------------------
;        konverze mezer na tabel†tory
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa naátenÇho bloku v pamàti
;        CX=poáet bajtñ ve vstupn°m bufferu
;        ES:DI=ukl†dac° adresa do vòstupn°ho bufferu
;        DX=á°taá zbylòch bajtñ do konce vòstupn°ho bufferu
;        BP=á°taá zbylòch pozic do konce tabel†toru
;        BX=á°taá neuloëenòch mezer
; VùSTUP:CY=chyba z†pisu do vòstupn°ho souboru
; -----------------------------------------------------------------------------

KonvTab  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      si
         push      cx

; ------ naáten° znaku z bufferu

         cld
KonvTab1:clc
         jcxz      KonvTab9                 ; je konec dat v bufferu
         lodsb                              ; naáten° znaku z bufferu
         dec       cx                       ; sn°ëen° á°taáe zbylòch bajtñ

; ------ znak CR - inicializace ukazatele tabel†toru

         cmp       al,13                    ; je znak CR ?
         je        KonvTab3                 ; je znak CR - nov† tabel. pozice

; ------ znak LF - ignorov†n° á°taáe

         cmp       al,10                    ; je znak LF ?
         je        KonvTab4                 ; vysl†n° znaku s vypr†zdnàn°m mezer

; ------ tabel†tor - mezery se ignoruj°

         cmp       al,9                     ; je tabel†tor ?
         je        KonvTb15                 ; je tabel†tor

; ------ mezera - zvò®en° á°taáe mezer

         cmp       al," "                   ; je mezera ?
         jne       KonvTab2                 ; nen° mezera
         inc       bx                       ; zvò®en° á°taáe mezer
         dec       bp                       ; sn°ëen° tabelaán°ho á°taáe
         jnz       KonvTab1                 ; nejsou je®tà v®echny - dal®° znak

; ------ 1 mezera zñstane mezerou

         dec       bx                       ; je 1 mezera ?
         jz        KonvTab8                 ; vysl†n° 1 mezery

; ------ n†hrada mezer tabel†torem

KonvTb14:mov       al,9                     ; n†hrada znakem tabel†toru
KonvTb15:xor       bx,bx                    ; nen° ë†dn† mezera
         mov       bp,cs:[Tabel]            ; je pozice tabel†toru
         jmp       short KonvTab8           ; vysl†n° znaku tabel†toru

; ------ bàënò znak - á°t†n° pozice

KonvTab2:dec       bp                       ; á°taá zbylòch pozic
         jnz       KonvTab4                 ; nen° je®tà tabelaán° pozice
KonvTab3:mov       bp,cs:[Tabel]            ; novò á°taá tabel†toru

; ------ vysl†n° neuloëenòch mezer na vòstup

KonvTab4:or        bx,bx                    ; jsou nàjakÇ mezery ?
         jz        KonvTab8                 ; nejsou ë†dnÇ mezery
KonvTb42:push      ax                       ; £schova znaku k vysl†n°
         mov       al," "                   ; n†hradn° znak mezery
KonvTab5:stosb                              ; uloëen° znaku do bufferu
         dec       dx                       ; á°taá zbylòch znakñ
         jz        KonvTab7                 ; buffer je plnò
KonvTab6:dec       bx                       ; á°taá neuloëenòch mezer
         jnz       KonvTab5                 ; uloëen° dal®°ho znaku
         pop       ax                       ; pñvodn° znak k vysl†n°
         jmp       short KonvTab8           ; z†pis znaku

; ------ z†pis bloku dat

KonvTab7:call      WritBlk                  ; uloëen° obsahu bufferu
         jnc       KonvTab6                 ; dal®° znak
         pop       ax
         jmp       short KonvTab9           ; chyba z†pisu do souboru

; ------ z†pis znaku na vòstup

KonvTab8:stosb                              ; uloëen° znaku na vòstup
         dec       dx                       ; á°taá zbylòch znakñ
         jnz       KonvTab1                 ; dal®° znak
         call      WritBlk                  ; z†pis bloku do souboru
         jnc       KonvTab1                 ; dal®° znak

; ------ n†vrat registrñ

KonvTab9:pop       cx
         pop       si
         pop       ax
         ret

KonvTab  ENDP

; -----------------------------------------------------------------------------
;        rozbor p©°kazovÇho ©†dku (CY=chyba)
; -----------------------------------------------------------------------------

Rozbor   PROC      NEAR

; ------ p©°prava p©°kazovÇho ©†dku

         mov       si,81h                   ; zaá†tek p©°kazovÇho ©†dku
         mov       bl,ds:[si-1]             ; dÇlka p©°kazovÇho ©†dku
         mov       bh,0
         mov       byte ptr ds:[bx+si],0    ; oznaáen° konce p©°kazovÇho ©†dku

; ------ mus° bòt nàco zad†no

         call      ParSpc                   ; test, zda nàco je zad†no
         jc        Rozbor9                  ; chyba - nen° nic zad†no

; ------ rozbor parametrñ na zaá†tku

         call      RozbPar                  ; rozbor parametrñ na zaá†tku
         jc        Rozbor9                  ; chyba zad†n°

; ------ rozbor jmÇna vstupn°ho souboru

         mov       di,offset Soubor1        ; buffer vstupn°ho souboru
         call      ParFile                  ; rozbor jmÇna souboru
         jc        Rozbor9                  ; chyba zad†n°

; ------ rozbor parametrñ uprost©ed

         call      RozbPar                  ; rozbor parametrñ uprost©ed
         jc        Rozbor9                  ; chyba zad†n°

; ------ rozbor jmÇna vòstupn°ho souboru

         mov       di,offset Soubor2        ; buffer vòstupn°ho souboru
         call      ParFile                  ; rozbor jmÇna souboru
         jc        Rozbor9                  ; chyba zad†n°

; ------ rozbor parametrñ na konci

         call      RozbPar                  ; rozbor parametrñ na konci
         jc        Rozbor9                  ; chyba zad†n°

; ------ kontrola, zda nàco na ©†dku zbylo

         call      ParSpc                   ; test, zda je jië konec ©†dku
         cmc                                ; mus° bòt CY

Rozbor9: ret

Rozbor   ENDP

; -----------------------------------------------------------------------------
;        inicializace konverzn°ch tabulek
; -----------------------------------------------------------------------------

InitTab  PROC      NEAR

; ------ tabulka pro p©evod n†rodn°ch fontñ

         mov       bl,ds:[Prep]             ; p©ep°naáe
         and       bx,0fh                   ; p©ep°naáe
         shl       bx,1                     ; offset v tabulce
         mov       si,ds:[bx+TabFont]       ; adresa tabulky
         mov       di,offset Filtr0
         mov       cx,128
         cld
         rep       movsb                    ; p©enos tabulky pro p©evod fontñ

; ------ p©evod velk†/mal† p°smena - z†kladn° á†st tabulky

         mov       si,offset Filtr          ; filtr bez konverze
         test      byte ptr ds:[Prep],0c0h  ; je konverze velk†/mal† p°smena ?
         jz        InitTab2                 ; nen° konverze
         mov       si,offset FiltrD         ; mal† p°smena
         test      byte ptr ds:[Prep],80h   ; mal† p°smena ?
         jnz       InitTab2                 ; jsou mal† p°smena
         mov       si,offset FiltrU         ; jinak velk† p°smena
InitTab2:mov       di,offset FiltrU         ; ukl†dac° adresa
         mov       cx,128                   ; dÇlka tabulky
         rep       movsb                    ; p©enos z†kladn° á†sti tabulky

; ------ p©evod velk†/mal† p°smena - horn° á†st tabulky

         mov       si,offset Tb00
         mov       bl,ds:[Prep]             ; p©ep°naáe
         test      bl,0c0h                  ; je p©evod velk†/mal† p°smena ?
         jz        InitTab4                 ; nen° p©evod velk†/mal† p°smena
         and       bx,3                     ; vstupn° k¢d
         test      byte ptr ds:[Prep],80h   ; p©evod na mal† p°smena ?
         jz        InitTab3                 ; jsou velk† p°smena
         or        bl,4                     ; jinak p©°znak malòch p°smen
InitTab3:shl       bx,1
         mov       si,ds:[bx+TabUpC]        ; konverzn° tabulka
InitTab4:mov       di,offset FiltrU0
         mov       cx,128
         rep       movsb                    ; p©enos tabulky



         ret

InitTab  ENDP

; -----------------------------------------------------------------------------
;        rozbor parametrñ
; -----------------------------------------------------------------------------

RozbPar  PROC      NEAR

; ------ vypu®tàn° poá†teán°ch mezer

         mov       bl,ds:[Prep]             ; souáasnò stav p©ep°naáñ
RozbPar1:call      ParSpc                   ; vypu®tàn° mezer
         jnc       RozbPr12
RozbPr11:jmp       RozbPar8                 ; je konec textu
RozbPr12:cmp       al,"/"                   ; je p©ep°naá parametru ?
         jne       RozbPr11                 ; nen° parametr
         call      ParChr                   ; vypu®tàn° znaku "/"

; ------ naáten° prvn°ho znaku parametru

         call      ParChr                   ; naáten° znaku parametru
         jc        RozbPar9                 ; nen° znak = chyba

; ------ parametr "/U" - konverze na velk† p°smena

         cmp       al,"U"                   ; je parametr "/U" ?
         jne       RozbPar2                 ; nen° parametr "/U"
         and       bl,not 80h               ; nulov†n° parametru "/D"
         or        bl,40h                   ; p©°znak parametru "/U"
         jmp       short RozbPar1           ; dal®° parametr

; ------ parametr "/D" - konverze na mal† p°smena

RozbPar2:cmp       al,"D"                   ; je parametr "/D" ?
         jne       RozbPar3                 ; nen° parametr "/D"
         and       bl,not 40h               ; nulov†n° parametru "/U"
         or        bl,80h                   ; p©°znak parametru "/D"
RozbPr10:jmp       short RozbPar1           ; dal®° parametr

; ------ parametr "/Sn" - n†hrada tabel†toru mezerami

RozbPar3:cmp       al,"S"                   ; je parametr "/Sn" ?
         jne       RozbPar4                 ; nen° parametr "/Sn"
         and       bl,not 20h               ; nulov†n° parametru "/Tn"
         or        bl,10h                   ; p©°znak parametru "/Sn"
         jmp       short RozbPr42           ; vstup á°selnÇho parametru

; ------ parametr "/Tn" - n†hrada mezer tabel†tory

RozbPar4:cmp       al,"T"                   ; je parametr "/Tn" ?
         jne       RozbPar5                 ; nen° parametr "/Tn"
         and       bl,not 10h               ; nulov†n° parametru "/Sn"
         or        bl,20h                   ; p©°znak parametru "/Tn"
RozbPr42:mov       word ptr ds:[Tabel],8    ; implicitn° tabel†tor 8 pozic
         call      ParNum                   ; naáten° á°selnÇho parametru
         jc        RozbPr10                 ; parametr nen° zad†n
         or        ax,ax                    ; je = 0 ?
         jz        RozbPr10                 ; nespr†vnÇ zad†n° - neplat°
         mov       ds:[Tabel],ax            ; poáet pozic na tabel†tor
         jmp       short RozbPr10           ; dal®° parametr

; ------ parametr "/W" - p©epsat vòstupn° soubor bez dotazu

RozbPar5:cmp       al,"W"                   ; je parametr "/W" ?
         jne       RozbPr51                 ; nen° parametr "/W"
         or        byte ptr ds:[Param],1    ; p©°znak parametru "/W"
         jmp       short RozbPr10           ; dal®° parametr

; ------ parametr "/xy" - konverze n†rodn°ch znakñ

RozbPr51:call      RozbKod                  ; rozbor prvn°ho znaku
         jc        RozbPar6                 ; chyba - neplatnò znak
         and       bl,not 0fh               ; nulov†n° k¢du
         or        bl,bh                    ; vstupn° k¢d
         shl       bh,1
         shl       bh,1
         or        bl,bh                    ; vòstupn° k¢d
         call      ParChr                   ; naáten° druhÇho znaku k¢du
         jc        RozbPar8                 ; nen° dal®° znak
         call      RozbKod                  ; rozbor druhÇho znaku
         jc        RozbPr52                 ; nen° platnò znak
         and       bl,not 1100b             ; nulov†n° k¢du
         shl       bh,1
         shl       bh,1
         or        bl,bh                    ; vòstupn° k¢d
         jmp       short RozbPr10           ; dal®° parametr
RozbPr52:dec       si                       ; n†vrat znaku
         jmp       short RozbPr10           ; dal®° znak

; ------ neplatnò parametr

RozbPar6:stc                                ; p©°znak chyby
         jmp       short RozbPar9           ; nezn†mò parametr - chyba

RozbPar8:clc                                ; p©°znak operace OK
RozbPar9:mov       ds:[Prep],bl             ; novò stav p©ep°naáñ
         ret

RozbPar  ENDP

; -----------------------------------------------------------------------------
;        rozbor znaku n†rodn°ho k¢du (AL -> BH)
; -----------------------------------------------------------------------------

RozbKod  PROC      NEAR

         mov       bh,1                     ; k¢d Kamenickòch
         cmp       al,"K"                   ; vstupn° k¢d Kamenickòch ?
         je        RozbKod8                 ; je k¢d Kamenickòch

         mov       bh,2                     ; k¢d Latin 2
         cmp       al,"L"                   ; vstupn° k¢d Latin 2 ?
         je        RozbKod8                 ; je k¢d Latin 2

         mov       bh,3                     ; k¢d KOI 8
         cmp       al,"I"                   ; vstupn° k¢d KOI 8 ?
         je        RozbKod8                 ; je k¢d KOI 8

         mov       bh,0                     ; k¢d bez diakritiky
         cmp       al,"0"                   ; vstupn° k¢d bez diakritiky ?
         je        RozbKod8                 ; je k¢d bez diakritiky

         stc                                ; p©°znak neplatnÇho znaku
RozbKod8:ret

RozbKod  ENDP

; -----------------------------------------------------------------------------
;        rozbor á°sla
; -----------------------------------------------------------------------------

ParNum   PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      dx

; ------ naáten° á°sla

         xor       bx,bx                    ; st©adaá á°sla
         call      ParNm                    ; prvn° á°slice
         jc        ParNum9                  ; nen° zadanÇ á°slo
ParNum1: push      ax
         mov       ax,10
         mul       bx                       ; vyn†soben° st©adaáe
         mov       bx,ax                    ; nov† hodnota st©adaáe
         pop       ax
         mov       ah,0
         add       bx,ax                    ; p©iáten° á°sla
         call      ParNm                    ; dal®° á°slice
         jnc       ParNum1                  ; p©iáten° á°slice
         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

ParNum9: mov       ax,bx                    ; nast©†danÇ á°slo
         pop       dx
         pop       bx
         ret

ParNum   ENDP

; -----------------------------------------------------------------------------
;        jedna á°slice
; -----------------------------------------------------------------------------

ParNm    PROC      NEAR

         call      ParChr                   ; naáten° znaku
         jc        ParNm9                   ; nen° dal®° znak

         cmp       al,"0"
         jb        ParNm8                   ; neplatnò znak
         cmp       al,"9"
         ja        ParNm8                   ; neplatnò znak

         sub       al,"0"                   ; korekce na á°slo
         ret

ParNm8:  dec       si                       ; n†vrat znaku
         stc                                ; p©°znak chyby
ParNm9:  ret

ParNm    ENDP

; -----------------------------------------------------------------------------
;        rozbor jmÇna souboru (ES:DI=buffer, CY=nen°)
; -----------------------------------------------------------------------------

ParFile  PROC      NEAR

; ------ vypu®tàn° poá†teán°ch oddàlovaáñ

         call      ParSpc                   ; vypu®tàn° mezer
         jc        ParFile9                 ; nen° dal®° text
         cmp       al,"/"                   ; je parametr ?
         stc
         je        ParFile9                 ; je oddàlovaá

; ------ p©enesen° jmÇna souboru

ParFile2:call      ParChr                   ; naáten° jednoho znaku
         jc        ParFile6                 ; je konec textu
         je        ParFile5                 ; je oddàlovaá
         cmp       al,"/"                   ; je parametr ?
         je        ParFile5                 ; je parametr
         cld
         stosb                              ; uloëen° znaku jmÇna
         jmp       short ParFile2           ; dal®° znak

; ------ ukonáen° jmÇna

ParFile5:dec       si                       ; n†vrat ukazatele textu
ParFile6:clc                                ; p©°znak zad†n° OK
         mov       byte ptr es:[di],0       ; oznaáen° konce jmÇna souboru

ParFile9:ret

ParFile  ENDP

; -----------------------------------------------------------------------------
;        vypu®tàn° mezer z p©°kazovÇho ©†dku
; -----------------------------------------------------------------------------

ParSpc   PROC      NEAR

         call      ParChr                   ; znak z p©°kazovÇho ©†dku
         jc        ParSpc2                  ; konec p©°kazovÇho ©†dku
         je        ParSpc                   ; je oddàlovaá - vypu®tàn°
         dec       si                       ; n†vrat ukazatele na znak
ParSpc2: ret

ParSpc   ENDP

; -----------------------------------------------------------------------------
;        vstup znaku z p©°kazovÇho ©†dku
; -----------------------------------------------------------------------------

ParChr   PROC      NEAR

; ------ vstup jednoho znaku

         cld
         lodsb                              ; naáten° znaku

; ------ konverze na velkÇ p°smeno

         cmp       al,"a"
         jb        ParChr2                  ; nen° malÇ p°smeno
         cmp       al,"z"
         ja        ParChr2
         sub       al,32                    ; konverze na velkÇ p°smeno

; ------ n†hrada tabel†toru mezerou

ParChr2: cmp       al,9                     ; je tabel†tor ?
         jne       ParChr3                  ; nen° tabel†tor
         mov       al," "                   ; m†hrada mezerou

; ------ test, zda je konec ©†dku

ParChr3: cmp       al," "                   ; je oddàlovaá ?
         jae       ParChr4                  ; nen° oddàlovaá
         dec       si                       ; n†vrat ukazatele textu
ParChr4: ret

ParChr   ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

                                          ;* tabulky konverz° n†rodn°ch fontñ
TabFont  dw        Tb00                     ;   0 -> 0
         dw        TbKamCS0                 ; KAM -> 0
         dw        TbLatCS0                 ; LAT -> 0
         dw        TbKOICS0                 ; KOI -> 0

         dw        Tb00                     ;   0 -> KAM
         dw        Tb00                     ; KAM -> KAM
         dw        TbLatKam                 ; LAT -> KAM
         dw        TbKOIKam                 ; KOI -> KAM

         dw        Tb00                     ;   0 -> LAT
         dw        TbKamLat                 ; KAM -> LAT
         dw        Tb00                     ; LAT -> LAT
         dw        TbKOILat                 ; KOI -> LAT

         dw        Tb00                     ;   0 -> KOI
         dw        TbKamKOI                 ; KAM -> KOI
         dw        TbLatKOI                 ; LAT -> KOI
         dw        Tb00                     ; KOI -> KOI

                                          ;* tabulky velkòch/malòch p°smen
TabUpC   dw        Tb00                     ; bez diakritiky
         dw        TbKamUpC                 ; Kamenickòch - velk†
         dw        TbLatUpC                 ; Latin 2 - velk†
         dw        TbKOIUpC                 ; KOI 8 - velk†
         dw        Tb00                     ; bez diakritiky
         dw        TbKamDnC                 ; Kamenickòch - mal†
         dw        TbLatDnC                 ; Latin 2 - mal†
         dw        TbKOIDnC                 ; KOI 8 - mal†

; ------ filtr znakñ pro konverzi fontñ

Filtr    db          0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15
         db         16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31
         db         32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47
         db         48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63
         db         64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79
         db         80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95
         db         96, 97, 98, 99,100,101,102,103,104,105,106,107,108,109,110,111
         db        112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127

Filtr0   db        128 dup(0)               ; konverzn° tabulka 128 aë 255

; ------ filtr velkÇ/malÇ p°smeno

FiltrU   db          0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15
         db         16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31
         db         32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47
         db         48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63
         db         64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79
         db         80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95
         db         96, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79
         db         80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90,123,124,125,126,127

FiltrU0  db        128 dup(0)               ; konverzn° tabulka 128 aë 255

; ------ p©evod na mal† p°smena

FiltrD   db          0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15
         db         16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31
         db         32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47
         db         48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63
         db         64, 97, 98, 99,100,101,102,103,104,105,106,107,108,109,110,111
         db        112,113,114,115,116,117,118,119,120,121,122, 91, 92, 93, 94, 95
         db         96, 97, 98, 99,100,101,102,103,104,105,106,107,108,109,110,111
         db        112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127

; ------ tabulka bez konverze

Tb00     db        128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143
         db        144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159
         db        160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175
         db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
         db        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
         db        208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
         db        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
         db        240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255

; ------ konverzn° tabulka z k¢du Kamenickòch na velk† p°smena

TbKamUpC label     byte
         db        'ÄöêÖéÖÜÄââäãúäéè'
         db        'êííßôï¶óùôöõúùûÜ'
         db        'èãïó••¶ßõû´´',172,173,174,175
         db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
         db        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
         db        208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
         db        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
         db        240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255

; ------ konverzn° tabulka z k¢du Kamenickòch na mal† p°smena

TbKamDnC label     byte
         db        'áÅÇÉÑÉüáààç°åçÑ†'
         db        'Çëëìî¢ñ£òîÅ®åò©ü'
         db        '†°¢£§§ñì®©™™',172,173,174,175
         db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
         db        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
         db        208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
         db        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
         db        240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255

; ------ konverzn° tabulka z k¢du Latin 2 na velk† p°smena

TbLatUpC label     byte
         db        128,154,144,182,142,222,143,128,157,211,138,138,215,141,142,143
         db        144,145,145,226,153,149,149,151,151,153,154,155,155,157,158,172
         db        181,214,224,233,164,164,166,166,168,168,170,141,172,184,174,175
         db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,189,191
         db        192,193,194,195,196,197,198,198,200,201,202,203,204,205,206,207
         db        209,209,210,211,210,213,214,215,183,217,218,219,220,221,222,223
         db        224,225,226,227,227,213,230,230,232,233,232,235,237,237,221,239
         db        240,241,242,243,244,245,246,247,248,249,250,235,252,252,254,255

; ------ konverzn° tabulka z k¢du Latin 2 na mal† p°smena

TbLatDnC label     byte

         db        135,129,130,131,132,133,134,135,136,137,139,139,140,171,132,134
         db        130,146,146,147,148,150,150,152,152,148,129,156,156,136,158,159
         db        160,161,162,163,165,165,167,167,169,169,170,171,159,173,174,175
         db        176,177,178,179,180,160,131,216,173,185,186,187,188,190,190,191
         db        192,193,194,195,196,197,199,199,200,201,202,203,204,205,206,207
         db        208,208,212,137,212,229,161,140,216,217,218,219,220,238,133,223
         db        162,225,147,228,228,229,231,231,234,163,234,251,236,236,238,239
         db        240,241,242,243,244,245,246,247,248,249,250,251,253,253,254,255

; ------ konverzn° tabulka z k¢du KOI 8 na velk† p°smena

TbKOIUpC label     byte
         db        128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143
         db        144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159
         db        160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175
         db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
         db        192,225,194,227,228,229,230,199,232,233,234,235,236,237,238,239
         db        240,241,242,243,244,245,214,247,248,249,250,219,220,221,222,223
         db        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
         db        240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255

; ------ konverzn° tabulka z k¢du KOI 8 na mal† p°smena

TbKOIDnC label     byte
         db        128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143
         db        144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159
         db        160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175
         db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
         db        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
         db        208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
         db        224,193,226,195,196,197,198,231,200,201,202,203,204,205,206,207
         db        208,209,210,211,212,213,246,215,216,217,218,251,252,253,254,255

; ------ konverzn° tabulka z k¢du Kamenickòch na k¢d bez diakritiky

TbKamCS0 label     byte
         db        'CuedaDTceELIllAA'
         db        'EzZooOuUyOUSLYRt'
         db        'aiounNUOsrrR',172,173,174,175
         db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
         db        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
         db        208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
         db        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
         db        240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255

; ------ konverzn° tabulka z k¢du Latin 2 na k¢d bez diakritiky

TbLatCS0 label     byte
         db        'CueaauccleOoiZAC'
         db        'ELlooLlSsOUTtLxc'
         db        'aiouAaZzEerzCs',174,175
         db        176,177,178,179,180,'AAES',185,186,187,188,'Zz',191
         db        192,193,194,195,196,197,'Aa',200,201,202,203,204,205,206,207
         db        'dDDEdNIIe',217,218,219,220,'TU',223
         db        'O',225,'ONnnSsRUrUyYt',239
         db        240,241,242,243,244,245,246,247,248,249,250,'uRr',254,255

; ------ konverzn° tabulka z k¢du KOI 8 na k¢d bez diakritiky

TbKoiCS0 label     byte
         db        128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143
         db        144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159
         db        160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175
         db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
         db        192,'a',194,'cder',199,'uiullono'
         db        'oarstu',214,'eayz',219,220,221,222,223
         db        224,'A',226,'CDER',231,'UIULLONO'
         db        'OARSTU',246,'EAYZ',251,252,253,254,255

; ------ konverzn° tabulka z k¢du Latin 2 na k¢d Kamenickòch

TbLatKam label     byte
         db        'CÅÇaÑñccleôîiZéC'
         db        'êäçìîúåSsôöÜüLxá'
         db        '†°¢£AaíëEeøzÄsÆØ'
         db        176,177,178,179,180,'èAâS',185,186,187,188,'Zz',191
         db        192,193,194,195,196,197,'Aa',200,201,202,203,204,205,206,'x'
         db        'dDÖEÉ•ãIà',217,218,219,220,'T¶',223
         db        'ï',225,'ßNn§õ®´ó™öòùt',39
         db        '-".""≠ˆ,¯"',250,'Åû©',254,255

; ------ konverzn° tabulka z k¢du KOI 8 na k¢d Kamenickòch

TbKoiKam label     byte
         db        128,129,130,131,132,133,134,135,136,137,138,139,140,176,142,143
         db        144,145,146,147,148,149,219,151,152,153,154,155,156,157,158,178
         db        160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175
         db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
         db        '⁄†¿áÉà™ƒÅ°ñçåî§¢'
         db        'ìÑ©®ü£√Ç†òë¬',220,39,248,'≈'
         db        'øèŸÄÖâ´≥öã¶äúô•ï'
         db        'ßéûõÜó¥êèùí¡',252,'^',254,255

; ------ konverzn° tabulka z k¢du Kamenickòch na k¢d Latin 2

TbKamLat label     byte
         db        172,'ÅÇ',212,'Ñ',210,155,159,216,183,145,214,150,146,'é',181
         db        'ê',167,166,'ìî',224,133,233,236,'ôö',230,149,237,252,156
         db        '†°¢£',229,213,222,226,231,253,234,232,'/',245,174,175
         db        176,177,178,179,180,179,186,187,191,185,186,187,188,188,217,191
         db        192,193,194,195,196,197,179,186,200,201,202,203,204,205,206,205
         db        188,205,196,200,192,218,201,186,205,217,218,219,220,219,219,223
         db        'a',225,'G','p','S','s','m','t','f','T','O','d','0','/','E','N'
         db        '=','+','>','<',218,217,246,'=',248,250,250,'V','n','2',254,255

; ------ konverzn° tabulka z k¢du KOI 8 na k¢d Latin 2

TbKoiLat label     byte
         db        128,129,130,131,132,133,134,135,136,137,138,139,140,176,142,143
         db        144,145,146,147,148,149,219,151,152,153,154,155,156,157,158,178
         db        160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175
         db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
         db        '⁄','†','¿',159,212,216,234,'ƒ',129,'°',133,146,150,148,229,'¢'
         db        147,132,253,231,156,'£','√','Ç','†',236,167,'¬',243, 39,248,'≈'
         db        'ø',181,'Ÿ',172,210,183,232,'≥','ö',214,222,145,149,'ô',213,224
         db        226,142,252,230,155,233,'¥','ê',181,237,166,'¡',249,'^',254,255

; ------ konverzn° tabulka z k¢du Kamenickòch na k¢d KOI 8

TbKamKoi label     byte
         db        227,200,215,196,209,228,244,195,197,229,235,233,204,203,241,225
         db        247,218,250,208,205,239,202,245,217,237,232,243,236,249,242,212
         db        193,201,207,213,206,238,234,240,211,210,198,230,131,173,174,175
         db        141,141,159,231,246,246,246,224,224,246,231,224,226,226,226,224
         db        194,251,219,214,199,223,214,214,194,192,251,219,214,199,223,251
         db        251,219,219,194,194,192,192,223,223,226,192,150,220,221,222,223
         db        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
         db        240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255

; ------ konverzn° tabulka z k¢du Latin 2 na k¢d KOI 8

TbLatKoi label     byte
         db        128,200,215,'a',209,202,'c','c','l','e',237,208,'i','Z',241,'C'
         db        247,235,203,208,205,236,204,'S','s',237,232,244,212,'L','x',195
         db        193,201,207,213,'A','a',250,218,'E','e',224,'z',227,'s',174,175
         db        141,141,159,231,246,225,'A',229,'S',246,231,224,226,'Z','z',224
         db        194,251,219,214,199,223,'A','a',194,192,251,219,213,199,223,'x'
         db        'd','D',228,'E',196,238,233,'I',197,226,192,150,220,'T',234,223
         db        239,225,240,'N','n',206,243,211,230,245,198,232,217,249,'t', 39
         db        '-',252,'.',220,220,131,':',',',222,252,254,200,242,210,254,255

UvTxt    db        'FILT V1.0 - filtrace souboru; (c) Miroslav Nemecek',13,10,'$'

MemTxt   db        'Chyba - nedostatek pameti !',7,13,10,'$'

Soub1Txt db        'Chybne zadani vstupniho souboru - soubor nenalezen !',13,10,'$'
Soub2Txt db        'Chybne zadani vystupniho souboru - soubor nelze vytvorit !'
CRTxt    db        13,10,'$'
ExistTxt db        'Vystupni soubor jiz existuje. Chcete jej prepsat (A=ano) ? $'

ReadTxt  db        'Chyba cteni ze vstupniho souboru !',13,10,'$'
WritTxt  db        'Chyba zapisu do vystupniho souboru !',13,10,'$'

HelpTxt  db        'Zadejte:  FILT  vstupni_soubor  vystupni_soubor  prepinace',13,10
         db        'Prepinace:  /U  - konverze na velka pismena',13,10
         db        '            /D  - konverze na mala pismena',13,10
         db        '            /Sn - nahrada tabelatoru mezerami',13,10
         db        '                  n=pocet pozic na tabelator (implicitne 8)',13,10
         db        '            /Tn - nahrada mezer tabelatory',13,10
         db        '                  n=pocet pozic na tabelator (implicitne 8)',13,10
         db        '            /xy - konverze narodnich fontu',13,10
         db        '                   x=vstupni kod souboru K,L,I',13,10
         db        '                   y=vystupni kod souboru K,L,I,0',13,10
         db        '                       K=kod Kamenickych (KEYBCS2)',13,10
         db        '                       L=kod Latin 2',13,10
         db        '                       I=kod KOI 8 (TEXT602)',13,10
         db        '                       0=odstraneni diakritiky',13,10
         db        '            /W  - prepsani vystupniho souboru bez dotazu',13,10
         db        'Zadanim vstupniho kodu parametrem /xy (nebo pouze /x) se provadi',13,10
         db        'konverze prepinaci /U a /D tez pro narodni znaky s diakritikou.',13,10
         db        '$'

Prep     db        0                        ; p©ep°naáe
                                            ;   bit 0,1: 0=zdroj bez diakritiky
                                            ;            1=zdroj Kamenickòch
                                            ;            2=zdroj Latin 2
                                            ;            3=zdroj KOI 8
                                            ;   bit 2,3: 0=vòstup bez diakritiky
                                            ;            1=vòstup Kamenickòch
                                            ;            2=vòstup Latin 2
                                            ;            3=vòstup KOI 8
                                            ;   bit 4: 1=tabel†tory na mezery
                                            ;   bit 5: 1=mezery na tabel†tory
                                            ;   bit 6: 1=mal† p°smena na velk†
                                            ;   bit 7: 1=velk† p°smena na mal†

Param    db        0                        ; parametry
                                            ;   bit 0: 1=p©epsat soubor bez dotazu

Tabel    dw        8                        ; poáet pozic na tabel†tor

AdrBuff1 dw        0                        ; adresa vstupn°ho bufferu
AdrBuff2 dw        0                        ; adresa vòstupn°ho bufferu
BuffSize dw        0                        ; velikost bufferu (bajtñ)

NumBuff1 dw        0                        ; poáet bajtñ ve vstupn°m bufferu

SoubDate dw        0                        ; datum souboru
SoubTime dw        0                        ; áas souboru
SoubAtr  dw        0                        ; atributy souboru

Soubor1I dw        0                        ; identifik†tor vstupn°ho souboru
Soubor2I dw        0                        ; identifik†tor vòstupn°ho souboru
Soubor1  db        128 dup(0)               ; jmÇno vstupn°ho souboru
Soubor2  db        128 dup(0)               ; jmÇno vòstupn°ho souboru

         dw        200h                     ; z†sobn°k
Zasob    label     word                     ; konec programu, z†sobn°k

code     ENDS
         END       Start

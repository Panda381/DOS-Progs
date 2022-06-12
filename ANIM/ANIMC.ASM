
; *****************************************************************************
;
;                                A N I M C
;
;          kompil†tor animaán°ho programu ANIM (vyëaduje 180 KB pamàti)
;
; *****************************************************************************

Code     SEGMENT   para
         ASSUME    cs:Code,ds:Data,ss:Stack

PUBLIC   Animc
Animc:                                      ; start programu (kompil†toru)

; ------ p©edefinov†n° z†sobn°ku na vrchol pamàti

         cli                                ; z†kaz p©eru®en°
         mov       ax,ds:[2]                ; segment s koncem pamàti
         sub       ax,1000h                 ; rezerva 64 KB
         mov       ss,ax                    ; segment z†sobn°ku
         mov       sp,0fff8h                ; offset z†sobn°ku
         sti                                ; povolen° p©eru®en°

; ------ oznaáen° konce zad†n° p©°kazovÇho ©†dku

         mov       bl,ds:[80h]              ; poáet znakñ p©°kazu
         mov       bh,0
         mov       byte ptr ds:[bx+81h],0   ; oznaáen° konce textu

; ------ kontrola volnÇ pamàti, inicializace segmentovòch registrñ

         mov       dx,offset MemTxt         ; text - nedostatek pamàti
         mov       ax,SEG Interp            ; segment s interpreterem
         add       ax,2800h                 ; rezerva 160 KB
         cmp       ax,ds:[2]                ; je dostatek pamàti ?
         mov       ax,SEG Data              ; datovò segment
         mov       ds,ax                    ; DS <- datovò segment
         jae       Animc8                   ; chyba - nedostatek pamàti
         mov       ds:[SegPSP],es           ; £schova segmentu PSP
         mov       es,ax                    ; datovò segment

; ------ zobrazen° £vodn°ho textu

         mov       dx,offset UvTxt          ; £vodn° text
         mov       ah,9
         int       21h                      ; zobrazen° £vodn°ho textu

; ------ rozbor zad†n° zdrojovÇho souboru

         cld                                ; smàr nahoru
         mov       si,81h                   ; zaá†tek textu
         call      RozbSpc                  ; vypustàn° oddàlovaáñ z textu
         mov       dx,offset ZdrojTxt       ; text - zadejte soubor
         jc        Animc8                   ; chyba - nen° nic zad†no
         mov       di,offset Soubor         ; buffer k uloëen° jmÇna souboru
Animc1:  call      RozbCh                   ; áten° znaku ze souboru
         jc        Animc3                   ; nen° dal®° znak
         cmp       al,"/"                   ; je oddàlovaá parametrñ ?
         je        Animc2                   ; jsou parametry
         cmp       al,","                   ; je oddàlovac° á†rka ?
         je        Animc2                   ; je oddàlovac° á†rka
         cmp       al," "                   ; je oddàlovaá ?
         jbe       Animc2                   ; je oddàlovaá
         stosb                              ; uloëen° znaku do bufferu
         jmp       short Animc1             ; dal®° znak
Animc2:  dec       si                       ; n†vrat posledn°ho znaku
Animc3:  xor       al,al                    ; ukonáovac° bajt 0
         mov       bx,di                    ; £schova konce jmÇna
         stosb                              ; uloëen° ukoáovac°ho bajtu 0

; ------ nalezen° p©°padnÇ p©°pony jmÇna souboru

Animc4:  dec       di                       ; nastaven° na posledn° znak
         cmp       byte ptr ds:[di],"."     ; je p©°pona zadan† ?
         je        Animc6                   ; p©°pona je zadan†
         cmp       byte ptr ds:[di],"\"     ; je oddàlovaá cesty ?
         je        Animc5                   ; p©°pona nen° zadan†
         cmp       di,offset Soubor         ; bude jië p©ed zaá†tkem jmÇna ?
         ja        Animc4                   ; nebude je®tà p©ed zaá†tkem jmÇna

; ------ nastaven° implicitn° p©°pony

Animc5:  mov       di,bx                    ; konec specifikace souboru
         mov       si,offset PripAni        ; implicitn° p©°pona .ANI
         mov       cx,5                     ; poáet bajtñ p©°pony
         cld                                ; smàr nahoru
         rep       movsb                    ; nastaven° implicitn° p©°pony
         mov       di,bx                    ; adresa p©°pony

; ------ otev©en° zdrojovÇho souboru

Animc6:  mov       dx,offset Soubor         ; jmÇno zdrojovÇho souboru
         mov       ax,3d00h                 ; funkce otev©en° pro áten°
         int       21h                      ; otev©en° souboru pro áten°
         mov       ds:[ZdrojId],ax          ; identifik†tor zdrojovÇho souboru
         jnc       Animc9                   ; soubor otev©en OK

; ------ chyba zad†n° zdrojovÇho souboru, jin† chyba

Animc7:  mov       dx,offset FndTxt         ; text - soubor nenalezen
Animc8:  mov       ah,9
         int       21h                      ; zobrazen° chybovÇho textu
         mov       ax,4c01h
         int       21h                      ; n†vrat s chybou

; ------ sestaven° jmÇna c°lovÇho souboru

Animc9:  mov       si,offset PripExe        ; p©°pona vòstupn°ho souboru EXE
         mov       cx,5
         rep       movsb                    ; nastaven° p©°pony souboru EXE

; ------ vytvo©en° c°lovÇho souboru

         mov       ah,3ch                   ; funkce vytvo©en° souboru
         xor       cx,cx                    ; atributy souboru
         int       21h                      ; vytvo©en° c°lovÇho souboru
         mov       dx,offset CilTxt         ; text - soubor nelze vytvo©it
         jc        Animc8                   ; chybnÇ zad†n° jmÇna souboru
         mov       ds:[CilId],ax            ; identifik†tor c°lovÇho souboru

; ------ uloëen° interpreteru programu

         push      ds
         mov       ax,SEG Interp            ; segment s interpreterem
         mov       ds,ax                    ; segment z†hlav° interpreteru
         mov       cx,ax                    ; segment z†hlav° interpreteru
         add       cx,ds:[8]                ; zvò®en° segmentu o z†hlav° EXE
         mov       ds,cx                    ; segment s interpreterem
         add       cx,ds:[2]                ; segment konce interpreteru
         sub       cx,ax                    ; dÇlka interpreteru v odstavc°ch
         shl       cx,1
         shl       cx,1
         shl       cx,1
         shl       cx,1                     ; dÇlka interpreteru v bajtech
         pop       ds
         call      WritProg                 ; uloëen° interpeteru do souboru

; ------ inicializace bufferñ programu

         mov       ax,SEG Interp            ; segment s interpreterem
         add       ax,1000h                 ; buffer 64 KB
         mov       ds:[FlagBuf],ax          ; segment s tabulkou n†và®t°
         add       ax,1000h                 ; buffer 64 KB
         mov       ds:[SrcBuf],ax           ; segment vstupn°ho bufferu 2000h B.

; ------ inicializace bufferu pro p©eklad programu (datov† á†st)

         mov       word ptr ds:[ProgNum],2  ; inicializace ukazatele v bufferu
         push      ds
         mov       ds,ds:[ProgSeg]          ; segment s bufferem programu
         mov       word ptr ds:[0],2        ; dÇlka datovÇho bufferu programu
         pop       ds

; ------ kompilace programu

         call      Compil                   ; kompilace programu

; ------ z†pis programu do souboru

         mov       cx,ds:[ProgNum]          ; poáet bajtñ v bufferu
         cmp       cx,ds:[SizProg]
         jbe       Anixx1
         mov       ds:[SizProg],cx          ; £schova velikosti programu
Anixx1:  call      WritProg                 ; z†pis dat. promànnòch do souboru

; ------ z†pis koncovÇho objektu 0

         push      ds
         mov       ds,ds:[ProgSeg]          ; segment s programem
         mov       word ptr ds:[0],0        ; á°slo objektu 0
         pop       ds
         mov       cx,2                     ; poáet bajtñ k z†pisu
         call      WritProg                 ; z†pis koncovÇho objektu 0

; ------ nastaven° z†hlav° programu

         mov       bx,ds:[CilId]            ; c°lovò soubor
         xor       cx,cx
         xor       dx,dx
         mov       ax,4202h
         int       21h                      ; zji®tàn° velikosti programu

         mov       cx,512
         div       cx                       ; p©epoáet na str†nky
         or        dx,dx                    ; je bajt v posledn° str†nce ?
         jz        Animca                   ; v posledn° str†nce nen° bajt
         inc       ax                       ; str†nka + 1
Animca:
         mov       word ptr ds:[CilSize],dx ; velikost vòstupn°ho souboru
         mov       word ptr ds:[CilSize+2],ax

         mov       dx,2
         mov       cx,0
         mov       ax,4200h
         int       21h                      ; ukazatel na offset souboru 2

         mov       dx,offset CilSize
         mov       ah,40h
         mov       cx,4
         int       21h                      ; z†pis novÇ velikosti programu

; ------ kontrola, zda byl program

         mov       dx,offset ErrMain        ; chyba - nen° procedura MAIN
         cmp       byte ptr ds:[ParMain],0  ; byla hlavn° procedura ?
         je        Navrat0                  ; nebyla hlavn° procedura
         mov       dx,offset ErrClos        ; chyba - procedura neuzav©ena
         cmp       byte ptr ds:[ProgLev],2  ; zñstala otev©en† procedura ?
         je        Navrat0                  ; zñstala otev©en† procedura

         jmp       short Navrat

; ------ chyba

PUBLIC   Navrat0
Navrat0: mov       ah,9
         int       21h                      ; zobrazen° chybovÇho textu
         inc       word ptr ds:[CitChyb]    ; zvò®en° á°taáe chyb


PUBLIC   Navrat
Navrat:

; ------ zobrazen° volnÇho m°sta

         mov       dx,offset FreeTxt        ; text - Volnò prostor
         mov       ah,9
         int       21h                      ; zobrazen° textu
         mov       ax,ds:[SizProg]          ; poáet bajtñ programu
         neg       ax                       ; volnÇ m°sto
         call      DispNum                  ; zobrazen° volnÇho prostoru
         mov       dx,offset FreeTxt1       ; text "data"
         mov       ah,9
         int       21h
         mov       ax,ds:[SizDat]           ; poáet bajtñ datovÇho segmentu
         neg       ax                       ; volnÇ m°sto
         call      DispNum                  ; zobrazen° volnÇho prostoru
         mov       dx,offset FreeTxt2       ; text "Symboly"
         mov       ah,9
         int       21h
         mov       ax,-70                   ; maxim†ln° konec tabulky symbolñ
         sub       ax,ds:[FlagNum]          ; volnÇ m°sto
         call      DispNum                  ; zobrazen° volnÇho m°sta
         mov       dx,offset FreeTxt3       ; zbytek textu
         mov       ah,9
         int       21h                      ; od©†dkov†n°

; ------ zobrazen° poátu chyb

         mov       dx,offset Err000         ; text - Poáet chyb
         mov       ah,9
         int       21h                      ; zobrazen° textu chyby
         mov       ax,ds:[CitChyb]          ; poáet chyb
         push      ax                       ; £schova poátu chyb
         call      DispNum                  ; zobrazen° poátu chyb
         mov       dx,offset UvTxt1         ; text od©†dkov†n°
         mov       ah,9
         int       21h                      ; od©†dkov†n° textu

; ------ uzav©en° souborñ

         mov       bx,ds:[ZdrojId]          ; identifik†tor zdrojovÇho souboru
         mov       ah,3eh
         int       21h                      ; uzav©en° zdrojovÇho souboru
         mov       bx,ds:[CilId]            ; identifik†tor c°lovÇho souboru
         mov       ah,3eh
         int       21h                      ; uzav©en° c°lovÇho souboru

; ------ konec programu

         pop       ax                       ; n†vrat poátu chyb
         or        al,ah                    ; byla nàjak† chyba ?
         jz        Animcx                   ; nebyla ë†dn† chyba
         mov       dx,offset Soubor         ; jmÇno vòstupn°ho souboru
         mov       ah,41h                   ; funkce zru®en° souboru
         int       21h                      ; zru®en° vòstupn°ho souboru
         mov       al,1                     ; k¢d chyby 1
Animcx:  mov       ah,4ch
         int       21h                      ; n†vrat z programu bez chyby

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;
;                      Rozbor p©°kazovÇho ©†dku
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

; -----------------------------------------------------------------------------
;        Vypustàn° oddàlovaáñ z p©°kazovÇho ©†dku
; -----------------------------------------------------------------------------

PUBLIC   RozbSpc
RozbSpc: call      RozbCh
         je        RozbSpc                  ; je mezera - vypustàn°
         jc        RozbSpc2                 ; je konec textu
         dec       si                       ; n†vrat posledn°ho znaku
RozbSpc2:ret

; -----------------------------------------------------------------------------
;        Vstup znaku z p©°kazovÇho ©†dku SI (CY=konec)
; -----------------------------------------------------------------------------

PUBLIC   RozbCh
RozbCh:  push      ds
         mov       ds,ds:[SegPSP]           ; segment PSP
         cld                                ; smàr nahoru
         lodsb                              ; áten° znaku
         call      UpCase                   ; p©evod znaku na velkÇ p°smeno

; ------ n†hrada tabel†toru mezerou

         cmp       al,9                     ; je tabel†tor ?
         jne       RozbCh2                  ; nen° tabel†tor
         mov       al," "                   ; n†hrada mezerou

; ------ kontrola, zda je oddàlovaá

RozbCh2: cmp       al," "                   ; je oddàlovaá ?
         jae       RozbCh3                  ; nen° oddàlovaá
         dec       si                       ; konec - n†vrat posledn°ho znaku

RozbCh3: pop       ds
         ret

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;
;                            Kompil†tor
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞


; -----------------------------------------------------------------------------
;        Kompilace programu
; -----------------------------------------------------------------------------

PUBLIC   Compil
Compil:  xor       ax,ax                    ; AX <- 0
         push      ax                       ; identifik†tor konce ©etàzce cyklñ

; ------ nalezen° dal®°ho p©°kazu

Compil0: call      InpSpc                   ; nalezen° zaá†tku dal®°ho slova
         jnc       Compil01                 ; je dal®° znak
Compil00:jmp       CompRet                  ; nen° dal®° znak
Compil01:cmp       al,";"                   ; je pr†zdnò p©°kaz ?
         je        Compil0                  ; je pr†zdnò p©°kaz - dal®°
         call      RetCh                    ; n†vrat nalezenÇho znaku

; ------ £schova odkazu na ©†dek s p©°kazem (pro zobrazen° chyby)

Compil1: mov       ax,word ptr ds:[UkazRad] ; souáasnò ukazatel ©†dku - LOW
         mov       word ptr ds:[ErrARad],ax ; ukazatel ©†dku s chybou - LOW
         mov       ax,word ptr ds:[UkazRad+2] ; souáasnò ukazatel ©†dku - HIGH
         mov       word ptr ds:[ErrARad+2],ax ; ukazatel ©†dku s chybou - HIGH
         mov       ax,ds:[CitRad]           ; souáasnÇ á°slo ©†dku
         mov       ds:[ErrNRad],ax          ; á°slo ©†dku s chybou

; ------ naáten° identifik†toru povelu, identifikace konce p©ekladu

         mov       bp,sp                    ; ukazatel na cykly v z†sobn°ku
         call      ReadIdnt                 ; áten° identifik†toru
         jnc       Compil4                  ; je platnò identifik†tor

; ------ chyba - neplatnò symbol (hl†®en° chyby a nalezen° konce p©°kazu)

Compil2: mov       dx,offset Err001         ; chyba - Neplatnò symbol
Compil3: call      DispErr                  ; zobrazen° textu chyby
Compil32:call      InpSpc                   ; zru®en° znakñ oddàlovaáe
         jc        Compil00                 ; nen° dal®° znak
         cmp       al,";"                   ; je konec p©°kazu ?
         jne       Compil32                 ; nalezen° konce p©°kazu
         jmp       short Compil0            ; p©eklad dal®°ho znaku

; ------ nalezen° identifik†toru v tabulce vnit©n°ch procedur

Compil4: call      SrcIdnt                  ; nalezen° slova v intern° tabulce
         jc        Compil5                  ; intern° identifik†tor nenalezen

; ------ je intern° kl°áovÇ slovo - kontrola opr†vnànosti

                                          ;* deklaraán° á†st programu
         mov       bl,ds:[ProgLev]          ; stupe§ programu
         cmp       bl,0                     ; je zaá†tek programu ?
         jne       Comp43                   ; nen° zaá†tek programu

         mov       dx,offset Err019         ; LINK nesm° bòt v deklar. á†sti
         cmp       al,0                     ; je LINK ?
         je        Compil3                  ; chyba - LINK nen° povoleno
         cmp       al,5                     ; maxim†lnà povoleno PROC
         jbe       Comp4c                   ; povoleno
         jmp       short Compil3            ; chyba - nesm° bòt v deklar. á†sti

                                          ;* vnit©n° á†st, PROC nen° otev©ena
Comp43:  cmp       bl,1                     ; je vnit©n° á†st - uzav©en† PROC ?
         jne       Comp46                   ; nen° vnit©n° á†st

         cmp       al,0                     ; je LINK ?
         je        Comp4c                   ; je LINK - OK
         cmp       al,5                     ; je PROC ?
         je        Comp4c                   ; je PROC - OK
         jb        Comp47                   ; je men®° - test opr†vnànosti
Comp44:  mov       dx,offset Err011         ; text - mus° bòt v procedu©e
         jmp       short Compil3            ; hl†®en° chyby

                                          ;* vnit©n° á†st, PROC je otev©ena
Comp46:  cmp       bl,2                     ; je vnit©n° á†st - otev©en† PROC ?
         jne       Comp49                   ; nen° vnit©n° á†st

         mov       dx,offset Err008         ; text - LINK nesm° bòt uvnit© proc.
         cmp       al,0                     ; je LINK ?
         je        Compil3                  ; zobrazen° chybovÇho hl†®en°

Comp47:  mov       dx,offset Err003         ; text - BYTE sm° bòt jen v deklar.
         cmp       al,2                     ; je BYTE ?
         jb        Comp4c                   ; je INCLUDE - OK
         cmp       al,4                     ; je STRING ?
         jbe       Compil3                  ; chyba - nesm° bòt
         jmp       short Comp4c             ; ostatn° OK

                                          ;* je konec programu
Comp49:  cmp       al,0                     ; je povoleno pouze LINK
         je        Comp4c                   ; povolen† funkce

                                          ;* chyba - za LINK je program
         mov       dx,offset Err007         ; chyba - nesmi n†sledovat program
         call      DispErr                  ; zobrazen° textu chyby
         jmp       short CompRet            ; konec programu

; ------ intern° identifik†tor nalezen a povolen

Comp4c:  mov       ds:[LastIdn],al          ; £schova identifik†toru
         call      OutCh                    ; uloëen° identifik†toru povelu
         mov       bh,0
         mov       bl,ds:[si]               ; dÇlka slova
         mov       ax,ss:[bp]               ; k¢d konstrukce v z†sobn°ku
         call      word ptr ds:[si+bx+1]    ; vyvol†n° obsluhy procedury
         cmp       byte ptr ds:[LastIdn],24 ; je procedura ?
         jb        Compil02                 ; nen° bàën† procedura
         call      TestKon                  ; test, zda je konec p©°kazu
Compil02:jmp       Compil0                  ; p©eklad dal®°ho slova

; ------ nen° vnit©n° identifik†tor - pokus o nalezen° v uëivatelskÇ tabulce

Compil5: xor       al,al                    ; p©°znak - n†và®t° nedefinov†no
         call      StorFlg                  ; pokus o nalezen° v tabulce
         jnc       Compil53                 ; n†và®t° nebylo v tabulce nalezeno
         test      al,1                     ; bylo jmÇno definov†no ?
         jz        Compil53                 ; jmÇno nebylo dosud definov†no

; ------ je uëivatelsk† procedura

         test      al,2                     ; je to procedura ?
         jz        Compil51                 ; je to promànn†
         mov       al,0ffh                  ; p©°znak uëivatelskÇ procedury
         call      OutCh                    ; uloëen° p©°znak uëivat. procedury
         mov       ax,es:[di+1]             ; adresa symbolu
         call      OutWrd                   ; uloëen° adresy
         call      TestKon                  ; test konce p©°kazu ";"
         jmp       short Compil02           ; dal®° slovo

; ------ je promànn† - sestaven° k¢du promànnÇ

Compil51:mov       al,0f8h                  ; p©°znak promànnÇ
         test      byte ptr es:[di],4       ; je WORD ?
         jz        Compil56                 ; je BYTE
         or        al,1                     ; p©°znak WORD
Compil56:test      byte ptr es:[di],10h     ; je index ?
         jz        Compil57                 ; nen° index
         or        al,2                     ; p©°znak indexu
Compil57:call      OutCh                    ; uloëen° p©°znaku promànnÇ

; ------ adresa promànnÇ

         mov       ax,es:[di+1]             ; adresa symbolu
         call      OutWrd                   ; uloëen° adresy

; ------ pro indexovanou poloëku definice argumentu

         test      byte ptr es:[di],10h     ; je index ?
         jz        Compil58                 ; nen° index
         mov       cx,1                     ; 1 argument
         call      Argum                    ; dek¢dov†n° argumentu

; ------ test p©i©azen°

Compil58:call      InpPri                   ; test, zda n†sleduje p©°©azen° ":="
         mov       dx,offset Err004         ; chyba - :=
         jc        Compil35                 ; chyba definice promànnÇ
         call      Vyraz                    ; uloëen° vòrazu do programu
         jc        Compil35                 ; chyba vòrazu
         call      TestKon                  ; test konce p©°kazu ";"
         jmp       short Compil02           ; dal®° p©°kaz

; ------ chyba - nezn†mÇ jmÇno procedury nebo promànnÇ

Compil53:mov       dx,offset Err002         ; text chyby - identifik. nenalezen
Compil35:jmp       Compil3                  ; hl†®en° chyby

; ------ n†vrat - zji®tàn° neukonáenòch cyklñ a podm°nek

; V z†sobn°ku 4 slova:
; SS:[BP+n+4] (DWORD)   ukazatel ©†dku v souboru
; SS:[BP+n+2] (WORD)    á°slo ©†dku se zaá†tkem konstrukce
; SS:[BP+2]  n*(WORD)   adresy k proveden° relokace konstrukce
; SS:[BP+1] (BYTE)      poáet slov adres k relokaci (=n)
; SS:[BP+0] (BYTE)      00h - konec vno©enòch konstrukc°
;
;                       10h - PROC
;                                       ;(; v z†sob.:<- xENDPROC (pro RETURN))
;
;                       20h - IF-THEN       ; v z†sob.:<- ENDIF,ELSE (IF nespl.)
;                       21h - IF-THEN-ELSE  ; v z†sob.:<- ENDIF (konec THEN)
;
;                       30h - DO            ; v z†sob.:<- xENDDO (ON)
;                                           ; v z†sob.: zaá†tek cyklu pro ENDDO
;                       (31h - FOR)
;
;                       40h - CASE-IN       ; v z†sob.:<- ENDCASE,IN,OUT (ne-IN)
;                       41h - OUT           ; v z†sob.:<- ENDCASE (konec IN)

; ------ test uzav©en° procedur a funkc°

PUBLIC   CompRet
CompRet: mov       bp,sp
         call      ClosIf                   ; uzav©en° podm°nek a cyklñ
         call      ClosProc                 ; uzav©en° procedur
         cmp       byte ptr ss:[bp],0       ; je jië konec ?
         jne       CompRet                  ; nen° konec - dal®°

         pop       ax                       ; zru®en° identifik†toru 0
         ret

; -----------------------------------------------------------------------------
;        Test ukonáen° procedur (v z†sobn°ku sm° bòt jen n†vratov† adresa)
; -----------------------------------------------------------------------------

PUBLIC   ClosProc
ClosProc:pop       word ptr ds:[RetClose]   ; £schova n†vratovÇ adresy

; ------ test, zda je procedura otev©ena

ClosPrc1:mov       bp,sp
         mov       ax,ss:[bp]               ; identifik†tor konstrukce
         cmp       al,10h                   ; je identifik†tor PROC ?
         jne       ClosPrc9                 ; nen° PROC - konec

; ------ zobrazen° textu chyby

         mov       dx,offset Err010         ; text - procedura nen° uzav©ena
         call      ClosDisp                 ; zobrazen° textu chyby
         jmp       short ClosPrc1           ; dal®° test

ClosPrc9:jmp       word ptr ds:[RetClose]   ; n†vrat z procedury

; -----------------------------------------------------------------------------
;        Test ukonáen° konstrukc° (v z†sobn°ku sm° bòt jen n†vratov† adresa)
; -----------------------------------------------------------------------------

PUBLIC   ClosIf
ClosIf:  pop       word ptr ds:[RetClose]   ; £schova n†vratovÇ adresy

; ------ test, zda je nàkter† konstrukce otev©ena

ClosIf1: mov       bp,sp
         mov       ax,ss:[bp]               ; identifik†tor konstrukce
         cmp       al,20h                   ; je identifik†tor PROC ?
         jb        ClosIf9                  ; je PROC nebo konec - OK

; ------ zji®tàn° textu chyby

         mov       dx,offset Err020         ; text - IF neuzav©en
         cmp       al,30h                   ; je otev©en IF ?
         jb        ClosIf3                  ; je otev©en IF
         mov       dx,offset Err031         ; text - DO neuzav©en
         cmp       al,30h                   ; je cyklus DO ?
         jb        ClosIf3                  ; je otev©en DO
         mov       dx,offset Err040         ; text - CASE neuzav©eno
ClosIf3: call      ClosDisp                 ; zobrazen° textu chyby
         jmp       short ClosIf1            ; dal®° konstrukce

ClosIf9: jmp       word ptr ds:[RetClose]   ; n†vrat z procedury

; -----------------------------------------------------------------------------
;        Zobrazen° chyby neuzav©en° (v z†sobn°ku sm° bòt jen n†vratov† adresa)
; -----------------------------------------------------------------------------

PUBLIC   ClosDisp
ClosDisp:pop       word ptr ds:[RetDisp]    ; £schova n†vratovÇ adresy

; ------ n†vrat parametrñ textu chyby

         pop       ax                       ; zru®en° k¢du konstrukce
         or        ah,ah                    ; je nàjakÇ slovo ?
         jz        ClosDis2                 ; nen° ë†dnÇ slovo
ClosDis1:pop       cx                       ; zru®en° slova ze z†sobn°ku
         dec       ah                       ; sn°ëen° á°taáe slov
         jnz       ClosDis1                 ; dal®° slovo
ClosDis2:pop       cx                       ; n†vrat á°sla ©†dku
         pop       ax                       ; n†vrat adresy ©†dku - LOW
         pop       bx                       ; n†vrat adresy ©†dku - HIGH

; ------ £schova souáasnòch parametrñ ©†dku

         push      word ptr ds:[ErrARad+2]  ; adresa ©†dku - HIGH
         push      word ptr ds:[ErrARad]    ; adresa ©†dku - LOW
         push      word ptr ds:[ErrNRad]    ; á°slo ©†dku

; ------ nastaven° novòch ukazatelñ ©†dku

         mov       ds:[ErrNRAd],cx          ; á°slo ©†dku
         mov       word ptr ds:[ErrARad],ax ; adresa ©†dku - LOW
         mov       word ptr ds:[ErrARad+2],bx ; adresa ©†dku - HIGH

; ------ zobrazen° chybovÇho hl†®en°

         call      DispErr                  ; zobrazen° chybovÇho hl†®en°

; ------ n†vrat ukazatelñ ©†dku

         pop       word ptr ds:[ErrNRad]    ; á°slo ©†dku
         pop       word ptr ds:[ErrARad]    ; adresa ©†dku - LOW
         pop       word ptr ds:[ErrARad+2]  ; adresa ©†dku - HIGH

         jmp       word ptr ds:[RetDisp]    ; n†vrat z procedury

; -----------------------------------------------------------------------------
;        Definice argumentu (CX=poáet poloëek)
; -----------------------------------------------------------------------------

PUBLIC   Argum

Argum:   call      TestLeft                 ; test, zda je lev† z†vorka
         jc        Argum2                   ; nen° lev† z†vorka
Argum1:  call      Vyraz                    ; vstup prvn°ho vòrazu
         jc        Argum3                   ; chybnò vòraz v argumentu
         dec       cx
         jcxz      Argum5                   ; m† bòt konec
         call      TestCar                  ; test, zda je á†rka
         jc        Argum2                   ; chybnò argument
         jmp       short Argum1             ; dal®° argument

Argum5:  call      TestRght                 ; test, zda je prav† z†vorka
         jnc       Argum4                   ; je prav† z†vorka OK

Argum2:  mov       dx,offset Err01b         ; text - chybnò argument
Argum3:  call      DispErr                  ; zobrazen° textu chyby
         stc
Argum4:  ret

; -----------------------------------------------------------------------------
;        Definice vòrazu
; -----------------------------------------------------------------------------
;           0 - konec vòrazu
;           1 - (
;           2 - )
;           3 - ^
;           4 - *
;           5 - /
;           6 - MOD
;           7 - <<
;           8 - >>
;           9 - +
;          10 - -
;          11 - =
;          12 - <>
;          13 - <
;          14 - >
;          15 - <=
;          16 - >=
;          17 - NOT
;          18 - AND
;          19 - OR
;          20 - XOR
;         81h - á°seln† konstanta (v BX hodnota konstanty)
;         82h - intern° procedura (v BL á°slo procedury)
;         83h - uëivatelsk† procedura (v BX adresa procedury)
;         84h - BYTE bez indexu (v BX adresa promànnÇ)
;         85h - WORD bez indexu (v BX adresa promànnÇ)
;         86h - BYTE s indexem (v BX adresa promànnÇ, n†sleduje index)
;         87h - WORD s indexem (v BX adresa promànnÇ, n†sleduje index)
; -----------------------------------------------------------------------------
;˛
PUBLIC   Vyraz
Vyraz:
         call      Vyraz0
         pushf
         mov       al,0
         call      OutCh                    ; oznaáen° konce vòrazu
         popf
         ret


PUBLIC   Vyraz0
Vyraz0:

; ------ dek¢dov†n° prvn°ho operandu

         call      VyrUn                    ; dek¢dov†n° operandu
         jc        Vyraz9                   ; chyba

; ------ dek¢dov†n° oper†toru

Vyraz1:  call      GetOper                  ; dek¢dov†n° oper†toru
         cmc
         jnc       Vyraz9                   ; nen° dal®° oper†tor - nevad°

; ------ test, zda je konec vòrazu

         cmp       al,2                     ; je prav† z†vorka ?
         jne       Vyraz2                   ; nen° prav† z†vorka
         mov       al,")"                   ; pñvodn° prav† z†vorka
         call      RetCh                    ; n†vrat pravÇ z†vorky
         jmp       short Vyraz9             ; konec vòrazu

; ------ uloëen° k¢du oper†toru

Vyraz2:  call      OutCh                    ; uloëen° k¢du oper†toru

; ------ dek¢dov†n° druhÇho operandu

         call      VyrUn                    ; dek¢dov†n° druhÇho operandu
         jnc       Vyraz1                   ; OK, takëe dal®° oper†tor


Vyraz9:  mov       dx,offset Err005         ; text - cbybnò vòraz
         ret

; -----------------------------------------------------------------------------
;        Dek¢dov†n° jednoduchÇho vòrazu (s un†rn°m oper†torem)
; -----------------------------------------------------------------------------

PUBLIC   VyrUn

VyrUn:   push      bx
         push      cx

; ------ dek¢dov†n° un†rn°ho oper†toru

VyrUn1:  call      GetOper                  ; dek¢dov†n° p©°padnÇho oper†toru
         jc        VyrUn4                   ; nen° platnò oper†tor
         cmp       al,9                     ; je un†rn° + ?
         je        VyrUn1                   ; je un†rn° + (ignoruje se)
         cmp       al,10                    ; je un†rn° - ?
         je        VyrUn2                   ; je un†rn° - (uloë° se)
         cmp       al,17                    ; je un†rn° NOT ?
         jne       VyrUn3                   ; nen° un†rn° NOT - test z†vorky
VyrUn2:  call      OutCh                    ; uloëen° un†rn°ho oper†toru
         jmp       short VyrUn1             ; dal®° un†rn° oper†tor

; ------ dek¢dov†n° vòrazu v z†vorce

VyrUn3:  cmp       al,1                     ; je lev† z†vorka ?
         stc                                ; p©°znak chyby
         jne       VyrUn9                   ; nen° platnò oper†tor - chyba
         call      Outch                    ; uloëen° k¢du levÇ z†vorky
         call      Vyraz0                   ; dek¢dov†n° vòrazu v z†vorce
         jc        VyrUn9                   ; byla nàjak† chyba
         call      GetOper                  ; test dal®°ho oper†toru
         jc        VyrUn9                   ; nen° prav† z†vorka - chyba
         cmp       al,2                     ; je prav† z†vorka ?
         stc                                ; p©°znak chyby
         jne       VyrUn9                   ; chyba - nen° prav† z†vorka
         call      OutCh                    ; uloëen° k¢du pravÇ z†vorky
         jmp       short VyrUn8             ; n†vrat

; ------ dek¢dov†n° operandu

VyrUn4:  call      GetOpn                   ; dek¢dov†n° operandu
         jc        VyrUn9                   ; chyba - neplatnò operand
         call      OutCh                    ; uloëen° k¢du operandu
         xchg      al,bl                    ; AL <- nië®° bajt parametru
         call      OutCh                    ; uloëen° nië®°ho bajtu parametru
         cmp       bl,82h                   ; je intern° procedura ?
         jne       VyrUn5                   ; nen° intern° procedura
         cmp       al,24                    ; je funkce ?
         jb        VyrUn8                   ; zak†zan† procedura

; ------ nalezen° adresy intern° procedury

         mov       bx,offset TabKey         ; tabulka slov
VyrUn6:  add       bl,ds:[bx]               ; p©iáten° dÇlky slova
         adc       bh,0                     ; p©enos do vy®®°ho bajtu
         add       bx,3                     ; p©eskoáen° bajtu dÇlky a adresy
         cmp       al,0                     ; procedura nalezena ?
         je        VyrUn62                  ; nalezena
         dec       al                       ; sn°ëen° á°taáe procedur
         jmp       short VyrUn6             ; dal®° slovo

; ------ vyvol†n° obsluhy procedury

VyrUn62: call      word ptr ds:[bx-2]       ; vyvol†n° obsluhy procedury
         jmp       short VyrUn8

VyrUn5:  mov       al,bh                    ; vy®®° bajt k uloëen°
         call      OutCh                    ; uloëen° vy®®°ho bajtu

         cmp       bl,86h
         je        VyrUn7
         cmp       bl,87h
         jne       VyrUn8
VyrUn7:  mov       cx,1
         call      Argum                    ; argument prvku vektoru

VyrUn8:  clc                                ; p©°znak - operace OK
VyrUn9:  pop       cx
         pop       bx
         ret

; -----------------------------------------------------------------------------
;        Dek¢dov†n° operandu (CY=neplatnò operand)
; -----------------------------------------------------------------------------
; AL = typ operandu (bit 7 = 1):
;            0h - neplatnò operand
;           81h - á°seln† konstanta (v BX hodnota konstanty)
;           82h - intern° procedura (v BL á°slo procedury)
;           83h - uëivatelsk† procedura (v BX adresa procedury)
;           84h - BYTE bez indexu (v BX adresa promànnÇ)
;           85h - WORD bez indexu (v BX adresa promànnÇ)
;           86h - BYTE s indexem (v BX adresa promànnÇ, n†sleduje index)
;           87h - WORD s indexem (v BX adresa promànnÇ, n†sleduje index)
; BX = adresa nebo hodnota operandu
; -----------------------------------------------------------------------------

PUBLIC   GetOpn
GetOpn:

; ------ £schova registrñ

         push      si
         push      di
         push      es

; ------ pokus o naáten° jmÇna promànnÇ nebo funkce

         call      ReadIdnt                 ; áten° jmÇna operandu
         jc        GetOpn6                  ; nen° platnÇ jmÇno

; ------ pokus o nalezen° v intern° tabulce funkc°

         call      SrcIdnt                  ; nalezen° v intern° tabulce
         jc        GetOpn3                  ; nen° slovo intern° tabulky
         mov       bl,al                    ; á°slo procedury
         mov       al,82h                   ; p©°znak, ëe je intern° procedura
         cmp       bl,24                    ; mñëe bòt jako funkce ?
         jae       GetOpn9                  ; mñëe bòt pouëit - OK

; ------ n†vrat slova, protoëe je neplatnÇ

         call      RetIdnt                  ; n†vrat jmÇna funkce
         jmp       short GetOpn8            ; n†vrat s chybou

; ------ pokus o nalezen° slova v uëivatelskÇ tabulce

GetOpn3: mov       al,0                     ; p©°znak, ëe jmÇno nen° definov†no
         call      StorFlg                  ; nalezen° jmÇna v tabulce
         jnc       GetOpn8                  ; nen° definov†no - to je chyba
         test      al,1                     ; je definov†no ?
         jz        GetOpn8                  ; slovo nen° definov†no

; ------ je uëivatelsk† procedura

         mov       bx,es:[di+1]             ; adresa procedury nebo promànnÇ
         test      al,2                     ; je procedura ?
         jz        GetOpn5                  ; nen° procedura
         mov       al,83h                   ; p©°znak uëivatelskÇ procedury
         jmp       short GetOpn9            ; n†vrat

; ------ stanoven° typu promànnÇ

GetOpn5: test      al,8                     ; je OBJECT ?
         jnz       GetOpn8                  ; nen° povolen† promànn†
         shr       al,1
         shr       al,1                     ; p©°znak WORD z bitu 2 na bit 0
         test      al,4                     ; je index ?
         jz        GetOpn4                  ; nen° index
         or        al,2                     ; p©°znak indexu
GetOpn4: and       al,3                     ; typ
         or        al,84h
         jmp       short GetOpn9

; ------ pokus o interpretaci jako á°slo

GetOpn6: call      Numb                     ; interpretace jako á°slo
         mov       bx,ax                    ; hodnota konstanty
         mov       al,81h                   ; p©°znak á°selnÇ konstanty
         jnc       GetOpn9                  ; je á°selnò operand

; ------ chyba - neplatnò operand

GetOpn8: mov       al,0                     ; p©°znak - neplatnò operand
         mov       bx,0
         stc                                ; p©°znak chyby

; ------ n†vrat registrñ

GetOpn9: pop       es
         pop       di
         pop       si
         ret

; -----------------------------------------------------------------------------
;        Vstup znaku oper†toru (CY=neplatnò oper†tor)
; -----------------------------------------------------------------------------
; AL = oper†tor (bit 7 = 0):
;           0 - neplatnò oper†tor
;           1 - (
;           2 - )
;           3 - ^
;           4 - *
;           5 - /
;           6 - MOD
;           7 - <<
;           8 - >>
;           9 - +
;          10 - -
;          11 - =
;          12 - <>
;          13 - <
;          14 - >
;          15 - <=
;          16 - >=
;          17 - NOT
;          18 - AND
;          19 - OR
;          20 - XOR
;          (21 - un†rn° -)
; -----------------------------------------------------------------------------

PUBLIC   GetOper
GetOper:

; ------ £schova registrñ

         push      cx
         push      si
         push      di
         push      es

         push      ds
         pop       es
         cld

; ------ naáten° max. 3 znakñ oper†toru

         mov       di,offset BufOper        ; buffer oper†toru
         mov       cx,3                     ; 3 znaky
         xor       al,al
         stosb                              ; poáet bajtñ zat°m je 0
         call      InpSpc                   ; vstup s vypu®tàn°m mezer
         jc        GetOper2                 ; nen° dal®° znak
         cmp       al,'"'
         je        GetOpr11                 ; jsou uvozovky
GetOper1:stosb                              ; uloëen° znaku
         inc       byte ptr ds:[BufOper]    ; zvò®en° á°taáe poátu znakñ
         dec       cx
         jcxz      GetOper2
         call      InpChU                   ; vstup dal®°ho znaku
         cmp       al,'"'
         jne       GetOper1
GetOpr11:call      RetCh                    ; n†vrat znaku "

; ------ test, zda se provede hled†n° v tabulce

GetOper2:mov       al,0                     ; p©ednastaven° - oper†tor nenalezen
         cmp       byte ptr ds:[BufOper],0  ; je je®tà nàco v bufferu ?
         stc                                ; p©°znak chyby, ëe nic nen°
         je        GetOper6                 ; slovo nenalezeno

; ------ tabulka bude prohled†na

         mov       si,offset BufOper        ; buffer s oper†torem
         mov       di,offset TabOper        ; tabulka oper†torñ

; ------ test, zda je konec tabulky

GetOper3:inc       al                       ; zvò®en° ukazatele slov v tabulce
         mov       cl,ds:[di]               ; dÇlka oper†toru v tabulce
         jcxz      GetOper4                 ; je jië konec tabulky
         inc       cl                       ; porovn† se i dÇlka

; ------ porovn†n° jednÇ poloëky v tabulce

         cld
         push      si
         push      di
         push      cx
         repe      cmpsb                    ; porovn†n° s poloëkou tabulky
         pop       cx
         pop       di
         pop       si
         je        GetOper6                 ; poloëka nalezena OK

; ------ nastaven° na dal®° poloëku tabulky

         add       di,cx                    ; adresa dal®° poloëky v tabulce
         jmp       short GetOper3           ; test dal®° poloëky tabulky

; ------ n†vrat posledn°ho znaku z bufferu

GetOper4:mov       cl,ds:[si]               ; poáet znakñ v buferu
         dec       byte ptr ds:[si]         ; sn°ëen° poátu znakñ v bufferu
         add       si,cx                    ; adresa znaku v bufferu
         mov       al,ds:[si]               ; znak v bufferu
         call      RetCh                    ; n†vrat znaku do bufferu
         jmp       short GetOper2           ; dal®° porovn†n° oper†toru

; ------ n†vrat registrñ

GetOper6:pop       es
         pop       di
         pop       si
         pop       cx
         ret

; -----------------------------------------------------------------------------
;        Zji®tàn°, zda n†sleduje znak p©i©azen° := (CY=nen†sleduje)
; -----------------------------------------------------------------------------

PUBLIC   InpPri
InpPri:
         push      ax
         call      InpSpc                   ; vstup prvn°ho znaku
         jc        InpPri3                  ; nen° dal®° znak
         cmp       al,":"                   ; je znak ":" ?
         jne       InpPri2                  ; prvn° znak nen° ":"
         call      InpCh                    ; dal®° znak
         jc        InpPri1                  ; nen° dal®° znak - chyba
         cmp       al,"="                   ; je znak "=" ?
         je        InpPri3                  ; je znak "=" - OK
         call      RetCh                    ; n†vrat druhÇho znaku
InpPri1: mov       al,":"                   ; znak ":"
InpPri2: call      RetCh                    ; n†vrat znaku ":"
         stc                                ; p©°znak chyby - nen° ":="
InpPri3: pop       ax
         ret

; -----------------------------------------------------------------------------
;        Test konce p©°kazu (znak ;)
; -----------------------------------------------------------------------------

PUBLIC   TestKon
TestKon: call      InpSpc
         jc        TestKon1                 ; p©°kaz nen° ukonáen
         cmp       al,";"
         je        TestKon2
         call      RetCh                    ; n†vrat znaku
TestKon1:mov       dx,offset Err01a         ; text - chyb° st©edn°k
         call      DispErr                  ; zobrazen° chyby
TestKon2:ret

; -----------------------------------------------------------------------------
;        Test, zda je lev† z†vorka "("
; -----------------------------------------------------------------------------

PUBLIC   TestLeft
TestLeft:call      InpSpc                   ; naáten° dal®°ho znaku
         jc        TestLft2                 ; chyba - nen° lev† z†vorka
         cmp       al,"("                   ; je lev† z†vorka ?
         je        TestLft2                 ; je lev† z†vorka - OK
         call      RetCh                    ; n†vrat znaku
         stc                                ; p©°znak chyby
TestLft2:ret

; -----------------------------------------------------------------------------
;        Test, zda je oddàlovac° á†rka ","
; -----------------------------------------------------------------------------

PUBLIC   TestCar
TestCar: call      InpSpc                   ; naáten° dal®°ho znaku
         jc        TestCar2                 ; chyba - nen° á†rka
         cmp       al,","                   ; je á†rka ?
         je        TestCar2                 ; je á†rka - OK
         call      RetCh                    ; n†vrat znaku
         stc                                ; p©°znak chyby
TestCar2:ret

; -----------------------------------------------------------------------------
;        Test, zda je oddàlovac° dvojteáka ":"
; -----------------------------------------------------------------------------

PUBLIC   TestDvj
TestDvj: call      InpSpc                   ; naáten° dal®°ho znaku
         jc        TestDvj2                 ; chyba - nen° dvojteáka
         cmp       al,":"                   ; je dvojteáka ?
         je        TestDvj2                 ; je dvojteáka - OK
         call      RetCh                    ; n†vrat znaku
         stc                                ; p©°znak chyby
TestDvj2:ret

; -----------------------------------------------------------------------------
;        Test, zda je prav† z†vorka ")"
; -----------------------------------------------------------------------------

PUBLIC   TestRght
TestRght:call      InpSpc                   ; naáten° dal®°ho znaku
         jc        TestRgh2                 ; chyba - nen° prav† z†vorka
         cmp       al,")"                   ; je prav† z†vorka ?
         je        TestRgh2                 ; je prav† z†vorka - OK
         call      RetCh                    ; n†vrat znaku
         stc                                ; p©°znak chyby
TestRgh2:ret

; -----------------------------------------------------------------------------
;        Test, zda je oddàlovaá intervalu
; -----------------------------------------------------------------------------

PUBLIC   TestInt
TestInt: push      ax
         call      InpCh                    ; áten° dal®°ho znaku
         jc        TestInt3                 ; nen° dal®° znak
         cmp       al,"."                   ; je interval ?
         stc                                ; p©°znak, ëe nen° interval
         jne       TestInt2                 ; nen° interval
         call      InpCh                    ; áten° dal®°ho znaku
         jc        TestInt1                 ; nen° dal®° znak
         cmp       al,"."                   ; je interval ?
         je        TestInt3                 ; je interval
         stc                                ; p©°znak, ëe nen° interval
         call      RetCh                    ; n†vrat znaku
TestInt1:mov       al,"."
TestInt2:call      RetCh
TestInt3:pop       ax
         ret

; -----------------------------------------------------------------------------
;        Zji®tàn° dimenze promànnÇ (vrac° AX,BX=velikost)
; -----------------------------------------------------------------------------

PUBLIC   CompI
CompI:   mov       bx,1                     ; velikost promànnÇ = 1
         call      InpCh                    ; áten° dal®°ho znaku
         cmc
         jnc       CompI6                   ; nen° dal®° znak (to nevad°)
         cmp       al,"("                   ; jsou parametry ?
         clc
         jne       CompI5                   ; nen° dimenze - OK (bude 1)
         call      Numb                     ; áten° á°sla
         jc        CompI6                   ; chybnÇ á°slo
         mov       bx,ax                    ; nov† velikost promànnÇ
         call      InpCh                    ; áten° dal®°ho znaku
         jc        CompI6                   ; nen° dal®° znak
         cmp       al,")"                   ; uzav©en° parametru ?
         je        CompI6                   ; v®e je OK
         stc                                ; p©°znak chyby syntaxe
CompI5:  call      RetCh                    ; n†vrat znaku

CompI6:  jnc       CompI7                   ; v®e je OK
         mov       dx,offset Err014         ; text - chybn† dimenze
         call      DispErr                  ; zobrazen° chyby
CompI7:  mov       ax,bx                    ; velikost promànnÇ
         ret

; -----------------------------------------------------------------------------
;        Dek¢dov†n° á°sla se znamÇnkem
; -----------------------------------------------------------------------------

PUBLIC   NumbS
NumbS:   call      InpSpc                   ; vstup prvn°ho znaku
         jc        NumbS9
         cmp       al,"+"
         je        NumbS                    ; + se ignoruje
         cmp       al,"-"
         jne       NumbS1                   ; nen° á°slo se znamÇnkem

                                          ;* je á°slo s "-"
         call      NumbS
         jc        NumbS2
         neg       ax
         clc
NumbS9:  ret

NumbS2:  mov       al,"-"
         call      RetCh
         ret

NumbS1:  call      RetCh
         call      Numb
         ret

; -----------------------------------------------------------------------------
;        Dek¢dov†n° textovÇho á°sla
; -----------------------------------------------------------------------------

PUBLIC   Numbt
Numbt:   push      bx
         xor       bx,bx
Numbt0:  call      InpCh                    ; vstup prvn°ho znaku
         jc        Numbt5                   ; chyba - nen° ë†dnò znak
         call      RetCh                    ; n†vrat znaku
         call      Numbt00                  ; vstup prvn°ho znaku
         jc        Numbt5                   ; chyba - nen° platnò znak

; ------ je platnò dal®° znak

Numbt1:  cmp       bh,0                     ; bude p©eteáen° ?
         stc
         jne       Numbt5                   ; bylo by p©eteáen°
         mov       bh,bl                    ; p©edchoz° znak
         mov       bl,al                    ; uloëen° novÇho znaku
         call      Numbt00                  ; vstup dal®°ho znaku
         jnc       Numbt1                   ; je dal®° platnò znak
         clc                                ; p©°znak - v®e OK
Numbt5:  mov       ax,bx
         pop       bx
         ret

; -----------------------------------------------------------------------------
;        Vstup textovÇho znaku (CY=konec, zru®° koncovÇ uvozovky)
; -----------------------------------------------------------------------------

PUBLIC   Numbt00
Numbt00: call      InpCh                    ; vstup znaku
         jc        Numbt05                  ; nen° dal®° znak
         cmp       al,'"'                   ; jsou uvozovky ?
         clc
         jne       Numbt05                  ; nejsou uvozovky - OK
         call      InpCh                    ; vstup dal®°ho znaku
         cmp       al,'"'                   ; jsou zdvojenÇ uvozovky ?
         je        Numbt05                  ; zdvojenÇ uvozovky - OK
         call      RetCh                    ; n†vrat znaku
         stc                                ; p©°znak konce textu
Numbt05: ret

; -----------------------------------------------------------------------------
;        Dek¢dov†n° á°sla (AX <-)
; -----------------------------------------------------------------------------

PUBLIC   Numb
                                          ;* test, zda je prvn° znak á°slice
Numb:
         push      bx
         xor       bx,bx                    ; BX <- 0 st©adaá á°sla
         call      InpSpc                   ; vypu®tàn° mezer z textu
         jc        Numb9                    ; nen° dal®° znak - chyba
         cmp       al,"?"                   ; je konstanta 8000h ?
         jne       Numb0                    ; nen° konstanta 8000h
         mov       bx,8000h                 ; konstanta 8000h
         jmp       short Numb9              ; n†vrat
Numb0:   cmp       al,"$"                   ; je hexadecim†ln° á°slo ?
         je        Numbh0                   ; vstup hexadecim†ln°ho á°sla
         cmp       al,"%"                   ; je bin†rn° á°slo ?
         je        Numbb0                   ; vstup bin†rn°ho á°sla
         cmp       al,'"'                   ; je textovÇ á°slo ?
         je        Numbt0                   ; dek¢dov†n° textovÇho á°sla

         call      Numb00                   ; test, zda je znak á°slice
         jc        Numb8                    ; nen° á°slice

         mov       bl,al                    ; prvn° á°slice
Numb1:   call      InpCh                    ; vstup dal®°ho znaku
         cmc
         jnc       Numb9                    ; nen° dal®° znak
         call      Numb00                   ; test, zda je to á°slice
         cmc
         jnc       Numb8                    ; nen° to á°slice
         push      ax
         mov       ax,10
         mul       bx                       ; starÇ á°slo * 10
         pop       bx                       ; nov† á°slice
         or        dx,dx                    ; je p©eteáen° á°sla ?
         stc                                ; p©°znak p©eteáen° á°sla
         jnz       Numb9                    ; chyba - p©eteáen° á°sla
         mov       bh,0
         add       bx,ax                    ; p©iáten° á°slice k st©adaái
         jc        Numb9                    ; chyba - p©eteáen° á°sla
         jmp       short Numb1              ; vstup dal®° á°slice

Numb8:   call      RetCh                    ; n†vrat znaku do bufferu
Numb9:   mov       ax,bx                    ; naátenÇ á°slo
         pop       bx
         ret

; -----------------------------------------------------------------------------
;        Dek¢dov†n° hexadecim†ln°ho á°sla (AX <-)
; -----------------------------------------------------------------------------

PUBLIC   Numbh
                                          ;* test, zda je prvn° znak á°slice
Numbh:   push      bx
         xor       bx,bx                    ; BX <- 0 st©adaá á°sla
Numbh0:  call      InpSpc                   ; vypu®tàn° mezer z textu
         jc        Numbh9                   ; nen° dal®° znak - chyba
         call      Numbh00                  ; test, zda je znak á°slice
         jc        Numbh8                   ; nen° á°slice

Numbh1:  add       bl,al                    ; p©iáten° á°slice
         call      InpChU                   ; vstup dal®°ho znaku
         cmc
         jnc       Numbh9                   ; nen° dal®° znak
         call      Numbh00                  ; test, zda je to á°slice
         cmc
         jnc       Numbh8                   ; nen° to á°slice
         shl       bx,1
         jc        Numbh9                   ; p©eteáen° á°sla
         shl       bx,1
         jc        Numbh9                   ; p©eteáen° á°sla
         shl       bx,1
         jc        Numbh9                   ; p©eteáen° á°sla
         shl       bx,1                     ; starÇ á°slo * 16
         jc        Numbh9                   ; p©eteáen° á°sla
         jmp       short Numbh1             ; vstup dal®° á°slice

Numbh8:  call      RetCh                    ; n†vrat znaku do bufferu
Numbh9:  mov       ax,bx                    ; naátenÇ á°slo
         pop       bx
         ret

; -----------------------------------------------------------------------------
;        Dek¢dov†n° bin†rn°ho á°sla (AX <-)
; -----------------------------------------------------------------------------

PUBLIC   Numbb
                                          ;* test, zda je prvn° znak á°slice
Numbb:   push      bx
         xor       bx,bx                    ; BX <- 0 st©adaá á°sla
Numbb0:  call      InpSpc                   ; vypu®tàn° mezer z textu
         jc        Numbb9                   ; nen° dal®° znak - chyba
         call      Numbb00                  ; test, zda je znak á°slice
         jc        Numbb8                   ; nen° á°slice

Numbb1:  add       bl,al                    ; p©iáten° á°slice
         call      InpChU                   ; vstup dal®°ho znaku
         cmc
         jnc       Numbb9                   ; nen° dal®° znak
         call      Numbb00                  ; test, zda je to á°slice
         cmc
         jnc       Numbb8                   ; nen° to á°slice
         shl       bx,1                     ; á°slo * 2
         jc        Numbb9                   ; p©eteáen° á°sla
         jmp       short Numbb1             ; vstup dal®° á°slice

Numbb8:  call      RetCh                    ; n†vrat znaku do bufferu
Numbb9:  mov       ax,bx                    ; naátenÇ á°slo
         pop       bx
         ret

; -----------------------------------------------------------------------------
;        Test, zda je platn† dekadick† á°slice
; -----------------------------------------------------------------------------

PUBLIC   Numb00

Numb00:  cmp       al,"0"
         jb        Numb01                   ; nen° á°slice
         cmp       al,"9"+1
         cmc
         jc        Numb01
         sub       al,"0"
Numb01:  ret

; -----------------------------------------------------------------------------
;        Test, zda je platn† á°slice HEX
; -----------------------------------------------------------------------------

PUBLIC   Numbh00
Numbh00: cmp       al,"0"
         jb        Numbh02                  ; nen° á°slice

         cmp       al,"9"
         jbe       Numbh01                  ; je á°slice

         cmp       al,"F"+1
         cmc
         jc        Numbh02                  ; nen° á°slice HEX

         cmp       al,"A"
         jb        Numbh02                  ; nen° á°slice HEX
         sub       al,7                     ; korekce na á°slici HEX

Numbh01: sub       al,"0"                   ; korekce na bin†rn° á°slo
Numbh02: ret

; -----------------------------------------------------------------------------
;        Test, zda je platn† á°slice BIN
; -----------------------------------------------------------------------------

PUBLIC   Numbb00
Numbb00: cmp       al,"0"
         jb        Numbb02                  ; nen° á°slice

         cmp       al,"2"
         cmc
         jc        Numbb02                  ; je á°slice

         sub       al,"0"                   ; korekce na bin†rn° á°slo
Numbb02: ret

; -----------------------------------------------------------------------------
;        Uloëen° identifik†toru konstrukce (v z†sob. 2 n†vrat. adresy)
; -----------------------------------------------------------------------------

PUBLIC   PushKod
PushKod: pop       word ptr ds:[RetPush]
         pop       word ptr ds:[RetComp]

         push      word ptr ds:[ErrARad+2]  ; adresa ©†dku - vy®®° slovo
         push      word ptr ds:[ErrARad]    ; adresa ©†dku - nië®° slovo
         push      word ptr ds:[ErrNRad]    ; á°slo ©†dku
         mov       ah,0                     ; nen° ë†dn† adresa v bufferu
         push      ax                       ; uloëen° k¢du adresy
         sub       bp,8                     ; nov† adresa ukazatele

         push      word ptr ds:[RetComp]
         jmp       word ptr ds:[RetPush]

; -----------------------------------------------------------------------------
;        Uloëen° adresy AX do bufferu (v z†sob. 2 n†vrat. adresy) (niá° BX)
; -----------------------------------------------------------------------------

PUBLIC   PushAdrX
PushAdrX:mov       ax,ds:[ProgNum]          ; ukazatel

PUBLIC   PushAdr
PushAdr: pop       word ptr ds:[RetPush]
         pop       word ptr ds:[RetComp]

         pop       bx                       ; á°taá a p©°znak
         push      ax                       ; uloëen° adresy
         inc       bh                       ; zvò®en° á°taáe
         push      bx                       ; uloëen° k¢du adresy
         sub       bp,2                     ; nov† adresa ukazatele

         push      word ptr ds:[RetComp]
         jmp       word ptr ds:[RetPush]

; -----------------------------------------------------------------------------
;        Zru®en° identif. konstrukce (v z†sob. 2 n†vrat. adresy) (niá° BX, AX)
; -----------------------------------------------------------------------------

PUBLIC   PopKod
PopKod:  pop       word ptr ds:[RetPush]
         pop       word ptr ds:[RetComp]

PopKod1: pop       ax                       ; á°taá a p©°znaky
         or        ah,ah                    ; je je®tà nàjakÇ slovo ?
         jz        PopKod3                  ; nen° dal®° slovo

         pop       bx                       ; adresa promànnÇ
         dec       ah                       ; sn°ëen° á°taáe
         push      ax                       ; £schova á°taáe
         add       bp,2                     ; zvò®en° ukazatele

         push      es                       ; £schova ES
         mov       es,ds:[ProgSeg]          ; segment s programem
         mov       ax,ds:[ProgNum]          ; ukazatel programu
         mov       es:[bx],ax               ; nastaven° poëadovanÇ adresy
         pop       es                       ; n†vrat ES

         jmp       short PopKod1            ; dal®° adresa

PopKod3: pop       ax                       ; á°slo ©†dku
         pop       ax                       ; adresa ©†dku - LOW
         pop       ax                       ; adresa ©†dku - HIGH
         add       bp,8                     ; posledn° posun ukazatele

         push      word ptr ds:[RetComp]
         jmp       word ptr ds:[RetPush]

; -----------------------------------------------------------------------------
;        Nastaven° jednÇ adresy (niá° AX a BX)
; -----------------------------------------------------------------------------

SetAdr:  pop       word ptr ds:[RetPush]
         pop       word ptr ds:[RetComp]

         pop       ax
         or        ah,ah
         jz        SetAdr3                  ; nen° ë†dnÇ slovo

         pop       bx                       ; adresa promànnÇ
         dec       ah                       ; sn°ëen° á°taáe
         add       bp,2                     ; zvò®en° ukazatele

         push      es                       ; £schova ES
         push      ax
         mov       es,ds:[ProgSeg]          ; segment s programem
         mov       ax,ds:[ProgNum]          ; ukazatel programu
         mov       es:[bx],ax               ; nastaven° poëadovanÇ adresy
         pop       ax
         pop       es                       ; n†vrat ES

SetAdr3: push      ax
         push      word ptr ds:[RetComp]
         jmp       word ptr ds:[RetPush]

; -----------------------------------------------------------------------------
;        Vyjmut° adresy z bufferu (CY=nen°) (v z†sob. 2 n†vrat.adresy) (niá° BX)
; -----------------------------------------------------------------------------

PUBLIC   PopAdr
PopAdr:  pop       word ptr ds:[RetPush]
         pop       word ptr ds:[RetComp]

         pop       bx                       ; á°taá a p©°znak
         or        bh,bh                    ; je dal®° slovo ?
         stc                                ; p©°znak - nen° dal®° slovo
         jz        PopAdr2                  ; nen° dal®° slovo

         pop       ax                       ; vyjmut° adresy
         dec       bh                       ; sn°ëen° á°taáe
         add       bp,2                     ; nov† adresa ukazatele
         clc                                ; p©°znak, ëe je v®e OK

PopAdr2: push      bx                       ; n†vrat á°taáe

         push      word ptr ds:[RetComp]
         jmp       word ptr ds:[RetPush]


; *****************************************************************************
;
;                Obsluha intern°ch kl°áovòch slov
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;        LINK - p©ipojen° objektu
; -----------------------------------------------------------------------------

XLink78: jmp       XLink7

PUBLIC   XLInk
XLink:
         call      OutRet                   ; zru®en° bajtu z bufferu
         mov       byte ptr ds:[ProgLev],3  ; p©°znak konce programu

; ------ uloëen° programu na disk

         mov       cx,ds:[ProgNum]          ; poáet bajtñ v bufferu
         cmp       cx,ds:[SizProg]
         jbe       XLink1
         mov       ds:[SizProg],cx          ; £schova velikosti programu
XLink1:  call      WritProg                 ; z†pis dat. promànnòch do souboru
         mov       word ptr ds:[ProgNum],2  ; zru®en° programu

; ------ test, zda je prvn° znak z†vorka "("

         call      TestLeft                 ; test, zda je lev† z†vorka
         jc        XLink78                  ; chyba - nejsou parametry

; ------ definice objektu

         call      DefObj                   ; definice á°sla objektu

; ------ oddàlovac° á†rka parametrñ

         call      TestCar                  ; test, zda je oddàlovac° á†rka
         jc        XLink78                  ; chyba - neplatnò znak

; ------ definice jmÇna souboru

         mov       dx,ds:[ProgNum]          ; zaá†tek jmÇna souboru
         call      DefTxt                   ; definice jmÇna
         jc        XLink78                  ; chybnÇ jmÇno souboru

; ------ test, zda je prav† z†vorka ")"

         call      TestRght                 ; test, zda je prav† z†vorka
         jc        XLink78                  ; chyba - nen° prav† z†vorka

; ------ otev©en° zadanÇho souboru

         push      ds
         mov       ds,ds:[ProgSeg]          ; segment se jmÇnem souboru
         mov       ax,3d00h                 ; funkce otev©en° souboru pro áten°
         int       21h                      ; otev©en° souboru pro áten°
         pop       ds
XLink3:  mov       dx,offset Err016         ; text - chybnÇ jmÇno souboru
         mov       ds:[LinkId],ax           ; identifik†tor souboru
         mov       bx,ax                    ; identifik†tor souboru
         mov       ax,4202h                 ; funkce p©esunut° na konec
         jc        XLink77                  ; chyba - soubor nenalezen

; ------ zji®tàn° velikosti linkovanÇho souboru

         xor       cx,cx                    ; CX <- 0
         xor       dx,dx                    ; DX <- 0
         int       21h                      ; poskytnut° velikosti
         jc        XLink3                   ; chyba souboru
         add       ax,15                    ; zaokrouhlen° na odstavec
         adc       dx,0                     ; p©enos do vy®®°ho slova

; ------ p©epoáet velikosti na odstavce

         shr       dx,1
         rcr       ax,1
         shr       dx,1
         rcr       ax,1
         shr       dx,1
         rcr       ax,1
         shr       dx,1
         rcr       ax,1                     ; p©epoáet na odstavce

; ------ nastaven° ukazatele opàt na zaá†tek souboru

         push      ax
         xor       cx,cx
         xor       dx,dx
         mov       ax,4200h
         int       21h                      ; nastaven° na zaá†tek souboru
         pop       ax
         jc        XLink3                   ; chyba souboru

; ------ kopie prvn°ho bloku souboru

         push      ds
         push      ax                       ; velikost souboru v odstavc°ch
         mov       bx,ds:[LinkId]           ; zdrojovò soubor
         mov       ds,ds:[ProgSeg]          ; datovò segment
         push      word ptr ds:[2]          ; £schova á°sla objektu
         xor       dx,dx                    ; ukl†dac° adresa - offset
         mov       cx,0e000h                ; maxim†ln° velikost bloku
         mov       ah,3fh                   ; funkce áten° ze souboru
         int       21h                      ; áten° bloku ze souboru
         mov       cx,ax                    ; poáet naátenòch bajtñ
         pop       word ptr ds:[0]          ; n†vrat á°sla objektu
         pop       word ptr ds:[2]          ; nastaven° velikosti souboru
         pop       ds
         jc        XLink3                   ; chyba áten°
         call      WritProg                 ; uloëen° prvn°ho bloku souboru

; ------ kopie dal®°ch blokñ souboru

XLink4:  push      ds
         mov       bx,ds:[LinkId]           ; zdrojovò soubor
         mov       ds,ds:[ProgSeg]          ; datovò segment
         xor       dx,dx                    ; ukl†dac° adresa - offset
         mov       cx,0e000h                ; maxim†ln° velikost bloku
         mov       ah,3fh                   ; funkce áten° ze souboru
         int       21h                      ; áten° bloku ze souboru
         mov       cx,ax                    ; poáet naátenòch bajtñ
         pop       ds
         jc        XLink3                   ; chyba áten°
         call      WritProg                 ; uloëen° bloku souboru
         jcxz      XLink83                  ; konec souboru
         jmp       short XLink4             ; kopie dal®°ho bloku

XLink83: mov       ah,3eh
         mov       bx,ds:[LinkId]           ; zdrojovò soubor
         int       21h                      ; uzav©en° vòstupn°ho souboru
         jmp       short XLink8

; ------ chyba syntaxe p©°kazu LINK

XLink7:  mov       dx,offset Err015         ; text - chyba syntaxe
XLink77: call      DispErr                  ; zobrazen° textu chyby

; ------ n†vrat z obsluhy

XLink8:  mov       word ptr ds:[ProgNum],0  ; zru®en° naátenÇho textu
         call      TestKon                  ; test, zda je konec p©°kazu
         ret

; -----------------------------------------------------------------------------
;        Definice odkazu na objekt
; -----------------------------------------------------------------------------

PUBLIC   DefObj
DefObj:  call      ReadIdnt                 ; áten° jmÇna objektu
         jc        DefObj4                  ; chyba - neplatnÇ jmÇno
         mov       al,0dh                   ; identifik†tor objektu
         call      StorFlg                  ; uloëen° identifik†toru
         mov       dx,offset Err009         ; chyba - v°cen†sobnÇ pouëit° jmÇna
         cmp       al,0dh                   ; je identifik†tor objektu ?
         jne       DefObj5                  ; nen° objekt - chyba
         mov       ax,di                    ; adresa objektu v tabulce
         inc       ax                       ; bude á°slo 1 a vò®e
         call      OutWrd                   ; uloëen° á°sla objektu
         clc                                ; p©°znak operace OK
         ret

DefObj4: mov       dx,offset Err012         ; text - neplatnÇ jmÇno objektu
DefObj5: call      DispErr                  ; zobrazen° textu chyby
         stc                                ; p©°znak chyby
DefObj6: ret

; -----------------------------------------------------------------------------
;        Definice textu v uvozovk†ch jako ASCIIZ (CY=nen° text v uvozovk†ch)
; -----------------------------------------------------------------------------

PUBLIC   DefTxt
DefTxt:

; ------ test, zda je platnò zaá†tek textu

         call      InpSpc                   ; vypustàn° mezer z textu
         jc        DefTxt6                  ; chyba - nen° dal®° znak
         cmp       al,'"'                   ; jsou uvozovky ?
         stc
         jne       DefTxt5                  ; nejsou uvozovky - neplatnò text

; ------ naáten° znaku textu

DefTxt1: call      InpCh                    ; vstup dal®°ho znaku
         jc        DefTxt4                  ; nen° dal®° znak
         cmp       al,'"'                   ; jsou uvozovky ?
         je        DefTxt3                  ; je znak uvozovek
DefTxt2: call      OutCh                    ; uloëen° znaku
         jmp       short DefTxt1            ; dal®° znak textu

; ------ test, zda je platnò znak uvozovek

DefTxt3: call      InpCh                    ; áten° dal®°ho znaku
         jc        DefTxt4                  ; nen° dal®° znak
         cmp       al,'"'                   ; jsou uvozovky ?
         je        DefTxt2                  ; jsou zdvojenÇ uvozovky
         clc                                ; p©°znak - konec textu OK

; ------ oznaáen° konce textu ASCIIZ

DefTxt4: push      ax
         mov       al,0
         call      OutCh                    ; uloëen° ukonáovac°ho bajtu 0
         pop       ax
         clc
DefTxt5: call      RetCh                    ; n†vrat posledn°ho znaku
DefTxt6: ret

; -----------------------------------------------------------------------------
;        INCLUDE - vno©en° textovÇho souboru
; -----------------------------------------------------------------------------

PUBLIC   XInclud
XInclud:
         call      OutRet                   ; zru®en° bajtu z bufferu

         call      TestKon                  ; test, zda je konec

         ret

; -----------------------------------------------------------------------------
;        EXEC - proveden° p©°kazu DOS
; -----------------------------------------------------------------------------

PUBLIC   XExec
XExec:  ; call      DefTxt
        ; jnc       XExec3                   ; zad†n° p©°kazu OK
        ;
        ; mov       dx,offset Err017         ; text - chyb° p©°kaz
        ; call      DispErr                  ; zobrazen° chyby

XExec3:
         ret

; -----------------------------------------------------------------------------
;        IF - podm°nka
; -----------------------------------------------------------------------------

PUBLIC   XIf
XIf:
         mov       al,20h                   ; identifik†tor IF
         call      PushKod                  ; uloëen° identifik†toru do z†sob.

; ------ uloëen° vòrazu jako podm°nka funkce

         call      Vyraz                    ; uloëen° vòrazu (podm°nka)
         jnc       XIf5
         call      DispErr
XIf5:

; ------ kontrola, zda n†sleduje THEN

         call      ReadIdnt                 ; naáten° identifik†toru THEN
         jc        XIf2                     ; chyba - neplatnÇ jmÇno
         call      SrcIdnt                  ; nalezen° identifik†toru v tabulce
         jc        XIf4                     ; neplatnÇ jmÇno
         cmp       al,10                    ; je jmÇno THEN ?
         je        XIf3                     ; je jmÇno THEN - OK

; ------ chyba - nen†sleduje THEN

XIf4:    call      RetIdnt                  ; n†vrat n†và®t° do bufferu
XIf2:    mov       dx,offset Err021         ; text - mus° n†sledovat THEN
         call      DispErr                  ; zobrazen° textu chyby

; ------ uloëen° adresy pro vàtven° IF (podm°nka nesplnàna)

XIf3:    call      PushAdrX                 ; uloëen° adresy ukazatele
         call      OutWrd                   ; rezerva pro uloëen° adresy
         ret

; -----------------------------------------------------------------------------
;        THEN - zaá†tek p©°kazñ v podm°nce IF (nelze v°cen†sobnà)
; -----------------------------------------------------------------------------

PUBLIC   XThen
XThen:   mov       dx,offset Err023         ; text - THEN mus° bòt za IF
         call      DispErr                  ; zobrazen° textu chyby
         ret

; -----------------------------------------------------------------------------
;        ELSE - zaá†tek p©°kazñ (podm°nka IF nesplnàna)
; -----------------------------------------------------------------------------

PUBLIC   XElse
XElse:   mov       dx,offset Err022         ; text - ELSE bez podm°nky IF
         cmp       al,20h                   ; je otev©enÇ IF ?
         jne       XElse5                   ; zobrazen° textu chyby
         mov       dx,offset Err025         ; text - ELSE nesm° bòt v°ckr†t
         cmp       al,21h                   ; bylo jië ELSE ?
         je        XElse5                   ; zobrazen° textu chyby

; ------ ELSE je povoleno

         mov       byte ptr ss:[bp],21h     ; p©°znak ELSE
         call      PopAdr                   ; vyjmut° adresy za IF
         mov       si,ax                    ; adresa v programu
         call      PushAdrX                 ; adresa pro nastaven° odkazu
         add       ax,2                     ; m°sto pro n†vratovou adresu
         push      ds
         mov       ds,ds:[ProgSeg]          ; segment s programem
         mov       ds:[si],ax               ; oznaáen° adresy za ELSE
         pop       ds
         call      OutWrd                   ; rezerva m°sta pro adresu
         ret

XElse5:  call      DispErr                  ; zobrazen° chyby
         ret

; -----------------------------------------------------------------------------
;        ENDIF - konec podm°nky IF
; -----------------------------------------------------------------------------

PUBLIC   XEndif
XEndif:
         call      OutRet                   ; zru®en° bajtu z bufferu
         cmp       al,20h                   ; je IF ?
         je        XEndif1                  ; je IF-THEN
         cmp       al,21h                   ; je IF-THEN-ELSE ?
         jne       XEndif2                  ; nen° IF

; ------ je otev©enÇ IF - uklizen°

XEndif1: call      PopKod                   ; zru®en° k¢du ze z†sobn°ku
         call      TestKon                  ; test, zda je konec p©°kazu
         ret

; ------ chyba - nen° otev©enÇ IF

XEndif2: mov       dx,offset Err022         ; text - nebyla podm°nka IF
         call      DispErr                  ; zobrazen° textu chyby
         ret

; -----------------------------------------------------------------------------
;        FOR - cyklus s parametrem
; -----------------------------------------------------------------------------

PUBLIC   XFor
XFor:
         call      OutRet                   ; zru®en° bajtu z bufferu
         ret


; -----------------------------------------------------------------------------
;        TO - koncov† hodnota cyklu s parametrem
; -----------------------------------------------------------------------------

PUBLIC   XTo
XTo:
         call      OutRet                   ; zru®en° bajtu z bufferu
         ret

; -----------------------------------------------------------------------------
;        STEP - krok cyklu s parametrem
; -----------------------------------------------------------------------------

PUBLIC   XStep
XStep:
         call      OutRet                   ; zru®en° bajtu z bufferu
         ret

; -----------------------------------------------------------------------------
;        DO - cyklus
; -----------------------------------------------------------------------------

PUBLIC   XDo
XDo:
         call      OutRet                   ; zru®en° bajtu z bufferu
         mov       al,30h                   ; identifik†tor DO
         call      PushKod                  ; uloëen° identifik†toru do z†sob.

         call      PushAdrX                 ; uloëen° adresy zaá†tku cyklu
         ret

; -----------------------------------------------------------------------------
;        ON - podm°nka cyklu
; -----------------------------------------------------------------------------

PUBLIC   XOn
XOn:     cmp       al,30h                   ; je otev©en cyklus DO ?
         je        XOn2                     ; je otev©en cyklus FOR/DO

XOn1:    mov       dx,offset Err031         ; text - WHILE bez DO
         call      DispErr                  ; zobrazen° textu chyby
         ret

; ------ uloëen° vòrazu jako podm°nka funkce

XOn2:    call      Vyraz                    ; uloëen° vòrazu (podm°nka)
         jnc       XOn6
         call      DispErr
XOn6:

; ------ uloëen° adresy pro p©°pad nesplnàn° podm°nky

         call      PopAdr                   ; adresa zaá†tku cyklu DO
         mov       cx,ax                    ; adresa zaá†tku cyklu
         call      PushAdrX                 ; uloëen° adresy
         call      OutWrd                   ; rezerva pro uloëen° adresy
         mov       ax,cx                    ; adresa zaá†tku cyklu
         call      PushAdr                  ; adresa zaá†tku cyklu do z†sobn°ku

; ------ kontrola, zda n†sleduje EXIT

         call      ReadIdnt                 ; naáten° identifik†toru EXIT
         jc        XOn3                     ; chyba - neplatnÇ jmÇno
         call      SrcIdnt                  ; nalezen° identifik†toru v tabulce
         jc        XOn5                     ; neplatnÇ jmÇno
         cmp       al,19                    ; je jmÇno EXIT ?
         je        XOn4                     ; je jmÇno EXIT - OK

; ------ chyba - nen†sleduje EXIT

XOn5:    call      RetIdnt                  ; n†vrat n†và®t° do bufferu

XOn3:    mov       dx,offset Err032         ; text - mus° n†sledovat EXIT
         call      DispErr                  ; zobrazen° textu chyby

XOn4:
         ret

; -----------------------------------------------------------------------------
;        ENDDO - konec cyklu
; -----------------------------------------------------------------------------

PUBLIC   XEnddo
XEnddo:  cmp       al,30h                   ; je otev©en cyklus DO ?
         jne       XOn1                     ; chyba - nen° otev©en cyklus

         call      PopAdr                   ; adresa zaá†tku cyklu
         call      OutWrd                   ; nastaven° adresy zaá†tku cyklu

         call      PopKod                   ; zru®en° k¢du ze z†sobn°ku
         call      TestKon                  ; test, zda je konec p©°kazu
         ret

; -----------------------------------------------------------------------------
;        EXIT - ukonáen° cyklu
; -----------------------------------------------------------------------------

PUBLIC   XExit
XExit:
         call      OutRet                   ; zru®en° bajtu z bufferu
         mov       dx,offset Err033         ; text - EXIT sm° bòt jen za ON
         call      DispErr                  ; zobrazen° textu chyby
         ret

; -----------------------------------------------------------------------------
;        CASE - v°cen†sobnÇ vàtven°
; -----------------------------------------------------------------------------

PUBLIC   XCase
XCase:
         mov       al,40h
         call      PushKod

; ------ uloëen° vòrazu jako podm°nka funkce

         call      Vyraz                    ; uloëen° vòrazu (podm°nka)
         jnc       XCase4
         call      DispErr

XCase4:

; ------ kontrola, zda n†sleduje IN

         call      ReadIdnt                 ; naáten° identifik†toru IN
         jc        XCase2                   ; chyba - neplatnÇ jmÇno
         call      SrcIdnt                  ; nalezen° identifik†toru v tabulce
         jc        XCase2                   ; neplatnÇ jmÇno
         cmp       al,21                    ; je jmÇno IN ?
         je        XCase3                   ; je jmÇno IN - OK

; ------ chyba - nen†sleduje IN

XCase2:  mov       dx,offset Err046         ; text - mus° n†sledovat IN
         call      DispErr                  ; zobrazen° textu chyby

; ------ uloëen° adresy pro vàtven° IN (podm°nka nesplnàna)

XCase3:  call      OutCh                    ; uloëen° k¢du IN
         jmp       short XIn1               ; zpracov†n° IN

; -----------------------------------------------------------------------------
;        IN - podm°nka v°cen†sobnÇho vàtven°
; -----------------------------------------------------------------------------

PUBLIC   XIn
XIn:     cmp       al,41h                   ; bylo jië OUT ?
         jne       XIn01                    ; nebylo OUT - OK

; ------ chyba - IN je neopr†vnànà

         mov       dx,offset Err043         ; text - nesm° bòt IN po OUT
XIn00:   call      DispErr                  ; zobrazen° textu chyby
         ret


XIn01:   cmp       al,40h                   ; je CASE-IN ?
         mov       dx,offset Err041         ; text - IN bez CASE
         jne       XIn00                    ; nebylo CASE-IN - chyba

; ------ nastaven° adresy pokraáov†n° ©etàzce IN

XIn1:    call      OutRet                   ; zru®en° bajtu z bufferu
         call      SetAdr                   ; nastaven° adresy
         call      OutInc                   ; zvò®en° ukazatele

; ------ zji®tàn° intervalu hodnot promànnÇ

XIn11:   call      NumbS                    ; áten° á°sla spodn°ho okraje
         jc        XIn2                     ; chybn† mez
         call      OutWrd                   ; uloëen° spodn° meze
         call      OutWrd                   ; p©ednastaven° jako horn° mez
         call      TestInt                  ; test, zda je oddàlovaá intervalu
         jc        XIn5                     ; nen° interval
         call      NumbS                    ; áten° á°sla horn°ho okraje
         jc        XIn2                     ; chyba - chybnÇ á°slo
         call      OutRet                   ; zru®en° bajtu z bufferu
         call      OutRet                   ; zru®en° bajtu z bufferu
         call      OutWrd                   ; nastaven° horn° meze
         jmp       short XIn5               ; v®e je OK

; ------ chybnÇ zad†n° intervalu

XIn2:    mov       dx,offset Err047         ; text - chybnÇ meze
         call      DispErr                  ; zobrazen° textu chyby
         ret

; ------ rezervace adresy pro pokraáov†n° ©etàzce IN

XIn5:    call      PushAdrX                 ; £schova adresy
         call      OutWrd                   ; rezerva m°sta pro adresu

; ------ test, zda n†sleduje dvouteáka ":"

         call      TestDvj
         jc        XIn2                     ; nen° dvojteáka - chyba
         ret

; -----------------------------------------------------------------------------
;        OUT - nesplnàna podm°nka CASE
; -----------------------------------------------------------------------------

PUBLIC   XOut
XOut:

; ------ test opr†vnànosti funkce

         mov       dx,offset Err044         ; text - bylo jië OUT
         cmp       al,41h                   ; bylo jië OUT ?
         je        XOut1                    ; bylo jië OUT
         mov       dx,offset Err041         ; text - OUT bez CASE
         cmp       al,40h                   ; bylo CASE-IN ?
         je        XOut2                    ; bylo CASE-IN
XOUt1:   call      DispErr                  ; zobrazen° chyby
         ret

; ------ nastaven° adresy pokraáov†n°

XOut2:
         call      OutRet                   ; zru®en° bajtu z bufferu
         call      SetAdr
         call      OutInc                   ; zvò®en° ukazatele

; ------ rezervace adresy pro pokraáov†n° ©etàzce IN

         call      PushAdrX                 ; £schova adresy
         call      OutWrd                   ; rezerva m°sta pro adresu

         mov       byte ptr ss:[bp],41h     ; p©°znak OUT
         ret

; -----------------------------------------------------------------------------
;        ENDCASE - konec vàtven°
; -----------------------------------------------------------------------------

PUBLIC   XEndCAse
XEndCase:mov       dx,offset Err045         ; text - ENDCASE bez CASE
         cmp       al,40h                   ; je CASE ?
         je        XEndCas1                 ; bylo CASE
         cmp       al,41h
         jne       XEndCas2                 ; nebylo CASE
XEndCas1:call      PopKod                   ; zru®en° k¢du ze z†sobn°ku
         ret

XEndCas2:call      DispErr
         call      TestKon                  ; test, zda je konec p©°kazu
         ret

; -----------------------------------------------------------------------------
;        PROC - definice procedury
; -----------------------------------------------------------------------------

PUBLIC   XProc
XProc:   call      OutRet                   ; zru®en° bajtu z bufferu

; ------ test uzav©en° procedur a funkc°

         pop       word ptr ds:[RetProc]
XProc1:  call      ClosIf                   ; uzav©en° podm°nek a cyklñ
         call      ClosProc                 ; uzav©en° procedur
         cmp       word ptr ss:[bp],0       ; je jië konec ?
         jne       XProc1                   ; nen° konec - dal®°
         push      word ptr ds:[RetProc]    ; n†vrat n†vratovÇ adresy

; ------ z†pis datovÇho bufferu na disk, inicializace programovÇho bufferu

         cmp       byte ptr ds:[ProgLev],0  ; byla deklaraán° á†st ?
         jne       XProc2                   ; nebyla deklaraán° á†st
         mov       cx,ds:[ProgNum]          ; poáet bajtñ bloku
         cmp       cx,ds:[SizDat]
         jbe       XProc12
         mov       ds:[SizDat],cx           ; £schova velikosti programu
XProc12: call      WritProg                 ; z†pis datovÇho bloku na disk
         mov       word ptr ds:[ProgNum],4  ; zru®en° dat v bufferu
         push      ds
         mov       ds,ds:[ProgSeg]          ; segment s programem
         mov       word ptr ds:[0],4        ; dÇlka bloku
         mov       word ptr ds:[2],0        ; startovac° adresa nedefinov†na
         pop       ds

; ------ definice novÇho jmÇna procedury

XProc2:  call      ReadIdnt                 ; áten° jmÇna procedury
         jc        XProc4                   ; chyba - neplatnÇ jmÇno

; ------ test, zda je procedura MAIN

         cmp       byte ptr ds:[DelIdent],4 ; dÇlka n†và®t° = 4 ?
         jne       XProc3                   ; nen° procedura MAIN
         cmp       word ptr ds:[BufIdent],"AM" ; je MAIN ?
         jne       XProc3                   ; nen° MAIN
         cmp       word ptr ds:[BufIdent+2],"NI" ; je MAIN ?
         jne       XProc3                   ; nen° MAIN
         inc       byte ptr ds:[ParMain]    ; p©°znak, ëe byla procedura MAIN
         push      ds
         mov       ax,ds:[ProgNum]          ; ukazatel programu
         mov       ds,ds:[ProgSeg]          ; segment s programem
         mov       ds:[2],ax                ; startovac° adresa programu
         pop       ds

; ------ test, zda je rezervovanÇ jmÇno procedury

XProc3:  call      SrcIdnt                  ; nalezen° v intern° tabulce
         mov       dx,offset Err013         ; text, ëe jmÇno je rezervov†no
         jnc       XProc5                   ; slovo nalezeno - chyba

; ------ za©azen° jmÇna do tabulky

         mov       al,3                     ; p©°znak definovanÇ procedury
         call      StorFlg                  ; uloëen° identifik†toru
         mov       dx,offset Err009         ; chyba - v°cen†sobnÇ pouëit° jmÇna
         jc        XProc5                   ; chyba - jmÇno jië existuje
         mov       ax,ds:[ProgNum]          ; adresa procedury
         mov       es:[di+1],ax             ; £schova adresy procedury
         jmp       short XProc6

; ------ chybnÇ zad†n° jmÇna procedury

XProc4:  mov       dx,offset Err018         ; text - neplatnÇ jmÇno procedury
XProc5:  call      DispErr                  ; zobrazen° textu chyby

; ------ inicializace identifik†toru v z†sobn°ku

XProc6:  mov       al,10h
         call      PushKod
         mov       byte ptr ds:[ProgLev],2  ; p©°znak otev©en° procedury
         ret

; -----------------------------------------------------------------------------
;        RETURN - n†vrat z procedury
; -----------------------------------------------------------------------------

PUBLIC   XRet
XRet:
         call      TestLeft                 ; test, zda je lev† z†vorka
         jc        XRet1                    ; nen° lev† z†vorka
         call      Vyraz                    ; dek¢dov†n° vòrazu
         jc        XRet2                    ; chybnò vòraz
         call      TestRght                 ; test, zda je prav† z†vorka
         jnc       XRet3                    ; je prav† z†vorka OK

XRet1:   mov       dx,offset Err01b         ; text - chybnò argument
XRet2:   call      DispErr                  ; zobrazen° textu chyby
         ret

; ------ rezervace adresy pro konec

XRet3:   call      TestKon                  ; test, zda je konec p©°kazu
         ret

; -----------------------------------------------------------------------------
;        ENDP - konec definice procedury
; -----------------------------------------------------------------------------

PUBLIC   XEndp
XEndp:

; ------ test uzav©en° procedur a funkc°

         pop       word ptr ds:[RetProc]
         call      ClosIf                   ; uzav©en° v®ech konstrukc°
         push      word ptr ds:[RetProc]    ; n†vrat n†vratovÇ adresy

; ------ test, zda je otev©ena procedura

XEndp4:  cmp       byte ptr ss:[bp],10h     ; je otev©ena procedura ?
         je        XEndp5                   ; je otev©ena procedura

         mov       dx,offset Err011         ; text - nen° ë†dn† procedura
         call      DispErr                  ; zobrazen° textu chyby
         ret

XEndp5:  call      OutRet                   ; n†vrat ukazatele
         call      PopKod                   ; zru®en° k¢du ze z†sobn°ku
         call      OutInc                   ; posun ukazatele
         mov       byte ptr ds:[ProgLev],1  ; p©°znak uzav©en° procedury
         call      TestKon                  ; test, zda je konec p©°kazu
         ret

; -----------------------------------------------------------------------------
;        BYTE - definice bajtovÇ promànnÇ
; -----------------------------------------------------------------------------

PUBLIC   XBYte
XByte:

; ------ test, zda je povolenÇ jmÇno

XByte1:  call      ReadIdnt                 ; áten° jmÇna promànnÇ
         mov       dx,offset Err001         ; text - neplatnÇ jmÇno
         jc        XByte6                   ; chybnÇ jmÇno
         call      SrcIdnt                  ; nalezen° v intern° tabulce
         mov       dx,offset Err013         ; text - jmÇno rezervov†no
         jnc       XByte6                   ; jmÇno je rezervov†no

; ------ zji®tàn° rozmàrñ promànnÇ

         call      CompI                    ; zji®tàn° rozmàrñ promànnÇ
         mov       cx,bx                    ; poáet bajtñ promànnÇ
         mov       al,1                     ; p©°znak - definovanò bajt
         cmp       cx,1                     ; je 1 bajt ?
         je        XByte2                   ; je 1 bajt
         mov       al,11h                   ; p©°znak indexovanÇ promànnÇ

;------- definice jmÇna promànnÇ

XByte2:  call      StorFlg                  ; uloëen° jmÇna promànnÇ
         mov       dx,offset Err009         ; chyba - v°cen†sobnÇ pouëit°
         jc        XByte6                   ; promànn† byla jië definov†na

; ------ zji®tàn°, zda je promànn† uráen†

         call      InpPri                   ; test, zda je promànn† uráen†
         jc        XByte7                   ; promànn† nen° uráen†

; ------ vstup jednotlivòch definián°ch bajtñ

         call      TestLeft                 ; test, zda je lev† z†vorka
         jnc       XByte3                   ; je lev† z†vorka
         mov       dx,offset Err004         ; text - chybnÇ naplnàn° promànnÇ
         cmp       bx,1                     ; je 1 prvek ?
         jne       XByte6                   ; chybnò z†pis - je v°ce prvkñ

XByte3:  mov       dx,offset Err01c         ; text - p©°li® mnoho £dajñ
         jcxz      XByte6                   ; jsou v®echny hodnoty - p©eplnàn°
         call      InpSpc                   ; vstup prvn°ho znaku
         jc        XByte7                   ; nen° dal®° znak
         cmp       al,'"'                   ; je text ?
         jne       XByte4                   ; nen° text

; ------ vstup textu

XByte32: call      InpCh                    ; vstup dal®°ho bajtu
         jc        XByte5                   ; nen° dal®° znak
         cmp       al,'"'                   ; jsou uvozovky ?
         je        XByte35                  ; jsou uvozovky
XByte33: jcxz      XByte3                   ; chyba - mnoho argumentñ
         call      OutCh                    ; uloëen° dal®°ho bajtu
         dec       cx
         jmp       short XByte32            ; dal®° znak

XByte35: call      InpCh
         jc        XByte5                   ; nen° dal®° znak
         cmp       al,'"'                   ; jsou zdvojenÇ uvozovky ?
         je        XByte33                  ; je platnò znak
         call      RetCh                    ; n†vrat znaku
         jmp       short XByte5             ; dal®° argument

; ------ vstup á°selnÇ promànnÇ

XByte4:  call      RetCh                    ; n†vrat znaku
         call      NumbS                    ; vstup á°sla se znamÇnkem
         mov       dx,offset Err01b         ; text - chybnò argument
         jc        XByte6                   ; chyba
         call      OutCh                    ; z†pis bajtu
         dec       cx                       ; sn°ëen° á°taáe bajtñ

; ------ test, zda je dal®° hodnota

XByte5:  call      TestRght                 ; je konec ?
         jnc       XByte7                   ; je konec argumentu - OK
         cmp       bx,1                     ; m† bòt jen jeden argument ?
         je        XByte7                   ; m† bòt jen jeden argument - konec
         call      TestCar                  ; test, zda je á†rka
         jnc       XByte3                   ; vstup dal®°ho bajtu
         mov       dx,offset Err01b         ; text - chybnò argument

; ------ hl†®en° chyby a nalezen° konce p©°kazu

XByte6:  call      DispErr                  ; zobrazen° textu chyby
Xbyte62: call      InpSpc
         jc        XByte63                  ; nen° dal®° znak
         cmp       al,";"                   ; je konec p©°kazu ?
         jne       XByte62                  ; nalezen° konce p©°kazu
XByte63: ret

; ------ vymaz†n° zbytku promànnÇ

XByte7:  jcxz      XByte72                  ; nen° dal®° bajt
         xor       al,al                    ; inicializaán° bajt 0
         call      OutCh                    ; z†pis bajtu
         loop      XByte7                   ; dal®° bajt

; ------ test, zda je dal®° promànn†

XByte72: call      TestCar                  ; test, zda je oddàlovac° á†rka
         jc        XByte8
         jmp       XByte1                   ; definice dal®° promànnÇ

XByte8:  call      TestKon                  ; test, zda je konec p©°kazu
         ret

; -----------------------------------------------------------------------------
;        WORD - definice slovn° promànnÇ
; -----------------------------------------------------------------------------

PUBLIC   XWord
XWord:
; ------ test, zda je povolenÇ jmÇno

XWord1:  call      ReadIdnt                 ; áten° jmÇna promànnÇ
         mov       dx,offset Err001         ; text - neplatnÇ jmÇno
         jc        XWord6                   ; chybnÇ jmÇno
         call      SrcIdnt                  ; nalezen° v intern° tabulce
         mov       dx,offset Err013         ; text - jmÇno rezervov†no
         jnc       XWord6                   ; jmÇno je rezervov†no

; ------ zji®tàn° rozmàrñ promànnÇ

         call      CompI                    ; zji®tàn° rozmàrñ promànnÇ
         mov       cx,bx                    ; poáet slov promànnÇ
         mov       al,5                     ; p©°znak - definovanÇ slovo
         cmp       cx,1                     ; je 1 slovo ?
         je        XWord2                   ; je 1 slovo
         mov       al,15h                   ; p©°znak indexovanÇ promànnÇ

;------- definice jmÇna promànnÇ

XWord2:  call      StorFlg                  ; uloëen° jmÇna promànnÇ
         mov       dx,offset Err009         ; chyba - v°cen†sobnÇ pouëit°
         jc        XWord6                   ; promànn† byla jië definov†na

; ------ zji®tàn°, zda je promànn† uráen†

         call      InpPri                   ; test, zda je promànn† uráen†
         jc        XWord7                   ; promànn† nen° uráen†

; ------ vstup jednotlivòch definián°ch slovoñ

         call      TestLeft                 ; test, zda je lev† z†vorka
         jnc       XWord3                   ; je lev† z†vorka
         mov       dx,offset Err004         ; text - chybnÇ naplnàn° promànnÇ
         cmp       bx,1                     ; je 1 prvek ?
         jne       XWord6                   ; chybnò z†pis - je v°ce prvkñ

XWord3:  mov       dx,offset Err01c         ; text - p©°li® mnoho £dajñ
         jcxz      XWord6                   ; jsou v®echny hodnoty - p©eplnàn°

; ------ vstup á°selnÇ promànnÇ

XWord4:  call      NumbS                    ; vstup á°sla se znamÇnkem
         mov       dx,offset Err01b         ; text - chybnò argument
         jc        XWord6                   ; chyba
         call      OutWrd                   ; z†pis slova
         dec       cx                       ; sn°ëen° á°taáe slov

; ------ test, zda je dal®° hodnota

XWord5:  call      TestRght                 ; je konec ?
         jnc       XWord7                   ; je konec
         cmp       bx,1                     ; m† bòt jen jeden argument ?
         je        XWord7                   ; m† bòt jen jeden argument - konec
         call      TestCar                  ; test, zda je á†rka
         jnc       XWord3                   ; vstup dal®°ho slovou
         mov       dx,offset Err01b         ; text - chybnò argument

; ------ hl†®en° chyby a nalezen° konce p©°kazu

XWord6:  call      DispErr                  ; zobrazen° textu chyby
XWord62: call      InpSpc
         jc        XWord63                  ; nen° dal®° znak
         cmp       al,";"                   ; je konec p©°kazu ?
         jne       XWord62                  ; nalezen° konce p©°kazu
XWord63: ret

; ------ vymaz†n° zbytku promànnÇ

XWord7:  jcxz      XWord72                  ; nen° dal®° slovo
         xor       ax,ax                    ; inicializaán° slovo 0
         call      OutWrd                   ; z†pis slova
         loop      XWord7                   ; dal®° slovo

; ------ test, zda je dal®° promànn†

XWord72: call      TestCar                  ; test, zda je oddàlovac° á†rka
         jnc       XWord1                   ; definice dal®° promànnÇ

XWord8:  call      TestKon                  ; test, zda je konec p©°kazu
         ret

; -----------------------------------------------------------------------------
;        STRING - definice textovÇ promànnÇ
; -----------------------------------------------------------------------------

PUBLIC   XString
XString:
         call      TestKon                  ; test, zda je konec p©°kazu
         ret

; -----------------------------------------------------------------------------
;        VAL - konverze ©etàzce na á°slo
; -----------------------------------------------------------------------------

PUBLIC   XVal
XVal:
         ret

; -----------------------------------------------------------------------------
;        STR - konverze á°sla na ©etàzec
; -----------------------------------------------------------------------------

PUBLIC   XStr
XStr:
         ret

; -----------------------------------------------------------------------------
;        LEN - dÇlka ©etàzce
; -----------------------------------------------------------------------------

PUBLIC   XLen
XLen:
         ret

; -----------------------------------------------------------------------------
;        CARD - test grafickÇ karty
; -----------------------------------------------------------------------------

PUBLIC   XCard
XCard:
         ret

; -----------------------------------------------------------------------------
;        VIDEO - nastaven° videom¢du
; -----------------------------------------------------------------------------

PUBLIC   XVideo
XVideo:
         mov       cx,1                     ; 1 argument
         call      Argum                    ; vstup argumentu
         ret

; -----------------------------------------------------------------------------
;        GETVIDEO - zji®tàn° videom¢du
; -----------------------------------------------------------------------------

PUBLIC   XGVideo
XGVideo:
         ret

; -----------------------------------------------------------------------------
;        MODE - nastaven° m¢du displeje
; -----------------------------------------------------------------------------

PUBLIC   XMode
XMode:
         mov       cx,1                     ; 1 argument
         call      Argum                    ; vstup argumentu
         ret

; -----------------------------------------------------------------------------
;        PAGE - nastaven° str†nek displeje
; -----------------------------------------------------------------------------

PUBLIC   XPage
XPage:
         mov       cx,2                     ; 2 argumenty
         call      Argum                    ; vstup argumentu
         ret

; -----------------------------------------------------------------------------
;        XPAGE - z†màna str†nek displeje
; -----------------------------------------------------------------------------

PUBLIC   XXPage
XXPage:
         ret

; -----------------------------------------------------------------------------
;        WINDOW - definice vòstupn°ho okna
; -----------------------------------------------------------------------------

PUBLIC   XWind
XWind:
         mov       cx,4                     ; 4 argumenty
         call      Argum                    ; vstup argumentu
         ret

; -----------------------------------------------------------------------------
;        PALETTE - definice palet displeje
; -----------------------------------------------------------------------------

PUBLIC   XPal
XPal:
         mov       cx,17                    ; 17 argumentñ
         call      Argum                    ; vstup argumentu
         ret

; -----------------------------------------------------------------------------
;        XCOLOR - z†màna barvy v oknà
; -----------------------------------------------------------------------------

PUBLIC   XXCOl
XXCol:
         mov       cx,2                     ; 2 argumenty
         call      Argum                    ; vstup argumentu
         ret

; -----------------------------------------------------------------------------
;        SETCURS - nastaven° pozice kurzoru
; -----------------------------------------------------------------------------

PUBLIC   XSetCur
XSetCur:
         mov       cx,2                     ; 2 argumenty
         call      Argum                    ; vstup argumentu
         ret

; -----------------------------------------------------------------------------
;        CURSOFF - vypnut° kurzoru
; -----------------------------------------------------------------------------

PUBLIC   XCurOff
XCurOff:
         ret

; -----------------------------------------------------------------------------
;        LOAD - naáten° objektu do pamàti
; -----------------------------------------------------------------------------

PUBLIC   XLoad
XLoad:

; ------ test, zda je prvn° znak z†vorka "("

         call      TestLeft                 ; test, zda je lev† z†vorka
         jc        XLoad7                   ; chyba - nejsou parametry

; ------ definice objektu

         call      DefObj                   ; definice á°sla objektu

; ------ oddàlovac° á†rka parametrñ

         call      TestCar                  ; test, zda je oddàlovac° á†rka
         jc        XLoad7                   ; chyba - neplatnò znak

; ------ definice jmÇna souboru

         call      DefTxt                   ; definice jmÇna
         jc        XLoad7                   ; chybnÇ jmÇno souboru

; ------ test, zda je prav† z†vorka ")"

         call      TestRght                 ; test, zda je prav† z†vorka
         jnc       XLoad8                   ; je prav† z†vorka - OK

; ------ chyba syntaxe p©°kazu

XLoad7:  mov       dx,offset Err01b         ; text - chyba syntaxe
         call      DispErr                  ; zobrazen° textu chyby
         ret

; ------ n†vrat z obsluhy

XLoad8:
         ret


; -----------------------------------------------------------------------------
;        PIC - zobrazen° objektu
; -----------------------------------------------------------------------------

PUBLIC   XObj
XObj:

; ------ test, zda je prvn° znak z†vorka "("

         call      TestLeft                 ; test, zda je lev† z†vorka
         jc        XObj7                    ; chyba - nejsou parametry

; ------ definice objektu

         call      DefObj                   ; definice á°sla objektu

; ------ oddàlovac° á†rka parametrñ

         call      TestCar                  ; test, zda je oddàlovac° á†rka
         jc        XObj7                    ; chyba - neplatnò znak

; ------ sou©adnice X

         call      Vyraz                    ; sou©adnice X

; ------ oddàlovac° á†rka parametrñ

         call      TestCar                  ; test, zda je oddàlovac° á†rka
         jc        XObj7                    ; chyba - neplatnò znak

; ------ sou©adnice Y

         call      Vyraz                    ; sou©adnice Y

; ------ test, zda je prav† z†vorka ")"

         call      TestRght                 ; test, zda je prav† z†vorka
         jnc       XObj8                   ; je prav† z†vorka - OK

; ------ chyba syntaxe p©°kazu

XObj7:   mov       dx,offset Err01b         ; text - chyba syntaxe
         call      DispErr                  ; zobrazen° textu chyby
         ret

; ------ n†vrat z obsluhy

XObj8:   ret

; -----------------------------------------------------------------------------
;        UNLOAD - zru®en° objektu v pamàti
; -----------------------------------------------------------------------------

PUBLIC   XUnld
XUnld:

; ------ test, zda je prvn° znak z†vorka "("

         call      TestLeft                 ; test, zda je lev† z†vorka
         jc        XUnld7                   ; chyba - nejsou parametry

; ------ definice objektu

         call      DefObj                   ; definice á°sla objektu

; ------ test, zda je prav† z†vorka ")"

         call      TestRght                 ; test, zda je prav† z†vorka
         jnc       XUnld8                   ; je prav† z†vorka - OK

; ------ chyba syntaxe p©°kazu

XUnld7:  mov       dx,offset Err01b         ; text - chyba syntaxe
         call      DispErr                  ; zobrazen° textu chyby
         ret

; ------ n†vrat z obsluhy

XUnld8:  ret

; -----------------------------------------------------------------------------
;        TEXT - zobrazen° textu
; -----------------------------------------------------------------------------

PUBLIC   XText
XText:

; ------ test, zda je prvn° znak z†vorka "("

         call      TestLeft                 ; test, zda je lev† z†vorka
         jc        XText7                   ; chyba - nejsou parametry

; ------ sou©adnice X

         call      Vyraz                    ; definice sou©adnice X
         jc        XText8

; ------ oddàlovac° á†rka

         call      TestCar                  ; test, zda je oddàlovac° á†rka
         jc        XText7                   ; nen° - chyba syntaxe

; ------ sou©adnice Y

         call      Vyraz                    ; definice sou©adnice Y
         jc        XText8

; ------ oddàlovac° á†rka

         call      TestCar                  ; test, zda je oddàlovac° á†rka
         jc        XText7                   ; nen° - chyba syntaxe

; ------ barva textu

         call      Vyraz                    ; definice barvy
         jc        XText8

; ------ oddàlovac° á†rka

         call      TestCar                  ; test, zda je oddàlovac° á†rka
         jc        XText7                   ; nen° - chyba syntaxe

; ------ definice textu k zobrazen°

         call      DefTxt                   ; definice textu
         jc        XText7                   ; chyba

; ------ test, zda je prav† z†vorka ")"

         call      TestRght                 ; test, zda je prav† z†vorka
         jnc       XText9                   ; je prav† z†vorka - OK

; ------ chyba syntaxe p©°kazu

XText7:  mov       dx,offset Err01b         ; text - chyba syntaxe
XText8:  call      DispErr                  ; zobrazen° textu chyby
         ret

; ------ n†vrat z obsluhy

XText9:  ret

; -----------------------------------------------------------------------------
;        POINT - zobrazen° bodu
; -----------------------------------------------------------------------------

PUBLIC   XPoint
XPoint:
         mov       cx,3                     ; 3 argumenty
         call      Argum                    ; vstup argumentu
         ret

; -----------------------------------------------------------------------------
;        XLINE - zobrazen° á†ry
; -----------------------------------------------------------------------------

PUBLIC   XLine
XLine:
         mov       cx,5                     ; 5 argumentñ
         call      Argum                    ; vstup argumentu
         ret

; -----------------------------------------------------------------------------
;        XRLINE - zobrazen° á†ry relativnà
; -----------------------------------------------------------------------------

PUBLIC   XRline
XRline:
         mov       cx,3                     ; 3 argumenty
         call      Argum                    ; vstup argumentu
         ret

; -----------------------------------------------------------------------------
;        BOX - zobrazen° obdÇln°ku
; -----------------------------------------------------------------------------

PUBLIC   XBox
XBox:
         mov       cx,5                     ; 5 argumentñ
         call      Argum                    ; vstup argumentu
         ret

; -----------------------------------------------------------------------------
;        FBOX - zobrazen° plnÇho obdÇln°ku
; -----------------------------------------------------------------------------

PUBLIC   XFBox
XFBox:
         mov       cx,5                     ; 5 argumentñ
         call      Argum                    ; vstup argumentu
         ret

; -----------------------------------------------------------------------------
;        CIRC - zobrazen° kruënice
; -----------------------------------------------------------------------------

PUBLIC   XCirc
XCirc:
         mov       cx,4                     ; 4 argumenty (barva, sou©., polom.)
         call      Argum                    ; vstup argumentu
         ret

; -----------------------------------------------------------------------------
;        FCIRC - zobrazen° plnÇ kruënice
; -----------------------------------------------------------------------------

PUBLIC   XFCirc
XFCirc:
         mov       cx,4                     ; 4 argumenty
         call      Argum                    ; vstup argumentu
         ret

; -----------------------------------------------------------------------------
;        PRESS - test uráenÇ kl†vesy, zda je stisknuta
; -----------------------------------------------------------------------------

PUBLIC   XPress
XPress:
         mov       cx,1                     ; 1 argument
         call      Argum                    ; vstup argumentu
         ret

; -----------------------------------------------------------------------------
;        TESTKEY - test p©ipravenÇ kl†vesy
; -----------------------------------------------------------------------------

PUBLIC   XTstKey
XTstKey:
         ret

; -----------------------------------------------------------------------------
;        GETKEY - vstup znaku z kl†vesnice
; -----------------------------------------------------------------------------

PUBLIC   XGtKey
XGtKey:
         ret

; -----------------------------------------------------------------------------
;        STATKEY - stavovÇ slovo kl†vesnice
; -----------------------------------------------------------------------------

PUBLIC   XStatKey
XStatKey:
         ret

; -----------------------------------------------------------------------------
;        INPUT - vstup textu
; -----------------------------------------------------------------------------

PUBLIC   XInp
XInp:
         ret

; -----------------------------------------------------------------------------
;        SOUND - ovl†d†n° zvukovÇho gener†toru
; -----------------------------------------------------------------------------

PUBLIC   XSound
XSound:
         mov       cx,1                     ; 1 argument
         call      Argum                    ; vstup argumentu
         ret

; -----------------------------------------------------------------------------
;        TON - zahr†n° t¢nu danÇ frekvence a dÇlky
; -----------------------------------------------------------------------------

PUBLIC   XTon
XTon:
         mov       cx,2                     ; 2 argumenty
         call      Argum                    ; vstup argumentu
         ret

; -----------------------------------------------------------------------------
;        MUSIC - zahr†n° melodie
; -----------------------------------------------------------------------------

; ------ uloëen° slova dÇlky melodie

XMusK:
         push      es                       ; £schova ES
         mov       es,ds:[ProgSeg]          ; segment s programem
         mov       ax,ds:[ProgNum]          ; ukazatel programu
         sub       ax,bx                    ; dÇlka melodie*2 + 2
         sub       ax,2                     ; dÇlka melodie*2
         shr       ax,1                     ; dÇlka melodie
         mov       es:[bx],ax               ; nastaven° dÇlky melodie
         pop       es                       ; n†vrat ES
         ret

; ------ chyba syntaxe p©°kazu

XMusX:   mov       dx,offset Err01b         ; text - chyba syntaxe
         call      DispErr                  ; zobrazen° textu chyby
         ret




PUBLIC   XMusic
XMusic:

; ------ test, zda je prvn° znak z†vorka "("

         call      TestLeft                 ; test, zda je lev† z†vorka
         jc        XMusX                    ; chyba - nejsou parametry

; ------ £schova ukazatele zaá†tku melodie

         mov       bx,ds:[ProgNum]          ; £schova ukazatele programu
         call      OutWrd                   ; rezerva pro slovo dÇlky melodie

; ------ inicializace ukazatelñ melodie

         mov       word ptr ds:[Oktava],4*12+1 ; inicializaán° okt†va 4
         mov       byte ptr ds:[DelTon],4   ; inicializaán° dÇlka t¢nu 4
         mov       word ptr ds:[Krizky],0   ; zru®en° k©°ëkñ

; ------ nalezen° platnÇho znaku

XMus1:   call      InpSpc
         jc        XMusX                    ; neoáek†vanò konec
         cmp       al,")"                   ; je konec parametru ?
         je        XMusK                    ; konec parametru
         cmp       al,","                   ; je oddàlovac° á†rka ?
         je        XMus1                    ; oddàlovac° á†rka - ignoruje se

; ------ nastaven° okt†vy - parametr "On"

         cmp       al,"O"                   ; je nastaven° okt†vy "O" ?
         jne       XMus2                    ; nen° nastaven° okt†vy "O"
         call      Numb                     ; vstup á°sla - nastaven° okt†vy
         jc        XMusX                    ; chyba
         cmp       ax,9
XMusXA:  ja        XMusX                    ; chybnÇ á°slo okt†vy
         mov       ah,12                    ; dÇlka okt†vy v pñlt¢nech
         mul       ah                       ; p©epoáet okt†vy na pñlt¢ny
         inc       ax                       ; poá†teán° offset = 1
         mov       ds:[Oktava],ax           ; £schova á°sla okt†vy v pñlt¢nech
         jmp       short XMus1              ; vstup dal®°ho parametru

; ------ zvò®en° t¢nu o okt†vu - znak "+"

XMus2:   cmp       al,"+"                   ; je zvò®en° okt†vy ?
         jne       XMus3                    ; nen° zvò®en° okt†vy "+"
         add       word ptr ds:[Krizky],12  ; zvò®en° t¢nu o okt†vu
         jmp       short XMus1              ; vstup dal®°ho parametru

; ------ sn°ëen° okt†vy - znak "-"

XMus3:   cmp       al,"-"                   ; je sn°ëen° okt†vy ?
         jne       XMus4                    ; nen° sn°ëen° okt†vy "-"
         sub       word ptr ds:[Krizky],12  ; sn°ëen° t¢nu o okt†vu
         jmp       short XMus1              ; vstup dal®°ho parametru

; ------ transpozice t¢niny - parametr "Tn"

XMus4:   cmp       al,"T"                   ; je transpozice t¢niny ?
         jne       XMus5                    ; nen° transpozice t¢niny
         call      Numb                     ; vstup á°sla - transpozice
XMusXC:  jc        XMusX                    ; chyba syntaxe
         add       ds:[Oktava],ax           ; transpozice t¢niny
         jmp       short XMus1              ; vstup dal®°ho parametru

; ------ posun t¢nu o pñlt¢n - znak "#"

XMus5:   cmp       al,"#"                   ; je posun o pñlt¢n ?
         jne       XMus6                    ; nen° posun o pñlt¢n
         inc       word ptr ds:[Krizky]     ; zvò®en° á°taáe k©°ëkñ
         jmp       short XMus1              ; vstup dal®°ho parametru

; ------ nastaven° dÇlky t¢nu - parametr "Ln"

XMus6:   cmp       al,"L"                   ; je nastaven° dÇlky t¢nu ?
         jne       XMus7                    ; nen° nastaven° dÇlky t¢nu
         call      Numb                     ; vstup á°sla - dÇlka t¢nu
         jc        XMusXC                   ; chyba syntaxe
         cmp       ax,255                   ; max. dÇlka
XMusXA2: ja        XMusXA                   ; chyba dÇlky t¢nu
         mov       byte ptr ds:[DelTon],al  ; £schova dÇlky t¢nu
XMus11:  jmp       short XMus1              ; vstup dal®°ho parametru

; ------ prodleva - parametr R

XMus7:   cmp       al,"R"                   ; je prodleva ?
         mov       dl,0                     ; á°slo t¢nu - prodleva
         je        XMus9

; ------ je t¢n - parametr C, D, E, F, G, A, H

         mov       dl,1                     ; je t¢n C
         cmp       al,"C"
         je        XMus8                    ; je C

         mov       dl,3
         cmp       al,"D"
         je        XMus8                    ; je D

         mov       dl,5
         cmp       al,"E"
         je        XMus8                    ; je E

         mov       dl,6
         cmp       al,"F"
         je        XMus8                    ; je F

         mov       dl,8
         cmp       al,"G"
         je        XMus8                    ; je G

         mov       dl,10
         cmp       al,"A"
         je        XMus8                    ; je A

         mov       dl,12
         cmp       al,"H"
         stc
         jne       XMusXC                   ; nen° "H" - chyba

; ------ zvò®en° t¢nu o okt†vu a pñlt¢ny

XMus8:   mov       dh,0
         add       dx,ds:[Oktava]           ; zvò®en° t¢nu o okt†vy
         add       dx,ds:[Krizky]           ; zvò®en° t¢nu o k©°ëky
         cmp       dx,121                   ; maxim†ln° t¢n 121
XMusXA3: ja        XMusXA2                  ; p©eteáen°

; ------ uloëen° k¢du t¢nu

XMus9:   mov       al,dl                    ; k¢d t¢nu
         call      OutCh                    ; z†pis bajt k¢du t¢nu
         mov       word ptr ds:[Krizky],0   ; zru®en° p©°znaku k©°ëkñ

; ------ prodlouëen° t¢nu o pñlt¢n

         mov       dx,0                     ; á°taá znakñ "." a "^"
XMusA:   call      InpSpc                   ; vstup dal®°ho znaku
         jc        XMusXC                   ; to je chyba
         cmp       al,"."                   ; je prodlouëen° o pñlt¢n ?
         jne       XMusB                    ; nen° prodlouëen° o pñlt¢n
         inc       dx                       ; zvò®en° á°taáe pñlt¢nñ
         jmp       short XMusA              ; vstup dal®°ho znaku

; ------ zkr†cen° t¢nu na polovinu

XMusB:   cmp       al,"<"                   ; je zkr†cen° t¢nu na polovinu ?
         jne       XMusC                    ; nen° zkr†cen° t¢nu na polovinu
         sub       dx,2                     ; zvò®en° á°taáe zkr†cen°
         jmp       short XMusA              ; vstup dal®°ho znaku

; ------ prodlouëen° t¢nu na dvojn†sobek

XMusC:   cmp       al,">"                   ; je dvojn†sobnÇ prodlouëen° t¢nu ?
         jne       XMusH                    ; nen° dvojn†sobnÇ prodlouëen° t¢nu
         add       dx,2
         jmp       short XMusA              ; vstup dal®°ho znaku

; ------ dek¢dov†n° dÇlky t¢nu

XMusH:   call      RetCh                    ; navr†cen° znaku
         call      NumB                     ; vstup á°sla dÇlky t¢nu
         jnc       XMusD                    ; dÇlka t¢nu OK
         mov       al,ds:[DelTon]           ; implicitn° dÇlka t¢nu
         mov       ah,0
XMusD:   cmp       ax,255                   ; je dÇlka t¢nu povolen† ?
         ja        XMusXA3                  ; dÇlka t¢nu nen° povolen†

; ------ £prava dÇlky t¢nu podle p©ep°naáñ

         or        dx,dx                    ; je prodlouëen° nebo zkr†cen° ?
         je        XMusF                    ; nen° ë†dn† oprava
         js        XMusE                    ; je zkr†cen° doby

; ------ je prodlouëen° doby

         mov       cx,dx                    ; poáet prodlouëen° o pñlt¢n
         shr       cx,1                     ; poáet prodlouëen° o celò t¢n
         shl       ax,cl                    ; prodlouëen° doby
         jmp       short XMusF

; ------ je zkr†cen° doby

XMusE:   neg       dx
         mov       cx,dx                    ; poáet zkr†cen° o pñlt¢n
         shr       cx,1                     ; poáet zkr†cen° o celò t¢n
         shr       ax,cl                    ; zkr†cen° doby

; ------ p©°padnÇ prodlouëen° doby o pñlt¢n

XMusF:   shr       dx,1                     ; je prodlouëen° o pñlt¢n ?
         jnc       XMusG                    ; nen° prodlouëen° o pñlt¢n
         mov       dx,ax                    ;
         shr       dx,1
         add       ax,dx                    ; prodlouëen° o pñlt¢n

; ------ uloëen° dÇlky t¢nu

XMusG:   call      OutCh                    ; z†pis bajtu dÇlky t¢nu
         jmp       XMus11                   ; dek¢dov†n° dal®°ho parametru


; -----------------------------------------------------------------------------
;        MUSICSTOP - zastaven° hry melodie
; -----------------------------------------------------------------------------

PUBLIC   XMStop
XMStop:
         ret

; -----------------------------------------------------------------------------
;        MUSICGET - poskytnut° ukazatele melodie
; -----------------------------------------------------------------------------

PUBLIC   XMusGet
XMusGet:
         ret

; -----------------------------------------------------------------------------
;        WAIT - áek†n° po danou dobu
; -----------------------------------------------------------------------------

PUBLIC   XWait
XWait:
         mov       cx,1                     ; 1 argument
         call      Argum                    ; vstup argumentu
         ret

; -----------------------------------------------------------------------------
;        TIME - poskytnut° systÇmovÇho áasu
; -----------------------------------------------------------------------------

PUBLIC   XTime
XTime:
         ret

; -----------------------------------------------------------------------------
;        DATE - poskytnut° systÇmovÇho data
; -----------------------------------------------------------------------------

PUBLIC   XDate
XDate:
         ret

; -----------------------------------------------------------------------------
;        XMOUSE - poskytnut° pozice my®i
; -----------------------------------------------------------------------------

PUBLIC   XXMous
XXMous:
         ret

; -----------------------------------------------------------------------------
;        YMOUSE - poskytnut° ©†dku my®i
; -----------------------------------------------------------------------------

PUBLIC   XYMous
XYMous:
         ret

; -----------------------------------------------------------------------------
;        GETMOUSE - poskytnut° tlaá°tek my®i
; -----------------------------------------------------------------------------

PUBLIC   XKMous
XKMous:
         ret

; -----------------------------------------------------------------------------
;        MOUSEON - zapnut° kurzoru my®i
; -----------------------------------------------------------------------------

PUBLIC   XMon
XMon:
         ret

; -----------------------------------------------------------------------------
;        MOUSEOFF - vypnut° kurzoru my®i
; -----------------------------------------------------------------------------

PUBLIC   XMoff
XMoff:
         ret

; -----------------------------------------------------------------------------
;        CURMOUSE - definice kurzoru my®i
; -----------------------------------------------------------------------------

PUBLIC   XDefm
XDefm:
         ret

; -----------------------------------------------------------------------------
;        WINMOUSE - definice okna my®i
; -----------------------------------------------------------------------------

PUBLIC   XWinm
XWinm:
         mov       cx,4                     ; 4 argumenty
         call      Argum                    ; vstup argumentu
         ret

; -----------------------------------------------------------------------------
;        RND - gener†tor n†hodnÇho á°sla
; -----------------------------------------------------------------------------

PUBLIC   XRnd
XRnd:
         mov       cx,1
         call      Argum
         ret

; -----------------------------------------------------------------------------
;        REGISTER - nastaven° registru CRT
; -----------------------------------------------------------------------------

PUBLIC   XReg
XReg:
         mov       cx,2                     ; 2 parametry
         call      Argum
         ret

; -----------------------------------------------------------------------------
;        HSYN - horizont†ln° synchronizace
; -----------------------------------------------------------------------------

PUBLIC   XHSyn
XHSyn:
         mov       cx,1                     ; 1 parametr
         call      Argum
         ret

; -----------------------------------------------------------------------------
;        VSYN - vertik†ln° synchronizace
; -----------------------------------------------------------------------------

PUBLIC   XVSyn
XVSyn:
         mov       cx,1                     ; 1 parametr
         call      Argum
         ret

; -----------------------------------------------------------------------------
;        PATTERN - vzorek vòplnà
; -----------------------------------------------------------------------------

PUBLIC   XPatt
XPatt:
         mov       cx,8                     ; 8 parametrñ
         call      Argum
         ret

; -----------------------------------------------------------------------------
;        STICK - joystickovò vstup
; -----------------------------------------------------------------------------

PUBLIC   XStick
XStick:
         ret

; -----------------------------------------------------------------------------
;        TRIG - aktivaán° tlaá°tko Joysticku
; -----------------------------------------------------------------------------

PUBLIC   XTrig
XTrig:
         ret

; -----------------------------------------------------------------------------
;        SIN - funkce sinus
; -----------------------------------------------------------------------------

PUBLIC   XSin
XSin:    mov       cx,1
         call      Argum                    ; 1 argument
         ret

; -----------------------------------------------------------------------------
;        COS - funkce cosinus
; -----------------------------------------------------------------------------

PUBLIC   XCos
XCos:    mov       cx,1
         call      Argum                    ; 1 argument
         ret

; -----------------------------------------------------------------------------
;        TAN - funkce tangent
; -----------------------------------------------------------------------------

PUBLIC   XTan
XTan:    mov       cx,1
         call      Argum                    ; 1 argument
         ret

; -----------------------------------------------------------------------------
;        ABS - absolutn° hodnota
; -----------------------------------------------------------------------------

PUBLIC   XAbs
XAbs:    mov       cx,1
         call      Argum                    ; 1 argument
         ret

; -----------------------------------------------------------------------------
;        ATN - funkce arcutangent
; -----------------------------------------------------------------------------

PUBLIC   XAtn
XAtn:    mov       cx,1
         call      Argum                    ; 1 argument
         ret

; -----------------------------------------------------------------------------
;        SQR - funkce odmocnina
; -----------------------------------------------------------------------------

PUBLIC   XSqr
XSqr:    mov       cx,1
         call      Argum                    ; 1 argument
         ret



; *****************************************************************************
;
;                        Obsluha uëivatelskÇho n†và®t°
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;                        Uloëen° jmÇna do bufferu
; -----------------------------------------------------------------------------
; VSTUP:  AL=typ jmÇna
; Vòstup: AL=typ nalezenÇho jmÇna (indik†tor)
;         ES:DI=adresa jmÇna v tabulce symbolñ
;         CY=je jië definov†no
; -----------------------------------------------------------------------------
; Popis definice jmÇna v tabulce uëivatelskòch jmen:
;      00h=Indikaán° bajt: bit 0:    0=nen° definov†no, 1=jmÇno definov†no
;                          bit 1:    0=data, 1=procedura
;                          bit 2,3:  0 = BYTE
;                                    1 = WORD
;                                    (2 = STRING)
;                                    3 = OBJECT
;                          bit 4:    1 = indexovan† promànn†
;      01h=adresa symbolu (slovo)
;      03h=dÇlka jmÇna (max. 64 bajtñ)
;      04h=text jmÇna
; -----------------------------------------------------------------------------
;˛
PUBLIC   StorFlg
StorFlg:

; ------ £schova registrñ

         push      bx
         push      cx
         push      si

; ------ inicializace registrñ

         cld
         mov       es,ds:[FlagBuf]          ; segment s bufferem symbolñ
         xor       di,di                    ; poá†teán° adresa v bufferu
         mov       si,offset DelIdent       ; dÇlka jmÇna a text jmÇna
         mov       ch,0                     ; CH <- 0

; ------ test, zda je je®tà dal®° jmÇno v bufferu

StorFlg1:cmp       di,ds:[FlagNum]          ; je jië konec tabulky ?
         jae       StorFlg3                 ; je konec tabulky

; ------ porovn†n°, zda je hledanÇ jmÇno

         mov       cl,es:[di+3]             ; dÇlka jmÇna
         inc       cl                       ; porovn†v† se i dÇlkovò bajt
         push      si
         push      di
         push      cx
         add       di,3                     ; adresa zaá†tku jmÇna s dÇlkou
         repe      cmpsb                    ; porovn†n° n†và®t°
         pop       cx
         pop       di
         pop       si
         stc                                ; p©°znak, ëe jmÇno bylo nalezeno
         je        StorFlg5                 ; jmÇno nalezeno OK

; ------ nastaven° na dal®° jmÇno v tabulce

         add       di,3                     ; p©eskoáen° £vodn°ch bajtñ
         add       di,cx                    ; p©eskoáen° textu jmÇna
         jmp       short StorFlg1           ; test dal®°ho jmÇna

; ------ uloëen° novÇho n†và®t° do bufferu

StorFlg3:cmp       di,-70                   ; dosaëeno konce bufferu ?
         jae       StorFlg7                 ; chyba p©eteáen° pamàti
         push      di                       ; £schova adresy zaá†tku jmÇna
         stosb                              ; uloëen° indikaán°ho bajtu
         mov       bx,ds:[ProgNum]          ; adresa ukazatele programu
         mov       es:[di],bx               ; nastaven° adresy symbolu
         add       di,2                     ; zvò®en° adresy
         mov       cl,ds:[si]               ; dÇlka jmÇna symbolu
         inc       cx                       ; uloë° se i bajt dÇlky
         rep       movsb                    ; uloëen° textu jmÇna
         mov       ds:[FlagNum],di          ; nov† adresa konce bufferu
         pop       di                       ; adresa zaá†tku jmÇna
         clc                                ; p©°znak, ëe je novÇ jmÇno

; ------ zji®tàn° parametrñ jmÇna ES:DI

StorFlg5:mov       al,es:[di]               ; indikaán° bajt symbolu

; ------ n†vrat registrñ

StorFlg6:pop       si
         pop       cx
         pop       bx
         ret

; ------ chyba p©eteáen° pamàti

StorFlg7:mov       dx,offset Mem1Txt        ; text - p©eteáen° tabulky symbolñ
         jmp       WritPrg1                 ; chyba - p©eteáen° pamàti

; *****************************************************************************
;
;                   Obsluha standardn°ho identifik†toru
;
; *****************************************************************************


; -----------------------------------------------------------------------------
;        Naáten° identifik†toru (symbolu) (CY=nen° platnò identifik†tor)
; -----------------------------------------------------------------------------

PUBLIC   ReadIdnt

; ------ p©°prava registrñ

ReadIdnt:push      cx
         push      di
         push      es
         mov       byte ptr ds:[DelIdent],0 ; dÇlka n†và®t° = 0
         mov       cx,64                    ; maxim†ln° poáet znakñ identifik.
         mov       di,offset BufIdent       ; buffer k uloëen°
         push      ds
         pop       es                       ; ES <- datovò segment
         cld                                ; smàr nahoru

; ------ naáten° prvn°ho znaku identifik†toru

         call      InpSpc                   ; vstup znaku s vypustàn°m mezer
         jc        ReadIdn5                 ; nen° dal®° znak
         call      IdentCh                  ; test, zda je to platnò znak
         jc        ReadIdn4                 ; nen° to platnò znak - n†vrat

; ------ test, zda to nen° á°slice (= zak†zanò prvn° znak)

         cmp       al,"0"                   ; je to á°slice ?
         jb        ReadIdn2                 ; nen° to á°slice - OK
         cmp       al,"9"+1                 ; je to á°slice ?
         jb        ReadIdn4                 ; je to á°slice - zak†zanò znak

; ------ uloëen° znaku identifik†toru

ReadIdn2:stosb                              ; uloëen° znaku do bufferu
         inc       byte ptr ds:[DelIdent]   ; zvò®en° á°taáe dÇlky n†và®t°
         dec       cx                       ; sn°ëen° á°taáe max. poátu znakñ
         jz        ReadIdn3                 ; p©ekroáen max. poáet znakñ

; ------ vstup dal®°ho znaku identifik†toru

         call      InpCh                    ; vstup dal®°ho znaku
         cmc
         jnc       ReadIdn5                 ; nen° dal®° znak
         call      IdentCh                  ; test, zda to je platnò znak
         jnc       ReadIdn2                 ; je platnò znak - dal®° znak

; ------ n†vrat posledn°ho znaku

ReadIdn3:clc                                ; p©°znak - n†và®t° je OK
ReadIdn4:call      RetCh                    ; n†vrat znaku
ReadIdn5:pop       es
         pop       di
         pop       cx
         ret

; -----------------------------------------------------------------------------
;        Test, zda je znak symbolu (CY=nen° platnò znak identifik†toru)
; -----------------------------------------------------------------------------

PUBLIC   IdentCh

IdentCh: call      UpCase                   ; p©evod na velkÇ p°smeno
         cmp       al,"_"                   ; je podtrë°tko ?
         je        IdentCh2                 ; je platnò znak identifik†toru
         cmp       al,"0"                   ; je á°slice ?
         jb        IdentCh2                 ; nen° platnò znak identifik†toru
         cmp       al,"9"+1                 ; je á°slice ?
         cmc
         jnc       IdentCh2                 ; je á°slice - je platnò znak
         cmp       al,"A"                   ; je p°smeno ?
         jb        IdentCh2                 ; nen° platnò znak identifik†toru
         cmp       al,"Z"+1                 ; je p°smeno ?
         cmc
         jnc       IdentCh2                 ; je p°smeno - je platnò znak
         cmp       al,128                   ; je znak > 128 ?

IdentCh2:ret

; -----------------------------------------------------------------------------
;        Nalezen° identifik†toru v tabulce intern°ch povelñ
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: DS:SI=adresa slova v tabulce
;         AL=á°slo slova v tabulce (0...)
;         CY=slovo nenalezeno
; -----------------------------------------------------------------------------

PUBLIC   SrcIdnt

SrcIdnt:

; ------ £schova registrñ

         push      cx
         push      di
         push      es
         push      ds
         pop       es                       ; ES <- DS

; ------ p©°prava registrñ

         cld                                ; smàr posunu ukazatelñ nahoru
         mov       al,0                     ; ukazatel á°sla identifik†toru
         mov       si,offset TabKey         ; tabulka intern°ch slov
         mov       di,offset DelIdent       ; dÇlka identifik†toru + identifik.
         mov       ch,0                     ; CH <- 0 vy®®° bajt dÇlky

; ------ porovn†n° jednoho slova

SrcIdn1: mov       cl,ds:[si]               ; dÇlka slova
         stc                                ; p©°znak chyby - slovo nenalezeno
         jcxz      SrcIdn3                  ; je konec tabulky
         inc       cx                       ; p©iáten° bajtu dÇlky
         push      cx
         push      di
         push      si
         repe      cmpsb                    ; porovn†n° ©etàzcñ
         pop       si
         pop       di
         pop       cx
         je        SrcIdn3                  ; slovo nalezeno

; ------ nastaven° na dal®° slovo

         add       si,cx                    ; p©eskoáen° dÇlky a slova
         add       si,2                     ; p©eskoáen° adresy obsluhy
         inc       al                       ; zvò®en° á°taáe slov
         jmp       short SrcIdn1            ; porovn†n° dal®°ho slova

; ------ n†vrat registrñ

SrcIdn3: pop       es
         pop       di
         pop       cx
         ret


; -----------------------------------------------------------------------------
;        N†vrat n†và®t° do bufferu
; -----------------------------------------------------------------------------

PUBLIC   RetIdnt

RetIdnt: push      ax
         push      cx
         push      si
         mov       si,offset BufIdent-1     ; buffer s identifik†torem - 1
         mov       ch,0
         mov       cl,ds:[DelIdent]         ; dÇlka identifik†toru
         jcxz      RetIdnt2                 ; nen° ë†dnò znak
         add       si,cx                    ; posledn° znak v bufferu
RetIdnt1:std                                ; smàr dolñ
         lodsb                              ; naáten° znaku k n†vratu
         call      RetCh                    ; n†vrat znaku do bufferu
         loop      RetIdnt1                 ; n†vrat dal®°ho znaku
RetIdnt2:cld                                ; smàr nahoru
         pop       si
         pop       cx
         pop       ax
         ret

; *****************************************************************************
;
;                    Vstup ze vstupn°ho souboru
;
; *****************************************************************************

;; -----------------------------------------------------------------------------
;;        Nalezen° oddàlovaáe
;; -----------------------------------------------------------------------------
;
;PUBLIC   SrcSpc
;SrcSpc:  call      InpCh                    ; vstup dal®°ho znaku
;         jc        SrcSpc2                  ; nen° dal®° znak
;         cmp       al," "                   ; je oddàlovaá ?
;         jbe       SrcSpc1                  ; je to oddàlovaá
;         cmp       al,","                   ; je á†rka ?
;         je        SrcSpc1                  ; je á†rka - je to oddàlovaá
;         cmp       al,";"                   ; je st©edn°k ?
;         je        SrcSpc1                  ; je st©edn°k - je to oddàlovaá
;         cmp       al,"{"                   ; je pozn†mka ?
;         jne       SrcSpc                   ; nen° pozn†mka - dal®° znak
;SrcSpc1: call      RetCh                    ; n†vrat posledn°ho znaku
;         clc
;SrcSpc2: ret

; -----------------------------------------------------------------------------
;        Vstup znaku s p©evodem na velkÇ p°smeno
; -----------------------------------------------------------------------------

PUBLIC   InpChU

InpChU:  call      InpCh                    ; vstup znaku ze vstupn°ho souboru
         jc        InpChU2                  ; nen° dal®° znak
         call      UpCase                   ; p©evod znaku na velkÇ p°smeno
InpChU2: ret

; -----------------------------------------------------------------------------
;        P©evod znaku na velkÇ p°smeno (ponech†v† registr p©°znakñ)
; -----------------------------------------------------------------------------

PUBLIC   UpCase

UpCase:  pushf
         cmp       al,"a"
         jb        UpCase2
         cmp       al,"z"
         ja        UpCase2
         sub       al,20h
UpCase2: popf
         ret

; -----------------------------------------------------------------------------
;        Vypu®tàn° oddàlovaáñ z textu
; -----------------------------------------------------------------------------

PUBLIC   InpSpc

; ------ vypustàn° oddàlovac°ch znakñ (mezera, tabel†tor, CR, LF)

InpSpc:  call      InpCh                    ; vstup znaku ze souboru
         jc        InpSpc3                  ; nen° dal®° znak (konec souboru)
         cmp       al," "                   ; je oddàlovaá ?
         jbe       InpSpc                   ; je oddàlovac° znak

; ------ test, zda je pozn†mka (z†vorka {)

         cmp       al,"{"                   ; je zaá†tek pozn†mky ?
         clc                                ; p©°znak operace OK
         jne       InpSpc3                  ; nen° pozn†mka - konec

; ------ vypustàn° textu po konce pozn†mky (z†vorka })

InpSpc1: call      InpCh                    ; vstup dal®°ho znaku ze souboru
         jc        InpSpc3                  ; nen° dal®° znak
         cmp       al,"{"                   ; je zaá†tek dal®° pozn†mky ?
         jne       InpSpc2                  ; nen° zaá†tek dal®° pozn†mky
         call      InpSpc1                  ; vypustàn° vnit©n° pozn†mky
         jc        InpSpc3                  ; nen° dal®° znak
InpSpc2: cmp       al,"}"                   ; je konec pozn†mky ?
         jne       InpSpc1                  ; nalezen° konce pozn†mky
         jmp       short InpSpc             ; vypustàn° oddàlovaáñ

InpSpc3: call      UpCase                   ; p©evod znaku na velkÇ p°smeno
         ret

; -----------------------------------------------------------------------------
;        Vstup znaku ze vstupn°ho souboru (CY=nen° dal®° znak)
; -----------------------------------------------------------------------------

PUBLIC   InpCh

; ------ vyjmut° znaku z p©echodnÇho bufferu

InpCh:   cmp       word ptr ds:[BuffChU],0  ; je v p©echodnÇm bufferu znak ?
         je        InpCh7                   ; v p©echodnÇm bufferu nen° znak
         push      si                       ; £schova SI
         mov       si,ds:[BuffChU]          ; poáet bajtñ v p©echodnÇm bufferu
         dec       si                       ; sn°ëen° poátu bajtñ v bufferu
         mov       ds:[BuffChU],si          ; novò poáet bajtñ v bufferu
         mov       al,ds:[BuffCh+si]        ; áten° znaku z bufferu
         pop       si                       ; n†vrat SI
         jmp       short InpCh22

; ------ kontrola, zda je v bufferu nàjakò znak

InpCh7:  cmp       word ptr ds:[SrcNum],0   ; je v buffer je®tà nàjakò znak ?
         jne       InpCh2                   ; v bufferu je je®tà nàjakò znak

; ------ naáten° dal®°ho bloku ze souboru

         push      ax
         push      bx
         push      cx
         push      dx

         cmp       byte ptr ds:[SrcEnd],0   ; byl jië konec souboru ?
         jne       InpCh4                   ; byl jië konec souboru

                                          ;* naáten° bloku dat ze souboru
         mov       ah,3fh                   ; funkce áten° ze souboru
         mov       bx,ds:[ZdrojId]          ; identifik†tor zdrojovÇho souboru
         mov       cx,2000h                 ; velikost vstupn°ho bufferu
         xor       dx,dx                    ; buffer k naáten° souboru
         mov       ds:[SrcUkaz],dx          ; nastaven° ukazatele vstup. bufferu

         push      ds
         mov       ds,ds:[SrcBuf]           ; buffer vstupn°ho souboru
         int       21h                      ; naáten° bloku ze vstup. souboru
         pop       ds

                                          ;* kontrola spr†vnosti operace
         jc        InpCh1                   ; chyba áten°
         mov       ds:[SrcNum],ax           ; poáet naátenòch bajtñ
         or        ax,ax                    ; naáten nàjakò bajt ?
         jnz       InpCh1                   ; bylo nàco naáteno
         inc       byte ptr ds:[SrcEnd]     ; p©°znak konce souboru
InpCh4:  stc                                ; p©°znak konce souboru

InpCh1:  pop       dx
         pop       cx
         pop       bx
         pop       ax
         jc        InpCh3                   ; chyba - nejsou dal®° data

; ------ naáten° znaku z bufferu vstupn°ho souboru

InpCh2:  push      si
         push      ds
         cld                                ; smàr nahoru
         mov       si,ds:[SrcUkaz]          ; ukazatel vstupn°ho bufferu
         mov       ds,ds:[SrcBuf]           ; buffer vstupn°ho souboru
         lodsb                              ; naáten° znak z bufferu
         pop       ds
         pop       si
         inc       word ptr ds:[SrcUkaz]    ; zvò®en° ukazatele vstup. bufferu
         dec       word ptr ds:[SrcNum]     ; sn°ëen° á°taáe znakñ v bufferu

; ------ obsluha ukazatele zaá†tkñ ©†dkñ v souboru

         add       word ptr ds:[UkazCh],1   ; zvò®en° ukazatele znakñ v souboru
         adc       word ptr ds:[UkazCh+2],0 ; p©enos do vy®®°ho slova
         cmp       al,13                    ; je CR ?
         je        InpCh21                  ; je CR
         cmp       al,10                    ; je LF ?
         jne       InpCh22                  ; nen° LF
         inc       word ptr ds:[CitRad]     ; zvò®en° á°taáe ©†dkñ souboru
InpCh21: push      ax
         mov       ax,word ptr ds:[UkazCh]  ; ukazatel v souboru - nië®° slovo
         mov       word ptr ds:[UkazRad],ax ; ukazatel ©†dku - nië®° slovo
         mov       ax,word ptr ds:[UkazCh+2] ; ukazatel v souboru - vy®®° slovo
         mov       word ptr ds:[UkazRad+2],ax ; ukazatel ©†dku - vy®®° slovo
         pop       ax

InpCh22: clc                                ; p©°znak operace OK

InpCh3:  ret

; -----------------------------------------------------------------------------
;        N†vrat znaku do p©echodnÇho bufferu
; -----------------------------------------------------------------------------

PUBLIC   RetCh

RetCh:   pushf
         push      si
         mov       si,ds:[BuffChU]          ; poáet bajtñ v p©echodnÇm bufferu
         cmp       si,64                    ; p©ekroáen konec bufferu ?
         jae       RetCh2                   ; p©eteáen° bufferu
         mov       ds:[BuffCh+si],al        ; uloëen° znaku do bufferu
         inc       si                       ; zvò®en° ukazatele v bufferu
         mov       ds:[BuffChU],si          ; novò poáet bajtñ v bufferu
RetCh2:  pop       si
         popf
         ret


; *****************************************************************************
;
;                      Z†pis do vòstupn°ho bufferu
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;        Zvò®en° ukazatele v buferu
; -----------------------------------------------------------------------------

PUBLIC   OutInc
OutInc:  pushf
         push      ds
         cmp       word ptr ds:[ProgNum],-1 ; poáet bajtñ ve vòstupn°m bufferu
         je        OutInc2                  ; je p©eteáen° bufferu
         inc       word ptr ds:[ProgNum]    ; zvò®en° ukazatele dat
         mov       ds,ds:[ProgSeg]          ; segment vòstupn°ho bufferu
         inc       word ptr ds:[0]          ; zvò®en° ukazatele dÇlky
OutInc2: pop       ds
         popf
         ret

; -----------------------------------------------------------------------------
;        Zru®en° bajtu uloëenÇho do buferu
; -----------------------------------------------------------------------------

PUBLIC   OutRet
OutRet:  pushf
         push      ds
         cmp       word ptr ds:[ProgNum],0  ; poáet bajtñ ve vòstupn°m bufferu
         je        OutRet2                  ; je podteáen° bufferu
         dec       word ptr ds:[ProgNum]    ; sn°ëen° ukazatele dat
         mov       ds,ds:[ProgSeg]          ; segment vòstupn°ho bufferu
         dec       word ptr ds:[0]          ; sn°ëen° ukazatele dÇlky
OutRet2: pop       ds
         popf
         ret

; -----------------------------------------------------------------------------
;        Z†pis slova AX do vòstupn°ho bufferu
; -----------------------------------------------------------------------------

PUBLIC   OutWrd
OutWrd:  push      ax
         call      OutCh
         mov       al,ah
         call      OutCh
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        Z†pis bajtu do vòstupn°ho bufferu
; -----------------------------------------------------------------------------

PUBLIC   OutCh

OutCh:   push      di
         push      es
         cld                                ; smàr nahoru
         mov       es,ds:[ProgSeg]          ; segment vòstupn°ho bufferu
         mov       di,ds:[ProgNum]          ; poáet bajtñ ve vòstupn°m bufferu
         stosb                              ; uloëen° bajtu do vòstup. bufferu
         or        di,di                    ; je p©eteáen° bufferu ?
         stc                                ; p©ednastaven° p©°znaku chyby
         jz        OutCh2                   ; je p©eteáen° bufferu
         mov       ds:[ProgNum],di          ; jinak novò poáet bajtñ v bufferu
         inc       word ptr es:[0]          ; zvò®en° ukazatele dÇlky
         clc                                ; p©°znak operace OK
OutCh2:  pop       es
         pop       di
         ret

; -----------------------------------------------------------------------------
;        Z†pis vòstupn°ho bufferu do souboru (CX=poáet bajtñ)
; -----------------------------------------------------------------------------

PUBLIC   WritProg
WritProg:push      ds
         mov       bx,ds:[CilId]            ; identifik†tor vòstupn°ho souboru
         mov       ds,ds:[ProgSeg]          ; segment s interpreterem
         xor       dx,dx                    ; poá†teán° offset
         add       cx,15                    ; zaokrouhlen° na odstavec nahoru
         and       cx,not 15                ; zarovn†n° na odstavec
         mov       ax,cx                    ; poáet bajtñ k z†pisu
         jcxz      WritPrg3                 ; nen° nic k z†pisu
         mov       ah,40h                   ; funkce z†pisu do souboru
         int       21h                      ; z†pis interpreteru do souboru
WritPrg3:pop       ds
         mov       dx,offset WritTxt        ; text - chyba z†pisu
         jc        WritPrg1                 ; chyba z†pisu do vòstupn°ho souboru
         cmp       ax,cx                    ; zaps†no v®e ?
         je        WritPrg2                 ; nen° chyba - OK

; ------ chyba z†pisu do vòstupn°ho souboru nebo jin† chyba

PUBLIC   WritPrg1
WritPrg1:
         jmp       Navrat0                  ; n†vrat s chybou

WritPrg2:ret

; *****************************************************************************
;
;                     Obsluha chybovòch hl†®en°
;
; *****************************************************************************


; -----------------------------------------------------------------------------
;        Zobrazen° chybovÇho hl†®en°
; -----------------------------------------------------------------------------

PUBLIC   DispErr
DispErr:

; ------ £schova registrñ

         pushf
         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      es

         push      ds
         pop       es
         inc       word ptr ds:[CitChyb]    ; zvò®en° á°taáe chyb

; ------ zobrazen° á°sla ©†dku s chybou

         push      dx                       ; £schova adresy textu hl†®en°
         mov       al,"["                   ; lev† z†vorka
         call      DispCh                   ; zobrazen° znaku levÇ z†vorky
         mov       ax,ds:[ErrNRad]          ; á°slo ©†dku
         call      DispNum                  ; zobrazen° á°sla aktu†ln°ho ©†dku
         mov       al,"]"                   ; prav† z†vorka
         call      DispCh                   ; zobrazen° pravÇ z†vorky
         mov       al," "                   ; oddàlovac° mezera za á°slem ©†dku
         call      DispCh                   ; zobrazen° oddàlovac° mezery
         pop       di                       ; chybovÇ hl†®en°

; ------ zobrazen° textu chybovÇho hl†®en°

DispErr1:mov       al,ds:[di]
         inc       di
         or        al,al                    ; konec texty ?
         jz        DispErr3                 ; konec textu
         cmp       al,"%"                   ; parametr ?
         jne       DispErr2                 ; nen° parametr

         mov       ch,0
         mov       dx,offset BufIdent       ; buffer identifik†toru
         mov       cl,ds:[DelIdent]         ; dÇlka identifik†toru
         call      DispTxt                  ; zobrazen° textu identifik†toru
         jmp       short DispErr1           ; dal®° znak

DispErr2:call      DispCh                   ; zobrazen° znaku textu
         jmp       short DispErr1
DispErr3:mov       al,":"                   ; oddàlovaá hl†®en°
         call      DispCh                   ; zobrazen° znaku ":"
         mov       al," "                   ; oddàlovac° mezera textu
         call      DispCh                   ; zobrazen° oddàlovac° mezery

; ------ £schova aktu†ln° pozice v souboru

         mov       ax,4201h                 ; funkce p©esunu od souáasnÇ pozice
         mov       bx,ds:[ZdrojId]          ; identifik†tor zdrojovÇho souboru
         xor       cx,cx
         xor       dx,dx
         int       21h                      ; poskytnut° aktu†ln°ho ukazatele
         push      ax                       ; ukazatel - nië®° slovo
         push      dx                       ; ukazatel - vy®®° slovo

; ------ nastaven° pozice ©†dku s chybou

         mov       ax,4200h                 ; funkce nastaven° od zaá†tku soub.
         mov       dx,word ptr ds:[ErrARad] ; ukazatel ©†dku - nië®° slovo
         mov       cx,word ptr ds:[ErrARad+2] ; ukazatel ©†dku - vy®®° slovo
         int       21h                      ; nastaven° ukazatele na ©†dek

; ------ naáten° ©†dku do bufferu

         mov       ah,3fh                   ; funkce áten° ze souboru
         mov       dx,offset ErrRad         ; buffer pro chybovò ©†dek
         mov       cx,255                   ; maxim†ln° poáet znakñ
         int       21h                      ; naáten° ©†dku ze souboru
         xor       ah,ah                    ; AH <- 0 poji®tàn°
         mov       di,ax                    ; £schova poátu naátenòch znakñ

; ------ n†vrat pñvodn°ho ukazatele v souboru

         mov       ax,4200h                 ; funkce nastaven° ukazatele
         pop       cx                       ; ukazatel - vy®®° slovo
         pop       dx                       ; ukazatel - nië®° slovo
         int       21h                      ; nastaven° pñvodn°ho ukazatele

; ------ nalezen° konce ©†dku v bufferu

         mov       cx,di                    ; poáet znakñ v bufferu
         push      cx
         mov       al,13                    ; hledanò znak - CR
         mov       di,offset ErrRad         ; buffer s chybovòm ©†dkem
         mov       dx,di                    ; buffer s chybovòm ©†dkem
         repne     scasb                    ; nalezen° znaku CR
         mov       byte ptr ds:[di-1],0     ; n†hrada bajtem 0 (konec textu)
         pop       cx                       ; poáet znakñ v bufferu

; ------ nalezen° zaá†tku textu

         jcxz      DispErr7                 ; nen° dal®° znak
DispErr5:mov       di,dx                    ; ukazatel adresy v bufferu
         cmp       byte ptr ds:[di]," "     ; je oddàlovaë ?
         ja        DispErr7                 ; nen° oddàlovaá - zobrazen° textu
         inc       dx                       ; zvò®en° adresy
         loop      DispErr5                 ; dal®° znak

; ------ zobrazen° chybovÇho ©†dku

DispErr7:mov       si,dx                    ; text k zobrazen°
         cld
DispErr6:lodsb
         or        al,al                    ; je konec textu ?
         jz        DispErr4                 ; je konec textu
         call      DispCh                   ; zobrazen° textu ©†dku
         jmp       short DispErr6           ; dal®° znak k zobrazen°

; ------ od©†dkov†n° textu

DispErr4:mov       al,13
         call      DispCh                   ; zobrazen° CR
         mov       al,10
         call      DispCh                   ; zobrazen° LF

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         popf
         ret

; -----------------------------------------------------------------------------
;        Zobrazen° á°sla AX
; -----------------------------------------------------------------------------

PUBLIC   DispNum

; ------ p©°prava registrñ

DispNum: push      ax
         push      bx
         push      cx
         push      dx
         mov       bx,10                    ; á°seln† soustava
         xor       cx,cx                    ; á°taá á°slic v z†sobn°ku

; ------ vòpoáet jednÇ á°slice

DispNm1: xor       dx,dx                    ; DX <- 0 vy®®° slovo á°sla
         div       bx                       ; vòpoáet jednÇ á°slice
         add       dl,"0"                   ; korekce na znak ASCII
         push      dx                       ; uloëen° znaku do z†sobn°ku
         inc       cx                       ; zvò®en° á°taáe znakñ
         or        ax,ax                    ; zbylo nàjakÇ á°slo ?
         jnz       DispNm1                  ; je dal®° á°slo

; ------ zobrazen° á°sla

DispNm2: pop       ax                       ; znak k zobrazen°
         call      DispCh                   ; zobrazen° á°slice
         loop      DispNm2                  ; zobrazen° dal®° á°slice

; ------ n†vrat registrñ

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        Zobrazen° textu DS:DX o dÇlce CX znakñ
; -----------------------------------------------------------------------------

PUBLIC   DispTxt
DispTxt: push      ax
         push      cx
         push      si
         mov       si,dx                    ; adresa textu
         jcxz      DispTxt2                 ; nen° ë†dnò znak
         cld
DispTxt1:lodsb
         call      DispCh                   ; zobrazen° znaku
         loop      DispTxt1                 ; dal®° znak
DispTxt2:pop       si
         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        Zobrazen° znaku DOS
; -----------------------------------------------------------------------------

PUBLIC   DispCh
DispCh:  push      ax
         push      dx
         mov       dl,al                    ; znak k zobrazen°
         mov       ah,2                     ; funkce zobrazen° znaku
         int       21h                      ; zobrazen° znaku
         pop       dx
         pop       ax
         ret




code     ends

; -----------------------------------------------------------------------------
;        Data
; -----------------------------------------------------------------------------

Data     SEGMENT

TabOper  label     byte                   ;* tabulka oper†torñ

         db        1,'('                    ; 1
         db        1,')'                    ; 2
         db        1,'^'                    ; 3
         db        1,'*'                    ; 4
         db        1,'/'                    ; 5
         db        3,'MOD'                  ; 6
         db        2,'<<'                   ; 7
         db        2,'>>'                   ; 8
         db        1,'+'                    ; 9
         db        1,'-'                    ; 10
         db        1,'='                    ; 11
         db        2,'<>'                   ; 12
         db        1,'<'                    ; 13
         db        1,'>'                    ; 14
         db        2,'<='                   ; 15
         db        2,'>='                   ; 16
         db        3,'NOT'                  ; 17
         db        3,'AND'                  ; 18
         db        2,'OR'                   ; 19
         db        3,'XOR'                  ; 20
         db        0


; Za kaëdòm p©°kazem mus° bòt uveden znak st©edn°ku ";" (= konec p©°kazu).
; Vnit©n° oddàlovaáe á†st° konstrukc°: THEN, ELSE, ENDIF, DO uvnit© FOR, ENDDO,
;                                      IN, OUT, ENDCASE, ENDPROC;
; - za p©°kazem p©ed vnit©n°m oddàlovaáem se nep°®e st©edn°k.
;
; znak ? = speci†ln° hodnota 8000h=-32768, u nàkteròch p©°kazñ zpñsob°, ëe
;          se tato hodnota nenastav° (nap©. definice jen nàkteròch palet)

; -----------------------------------------------------------------------------
; Podm°nànÇ vàtven°:
;     IF c THEN [s1; s2; ... sn] [ELSE [s1; s2; ... sn]] ENDIF;
;
; V°cen†sobnÇ vàtven°:
;     CASE e
;     IN [a1..a2 | a]: [s1; s2; ... sn]
;     .....
;     [OUT [s1; s2; ... sn]
;     ENDCASE;
;
; Cyklus:
;    [FOR v [:= e1] [TO e2] [STEP e3]] DO
;           [s1; s2; ... sn;]
;    [WHILE c;]
;           [s1; s2; ... sn;]
;    [WHILE c;]
;           .....
;           [s1; s2; ... sn]
;    ENDDO;
;
; Definice procedury:
;    PROC p;
;           [s1; s2; ... sn;]
;           [RETURN[(e)];]
;           ....
;           [s1; s2; ... sn]
;    ENDPROC;
;
; PouëitÇ symboly:
;    a1, a2, a - á°selnÇ konstanty
;    c - podm°nka
;    e - vòraz
;    s - p©°kaz
;    v - promànn†
;    p - jmÇno procedury
; -----------------------------------------------------------------------------

TabKey   label     byte                   ;* tabulka kl°áovòch slov
                                            ; FF: uëivatelsk† procedura

                                            ; FB: naplnàn° WORD s indexem
                                            ; FA: naplnàn° BYTE s indexem
                                            ; F9: naplnàn° WORD
                                            ; F8: naplnàn° BYTE


                                          ;* povoleno jen na konci programu

         db        4,'LINK'                 ;  0: p©ilinkov†n° objektu
         dw        offset XLink

                                          ;* povoleno kdykoliv

         db        7,'include'              ;  (1: vno©en° vstupn°ho souboru)
         dw        offset XInclud

                                          ;* povoleno jen na zaá†tku programu

         db        4,'BYTE'                 ;  2: definice promànnÇ bajtñ
         dw        offset XByte
         db        4,'WORD'                 ;  3: definice promànnÇ slov
         dw        offset XWord
         db        6,'string'               ;  (4: definice ©etàzcovÇ promànnÇ)
         dw        offset XString

                                          ;* povoleno na zaá†tku i uvnit©

         db        4,'PROC'                 ;  5: definice procedury
         dw        offset XProc

                                          ;* povoleno uvnit© procedur

         db        7,'ENDPROC'              ;  6: konec definice procedury
         dw        offset XEndp
         db        6,'RETURN'               ;  7: n†vrat z procedury
         dw        offset XRet
         db        4,'exec'                 ;  8: proveden° p©°kazu DOS
         dw        offset XExec

         db        2,'IF'                   ;  9: identifik†tor podm°nky
         dw        offset XIf
         db        4,'THEN'                 ; 10: zaá†tek p©°kazñ - podm°nka splnàna
         dw        offset XThen
         db        4,'ELSE'                 ; 11: zaá†tek p©°kazñ - podm. nesplnàna
         dw        offset XElse
         db        5,'ENDIF'                ; 12: konec podm°nky IF
         dw        offset XEndif

         db        3,'for'                  ; 13: cyklus s parametrem
         dw        offset XFor
         db        2,'to'                   ; 14: podm°nka konce cyklu
         dw        offset XTo
         db        4,'step'                 ; 15: krok cyklu s parametrem
         dw        offset XStep

         db        2,'DO'                   ; 16: cyklus s podm°nkou
         dw        offset XDo
         db        2,'ON'                   ; 17: podm°nka cyklu
         dw        offset XOn
         db        5,'ENDDO'                ; 18: konec cyklu
         dw        offset XEnddo

         db        4,'EXIT'                 ; 19: p©edáasnÇ ukonáen° cyklu
         dw        offset XExit

         db        4,'CASE'                 ; 20: v°cen†sobnÇ vàtven°
         dw        offset XCase
         db        2,'IN'                   ; 21: podm°nka intervalu nebo hodnoty
         dw        offset XIn
         db        3,'OUT'                  ; 22: podm°nka nesplnàn° ë†dnÇ hodnoty
         dw        offset XOut
         db        7,'ENDCASE'              ; 23: konec vàtven° CASE
         dw        offset XEndCase

                                          ;* povoleno jako funkce
         db        3,'val'                  ; 24: p©evod ©etàzce na á°slo
         dw        offset XVal
         db        3,'str'                  ; 25: p©evod á°sla na ©etàzec
         dw        offset XStr
         db        3,'len'                  ; 26: zji®tàn° dÇlky ©etàzce
         dw        offset XLen
         db        4,'CARD'                 ; 27: test grafickÇ karty
         dw        offset XCard
         db        5,'VIDEO'                ; 28: nastaven° videom¢du
         dw        offset XVideo
         db        8,'getvideo'             ; 29: zji®tàn° videom¢du
         dw        offset XGVideo
         db        4,'MODE'                 ; 30: nastaven° m¢du displeje
         dw        offset XMode
         db        4,'PAGE'                 ; 31: nastaven° str†nek displeje
         dw        offset XPage
         db        5,'XPAGE'                ; 32: p©epnut° str†nek displeje
         dw        offset XXPage
         db        6,'WINDOW'               ; 33: definice vòstupn°ho okna
         dw        offset XWind
         db        7,'PALETTE'              ; 34: definice palet displeje
         dw        offset XPal
         db        6,'XCOLOR'               ; 35: z†màna barvy v oknà
         dw        offset XXCol
         db        7,'SETCURS'              ; 36: nastaven° pozice kurzoru
         dw        offset XSetCur
         db        7,'CURSOFF'              ; 37: vypnut° kurzoru
         dw        offset XCurOff
         db        4,'LOAD'                 ; 38: naáten° objektu ze souboru
         dw        offset XLoad
         db        3,'PIC'                  ; 39: zobrazen° objektu
         dw        offset XObj
         db        6,'UNLOAD'               ; 40: zru®en° objektu z pamàti
         dw        offset XUnld
         db        4,'TEXT'                 ; 41: zobrazen° textu
         dw        offset XText
         db        5,'POINT'                ; 42: zobrazen° bodu
         dw        offset XPoint
         db        4,'LINE'                 ; 43: zobrazen° á†ry
         dw        offset XLine
         db        5,'RLINE'                ; 44: zobrazen° á†ry relativnà
         dw        offset XRline
         db        3,'BOX'                  ; 45: zobrazen° opbdÇln°ku
         dw        offset XBox
         db        4,'FBOX'                 ; 46: zobrazen° plnÇho obdÇln°ku
         dw        offset XFBox
         db        4,'CIRC'                 ; 47: zobrazen° kruënice
         dw        offset XCirc
         db        5,'FCIRC'                ; 48: zobrazen° plnÇ kruënice
         dw        offset XFCirc
         db        5,'PRESS'                ; 49: test uráitÇ kl†vesy na stisk
         dw        offset XPress
         db        7,'TESTKEY'              ; 50: test p©ipravenÇ kl†vesy
         dw        offset XTstKey
         db        6,'GETKEY'               ; 51: vstup znaku z kl†vesnice
         dw        offset XGtKey
         db        7,'STATKEY'              ; 52: stavovÇ slovo kl†vesnice
         dw        offset XStatKey
         db        5,'INPUT'                ; 53: vstup textu
         dw        offset XInp
         db        5,'SOUND'                ; 54: ovl†d†n° zvukovÇho gener†toru
         dw        offset XSound
         db        3,'TON'                  ; 55: zahr†n° t¢nu danÇ frekvence
         dw        offset XTon
         db        5,'MUSIC'                ; 56: zahr†n° melodie
         dw        offset XMusic
         db        9,'MUSICSTOP'            ; 57: zastaven° hry melodie
         dw        offset XMStop
         db        8,'MUSICGET'             ; 58: poskytnut° ukazatele melodie
         dw        offset XMusGet
         db        4,'WAIT'                 ; 59: áek†n° po danou dobu
         dw        offset XWait
         db        4,'TIME'                 ; 60: poskytnut° systÇmovÇho áasu
         dw        offset XTime
         db        4,'DATE'                 ; 61: poskytnut° systÇmovÇho data
         dw        offset XDate
         db        6,'XMOUSE'               ; 62: poskytnut° pozice my®i
         dw        offset XXMous
         db        6,'YMOUSE'               ; 63: poskytnut° linky my®i
         dw        offset XYMous
         db        8,'GETMOUSE'             ; 64: poskytnut° tlaá°tek my®i
         dw        offset XKMous
         db        7,'MOUSEON'              ; 65: zapnut° kurzoru my®i
         dw        offset XMon
         db        8,'MOUSEOFF'             ; 66: vypnut° kurzoru my®i
         dw        offset XMoff
         db        8,'CURMOUSE'             ; 67: definice kurzoru my®i
         dw        offset XDefm
         db        8,'WINMOUSE'             ; 68: definice okna my®i
         dw        offset XWinm
         db        3,'RND'                  ; 69: gener†tor n†hodnÇho á°sla
         dw        offset XRnd
         db        8,'REGISTER'             ; 70: nastaven° registru CRT
         dw        offset XReg
         db        4,'HSYN'                 ; 71: horizont†ln° synchronizace
         dw        offset XHSyn
         db        4,'VSYN'                 ; 72: vertik†ln° synchronizace
         dw        offset XVSyn
         db        7,'PATTERN'              ; 73: vzorek vòplnà
         dw        offset XPatt
         db        5,'STICK'                ; 74: joystickovò vstup
         dw        offset XStick
         db        4,'TRIG'                 ; 75: aktivaán° tlaá°tko joysticku
         dw        offset XTrig
         db        3,'SIN'                  ; 76: funkce SINUS
         dw        offset XSin
         db        3,'COS'                  ; 77: funkce COSINUS
         dw        offset XCos
         db        3,'TAN'                  ; 78: funkce Tangens
         dw        offset XTan
         db        3,'ABS'                  ; 79: absolutn° hodnota
         dw        offset XAbs
         db        3,'ATN'                  ; 80: ArcTangent
         dw        offset XAtn
         db        3,'SQR'                  ; 81: odmocnina
         dw        offset XSqr

         db        0                        ; identifikace konce tabulky

; ------ £vodn° a z†kladn° chybov† hl†®en°

UvTxt    db        'ANIM V 1.00 - graficka animace;  (c) Miroslav Nemecek',13,10,'$'

MemTxt   db        'Chyba - nedostatek pameti !',13,10,'$'
Mem1Txt  db        'Chyba - preteceni tabulky symbolu !',13,10,'$'
Mem2Txt  db        'Chyba - preteceni datoveho modulu !',13,10,'$'
Mem3Txt  db        'Chyba - preteceni programoveho modulu !',13,10,'$'
ZdrojTxt db        'Zadejte specifikaci zdrojoveho souboru !',13,10,'$'
FndTxt   db        'Chybne zadani zdrojoveho souboru !',13,10,'$'
CilTxt   db        'Vystupni soubor .EXE nelze vytvorit'
Err0Txt  db        ' !'
UvTxt1   db        13,10,'$'
WritTxt  db        'Chyba zapisu do vystupniho souboru !',13,10,'$'
ErrMain  db        'Nebyla definovana procedura MAIN',13,10,'$'
ErrClos  db        'Procedura neni uzavrena !',13,10,'$'

FreeTxt  db        13,10,'Volna pamet: program $'
FreeTxt1 db        ', data $'
FreeTxt2 db        ', symboly $'
FreeTxt3 db        13,10,'$'

ProgLev  db        0                        ; £rove§ zpracov†n° programu
                                            ;  0=deklaraán° á†st promànnòch
                                            ;  1=programov† á†st - uzav©eno PROC
                                            ;  2=programov† á†st - otev©eno PROC
                                            ;  3=konec programu - LINK
ParMain  db        0                        ; p©°znak, ëe byla hlavn° porcedura
LastIdn  db        0                        ; posledn° identifik†tor

SegPSP   dw        0                        ; segment PSP

; ------ obsluha chyb p©ekladu

Err000   db        'Pocet chyb : $'

Err001   db        'Neplatne symbolicke jmeno',0
Err002   db        'Jmeno % nedefinovano',0
Err003   db        '% smi byt jen v deklaracni casti',0
Err004   db        'Chybny zapis pro naplneni promenne',0
Err005   db        'Chybny zapis vyrazu',0
Err007   db        'Za prikazem LINK nesmi nasledovat program',0
Err008   db        '% nesmi byt uvnitr procedury',0
Err009   db        'Vicenasobne pouziti jmena %',0

Err010   db        'Procedura neni uzavrena',0
Err011   db        '% musi byt uvedeno v procedure',0
Err012   db        'Neplatne jmeno objektu',0
Err013   db        'Jmeno % je rezervovano',0
Err014   db        'Chybne zadani dimenze promenne %',0
Err015   db        'Chyba syntaxe prikazu LINK',0
Err016   db        'Chybne jmeno souboru',0
Err017   db        'Chybne zadani jmena programu ke startu',0
Err018   db        'Neplatne jmeno procedury',0
Err019   db        '% nesmi byt v deklaracni casti',0
Err01a   db        'Za prikazem chybi strednik',0
Err01b   db        'Chybny argument prikazu',0
Err01c   db        'Prilis mnoho udaju',0

Err020   db        'Podminka IF neuzavrena',0
Err021   db        'Za IF musi nasledovat THEN',0
Err022   db        '% bez podminky IF',0
Err023   db        'THEN musi nasledovat za podminkou IF',0
Err025   db        '% nelze uvest vicenasobne',0

Err030   db        'Cyklus DO neuzavren',0
Err031   db        '% bez zacatku cyklu DO',0
Err032   db        'Za ON musi nasledovat EXIT',0
Err033   db        'EXIT smi byt pouze za ON',0

Err040   db        'Vicenasobne vetveni CASE neuzavreno',0
Err041   db        '% bez CASE',0
Err043   db        '% nelze uvest po OUT',0
Err044   db        'Vetev % jiz byla pouzita',0
Err045   db        '% bez CASE',0
Err046   db        'Za CASE musi nasledovat IN',0
Err047   db        'Chybne meze pro IN',0

ErrARad  dd        0                        ; £schova ukazatele chybovÇho ©†dku
ErrNRad  dw        0                        ; £schova á°sla chybovÇho ©†dku
ErrRad   db        256 dup(0)               ; text chybovÇho ©†dku
RetClose dw        0                        ; £schova n†vrat. adresy uzav©en°
RetDisp  dw        0                        ; £schova n†vrat. adresy zobrazen°
RetComp  dw        0                        ; n†vratov† adresa do kompil†toru
RetPush  dw        0                        ; n†vratov† adresa z £schovy reg.
RetProc  dw        0                        ; n†vratov† adresa z £schovy PROC
CitChyb  dw        0                        ; á°taá chyb p©ip©ekladu

; ------ ukazatele pro spojov†n° modulñ LINK

LinkId   dw        0                        ; identifik†tor zdrojovÇho modulu

; ------ parametry pro gener†tor melodie

Oktava   dw        0                        ; okt†va
Krizky   dw        0                        ; á°taá k©°ëkñ
DelTon   db        0                        ; dÇlka t¢nu

; ------ buffer n†và®t° a identifik†torñ

BufOper  db        4 dup(0)                 ; buffer oper†toru

DelIdent db        0                        ; dÇlka n†và®t° (dodrëet po©ad° !)
BufIdent db        64 dup(0)                ; buffer n†và®t°

FlagBuf  dw        0                        ; segment s tabulkou n†và®t°
FlagNum  dw        0                        ; poáet bajtñ v tabulce n†và®t°

; ------ vòstupn° buffer (velikost 64 KB)

ProgSeg  dw        SEG Interp               ; segment s programem
ProgNum  dw        2                        ; poáet bajtñ programu



SizProg  dw        0                        ; poáet bajtñ programu
SizDat   dw        0                        ; poáet bajtñ v dat. segmentu

; ------ vstupn° buffer (velikost 2000h bajtñ)

SrcBuf   dw        0                        ; segment vstupn°ho bufferu
SrcUkaz  dw        0                        ; ukazatel ve vstupn°m bufferu
SrcNum   dw        0                        ; poáet zbylòch znakñ vstup. bufferu
UkazCh   dd        0                        ; ukazatel znakñ v souboru
UkazRad  dd        0                        ; ukazatel zaá†tku ©†dku v souboru
CitRad   dw        1                        ; á°taá ©†dkñ v souboru
SrcEnd   db        0                        ; 1=p©°znak konce souboru

BuffChU  dw        0                        ; poáet bajtñ v p©echodnÇm bufferu
BuffCh   db        64 dup(0)                ; p©echodnò buffer

; ------ obsluha souborñ

SoubLinn db        0                        ; poáet bajtñ jmÇna souboru
SoubLink db        128 dup(0)               ; pracovn° soubor

PripAni  db        '.ANI',0                 ; p©°pona animaán°ho zdroj. souboru
PripExe  db        '.EXE',0                 ; p©°pona vòstupn°ho souboru
Soubor   db        128 dup(0)               ; buffer k uloëen° jmÇna souboru

CilSize  dd        0                        ; velikost vòstupn°ho souboru
ZdrojId  dw        0                        ; identifik†tor zdrojovÇho souboru
CilId    dw        0                        ; identifik†tor c°lovÇho souboru


Konec    label     byte                     ; ukazatel konce programu

Data     ENDS


; *****************************************************************************
;
;                  P©echodnò z†sobn°k pro kompil†tor
;
; *****************************************************************************

Stack    SEGMENT   stack para

         dw        20h dup(0)               ; mus° bòt nàco definovanÇ !

Stack    ENDS


; *****************************************************************************
;
;        Segment s interpreterem programu (p©°poj° se p©i kompilaci)
;
; *****************************************************************************

Interp   SEGMENT   para

Interp   ENDS

         END       Animc

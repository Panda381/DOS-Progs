
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                                 HD-HESLO
;                        uzamyk†n° poá°taáe heslem
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

MAXHESLO EQU       60                       ; maxim†ln° dÇlka hesla
KODBYTE  EQU       63h                      ; k¢dovac° bajt
HOTOFF   EQU       21A9h                    ; k¢d pro p©echodnÇ vypnut° hesla

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ p©°prava adresy modulu HESLO.SYS

Start:   mov       ax,offset Code:HesloBeg  ; offset zaá†tku hesla
         mov       cl,4
         shr       ax,cl
         mov       bx,cs
         add       ax,bx                    ; segment hesla
         mov       ds:[HesloSeg],ax         ; segment hesla

; ------ zobrazen° £vodn°ho textu a vòzvy k zad†n° hesla

         mov       si,offset ZadTxt         ; text vòzvy k zad†n°
         call      HOutTxt                  ; zobrazen° textu vòzvy

; ------ zad†n° textu hesla

         mov       si,offset Code:BufHeslo  ; buffer hesla v modulu HESLO.SYS
         call      HInpTxt                  ; zad†n° textu hesla
         jnc       Start2                   ; zad†n° OK

; ------ p©eru®en° programu

HPrerus: call      HMazTxt                  ; vymaz†n° ©†dku
HPrerus2:mov       ax,4c01h                 ; n†vrat - nen° nic zad†no
         int       21h

; ------ zak¢dov†n° hesla (adresa SI, dÇlka CX)

Start2:  jcxz      HPrerus                  ; nen° nic zad†no - konec
         mov       ds:[Code:Delka],cx       ; dÇlka hesla
Start22: not       byte ptr ds:[si]         ; zak¢dov†n° znaku hesla
         inc       si
         loop      Start22

; ------ dotaz, zda m† bòt heslo p©i startu

         mov       si,offset StartTxt       ; dotaz na heslo p©i startu
         call      HMenu                    ; volba hesla p©i startu
         jc        HPrerus2                 ; p©eru®en° operace
         jnz       Start3                   ; nen° heslo p©i startu
         or        byte ptr ds:[Code:ParInt],2 ; p©°znak hesla p©i startu

Start3:
;; ------ dotaz, zda se m† disk parkovat p©ed zad†n°m hesla
;         mov       si,offset ParkTxt        ; dotaz na parkov†n° disku
;         call      HMenu                    ; volba parkov†n° disku
;         jc        HPrerus2                 ; p©eru®en° operace
;         jnz       Start4                   ; nem† se parkovat p©i startu
;         or        byte ptr ds:[Code:ParInt],4 ; p©°znak parkov†n° p©ed heslem

; ------ zad†n° áasu pro automatickÇ uzamknut°

Start4:  mov       si,offset TimerTxt       ; dotaz na dobu
         call      HOutTxt                  ; zobrazen° vòzvy k zad†n° áasu
         mov       si,offset InpBuff        ; vstupn° buffer
         call      HInpTxt                  ; zad†n° áasu
         jc        HPrerus                  ; p©eru®en° operace
         call      HMazTxt                  ; vymaz†n° ©†dku

; ------ naáten° zadanÇho £daje áasu

         xor       bx,bx                    ; BX <- st©adaá á°sla
         jcxz      Start54                  ; nen° ë†dnò znak
         cld
Start5:  lodsb                              ; naáten° znaku
         sub       al,"0"
         jb        Start52                  ; nen° á°slice
         cmp       al,10
         jae       Start52                  ; nen° á°slice
         mov       ah,0
         xchg      ax,bx                    ; BX <- nov† á°slice, AX <- st©adaá
         mov       dx,10
         mul       dx                       ; vyn†soben° st©adaáe * 10
         add       bx,ax                    ; p©iáten° novÇ á°slice
Start52: loop      Start5                   ; dal®° á°slice

; ------ uloëen° £daje áasu pro uzamknut°

Start54: cmp       bx,60                    ; maxim†ln° poáet minut
         jbe       Start56                  ; poáet minut je OK
         mov       bx,60                    ; omezen° doby
Start56: mov       ax,1092                  ; poáet impulsñ za minutu
         mul       bx                       ; p©epoáet na impulsy
         mov       ds:[Code:LockTime],ax    ; zadan† doba pro uzamknut°
         mov       ds:[Code:LockCit],ax     ; á°taá pro uzamknut°
         or        ax,ax                    ; je doba pro uzamknut° ?
         jz        Start58                  ; nen° automatickÇ uzamknut°
         or        byte ptr ds:[Code:ParInt],8 ; je automatickÇ uzamyk†n°

; ------ zad†n° horkÇ kl†vesy

Start58: mov       si,offset HotTxt         ; text "Stisknete horkou ..."
         call      HOutTxt                  ; zobrazen° textu vòzvy

; ------ instalace obsluhy INT 09h

         mov       ax,3509h
         int       21h                      ; poskytnut° adresy INT 09h
         mov       word ptr ds:[HOld09],bx  ; £schova adresy INT 09h
         mov       word ptr ds:[HOld09+2],es
         mov       dx,offset HInt09         ; obsluha INT 09h
         mov       ax,2509h
         int       21h                      ; instalace obsluhy INT 09h

; ------ p©echodnÇ vypnut° p©°padnÇho rezidentn°ho hesla

         xor       ax,ax
         mov       es,ax
         push      word ptr es:[472h]       ; £schova p©°znaku RESET
         mov       word ptr es:[472h],HOTOFF ; p©echodnÇ vypnut° funkce z†mku

; ------ áek†n° na zad†n° horkÇ kl†vesy

         sti
Start7:  test      byte ptr ds:[HParInt],1  ; byl stisk kl†vesy ?
         jz        Start7                   ; áek†n° na zad†n° kl†vesy
         pop       word ptr ds:[472h]       ; n†vrat p©°znaku RESET
         call      HMazTxt                  ; vymaz†n° ©†dku

; ------ n†vrat obsluhy INT 09h

         push      ds
         lds       dx,ds:[HOld09]           ; pñvodn° obsluha INT 09h
         mov       ax,2509h
         int       21h                      ; n†vrat adresy INT 09h
         pop       ds

; ------ nastaven° norm†ln°ch atributñ p©°padnÇho souboru HESLO.SYS

         mov       dx,offset Soubor         ; jmÇno souboru
         mov       ax,4301h                 ; funkce nastaven° atributñ souboru
         xor       cx,cx                    ; CX <- atributy (norm†ln° soubor)
         int       21h                      ; zru®en° atributñ HID, SYS a R/O

; ------ vytvo©en° novÇho souboru HESLO.SYS (adresa DX)

         mov       ah,3ch                   ; funkce vytvo©en° souboru
         xor       cx,cx                    ; atributy - norm†ln° soubor
         int       21h                      ; otev©en° souboru
         xchg      ax,bx                    ; BX <- identifik†tor souboru
         jnc       Start82                  ; soubor vytvo©en OK

; ------ chyba vytvo©en° souboru HESLO.SYS

Start8:  mov       si,offset HErrTxt        ; chybovÇ hl†®en°
         call      HOutTxt                  ; zobrazen° hl†®en°
         mov       ax,4c02h
         int       21h

; ------ z†pis souboru na disk

Start82: mov       ah,40h
         mov       dx,offset Code:HesloBeg  ; zaá†tek hesla
         mov       cx,offset(HesloEnd-HesloBeg) ; dÇlka hesla
         int       21h                      ; z†pis souboru hesla
         jc        Start8                   ; chyba z†pisu
         cmp       ax,cx
         jne       Start8                   ; chyba z†pisu

; ------ uzav©en° souboru

         mov       ah,3eh
         int       21h                      ; uzav©en° souboru

; ------ nastaven° atributñ souboru

         mov       ax,4301h
         mov       cx,7                     ; poëadovanÇ atributy HID, SYS a R/O
         mov       dx,offset Soubor         ; jmÇno souboru
         int       21h                      ; nastaven° atributñ souboru

; ------ p©°prava oznaáen° aktivn°ho disku

         mov       ah,19h
         int       21h                      ; poskytnut° aktivn°ho disku
         add       byte ptr ds:[ZavTxt1],al ; oznaáen° disku

; ------ naáten° aktivn° cesty

         mov       ah,47h
         mov       si,offset ZavTxt2        ; buffer k naáten° cesty
         mov       dl,0                     ; aktivn° disk
         int       21h                      ; naáten° aktivn°ho adres†©e

; ------ prvn° á†st z†vàreánÇho hl†®en°

         mov       si,offset ZavTxt         ; z†vàreánò text
         call      HOutTxt                  ; zobrazen° prvn° á†sti textu

; ------ zaji®tàn° oddàlovac°ho znaku "\"

         cmp       byte ptr ds:[ZavTxt2],0  ; je z†kladn° adres†© ?
         je        Start84                  ; je jië z†kladn° adres†©
         mov       al,"\"                   ; oddàlovaá cesty
         call      HOutChr                  ; zobrazen° oddàlovaáe cesty

; ------ zobrazen° jmÇna souboru

Start84: mov       si,offset soubor         ; jmÇno souboru
         call      HOutTxt                  ; zobrazen° jmÇna souboru

; ------ druh† á†st z†vàreánÇho hl†®en°

         mov       si,offset HErrTxt0       ; text od©†dkov†n°
         call      HOutTxt                  ; od©†dkov†n° textu

; ------ konec programu

         mov       ax,4c00h                 ; n†vratovò k¢d - OK
         int       21h

; -----------------------------------------------------------------------------
;     vstup textu z kl†vesnice do bufferu DS:SI -> CX=poáet znakñ, CY=p©eru®en°
; -----------------------------------------------------------------------------

HInpTxt  PROC      NEAR

; ------ p©°prava registrñ

         push      si
         xor       cx,cx                    ; CX <- 0 á°taá zadanòch znakñ

; ------ vstup znaku z kl†vesnice

HInpTxt1:call      HInpChr                  ; vstup znaku z kl†vesnice
         jc        HInpTxt9                 ; p©eru®en° ESC nebo Ctrl-Break

; ------ ukonáen° programu ENTER

         cmp       al,13                    ; je Enter ?
         je        HInpTxt9                 ; je Enter

; ------ zru®en° znaku p©ed kurzorem BS

         cmp       al,8                     ; je BS ?
         jne       HInpTxt2                 ; nen° BS
         jcxz      HInpTxt1                 ; v bufferu nen° ë†dnò znak
         call      HOutBS                   ; vymaz†n° p©edchoz°ho znaku
         dec       cx                       ; sn°ëen° znakñ v bufferu
         dec       si                       ; sn°ëen° ukazatele v bufferu
         jmp       short HInpTxt1           ; vstup dal®°ho znaku

; ------ z†kaz ©°dic°ch kl†ves a zvl†®tn°ch znakñ

HInpTxt2:cmp       al," "                   ; je ©°dic° kl†vesa ?
         jb        HInpTxt1                 ; ©°dic° kl†vesa neplat°
         cmp       al,127                   ; je platnò znak ?
         jae       HInpTxt1                 ; nen° platnò znak

; ------ uloëen° znaku do bufferu

         cmp       cl,MAXHESLO              ; je jië maxim†ln° dÇlka textu ?
         jae       HInpTxt1                 ; je jië maxim†ln° dÇlka textu
         mov       ds:[si],al               ; uloëen° novÇho znaku
         inc       cx                       ; zvò®en° á°taáe znakñ
         inc       si                       ; zvò®en° ukl†dac° adresy
         call      HOutChr                  ; zobrazen° zadanÇho znaku
         jmp       short HInpTxt1           ; vstup dal®°ho znaku

; ------ n†vrat registrñ

HInpTxt9:pop       si
         ret

HInpTxt  ENDP

; -----------------------------------------------------------------------------
;        vstup znaku z kl†vesnice (s konverz° na velkÇ p°smeno) -> AX, CY=p©eru®en°
; -----------------------------------------------------------------------------

HInpChr  PROC      NEAR

; ------ vstup znaku z kl†vesnice

         mov       ah,0
         int       16h                      ; vstup znaku

; ------ konverze na velkÇ p°smeno

         cmp       al,"a"
         jb        HInpChr2                 ; nen° malÇ p°smeno
         cmp       al,"z"
         ja        HInpChr2                 ; nen° malÇ p°smeno
         sub       al,32                    ; korekce na velkÇ p°smeno

; ------ test, zda je ESC nebo Ctrl-Break

HInpChr2:cmp       al,27                    ; je ESC ?
         je        HInpChr3                 ; je ESC
         or        ax,ax                    ; je Ctrl-Break ?
         jnz       HInpChr4                 ; nen° Ctrl-Break
HInpChr3:stc                                ; p©°znak p©eru®en°
HInpChr4:ret

HInpChr  ENDP

; -----------------------------------------------------------------------------
;        menu zad†n° Ano/Ne pro text DS:SI -> CY=p©eru®en°, ZY="ANO", NZ="NE"
; -----------------------------------------------------------------------------

HMenu    PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      dx
         push      si
         push      di

; ------ inicializaán° zobrazen° v®eho

         xor       dx,dx                    ; DL <- 0 p©°znak volby "Ano"
         mov       di,si                    ; DX <- £schova adresy textu
         call      HOutTxt                  ; zobrazen° vòzvy
         mov       si,offset AnoNeTxt       ; text "Ano, (N)e"
         call      HOutTxt                  ; zobrazen° moënost°

; ------ zobrazen° vòzvy

HMenu1:  mov       si,di                    ; SI <- adresa vòzvy
         call      HOutTxt                  ; zobrazen° vòzvy

; ------ zobrazen° zbytku menu pro "Ne"

         or        dl,dl                    ; je "Ne" ?
         jz        HMenu2                   ; nen° "Ne"
         mov       si,offset AnoNeTx2
         call      HOutTxt                  ; zobrazen° zbytku menu

; ------ vstup znaku z kl†vesnice

HMenu2:  call      HInpChr                  ; vstup znaku z kl†vesnice
         jc        HMenu9                   ; p©eru®en° programu

; ------ potvrzen° volby ENTER

         cmp       al,13                    ; je ENTER ?
         je        HMenu8                   ; je ENTER

; ------ volba "A" = ano

         cmp       al,"A"
         je        HMenu9                   ; volba "Ano"

; ------ volba "N" = ne

         cmp       al,"N"
         je        HMenu7                   ; volba "Ne"

; ------ zmàna pozice kurzoru

         cmp       al,9                     ; TAB
         je        HMenu6
         cmp       ax,0f00h                 ; Shift-TAB
         je        HMenu6
         cmp       al,8                     ; BS
         je        HMenu6
         cmp       ah,4bh                   ; vlevo
         je        HMenu6
         cmp       ah,4dh                   ; vpravo
         jne       HMenu2
HMenu6:  xor       dl,1                     ; zmàna pozice kurzoru
         jmp       short HMenu1             ; pokraáov†n°

; ------ test, zda je volba "Ano"

HMenu7:  mov       dl,1                     ; volba NE
HMenu8:  or        dl,dl                    ; je volba ANO (= 0) ?

; ------ n†vrat registrñ

HMenu9:  call      HMazTxt                  ; vymaz†n° ©†dku
         pop       di
         pop       si
         pop       dx
         pop       ax
         ret

HMenu    ENDP

; -----------------------------------------------------------------------------
;        vymaz†n° ©†dku DOS (uchov†v† registr p©°znakñ)
; -----------------------------------------------------------------------------

HMazTxt  PROC      NEAR

         pushf
         push      ax
         push      cx

         mov       al,13
         call      HOutChr                  ; kurzor na zaá†tek ©†dku
         mov       cx,78                    ; asi tak znakñ na ©†dek
         mov       al," "
HMazTxt1:call      HOutChr                  ; zobrazen° jednÇ mezery
         loop      HMazTxt1                 ; dal®° mezera
         mov       al,13
         call      HOutChr                  ; kurzor na zaá†tek ©†dku

         pop       cx
         pop       ax
         popf
         ret

HMazTxt  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° textu ASCIIZ DS:SI na displej (niá° SI)
; -----------------------------------------------------------------------------

HOutTxt  PROC      NEAR

HOutTxt1:cld
         lodsb                              ; naáten° znaku
         cmp       al,0                     ; konec textu ?
         je        HOutTxt2                 ; je konec textu
         call      HOutChr                  ; vòstup znaku na displej DOS
         jmp       short HOutTxt1           ; dal®° znak

HOutTxt2:ret

HOutTxt  ENDP

; -----------------------------------------------------------------------------
;        vymaz†n° p©edchoz°ho znaku DOS
; -----------------------------------------------------------------------------

HOutBS   PROC      NEAR

         push      ax

         mov       al,8
         call      HOutChr                   ; posun kurzoru vlevo <BS>
         mov       al," "
         call      HOutChr                   ; vymaz†n° posledn°ho znaku
         mov       al,8
         call      HOutChr                   ; posun kurzoru zpàt vlevo

         pop       ax
         ret

HOutBS   ENDP

; -----------------------------------------------------------------------------
;        vòstup znaku AL na displej DOS
; -----------------------------------------------------------------------------

HOutChr  PROC      NEAR

         push      ax
         push      dx

         xchg      ax,dx                    ; DL <- znak k zobrazen°
         mov       ah,2
         int       21h                      ; zobrazen° znaku

         pop       dx
         pop       ax
         ret

HOutChr  ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 09h
; -----------------------------------------------------------------------------

HInt09   PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      ds

; ------ £schova ukl†dac° adresy do bufferu kl†vesnice

         mov       bx,40h
         mov       ds,bx                    ; segment s daty
         mov       bx,ds:[1ch]              ; ukl†dac° adresa do bufferu

; ------ pñvodn° obsluha INT 09h

         pushf
         call      dword ptr cs:[HOld09]    ; vol†n° pñvodn° obsluhy INT 09h

; ------ test, zda byla stisknuta nàjak† kl†vesa

         cmp       bx,ds:[1ch]              ; byla uloëena nàjak† kl†vesa ?
         je        HInt092                  ; nebyla ë†dn† kl†vesa

; ------ uji®tàn°, zda jië kl†vesa nebyla stisknuta

         test      byte ptr cs:[HParInt],1  ; byla kl†vesa jië zad†na ?
         jnz       HInt092                  ; kl†vesa jië byla zad†na
         or        byte ptr cs:[HParInt],1  ; p©°znak zad†n° k¢du kl†vesy

; ------ uloëen° k¢du horkÇ kl†vesy

         mov       ds:[1ch],bx              ; zru®en° horkÇ kl†vesy z bufferu
         mov       ax,ds:[bx]               ; k¢d horkÇ kl†vesy
         mov       bl,ds:[17h]              ; p©esmykaáe
         and       bl,0fh                   ; p©esmykaáe
         mov       cs:[Code:HotKey],ax      ; uloëen° k¢du horkÇ kl†vesy
         mov       cs:[Code:HotSwc],bl      ; p©esmykaáe

; ------ n†vrat registrñ

HInt092: pop       ds
         pop       bx
         pop       ax
         iret

HInt09   ENDP

; *****************************************************************************
;
;                                Data
;
; *****************************************************************************
;˛
HParInt  db        0                        ; bit 0: 1=hork† kl†vesa byla zad†na
HOld09   dd        0                        ; pñvodn° adresa INT 09h
Soubor   db        'HESLO.SYS',0            ; specifikace souboru

HesloSeg dw        0                        ; adresa programu hesla

HErrTxt  db        7,13,10,'Chyba zapisu do souboru HESLO.SYS !'
HErrTxt0 db        13,10,0

ZadTxt   db        'HESLO V1.30 - uzamykani pocitace; (c) Miroslav Nemecek',13,10
         db        'Zadejte heslo: ',0

StartTxt db        13,'Dotaz na heslo pri startu pocitace ? (',0
;ParkTxt  db        13,'Parkovat disk pred zadanim hesla ? (',0

AnoNeTxt db        'A)no, (N)e',0
AnoNeTx2 db        'A)no, (',0

TimerTxt db        13,'Doba pro automaticke uzamceni (1 az 60, 0=vypnuto) v minutach: ',0
HotTxt   db        13,'Stisknete horkou klavesu pro uzamceni pocitace: ',0

ZavTxt   db        13,'Nove vygenerovany soubor HESLO.SYS zaclente do CONFIG.SYS zapisem:',13,10
         db        'DEVICE='
ZavTxt1  db        'A:\'
ZavTxt2  db        70 dup(0)                ; buffer k naáten° aktivn° cesty

InpBuff  db        MAXHESLO dup(0)          ; vstupn° buffer k zad†n° áasu

Code     ENDS

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                          H E S L O   (modul HESLO.SYS)
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
HesloSys SEGMENT   PARA
         ASSUME    cs:HesloSys,ds:HesloSys
         ORG       0

HesloBeg label     byte                     ; offset zaá†tku modulu hesla

; ------------------------- z†hlav° ovladaáe za©°zen° -------------------------
         dd        -1                       ; ukazatel na n†sleduj°c° za©°zen°
         dw        0c000h                   ; atributy - znakovÇ za©°zen°
         dw        offset Strateg           ; adresa obsluhy strategie za©°zen°
         dw        offset Prerus            ; adresa obsluhy p©eru®en° za©°zen°
         db        '*HESLO* '               ; jmÇno za©°zen° (nepouëije se)
; ------------------------------ data, adresy ---------------------------------
AdrDev   dd        0                        ; adresa z†hlav° poëadavku za©°zen°
Heslo    dw        offset BufHeslo          ; adresa hesla (=konec programu)
Delka    dw        0                        ; dÇlka hesla
HotSwc   db        0                        ; p©esmykaáe horkÇ kl†vesy
HotKey   dw        01f0h                    ; hork† kl†vesa
Old08    dd        0                        ; pñvodn° adresa INT 08h
Old09    dd        0                        ; pñvodn° adresa INT 09h
ParInt   db        0                        ; bit 0: 1=program je zamknut
                                            ; bit 1: 1=heslo p©i startu poá°taáe
                                            ;  (bit 2: 1=parkov†n° p©ed heslem)
                                            ; bit 3: 1=automatickÇ uzamyk†n°
LockTime dw        0                        ; doba pro uzamáen° v 1/18 s (0=nen°)
LockCit  dw        0                        ; á°taá pro uzamáen° v 1/18 s

; ------------------------------- strategie -----------------------------------
Strateg  PROC      FAR                    ;* obsluha rutiny STRATEGIE

         mov       word ptr cs:[AdrDev],bx  ; offset adresy z†hlav° poëadavku
         mov       word ptr cs:[AdrDev+2],es; segment adresy z†hlav° poëadavku
         ret

Strateg  ENDP
; ------------------------------- p©eru®en° -----------------------------------
prerus   PROC      FAR                    ;* obsluha rutiny PûERUõENã

         pushf                              ; £schova p©°znakovÇho registru
         push      ax                       ; £schova AX
         push      bx                       ; £schova BX
         push      cx                       ; £schova CX
         push      dx                       ; £schova DX
         push      si                       ; £schova SI
         push      di                       ; £schova DI
         push      bp                       ; £schova BP
         push      ds                       ; £schova DS
         push      es                       ; £schova ES

         push      cs
         pop       ds                       ; DS <- CS
                                          ;* kontrola á°sla funkce
         les       di,ds:[adrdev]           ; adresa poëadavku za©°zen°
         mov       bl,es:[di+2]             ; k¢d povelu
         or        bl,bl                    ; kontrola maxim†ln°ho á°sla povelu
         mov       ax,8103h                 ; k¢d chyby - nezn†mò povel
         jz        Prerus1
         jmp       prerusa                  ; chyba - nezn†mò povel

                                          ;* rozli®en°, zda m† bòt heslo zad†no
Prerus1: test      byte ptr ds:[parint],2   ; m† bòt heslo zad†no ?
         jz        prerus99                 ; heslo nem† bòt zad†no

                                          ;* inicializace - vstup hesla
         mov       si,offset uvtxt          ; £vodn° text
         call      outtxt                   ; zobrazen° £vodn°ho textu
         mov       bx,ds:[heslo]            ; adresa hesla
         mov       si,bx                    ; adresa hesla
         add       si,ds:[delka]            ; zaá†tek bufferu pro vstup textu
         call      inptxt                   ; vstup textu hesla
         call      cmpall                   ; nalezen° hesla v textu
         jnc       prerus9                  ; heslo nalezeno OK
         lea       si,[errtxt]              ; chybovò text
         call      outtxt                   ; zobrazen° chybovÇho textu
         call      Parkuj                   ; zaparkov†n° pevnòch diskñ
prerus2: jmp       short prerus2            ; zablokov†n° poá°taáe

prerus9: lea       si,[oktxt]               ; text OK
         call      outtxt                   ; zobrazen° textu O.K.
prerus99:lea       ax,[BufHeslo]               ; konec programu
         add       ax,ds:[delka]            ; konec programu s heslem
         add       ax,15                    ; rezerva za heslem
         mov       es:[di+0eh],ax           ; konec rezid. modulu
         mov       word ptr es:[di+10h],cs  ; segment konce
         mov       byte ptr es:[di+13],0    ; poáet nainstalovanòch diskñ = 0

                                          ;* instalace obsluhy INT 09h
         cli
         xor       ax,ax
         mov       ds,ax
         mov       ax,ds:[9*4]
         mov       word ptr cs:[old09],ax
         mov       ax,ds:[9*4+2]
         mov       word ptr cs:[old09+2],ax

         mov       ax,ds:[8*4]
         mov       word ptr cs:[old08],ax
         mov       ax,ds:[8*4+2]
         mov       word ptr cs:[old08+2],ax

         mov       word ptr ds:[9*4],offset int09
         mov       word ptr ds:[9*4+2],cs

         mov       word ptr ds:[8*4],offset int08
         mov       word ptr ds:[8*4+2],cs

         mov       ax,0100h                 ; n†vratovò k¢d
prerusa: mov       es:[di+3],ax             ; nastaven° stavovÇho slova

         pop       es                       ; n†vrat ES
         pop       ds                       ; n†vrat DS
         pop       bp                       ; n†vrat BP
         pop       di                       ; n†vrat DI
         pop       si                       ; n†vrat SI
         pop       dx                       ; n†vrat DX
         pop       cx                       ; n†vrat CX
         pop       bx                       ; n†vrat BX
         pop       ax                       ; n†vrat AX
         popf                               ; n†vrat p©°znakovÇho registru
         ret

prerus   ENDP

; ----------------------- INT 08h - obsluha INT 08h

Int08:   pushf
         call      dword ptr cs:[Old08]
         test      byte ptr cs:[ParInt],8   ; je automatickÇ uzamyk†n° ?
         jz        Int089                   ; nen° automatickÇ uzamyk†n°

         cmp       word ptr cs:[LockCit],0  ; je jië 0 ?
         je        Int089                   ; je jië 0
         dec       word ptr cs:[LockCit]    ; á°t†n° uzamknut°
         jnz       Int089                   ; nen° je®tà uzamknut°

         push      ax
         push      bx
         push      ds
         mov       bx,40h
         mov       ds,bx
         mov       bx,ds:[1ch]              ; ukl†dac° adresa do bufferu
         jmp       short Int091             ; uzamknut° poá°taáe

Int089:  iret

; ------------------------ INT 09h - obsluha INT 09h --------------------------
int09:                                    ;* obsluha INT 09h - zamykac° kl†vesa

         push      ax
         push      bx
         push      ds
         mov       bx,cs:[LockTime]
         mov       cs:[LockCit],bx          ; inicializace á°taáe pro uzamknut°

         mov       bx,40h
         mov       ds,bx                    ; segment s daty
         mov       bx,ds:[1ch]              ; ukl†dac° adresa do bufferu
         pushf
         call      dword ptr cs:[old09]     ; vol†n° pñvodn° obsluhy INT 09h
         cmp       bx,ds:[1ch]              ; byla uloëena nàjak† kl†vesa ?
         je        int092                   ; nebyla ë†dn† kl†vesa
         mov       ax,cs:[hotkey]           ; hork† kl†vesa
         cmp       ds:[bx],ax               ; je hork† kl†vesa ?
         jne       int092                   ; nen° hork† kl†vesa
         mov       al,ds:[17h]              ; p©esmykaáe
         and       al,0fh                   ; stav p©esmykaáñ
         cmp       al,cs:[hotswc]           ; stejnÇ p©esmykaáe ?
         jne       int092                   ; nen° shoda p©esmykaáñ

Int091:  test      byte ptr cs:[parint],1   ; je program zamknut ?
         jnz       int092                   ; program je jië zamknut
         cmp       word ptr ds:[72h],HOTOFF ; je p©echodnÇ vypnut° z†mku ?
         je        int092                   ; je p©echodnÇ vypnut° z†mku

         or        byte ptr cs:[parint],1   ; p©°znak uzamáen° programu
         mov       ds:[1ch],bx              ; zru®en° horkÇ kl†vesy z bufferu
         mov       byte ptr ds:[100h],1     ; fale®nò p©°znak obsluhy PrtScr

         call      beep                     ; p°pnut°
         call      beep                     ; p°pnut°
         call      beep                     ; p°pnut°
         call      beep                     ; p°pnut°
         call      beep                     ; p°pnut°
         call      beep                     ; p°pnut°
         call      zamek                    ; uzamknut° programu
         and       byte ptr cs:[parint],not 1 ; zru®en° p©°znaku zamknut° prog.
         call      beep
         call      beep
         call      beep
         mov       byte ptr ds:[100h],0     ; zru®en° p©°znaku obsluhy PrtScr

int092:  pop       ds
         pop       bx
         pop       ax
int05:                                    ;* p©echodn† obsluha INT 05h (PrtScr)

         iret

; --------------------------- p°pnut° -----------------------------------------
beep:                                     ;* p°pnut°

         push      ax
         push      cx
         mov       cx,20000
;         mov       al,0b6h                  ; povel pro nastaven° kan†lu 2
;         out       [43h],al                 ; nastaven° kan†lu 2
;         mov       al,60                    ; nië®° bajt dàliáky
;         out       [42h],al                 ; nastaven° nië®°ho bajtu dàliáky
;         mov       al,2                     ; vy®®° bajt dàliáky
;         out       [42h],al                 ; nastaven° vy®®°ho bajtu dàliáky
         in        al,[61h]
         push      ax
         or        al,3                     ; zapnut° reproduktoru
         out       [61h],al
         loop      $                        ; áek†n° po zadanou dÇlku t¢nu
         pop       ax                       ; n†vrat nastaven° portu
         out       [61h],al
         mov       cx,1000
         loop      $                        ; prodleva mezi t¢ny
         pop       cx
         pop       ax
         ret

; ---------------------------- uzamknut° programu ----------------------------
zamek:                                    ;* uzamknut° programu
         pushf
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      ds
         push      cs
         pop       ds
         sti
zamek0:                                   ;* vynulov†n° bufferu
         mov       ah,1
         int       16h                      ; dotaz na statut bufferu
         jz        zamek1                   ; buffer je jië vynulov†n
         call      inpch                    ; vyjmut° znaku z bufferu
         jmp       short zamek0             ; dal®° znak
zamek1:                                   ;* zaá†tek zad†v†n° hesla
         mov       si,ds:[heslo]            ; adresa hesla
         mov       cx,ds:[delka]            ; dÇlka hesla
         jcxz      zamek6                   ; nen° ë†dnò znak hesla
zamek3:  call      inpch                    ; vstup znak
         not       al                       ; negace znaku
         cmp       ds:[si],al               ; je spr†vnò znak ?
         jne       zamek1                   ; nen° spr†vnò znak
         inc       si                       ; zvò®en° ukazatele hesla
         loop      zamek3                   ; vstup dal®°ho znaku
zamek6:
         pop       ds
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         popf
         ret

; -------------------------- nalezen° hesla v textu ---------------------------
cmpall:                                   ;* nalezen° hesla v textu
                                            ; VSTUP: DS:SI=zadanò text hesla
                                            ;        DS:BX=zak¢dovanÇ heslo
                                            ;        CX=poáet zadanòch znakñ
                                            ; VùSTUP: CY=heslo nenalezeno

         sub       cx,ds:[delka]            ; je zadanò text men®° ?
         jb        cmpall2                  ; zadanò text je men®°
         inc       cx                       ; poáet testñ shody
cmpall1: call      cmptxt                   ; porovn†n° textñ
         je        cmpall2                  ; text nalezen
         inc       si                       ; zvò®en° adresy v bufferu
         loop      cmpall1                  ; dal®° test textu
         stc                                ; p©°znak - text nenalezen
cmpall2: ret
; -------------------------- porovn†n° textñ ----------------------------------
cmptxt:                                   ;* porovn†n° textñ v bufferech
                                            ; VSTUP: DS:SI=zadanò text
                                            ;        DS:BX=zak¢dovanÇ heslo
                                            ; VùSTUP: ZY=je shoda jmen

         push      si                       ; zadanò text
         push      bx                       ; porovn†vanò text
         push      cx
         mov       cx,ds:[delka]            ; dÇlka hesla
         or        cx,cx
         jz        cmptxt2                  ; nen° ë†dnò znak hesla
         cld
cmptxt1: lodsb                              ; naáten° zadanÇho znaku
         inc       bx                       ; zvò®en° ukazatele reference
         not       al
         cmp       al,ds:[bx-1]             ; porovn†n° se zak¢dovanòm znakem
         loopz     cmptxt1                  ; test dal®°ho znaku
cmptxt2: pop       cx
         pop       bx
         pop       si
         ret
; ------------------------- vstup textu z kl†vesnice --------------------------
inptxt:                                   ;* vstup textu z kl†vesnice
                                            ; VSTUP: DS:SI=ukl†dac° adresa
                                            ; VùSTUP: CX=poáet zadanòch znakñ

         push      si
         xor       cx,cx                    ; á°taá zadanòch znakñ
inptxt1: call      inpch                    ; vstup znaku z kl†vesnice
         cmp       al,13                    ; je <Enter> ?
         je        inptxt3                  ; je <Enter>

         cmp       al,8                     ; je <BS> ?
         je        inptxt2                  ; je <BS>

         cmp       al,27
         je        inptxt1                  ; ESC

         cmp       al," "
         jb        inptxt1

         cmp       cl,MAXHESLO              ; je jië maxim†ln° dÇlka textu ?
         jae       InpTxt1                  ; je jië maxim†ln° dÇlka textu
         mov       ds:[si],al               ; uloëen° novÇho znaku
         inc       cx                       ; zvò®en° á°taáe znakñ
         inc       si                       ; zvò®en° ukl†dac° adresy
         mov       al,"*"                   ; n†hradn° znak "*"
         call      outch                    ; zobrazen° n†hradn°ho znaku "*"
         jmp       short inptxt1            ; vstup dal®°ho znaku

inptxt2: jcxz      inptxt1                  ; v bufferu nen° ë†dnò znak
         call      outbs                    ; vymaz†n° p©edchoz°ho znaku
         dec       cx                       ; sn°ëen° znakñ v bufferu
         dec       si                       ; sn°ëen° ukazatele v bufferu
         jmp       short inptxt1            ; vstup dal®°ho znaku

inptxt3: jcxz      inptxt5                  ; nen° zad†n ë†dnò text

         push      cx
inptxt4: call      outbs                    ; vymaz†n° posledn°ho znaku "*"
         loop      inptxt4
         pop       cx

inptxt5: pop       si
         ret
; ------------------------- vstup znaku z kl†vesnice --------------------------
inpch:                                    ;* vstup znaku z kl†vesnice
                                            ; VùSTUP: AX=k¢d kl†vesy
         xor       ax,ax
         int       16h                      ; vstup znaku
         cmp       al,"a"
         jb        inpch2                   ; je men®° neë "a" - nen° malÇ p°sm.
         cmp       al,"z"
         ja        inpch2                   ; je vàt®° neë "z" - nen° malÇ p°sm.
         sub       al,32                    ; korekce na velkÇ p°smeno
inpch2:  ret
; ------------------------- vòstup textu na displej ---------------------------
outtxt:                                   ;* vòstup textu na displej
                                            ; VSTUP: DS:SI=adresa textu

         cld
         lodsb                              ; naáten° znaku k zobrazen°
         xor       al,KODBYTE               ; rozk¢dov†n° znaku
         or        al,al                    ; je jië konec textu ?
         jz        outtxt1                  ; je konec textu
         call      outch                    ; zobrazen° znaku
         jmp       short outtxt             ; zobrazen° dal®°ho znaku
outtxt1: ret
; -------------------------- vymmaz†n° znaku ----------------------------------
outbs:                                    ;* vymaz†n° p©edchoz°ho znaku
         push      ax
         mov       al,8
         call      outch                    ; posun kurzoru vlevo <BS>
         mov       al," "
         call      outch                    ; vymaz†n° posledn°ho znaku
         mov       al,8
         call      outch                    ; posun kurzoru zpàt vlevo
         pop       ax
         ret
; ------------------------- vòstup znaku na displej ---------------------------
outch:                                    ;* vòstup znaku na displej
                                            ; VSTUP: AL=znak k zobrazen°
         push      ax
         push      bx
         push      cx
         push      si

         mov       ah,0eh                   ; funkce zobrazen° znaku
         mov       bx,7                     ; str†nka 0, atributy b°l† na áernÇ
         int       10h                      ; zobrazen° znaku na displeji

         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

; *****************************************************************************
;
;                         Parkov†n° pevnòch diskñ
;
; *****************************************************************************

Parkuj   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es
                                          ;* reset diskovÇho systÇmu
         mov       ah,0dh
         int       21h                      ; reset diskovÇho systÇmu DOS
                                          ;* z°sk†n° poátu diskñ
         mov       ah,8
         mov       dl,80h                   ; á°slo pevnÇho disku 0
         int       13h                      ; poskytnut° poátu diskñ
         jc        Parkuj9                  ; chyba - nen° ë†dnò pevnò disk
         and       dx,3                     ; poáet pevnòch diskñ
         jz        Parkuj9                  ; nen° ani 1 pevnò disk
         mov       ds:[disku],dl            ; £schova poátu pevnòch diskñ
         dec       dx                       ; je 1 pevnò disk ?
         jz        getd0                    ; je pouze 1 pevnò disk
                                          ;* zji®tàn° parkovac° stopy disku 1
         mov       dl,81h                   ; á°slo pevnÇho disku 1
         mov       bx,118h                  ; offset adresy INT 46h
         call      getdisk                  ; zji®tàn° parkovac° stopy disku 1
         mov       ds:[parkc1],dx           ; parkovac° stopa disku 1
getd0:                                    ;* zji®tàn° parkovac° stopy disku 0
         mov       dl,80h                   ; á°slo pevnÇho disku 0
         mov       bx,104h                  ; offset adresy INT 41h
         call      getdisk                  ; zji®tàn° parkovac° stopy disku 0
         mov       ds:[parkc0],dx           ; parkovac° stopa disku 0
                                          ;* test spr†vnosti stop
         mov       ax,ds:[parkc0]           ; parkovac° stopa disku 0
         or        ax,ds:[parkc1]           ; je alespo§ 1 pevnò disk ?
         jz        Parkuj9                  ; nen° ë†dnò pevnò disk

                                          ;* zaparkov†n° diskñ
         mov       dl,80h                   ; á°slo pevnÇho disku 0
         mov       bx,ds:[parkc0]           ; parkovac° stopa disku 0
         call      park                     ; zaparkov†n° pevnÇho disku 0
         inc       dx                       ; á°slo pevnÇho disku 1
         mov       bx,ds:[parkc1]           ; parkovac° stopa disku 1
         call      park                     ; zaparkov†n° pevnÇho disku 1

; ------ n†vrat registrñ

Parkuj9: pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Parkuj   ENDP

; -----------------------------------------------------------------------------
getdisk:                                  ;* zji®tàn° parkovac° stopy
                                            ; VSTUP: DL=á°slo disku
                                            ;        BX=offset ukazatele tabulky
                                            ; VùSTUP: DX=parkovac° stopa disku
         push      es
         xor       ax,ax
         mov       es,ax                    ; segment 0
         mov       al,dl                    ; £schova á°sla disku
         les       bx,es:[bx]               ; adresa tabulky popisovaáe
         mov       dx,es:[bx]               ; poáet v†lcñ disku
         dec       dx                       ; á°slo posledn° stopy
         call      testat                   ; je poá°taá AT ?
         jc        getdisk2                 ; nen° poá°taá AT
         mov       dx,es:[bx+0ch]           ; parkovac° z¢na pevnÇho disku
getdisk2:or        dx,dx                    ; je platn† stopa ?
         jnz       getdisk4                 ; je platn† stopa

         mov       dl,al                    ; á°slo disku
         mov       ah,8
         int       13h                      ; poskytnut° posledn° stopy
         jc        getdisk4                 ; nen° platnò disk
         xchg      ch,cl                    ; CL <- nië®° bajt á°sla stopy
         rol       ch,1
         rol       ch,1                     ; bity 8 a 9 á°sla stopy
         and       ch,3                     ; bity 8 a 9 á°sla stopy
         shr       dh,1
         shr       dh,1
         shr       dh,1
         shr       dh,1                     ; bity 10 a 11 á°sla stopy
         and       dh,0ch                   ; bity 10 a 11 á°sla stopy
         xor       dl,dl
         or        dx,cx                    ; DX = á°slo posledn° stopy
         inc       dx                       ; DX = á°slo parkovac° stopy

getdisk4:pop       es
         ret
; -----------------------------------------------------------------------------
park:                                     ;* zaparkov†n° jednoho pevnÇho disku
                                            ; VSTUP: DL=á°slo disku
                                            ;        BX=á°slo stopy

         or        bx,bx                    ; je disk zad†n ?
         jz        park2                    ; neplatnò disk
         push      dx
         xor       ax,ax
         int       13h                      ; reset disku
         pop       dx
         mov       cx,5                     ; poáet pokusñ o parkov†n°
park1:   push      bx
         push      cx
         push      dx

         mov       ch,bl                    ; nië®° bajt á°sla v†lce
         mov       cl,bh                    ; vy®®° bajt á°sla v†lce
         ror       cl,1
         ror       cl,1                     ; bity 8 a 9 do bitñ 6 a 7
         and       cl,0c0h                  ; ponech† bity 6 a 7 (= 8 a 9)
         inc       cl                       ; -> sektor 1
         mov       dh,bh                    ; vy®®° bajt á°sla v†lce
         shl       dh,1
         shl       dh,1
         shl       dh,1
         shl       dh,1                     ; bity 10 a 11 do bitñ 6 a 7
         and       dh,0c0h                  ; ponech† bity 6 a 7 (= 10 a 11)
         mov       ah,0ch                   ; funkce vystaven° hlav
         int       13h                      ; vystaven° na parkovac° stopu

         pop       dx
         pop       cx
         pop       bx
         loop      park1                    ; novÇ zaparkov†n° disku
park2:   ret
; -----------------------------------------------------------------------------
testat:                                   ;* je poá°taá AT ?
                                            ; VùSTUP: CY=nen° AT
         push      ax
         push      ds
         mov       ax,0f000h                ; segment modulu BIOS
         mov       ds,ax                    ; segment modulu BIOS
         cmp       byte ptr ds:[0fffeh],0fch; je AT nebo XT-286 ?
         je        testat2                  ; je AT nebo XT-286
         stc                                ; p©°znak, ëe nen° AT
testat2: pop       ds
         pop       ax
         ret

parkc0   dw        0                        ; parkovac° stopa disku 0
parkc1   dw        0                        ; parkovac° stopa disku 1

disku    db        0                        ; poáet pevnòch diskñ

; ------ texty k vòpisu

UvTxt    label     byte
;        db        'ZADEJTE HESLO: ',0

         db        'Z' XOR KODBYTE
         db        'A' XOR KODBYTE
         db        'D' XOR KODBYTE
         db        'E' XOR KODBYTE
         db        'J' XOR KODBYTE
         db        'T' XOR KODBYTE
         db        'E' XOR KODBYTE
         db        ' ' XOR KODBYTE
         db        'H' XOR KODBYTE
         db        'E' XOR KODBYTE
         db        'S' XOR KODBYTE
         db        'L' XOR KODBYTE
         db        'O' XOR KODBYTE
         db        ':' XOR KODBYTE
         db        ' ' XOR KODBYTE
         db        0   XOR KODBYTE

ErrTxt   label     byte
;        db        ' ..... CHYBA !',7,13,10,0

         db        ' ' XOR KODBYTE
         db        '.' XOR KODBYTE
         db        '.' XOR KODBYTE
         db        '.' XOR KODBYTE
         db        '.' XOR KODBYTE
         db        '.' XOR KODBYTE
         db        '.' XOR KODBYTE
         db        ' ' XOR KODBYTE
         db        'C' XOR KODBYTE
         db        'H' XOR KODBYTE
         db        'Y' XOR KODBYTE
         db        'B' XOR KODBYTE
         db        'A' XOR KODBYTE
         db        ' ' XOR KODBYTE
         db        '!' XOR KODBYTE
         db        7   XOR KODBYTE
         db        13  XOR KODBYTE
         db        10  XOR KODBYTE
         db        'P' XOR KODBYTE
         db        'a' XOR KODBYTE
         db        'r' XOR KODBYTE
         db        'k' XOR KODBYTE
         db        'u' XOR KODBYTE
         db        'j' XOR KODBYTE
         db        'i' XOR KODBYTE
         db        ' ' XOR KODBYTE
         db        'p' XOR KODBYTE
         db        'e' XOR KODBYTE
         db        'v' XOR KODBYTE
         db        'n' XOR KODBYTE
         db        'e' XOR KODBYTE
         db        ' ' XOR KODBYTE
         db        'd' XOR KODBYTE
         db        'i' XOR KODBYTE
         db        's' XOR KODBYTE
         db        'k' XOR KODBYTE
         db        'y' XOR KODBYTE
         db        ' ' XOR KODBYTE
         db        'a' XOR KODBYTE
         db        ' ' XOR KODBYTE
         db        'b' XOR KODBYTE
         db        'l' XOR KODBYTE
         db        'o' XOR KODBYTE
         db        'k' XOR KODBYTE
         db        'u' XOR KODBYTE
         db        'j' XOR KODBYTE
         db        'i' XOR KODBYTE
         db        ' ' XOR KODBYTE
         db        'p' XOR KODBYTE
         db        'o' XOR KODBYTE
         db        'c' XOR KODBYTE
         db        'i' XOR KODBYTE
         db        't' XOR KODBYTE
         db        'a' XOR KODBYTE
         db        'c' XOR KODBYTE
         db        '.' XOR KODBYTE
         db        '.' XOR KODBYTE
         db        '.' XOR KODBYTE
         db        '.' XOR KODBYTE
         db        13  XOR KODBYTE
         db        10  XOR KODBYTE
         db        0   XOR KODBYTE

OKTxt    label     byte
;        db        ' O.K. ',13,10,0

         db        ' ' XOR KODBYTE
         db        'O' XOR KODBYTE
         db        '.' XOR KODBYTE
         db        'K' XOR KODBYTE
         db        '.' XOR KODBYTE
         db        ' ' XOR KODBYTE
         db        13  XOR KODBYTE
         db        10  XOR KODBYTE
         db        0   XOR KODBYTE

; ------ zadanÇ heslo

BufHeslo db        MAXHESLO dup(?)          ; buffer k uloëen° hesla
BufRefer db        MAXHESLO dup(?)          ; referenán° buffer k naáten°

HesloEnd label     byte                     ; konec programu hesla

HesloSys ENDS
         END       Start

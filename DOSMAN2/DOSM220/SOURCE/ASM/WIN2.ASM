

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                               W I N D O W - 2
;
;                         Obsluha funkc° oken adres†©ñ
;
; =============================================================================
;
;        EditAWin (FAR) - ovl†d†n° kurzoru v adres†©ovÇm oknà
;        QSrcEnd  (FAR) - ukonáen° reëimu rychlovyhled†v†n°
;        InvSPol  (FAR) - inverze oznaáen° vòbàru jednÇ poloëky
;        SetSPol  (FAR) - oznaáen° vòbàru jednÇ poloëky
;        ResSPol  (FAR) - odznaáen° vòbàru jednÇ poloëky
;        InitRows (FAR) - inicializace vò®ky oken
;
;        ReReadD  (FAR) - opàtovnÇ naáten° obsahu adres†©ovÇho okna
;        ReadDir  (FAR) - naáten° obsahu adres†©ovÇho okna
;        XchgWSeg (FAR) - z†màna segmentñ okna
;        LoadFInf (FAR) - naáten° informaán°ho souboru koment†©ñ okna
;        InitDInf (FAR) - inicializace diskovòch informac° (volnÇ m°sto disku)
;        DuplAWin (FAR) - zdvojen° (kopie) definice okna pro novÇ naá°t†n°
;        CreatAWn (FAR) - vytvo©en° novÇho okna
;        SelWDir  (FAR) - vòbàr poloëek k zobrazen° v adres†©ovÇm oknà
;        TestMask (FAR) - test poloëky, zda odpov°d† zadanÇ masce
;        TestProg (FAR) - test poloëky, zda je to program
;        SortLWn  (FAR) - set©°dàn° á†sti poloëek v seznamu
;        SortDir  (FAR) - set©°dàn° poloëek v adres†©i
;        InitFKom (FAR) - inicializace p©i©azen° koment†©ñ poloëk†m
;        GetAKurz (FAR) - poskytnut° adresy aktivn° poloëky aktivn°ho okna
;        GetPol   (FAR) - poskytnut° adresy zadanÇ poloëky
;        ReSort   (FAR) - p©et©°dàn° adres†©ovÇho okna (se zachov†n°m kurzoru)
;        AktSelct (FAR) - aktualizace vòbàru poloëek
;        RetWKur  (FAR) - n†vrat kurzoru na pñvodn° stejnou poloëku adres†©e
;        TestWPol (FAR) - test poloëky ve tvaru FCB, zda je v seznamu okna
;        InsNFile (FAR) - uloëen° souboru do seznamu okna
;           (StorFile (FAR) - uloëen° novà nalezenÇho souboru do definice okna)
;
;        AllDisk  (BYTE) - text specifikace v®ech souborñ s diskem
;        AllDir   (BYTE) - text specifikace v®ech souborñ v adres†©i ROOT
;        All      (BYTE) - text specifikace v®ech souborñ
;        HomeDirN (WORD) - dÇlka specifikace domovskÇho adres†©e
;        HomeDir  (BYTE) - domovskò adres†©
;        TabScan  (BYTE) - tabulka SCAN k¢dñ kl†ves Alt-p°smeno
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

INCLUDE  ASM\DEF.ASM

CodeWin  SEGMENT   BYTE PUBLIC
         ASSUME    cs:CodeWin,ds:data

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                   Editace (obsluha) adres†©ovòch oken
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; *****************************************************************************
;                            EditAWin
;                 obsluha aktivn°ho adres†©ovÇho okna
; -----------------------------------------------------------------------------
; VSTUP: BX=kl†vesa
;        DS=datovò segment
; VùSTUP:BX=0 - kl†vesa byla obslouëena
; *****************************************************************************

EditAWin PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ adresa aktivn°ho okna

         call      far ptr TestAAWn         ; test, zda je aktivn° okno zapnuto
         jnc       EditAW06                 ; okno je zapnuto OK
         jmp       EditAWn9                 ; okno nen° zapnuto
EditAW06:call      far ptr GetAAWin         ; poskytnut° adresy aktivn°ho okna
         mov       bp,es                    ; BP <- adresa okna

; ------ zah†jen° rychlovyhled†v†n°, je-li platnò znak a nen°-li p©°kaz. ©†dek

         cmp       byte ptr ds:[LineCVys],0 ; je p©°kazovò ©†dek ?
         jne       EditAWn0                 ; je p©°kazovò ©†dek
         cmp       bl," "                   ; je ASCII znak ?
         jb        EditAWn0                 ; nen° znak ASCII
         or        byte ptr ds:[WindPar],bit3 ; zah†jen° reëimu rychlovyhled.

; ------ zak†zanÇ kl†vesy

EditAWn0:test      byte ptr ds:[WindPar],bit3 ; je rychlovyhled†v†n° ?
         jnz       EditAWn1                 ; je rychlovyhled†v†n°

         cmp       bx,11bh
         je        EditAW09                 ; ESC
         cmp       bx,0e08h
         je        EditAW09                 ; BS
         cmp       bx,0e00h
         je        EditAW09                 ; Alt-BS

         push      ax
         mov       al,es:[AWinPrm2]
         and       al,bit5+bit6             ; typ zobrazen°
         cmp       al,1*bit5                ; je 3-sloupcovÇ zobrazen° ?
         pop       ax
         je        EditAWn1                 ; je 3-sloupcovÇ okno

;         test      byte ptr es:[AWinPrm2],bit5 ; 3 sloupcovÇ okno ?
;         jnz       EditAWn1                 ; je 3 sloupcovÇ okno
         cmp       bx,4b00h                 ; kurzor vlevo ?
         je        EditAW09                 ; kurzor vlevo
         cmp       bx,1f13h                 ; ^S
         je        EditAW09
         cmp       bx,4d00h                 ; kurzor vpravo ?
         je        EditAW09                 ; kurzor vpravo
         cmp       bx,2004h                 ; ^D
EditAW09:je        EditAWn9

; ------ p©°prava registrñ

EditAWn1:xor       cx,cx                    ; CX <- 0
         mov       cl,ds:[NumRows]          ; skuteán† vò®ka okna
         sub       cl,5                     ; poáet souborñ v oknà
         test      byte ptr es:[AWinPrm2],bit4 ; je stavovò ©†dek ?
         jnz       EditAWn2                 ; nen° stavovò ©†dek
         sub       cl,2                     ; odeáten° 2 ©†dkñ na stavovò ©†dek
EditAWn2:mov       di,cx                    ; poáet ©†dkñ okna

         mov       al,es:[AWinPrm2]
         and       al,bit5+bit6             ; parametry
         cmp       al,1*bit5                ; je 3-sloupcovÇ okno ?
         jne       EditAWn3                 ; nen° 3-sloupcovÇ okno

;         test      byte ptr es:[AWinPrm2],bit5 ; 3 sloupcovÇ okno ?
;         jz        EditAWn3                 ; nen° 3 sloupcovÇ okno
         mov       al,cl                    ; AL <- poáet ©†dkñ se soubory
         shl       cl,1                     ; poáet ©†dkñ * 2
         add       cl,al                    ; poáet poloëek v 3-sloupc. oknà
EditAWn3:mov       si,es:[AWinFrst]         ; prvn° poloëka v oknà
         mov       dx,es:[AWinSouN]         ; poáet zobrazenòch poloëek celkem
         mov       ax,es:[AWinKurz]         ; kurzor

; ------ obsluha podle kl†vesy

         call      EditAWE                  ; obsluha kl†vesy

         cmp       ax,es:[AWinKurz]         ; je zmàna ?
         jne       EditAWn6                 ; je zmàna
         cmp       si,es:[AWinFrst]
         je        EditAWn7                 ; nen° zmàna
EditAWn6:or        byte ptr es:[AWinPrm0],bit4 ; je pot©eba zobrazen°
EditAWn7:mov       es:[AWinKurz],ax         ; novò kurzor
         mov       es:[AWinFrst],si         ; nov† prvn° poloëka

         call      far ptr InitQVw          ; inicializace rychlovyhled†v†n°
         call      far ptr AktPthAT         ; aktualizace stromu v aktivn°m oknà
         call      far ptr AktPthAL         ; aktualizace cesty okna seznamu
         call      far ptr DispAAWn         ; zobrazen° aktivn°ho okna

EditAWn8:xor       bx,bx                    ; p©°znak obsluhy kl†vesy
EditAWn9:pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

EditAWin ENDP

; -----------------------------------------------------------------------------
;        skok na obsluhu kl†vesy editace aktivn°ho okna
; -----------------------------------------------------------------------------

EditAWE  PROC      NEAR

         call      far ptr JumpBX           ; skok na obsluhu podle kl†vesy

         dw        5000h,AWinDown           ; Down - posun o ©†dek dolñ
         dw        2d18h,AWinDown           ; ^X - posun o ©†dek dolñ
         dw        4800h,AWinUp             ; Up - posun o ©†dek nahoru
         dw        1205h,AWinUp             ; ^E - posun o ©†dek nahoru
         dw        4700h,AWinHome           ; Home - posun na zaá†tek okna
         dw        4f00h,AWinEnd            ; End - posun na konec okna
         dw        8400h,AWinHome           ; ^PageUp - posun na zaá†tek okna
         dw        7600h,AWinEnd            ; ^PageDown - posun na konec okna
         dw        4900h,AWinPgUp           ; PageUp - posun o str†nku nahoru
         dw        1312h,AWinPgUp           ; ^R - posun o str†nku nahoru
         dw        5100h,AWinPgDn           ; PageDown - posun o str†nku dolñ
         dw        2e03h,AWinPgDn           ; ^C - posun o str†nku dolñ
         dw        7700h,AWinHome           ; ^Home - posun na zaá†tek okna
         dw        7500h,AWinEnd            ; ^End - posun na konec okna
         dw        1117h,AWinCW             ; ^W - rolov†n° okna o ©†dek dolñ
         dw        2c1ah,AWinCZ             ; ^Z - rolov†n° okna o ©†dek nahoru
         dw        8d00h,AWinCUp            ; ^Up - posun o 6 ©†dkñ nahoru
         dw        9100h,AWinCDwn           ; ^Down - posun o 6 ©†dkñ dolñ
         dw        5200h,AWinIns            ; INS - oznaáen° souboru
         dw        2f16h,AWinIns            ; ^V - oznaáen° souboru
         dw        0a200h,AWinIns0          ; Alt-INS oznaáen° souboru (bez ukonáen° rychlovyhled†v†n°)
         dw        9000h,AWinSet            ; ^[+] - oznaáen° v®ech souborñ
         dw        8e00h,AWinRes            ; ^[-] - odznaáen° v®ech souborñ
         dw        9600h,AWinInv            ; ^[*] - inverze v®ech souborñ
         dw        9200h,AWinInv            ; Ctrl-Ins - inverze v®ech souborñ
;         dw        9200h,AWinInvD           ; Ctrl-Ins - inverze souborñ+adres†©ñ
         dw        071eh,AWinPrg            ; Ctrl-^ - inverze oznaáen° programñ
         dw        1b1dh,AWinObn            ; Ctrl-] - obnoven° oznaáen° poloëek
         dw        4e00h,AWinStF            ; Alt-[+] - oznaáen° jednoho souboru
         dw        4a00h,AWinRsF            ; Alt-[-] - odznaáen° jednoho soub.
         dw        3700h,AWinIns            ; Alt-[*] - inverze jednoho souboru
         dw        4b00h,AWinLeft           ; kurzor vlevo
         dw        1f13h,AWinLeft           ; ^S vlevo
         dw        4d00h,AWinRght           ; kurzor vpravo
         dw        2004h,AWinRght           ; ^D vpravo
         dw        9b00h,AWinQLft           ; Alt-vlevo
         dw        9d00h,AWinQRgh           ; Alt-vpravo
         dw        11bh,AWinEsc             ; ESC
         dw        0e08h,AWinQLft           ; BS
         dw        2308h,AWinQLft           ; ^H
         dw        0e00h,AWinQLft           ; Alt-BS
         dw        0a000h,AWinADwn          ; Alt-dolñ
         dw        9800h,AWinAUp            ; Alt-nahoru
         dw        9700h,AWinAHom           ; Alt-Home
         dw        9f00h,AWinAEnd           ; Alt-End

         dw        0,EditAWE1

; -----------------------------------------------------------------------------
;        obsluha kl†vesy BX vòbàru souborñ DS:SI
; -----------------------------------------------------------------------------

EditSMnu PROC      FAR

; ------ p©echodnÇ vypnut° okna

         call      far ptr MCtrlO           ; obsluha vypnut° okna
         jnc       EditSMn1                 ; nebyla funkce Ctrl-O
         ret

; ------ £schova registrñ

EditSMn1:push      ax
         push      cx
         push      dx
         push      di
         push      bp
         push      es

; ------ adresa okna

         mov       ax,ds:[si+SMnuSeg]       ; segment okna
         call      far ptr GetDat           ; adresa okna
         jc        EditSMn9                 ; chyba
         mov       bp,es                    ; BP <- segment okna

; ------ zah†jen° rychlovyhled†v†n°, je-li to platnò znak

         cmp       bl," "                   ; je ASCII znak ?
         jb        EditSMn2                 ; nen° znak ASCII
         cmp       bh,MousXKod/HI           ; je to k¢d my®i ?
         je        EditSMn2                 ; je to k¢d my®i
         or        byte ptr ds:[WindPar],bit3 ; zah†jen° reëimu rychlovyhled.

; ------ z†kaz nàkteròch kl†ves, nen°-li rychlovyhled†v†n°

EditSMn2:test      byte ptr ds:[WindPar],bit3 ; je rychlovyhled†v†n° ?
         jnz       EditSMn3                 ; je rychlovyhled†v†n°
         cmp       bx,4b00h                 ; kurzor vlevo ?
         je        EditSMn9                 ; kurzor vlevo
         cmp       bx,1f13h                 ; ^S
         je        EditSMn9
         cmp       bx,4d00h                 ; kurzor vpravo ?
         je        EditSMn9                 ; kurzor vpravo
         cmp       bx,2004h                 ; ^D
         je        EditSMn9

; ------ obsluha kl†vesy BX

EditSMn3:push      si
         mov       ax,es:[AWinKurz]         ; kurzor
         mov       cl,ds:[si+MnuVys]        ; vò®ka okna
         sub       cl,4                     ; odeáten° okrajñ
         mov       ch,0
         mov       dx,es:[AWinSouN]         ; poáet zobrazenòch poloëek celkem
         cmp       bh,MousXKod/HI           ; je k¢d my®i ?
         jne       EditSM32                 ; nen° k¢d my®i
         mov       dx,word ptr ds:[si+MnuPoz] ; ©†dek a pozice menu
EditSM32:mov       si,es:[AWinFrst]         ; prvn° poloëka
         call      EditSMn0                 ; obsluha kl†vesy BX
         xor       bx,bx                    ; p©°znak obslouëen° kl†vesy
         mov       es:[AWinKurz],ax         ; novò kurzor
         mov       es:[AWinFrst],si         ; nov† prvn° poloëka
         pop       si

; ------ omezen° dÇlky bufferu rychlovyhled†v†n°

         cmp       byte ptr ds:[QSrcNum],8  ; maxim†ln° dÇlka textu
         jbe       EditSMn4
         mov       byte ptr ds:[QSrcNum],8  ; omezen° dÇlky textu

; ------ zobrazen° okna, pokud byla kl†vesa obslouëena

EditSMn4:or        bx,bx                    ; byla kl†vesa obslouëena ?
         jnz       EditSMn9                 ; kl†vesa nebyla obslouëena
         call      far ptr DispMnu          ; novÇ zobrazen° okna

; ------ n†vrat registrñ

EditSMn9:pop       es
         pop       bp
         pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

EditSMnu ENDP

EditSMn0:call      far ptr JumpBX           ; skok na obsluhu podle kl†vesy

         dw        5000h,AWinDown           ; Down - posun o ©†dek dolñ
         dw        2d18h,AWinDown           ; ^X - posun o ©†dek dolñ
         dw        4800h,AWinUp             ; Up - posun o ©†dek nahoru
         dw        1205h,AWinUp             ; ^E - posun o ©†dek nahoru
         dw        4700h,AWinHome           ; Home - posun na zaá†tek okna
         dw        4f00h,AWinEnd            ; End - posun na konec okna
         dw        8400h,AWinHome           ; ^PageUp - posun na zaá†tek okna
         dw        7600h,AWinEnd            ; ^PageDown - posun na konec okna
         dw        4900h,EdSMPgUp           ; PageUp - posun o str†nku nahoru
         dw        1312h,EdSMPgUp           ; ^R - posun o str†nku nahoru
         dw        5100h,EdSMPgDn           ; PageDown - posun o str†nku dolñ
         dw        2e03h,EdSMPgDn           ; ^C - posun o str†nku dolñ
         dw        7700h,AWinHome           ; ^Home - posun na zaá†tek okna
         dw        7500h,AWinEnd            ; ^End - posun na konec okna
         dw        1117h,AWinCW             ; ^W - rolov†n° okna o ©†dek dolñ
         dw        2c1ah,AWinCZ             ; ^Z - rolov†n° okna o ©†dek nahoru
         dw        8d00h,AWinCUp            ; ^Up - posun o 6 ©†dkñ nahoru
         dw        9100h,AWinCDwn           ; ^Down - posun o 6 ©†dkñ dolñ
         dw        1f13h,AWinQLft           ; ^S vlevo
         dw        2004h,AWinQRgh           ; ^D vpravo
         dw        4b00h,AWinQLft           ; kurzor vlevo
         dw        4d00h,AWinQRgh           ; kurzor vpravo
         dw        9b00h,AWinQLft           ; Alt-vlevo
         dw        9d00h,AWinQRgh           ; Alt-vpravo
         dw        0e08h,AWinQLft           ; BS
         dw        2308h,AWinQLft           ; ^H
         dw        0e00h,AWinQLft           ; Alt-BS
         dw        0a000h,AWinADwn          ; Alt-dolñ
         dw        9800h,AWinAUp            ; Alt-nahoru
         dw        9700h,AWinAHom           ; Alt-Home
         dw        9f00h,AWinAEnd           ; Alt-End
         dw        MousXKod+MousXLP,AWinMous ; stisk levÇho tlaá°tka my®i
         dw        MousXKod+MousXLH,AWinMous ; drëen° levÇho tlaá°tka my®i
         dw        MousXKod+MousXMov,AWinMous ; veden° kurzoru my®°

         dw        0,EditAWE0

; ------ str†nka nahoru

EdSMPgUp:dec       dx                       ; posledn° poloëka
         cmp       ax,dx                    ; je posledn° poloëka ?
         jne       EdSMPgU2                 ; nen° posledn° poloëka
         dec       ax                       ; korekce kurzoru
EdSMPgU2:dec       cx                       ; poáet ©†dkñ k posunu
         cmp       cx,si                    ; zbòv† mÇnà ©†dkñ ?
         jbe       EdSMPgU4                 ; je v°ce ©†dkñ
         mov       cx,si                    ; omezen° poátu ©†dkñ
EdSMPgU4:jcxz      EdSMPgU5                 ; je jië zaá†tek okna
         sub       si,cx                    ; posun poá†tku
         sub       ax,cx                    ; posun kurzoru
         ret

EdSMPgU5:xor       ax,ax                    ; kurzor na zaá†tek okna
         ret

; ------ str†nka dolñ

EdSMPgDn:dec       cx
         or        dx,dx                    ; je nàjak† poloëka ?
         jz        EdSMPgD8                 ; nen° ë†dn† poloëka
         or        ax,ax                    ; je prvn° poloëka ?
         jnz       EdSMPgD2                 ; nen° prvn° poloëka
         inc       ax                       ; zvò®en° kurzoru
EdSMPgD2:mov       bx,dx                    ; BX <- poáet poloëek
         dec       bx                       ; posledn° poloëka
         sub       bx,cx                    ; prvn° zobrazen† poloëka
         jnc       EdSMPgD4                 ; nen° podteáen°
         xor       bx,bx                    ; omezen° poá†tku
EdSMPgD4:sub       bx,si                    ; je jië zobrazen konec ?
         jbe       EdSMPgD9                 ; je jië zobrazen konec
         cmp       cx,bx                    ; zbòv† v°ce ©†dkñ ?
         jbe       EdSMPgD6                 ; zbòv† v°ce ©†dkñ
         mov       cx,bx                    ; omezen° poátu ©†dkñ
EdSMPgD6:add       si,cx                    ; posun poá†tku
         add       ax,cx                    ; posun kurzoru
EdSMPgD8:ret

EdSMPgD9:mov       ax,dx
         dec       ax
         ret

; ------ veden° kurzoru my®°

AWinMous:mov       al,byte ptr ds:[MousePoz+1] ; ©†dek kurzoru my®i
         sub       al,dh                    ; offset od zaá†tku okna
         sub       al,3                     ; bez horn°ho okraje
         jns       AWinMou1
         mov       al,0
AWinMou1:cmp       al,cl
         jb        AWinMou2
         mov       al,cl
         dec       ax
AWinMou2:cbw                                ; konverze na slovo
         add       ax,si                    ; p©iáten° poá†teán° poloëky
         ret

; ------ obsluha rychlovyhled†v†n°

EditAWE0:call      EditAWE2                 ; obsluha rychlovyhled†v†n°
         or        bx,bx                    ; byla kl†vesa obslouëena ?
         jz        EdiAWE01                 ; kl†vesa byla obslouëena

         pop       ax                       ; zru®en° n†vratovÇ adresy
         pop       si                       ; n†vrat SI
         jmp       EditSMn9                 ; kl†vesa neobslouëena

EdiAWE01:ret

; -----------------------------------------------------------------------------
;        obsluha rychlovyhled†v†n°
; -----------------------------------------------------------------------------

EditAWE1:call      EditAWE2                 ; obsluha rychlovyhled†v†n°
         or        bx,bx                    ; byla kl†vesa obslouëena ?
         jz        EdtAWE11                 ; kl†vesa byla obslouëena

         pop       ax                       ; zru®en° n†vratovÇ adresy
         jmp       EditAWn9                 ; neobslouëen† kl†vesa

EdtAWE11:ret


EditAWE2 PROC      NEAR

; ------ test, zda je kl†vesa pro rychlovyhled†v†n°

         mov       di,offset TabScan        ; tabulka SCAN k¢dñ kl†ves
         cmp       bl,0
         je        EditAWE3                 ; je kl†vesa s ALT-

         cmp       bl," "
         jb        EditAWE4
         test      byte ptr ds:[WindPar],bit3 ; prob°h† rychlovyhled†v†n° ?
         jnz       EditAWE6                 ; je rychlovyhled†v†n°
         jmp       short EditAWE4

EditAWE3:cmp       bh,ds:[di]
         je        EditAWE5
         inc       di
         inc       di
         cmp       byte ptr ds:[di],0
         jne       EditAWE3

EditAWE4:ret                                ; neobslouëen† kl†vesa

; ------ zah†jen° editace

EditAWE5:mov       bl,ds:[di+1]             ; ASCII hodnota znaku
         or        byte ptr ds:[WindPar],bit3 ; zah†jen° reëimu rychlovyhled.

; ------ oprava znaku "/" na "?"

EditAWE6:cmp       bl,"/"
         jne       EditAW61
         mov       bl,"?"

; ------ konverze na velkÇ p°smeno

EditAW61:cmp       bl,"a"
         jb        EditAW62
         cmp       bl,"z"
         ja        EditAW62
         sub       bl,32                    ; konverze na velkÇ p°smeno

; ------ doplnàn° otazn°kñ, je-li zad†na teáka

EditAW62:cmp       bl,"."
         jne       EditAW64
EditAW63:cmp       byte ptr ds:[QSrcNum],8
         jae       EditAW68
         mov       bl,"?"
         call      QSrcChr                  ; uloëen° znaku do bufferu
         jmp       short EditAW63

EditAW64:call      QSrcChr                  ; uloëen° znaku do bufferu
         jc        EditAW68                 ; buffer je jië plnò

         push      es
         xchg      ax,bx                    ; BX <- á°slo kurzoru
         call      far ptr GetPolDI         ; adresa poloëky
         mov       dl,es:[di+FileAtr]       ; atributy
         mov       dh,es:[di+FileTLev]      ; hladina adres†©e, je-li strom
         xchg      ax,bx
         pop       es

         test      byte ptr es:[AWinPrm1],bit4 ; je strom ?
         jz        EditAW65                 ; nen° strom
         or        dh,dh                    ; je ROOT ?
         jnz       EditAW65                 ; nen° ROOT
         mov       dh,1                     ; n†hradn° hladina, je-li ROOT

EditAW65:and       dl,DIR                   ; poëadovan† sekce
         call      QSrcFnd                  ; vyhled†n° poloëky
         jnc       EditAW68                 ; poloëka nalezena OK

         mov       dh,0                     ; hladina adres†©e se nerozli®uje
         xor       dl,DIR                   ; druhò atribut
         call      QSrcFnd                  ; vyhled†n° poloëky v druhÇ sekci
         jnc       EditAW68                 ; poloëka nalezena OK

         dec       byte ptr ds:[QSrcNum]    ; zru®en° posledn°ho zadanÇho znaku
         call      QSrcChr                  ; uloëen° znaku do bufferu
         dec       byte ptr ds:[QSrcNum]    ; n†vrat minulÇho znaku

EditAW68:xor       bx,bx                    ; p©°znak obslouëenÇ kl†vesy
         ret

EditAWE2 ENDP

EditAWE  ENDP

; -----------------------------------------------------------------------------
;        uloëen° znaku BL do bufferu rychlovyhled†v†n° (-> BL pñvodn° znak)
; -----------------------------------------------------------------------------

QSrcChr  PROC      NEAR

         push      ax

         xchg      ax,bx
         mov       bl,ds:[QSrcNum]
         mov       bh,0
         cmp       bl,11
         cmc
         jc        QSrcChr2
         xchg      al,ds:[bx+QSrcBuff]
         inc       byte ptr ds:[QSrcNum]
QSrcChr2:xchg      ax,bx

         pop       ax
         ret

QSrcChr  ENDP

; -----------------------------------------------------------------------------
;        ukonáen° rychlovyhled†v†n° ESC
; -----------------------------------------------------------------------------

AWinEsc  PROC      NEAR

         push      cs
         call      near ptr QSrcEnd
         ret

AWinEsc  ENDP

; *****************************************************************************
;                                 QSrcEnd
;                     ukonáen° reëimu rychlovyhled†v†n°
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

QSrcEnd  PROC      FAR

         test      byte ptr ds:[WindPar],bit3 ; je rychlovyhled†v†n° ?
         jz        QSrcEnd2                 ; nen° rychlovyhled†v†n°

         mov       byte ptr ds:[QSrcNum],0  ; zru®en° obsahu bufferu
         and       byte ptr ds:[WindPar],not bit3 ; zru®en° p©°znaku
         call      far ptr DispAAWn         ; novÇ zobrazen° aktivn°ho okna

QSrcEnd2:ret

QSrcEnd  ENDP

; -----------------------------------------------------------------------------
;        vyhled†n° poloëky p©i rychlovyhled†n°
; -----------------------------------------------------------------------------
; VSTUP: ES,BP=segment definice okna
;        DL=poëadovanò atribut DIR
;        DH=poëadovan† hladina stromu 1.. (0=nerozli®uje se - je druhò pokus)
;        DS=datovò segment
; VùSTUP: AX=nov† aktivn° poloëka, p©i nenalezen° je AX nezmànàn
;         CY=poloëka nenalezena (AX nezmànàno)
; -----------------------------------------------------------------------------
; zniáenÇ registry: CX, DI
; -----------------------------------------------------------------------------
;˛
QSrcFnd  PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      si
         push      ax

; ------ p©°prava registrñ

         cld
         mov       ah,es:[AWinPrm1]         ; parametry okna (bit4=strom)
         mov       ch,0
         mov       cl,ds:[QSrcNum]          ; poáet znakñ k porovn†n°
         mov       bx,-1                    ; ukazatel poloëky
         or        dh,dh                    ; je druhò pokus o hled†n° ?
         jz        QSrcFnd4                 ; je druhò pokus o hled†n°

; ------ nalezen° vòchoz° poloëky pro okno stromu

         test      ah,bit4                  ; je okno stromu ?
         jz        QSrcFnd2                 ; nen° okno stromu
         mov       bx,es:[AWinKurz]         ; kurzor
         or        bx,bx                    ; je ROOT ?
         jnz       QSrcFnd1                 ; nen° ROOT
         inc       bx                       ; p©eskoáen° ROOT
QSrcFnd1:dec       bx                       ; sn°ëen° ukazatele poloëky
         mov       es,bp                    ; adresa definice okna
         call      far ptr GetPolDI         ; adresa dal®° poloëky
         jc        QSrcFnd4                 ; nen° dal®° poloëka
         cmp       dh,es:[di+FileTLev]      ; nalezena nië®° hladina ?
         ja        QSrcFnd4                 ; nalezena nië®° hladina OK
         jmp       short QSrcFnd1           ; hled†n° dal®° poloëky

; ------ nalezen° vòchoz° poloëky pro okno hled†n°

QSrcFnd2:test      ah,bit5                  ; je okno seznamu ?
         jz        QSrcFnd4                 ; nen° okno seznamu
         mov       bx,es:[AWinKurz]         ; kurzor
         inc       bx
QSrcFnd3:dec       bx                       ; sn°ëen° ukazatele poloëky
         mov       es,bp                    ; adresa definice okna
         call      far ptr GetPolDI         ; adresa dal®° poloëky
         jc        QSrcFnd4                 ; nen° dal®° poloëka
         test      byte ptr es:[di+FileAtr],ATRT ; je to cesta ?
         jnz       QSrcFnd3                 ; nalezen° cesty

; ------ adresa dal®° poloëky

QSrcFnd4:jcxz      QSrcFnd9                 ; nen° ë†dn† poloëka
QSrcFn41:inc       bx                       ; zvò®en° ukazatele poloëky
         mov       es,bp                    ; ES <- adresa definice okna
         call      far ptr GetPolDI         ; adresa poloëky
         jc        QSrcFnd9                 ; jsou jië v®echny poloëky

; ------ test platnosti poloëky pro strom

         test      ah,bit4                  ; je okno stromu ?
         jz        QSrcFn44                 ; nen° okno stromu
         or        dh,dh                    ; rozli®uj° se podm°nky ?
         jz        QSrcFnd5                 ; podm°nky se nerozli®uj°
         cmp       dh,es:[di+FileTLev]      ; je to hledan† hladina ?
         je        QSrcFnd5                 ; hladina je OK
         ja        QSrcFnd9                 ; je jië konec vàtve
         jmp       short QSrcFn41           ; dal®° poloëka

; ------ test platnosti poloëky pro hled†n°

QSrcFn44:test      ah,bit5                  ; je okno hled†n° ?
         jz        QSrcFn48                 ; nen° okno hled†n°
         or        dh,dh                    ; rozli®uj° se podm°nky ?
         jz        QSrcFnd5                 ; podm°nky se nerozli®uj°
         test      byte ptr es:[di+FileAtr],ATRT ; je to platn† poloëka ?
         jz        QSrcFnd9                 ; je konec skupiny - konec
         jmp       short QSrcFnd5           ; poloëka vyhovuje OK

; ------ test platnosti poloëky pro adres†©

QSrcFn48:mov       al,es:[di+FileAtr]       ; atribut poloëky
         test      al,ATRT                  ; je to platn† poloëka ?
         jz        QSrcFn41                 ; nen° platn† poloëka - dal®°
         and       al,DIR
         cmp       al,dl                    ; je poëadovanò atribut ?
         jne       QSrcFn41                 ; nen° poëadovanò atribut

; ------ porovn†n° jmÇna poloëky ES:DI

QSrcFnd5:cld
         push      cx                       ; dÇlka textu rychlovyhled†v†n°
         mov       si,offset QSrcBuff       ; buffer k porovn†n°
         inc       di                       ; zaá†tek jmÇna poloëky
QSrcFnd6:lodsb                              ; znak z bufferu
         inc       di                       ; zvò®en° ukazatele pro znak "?"
         cmp       al,"?"                   ; je n†hradn° znak "?" ?
         je        QSrcFnd7                 ; je n†hradn° znak "?"
         dec       di                       ; ukazatel na znak jmÇna
         scasb                              ; je to spr†vnò znak ?
QSrcFnd7:loope     QSrcFnd6                 ; p©i shodà porovn†n° dal®°ho znaku
         pop       cx
         jne       QSrcFn41                 ; jmÇno poloëky nesouhlas°

; ------ n†vrat registrñ, je-li poloëka nalezena OK

QSrcFnd8:mov       es,bp
         xchg      ax,bx                    ; AX <- nalezen† poloëka
         pop       si
         pop       si
         pop       bx
         clc                                ; p©°znak nalezen° poloëky
         ret

; ------ poloëka nenalezena - pro strom je®tà pokus od kurzoru dolñ

QSrcFnd9:mov       es,bp
;         or        dh,dh                    ; je druhò pokus ?
;         jz        QSrcFn96                 ; je druhò pokus
;         test      byte ptr es:[AWinPrm1],bit4 ; je to okno stromu ?
;         jz        QSrcFn96                 ; nen° to okno stromu
;
;         mov       dh,0                     ; p©°znak, ëe se nerozli®uje hladina
;         mov       bx,es:[AWinKurz]         ; kurzor
;         jmp       short QSrcFnd4           ; dal®° pokus

; ------ n†vrat registrñ, nen°-li poloëka nalezena

QSrcFn96:pop       ax
         pop       si
         pop       bx
         stc                                ; p©°znak chyby - nenalezeno
         ret

QSrcFnd  ENDP

; -----------------------------------------------------------------------------
;        Alt-nahoru
; -----------------------------------------------------------------------------

AWinAUp  PROC      NEAR

         push      si
         push      ax

         mov       bx,ax                    ; kurzor
         cld
         mov       ch,0

         mov       es,bp                    ; adresa okna
         call      far ptr GetPolDI         ; adresa poloëky kurzoru
         jc        AWinAU12                 ; nen° dal®° poloëka
         test      byte ptr es:[di+FileAtr],ATRT ; je to cesta ?
         jnz       AWinAUp1                 ; nen° to cesta

AWinAU02:dec       bx                       ; sn°ëen° ukazatele
         mov       es,bp                    ; adresa okna
         call      far ptr GetPolDI         ; adresa dal®° poloëky
         jc        AWinAU12                 ; nen° dal®° poloëka
         test      byte ptr es:[di+FileAtr],ATRT ; je to zase cesta ?
         jnz       AWinAU02                 ; nalezen° cesty
         jmp       short AWinAUp9           ; poloëka je platn†

AWinAUp1:mov       es,bp
         dec       bx                       ; sn°ëen° ukazatele poloëky
         jns       AWinAUp2

AWinAU12:pop       ax
         pop       si
         ret

AWinAUp2:call      far ptr GetPolDI         ; adresa poloëky

         test      byte ptr ds:[WindPar],bit3
         jnz       AWinAUp3                 ; je rychlovyhled†v†n°
         test      byte ptr es:[di+FileAtr],ATRT ; je to platn† poloëka ?
         jz        AWinAUp1                 ; nen° to platn† poloëka
         test      byte ptr es:[di+FileAtr],ATRO ; je oznaáen† poloëka ?
         jnz       AWinAUp9                 ; nalezena oznaáen† poloëka
         jmp       short AWinAUp1

AWinAUp3:mov       cl,ds:[QSrcNum]          ; poáet znakñ k porovn†n°
         jcxz      AWinAUp9                 ; nen° ë†dn† poloëka - nalezeno OK

         mov       si,offset QSrcBuff       ; buffer k porovn†n°
         inc       di
AWinAUp4:lodsb
         inc       di
         cmp       al,"?"
         je        AWinAUp5
         dec       di
         scasb
AWinAUp5:loope     AWinAUp4
         jne       AWinAUp1

AWinAUp9:mov       ax,bx                    ; AX <- nalezen† poloëka
         mov       es,bp
         pop       si
         pop       si
         ret

AWinAUp  ENDP

; -----------------------------------------------------------------------------
;        Alt-Home
; -----------------------------------------------------------------------------

AWinAHom PROC      NEAR

         push      si
         cld
         mov       ch,0

         xchg      bx,ax                    ; BX <- £schova kurzoru
         mov       ax,es:[AWinSouN]         ; p©ednastaven° kurzoru

AWinAHm1:mov       dx,ax                    ; £schova nalezenÇ poloëka
AWinAHm2:mov       es,bp
         dec       ax                       ; sn°ëen° ukazatele poloëky
         js        AWinAHm6                 ; jsou jië v®echny poloëky

         mov       bx,ax
         call      far ptr GetPolDI         ; adresa poloëky

         test      byte ptr ds:[WindPar],bit3 ; je rychlovyhled†v†n° ?
         jnz       AWinAHm3                 ; je rychlovyhled†v†n°
         test      byte ptr es:[di+FileAtr],ATRT ; je to platn† poloëka ?
         jz        AWinAHm2                 ; nen° to platn† poloëka
         test      byte ptr es:[di+FileAtr],ATRO ; je oznaáen† poloëka ?
         jnz       AWinAHm1                 ; nalezena oznaáen† poloëka
         jmp       short AWinAHm2

AWinAHm3:mov       cl,ds:[QSrcNum]          ; poáet znakñ k porovn†n°
         jcxz      AWinAHm1                 ; nen° ë†dn† poloëka - nalezeno OK

         mov       si,offset QSrcBuff       ; buffer k porovn†n°
         push      ax
         inc       di
AWinAHm4:lodsb
         inc       di
         cmp       al,"?"
         je        AWinAHm5
         dec       di
         scasb
AWinAHm5:loope     AWinAHm4
         pop       ax
         jne       AWinAHm2
         jmp       short AWinAHm1

AWinAHm6:mov       es,bp
         xchg      ax,dx                    ; AX <- nalezen† poloëka
         cmp       ax,es:[AWinSouN]         ; byla nalezena platn† poloëka ?
         jb        AWinAHm7                 ; byla nalezena platn† poloëka OK
         xchg      ax,bx                    ; AX <- n†vrat pñvodn°ho kurzoru

AWinAHm7:pop       si
         ret

AWinAHom ENDP

; ------ zmàna oznaáen° p©i rychlovyhled†v†n°

AWinIns0 PROC      NEAR

         mov       bx,ax                    ; BX <- á°slo poloëky pod kurzorem
         push      cs
         call      near ptr InvSPol         ; inverze oznaáen° poloëky pod kurzorem
                                          ;* n†sleduje posun kurzoru dolñ !
AWinIns0 ENDP

; -----------------------------------------------------------------------------
;        Alt-dolñ
; -----------------------------------------------------------------------------

AWinADwn PROC      NEAR

         push      si
         push      ax

         mov       bx,ax                    ; kurzor
         cld
         mov       ch,0

         mov       es,bp                    ; adresa okna
         call      far ptr GetPolDI         ; adresa poloëky kurzoru
         jc        AWinAD12                 ; nen° dal®° poloëka
         test      byte ptr es:[di+FileAtr],ATRT ; je to cesta ?
         jnz       AWinADn1                 ; nen° to cesta

AWinAD02:inc       bx                       ; zvò®en° ukazatele
         mov       es,bp                    ; adresa okna
         call      far ptr GetPolDI         ; adresa dal®° poloëky
         jc        AWinAD12                 ; nen° dal®° poloëka
         test      byte ptr es:[di+FileAtr],ATRT ; je to zase cesta ?
         jnz       AWinAD02                 ; nalezen° cesty
         jmp       short AWinADn9           ; poloëka je platn†

AWinADn1:mov       es,bp
         inc       bx                       ; zvò®en° ukazatele poloëky
         cmp       bx,es:[AWinSouN]         ; jsou jië v®echny poloëky ?
         jb        AWinADn2

AWinAD12:pop       ax
         pop       si
         ret

AWinADn2:call      far ptr GetPolDI         ; adresa poloëky

         test      byte ptr ds:[WindPar],bit3
         jnz       AWinADn3                 ; je rychlovyhled†v†n°
         test      byte ptr es:[di+FileAtr],ATRT ; je to platn† poloëka ?
         jz        AWinADn1                 ; nen° to platn† poloëka
         test      byte ptr es:[di+FileAtr],ATRO ; je oznaáen† poloëka ?
         jnz       AWinADn9                 ; nalezena oznaáen† poloëka
         jmp       short AWinADn1

AWinADn3:mov       cl,ds:[QSrcNum]          ; poáet znakñ k porovn†n°
         jcxz      AWinADn9                 ; nen° ë†dn† poloëka - nalezeno OK

         mov       si,offset QSrcBuff       ; buffer k porovn†n°
         inc       di
AWinADn4:lodsb
         inc       di
         cmp       al,"?"
         je        AWinADn5
         dec       di
         scasb
AWinADn5:loope     AWinADn4
         jne       AWinADn1

AWinADn9:mov       ax,bx                    ; AX <- nalezen† poloëka
         mov       es,bp
         pop       si
         pop       si
         ret

AWinADwn ENDP

; -----------------------------------------------------------------------------
;        Alt-End
; -----------------------------------------------------------------------------

AWinAEnd PROC      NEAR

         push      si
         cld
         mov       ch,0

         xchg      bx,ax                    ; BX <- £schova kurzoru
         mov       ax,-1                    ; p©ednastaven° kurzoru
AWinAEn1:mov       dx,ax                    ; £schova nalezenÇ poloëky
AWinAEn2:mov       es,bp
         inc       ax                       ; zvò®en° ukazatele poloëky
         cmp       ax,es:[AWinSouN]         ; jsou jië v®echny poloëky ?
         jae       AWinAEn6

         xchg      ax,bx
         call      far ptr GetPolDI         ; adresa poloëky
         xchg      ax,bx

         test      byte ptr ds:[WindPar],bit3
         jnz       AWinAEn3                 ; je rychlovyhled†v†n°
         test      byte ptr es:[di+FileAtr],ATRT ; je to platn† poloëka ?
         jz        AWinAEn2                 ; nen° to platn† poloëka
         test      byte ptr es:[di+FileAtr],ATRO ; je oznaáen† poloëka ?
         jnz       AWinAEn1                 ; nalezena oznaáen† poloëka
         jmp       short AWinAEn2

AWinAEn3:mov       cl,ds:[QSrcNum]          ; poáet znakñ k porovn†n°
         jcxz      AWinAEn1                 ; nen° ë†dn† poloëka - nalezeno OK

         mov       si,offset QSrcBuff       ; buffer k porovn†n°
         push      ax
         inc       di
AWinAEn4:lodsb
         inc       di
         cmp       al,"?"
         je        AWinAEn5
         dec       di
         scasb
AWinAEn5:loope     AWinAEn4
         pop       ax
         jne       AWinAEn2
         jmp       short AWinAEn1

AWinAEn6:xchg      ax,dx                    ; AX <- nalezen† poloëka
         or        ax,ax                    ; nalezena nàjak† platn† poloëka ?
         jns       AWinAEn7                 ; poloëka je platn† OK
         xchg      ax,bx                    ; AX <- n†vrat pñvodn°ho kurzoru
AWinAEn7:mov       es,bp
         pop       si
         ret

AWinAEnd ENDP

; -----------------------------------------------------------------------------
;        oznaáen° v®ech souborñ
; -----------------------------------------------------------------------------

AWinSet  PROC      NEAR

         mov       dl,bit0                  ; oznaáen°
         jmp       short AWinInv1

AWinSet  ENDP

; -----------------------------------------------------------------------------
;        zru®en° oznaáen° v®ech souborñ a adres†©ñ
; -----------------------------------------------------------------------------

AWinRes  PROC      NEAR

         mov       dx,bit4*HI + bit1        ; nulov†n°, adres†©e vëdy
         cmp       word ptr es:[AWinSNum],0 ; jsou oznaáenÇ soubory ?
         jne       AWinInv2                 ; jsou oznaáenÇ soubory
         call      far ptr TestNAWn         ; je neaktivn° okno zapnuto ?
         jc        AWinInv2                 ; nen° zapnuto

         push      es
         push      bp
         call      far ptr GetNAWin         ; poskytnut° adresy neaktivn°ho okna
         mov       bp,es
         call      AWinInv2                 ; odznaáen° neaktivn°ho okna
         pop       bp
         pop       es
         jmp       short AWinInv1

AWinRes  ENDP

; -----------------------------------------------------------------------------
;        inverze oznaáen° v®ech souborñ
; -----------------------------------------------------------------------------

AWinInv  PROC      NEAR

         mov       dl,bit2                  ; inverze

; ------ p©°prava k operaci

AWinInv1:mov       dh,es:[AWinPrm1]         ; parametry
AWinInv2:push      cs
         call      near ptr QSrcEnd         ; ukonáen° rychlovyhled†v†n°
         xor       bx,bx                    ; ukazatel á°sla poloëky

; ------ adresa poloëky

AWinInv3:mov       es,bp                    ; ES <- adresa poloëky
         call      far ptr GetPolDI         ; adresa poloëky -> ES:DI
         jc        AWinInv8                 ; nen° dal®° poloëka

; ------ test, zda je poloëka soubor

         test      dh,bit4                  ; je to strom nebo odznaáen° ?
         jnz       AWinInv4                 ; je to strom nebo odznaáen°
         test      byte ptr es:[di+FileAtr],DIR ; je to adres†© ?
         jnz       AWinInv5                 ; adres†© se neoznaáuje

; ------ oznaáen° poloëky

AWinInv4:push      cs
         call      near ptr SelPol          ; oznaáen° poloëky (á°slo BX,adr.BP)

; ------ p©°prava pro dal®° poloëku

AWinInv5:inc       bx                       ; zvò®en° ukazatele poloëek
         jmp       short AWinInv3           ; dal®° poloëka

AWinInv8:mov       es,bp                    ; n†vrat ES
         ret

AWinInv  ENDP

; -----------------------------------------------------------------------------
;        oznaáen° poloëky pod kurzorem
; -----------------------------------------------------------------------------

AWinStF  PROC      NEAR

         push      dx
         mov       dl,bit0                  ; oznaáen° poloëky pod kurzorem
         jmp       short AWinIns1

AWinStF  ENDP

; -----------------------------------------------------------------------------
;        odznaáen° poloëky pod kurzorem
; -----------------------------------------------------------------------------

AWinRsF  PROC      NEAR

         push      dx
         mov       dl,bit1                  ; odznaáen° poloëky
         jmp       short AWinIns1

AWinRsF  ENDP

; -----------------------------------------------------------------------------
;        zmàna oznaáen° poloëky pod kurzorem
; -----------------------------------------------------------------------------

AWinIns  PROC      NEAR

         push      dx
         mov       dl,bit2                  ; zmàna oznaáen° poloëky

; ------ adresa poloëky

AWinIns1:mov       bx,ax                    ; BX <- á°slo poloëky pod kurzorem
         call      far ptr GetPolDI         ; adresa poloëky -> ES:DI
         jc        AWinIns7                 ; nen° platn† poloëka

; ------ test, zda je cesta

         test      byte ptr es:[di+FileAtr],ATRT ; je to platn† poloëka ?
         jnz       AWinIns5                 ; je to platn† poloëka

; ------ kurzor je na cestà - proveden° operace pro podadres†©

AWinIns2:inc       bx                       ; zvò®en° ukazatele poloëek
         mov       es,bp                    ; ES <- adresa okna
         call      far ptr GetPolDI         ; adresa poloëky -> ES:DI
         jc        AWinIns3                 ; nen° dal®° poloëka
         test      byte ptr es:[di+FileAtr],ATRT ; je to platn† poloëka ?
         jz        AWinIns4                 ; nen° dal®° poloëka
         push      cs
         call      near ptr SelPol          ; oznaáen° poloëky
         jmp       short AWinIns2           ; dal®° poloëka

AWinIns3:xchg      ax,bx                    ; BX <- pñvodn° kurzor
AWinIns4:pop       dx                       ; n†vrat DX
         xchg      ax,bx                    ; AX <- novò kurzor
         mov       es,bp                    ; n†vrat ES
         ret

; ------ n†hradn° funkce pro poloëku ".." (neposune kurzor !)

AWinIns5:cmp       byte ptr es:[di+FileName],"." ; je poloëka ".." ?
         jne       AWinIns6                 ; nen° poloëka ".."
         pop       di                       ; zru®en° registru DX v z†sobn°ku
         mov       dh,bit4                  ; fale®nò typ okna - strom
         mov       es,bp                    ; n†vrat ES
         jmp       AWinInv2                 ; n†hradn° funkce pro poloëku ".."

; ------ zmàna oznaáen° poloëky pod kurzorem

AWinIns6:push      cs
         call      near ptr SelPol          ; oznaáen° poloëky

; ------ posun kurzoru

AWinIns7:pop       dx
         mov       es,bp                    ; n†vrat ES
         jmp       AWinDown                 ; posun kurzoru

AWinIns  ENDP

; -----------------------------------------------------------------------------
;        zmàna oznaáen° programñ Ctrl-^
; -----------------------------------------------------------------------------

AWinPrg  PROC      NEAR

; ------ ukonáen° rychlovyhled†v†n°, £schova registrñ

         push      cs
         call      near ptr QSrcEnd         ; ukonáen° rychlovyhled†v†n°
         push      si                       ; £schova SI

; ------ adresa dal®° poloëky

         xor       bx,bx                    ; BX <- 0 ukazatel á°sla poloëky
AWinPrg1:mov       es,bp                    ; ES <- adresa okna
         call      far ptr GetESPol         ; adresa poloëky
         jc        AWinPrg9                 ; jsou jië v®echny poloëky

; ------ test, zda je poloëka program

         call      far ptr TestProg         ; test, zda je poloëka program
         jne       AWinPrg2                 ; nen° to program

; ------ inverze oznaáen° poloëky

         mov       es,bp
         call      far ptr InvSPol          ; inverze oznaáen° poloëky

; ------ p©°prava pro dal®° poloëku

AWinPrg2:inc       bx                       ; zvò®en° ukazatele poloëek
         jmp       short AWinPrg1           ; dal®° poloëka

; ------ n†vrat registrñ

AWinPrg9:pop       si                       ; n†vrat SI
         ret

AWinPrg  ENDP

; -----------------------------------------------------------------------------
;        obnoven° oznaáen° poloëek Ctrl-]
; -----------------------------------------------------------------------------

AWinObn  PROC      NEAR

; ------ ukonáen° rychlovyhled†v†n°

         push      cs
         call      near ptr QSrcEnd         ; ukonáen° rychlovyhled†v†n°

; ------ adresa dal®° poloëky

         xor       bx,bx                    ; BX <- 0 ukazatel á°sla poloëky
AWinObn1:mov       es,bp                    ; ES <- adresa okna
         call      far ptr GetPolDI         ; adresa poloëky -> ES:DI
         jc        AWinObn9                 ; jsou jië v®echny poloëky

; ------ test, zda je £schova oznaáen°

         test      byte ptr es:[di+FileAtr],ATRU ; je uschovanÇ oznaáen° ?
         jz        AWinObn2                 ; nen° uschovanÇ oznaáen°

; ------ oznaáen° poloëky

         mov       es,bp                    ; adresa okna
         call      far ptr SetSPol          ; oznaáen° poloëky

; ------ p©°prava pro dal®° poloëku

AWinObn2:inc       bx                       ; zvò®en° ukazatele poloëek
         jmp       short AWinObn1           ; dal®° poloëka

AWinObn9:ret

AWinObn  ENDP

; -----------------------------------------------------------------------------
;        rolov†n° okna o ©†dek nahoru
; -----------------------------------------------------------------------------

AWinCZ   PROC      NEAR

         push      cs
         call      near ptr QSrcEnd         ; ukonáen° rychlovyhled†v†n°

; ------ posun poá†tku okna

         mov       bx,si                    ; poá†tek okna
         add       bx,cx                    ; konec
         cmp       bx,dx                    ; je jië maxim†ln° poá†tek okna ?
         jae       AWinCZ9                  ; maxim†ln° poá†tek - nebude posun
         inc       si                       ; posun poá†tku okna

; ------ posun kurzoru dolñ

         cmp       ax,si                    ; je kurzor jië na poá†tku okna ?
         ja        AWinCZ9                  ; nen° na poá†tku okna - mñëe zñstat
         call      AWinDown                 ; posun kurzoru dolñ
AWinCZ9: ret

AWinCZ   ENDP

; -----------------------------------------------------------------------------
;        rolov†n° okna o ©†dek dolñ
; -----------------------------------------------------------------------------

AWinCW   PROC      NEAR

         push      cs
         call      near ptr QSrcEnd         ; ukonáen° rychlovyhled†v†n°

; ------ posun prvn° poloëky

         or        si,si                    ; je jië poá†tek ?
         jz        AWinCW9                  ; je jië poá†tek
         dec       si                       ; posun poá†tku okna

; ------ posun kurzoru

         mov       bx,si                    ; poá†tek okna
         add       bx,cx
         dec       bx
         cmp       bx,ax                    ; je kurzor za koncem okna ?
         ja        AWinCW9                  ; nen° ke®tà za koncem okna
         call      AWinUp                   ; posun kurzoru
AWinCW9: ret

AWinCW   ENDP

; -----------------------------------------------------------------------------
;        posun o str†nku nahoru
; -----------------------------------------------------------------------------

AWinPgUp PROC      NEAR

         push      cs
         call      near ptr QSrcEnd         ; ukonáen° rychlovyhled†v†n°

; ------ kontrola, zda je jië zaá†tek okna

         or        si,si                    ; je jië zaá†tek okna ?
         je        AWinHome                 ; je jië zaá†tek okna

; ------ posun poá†tku okna

         dec       cx
         dec       cx                       ; dÇlka str†nky
         sub       si,cx                    ; posun poá†tku okna
         jnc       AWinPgU2                 ; nen° p©eteáen°
         xor       si,si                    ; omezen° poá†tku okna

; ------ pozice kurzoru

AWinPgU2:mov       ax,si                    ; nov† prvn° poloëka
         inc       ax                       ; 2. ©†dek okna
         ret

AWinPgUp ENDP

; -----------------------------------------------------------------------------
;        posun na zaá†tek okna
; -----------------------------------------------------------------------------

AWinHome PROC      NEAR

         push      cs
         call      near ptr QSrcEnd         ; ukonáen° rychlovyhled†v†n°

         xor       ax,ax
         ret

AWinHome ENDP

;; -----------------------------------------------------------------------------
;;        posun na horn° okraj okna
;; -----------------------------------------------------------------------------
;
;AWinCHom PROC      NEAR
;
;         push      cs
;         call      near ptr QSrcEnd         ; ukonáen° rychlovyhled†v†n°
;
;         mov       ax,si                    ; poá†tek okna
;         or        ax,ax                    ; je zaá†tek okna ?
;         jz        AWinCHm9                 ; je zaá†tek okna
;         inc       ax                       ; jinak druhò ©†dek okna
;AWinCHm9:ret
;
;AWinCHom ENDP

; -----------------------------------------------------------------------------
;        posun o str†nku dolñ
; -----------------------------------------------------------------------------

AWinPgDn PROC      NEAR

         push      cs
         call      near ptr QSrcEnd         ; ukonáen° rychlovyhled†v†n°

; ------ maxim†ln° prvn° poloëka

         mov       bx,dx                    ; poáet poloëek okna
         sub       bx,cx                    ; maxim†ln° prvn° poloëka
         jbe       AWinEnd                  ; malò poáet souborñ - jako END
         cmp       bx,si                    ; je jië maxim†ln° poloëka ?
         je        AWinEnd                  ; je jië maxim†ln° poloëka

; ------ posun poá†tku okna

         add       si,cx                    ; posun poá†tku
         dec       si
         dec       si                       ; oprava poá†tku

; ------ omezen° poá†tku okna

         cmp       bx,si                    ; je za maxim†ln°m poá†tkem ?
         ja        AWinPgD2                 ; nen°
         mov       si,bx                    ; omezen° poá†tku okna

; ------ posun kurzoru

AWinPgD2:mov       ax,si                    ; nov† prvn° poloëka
         inc       ax                       ; kurzor na 2. ©†dku
         ret

AWinPgDn ENDP

; -----------------------------------------------------------------------------
;        posun na konec seznamu (AX=kurzor, DX=poáet poloëek celkem)
; -----------------------------------------------------------------------------

AWinEnd  PROC      NEAR

         push      cs
         call      near ptr QSrcEnd         ; ukonáen° rychlovyhled†v†n°

         mov       ax,dx                    ; poáet poloëek
         or        ax,ax                    ; je nàjak† poloëka ?
         jz        AWinEnd9                 ; nen° ë†dn† poloëka
         dec       ax                       ; á°slo posledn° poloëky
AWinEnd9:ret

AWinEnd  ENDP

;; -----------------------------------------------------------------------------
;;        posun na spodn° okraj okna (AX=kurzor, DX=poáet poloëek, SI=poá†tek)
;; -----------------------------------------------------------------------------
;
;AWinCEnd PROC      NEAR
;
;         push      cs
;         call      near ptr QSrcEnd         ; ukonáen° rychlovyhled†v†n°
;
;         mov       ax,si                    ; prvn° poloëka
;         add       ax,cx                    ; posun o okno
;         cmp       ax,dx
;         ja        AWinEnd                  ; p©es†hl konec souboru
;         dec       ax                       ; posledn° ©†dek okna
;         jnc       AWinCEn3                 ; byla posledn° poloëka okna
;         dec       ax                       ; p©edposledn° ©†dek okna
;AWinCEn3:ret
;
;AWinCEnd ENDP

; -----------------------------------------------------------------------------
;        posun o 6 ©†dkñ nahoru (AX=kurzor, DX=poáet poloëek celkem)
; -----------------------------------------------------------------------------

AWinCUp  PROC      NEAR

         push      cs
         call      near ptr QSrcEnd         ; ukonáen° rychlovyhled†v†n°

         mov       cx,6
AWinCUp2:call      AWinUp                   ; posun o ©†dek nahoru
         jc        AWinCUp3
         loop      AWinCUp2
AWinCUp3:ret

AWinCUp  ENDP

; -----------------------------------------------------------------------------
;        posun o ©†dek nahoru (AX=kurzor, DX=poáet poloëek celkem, CY=nelze)
; -----------------------------------------------------------------------------

AWinUp   PROC      NEAR

         push      cs
         call      near ptr QSrcEnd         ; ukonáen° rychlovyhled†v†n°

         or        ax,ax                    ; je jië prvn° poloëka ?
         stc
         jz        AWinUp2                  ; je jië prvn° poloëka
         dec       ax                       ; posun poloëky
         clc                                ; p©°znak operace OK
AWinUp2: ret

AWinUp   ENDP

; -----------------------------------------------------------------------------
;        posun o 6 ©†dkñ dolñ (AX=kurzor, DX=poáet poloëek celkem)
; -----------------------------------------------------------------------------

AWinCDwn PROC      NEAR

         push      cs
         call      near ptr QSrcEnd         ; ukonáen° rychlovyhled†v†n°

         mov       cx,6
AWinCDw2:call      AWinDown                 ; posun o ©†dek dolñ
         jc        AWinCDw3
         loop      AWinCDw2                 ; dal®° ©†dek
AWinCDw3:ret

AWinCDwn ENDP

; -----------------------------------------------------------------------------
;        posun o ©†dek dolñ (AX=kurzor, DX=poáet poloëek celkem, CY=nelze)
; -----------------------------------------------------------------------------

AWinDown PROC      NEAR

         push      cs
         call      near ptr QSrcEnd         ; ukonáen° rychlovyhled†v†n°

         inc       ax                       ; zvò®en° kurzoru
         cmp       ax,dx                    ; je jië konec seznamu ?
         cmc
         jnc       AWinDwn2                 ; kurzor je OK
         dec       ax                       ; n†vrat kurzoru
AWinDwn2:ret

AWinDown ENDP

; -----------------------------------------------------------------------------
;        posun kurzoru vlevo (3-sloupce)
; -----------------------------------------------------------------------------

AWinLeft PROC      NEAR

         test      byte ptr ds:[WindPar],bit3 ; je rychlovyhled†v†n° ?
         jnz       AWinQLft                 ; je rychlovyhled†v†n°

; ------ posun kurzoru o sloupec vlevo

AWinLft1:sub       ax,di                    ; posun o sloupec vlevo
         jnc       AWinLft2                 ; kurzor je OK
         xor       ax,ax                    ; omezen° posunu kurzoru

; ------ posun poá†tku o sloupec vlevo

AWinLft2:cmp       ax,si                    ; je kurzor p©ed poá†tkem ?
         ja        AWinLft3                 ; poá†tek okna je OK
         sub       si,di                    ; posun poá†tku okna
         jnc       AWinLft3                 ; poá†tek okna je OK
         xor       si,si                    ; omezen° posunu poá†tku okna
         xor       ax,ax                    ; kurzor na prvn° poloëku v oknà

AWinLft3:ret

AWinLeft ENDP

; -----------------------------------------------------------------------------
;        posun kurzoru vlevo - rychlovyhled†v†n°
; -----------------------------------------------------------------------------

AWinQLft PROC      NEAR

         or        byte ptr ds:[WindPar],bit3 ; zah†jen° rychlovyhled†v†n°
         cmp       byte ptr ds:[QSrcNum],0  ; je jië zaá†tek bufferu ?
         je        AWinQLf4                 ; je jië zaá†tek bufferu
         dec       byte ptr ds:[QSrcNum]    ; sn°ëen° poátu znakñ v bufferu
AWinQLf4:ret

AWinQLft ENDP

; -----------------------------------------------------------------------------
;        posun kurzoru vpravo (3-sloupce)
; -----------------------------------------------------------------------------

AWinRght PROC      NEAR

         test      byte ptr ds:[WindPar],bit3 ; je rychlovyhled†v†n° ?
         jnz       AWinQRgh                 ; je rychlovyhled†v†n°

; ------ posun kurzoru o sloupec vpravo

         add       ax,di                    ; posun o sloupec vpravo
         cmp       ax,dx                    ; p©ekroáen konec ?
         jb        AWinRgh1                 ; kurzor je OK
         mov       ax,dx                    ; omezen° posunu kurzoru
         or        ax,ax                    ; je nàjak† poloëka ?
         jz        AWinRgh1                 ; nen° ë†dn† poloëka
         dec       ax                       ; maxim†ln° poloëka

; ------ posun poá†tku o sloupec vpravo

AWinRgh1:mov       bx,si                    ; poá†tek okna
         add       bx,cx                    ; konec okna
         dec       bx                       ; posledn° poloëka v oknà
         cmp       ax,bx                    ; je kurzor za poá†tkem ?
         jb        AWinRgh2                 ; poá†tek okna je OK
         add       si,di                    ; posun poá†tku okna
         add       bx,di                    ; posun konce okna
         cmp       bx,dx                    ; je jië maxim†ln° konec ?
         jb        AWinRgh2                 ; nen° maxim†ln° konec
         mov       ax,dx                    ; poáet poloëek v oknà
         or        ax,ax                    ; je nàjak† poloëka v oknà ?
         jz        AWinRgh2                 ; nen° ë†dn† poloëka v oknà
         dec       ax                       ; posledn° poloëka v oknà

AWinRgh2:ret

AWinRght ENDP

; -----------------------------------------------------------------------------
;        posun kurzoru vpravo - rychlovyhled†v†n°
; -----------------------------------------------------------------------------

AWinQRgh PROC      NEAR

         or        byte ptr ds:[WindPar],bit3 ; zah†jen° rychlovyhled†v†n°
         cmp       byte ptr ds:[QSrcNum],11 ; je jië konec bufferu ?
         je        AWinQRg4                 ; je jië konec bufferu
         inc       byte ptr ds:[QSrcNum]    ; zvò®en° poátu znakñ v bufferu

         push      es
         xchg      ax,bx                    ; kurzor
         call      far ptr GetPolDI
         mov       dl,es:[di+FileAtr]       ; atributy
         and       dl,DIR                   ; poëadovan† sekce
         mov       dh,es:[di+FileTLev]      ; hladina adres†©e, je-li strom
         xchg      ax,bx
         pop       es

         test      byte ptr es:[AWinPrm1],bit4 ; je strom ?
         jz        AWinQRg3                 ; nen° strom
         or        dh,dh                    ; je ROOT ?
         jnz       AWinQRg3                 ; nen° ROOT
         mov       dh,1                     ; n†hradn° hladina, je-li ROOT

AWinQRg3:call      QSrcFnd                  ; vyhled†n° poloëky
         jnc       AWinQRg4                 ; poloëka nalezena OK

         xor       dl,DIR                   ; druhò atribut
         mov       dh,0                     ; hladina adres†©e se nerozli®uje
         call      QSrcFnd                  ; vyhled†n° poloëky v druhÇ sekci
         jnc       AWinQRg4                 ; poloëka nalezena OK
         dec       byte ptr ds:[QSrcNum]    ; zru®en° posledn°ho zadanÇho znaku

AWinQRg4:ret

AWinQRgh ENDP

; *****************************************************************************
;                      SelPol (adresa v BP), SelPol0 (adresa v ES)
;                               Oznaáen° poloëky
; -----------------------------------------------------------------------------
; VSTUP: BX=á°slo poloëky
;        DL=p©ep°naáe
;               bit 0: oznaáen°
;               bit 1: nulov†n°
;               bit 2: inverze
;  SelPol:  BP=segment definice okna
;  SelPol0: ES=segment definice okna
;
; VùSTUP:CY=nebyla zmàna oznaáen° poloëky
;        ES=segment definice okna
; *****************************************************************************

SelPol   PROC      FAR

; ------ adresa okna

         mov       es,bp                    ; ES <- adresa okna

; ------ oznaáen° poloëky

SelPol0  LABEL     FAR

         test      dl,bit0                  ; m† bòt oznaáen° poloëky ?
         jnz       SetSPol                  ; oznaáen° poloëky

; ------ inverze oznaáen° poloëky

         test      dl,bit2                  ; m† se invertovat oznaáen° ?
         jnz       InvSPol                  ; je inverze oznaáen°
         jmp       near ptr ResSPol         ; nulov†n° oznaáen° poloëky

SelPol   ENDP

; *****************************************************************************
;                                InvSPol
;                   inverze oznaáen° poloëky adres†©e
; -----------------------------------------------------------------------------
; VSTUP: BX=á°slo poloëky
;        ES=segment definice okna
; VùSTUP:CY=nelze zmànit oznaáen° poloëky (je to adres†© "..")
; *****************************************************************************

InvSPol  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      si
         push      es

; ------ adresa poloëky

         call      far ptr GetESPol         ; adresa poloëky
         jc        SetSPol9                 ; neplatn† poloëka

; ------ test, zda je soubor jië oznaáen

         test      byte ptr es:[si+FileAtr],ATRO ; je poloëka jië oznaáen† ?
         jz        SetSPol2                 ; nen° oznaáen† - oznaáen° poloëky
         jmp       short ResSPol2           ; jinak odznaáen° poloëky

InvSPol  ENDP

; *****************************************************************************
;                                  SetSPol
;                        oznaáen° poloëky adres†©e
; -----------------------------------------------------------------------------
; VSTUP: BX=á°slo poloëky
;        ES=segment definice okna
; VùSTUP:CY=poloëku nelze oznaáit (je jië oznaáena nebo je "..")
; *****************************************************************************

SetSPol  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      si
         push      es

; ------ adresa poloëky

         call      far ptr GetESPol         ; adresa poloëky
         jc        SetSPol9                 ; neplatn† poloëka

; ------ kontrola, zda je soubor jië oznaáen

         test      byte ptr es:[si+FileAtr],ATRO ; je poloëka jië oznaáen† ?
         stc
         jnz       SetSPol9                 ; chyba - poloëka je jië oznaáen†

; ------ kontrola, zda je zak†zan† poloëka ".."

SetSPol2:cmp       word ptr es:[si+FileName],".." ; je to adres†© ?
         je        SetSPol3                 ; nelze oznaáit - je adres†© ".."

; ------ kontrola, zda je to cesta

         test      byte ptr es:[si+FileAtr],ATRT ; je to cesta ?
SetSPol3:stc                                ; p©°znak chyby
         jz        SetSPol9                 ; je to cesta - nelze oznaáit

; ------ oznaáen° poloëky

         or        byte ptr es:[si+FileAtr],ATRO ; p©°znak oznaáen° poloëky

; ------ p©iáten° kapacity poloëky

         mov       ax,word ptr es:[si+FileSize] ; velikost LOW
         mov       si,word ptr es:[si+FileSize+2] ; velikost HIGH
         pop       es
         push      es
         add       word ptr es:[AWinSSum],ax   ; zvò®en° kapacity LOW
         adc       word ptr es:[AWinSSum+2],si ; zvò®en° kapacity HIGH
         inc       word ptr es:[AWinSNum]   ; zvò®en° poátu souborñ
         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

SetSPol9:pop       es
         pop       si
         pop       ax
         ret

SetSPol  ENDP

; *****************************************************************************
;                                  ResSPol
;                      zru®en° oznaáen° poloëky adres†©e
; -----------------------------------------------------------------------------
; VSTUP: BX=á°slo poloëky
;        ES=segment definice okna
; VùSTUP:CY=poloëku nelze odznaáit (nen° oznaáena nebo je "..")
; *****************************************************************************

ResSPol  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      si
         push      es

; ------ adresa poloëky

         call      far ptr GetESPol         ; adresa poloëky
         jc        ResSPol9                 ; neplatn† poloëka

; ------ kontrola, zda je soubor oznaáen

         test      byte ptr es:[si+FileAtr],ATRO ; je poloëka oznaáen† ?
         jz        ResSPol3                 ; chyba - poloëka nen° oznaáen†

; ------ kontrola, zda je zak†zan† poloëka ".."

ResSPol2:cmp       word ptr es:[si+FileName],".." ; je to adres†© ?
         je        ResSPol3                 ; nelze oznaáit - je adres†© ".."

; ------ kontrola, zda je to cesta

         test      byte ptr es:[si+FileAtr],ATRT ; je to cesta ?
ResSPol3:stc                                ; p©°znak chyby
         jz        ResSPol9                 ; je to cesta - nelze oznaáit

; ------ odznaáen° poloëky

         and       byte ptr es:[si+FileAtr],not ATRO ; zru®en° p©°znaku oznaáen°

; ------ odeáten° kapacity poloëky

         mov       ax,word ptr es:[si+FileSize]  ; velikost LOW
         mov       si,word ptr es:[si+FileSize+2] ; velikost HIGH
         pop       es
         push      es
         sub       word ptr es:[AWinSSum],ax     ; sn°ëen° kapacity LOW
         sbb       word ptr es:[AWinSSum+2],si   ; sn°ëen° kapacity HIGH
         dec       word ptr es:[AWinSNum]   ; sn°ëen° poátu souborñ
         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

ResSPol9:pop       es
         pop       si
         pop       ax
         ret

ResSPol  ENDP

; *****************************************************************************
;                              InitRows
;            inicializace vò®ky oken a poá†teán°ho ©†dku podkladu
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

InitRows PROC      FAR

; ------ £schova registrñ

         push      ax
         push      dx

; ------ korekce vò®ky, je-li mal† n†povàda

         mov       al,ds:[Radku]            ; vò®ka obrazovky
         test      byte ptr ds:[HelpPar],bit0 ; je mal† n†povàda ?
         jz        InitRow1                 ; nen° mal† n†povàda
         dec       ax                       ; sn°ëen° vò®ky o malou n†povàdu

; ------ odeáten° ©†dkñ pro p©°kazovò ©†dek

InitRow1:sub       al,ds:[LineCVys]         ; odeáten° vò®ky p©°kaz. ©†dku
         mov       ds:[LineCRad],al         ; ©†dek pro p©°kazovò ©†dek
InitRow2:mov       ah,al                    ; vò®ka podkladu

; ------ korekce vò®ky, je-li trvalÇ menu

         test      byte ptr ds:[ParMenu],bit0 ; je trvalÇ hlavn° menu ?
         jz        InitRow3                 ; nen° trvalÇ hlavn° menu
         dec       ax                       ; sn°ëen° vò®ky o trvalÇ menu

; ------ omezen° vò®ky podle uëivatelskÇho nastaven°

InitRow3:cmp       al,ds:[NumRows0]         ; je poëadov†na men®° vò®ka ?
         jbe       InitRow4                 ; vò®ka oken je OK
         mov       al,ds:[NumRows0]         ; omezen° na uëivatelskou vò®ku

; ------ kontrola minim†ln° vò®ky okna

InitRow4:cmp       al,8                     ; minim†ln° vò®ka
         ja        InitRow5                 ; vò®ka je OK
         mov       al,8                     ; omezen° na minim†ln° vò®ku
InitRow5:mov       ds:[NumRows],al          ; nov† vò®ka oken

; ------ stanoven° poá†teán°ho ©†dku

         mov       al,byte ptr ds:[SKurzor+1] ; ©†dek s kurzorem
         cmp       byte ptr ds:[SKurzor],0  ; je kurzor na zaá†tku ©†dku ?
         je        InitRow6                 ; kurzor je na zaá†tku ©†dku
         inc       ax                       ; zobraz° se i ©†dek s kurzorem

InitRow6:sub       al,ah                    ; poáet nezobrazenòch ©†dkñ
         mov       ah,0
         jae       InitRow7                 ; jsou nezobrazenÇ ©†dky
         mov       al,0                     ; je zobrazeno v®e
         test      byte ptr ds:[ParMenu],bit0 ; je trvalÇ hlavn° menu ?
         jnz       InitRow8                 ; je trvalÇ hlavn° menu -> -1

InitRow7:cmp       al,ds:[SRadku]           ; p©ekroáen poáet ©†dkñ ?
         jb        InitRow9                 ; á°slo ©†dku je OK
         mov       al,ds:[SRadku]           ; poáet ©†dkñ
         or        al,al
         jz        InitRow9
InitRow8:dec       ax                       ; maxim†ln° á°slo ©†dku
InitRow9:mov       ds:[STopLine],al         ; poá†teán° zobrazenò ©†dek

; ------ adresa zobrazenÇho poá†tku

         imul      word ptr ds:[SBajtRow]   ; adresa poá†tku k zobrazen°
         mov       ds:[STopAdr],ax          ; adresa poá†tku k zobrazen°

; ------ n†vrat registrñ

         pop       dx
         pop       ax
         ret

InitRows ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                      Naá°t†n° obsahu adres†©ovòch oken
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; *****************************************************************************
;                                 ReRetWK
;              n†vrat kurzoru okna (nap©. po n†vratu z programu)
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo okna
;        AWinKFil = soubor pro aktivn° okno (AWinKOff=poá†tek)
;        NWinKFil = soubor pro neaktivn° okno (NWinKOff=poá†tek)
; *****************************************************************************

ReRetWK  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      si
         push      es

; ------ uráen° adresy jmÇna

         mov       si,offset AWinKFil       ; aktivn° okno
         cmp       ax,ds:[SegmAkt]          ; je to aktivn° okno ?
         je        ReRetWK1                 ; je to aktivn° okno
         mov       si,offset NWinKFil       ; neaktivn° okno

; ------ nalezen° pozice kurzoru

ReRetWK1:push      ds
         pop       es                       ; ES <- datovò segment
         call      far ptr SrcWKur          ; nalezen° kurzoru
         call      far ptr GetDat
         mov       es:[AWinKurz],bx
         call      far ptr AktPathT         ; aktualizace stromu v aktivn°m oknà
         call      far ptr AktPathL         ; aktualizace cesty okna seznamu

; ------ uloëen° pozice kurzoru

         mov       byte ptr ds:[si],0
         mov       ax,es:[AWInKurz]
         sub       ax,ds:[si-2]
         jnc       ReRetWK2
         xor       ax,ax
ReRetWK2:mov       es:[AWinFrst],ax
         mov       word ptr ds:[si-2],-1

; ------ n†vrat registrñ

ReRetWK5:pop       es
         pop       si
         pop       bx
         pop       ax
         ret

ReRetWK  ENDP

; *****************************************************************************
;                                  ReReadD
;                  opàtovnÇ naáten° obsahu adres†©ovÇho okna
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo okna (mus° bòt platnÇ !!!)
; VùSTUP: AX=novÇ á°slo okna (p©i chybà á°slo starÇho okna)
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) á°slo starÇho okna
;                   SS:[BP-4] (2) á°slo novÇho okna
;                   SS:[BP-6] (2) offset kurzoru od poá†tku okna
;                   SS:[BP-7] (1)
;                   SS:[BP-28] (21) uschovan† poloëka pod kurzorem
; *****************************************************************************
;˛
ReReadD  PROC      FAR

         push      es
         call      far ptr GetDat           ; poskytnut° adresy okna
         and       byte ptr es:[AWinPrm1],not bit1 ; zru®en° p©°znaku naáten°
         test      byte ptr es:[AWinPrm1],bit4 ; je to strom ?
         pop       es
         jz        ReReadD1                 ; nen° to strom

         push      dx
         mov       dx,ax                    ; DX <- £schova starÇho okna
         call      far ptr CreatTWn         ; vytvo©en° novÇho okna
         jc        ReReadD0                 ; chyba operace
         call      far ptr XchgWSeg         ; z†màna oken
         xchg      ax,dx
         call      far ptr DeletAWn         ; zru®en° starÇho okna
         xchg      ax,dx
         call      far ptr DispAWin         ; zobrazen° okna
         call      far ptr InitTWn          ; inicializace okna
         clc

ReReadD0:pop       dx
         ret


;ReadDirX label     far

; ------ £schova registrñ

ReReadD1:push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ p©°prava lok†ln°ch promànnòch

         mov       bp,sp
         sub       sp,28
         mov       ss:[bp-2],ax             ; á°slo starÇho okna

; ------ test, zda je to adres†©ovÇ okno

         call      far ptr GetDat           ; adresa okna
         jc        ReReadD2

; P©°znak naáten°, aby po chybà se to nesnaëil po©†d naá°tat znovu

         or        byte ptr es:[AWinPrm1],bit1 ; p©°znak naáten° adres†©e

         test      byte ptr es:[AWinPrm1],bit3 ; je to adres†©ovÇ okno ?
         jz        ReReadD2                 ; nen° to adres†©ovÇ okno

; ------ £schova polohy kurzoru v oknà

         mov       bx,es:[AWinKurz]         ; soubor s kurzorem
         sub       bx,es:[AWinFrst]         ; offset od poá†tku okna
         mov       ss:[bp-6],bx             ; offset kurzoru od poá†tku okna

; ------ hl†®en° o naá°t†n° okna AX

         call      NacitDir                 ; hl†®en° o naá°t†n° adres†©e okna AX

; ------ vytvo©en° novÇho okna

         call      far ptr DuplAWin         ; duplikace okna AX -> BX
         jnc       ReReadD3                 ; operace OK
         call      far ptr MemErr           ; hl†®en° - chyba pamàti
ReReadD2:jmp       ReReadD9

; ------ ovà©en° p©ipravenosti disku

ReReadD3:mov       ss:[bp-4],bx             ; á°slo novÇho okna

;         xchg      ax,bx                    ; AX <- novÇ okno, BX <- starÇ okno
;         call      far ptr GetDat           ; adresa okna
;         mov       cl,es:[AWinDir]          ; poëadovanò disk
;         mov       si,offset AllDisk        ; adres†© "A:\*.*"
;         mov       ds:[si],cl               ; oznaáen° disku
;         push      ds
;         pop       es                       ; ES <- datovò segment
;         call      far ptr ExisFile         ; test p©ipravenosti disku
;         call      far ptr TestBreak        ; chyba disku ?
;         xchg      ax,bx                    ; AX <- starÇ okno, BX <- novÇ okno
;         jc        ReReadD2                 ; chyba disku

; ------ test, zda se bude uchov†vat kurzor a oznaáen°

         call      far ptr GetDat           ; adresa okna
         jc        ReReadD4
         test      byte ptr es:[AWinPrm0],bit0 ; bude se uchov†vat kurzor ?
         jz        ReReadD4                 ; kurzor se bude uchov†vat

; ------ zru®en° starÇho okna AX (pro uvolnàn° pamàti)

         push      cs
         call      near ptr DeletAWn        ; zru®en° starÇho okna

; ------ z†màna á°sla okna

         xchg      ax,dx                    ; DX <- starÇ okno
         xchg      ax,bx                    ; AX <- novÇ okno
         push      cs
         call      near ptr XchgWSeg        ; z†màna starÇho okna DX za novÇ AX

; ------ naáten° novÇho obsahu okna

         push      cs
         call      near ptr ReadDir         ; naáten° novÇho okna AX
         call      far ptr GetDat
         and       byte ptr es:[AWinPrm0],not bit0 ; p©°®tà se kurzor uchov†
         jmp       short ReReadD2

; ------ nulov†n° poloëky pod kurzorem

ReReadD4:push      ax
         push      ss
         pop       es                       ; ES <- z†sobn°k
         lea       di,ss:[bp-28]            ; buffer uschovanÇ poloëky
         mov       cx,21                    ; dÇlka poloëky
         cld
         mov       al,0
         push      di
         rep       stosb                    ; vynulov†n° poloëky
         pop       di
         pop       ax

; ------ £schova poloëky pod kurzorem

         call      far ptr GetWKurz         ; poskytnut° poloëky pod kurzorem
         jc        ReReadD5                 ; nen° ë†dn† poloëka
         push      ds
         push      es
         pop       ds                       ; DS <- segment poloëky
         push      ss
         pop       es                       ; ES <- segment bufferu
         cld
         mov       cl,21                    ; velikost poloëky
         rep       movsb                    ; £schova poloëky pod kurzorem
         pop       ds

; ------ naáten° novÇho obsahu okna

ReReadD5:xchg      ax,dx                    ; DX <- starÇ okno
         xchg      ax,bx                    ; AX <- novÇ okno
         push      cs
         call      near ptr ReadDir         ; naáten° novÇho okna AX

; ------ test, zda m† bòt navracen kurzor a oznaáen°

         call      far ptr GetDat           ; adresa okna
         mov       cl,es:[AWinPrm0]
         and       byte ptr es:[AWinPrm0],not bit0 ; p©°®tà se uchov†
         test      cl,bit0                  ; uchov†v† se kurzor ?
         jz        ReRead54                 ; kurzor se uchov†v†
         jmp       ReReadD8                 ; kurzor se neuchov†v†

; ------ n†vrat pozice kurzoru

ReRead54:push      ss
         pop       es                       ; ES <- segment buffery
         lea       si,ss:[bp-28]            ; buffer poloëky
         call      far ptr SrcWKur          ; nalezen° bl°zkÇ poloëky
         call      far ptr GetDat           ; adresa okna
         mov       es:[AWinKurz],bx         ; pozice kurzoru
         sub       bx,ss:[bp-6]             ; pozice poá†tku okna
         jnc       ReReadD6
         xor       bx,bx                    ; omezen° p©i podteáen°
ReReadD6:mov       es:[AWinFrst],bx         ; poá†tek okna

; ------ p©°prava k p©enesen° oznaáen° poloëek

         mov       di,es                    ; DI <- adresa novÇho okna
         push      ax
         push      dx
         xchg      ax,dx                    ; AX <- starÇ okno, DX <- novÇ okno
         call      far ptr GetDat           ; adresa starÇho okna -> ES
         jc        ReRead79
         xchg      ax,dx                    ; AX <- novÇ okno, DX <- starÇ okno
         mov       dx,es                    ; DX <- adresa starÇho okna
         xor       cx,cx                    ; ukazatel poloëek starÇho okna

; ------ nalezen° dal®° oznaáenÇ poloëky starÇho okna

ReRead72:mov       bx,cx                    ; BX <- ukazatel poloëek
         inc       cx                       ; zvò®en° ukazatele poloëek
         mov       es,dx                    ; ES <- adresa starÇho okna
         call      far ptr GetESPol         ; adresa dal®° poloëky
         jc        ReRead79                 ; nen° dal®° poloëka
         test      byte ptr es:[si+FileAtr],ATRT ; je to platn† poloëka ?
         jz        ReRead72                 ; nen° to platn† poloëka
         test      byte ptr es:[si+FileAtr],ATRO+ATRU+DIR ; oznaáenÇ/adres†© ?
         jz        ReRead72                 ; nen° to oznaáen† poloëka

; ------ nalezen° stejnÇ poloëky v novÇm oknà -> BX

         call      far ptr SrcWNam          ; nalezen° poloëky ES:SI v oknà AX
         jc        ReRead72                 ; poloëka nenalezena - dal®°

; ------ p©enesen° velikosti adres†©e (vad° p©i aktualizaci ze stromu !!!!)

;         test      byte ptr es:[si+FileAtr],DIR ; je to adres†© ?
;         jz        ReRead74                 ; nen° to adres†©
;         push      si
;         push      es
;         push      word ptr es:[si+FileSize] ; velikost adres†©e
;         push      word ptr es:[si+FileSize+2]
;         mov       es,di                    ; ES <- adresa novÇho okna
;         call      far ptr GetESPol         ; adresa poloëky -> ES:SI
;         pop       word ptr es:[si+FileSize+2]
;         pop       word ptr es:[si+FileSize]
;         pop       es
;         pop       si

; ------ £schova oznaáen° poloëky

ReRead74:test      byte ptr es:[si+FileAtr],ATRU ; je £schova oznaáen° ?
         jz        ReRead76                 ; nen° £schova oznaáen°
         push      si
         push      es
         mov       es,di                    ; ES <- adresa novÇho okna
         call      far ptr GetESPol         ; adresa poloëky ES:SI
         or        byte ptr es:[si+FileAtr],ATRU ; £schova oznaáen°
         pop       es
         pop       si

; ------ oznaáen° nalezenÇ poloëky

ReRead76:test      byte ptr es:[si+FileAtr],ATRO ; je poloëka oznaáen† ?
         jz        ReRead72                 ; poloëka nen° oznaáen†
         mov       es,di                    ; ES <- adresa novÇho okna
         call      far ptr SetSPol          ; oznaáen° poloëky okna
         jmp       short ReRead72           ; dal®° poloëka

ReRead79:pop       dx
         pop       ax

; ------ zru®en° starÇho okna

ReReadD8:xchg      ax,dx                    ; AX <- starÇ okno, DX <- novÇ okno
         push      cs
         call      near ptr DeletAWn        ; zru®en° starÇho okna

; ------ z†màna á°sla okna

         xchg      ax,dx                    ; AX <- novÇ okno, DX <- starÇ okno
         push      cs
         call      near ptr XchgWSeg        ; z†màna starÇho okna DX za novÇ AX

; ------ n†vrat registrñ

ReReadD9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         call      far ptr InfoClos         ; uzav©en° informaán°ho okna
         clc
         ret

ReReadD  ENDP

; -----------------------------------------------------------------------------
;        hl†®en° o naá°t†n° adres†©e okna AX
; -----------------------------------------------------------------------------

NacitDir PROC      NEAR

         push      cx
         push      si
         push      es

         call      far ptr GetDat           ; adresa okna
         jc        NacitDr6                 ; chyba
         test      byte ptr es:[AWinPrm0],bit3 ; je hl†®en° p©i GetFFil ?
         jnz       NacitDr6                 ; naá°t†n° se nehl†s°

         call      far ptr InfoClr          ; vymaz†n° informaán°ho ©†dku

         mov       si,offset NacAdTxt       ; text - naá°t†m adres†©
         call      far ptr InfoTxt          ; p©°prava textu hl†®en°

         mov       si,AWinDir               ; text adres†©e
         mov       cx,es:[AWinDNum]         ; dÇlka textu adres†©e
         call      far ptr InfoDek          ; dek¢dov†n° textu adres†©e

         call      far ptr InfoDisp         ; zobrazen° informaán°ho ©†dku

NacitDr6:pop       es
         pop       si
         pop       cx
         ret

NacitDir ENDP

; *****************************************************************************
;                                   ReadDir
;                     Naáten° obsahu adres†©ovÇho okna
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo datovÇho bloku okna (mus° bòt platnò !)
; VùSTUP:CY=chyba (chybu pamàti hl†s°) - bude se ignorovat, ned† se nic dàlat
; -----------------------------------------------------------------------------
; Lok†ln° promànnÇ: [BP- 1] (1)  bit 0: 1=maska p©i naá°t†n°
;                                bit 1: 1=p©°znak nalezen° poloëky ".."
;                                bit 2: 1=adres†© naá°st vëdy
;                                bit 3: 1=oznaáovat odpov°daj°c° poloëky
;                                bit 4: 1=nenaá°tat ".."
;                                bit 5: 1=je to ROOT
;                                bit 6,7: 0=v®echny soubory
;                                         1=programy
;                                         2=maska
;                   [BP- 2] (1)
;                   [BP- 4] (2) pracovn° identifik†tor DTA
;                   [BP- 5] (1)
;                   [BP-18] (13) jmÇno souboru s p©°ponou ASCIIZ
;                   [BP-22] (4)  velikost souboru
;                   [BP-24] (2)  datum souboru
;                   [BP-26] (2)  áas souboru
;                   [BP-27] (1)  atributy souboru
;                   [BP-48] (21) pracovn° adresa DTA - zaá†tek
;
;                   [BP-50] (2)  á°taá souborñ k naáten° (volnÇ m°sto)
;                   [BP-52] (2)  adresa konce cesty v z†sobn°ku
;                   [BP-54] (2)  adresa okna
;                   [BP-56] (2)  á°slo okna
;                   [BP-184] (128) specifikace souboru *.*
; *****************************************************************************
;˛
$ReaDFl$ EQU       SS:[BP-184]              ; adresa jmÇna souboru

ReadDir  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp                    ; ukazatel dat v z†sobn°ku
         sub       sp,184                   ; prostor pro buffer DTA a promànnÇ

; ------ adresa okna

         test      byte ptr ds:[ParInt24],bit3 ; je z†kaz DOS bàhem INT 24h ?
         stc                                ; p©°znak chyby
         jnz       ReadDr01                 ; je z†kaz DOS bàhem INT 24h
         mov       ss:[bp-56],ax            ; £schova á°sla okna
         call      far ptr GetDat           ; poskytnut° adresy definice okna
         jc        ReadDr01                 ; (pojistka - ale nesm° nastat !)
         mov       ss:[bp-54],es            ; adresa okna
         test      byte ptr es:[AWinPrm1],bit3 ; je to adres†©ovÇ okno ?
         jnz       ReadDir0                 ; je to adres†©ovÇ okno
ReadDr01:jmp       ReadDir8                 ; adres†© se neáte

; ------ parametry

ReadDir0:mov       ah,es:[AWinPrm0]         ; parametry pro naá°t†n°
         mov       al,es:[AWinFilP]         ; parametry filtru
         and       ax,bit3*HI + bit0+bit2+bit4+bit6+bit7 ; zru®en° p©°znaku poloëky ".."
         or        al,ah                    ; p©°znak oznaáen° poloëek
         cmp       word ptr es:[AWinDNum],3 ; je to ROOT ?
         ja        ReadDr03                 ; nen° to ROOT
         or        al,bit5                  ; p©°znak, ëe to je ROOT
ReadDr03:mov       ss:[bp-1],al             ; parametry

; ------ naáten° n†và®t° disku

         mov       al,es:[AWinDisk]         ; disk okna
         mov       di,AWinLab               ; n†và®t° disku
         call      far ptr GetVol           ; poskytnut° n†và®t° disku
         mov       es:[AWinLabN],cl         ; dÇlka n†và®t°

; ------ naáten° informac° o disku

         mov       ax,ss:[bp-56]            ; á°slo okna
         push      cs
         call      near ptr InitDInf        ; inicializace diskovòch informac°

; ------ nulov†n° parametrñ bloku

         mov       es,ss:[bp-54]            ; adresa bloku
         or        byte ptr es:[AWinPrm1],bit1 ; p©°znak naáten° adres†©e
         and       byte ptr es:[AWinPrm1],not bit6 ; nebyl koment†©
         mov       word ptr es:[AWinSouR],0 ; nen° nic naáteno
         mov       word ptr es:[AWinSouN],0 ; nen° nic zobrazeno
         mov       word ptr es:[AWinSouI],AWin AND 0fh ; offset tabulky indexñ
         mov       word ptr es:[AWinSouI+2],AWin/16 ; segment tabulky indexñ
         mov       word ptr es:[AWinKomI],AWin AND 0fh ; offset tabulky indexñ
         mov       word ptr es:[AWinKomI+2],AWin/16 ; segment tabulky indexñ

; ------ p©°prava maxim†ln°ho poátu souborñ (AX=á°slo okna)

         call      far ptr GetSgSiz         ; velikost segmentu -> BX
         xchg      ax,bx                    ; AX <- velikost segmentu v odstavc°ch
         call      far ptr GetFree          ; poskytnut° volnÇ pamàti -> BX
         add       bx,ax                    ; BX <- celkov† voln† pamàü
         sub       bx,(AWin + 15 + 1000)/16 ; bez popisovaáñ + rezerva
         jb        ReadDr13                 ; chyba pamàti
         cmp       word ptr es:[AWinFilF.AWinFTxN],0 ; je hled†n° textu ?
         je        ReadDr11                 ; nen° hled†n° textu
         sub       bx,4000/16               ; je®tà asi takov† rezerva
         jb        ReadDr13                 ; chyba pamàti
ReadDr11:mov       ax,16                    ; pro p©epoáet na bajty
         mul       bx                       ; voln† kapacita v bajtech
         mov       cx,FileSumm + 3 + 2    + 40  ; poáet bajtñ pot©ebnòch na soubor
         div       cx                       ; vòpoáet poátu souborñ
         cmp       ax,MaxAFile+1            ; p©ekroáen poáet souborñ ?
         jb        ReadDr12                 ; to je OK
         mov       ax,MaxAFile+1            ; maxim†ln° poáet souborñ (+ 1 "..")
ReadDr12:mov       ss:[bp-50],ax            ; maxim†ln° poáet souborñ adres†©e
         cmp       ax,2                     ; asi tak minim†lnà souborñ
         jb        ReadDr13                 ; nen° voln† pamàü

; ------ nastaven° velikosti bloku okna na maximum (velikost BX)

         mov       ax,ss:[bp-56]            ; á°slo novÇho okna
         add       bx,(AWin+15)/16          ; inicializaán° velikost segmentu
         call      far ptr ModiSeg          ; nastaven° velikosti segmentu
         jnc       ReadDr14                 ; operace OK
ReadDr13:jmp       ReadDir7                 ; chyba - nedostatek pamàti

; ------ hl†®en° o naá°t†n° adres†©e okna

ReadDr14:mov       ax,ss:[bp-56]            ; á°slo okna
         call      NacitDir                 ; hl†®en° o naá°t†n° adres†©e okna AX

; ------ kopie adres†©e okna do bufferu v z†sobn°ku

         mov       di,sp                    ; buffer jmÇna souboru
         push      ds                       ; £schova DS
         mov       ds,ss:[bp-54]            ; DS <- adresa okna
         push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku
         mov       si,AWinDir               ; adres†© okna
         mov       cx,ds:[AWinDNum]         ; dÇlka textu adres†©e
         cld
         rep       movsb                    ; p©enos textu adres†©e
         pop       ds                       ; n†vrat DS

; ------ p©id†n° specifikace "*.*" k textu adres†©e

         mov       al,"\"                   ; znak oddàlovaáe
         dec       di                       ; n†vrat na posledn° znak
         scasb                              ; je jië oddàlovaá "\" ?
         je        ReadDr15                 ; je jië "\"
         stosb                              ; uloëen° oddàlovaáe "\"
ReadDr15:mov       ss:[bp-52],di            ; £schova adresy konce cesty
         mov       si,offset All            ; text "*.*"
         movsw                              ; znaky ".*"
         movsw                              ; znaky "*" a 0

; ------ definice bufferu DTA

         lea       si,[bp-48]               ; adresa bufferu DTA
         call      far ptr SetDTA           ; nastaven° adresy DTA

; ------ nalezen° prvn°ho souboru

         mov       word ptr ds:[LastErr],0  ; zru®en° p©°znaku chyby
         mov       cx,SYS+HID+RO+DIR+ARC    ; specifikace - v®echny soubory
         mov       si,sp                    ; specifikace souborñ
         call      far ptr SrcFirst         ; nalezen° prvn°ho souboru
         jnc       ReadDir4                 ; operace OK
         call      far ptr TestBreak        ; bylo p©eru®en° operace ?
         jnc       ReadDr16
         jmp       ReadDir6                 ; bylo p©eru®en° operace

; ------ kontrola, zda je neplatn† cesta

ReadDr16:cmp       word ptr ds:[LastErr],3  ; neplatn† cesta ?
         jne       ReadDr39                 ; nen° chyba nenalezen° cesty

; ------ test, zda je jië ROOT adres†©

         mov       es,ss:[bp-54]            ; adresa okna
         mov       cx,es:[AWinDNum]         ; dÇlka textu adres†©e
         cmp       cx,3                     ; je jië ROOT ?
         jbe       ReadDr39                 ; je jië ROOT

; ------ zkr†cen° cesty o jeden podadres†©

         or        byte ptr es:[AWinPrm0],bit0 ; p©°znak zmàny adres†©e
         mov       si,AWinDir               ; buffer cesty
         add       si,cx                    ; adresa konce cesty
ReadDr32:dec       si                       ; sn°ëen° ukazatele cesty
         cmp       byte ptr es:[si],"\"     ; je konec ?
         jne       ReadDr32                 ; nalezen° oddàlovaáe podadres†©e
         cmp       byte ptr es:[si-1],":"   ; je to ROOT ?
         jne       ReadDr33                 ; nen° to ROOT
         inc       si                       ; znak "\" je platnò znak cesty
         or        byte ptr ss:[bp-1],bit5  ; p©°znak, ëe to je ROOT
ReadDr33:mov       byte ptr es:[si],0       ; oznaáen° konce cesty
         sub       si,AWinDir               ; dÇlka cesty
         mov       es:[AWinDNum],si         ; nov† dÇlka cesty
         jmp       ReadDr14                 ; novò pokus

ReadDr39:jmp       ReadDr62

ReadDr3A:jmp       ReadDir6                 ; nen° dal®° soubor - konec

; ------ rozli®en°, zda byl nalezen platnò soubor

ReadDir4:jnz       ReadDr3A                 ; dal®° soubor nenalezen - konec

         mov       byte ptr ss:[bp-18+12],0 ; pojistnÇ zakonáen° jmÇna

         and       byte ptr ss:[bp-27],not ATRU+ATRO ; nulov†n° nepot©ebnòch atributñ
         test      byte ptr ss:[bp-27],DIR  ; je to adres†© ?
         jz        ReadDr42                 ; nen° to adres†©
         mov       word ptr ss:[bp-22],0    ; velikost adres†©e LOW
         mov       word ptr ss:[bp-22+2],0  ; velikost adres†©e HIGH

         cmp       word ptr ss:[bp-18],"."  ; je adres†© s oznaáen°m "." ?
         je        ReadDir5                 ; adres†© "." se p©eskoá°
         cmp       word ptr ss:[bp-18],".." ; je adres†© ".." ?
         jne       ReadDr42                 ; nen° adres†© ".."
         or        byte ptr ss:[bp-1],bit1  ; p©°znak poloëky ".."
         test      byte ptr ss:[bp-1],bit4+bit5  ; je to ROOT nebo z†kaz ?
         jnz       ReadDir5                 ; pro ROOT je ".." zak†z†n

; ------ vòbàr souborñ bàhem naá°t†n°

ReadDr42:call      ReadDirV                 ; test vòbàru poloëky
         jnc       ReadDr44                 ; poloëka vyhovuje OK

; ------ test, zda se bude prov†dàt vòbàr souboru

         test      byte ptr ss:[bp-27],DIR  ; je to adres†© ?
         jz        ReadDir5                 ; nen° to adres†© - nevyhovuje
         mov       es,ss:[bp-54]            ; adresa okna
         cmp       byte ptr es:[AWinFilF.AWinFAtM],0 ; testuj° se atributy ?
         jz        ReadDr43                 ; atributy se netestuj°
         mov       al,ss:[bp-27]            ; atributy
         and       al,es:[AWinFilF.AWinFAtM] ; maskov†n°
         cmp       al,es:[AWinFilF.AWinFAtr] ; odpov°daj° atributy ?
         jne       ReadDir5                 ; poloëka nevyhovuje
ReadDr43:test      byte ptr ss:[bp-1],bit2  ; adres†© se naá°t† vëdy ?
         jnz       ReadDr45                 ; je to adres†© - naáte se takÇ
         jmp       short ReadDir5           ; poloëka nevyhovuje

; ------ oznaáen° vyhovuj°c° poloëky

ReadDr44:test      byte ptr ss:[bp-1],bit3  ; poloëky se oznaáuj° ?
         jz        ReadDr45                 ; poloëky se neoznaáuj°
         or        byte ptr ss:[bp-27],ATRU ; p©°znak vyhovuj°c° poloëky

; ------ test, zda je m°sto pro dal®° soubor

ReadDr45:cmp       word ptr ss:[bp-50],2    ; á°taá souborñ k naáten°
         jb        ReadDir6                 ; nedostatek pamàti

; ------ uloëen° souboru do bufferu

         lea       si,[bp-27]               ; offset bufferu DTA - zaá†tek dat
         mov       dx,ss                    ; segment bufferu DTA
         mov       es,ss:[bp-54]            ; adresa okna
         call      StorFile                 ; uloëen° souboru SS:SI do seznamu
         dec       word ptr ss:[bp-50]      ; á°taá souborñ

; ------ pokus o nalezen° dal®°ho souboru

ReadDir5:call      far ptr SrcNext          ; nalezen° dal®°ho souboru
         jc        ReadDr62                 ; chyba
         jmp       ReadDir4                 ; operace OK

; ------ uloëen° poloëky ".." (je ponech†na rezerva pro 1 soubor); CY chyba pamàti

ReadDr62:call      far ptr TestBreak        ; bylo p©eru®en° operace ?

ReadDir6:call      far ptr SrcClose         ; uzav©en° starÇho hled†n°

         pushf                              ; CY=chyba pamàti
         test      byte ptr ss:[bp-1],bit1+bit4+bit5  ; byla nalezena poloëka ".." ?
         jnz       ReadDr64                 ; nalezena poloëka ".." nebo je ROOT
         lea       si,[bp-27]               ; offset bufferu DTA - zaá†tek dat
         xor       ax,ax                    ; AX <- 0
         mov       byte ptr ss:[si],DIR     ; atributy
         mov       ss:[si+1],ax             ; áas
         mov       word ptr ss:[si+3],bit0+bit5 ; datum
         mov       ss:[si+5],ax             ; velikost LOW
         mov       ss:[si+7],ax             ; velikost HIGH
         mov       word ptr ss:[si+9],".."  ; jmÇno
         mov       ss:[si+11],al            ; koncov† 0
         test      byte ptr ss:[bp-1],bit2  ; adres†© se naá°t† vëdy ?
         jnz       ReadDr63                 ; adres†© se naá°t† vëdy
         call      ReadDirV                 ; test vòbàru poloëky
         jc        ReadDr64                 ; poloëka nevyhovuje nebo chyba
ReadDr63:lea       si,[bp-27]               ; offset bufferu DTA - zaá†tek dat
         mov       dx,ss                    ; segment bufferu DTA
         mov       es,ss:[bp-54]            ; adresa okna
         call      StorFile                 ; uloëen° souboru SS:SI do seznamu
ReadDr64:popf

; ------ vòbàr poloëek k zobrazen° (CY=je chyba pamàti nebo p©eru®en° operace)

ReadDir7:pushf
         mov       ax,ss:[bp-56]            ; á°slo okna
         call      far ptr SelWDir          ; vòbàr poloëek okna

; ------ naáten° informaán°ho souboru

         call      far ptr LoadFInf         ; naáten° informaán°ho souboru

; ------ naáten° velikost° adres†©ñ ze stromu

         call      far ptr DirSumm          ; naáten° velikost° adres†©ñ

; ------ set©°dàn° poloëek v adres†©i

         call      far ptr SortDir          ; set©°dàn° poloëek v oknà
         popf

; ------ nedostatek pamàti

ReadDir8:jnc       ReadDir9                 ; operace OK
         call      far ptr TestBreak        ; je p©eru®en° operace ?
         jc        ReadDir9                 ; je p©eru®en° operace

         call      far ptr DispAll          ; zobrazen° podkladu
         mov       ax,ss:[bp-56]            ; á°slo okna
         call      far ptr GetDat           ; adresa okna
         mov       ax,es:[AWinSouR]         ; poáet naátenòch souborñ
         push      ds
         pop       es                       ; ES <- datovò segment
         xor       bx,bx                    ; nen° oddàlovaá ani barva
         mov       di,offset ChbRDirC+1     ; buffer k dek¢dov†n° á°sla
         call      far ptr DekNumW          ; dek¢dov†n° á°sla poátu souborñ
         sub       di,offset ChbRDirC+1     ; dÇlka textu
         xchg      ax,di
         mov       ds:[ChbRDirC],al         ; dÇlka textu
         call      far ptr InfoClos         ; uzav©en° informaán°ho ©†dku
         mov       si,offset ChybRDir
         call      far ptr Lin0MenF         ; zobrazen° hl†®en°
         call      far ptr SetEsc           ; p©°znak p©eru®en° operace

; ------ n†vrat registrñ

ReadDir9:mov       sp,bp                    ; n†vrat ukazatele z†sobn°ku SP
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ReadDir  ENDP

; -----------------------------------------------------------------------------
;        test vòbàru poloëky (CY=nevyhovuje)
; -----------------------------------------------------------------------------
;˛
ReadDirV PROC      NEAR

; ------ test, zda se bude prov†dàt vòbàr souboru

         test      byte ptr ss:[bp-1],bit0  ; prov†d° se vòbàr souborñ ?
         jnz       ReadDrV1                 ; prov†d° se vòbàr souborñ
         ret

; ------ test, zda se prov†d° test maskou

ReadDrV1:test      byte ptr ss:[bp-1],bit6+bit7 ; jsou v®echny soubory ?
         jz        ReadDrV3                 ; jsou v®echny soubory

; ------ p©°prava jmÇna poloëky ve tvaru FCB

         lea       si,[bp-48]               ; tabulka DTA
         push      ss
         pop       es                       ; ES <- segment tabulky DTA
         call      far ptr GetBFCB0         ; dek¢dov†n° na jmÇno FCB

; ------ test jmÇna poloëky, zda poloëka vyhovuje hled†n°

         push      ds
         push      ds
         pop       es                       ; ES <- datovò segment
         mov       si,offset FileFCB0       ; ES:SI = jmÇno poloëky FCB
         mov       ds,ss:[bp-54]            ; adresa okna
         mov       di,AWinFilF.AWinFilt     ; DS:DI = maska pro hled†n°
         mov       cx,ds:[AWinFilF.AWinFilN] ; dÇlka masky pro hled†n°
         call      far ptr TestMask         ; test, zda poloëka vyhovuje
         pop       ds
         jc        ReadDrV9                 ; poloëka nevyhovuje

; ------ test ostatn°ch parametrñ poloëky, zda vyhovuje

ReadDrV3:push      ds
         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         lea       si,[bp-48]               ; adresa DTA
         mov       di,AWinFilF              ; zaá†tek parametrñ
         mov       ds,ss:[bp-54]            ; adresa okna
         call      far ptr GetBTest         ; test ostatn°ch parametrñ
         pop       ds
         jc        ReadDrV9                 ; poloëka nevyhovuje

; ------ test, zda se bude hledat text v souboru

         mov       es,ss:[bp-54]            ; adresa okna
         cmp       word ptr es:[AWinFilF.AWinFTxN],0 ; je hledanò text ?
         je        ReadDrV9                 ; text se nehled†

; ------ sestaven° jmÇna souboru

         mov       di,ss:[bp-52]            ; adresa konce cesty v z†sobn°ku
         lea       si,ss:[bp-18]            ; jmÇno nalezenÇho souboru
         push      ds
         push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku
         push      ss
         pop       ds                       ; DS <- segment z†sobn°ku
         cld
ReadDrV4:lodsb
         stosb
         cmp       al,0
         jne       ReadDrV4                 ; p©enos jmÇna souboru
         pop       ds

; ------ p©°prava velikosti souboru

         mov       ax,ss:[bp-22]            ; velikost souboru LOW
         mov       word ptr ds:[InfoKMax],ax
         mov       ax,ss:[bp-22+2]          ; velikost souboru HIGH
         mov       word ptr ds:[InfoKMax+2],ax

; ------ nalezen° textovÇho ©etàzce v souboru

         dec       di                       ; bez koncovÇ 0
         lea       si,$ReaDFl$              ; adresa textu jmÇna souboru
         sub       di,si                    ; dÇlka textu jmÇna souboru
         mov       cx,di                    ; CX <- dÇlka jmÇna souboru
         push      ss
         pop       es                       ; ES <- segment jmÇna souboru
         mov       dx,ss:[bp-54]            ; DX <- segment adresy okna
         mov       di,AWinFilF              ; tabulka parametrñ k hled†n°
         call      far ptr SrcFText         ; nalezen° textu v souboru

ReadDrV9:ret

ReadDirV ENDP

; *****************************************************************************
;                              XchgWSeg
;                        z†màna segmentu okna
; -----------------------------------------------------------------------------
; VSTUP: AX=segment novÇho okna
;        DX=segment starÇho okna
;        DS=datovò segment
; *****************************************************************************

XchgWSeg PROC      FAR

; ------ aktivn° okno

         cmp       dx,ds:[SegmAkt]          ; bylo to aktivn° okno ?
         jne       XchgWSg1                 ; nebylo to aktivn° okno
         mov       ds:[SegmAkt],ax          ; novÇ aktivn° okno

; ------ neaktivn° okno

XchgWSg1:cmp       dx,ds:[SegmNAkt]         ; bylo to neaktivn° okno ?
         jne       XchgWSg2                 ; nebylo to neaktivn° okno
         mov       ds:[SegmNAkt],ax         ; novÇ neaktivn° okno

; ------ levÇ okno

XchgWSg2:cmp       dx,ds:[SegmL]            ; levÇ okno ?
         jne       XchgWSg3                 ; nen° levÇ okno
         mov       ds:[SegmL],ax            ; novÇ levÇ okno

; ------ pravÇ okno

XchgWSg3:cmp       dx,ds:[SegmR]            ; pravÇ okno ?
         jne       XchgWSg4                 ; nen° pravÇ okno
         mov       ds:[SegmR],ax            ; novÇ pravÇ okno

; ------ levÇ okno - adres†©

XchgWSg4:cmp       dx,ds:[SegmLAdr]         ; levÇ okno ?
         jne       XchgWSg5                 ; nen° levÇ okno
         mov       ds:[SegmLAdr],ax         ; novÇ levÇ okno

; ------ pravÇ okno - adres†©

XchgWSg5:cmp       dx,ds:[SegmRAdr]         ; pravÇ okno ?
         jne       XchgWSg6                 ; nen° pravÇ okno
         mov       ds:[SegmRAdr],ax         ; novÇ pravÇ okno

XchgWSg6:ret

XchgWSeg ENDP

; *****************************************************************************
;                                LoadFInf
;                   naáten° informaán°ho souboru okna AX
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo segmentu okna
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: [BP-2] (2) á°slo segmentu okna
;                   [BP-4] (2) á°slo segmentu koment†©ñ
; *****************************************************************************

LoadFInf PROC      FAR

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
         sub       sp,FileMax+4

; ------ adresa segmentu okna

         mov       ss:[bp-2],ax             ; á°slo segmentu okna
         call      far ptr GetDat           ; adresa okna
         jc        LoadFI11

; ------ test, zda m† bòt koment†© naáten

         test      byte ptr es:[AWinPrm1],bit6 ; byl koment†© jië naá°t†n ?
         jz        LoadFI10                 ; koment†© je®tà nebyl naá°t†n
LoadFI11:jmp       LoadFIn9                 ; soubor nenalezen nebo chyba
LoadFI10:test      byte ptr es:[AWinPrm1],bit3 ; je adres†©ovÇ okno ?
         jz        LoadFI11                 ; nen° adres†©ovÇ okno

         mov       al,es:[AWInPrm2]
         and       al,bit5+bit6
         cmp       al,2*bit5                ; je komentovanÇ okno ?
         jne       LoadFI11                 ; nen° komentovanÇ okno

; ------ zru®en° staròch dat

         and       byte ptr ds:[FileInfP],not bit0+bit1 ; nen° DOSMAN.FIL, *.BBS
         or        byte ptr es:[AWinPrm1],bit6 ; p©°znak hled†n° soub. koment†©ñ
         xor       ax,ax                    ; AX <- 0
         mov       es:[AWinKomN],ax         ; zru®en° dat pozn†mek
         mov       es:[AWinKomD],ax         ; zru®en° nadpisu
         mov       ax,es:[AWinKomS]         ; starò segment pozn†mek
         call      far ptr DelSeg           ; zru®en° starÇho segmentu
         mov       es:[AWinKomS],ax         ; p©°znak, ëe je zru®en

; ------ vytvo©en° novÇho bloku pozn†mek

         mov       bx,100                   ; asi tak minim†ln° velikost
         call      far ptr CreatDat         ; vytvo©en° novÇho bloku
         jc        LoadFI11                 ; nedostatek pamàti
         mov       ss:[bp-4],ax             ; á°slo segmentu koment†©ñ
         call      far ptr GetDat           ; adresa koment†©ñ
         mov       es:[0],bx                ; velikost bloku koment†©ñ
         xchg      ax,bx                    ; BX <- segment koment†©ñ
         mov       ax,ss:[bp-2]             ; segment okna
         call      far ptr GetDat           ; adresa okna
         mov       es:[AWinKomS],bx         ; segment koment†©ñ

; ------ p©°prava specifikace souboru

         cld
         mov       di,sp                    ; buffer v z†sobn°ku
         push      ds

         push      es
         pop       ds                       ; DS <- segment okna
         push      ss
         pop       es                       ; ES <- buffer v z†sobn°ku

         mov       si,AWinDir               ; adres†© okna
         mov       cx,ds:[AWinDNum]         ; dÇlka textu adres†©e
         rep       movsb                    ; p©enos textu adres†©e

         mov       al,"\"
         dec       di                       ; n†vrat na posledn° znak
         scasb                              ; byla cesta ukonáena s "\" ?
         je        LoadFIn1                 ; je ukonáena s "\"
         stosb                              ; oddàlovaá cesty

LoadFIn1:pop       ds
         mov       si,offset FileInfo       ; text "FILEINFO"
         mov       cl,9                     ; dÇlka textu (s nulou na konci)
         push      di
         rep       movsb                    ; p©enos textu do bufferu
         pop       di

; ------ otev©en° souboru FILEINFO

         mov       si,sp                    ; buffer v z†sobn°ku
         call      far ptr OpenR            ; otev©en° souboru ES:SI pro áten°
         jnc       LoadFIn3                 ; soubor otev©en OK

; ------ pokus o otev©en° souboru DESCRIPT.ION

         mov       si,offset FileInfD       ; soubor DESCRIPT.ION
         mov       cl,13
         cld
         push      di
         rep       movsb                    ; p©enos textu DESCRIPT.ION
         pop       di
         mov       si,sp
         call      far ptr OpenR            ; otev©en° souboru
         jnc       LoadFIn3                 ; soubor otev©en OK

; ------ druhò pokus - otev©en° souboru DOSMAN.FIL

         mov       si,offset FileInf1
         mov       cl,11
         cld
         push      di
         rep       movsb                    ; p©enos textu DOSMAN.FIL
         pop       di
         mov       si,sp
         call      far ptr OpenR            ; otev©en° souboru
         jnc       LoadFI21                 ; soubor otev©en OK

; ------ t©et° pokus - otev©en° souboru *.BBS

         mov       si,offset FileInf2       ; text "*.BBS"
         mov       cl,6
         cld
         push      di
         rep       movsb                    ; p©enos textu *.BBS
         pop       di
         mov       si,sp
         call      far ptr ExisFile         ; test souboru
         jc        LoadFIn2                 ; soubor nenalezen
         mov       si,offset BuffDTA+DTAName ; jmÇno nalezenÇho souboru
         mov       cl,13
         cld
         rep       movsb                    ; p©enos jmÇna souboru
         mov       si,sp
         call      far ptr OpenR            ; otev©en° souboru
         jnc       LoadFI22                 ; soubor otev©en OK

; ------ p©i nenalezen° souboru zru®en° datovÇho bloku

LoadFIn2:mov       ax,ss:[bp-4]             ; á°slo segmentu koment†©ñ
         call      far ptr DelSeg           ; zru®en° datovÇho bloku
         mov       ax,ss:[bp-2]             ; segment okna
         call      far ptr GetDat           ; adresa okna
         mov       word ptr es:[AWinKomS],0 ; oznaáen° segmentu za zru®enò
         jmp       LoadFIn9                 ; soubor nenalezen nebo chyba

; ------ p©°znak, ëe je soubor DOSMAN.FIL

LoadFI21:or        byte ptr ds:[FileInfP],bit0 ; p©°znak souboru DOSMAN.FIL
         jmp       short LoadFIn3

; ------ p©°znak, ëe je informaán° soubor *.BBS

LoadFI22:or        byte ptr ds:[FileInfP],bit1 ; je soubor *.BBS

; ------ adresa bufferu koment†©e -> ES

LoadFIn3:push      ax
         mov       ax,ss:[bp-4]             ; segment bufferu koment†©e
         call      far ptr GetDat           ; poskytnut° adresy bufferu
         pop       ax

; ------ naáten° souboru do bufferu

         mov       cx,es:[0]                ; velikost bufferu v bajtech
         mov       di,2                     ; poá†teán° adresa k naáten°
         sub       cx,4                     ; 1 slovo dÇlka + 1 slovo rezerva
         mov       bx,cx                    ; £schova velikosti bufferu
         call      far ptr ReadFile         ; naáten° souboru do bufferu

; ------ kontrola, zda byl soubor naáten do bufferu celò

         push      ax
         push      es

         pushf
         mov       ax,ss:[bp-2]             ; segment okna
         call      far ptr GetDat
         popf

         jc        LoadFI32                 ; chyba áten°
         and       byte ptr es:[AWinPrm1],not bit7 ; nen° p©°znak necelÇho kom.
         cmp       cx,bx                    ; je buffer plnò ?
         jne       LoadFIn4                 ; buffer nen° plnò
LoadFI32:or        byte ptr es:[AWinPrm1],bit7 ; p©°znak necelÇho koment†©e
LoadFIn4:pop       es
         pop       ax

; ------ uzav©en° souboru

         call      far ptr ClosFile         ; uzav©en° souboru

; ------ nastaven° novÇ velikosti bufferu

         add       cx,di                    ; novò poáet bajtñ v bufferu
         mov       bx,cx                    ; BX <- novò poáet bajtñ v bufferu
         mov       es:[0],bx                ; nov† velikost bufferu
         mov       ax,ss:[bp-4]             ; segment bufferu koment†©e
         call      far ptr ModiSegS         ; nastaven° velikosti bufferu

; ------ korekce souboru DOSMAN.FIL

         test      byte ptr ds:[FileInfP],bit0 ; je soubor DOSMAN.FIL ?
         jz        LoadFI43                 ; nen° soubor DOSMAN.FIL
         call      KonvFil                  ; konverze souboru DOSMAN.FIL

; ------ korekce souboru BBS

LoadFI43:test      byte ptr ds:[FileInfP],bit1 ; je soubor BBS ?
         jz        LoadFI44                 ; nen° soubor BBS
         call      KonvBBS                  ; konverze souboru BBS

; ------ zak¢dov†n° bufferu (segment AX)

LoadFI44:push      cs
         call      near ptr KodBDTxt        ; k¢dov†n° bufferu

; ------ adresa koment†©ñ

         mov       ax,ss:[bp-2]             ; segment okna
         call      far ptr GetDat           ; adresa okna -> ES
         mov       ax,ss:[bp-4]             ; segment koment†©ñ
         call      far ptr GetSgAdr         ; adresa koment†©ñ -> DX

; ------ p©°prava k vyhled†n° parametrñ koment†©ñ

         cld
         push      ds
         mov       ds,dx                    ; DS <- segment koment†©ñ
         mov       si,2                     ; ukazatel zaá†tku textu

; ------ nalezen° prvn°ho nepr†zdnÇho ©†dku

LoadFIn5:cmp       si,ds:[0]                ; je konec dat ?
         jae       LoadFI54                 ; je konec dat - nen° nadpis
         mov       ah,0
         lodsb                              ; dÇlka ©†dku
         cmp       al,1                     ; je pr†zdnò ©†dek ?
         jne       LoadFI50                 ; nen° pr†zdnò ©†dek
         inc       si                       ; zaá†tek dal®°ho ©†dku
         jmp       short LoadFIn5           ; dal®° ©†dek

; ------ test, zda je ©†dek nadpisu (tj. zda ©†dek zaá°n† mezerami)

LoadFI50:cmp       byte ptr ds:[si]," "     ; jsou mezery na zaá†tku ?
         je        LoadFI51                 ; jsou mezery - je nadpis
         cmp       byte ptr ds:[si],TAB     ; tabul†tor na zaá†tku ?
         je        LoadFI51                 ; jsou tabul†tory - je nadpis
         dec       si                       ; n†vrat ukazatele na zaá†tek
         jmp       short LoadFI54           ; nen° nadpis - je platnò ©†dek

; ------ nalezen° zaá†tku textu nadpisu

LoadFI51:inc       si                       ; p©eskoáen° mezery
         dec       ax                       ; sn°ëen° dÇlky ©†dku
         cmp       byte ptr ds:[si]," "
         je        LoadFI51                 ; je £vodn° mezera - dal®° znak
         cmp       byte ptr ds:[si],TAB
         je        LoadFI51                 ; je £vodn° tabul†tor - dal®° znak

; ------ parametry nadpisu

         dec       ax
         mov       es:[AWinKomA],si         ; adresa nadpisu
         mov       es:[AWinKomD],ax         ; dÇlka nadpisu
         add       si,ax                    ; dal®° ©†dek
         inc       si

; ------ parametry ©†dkñ koment†©ñ

LoadFI54:mov       es:[AWinKomB],si         ; adresa zaá†tku ©†dkñ koment†©ñ
         mov       ax,ds:[0]                ; poáet bajtñ v bufferu
         sub       ax,si                    ; dÇlka koment†©ñ
         mov       es:[AWinKomN],ax         ; poáet bajtñ koment†©ñ

; ------ p©°prava ke konverzi na velk† p°smena

         mov       bx,ds:[0]                ; poáet bajtñ v bufferu

; ------ test, zda je dal®° ©†dek

         cmp       si,bx                    ; je konec dat ?
         jae       LoadFIn8                 ; konec dat

; ------ dÇlka ©†dku -> CX

LoadFIn6:mov       ah,0
         lodsb                              ; AX <- dÇlka ©†dku
         xchg      ax,cx                    ; CX <- dÇlka ©†dku

; ------ test, zda je to platnò ©†dek

         lodsb                              ; prvn° znak
         cmp       al,TAB
         je        LoadFI67                 ; nen° platnò ©†dek
         cmp       al," "
         je        LoadFI67                 ; nen° platnò ©†dek
         cmp       al,0
         je        LoadFI67                 ; je pr†zdnò ©†dek

; ------ konverze jmÇna souboru na velk† p°smena

LoadFI62:cmp       al,"a"
         jb        LoadFI63
         cmp       al,"z"
         ja        LoadFI63
         sub       byte ptr ds:[si-1],32    ; konverze na velkÇ p°smeno
LoadFI63:lodsb                              ; naáten° dal®°ho znaku
         cmp       al," "
         je        LoadFI64                 ; je mezera
         cmp       al,TAB
LoadFI64:loopne    LoadFI62                 ; dal®° znak (nen°-li oddàlovaá)

; ------ p©°prava pro dal®° ©†dek

LoadFI67:dec       si                       ; n†vrat ukazatele znakñ
LoadFI68:add       si,cx                    ; adresa dal®°ho ©†dku
         cmp       si,bx                    ; je konec dat ?
         jb        LoadFIn6                 ; konverze dal®°ho ©†dku
LoadFIn8:pop       ds

; ------ nalezen° p©ep°naáe fontñ (DX=segment dat, CLD)

         mov       es,dx                    ; ES <- segment dat
         xor       cx,cx                    ; CX <- 0
         mov       di,2                     ; ukazatel dat v bufferu
LoadFI81:add       di,cx                    ; adresa dal®°ho ©†dku
         cmp       di,es:[0]                ; je konec dat ?
         jae       LoadFIn9                 ; je konec dat - nen° p©ep°naá
         mov       cl,es:[di]               ; dÇlka textu ©†dku
         inc       di                       ; zaá†tek textu
         cmp       byte ptr es:[di],"["     ; je nàjakò p©ep°naá ?
         jne       LoadFI81                 ; nen° p©ep°naá

         mov       si,offset KodISwcT       ; p©ep°naá "KOD="
         call      far ptr GetTISwc         ; naáten° p©ep°naáe
         jc        LoadFI81                 ; neplatnò p©ep°naá

         push      cx
         xchg      ax,cx                    ; CX <- naátenò p©ep°naá
         mov       dl,bit1                  ; p©°prava
         shl       dl,cl                    ; DL = aktu†ln° k¢d
         pop       cx

; ------ zru®en° ©†dku s p©ep°naáem

         dec       di                       ; zaá†tek ©†dku
         inc       cx                       ; dÇlka ©†dku + 1
         mov       ax,ss:[bp-4]             ; á°slo segmentu koment†©ñ
         call      far ptr DelDat           ; zru®en° ©†dku
         push      es
         mov       ax,ss:[bp-2]             ; segment okna
         call      far ptr GetDat           ; adresa okna -> ES
         sub       es:[AWinKomN],cx         ; sn°ëen° poátu bajtñ koment†©ñ
         pop       es

; ------ test, zda k¢d odpov°d†

         mov       cl,ds:[CodePagK]         ; aktu†ln° k¢dov† str†nka
         cmp       cl,0
         je        LoadFIn9                 ; k¢d neuráen
         mov       dh,bit1                  ; p©°prava
         shl       dh,cl                    ; bit2=KEYBCS2, bit3=Latin 2
         cmp       dh,dl                    ; màn° se k¢d ?
         je        LoadFIn9                 ; k¢d se nemàn°

; ------ konverze fontñ DL -> DH

         mov       si,2                     ; zaá†tek dat
LoadFI85:cmp       si,es:[0]                ; je konec dat ?
         jae       LoadFIn9                 ; je konec dat
         mov       cl,es:[si]               ; dÇlka ©†dku
         inc       si                       ; zaá†tek textu
         call      far ptr KonvFnt          ; konverze fontñ
         add       si,cx                    ; adresa dal®°ho ©†dku
         jmp       short LoadFI85           ; dal®° ©†dek

; ------ n†vrat registrñ

LoadFIn9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

LoadFInf ENDP

; -----------------------------------------------------------------------------
;        konverze souboru DOSMAN.FIL (á°slo segmentu AX)
; -----------------------------------------------------------------------------

KonvFil  PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      dx
         push      di
         push      es

; ------ p©°prava ukazatelñ

         call      far ptr GetDat           ; adresa bufferu -> ES
         mov       di,2                     ; zaá†tek dat
         mov       bx,es:[di-2]             ; konec dat v bufferu
         mov       cx,1                     ; ru®it/vkl†dat 1 znak

; ------ test, zda je platnò ©†dek (podle prvn°ho znaku - nen° mezera ani TAB)

KonvFil1:cmp       di,bx                    ; je konec dat ?
         jae       KonvFil9                 ; je konec dat
         cmp       byte ptr es:[di]," "     ; zaá°n† ©†dek mezerou ?
         je        KonvFil7                 ; ©†dek zaá°n† mezerou
         cmp       byte ptr es:[di],TAB     ; zaá°n† ©†dek tabul†torem ?
         je        KonvFil7                 ; ©†dek zaá°n† tabul†torem

; ------ vypu®tàn° mezer ze jmÇna

         mov       dx,8                     ; poáet znakñ
         call      Konv0Fil                 ; redukce jmÇna souboru
         jnc       KonvFil2                 ; p©eru®en° operace

; ------ vloëen° znaku teáky

         call      far ptr InsDat           ; vytvo©en° m°sta pro teáku
         jc        KonvFil2                 ; chyba
         mov       byte ptr es:[di],"."     ; oddàlovac° teáka
         inc       di                       ; p©eskoáen° znaku teáky
         inc       bx                       ; oprava konce bufferu

; ------ vypu®tàn° mezer z p©°pony

KonvFil2:mov       dx,3                     ; poáet znakñ
         call      Konv0Fil                 ; redukce p©°pony jmÇna souboru

; ------ doplnàn° tabul†toru za jmÇno a p©°ponu

         cmp       di,bx                    ; je konec dat ?
         jae       KonvFil7                 ; je konec dat
         cmp       byte ptr es:[di],LF      ; je konec ©†dku ?
         je        KonvFil7                 ; je konec ©†dku
         cmp       byte ptr es:[di],CR      ; je konec ©†dku ?
         je        KonvFil7                 ; je konec ©†dku
         mov       byte ptr es:[di],TAB     ; oddàlovac° tabul†tor

; ------ nalezen° konce ©†dku LF

KonvFil7:cmp       di,bx                    ; je konec dat ?
         jae       KonvFil9                 ; je konec dat
         inc       di                       ; zvò®en° ukazatele dat
         cmp       byte ptr es:[di-1],LF    ; byl to konec ©†dku ?
         jne       KonvFil7                 ; nebyl konec ©†dku - dal®° znak

; ------ p©eskoáen° znakñ CR

KonvFil8:cmp       di,bx                    ; je konec dat ?
         jae       KonvFil9                 ; je konec dat
         cmp       byte ptr es:[di],CR      ; je to znak CR ?
         jne       KonvFil1                 ; nen° CR - dal®° ©†dek
         inc       di                       ; p©eskoáen° znaku CR
         jmp       short KonvFil8           ; dal®° znak

; ------ n†vrat registrñ

KonvFil9:pop       es
         pop       di
         pop       dx
         pop       cx
         pop       bx
         ret

KonvFil  ENDP

; -----------------------------------------------------------------------------
;        redukce á†sti jmÇna nebo p©°pony (NC=p©eru®en°)
; -----------------------------------------------------------------------------

Konv0Fil PROC      NEAR

; ------ test, zda je konec dat

Konv0Fl2:cmp       di,bx                    ; je konec dat ?
         jae       Konv0Fl8                 ; je konec dat
         cmp       byte ptr es:[di],LF      ; je konec ©†dku ?
         je        Konv0Fl8                 ; je konec ©†dku

; ------ vypu®tàn° znaku "*"

         cmp       byte ptr es:[di],"|"     ; je znak "|" ?
         je        Konv0Fl3                 ; je znak "|"
         cmp       byte ptr es:[di],"*"     ; je znak "*" ?
         jne       Konv0Fl4                 ; nen° znak "*"
Konv0Fl3:call      far ptr DelDat           ; zru®en° znaku "*"
         dec       bx                       ; oprava konce bufferu
         jmp       short Konv0Fl2           ; dal®° znak

; ------ vypu®tàn° znaku mezery

Konv0Fl4:cmp       byte ptr es:[di]," "     ; je mezera ?
         jne       Konv0Fl6                 ; nen° mezera
         call      far ptr DelDat           ; zru®en° znaku mezery
         dec       bx                       ; oprava konce bufferu
         dec       di                       ; p©ednastaven° ukazatele dat

; ------ p©°prava pro dal®° znak

Konv0Fl6:inc       di                       ; zvò®en° ukazatele dat
         dec       dx                       ; á°taá dÇlky jmÇna
         jnz       Konv0Fl2                 ; dal®° znak jmÇna
         stc                                ; p©°znak pokraáov†n° operace
Konv0Fl8:ret

Konv0Fil ENDP

; -----------------------------------------------------------------------------
;        konverze souboru BBS (á°slo segmentu AX)
; -----------------------------------------------------------------------------

KonvBBS  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      ds

; ------ p©°prava ukazatelñ

         call      far ptr GetSgAdr         ; adresa bufferu
         mov       ds,dx                    ; DS <- adresa bufferu
         mov       si,2                     ; zaá†tek dat
         mov       cx,ds:[si-2]             ; dÇlka dat
         sub       cx,si                    ; bez £vodn°ho slova
         jbe       KonvBBS9                 ; nejsou dal®° data
         cld

; ------ test, zda je platnò ©†dek (podle prvn°ho znaku - nen° mezera ani TAB)

KonvBBS1:jcxz      KonvBBS9                 ; konec dat
         lodsb
         dec       cx
         cmp       al," "
         je        KonvBBS6                 ; nen° platnò ©†dek
         cmp       al,TAB
         je        KonvBBS6                 ; nen° platnò ©†dek

; ------ p©eskoáen° jmÇna souboru (po mezeru nebo konec ©†dku)

KonvBBS2:jcxz      KonvBBS9                 ; konec dat
         lodsb
         dec       cx
         cmp       al,LF
         je        KonvBBS7                 ; konec ©†dku
         cmp       al," "
         je        KonvBBS3
         cmp       al,TAB
         jne       KonvBBS2

; ------ konverze velikosti souboru

KonvBBS3:call      KonvSBBS                 ; p©eskoáen° mezer
         call      KonvNBBS                 ; konverze á°sla na mezery

; ------ konverze data souboru

         call      KonvSBBS                 ; p©eskoáen° mezer
         call      KonvNBBS                 ; konverze á°sla na mezery
         call      KonvOBBS                 ; konverze oddàlovaáe na mezeru
         call      KonvNBBS                 ; konverze á°sla na mezery
         call      KonvOBBS                 ; konverze oddàlovaáe na mezeru
         call      KonvNBBS                 ; konverze á°sla na mezery

; ------ nalezen° konce ©†dku LF

KonvBBS6:jcxz      KonvBBS9                 ; konec dat
         lodsb
         dec       cx
         cmp       al,LF
         jne       KonvBBS6

; ------ p©eskoáen° znakñ CR

KonvBBS7:jcxz      KonvBBS9                 ; konec dat
KonvBBS8:cmp       byte ptr ds:[si],CR
         jne       KonvBBS1                 ; nen° CR
         inc       si
         loop      KonvBBS8                 ; dal®° pokus

; ------ n†vrat registrñ

KonvBBS9:pop       ds
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

KonvBBS  ENDP

; ------ p©eskoáen° mezer

KonvSBBS:jcxz      KnvSBBS2
         cmp       byte ptr ds:[si]," "
         je        KnvSBBS1
         cmp       byte ptr ds:[si],TAB
         jne       KnvSBBS2
KnvSBBS1:inc       si
         dec       cx
         jmp       short KonvSBBS

KnvSBBS2:ret

; ------ konverze á°sla na mezery

KonvNBBS:jcxz      KnvNBBS4
         cmp       byte ptr ds:[si],"0"
         jb        KnvNBBS4
         cmp       byte ptr ds:[si],"9"
         ja        KnvNBBS4
         mov       byte ptr ds:[si]," "
         inc       si
         dec       cx
         jmp       short KonvNBBS
KnvNBBS4:ret

; ------ konverze oddàlovaáe na mezery

KonvOBBS:jcxz      KnvOBBS4
         mov       al,ds:[si]
         cmp       al,"."
         je        KnvOBBS2
         cmp       al,"-"
         je        KnvOBBS2
         cmp       al,"/"
         je        KnvOBBS2
         cmp       al,":"
         je        KnvOBBS2
         cmp       al,","
         jne       KnvOBBS4

KnvOBBS2:mov       byte ptr ds:[si]," "
         inc       si
         dec       cx
         jmp       short KonvOBBS
KnvOBBS4:ret

; *****************************************************************************
;                               KodBDTxt
;          zak¢dov†n° datovÇho textu v bufferu (posouv† pamàüovÇ bloky !)
;   nahrad° ©†dky s CR/LF ©†dky s udanou dÇlkou (1 bajt) a ukonáenÇ bajtem 0
; -----------------------------------------------------------------------------
; VSTUP: AX=segment bufferu koment†©ñ (mus° bòt platnò !)
;        DS=datovò segment
; -----------------------------------------------------------------------------
; Struktura bufferu po k¢dov†n°: 1. slovo = poáet bajtñ v bufferu celkem
;                                1. bajt ©†dku = dÇlka ©†dku váetnà 0 (1 aë 255)
;                                     text
;                                     koncov† 0
; *****************************************************************************

KodBDTxt PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ adresa bufferu

         call      far ptr GetDat           ; adresa bufferu

; ------ vytvo©en° m°sta pro popisovaáe

         mov       cx,2                     ; vloë° se 2 bajty (rezerva)
         mov       di,2                     ; adresa k vloëen° 2 bajtñ
         call      far ptr InsDat           ; vloëen° 2 bajtñ
         jnc       KodBDTx0                 ; operace OK
         cmp       es:[di-2],di             ; jsou nàjak† data ?
         jb        KodBDTx0                 ; nen° nic
         sub       es:[di-2],di             ; zru®en° 2 posledn°ch znakñ
         call      far ptr InsDat           ; druhò pokus o operaci

; ------ p©°prava registrñ (DI=ukl†dac° adresa)

KodBDTx0:cld
         push      ax                       ; segment bufferu
         push      ds                       ; datovò segment

         push      es
         pop       ds                       ; DS <- segment bufferu
         mov       si,4                     ; poá†tek dat
         mov       cx,ds:[si-4]             ; poáet bajtñ v bufferu
         sub       cx,si                    ; poáet platnòch dat v bufferu
         jbe       KodBDTx8                 ; nejsou data

; ------ p©°prava ke k¢dov†n° jednoho ©†dku

KodBDTx1:mov       bx,di                    ; £schova zaá†tku ©†dku
         inc       di                       ; zaá†tek k ukl†d†n° dat ©†dku
         xor       dx,dx                    ; á°taá dÇlky ©†dku
         mov       ah,0                     ; p©ede®lò znak - nen°

; ------ naáten° znaku a test konce ©†dku

KodBDTx2:jcxz      KodBDTx6                 ; nen° dal®° znak
         lodsb                              ; naáten° znaku
         dec       cx                       ; sn°ëen° á°taáe zbylòch znakñ
         cmp       ax,CR*HI + LF            ; je konec ©†dku ?
         je        KodBDTx4                 ; je konec ©†dku
         cmp       ax,LF*HI + CR
         je        KodBDTx4                 ; je konec ©†dku

; ------ uloëen° znaku

         cmp       dl,254                   ; je ©†dek plnò ?
         je        KodBDTx3                 ; ©†dek je plnò
         cmp       al,0                     ; je zak†zanò znak ?
         je        KodBDTx3                 ; je zak†zanò znak - ignorov†n°
         stosb                              ; uloëen° znaku
         inc       dx                       ; zvò®en° á°taáe dÇlky ©†dku
KodBDTx3:mov       ah,al                    ; £schova p©ede®lÇho znaku
         jmp       short KodBDTx2           ; dal®° znak

; ------ odstranàn° p©ede®lÇho CR nebo LF z konce ©†dku (bylo nàco uloëeno)

KodBDTx4:mov       al,ds:[di-1]             ; p©ede®lò znak
         cmp       al,CR
         je        KodBDTx5                 ; je CR - odstranàn°
         cmp       al,LF
         jne       KodBDTx6                 ; konec nebyl uloëen (bylo p©eteáen°)

; ------ vypu®tàn° mezer z konce ©†dku
; !!!!  (to vad° p©i uloëen° koment†©e s dÇlkou 0)

KodBDTx5:dec       di                       ; n†vrat posledn°ho znaku CR nebo LF
         dec       dx                       ; sn°ëen° á°taáe znakñ
KodBDTx6:
;         or        dx,dx                    ; je nàco v ©†dku ?
;         jz        KodBDTx7                 ; ©†dek je pr†zdnò
;         mov       al,ds:[di-1]             ; p©ede®lò znak
;         cmp       al," "                   ; je mezera ?
;         je        KodBDTx5                 ; vypu®tàn° mezery
;         cmp       al,TAB                   ; je tabul†tor ?
;         je        KodBDTx5                 ; vypu®tàn° tabul†toru

; ------ konec ©†dku

KodBDTx7:mov       al,0
         stosb                              ; oznaáen° konce ©†dku
         inc       dx                       ; zvò®en° á°taáe dÇlky
         mov       ds:[bx],dl               ; dÇlka ©†dku

; ------ p©°prava pro dal®° ©†dek

         or        cx,cx                    ; jsou dal®° data ?
         jnz       KodBDTx1                 ; jsou dal®° data

KodBDTx8:mov       cx,ds:[0]                ; poáet bajtñ v bufferu
         pop       ds                       ; datovò segment
         pop       ax                       ; segment bufferu

; ------ nastaven° novÇ velikosti bufferu (DI=adresa konce dat)

         sub       cx,di                    ; poáet zbylòch dat
         call      far ptr DelDat           ; zru®en° zbytku dat

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

KodBDTxt ENDP

; *****************************************************************************
;                               DekBDTxt
;                  dek¢dov†n° datovÇho textu v bufferu
;     nahrad° ©†dky s udanou dÇlkou (a ukonáenÇ bajtem 0) ©†dky s CR/LF
; -----------------------------------------------------------------------------
; VSTUP: AX=segment bufferu koment†©ñ (mus° bòt platnò !)
;        DS=datovò segment
; -----------------------------------------------------------------------------
; Struktura bufferu po k¢dov†n°: 1. slovo = poáet bajtñ v bufferu celkem
;                                1. bajt ©†dku = dÇlka ©†dku váetnà 0 (1 aë 255)
;                                     text
;                                     koncov† 0
; *****************************************************************************

DekBDTxt PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      di
         push      ds
         push      es

; ------ p©°prava registrñ

         call      far ptr GetDat           ; adresa bufferu
         push      es
         pop       ds                       ; DS <- adresa bufferu
         mov       si,2                     ; átec° adresa
         mov       di,si                    ; ukl†dac° adresa
         cmp       si,ds:[si-2]             ; jsou nàjak† data ?
         jae       DekBDTx2                 ; nejsou ë†dn† data
         cld

; ------ dek¢dov†n° jednoho ©†dku

DekBDTx1:lodsb                              ; dÇlka ©†dku
         mov       ah,0
         dec       ax                       ; bez koncovÇ 0
         xchg      ax,cx                    ; CX <- dÇlka ©†dku
         shr       cx,1                     ; dÇlka ©†dku ve slovech
         rep       movsw                    ; p©enos á†sti po slovech
         adc       cx,cx                    ; lichò bajt
         rep       movsb                    ; p©enos lichÇho bajtu
         mov       ax,LF*HI + CR            ; ukonáen° ©†dku CR/LF
         stosw                              ; uloëen° koncovÇho CR/LF
         inc       si                       ; p©eskoáen° koncovÇ 0
         cmp       si,ds:[0]                ; je jië konec ©†dku ?
         jb        DekBDTx1                 ; dek¢dov†n° dal®°ho ©†dku

; ------ n†vrat registrñ

DekBDTx2:pop       es
         pop       ds
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

DekBDTxt ENDP

; *****************************************************************************
;                               InitDInf
;                     inicializace informac° o disku
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo okna
;        DS=datovò segment
; VùSTUP: CY=p©eru®en° nebo chyba (nic nebylo zmànàno)
; *****************************************************************************

InitDInf PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      es

; ------ adresa datovÇho bloku

         call      far ptr GetDat           ; poskytnut° adresy bloku
         jc        InitDI19                 ; chyba - neplatnò blok

; ------ p©°prava p©°znaku CD-ROM disku

         and       byte ptr es:[AWinPrm0],not bit6 ; nen° CD-ROM
         mov       bl,es:[AWinDisk]         ; á°slo disku okna
         mov       bh,0
         mov       bl,ds:[bx+DiskITab]      ; parametry disku
         and       bl,7                     ; typ disku
         cmp       bl,6                     ; je to CD-ROM ?
         jne       InitDIn1                 ; nen° CD-ROM
         or        byte ptr es:[AWinPrm0],bit6 ; p©°znak CD-ROM

; ------ naáten° informac° o disku

InitDIn1:or        byte ptr es:[AWinPrm0],bit2 ; diskovÇ informace zn†mÇ
         mov       al,es:[AWinDisk]         ; á°slo disku okna
         call      far ptr GetDInfo         ; poskytnut° informac° o disku AL
         jnc       InitDIn2                 ; operace OK
         call      far ptr TestBreak        ; je chyba disku ?
InitDI19:jc        IniDInf9                 ; chyba disku nebo p©eru®en° operace

; ------ neplatnÇ informace

         or        byte ptr es:[AWinPrm0],bit7 ; neplatnÇ diskovÇ informace
         jmp       short InitDIn3

; ------ vòpoáet velikosti alokaán°ho bloku

InitDIn2:and       byte ptr es:[AWinPrm0],not bit7 ; platnÇ diskovÇ informace

InitDIn3:xchg      cx,dx                    ; CX<-blokñ celkem, DX<-bajtñ/sektor
         mul       dx                       ; vòpoáet poátu bajtñ na blok
         or        dx,dx                    ; je blok > 64 KB ?
         jz        InitDIn4                 ; blok je OK
         mov       ax,-1                    ; omezen° velikosti alokaán°ho bloku
InitDIn4:cmp       ax,32                    ; minim†ln° velikosti alok. bloku
         jae       InitDIn5                 ; velikost bloku je OK
         mov       ax,32                    ; minim†ln° velikost alok. bloku
InitDIn5:mov       es:[AWinAlok],ax         ; velikost alokaán°ho bloku

; ------ vòpoáet celkovÇ kapacity disku

         xchg      ax,cx                    ; AX<-blokñ celkem, CX<-velikost bloku
         mul       cx                       ; celkov† kapacita disku

; ------ kapacita CD disku

         cmp       word ptr ds:[GetCDMxS+2],0 ; je £daj pro CD disk ?
         je        IniDInf8                 ; nen° £daj pro CD disk

         mov       ax,word ptr ds:[GetCDMxS] ; kapacita CD disku
         mov       dx,word ptr ds:[GetCDMxS+2]

IniDInf8:mov       word ptr es:[AWinDMax],ax         ; celkov† kapacita - LOW
         mov       word ptr es:[AWinDMax+2],dx       ; celkov† kapacita - HIGH

; ------ vòpoáet volnÇ kapacity disku

         xchg      ax,bx                    ; poáet volnòch alok. blokñ
         mul       cx                       ; vòpoáet volnÇ kapacity
         mov       word ptr es:[AWinDFre],ax         ; voln† kapacita - LOW
         mov       word ptr es:[AWinDFre+2],dx       ; voln† kapacita - HIGH
         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

IniDInf9:pop       es
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InitDInf ENDP

; *****************************************************************************
;                               DuplAWin
;     duplikace adres†©ovÇho okna (bez souborñ, nevytv†©° segment koment†©ñ)
; -----------------------------------------------------------------------------
; VSTUP: AX=okno k duplikaci (á°slo datovÇho bloku)
;        DS=datovò segment
; VùSTUP:BX=á°slo segmentu novÇho okna (p©i chybà BX=0)
;        ES=segment novÇho okna
;        CY=nedostatek pamàti
; *****************************************************************************

DuplAWin PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di

; ------ vytvo©en° novÇho adres†©ovÇho okna -> AX, ES

         xchg      ax,bx                    ; BX <- starÇ okno
         call      far ptr CreatAWn         ; vytvo©en° novÇho adres†©ovÇho okna
         xchg      ax,bx                    ; BX <- novÇ okno, AX <- starÇ okno
         jc        DuplAWn9                 ; chyba - nedostatek pamàti
         call      far ptr GetSgAdr         ; DX <- adresa starÇho okna
         jc        DuplAWn9                 ; chybnÇ á°slo okna

; ------ kopie definice do novÇho okna

         push      ds
         mov       ds,dx                    ; adresa starÇho okna
         cld                                ; smàr nahoru
         mov       di,AWinPrm0
         mov       si,di
         movsb                              ; AWinPrm0
         movsw                              ; AWinPrm1 a AWinPrm2
         and       byte ptr es:[di-2],not bit6 ; nebyl koment†©

         mov       di,AWinDNum
         mov       si,di
         mov       cx,(2+(AWinDir0-AWinDir)+12+1 +2+4+4 +1)/2
         rep       movsw                    ; p©enos aktivn°ho adres†©e+kapacita

         mov       di,AWinLabN
         mov       si,di
         mov       cx,(AWin-AWinLabN+1)/2   ; dÇlka definice masky
         rep       movsw                    ; p©enos n†và®t° a filtru

         pop       ds
         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

DuplAWn9:pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DuplAWin ENDP

; *****************************************************************************
;                                   CreatAWn
;      vytvo©en° popisovaáe adres†©ovÇho okna (nevytv†©° segment koment†©ñ)
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:AX=á°slo pamàüovÇho bloku (p©i chybà AX=0)
;        ES=adresa pamàüovÇho bloku
;        CY=nedostatek pamàti (AX=0)
; *****************************************************************************

CreatAWn PROC      FAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      si
         push      di

; ------ vytvo©en° novÇho datovÇho bloku

         call      far ptr CreatSeg         ; vytvo©en° datovÇho segmentu
         jnc       CreatAW2
         jmp       CreatAW8                 ; chyba - nedostatek pamàti

; ------ modifikace bloku na pot©ebnou velikost

CreatAW2:mov       bx,AWin                  ; inicializaán° velikost bloku
         call      far ptr ModiSegS         ; nastaven° velikosti bloku
         jc        CreatAW7                 ; chyba - nedostatek pamàti

; ------ inicializaán° nulov†n° popisovaáe

         call      far ptr GetDat           ; poskytnut° adresy bloku
         xor       di,di                    ; poá†teán° adresa v bloku
         push      ax                       ; á°slo bloku
         xchg      ax,bx
         stosw                              ; velikost dat v segmentu
         xchg      ax,bx
         mov       cx,(AWin-2+1)/2          ; dÇlka tabulky ve slovech
         xor       ax,ax                    ; nulovac° slovo
         cld
         rep       stosw                    ; vymaz†n° tabulky
         pop       ax

; ------ inicializace dat popisovaáe

         xor       di,di                    ; DI <- 0
         mov       byte ptr es:[di+AWinPrm0],bit4 ; je pot©eba zobrazen° okna
         mov       byte ptr es:[di+AWinPrm1],bit3 ; p©°znak adres†©e
         mov       word ptr es:[di+AWinSouI],bx      ; adresa tabulky indexñ
         mov       word ptr es:[di+AWinKomI],bx      ; adresa tabulky indexñ koment†©ñ
         mov       word ptr es:[di+AWinAlok],200h ; velikost alokaán°ho bloku
         mov       word ptr es:[di+AWinFilF.AWinFSz2],-1 ; maxim†ln° velikost souboru
         mov       word ptr es:[di+AWinFilF.AWinFSz2+2],-1
         mov       byte ptr es:[AWinFilF.AWinFilN],3 ; dÇlka masky
         mov       word ptr es:[AWinFilF.AWinFilt],".*" ; maska
         mov       byte ptr es:[AWinFilF.AWinFilt+2],"*"
         mov       byte ptr es:[AWinFilP],bit0+bit2 ; maska p©i naá°t†n°, adres†© vëdy

         push      cs
         call      near ptr NormIAWn        ; normalizace adresy tabulek

; ------ p©enesen° textu aktivn°ho adres†©e

         cld
         mov       di,AWinDir               ; buffer adres†©e okna
         mov       si,offset AktPath        ; aktivn° cesta
         mov       cx,ds:[AktPathN]         ; dÇlka textu cesty
         mov       es:[AWinDNum],cx         ; dÇlka textu adres†©e
         inc       cx                       ; p©enese se i koncov† 0
         rep       movsb                    ; p©enos textu adres†©e
         mov       bl,ds:[AktPath]          ; aktivn° disk
         sub       bl,"A"                   ; korekce na á°slo disku
         mov       es:[AWinDisk],bl         ; aktivn° disk
         clc                                ; p©°znak operace OK
         jmp       short CreatAW9

; ------ p©i chybà zru®en° bloku segmentu okna

CreatAW7:call      far ptr DelSeg           ; zru®en° datovÇho bloku
CreatAW8:xor       ax,ax                    ; p©°znak neplatnÇho okna
         stc                                ; p©°znak chyby

; ------ n†vrat registrñ

CreatAW9:pop       di
         pop       si
         pop       cx
         pop       bx
         ret

CreatAWn ENDP

; *****************************************************************************
;                                 NormIAWn
;                    normalizace ukazatelñ tabulek okna
; -----------------------------------------------------------------------------
; VSTUP: ES=segment adresy okna
; *****************************************************************************

NormIAWn PROC      FAR

; ------ £schova registrñ

         push      ax

; ------ normalizace adresy indexovÇ tabulky souborñ

         mov       ax,word ptr es:[AWinSouI]
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1
         add       word ptr es:[AWinSouI+2],ax
         and       word ptr es:[AWinSouI],0fh

; ------ normalizace adresy indexovÇ tabulky koment†©ñ

         mov       ax,word ptr es:[AWinKomI]
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1
         add       word ptr es:[AWinKomI+2],ax
         and       word ptr es:[AWinKomI],0fh

; ------ n†vrat registrñ

         pop       ax
         ret

NormIAWn ENDP

; *****************************************************************************
;                                DeletAWn
;                       zru®en° adres†©ovÇho okna
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo okna (0=neplatnÇ)
;        DS=datovò segment
; *****************************************************************************

DeletAWn PROC      FAR

; ------ £schova registrñ

         push      ax
         push      es

; ------ adresa okna

         call      far ptr GetDat           ; adresa okna
         jc        DeletAW9                 ; neplatnÇ okno

; ------ zru®en° segmentu okna

         push      word ptr es:[AWinKomS]   ; segment pozn†mek
         call      far ptr DelSeg           ; p©i chybà zru®en° novÇho segmentu

; ------ zru®en° segmentu pozn†mek

         pop       ax                       ; AX <- segment pozn†mek
         call      far ptr DelSeg           ; zru®en° segmentu pozn†mek

; ------ n†vrat registrñ

DeletAW9:pop       es
         pop       ax
         ret

DeletAWn ENDP

; *****************************************************************************
;                                 SelWDir
;             vòbàr souborñ v adres†©ovÇm oknà podle filtru
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo datovÇho bloku
;        DS=datovò segment
; VùSTUP:CY=nedostatek pamàti (nic se nezmànilo)
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) á°slo datovÇho bloku
;                   SS:[BP-4] (2) adresa datovÇho bloku
;                   SS:[BP-6] (2) á°taá za©azenòch poloëek
;                   SS:[BP-8] (2) á°taá souborñ k testov†n°
;                   SS:[BP-10] (2) ukazatel adresy poloëky SEGMENT
;                   SS:[BP-12] (2) ukazatel adresy poloëky OFFSET
;                   SS:[BP-14] (2) adresa tabulky indexñ SEGMENT
;                   SS:[BP-16] (2) ukazatel adresy indexu OFFSET
;                   SS:[BP-18] (2) adresa konce cesty v bufferu
;                   SS:[BP-20] (2) datovò segment
;                   SS:[BP-22] (2) á°taá zobrazenòch souborñ
;                   SS:[BP-26] (4) st©adaá zabranÇ kapacity soubory
;
;                   SS:[BP-27] (1) parametry filtru
;                                    bit 0: 1=maska p©i naá°t†n°
;                                    bit 2: 1=adres†© naá°st vëdy
;                                    bit 6,7: 0=v®echny
;                                             1=programy
;                                             2=maska
;                   SS:[BP-28] (1)
;                   SS:[BP-30] (2) pracovn° identifik†tor DTA
;                   SS:[BP-31] (1)
;                   SS:[BP-44] (13) jmÇno souboru s p©°ponou ASCIIZ
;                   SS:[BP-48] (4)  velikost souboru
;                   SS:[BP-50] (2)  datum souboru
;                   SS:[BP-52] (2)  áas souboru
;                   SS:[BP-53] (1)  atributy souboru
;                   SS:[BP-74] (21) pracovn° adresa DTA - zaá†tek
;
;                   SS:[BP-160] (86) jmÇno prohled†vanÇho souboru
;
;                              (80) £schova parametrñ pro vòbàr souborñ
; *****************************************************************************

SelWDir  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es
         mov       bp,sp
         sub       sp,160 + 80

; ------ £schova parametrñ pro hled†n° souborñ

         mov       di,sp                    ; buffer v z†sobn°ku
         mov       si,offset SrcInit        ; zaá†tek parametrñ
         push      ss
         pop       es                       ; ES <- segment bufferu
         mov       cx,80/2                  ; dÇlka definice parametrñ
         cld
         rep       movsw                    ; £schova parametrñ
         mov       byte ptr ds:[SrcTextN],cl ; nen° text k hled†n°

; ------ poskytnut° popisovaáe okna

         mov       ss:[bp-20],ds            ; datovò segment
         mov       ss:[bp-2],ax             ; á°slo datovÇho bloku
         call      far ptr GetDat           ; poskytnut° adresy bloku
         jc        SelWDir1                 ; chybnÇ á°slo datovÇho bloku
         mov       ss:[bp-4],es             ; adresa datovÇho bloku

         test      byte ptr es:[AWinPrm1],bit3 ; je to adres†©ovÇ okno ?
         jz        SelWDir1                 ; nen° to adres†©ovÇ okno

; ------ inicializace parametrñ pro vòbàr souborñ

         push      ds
         push      es

         push      es
         push      ds
         pop       es                       ; ES <- datovò segment
         pop       ds                       ; DS <- segment okna
         mov       si,AWinFilF.AWinFAtr              ; zaá†tek parametrñ
         mov       di,offset SrcInit        ; dÇlka definice vòbàru souborñ
         mov       cx,80/2                  ; dÇlka definice parametrñ
         cld
         rep       movsw                    ; uloëen° definice parametrñ

; ------ £schova adres†©e okna

         push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku
         lea       di,[bp-160]              ; buffer jmÇna souboru
         mov       si,AWinDir               ; adres†© okna
         mov       cx,ds:[AWinDNum]         ; dÇlka textu adres†©e
         rep       movsb                    ; £schova adres†©e okna

         cmp       byte ptr es:[di-1],"\"
         je        SelWDir0
         mov       byte ptr es:[di],"\"
         inc       di
SelWDir0:mov       ss:[bp-18],di            ; adresa konce cesty v bufferu

         pop       es
         pop       ds

; ------ nastaven° velikosti bloku

         push      ax
         mov       ax,2+3                   ; poáet bajtñ na index
         mul       word ptr es:[AWinSouR]   ; inicializaán° velikost tabulky indexñ
         mov       bx,16
         div       bx                       ; p©evod na odstavce
         add       ax,word ptr es:[AWinSouI+2]       ; adresa konce tabulky indexñ
         inc       ax
         inc       ax                       ; asi tak nàjak zaokrouhlen°
         xchg      ax,bx                    ; BX <- poëadovan† velikost bloku
         pop       ax
         call      far ptr ModiSeg          ; nastaven° novÇ velikosti bloku
         jnc       SelWDir2                 ; v®e je OK
SelWDir1:jmp       SelWDir9                 ; chyba

; ------ inicializace ukazatelñ

SelWDir2:xor       ax,ax
         mov       es:[AWinSouN],ax         ; poáet zobrazenòch souborñ
         mov       es:[AWinDFil],ax         ; poáet zobrazenòch souborñ
         mov       word ptr es:[AWinDSum],ax         ; obsazen† kapacita LOW
         mov       word ptr es:[AWinDSum+2],ax       ; obsazen† kapacita HIGH
         mov       ss:[bp-6],ax             ; á°taá za©azenòch poloëek
         mov       ss:[bp-22],ax            ; á°taá zobrazenòch souborñ
         mov       ss:[bp-24],ax            ; st©adaá zabranÇ kapacity HIGH
         mov       ss:[bp-26],ax            ; st©adaá zabranÇ kapacity LOW

         mov       word ptr ss:[bp-12],AWinSoub AND 0fh; ukazatel poloëek OFFSET
         mov       ax,AWinSoub/16           ; zaá†tek poloëek
         add       ax,ss:[bp-4]             ; + adresa okna
         mov       ss:[bp-10],ax            ; ukazatel adresy poloëky SEGMENT
         mov       ax,word ptr es:[AWinSouI]         ; adresa tabulky indexñ (offset)
         mov       word ptr es:[AWinKomI],ax         ; tabulka indexñ koment†©ñ
         mov       ss:[bp-16],ax            ; adresa tabulky indexñ OFFSET
         mov       ax,word ptr es:[AWinSouI+2]
         mov       word ptr es:[AWinKomI+2],ax       ; segment indexñ koment†©ñ
         add       ax,ss:[bp-4]             ; segment indexñ
         mov       ss:[bp-14],ax            ; adresa tabulky indexñ SEGMENT
         mov       ax,es:[AWinSouR]         ; poáet naátenòch souborñ
         mov       ss:[bp-8],ax             ; á°taá souborñ k testov†n°
         or        ax,ax                    ; je nàjakò soubor ?
         jz        SelWDir1                 ; nen° ë†dnò soubor

; ------ parametry filtru

         mov       al,es:[AWinFilP]         ; parametry filtru
         test      al,bit6+bit7             ; je maska ?
         jz        SelWDir3                 ; nen° maska
         cmp       word ptr es:[AWinFilF.AWinFilN],0 ; je maska souborñ ?
         jne       SelWDir3                 ; je maska souborñ OK
         and       al,not bit7+bit6         ; neprov†d° se test maskou
SelWDir3:mov       ss:[bp-27],al            ; parametry filtru

; ------ adresa testovanÇ poloëky

         mov       bx,es:[AWinAlok]         ; poáet bajtñ na alokaán° blok disku
         test      byte ptr es:[AWinPrm0],bit6 ; je to CD-ROM disk ?
         jz        SelWDir4                 ; nen° to CR-ROM disk
         mov       bx,2048                  ; velikost bloku = 1 sektor
SelWDir4:mov       ds,ss:[bp-20]            ; datovò segment
         les       si,ss:[bp-12]            ; ukazatel adresy testovanÇ poloëky

; ------ kontrola, zda se m† poloëka testovat filtrem

         test      byte ptr ss:[bp-27],bit0 ; byla maska p©i naá°t†n° ?
         jnz       SelWDir6                 ; maska byla jië p©i naá°t†n°
         test      byte ptr ds:[SrcInit+1],DIR ; hledaj° se DIR ?
         jnz       SelWDr42                 ; hledaj° se DIR
         test      byte ptr es:[si+FileAtr],DIR ; je to adres†© ?
         jnz       SelWDir6                 ; adres†© - vyhovuje hled†n°
SelWDr42:test      byte ptr ss:[bp-27],bit6+bit7 ; testuje se maskou ?
         jz        SelWDr44                 ; netestuje se maskou

; ------ kontrola poloëky filtrem

         mov       ds,ss:[bp-4]             ; adresa segmentu okna
         inc       si                       ; zaá†tek jmÇna poloëky
         mov       di,AWinFilF.AWinFilt              ; maska pro hled†n°
         mov       cx,ds:[AWinFilF.AWinFilN]         ; dÇlka masky pro hled†n°
         push      cs
         call      near ptr TestMask        ; porovn†n° ES:SI s maskou DS:DI
         dec       si                       ; n†vrat zaá†tku poloëky
         mov       ds,ss:[bp-20]            ; datovò segment
         jnc       SelWDr44                 ; poloëka vyhovuje OK
SelWDr43:jmp       SelWDir7                 ; poloëka nen° povolen†

; ------ p©°prava poloëky pro test parametrñ

SelWDr44:mov       ax,word ptr es:[si+FileSize]      ; velikost
         mov       ss:[bp-48],ax
         mov       ax,word ptr es:[si+FileSize+2]
         mov       ss:[bp-48+2],ax
         mov       ax,es:[si+FileDate]      ; datum
         mov       ss:[bp-50],ax
         mov       ax,es:[si+FileTime]      ; áas
         mov       ss:[bp-52],ax
         mov       al,es:[si+FileAtr]       ; atributy
         mov       ss:[bp-53],al

; ------ kontrola parametrñ poloëky

         push      di
         push      si
         push      es
         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         lea       si,[bp-74]               ; adresa DTA
         mov       di,offset SrcAtr         ; zaá†tek parametrñ
         call      far ptr GetBTest         ; test ostatn°ch parametrñ
         pop       es
         pop       si
         pop       di
         jc        SelWDr43                 ; poloëka nevyhovuje

; ------ vyhled†n° textu v souboru

;         cmp       byte ptr ds:[SrcTextN],0 ; je nàjakò text k hled†n° ?
;         je        SelWDir6                 ; nen° hled†n° textu
;         test      byte ptr es:[si+FileAtr],DIR ; je to adres†© ?
;SelWDr46:jnz       SelWDir6                 ; adres†© je povolen
;
;; ------ p©°prava jmÇna souboru
;
;         push      ds
;         push      es
;
;         mov       di,ss:[bp-18]            ; adresa konce cesty v bufferu
;         push      es
;         pop       ds                       ; DS <- segment poloëky
;         inc       si                       ; zaá†tek jmÇna poloëky
;         push      ss
;         pop       es                       ; ES <- segment bufferu
;         call      far ptr FileAsc          ; dek¢dov†n° na jmÇno souboru
;
;         pop       es
;         pop       ds
;
;; ------ vyhled†n° textu
;
;         lea       si,[bp-160]              ; buffer jmÇna souboru
;         push      ss
;         pop       es                       ; segment jmÇna souboru
;         mov       cx,di                    ; konec textu jmÇna souboru
;         sub       cx,si                    ; dÇlka jmÇna souboru
;         call      far ptr SrcFText         ; vyhled†n° textu v souboru
;         les       si,ss:[bp-12]            ; ukazatel adresy testovanÇ poloëky
;         jc        SelWDir7                 ; text nenalezen

; ------ poloëka je povolen† - za©azen° do tabulky indexñ

SelWDir6:lds       di,ss:[bp-16]            ; adresa indexñ
         mov       ax,si                    ; offset poloëky
         mov       ds:[di],al               ; offset poloëky LOW
         mov       ax,es                    ; segment poloëky
         sub       ax,ss:[bp-4]             ; offset segmentu v bloku
         mov       ds:[di+1],ax             ; offset poloëky HIGH
         add       word ptr ss:[bp-16],3    ; zvò®en° ukazatele indexñ
         inc       word ptr ss:[bp-6]       ; á°taá za©azenòch poloëek

; ------ test, zda poloëka je soubor

         test      byte ptr es:[si+FileAtr],DIR ; je poloëka soubor ?
         jnz       SelWDir7                 ; poloëka je adres†©

; ------ zvò®en° á°taáe zobrazenòch souborñ

         inc       word ptr ss:[bp-22]      ; zvò®en° á°taáe souborñ

; ------ zaokrouhlen° velikosti souboru nahoru

         mov       ax,word ptr es:[si+FileSize]      ; velikost souboru LOW
         mov       dx,word ptr es:[si+FileSize+2]    ; velikost souboru HIGH
         dec       bx                       ; velikost bloku - 1
         add       ax,bx                    ; zaokrouhlen° na blok
         adc       dx,0                     ; p©enos
         inc       bx                       ; n†vrat velikosti bloku
         jc        SelWDir7                 ; p©i p©eteáen° se poloëka nepoá°t†

; ------ kontrola, zda je p©eteáen° velikosti souboru (diskov† chyba nebo CD)

         cmp       dx,bx                    ; je p©eteáen° velikosti ?
         jae       SelWDr62                 ; je p©eteáen° velikosti souboru

; ------ zaokrouhlen° velikosti na celÇ bloky

         div       bx                       ; vòpoáet celòch blokñ
         mul       bx                       ; vòpoáet zaokrouhlenÇ velikosti

; ------ zvò®en° kapacity souborñ

SelWDr62:add       ss:[bp-26],ax            ; p©iáten° velikosti LOW
         adc       ss:[bp-24],dx            ; p©iáten° velikosti HIGH

; ------ p©°prava pro dal®° poloëku

SelWDir7:add       si,FileSumm+1            ; adresa dal®° poloëky
         mov       al,es:[si-1]             ; dÇlka dlouhÇho jmÇna
         mov       ah,0
         add       si,ax                    ; p©eskoáen° dlouhÇho jmÇna

         mov       ax,si                    ; offset poloëky
         and       si,0fh                   ; normalizace offsetu poloëky
         mov       ss:[bp-12],si            ; offset adresy poloëky
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©evod offsetu na segment
         add       ss:[bp-10],ax            ; segment adresy poloëky
         dec       word ptr ss:[bp-8]       ; á°taá poloëek k testov†n°
         jz        SelWDir8                 ; jsou jië v®echny poloëky
         jmp       SelWDir4                 ; test dal®° poloëky

; ------ inicializace ukazatelñ v segmentu

SelWDir8:mov       ds,ss:[bp-20]            ; datovò segment
         mov       es,ss:[bp-4]             ; segment bloku
         mov       ax,ss:[bp-6]             ; poáet za©azenòch poloëek
         mov       es:[AWinSouN],ax         ; poáet za©azenòch poloëek
         xchg      ax,cx                    ; CX <- poáet za©azenòch poloëek
         mov       ax,ss:[bp-16]            ; adresa indexñ OFFSET
         mov       di,ax                    ; DI <- offset indexñ
         and       di,0fh                   ; normalizace offsetu
         mov       word ptr es:[AWinKomI],di         ; adresa indexñ koment†©ñ
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©evod offsetu na segment
         add       ax,ss:[bp-14]            ; adresa indexñ SEGMENT
         push      ax                       ; adresa indexñ SEGMENT
         sub       ax,ss:[bp-4]             ; segment relativnà
         mov       word ptr es:[AWinKomI+2],ax       ; adresa indexñ koment†©ñ
         mov       ax,ss:[bp-22]            ; poáet zobrazenòch souborñ
         mov       es:[AWinDFil],ax         ; poáet zobrazenòch souborñ
         mov       ax,ss:[bp-24]
         mov       word ptr es:[AWinDSum+2],ax       ; obsazen† kapacita LOW
         mov       ax,ss:[bp-26]
         mov       word ptr es:[AWinDSum],ax         ; obsazen† kapacita HIGH
         pop       es                       ; segment indexñ

; ------ vymaz†n° tabulky indexñ koment†©ñ

         cld
         xor       ax,ax
         rep       stosw                    ; vymaz†n° tabulky indexñ koment†©ñ

; ------ nastaven° novÇ velikosti segmentu

         add       di,15                    ; zarovn†n° nahoru
         shr       di,1
         shr       di,1
         shr       di,1
         shr       di,1                     ; p©evod na odstavec
         mov       ax,es                    ; segment tabulky indexñ
         sub       ax,ss:[bp-4]             ; segment relativnà
         add       ax,di                    ; p©enos z offsetu
         xchg      ax,bx                    ; BX <- poëadovan† velikost segmentu
         mov       ax,ss:[bp-2]             ; á°slo datovÇho bloku
         call      far ptr ModiSeg          ; nastaven° novÇ velikosti segmentu

; ------ nastaven° ukazatele velikosti dat v segmentu

         mov       ax,16
         mul       bx                       ; p©evod na bajty
         mov       es,ss:[bp-4]             ; segment bloku
         mov       word ptr es:[AWinByts],ax         ; velikost bloku
         mov       byte ptr es:[AWinByts+2],dl
         clc

; ------ n†vrat parametrñ pro vòbàr souborñ (uchov†v† p©°znak CF)

SelWDir9:mov       si,sp                    ; buffer v z†sobn°ku
         pushf

         mov       ds,ss:[bp-20]            ; datovò segment
         cmp       byte ptr ds:[SrcTextN],0 ; je nàjakò text k hled†n° ?
         je        SelWDirA                 ; nen° hled†n° textu
         call      far ptr Disp0Hlp         ; n†vrat zobrazen° kl†ves

SelWDirA:mov       es,ss:[bp-20]            ; ES <- datovò segment
         push      ss
         pop       ds                       ; DS <- segment bufferu
         mov       di,offset SrcInit        ; zaá†tek parametrñ
         mov       cx,80/2                  ; dÇlka definice parametrñ
         cld
         rep       movsw                    ; n†vrat parametrñ

         popf

; ------ n†vrat registrñ

         mov       sp,bp
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      far ptr AktSelct         ; aktualizace vòbàru poloëek
         ret

SelWDir  ENDP

; *****************************************************************************
;                              TestMask
;              test nalezenÇho souboru, zda odpov°d† masce
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=jmÇno poloëky souboru ve tvaru FCB
;        DS:DI=maska souborñ
;        CX=dÇlka masky souborñ
; VùSTUP:NC=poloëka odpov°d†
; *****************************************************************************

TestMask PROC      FAR

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      ds

; ------ p©°prava ukazatelñ

         xor       bx,bx                    ; BX <- 0
         mov       dx,si                    ; £schova adresy poloëky

; ------ test, zda je z†porn† maska (=poloëka je zak†zan†)

TestMsk1:jcxz      TestMsk2                 ; nen° platn† poloëka
         cmp       byte ptr ds:[di],"-"     ; je z†porn† maska ?
         jne       TestMsk2                 ; nen° z†porn† maska
         inc       di                       ; p©eskoáen° znaku "-"
         dec       cx                       ; sn°ëen° á°taáe znakñ
         call      Test1Msk                 ; test jednÇ masky
         jc        TestMsk5                 ; jmÇno se neshoduje - dal®° maska
         jmp       short TestMsk7           ; jmÇno odpov°d† - zak†zanÇ jmÇno

; ------ kontrola jmÇna poloëky

TestMsk2:call      Test1Msk                 ; test jednÇ masky
         jnc       TestMsk6                 ; poloëka vyhovuje OK
TestMsk5:call      TestMNxt                 ; nalezen° dal®° poloëky
         jnc       TestMsk1                 ; kontrola dal®° masky
         jmp       short TestMsk9           ; poloëka nevyhovuje

; ------ nalezena shodn† maska - test zbytku masek, zda nen° z†porn† maska

TestMsk6:call      TestMNxt                 ; nalezen° dal®° poloëky
         jc        TestMsk8                 ; nenalezena dal®° poloëka
         jcxz      TestMsk8                 ; nen° dal®° poloëka
         cmp       byte ptr ds:[di],"-"     ; je z†porn† maska ?
         jne       TestMsk6                 ; nen° z†porn† maska - dal®° poloëka
         inc       di                       ; p©eskoáen° znaku "-"
         dec       cx                       ; sn°ëen° á°taáe znakñ
         call      Test1Msk                 ; test jednÇ masky
         jc        TestMsk6                 ; jmÇno se neshoduje - dal®° maska
TestMsk7:stc                                ; p©°znak CY = poloëka nevyhovuje
         jmp       short TestMsk9

TestMsk8:clc                                ; p©°znak, ëe poloëka vyhovuje OK

; ------ n†vrat registrñ

TestMsk9:pop       ds
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

TestMask ENDP

; -----------------------------------------------------------------------------
;             test jednÇ masky (CY=neodpov°d†)
;  (maska DS:DI, dÇlka CX, soubor ES:SI, BH=0, DX=zaá†tek jmÇna poloëky ES:SI)
; -----------------------------------------------------------------------------

Test1Msk PROC      NEAR

; ------ test, zda maska obsahuje teáku

         stc                                ; p©°znak - konec masek
         jcxz      Test1Ms8                 ; konec masek
         push      di
         push      cx
Test1Ms2:mov       al,ds:[di]
         cmp       al,"."
         je        Test1Ms3                 ; nalezena teáka
         inc       di
         cmp       al,0
         je        Test1M22
         cmp       al,TAB
         je        Test1M22                 ; tabul†tor
         cmp       al," "                   ; konec masky ?
Test1M22:loopne    Test1Ms2                 ; dal®° znak
         stc                                ; p©°znak - nen° teáka
Test1Ms3:pop       cx
         pop       di

; ------ porovn†n° jmÇna poloëky

         mov       bl,11                    ; dÇlka jmÇna s p©°ponou
         jc        Test1Ms7                 ; porovn†n° poloëky s p©°ponou
         mov       bl,8                     ; dÇlka jmÇna
         call      TestMs                   ; kontrola jmÇna
         jc        Test1Ms8                 ; jmÇno se neshoduje

; ------ nastaven° na p©°ponu poloëky

Test1Ms4:jcxz      Test1Ms6                 ; konec jmÇna
         mov       al,ds:[di]               ; p©ipravenò znak
         cmp       al,0
         je        Test1Ms6
         cmp       al," "                   ; je p©ipravena mezera ?
         je        Test1Ms6                 ; konec jmÇna poloëky
         cmp       al,TAB
         je        Test1Ms6
         inc       di                       ; zvò®en° ukazatele textu
         dec       cx
         cmp       al,"."                   ; oddàlovac° teáka ?
         jne       Test1Ms4                 ; nen° teáka - dal®° znak

; ------ porovn†n° p©°pony poloëky

Test1Ms6:mov       bl,3                     ; dÇlka p©°pony
         mov       si,dx
         add       si,8                     ; p©°pona jmÇna souboru
Test1Ms7:call      TestMs                   ; test p©°pony jmÇna
Test1Ms8:mov       si,dx                    ; n†vrat adresy zaá†tku poloëky
         ret

Test1Msk ENDP

; -----------------------------------------------------------------------------
;        nastaven° na dal®° poloëku masky (NC=nalezena dal®° poloëka)
; -----------------------------------------------------------------------------

TestMNxt PROC      NEAR

TestMNx1:jcxz      TestMNx2                 ; nen° dal®° maska - nenalezena
         mov       al,ds:[di]               ; p©ipravenò znak
         inc       di                       ; zvò®en° ukazatele textu
         dec       cx                       ; sn°ëen° á°taáe znakñ
         cmp       al,TAB                   ; tabul†tor ?
         je        TestMNx3                 ; tabul†tor - bude dal®° maska
         cmp       al," "                   ; byla to oddàlovac° mezera ?
         jne       TestMNx1                 ; nen° mezera - dal®° znak
TestMNx3:ret                                ; NC = nalezeno OK

TestMNx2:stc                                ; nenalezeno
         ret

TestMNxt ENDP

; -----------------------------------------------------------------------------
;        test jmÇna nebo p©°pony souboru
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=jmÇno nebo p©°pona (ve tvaru FCB)
;        BX=poáet znakñ k porovn†n° (nesm° bòt = 0)
;        DS:DI=maska
;        DX=adresa zaá†tku poloëky
;        CX=poáet zbylòch znakñ masky
; VùSTUP:CY=poloëka nevyhovuje
;        SI, DI, BX a CX se p©i NC zmàn°, p©i chybà CY zñstanou nezmànàny
; -----------------------------------------------------------------------------

TestMs   PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      si
         push      di

; ------ konec masky - zbytek mus° bòt mezery

TestMs1: mov       al," "                   ; porovn†vanò znak
         jcxz      TestMs4                  ; konec - zbytek mus° bòt mezery

; ------ oddàlovac° mezera - zbytek mus° bòt mezery

         mov       ah,ds:[di]               ; p©ipravenò znak masky
         or        ah,ah                    ; je konec textu ?
         jz        TestMs4                  ; je konec textu - mus° bòt mezera
         cmp       ah," "                   ; mezera - konec poloëky ?
         je        TestMs4                  ; konec - zbytek mus° bòt mezery
         cmp       ah,TAB                   ; tabul†tor ?
         je        TestMs4                  ; tabul†tor - zbytek mus° bòt mezery

; ------ oddàlovac° teáka - zbytek mus° bòt mezery

         cmp       ah,"."                   ; teáka - konec jmÇna nebo p©°pony ?
         je        TestMs4                  ; konec - zbytek mus° bòt mezery

; ------ n†hradn° znak "*" - bude volnò poáet znakñ

         inc       di                       ; zvò®en° ukazatele textu
         dec       cx                       ; sn°ëen° á°taáe zbylòch znakñ
         cmp       ah,"*"                   ; n†hradn° znaky - v®e vyhovuje
         jne       TestMs3

; ------ vypu®tàn° nadbyteánòch znakñ "*"

         jcxz      TestMs2                  ; nen° dal®° znak
TestMs12:cmp       byte ptr ds:[di],"*"     ; je p©ipraven dal®° znak "*" ?
         jne       TestMs2                  ; nen° p©ipraven dal®° znak "*"
         inc       di                       ; zvò®en° ukazatele textu
         loop      TestMs12                 ; dal®° znak

; ------ porovn†n° zbytku masky (od souáasnÇ pozice), zda vyhovuje

TestMs2: call      TestMs                   ; porovn†n° zbytku masky
         jnc       TestMs6                  ; zbytek masky vyhovuje
         inc       si                       ; ukazatel v FCB
         dec       bx                       ; á°taá zbylòch pozic FCB
         jnz       TestMs2                  ; dal®° test
         jmp       short TestMs6            ; jinak mus° bòt konec masky

; ------ porovn†n° znaku

TestMs3: mov       al,ah                    ; znak k porovn†n°
         cmp       al,"?"                   ; n†hradn° znak
         je        TestMs5                  ; n†hradn° znak - vyhovuje
TestMs4: cmp       al,es:[si]               ; souhlas° jmÇno ?
         jne       TestMs9                  ; poloëka nesouhlas°

; ------ znak vyhovuje - dal®° znak

TestMs5: inc       si                       ; zvò®en° ukazatele v poloëce
         dec       bx                       ; á°taá znakñ k testov†n°
         jnz       TestMs1                  ; dal®° znak

; ------ zat°m vyhovuje - test, zda je konec textu

TestMs6: jcxz      TestMs7                  ; konec textu = OK
         cmp       byte ptr ds:[di],0
         je        TestMs7
         cmp       byte ptr ds:[di]," "     ; je konec masky (mezera) ?
         je        TestMs7                  ; je konec masky = OK
         cmp       byte ptr ds:[di],TAB
         je        TestMs7                  ; je konec masky (tabul†tor) = OK
         cmp       byte ptr ds:[di],"."     ; je konec jmÇna ?
         je        TestMs7                  ; je konec jmÇna = OK
         cmp       byte ptr ds:[di],"*"     ; je univerz†ln° znak "*" ?
         jne       TestMs9                  ; je platnò znak - nevyhovuje
         inc       di                       ; p©eskoáen° znaku "*"
         loop      TestMs6                  ; test dal®°ho znaku "*"

; ------ poloëka vyhovuje - registry se nevracej°

TestMs7: add       sp,4*2                   ; registry se nevracej°
         clc                                ; p©°znak, ëe vyhovuje
         ret

; ------ poloëka nevyhovuje - n†vrat registrñ

TestMs9: stc                                ; p©°znak, ëe nevyhovuje
         pop       di
         pop       si
         pop       cx
         pop       bx
         ret

TestMs   ENDP

; *****************************************************************************
;                                TestProg
;                 kontrola, zda je poloëka ES:SI program
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=poloëka souboru
; VùSTUP:ZY=je program
; *****************************************************************************

TestProg PROC      FAR

; ------ adres†© se nekontroluje

         push      ax
         test      byte ptr es:[si+FileAtr],DIR ; je to adres†© ?
         jnz       TestPrg9                 ; je to adres†© - nen° program

; ------ prvn° 2 znaky p©°pony

         mov       ax,word ptr es:[si+FileExt] ; prvn° 2 znaky p©°pony souboru

; ------ test, zda je poloëka program EXE

         cmp       ax,"XE"
         jne       TestPrg2                 ; nen° EXE
         cmp       byte ptr es:[si+FileExt+2],"E"
         jmp       short TestPrg9

; ------ test, zda je poloëka program COM

TestPrg2:cmp       ax,"OC"
         jne       TestPrg3                 ; nen° COM
         cmp       byte ptr es:[si+FileExt+2],"M"
         jmp       short TestPrg9

; ------ test, zda je poloëka povelovò soubor BAT

TestPrg3:cmp       ax,"AB"
         jne       TestPrg9
         cmp       byte ptr es:[si+FileExt+2],"T"

; ------ n†vrat registrñ

TestPrg9:pop       ax
         ret

TestProg ENDP

; *****************************************************************************
;                                  SortDir
;                       Set©°dàn° poloëek adres†©e
;                p©i t©°dàn° se udrëuje kurzor na svÇ poloëce
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo datovÇho bloku
;        DS=datovò segment
; *****************************************************************************

SortDir  PROC      FAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ adresa popisovaáe okna

         call      far ptr GetDat           ; poskytnut° adresy popisovaáe
         jc        SortDir9
         xor       bx,bx                    ; poá†teán° poloëka
         mov       cx,es:[AWinSouN]         ; poáet zobrazenòch poloëek

; ------ test, zda to je adres†©ovÇ okno

         test      byte ptr es:[AWinPrm1],bit3 ; je to adres†©ovÇ okno ?
         jnz       SortDir8                 ; je to adres†©ovÇ okno

; ------ test, zda to je okno seznamu

         test      byte ptr es:[AWinPrm1],bit5 ; je to seznam ?
         jz        SortDir9                 ; nen° to seznam

; ------ nalezen° zaá†tku dal®° á†sti seznamu

         mov       di,es                    ; DI <- £schova adresy okna
SortDir2:inc       bx                       ; zvò®en° ukazatele poloëek
         mov       es,di                    ; adresa okna
         call      far ptr GetESPol         ; adresa poloëky -> ES:SI
         jc        SortDir9                 ; nen° dal®° á†st seznamu
         test      byte ptr es:[si+FileAtr],ATRT ; je to platn† poloëka ?
         jz        SortDir2                 ; nen° to platn† poloëka - dal®°

; ------ zji®tàn° posledn° poloëky á†sti seznamu

         mov       dx,bx                    ; DX <- £schova prvn° poloëky
SortDir3:inc       bx                       ; zvò®en° ukazatele poloëek
         mov       es,di                    ; adresa okna
         call      far ptr GetESPol         ; adresa poloëky -> ES:SI
         jc        SortDir4
         test      byte ptr es:[si+FileAtr],ATRT ; je to platn† poloëka ?
         jnz       SortDir3                 ; je to platn† poloëka - dal®°

; ------ set©°dàn° á†sti seznamu

SortDir4:xchg      bx,dx                    ; BX <- prvn° poloëka, DX <- dal®°
         mov       cx,dx                    ; n†sleduj°c° poloëka
         sub       cx,bx                    ; poáet poloëek k set©°dàn°
         push      cs
         call      near ptr SortLWn         ; set©°dàn° poloëek á†sti seznamu
         mov       bx,dx                    ; BX <- dal®° poloëka
         jmp       short SortDir2           ; dal®° t©°dàn°

; ------ set©°dàn° adres†©ovÇho okna

SortDir8:push      cs
         call      near ptr SortLWn         ; set©°dàn° poloëek á†sti seznamu

; ------ n†vrat registrñ

SortDir9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         call      far ptr InitFKom         ; inicializace koment†©ñ k souborñm
         ret

SortDir  ENDP

; *****************************************************************************
;                                 SortLWn
;            set©°dàn° á†sti poloëek seznamu (neinicializuje koment†©e)
;                p©i t©°dàn° se udrëuje kurzor na svÇ poloëce
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo datovÇho bloku
;        BX=poá†teán° poloëka
;        CX=poáet poloëek
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) á°slo okna
;                   SS:[BP-4] (2) adresa okna
;                   SS:[BP-6] (2) datovò segment
;                   SS:[BP-8] (2) poá†teán° poloëka
;                   SS:[BP-10] (2) posledn° poloëka
;                   SS:[BP-12] (2) p©°rustek kroku testu
;                   SS:[BP-14] (2) ukazatel poloëky
;                   SS:[BP-16] (2) segment indexovÇ tabulky
;                   SS:[BP-18] (2) offset indexovÇ tabulky
;                   SS:[BP-19] (1) t©°dàn°
;                                      bit 0: 1=okno se net©°d°
;                                      bit 1,2: 0=podle jmÇna
;                                               1=podle p©°pony
;                                               2=podle velikosti
;                                               3=podle data a áasu
;                                      bit 3: 1=sestupnÇ t©°dàn°
;                   SS:[BP-20] (1)
; *****************************************************************************

SortLWn  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es
         mov       bp,sp
         sub       sp,20

; ------ adresa popisovaáe okna

         jcxz      SortLWn0                 ; nen° ë†dn† poloëka
         call      far ptr GetDat           ; poskytnut° adresy popisovaáe
         jnc       SortLWn1
SortLWn0:jmp       SortLWn9

; ------ p©°prava lok†ln°ch promànnòch

SortLWn1:or        byte ptr es:[AWinPrm0],bit4 ; je pot©eba zobrazit okno
         mov       ss:[bp-2],ax             ; á°slo okna
         mov       ss:[bp-4],es             ; adresa okna
         mov       ss:[bp-6],ds             ; datovò segment
         mov       ss:[bp-8],bx             ; poá†teán° poloëka
         add       bx,cx                    ; n†sleduj°c° poloëka
         dec       bx                       ; posledn° poloëka
         mov       ss:[bp-10],bx            ; posledn° poloëka
         mov       ss:[bp-12],cx            ; velikost kroku
         mov       ax,word ptr es:[AWinSouI]         ; indexov† tabulka - offset
         mov       ss:[bp-18],ax            ; adresa indexovÇ tabulky - OFFSET
         mov       ax,es                    ; segment okna
         add       ax,word ptr es:[AWinSouI+2]       ; segment indexovÇ tabulky
         mov       ss:[bp-16],ax            ; segment indexovÇ tabulky
         xor       cx,cx                    ; CX <- 0 á°taá
         cld

; ------ rozli®en° zpñsobu t©°dàn°

         mov       al,es:[AWinPrm2]         ; t©°dàn°
         mov       ss:[bp-19],al            ; t©°dàn°
         mov       dx,offset SortDirZ       ; net©°dànÇ okno
         test      al,bit0                  ; t©°d° se okno ?
         jnz       SortLW13                 ; okno se net©°d°

         test      al,bit3                  ; je sestupnÇ t©°dàn° ?
         jz        SortLW12                 ; nen° sestupnÇ t©°dàn°
         mov       dx,offset SortSirN       ; t©°dàn° podle jmÇna
         test      al,bit1+bit2
         jz        SortLW13                 ; podle jmÇna
         mov       dx,offset SortSirS       ; t©°dàn° podle velikosti
         test      al,bit1
         jz        SortLW13                 ; podle velikosti
         mov       dx,offset SortSirE       ; t©°dàn° podle p©°pony
         test      al,bit2
         jz        SortLW13                 ; podle p©°pony
         mov       dx,offset SortSirD       ; t©°dàn° podle data
         jmp       short SortLW13

SortLW12:mov       dx,offset SortDirN       ; t©°dàn° podle jmÇna
         test      al,bit1+bit2
         jz        SortLW13                 ; podle jmÇna
         mov       dx,offset SortDirS       ; t©°dàn° podle velikosti
         test      al,bit1
         jz        SortLW13                 ; podle velikosti
         mov       dx,offset SortDirE       ; t©°dàn° podle p©°pony
         test      al,bit2
         jz        SortLW13                 ; podle p©°pony
         mov       dx,offset SortDirD       ; t©°dàn° podle data

SortLW13:mov       cs:[SortLWnA],dx         ; adresa obsluhy

; ------ zjemnàn° velikosti kroku

SortLWn2:shr       word ptr ss:[bp-12],1    ; zjemnàn° velikosti kroku
         jnz       SortLWn3                 ; je je®tà platnò krok
         jmp       SortLWn9                 ; konec

; ------ p©°prava á°sla poá†teán° poloëky (na konci prvn°ho kroku)

SortLWn3:mov       ax,ss:[bp-12]            ; krok
         dec       ax                       ; p©ednastaven° - 1
         add       ax,ss:[bp-8]             ; aktu†ln° poloëka
         mov       ss:[bp-14],ax            ; ukazatel á°sla poloëky

; ------ zvò®en° ukazatele aktu†ln° poloëky

SortLWn4:mov       bx,ss:[bp-14]            ; ukazatel á°sla poloëky
         inc       bx                       ; zvò®en° á°sla poloëky
         mov       ss:[bp-14],bx
         cmp       bx,ss:[bp-10]            ; je je®tà platn† poloëka ?
         ja        SortLWn2                 ; nen° platn† poloëka

; ------ ukazatel testovanÇ poloëky

         mov       dx,bx                    ; DX <- testovan† poloëka
SortLWn5:sub       dx,ss:[bp-12]            ; testovan† poá†teán° poloëka
         jc        SortLWn4                 ; podteáen°
         cmp       dx,ss:[bp-8]             ; je je®tà platn† poloëka ?
         jb        SortLWn4                 ; posun á°sla poloëky
         mov       bx,dx                    ; á°slo testovanÇ poloëky
         add       bx,ss:[bp-12]            ; druh† testovan† poloëka

; ------ adresa druhÇ poloëky (BX) -> DS:SI

         mov       ds,ss:[bp-4]             ; adresa okna
         mov       si,bx                    ; á°slo poloëky
         shl       si,1                     ; á°slo poloëky * 2
         add       si,bx                    ; á°slo poloëky * 3
         mov       ax,ds                    ; adresa okna
         push      ax
         add       si,word ptr ds:[AWinSouI]         ; p©iáten° offsetu tabulky indexñ
         add       ax,word ptr ds:[AWinSouI+2]
         mov       ds,ax                    ; ES:SI=adresa indexu
         pop       ax
         add       ax,ds:[si+1]             ; segment
         mov       si,ds:[si]               ; offset
         and       si,0ffh                  ; offset
         mov       ds,ax

; ------ adresa prvn° poloëky (DX) -> ES:DI

         mov       es,ss:[bp-4]             ; adresa okna
         mov       di,dx                    ; á°slo poloëky
         shl       di,1                     ; á°slo poloëky * 2
         add       di,dx                    ; á°slo poloëky * 3
         mov       ax,es                    ; adresa okna
         push      ax
         add       di,word ptr es:[AWinSouI]         ; p©iáten° offsetu tabulky indexñ
         add       ax,word ptr es:[AWinSouI+2]
         mov       es,ax                    ; ES:SI=adresa indexu
         pop       ax
         add       ax,es:[di+1]             ; segment
         mov       di,es:[di]               ; offset
         and       di,0ffh                  ; offset
         mov       es,ax

; ------ £schova atributñ poloëek

         push      bx
         mov       bh,0
         mov       bl,es:[di+FileATyp]      ; typ poloëky 1
         inc       bl
         mov       al,cs:[bx+GrpSortT]      ; t©°dic° typ poloëky 1
         mov       bl,ds:[si+FileATyp]      ; typ poloëky 2
         inc       bl
         mov       ah,cs:[bx+GrpSortT]      ; t©°dic° typ poloëky 2
         pop       bx

         inc       si
         inc       di

; ------ net©°dànÇ okno

         test      byte ptr ss:[bp-19],bit0 ; okno se net©°d° ?
         jnz       SortLWnX                 ; okno se net©°d°

; ------ zaji®tàn° po©ad° skupin poloëek

         cmp       al,ah
         je        SortLWnX                 ; stejn† skupina - vnit©n° t©°dàn°
         ja        SortLWn8                 ; z†màna poloëek

SortLW54:jmp       SortLWn4                 ; jinak v®e OK

; ------ porovn†n° poloëek DS:SI (2.) a ES:DI (1.)

SortLWnX:call      word ptr cs:[SortLWnA]   ; porovn†n° poloëek
         jnc       SortLW54                 ; poloëky jsou OK

; ------ oprava kurzoru p©i z†mànà indexñ poloëek

;˛ -- vypnuto pro seznam !!!! (jinak sk†áe kurzor p©i hled†n° ?!?!)

SortLWn8:mov       es,ss:[bp-4]             ; ES <- adresa okna
         test      byte ptr es:[AWinPrm1],bit5 ; je to seznam ?
         jnz       SortLW84                 ; je to seznam
         cmp       dx,es:[AWinKurz]         ; je poloëka 1 kurzor ?
         jne       SortLW82                 ; poloëka 1 nen° kurzor
         mov       es:[AWinKurz],bx         ; kurzor se p©esune na pozici 2
         jmp       short SortLW84

SortLW82:cmp       bx,es:[AWinKurz]         ; je poloëka 2 kurzor ?
         jne       SortLW84                 ; poloëka 2 nen° kurzor
         mov       es:[AWinKurz],dx         ; kurzor se p©esune na pozici 1

; ------ z†màna indexñ poloëek

SortLW84:mov       si,dx                    ; poloëka 1
         shl       si,1
         add       si,dx
         add       si,ss:[bp-18]            ; adresa indexu poloëky 1

         mov       di,bx                    ; poloëka 2
         shl       di,1
         add       di,bx
         add       di,ss:[bp-18]

         mov       es,ss:[bp-16]            ; adresa indexovÇ tabulky
         mov       al,es:[si]
         xchg      al,es:[di]
         mov       es:[si],al
         mov       ax,es:[si+1]
         xchg      ax,es:[di+1]
         mov       es:[si+1],ax
         jmp       SortLWn5

; ------ n†vrat registrñ

SortLWn9:mov       sp,bp
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

SortLWn  ENDP

SortLWnA dw        SortDirN                 ; adresa obsluhy t©°dàn°

; ------ t©°dàn° podle data a áasu - vzestupnà

SortDirD:mov       ax,es:[di+FileDate-1]    ; datum
         cmp       ax,ds:[si+FileDate-1]    ; porovn†n° data
         jne       SortDrD8                 ; data jsou rozd°ln†
         mov       ax,es:[di+FileTime-1]    ; áas
         cmp       ax,ds:[si+FileTime-1]    ; porovn†n° áasñ
         je        SortDirN                 ; áasy jsou takÇ shodnÇ
SortDrD8:ret

; ------ t©°dàn° podle velikosti - vzestupnà

SortDirS:mov       ax,word ptr es:[di+FileSize+2-1] ; vy®®° slovo velikosti
         cmp       ax,word ptr ds:[si+FileSize+2-1] ; porovn†n° vy®®°ho slova
         jne       SortDrS8                 ; velikost rozd°ln†
         mov       ax,word ptr es:[di+FileSize-1] ; nië®° slovo velikosti
         cmp       ax,word ptr ds:[si+FileSize-1] ; porovn†n° nië®°ch slov
         je        SortDirN                 ; velikost shodn†
SortDrS8:ret

; ------ t©°dàn° podle p©°pony - vzestupnà

SortDirE:push      si
         push      di
         add       si,FileExt-1
         add       di,FileExt-1
         mov       cl,3
         repe      cmpsb                    ; porovn†n° p©°pon
         pop       di
         pop       si
         je        SortDirN                 ; je shodn† p©°pona
         ret

; ------ t©°dàn° podle jmÇna - vzestupnà

SortDirN:mov       cl,11                    ; dÇlka jmÇna s p©°ponou
         repe      cmpsb                    ; porovn†n° jmen souborñ
         ret

; ------ t©°dàn° podle data a áasu - sestupnà

SortSirD:mov       ax,ds:[si+FileDate-1]    ; datum
         cmp       ax,es:[di+FileDate-1]    ; porovn†n° data
         jne       SortSrD8                 ; data jsou rozd°ln†
         mov       ax,ds:[si+FileTime-1]    ; áas
         cmp       ax,es:[di+FileTime-1]    ; porovn†n° áasñ
         je        SortSirN                 ; áasy jsou takÇ shodnÇ
SortSrD8:ret

; ------ t©°dàn° podle velikosti - sestupnà

SortSirS:mov       ax,word ptr ds:[si+FileSize+2-1] ; vy®®° slovo velikosti
         cmp       ax,word ptr es:[di+FileSize+2-1] ; porovn†n° vy®®°ho slova
         jne       SortSrS8                 ; velikost rozd°ln†
         mov       ax,word ptr ds:[si+FileSize-1] ; nië®° slovo velikosti
         cmp       ax,word ptr es:[di+FileSize-1] ; porovn†n° nië®°ch slov
         je        SortSirN                 ; velikost shodn†
SortSrS8:ret

; ------ t©°dàn° podle p©°pony - sestupnà

SortSirE:push      si
         push      di
         add       si,FileExt-1
         add       di,FileExt-1
         mov       cl,3
         repe      cmpsb                    ; porovn†n° p©°pon
         pop       di
         pop       si
         je        SortSirN                 ; je shodn† p©°pona
         cmc
         ret

; ------ t©°dàn° podle jmÇna - sestupnà

SortSirN:mov       cl,11                    ; dÇlka jmÇna s p©°ponou
         repe      cmpsb                    ; porovn†n° jmen souborñ
         je        SortSrN2
         cmc
SortSrN2:ret

; ------ net©°dànÇ okno

SortDirZ:mov       ax,ds
         mov       cx,es
         cmp       ax,cx
         ret

; *****************************************************************************
;                                 StorFKom
;    uloëen° zadanÇho koment†©e k aktivn° poloëce (z ©†dkovÇho bufferu LinBuff)
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo okna (je vytvo©ena indexov† tabulka koment†©ñ !)
;        DS=datovò segment
; VùSTUP: CY=chyba
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) á°slo okna
;                   SS:[BP-4] (2) adresa okna
;                   SS:[BP-6] (2) á°slo segmentu koment†©ñ
;                   SS:[BP-8] (2) adresa koment†©ñ
;                   SS:[BP-10] (2) poáet p©°davnòch tabul†torñ
;                   SS:[BP-12] (2) index koment†©e poloëky
;                   SS:[BP-14] (2) adresa indexovÇ tabulky SEGMENT
;                   SS:[BP-16] (2) adresa indexovÇ tabulky OFFSET
; *****************************************************************************

StorFKom PROC      FAR

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
         sub       sp,16                    ; lok†ln° promànnÇ

; ------ p©°prava lok†ln°ch promànnòch

         call      KomLIni                  ; inicializace zadanÇho textu

         mov       ss:[bp-2],ax             ; segment okna
         call      far ptr GetDat           ; adresa definice okna
         jc        StorFKm1                 ; neplatnò segment okna
         mov       ss:[bp-4],es             ; adresa okna
         push      cs
         call      near ptr KomSIni         ; inicializace segmentu koment†©ñ
         jnc       StorFKm2
StorFKm1:call      far ptr MemErr           ; chyba pamàti
         jmp       StorFKm9                 ; chyba

StorFKm2:mov       ss:[bp-6],ax             ; segment koment†©ñ
         mov       ss:[bp-8],es             ; adresa koment†©ñ
         mov       word ptr ss:[bp-10],0    ; nejsou p©°davnÇ tabul†tory

; ------ adresa indexovÇ tabulky

         mov       es,ss:[bp-4]             ; segment okna
         mov       ax,word ptr es:[AWinKomI] ; adresa indexovÇ tabulky
         mov       ss:[bp-16],ax            ; adresa indexovÇ tabulky OFFSET
         mov       ax,es                    ; segment okna
         add       ax,word ptr es:[AWinKomI+2] ; adresa indexovÇ tabulky SEGMENT
         mov       ss:[bp-14],ax            ; adresa indexovÇ tabulky SEGMENT

; ------ adresa indexu koment†©e aktivn° poloëky -> ES:DI

         mov       di,es:[AWinKurz]         ; kurzor
         cmp       di,es:[AWinSouN]         ; je to platn† poloëka ?
         jae       StorFKm1                 ; nen° to platn† poloëka
         shl       di,1                     ; offset v tabulce indexñ
         add       di,ss:[bp-16]            ; adresa v tabulce indexñ
         mov       es,ax                    ; adresa indexovÇ tabulky SEGMENT

; ------ test, zda je platnò koment†©

         mov       di,es:[di]               ; adresa koment†©e poloëky OFFSET
         mov       es,ss:[bp-8]             ; adresa koment†©ñ SEGMENT
         or        di,di                    ; je platnò koment†© ?
         jz        StorFKm3                 ; nen° to platnò koment†©
         jmp       StorFKm5                 ; je to platnò koment†©

; ------ nen° platnò koment†© - vytvo©en° m°sta na konci bufferu

StorFKm3:mov       cl,ds:[LinNum]           ; dÇlka koment†©e
         mov       ch,0
         add       cx,1 + 12 + 1 + 1        ; dÇlka + jmÇno + tabul†tor + 0
         mov       ax,ss:[bp-6]             ; á°slo segmentu koment†©ñ
         mov       di,es:[0]                ; souáasn† velikost bufferu
         call      far ptr InsDat           ; vytvo©en° m°sta pro ©†dek
         jc        StorFKm1                 ; nedostatek pamàti

; ------ oprava adres tabulek

         mov       ax,ss:[bp-2]             ; segment okna
         call      far ptr GetDat           ; adresa okna
         mov       ss:[bp-4],es             ; nov† adresa okna
         mov       ax,es                    ; segment okna
         add       ax,word ptr es:[AWinKomI+2] ; segment tabulky koment†©ñ
         mov       ss:[bp-14],ax            ; adresa indexovÇ tabulky SEGMENT

; ------ adresa poloëky jmÇna souboru -> ES:SI

         mov       bx,es:[AWinKurz]         ; kurzor
         call      far ptr GetESPol         ; adresa poloëky -> ES:SI

         mov       bx,di                    ; BX <- £schova zaá†tku ©†dku
         inc       si                       ; zaá†tek jmÇna poloëky
         inc       di                       ; m°sto pro bajt dÇlky

; ------ dek¢dov†n° jmÇna poloëky do bufferu koment†©ñ

         push      ds
         push      es
         pop       ds                       ; DS <- segment poloëky
         mov       es,ss:[bp-8]             ; segment koment†©ñ
         call      far ptr FileAsc          ; dek¢dov†n° jmÇna poloëky
         pop       ds

; ------ oddàlovac° tabul†tor

         cld
         mov       ch,0
         mov       cl,ds:[LinNum]           ; CX <- dÇlka textu koment†©e
         jcxz      StorFK34                 ; nen° koment†© - nebudou tabul†tory
         mov       al,TAB
         stosb                              ; oddàlovac° tabul†tor

         push      di
         sub       di,bx                    ; dÇlka textu
         cmp       di,8+1                   ; je pot©eba dal®° tabul†tor ?
         pop       di
         ja        StorFK34                 ; nen° pot©eba dal®° tabul†tor
         stosb                              ; uloëen° dal®°ho tabul†toru

; ------ p©enesen° textu koment†©e

StorFK34:mov       dx,di                    ; £schova adresy zaá†tku koment†©e
         mov       ax,di                    ; ukl†dac° adresa
         sub       ax,bx                    ; dÇlka jië uloëenÇho textu + 1
         add       cx,ax                    ; vòsledn† dÇlka ©†dku
         cmp       cx,255                   ; maxim†ln° dÇlka textu + 1 - 1
         jbe       StorFKm4                 ; dÇlka textu je OK
         mov       cx,255                   ; omezen° dÇlky textu + 1 - 1
StorFKm4:sub       cx,ax                    ; zbytek na text koment†©e
         cld
         mov       si,offset LinBuff        ; buffer textu
         rep       movsb                    ; p©enesen° textu koment†©e

; ------ koncov† 0

         mov       al,0
         stosb                              ; koncov† 0

; ------ nov† velikost bufferu

         mov       es:[0],di                ; novò poáet bajtñ v bufferu

; ------ nastaven° dÇlky ©†dku

         sub       di,bx                    ; dÇlka ©†dku + 1
         dec       di                       ; dÇlka ©†dku (bez bajtu dÇlky)
         xchg      ax,di                    ; AX <- dÇlka ©†dku
         mov       es:[bx],al               ; dÇlka ©†dku
         inc       ax                       ; dÇlka ©†dku + 1
         mov       es,ss:[bp-4]             ; segment okna
         add       es:[AWinKomN],ax         ; zvò®en° poátu bajtñ koment†©ñ

; ------ aktualizace koment†©e k poloëce

         mov       di,es:[AWinKurz]         ; kurzor
         shl       di,1                     ; offset v tabulce indexñ
         add       di,ss:[bp-16]            ; adresa v tabulce indexñ
         mov       es,ss:[bp-14]            ; segment indexovÇ tabulky
         mov       es:[di],dx               ; adresa koment†©e poloëky
         jmp       StorFKm7                 ; operace OK

; ------ nalezen° zaá†tku ©†dku koment†©e (adresa ES:DI) -> ES:BX

StorFKm5:mov       ax,2                     ; AX <- zaá†tek dat
StorFK51:mov       bx,ax                    ; BX <- zaá†tek dal®°ho ©†dku
         inc       ax                       ; p©eskoáen° bajtu dÇlky
         mov       ch,0
         mov       cl,es:[bx]               ; CX <- dÇlka ©†dku
         add       ax,cx                    ; adresa dal®°ho ©†dku
         cmp       ax,di                    ; nalezen poëadovanò ©†dek ?
         jb        StorFK51                 ; nen° hledanò ©†dek - dal®°

; ------ stanoven° novÇ dÇlky DX a korekce dÇlky ©†dku CX

StorFK52:mov       ax,di                    ; adresa zaá†tku koment†©e
         sub       ax,bx                    ; AX <- dÇlka z†hlav° ©†dku
         mov       dh,0
         mov       dl,ds:[LinNum]           ; DX <- dÇlka novÇho textu

         cmp       byte ptr es:[di-1]," "   ; je p©ede®lò znak mezera ?
         je        StorF522
         cmp       byte ptr es:[di-1],TAB
         je        StorF522

         inc       dx                       ; pot©ebuje se m°sto pro tabul†tor
         inc       word ptr ss:[bp-10]      ; 1 tabul†tor
         cmp       al,8+1                   ; je pot©eba 2. tabul†tor ?
         ja        StorF522                 ; nen° pot©eba 2. tabul†tor
         inc       dx                       ; m°sto pro 2. tabul†tor
         inc       word ptr ss:[bp-10]      ; 2. tabul†tor

StorF522:add       dx,ax                    ; nov† dÇlka ©†dku + 1 - 1
         cmp       dx,255                   ; maxim†ln° dÇlka ©†dku
         jbe       StorFK53                 ; dÇlka ©†dku je OK
         mov       dx,255                   ; omezen° dÇlky ©†dku
StorFK53:sub       cx,dx                    ; rozd°l dÇlky ©†dku
         sub       dx,ax                    ; nov† dÇlka textu koment†©e

; ------ prodlouëen° ©†dku

         mov       ax,ss:[bp-6]             ; segment koment†©ñ
         or        cx,cx                    ; je prodlouëen°/zkr†cen° ?
         jz        StorFK55                 ; dÇlka ©†dku se nemàn°
         jns       StorFK54                 ; ©†dek se zkracuje
         neg       cx                       ; poëadovanÇ prodlouëen° ©†dku
         call      far ptr InsDat           ; vloëen° m°sta
         jnc       StorFK55                 ; operace OK
         jmp       StorFKm1                 ; chyba pamàti

; ------ zkr†cen° ©†dku

StorFK54:call      far ptr DelDat           ; zkr†cen° ©†dku
         neg       cx                       ; korekce se odeáte

; ------ aktualizace segmentu okna

StorFK55:mov       ax,ss:[bp-2]             ; segment okna
         call      far ptr GetDat           ; adresa segmentu okna
         mov       ss:[bp-4],es             ; adresa segmentu okna
         add       es:[AWinKomN],cx         ; zmàna velikosti dat koment†©ñ
         mov       ax,es                    ; segment okna
         add       ax,word ptr es:[AWinKomI+2] ; segment indexñ koment†©ñ
         mov       ss:[bp-14],ax            ; adresa indexovÇ tabulky SEGMENT

; ------ p©enesen° textu koment†©e

         cld
         mov       es,ss:[bp-8]             ; adresa segmentu koment†©ñ
         mov       al,TAB                   ; oddàlovac° znak tabul†toru
         mov       cx,ss:[bp-10]            ; poáet p©°davnòch tabul†torñ
         sub       dx,cx                    ; sn°ëen° o p©°davnÇ tabul†tory
         rep       stosb                    ; uloëen° oddàlovac°ch tabul†torñ
         mov       cx,dx                    ; CX <- dÇlka novÇho koment†©e
         mov       dx,di                    ; £schova adresy koment†©e
         mov       si,offset LinBuff        ; buffer textu
         rep       movsb                    ; p©enesen° textu koment†©e

; ------ koncov† 0

         mov       al,0
         stosb                              ; koncov† 0

; ------ nastaven° dÇlky ©†dku

         sub       di,bx                    ; dÇlka ©†dku + 1
         dec       di                       ; dÇlka ©†dku
         xchg      ax,di
         mov       es:[bx],al               ; dÇlka ©†dku

; ------ aktualizace koment†©ñ k poloëk†m (protoëe se poloëky odsunou)

StorFKm7:mov       ax,ss:[bp-2]             ; segment okna
         push      cs
         call      near ptr InitFKom        ; inicializace koment†©ñ

; ------ uloëen° souboru koment†©ñ

         push      cs
         call      near ptr WritFKom        ; uloëen° souboru koment†©ñ

; ------ n†vrat registrñ

StorFKm9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

StorFKom ENDP

; *****************************************************************************
;                                 StorNKom
;    uloëen° zadanÇho koment†©e k nadpisu adres†©e (z ©†dkovÇho bufferu LinBuff)
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo okna (adres†©ovÇ okno !)
;        DS=datovò segment
; VùSTUP: CY=chyba
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) á°slo okna
;                   SS:[BP-4] (2) á°slo segmentu koment†©ñ
; *****************************************************************************

StorNKom PROC      FAR

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
         sub       sp,4                     ; lok†ln° promànnÇ

; ------ inicializace segmentu koment†©ñ -> AX, ES

         mov       ss:[bp-2],ax             ; segment okna
         call      KomLIni                  ; inicializace zadanÇho textu
         push      cs
         call      near ptr KomSIni         ; inicializace segmentu koment†©ñ
         jnc       StorNKm2                 ; segment je OK
StorNKm1:call      far ptr MemErr           ; chyba pamàti
         jmp       StorNKm9                 ; chyba
StorNKm2:mov       ss:[bp-4],ax             ; segment koment†©ñ

; ------ nalezen° prvn°ho nepr†zdnÇho ©†dku (ES=segment koment†©ñ) -> DI

         mov       di,2                     ; zaá†tek dat
StorNKm3:cmp       di,es:[0]                ; je konec dat ?
         jae       StorNKm6                 ; je konec dat
         mov       al,es:[di+1]             ; prvn° znak ©†dku
         cmp       al,0                     ; je pr†zdnò ©†dek ?
         jne       StorNKm4                 ; nen° pr†zdnò ©†dek
         inc       di                       ; p©eskoáen° bajtu dÇlky
         inc       di                       ; p©eskoáen° bajtu 0
         jmp       short StorNKm3           ; dal®° ©†dek

; ------ test, zda to je ©†dek nadpisu

StorNKm4:cmp       al," "                   ; £vodn° mezera ?
         je        StorNKm5                 ; je to ©†dek nadpisu OK
         cmp       al,TAB
         jne       StorNKm6                 ; nen° ©†dek nadpisu

; ------ nalezen° zaá†tku textu nadpisu -> adresa DI, dÇlka AL, maxim†lnà AH

StorNKm5:mov       bx,di                    ; zaá†tek ©†dku nadpisu
         inc       di                       ; zaá†tek nadpisu
         mov       al,es:[bx]               ; star† dÇlka ©†dku
         dec       ax                       ; bez koncovÇ 0
         mov       ah,254                   ; á°taá maxim†ln° dÇlky ©†dku bez 0
StorNK52:inc       di                       ; zvò®en° ukazatele textu
         dec       ah                       ; sn°ëen° maxim†ln° dÇlky
         dec       ax                       ; sn°ëen° á°taáe zbylÇ dÇlky
         cmp       byte ptr es:[di]," "
         je        StorNK52                 ; mezera - dal®° znak
         cmp       byte ptr es:[di],TAB
         je        StorNK52                 ; tabul†tor - dal®° znak

; ------ p©°prava novÇ dÇlky ©†dku -> CX

         mov       ch,0
         mov       cl,ds:[LinNum]           ; poáet bajtñ v bufferu
         cmp       cl,ah                    ; je dÇlka textu OK ?
         jb        StorNK54                 ; dÇlka textu je OK
         mov       cl,ah                    ; omezen° dÇlky textu
StorNK54:mov       dx,cx                    ; DX <- £schova dÇlky novÇho textu
         mov       ah,0
         sub       cx,ax                    ; zmàna dÇlky ©†dku
         jz        StorNK56                 ; dÇlka ©†dku se nemàn°

; ------ prodlouëen° ©†dku

         mov       ax,ss:[bp-4]             ; segment koment†©ñ
         js        StorNK55                 ; zkr†cen° ©†dku
         call      far ptr InsDat           ; prodlouëen° ©†dku
StorNK19:jc        StorNKm1                 ; chyba
         jmp       short StorNK56

; ------ zkr†cen° ©†dku

StorNK55:neg       cx
         call      far ptr DelDat           ; zkr†cen° ©†dku
         neg       cx

; ------ bude p©enesen° textu ©†dku

StorNK56:add       es:[bx],cl               ; zmàna dÇlky ©†dku
         mov       cx,dx                    ; CX <- dÇlka textu
         jmp       short StorNK82           ; p©enesen° textu ©†dku

; ------ bude vytvo©en novò ©†dek (na adrese DI)

StorNKm6:mov       ch,0
         mov       cl,ds:[LinNum]           ; dÇlka textu
         cmp       cl,253                   ; je dÇlka ©†dku OK ?
         jb        StorNKm7                 ; dÇlka ©†dku je OK
         mov       cl,253                   ; omezen° dÇlky ©†dku
StorNKm7:add       cx,1+1+1                 ; + dÇlka + TAB + nula
         mov       ax,ss:[bp-4]             ; segment koment†©ñ
         call      far ptr InsDat           ; vytvo©en° m°sta pro ©†dek
         jc        StorNK19                 ; chyba pamàti

; ------ uloëen° novÇho ©†dku na adresu ES:DI (dÇlka celkem CX)

StorNKm8:cld
         dec       cx                       ; bez bajtu dÇlky
         mov       al,cl                    ; dÇlka ©†dku
         stosb                              ; dÇlka ©†dku
         mov       al,TAB
         stosb                              ; £vodn° tabul†tor
         dec       cx                       ; bez tabul†toru
         dec       cx                       ; bez koncovÇ 0

; ------ p©enesen° textu ©†dku (a koncovÇ 0) na adresu ES:DI, dÇlka CX

StorNK82:cld
         mov       si,offset LinBuff        ; buffer textu
         mov       bx,di                    ; £schova adresy ©†dku
         push      cx
         rep       movsb                    ; uloëen° textu nadpisu
         pop       cx
         mov       al,0
         stosb                              ; koncovò bajt 0

; ------ uloëen° souboru koment†©ñ (DI=zaá†tek pozn†mek, BX=adresa/CX=dÇlka nadpisu)

         mov       ax,ss:[bp-2]             ; segment okna
         call      far ptr GetDat           ; adresa okna
         mov       es:[AWinKomB],di         ; novò zaá†tek pozn†mek
         mov       es:[AWinKomA],bx         ; nov† adresa nadpisu
         mov       es:[AWinKomD],cx         ; nov† dÇlka nadpisu
         push      cs
         call      near ptr InitFKom        ; inicializace koment†©ñ
         push      cs
         call      near ptr WritFKom        ; uloëen° souboru koment†©ñ

; ------ n†vrat registrñ

StorNKm9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

StorNKom ENDP

; -----------------------------------------------------------------------------
;    zaji®tàn° segmentu koment†©ñ okna AX -> AX/ES (CY=chyba pamàti) niá° BX,DX
; -----------------------------------------------------------------------------

KomSIni  PROC      FAR

; ------ adresa okna AX

         call      far ptr GetDat           ; adresa definice okna
         jc        KomSIni9                 ; neplatnò segment okna
         xchg      ax,dx                    ; DX <- £schova á°sla segmentu okna

; ------ mus° to bòt adres†©ovÇ okno

         test      byte ptr es:[AWinPrm1],bit3 ; je to adres†©ovÇ okno ?
         jz        KomSIni8                 ; nen° to adres†©ovÇ okno

; ------ adresa segmentu koment†©ñ -> AX/ES

         mov       ax,es:[AWinKomS]         ; á°slo segmentu koment†©ñ
         call      far ptr GetDat           ; poskytnut° adresy koment†©ñ
         jnc       KomSIni9                 ; adresa je OK

; ------ vytvo©en° novÇho segmentu koment†©ñ -> AX

         call      far ptr CreatSeg         ; vytvo©en° segmentu
         jc        KomSIni9                 ; nedostatek pamàti

; ------ inicializaán° nastaven° velikosti segmentu koment†©ñ

         mov       bx,2                     ; inicializaán° velikost segmentu
         call      far ptr ModiSegS         ; nastaven° velikosti segmentu
         jc        KomSIni7                 ; nedostatek pamàti

; ------ uloëen° á°sla segmentu do okna

         xchg      ax,dx                    ; DX <- koment†©e, AX <- okno
         call      far ptr GetDat           ; adresa segmentu okna
         xchg      ax,dx                    ; AX <- segment koment†©ñ
         mov       es:[AWinKomS],ax         ; segment koment†©ñ

; ------ inicializace ukazatelñ

         mov       es:[AWinKomA],bx         ; adresa nadpisu
         mov       es:[AWinKomB],bx         ; zaá†tek pozn†mek
         xor       bx,bx                    ; BX <- 0
         mov       es:[AWinKomN],bx         ; poáet bajtñ pozn†mek
         mov       es:[AWinKomD],bx         ; dÇlka nadpisu

; ------ inicializace segmentu koment†©ñ

         call      far ptr GetDat           ; adresa segmentu koment†©ñ
         mov       word ptr es:[bx],2       ; poáet bajtñ v bufferu
         jmp       short KomSIni9

; ------ zru®en° segmentu koment†©ñ AX p©i chybà

KomSIni7:call      far ptr DelSeg           ; zru®en° segmentu
KomSIni8:stc                                ; p©°znak chyby
KomSIni9:ret

KomSIni  ENDP

; -----------------------------------------------------------------------------
;        p©°prava textu v editaán°m ©†dku LineBuff (oáes†n° mezer)
; -----------------------------------------------------------------------------

KomLIni  PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      si
         push      di
         push      es

; ------ p©°prava registrñ

         cld
         push      ds
         pop       es                       ; ES <- datovò segment
         mov       si,offset LinBuff        ; SI <- zaá†tek bufferu
         mov       di,si                    ; DI <- zaá†tek bufferu

; ------ vypu®tàn° mezer ze zaá†tku textu

KomLIni2:mov       cl,ds:[LinNum]           ; dÇlka zadanÇho textu
         mov       ch,0
         jcxz      KomLIni9                 ; nen° dal®° znak
         cmp       byte ptr ds:[si]," "     ; je mezera ?
         je        KomLIni3                 ; mezera se vypust°
         cmp       byte ptr ds:[si],TAB
         jne       KomLIni4                 ; je jinò znak
KomLIni3:inc       si                       ; zvò®en° ukazatele textu
         dec       byte ptr ds:[LinNum]     ; sn°ëen° dÇlky textu
         jmp       short KomLIni2           ; dal®° znak

; ------ p©enesen° zbytku textu

KomLIni4:rep       movsb                    ; p©enos textu

; ------ vypu®tàn° mezer z konce ©†dku

KomLIni5:dec       di                       ; sn°ëen° ukazatele textu
         cmp       byte ptr ds:[di]," "
         je        KomLIni6                 ; mezera - vypu®tàn°
         cmp       byte ptr ds:[di],TAB
         jne       KomLIni9                 ; jinò znak - konec
KomLIni6:dec       byte ptr ds:[LinNum]     ; sn°ëen° poátu znakñ
         jnz       KomLIni5                 ; je dal®° znak

; ------ n†vrat registrñ

KomLIni9:pop       es
         pop       di
         pop       si
         pop       cx
         ret

KomLIni  ENDP

; *****************************************************************************
;                                WritFKom
;                      uloëen° koment†©ñ k souborñm
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo okna (mus° bòt platnÇ - váetnà segmentu koment†©ñ !)
;        DS=datovò segment
; VùSTUP: CY=chyba
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) segment okna
;                   SS:[BP-4] (2) segment koment†©ñ
; *****************************************************************************

WritFKom PROC      FAR

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
         sub       sp,FileMax+4             ; buffer pro jmÇno souboru FILEINFO

; ------ konverze koment†©ñ na textovò tvar

         mov       ss:[bp-2],ax             ; segment okna
         call      far ptr GetDat           ; adresa okna
         mov       ax,es:[AWinKomS]         ; segment koment†©ñ
         mov       ss:[bp-4],ax             ; segment koment†©ñ
         call      far ptr DekBDTxt         ; konverze na textovò tvar

; ------ p©°prava specifikace souboru FILEINFO

         cld
         mov       di,sp                    ; buffer v z†sobn°ku
         push      ds

         push      es
         pop       ds                       ; DS <- segment okna
         push      ss
         pop       es                       ; ES <- buffer v z†sobn°ku

         mov       si,AWinDir               ; adres†© okna
         mov       cx,ds:[AWinDNum]         ; dÇlka textu adres†©e
         rep       movsb                    ; p©enos textu adres†©e

         mov       al,"\"
         dec       di                       ; n†vrat na posledn° znak
         scasb                              ; je adres†© ukonáen znakem "\" ?
         je        WritFKm2                 ; je OK
         stosb                              ; oddàlovaá cesty

WritFKm2:pop       ds

         mov       si,offset FileInfo       ; text "FILEINFO"
         mov       cl,9                     ; dÇlka textu (s nulou na konci)
         rep       movsb                    ; p©enos textu do bufferu

; ------ otev©en° souboru FILEINFO

         mov       si,sp                    ; buffer v z†sobn°ku
         call      far ptr CreatFil         ; vytvo©en° souboru
         jc        WritFKm7                 ; chyba vytvo©en° souboru
         call      far ptr ModiWDir         ; modifikace oken

; ------ adresa bufferu koment†©ñ

         push      ax
         mov       ax,ss:[bp-4]             ; segment bufferu koment†©e
         call      far ptr GetDat           ; poskytnut° adresy bufferu
         pop       ax

; ------ z†pis dat souboru

         call      far ptr ZapKrit          ; zapnut° kritickÇ sekce
         mov       cx,es:[0]                ; velikost bufferu v bajtech
         mov       si,2                     ; poá†teán° adresa dat
         dec       cx
         dec       cx                       ; bez £vodn°ho slova
         call      far ptr WritFile         ; z†pis dat do souboru
         jc        WritFKm6                 ; chyba z†pisu

; ------ z†pis n†rodn°ho k¢du

         cmp       byte ptr ds:[CodePagK],0 ; je k¢d uráen ?
         je        WritFKm6                 ; k¢d nen° uráen

         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         mov       di,sp                    ; DI <- buffer v z†sobn°ku

         push      ax
         mov       al,ds:[CodePagK]         ; aktu†ln° k¢d
         mov       si,offset KodISwcT       ; p©ep°naá k¢dñ
         call      far ptr SetTISwc         ; dek¢dov†n° p©ep°naáe
         pop       ax

         mov       cx,di                    ; CX <- konec dat
         mov       si,sp                    ; SI <- zaá†tek dat
         sub       cx,si                    ; dÇlka textu
         inc       cx
         inc       cx                       ; váetnà CR/LF
         call      far ptr WritFile         ; z†pis p©ep°naáe n†rodn°ho k¢du

WritFKm6:call      far ptr VypKrit          ; vypnut° kritickÇ sekce

; ------ uzav©en° souboru

         pushf
         call      far ptr ClosFile         ; uzav©en° souboru
         popf

; ------ n†vrat bin†rn°ho tvaru

WritFKm7:pushf
         mov       ax,ss:[bp-4]             ; segment koment†©ñ
         call      far ptr KodBDTxt         ; konverze na bin†rn° tvar
         popf
         jnc       WritFKm9                 ; operace OK

; ------ chybovÇ hl†®en° - chyba z†pisu do souboru

         call      far ptr TestBreak
         jc        WritFKm9                 ; je p©eru®en° operace

         mov       si,offset ChybZInf
         call      far ptr Lin0MenF         ; chybovÇ hl†®en°
         call      far ptr SetEsc           ; p©°znak p©eru®en°

; ------ n†vrat registrñ

WritFKm9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

WritFKom ENDP

; *****************************************************************************
;                               InitFKom
;                    Inicialiace koment†©ñ k souborñm
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo datovÇho bloku
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) á°slo datovÇho bloku okna
;                   SS:[BP-4] (2) adresa segmentu datovÇho bloku okna
;                   SS:[BP-6] (2) á°slo segmentu koment†©ñ
;                   SS:[BP-8] (2) adresa segmentu koment†©ñ
;                   SS:[BP-10] (2) ukazatel á°sla poloëky
;                   SS:[BP-12] (2) á°taá poloëek k vyhled†n°
;                   SS:[BP-14] (2) adresa tabulky indexñ - SEGMENT
;                   SS:[BP-16] (2) ukazatel v tabulce indexñ - OFFSET
; *****************************************************************************

InitFKom PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es
         mov       bp,sp
         sub       sp,16

; ------ adresa definice okna

         mov       ss:[bp-2],ax             ; á°slo segmentu okna
         call      far ptr GetDat           ; adresa definice okna
         jc        InitFKm1                 ; neplatnò segment okna
         mov       ss:[bp-4],es             ; adresa segmentu okna
         test      byte ptr es:[AWinPrm1],bit3 ; je adres†©ovÇ okno ?
         jz        InitFKm1                 ; nen° adres†©ovÇ okno
         mov       ax,es:[AWinKomS]         ; á°slo segmentu koment†©ñ
         mov       ss:[bp-6],ax             ; á°slo segmentu koment†©ñ
         call      far ptr GetSgAdr         ; poskytnut° adresy koment†©ñ
         jc        InitFKm1                 ; neplatnò segment koment†©ñ
         mov       ss:[bp-8],dx             ; adresa segmentu koment†©ñ
         mov       ds,dx                    ; segment koment†©ñ
         cmp       word ptr es:[AWinKomN],0 ; je nàco v bufferu ?
         jne       InitFKm2                 ; je nàjakò text v bufferu
InitFKm1:jmp       InitFKm9                 ; nen° nic v bufferu

; ------ p©°prava registrñ

InitFKm2:cld
         mov       word ptr ss:[bp-10],0    ; ukazatel á°sla poloëky
         mov       ax,es:[AWinSouN]         ; poáet souborñ
         mov       ss:[bp-12],ax            ; á°taá poloëek k vyhled†n°
         or        ax,ax                    ; jsou nàjakÇ poloëky ?
         jz        InitFKm1                 ; nejsou ë†dnÇ poloëky
         mov       ax,word ptr es:[AWinKomI]         ; adresa indexñ koment†©ñ - OFFSET
         mov       ss:[bp-16],ax            ; ukazatel v tabulce koment†©ñ
         mov       ax,es                    ; segment okna
         add       ax,word ptr es:[AWinKomI+2]       ; segment tabulky indexñ
         mov       ss:[bp-14],ax            ; adresa tabulky indexñ - SEGMENT

; ------ adresa specifikace souboru

InitFKm3:mov       bx,ss:[bp-10]            ; á°slo poloëky
         mov       es,ss:[bp-4]             ; adresa segmentu okna
         mov       si,es:[AWinKomB]         ; adresa pozn†mek
         call      far ptr GetPolDI         ; adresa poloëky
         inc       di                       ; zaá†tek jmÇna poloëky
         mov       dx,di                    ; £schova adresy zaá†tku jmÇna

; ------ test, zda je jië konec bufferu

         xor       cx,cx                    ; nen° posun adresy
InitFKm4:add       si,cx                    ; adresa zaá†tku dal®°ho ©†dku
         cmp       si,ds:[0]                ; je jië konec bufferu ?
         jae       InitFKm7                 ; konec bufferu - nen° koment†©

; ------ dÇlka ©†dku -> CX

         cld
         mov       ah,0
         lodsb                              ; AX <- dÇlka ©†dku
         xchg      ax,cx                    ; CX <- dÇlka ©†dku

; ------ p©eskoáen° pr†zdnÇho ©†dku

InitFK42:cmp       cl,1
         je        InitFKm4                 ; mal† dÇlka ©†dku - dal®° ©†dek

; ------ test, zda je adres†© ".."

         cmp       word ptr ds:[si],".."
         jne       InitFK44
         cmp       word ptr es:[di],".."
         je        InitFKm5                 ; maska souhlas°

; ------ porovn†n° jednÇ specifikace souboru

InitFK44:mov       bh,0                     ; BH <- 0
         push      cx                       ; dÇlka specifikace souboru (masky)
         push      si                       ; maska
         push      di                       ; poloëka
         xchg      si,di                    ; ES:SI=jmÇno souboru, DS:DI=maska
         call      Test1Msk                 ; test jednÇ masky souboru
         pop       di
         pop       si
         pop       cx
         jc        InitFKm4                 ; maska nesouhlas° - dal®° ©†dek

; ------ maska souhlas° - nalezen° konce masky DS:SI

         cld
InitFKm5:lodsb                              ; znak z textu
         cmp       al,0                     ; je konec ©†dku ?
         je        IniFKm62                 ; je konec ©†dku
         cmp       al,TAB
         je        InitFKm6                 ; oddàlovac° tabul†tor - OK
         cmp       al," "                   ; oddàlovac° mezera ?
         jne       InitFKm5                 ; nen° mezera - nalezen° konce textu

; ------ nalezen° zaá†tku textu

InitFKm6:lodsb
         cmp       al,0                     ; je konec ©†dku ?
         je        IniFKm62                 ; je konec ©†dku - OK
         cmp       al,TAB
         je        InitFKm6                 ; tabul†tor - p©eskoáen°
         cmp       al," "
         je        InitFKm6                 ; je mezera - dal®° znak
IniFKm62:dec       si                       ; n†vrat ukazatele na zaá†tek textu
         jmp       short InitFKm8           ; uloëen° adresy textu pozn†mky

; ------ uloëen° adresy textu pozn†mky (nen°-li text, uloë° se 0)

InitFKm7:xor       si,si                    ; p©°znak, ëe nen° koment†©
InitFKm8:les       di,ss:[bp-16]            ; ukazatel v tabulce indexñ
         mov       es:[di],si               ; £schova adresy textu
         add       word ptr ss:[bp-16],2    ; zvò®en° ukazatele v tabulce indexñ
         inc       word ptr ss:[bp-10]      ; zvò®en° ukazatele á°sla poloëky
         dec       word ptr ss:[bp-12]      ; á°taá poloëek
         jnz       InitFKm3                 ; dal®° soubor

; ------ n†vrat registrñ

InitFKm9:mov       sp,bp
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InitFKom ENDP

; *****************************************************************************
;                              GetWKurz
;               Poskytnut° poloëky pod kurzorem - zadanÇ okno
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
;        AX=poëadovanÇ okno
; VùSTUP: ES:SI=adresa poloëky pod kurzorem
;         CY=nen° ë†dn† poloëka (ES:SI nedefinov†no)
; *****************************************************************************

GetWKurz PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         jmp       short GetAKrz1

GetWKurz ENDP

; *****************************************************************************
;                                 GetNKurz
;                Poskytnut° poloëky pod kurzorem - neaktivn° okno
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:ES:SI=adresa poloëky
;        CY=nen° ë†dn† poloëka (ES:SI nedefinov†no)
; *****************************************************************************

GetNKurz PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx

; ------ poskytnut° adresy datovÇho bloku

         mov       ax,ds:[SegmNAkt]         ; segment neaktivn°ho okna
         jmp       short GetAKrz1

GetNKurz ENDP

; *****************************************************************************
;                                 GetAKurz
;                Poskytnut° poloëky pod kurzorem - aktivn° okno
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:ES:SI=adresa poloëky
;        CY=nen° ë†dn† poloëka (ES:SI nedefinov†no)
; *****************************************************************************

GetAKurz PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx

; ------ poskytnut° adresy datovÇho bloku

         mov       ax,ds:[SegmAkt]          ; segment aktivn°ho okna
GetAKrz1:call      far ptr GetDat           ; poskytnut° adresy datovÇho bloku
         jc        GetAKrz9

; ------ adresa poloëky

         mov       bx,es:[AWinKurz]         ; kurzor
         push      cs
         call      near ptr GetESPol        ; adresa poloëky
                                          ;* zde m† bòt NC = p©°znak operace OK
; ------ n†vrat registrñ

GetAKrz9:pop       bx
         pop       ax
         ret

GetAKurz ENDP

;; *****************************************************************************
;;                               GetKomSI
;;                    poskytnut° adresy koment†©e
;; -----------------------------------------------------------------------------
;; VSTUP: BX=á°slo poloëky
;;        ES=segment definice okna
;; VùSTUP: SI=adresa koment†©e
;;         CY=neplatn† poloëka
;; *****************************************************************************
;
;GetKomSI PROC      FAR
;
;; ------ £schova registrñ
;
;         push      ax
;         push      es
;
;; ------ kontrola á°sla poloëky
;
;         cmp       bx,es:[AWinSouN]         ; kontrola á°sla poloëky
;         cmc
;         jc        GetKomS9                 ; chybnÇ á°slo poloëky
;
;; ------ poskytnut° adresy poloëky
;
;         mov       si,bx                    ; á°slo poloëky
;         shl       si,1                     ; á°slo poloëky * 2
;         add       si,word ptr es:[AWinKomI]         ; p©iáten° offsetu tabulky indexñ
;         mov       ax,es
;         add       ax,word ptr es:[AWinKomI+2]
;         mov       es,ax                    ; ES:SI=adresa indexu
;         mov       si,es:[si]               ; adresa koment†©e
;                                          ;* zde m† bòt NC = p©°znak operace OK
;; ------ n†vrat registrñ
;
;GetKomS9:pop       es
;         pop       ax
;         ret
;
;GetKomSI ENDP
;
;; *****************************************************************************
;;                               GetKomDI
;;                    poskytnut° adresy koment†©e
;; -----------------------------------------------------------------------------
;; VSTUP: BX=á°slo poloëky
;;        ES=segment definice okna
;; VùSTUP: SI=adresa koment†©e
;;         CY=neplatn† poloëka
;; *****************************************************************************
;
;GetKomDI PROC      FAR
;
;; ------ £schova registrñ
;
;         push      ax
;         push      es
;
;; ------ kontrola á°sla poloëky
;
;         cmp       bx,es:[AWinSouN]         ; kontrola á°sla poloëky
;         cmc
;         jc        GetKomD9                 ; chybnÇ á°slo poloëky
;
;; ------ poskytnut° adresy poloëky
;
;         mov       di,bx                    ; á°slo poloëky
;         shl       di,1                     ; á°slo poloëky * 2
;         add       di,word ptr es:[AWinKomI]         ; p©iáten° offsetu tabulky indexñ
;         mov       ax,es
;         add       ax,word ptr es:[AWinKomI+2]
;         mov       es,ax                    ; ES:SI=adresa indexu
;         mov       di,es:[di]               ; adresa koment†©e
;                                          ;* zde m† bòt NC = p©°znak operace OK
;; ------ n†vrat registrñ
;
;GetKomD9:pop       es
;         pop       ax
;         ret
;
;GetKomDI ENDP

; *****************************************************************************
;                                GetPolDI
;           poskytnut° adresy poloëky adres†©ovÇho okna ES
; -----------------------------------------------------------------------------
; VSTUP: BX=á°slo poloëky
;        ES=segment definice okna
; VùSTUP: ES:DI=adresa poloëky
;         CY=neplatn† poloëka
; *****************************************************************************

GetPolDI PROC      FAR

         push      si
         push      cs
         call      near ptr GetESPol
         mov       di,si
         pop       si
         ret

GetPolDI ENDP

; *****************************************************************************
;                                 GetPol
;                Poskytnut° adresy poloëky adres†©ovÇho okna
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo datovÇho bloku
;        BX=á°slo poloëky
;        DS=datovò segment
; VùSTUP:ES:SI=adresa poloëky
;        CY=neplatn† poloëka (ES nedefinov†no)
; *****************************************************************************

; -----------------------------------------------------------------------------
;        GetESPol - adresa poloëky BX, zad†na adresa segmentu okna ES -> ES:SI
; -----------------------------------------------------------------------------

GetPol   PROC      FAR

; ------ poskytnut° adresy datovÇho bloku

         call      far ptr GetDat           ; poskytnut° adresy datovÇho bloku
         jc        GetPol9

; ------ kontrola á°sla poloëky

GetESPol LABEL     FAR

         cmp       bx,es:[AWinSouN]         ; kontrola á°sla poloëky
         cmc
         jc        GetPol9                  ; chybnÇ á°slo poloëky

; ------ poskytnut° adresy poloëky

         push      ax
         mov       si,bx                    ; á°slo poloëky
         shl       si,1                     ; á°slo poloëky * 2
         add       si,bx                    ; á°slo poloëky * 3
         mov       ax,es                    ; adresa okna
         push      ax
         add       si,word ptr es:[AWinSouI]         ; p©iáten° offsetu tabulky indexñ
         add       ax,word ptr es:[AWinSouI+2]
         mov       es,ax                    ; ES:SI=adresa indexu
         pop       ax                       ; adresa okna
         add       ax,es:[si+1]             ; segment poloëky
         mov       si,es:[si]               ; offset poloëky
         and       si,0ffh                  ; offset poloëky
         mov       es,ax                    ; segment poloëky
         pop       ax
;         clc                                ; p©°znak operace OK

GetPol9: ret

GetPol   ENDP

; *****************************************************************************
;                              ReSort
;           p©et©°dàn° adres†©ovÇho okna (se zachov†n°m kurzoru)
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo okna k p©et©°dàn°
;        DS=datovò segment
; VùSTUP: CY=nàjak† chyba (nedostatek pamàti)
; *****************************************************************************
;˛
ReSort   PROC      FAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp
         sub       sp,12                    ; rezerva pro poloëku FCB

; ------ adresa datovÇho bloku okna

         call      far ptr GetDat           ; poskytnut° adresy datovÇho bloku
         jc        ReSort9                  ; aktivn° okno neexistuje (?)

; ------ kontrola kurzoru

         xor       bx,bx                    ; BX <- 0 kurzor bude zru®en
         xchg      bx,es:[AWinKurz]         ; BX <- kurzor

         test      byte ptr es:[AWinPrm1],bit5 ; je to seznam ?
         jz        ReSort1
         mov       es:[AWinKurz],bx         ; pro seznam se ponech† kurzor

ReSort1: cmp       bx,es:[AWinSouN]         ; kontrola á°sla poloëky
         jb        ReSort2                  ; á°slo poloëky je OK

; ------ p©et©°dàn° adres†©e, je-li kurzor neplatnò

         push      cs
         call      near ptr SelWDir         ; vòbàr poloëek okna
;         jc        ReSort9                  ; nedostatek pamàti
         push      cs
         call      near ptr SortDir         ; novÇ set©°dàn° okna
         jmp       short ReSort8

; ------ poskytnut° adresy poloëky kurzoru -> ES:SI

ReSort2: push      cs
         call      near ptr GetESPol        ; adresa poloëky ES:SI

; ------ £schova jmÇna poloëky do z†sobn°ku

         mov       di,sp                    ; buffer v z†sobn°ku
         push      ds
         push      es
         pop       ds                       ; DS <- segment poloëky
         push      ss
         pop       es                       ; ES <- segment bufferu
         cld
         inc       si                       ; zaá†tek jmÇna poloëky
         mov       cx,6                     ; dÇlka jmÇna/2
         rep       movsw                    ; £schova jmÇna poloëky
         pop       ds

; ------ p©et©°dàn° adres†©e

         push      cs
         call      near ptr SelWDir         ; vòbàr poloëek okna
;         jc        ReSort9                  ; nedostatek pamàti
         push      cs
         call      near ptr SortDir         ; novÇ set©°dàn° okna

; ------ n†vrat kurzoru

         mov       si,sp                    ; jmÇno poloëky v z†sobn°ku
         push      cs
         call      near ptr RetWKur         ; n†vrat pozice kurzoru

; ------ n†vrat registrñ

ReSort8: clc                                ; p©°znak operace OK
ReSort9: mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       cx
         pop       bx
         ret

ReSort   ENDP

; *****************************************************************************
;                              AktSelct
;         aktualizace vòbàru poloëek okna (spoáten°) (uchov†v† p©°znaky !)
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo okna
;        DS=datovò segment
; *****************************************************************************

AktSelct PROC      FAR

; ------ £schova registrñ

         pushf
         push      ax
         push      bx
         push      si
         push      bp
         push      es

; ------ adresa okna

         call      far ptr GetDat           ; adresa definice okna
         jc        AktSelc9                 ; neplatnÇ okno
         mov       bp,es

; ------ p©°prava k vyhled†v†n°

         xor       bx,bx                    ; BX <- 0 ukazatel á°sla poloëky
         mov       es:[AWinSNum],bx         ; poáet oznaáenòch poloëek
         mov       word ptr es:[AWinSSum],bx         ; souáet kapacit LOW
         mov       word ptr es:[AWinSSum+2],bx       ; souáet kapacit HIGH

; ------ adresa poloëky

AktSelc2:mov       es,bp
         call      far ptr GetESPol         ; adresa poloëky
         jc        AktSelc9                 ; konec poloëek

; ------ test, zda je poloëka oznaáen†

         test      byte ptr es:[si+FileAtr],ATRT ; je to platn† poloëka ?
         jz        AktSelc5                 ; nen° to platn† poloëka
         test      byte ptr es:[si+FileAtr],ATRO ; je poloëka oznaáen† ?
         jz        AktSelc5                 ; poloëka nen° oznaáen†

; ------ p©iáten° velikosti poloëky

         mov       ax,word ptr es:[si+FileSize]
         mov       si,word ptr es:[si+FileSize+2]
         mov       es,bp
         inc       word ptr es:[AWinSNum]   ; zvò®en° á°taáe poloëek
         add       word ptr es:[AWinSSum],ax  ; p©iáten° velikosti LOW
         adc       word ptr es:[AWinSSum+2],si ; p©iáten° velikosti HIGH

; ------ dal®° poloëka

AktSelc5:inc       bx                       ; zvò®en° ukazatele poloëek
         jmp       short AktSelc2           ; dal®° poloëka

; ------ n†vrat registrñ

AktSelc9:pop       es
         pop       bp
         pop       si
         pop       bx
         pop       ax
         popf
         ret

AktSelct ENDP

; *****************************************************************************
;                               SrcWNam
;   nalezen° stejnÇ poloëky v oknà podle jmÇna (ignoruje se platnost poloëky)
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo okna
;        ES:SI=hledan† poloëka v intern°m tvaru (pouëije se jen jmÇno a p©°pona)
;        DS=datovò segment
; VùSTUP: BX=nalezen† poloëka
;         CY=poloëka nenalezena (BX nedefinov†no)
; *****************************************************************************

SrcWNam  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

; ------ p©°prava registrñ

         call      far ptr GetSgAdr         ; adresa okna -> DX
         jc        SrcWNam9                 ; chyba okna ?
         mov       ch,0                     ; CH <- 0
         xor       bx,bx                    ; BX <- 0 ukazatel á°sla poloëky
         push      es
         pop       ds                       ; DS <- segment hledanÇ poloëky
         inc       si                       ; zaá†tek jmÇna hledanÇ poloëky
         xchg      ax,si                    ; AX <- adresa hledanÇ poloëky

; ------ adresa dal®° poloëky

         dec       bx                       ; p©ednastaven° á°sla poloëky
SrcWNam2:inc       bx                       ; zvò®en° ukazatele á°sla poloëky
         mov       es,dx                    ; ES <- segment okna
         call      far ptr GetPolDI         ; adresa poloëky ES:DI
         jc        SrcWNam9                 ; nen° dal®° poloëka
         inc       di                       ; zaá†tek jmÇna poloëky

; ------ porovn†n° jmÇna poloëky

         mov       si,ax                    ; SI <- adresa hledanÇ poloëky
         mov       cl,8+3                   ; dÇlka jmÇna poloëky
         cld
         repe      cmpsb                    ; porovn†n° jmÇna poloëky
         jne       SrcWNam2                 ; poloëka nesouhlas° - dal®°

; ------ n†vrat registrñ

SrcWNam9:pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

SrcWNam  ENDP

; *****************************************************************************
;                                SrcWKur
;                      nalezen° bl°zkÇ poloëky v oknà
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo okna
;        ES:SI=adresa hledanÇ poloëky (v intern°m tvaru)
;        DS=datovò segment
; VùSTUP: BX=nalezen† poloëka
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) ukazatel á°sla poloëky
;                   SS:[BP-3] (1)
;                   SS:[BP-3-FileSumm] (FileSumm) uschovan† poloëka
; *****************************************************************************

SrcWKur  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es
         mov       bp,sp
         sub       sp,2+FileSumm+1          ; buffer v z†sobn°ku

; ------ £schova poloëky do bufferu

         mov       cx,FileSumm
         mov       di,sp
SrcWKur1:mov       bl,es:[si]
         mov       ss:[di],bl
         inc       si
         inc       di
         loop      SrcWKur1

; ------ adresa definice okna

         call      far ptr GetDat           ; adresa definice okna
         push      es                       ; segment definice okna
         pop       ds                       ; DS <- segment definice okna
         mov       word ptr ss:[bp-2],0     ; ukazatel á°sla poloëky
         mov       dl,ds:[AWinPrm2]         ; parametry okna
         cld
         mov       ch,0

; ------ adresa testovanÇ poloëky -> ES:DI (hledan† poloëka -> SS:SI)

SrcWKur2:mov       bx,ss:[bp-2]             ; á°slo poloëky
         push      ds
         pop       es                       ; ES <- segment okna
         call      far ptr GetPolDI         ; adresa poloëky -> ES:DI
         jnc       SrcWKr22
SrcWKr21:jmp       SrcWKur9                 ; jsou jië v®echny poloëky
SrcWKr22:mov       si,sp                    ; adresa hledanÇ poloëky

; ------ net©°dànÇ okno

         test      dl,bit0                  ; je t©°dàn° ?
         jz        SrcWKur3                 ; je t©°dàn°
         inc       si
         inc       di
         mov       cl,11                    ; dÇlka jmÇna s p©°ponou
         push      ds
         push      ss
         pop       ds
         repe      cmpsb                    ; porovn†n° jmen souborñ
         pop       ds
         je        SrcWKr21                 ; poloëka nalezena
         jmp       SrcWKur8                 ; dal®° poloëka

; ------ atributy poloëek

SrcWKur3:mov       bh,0
         mov       bl,es:[di+FileATyp]      ; typ poloëky 1
         inc       bl
         mov       al,cs:[bx+GrpSortT]      ; t©°dic° typ poloëky 1
         mov       bl,ss:[si+FileATyp]      ; typ poloëky 2
         inc       bl
         mov       ah,cs:[bx+GrpSortT]      ; t©°dic° typ poloëky 2

; ------ zaji®tàn° spr†vnÇ skupiny

         cmp       al,ah
         jb        SrcWKur8                 ; dal®° poloëka
         ja        SrcWKur9                 ; nalezeno

; ------ rozli®en° zpñsobu t©°dàn°

SrcWKur4:test      dl,bit1 + bit2           ; je t©°dàn° podle jmÇna ?
         jz        SrcWKur7                 ; je t©°dàn° podle jmÇna
         test      dl,bit1                  ; t©°dàn° podle velikosti ?
         jz        SrcWKur5                 ; t©°dàn° podle velikosti
         test      dl,bit2                  ; t©°dàn° podle p©°pony ?
         jz        SrcWKur6                 ; t©°dàn° podle p©°pony

; ------ porovn†n° data a áasu

         mov       ax,ss:[si+FileDate]      ; datum
         cmp       ax,es:[di+FileDate]      ; porovn†n° data
         jne       SrcWKr77                 ; data jsou rozd°ln†
         mov       ax,ss:[si+FileTime]      ; áas
         cmp       ax,es:[di+FileTime]      ; porovn†n° áasñ
         jne       SrcWKr77                 ; áasy jsou rozd°lnÇ
         jmp       short SrcWKur7           ; jinak porovn†n° jmen

; ------ porovn†n° velikosti

SrcWKur5:mov       ax,word ptr ss:[si+FileSize+2] ; vy®®° slovo velikosti
         cmp       ax,word ptr es:[di+FileSize+2] ; porovn†n° vy®®°ho slova
         jne       SrcWKr77                 ; velikost rozd°ln†
         mov       ax,word ptr ss:[si+FileSize] ; nië®° slovo velikosti
         cmp       ax,word ptr es:[di+FileSize] ; porovn†n° nië®°ch slov
         jne       SrcWKr77                 ; velikost rozd°ln†
         jmp       short SrcWKur7           ; jinak porovn†n° jmen

; ------ porovn†n° p©°pony

SrcWKur6:push      si
         push      di
         push      ds
         push      ss
         pop       ds
         add       si,FileExt
         add       di,FileExt
         mov       cl,3
         repe      cmpsb                    ; porovn†n° p©°pon
         je        SrcWKr62
         cmc
SrcWKr62:pop       ds
         pop       di
         pop       si
         jne       SrcWKr77                 ; nen° shodn† p©°pona

; ------ porovn†n° jmen

SrcWKur7:inc       si
         inc       di
         mov       cl,11                    ; dÇlka jmÇna s p©°ponou
         push      ds
         push      ss
         pop       ds
         repe      cmpsb                    ; porovn†n° jmen souborñ
         pop       ds
         je        SrcWKr77
         cmc

; ------ zhodnocen° vòsledku porovn†n°

SrcWKr77:je        SrcWKur9                 ; shodnÇ - nalezeno OK
         jb        SrcWKr78                 ; testovanò soubor je men®°
         test      dl,bit3                  ; je vzestupnÇ t©°dàn° ?
         jz        SrcWKur9                 ; vzestupnÇ t©°dàn° - je to OK
         jmp       short SrcWKur8           ; jinak dal®° poloëka
SrcWKr78:test      dl,bit3                  ; je vzestupnÇ t©°dàn° ?
         jnz       SrcWKur9                 ; sestupnÇ t©°dàn° - OK

; ------ p©°prava pro dal®° poloëku

SrcWKur8:inc       word ptr ss:[bp-2]       ; zvò®en° ukazatele poloëek
         jmp       SrcWKur2                 ; test dal®° poloëky

; ------ n†vrat registrñ

SrcWKur9:mov       bx,ss:[bp-2]             ; á°slo nalezenÇ poloëky
         mov       sp,bp
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

SrcWKur  ENDP

; *****************************************************************************
;                                RetWKur
;             n†vrat kurzoru na poloëku adres†©e (ve tvaru FCB)
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo okna
;        ES:SI (11) jmÇno pñvodn° poloëky s kurzorem ve tvaru FCB
;        DS=datovò segment
; VùSTUP: CY=poloëka nenalezena (kurzor zñst†v† nezmànàn)
; *****************************************************************************

RetWKur  PROC      FAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

; ------ adresa definice okna

         mov       dx,si                    ; adresa hledanÇ poloëky
         push      es
         call      far ptr GetDat           ; adresa definice okna
         pop       ds                       ; DS <- segment hledanÇ poloëky
         mov       bp,es                    ; BP <- segment definice okna
         jc        RetWKur9

; ------ p©°prava registrñ

         cld
         mov       ch,0                     ; CH <- 0
         xor       bx,bx                    ; ukazatel á°sla poloëky
         dec       bx

; ------ p©°prava vòchoz° poloëky pro seznam

         test      byte ptr es:[AWinPrm1],bit5 ; je to seznam ?
         jz        RetWKur5                 ; nen° to seznam
         mov       bx,es:[AWinKurz]
         inc       bx
RetWKur2:dec       bx
         mov       es,bp
         call      far ptr GetESPol
         jc        RetWKur5
         test      byte ptr es:[si+FileAtr],ATRT ; je to cesta ?
         jnz       RetWKur2                 ; nalezen° cesty

; ------ vyhled†n° poloëky

RetWKur5:inc       bx                       ; zvò®en° ukazatele poloëek
         mov       es,bp                    ; ES <- segment okna
         call      far ptr GetPolDI         ; adresa poloëky -> ES:DI
         jc        RetWKur9                 ; poloëka nenalezena
         test      byte ptr es:[di+FileAtr],ATRT ; je to platn† poloëka ?
         stc
         jz        RetWKur5                 ; poloëka nenalezena

         inc       di                       ; zaá†tek jmÇna poloëky
         mov       si,dx                    ; jmÇno hledanÇ poloëky
         mov       cl,11                    ; dÇlka hledanÇ poloëky
         repe      cmpsb                    ; porovn†n° jmÇna poloëky
         jne       RetWKur5                 ; poloëka neodpov°d† - dal®°

; ------ uloëen° pozice kurzoru nalezenÇ poloëky

RetWKur8:mov       es,bp                    ; ES <- segment okna
         mov       es:[AWinKurz],bx         ; nov† pozice kurzoru

; ------ n†vrat registrñ

RetWKur9:pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         call      far ptr AktPathT         ; aktualizace stromu v aktivn°m oknà
         call      far ptr AktPathL         ; aktualizace cesty okna seznamu
         ret

RetWKur  ENDP

; *****************************************************************************
;                                  ModAWDir
;          modifikace obsahu adres†©e v oknech s aktualizac° souboru
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=pln† specifikace souboru/adres†©e v modifikovanÇm adres†©i ASCIIZ
;        DS=datovò segment
; uchov†v† registr p©°znakñ !
; *****************************************************************************

ModAWDir PROC      FAR

         pushf
         push      ax
         push      cx
         mov       al,bit0+bit1+bit3+bit4+bit6+bit7 ; parametry
         xor       cx,cx                    ; dÇlka adres†©e nezn†m†
         push      cs
         call      near ptr ModWFile        ; aktualizace adres†©e
         pop       cx
         pop       ax
         popf
         ret

ModAWDir ENDP

; *****************************************************************************
;                                  ModiWDir
;             modifikace obsahu adres†©e v oknech (mñëe posouvat segmenty !)
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=pln† specifikace souboru/adres†©e v modifikovanÇm adres†©i ASCIIZ
;        DS=datovò segment
; uchov†v† registr p©°znakñ !
; *****************************************************************************

ModiWDir PROC      FAR

         pushf
         push      ax
         push      cx
         mov       al,bit0+bit1+bit6        ; parametry
         xor       cx,cx                    ; dÇlka adres†©e nezn†m†
         push      cs
         call      near ptr ModWFile        ; aktualizace adres†©e
         pop       cx
         pop       ax
         popf
         ret

ModiWDir ENDP

; *****************************************************************************
;                                AktWFile
;          aktualizace informac° o souboru/adres†©i po jeho modifikaci
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=pln† specifikace souboru ASCIIZ
;        CX=dÇlka textu adres†©e
;        DS=datovò segment
; *****************************************************************************

AktWFile PROC      FAR

         push      ax
         mov       al,bit0+bit1+bit2+bit6+bit7
         push      cs
         call      near ptr ModWFile        ; aktualizace poloëky
         pop       ax
         ret

AktWFile ENDP

; *****************************************************************************
;                                 DelWFile
;             zru®en° poloëky (souboru nebo adres†©e) z oken
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=pln† specifikace poloëky ASCIIZ
;        CX=dÇlka textu adres†©e (bez jmÇna poloëky)
;        DX:DI=parametry poloëky (intern° tvar "FileSumm" - jen velikost)
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) segment adresy specifikace poloëky
;                   SS:[BP-4] (2) offset adresy specifikace poloëky
;                   SS:[BP-6] (2) dÇlka textu adres†©e (bez jmÇna poloëky)
;                   SS:[BP-8] (2) á°slo testovanÇho okna
;                   SS:[BP-10] (2) adresa testovanÇho okna
;                   SS:[BP-12] (2) á°slo nalezenÇ poloëky
; *****************************************************************************

DelWFile PROC      FAR

         push      ax
         mov       al,bit0+bit1+bit3+bit6
         push      cs
         call      near ptr ModWFile        ; zru®en° poloëky
         pop       ax
         ret

DelWFile ENDP

; *****************************************************************************
;                                InsWFile
;                      vytvo©en° poloëky v oknà
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=pln† specifikace poloëky ASCIIZ
;        CX=dÇlka textu adres†©e (bez jmÇna poloëky)
;        DX:DI=parametry poloëky (intern° tvar "FileSumm", jmÇno se nepouëije)
;        DS=datovò segment
; *****************************************************************************

InsWFile PROC      FAR

         push      ax
         mov       al,bit0+bit1+bit4+bit6
         push      cs
         call      near ptr ModWFile        ; vytvo©en° poloëky
         pop       ax
         ret

InsWFile ENDP

; *****************************************************************************
;                               ModWFile
;              modifikace poloëky v oknà bàhem operace
; -----------------------------------------------------------------------------
; VSTUP: AL=parametry
;                  bit 0: 1=aktualizace informac° o disku
;                  bit 1: 1=aktualizace informac° o adres†©i (novÇ naáten°)
;                  bit 2: 1=aktualizace parametrñ poloëky
;                  bit 3: 1=zru®en° poloëky, pokud je v oknà
;                  bit 4: 1=vytvo©en° poloëky, pokud nen° v oknà
;                  bit 5:
;                  bit 6: 1=jmÇno poloëky je za textem adres†©e (jako ASCIIZ)
;                           (jinak je jmÇno v poloëce DX:DI)
;                  bit 7: 1=ovà©it poloëku z disku (naá°st parametry poloëky)
;                           (nuluj° se p©°padnÇ bity 2, 3 a 4, jsou-li nastaveny)
;        ES:SI=pln† specifikace poloëky ASCIIZ (s diskem a adres†©em)
;        CX=dÇlka textu adres†©e (bez jmÇna poloëky) (0=dÇlka nezn†m†)
;        DX:DI=parametry poloëky (intern° tvar "FileSumm")
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-1] (1) pracovn° parametry
;                                    bit 0: 1=poloëka nalezena na disku
;                                    bit 1: 1=poloëka nalezena v seznamu
;                                    bit 2: 1=je to aktivn° adres†© okna
;                   SS:[BP-2] (1) zadanÇ parametry operace
;                                    bit 0: 1=aktualizace informac° o disku
;                                    bit 1: 1=aktualizace informac° o adres†©i (novÇ naáten°)
;                                    bit 2: 1=aktualizace parametrñ poloëky
;                                    bit 3: 1=zru®en° poloëky, pokud je v oknà
;                                    bit 4: 1=vytvo©en° poloëky, pokud nen° v oknà
;                                    bit 5:
;                                    bit 6: 1=jmÇno poloëky je za textem adres†©e (jako ASCIIZ)
;                                    bit 7: 1=ovà©it poloëku z disku (naá°st parametry poloëky)
;                                             (nuluj° se p©°padnÇ bity 2, 3 a 4, jsou-li nastaveny)
;                   SS:[BP-3] (1) £schova zadanòch parametrñ operace
;                   SS:[BP-4] (1) typ okna
;                                    bit 3: 1=adres†©ovÇ okno
;                                    bit 4: 1=okno stromu
;                                    bit 5: 1=okno seznamu
;                   SS:[BP-6] (2) dÇlka textu adres†©e (bez jmÇna poloëky)
;                   SS:[BP-8] (2) adresa textu adres†©e (v z†sobn°ku)
;                   SS:[BP-10] (2) á°slo testovanÇho okna
;                   SS:[BP-12] (2) adresa testovanÇho okna
;                   SS:[BP-14] (2) á°slo nalezenÇ poloëky v oknà
;                   SS:[BP-18] (4) adresa nalezenÇ poloëky v oknà (posouv† se !)
;                   SS:[BP-22] (4) velikost nalezenÇ poloëky
;                   SS:[BP-22-FileSumm] (FileSumm) poloëka v intern°m tvaru
;                              (1) p©°padnÇ zaokrouhlen° na sudou adresu
;                         .... uschovanò text adres†©e
; *****************************************************************************
;˛
ModWFPar EQU       byte ptr ss:[bp-1]       ; (1) pracovn° parametry
                                            ;  bit 0: 1=poloëka nalezena na disku
                                            ;  bit 1: 1=poloëka nalezena v seznamu
                                            ;  bit 2: 1=je aktivn° adres†© okna
ModWFSwc EQU       byte ptr ss:[bp-2]       ; (1) zadanÇ parametry operace
                                            ;  bit 0: 1=aktualizace informac° o disku
                                            ;  bit 1: 1=aktualizace informac° o adres†©i (novÇ naáten°)
                                            ;  bit 2: 1=aktualizace parametrñ poloëky
                                            ;  bit 3: 1=zru®en° poloëky, pokud je v oknà
                                            ;  bit 4: 1=vytvo©en° poloëky, pokud nen° v oknà
                                            ;  bit 5:
                                            ;  bit 6: 1=jmÇno poloëky je za textem adres†©e (jako ASCIIZ)
                                            ;  bit 7: 1=ovà©it poloëku z disku (naá°st parametry poloëky)
                                            ;           (nuluj° se p©°padnÇ bity 2, 3 a 4, jsou-li nastaveny)
ModWFSwU EQU       byte ptr ss:[bp-3]       ; (1) £schova zadanòch parametrñ operace
ModWFTyp EQU       byte ptr ss:[bp-4]       ; (1) typ okna
                                            ;  bit 3: 1=adres†©ovÇ okno
                                            ;  bit 4: 1=okno stromu
                                            ;  bit 5: 1=okno seznamu
ModWFDel EQU       word ptr ss:[bp-6]       ; (2) dÇlka textu adres†©e (bez jmÇna)
ModWFAdr EQU       word ptr ss:[bp-8]       ; (2) adresa textu adres†©e v z†sobn°ku
ModWFTst EQU       word ptr ss:[bp-10]      ; (2) á°slo testovanÇho okna
ModWFSeg EQU       word ptr ss:[bp-12]      ; (2) segment testovanÇho okna
ModWFNPl EQU       word ptr ss:[bp-14]      ; (2) á°slo nalezenÇ poloëky v oknà
ModWFAPl EQU       word ptr ss:[bp-18]      ; (4) adresa nalezenÇ poloëky v oknà
ModWFSiz EQU       word ptr ss:[bp-22]      ; (4) velikost nalezenÇ poloëky
ModWFPol EQU       ss:[bp-22-FileSumm]      ; (21) poloëka v intern°m tvaru
;  + FileAtr                                ; (1) atributy
;  + FileName                               ; (8) jmÇno
;  + FileExt                                ; (3) p©°pona
;  + FileSize                               ; (4) velikost
;  + FileDate                               ; (2) datum
;  + FileTime                               ; (2) áas
;  + FileATyp                               ; (1) typ

; Atributy "FileAtr" jsou opraveny podle nalezenÇ poloëky v oknà (oznaáen°)

ModWFile PROC      FAR

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

; ------ test, zda je dÇlka adres†©e zn†m†

         jcxz      ModWFl02                 ; dÇlka adres†©e nen° zn†m†
         jmp       short ModWFl06           ; dÇlka adres†©e je zn†m†

; ------ zji®tàn° celkovÇ dÇlky ©etàzce -> CX

ModWFl02:push      ax
         push      di

         mov       di,si                    ; DI <- adresa ©etàzce
         mov       al,0                     ; hledanò bajt 0 (konec ©etàzce)
         cld
         mov       cx,-1
         repne     scasb                    ; nalezen° konce ©etàzce
         neg       cx                       ; dÇlka ©etàzce + 2
         dec       cx                       ; dÇlka ©etàzce + 1

; ------ nalezen° konce cesty (p©edpoklad - bude jistà obsahovat alespo§ 1x "\")

         std
         dec       di                       ; n†vrat na koncovou 0
         mov       al,"\"                   ; hledanò znak oddàlovaáe
         repne     scasb                    ; nalezen° konce cesty
         cmp       byte ptr es:[di],":"     ; je to ROOT ?
         jne       ModWFl04                 ; nen° to ROOT
         inc       cx                       ; plat° znak "\"

ModWFl04:pop       di
         pop       ax

; ------ p©°prava bufferu v z†sobn°ku

ModWFl06:sub       sp,(22+FileSumm+1) AND not 1 ; buffer pro lok†ln° promànnÇ
         mov       ModWFSwc,al              ; uloëen° parametrñ
         mov       ModWFPar,0               ; pracovn° parametry
         mov       ModWFDel,cx              ; dÇlka textu adres†©e
         inc       cx                       ; váetnà koncovÇ 0
         inc       cx                       ; zaokrouhlen° nahoru
         and       cl,not bit0              ; zarovn†n° na sudou velikost
         sub       sp,cx                    ; buffer pro jmÇno adres†©e
         mov       ModWFAdr,sp              ; adresa adres†©e v bufferu

; ------ £schova registrñ

         push      si                       ; offset specifikace poloëky ASCIIZ
         push      es                       ; segment specifikace poloëky ASCIIZ
         push      ds                       ; datovò segment

; ------ £schova vzoru poloëky DX:DI (je moënÇ, ëe je DX:DI nedefinov†no)

         push      si                       ; offset specifikace poloëky ASCIIZ
         push      es                       ; segment specifikace poloëky ASCIIZ

         mov       si,di                    ; SI <- offset vzoru poloëky
         mov       ds,dx                    ; DS <- segment vzoru poloëky
         mov       ax,word ptr ds:[si+FileSize] ; velikost poloëky LOW
         mov       ModWFSiz,ax              ; pñvodn° velikost poloëky LOW
         mov       ax,word ptr ds:[si+FileSize+2]
         mov       ModWFSiz+2,ax            ; pñvodn° velikost poloëky HIGH

         lea       di,ModWFPol              ; buffer poloëky
         push      ss
         pop       es                       ; ES <- buffer poloëky v z†sobn°ku
         mov       cx,FileSumm              ; dÇlka poloëky
         cld
         rep       movsb                    ; £schova vzoru poloëky

         pop       ds                       ; segment specifikace poloëky ASCIIZ
         pop       si                       ; offset specifikace poloëky ASCIIZ

; ------ £schova specifikace adres†©e DS:SI (je CLD)

         mov       di,ModWFAdr              ; DI <- buffer k £schovà adres†©e
         mov       cx,ModWFDel              ; dÇlka textu adres†©e
         rep       movsb                    ; £schova textu adres†©e
         mov       al,0                     ; koncov† 0
         stosb                              ; uloëen° 0

; ------ dek¢dov†n° jmÇna poloëky DS:SI

         test      ModWFSwc,bit6            ; je jmÇno poloëky ?
         jz        ModWFil1                 ; nen° jmÇno poloëky
         lea       di,ModWFPol+FileName     ; buffer jmÇna poloëky
         call      far ptr AsciFCB          ; dek¢dov†n° jmÇna poloëky

; ------ n†vrat registrñ

ModWFil1:pop       ds                       ; datovò segment
         pop       es                       ; segment specifikace poloëky ASCIIZ
         pop       si                       ; offset specifikace poloëky ASCIIZ

; ------ naáten° informac° o souboru ES:SI

         test      ModWFSwc,bit7            ; m† bòt poloëka ovà©ena ?
         jz        ModWFil3                 ; nem† bòt ovà©ena
         call      far ptr ExisFile         ; nalezen° souboru
         jc        ModWFil2                 ; soubor nenalezen

; ------ poloëka na disku nalezena

         or        ModWFPar,bit0            ; p©°znak nalezen° poloëky na disku
         and       ModWFSwc,not bit3        ; z†kaz zru®en° poloëky

; ------ £schova parametrñ poloëky

         mov       ax,word ptr ds:[BuffDTA+DTADate]    ; datum poloëky
         mov       ModWFPol+FileDate,ax                ; datum poloëky
         mov       ax,word ptr ds:[BuffDTA+DTATime]    ; áas poloëky
         mov       ModWFPol+FileTime,ax                ; áas poloëky
         mov       al,byte ptr ds:[BuffDTA+DTAAtrib]   ; atributy poloëky
         mov       ModWFPol+FileAtr,al                 ; atributy poloëky
         mov       ax,word ptr ds:[BuffDTA+DTASize]    ; velikost poloëky LOW
         mov       word ptr (ModWFPol+FileSize),ax     ; velikost poloëky LOW
         mov       ax,word ptr ds:[BuffDTA+DTASize+2]  ; velikost poloëky HIGH
         mov       word ptr (ModWFPol+FileSize+2),ax   ; velikost poloëky HIGH
         jmp       short ModWFil3

; ------ poloëka na disku nenalezena (je moënÇ, ëe bylo jen p©eru®en° Ctrl-Break)

ModWFil2:and       ModWFSwc,not bit2+bit4   ; z†kaz modifikace a vytvo©en° poloëky

ModWFil3:mov       al,ModWFSwc              ; zadanÇ parametry
         mov       ModWFSwU,al              ; £schova zadanòch parametrñ

; ------ aktualizace pro levò adres†©

         mov       ax,ds:[SegmLAdr]         ; levò adres†©
         call      ModW0Fil                 ; aktualizace poloëky

; ------ aktualizace pro pravò adres†©

         mov       ax,ds:[SegmRAdr]         ; pravò adres†©
         call      ModW0Fil                 ; aktualizace poloëky

; ------ aktualizace pro aktivn° okno

         mov       ax,ds:[SegmAkt]
         call      ModW0Fl1                 ; aktualizace poloëky

; ------ aktualizace pro neaktivn° okno

         mov       ax,ds:[SegmNAkt]
         call      ModW0Fl1                 ; aktualizace poloëky

; ------ okna pro vyhled†v†n°

         mov       dx,ds:[FileWNum]         ; poáet oken pro operaci
         or        dx,dx                    ; je otev©enÇ nàjakÇ okno ?
         jz        ModWFil9                 ; nen° ë†dnÇ okno
         mov       bx,offset FileWSeg       ; ukazatel oken
ModWFil8:mov       ax,ds:[bx]               ; uschovanÇ okno

         push      bx
         push      dx
         call      ModW0Fil                 ; aktualizace okna
         pop       dx
         pop       bx

         inc       bx                       ; zvò®en° adresy v definici oken
         inc       bx
         dec       dx                       ; á°taá oken
         jnz       ModWFil8                 ; bude dal®° okno

; ------ n†vrat registrñ

ModWFil9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ModWFile ENDP

; -----------------------------------------------------------------------------
;        modifikace okna AX (niá° v®echny registry kromà DS)
; -----------------------------------------------------------------------------
; ModWFPar   (1) pracovn° parametry
;                 bit 0: 1=poloëka nalezena na disku
;                 bit 1: 1=poloëka nalezena v seznamu
;                          pro strom - nalezena poloëka adres†©e
;                 bit 2: 1=je aktivn° adres†© okna
; ModWFSwc   (1) zadanÇ parametry operace
;                 bit 0: 1=aktualizace informac° o disku
;                 bit 1: 1=aktualizace informac° o adres†©i (novÇ naáten°)
;                 bit 2: 1=aktualizace parametrñ poloëky
;                 bit 3: 1=zru®en° poloëky, pokud je v oknà
;                 bit 4: 1=vytvo©en° poloëky, pokud nen° v oknà
;                 bit 5:
;                 bit 6: 1=jmÇno poloëky je za textem adres†©e (jako ASCIIZ)
;                 bit 7: 1=ovà©it poloëku z disku (naá°st parametry poloëky)
;                          (nuluj° se p©°padnÇ bity 2, 3 a 4, jsou-li nastaveny)
; ModWFSwU   (1) £schova zadanòch parametrñ operace
; ModWFTyp   (1) typ okna
;                 bit 3: 1=adres†©ovÇ okno
;                 bit 4: 1=okno stromu
;                 bit 5: 1=okno seznamu
; ModWFDel   (2) dÇlka textu adres†©e (bez jmÇna)
; ModWFAdr   (2) adresa textu adres†©e v z†sobn°ku
; ModWFTst   (2) á°slo testovanÇho okna
; ModWFSeg   (2) segment testovanÇho okna
; ModWFNPl   (2) á°slo nalezenÇ poloëky v oknà (pro strom poloëka adres†©e)
; ModWFAPl   (4) adresa nalezenÇ poloëky v oknà (pro strom poloëka adres†©e)
; ModWFSiz   (4) velikost nalezenÇ poloëky
; ModWFPol   (21) poloëka v intern°m tvaru
;  + FileAtr                                ; (1) atributy
;  + FileName                               ; (8) jmÇno
;  + FileExt                                ; (3) p©°pona
;  + FileSize                               ; (4) velikost
;  + FileDate                               ; (2) datum
;  + FileTime                               ; (2) áas
;  + FileATyp                               ; (1) typ
;  + FileLong                               ; (1+x) dlouhÇ jmÇno
; -----------------------------------------------------------------------------

ModW0Fil PROC      NEAR

; ------ z†kaz aktivn°ho a neaktivn°ho okna

         cmp       ax,ds:[SegmAkt]
         je        ModW0Fl0
         cmp       ax,ds:[SegmNAkt]
         jne       ModW0Fl1
ModW0Fl0:ret

; ------ adresa okna AX -> ES

ModW0Fl1:mov       ModWFTst,ax              ; á°slo testovanÇho okna
         call      far ptr GetDat           ; adresa okna AX -> ES
         jc        ModW0Fl0                 ; chyba - neplatnÇ okno
         mov       ModWFSeg,es              ; segment adresy okna

; ------ nulov†n° nepot©ebnòch atributñ vzoru poloëky

         and       byte ptr ModWFPol + FileAtr,not ATRO+ATRU ; nen° oznaáen°
         or        byte ptr ModWFPol + FileAtr,ATRT ; je to platn† poloëka
         and       ModWFPar,not bit1+bit2   ; nen° adres†©, poloëka nenalezena

; ------ £schova typu okna

         mov       al,ModWFSwU              ; uschovanÇ parametry
         mov       ModWFSwc,al              ; n†vrat parametrñ
         mov       al,es:[AWinPrm1]         ; typ okna
         mov       ModWFTyp,al              ; £schova typu okna

; ------ porovn†n° disku

         mov       si,ModWFAdr              ; adresa cesty v z†sobn°ku
         mov       al,ss:[si]               ; oznaáen° disku
         cmp       al,es:[AWinDir]          ; souhlas° disk ?
         jne       ModW0Fl0                 ; disk nesouhlas°
         test      ModWFSwc,bit0            ; aktualizuj° se informace o disku ?
         jz        ModW0Fl2                 ; neaktualizuj° se
         and       byte ptr es:[AWinPrm0],not bit2 ; informace o disku nezn†mÇ

; ------ test, zda to je aktivn° adres†© okna

ModW0Fl2:mov       cx,ModWFDel              ; dÇlka textu adres†©e
         cmp       cx,es:[AWinDNum]         ; souhlas° dÇlka textu adres†©e ?
         jne       ModW0Fl3                 ; adres†© nesouhlas°
         cld
         mov       di,AWinDir               ; adres†© okna
         repe      cmps byte ptr ss:[si],es:[di] ; porovn†n° adres†©ñ
         jne       ModW0Fl3                 ; adres†©e nesouhlas°
         or        ModWFPar,bit2            ; je to aktivn° adres†© okna
         test      ModWFSwc,bit1            ; aktualizuj° se informace o adres†©i ?
         jz        ModW0Fl3                 ; neaktualizuj° se
         and       byte ptr es:[AWinPrm1],not bit1 ; adres†© nenaáten

; ------ aktualizace adres†©e v oknà stromu

ModW0Fl3:test      ModWFTyp,bit4            ; je to strom ?
         jz        ModW0Fl4                 ; nen° to strom
         and       byte ptr es:[AWinPrm1],not bit1 ; strom nenaáten
         mov       ax,ModWFTst              ; á°slo okna
         push      ss
         pop       es                       ; ES <- segment cesty
         mov       si,ModWFAdr              ; adresa cesty v z†sobn°ku
         call      far ptr SrcPathT         ; nalezen° cesty ve stromu
         call      far ptr GetPol           ; adresa poloëky BX -> ES:SI
         jc        ModW0F36                 ; poloëka nenalezena
         and       byte ptr es:[si+FileTPar],not bit0 ; adres†© nen° ovà©en
ModW0F36:ret

; ------ nalezen° poloëky v oknà (jen pro adres†©ovÇ okno)

ModW0Fl4:test      ModWFTyp,bit3            ; je to adres†©ovÇ okno ?
         jz        ModW0F36                 ; nen° to adres†©ovÇ okno
         push      es
         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         lea       si,ModWFPol              ; hledan† poloëka
         mov       ax,ModWFTst              ; á°slo okna
         call      far ptr SrcWNam          ; nalezen° poloëky v oknà
         jc        ModW0Fl5                 ; poloëka nenalezena

         or        ModWFPar,bit1            ; p©°znak nalezen° poloëky
         mov       ModWFNPl,bx              ; á°slo nalezenÇ poloëky v oknà
         call      far ptr GetPol           ; adresa poloëky BX -> ES:SI
         mov       ModWFAPl,si              ; adresa poloëky - offset
         mov       ModWFAPl+2,es            ; adresa poloëky - segment
         mov       ax,word ptr es:[si+FileSize] ; velikost poloëky LOW
         mov       ModWFSiz,ax              ; velikost poloëky LOW
         mov       ax,word ptr es:[si+FileSize+2] ; velikost poloëky HIGH
         mov       ModWFSiz+2,ax            ; velikost poloëky HIGH
         mov       al,es:[si+FileAtr]       ; atributy poloëky
         and       al,ATRO+ATRU             ; ponech† atributy oznaáen°
         or        byte ptr ModWFPol + FileAtr,al ; £schova atributñ
ModW0Fl5:pop       es

; ------ vytvo©en° poloëky

ModW0Fl6:test      ModWFSwc,bit4            ; vytvo©en° poloëky ?
         jz        ModW0Fl7                 ; nen° vytvo©en° poloëky
         test      ModWFPar,bit2            ; je adres†© s poloëkou ?
         jz        ModW0F62                 ; nen° adres†© s poloëkou
         test      ModWFPar,bit1            ; existuje poloëka ?
         jnz       ModW0F62                 ; poloëka jië existuje
         call      ModW0Ins                 ; vytvo©en° novÇ poloëky
         jmp       short ModW0Fl9

; ------ vytvo©en° poloëky, je-li adres†© s existuj°c° poloëkou

ModW0F62:call      ModW0Add                 ; p©iáten° novÇ velikosti poloëky
         jmp       short ModW0Fl9

; ------ aktualizace parametrñ poloëky

ModW0Fl7:test      ModWFSwc,bit2            ; aktualizace parametrñ poloëky ?
         jz        ModW0Fl8                 ; nen° aktualizace parametrñ
         test      ModWFPar,bit2            ; je adres†© s poloëkou ?
         jz        ModW0F72                 ; nen° adres†© s poloëkou
         test      ModWFPar,bit1            ; existuje poloëka ?
         jz        ModW0F72                 ; poloëka neexistuje
         call      ModW0Akt                 ; aktualizace parametrñ poloëky
         jmp       short ModW0Fl9           ; teÉ by se jië nemàlo dàlat ru®en°

; ------ oprava velikosti poloëky, nen°-li adres†© s poloëkou

ModW0F72:call      ModW0Sub                 ; odeáten° starÇ velikosti poloëky
         jmp       short ModW0F62           ; p©iáten° novÇ velikosti poloëky

; ------ zru®en° poloëky, nen°-li adres†© s poloëkou

ModW0F74:call      ModW0Sub                 ; odeáten° starÇ velikosti poloëky
         jmp       short ModW0Fl9

; ------ zru®en° poloëky

ModW0Fl8:test      ModWFSwc,bit3            ; ru®° se poloëka ?
         jz        ModW0Fl9                 ; poloëka se neru®°
         test      ModWFPar,bit2            ; je adres†© s poloëkou ?
         jz        ModW0F74                 ; nen° adres†© s poloëkou
         test      ModWFPar,bit1            ; existuje poloëka ?
         jz        ModW0F74                 ; poloëka neexistuje
         call      ModW0Del                 ; zru®en° poloëky z okna

ModW0Fl9:ret

ModW0Fil ENDP

; -----------------------------------------------------------------------------
;        vytvo©en° novÇ poloëky (m†lo pamàti nevad° - jen se poloëka nevytvo©°)
; -----------------------------------------------------------------------------

ModW0Ins PROC      NEAR

; ------ vytvo©en° m°sta k vloëen° poloëky

         mov       es,ModWFSeg              ; ES <- adresa okna
         or        byte ptr es:[AWinPrm0],bit4 ; je pot©eba zobrazit okno
         mov       di,word ptr es:[AWinSouI] ; offset konce poloëek
         mov       dx,word ptr es:[AWinSouI+2] ; segment konce poloëek
         mov       cx,FileSumm+1            ; velikost poloëky LOW
         xor       bx,bx                    ; velikost poloëky HIGH
         mov       ax,ModWFTst              ; á°slo okna
         call      far ptr InsSDat          ; vytvo©en° m°sta k vloëen° poloëky
         jnc       ModW0In2                 ; m°sto vytvo©eno OK
         ret

; ------ p©enesen° poloëky

ModW0In2:push      di
         push      es
         mov       ax,es                    ; AX <- segment okna
         add       ax,dx                    ; AX <- segment poloëky
         mov       es,ax                    ; ES <- segment poloëky
         mov       ModWFAPl,di              ; adresa poloëky - offset
         mov       ModWFAPl+2,ax            ; adresa poloëky - segment
         lea       si,ModWFPol              ; p©ipraven† poloëka
         cld
         push      di
         rep       movs byte ptr es:[di],ss:[si] ; p©enos poloëky
         mov       byte ptr es:[di-1],0     ; nen° dlouhÇ jmÇno
         pop       si                       ; SI <- adresa poloëky
         call      StorFTyp                 ; nastaven° typu poloëky
         pop       es
         pop       di

; ------ posun ukazatelñ

         inc       word ptr es:[AWinSouR]   ; zvò®en° poátu souborñ
         add       word ptr es:[AWinSouI],FileSumm+1 ; indexov† tabulka souborñ
         add       word ptr es:[AWinKomI],FileSumm+1 ; indexov† tabulka koment†©ñ
         push      cs
         call      near ptr NormIAWn        ; normalizace ukazatelñ tabulek

; ------ poloëka se uloë° na konec seznamu

         mov       bx,es:[AWinSouN]
         mov       ModWFNPl,bx              ; á°slo poloëky v oknà

; ------ adresa indexu poloëky -> DX:DI

         mov       es,ModWFSeg              ; ES <- adresa okna
         mov       di,ModWFNPl              ; á°slo nalezenÇ poloëky v oknà
         shl       di,1                     ; index * 2
         add       di,ModWFNPl              ; index * 3
         add       di,word ptr es:[AWinSouI] ; p©iáten° offsetu poloëky
         mov       dx,word ptr es:[AWinSouI+2] ; segment relativnà

; ------ vytvo©en° indexu poloëky

         mov       cx,3                     ; poáet vytvo©enòch bajtñ LOW
         xor       bx,bx                    ; poáet vytvo©enòch bajtñ HIGH
         mov       ax,ModWFTst              ; á°slo okna
         call      far ptr InsSDat          ; vytvo©en° indexu poloëky
         jnc       ModW0In5                 ; poloëka vytvo©ena OK

; ------ p©i chybà zru®en° poloëky

ModW0In4:dec       word ptr es:[AWinSouR]   ; sn°ëen° poátu poloëek v oknà
         add       byte ptr es:[AWinSouI],80h-FileSumm-1 ; oprava adresy
         sub       word ptr es:[AWinSouI+2],80h/16
         add       byte ptr es:[AWinKomI],80h-FileSumm-1
         sub       word ptr es:[AWinKomI+2],80h/16
         push      cs
         call      near ptr NormIAWn        ; normalizace ukazatelñ tabulek

         mov       di,word ptr es:[AWinSouI] ; offset konce poloëek
         mov       dx,word ptr es:[AWinSouI+2] ; segment konce poloëek
         mov       cx,FileSumm+1            ; velikost poloëky LOW
         xor       bx,bx                    ; velikost poloëky HIGH
         mov       ax,ModWFTst              ; á°slo okna
         call      far ptr DelSDat          ; zru®en° poloëky
         ret

; ------ oprava ukazatelñ (ES=adresa okna)

ModW0In5:inc       word ptr es:[AWinSouN]   ; zvò®en° poátu zobrazenòch poloëek
         add       byte ptr es:[AWinKomI],3 ; zvò®en° adresy koment†©ñ
         call      far ptr NormIAWn         ; normalizace ukazatelñ

; ------ uloëen° adresy poloëky

         add       dx,ModWFSeg              ; segment adresy poloëky
         mov       es,dx                    ; ES <- segment adresy poloëky
         mov       ax,ModWFAPl              ; adresa poloëky - offset
         mov       es:[di],al               ; adresa poloëky - offset
         mov       ax,ModWFAPl+2            ; adresa poloëky - segment
         sub       ax,ModWFSeg              ; segment poloëky relativnà
         mov       es:[di+1],ax             ; segment adresy poloëky

; ------ adresa indexu koment†©e (je ES=adresa okna)

         mov       es,ModWFSeg              ; segment okna
         mov       di,ModWFNPl              ; DI <- á°slo poloëky
         shl       di,1                     ; index * 2
         add       di,word ptr es:[AWinKomI] ; p©iáten° offsetu poloëky
         mov       dx,word ptr es:[AWinKomI+2] ; segment relativnà

; ------ vytvo©en° indexu koment†©e

         mov       cx,2                     ; poáet vkl†danòch bajtñ LOW
         xor       bx,bx                    ; poáet vkl†danòch bajtñ HIGH
         mov       ax,ModWFTst              ; á°slo segmentu okna
         call      far ptr InsSDat          ; vytvo©en° indexu
         jnc       ModW0In6                 ; index vytvo©en OK

; ------ p©i chybà zru®en° indexu k zobrazen° (CH=0, AX=á°slo/ES=adresa okna)

         dec       word ptr es:[AWinSouN]   ; sn°ëen° poátu poloëek
         add       byte ptr es:[AWinKomI],80h-3 ; oprava tabulky koment†©ñ
         sub       word ptr es:[AWinKomI+2],80h/16
         push      cs
         call      near ptr NormIAWn        ; normalizace ukazatelñ tabulek

         mov       di,ModWFNPl              ; á°slo nalezenÇ poloëky v oknà
         shl       di,1                     ; index * 2
         add       di,ModWFNPl              ; index * 3
         add       di,word ptr es:[AWinSouI] ; p©iáten° offsetu poloëky
         mov       dx,word ptr es:[AWinSouI+2] ; segment relativnà

         mov       cl,3                     ; poáet ru®enòch bajtñ LOW
         xor       bx,bx                    ; poáet ru®enòch bajtñ HIGH
         call      far ptr DelSDat          ; zru®en° indexu poloëky
         jmp       ModW0In4                 ; zru®en° poloëky

; ------ nulov†n° indexu koment†©e

ModW0In6:add       dx,ModWFSeg              ; segment adresy poloëky
         mov       es,dx                    ; ES <- segment adresy poloëky
         mov       word ptr es:[di],0       ; vynulov†n° indexu koment†©e

; ------ oprava velikosti souboru v evidenci

         call      ModW0Add                 ; p©iáten° novÇ velikosti souboru

; ------ novÇ set©°dàn° adres†©e (kurzor se p©i t©°dàn° uchov† na poloëce)

         mov       ax,ModWFTst
         call      far ptr SortDir          ; set©°dàn° okna
         ret

ModW0Ins ENDP

; -----------------------------------------------------------------------------
;        aktualizace parametrñ poloëky
; -----------------------------------------------------------------------------

ModW0Akt PROC      NEAR

; ------ £schova registrñ

         push      ds

; ------ adresa vzorovÇ (-> DS:SI) a c°lovÇ (-> ES:DI) poloëky

         les       di,dword ptr ModWFAPl    ; adresa poloëky v oknà
         lea       si,ModWFPol              ; novÇ parametry poloëky
         push      ss
         pop       ds                       ; DS <- segment vzoru poloëky

; ------ atributy, velikost, datum a áas poloëky

         cld
         movsb                              ; p©enos atributñ poloëky
         add       di,FileSize-1            ; poloëka velikosti
         add       si,FileSize-1
         mov       cx,2 + 1 + 1             ; poáet slov k p©enosu
         rep       movsw                    ; velikost, datum a áas

; ------ n†vrat registrñ

         pop       ds

; ------ oprava velikosti souboru v evidenci

         call      ModW0Sub                 ; odeáten° pñvodn° velikosti souboru
         call      ModW0Add                 ; p©iáten° novÇ velikosti souboru
         ret

ModW0Akt ENDP

; -----------------------------------------------------------------------------
;        zru®en° poloëky z okna
; -----------------------------------------------------------------------------

ModW0Del PROC      NEAR

; ------ oprava velikosti souboru v evidenci

         call      ModW0Sub                 ; odeáten° pñvodn° velikosti souboru

; ------ zru®en° poloëky souboru ze seznamu

         mov       di,ModWFAPl              ; adresa poloëky - offset
         mov       es,ModWFAPl+2            ; adresa poloëky - segment
         mov       cx,FileSumm+1            ; velikost poloëky LOW
         add       cl,es:[di+FileLong]      ; p©iáten° dlouhÇho jmÇna
         adc       ch,0
         mov       dx,ModWFAPl+2            ; adresa poloëky - segment
         sub       dx,ModWFSeg              ; segment adresy relativnà
         xor       bx,bx                    ; velikost poloëky HIGH
         mov       ax,ModWFTst              ; á°slo okna
         call      far ptr DelSDat          ; zru®en° poloëky

; ------ oprava ukazatelñ

         mov       es,ModWFSeg              ; ES <- adresa okna
         or        byte ptr es:[AWinPrm0],bit4 ; je pot©eba zobrazit okno
         dec       word ptr es:[AWinSouR]   ; sn°ëen° poátu naátenòch poloëek
         add       byte ptr es:[AWinSouI],80h ; sn°ëen° adresy indexñ
         sub       word ptr es:[AWinSouI],cx
         sub       word ptr es:[AWinSouI+2],80h/16
         add       byte ptr es:[AWinKomI],80h ; sn°ëen° adresy koment†©ñ
         sub       word ptr es:[AWinKomI],cx
         sub       word ptr es:[AWinKomI+2],80h/16
         call      far ptr NormIAWn         ; normalizace ukazatelñ

; ------ oprava adres v indexovÇ tabulce (plat°, ëe je alespo§ 1 poloëka !)

         neg       cx                       ; CX <- -posun
         add       cx,80h                   ; CX = 80h-ru®en† data
         mov       bx,es:[AWinSouN]         ; poáet poloëek v tabulce
         mov       si,word ptr es:[AWinSouI] ; offset adresy indexovÇ tabulky
         mov       ax,es
         add       ax,word ptr es:[AWinSouI+2] ; segment adresy indexovÇ tabulky
         mov       es,ax                    ; ES <- segment adresy indexovÇ tabulky
ModW0Dl2:cmp       es:[si+1],dx             ; je poloëka za ru®enou ?
         jbe       ModW0Dl3                 ; poloëka je p©ed ru®enou
         add       es:[si],cl               ; posun offsetu
         mov       al,es:[si]               ; offset poloëky
         and       byte ptr es:[si],0fh     ; normalizace offsetu
         mov       ah,0
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©evod na offset
         sub       ax,80h/16                ; oprava offsetu
         add       es:[si+1],ax             ; oprava segmentu
ModW0Dl3:add       si,3                     ; adresa dal®°ho indexu
         dec       bx                       ; á°taá poloëek
         jnz       ModW0Dl2                 ; dal®° poloëka

; ------ adresa indexu poloëky -> DX:DI

         mov       es,ModWFSeg              ; ES <- adresa okna
         mov       di,ModWFNPl              ; á°slo nalezenÇ poloëky v oknà
         shl       di,1                     ; index * 2
         add       di,ModWFNPl              ; index * 3
         add       di,word ptr es:[AWinSouI] ; p©iáten° offsetu poloëky
         mov       dx,word ptr es:[AWinSouI+2] ; segment relativnà

; ------ zru®en° indexu poloëky

         mov       cx,3                     ; poáet ru®enòch bajtñ LOW
         xor       bx,bx                    ; poáet ru®enòch bajtñ HIGH
         mov       ax,ModWFTst              ; á°slo okna
         call      far ptr DelSDat          ; zru®en° indexu poloëky

; ------ oprava ukazatelñ (ES=adresa okna)

         dec       word ptr es:[AWinSouN]   ; sn°ëen° poátu zobrazenòch poloëek
         add       byte ptr es:[AWinKomI],80h-3 ; sn°ëen° adresy koment†©ñ
         sub       word ptr es:[AWinKomI+2],80h/16
         call      far ptr NormIAWn         ; normalizace ukazatelñ

; ------ adresa indexu koment†©e (je ES=adresa okna)

         mov       di,ModWFNPl              ; DI <- á°slo poloëky
         shl       di,1                     ; index * 2
         add       di,word ptr es:[AWinKomI] ; p©iáten° offsetu poloëky
         mov       dx,word ptr es:[AWinKomI+2] ; segment relativnà

; ------ zru®en° indexu koment†©e (je CH=0, AX=á°slo okna)

         mov       cl,2                     ; poáet ru®enòch bajtñ LOW
         xor       bx,bx                    ; poáet ru®enòch bajtñ HIGH
         call      far ptr DelSDat          ; zru®en° indexu

; ------ oprava kurzoru (AX=á°slo okna, ES=adresa okna)

         mov       bx,ModWFNPl              ; BX <- á°slo poloëky
         cmp       bx,es:[AWinKurz]         ; je to kurzor ?
         ja        ModW0Dl9                 ; je za kurzorem - nic
         jb        ModW0Dl8                 ; je p©ed kurzorem - posune se
         cmp       ax,ds:[SegmAkt]          ; je to aktivn° okno ?
         jne       ModW0Dl7                 ; nen° to aktivn° okno
         or        byte ptr ds:[FileParm],bit7 ; kurzor zru®en
ModW0Dl7:mov       ax,es:[AWinKurz]         ; kurzor
         cmp       ax,es:[AWinSouN]         ; je za koncem ?
         jb        ModW0Dl9                 ; nen° za koncem
         or        ax,ax                    ; je nàjak† poloëka ?
         jz        ModW0Dl9                 ; nen° ë†dn† poloëka

ModW0Dl8:dec       word ptr es:[AWinKurz]   ; oprava kurzoru
         cmp       word ptr es:[AWinFrst],0 ; je poá†tek ?
         je        ModW0Dl9                 ; je poá†tek
         dec       word ptr es:[AWinFrst]   ; oprava poá†tku

ModW0Dl9:ret

ModW0Del ENDP

; -----------------------------------------------------------------------------
;        odeáten° pñvodn° velikosti poloëky (neuchov†v† registry !)
; -----------------------------------------------------------------------------

ModW0Sub PROC      NEAR

; ------ adresa okna -> ES, velikost poloëky -> DX:AX

         mov       es,ModWFSeg              ; ES <- adresa okna
         or        byte ptr es:[AWinPrm0],bit4 ; je pot©eba zobrazit okno
         mov       ax,ModWFSiz              ; pñvodn° velikost poloëky LOW
         mov       dx,ModWFSiz+2            ; pñvodn° velikost poloëky HIGH

; ------ sn°ëen° velikosti oznaáenòch souborñ

         test      ModWFPar,bit2            ; je adres†© s poloëkou ?
         jz        ModW0Sb2                 ; nen° adres†© s poloëkou
         test      byte ptr ModWFPol+FileAtr,ATRO ; je poloëka oznaáena ?
         jz        ModW0Sb2                 ; poloëka nebyla oznaáena
         sub       word ptr es:[AWinSSum],ax ; odeáten° velikosti poloëky
         sbb       word ptr es:[AWinSSum+2],dx
         dec       word ptr es:[AWinSNum]   ; sn°ëen° poátu souborñ

; ------ oprava ukazatelñ p©i zru®en° adres†©e

ModW0Sb2:test      byte ptr ModWFPol+FileAtr,DIR ; je to adres†© ?
         jz        ModW0Sb4                 ; nen° to adres†©
         mov       ax,es:[AWinAlok]         ; velikost jednoho alokaán°ho bloku
         xor       dx,dx                    ; DX <- 0
         jmp       short ModW0Sb6           ; adres†© zabere asi tak 1 blok

; ------ oprava obsazenÇho m°sta souborem

ModW0Sb4:push      cs
         call      near ptr KSizBlok        ; zarovn†n° velikosti na bloky
         test      ModWFPar,bit2            ; je adres†© s poloëkou ?
         jz        ModW0Sb6                 ; nen° adres†© s poloëkou
         sub       word ptr es:[AWinDSum],ax ; odeáten° pñvodn° velikosti
         sbb       word ptr es:[AWinDSum+2],dx
         dec       word ptr es:[AWinDFil]   ; sn°ëen° poátu souborñ

; ------ oprava volnÇho m°sta disku

ModW0Sb6:add       word ptr es:[AWinDFre],ax ; n†vrat volnÇ kapacity disku
         adc       word ptr es:[AWinDFre+2],dx
         ret

ModW0Sub ENDP

; -----------------------------------------------------------------------------
;        p©iáten° novÇ velikosti poloëky (neuchov†v† registry !)
; -----------------------------------------------------------------------------

ModW0Add PROC      NEAR

; ------ adresa okna -> ES, velikost poloëky -> DX:AX

         mov       es,ModWFSeg              ; ES <- adresa okna
         or        byte ptr es:[AWinPrm0],bit4 ; je pot©eba zobrazit okno
         mov       ax,word ptr (ModWFPol+FileSize) ; nov† velikost poloëky LOW
         mov       dx,word ptr (ModWFPol+FileSize+2) ; nov† velikost poloëky HIGH

; ------ oprava velikosti oznaáenòch souborñ

         test      ModWFPar,bit2            ; je adres†© s poloëkou ?
         jz        ModW0Ad2                 ; nen° adres†© s poloëkou
         test      byte ptr ModWFPol+FileAtr,ATRO ; je poloëka oznaáena ?
         jz        ModW0Ad2                 ; poloëka nebyla oznaáena
         add       word ptr es:[AWinSSum],ax ; p©iáten° novÇ velikosti poloëky
         adc       word ptr es:[AWinSSum+2],dx
         inc       word ptr es:[AWinSNum]   ; zvò®en° poátu souborñ

; ------ oprava ukazatelñ p©i vytvo©en° adres†©e

ModW0Ad2:test      byte ptr ModWFPol+FileAtr,DIR ; je to adres†© ?
         jz        ModW0Ad4                 ; nen° to adres†©
         mov       ax,es:[AWinAlok]         ; velikost jednoho alokaán°ho bloku
         xor       dx,dx                    ; DX <- 0
         jmp       short ModW0Ad6           ; adres†© zabere asi tak 1 blok

; ------ oprava obsazenÇho m°sta souborem

ModW0Ad4:push      cs
         call      near ptr KSizBlok        ; zarovn†n° velikosti na bloky
         test      ModWFPar,bit2            ; je adres†© s poloëkou ?
         jz        ModW0Ad6                 ; nen° adres†© s poloëkou
         add       word ptr es:[AWinDSum],ax ; p©iáten° novÇ velikosti
         adc       word ptr es:[AWinDSum+2],dx
         inc       word ptr es:[AWinDFil]   ; zvò®en° poátu souborñ

; ------ oprava volnÇho m°sta disku

ModW0Ad6:sub       word ptr es:[AWinDFre],ax ; odeáten° od volnÇho m°sta disku
         sbb       word ptr es:[AWinDFre+2],dx
         jnc       ModW0Ad8                 ; nen° podteáen°
         xor       ax,ax
         mov       word ptr es:[AWinDFre],ax ; oprava p©i podteáen° na 0
         mov       word ptr es:[AWinDFre+2],ax
ModW0Ad8:ret

ModW0Add ENDP

; -----------------------------------------------------------------------------
;        zarovn†n° velikosti na bloky
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=velikost v bajtech
;        ES=segment okna
; VùSTUP: DX:AX=velikost zarovnan† na alokaán° bloky
; -----------------------------------------------------------------------------

KSizBlok PROC      FAR

         push      cx

         mov       cx,es:[AWinAlok]         ; velikost alokaán°ho bloku
         test      byte ptr es:[AWinPrm0],bit6 ; je to CD-ROM ?
         jz        KSizBlk1                 ; nen° CD-ROM
         mov       cx,2048                  ; n†hradn° velikost sektoru

KSizBlk1:dec       cx                       ; velikost bloku - 1
         add       ax,cx                    ; zaokrouhlen° nahoru
         adc       dx,0
         inc       cx                       ; n†vrat velikosti bloku
         cmp       dx,cx                    ; bylo by p©eteáen° ?
         jae       KSizBlk2                 ; bylo by p©eteáen°
         div       cx                       ; p©epoáet na bloky
         mul       cx                       ; p©epoáet na zabranou kapacitu

KSizBlk2:pop       cx
         ret

KSizBlok ENDP

; -----------------------------------------------------------------------------
;                                StorFile
;           Za©azen° nalezenÇho souboru do seznamu adres†©ovÇho okna
;        IndexovÇ tabulky mus° bòt odsunuty (mus° bòt vytvo©eno m°sto),
;               ukazatele tabulek ale ne - ukazatele odsune
; -----------------------------------------------------------------------------
; VSTUP: DX:SI=buffer DTA s nalezenòm souborem - zaá†tek dat (poloëka DTAAtrib)
;        ES=segment okna
;        DS=datovò segment
; -----------------------------------------------------------------------------

StorFile PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es
         mov       bp,ds                    ; BP <- datovò segment

; ------ posun ukazatelñ

         inc       word ptr es:[AWinSouR]   ; zvò®en° á°taáe naátenòch souborñ

; ------ £schova aktu†ln° adresy k uloëen° poloëky -> AX:DI

         mov       di,word ptr es:[AWinSouI]         ; indexov† tabulka poloëek = offset
         mov       ax,es                    ; segment okna
         add       ax,word ptr es:[AWinSouI+2]       ; segment ukl†dac° adresy

; ------ posun indexovòch tabulek

         mov       cx,ds:[DTALNamN]         ; dÇlka dlouhÇho jmÇna
         add       word ptr es:[AWinSouI],FileSumm+1 ; indexov† tabulka souborñ
         add       word ptr es:[AWinSouI],cx

         add       word ptr es:[AWinKomI],FileSumm+1 ; indexov† tabulka koment†©ñ
         add       word ptr es:[AWinKomI],cx
         push      cs
         call      near ptr NormIAWn        ; normalizace ukazatelñ tabulek

; ------ p©°prava registrñ

         mov       es,ax                    ; ES <- segment ukl†dac° adresy
         mov       ds,dx                    ; DS <- segment poloëky DTA
         cld                                ; smàr nahoru

; ------ uloëen° parametrñ souboru (nenulovat atributy ATRU a ATRO !)

         mov       dx,si                    ; DX <- £schova zaá†tku DTA
         mov       bx,di                    ; BX <- £schova adresy poloëky
         lodsb                              ; atributy souboru
         or        al,ATRT                  ; p©°znak platnÇ poloëky
         stosb                              ; atributy souboru
         lodsw                              ; áas souboru
         mov       es:[di+FileTime-1],ax    ; áas souboru
         lodsw                              ; datum souboru
         mov       es:[di+FileDate-1],ax    ; datum souboru
         lodsw                              ; velikost souboru - LOW
         mov       word ptr es:[di+FileSize-1],ax ; velikost souboru - LOW
         lodsw                              ; velikost souboru - HIGH
         mov       word ptr es:[di+FileSize+2-1],ax ; velikost souboru - HIGH

; ------ inicializace jmÇna a p©°pony na mezery

         push      di                       ; £schova zaá†tku poloëky souboru
         mov       cx,11                    ; poáet znakñ jmÇna a p©°pony
         mov       al," "                   ; inicializaán° mezera
         rep       stosb                    ; inicializace jmÇna s p©°ponou
         pop       di                       ; jmÇno souboru s p©°ponou

; ------ uloëen° speci†ln° poloëky - ".."

         cmp       word ptr ds:[si],".."    ; je adres†© ".." ?
         je        StorFil5                 ; je adres†© ".." - uloëen°

; ------ uloëen° jmÇna souboru (po oddàlovac° teáku nebo koncovou 0)

         mov       cl,8                     ; max. poáet znakñ jmÇna souboru
         push      di                       ; zaá†tek jmÇna souboru
StorFil1:lodsb                              ; naáten° znaku
         cmp       al,0                     ; konec jmÇna s p©°ponou ?
         je        StorFil2                 ; konec jmÇna souboru
         cmp       al,"."                   ; oddàlovac° teáka
         je        StorFil3                 ; oddàlovac° teáka - bude p©°pona
         jcxz      StorFil1                 ; p©ekroáen poáet znakñ - dal®° znak
         stosb                              ; uloëen° znaku jmÇna souboru
         dec       cx                       ; sn°ëen° á°taáe zbylòch znakñ
         jmp       short StorFil1           ; p©enos dal®°ho znaku
StorFil2:dec       si                       ; n†vrat adresy koncovÇ 0
StorFil3:pop       di                       ; n†vrat zaá†tku jmÇna souboru

; ------ uloëen° p©°pony souboru

         add       di,8                     ; p©°pona souboru
StorFil5:mov       cl,3                     ; max. poáet znakñ p©°pony souboru
StorFil6:lodsb                              ; naáten° znaku
         cmp       al,0                     ; konec jmÇna souboru ?
         je        StorFil7                 ; konec jmÇna souboru
         stosb                              ; uloëen° znaku jmÇna souboru
         loop      StorFil6                 ; p©enos dal®°ho znaku

; ------ detekce typu poloëky

StorFil7:mov       si,bx                    ; SI <- adresa poloëky
         mov       ds,bp                    ; DS <- datovò segment
         call      StorFTyp                 ; uloëen° typu poloëky ES:SI

; ------ p©enesen° dlouhÇho jmÇna souboru

         mov       di,bx
         mov       si,offset DTALName       ; dlouhÇ jmÇno
         mov       cx,ds:[DTALNamN]         ; dÇlka dlouhÇho jmÇna
         add       di,FileLong+1            ; zaá†tek bufferu
         cld
         mov       es:[di-1],cl             ; dÇlka dlouhÇho jmÇna
         rep       movsb

; ------ n†vrat registrñ

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

StorFile ENDP

; -----------------------------------------------------------------------------
;                                 StorFTyp
;                            uloëen° typu poloëky
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=nalezen† poloëka
;        DS=datovò segment
; niá° registry AX, CX, DX a DI !
; -----------------------------------------------------------------------------

StorFTyp PROC      NEAR

         push      ds

; ------ poloëka ".."

         mov       al,FileATSb              ; p©°znak ".."
         cmp       word ptr es:[si+FileName],".." ; jmÇno souboru
         je        StorFTp8                 ; je ".."

; ------ poloëka adres†©e

         inc       ax                       ; adres†©
         test      byte ptr es:[si+FileAtr],DIR ; je to adres†© ?
         jnz       StorFTp8                 ; je to adres†©

; ------ poloëka HID/SYS

         inc       ax                       ; HID/SYS
         test      byte ptr es:[si+FileAtr],HID+SYS ; je to HID/SYS ?
         jnz       StorFTp8                 ; je to HID/SYS

; ------ poloëka programu

         inc       ax                       ; program
         call      far ptr TestProg         ; je to program ?
         je        StorFTp8                 ; je to program

; ------ adresa definice skupin souborñ -> DS

         mov       ax,ds:[SegmFGrp]         ; segment skupin souborñ
         call      far ptr GetSgAdr         ; adresa segmentu skupin
         mov       ds,dx                    ; DS <- segment skupin
         mov       di,2+1                   ; ukazatel dat v bufferu + 1

; ------ p©°prava k vyhled†n° p©°pony v tabulce

         mov       cx,ds:[di-3]             ; velikost dat v segmentu
         shr       cx,1
         shr       cx,1                     ; poáet p©°pon v segmentu
         jcxz      StorFTp7                 ; nen° ë†dn† p©°pona
         mov       dx,word ptr es:[si+FileExt+1]     ; 2. a 3. znak p©°pony
         mov       ah,es:[si+FileExt]       ; 1. znak p©°pony

; ------ porovn†n° prvn°ho znaku p©°pony (AH)

StorFTp3:cmp       byte ptr ds:[di],"?"     ; je 1. znak n†hradn° "?" ?
         je        StorFTp4                 ; 1. znak se shoduje OK
         cmp       ah,ds:[di]               ; shoduje se 1. znak ?
         jne       StorFTp6                 ; 1. znak se neshoduje

; ------ porovn†n° druhÇho znaku p©°pony (DL)

StorFTp4:cmp       byte ptr ds:[di+1],"?"   ; je 2. znak n†hradn° "?" ?
         je        StorFTp5                 ; 2. znak se shoduje OK
         cmp       dl,ds:[di+1]             ; shoduje se 2. znak ?
         jne       StorFTp6                 ; 2. znak se neshoduje

; ------ porovn†n° t©et°ho znaku p©°pony (DH)

StorFTp5:mov       al,ds:[di-1]             ; á°slo skupiny p©°pony
         cmp       byte ptr ds:[di+2],"?"   ; je 3. znak n†hradn° "?" ?
         je        StorFTp8                 ; 3. znak se shoduje OK
         cmp       dh,ds:[di+2]             ; shoduje se 3. znak ?
         je        StorFTp8                 ; 3. znak se shoduje OK

; ------ p©°prava k testu dal®° p©°pony

StorFTp6:add       di,4                     ; dal®° p©°pona
         loop      StorFTp3                 ; test dal®° p©°pony

; ------ nastaven° typu poloëky AL

StorFTp7:mov       al,FileATNo              ; jinak ostatn° poloëka
StorFTp8:mov       es:[si+FileATyp],al      ; typ poloëky

         pop       ds
         ret

StorFTyp ENDP

CodeWin  ENDS

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                                 Data
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
Data     SEGMENT

; -----------------------------------------------------------------------------
;        chybovÇ hl†®en° - m†lo pamàti pro naáten° adres†©e
; -----------------------------------------------------------------------------

ChybRDir label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        ChbRDirP                 ; zaá†tek definice poloëek menu
         dw        ChbLnMeH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@MaximalniPocetSouboru ; á°slo str†nky velkÇ n†povàdy
         dw        ChbRDirB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        ChbLnMeT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        51                       ; ®°©ka okna
         db        9                        ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; historie specifikac° souborñ
         db        0                        ; poáet p©edvoleb

ChbRDirP db        bit6,19,'Nedostatek pamàti !'
         db        bit6,39,'Z adres†©e naáteno jen ',0,1
         dw        ChbRDirC
         db        0,' poloëek...'
         db        bit6,0
         db        bit6+bit7,0
         db        2,7,' Konec '

ChbRDirC db        1,'      '

ChbRDirB db        0                        ; blokovac° tabulka

; -----------------------------------------------------------------------------
;        chybovÇ hl†®en° - chyba z†pisu do informaán°ho souboru
; -----------------------------------------------------------------------------

ChybZInf label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        ChbZInfP                 ; zaá†tek definice poloëek menu
         dw        ChbLnMeH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@KomentareSouboru     ; á°slo str†nky velkÇ n†povàdy
         dw        ChbZInfB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        ChbZInfT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        44                       ; ®°©ka okna
         db        9                        ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; historie specifikac° souborñ
         db        0                        ; poáet p©edvoleb

ChbZInfP db        bit6,6,0,'CHYBA'
         db        bit6,28,'Chyba z†pisu do informaán°ho'
         db        bit6,18,'souboru FILEINFO !'
         db        bit6+bit7,0
         db        2,7,' Konec '

ChbZInfT db        12,'chyba z†pisu'

ChbZInfB db        0                        ; blokovac° tabulka

; ------ tabulka SCAN k¢dñ znakñ p©i rychlovyhled†v†n°

TabScan  label     byte

         db        78h,'1'
         db        79h,'2'
         db        7ah,'3'
         db        7bh,'4'
         db        7ch,'5'
         db        7dh,'6'
         db        7eh,'7'
         db        7fh,'8'
         db        80h,'9'
         db        81h,'0'

         db        10h,'Q'
         db        11h,'W'
         db        12h,'E'
         db        13h,'R'
         db        14h,'T'
         db        15h,'Y'
         db        16h,'U'
         db        17h,'I'
         db        18h,'O'
         db        19h,'P'

         db        1eh,'A'
         db        1fh,'S'
         db        20h,'D'
         db        21h,'F'
         db        22h,'G'
         db        23h,'H'
         db        24h,'J'
         db        25h,'K'
         db        26h,'L'

         db        28h,"'"
         db        29h,'`'

         db        2ch,'Z'
         db        2dh,'X'
         db        2eh,'C'
         db        2fh,'V'
         db        30h,'B'
         db        31h,'N'
         db        32h,'M'

         db        34h,'.'
         db        35h,'?'

         db        0                        ; oznaáen° konce

; ------ texty pro naá°t†n° adres†©ñ

NacAdTxt db        17,'Naá°t†m adres†© ',0

FileInf0 db        8                        ; dÇlka textu jmÇna souboru FILEINFO
FileInfo db        'FILEINFO',0             ; koment†©e k souborñm
FileInfD db        'DESCRIPT.ION',0         ; koment†© systÇmu 4DOS
FileInf1 db        'DOSMAN.FIL',0           ; koment†© z DOSMAN1
FileInf2 db        '*.BBS',0                ; n†hradn° soubor koment†©ñ

FileInfP db        0                        ; parametry pro FILEINFO
                                            ;   bit 0: 1=soubor DOSMAN.FIL
                                            ;   bit 1: 1=je soubor *.BBS

AllDisk  db        'A:'
AllDir   db        '\'
All      db        '*.*',0                  ; specifikace - v®echny soubory

Data     ENDS
         END

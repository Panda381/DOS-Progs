
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                            D A T A B è Z E
;
;                            Zpracov†n° dat
;
; =============================================================================
;
; Ve©ejnÇ procedury:
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞


INCLUDE  ASM\DEF.ASM

CodeDbf  SEGMENT   BYTE PUBLIC
         ASSUME    cs:CodeDbf,ds:Data

DelKomDB EQU       50                       ; dÇlka koment†©e seznamu datab†ze
DelTxtDB EQU       63 - 2 - 12              ; dÇlka textovÇ poloëky (zalamov†n°)

; *****************************************************************************
;
;                     Obsluha datovÇho seznamu
;
; *****************************************************************************
;˛
DSezn    PROC      FAR

         add       sp,4                     ; zru®en° n†vratovÇ adresy
         call      far ptr ClosMnuA         ; uzav©en° menu

DSeznF   LABEL     FAR

         mov       si,offset SSMnuSel       ; specifikace menu vòbàru
         call      FileSel                  ; vòbàr souboru
         jnc       DSezn1                   ; zvolena dal®° poloëka OK
         jmp       far ptr Main0

; ------ obsluha souboru datab†ze

DSezn1:  push      ds
         pop       es                       ; ES <- datovò segment
         mov       di,offset SeznPath       ; jmÇno souboru DBF
         mov       cx,ds:[SeznPthN]         ; dÇlka jmÇna souboru
         call      far ptr ViewDBF          ; obsluha prohl°ëeáe DBF

; ------ odstranàn° jmÇna souboru z cesty

         mov       si,offset SSMnuSel       ; specifikace menu vòbàru
         call      far ptr SubFSel          ; odstranàn° jmÇna souboru
         jmp       short DSeznF

DSezn    ENDP

; -----------------------------------------------------------------------------
;      obsluha prohl°ëeáe DBF (soubor ES:DI, dÇlka CX) (niá° v®echny registry !)
; -----------------------------------------------------------------------------

ViewDBF  PROC      FAR

; ------ otev©en° souboru DBF (adresa ES:DI, dÇlka CX)

         mov       si,offset DBFMnu         ; menu editoru
         call      far ptr OpenDBF          ; otev©en° souboru datab†ze
         jnc       ViewDBF1                 ; operace OK
         ret                                ; n†vrat p©i chybà

; ------ jmÇno aktivn°ho souboru

ViewDBF1:call      DBFAdrES                 ; aktualizace adresy okna -> ES
         mov       bx,8                     ; dÇlka bufferu
         mov       si,offset SRSMnPl4+1     ; buffer jmÇna souboru
         mov       ch,0
         mov       cl,ds:[si-1]             ; dÇlka jmÇna souboru
         sub       bx,cx                    ; zbytek bufferu
         cld
         mov       di,DBFName               ; jmÇno souboru
         rep       movsb                    ; p©enos jmÇna souboru
         mov       cl,bl                    ; CL <- zbytek bufferu
         mov       al," "
         rep       stosb                    ; vymaz†n° zbytku bufferu

; ------ koment†© souboru

         mov       si,offset LinBuff        ; buffer s koment†©em
         mov       cl,ds:[si-1]             ; dÇlka textu koment†©e
         mov       es:[DBFNKom],cx          ; dÇlka textu koment†©e
         mov       di,DBFKom                ; buffer koment†©e
         rep       movsb                    ; p©enos koment†©e

; ------ otev©en° okna editoru datab†ze

         and       byte ptr ds:[DBFEParm],bit2+bit6 ; nulov†n° p©°znakñ
         mov       si,offset DBFMnu         ; menu datab†ze
         call      far ptr OpenMnu          ; otev©en° okna menu

; ------ p©°prava znakñ oddàlovaáñ

         mov       al,ds:[OddelRad]         ; oddàlovaá ©†dñ á°sel
         mov       cs:[DBFOdRad],al         ; oddàlovaá ©†dñ á°sel
         mov       al,ds:[OddelDes]         ; oddàlovaá desetin
         mov       cs:[DBFOdDes],al         ; oddàlovaá desetin

; ------ zobrazen° okna

DSezn2:  and       byte ptr ds:[ParMenu],not bit5 ; nulov†n° automat. vyno©en°
         call      far ptr VypKrit          ; vypnut° kritickÇ sekce
         call      far ptr DispMnu          ; zobrazen° okna
         call      far ptr InitQVw          ; inicializace rychloprohl°ëen°

; ------ start modifikace z†hlav°, je-li novò soubor

         mov       bx,3c00h                 ; povel pro modifikaci z†hlav° F2
         test      byte ptr ds:[DBFEParm],bit6 ; je vytvo©en° souboru ?
         jnz       DSezn383                 ; je vytvo©en° souboru

; ------ áek†n° na stisk kl†vesy (kalkulaáka/ASCII -> zñstane v InpChar !)

DSezn3:  call      far ptr NulBreak         ; nulov†n° p©°znaku p©eru®en°
         call      DispDBFK                 ; zobrazen° kurzoru
         call      far ptr MouseInt         ; obsluha my®i
         call      far ptr DispTime         ; obsluha zobrazen° áasu
         call      far ptr Darker           ; obsluha stm°vaáe
         call      far ptr InpPresm         ; test p©esmykaáñ
         call      EditBQVw                 ; obsluha rychlÇho zobrazen°
         call      far ptr MouseGet         ; test stavu my®i
         jnc       DSezn383                 ; je k¢d my®i
         call      far ptr TestChar         ; test, zda je p©ipraven znak
         jc        DSezn3                   ; nen° p©ipraven znak z kl†vesnice

; ------ vstup znaku z kl†vesnice -> BX

         call      far ptr InpChar          ; vstup znaku z kl†vesnice -> BX

; ------ vypnut° str†nkovÇho zobrazen° pomoc° ESC, v ©†dkovÇm reëimu konec

DSezn383:test      byte ptr ds:[DBFEParm],bit0 ; je editace ?
         jnz       DSezn388                 ; je editace

         mov       di,offset DBFMnHM1       ; ©†dkovò reëim
         test      byte ptr es:[DBFParm],bit0 ; je str†nkovÇ zobrazen° ?
         jz        DSezn385                 ; nen° str†nkovÇ zobrazen°
         mov       di,offset DBFMnHM2       ; str†nkovò reëim
DSezn385:call      far ptr MenKlHlp         ; menu kl†ves malÇ n†povàdy

DSezn386:cmp       bl,27
         jne       DSezn388                 ; nen° ESC

         call      DBFAdrES                 ; aktualizace adresy okna -> ES
         test      byte ptr es:[DBFParm],bit0 ; je str†nkovÇ zobrazen° ?
         jz        DSezn389                 ; nen° str†nkovÇ zobrazen°
         and       byte ptr es:[DBFParm],not bit0 ; vypnut° str†nkovÇho zobraz.
DSezn387:jmp       DSezn2                   ; n†vrat do okna

; ------ obsluha kl†vesy

DSezn388:call      far ptr EditBMnu         ; obsluha menu
         test      byte ptr ds:[DBFEParm],bit6 ; je st†le vytvo©en° souboru ?
         jz        DSezn387                 ; nen° - pokraáov†n° v obsluze
                                          ;* operace vytvo©en° byla p©eru®ena
; ------ n†vrat z menu ESC

DSezn389:

; ------ uzav©en° okna editoru

DSezn02: call      far ptr ClosMnu          ; uzav©en° okna

; ------ uzav©en° datab†ze

         mov       si,offset DBFMnu         ; specifikace menu vòbàru
         call      far ptr ClosDBF          ; uzav©en° datab†ze
         ret

ViewDBF  ENDP

; *****************************************************************************
;                               EditBMnu
;                      editace editoru datab†ze
; -----------------------------------------------------------------------------
; VSTUP: SI=definice menu
;        BX=kl†vesa
;        DS=datovò segment
; VùSTUP: BX=0 kl†vesa obslouëena
; *****************************************************************************
;˛
EditBMnu PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ adresa definice okna -> ES

         call      DBFAdrES                 ; aktualizace adresy okna -> ES

; ------ vyvol†n° obsluhy

         mov       ax,es:[DBFAktZ]          ; aktivn° poloëka LOW
         mov       dx,es:[DBFAktZ+2]        ; aktivn° poloëka HIGH
         mov       cx,es:[DBFVysL]          ; vò®ka okna datovòch ©†dkñ
         dec       cx
;         mov       cl,ds:[si+MnuVys]        ; vò®ka okna
;         sub       cl,4                     ; vò®ka okna bez okrajñ
;         mov       ch,0
         call      EditBMn0                 ; obsluha kl†vesy

; ------ zmàna aktivn° poloëky DX:AX

         cmp       ax,es:[DBFAktZ]          ; aktivn° poloëka zmànàna ?
         jne       EditBM01
         cmp       dx,es:[DBFAktZ+2]
         je        EditBM02                 ; nezmànàna
EditBM01:mov       es:[DBFAktZ],ax          ; nov† aktivn° poloëka LOW
         mov       es:[DBFAktZ+2],dx        ; nov† aktivn° poloëka HIGH
         call      EdiBEBeg                 ; zah†jen° editace
EditBM02:xor       bx,bx                    ; p©°znak obsluhy kl†vesy
         jmp       EditBMn9

; ------ obsluha kl†vesy

EditBMn0:call      far ptr JumpBX

         dw        4b00h,EditBLft           ; vlevo
         dw        4d00h,EditBRgh           ; vpravo
         dw        4800h,EditBUp            ; nahoru
         dw        5000h,EditBDwn           ; dolñ
         dw        7400h,EditBCRg           ; ^vpravo
         dw        7300h,EditBCLf           ; ^vlevo

         dw        4900h,EditBPUp           ; PageUp
         dw        5100h,EditBPDn           ; PageDown
         dw        8400h,EditBCPU           ; ^PageUp
         dw        7600h,EditBCPD           ; ^PageDown

         dw        4700h,EditBHom           ; Home
         dw        4f00h,EditBEnd           ; End
         dw        7700h,Edi1BCPU           ; ^Home
         dw        7500h,Edi1BCPD           ; ^End

         dw        9800h,EditBAUp           ; Alt-nahoru
         dw        0A000h,EditBADn          ; Alt-dolñ
         dw        9700h,EditBAHm           ; Alt-Home
         dw        9f00h,EditBAEn           ; Alt-End

         dw        0f09h,EditBTab           ; TAB
         dw        0f00h,EditBSTa           ; Shift-TAB

         dw        1011h,EditBQSt           ; Ctrl-Q rychlÇ zobrazen°
         dw        1615h,EditBUnd           ; Ctrl-U obnoven° zmàn

         dw        0e08h,EditBBS            ; BS zru®en° znaku p©ed kurzorem
         dw        5300h,EditBDlt           ; Delete zru®en° znaku za kurzorem

         dw        011bh,EditBBE1           ; Esc ukonáen° editace

         dw        3c00h,EditBMod           ; F2 modifikace z†hlav°
         dw        3d00h,EditBMem           ; F3 editace MEMO pole
         dw        3e00h,EditBBEd           ; F4 zah†jen° editace
         dw        3f00h,EditBKop           ; F5 kopie
         dw        4000h,EditBSko           ; F6 skok na z†znam
         dw        4100h,EditBHle           ; F7 hled†n°
         dw        4200h,EditBRus           ; F8 ru®en°
         dw        4300h,EditBVlo           ; F9 vloëen° novòch z†znamñ
         dw        4400h,EditBMen           ; F10 obsluha menu

         dw        5f00h,EditBPol           ; Ctrl-F2 ®°©ka pole

         dw        260ch,EditBHlL           ; Ctrl-L pokraáov†n°

         dw        5200h,EditBIns           ; Insert

         dw        MousXKod+MousXLP,EdiBMous ; stisk levÇho tlaá°tka
         dw        MousXKod+MousXLH,EdiBMous ; drëen° levÇho tlaá°tka
         dw        MousXKod+MousXLD,EditBBEd ; dvoj° stisk levÇho tlaá°tka
         dw        MousXKod+MousXRP,EdiBMouR ; stisk pravÇho tlaá°tka
         dw        MousXKod+MousXRH,EdiBMoR4 ; drëen° pravÇho tlaá°tka
         dw        MousXKod+MousXRR,EdiBMoR8 ; uvolnàn° pravÇho tlaá°tka my®i
         dw        MousXKod+MousXMP,EditBMen ; stisk st©edn°ho tlaá°tka (menu)
         dw        MousXKod+MousXMov,EdiBMoR4 ; pohyb my®°

         dw        0,EditBICh               ; editace

; ------ n†vrat registrñ

EditBMn8:pop       ax                       ; zru®en° n†vratovÇ adresy

EditBMn9:call      far ptr InfoClos         ; uzav©en° informaán°ho ©†dku
         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

EditBMnu ENDP

; ------ oznaáov†n° poloëek my®°

EdiBMouR:call      EdiBMoR8                 ; nen° oznaáov†n° my®°
         test      byte ptr ds:[DBFEParm],bit0 ; je editace ?
         jz        EdiBMoR1                 ; nen° editace
         jmp       EditBBE1                 ; ukonáen° editace

EdiBMoR1:test      byte ptr es:[DBFParm],bit0 ; je str†nkovò reëim ?
         jnz       EdiBMoR7                 ; je str†nkovò reëim - nic

         call      EdiBMous                 ; posun kurzoru

         test      byte ptr es:[DBFParm],bit1 ; je z†kaz z†pisu ?
         jnz       EdiBMoR7                 ; z†kaz z†pisu - posun kurzoru dolñ

         call      far ptr GetADBF          ; poskytnut° aktivn° poloëky DBF
         jc        EdiBMoR3                 ; nen° platnò z†znam
         or        byte ptr ds:[DBSelMou],bit0+bit1 ; p©°znak oznaáov†n° my®°
         cmp       byte ptr es:[di],"*"     ; je oznaáen† poloëka ?
         jne       EdiBMoR3                 ; nen° oznaáen† - oznaáov†n°
         and       byte ptr ds:[DBSelMou],not bit1 ; je odznaáov†n° poloëek
EdiBMoR3:call      DBFAdrES                 ; aktualizace adresy okna -> ES

EdiBMoR4:test      byte ptr ds:[DBSelMou],bit0 ; je oznaáov†n° ?
         jz        EdiBMous                 ; nen° oznaáov†n°
         test      byte ptr ds:[DBFEParm],bit0 ; je editace ?
         jnz       EdiBMoR7                 ; je editace
         test      byte ptr es:[DBFParm],bit0 ; je str†nkovò reëim ?
         jnz       EdiBMoR7                 ; je str†nkovò reëim - nic

         call      EdiBMous                 ; posun kurzoru
         test      byte ptr es:[DBFParm],bit1 ; je z†kaz z†pisu ?
         jnz       EdiBMoR7                 ; z†kaz z†pisu

; ------ £schova data a áasu souboru

         call      DBFGetDT                 ; £schova data a áasu souboru
         jc        EdiBMoR7                 ; chyba

; ------ naáten° aktu†ln°ho z†znamu

         call      far ptr GetADBF          ; poskytnut° aktivn° poloëky DBF
         jc        EdiBMoR7                 ; chyba

; ------ zmàna p©°znaku oznaáen° z†znamu

         test      byte ptr ds:[DBSelMou],bit1 ; je oznaáov†n° ?
         jz        EdiBMoR5                 ; nen° oznaáov†n°
         cmp       byte ptr es:[di],"*"     ; je oznaáeno ?
         jmp       short EdiBMoR6

EdiBMoR5:cmp       byte ptr es:[di]," "     ; je odznaáeno ?
EdiBMoR6:je        EdiBMoR7                 ; je jië oznaáeno
         xor       byte ptr es:[di],"*" XOR " " ; zmàna p©°znaku oznaáen°

; ------ uloëen° zmànànÇho z†znamu

         call      far ptr SetADBF          ; uloëen° aktivn° poloëky

; ------ vypr†zdnàn° z†pisovÇho bufferu a n†vrat data a áasu

         call      DBFSetDT                 ; nastaven° data a áasu

EdiBMoR7:call      DBFAdrES                 ; aktualizace adresy okna -> ES
         ret

EdiBMoR8:and       byte ptr ds:[DBSelMou],not bit0 ; nen° oznaáov†n° my®°
         ret

; ------ veden° kurzoru my®°

EdiBMous:test      byte ptr es:[DBFParm],bit0 ; je str†nkovò reëim ?
         jnz       EdiBMou5                 ; je str†nkovò reëim
         call      UlozDBF                  ; uloëen° editovanÇho bufferu
         mov       al,byte ptr ds:[MousePoz+1] ; ©†dek kurzoru my®i
         sub       al,ds:[si+MnuRad]        ; ©†dek v oknà relativnà
         jc        EdiBMou1
         sub       al,3                     ; odeáten° horn°ho okraje
         jnc       EdiBMou2                 ; nen° p©eteáen°
EdiBMou1:mov       al,0
EdiBMou2:cmp       al,cl
         jb        EdiBMou3
         mov       al,cl
         dec       ax
EdiBMou3:mov       ah,0
         xor       dx,dx
         add       ax,word ptr es:[DBFTopZ] ; poá†teán° ©†dek
         adc       dx,word ptr es:[DBFTopZ+2]

         cmp       ax,es:[DBFAktZ]          ; aktivn° poloëka zmànàna ?
         jne       EdiBMou4
         cmp       dx,es:[DBFAktZ+2]
         je        EdiBMou5                 ; nezmànàna
EdiBMou4:mov       es:[DBFAktZ],ax          ; nov† aktivn° poloëka LOW
         mov       es:[DBFAktZ+2],dx        ; nov† aktivn° poloëka HIGH
         call      EdiBEBeg                 ; zah†jen° editace
EdiBMou5:ret

; ------ kurzor vlevo

EditBLft:test      byte ptr ds:[DBFEParm],bit0 ; je editace ?
         jnz       EditBLf3                 ; je editace

         test      byte ptr es:[DBFParm],bit0 ; je str†nkovò reëim ?
         jnz       EditBLf2                 ; je str†nkovò reëim - nic se nedàje

         cmp       word ptr es:[DBFTopP],0  ; je jië poá†tek obrazovky ?
         je        EditBLf2                 ; je jië poá†tek obrazovky
         dec       word ptr es:[DBFTopP]    ; sn°ëen° poá†teán° zobrazenÇ pozice
EditBLf2:ret

EditBLf3:jmp       EditPLft                 ; posun kurzoru vlevo

; ------ kurzor vpravo

EditBRgh:test      byte ptr ds:[DBFEParm],bit0 ; je editace ?
         jnz       EditBRg3                 ; je editace

         test      byte ptr es:[DBFParm],bit0 ; je str†nkovò reëim ?
         jnz       EditBRg2                 ; je str†nkovò reëim - nic se nedàje
         inc       word ptr es:[DBFTopP]    ; zvò®en° poá†teán° zobrazenÇ pozice
EditBRg2:ret

EditBRg3:jmp       EditPRgh                 ; posun kurzoru vpravo

; ------ kurzor nahoru

EditBUp: test      byte ptr es:[DBFParm],bit0 ; je str†nkovò reëim ?
         jnz       EditBUp2                 ; je str†nkovò reëim
                                          ;* kurzor nahoru v ©†dkovÇm reëimu
                                          ;* sem se sk†áe z EditBPUp a EditBADn
EditBUp1:call      UlozDBF                  ; uloëen° editovanÇho bufferu
         sub       ax,1                     ; posun kurzoru nahoru
         sbb       dx,0
         jnc       EditBUp9                 ; nen° p©eteáen°
         jmp       EditBCPU                 ; prvn° z†znam

EditBUp2:test      byte ptr ds:[DBFEParm],bit0 ; je editace ?
         jz        EditBUp8                 ; nen° editace
                                          ;* poáet pozic k posunu kurzoru -> CX
         mov       cl,ds:[si+MnuSir]        ; ®°©ka okna
         sub       cl,15                    ; maxim†ln° ®°©ka ©†dku
         mov       ch,0
                                          ;* test, zda je jië prvn° ©†dek
         mov       bx,es:[DBFAktP]          ; aktivn° poloëka
         or        bx,bx                    ; je prvn° poloëka ?
         jnz       EditBUp4                 ; nen° prvn° poloëka
         cmp       cx,es:[DBFKurz]          ; je kurzor na dal®°m ©†dku ?
         ja        EditBUp6                 ; je prvn° ©†dek - nelze posunout

EditBUp4:call      EditPLft                 ; posun kurzoru vlevo
         jc        EditBUp6                 ; nelze jië posunout
         cmp       bx,es:[DBFAktP]          ; poloëka zmànàna ?
         loope     EditBUp4                 ; posun na p©edchoz° poloëku
         je        EditBUp9                 ; poloëka nezmànàna

         mov       cl,ds:[si+MnuSir]        ; ®°©ka okna
         sub       cl,15                    ; maxim†ln° ®°©ka ©†dku
         cmp       cx,es:[DBFKurz]          ; je prvn° ©†dek poloëky ?
         ja        EditBUp6                 ; je prvn° ©†dek poloëky

         push      ax
         mov       ax,es:[DBFKurz]          ; dÇlka pole - 1
         div       cl                       ; poáet ©†dkñ
         mul       cl                       ; poá†tek posledn°ho ©†dku
         mov       es:[DBFKurz],ax          ; nov† pozice na ©†dku
         pop       ax
         ret

EditBUp6:call      EditPBeg                 ; zaá†tek poloëky
         ret
                                          ;* nen° editace ve str†nkovÇm reëimu
EditBUp8:cmp       word ptr es:[DBFTopL],0  ; je jië prvn° ©†dek ?
         je        EditBUp9                 ; je jië prvn° ©†dek
         dec       word ptr es:[DBFTopL]    ; sn°ëen° á°sla ©†dku
EditBUp9:ret

; ------ kurzor dolñ

EditBDwn:test      byte ptr es:[DBFParm],bit0 ; je str†nkovò reëim ?
         jnz       EditBDw2                 ; je str†nkovò reëim
                                          ;* kurzor dolñ v ©†dkovÇm reëimu
                                          ;* sem se sk†áe z EditBPDn a EditBAUp
EditBDw1:call      UlozDBF                  ; uloëen° editovanÇho bufferu
         add       ax,1                     ; posun kurzoru dolñ
         adc       dx,0
         ret
                                          ;* posun str†nky, nen°-li editace
EditBDw2:test      byte ptr ds:[DBFEParm],bit0 ; je editace ?
         jnz       EditBDw3                 ; je editace
         inc       word ptr es:[DBFTopL]    ; zvò®en° poá†teán°ho ©†dku
         ret
                                          ;* poáet pozic k posunu kurzoru -> CX
EditBDw3:mov       cl,ds:[si+MnuSir]        ; ®°©ka okna
         sub       cl,15                    ; maxim†ln° ®°©ka ©†dku
         mov       ch,0
                                          ;* dÇlka poloëky -> BX
         mov       bx,es:[DBFAktP]          ; aktivn° poloëka
         shl       bx,1
         shl       bx,1
         shl       bx,1
         add       bx,es:[DBFAdrP]          ; adresa aktivn° poloëky
         mov       bx,es:[bx+DBFDelX]       ; dÇlka poloëky (pozic)
                                          ;* test, zda zbòv† je®tà dost pozic
         sub       bx,es:[DBFKurz]          ; poáet zbylòch pozic
         cmp       bx,cx                    ; zbòv† je®tà dost pozic ?
         jae       EditBDw5                 ; zbòv† dost pozic
         jmp       EditPNxt                 ; dal®° poloëka na ©†dku

EditBDw5:call      EditPRgh                 ; posun kurzoru vpravo
         loop      EditBDw5                 ; posun na dal®° ©†dek
         ret

; ------ Ctrl-vpravo: n†sleduj°c° poloëka na ©†dku

EditBCRg:test      byte ptr ds:[DBFEParm],bit0 ; je editace ?
         jz        EditBCR2                 ; nen° editace
         jmp       EditPCRg                 ; posun o slovo vpravo

EditBCR2:test      byte ptr es:[DBFParm],bit0 ; je str†nkovò reëim ?
         jnz       EditBCR4                 ; je str†nkovò reëim
         mov       ch,0
         mov       cl,ds:[si+MnuSir]        ; CX <- ®°©ka ©†dku okna
         sub       cl,2                     ; bez okrajñ
         shr       cx,1                     ; poáet pozic k posunu
         add       es:[DBFTopP],cx          ; posun poá†tku okna
EditBCR4:ret

; ------ Ctrl-vlevo: p©ede®l† poloëka na ©†dku

EditBCLf:test      byte ptr ds:[DBFEParm],bit0 ; je editace ?
         jz        EditBCL2                 ; nen° editace
         jmp       EditPCLf                 ; posun o slovo vlevo

EditBCL2:test      byte ptr es:[DBFParm],bit0 ; je str†nkovò reëim ?
         jnz       EditBCL4                 ; je str†nkovò reëim
         mov       ch,0
         mov       cl,ds:[si+MnuSir]        ; CX <- ®°©ka ©†dku okna
         sub       cl,2                     ; bez okrajñ
         shr       cx,1                     ; poáet pozic k posunu
         sub       es:[DBFTopP],cx          ; posun poá†tku okna
         jnc       EditBCL4                 ; nen° podteáen°
         mov       word ptr es:[DBFTopP],0  ; omezen° p©i podteáen°
EditBCL4:ret

; ------ PageUp: str†nka nahoru

EditBPUp:test      byte ptr es:[DBFParm],bit0 ; je str†nkovò reëim ?
         jz        EditBPU1                 ; nen° str†nkovò reëim
         jmp       EditBUp1                 ; dal®° z†znam
                                          ;* ukonáen° editace aktivn° poloëky
EditBPU1:call      UlozDBF                  ; uloëen° editovanÇho bufferu
         dec       cx                       ; vò®ka okna - 1
                                          ;* zaá†tek seznamu, je-li poá†tek
         cmp       word ptr es:[DBFTopZ+2],0
         jne       EditBPU2
         cmp       word ptr es:[DBFTopZ],0  ; je prvn° ©†dek seznamu ?
         je        EditBCPU                 ; zaá†tek seznamu
                                          ;* omezen° poátu ©†dkñ k posunu -> CX
         cmp       cx,es:[DBFTopZ]
         jbe       EditBPU2
         mov       cx,es:[DBFTopZ]          ; omezen° posuvu
                                          ;* á°slo maxim†ln°ho z†znamu -> DI:BX
EditBPU2:mov       bx,es:[DBFMaxZ]
         mov       di,es:[DBFMaxZ+2]
         sub       bx,1
         sbb       di,0
                                          ;* oprava kurzoru, je-li posledn° z†znam
         cmp       dx,di                    ; je posledn° z†znam ?
         jne       EditBPU4                 ; nen° posledn° z†znam
         cmp       ax,bx
         jne       EditBPU4
         sub       ax,1                     ; posun kurzoru na p©edposledn° z†znam
         sbb       dx,0
                                          ;* posun poá†tku okna a kurzoru
EditBPU4:sub       es:[DBFTopZ],cx          ; posun poá†teán°ho z†znamu
         sbb       word ptr es:[DBFTopZ+2],0
         sub       ax,cx                    ; posun kurzoru
         sbb       dx,0
         ret

; ------ Ctrl-PageUp: prvn° z†znam

EditBCPU:call      UlozDBF                  ; uloëen° editovanÇho bufferu
         xor       ax,ax                    ; prvn° z†znam
         xor       dx,dx
         ret

; ------ Ctrl-Home: prvn° z†znam/prvn° poloëka

Edi1BCPU:test      byte ptr ds:[DBFEParm],bit0 ; je editace ?
         jz        EditBCPU                 ; nen° editace - prvn° z†znam
Edi2BCPU:call      EditPPre                 ; p©edchoz° poloëka
         jnc       Edi2BCPU                 ; dal®° poloëka
         call      EditPBeg                 ; zaá†tek prvn° poloëky
         ret

; ------ PageDown: str†nka dolñ

EditBPDn:test      byte ptr es:[DBFParm],bit0 ; je str†nkovò reëim ?
         jz        EditBPD1                 ; nen° str†nkovò reëim
         jmp       EditBDw1                 ; dal®° z†znam
                                          ;* uloëen° editovanÇho ©†dku
EditBPD1:call      UlozDBF                  ; uloëen° editovanÇho bufferu
                                          ;* korekce kurzoru, je-li prvn° ©†dek
         or        ax,ax                    ; je kurzor na prvn° poloëce ?
         jnz       EditBPD2                 ; nen° prvn° poloëka
         or        dx,dx
         jnz       EditBPD2
         inc       ax                       ; korekce, je-li kurzor na 1.poloëce
                                          ;* p©°prava maxim. poá†tku -> DI:BX
EditBPD2:mov       bx,es:[DBFMaxZ]          ; poáet z†znamñ
         mov       di,es:[DBFMaxZ+2]
         sub       bx,cx                    ; maxim†ln° poá†tek
         sbb       di,0
         jnc       EditBPD4
         xor       bx,bx                    ; omezen° maxim†ln°ho poá†tku
         xor       di,di
                                          ;* vzd†lenost poá†tku ke konci->DI:BX
EditBPD4:dec       cx                       ; vò®ka okna - 1
         sub       bx,es:[DBFTopZ]          ; vzd†lenost od aktu†ln°ho poá†tku
         sbb       di,es:[DBFTopZ+2]
         jnz       EditBPD6                 ; poá†tek p©°li® vzd†len
                                          ;* je-li jië konec, kurzor na konec
         or        bx,bx
         jz        EditBCPD                 ; je jië konec
                                          ;* p©°prava poátu ©†dkñ k posunu
         cmp       cx,bx                    ; zbòv† dost ©†dkñ ?
         jbe       EditBPD6                 ; zbòv† dost ©†dkñ
         mov       cx,bx                    ; omezen° posunu
                                          ;* posun poá†tku a kurzoru
EditBPD6:add       es:[DBFTopZ],cx          ; posun poá†tku okna
         adc       word ptr es:[DBFTopZ+2],0
         add       ax,cx                    ; zvò®en° kurzoru
         adc       dx,0
         ret

; ------ Ctrl-PageDown: posledn° z†znam

EditBCPD:call      UlozDBF                  ; uloëen° editovanÇho bufferu
         mov       ax,es:[DBFMaxZ]          ; poáet z†znamñ
         mov       dx,es:[DBFMaxZ+2]
         sub       ax,1                     ; posledn° z†znam
         sbb       dx,0
         ret

; ------ Ctrl-End: posledn° z†znam/posledn° poloëka

Edi1BCPD:test      byte ptr ds:[DBFEParm],bit0 ; je editace ?
         jz        EditBCPD                 ; nen° editace - posledn° z†znam
Edi2BCPD:call      EditPNxt                 ; dal®° poloëka
         jnc       Edi2BCPD                 ; dal®° poloëka
         call      EditTEnd                 ; konec posledn° poloëky
         ret

; ------ Home: poá†tek poloëky, poá†tek ©†dku, prvn° poloëka

EditBHom:test      byte ptr ds:[DBFEParm],bit0 ; je editace ?
         jnz       EditBHm2                 ; je editace
                                          ;* str†nkovò reëim - prvn° ©†dek
         test      byte ptr es:[DBFParm],bit0 ; je str†nkovò reëim ?
         jz        EditBHm1                 ; nen° str†nkovò reëim
         mov       word ptr es:[DBFTopL],0  ; prvn° ©†dek
         ret
                                          ;* ©†dkovò reëim - poá†tek ©†dku
EditBHm1:mov       word ptr es:[DBFTopP],0  ; poá†teán° pozice ©†dku
         ret
                                          ;* editace - poá†tek poloëky
EditBHm2:mov       bx,es:[DBFKurz]          ; kurzor
         call      EditPBeg                 ; zaá†tek ©†dku
         cmp       bx,es:[DBFKurz]          ; byl kurzor zmànàn ?
         jne       EditBHm3                 ; kurzor byl zmànàn
         call      EditPPre                 ; p©edchoz° poloëka
         jc        EditBHm3                 ; nen° p©edchoz° poloëka
         call      EditTEnd                 ; posun na konec textu
EditBHm3:ret

; ------ End: konec poloëky, konec ©†dku, posledn° poloëka

EditBEnd:test      byte ptr ds:[DBFEParm],bit0 ; je editace ?
         jnz       EditBEn2                 ; je editace
                                          ;* str†nkovò reëim - posledn° ©†dek
         test      byte ptr es:[DBFParm],bit0 ; je str†nkovò reëim ?
         jz        EditBEn1                 ; nen° str†nkovò reëim
         mov       cx,es:[DBFNumL]          ; poáet ©†dkñ
         mov       es:[DBFTopL],cx          ; asi tak maximum ©†dkñ (omez° se)
         ret
                                          ;* ©†dkovò reëim - konec ©†dku
EditBEn1:mov       cx,es:[DBFSirR]          ; ®°©ka ©†dku
         mov       es:[DBFTopP],cx          ; asi tak novò poá†tek (omez° se)
         ret
                                          ;* editace - konec poloëky
EditBEn2:mov       bx,es:[DBFKurz]          ; kurzor v poloëce
         call      EditTEnd                 ; nalezen° konce textu v poloëce
         cmp       bx,es:[DBFKurz]          ; byl kurzor zmànàn ?
         jne       EditBEn3                 ; kurzor byl zmànàn
         call      EditPNxt                 ; dal®° poloëka (bude poá†tek)
EditBEn3:ret

; ------ Alt-nahoru: p©ede®l† oznaáen† poloëka

EditBAU0:call      EditBDw1                 ; n†vrat kurzoru dolñ
                                          ;* uloëen° aktu†ln°ho z†znamu
EditBAUp:call      UlozDBF                  ; uloëen° editovanÇho bufferu
         push      ax                       ; DX:AX=aktu†ln° z†znam
         push      dx
                                          ;* posun kurzoru nahoru
EditBAU2:sub       ax,1                     ; posun kurzoru nahoru
         sbb       dx,0
         jc        EditBAD8                 ; nen° dal®° z†znam
                                          ;* test, zda je oznaáenò z†znam
         call      far ptr GetDBF           ; poskytnut° dal®° poloëky
         jc        EditBAD8                 ; poloëka nenalezena
         call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jc        EditBAD7                 ; je p©eru®en° operace
         cmp       byte ptr es:[di]," "     ; je oznaáenò z†znam ?
         je        EditBAU2                 ; nen° oznaáenò z†znam - dal®°
         jmp       short EditBAD6           ; nalezen oznaáenò z†znam

; ------ Alt-dolñ: dal®° oznaáen† poloëka

EditBAD0:call      EditBUp1                 ; n†vrat kurzoru nahoru
                                          ;* uloëen° aktu†ln°ho z†znamu
EditBADn:call      UlozDBF                  ; uloëen° editovanÇho bufferu
         push      ax                       ; DX:AX=aktu†ln° z†znam
         push      dx
                                          ;* posun kurzoru dolñ
EditBAD2:add       ax,1
         adc       dx,0
                                          ;* test, zda je oznaáenò z†znam
         call      far ptr GetDBF           ; poskytnut° dal®° poloëky
         jc        EditBAD8                 ; poloëka nenalezena
         call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jc        EditBAD7                 ; je p©eru®en° operace
         cmp       byte ptr es:[di]," "     ; je oznaáen° z†znam ?
         je        EditBAD2                 ; nen° oznaáenò z†znam - dal®°
                                          ;* ©†dek nalezen OK
EditBAD6:add       sp,4                     ; zru®en° registrñ DX a AX
         clc                                ; p©°znak nalezen° ©†dku OK
         ret
                                          ;* ©†dek nenalezen - n†vrat ukazatele
EditBAD7:call      far ptr FlushChr         ; vypr†zdnàn° bufferu kl†vesnice
EditBAD8:pop       dx                       ; n†vrat aktu†ln°ho ©†dku DX:AX
         pop       ax
         stc                                ; p©°znak chyby - nenalezeno
         ret

; ------ Alt-Home: prvn° oznaáen† poloëka

EditBAHm:call      UlozDBF                  ; uloëen° editovanÇho bufferu
         call      EditBAUp                 ; p©ede®l† oznaáen† poloëka
         jc        EditBAD0                 ; nen° ë†dn† poloëka - posun dolñ
EditBAH1:call      EditBAUp                 ; nalezen° dal®° oznaáenÇ poloëky
         jnc       EditBAH1                 ; nalezena poloëka - hled†n° dal®°
         ret

; ------ Alt-End: posledn° oznaáen† poloëka

EditBAEn:call      UlozDBF                  ; uloëen° editovanÇho bufferu
         call      EditBADn                 ; dal®° oznaáen† poloëka
         jc        EditBAU0                 ; nen° ë†dn† poloëka - posun nahoru
EditBAE1:call      EditBADn                 ; nalezen° dal®° oznaáenÇ poloëky
         jnc       EditBAE1                 ; nalezena poloëka - hled†n° dal®°
         ret

; ------ ENTER: str†nkovÇ zobrazen°, dal®° editovan† poloëka

EditBEnt:test      byte ptr ds:[DBFEParm],bit0 ; je editace ?
         jnz       EditBTb0                 ; je editace
         xor       byte ptr es:[DBFParm],bit0 ; str†nkovÇ zobrazen°
         ret

; ------ TAB: dal®° editovanÇ pole
                                          ;* dal®° editovanÇ pole, je-li editace
EditBTab:test      byte ptr ds:[DBFEParm],bit0 ; je editace ?
         jz        EditBTb3                 ; nen° editace
EditBTb0:call      EditPNxt                 ; dal®° poloëka na ©†dku
         jnc       EditBTb8                 ; byla dal®° poloëka OK
         call      EditBDw1                 ; dal®° z†znam
         jmp       Edi1BCPU                 ; nastaven° na zaá†tek prvn° poloëky

                                          ;* ve str†nkovÇm reëimu se nic nedàje
EditBTb3:test      byte ptr es:[DBFParm],bit0 ; je str†nkovò reëim ?
         jnz       EditBTb8                 ; je str†nkovò reëim - nic

                                          ;* nalezen° dal®° poloëky na ©†dku
         xor       bx,bx                    ; á°taá pozice na ©†dku
         mov       cx,es:[DBFNumP]          ; poáet poloëek
         mov       di,es:[DBFAdrP]          ; adresa poloëek
         jcxz      EditBTb6                 ; nen° ë†dn† poloëka
         dec       cx                       ; poáet poloëek - 1
         jz        EditBTb6                 ; je jen 1 poloëka
EditBTb4:add       bx,es:[di+DBFSirX]       ; zvò®en° ukazatele pozice
         inc       bx                       ; korekce - oddàlovaá poloëek
         add       di,DBFX                  ; adresa dal®°ho popisovaáe
         cmp       bx,es:[DBFTopP]          ; je jië vy®®° pozice ?
         ja        EditBTb6                 ; dosaëeno vy®®° pozice
         loop      EditBTb4                 ; dal®° poloëka

EditBTb6:mov       es:[DBFTopP],bx          ; nov† poá†teán° pozice

EditBTb8:ret

; ------ Shift-Tab: p©edchoz° editovanÇ pole
                                          ;* p©edchoz° edit. pole, je-li editace
EditBSTa:test      byte ptr ds:[DBFEParm],bit0 ; je editace ?
         jz        EditBST3                 ; nen° editace
         call      EditPPre                 ; p©edchoz° poloëka na ©†dku
         jnc       EditBST2                 ; byla dal®° poloëka OK
         call      EditBUp1                 ; p©edchoz° z†znam
EditBST1:call      EditPNxt                 ; posun na dal®° poloëku
         jnc       EditBST1                 ; byl posun
EditBST2:call      EditPBeg                 ; posun na poá†tek poloëky
         ret

                                          ;* ve str†nkovÇm reëimu se nic nedàje
EditBST3:test      byte ptr es:[DBFParm],bit0 ; je str†nkovò reëim ?
         jnz       EditBST8                 ; je str†nkovò reëim - nic

                                          ;* nalezen° p©ede®lÇ poloëky na ©†dku
         xor       bx,bx                    ; BX <- á°taá pozice na ©†dku
         mov       cx,es:[DBFTopP]          ; CX <- £schova aktu†ln°ho poá†tku
         mov       di,es:[DBFAdrP]          ; adresa poloëek
EditBST4:mov       es:[DBFTopP],bx          ; novò poá†tek
         add       bx,es:[di+DBFSirX]       ; p©iáten° dal®° poloëky
         inc       bx                       ; oddàlovaá
         add       di,DBFX                  ; adresa dal®°ho popisovaáe
         cmp       bx,cx                    ; je jië vy®®° pozice ?
         jb        EditBST4                 ; nalezen° vy®®° pozice

EditBST8:ret

; -----------------------------------------------------------------------------
;        vol†n° ©†dkovÇho menu DI -> BX volba, CY p©eru®en°
; -----------------------------------------------------------------------------

EditBLM  PROC      NEAR

         push      ax

         push      si
         push      dx

         mov       si,di                    ; adresa menu
         call      far ptr Lin0Menu         ; potvrzen° operace

         pop       dx
         pop       si

         call      DBFAdrES                 ; aktualizace adresy okna

         pop       ax
         ret

EditBLM  ENDP

; -----------------------------------------------------------------------------
;        aktualizace adresy okna DS:SI -> ES (uchov†v† p©°znaky !)
; -----------------------------------------------------------------------------

DBFAdrES PROC      NEAR

         pushf
         push      ax

         mov       ax,ds:[si+DBMnuSeg]      ; segment datab†ze
         call      far ptr GetDat           ; nov† adresa datab†ze

         pop       ax
         popf
         ret

DBFAdrES ENDP

; -----------------------------------------------------------------------------
;        F10 menu
; -----------------------------------------------------------------------------
;˛
EditBMen PROC      NEAR

         mov       cs:[EdiBMTTT],si         ; £schova adresy menu

         push      si
         push      dx
         mov       si,offset DBMnVert
         xor       dx,dx

         test      byte ptr ds:[DBFEParm],bit0 ; je editace z†znamu ?
         jz        EdiBMe02                 ; nen° editace z†znamu
         or        dl,bit1                  ; je editace z†znamu

EdiBMe02:test      byte ptr es:[DBFParm],bit0 ; je str†nkovÇ zobrazen° ?
         jnz       EdiBMe03                 ; je str†nkovÇ zobrazen°
         or        dl,bit0                  ; nen° str†nkovÇ zobrazen°

EdiBMe03:test      byte ptr ds:[DBZobPar],bit0 ; zobrazen° vypnuto ?
         jnz       EdiBMe04                 ; zobrazen° vypnuto
         or        dl,bit2                  ; zobrazen° zapnuto

EdiBMe04:call      far ptr SetSwch          ; nastaven° p©ep°naáñ

         call      EditBMnS                 ; nastaven° p©ep°naáñ

         call      far ptr CentMenu
         call      far ptr VertMenu
         pop       dx
         pop       si

EditBMe0:ret

EditBMen ENDP

; -----------------------------------------------------------------------------
;        nastaven° z†kazu poloëek DS:SI (ES=adresa okna !)
; -----------------------------------------------------------------------------

EditBMnS PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      di

; ------ sestaven° p©°znaku

         mov       al,bit3                  ; nen° editace
         test      byte ptr ds:[DBFEParm],bit0 ; je editace ?
         jz        EdiBMnS1                 ; nen° editace
         mov       al,bit2                  ; je editace
EdiBMnS1:test      byte ptr es:[DBFParm],bit1 ; je z†kaz z†pisu ?
         jz        EdiBMnS2                 ; nen° z†kaz z†pisu
         or        al,bit4                  ; je z†kaz z†pisu
EdiBMnS2:mov       cx,es:[DBFMaxZ]
         or        cx,es:[DBFMaxZ+2]
         jnz       EdiBMnS3                 ; jsou nàjak† data
         or        al,bit1                  ; nejsou data
EdiBMnS3:cmp       word ptr es:[DBFNumP],0  ; jsou nàjakÇ poloëky ?
         jne       EdiBMnS4                 ; jsou nàjakÇ poloëky
         or        al,bit0                  ; nejsou poloëky

; ------ nastaven° poloëek

EdiBMnS4:mov       cx,ds:[si+MnuNum]        ; poáet poloëek
         mov       di,ds:[si+MnuBlk]        ; blokovac° tabulka
         mov       bx,offset EdiBMnST       ; tabulka blokov†n°
EdiBMnS5:and       byte ptr ds:[di],not bit1 ; povolen° poloëky
         test      cs:[bx],al               ; je poloëka povolen† ?
         jz        EdiBMnS6                 ; poloëka je povolen† OK
         or        byte ptr ds:[di],bit1    ; z†kaz poloëky
EdiBMnS6:inc       di
         inc       bx
         loop      EdiBMnS5

; ------ n†vrat registrñ

EdiBMnS9:pop       di
         pop       cx
         pop       bx
         pop       ax
         ret

EditBMnS ENDP

; bit 0: 1=nejsou poloëky
; bit 1: 1=nejsou data
; bit 2: 1=je editace
; bit 3: 1=nen° editace
; bit 4: 1=je z†kaz z†pisu

EdiBMnST db        bit0                     ; Browse (Enter)
         db        bit0+bit1+bit2           ; D†le (Ctrl-L)
         db        bit0                     ; Editace (F4)
         db        bit0+bit1+bit2           ; Hledat (F7)
         db        bit0+bit2+bit4           ; Import
         db        bit0+bit1+bit3+bit4      ; Kopie (F5)
         db        bit2+bit4                ; Modifikace (F2)
         db        bit0+bit1+bit2+bit4      ; Nulovat
         db        bit0+bit1+bit3+bit4      ; Obnoven° (Ctrl-U)
         db        bit0                     ; Pole (Ctrl-F2)
         db        bit0+bit1+bit2+bit4      ; Ru®it (F8)
         db        bit0+bit1                ; Skok (F6)
         db        bit0+bit1                ; Text (F3)
         db        bit0+bit2+bit4           ; Vloëit (F9)
         db        bit0+bit1+bit2           ; Export
         db        bit0+bit1                ; Zobraz (Ctrl-Q)

; ------ skok na zvolenou akci

EditBMe1:add       sp,4                     ; zru®en° n†vratovÇ adresy
         mov       bx,ds:[si+MnuAkt]        ; aktivn° zvolen† poloëka
         call      far ptr ClosMnu          ; uzav©en° okna menu
         pop       dx
         pop       si

         call      far ptr JumpBX           ; skok na obsluhu volby
;˛
;         dw        1,                       ; Browse (Enter)
         dw        2,EditBHlL               ; D†le (Ctrl-L)
;         dw        3,                       ; Editace (F4)
         dw        4,EditBHle               ; Hled†n° (F7)
;         dw        5,                       ; Import
         dw        6,EditBKop               ; kopie (F5)
         dw        7,EditBMod               ; modifikace (F2)
         dw        8,EditBNul               ; nulovat
         dw        9,EditBUnd               ; obnoven° (Ctrl-U)
         dw        10,EditBPol              ; nastaven° ®°©ky pole (Ctrl-F2)
         dw        11,EditBRus              ; ru®en° (F8)
         dw        12,EditBSko              ; skok (F6)
         dw        13,EditBMem              ; text (F3)
         dw        14,EditBVlo              ; vloëit (F9)
;         dw        15,                      ; Export
;         dw        16,                      ; Zobraz (Ctrl-Q)

;         dw        0,EditBMe0               ; (to by nemàlo nastat)

EdiBMTTT dw        0                        ; uschovan† adresa definice menu

; ------ p©°znak editace

EditBMe3 PROC      FAR

         xor       dl,bit1                  ; zmàna p©°znaku editace
         call      far ptr SetSwch          ; nastaven° p©ep°naáñ

         push      si
         mov       si,cs:[EdiBMTTT]         ; adresa menu
         call      EditBBEd                 ; zmàna p©°znaku editace
         pop       si

EdiBMe31:call      EditBMnS                 ; nastaven° p©ep°naáñ (ES=okno !)
         cmp       bl," "
         jne       EdiBMe34                 ; je vypnut° okna
EdiBMe32:call      far ptr DispAll          ; novÇ zobrazen° okna
         ret

EditBMe3 ENDP

EdiBMe34:add       sp,4                     ; zru®en° n†vratovÇ adresy
         call      far ptr ClosMnu          ; uzav©en° okna menu
         pop       dx
         pop       si
         ret

; ------ p©°znak str†nkovÇho reëimu

EditBMe5:xor       dl,bit0                  ; zmàna p©°znaku str†nkovÇho reëimu
         call      far ptr SetSwch          ; nastaven° p©ep°naáñ

         xor       byte ptr es:[DBFParm],bit0 ; str†nkovÇ zobrazen°
         jmp       short EdiBMe31

; ------ p©°znak zobrazen°

EditBMe6:xor       dl,bit2                  ; zmàna p©°znaku
         call      far ptr SetSwch          ; nastaven° p©ep°naáñ
         call      EditBQSt                 ; zmàna p©°znaku prohl°ëeáe
         jmp       short EdiBMe31

; -----------------------------------------------------------------------------
;        nastaven° ®°©ky pole (ES=adresa okna)
; -----------------------------------------------------------------------------

EditBPol PROC      NEAR

; ------ test, zda jsou nàjakÇ popisovaáe

         test      byte ptr es:[DBFParm],bit0 ; je str†nkovÇ zobrazen° ?
         jnz       EditBP02                 ; je str†nkovÇ zobrazen°
         cmp       word ptr es:[DBFNumP],0  ; jsou nàjakÇ popisovaáe ?
         jne       EditBPl0                 ; jsou popisovaáe
EditBP02:ret

; ------ £schova registrñ

EditBPl0:push      ax
         push      cx
         push      dx
         push      di
         or        byte ptr ds:[DBFEPar2],bit0 ; je reëim nastaven° ®°©ky

; ------ dek¢dov†n° ®°©ky pole pro zobrazen°

EditBPl1:call      EditPBeg                 ; posun na zaá†tek aktivn° poloëky

         push      es
         mov       di,es:[DBFAktP]          ; aktivn° poloëka
         shl       di,1
         shl       di,1
         shl       di,1                     ; offset indexu
         add       di,es:[DBFAdrP]          ; adresa indexu
         mov       al,es:[di+DBFSirX]       ; ®°©ka pole

         mov       di,offset DBFMnHPS+1     ; buffer k dek¢dov†n°
         push      ds
         pop       es                       ; ES <- datovò segment
         mov       ah,0                     ; barva se neukl†d†
         call      far ptr DekNumB          ; dek¢dov†n° ®°©ky pole
         xchg      ax,di                    ; AX <- konec textu
         sub       ax,offset DBFMnHPS+1     ; dÇlka textu
         mov       ds:[DBFMnHPS],al         ; dÇlka textu
         pop       es

; ------ zobrazen° okna

         call      DBReCalP                 ; p©epoá°t†n° ®°©ky pol°
         call      far ptr DispMnu          ; zobrazen° okna

; ------ vstup znaku z kl†vesnice

         call      DispDBFK                 ; zobrazen° kurzoru
         call      far ptr InpChar          ; vstup znaku z kl†vesnice

; ------ menu kl†ves malÇ n†povàdy

         mov       di,offset DBFMnHMP       ; menu kl†ves
         call      far ptr MenKlHlp         ; menu kl†ves malÇ n†povàdy

; ------ adresa indexu poloëky -> DI

         mov       di,es:[DBFAktP]          ; aktivn° poloëka
         shl       di,1
         shl       di,1
         shl       di,1                     ; offset indexu
         add       di,es:[DBFAdrP]          ; adresa indexu

; ------ skok na obsluhu kl†vesy

         call      far ptr JumpBX

         dw        4d00h,EditBPl2           ; vpravo
         dw        4b00h,EditBPl3           ; vlevo
         dw        4f00h,EditBP32           ; End
         dw        0f09h,EditBPl4           ; TAB
         dw        0f00h,EditBPl5           ; Shift-TAB
         dw        1c0dh,EditBPl7           ; ENTER
         dw        011bh,EditBPl9           ; ESC

         dw        0,EditBPl1

; ------ vpravo - zvàt®en° ®°©ky pole

EditBPl2:cmp       byte ptr es:[di+DBFSirX],255 ; je jië maxim†ln° ®°©ka ?
         je        EditBPl6                 ; je jië maxim†ln° ®°©ka
         inc       byte ptr es:[di+DBFSirX] ; zvò®en° ®°©ky pole
         jmp       short EditBPl6

; ------ vlevo - zmen®en° ®°©ky pole

EditBPl3:cmp       byte ptr es:[di+DBFSirX],0 ; je jië minim†ln° ®°©ka ?
         je        EditBPl6                 ; je jië minim†ln° ®°©ka
         dec       byte ptr es:[di+DBFSirX] ; sn°ëen° ®°©ky pole
         jmp       short EditBPl6

; ------ END - celÇ pole

EditBP32:mov       al,es:[di+DBFParX]       ; parametry
         mov       ah,10                    ; dÇlka pro datum
         test      al,bit3                  ; je to datum ?
         jnz       EditBP34                 ; je to datum
         mov       ah,3                     ; dÇlka pro logickou poloëku
         test      al,bit4                  ; je to logick† poloëka ?
         jnz       EditBP34                 ; je to logick† poloëka
         mov       ah,6                     ; dÇlka pro MEMO pole
         test      al,bit5                  ; je to MEMO pole ?
         jnz       EditBP34                 ; je to MEMO pole
         mov       ah,8                     ; dÇlka pro áas
         test      al,bit6                  ; je to áas ?
         jnz       EditBP34                 ; je to áas
         mov       ah,es:[di+DBFDelX]       ; dÇlka pole pro text a á°slo

EditBP34:mov       es:[di+DBFSirX],ah       ; nastaven° ®°©ky pole
         jmp       short EditBPl6

; ------ TAB - dal®° poloëka

EditBPl4:inc       word ptr es:[DBFAktP]    ; zvò®en° aktivn° poloëky
         mov       ax,es:[DBFAktP]          ; aktivn° poloëka
         cmp       ax,es:[DBFNumP]          ; p©ekroáen poáet poloëek ?
         jb        EditBPl6                 ; je to OK
         mov       word ptr es:[DBFAktP],0  ; omezen° na 0
         jmp       short EditBPl6

; ------ Shift-TAB - p©ede®l† poloëka

EditBPl5:dec       word ptr es:[DBFAktP]    ; sn°ëen° aktivn° poloëky
         jns       EditBPl6                 ; je to OK
         mov       ax,es:[DBFNumP]          ; poáet poloëek
         dec       ax
         mov       es:[DBFAktP],ax          ; posledn° aktivn° poloëka
EditBPl6:jmp       EditBPl1

; ------ ENTER - uloëen° nastaven°

EditBPl7:mov       bx,es:[DBFAdrP]          ; adresa indexñ popisovaáñ
         mov       cx,es:[DBFNumP]          ; poáet popisovaáñ
EditBPl8:mov       di,es:[bx+DBFNamX]       ; adresa popisovaáe
         mov       al,es:[bx+DBFSirX]       ; ®°©ka pole
         mov       ah,al
         add       ah,DBFPSirC              ; kontroln° bajt
         mov       es:[di+DBFPSirk],ax      ; uloëen° ®°©ky pole
         add       bx,DBFX                  ; dal®° popisovaá
         loop      EditBPl8                 ; dal®° popisovaá

         or        byte ptr ds:[DBFEParm],bit7 ; datum v z†hlav° se nemàn°
         mov       ax,es:[DBFIdent]         ; identifik†tor souboru
         call      far ptr GetDFile         ; naáten° data a áasu
         jc        EditBPl9                 ; chyba
         call      far ptr ZapKrit          ; zapnut° kritickÇ sekce
         call      far ptr HlavDBF          ; z†pis z†hlav° na disk
         call      far ptr SetDFile         ; navr†cen° data a áasu
         call      far ptr VypKrit          ; vypnut° kritickÇ sekce

; ------ n†vrat registrñ

EditBPl9:and       byte ptr ds:[DBFEPar2],not bit0 ; ukonáen° reëimu nastaven°
         pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

EditBPol ENDP

; -----------------------------------------------------------------------------
;        p©epoá°t†n° ®°©ky pol° (definice okna menu SI)
; -----------------------------------------------------------------------------

DBReCalP PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      es

; ------ adresa definice okn

         call      DBFAdrES                 ; aktualizace adresy okna -> ES

; ------ p©°prava k p©epoátu poloëek

         mov       cx,es:[DBFNumP]          ; poáet poloëek
         jcxz      DBReClP9                 ; nen° ë†dn† poloëka
         dec       cx                       ; poáet oddàlovaáñ
         mov       es:[DBFSirR],cx          ; á°taá celkovÇ ®°©ky okna
         inc       cx
         mov       bx,es:[DBFAdrP]          ; ukazatel popisovaáñ

; ------ p©°prava dÇlky poloëky

DBReClP2:mov       ax,es:[bx+DBFSirX]       ; ®°©ka pole poloëky
         add       es:[DBFSirR],ax          ; á°taá celkovÇ ®°©ky ©†dku
         add       bx,DBFX                  ; adresa dal®°ho popisovaáe
         loop      DBReClP2                 ; dal®° popisovaá

; ------ n†vrat registrñ

DBReClP9:pop       es
         pop       cx
         pop       bx
         pop       ax
         ret

DBReCalP ENDP

; -----------------------------------------------------------------------------
;        Ctrl-Q: p©ep°naá rychlÇho zobrazen°
; -----------------------------------------------------------------------------

EditBQSt:xor       byte ptr ds:[DBZobPar],bit0   ; zmàna p©°znaku
         call      EditBQVD                 ; zru®en° starÇho bufferu MEMO
         ret

; -----------------------------------------------------------------------------
;        obsluha rychlÇho zobrazen° okna ES (vol†no p©i áek†n° na kl†vesu)
; -----------------------------------------------------------------------------
;˛
EditBQVw PROC      NEAR

; ------ test, zda je funkce povolena

         test      byte ptr ds:[DBZobPar],bit0+bit1+bit2 ; funkce povolena ?
         jz        EditBQV1                 ; funkce je povolena OK
EditBQV0:ret

; ------ test, zda byl zmànàn aktivn° z†znam

EditBQV1:mov       ax,es:[DBFAktZ+2]        ; aktivn° z†znam HIGH
         cmp       ax,word ptr ds:[DBZobOld+2] ; zmànàn z†znam ?
         jne       EditBQV2                 ; aktivn° z†znam byl zmànàn
         mov       ax,es:[DBFAktZ]          ; aktivn° z†znam LOW
         cmp       ax,word ptr ds:[DBZobOld] ; zmànàn z†znam ?
         je        EditBQV0                 ; aktivn° z†znam nezmànàn

; ------ test, zda je jië áas k obsluze

EditBQV2:call      far ptr TestQVw          ; test rychloprohl°ëen°
         jc        EditBQV0                 ; nen° pot©eba zobrazen°

; ------ zru®en° starÇho bufferu MEMO

         call      EditBQVD                 ; zru®en° starÇho bufferu MEMO

; ------ £schova aktu†ln°ho z†znamu

         mov       ax,es:[DBFAktZ]          ; aktivn° z†znam LOW
         mov       word ptr ds:[DBZobOld],ax ; £schova z†znamu
         mov       ax,es:[DBFAktZ+2]        ; aktivn° z†znam HIGH
         mov       word ptr ds:[DBZobOld+2],ax

; ------ poskytnut° poloëky MEMO -> DX:AX

         call      GetPMemo                 ; poskytnut° poloëky MEMO
         jc        EditBQV8
         mov       cx,ax
         or        cx,dx                    ; je z†znam platnò ?
         jcxz      EditBQV8                 ; z†znam nen° platnò

; ------ p©°prava parametrñ pro MEMO

         mov       es:[DBFPolBT],ax         ; poá†teán° poloëka MEMO
         mov       es:[DBFPolBT+2],dx
         and       byte ptr es:[DBFParm],not bit6+bit7 ; nulov†n° p©°znakñ MEMO

; ------ otev©en° souboru MEMO -> AX = identifik†tor

         call      GetIMemo                 ; poskytnut° identifik†toru MEMO
         jc        EditBQV8                 ; chyba otev©en° souboru MEMO
         xchg      ax,bx                    ; BX <- identifik†tor MEMO

; ------ otev©en° okna editoru

         call      far ptr OpenText         ; otev©en° bufferu textu
         jc        EditBQV8                 ; chyba pamàti
         or        byte ptr es:[TextParm],bit6 ; neë†dat heslo
         mov       ds:[DBZobSeg],ax         ; segment okna

; ------ naáten° textu MEMO (adresa ES:DI, velikost CX, datab†ze DX)

         xchg      ax,bx                    ; AX <- identifik†tor, BX <- editor
         push      ax
         mov       ax,ds:[si+DBMnuSeg]      ; segment datab†ze
         call      far ptr GetSgAdr         ; adresa segmentu -> DX
         pop       ax
         call      ReadEMem                 ; naáten° poloëky MEMO
         jc        EditBQV8                 ; chyba

; ------ inicializace parametrñ MEMO

         xchg      ax,bx                    ; AX <- segment editoru
         call      far ptr InitText         ; inicializace textu
         xchg      ax,bx
         jc        EditBQV8                 ; nen° text

; ------ zobrazen° menu

         and       byte ptr ds:[DBZobPar],not bit4 ; je text MEMO pole
EditBQV8:call      far ptr DispMnu          ; zobrazen° okna
EditBQV9:ret

EditBQVw ENDP

; -----------------------------------------------------------------------------
;        zru®en° segmentu MEMO pole (obnov° adresu ES okna DS:SI !)
; -----------------------------------------------------------------------------

EditBQVD PROC      NEAR

         push      ax

         or        byte ptr ds:[DBZobPar],bit4 ; nen° text MEMO pole

         mov       ax,ds:[DBZobSeg]         ; segment bufferu
         call      far ptr DelSeg           ; zru®en° segmentu
         mov       ds:[DBZobSeg],ax         ; p©°znak zru®en°

         call      DBFAdrES                 ; aktualizace adresy okna -> ES

         pop       ax
         ret

EditBQVD ENDP

; -----------------------------------------------------------------------------
;        uzav©en° souboru MEMO (okno DS:SI)
; -----------------------------------------------------------------------------

ClosBMem PROC      NEAR

         push      ax
         push      es

         call      DBFAdrES                 ; adresa okna -> ES
         mov       ax,es:[DBFIdntT]         ; identifik†tor souboru MEMO
         call      far ptr ClosFile         ; uzav©en° souboru
         mov       es:[DBFIdntT],ax         ; zru®en° p©°znaku otev©en°

         pop       es
         pop       ax
         ret

ClosBMem ENDP

; *****************************************************************************
;
;                         Obsluha MEMO pole
;
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=definice okna datab†ze
;        ES=segment datab†ze
; VùSTUP: ES=novò segment datab†ze
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) adresa definice datab†ze
;                   SS:[BP-4] (2) á°slo segmentu datab†ze
;                   SS:[BP-6] (2) adresa segmentu datab†ze (p©echodnà)
;                   SS:[BP-8] (2) adresa definice editoru
;                   SS:[BP-10] (2) á°slo segmentu editoru
;                   SS:[BP-12] (2) adresa segmentu editoru
;                   SS:[BP-14] (2) identifik†tor souboru MEMO
; *****************************************************************************
;˛
EditBMem PROC      NEAR

; ------ test, zda je MEMO pole

         test      byte ptr es:[DBFParm],bit4 ; je MEMO soubor ?
         jnz       EditBMm0                 ; je MEMO soubor
         ret

; ------ £schova registrñ

EditBMm0:call      UlozDBF                  ; uloëen° editovanÇho bufferu
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         mov       bp,sp
         sub       sp,14

; ------ poskytnut° á°sla poloëky MEMO

         mov       ss:[bp-2],si             ; adresa definice datab†ze
         mov       ax,ds:[si+DBMnuSeg]      ; segment datab†ze
         mov       ss:[bp-4],ax             ; á°slo segmentu datab†ze
         call      GetPMemo                 ; poskytnut° poloëky MEMO
         jc        EditBMm1                 ; chyba
         mov       es:[DBFPolBT],ax         ; poá†teán° poloëka MEMO
         mov       es:[DBFPolBT+2],dx
         and       byte ptr es:[DBFParm],not bit6+bit7 ; nulov†n° p©°znakñ MEMO

; ------ otev©en° souboru MEMO

         call      GetIMemo                 ; poskytnut° identifik†toru MEMO
         jnc       EditBMm2                 ; soubor otev©en/vytvo©en OK
EditBMm1:jmp       EditBMm9                 ; chyba
EditBMm2:mov       ss:[bp-14],ax            ; identifik†tor souboru MEMO

; ------ korekce á°sla poloëky MEMO, je-li mimo rozsah

         mov       ax,es:[DBFPolBT]         ; poá†teán° poloëka MEMO
         mov       dx,es:[DBFPolBT+2]
         cmp       dx,es:[DBFLastT+2]
         jne       EdiBMm23
         cmp       ax,es:[DBFLastT]
EdiBMm23:jb        EdiBMm24                 ; á°slo bloku MEMO je OK
         xor       ax,ax
         mov       es:[DBFPolBT],ax         ; zru®en° á°sla poloëky
         mov       es:[DBFPolBT+2],ax
         mov       es:[DBFPolST],ax         ; je konec souboru

; ------ otev©en° okna editoru

EdiBMm24:mov       si,offset MemoMnu
         mov       ss:[bp-8],si             ; adresa definice editoru
         call      far ptr OpenText         ; otev©en° bufferu textu
         jc        EditBMm1                 ; chyba pamàti
         mov       ds:[si+EdMnuSeg],ax      ; segment okna
         mov       ss:[bp-10],ax            ; á°slo segmentu editoru
         mov       ss:[bp-12],es            ; adresa segmentu

; ------ inicializace parametrñ editoru MEMO

         mov       ax,ss:[bp-4]             ; á°slo segmentu datab†ze
         call      far ptr GetSgAdr         ; adresa segmentu datab†ze
         call      InitEMem                 ; inicial. parametrñ editoru MEMO

; ------ naáten° textu MEMO (adresa ES:DI, velikost CX, datab†ze DX)

         mov       ax,ss:[bp-14]            ; identifik†tor souboru MEMO
         mov       bx,ss:[bp-10]            ; segment okna editoru
         call      ReadEMem                 ; naáten° poloëky MEMO
         jc        EditBMm1

; ------ inicalizace textu MEMO pole

         xchg      ax,bx
         call      far ptr InitText         ; inicializace textu
         xchg      ax,bx
         jc        EditBMm1                 ; chyba hesla

; ------ parametry aktivn° poloëky (CX=poáet bajtñ naátenÇho textu)

         mov       ax,ss:[bp-4]             ; segment datab†ze
         call      far ptr GetDat           ; adresa datab†ze
         xor       bx,bx                    ; nen° ë†dnò blok
         mov       ax,es:[DBFPolBT]         ; poá†teán° poloëka LOW
         or        ax,es:[DBFPolBT+2]       ; je poloëka p©idàlena ?
         jz        EdiBMm32                 ; poloëka nen° p©idàlena

         xchg      ax,cx                    ; AX <- velikost dat
         xor       dx,dx                    ; DX <- 0
         mov       cx,es:[DBFBlokT]         ; velikost bloku
         add       ax,cx                    ; p©iáten° bloku - 1 + (1 bajt=EOF)
         adc       dx,0
         test      byte ptr es:[DBFParm],bit3 ; je form†t DBASE ?
         jnz       EditBMm3                 ; je form†t DBASE
         add       ax,7                     ; p©iáten° z†hlav° pro FOXPRO - 1
         adc       dx,0
EditBMm3:div       cx                       ; vòpoáet poátu blokñ
         mov       bx,ax                    ; BX <- £schova poátu blokñ
         mul       cx                       ; zaokrouhlen† velikost bloku

         add       bx,es:[DBFPolBT]         ; p©iáten° poá†teán° poloëky
         adc       dx,es:[DBFPolBT+2]

         cmp       dx,es:[DBFLastT+2]       ; je to posledn° z†znam ?
         jne       EdiBMm31
         cmp       bx,es:[DBFLastT]
EdiBMm31:jbe       EdiBMm32                 ; nen° to posledn° z†znam
         xor       ax,ax                    ; AX <- 0 je to posledn° z†znam

EdiBMm32:mov       es:[DBFPolST],ax         ; velikost m°sta pro poloëku

; ------ otev©en° okna menu

         mov       si,offset MemoMnu
         call      far ptr OpenMnu          ; otev©en° okna menu

; ------ editace okna MEMO

EditBMm6:mov       si,offset MemoMnu
         call      far ptr KorEMnu          ; korekce okna
         test      byte ptr ds:[TextEPar],bit3
         jz        EdiBMm62
         call      far ptr DispAll
         jmp       short EdiBMm64
EdiBMm62:call      far ptr DispMnu          ; zobrazen° okna
EdiBMm64:
         call      far ptr InpChar

         push      di
         mov       di,offset TxtMnHM1       ; menu kl†ves malÇ n†povàdy
         call      far ptr MenKlHlp         ; obsluha menu kl†ves
         pop       di

EdiBMm65:mov       ax,ds:[si+EdMnuSeg]
         call      far ptr GetDat           ; adresa segmentu okna

         and       byte ptr ds:[TextEPar],not bit0+bit1+bit2+bit3

         cmp       bl,27
         je        EditBMm7

         cmp       bx,3c00h
         jne       EdiBMm67

         mov       dx,ss:[bp-4]             ; segment datab†ze
         mov       bx,ss:[bp-10]            ; segment okna editoru
         call      WritEMem                 ; uloëen° souboru
         jmp       short EditBMm6

EdiBMm67:cmp       bx,4400h                 ; F10 menu
         je        EdiBMm68
         cmp       bx,MousXKod+MousXMP      ; stisk st©edn°ho tlaá°tka my®i
         je        EdiBMm68                 ; obsluha menu

         call      far ptr EditEMnu         ; obsluha editoru
EdiBMm69:jmp       short EditBMm6

EdiBMm68:call      far ptr ZapisMnX         ; obsluha menu
         jc        EdiBMm69
         jmp       short EdiBMm65           ; je kl†vesa v BX

; ------ test, zda se m† text uloëit

EditBMm7:test      byte ptr es:[TextParm],bit1 ; text modifikov†n ?
         jz        EdiBMm76                 ; nebyl modifikov†n

         mov       si,offset ZUSMnLin
         call      far ptr Lin0Menu         ; volba operace
         jc        EdiBMm69                 ; p©eru®en° operace

         dec       bx                       ; uloëen° souboru ?
         jnz       EdiBMm76                 ; p©eru®en° operace
         mov       si,offset MemoMnu
         mov       dx,ss:[bp-4]             ; segment datab†ze
         mov       bx,ss:[bp-10]            ; segment okna editoru
         call      WritEMem                 ; uloëen° souboru
         jc        EdiBMm69                 ; chyba

; ------ test, zda bylo zmànàno á°slo poloëky

EdiBMm76:mov       ax,ss:[bp-4]             ; segment datab†ze
         call      far ptr GetDat           ; adresa segmentu datab†ze
         mov       si,ss:[bp-2]             ; adresa definice datab†ze
         test      byte ptr es:[DBFParm],bit7 ; bylo zmànàno á°slo MEMO ?
         jz        EdiBMm78                 ; nebylo zmànàno á°slo MEMO

         call      GetPMemo                 ; poskytnut° poloëky MEMO
         jc        EdiBMm78

         push      di                       ; poá†teán° adresa z†znamu
         mov       di,bx                    ; DI <- poá†teán° adresa pole MEMO
         mov       cx,10
         mov       al," "
         cld
         rep       stosb                    ; inicializaán° vymaz†n° pole

         mov       ax,es:[DBFPolBT]         ; poá†teán° poloëka pole
         mov       dx,es:[DBFPolBT+2]
         mov       cx,ax
         or        cx,dx                    ; je pole p©idàleno ?
         jnz       EdiBMm77                 ; pole je p©idàleno OK
         mov       ax,es:[DBFLastT]         ; jinak je to konec souboru
         mov       dx,es:[DBFLastT+2]
EdiBMm77:xor       bx,bx                    ; nen° barva ani oddàlovaá
         call      far ptr DekNumD          ; dek¢dov†n° á°sla MEMO pole

         pop       di                       ; adresa z†znamu

         mov       ax,es:[DBFLast0]
         mov       dx,es:[DBFLast0+2]
         mov       es:[DBFLastT],ax
         mov       es:[DBFLastT+2],dx

         mov       dx,es:[DBFAktZ+2]        ; á°slo z†znamu HIGH
         mov       ax,es:[DBFAktZ]          ; á°slo z†znamu LOW

         cmp       dx,es:[DBFMaxZ+2]        ; je to novò z†znam ?
         jne       EdiBMm7A
         cmp       ax,es:[DBFMaxZ]
         jne       EdiBMm7A                 ; nen° to novò z†znam

         or        byte ptr ds:[DBFEParm],bit1 ; p©°znak modifikace bufferu
         call      UlozDBF                  ; uloëen° novÇho z†znamu
         jmp       short EdiBMm79           ; z†hlav° je jië aktualizov†no

EdiBMm7A:call      far ptr SetDBF           ; uloëen° z†znamu na disk
         mov       ax,es:[DBFIdent]         ; identifik†tor souboru
         call      far ptr FlshFile         ; uloëen° zmàn na disk

; ------ aktualizace z†hlav° souboru

EdiBMm78:test      byte ptr es:[DBFParm],bit6 ; byl z†pis do MEMO ?
         jz        EdiBMm79                 ; nebyl z†pis do MEMO
         call      far ptr HlavDBF          ; uloëen° z†hlav° DBF

; ------ uzav©en° okna editoru

EdiBMm79:mov       si,offset MemoMnu
         call      far ptr ClosMnu
EditBMm9:mov       ax,word ptr ds:[MemoMnu+EdMnuSeg] ; segment bufferu
         call      far ptr DelSeg           ; zru®en° segmentu
         mov       word ptr ds:[MemoMnu+EdMnuSeg],ax

; ------ n†vrat registrñ

         mov       sp,bp
         pop       bp
         pop       di
         pop       si
         call      DBFAdrES                 ; aktualizace adresy okna -> ES
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      EdiBEBeg                 ; zah†jen° editace
         mov       word ptr ds:[DBZobOld+2],-1 ; pot©eba naáten° MEMO
         ret

EditBMem ENDP

; -----------------------------------------------------------------------------
;        uloëen° textu MEMO
; -----------------------------------------------------------------------------
; VSTUP: BX=á°slo segmentu editoru MEMO
;        DX=á°slo segmentu datab†ze
; VùSTUP: CY=chyba
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) á°slo segmentu editoru MEMO
;                   SS:[BP-4] (2) á°slo segmentu datab†ze
;                   SS:[BP-6] (2) adresa segmentu editoru MEMO
;                   SS:[BP-8] (2) adresa segmentu datab†ze
;                   SS:[BP-10] (2) identifik†tor souboru MEMO
;                   SS:[BP-12] (2) dÇlka ©†dku s p©ep°naái
; -----------------------------------------------------------------------------
;˛
WritEMem PROC      NEAR

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
         sub       sp,12 + 256

; ------ p©°prava lok†ln°ch promànnòch

         mov       ss:[bp-2],bx             ; á°slo segmentu MEMO
         mov       ss:[bp-4],dx             ; á°slo segmentu datab†ze
         xchg      ax,dx                    ; AX <- á°slo segmentu datab†ze
         call      far ptr GetDat           ; adresa segmentu datab†ze
         mov       ss:[bp-8],es             ; adresa segmentu datab†ze
         xchg      ax,bx                    ; AX <- á°slo segmentu editoru MEMO
         call      far ptr GetSgAdr         ; adresa segmentu editoru MEMO
         mov       ss:[bp-6],dx             ; adresa segmentu MEMO
         mov       bx,es:[DBFIdntT]         ; identifik†tor souboru MEMO
         mov       ss:[bp-10],bx            ; identifik†tor souboru MEMO

; ------ test, zda je z†kaz z†pisu do MEMO pole

         test      byte ptr es:[DBFParm],bit5 ; je z†kaz z†pisu do MEMO ?
         jnz       WritEMm1                 ; je z†kaz z†pisu do MEMO

; ------ p©°prava textu p©ep°naáñ do bufferu v z†sobn°ku (AX=segment editoru)

         push      ss
         pop       es                       ; ES <- segment bufferu
         mov       di,sp                    ; DI <- adresa bufferu
         call      far ptr ZapisSwc         ; p©°prava p©ep°naáñ
         inc       di
         inc       di                       ; p©eskoáen° CR/LF
         sub       di,sp                    ; dÇlka textu
         mov       ss:[bp-12],di            ; dÇlka textu ©†dku

; ------ test, zda se m† text uloëit

         mov       es,dx                    ; segment editoru MEMO
         jmp       short WritEMm2
;         test      byte ptr es:[TextParm],bit1 ; byl text modifikov†n ?
;         jnz       WritEMm2                 ; text byl modifikov†n
WritEMm1:jmp       WritEMm9

; ------ p©°prava poëadovanÇ velikosti poloëky

WritEMm2:mov       ax,es:[TextBNum]         ; poáet bajtñ v bufferu
         add       ax,ss:[bp-12]            ; p©iáten° textu p©ep°naáñ
         mov       es,ss:[bp-8]             ; adresa segmentu datab†ze
         test      byte ptr es:[DBFParm],bit3 ; je form†t DBASE ?
         jnz       WritEMm3                 ; je form†t DBASE
         add       ax,7                     ; p©iáten° z†hlav° FOXPRO - 1

; ------ test, zda je ve starÇ poloëce dost m°sta k uloëen° textu

WritEMm3:xor       dx,dx                    ; DX <- 0
         cmp       es:[DBFPolST],dx         ; je konec souboru ?
         je        WritEMm4                 ; je konec souboru
         mov       cx,es:[DBFBlokT]         ; velikost bloku MEMO
         add       ax,cx                    ; p©iáten° velikosti bloku MEMO
         jc        WriEMm31                 ; je p©eteáen°
         cmp       ax,-1-TextBBeg
         jb        WriEMm32                 ; nen° p©eteáen°
WriEMm31:mov       ax,-1-TextBBeg           ; omezen° velikosti bloku dolñ
WriEMm32:div       cx
         mul       cx                       ; zaokrouhlen† velikost blokñ
         cmp       ax,es:[DBFPolST]         ; je dost m°sta ?
         jbe       WritEMm4                 ; je dost m°sta

         mov       es:[DBFPolBT],dx         ; jinak zru®en° starÇ poloëky
         mov       es:[DBFPolBT+2],dx
         mov       es:[DBFPolST],dx         ; p©°znak, ëe je konec souboru

; ------ nastaven° ukazatele v souboru

WritEMm4:mov       bx,es:[DBFPolBT]         ; á°slo poá†teán° poloëky
         mov       dx,es:[DBFPolBT+2]
         mov       ax,bx
         or        ax,dx                    ; je poloëka definovan† ?
         jnz       WriEMm42                 ; poloëka je definovan†
         or        byte ptr es:[DBFParm],bit7 ; á°slo MEMO bylo zmànàno
         mov       bx,es:[DBFLastT]         ; á°slo z†znamu konce souboru
         mov       dx,es:[DBFLastT+2]
WriEMm42:mov       ax,ss:[bp-10]            ; identifik†tor souboru
         call      SetUPMem                 ; nastaven° ukazatele v souboru
         jnc       WritEMm5
WriEMm49:jmp       WritEMm9                 ; chyba

; ------ p©°prava k z†pisu dat do souboru

WritEMm5:mov       bx,es:[DBFBlokT]         ; velikost bloku MEMO
         test      byte ptr es:[DBFParm],bit3 ; je form†t DBASE ?
         jz        WritEMm6                 ; je form†t FOXPRO

; ------ z†pis dat ve form†tu DBASE (nelze zak¢dovat heslem !)

         push      ss
         pop       es
         mov       si,sp                    ; buffer v z†sobn°ku
         mov       cx,ss:[bp-12]            ; dÇlka ©†dku s p©ep°naái
         call      far ptr WritFile         ; z†pis p©ep°naáñ

         mov       es,ss:[bp-6]             ; adresa segmentu editoru
         mov       cx,es:[TextBNum]         ; poáet bajtñ v bufferu
         mov       si,TextBBEg              ; zaá†tek bufferu textu
         call      far ptr WritFile         ; z†pis dat souboru
         jc        WriEMm49                 ; chyba
         mov       cx,1
         dec       si
         mov       byte ptr es:[si],EOF
         call      far ptr WritFile         ; z†pis koncovÇho EOF
         jc        WriEMm49                 ; chyba
         add       cx,ss:[bp-12]
         add       cx,es:[TextBNum]         ; poáet zapsanòch bajtñ
         jmp       WritEMm7

; ------ z†pis dat ve form†tu FOXPRO

WritEMm6:mov       si,TextDBFH              ; z†hlav° poloëky MEMO
         mov       es,ss:[bp-6]             ; adresa segmentu editoru
         mov       cx,es:[TextBNum]         ; poáet bajtñ v bufferu
         add       cx,ss:[bp-12]            ; p©iáten° ©†dku p©ep°naáñ
         mov       ax,cx                    ; AX <- poáet bajtñ v bufferu
         add       ax,7                     ; p©iáten° z†hlav° 8 bajtñ - 1
         add       ax,bx                    ; p©iáten° velikosti bloku MEMO
         jc        WriEMm61                 ; je p©eteáen°
         cmp       ax,-1-TextBBeg
         jb        WriEMm62                 ; nen° p©eteáen°
WriEMm61:mov       ax,-1-TextBBeg           ; omezen° velikosti bloku dolñ
WriEMm62:div       bx
         mul       bx                       ; zaokrouhlen† velikost blokñ
         sub       ax,8                     ; maxim†ln° velikost dat
         cmp       ax,cx
         jae       WriEMm63
         xchg      ax,cx                    ; CX <- omezen° velikosti dat

WriEMm63:mov       ax,cx                    ; AX <- velikost dat
         mov       word ptr es:[si],0
         mov       word ptr es:[si+2],100h  ; identifik†tor "1"
         mov       word ptr es:[si+4],0     ; velikost dat HIGH
         xchg      ah,al                    ; oprava po©ad° bajtñ velikosti
         mov       es:[si+6],ax             ; velikost dat
         mov       ax,ss:[bp-10]            ; identifik†tor souboru

         push      cx
         mov       cx,8                     ; dÇlka z†hlav°
         call      far ptr WritFile         ; z†pis z†hlav°
         pop       cx

         push      ss
         pop       es
         mov       si,sp
         push      cx
         mov       cx,ss:[bp-12]
         call      far ptr WritFile         ; z†pis ©†dku p©ep°naáñ
         pop       cx

         mov       es,ss:[bp-6]             ; adresa segmentu editoru
         sub       cx,ss:[bp-12]            ; bez ©†dku p©ep°naáñ
         mov       si,TextBBEg              ; zaá†tek bufferu textu
         mov       di,si                    ; zaá†tek dat
         call      far ptr ZapZakod         ; zak¢dov†n° dat
         call      far ptr WritFile         ; z†pis dat souboru
         pushf
         call      far ptr ZapDekod         ; dek¢dov†n° textu
         popf
         jnc       WriEMm4B
WriEMm4A:jmp       WritEMm9                 ; chyba

WriEMm4B:add       cx,ss:[bp-12]
         add       cx,8

; ------ doplnàn° bloku na plnou velikost

WritEMm7:mov       es,ss:[bp-8]             ; adresa segmentu datab†ze
         xchg      ax,cx                    ; AX <- velikost zapsanòch dat
         xor       dx,dx
         div       bx                       ; vòpoáet zbytku v posledn°m bloku
         or        dx,dx                    ; zbylo nàco ?
         jz        WriEMm72                 ; nezbylo nic
         sub       bx,dx                    ; zbytek m°sta v posledn°m bloku
         mov       cx,bx                    ; CX <- velikost zbytku dat
         mov       di,DBFBuffT              ; buffer pro MEMO soubor
         mov       si,di                    ; adresa bufferu
         mov       al,0                     ; nulovac° bajt
         cld
         push      cx
         rep       stosb                    ; vynulov†n° bufferu
         pop       cx
         mov       ax,ss:[bp-10]            ; identifik†tor souboru
         call      far ptr WritFile         ; z†pis zbytku dat
         jc        WriEMm4A

; ------ z†pis z†hlav°, pokud to je posledn° poloëka v souboru

WriEMm72:cmp       word ptr es:[DBFPolST],0 ; je to konec souboru ?
         jne       WriEMm76                 ; nen° to konec souboru

         mov       di,DBFBuffT              ; buffer pro MEMO
         mov       si,di
         xor       ax,ax
         mov       cx,es:[DBFBlokT]         ; velikost bloku MEMO
         cld
         rep       stosb                    ; vynulov†n° bufferu pro MEMO

         mov       ax,ss:[bp-10]            ; identifik†tor souboru
         call      far ptr WritFile         ; useknut° konce souboru (CX=0 !)
         call      far ptr GetUFile         ; poskytnut° ukazatele v souboru
         jc        WritEMm9

         mov       bx,es:[DBFBlokT]         ; velikost bloku MEMO
         xor       ax,ax
         xchg      ax,dx                    ; AX <- ukazatel konce HIGH
         div       bx                       ; poáet poloëek HIGH
         xchg      ax,cx                    ; AX <- ukazatel konce LOW
         div       bx                       ; CX:AX = poáet poloëek v souboru
         mov       es:[si],ax
         mov       es:[si+2],cx             ; poáet poloëek pro form†t DBASE
         mov       es:[DBFLast0],ax
         mov       es:[DBFLast0+2],cx

         test      byte ptr es:[DBFParm],bit3 ; je form†t DBASE ?
         jnz       WriEMm74                 ; je form†t DBASE
         xchg      al,ah
         xchg      cl,ch
         xchg      bl,bh
         mov       es:[si],cx               ; poáet poloëek pro form†t FOXPRO
         mov       es:[si+2],ax
         mov       es:[si+6],bx             ; velikost bloku MEMO

WriEMm74:mov       cx,es:[DBFBlokT]         ; velikost z†hlav° souboru
         mov       ax,ss:[bp-10]            ; identifik†tor souboru
         call      far ptr ResFile          ; ukazatel na zaá†tek souboru
         call      far ptr WritFile         ; z†pis novÇho z†hlav° souboru

; ------ oprava p©°znakñ

WriEMm76:mov       ax,ss:[bp-10]            ; identifik†tor souboru
         call      far ptr FlshFile         ; uloëen° zmàn na disk
         or        byte ptr es:[DBFParm],bit6 ; byl z†pis do MEMO
         mov       es,ss:[bp-6]             ; adresa segmentu editoru
         and       byte ptr es:[TextParm],not bit1 ; zru®en° p©°znaku modifikace
         or        byte ptr ds:[TextEPar],bit2 ; zobrazen° okna

; ------ n†vrat registrñ

WritEMm9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

WritEMem ENDP

; -----------------------------------------------------------------------------
;        naáten° poloëky MEMO
; -----------------------------------------------------------------------------
; VSTUP: AX=identifik†tor souboru MEMO
;        BX=á°slo segmentu editoru MEMO
;        CX=velikost bufferu k naáten° poloëky MEMO
;        DX=adresa segmentu datab†ze
;        ES:DI=buffer k naáten° poloëky MEMO
; VùSTUP: CX=velikost naátenòch dat do bufferu (p©i chybà nedefinov†no)
;         CY=chyba áten°
; -----------------------------------------------------------------------------

ReadEMem PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      dx
         push      si
         push      di

; ------ test, zda je poloëka platn†

         push      ax
         push      es

         mov       es,dx
         mov       ax,es:[DBFPolBT]
         or        ax,es:[DBFPolBT+2]

         pop       es
         pop       ax

         jnz       ReadEMm0                 ; je platn† poloëka MEMO

         mov       dx,di                    ; DX <- £schova zaá†tku bufferu
         jmp       ReadEMm7

; ------ nastaven° ukazatele v souboru

ReadEMm0:push      bx
         push      dx
         push      es

         mov       es,dx                    ; ES <- adresa segmentu datab†ze
         mov       bx,es:[DBFPolBT]         ; poá†teán° poloëka LOW
         mov       dx,es:[DBFPolBT+2]       ; poá†teán° poloëka HIGH
         call      SetUPMem                 ; nastaven° ukazatele v souboru

         pop       es
         pop       dx
         pop       bx

; ------ test, zda je form†t DBASE

         push      ds
         mov       ds,dx                    ; DS <- adresa segmentu datab†ze
         test      byte ptr ds:[DBFParm],bit3 ; je form†t DBASE ?
         pop       ds
         mov       dx,di                    ; DX <- £schova zaá†tku bufferu
         jz        ReadEMm2                 ; je form†t FOXPRO

         or        byte ptr es:[TextParm],bit5 ; je z†kaz hesla

; ------ naáten° dat ve form†tu DBASE

ReadEMm1:cmp       cx,512
         jae       ReadEM10
         or        byte ptr es:[TextParm],bit0 ; z†kaz z†pisu (nen° celò text)
         jmp       ReadEMm7

ReadEM10:mov       byte ptr es:[di],EOF
         push      cx
         mov       cx,512
         call      far ptr ReadFile         ; naáten° sektoru dat
         pop       cx
         jc        ReaEMm22

         sub       cx,512

         push      ax
         push      cx
         mov       cx,512
         cld
         mov       al,EOF                   ; hledanò znak
         repne     scasb                    ; nalezen° znaku EOF
         pop       cx
         pop       ax
         jne       ReadEMm1                 ; dal®° blok dat
         dec       di                       ; zru®en° znaku EOF

         push      ax
         push      cx
         push      di

         mov       ax,0a8dh                 ; màkkò konec ©†dku CR/LF
         mov       cx,di
         mov       di,dx
         dec       di
         sub       cx,dx
ReadEM11:jcxz      ReadEM14
ReadEM12:inc       di
         cmp       word ptr es:[di],AX
         loopne    ReadEM12
         jne       ReadEM14
         mov       word ptr es:[di],0a0dh
         jmp       short ReadEM11

ReadEM14:pop       di
         pop       cx
         pop       ax
         jmp       short ReadEMm7

; ------ p©°prava parametrñ pro form†t FOXPRO

ReadEMm2:mov       word ptr es:[di+4],0
         mov       word ptr es:[di+6],0
         push      cx
         mov       cx,8                     ; z†hlav° 8 bajtñ
         call      far ptr ReadFile         ; naáten° z†hlav° 8 bajtñ
         pop       cx
ReaEMM22:jc        ReadEMm9                 ; chyba
         sub       cx,8
         jc        ReadEMm9

         push      ax
         mov       ax,-1                    ; asi tak velikost z†znamu
         cmp       word ptr es:[di+4],0     ; je v°ce neë 64 KB ?
         jne       ReadEMm3                 ; je v°ce neë 64 KB
         mov       ax,es:[di+6]             ; velikost dat LOW
         xchg      al,ah                    ; oprava po©ad° bajtñ
ReadEMm3:cmp       ax,cx
         jbe       ReadEMm4                 ; velikost dat je OK
         mov       ax,cx                    ; omezen° velikosti dat
         or        byte ptr es:[TextParm],bit0 ; z†kaz z†pisu (nen° celò text)
ReadEMm4:xchg      ax,cx                    ; CX <- poáet bajtñ k naáten°
         pop       ax

; ------ naáten° dat ve form†tu FOXPRO

         call      far ptr ReadFile         ; naáten° dat MEMO pole pro FOXPRO
         jc        ReadEMm9                 ; chyba
         add       di,cx                    ; adresa konce dat

; ------ poáet naátenòch bajtñ dat

ReadEMm7:xchg      ax,bx                    ; AX <- á°slo segmentu editoru
         mov       bx,di
         mov       es:[0],di                ; adresa konce dat
         sub       di,dx                    ; poáet naátenòch bajtñ v bufferu
         mov       es:[TextBNum],di         ; poáet bajtñ naátenòch v bufferu
         mov       cx,di                    ; CX <- poáet naátenòch bajtñ dat

; ------ zmen®en° velikosti bufferu editoru

         call      far ptr ModiSegS         ; nastaven° velikosti segmentu
         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

ReadEMm9:pop       di
         pop       si
         pop       dx
         pop       bx
         pop       ax
         ret

ReadEMem ENDP

; -----------------------------------------------------------------------------
;      nastaven° ukazatele poloëky DX:BX v souboru MEMO ident. AX (datab†ze ES)
; -----------------------------------------------------------------------------

SetUPMem PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      dx

; ------ nastaven° ukazatele v souboru

         push      ax
         mov       ax,es:[DBFBlokT]         ; velikost bloku MEMO
         mul       dx                       ; vyn†soben° poloëky HIGH
         xchg      ax,bx                    ; BX<-offset HIGH, AX<-poloëka LOW
         mul       word ptr es:[DBFBlokT]   ; vyn†soben° poloëky LOW
         add       dx,bx                    ; offset HIGH
         xchg      ax,cx                    ; CX <- offset LOW
         pop       ax
         call      far ptr SetUFile         ; nastaven° ukazatele v souboru

; ------ n†vrat registrñ

         pop       dx
         pop       cx
         pop       bx
         ret

SetUPMem ENDP

; -----------------------------------------------------------------------------
;        inicializace parametrñ editoru MEMO
; -----------------------------------------------------------------------------
; VSTUP: DX=segment datab†ze
;        DS=datovò segment
;        ES=segment editoru MEMO
; -----------------------------------------------------------------------------

InitEMem PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      di
         push      ds
         mov       ds,dx                    ; DS <- adresa datab†ze

; ------ p©enesen° jmÇna souboru

         mov       di,TextName
         mov       si,DBFName
         mov       cx,8
         cld
         rep       movsb                    ; p©enos jmÇna souboru

; ------ p©enesen° koment†©e

         mov       cx,ds:[DBFNKom]          ; dÇlka koment†©e
         mov       si,DBFKom                ; koment†©
         mov       es:[TextNKom],cx         ; dÇlka koment†©e
         mov       di,TextKom               ; koment†©
         rep       movsb                    ; p©enos koment†©e

; ------ p©°znak z†kazu z†pisu

         test      byte ptr ds:[DBFParm],bit1+bit5 ; je z†kaz z†pisu MEMO ?
         jz        InitEMm2
         or        byte ptr es:[TextParm],bit0 ; z†kaz z†pisu MEMO

; ------ implicitn° pouëit° intern°ch p©ep°naáñ

InitEMm2:test      byte ptr ds:[DBFParm2],bit0 ; jsou intern° p©ep°naáe ?
         jnz       InitEMm4                 ; jsou intern° p©ep°naáe
         or        byte ptr es:[TextParm],bit4 ; nepouë°vat intern° promànnÇ

; ------ n†vrat registrñ

InitEMm4:pop       ds
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

InitEMem ENDP

; -----------------------------------------------------------------------------
;        poskytnut° ukazatele poloëky MEMO
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
; VùSTUP: ES:DI=adresa z†znamu
;         DX:AX=poá†teán° blok MEMO pole (0=nen°)
;         BX=adresa pole MEMO (10 znakñ)
;         CY=chyba nebo nen° poloëka MEMO
; -----------------------------------------------------------------------------

GetPMemo PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      si

; ------ poskytnut° aktivn°ho z†znamu ES:DI

         call      far ptr GetADBF          ; poskytnut° z†znamu datab†ze
         jnc       GetPMem0                 ; poloëka OK

         test      byte ptr ds:[DBFEParm],bit0 ; je editace ?
         jz        GetPMm02                 ; nen° editace
         mov       ax,es:[DBFAktZ]          ; aktivn° z†znam
         cmp       ax,es:[DBFMaxZ]          ; je to novò z†znam ?
         jne       GetPMm02
         mov       ax,es:[DBFAktZ+2]
         cmp       ax,es:[DBFMaxZ+2]
         jne       GetPMm02                 ; nen° to novò z†znam

         mov       cx,es:[DBFBytZ]          ; poáet bajtñ na z†znam
         mov       di,es:[DBFAdrE]          ; adresa editaán°ho bufferu
         push      di
         cld
         mov       al," "
         rep       stosb                    ; vymaz†n° bufferu
         pop       di
         jmp       short GetPMem0

GetPMm02:jmp       GetPMem8                 ; chyba

; ------ p©°prava k nalezen° poloëky s MEMO polem

GetPMem0:mov       bx,di                    ; BX <- adresa zaá†tku z†znamu
         inc       bx                       ; p©eskoáen° bajtu popisovaáe
         mov       si,es:[DBFAdrP]          ; tabulka popisovaáñ
         xor       dx,dx                    ; DX <- nen° MEMO poloëka
         xor       cx,cx                    ; CX <- ukazatel á°sla poloëky

; ------ nalezen° MEMO poloëky

GetPMem1:cmp       cx,es:[DBFNumP]          ; je to platn† poloëka ?
         jae       GetPMem4                 ; nen° platn† poloëka - nen° MEMO
         test      byte ptr es:[si+DBFParX],bit5 ; je to MEMO pole ?
         jz        GetPMem2                 ; nen° MEMO pole
         mov       dx,bx                    ; DX <- adresa nalezenÇho pole
;         test      byte ptr ds:[DBFEParm],bit0 ; je editace ?
;         jz        GetPMem5                 ; nen° editace - staá° 1. poloëka
         cmp       cx,es:[DBFAktP]          ; je jië za aktivn° poloëkou ?
         jae       GetPMem5                 ; je jië za aktivn° poloëkou
GetPMem2:add       bx,es:[si+DBFDelX]       ; adresa dal®° poloëky
         add       si,DBFX                  ; dal®° poloëka
         inc       cx                       ; zvò®en° ukazatele á°sla poloëky
         jmp       short GetPMem1           ; dal®° poloëka

GetPMem4:mov       bx,dx                    ; BX <- nalezen† poloëka
         or        bx,bx                    ; bylo nalezeno MEMO pole ?
         jz        GetPMem8                 ; MEMO pole nenalezeno

; ------ p©°prava k dek¢dov†n° á°sla poloëky MEMO

GetPMem5:mov       cx,10                    ; á°taá znakñ
         xor       si,si                    ; st©adaá LOW
         xor       dx,dx                    ; st©adaá HIGH
         push      bx

; ------ naáten° jednÇ á°slice

GetPMem6:mov       al,es:[bx]               ; znak z MEMO pole
         inc       bx                       ; zvò®en° ukazatele dat
         sub       al,"0"                   ; je to platn† á°slice ?
         jb        GetPMem7                 ; nen° platn† á°slice
         cmp       al,9
         ja        GetPMem7                 ; nen° platn† á°slice
         mov       ah,0                     ; AX = nov† á°slice

; ------ p©id†n° á°slice ke st©adaái

         push      ax
         mov       ax,10                    ; n†sobitel ©†du
         mul       dx                       ; AX <- novò HIGH
         xchg      ax,si                    ; AX <- starò LOW, SI <- novò HIGH
         mov       dx,10                    ; n†sobitel ©†du
         mul       dx                       ; AX <- novò LOW
         add       dx,si                    ; DX <- novò HIGH
         pop       si                       ; SI <- novà naáten† á°slice
         add       si,ax                    ; SI <- p©iáten° á°sla LOW
         adc       dx,0                     ; p©enos
GetPMem7:loop      GetPMem6                 ; dal®° á°slice
         pop       bx
         xchg      ax,si                    ; AX <- naátenÇ á°slo LOW
         clc                                ; p©°znak operace OK
         jmp       short GetPMem9

; ------ n†vrat registrñ

GetPMem8:stc                                ; p©°znak chyby
GetPMem9:pop       si
         pop       cx
         ret

GetPMemo ENDP

; -----------------------------------------------------------------------------
;        poskytnut° identifik†toru souboru MEMO (segment ES) -> AX, CY=chyba
; -----------------------------------------------------------------------------

GetIMemo PROC      NEAR

; ------ test, zda soubor MEMO m† bòt (zda nen° ignorov†n)

         test      byte ptr es:[DBFParm],bit4 ; m† bòt MEMO soubor ?
         jnz       GetIMem2                 ; m† bòt MEMO soubor
         stc                                ; p©°znak chyby
GetIMem1:ret

; ------ test, zda je soubor MEMO jië otev©en

GetIMem2:mov       ax,es:[DBFIdntT]         ; identifik†tor MEMO souboru
         or        ax,ax                    ; je soubor jië otev©en ?
         jnz       GetIMem1                 ; soubor je jië otev©en

; ------ £schova registrñ

         push      cx
         push      si
         push      di

; ------ otev©en° souboru pro z†pis

         and       byte ptr es:[DBFParm],not bit5 ; nen° z†kaz z†pisu
         mov       si,DBFSouT               ; jmÇno souboru MEMO
         call      far ptr OpenRW           ; otev©en° pro áten° i z†pis
         jnc       GetIMem4                 ; soubor otev©en OK

; ------ otev©en° alespo§ pro áten°

         call      far ptr OpenR            ; otev©en° pro áten°
         jnc       GetIMem3                 ; soubor otev©en OK

; ------ vytvo©en° souboru

         call      far ptr CreatFil         ; vytvo©en° souboru
         jnc       GetIMm21
         jmp       GetIMem9                 ; chyba vytvo©en° souboru

; ------ p©°prava z†hlav° v bufferu

GetIMm20:
        ;call      far ptr ModiWDir         ; aktualizace adres†©e
;         (nen° aktualizov†na adresa ES !)

GetIMm21:push      ax
         cld
         mov       di,DBFBuffT              ; buffer pro MEMO soubor
         mov       si,di                    ; zaá†tek bufferu
         xor       ax,ax

         test      byte ptr es:[DBFParm],bit3 ; je form†t DBASE ?
         jz        GetIMm22                 ; je form†t FOXPRO
         inc       ax
         stosw                              ; je 1 z†znam 512 bajtñ
         dec       ax
         stosw
         stosw
         jmp       short GetIMm24

GetIMm22:stosw
         mov       ah,8
         stosw                              ; velikost souboru - 8 blokñ
         mov       ah,0
         stosw
         mov       ah,64
GetIMm24:stosw                              ; velikost bloku 64 bajtñ
         mov       ah,0
         mov       cx,(512-8)/2
         rep       stosw                    ; vymaz†n° zbytku sektoru
         pop       ax

; ------ z†pis z†hlav°

         mov       cx,512                   ; poáet bajtñ na z†hlav°
         call      far ptr WritFile         ; z†pis z†hlav°
         call      far ptr ResFile          ; resetov†n° ukazatele souboru
         jmp       short GetIMem4

GetIMem3:or        byte ptr es:[DBFParm],bit5 ; z†kaz z†pisu do MEMO
GetIMem4:mov       es:[DBFIdntT],ax         ; identifik†tor souboru MEMO

; ------ naáten° z†hlav° souboru

         mov       di,DBFBuffT              ; buffer souboru MEMO
         mov       cx,512                   ; velikost z†hlav°
         call      far ptr ReadFile         ; naáten° z†hlav° souboru
         jc        GetIMem8                 ; chyba
         cmp       cx,512
         jne       GetIMem8

; ------ p©°prava parametrñ pro DBASE

         mov       word ptr es:[DBFHeadT],512 ; poáet bajtñ na z†hlav° MEMO
         mov       word ptr es:[DBFBlokT],512 ; velikost bloku MEMO pole
         mov       ax,es:[di]               ; posledn° z†znam LOW
         mov       cx,es:[di+2]             ; posledn° z†znam HIGH
         mov       es:[DBFLastT],ax         ; posledn° z†znam LOW
         mov       es:[DBFLastT+2],cx       ; posledn° z†znam HIGH
         mov       es:[DBFLast0],ax         ; posledn° z†znam LOW
         mov       es:[DBFLast0+2],cx       ; posledn° z†znam HIGH

; ------ p©°prava parametrñ pro FOXPRO

         test      byte ptr es:[DBFParm],bit3 ; je form†t FOXPRO ?
         jnz       GetIMem6                 ; nen° form†t FOXPRO
         xchg      al,ah
         xchg      cl,ch
         mov       es:[DBFLastT],cx         ; posledn° z†znam LOW
         mov       es:[DBFLastT+2],ax       ; posledn° z†znam HIGH
         mov       es:[DBFLast0],cx         ; posledn° z†znam LOW
         mov       es:[DBFLast0+2],ax       ; posledn° z†znam HIGH
         mov       ax,es:[di+4]             ; velikost z†znamu HIGH
         or        ax,ax                    ; je velikost z†znamu OK ?
         jnz       GetIMem8                 ; chyba velikosti bloku
         mov       ax,es:[di+6]             ; velikost z†znamu LOW
         xchg      ah,al                    ; oprava po©ad° bajtñ
         cmp       ax,16                    ; minim†ln° velikost bloku
         jb        GetIMem8                 ; chyba velikosti bloku
         cmp       ax,512
         ja        GetIMem8                 ; chyba velikosti bloku
         mov       es:[DBFBlokT],ax         ; velikost bloku

GetIMem6:clc
         mov       ax,es:[DBFIdntT]         ; identifik†tor souboru
         jmp       short GetIMem9

; ------ p©i chybà uzav©en° souboru

GetIMem8:mov       ax,es:[DBFIdntT]         ; identifik†tor souboru
         call      far ptr ClosFile         ; uzav©en° souboru
         mov       word ptr es:[DBFIdntT],0 ; zru®en° identifik†toru
         stc                                ; p©°znak chyby

; ------ n†vrat registrñ

GetIMem9:pop       di
         pop       si
         pop       cx
         ret

GetIMemo ENDP

; -----------------------------------------------------------------------------
;        dopl§kov† data
; -----------------------------------------------------------------------------

DBFOdDes db        ","                      ; oddàlovaá desetin
DBFOdRad db        "."                      ; oddàlovaá ©†dñ

CodeDbf  ENDS

INCLUDE  ASM\DBF1.ASM                       ; obsluha seznamu souborñ k vòbàru
INCLUDE  ASM\DBF2.ASM
;INCLUDE  ASM\DBF3.ASM

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;
;                                 Data
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
Data     SEGMENT

; Struktura datovÇho souboru .DBF
; -------------------------------
;   z†hlav°:
;             0 (1) identifik†tor 3=DBASE III (nebo FOXPRO)
;                                 83h=DBASE III se souborem .DBT (memo)
;                                 F5h=FOXPRO se souborem .FPT (memo)
;             1 (3) datum posledn° zmàny - (1) rok (bez stolet°)
;                                          (1) màs°c
;                                          (1) den
;             4 (4) poáet z†znamñ v souboru
;             8 (2) dÇlka z†hlav° (bajtñ)
;            10 (2) dÇlka z†znamu (bajtñ)
;            12 (20) ... rezervov†no (pro verzi 1.00)
;            32 (n*32) popisovaáe poloëek
;            32 + n*32 (1) konec z†hlav° 0dh
;
; popisovaá poloëky:
;             0 (11) jmÇno poloëky ASCIIZ (s 0 na konci)
;            11 (1) typ poloëky ("C", "N", "F", "L", "D", "M" nebo "P")
;                          typ "C" (Character): text doplnàn° zprava mezerami
;                                               dÇlka max. 254 znakñ
;                          typ "N" (Numeric): á°slo s pevnou desetinnou teákou,
;                                             znaky "0" aë "9","-", "+" a "."
;                                             max. 20 pozic (max. 15 des. m°st)
;                          typ "F" (Float): re†lnÇ á°slo s pohyblivou teákou,
;                                           max. 20 pozic (max. 15 des. m°st),
;                                           rozsah 0.9xE+308 aë 0.1xE-307,
;                                           max. 15 á°slic p©ed teákou a 9 za
;                          typ "L" (Logical): hodnoty Y,y,N,n,T,t,F,f,mezera
;                                             ? = neinicializov†no
;                          typ "D" (Date): osum á°slic RRRRMMDD
;                          typ "M" (Memo): deset á°slic - á°slo poá†teán°ho
;                                          bloku .DBT nebo .FPT textu k poloëce
;                          typ "G" (General): jako MEMO, ale pro obecn† data
;                          typ "P" (Picture): obr†zek (z©ejmà jmÇno souboru)
;            12 (4) adresa obsahu poloëky v pamàti
;            16 (1) dÇlka poloëky v z†znamu (bajtñ)
;            17 (1) poáet desetinnòch m°st
;            18 (2) ... rezervov†no             ƒƒƒƒø rezervov†no pro verzi 1.00
;            20 (1) oznaáen° pracovn° oblasti       ≥
;            21 (2) ... rezervov†no                 ≥
;            23 (1) n†và®t° pro SET FIELDS TO (...) ≥
;            24 (8) ... rezervov†no             ƒƒƒƒŸ
;
; z†znam:
;             0 (1) p©°znak zru®enÇ poloëky - "*"=zru®en†, jinak " "
;             1 (x) poloëky (n†sleduj° bezprost©ednà za sebou)
;
; Struktura Memo pole .DBT
; ------------------------
; bloky textñ o dÇlce 512 bajtñ, kterÇ jsou sekvenánà ©azeny za sebou.
; Memo pole ukazuje na poá†teán° á°slo z†znamu (po 512 bajtech) od 1.
; Z†znam 0 Memo pole je pro intern° pot©ebu: na offsetu 0 je dvojslovo (4) -
; - poáet z†znamñ 512 bajtñ v souboru (tj. novò z†znam k pouëit°). P©i zvàt®en°
; poloëky v memo poli p©es aktu†ln° velikost se star† poloëka uvoln° a p©idàl°
; se nov† poloëka na konci souboru. û†dek v MEMO poli je ukonáen znaky 0Dh/0Ah,
; màkkÇ zakonáen° ©†dku (v odstavci) je 8Dh/0Ah. Text je zakonáen 1Ah.
;
; Struktura Memo pole .FPT
; ------------------------
; Bloky textñ max° volitelnou velikost - standardnà 64 bajtñ. Poáet blokñ
; je ud†n na offsetu 0 bloku 0 (tj. na zaá†tku souboru) jako dvojslovo, na
; rozd°l od souboru DBT je v®ak po©ad° bajtñ opaánà (tj. nap©. 00 00 12 6E).
; Na offsetu 4 bloku 0 je dvojslovo ud†vaj°c° velikost bloku textu v bajtech
; (opàt v po©ad° od nejvy®®°ch bajtñ). Z†hlav° souboru je 512 bajtñ, coë
; ud†v† minim†ln° á°slo z†znamu - pro standardn° 64 B je to tedy min. 8.
; Jeden z†znam Memo pole zaá°n† dvojslovem 00 00 00 01 a dvojslovem ud†vaj°c°m
; dÇlku z†znamu v bajtech (opàt v opaánÇm po©ad°, tedy nap©. 00 00 01 2A), za
; kteròm n†sleduje text udanÇ dÇlky.
;
; Struktura indexovÇho souboru .NDX
; ---------------------------------
; Z†hlav° (uzel á°slo 0):
;             0 (2) á°slo uzlu, ve kterÇm je t©eba zaá°t vyhled†v†n° (ko©en)
;             2 (2) ... rezervov†no
;             4 (2) á°slo posledn°ho bloku .NDX + 1
;             6 (6) ... rezervov†no
;            12 (2) dÇlka kl°áovÇ hodnoty
;            14 (2) poáet kl°áovòch poloëek v jednom uzlu
;            16 (1) 0=hodnota kl°áe je typu C
;                   1=hodnota kl°áe je typu N
;            17 (1) ... rezervov†no
;            18 (2) dÇlka kl°áovÇ poloëky
;            20 (4) ... rezervov†no
;            24 (100) vzorec pro vòpoáet kl°áovÇ hodnoty
;            x-511 ... rezervov†no
;
; V®echny ostatn° uzly:
;             0 (1) poáet kl°áovòch poloëek v uzlu
;             1 (3) ... rezervov†no
;             4 (508) pole kl°áovòch poloëek v uzlu
;
; Kl°áov† poloëka:
;             0 (2) ukazatel na nië®° £rove§ (á°slo bloku, ve kterÇm se nach†z°
;                   uzel nië®° £rovnà). U listñ = 0 (konec stromu).
;             2 (2) ... rezervov†no
;             4 (4) ukazatel do souboru .DBF (á°slo vàty v .DBF se stejnou
;                   hodnotou kl°áovÇho vòrazu). U uzlñ vy®®° £rovnà = 0.
;             8     hodnota kl°áovÇho vòrazu (dÇlka z†vis° na £daji dÇlky kl°áe)


;ColDBF1  db        71h                      ; stavovò ©†dek - bàën† barva
;ColDBF11 db        74h                      ; stavovò ©†dek - nadpis
;                                          ;* barvy v ©†dkovÇm oknà
;ColDBF2  db        0fh                      ; ©†dek se jmÇny poloëek
;ColDBF22 db        4fh                      ; poloëka s nastavovanou ®°©kou
;ColDBF3  db        1bh                      ; bàënò z†znam
;ColDBF4  db        30h                      ; bàënò z†znam s kurzorem
;ColDBF42 db        0fh                      ; barva editovanÇ poloëky
;
;ColDBF5  db        1eh                      ; oznaáenò z†znam
;ColDBF6  db        3eh                      ; oznaáenò z†znam s kurzorem
;
;                                          ;* barvy ve str†nkovÇm oknà
;ColDBF12 db        70h                      ; jmÇna poloëek + podklad
;ColDBF13 db        1bh                      ; poloëky z†znamu
;ColDBF14 db        0fh                      ; barva aktivn° editovanÇ poloëky
;ColDBF15 db        74h                      ; vysv°cen† jmÇna poloëek

;ColDBF7  db        1bh                      ; bavra textu rychlÇho prohl°ëen°

; -----------------------------------------------------------------------------
;        okno datab†ze
; -----------------------------------------------------------------------------
;˛
DBFMnu   label     byte

         db        10                       ; typ menu - editor datab†ze

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet poloëek menu
         dw        1                        ; celkovò poáet poloëek menu

         dw        0                        ; zaá†tek definice poloëek menu
         dw        DBFMnHl1                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@EditorDBF            ; á°slo str†nky velkÇ n†povàdy
         dw        0                        ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        DBFMnTit                 ; adresa titulu okna
         dw        LinMenTM                 ; adresy obsluh
         dw        LinMenTM                 ; adresa podmenu
         dd        0                        ; n†vratov† adresa

         db        0                        ; poá†teán° pozice okna
         db        1                        ; poá†teán° ©†dek okna
         db        80                       ; ®°©ka okna
         db        21                       ; vò®ka okna

DBFMnuSg dw        0                        ; segment se souborem

DBFMnTit db        6,'seznam'

HelpS    SEGMENT   BYTE PUBLIC              ; n†povàda k menu
DBFMnHl1 db        90,'Enter z†znam, Insert oznaá, F3 text, F4 edituj, F6 skok, F7 hledej, F10 menu'
DBFMnHl2 db        84,'Enter ©†dky, F3 text, F4 edituj, F6 skok, F7 hledej, F9 vloë, F10 menu'

DBFMnHl3 db        61,'ZNAKOVê pole: zadejte text (Ctrl-U n†vrat zmàn v z†znamu)'
DBFMnHl4 db        75,'ÄãSLO: zadejte á°slice 0 aë 9, desetinnou teáku . nebo znamÇnko -'

DBFMnHl5 db        23,1
         dw        DBFMnHD1
         db        'DEN.MâSãC.ROK',1
         dw        DBFMnHD2

DBFMnHl6 db        23,1
         dw        DBFMnHD1
         db        'MâSãC/DEN/ROK',1
         dw        DBFMnHD2

DBFMnHl7 db        23,1
         dw        DBFMnHD1
         db        'ROK:MâSãC:DEN',1
         dw        DBFMnHD2

DBFMnHl8 db        65,'LOGICKê pole: zadejte A (T, Y, J) = ANO, N (F) = NE'
DBFMnHl9 db        26,'TEXT: F3=editace textu'
DBFMnHlA db        57,'ÄAS: zadejte áas ve form†tu HODINA:MINUTA:SEKUNDA'

DBFMnHlP db        92,'vlevo/vpravo=®°©ka (',1
         dw        DBFMnHPS
         db        '), TAB=pole, End=celÇ, Enter=uloëen° na disk, Esc=konec'
HelpS    ENDS

DBFMnHD1 db        35,'DATUM: zadejte datum ve form†tu '
DBFMnHD2 db        24,' (rok 2 nebo 4 á°slice)'

DBFMnHPS db        0,'   '

DBFMnHM1 label     byte
         db        14
         dw        1c0dh                    ; Enter
         db        14
         dw        5200h                    ; Insert
         db        9
         dw        3d00h                    ; F3
         db        11
         dw        3e00h                    ; F4
         db        9
         dw        4000h                    ; F6
         db        11
         dw        4100h                    ; F7
         db        -1
         dw        4400h                    ; F10

DBFMnHM2 label     byte
         db        13
         dw        1c0dh                    ; Enter
         db        9
         dw        3d00h                    ; F3
         db        11
         dw        3e00h                    ; F4
         db        9
         dw        4000h                    ; F6
         db        11
         dw        4100h                    ; F7
         db        9
         dw        4300h                    ; F9
         db        -1
         dw        4400h                    ; F10

DBFMnHMP label     byte
         db        7
         dw        4b00h                    ; vlevo
         db        18
         dw        4d00h                    ; vpravo
         db        10
         dw        0f09h                    ; Tab
         db        10
         dw        4f00h                    ; End
         db        23
         dw        1c0dh                    ; Enter
         db        -1
         dw        011bh                    ; Esc

; ------ skok na z†znam

DBSMSLin label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        DBSMLPol                 ; zaá†tek definice poloëek menu
         dw        DBSMLHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@DatabazoveMenu       ; á°slo str†nky velkÇ n†povàdy
         dw        DBSMLBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        DBSMLTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        20                       ; poá†teán° pozice okna
         db        0                        ; poá†teán° ©†dek okna
         db        40                       ; ®°©ka okna
         db        8                        ; vò®ka okna

         dw        13                       ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        1                        ; celkovò poáet ©†dkñ
         dw        1                        ; poáet zobrazenòch ©†dkñ

         db        bit4                     ; maska zad†vanòch znakñ - á°slo
         db        6,'. +-,:'               ; zak†zanÇ znaky

         db        HistCis                  ; historie á°sel
         db        0                        ; poáet p©edvoleb

; ------ poloëky voleb

DBSMLPol db        bit6,21,'Skok na z†znam á°slo:'
         db        0,0
         db        bit6+bit7,0
         db        1,4,'Skok'
         db        1,6,'N†vrat'

DBSMLBlk db        0,0,0                    ; blokovac° tabulka

DBSMLTit db        4,'skok'

; ------ n†povàda

HelpS    SEGMENT   BYTE PUBLIC
DBSMLHlp db        42,'Zadejte á°slo novÇho z†znamu (1...MAX)'
         db        29,'Skok na z†znam zadanÇho á°sla'
         db        3,1
         dw        MenuHlp2
HelpS    ENDS

;; ------ data k vyhled†n° v seznamu
;
;DBHMSLin label     byte
;
;         db        3                        ; typ menu - ©†dkovÇ menu
;
;         db        0                        ; hladina k zobrazen° menu
;         dw        1                        ; aktivn° poloëka menu
;         dw        5                        ; poáet platnòch poloëek menu
;         dw        7                        ; celkovò poáet poloëek menu
;
;         dw        DBHMLPol                 ; zaá†tek definice poloëek menu
;         dw        DBHMLHlp                 ; adresa tabulky textñ n†povàdy
;         dw        Hlp@VyhledavaniTextuVDatabazi ; á°slo str†nky velkÇ n†povàdy
;         dw        DBHMLBlk                 ; adresa blokovac° tabulky
;         dw        DBHMLSwc                 ; adresa tabulky p©ep°naáñ
;         dw        DBHMLTit                 ; adresa titulu okna
;         dw        DBHMLExe                 ; tabulka obsluh voleb menu
;         dw        LinMenTM                 ; tabulka adres podmenu
;         dd        0                        ; n†vratov† adresa p©i p©eru®en°
;
;         db        20                       ; poá†teán° pozice okna
;         db        0                        ; poá†teán° ©†dek okna
;         db        57                       ; ®°©ka okna
;         db        8                        ; vò®ka okna
;
;         dw        TextFndX                 ; maxim†ln° dÇlka textu ©†dku
;         dw        0                        ; prvn° zobrazenò ©†dek
;         dw        0                        ; aktivn° zobrazenò ©†dek
;         dw        1                        ; celkovò poáet ©†dkñ
;         dw        1                        ; poáet zobrazenòch ©†dkñ
;
;         db        bit2                     ; maska zad†vanòch znakñ - v®echny
;         db        1,26,'     '             ; zak†zanÇ znaky
;
;         db        HistFind                 ; historie hled†n°
;         db        0                        ; poáet p©edvoleb
;
;; ------ poloëky voleb
;
;DBHMLPol db        bit6,27,'Text k vyhled†n° v seznamu:'
;         db        0,0
;         db        bit6+bit7,0
;         db        1,6,'Hledej'
;         db        1+bit7,9,'Oznaáit '
;DBHMLPl1 db        '-'
;         db        1+bit7,9,'Nulovat '
;DBHMLPl2 db        '-'
;         db        1,8,'P©eru®it'
;
;DBHMLBlk db        0,0,0,0,0                ; blokovac° tabulka
;DBHMLSwc db        0,0                      ; p©ep°naáe
;
;DBHMLTit db        6,'hledej'
;
;DBHMLTxt db        18,'Vyhled†v†m text...'
;
;HelpS    SEGMENT   BYTE PUBLIC
;DBHMLHlp db        65,'Zadejte textovò ©etàzec k vyhled†n° (od kurzoru ke konci seznamu)'
;         db        24,'Vyhled†n° zadanÇho textu'
;         db        39,'V®echny nalezenÇ z†znamy budou oznaáeny'
;         db        47,'Bude nulov†no oznaáen° v®ech nalezenòch z†znamñ'
;         db        3,1
;         dw        MenuHlP2
;HelpS    ENDS
;
;DBHMLExe label     dword
;         dd        Lin0MenR                 ; ©†dky
;         dd        Lin0MenR                 ; Hledej
;         dd        EditBHS1                 ; Oznaáit
;         dd        EditBHS2                 ; Nulovat
;         dd        Lin0MenR                 ; P©eru®it
;
;; ------ vloëen° z†znamñ
;
;DBVMSLin label     byte
;
;         db        3                        ; typ menu - ©†dkovÇ menu
;
;         db        0                        ; hladina k zobrazen° menu
;         dw        1                        ; aktivn° poloëka menu
;         dw        3                        ; poáet platnòch poloëek menu
;         dw        5                        ; celkovò poáet poloëek menu
;
;         dw        DBVMLPol                 ; zaá†tek definice poloëek menu
;         dw        DBVMLHlp                 ; adresa tabulky textñ n†povàdy
;         dw        Hlp@DatabazoveMenu       ; á°slo str†nky velkÇ n†povàdy
;         dw        DBVMLBlk                 ; adresa blokovac° tabulky
;         dw        0                        ; adresa tabulky p©ep°naáñ
;         dw        DBVMLTit                 ; adresa titulu okna
;         dw        LinMenTE                 ; tabulka obsluh voleb menu
;         dw        LinMenTM                 ; tabulka adres podmenu
;         dd        0                        ; n†vratov† adresa p©i p©eru®en°
;
;         db        20                       ; poá†teán° pozice okna
;         db        0                        ; poá†teán° ©†dek okna
;         db        40                       ; ®°©ka okna
;         db        8                        ; vò®ka okna
;
;         dw        13                       ; maxim†ln° dÇlka textu ©†dku
;         dw        0                        ; prvn° zobrazenò ©†dek
;         dw        0                        ; aktivn° zobrazenò ©†dek
;         dw        1                        ; celkovò poáet ©†dkñ
;         dw        1                        ; poáet zobrazenòch ©†dkñ
;
;         db        bit4                     ; maska zad†vanòch znakñ - á°slo
;         db        2,'.     '               ; zak†zanÇ znaky
;
;         db        HistCis                  ; historie á°sel
;         db        1                        ; poáet p©edvoleb
;
;         dw        1
;         dd        DBVMLPr1                 ; p©edvolba "1"
;
;DBVMLPr1 db        '1'
;
;; ------ poloëky voleb
;
;DBVMLPol db        bit6,24,'Poáet z†znamñ k vloëen°:'
;         db        0,0
;         db        bit6+bit7,0
;         db        1,6,'Vloëit'
;         db        1,6,'N†vrat'
;
;DBVMLBlk db        0,0,0                    ; blokovac° tabulka
;
;DBVMLTit db        8,'vkl†d†n°'
;
;; ------ n†povàda
;
;HelpS    SEGMENT   BYTE PUBLIC
;DBVMLHlp db        56,'Zadejte poáet novòch z†znamñ k vloëen° na pozici kurzoru'
;         db        44,'Vloëen° poëadovanÇho mnoëstv° novòch z†znamñ'
;         db        3,1
;         dw        MenuHlP2
;HelpS    ENDS
;
;; -----------------------------------------------------------------------------
;;        menu ru®en° z†znamñ v souboru
;; -----------------------------------------------------------------------------
;
;DBPMLin  label     byte
;         db        3                        ; typ menu - ©†dkovÇ menu
;
;         db        0                        ; hladina k zobrazen° menu
;         dw        1                        ; aktivn° poloëka menu
;         dw        2                        ; poáet platnòch poloëek menu
;         dw        7                        ; celkovò poáet poloëek menu
;
;         dw        DBPMLPol                 ; adresa definice poloëek
;         dw        DBPMLHlp                 ; adresa n†povàd
;         dw        Hlp@DatabazoveMenu       ; á°slo str†nky velkÇ n†povàdy
;         dw        DBPMLBlk                 ; adresa blokovac° tabulky
;         dw        0                        ; adresa tabulky p©ep°naáñ
;         dw        DBPMLTit                 ; adresa titulu okna
;         dw        LinMenTE                 ; adresa obsluh voleb
;         dw        LinMenTM                 ; adresy podmenu
;         dd        0                        ; n†vratov† adresa
;
;         db        19                       ; poá†teán° pozice
;         db        7                        ; poá†teán° ©†dek
;         db        40                       ; ®°©ka
;         db        10                       ; vò®ka
;
;         dw        0                        ; maxim†ln° dÇlka ©†dku
;         dw        0                        ; prvn° zobrazenò ©†dek
;         dw        0                        ; aktivn° zobrazenò ©†dek
;         dw        0                        ; celkovò poáet ©†dkñ
;         dw        0                        ; poáet zobrazenòch ©†dkñ
;
;         db        0                        ; maska znakñ
;         db        0,'      '               ; zak†zanÇ znaky
;
;         db        0                        ; identifik†tor historie
;         db        0                        ; poáet p©edvoleb
;
;DBPMLPol db        bit6,0
;         db        bit6,34,'V®echny oznaáenÇ poloëky v souboru'
;         db        bit6,18,'budou odstranàny !'
;         db        bit6,0
;         db        bit6+bit7,0
;         db        1,10,'Pokraáovat'
;         db        1,6,'N†vrat'
;
;DBPMLBlk db        0,0
;DBPMLTit db        6,'ru®en°'
;
;HelpS    SEGMENT   BYTE PUBLIC
;DBPMLHlp db        37,'Zru®en° oznaáenòch poloëek ze souboru'
;         db        3,1
;         dw        MenuHlP2
;HelpS    ENDS
;
;; ------ druhÇ potvrzen° ru®en°
;
;DBP2Lin  label     byte
;         db        3                        ; typ menu - ©†dkovÇ menu
;
;         db        0                        ; hladina k zobrazen° menu
;         dw        1                        ; aktivn° poloëka menu
;         dw        2                        ; poáet platnòch poloëek menu
;         dw        8                        ; celkovò poáet poloëek menu
;
;         dw        DBP2LPol                 ; adresa definice poloëek
;         dw        DBP2LHlp                 ; adresa n†povàd
;         dw        Hlp@DatabazoveMenu       ; á°slo str†nky velkÇ n†povàdy
;         dw        DBP2LBlk                 ; adresa blokovac° tabulky
;         dw        0                        ; adresa tabulky p©ep°naáñ
;         dw        DBPMLTit                 ; adresa titulu okna
;         dw        LinMenTE                 ; adresa obsluh voleb
;         dw        LinMenTM                 ; adresy podmenu
;         dd        0                        ; n†vratov† adresa
;
;         db        19                       ; poá†teán° pozice
;         db        7                        ; poá†teán° ©†dek
;         db        40                       ; ®°©ka
;         db        11                       ; vò®ka
;
;         dw        0                        ; maxim†ln° dÇlka ©†dku
;         dw        0                        ; prvn° zobrazenò ©†dek
;         dw        0                        ; aktivn° zobrazenò ©†dek
;         dw        0                        ; celkovò poáet ©†dkñ
;         dw        0                        ; poáet zobrazenòch ©†dkñ
;
;         db        0                        ; maska znakñ
;         db        0,'      '               ; zak†zanÇ znaky
;
;         db        0                        ; identifik†tor historie
;         db        0                        ; poáet p©edvoleb
;
;DBP2LPol db        bit6,0
;         db        bit6,10,0,'VAROVèNã:'
;         db        bit6,23,'Zru®°m v®echny oznaáenÇ'
;         db        bit6,19,'poloëky v souboru !'
;         db        bit6,0
;         db        bit6+bit7,0
;         db        1,5,'Ru®it'
;         db        1,6,'N†vrat'
;
;DBP2LBlk db        0,0
;
;HelpS    SEGMENT   BYTE PUBLIC
;DBP2LHlp db        46,'Zah†jen° operace vypou®tàn° oznaáenòch poloëek'
;         db        3,1
;         dw        MenuHlP2
;HelpS    ENDS

; -----------------------------------------------------------------------------
;        menu volby dal®° operace v oknà datab†ze
; -----------------------------------------------------------------------------
;˛
DBMnVert label     byte                   ;* menu volby operace v datab†zi

         db        2                        ; typ menu - vertik†ln° podmenu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        16                       ; poáet platnòch poloëek menu
         dw        16                       ; celkovò poáet poloëek menu

         dw        DBMnVPol                 ; adresa definice poloëek
         dw        DBMnVHlp                 ; adresa n†povàd
         dw        Hlp@DatabazoveMenu       ; á°slo str†nky velkÇ n†povàdy
         dw        DBMnVBlk                 ; adresa blokovac° tabulky
         dw        DBMnVSwc                 ; adresa tabulky p©ep°naáñ
         dw        DBMnVTit                 ; adresa titulu okna
         dw        DBMnVExe                 ; adresa obsluh
         dw        DBMnVMnu                 ; adresa podmenu
         dd        0                        ; n†vratov† adresa

         db        30                       ; poá†teán° pozice
         db        5                        ; poá†teán° ©†dek
         db        20                       ; ®°©ka
         db        18                       ; vò®ka

DBMnVPol db        1+bit7,6,'Browse'        ; zobrazen° z†znamu (Enter)
         db        1,4,'D†le'               ; pokraáov†n° v hled†n° (Ctrl-L)
         db        1+bit7,7,'Editace'       ; editace z†znamu (F4)
         db        1,6,'Hledat'             ; hled†n° textu (F7)
         db        1,17,'Import          ',16 ; naáten° dat z text. souboru
         db        1,5,'Kopie'              ; kop°rov†n° z†znamu (F5)
         db        1,10,'Modifikace'        ; modifikace struktury (F2)
         db        1,7,'Nulovat'            ; nulovat oznaáen° z†znamñ
         db        1,8,'Obnoven°'           ; obnoven° obsahu z†znamu (Ctrl-U)
         db        1,4,'Pole'               ; nastaven° ®°©ky zobrazen° pole
         db        1,5,'Ru®it'              ; ru®en° oznaáenòch z†znamñ (F8)
         db        1,4,'Skok'               ; skok na zadanò z†znam (F6)
         db        1,4,'Text'               ; editace/zobraz.textovÇho pole (F3)
         db        1,6,'Vloëit'             ; vloëen° novòch z†znamñ (F9)
         db        2,17,'eXport          ',16 ; uloëen° dat do text. souboru
         db        1+bit7,6,'Zobraz'        ; zobrazen° obsahu

; nahorU  Ctrl-F9
; doLñ    Ctrl-F10
; set©°dit (Ut©°dit)
; vYti®tàn°


DBMnVBlk db        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DBMnVSwc db        0,0,0
DBMnVTit db        4,'menu'

HelpS    SEGMENT   BYTE PUBLIC
DBMnVHlp db        69,'Zobrazen° z†znamñ po ©†dc°ch, jinak jeden z†znam na str†nku (Enter)'
         db        43,'Pokraáov†n° ve vyhled†v†n° textu (Ctrl-L)'
         db        22,'Editace z†znamu (F4)'
         db        32,'Vyhled†n° textu v seznamu (F7)'
         db        30,'Import dat z textovÇho souboru'
         db        37,'Kopie dat do aktivn°ho z†znamu (F5)'
         db        43,'Modifikace struktury souboru seznamu (F2)'
         db        41,'Nulov†n° oznaáen° z†znamñ v celÇm souboru'
         db        56,'Obnoven° pñvodn°ho obsahu editovanÇho z†znamu (Ctrl-U)'
         db        42,'Nastaven° zobrazenÇ ®°©ky pole (Ctrl-F2)'
         db        49,'Zru®en° v®ech oznaáenòch z†znamñ v seznamu (F8)'
         db        36,'Skok na z†znam zadanÇho á°sla (F6)'
         db        45,'Zobrazen°/editace textu textovÇho pole (F3)'
         db        29,'Vloëen° novòch z†znamñ (F9)'
         db        54,'Uloëen° dat ze seznamu do textovÇho souboru (Export)'
         db        62,'RychlÇ zobrazen° obsahu prvn°ho pole TEXT v z†znamu (Ctrl-Q)'

;DBMnVHl1 db        68,'Zadejte omezen° maxim†ln° ®°©ky znakovÇho pole (10 aë 255 pozic)'
HelpS    ENDS

DBMnVExe dd        EditBMe5                 ; Browse
         dd        EditBMe1                 ; D†le
         dd        EditBMe3                 ; Editace
         dd        EditBMe1                 ; Hledat
         dd        EditBImp                 ; Import
         dd        EditBMe1                 ; Kopie
         dd        EditBMe1                 ; Modifikace
         dd        EditBMe1                 ; Nulovat
         dd        EditBMe1                 ; Obnoven°
         dd        EditBMe1                 ; Pole
         dd        EditBMe1                 ; Ru®it
         dd        EditBMe1                 ; Skok
         dd        EditBMe1                 ; Text
         dd        EditBMe1                 ; Vloëit
         dd        EditBExp                 ; eXport
         dd        EditBMe6                 ; Zobraz

DBMnVMnu dw        0                        ; Browse
         dw        0                        ; D†le
         dw        0                        ; Editace
         dw        0                        ; Hledat
         dw        DBIMVert                 ; Import
         dw        0                        ; Kopie
         dw        0                        ; Modifikace
         dw        0                        ; Nulovat
         dw        0                        ; Obnoven°
         dw        0                        ; Pole
         dw        0                        ; Ru®it
         dw        0                        ; Skok
         dw        0                        ; Text
         dw        0                        ; Vloëit
         dw        DBXMVert                 ; eXport
         dw        0                        ; Zobraz

; ------ potvrzen° nulov†n° oznaáen°

DBNMLin  label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        2                        ; poáet platnòch poloëek menu
         dw        7                        ; celkovò poáet poloëek menu

         dw        DBNMLPol                 ; adresa definice poloëek
         dw        DBNMLHlp                 ; adresa n†povàd
         dw        Hlp@DatabazoveMenu       ; á°slo str†nky velkÇ n†povàdy
         dw        DBNMLBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        DBNMLTit                 ; adresa titulu okna
         dw        LinMenTE                 ; adresa obsluh voleb
         dw        LinMenTM                 ; adresy podmenu
         dd        0                        ; n†vratov† adresa

         db        19                       ; poá†teán° pozice
         db        7                        ; poá†teán° ©†dek
         db        49                       ; ®°©ka
         db        10                       ; vò®ka

         dw        0                        ; maxim†ln° dÇlka ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        0                        ; maska znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; identifik†tor historie
         db        0                        ; poáet p©edvoleb

DBNMLPol db        bit6,0
         db        bit6,9,0,'VAROVèNã'
         db        bit6,32,'Vynuluji oznaáen° v®ech z†znamñ.'
         db        bit6,0
         db        bit6+bit7,0
         db        1,7,'Nulovat'
         db        1,5,'Konec'

DBNMLBlk db        0,0
DBNMLTit db        8,'nulov†n°'

HelpS    SEGMENT   BYTE PUBLIC
DBNMLHlp db        41,'Nulov†n° oznaáen° v®ech z†znamñ v seznamu'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

DBNMLHls db        26,'Nuluji oznaáen° z†znamñ...'

; ------ kopie z†znamu

DBKMSLin label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        DBKMLPol                 ; zaá†tek definice poloëek menu
         dw        DBKMLHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@DatabazoveMenu       ; á°slo str†nky velkÇ n†povàdy
         dw        DBKMLBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        DBKMLTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        20                       ; poá†teán° pozice okna
         db        0                        ; poá†teán° ©†dek okna
         db        40                       ; ®°©ka okna
         db        8                        ; vò®ka okna

         dw        13                       ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        1                        ; celkovò poáet ©†dkñ
         dw        1                        ; poáet zobrazenòch ©†dkñ

         db        bit4                     ; maska zad†vanòch znakñ - á°slo
         db        6,'. +-,:'               ; zak†zanÇ znaky

         db        HistCis                  ; historie á°sel
         db        0                        ; poáet p©edvoleb

; ------ poloëky voleb

DBKMLPol db        bit6,29,'Naáten° dat ze z†znamu á°slo:'
         db        0,0
         db        bit6+bit7,0
         db        1,5,'Kopie'
         db        1,6,'N†vrat'

DBKMLBlk db        0,0,0                    ; blokovac° tabulka

DBKMLTit db        5,'kopie'

; ------ n†povàda

HelpS    SEGMENT   BYTE PUBLIC
DBKMLHlp db        69,'Zadejte á°slo z†znamu (1...MAX), z kterÇho budou data zkop°rov†na'
         db        52,'Kopie dat ze zadanÇho do editovanÇho z†znamu'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

; ------ export

DBXMVert label     byte                   ;* menu volby operace v datab†zi

         db        2                        ; typ menu - vertik†ln° podmenu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        7                        ; poáet platnòch poloëek menu
         dw        8                        ; celkovò poáet poloëek menu

         dw        DBXMVPol                 ; adresa definice poloëek
         dw        DBXMVHlp                 ; adresa n†povàd
         dw        Hlp@ExportDatZDatabazovehoSouboru  ; á°slo str†nky velkÇ n†povàdy
         dw        DBXMVBlk                 ; adresa blokovac° tabulky
         dw        DBXMVSwc                 ; adresa tabulky p©ep°naáñ
         dw        DBXMVTit                 ; adresa titulu okna
         dw        DBXMVExe                 ; adresa obsluh
         dw        LinMenTM                 ; adresa podmenu
         dd        0                        ; n†vratov† adresa

         db        30                       ; poá†teán° pozice
         db        5                        ; poá†teán° ©†dek
         db        20                       ; ®°©ka
         db        10                       ; vò®ka

DBXMVPol db        1+bit7,7,'C á†rka'
         db        1+bit7,8,'St©edn°k'
         db        1+bit7,9,'Tabul†tor'
         db        1+bit7,3,'R†m'
         db        1+bit7,6,'Pozice'
         db        bit6+bit7,0
         db        1,7,'V®echny'
         db        1,8,'OznaáenÇ'

DBXMVBlk db        0,0,0,0,0,0,0
DBXMVSwc db        0,0,0,0,0
DBXMVTit db        6,'export'

HelpS    SEGMENT   BYTE PUBLIC
DBXMVHlp db        30,'DatovÇ poloëky oddàleny á†rkou'
         db        34,'DatovÇ poloëky oddàleny st©edn°kem'
         db        35,'DatovÇ poloëky oddàleny tabul†torem'
         db        61,'DatovÇ poloëky oddàleny znakem r†meáku a zarovn†ny do sloupcñ'
         db        57,'DatovÇ poloëky rozli®eny pozic° na ©†dku (bez oddàlovaáñ)'
         db        30,'Export v®ech z†znamñ v seznamu'
         db        31,'Export pouze oznaáenòch z†znamñ'
HelpS    ENDS

DBXMVExe dd        EditBEx1                 ; á†rka
         dd        EditBEx1                 ; st©edn°k
         dd        EditBEx1                 ; tabul†tor
         dd        EditBEx1                 ; r†m
         dd        EditBEx1                 ; pozice
         dd        EditBEx3                 ; v®echny
         dd        EditBEx2                 ; oznaáenÇ

; ------ zad†n° souboru k exportu

DBXMSLin label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        DBXMLPol                 ; zaá†tek definice poloëek menu
         dw        DBXMLHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@ExportDatZDatabazovehoSouboru ; á°slo str†nky velkÇ n†povàdy
         dw        DBXMLBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        DBXMLTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        20                       ; poá†teán° pozice okna
         db        0                        ; poá†teán° ©†dek okna
         db        43                       ; ®°©ka okna
         db        8                        ; vò®ka okna

         dw        100                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        1                        ; celkovò poáet ©†dkñ
         dw        1                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ - soubor
         db        2,'?*    '               ; zak†zanÇ znaky

         db        HistFile                 ; historie souborñ
         db        0                        ; poáet p©edvoleb

; ------ poloëky voleb

DBXMLPol db        bit6,28,'JmÇno souboru k exportu dat:'
         db        0,0
         db        bit6+bit7,0
         db        1,6,'Export'
         db        1,6,'N†vrat'

DBXMLBlk db        0,0,0                    ; blokovac° tabulka

DBXMLTit db        6,'export'

HelpS    SEGMENT   BYTE PUBLIC
DBXMLHlp db        56,'Zadejte jmÇno souboru, do kterÇho budou data exportov†na'
         db        76,'Proveden° exportu dat do textovÇho souboru (p©id†n° dat, pokud jië existuje)'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

; ------ import

DBIMVert label     byte

         db        2                        ; typ menu - vertik†ln° podmenu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        7                        ; poáet platnòch poloëek menu
         dw        8                        ; celkovò poáet poloëek menu

         dw        DBIMVPol                 ; adresa definice poloëek
         dw        DBIMVHlp                 ; adresa n†povàd
         dw        Hlp@ImportDatDoDatabazovehoSouboru ; á°slo str†nky velkÇ n†povàdy
         dw        DBIMVBlk                 ; adresa blokovac° tabulky
         dw        DBIMVSwc                 ; adresa tabulky p©ep°naáñ
         dw        DBIMVTit                 ; adresa titulu okna
         dw        DBIMVExe                 ; adresa obsluh
         dw        LinMenTM                 ; adresa podmenu
         dd        0                        ; n†vratov† adresa

         db        30                       ; poá†teán° pozice
         db        5                        ; poá†teán° ©†dek
         db        20                       ; ®°©ka
         db        10                       ; vò®ka

DBIMVPol db        1+bit7,7,'C á†rka'
         db        1+bit7,8,'St©edn°k'
         db        1+bit7,9,'Tabul†tor'
         db        1+bit7,3,'R†m'
         db        1+bit7,6,'Pozice'
         db        bit6+bit7,0
         db        1,6,'Vloëit'
         db        1,8,'Na konec'

DBIMVBlk db        0,0,0,0,0,0,0
DBIMVSwc db        0,0,0,0,0
DBIMVTit db        6,'import'

HelpS    SEGMENT   BYTE PUBLIC
DBIMVHlp db        36,'DatovÇ poloëky oddàleny á†rkou ","'
         db        40,'DatovÇ poloëky oddàleny st©edn°kem ";"'
         db        35,'DatovÇ poloëky oddàleny tabul†torem'
         db        44,'DatovÇ poloëky oddàleny znakem r†meáku "≥"'
         db        57,'DatovÇ poloëky rozli®eny pozic° na ©†dku (bez oddàlovaáñ)'
         db        40,'Vloëen° novòch z†znamñ od pozice kurzoru'
         db        39,'P©id†n° novòch z†znamñ na konec seznamu'
HelpS    ENDS

DBIMVExe dd        EditBIm1                 ; á†rka
         dd        EditBIm1                 ; st©edn°k
         dd        EditBIm1                 ; tabul†tor
         dd        EditBIm1                 ; r†m
         dd        EditBIm1                 ; pozice
         dd        EditBIm2                 ; vloëit
         dd        EditBIm3                 ; na konec

; ------ zad†n° souboru k importu

DBIMSLin label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        DBIMLPol                 ; zaá†tek definice poloëek menu
         dw        DBIMLHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@ImportDatDoDatabazovehoSouboru ; á°slo str†nky velkÇ n†povàdy
         dw        DBIMLBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        DBIMLTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        20                       ; poá†teán° pozice okna
         db        0                        ; poá†teán° ©†dek okna
         db        43                       ; ®°©ka okna
         db        8                        ; vò®ka okna

         dw        100                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        1                        ; celkovò poáet ©†dkñ
         dw        1                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ - soubor
         db        2,'?*    '               ; zak†zanÇ znaky

         db        HistFile                 ; historie souborñ
         db        0                        ; poáet p©edvoleb

; ------ poloëky voleb

DBIMLPol db        bit6,28,'JmÇno souboru k importu dat:'
         db        0,0
         db        bit6+bit7,0
         db        1,6,'Import'
         db        1,6,'N†vrat'

DBIMLBlk db        0,0,0                    ; blokovac° tabulka

DBIMLTit db        6,'import'

HelpS    SEGMENT   BYTE PUBLIC
DBIMLHlp db        55,'Zadejte jmÇno souboru, z kterÇho budou data importov†na'
         db        53,'Proveden° importu dat ze zadanÇho (textovÇho) souboru'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

; -----------------------------------------------------------------------------
;        okno editoru MEMO pole
; -----------------------------------------------------------------------------
;˛
MemoMnu  label     byte

         db        16                       ; typ menu - editace textu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet poloëek menu
         dw        1                        ; celkovò poáet poloëek menu

         dw        0                        ; zaá†tek definice poloëek menu
         dw        TxtMnHl1                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@EditaceTextovehoPoleDatabaze ; á°slo str†nky velkÇ n†povàdy
         dw        0                        ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        MemMnTit                 ; adresa titulu okna
         dw        LinMenTM                 ; adresy obsluh
         dw        LinMenTM                 ; adresa podmenu
         dd        0                        ; n†vratov† adresa

         db        0                        ; poá†teán° pozice okna
         db        1                        ; poá†teán° ©†dek okna
         db        80                       ; ®°©ka okna
         db        21                       ; vò®ka okna

TextSegm dw        0                        ; aktivn° segment s textem

MemMnTit db        12,'textovÇ pole'

;HelpS    SEGMENT   BYTE PUBLIC              ; n†povàda k menu
;MemMnHl1 db        93,'F2 uloë, F3 zaá., F4 konec, F5 kopie, F6 p©esun, F7 hledej, F8 zru®, F10 menu'
;MemMnHl2 db        87,'Nahradit nalezenò ©etàzec ?  Enter nebo A=Ano, N=Ne, V=V®echny, Esc=p©eru®en°'
;HelpS    ENDS

; ------ data pro datab†zi

OpnKnvHl db        17,'Konvertuji k¢d...'

;MaxCPole db        78                       ; max. zobrazen† dÇlka text. pole>10
DBFEParm db        bit2                     ; parametry
                                            ;   bit 0: 1=je editace z†znamu
                                            ;   bit 1: 1=edit.buffer modifikov†n
                                            ;   bit 2: 1=zapnut INSERT
                                            ;   bit 3: 1=modifikace á°sel. pole
                                            ;   bit 4: 1=prohl°ëeá TEXT
                                            ;   bit 5: 1=oznaáenÇ z†znamy/0=v®e
                                            ;          1=od kurzoru, 0=na konec
                                            ;   bit 6: 1=definice novÇho z†hlav°
                                            ;          0=modifik. starÇho z†hl.
                                            ;   bit 7: 1=datum z†hlav° se nemàn°

;DBFEPar2 db        0                        ; parametry 2
;                                            ;   bit 0: 1=je nastaven° ®°©ky pole
;                                            ;   bit 1: 1=oznaáen° p©i hled†n°
;                                            ;   bit 2: 1=nulov†n° oznaáen° hled†n°

DBExpPar db        bit0                     ; parametry pro export
                                            ;   bit 0: 1=odàlovaá á†rka
                                            ;   bit 1: 1=oddàlovaá st©edn°k
                                            ;   bit 2: 1=oddàlovaá tabul†tor
                                            ;   bit 3: 1=oddàlovaá r†m
                                            ;   bit 4: 1=poloëky uráeny pozic°

DBImpPar db        bit0                     ; parametry pro import
                                            ;   bit 0: 1=odàlovaá á†rka
                                            ;   bit 1: 1=oddàlovaá st©edn°k
                                            ;   bit 2: 1=oddàlovaá tabul†tor
                                            ;   bit 3: 1=oddàlovaá r†m
                                            ;   bit 4: 1=poloëky uráeny pozic°

DBZobOld dd        -1                       ; obslouëenò zobraz. z†znam
                                            ;   HIGH=-1 ... text nen° naáten

DBZobPar db        0                        ; parametry pro rychlÇ zobrazen°
                                            ;   bit 0: 1=funkce vypnuta
                                            ;   bit 1: 1=nen° MEMO pole
                                            ;   bit 2: 1=z†kaz p©i prov†dàn° funkce

                                            ;   bit 4: 1=nen° text MEMO pole

DBSelMou db        0                        ; parametry pro oznaáov†n° my®°
                                            ;   bit 0: 1=je oznaáov†n° my®°
                                            ;   bit 1: 1=oznaáen° poloëek
                                            ;          0=odznaáen° poloëek

DBZobSeg dw        0                        ; segment s naátenòm textem MEMO

Data     ENDS

         END

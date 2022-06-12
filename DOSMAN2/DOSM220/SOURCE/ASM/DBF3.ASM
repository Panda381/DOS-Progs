
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                            D A T A B è Z E - á†st 3
;
;                 Obsluha editace poloëek, oznaáen°, export a import dat
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

; -----------------------------------------------------------------------------
;                            UlozDBF
;              uloëen° editovanÇho z†znamu z bufferu na disk
; -----------------------------------------------------------------------------
; VSTUP: ES=segment definice okna
;        SI=adresa definice okna
;        DS=datovò segment
; VùSTUP: CY=chyba
; -----------------------------------------------------------------------------

UlozDBF  PROC      NEAR

; ------ test, zda byl buffer modifikov†n

         test      byte ptr ds:[DBFEParm],bit1 ; byl buffer modifikov†n ?
         jnz       UlozDBF1                 ; buffer byl modifikov†n
         ret

UlozDBF1:and       byte ptr ds:[DBFEParm],not bit1 ; zru®en° p©°znaku modifikace

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      di

; ------ ukonáen° editace á°selnÇ poloëky

         call      EditNmEn                 ; ukonáen° editace á°selnÇ poloëky

; ------ aktualizace adres†©e

         push      si
         mov       si,offset DBFSoub        ; jmÇno souboru
         call      far ptr ModiWDir         ; aktualizace adres†©e
         pop       si
         call      DBFAdrES                 ; aktualizace adresy okna -> ES

; ------ uloëen° z†znamu na disk

         mov       di,es:[DBFAdrE]          ; editaán° buffer
         mov       dx,es:[DBFAktZ+2]        ; á°slo z†znamu HIGH
         mov       ax,es:[DBFAktZ]          ; á°slo z†znamu LOW
         call      far ptr SetDBF           ; uloëen° z†znamu na disk
         jc        UlozDBF9                 ; chyba z†pisu

; ------ test, zda je to platnò z†znam

         cmp       dx,es:[DBFMaxZ+2]        ; je to platnò z†znam ?
         jne       UlozDBF4
         cmp       ax,es:[DBFMaxZ]
UlozDBF4:jb        UlozDBF7                 ; je to platnò z†znam

; ------ novò poáet z†znamñ v souboru

         add       ax,1
         adc       dx,0
         mov       es:[DBFMaxZ],ax          ; novò poáet z†znamñ
         mov       es:[DBFMaxZ+2],dx

; ------ z†pis koncovÇho znaku EOF

         call      UlozDEOF                 ; z†pis koncovÇho EOF

; ------ z†pis z†hlav° souboru

UlozDBF7:call      far ptr HlavDBF          ; z†pis z†hlav° souboru
         mov       word ptr es:[DBFNumD],0  ; datovò buffer je neplatnò
         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

UlozDBF9:pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

UlozDBF  ENDP

; ------ z†pis koncovÇho znaku EOF (okno ES)

UlozDEOF PROC      NEAR

         push      ax
         push      cx
         push      si
         push      es

         mov       ax,es:[DBFIdent]         ; identifik†tor souboru
         push      cs
         pop       es                       ; ES <- segment znaku EOF
         mov       si,offset UlozDBFE       ; znak EOF
         mov       cx,1                     ; zap°®e se 1 znak
         call      far ptr WritFile         ; z†pis koncovÇho znaku EOF
         xor       cx,cx                    ; CX <- 0
         call      far ptr WritFile         ; useknut° konce souboru

         pop       es
         pop       si
         pop       cx
         pop       ax
         ret

UlozDEOF ENDP

UlozDBFE db        EOF                      ; koncovò znak EOF

; -----------------------------------------------------------------------------
;        BS: zru®en° znaku p©ed kurzorem
; -----------------------------------------------------------------------------

; ------ test, zda je operace povolena

EditBBS: test      byte ptr ds:[DBFEParm],bit0 ; je editace ?
         jz        EditBBS8                 ; nen° editace
         test      byte ptr es:[DBFParm],bit1 ; je z†kaz z†pisu ?
         jnz       EditBBS8                 ; je z†kaz z†pisu

; ------ posun kurzoru vlevo

         call      EditPLft                 ; posun kurzoru vlevo
         jc        EditBBS8                 ; nen° dal®° pozice

; ------ adresa popisovaáe poloëky -> ES:BP a adresa kurzoru -> ES:DI

         mov       cx,es:[DBFAktP]          ; CX <- aktivn° poloëka
         mov       bp,es:[DBFAdrP]          ; BP <- adresa popisovaáe
         mov       di,es:[DBFAdrE]          ; adresa bufferu
         inc       di                       ; adresa prvn° poloëky
         jcxz      EditBBS4                 ; je prvn° poloëka
EditBBS2:add       di,es:[bp+DBFDelX]       ; adresa dal®° poloëky
         add       bp,DBFX                  ; adresa dal®°ho popisovaáe
         loop      EditBBS2                 ; nalezen° poloëky
EditBBS4:add       di,es:[DBFKurz]          ; p©iáten° offsetu kurzoru

; ------ pro MEMO pole se funkce ignoruje (needituje se)

         test      byte ptr es:[bp+DBFParX],bit5 ; je MEMO pole ?
         jnz       EditBBS8                 ; je MEMO pole

; ------ je-li INSERT zapnut, bude n†sledovat funkce DELETE

         test      byte ptr ds:[DBFEParm],bit2 ; je zapnut INSERT ?
         jnz       EditBDlt                 ; je zapnut INSERT - bude DELETE

; ------ uloëen° znaku mezery

         mov       byte ptr es:[di]," "     ; uloëen° znaku mezery
         or        byte ptr ds:[DBFEParm],bit1 ; p©°znak modifikace bufferu

; ------ p©°znak modifikace á°selnÇho pole

         test      byte ptr es:[bp+DBFParX],bit1+bit2+bit3+bit6 ; á°slo/datum/áas ?
         jz        EditBBS8                 ; nen° á°slo/datum/áas
         or        byte ptr ds:[DBFEParm],bit3 ; modifikace á°selnÇho pole
EditBBS8:ret                                ; (sem se sk†áe i z EditBDlt !)

; -----------------------------------------------------------------------------
;        Delete: zru®en° znaku za kurzorem
; -----------------------------------------------------------------------------

; ------ test, zda je operace Delete povolena

EditBDlt:test      byte ptr ds:[DBFEParm],bit0 ; je editace ?
         jz        EditBBS8                 ; nen° editace
         test      byte ptr es:[DBFParm],bit1 ; je z†kaz z†pisu ?
         jnz       EditBBS8                 ; je z†kaz z†pisu

; ------ adresa popisovaáe poloëky -> ES:BP a adresa kurzoru -> ES:DI

         mov       cx,es:[DBFAktP]          ; CX <- aktivn° poloëka
         mov       bp,es:[DBFAdrP]          ; adresa popisovaáe
         mov       di,es:[DBFAdrE]          ; adresa bufferu
         inc       di                       ; adresa prvn° poloëky
         jcxz      EditBDl2                 ; je prvn° poloëka
EditBDl1:add       di,es:[bp+DBFDelX]       ; adresa dal®° poloëky
         add       bp,DBFX                  ; adresa dal®°ho popisovaáe
         loop      EditBDl1                 ; nalezen° poloëky
EditBDl2:add       di,es:[DBFKurz]          ; p©iáten° offsetu kurzoru

; ------ stanoven° parametrñ pro áas

         test      byte ptr es:[bp+DBFParX],bit6 ; je áas ?
         jz        EditBDl3                 ; nen° áas
         mov       cl,es:[DBFKurz]          ; CL <- kurzor
         and       cl,bit0                  ; p©°znak lichosti
         xor       cl,bit0                  ; poáet zbylòch bitñ
         jmp       short EditBD56           ; zru®en° znaku

; ------ stanoven° parametrñ pro datum

EditBDl3:test      byte ptr es:[bp+DBFParX],bit3 ; je datum ?
         jz        EditBDl4                 ; nen° datum

         push      si
         mov       si,es:[DBFKurz]          ; kurzor
         mov       cl,cs:[si+EditBIIT]      ; poáet zbylòch pozic
         pop       si
         jmp       short EditBDl6

; ------ pro MEMO pole se funkce ignoruje (needituje se)

EditBDl4:test      byte ptr es:[bp+DBFParX],bit5 ; je to MEMO pole ?
         jnz       EditBDl9                 ; je to MEMO pole

; ------ stanoven° parametrñ pro á°slo

         test      byte ptr es:[bp+DBFParX],bit1+bit2 ; je to á°slo ?
         jz        EditBDl7                 ; nen° to á°slo

         push      di
         mov       di,es:[bp+DBFNamX]       ; popisovaá poloëky
         mov       cx,es:[di+16]            ; CL <- dÇlka pol., CH <- desetiny
         or        ch,ch                    ; jsou desetiny ?
         jz        EditBDl5                 ; nejsou desetiny
         sub       cl,ch                    ; odeáten° desetin
         dec       cx                       ; oddàlovac° teáka -> CL=cel† á†st
EditBDl5:pop       di
         sub       cl,es:[DBFKurz]          ; je celoá°seln† á†st ?
         ja        EditBDl6                 ; je celoá°seln† á†st

         add       ch,cl                    ; zbytek do konce poloëky
         mov       cl,ch                    ; zbytek do konce poloëky
EditBD56:inc       cx                       ; bez oddàlovac° teáky

EditBDl6:or        byte ptr ds:[DBFEParm],bit3 ; modifikace á°selnÇho pole
         jmp       short EditBDl8

; ------ stanoven° parametrñ pro ostatn° poloëky

EditBDl7:mov       cl,es:[bp+DBFDelX]       ; dÇlka poloëky (bajtñ)
         sub       cl,es:[DBFKurz]          ; zbytek do konce poloëky

; ------ vymaz†n° znaku ES:DI, dÇlka pole CL

EditBDl8:call      EditBDlC                 ; vymaz†n° znaku
         or        byte ptr ds:[DBFEParm],bit1 ; p©°znak modifkace bufferu
EditBDl9:ret

; -----------------------------------------------------------------------------
;        zru®en° znaku z pozice ES:DI, dÇlka pole CL
; -----------------------------------------------------------------------------

EditBDlC PROC      NEAR

         push      si
         push      di
         push      cx

         mov       ch,0
         cld
         mov       si,di
         inc       si
         dec       cx
         rep       movs byte ptr es:[di],es:[si] ; p©°sun zbytku textu
         mov       byte ptr es:[di]," "     ; vymaz†n° posledn°ho znaku

         pop       cx
         pop       di
         pop       si
         ret

EditBDlC ENDP

; -----------------------------------------------------------------------------
;        vloëen° znaku
; -----------------------------------------------------------------------------
;˛
EditBICh PROC      NEAR

; ------ test, zda je operace povolena

         test      byte ptr ds:[DBFEParm],bit0 ; je editace ?
         jnz       EditBIC1                 ; je editace
         cmp       bx,1c0dh                 ; je ENTER ?
         je        EditBI11                 ; je ENTER -> dal®° poloëka
EditBIC0:jmp       EditBMn8                 ; n†vrat

; ------ test, zda je platnò znak

EditBIC1:or        bx,bx                    ; platn† kl†vesa ?
         jz        EditBIC0                 ; nen° platn† kl†vesa
         cmp       bx,1c0dh                 ; ENTER ?
         jne       EditBI12                 ; nen° ENTER
         test      byte ptr ds:[DBFEParm],bit3 ; modifikace á°sla ?
         jnz       EditBI14                 ; je modifikace á°sla
EditBI11:jmp       EditBEnt                 ; ENTER

EditBI12:test      byte ptr es:[DBFParm],bit1 ; je z†kaz z†pisu ?
         jnz       EditBIC0                 ; je z†kaz z†pisu
         cmp       bh,0
         je        EditBI14                 ; znak s Alt-
         cmp       bl,EOF
         je        EditBIC0                 ; zak†zanò znak EOF
         cmp       bl,CR
         je        EditBIC0                 ; zak†zanò znak CR
         cmp       bl,LF
         je        EditBIC0                 ; zak†zanò znak LF
         cmp       bx,300h                  ; Ctrl-@
         je        EditBI14                 ; znak Ctrl-@ je povolen
         cmp       bl," "
         jb        EditBIC0                 ; ©°dic° kl†vesa s Ctrl-

; ------ adresa popisovaáe poloëky -> ES:BP a adresa kurzoru -> ES:DI

EditBI14:mov       cx,es:[DBFAktP]          ; CX <- aktivn° poloëka
         mov       bp,es:[DBFAdrP]          ; adresa popisovaáe
         mov       di,es:[DBFAdrE]          ; adresa bufferu
         inc       di                       ; adresa prvn° poloëky
         jcxz      EditBI16                 ; je prvn° poloëka
EditBI15:add       di,es:[bp+DBFDelX]       ; adresa dal®° poloëky
         add       bp,DBFX                  ; adresa dal®°ho popisovaáe
         loop      EditBI15                 ; nalezen° poloëky
EditBI16:add       di,es:[DBFKurz]          ; p©iáten° offsetu kurzoru

; ------ MEMO pole - ignorov†n° znaku

         test      byte ptr es:[bp+DBFParX],bit5 ; je to MEMO pole ?
         jz        EditBIC2                 ; nen° MEMO pole
EditBI19:jmp       EditBIC9                 ; pro MEMO pole zak†z†no

; ------ logickÇ pole

EditBIC2:test      byte ptr es:[bp+DBFParX],bit4 ; je to logickÇ pole ?
         jz        EditBIC3                 ; nen° to logickÇ pole

         xchg      ax,bx                    ; AL <- znak
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         xchg      ax,bx                    ; BL <- znak

         mov       bh," "                   ; hodnota pro mezeru
         cmp       bl,"?"                   ; nedefinovanò znak ?
         je        EditBI24                 ; nedefinovanò znak
         cmp       bl," "                   ; mezera ?
         je        EditBI24                 ; mezera

         mov       bh,"T"                   ; hodnota pro TRUE
         cmp       bl,"A"
         je        EditBI24                 ; je "Ano"
         cmp       bl,"Y"
         je        EditBI24                 ; je "Yes"
         cmp       bl,"J"
         je        EditBI24                 ; je "Ja"
         cmp       bl,"T"
         je        EditBI24                 ; je "True"

         mov       bh,"F"                   ; hodnota pro FALSE
         cmp       bl,"F"
         je        EditBI24                 ; je "False"
         cmp       bl,"N"
         jne       EditBI19                 ; nepovolenò znak

EditBI24:mov       es:[di],bh               ; uloëen° znaku
         jmp       EditBIC8

; ------ datum a áas

EditBIC3:test      byte ptr es:[bp+DBFParX],bit3+bit6 ; je datum/áas ?
         jnz       EdiBIC31
         jmp       EditBIC4                 ; nen° datum ani áas

EdiBIC31:cmp       bl,CR
         je        EdiBIC32                 ; ENTER - konec editace
         cmp       bl,"."
         je        EdiBIC32                 ; teáka - konec editace
         cmp       bl,ds:[OddelDes]         ; je to oddàlovaá desetin ?
         je        EdiBIC32                 ; je to oddàlovaá desetin

         call      EditTstN                 ; test, zda to je á°slice/mezera
         jc        EditBI19                 ; nen° to á°slice

EdiBIC32:or        byte ptr ds:[DBFEParm],bit3 ; p©°znak modifikace á°sel. pole
         push      si
         mov       si,es:[DBFKurz]          ; kurzor
         mov       cl,cs:[si+EditBIIT]      ; poáet zbylòch pozic
         pop       si

         test      byte ptr es:[bp+DBFParX],bit6 ; je to áas ?
         jz        EdiBIC33                 ; nen° to áas
         mov       cl,es:[DBFKurz]          ; kurzor
         and       cl,bit0
         xor       cl,bit0
         inc       cx                       ; poáet znakñ do konce pole

EdiBIC33:call      EditBIII                 ; odsun zbytku textu
         mov       es:[di],bl               ; uloëen° znaku
         mov       cx,es:[DBFAktP]          ; aktivn° poloëka
         cmp       bl,CR
         je        EdiBIC34
         cmp       bl,"."
         je        EdiBIC34
         cmp       bl,ds:[OddelDes]         ; je to oddàlovaá desetin ?
         je        EdiBIC34                 ; oddàlovaá desetin
         jmp       EditBIC8                 ; posun kurzoru vpravo

EdiBIC34:call      EditPRgh                 ; posun kurzoru vpravo
         jc        EdiBIC36
         cmp       cx,es:[DBFAktP]          ; poloëka zmànàna ?
         jne       EdiBIC36                 ; poloëka zmànàna
         cmp       bl,CR
         je        EdiBIC34

         test      byte ptr es:[bp+DBFParX],bit6 ; je to áas ?
         jz        EdiBIC35                 ; nen° to áas
         test      byte ptr es:[DBFKurz],bit0
         jnz       EdiBIC34
         jmp       short EdiBIC36

EdiBIC35:cmp       byte ptr es:[DBFKurz],0
         je        EdiBIC36
         cmp       byte ptr es:[DBFKurz],4
         je        EdiBIC36
         cmp       byte ptr es:[DBFKurz],6
         jne       EdiBIC34
EdiBIC36:jmp       EdiBIC88

; ------ á°selnÇ pole

EditBIC4:test      byte ptr es:[bp+DBFParX],bit1+bit2 ; je á°slo ?
         jz        EditBIC7                 ; nen° á°slo

         cmp       bl,"-"
         je        EditBI41
         cmp       bl,"+"
         je        EditBI41
         cmp       bl,"."
         je        EditBI41
         cmp       bl,ds:[OddelDes]         ; oddàlovaá desetin ?
         je        EditBI41
         cmp       bl,CR
         je        EditBI41

         call      EditTstN                 ; test, zda to je á°slice/mezera
         jc        EditBIC9                 ; nen° to á°slice

EditBI41:push      di
         mov       di,es:[bp+DBFNamX]       ; popisovaá poloëky
         mov       cx,es:[di+16]            ; CL <- dÇlka pol., CH <- desetiny
         cmp       ch,0                     ; jsou desetiny ?
         je        EditBI42                 ; nejsou desetiny
         sub       cl,ch                    ; odeáten° desetin
         dec       cx                       ; oddàlovac° teáka -> CL=cel† á†st
EditBI42:pop       di

         or        byte ptr ds:[DBFEParm],bit3 ; p©°znak modifikace á°sel. pole
         sub       cl,es:[DBFKurz]          ; je celoá°seln† á†st ?
         ja        EditBI44                 ; je celoá°seln† á†st
         add       ch,cl                    ; zbytek do konce poloëky
         mov       cl,ch                    ; zbytek do konce poloëky
         inc       cx                       ; bez oddàlovac° teáky

EditBI44:call      EditBIII                 ; odsun zbytku textu
         mov       es:[di],bl               ; uloëen° znaku

         mov       cl,es:[DBFAktP]          ; aktivn° poloëka LOW

         inc       di

         cmp       bl,CR
         je        EdiBIC45
         cmp       bl,ds:[OddelDes]         ; oddàlovaá desetin ?
         je        EdiBIC45                 ; oddàlovaá desetin
         cmp       bl,"."
         jne       EditBIC8

EdiBIC45:inc       di
         call      EditPRgh                 ; posun kurzoru vpravo
         jc        EdiBIC88
         cmp       cl,es:[DBFAktP]          ; poloëka zmànàna ?
         jne       EdiBIC88                 ; poloëka zmànàna
         cmp       es:[di-1],bl
         jne       EdiBIC45
         jmp       short EdiBIC88

; ------ znakovÇ pole

EditBIC7:mov       cl,es:[bp+DBFDelX]       ; dÇlka poloëky
         sub       cl,es:[DBFKurz]          ; poáet znakñ za kurzorem
EditBI76:call      EditBIII                 ; odsun zbytku textu
EditBI77:mov       es:[di],bl               ; uloëen° znaku

; ------ znak platnò - posun kurzoru

EditBIC8:call      EditPRgh                 ; posun kurzoru vpravo
EdiBIC88:or        byte ptr ds:[DBFEParm],bit1 ; p©°znak modifikace
EditBIC9:ret

EditBICh ENDP

EditBIIT db        4,3,2,1,2,1,2,1          ; poáty zbylòch pozic v poli data

; -----------------------------------------------------------------------------
;        odsun CX znakñ od kurzoru DI
; -----------------------------------------------------------------------------

EditBIII PROC      NEAR

         test      byte ptr ds:[DBFEParm],bit2 ; je zapnut INSERT ?
         jz        EditBII7                 ; nen° zapnut INSERT

EditBII2:push      si
         push      di
         push      cx

         mov       ch,0
         dec       cx                       ; bez 1 znaku
         add       di,cx
         mov       si,di                    ; posledn° znak
         dec       si                       ; p©edposledn° znak
         std
         rep       movs byte ptr es:[di],es:[si] ; odsun zbytku textu o pozici

         pop       cx
         pop       di
         pop       si
EditBII7:ret

EditBIII ENDP

; -----------------------------------------------------------------------------
;        test, zda je znak BL á°slice (CY=nen°)
; -----------------------------------------------------------------------------

EditTstN PROC      NEAR

         cmp       bl," "
         je        EdiTstN1
         cmp       bl,"0"
         jb        EdiTstN1
         cmp       bl,"9"+1
         cmc
EdiTstN1:ret

EditTstN ENDP

; -----------------------------------------------------------------------------
;        korekce aktivn°ho á°selnÇho pole (segment okna ES)
; -----------------------------------------------------------------------------

EditNmEn PROC      NEAR

         test      byte ptr ds:[DBFEParm],bit3 ; numerickÇ pole modifikov†no ?
         jnz       EditMnE0                 ; modifikov†no
         ret

; ------ £schova registrñ

EditMnE0:and       byte ptr ds:[DBFEParm],not bit3 ; zru®en° p©°znaku modifikace
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds

         push      es
         pop       ds                       ; DS <- segment bufferu

; ------ adresa aktivn° poloëky -> DS:DI a popisovaáe poloëky -> DS:BX

         mov       cx,ds:[DBFAktP]          ; aktivn° poloëka
         mov       bx,ds:[DBFAdrP]          ; ukazatel poloëek
         mov       si,ds:[DBFAdrE]          ; editaán° buffer
         inc       si                       ; zaá†tek prvn° poloëky
         jcxz      EditNmE2                 ; je prvn° poloëka
EditNmE1:add       si,ds:[bx+DBFDelX]       ; adresa dal®° poloëky
         add       bx,DBFX                  ; adresa dal®°ho popisovaáe
         loop      EditNmE1                 ; dal®° poloëka
EditNmE2:mov       di,si                    ; DI <- zaá†tek poloëky
         cld

; ------ korekce data (CH=0)

         test      byte ptr ds:[bx+DBFParX],bit3 ; je to datum ?
         jz        EditNmE3                 ; nen° datum

         mov       cl,4                     ; dÇlka poloëky
         call      EditNKR                  ; korekce poloëky data

         push      si
         dec       si                       ; 4. á°slice roku
         dec       si                       ; 3. á°slice roku
         call      EditNKT                  ; korekce á°slice - des°tky roku
         dec       si                       ; 2. á°slice roku
         call      EditNKT                  ; korekce á°slice - stovky roku
         dec       si                       ; 1. á°slice roku
         call      EditNKT                  ; korekce á°slice - tis°cilet°

         cmp       word ptr ds:[si],"00"    ; zad†no stolet° ?
         jne       EditNE25                 ; stolet° zad†no
         mov       word ptr ds:[si],"91"    ; stolet° 19xx
         cmp       byte ptr ds:[si+2],"3"   ; rok 1930 a v°ce ?
         jae       EditNE25                 ; je rok 1930 a v°ce
         mov       word ptr ds:[si],"02"    ; stolet° 20xx
EditNE25:pop       si

         mov       ax,"01"                  ; màs°c minim†lnà
         mov       dx,"12"                  ; màs°c maxim†lnà
         call      EditNKO                  ; omezen° màs°ce
         mov       dx,"31"                  ; den maxim†lnà
         call      EditNKO                  ; omezen° dne
         jmp       short EditNE39

; ------ test, zda je áas

EditNmE3:test      byte ptr ds:[bx+DBFParX],bit6 ; je to áas ?
         jz        EditNmE4                 ; nen° to áas

         mov       ax,"00"                  ; hodina minim†lnà
         mov       dx,"23"                  ; hodina maxim†lnà
         call      EditNKO                  ; omezen° hodiny
         mov       dx,"59"                  ; minuta maxim†lnà
         call      EditNKO                  ; omezen° minuty
         call      EditNKO                  ; omezen° sekundy
EditNE39:jmp       short EditNmE9

; ------ test, zda je numerick† poloëka

EditNmE4:test      byte ptr ds:[bx+DBFParX],bit1+bit2 ; je á°seln† poloëka ?
         jz        EditNE39                 ; nen° á°seln† poloëka

; ------ p©°prava dÇlky poloëky -> CL + CH

         push      di
         mov       di,ds:[bx+DBFNamX]       ; popisovaá poloëky
         mov       cx,ds:[di+16]            ; CL <- dÇlka poloëky, CH <- deset.
         or        ch,ch                    ; jsou desetiny ?
         jz        EditNmE5                 ; nejsou desetiny
         sub       cl,ch                    ; odeáten° desetin
         dec       cx                       ; bez oddàlovac° teáky
EditNmE5:pop       di

; ------ korekce celoá°selnÇ á†sti

         push      cx
         mov       ch,0                     ; CX = dÇlka celoá°selnÇ á†sti
         call      EditNKR                  ; korekce celoá°selnÇ á†sti
         pop       cx
         mov       cl,ch                    ; CL <- dÇlka desetinnÇ á†sti
         mov       ch,0                     ; CX = dÇlka desetinnÇ á†sti
         jcxz      EditNmE9                 ; nejsou desetiny

; ------ korekce desetinnÇ á†sti

         inc       si                       ; zaá†tek poloëky
         inc       di                       ; zaá†tek poloëky
         mov       bx,di                    ; BX <- zaá†tek poloëky
         add       bx,cx                    ; BX = konec poloëky

EditNmE6:cmp       si,bx
         jae       EditNmE7                 ; je konec bufferu
         lodsb                              ; naáten° znaku
         cmp       al,"."
         je        EditNmE7                 ; je konec á°sla
         cmp       al,cs:[DBFOdDes]         ; je oddàlovaá desetin ?
         je        EditNmE7                 ; konec á°sla
         cmp       al,CR
         je        EditNmE7                 ; je konec á°sla
         cmp       al,"0"
         jb        EditNmE6                 ; nen° á°slice - ignoruje se
         cmp       al,"9"
         ja        EditNmE6                 ; nen° á°slice - ignoruje se
         stosb                              ; uloëen° á°slice
         dec       cx                       ; sn°ëen° á°taáe znakñ
         jmp       short EditNmE6           ; dal®° znak

EditNmE7:mov       al,"0"
         rep       stosb                    ; vyplnàn° zbytku poloëky nulami

; ------ n†vrat registrñ

EditNmE9:pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

EditNmEn ENDP

; ------ korekce á°slice DS:SI (nastaven° na "0", nen°-li to znak á°slice)

EditNKT: cmp       byte ptr ds:[si],"0"
         jb        EditNKT1
         cmp       byte ptr ds:[si],"9"
         jbe       EditNKT2
EditNKT1:mov       byte ptr ds:[si],"0"
EditNKT2:ret

; ------ korekce 2-á°sl° DS:SI s omezen°m na AX aë DX (ASCII) (niá° CX !)

EditNKO: mov       cx,2                     ; dÇlka poloëky
         call      EditNKR                  ; korekce poloëky (2 znaky)

         push      si
         dec       si                       ; 2. á°slice
         dec       si                       ; 1. á°slice
         call      EditNKT                  ; korekce 1. á°slice
         mov       cx,ds:[si]               ; 2 znaky á°sla
         xchg      cl,ch                    ; oprava po©ad° á°slic
         cmp       ax,cx                    ; minim†ln° á°slo
         jbe       EditNKO2                 ; je to OK
         mov       cx,ax                    ; CX <- minim†ln° á°slo
EditNKO2:cmp       dx,cx                    ; maxim†ln° á°slo
         jae       EditNKO4                 ; je to OK
         mov       cx,dx                    ; CX <- maxim†ln° á°slo
EditNKO4:xchg      cl,ch                    ; n†vrat po©ad° á°slic
         mov       ds:[si],cx               ; uloëen° á°slic
         pop       si
         ret

; -----------------------------------------------------------------------------
;        korekce á°sla s posunem vpravo
; -----------------------------------------------------------------------------
; VSTUP: DS:SI,DI=zaá†tek bufferu á°sla
;        CX=dÇlka bufferu á°sla
;        CLD
; VùSTUP: DS:DI,SI=n†sleduj°c° adresa za bufferem
; -----------------------------------------------------------------------------

; ------ £schova registrñ

EditNKR: add       di,cx                    ; konec á°sla
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

         mov       bx,di                    ; £schova adresy konce bufferu
         mov       dx,si                    ; £schova adresy zaá†tku bufferu

; ------ nalezen° konce á°sla (nalezen° oddàlovac° teáky nebo konce bufferu)

EditNKR1:cmp       si,bx                    ; je konec bufferu ?
         jae       EditNKR2                 ; je konec bufferu á°sla
         lodsb                              ; naáten° znaku
         cmp       al,CR                    ; ENTER
         je        EditNKR2                 ; je konec á°sla
         cmp       al,cs:[DBFOdDes]         ; oddàlovac° teáka ?
         je        EditNKR2                 ; je oddàlovac° teáka
         cmp       al,"."                   ; je oddàlovac° teáka ?
         jne       EditNKR1                 ; nalezen° oddàlovac° teáky

; ------ p©enesen° á°sla na konec bufferu

EditNKR2:mov       ah,0                     ; p©°znak - nen° znamÇnko
EditNKR3:cmp       si,dx                    ; je jië zaá†tek bufferu ?
         jbe       EditNKR5                 ; je jië zaá†tek bufferu
         dec       si
         mov       al,ds:[si]               ; znak á°sla
         cmp       al,"-"                   ; znamÇnko ?
         jne       EditNKR4
         mov       ah,al                    ; £schova znamÇnka "-"
         jmp       short EditNKR3

EditNKR4:cmp       al,"0"
         jb        EditNKR3
         cmp       al,"9"
         ja        EditNKR3
         dec       di
         mov       ds:[di],al               ; uloëen° znaku á°slice
         jmp       short EditNKR3

; ------ vypu®tàn° £vodn°ch nul á°sla

EditNKR5:cmp       di,bx                    ; je jië konec bufferu ?
         jae       EditNKR6                 ; je jië konec bufferu
         cmp       byte ptr ds:[di],"0"     ; je nula ?
         jne       EditNKR6                 ; nen° nula
         inc       di                       ; vypu®tàn° nuly
         jmp       short EditNKR5

; ------ zaji®tàn° alespo§ jednÇ nuly, nen°-li jin† á°slice

EditNKR6:cmp       di,bx                    ; je nàjak† á°slice ?
         jb        EditNKR7                 ; je nàjak† á°slice
         dec       di
         mov       byte ptr ds:[di],"0"     ; alespo§ 1 nula

; ------ uloëen° znamÇnka "-"

EditNKR7:cmp       di,dx                    ; je jië zaá†tek bufferu ?
         jbe       EditNKR8                 ; je jië zaá†tek bufferu
         cmp       ah,"-"                   ; je znamÇnko "-" ?
         jne       EditNKR8                 ; nen° znamÇnko "-"
         dec       di
         mov       ds:[di],ah               ; uloëen° znamÇnka "-"

; ------ vymaz†n° zbytku bufferu

EditNKR8:cmp       di,dx                    ; je jië zaá†tek bufferu ?
         jbe       EditNKR9                 ; je jië zaá†tek bufferu
         dec       di
         mov       byte ptr ds:[di]," "     ; £vodn° mezera
         jmp       short EditNKR8

; ------ n†vrat registrñ

EditNKR9:pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         add       si,cx                    ; konec bufferu á°sla
         ret

; -----------------------------------------------------------------------------
;        posun za konec textu v poloëce (ES=segment okna)
; -----------------------------------------------------------------------------

EditTEnd PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx

; ------ posun na konec poloëky

         call      EditPEnd                 ; posun na konec poloëky

; ------ parametry poloëky

         mov       bx,es:[DBFAktP]          ; á°slo aktivn° poloëky
         shl       bx,1
         shl       bx,1
         shl       bx,1
         add       bx,es:[DBFAdrP]          ; adresa popisovaáe

; ------ poloëky D, T, L a M jsou jië na konci

         test      byte ptr es:[bx+DBFParX],bit3+bit4+bit5+bit6 ; poloëky DLMT ?
         jnz       EditTEn8                 ; poloëky jsou jië na konci

; ------ test, zda je na konci poloëky text

         call      EdiBGetC                 ; poskytnut° znaku na pozici kurzoru
         cmp       al," "                   ; je text ?
         jne       EditTEn4                 ; je text

; ------ nalezen° konce textu v poloëce

EditTEn2:cmp       byte ptr es:[DBFKurz],0  ; je jië zaá†tek poloëky ?
         je        EditTEn4                 ; je jië zaá†tek poloëky
         call      EditPLft                 ; posun kurzoru vlevo
         jc        EditTEn4                 ; chyba, ale zde by nemàla nastat
         call      EdiBGetC                 ; poskytnut° znaku na pozici kurzoru
         cmp       al," "                   ; je text ?
         je        EditTEn2                 ; je text - dal®° znak
         call      EditPRgh                 ; n†vrat kurzoru

; ------ korekce textovÇ poloëky

EditTEn4:mov       bx,es:[DBFKurz]          ; kurzor v poloëce
         call      EditPBeg                 ; kurzor na zaá†tek poloëky
EditTEn6:cmp       bx,es:[DBFKurz]          ; dosaëeno poëadovanÇ pozice ?
         je        EditTEn8                 ; dosaëeno poëadovanÇ pozice
         call      EditPRgh                 ; posun kurzoru vpravo
         jnc       EditTEn6

; ------ n†vrat registrñ

EditTEn8:pop       bx
         pop       ax
         ret

EditTEnd ENDP

; -----------------------------------------------------------------------------
;        poskytnut° znaku na pozici kurzoru -> AL (ES=segment okna)
; -----------------------------------------------------------------------------

EdiBGetC PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      si

; ------ p©°prava k vyhled†v†n° poloëky

         mov       si,es:[DBFAdrE]          ; editaán° buffer
         inc       si                       ; adresa prvn° poloëky
         mov       cx,es:[DBFAktP]          ; aktivn° poloëka
         mov       bx,es:[DBFAdrP]          ; adresa popisovaáñ poloëek

; ------ nalezen° aktivn° poloëky

         jcxz      EdiBGtC2                 ; je prvn° poloëka
EdiBGtC1:add       si,es:[bx+DBFDelX]       ; adresa dal®° poloëky
         add       bx,DBFX                  ; popisovaá dal®° poloëky
         loop      EdiBGtC1                 ; dal®° poloëka

; ------ adresa aktivn° poloëky

EdiBGtC2:add       si,es:[DBFKurz]          ; adresa aktivn° poloëky
         mov       al,es:[si]               ; znak na pozici kurzoru

; ------ n†vrat registrñ

         pop       si
         pop       cx
         pop       bx
         ret

EdiBGetC ENDP

; -----------------------------------------------------------------------------
;        posun na konec poloëky (ES=segment okna)
; -----------------------------------------------------------------------------

EditPEnd PROC      NEAR

; ------ £schova registrñ

         push      ax

; ------ nalezen° zaá†tku ©†dku

EditPEn2:mov       ax,es:[DBFAktP]          ; aktivn° poloëka
         call      EditPRgh                 ; posun kurzoru vpravo
         jc        EditPEn6                 ; nen° dal®° pozice
         cmp       ax,es:[DBFAktP]          ; je dal®° poloëka ?
         je        EditPEn2                 ; nalezen° dal®° poloëky
         call      EditPLft                 ; n†vrat na konec poloëky

; ------ n†vrat registrñ

EditPEn6:pop       ax
         ret

EditPEnd ENDP

; -----------------------------------------------------------------------------
;        posun na zaá†tek aktivn° poloëky (ES=segment okna)
; -----------------------------------------------------------------------------

EditPBeg PROC      NEAR

; ------ £schova registrñ

         push      ax

; ------ nalezen° zaá†tku ©†dku

EditPBg2:mov       ax,es:[DBFAktP]          ; aktivn° poloëka
         call      EditPLft                 ; posun kurzoru vlevo
         jc        EditPBg6                 ; nen° dal®° pozice
         cmp       ax,es:[DBFAktP]          ; je dal®° poloëka ?
         je        EditPBg2                 ; nalezen° p©ede®lÇ poloëky
         call      EditPRgh                 ; n†vrat na zaá†tek poloëky

; ------ n†vrat registrñ

EditPBg6:pop       ax
         ret

EditPBeg ENDP

; -----------------------------------------------------------------------------
;        posun na dal®° edit. poloëku (ES=segment okna, CY=nen° dal®° poloëka)
; -----------------------------------------------------------------------------

EditPNxt PROC      NEAR

; ------ £schova registrñ

         push      ax

; ------ posun kurzoru na dal®° editovanou poloëku

EditPNx1:mov       ax,es:[DBFAktP]          ; aktivn° poloëka
         call      EditPRgh                 ; posun kurzoru vpravo
         jc        EditPNx8                 ; nen° dal®° pozice
         cmp       ax,es:[DBFAktP]          ; zmànàna aktivn° poloëka ?
         je        EditPNx1                 ; nen° dal®° poloëka - dal®° posun
         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

EditPNx8:pop       ax
         ret

EditPNxt ENDP

; -----------------------------------------------------------------------------
;     posun na p©ede®lou edit. poloëku (ES=segment okna, CY=nen° dal®° poloëka)
; -----------------------------------------------------------------------------

EditPPre PROC      NEAR

; ------ £schova registrñ

         push      ax

; ------ posun kurzoru na p©ede®lou editovanou poloëku

EditPPr1:mov       ax,es:[DBFAktP]          ; aktivn° poloëka
         call      EditPLft                 ; posun kurzoru vlevo
         jc        EditPPr8                 ; nen° dal®° pozice
         cmp       ax,es:[DBFAktP]          ; zmànàna aktivn° poloëka ?
         je        EditPPr1                 ; poloëka nezmànàna - dal®° posun
         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

EditPPr8:pop       ax
         ret

EditPPre ENDP

; -----------------------------------------------------------------------------
;        posun kurzoru o slovo vpravo (ES=segment okna)
; -----------------------------------------------------------------------------

EditPCRg PROC      NEAR

; ------ posun kurzoru o pozici vpravo

EditPCR1:call      EditPRgh                 ; posun kurzoru vpravo
         jc        EditPCR9                 ; nen° dal®° pozice

; ------ test, zda je zaá†tek slova

         call      EditPCT                  ; test, zda je zaá†tek slova
         jc        EditPCR1                 ; nen° zaá†tek slova - dal®° posun
EditPCR9:ret

EditPCRg ENDP

; -----------------------------------------------------------------------------
;        posun kurzoru o slovo vlevo (ES=segment definice okna)
; -----------------------------------------------------------------------------

EditPCLf PROC      NEAR

; ------ posun kurzoru o pozici vlevo

EditPCL1:call      EditPLft                 ; posun kurzoru vlevo
         jc        EditPCL9                 ; nen° dal®° pozice

; ------ test, zda je zaá†tek slova

         call      EditPCT                  ; test, zda je zaá†tek slova
         jc        EditPCL1                 ; nen° zaá†tek slova - dal®° posun
EditPCL9:ret

EditPCLf ENDP

; -----------------------------------------------------------------------------
;        test, zda je zaá†tek slova (CY=nen° zaá†tek slova)
; -----------------------------------------------------------------------------

EditPCT  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx

; ------ definice aktivn° poloëky -> ES:BX, AL, AH

         mov       bx,es:[DBFAktP]          ; BX <- aktivn° poloëka
         shl       bx,1
         shl       bx,1
         shl       bx,1
         add       bx,es:[DBFAdrP]          ; adresa definice poloëky
         mov       ah,es:[bx+DBFParX]       ; AH <- parametry poloëky
         mov       al,es:[DBFKurz]          ; AL <- kurzor

; ------ konec, je-li zaá†tek kterÇkoliv poloëky

         cmp       al,0                     ; je zaá†tek poloëky ?
         je        EditPCT9                 ; je zaá†tek poloëky

; ------ posun kurzoru v áasu

         test      ah,bit6                  ; je áas ?
         jz        EditPCT2                 ; nen° to áas
         shr       al,1
         jmp       short EditPCT9           ; CY=je dal®° posun

; ------ posun kurzoru v datu na dal®° poloëku

EditPCT2:test      ah,bit3                  ; je to datum ?
         jz        EditPCT4                 ; nen° to datum
         cmp       al,4                     ; zaá†tek màs°ce ?
         je        EditPCT9                 ; zaá†tek novÇ poloëky
         cmp       al,6                     ; zaá†tek dne ?
         stc
         jne       EditPCT9                 ; nen° - dal®° posun

; ------ posouv†n° po slovech pouze pro text a á°slo

EditPCT4:test      ah,bit0+bit1+bit2+bit7   ; je text nebo á°slo ?
         jz        EditPCT9                 ; nàco jinÇho - konec OK

; ------ test, zda je zaá†tek desetinnÇ á†sti pro á°slo

         test      ah,bit1+bit2             ; je á°slo ?
         jz        EditPCT6                 ; nen° á°slo
         mov       bx,es:[bx+DBFNamX]       ; adresa popisovaáe poloëky
         sub       al,es:[bx+16]            ; odeáten° dÇlky poloëky
         add       al,es:[bx+17]            ; test, zda je desetinn† á†st
         clc                                ; p©°znak konce posunu
         jz        EditPCT9                 ; je zaá†tek desetinnÇ á†sti

; ------ £schova znaku na pozici kurzoru -> AH

EditPCT6:call      EdiBGetC                 ; znak na pozici kurzoru
         mov       ah,al                    ; £schova aktu†ln°ho znaku

; ------ posun o pozici vlevo (nen° je®tà zaá†tek poloëky)

         call      EditPLft                 ; posun kurzoru vlevo

; ------ £schova p©edch†zej°c°ho znaku

         call      EdiBGetC                 ; znak na pozici kurzoru

; ------ n†vrat kurzoru

         call      EditPRgh                 ; n†vrat kurzoru

; ------ test, zda je zaá†tek slova (pokud ne, je dal®° posun)

         call      far ptr TestWrd          ; je to zaá†tek slova ?

; ------ n†vrat registrñ

EditPCT9:pop       bx
         pop       ax
         ret

EditPCT  ENDP

; -----------------------------------------------------------------------------
;       posun kurzoru v poloëce vpravo (ES=segment okna, CY=nen° dal®° pozice)
; -----------------------------------------------------------------------------

EditPRgh PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      dx
         push      di

; ------ adresa popisovaáe aktivn° poloëky -> DI

         mov       di,es:[DBFAktP]          ; á°slo aktivn° poloëky
         shl       di,1
         shl       di,1
         shl       di,1                     ; offset v tabulce popisovaáñ
         add       di,es:[DBFAdrP]          ; adresa popisovaáe

; ------ zvò®en° offsetu v poloëce, je-li datum -> AL

         mov       al,es:[DBFKurz]          ; kurzor
         mov       ah,0
         test      byte ptr es:[di+DBFParX],bit3 ; je to datum ?
         jz        EditPRg2                 ; nen° datum
         mov       bh,0
         mov       bl,ds:[FormDat]          ; form†t data (0=MDR, 1=DMR, 2=RMD)
         shl       bx,1
         shl       bx,1
         shl       bx,1

         push      bx
         add       bx,ax                    ; pozice kurzoru v poloëce
         mov       al,cs:[bx+EditPPT1]      ; n†sleduj°c° offset kurzoru
         pop       bx
         add       bx,ax                    ; aktu†ln° pozice kurzoru
         mov       dl,cs:[bx+EditPPT3]      ; pozice na displeji

         cmp       al,6
         je        EditPRg0                 ; zaá†tek dne - konec editace
         cmp       al,4
         je        EditPRg0
         cmp       al,0
         jne       EditPRg1
EditPRg0:call      EditNmEn                 ; ukonáen° editace á°selnÇ poloëky
EditPRg1:jmp       short EditPR44

; ------ zvò®en° offsetu v poloëce, je-li á°slo

EditPRg2:test      byte ptr es:[di+DBFParX],bit1+bit2 ; je á°slo ?
         jz        EditPRg3                 ; nen° á°slo
         inc       ax                       ; zvò®en° offsetu kurzoru
         mov       bx,es:[di+DBFNamX]       ; adresa definice poloëky
         cmp       byte ptr es:[bx+17],0    ; jsou desetiny ?
         je        EditPRg5                 ; nejsou desetiny
         mov       dl,es:[bx+16]            ; dÇlka poloëky
         sub       dl,es:[bx+17]            ; zbytek na celÇ á°slo
         dec       dx                       ; bez oddàlovac° teáky
         cmp       al,dl                    ; je pozice teáky ?
         jne       EditPRg5                 ; nen° pozice teáky
         call      EditNmEn                 ; ukonáen° editace á°selnÇ poloëky
         inc       ax                       ; p©eskoáen° teáky
         jmp       short EditPRg5

; ------ zvò®en° offsetu, je-li pole MEMO

EditPRg3:test      byte ptr es:[di+DBFParX],bit5 ; je pole MEMO ?
         jz        EditPRg4

         mov       al,10                    ; pozice za polem MEMO
         jmp       short EditPRg5

; ------ zvò®en° offsetu v textovÇ poloëce, áasu a logickÇ poloëce

EditPRg4:inc       ax
         test      byte ptr es:[di+DBFParX],bit6 ; je to áasovÇ pole ?
         jz        EditPRg5                 ; nen° to áas
         mov       dl,al                    ; DL <- offset kurzoru
         cmp       al,2                     ; minuta nebo sekunda ?
         jb        EditPR42                 ; hodina
         inc       dx                       ; p©eskoáen° oddàlovaáe
EditPR42:cmp       al,4                     ; sekunda ?
         jb        EditPR43                 ; nen°
         inc       dx                       ; p©eskoáen° oddàlovaáe
EditPR43:test      al,bit0                  ; je zaá†tek dal®° podpoloëky ?
         jnz       EditPR44                 ; nen°
         call      EditNmEn                 ; ukonáen° editace á°selnÇ poloëky

; ------ test, zda je jië konec poloëky (DL=relativn° pozice na displeji)

EditPR44:cmp       dl,es:[di+DBFSirX]       ; p©ekroáen konec zobrazen° ?
         jae       EditPR52                 ; p©ekroáen konec

EditPRg5:cmp       al,es:[di+DBFDelX]       ; p©ekroáen konec poloëky ?
         jb        EditPRg7                 ; nen° je®tà konec poloëky
EditPR52:call      EditNmEn                 ; ukonáen° editace á°selnÇ poloëky

; ------ dal®° popisovaá poloëek

         mov       dx,es:[DBFAktP]          ; aktivn° poloëka
         inc       dx                       ; zvò®en° á°sla poloëky
         cmp       dx,es:[DBFNumP]          ; je to platn† poloëka ?
         cmc
         jc        EditPRg9                 ; nen° dal®° platn† poloëka
         add       di,DBFX                  ; adresa dal®°ho popisovaáe
         mov       es:[DBFAktP],dx          ; nov† aktivn° poloëka

; ------ stanoven° novÇ pozice kurzoru

         xor       ax,ax                    ; kurzor na poá†tek poloëky
         mov       es:[DBFOffT],ax          ; offset poá†tku poloëky
         test      byte ptr es:[di+DBFParX],bit3 ; je to datum ?
         jz        EditPRg7                 ; nen° to datum
         cmp       byte ptr ds:[FormDat],1  ; je form†t data DMR ?
         ja        EditPRg7                 ; form†t data je RMD
         mov       al,4
         jb        EditPRg7                 ; form†t data je MDR
         mov       al,6                     ; jinak form†t data DMR

; ------ uloëen° novÇ pozice kurzoru

EditPRg7:mov       es:[DBFKurz],ax          ; nov† pozice kurzoru

; ------ korekce poá†tku textovÇ poloëky

         test      byte ptr es:[di+DBFParX],bit0+bit1+bit2+bit7 ; text/á°slo ?
         jz        EditPRg8                 ; nen° to text/á°slo
         sub       ax,es:[DBFOffT]          ; offset kurzoru od poá†tku
         jbe       EditPRg8                 ; OK
         sub       ax,es:[di+DBFSirX]       ; p©ekroáena ®°©ka pole ?
         jb        EditPRg8                 ; nep©ekroáena ®°©ka pole
         inc       ax                       ; p©eteáen° p©es konec
         add       es:[DBFOffT],ax          ; korekce poá†tku poloëky
EditPRg8:clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

EditPRg9:pop       di
         pop       dx
         pop       bx
         pop       ax
         ret

EditPRgh ENDP

; ------ tabulka maxim†ln°ch offsetñ v datu (podle ®°©ky pole)

EditPPT0 db        4,4,5,5,6,7,7,0,1,2,3    ; USA:      MM.DD.RRRR
         db        6,6,7,7,4,5,5,0,1,2,3    ; EVROPA:   DD.MM.RRRR
         db        0,0,1,2,3,3,4,5,5,6,7    ; JAPONSKO: RRRR.MM.DD

; ------ tabulka dal®°ch offsetñ v datu
;                  0 1 2 3 4 5 6 7 8
;                  R R R R M M D D

EditPPT1 db        1,2,3,8,5,6,7,0          ; USA:      MM.DD.RRRR
         db        1,2,3,8,5,0,7,4          ; EVROPA:   DD.MM.RRRR
         db        1,2,3,4,5,6,7,8          ; JAPONSKO: RRRR.MM.DD

; ------ tabulka p©ede®lòch offsetñ v datu

EditPPT2 db       7,0,1,2,-1,4,5,6          ; USA:      MM.DD.RRRR
         db       5,0,1,2,7,4,-1,6          ; EVROPA:   DD.MM.RRRR
         db       -1,0,1,2,3,4,5,6          ; JAPONSKO: RRRR.MM.DD

; ------ tabulka pozic na displeji
;                                                       0123456789
EditPPT3 db        6,7,8,9,0,1,2,3          ; USA:      MM.DD.RRRR
         db        6,7,8,9,3,4,0,1          ; EVROPA:   DD.MM.RRRR
         db        0,1,2,3,5,6,8,9          ; JAPONSKO: RRRR.MM.DD

; -----------------------------------------------------------------------------
;       posun kurzoru v poloëce vlevo (ES=segment okna, CY=nen° dal®° pozice)
; -----------------------------------------------------------------------------
;˛
EditPLft PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      dx
         push      di

; ------ adresa popisovaáe aktivn° poloëky -> DI

         mov       di,es:[DBFAktP]          ; á°slo aktivn° poloëky
         shl       di,1
         shl       di,1
         shl       di,1                     ; offset v tabulce popisovaáñ
         add       di,es:[DBFAdrP]          ; adresa popisovaáe

; ------ sn°ëen° offsetu v poloëce, je-li datum -> AL

         mov       al,es:[DBFKurz]          ; kurzor
         mov       ah,0
         test      byte ptr es:[di+DBFParX],bit3 ; je to datum ?
         jz        EditPLf2                 ; nen° datum
         mov       bh,0
         mov       bl,ds:[FormDat]          ; form†t data (0=MDR, 1=DMR, 2=RMD)
         shl       bx,1
         shl       bx,1
         shl       bx,1

         add       bx,ax                    ; pozice kurzoru v poloëce
         mov       al,cs:[bx+EditPPT2]      ; p©ede®lò offset kurzoru

         cmp       al,7
         je        EditPLf0
         cmp       al,5
         je        EditPLf0
         cmp       al,3
         jne       EditPLf1
EditPLf0:call      EditNmEn                 ; ukonáen° editace á°selnÇ poloëky
EditPLf1:cbw                                ; konverze na slovo
         jmp       short EditPLf5

; ------ sn°ëen° offsetu v poloëce, je-li á°slo

EditPLf2:test      byte ptr es:[di+DBFParX],bit1+bit2 ; je á°slo ?
         jz        EditPLf3                 ; nen° á°slo
         dec       ax                       ; sn°ëen° offsetu kurzoru
         js        EditPLf5                 ; p©ekroáen zaá†tek poloëky
         mov       bx,es:[di+DBFNamX]       ; adresa definice poloëky
         cmp       byte ptr es:[bx+17],0    ; jsou desetiny ?
         je        EditPLf5                 ; nejsou desetiny
         mov       dl,es:[bx+16]            ; dÇlka poloëky
         sub       dl,es:[bx+17]            ; zbytek na celÇ á°slo
         dec       dx                       ; bez oddàlovac° teáky
         cmp       al,dl                    ; je pozice teáky ?
         jne       EditPLf5                 ; nen° pozice teáky
         call      EditNmEn                 ; ukonáen° editace á°selnÇ poloëky
         dec       ax                       ; p©eskoáen° teáky
         jmp       short EditPLf5

; ------ sn°ëen° offsetu, je-li pole MEMO

EditPLf3:test      byte ptr es:[di+DBFParX],bit5 ; je pole MEMO ?
         jz        EditPLf4

         mov       ax,-1                    ; pozice p©ed polem MEMO
         jmp       short EditPLf5

; ------ sn°ëen° offsetu v textovÇ poloëce

EditPLf4:dec       ax
         js        EditPLf5                 ; je podteáen°

; ------ ukonáen° editace v poloëce áasu

         test      byte ptr es:[di+DBFParX],bit6 ; je áas ?
         jz        EditPLf5                 ; nen° áas
         test      al,bit0                  ; je druhò znak ?
         jnz       EditPLf0                 ; je nov† podpoloëka

; ------ test, zda je jië zaá†tek poloëky

EditPLf5:or        ax,ax                    ; p©ekroáen zaá†tek poloëky ?
         jns       EditPLf7                 ; nebyl je®tà zaá†tek poloëky
         call      EditNmEn                 ; ukonáen° editace á°selnÇ poloëky

; ------ dal®° popisovaá poloëek

         mov       dx,es:[DBFAktP]          ; aktivn° poloëka
         or        dx,dx                    ; je jië prvn° popisovaá ?
         jnz       EditPL50
         stc
         jmp       EditPLf9                 ; nen° dal®° platn† poloëka

EditPL50:sub       di,DBFX                  ; adresa dal®°ho popisovaáe
         dec       dx
         mov       es:[DBFAktP],dx          ; nov† aktivn° poloëka

; ------ stanoven° novÇ pozice kurzoru

         xor       ax,ax                    ; AX <- 0
         mov       es:[DBFOffT],ax          ; offset poloëky <- 0
         test      byte ptr es:[di+DBFParX],bit5 ; je MEMO ?
         jnz       EditPLf7                 ; je MEMO pole
         mov       al,es:[di+DBFDelX]       ; dÇlka poloëky
         dec       ax                       ; posledn° pozice v poloëce

         test      byte ptr es:[di+DBFParX],bit6 ; je to áas ?
         jz        EditPL56                 ; nen° to áas

         mov       ax,es:[di+DBFSirX]       ; ®°©ka pole
         dec       ax                       ; posledn° znak
         jns       EditPL51
         xor       ax,ax                    ; omezen° p©i podteáen°
EditPL51:cmp       al,7                     ; je dostateán† ®°©ka ?
         jbe       EditPL52                 ; mal† ®°©ka
         mov       al,7                     ; omezen°
EditPL52:cmp       al,5                     ; zak†zanò znak ?
         jb        EditPL53                 ; OK
         dec       ax
EditPL53:cmp       al,2                     ; zak†zanò znak
         jb        EditPL56
         dec       ax

EditPL56:test      byte ptr es:[di+DBFParX],bit3 ; je to datum ?
         jz        EditPLf7                 ; nen° to datum

         mov       ah,11
         mov       al,ds:[FormDat]          ; form†t data (0=MDR, 1=DMR, 2=RMD)
         mul       ah                       ; adresa seznamu offsetñ
         mov       bx,es:[di+DBFSirX]       ; ®°©ka pole
         cmp       bl,10
         jbe       EditPLf6
         mov       bl,10
EditPLf6:add       bx,ax
         mov       al,cs:[EditPPT0+bx]

; ------ uloëen° novÇ pozice kurzoru

EditPLf7:mov       es:[DBFKurz],ax          ; nov† pozice kurzoru

; ------ korekce poá†tku textovÇ a á°selnÇ poloëky

         test      byte ptr es:[di+DBFParX],bit0+bit1+bit2+bit7 ; je to text/á°slo ?
         jz        EditPLf8                 ; nen° to text/á°slo
         cmp       ax,es:[DBFOffT]          ; je kurzor za poá†tkem ?
         jae       EditPL72                 ; poá†tek je OK
         mov       word ptr es:[DBFOffT],ax ; korekce poá†tku poloëky
EditPL72:inc       ax
         sub       ax,es:[di+DBFSirX]       ; minim†ln° poá†tek
         jbe       EditPLf8                 ; kurzor je OK
         cmp       ax,es:[DBFOffT]          ; p©eteáen° konce ?
         jbe       EditPLf8                 ; nen° p©eteáen° konce
         mov       es:[DBFOffT],ax          ; omezen° poá†tku

EditPLf8:clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

EditPLf9:pop       di
         pop       dx
         pop       bx
         pop       ax
         ret

EditPLft ENDP

; -----------------------------------------------------------------------------
;        Insert - oznaáen° poloëky/p©°znak vkl†d†n°
; -----------------------------------------------------------------------------

; ------ p©i editaci zmàna p©°znaku INSERT

EditBIns:cmp       word ptr es:[DBFNumP],0  ; jsou nàjakÇ poloëky ?
         je        EditBI02                 ; nejsou ë†dnÇ poloëky
         test      byte ptr ds:[DBFEParm],bit0 ; prob°h† editace ?
         jz        EditBIn1                 ; nen° editace
         xor       byte ptr ds:[DBFEParm],bit2 ; zmàna p©°znaku editace
EditBI02:ret

; ------ test, zda bude oznaáen° z†znamu

EditBIn1:test      byte ptr es:[DBFParm],bit0 ; je str†nkovò reëim ?
         jnz       EditBI02                 ; je str†nkovò reëim - nic
         test      byte ptr es:[DBFParm],bit1 ; je z†kaz z†pisu ?
         jnz       EditBIn9                 ; z†kaz z†pisu - posun kurzoru dolñ

; ------ £schova data a áasu souboru

         call      DBFGetDT                 ; £schova data a áasu souboru
         jc        EditBIn9                 ; chyba

; ------ naáten° aktu†ln°ho z†znamu

         call      far ptr GetADBF          ; poskytnut° aktivn° poloëky DBF
         jc        EditBIn9                 ; chyba

; ------ zmàna p©°znaku oznaáen° z†znamu

         cmp       byte ptr es:[di]," "     ; je mezera ?
         je        EditBIn2                 ; je mezera OK
         mov       byte ptr es:[di],"*"     ; p©°znak oznaáen° poloëky
EditBIn2:xor       byte ptr es:[di],"*" XOR " " ; zmàna p©°znaku oznaáen°

; ------ uloëen° zmànànÇho z†znamu

         call      far ptr SetADBF          ; uloëen° aktivn° poloëky

; ------ vypr†zdnàn° z†pisovÇho bufferu a n†vrat data a áasu

         call      DBFSetDT                 ; nastaven° data a áasu

; ------ posun kurzoru dolñ

EditBIn9:jmp       EditBDwn                 ; posun kurzoru dolñ

; -----------------------------------------------------------------------------
;        nulov†n° oznaáen° v®ech z†znamñ
; -----------------------------------------------------------------------------

; ------ test, zda je funkce povolena

EditBNul:cmp       word ptr es:[DBFNumP],0  ; jsou nàjakÇ poloëky ?
         je        EditBNl0                 ; nejsou ë†dnÇ poloëky
         test      byte ptr ds:[DBFEParm],bit0 ; je editace ?
         jnz       EditBNl0                 ; je editace
         test      byte ptr es:[DBFParm],bit1 ; je z†kaz z†pisu ?
         jnz       EditBNl0                 ; je z†kaz z†pisu

; ------ potvrzen° operace

         mov       di,offset DBNMLin
         call      EditBLM                  ; obsluha ©†dkovÇho menu
         jnc       EditBNl1                 ; nen° p©eru®en° operace
EditBNl0:ret

; ------ zobrazen° hl†®en° o nulov†n°

EditBNl1:push      si
         mov       si,offset DBNMLHls       ; hl†®en°
         call      far ptr InfDisp0         ; zobrazen° hl†®en°
         pop       si

; ------ £schova registrñ

         push      ax
         push      dx

; ------ £schova data a áasu

         call      DBFGetDT                 ; £schova data a áasu
         jc        EditBNl8                 ; chyba

; ------ poskytnut° dal®°ho z†znamu

         xor       ax,ax                    ; ukazatel z†znamu LOW
         xor       dx,dx                    ; ukazatel z†znamu HIGH
EditBNl2:call      far ptr GetDBF           ; poskytnut° z†znamu DX:AX
         jc        EditBNl6                 ; konec - nen° dal®° z†znam

; ------ nulov†n° p©°znaku oznaáen°

         cmp       byte ptr es:[di]," "     ; je poloëka oznaáena ?
         je        EditBNl4                 ; poloëka nen° oznaáena - dal®°
         mov       byte ptr es:[di]," "     ; zru®en° oznaáen° poloëky
         call      far ptr SetDBF           ; uloëen° poloëky na disk

; ------ dal®° z†znam

EditBNl4:add       ax,1                     ; zvò®en° á°sla z†znamu
         adc       dx,0

; ------ test, zda je p©eru®en° operace

         call      far ptr TestBEsc         ; test p©eru®en° operace
         jnc       EditBNl2
         call      far ptr FlushChr         ; vypr†zdnàn° bufferu kl†vesnice

; ------ n†vrat data a áasu, pokud byla alespo§ 1 modifikace souboru

EditBNl6:call      DBFSetDT                 ; n†vrat data a áasu

; ------ n†vrat registrñ

EditBNl8:pop       dx
         pop       ax
         call      far ptr InfoClos         ; uzav©en° informaán°ho ©†dku

EditBNl9:ret

; -----------------------------------------------------------------------------
;        export dat (SI=podmenu)
; -----------------------------------------------------------------------------
;˛
EditBExp PROC      FAR

         cmp       word ptr es:[DBFNumP],0  ; jsou nàjakÇ poloëky ?
         je        EditBEx0                 ; nejsou ë†dnÇ poloëky
         test      byte ptr ds:[DBFEParm],bit0 ; je editace ?
         jnz       EditBEx0                 ; je editace

         and       byte ptr ds:[DBFEParm],not bit5 ; v®echny z†znamy
         mov       cx,word ptr ds:[DBMnVert+MnuPoz]
         add       cx,7+7*HI
         mov       word ptr ds:[si+MnuPoz],cx

         mov       dl,ds:[DBExpPar]         ; parametry
         call      far ptr SetSwch          ; nastaven° p©ep°naáñ
         jmp       far ptr VertMenu         ; volba operace

EditBEx0:ret

EditBExp ENDP

; ------ zmàna p©ep°naáñ

EditBEx1 PROC      FAR

         mov       cl,byte ptr ds:[si+MnuAkt]        ; aktivn° zvolen† poloëka
         dec       cx
         mov       dl,bit0
         shl       dl,cl                    ; novò p©ep°naá
         mov       ds:[DBExpPar],dl         ; novò p©ep°naá
         call      far ptr SetSwch          ; nastaven° p©ep°naáe
         call      far ptr DispMnu          ; novÇ zobrazen° okna menu
         ret

EditBEx1 ENDP

; ------ start volby

EditBEx2:or        byte ptr ds:[DBFEParm],bit5 ; pouze oznaáenÇ z†znamy
EditBEx3:add       sp,4                     ; zru®en° n†vratovÇ adresy
         call      far ptr ClosMnu          ; uzav©en° okna podmenu
         call      far ptr ClosMnu          ; uzav©en° okna menu
         pop       dx
         pop       si

; ------ zad†n° jmÇna souboru

         push      ax

         mov       di,offset DBXMSLin
         call      EditBLM                  ; obsluha ©†dkovÇho menu
         jc        EditBEx9

; ------ normalizace jmÇna souboru

         push      si
         push      es
         call      far ptr NormFilL         ; normalizace jmÇna souboru
         pop       es
         pop       si
         jz        EditBEx9                 ; nen° nic zad†no

; ------ otev©en°/vytvo©en° souboru

         push      si
         push      es

         push      ds
         pop       es
         mov       si,offset LinBuff        ; buffer jmÇna souboru
         call      far ptr OpenRW           ; otev©en° souboru
         jnc       EditBEx4                 ; soubor otev©en OK
         call      far ptr CreatFil         ; vytvo©en° souboru

EditBEx4:pop       es
         pop       si
         jc        EditBEx9                 ; chyba
         call      far ptr SizeFile         ; ukazatel na konec souboru

; ------ export dat do souboru AX

         call      EDBExp                   ; export dat do souboru AX

         call      far ptr ClosFile         ; uzav©en° souboru AX

EditBEx9:pop       ax
         ret

; -----------------------------------------------------------------------------
;        export dat do souboru AX (SI=definice okna, ES=segment okna)
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) adresa definice okna
;                   SS:[BP-4] (2) identifik†tor vòstupn°ho souboru
;                   SS:[BP-8] (4) ukazatel á°sla z†znamu
;                   SS:[BP-10] (2) adresa konce bufferu
;                   SS:[BP-11] (1) znak oddàlovaáe (0=nen°)
; -----------------------------------------------------------------------------

EDBExp   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         mov       bp,sp
         sub       sp,12

; ------ p©°prava lok†ln°ch promànnòch

         mov       ss:[bp-2],si             ; adresa definice okna
         mov       ss:[bp-4],ax             ; identifik†tor vòstup. souboru
         xor       ax,ax
         mov       ss:[bp-8+2],ax           ; ukazatel á°sla z†znamu
         mov       ss:[bp-8],ax
         mov       ax,es:[DBFAdrE]          ; adresa editaán°ho bufferu
         mov       di,ax                    ; adresa editaán°ho bufferu
         add       ax,es:[DBFBytZ]          ; adresa konce bufferu
         mov       ss:[bp-10],ax            ; adresa konce bufferu

; ------ p©°prava znaku oddàlovaáe dat

         mov       al,ds:[DBExpPar]         ; parametry pro export
         mov       ah,","
         shr       al,1
         jc        EDBExp1                  ; oddàlovac° á†rka
         mov       ah,";"
         shr       al,1
         jc        EDBExp1                  ; oddàlovac° st©edn°k
         mov       ah,TAB
         shr       al,1
         jc        EDBExp1                  ; oddàlovac° tabul†tor
         mov       ah,"≥"
         shr       al,1
         jc        EDBExp1                  ; oddàlovac° r†m
         mov       ah,0                     ; nen° oddàlovaá
EDBExp1: mov       ss:[bp-11],ah            ; znak oddàlovaáe poloëek

; ------ poskytnut° dal®°ho z†znamu

EDBExp2: push      di                       ; ukl†dac° adresa do bufferu
         mov       si,ss:[bp-2]             ; adresa definice okna
         mov       ax,ss:[bp-8]             ; á°slo z†znamu LOW
         mov       dx,ss:[bp-8+2]           ; á°slo z†znamu HIGH
         call      far ptr GetDBF           ; poskytnut° dal®°ho z†znamu
         mov       si,di                    ; SI <- zaá†tek z†znamu
         pop       di
         jnc       EDBExp24                 ; je dal®° z†znam OK
         jmp       EDBExp8                  ; nen° dal®° z†znam

; ------ test, zda je z†znam platnò

EDBExp24:test      byte ptr ds:[DBFEParm],bit5 ; pouze oznaáenÇ z†znamy ?
         jz        EDBExp3                  ; jsou v®echny z†znamy
         cmp       byte ptr es:[si],"*"     ; je to oznaáenò z†znam ?
         je        EDBExp3                  ; je to oznaáenò z†znam
         jmp       EDBExp7                  ; nen° to oznaáenò z†znam

; ------ nalezen° dÇlky dat v z†znamu -> CX

EDBExp3: mov       cx,es:[DBFBytZ]          ; poáet bajtñ na z†znam
         dec       cx                       ; bez £vodn°ho bajtu
         inc       si                       ; poá†tek z†znamu
         push      si
         test      byte ptr ds:[DBExpPar],bit3 ; je r†m ?
         jnz       EDBExp34                 ; je r†m
         add       si,cx                    ; adresa konec dat v z†znamu
EDBExp32:dec       si                       ; posledn° bajt
         cmp       byte ptr es:[si]," "     ; jsou data ?
         jne       EDBExp34                 ; jsou data
         loop      EDBExp32                 ; dal®° data
EDBExp34:pop       si

; ------ p©°prava k dek¢dov†n° z†znamu

         mov       bx,es:[DBFAdrP]          ; tabulka popisovaáñ
         jcxz      EDBExp43                 ; je konec dat

; ------ p©°prava k dek¢dov†n° jednÇ poloëky

EDBExp4: mov       ah,es:[bx+DBFDelX]       ; dÇlka poloëky (bajtñ)

; ------ MEMO pole se neexportuje

         test      byte ptr es:[bx+DBFParX],bit5 ; je MEMO pole ?
         jz        EDBExp41                 ; nen° MEMO pole
         mov       al,ah                    ; dÇlka poloëky
         mov       ah,0
         add       si,ax                    ; adresa dal®° poloëky
         sub       cx,ax                    ; zbylÇ znaky
         jnc       EDBExp40
         xor       cx,cx
EDBExp40:jcxz      EDBExp43                 ; konec ©†dku
         jmp       EDBExp5A                 ; MEMO pole se neukl†d†

; ------ nalezen° zaá†tku textu v poloëce

EDBExp41:test      byte ptr es:[bx+DBFParX],bit0+bit7 ; je textov† poloëka ?
         jnz       EDBExp5                  ; je textov† poloëka
         test      byte ptr ds:[DBExpPar],bit3+bit4 ; je r†m nebo pozice ?
         jnz       EDBExp5                  ; je r†m nebo pozice
EDBExp42:cmp       byte ptr es:[si]," "     ; je platnò znak ?
         jne       EDBExp5                  ; je zaá†tek textu poloëky
         inc       si                       ; dal®° znak
         dec       cx                       ; á°taá zbytku textu
EDBExp43:jcxz      EDBExp6                  ; konec ©†dku
         dec       ah                       ; á°taá dÇlky poloëky
         jnz       EDBExp42                 ; nen° konec poloëky
         jmp       short EDBExp59           ; je konec poloëky

; ------ nalezen° konce textu poloëky

EDBExp5: push      si
         push      ax

         mov       al,ah                    ; dÇlka zbytku poloëky
         mov       ah,0
         add       si,ax                    ; konec poloëky
         mov       dx,si                    ; DX <- adresa konce poloëky

         test      byte ptr ds:[DBExpPar],bit3+bit4 ; je r†m nebo pozice ?
         jz        EDBExp51                 ; nen° r†m ani pozice
         cmp       cx,ax                    ; bude je®tà dal®° poloëka ?
         ja        EDBExp52                 ; bude dal®° poloëka - konec plat°

EDBExp51:dec       si
         cmp       byte ptr es:[si]," "     ; nalezen konec poloëky ?
         jne       EDBExp52                 ; nalezen konec poloëky
         dec       dx                       ; sn°ëen° ukazatele konce poloëky
         jmp       short EDBExp51

EDBExp52:pop       ax
         pop       si

; ------ dek¢dov†n° poloëky

         cmp       si,dx                    ; je nàjakò text ?
         jae       EDBExp57                 ; nen° ë†dnò text
         call      EDBExpV                  ; uloëen° znaku uvozovek
EDBExp54:cmp       si,dx                    ; je konec textu poloëky ?
         jae       EDBExp56                 ; konec textu poloëky

         mov       al,es:[si]               ; naáten° znaku poloëky
         inc       si
         cmp       al,'"'
         jne       EDBExp55
         call      EDBExpV                  ; uloëen° znaku uvozovek
EDBExp55:call      EDBExpU0                 ; uloëen° znaku (ne TAB)

         dec       ah                       ; á°taá zbytku poloëky
         loop      EDBExp54                 ; dal®° znak

EDBExp56:call      EDBExpV                  ; uloëen° znaku uvozovek
EDBExp57:mov       al,ah                    ; zbytek poloëky
         mov       ah,0
         add       si,ax                    ; adresa dal®° poloëky
         sub       cx,ax                    ; zbylÇ znaky
         jnc       EDBExp59
         xor       cx,cx

; ------ p©°prava pro dal®° poloëku v z†znamu

EDBExp59:jcxz      EDBExp6                  ; je konec dat

; ------ uloëen° znaku oddàlovaáe dat

         mov       al,ss:[bp-11]            ; znak oddàlovaáe dat
         or        al,al                    ; je oddàlovaá dat ?
         jz        EDBExp5A                 ; nen° oddàlovaá dat
         call      EDBExpU                  ; uloëen° oddàlovaáe dat

EDBExp5A:add       bx,DBFX                  ; adresa dal®°ho popisovaáe
         cmp       bx,es:[DBFAdrE]          ; konec popisovaáñ ?
         jae       EDBExp6                  ; jsou jië v®echny poloëky
         jmp       EDBExp4                  ; dal®° poloëka

; ------ uloëen° konce ©†dku

EDBExp6: mov       al,CR
         call      EDBExpU
         mov       al,LF
         call      EDBExpU

; ------ p©°prava pro dal®° z†znam

EDBExp7: add       word ptr ss:[bp-8],1     ; zvò®en° á°sla z†znamu
         adc       word ptr ss:[bp-8+2],0
         call      far ptr TestBEsc         ; je p©eru®en° ?
         jc        EDBExp8                  ; p©eru®en° operace
         jmp       EDBExp2                  ; dal®° z†znam

; ------ uloëen° zbytku dat do souboru

EDBExp8: call      EDBExpW                  ; uloëen° zbytku dat z bufferu
         clc

; ------ n†vrat registrñ

EDBExp9: mov       sp,bp
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

EDBExp   ENDP


; ------ uloëen° znaku uvozovek

EDBExpV: test      byte ptr es:[bx+DBFParX],bit0+bit7 ; je to textov† poloëka ?
         jz        EDBExpU2                 ; nen° to textov† poloëka
         test      byte ptr ds:[DBExpPar],bit2+bit3+bit4 ; TAB, r†m, pozice ?
         jnz       EDBExpU2                 ; je TAB, r†m, pozice - nejsou uvoz.
         mov       al,'"'

EDBExpU0:cmp       al,TAB                   ; je tabul†tor ?
         jne       EDBExpU                  ; nen° tabul†tor
         mov       al," "                   ; n†hrada tabul†toru mezerou

; ------ uloëen° znaku AL do bufferu (ukl†dac° adresa DI)

EDBExpU: cld
         stosb                              ; uloëen° znaku AL do bufferu
         cmp       di,ss:[bp-10]            ; je buffer plnò ?
         jae       EDBExpW                  ; buffer je jië plnò
EDBExpU2:ret

; ------ vypr†zdnàn° bufferu (ukl†dac° adresa DI, smàr CLD)

EDBExpW: push      cx
         push      si
         push      ax

         mov       si,es:[DBFAdrE]          ; adresa editaán°ho bufferu
         sub       di,si                    ; poáet bajtñ v bufferu
         mov       cx,di                    ; CX <- poáet bajtñ v bufferu
         mov       ax,ss:[bp-4]             ; identifik†tor souboru
         call      far ptr WritFile         ; z†pis dat do souboru
         mov       di,si                    ; adresa bufferu

         pop       ax
         pop       si
         pop       cx
         cld
         jnc       EDBExpU2                 ; operace OK

         add       sp,2                     ; zru®en° n†vratovÇ adresy
         stc                                ; p©°znak chyby
         jmp       EDBExp9                  ; n†vrat p©i chybà

; -----------------------------------------------------------------------------
;        import dat (SI=podmenu)
; -----------------------------------------------------------------------------
;˛
EditBImp PROC      FAR

         cmp       word ptr es:[DBFNumP],0  ; jsou nàjakÇ poloëky ?
         je        EditBIm0                 ; nejsou ë†dnÇ poloëky
         test      byte ptr ds:[DBFEParm],bit0 ; je editace ?
         jnz       EditBIm0                 ; je editace

         and       byte ptr ds:[DBFEParm],not bit5 ; z†znamy na konec souboru
         mov       cx,word ptr ds:[DBMnVert+MnuPoz]
         add       cx,7+1*HI
         mov       word ptr ds:[si+MnuPoz],cx

         mov       dl,ds:[DBImpPar]         ; parametry
         call      far ptr SetSwch          ; nastaven° p©ep°naáñ
         jmp       far ptr VertMenu         ; volba operace

EditBIm0:ret

EditBImp ENDP

; ------ zmàna p©ep°naáñ

EditBIm1 PROC      FAR

         mov       cl,byte ptr ds:[si+MnuAkt]        ; aktivn° zvolen† poloëka
         dec       cx
         mov       dl,bit0
         shl       dl,cl                    ; novò p©ep°naá
         mov       ds:[DBImpPar],dl         ; novò p©ep°naá
         call      far ptr SetSwch          ; nastaven° p©ep°naáe
         call      far ptr DispMnu          ; novÇ zobrazen° okna menu
         ret

EditBIm1 ENDP

; ------ start volby

EditBIm2:or        byte ptr ds:[DBFEParm],bit5 ; vloëit z†znamy
EditBIm3:add       sp,4                     ; zru®en° n†vratovÇ adresy
         call      far ptr ClosMnu          ; uzav©en° okna podmenu
         call      far ptr ClosMnu          ; uzav©en° okna menu
         pop       dx
         pop       si

; ------ zad†n° jmÇna souboru

         push      ax

         mov       di,offset DBIMSLin
         call      EditBLM                  ; obsluha ©†dkovÇho menu
         jc        EdiBIm34

; ------ normalizace jmÇna souboru

         push      si
         push      es
         call      far ptr NormFilL         ; normalizace jmÇna souboru
         pop       es
         pop       si
         jz        EdiBIm34                 ; nen° nic zad†no

; ------ otev©en° souboru

         push      si
         push      es

         push      ds
         pop       es
         mov       si,offset LinBuff        ; buffer jmÇna souboru
         call      far ptr OpenR            ; otev©en° souboru pro áten°

         pop       es
         pop       si
         jnc       EdiBIm36
EdiBIm34:jmp       EditBIm9                 ; chyba

; ------ poloëky se vkl†daj° na konec souboru

EdiBIm36:mov       bx,es:[DBFMaxZ+2]        ; posledn° z†znam v souboru
         mov       cx,es:[DBFMaxZ]
         test      byte ptr ds:[DBFEParm],bit5 ; je vkl†d†n° od kurzoru ?
         jz        EditBIm7                 ; je ukl†d†n° na konec souboru

; ------ spoáten° poátu ©†dkñ v souboru

         push      dx

         push      ax
         mov       ax,es:[DBFBytZ]          ; poáet bajtñ na z†znam
         mul       word ptr es:[DBFMaxD]    ; velikost bufferu (bajtñ)
         xchg      ax,cx                    ; CX <- velikost bufferu (bajtñ)
         pop       ax

         xor       bx,bx                    ; á°taá ©†dkñ LOW
         xor       dx,dx                    ; á°taá ©†dkñ HIGH
         mov       es:[DBFNumD],bx          ; poáet z†znamñ v bufferu = 0

EditBIm4:mov       di,es:[DBFAdrD]          ; adresa datovÇho bufferu
         call      far ptr ReadFile         ; naáten° dat ze souboru
         jcxz      EditBIm6                 ; konec souboru
         push      ax
         push      cx

         cld
         mov       al,LF                    ; hledanò znak LF
EdiBIm42:repne     scasb                    ; nalezen° znaku LF
         jne       EditBIm5                 ; dal®° znak nenalezen
         add       bx,1                     ; á°taá ©†dkñ LOW
         adc       dx,0                     ; á°taá ©†dkñ HIGH
         or        cx,cx                    ; jsou dal®° data ?
         jnz       EdiBIm42                 ; jsou dal®° data
EditBIm5:pop       cx
         pop       ax
         jmp       short EditBIm4           ; dal®° data

EditBIm6:mov       di,dx                    ; DI <- poáet ©†dkñ HIGH
         or        dx,bx                    ; jsou nàjakÇ ©†dky ?
         pop       dx
         jz        EditBIm8                 ; nejsou ë†dnÇ ©†dky

; ------ vloëen° z†znamñ do souboru

         push      ax
         push      dx
         mov       dx,es:[DBFAktZ+2]
         mov       ax,es:[DBFAktZ]          ; aktivn° z†znam
         call      EdiBZIns                 ; vloëen° novòch z†znamñ
         pop       dx
         pop       ax
         jc        EditBIm8                 ; chyba

; ------ resetov†n° ukazatele v souboru

         call      far ptr ResFile          ; resetov†n° ukazatele v souboru
         mov       bx,es:[DBFAktZ+2]
         mov       cx,es:[DBFAktZ]          ; aktivn° z†znam

; ------ import dat ze souboru AX

EditBIm7:call      EDBImp                   ; import dat ze souboru AX

EditBIm8:call      far ptr ClosFile         ; uzav©en° souboru AX

EditBIm9:pop       ax
         ret

; -----------------------------------------------------------------------------
;        import dat ze souboru
; -----------------------------------------------------------------------------
; VSTUP: AX=identifik†tor souboru
;        SI=adresa definice okna
;        ES=segment okna
;        BX:CX=poá†teán° z†znam
; VùSTUP: CY=chyba
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) adresa definice okna
;                   SS:[BP-4] (2) identifik†tor vstupn°ho souboru
;                   SS:[BP-8] (4) ukazatel á°sla z†znamu
;                   SS:[BP-10] (2) adresa konce bufferu (konce dat v bufferu)
;                   SS:[BP-11] (1) znak oddàlovaáe (0=nen°)
; -----------------------------------------------------------------------------
;˛
EDBImp   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         mov       bp,sp
         sub       sp,12

; ------ p©°prava lok†ln°ch promànnòch

         mov       ss:[bp-2],si             ; adresa definice okna
         mov       ss:[bp-4],ax             ; identifik†tor souboru
         mov       ss:[bp-8],cx             ; ukazatel á°sla z†znamu
         mov       ss:[bp-8+2],bx
         mov       ax,es:[DBFMaxZ]          ; maxim†lnà z†znamñ v bufferu
         mul       word ptr es:[DBFBytZ]    ; vòpoáet velikosti bufferu
         add       ax,es:[DBFAdrD]          ; adresa konce bufferu
         mov       ss:[bp-10],ax            ; adresa konce bufferu

; ------ p©°prava znaku oddàlovaáe dat

         mov       al,ds:[DBImpPar]         ; parametry pro import
         mov       ah,","
         shr       al,1
         jc        EDBImp1                  ; oddàlovac° á†rka
         mov       ah,";"
         shr       al,1
         jc        EDBImp1                  ; oddàlovac° st©edn°k
         mov       ah,TAB
         shr       al,1
         jc        EDBImp1                  ; oddàlovac° tabul†tor
         mov       ah,"≥"
         shr       al,1
         jc        EDBImp1                  ; oddàlovac° r†m
         mov       ah,0                     ; nen° oddàlovaá
EDBImp1: mov       ss:[bp-11],ah            ; znak oddàlovaáe poloëek

; ------ naáten° dat do bufferu

         call      EDBImpCR                 ; naáten° obsahu bufferu
         dec       si                       ; n†vrat ukazatele dat v bufferu

; ------ vymaz†n° bufferu jednoho z†znamu

EDBImp2: mov       al," "                   ; mazac° znak mezery
         mov       di,es:[DBFAdrE]          ; adresa editaán°ho bufferu
         mov       cx,es:[DBFBytZ]          ; poáet bajtñ na z†znam
         cld
         rep       stosb                    ; vymaz†n° bufferu

; ------ p©°prava k dek¢dov†n° dat z†znamu

         mov       bx,es:[DBFAdrP]          ; adresa popisovaáñ poloëek
         mov       di,es:[DBFAdrE]          ; adresa editaán°ho bufferu
         inc       di                       ; zaá†tek prvn° poloëky

; ------ MEMO pole se p©eskoá°

EDBImp3: mov       ah,es:[bx+DBFDelX]       ; dÇlka poloëky
         test      byte ptr es:[bx+DBFParX],bit5 ; je to MEMO pole ?
         jnz       EDBImp44                 ; je MEMO pole - dal®° poloëka

; ------ dek¢dov†n° poloëky v m¢du pozice

EDBImp4: test      byte ptr ds:[DBImpPar],bit4 ; je uráeno pozic° ?
         jz        EDBImp5                  ; nen° m¢d pozice
         mov       cx,es:[bx+DBFDelX]       ; dÇlka poloëky (pozic)
EDBImp42:call      EDBImpC                  ; naáten° znaku
         call      EDBImpU                  ; uloëen° znaku
         loop      EDBImp42                 ; dal®° znak
EDBImp44:jmp       EDBImp7                  ; dal®° poloëka

; ------ dek¢dov†n° textovÇ poloëky

EDBImp5: call      EDBImpC                  ; naáten° prvn°ho znaku
         cmp       al,'"'
         jne       EDBImp6
EDBImp51:call      EDBImpC                  ; naáten° znaku
         cmp       al,'"'
         je        EDBImp53                 ; je konec poloëky
EDBImp52:call      EDBImpU                  ; uloëen° znaku
         jmp       short EDBImp51

EDBImp53:call      EDBImpC                  ; dal®° znak
         cmp       al,'"'
         je        EDBImp52                 ; zdvojenÇ uvozovky
EDBImp54:cmp       al,ss:[bp-11]            ; oddàlovaá ?
         je        EDBImp44                 ; oddàlovaá - konec poloëky
         call      EDBImpC                  ; dal®° znak
         jmp       short EDBImp54

; ------ dek¢dov†n° jinÇ poloëky

EDBImp6: cmp       al,ss:[bp-11]
         je        EDBImp7                  ; je oddàlovaá
EDBImp62:call      EDBImpU                  ; uloëen° znaku
         call      EDBImpC                  ; dal®° znak
         cmp       al,ss:[bp-11]
         jne       EDBImp62                 ; nen° oddàlovaá - dal®° znak

; ------ p©°prava pro dal®° poloëku

EDBImp7: mov       al,ah
         mov       ah,0
         add       di,ax                    ; dal®° poloëka
         add       bx,DBFX                  ; popisovaá dal®°ho z†znamu
         cmp       bx,es:[DBFAdrE]          ; je jië konec popisovaáñ ?
         jae       EDBImp72                 ; je jië konec popisovaáñ
         jmp       EDBImp3                  ; dek¢dov†n° dal®° poloëky

; ------ nalezen° konce ©†dku

EDBImp72:call      EDBImpC                  ; dal®° znak
         cmp       al,LF
         jne       EDBImp72                 ; nalezen° konce ©†dku

; ------ uloëen° dek¢dovanÇho z†znamu (sem se sk†áe z EDBImpC)

EDBImp8: push      si
         call      EDBImpK                  ; korekce z†znamu
         mov       ax,ss:[bp-8]             ; á°slo z†znamu
         mov       dx,ss:[bp-8+2]
         mov       si,ss:[bp-2]             ; adresa definice okna
         mov       di,es:[DBFAdrE]          ; adresa z†znamu
         call      far ptr SetDBF           ; uloëen° z†znamu
         pop       si
         jc        EDBImp88                 ; nàjak† chyba

; ------ zvò®en° poátu z†znamñ

         cmp       dx,es:[DBFMaxZ+2]
         jne       EDBImp82
         cmp       ax,es:[DBFMaxZ]
EDBImp82:jb        EDBImp85                 ; nen° zvò®en° poátu z†znamñ
         add       word ptr es:[DBFMaxZ],1
         adc       word ptr es:[DBFMaxZ+2],0

; ------ p©°prava pro dal®° z†znam

EDBImp85:add       word ptr ss:[bp-8],1     ; zvò®en° ukazatele á°sla z†znamu
         adc       word ptr ss:[bp-8+2],0
         jmp       EDBImp2                  ; dal®° z†znam

; ------ uloëen° novÇho z†hlav°

EDBImp88:mov       si,ss:[bp-2]             ; adresa definice okna
         call      far ptr HlavDBF          ; z†pis z†hlav° souboru
         mov       word ptr es:[DBFNumD],0  ; datovò buffer je neplatnò

; ------ n†vrat registrñ

EDBImp9: mov       sp,bp
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

EDBImp   ENDP

; ------ uloëen° znaku AL do poloëky v z†znamu ES:DI (AH=omezen° dÇlky poloëky)

EDBImpU: or        ah,ah                    ; je konec poloëky ?
         jz        EDBImpU2                 ; je jië konec poloëky
         cld
         stosb                              ; uloëen° bajtu
         dec       ah                       ; sn°ëen° á°taáe zbylÇ dÇlky
EDBImpU2:ret

; ------ naáten° znaku AL z bufferu SI

EDBImpC: cmp       si,ss:[bp-10]            ; je konec dat v bufferu ?
         jae       EDBImpCR                 ; je jië konec dat v bufferu
EDBImpC1:mov       al,es:[si]               ; znak z bufferu
         inc       si                       ; zvò®en° ukazatele dat
         cmp       al,CR                    ; je znak CR ?
         je        EDBImpC                  ; znak CR se ignoruje
         cmp       al,LF                    ; je konec ©†dku ?
         je        EDBImpC2                 ; konec ©†dku - konec z†znamu
         ret

EDBImpC2:add       sp,2                     ; zru®en° n†vratovÇ adresy
         jmp       EDBImp8                  ; uloëen° z†znamu

; ------ naáten° obsahu bufferu

EDBImpCR:push      di
         push      ax
         push      cx

         mov       ax,ss:[bp-4]             ; adresa bufferu
         mov       di,es:[DBFAdrD]          ; adresa datovÇho bufferu
         mov       cx,ss:[bp-10]            ; adresa konce bufferu
         sub       cx,di                    ; velikost bufferu
         call      far ptr ReadFile         ; naáten° obsahu bufferu
         mov       si,di                    ; zaá†tek bufferu

         add       di,cx                    ; novò konec bufferu
         mov       ss:[bp-10],di            ; novò konec bufferu
         or        cx,cx                    ; bylo nàco naáteno ?

         pop       cx
         pop       ax
         pop       di
         jnz       EDBImpC1                 ; bylo nàco naáteno
         add       sp,2                     ; zru®en° n†vratovÇ adresy
         clc                                ; p©°znak operace OK
         jmp       EDBImp88                 ; nejsou dal®° data - konec

; -----------------------------------------------------------------------------
;        korekce z†znamu
; -----------------------------------------------------------------------------

EDBImpK: mov       bx,es:[DBFAdrP]          ; adresa popisovaáñ
         mov       di,es:[DBFAdrE]          ; adresa bufferu
         inc       di                       ; zaá†tek prvn° poloëky

; ------ test, zda je á°seln† poloëka

EDBImpK2:test      byte ptr es:[bx+DBFParX],bit1+bit2 ; je á°seln† poloëka ?
         jz        EDBImpK8                 ; nen° á°seln† poloëka

; ------ p©°prava parametrñ poloëky

         mov       si,es:[bx+DBFNamX]       ; popisovaá
         xor       cx,cx
         mov       cl,es:[si+16]            ; CX = dÇlka poloëky
         mov       dx,cx                    ; DX = dÇlka poloëky
         cmp       byte ptr es:[si+17],0    ; jsou desetiny ?
         je        EDBImpK3                 ; nejsou desetiny
         sub       dl,es:[si+17]            ; offset desetinnòch m°st
         dec       dx                       ; offset desetinnÇ teáky
EDBImpK3:add       dx,di                    ; adresa desetinnÇ teáky

; ------ nalezen° zaá†tku textu poloëky

EDBImK34:push      cx
         mov       si,di                    ; adresa zaá†tku poloëky
EDBImpK4:cmp       byte ptr es:[si]," "     ; je zaá†tek textu ?
         jne       EDBImpK5                 ; nalezen zaá†tek textu
         inc       si                       ; dal®° znak
         loop      EDBImpK4                 ; dal®° znak
EDBImpK5:jcxz      EDBImpK7                 ; nen° text

; ------ nalezen° oddàlovac° teáky

         push      ax
         mov       al,ds:[OddelDes]         ; oddàlovaá desetin
EDBImpK6:cmp       byte ptr es:[si]," "     ; konec poloëky ?
         je        EDBImK62                 ; nalezen konec poloëky
         cmp       byte ptr es:[si],al
         je        EDBImK62
         cmp       byte ptr es:[si],"."
         je        EDBImK62
         inc       si
         loop      EDBImpK6
EDBImK62:pop       ax

         pop       cx

; ------ kontrola pozice teáky

         cmp       si,dx                    ; je teáka OK ?
         je        EDBImpK8                 ; teáka je OK
         ja        EDBImK66                 ; teáka m† bòt d†le

; ------ vloëen° mezery

         call      EditBII2                 ; vloëen° mezery
         mov       byte ptr es:[di]," "
         jmp       short EDBImK34

; ------ vypu®tàn° znaku

EDBImK66:call      EditBDLC                 ; zru®en° znaku
         jmp       short EDBImK34           ; dal®° korekce

EDBImpK7:pop       cx

; ------ dal®° poloëka

EDBImpK8:add       di,es:[bx+DBFDelX]       ; adresa dal®° poloëky
         add       bx,DBFX                  ; dal®° popisovaá
         cmp       bx,es:[DBFAdrE]          ; je konec popisovaáñ ?
         jb        EDBImpK2                 ; nen° je®tà konec popisovaáñ
         ret

; -----------------------------------------------------------------------------
;        Ctrl-U n†vrat zmàn
; -----------------------------------------------------------------------------

EditBUnd:call      EdiBEBeg                 ; zah†jen° editace
         ret

; -----------------------------------------------------------------------------
;        ESC - konec editace
; -----------------------------------------------------------------------------

EditBBE1:call      UlozDBF                  ; uloëen° editovanÇho bufferu
         and       byte ptr ds:[DBFEParm],not bit0 ; ukonáen° editace
         ret

; -----------------------------------------------------------------------------
;        F4 - zah†jen° editace ©†dku
; -----------------------------------------------------------------------------

EditBBEd:test      byte ptr ds:[DBFEParm],bit0 ; je editace ?
         jnz       EditBBE1                 ; je jië editace - ukonáen° editace

         cmp       word ptr es:[DBFNumP],0  ; jsou nàjakÇ popisovaáe ?
         je        EditBBE0                 ; nejsou popisovaáe

         or        byte ptr ds:[DBFEParm],bit0 ; p©°znak editace
         call      EdiBEBeg                 ; zah†jen° editace
EditBBE0:ret

; -----------------------------------------------------------------------------
;        zah†jen° editace ©†dku okna SI (CY=nen° platn† poloëka)
; -----------------------------------------------------------------------------

EdiBEBeg PROC      NEAR

         test      byte ptr ds:[DBFEParm],bit0 ; prob°h† editace ?
         jz        EdiBEBg9                 ; nen° editace

; ------ £schova registrñ

         push      bx
         push      cx
         push      si
         push      di
         push      es

; ------ inicializaán° vymaz†n° bufferu

         push      ax
         and       byte ptr ds:[DBFEParm],not bit1+bit3 ; nen° modifikace
         call      DBFAdrES                 ; aktualizace adresy okna -> ES
         mov       cx,es:[DBFBytZ]          ; poáet bajtñ na z†znam
         mov       di,es:[DBFAdrE]          ; adresa editaán°ho bufferu
         cld
         mov       al," "
         rep       stosb                    ; vymaz†n° bufferu
         pop       ax

; ------ adresa aktivn° poloëky -> ES:DI

         call      far ptr GetADBF          ; poskytnut° aktivn° poloëky
         jc        EdiBEBg4                 ; chyba

; ------ £schova poloëky do bufferu (uchovat p©°znak CY !)

         mov       si,di                    ; SI <- aktivn° poloëka
         mov       cx,es:[DBFBytZ]          ; poáet bajtñ na z†znam
         mov       di,es:[DBFAdrE]          ; adresa editaán°ho bufferu
         cld
         rep       movs byte ptr es:[di],es:[si] ; kopie aktivn° poloëky

; ------ inicializace á°selnòch poloëek

EdiBEBg4:pushf
         mov       di,es:[DBFAdrE]          ; adresa editaán°ho bufferu
         inc       di                       ; zaá†tek editaán°ho bufferu
         mov       cx,es:[DBFNumP]          ; poáet popisovaáñ
         jcxz      EdBEBg72                 ; nen° ë†dn† poloëka
         mov       bx,es:[DBFAdrP]          ; adresa popisovaáñ
EdiBEBg5:test      byte ptr es:[bx+DBFParX],bit1+bit2 ; je to á°seln† poloëka ?
         jz        EdiBEBg7                 ; nen° to á°seln† poloëka
         mov       si,es:[bx+DBFNamX]       ; popisovaá poloëky

         push      bx
         mov       bx,es:[si+16]            ; dÇlka poloëky, poáet desetin
         or        bh,bh                    ; jsou desetiny ?
         jz        EdiBEBg6                 ; nejsou desetiny
         sub       bl,bh                    ; offset desetinnÇ teáky
         mov       bh,0
         add       bx,di                    ; adresa desetinnÇ teáky
         mov       byte ptr es:[bx-1],"."   ; uloëen° desetinnÇ teáky
EdiBEBg6:pop       bx

EdiBEBg7:add       di,es:[bx+DBfDelX]       ; dal®° poloëka
         add       bx,DBFX                  ; dal®° popisovaá
         loop      EdiBEBg5                 ; dal®° poloëka
EdBEBg72:popf

; ------ n†vrat registrñ

EdiBEBg8:pop       es
         pop       di
         pop       si
         pop       cx
         pop       bx
EdiBEBg9:ret

EdiBEBeg ENDP

; -----------------------------------------------------------------------------
;        F5: kopie z†znamu do aktivn°ho editovanÇho z†znamu
; -----------------------------------------------------------------------------

; ------ test, zda je operace povolena

EditBKop:test      byte ptr ds:[DBFEParm],bit0 ; je editace z†znamu ?
         jz        EditBKp9                 ; nen° editace z†znamu
         test      byte ptr es:[DBFParm],bit1 ; je z†kaz z†pisu ?
         jnz       EditBKp9                 ; je z†kaz z†pisu

; ------ zad†n° á°sla z†znamu

         mov       di,offset DBKMSLin       ; menu zad†n° á°sla z†znamu
         call      EditBLM                  ; obsluha ©†dkovÇho menu
         jc        EditBKp9                 ; p©eru®en° operace

; ------ £schova registrñ

         push      ax
         push      dx

; ------ naáten° zadanÇho á°sla z†znamu

         call      DBGetZNm                 ; vstup zadanÇho á°sla -> DX:AX
         jc        EditBKp8                 ; nen° nic zad†no

; ------ oprava á°sla z†znamu

         sub       ax,1                     ; oprava á°sla z†znamu
         sbb       dx,0
         jc        EditBKp8

; ------ naáten° zadanÇho z†znamu

         call      far ptr GetDBF           ; poskytnut° zadanÇho z†znamu
         jc        EditBKp8                 ; chyba

; ------ kopie z†znamu do editaán°ho bufferu

         push      si
         mov       cx,es:[DBFBytZ]          ; poáet bajtñ na z†znam
         mov       si,di                    ; zaá†tek z†znamu
         mov       di,es:[DBFAdrE]          ; adresa editaán°ho bufferu
         cld
         rep       movs byte ptr es:[di],es:[si] ; kopie dat ze z†znamu
         pop       si
         or        byte ptr ds:[DBFEParm],bit1 ; p©°znak modifikace bufferu

; ------ nulov†n° MEMO pol°

         mov       word ptr ds:[DBZobOld+2],-1 ; pot©eba naáten° MEMO

         mov       bx,es:[DBFAdrP]          ; adresa indexñ popisovaáñ
         mov       di,es:[DBFAdrE]          ; editaán° bufferu
         mov       cx,es:[DBFNumP]          ; poáet popisovaáñ
         inc       di                       ; zaá†tek poloëek
         jcxz      EditBKp8                 ; nen° ë†dn† poloëka
EditBKp4:test      byte ptr es:[bx+DBFParX],bit5 ; je to MEMO pole ?
         jz        EditBKp6                 ; nen° to MEMO pole
         push      di
         push      cx
         mov       cx,10
EditBKp5:mov       byte ptr es:[di]," "
         inc       di
         loop      EditBKp5
         pop       cx
         pop       di
EditBKp6:add       di,es:[bx+DBFDelX]       ; adresa dal®° poloëky
         add       bx,DBFX                  ; dal®° index
         loop      EditBKp4                 ; dal®° poloëka

; ------ n†vrat registrñ

EditBKp8:pop       dx
         pop       ax
EditBKp9:ret

; -----------------------------------------------------------------------------
;        F6 skok na z†znam
; -----------------------------------------------------------------------------

; ------ £schova registrñ

EditBSko:push      ax
         push      dx

; ------ volba novÇho z†znamu

         mov       di,offset DBSMSLin
         call      EditBLM                  ; obsluha ©†dkovÇho menu
         jc        EditBSk8                 ; p©eru®en° operace

; ------ dek¢dov†n° á°sla z†znamu

         call      DBGetZNm                 ; vstup zadanÇho á°sla -> DX:AX
         jc        EditBSk8                 ; nezad†no platnÇ á°slo

; ------ uloëen° aktu†ln°ho editovanÇho z†znamu

         call      UlozDBF                  ; uloëen° editovanÇho bufferu

; ------ oprava á°sla z†znamu

         sub       ax,1
         sbb       dx,0
         jc        EditBSk8                 ; neplatnÇ á°slo z†znamu

; ------ zru®en° registrñ DX a AX, je-li platnÇ á°slo z†znamu

         add       sp,4
         jmp       short EditBSk9

; ------ n†vrat registrñ p©i p©eru®en° operace

EditBSk8:pop       dx
         pop       ax

EditBSk9:ret

; -----------------------------------------------------------------------------
;        vstup á°sla z p©°kazovÇho ©†dku -> DX:AX (CY=chyba)
; -----------------------------------------------------------------------------

DBGetZNm PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      si
         push      di

; ------ p©°prava ukazatelñ bufferu

         mov       si,offset LinBuff        ; buffer p©°kazovÇho ©†dku
         mov       cl,ds:[LinNum]           ; poáet znakñ v p©°kazovÇm ©†dku
         mov       ch,0

; ------ p©°prava st©adaáe

         xor       bx,bx                    ; st©adaá LOW
         xor       di,di                    ; st©adaá HIGH

; ------ naáten° prvn° á°slice

         call      DBGetZN7                 ; prvn° á°slice
         jc        DBGetZN6                 ; nen° ë†dn† platn† á°slice

; ------ vyn†soben° st©adaáe

DBGetZN2:push      ax
         mov       ax,10
         mul       bx                       ; n†soben° st©adaáe LOW
         xchg      ax,bx                    ; BX <- novò st©adaá LOW
         xchg      ax,di                    ; AX <- starò st©adaá HIGH
         mov       di,dx                    ; DI <- novò st©adaá HIGH
         mov       dx,10
         mul       dx                       ; n†soben° st©adaáe HIGH
         add       di,ax                    ; novò st©adaá HIGH

         jnc       DBGetZN3
         mov       di,-1                    ; omezen° st©adaáe
         mov       bx,di

DBGetZN3:pop       ax
         mov       ah,0
         add       bx,ax                    ; p©iáten° novÇ á°slice
         adc       di,0

         jnc       DBGetZN4
         mov       di,-1
         mov       bx,di

DBGetZN4:call      DBGetZN7                 ; dal®° á°slice
         jnc       DBGetZN2
         clc

; ------ naátenÇ á°slo

DBGetZN6:xchg      ax,bx                    ; AX <- st©adaá LOW
         mov       dx,di                    ; DX <- st©adaá HIGH

; ------ n†vrat registrñ

         pop       di
         pop       si
         pop       cx
         pop       bx
         ret

DBGetZNm ENDP

; ------ naáten° jednÇ á°slice

DBGetZN7:jcxz      DBGetZN9                 ; nen° dal®° znak
         cld
         lodsb                              ; naáten° znaku z bufferu
         dec       cx
         cmp       al," "
         je        DBGetZN7                 ; mezera se ignoruje
         cmp       al,"."
         je        DBGetZN7                 ; teáka se ignoruje
         cmp       al,cs:[DBFOdDes]         ; je oddàlovaá desetin ?
         je        DBGetZN7                 ; teáka se ignoruje
         cmp       al,"0"
         jb        DBGetZN8                 ; nen° platn† á°slice
         cmp       al,"9"
         ja        DBGetZN8                 ; nen° platn† á°slice
         sub       al,"0"                   ; zadanÇ á°slo
         ret

DBGetZN8:dec       si                       ; n†vrat znaku
         inc       cx                       ; n†vrat á°taáe znakñ
DBGetZN9:stc
         ret

; -----------------------------------------------------------------------------
;        F7 hled†n° dat
; -----------------------------------------------------------------------------

; ------ pokraáov†n° v hled†n° Ctrl-L

EditBHlL:cmp       word ptr es:[DBFNumP],0  ; jsou nàjakÇ poloëky ?
         je        EditBH01                 ; nejsou poloëky
         test      byte ptr ds:[DBFEParm],bit0 ; je editace ?
         jz        EditBH02                 ; nen° editace
EditBH01:ret

; ------ p©°prava pro pokraáov†n° v hled†n°

EditBH02:push      ax                       ; kurzor LOW
         push      dx                       ; kurzor HIGH
         push      word ptr es:[DBFTopZ]    ; poá†teán° z†znam LOW
         push      word ptr es:[DBFTopZ+2]  ; poá†teán° z†znam HIGH

         add       ax,1                     ; pokraáuje se dal®°m z†znamem
         adc       dx,0

         and       byte ptr ds:[DBFEPar2],not bit1+bit2 ; nebude oznaáov†n°
         mov       cx,ds:[TextFndN]         ; dÇlka textu
         or        cx,cx                    ; je nàjakò text ?
         jnz       EditBH18                 ; je nàjakò text v bufferu

EditBH08:jmp       EditBHl9                 ; operace p©eru®ena

; ------ test, zda je operace povolena

EditBHle:cmp       word ptr es:[DBFNumP],0  ; jsou nàjakÇ poloëky ?
         je        EditBH01                 ; nejsou poloëky
         test      byte ptr ds:[DBFEParm],bit0 ; je editace ?
         jz        EditBH10                 ; nen° editace
         ret

; ------ £schova registrñ

EditBH10:push      ax                       ; kurzor LOW
         push      dx                       ; kurzor HIGH
         push      word ptr es:[DBFTopZ]    ; poá†teán° z†znam LOW
         push      word ptr es:[DBFTopZ+2]  ; poá†teán° z†znam HIGH

; ------ zad†n° textu k hled†n°

         call      EditBHPr                 ; p©°prava p©ep°naáñ
         mov       di,offset DBHMSLin
         call      EditBLM                  ; obsluha ©†dkovÇho menu
         jc        EditBH08

; ------ dÇlka zadanÇho textu

         mov       ch,0
         mov       cl,ds:[LinNum]           ; dÇlka hledanÇho textu
         jcxz      EditBH08                 ; nen° zad†n ë†dnò text
         mov       ds:[TextFndN],cx         ; dÇlka textu

; ------ £schova textu do bufferu

         push      ax
         push      si
         push      cx
         push      es

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       di,offset TextFnd        ; buffer hledanÇho textu
         mov       si,offset LinBuff        ; buffer zadanÇho textu
         cld
EditBH12:lodsb
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         stosb
         loop      EditBH12

         pop       es
         pop       cx
         pop       si
         pop       ax

; ------ omezen° dÇlky hledanÇho textu podle dÇlky z†znamu -> CX, BX

EditBH18:mov       bx,es:[DBFBytZ]          ; BX <- dÇlka z†znamu
         sub       bx,cx                    ; poáet ©etàzcñ v z†znamu
         jnc       EditBHl1                 ; je to OK
         xor       bx,bx                    ; omezen° na 1 ©etàzec
         mov       cl,es:[DBFBytZ]          ; omezen° dÇlky textu
EditBHl1:inc       bx                       ; korekce poátu ©etàzcñ

; ------ zobrazen° hl†®en° o vyhled†v†n°

         push      ax
         push      cx
         push      si

         mov       si,offset DBHMLTxt
         call      far ptr InfDisp0         ; zobrazen° hl†®en°

         mov       word ptr ds:[InfoKCit],ax ; á°taá kurzoru
         mov       word ptr ds:[InfoKCit+2],dx

         mov       ax,es:[DBFMaxZ+2]        ; poáet z†znamñ HIGH
         mov       word ptr ds:[InfoKMax+2],ax
         mov       ax,es:[DBFMaxZ]
         mov       word ptr ds:[InfoKMax],ax

         xor       cx,cx                    ; CX <- 0
         call      far ptr InfoKurz         ; nulov†n° kurzoru

         pop       si
         pop       cx
         pop       ax

; ------ p©°prava k vyhled†v†n°

         mov       word ptr ds:[DBCitFnd],0 ; nulov†n° á°taáe nalezenòch ©etàzcñ
         mov       word ptr ds:[DBCitFnd+2],0
         call      DBFGetDT                 ; £schova data a áasu

; ------ poskytnut° z†znamu DX:AX

EditBHl2:mov       bp,15                    ; á°taá krokñ pro zobrazen°
EditBHl3:mov       es:[DBFAktZ],ax          ; aktivn° z†znam
         mov       es:[DBFAktZ+2],dx
         call      far ptr GetDBF           ; dal®° poloëka
         jc        EditBHl7                 ; nen° dal®° poloëka - konec

; ------ prohled†n° bufferu

         call      EditBHBf                 ; prohled†n° bufferu
         jc        EditBHl6                 ; ©etàzec v z†znamu nenalezen

; ------ text nalezen - zru®en° registrñ v z†sobn°ku

         test      byte ptr ds:[DBFEPar2],bit1+bit2 ; bude oznaáen° z†znamu ?
         jnz       EditBHl4                 ; je oznaáen° z†znamu
         add       sp,4*2                   ; zru®en° registrñ v z†sobn°ku
         ret

; ------ zvò®en° á°taáe nalezenòch ©etàzcñ

EditBHl4:add       word ptr ds:[DBCitFnd],1 ; zvò®en° á°taáe nalezenòch ©etàzcñ
         adc       word ptr ds:[DBCitFnd+2],0

; ------ nastaven° oznaáen° poloëky

         test      byte ptr ds:[DBFEPar2],bit1 ; m† bòt oznaáen° ?
         jz        EditBHl5                 ; nem† bòt oznaáen°
         cmp       byte ptr es:[di]," "     ; je poloëka oznaáena ?
         jne       EditBHl6                 ; poloëka je jië oznaáena
         mov       byte ptr es:[di],"*"     ; oznaáen° poloëky
         jmp       short EditBH52           ; dal®° poloëka

; ------ nulov†n° oznaáen° poloëky

EditBHl5:cmp       byte ptr es:[di]," "     ; je poloëka vynulov†na ?
         je        EditBHl6                 ; je jië vynulov†na
         mov       byte ptr es:[di]," "     ; vynulov†n° oznaáen° poloëky
EditBH52:call      far ptr SetDBF           ; uloëen° poloëky na disk

; ------ obsluha zobrazen° okna a kurzoru

EditBHl6:add       ax,1                     ; zvò®en° á°sla dal®°ho z†znamu
         adc       dx,0
         dec       bp                       ; á°taá pro zobrazen° okna
         jnz       EditBHl3                 ; pokraáov†n° dal®°m z†znamem
         call      far ptr DispBMnu         ; zobrazen° okna

         push      cx
         mov       cx,15                    ; poáet z†znamñ
         call      far ptr InfoKurz         ; zobrazen° informaán°ho kurzoru
         pop       cx

         call      far ptr TestBEsc         ; test p©eru®en° operace
         jnc       EditBHl2                 ; nen° p©eru®en° operace
         call      far ptr FlushChr         ; vypr†zdnàn° bufferu kl†vesnice

; ------ konec hled†n°

EditBHl7:call      DBFSetDT                 ; n†vrat data a áasu souboru

; ------ test, zda bylo nàco nalezeno

         mov       di,offset DBHMFnd        ; text nenalezen
         mov       ax,word ptr ds:[DBCitFnd] ; á°taá nalezenòch z†znamñ
         or        ax,word ptr ds:[DBCitFnd+2] ; bylo nàco nalezeno ?
         jz        EditBHl8                 ; nebylo nic nalezeno

; ------ dek¢dov†n° á°sla poátu z†znamñ

         push      es
         push      ds
         pop       es
         mov       di,offset DBH1MFBN+1
         mov       ax,word ptr ds:[DBCitFnd] ; poáet z†znamñ
         mov       dx,word ptr ds:[DBCitFnd+2]
         xor       bx,bx                    ; nen° oddàlovaá ani barva
         call      far ptr DekNum           ; dek¢dov†n° á°sla
         xchg      ax,di
         sub       ax,offset DBH1MFBN+1
         mov       ds:[DBH1MFBN],al         ; dÇlka á°sla
         pop       es

; ------ zobrazen° hl†®en°

         call      far ptr NulBreak         ; nulov†n° p©°znaku p©eru®en°
         mov       di,offset DBH1MFnd       ; text nalezen

EditBHl8:call      far ptr TestBEsc         ; bylo p©eru®en° operace ?
         jc        EditBHl9                 ; nic se nehl†s°
         call      EditBLM                  ; hl†®en°

; ------ n†vrat ukazatelñ

EditBHl9:pop       word ptr es:[DBFTopZ+2]  ; poá†teán° z†znam HIGH
         pop       word ptr es:[DBFTopZ]    ; poá†teán° z†znam LOW
         pop       dx
         pop       ax
         ret

; ------ p©ep°naá zad†n° textu k hled†n° "Oznaáit"

EditBHS1 PROC      FAR

         xor       byte ptr ds:[DBFEPar2],bit1 ; zmàna p©ep°naáe "Oznaáit"
         and       byte ptr ds:[DBFEPar2],not bit2
EditBHS0:call      EditBHPr                 ; p©°prava p©ep°naáñ
         call      far ptr DispMnu          ; novÇ zobrazen° menu
         ret

EditBHS1 ENDP

EditBHS2:xor       byte ptr ds:[DBFEPar2],bit2 ; zmàna p©ep°naáe "Nulovat"
         and       byte ptr ds:[DBFEPar2],not bit1
         jmp       short EditBHS0

; ------ p©°prava p©ep°naáñ

EditBHPr PROC      NEAR

         push      dx

         mov       dl,ds:[DBFEPar2]
         shr       dl,1
         test      dl,bit0
         mov       dh,ds:[ZnakSwch]         ; p©ep°naá nastaven
         jnz       EditBHP2                 ; je nastaven
         mov       dh,ds:[ZnakSwch+1]       ; nenastaven
EditBHP2:mov       ds:[DBHMLPl1],dh         ; znak p©ep°naáe

         test      dl,bit1
         mov       dh,ds:[ZnakSwch]         ; p©ep°naá nastaven
         jnz       EditBHP3                 ; je nastaven
         mov       dh,ds:[ZnakSwch+1]       ; nenastaven
EditBHP3:mov       ds:[DBHMLPl2],dh         ; znak p©ep°naáe

         call      far ptr SetSwch

         pop       dx
         ret

EditBHPr ENDP

; ------ prohled†n° bufferu ES:DI (dÇlka ©etàzce CX, poáet pokusñ BX) -> CY=nen°

EditBHBf:push      ax
         push      bx
         push      si
         push      di
         cld

EditBHB2:push      di
         push      cx

         mov       si,offset TextFnd-1      ; hledanò text - 1
EditBHB6:mov       al,es:[di]               ; znak z bufferu
         inc       di
         inc       si
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         cmp       al,ds:[si]               ; porovn†n° s hledanòm ©etàzcem
         loope     EditBHB6                 ; dal®° znak

         pop       cx
         pop       di
         je        EditBHB8                 ; ©etàzec nalezen OK

         inc       di                       ; zvò®en° adresy v bufferu
         dec       bx                       ; á°taá pokusñ
         jnz       EditBHB2                 ; dal®° pokus
         stc                                ; p©°znak nenalezen° textu

EditBHB8:pop       di
         pop       si
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        £schova data a áasu souboru p©ed operac° (ES=okno)
; -----------------------------------------------------------------------------

DBFGetDT PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx

; ------ naáten° data a áasu souboru

         and       byte ptr ds:[DBFEPar2],not bit5 ; nebyl z†pis z†znamu
         mov       ax,es:[DBFIdent]         ; identifik†tor souboru
         call      far ptr GetDFile         ; poskytnut° data a áasu souboru
         mov       ds:[DBFETime],cx         ; áas souboru
         mov       ds:[DBFEDate],dx         ; datum souboru

; ------ n†vrat registrñ

         pop       dx
         pop       cx
         pop       ax
         ret

DBFGetDT ENDP

; -----------------------------------------------------------------------------
;        n†vrat data a áasu souboru, pokud byl modifikov†n (ES=okno)
; -----------------------------------------------------------------------------

DBFSetDT PROC      NEAR

; ------ £schova registrñ

         pushf
         push      ax
         push      cx
         push      dx

; ------ naáten° data a áasu souboru

         test      byte ptr ds:[DBFEPar2],bit5 ; nebyl z†pis z†znamu ?
         jz        DBFStDT9                 ; nebyl z†pis z†znamu

         call      far ptr ZapKrit          ; zapnut° kritickÇho m°sta
         mov       cx,ds:[DBFETime]         ; áas souboru
         mov       dx,ds:[DBFEDate]         ; datum souboru
         mov       ax,es:[DBFIdent]         ; identifik†tor souboru
         call      far ptr SetDFile         ; nastaven° data a áasu souboru
         call      far ptr FlshFile         ; uloëen° zmàn na disk
         call      far ptr VypKrit          ; vypnut° kritickÇho m°sta

; ------ n†vrat registrñ

DBFStDT9:pop       dx
         pop       cx
         pop       ax
         popf
         ret

DBFSetDT ENDP

; -----------------------------------------------------------------------------
;        F9 vloëen° novòch z†znamñ
; -----------------------------------------------------------------------------
;˛
EditBVlo:test      byte ptr ds:[DBFEParm],bit0 ; je editace ?
         jnz       EditBVl9                 ; je editace
         test      byte ptr es:[DBFParm],bit1 ; je z†kaz z†pisu ?
         jnz       EditBVl9                 ; je z†kaz z†pisu
         cmp       word ptr es:[DBFNumP],0  ; jsou nàjakÇ poloëky ?
         je        EditBVl9                 ; nejsou poloëky

; ------ zad†n° poátu z†znamñ k vloëen°

         mov       di,offset DBVMSLin
         call      EditBLM                  ; obsluha ©†dkovÇho menu
         jc        EditBVl9                 ; p©eru®en° operace

; ------ p©°prava zadanÇho poátu z†znamñ k vloëen° -> DI:BX

         push      ax
         push      dx

         call      DBGetZNm                 ; vstup zadanÇho á°sla -> DX:AX
         jc        EditBVl8                 ; chyba zad†n°

         mov       bx,ax
         or        bx,dx
         jz        EditBVl8                 ; nebylo nic zad†no

         mov       bx,ax                    ; poáet z†znamñ LOW
         mov       di,dx                    ; poáet z†znamñ HIGH

         pop       dx
         pop       ax

; ------ vloëen° z†znamñ

         mov       word ptr ds:[DBZobOld+2],-1 ; pot©eba naáten° MEMO

         call      ClosBMem                 ; uzav©en° souboru MEMO
         call      EdiBZIns                 ; vloëen° z†znamñ
         jmp       short EditBVl9

; ------ n†vrat registrñ p©i p©eru®en°

EditBVl8:pop       dx
         pop       ax

EditBVl9:ret

; -----------------------------------------------------------------------------
;                  vloëen° novòch z†znamñ do souboru
; -----------------------------------------------------------------------------
; VSTUP: DI:BX=poáet z†znamñ k vloëen°
;        DX:AX=á°slo z†znamu k vloëen° novòch z†znamñ
;        SI=definice okna datab†ze
;        DS=datovò segment
; VùSTUP: CY=chyba
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) definice okna datab†ze
;                   SS:[BP-4] (2) adresa starÇho okna
;                   SS:[BP-6] (2) segment novÇho okna
;                   SS:[BP-8] (2) adresa novÇho okna
;                   SS:[BP-10] (2) identifik†tor starÇho souboru
;                   SS:[BP-12] (2) identifik†tor novÇho souboru
;                   SS:[BP-16] (4) á°taá z†znamñ ke zkop°rov†n°
;                   SS:[BP-20] (4) á°taá z†znamñ p©ed poá†tkem vkl†d†n°
;                   SS:[BP-24] (4) á°taá z†znamñ k vloëen°
; -----------------------------------------------------------------------------

EdiBZIns PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      bp
         mov       bp,sp

; ------ p©°prava lok†ln°ch promànnòch

         sub       sp,24
         mov       ss:[bp-2],si             ; adresa definice okna
         mov       ss:[bp-20],ax            ; z†znam p©ed poá†tkem vkl†d†n°
         mov       ss:[bp-20+2],dx
         mov       ss:[bp-24],bx            ; á°taá z†znamñ k vloëen°
         mov       ss:[bp-24+2],di

; ------ zobrazen° hl†®en° o vkl†d†n° z†znamñ

         push      si
         mov       word ptr ds:[InfoKCit],0 ; á°taá ukazatele kurzoru
         mov       word ptr ds:[InfoKCit+2],0
         mov       si,offset DBFInsHl       ; hl†®en° o vkl†d†n°
         call      far ptr InfDisp0         ; zobrazen° hl†®en°
         pop       si

; ------ vytvo©en° vòstupn°ho souboru

         call      DBFTOpen                 ; vytvo©en° p©echodnÇho souboru
         jnc       EdiBZIn2                 ; soubor vytvo©en OK
EdiBZIn1:jmp       EdiBZIn9                 ; chyba

EdiBZIn2:mov       ss:[bp-6],ax             ; segment novÇho okna

; ------ maximalizace starÇho okna

         call      far ptr MaxiDBF          ; maximalizace starÇho okna

; ------ adresa starÇho okna

         call      DBFAdrES                 ; aktualizace adresy okna -> ES
         mov       ss:[bp-4],es             ; adresa starÇho okna

; ------ adresa novÇho okna

         push      es                       ; adresa starÇho okna

         call      far ptr GetDat           ; adresa novÇho okna -> ES
         mov       ss:[bp-8],es             ; adresa novÇho okna

; ------ identifik†tor novÇho souboru

         mov       ax,es:[DBFIdent]         ; identifik†tor novÇho souboru
         mov       ss:[bp-12],ax            ; identifik†tor novÇho souboru

; ------ z†pis z†hlav° do novÇho souboru (ukazatel resetov†n, chyba se ignoruje)

         mov       si,DBFHlava              ; z†hlav° souboru
         mov       cx,es:[DBFBytH]          ; dÇlka z†hlav° souboru
         call      far ptr WritFile         ; z†pis z†hlav° do souboru

         pop       es                       ; ES <- adresa starÇho okna

; ------ identifik†tor starÇho souboru

         mov       ax,es:[DBFIdent]         ; identifik†tor starÇho souboru
         mov       ss:[bp-10],ax            ; identifik†tor starÇho souboru

; ------ nastaven° ukazatele ve starÇm souboru za z†hlav° souboru

         xor       dx,dx                    ; DX <- 0 offset HIGH
         mov       cx,es:[DBFBytH]          ; dÇlka z†hlav° (bajtñ)
         call      far ptr SetUFile         ; nastaven° ukazatele v souboru

; ------ poáet z†znamñ ve starÇm souboru, inicializace ukazatele operace

         mov       ax,es:[DBFMaxZ]          ; poáet z†znamñ v souboru
         mov       ss:[bp-16],ax            ; á°taá z†znamñ ke zkop°rov†n°
         add       ax,ss:[bp-24]            ; + poáet vkl†danòch z†znamñ
         mov       word ptr ds:[InfoKMax],ax ; maximum pro kurzor
         mov       ax,es:[DBFMaxZ+2]
         mov       ss:[bp-16+2],ax
         adc       ax,ss:[bp-24+2]
         mov       word ptr ds:[InfoKMax+2],ax
         xor       cx,cx                    ; CX <- 0
         call      far ptr InfoKurz         ; zobrazen° kurzoru operace

; ------ zkop°rov†n° dat p©ed vkl†danòmi z†znamy

         call      EdiBZIC                  ; zkop°rov†n° prvn° á†sti dat
         jc        EdiBZIn8                 ; chyba nebo p©eru®en° operace

; ------ vytvo©en° pr†zdnÇho z†znamu

         mov       es,ss:[bp-4]             ; adresa starÇho okna
         mov       di,es:[DBFAdrD]          ; adresa datovÇho bufferu
         mov       cx,es:[DBFBytZ]          ; poáet bajtñ na z†znam
         mov       al," "                   ; mazac° znak mezery
         cld
         rep       stosb                    ; vymaz†n° z†znamu

; ------ á°taá z†znamñ k vloëen°

EdiBZIn4:mov       cx,1                     ; z†pis 1 z†znamu
         sub       ss:[bp-24],cx            ; á°taá z†znamñ
         sbb       word ptr ss:[bp-24+2],0
         jc        EdiBZIn6                 ; nen° dal®° z†znam

; ------ z†pis jednoho z†znamu

         call      EdiBZIW                  ; z†pis 1 z†znamu
         jc        EdiBZIn8                 ; chyba nebo p©eru®en° operace

; ------ test, zda je p©eru®en° operace

         call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jc        EdiBZIn8                 ; je p©eru®en° operace
         jmp       short EdiBZIn4           ; dal®° z†znam

; ------ zkop°rov†n° druhÇ á†sti dat (za vkl†danòmi daty)

EdiBZIn6:dec       word ptr ss:[bp-20+2]    ; neplatnò á°taá p©ed zaá†tkem
         call      EdiBZIC                  ; zkop°rov†n°
         jc        EdiBZIn8                 ; chyba nebo p©eru®en° operace

; ------ konec konverze souboru

         mov       es,ss:[bp-8]             ; adresa novÇho okna
         call      UlozDEOF                 ; z†pis koncovÇho znaku EOF

         mov       ax,ss:[bp-6]             ; segment novÇho okna
         mov       si,ss:[bp-2]             ; adresa definice okna
         call      DBFTClos                 ; uzav©en° vòstupn°ho souboru
         jnc       EdiBZIn9                 ; operace OK

; ------ chyba z†pisu do vòstupn°ho souboru

EdiBZIn8:mov       di,offset DBHMWrt        ; hl†®en° - chyba z†pisu
         call      far ptr Lin0MenP         ; chybovÇ hl†®en°

; ------ zru®en° vòstupn°ho souboru, zru®en° bufferu

         mov       ax,ss:[bp-6]             ; segment novÇho okna
         mov       si,ss:[bp-2]             ; adresa definice okna
         call      DBFTDel                  ; zru®en° segmentu AX p©i chybà
         stc

; ------ n†vrat registrñ

EdiBZIn9:mov       sp,bp
         pop       bp
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      far ptr InfoClos         ; uzav©en° informaán°ho ©†dku
         call      DBFAdrES                 ; aktualizace adresy okna -> ES
         ret

EdiBZIns ENDP

; ------ zkop°rov†n° á†sti dat (CY=chyba)

EdiBZIC: call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jc        EdiBZIC9                 ; je p©eru®en° operace

         mov       es,ss:[bp-4]             ; adresa starÇho okna
         mov       cx,es:[DBFMaxD]          ; max. z†znamñ v bufferu
         cmp       word ptr ss:[bp-16+2],0  ; zbòv† dost z†znamñ ?
         jne       EdiBZIC2                 ; zbòv† dost z†znamñ
         cmp       cx,ss:[bp-16]            ; zbòv† dost z†znamñ ?
         jbe       EdiBZIC2                 ; zbòv† dost z†znamñ
         mov       cx,ss:[bp-16]            ; omezen° poátu z†znamñ

EdiBZIC2:cmp       word ptr ss:[bp-20+2],0  ; je dost z†znamñ k poá†tku ?
         jne       EdiBZIC4                 ; zbòv† dost z†znamñ
         cmp       cx,ss:[bp-20]            ; zbòv† dost z†znamñ ?
         jbe       EdiBZIC4                 ; zbòv† dost z†znamñ
         mov       cx,ss:[bp-20]            ; omezen° poátu z†znamñ

EdiBZIC4:clc                                ; p©°znak operace OK
         jcxz      EdiBZIC9                 ; nejsou dal®° data

         sub       ss:[bp-16],cx            ; á°taá z†znamñ ke zkop°rov†n°
         sbb       word ptr ss:[bp-16+2],0
         sub       ss:[bp-20],cx            ; á°taá z†znamñ p©ed poá†tkem
         sbb       word ptr ss:[bp-20+2],0

         mov       ax,es:[DBFBytZ]          ; poáet bajtñ na z†znam
         mul       cx                       ; p©epoáet z†znamñ na bajty
         push      cx                       ; £schova poátu z†znamñ
         xchg      ax,cx                    ; CX <- poáet bajtñ k naáten°
         mov       ax,ss:[bp-10]            ; identifik†tor starÇho souboru
         mov       di,es:[DBFAdrD]          ; adresa datovÇho bufferu
         call      far ptr Read0Fil         ; naáten° dat ze souboru
         pop       cx                       ; CX <- poáet z†znamñ
         jc        EdiBZIC9                 ; chyba

         call      EdiBZIW                  ; z†pis CX z†znamñ na vòstup
         jnc       EdiBZIC                  ; dal®° blok dat

EdiBZIC9:ret

; ------ z†pis CX z†znamñ

EdiBZIW: mov       es,ss:[bp-4]             ; adresa starÇho okna
         mov       ax,es:[DBFBytZ]          ; poáet bajtñ na z†znam
         mul       cx                       ; poáet bajtñ k z†pisu

         push      cx
         push      si

         xchg      ax,cx                    ; CX <- poáet bajtñ k z†pisu
         mov       ax,ss:[bp-12]            ; identifik†tor novÇho souboru
         mov       si,es:[DBFAdrD]          ; adresa datovÇho bufferu
         call      far ptr WritFile         ; z†pis dat

         pop       si
         pop       cx
         jc        EdiBZIW8                 ; byla chyba operace

         call      far ptr InfoKurz         ; zobrazen° ukazatele

         mov       es,ss:[bp-8]             ; adresa novÇho okna
         add       es:[DBFMaxZ],cx          ; á°taá uloëenòch z†znamñ
         adc       word ptr es:[DBFMaxZ+2],0
         clc                                ; p©°znak operace OK

EdiBZIW8:ret

; -----------------------------------------------------------------------------
;        F8 zru®en° z†znamñ
; -----------------------------------------------------------------------------
;˛
; ------ test, zda je operace povolena

EditBRus:test      byte ptr ds:[DBFEParm],bit0 ; je editace ?
         jnz       EditBRs9                 ; je editace
         test      byte ptr es:[DBFParm],bit1 ; je z†kaz z†pisu ?
         jnz       EditBRs9                 ; je z†kaz z†pisu
         cmp       word ptr es:[DBFNumP],0  ; jsou nàjakÇ poloëky ?
         je        EditBRs9                 ; nejsou poloëky

; ------ potvrzen° operace ru®en° poloëek

         call      far ptr FlushChr         ; vypr†zdnàn° bufferu kl†vesnice
         mov       di,offset DBPMLin
         call      EditBLM                  ; obsluha ©†dkovÇho menu
         jc        EditBRs9

; ------ druhÇ potvrzen° operace ru®en° poloëek

         call      far ptr FlushChr         ; vypr†zdnàn° bufferu kl†vesnice
         mov       di,offset DBP2Lin
         call      EditBLM                  ; obsluha ©†dkovÇho menu
         jc        EditBRs9

; ------ ru®en° oznaáenòch z†znamñ

         mov       word ptr ds:[DBZobOld+2],-1 ; pot©eba naáten° MEMO

         call      ClosBMem                 ; uzav©en° souboru MEMO
         call      EdiBODel                 ; zru®en° oznaáenòch z†znamñ
EditBRs9:ret

; -----------------------------------------------------------------------------
;                                EdiBODel
;                        zru®en° oznaáenòch z†znamñ
; -----------------------------------------------------------------------------
; VSTUP: SI=definice okna
;        DS=datovò segment
; VùSTUP: CY=chyba
;         ES=obnoven† adresa okna
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) adresa definice okna (SI)
;                   SS:[BP-4] (2) adresa starÇho okna
;                   SS:[BP-6] (2) segment novÇho okna
;                   SS:[BP-8] (2) adresa novÇho okna
;                   SS:[BP-10] (2) identifik†tor starÇho souboru
;                   SS:[BP-12] (2) identifik†tor novÇho souboru
;                   SS:[BP-14] (2) ukazatel dat v bufferu k z†pisu
;                   SS:[BP-16] (2) ukazatel dat v bufferu
;                   SS:[BP-18] (2) ukazatel konce dat v bufferu
;                   SS:[BP-20] (2)
;                   SS:[BP-24] (4) poáet z†znamñ ke áten°
; -----------------------------------------------------------------------------

EdiBODel PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         mov       bp,sp

; ------ p©°prava lok†ln°ch promànnòch

         sub       sp,24
         mov       ss:[bp-2],si             ; adresa definice okna
         and       byte ptr ds:[DBFEPar2],not bit5 ; nebyl zru®enò z†znam

; ------ zobrazen° hl†®en°

         push      si
         mov       word ptr ds:[InfoKCit],0 ; á°taá ukazatele kurzoru
         mov       word ptr ds:[InfoKCit+2],0
         mov       si,offset DBFDelHl       ; hl†®en° o ru®en°
         call      far ptr InfDisp0         ; zobrazen° hl†®en°
         pop       si

; ------ vytvo©en° vòstupn°ho souboru

         call      DBFTOpen                 ; vytvo©en° p©echodnÇho souboru
         jnc       EdiBODl2                 ; soubor vytvo©en OK
EdiBODl1:jmp       EdiBODl9                 ; chyba

EdiBODl2:mov       ss:[bp-6],ax             ; segment novÇho okna

; ------ maximalizace starÇho okna

         call      far ptr MaxiDBF          ; maximalizace starÇho okna

; ------ adresa starÇho okna

         call      DBFAdrES                 ; aktualizace adresy okna -> ES
         mov       ss:[bp-4],es             ; adresa starÇho okna

; ------ adresa novÇho okna

         push      es                       ; adresa starÇho okna

         call      far ptr GetDat           ; adresa novÇho okna -> ES
         mov       ss:[bp-8],es             ; adresa novÇho okna

; ------ identifik†tor novÇho souboru

         mov       ax,es:[DBFIdent]         ; identifik†tor novÇho souboru
         mov       ss:[bp-12],ax            ; identifik†tor novÇho souboru

; ------ z†pis z†hlav° do novÇho souboru (ukazatel resetov†n, chyba se ignoruje)

         mov       si,DBFHlava              ; z†hlav° souboru
         mov       cx,es:[DBFBytH]          ; dÇlka z†hlav° souboru
         call      far ptr WritFile         ; z†pis z†hlav° do souboru

         pop       es                       ; ES <- adresa starÇho okna

; ------ identifik†tor starÇho souboru

         mov       ax,es:[DBFIdent]         ; identifik†tor starÇho souboru
         mov       ss:[bp-10],ax            ; identifik†tor starÇho souboru

; ------ nastaven° ukazatele ve starÇm souboru za z†hlav° souboru

         xor       dx,dx                    ; DX <- 0 offset HIGH
         mov       cx,es:[DBFBytH]          ; dÇlka z†hlav° (bajtñ)
         call      far ptr SetUFile         ; nastaven° ukazatele v souboru

; ------ poáet z†znamñ ve starÇm souboru, inicializace ukazatele operace

         mov       ax,es:[DBFMaxZ]          ; poáet z†znamñ v souboru
         mov       word ptr ds:[InfoKMax],ax
         mov       ss:[bp-24],ax            ; poáet z†znamñ ke áten°
         mov       ax,es:[DBFMaxZ+2]
         mov       word ptr ds:[InfoKMax+2],ax
         mov       ss:[bp-24+2],ax
         xor       cx,cx                    ; CX <- 0
         call      far ptr InfoKurz         ; zobrazen° kurzoru operace

; ------ poáet z†znamñ pro dal®° operaci áten° -> CX

EdiBODl3:mov       es,ss:[bp-4]             ; ES <- adresa starÇho okna
         mov       ax,es:[DBFMaxD]          ; max. z†znamñ v bufferu
         cmp       word ptr ss:[bp-24+2],0  ; je je®tà dost z†znamñ ?
         jne       EdiBODl4                 ; je je®tà dost z†znamñ
         cmp       ax,ss:[bp-24]            ; zbòv† dost z†znamñ ?
         jbe       EdiBODl4                 ; zbòv† dost z†znamñ
         mov       ax,ss:[bp-24]            ; omezen° poátu z†znamñ
EdiBODl4:sub       ss:[bp-24],ax            ; sn°ëen° zbylòch z†znamñ
         sbb       word ptr ss:[bp-24+2],0
         mul       word ptr es:[DBFBytZ]    ; p©epoáet na bajty
         xchg      ax,cx                    ; CX <- poáet bajtñ ke áten°
         jcxz      EdiBODl7                 ; konec souboru

; ------ p©°prava ukazatelñ pro dal®° blok dat

         mov       di,es:[DBFAdrD]          ; adresa datovÇho bufferu
         mov       ss:[bp-18],di            ; adresa konce dat v bufferu
         mov       ss:[bp-16],di            ; ukazatel dat v bufferu
         mov       ss:[bp-14],di            ; ukazatel dat v bufferu k z†pisu

; ------ test, zda je p©eru®en° operace

         call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jc        EdiBOD82                 ; je p©eru®en° operace

; ------ naáten° z†znamñ ze souboru

         mov       ax,ss:[bp-10]            ; identifik†tor starÇho souboru
         call      far ptr Read0Fil         ; naáten° dat ze souboru
         jc        EdiBODl8                 ; chyba áten° dat
         add       ss:[bp-18],cx            ; posun adresy konce dat v bufferu

; ------ test, zda je dal®° z†znam v bufferu

EdiBODl5:mov       si,ss:[bp-16]            ; ukazatel dat v bufferu
         cmp       si,ss:[bp-18]            ; je dal®° z†znam v bufferu ?
         jb        EdiBODl6                 ; je dal®° z†znam v bufferu
         call      EdiBODW                  ; z†pis bufferu na disk
         jc        EdiBODl8                 ; chyba z†pisu
         jmp       short EdiBODl3           ; dal®° blok dat

; ------ test, zda je z†znam oznaáen ke zru®en°

EdiBODl6:cmp       byte ptr es:[si],"*"     ; je z†znam oznaáen ke zru®en° ?
         jne       EdiBOD62                 ; z†znam nen° oznaáen ke zru®en°

; ------ vypr†zdnàn° dat p©ed ru®enòm z†znamem

         call      EdiBODW                  ; z†pis bufferu na disk
         jc        EdiBODl8                 ; chyba z†pisu

; ------ p©eskoáen° zru®enÇho z†znamu

         mov       ax,es:[DBFBytZ]          ; poáet bajtñ na z†znam
         add       ss:[bp-14],ax            ; zvò®en° z†pisovÇ adresy
         add       ss:[bp-16],ax            ; zvò®en° ukazatele dat
         or        byte ptr ds:[DBFEPar2],bit5 ; byl zru®en z†znam
         jmp       short EdiBODl5           ; dal®° z†znam

; ------ zvò®en° ukazatelñ, je-li z†znam platnò

EdiBOD62:mov       ax,es:[DBFBytZ]          ; poáet bajtñ na z†znam
         add       ss:[bp-16],ax            ; zvò®en° ukazatele dat
         jmp       short EdiBODl5           ; dal®° z†znam

; ------ konec konverze souboru

EdiBODl7:test      byte ptr ds:[DBFEPar2],bit5 ; byl zru®enò z†znam ?
         jz        EdiBOD82                 ; nebyl zru®enò z†znam

         mov       es,ss:[bp-8]             ; adresa novÇho okna
         call      UlozDEOF                 ; z†pis koncovÇho znaku EOF

         mov       ax,ss:[bp-6]             ; segment novÇho okna
         mov       si,ss:[bp-2]             ; adresa definice okna
         call      DBFTClos                 ; uzav©en° vòstupn°ho souboru
         jnc       EdiBODl9                 ; operace OK

; ------ chyba z†pisu do vòstupn°ho souboru

EdiBODl8:mov       di,offset DBHMWrt        ; hl†®en° - chyba z†pisu
         call      far ptr Lin0MenP         ; chybovÇ hl†®en°

; ------ zru®en° vòstupn°ho souboru, zru®en° bufferu

EdiBOD82:mov       ax,ss:[bp-6]             ; segment novÇho okna
         mov       si,ss:[bp-2]             ; adresa definice okna
         call      DBFTDel                  ; zru®en° segmentu AX p©i chybà
         stc

; ------ n†vrat registrñ

EdiBODl9:mov       sp,bp
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      far ptr InfoClos         ; uzav©en° informaán°ho ©†dku
         call      DBFAdrES                 ; aktualizace adresy okna -> ES
         ret

EdiBODel ENDP

; ------ z†pis bufferu na disk (CY=chyba)

EdiBODW: mov       si,ss:[bp-14]            ; adresa dat k z†pisu
         mov       cx,ss:[bp-16]            ; ukazatel dat v bufferu
         mov       ss:[bp-14],cx            ; posun adresy dat k z†pisu
         sub       cx,si                    ; poáet bajtñ k z†pisu
         jz        EdiBODW2                 ; nen° nic k z†pisu (-> NC)

         mov       ax,ss:[bp-12]            ; identifik†tor novÇho souboru
         call      far ptr WritFile         ; z†pis dat do souboru
         jc        EdiBODW2                 ; chyba z†pisu

         xor       dx,dx                    ; DX <- 0
         xchg      ax,cx                    ; AX <- poáet zapsanòch bajtñ
         div       word ptr es:[DBFBytZ]    ; AX <- poáet uloëenòch z†znamñ

         push      es
         mov       es,ss:[bp-8]             ; adresa novÇho okna
         add       word ptr es:[DBFMaxZ],ax  ; zvò®en° poátu z†znamñ
         adc       word ptr es:[DBFMaxZ+2],0
         pop       es

         xchg      ax,cx                    ; CX <- poáet uloëenòch z†znamñ
         call      far ptr InfoKurz         ; zobrazen° kurzoru
         clc                                ; p©°znak operace OK

EdiBODW2:ret

; -----------------------------------------------------------------------------
;        vytvo©en° p©echodnÇho vòstupn°ho souboru DBF
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa menu
; VùSTUP: AX=á°slo bloku s novòm otev©enòm souborem DBF (p©i CY je AX=0)
;         CY=chyba (hl†s° chybu), AX=0
;         ES=obnoven† adresa starÇho okna
;         poloëka DBFSoubN (dÇlka jmÇna souboru) zñst†v† nezmànàna !
; -----------------------------------------------------------------------------

DBFTOpen PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      dx
         push      di
         push      bp

; ------ minimalizace starÇ datab†ze

         call      far ptr MiniDBF          ; minimalizace datab†ze

; ------ pot©ebn† velikost pro novou datab†zi -> BX, CX

         call      DBFAdrES                 ; aktualizace adresy okna -> ES
         mov       bx,es:[DBFByts]          ; velikost segmentu
         mov       cx,bx                    ; CX <- velikost segmentu

; ------ aktualizace adres†©e

         push      si
         mov       si,DBFSoub               ; soubor DBF
         call      far ptr ModiWDir         ; aktualizace adres†©e
         pop       si

; ------ vytvo©en° segmentu novÇ datab†ze

         call      far ptr CreatSeg         ; vytvo©en° segmentu datab†ze
         jc        DBFTOpn1                 ; chyba
         mov       bp,ax                    ; BP <- segment novÇ datab†ze
         call      far ptr ModiSegS         ; nastaven° velikosti segmentu
         jnc       DBFTOpn2                 ; je to OK
         call      far ptr DelSeg           ; zru®en° segmentu p©i chybà

; ------ chyba pamàti

DBFTOpn1:call      far ptr MemErr           ; chyba pamàti
         jmp       short DBFTOpn8

; ------ kopie definice datab†ze (CX=velikost v bajtech)

DBFTOpn2:push      si
         push      ds

         call      far ptr GetDat           ; adresa novÇho segmentu -> ES
         mov       ax,ds:[si+DBMnuSeg]      ; AX <- segment starÇ datab†ze
         call      far ptr GetSgAdr         ; adresa segmentu -> DX
         mov       ds,dx                    ; DS <- adresa starÇ datab†ze
         xor       si,si                    ; SI <- 0
         xor       di,di                    ; DI <- 0
         cld
         rep       movsb                    ; kopie definice datab†ze

         pop       ds
         pop       si

; ------ nulov†n° ukazatelñ

         xchg      ax,cx                    ; AX <- 0
         mov       es:[DBFMaxZ],ax          ; nejsou z†znamy
         mov       es:[DBFMaxZ+2],ax
         mov       es:[DBFIdent],ax         ; soubor DBF nen° otev©en
         mov       es:[DBFIdntT],ax         ; soubor DBT nen° otev©en

; ------ vytvo©en° p©echodnÇho souboru (dÇlka jmÇna souboru se neaktualizuje !)

         push      si
         mov       si,DBFSoub               ; jmÇno souboru DBF
         call      far ptr CreatPF          ; vytvo©en° p©echodnÇho souboru
         pop       si
         mov       es:[DBFIdent],ax         ; identifik†tor souboru
         jnc       DBFTOpn9                 ; soubor vytvo©en OK

; ------ hl†®en° - chyba z†pisu do souboru

         mov       di,offset DBHMWrt        ; chyba z†pisu
         call      far ptr Lin0MenP         ; chybovÇ hl†®en°

; ------ zru®en° novÇ datab†ze p©i chybà

         xchg      ax,bp                    ; AX <- segment novÇ datab†ze
         call      far ptr DelSeg           ; zru®en° segmentu

; ------ maximalizace pñvodn° datab†ze p©i chybà

DBFTOpn8:call      far ptr MaxiDBF          ; maximalizace bufferñ
         xor       bp,bp                    ; BP <- segment neplatnò
         stc                                ; p©°znak chyby

; ------ n†vrat registrñ

DBFTOpn9:xchg      ax,bp                    ; AX <- segment novÇ datab†ze
         pop       bp
         pop       di
         pop       dx
         pop       cx
         pop       bx
         call      DBFAdrES                 ; aktualizace adresy okna -> ES
         ret

DBFTOpen ENDP

; -----------------------------------------------------------------------------
;        zru®en° p©echodnÇho vòstupn°ho souboru DBF p©i chybà
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo bloku s p©echodnòm souborem (bude zru®en !) (mñëe bòt = 0)
;        DS:SI=definice starÇho okna
; -----------------------------------------------------------------------------

DBFTDel  PROC      NEAR

; ------ zapnut° kritickÇ sekce

         call      far ptr ZapKrit          ; zapnut° kritickÇ sekce

; ------ adresa bloku AX -> ES

         call      far ptr GetDat           ; adresa bloku -> ES
         jc        DBFTDel9                 ; neplatnò blok

; ------ uzav©en° souboru, nen°-li uzav©en

         call      DBFClosF                 ; uzav©en° souboru v oknà

; ------ zru®en° souboru

         call      DBFDelF                  ; zru®en° p©echodnÇho souboru

; ------ zru®en° segmentu okna

         call      far ptr DelSeg           ; zru®en° segmentu AX

; ------ vypnut° kritickÇ sekce

DBFTDel9:call      far ptr VypKrit          ; vypnut° kritickÇ sekce

; ------ aktualizace adresy okna DS:SI -> ES

         call      DBFAdrES                 ; aktualizace adresy okna -> ES
         ret

DBFTDel  ENDP

; -----------------------------------------------------------------------------
;        uzav©en° p©echodnÇho vòstupn°ho souboru
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo bloku s p©echodnòm souborem
;        DS:SI=definice starÇho okna
; VùSTUP: CY=chyba operace (nehl†s° chybu) (nic se nezmànilo)
; -----------------------------------------------------------------------------

DBFTClos PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      di

; ------ z†pis z†hlav° souboru

         xchg      ax,ds:[si+DBMnuSeg]      ; z†màna segmentu bufferu
         call      HlavDBF                  ; z†pis z†hlav° souboru
         jc        DBFTCls8                 ; chyba

; ------ adresa bufferu vòstupn°ho souboru -> ES

         call      DBFAdrES                 ; aktualizace adresy okna -> ES

; ------ uzav©en° vòstupn°ho souboru

         call      DBFClosF                 ; uzav©en° vòstupn°ho souboru

; ------ adresa bufferu starÇho souboru -> ES

         call      far ptr GetDat           ; adresa bufferu -> ES

; ------ uzav©en° vstupn°ho souboru

         call      DBFClosF                 ; uzav©en° vstupn°ho souboru

; ------ zru®en° starÇho (vstupn°ho) souboru

         call      DBFDelF                  ; zru®en° starÇho souboru
         jc        DBFTCls7                 ; chyba - nelze zru®it

; ------ p©ejmenov†n° novÇho souboru (chyba se ignoruje - nelze s n° nic dàlat)

         push      si
         push      ds

         mov       dx,es                    ; segment starÇho souboru
         call      DBFAdrES                 ; aktualizace adresy okna -> ES
         mov       si,DBFSoub               ; SI <- novÇ jmÇno (starò soubor)
         mov       di,si                    ; DI <- starÇ jmÇno (novò soubor)
         call      far ptr RenFile          ; p©ejmenov†n° souboru

; ------ kopie jmÇna souboru

         mov       ds,dx                    ; DS <- segment novÇho jmÇna
         mov       cx,FileMax               ; dÇlka jmÇna souboru
         cld
         rep       movsb                    ; p©enos jmÇna souboru

         pop       ds
         pop       si

; ------ novÇ otev©en° vòstupn°ho souboru

         push      ax
         push      si
         mov       si,DBFSoub               ; jmÇno souboru
         call      far ptr OpenRW           ; otev©en° souboru
         jc        DBFTCls4                 ; s chybou se ned† nic dàlat
         mov       es:[DBFIdent],ax         ; identifik†tor souboru
DBFTCls4:pop       si
         pop       ax

; ------ zru®en° starÇho segmentu

         call      far ptr DelSeg           ; zru®en° starÇho segmentu

; ------ korekce zobrazen° novÇ datab†ze

         call      ModiDKor                 ; korekce zobrazen° datab†ze

; ------ maximalizace bufferu datab†ze

         call      far ptr MaxiDBF          ; maximalizace bufferñ
         clc                                ; p©°znak operace OK
         jmp       short DBFTCls9

; ------ otev©en° starÇho souboru p©i chybà (ES=segment starÇho okna)

DBFTCls7:push      ax
         push      si

         mov       si,DBFSoub               ; jmÇno souboru
         call      far ptr OpenRW           ; otev©en° souboru
         jnc       DBFTCl72                 ; soubor otev©en OK
         call      far ptr OpenR            ; otev©en° pro áten°
         jc        DBFTCl74                 ; s chybou se ned† nic dàlat
         or        byte ptr es:[DBFParm],bit1 ; z†kaz z†pisu
DBFTCl72:mov       es:[DBFIdent],ax         ; identifik†tor souboru

DBFTCl74:pop       si
         pop       ax

; ------ n†vrat starÇho segmentu p©i chybà

DBFTCls8:xchg      ax,ds:[si+DBMnuSeg]      ; n†vrat segmentu bufferu p©i chybà
         stc

; ------ n†vrat registrñ

DBFTCls9:pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      DBFAdrES                 ; aktualizace adresy okna -> ES
         ret

DBFTClos ENDP

; -----------------------------------------------------------------------------
;        uzav©en° souboru v oknà ES
; -----------------------------------------------------------------------------

DBFClosF PROC      NEAR

         push      ax
         mov       ax,es:[DBFIdent]         ; identifik†tor souboru
         call      far ptr ClosFile         ; uzav©en° vòstupn°ho souboru
         mov       es:[DBFIdent],ax         ; p©°znak uzav©en° souboru
         pop       ax
         ret

DBFClosF ENDP

; -----------------------------------------------------------------------------
;        zru®en° souboru v oknà ES
; -----------------------------------------------------------------------------

DBFDelF  PROC      NEAR

         push      si
         mov       si,DBFSoub               ; jmÇno souboru DBF
         call      far ptr DelFile          ; zru®en° starÇho souboru
         pop       si
         ret

DBFDelF  ENDP

CodeDbf  ENDS

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;
;                                 Data
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
Data     SEGMENT

; ------ data k vyhled†n° v seznamu

DBHMSLin label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        5                        ; poáet platnòch poloëek menu
         dw        7                        ; celkovò poáet poloëek menu

         dw        DBHMLPol                 ; zaá†tek definice poloëek menu
         dw        DBHMLHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@VyhledavaniTextuVDatabazi ; á°slo str†nky velkÇ n†povàdy
         dw        DBHMLBlk                 ; adresa blokovac° tabulky
         dw        DBHMLSwc                 ; adresa tabulky p©ep°naáñ
         dw        DBHMLTit                 ; adresa titulu okna
         dw        DBHMLExe                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        20                       ; poá†teán° pozice okna
         db        0                        ; poá†teán° ©†dek okna
         db        57                       ; ®°©ka okna
         db        8                        ; vò®ka okna

         dw        TextFndX                 ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        1                        ; celkovò poáet ©†dkñ
         dw        1                        ; poáet zobrazenòch ©†dkñ

         db        bit2                     ; maska zad†vanòch znakñ - v®echny
         db        1,26,'     '             ; zak†zanÇ znaky

         db        HistFind                 ; historie hled†n°
         db        0                        ; poáet p©edvoleb

DBHMLPol db        bit6,27,'Text k vyhled†n° v seznamu:'
         db        0,0
         db        bit6+bit7,0
         db        1,6,'Hledej'
         db        1+bit7,9,'Oznaáit '
DBHMLPl1 db        '-'
         db        1+bit7,9,'Nulovat '
DBHMLPl2 db        '-'
         db        1,8,'P©eru®it'

DBHMLBlk db        0,0,0,0,0                ; blokovac° tabulka
DBHMLSwc db        0,0                      ; p©ep°naáe

DBHMLTit db        6,'hledej'

DBHMLTxt db        18,'Vyhled†v†m text...'

HelpS    SEGMENT   BYTE PUBLIC
DBHMLHlp db        65,'Zadejte textovò ©etàzec k vyhled†n° (od kurzoru ke konci seznamu)'
         db        24,'Vyhled†n° zadanÇho textu'
         db        39,'V®echny nalezenÇ z†znamy budou oznaáeny'
         db        47,'Bude nulov†no oznaáen° v®ech nalezenòch z†znamñ'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

DBHMLExe label     dword
         dd        Lin0MenR                 ; ©†dky
         dd        Lin0MenR                 ; Hledej
         dd        EditBHS1                 ; Oznaáit
         dd        EditBHS2                 ; Nulovat
         dd        Lin0MenR                 ; P©eru®it

; ------ chyba - nenalezen ë†dnò text

DBHMFnd  label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        DBHMFndP                 ; zaá†tek definice poloëek menu
         dw        ChbLnMeH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@VyhledavaniTextuVDatabazi ; á°slo str†nky velkÇ n†povàdy
         dw        DBHMFndB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        DBHMFndT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        49                       ; ®°©ka okna
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

DBHMFndP db        bit6,0
         db        bit6,34,'Zadanò textovò ©etàzec nenalezen !'
         db        bit6,0
         db        bit6+bit7,0
         db        1,6,'N†vrat'

DBHMFndB db        0                        ; blokovac° tabulka

DBHMFndT db        14,'text nenalezen'

; ------ poáet nalezenòch z†znamñ

DBH1MFnd label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet platnòch poloëek menu
         dw        6                        ; celkovò poáet poloëek menu

         dw        DBH1MFnP                 ; zaá†tek definice poloëek menu
         dw        ChbLnMeH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@VyhledavaniTextuVDatabazi ; á°slo str†nky velkÇ n†povàdy
         dw        DBH1MFnB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        DBH1MFnT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        49                       ; ®°©ka okna
         db        10                       ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; historie
         db        0                        ; poáet p©edvoleb

DBH1MFnP db        bit6,0
         db        bit6,30,'Zadanò textovò ©etàzec nalezen'
         db        bit6,18,'v ',0,1
         dw        DBH1MFBN                 ; buffer s á°slem
         db        0,' z†znamech.'
         db        bit6,0
         db        bit6+bit7,0
         db        1,6,'N†vrat'

DBH1MFnB db        0                        ; blokovac° tabulka

DBH1MFBN db        0,10 dup(0)              ; buffer k dek¢dov†n° á°sla

DBH1MFnT db        12,'text nalezen'

; -----------------------------------------------------------------------------
;        menu ru®en° z†znamñ v souboru
; -----------------------------------------------------------------------------

DBPMLin  label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        2                        ; poáet platnòch poloëek menu
         dw        7                        ; celkovò poáet poloëek menu

         dw        DBPMLPol                 ; adresa definice poloëek
         dw        DBPMLHlp                 ; adresa n†povàd
         dw        Hlp@DatabazoveMenu       ; á°slo str†nky velkÇ n†povàdy
         dw        DBPMLBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        DBPMLTit                 ; adresa titulu okna
         dw        LinMenTE                 ; adresa obsluh voleb
         dw        LinMenTM                 ; adresy podmenu
         dd        0                        ; n†vratov† adresa

         db        19                       ; poá†teán° pozice
         db        7                        ; poá†teán° ©†dek
         db        50                       ; ®°©ka
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

DBPMLPol db        bit6,0
         db        bit6,34,'V®echny oznaáenÇ z†znamy v souboru'
         db        bit6,18,'budou odstranàny !'
         db        bit6,0
         db        bit6+bit7,0
         db        1,10,'Pokraáovat'
         db        1,6,'N†vrat'

DBPMLBlk db        0,0
DBPMLTit db        6,'ru®en°'

HelpS    SEGMENT   BYTE PUBLIC
DBPMLHlp db        37,'Zru®en° oznaáenòch z†znamñ ze souboru'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

; ------ druhÇ potvrzen° ru®en°

DBP2Lin  label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        2                        ; poáet platnòch poloëek menu
         dw        8                        ; celkovò poáet poloëek menu

         dw        DBP2LPol                 ; adresa definice poloëek
         dw        DBP2LHlp                 ; adresa n†povàd
         dw        Hlp@DatabazoveMenu       ; á°slo str†nky velkÇ n†povàdy
         dw        DBP2LBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        DBPMLTit                 ; adresa titulu okna
         dw        LinMenTE                 ; adresa obsluh voleb
         dw        LinMenTM                 ; adresy podmenu
         dd        0                        ; n†vratov† adresa

         db        19                       ; poá†teán° pozice
         db        7                        ; poá†teán° ©†dek
         db        44                       ; ®°©ka
         db        11                       ; vò®ka

         dw        0                        ; maxim†ln° dÇlka ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        0                        ; maska znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; identifik†tor historie
         db        0                        ; poáet p©edvoleb

DBP2LPol db        bit6,0
         db        bit6,10,0,'VAROVèNã:'
         db        bit6,23,'Zru®°m v®echny oznaáenÇ'
         db        bit6,19,'z†znamy v souboru !'
         db        bit6,0
         db        bit6+bit7,0
         db        1,5,'Ru®it'
         db        1,6,'N†vrat'

DBP2LBlk db        0,0

HelpS    SEGMENT   BYTE PUBLIC
DBP2LHlp db        42,'Zah†jen° operace ru®en° oznaáenòch z†znamñ'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

DBFDelHl db        25,'Ru®°m oznaáenÇ z†znamy...'

; ------ vloëen° z†znamñ
;˛
DBVMSLin label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        DBVMLPol                 ; zaá†tek definice poloëek menu
         dw        DBVMLHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@DatabazoveMenu       ; á°slo str†nky velkÇ n†povàdy
         dw        DBVMLBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        DBVMLTit                 ; adresa titulu okna
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
         db        6,'. +-:,'               ; zak†zanÇ znaky

         db        HistCis                  ; historie á°sel
         db        1                        ; poáet p©edvoleb

         dw        1
         dd        DBVMLPr1                 ; p©edvolba "1"

DBVMLPr1 db        '1'

DBVMLPol db        bit6,24,'Poáet z†znamñ k vloëen°:'
         db        0,0
         db        bit6+bit7,0
         db        1,6,'Vloëit'
         db        1,6,'N†vrat'

DBVMLBlk db        0,0,0                    ; blokovac° tabulka

DBVMLTit db        8,'vkl†d†n°'

HelpS    SEGMENT   BYTE PUBLIC
DBVMLHlp db        56,'Zadejte poáet novòch z†znamñ k vloëen° na pozici kurzoru'
         db        44,'Vloëen° poëadovanÇho mnoëstv° novòch z†znamñ'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

DBFInsHl db        23,'Vkl†d†m novÇ z†znamy...'

; ------ chyba z†pisu do vòstupn°ho souboru (pouëito tÇë p©i exportu dat z TABULKY)

DBHMWrt  label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        DBHMWrtP                 ; zaá†tek definice poloëek menu
         dw        ChbLnMeH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@PodmenuZvlastni      ; á°slo str†nky velkÇ n†povàdy
         dw        DBHMWrtB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        DBHMWrtT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        49                       ; ®°©ka okna
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

DBHMWrtP db        bit6,6,0,'CHYBA'
         db        bit6,36,'Chyba z†pisu do vòstupn°ho souboru !'
         db        bit6,0
         db        bit6+bit7,0
         db        1,6,'N†vrat'

DBHMWrtB db        0                        ; blokovac° tabulka

DBHMWrtT db        12,'chyba z†pisu'

; ------ data

DBFETime dw        0                        ; uschovanò áas souboru
DBFEDate dw        0                        ; uschovanÇ datum souboru

DBFEPar2 db        0                        ; parametry 2
                                            ;   bit 0: 1=je nastaven° ®°©ky pole
                                            ;   bit 1: 1=oznaáen° p©i hled†n°
                                            ;   bit 2: 1=nulov†n° oznaáen° hled†n°

                                            ;   bit 5: 1=byl z†pis z†znamu

DBCitFnd dd        0                        ; á°taá nalezenòch z†znamñ

Data     ENDS
         END


; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                             E D I T O R - 1
;
;             textovò a bin†rn° editor - obsluha zobrazen°
;
; =============================================================================
;
; Ve©ejnÇ procedury:
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

INCLUDE  ASM\DEF.ASM

CodeEdi  SEGMENT   BYTE PUBLIC
         ASSUME    cs:CodeEdi,ds:Data

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                                 Obsluha menu
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

EditF10X:or        byte ptr ds:[ParMenu],bit4 ; p©°znak autom. vno©en° do menu

EditF10:
         mov       si,offset EMnuMain       ; hlavn° adres†©ovÇ menu
         call      far ptr MainMenu         ; obsluha volby hlavn°ho menu

         ret

; -----------------------------------------------------------------------------
;        p©°prava volby menu
; -----------------------------------------------------------------------------

EditSMnX PROC      NEAR

         pop       dx                       ; n†vratov† adresa z procedury
         pop       ax
         pop       ax                       ; zru®en° n†vratovÇ adresy do menu
         mov       ax,offset EditSMX4
         push      ax                       ; n†vratov† adresa z volby
         push      dx                       ; n†vratov† adresa z procedury
         call      far ptr ClosMnuA         ; uzav©en° oken menu

EditSMnY:mov       dx,ds:[EdiSAkt]           ; aktu†ln° okno
         call      EditGetD                 ; poskytnut° adresy okna
         mov       di,EdiW1                 ; definice pro okno 1
         or        dh,dh                    ; je aktivn° okno 2 ?
         jns       EditSMX3                 ; je aktivn° okno 1
         mov       di,EdiW2                 ; definice pro okno 2
EditSMX3:ret

EditSMnX ENDP

EditSMX4:jmp       far ptr Main0

; -----------------------------------------------------------------------------
;        menu Soubory
; -----------------------------------------------------------------------------
;˛
EditSMn: jmp       far ptr VertMenu

; -----------------------------------------------------------------------------
;        otev©en° souboru
; -----------------------------------------------------------------------------

EditSMnO:call      EditSMnX                 ; p©°prava parametrñ
         jmp       EditNew                  ; otev©en° souboru

; -----------------------------------------------------------------------------
;        uloëen° souboru
; -----------------------------------------------------------------------------

EditSMU: call      EditSMnX                 ; p©°prava parametrñ
         jmp       EditUloz                 ; uloëen° souboru

; -----------------------------------------------------------------------------
;        uloëen° jako
; -----------------------------------------------------------------------------

EditSMnJ:call      EditSMnX                 ; p©°prava parametrñ
         jmp       EditZap                  ; z†pis souboru

; -----------------------------------------------------------------------------
;        n†vrat
; -----------------------------------------------------------------------------

EditSMnN:call      EditSMnX                 ; p©°prava parametrñ

         test      byte ptr es:[EdiParm],bit0 ; byl soubor modifikov†n ?
         jz        EditSMN2                 ; soubor nebyl modifikov†n

; ------ potvrzen° operace

         call      far ptr FlushChr         ; vypr†zdnàn° bufferu kl†vesnice
         mov       si,offset ENEMnLin       ; menu dotazu
         call      Edi0Menu                 ; potvrzen° operace
         jnc       EditSMn2
         ret

; ------ nastaven° pñvodn° origin†ln° velikosti souboru

EditSMN2:mov       ax,word ptr es:[EdiOSize] ; velikost souboru LOW
         mov       word ptr es:[EdiSize],ax ; to je pñvodn° velikost souboru
         mov       ax,word ptr es:[EdiOSize+2]
         mov       word ptr es:[EdiSize+2],ax
         jmp       EditUIni                 ; n†vrat k pñvodn°mu obsahu souboru

; -----------------------------------------------------------------------------
;        Zav©en°
; -----------------------------------------------------------------------------

EditSMnZ:call      EditSMnX                 ; p©°prava parametrñ
EditSF6: mov       ax,ds:[EdiWAkt]          ; á°slo aktivn°ho okna
         jmp       EditClos                 ; uzav©en° souboru

; -----------------------------------------------------------------------------
;        P©edchoz°
; -----------------------------------------------------------------------------

EditSMnP:call      EditSMnX                 ; p©°prava parametrñ
         jmp       EditAF2                  ; p©edchoz° soubor

; -----------------------------------------------------------------------------
;        Dal®°
; -----------------------------------------------------------------------------

EditSMnD:call      EditSMnX                 ; p©°prava parametrñ
         jmp       EditAF3                  ; dal®° soubor

;; -----------------------------------------------------------------------------
;;        Seznam
;; -----------------------------------------------------------------------------
;
;EditSMnS:call      EditSMnX                 ; p©°prava parametrñ
;         ret
;
;; -----------------------------------------------------------------------------
;;        Tisk
;; -----------------------------------------------------------------------------
;
;EditSMnT:call      EditSMnX                 ; p©°prava parametrñ
;         ret
;
; -----------------------------------------------------------------------------
;        V®e p©eru®it
; -----------------------------------------------------------------------------

EditSMnV:call      EditSMnX                 ; p©°prava parametrñ
EdiSMnV2:jmp       EditEdi9                 ; p©eru®en° editace

; -----------------------------------------------------------------------------
;        Konec s uloëen°m
; -----------------------------------------------------------------------------

EditSMnK:call      EditSMnX                 ; p©°prava parametrñ

EditCKD:
         mov       cx,ds:[NumEdi]           ; poáet souborñ
         jcxz      EdiSMnV2
         xor       bx,bx
EdiSMnK2:inc       bx
         inc       bx                       ; ukazatel dat
         mov       ax,ds:[SegmTEdi]         ; segment seznamu
         call      far ptr GetDat           ; adresa segmentu
         jc        EdiSMnV2

         mov       dx,es:[bx]               ; segment okna
         call      EditGetD                 ; poskytnut° adresy okna
         jc        EdiSMnK4
         test      byte ptr es:[EdiParm],bit0 ; byl soubor modifikov†n ?
         jz        EdiSMnK4                 ; nebyl modifikov†n
         call      EditUloz                 ; uloëen° souboru
         jc        EdiSMnK8                 ; p©eru®en° operace
EdiSMnK4:loop      EdiSMnK2
         jmp       short EdiSMnV2           ; p©eru®en° editace

EdiSMnK8:ret

; -----------------------------------------------------------------------------
;        menu Blok
; -----------------------------------------------------------------------------
;˛
EditBMn: call      EditBMS                  ; p©°prava p©ep°naáñ pro menu
         jmp       far ptr VertMenu

; ------ p©°prava p©ep°naáñ pro menu

EditBMS  PROC      NEAR

         push      ax
         push      dx
         push      si
         push      di
         push      es

         call      EditSMnY                 ; p©°prava parametrñ okna

; ====== p©ep°naáe menu BLOK

         mov       dx,bit0                  ; textovò blok
         test      byte ptr es:[EdiParm],bit6+bit7
         jz        EditBMS1                 ; textovò blok
         mov       dl,bit1                  ; line†rn° blok
         test      byte ptr es:[EdiParm],bit7 ; ©†dkovò blok
         jnz       EditBMS1                 ; je ©†dkovò blok
         mov       dl,bit2                  ; jinak sloupcovò blok

EditBMS1:or        word ptr ds:[EBMnVBlk+6],bit1 + bit1*HI ; p©esun a kopie
         or        word ptr ds:[EBMnVBlk+8],bit1 + bit1*HI ; ru®en° a do bufferu
         or        byte ptr ds:[EBMnVBlk+11],bit1 ; uloëen°
         or        byte ptr ds:[EBMnVBlk+13],bit1 ; modifikace

         test      byte ptr es:[di+EdiParm2],bit5 ; je blok zobrazen ?
         jz        EditBMS2                 ; blok nen° zobrazen
         or        dl,bit3                  ; p©°znak zobrazen° bloku

         and       word ptr ds:[EBMnVBlk+6],not bit1 + bit1*HI ; p©esun a kopie
         and       word ptr ds:[EBMnVBlk+8],not bit1 + bit1*HI ; ru®en° a do bufferu
         and       byte ptr ds:[EBMnVBlk+11],not bit1 ; uloëen°
         and       byte ptr ds:[EBMnVBlk+13],not bit1 ; modifikace

EditBMS2:mov       si,offset EBMnVert
         call      far ptr SetSwch          ; nastaven° p©ep°naáñ

; ====== p©ep°naáe menu VOLBY

; ------ aktivn° okno 2

         xor       dx,dx                    ; DX <- p©°prava p©ep°naáñ
         test      byte ptr ds:[EditPar2],bit6 ; je aktivn° okno 2 ?
         jz        EditBMS3                 ; je aktivn° okno 1
         or        dl,bit0                  ; aktivn° okno 2

; ------ plnÇ okno

EditBMS3:test      byte ptr ds:[EditPar2],bit4 ; jsou 2 okna ?
         jnz       EditBMS4                 ; jsou 2 okna
         or        dl,bit1                  ; p©°znak plnÇho okna

; ------ vertik†ln° okna

EditBMS4:test      byte ptr ds:[EditPar2],bit5 ; jsou vertik†ln° okna ?
         jz        EditBMS5                 ; jsou horizont†ln° okna
         or        dl,bit2                  ; p©°znak vertik†ln°ho okna

; ------ synchronizace oken

EditBMS5:test      byte ptr ds:[EditParm],bit6 ; je synchronizace oken ?
         jz        EditBMS6                 ; nen° synchronizace oken
         or        dl,bit3                  ; p©°znak synchronizace oken

; ------ bin†rn° m¢d

EditBMS6:test      byte ptr es:[di+EdiParm1],bit2 ; je bin†rn° m¢d ?
         jz        EditBMS7                 ; nen° bin†rn° m¢d
         or        dl,bit4                  ; p©°znak bin†rn°ho m¢du

; ------ HEX m¢d

EditBMS7:test      byte ptr es:[di+EdiParm1],bit1 ; je HEX m¢d ?
         jz        EditBMS8                 ; nen° HEX m¢d
         or        dl,bit5                  ; p©°znak HEX m¢du

; ------ Editace textu

EditBMS8:test      byte ptr es:[di+EdiParm1],bit0 ; je editace ?
         jnz       EditBMS9                 ; nen° editace
         or        dl,bit6                  ; p©°znak editace

; ------ line†l

EditBMS9:
;test      byte ptr es:[di+EdiParm1],bit3 ; je line†l ?
;         jz        EditBMSA                 ; nen° line†l
;         or        dl,bit7                  ; p©°znak line†lu

; ------ o©ez†n° mezer

EditBMSA:test      byte ptr es:[di+EdiParm1],bit5 ; je o©ez†v†n° mezer ?
         jnz       EditBMSB                 ; nen° o©ez†v†n° mezer
;         or        dh,bit8/bit8             ; p©°znak o©ez†v†n° mezer
         or        dl,bit7

; ------ tabul†tor volnò

EditBMSB:
;test      byte ptr es:[di+EdiParm1],bit4 ; je volnò tabul†tor ?
;         jz        EditBMSC                 ; nen° volnò tabul†tor
;;         or        dh,bit9/bit8             ; p©°znak volnÇho tabul†toru
;         or        dh,bit8/bit8

; ------ nastaven° p©ep°naáñ menu

EditBMSC:mov       si,offset EVMnVert       ; menu voleb
         call      far ptr SetSwch

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       ax
         ret

EditBMS  ENDP

; -----------------------------------------------------------------------------
;        textovò blok
; -----------------------------------------------------------------------------

EditBMnT PROC      FAR

         mov       al,0                     ; textovò blok

EditBMT2:push      bx
         push      dx
         push      si
         push      di
         push      es
         call      EditSMnY                 ; p©°prava parametrñ okna
         and       byte ptr es:[EdiParm],not bit6+bit7 ; textovò blok
         or        byte ptr es:[EdiParm],al ; nastaven° typu bloku

         or        byte ptr ds:[EditPar2],bit3 ; p©°znak zobrazen° v®eho

         call      EdiAktBl                 ; aktualizace parametrñ bloku

         call      EditZapB                 ; zapnut° bloku

EditBMT4:call      EditAktA                 ; aktualizave oken

         call      EditBMS                  ; p©°prava p©ep°naáñ pro menu
         pop       es
         pop       di
         pop       si
         pop       dx
         pop       bx
         call      far ptr DispAll
         cmp       bl," "
         je        EditBMT6                 ; jen zmàna p©ep°naáe
         add       sp,4                     ; zru®en° n†vratovÇ adresy
         jmp       EditSMX4

EditBMT6:ret

EditBMnT ENDP

; -----------------------------------------------------------------------------
;        line†rn° blok
; -----------------------------------------------------------------------------

EditBMnL:mov       al,bit7                  ; line†rn° blok
         jmp       short EditBMT2

; -----------------------------------------------------------------------------
;        sloupcovò blok
; -----------------------------------------------------------------------------

EditBMnS:mov       al,bit6                  ; sloupcovò blok
         jmp       short EditBMT2

; -----------------------------------------------------------------------------
;        zaá†tek bloku
; -----------------------------------------------------------------------------

EditBMnA:call      EditSMnX                 ; p©°prava parametrñ
         jmp       EditF3                   ; oznaáen° zaá†tku bloku

; -----------------------------------------------------------------------------
;        konec bloku
; -----------------------------------------------------------------------------

EditBMnO:call      EditSMnX                 ; p©°prava parametrñ
         jmp       EditF4                   ; oznaáen° konce bloku

; -----------------------------------------------------------------------------
;        viditelnò blok
; -----------------------------------------------------------------------------

EditBMnV:push      bx
         push      dx
         push      si
         push      di
         push      es
         call      EditSMnY                 ; p©°prava parametrñ okna

         call      EditF9                   ; zap/vyp bloku

         jmp       EditBMT4

; -----------------------------------------------------------------------------
;        p©esun bloku
; -----------------------------------------------------------------------------

EditBMnP:call      EditSMnX                 ; p©°prava parametrñ
         jmp       EditF6                   ; p©esun bloku

; -----------------------------------------------------------------------------
;        kopie bloku
; -----------------------------------------------------------------------------

EditBMnK:call      EditSMnX                 ; p©°prava parametrñ
         jmp       EditF5                   ; kopie bloku

; -----------------------------------------------------------------------------
;        ru®en° bloku
; -----------------------------------------------------------------------------

EditBMnR:call      EditSMnX                 ; p©°prava parametrñ
         jmp       EditF8                   ; ru®en° bloku

; -----------------------------------------------------------------------------
;        do bufferu
; -----------------------------------------------------------------------------

EditBMnD:call      EditSMnX                 ; p©°prava parametrñ
         jmp       Stor0Blk                 ; uloëen° bloku do bufferu

; -----------------------------------------------------------------------------
;        z bufferu
; -----------------------------------------------------------------------------

EditBMnZ:call      EditSMnX                 ; p©°prava parametrñ
         jmp       Retn0Blk                 ; n†vrat bloku z bufferu

; -----------------------------------------------------------------------------
;        uloëen° bloku
; -----------------------------------------------------------------------------

EditBMnU:call      EditSMnX                 ; p©°prava parametrñ
         jmp       EditUlBl                 ; uloëen° bloku na disk

; -----------------------------------------------------------------------------
;        naáten° bloku
; -----------------------------------------------------------------------------

EditBMnN:call      EditSMnX                 ; p©°prava parametrñ
         jmp       EditCtBl                 ; naáten° bloku z disku

; -----------------------------------------------------------------------------
;        modifikace bloku
; -----------------------------------------------------------------------------

EditBMnM:call      EditSMnX                 ; p©°prava parametrñ
         jmp       EditCtF8                 ; modifikace bloku

; -----------------------------------------------------------------------------
;        menu Editace
; -----------------------------------------------------------------------------

EditEMn: jmp       far ptr VertMenu

; -----------------------------------------------------------------------------
;        maz†n° znaku za kurzorem
; -----------------------------------------------------------------------------

EditEMnZ:call      EditSMnX                 ; p©°prava parametrñ
         jmp       EditDelC                 ; maz†n° znaku za kurzorem

; -----------------------------------------------------------------------------
;        maz†n° znaku p©ed kurzorem
; -----------------------------------------------------------------------------

EditEMnP:call      EditSMnX                 ; p©°prava parametrñ
         jmp       EditBS                   ; maz†n° znaku p©ed kurzorem

; -----------------------------------------------------------------------------
;        maz†n° n†sleduj°c°ho slova (Ctrl-T, Ctrl-Delete)
; -----------------------------------------------------------------------------

EditEMnN:call      EditSMnX                 ; p©°prava parametrñ
         jmp       EditCtrT

; -----------------------------------------------------------------------------
;        maz†n° slova p©ed kurzorem
; -----------------------------------------------------------------------------

EditEMnS:call      EditSMnX                 ; p©°prava parametrñ
         jmp       EditCtBS

; -----------------------------------------------------------------------------
;        maz†n° ©†dku
; -----------------------------------------------------------------------------

EditEMnR:call      EditSMnX                 ; p©°prava parametrñ
         jmp       EditDelL                 ; maz†n° celÇho ©†dku

; -----------------------------------------------------------------------------
;        maz†n° po zaá†tek ©†dku
; -----------------------------------------------------------------------------

EditEMnA:call      EditSMnX                 ; p©°prava parametrñ
         jmp       EditCtQH

; -----------------------------------------------------------------------------
;        useknut° konce
; -----------------------------------------------------------------------------

EditEMU: call      EditSMnX                 ; p©°prava parametrñ
         jmp       EditCtQY

;; -----------------------------------------------------------------------------
;;        kopie ©†dku
;; -----------------------------------------------------------------------------
;
;EditEMnK:call      EditSMnX                 ; p©°prava parametrñ
;         ret
;
;; -----------------------------------------------------------------------------
;;        jeden ©†dek vloëit
;; -----------------------------------------------------------------------------
;
;EditEMnJ:call      EditSMnX                 ; p©°prava parametrñ
;         ret

; -----------------------------------------------------------------------------
;        vzhñru ©†dek
; -----------------------------------------------------------------------------

EditEMnV:call      EditSMnX                 ; p©°prava parametrñ
         jmp       EditCtF9                 ; ©†dek nahoru

; -----------------------------------------------------------------------------
;        dolñ ©†dek
; -----------------------------------------------------------------------------

EditEMnD:call      EditSMnX                 ; p©°prava parametrñ
         jmp       EditCF10                 ; ©†dek dolñ

; -----------------------------------------------------------------------------
;        menu Kurzor
; -----------------------------------------------------------------------------
;˛
EditKMn: jmp       far ptr VertMenu

; -----------------------------------------------------------------------------
;        hled†n°
; -----------------------------------------------------------------------------

EditKMnH:call      EditSMnX                 ; p©°prava parametrñ
         jmp       EditF7                   ; hled†n°

; -----------------------------------------------------------------------------
;        n†hrada
; -----------------------------------------------------------------------------

EditKMnN:call      EditSMnX                 ; p©°prava parametrñ
         jmp       EditSF7                  ; n†hrada

; -----------------------------------------------------------------------------
;        d†le
; -----------------------------------------------------------------------------

EditKMnL:call      EditSMnX                 ; p©°prava parametrñ
         jmp       EditHlCL                 ; pokraáov†n° v hled†n°

; -----------------------------------------------------------------------------
;        p©edchoz°
; -----------------------------------------------------------------------------

EditKMnP:call      EditSMnX                 ; p©°prava parametrñ
         jmp       EditHlAU                 ; hled†n° zpàt

; -----------------------------------------------------------------------------
;        dal®°
; -----------------------------------------------------------------------------

EditKMnD:call      EditSMnX                 ; p©°prava parametrñ
         jmp       EditHlAD                 ; hled†n° vp©ed

;; -----------------------------------------------------------------------------
;;        p†rov† z†vorka
;; -----------------------------------------------------------------------------
;
;EditKMnR:call      EditSMnX                 ; p©°prava parametrñ
;         ret

; -----------------------------------------------------------------------------
;        zaá†tek textu
; -----------------------------------------------------------------------------

EditKMnZ:call      EditSMnX                 ; p©°prava parametrñ
         jmp       EditCPgU                 ; zaá†tek textu

; -----------------------------------------------------------------------------
;        konec textu
; -----------------------------------------------------------------------------

EditKMnT:call      EditSMnX                 ; p©°prava parametrñ
         jmp       EditCPgD                 ; konec textu

; -----------------------------------------------------------------------------
;        zaá†tek bloku
; -----------------------------------------------------------------------------

EditKMnB:call      EditSMnX                 ; p©°prava parametrñ

EditCtQB:mov       bx,EdiPBBlk              ; zaá†tek bloku
         jmp       short EditKMK2           ; nastaven° kurzoru

; -----------------------------------------------------------------------------
;        konec bloku
; -----------------------------------------------------------------------------

EditKMnK:call      EditSMnX                 ; p©°prava parametrñ

EditCtQK:mov       bx,EdiPKBlk              ; konec bloku

EditKMK2:mov       si,es:[bx]               ; pozice LOW
         mov       bp,es:[bx+2]             ; pozice HIGH
         mov       ax,es:[bx+4]             ; ©†dek LOW
         mov       cx,es:[bx+6]             ; ©†dek HIGH
         test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je textovò m¢d ?
         jz        EditSetP                 ; je textovò m¢d OK

         mov       ax,es:[bx+8]             ; offset LOW
         mov       cx,es:[bx+10]            ; offset HIGH
EditKMK4:call      EdiGetAd                 ; p©evod offsetu na blok -> BX/SI
         push      di
         call      EdiBORad                 ; p©evod na ©†dek a pozici
         mov       si,di                    ; pozice LOW
         pop       di

; -----------------------------------------------------------------------------
;        nastaven° kurzoru na pozici BP:SI, ©†dek CX:AX, okno ES:DI/DX
;                      (je vol†no i z hled†n° textu)
; -----------------------------------------------------------------------------

EditSetP PROC      NEAR

; ------ nastaven° ©†dku a pozice kurzoru

         mov       word ptr es:[di+EdiRKur],ax ; ©†dek s kurzorem
         mov       word ptr es:[di+EdiRKur+2],cx
         mov       word ptr es:[di+EdiPKur],si ; pozice s kurzorem
         mov       word ptr es:[di+EdiPKur+2],bp

; ------ nastaven° kurzoru na nalezenou pozici

EditStP2:and       byte ptr es:[di+EdiParm1],not bit0 ; zapnut° m¢du editace
         call      EditModW                 ; poëadavek aktualizace okna
         call      EditAktW                 ; aktualizace kurzoru
         or        byte ptr ds:[EditPar2],bit2 ; zobrazit okno
         ret

EditSetP ENDP

; -----------------------------------------------------------------------------
;        £schova aktu†ln° pozice
; -----------------------------------------------------------------------------

EditKMnA:call      EditSMnX                 ; p©°prava parametrñ
EditCtQM:mov       bx,EdiTZnac              ; znaáka 0

EditKMA2:mov       ax,word ptr es:[di+EdiPKur] ; pozice kurzoru na ©†dku LOW
         mov       es:[bx],ax               ; £schova pozice LOW
         mov       ax,word ptr es:[di+EdiPKur+2] ; pozice kurzoru na ©†dku HIGH
         mov       es:[bx+2],ax             ; £schova pozice HIGH
         mov       ax,word ptr es:[di+EdiRKur] ; ©†dek kurzoru LOW
         mov       es:[bx+4],ax             ; £schova ©†dku LOW
         mov       ax,word ptr es:[di+EdiRKur+2] ; ©†dek kurzoru HIGH
         mov       es:[bx+6],ax             ; £schova ©†dku HIGH
         mov       ax,word ptr es:[di+EdiOffsK] ; offset kurzoru LOW
         mov       es:[bx+8],ax             ; £schova offsetu LOW
         mov       ax,word ptr es:[di+EdiOffsK+2] ; offset kurzoru HIGH
         mov       es:[bx+10],ax            ; £schova offsetu HIGH
         ret

; -----------------------------------------------------------------------------
;        n†vrat na uschovanou pozici
; -----------------------------------------------------------------------------

EditKMnU:call      EditSMnX                 ; p©°prava parametrñ
EditCtQP:mov       bx,EdiTZnac              ; znaáka 0
         jmp       EditKMK2                 ; n†vrat pozice

; -----------------------------------------------------------------------------
;        oznaáen° znaákou
; -----------------------------------------------------------------------------

EditKMnO:call      EditSMnX                 ; p©°prava parametrñ
         jmp       EditAF8

; -----------------------------------------------------------------------------
;        p©edchoz° znaáka
; -----------------------------------------------------------------------------

EditKMn1:call      EditSMnX                 ; p©°prava parametrñ
         jmp       EditAF9

; -----------------------------------------------------------------------------
;        dal®° znaáka
; -----------------------------------------------------------------------------

EditKMn2:call      EditSMnX                 ; p©°prava parametrñ
         jmp       EditAF10

; -----------------------------------------------------------------------------
;        skok na zadanou pozici
; -----------------------------------------------------------------------------

EditKMnS:call      EditSMnX                 ; p©°prava parametrñ

; ------ zad†n° offsetu v dekadickÇm tvaru

EditCtQZ:test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je textovò m¢d ?
         jz        EditCQZ6                 ; je textovò m¢d

         test      byte ptr es:[di+EdiParm1],bit1 ; je HEX m¢d ?
         jz        EditCQZ2                 ; nen° HEX m¢d
         test      byte ptr es:[di+EdiParm2],bit2 ; je ASCII á†st HEX pole ?
         jz        EditCQZ4                 ; nen° ASCII á†st HEX pole

EditCQZ2:mov       si,offset EdDQZLin
         call      Edi0Menu                 ; volba novÇho ©†dku
         jc        EditCQZ5                 ; p©eru®en°

         mov       si,offset LinBuff        ; editaán° buffer
         mov       ch,0
         mov       cl,ds:[LinNum]           ; poáet bajtñ v editaán°m bufferu

         call      EditGetD                 ; obnoven° adresy okna

         push      dx
         call      far ptr RozXDNum         ; rozbor zad†n° offsetu
         mov       cx,dx                    ; CX <- offset HIGH
         pop       dx
         jc        EditCQZ5                 ; offset nen° zad†n

EditCQZ3:push      dx
         mov       bx,es:[di+EdiLSir]       ; BX <- ®°©ka dat
         xchg      ax,cx                    ; CX <- offset LOW, AX <- offset HIGH
         xor       dx,dx                    ; DX <- 0
         div       bx                       ; vòpoáet ©†dku HIGH
         xchg      ax,cx                    ; AX <- offset LOW, CX <- ©†dek HIGH
         div       bx                       ; AX <- vòpoáet ©†dku LOW
         mov       bx,dx                    ; BX <- pozice na ©†dku
         pop       dx
         call      EditSetK                 ; nastaven° ©†dku s kurzorem
         xor       cx,cx                    ; CX <- 0
         xchg      ax,bx                    ; AX <- pozice na ©†dku
         call      EditStKP                 ; nastaven° pozice na ©†dku
         ret

;         jmp       EditKMK4                 ; nastaven° kurzoru

; ------ zad†n° offsetu v HEX tvaru

EditCQZ4:mov       si,offset EdHQZLin       ; HEX zad†n°
         call      Edi0Menu                 ; volba novÇho ©†dku
         jc        EditCQZ5                 ; p©eru®en°

         mov       si,offset LinBuff        ; editaán° buffer
         mov       ch,0
         mov       cl,ds:[LinNum]           ; poáet bajtñ v editaán°m bufferu

         call      EditGetD                 ; obnoven° adresy okna

         push      dx
         call      far ptr RozXHNum         ; rozbor zad†n° offsetu v HEX tvaru
         mov       cx,dx                    ; CX <- offset HIGH
         pop       dx
EditCQZ5:jc        EditCQZ9                 ; offset nen° zad†n
         jmp       short EditCQZ3
;         jmp       EditKMK4                 ; nastaven° kurzoru

; ------ zad†n° ©†dku a pozice

EditCQZ6:mov       si,offset EdiQZLin
         call      Edi0Menu                 ; volba novÇho ©†dku
         jc        EditCQZ9                 ; p©eru®en°

         mov       si,offset LinBuff        ; editaán° buffer
         mov       ch,0
         mov       cl,ds:[LinNum]           ; poáet bajtñ v editaán°m bufferu

         call      EditGetD                 ; obnoven° adresy okna

         push      dx
         call      far ptr RozXDNum         ; rozbor zad†n° á°sla ©†dku
         jc        EditCQZ7                 ; ©†dek nen° zad†n
         sub       ax,1
         sbb       dx,0
         jc        EditCQZ7
EdiCQZ62:mov       word ptr es:[di+EdiRKur],ax ; ©†dek s kurzorem LOW
         mov       word ptr es:[di+EdiRKur+2],dx ; ©†dek s kurzorem HIGH

EditCQZ7:call      far ptr RozXPOdd         ; vypu®tàn° oddàlovaáe
         call      far ptr RozXDNum         ; rozbor zad†n° á°sla pozice
         jc        EditCQZ8                 ; pozice nezad†na
         sub       ax,1
         sbb       dx,0
         jc        EditCQZ8
EdiCQZ72:mov       word ptr es:[di+EdiPKur],ax ; pozice s kurzorem LOW
         mov       word ptr es:[di+EdiPKur+2],dx ; pozice s kurzorem HIGH
EditCQZ8:pop       dx
         jmp       EditStP2                 ; nastaven° pozice kurzoru

EditCQZ9:ret

; -----------------------------------------------------------------------------
;        menu Volby
; -----------------------------------------------------------------------------
;˛
EditVMn: call      EditBMS                  ; p©°prava p©ep°naáñ menu
         jmp       far ptr VertMenu

; -----------------------------------------------------------------------------
;        p©ep°naáe voleb
; -----------------------------------------------------------------------------

; ------ aktivn° okno 2

EdiVMPP1:push      bx
         push      dx
         push      si
         push      di
         push      es
         call      EditSMnY                 ; p©°prava parametrñ okna
         call      EditAF1                  ; zmàna aktivn°ho okna
EdiVMPP0:jmp       EditBMT4

; ------ plnÇ okno

EdiVMPP2:push      bx
         push      dx
         push      si
         push      di
         push      es
         call      EditSMnY                 ; p©°prava parametrñ okna
         call      EditAF4                  ; zmàna poátu oken
         jmp       short EdiVMPP0

; ------ vertik†ln° okna

EdiVMPP3:push      bx
         push      dx
         push      si
         push      di
         push      es
         call      EditSMnY                 ; p©°prava parametrñ okna
         call      EditAF6                  ; vertik†ln° okna
         jmp       short EdiVMPP0

; ------ synchronizace

EdiVMPP5:push      bx
         push      dx
         push      si
         push      di
         push      es
         call      EditSMnY                 ; p©°prava parametrñ okna
         call      EditAF7                  ; synchronizace oken
         jmp       short EdiVMPP0

; ------ bin†rn° m¢d

EdiVMPP6:push      bx
         push      dx
         push      si
         push      di
         push      es
         call      EditSMnY                 ; p©°prava parametrñ okna
         call      EditCtF2                 ; bin†rn° m¢d
         jmp       short EdiVMPP0

; ------ hexadecim†ln° m¢d

EdiVMPP7:push      bx
         push      dx
         push      si
         push      di
         push      es
         call      EditSMnY                 ; p©°prava parametrñ okna
         call      EditCtF3                 ; hexadecim†ln° m¢d
         jmp       short EdiVMPP0

; ------ editace povolena

EdiVMPP8:push      bx
         push      dx
         push      si
         push      di
         push      es
         call      EditSMnY                 ; p©°prava parametrñ okna
         call      EditCtF1                 ; editace povolena
         jmp       short EdiVMPP0

;; ------ line†l
;
;EdiVMPP9:push      bx
;         push      dx
;         push      si
;         push      di
;         push      es
;         call      EditSMnY                 ; p©°prava parametrñ okna
;         xor       byte ptr es:[di+EdiParm1],bit3 ; p©°znak line†lu
;         jmp       short EdiVMPP0

; ------ mezery o©ezat

EdiVMPPA:push      bx
         push      dx
         push      si
         push      di
         push      es
         call      EditSMnY                 ; p©°prava parametrñ okna
         call      EditCtF6                 ; o©ez†v†n° mezer
         jmp       short EdiVMPP0

;; ------ tabul†tor volnò
;
;EdiVMPPB:push      bx
;         push      dx
;         push      si
;         push      di
;         push      es
;         call      EditSMnY                 ; p©°prava parametrñ okna
;         xor       byte ptr es:[di+EdiParm1],bit4 ; p©°znak tabul†toru
;         jmp       short EdiVMPP0

;         xor       byte ptr es:[di+EdiParm1],bit7 ; tabul†tor platnò znak

; -----------------------------------------------------------------------------
;        nastaven° rozmàrñ oken
; -----------------------------------------------------------------------------
;˛
EdiVMPP4 PROC      FAR

; ------ uzav©en° oken menu

         add       sp,4                     ; zru®en° n†vratovÇ adresy
         call      far ptr ClosMnuA         ; uzav©en° oken menu
EdVMPP40:or        byte ptr ds:[EditPar2],bit4 ; zobraz° se 2 okna

         push      word ptr ds:[Edit0Sir]   ; £schova pñvodn° ®°©ky
         push      word ptr ds:[Edit0Vys]   ; £schova pñvodn° vò®ky

; ------ zobrazen° oken s aktu†ln°m nastaven°m

EdVMPP41:call      EdVMPPY                  ; aktualizace oken
         mov       si,offset VyskTxt        ; text "Nastavte okna"
         call      far ptr DispHTxt         ; zobrazen° textu n†povàdy

; ------ vstup znaku z kl†vesnice

EdVMPP42:call      far ptr MouseInt         ; obsluha my®i
         call      far ptr DispTime         ; zobrazen° áasu
         call      far ptr Darker           ; obsluha stm°vaáe
         call      far ptr KurzOff          ; vypnut° kurzoru
         call      far ptr MouseGet         ; vstup k¢du my®i
         jnc       EdVPP422                 ; je k¢d my®i
         call      far ptr TestChar         ; test, zda je znak z kl†vesnice
         jc        EdVMPP42                 ; áek†n° na stisk kl†vesy
         call      far ptr InpChar          ; vstup znaku

; ------ adresa okna 1 -> DX

EdVPP422:mov       ax,ds:[EdiS1Win]         ; segment okna 1
         call      far ptr GetSgAdr         ; adresa okna 1 -> DX

; ------ adresa okna 2 -> ES

         mov       ax,ds:[EdiS2Win]         ; segment okna 2
         call      far ptr GetDat           ; adresa okna 2 -> ES

; ------ ukazatel parametrñ oken

         mov       si,EdiW1+EdiRad          ; ©†dek okna 1
         mov       di,EdiW2+EdiRad          ; ©†dek okna 2
         test      byte ptr ds:[EditPar2],bit5 ; jsou vertik†ln° okna ?
         jz        EdVMPP43                 ; jsou horizont†ln° okna
         mov       si,EdiW1+EdiPoz          ; pozice okna 1
         mov       di,EdiW2+EdiPoz          ; pozice okna 2

; ------ p©°prava parametrñ oken

EdVMPP43:push      es
         mov       es,dx                    ; ES <- segment okna 1
         mov       al,es:[si+2]             ; ®°©ka/vò®ka okna 1
         pop       es
         mov       ah,es:[di+2]             ; ®°©ka/vò®ka okna 2

; ------ skok na obsluhu kl†vesy

         call      far ptr JumpBX

         dw        4800h,EdVMPP44           ; nahoru
         dw        4b00h,EdVMPP44           ; vlevo
         dw        5000h,EdVMPP45           ; dolñ
         dw        4d00h,EdVMPP45           ; vpravo
         dw        1c0dh,EdVMPP47           ; ukonáen° operace Enter
         dw        011bh,EdVMPP48           ; p©eru®en° operace ESC

         dw        MousXKod+MousXLR,EdVMPP47 ; uvolnàn° levÇho tlaá°tka my®i
         dw        MousXKod+MousXRP,EdVMPP48 ; stisk pravÇho tlaá°tka my®i
         dw        MousXKod+MousXMP,EdVMPP48 ; stisk st©edn°ho tlaá°tka my®i
         dw        MousXKod+MousXMov,EVMPP441 ; pohyb my®°

         dw        0,EVMPP439

EVMPP439:jmp       EdVMPP42

; ------ veden° pomoc° kurzoru my®i

EVMPP441:mov       cl,byte ptr ds:[MousePoz] ; pozice kurzoru my®i
         test      byte ptr ds:[EditPar2],bit5 ; jsou vertik†ln° okna ?
         jnz       EVMPP442                 ; jsou vertik†ln° okna
         mov       cl,byte ptr ds:[MousePoz+1] ; ©†dek kurzoru my®i
EVMPP442:push      es
         mov       es,dx
         sub       cl,es:[si]               ; odeáten° poá†tku okna 1
         pop       es
         jc        EVMPP440                 ; podteáen°
         cmp       cl,2                     ; minim†ln° rozmàr
         ja        EVMPP443                 ; je to OK
EVMPP440:mov       cl,2                     ; omezen° na minim†ln° rozmàr
EVMPP443:sub       cl,al                    ; korekce pro okno 1
EVMPP444:add       al,cl                    ; rozmàr okna 1
         sub       ah,cl                    ; rozmàr okna 2
         add       es:[di],cl               ; poá†tek okna 2
         mov       cl,-1                    ; oprava pro okno 2
         cmp       ah,2                     ; minim†ln° rozmàr okna 2
         jb        EVMPP444                 ; je nutno zvàt®it okno 2
         jmp       short EdVMPP46           ; proveden° korekce vò®ky

; ------ vlevo, nahoru

EdVMPP44:cmp       al,2                     ; je minim†ln° rozmàr okna 3 ?
         jbe       EVMPP439                 ; je jië poá†tek okna 1
         dec       ax                       ; sn°ëen° rozmàru okna 1
         inc       ah                       ; zvò®en° rozmàru okna 2
         dec       byte ptr es:[di]         ; sn°ëen° poá†tku okna 2
         jmp       short EdVMPP46           ; proveden° korekce vò®ky

; ------ dolñ, vpravo

EdVMPP45:cmp       ah,2                     ; je minim†ln° rozmàr okna 3 ?
         jbe       EVMPP439                 ; je jië poá†tek okna 2
         inc       ax                       ; zvò®en° rozmàru okna 1
         dec       ah                       ; sn°ëen° rozmàru okna 2
         inc       byte ptr es:[di]         ; zvò®en° poá†tku okna 2

; ------ uloëen° parametrñ

EdVMPP46:push      es
         mov       es,dx
         mov       es:[si+2],al             ; ®°©ka okna 1
         pop       es
         mov       es:[di+2],ah             ; ®°©ka okna 2
         call      EdVMPPX                  ; uloëen° parametrñ
         jmp       EdVMPP41

; ------ Enter - uloëen° parametrñ

EdVMPP47:pop       ax
         pop       ax                       ; zru®en° pñvodn°ho nastaven°
         jmp       short EdVMPP49

; ------ Esc

EdVMPP48:pop       word ptr ds:[Edit0Vys]   ; n†vrat pñvodn° vò®ky
         pop       word ptr ds:[Edit0Sir]   ; n†vrat pñvodn° ®°©ky

EdVMPP49:call      EdVMPPY                  ; aktualizace oken
         jmp       far ptr Main0

EdiVMPP4 ENDP

EdVMPPX: mov       cl,es:[di+2]             ; ®°©ka/vò®ka okna 2
         mov       ch,0
         mov       es,dx                    ; ES <- adresa okna 2
         mov       dl,es:[si+2]             ; ®°©ka/vò®ka okna 1
         mov       dh,0
         add       cx,dx                    ; souáet vò®ek/®°©ek obou oken
         xor       ax,ax                    ; DX:AX = ®°©ka/vò®ka * 65535

         mov       si,offset Edit0Sir       ; ®°©ka oken
         test      byte ptr ds:[EditPar2],bit5 ; jsou vertik†ln° okna ?
         jnz       EdVMPPX2                 ; jsou vertik†ln° okna
         mov       si,offset Edit0Vys       ; relativn° vò®ka
EdVMPPX2:div       cx                       ; vòpoáet relativn° ®°©ky/vò®ky
         mov       ds:[si],ax               ; relativn° rozmàr oken
         ret

EdVMPPY: call      EditRozv                 ; novÇ rozvrëen° oken
         mov       dx,ds:[EdiSNAkt]         ; segment neaktivn°ho okna
         call      Edi2CF0                  ; aktualizace neaktivn°ho okna
         mov       dx,ds:[EdiSAkt]          ; segment aktivn°ho okna
         call      Edi2CF0                  ; aktualizace aktivn°ho okna
         call      EditAktA                 ; aktualizace parametrñ kurzorñ
         call      EdiAktBl                 ; pokus o aktualizaci ukazatelñ bloku
         call      far ptr DispAll          ; novÇ zobrazen° oken
         ret

; -----------------------------------------------------------------------------
;        menu Zvl†®tn°
; -----------------------------------------------------------------------------

EditZMn:

         jmp       far ptr VertMenu


; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                           Obsluha zobrazen°
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; -----------------------------------------------------------------------------
;        zobrazen° okna editoru AX (bit 15: 1=zobraz° se jako okno 2)
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) á°slo segmentu okna
;                   SS:[BP-4] (2) uschovanò datovò segment
;                   SS:[BP-5] (1) ukazatel ©†dku na obrazovce k zobrazen°
;                   SS:[BP-6] (1) poá†teán° pozice okna
;                   SS:[BP-7] (1) á°taá ©†dkñ k zobrazen°
;                   SS:[BP-8] (1) ®°©ka okna
;
;                   SS:[BP-10] (2) ukazatel relativn°ho á°sla bloku
;                   SS:[BP-12] (2) adresa datovÇho bloku
;                   SS:[BP-14] (2) ukazatel dat v bloku (offset)
;                   SS:[BP-16] (2) poáet bajtñ v bloku
;
;                   SS:[BP-20] (4) poá†teán° zobrazen† pozice ©†dku
;                   SS:[BP-21] (1) parametry
;                                      bit 0: 1=jen zobrazen° (bez editace)
;                                      bit 1: 1=HEX m¢d zobrazen° ƒø0=text.
;                                      bit 2: 1=bin†rn° m¢d       ƒŸ  m¢d
;                                      bit 4: 1=nen° ë†dnò znak na ©†dku
;                                      bit 6: 1=je k¢dov†n° pro DEMO
;                                      bit 7: 1=TAB jako bàënò znak
;
;                   SS:[BP-22] (1) barva neaktivn°ho kurzoru
;                   SS:[BP-23] (1) barva ©°dic°ch znakñ
;                   SS:[BP-24] (1) bàën† barva textu
;                   SS:[BP-25] (1) barva bloku v textu
;                   SS:[BP-26] (1) barva indikace p©eteáen°
;
;                   SS:[BP-30] (4) offset poá†tku ©†dku (pro HEX m¢d)
;                   SS:[BP-31] (1) p©esah tabul†toru na zaá†tku ©†dku
;                   SS:[BP-32] (1) parametry 2
;                                      bit 0: 1=prob°h† zobrazen° bloku
;                                      bit 1: 1=zobraz° se jako okno 2
;                                      bit 2: 1=z†kaz z†pisu do souboru
;                                      bit 4: 1=je to aktivn° okno
;                                      bit 5: 1=blok zobrazen
;                                      bit 6: 1=sloupcovò blok ƒø0=textovò blok
;                                      bit 7: 1=©†dkovò blok   ƒŸ
;                   SS:[BP-36] (4) pozice konce bloku
;                   SS:[BP-40] (4) relativn° ©†dek konce bloku
;                   SS:[BP-44] (4) relativn° pozice konce bloku
;                   SS:[BP-48] (4) pozice zaá†tku bloku
;                   SS:[BP-52] (4) relativn° ©†dek zaá†tku bloku
;                   SS:[BP-56] (4) relativn° pozice zaá†tku bloku
;                   SS:[BP-58] (2) á°taá pozice k zapnut° bloku
;                   SS:[BP-60] (2) á°taá pozice k vypnut° bloku
;                   SS:[BP-62] (2) offset definice okna
;                   SS:[BP-64] (2) á°taá kurzoru pro HEX a BIN m¢d
;                       SS:[BP-63] (1) pozice kurzoru na ©†dku pro textovò m¢d
;                       SS:[BP-64] (1) á°taá ©†dku s kurzorem pro textovò m¢d
;                   SS:[BP-68] (4) á°taá offsetu k zapnut° bloku (BIN a HEX m¢d)
;                   SS:[BP-72] (4) á°taá offsetu k vypnut° bloku (BIN a HEX m¢d)
;                   SS:[BP-74] (2) ®°©ka dat v m¢du BIN a HEX
;                   SS:[BP-76] (2) korekce ASCII pole pro HEX m¢d
;                   SS:[BP-80] (4) ukazatel á°sla ©†dku pro DEMO
; -----------------------------------------------------------------------------

DispEdi  PROC      NEAR

         call      DispENad                 ; zobrazen° nadpisu editoru

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
         sub       sp,80

; ------ p©°znak okna 2

         mov       bl,ah                    ; BL <- bit 7 p©°znak okna 2
         rol       bl,1                     ; rotace na bitovou pozici 0
         rol       bl,1                     ; rotace na bitovou pozici 1
         and       bl,bit1                  ; p©°znak okna 2

; ------ p©°znak aktivn°ho okna

         cmp       ax,ds:[EdiSAkt]          ; je to aktivn° okno ?
         jne       DispEd04                 ; nen° to aktivn° okno
         or        bl,bit4                  ; p©°znak aktivn°ho okna
DispEd04:mov       ss:[bp-32],bl            ; parametry 2

; ------ adresa definice okna -> BX

         mov       bx,EdiW1                 ; okno 1
         or        ax,ax                    ; je to okno 1 ?
         jns       DispEdi1                 ; je okno 1
         mov       bx,EdiW2                 ; okno 2
DispEdi1:mov       ss:[bp-62],bx            ; definice okna

; ------ adresa segmentu souboru -> ES

         mov       ss:[bp-2],ax             ; á°slo segmentu okna
         and       ah,not bit15/bit8        ; nulov†n° p©°znaku okna 2
         mov       ss:[bp-4],ds             ; £schova datovÇho segmentu
         call      far ptr GetDat           ; adresa definice okna -> ES

; ------ ©†dek, pozice a rozmàry okna

         mov       ax,word ptr es:[bx+EdiPoz] ; pozice a ©†dek k zobrazen° okna
         inc       ah                       ; prvn° ©†dek
         mov       ss:[bp-6],ax             ; pozice a ©†dek k zobrazen°
         mov       ax,word ptr es:[bx+EdiSir] ; ®°©ka a vò®ka okna
         dec       ah                       ; bez ©†dku nadpisu
         mov       ss:[bp-8],ax             ; ®°©ka okna a á°taá ©†dkñ

; ------ buffer k dek¢dov†n° ©†dku

         mov       ah,0                     ; AX = poáet znakñ na ©†dek
         cmp       al,20                    ; asi tak minim†ln° buffer
         jae       DispEd12
         mov       al,20
DispEd12:shl       ax,1                     ; poáet bajtñ na ©†dek
         sub       sp,ax                    ; m°sto pro buffer ©†dku

; ------ ukazatel dat v bloku

         mov       ax,es:[bx+EdiBTop]       ; á°slo poá†teán°ho bloku
         mov       ss:[bp-10],ax            ; ukazatel á°sla bloku
         mov       ax,es:[bx+EdiOTop]       ; poá†tek prvn°ho ©†dku v bloku
         mov       ss:[bp-14],ax            ; ukazatel dat v bloku

; ------ £schova ukazatele á°sla ©†dku pro DEMO

         mov       ax,word ptr es:[bx+EdiRTop] ; á°slo poá†teán°ho ©†dku
         mov       ss:[bp-80],ax            ; ukazatel á°sla ©†dku
         mov       ax,word ptr es:[bx+EdiRTop+2]
         mov       ss:[bp-80+2],ax

; ------ poá†teán° zobrazen† pozice ©†dku

         mov       ax,word ptr es:[bx+EdiPTop+2] ; poá†teán° pozice HIGH
         mov       ss:[bp-20+2],ax          ; poá†teán° pozice HIGH
         mov       ax,word ptr es:[bx+EdiPTop] ; poá†teán° pozice LOW
         mov       ss:[bp-20],ax            ; poá†teán° pozice LOW

; ------ parametry 1

         mov       al,es:[bx+EdiParm1]
         mov       ss:[bp-21],al            ; parametry

; ------ p©°prava barev textu

         mov       al,ds:[ColEdi7]          ; barva neaktivn°ho kurzoru
         mov       ss:[bp-22],al            ; barva neaktivn°ho kurzoru
         mov       ax,word ptr ds:[ColEdi3] ; bàën† barva a ©°dic° znaky
         mov       ss:[bp-24],ax            ; bàën† barva a ©°dic° znaky
         mov       ax,word ptr ds:[ColEdi5] ; barva indikace p©eteáen° a blok
         mov       ss:[bp-26],ax            ; barva indikace p©eteáen° a blok

; ------ offset poá†tku ©†dku (pro zobrazen° HEX)

         mov       ax,word ptr es:[bx+EdiOffsT+2] ; poá†tek HIGH
         mov       ss:[bp-30+2],ax
         mov       ax,word ptr es:[bx+EdiOffsT] ; poá†tek LOW
         mov       ss:[bp-30],ax

; ------ parametry 2

         mov       ah,es:[bx+EdiParm2]      ; parametry
         and       ah,bit5                  ; p©°znak zapnut° bloku
         mov       al,es:[EdiParm]          ; parametry 2
         and       al,bit2+bit6+bit7        ; z†kaz z†pisu + typ bloku
         or        al,ah                    ; p©°znak zapnut° bloku
         or        ss:[bp-32],al            ; parametry 2

; ------ zaá†tek bloku pro BIN a HEX m¢d

         mov       ax,word ptr es:[EdiOBBlk] ; offset zaá†tku bloku LOW
         mov       cx,word ptr es:[EdiOBBlk+2] ; offset zaá†tku bloku HIGH
         sub       ax,word ptr es:[bx+EdiOffsT] ; offset od poá†tku str†nky
         sbb       cx,word ptr es:[bx+EdiOffsT+2]
         mov       ss:[bp-68],ax            ; á°taá k zapnut° bloku
         mov       ss:[bp-68+2],cx

; ------ konec bloku pro BIN a HEX m¢d

         mov       ax,word ptr es:[EdiOKBlk] ; offset konce bloku LOW
         mov       cx,word ptr es:[EdiOKBlk+2] ; offset konce bloku HIGH
         sub       ax,word ptr es:[bx+EdiOffsT] ; offset od poá†tku str†nky
         sbb       cx,word ptr es:[bx+EdiOffsT+2]
         mov       ss:[bp-72],ax            ; á°taá k vypnut° bloku
         mov       ss:[bp-72+2],cx

; ------ blok vypnut

         test      byte ptr ss:[bp-32],bit5 ; je blok zobrazen ?
         jnz       DispEd13                 ; blok je zobrazen
         xor       ax,ax                    ; AX <- 0
         dec       ax                       ; AX <- -1
         mov       ss:[bp-68],ax            ; nen° zaá†tek bloku
         mov       ss:[bp-68+2],ax
         mov       ss:[bp-72],ax            ; nen° konec bloku
         mov       ss:[bp-72+2],ax

; ------ ©†dek konce bloku relativnà (od poá†tku okna)

DispEd13:mov       ax,word ptr es:[EdiRKBlk] ; ©†dek konce bloku LOW
         mov       cx,word ptr es:[EdiRKBlk+2] ; ©†dek konce bloku HIGH
         sub       ax,word ptr es:[bx+EdiRTop] ; ©†dek relativnà k poá†tku
         sbb       cx,word ptr es:[bx+EdiRTop+2]
         mov       ss:[bp-40+2],cx          ; ©†dek konce relativnà k poá†tku
         mov       ss:[bp-40],ax

; ------ pozice konce bloku

         mov       ax,word ptr es:[EdiPKBlk]
         mov       cx,word ptr es:[EdiPKBlk+2] ; pozice konce bloku
         mov       ss:[bp-36+2],cx          ; pozice konce bloku
         mov       ss:[bp-36],ax

; ------ ©†dek zaá†tku bloku relativnà

         mov       ax,word ptr es:[EdiRBBlk]
         mov       cx,word ptr es:[EdiRBBlk+2] ; ©†dek zaá†tku bloku
         sub       ax,word ptr es:[bx+EdiRTop] ; ©†dek relativnà k poá†tku
         sbb       cx,word ptr es:[bx+EdiRTop+2]
         mov       ss:[bp-52+2],cx          ; ©†dek zaá†tku relativnà k poá†tku
         mov       ss:[bp-52],ax

; ------ pozice zaá†tku bloku relativnà

         mov       ax,word ptr es:[EdiPBBlk]
         mov       cx,word ptr es:[EdiPBBlk+2] ; pozice zaá†tku bloku
         mov       ss:[bp-48+2],cx          ; pozice zaá†tku bloku
         mov       ss:[bp-48],ax

; ------ á°taá kurzoru pro HEX a BIN m¢d

         test      byte ptr es:[bx+EdiParm2],bit3 ; je dotaz p©i n†hradà ?
         jnz       DispEd15                 ; je dotaz p©i n†hradà (je kurzor)
         mov       ax,-1                    ; kurzor vypnutò
         test      byte ptr ss:[bp-32],bit4 ; je to aktivn° okno ?
         jz        DispEd14                 ; nen° to aktivn° okno
         test      byte ptr ss:[bp-21],bit1 ; je HEX m¢d ?
         jz        DispEd16                 ; aktivn° okno+nen° HEX m¢d -> vyp
DispEd14:test      byte ptr ss:[bp-21],bit0 ; je jen zobrazen° ?
         jnz       DispEd16                 ; je jen zobrazen° - kurzor vypnut
DispEd15:mov       ax,word ptr es:[bx+EdiOffsK] ; offset kurzoru v souboru LOW
         sub       ax,word ptr es:[bx+EdiOffsT] ; offset od poá†tku okna
         inc       ax                       ; korekce
         test      byte ptr ss:[bp-21],bit1+bit2 ; je textovò m¢d ?
         jnz       DispEd16                 ; nen° textovò m¢d
         mov       al,es:[bx+EdiRKurR]      ; ©†dek s kurzorem relativnà
         inc       ax                       ; korekce
         mov       ah,es:[bx+EdiPKurR]      ; pozice s kurzorem relativnà
DispEd16:mov       ss:[bp-64],ax            ; á°taá kurzoru pro HEX m¢d

; ------ ®°©ka dat v m¢du BIN a HEX

         mov       ax,es:[bx+EdiLSir]       ; ®°©ka dat v m¢du BIN a HEX
         mov       ss:[bp-74],ax            ; ®°©ka dat v m¢du BIN a HEX
         mov       dx,2*3                   ; poáet pozic na HEX znak
         mul       dx
         mov       ss:[bp-76],ax            ; korekce pro ASCII pole HEX m¢du

; ------ test, zda bude k¢dov†n° dat pro DEMO

DispEdi2:push      ds
         mov       ds,ss:[bp-4]             ; DS <- datovò segment
         test      byte ptr ds:[LicDPar0],bit4 ; je DEMO verze ?
         pop       ds
         jz        DispEd20                 ; nen° DEMO verze
         or        byte ptr ss:[bp-21],bit6 ; je k¢dov†n° dat pro DEMO
         cmp       word ptr ss:[bp-80+2],0
         jne       DispEd21                 ; bude k¢dov†n° dat pro DEMO
         cmp       word ptr ss:[bp-80],500  ; poáet ©†dkñ pro zobrazen°
         jae       DispEd21                 ; bude k¢dov†n° dat pro DEMO
         test      byte ptr ss:[bp-21],bit0 ; je jen zobrazen° ?
         jnz       DispEd20                 ; je jen zobrazen° - v°ce ©†dkñ
         test      byte ptr ss:[bp-32],bit2 ; je z†kaz z†pisu ?
         jnz       DispEd20                 ; je z†kaz z†pisu
         cmp       word ptr ss:[bp-80],50   ; poáet ©†dkñ pro editaci
         jae       DispEd21                 ; bude k¢dov†n° dat pro DEMO
DispEd20:and       byte ptr ss:[bp-21],not bit6 ; nen° k¢dov†n° dat pro DEMO

; ------ p©°prava dat k zobrazen° -> DS:SI/CX

DispEd21:mov       si,ss:[bp-14]            ; poá†tek prvn°ho ©†dku v bloku
         call      DspNxtEB                 ; poskytnut° adresy bloku -> DS:SI
         push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku

; ------ nalezen° poá†tku k zobrazen° ©†dku, je-li textovò m¢d

         or        byte ptr ss:[bp-21],bit4 ; p©°znak - nen° znak
         test      byte ptr ss:[bp-21],bit1+bit2 ; je HEX nebo bin†rn° m¢d ?
         jnz       DispEdi3                 ; je HEX nebo bin†rn° m¢d
         jcxz      DispEd23                 ; konec dat
         and       byte ptr ss:[bp-21],not bit4 ; p©°znak - je nàjakò znak
DispEd23:call      EdGetPoz                 ; nalezen° pozice (CX=0 konec ©†dku)

; ------ inicializace parametrñ bloku

DispEdi3:and       byte ptr ss:[bp-32],not bit0 ; nen° zobrazen° bloku
         mov       word ptr ss:[bp-58],-1   ; nen° zaá†tek bloku
         mov       word ptr ss:[bp-60],-1   ; nen° konec bloku
         test      byte ptr ss:[bp-32],bit5 ; je blok zobrazen ?
         jz        DispEd3B                 ; blok nen° zobrazen

; ------ test, zda je bin†rn° nebo HEX m¢d

         test      byte ptr ss:[bp-21],bit1+bit2 ; je BIN nebo HEX m¢d ?
         jz        DispEd30                 ; je textovò m¢d

; ------ test poá†tku bloku (mus° bòt <= 0)

         mov       ax,ss:[bp-68]            ; á°taá pro zapnut° bloku
         mov       bx,ss:[bp-68+2]
         sub       ax,1
         sbb       bx,0
         jns       DispEd3B                 ; nen° blok

; ------ test konce bloku (mus° bòt >=0)

         mov       ax,ss:[bp-72+2]
         or        ax,ax
         js        DispEd3B                 ; nen° blok
         or        byte ptr ss:[bp-32],bit0 ; prob°h† zobrazen° bloku
DispEd3B:jmp       short DispEd35

; ------ test, zda je poá†teán° ©†dek bloku platnò (mus° bòt <= 0)

DispEd30:mov       bx,ss:[bp-52+2]
         mov       ax,ss:[bp-52]            ; relativn° ©†dek zaá†tku bloku
         sub       ax,1
         sbb       bx,0                     ; vyhovuje ©†dek poá†tku ?
         jns       DispEd35                 ; nen° blok

; ------ test, zda je koncovò ©†dek bloku platnò (mus° bòt >= 0)

         mov       ax,ss:[bp-40+2]          ; ©†dek konce bloku
         or        ax,ax                    ; vyhovuje ©†dek konce bloku ?
         js        DispEd35                 ; ©†dek konce nevyhovuje

; ------ ©†dek leë° v ©†dku bloku

         or        byte ptr ss:[bp-32],bit0 ; prob°h† zobrazen° bloku

; ------ test, zda je sloupcovò blok nebo prvn° ©†dek textovÇho bloku

         test      byte ptr ss:[bp-32],bit6 ; je sloupcovò blok ?
         jnz       DispEd31                 ; je sloupcovò blok

         test      byte ptr ss:[bp-32],bit7 ; je ©†dkovò blok ?
         jnz       DispEd32                 ; je ©†dkovò blok
         mov       ax,ss:[bp-52+2]          ; relativn° ©†dek zaá†tku bloku
         or        ax,ss:[bp-52]            ; je prvn° ©†dek textovÇho bloku ?
         jnz       DispEd32                 ; nen° prvn° ©†dek textovÇho bloku

; ------ test, zda vyhovuje poá†teán° pozice bloku (sloupcovò blok/1. ©†dek)

DispEd31:mov       bx,ss:[bp-56+2]          ; pozice zaá†tku bloku HIGH
         mov       ax,ss:[bp-56]            ; pozice zaá†tku bloku LOW
         sub       ax,1
         sbb       bx,0                     ; vyhovuje pozice ?
         js        DispEd32                 ; poá†tek vyhovuje OK

; ------ nen° je®tà zaá†tek bloku - p©°prava á°taáe zapnut° bloku

         and       byte ptr ss:[bp-32],not bit0 ; blok nen° zobrazen
         cmp       word ptr ss:[bp-56+2],0  ; je velk† pozice ?
         jne       DispEd32                 ; je velk† pozice
         inc       ax                       ; n†vrat á°taáe zaá†tku bloku
         mov       ss:[bp-58],ax            ; á°taá pro zapnut° bloku

; ------ test, zda je sloupcovò blok nebo posledn° ©†dek textovÇho bloku

DispEd32:test      byte ptr ss:[bp-32],bit6 ; je sloupcovò blok ?
         jnz       DispEd33                 ; je sloupcovò blok

         test      byte ptr ss:[bp-32],bit7 ; je ©†dkovò blok ?
         jnz       DispEd35                 ; je ©†dkovò blok
         mov       ax,ss:[bp-40+2]          ; relativn° ©†dek konce bloku
         or        ax,ss:[bp-40]            ; je posledn° ©†dek text. bloku ?
         jnz       DispEd35                 ; nen° posledn° ©†dek text. bloku

; ------ test, zda vyhovuje koncov† pozice bloku (sloupcovò blok/posledn° ©†dek)

DispEd33:mov       ax,ss:[bp-44]            ; pozice konce bloku LOW
         mov       bx,ss:[bp-44+2]          ; pozice konce bloku HIGH
         sub       ax,1
         sbb       bx,0
         jns       DispEd34                 ; konec vyhovuje OK
         and       byte ptr ss:[bp-32],not bit0 ; blok nen° zobrazen

; ------ p©°prava á°taáe vypnut° bloku

DispEd34:cmp       word ptr ss:[bp-44+2],0  ; je velk† pozice ?
         jne       DispEd35                 ; je velk† pozice
         inc       ax
         mov       ss:[bp-60],ax            ; á°taá pro vypnut° bloku

; ------ dek¢dov†n° ©†dku v HEX m¢du

DispEd35:mov       di,sp                    ; DI <- buffer v z†sobn°ku
         cld
         test      byte ptr ss:[bp-21],bit1 ; je HEX m¢d ?
         jz        DispEd36                 ; nen° HEX m¢d
         call      DekEdH                   ; dek¢dov†n° ©†dku v HEX m¢du
         jmp       DispEdi8                 ; zobrazen° ©†dku

; ------ dek¢dov†n° ©†dku v textovÇm m¢du

DispEd36:test      byte ptr ss:[bp-21],bit2 ; je bin†rn° m¢d ?
         jnz       DispEd38                 ; je bin†rn° m¢d
         call      DekEdT                   ; dek¢dov†n° ©†dku v textovÇm m¢du
         jmp       short DispEdi8

; ------ dek¢dov†n° ©†dku v bin†rn°m m¢du

DispEd38:call      DekEdB                   ; dek¢dov†n° ©†dku v bin†rn°m m¢du

; ------ oznaáen° podteáen° poá†tku ©†dku

DispEdi8:mov       ss:[bp-14],si            ; ukazatel dat v bufferu
         mov       ds,ss:[bp-4]             ; n†vrat datovÇho segmentu
         mov       si,sp                    ; SI <- zaá†tek bufferu
         mov       cl,ss:[bp-8]             ; ®°©ka okna
         test      byte ptr ss:[bp-21],bit4+bit2+bit1 ; nen° znak/HEX/BIN ?
         jnz       DispEd84                 ; nen° znak/je HEX/je BIN
         mov       ax,ss:[bp-20]            ; poá†teán° pozice
         or        ax,ss:[bp-20+2]          ; je poá†tek ©†dku ?
         jz        DispEd84                 ; je poá†tek ©†dku
         cmp       cl,19                    ; je mal† ®°©ka okna ?
         jb        DispEd84                 ; je mal† ®°©ka okna
         mov       ah,ss:[bp-26]            ; barva indikace p©eteáen°
         mov       al,"Æ"                   ; indikace p©eteáen°
         mov       es:[si],ax               ; indikace p©eteáen°

; ------ zobrazen° ©†dku

DispEd84:mov       dx,ss:[bp-6]             ; pozice a ©†dek k zobrazen°
         xor       ax,ax                    ; hladina k zobrazen°
         call      far ptr DispMStr         ; zobrazen° ©†dku

; ------ p©°prava pro dal®° ©†dek

         add       word ptr ss:[bp-80],1
         adc       word ptr ss:[bp-80+2],0

         inc       byte ptr ss:[bp-5]       ; zvò®en° ukazatele ©†dkñ
         dec       byte ptr ss:[bp-7]       ; sn°ëen° á°taáe ©†dkñ
         jz        DispEdi9                 ; nen° dal®° ©†dek
         mov       ds,ss:[bp-12]            ; adresa datovÇho bloku
         mov       cx,ss:[bp-16]            ; poáet bajtñ v bloku
         jmp       DispEdi2                 ; zobrazen° dal®°ho ©†dku

; ------ n†vrat registrñ

DispEdi9:mov       sp,bp
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      DispKEdi                 ; zobrazen° kurzoru v oknà AX
         ret

DispEdi  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° ©†dku v textovÇm m¢du
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=buffer k dek¢dov†n° ©†dku
;        DS:SI=ukazatel dat v bufferu
;        CX=poáet bajtñ v bufferu (0=je konec ©†dku)
;        CLD
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) á°slo segmentu okna
;                   SS:[BP-4] (2) uschovanò datovò segment
;                   SS:[BP-5] (1) ukazatel ©†dku na obrazovce k zobrazen°
;                   SS:[BP-6] (1) poá†teán° pozice okna
;                   SS:[BP-7] (1) á°taá ©†dkñ k zobrazen°
;                   SS:[BP-8] (1) ®°©ka okna
;
;                   SS:[BP-10] (2) ukazatel relativn°ho á°sla bloku
;                   SS:[BP-12] (2) adresa datovÇho bloku
;                   SS:[BP-14] (2) ukazatel dat v bloku (offset)
;                   SS:[BP-16] (2) poáet bajtñ v bloku
;
;                   SS:[BP-20] (4) poá†teán° zobrazen† pozice ©†dku
;                   SS:[BP-21] (1) parametry
;                                      bit 0: 1=jen zobrazen° (bez editace)
;                                      bit 1: 1=HEX m¢d zobrazen° ƒø0=text.
;                                      bit 2: 1=bin†rn° m¢d       ƒŸ  m¢d
;                                      bit 4: 1=nen° ë†dnò znak na ©†dku
;                                      bit 6: 1=je k¢dov†n° pro DEMO
;                                      bit 7: 1=TAB jako bàënò znak
;
;                   SS:[BP-22] (1) barva neaktivn°ho kurzoru
;                   SS:[BP-23] (1) barva ©°dic°ch znakñ
;                   SS:[BP-24] (1) bàën† barva textu
;                   SS:[BP-25] (1) barva bloku v textu
;                   SS:[BP-26] (1) barva indikace p©eteáen°
;
;                   SS:[BP-30] (4) offset poá†tku ©†dku (pro HEX m¢d)
;                   SS:[BP-31] (1) p©esah tabul†toru na zaá†tku ©†dku
;                   SS:[BP-32] (1) parametry 2
;                                      bit 0: 1=prob°h† zobrazen° bloku
;                                      bit 1: 1=zobraz° se jako okno 2
;                                      bit 2: 1=z†kaz z†pisu do souboru
;                                      bit 4: 1=je to aktivn° okno
;                                      bit 5: 1=blok zobrazen
;                                      bit 6: 1=sloupcovò blok ƒø0=textovò blok
;                                      bit 7: 1=©†dkovò blok   ƒŸ
;                   SS:[BP-36] (4) pozice konce bloku
;                   SS:[BP-40] (4) relativn° ©†dek konce bloku
;                   SS:[BP-44] (4) relativn° pozice konce bloku
;                   SS:[BP-48] (4) pozice zaá†tku bloku
;                   SS:[BP-52] (4) relativn° ©†dek zaá†tku bloku
;                   SS:[BP-56] (4) relativn° pozice zaá†tku bloku
;                   SS:[BP-58] (2) á°taá pozice k zapnut° bloku
;                   SS:[BP-60] (2) á°taá pozice k vypnut° bloku
;                   SS:[BP-62] (2) offset definice okna
;                   SS:[BP-64] (2) á°taá kurzoru pro HEX a BIN m¢d
;                       SS:[BP-63] (1) pozice kurzoru na ©†dku pro textovò m¢d
;                       SS:[BP-64] (1) á°taá ©†dku s kurzorem pro textovò m¢d
;                   SS:[BP-68] (4) á°taá offsetu k zapnut° bloku (BIN a HEX m¢d)
;                   SS:[BP-72] (4) á°taá offsetu k vypnut° bloku (BIN a HEX m¢d)
;                   SS:[BP-74] (2) ®°©ka dat v m¢du BIN a HEX
;                   SS:[BP-76] (2) korekce ASCII pole pro HEX m¢d
;                   SS:[BP-80] (4) ukazatel á°sla ©†dku pro DEMO
; -----------------------------------------------------------------------------

DekEdT:  push      di                       ; £schova adresy zaá†tku bufferu

; ------ p©°prava vòchoz° barvy textu ©†dku -> DX

         mov       dx,ss:[bp-24]            ; bàën† barva a barva ©°dic°ch znakñ
         test      byte ptr ss:[bp-32],bit0 ; prob°h† zobrazen° bloku ?
         jz        DekEdT1                  ; neprob°h† zobrazen° bloku
         mov       dl,ss:[bp-25]            ; barva bloku v textu
         mov       dh,dl

; ------ p©°prava á°taáe ®°©ky okna -> BX

DekEdT1: mov       bl,ss:[bp-8]             ; BL <- ®°©ka okna
         mov       bh,0

; ------ zobrazen° mezer z p©esahu tabul†toru

         push      cx
         mov       cl,ss:[bp-31]            ; p©esah tabul†toru
         mov       ch,0
         jcxz      DekEdT14                 ; nen° p©esah tabul†toru
         mov       al," "                   ; znak mezery k vymaz†n°
DekEdT12:or        bx,bx                    ; je jië konec okna ?
         jz        DekEdT60                 ; je jië konec okna
         mov       ah,dl                    ; AH <- bàën† barva znaku
         call      DekEdUl                  ; uloëen° znaku
         loop      DekEdT12                 ; dal®° znak
DekEdT14:pop       cx

         or        cx,cx                    ; zbyly nàjakÇ znaky ?
         jnz       DekEdT3                  ; nen° konec ©†dku
DekEdT2: jmp       DekEdT8                  ; konec dek¢dov†n° ©†dku

; ------ naáten° znaku z bufferu

DekEdT22:call      DspNxtEB                 ; adresa dal®°ho bloku
         jc        DekEdT2                  ; nejsou dal®° data
DekEdT3: cmp       si,cx                    ; je konec bufferu ?
         jae       DekEdT22                 ; p©°prava dal®°ch dat
         lodsb                              ; naáten° znaku z bufferu

; ------ test, zda je konec ©†dku LF

         cmp       al,LF                    ; je konec ©†dku ?
         jne       DekEdT32
         jmp       DekEdT7                  ; je konec ©†dku LF

; ------ test, zda je znak CR

DekEdT32:cmp       al,CR
         je        DekEdT5                  ; je znak CR

; ------ je platnò znak - test, zda je jië konec ©†dku

DekEdT4: or        bx,bx                    ; je voln† dal®° pozice na ©†dku ?
         jz        DekEdT6                  ; nen° voln† pozice - je p©eteáen°

; ------ obsluha tabul†toru

         cmp       al,TAB                   ; je tabul†tor ?
         jne       DekEdT42                 ; nen° tabul†tor - je bàënò znak
         test      byte ptr ss:[bp-21],bit7 ; je TAB jako bàënò znak ?
         jnz       DekEdT42                 ; TAB je jako bàënò znak

         mov       ax,bx                    ; AX <- zbylÇ pozice do konce ©†dku
         sub       al,ss:[bp-8]             ; AL <- -offset pozice na ©†dku
         sub       al,ss:[bp-20]            ; AL <- -pozice relativnà
         dec       al                       ; - (pozice relativnà + 1)
         and       al,7                     ; doplnàk do tabulaán° pozice
         inc       ax                       ; poáet pozic k uloëen°

         push      cx
         xchg      ax,cx                    ; CX <- poáet pozic
         mov       al," "                   ; n†hradn° znak mezery
DekEdT43:or        bx,bx                    ; je konec ©†dku ?
         jz        DekEdT60                 ; je konec ©†dku
         mov       ah,dl                    ; AH <- barva znaku
         call      DekEdUl                  ; uloëen° znaku
         loop      DekEdT43                 ; dal®° mezera
         pop       cx
         jmp       short DekEdT3            ; dal®° znak

; ------ uloëen° platnÇho znaku

DekEdT42:mov       ah,dl                    ; bàën† barva textu
         cmp       al," "                   ; je ©°dic° znak ?
         jb        DekEdT48                 ; je ©°dic° znak
DekEdT44:call      DekEdUl                  ; uloëen° znaku
         jmp       short DekEdT3            ; dal®° znak

; ------ obsluha znaku < 32 (jin† barva, n†hrada 0 znakem ".")

DekEdT48:mov       ah,dh                    ; barva ©°dic°ch znakñ
         cmp       al,0                     ; je bajt 0 ?
         jne       DekEdT44                 ; nen° bajt 0
         mov       al,"."                   ; n†hrada za bajt 0
         jmp       short DekEdT44

; ------ je znak CR - test, zda n†sleduje znak LF

DekEdT5: cmp       si,cx                    ; jsou p©ipravena dal®° data ?
         jb        DekEdT52                 ; jsou p©ipravena dal®° data
         call      DspNxtEB                 ; dal®° blok
         jc        DekEdT4                  ; nejsou dal®° data - znak CR plat°
DekEdT52:cmp       byte ptr ds:[si],LF      ; n†sleduje znak LF ?
         je        DekEdT74                 ; je LF - vypu®tàn°, konec
         jmp       short DekEdT4            ; nen° znak LF - znak CR je platnò

; ------ oznaáen° p©eteáen° konce ©†dku (DI=konec za bufferem ©†dku)

DekEdT60:pop       cx

DekEdT6: cmp       byte ptr ss:[bp-8],19    ; je mal† ®°©ka okna ?
         jb        DekEdT64                 ; je mal† ®°©ka okna
         mov       ah,ss:[bp-26]            ; barva indikace p©eteáen°
         mov       al,"Ø"                   ; oznaáen° p©eteáen°
         mov       es:[di-2],ax             ; oznaáen° p©eteáen° ©†dku

; ------ nalezen° konce ©†dku

DekEdT64:cmp       si,cx                    ; jsou p©ipravena dal®° data ?
         jb        DekEdT66                 ; jsou p©ipravena dal®° data
         call      DspNxtEL                 ; dal®° blok (s p©elomem ©†dkñ)
         jc        DekEdT8                  ; nejsou dal®° data
DekEdT66:lodsb                              ; p©ipravenò znak
         cmp       al,LF                    ; konec ©†dku LF ?
         je        DekEdT7                  ; je konec ©†dku LF
         cmp       al,CR                    ; je znak CR ?
         jne       DekEdT64                 ; nen° CR - dal®° znak

; ------ je znak CR - test, zda n†sleduje znak LF (zda je konec ©†dku)

         cmp       si,cx                    ; jsou p©ipravena dal®° data ?
         jb        DekEdT68                 ; jsou p©ipravena dal®° data
         call      DspNxtEB                 ; dal®° blok
         jc        DekEdT8                  ; nejsou dal®° data
DekEdT68:cmp       byte ptr ds:[si],LF      ; n†sleduje znak LF ?
         jne       DekEdT64                 ; nen° znak LF - dal®° znak
         jmp       short DekEdT74           ; jinak konec ©†dku - vypu®tàn° LF

; ------ konec ©†dku LF - vypu®tàn° p©°padnÇho n†sleduj°c°ho znaku CR

DekEdT7: cmp       si,cx                    ; jsou p©ipravena dal®° data ?
         jb        DekEdT72                 ; jsou p©ipravena dal®° data
         call      DspNxtEB                 ; dal®° blok
         jc        DekEdT8                  ; nejsou dal®° data
DekEdT72:cmp       byte ptr ds:[si],CR      ; n†sleduje znak CR ?
         jne       DekEdT8                  ; nen†sleduje znak CR
DekEdT74:inc       si                       ; vypu®tàn° znaku CR (nebo LF)

; ------ vymaz†n° zbytku ©†dku

DekEdT8: or        bx,bx                    ; zbyly nàjakÇ pozice ?
         jz        DekEdT9                  ; nezbyly ë†dnÇ pozice
         mov       al," "                   ; znak mezery
DekEdT82:mov       ah,dl                    ; AH <- bàën† barva textu
         call      DekEdUl                  ; uloëen° znaku
         jnz       DekEdT82                 ; dal®° znak

; ------ zvò®en° ukazatele ©†dkñ bloku

DekEdT9: sub       word ptr ss:[bp-40],1    ; posun ©†dku konce bloku
         sbb       word ptr ss:[bp-40+2],0
         sub       word ptr ss:[bp-52],1    ; posun ©†dku zaá†tku bloku
         sbb       word ptr ss:[bp-52+2],0

         pop       di                       ; n†vrat adresy zaá†tku bufferu

; ------ test, zda je ©†dek s kurzorem

         dec       byte ptr ss:[bp-64]      ; á°taá ©†dku s kurzorem
         jnz       DekEdTA                  ; nen° ©†dek s kurzorem

; ------ zobrazen° kurzoru

         mov       al,ss:[bp-63]            ; pozice s kurzorem
         cmp       al,ss:[bp-8]             ; vyhovuje pozice ?
         jae       DekEdTA                  ; neplatn† pozice
         mov       ah,0
         add       di,ax
         add       di,ax                    ; pozice k uloëen° kurzoru
         mov       al,ss:[bp-22]            ; barva kurzoru
         mov       es:[di+1],al             ; uloëen° kurzoru

DekEdTA: ret

; -----------------------------------------------------------------------------
;        uloëen° znaku AX (ZY=konec)
; -----------------------------------------------------------------------------

DekEdUl: stosw                              ; uloëen° znaku

; ------ za®ifrov†n° dat pro DEMO

         test      byte ptr ss:[bp-21],bit6 ; je ®ifrov†n° dat ?
         jz        DekEdUl1                 ; nen° ®ifrov†n° dat
         cmp       byte ptr es:[di-2]," "
         je        DekEdUl1
         mov       byte ptr es:[di-2],"*"

; ------ á°t†n° zapnut° bloku

DekEdUl1:dec       word ptr ss:[bp-58]      ; á°taá pro zapnut° bloku
         jnz       DekEdUl2                 ; nen° zapnut° bloku
         mov       dl,ss:[bp-25]            ; barva bloku v textu
         mov       dh,dl

; ------ á°t†n° vypnut° bloku

DekEdUl2:dec       word ptr ss:[bp-60]      ; á°taá pro vypnut° bloku
         jnz       DekEdUl3                 ; nen° vypnut° bloku
         mov       dx,ss:[bp-24]            ; bàën† barva a barva ©°dic°ch znakñ

DekEdUl3:dec       bx                       ; sn°ëen° á°taáe zbylòch pozic
         ret

; -----------------------------------------------------------------------------
;        dek¢dov†n° ©†dku v bin†rn°m m¢du
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=buffer k dek¢dov†n° ©†dku
;        DS:SI=ukazatel dat v bufferu
;        CX=poáet bajtñ v bufferu (0=konec dat)
;        CLD
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) á°slo segmentu okna
;                   SS:[BP-4] (2) uschovanò datovò segment
;                   SS:[BP-5] (1) ukazatel ©†dku na obrazovce k zobrazen°
;                   SS:[BP-6] (1) poá†teán° pozice okna
;                   SS:[BP-7] (1) á°taá ©†dkñ k zobrazen°
;                   SS:[BP-8] (1) ®°©ka okna
;
;                   SS:[BP-10] (2) ukazatel relativn°ho á°sla bloku
;                   SS:[BP-12] (2) adresa datovÇho bloku
;                   SS:[BP-14] (2) ukazatel dat v bloku (offset)
;                   SS:[BP-16] (2) poáet bajtñ v bloku
;
;                   SS:[BP-20] (4) poá†teán° zobrazen† pozice ©†dku
;                   SS:[BP-21] (1) parametry
;                                      bit 0: 1=jen zobrazen° (bez editace)
;                                      bit 1: 1=HEX m¢d zobrazen° ƒø0=text.
;                                      bit 2: 1=bin†rn° m¢d       ƒŸ  m¢d
;                                      bit 4: 1=nen° ë†dnò znak na ©†dku
;                                      bit 6: 1=je k¢dov†n° pro DEMO
;                                      bit 7: 1=TAB jako bàënò znak
;
;                   SS:[BP-22] (1) barva neaktivn°ho kurzoru
;                   SS:[BP-23] (1) barva ©°dic°ch znakñ
;                   SS:[BP-24] (1) bàën† barva textu
;                   SS:[BP-25] (1) barva bloku v textu
;                   SS:[BP-26] (1) barva indikace p©eteáen°
;
;                   SS:[BP-30] (4) offset poá†tku ©†dku (pro HEX m¢d)
;                   SS:[BP-31] (1) p©esah tabul†toru na zaá†tku ©†dku
;                   SS:[BP-32] (1) parametry 2
;                                      bit 0: 1=prob°h† zobrazen° bloku
;                                      bit 1: 1=zobraz° se jako okno 2
;                                      bit 2: 1=z†kaz z†pisu do souboru
;                                      bit 4: 1=je to aktivn° okno
;                                      bit 5: 1=blok zobrazen
;                                      bit 6: 1=sloupcovò blok ƒø0=textovò blok
;                                      bit 7: 1=©†dkovò blok   ƒŸ
;                   SS:[BP-36] (4) pozice konce bloku
;                   SS:[BP-40] (4) relativn° ©†dek konce bloku
;                   SS:[BP-44] (4) relativn° pozice konce bloku
;                   SS:[BP-48] (4) pozice zaá†tku bloku
;                   SS:[BP-52] (4) relativn° ©†dek zaá†tku bloku
;                   SS:[BP-56] (4) relativn° pozice zaá†tku bloku
;                   SS:[BP-58] (2) á°taá pozice k zapnut° bloku
;                   SS:[BP-60] (2) á°taá pozice k vypnut° bloku
;                   SS:[BP-62] (2) offset definice okna
;                   SS:[BP-64] (2) á°taá kurzoru pro HEX a BIN m¢d
;                       SS:[BP-63] (1) pozice kurzoru na ©†dku pro textovò m¢d
;                       SS:[BP-64] (1) á°taá ©†dku s kurzorem pro textovò m¢d
;                   SS:[BP-68] (4) á°taá offsetu k zapnut° bloku (BIN a HEX m¢d)
;                   SS:[BP-72] (4) á°taá offsetu k vypnut° bloku (BIN a HEX m¢d)
;                   SS:[BP-74] (2) ®°©ka dat v m¢du BIN a HEX
;                   SS:[BP-76] (2) korekce ASCII pole pro HEX m¢d
;                   SS:[BP-80] (4) ukazatel á°sla ©†dku pro DEMO
; -----------------------------------------------------------------------------

; ------ p©°prava vòchoz° barvy textu ©†dku -> DX

DekEdB:  mov       dx,ss:[bp-24]            ; bàën† barva a barva ©°dic°ch znakñ
         test      byte ptr ss:[bp-32],bit0 ; prob°h† zobrazen° bloku ?
         jz        DekEdB1                  ; neprob°h† zobrazen° bloku
         mov       dl,ss:[bp-25]            ; barva bloku v textu
         mov       dh,dl

; ------ p©°prava á°taáe ®°©ky okna -> BX

DekEdB1: mov       bl,ss:[bp-8]             ; ®°©ka okna
         mov       bh,0
         jmp       short DekEdB3

; ------ naáten° znaku z bufferu

DekEdB22:call      DspNxtEB                 ; adresa dal®°ho bloku
         jc        DekEdB8                  ; nejsou dal®° data

DekEdB3: cmp       si,cx                    ; je konec bufferu ?
         jae       DekEdB22                 ; p©°prava dal®°ch dat
         lodsb                              ; naáten° znaku z bufferu

; ------ uloëen° platnÇho znaku

DekEdB42:or        bx,bx                    ; je konec ©†dku ?
         jz        DekEdB7                  ; je konec ©†dku

; ------ zapnut°/vypnut° bloku

         call      DekEdBBl                 ; posun ukazatelñ bloku

         mov       ah,dl                    ; bàën† barva textu
         cmp       al," "
         jb        DekEdB48                 ; je ©°dic° znak

; ------ oprava barvy pro kurzor

DekEdB44:dec       word ptr ss:[bp-64]      ; á°taá kurzoru
         jnz       DekEdB47                 ; nen° kurzor
         mov       ah,ss:[bp-22]            ; barva neaktivn°ho kurzoru

DekEdB47:stosw                              ; uloëen° znaku

; ------ za®ifrov†n° dat pro DEMO

         test      byte ptr ss:[bp-21],bit6 ; je ®ifrov†n° dat ?
         jz        DekEdB45                 ; nen° ®ifrov†n° dat
         cmp       byte ptr es:[di-2]," "
         je        DekEdB45
         mov       byte ptr es:[di-2],"*"
DekEdB45:dec       bx                       ; á°taá znakñ
         jmp       short DekEdB3            ; dal®° znak

; ------ obsluha znaku < 32 (jin† barva, n†hrada 0 znakem ".")

DekEdB48:mov       ah,dh                    ; barva ©°dic°ch znakñ
         cmp       al,0                     ; je bajt 0 ?
         jne       DekEdB44                 ; nen° bajt 0
         mov       al,"."                   ; n†hrada za bajt 0
         jmp       short DekEdB44

; ------ vymaz†n° zbytku ©†dku

DekEdB7: dec       si                       ; n†vrat ukazatele na posledn° znak
DekEdB8: or        bx,bx                    ; zbyly nàjakÇ pozice ?
         jz        DekEdB9                  ; nezbyly ë†dnÇ pozice
         mov       al," "                   ; znak mezery
DekEdB82:mov       ah,ss:[bp-24]            ; bàën† barva textu
         dec       word ptr ss:[bp-64]      ; á°taá kurzoru pro HEX m¢d
         jnz       DekEdB84                 ; nen° kurzor
         mov       ah,ss:[bp-22]            ; barva kurzoru v HEX m¢du
DekEdB84:stosw                              ; uloëen° znaku
         dec       bx
         jnz       DekEdB82                 ; dal®° znak
DekEdB9: ret

; -----------------------------------------------------------------------------
;        posun ukazatelñ bloku (a zmàna barvy)
; -----------------------------------------------------------------------------

DekEdBBl:sub       word ptr ss:[bp-68],1    ; á°taá pro zapnut° bloku
         jnc       DekEdBB2
         sbb       word ptr ss:[bp-68+2],0
         jnc       DekEdBB2
         mov       dl,ss:[bp-25]            ; barva bloku v textu
         mov       dh,dl

DekEdBB2:sub       word ptr ss:[bp-72],1    ; á°taá pro vypnut° bloku
         jnc       DekEdBB4
         sbb       word ptr ss:[bp-72+2],0
         jnc       DekEdBB4
         mov       dx,ss:[bp-24]            ; bàën† barva a barva ©°dic°ch znakñ

DekEdBB4:ret

; -----------------------------------------------------------------------------
;        dek¢dov†n° ©†dku v HEX m¢du
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=buffer k dek¢dov†n° ©†dku
;        DS:SI=ukazatel dat v bufferu
;        CX=poáet bajtñ v bufferu (0=konec dat)
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) á°slo segmentu okna
;                   SS:[BP-4] (2) uschovanò datovò segment
;                   SS:[BP-5] (1) ukazatel ©†dku na obrazovce k zobrazen°
;                   SS:[BP-6] (1) poá†teán° pozice okna
;                   SS:[BP-7] (1) á°taá ©†dkñ k zobrazen°
;                   SS:[BP-8] (1) ®°©ka okna
;
;                   SS:[BP-10] (2) ukazatel relativn°ho á°sla bloku
;                   SS:[BP-12] (2) adresa datovÇho bloku
;                   SS:[BP-14] (2) ukazatel dat v bloku (offset)
;                   SS:[BP-16] (2) poáet bajtñ v bloku
;
;                   SS:[BP-20] (4) poá†teán° zobrazen† pozice ©†dku
;                   SS:[BP-21] (1) parametry
;                                      bit 0: 1=jen zobrazen° (bez editace)
;                                      bit 1: 1=HEX m¢d zobrazen° ƒø0=text.
;                                      bit 2: 1=bin†rn° m¢d       ƒŸ  m¢d
;                                      bit 4: 1=nen° ë†dnò znak na ©†dku
;                                      bit 6: 1=je k¢dov†n° pro DEMO
;                                      bit 7: 1=TAB jako bàënò znak
;
;                   SS:[BP-22] (1) barva neaktivn°ho kurzoru
;                   SS:[BP-23] (1) barva ©°dic°ch znakñ
;                   SS:[BP-24] (1) bàën† barva textu
;                   SS:[BP-25] (1) barva bloku v textu
;                   SS:[BP-26] (1) barva indikace p©eteáen°
;
;                   SS:[BP-30] (4) offset poá†tku ©†dku (pro HEX m¢d)
;                   SS:[BP-31] (1) p©esah tabul†toru na zaá†tku ©†dku
;                   SS:[BP-32] (1) parametry 2
;                                      bit 0: 1=prob°h† zobrazen° bloku
;                                      bit 1: 1=zobraz° se jako okno 2
;                                      bit 2: 1=z†kaz z†pisu do souboru
;                                      bit 4: 1=je to aktivn° okno
;                                      bit 5: 1=blok zobrazen
;                                      bit 6: 1=sloupcovò blok ƒø0=textovò blok
;                                      bit 7: 1=©†dkovò blok   ƒŸ
;                   SS:[BP-36] (4) pozice konce bloku
;                   SS:[BP-40] (4) relativn° ©†dek konce bloku
;                   SS:[BP-44] (4) relativn° pozice konce bloku
;                   SS:[BP-48] (4) pozice zaá†tku bloku
;                   SS:[BP-52] (4) relativn° ©†dek zaá†tku bloku
;                   SS:[BP-56] (4) relativn° pozice zaá†tku bloku
;                   SS:[BP-58] (2) á°taá pozice k zapnut° bloku
;                   SS:[BP-60] (2) á°taá pozice k vypnut° bloku
;                   SS:[BP-62] (2) offset definice okna
;                   SS:[BP-64] (2) á°taá kurzoru pro HEX a BIN m¢d
;                       SS:[BP-63] (1) pozice kurzoru na ©†dku pro textovò m¢d
;                       SS:[BP-64] (1) á°taá ©†dku s kurzorem pro textovò m¢d
;                   SS:[BP-68] (4) á°taá offsetu k zapnut° bloku (BIN a HEX m¢d)
;                   SS:[BP-72] (4) á°taá offsetu k vypnut° bloku (BIN a HEX m¢d)
;                   SS:[BP-74] (2) ®°©ka dat v m¢du BIN a HEX
;                   SS:[BP-76] (2) korekce ASCII pole pro HEX m¢d
;                   SS:[BP-80] (4) ukazatel á°sla ©†dku pro DEMO
; -----------------------------------------------------------------------------

DekEdH   PROC      NEAR

; ------ vymaz†n° ©†dku

         push      di
         push      cx
         mov       cl,ss:[bp-8]             ; CL <- ®°©ka okna
         mov       ch,0
         mov       al," "                   ; mazac° znak mezery
         mov       ah,ss:[bp-24]            ; bàën† barva textu
         cld
         rep       stosw                    ; vymaz†n° ©†dku
         pop       cx
         pop       di

; ------ rozli®en°, zda je dlouhò (®°©ka okna 80 znakñ) nebo zkr†cenò ©†dek

         cmp       byte ptr ss:[bp-8],80    ; je ®°©ka okna alespo§ 80 ?
         jae       DekEdH1                  ; ®°©ka okna je OK
         jmp       DekEd4H                  ; dek¢dov†n° kr†tkÇho ©†dku

; ------ levò a pravò okraj

DekEdH1: mov       ah,ss:[bp-24]            ; bàën† barva textu
         mov       al,"∫"
         stosw                              ; levò okraj
         mov       es:[di+2*79-2],ax        ; pravò okraj

; ------ oddàlovac° á†ra

         mov       al,"≥"
         mov       es:[di+2*8+2*1],ax       ; lev† oddàlovac° á†ra
         mov       es:[di+2*8+2*1+2*52],ax  ; prav† oddàlovac° á†ra
         jcxz      DekEdH26                 ; nejsou dal®° data

; ------ dek¢dov†n° offsetu v souboru

         xchg      ax,bx                    ; BH <- barva
         mov       ax,ss:[bp-30+2]          ; offset HIGH
         call      far ptr DekHWord         ; dek¢dov†n° offsetu HIGH
         mov       al,":"
         cld
         stosb                              ; oddàlovac° znak "0000:0000"
         inc       di                       ; p©eskoáen° barvy
         mov       ax,ss:[bp-30]            ; offset LOW
         call      far ptr DekHWord         ; dek¢dov†n° offsetu LOW
         inc       di                       ; p©eskoáen° oddàlovac° á†ry
         inc       di

; ------ p©°prava k dek¢dov†n°

         cld
         mov       bx,2*52                  ; korekce pro ASCII pole
         mov       dx,ss:[bp-24]            ; bàën† barva a barva ©°dic°ch znakñ
         test      byte ptr ss:[bp-32],bit0 ; je zobrazen° bloku ?
         jz        DekEdH2                  ; nen° zobrazen° bloku
         mov       dl,ss:[bp-25]            ; barva bloku v textu
         mov       dh,dl

; ------ zapnut°/vypnut° bloku

DekEdH2: call      DekEdBBl                 ; posun ukazatelñ bloku

; ------ naáten° znaku z bufferu

         cmp       si,cx                    ; jsou p©ipravena dal®° data ?
         jb        DekEdH3                  ; jsou dal®° data
         call      DspNxtEB                 ; dal®° blok
         jnc       DekEdH3                  ; jsou dal®° data OK
DekEdH26:jmp       short DekEdH8            ; nejsou dal®° data

DekEdH3: lodsb                              ; naáten° znaku z bufferu

; ------ barva znaku

         mov       ah,dl                    ; AH <- bàën† barva
         cmp       al," "                   ; je ©°dic° znak ?
         jae       DekEdH5                  ; je bàënò znak
         mov       ah,dh                    ; AH <- barva ©°dic°ch znakñ
         or        al,al                    ; je bajt 0 ?
         jnz       DekEdH5                  ; nen° bajt 0
         mov       al,"."

; ------ oprava barvy pro kurzor

DekEdH5: dec       word ptr ss:[bp-64]      ; á°taá kurzoru pro HEX m¢d
         jnz       DekEdH51                 ; nen° kurzor
         mov       ah,ss:[bp-22]            ; barva neaktivn°ho kurzoru

; ------ uloëen° znaku

DekEdH51:mov       es:[di+bx],ax            ; uloëen° ASCII znaku

; ------ za®ifrov†n° dat pro DEMO

         test      byte ptr ss:[bp-21],bit6 ; je ®ifrov†n° dat ?
         jz        DekEdH52                 ; nen° ®ifrov†n° dat
         cmp       byte ptr es:[di+bx]," "
         je        DekEdH52
         mov       byte ptr es:[di+bx],"*"
DekEdH52:dec       si                       ; n†vrat ukazatele
         lodsb                              ; novÇ naáten° znaku k dek¢dov†n°
         call      far ptr DekHByte         ; dek¢dov†n° bajtu HEX

         test      byte ptr ss:[bp-21],bit6 ; je ®ifrov†n° dat ?
         jz        DekEdH53                 ; nen° ®ifrov†n° dat
         mov       byte ptr es:[di-4],"*"
         mov       byte ptr es:[di-2],"*"

; ------ test, zda to byl posledn° bajt

DekEdH53:sub       bx,2*2                   ; oprava korekce
         cmp       bl,2*16                  ; je jië konec ?
         jbe       DekEdH8                  ; je jië konec dek¢dov†n°

; ------ oddàlovac° mezera za bajtem

         mov       ah,dl                    ; AH <- bàën† barva
         mov       al," "
         stosw                              ; oddàlovac° mezera

; ------ oddàlovac° mezera v polovinà ©†dku

         cmp       bl,2*52 - 4*2*2 - 2 - 4*2*2 ; je polovina ©†dku ?
         jne       DekEdH54
         mov       al,"-"
         stosw
         dec       bx                       ; oprava korekce
         dec       bx
         jmp       short DekEdH6

; ------ oddàlovac° mezera za kaëdòm átvrtòm bajtem

DekEdH54:cmp       bl,2*52 - 4*2*2 - 2 - 4*2*2 - 2*2 - 4*2*2
         je        DekEdH6
         cmp       bl,2*52 - 4*2*2
         jne       DekEdH7
DekEdH6: mov       al," "
         stosw                              ; oddàlovac° mezera
         dec       bx                       ; oprava korekce
         dec       bx
DekEdH7: jmp       short DekEdH2            ; dek¢dov†n° dal®°ho bajtu

; ------ konec dek¢dov†n° - posun ukazatelñ

DekEdH8: add       word ptr ss:[bp-30],16   ; zvò®en° offsetu v souboru
         adc       word ptr ss:[bp-30+2],0
         ret


; ====== dek¢dov†n° kr†tkÇho ©†dku

; ------ oddàlovac° á†ra

DekEd4H: mov       ah,ss:[bp-24]            ; AH <- bàën† barva textu
         mov       al,"≥"
         cmp       byte ptr ss:[bp-8],7+1+2+1+1 ; je mal† ®°©ka okna ?
         jb        DekEd4H0                 ; je mal† ®°©ka okna

         mov       es:[di+2*7],ax           ; lev† oddàlovac° á†ra
         push      di
         add       di,ss:[bp-76]            ; korekce pro ASCII pole
         mov       es:[di+2*7],ax           ; prav† oddàlovac° á†ra
         pop       di
         jcxz      DekEd426                 ; nejsou dal®° data

; ------ dek¢dov†n° offsetu v souboru

         xchg      ax,bx                    ; BH <- bàën† barva textu
         mov       ax,ss:[bp-30+2]          ; offset HIGH
         shl       ax,1
         shl       ax,1
         shl       ax,1
         shl       ax,1                     ; offset HIGH * 16
         call      far ptr DekHWord         ; dek¢dov†n° offsetu HIGH
         dec       di
         dec       di                       ; zru®en° p©idanÇ neplatnÇ á°slice
         mov       ax,ss:[bp-30]            ; offset LOW
         call      far ptr DekHWord         ; dek¢dov†n° offsetu LOW
         inc       di
         inc       di                       ; p©eskoáen° oddàlovac° á†ry
         jmp       short DekEd4H1

; ------ p©°prava k dek¢dov†n°

DekEd4H0:mov       es:[di+2*2],ax           ; á†ra pro kr†tkò ©†dek

DekEd4H1:xor       bx,bx                    ; BX <- á°taá dat na ©†dku
         mov       dx,ss:[bp-24]            ; bàën† barva a barva ©°dic°ch znakñ
         test      byte ptr ss:[bp-32],bit0 ; je zobrazen° bloku ?
         jz        DekEd4H2                 ; nen° zobrazen° bloku
         mov       dl,ss:[bp-25]            ; barva bloku v textu
         mov       dh,dl

; ------ zapnut°/vypnut° bloku

DekEd4H2:call      DekEdBBl                 ; posun ukazatelñ bloku

; ------ naáten° znaku z bufferu

         cmp       si,cx                    ; jsou p©ipravena dal®° data ?
         jb        DekEd4H3                 ; jsou dal®° data
         call      DspNxtEB                 ; dal®° blok
         jnc       DekEd4H3                 ; jsou dal®° data
DekEd426:jmp       short DekEd4H8           ; nejsou dal®° data
DekEd4H3:lodsb                              ; naáten° znaku z bufferu

; ------ barva znaku

         mov       ah,dl                    ; AH <- bàën† barva
         cmp       al," "                   ; je ©°dic° znak ?
         jae       DekEd4H5                 ; je bàënò znak
         mov       ah,dh                    ; AH <- barva ©°dic°ch znakñ
         or        al,al                    ; je bajt 0 ?
         jnz       DekEd4H5                 ; nen° bajt 0
         mov       al,"."                   ; n†hrada bajtu 0

; ------ oprava barvy pro kurzor

DekEd4H5:dec       word ptr ss:[bp-64]      ; á°taá kurzoru pro HEX m¢d
         jnz       DekEd451                 ; nen° kurzor
         mov       ah,ss:[bp-22]            ; barva kurzoru

; ------ uloëen° znaku

DekEd451:push      di
         add       di,ss:[bp-76]            ; korekce pro ASCII pole
         sub       di,bx
         sub       di,bx
         sub       di,bx
         sub       di,bx                    ; korekce offsetu (- 4 * pozice)
         stosw                              ; uloëen° ASCII znaku

; ------ za®ifrov†n° dat pro DEMO

         test      byte ptr ss:[bp-21],bit6 ; je ®ifrov†n° dat ?
         jz        DekEd452                 ; nen° ®ifrov†n° dat
         cmp       byte ptr es:[di-2]," "
         je        DekEd452
         mov       byte ptr es:[di-2],"*"

DekEd452:pop       di

         dec       si                       ; n†vrat ukazatele
         lodsb                              ; novÇ naáten° znaku k dek¢dov†n°
         call      far ptr DekHByte         ; dek¢dov†n° bajtu HEX

         test      byte ptr ss:[bp-21],bit6 ; je ®ifrov†n° dat ?
         jz        DekEd453                 ; nen° ®ifrov†n° dat
         mov       byte ptr es:[di-4],"*"
         mov       byte ptr es:[di-2],"*"

; ------ test, zda byl posledn° bajt

DekEd453:inc       bx                       ; zvò®en° offsetu bajtu
         cmp       bx,ss:[bp-74]            ; jsou jië v®ehny bajty ?
         jae       DekEd4H8                 ; jsou jië v®echny bajty

; ------ oddàlovac° mezera za bajtem

         mov       ah,dl                    ; AH <- bàën† barva
         mov       al," "
         stosw                              ; oddàlovac° mezera
         jmp       short DekEd4H2           ; dal®° bajt

; ------ konec dek¢dov†n° - posun ukazatelñ

DekEd4H8:mov       ax,ss:[bp-74]            ; poáet bajtñ na ©†dek
         add       word ptr ss:[bp-30],ax   ; zvò®en° offsetu v souboru
         adc       word ptr ss:[bp-30+2],0
         ret

DekEdH   ENDP

; -----------------------------------------------------------------------------
;        aktualizace bloku pro nalezen° konce ©†dku
; -----------------------------------------------------------------------------
; VSTUP: SI=ukazatel dat v bufferu (mñëe p©etÇct do jinÇho bufferu)
;        BP=ukazatel lok†ln°ch promànnòch
; VùSTUP: CY=chyba nebo konec dat (CX=0)
;         DS=segment dat v bufferu
;         SI=novò ukazatel dat v bufferu
;         CX=poáet bajtñ v bufferu celkem (=adresa konce dat)
;         CLD p©°znak nahoru
; -----------------------------------------------------------------------------

DspNxtEL PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      dx
         push      di
         push      ds
         push      es

; ------ adresa okna -> ES

         mov       dx,ss:[bp-2]             ; DX <- á°slo segmentu okna
         mov       ds,ss:[bp-4]             ; DS <- datovò segment
         call      EditGetD                 ; adresa definice okna -> ES

; ------ ukazatel á°sla bloku -> BX, DI

         mov       bx,ss:[bp-10]            ; BX <- ukazatel á°sla bloku
DspNxEL1:mov       di,bx                    ; DI <- á°slo bloku
         shl       di,1
         shl       di,1
         shl       di,1                     ; á°slo bloku * 8
         add       di,EdiABlok              ; adresa definice bloku

; ------ normalizace ukazatele

DspNxEL2:cmp       si,es:[di+EdiBlokN]      ; je ukazatel uvnit© bloku ?
         jb        DspNxEL4                 ; ukazatel je OK uvnit© bloku
DspNxEL3:inc       bx                       ; zvò®en° á°sla bloku
         cmp       bx,es:[EdiNBlok]         ; je to platnÇ á°slo bloku ?
         jae       DspNxEL8                 ; je p©eteáen° á°sla bloku
         sub       si,es:[di+EdiBlokN]      ; posun offsetu v bloku
         jmp       short DspNxEL1

; ------ test, zda je v bloku poáet ©†dkñ = 0 (-1=nezn†mÇ) -> CX=poáet bajtñ
; Je testov†n i n†sleduj°c° buffer, aby se zastavilo zrychlenÇ vyhled†v†n°
; d©°ve pro p©°pad, ëe by byl LF na zaá†tku dal®°ho bufferu (zapoá°tal by
; se jen LF nam°sto CR/LF). Mohlo by se je®tà st†t, ëe v tomto bloku bude
; poáet bajtñ = 0 a souáasnà dal®° blok zaá°nat LF, to je m†lo pravdàpodobnÇ.

DspNxEL4:cmp       word ptr es:[di+EdiBlokL+EdiBlokS],0 ; jsou v dal®°m bufferu ©†dky ?
         jne       DspNxEL9                 ; budou ©†dky
         cmp       word ptr es:[di+EdiBlokL],0 ; jsou v bloku ©†dky ?
         jne       DspNxEL9                 ; v bloku nen° poáet ©†dkñ = 0

; ------ posun k dal®°mu bloku

         mov       si,es:[di+EdiBlokN]      ; ukazatel na konec bloku
         jmp       short DspNxEL3           ; dal®° blok

; ------ novÇ á°slo bloku

DspNxEL8:dec       bx                       ; n†vrat á°sla bloku
DspNxEL9:mov       ss:[bp-10],bx            ; novò aktu†ln° blok

; ------ n†vrat registrñ

         pop       es
         pop       ds
         pop       di
         pop       dx
         pop       bx

;                           !!!!!!
; ------ pokraáuje DspNxtEB !!!!!!
;                           !!!!!!

DspNxtEL ENDP

; -----------------------------------------------------------------------------
;        aktualizace bloku p©i zobrazen° (n†sleduje za DspNxtEL !)
; -----------------------------------------------------------------------------
; VSTUP: SI=ukazatel dat v bufferu (mñëe p©etÇct do jinÇho bufferu)
;        BP=ukazatel lok†ln°ch promànnòch
; VùSTUP: CY=chyba nebo konec dat (CX=0)
;         DS=segment dat v bufferu
;         SI=novò ukazatel dat v bufferu
;         CX=poáet bajtñ v bufferu celkem (=adresa konce dat)
;         CLD p©°znak nahoru
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) á°slo segmentu okna
;                   SS:[BP-4] (2) uschovanò datovò segment
;                   SS:[BP-5] (1) ukazatel ©†dku na obrazovce k zobrazen°
;                   SS:[BP-6] (1) poá†teán° pozice okna
;                   SS:[BP-7] (1) á°taá ©†dkñ k zobrazen°
;                   SS:[BP-8] (1) ®°©ka okna
;
;                   SS:[BP-10] (2) ukazatel relativn°ho á°sla bloku
;                   SS:[BP-12] (2) adresa datovÇho bloku
;                   SS:[BP-14] (2) ukazatel dat v bloku (offset)
;                   SS:[BP-16] (2) poáet bajtñ v bloku
;
;                   SS:[BP-20] (4) poá†teán° zobrazen† pozice ©†dku
;                   SS:[BP-21] (1) parametry
;                                      bit 0: 1=jen zobrazen° (bez editace)
;                                      bit 1: 1=HEX m¢d zobrazen° ƒø0=text.
;                                      bit 2: 1=bin†rn° m¢d       ƒŸ  m¢d
;                                      bit 4: 1=nen° ë†dnò znak na ©†dku
;                                      bit 6: 1=je k¢dov†n° pro DEMO
;                                      bit 7: 1=TAB jako bàënò znak
;
;                   SS:[BP-22] (1) barva neaktivn°ho kurzoru
;                   SS:[BP-23] (1) barva ©°dic°ch znakñ
;                   SS:[BP-24] (1) bàën† barva textu
;                   SS:[BP-25] (1) barva bloku v textu
;                   SS:[BP-26] (1) barva indikace p©eteáen°
;
;                   SS:[BP-30] (4) offset poá†tku ©†dku (pro HEX m¢d)
;                   SS:[BP-31] (1) p©esah tabul†toru na zaá†tku ©†dku
;                   SS:[BP-32] (1) parametry 2
;                                      bit 0: 1=prob°h† zobrazen° bloku
;                                      bit 1: 1=zobraz° se jako okno 2
;                                      bit 2: 1=z†kaz z†pisu do souboru
;                                      bit 4: 1=je to aktivn° okno
;                                      bit 5: 1=blok zobrazen
;                                      bit 6: 1=sloupcovò blok ƒø0=textovò blok
;                                      bit 7: 1=©†dkovò blok   ƒŸ
;                   SS:[BP-36] (4) pozice konce bloku
;                   SS:[BP-40] (4) relativn° ©†dek konce bloku
;                   SS:[BP-44] (4) relativn° pozice konce bloku
;                   SS:[BP-48] (4) pozice zaá†tku bloku
;                   SS:[BP-52] (4) relativn° ©†dek zaá†tku bloku
;                   SS:[BP-56] (4) relativn° pozice zaá†tku bloku
;                   SS:[BP-58] (2) á°taá pozice k zapnut° bloku
;                   SS:[BP-60] (2) á°taá pozice k vypnut° bloku
;                   SS:[BP-62] (2) offset definice okna
;                   SS:[BP-64] (2) á°taá kurzoru pro HEX a BIN m¢d
;                       SS:[BP-63] (1) pozice kurzoru na ©†dku pro textovò m¢d
;                       SS:[BP-64] (1) á°taá ©†dku s kurzorem pro textovò m¢d
;                   SS:[BP-68] (4) á°taá offsetu k zapnut° bloku (BIN a HEX m¢d)
;                   SS:[BP-72] (4) á°taá offsetu k vypnut° bloku (BIN a HEX m¢d)
;                   SS:[BP-74] (2) ®°©ka dat v m¢du BIN a HEX
;                   SS:[BP-76] (2) korekce ASCII pole pro HEX m¢d
;                   SS:[BP-80] (4) ukazatel á°sla ©†dku pro DEMO
; -----------------------------------------------------------------------------

DspNxtEB PROC      NEAR                     ; (n†sleduje za DspNxtEL !)

; ------ £schova registrñ

         push      bx
         push      dx
         push      es

; ------ poskytnut° adresy bloku

         mov       dx,ss:[bp-2]             ; DX <- á°slo segmentu okna
         mov       ds,ss:[bp-4]             ; DS <- datovò segment
         mov       bx,ss:[bp-10]            ; BX <- ukazatel á°sla bloku
         call      EditNGet                 ; poskytnut° adresy bloku
         jnz       DspNxEB2                 ; jsou nàjak† data OK
         xor       cx,cx                    ; nejsou data
         stc                                ; p©°znak chyby nebo konec dat

; ------ uloëen° ukazatelñ

DspNxEB2:mov       ss:[bp-10],bx            ; novò aktu†ln° blok
         mov       ss:[bp-12],es            ; adresa datovÇho bloku
         mov       ss:[bp-14],si            ; ukazatel dat v bloku
         mov       ss:[bp-16],cx            ; poáet bajtñ v bloku
         push      es
         pop       ds                       ; DS <- adresa datovÇho bloku

; ------ n†vrat registrñ

         cld
         pop       es
         pop       dx
         pop       bx
         ret

DspNxtEB ENDP

; -----------------------------------------------------------------------------
;        nalezen° adresy v bufferu pro poá†teán° pozici ©†dku
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=ukazatel dat v bufferu (ukazatel na zaá†tek ©†dku)
;        CX=poáet bajtñ v bloku (0=konec dat)
;        BP=ukazatel lok†ln°ch promànnòch
; VùSTUP: DS:SI=novò ukazatel dat v bufferu
;         CX=novò poáet bajtñ v bloku (0=konec dat nebo konec ©†dku)
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) á°slo segmentu okna
;                   SS:[BP-4] (2) uschovanò datovò segment
;                   SS:[BP-5] (1) ukazatel ©†dku na obrazovce k zobrazen°
;                   SS:[BP-6] (1) poá†teán° pozice okna
;                   SS:[BP-7] (1) á°taá ©†dkñ k zobrazen°
;                   SS:[BP-8] (1) ®°©ka okna
;
;                   SS:[BP-10] (2) ukazatel relativn°ho á°sla bloku
;                   SS:[BP-12] (2) adresa datovÇho bloku
;                   SS:[BP-14] (2) ukazatel dat v bloku (offset)
;                   SS:[BP-16] (2) poáet bajtñ v bloku
;
;                   SS:[BP-20] (4) poá†teán° zobrazen† pozice ©†dku
;                   SS:[BP-21] (1) parametry
;                                      bit 0: 1=jen zobrazen° (bez editace)
;                                      bit 1: 1=HEX m¢d zobrazen° ƒø0=text.
;                                      bit 2: 1=bin†rn° m¢d       ƒŸ  m¢d
;                                      bit 4: 1=nen° ë†dnò znak na ©†dku
;                                      bit 6: 1=je k¢dov†n° pro DEMO
;                                      bit 7: 1=TAB jako bàënò znak
;
;                   SS:[BP-22] (1) barva neaktivn°ho kurzoru
;                   SS:[BP-23] (1) barva ©°dic°ch znakñ
;                   SS:[BP-24] (1) bàën† barva textu
;                   SS:[BP-25] (1) barva bloku v textu
;                   SS:[BP-26] (1) barva indikace p©eteáen°
;
;                   SS:[BP-30] (4) offset poá†tku ©†dku (pro HEX m¢d)
;                   SS:[BP-31] (1) p©esah tabul†toru na zaá†tku ©†dku
;                   SS:[BP-32] (1) parametry 2
;                                      bit 0: 1=prob°h† zobrazen° bloku
;                                      bit 1: 1=zobraz° se jako okno 2
;                                      bit 2: 1=z†kaz z†pisu do souboru
;                                      bit 4: 1=je to aktivn° okno
;                                      bit 5: 1=blok zobrazen
;                                      bit 6: 1=sloupcovò blok ƒø0=textovò blok
;                                      bit 7: 1=©†dkovò blok   ƒŸ
;                   SS:[BP-36] (4) pozice konce bloku
;                   SS:[BP-40] (4) relativn° ©†dek konce bloku
;                   SS:[BP-44] (4) relativn° pozice konce bloku
;                   SS:[BP-48] (4) pozice zaá†tku bloku
;                   SS:[BP-52] (4) relativn° ©†dek zaá†tku bloku
;                   SS:[BP-56] (4) relativn° pozice zaá†tku bloku
;                   SS:[BP-58] (2) á°taá pozice k zapnut° bloku
;                   SS:[BP-60] (2) á°taá pozice k vypnut° bloku
;                   SS:[BP-62] (2) offset definice okna
;                   SS:[BP-64] (2) á°taá kurzoru pro HEX a BIN m¢d
;                       SS:[BP-63] (1) pozice kurzoru na ©†dku pro textovò m¢d
;                       SS:[BP-64] (1) á°taá ©†dku s kurzorem pro textovò m¢d
;                   SS:[BP-68] (4) á°taá offsetu k zapnut° bloku (BIN a HEX m¢d)
;                   SS:[BP-72] (4) á°taá offsetu k vypnut° bloku (BIN a HEX m¢d)
;                   SS:[BP-74] (2) ®°©ka dat v m¢du BIN a HEX
;                   SS:[BP-76] (2) korekce ASCII pole pro HEX m¢d
;                   SS:[BP-80] (4) ukazatel á°sla ©†dku pro DEMO
; -----------------------------------------------------------------------------

EdGetPoz PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      dx
         push      di
         push      es

; ------ relativn° pozice konce bloku

         mov       ax,ss:[bp-36]            ; pozice konce bloku
         mov       bx,ss:[bp-36+2]
         sub       ax,ss:[bp-20]            ; odeáten° poá†teán° pozice
         sbb       bx,ss:[bp-20+2]
         mov       ss:[bp-44],ax            ; relativn° pozice konce bloku
         mov       ss:[bp-44+2],bx

; ------ relativn° pozice zaá†tku bloku

         mov       ax,ss:[bp-48]            ; pozice zaá†tku bloku
         mov       bx,ss:[bp-48+2]
         sub       ax,ss:[bp-20]            ; odeáten° poá†teán° pozice
         sbb       bx,ss:[bp-20+2]
         mov       ss:[bp-56],ax            ; relativn° pozice zaá†tku bloku
         mov       ss:[bp-56+2],bx

; ------ test, zda je poá†tek ©†dku

         mov       byte ptr ss:[bp-31],0    ; nen° p©esah tabul†toru z poá†tku
         jcxz      EdGetPz4                 ; je konec dat
         mov       ax,ss:[bp-20]            ; poá†teán° zobrazen† pozice LOW
         or        ax,ss:[bp-20+2]          ; poá†teán° zobrazen† pozice HIGH
         jz        EdGetPz4                 ; je poá†tek ©†dku OK

; ------ nalezen° adresy v bufferu pro poá†teán° pozici

         mov       dx,ss:[bp-2]             ; á°slo segmentu okna
         mov       ds,ss:[bp-4]             ; datovò segment
         mov       ax,ss:[bp-20]            ; poá†teán° zobrazen† pozice LOW
         mov       cx,ss:[bp-20+2]          ; poá†teán° zobrazen† pozice HIGH
         mov       bx,ss:[bp-10]            ; á°slo bloku
         call      EditGetP                 ; poskytnut° pozice v bufferu
         mov       cx,0                     ; CX <- 0 nejsou dal®° data
         jc        EdGetPz2                 ; chyba

; ------ p©esah tabul†toru

         mov       ax,di                    ; AX <- p©esah tabul†toru
         or        ax,ax                    ; je konec ©†dku ?
         jns       EdGetPz1                 ; nen° konec ©†dku
         xor       ax,ax                    ; je konec ©†dku
EdGetPz1:mov       ss:[bp-31],al            ; p©esah tabul†toru

; ------ nov† adresa dat v bufferu

         call      EditNGet                 ; poskytnut° adresy bloku
         mov       ss:[bp-10],bx            ; á°slo bloku
         mov       ss:[bp-12],es            ; adresa bloku
         mov       ss:[bp-14],si            ; ukazatel dat v bloku
EdGetPz2:mov       ss:[bp-16],cx            ; poáet bajtñ v bloku

; ------ korekce, je-li konec ©†dku

         or        di,di                    ; je konec ©†dku ?
         jns       EdGetPz3                 ; nen° konec ©†dku
         xor       cx,cx                    ; p©°znak konce ©†dku
EdGetPz3:push      es
         pop       ds                       ; DS <- segment bufferu

; ------ n†vrat registrñ

EdGetPz4:pop       es
         pop       di
         pop       dx
         pop       bx
         pop       ax
         ret

EdGetPoz ENDP

; -----------------------------------------------------------------------------
;        zobrazen° nadpisu okna AX editoru (bit 15: 1=zobraz° se jako okno 2)
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) á°slo segmentu okna (bit 15: 1=je okno 2)
;                   SS:[BP-4] (2) adresa segmentu okna
;                   SS:[BP-5] (1) parametry
;                                    bit 0: 1=soubor modifikov†n
;                                    bit 1: 1=je aktivn° okno
;                                    bit 2: 1=z†kaz z†pisu
;                                    bit 3: 1=je editace (nen° zobrazen°)
;                                    bit 4: 1=©†dek a pozice, 0=ukazatel
;                                    bit 5:    1=29 pozic, 0=14 pozic
;                                    bit 6: 1=zobraz° se offset v souboru
;                                    bit 7: 1=zobraz° se áas (10 pozic)
;                   SS:[BP-6] (1) dÇlka ©†dku (pro zobrazen° - pozic)
;                   SS:[BP-8] (2) ©†dek a pozice k zobrazen°
;                   SS:[BP-9] (1) zvòraznàn† barva
;                   SS:[BP-10] (1) á°slo okna 1...99
;                   SS:[BP-12] (2) offset definice okna
; -----------------------------------------------------------------------------

DispENad PROC      NEAR

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
         sub       sp,12                    ; lok†ln° promànnÇ

; ------ ukazatel definice okna

         mov       bx,EdiW1                 ; definice okna 1
         or        ax,ax                    ; je okno 2 ?
         jns       DispEN11                 ; je okno 1
         mov       bx,EdiW2                 ; definice okna 2
DispEN11:mov       ss:[bp-12],bx            ; offset definice okna

; ------ rozli®en°, zda to je aktivn° okno

         mov       cl,0                     ; nen° aktivn° okno
         mov       dh,ds:[ColEdi1]          ; bàën† barva
         cmp       ax,ds:[EdiSAkt]          ; je to aktivn° okno ?
         jne       DispEN12                 ; nen° to aktivn° okno
         mov       cl,bit1                  ; p©°znak aktivn°ho okna
         mov       dh,ds:[ColEdi2]          ; zvòraznàn† barva

DispEN12:mov       ss:[bp-5],cl             ; p©°znaky okna
         mov       ss:[bp-9],dh             ; zvòraznàn† barva

; ------ adresa okna

         mov       ss:[bp-2],ax             ; £schova á°sla segmentu okna
         and       ah,not bit15/bit8        ; nulov†n° p©°znaku okna 2
         call      far ptr GetDat           ; adresa definice okna
         mov       ss:[bp-4],es             ; adresa segmentu okna

; ------ p©°znak modifikace souboru a p©°znak z†kazu z†pisu

         mov       cl,es:[EdiParm]          ; parametry okna
         and       cl,bit0+bit2             ; p©°znak modifikace a prohl°ëeáe
         or        ss:[bp-5],cl             ; dal®° p©°znaky

; ------ p©°znak zobrazen° áasu (10 pozic)

         cmp       byte ptr es:[bx+EdiRad],0 ; je ©†dek 0 ?
         jne       DispEn14                 ; nen° ©†dek 0
         mov       al,es:[bx+EdiPoz]        ; poá†teán° pozice
         add       al,es:[bx+EdiSir]        ; koncov† pozice
         cmp       al,ds:[MaxPoz]           ; je to pravÇ okno ?
         jb        DispEn14                 ; nen° to pravÇ okno

         and       byte ptr ds:[EditPar2],not bit7 ; áas se nezobraz°

         cmp       byte ptr es:[bx+EdiSir],80 ; je dostateán† ®°©ka ?
         jb        DispEn14                 ; je mal† ®°©ka

         or        byte ptr ss:[bp-5],bit7  ; áas se zobraz°
         or        byte ptr ds:[EditPar2],bit7 ; áas se zobraz°

; ------ test, zda se zobraz° offset

DispEn14:test      byte ptr es:[bx+EdiParm1],bit0 ; je jen zobrazen° ?
         jnz       DispEn16                 ; je jen zobrazen°
         or        byte ptr ss:[bp-5],bit3+bit6 ; offset se zobraz° + je editace

; ------ test, zda se zobraz° ukazatel (jinak bude ©†dek a pozice)

DispEn16:test      byte ptr es:[bx+EdiParm1],bit0+bit1+bit2 ; zobr./bin†rn°/HEX ?
         jnz       DispEn17                 ; v tàchto m¢dech se nezobraz° pozice
         or        byte ptr ss:[bp-5],bit4  ; ©†dek a pozice s textem

; ------ ®°©ka zobrazen° ukazatele

DispEn17:cmp       byte ptr es:[bx+EdiSir],65 ; asi tak minim†ln° ®°©ka
         jb        DispEn18                 ; mal† ®°©ka ©†dku
         or        byte ptr ss:[bp-5],bit5  ; dlouhò £daj

; ------ buffer pro dek¢dov†n° ©†dku (minim†lnà 80 pozic) -> CX=dÇlka bufferu

DispEN18:mov       cl,es:[bx+EdiSir]        ; ®°©ka okna
         mov       ch,0
         mov       ss:[bp-6],cl             ; dÇlka ©†dku
         cmp       cl,80                    ; minim†ln° ®°©ka okna
         ja        DispENd1                 ; ®°©ka okna je OK
         mov       cl,80                    ; omezen° minim†ln° ®°©ky okna
DispENd1:sub       sp,cx
         sub       sp,cx                    ; buffer v z†sobn°ku

; ------ p©°prava parametrñ okna

         mov       ax,word ptr es:[bx+EdiPoz] ; pozice a ©†dek poá†tku okna
         mov       ss:[bp-8],ax             ; pozice a ©†dek k zobrazen°

         mov       ax,ds:[EdiWAkt]          ; á°slo souboru aktivn°ho okna
         test      byte ptr ss:[bp-5],bit1  ; je to aktivn° okno ?
         jnz       DispEN21                 ; je to aktivn° okno
         mov       ax,ds:[EdiWNAkt]         ; jinak á°slo neaktivn°ho okna
DispEN21:cmp       ax,100                   ; maxim†ln° á°slo okna
         jb        DispEN22                 ; á°slo okna je OK
         mov       al,99                    ; omezen° á°sla okna
DispEN22:mov       ss:[bp-10],al            ; á°slo okna

; ------ vymaz†n° ©†dku v z†sobn°ku (CX=dÇlka bufferu)

         push      ss
         pop       es                       ; ES <- segment bufferu
         mov       di,sp                    ; DI <- buffer k dek¢dov†n° textu
         mov       ah,ds:[ColEdi1]          ; barva informaán°ho ©†dku
         mov       al," "
         cld
         rep       stosw                    ; vymaz†n° zbytku ©†dku

; ------ test, zda se zobraz° p©°znak Ctrl- (AH=bàën† barva textu)

         mov       di,sp                    ; DI <- buffer
         cmp       byte ptr ss:[bp-6],80-10 ; je dostateán† ®°©ka ?
         jb        DispEn32                 ; je mal† ®°©ka

; ------ dek¢dov†n° p©°kazu Ctrl-

         call      DispENNO                 ; oddàlovac° á†ra
         test      byte ptr ss:[bp-5],bit1  ; je to aktivn° okno ?
         jz        DispENd3                 ; nen° to aktivn° okno
         mov       al,ds:[EditPrik]         ; p©°kaz
         cmp       al,0                     ; je nàjakò p©°kaz ?
         je        DispENd3                 ; nen° ë†dnò p©°kaz
         mov       byte ptr es:[di],"^"
         add       al,"@"                   ; korekce na znak ASCII
         cmp       al,"*"
         jne       DispEN31                 ; nen° p©°znak hled†n°
         mov       es:[di],al
DispEN31:mov       es:[di+2],al             ; oznaáen° p©°kazu
DispENd3:add       di,2*3                   ; zvò®en° ukl†dac° adresy
         call      DispENNO                 ; oddàlovac° á†ra

; ------ dek¢dov†n° p©°znaku editace souboru

DispEn32:cmp       byte ptr ss:[bp-6],3     ; je dostateán† ®°©ka ?
         jb        DispEN41                 ; je mal† ®°©ka
         mov       al,"x"                   ; oznaáen° z†kazu z†pisu
         test      byte ptr ss:[bp-5],bit2  ; je z†kaz z†pisu ?
         jnz       DispENd4                 ; je z†kaz z†pisu
         mov       al,"!"                   ; soubor modifikov†n
         test      byte ptr ss:[bp-5],bit0  ; je soubor modifikov†n ?
         jnz       DispENd4                 ; soubor je modifikov†n
         mov       al," "                   ; jinak nic
DispENd4:stosw                              ; uloëen° p©°znaku modifikace

; ------ dek¢dov†n° á°sla okna (AH=bàën† barva)

DispEN41:push      ax

         mov       al,ss:[bp-10]            ; á°slo okna
         aam                                ; rozdàlen° na á°slice
         add       ax,"00"                  ; á°slo okna
         mov       cl,al                    ; CL <- á°slice LOW
         mov       al,ah                    ; AL <- á°slice HIGH
         cmp       al,"0"
         jne       DispEN42
         mov       al," "                   ; nula se nezobraz°
DispEN42:mov       ah,ss:[bp-9]             ; zvòraznàn† barva
         stosw                              ; prvn° á°slice
         mov       al,cl
         stosw                              ; druh† á°slice

         pop       ax                       ; AH = bàën† barva

; ------ oddàlovac° á†ra

         call      DispENNO                 ; oddàlovac° á†ra

; ------ test, zda se zobraz° jmÇno souboru

         cmp       byte ptr ss:[bp-6],50    ; je dostateán† ®°©ka ?
         jb        DispEnd6                 ; je mal† ®°©ka

; ------ dek¢dov†n° jmÇna souboru

         push      di
         push      ds

         mov       ds,ss:[bp-4]             ; adresa segmentu okna
         mov       si,EdiSoub               ; zaá†tek specifikace souboru
         add       si,ds:[EdiSoubJ]         ; adresa zaá†tku jmÇna souboru
         mov       cx,ds:[EdiSoubN]         ; celkov† dÇlka specifikace
         sub       cx,ds:[EdiSoubJ]         ; dÇlka jmÇna souboru
         jbe       DispEN52                 ; je mal† dÇlka
DispENd5:lodsb
         stosw
         loop      DispENd5                 ; dal®° znak

DispEN52:pop       ds
         pop       di
         add       di,12*2

; ------ oddàlovac° á†ra

         call      DispENNO                 ; oddàlovac° á†ra

; ------ test, zda se zobraz° znak pod kurzorem (AH=bàën† barva)

DispENd6:test      byte ptr ss:[bp-5],bit3  ; je editace souboru ?
         jz        DispE601                 ; nen° editace souboru
         cmp       byte ptr ss:[bp-6],22    ; je dostateán† ®°©ka ?
         jae       DispEN60                 ; je dostateán† ®°©ka
DispE601:jmp       DispEn67                 ; je mal† ®°©ka

; ------ znak pod kurzorem -> AL (n†sleduj°c° znak -> AH)

DispEN60:add       di,2*3                   ; konec textu znaku pod kurzorem

         push      ax                       ; AH = bàën† barva

         mov       dx,ss:[bp-2]             ; á°slo segmentu okna
         mov       es,ss:[bp-4]             ; adresa segmentu okna
         mov       si,ss:[bp-12]            ; offset definice okna
         mov       bx,es:[si+EdiBBKur]      ; blok s kurzorem
         mov       si,es:[si+EdiOfKur]      ; offset kurzoru v bloku
         inc       si                       ; n†sleduj°c° znak
         call      EdiGetCh                 ; znak za kurzorem
         mov       ah,al                    ; £schova znaku
         dec       si                       ; n†vrat pozice
         call      EdiGetCh                 ; znak pod kurzorem
         mov       ss:[bp-4],es             ; nov† adresa segmentu okna

         pop       bx                       ; BH <- bàën† barva

; ------ p©°prava poátu ©†dkñ (DX=á°slo okna) -> DX:AX (BH=bàën† barva)

         push      ax                       ; znak pod kurzorem + n†sleduj°c°

         call      EdiGetCL                 ; poskytnut° celkovÇho poátu ©†dkñ
         mov       dx,cx                    ; poáet ©†dkñ HIGH

; ------ test, zda je kurzor za koncem souboru

         xor       cx,cx                    ; p©°znak - je posledn° ©†dek
         mov       si,ss:[bp-12]            ; offset definice okna
         cmp       dx,word ptr es:[si+EdiRKur+2] ; je to platnò ©†dek ?
         jne       DispEN61
         cmp       ax,word ptr es:[si+EdiRKur]
DispEN61:pop       ax                       ; AX <- 2 znaky pod kurzorem

         jb        DispEN63                 ; konec souboru
         je        DispE612                 ; je posledn° ©†dek
         inc       cx                       ; p©°znak - nen° posledn° ©†dek

; ------ test, zda je kurzor za koncem ©†dku (SI=offset definice okna)

DispE612:xchg      si,di                    ; DI <- offset definice okna
         call      EditCmKL                 ; porovn†n° pozice kurzoru s dÇlkou ©†dku
         xchg      si,di                    ; SI <- n†vrat offsetu definice okna
         jb        DispEN65                 ; je platnò znak
         jcxz      DispEN63                 ; je posledn° ©†dek - konec souboru
         mov       si,offset EOLTxt         ; text - konec ©†dku
         ja        DispEN64                 ; konec ©†dku

; ------ rozli®en° konce ©†dku

         mov       si,offset CRLFTxt        ; 'CRL'
         cmp       ax,LF*HI + CR
         je        DispEN64
         mov       si,offset LFCRTxt        ; 'LFC'
         cmp       ax,CR*HI + LF
         je        DispEN64
         mov       si,offset LFTxt          ; 'LF'
         cmp       al,LF
         je        DispEN64
DispEN63:mov       si,offset EOFTxt         ; text - konec souboru

; ------ zobraz° se text DS:SI

DispEN64:push      ss
         pop       es                       ; ES <- segment bufferu
         cld
         sub       di,2*3
         mov       ah,bh                    ; barva informaán°ho ©†dku
         lodsb
         stosw
         lodsb
         stosw
         lodsb
         stosw
         jmp       short DispEN66

; ------ test, zda je tabul†tor (SI=offset definice okna)

DispEN65:test      byte ptr es:[si+EdiParm2],bit0 ; odskok tabul†toru ?
         mov       si,offset TbTxt          ; '>>>'
         jnz       DispEN64                 ; je odskok tabul†toru
         mov       si,offset TabTxt         ; 'TAB'
         cmp       al,TAB
         je        DispEN64                 ; je tabul†tor

; ------ zobraz° se á°slo znaku AL (BH=barva, na BL nez†leë°)

         push      ss
         pop       es                       ; ES <- segment bufferu
         xor       dx,dx                    ; DX <- 0  á°slo HIGH
         mov       ah,0
         call      far ptr DekNumD          ; dek¢dov†n° bajtu pod kurzorem

; ------ oddàlovac° á†ra

DispEN66:call      DispENNO                 ; oddàlovac° á†ra

; ------ test, zda se zobraz° ukazatel (AH=bàën† barva)

DispEN67:cmp       byte ptr ss:[bp-6],18    ; je dostateán† ®°©ka ?
         jb        DispEN72                 ; je mal† ®°©ka

         test      byte ptr ss:[bp-5],bit4  ; zobraz° se ©†dek a pozice ?
         jz        DispEN73                 ; zobraz° se ukazatel

; ------ zobrazen° á°sla aktu†ln°ho ©†dku (14+1 pozic)

         mov       si,ss:[bp-12]            ; offset definice okna
         mov       es,ss:[bp-4]             ; adresa segmentu okna
         mov       ax,word ptr es:[si+EdiRKur] ; aktivn° ©†dek LOW
         mov       dx,word ptr es:[si+EdiRKur+2] ; aktivn° ©†dek HIGH
         mov       si,offset EdNadTx1       ; text nadpisu "û†dek"
         call      DispENN1                 ; zobrazen° á°sla ©†dku

; ------ test, zda se zobraz° i pozice

         test      byte ptr ss:[bp-5],bit5  ; je mal† ®°©ka ?
         jz        DispEN72                 ; je mal† ®°©ka

; ------ dek¢dov†n° á°sla aktu†ln° pozice (14+1 pozic)

         mov       si,ss:[bp-12]            ; offset definice okna
         mov       es,ss:[bp-4]             ; adresa segmentu okna
         mov       ax,word ptr es:[si+EdiPKur] ; pozice kurzoru na ©†dku LOW
         mov       dx,word ptr es:[si+EdiPKur+2] ; pozice kurzoru na ©†dku HIGH
         mov       si,offset EdNadTx2       ; text nadpisu "Pozice"
         call      DispENN1                 ; zobrazen° á°sla pozice
DispEN72:jmp       short DispEN77

; ------ p©°prava dÇlky ukazatele

DispEN73:mov       si,14                    ; mal† ®°©ka ukazatele
         test      byte ptr ss:[bp-5],bit5  ; je mal† ®°©ka ?
         jz        DispEN74                 ; je mal† ®°©ka
         mov       si,29                    ; velk† ®°©ka ukazatele

; ------ inicializaán° vymaz†n° pole (AH=bàën† barva)

DispEN74:mov       cx,si                    ; CX <- dÇlka ukazatele
         mov       al,"∞"
         cld
         rep       stosw                    ; vymaz†n° pole

; ------ offset kurzoru -> DX:AX (radàji poá†tek okna - kurzor je skrytò)

         push      si
         mov       es,ss:[bp-4]             ; adresa segmentu okna
         mov       si,ss:[bp-12]            ; adresa definice okna
         mov       ax,word ptr es:[si+EdiOffsT] ; offset poá†tku okna
         mov       dx,word ptr es:[si+EdiOffsT+2]
         pop       si

; ------ velikost souboru -> BX:CX

         mov       cx,word ptr es:[EdiSize] ; velikost souboru
         mov       bx,word ptr es:[EdiSize+2]

; ------ omezen° offsetu kurzoru

         cmp       dx,bx
         jne       DispE752
         cmp       ax,cx
DispE752:jbe       DispE754                 ; offset je OK
         mov       ax,cx                    ; omezen° na konec souboru
         mov       dx,bx

; ------ normalizace ukazatelñ -> AX/CX

DispE754:or        bx,bx                    ; je jië < 64 KB ?
         jz        DispE756
         shr       bx,1                     ; velikost BX:CX / 2
         rcr       cx,1
         shr       dx,1                     ; poá†tek DX:AX / 2
         rcr       ax,1
         jmp       short DispE754

; ------ vòpoáet offsetu kurzoru -> AX

DispE756:or        cx,cx                    ; je velikost = 0 ?
         jnz       DispE757                 ; velikost nen° = 0
         inc       cx                       ; minim†ln° velikost = 1
DispE757:mul       si                       ; kurzor * dÇlka
         div       cx                       ; kurzor relativnà

; ------ dek¢dov†n° kurzoru

         push      ss
         pop       es                       ; ES <- segment bufferu
         push      di                       ; konec bufferu
         sub       di,si
         sub       di,si                    ; DI <- poá†tek bufferu
         cmp       ax,si                    ; je kurzor je®tà v poli ukazatele ?
         jb        DispE763                 ; kurzor je je®tà OK
         mov       ax,si                    ; AX <- omezen° kurzoru
         dec       ax                       ; posledn° znak pole
DispE763:add       di,ax
         add       di,ax                    ; DI <- pozice kurzoru
         mov       byte ptr es:[di],"≤"     ; oznaáen° kurzoru
         pop       di                       ; konec bufferu

         call      DispENNO                 ; oddàlovac° á†ra

; ------ dek¢dov†n° offsetu aktu†ln° pozice nebo velikosti souboru

DispEN77:cmp       byte ptr ss:[bp-6],37    ; je dostateán† ®°©ka ?
         jb        DispEN78                 ; je mal† ®°©ka

         mov       es,ss:[bp-4]             ; adresa segmentu okna
         mov       si,ss:[bp-12]            ; offset definice okna
         mov       ax,word ptr es:[si+EdiOffsK] ; offset kurzoru v souboru LOW
         mov       dx,word ptr es:[si+EdiOffsK+2] ; offset kurzoru v souboru HIGH
         mov       si,offset EdNadTx3       ; text "offset:"
         test      byte ptr ss:[bp-5],bit6  ; zobraz° se offset ?
         jnz       DispE774                 ; zobraz° se offset
         mov       si,offset EdNadTx4       ; text "dÇlka:"
         mov       ax,word ptr es:[EdiSize] ; velikost souboru LOW
         mov       dx,word ptr es:[EdiSize+2] ; velikost souboru HIGH
DispE774:call      DispENN2                 ; dek¢dov†n° offsetu/velikosti
         mov       byte ptr es:[di-2]," "   ; zru®en° oddàlovac° á†ry

; ------ dek¢dov†n° aktu†ln°ho áasu

DispEN78:test      byte ptr ss:[bp-5],bit7  ; zobraz° se áas ?
         jz        DispENd8                 ; nezobraz° se

         lea       di,ss:[bp-12-2*10]       ; buffer k dek¢dov†n° áasu
         call      DispENNO                 ; oddàlovac° á†ra
         call      far ptr DekSTime         ; dek¢dov†n° systÇmovÇho áasu
         call      DispENNO                 ; oddàlovac° á†ra

; ------ zobrazen° dek¢dovanÇho ©†dku

DispENd8:mov       si,sp
         mov       cl,ss:[bp-6]             ; dÇlka ©†dku okna
         xor       ax,ax                    ; nulov† hladina k zobrazen°
         mov       dx,ss:[bp-8]             ; pozice a ©†dek k zobrazen°
         or        dh,dh                    ; je ©†dek 0 ?
         jnz       DispENd9                 ; nen° ©†dek 0
         test      byte ptr ds:[ParMenu],bit1 ; zobrazeno hlavn° menu ?
         jnz       DispENdA                 ; je hlavn° menu - nezobraz° se
DispENd9:call      far ptr DispMStr         ; zobrazen° ©†dku nadpisu

; ------ n†vrat registrñ

DispENdA:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispENad ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° á°sla DX:AX do bufferu SS:DI (£vodn° text DS:SI) - 14 pozic
; -----------------------------------------------------------------------------

; ------ korekce pro ©†dek a pozici

DispENN1:add       ax,1                     ; korekce - ©†dek + 1
         adc       dx,0

DispENN2:push      ss
         pop       es                       ; ES <- segment bufferu

; ------ dek¢dov†n° textu (7 pozic)

         cld
         mov       cx,7                     ; dÇlka textu
         push      ax

         mov       ah,ds:[ColEdi1]          ; barva informaán°ho ©†dku
DispENN3:lodsb                              ; naáten° znaku
         cmp       al,128                   ; je diakritika ?
         jb        DspENN32                 ; nen° diakritika
         call      far ptr KonvFChr         ; konverze k¢du znaku
DspENN32:stosw
         loop      DispENN3

         pop       ax
         add       di,2*7                   ; pozice pro dek¢dov†n° á°sla

; ------ test, zda je pot©eba zkr†tit text (4+10 nebo 7+7 - max. 999.999)

         cmp       dx,15                    ; 999.999 HIGH
         jne       DispENN4
         cmp       ax,16959                 ; 999.999 LOW
DispENN4:jbe       DispENN5                 ; á°slo je OK < 999.999

; ------ zkr†cen° textu

         mov       byte ptr es:[di-2*11],"."
         mov       byte ptr es:[di-2*11+2]," "
         mov       byte ptr es:[di-2*11+4]," "

; ------ dek¢dov†n° á°sla do bufferu

DispENN5:mov       bh,ss:[bp-9]             ; zvòraznàn† barva
         mov       bl,ds:[OddelRad]         ; znak oddàlovaáe ©†dñ
         call      far ptr Dek10Num         ; dek¢dov†n° á°sla

; ------ dek¢dov†n° oddàlovac°ho znaku

DispENNO:cld
         mov       ah,ds:[ColEdi1]          ; AH <- bàën† barva
         mov       al,"≥"
         stosw
         ret

; -----------------------------------------------------------------------------
;        zobrazen° aktivn°ho okna
; -----------------------------------------------------------------------------

DispEdiA PROC      NEAR

         push      ax
         mov       ax,ds:[EdiSAkt]          ; segment aktivn°ho okna
         call      DispEdi                  ; zobrazen° okna
         xor       ah,bit15/bit8            ; zmàna p©°znaku okna
         cmp       ax,ds:[EdiSNAkt]         ; je to i neaktivn° okno ?
         jne       DispEdA3                 ; nen° to neaktivn° okno
         test      byte ptr ds:[EditPar2],bit4 ; jsou 2 okna ?
         jz        DispEdA3                 ; nejsou 2 okna
         call      DispEdi                  ; zobrazen° neaktivn°ho okna
DispEdA3:pop       ax
         ret

DispEdiA ENDP

; *****************************************************************************
;                               DispAEdi
;                     zobrazen° v®ech oken editoru
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

DispAEdi PROC      FAR

; ------ £schova registrñ

         push      ax
         push      dx

; ------ p©°prava segmentñ oken

         and       byte ptr ds:[EditPar2],not bit7 ; áas se nezobraz°

         mov       ax,ds:[EdiS1Win]         ; okno 1
         mov       dx,ds:[EdiS2Win]         ; okno 2
         or        dh,bit15/bit8            ; p©°znak okna 2
         test      byte ptr ds:[EditPar2],bit6 ; je aktivn° okno 2 ?
         jz        DispAEd2                 ; nen° aktivn° okno 2
         xchg      ax,dx                    ; z†màna oken

; ------ zobrazen° aktivn°ho okna

DispAEd2:call      DispEdi                  ; zobrazen° aktivn°ho okna

; ------ zobrazen° neaktivn°ho okna

         test      byte ptr ds:[EditPar2],bit4 ; zobraz° se 2 okna ?
         jz        DispAEd9                 ; zobraz° se jen 1 okno
         xchg      ax,dx                    ; AX <- neaktivn° okno
         call      DispEdi                  ; zobrazen° neaktivn°ho okna

; ------ test, zda je vertik†ln° reëim

         test      byte ptr ds:[EditPar2],bit5 ; jsou vertik†ln° okna ?
         jz        DispAEd9                 ; nejsou vertik†ln° okna

; ------ £schova registrñ 2

         push      cx
         push      si
         push      es

; ------ adresa okna 1

         mov       ax,ds:[EdiS1Win]         ; segment okna 1
         call      far ptr GetDat           ; adresa okna 1
         jc        DispAEd8                 ; nàjak† chyba

; ------ parametry k zobrazen° oddàlovac° á†ry

         mov       dx,word ptr es:[EdiW1+EdiPoz] ; ©†dek a pozice okna 1
         add       dl,es:[EdiW1+EdiSir]     ; pozice za koncem okna 1
         mov       ch,es:[EdiW1+EdiVys]     ; vò®ka okna 1

; ------ zobrazen° oddàlovac° á†ry

         mov       si,offset DispAEdT       ; buffer znaku k zobrazen°
         push      cs
         pop       es                       ; ES <- segment textu k zobrazen°
         mov       cl,1                     ; zobraz° se 1 znak
DispAEd3:mov       al,ds:[ColEdi1]          ; barva informaán°ho ©†dku
         mov       byte ptr cs:[si+1],al    ; barva znaku
         xor       ax,ax                    ; hladina k zobrazen°
         call      far ptr DispMStr         ; zobrazen° znaku
         dec       dx                       ; n†vrat pozice znaku
         inc       dh                       ; zvò®en° ukazatele ©†dku
         dec       ch                       ; á°taá ©†dkñ k zobrazen°
         jnz       DispAEd3                 ; zobrazen° znaku na dal®°m ©†dku

; ------ n†vrat registrñ 2

DispAEd8:pop       es
         pop       si
         pop       cx

; ------ n†vrat registrñ

DispAEd9:pop       dx
         pop       ax
         ret

DispAEdi ENDP

DispAEdT dw        '∞'                      ; znak oddàlovac° á†ry + barva (!)

; -----------------------------------------------------------------------------
;        zobrazen° kurzoru v oknà AX
; -----------------------------------------------------------------------------

DispKEdi PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      dx
         push      si
         push      es

; ------ definice okna 1/2 -> SI

         or        ax,ax                    ; je okno 2 ?
         mov       si,EdiW1                 ; okno 1
         jns       DispKEd1                 ; je okno 1
         mov       si,EdiW2                 ; okno 2

; ------ test, zda to je aktivn° okno (pro neaktivn° okno nen° kurzor)

DispKEd1:cmp       ax,ds:[EdiSAkt]          ; je to aktivn° okno ?
         jne       DispKEd3                 ; nen° to aktivn° okno

; ------ adresa aktivn°ho okna -> ES

         and       ah,not bit15/bit8        ; nulov†n° p©°znaku okna 2
         call      far ptr GetDat           ; adresa okna -> ES

; ------ vypnut° kurzoru, nen°-li m¢d editace

         test      byte ptr es:[si+EdiParm1],bit0 ; je m¢d editace ?
         jz        DispKEd4                 ; je editace
         call      far ptr KurzOff          ; vypnut° kurzoru
DispKEd3:jmp       DispKEd9

; ------ zobrazen° kurzoru

DispKEd4:mov       dx,word ptr es:[si+EdiPKurR] ; relativn° pozice a ©†dek kurzoru
         add       dh,es:[si+EdiRad]           ; p©iáten° poá†teán°ho ©†dku
         inc       dh                          ; p©eskoáen° ©†dku nadpisu

; ------ korekce pro HEX m¢d

         test      byte ptr es:[si+EdiParm1],bit1 ; je HEX m¢d ?
         jz        DispKEd6                 ; nen° HEX m¢d

         test      byte ptr es:[si+EdiParm2],bit2 ; je ASCII á†st HEX pole ?
         jz        DispKE44                 ; nen° ASCII á†st
         add       dl,1 + 9 + 1 + 16*2+15*1+3*1+1 + 1 ; korekce na ASCII pole
         cmp       byte ptr es:[si+EdiSir],80 ; je dostateán† ®°©ka okna ?
         jae       DispKEd6                 ; je dostateán† ®°©ka okna
         sub       dl,(1 + 9 + 1 + 16*2+15*1+3*1+1 + 1) - (7+1) ; n†vrat + 8
         mov       al,byte ptr es:[si+EdiLSir] ; ®°©ka dat
         add       dl,al
         shl       al,1
         add       dl,al                    ; + ®°©ka dat * 3 (tj. pro HEX)
         cmp       byte ptr es:[si+EdiSir],7+1+2+1+1 ; minim†ln° ®°©ka okna
         jae       DispKEd6                 ; ®°©ka okna je OK
         sub       dl,7+1                   ; odeáten° pole offsetu
         jmp       short DispKEd6

DispKE44:mov       al,dl                    ; pozice (0...15)
         shl       al,1
         add       dl,al                    ; korekce pozice (=offset * 3)
         cmp       byte ptr es:[si+EdiSir],7+1+2+1+1 ; minim†ln° ®°©ka okna
         jb        DispKEd5                 ; je mal† ®°©ka okna
         add       dl,7+1                   ; korekce pro kr†tkò ©†dek
         cmp       byte ptr es:[si+EdiSir],80 ; je dostateán† ®°©ka okna ?
         jb        DispKEd5                 ; je mal† ®°©ka okna
         add       dl,3                     ; + poá†teán° pozice
         shr       al,1                     ; pozice
         shr       al,1
         shr       al,1                     ; offset / 4
         add       dl,al                    ; korekce pro kaëdò 4. bajt
         shr       al,1                     ; offset / 8
         add       dl,al                    ; korekce pro kaëdò 8. bajt
DispKEd5:test      byte ptr es:[si+EdiParm2],bit1 ; je druhò znak HEX pole ?
         jz        DispKEd6                 ; nen° druhò znak HEX pole
         inc       dx                       ; oprava pozice kurzoru
DispKEd6:add       dl,es:[si+EdiPoz]        ; p©iáten° poá†teán° pozice
         call      far ptr SetKurz          ; zobrazen° kurzoru

; ------ nastaven° velikosti kurzoru

         test      byte ptr es:[si+EdiParm1],bit1 ; je HEX m¢d ?
         jnz       DispKEd7                 ; pro HEX m¢d je INSERT vëdy vypnutò
         test      byte ptr ds:[EditParm],bit5 ; je zapnut INSERT ?
         jnz       DispKEd8                 ; je zapnut INSERT
DispKEd7:call      far ptr SizeHKur         ; nastaven° vysokÇho kurzoru
         jmp       short DispKEd9

DispKEd8:call      far ptr SizeLKur         ; nastaven° n°zkÇho kurzoru

; ------ n†vrat registrñ

DispKEd9:pop       es
         pop       si
         pop       dx
         pop       ax
         ret

DispKEdi ENDP

CodeEdi  ENDS

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;
;                                 Data
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
Data     SEGMENT

; -----------------------------------------------------------------------------
;        Definice hlavn°ho menu editoru
; -----------------------------------------------------------------------------

EMnuMain label     byte                   ;* hlavn° adres†©ovÇ menu

         db        0                        ; typ menu - hlavn° menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        7                        ; poáet poloëek v menu
         dw        7                        ; celkovò poáet poloëek v menu

         dw        EMnuMPol                 ; adresa definice poloëek menu
         dw        EMnuMHlp                 ; adresa textñ n†povàd
         dw        Hlp@HlavniMenuEditoru    ; á°slo str†nky velkÇ n†povàdy
         dw        EMnuMBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ (0=nen°)
         dw        0                        ; adresa titulu okna (0=nen°)
         dw        EMnuMExe                 ; tabulka obsluh voleb menu
         dw        EMnuMMnu                 ; tabulka odvozenòch menu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        11                       ; poá†teán° pozice okna menu
         db        0                        ; poá†teán° ©†dek okna menu
         db        80                       ; ®°©ka okna menu
         db        1                        ; vò®ka okna menu

         db        0                        ; levò okraj menu
         db        0                        ; mezera na okraji poloëky
         db        0                        ; oddàlovac° mezera mezi poloëkami
         db        0                        ; pravò okraj menu
         db        0                        ; omezen° dÇlky poloëky

EMnuMPol db        1,6,'Soubor'
         db        1,4,'Blok'
         db        1,7,'Editace'
         db        1,6,'Kurzor'
         db        1,5,'Volby'
         db        1,8,'Zvl†®tn°'
         db        1,8,'N†povàda'

EMnuMBlk db        0,0,0,0,0,0,0            ; blokovac° tabulka poloëek

HelpS    SEGMENT   BYTE PUBLIC
EMnuMHlp db        59,'Operace se soubory - otev©en°, uloëen°, uzav©en°, p©eru®en°'
         db        59,'Operace s blokem textu - oznaáen°, kop°rov†n°, uloëen°, ...'
         db        50,'Editace (modifikace) textu - ru®en°, vkl†d†n°, ...'
         db        45,'Zmàna pozice kurzoru, znaáky, hled†n°, z†màna'
         db        50,'Nastaven° p©ep°naáñ a voleb editoru, ovl†d†n° oken'
         db        46,'Zvl†®tn° funkce - kalkul†tor, datab†ze, hodiny'
         db        28,'N†povàda k textovÇmu editoru'
HelpS    ENDS

EMnuMExe label     dword                    ; tabulka obsluh voleb menu
         dd        EditSMn                  ; Soubor
         dd        EditBMn                  ; Blok
         dd        EditEMn                  ; Editace
         dd        EditKMn                  ; Kurzor
         dd        EditVMn                  ; Volby
         dd        EditZMn                  ; Zvl†®tn°
         dd        AWMMnuN                  ; n†povàda

EMnuMMnu label     word                     ; adresy definic podmenu
         dw        ESMnVert                 ; soubor
         dw        EBMnVert                 ; blok
         dw        EEMnVert                 ; editace
         dw        EKMnVert                 ; Kurzor
         dw        EVMnVert                 ; volby
         dw        ZMnuVert                 ; Zvl†®tn°
         dw        NMnuVert                 ; n†povàda

; -----------------------------------------------------------------------------
;        Definice vertik†ln°ho menu - obsluha souborñ
; -----------------------------------------------------------------------------

ESMnVert label     byte                   ;* menu souborñ

         db        1                        ; typ menu - vertik†ln° menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        9                        ; poáet platnòch poloëek menu
         dw        11                       ; celkovò poáet poloëek menu

         dw        ESMnVPol                 ; adresa definice poloëek menu
         dw        ESMnVHlp                 ; adresa n†povàd
         dw        Hlp@PodmenuEditoruSoubor ; á°slo str†nky velkÇ n†povàdy
         dw        ESMnVBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        ESMnVTit                 ; adresa titulu okna
         dw        ESMnVExe                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        29                       ; poá†teán° pozice
         db        1                        ; poá†teán° ©†dek
         db        20                       ; ®°©ka
         db        13                       ; vò®ka

ESMnVPol db        1,8,'Otev©en°'
         db        1,7,'Uloëen°'
         db        9,15,'uloëen° Jako...'
         db        1,6,'N†vrat'
         db        1,7,'Zav©en°'
         db        bit6+bit7,0
         db        1,9,'P©edchoz°'
         db        1,5,'Dal®°'
;         db        1,6,'Seznam'
;         db        1,4,'Tisk'
         db        bit6+bit7,0
         db        1,12,'V®e p©eru®it'
         db        1,16,'Konec s uloëen°m'

ESMnVBlk db        0,0,0,0,0,0,0,0,0;,0,0

ESMnVTit db        6,'soubor'

HelpS    SEGMENT   BYTE PUBLIC
ESMnVHlp db        75,'Otev©en° souboru k editaci, zaloëen° novÇho souboru (Shift-F4, Ctrl-KL)'
         db        76,'Uloëen° provedenòch zmàn do souboru, pokraáov†n° v editaci (F2, Ctrl-KS)'
         db        55,'Uloëen° souboru na disk pod zadanòm jmÇnem (Shift-F2)'
         db        59,'Zru®en° provedenòch zmàn, n†vrat k pñvodn°mu obsahu souboru'
         db        57,'Uzav©en° editovanÇho souboru v aktivn°m oknà (Shift-F6)'
         db        65,'Bude editov†n p©edch†zej°c° otev©enò soubor (Alt-F2, Ctrl-K-)'
         db        63,'Bude editov†n n†sleduj°c° otev©enò soubor (Alt-F3, Ctrl-K+)'
;         db        62,'Zobrazen° seznamu otev©enòch souborñ s informacemi o souborech'
;         db        57,'Vyti®tàn° editovanÇho souboru na tisk†rnu nebo do souboru'
         db        68,'P©eru®en° editace v®ech souborñ, opu®tàn° editoru (ESC, Ctrl-KQ)'
         db        66,'Uloëen° v®ech modifikovanòch souborñ, opu®tàn° editoru (Ctrl-KD)'
HelpS    ENDS

ESMnVExe label     dword
         dd        EditSMnO                 ; Otev©en°
         dd        EditSMU                  ; Uloëen°
         dd        EditSMnJ                 ; Jako...
         dd        EditSMnN                 ; N†vrat
         dd        EditSMnZ                 ; Zav©en°
         dd        EditSMnP                 ; P©edchoz°
         dd        EditSMnD                 ; Dal®°
;         dd        EditSMnS                 ; Seznam
;         dd        EditSMnT                 ; Tisk
         dd        EditSMnV                 ; V®e p©eru®it
         dd        EditSMnK                 ; Konec s uloëen°m

; -----------------------------------------------------------------------------
;        Definice vertik†ln°ho menu - obsluha bloku
; -----------------------------------------------------------------------------

EBMnVert label     byte                   ;* menu souborñ

         db        1                        ; typ menu - vertik†ln° menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        14                       ; poáet platnòch poloëek menu
         dw        16                       ; celkovò poáet poloëek menu

         dw        EBMnVPol                 ; adresa definice poloëek menu
         dw        EBMnVHlp                 ; adresa n†povàd
         dw        Hlp@PodmenuEditoruBlok   ; á°slo str†nky velkÇ n†povàdy
         dw        EBMnVBlk                 ; adresa blokovac° tabulky
         dw        EBMnVSwc                 ; adresa tabulky p©ep°naáñ
         dw        EBMnVTit                 ; adresa titulu okna
         dw        EBMnVExe                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        29                       ; poá†teán° pozice
         db        1                        ; poá†teán° ©†dek
         db        20                       ; ®°©ka
         db        18                       ; vò®ka

EBMnVPol db        bit7+1,7,'Textovò'
         db        bit7+1,8,'Line†rn°'
         db        bit7+1,9,'Sloupcovò'
         db        2,7,'zAá†tek'
         db        2,5,'kOnec'
         db        bit7+1,9,'Viditelnò'
         db        bit6+bit7,0
         db        1,6,'P©esun'
         db        1,5,'Kopie'
         db        1,6,'Ru®en°'
         db        1,10,'Do bufferu'
         db        1,9,'Z bufferu'
         db        bit6+bit7,0
         db        1,7,'Uloëen°'
         db        1,7,'Naáten°'
         db        1,10,'Modifikace'

EBMnVBlk db        0,0,0,0,0,0,0,0,0,0,0,0,0,0

EBMnVSwc db        1,0,0,0

EBMnVTit db        4,'blok'

HelpS    SEGMENT   BYTE PUBLIC
EBMnVHlp db        75,'Blok bude oznaáen jako textovò (souvislò £sek textu; Shift-F9, Ctrl-KN)'
         db        64,'Blok bude oznaáen jako line†rn° (©†dkovò; Shift-F9, Ctrl-KN)'
         db        69,'Blok bude oznaáen jako sloupcovò (obdÇln°kovò; Shift-F9, Ctrl-KN)'
         db        40,'Oznaáen° zaá†tku bloku (F3, Ctrl-KB)'
         db        38,'Oznaáen° konce bloku (F4, Ctrl-KK)'
         db        45,'Zviditelnàn° oznaáen° bloku (F9, Ctrl-KH)'
         db        59,'P©esun oznaáenÇho bloku na pozici kurzoru (F6, Ctrl-KV)'
         db        58,'Kopie oznaáenÇho bloku na pozici kurzoru (F5, Ctrl-KC)'
         db        68,'Zru®en° oznaáenÇho bloku (s uschov†n°m do bufferu) (F8, Ctrl-KY)'
         db        59,'Kopie oznaáenÇho bloku do bufferu (Ctrl-], Ctrl-Insert)'
         db        67,'N†vrat bloku z bufferu na pozici kurzoru (Ctrl-^, Shift-Insert)'
         db        67,'Uloëen° oznaáenÇho bloku na disk do souboru (Shift-F3, Ctrl-KW)'
         db        66,'Naáten° bloku ze souboru na pozici kurzoru (Shift-F5, Ctrl-KR)'
         db        74,'Modifikace bloku (velk†/mal† p°smena, konverze n†rodn°ho k¢du) (Ctrl-F8)'
HelpS    ENDS

EBMnVExe label     dword
         dd        EditBMnT                 ; textovò
         dd        EditBMnL                 ; line†rn°
         dd        EditBMnS                 ; sloupcovò
         dd        EditBMnA                 ; zaá†tek
         dd        EditBMnO                 ; konec
         dd        EditBMnV                 ; viditelnò
         dd        EditBMnP                 ; p©esun
         dd        EditBMnK                 ; kopie
         dd        EditBMnR                 ; ru®en°
         dd        EditBMnD                 ; do bufferu
         dd        EditBMnZ                 ; z bufferu
         dd        EditBMnU                 ; uloëen°
         dd        EditBMnN                 ; naáten°
         dd        EditBMnM                 ; modifikace

;; -----------------------------------------------------------------------------
;;        menu modifikace bloku
;; -----------------------------------------------------------------------------
;         db        'K¢d textu KAM'
;
;         db        'Velk† p°smena'
;         db        'Mal† p°smena'
;         db        'Inverze p°smen'
;         db        'JmÇna'
;
;         db        'N†rodn° k¢d'
;         db        'T©°dàn° ©†dkñ'
;         db        'Sloupcovò souáet'
;
;         db        'Zaplnàn° znakem'

; -----------------------------------------------------------------------------
;        Definice vertik†ln°ho menu - obsluha editace
; -----------------------------------------------------------------------------

EEMnVert label     byte                   ;* menu souborñ

         db        1                        ; typ menu - vertik†ln° menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        9                        ; poáet platnòch poloëek menu
         dw        10                       ; celkovò poáet poloëek menu

         dw        EEMnVPol                 ; adresa definice poloëek menu
         dw        EEMnVHlp                 ; adresa n†povàd
         dw        Hlp@PodmenuEditoruEditace ; á°slo str†nky velkÇ n†povàdy
         dw        EEMnVBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        EEMnVTit                 ; adresa titulu okna
         dw        EEMnVExe                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        29                       ; poá†teán° pozice
         db        1                        ; poá†teán° ©†dek
         db        22                       ; ®°©ka
         db        12                       ; vò®ka

EEMnVPol db        1,16,'Za kurzorem znak'
         db        1,18,'P©ed kurzorem znak'
         db        1,17,'N†sleduj°c° slovo'
         db        1,10,'Slovo p©ed'
         db        1,12,'Ru®en° ©†dku'
         db        5,16,'po zAá†tek ©†dku'
         db        1,14,'Useknut° konce'
         db        bit6+bit7,0
;         db        1,11,'Kopie ©†dku'
;         db        1,16,'Jeden ©†dek vloë'
         db        1,12,'Vzhñru ©†dek'
         db        1,10,'Dolñ ©†dek'
;         db        1,16,'Centrov†n° ©†dku'
;         db        bit6+bit7,0
;         db        1,11,'Form†tov†n°'
;         db        1,14,'Obnoven° zmàny'
;         db        2,10,'zMàna zpàt'
;         db        1,6,'Insert'

EEMnVBlk db        0,0,0,0,0,0,0,0,0;,0,0,0,0,0,0,0

EEMnVTit db        7,'editace'

HelpS    SEGMENT   BYTE PUBLIC
EEMnVHlp db        46,'Zru®en° znaku za kurzorem (Ctrl-G, Delete)'
         db        51,'Zru®en° znaku p©ed kurzorem (Ctrl-H, BackSpace)'
         db        51,'Zru®en° slova za kurzorem (Ctrl-T, Ctrl-Delete)'
         db        57,'Zru®en° slova p©ed kurzorem (Ctrl-QT, Ctrl-BackSpace)'
         db        31,'Zru®en° celÇho ©†dku (Ctrl-Y)'
         db        53,'Zru®en° ©†dku od kurzoru po zaá†tek ©†dku (Ctrl-QH)'
         db        51,'Zru®en° ©†dku od kurzoru po konec ©†dku (Ctrl-QY)'
;         db        39,'Zkop°rov†n° (zdvojen°) ©†dku s kurzorem'
;         db        54,'Vloëen° pr†zdnÇho ©†dku na ©†dek s kurzorem (Ctrl-N)'
         db        49,'Posun ©†dku s kurzorem o ©†dek nahoru (Ctrl-F9)'
         db        48,'Posun ©†dku s kurzorem o ©†dek dolñ (Ctrl-F10)'
;         db        27,'Vyst©edàn° ©†dku s kurzorem'
;         db        50,'Zform†tov†n° odstavce od kurzoru po konec odstavce'
;         db        37,'Obnoven° jednÇ zmàny v editaci (UNDO)'
;         db        34,'N†vrat jednÇ obnovenÇ zmàny (REDO)'
;         db        36,'Zmàna p©°znaku vkl†d†n° textu INSERT'
HelpS    ENDS

EEMnVExe label     dword
         dd        EditEMnZ                 ; maz†n° znaku za kurzorem
         dd        EditEMnP                 ; maz†n° znaku p©ed kurzorem
         dd        EditEMnN                 ; maz†n° n†sleduj°c°ho slova
         dd        EditEMnS                 ; maz†n° slova p©ed
         dd        EditEMnR                 ; maz†n° ©†dku
         dd        EditEMnA                 ; maz†n° po zaá†tek ©†dku
         dd        EditEMU                  ; useknut° konce
;         dd        EditEMnK                 ; kopie ©†dku
;         dd        EditEMnJ                 ; jeden ©†dek vloëit
         dd        EditEMnV                 ; vzhñru ©†dek
         dd        EditEMnD                 ; dolñ ©†dek
;         dd        EditEMnC                 ; centrov†n° ©†dku

; -----------------------------------------------------------------------------
;        Definice vertik†ln°ho menu - obsluha kurzoru
; -----------------------------------------------------------------------------

EKMnVert label     byte                   ;* menu souborñ

         db        1                        ; typ menu - vertik†ln° menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        15                       ; poáet platnòch poloëek menu
         dw        17                       ; celkovò poáet poloëek menu

         dw        EKMnVPol                 ; adresa definice poloëek menu
         dw        EKMnVHlp                 ; adresa n†povàd
         dw        Hlp@PodmenuEditoruKurzor ; á°slo str†nky velkÇ n†povàdy
         dw        EKMnVBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        EKMnVTit                 ; adresa titulu okna
         dw        EKMnVExe                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        29                       ; poá†teán° pozice
         db        1                        ; poá†teán° ©†dek
         db        20                       ; ®°©ka
         db        19                       ; vò®ka

EKMnVPol db        1,7,'Hled†n°'
         db        1,7,'N†hrada'
         db        3,4,'d†Le'
         db        1,9,'P©edchoz°'
         db        1,5,'Dal®°'
         db        bit6+bit7,0
;         db        3,14,'p†Rov† z†vorka'
         db        1,13,'Zaá†tek textu'
         db        7,11,'konec Textu'
         db        9,13,'zaá†tek Bloku'
         db        1,11,'Konec bloku'
         db        bit6+bit7,0
         db        1,15,'Aktu†ln° pozice'
         db        1,16,'Uschovan† pozice'
         db        1,16,'Oznaáen° znaákou'
         db        1,13,'< znaáka zpàt'
         db        1,14,'> znaáka vp©ed'
         db        1,14,'Skok na pozici'

EKMnVBlk db        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

EKMnVTit db        6,'kurzor'

HelpS    SEGMENT   BYTE PUBLIC
EKMnVHlp db        34,'Hled†n° zadanÇho textu (Ctrl-QF)'
         db        44,'N†hrada zadanÇho textu v souboru (Ctrl-QA)'
         db        66,'Pokraáov†n° v hled†n°/n†hradà v poslednà pouëitÇm smàru (Ctrl-L)'
         db        50,'Hled†n° p©edchoz°ho vòskytu ©etàzce (Alt-nahoru)'
         db        44,'Hled†n° dal®°ho vòskytu ©etàzce (Alt-dolñ)'
;         db        32,'Nalezen° p†rovÇ z†vorky {[()]}'
         db        61,'Skok na zaá†tek textu (Ctrl-PageUp, Ctrl-Home, Ctrl-QR)'
         db        60,'Skok na konec textu (Ctrl-PageDown, Ctrl-End, Ctrl-QC)'
         db        33,'Skok na zaá†tek bloku (Ctrl-QB)'
         db        31,'Skok na konec bloku (Ctrl-QK)'
         db        42,'óschova aktu†ln° pozice kurzoru (Ctrl-QM)'
         db        47,'N†vrat na uschovanou pozici kurzoru (Ctrl-QP)'
         db        57,'Oznaáen° pozice v textu textovou znaákou {',254,'} (Alt-F8)'
         db        54,'Nalezen° p©edch†zej°c° textovÇ znaáky {',254,'} (Alt-F9)'
         db        53,'Nalezen° n†sleduj°c° textovÇ znaáky {',254,'} (Alt-F10)'
         db        40,'Skok na zadanò ©†dek, pozici (Ctrl-QZ)'
HelpS    ENDS

EKMnVExe label     dword
         dd        EditKMnH                 ; hled†n°
         dd        EditKMnN                 ; n†hrada
         dd        EditKMnL                 ; d†le
         dd        EditKMnP                 ; p©edchoz°
         dd        EditKMnD                 ; dal®°
;         dd        EditKMnR                 ; p†rov† z†vorka
         dd        EditKMnZ                 ; zaá†tek textu
         dd        EditKMnT                 ; konec textu
         dd        EditKMnB                 ; zaá†tek bloku
         dd        EditKMnK                 ; konec bloku
         dd        EditKMnA                 ; aktu†ln° pozice
         dd        EditKMnU                 ; uschovan† pozice
         dd        EditKMnO                 ; oznaáen° znaákou
         dd        EditKMn1                 ; p©edchoz° znaáka
         dd        EditKMn2                 ; dal®° znaáka
         dd        EditKMnS                 ; skok na pozici

; -----------------------------------------------------------------------------
;        zad†n° ©†dku a pozice k nastaven°
; -----------------------------------------------------------------------------

EdiQZLin label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        EdiQZPol                 ; zaá†tek definice poloëek menu
         dw        EdiQZHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@PodmenuEditoruKurzor ; á°slo str†nky velkÇ n†povàdy
         dw        EdiQZBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        EdiQZTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        20                       ; poá†teán° pozice okna
         db        0                        ; poá†teán° ©†dek okna
         db        48                       ; ®°©ka okna
         db        8                        ; vò®ka okna

         dw        60                       ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        1                        ; celkovò poáet ©†dkñ
         dw        1                        ; poáet zobrazenòch ©†dkñ

         db        bit4                     ; maska zad†vanòch znakñ - á°slice
         db        4,':+-.  '               ; zak†zanÇ znaky

         db        HistCis                  ; historie
         db        0                        ; poáet p©edvoleb

; ------ poloëky voleb

EdiQZPol db        bit6,33,'Novò ',0,'©†dek',0,' nebo ',0,'©†dek,pozice',0,':'
         db        0,0
         db        bit6+bit7,0
         db        1,4,'D†le'
         db        1,6,'N†vrat'

EdiQZBlk db        0,0,0                    ; blokovac° tabulka

EdiQZTit db        14,'skok na pozici'

; ------ n†povàda

HelpS    SEGMENT   BYTE PUBLIC
EdiQZHlp db        66,'Zadejte poëadovanò ©†dek nebo ©†dek,pozici k nastaven° kurzoru'
         db        35,'Nastaven° kurzoru na zadanou pozici'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

; ------ zad†n° offsetu (dekadicky)

EdDQZLin label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        EdDQZPol                 ; zaá†tek definice poloëek menu
         dw        EdDQZHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@PodmenuEditoruKurzor ; á°slo str†nky velkÇ n†povàdy
         dw        EdDQZBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        EdDQZTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        20                       ; poá†teán° pozice okna
         db        0                        ; poá†teán° ©†dek okna
         db        48                       ; ®°©ka okna
         db        8                        ; vò®ka okna

         dw        60                       ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        1                        ; celkovò poáet ©†dkñ
         dw        1                        ; poáet zobrazenòch ©†dkñ

         db        bit4                     ; maska zad†vanòch znakñ - á°slice
         db        5,':+-., '               ; zak†zanÇ znaky

         db        HistCis                  ; historie
         db        0                        ; poáet p©edvoleb

; ------ poloëky voleb

EdDQZPol db        bit6,34,'Novò offset kurzoru (',0,'dekadicky',0,'):'
         db        0,0
         db        bit6+bit7,0
         db        1,4,'D†le'
         db        1,6,'N†vrat'

EdDQZBlk db        0,0,0                    ; blokovac° tabulka

EdDQZTit db        14,'skok na offset'

; ------ n†povàda

HelpS    SEGMENT   BYTE PUBLIC
EdDQZHlp db        59,'Zadejte poëadovanò offset (dekadicky) k nastaven° kurzoru'
         db        34,'Nastaven° kurzoru na zadanò offset'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

; ------ zad†n° offsetu (hexadecim†lnà)

EdHQZLin label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        EdHQZPol                 ; zaá†tek definice poloëek menu
         dw        EdHQZHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@PodmenuEditoruKurzor ; á°slo str†nky velkÇ n†povàdy
         dw        EdHQZBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        EdDQZTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        20                       ; poá†teán° pozice okna
         db        0                        ; poá†teán° ©†dek okna
         db        48                       ; ®°©ka okna
         db        8                        ; vò®ka okna

         dw        60                       ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        1                        ; celkovò poáet ©†dkñ
         dw        1                        ; poáet zobrazenòch ©†dkñ

         db        bit5                     ; maska zad†vanòch znakñ - HEX
         db        0,'      '               ; zak†zanÇ znaky

         db        HistCis                  ; historie
         db        0                        ; poáet p©edvoleb

; ------ poloëky voleb

EdHQZPol db        bit6,38,'Novò offset kurzoru (',0,'hexadecim†lnà',0,'):'
         db        0,0
         db        bit6+bit7,0
         db        1,4,'D†le'
         db        1,6,'N†vrat'

EdHQZBlk db        0,0,0                    ; blokovac° tabulka

; ------ n†povàda

HelpS    SEGMENT   BYTE PUBLIC
EdHQZHlp db        63,'Zadejte poëadovanò offset (hexadecim†lnà) k nastaven° kurzoru'
         db        34,'Nastaven° kurzoru na zadanò offset'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

; -----------------------------------------------------------------------------
;        Definice vertik†ln°ho menu - obsluha voleb
; -----------------------------------------------------------------------------

EVMnVert label     byte                   ;* menu souborñ

         db        1                        ; typ menu - vertik†ln° menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        9                        ; poáet platnòch poloëek menu
         dw        10                       ; celkovò poáet poloëek menu

         dw        EVMnVPol                 ; adresa definice poloëek menu
         dw        EVMnVHlp                 ; adresa n†povàd
         dw        Hlp@PodmenuEditoruVolby  ; á°slo str†nky velkÇ n†povàdy
         dw        EVMnVBlk                 ; adresa blokovac° tabulky
         dw        EVMnVSwc                 ; adresa tabulky p©ep°naáñ
         dw        EVMnVTit                 ; adresa titulu okna
         dw        EVMnVExe                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        29                       ; poá†teán° pozice
         db        1                        ; poá†teán° ©†dek
         db        22                       ; ®°©ka
         db        12                       ; vò®ka

EVMnVPol db        bit7+1,14,'Aktivn° okno 2'
         db        bit7+1,9,'PlnÇ okno'
         db        bit7+1,10,'Vertik†ln°'
         db        1,14,'Rozdàlen° oken'
         db        bit7+1,13,'Synchronizace'
         db        bit6+bit7,0
         db        bit7+1,11,'Bin†rn° m¢d'
         db        bit7+1,7,'HEX m¢d'
         db        bit7+1,13,'Editace textu'
;         db        bit7+1,6,'Line†l'
;         db        bit6+bit7,0
         db        bit7+1,12,'Optimalizace'
;         db        bit7+1,15,'Tabul†tor volnò'
;         db        1,15,'UchovanÇ z†lohy'
;         db        bit7+1,11,'Zarovn†v†n°'
;         db        1,18,'Form†t str†nky   ',16

EVMnVSwc db        0,0,0,0,0,0,0,0,0;,0,0,0,0,0

EVMnVBlk db        0,0,0,0,0,0,0,0,0;,0,0,0,0,0
EVMnVTit db        5,'Volby'

HelpS    SEGMENT   BYTE PUBLIC
EVMnVHlp db        51,'Volba aktivn°ho okna 1 nebo 2 (Ctrl-K*, Alt-F1)'
         db        60,'Zobrazeno pouze aktivn° okno p©es celou obrazovku (Alt-F4)'
         db        58,'Okna jsou rozdàlena vertik†lnà (tj. vedle sebe) (Alt-F6)'
         db        54,'Nastaven° p©edàlu mezi okny (nastaven° velikosti oken)'
         db        63,'Synchronizace kurzorñ v oknech 1 a 2 (sp©aëen° oken) (Alt-F7)'
         db        70,'Soubor zobrazen v bin†rn°m m¢du - v®echny bajty jako znaky (Ctrl-F2)'
         db        49,'Soubor zobrazen v hexadecim†ln°m m¢du (Ctrl-F3)'
         db        51,'Reëim editace souboru (zobrazen kurzor) (Ctrl-F1)'
;         db        34,'Zobrazen° line†lu (prav°tka) ©†dku'
         db        75,'Optimalizace - nadbyteánÇ mezery z konce ©†dku budou odstranàny (Ctrl-F6)'
;         db        52,'Volnò (promànlivò) tabul†tor podle p©edchoz°ho ©†dku'
;         db        60,'Volba poátu uchovanòch z†loh souboru BAK (0=nen° z†lohov†n°)'
;         db        37,'Text bude zarovn†v†n k pravÇmu okraji'
;         db        74,'Volba form†tu str†nky (levò a pravò okraj, dÇlka str†nky, tabul†tory, ...)'
HelpS    ENDS

EVMnVExe label     dword
         dd        EdiVMPP1                 ; Aktivn° okno 2
         dd        EdiVMPP2                 ; PlnÇ okno
         dd        EdiVMPP3                 ; Vertik†ln°
         dd        EdiVMPP4                 ; Rozdàlen° oken
         dd        EdiVMPP5                 ; Synchronizace
         dd        EdiVMPP6                 ; Bin†rn° m¢d
         dd        EdiVMPP7                 ; Hex m¢d
         dd        EdiVMPP8                 ; Editace povolena
;         dd        EdiVMPP9                 ; Line†l
         dd        EdiVMPPA                 ; Optimalizace
;         dd        EdiVMPPB                 ; Tabul†tor volnò
;         dd        0                        ; BAk z†lohov†n°
;         dd        0                        ; Zarovn†v†n°
;         dd        0                        ; Form†t str†nky


EdNadTx1 db        'û†dek  '
EdNadTx2 db        'Pozice '
EdNadTx3 db        'Offset '
EdNadTx4 db        'DÇlka  '

CRLFTxt  db        'C/L'
LFCRTxt  db        'L/C'
LFTxt    db        ' LF'
EolTxt   db        ' - '
EofTxt   db        'eof'
TabTxt   db        'TAB'
TbTxt    db        '>>>'

; -----------------------------------------------------------------------------
;        varovnÇ hl†®en° - soubor bude navr†cen
; -----------------------------------------------------------------------------

ENEMnLin label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        2                        ; poáet platnòch poloëek menu
         dw        6                        ; celkovò poáet poloëek menu

         dw        ENEMnLnP                 ; zaá†tek definice poloëek menu
         dw        ENEMnLnH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@PodmenuEditoruSoubor ; á°slo str†nky velkÇ n†povàdy
         dw        ENEMnLnB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        ENEMnLnT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        22                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        55                       ; ®°©ka okna
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

; ------ poloëky voleb

ENEMnLnP db        bit6,9,0,'VAROVèNã'
         db        bit6,34,'Bude obnoven pñvodn° obsah souboru'
         db        bit6,29,'jako p©ed zapoáet°m editace !'
         db        bit6+bit7,0
         db        1,7,'Obnovit'
         db        1,6,'N†vrat'

ENEMnLnB db        0,0                      ; blokovac° tabulka

ENEMnLnT db        16,'obnoven° souboru'

HelpS    SEGMENT   BYTE PUBLIC
ENEMnLnH db        60,'Obnoven° obsahu souboru do stavu jako p©ed zapoáet°m editace'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

Data     ENDS

         END

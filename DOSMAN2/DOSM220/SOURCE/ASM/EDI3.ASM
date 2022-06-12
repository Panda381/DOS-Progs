
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                             E D I T O R - 3
;
;                editor - obsluha hled n¡ a n hrady, modifikace bloku
;
; =============================================================================
;
; Ve©ejn‚ procedury:
;
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

INCLUDE  ASM\DEF.ASM

CodeEdi  SEGMENT   BYTE PUBLIC
         ASSUME    cs:CodeEdi,ds:Data

; -----------------------------------------------------------------------------
;        Shift-F7: hled n¡ s n hradou
; -----------------------------------------------------------------------------

EditSF7: or        byte ptr ds:[EdiHledP],bit6 ; je n hrada
         jmp       short EditF700

; -----------------------------------------------------------------------------
;        F7: hled n¡ textu (DX/ES:DI=definice okna)
; -----------------------------------------------------------------------------

EditF7   PROC      NEAR

         and       byte ptr ds:[EdiHledP],not bit6 ; nen¡ n hrada

; ------ rozli¨en¡, zda je hled n¡ v HEX tvaru

EditF700:and       byte ptr ds:[EdiHldP2],not bit2+bit3 ; nen¡ HEX tvar, nen¡ zna‡ka
         test      byte ptr es:[di+EdiParm1],bit1 ; je HEX m¢d ?
         jz        EdiF7011                 ; nen¡ HEX m¢d
         test      byte ptr es:[di+EdiParm2],bit2 ; je ASCII ‡ st HEX pole ?
         jnz       EdiF7011                 ; je ASCII ‡ st HEX pole
         or        byte ptr ds:[EdiHldP2],bit2 ; je zad n¡ v HEX tvaru

; ------ p©¡prava p©edvolby - ozna‡en˜ blok

EdiF7011:mov       byte ptr ds:[EdiHPrN],0  ; po‡et p©edvoleb hled n¡ ASCII
         mov       byte ptr ds:[EdiNPrN],0  ; po‡et p©edvoleb n hrady ASCII
         mov       byte ptr ds:[EdiHHPN],0  ; po‡et p©edvoleb hled n¡ HEX
         mov       byte ptr ds:[EdiNHPN],0  ; po‡et p©edvoleb n hrady HEX
         call      EditTstB                 ; test, zda je blok zapnut
         jc        EdiF7015                 ; blok nen¡ zapnut
         mov       ax,word ptr es:[EdiOBBlk] ; offset za‡ tku bloku LOW
         mov       cx,word ptr es:[EdiOBBlk+2] ; offset za‡ tku bloku HIGH
         call      EdiGetAd                 ; v˜po‡et adresy v souboru -> BX:SI

; ------ po‡et bajt– k na‡ten¡ -> CX

         push      bx
         push      si
         mov       si,word ptr es:[EdiOKBlk] ; offset konce bloku LOW
         mov       bx,word ptr es:[EdiOKBlk+2] ; offset konce bloku HIGH
         sub       si,ax                    ; vzd lenost konce od za‡ tku
         sbb       bx,cx
         jz        EdiF7012                 ; offset HIGH je OK
         mov       si,-1                    ; omezen¡ offsetu LOW
EdiF7012:mov       cx,si                    ; CX <- vzd lenost konce LOW
         pop       si
         pop       bx

; ------ na‡ten¡ dat z bloku v ASCII tvaru

         jcxz      EdiF7015                 ; ©etˆzec neplatn˜
         test      byte ptr ds:[EdiHldP2],bit2 ; je HEX tvar ?
         jnz       EdiF7016                 ; je HEX tvar

         cmp       cx,3*16                  ; maxim ln¡ d‚lka ©etˆzce
         jbe       EdiF7013                 ; ©etˆzec je OK
         mov       cx,3*16                  ; omezen¡ d‚lky ©etˆzce

EdiF7013:inc       byte ptr ds:[EdiHPrN]    ; je 1 p©edvolba
         inc       byte ptr ds:[EdiNPrN]
         mov       ds:[EdiHPrPN],cx         ; d‚lka p©edvolby hled n¡ ASCII
         mov       ds:[EdiNPrPN],cx         ; d‚lka p©edvolby n hrady ASCII

         push      di
         mov       di,offset EdiHPrTx       ; buffer textu
EdiF7014:call      EdiGetCh                 ; na‡ten¡ znaku
         mov       ds:[di],al               ; ulo‘en¡ znaku
         inc       si                       ; zv˜¨en¡ ukazatele textu
         inc       di                       ; zv˜¨en¡ ukl dac¡ adresy
         loop      EdiF7014                 ; dal¨¡ znak textu
         pop       di
EdiF7015:jmp       short EdiF7019

; ------ na‡ten¡ dat z bloku pro HEX

EdiF7016:cmp       cx,16                    ; maxim ln¡ d‚lka ©etˆzce
         jbe       EdiF7017                 ; ©etˆzec je OK
         mov       cx,16                    ; omezen¡ d‚lky ©etˆzce
EdiF7017:push      cx
         mov       ax,cx
         shl       cx,1
         add       cx,ax                    ; CX <- po‡et bajt– * 3
         dec       cx                       ; bez koncov‚ mezery
         mov       ds:[EdiHHPPN],cx         ; d‚lka p©edvolby HEX
         mov       ds:[EdiNHPPN],cx         ; d‚lka p©edvolby HEX
         pop       cx
         inc       byte ptr ds:[EdiHHPN]    ; 1 p©edvolba hled n¡ v HEX tvaru
         inc       byte ptr ds:[EdiNHPN]    ; 1 p©edvolba n hrady v HEX tvaru

         push      di
         mov       di,offset EdiHPrTx       ; buffer textu
EdiF7018:call      EdiGetCh                 ; na‡ten¡ znaku
         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       ah,0                     ; barva se neukl d 
         call      far ptr DekHByte         ; dek¢dov n¡ bajtu HEX
         mov       al," "
         stosb                              ; oddˆlovac¡ mezera
         inc       si                       ; zv˜¨en¡ ukazatele textu
         loop      EdiF7018                 ; dal¨¡ znak textu
         call      EditGetD                 ; obnoven¡ adresy okna
         pop       di

; ------ zad n¡ textu k hled n¡

EdiF7019:call      far ptr EdiHF7Za         ; zad n¡ textu k hled n¡
         jnc       EditF704                 ; zad n¡ OK

EditF702:jmp       EditF79                  ; p©eru¨en¡ operace

; ------ zad n¡ textu k nahrazen¡

EditF704:test      byte ptr ds:[EdiHledP],bit6 ; je n hrada ?
         jz        EditF712                 ; nen¡ n hrada
         mov       si,offset EdiNMLin       ; n hrada v ASCII tvaru
         test      byte ptr ds:[EdiHldP2],bit2 ; je HEX tvar ?
         jz        EditF705                 ; nen¡ HEX tvar
         mov       si,offset EdiNHLin       ; n hrada v HEX tvaru
EditF705:call      Edi0Menu                 ; zad n¡ textu k n hradˆ
         jc        EditF702                 ; p©eru¨en¡ operace

; ------ £schova textu do bufferu

         mov       ax,offset TextSub        ; buffer n hradn¡ho textu
         call      EdiF7Sto                 ; ulo‘en¡ textu do bufferu
         mov       ds:[TextSubN],cx         ; d‚lka textu
         mov       ds:[TextSub0],cl         ; d‚lka pro zobrazen¡

; ------ zad n¡ parametr– hled n¡

EditF712:call      EditF7Kd                 ; p©¡prava p©ep¡na‡– konverze
         mov       si,offset EdiHPLin       ; menu volby p©ep¡na‡–
         call      Edi0Menu                 ; zad n¡ p©ep¡na‡– pro operaci
         jc        EditF702                 ; p©eru¨en¡ operace

; ------ p©¡prava k rozboru parametr–

         mov       word ptr ds:[EdiHledC],0 ; ‡¡ta‡ p©esko‡en¡ ©etˆzc–
         mov       word ptr ds:[EdiHledC+2],0
         and       byte ptr ds:[EdiHledP],not bit0+bit1+bit2+bit3+bit4+bit5
         and       byte ptr ds:[EdiHldP2],not bit0 ; nen¡ pokra‡ov n¡ hled n¡

         mov       si,offset LinBuff        ; © dkov˜ buffer
         mov       ch,0
         mov       cl,ds:[LinNum]           ; po‡et zadan˜ch znak–
         cld

; ------ na‡ten¡ dal¨¡ho znaku parametr–

EditF74: jcxz      EditF740                 ; nen¡ dal¨¡ znak
         lodsb                              ; na‡ten¡ znaku
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         call      far ptr UpCase           ; konverze na velk‚ p¡smeno

; ------ hled n¡ zpˆt "B"

         cmp       al,"B"
         jne       EditF741
         or        byte ptr ds:[EdiHledP],bit0 ; hled n¡ zpˆt
         jmp       short EditF74

EditF740:jmp       EditF75                  ; nen¡ dal¨¡ znak

; ------ nerozli¨uje velk  a mal  p¡smena "U"

EditF741:cmp       al,"U"
         jne       EditF742
         or        byte ptr ds:[EdiHledP],bit1 ; nerozli¨uje velk /mal 
         jmp       short EditF74

; ------ cel˜ soubor "G"

EditF742:cmp       al,"G"
         jne       EditF743
         or        byte ptr ds:[EdiHledP],bit2 ; cel˜ soubor nebo blok
         jmp       short EditF74

; ------ v bloku "L"

EditF743:cmp       al,"L"
         jne       EditF744
         or        byte ptr ds:[EdiHledP],bit3+bit2 ; cel˜ ozna‡en˜ blok
         jmp       short EditF74

; ------ jen cel  slova "W"

EditF744:cmp       al,"W"
         jne       EditF745
         or        byte ptr ds:[EdiHledP],bit4 ; jen cel  slova
         jmp       short EditF74

; ------ bez dotazu "N"

EditF745:cmp       al,"N"
         jne       EditF746
         or        byte ptr ds:[EdiHledP],bit5 ; bez dotazu
         jmp       short EditF74

; ------ ‡¡slice - ‡¡ta‡ p©esko‡en¡

EditF746:sub       al,"0"
         jb        EditF74                  ; neplatn˜ znak
         cmp       al,9
         ja        EditF74                  ; neplatn˜ znak
         mov       ah,0

         push      dx
         push      ax

         mov       ax,10                    ; n sobek
         mul       word ptr ds:[EdiHledC+2] ; posun ‡¡sla HIGH o © d
         mov       word ptr ds:[EdiHledC+2],ax ; nov‚ ‡¡slo HIGH
         mov       ax,10
         mul       word ptr ds:[EdiHledC]   ; posun ‡¡sla LOW o © d
         mov       word ptr ds:[EdiHledC],ax ; nov‚ ‡¡slo LOW

         pop       ax
         add       word ptr ds:[EdiHledC],ax ; p©i‡ten¡ zadan‚ ‡¡slice
         adc       word ptr ds:[EdiHledC+2],dx ; p©i‡ten¡ nov‚ho ‡¡sla HIGH
         pop       dx
         jmp       short EditF74

; ------ Alt-nahoru: hled n¡ zpˆt (DX/ES:DI=definice okna)

EditHlAU:or        byte ptr ds:[EdiHledP],bit0 ; je hled n¡ zpˆt
         jmp       short EditHlCL

; ------ Alt-dol–: hled n¡ vp©ed (DX/ES:DI=definice okna)

EditHlAD:and       byte ptr ds:[EdiHledP],not bit0 ; je hled n¡ vp©ed

; ------ pokra‡ov n¡ v hled n¡ Ctlr-L (DX/ES:DI=definice okna)

EditHlCL:and       byte ptr ds:[EdiHldP2],not bit3 ; nehled  se zna‡ka
EdiHlCL0:or        byte ptr ds:[EdiHldP2],bit0 ; je pokra‡ov n¡ v hled n¡
         mov       word ptr ds:[EdiHledC],0 ; ‡¡ta‡ p©esko‡en¡ ©etˆzc–
         mov       word ptr ds:[EdiHledC+2],0
         and       byte ptr ds:[EdiHledP],not bit5 ; z kaz operace bez dotazu

; ------ ovˆ©en¡, zda je nˆjak˜ text k hled n¡

EditF75: cmp       word ptr ds:[TextFndN],0 ; je nˆjak˜ text ?
         je        EditF754                 ; nen¡ ‘ dn˜ text k hled n¡

; ------ konverze hledan‚ho textu na velk  p¡smena

         call      EdiF7KdP                 ; p©¡prava n rodn¡ho k¢du hled n¡
         test      byte ptr ds:[EdiHledP],bit1 ; nerozli¨uj¡ se ?
         jz        EditF752                 ; rozli¨uj¡ se

         push      dx

         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       si,offset TextFnd        ; buffer textu
         mov       dl,bit0                  ; maska k¢du
         mov       cl,ds:[EdiHlKod]         ; k¢d hled n¡
         dec       cx
         shl       dl,cl                    ; rotace na pozici
         mov       cx,ds:[TextFndN]         ; d‚lka hledan‚ho textu
         call      far ptr KonvUpC          ; konverze na velk  p¡smena

         pop       dx

; ------ adresa okna -> ES

EditF752:call      EditGetD                 ; adresa okna -> ES
         jnc       EditF755                 ; segment okna OK
EditF754:jmp       EditF79                  ; p©eru¨en¡ operace

; ------ inicializace ukazatel– operace

EditF755:mov       ax,word ptr es:[EdiSize] ; velikost souboru LOW
         mov       word ptr ds:[EdiHledN],ax ; ‡¡ta‡ zbyl˜ch dat LOW
         mov       word ptr ds:[InfoKMax],ax ; maxim ln¡ velikost indik toru LOW
         mov       word ptr ds:[InfoKCit],ax ; ‡¡ta‡ indik toru LOW

         mov       ax,word ptr es:[EdiSize+2] ; velikost souboru HIGH
         mov       word ptr ds:[EdiHledN+2],ax ; ‡¡ta‡ zbyl˜ch dat HIGH
         mov       word ptr ds:[InfoKMax+2],ax ; maxim ln¡ velikost indik toru HIGH
         mov       word ptr ds:[InfoKCit+2],ax ; ‡¡ta‡ indik toru HIGH

; ------ test, zda je hled n¡ v bloku

         and       byte ptr ds:[EdiHldP2],not bit4 ; nen¡ sloupcov˜ blok
         test      byte ptr ds:[EdiHledP],bit3 ; je hled n¡ v bloku ?
         jz        EditF758                 ; nen¡ hled n¡ v bloku

; ------ test, zda je blok ozna‡en

         call      EditTstB                 ; test, zda je blok zapnut
         jc        EditF754                 ; blok nen¡ zobrazen

; ------ p©¡prava pro hled n¡ v BIN a HEX m¢du

         test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je bin rn¡/HEX m¢d ?
         jz        EditF756                 ; nen¡ bin rn¡/HEX m¢d
         call      EdiHlIO                  ; p©¡prava pro BIN a HEX m¢d
         jmp       short EditF76            ; hled n¡ ©etˆzce

; ------ p©¡znak sloupcov‚ho bloku

EditF756:test      byte ptr es:[EdiParm],bit6 ; je sloupcov˜ blok ?
         jz        EditF757                 ; nen¡ sloupcov˜ blok
         or        byte ptr ds:[EdiHldP2],bit4 ; p©¡znak sloupcov‚ho bloku

; ------ p©¡prava pro hled n¡ v textov‚m m¢du

EditF757:call      EdiHlIB                  ; p©¡prava pro textov˜ m¢d
         jmp       short EditF76            ; hled n¡ ©etˆzce

; ------ test, zda je hled n¡ vp©ed

EditF758:test      byte ptr ds:[EdiHledP],bit0 ; je hled n¡ vp©ed ?
         jnz       EditF77                  ; je hled n¡ zpˆt

; ------ hled n¡ vp©ed v cel‚m souboru

         test      byte ptr ds:[EdiHledP],bit2 ; je cel˜ soubor ?
         jz        EditF762                 ; nen¡ cel˜ soubor
         test      byte ptr ds:[EdiHldP2],bit0 ; je pokra‡ov n¡ v hled n¡ ?
         jnz       EditF762                 ; je pokra‡ov n¡ v hled n¡
EditF761:xor       ax,ax                    ; AX <- 0
         mov       ds:[EdiHledB],ax         ; blok ukazatele hled n¡
         mov       ds:[EdiHledO],ax         ; offset ukazatele hled n¡
         mov       word ptr ds:[InfoKCit],ax ; ‡¡ta‡ kurzoru LOW
         mov       word ptr ds:[InfoKCit+2],ax ; ‡¡ta‡ kurzoru HIGH
EditF76: jmp       short EditF78            ; hled n¡ ©etˆzce

; ------ hled n¡ vp©ed od kurzoru

EditF762:test      byte ptr es:[di+EdiParm1],bit0 ; je kurzor zobrazen ?
         jnz       EditF761                 ; zobrazen¡ - kurzor nen¡ zobrazen
         mov       ax,word ptr es:[di+EdiOffsK] ; offset kurzoru v souboru LOW
         mov       word ptr ds:[InfoKCit],ax ; ‡¡ta‡ kurzoru LOW
         mov       ax,word ptr es:[di+EdiOffsK+2] ; offset kurzoru v souboru HIGH
         mov       word ptr ds:[InfoKCit+2],ax ; ‡¡ta‡ kurzoru HIGH
         mov       ax,es:[di+EdiBBKur]      ; blok s kurzorem
         mov       ds:[EdiHledB],ax         ; blok ukazatele hled n¡
         mov       ax,es:[di+EdiOfKur]      ; offset s kurzorem
         inc       ax                       ; n sleduj¡c¡ bajt
         mov       ds:[EdiHledO],ax         ; offset ukazatele hled n¡
         jmp       short EditF78            ; hled n¡ ©etˆzce

; ------ hled n¡ zpˆt v cel‚m souboru

EditF77: test      byte ptr ds:[EdiHledP],bit2 ; je cel˜ soubor ?
         jz        EditF772                 ; nen¡ cel˜ soubor
         test      byte ptr ds:[EdiHldP2],bit0 ; je pokra‡ov n¡ v hled n¡
         jnz       EditF772                 ; je pokra‡ov n¡ v hled n¡
EditF771:mov       bx,es:[EdiNBlok]         ; po‡et blok–
         dec       bx                       ; posledn¡ blok
         mov       ds:[EdiHledB],bx         ; blok ukazatele hled n¡
         call      EditNGet                 ; poskytnut¡ blok BX
         dec       cx                       ; posledn¡ bajt
         mov       ds:[EdiHledO],cx         ; offset ukazatele hled n¡
         jmp       short EditF78            ; hled n¡ ©etˆzce

; ------ hled n¡ zpˆt od kurzoru

EditF772:test      byte ptr es:[di+EdiParm1],bit0 ; je kurzor zobrazen ?
         jnz       EditF771                 ; zobrazen¡ - kurzor nen¡ zobrazen
         mov       ax,word ptr es:[di+EdiOffsK] ; offset kurzoru v souboru LOW
         mov       word ptr ds:[InfoKCit],ax ; ‡¡ta‡ kurzoru LOW
         mov       ax,word ptr es:[di+EdiOffsK+2] ; offset kurzoru v souboru LOW
         mov       word ptr ds:[InfoKCit+2],ax ; ‡¡ta‡ kurzoru HIGH

         mov       ax,es:[di+EdiBBKur]      ; blok s kurzorem
         mov       ds:[EdiHledB],ax         ; blok ukazatele hled n¡
         mov       ax,es:[di+EdiOfKur]      ; offset s kurzorem
         dec       ax                       ; p©edch zej¡c¡ bajt
         mov       ds:[EdiHledO],ax         ; offset ukazatele hled n¡

; ------ vyhled n¡ ©etˆzce

EditF78: call      EditHled                 ; vyhled n¡
EditF79: or        byte ptr ds:[EditPar2],bit0 ; zobrazit kurzor
         ret

EditF7   ENDP

; ------ p©ep¡na‡ volby otazn¡ku

EditF7O  PROC      FAR

         xor       byte ptr ds:[EdiHMSwc],-1
         xor       byte ptr ds:[EdiHledP],bit7 ; p©¡znak otazn¡ku
         mov       al,ds:[ZnakSwch+1]       ; "-" p©ep¡na‡ nenastaven
         xor       al,ds:[ZnakSwch]         ; znak p©ep¡na‡e menu
         xor       ds:[EdiHMPl2+10],al
EditF7O2:call      far ptr DispMnu
         ret

EditF7O  ENDP

; ------ p©ep¡na‡ k¢du

EdiHPEx1 PROC      FAR

         mov       bx,ds:[si+MnuAkt]        ; aktivn¡ zvolen  polo‘ka
         dec       bx
         dec       bx                       ; korekce
         mov       ds:[EdiHlKod],bl         ; k¢d konverze
         call      EditF7Kd                 ; p©¡prava p©ep¡na‡– konverze
         jmp       short EditF7O2

EdiHPEx1 ENDP

; -----------------------------------------------------------------------------
;        zad n¡ textu k hled n¡ (i pro diskov˜ editor !) -> CY=p©eru¨en¡ operace
; -----------------------------------------------------------------------------

EdiHF7Za PROC      FAR

; ------ p©¡prava p©ep¡na‡e otazn¡ku

         mov       al,ds:[ZnakSwch+1]       ; "-" p©ep¡na‡ nenastaven
         mov       byte ptr ds:[EdiHMSwc],0
         test      byte ptr ds:[EdiHledP],bit7 ; povolen otazn¡k ?
         jz        EdiHF7Z1                 ; otazn¡k nen¡ platn˜ znak
         mov       al,ds:[ZnakSwch]         ; znak p©ep¡na‡e menu
         dec       byte ptr ds:[EdiHMSwc]   ; p©ep¡na‡ nastaven
EdiHF7Z1:mov       ds:[EdiHMPl2+10],al      ; znak nastaven¡ p©ep¡na‡e

; ------ zad n¡ textu k hled n¡

         mov       si,offset EdiHMLin       ; zad n¡ textu v ASCII tvaru
         test      byte ptr ds:[EdiHldP2],bit2 ; je HEX tvar ?
         jz        EdiHF7Z2                 ; nen¡ HEX tvar
         mov       si,offset EdiHHLin       ; zad n¡ textu v HEX tvaru
EdiHF7Z2:call      Edi0Menu                 ; zad n¡ textu k hled n¡
         jc        EdiHF7Z9                 ; p©eru¨en¡ operace

; ------ ulo‘en¡ textu do bufferu

         mov       ax,offset TextFnd        ; buffer hledan‚ho textu
         call      EdiF7Sto                 ; ulo‘en¡ textu do bufferu
         mov       ds:[TextFndN],cx         ; d‚lka textu
         mov       ds:[TextFnd0],cl         ; d‚lka textu pro zobrazen¡
         stc                                ; p©¡znak p©eru¨en¡ operace
         jcxz      EdiHF7Z9                 ; nen¡ text

; ------ test, zda je v ©etˆzci n hradn¡ otazn¡k

         and       byte ptr ds:[EdiHldP2],not bit1 ; v ©etˆzci nen¡ otazn¡k
         test      byte ptr ds:[EdiHldP2],bit2 ; je HEX tvar ?
         jnz       EdiHF7Z8                 ; je HEX tvar - nen¡ otazn¡k
         test      byte ptr ds:[EdiHledP],bit7 ; je otazn¡k platn˜ znak ?
         jnz       EdiHF7Z8                 ; otazn¡k je platn˜ znak

         mov       si,offset TextFnd        ; buffer textu
EdiHF7Z4:cmp       byte ptr ds:[si],"?"     ; je otazn¡k ?
         jne       EdiHF7Z6                 ; nen¡ otazn¡k
         or        byte ptr ds:[EdiHldP2],bit1 ; v ©etˆzci je otazn¡k
EdiHF7Z6:inc       si
         loop      EdiHF7Z4                 ; dal¨¡ znak

EdiHF7Z8:clc                                ; p©¡znak operace OK
EdiHF7Z9:ret

EdiHF7Za ENDP

; ------ p©¡prava p©ep¡na‡– konverze

EditF7Kd:push      ax
         push      cx
         push      si

         call      EdiF7KdP                 ; implicitn¡ p©ep¡na‡ k¢du hled n¡
         mov       si,offset EdiHPPl1+6
         mov       ah,ds:[EdiHlKod]         ; k¢d konverze
         mov       cx,6                     ; po‡et p©ep¡na‡–
EdiF7Kd2:mov       al,ds:[ZnakSwch+1]       ; nenastaven
         dec       ah
         jnz       EdiF7Kd4
         mov       al,ds:[ZnakSwch]         ; nastaven
EdiF7Kd4:mov       ds:[si],al
         add       si,7
         loop      EdiF7Kd2

         pop       si
         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        implicitn¡ p©ep¡na‡ k¢du pro hled n¡ a modifikaci
; -----------------------------------------------------------------------------

EdiF7KdP PROC      NEAR

         push      ax
         mov       al,ds:[EdiHlKod]         ; k¢d konverze
         or        al,al                    ; je k¢d zadan˜ ?
         jnz       EdiF7KP2                 ; k¢d je zadan˜
         mov       al,1                     ; k¢d pro HEX
         test      byte ptr ds:[EdiHldP2],bit2 ; je HEX tvar ?
         jnz       EdiF7KP1                 ; je HEX tvar
         cmp       byte ptr ds:[CodePagK],0 ; je k¢d ur‡en ?
         je        EdiF7KP1                 ; k¢d nen¡ ur‡en
         mov       al,ds:[CodePagK]         ; k¢dov  str nka
         add       al,2
EdiF7KP1:mov       ds:[EdiHlKod],al         ; nastaven¡ k¢du znak–
EdiF7KP2:pop       ax
         ret

EdiF7KdP ENDP

; ------ ulo‘en¡ zadan‚ho textu do bufferu AX

EdiF7Sto:push      bx
         push      di
         push      es

         xchg      ax,di                    ; AX <- adresa bufferu
         push      ds
         pop       es                       ; ES <- datov˜ segment

         mov       si,offset LinBuff        ; buffer s textem
         mov       ch,0
         mov       cl,ds:[LinNum]           ; d‚lka hledan‚ho textu
         xor       bx,bx                    ; BX <- 0 ‡¡ta‡ d‚lky dat

         cld
         jcxz      EdiF7St9                 ; nen¡ nic zad no

         test      byte ptr ds:[EdiHldP2],bit2 ; je HEX tvar ?
         jz        EdiF7St6                 ; nen¡ HEX tvar

EdiF7St2:jcxz      EdiF7St9                 ; nen¡ dal¨¡ znak
         call      EdiF7HG                  ; na‡ten¡ znaku HEX
         jc        EdiF7St2                 ; nen¡ znak HEX
         mov       ah,al                    ; AH <- na‡ten¡ znak

         jcxz      EdiF7St3                 ; nen¡ dal¨¡ znak
         call      EdiF7HG                  ; na‡ten¡ druh‚ho znaku HEX
         jc        EdiF7St3                 ; nen¡ to znak HEX
         shl       ah,1
         shl       ah,1
         shl       ah,1
         shl       ah,1                     ; AH = vy¨¨¡ tetr da
         or        ah,al

EdiF7St3:mov       al,ah                    ; AL <- na‡ten˜ bajt
         stosb                              ; ulo‘en¡ bajtu
         inc       bx                       ; zv˜¨en¡ ‡¡ta‡e bajt–
         cmp       bl,TextFndX              ; maxim ln¡ d‚lka dat
         jb        EdiF7St2                 ; m–‘e b˜t dal¨¡ bajt
         jmp       short EdiF7St9           ; konec

EdiF7St6:cmp       cl,TextFndX
         jbe       EdiF7sT8
         mov       cl,TextFndX
EdiF7St8:mov       bx,cx                    ; BX <- po‡et bajt–
         rep       movsb                    ; p©enesen¡ dat ASCII

EdiF7St9:mov       cx,bx                    ; CX <- po‡et ulo‘en˜ch bajt–
         pop       es
         pop       di
         pop       bx
         ret

; ------ na‡ten¡ znaku HEX (CY=nen¡ platn˜ znak)

EdiF7HG: lodsb                              ; na‡ten¡ znaku AL
         call      far ptr UpCase           ; konverze na velk‚ p¡smeno
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         sub       al,"0"
         jb        EdiF7HG5                 ; nen¡ platn˜ znak HEX
         cmp       al,9+1
         jb        EdiF7HG4                 ; je to platn˜ znak
         sub       al,7                     ; korekce
         cmp       al,16
         jae       EdiF7HG4                 ; neplatn˜ znak
         cmp       al,10
         cmc
EdiF7HG4:cmc
EdiF7HG5:ret

; -----------------------------------------------------------------------------
;        inicializace ukazatel– pro hled n¡ v bloku v m¢du BIN a HEX
; -----------------------------------------------------------------------------

EdiHlIO  PROC      NEAR

; ------ test, zda je pokra‡ov n¡ v hled n¡ od kurzoru zpˆt

         test      byte ptr ds:[EdiHldP2],bit0 ; je pokra‡ov n¡ v hled n¡ ?
         jz        EdHlIBO1                 ; nen¡ pokra‡ov n¡ v hled n¡
         test      byte ptr ds:[EdiHledP],bit0 ; je hled n¡ zpˆt ?
         jz        EdHlIBO1                 ; nen¡ hled n¡ zpˆt

; ------ kontrola, zda je kurzor uvnit© bloku

         call      EdiHlKBO                 ; test, zda je kurzor uvnit© bloku
         jnc       EdHlIBO4                 ; kurzor je uvnit© bloku OK

; ------ offset a adresa konce bloku -> CX:AX/BX:SI

EdHlIBO1:mov       ax,word ptr es:[EdiOKBlk] ; © dek konce bloku
         mov       cx,word ptr es:[EdiOKBlk+2]
         call      EdiGetAd                 ; v˜po‡et adresy konce bloku

; ------ nastaven¡ na posledn¡ znak bloku (nebo znak p©ed kurzorem)

EdHlIBO4:sub       ax,1                     ; offset p©ede¨l‚ho znaku
         sbb       cx,0
         dec       si                       ; adresa p©ede¨l‚ho znaku

; ------ nastaven¡ ukazatel– pro konec hled n¡

         mov       ds:[EdiHledB],bx         ; blok ukazatele hled n¡
         mov       ds:[EdiHledO],si         ; offset ukazatele hled n¡
         mov       word ptr ds:[InfoKCit],ax ; ‡¡ta‡ ukazatele operace
         mov       word ptr ds:[InfoKCit+2],cx
         add       ax,1
         adc       cx,0
         mov       word ptr ds:[EdiHledN],ax ; celkem bajt–
         mov       word ptr ds:[EdiHledN+2],cx

; ------ test, zda je pokra‡ov n¡ v hled n¡ od kurzoru vp©ed

         test      byte ptr ds:[EdiHldP2],bit0 ; je pokra‡ov n¡ v hled n¡ ?
         jz        EdHlIBO5                 ; nen¡ pokra‡ov n¡ v hled n¡
         test      byte ptr ds:[EdiHledP],bit0 ; je hled n¡ vp©ed ?
         jnz       EdHlIBO5                 ; nen¡ hled n¡ vp©ed

; ------ kontrola, zda je kurzor uvnit© bloku

         call      EdiHlKBO                 ; test, zda je kurzor uvnit© bloku
         jc        EdHlIBO5                 ; kurzor nen¡ uvnit© bloku
         add       ax,1                     ; offset dal¨¡ho znaku
         adc       cx,0
         inc       si                       ; adresa dal¨¡ho znaku
         jmp       short EdHlIBO7           ; kurzor vyhovuje

; ------ offset a adresa za‡ tku bloku -> CX:AX/BX:SI

EdHlIBO5:mov       ax,word ptr es:[EdiOBBlk] ; © dek za‡ tku bloku
         mov       cx,word ptr es:[EdiOBBlk+2]
         call      EdiGetAd                 ; v˜po‡et adresy za‡ tku bloku

; ------ korekce po‡tu bajt– k hled n¡

EdHlIBO7:sub       word ptr ds:[EdiHledN],ax ; po‡et zbyl˜ch bajt–
         sbb       word ptr ds:[EdiHledN+2],cx

; ------ offset za‡ tku k hled n¡ (je-li hled n¡ vp©ed)

         test      byte ptr ds:[EdiHledP],bit0 ; je hled n¡ zpˆt ?
         jnz       EdHlIBO9                 ; je hled n¡ zpˆt
         mov       ds:[EdiHledB],bx         ; blok ukazatele hled n¡
         mov       ds:[EdiHledO],si         ; offset ukazatele hled n¡
         mov       word ptr ds:[InfoKCit],ax
         mov       word ptr ds:[InfoKCit+2],cx
EdHlIBO9:ret

EdiHlIO  ENDP

; -----------------------------------------------------------------------------
;        inicializace ukazatel– pro hled n¡ v bloku v textov‚m m¢du
; -----------------------------------------------------------------------------

EdiHlIB  PROC      NEAR

; ------ test, zda je pokra‡ov n¡ v hled n¡ od kurzoru zpˆt

         test      byte ptr ds:[EdiHldP2],bit0 ; je pokra‡ov n¡ v hled n¡ ?
         jz        EdiHlIB1                 ; nen¡ pokra‡ov n¡ v hled n¡
         test      byte ptr ds:[EdiHledP],bit0 ; je hled n¡ zpˆt ?
         jz        EdiHlIB1                 ; nen¡ hled n¡ zpˆt

; ------ kontrola, zda je kurzor uvnit© bloku

         call      EdiHlKB                  ; test, zda je kurzor uvnit© bloku
         jnc       EdiHlIB4                 ; kurzor je uvnit© bloku OK

; ------ © dek konce bloku -> CX:AX

EdiHlIB1:mov       ax,word ptr es:[EdiRKBlk] ; © dek konce bloku
         mov       cx,word ptr es:[EdiRKBlk+2]
         test      byte ptr es:[EdiParm],bit7 ; je © dkov˜ blok ?
         jz        EdiHlIB2                 ; nen¡ © dkov˜ blok
         add       ax,1                     ; korekce © dku konce bloku
         adc       cx,0

; ------ adresa © dku konce bloku -> BX:SI

EdiHlIB2:call      EdiGetLn                 ; adresa konce bloku -> BX:SI
         jc        EdHlIB52                 ; chyba operace

; ------ pozice konce bloku -> BX:SI

         test      byte ptr es:[EdiParm],bit7 ; je © dkov˜ blok ?
         jnz       EdiHlIB3                 ; je © dkov˜ blok
         mov       ax,word ptr es:[EdiPKBlk] ; pozice konce bloku
         mov       cx,word ptr es:[EdiPKBlk+2]
         push      di
         call      EditGetP                 ; nalezen¡ pozice v © dku -> BX:SI
         pop       di
         jc        EdHlIB52                 ; chyba operace

; ------ offset konce bloku -> CX:AX

EdiHlIB3:call      EdiGetOf                 ; v˜po‡et offsetu konce bloku

; ------ posun na posledn¡ znak v bloku (nebo na znak p©ed kurzorem)

EdiHlIB4:sub       ax,1                     ; offset p©ede¨l‚ho znaku
         sbb       cx,0
         dec       si                       ; adresa p©ede¨l‚ho znaku

; ------ nastaven¡ ukazatel– pro konec hled n¡

         mov       ds:[EdiHledB],bx         ; blok ukazatele hled n¡
         mov       ds:[EdiHledO],si         ; offset ukazatele hled n¡
         mov       word ptr ds:[InfoKCit],ax ; ‡¡ta‡ ukazatele operace
         mov       word ptr ds:[InfoKCit+2],cx
         add       ax,1
         adc       cx,0
         mov       word ptr ds:[EdiHledN],ax ; celkem bajt–
         mov       word ptr ds:[EdiHledN+2],cx

; ------ test, zda je pokra‡ov n¡ v hled n¡ od kurzoru vp©ed

         test      byte ptr ds:[EdiHldP2],bit0 ; je pokra‡ov n¡ v hled n¡ ?
         jz        EdiHlIB5                 ; nen¡ pokra‡ov n¡ v hled n¡
         test      byte ptr ds:[EdiHledP],bit0 ; je hled n¡ vp©ed ?
         jnz       EdiHlIB5                 ; nen¡ hled n¡ vp©ed

; ------ kontrola, zda je kurzor uvnit© bloku

         call      EdiHlKB                  ; test, zda je kurzor uvnit© bloku
         jc        EdiHlIB5                 ; kurzor nen¡ uvnit© bloku
         add       ax,1                     ; offset dal¨¡ho znaku
         adc       cx,0
         inc       si                       ; adresa dal¨¡ho znaku
         jmp       short EdiHlIB7           ; kurzor vyhovuje

; ------ adresa © dku za‡ tku bloku -> BX:SI

EdiHlIB5:mov       ax,word ptr es:[EdiRBBlk] ; © dek za‡ tku bloku
         mov       cx,word ptr es:[EdiRBBlk+2]
         call      EdiGetLn                 ; adresa za‡ tku bloku
         jc        EdHlIB52                 ; chyba operace

; ------ pozice za‡ tku bloku -> BX:SI

         test      byte ptr es:[EdiParm],bit7 ; je © dkov˜ blok ?
         jnz       EdiHlIB6                 ; je © dkov˜ blok
         mov       ax,word ptr es:[EdiPBBlk] ; pozice za‡ tku bloku
         mov       cx,word ptr es:[EdiPBBlk+2]
         push      di
         call      EditGetP                 ; nalezen¡ pozice v © dku
         pop       di
EdHlIB52:jc        EdiHlIB9                 ; chyba operace

; ------ offset za‡ tku bloku -> CX:AX

EdiHlIB6:call      EdiGetOf                 ; v˜po‡et offsetu konce bloku

; ------ korekce po‡tu bajt– k hled n¡

EdiHlIB7:sub       word ptr ds:[EdiHledN],ax ; po‡et zbyl˜ch bajt–
         sbb       word ptr ds:[EdiHledN+2],cx

; ------ offset za‡ tku k hled n¡ (je-li hled n¡ vp©ed)

         test      byte ptr ds:[EdiHledP],bit0 ; je hled n¡ zpˆt ?
         jnz       EdiHlIB9                 ; je hled n¡ zpˆt
         mov       ds:[EdiHledB],bx         ; blok ukazatele hled n¡
         mov       ds:[EdiHledO],si         ; offset ukazatele hled n¡
         mov       word ptr ds:[InfoKCit],ax
         mov       word ptr ds:[InfoKCit+2],cx
EdiHlIB9:ret

EdiHlIB  ENDP

; -----------------------------------------------------------------------------
;        test, zda je kurzor uvnit© bloku -> CX:AX, BX:SI kurzor, CY=nen¡
; -----------------------------------------------------------------------------

EdiHlKB  PROC      NEAR

; ------ test, zda je kurzor platn˜

         test      byte ptr es:[di+EdiParm1],bit0 ; je kurzor zobrazen ?
         jnz       EdiHlKB8                 ; je zobrazen¡ - kurzor nen¡ platn˜

; ------ test, zda je © dkov˜ blok

         mov       si,EdiPBBlk              ; ukazatel za‡ tku bloku
         test      byte ptr es:[EdiParm],bit7 ; je © dkov˜ blok ?
         jz        EdiHlKB3                 ; nen¡ © dkov˜ blok

; ------ kontrola © dku za‡ tku bloku

         call      EdiChPBK                 ; kontrola © dku kurzoru
         jb        EdiHlKB9                 ; chyba - je p©ed © dkem po‡ tku

; ------ kontrola © dku konce bloku

         mov       si,EdiPKBlk              ; ukazatel konce bloku
         call      EdiChPBK                 ; kontrola © dku kurzoru
         je        EdiHlKB9                 ; © dek s koncem je OK
         jmp       short EdiHlKB8           ; jinak za © dkem konce = chyba

; ------ kontrola © dku za‡ tku bloku

EdiHlKB3:call      EdiChPBK                 ; kontrola © dku kurzoru
         jne       EdiHlKB4                 ; nen¡ © dek po‡ tku bloku

; ------ kontrola pozice za‡ tku bloku

         call      EdiChPBP                 ; kontrola pozice kurzoru
EdiHlKB4:jb        EdiHlKB9                 ; chyba - je p©ed pozic¡ po‡ tku

; ------ kontrola © dku konce bloku

         mov       si,EdiPKBlk              ; ukazatel konce bloku
         call      EdiChPBK                 ; kontrola © dku kurzoru
         jne       EdiHlKB8                 ; nen¡ posledn¡ © dek bloku

; ------ kontrola pozice konce bloku

         call      EdiChPBP                 ; kontrola pozice kurzoru

; ------ ukazatel kurzoru

EdiHlKB8:cmc                                ; CY=nen¡ v bloku
EdiHlKB9:mov       ax,word ptr es:[di+EdiOffsK] ; offset kurzoru
         mov       cx,word ptr es:[di+EdiOffsK+2]
         mov       bx,es:[di+EdiBBKur]      ; blok s kurzorem
         mov       si,es:[di+EdiOfKur]      ; offset s kurzorem
         ret

EdiHlKB  ENDP

; -----------------------------------------------------------------------------
;        test, zda je kurzor uvnit© bloku v m¢du BIN a HEX
; -----------------------------------------------------------------------------

EdiHlKBO PROC      NEAR

; ------ test, zda je kurzor platn˜

         test      byte ptr es:[di+EdiParm1],bit0 ; je kurzor zobrazen ?
         jnz       EdiHlKB8                 ; je zobrazen¡ - kurzor nen¡ platn˜

; ------ kontrola offsetu za‡ tku bloku

         mov       si,EdiPBBlk              ; ukazatel za‡ tku bloku
         call      EdiChPBO                 ; porovn n¡ kurzoru s offsetem za‡ tku
         jc        EdiHKBO9                 ; kurzor nen¡ za po‡ tkem bloku

; ------ kontrola offsetu konce bloku

         mov       si,EdiPKBlk              ; ukazatel konce bloku
         call      EdiChPBO                 ; porovn n¡ kurzoru s offsetem konce
         cmc                                ; CY=nen¡ p©ed koncem bloku
EdiHKBO9:jmp       short EdiHlKB9           ; nastaven¡ parametr– kurzoru

EdiHlKBO ENDP

; -----------------------------------------------------------------------------
;        hled n¡ textu (okno DX, ES:DI)
; -----------------------------------------------------------------------------
; lok ln¡ promˆnn‚: SS:[BP-2] (2) ‡¡slo okna (DX)
;                   SS:[BP-4] (2) offset okna (DI)
;                   SS:[BP-6] (2) adresa konverzn¡ tabulky v z sobn¡ku
;                   SS:[BP-8] (2) ukazatel ‡¡sla bloku
;                   SS:[BP-10] (2) offset ukazatele hled n¡
;                   SS:[BP-14] (4) ‡¡ta‡ zbyl˜ch dat k hled n¡
; -----------------------------------------------------------------------------
;þ
EditHled PROC      NEAR

; ------ £schova registr– (nˆkter˜ch)

         push      bp
         mov       bp,sp
         sub       sp,256 + 14

; ------ p©¡prava lok ln¡ch promˆnn˜ch

         and       byte ptr ds:[EdiHldP2],not bit7+bit6 ; nen¡ ©etˆzec+dotaz+sloupc.
         mov       ss:[bp-2],dx             ; ‡¡slo okna
         mov       ss:[bp-4],di             ; offset okna
         mov       ss:[bp-6],sp             ; adresa konverzn¡ tabulky 256 bajt–
         mov       ax,ds:[EdiHledB]         ; blok ukazatele hled n¡
         mov       ss:[bp-8],ax             ; ukazatel ‡¡sla bloku
         mov       ax,ds:[EdiHledO]         ; offset ukazatele hled n¡
         mov       ss:[bp-10],ax            ; offset ukazatele

         mov       ax,word ptr ds:[EdiHledN] ; ‡¡ta‡ dat k hled n¡ LOW
         mov       cx,word ptr ds:[EdiHledN+2] ; ‡¡ta‡ dat k hled n¡ HIGH
         mov       bx,ds:[TextFndN]         ; d‚lka hledan‚ho textu
         dec       bx                       ; bez 1 znaku
         sub       ax,bx                    ; rezerva pro ©etˆzec
         sbb       cx,0
         mov       ss:[bp-14+2],cx          ; ‡¡ta‡ zbyl˜ch dat HIGH
         mov       ss:[bp-14],ax            ; ‡¡ta‡ zbyl˜ch dat LOW

; ------ inicializace konverzn¡ tabulky (p©¡prava do z sobn¡ku)

         call      EdiHKIni                 ; p©¡prava konverzn¡ tabulky

; ------ kontrola platnosti ‡¡ta‡e zbyl˜ch dat

EditHld1:mov       ax,ss:[bp-14+2]          ; ‡¡ta‡ dat HIGH
         or        ax,ax                    ; je ‡¡ta‡ platn˜ ?
         js        EditHl51                 ; neplatn  data

; ------ zobrazen¡ hl ¨en¡ o vyhled v n¡

         mov       si,offset EdiHlTxt       ; text "Hled m"
         call      far ptr InfDisp0         ; dek¢dov n¡ a zobrazen¡ hl ¨en¡
         xor       cx,cx                    ; CX <- 0
         call      far ptr InfoKurz         ; zobrazen¡ informa‡n¡ho © dku

; ------ p©¡prava dat

         mov       di,ss:[bp-14]            ; ‡¡ta‡ zbyl˜ch dat LOW
         mov       si,ss:[bp-10]            ; offset ukazatele hled n¡
         mov       ah,byte ptr ds:[TextFndN] ; d‚lka dat k hled n¡
         dec       ah                       ; d‚lka dat - 1
         mov       dx,word ptr ds:[TextFnd] ; prvn¡ a druh˜ znak ©etˆzce
         xor       cx,cx                    ; CX <- 0 kurzor se neposune

; ------ hled n¡ vp©ed

         test      byte ptr ds:[EdiHledP],bit0 ; je hled n¡ zpˆt ?
         jnz       EditHld3                 ; je hled n¡ zpˆt

         test      byte ptr ds:[EdiHldP2],bit1 ; je v ©etˆzci otazn¡k ?
         jnz       EditHld2                 ; v ©etˆzci je otazn¡k
         call      EdiHldF                  ; hled n¡ vp©ed bez otazn¡ku
         jmp       short EditHld5

EditHld2:call      EdiHlOF                  ; hled n¡ vp©ed s otazn¡kem
         jmp       short EditHld5

; ------ hled n¡ zpˆt

EditHld3:test      byte ptr ds:[EdiHldP2],bit1 ; je v ©etˆzci otazn¡k ?
         jnz       EditHld4                 ; v ©etˆzci je otazn¡k
         call      EdiHldB                  ; hled n¡ zpˆt bez otazn¡ku
         jmp       short EditHld5

EditHld4:call      EdiHlOB                  ; hled n¡ zpˆt s otazn¡kem

; ------ n vrat ukazatel– okna (CY=nenalezen)

EditHld5:mov       ss:[bp-14],di            ; nov˜ ‡¡ta‡ zbyl˜ch bajt– LOW
         mov       ss:[bp-10],si            ; nov˜ offset ukazatele hled n¡
         mov       dx,ss:[bp-2]             ; ‡¡slo okna
         mov       di,ss:[bp-4]             ; adresa okna
         jnc       EditHl52                 ; ©etˆzec nalezen OK
EditHl51:jmp       EditHld9                 ; ©etˆzec nenalezen

; ------ normalizace ukazatele nalezen‚ho ©etˆzce -> BX:SI

EditHl52:or        byte ptr ds:[EdiHldP2],bit0+bit7 ; p©¡znak nalezen¡ ©etˆzce
         call      EditHlNm                 ; normalizace bloku dat
         call      EditGetD                 ; obnoven¡ adresy okna -> ES
         mov       bx,ss:[bp-8]             ; ukazatel ‡¡sla bloku

; ------ nastaven¡ kurzoru na nalezenou pozici a © dek

         push      bp
         push      si

         push      di
         call      EdiBORad                 ; p©evod offsetu na © dek a pozici
         mov       si,di                    ; SI <- pozice LOW
         pop       di
         call      EditSetP                 ; nastaven¡ pozice kurzoru

         pop       si
         pop       bp

; ------ uzav©en¡ informa‡n¡ho © dku

         call      far ptr InfoClos         ; uzav©en¡ informa‡n¡ho © dku

; ------ test, zda m  b˜t n hrada textu

         test      byte ptr ds:[EdiHledP],bit6 ; je n hrada textu ?
         jnz       EditHl58                 ; je n hrada textu
         jmp       EditHldA                 ; nen¡ n hrada textu

; ------ test, zda bude ©etˆzec nahrazen bez dotazu

EditHl58:test      byte ptr ds:[EdiHledP],bit5 ; bez dotazu ?
         jnz       EditHl72                 ; n hrada bez dotazu
         test      byte ptr ds:[EdiHldP2],bit6 ; v¨echny dal¨¡ bez dotazu ?
         jnz       EditHl72                 ; v¨echny dal¨¡ bez dotazu

; ------ dotaz, zda m  b˜t ©etˆzec nahrazen

EditHld6:call      EditGetD                 ; adresa okna -> ES
         or        byte ptr es:[di+EdiParm2],bit3 ; p©¡znak dotazu p©i n hradˆ
         mov       si,offset EdiHlTx4       ; text hl ¨en¡
         call      far ptr InfDisp0         ; zobrazen¡ hl ¨en¡
         mov       ax,dx                    ; AX <- segment okna
         call      DispEdi                  ; zobrazen¡ okna AX
         call      far ptr InpChar          ; ‡ek n¡ na vstup znaku z kl vesnice
         call      far ptr InfoClos         ; uzav©en¡ informa‡n¡ho © dku
         call      EditGetD                 ; obnoven¡ adresy okna -> ES
         and       byte ptr es:[di+EdiParm2],not bit3 ; zru¨en¡ p©¡znaku dotazu
         xchg      ax,bx                    ; AX <- znak z kl vesnice
         mov       ah,0                     ; sta‡¡ jen ASCII znak
         call      far ptr UpCase           ; konverze na velk‚ p¡smeno
         xchg      ax,bx                    ; BX <- n vrat znaku z kl vesnice
         call      far ptr JumpBX           ; obsluha znaku

         dw        "A",EditHl72             ; n hrada ©etˆzce
         dw        "N",EditHl79             ; dal¨¡ hled n¡
         dw        "V",EditHld7             ; v¨echny dal¨¡ bez dotazu
         dw        ESCP,EditHl92            ; p©eru¨en¡ operace
         dw        0,EditHld6               ; neplatn˜ znak

; ------ n hrada ©etˆzce

EditHld7:or        byte ptr ds:[EdiHldP2],bit6 ; v¨echny dal¨¡ bez dotazu
EditHl72:call      EditHNh                  ; n hrada ©etˆzce
         call      EditGt0D                 ; obnoven¡ adresy okna -> ES

; ------ aktualizace ‡¡ta‡e zbyl˜ch dat (DX/ES:DI=definice okna)

         pushf
         jc        EditHl76                 ; byla chyba operace

         xor       cx,cx                    ; CX <- 0
         mov       ax,ds:[TextSubN]         ; d‚lka n hradn¡ho textu
         sub       ax,ds:[TextFndN]         ; po‡et p©idan˜ch znak–
         sbb       cx,cx
         add       ss:[bp-14],ax            ; oprava d‚lky zbyl‚ho textu
         adc       ss:[bp-14+2],cx

; ------ korekce ukazatel– blok– a zna‡ek po p©id n¡ CX:AX znak– za kurzor

         push      bp
         mov       bp,offset EdiChPBN       ; aktualizace ukazatel–
         call      EdiChPBA                 ; obsluha korekc¡
         pop       bp

; ------ aktualizace oken

EditHl76:call      EditModA                 ; po‘adavek aktualizace okna
         call      EditAktW                 ; aktualizace kurzoru
         mov       ax,dx                    ; AX <- segment okna
         call      DispEdi                  ; zobrazen¡ okna AX
         popf
         jc        EditHldA                 ; p©eru¨en¡ operace p©i chybˆ

; ------ test, zda m  b˜t dal¨¡ ©etˆzec (posun o AX znak–)

         mov       ax,ds:[TextSubN]         ; d‚lka n hradn¡ho textu
EditHl78:test      byte ptr ds:[EdiHldP2],bit6 ; v¨e bez dotazu ?
         jnz       EdiHl780                 ; v¨echny bez dotazu
         test      byte ptr ds:[EdiHledP],bit2 ; m  b˜t dal¨¡ hled n¡ ?
         jz        EditHldA                 ; nen¡ dal¨¡ hled n¡

; ------ sn¡‘en¡ ‡¡ta‡e zbyl˜ch dat

EdiHl780:or        ax,ax                    ; je n hradn¡ text = 0 ?
         jnz       EdiHl781                 ; je n hradn¡ text
         add       word ptr ss:[bp-14],1    ; n vrat ‡¡ta‡e znak–
         adc       word ptr ss:[bp-14+2],0
         jmp       short EdiHl782           ; dal¨¡ hled n¡

EdiHl781:dec       ax                       ; 1 znak ji‘ byl po‡¡t n
         sub       word ptr ss:[bp-14],ax   ; sn¡‘en¡ ‡¡ta‡e zbyl˜ch znak–
         sbb       word ptr ss:[bp-14+2],0
         jc        EditHldA                 ; nen¡ dal¨¡ hled n¡
         inc       ax                       ; n vrat d‚lky posunu

; ------ posun ukazatele

         add       word ptr ss:[bp-10],ax   ; zv˜¨en¡ offsetu ukazatele
         test      byte ptr ds:[EdiHledP],bit0 ; je hled n¡ zpˆt ?
         jz        EdiHl782                 ; nen¡ hled n¡ zpˆt
         shl       ax,1                     ; 2*d‚lka ©etˆzce
         sub       word ptr ss:[bp-10],ax   ; posun ukazatele zpˆt
EdiHl782:jmp       EditHld1                 ; dal¨¡ ©etˆzec

EditHl79:mov       ax,1                     ; posun o 1 znak
         jmp       short EditHl78

; ------ chyba - text nenalezen

EditHld9:call      EditGetD                 ; obnoven¡ adresy okna -> ES
         call      far ptr InfoClos         ; uzav©en¡ informa‡n¡ho © dku
         call      far ptr TestBEsc         ; bylo p©eru¨en¡ operace ?
         jc        EditHl92                 ; je p©eru¨en¡
         test      byte ptr ds:[EdiHldP2],bit7+bit3 ; nalezen ©etˆzec/je zna‡ka?
         jnz       EditHl92                 ; ©etˆzec nalezen OK nebo je zna‡ka
         call      far ptr FlushChr         ; vypr zdnˆn¡ bufferu kl vesnice
         mov       ax,ds:[TextFndN]         ; d‚lka textu
         mov       ds:[EdNFMPl1],al         ; d‚lka textu pro hl ¨en¡
         mov       si,offset EdNFMLin       ; hl ¨en¡ - text nenalezen
         call      Edi0Menu                 ; hl ¨en¡
EditHl92:call      far ptr FlushChr         ; vypr zdnˆn¡ bufferu kl vesnice

; ------ n vrat registr–

EditHldA:mov       sp,bp
         pop       bp

; ------ aktualizace ukazatel– blok– po n hradˆ ©etˆzc–

         test      byte ptr ds:[EdiHledP],bit6 ; je n hrada textu ?
         jz        EditHldB                 ; nebyla n hrada textu
         test      byte ptr ds:[EdiHldP2],bit7 ; byl nalezen nˆjak˜ ©etˆzec ?
         jz        EditHldB                 ; ©etˆzec nebyl nalezen
         call      EdiChPBY                 ; p©epo‡et ukazatel– blok–
EditHldB:ret

EditHled ENDP

; -----------------------------------------------------------------------------
;        n hrada nalezen‚ho ©etˆzce (CY=chyba operace)
; -----------------------------------------------------------------------------

EditHNh  PROC      NEAR

; ------ £schova registr–

         push      di
         push      bp

; ------ adresa okna -> ES

         call      EditGetD                 ; adresa okna -> ES

; ------ zru¨en¡ nalezen‚ho ©etˆzce na pozici kurzoru

         xor       cx,cx                    ; CX <- 0 po‡et bajt– HIGH
         mov       ax,ds:[TextFndN]         ; d‚lka nalezen‚ho textu
         mov       bx,es:[di+EdiBBKur]      ; blok s kurzorem
         mov       si,es:[di+EdiOfKur]      ; offset s kurzorem
         call      EditDel                  ; zru¨en¡ bloku dat
         jc        EditHNh8                 ; chyba operace

; ------ vytvo©en¡ m¡sta pro n hradn¡ text

         mov       bp,offset TextSub        ; n hradn¡ text
         mov       ax,ds:[TextSubN]         ; po‘adovan˜ po‡et bajt– k vlo‘en¡
EditHNh2:mov       cx,ax                    ; CX <- po‡et zbyl˜ch bajt– k vlo‘en¡
         clc                                ; p©¡znak operace OK
         jcxz      EditHNh8                 ; nen¡ co vkl dat (je ji‘ v¨e hotovo)
         call      EditIns                  ; vytvo©en¡ m¡sta v bloku
         jc        EditHNh8                 ; chyba
         stc                                ; p©¡znak chyby
         jcxz      EditHNh8                 ; nen¡ m¡sto (?)

; ------ vlo‘en¡ ‡ sti textu

         sub       ax,cx                    ; sn¡‘en¡ zbyl‚ho m¡sta
         push      si
         mov       si,bp                    ; SI <- ukazatel dat
         add       bp,cx                    ; zv˜¨en¡ adresy
         cld
         rep       movsb                    ; p©enos ©etˆzce
         pop       si
         jmp       short EditHNh2           ; dal¨¡ ‡ st dat

; ------ n vrat registr–

EditHNh8:pop       bp
         pop       di
         ret

EditHNh  ENDP

; -----------------------------------------------------------------------------
;        aktualizace ukazatele ES:SI po vlo‘en¡/vyjmut¡ CX:AX znak– za kurzor
; -----------------------------------------------------------------------------

EdiChPBN PROC      NEAR

; ------ korekce offsetu ukazatele

         call      EdiChPBO                 ; porovn n¡ offsetu
         jae       EdChPBN2                 ; kurzor nen¡ p©ed ukazatelem
         add       es:[si+8],ax             ; korekce offsetu ukazatele
         adc       es:[si+8+2],cx

; ------ kontrola, zda to je © dek s kurzorem

EdChPBN2:test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je BIN/HEX m¢d ?
         jnz       EdChPBN4                 ; je BIN/HEX m¢d
         call      EdiChPBK                 ; je to © dek s kurzorem ?
         jne       EdChPBN4                 ; nen¡ to © dek s kurzorem

; ------ test, zda je kurzor p©ed ukazatelem

         call      EdiChPBP                 ; je kurzor p©ed ukazatelem ?
         jae       EdChPBN4                 ; kurzor nen¡ p©ed ukazatelem

; ------ korekce pozice ukazatele (ne pro sloupcov˜ blok)

         test      byte ptr ds:[EdiHldP2],bit4 ; je sloupcov˜ blok ?
         jnz       EdChPBN4                 ; je sloupcov˜ blok
         add       es:[si],ax               ; oprava pozice ukazatele
         adc       es:[si+2],cx
EdChPBN4:ret

EdiChPBN ENDP

; -----------------------------------------------------------------------------
;        p©¡prava konverzn¡ tabulky
; -----------------------------------------------------------------------------

EdiHKIni PROC      NEAR

; ------ inicializace konverzn¡ tabulky

         push      ss
         pop       es                       ; ES <- segment bufferu
         mov       di,ss:[bp-6]             ; DI <- adresa konverzn¡ tabulky
         mov       al,0                     ; AL <- 0
         cld
EdiHKIn2:stosb                              ; ulo‘en¡ znaku
         inc       al                       ; ‡¡ta‡ znak–
         jnz       EdiHKIn2                 ; ulo‘en¡ dal¨¡ho znaku

; ------ test, zda se bude prov dˆt konverze

         test      byte ptr ds:[EdiHledP],bit1 ; rozli¨uj¡ se p¡smena ?
         jz        EdiHKIn9                 ; rozli¨uj¡ se mal /velk  p¡smena

; ------ inicializace p¡smen ASCII

         sub       di,256-"a"               ; n vrat na p¡smeno "a"
         mov       al,"A"
EdiHKIn4:stosb                              ; ulo‘en¡ velk‚ho p¡smene
         inc       ax
         cmp       al,"Z"
         jbe       EdiHKIn4

; ------ p©¡prava konverzn¡ tabulky

         push      ds
         mov       al,ds:[EdiHlKod]         ; k¢d hled n¡
         mov       ah,0
         dec       ax                       ; je konverze ASCII ?
         jz        EdiHKIn8                 ; konverzn¡ tabulka nen¡
         mov       si,SEG CodeDek
         mov       ds,si                    ; DS <- segment k¢dovac¡ch tabulek
         mov       si,offset TbIBMUpC       ; konverze k¢du IBM na velk  p¡smena
         dec       ax                       ; je k¢d IBM ?
         jz        EdiHKIn6                 ; je k¢d IBM
         mov       si,offset TbKamUpC       ; konverze k¢du Kamenick˜ch na velk 
         dec       ax                       ; je k¢d Kamenick˜ch ?
         jz        EdiHKIn6                 ; je k¢d Kamenick˜ch
         mov       si,offset TbLatUpC       ; konverze k¢du Latin 2 na velk  p.
         dec       ax                       ; je k¢d Latin 2 ?
         jz        EdiHKIn6                 ; je k¢d Latin 2
         mov       si,offset TbKOIUpC       ; konverze k¢du KOI 8 na velk  p¡sm.
         dec       ax                       ; je k¢d KOI 8 ?
         jz        EdiHKIn6                 ; je k¢d KOI 8
         mov       si,offset TbWinUpC       ; konverze k¢du WINDOWS na velk  p.
EdiHKIn6:add       di,128-("z"+1)           ; adresa k ulo‘en¡ tabulky
         mov       cx,128                   ; d‚lka konverzn¡ tabulky
         rep       movsb                    ; p©enos konverzn¡ tabulky
EdiHKIn8:pop       ds
EdiHKIn9:ret

EdiHKIni ENDP

; ------ normalizace bloku dat SI -> ES:SI/CX/BX

EditHlNm PROC      NEAR

         push      dx
         mov       dx,ss:[bp-2]             ; ‡¡slo okna
         mov       bx,ss:[bp-8]             ; ukazatel ‡¡sla bloku
         call      EditNGet                 ; poskytnut¡ bloku dat
         mov       ss:[bp-8],bx             ; ukazatel ‡¡sla bloku
         mov       bx,ss:[bp-6]             ; adresa konverzn¡ tabulky
         pop       dx
         ret

EditHlNm ENDP

; -----------------------------------------------------------------------------
;        hled n¡ vp©ed bez otazn¡ku
; -----------------------------------------------------------------------------

EdiHldF  PROC      NEAR

; ------ p©¡prava bloku dat (CX=posun kurzoru ukazatele operace)

EdiHldF1:call      far ptr InfoKurz         ; posun informa‡n¡ho kurzoru
         call      far ptr TestBEsc         ; test p©eru¨en¡ operace
         jc        EdiHldF8                 ; je p©eru¨en¡ operace
         call      EditHlNm                 ; normalizace bloku dat
         jz        EdiHldF8                 ; nejsou dal¨¡ data
         dec       si                       ; p©ednastaven¡

; ------ test, zda jsou dal¨¡ data pro 1. znak

EdiHldF2:inc       si                       ; posun ukazatele dat
         cmp       si,cx                    ; je platn˜ ukazatel ?
         jae       EdiHldF1                 ; nen¡ platn˜ ukazatel

; ------ na‡ten¡ prvn¡ho znaku ©etˆzce

         mov       al,es:[si]               ; p©ipraven˜ znak
         xlat      byte ptr ss:[bx]         ; konverze jednoho znaku

; ------ ‡¡ta‡ zbyl˜ch dat

         sub       di,1                     ; ‡¡ta‡ zbyl˜ch dat
         jc        EdiHldF7                 ; p©ete‡en¡ ‡¡ta‡e dat LOW

; ------ porovn n¡ prvn¡ho znaku ©etˆzce

EdiHldF3:cmp       al,dl                    ; je to prvn¡ znak ©etˆzce ?
         jne       EdiHldF2                 ; nen¡ to hledan˜ ©etˆzec - dal¨¡

; ------ test, zda je druh˜ znak

         or        ah,ah                    ; bude 2. znak ?
         jz        EdiHldF6                 ; nebude 2. znak - ©etˆzec nalezen

; ------ test, zda jsou dal¨¡ data pro 2. znak

         inc       si                       ; posun ukazatele dat na 2. znak
         cmp       si,cx                    ; je platn˜ ukazatel ?
         jb        EdiHldF4                 ; jsou platn  data OK

; ------ p©¡prava dat pro druh˜ znak

         call      EditHlNm                 ; normalizace bloku dat
         jz        EdiHldF8                 ; nejsou dal¨¡ data

; ------ na‡ten¡ druh‚ho znaku ©etˆzce

EdiHldF4:mov       al,es:[si]               ; p©ipraven˜ znak
         xlat      byte ptr ss:[bx]         ; konverze znaku

; ------ n vrat ukazatele na za‡ tek ©etˆzce (aby se neposunul ukazatel kurzoru)

         dec       si                       ; n vrat ukazatele dat
         jns       EdiHldF5                 ; ukazatel je OK
         call      EditHlNm                 ; normalizace bloku dat
         jz        EdiHldF8                 ; chyba operace

; ------ porovn n¡ druh‚ho znaku ©etˆzce

EdiHldF5:cmp       al,dh                    ; je to druh˜ znak ©etˆzce ?
         jne       EdiHldF2                 ; znak nesouhlas¡

; ------ souhlas¡ 2 znaky - test, zda jsou dal¨¡ znaky ©etˆzce

         cmp       ah,1                     ; jsou dal¨¡ znaky ©etˆzce ?
         je        EdiHldF6                 ; nejsou dal¨¡ znaky ©etˆzce

; ------ porovn n¡ zbytku ©etˆzce (1. a 2. znak je OK)

         call      EdiHlCmp                 ; porovn n¡ zbytku ©etˆzce
         jc        EdiHldF2                 ; dal¨¡ hled n¡

; ------ ©etˆzec cel˜ souhlas¡ - test, zda je to slovo

EdiHldF6:call      EdiHlWrd                 ; test, zda je ©etˆzec slovo
         jc        EdiHldF2                 ; nen¡ slovo - dal¨¡ hled n¡

; ------ test, zda je ve sloupcov‚m bloku

         call      EdiHlSlo                 ; test, zda je ve sloupcov‚m bloku
         jc        EdiHldF2                 ; nen¡ ve sloupcov‚m bloku

; ------ ‡¡t n¡ v˜skytu ©etˆzce

         call      EdiHlCit                 ; ‡¡t n¡ v˜skytu ©etˆzce
         jc        EdiHldF2                 ; nen¡ je¨tˆ nalezen
         ret                                ; (zde je NC) ©etˆzec souhlas¡ OK

; ------ ‡¡t n¡ zbyl˜ch dat HIGH

EdiHldF7:sbb       word ptr ss:[bp-14+2],0  ; ‡¡ta‡ zbyl˜ch dat HIGH
         jnc       EdiHldF3                 ; dal¨¡ data

; ------ p©¡znak nenalezen¡ ©etˆzce

EdiHldF8:stc                                ; p©¡znak nenalezen¡ ©etˆzce
         ret

EdiHldF  ENDP

; -----------------------------------------------------------------------------
;        hled n¡ vp©ed s otazn¡kem
; -----------------------------------------------------------------------------

EdiHlOF  PROC      NEAR

; ------ p©¡prava bloku dat (CX=posun kurzoru ukazatele operace)

EdiHlOF1:call      far ptr InfoKurz         ; posun informa‡n¡ho kurzoru
         call      far ptr TestBEsc         ; test p©eru¨en¡ operace
         jc        EdiHlOF8                 ; je p©eru¨en¡ operace
         call      EditHlNm                 ; normalizace bloku dat
         jz        EdiHlOF8                 ; nejsou dal¨¡ data
         dec       si                       ; p©ednastaven¡

; ------ test, zda jsou dal¨¡ data pro 1. znak

EdiHlOF2:inc       si                       ; posun ukazatele dat
         cmp       si,cx                    ; je platn˜ ukazatel ?
         jae       EdiHlOF1                 ; nen¡ platn˜ ukazatel

; ------ na‡ten¡ prvn¡ho znaku ©etˆzce -> AL

         mov       al,es:[si]               ; p©ipraven˜ znak
         xlat      byte ptr ss:[bx]         ; konverze jednoho znaku

; ------ ‡¡ta‡ zbyl˜ch dat

         sub       di,1                     ; ‡¡ta‡ zbyl˜ch dat
         jc        EdiHlOF7                 ; p©ete‡en¡ ‡¡ta‡e dat LOW

; ------ porovn n¡ prvn¡ho znaku ©etˆzce

EdiHlOF3:cmp       dl,"?"                   ; je otazn¡k ?
         je        EdiHOF34                 ; ©etˆzec vyhovuje OK
         cmp       al,dl                    ; je to prvn¡ znak ©etˆzce ?
         jne       EdiHlOF2                 ; nen¡ to hledan˜ ©etˆzec - dal¨¡

; ------ test, zda je druh˜ znak

EdiHOF34:or        ah,ah                    ; bude 2. znak ?
         jz        EdiHlOF6                 ; nebude 2. znak - ©etˆzec nalezen

; ------ test, zda jsou dal¨¡ data pro 2. znak

         inc       si                       ; posun ukazatele dat na 2. znak
         cmp       si,cx                    ; je platn˜ ukazatel ?
         jb        EdiHlOF4                 ; je platn˜ ukazatel

; ------ p©¡prava dat pro druh˜ znak

         call      EditHlNm                 ; normalizace bloku dat
         jz        EdiHlOF8                 ; nejsou dal¨¡ data

; ------ na‡ten¡ druh‚ho znaku ©etˆzce -> AL

EdiHlOF4:mov       al,es:[si]               ; p©ipraven˜ znak
         xlat      byte ptr ss:[bx]         ; konverze znaku

; ------ n vrat ukazatele na za‡ tek ©etˆzce (aby se neposunul ukazatel kurzoru)

         dec       si                       ; n vrat ukazatele dat
         jns       EdiHlOF5                 ; ukazatel je OK
         call      EditHlNm                 ; normalizace bloku dat
         jz        EdiHlOF8                 ; chyba operace

; ------ porovn n¡ druh‚ho znaku ©etˆzce

EdiHlOF5:cmp       dh,"?"                   ; je n hradn¡ znak ?
         je        EdiHOF54                 ; je n hradn¡ znak
         cmp       al,dh                    ; je to druh˜ znak ©etˆzce ?
         jne       EdiHlOF2                 ; nesouhlas¡ - pokra‡ov n¡

; ------ souhlas¡ 2 znaky - test, zda jsou dal¨¡ znaky ©etˆzce

EdiHOF54:cmp       ah,1                     ; jsou dal¨¡ znaky ©etˆzce ?
         je        EdiHlOF6                 ; nejsou dal¨¡ znaky ©etˆzce

; ------ porovn n¡ zbytku ©etˆzce (1. a 2. znak je OK)

         call      EdiHOCmp                 ; porovn n¡ zbytku ©etˆzce
         jc        EdiHlOF2                 ; dal¨¡ hled n¡

; ------ ©etˆzec cel˜ souhlas¡ - test, zda je to slovo

EdiHlOF6:call      EdiHlWrd                 ; test, zda je ©etˆzec slovo
         jc        EdiHlOF2                 ; nen¡ slovo - dal¨¡ hled n¡

; ------ test, zda je ve sloupcov‚m bloku

         call      EdiHlSlo                 ; test, zda je ve sloupcov‚m bloku
         jc        EdiHlOF2                 ; nen¡ ve sloupcov‚m bloku

; ------ ‡¡t n¡ v˜skytu ©etˆzce

         call      EdiHlCit                 ; ‡¡t n¡ v˜skytu ©etˆzce
         jc        EdiHlOF2                 ; nen¡ je¨tˆ nalezen
         ret                                ; ©etˆzec souhlas¡ OK

; ------ ‡¡t n¡ zbyl˜ch dat

EdiHlOF7:sbb       word ptr ss:[bp-14+2],0  ; ‡¡ta‡ zbyl˜ch dat HIGH
         jnc       EdiHlOF3                 ; dal¨¡ data

; ------ p©¡znak nenalezen¡ ©etˆzce

EdiHlOF8:stc                                ; p©¡znak nenalezen¡ ©etˆzce
         ret

EdiHlOF  ENDP

; -----------------------------------------------------------------------------
;        hled n¡ zpˆt bez otazn¡ku
; -----------------------------------------------------------------------------

EdiHldB  PROC      NEAR

; ------ p©¡prava bloku dat (CX=posun kurzoru ukazatele operace)

EdiHldB1:call      far ptr InfoKurD         ; posun informa‡n¡ho kurzoru zpˆt
         call      far ptr TestBEsc         ; test p©eru¨en¡ operace
         jc        EdiHldB8                 ; je p©eru¨en¡ operace
         call      EditHlNm                 ; normalizace bloku dat
         jz        EdiHldB8                 ; nejsou dal¨¡ data
         inc       si                       ; p©ednastaven¡

; ------ test, zda jsou dal¨¡ data pro 1. znak

EdiHldB2:dec       si                       ; posun ukazatele dat
         cmp       si,cx                    ; je platn˜ ukazatel ?
         jae       EdiHldB1                 ; nen¡ platn˜ ukazatel

; ------ na‡ten¡ prvn¡ho znaku ©etˆzce

         mov       al,es:[si]               ; p©ipraven˜ znak
         xlat      byte ptr ss:[bx]         ; konverze jednoho znaku

; ------ ‡¡ta‡ zbyl˜ch dat

         sub       di,1                     ; ‡¡ta‡ zbyl˜ch dat
         jc        EdiHldB7                 ; p©ete‡en¡ ‡¡ta‡e dat LOW

; ------ porovn n¡ prvn¡ho znaku ©etˆzce

EdiHldB3:cmp       al,dl                    ; je to prvn¡ znak ©etˆzce ?
         jne       EdiHldB2                 ; nen¡ to hledan˜ ©etˆzec - dal¨¡

; ------ test, zda je druh˜ znak

         or        ah,ah                    ; bude 2. znak ?
         jz        EdiHldB6                 ; nebude 2. znak - ©etˆzec nalezen

; ------ test, zda jsou dal¨¡ data pro 2. znak

         inc       si                       ; posun ukazatele dat na 2. znak
         cmp       si,cx                    ; je platn˜ ukazatel ?
         jb        EdiHldB4                 ; jsou platn  data OK

; ------ p©¡prava dat pro druh˜ znak

         call      EditHlNm                 ; normalizace bloku dat
         jz        EdiHldB8                 ; nejsou dal¨¡ data

; ------ na‡ten¡ druh‚ho znaku ©etˆzce

EdiHldB4:mov       al,es:[si]               ; p©ipraven˜ znak
         xlat      byte ptr ss:[bx]         ; konverze znaku

; ------ n vrat ukazatele na za‡ tek ©etˆzce (aby se neposunul ukazatel kurzoru)

         dec       si                       ; n vrat ukazatele dat
         jns       EdiHldB5                 ; ukazatel je OK
         call      EditHlNm                 ; normalizace bloku dat
         jz        EdiHldB8                 ; chyba operace

; ------ porovn n¡ druh‚ho znaku ©etˆzce

EdiHldB5:cmp       al,dh                    ; je to druh˜ znak ©etˆzce ?
         jne       EdiHldB2                 ; znak nesouhlas¡

; ------ souhlas¡ 2 znaky - test, zda jsou dal¨¡ znaky ©etˆzce

         cmp       ah,1                     ; jsou dal¨¡ znaky ©etˆzce ?
         je        EdiHldB6                 ; nejsou dal¨¡ znaky ©etˆzce

; ------ porovn n¡ zbytku ©etˆzce (1. a 2. znak je OK)

         call      EdiHlCmp                 ; porovn n¡ zbytku ©etˆzce
         jc        EdiHldB2                 ; dal¨¡ hled n¡

; ------ ©etˆzec cel˜ souhlas¡ - test, zda je to slovo

EdiHldB6:call      EdiHlWrd                 ; test, zda je ©etˆzec slovo
         jc        EdiHldB2                 ; nen¡ slovo - dal¨¡ hled n¡

; ------ test, zda je ve sloupcov‚m bloku

         call      EdiHlSlo                 ; test, zda je ve sloupcov‚m bloku
         jc        EdiHldB2                 ; nen¡ ve sloupcov‚m bloku

; ------ ‡¡t n¡ v˜skytu ©etˆzce

         call      EdiHlCit                 ; ‡¡t n¡ v˜skytu ©etˆzce
         jc        EdiHldB2                 ; nen¡ je¨tˆ nalezen
         ret                                ; (zde je NC) ©etˆzec souhlas¡ OK

; ------ ‡¡t n¡ zbyl˜ch dat HIGH

EdiHldB7:sbb       word ptr ss:[bp-14+2],0  ; ‡¡ta‡ zbyl˜ch dat HIGH
         jnc       EdiHldB3                 ; dal¨¡ data

; ------ p©¡znak nenalezen¡ ©etˆzce

EdiHldB8:stc                                ; p©¡znak nenalezen¡ ©etˆzce
         ret

EdiHldB  ENDP

; -----------------------------------------------------------------------------
;        hled n¡ zpˆt s otazn¡kem
; -----------------------------------------------------------------------------

EdiHlOB  PROC      NEAR

; ------ p©¡prava bloku dat (CX=posun kurzoru ukazatele operace)

EdiHlOB1:call      far ptr InfoKurD         ; posun informa‡n¡ho kurzoru zpˆt
         call      far ptr TestBEsc         ; test p©eru¨en¡ operace
         jc        EdiHlOB8                 ; je p©eru¨en¡ operace
         call      EditHlNm                 ; normalizace bloku dat
         jz        EdiHlOB8                 ; nejsou dal¨¡ data
         inc       si                       ; p©ednastaven¡

; ------ test, zda jsou dal¨¡ data pro 1. znak

EdiHlOB2:dec       si                       ; posun ukazatele dat
         cmp       si,cx                    ; je platn˜ ukazatel ?
         jae       EdiHlOB1                 ; nen¡ platn˜ ukazatel

; ------ na‡ten¡ prvn¡ho znaku ©etˆzce -> AL

         mov       al,es:[si]               ; p©ipraven˜ znak
         xlat      byte ptr ss:[bx]         ; konverze jednoho znaku

; ------ ‡¡ta‡ zbyl˜ch dat

         sub       di,1                     ; ‡¡ta‡ zbyl˜ch dat
         jc        EdiHlOB7                 ; p©ete‡en¡ ‡¡ta‡e dat LOW

; ------ porovn n¡ prvn¡ho znaku ©etˆzce

EdiHlOB3:cmp       dl,"?"                   ; je otazn¡k ?
         je        EdiHOB34                 ; ©etˆzec vyhovuje OK
         cmp       al,dl                    ; je to prvn¡ znak ©etˆzce ?
         jne       EdiHlOB2                 ; nen¡ to hledan˜ ©etˆzec - dal¨¡

; ------ test, zda je druh˜ znak

EdiHOB34:or        ah,ah                    ; bude 2. znak ?
         jz        EdiHlOB6                 ; nebude 2. znak - ©etˆzec nalezen

; ------ test, zda jsou dal¨¡ data pro 2. znak

         inc       si                       ; posun ukazatele dat na 2. znak
         cmp       si,cx                    ; je platn˜ ukazatel ?
         jb        EdiHlOB4                 ; je platn˜ ukazatel

; ------ p©¡prava dat pro druh˜ znak

         call      EditHlNm                 ; normalizace bloku dat
         jz        EdiHlOB8                 ; nejsou dal¨¡ data

; ------ na‡ten¡ druh‚ho znaku ©etˆzce -> AL

EdiHlOB4:mov       al,es:[si]               ; p©ipraven˜ znak
         xlat      byte ptr ss:[bx]         ; konverze znaku

; ------ n vrat ukazatele na za‡ tek ©etˆzce (aby se neposunul ukazatel kurzoru)

         dec       si                       ; n vrat ukazatele dat
         jns       EdiHlOB5                 ; ukazatel je OK
         call      EditHlNm                 ; normalizace bloku dat
         jz        EdiHlOB8                 ; chyba operace nebo konec dat

; ------ porovn n¡ druh‚ho znaku ©etˆzce

EdiHlOB5:cmp       dh,"?"                   ; je n hradn¡ znak ?
         je        EdiHOB54                 ; je n hradn¡ znak
         cmp       al,dh                    ; je to druh˜ znak ©etˆzce ?
         jne       EdiHlOB2                 ; dal¨¡ znak

; ------ souhlas¡ 2 znaky - test, zda jsou dal¨¡ znaky ©etˆzce

EdiHOB54:cmp       ah,1                     ; jsou dal¨¡ znaky ©etˆzce ?
         je        EdiHlOB6                 ; nejsou dal¨¡ znaky ©etˆzce

; ------ porovn n¡ zbytku ©etˆzce (1. a 2. znak je OK)

         call      EdiHOCmp                 ; porovn n¡ zbytku ©etˆzce
         jc        EdiHlOB2                 ; dal¨¡ hled n¡

; ------ ©etˆzec cel˜ souhlas¡ - test, zda je to slovo

EdiHlOB6:call      EdiHlWrd                 ; test, zda je ©etˆzec slovo
         jc        EdiHlOB2                 ; nen¡ slovo - dal¨¡ hled n¡

; ------ test, zda je ve sloupcov‚m bloku

         call      EdiHlSlo                 ; test, zda je ve sloupcov‚m bloku
         jc        EdiHlOB2                 ; nen¡ ve sloupcov‚m bloku

; ------ ‡¡t n¡ v˜skytu ©etˆzce

         call      EdiHlCit                 ; ‡¡t n¡ v˜skytu ©etˆzce
         jc        EdiHlOB2                 ; nen¡ je¨tˆ nalezen
         ret                                ; ©etˆzec souhlas¡ OK

; ------ ‡¡t n¡ zbyl˜ch dat

EdiHlOB7:sbb       word ptr ss:[bp-14+2],0  ; ‡¡ta‡ zbyl˜ch dat HIGH
         jnc       EdiHlOB3                 ; dal¨¡ data

; ------ p©¡znak nenalezen¡ ©etˆzce

EdiHlOB8:stc                                ; p©¡znak nenalezen¡ ©etˆzce
         ret

EdiHlOB  ENDP

; -----------------------------------------------------------------------------
;        porovn n¡ zbytku ©etˆzce bez otazn¡ku
; -----------------------------------------------------------------------------

EdiHlCmp PROC      NEAR

; ------ £schova registr–

         push      ax
         push      di

; ------ p©¡prava registr–

         dec       ah                       ; d‚lka textu - 2
         mov       di,offset TextFnd+1      ; ukazatel na 2. znak ©etˆzce
         inc       si                       ; posun na 2. znak

; ------ zv˜¨en¡ ukazatele dat

EdiHlCm2:inc       si                       ; posun na dal¨¡ znak dat
         inc       di                       ; posun na dal¨¡ znak ©etˆzce

; ------ zaji¨tˆn¡ na‡ten¡ dal¨¡ho znaku ©etˆzce

         cmp       si,cx                    ; jsou dal¨¡ data ?
         jb        EdiHlCm4                 ; jsou dal¨¡ data OK
         call      EditHlNm                 ; normalizace bloku dat
         jz        EdiHlCm6                 ; nejsou dal¨¡ data

; ------ porovn n¡ znaku ©etˆzce

EdiHlCm4:mov       al,es:[si]               ; p©ipraven˜ znak
         xlat      byte ptr ss:[bx]         ; konverze znaku
         cmp       al,ds:[di]               ; je to znak ©etˆzce ?
         jne       EdiHlCm6                 ; nen¡ to znak ©etˆzce

; ------ ‡¡ta‡ porovn van˜ch znak–

         dec       ah                       ; ‡¡ta‡ hledan˜ch znak–
         jnz       EdiHlCm2                 ; test dal¨¡ho znaku ©etˆzce
         jmp       short EdiHlCm8           ; ©etˆzec odpov¡d  OK (je NC !)

EdiHlCm6:stc                                ; p©¡znak nenalezen¡ ©etˆzce

; ------ n vrat ukazatele textu

EdiHlCm8:pushf
         sub       di,offset TextFnd        ; ukazatel textu
         sub       si,di                    ; n vrat offsetu dat zpˆt

; ------ normalizace ukazatele dat

         jns       EdiHlCm9                 ; ukazatel je OK
         call      EditHlNm                 ; normalizace bloku dat
EdiHlCm9:popf

; ------ n vrat registr–

         pop       di
         pop       ax
         ret

EdiHlCmp ENDP

; -----------------------------------------------------------------------------
;        porovn n¡ zbytku ©etˆzce s otazn¡kem
; -----------------------------------------------------------------------------

EdiHOCmp PROC      NEAR

; ------ £schova registr–

         push      ax
         push      di

; ------ p©¡prava registr–

         dec       ah                       ; d‚lka textu - 2
         mov       di,offset TextFnd+1      ; ukazatel na 2. znak ©etˆzce
         inc       si                       ; posun na 2. znak

; ------ zv˜¨en¡ ukazatele dat

EdiHOCm2:inc       si                       ; posun na dal¨¡ znak dat
         inc       di                       ; posun na dal¨¡ znak ©etˆzce

; ------ zaji¨tˆn¡ na‡ten¡ dal¨¡ho znaku ©etˆzce

         cmp       si,cx                    ; jsou dal¨¡ data ?
         jb        EdiHOCm4                 ; jsou dal¨¡ data OK
         call      EditHlNm                 ; normalizace bloku dat
         jz        EdiHlCm6                 ; nejsou dal¨¡ data

; ------ porovn n¡ znaku ©etˆzce

EdiHOCm4:cmp       byte ptr ds:[di],"?"     ; je n hradn¡ znak ?
         je        EdiHOCm5                 ; je n hradn¡ znak
         mov       al,es:[si]               ; p©ipraven˜ znak
         xlat      byte ptr ss:[bx]         ; konverze znaku
         cmp       al,ds:[di]               ; je to znak ©etˆzce ?
         jne       EdiHlCm6                 ; nen¡ to znak ©etˆzce

; ------ ‡¡ta‡ porovn van˜ch znak–

EdiHOCm5:dec       ah                       ; ‡¡ta‡ hledan˜ch znak–
         jnz       EdiHOCm2                 ; test dal¨¡ho znaku ©etˆzce
         jmp       short EdiHlCm8           ; ©etˆzec odpov¡d  OK (je NC !)

EdiHOCmp ENDP

; -----------------------------------------------------------------------------
;        test, zda je nalezen˜ ©etˆzec slovo (CY=nen¡)
; -----------------------------------------------------------------------------

EdiHlWrd PROC      NEAR

; ------ test, zda se kontroluj¡ slova

         test      byte ptr ds:[EdiHledP],bit4 ; slova ?
         jz        EdiHlWr9                 ; nejsou cel  slova - je to OK

; ------ £schova registr–

         push      ax
         push      dx
         xor       dx,dx                    ; DX <- 0 ‡¡ta‡ posunu ukazatele

; ------ na‡ten¡ znaku -> AH

         cmp       si,cx                    ; jsou data OK ?
         jb        EdiHlWr0                 ; data jsou OK
         call      EditHlNm                 ; normalizace bloku dat
EdiHlWr0:mov       ah,es:[si]               ; prvn¡ znak slova

; ------ n hrada oddˆlovac¡ho znaku p¡smenem (nenahrazuje se pro "?")

         cmp       byte ptr ds:[TextFnd]," " ; je to platn˜ znak ?
         ja        EdiHlWr1                 ; je to platn˜ znak OK
         mov       ah,"A"                   ; n hrada p¡smenem

; ------ na‡ten¡ p©ede¨l‚ho znaku -> AL

EdiHlWr1:dec       si                       ; posun k p©ede¨l‚mu znaku
         dec       dx                       ; posun ukazatele
         cmp       si,cx                    ; je to je¨tˆ OK ?
         jb        EdiHlWr2                 ; ukazatel je je¨tˆ OK
         call      EditHlNm                 ; normalizace bloku dat
         jz        EdiHlWr3                 ; mimo rozsah - za‡ tek slova je OK
EdiHlWr2:mov       al,es:[si]               ; znak p©ed slovem

; ------ test, zda to je za‡ tek slova

         call      far ptr TestWrd          ; test, zda je za‡ tek slova
         jc        EdiHlWr8                 ; nen¡ to slovo

; ------ na‡ten¡ znaku z konce ©etˆzce -> AL

EdiHlWr3:add       si,ds:[TextFndN]         ; posun na posledn¡ znak slova
         add       dx,ds:[TextFndN]         ; posun ukazatele
         cmp       si,cx                    ; je ukazatel je¨tˆ OK ?
         jb        EdiHlWr4                 ; ukazatel je je¨tˆ OK
         call      EditHlNm                 ; normalizace bloku dat
         jz        EdiHlWr7                 ; asi to je slovo
EdiHlWr4:mov       ah,es:[si]               ; posledn¡ znak slova

; ------ n hrada oddˆlovac¡ho znaku p¡smenem (nenahrazuje se pro "?")

         push      di
         mov       di,ds:[TextFndN]         ; DI <- d‚lka ©etˆzce
         cmp       byte ptr ds:[di+TextFnd-1]," " ; je posledn¡ znak platn˜ ?
         pop       di
         ja        EdiHlWr5                 ; je to platn˜ znak OK
         mov       ah,"A"                   ; n hrada p¡smenem

; ------ na‡ten¡ znaku za koncem ©etˆzce -> AL

EdiHlWr5:inc       si                       ; posun na n sleduj¡c¡ znak
         inc       dx                       ; posun ukazatele
         cmp       si,cx                    ; je ukazatel je¨tˆ OK ?
         jb        EdiHlWr6                 ; ukazatel je je¨tˆ OK
         call      EditHlNm                 ; normalizace bloku dat
         jz        EdiHlWr7                 ; nejsou dal¨¡ data - je to slovo
EdiHlWr6:mov       al,es:[si]               ; n sleduj¡c¡ znak za slovem

; ------ test, zda to je konec slova

         call      far ptr TestWrd          ; test, zda je konec slova
         jc        EdiHlWr8                 ; nen¡ to konec slova

; ------ je to slovo OK

EdiHlWr7:clc                                ; p©¡znak - je to slovo OK

; ------ n vrat ukazatele

EdiHlWr8:pushf
         sub       si,dx                    ; n vrat ukazatele
         cmp       si,cx                    ; je pot©ebn  normalizace ?
         jb        EdHlWr82                 ; nen¡ pot©ebn  normalizace
         call      EditHlNm                 ; normalizace bloku dat
EdHlWr82:popf

; ------ n vrat registr– (CY=chyba)

         pop       dx
         pop       ax
EdiHlWr9:ret

EdiHlWrd ENDP

; -----------------------------------------------------------------------------
;        ‡¡t n¡ v˜skytu ©etˆzce (CY=je¨tˆ nen¡ v˜skyt)
; -----------------------------------------------------------------------------

EdiHlCit PROC      NEAR

         cmp       word ptr ds:[EdiHledC],0 ; je ‡¡ta‡ = 0 ?
         jne       EdiHlCt4                 ; nen¡ = 0
         cmp       word ptr ds:[EdiHledC+2],0
         je        EdiHlCt6                 ; ‡¡ta‡ je ji‘ = 0

EdiHlCt4:sub       word ptr ds:[EdiHledC],1 ; ‡¡ta‡ v˜skytu ©etˆzc–
         sbb       word ptr ds:[EdiHledC+2],0
         stc                                ; p©¡znak nenalezen¡ ©etˆzce

EdiHlCt6:ret

EdiHlCit ENDP

; -----------------------------------------------------------------------------
;        test, zda je nalezen˜ ©etˆzec ve sloupcov‚m bloku (CY=nen¡)
; -----------------------------------------------------------------------------

EdiHlSlo PROC      NEAR

; ------ test, zda je sloupcov˜ blok

         test      byte ptr ds:[EdiHldP2],bit4 ; je sloupcov˜ blok ?
         jz        EdiHlSl9                 ; nen¡ sloupcov˜ blok

; ------ £schova registr–

         push      ax
         push      dx
         push      si
         push      di
         push      bp

; ------ v˜po‡et © dku+pozice z adresy BX:SI->CX:AX=© dek, BP:DI=pozice, ES=okno

         mov       dx,ss:[bp-2]             ; DX <- ‡¡slo okna
         mov       bx,ss:[bp-8]             ; ukazatel ‡¡sla bloku
         call      EdiBORad                 ; p©evod offsetu na © dek a pozici
         jc        EdiHlSl8                 ; chyba operace

; ------ kontrola po‡ te‡n¡ pozice bloku

         cmp       bp,word ptr es:[EdiPBBlk+2] ; kontrola po‡ te‡n¡ pozice bloku HIGH
         jne       EdiHlSl2
         cmp       di,word ptr es:[EdiPBBlk] ; kontrola po‡ te‡n¡ pozice bloku LOW
EdiHlSl2:jb        EdiHlSl8                 ; ©etˆzec je p©ed po‡ tkem bloku

; ------ pozice za koncem ©etˆzce -> BP:DI

         add       di,ds:[TextFndN]         ; pozice za koncem ©etˆzce
         adc       bp,0

; ------ kontrola koncov‚ pozice bloku

         cmp       bp,word ptr es:[EdiPKBlk+2] ; kontrola koncov‚ pozice bloku HIGH
         jne       EdiHlSl4
         cmp       di,word ptr es:[EdiPKBlk] ; kontrola koncov‚ pozice bloku LOW
EdiHlSl4:je        EdiHlSl8                 ; je po konec bloku - OK
         cmc                                ; CY=©etˆzec je za koncem bloku

; ------ n vrat registr–

EdiHlSl8:pop       bp
         pop       di
         pop       si
         pop       dx
         pop       ax

; ------ normalizace dat (CY=nen¡ ve sloupcov‚m bloku)

         pushf
         call      EditHlNm                 ; normalizace bloku dat
         popf
EdiHlSl9:ret

EdiHlSlo ENDP

; -----------------------------------------------------------------------------
;        Alt-F8 - nastaven¡ zna‡ky
; -----------------------------------------------------------------------------

EditAF8  PROC      NEAR

; ------ test, zda je operace povolena

         test      byte ptr es:[di+EdiParm1],bit0+bit1 ; je zobrazen¡/HEX m¢d ?
         jnz       EditAF89                 ; je zobrazen¡/HEX m¢d - ignoruje se
         test      byte ptr es:[EdiParm],bit2 ; je povolena editace souboru ?
         jnz       EditAF89                  ; z kaz z pisu

; ------ ukon‡en¡ ozna‡ov n¡ bloku

         call      EdiEShft                 ; ukon‡en¡ ozna‡ov n¡ bloku se SHIFT-

; ------ £schova a zapnut¡ m¢du INSERT

         mov       al,ds:[EditParm]         ; m¢d INSERT
         push      ax                       ; £schova stavu INSERT
         or        byte ptr ds:[EditParm],bit5 ; zapnut¡ p©ep¡na‡e INSERT

; ------ z pis textu zna‡ky

         mov       si,offset EdiZnTxt+1     ; buffer zna‡ky
         mov       ch,0
         mov       cl,ds:[si-1]             ; CX <- d‚lka textu zna‡ky
         jcxz      EditAF88                 ; nen¡ zna‡ka
EditAF82:mov       bl,ds:[si]               ; p©ipraven˜ znak
         inc       si                       ; zv˜¨en¡ ukazatele textu
         mov       bh,0
         push      si
         push      cx
         call      EditChr                  ; z pis znaku
         call      EditAktW                 ; aktualizace okna
         pop       cx
         pop       si
         loop      EditAF82                 ; dal¨¡ znak

; ------ n vrat m¢du INSERT

EditAF88:pop       ax                       ; n vrat p©¡zanku INSERT
         and       al,bit5                  ; aktu ln¡ stav p©ep¡na‡e INSERT
         and       byte ptr ds:[EditParm],not bit5 ; nulov n¡ star‚ho p©¡znaku
         or        ds:[EditParm],al         ; n vrat p–vodn¡ho p©¡znaku
EditAF89:ret

EditAF8  ENDP

; -----------------------------------------------------------------------------
;        Alt-F9 - nalezen¡ p©ede¨l‚ zna‡ky
; -----------------------------------------------------------------------------

EditAF9  PROC      NEAR

         mov       cl,bit0+bit1             ; smˆr hled n¡ zpˆt
         jmp       short EdiAF101

EditAF9  ENDP

; -----------------------------------------------------------------------------
;        Alt-F10 - nalezen¡ n sleduj¡c¡ zna‡ky
; -----------------------------------------------------------------------------

EditAF10 PROC      NEAR

         mov       cl,bit1                  ; smˆr hled n¡ vp©ed

; ------ test, zda existuje zna‡ka

EdiAF101:cmp       byte ptr ds:[EdiZnTxt],0 ; je zna‡ka ?
         je        EdiAF109                 ; nen¡ ‘ dn  zna‡ka

; ------ £schova parametr– hled n¡ a registr–

         mov       al,ds:[EdiHledP]         ; parametry hled n¡
         mov       ah,ds:[EdiHldP2]         ; parametry hled n¡ 2
         mov       ds:[EdiHledP],cl         ; n hradn¡ parametry hled n¡
         push      ax                       ; £schova parametr– hled n¡
         push      bp
         mov       bp,sp
         sub       sp,TextFndX              ; uvolnˆn¡ m¡sta pro buffer

; ------ £schova textu k hled n¡ do z sobn¡ku

         mov       cx,ds:[TextFndN]         ; d‚lka textu
         push      cx                       ; p–vodn¡ d‚lka textu
         push      di                       ; offset definice okna
         push      es                       ; segment definice okna

         mov       di,sp
         add       di,6                     ; adresa bufferu v z sobn¡ku
         push      ss
         pop       es                       ; ES <- buffer z sobn¡ku
         mov       si,offset TextFnd        ; buffer textu
         cld
         rep       movsb                    ; £schova textu do z sobn¡ku

; ------ ulo‘en¡ nov‚ho textu k hled n¡

         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       si,offset EdiZnTxt+1     ; buffer zna‡ky
         mov       cl,ds:[si-1]             ; d‚lka textu zna‡ky (CH=0 !)
         mov       ds:[TextFndN],cx         ; d‚lka hledan‚ho textu
         mov       ds:[TextFnd0],cl         ; d‚lka hledan‚ho textu
         mov       di,offset TextFnd        ; buffer textu
         rep       movsb                    ; ulo‘en¡ textu k hled n¡

         pop       es
         pop       di

; ------ vyhled n¡ textu zna‡ky

         or        byte ptr ds:[EdiHldP2],bit3 ; je hled n¡ zna‡ky
         push      bp
         call      EdiHlCL0                 ; vyhled n¡ ©etˆzce zna‡ky
         pop       bp

; ------ n vrat textu k hled n¡ ze z sobn¡ku

         pop       cx                       ; p–vodn¡ d‚lka textu
         mov       ds:[TextFndN],cx         ; d‚lka p–vodn¡ho textu
         mov       ds:[TextFnd0],cl

         mov       si,sp                    ; SI <- buffer v z sobn¡ku
         push      es
         push      di
         push      ds

         push      ds
         pop       es                       ; ES <- datov˜ segment
         push      ss
         pop       ds                       ; DS <- z sobn¡k
         mov       di,offset TextFnd        ; buffer textu k hled n¡
         cld
         rep       movsb                    ; n vrat textu k hled n¡

         pop       ds
         pop       di
         pop       es

; ------ n vrat registr– a parametr– k hled n¡

         mov       sp,bp
         pop       bp
         pop       ax                       ; p–vodn¡ parametry hled n¡
         mov       ds:[EdiHledP],al         ; n vrat parametr– hled n¡ 1
         mov       ds:[EdiHldP2],ah         ; n vrat parametr– hled n¡ 2
EdiAF109:ret

EditAF10 ENDP

; *****************************************************************************
;
;                     Obsluha posouv n¡ kurzoru
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        nastaven¡ prvn¡ho znaku HEX (okno ES:DI)
; -----------------------------------------------------------------------------

Edit1Hex PROC      NEAR

         and       byte ptr es:[di+EdiParm2],not bit1 ; je prvn¡ znak HEX pole
         ret

Edit1Hex ENDP

; -----------------------------------------------------------------------------
;        synchronizace oken (v z sobn¡ku je adresa procedury ke zdvojen¡)
;             (ni‡¡ registr BP !)
; -----------------------------------------------------------------------------

EditSyn  PROC      NEAR

; ------ test, zda m  b˜t synchronizace prov dˆna

         test      byte ptr ds:[EditParm],bit6 ; je synchronizace oken ?
         jz        EditSyn9                  ; nen¡ synchronizace oken

; ------ £schova n vratov‚ adresy do registru BP

         pop       bp                       ; BP <- n vratov  adresa
         push      bp

; ------ £schova registr–

         push      di
         push      dx

; ------ p©epnut¡ na druh‚ okno

         xor       di,EdiW1 XOR EdiW2       ; zmˆna okna
         cmp       dx,ds:[EdiSAkt]          ; je teƒ aktivn¡ okno ?
         mov       dx,ds:[EdiSNAkt]         ; DX <- neaktivn¡ okno
         je        EditSyn1                 ; je aktivn¡ okno OK
         mov       dx,ds:[EdiSAkt]          ; jinak zmˆna na aktivn¡ okno
EditSyn1:call      EditGetD                 ; adresa okna -> ES

; ------ vol n¡ obsluhy druh‚ho okna

         call      bp                       ; zdvojen¡ povelu

; ------ aktualizace zobrazen¡ druh‚ho okna

         test      byte ptr ds:[EditPar2],bit0+bit1+bit2 ; aktivn¡ okno/© dek ?
         jz        EditSyn2                 ; nen¡ pot©eba nic zobrazit
         or        byte ptr ds:[EditPar2],bit3 ; je nutn‚ zobrazit v¨e

; ------ n vrat registr–

EditSyn2:pop       dx
         pop       di

; ------ obnoven¡ adresy okna

         call      EditGetD                 ; n vrat adresy aktivn¡ho okna
EditSyn9:ret

EditSyn  ENDP

; -----------------------------------------------------------------------------
;        posun kurzoru o zadan˜ po‡et pozic vpravo (bez posunu textu)
; -----------------------------------------------------------------------------
; VSTUP: DX=‡¡slo segmentu okna
;        DI=adresa definice okna
;        BP=po‘adovan˜ po‡et pozic
;        ES=adresa okna
;        DS=datov˜ segment
; -----------------------------------------------------------------------------

EditKrRg PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx

; ------ posun kurzoru

         call      EditGtKP                 ; poskytnut¡ pozice s kurzorem
         add       ax,bp                    ; zv˜¨en¡ ‡¡sla pozice
         adc       cx,0
         call      EditStKP                 ; nastaven¡ pozice s kurzorem

; ------ n vrat registr–

         pop       cx
         pop       ax
         ret

EditKrRg ENDP

; -----------------------------------------------------------------------------
;        posun kurzoru o zadan˜ po‡et pozic vlevo (bez rolov n¡ textu)
; -----------------------------------------------------------------------------
; VSTUP: DX=‡¡slo segmentu okna
;        DI=adresa definice okna
;        BP=po‘adovan˜ po‡et pozic
;        ES=adresa okna
;        DS=datov˜ segment
; -----------------------------------------------------------------------------

EditKrLf PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx

; ------ posun kurzoru

         call      EditGtKP                 ; poskytnut¡ pozice s kurzorem
         sub       ax,bp                    ; posun pozice kurzoru
         sbb       cx,0
         jnc       EditKrL2                 ; nen¡ podte‡en¡
         xor       ax,ax                    ; omezen¡ na pozici 0
         xor       cx,cx
EditKrL2:call      EditStKP                 ; nastaven¡ pozice s kurzorem

; ------ n vrat registr–

         pop       cx
         pop       ax
         ret

EditKrLf ENDP

; -----------------------------------------------------------------------------
;        posun kurzoru o zadan˜ po‡et © dk– dol– (bez posunu textu)
; -----------------------------------------------------------------------------
; VSTUP: DX=‡¡slo segmentu okna
;        DI=adresa definice okna
;        BP=po‘adovan˜ po‡et © dk–
;        ES=adresa okna
;        DS=datov˜ segment
; -----------------------------------------------------------------------------

EditKrDn PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx

; ------ posun kurzoru

         call      EditGetK                 ; poskytnut¡ © dku s kurzorem
         add       ax,bp                    ; zv˜¨en¡ ‡¡sla © dku
         adc       cx,0
         call      EditSetK                 ; nastaven¡ © dku s kurzorem

; ------ n vrat registr–

         pop       cx
         pop       ax
         ret

EditKrDn ENDP

; -----------------------------------------------------------------------------
;        posun kurzoru o zadan˜ po‡et © dk– nahoru (bez rolov n¡ textu)
; -----------------------------------------------------------------------------
; VSTUP: DX=‡¡slo segmentu okna
;        DI=adresa definice okna
;        BP=po‘adovan˜ po‡et © dk–
;        ES=adresa okna
;        DS=datov˜ segment
; -----------------------------------------------------------------------------

EditKrUp PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx

; ------ posun kurzoru

         call      EditGetK                 ; poskytnut¡ © dku s kurzorem
         sub       ax,bp                    ; posun © dku kurzoru
         sbb       cx,0
         jnc       EditKrU2                 ; nen¡ podte‡en¡
         xor       ax,ax                    ; omezen¡ na © dek 0
         xor       cx,cx
EditKrU2:call      EditSetK                 ; nastaven¡ © dku s kurzorem

; ------ n vrat registr–

         pop       cx
         pop       ax
         ret

EditKrUp ENDP

; -----------------------------------------------------------------------------
;        rolov n¡ textu o zadan˜ po‡et pozic vpravo (bez posunu kurzoru)
; -----------------------------------------------------------------------------
; VSTUP: DX=‡¡slo segmentu okna
;        DI=adresa definice okna
;        BP=po‘adovan˜ po‡et pozic
;        ES=adresa okna
;        DS=datov˜ segment
; -----------------------------------------------------------------------------

EditRlRg PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx

; ------ posun po‡ te‡n¡ pozice

         call      EditGtTP                 ; poskytnut¡ po‡ te‡n¡ pozice
         sub       ax,bp                    ; posun po‡ te‡n¡ pozice
         sbb       cx,0
         jnc       EditRlR2
         xor       ax,ax                    ; omezen¡ na pozici 0
         xor       cx,cx
EditRlR2:call      EditStTP                 ; nastaven¡ nov‚ po‡ te‡n¡ pozice

; ------ n vrat registr–

         pop       cx
         pop       ax
         ret

EditRlRg ENDP

; -----------------------------------------------------------------------------
;        rolov n¡ textu o zadan˜ po‡et pozic vlevo (bez posunu kurzoru)
; -----------------------------------------------------------------------------
; VSTUP: DX=‡¡slo segmentu okna
;        DI=adresa definice okna
;        BP=po‘adovan˜ po‡et pozic
;        ES=adresa okna
;        DS=datov˜ segment
; -----------------------------------------------------------------------------

EditRlLf PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx

; ------ posun po‡ te‡n¡ pozice

         call      EditGtTP                 ; poskytnut¡ po‡ te‡n¡ pozice
         add       ax,bp                    ; posun po‡ te‡n¡ pozice
         adc       cx,0
         call      EditStTP                 ; nastaven¡ nov‚ po‡ te‡n¡ pozice

; ------ n vrat registr–

         pop       cx
         pop       ax
         ret

EditRlLf ENDP

; -----------------------------------------------------------------------------
;        rolov n¡ textu o zadan˜ po‡et © dk– dol– (bez posunu kurzoru)
; -----------------------------------------------------------------------------
; VSTUP: DX=‡¡slo segmentu okna
;        DI=adresa definice okna
;        BP=po‘adovan˜ po‡et © dk–
;        ES=adresa okna
;        DS=datov˜ segment
; -----------------------------------------------------------------------------

EditRlDn PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx

; ------ posun po‡ te‡n¡ho © dku

         call      EditGetT                 ; poskytnut¡ po‡ te‡n¡ho © dku
         sub       ax,bp                    ; posun po‡ te‡n¡ho © dku
         sbb       cx,0
         jnc       EditRlD2
         xor       ax,ax                    ; omezen¡ na © dek 0
         xor       cx,cx
EditRlD2:call      EditSetT                 ; nastaven¡ nov‚ho prvn¡ho © dku

; ------ n vrat registr–

         pop       cx
         pop       ax
         ret

EditRlDn ENDP

; -----------------------------------------------------------------------------
;        rolov n¡ textu o zadan˜ po‡et © dk– nahoru (bez posunu kurzoru)
; -----------------------------------------------------------------------------
; VSTUP: DX=‡¡slo segmentu okna
;        DI=adresa definice okna v segmentu souboru
;        BP=po‘adovan˜ po‡et © dk–
;        ES=adresa definice souboru
;        DS=datov˜ segment
; -----------------------------------------------------------------------------

EditRlUp PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx

; ------ posun po‡ te‡n¡ho © dku

         call      EditGetT                 ; poskytnut¡ po‡ te‡n¡ho © dku
         add       ax,bp                    ; zv˜¨en¡ ‡¡sla © dku
         adc       cx,0
         call      EditSetT                 ; nastaven¡ nov‚ho prvn¡ho © dku

; ------ n vrat registr–

         pop       cx
         pop       ax
         ret

EditRlUp ENDP

; -----------------------------------------------------------------------------
;        po‘adavek aktualizace ukazatel– kurzor– v obou oknech aktivn¡ho souboru
; -----------------------------------------------------------------------------
; VSTUP: DX=‡¡slo okna
;        DS=datov˜ segment
; VSTUP: CY=chyba
;         ES=nov  adresa okna
; -----------------------------------------------------------------------------

EditModA PROC      NEAR

         push      dx
         or        byte ptr ds:[EditPar2],bit3 ; zobrazit v¨echna okna
         call      EditModW                 ; aktualizace kurzoru v oknˆ
         jc        EditMdA2                 ; chyba
         xor       dh,bit15/bit8            ; p©epnut¡ na druh‚ okno
         call      EditModW                 ; aktualizace kurzoru v oknˆ
EditMdA2:pop       dx
         call      EditGt0D                 ; nov  adresa aktivn¡ho okna
         ret

EditModA ENDP

; -----------------------------------------------------------------------------
;      aktualizace ukazatel– kurzor– v obou zobrazen˜ch oknech (odli¨n‚ soubory)
; -----------------------------------------------------------------------------
; VSTUP: DX=‡¡slo okna pro obnoven¡ adresy okna
;        DS=datov˜ segment
; VSTUP: CY=chyba
;         ES=nov  adresa okna
; -----------------------------------------------------------------------------

EditAktA PROC      NEAR

         push      dx
         mov       dx,ds:[EdiSAkt]          ; aktivn¡ okno
         call      EditAktW                 ; aktualizace kurzoru v oknˆ
         jc        EditAkA8                 ; chyba

         mov       dx,ds:[EdiSNAkt]         ; neaktivn¡ okno
         test      byte ptr ds:[EditPar2],bit4 ; jsou 2 okna ?
         jnz       EditAkA6                 ; jsou 2 okna

         push      ax
         mov       al,bit4                  ; p©¡znak pro okno 1
         or        dx,dx                    ; je okno 1 ?
         jns       EditAkA2                 ; je to okno 1
         mov       al,bit5                  ; p©¡znak pro okno 2
EditAkA2:test      byte ptr ds:[ParMous2],al ; je p©¡znak vypnut ?
         jz        EditAkA4                 ; p©¡znak je vypnut
         xor       byte ptr ds:[ParMous2],al ; vypnut¡ p©¡znaku
         call      far ptr RIniMous         ; reinicializace my¨i
EditAkA4:pop       ax
         jmp       short EditAkA8           ; neaktivn¡ okno se nemus¡

EditAkA6:call      EditAktW                 ; aktualizace kurzoru v oknˆ
EditAkA8:pop       dx
         call      EditGt0D                 ; nov  adresa aktivn¡ho okna
         ret

EditAktA ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ po‘adavku aktualizace okna
; -----------------------------------------------------------------------------
; VSTUP: DX=segment okna
;        DS=datov˜ segment
; -----------------------------------------------------------------------------

EditModW PROC      NEAR

; ------ £schova registr–

         push      di
         push      es

; ------ p©¡prava adresy definice okna -> ES:DI

         mov       di,EdiW1                 ; definice pro okno 1
         or        dx,dx                    ; je aktivn¡ okno 2 ?
         jns       EditMdW2                 ; je aktivn¡ okno 1
         mov       di,EdiW2                 ; definice pro okno 2
EditMdW2:call      EditGetD                 ; poskytnut¡ adresy okna -> ES

; ------ nastaven¡ po‘adavku aktualizace

         or        byte ptr ds:[EditPar2],bit0+bit1+bit2 ; zobrazit okno
         or        byte ptr es:[di+EdiParm2],bit4+bit6+bit7 ; po‘adavek aktualizace

; ------ n vrat registr–

         pop       es
         pop       di
         ret

EditModW ENDP

; -----------------------------------------------------------------------------
;        aktualizace okna po proveden¡ operace
; -----------------------------------------------------------------------------
; VSTUP: DX=segment okna (bit 15: 1=je okno 2)
;        DS=datov˜ segment
; VSTUP: CY=chyba
;         ES=nov˜ segment definice okna
; -----------------------------------------------------------------------------

EditAktW PROC      NEAR

; ------ £schova registr–

         push      ax
         push      di

; ------ p©¡prava adresy definice okna -> ES:DI

         mov       al,bit4                  ; p©¡znak pro okno 1
         mov       di,EdiW1                 ; definice pro okno 1
         or        dx,dx                    ; je aktivn¡ okno 2 ?
         jns       EditAkW2                 ; je aktivn¡ okno 1
         mov       al,bit5                  ; p©¡znak pro okno 2
         mov       di,EdiW2                 ; definice pro okno 2
EditAkW2:call      EditGetD                 ; poskytnut¡ adresy okna -> ES

; ------ oprava zobrazen¡ grafick‚ho kurzoru my¨i

         mov       ah,ds:[ParMous2]         ; p©¡znak
         test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je textov˜ m¢d ?
         jnz       EditAkW3                 ; nen¡ textov˜ m¢d
         xor       ah,al                    ; zmˆna
EditAkW3:test      ah,al                    ; je p©¡znak spr vnˆ nastaven ?
         jnz       EditAkW4                 ; je ji‘ spr vnˆ nastaven
         xor       byte ptr ds:[ParMous2],al ; zmˆna p©¡znaku
         call      far ptr RIniMous         ; reinicializace my¨i

; ------ korekce po‡ te‡n¡ho © dku
; P©i z kazu z pisu omez¡ maxim ln¡ © dek s kurzorem a maxim ln¡ po‡ te‡n¡
; © dek. P©i zobrazen¡ nastav¡ kurzor na st©edn¡ © dek obrazovky.
; Oprav¡ po‡ te‡n¡ © dek podle © dku s kurzorem.

EditAkW4:call      EditKorT                 ; korekce po‡ te‡n¡ho © dku

; ------ aktualizace po‡ te‡n¡ho © dku
; Je-li pot©eba, inicializuje adresu po‡ te‡n¡ho © dku.

         call      EditAktT                 ; aktualizace po‡ te‡n¡ho © dku
         jc        EditAkW8                 ; chyba operace

; ------ aktualizace © dku s kurzorem
; Je-li pot©eba, inicializuje adresu © dku s kurzorem (a jeho d‚lku)

         call      EditAktK                 ; aktualizace © dku s kurzorem
         jc        EditAkW8                 ; chyba operace

; ------ korekce po‡ te‡n¡ pozice (pouze pro textov˜ m¢d)
; P©i zobrazen¡ nastav¡ kurzor na st©edn¡ pozici obrazovky.
; Oprav¡ po‡ te‡n¡ pozici okna podle pozice kurzoru (pro textov˜ m¢d).
; Vy‘aduje, aby byla aktualizovan  d‚lka © dku s kurzorem.

         call      EditKorP                 ; korekce po‡ te‡n¡ pozice

; ------ aktualizace pozice s kurzorem
; Je-li pot©eba, inicializuje pozici s kurzorem na © dku

         call      EditAkKP                 ; aktualizace pozice s kurzorem
                                          ;* zde je CY=chyba

; ------ aktualizace relativn¡ pozice/© dku

EditAkW8:pushf
         call      EditAktR                 ; aktualizace relativn¡ pozice/© dku
         popf

; ------ n vrat registr–

         pop       di
         pop       ax
         ret

EditAktW ENDP

; -----------------------------------------------------------------------------
;        korekce po‡ te‡n¡ pozice okna
; -----------------------------------------------------------------------------
; VSTUP: (DX=segment okna)
;        DI=adresa definice okna
;        ES=segment definice okna
;        DS=datov˜ segment
; -----------------------------------------------------------------------------

EditKorP PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx

; ------ test, zda je m¢d BIN nebo HEX

         test      byte ptr es:[di+EdiParm1],bit1+bit2 ; BIN/HEX m¢d ?
         jnz       EditKrP9                 ; je BIN nebo HEX m¢d

; ------ pro m¢d zobrazen¡ se nastav¡ kurzor do st©edu obrazovky

         mov       bh,0
         mov       bl,es:[di+EdiSir]        ; ¨¡©ka okna
         shr       bx,1                     ; ¨¡©ka okna / 2
         test      byte ptr es:[di+EdiParm1],bit0 ; je jen zobrazen¡ ?
         jz        EditKrP1                 ; je editace
         call      EditGtTP                 ; poskytnut¡ po‡ te‡n¡ pozice
         add       ax,bx                    ; p©i‡ten¡ poloviny obrazovky
         adc       cx,0
         call      EditStKP                 ; nastaven¡ kurzoru do st©edu

; ------ p©¡prava rezervy na okraj¡ch © dku -> BX

EditKrP1:shr       bx,1
         shr       bx,1                     ; 1/8 okna

; ------ p©¡prava minim ln¡ho po‡ tku © dku -> CX:AX

         call      EditGtKP                 ; poskytnut¡ pozice kurzoru -> CX:AX
         sub       ax,bx                    ; rezerva na lev‚m okraji
         sbb       cx,0
         jnc       EditKrP2                 ; nen¡ podte‡en¡
         xor       ax,ax                    ; maxim ln¡ po‡ tek p©i podte‡en¡
         xor       cx,cx

; ------ kontrola minim ln¡ho po‡ tku okna

EditKrP2:call      EditCmTP                 ; kontrola po‡ tku okna
         jae       EditKrP3                 ; po‡ tek je OK
         call      EditStTP                 ; nastaven¡ po‡ tku okna

; ------ p©¡prava rezervy na prav‚m okraji -> BX

EditKrP3:call      EditGtLP                 ; poskytnut¡ d‚lky © dku s kurzorem
         sub       ax,word ptr es:[di+EdiPKur] ; rezerva kurzoru do konce
         sbb       cx,word ptr es:[di+EdiPKur+2]
         ja        EditKrP5                 ; je velk  rezerva
         jb        EditKrP4                 ; kurzor je za koncem © dku
         cmp       ax,bx                    ; zb˜v  m‚nˆ znak– ?
         jae       EditKrP5                 ; je to OK
         xchg      ax,bx                    ; BX <- omezen¡ po‡tu znak–
         jmp       short EditKrP5

EditKrP4:xor       bx,bx                    ; nen¡ rezerva vpravo

; ------ p©¡prava minim ln¡ho po‡ tku -> CX:AX

EditKrP5:inc       bx                       ; rezerva pro kurzor
         call      EditGtKP                 ; poskytnut¡ pozice kurzoru -> CX:AX
         add       ax,bx                    ; rezerva na prav‚m okraji
         adc       cx,0
         mov       bl,es:[di+EdiSir]        ; ¨¡©ka okna
         sub       ax,bx                    ; ode‡ten¡ ¨¡©ky okna
         sbb       cx,0
         jnc       EditKrP6                 ; nen¡ p©ete‡en¡
         xor       ax,ax                    ; minim ln¡ po‡ tek
         xor       cx,cx

; ------ kontrola p©ete‡en¡ konce

EditKrP6:call      EditCmTP                 ; kontrola po‡ tku okna
         jbe       EditKrP9                 ; po‡ tek je OK
         call      EditStTP                 ; nastaven¡ po‡ te‡n¡ pozice okna

; ------ n vrat registr–

EditKrP9:pop       cx
         pop       bx
         pop       ax
         ret

EditKorP ENDP

; -----------------------------------------------------------------------------
;        korekce po‡ te‡n¡ho © dku okna
; (P©i zmˆnˆ rezervy na spodn¡m a horn¡m okraji okna zkontrolovat rezervu t‚‘
; pro Ctrl-Z a Ctrl-W, zda souhlas¡, a zkontrolovat t‚‘ PageUp a PageDown)
; -----------------------------------------------------------------------------
; VSTUP: DX=segment okna
;        DI=adresa definice okna
;        ES=segment definice okna
;        DS=datov˜ segment
; -----------------------------------------------------------------------------

EditKorT PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx

; ------ p©¡prava v˜¨ky okna -> BX

         mov       bh,0
         mov       bl,es:[di+EdiVys]        ; v˜¨ka okna

; ------ test, zda je povolena modifikace souboru

         test      byte ptr es:[di+EdiParm1],bit0 ; je jen zobrazen¡ ?
;         jnz       EditKrT1                 ; je jen zobrazen¡
;         test      byte ptr es:[EdiParm],bit2 ; je z kaz z pisu ?
;         jz        EditKrT3                 ; nen¡ z kaz z pisu
         jz        EditKrT3                 ; je editace

; ------ omezen¡ maxim ln¡ho © dku s kurzorem

EditKrT1:call      EdiGetCL                 ; poskytnut¡ po‡tu © dk– -> CX:AX
         call      EditCmpK                 ; kontrola © dku s kurzorem
         jae       EditKrT2                 ; © dek s kurzorem je OK
         call      EditSetK                 ; omezen¡ © dku s kurzorem

; ------ omezen¡ maxim ln¡ho po‡ te‡n¡ho © dku (v˜¨ka okna > 1 !)

EditKrT2:dec       bx
         dec       bx                       ; v˜¨ka okna - 2
         sub       ax,bx                    ; ode‡ten¡ v˜¨ky okna
         sbb       cx,0
         jnc       EditKT21
         xor       cx,cx                    ; omezen¡ max. © dku na 0
         xor       ax,ax
EditKT21:call      EditCmpT                 ; kontrola po‡ te‡n¡ho © dku
         jae       EditKT22                 ; po‡ te‡n¡ © dek je OK
         call      EditSetT                 ; nastaven¡ po‡ te‡n¡ho © dku
EditKT22:inc       bx
         inc       bx                       ; n vrat v˜¨ky okna

; ------ pro m¢d zobrazen¡ se nastav¡ kurzor do st©edu obrazovky

EditKrT3:shr       bx,1                     ; v˜¨ka okna / 2
         test      byte ptr es:[di+EdiParm1],bit0 ; je jen zobrazen¡ ?
         jz        EditKT32                 ; je editace
         call      EditGetT                 ; poskytnut¡ po‡ te‡n¡ho © dku
         add       ax,bx                    ; p©i‡ten¡ poloviny obrazovky
         adc       cx,0
         call      EditSetK                 ; nastaven¡ kurzoru do st©edu

; ------ p©¡prava rezervy © dku -> BX

EditKT32:shr       bx,1
         shr       bx,1                     ; v˜¨ka okna / 8

; ------ minim ln¡ po‡ tek okna -> CX:AX

         call      EditGetK                 ; poskytnut¡ © dku s kurzorem->CX:AX
         sub       ax,bx                    ; rezerva na horn¡m okraji
         sbb       cx,0
         jnc       EditKrT4                 ; nen¡ podte‡en¡
         xor       ax,ax                    ; maxim ln¡ po‡ tek p©i podte‡en¡
         xor       cx,cx

; ------ kontrola, zda vyhovuje minim ln¡ po‡ tek okna

EditKrT4:call      EditCmpT                 ; porovn n¡ s po‡ te‡n¡m © dkem
         jae       EditKrT5                 ; po‡ tek okna je OK
         call      EditSetT                 ; nastaven¡ po‡ te‡n¡ho © dku

; ------ p©¡prava rezervy na spodn¡m okraji -> BX

EditKrT5:call      EdiGetCL                 ; poskytnut¡ po‡tu © dk– -> CX:AX
         sub       ax,word ptr es:[di+EdiRKur] ; rezerva kurzoru do konce
         sbb       cx,word ptr es:[di+EdiRKur+2]
         ja        EditKrT7                 ; je velk  rezerva
         jb        EditKrT6                 ; kurzor je za koncem textu
         cmp       ax,bx                    ; zb˜v  m‚nˆ © dk– ?
         jae       EditKrT7                 ; je to OK
         xchg      ax,bx                    ; BX <- omezen˜ po‡et © dk–
         jmp       short EditKrT7

EditKrT6:xor       bx,bx                    ; nen¡ rezerva dole

; ------ maxim ln¡ po‡ te‡n¡ © dek okna -> CX:AX

EditKrT7:inc       bx                       ; rezerva pro kurzor
         inc       bx
         call      EditGetK                 ; poskytnut¡ © dku s kurzorem->CX:AX
         add       ax,bx                    ; rezerva na doln¡m okraji
         adc       cx,0
         mov       bl,es:[di+EdiVys]        ; v˜¨ka okna
         sub       ax,bx                    ; ode‡ten¡ v˜¨ky okna
         sbb       cx,0
         jnc       EditKrT8                 ; nen¡ p©ete‡en¡
         xor       ax,ax                    ; minim ln¡ po‡ tek okna
         xor       cx,cx

; ------ kontrola p©ete‡en¡ konce okna

EditKrT8:call      EditCmpT                 ; porovn n¡ s po‡ te‡n¡m © dkem
         jbe       EditKrT9                 ; po‡ tek je OK
         call      EditSetT                 ; nastaven¡ po‡ te‡n¡ho © dku

; ------ n vrat registr–

EditKrT9:pop       cx
         pop       bx
         pop       ax
         ret

EditKorT ENDP

; -----------------------------------------------------------------------------
;        aktualizace relativn¡ pozice a © dku kurzoru (uchov v  p©¡znaky !)
; -----------------------------------------------------------------------------
; VSTUP: DI=adresa definice okna
;        ES=segment definice okna
; -----------------------------------------------------------------------------

EditAktR PROC      NEAR

; ------ £schova registr–

         pushf
         push      ax

; ------ relativn¡ pozice s kurzorem

         mov       al,byte ptr es:[di+EdiPKur] ; pozice kurzoru
         test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je BIN/HEX m¢d ?
         jnz       EditAkR2                 ; je m¢d BIN nebo HEX
         sub       al,byte ptr es:[di+EdiPTop] ; offset od po‡ tku v text. m¢du
EditAkR2:mov       es:[di+EdiPKurR],al      ; relativn¡ kurzor (pozice)

; ------ relativn¡ © dek s kurzorem

         mov       al,byte ptr es:[di+EdiRKur] ; © dek s kurzorem
         sub       al,byte ptr es:[di+EdiRTop] ; offset od po‡ tku
         mov       es:[di+EdiRKurR],al      ; relativn¡ © dek s kurzorem

; ------ n vrat registr–

         pop       ax
         popf
         ret

EditAktR ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ po‡ te‡n¡ pozice (uchov v  registr p©¡znak– !)
; -----------------------------------------------------------------------------
; VSTUP: DI=adresa definice okna
;        ES=segment definice okna
; VSTUP: CX:AX=‡¡slo po‡ te‡n¡ pozice
; -----------------------------------------------------------------------------

EditGtTP PROC      NEAR

         mov       ax,word ptr es:[di+EdiPTop] ; pozice s kurzorem LOW
         mov       cx,word ptr es:[di+EdiPTop+2] ; pozice s kurzorem HIGH
         ret

EditGtTP ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ po‡ te‡n¡ pozice (uchov v  registr p©¡znak– !)
; -----------------------------------------------------------------------------
; VSTUP: CX:AX=‡¡slo po‘adovan‚ po‡ te‡n¡ pozice
;        DI=adresa definice okna
;        ES=segment definice okna
;        DS=datov˜ segment
; -----------------------------------------------------------------------------

EditStTP PROC      NEAR

         pushf
         mov       word ptr es:[di+EdiPTop],ax ; nov  po‡ te‡n¡ pozice LOW
         mov       word ptr es:[di+EdiPTop+2],cx ; nov  po‡ te‡n¡ pozice HIGH
         or        byte ptr ds:[EditPar2],bit2 ; p©¡znak - zobraz akt. okno
         popf

         call      EditAktR                 ; aktualizace relativn¡ pozice/© dku
         ret

EditStTP ENDP

; -----------------------------------------------------------------------------
;        porovn n¡ po‡ te‡n¡ pozice
; -----------------------------------------------------------------------------
; VSTUP: CX:AX=‡¡slo k testu po‡ te‡n¡ pozice
;        DI=adresa definice okna
;        ES=segment definice okna
; VSTUP: p©¡znaky podle operace "CMP CX:AX,pozice"
; -----------------------------------------------------------------------------

EditCmTP PROC      NEAR

         cmp       cx,word ptr es:[di+EdiPTop+2] ; porovn n¡ ‡¡sla HIGH
         jne       EditCTP2
         cmp       ax,word ptr es:[di+EdiPTop] ; porovn n¡ ‡¡sla LOW
EditCTP2:ret

EditCmTP ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ pozice s kurzorem (uchov v  registr p©¡znak– !)
; -----------------------------------------------------------------------------
; VSTUP: DI=adresa definice okna
;        ES=segment definice okna
; VSTUP: CX:AX=‡¡slo pozice s kurzorem
; -----------------------------------------------------------------------------

EditGtKP PROC      NEAR

         mov       ax,word ptr es:[di+EdiPKur] ; pozice s kurzorem LOW
         mov       cx,word ptr es:[di+EdiPKur+2] ; pozice s kurzorem HIGH
         ret

EditGtKP ENDP

; -----------------------------------------------------------------------------
;        porovn n¡ offsetu kurzoru s d‚lkou souboru
; -----------------------------------------------------------------------------
; VSTUP: DI=adresa definice okna
;        ES=segment definice okna
; VSTUP: p©¡znaky podle porovn n¡ CMP OFFSET,DLKA
; -----------------------------------------------------------------------------

EditCmKO PROC      NEAR

         push      ax
         mov       ax,word ptr es:[di+EdiOffsK+2] ; offset kurzoru v souboru
         cmp       ax,word ptr es:[EdiSize+2] ; je kurzor uvnit© textu ?
         jne       EdiCMKO2
         mov       ax,word ptr es:[di+EdiOffsK]
         cmp       ax,word ptr es:[EdiSize]
EdiCMKO2:pop       ax
         ret

EditCmKO ENDP

; -----------------------------------------------------------------------------
;        porovn n¡ pozice kurzoru s pozic¡ koncem © dku
; -----------------------------------------------------------------------------
; VSTUP: DI=adresa definice okna
;        ES=segment definice okna
; VSTUP: p©¡znaky podle porovn n¡ CMP KURZOR,DLKA
; -----------------------------------------------------------------------------

EditCmKL PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx

; ------ porovn n¡ kurzoru s d‚lkou © dku

         call      EditGtKP                 ; poskytnut¡ pozice kurzoru -> CX:AX
         cmp       cx,word ptr es:[di+EdiPLKur+2] ; porovn n¡ pozice HIGH
         jne       EditCKL2
         cmp       ax,word ptr es:[di+EdiPLKur] ; porovn n¡ pozice LOW

; ------ n vrat registr–

EditCKL2:pop       cx
         pop       ax
         ret

EditCmKL ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ d‚lky © dku s kurzorem (uchov v  registr p©¡znak– !)
; -----------------------------------------------------------------------------
; VSTUP: DI=adresa definice okna
;        ES=segment definice okna
; VSTUP: CX:AX=d‚lka aktu ln¡ho © dku s kurzorem
; -----------------------------------------------------------------------------

EditGtLP PROC      NEAR

         mov       ax,word ptr es:[di+EdiPLKur] ; d‚lka © dku s kurzorem LOW
         mov       cx,word ptr es:[di+EdiPLKur+2] ; d‚lka © dku s kurzorem HIGH
         ret

EditGtLP ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ pozice s kurzorem (uchov v  registr p©¡znak– !)
; -----------------------------------------------------------------------------
; VSTUP: CX:AX=‡¡slo po‘adovan‚ pozice s kurzorem
;        DI=adresa definice okna
;        ES=segment definice okna
;        DS=datov˜ segment
; -----------------------------------------------------------------------------

EditStKP PROC      NEAR

         pushf
         call      EditCmKP                 ; je pozice ji‘ nastavena ?
         je        EditSKP6                 ; pozice je ji‘ nastavena OK
         or        byte ptr ds:[EditPar2],bit0 ; p©¡znak zobrazen¡ kurzoru
         or        byte ptr es:[di+EdiParm2],bit4 ; nutn  aktualizace pozice
         mov       word ptr es:[di+EdiPKur],ax ; nov  pozice s kurzorem LOW
         mov       word ptr es:[di+EdiPKur+2],cx ; nov  pozice s kurzorem HIGH
         call      EditAktR                 ; aktualizace relativn¡ pozice/© dku
EditSKP6:popf
         ret

EditStKP ENDP

; -----------------------------------------------------------------------------
;        porovn n¡ pozice s kurzorem
; -----------------------------------------------------------------------------
; VSTUP: CX:AX=‡¡slo k testu pozice s kurzorem
;        DI=adresa definice okna
;        ES=segment definice okna
; VSTUP: p©¡znaky podle operace "CMP CX:AX,pozice"
; -----------------------------------------------------------------------------

EditCmKP PROC      NEAR

         cmp       cx,word ptr es:[di+EdiPKur+2] ; porovn n¡ ‡¡sla HIGH
         jne       EditCKP2
         cmp       ax,word ptr es:[di+EdiPKur]   ; porovn n¡ ‡¡sla LOW
EditCKP2:ret

EditCmKP ENDP

; -----------------------------------------------------------------------------
;        podm¡nˆn  aktualizace pozice kurzoru na © dku
; -----------------------------------------------------------------------------
; VSTUP: DX=‡¡slo okna (bit 15: 1=je okno 2)
;        DI=offset definice okna
;        ES=segment definice okna
;        DS=datov˜ segment
; VSTUP: CY=chyba
;         ES=nov˜ segment definice okna
; -----------------------------------------------------------------------------

EditAkKP PROC      NEAR

; ------ test, zda je pot©eba prov‚st aktualizaci

         test      byte ptr es:[di+EdiParm2],bit4 ; je pot©ebn  aktualizace ?
         jz        EditAKP9                 ; nen¡ pot©ebn  aktualizace

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      si

; ------ adresa © dku s kurzorem -> BX:SI

         mov       bx,es:[di+EdiBKur]       ; blok © dku s kurzorem
         mov       si,es:[di+EdiOKur]       ; offset © dku s kurzorem

; ------ ‡¡slo pozice s kurzorem -> CX:AX

         call      EditGtKP                 ; pozice s kurzorem -> CX:AX

; ------ nalezen¡ pozice kurzoru na © dku -> BX:SI/AX

         push      di
         call      EditGetP                 ; nalezen¡ pozice kurzoru
         xchg      ax,di                    ; AX <- p©esah kurzoru
         pop       di
         jc        EditAKP8                 ; chyba

; ------ p©esah kurzoru p©es tabul tor

         and       byte ptr es:[di+EdiParm2],not bit0 ; nen¡ odskok tabul toru
         or        ax,ax                    ; je odskok tabul toru ?
         jle       EditAKP2                 ; nen¡ odskok tabul toru
         or        byte ptr es:[di+EdiParm2],bit0 ; je odskok tabul toru
         dec       si                       ; n vrat ukazatele na znak TAB

; ------ ukazatel bloku kurzoru

EditAKP2:mov       es:[di+EdiBBKur],bx      ; blok s kurzorem
         mov       es:[di+EdiOfKur],si      ; offset kurzoru v bloku

; ------ stanoven¡ offsetu kurzoru v souboru -> CX:AX

         call      EdiGetOf                 ; stanoven¡ offsetu v souboru
         mov       word ptr es:[di+EdiOffsK],ax ; nov˜ offset kurzoru
         mov       word ptr es:[di+EdiOffsK+2],cx

; ------ p©¡znak proveden¡ aktualizace pozice kurzoru

         and       byte ptr es:[di+EdiParm2],not bit4 ; aktualizov na pozice
                                          ;* zde se navrac¡ NC !

; ------ n vrat registr–

EditAKP8:pop       si
         pop       cx
         pop       bx
         pop       ax
EditAKP9:ret

EditAkKP ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ © dku s kurzorem (uchov v  registr p©¡znak– !)
; -----------------------------------------------------------------------------
; VSTUP: DI=adresa definice okna
;        ES=segment definice okna
; VSTUP: CX:AX=‡¡slo © dku s kurzorem
; -----------------------------------------------------------------------------

EditGetK PROC      NEAR

         mov       ax,word ptr es:[di+EdiRKur] ; © dek s kurzorem LOW
         mov       cx,word ptr es:[di+EdiRKur+2] ; © dek s kurzorem HIGH
         ret

EditGetK ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ © dku s kurzorem (uchov v  registr p©¡znak– !)
; -----------------------------------------------------------------------------
; VSTUP: CX:AX=‡¡slo po‘adovan‚ho © dku s kurzorem
;        DI=adresa definice okna
;        ES=segment definice okna
;        DS=datov˜ segment
; -----------------------------------------------------------------------------

EditSetK PROC      NEAR

         pushf
         call      EditCmpK                 ; je © dek ji‘ nastaven ?
         je        EditStK6                 ; © dek je ji‘ nastaven OK
         or        byte ptr ds:[EditPar2],bit0 ; p©¡znak zobrazen¡ kurzoru
         or        byte ptr es:[di+EdiParm2],bit7+bit4 ; nutn  aktualizace © dku
         mov       word ptr es:[di+EdiRKur],ax ; nov˜ © dek s kurzorem LOW
         mov       word ptr es:[di+EdiRKur+2],cx ; nov˜ © dek s kurzorem HIGH
         call      EditAktR                 ; aktualizace relativn¡ pozice/© dku
EditStK6:popf
         ret

EditSetK ENDP

; -----------------------------------------------------------------------------
;        porovn n¡ © dku s kurzorem
; -----------------------------------------------------------------------------
; VSTUP: CX:AX=‡¡slo k testu © dku s kurzorem
;        DI=adresa definice okna
;        ES=segment definice okna
; VSTUP: p©¡znaky podle operace "CMP CX:AX,© dek"
; -----------------------------------------------------------------------------

EditCmpK PROC      NEAR

         cmp       cx,word ptr es:[di+EdiRKur+2] ; porovn n¡ ‡¡sla HIGH
         jne       EditCmK2
         cmp       ax,word ptr es:[di+EdiRKur]   ; porovn n¡ ‡¡sla LOW
EditCmK2:ret

EditCmpK ENDP

; -----------------------------------------------------------------------------
;        podm¡nˆn  aktualizace © dku s kurzorem
; -----------------------------------------------------------------------------
; VSTUP: DX=‡¡slo okna
;        DI=adresa definice okna
;        ES=segment definice okna
;        DS=datov˜ segment
; VSTUP: CY=chyba
;         ES=nov˜ segment definice okna
; -----------------------------------------------------------------------------

EditAktK PROC      NEAR

; ------ test, zda je pot©eba prov‚st aktualizaci

         test      byte ptr es:[di+EdiParm2],bit7 ; je pot©ebn  aktualizace ?
         jz        EditAkK9                 ; nen¡ pot©ebn  aktualizace

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      si

; ------ ‡¡slo © dku s kurzorem -> CX:AX

         call      EditGetK                 ; © dek s kurzorem -> CX:AX

; ------ nalezen¡ po‘adovan‚ho © dku v bufferu -> BX:SI

         call      EdiGetLn                 ; nalezen¡ po‘adovan‚ho © dku
         jc        EditAkK8                 ; chyba
         mov       es:[di+EdiBKur],bx       ; blok s kurzorem
         mov       es:[di+EdiOKur],si       ; offset © dku s kurzorem

; ------ stanoven¡ d‚lky © dku s kurzorem

         call      EditLenL                 ; stanoven¡ d‚lky © dku
         jc        EditAkK8                 ; chyba
         mov       word ptr es:[di+EdiPLKur],ax ; d‚lka © dku LOW
         mov       word ptr es:[di+EdiPLKur+2],cx ; d‚lka © dku HIGH

; ------ p©¡znak proveden¡ aktualizace © dku s kurzorem

         or        byte ptr es:[di+EdiParm2],bit4 ; aktualizovat pozici kurzoru
         and       byte ptr es:[di+EdiParm2],not bit7 ; aktualizace provedena
                                          ;* zde se navrac¡ NC !

; ------ n vrat registr–

EditAkK8:pop       si
         pop       cx
         pop       bx
         pop       ax
EditAkK9:ret

EditAktK ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ po‡ te‡n¡ho © dku (uchov v  registr p©¡znak– !)
; -----------------------------------------------------------------------------
; VSTUP: DI=adresa definice okna
;        ES=segment definice okna
; VSTUP: CX:AX=‡¡slo prvn¡ho © dku
; -----------------------------------------------------------------------------

EditGetT PROC      NEAR

         mov       ax,word ptr es:[di+EdiRTop] ; po‡ te‡n¡ © dek LOW
         mov       cx,word ptr es:[di+EdiRTop+2] ; po‡ te‡n¡ © dek HIGH
         ret

EditGetT ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ po‡ te‡n¡ho © dku (uchov v  registr p©¡znak– !)
; -----------------------------------------------------------------------------
; VSTUP: CX:AX=‡¡slo po‘adovan‚ho prvn¡ho © dku
;        DI=adresa definice okna
;        ES=segment definice okna
;        DS=datov˜ segment
; -----------------------------------------------------------------------------

EditSetT PROC      NEAR

         pushf
         call      EditCmpT                 ; je © dek ji‘ nastaven ?
         je        EditStT6                 ; © dek je ji‘ nastaven OK
         or        byte ptr ds:[EditPar2],bit2 ; p©¡znak - zobraz akt. okno
         or        byte ptr es:[di+EdiParm2],bit6 ; nutn  aktualizace © dku
         mov       word ptr es:[di+EdiRTop],ax ; nov˜ © dek LOW
         mov       word ptr es:[di+EdiRTop+2],cx ; nov˜ © dek HIGH
         call      EditAktR                 ; aktualizace relativn¡ pozice/© dku
EditStT6:popf
         ret

EditSetT ENDP

; -----------------------------------------------------------------------------
;        porovn n¡ po‡ te‡n¡ho © dku
; -----------------------------------------------------------------------------
; VSTUP: CX:AX=‡¡slo k testu prvn¡ho © dku
;        DI=adresa definice okna
;        ES=segment definice okna
; VSTUP: p©¡znaky podle operace "CMP CX:AX,© dek"
; -----------------------------------------------------------------------------

EditCmpT PROC      NEAR

         cmp       cx,word ptr es:[di+EdiRTop+2] ; porovn n¡ ‡¡sla HIGH
         jne       EditCmT2
         cmp       ax,word ptr es:[di+EdiRTop]   ; porovn n¡ ‡¡sla LOW
EditCmT2:ret

EditCmpT ENDP

; -----------------------------------------------------------------------------
;        podm¡nˆn  aktualizace po‡ te‡n¡ho © dku
; -----------------------------------------------------------------------------
; VSTUP: DX=‡¡slo okna
;        DI=adresa definice okna
;        ES=segment definice okna
;        DS=datov˜ segment
; VSTUP: CY=chyba
;         ES=nov  adresa definice okna
; -----------------------------------------------------------------------------

EditAktT PROC      NEAR

; ------ test, zda je pot©eba prov dˆt aktualizaci

         test      byte ptr es:[di+EdiParm2],bit6 ; nutn  aktualizace ?
         jz        EditAkT9                 ; nen¡ nutn  aktualizace

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      si

; ------ ‡¡slo po‡ te‡n¡ho © dku -> CX:AX

         call      EditGetT                 ; po‡ te‡n¡ © dek -> CX:AX

; ------ nalezen¡ po‘adovan‚ho © dku v bufferu -> BX:SI

         call      EdiGetLn                 ; nalezen¡ po‘adovan‚ho © dku
         jc        EditAkT8                 ; chyba
         mov       es:[di+EdiBTop],bx       ; blok s po‡ tkem
         mov       es:[di+EdiOTop],si       ; offset po‡ tku © dku

; ------ stanoven¡ offsetu po‡ te‡n¡ho © dku v souboru

         call      EdiGetOf                 ; stanoven¡ offsetu v souboru
         mov       word ptr es:[di+EdiOffsT],ax ; nov˜ offset © dku v souboru
         mov       word ptr es:[di+EdiOffsT+2],cx

; ------ p©¡znak proveden¡ aktualizace po‡ te‡n¡ho © dku

         and       byte ptr es:[di+EdiParm2],not bit6 ; aktualizace provedena
                                          ;* zde se navrac¡ NC !
; ------ n vrat registr–

EditAkT8:pop       si
         pop       cx
         pop       bx
         pop       ax
EditAkT9:ret

EditAktT ENDP

; *****************************************************************************
;
;                              Blokov‚ operace
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        F3 - za‡ tek bloku (vyvol v  se externˆ, ni‡¡ AX, CX, SI)
; -----------------------------------------------------------------------------

EditF3   PROC      NEAR

         mov       si,EdiPBBlk              ; ukazatele za‡ tku bloku
         mov       cl,bit0                  ; p©¡znak platnosti za‡ tku bloku
         jmp       short EditF42

EditF3   ENDP

; -----------------------------------------------------------------------------
;        F4 - konec bloku (vyvol v  se externˆ, ni‡¡ AX, CX, SI)
; -----------------------------------------------------------------------------

EditF4   PROC      NEAR

         mov       si,EdiPKBlk              ; ukazatele konce bloku
         mov       cl,bit1                  ; p©¡znak platnosti konce bloku

; ------ v re‘imu prohl¡‘e‡e se nic nedˆje

EditF42: test      byte ptr es:[di+EdiParm1],bit0 ; je zobrazen¡ ?
         jz        EditF422                 ; nen¡ zobrazen¡
         ret                                ; je jen zobrazen¡ - nic se nedˆje

; ------ n vrat pozic bloku, jsou-li zamˆnˆny (ES:SI=ukazatel, CL=maska, DI=okno)

EditF422:call      EditRPBl                 ; n vrat pozic bloku

; ------ nastaven¡ pozice ukazatele podle pozice kurzoru

         mov       ax,word ptr es:[di+EdiPKur]
         mov       es:[si],ax
         mov       ax,word ptr es:[di+EdiPKur+2]
         mov       es:[si+2],ax

; ------ nastaven¡ © dku ukazatele podle © dku kurzoru

         mov       ax,word ptr es:[di+EdiRKur] ; © dek kurzoru
         mov       es:[si+4],ax             ; © dek ukazatele bloku
         mov       ax,word ptr es:[di+EdiRKur+2]
         mov       es:[si+4+2],ax

; ------ nastaven¡ offsetu ukazatele podle offsetu kurzoru

         mov       ax,word ptr es:[di+EdiOffsK] ; offset kurzoru
         mov       es:[si+8],ax             ; offset ukazatele bloku
         mov       ax,word ptr es:[di+EdiOffsK+2]
         mov       es:[si+8+2],ax

; ------ test, zda je textov˜ m¢d

         test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je to textov˜ m¢d ?
         jz        EditF43                  ; je to textov˜ m¢d OK

; ------ pro m¢d BIN a HEX jsou ukazatele pozice a © dku neplatn‚

         or        es:[EdiParm0],cl         ; © dek a pozice ukazatele neplatn‚
         or        byte ptr es:[di+EdiParm2],bit5 ; p©ednastaven¡ - blok zapnut
         jmp       EdiAktBl                 ; pokus o aktualizaci ukazatel–

; ------ pro textov˜ m¢d jsou ukazatele pozice a © dku platn‚ OK

EditF43: not       cl
         and       es:[EdiParm0],cl         ; © dek a pozice platn 
         jmp       EditZapB                 ; zanut¡ bloku v oknˆ

EditF4   ENDP

; -----------------------------------------------------------------------------
;        F5 - kopie bloku
; -----------------------------------------------------------------------------

EditF5   PROC      NEAR

; ------ test, zda je povolen z pis do souboru

         test      byte ptr es:[EdiParm],bit2 ; je z kaz z pisu ?
         jnz       EditF69                  ; je z kaz z pisu

; ------ v re‘imu zobrazen¡ nen¡ operace povolena

         test      byte ptr es:[di+EdiParm1],bit0 ; je jen zobrazen¡ ?
         jnz       EditF69                  ; je jen zobrazen¡

; ------ test, zda je blok zapnut

         call      EditTstB                 ; test, zda je blok zapnut
         jc        EditF69                  ; blok nen¡ zapnut

; ------ zobrazen¡ hl ¨en¡ o prov dˆn¡ operace p©esunu bloku

         mov       si,offset EdiCpTxt       ; hl ¨en¡
         call      far ptr InfDisp0         ; hl ¨en¡ o kop¡rov n¡ bloku

; ------ ulo‘en¡ bloku do bufferu

         call      StorBlok                 ; ulo‘en¡ bloku do bufferu
         jc        EditF68                  ; nˆjak  chyba

; ------ n vrat bloku na pozici kurzoru

         jmp       short EditF67            ; n vrat bloku z bufferu

EditF5   ENDP

; -----------------------------------------------------------------------------
;        F6 - p©esun bloku
; -----------------------------------------------------------------------------

EditF6   PROC      NEAR

; ------ test, zda je povolen z pis do souboru

         test      byte ptr es:[EdiParm],bit2 ; je z kaz z pisu ?
         jnz       EditF69                  ; je z kaz z pisu

; ------ v re‘imu zobrazen¡ nen¡ operace povolena

         test      byte ptr es:[di+EdiParm1],bit0 ; je jen zobrazen¡ ?
         jnz       EditF69                  ; je jen zobrazen¡

; ------ test, zda je blok zapnut

         call      EditTstB                 ; test, zda je blok zapnut
         jc        EditF69                  ; blok nen¡ zapnut

; ------ zobrazen¡ hl ¨en¡ o prov dˆn¡ operace p©esunu bloku

         mov       si,offset EdiMvTxt       ; hl ¨en¡
         call      far ptr InfDisp0         ; hl ¨en¡ o p©esunu bloku

; ------ ulo‘en¡ bloku do bufferu

         call      StorBlok                 ; ulo‘en¡ bloku do bufferu
         jc        EditF68                  ; chyba

; ------ zru¨en¡ ozna‡en‚ho bloku

         call      DeltBlok                 ; zru¨en¡ bloku
         jc        EditF68                  ; chyba

; ------ n vrat bloku na pozici kurzoru
; sem se sk ‡e z EditF5 !
EditF67: call      RetnBlok                 ; n vrat bloku z bufferu

; ------ uzav©en¡ informa‡n¡ho © dku
; sem se sk ‡e z EditF5 a EditF8 !
EditF68: or        byte ptr ds:[EditPar2],bit3 ; p©¡znak zobrazen¡ v¨eho
         call      far ptr InfoClos         ; uzav©en¡ informa‡n¡ho © dku
EditF69: ret

EditF6   ENDP

; -----------------------------------------------------------------------------
;        F8 - ru¨en¡ bloku
; -----------------------------------------------------------------------------

EditF8   PROC      NEAR

; ------ test, zda je povolen z pis do souboru

         test      byte ptr es:[EdiParm],bit2 ; je z kaz z pisu ?
         jnz       EditF69                  ; je z kaz z pisu

; ------ test, zda je blok zapnut

         call      EditTstB                 ; test, zda je blok zapnut
         jc        EditF69                  ; blok nen¡ zapnut

;; ------ pro HEX m¢d se provede zaplnˆn¡ bloku ©etˆzcem
;
;         test      byte ptr es:[di+EdiParm1],bit1 ; je HEX m¢d ?
;         jnz       EditFFil                 ; je HEX m¢d - zaplnˆn¡ ©etˆzcem

; ------ zobrazen¡ hl ¨en¡ o prov dˆn¡ operace ru¨en¡ bloku

         mov       si,offset EdiDlTxt       ; hl ¨en¡
         call      far ptr InfDisp0         ; hl ¨en¡ o ru¨en¡ bloku

; ------ ulo‘en¡ bloku do bufferu

         call      StorBlok                 ; ulo‘en¡ bloku do bufferu
         jc        EditF68                  ; nˆjak  chyba

; ------ zru¨en¡ ozna‡en‚ho bloku

         call      DeltBlok                 ; zru¨en¡ ozna‡en‚ho bloku
         jmp       short EditF68            ; uzav©en¡ informa‡n¡ho © dku

EditF8   ENDP

; -----------------------------------------------------------------------------
;        modifikace bloku Ctrl-F8
; -----------------------------------------------------------------------------
;þ
EditCtF8 PROC      NEAR

; ------ test, zda je povolen z pis do souboru

         test      byte ptr es:[EdiParm],bit2 ; je z kaz z pisu ?
         jnz       EdiCtF82                 ; je z kaz z pisu

; ------ test, zda je blok zapnut

         call      EditTstB                 ; test, zda je blok zapnut
         jc        EdiCtF82                 ; blok nen¡ zapnut

; ------ volba operace

         and       byte ptr ds:[EdiHldP2],not bit2 ; nen¡ HEX tvar
         mov       si,offset EdModMnu       ; menu modifikace
         call      EdiCF8Sw                 ; p©¡prava p©ep¡na‡–
         call      far ptr CentMenu         ; vyst©edˆn¡ okna menu
         call      far ptr VertMenu         ; obsluha menu
EdiCtF82:ret                                ; p©eru¨en¡ operace

; ------ zmˆna p©ep¡na‡e

EditCF8P PROC      FAR

         mov       al,byte ptr ds:[si+MnuAkt] ; aktivn¡ polo‘ka
         sub       al,3                     ; korekce
         mov       ds:[EdiHlKod],al         ; nastaven¡ k¢du
         call      EdiCF8Sw                 ; nastaven¡ p©ep¡na‡–
         call      far ptr DispMnu          ; zobrazen¡ okna menu
         ret

EditCF8P ENDP

; ------ p©¡prava p©ep¡na‡–

EdiCF8Sw PROC      NEAR

         push      cx
         push      dx

         call      EdiF7KdP                 ; p©¡prava n rodn¡ho k¢du hled n¡
         mov       dl,bit0
         mov       cl,ds:[EdiHlKod]         ; k¢d
         dec       cx                       ; korekce ‡¡sla k¢du
         shl       dl,cl                    ; rotace bitu na pozici
         call      far ptr SetSwch          ; nastaven¡ p©ep¡na‡–

         pop       dx
         pop       cx
         ret

EdiCF8Sw ENDP

; ------ zad n¡ c¡lov‚ho k¢du pro zmˆnu font–

EdiCtF8F:add       sp,4                     ; zru¨en¡ n vratov‚ adresy
         call      far ptr ClosMnu          ; uzav©en¡ okna menu
         mov       si,offset EMFntMnu       ; volba font–
         mov       al,ds:[EdiMdKod]         ; minul˜ k¢d
         mov       byte ptr ds:[si+MnuAkt],al ; aktivn¡ polo‘ka
         push      dx
         call      far ptr Lin1Menu         ; volba menu
         pop       dx
         mov       al,byte ptr ds:[si+MnuAkt]
         mov       ds:[EdiMdKod],al         ; zvolen˜ k¢d
         jnc       EdiCF8F2                 ; nen¡ p©eru¨en¡
EdiCF8F1:ret

; ------ p©¡prava konverzn¡ tabulky pro konverzi font–

EdiCF8F2:mov       al,ds:[EdiHlKod]         ; p–vodn¡ n rodn¡ k¢d
         sub       al,2                     ; k¢d ASCII ?
         jb        EdiCF8F1                 ; k¢d ASCII nelze konvertovat
         mov       ah,6                     ; po‡et polo‘ek na k¢d
         mul       ah                       ; p©epo‡et na ‡¡slo tabulky
         add       al,ds:[EdiMdKod]         ; p©i‡ten¡ nov‚ho k¢du
         adc       ah,0
         shl       ax,1                     ; offset v tabulce k¢d–
         xchg      ax,bx                    ; BX <- offset
         mov       ax,SEG CodeDek
         mov       es,ax                    ; segment tabulky
         mov       si,es:[bx+KonvFntT-2]    ; adresa tabulky
         or        si,si                    ; je platn  konverze ?
         jz        EdiCF8F1                 ; nen¡ platn  tabulka

;!!!!! modifikace SP !!!!!!!
; lok ln¡ promˆnn‚: SS:[BP-4] (4) ‡¡ta‡ bajt–, SS:[BP-6] (2) blok BX
;  SS:[BP-10] (4) po‡ te‡n¡ pozice bloku, SS:[BP-14] (4) koncov  pozice bloku
;  SS:[BP-18] (4) ukazatel pozice bloku, SS:[BP-20] (2) parametry:
;                                  bit 6: 1=je sloupcov˜ blok
;                                  bit 7: 1=tabul tor je bˆ‘n˜ znak (z EdiParm1)

         mov       bp,sp
         sub       sp,256+20
         mov       di,sp
         push      ss
         pop       es
         mov       al,0
         cld
EdiCF8F3:stosb
         inc       al
         jns       EdiCF8F3
         jmp       short EdiCtF84

; ------ zmˆna na velk  p¡smena

EdiCtF8V:add       sp,4                     ; zru¨en¡ n vratov‚ adresy
         call      far ptr ClosMnu          ; uzav©en¡ okna menu

         mov       bl,ds:[EdiHlKod]         ; p–vodn¡ n rodn¡ k¢d
         mov       bh,0
         shl       bx,1
         mov       si,cs:[bx+EdiCtFCV-2]

;!!!!! modifikace SP !!!!!!!
; lok ln¡ promˆnn‚: SS:[BP-4] (4) ‡¡ta‡ bajt–, SS:[BP-6] (2) blok BX
;  SS:[BP-10] (4) po‡ te‡n¡ pozice bloku, SS:[BP-14] (4) koncov  pozice bloku
;  SS:[BP-18] (4) ukazatel pozice bloku, SS:[BP-20] (2) parametry:
;                                  bit 6: 1=je sloupcov˜ blok
;                                  bit 7: 1=tabul tor je bˆ‘n˜ znak (z EdiParm1)

         mov       bp,sp
         sub       sp,256+20
         mov       di,sp
         push      ss
         pop       es
         mov       ah,0
         cld
EdiCF8V3:mov       al,ah
         call      far ptr UpCase
         stosb
         inc       ah
         jns       EdiCF8V3
         jmp       short EdiCtF84

; ------ zmˆna na mal  p¡smena

EdiCtF8M:add       sp,4                     ; zru¨en¡ n vratov‚ adresy
         call      far ptr ClosMnu          ; uzav©en¡ okna menu

         mov       bl,ds:[EdiHlKod]         ; p–vodn¡ n rodn¡ k¢d
         mov       bh,0
         shl       bx,1
         mov       si,cs:[bx+EdiCtFCM-2]

;!!!!! modifikace SP !!!!!!!
; lok ln¡ promˆnn‚: SS:[BP-4] (4) ‡¡ta‡ bajt–, SS:[BP-6] (2) blok BX
;  SS:[BP-10] (4) po‡ te‡n¡ pozice bloku, SS:[BP-14] (4) koncov  pozice bloku
;  SS:[BP-18] (4) ukazatel pozice bloku, SS:[BP-20] (2) parametry:
;                                  bit 6: 1=je sloupcov˜ blok
;                                  bit 7: 1=tabul tor je bˆ‘n˜ znak (z EdiParm1)

         mov       bp,sp
         sub       sp,256+20
         mov       di,sp
         push      ss
         pop       es
         mov       ah,0
         cld
EdiCF8M3:mov       al,ah
         call      far ptr DownCase
         stosb
         inc       ah
         jns       EdiCF8M3

; ------ konverzn¡ tabulka pro > 128 (SI=adresa tabulky, DI=buffer)

EdiCtF84:mov       al,128
         push      di
EdiCtF85:stosb
         inc       al
         jnz       EdiCtF85
         pop       di
         or        si,si                    ; je tabulka platn  ?
         jz        EdiCtF86                 ; nen¡ platn 
         add       si,128
         push      ds
         mov       ax,SEG CodeDek
         mov       ds,ax
         mov       cx,128/2
         rep       movsw
         pop       ds

; ------ zobrazen¡ hl ¨en¡ o prov dˆn¡ operace

EdiCtF86:mov       si,offset EdiMdTxt       ; hl ¨en¡
         call      far ptr InfDisp0         ; hl ¨en¡ o modifikaci bloku

; ------ obnoven¡ adresy okna -> DX, ES

         mov       dx,ds:[EdiSAkt]          ; aktu ln¡ okno
         call      EditGetD                 ; poskytnut¡ adresy okna -> ES
         mov       di,EdiW1                 ; definice pro okno 1
         or        dx,dx                    ; je aktivn¡ okno 2 ?
         jns       EdiCtF87                 ; je aktivn¡ okno 1
         mov       di,EdiW2                 ; definice pro okno 2

; ------ p©¡prava lok ln¡ch promˆnn˜ch

EdiCtF87:mov       ah,es:[EdiParm]          ; parametr souboru
         and       ah,bit6                  ; p©¡znak sloupcov‚ho bloku
         mov       al,es:[di+EdiParm1]      ; parametr okna
         test      al,bit1+bit2             ; je textov˜ m¢d ?
         jz        EdiCF871                 ; je textov˜ m¢d
         mov       ah,0                     ; jinak nen¡ sloupcov˜ blok
EdiCF871:and       al,bit7                  ; p©¡znak tabul toru
         or        al,ah
         mov       ss:[bp-20],al            ; p©¡znaky

; ------ p©¡prava ukazatele pozice (pro sloupcov˜ blok)

         mov       ax,word ptr es:[EdiPBBlk] ; pozice za‡ tku bloku
         mov       ss:[bp-10],ax
         mov       ss:[bp-18],ax            ; ukazatel pozice bloku
         mov       ax,word ptr es:[EdiPBBlk+2]
         mov       ss:[bp-10+2],ax
         mov       ss:[bp-18+2],ax
         mov       ax,word ptr es:[EdiPKBlk] ; pozice konce bloku
         mov       ss:[bp-14],ax
         mov       ax,word ptr es:[EdiPKBlk+2]
         mov       ss:[bp-14+2],ax

; ------ p©¡prava parametr– operace -> BX:SI=offset za‡ tku, CX:AX=d‚lka

         push      bp
         call      StorBlTB                 ; p©¡prava parametr– operace
         pop       bp
         jnc       EdCF8714                 ; operace OK

;!!!!!!!!! n vrat SP !!!!!!!!

EdiCtF88:mov       sp,bp

         or        byte ptr ds:[EditPar2],bit3 ; p©¡znak zobrazen¡ v¨eho
         call      far ptr InfoClos         ; uzav©en¡ informa‡n¡ho © dku
         ret

EdCF8714:mov       ss:[bp-4+2],cx           ; ‡¡ta‡ HIGH
         mov       ss:[bp-4],ax             ; ‡¡ta‡ LOW
         mov       ss:[bp-6],bx             ; ukazatel bloku

; ------ test p©eru¨en¡ operace

EdiCF872:call      far ptr TestBEsc         ; je p©eru¨en¡ operace ?
         jc        EdiCtF88                 ; je p©eru¨en¡ operace

; ------ adresa bloku

         mov       bx,ss:[bp-6]             ; blok
         call      EditNGet                 ; poskytnut¡ bloku dat
         mov       ss:[bp-6],bx             ; nov˜ blok
         jz        EdiCtF88                 ; nejsou dal¨¡ data
         mov       bx,sp                    ; konverzn¡ tabulka
         dec       si                       ; p©ednastaven¡

; ------ test, zda jsou dal¨¡ data

EdiCF873:mov       ax,ss:[bp-4]
         or        ax,ss:[bp-4+2]           ; jsou dal¨¡ data ?
         jz        EdiCtF88                 ; nejsou dal¨¡ data
         inc       si                       ; posun ukazatele dat
         cmp       si,cx                    ; je platn˜ ukazatel ?
         jae       EdiCF872                 ; nen¡ platn˜ ukazatel

; ------ ‡¡ta‡ zbyl˜ch dat

         sub       word ptr ss:[bp-4],1     ; ‡¡ta‡ zbyl˜ch dat
         sbb       word ptr ss:[bp-4+2],0

; ------ konverze znaku

         mov       al,es:[si]               ; p©ipraven˜ znak
         mov       ah,al                    ; AH <- £schova znaku
         xlat      byte ptr ss:[bx]         ; konverze znaku
         cmp       al,ah                    ; zmˆnil se znak ?
         je        EdiCF877                 ; znak se nezmˆnil

; ------ test, zda je ve sloupcov‚m bloku

         test      byte ptr ss:[bp-20],bit6 ; je sloupcov˜ blok ?
         jz        EdiCF876                 ; nen¡ sloupcov˜ blok
         push      ax
         mov       ax,ss:[bp-18+2]          ; ukazatel pozice bloku HIGH
         cmp       ax,ss:[bp-14+2]          ; je za koncem bloku ?
         jne       EdiCF874
         mov       ax,ss:[bp-18]            ; ukazatel pozice bloku LOW
         cmp       ax,ss:[bp-14]
EdiCF874:cmc                                ; CY = nen¡ p©ed koncem bloku
         jb        EdiCF875                 ; ukazatel nen¡ p©ed koncem bloku
         mov       ax,ss:[bp-18+2]          ; ukazatel pozice bloku HIGH
         cmp       ax,ss:[bp-10+2]          ; je p©ed po‡ tkem bloku ?
         jne       EdiCF875
         mov       ax,ss:[bp-18]            ; ukazatel pozice bloku LOW
         cmp       ax,ss:[bp-10]
EdiCF875:pop       ax
         jc        EdiCF877                 ; nen¡ ve sloupcov‚m bloku

; ------ modifikace dat

EdiCF876:mov       es:[si],al               ; ulo‘en¡ nov‚ho znaku
         call      EdiCF8Pz                 ; zv˜¨en¡ ukazatele pozice
         inc       si                       ; zv˜¨en¡ ukazatele textu
         call      EditGetD                 ; adresa okna -> ES
         mov       bx,ss:[bp-6]             ; blok
         shl       bx,1
         shl       bx,1
         shl       bx,1                     ; ‡¡slo bloku * 8
         add       bx,EdiABlok              ; adresa bloku
         cmp       word ptr es:[bx+EdiBlokM],0 ; je blok v pamˆti ?
         je        EdiCF872                 ; nen¡ blok v pamˆti
         or        byte ptr es:[bx+EdiBlokM+1],bit15/bit8 ; p©¡znak modifikace
         or        byte ptr es:[EdiParm],bit0 ; p©¡znak modifikace souboru
         jmp       EdiCF872                 ; dal¨¡ znak

; ------ zv˜¨en¡ ukazatele pozice, pokud se znak nezmˆnil

EdiCF877:call      EdiCF8Pz                 ; zv˜¨en¡ ukazatele pozice
         jmp       short EdiCF873           ; dal¨¡ znak

EditCtF8 ENDP

; ------ inkrementace pozice - znak AL

EdiCF8Pz PROC      NEAR

         test      byte ptr ss:[bp-20],bit6 ; je sloupcov˜ blok ?
         jz        EdiCF8P9                 ; nen¡ sloupcov˜ blok

         cmp       al,CR                    ; je znak CR ?
         je        EdiCF8P9                 ; znak CR se ignoruje
         cmp       al,LF                    ; je konec © dku LF ?
         jne       EdiCF8P4                 ; nen¡ konec © dku LF
         mov       word ptr ss:[bp-18],0    ; nulov n¡ ukazatele pozice
         mov       word ptr ss:[bp-18+2],0
         ret

EdiCF8P4:cmp       al,TAB                   ; je tabul tor ?
         jne       EdiCF8P6                 ; nen¡ tabul tor
         test      byte ptr ss:[bp-20],bit7 ; je tabul tor bˆ‘n˜ znak ?
         jnz       EdiCF8P6                 ; tabul tor je bˆ‘n˜ znak
         add       word ptr ss:[bp-18],8
         adc       word ptr ss:[bp-18+2],0
         and       byte ptr ss:[bp-18],not 7
         ret

EdiCF8P6:add       word ptr ss:[bp-18],1    ; zv˜¨en¡ ukazatele pozice
         adc       word ptr ss:[bp-18+2],0
EdiCF8P9:ret

EdiCF8Pz ENDP

EdiCtFCV label     word
         dw        0                        ; ASCII - nen¡ tabulka
         dw        TbIBMUpC-128             ; konverze k¢du IBM na velk  p¡smena
         dw        TbKamUpC-128             ; konverze k¢du Kamenick˜ch na velk 
         dw        TbLatUpC-128             ; konverze k¢du Latin 2 na velk  p.
         dw        TbKOIUpC-128             ; konverze k¢du KOI 8 na velk  p¡sm.
         dw        TbWinUpC-128             ; konverze k¢du WIN na velk  p¡sm.

EdiCtFCM label     word
         dw        0                        ; ASCII - nen¡ tabulka
         dw        TbIBMDnC-128             ; konverze k¢du IBM na mal  p¡smena
         dw        TbKamDnC-128             ; konverze k¢du Kamenick˜ch na mal 
         dw        TbLatDnC-128             ; konverze k¢du Latin 2 na mal  p.
         dw        TbKOIDnC-128             ; konverze k¢du KOI 8 na mal  p¡sm.
         dw        TbWinDnC-128             ; konverze k¢du WIN na mal  p¡sm.

;; -----------------------------------------------------------------------------
;;        zaplnˆn¡ bloku ©etˆzcem
;; -----------------------------------------------------------------------------
;
;EditFFil PROC      NEAR
;
;
;         ret
;
;EditFFil ENDP

; -----------------------------------------------------------------------------
;        ulo‘en¡ bloku do bufferu Ctrl-], Ctrl-Insert
; -----------------------------------------------------------------------------

Stor0Blk PROC      NEAR

; ------ test, zda je blok zapnut

         call      EditTstB                 ; test, zda je blok zapnut
         jc        Stor0Bl9                 ; blok nen¡ zapnut

; ------ zobrazen¡ hl ¨en¡ o prov dˆn¡ operace

         mov       si,offset EdiUkTxt       ; hl ¨en¡
         call      far ptr InfDisp0         ; hl ¨en¡ o ukl d n¡ bloku

; ------ ulo‘en¡ bloku do bufferu

         call      StorBlok                 ; ulo‘en¡ bloku do bufferu

; ------ uzav©en¡ informa‡n¡ho © dku

         or        byte ptr ds:[EditPar2],bit3 ; p©¡znak zobrazen¡ v¨eho
         call      far ptr InfoClos         ; uzav©en¡ informa‡n¡ho © dku
Stor0Bl9:ret

Stor0Blk ENDP

; -----------------------------------------------------------------------------
;        navr cen¡ bloku z bufferu Ctrl-^, Shift-Insert
; -----------------------------------------------------------------------------

Retn0Blk PROC      NEAR

; ------ test, zda je operace povolena

         test      byte ptr es:[EdiParm],bit2 ; je z kaz z pisu ?
         jnz       Retn0Bl9                 ; je z kaz z pisu
         test      byte ptr es:[di+EdiParm1],bit0 ; je jen zobrazen¡ ?
         jnz       Retn0Bl9                 ; je jen zobrazen¡

; ------ zobrazen¡ hl ¨en¡ o operaci

         mov       si,offset EdiNaTxt       ; hl ¨en¡
         call      far ptr InfDisp0         ; hl ¨en¡ o navracen¡ bloku

; ------ navr cen¡ bloku z bufferu

         call      RetnBlok                 ; navr cen¡ bloku z bufferu

; ------ uzav©en¡ informa‡n¡ho © dku

         or        byte ptr ds:[EditPar2],bit3 ; p©¡znak zobrazen¡ v¨eho
         call      far ptr InfoClos         ; uzav©en¡ informa‡n¡ho © dku
Retn0Bl9:ret

Retn0Blk ENDP

; -----------------------------------------------------------------------------
;                                DeltBlok
;                    zru¨en¡ ozna‡en‚ho bloku (F8)
; -----------------------------------------------------------------------------
; VSTUP: DX=segment okna
;        DI=offset definice okna
;        DS=datov˜ segment
; VSTUP: CY=chyba operace
;         ES=nov  adresa okna
; -----------------------------------------------------------------------------

DeltBlok PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      si
         push      di
         push      bp

; ------ adresa okna -> ES

         call      EditGetD                 ; adresa okna -> ES
         jc        DeltBlk0                 ; neplatn  adresa okna

; ------ ukon‡en¡ ozna‡ov n¡ bloku Shift-

         call      EdiEShft                 ; ukon‡en¡ ozna‡ov n¡ bloku

; ------ test, je-li operace povolena

         test      byte ptr es:[EdiParm],bit2 ; je povolena editace souboru ?
         jnz       DeltBlk0                 ; z kaz z pisu

; ------ test, zda je blok zapnut

         call      EditTstB                 ; test, zda je blok zapnut
         jnc       DeltBlk1                 ; blok je zapnut OK
DeltBlk0:jmp       DeltBlk9                 ; CY=chyba

; ------ v bin rn¡m a HEX m¢du je pouze textov˜ blok

DeltBlk1:or        byte ptr ds:[EditPar2],bit3 ; p©¡znak - zobrazit v¨e

         test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je textov˜ m¢d ?
         jnz       DeltBl12                 ; nen¡ textov˜ m¢d

; ------ test, zda je sloupcov˜ blok

         test      byte ptr es:[EdiParm],bit6 ; je sloupcov˜ blok ?
         jnz       DeltBlk2                 ; je sloupcov˜ blok
DeltBl12:jmp       DeltBlk6                 ; nen¡ sloupcov˜ blok

; ====== zru¨en¡ sloupcov‚ho bloku

; ------ adresa © dku sloupcov‚ho bloku

DeltBlk2:mov       bp,word ptr es:[EdiRBBlk+2] ; © dek za‡ tku bloku HIGH
         mov       di,word ptr es:[EdiRBBlk] ; © dek za‡ tku bloku LOW
DeltBl21:call      StorBlSB                 ; velikost dat ke zru¨en¡
         jc        DeltBlk0                 ; chyba

; ------ zru¨en¡ dat BX:SI/d‚lka CX:AX

         or        ax,ax                    ; jsou nˆjak  data ke zru¨en¡ ?
         jnz       DeltBlk3                 ; jsou nˆjak  data ke zru¨en¡
         jcxz      DeltBlk4                 ; nejsou ‘ dn  data ke zru¨en¡
DeltBlk3:call      EditDel                  ; zru¨en¡ dat
         jc        DeltBlk0                 ; chyba operace

; ------ o©ez n¡ mezer na konci © dku

         mov       ax,di                    ; © dek LOW
         mov       cx,bp                    ; © dek HIGH
         call      EdiGetLn                 ; adresa © dku -> BX:SI
         jc        DeltBlk0                 ; chyba
         call      EditLOrz                 ; o©ez n¡ mezer na konci © dku
         jc        DeltBlk0                 ; chyba

; ------ oprava pozice kurzoru v oknech (CX:AX=po‡et ru¨en˜ch bajt–)

DeltBlk4:mov       si,EdiW1                 ; okno 1
         call      DeltBSlK                 ; oprava pozice kurzoru v oknˆ 1
         mov       si,EdiW2                 ; okno 2
         call      DeltBSlK                 ; oprava pozice kurzoru v oknˆ 2

; ------ posun k dal¨¡mu © dku

         add       di,1                     ; zv˜¨en¡ ‡¡sla © dku
         adc       bp,0

; ------ kontrola, zda jsou ji‘ v¨echny © dky bloku

         cmp       bp,word ptr es:[EdiRKBlk+2] ; dosa‘eno koncov‚ho © dku ?
         jne       DeltBlk5
         cmp       di,word ptr es:[EdiRKBlk]
DeltBlk5:jbe       DeltBl21                 ; nen¡ je¨tˆ koncov˜ © dek + 1
                                          ;* zde je nastaven NC !
         jmp       short DeltBlk8           ; byly ji‘ v¨echny © dky


; ====== zru¨en¡ © dkov‚ho a textov‚ho bloku

DeltBlk6:call      StorBlTB                 ; p©¡prava dat pro operaci
         jc        DeltBl62                 ; chyba
         jz        DeltBlk7                 ; nejsou data k ru¨en¡
         call      EditDel                  ; zru¨en¡ dat
DeltBl62:jc        DeltBlk9                 ; chyba

; ------ posun kurzor– po ru¨en¡ textov‚ho a © dkov‚ho bloku

DeltBlk7:push      dx
         mov       di,EdiW1                 ; definice pro okno 1
         and       dh,not bit15/bit8        ; p©¡znak okna 1
         call      DeltKur                  ; posun kurzoru po ru¨en¡
         mov       di,EdiW2                 ; definice pro okno 2
         or        dh,bit15/bit8            ; p©¡znak okna 2
         call      DeltKur                  ; posun kurzoru pro ru¨en¡
         pop       dx

; ------ o©ez n¡ mezer v textov‚m m¢du u textov‚ho bloku

         mov       di,EdiW1                 ; definice pro okno 1
         or        dx,dx                    ; je okno 1 ?
         jnz       DeltBl71                 ; je okno 1
         mov       di,EdiW2                 ; definice pro okno 2
DeltBl71:test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je BIN/HEX m¢d ?
         jnz       DeltBl72                 ; nen¡ textov˜ m¢d
         test      byte ptr es:[EdiParm],bit6+bit7 ; je textov˜ blok ?
         jnz       DeltBl72                 ; nen¡ textov˜ blok
         mov       ax,word ptr es:[EdiRBBlk] ; © dek za‡ tku bloku LOW
         mov       cx,word ptr es:[EdiRBBlk+2] ; © dek za‡ tku bloku HIGH
         call      EdiGetLn                 ; adresa © dku -> BX:SI
         jc        DeltBlk9                 ; chyba
         call      EditLOrz                 ; o©ez n¡ mezer na konci © dku
         jc        DeltBlk9                 ; chyba

; ------ posun ukazatel– bloku ZA€TEK=>KONEC

DeltBl72:mov       ax,word ptr es:[EdiOBBlk] ; offset za‡ tku bloku
         mov       word ptr es:[EdiOKBlk],ax ; bude to konec bloku
         mov       ax,word ptr es:[EdiOBBlk+2]
         mov       word ptr es:[EdiOBBlk+2],ax
         mov       ax,word ptr es:[EdiRBBlk] ; © dek za‡ tku bloku
         mov       word ptr es:[EdiRKBlk],ax ; bude to konec bloku
         mov       ax,word ptr es:[EdiRBBlk+2]
         mov       word ptr es:[EdiRKBlk+2],ax

; ------ korekce i pro sloupcov˜ blok

DeltBlk8:mov       ax,word ptr es:[EdiPBBlk] ; pozice za‡ tku bloku
         mov       word ptr es:[EdiPKBlk],ax ; bude to konec bloku
         mov       ax,word ptr es:[EdiPBBlk+2]
         mov       word ptr es:[EdiPKBlk+2],ax

; ------ aktualizace oken

         and       byte ptr es:[EdiW1+EdiParm2],not bit5 ; vypnut¡ bloku okna 1
         and       byte ptr es:[EdiW2+EdiParm2],not bit5 ; vypnut¡ bloku okna 2

DeltBlk9:pushf
         call      EditModA                 ; po‘adavek aktualizace oken
         call      EditAktW                 ; aktualizace kurzor–
         popf

; ------ n vrat registr–

         pop       bp
         pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

DeltBlok ENDP

; ------ oprava kurzoru v oknˆ ES:SI po zru¨en¡ dat v sloupcov‚m bloku

DeltBSlK:cmp       di,word ptr es:[si+EdiRKur] ; je to © dek s kurzorem ?
         jne       DelBSlK4                 ; nen¡ to © dek s kurzorem
         cmp       bp,word ptr es:[si+EdiRKur+2]
         jne       DelBSlK4

; ------ je © dek s kurzorem - test, zda je za koncem bloku

         mov       ax,word ptr es:[EdiPKBlk+2] ; pozice konce bloku
         cmp       ax,word ptr es:[si+EdiPKur+2] ; je p©ed kurzorem ?
         jne       DelBSlK2
         mov       ax,word ptr es:[EdiPKBlk] ; pozice konce bloku
         cmp       ax,word ptr es:[si+EdiPKur] ; je konec bloku p©ed kurzorem ?
DelBSlK2:ja        DelBSlK4                 ; kurzor nen¡ za koncem bloku

; ------ sn¡‘en¡ pozice kurzoru v oknˆ

         test      byte ptr es:[si+EdiParm1],bit1+bit2 ; je textov˜ m¢d ?
         jnz       DelBSlK4                 ; nen¡ textov˜ m¢d

         mov       ax,word ptr es:[EdiPKBlk] ; pozice konce bloku
         mov       cx,word ptr es:[EdiPKBlk+2]
         sub       ax,word ptr es:[EdiPBBlk] ; ¨¡©ka bloku
         sbb       cx,word ptr es:[EdiPBBlk+2]

         sub       word ptr es:[si+EdiPKur],ax ; sn¡‘en¡ pozice kurzoru
         sbb       word ptr es:[si+EdiPKur+2],cx
         jnc       DelBSlK4
         mov       word ptr es:[si+EdiPKur],0
         mov       word ptr es:[si+EdiPKur+2],0

DelBSlK4:ret

; -----------------------------------------------------------------------------
;        posun kurzoru po ru¨en¡ textov‚ho a © dkov‚ho bloku (okno ES:DI)
; -----------------------------------------------------------------------------

DeltKur  PROC      NEAR

; ------ test, zda je BIN/HEX m¢d

         test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je BIN/HEX m¢d ?
         jz        DeltKur1                 ; je textov˜ m¢d

; ------ offset kurzoru od konce bloku

         mov       ax,word ptr es:[di+EdiOffsK] ; offset kurzoru
         mov       cx,word ptr es:[di+EdiOffsK+2]
         sub       ax,word ptr es:[EdiOKBlk] ; offset od konce bloku
         sbb       cx,word ptr es:[EdiOKBlk+2]
         jc        DeltKr32                 ; nen¡ za koncem bloku - konec

; ------ nastaven¡ nov‚ pozice a © dku kurzoru v bin rn¡m a HEX m¢du

         push      di
         add       ax,word ptr es:[EdiOBBlk] ; nov˜ offset kurzoru
         adc       cx,word ptr es:[EdiOBBlk+2]
         call      EdiGetAd                 ; p©evod na ukazatel v souboru
         call      EdiBORad                 ; p©evod na © dek a pozici
         mov       si,di                    ; SI <- pozice LOW
         pop       di
         call      EditSetK                 ; nastaven¡ © dku s kurzorem
         xchg      ax,si                    ; AX <- pozice kurzoru LOW
         mov       cx,bp                    ; CX <- pozice kurzoru HIGH
         call      EditStKP                 ; nastaven¡ pozice kurzoru
         jmp       short DeltKr32

; ------ test, zda je kurzor za koncov˜m © dkem bloku

DeltKur1:mov       ax,word ptr es:[EdiRKBlk] ; © dek konce bloku
         mov       cx,word ptr es:[EdiRKBlk+2]
         cmp       cx,word ptr es:[di+EdiRKur+2] ; je p©ed kurzorem ?
         jne       DeltKur2
         cmp       ax,word ptr es:[di+EdiRKur]
DeltKur2:ja        DeltKr32                 ; kurzor je p©ed koncem bloku
         jb        DeltKur6                 ; kurzor je za koncem bloku

; ------ u © dkov‚ho bloku se pozice nekoriguje

         test      byte ptr es:[EdiParm],bit7 ; je © dkov˜ blok ?
         jnz       DeltKr32                 ; je © dkov˜ blok - nen¡ pozice

; ------ test, zda je kurzor za koncovou pozic¡ bloku

         mov       ax,word ptr es:[EdiPKBlk] ; pozice konce bloku
         mov       cx,word ptr es:[EdiPKBlk+2]
         cmp       cx,word ptr es:[di+EdiPKur+2] ; je p©ed kurzorem ?
         jne       DeltKur3
         cmp       ax,word ptr es:[di+EdiPKur]
DeltKur3:jbe       DeltKr34                 ; kurzor je za koncem bloku
DeltKr32:jmp       DeltKur9

; ------ oprava pozice kurzoru, je-li kurzor za koncem bloku

DeltKr34:sub       word ptr es:[di+EdiPKur],ax ; ode‡ten¡ pozice konce bloku
         sbb       word ptr es:[di+EdiPKur+2],cx
         mov       ax,word ptr es:[EdiPBBlk] ; pozice za‡ tku bloku
         mov       cx,word ptr es:[EdiPBBlk+2]
         add       word ptr es:[di+EdiPKur],ax ; p©i‡ten¡ pozice za‡ tku bloku
         adc       word ptr es:[di+EdiPKur+2],cx

; ------ posledn¡ © dek bloku -> CX:AX

DeltKur6:mov       ax,word ptr es:[EdiRKBlk] ; © dek konce bloku
         mov       cx,word ptr es:[EdiRKBlk+2]
         test      byte ptr es:[EdiParm],bit7 ; je © dkov˜ blok ?
         jz        DeltKur7                 ; nen¡ © dkov˜ blok
         add       ax,1                     ; korekce pro © dkov˜ blok
         adc       cx,0

; ------ po‡et ru¨en˜ch © dk– -> CX:AX

DeltKur7:sub       ax,word ptr es:[EdiRBBlk] ; ode‡ten¡ © dku za‡ tku bloku
         sbb       cx,word ptr es:[EdiRBBlk+2]
         jc        DeltKur9

; ------ posun © dku s kurzorem

         sub       word ptr es:[di+EdiRKur],ax ; oprava © dku s kurzorem
         sbb       word ptr es:[di+EdiRKur+2],cx
         jnc       DeltKur8
         mov       word ptr es:[di+EdiRKur],0
         mov       word ptr es:[di+EdiRKur+2],0

; ------ posun po‡ te‡n¡ho © dku o CX:AX © dk–

DeltKur8:sub       word ptr es:[di+EdiRTop],ax
         sbb       word ptr es:[di+EdiRTop+2],cx
         jnc       DeltKur9
         mov       word ptr es:[di+EdiRTop],0
         mov       word ptr es:[di+EdiRTop+2],0

DeltKur9:ret

DeltKur  ENDP

; -----------------------------------------------------------------------------
;                                StorBlok
;                  ulo‘en¡ ozna‡en‚ho bloku do bufferu
; -----------------------------------------------------------------------------
; VSTUP: DX=segment okna
;        DI=offset definice okna
;        DS=datov˜ segment
; VSTUP: CY=chyba operace
;         ES=nov  adresa okna
; -----------------------------------------------------------------------------

StorBlok PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      si
         push      di
         push      bp

; ------ adresa okna -> ES

         call      EditGetD                 ; adresa okna -> ES
         jc        StorBlk0                 ; neplatn  adresa okna

; ------ £schova typu bloku (pro BIN a HEX m¢d bude v‘dy jako textov˜ blok)->BL

         mov       bl,es:[EdiParm]          ; £schova parametr– souboru
         test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je BIN/HEX m¢d ?
         jz        StorBl02                 ; nen¡ BIN/HEX m¢d
         and       bl,not bit6+bit7         ; bude v‘dy jako textov˜ blok

; ------ test, zda je blok zapnut

StorBl02:call      EditTstB                 ; test, zda je blok zapnut
         jnc       StorBlk1                 ; blok je zapnut OK
StorBlk0:jmp       StorBlk9                 ; CY=chyba

; ------ vynulov n¡ segmentu bufferu

StorBlk1:mov       al,bl                    ; AL <- typ bloku
         call      NulSBuf                  ; nulov n¡ segmentu bufferu

; ------ obnoven¡ adresy okna -> ES

         call      EditGetD                 ; nov  adresa okna -> ES

; ------ relativn¡ © dek konce bloku -> CX:AX (£schova do z sobn¡ku)

         push      es                       ; adresa okna

         mov       ax,word ptr es:[EdiRKBlk] ; © dek konce bloku LOW
         mov       cx,word ptr es:[EdiRKBlk+2] ; © dek konce bloku HIGH
         sub       ax,word ptr es:[EdiRBBlk] ; vzd lenost od © dku po‡ tku bloku
         sbb       cx,word ptr es:[EdiRBBlk+2]
         push      ax                       ; relativn¡ © dek konce bloku LOW
         push      cx                       ; relativn¡ © dek konce bloku HIGH

; ------ relativn¡ pozice konce bloku -> CX:AX (£schova do z sobn¡ku)

         or        ax,cx                    ; je to stejn˜ © dek ?
         mov       ax,word ptr es:[EdiPKBlk] ; pozice konce bloku LOW
         mov       cx,word ptr es:[EdiPKBlk+2] ; pozice konce bloku HIGH
         jz        StorBl11                 ; je to stejn˜ © dek
         test      bl,bit6                  ; je to sloupcov˜ blok ?
         jz        StorBl12                 ; nen¡ to sloupcov˜ blok
StorBl11:sub       ax,word ptr es:[EdiPBBlk] ; vzd lenost od pozice po‡ tku
         sbb       cx,word ptr es:[EdiPBBlk+2]
StorBl12:push      ax                       ; relativn¡ pozice konce bloku LOW
         push      cx                       ; relativn¡ pozice konce bloku HIGH

; ------ d‚lka bloku v bajtech -> CX:AX (£schova do z sobn¡ku)

         mov       ax,word ptr es:[EdiOKBlk] ; offset konce bloku LOW
         mov       cx,word ptr es:[EdiOKBlk+2] ; offset konce bloku HIGH
         sub       ax,word ptr es:[EdiOBBlk] ; vzd lenost od offsetu za‡ tku
         sbb       cx,word ptr es:[EdiOBBlk+2]
         push      ax                       ; d‚lka bloku LOW
         push      cx                       ; d‚lka bloku HIGH

; ------ adresa bufferu -> ES

         call      EditGetB                 ; adresa bufferu -> ES

; ------ nastaven¡ ukazatel– bloku v bufferu (po‡ tek bloku je vynulov n)

         pop       word ptr es:[EdiOKBlk+2] ; offset konce bloku HIGH
         pop       word ptr es:[EdiOKBlk]   ; offset konce bloku LOW
         pop       word ptr es:[EdiPKBlk+2] ; pozice konce bloku HIGH
         pop       word ptr es:[EdiPKBlk]   ; pozice konce bloku LOW
         pop       word ptr es:[EdiRKBlk+2] ; © dek konce bloku HIGH
         pop       word ptr es:[EdiRKBlk]   ; © dek konce bloku LOW

         pop       es                       ; n vrat adresy okna

; ------ test, zda je sloupcov˜ blok

         test      bl,bit6                  ; je sloupcov˜ blok ?
         jz        StorBlk6                 ; nen¡ sloupcov˜ blok


; ====== bude sloupcov˜ blok
; ------ adresa a d‚lka © dku sloupcov‚ho bloku -> BX:SI a CX:AX

         mov       bp,word ptr es:[EdiRBBlk+2] ; © dek za‡ tku bloku HIGH
         mov       di,word ptr es:[EdiRBBlk] ; © dek za‡ tku bloku LOW
StorBlk2:call      StorBlSB                 ; velikost dat k ulo‘en¡
         jc        StorBlk9                 ; chyba

; ------ ulo‘en¡ dat BX:SI/d‚lka CX:AX

         or        ax,ax                    ; jsou nˆjak  data k ulo‘en¡ ?
         jnz       StorBlk3                 ; jsou nˆjak  data
         jcxz      StorBlk4                 ; nejsou ‘ dn  data na © dku
StorBlk3:call      EdiToBf0                 ; £schova dat do bufferu
         jc        StorBlk9                 ; chyba operace

; ------ ulo‘en¡ konce © dku CR/LF

StorBlk4:call      EdiCrlBf                 ; ulo‘en¡ CR/LF do bufferu
         jc        StorBlk9                 ; chyba operace

; ------ obnoven¡ adresy okna -> ES

         call      EditGetD                 ; nov  adresa okna -> ES

; ------ posun k dal¨¡mu © dku

         add       di,1                     ; zv˜¨en¡ ‡¡sla © dku
         adc       bp,0

; ------ kontrola, zda jsou ji‘ v¨echny © dky bloku

         cmp       bp,word ptr es:[EdiRKBlk+2] ; dosa‘eno koncov‚ho © dku ?
         jne       StorBlk5
         cmp       di,word ptr es:[EdiRKBlk]
StorBlk5:jbe       StorBlk2                 ; nen¡ je¨tˆ koncov˜ © dek + 1
;         je        StorBlk2                 ; nen¡ je¨tˆ koncov˜ © dek + 1

                                          ;* zde je nastaven NC !
         jmp       short StorBlk9           ; byly ji‘ v¨echny © dky (je NC !)


; ====== bude textov˜ a © dkov˜ blok
; ------ ulo‘en¡ © dkov‚ho a textov‚ho bloku

StorBlk6:call      StorBlTB                 ; p©¡prava dat pro operaci
         jc        StorBlk9                 ; chyba ?
         jz        StorBlk9                 ; nejsou data k ulo‘en¡
         call      EdiToBf0                 ; £schova dat do bufferu

; ------ n vrat registr–

StorBlk9:pop       bp
         pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
         call      EditGt0D                 ; obnoven¡ adresy okna
         ret

StorBlok ENDP

; -----------------------------------------------------------------------------
;po‡et bajt– na © dku BP:DI pro operaci se sloupc. blokem->CX:AX,BX:SI(CY=chyba)
; -----------------------------------------------------------------------------

StorBlSB PROC      NEAR

; ------ £schova registr–

         push      di                       ; ‡¡slo © dku LOW
         push      bp                       ; ‡¡slo © dku HIGH

; ------ nalezen¡ adresy © dku -> BX:SI

         mov       ax,di                    ; © dek LOW
         mov       cx,bp                    ; © dek HIGH
         call      EdiGetLn                 ; adresa © dku -> BX:SI
         jc        StrBlSB9                 ; chyba

; ------ offset konce bloku na © dku BX:SI -> CX:AX

         call      EdiGtPKB                 ; offset konce bloku na © dku
         jc        StrBlSB9                 ; chyba

; ------ offset za‡ tku bloku na © dku BX:SI -> BP:DI (BX:SI), adresa BX:SI

         push      ax                       ; offset konce bloku LOW
         push      cx                       ; offset konce bloku HIGH

         call      EdiGtPBB                 ; offset za‡ tku bloku -> CX:AX
         xchg      ax,di                    ; DI <- offset LOW
         mov       bp,cx                    ; BP <- offset HIGH

         pop       cx                       ; offset konce bloku HIGH
         pop       ax                       ; offset konce bloku LOW

; ------ velikost dat pro operaci -> CX:AX

         pushf
         sub       ax,di                    ; d‚lka dat k ulo‘en¡/ru¨en¡ LOW
         sbb       cx,bp                    ; d‚lka dat k ulo‘en¡/ru¨en¡ HIGH
         popf

; ------ n vrat registr–

StrBlSB9:pop       bp
         pop       di
         ret

StorBlSB ENDP

; -----------------------------------------------------------------------------
;        p©¡prava pro zru¨en¡/ulo‘en¡ textov‚ho a © dkov‚ho bloku (CY=chyba)
; -----------------------------------------------------------------------------

StorBlTB PROC      NEAR

; ------ pro bin rn¡ a HEX m¢d plat¡ offset ukazatel–

         mov       ax,word ptr es:[EdiOKBlk] ; offset konce bloku LOW
         mov       cx,word ptr es:[EdiOKBlk+2] ; offset konce bloku HIGH
         test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je BIN/HEX m¢d ?
         jnz       StrBlTB5                 ; je BIN/HEX m¢d

; ------ offset © dku konce bloku -> BX:SI

         mov       ax,word ptr es:[EdiRKBlk] ; © dek konce bloku
         mov       cx,word ptr es:[EdiRKBlk+2]
         test      byte ptr es:[EdiParm],bit7 ; je © dkov˜ blok ?
         jz        StrBlTB2                 ; nen¡ © dkov˜ blok
         add       ax,1                     ; n sleduj¡c¡ © dek
         adc       cx,0
StrBlTB2:call      EdiGetLn                 ; poskytnut¡ adresy © dku -> BX:SI
         jc        StrBlTB9                 ; nˆjak  chyba

; ------ offset pozice konce bloku -> CX:AX

         test      byte ptr es:[EdiParm],bit7 ; je © dkov˜ blok ?
         jnz       StrBlTB4                 ; je © dkov˜ blok (pou‘ije se © dek)
         mov       ax,word ptr es:[EdiPKBlk] ; pozice konce bloku
         mov       cx,word ptr es:[EdiPKBlk+2]
         call      EditGtPO                 ; adresa pozice konce bloku -> BX:SI
         jc        StrBlTB9
StrBlTB4:call      EdiGetOf                 ; v˜po‡et offsetu konce bloku

; ------ offset za‡ tku bloku -> BP:DI, adresa za‡ tku bloku -> BX:SI

StrBlTB5:push      ax                       ; offset konce bloku
         push      cx

         mov       ax,word ptr es:[EdiOBBlk] ; offset za‡ tku bloku
         mov       cx,word ptr es:[EdiOBBlk+2]
         call      EdiGetAd                 ; v˜po‡et adresy v souboru -> BX:SI
         test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je BIN/HEX m¢d ?
         jnz       StrBlTB7                 ; je BIN/HEX m¢d

         mov       ax,word ptr es:[EdiRBBlk] ; © dek za‡ tku bloku
         mov       cx,word ptr es:[EdiRBBlk+2]
         call      EdiGetLn                 ; poskytnut¡ adresy © dku -> BX:SI
         jc        StrBlTB8                 ; nˆjak  chyba
         test      byte ptr es:[EdiParm],bit7 ; je © dkov˜ blok ?
         jnz       StrBlTB6                 ; je © dkov˜ blok
         mov       ax,word ptr es:[EdiPBBlk] ; pozice za‡ tku bloku
         mov       cx,word ptr es:[EdiPBBlk+2]
         call      EditGtPO                 ; adresa pozice za‡ tku bloku
         jc        StrBlTB8                 ; chyba
StrBlTB6:call      EdiGetOf                 ; v˜po‡et offsetu za‡ tku bloku
                                          ;* zde se navrac¡ NC !
StrBlTB7:xchg      ax,di                    ; DI <- offset za‡ tku LOW
         mov       bp,cx                    ; BP <- offset za‡ tku HIGH

StrBlTB8:pop       cx                       ; offset konce HIGH
         pop       ax                       ; offset konce LOW
         jc        StrBlTB9                 ; chyba

; ------ po‡et bajt– pro operaci -> CX:AX

         sub       ax,di                    ; po‡et bajt– k ulo‘en¡
         sbb       cx,bp
         jnz       StrBlTB9                 ; jsou nˆjak  data nebo chyba
         or        ax,ax                    ; jsou nˆjak  data k ulo‘en¡ ?
StrBlTB9:ret

StorBlTB ENDP

; -----------------------------------------------------------------------------
; offset za‡ tku bloku na © dku BX:SI (okno DX, adresa ES)->CX:AX,BX:SI,CY=chyba
;          (pou‘¡v  se pouze p©i ukl d n¡ sloupcov‚ho bloku do bufferu)
; -----------------------------------------------------------------------------

EdiGtPBB PROC      NEAR

; ------ adresa pozice za‡ tku bloku -> BX:SI

         mov       ax,word ptr es:[EdiPBBlk] ; pozice za‡ tku bloku
         mov       cx,word ptr es:[EdiPBBlk+2]
         call      EditGtPO                 ; adresa pozice za‡ tku bloku
         jc        EdiGPBB4                 ; chyba operace

; ------ v˜po‡et offsetu pozice za‡ tku bloku -> CX:AX

         call      EdiGetOf                 ; v˜po‡et offsetu za‡ tku bloku
                                          ;* zde se navrac¡ NC !
; ------ n vrat registr–

EdiGPBB4:ret

EdiGtPBB ENDP

; -----------------------------------------------------------------------------
;      offset konce bloku na © dku BX:SI (okno DX, adresa ES) -> CX:AX, CY=chyba
;          (pou‘¡v  se pouze p©i ukl d n¡ sloupcov‚ho bloku do bufferu)
; -----------------------------------------------------------------------------

EdiGtPKB PROC      NEAR

; ------ £schova registr–

         push      bx
         push      si

; ------ adresa pozice konce bloku -> BX:SI

         mov       ax,word ptr es:[EdiPKBlk] ; pozice konce bloku
         mov       cx,word ptr es:[EdiPKBlk+2]
         call      EditGtPO                 ; adresa pozice konce bloku
         jc        EdiGPKB4                 ; chyba

; ------ v˜po‡et offsetu pozice konce bloku -> CX:AX

         call      EdiGetOf                 ; v˜po‡et offsetu konce bloku
                                          ;* zde se navrac¡ NC !
; ------ n vrat registr–

EdiGPKB4:pop       si
         pop       bx
         ret

EdiGtPKB ENDP

; -----------------------------------------------------------------------------
;                                RetnBlok
;                   n vrat bloku z bufferu (na pozici kurzoru)
; -----------------------------------------------------------------------------
; VSTUP: DX=segment okna
;        DI=offset definice okna
;        DS=datov˜ segment
; VSTUP: CY=chyba operace
;         ES=nov  adresa okna
; -----------------------------------------------------------------------------

RetnBlok PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      si
         push      di
         push      bp

; ------ inicializace ukazatele v bufferu

         call      InitUBuf                 ; inicializace ukazatele v bufferu

; ------ adresa okna

         call      EditGetD                 ; adresa okna
         jnc       RetnBlk1                 ; adresa okna OK
RetnBlk0:jmp       RetnBlk9                 ; CY=chyba operace

; ------ kontrola, zda je operace povolena

RetnBlk1:test      byte ptr es:[EdiParm],bit2 ; je z kaz z pisu ?
         jnz       RetnBlk0                 ; je z kaz z pisu
         test      byte ptr es:[di+EdiParm1],bit0 ; je jen zobrazen¡ ?
         jnz       RetnBlk0                 ; je jen zobrazen¡
         or        byte ptr ds:[EditPar2],bit2 ; p©¡znak - zobrazit okno

; ------ doplnˆn¡ offsetu/© dk– po kurzor

         test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je bin rn¡/HEX m¢d ?
         jz        RetnBl10                 ; je textov˜ m¢d
         or        byte ptr es:[EdiParm0],bit0+bit1 ; ukazatele neplatn‚
         call      DoplnOff                 ; doplnˆn¡ mezer/nul v m¢du BIN/HEX
         jmp       short RetnBl12
RetnBl10:call      EditGetK                 ; poskytnut¡ © dku s kurzorem->CX:AX
         call      DoplnRad                 ; doplnˆn¡ © dk– po kurzor
RetnBl11:jc        RetnBlk0                 ; chyba operace

; ------ doplnˆn¡ mezer po kurzor pro sloupcov˜ a textov˜ blok (textov˜ m¢d)

         push      es
         call      EditGetB                 ; adresa bufferu -> ES
         test      byte ptr es:[EdiParm],bit7 ; je © dkov˜ blok ?
         pop       es
         jnz       RetnBl13                 ; je © dkov˜ blok
         call      EditDopS                 ; doplnˆn¡ pozic po kurzor
RetnBl12:jc        RetnBlk0                 ; chyba operace

; ------ nastaven¡ ukazatel– bloku podle kurzoru (ni‡¡ se AX, CX, SI !)

RetnBl13:call      EditF3                   ; nastaven¡ za‡ tku bloku
         call      EditF4                   ; nastaven¡ konce bloku
         call      EditRPBl                 ; n vrat pozic bloku

; ------ adresa bufferu -> DS

         push      dx                       ; ‡¡slo okna
         push      ds                       ; datov˜ segment

         mov       ax,ds:[EditSBuf]         ; buffer
         call      far ptr GetSgAdr         ; adresa bufferu
         mov       ds,dx                    ; DS <- adresa bufferu

; ------ nastaven¡ offsetu konce bloku

         mov       ax,word ptr ds:[EdiSize] ; velikost bloku k na‡ten¡
         mov       cx,word ptr ds:[EdiSize+2]
         add       ax,word ptr es:[EdiOBBlk] ; p©epo‡et na offset v souboru
         adc       cx,word ptr es:[EdiOBBlk+2]
         mov       word ptr es:[EdiOKBlk],ax ; offset konce bloku
         mov       word ptr es:[EdiOKBlk+2],cx

; ------ © dek konce bloku

         mov       ax,word ptr ds:[EdiRKBlk] ; © dek konce bloku
         mov       cx,word ptr ds:[EdiRKBlk+2]
         push      ax
         push      cx
         add       ax,word ptr es:[EdiRBBlk] ; p©epo‡et na © dek v souboru
         adc       cx,word ptr es:[EdiRBBlk+2]
         mov       word ptr es:[EdiRKBlk],ax ; © dek konce bloku
         mov       word ptr es:[EdiRKBlk+2],cx
         pop       cx
         pop       ax

; ------ pozice konce bloku

         or        ax,cx                    ; je stejn˜ © dek ?
         mov       ax,word ptr ds:[EdiPKBlk] ; pozice konce bloku
         mov       cx,word ptr ds:[EdiPKBlk+2]
         jz        RetnBl15                 ; je to stejn˜ © dek
         test      byte ptr ds:[EdiParm],bit6 ; je to sloupcov˜ blok ?
         jz        RetnBl16                 ; nen¡ sloupcov˜ blok - pozice OK
         test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je BIN/HEX m¢d ?
         jnz       RetnBl16                 ; je BIN/HEX m¢d - textov˜ blok
RetnBl15:add       ax,word ptr es:[EdiPBBlk] ; + pozice po‡ tku bloku
         adc       cx,word ptr es:[EdiPBBlk+2]
RetnBl16:mov       word ptr es:[EdiPKBlk],ax ; pozice konce bloku
         mov       word ptr es:[EdiPKBlk+2],cx

; ------ nastaven¡ typu bloku

         mov       al,ds:[EdiParm]          ; typ navracen‚ho bloku
         and       byte ptr es:[EdiParm],not bit6+bit7 ; zru¨en¡ typu bloku
         and       al,bit6+bit7
         or        es:[EdiParm],al          ; nastaven¡ typu bloku

         pop       ds
         pop       dx

; ------ test, zda je sloupcov˜ blok

         test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je BIN/HEX m¢d ?
         jnz       RetnBl18                 ; je BIN/HEX m¢d - textov˜ blok
         test      byte ptr es:[EdiParm],bit6 ; je sloupcov˜ blok ?
         jnz       RetnBlk2                 ; je sloupcov˜ blok
RetnBl18:jmp       RetnBlk6                 ; nen¡ sloupcov˜ blok

; ====== na‡ten¡ sloupcov‚ho bloku

; ------ doplnˆn¡ © dk–, je-li za koncem souboru

RetnBlk2:mov       ax,word ptr es:[EdiRKBlk] ; © dek konce bloku
         mov       cx,word ptr es:[EdiRKBlk+2]
         call      DoplnRad                 ; doplnˆn¡ © dk–
         jc        RetnBl52                 ; chyba operace

; ------ po‡ te‡n¡ © dek sloupcov‚ho bloku

         mov       bp,word ptr es:[EdiRBBlk+2] ; © dek za‡ tku bloku HIGH
         mov       di,word ptr es:[EdiRBBlk] ; © dek za‡ tku bloku LOW

; ------ na‡ten¡ © dku BP:DI z bufferu

RetnBlk3:call      RetBlLn                  ; na‡ten¡ © dku z bufferu
         jc        RetnBl52                 ; chyba operace

; ------ posun k dal¨¡mu © dku

RetnBlk4:add       di,1                     ; zv˜¨en¡ ‡¡sla © dku
         adc       bp,0

; ------ test, zda jsou ji‘ v¨echny © dky

         cmp       bp,word ptr es:[EdiRKBlk+2] ; dosa‘eno koncov‚ho © dku ?
         jne       RetnBlk5
         cmp       di,word ptr es:[EdiRKBlk]
RetnBlk5:jbe       RetnBlk3                 ; dal¨¡ © dek
                                          ;* zde je NC !
RetnBl52:jmp       short RetnBlk8           ; byly ji‘ v¨echny © dky


; ====== na‡ten¡ © dkov‚ho a textov‚ho bloku (na pozici kurzoru)

; ------ pro BIN a HEX m¢d plat¡ adresa kurzoru

RetnBlk6:test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je BIN/HEX m¢d ?
         jnz       RetnBl62                 ; je BIN/HEX m¢d

; ------ adresa © dku za‡ tku bloku pro © dkov˜ blok -> BX:SI

         mov       bx,es:[di+EdiBKur]       ; blok s © dkem kurzoru
         mov       si,es:[di+EdiOKur]       ; offset © dku s kurzorem
         test      byte ptr es:[EdiParm],bit7 ; je © dkov˜ blok ?
         jnz       RetnBlk7                 ; je to © dkov˜ blok

; ------ adresa kurzoru jako za‡ tek bloku -> BX:SI

RetnBl62:mov       bx,es:[di+EdiBBKur]      ; blok s kurzorem
         mov       si,es:[di+EdiOfKur]      ; offset s kurzorem

; ------ po‡et bajt– k na‡ten¡ (velikost bloku) -> CX:AX

RetnBlk7:call      EditGetB                 ; adresa okna bufferu -> ES
         mov       ax,word ptr es:[EdiSize] ; velikost dat v bufferu
         mov       cx,word ptr es:[EdiSize+2]

; ------ na‡ten¡ bloku z bufferu (BX:SI=ukazatel k ulo‘en¡ dat, CX:AX=bajt–)

         call      EdiFrmB0                 ; na‡ten¡ dat z bufferu

; ------ aktualizace offset– ukazatel–

RetnBlk8:pushf
         call      EdiChPBY                 ; p©epo‡et ukazatel–

; ------ aktualizace © dku s kurzorem

         call      EditModA                 ; po‘adavek aktualizace oken
         call      EditAktW                 ; aktualizace kurzor–
         call      EditZapB                 ; zapnut¡ bloku
         popf

; ------ n vrat registr–

RetnBlk9:pop       bp
         pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

RetnBlok ENDP

; -----------------------------------------------------------------------------
;        p©epo‡et offset– ukazatel– pro okno DX/ES:DI
; -----------------------------------------------------------------------------

EdiChPBY PROC      NEAR

         push      bp
         mov       bp,offset EdiChPBX       ; aktualizace ukazatel–
         call      EdiChPBA                 ; obsluha korekc¡
         pop       bp
         ret

EdiChPBY ENDP

; -----------------------------------------------------------------------------
;        aktualizace offsetu ukazatele ES:SI
; -----------------------------------------------------------------------------

EdiChPBX PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      si
         push      bp
         mov       bp,si                    ; BP <- offset ukazatele

; ------ pro BIN a HEX m¢d nastaven¡ po‘adavku aktualizace

         test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je BIN/HEX m¢d ?
         jz        EdChPBX2                 ; nen¡ BIN/HEX m¢d
         or        byte ptr es:[EdiParm0],bit0+bit1 ; ukazatele neplatn‚
         jmp       short EdChPBX8

; ------ adresa © dku ukazatele -> BX:SI

EdChPBX2:mov       ax,es:[bp+4]             ; © dek LOW
         mov       cx,es:[bp+4+2]           ; © dek HIGH
         call      EdiGetLn                 ; nalezen¡ po‘adovan‚ho © dku->BX:SI
         jc        EdChPBX8                 ; chyba

; ------ adresa pozice ukazatele -> BX:SI

         mov       ax,es:[bp]               ; pozice LOW
         mov       cx,es:[bp+2]             ; pozice HIGH
         push      di
         call      EditGetP                 ; nalezen¡ pozice kurzoru
         xchg      ax,di                    ; AX <- p©esah kurzoru
         pop       di
         jc        EdChPBX8                 ; chyba

; ------ korekce adresy pro tabul tor

         or        ax,ax                    ; je odskok tabul toru ?
         jle       EdChPBX4                 ; nen¡ odskok tabul toru
         dec       si                       ; n vrat ukazatele na znak TAB

; ------ offset ukazatele -> CX:AX

EdChPBX4:call      EdiGetOf                 ; stanoven¡ offsetu v souboru
         mov       es:[bp+8],ax             ; offset LOW
         mov       es:[bp+8+2],cx           ; offset HIGH

; ------ n vrat registr–

EdChPBX8:pop       bp
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

EdiChPBX ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ jednoho © dku z bufferu do textu (okno ES/DX, © dek BP:DI)
; -----------------------------------------------------------------------------

RetBlLn  PROC      NEAR

; ------ £schova registr–

         push      di
         push      bp

; ------ adresa aktivn¡ho © dku -> BX:SI

         xchg      ax,di                    ; AX <- © dek LOW
         mov       cx,bp                    ; CX <- © dek HIGH
         call      EdiGetLn                 ; adresa © dku -> BX:SI
         jc        RetBlLn9                 ; chyba

; ------ doplnˆn¡ pozic po za‡ tek bloku

         mov       ax,word ptr es:[EdiPBBlk] ; pozice za‡ tku bloku
         mov       cx,word ptr es:[EdiPBBlk+2]
         call      DoplnPoz                 ; doplnˆn¡ pozic
         jc        RetBlLn9                 ; chyba

; ------ zji¨tˆn¡ d‚lky p©ipraven‚ho © dku v bufferu -> CX:AX

         call      EdiLnBf                  ; d‚lka p©ipraven‚ho © dku v bufferu
         jc        RetBlLn9                 ; chyba
         mov       di,ax                    ; DI <- d‚lka © dku LOW
         mov       bp,cx                    ; BP <- d‚lka © dku HIGH

; ------ na‡ten¡ © dku z bufferu

         call      EdiFrmBf                 ; na‡ten¡ © dku z bufferu
         jc        RetBlLn9                 ; chyba

; ------ doplnˆn¡ mezer po koncovou pozici bloku (je-li uvnit© textu !)

         add       di,word ptr es:[EdiPBBlk] ; pozice konce vlo‘en˜ch dat
         adc       bp,word ptr es:[EdiPBBlk+2]
         mov       ax,word ptr es:[EdiPKBlk] ; pozice konce bloku
         mov       cx,word ptr es:[EdiPKBlk+2]
         sub       ax,di                    ; chybˆj¡c¡ po‡et mezer
         sbb       cx,bp
         jc        RetBlLn6                 ; nechyb¡ ‘ dn‚ mezery
         jnz       RetBlLn5
         or        ax,ax
         jz        RetBlLn6                 ; nechyb¡ ‘ dn‚ mezery
RetBlLn5:call      EditISpc                 ; vlo‘en¡ mezer
         jc        RetBlLn9

; ------ o©ez n¡ mezer na konci © dku

RetBlLn6:pop       cx                       ; © dek HIGH
         pop       ax                       ; © dek LOW
         push      ax
         push      cx
         call      EdiGetLn                 ; adresa © dku -> BX:SI
         jc        RetBlLn9                 ; chyba
         call      EditLOrz                 ; o©ez n¡ mezer na konci © dku
         jc        RetBlLn9                 ; chyba

; ------ nastaven¡ na dal¨¡ © dek v bufferu

         call      EdiNxtBf                 ; nastaven¡ na dal¨¡ © dek

; ------ obnoven¡ adresy okna

RetBlLn9:call      EditGt0D                 ; nov  adresa okna

; ------ n vrat registr–

         pop       bp
         pop       di
         ret

RetBlLn  ENDP

; -----------------------------------------------------------------------------
;        ulo‘en¡ bloku souboru DX podle zad n¡ (z pis do souboru)
; -----------------------------------------------------------------------------
; lok ln¡ promˆnn‚: SS:[BP-2] (2) d‚lka jm‚na souboru
; ni‡¡ v¨echny registry kromˆ DX, BP a DS !
; -----------------------------------------------------------------------------
;þþþþþþþþþþþþþþþ
EditUlBl PROC      NEAR

; ------ test, zda je blok zapnut

         call      EditTstB                 ; test, zda je blok zapnut
         jc        EditUlB9                 ; blok nen¡ zapnut

; ------ ulo‘en¡ bloku do z sobn¡ku

         mov       si,offset EdiUkTxt       ; hl ¨en¡
         call      far ptr InfDisp0         ; hl ¨en¡ o ukl d n¡ bloku
         call      StorBlok                 ; ulo‘en¡ bloku do bufferu
         jc        EditUlB9                 ; chyba
         or        byte ptr ds:[EditPar2],bit3 ; p©¡znak zobrazen¡ v¨eho
         call      far ptr InfoClos         ; uzav©en¡ informa‡n¡ho © dku

; ------ ulo‘en¡ souboru na disk

         push      dx
         mov       dx,ds:[EditSBuf]         ; segment bufferu
         call      EditZap                  ; z pis bufferu na disk
         pop       dx
         call      EditGetD                 ; obnoven¡ adresy okna

EditUlB9:ret

EditUlBl ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ bloku ze souboru
; -----------------------------------------------------------------------------
; lok ln¡ promˆnn‚: SS:[BP-2] (2) d‚lka jm‚na souboru
;                   SS:[BP-6] (4) ukazatel ‡tec¡ adresy ze souboru
;                   SS:[BP-10] (4) ‡¡ta‡ zbyl˜ch dat ke ‡ten¡ ze souboru
;                   SS:[BP-12] (2) identifik tor vstupn¡ho souboru
; ni‡¡ v¨echny registry kromˆ DX, BP a DS !
; -----------------------------------------------------------------------------
;þþþþþþ
EditCtBl PROC      NEAR

; ------ £schova registr–

         push      bp
         mov       bp,sp
         sub       sp,FileMax+12

; ------ test, zda je operace povolena

         test      byte ptr es:[EdiParm],bit2 ; je z kaz z pisu ?
         jnz       EditCtB1                 ; je z kaz z pisu
         test      byte ptr es:[di+EdiParm1],bit0 ; je jen zobrazen¡ ?
         jz        EditCtB2                 ; je editace OK
EditCtB1:jmp       EditCtB9

; ------ zad n¡ souboru k na‡ten¡

EditCtB2:mov       si,offset SENBMLin
         call      Edi0Menu                 ; zad n¡ jm‚na souboru
         jc        EditCtB1                 ; p©eru¨en¡ operace

; ------ normalizace jm‚na souboru

         call      far ptr NormFilL         ; normalizace jm‚na souboru
         clc
         jcxz      EditCtB1                 ; nen¡ nic zad no
         call      far ptr FullFile         ; p©evod na pln‚ jm‚no souboru
         mov       ss:[bp-2],cx             ; d‚lka jm‚na souboru

; ------ £schova jm‚na souboru do bufferu v z sobn¡ku

         push      ss
         pop       es
         mov       di,sp
         inc       cx                       ; v‡etnˆ koncov‚ 0
         cld
         mov       ds:[ENFMnLP1],cl         ; d‚lka jm‚na souboru
         mov       word ptr ds:[ENFMnLP1+1],di ; offset adresy jm‚na souboru
         mov       word ptr ds:[ENFMnLP1+3],es ; segment adresy jm‚na souboru
         rep       movsb                    ; £schova jm‚na souboru do z sobn¡ku

; ------ otev©en¡ souboru pro ‡ten¡

         mov       si,sp                    ; SI <- soubor
         call      far ptr OpenR            ; otev©en¡ souboru pro ‡ten¡
         jnc       EditCtB3                 ; soubor otev©en OK

; ------ chyba - soubor nenalezen

         mov       si,offset ENFMnLin
         push      dx
         call      far ptr Lin0MenF         ; chybov‚ hl ¨en¡
         pop       dx
         jmp       short EditCtB1

; ------ p©¡prava parametr– ke ‡ten¡ souboru

EditCtB3:mov       ss:[bp-12],ax            ; identifik tor vstupn¡ho souboru
         call      far ptr SizeFile         ; zji¨tˆn¡ velikosti souboru
;         jc        EditCtB8                 ; chyba
         mov       ss:[bp-10],cx            ; velikost souboru LOW
         mov       ss:[bp-10+2],bx          ; velikost souboru HIGH
         mov       word ptr ss:[bp-6],0     ; ukazatel ‡tec¡ adresy LOW
         mov       word ptr ss:[bp-6+2],0   ; ukazatel ‡tec¡ adresy HIGH

; ------ zobrazen¡ informa‡n¡ho © dku

         call      far ptr InfoClr0         ; nulov n¡ informa‡n¡ho © dku
         mov       si,offset EdiCtTxt       ; text hl ¨en¡
         call      far ptr InfoTxt          ; dek¢dov n¡ textu
         mov       cx,ss:[bp-2]             ; d‚lka jm‚na souboru
         push      ss
         pop       es
         mov       si,sp
         call      far ptr InfoDek          ; dek¢dov n¡ jm‚na souboru
         xor       cx,cx                    ; ‡¡ta‡ kurzoru
         call      far ptr InfoKurz         ; zobrazen¡ hl ¨en¡

; ------ p©¡prava segmentu bufferu

         call      EditGetD                 ; adresa okna
         push      ax
         mov       al,es:[EdiParm]          ; parametry - typ bloku
         call      NulSBuf                  ; nulov n¡ segmentu bufferu
         pop       ax

; ------ nastaven¡ ukazatele ve vstupn¡m souboru

         xor       bx,bx                    ; ukazatel ‡¡sla bloku
         xor       si,si                    ; offset v bloku
EditCtB4:push      dx
         mov       cx,ss:[bp-6]             ; ukazatel ‡tec¡ adresy LOW
         mov       dx,ss:[bp-6+2]           ; ukazatel ‡tec¡ adresy HIGH
         call      far ptr SetUFile         ; nastaven¡ ukazatele v souboru
         pop       dx
;         jc        EditCtB8                 ; chyba

; ------ p©¡prava velikosti dat

         mov       cx,BLOKBLOK              ; velikost jednoho bloku
         cmp       word ptr ss:[bp-10+2],0  ; zbyla nˆjak  data ?
         jne       EditCtB5                 ; je je¨tˆ dost dat
         cmp       cx,ss:[bp-10]            ; je je¨tˆ dost dat ?
         jbe       EditCtB5                 ; je je¨tˆ dost dat
         mov       cx,ss:[bp-10]            ; omezen¡ velikosti dat

; ------ vytvo©en¡ m¡sta k na‡ten¡ dat

EditCtB5:jcxz      EditCtB6                 ; nejsou dal¨¡ data
         push      dx
         mov       dx,ds:[EditSBuf]         ; segment bufferu
         call      EditIns                  ; vytvo©en¡ m¡sta pro data
         pop       dx
         jc        EditCtB8                 ; chyba - m lo pamˆti

; ------ na‡ten¡ dat ze souboru

         call      far ptr ReadFile         ; na‡ten¡ dat
         jc        EditCtB8                 ; chyba
         jcxz      EditCtB8                 ; neo‡ek van˜ konec dat

; ------ posun ukazatel– dat

         sub       word ptr ss:[bp-10],cx   ; sn¡‘en¡ ‡¡ta‡e zbyl˜ch dat
         sbb       word ptr ss:[bp-10+2],0
         add       word ptr ss:[bp-6],cx    ; posun ukazatele ‡tec¡ adresy
         adc       word ptr ss:[bp-6+2],0
         call      far ptr InfoKurz         ; zobrazen¡ informa‡n¡ho kurzoru
         jmp       short EditCtB4           ; dal¨¡ data


; ------ uzav©en¡ souboru

EditCtB6:call      far ptr ClosFile         ; uzav©en¡ souboru

; ------ aktualizace ukazatel– bloku

         push      bx
         push      cx
         push      dx
         push      di
         push      bp

         mov       dx,ds:[EditSBuf]         ; segment bufferu
         call      EditGetD                 ; adresa okna
         mov       ax,word ptr es:[EdiSize] ; aktu ln¡ velikost souboru
         mov       cx,word ptr es:[EdiSize+2]
         mov       word ptr es:[EdiOKBlk],ax ; offset konce bloku
         mov       word ptr es:[EdiOKBlk+2],cx
         call      EdiGetAd                 ; nalezen¡ adresy v souboru -> BX:SI
         call      EdiBORad                 ; p©evod na © dek/pozici CX:AX/BP:DI
         mov       word ptr es:[EdiRKBlk],ax ; © dek konce bloku
         mov       word ptr es:[EdiRKBlk+2],cx
         mov       word ptr es:[EdiPKBlk],di ; pozice konce bloku
         mov       word ptr es:[EdiPKBlk+2],bp
         and       byte ptr es:[EdiParm0],not bit0+bit1 ; konec i za‡ tek zn m˜

         pop       bp
         pop       di
         pop       dx
         pop       cx
         pop       bx

; ------ na‡ten¡ bloku do souboru

         call      EditGetD                 ; adresa okna
         mov       di,EdiW1                 ; okno 1
         or        dh,dh                    ; je okno 2 ?
         jns       EdiCtB79                 ; je okno 1
         mov       di,EdiW2                 ; okno 2
EdiCtB79:call      RetnBlok                 ; n vrat bloku z bufferu
         jmp       short EditCtB9

; ------ chyba ‡ten¡ ze souboru

EditCtB8:call      far ptr ClosFile         ; uzav©en¡ souboru

; ------ n vrat registr–

EditCtB9:mov       sp,bp
         pop       bp
         call      far ptr InfoClos         ; uzav©en¡ informa‡n¡ho © dku
         ret

EditCtBl ENDP

; -----------------------------------------------------------------------------
;        Ctrl-F9 - posun © dku nahoru
; -----------------------------------------------------------------------------

EditCtF9 PROC      NEAR

         call      EditGetK                 ; poskytnut¡ © dku s kurzorem
         or        ax,cx                    ; je ji‘ © dek 0 ?
         jz        EdiCF102                 ; je ji‘ © dek 0 - nen¡ posun
         or        byte ptr ds:[EditPTmp],bit0   ; posun © dku je nahoru
         jmp       short EdiCF101

EditCtF9 ENDP

; -----------------------------------------------------------------------------
;        Ctrl-F10 - posun © dku dol–
; -----------------------------------------------------------------------------

EditCF10 PROC      NEAR

; ------ povoleno pouze pro textov˜ m¢d

         and       byte ptr ds:[EditPTmp],not bit0 ; posun © dku je dol–
EdiCF101:test      byte ptr es:[di+EdiParm1],bit0+bit1+bit2 ; zobraz./text.m¢d ?
         jnz       EdiCF102                 ; nen¡ textov˜ m¢d nebo nen¡ editace
         test      byte ptr es:[EdiParm],bit2 ; je povolena editace souboru ?
         jz        EdiCF103                 ; editace je povolena OK
EdiCF102:ret

; ------ ukon‡en¡ ozna‡ov n¡ bloku Shift-

EdiCF103:call      EdiEShft                 ; ukon‡en¡ ozna‡ov n¡ bloku

; ------ £schova p©¡znak– zapnut¡ bloku

         mov       al,es:[EdiW1+EdiParm2]   ; p©¡znak zapnut¡ bloku okna 1
         mov       ah,es:[EdiW2+EdiParm2]   ; p©¡znak zapnut¡ bloku okna 2
         push      ax                       ; £schova p©¡znak– zapnut¡ blok–

; ------ nastaven¡ © dkov‚ho typu bloku

         mov       al,es:[EdiParm]          ; sou‡asn˜ typ bloku
         and       byte ptr es:[EdiParm],not bit6+bit7
         or        byte ptr es:[EdiParm],bit7 ; je © dkov˜ blok
         push      ax                       ; £schova typu bloku

; ------ £schova sou©adnic za‡ tku a konce bloku

         push      word ptr es:[EdiPBBlk]   ; pozice za‡ tku bloku LOW
         push      word ptr es:[EdiPBBlk+2] ; pozice za‡ tku bloku HIGH
         push      word ptr es:[EdiRBBlk]   ; © dek za‡ tku bloku LOW
         push      word ptr es:[EdiRBBlk+2] ; © dek za‡ tku bloku HIGH

         push      word ptr es:[EdiPKBlk]   ; pozice konce bloku LOW
         push      word ptr es:[EdiPKBlk+2] ; pozice konce bloku HIGH
         push      word ptr es:[EdiRKBlk]   ; © dek konce bloku LOW
         push      word ptr es:[EdiRKBlk+2] ; © dek konce bloku HIGH

; ------ £schova © dku po‡ tku okna (proto‘e jej posouv  p©esun bloku)

         call      EditGetT                 ; poskytnut¡ © dku po‡ tku okna
         push      ax
         push      cx

; ------ ozna‡en¡ aktu ln¡ho © dku jako blok

         call      EditF3                   ; ozna‡en¡ za‡ tku bloku
         call      EditF4                   ; ozna‡en¡ konce bloku

; ------ posun kurzoru dol–

         test      byte ptr ds:[EditPTmp],bit0 ; je posun nahoru ?
         jnz       EdiCF104                 ; je posun nahoru
         call      EditDwnY                 ; posun kurzoru o © dek dol–
         call      EditAktW                 ; aktualizace okna
         call      EditDwnY                 ; posun kurzoru o © dek dol–
         jmp       short EdiCF105

; ------ posun kurzoru nahoru

EdiCF104:call      EditUpY                  ; posun kurzoru o © dek nahoru

; ------ p©esun bloku na nov˜ © dek

EdiCF105:call      EditAktW                 ; aktualizace okna
         call      EditF6                   ; p©esun bloku (© dku)

; ------ n vrat © dku po‡ tku okna

         pop       cx
         pop       ax
         call      EditSetT                 ; nastaven¡ © dku po‡ tku okna

; ------ n vrat sou©adnic za‡ tku a konce bloku

         pop       word ptr es:[EdiRKBlk+2] ; © dek konce bloku HIGH
         pop       word ptr es:[EdiRKBlk]   ; © dek konce bloku LOW
         pop       word ptr es:[EdiPKBlk+2] ; pozice konce bloku HIGH
         pop       word ptr es:[EdiPKBlk]   ; pozice konce bloku LOW

         pop       word ptr es:[EdiRBBlk+2] ; © dek za‡ tku bloku HIGH
         pop       word ptr es:[EdiRBBlk]   ; © dek za‡ tku bloku LOW
         pop       word ptr es:[EdiPBBlk+2] ; pozice za‡ tku bloku HIGH
         pop       word ptr es:[EdiPBBlk]   ; pozice za‡ tku bloku LOW

; ------ n vrat typu bloku

         pop       ax
         and       byte ptr es:[EdiParm],not bit6+bit7
         and       al,bit6+bit7
         or        es:[EdiParm],al          ; n vrat typu bloku

; ------ n vrat p©¡znak– zapnut¡ blok–

         pop       ax
         and       ax,bit5 + bit5*HI        ; p©¡znaky zapnut¡ blok–
         and       byte ptr es:[EdiW1+EdiParm2],not bit5 ; nulov n¡ bloku okna 1
         or        es:[EdiW1+EdiParm2],al   ; n vrat p©¡znaku bloku okna 1
         and       byte ptr es:[EdiW2+EdiParm2],not bit5 ; nulov n¡ bloku okna 2
         or        es:[EdiW2+EdiParm2],ah   ; n vrat p©¡znaku bloku okna 2

; ------ korekce ukazatel– po operaci

         push      bp
         mov       bp,offset EdiChC1A       ; aktualizace ukazatel–
         call      EdiChPBA                 ; obsluha korekc¡
         pop       bp

; ------ aktualizace offset– ukazatel–

         call      EdiChPBY                 ; aktualizace ukazatel–

; ------ aktualizace parametr– bloku (a p©¡padn‚ zapnut¡/vypnut¡ bloku)

         call      EdiAktBl                 ; aktualizace parametr– bloku
EdiCF109:ret

EditCF10 ENDP

; -----------------------------------------------------------------------------
;        korekce ukazatel– po operaci
; -----------------------------------------------------------------------------

EdiChC1A PROC      NEAR

; ------ p©¡prava © dku ukazatele -> CX:AX

         mov       ax,es:[si+4]             ; © dek ukazatele LOW
         mov       cx,es:[si+4+2]           ; © dek ukazatele HIGH

; ------ rozli¨en¡, zda byl posun nahoru nebo dol–

         test      byte ptr ds:[EditPTmp],bit0 ; byl posun nahoru ?
         jz        EdChC1A4                 ; byl posun dol–

; ------ byl posun nahoru: test, zda ukazatel je na © dku s kurzorem

         call      EdiChPBK                 ; je © dek s kurzorem ?
         je        EdChC1A7                 ; je © dek s kurzorem - odsun dol–

; ------ test, zda byl p©ed operac¡ © dek s kurzorem

         sub       ax,1                     ; posun ukazatele s kurzorem
         sbb       cx,0
         call      EditCmpK                 ; byl by © dek s kurzorem ?
         je        EdChC1A9                 ; p©¡sun ukazatele s kurzorem
         ret

; ------ byl posun dol–: test, zda ukazatel je na © dku s kurzorem

EdChC1A4:call      EdiChPBK                 ; je © dek s kurzorem ?
         je        EdChC1A9                 ; je © dek s kurzorem - odsun nahoru

; ------ test, zda byl p©ed operac¡ © dek s kurzorem

         add       ax,1                     ; posun ukazatele s kurzorem
         adc       cx,0
         call      EditCmpK                 ; byl by © dek s kurzorem ?
         jne       EdChC1A8                 ; nebyl by © dek s kurzorem

; ------ posun ukazatele dol–

EdChC1A7:add       word ptr es:[si+4],1     ; posun ukazatele o © dek dol–
         adc       word ptr es:[si+4+2],0
EdChC1A8:ret

; ------ posun ukazatele nahoru

EdChC1A9:sub       word ptr es:[si+4],1     ; posun ukazatele o © dek nahoru
         sbb       word ptr es:[si+4+2],0
         ret

EdiChC1A ENDP

; -----------------------------------------------------------------------------
;        Shift-F9 typ bloku
; -----------------------------------------------------------------------------

; ------ zmˆna textov˜ blok -> © dkov˜ blok

EditSF9: test      byte ptr es:[EdiParm],bit6+bit7 ; je textov˜ blok ?
         jnz       EditSF92                 ; nen¡ textov˜ blok
         or        byte ptr es:[EdiParm],bit7  ; © dkov˜ blok
         jmp       short EditSF94            ; zapnut¡ bloku

; ------ zmˆna © dkov˜ blok -> sloupcov˜ blok

EditSF92:xor       byte ptr es:[EdiParm],bit6+bit7 ; © dkov˜<->sloupcov˜ blok
         test      byte ptr es:[EdiParm],bit7 ; byl © dkov˜ blok ?
         jz        EditSF94                 ; byl © dkov˜ blok - je sloupcov˜

; ------ zmˆna sloupcov˜ blok -> textov˜ blok

         and       byte ptr es:[EdiParm],not bit6+bit7 ; textov˜ blok

; ------ zapnut¡ bloku

EditSF94:or        byte ptr ds:[EditPar2],bit3 ; p©¡znak zobrazen¡ v¨eho
         call      EdiAktBl                 ; aktualizace parametr– bloku
         jmp       short EditF92            ; zapnut¡ bloku

; -----------------------------------------------------------------------------
;        F9 zobrazen¡ bloku
; -----------------------------------------------------------------------------

EditF9:  test      byte ptr es:[EdiW1+EdiParm2],bit5 ; je blok v oknˆ 1 ?
         jnz       EditF91                  ; je blok v oknˆ 1
         test      byte ptr es:[EdiW2+EdiParm2],bit5 ; je blok v oknˆ 2 ?
         jz        EditF92                  ; blok nen¡ ani v oknˆ 2
EditF91: and       byte ptr es:[EdiW1+EdiParm2],not bit5 ; vypnut¡ bloku v oknˆ 1
         and       byte ptr es:[EdiW2+EdiParm2],not bit5 ; vypnut¡ bloku v oknˆ 2
         or        byte ptr ds:[EditPar2],bit3 ; p©¡znak zobrazen¡ v¨eho
         ret

EditF92: jmp       EditZapB                 ; zapnut¡ bloku v oknˆ DX

; -----------------------------------------------------------------------------
;        ukon‡en¡ ozna‡ov n¡ bloku SHIFT- (okno DX/ES)
; -----------------------------------------------------------------------------

EdiEShft PROC      NEAR

         pushf
         and       byte ptr es:[EdiParm0],not bit4+bit5 ; ukon‡en¡ ozna‡ov n¡
         popf
         ret

EdiEShft ENDP

; -----------------------------------------------------------------------------
;        zah jen¡ ozna‡ov n¡ bloku SHIFT- (okno DX/ES:DI)
; -----------------------------------------------------------------------------

; ------ zah jen¡ ozna‡ov n¡ pomoc¡ prav‚ho tla‡¡tka my¨i

EdiBShf0:pushf
         push      ax
         push      cx
         push      si
         jmp       short EdiBShf2

EdiBShft PROC      NEAR

; ------ £schova registr–

         pushf
         push      ax
         push      cx
         push      si

; ------ povoleno jen pro aktivn¡ okno

         cmp       dx,ds:[EdiSAkt]          ; je to aktivn¡ okno ?
         jne       EdiBShf9                 ; nen¡ to aktivn¡ okno

; ------ test, zda je SHIFT-

         test      byte ptr ds:[Presmyk],bit4 ; je SHIFT- ?
         jnz       EdiBShf2                 ; je SHIFT-
         test      byte ptr ds:[MouseKey],bit1 ; je prav‚ tla‡¡tko my¨i ?
         jnz       EdiBShf9                 ; je prav‚ tla‡¡tko - neukon‡uje se
         call      EdiEShft                 ; ukon‡en¡ ozna‡ov n¡ bloku se SHIFT-
         jmp       short EdiBShf9

; ------ zah jen¡ ozna‡ov n¡ bloku

EdiBShf2:test      byte ptr es:[EdiParm0],bit4 ; je ozna‡ov n¡ ?
         jnz       EdiBShf9                 ; ozna‡ov n¡ je ji‘ zah jeno
         test      byte ptr es:[di+EdiParm1],bit0 ; je jen zobrazen¡ ?
         jnz       EdiBShf9                 ; je jen zobrazen¡
         or        byte ptr es:[EdiParm0],bit4 ; zah jen¡ ozna‡ov n¡
         and       byte ptr es:[EdiParm0],not bit5 ; nen¡ pevn˜ konec
         call      EditF3                   ; ozna‡en¡ za‡ tku bloku
         call      EditF4                   ; ozna‡en¡ konce bloku

; ------ n vrat registr–

EdiBShf9:pop       si
         pop       cx
         pop       ax
         popf
         ret

EdiBShft ENDP

; -----------------------------------------------------------------------------
;        obsluha ozna‡en¡ bloku SHIFT- (okno DX)
; -----------------------------------------------------------------------------

EdiShift PROC      NEAR

; ------ £schova registr–

         pushf
         push      ax
         push      cx
         push      si
         push      di
         push      es

; ------ p©¡prava adresy definice okna -> ES:DI

         mov       di,EdiW1                 ; definice pro okno 1
         or        dx,dx                    ; je aktivn¡ okno 2 ?
         jns       EdiShft1                 ; je aktivn¡ okno 1
         mov       di,EdiW2                 ; definice pro okno 2
EdiShft1:call      EditGetD                 ; poskytnut¡ adresy okna -> ES

; ------ test, zda je zah jeno ozna‡ov n¡ bloku

         test      byte ptr ds:[MouseKey],bit1 ; je prav‚ tla‡¡tko my¨i ?
         jnz       EdiShf12                 ; je prav‚ tla‡¡tko my¨i
         test      byte ptr ds:[Presmyk],bit4 ; je p©esmyka‡ SHIFT- ?
         jz        EdiShft9                 ; nen¡ SHIFT-
EdiShf12:test      byte ptr es:[EdiParm0],bit4 ; je ozna‡ov n¡ ?
         jz        EdiShft9                 ; nen¡ ozna‡ov n¡ bloku

; ------ n vrat pozic, jsou-li zamˆnˆny

         call      EditRPBl                 ; n vrat pozic bloku

; ------ nastaven¡ voln‚ho konce podle kurzoru

         test      byte ptr es:[EdiParm0],bit5 ; je pevn˜ konec ?
         jnz       EdiShft2                 ; je pevn˜ konec bloku
         call      EditF4                   ; nastaven¡ konce bloku
         jmp       short EdiShft3
EdiShft2:call      EditF3                   ; nastaven¡ za‡ tku bloku

; ------ porovn n¡ © dk– pro textov˜ m¢d

EdiShft3:test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je textov˜ m¢d ?
         jnz       EdiShft5                 ; nen¡ textov˜ m¢d
         mov       si,EdiRBBlk              ; © dky
         call      EditZpUB                 ; porovn n¡ © dk– za‡ tku a konce
         jb        EdiShft9                 ; za‡ tek je p©ed koncem OK
         ja        EdiShft6                 ; za‡ tek je za koncem - z mˆna

; ------ porovn n¡ offset– pro bin rn¡ m¢d (a pro shodn‚ © dky v text. m¢du)

EdiShft5:mov       si,EdiOBBlk              ; offset
         call      EditZpUB                 ; porovn n¡ offset– za‡ tku a konce
         jbe       EdiShft9                 ; za‡ tek nen¡ za koncem bloku

; ------ z mˆna za‡ tku a konce bloku

EdiShft6:call      EditRPBl                 ; n vrat pozic bloku
         mov       si,EdiPBBlk              ; za‡ tek bloku
         mov       cx,(EdiPKBlk-EdiPBBlk)/2 ; velikost popisova‡e (slov)
EdiShft7:mov       ax,es:[si]
         xchg      ax,word ptr es:[si+EdiPKBlk-EdiPBBlk]
         mov       es:[si],ax
         inc       si
         inc       si
         loop      EdiShft7

; ------ z mˆna p©¡znaku platnosti

         mov       al,es:[EdiParm0]
         and       byte ptr es:[EdiParm0],not bit0+bit1
         mov       ah,al
         and       ax,bit0*HI + bit1
         shl       ah,1
         shr       al,1
         or        al,ah
         or        byte ptr es:[EdiParm0],al
         xor       byte ptr es:[EdiParm0],bit5 ; zmˆna p©¡znaku pevn‚ho konce

; ------ nov˜ pokus o zapnut¡ bloku

         call      EditZapB                 ; nov˜ pokus o zapnut¡ bloku

; ------ n vrat registr–

EdiShft9:pop       es
         pop       di
         pop       si
         pop       cx
         pop       ax
         popf
         ret

EdiShift ENDP

; -----------------------------------------------------------------------------
;        aktualizace ukazatel– bloku okna DX (-> CY=chyba, ES=nov  adresa okna)
; -----------------------------------------------------------------------------

EdiAktBl PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp

; ------ adresa okna -> ES:DI

         call      EditGetD                 ; poskytnut¡ adresy okna -> ES
         call      EditRPBl                 ; n vrat pozic bloku
         mov       di,EdiW1                 ; definice pro okno 1
         or        dh,dh                    ; je aktivn¡ okno 2 ?
         jns       EdiAktB1                 ; je aktivn¡ okno 1
         mov       di,EdiW2                 ; definice pro okno 2

; ------ nalezen¡ okna v textov‚m m¢du

EdiAktB1:test      byte ptr es:[di+EdiParm1],bit1+bit2 ; aktivn¡ okno v text. m¢du ?
         jz        EdiAktB2                 ; aktivn¡ okno v textov‚m m¢du
         xor       dh,bit15/bit8            ; neaktivn¡ okno
         xor       di,EdiW1 XOR EdiW2       ; p©epnut¡ na neaktivn¡ okno
         test      byte ptr es:[di+EdiParm1],bit1+bit2 ; neaktivn¡ okno v text. m¢du ?
         jnz       EdiAktB6                 ; nenalezeno okno v text. m¢du

; ------ test, zda je toto okno zobrazeno

EdiAktB2:cmp       dx,ds:[EdiSAkt]          ; je to aktivn¡ okno ?
         je        EdiAktB3                 ; je to aktivn¡ okno OK
         cmp       dx,ds:[EdiSNAkt]         ; je to neaktivn¡ okno ?
         jne       EdiAktB6                 ; nen¡ to ani neaktivn¡ okno
         test      byte ptr ds:[EditPar2],bit4 ; jsou 2 okna ?
         jz        EdiAktB6                 ; neaktivn¡ okno nen¡ zobrazeno

; ------ aktualizace za‡ tku bloku

EdiAktB3:test      byte ptr es:[EdiParm0],bit0 ; je za‡ tek bloku zn m˜ ?
         jz        EdiAktB4                 ; za‡ tek bloku je zn m˜
         mov       ax,word ptr es:[EdiOBBlk] ; offset za‡ tku bloku v souboru
         mov       cx,word ptr es:[EdiOBBlk+2]
         call      EdiGetAd                 ; nalezen¡ adresy v souboru -> BX:SI
         call      EdiBORad                 ; p©evod na © dek/pozici CX:AX/BP:DI
         jc        EdiAktB9                 ; chyba
         mov       word ptr es:[EdiRBBlk],ax ; © dek za‡ tku bloku
         mov       word ptr es:[EdiRBBlk+2],cx
         mov       word ptr es:[EdiPBBlk],di ; pozice za‡ tku bloku
         mov       word ptr es:[EdiPBBlk+2],bp
         and       byte ptr es:[EdiParm0],not bit0 ; za‡ tek bloku je zn m˜ OK

; ------ aktualizace konce bloku

EdiAktB4:test      byte ptr es:[EdiParm0],bit1 ; je konec bloku zn m˜ ?
         jz        EdiAktB6                 ; konec bloku je zn m˜
         mov       ax,word ptr es:[EdiOKBlk] ; offset konce bloku v souboru
         mov       cx,word ptr es:[EdiOKBlk+2]
         call      EdiGetAd                 ; nalezen¡ adresy v souboru -> BX:SI
         call      EdiBORad                 ; p©evod na © dek/pozici CX:AX/BP:DI
         jc        EdiAktB9                 ; chyba
         mov       word ptr es:[EdiRKBlk],ax ; © dek konce bloku
         mov       word ptr es:[EdiRKBlk+2],cx
         mov       word ptr es:[EdiPKBlk],di ; pozice konce bloku
         mov       word ptr es:[EdiPKBlk+2],bp
         and       byte ptr es:[EdiParm0],not bit1 ; konec bloku je zn m˜ OK

; ------ zapnut¡ bloku (v obou oknech)

EdiAktB6:test      byte ptr es:[EdiW1+EdiParm2],bit5 ; je blok v oknˆ 1 ?
         jnz       EdiAktB7                 ; je blok v oknˆ 1
         test      byte ptr es:[EdiW2+EdiParm2],bit5 ; je blok v oknˆ 2 ?
         jz        EdiAktB8                 ; blok nen¡ zapnut
EdiAktB7:call      EditZapB                 ; zapnut¡ bloku v oknech
EdiAktB8:clc                                ; p©¡znak operace OK

; ------ n vrat registr–

EdiAktB9:pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

EdiAktBl ENDP

; -----------------------------------------------------------------------------
;        test bloku okna ES:DI, je-li zapnut˜ -> CY=blok nen¡ zapnut
; -----------------------------------------------------------------------------

EditTstB PROC      NEAR

         test      byte ptr es:[di+EdiParm2],bit5 ; je blok zapnut ?
         jnz       EditTsB2                 ; blok je zapnut OK
         stc                                ; p©¡znak, ‘e blok nen¡ zapnut
EditTsB2:ret

EditTstB ENDP

; -----------------------------------------------------------------------------
;        zapnut¡ bloku (okno DX, segment ES)
; -----------------------------------------------------------------------------

EditZapB PROC      NEAR

; ------ n vrat pozic bloku, jsou-li zamˆnˆny

         call      EditRPBl                 ; n vrat pozic bloku
         and       byte ptr es:[EdiParm0],not bit3 ; nen¡ pot©ebn  z mˆna pozic

; ------ zapnut¡ bloku v obou oknech souboru DX

         xor       dh,bit15/bit8            ; p©epnut¡ na druh‚ okno
         call      EditZpB0                 ; zapnut¡ bloku v druh‚m oknˆ
         xor       dh,bit15/bit8            ; p©epnut¡ zpˆt na prvn¡ okno

; ------ £schova registr–

EditZpB0:push      ax
         push      si
         push      di

; ------ definice aktivn¡ho okna -> DI

         or        byte ptr ds:[EditPar2],bit2 ; p©¡znak - zobrazit okno
         mov       di,EdiW1                 ; definice pro okno 1
         or        dh,dh                    ; je aktivn¡ okno 2 ?
         jns       EditZpB2                 ; je aktivn¡ okno 1
         mov       di,EdiW2                 ; definice pro okno 2
EditZpB2:and       byte ptr es:[di+EdiParm2],not bit5 ; blok nen¡ zapnut

; ------ porovn n¡ ukazatel– pro BIN a HEX m¢d

         test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je BIN/HEX m¢d ?
         jz        EditZpB3                 ; je textov˜ m¢d
         mov       si,EdiOBBlk              ; offset za‡ tku bloku
         call      EditZpUB                 ; porovn n¡ offset– bloku
         jb        EditZpB7                 ; za‡ tek je p©ed koncem OK
         jmp       short EditZpB8           ; jinak je blok vypnut

; ------ porovn n¡ © dk–

EditZpB3:mov       si,EdiRBBlk              ; © dek blok–
         call      EditZpUB                 ; porovn n¡ © dk–
         ja        EditZpB8                 ; po‡ te‡n¡ © dek za koncov˜m-chyba
         jb        EditZpB4                 ; po‡ te‡n¡ © dek p©ed koncov˜m

; ------ © dky shodn‚ - pro © dkov˜ blok je to OK, jinak test pozic

         test      byte ptr es:[EdiParm],bit7 ; je © dkov˜ blok ?
         jnz       EditZpB7                 ; je © dkov˜ blok - © dky vyhovuj¡
         jmp       short EditZpB6           ; jinak porovn n¡ pozic

; ------ po‡ te‡n¡ © dek p©ed koncov˜m - test, zda je pot©eba testovat pozici

EditZpB4:test      byte ptr es:[EdiParm],bit6 ; je sloupcov˜ blok ?
         jz        EditZpB7                 ; nen¡ sloupcov˜, na pozici nez le‘¡

; ------ porovn n¡ pozic

EditZpB6:mov       si,EdiPBBlk              ; pozice blok–
         call      EditZpUB                 ; porovn n¡ pozic
         jb        EditZpB7                 ; pozice jsou OK
         je        EditZpB8                 ; pozice jsou shodn‚ - nen¡ blok
         or        byte ptr es:[EdiParm0],bit3 ; je pot©ebn  z mˆna pozic
         call      EditZPBl                 ; z mˆna pozic bloku

; ------ zapnut¡ bloku

EditZpB7:or        byte ptr es:[di+EdiParm2],bit5 ; p©¡znak zapnut¡ bloku

; ------ n vrat registr–

EditZpB8:pop       di
         pop       si
         pop       ax
         ret

EditZapB ENDP

; ------ porovn n¡ ukazatele ES:SI (za‡ tek s koncem bloku) (vol no z EdiShift)

EditZpUB:mov       ax,es:[si+2]             ; za‡ tek HIGH
         cmp       ax,word ptr es:[si+2+EdiPKBlk-EdiPBBlk] ; konec HIGH
         jne       EdiZpUB2
         mov       ax,es:[si]               ; za‡ tek LOW
         cmp       ax,word ptr es:[si+EdiPKBlk-EdiPBBlk] ; konec LOW
EdiZpUB2:ret

; -----------------------------------------------------------------------------
;        z mˆna pozic bloku aktivn¡ho okna ES, je-li pot©ebn  (uchov v  p©¡znaky)
; -----------------------------------------------------------------------------

EditZPBl PROC      NEAR

         pushf
         push      ax

         mov       al,es:[EdiParm0]         ; parametry
         and       al,bit2+bit3             ; p©¡znaky
         cmp       al,bit3                  ; nutn  z mˆna + nen¡ z mˆna ?
         je        EditRPB1                 ; nutn  z mˆna + nen¡ z mˆna
         jmp       short EditRPB2           ; jinak nen¡ z mˆna

EditZPBl ENDP

; -----------------------------------------------------------------------------
;        nepodm¡nˆn  z mˆna pozic bloku okna ES
; -----------------------------------------------------------------------------

EditNPBl PROC      NEAR

         pushf
         push      ax
         jmp       short EditRPB1           ; z mˆna pozic bloku

EditNPBl ENDP

; -----------------------------------------------------------------------------
;        n vrat pozic bloku aktivn¡ho okna ES, jsou-li zamˆnˆny (uchov v  p©¡znaky)
; -----------------------------------------------------------------------------

EditRPBl PROC      NEAR

         pushf
         push      ax

         test      byte ptr es:[EdiParm0],bit2 ; jsou pozice zamˆnˆny ?
         jz        EditRPB2                 ; pozice nejsou zamˆnˆny

EditRPB1:mov       ax,word ptr es:[EdiPBBlk] ; pozice za‡ tku bloku LOW
         xchg      ax,word ptr es:[EdiPKBlk] ; pozice konce bloku LOW
         mov       word ptr es:[EdiPBBlk],ax

         mov       ax,word ptr es:[EdiPBBlk+2] ; pozice za‡ tku bloku HIGH
         xchg      ax,word ptr es:[EdiPKBlk+2] ; pozice konce bloku HIGH
         mov       word ptr es:[EdiPBBlk+2],ax

         xor       byte ptr es:[EdiParm0],bit2 ; zmˆna p©¡znaku z mˆny

EditRPB2:pop       ax
         popf
         ret

EditRPBl ENDP

CodeEdi  ENDS

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
; Origin ln¡ syntaxe regul rn¡ho v˜razu (pro hled n¡):
; ---------------------------------------------------
;   Vzorek:    buƒ samostatn˜ znak "a" a‘ "z", "A" a‘ "Z", "0" a‘ "9" nebo
;              v˜raz uzav©en˜ do slo‘en˜ch z vorek {v˜raz}.
;   V˜raz:     skupina vzork– navz jem spojen˜ch pomoc¡ oper tor–.
;   Oper tory: ^ ......... za‡ tek © dku nebo po‡ te‡n¡ pozice sloupcov‚ho bloku
;              $ ......... konec © dku nebo koncov  pozice sloupcov‚ho bloku
;              . ......... libovoln˜ znak
;              ? ......... voliteln˜ vzorek - vzorek uveden˜ p©ed znakem "?" se
;                          m–‘e nebo nemus¡ vyskytovat v ©etˆzci
;              | ......... alternativn¡ oper tor - povolen jeden ze vzork–
;                          uveden˜ch na stran ch znaku "|" (lze z©etˆzit)
;              * ......... m–‘e nebo nemus¡ se vyskytovat jeden nebo v¡ce
;                          vzork– uveden˜ch p©ed znakem "*" (minim ln¡ ©etˆzec)
;              + ......... mus¡ se vyskytovat jeden nebo v¡ce vzork– uveden˜ch
;                          p©ed znakem "+" (minim ln¡ ©etˆzec)
;              @ ......... m–‘e nebo nemus¡ se vyskytovat jeden nebo v¡ce
;                          vzork– uveden˜ch p©ed znakem "@" (maxim ln¡ ©etˆzec)
;              # ......... mus¡ se vyskytovat jeden nebo v¡ce vzork– uveden˜ch
;                          p©ed znakem "#" (maxim ln¡ ©etˆzec)
;              [seznam] .. seznam znak– povolen˜ch na t‚to pozici
;                          (rozli¨uj¡ se velk /mal  p¡smena nez visle na "U")
;                             v˜‡et ....... znaky uvedeny jednodu¨e za sebou
;                             interval .... uvede se prvn¡ a posledn¡ znak
;                                           navz jem oddˆlen‚ znakem "-"
;                                           (na konci nebo za‡ tku seznamu
;                                           se pova‘uje za platn˜ znak)
;                             doplnˆk ..... uveden¡m znaku ~ za levou z vorkou [
;                                           se pou‘ije doplnˆk seznamu znak–
;              {v˜raz} ... v˜raz slo‘en˜ z v˜pln¡ pomoc¡ oper tor–, pou‘ije se
;                          jako jedna v˜pl¤ ve v˜razech (=vno©ov n¡ v˜raz–);
;                          slou‘¡ t‚‘ k ozna‡ov n¡ "c¡lov‚ho" ©etˆzce k n hradˆ
;              \ ......... n sleduj¡c¡ znak bude pova‘ov n za platn˜ znak a ne
;                          za oper tor regul rn¡ho v˜razu; t‚‘ speci ln¡ znaky:
;                              \a ...... BEEP (znak 7)
;                              \b ...... BACK SPACE (znak 8)
;                              \t ...... TAB (znak 9)
;                              \n ...... NEW LINE (znak 10)
;                              \v ...... VERTICAL TAB (znak 11)
;                              \f ...... FORM FEED (znak 12)
;                              \r ...... RETURN (znak 13)
;                              \xHH .... znak zad n hexadecim lnˆ HH
;
; V ©etˆzci pro n hradu:
; ---------------------
;              \‡¡slo .... je nahrazen nalezen˜m v˜razem odpov¡daj¡c¡m v˜razu
;                          uveden‚mu v {}, ‡¡slo odpov¡d  po©adov‚mu ‡¡slu {}
;                          (nap©.
;                                "{.*}"       .... hled n¡
;                                '\1'         .... n hrada
;                          - nahrad¡ v¨echny uvozovky "" uvozovkami ''
;
;                      {[a-zA-Z]#} +{[a-zA-Z]#}      .... hled n¡
;                               \2 and \1            .... n hrada
;                          - zamˆn¡ dvˆ slova z p¡smen a vlo‘¡ slovo "and"
;              \0 ........ odpov¡d  cel‚mu nalezen‚mu ©etˆzci
;              \\ ........ odpov¡d  platn‚mu znaku "\"
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
; Upraven  syntaxe regul rn¡ch v˜raz–:
; -----------------------------------
;   Vzorek:    buƒ samostatn˜ znak (znaky pro ozna‡ov n¡ soubor– v DOS, tj.
;                                   v¨echny znaky kromˆ "<", ">", "[", "]", "+",
;                                   dvojit‚ uvozovky ", ";", "=", "?", "|", "*",
;                                   "/", ","  a ©¡dic¡ch znak– < 32)
;              nebo v˜raz uzav©en˜ do z vorek [v˜raz].
;   V˜raz:     skupina vzork– navz jem spojen˜ch pomoc¡ oper tor–.
;   Oper tory: "znak ..... znak bude pova‘ov n za platn˜ znak (a ne oper tor)
;              ? ......... libovoln˜ znak
;              * ......... libovoln  skupinka znak– (0 nebo v¡ce)
;              =‡¡slo .... zad n po‘adovan˜ po‡et opakov n¡ p©ede¨l‚ v˜plnˆ
;                          (p©i v¡cen sobn‚m zad n¡ se slu‡uje jako "nebo")
;              <‡¡slo .... maxim ln¡ po‡et opakov n¡ p©ede¨l‚ v˜plnˆ
;              >‡¡slo .... minim ln¡ po‡et opakov n¡ p©ede¨l‚ v˜plnˆ
;              <min>max .. zad n interval po‘adovan‚ho po‡tu opakov n¡ p©ede¨l‚
;                          v˜plnˆ (p©i v¡cen sob. zad n¡ se slu‡uje jako "nebo")
;              [v˜raz] ... v˜raz slo‘en˜ z v˜pln¡ pomoc¡ oper tor–, pou‘ije se
;                          jako jedna v˜pl¤ ve v˜razech (=vno©ov n¡ v˜raz–);
;                          slou‘¡ t‚‘ k ozna‡ov n¡ "c¡lov‚ho" ©etˆzce k n hradˆ
;              [;seznam] . seznam znak– povolen˜ch na t‚to pozici
;                     v˜‡et ..... jednoduch˜ v˜‡et povolen˜ch znak–
;                     min<max ... interval seznamu znak– (min. a‘ max. znak)
;                     min>max ... doplnˆk intervalu seznamu znak– (max. a‘ min.)
;                     =znak ..... n sleduj¡c¡ znak nen¡ povolen
;              [=‡¡slo] .. mus¡ odpov¡dat v˜razu [] se zadan˜m po©adov˜m ‡¡slem
;              | ......... alternativn¡ oper tor - povolen jeden ze vzork–
;                          uveden˜ch na stran ch znaku "|" (lze z©etˆzit)
;              +znak ..... speci ln¡ znak
;                              +l ....... p©elom © dku (LF nebo CRLF nebo LFCR)
;                              +p ....... znak BEEP (7)
;                              +k ....... znak BS (8)
;                              +t ....... tabul tor (9)
;                              +n ....... znak LF (10)
;                              +v ....... znak VERTICAL TAB (11)
;                              +m ....... znak FORM FEED (12)
;                              +r ....... znak CR (13)
;                              +o ....... znak EOF (26)
;                              +s ....... znak ESCAPE (27)
;                              +HH ...... znak zad n HEX ‡¡slem (2 znaky
;                                         (0 a‘ 9 a A a‘ F)
; -----------------------------------------------------------------------------



;TextFndN dw        0                        ; d‚lka hledan‚ho textu
;TextFnd0 db        0                        ; d‚lka textu pro zobrazen¡ hl ¨en¡
;TextFnd  label     byte
;         db        TextFndX dup(0)          ; buffer hledan‚ho textu
;
;TextSubN dw        0                        ; d‚lka n hradn¡ho textu
;TextSub0 db        0                        ; d‚lka textu pro zobrazen¡ hl ¨en¡
;TextSub  label     byte
;         db        TextSubX dup(0)          ; buffer n hradn¡ho textu

;EdiHledP db        0                        ; parametry pro hled n¡
;                                            ;    bit 0: 1=hled n¡ zpˆt "B"
;                                            ;    bit 1: 1=nerozli¨uje velk /mal  "U"
;                                            ;    bit 2: 1=cel˜ soubor (nebo blok) "G"
;                                            ;    bit 3: 1=ozna‡en˜ blok "L"
;                                            ;    bit 4: 1=jen cel  slova "W"
;                                            ;    bit 5: 1=v¨echny bez dotazu "N"
;                                            ;    bit 6: 1=je n hrada textu
;                                            ;    bit 7: 1=otazn¡k platn˜ znak

;EdiHldP2 db        0                        ; parametry pro hled n¡ 2
;                                            ;    bit 0: 1=pokra‡ov n¡ v hled n¡
;                                            ;    bit 1: 1=v ©etˆzci je otazn¡k
;                                            ;    bit 2: 1=zad n¡ dat v HEX tvaru
;                                            ;    bit 3: 1=hled  se zna‡ka
;                                            ;    bit 4: 1=sloupcov˜ blok
;                                            ;    bit 6: 1=v¨echny dal¨¡ bez dotazu
;                                            ;    bit 7: 1=nalezen ©etˆzec

;EdiHlKod db        0                        ; k¢d souboru pro hled n¡ a modifikaci
;                                            ;         0 = implicitn¡
;                                            ;         1 = ASCII
;                                            ;         2 = IBM
;                                            ;         3 = Kamenick˜ch
;                                            ;         4 = Latin 2
;                                            ;         5 = KOI 8
;                                            ;         6 = WINDOWS

;EdiMdKod db        1                        ; k¢d pro modifikaci bloku
;                                            ;    1 = ASCII
;                                            ;    2 = IBM
;                                            ;    3 = Kamenick˜ch
;                                            ;    4 = Latin 2
;                                            ;    5 = KOI 8
;                                            ;    6 = WINDOWS

EdiHledR dd        0                        ; ukazatel © dku v sloupcov‚m bloku

;EdiHleBB dw        0                        ; blok za‡ tku hled n¡
;EdiHleBO dw        0                        ; offset za‡ tku hled n¡
EdiHledN dd        0                        ; ‡¡ta‡ zbyl˜ch bajt– k hled n¡

EdiHledB dw        0                        ; blok ukazatele hled n¡
EdiHledO dw        0                        ; offset ukazatele hled n¡

EdiHledC dd        0                        ; ‡¡ta‡ p©esko‡en¡ ©etˆzc–

EdiZnTxt db        1,'þ',9 dup(0)           ; zna‡ka pro hled n¡ (max. 10 znak–)

; -----------------------------------------------------------------------------
;    menu zad n¡ textu k hled n¡ v ASCII tvaru (pou‘ito i pro diskov˜ editor !)
; -----------------------------------------------------------------------------

EdiHMLin label     byte
         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        4                        ; po‡et platn˜ch polo‘ek menu
         dw        6                        ; celkov˜ po‡et polo‘ek menu

         dw        EdiHMPol                 ; za‡ tek definice polo‘ek menu
         dw        EdiHMHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@PodmenuEditoruKurzor ; ‡¡slo str nky velk‚ n povˆdy
         dw        EdiHMBlk                 ; adresa blokovac¡ tabulky
         dw        EdiHMSwc                 ; adresa tabulky p©ep¡na‡–
         dw        EdiHMTit                 ; adresa titulu okna
         dw        EdiHMExe                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        20                       ; po‡ te‡n¡ pozice okna
         db        0                        ; po‡ te‡n¡ © dek okna
         db        48                       ; ¨¡©ka okna
         db        8                        ; v˜¨ka okna

         dw        TextFndX                 ; maxim ln¡ d‚lka textu © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        1                        ; celkov˜ po‡et © dk–
         dw        1                        ; po‡et zobrazen˜ch © dk–

         db        bit2                     ; maska zad van˜ch znak– - v¨echny
         db        0,'      '               ; zak zan‚ znaky

         db        HistFind                 ; historie hled n¡
EdiHPrN  db        1                        ; po‡et p©edvoleb

EdiHPrPN dw        0                        ; d‚lka p©edvolby
         dd        EdiHPrTx                 ; adresa p©edvolby

EdiHPrTx db        3*16 dup(" ")            ; buffer p©edvolby hled n¡

; ------ polo‘ky voleb

EdiHMPol db        bit6,17,'Text k vyhled n¡:'
         db        0,0
         db        bit6+bit7,0
         db        1,4,'D le'
EdiHMPl2 db        bit7+1,9,'Otazn¡k -'
         db        1,6,'N vrat'

EdiHMBlk db        0,0,0,0                  ; blokovac¡ tabulka
EdiHMSwc db        0

EdiHMTit db        6,'hledej'

; ------ n povˆda

HelpS    SEGMENT   BYTE PUBLIC
EdiHMHlp db        75,'Zadejte textov˜ ©etˆzec k vyhled n¡ (?=na pozici m–‘e b˜t libovoln˜ znak)'
         db        33,'Pokra‡ov n¡ v operaci vyhled v n¡'
         db        64,'Otazn¡k je jako platn˜ znak (jinak ? nahrazuje libovoln˜ znak)'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

EdiHMExe label     dword                    ; adresy obsluh
         dd        Lin0MenR                 ; © dky
         dd        Lin0MenR                 ; hledej
         dd        EditF7O                  ; otazn¡k
         dd        Lin0MenR                 ; n vrat

; -----------------------------------------------------------------------------
;     menu zad n¡ textu k hled n¡ v HEX tvaru (pou‘ito i pro diskov˜ editor !)
; -----------------------------------------------------------------------------

EdiHHLin label     byte
         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        3                        ; po‡et platn˜ch polo‘ek menu
         dw        5                        ; celkov˜ po‡et polo‘ek menu

         dw        EdiHHPol                 ; za‡ tek definice polo‘ek menu
         dw        EdiHHHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@PodmenuEditoruKurzor ; ‡¡slo str nky velk‚ n povˆdy
         dw        EdiHHBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        EdiHMTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        20                       ; po‡ te‡n¡ pozice okna
         db        0                        ; po‡ te‡n¡ © dek okna
         db        48                       ; ¨¡©ka okna
         db        8                        ; v˜¨ka okna

         dw        TextFndX                 ; maxim ln¡ d‚lka textu © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        1                        ; celkov˜ po‡et © dk–
         dw        1                        ; po‡et zobrazen˜ch © dk–

         db        bit5                     ; maska zad van˜ch znak– - HEX znaky
         db        0,'      '               ; zak zan‚ znaky

         db        HistFind                 ; historie hled n¡
EdiHHPN  db        1                        ; po‡et p©edvoleb

EdiHHPPN dw        0                        ; d‚lka p©edvolby
         dd        EdiHPrTx                 ; adresa p©edvolby

; ------ polo‘ky voleb

EdiHHPol db        bit6,31,'Data v ',0,'HEX',0,' tvaru k vyhled n¡:'
         db        0,0
         db        bit6+bit7,0
         db        1,4,'D le'
         db        1,6,'N vrat'

EdiHHBlk db        0,0,0                    ; blokovac¡ tabulka

; ------ n povˆda

HelpS    SEGMENT   BYTE PUBLIC
EdiHHHlp db        68,'Zadejte data k vyhled n¡ v HEX tvaru (jako bajty po 2 znac¡ch HEX)'
         db        33,'Pokra‡ov n¡ v operaci vyhled v n¡'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

; -----------------------------------------------------------------------------
;        menu zad n¡ n hradn¡ho textu
; -----------------------------------------------------------------------------

EdiNMLin label     byte
         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        3                        ; po‡et platn˜ch polo‘ek menu
         dw        5                        ; celkov˜ po‡et polo‘ek menu

         dw        EdiNMPol                 ; za‡ tek definice polo‘ek menu
         dw        EdiNMHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@PodmenuEditoruKurzor ; ‡¡slo str nky velk‚ n povˆdy
         dw        EdiNMBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        EdiNMTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        20                       ; po‡ te‡n¡ pozice okna
         db        0                        ; po‡ te‡n¡ © dek okna
         db        46                       ; ¨¡©ka okna
         db        8                        ; v˜¨ka okna

         dw        TextSubX                 ; maxim ln¡ d‚lka textu © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        1                        ; celkov˜ po‡et © dk–
         dw        1                        ; po‡et zobrazen˜ch © dk–

         db        bit2                     ; maska zad van˜ch znak– - v¨echny
         db        0,'      '               ; zak zan‚ znaky

         db        HistFind                 ; historie hled n¡
EdiNPrN  db        1                        ; po‡et p©edvoleb

EdiNPrPN dw        0                        ; d‚lka p©edvolby
         dd        EdiHPrTx                 ; adresa p©edvolby

; ------ polo‘ky voleb

EdiNMPol db        bit6,36,'Text k nahrazen¡ nalezen‚ho ©etˆzce:'
         db        0,0
         db        bit6+bit7,0
         db        1,4,'D le'
         db        1,6,'N vrat'

EdiNMBlk db        0,0,0                    ; blokovac¡ tabulka

EdiNMTit db        6,'nahraƒ'

; ------ n povˆda

HelpS    SEGMENT   BYTE PUBLIC
EdiNMHlp db        62,'Zadejte textov˜ ©etˆzec, kter˜m bude nalezen˜ ©etˆzec nahrazen'
         db        41,'Pokra‡ov n¡ zad n¡m parametr– vyhled v n¡'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

; -----------------------------------------------------------------------------
;        menu zad n¡ textu k n hradˆ v HEX tvaru
; -----------------------------------------------------------------------------

EdiNHLin label     byte
         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        3                        ; po‡et platn˜ch polo‘ek menu
         dw        5                        ; celkov˜ po‡et polo‘ek menu

         dw        EdiNHPol                 ; za‡ tek definice polo‘ek menu
         dw        EdiNHHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@PodmenuEditoruKurzor ; ‡¡slo str nky velk‚ n povˆdy
         dw        EdiNHBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        EdiNMTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        20                       ; po‡ te‡n¡ pozice okna
         db        0                        ; po‡ te‡n¡ © dek okna
         db        46                       ; ¨¡©ka okna
         db        8                        ; v˜¨ka okna

         dw        TextFndX                 ; maxim ln¡ d‚lka textu © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        1                        ; celkov˜ po‡et © dk–
         dw        1                        ; po‡et zobrazen˜ch © dk–

         db        bit5                     ; maska zad van˜ch znak– - HEX znaky
         db        0,'      '               ; zak zan‚ znaky

         db        HistFind                 ; historie hled n¡
EdiNHPN  db        1                        ; po‡et p©edvoleb

EdiNHPPN dw        0                        ; d‚lka p©edvolby
         dd        EdiHPrTx                 ; adresa p©edvolby

; ------ polo‘ky voleb

EdiNHPol db        bit6,29,'Data v ',0,'HEX',0,' tvaru k n hradˆ:'
         db        0,0
         db        bit6+bit7,0
         db        1,4,'D le'
         db        1,6,'N vrat'

EdiNHBlk db        0,0,0                    ; blokovac¡ tabulka

; ------ n povˆda

HelpS    SEGMENT   BYTE PUBLIC
EdiNHHlp db        66,'Zadejte data k n hradˆ v HEX tvaru (jako bajty po 2 znac¡ch HEX)'
         db        41,'Pokra‡ov n¡ zad n¡m parametr– vyhled v n¡'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

; -----------------------------------------------------------------------------
;        zad n¡ parametr– hled n¡
; -----------------------------------------------------------------------------

EdiHPLin label     byte

         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        9                        ; po‡et platn˜ch polo‘ek menu
         dw        11                       ; celkov˜ po‡et polo‘ek menu

         dw        EdiHPPol                 ; za‡ tek definice polo‘ek menu
         dw        EdiHPHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@PodmenuEditoruKurzor ; ‡¡slo str nky velk‚ n povˆdy
         dw        EdiHPBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        EdiHPTit                 ; adresa titulu okna
         dw        EdiHPExe                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        20                       ; po‡ te‡n¡ pozice okna
         db        0                        ; po‡ te‡n¡ © dek okna
         db        78                       ; ¨¡©ka okna
         db        8                        ; v˜¨ka okna

         dw        15                       ; maxim ln¡ d‚lka textu © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        1                        ; celkov˜ po‡et © dk–
         dw        1                        ; po‡et zobrazen˜ch © dk–

         db        bit7                     ; maska zad van˜ch znak– - parametry
         db        0,'      '               ; zak zan‚ znaky

         db        HistSwch                 ; historie p©ep¡na‡–
         db        0                        ; po‡et p©edvoleb

; ------ polo‘ky voleb

EdiHPPol db        bit6,22,'Parametry vyhled v n¡:'
         db        0,0
         db        bit6+bit7,0
         db        1,6,'Hledej'
EdiHPPl1 db        bit7+1,5,'Asc -'
         db        bit7+1,5,'IBM -'
         db        bit7+1,5,'Kam -'
         db        bit7+1,5,'Lat -'
         db        bit7+2,5,'KOI -'
         db        bit7+1,5,'Win -'
         db        1,6,'N vrat'

EdiHPBlk db        0,0,0,0,0,0,0,0,0        ; blokovac¡ tabulka

EdiHPTit db        9,'parametry'

; ------ n povˆda

HelpS    SEGMENT   BYTE PUBLIC
EdiHPHlp db        89,'B zpˆt/U nerozli¨uj/G v¨echno/L blok/W slovo/‡¡slo p©esko‡it/(N bez dotazu)'
         db        24,'Vyhled n¡ zadan‚ho textu'

         db        65,'Soubor nen¡ v ‘ dn‚m n rodn¡m k¢du (pouze p¡smena bez diakritiky)'

         db        29,1
         dw        EdiHPHl2
         db        'IBM (omezen  diakritika)'

         db        26,1
         dw        EdiHPHl2
         db        'Kamenick˜ch (KEYBCS2)'

         db        12,1
         dw        EdiHPHl2
         db        'Latin 2'

         db        10,1
         dw        EdiHPHl2
         db        'KOI 8'

         db        17,1
         dw        EdiHPHl2
         db        'Windows 1250'

         db        3,1
         dw        MenuHlP2
HelpS    ENDS

EdiHPExe dd        Lin0MenR                 ; © dky
         dd        Lin0MenR                 ; Hledej
         dd        EdiHPEx1                 ; Asc
         dd        EdiHPEx1                 ; IBM
         dd        EdiHPEx1                 ; Kam
         dd        EdiHPEx1                 ; Lat
         dd        EdiHPEx1                 ; KOI
         dd        EdiHPEx1                 ; Win
         dd        Lin0MenR                 ; n vrat

EdiHPHl2 db        26,'Soubor je v n rodn¡m k¢du '

; -----------------------------------------------------------------------------
;        Definice vertik ln¡ho menu - modifikace bloku
; -----------------------------------------------------------------------------
;þ
EdModMnu label     byte                   ;* menu soubor–
         db        1                        ; typ menu - vertik ln¡ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        9                        ; po‡et platn˜ch polo‘ek menu
         dw        10                       ; celkov˜ po‡et polo‘ek menu

         dw        EdModPol                 ; adresa definice polo‘ek menu
         dw        EdModHlp                 ; adresa n povˆd
         dw        Hlp@ModifikaceBloku      ; ‡¡slo str nky velk‚ n povˆdy
         dw        EdModBlk                 ; adresa blokovac¡ tabulky
         dw        EdModSwc                 ; adresa tabulky p©ep¡na‡–
         dw        EdModTit                 ; adresa titulu okna
         dw        EdModExe                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        29                       ; po‡ te‡n¡ pozice
         db        1                        ; po‡ te‡n¡ © dek
         db        22                       ; ¨¡©ka
         db        12                       ; v˜¨ka

EdModPol db        1,13,'Velk  p¡smena'
         db        1,12,'Mal  p¡smena'
         db        1,5,'Fonty'
         db        bit6+bit7,0
         db        bit7+1,5,'Ascii'
         db        bit7+1,3,'IBM'
         db        bit7+1,11,'Kamenick˜ch'
         db        bit7+1,7,'Latin 2'
         db        bit7+2,5,'KOI 8'
         db        bit7+1,7,'Windows'

EdModBlk db        0,0,0,0,0,0,0,0,0
EdModSwc db        0,0,0,0,0,0
EdModTit db        16,'modifikace bloku'

HelpS    SEGMENT   BYTE PUBLIC
EdModHlp db        25,'Konverze na velk  p¡smena'
         db        24,'Konverze na mal  p¡smena'
         db        23,'Konverze n rodn¡ho k¢du'

         db        36,'Konverze pouze p¡smen bez diakritiky'

         db        29,1
         dw        EdiHPHl2
         db        'IBM (omezen  diakritika)'

         db        26,1
         dw        EdiHPHl2
         db        'Kamenick˜ch (KEYBCS2)'

         db        12,1
         dw        EdiHPHl2
         db        'Latin 2'

         db        10,1
         dw        EdiHPHl2
         db        'KOI 8'

         db        17,1
         dw        EdiHPHl2
         db        'Windows 1250'
HelpS    ENDS

EdModExe label     dword
         dd        EdiCtF8V                 ; Velk  p¡smena
         dd        EdiCtF8M                 ; Mal  p¡smena
         dd        EdiCtF8F                 ; Fonty
         dd        EditCF8P                 ; Ascii
         dd        EditCF8P                 ; IBM
         dd        EditCF8P                 ; Kamenick˜ch
         dd        EditCF8P                 ; Latin 2
         dd        EditCF8P                 ; KOI 8
         dd        EditCF8P                 ; Windows

; -----------------------------------------------------------------------------
;        zad n¡ c¡lov‚ho fontu
; -----------------------------------------------------------------------------

EMFntMnu label     byte
         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        7                        ; po‡et platn˜ch polo‘ek menu
         dw        9                        ; celkov˜ po‡et polo‘ek menu

         dw        EMFntPol                 ; za‡ tek definice polo‘ek menu
         dw        EMFntHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@ModifikaceBloku      ; ‡¡slo str nky velk‚ n povˆdy
         dw        EMFntBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        EMFntTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        20                       ; po‡ te‡n¡ pozice okna
         db        0                        ; po‡ te‡n¡ © dek okna
         db        76                       ; ¨¡©ka okna
         db        7                        ; v˜¨ka okna

         dw        250                      ; maxim ln¡ d‚lka textu © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        0                        ; celkov˜ po‡et © dk–
         dw        0                        ; po‡et zobrazen˜ch © dk–

         db        bit2                     ; maska zad van˜ch znak– - parametry
         db        0,'      '               ; zak zan‚ znaky

         db        0                        ; historie p©ep¡na‡–
         db        0                        ; po‡et p©edvoleb

EMFntPol db        bit6,45,'Obsah bloku bude zkonvertov n na n rodn¡ k¢d:'
         db        bit6+bit7,0
         db        1,5,'Ascii'
         db        1,3,'IBM'
         db        1,11,'Kamenick˜ch'
         db        1,7,'Latin 2'
         db        2,5,'KOI 8'
         db        1,7,'Windows'
         db        1,6,'N vrat'

EMFntTit db        13,'konverze k¢du'
EMFntBlk db        0,0,0,0,0,0,0            ; blokovac¡ tabulka

HelpS    SEGMENT   BYTE PUBLIC
EMFntHlp db        60,'Odstranˆn¡ diakritiky znak– (konverze na bˆ‘n˜ text ASCII)'

         db        29,1
         dw        EMFntHl2
         db        'IBM (omezen  diakritika)'

         db        26,1
         dw        EMFntHl2
         db        'Kamenick˜ch (KEYBCS2)'

         db        12,1
         dw        EMFntHl2
         db        'Latin 2'

         db        10,1
         dw        EMFntHl2
         db        'KOI 8'

         db        17,1
         dw        EMFntHl2
         db        'Windows 1250'

         db        3,1
         dw        MenuHlP2
HelpS    ENDS

EMFntHl2 db        30,'Konverze znak– na n rodn¡ k¢d '

; -----------------------------------------------------------------------------
;        hl ¨en¡ - text nenalezen
; -----------------------------------------------------------------------------

EdNFMLin label     byte
         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        1                        ; po‡et platn˜ch polo‘ek menu
         dw        6                        ; celkov˜ po‡et polo‘ek menu

         dw        EdNFMPol                 ; za‡ tek definice polo‘ek menu
         dw        ChbLnMeH                 ; adresa tabulky text– n povˆdy
         dw        Hlp@PodmenuEditoruKurzor ; ‡¡slo str nky velk‚ n povˆdy
         dw        EdNFMBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        EdNFMTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        20                       ; po‡ te‡n¡ pozice okna
         db        0                        ; po‡ te‡n¡ © dek okna
         db        48                       ; ¨¡©ka okna
         db        10                       ; v˜¨ka okna

         dw        255                      ; maxim ln¡ d‚lka textu © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        0                        ; celkov˜ po‡et © dk–
         dw        0                        ; po‡et zobrazen˜ch © dk–

         db        bit3                     ; maska zad van˜ch znak– - soubor
         db        0,'      '               ; zak zan‚ znaky

         db        0                        ; historie specifikac¡ soubor–
         db        0                        ; po‡et p©edvoleb

; ------ polo‘ky voleb

EdNFMPol db        bit6,0
         db        bit6,23,'Hledan˜ text nenalezen.'

         db        bit6,11,'"',4,0,3
EdNFMPl1 db        0
         dd        TextFnd
         db        0,'"'

         db        bit6,0
         db        bit6+bit7,0
         db        1,6,'N vrat'

EdNFMBlk db        0,0                      ; blokovac¡ tabulka

EdNFMTit db        14,'text nenalezen'

EdiHlTxt db        16,'Hled m "',0,1
         dd        TextFnd0
         db        0,'"'

EdiHlTx4 db        70,'Nahradit nalezen˜ ©etˆzec (',0,'A',0,'=ano, ',0,'N',0,'=ne, ',0,'V',0,'=v¨e, ',0,'ESC',0,'=p©eru¨it) ?'

; ------ hl ¨en¡ o operac¡ch

EdiCpTxt db        27,0,'Kop¡ruji',0,' ozna‡en˜ blok...'
EdiMvTxt db        28,0,'P©esouv m',0,' ozna‡en˜ blok...'
EdiDlTxt db        24,0,'Ru¨¡m',0,' ozna‡en˜ blok...'
EdiUkTxt db        39,0,'Ukl d m',0,' ozna‡en˜ blok do z sobn¡ku...'
EdiNaTxt db        31,0,'Navrac¡m',0,' blok ze z sobn¡ku...'

EdiCtTxt db        16,'Na‡¡t m soubor ',0

EdiMdTxt db        18,'Modifikuji blok...'

;EdiMdTbl dw        0,SEG CodeDek            ; konverzn¡ tabulka modifikace

EditPTmp db        0                        ; p©echodn‚ parametry
                                            ;   bit 0: 1=posun © dku je nahoru

Data     ENDS

         END

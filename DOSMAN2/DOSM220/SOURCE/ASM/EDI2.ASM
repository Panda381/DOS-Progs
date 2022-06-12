
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                             E D I T O R - 2
;
;                        editor - obsluha souboru
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

MAXBUSE  EQU       1000h/(BLOKBLOK/100h)    ; maxim†ln° poáet blokñ v historii

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                            Obsluha souboru
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; ----------------------------------------------------------------------------
;        otev©en° novÇho souboru (ve FILEPATH) -> AX=segment souboru, CY=chyba
;  (FILEPATH = 0 -> je to buffer -> FileFSiz=0, FileFAtr=0)
; -----------------------------------------------------------------------------

EditOpen PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ aktualizace velikosti a atributñ souboru

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       si,offset FilePath       ; jmÇno souboru
         cmp       byte ptr ds:[si],0       ; je to buffer ?
         je        EditOp04                 ; je to buffer
         call      far ptr GetAFile         ; atributy souboru
         jc        EditOp04                 ; chyba
         mov       ds:[FileFAtr],cl         ; atributy souboru
         call      far ptr OpenR            ; otev©en° souboru pro áten°
         jc        EditOp04                 ; chyba nebo soubor nenalezen
         call      far ptr SizeFile         ; test velikosti souboru
         jc        EditOp01                 ; nàjak† chyba
         mov       word ptr ds:[FileFSiz],cx ; velikost souboru LOW
         mov       word ptr ds:[FileFSiz+2],bx ; velikost souboru HIGH
         call      far ptr GetDFile         ; poskytnut° data a áasu souboru
         jc        EditOp01                 ; nàjak† chyba
         mov       ds:[FileFTim],cx         ; áas souboru
         mov       ds:[FileFDat],dx         ; datum souboru
EditOp01:call      far ptr ClosFile         ; uzav©en° souboru

; ------ vytvo©en° datovÇho bloku pro soubor -> BP

EditOp04:xor       bp,bp                    ; p©°znak, ëe nen° segment
         call      far ptr TestBreak        ; je p©eru®en° operace ?
         jc        EditOpn0                 ; je p©eru®en° operace
         call      far ptr CreatSeg         ; vytvo©en° datovÇho segmentu
         jnc       EditOpn1                 ; blok vytvo©en OK
EditOpn0:jmp       EditOpn8                 ; nedostatek pamàti
EditOpn1:mov       bp,ax                    ; BP <- £schova á°sla segmentu

; ------ stanoven° poátu blokñ souboru (u souboru > 260 MB rezerva 10 MB)

         mov       bx,word ptr ds:[FileFSiz] ; velikost souboru LOW
         mov       dx,word ptr ds:[FileFSiz+2] ; velikost souboru HIGH
         add       bx,BLOKBLOK-1            ; bude zaokrouhlen° na blok
         adc       dx,0                     ; p©enos
         jc        EditOp02                 ; chyba - soubor p©°li® velkò
                                            ; vòpoáet z†vis° na BLOKBLOK !
         shl       bx,1
         rcl       dx,1                     ; stanoven° poátu blokñ -> DX
         jc        EditOp02                 ; p©eteáen°
         cmp       dx,BLOKMAXN-32           ; maxim†ln° poáet popisovaáñ (-1 MB)
         jbe       EditOp10                 ; poáet blokñ je OK
EditOp02:mov       dx,(BLOKMAXN-340) AND not bit0 ; omezen° na maxim†ln° poáet blokñ
         mov       word ptr ds:[FileFSiz],0
         mov       word ptr ds:[FileFSiz+2],(BLOKMAXN-340)/2

; ------ nastaven° inicializaán° velikosti segmentu

EditOp10:mov       bx,EdiSumm               ; inicializaán° velikost
         mov       cx,dx                    ; poáet blokñ
         shl       cx,1
         shl       cx,1
         shl       cx,1                     ; poáet blokñ * 8 = velikost tabulky
         add       bx,cx                    ; poëadovan† velikost popisovaáe
         jc        EditOpn0                 ; (nemñëe nastat)
         call      far ptr ModiSegS         ; nastaven° velikosti segmentu
         jc        EditOpn0                 ; nedostatek pamàti

; ------ vynulov†n° datovÇho segmentu popisovaáe

         call      far ptr GetDat           ; adresa segmentu
         cld
         xor       di,di                    ; DI <- 0
         xchg      ax,bx                    ; AX <- velikost datovÇho bloku
         stosw                              ; velikost datovÇho bloku
         xor       ax,ax                    ; AX <- 0
         mov       cx,EdiSumm-2             ; velikost popisovaáe
         rep       stosb                    ; vynulov†n° segmentu

; ------ je buffer

         cmp       byte ptr ds:[FilePath],0 ; je to buffer ?
         jne       EditOp12                 ; nen° to buffer
         or        byte ptr es:[EdiParm0],bit7 ; p©°znak bufferu
         jmp       EditOpn4                 ; je to buffer

; ------ inicializace parametrñ

EditOp12:mov       es:[EdiNBlok],dx         ; poáet blokñ v tabulce
         mov       cx,dx                    ; CX <- poáet blokñ v tabulce

         mov       word ptr es:[EdiW1+EdiSir],40 + 12*HI ; pomocnÇ rozmàry okna
         mov       word ptr es:[EdiW2+EdiSir],40 + 12*HI ; pomocnÇ rozmàry okna
         mov       byte ptr es:[EdiW1+EdiLSir],40
         mov       byte ptr es:[EdiW2+EdiLSir],40

         mov       si,word ptr ds:[FileFSiz] ; velikost LOW
         mov       dx,word ptr ds:[FileFSiz+2] ; velikost HIGH
         mov       word ptr es:[EdiOSize],si ; pñvodn° velikost LOW
         mov       word ptr es:[EdiOSize+2],dx ; pñvodn° velikost HIGH
         mov       word ptr es:[EdiSize],si ; souáasn† velikost LOW
         mov       word ptr es:[EdiSize+2],dx ; souáasn† velikost HIGH

; ------ inicializace tabulky popisovaáñ (ES:DI=adresa tabulky)

         jcxz      EditOp18                 ; nen° ë†dnò blok
         xor       bx,bx                    ; popisovaá - vstupn° soubor
EditOp14:xor       ax,ax                    ; AX <- 0
         stosw                              ; nen° blok v pamàti
         mov       ax,bx                    ; AX <- popisovaá bloku v souboru
         stosw                              ; uloëen° popisovaáe bloku

         mov       ax,BLOKBLOK              ; velikost jednoho bloku
         sub       si,ax                    ; sn°ëen° á°taáe velikosti
         sbb       dx,0
         jnc       EditOp15                 ; nen° je®tà p©eteáen°
         add       si,ax                    ; n†vrat velikosti v posledn°m bloku
         xor       dx,dx                    ; DX <- 0
         xor       ax,ax                    ; AX <- 0
         xchg      ax,si                    ; AX <- velikost posledn°ho bloku
EditOp15:stosw                              ; poáet bajtñ v bloku

         mov       ax,-1                    ; p©°znak - nezn†mò poáet ©†dkñ
         stosw                              ; poáet p©elomñ ©†dkñ nezn†mò

         inc       bx                       ; zvò®en° ukazatele á°sla bloku
         loop      EditOp14

; ------ p©enesen° jmÇna souboru

EditOp18:mov       si,offset FilePath       ; specifikace souboru
         mov       di,EdiSoub               ; jmÇno souboru
         mov       bx,ds:[FilePthN]         ; dÇlka textu adres†©e
         cmp       byte ptr ds:[si+bx],"\"
         jne       EditOpn2
         inc       bx
EditOpn2:mov       es:[EdiSoubJ],bx         ; offset zaá†tku jmÇna souboru
         mov       cx,ds:[FileFilN]         ; dÇlka specifikace souboru
         mov       es:[EdiSoubN],cx         ; dÇlka specifikace souboru
         inc       cx                       ; váetnà koncovÇ 0
         rep       movsb                    ; p©enos jmÇna souboru

; ------ inicializace parametrñ

         mov       al,ds:[OldESwch]         ; inicializaán° parametry
         mov       es:[EdiW1+EdiParm1],al   ; parametry okna 1
         mov       es:[EdiW2+EdiParm1],al   ; parametry okna 2
         mov       al,ds:[OldESwc2]         ; inicializaán° parametry
         and       al,bit2+bit6+bit7        ; typ bloku
         test      byte ptr ds:[FileFAtr],RO ; je soubor R/O ?
         jz        EditOp22                 ; nen° R/O
         or        al,bit2                  ; soubor je R/O
EditOp22:mov       es:[EdiParm],al          ; parametry

         mov       al,ds:[FileFAtr]         ; atributy souboru
         mov       es:[EdiAtrib],al         ; atributy souboru
         mov       ax,ds:[FileFDat]         ; datum souboru
         mov       es:[EdiDate],ax          ; datum souboru
         mov       ax,ds:[FileFTim]         ; áas souboru
         mov       es:[EdiTime],ax          ; áas souboru

; ------ otev©en° souboru

EditOp23:mov       si,offset EdiSoub        ; jmÇno souboru
         call      far ptr OpenR            ; otev©en° pro áten°
         jnc       EditOpn3                 ; soubor otev©en OK

; ------ uzav©en° nàkterÇho souboru a novò pokus

         call      EditFFre                 ; uvolnàn° identifik†toru
         jc        EditOp24                 ; nen° ë†dnò
         call      far ptr OpenR            ; otev©en° pro áten°
         jnc       EditOpn3                 ; soubor otev©en OK

; ------ pokus o vytvo©en° souboru

EditOp24:call      far ptr CreatFil         ; vytvo©en° souboru
         jnc       EditOp25                 ; soubor vytvo©en OK
         jmp       EditOpn8                 ; chyba - soubor nelze ani vytvo©it

; ------ aktualizace adres†©e

EditOp25:call      far ptr ModiWDir         ; aktualizace adres†©e
         xchg      ax,bp                    ; segment okna
         call      far ptr GetDat           ; obnoven° adresy okna -> ES
         xchg      ax,bp

         or        byte ptr es:[EdiParm],bit3 ; p©°znak vytvo©en° souboru

; ------ parametry vytvo©enÇho souboru

         call      far ptr GetDFile         ; poskytnut° data a áasu souboru
         mov       es:[EdiDate],dx          ; datum souboru
         mov       es:[EdiTime],cx          ; áas souboru
         xor       cx,cx                    ; CX <- 0
         mov       word ptr es:[EdiOSize],cx ; velikost souboru
         mov       word ptr es:[EdiOSize+2],cx
         mov       word ptr es:[EdiSize],cx
         mov       word ptr es:[EdiSize+2],cx
         mov       word ptr es:[EdiNBlok],cx ; nen° ë†dnò blok v tabulce

; ------ atributy souboru

         call      far ptr GetAFile         ; atributy souboru
         mov       es:[EdiAtrib],cl         ; atributy souboru

; ------ korekce velikosti segmentu

         push      ax
         mov       ax,bp                    ; segment okna
         mov       bx,EdiSumm
         call      far ptr ModiSegS         ; nastaven° velikosti segmentu
         mov       es:[0],bx                ; nov† velikost segmentu
         pop       ax

; ------ uloëen° identifik†toru souboru

EditOpn3:mov       es:[EdiIdent],ax         ; identifik†tor souboru

; ------ test, zda to je za©°zen°

         call      far ptr TestDev          ; test, zda to je za©°zen°
         jnc       EditOpn7                 ; je to za©°zen° - chyba


; ------ inicializace parametrñ souboru (odtuto pokraáuje jië i buffer)

EditOpn4:mov       dx,bp                    ; DX <- segment okna
         mov       di,EdiW1                 ; okno 1
         call      EditCPgU                 ; inicializace na poá†tek
         or        dh,bit15/bit8            ; p©°znak okna 2
         mov       di,EdiW2                 ; okno 2
         call      EditCPgU                 ; inicializace na poá†tek

; ------ uloëen° segmentu do tabulky segmentñ

         test      byte ptr es:[EdiParm0],bit7 ; je to buffer ?
         jnz       EditOpn6                 ; je to buffer
         mov       ax,ds:[SegmTEdi]         ; tabulka segmentñ
         call      far ptr GetDat           ; adresa tabulky segmentñ
         jc        EditOpn7                 ; chyba ?
         mov       di,es:[0]                ; velikost segmentu
         mov       cx,2                     ; poáet bajtñ k vloëen°
         call      far ptr InsDat           ; vytvo©en° m°sta k vloëen° segmentu
         jc        EditOpn7                 ; nedostatek pamàti
         mov       es:[di],bp               ; uloëen° segmentu
         inc       word ptr ds:[NumEdi]     ; zvò®en° á°taáe souborñ
EditOpn6:xchg      ax,bp                    ; AX <- segment okna
;         clc                                ; p©°znak operace OK
         jmp       short EditOpn9           ; zde je NC !

; ------ p©i chybà uzav©en° souboru

EditOpn7:mov       ax,bp                    ; segment editoru
         call      far ptr GetDat           ; adresa segmentu
         jc        EditOpn8                 ; chyba ?
         mov       ax,es:[EdiIdent]         ; identifik†tor souboru
         call      far ptr ClosFile         ; uzav©en° souboru

; ------ p©i chybà zru®en° datovÇho bloku

EditOpn8:xchg      ax,bp                    ; AX <- á°slo datovÇho bloku
         call      far ptr DelSeg           ; zru®en° datovÇho segmentu
         stc                                ; p©°znak chyby

; ------ n†vrat registrñ

EditOpn9:pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

EditOpen ENDP

; -----------------------------------------------------------------------------
;     detekce souboru okna AX, zda je to textovò soubor (p©ednastaven bin†rn°)
; -----------------------------------------------------------------------------

EditDetT PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      es

; ------ adresa prvn°ho bloku souboru -> ES/CX

         xchg      ax,dx                    ; DX <- segment okna
         xor       bx,bx                    ; BX <- á°slo prvn°ho bloku
         call      EditBGet                 ; adresa prvn°ho bloku -> ES, CX
         jz        EditDtT9                 ; nejsou dal®° data nebo chyba
         xor       si,si                    ; ukazatel zaá†tku dat

; ------ test, zda to je textovò soubor

         call      far ptr TextDet          ; detekce, zda to je text
         jc        EditDtT9                 ; nen° textovò soubor

; ------ je textovò soubor -> NC

         call      EditGetD                 ; adresa okna
         and       byte ptr es:[EdiW1+EdiParm1],not bit2 ; zru®en° bin†rn°ho m¢du
         and       byte ptr es:[EdiW2+EdiParm1],not bit2 ; zru®en° bin†rn°ho m¢du

; ------ n†vrat registrñ

EditDtT9:pop       es
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

EditDetT ENDP

; -----------------------------------------------------------------------------
;        detekce dat ES:SI/CX, zda to je textovò soubor -> CY=bin†rn° soubor
; -----------------------------------------------------------------------------

TextDet  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp

; ------ test, zda je dost dat (jinak textovò m¢d)

         mov       ah,0                     ; AH <- 0
         mov       al,ds:[Pozic]            ; poáet pozic na ©†dek displeje
         cmp       cx,ax                    ; minim†ln° mnoëtv° dat - 1 ©†dek
         jb        TextDet8                 ; je m†lo znakñ -> textovò m¢d

; ------ p©°prava k prohled†n° dat

         push      cx                       ; £schova poátu bajtñ dat

         xor       bp,bp                    ; BP <- 0 á°taá znakñ > 128
         xor       di,di                    ; DI <- 0 á°taá LF a CR
         xor       bx,bx                    ; BX <- 0 á°taá bàënòch znakñ a TAB

; ------ prohled†n° dat

TextDet1:mov       al,es:[si]               ; znak ze souboru
         inc       si
         cmp       al,128
         jb        TextDet2
         inc       bp                       ; á°taá znakñ > 128

TextDet2:cmp       al,CR
         je        TextDet3                 ; je CR
         cmp       al,LF
         jne       TextDet4
TextDet3:inc       di                       ; á°taá LF a CR

TextDet4:cmp       al,FF
         je        TextDet5                 ; nov† str†nka
         cmp       al,EOF
         je        TextDet5                 ; konec souboru
         cmp       al,TAB
         je        TextDet5                 ; tabul†tor
         cmp       al,ESCP
         je        TextDet5                 ; Escape
         cmp       al," "
         jb        TextDet7
         cmp       al,"}"
         ja        TextDet7
TextDet5:inc       bx                       ; á°taá bàënòch znakñ

TextDet7:loop      TextDet1

         pop       cx                       ; poáet bajtñ dat

; ------ p©evod £dajñ na relativn° á°sla 0 aë 999

         mov       ax,1000
         mul       bp
         div       cx
         xchg      ax,bp                    ; BP <- poáet znakñ > 128 relativnà

         mov       ax,1000
         mul       di
         div       cx
         xchg      ax,di                    ; DI <- poáet LF a CR relativnà

         mov       ax,1000
         mul       bx
         div       cx
         xchg      ax,bx                    ; BX <- poáet bàënòch znakñ relativnà

         mov       ax,1000
         sub       ax,bp
         sub       ax,di
         sub       ax,bx
         xchg      ax,cx                    ; CX <- neplatnÇ znaky relativnà

; ------ test, zda je textovò soubor

         cmp       di,5                     ; LF a CR minim†lnà 1 na 200
         jb        TextDet9                 ; nen° textovò soubor
         cmp       bx,200                   ; bàënòch znakñ minim†lnà 1 na 5
         jb        TextDet9                 ; nen° textovò soubor
         cmp       cx,80                    ; jinòch znakñ maxim†lnà 1 na 12
         ja        TextDet9                 ; nen° textovò soubor

; ------ je textovò soubor

TextDet8:clc                                ; p©°znak, ëe je textovò soubor
         jmp       short TextDetA

; ------ je bin†rn° soubor

TextDet9:stc                                ; p©°znak, ëe je bin†rn° soubor

; ------ n†vrat registrñ

TextDetA:pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

TextDet  ENDP

; -----------------------------------------------------------------------------
;        rozvrëen° oken (nap©. po p©epnut° okna)
; -----------------------------------------------------------------------------

EditRozv PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      es

; ------ poá†teán° ©†dek a pozice oken

         or        byte ptr ds:[EditPar2],bit3 ; p©°znak - zobrazit v®echno
         xor       dx,dx                    ; poá†teán° ©†dek a pozice = 0
         test      byte ptr ds:[ParMenu],bit0 ; je trvalÇ hlavn° menu ?
         jz        EditRzv1                 ; nen° trvalÇ hlavn° menu
         inc       dh                       ; poá†teán° ©†dek, je-li trvalÇ menu

; ------ ®°©ka a vò®ka oken

EditRzv1:mov       ch,ds:[Radku]            ; poáet ©†dkñ displeje
         mov       cl,ds:[Pozic]            ; poáet pozic displeje
         test      byte ptr ds:[HelpPar],bit0 ; je mal† n†povàda ?
         jz        EditRzv2                 ; nen° mal† n†povàda
         dec       ch                       ; kromà posledn°ho ©†dku
EditRzv2:sub       ch,dh                    ; zbyl† vò®ka pro okna

; ------ celoplo®nÇ zobrazen° okna

         mov       ax,ds:[EdiS1Win]         ; segment okna 1
         mov       bx,EdiW1                 ; popisovaá okna 1

         test      byte ptr ds:[EditPar2],bit4 ; jsou 2 okna ?
         jnz       EditRzv3                 ; jsou 2 okna
         test      byte ptr ds:[EditPar2],bit6 ; je aktivn° okno 2 ?
         jnz       EditRz42                 ; je okno 2
         jmp       EditRzv8                 ; je aktivn° okno 1

; ------ okna nad sebou

EditRzv3:test      byte ptr ds:[EditPar2],bit5 ; jsou vertik†ln° okna ?
         jnz       EditRzv5                 ; jsou vertik†ln° okna

         call      EditRzvW                 ; parametry pro okno 1
         pushf
         push      bx
         push      dx

         mov       bx,ds:[Edit0Vys]         ; vò®ka okna 1 relativnà
         mov       ah,0
         mov       al,ch                    ; vò®ka oken celkem
         mul       bx                       ; vò®ka okna 1 relativnà
         shr       bx,1
         shr       bx,1                     ; relativn° vò®ka okna / 4
         add       ax,bx                    ; korekce pro zaokrouhlen°
         adc       dx,0                     ; p©enos p©i zaokrouhlen°
         mov       al,dl                    ; vò®ka okna 1
         cmp       al,2                     ; minim†ln° vò®ka okna
         jae       EditRz32                 ; vò®ka okna je OK
         mov       al,2                     ; minim†ln° vò®ka 2 ©†dky

EditRz32:add       al,2                     ; p©iáten° vò®ky okna 2
         jc        EdiRz322                 ; p©eteáen° vò®ky okna
         cmp       al,ch                    ; p©ekroáena celkov† vò®ka ?
         jbe       EditRz33                 ; maxim†ln° vò®ka OK
EdiRz322:mov       al,ch                    ; omezen† vò®ka
EditRz33:sub       al,2                     ; odeáten° vò®ky okna 2

         pop       dx
         pop       bx
         popf
         jc        EditRzv4                 ; neplatnÇ okno
         mov       es:[bx+EdiVys],al        ; opraven† vò®ka okna 1
EditRzv4:sub       ch,al                    ; zbytek vò®ky pro okno 2
         add       dh,al                    ; posun poá†teán°ho ©†dku
EditRz42:jmp       short EditRzv7           ; pokraáov†n° oknem 2

; ------ okna vedle sebe

EditRzv5:dec       cl                       ; ®°©ka bez oddàlovac° á†ry
         call      EditRzvW                 ; parametry pro okno 1
         pushf
         push      bx
         push      dx

         mov       bx,ds:[Edit0Sir]         ; ®°©ka okna 1 relativnà
         mov       ah,0
         mov       al,cl                    ; ®°©ka oken celkem
         mul       bx                       ; ®°©ka okna 1 relativnà
         shr       bx,1
         shr       bx,1                     ; relativn° ®°©ka okna / 4
         add       ax,bx                    ; korekce pro zaokrouhlen°
         adc       dx,0                     ; p©enos p©i zaokrouhlen°
         mov       al,dl                    ; ®°©ka okna 1
         cmp       al,2                     ; minim†ln° ®°©ka okna
         jae       EditRz52                 ; ®°©ka okna je OK
         mov       al,2                     ; minim†ln° ®°©ka okna

EditRz52:add       al,2                     ; p©iáten° ®°©ky okna 2
         jc        EdiRz522                 ; p©eteáen° ®°©ky okna
         cmp       al,cl                    ; je p©ekroáena maxim†ln° ®°©ka ?
         jbe       EditRz53                 ; maxim†ln° ®°©ka OK
EdiRz522:mov       al,cl                    ; omezen° ®°©ky
EditRz53:sub       al,2                     ; odeáten° ®°©ky okna 2

         pop       dx
         pop       bx
         popf

         jc        EditRzv6                 ; neplatnÇ okno
         mov       es:[bx+EdiSir],al        ; ®°©ka okna 1
         mov       byte ptr es:[bx+EdiLSir],al ; ®°©ka pro bin†rn° m¢d
         call      EditRzvH                 ; ®°©ka dat pro HEX m¢d
EditRzv6:sub       cl,al                    ; zbytek ®°©ky pro okno 2
         add       dl,al                    ; posun poá†teán° pozice
         inc       dx                       ; p©eskoáen° oddàlovac° á†ry

; ------ nastaven° posledn°ho okna

EditRzv7:mov       ax,ds:[EdiS2Win]         ; segment okna 2
         mov       bx,EdiW2                 ; popisovaá okna 2
EditRzv8:call      EditRzvW

; ------ n†vrat registrñ

EditRzv9:pop       es
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

EditRozv ENDP

; ------ nastaven° parametrñ pro okno AX, definice BX, pozice DX, rozmàry CX

EditRzvW:and       ah,not bit15/bit8
         call      far ptr GetDat           ; adresa okna
         jc        EditRzvX                 ; nen° okno
         mov       word ptr es:[bx+EdiPoz],dx ; poá†teán° ©†dek a pozice okna
         mov       word ptr es:[bx+EdiSir],cx ; ®°©ka a vò®ka okna
         mov       byte ptr es:[bx+EdiLSir+1],0
         mov       byte ptr es:[bx+EdiLSir],cl ; ®°©ka pro m¢d BIN

; ------ ®°©ka pro HEX m¢d (pokraáuje za EditRzvW !)

EditRzvH:pushf
         test      byte ptr es:[bx+EdiParm1],bit1 ; je HEX m¢d ?
         jz        EditRzH8                 ; nen° HEX m¢d
         mov       byte ptr es:[bx+EdiLSir],16 ; ®°©ka pro m¢d HEX
         cmp       byte ptr es:[bx+EdiSir],80 ; je dostateán† ®°©ka okna ?
         jae       EditRzH8                 ; je dostateán† ®°©ka okna

         push      ax
         mov       al,es:[bx+EdiSir]        ; ®°©ka okna
         sub       al,8                     ; odeáten° pevnÇ á†sti
         jbe       EditRzH4                 ; podteáen°
         cmp       al,16*4                  ; maxim†ln° ®°©ka
         jbe       EditRzH2                 ; ®°©ka je OK
         mov       al,16*4                  ; maxim†ln° ®°©ka
EditRzH2:shr       al,1
         shr       al,1                     ; ®°©ka / 4
         jnz       EditRzH6                 ; ®°©ka je OK
EditRzH4:mov       al,1                     ; minim†ln° ®°©ka dat
EditRzH6:mov       byte ptr es:[bx+EdiLSir],al ; ®°©ka pro HEX m¢d
         cmp       byte ptr es:[bx+EdiSir],2+1+1 ; minim†ln° ®°©ka pole
         jae       EditRzH7                 ; ®°©ka okna je OK
         and       byte ptr es:[bx+EdiParm2],not bit2 ; nen° ASCII á†st HEX pole
EditRzH7:pop       ax

EditRzH8:popf

EditRzvX:ret

; -----------------------------------------------------------------------------
;        uvolnàn° nàkterÇho identifik†toru souboru (CY=nelze)
; -----------------------------------------------------------------------------

EditFFre PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      bp
         push      es

; ------ adresa segmentu tabulky -> BP

         mov       ax,ds:[SegmTEdi]         ; segment souborñ
         call      far ptr GetDat           ; adresa segmentu
         jc        EditFFr4                 ; chyba ?
         mov       bp,es                    ; BP <- segment definic souborñ

; ------ p©°prava ukazatelñ

         mov       cx,ds:[NumEdi]           ; poáet souborñ
         jcxz      EditFFr4                 ; nen° ë†dnò soubor
         xor       bx,bx                    ; ukazatel tabulky

; ------ prohled†n° identifik†torñ souborñ

EditFFr1:mov       es,bp                    ; ES <- segment tabulky souborñ
         inc       bx
         inc       bx                       ; zvò®en° ukazatele v tabulce
         mov       ax,es:[bx]               ; á°slo okna
         call      far ptr GetDat           ; adresa okna
         jc        EditFFr2                 ; nàjak† chyba
         mov       ax,es:[EdiIdent]         ; identifik†tor souboru
         or        ax,ax                    ; je soubor otev©en ?
         jnz       EditFFr3                 ; soubor je otev©en OK
EditFFr2:loop      EditFFr1                 ; dal®° okno
         jmp       short EditFFr4           ; nenalezen otev©enò soubor

; ------ uzav©en° vstupn°ho souboru okna

EditFFr3:call      far ptr ClosFile         ; uzav©en° souboru
         mov       es:[EdiIdent],ax         ; oznaáen°, ëe soubor je uzav©en
         jmp       short EditFFr8

; ------ uzav©en° p©echodnÇho souboru

EditFFr4:mov       ax,ds:[EditTemp]         ; identifik†tor p©echodnÇho souboru
         or        ax,ax                    ; je p©echodnò soubor otev©en ?
         jz        EditFFr5                 ; p©echodnò soubor nen° otev©en
         call      far ptr ClosFile         ; uzav©en° p©echodnÇho souboru
         mov       ds:[EditTemp],ax         ; oznaáen°, ëe je uzav©en
         jmp       short EditFFr8

; ------ uzav©en° vòstupn°ho souboru

EditFFr5:mov       ax,ds:[EditOutI]         ; identifik†tor vòstupn°ho souboru
         or        ax,ax
         stc
         jz        EditFFr9                 ; nen° nic otev©eno
         call      far ptr ClosFile         ; uzav©en° vòstupn°ho souboru
         mov       ds:[EditOutI],ax         ; oznaáen°, ëe je uzav©en

; ------ n†vrat registrñ

EditFFr8:clc                                ; p©°znak operace OK
EditFFr9:pop       es
         pop       bp
         pop       cx
         pop       bx
         pop       ax
         ret

EditFFre ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                    Obsluha datovòch blokñ souboru
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; -----------------------------------------------------------------------------
;        nulov†n° segmentu bufferu (clipboard) (mus° n†sledovat IniSBuf !!!)
; -----------------------------------------------------------------------------
; VSTUP: AL=parametry souboru (typ bloku)
;                 bit 6: 1=sloupcovò blokƒø0=text.
;                 bit 7: 1=©†dkovò blok ƒƒŸ blok
; -----------------------------------------------------------------------------

NulSBuf  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      di
         push      es

; ------ adresa bufferu

         mov       dx,ds:[EditSBuf]         ; segment bufferu
         call      EditGetD                 ; adresa okna

; ------ p©°prava typu bloku

         and       al,bit6+bit7             ; parametry blokñ
         and       byte ptr es:[EdiParm],not bit6+bit7 ; nulov†n° typu bloku
         or        es:[EdiParm],al          ; zadanò typ bloku

; ------ zru®en° popisovaáñ blokñ

         mov       di,EdiABlok              ; adresa prvn°ho popisovaáe
NulSBuf2:cmp       word ptr es:[EdiNBlok],0 ; je je®tà nàjakò blok ?
         je        NulSBuf6                 ; nen° dal®° blok
         call      EditBDel                 ; zru®en° popisovaáe okna
         jmp       short NulSBuf2

; ------ vynulov†n° ukazatelñ bloku

NulSBuf6:xor       ax,ax                    ; AX <- 0
         mov       di,EdiPBBlk              ; pozice zaá†tku bloku
         mov       cx,6*4/2                 ; poáet slov k vynulov†n°
         cld
         rep       stosw                    ; vynulov†n° ukazatelñ bloku
         and       byte ptr es:[EdiParm0],not bit0+bit1+bit2+bit3+bit4+bit5

; ------ n†vrat registrñ

NulSBuf9:pop       es
         pop       di
         pop       dx
         pop       cx
         pop       ax

; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;         ret                               ; pokraáuje IniSBuf !!!
; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! neposouvat !!!!!!!!!!!!!!!!!!!!!!!!

NulSBuf  ENDP

; -----------------------------------------------------------------------------
;        inicializace ukazatele v bufferu (clipboard) (mus° bòt za NulSBuf !!!)
; -----------------------------------------------------------------------------

; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! neposouvat !!!!!!!!!!!!!!!!!!!!!!!!

InitUBuf PROC      NEAR

; ------ £schova registrñ

         push      es

; ------ adresa bufferu

         call      EditGetB                 ; adresa bufferu

; ------ nulov†n° ukazatele dat

         mov       word ptr es:[EdiW1+EdiBKur],0 ; nulov†n° bloku ukazatele
         mov       word ptr es:[EdiW1+EdiOKur],0 ; nulov†n° offsetu ukazatele

; ------ n†vrat registrñ

         pop       es
         ret

InitUBuf ENDP

; -----------------------------------------------------------------------------
;            uloëen° konce ©†dku CR/LF do bufferu
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY=chyba
; -----------------------------------------------------------------------------
;        niá° registr ES a posouv† segmenty !
; -----------------------------------------------------------------------------

EdiCrlBf PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

; ------ adresa okna bufferu

         mov       dx,ds:[EditSBuf]         ; segment bufferu
         call      EditGetD                 ; adresa okna

; ------ ukazatel ukl†dac° pozice do bufferu -> BX:SI

         mov       bx,es:[EdiW1+EdiBKur]    ; ukl†dac° blok
         mov       si,es:[EdiW1+EdiOKur]    ; ukl†dac° offset

; ------ vloëen° konce ©†dku CR/LF

         xor       cx,cx                    ; CX <- 0
         mov       ax,1                     ; vkl†d† se 1 CR/LF
         call      EditILn                  ; vloëen° konce ©†dku

; ------ nov† ukl†dac° adresa do bufferu

         mov       es:[EdiW1+EdiBKur],bx    ; ukl†dac° blok
         mov       es:[EdiW1+EdiOKur],si    ; ukl†dac° offset

; ------ n†vrat registrñ

         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

EdiCrlBf ENDP

; -----------------------------------------------------------------------------
;        uloëen° bloku dat do bufferu s £schovou registrñ
; -----------------------------------------------------------------------------
; VSTUP: CX:AX=poáet bajtñ k uloëen°
;        BX=blok zaá†tku dat
;        SI=offset zaá†tku dat
;        DX=á°slo segmentu okna
;        DS=datovò segment
; VùSTUP: ES=adresa segmentu okna
;         CY=chyba operace (data neuloëena v®echna)
; -----------------------------------------------------------------------------

EdiToBf0 PROC      NEAR

         push      ax
         push      cx
         push      bx
         push      si

         call      EdiToBuf

         pop       si
         pop       bx
         pop       cx
         pop       ax
         ret

EdiToBf0 ENDP

; -----------------------------------------------------------------------------
;                               EdiToBuf
;           uloëen° bloku dat do bufferu (na pozici ukazatele)
; -----------------------------------------------------------------------------
; VSTUP: CX:AX=poáet bajtñ k uloëen°
;        BX=blok zaá†tku dat
;        SI=offset zaá†tku dat
;        DX=á°slo segmentu okna
;        DS=datovò segment
; VùSTUP: CX:AX=poáet zbòvaj°c°ch neuloëenòch dat
;         BX=novò blok za ukl†danòmi daty
;         SI=novò offset za ukl†danòmi daty
;         ES=adresa segmentu okna
;         CY=chyba operace (data neuloëena v®echna)
; -----------------------------------------------------------------------------

EdiToBuf PROC      NEAR

; ------ adresa segmentu bufferu

         call      EditGetB                 ; adresa bufferu

; ------ proveden° operace uloëen° dat do bufferu

         push      word ptr ds:[EditSBuf]   ; segment c°lovÇho souboru
         push      dx                       ; segment zdrojovÇho souboru
         push      word ptr es:[EdiW1+EdiBKur] ; poá†teán° blok c°lovÇho souboru
         push      word ptr es:[EdiW1+EdiOKur] ; poá†teán° offset c°lovÇho souboru
         push      bx                       ; blok zdrojovÇho souboru
         push      si                       ; offset zdrojovÇho souboru
         push      cx                       ; poáet bajtñ HIGH
         push      ax                       ; poáet bajtñ LOW

         call      EditCopy                 ; proveden° operace p©esunu dat

         call      EditGetB                 ; adresa bufferu

         pop       ax                       ; zbylò poáet bajtñ LOW
         pop       cx                       ; zbylò poáet bajtñ HIGH
         pop       si                       ; novò offset zdrojovÇho souboru
         pop       bx                       ; novò blok zdrojovÇho souboru
         pop       word ptr es:[EdiW1+EdiOKur] ; novò offset ukazatele
         pop       word ptr es:[EdiW1+EdiBKur] ; novò blok ukazatele
         pop       es                       ; zru®en° zdrojovÇho segmentu
         pop       es                       ; zru®en° c°lovÇho segmentu

; ------ adresa segmentu okna

         call      EditGt0D                 ; obnoven° adresy okna
         ret

EdiToBuf ENDP

; -----------------------------------------------------------------------------
;                              EdiLnBf
;         poskytnut° dÇlky aktivn°ho ©†dku v bufferu (v pozic°ch)
;      (ukazatel kurzoru v bufferu mus° ukazovat na zaá†tek ©†dku !)
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CX:AX=dÇlka aktivn°ho (p©ipravenÇho) ©†dku (v pozic°ch !)
;         CY=chyba operace
; -----------------------------------------------------------------------------
; registr ES zniáen (a posunuty bloky) !
; -----------------------------------------------------------------------------

EdiLnBf  PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      dx
         push      si

; ------ adresa bufferu -> ES

         call      EditGetB                 ; adresa bufferu -> ES

; ------ dÇlka aktivn°ho ©†dku

         mov       dx,ds:[EditSBuf]         ; segment bufferu
         mov       bx,es:[EdiW1+EdiBKur]    ; poá†teán° blok zdrojovÇho souboru
         mov       si,es:[EdiW1+EdiOKur]    ; poá†teán° offset zdrojovÇho souboru
         call      EditLenL                 ; stanoven° dÇlky ©†dku

; ------ n†vrat registrñ

EdiLnBf9:pop       si
         pop       dx
         pop       bx
         ret

EdiLnBf  ENDP

; -----------------------------------------------------------------------------
;                                 EdiNxtBf
;                   nastaven° na dal®° ©†dek v bufferu
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY=chyba operace
; -----------------------------------------------------------------------------
; registr ES zniáen (a posunuty bloky) !
; -----------------------------------------------------------------------------

EdiNxtBf PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      dx
         push      si

; ------ adresa bufferu -> ES

         call      EditGetB                 ; adresa bufferu

; ------ ukazatele textu v bufferu

         mov       dx,ds:[EditSBuf]         ; segment bufferu
         mov       bx,es:[EdiW1+EdiBKur]    ; poá†teán° blok zdrojovÇho souboru
         mov       si,es:[EdiW1+EdiOKur]    ; poá†teán° offset zdrojovÇho souboru

; ------ vypu®tàn° jednoho znaku

EdiNxBf2:call      EdiGetCh                 ; znak na pozici kurzoru
         jc        EdiNxBf9                 ; chyba
         jz        EdiNxBf8                 ; nen° dal®° znak
EdiNxBf3:inc       si                       ; vypu®tàn° jednoho znaku

; ------ test, zda je znak LF

         cmp       al,LF                    ; je LF ?
         jne       EdiNxBf4                 ; nen° LF

; ------ test, zda za znakem LF n†sleduje CR

         call      EdiGetCh                 ; n†sleduj°c° znak
         jc        EdiNxBf9                 ; chyba
         jz        EdiNxBf8                 ; nen° dal®° znak
         cmp       al,CR                    ; n†sleduje znak CR ?
         jne       EdiNxBf8                 ; nen° CR - konec ©†dku
         inc       si                       ; p©eskoáen° znaku CR
         jmp       short EdiNxBf8           ; konec ©†dku

; ------ test, zda je znak CR

EdiNxBf4:cmp       al,CR                    ; je znak CR ?
         jne       EdiNxBf2                 ; nen° znak CR - dal®° znak

; ------ test, zda za znakem CR n†sleduje znak LF

         call      EdiGetCh                 ; n†sleduj°c° znak
         jc        EdiNxBf9                 ; chyba
         jz        EdiNxBf8                 ; nen° dal®° znak
         cmp       al,LF                    ; n†sleduje znak LF ?
         jne       EdiNxBf3                 ; nen†sleduje znak LF
         inc       si                       ; p©eskoáen° znaku LF

; ------ uloëen° novÇho ukazatele textu

EdiNxBf8:clc
         mov       es:[EdiW1+EdiBKur],bx    ; poá†teán° blok zdrojovÇho souboru
         mov       es:[EdiW1+EdiOKur],si    ; poá†teán° offset zdrojovÇho souboru

; ------ n†vrat registrñ

EdiNxBf9:pop       si
         pop       dx
         pop       bx
         ret

EdiNxtBf ENDP

; -----------------------------------------------------------------------------
;                              EdiFrmB0
;                naáten° bloku dat z bufferu s £schovou registrñ
; -----------------------------------------------------------------------------
; VSTUP: CX:AX=poáet bajtñ k naáten°
;        BX=blok zaá†tku, kam se maj° data naá°st
;        SI=offset zaá†tku, kam se maj° data naá°st
;        DX=á°slo segmentu okna
;        DS=datovò segment
; VùSTUP: ES=adresa segmentu okna
;         CY=chyba operace (data nenaátena v®echna)
; -----------------------------------------------------------------------------

EdiFrmB0 PROC      NEAR

         push      ax
         push      cx
         push      bx
         push      si

         call      EdiFrmBf

         pop       si
         pop       bx
         pop       cx
         pop       ax
         ret

EdiFrmB0 ENDP

; -----------------------------------------------------------------------------
;                              EdiFrmBf
;                naáten° bloku dat z bufferu (z pozice ukazatele)
; -----------------------------------------------------------------------------
; VSTUP: CX:AX=poáet bajtñ k naáten°
;        BX=blok zaá†tku, kam se maj° data naá°st
;        SI=offset zaá†tku, kam se maj° data naá°st
;        DX=á°slo segmentu okna
;        DS=datovò segment
; VùSTUP: CX:AX=poáet zbòvaj°c°ch nenaátenòch dat (p©i NC je = 0)
;         BX=novò blok za naá°tanòmi daty
;         SI=novò offset za naá°tanòmi daty
;         ES=adresa segmentu okna
;         CY=chyba operace (data nenaátena v®echna)
; -----------------------------------------------------------------------------

EdiFrmBf PROC      NEAR

; ------ adresa segmentu bufferu -> ES

         call      EditGetB                 ; adresa bufferu

; ------ proveden° operace naáten° dat z bufferu

         push      dx                       ; segment c°lovÇho souboru
         push      word ptr ds:[EditSBuf]   ; segment zdrojovÇho souboru
         push      bx                       ; blok c°lovÇho souboru
         push      si                       ; offset c°lovÇho souboru
         push      word ptr es:[EdiW1+EdiBKur] ; poá†teán° blok zdrojovÇho souboru
         push      word ptr es:[EdiW1+EdiOKur] ; poá†teán° offset zdrojovÇho souboru
         push      cx                       ; poáet bajtñ HIGH
         push      ax                       ; poáet bajtñ LOW

         call      EditCopy                 ; proveden° operace p©esunu dat

         call      EditGetB                 ; adresa bufferu

         pop       ax                       ; zbylò poáet bajtñ LOW
         pop       cx                       ; zbylò poáet bajtñ HIGH
         pop       word ptr es:[EdiW1+EdiOKur] ; novò offset ukazatele
         pop       word ptr es:[EdiW1+EdiBKur] ; novò blok ukazatele
         pop       si                       ; novò offset c°lovÇho souboru
         pop       bx                       ; novò blok c°lovÇho souboru
         pop       es                       ; zru®en° zdrojovÇho segmentu
         pop       es                       ; zru®en° c°lovÇho segmentu

; ------ adresa segmentu okna

         call      EditGt0D                 ; obnoven° adresy okna
         ret

EdiFrmBf ENDP

; -----------------------------------------------------------------------------
;                               EditCopy
;                     kop°rov†n° £seku dat mezi soubory
;                 Operaci nelze prov†dàt v jednom souboru !
;         Po operaci je nutno aktualizovat adresu segmentu okna !
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
;        SS:[SP+16] (2) á°slo segmentu c°lovÇho souboru
;        SS:[SP+14] (2) á°slo segmentu zdrojovÇho souboru
;        SS:[SP+12] (2) poá†teán° á°slo bloku c°lovÇho souboru
;        SS:[SP+10] (2) offset v bloku c°lovÇho souboru
;        SS:[SP+8] (2) poá†teán° á°slo bloku zdrojovÇho souboru
;        SS:[SP+6] (2) offset v bloku zdrojovÇho souboru
;        SS:[SP+2] (4) poáet bajtñ ke zkop°rov†n°
; VùSTUP:SS:[SP+12] (2) novÇ poá†teán° á°slo bloku c°lovÇho souboru
;        SS:[SP+10] (2) novò offset v bloku c°lovÇho souboru
;        SS:[SP+8] (2) novÇ poá†teán° á°slo bloku zdrojovÇho souboru
;        SS:[SP+6] (2) novò offset v bloku zdrojovÇho souboru
;        SS:[SP+2] (4) zbylò poáet nezkop°rovanòch bajtñ (p©i NC je = 0)
;         CY=chyba operace (ukazatele blokñ nejsou zaruáeny)
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ:
;        SS:[BP+32] (2) á°slo segmentu c°lovÇho souboru
;        SS:[BP+30] (2) á°slo segmentu zdrojovÇho souboru
;        SS:[BP+28] (2) ukazatel á°sla bloku c°lovÇho souboru
;        SS:[BP+26] (2) ukazatel offsetu v bloku c°lovÇho souboru
;        SS:[BP+24] (2) ukazatel á°sla bloku zdrojovÇho souboru
;        SS:[BP+22] (2) ukazatel offsetu v bloku zdrojovÇho souboru
;        SS:[BP+18] (4) á°taá poátu bajtñ ke zkop°rov†n°
;
;        SS:[BP-2]  (2) datovò segment
;        SS:[BP-4]  (2) adresa segmentu c°lovÇho souboru
;        SS:[BP-6]  (2) adresa segmentu zdrojovÇho souboru
;        SS:[BP-8]  (2) adresa popisovaáe c°lovÇho bloku v segmentu okna
;        SS:[BP-10] (2) adresa popisovaáe zdrojovÇho bloku v segmentu okna
;        SS:[BP-12] (2) poáet bajtñ ke zkop°rov†n° v jednÇ operaci
;        SS:[BP-14] (2) adresa bloku c°lovÇho souboru
;        SS:[BP-16] (2) adresa bloku zdrojovÇho souboru
;        SS:[BP-18] (2) uschovanÇ á°slo bloku ukl†dac° adresy do c°lovÇho bloku
;        SS:[BP-20] (2) uschovanò offset ukl†dac° adresy do c°lovÇho bloku
;        SS:[BP-22] (2) á°slo segmentu c°lovÇho bloku
;        SS:[BP-24] (2) á°slo segmentu zdrojovÇho bloku
; -----------------------------------------------------------------------------
;˛
EditCopy PROC      NEAR

; ------ £schova registrñ
                                            ; IP = SS:[BP+16]
         push      ax                       ; AX = SS:[BP+14]
         push      bx                       ; BX = SS:[BP+12]
         push      cx                       ; CX = SS:[BP+10]
         push      dx                       ; DX = SS:[BP+8]
         push      si                       ; SI = SS:[BP+6]
         push      di                       ; DI = SS:[BP+4]
         push      bp                       ; BP = SS:[BP+2]
         push      es                       ; ES = SS:[BP+0]

; ------ p©°prava lok†ln°ch promànnòch

         mov       bp,sp
         sub       sp,24
         mov       ss:[bp-2],ds             ; £schova datovÇho segmentu

; ------ p©°prava poátu bajtñ pro jednu operaci

EditCop1:mov       ax,BLOKBLOK              ; velikost jednoho bloku
         cmp       word ptr ss:[bp+18+2],0  ; zbòv† v°ce dat neë 64 KB ?
         jne       EditCp12                 ; zbòv† v°ce dat
         cmp       ax,ss:[bp+18]            ; zbòv† v°ce dat ?
         jbe       EditCp12                 ; zbòv† v°ce dat
         mov       ax,ss:[bp+18]            ; omezen° velikosti dat
EditCp12:mov       ss:[bp-12],ax            ; poáet bajtñ ke zkop°rov†n°
         or        ax,ax                    ; je je®tà co kop°rovat ?
         jnz       EditCp14                 ; je je®tà co kop°rovat
EditCp13:jmp       EditCop9                 ; konec operace

EditC138:jmp       EditCop8                 ; chyba operace

; ------ naáten° zdrojovÇho segmentu

EditCp14:mov       bx,ss:[bp+24]            ; blok zdrojovÇho souboru
         mov       si,ss:[bp+22]            ; offset v bloku zdrojovÇho souboru
         mov       dx,ss:[bp+30]            ; á°slo segmentu zdrojovÇho souboru
         call      EditNGet                 ; poskytnut° bloku
         jz        EditC138                 ; nejsou dal®° data nebo chyba
         mov       ss:[bp+22],si            ; novò offset v bloku
         mov       ss:[bp+24],bx            ; novò blok zdrojovÇho souboru

; ------ omezen° velikosti dat k p©esunu (podle zbylòch dat ve zdrojovÇm bloku)

         sub       cx,si                    ; poáet zbylòch dat v bloku
         jbe       EditC138                 ; chyba ?
         cmp       cx,ss:[bp-12]            ; zbòv† mÇnà dat ?
         jae       EditCp15                 ; velikost dat je OK
         mov       ss:[bp-12],cx            ; omezen° velikosti dat

; ------ vytvo©en° m°sta v c°lovÇm souboru (nastav° nedefinovanò poáet ©†dkñ)

EditCp15:mov       cx,ss:[bp-12]            ; poáet bajtñ pro operaci
         mov       bx,ss:[bp+28]            ; á°slo bloku c°lovÇho souboru
         mov       si,ss:[bp+26]            ; offset v bloku c°lovÇho souboru
         mov       dx,ss:[bp+32]            ; á°slo segmentu c°lovÇho souboru
         mov       ss:[bp-18],bx            ; £schova á°sla bloku
         mov       ss:[bp-20],si            ; £schova offsetu
         call      EditIns                  ; vytvo©en° m°sta pro operaci
         jc        EditC138                 ; chyba operace
         jcxz      EditC138                 ; chyba ?
         mov       ss:[bp+26],si            ; novò offset v bloku c°lovÇho souboru
         mov       ss:[bp+28],bx            ; novò blok c°lovÇho souboru
         mov       ss:[bp-12],cx            ; novò poáet bajtñ pro operaci

; ------ poskytnut° c°lovÇho segmentu s normalizac° (p©iáte fale®nÇ ©†dky LF !)

         mov       bx,ss:[bp-18]            ; blok c°lovÇho souboru
         mov       si,ss:[bp-20]            ; offset v bloku c°lovÇho souboru
         call      EditNGet                 ; poskytnut° bloku
         jz        EditC138                 ; nejsou dal®° data nebo chyba
         mov       ss:[bp-20],si            ; novò offset v bloku
         mov       ss:[bp-18],bx            ; novò blok c°lovÇho souboru

; ------ naáten° zdrojovÇho segmentu

         mov       bx,ss:[bp+24]            ; blok zdrojovÇho souboru
         mov       si,ss:[bp+22]            ; offset v bloku zdrojovÇho souboru
         mov       dx,ss:[bp+30]            ; á°slo segmentu zdrojovÇho souboru
         call      EditNGet                 ; poskytnut° bloku
         jz        EditC138                 ; nejsou dal®° data nebo chyba
         mov       ss:[bp+22],si            ; novò offset v bloku
         mov       ss:[bp+24],bx            ; novò blok zdrojovÇho souboru

; ------ adresa okna zdrojovÇho souboru

         call      EditGetD                 ; adresa zdrojovÇho okna
         mov       ss:[bp-6],es             ; adresa segmentu zdrojovÇho souboru

; ------ adresa okna c°lovÇho souboru

         mov       dx,ss:[bp+32]            ; á°slo segmentu c°lovÇho souboru
         call      EditGetD                 ; adresa c°lovÇho okna
         mov       ss:[bp-4],es             ; adresa segmentu c°lovÇho souboru

; ------ ukazatel bloku c°lovÇho souboru

         mov       bx,ss:[bp-18]            ; á°slo c°lovÇho bloku
         shl       bx,1
         shl       bx,1
         shl       bx,1                     ; á°slo bloku * 8
         add       bx,EdiABlok              ; adresa popisovaáe bloku
         mov       ss:[bp-8],bx             ; £schova adresy popisovaáe

; ------ test, zda je c°lovò blok v pamàti

         mov       ax,es:[bx+EdiBlokM]      ; identifik†tor bloku v pamàti
         or        ax,ax                    ; je blok v pamàti ?
         jz        EditCop7                 ; chyba - nen° v pamàti
         and       ah,not bit15/bit8        ; nulov†n° p©°znaku modifikace
         mov       ss:[bp-22],ax            ; á°slo segmentu c°lovÇho bloku

; ------ adresa c°lovÇho bloku

         call      far ptr GetDat           ; adresa c°lovÇho bloku
         jc        EditCop8                 ; chyba
         mov       ss:[bp-14],es            ; adresa c°lovÇho bloku

; ------ ukazatel bloku zdrojovÇho souboru

         mov       bx,ss:[bp+24]            ; á°slo zdrojovÇho bloku
         shl       bx,1
         shl       bx,1
         shl       bx,1                     ; á°slo bloku * 8
         add       bx,EdiABlok              ; adresa popisovaáe bloku
         mov       ss:[bp-10],bx            ; £schova adresy popisovaáe

; ------ test, zda je zdrojovò blok v pamàti

         mov       es,ss:[bp-6]             ; adresa zdrojovÇho okna
         mov       ax,es:[bx+EdiBlokM]      ; identifik†tor bloku v pamàti
         or        ax,ax                    ; je blok v pamàti ?
         jz        EditCop7                 ; chyba - nen° v pamàti
         and       ah,not bit15/bit8        ; nulov†n° p©°znaku modifikace
         mov       ss:[bp-24],ax            ; á°slo segmentu zdrojovÇho bloku

; ------ adresa zdrojovÇho bloku

         call      far ptr GetDat           ; adresa zdrojovÇho bloku
         jc        EditCop8                 ; chyba
         mov       ss:[bp-16],es            ; adresa zdrojovÇho bloku

; ------ p©enesen° dat

         push      ds
         push      es
         pop       ds                       ; DS <- segment zdrojovÇho bloku
         mov       es,ss:[bp-14]            ; ES <- segment c°lovÇho bloku
         mov       si,ss:[bp+22]            ; SI <- offset v zdrojovÇm bloku
         mov       di,ss:[bp-20]            ; DI <- offset v c°lovÇm bloku
         mov       cx,ss:[bp-12]            ; CX <- poáet bajtñ k p©esunu
         cld
         shr       cx,1
         rep       movsw                    ; p©esun dat po slovech
         adc       cx,cx
         rep       movsb                    ; p©esun lichÇho bajtu
         pop       ds

; ------ oznaáen°, ëe ©†dky v c°lovÇm bloku jsou nedefinovanÇ

         mov       es,ss:[bp-4]             ; adresa segmentu c°lovÇho souboru
         mov       di,ss:[bp-8]             ; adresa popisovaáe c°lovÇho segmentu
         call      EditIDlL                 ; zru®en° ©†dkñ v popisovaái

; ------ operace OK - sn°ëen° poátu zbòvaj°c°ch bajtñ

         mov       ax,ss:[bp-12]            ; poáet zkop°rovanòch bajtñ
         sub       ss:[bp+18],ax            ; sn°ëen° á°taáe zbylòch bajtñ
         sbb       word ptr ss:[bp+18+2],0
         add       ss:[bp+22],ax            ; zvò®en° ukazatele zdrojovÇho bloku
         jmp       EditCop1                 ; dal®° blok dat

; ------ n†vrat registrñ

EditCop7:call      far ptr TestBEsc
         jc        EditCop8
         call      far ptr MemErr

EditCop8:stc                                ; p©°znak chyby
EditCop9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

EditCopy ENDP

; -----------------------------------------------------------------------------
;                                  EditDel
;                        Zru®en° £seku dat v souboru
;         Nastaven p©°znak modifikace bloku a opraven poáet ©†dkñ.
;              Neprov†d° se korekce kurzoru ani jinòch ukazatelñ.
; -----------------------------------------------------------------------------
; VSTUP: CX:AX=poëadovanò poáet bajtñ ke zru®en°
;        BX=poá†teán° á°slo bloku dat
;        SI=offset v bloku (nemus° bòt normovanò)
;        DX=á°slo okna (mus° bòt platnÇ !)
;        DS=datovò segment
; VùSTUP: CY=chyba operace (nap©. konec souboru - nic nezru®eno)
;         ES=nov† adresa definice okna
; -----------------------------------------------------------------------------
;˛
EditDel  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      si
         push      di
         push      bp

         xchg      ax,cx                    ; CX <- poëadovanò poáet bajtñ LOW
         xchg      ax,bp                    ; BP <- poëadovanò poáet bajtñ HIGH

; ------ adresa definice okna -> ES

         call      EditGetD                 ; adresa definice okna
         or        byte ptr es:[EdiParm],bit0 ; p©°znak modifikace souboru

; ------ kontrola, zda nen° podteáen° á°sla bloku

         or        bx,bx                    ; je podteáen° á°sla bloku ?
         jns       EditDl02                 ; nen° podteáen° á°sla bloku
         xor       bx,bx                    ; minim†ln° á°slo bloku

; ------ popisovaá bloku -> DI

EditDl02:mov       di,bx                    ; DI <- á°slo bloku
         shl       di,1
         shl       di,1
         shl       di,1                     ; á°slo bloku * 8
         add       di,EdiABlok              ; adresa popisovaáe bloku

; ------ korekce adresy, je-li offset z†pornò

EditDel1:cmp       si,BLOKTEST              ; je offset z†pornò ?
         jb        EditDel2                 ; nen° z†pornÇ á°slo
         or        bx,bx                    ; je jië blok 0 ?
         jz        EditDl12                 ; podteáen°
         dec       bx                       ; sn°ëen° á°sla bloku
         sub       di,EdiBlokS              ; posun adresy popisovaáe
         add       si,es:[di+EdiBlokN]      ; posun ukazatele v bloku
         jmp       short EditDel1           ; dal®° blok

; ------ korekce adresy, je-li offset za blokem

EditDl12:xor       si,si                    ; korekce offsetu na poá†tek
EditDel2:cmp       word ptr es:[EdiNBlok],0 ; je nàjakò blok ?
         je        EditDel3                 ; nen° ë†dnò blok
EditDl22:cmp       si,es:[di+EdiBlokN]      ; je ukazatel uvnit© bloku ?
         jb        EditDel3                 ; ukazatel je OK uvnit© bloku
         sub       si,es:[di+EdiBlokN]      ; posun offsetu
         add       di,EdiBlokS              ; posun adresy popisovaáe
         inc       bx                       ; zvò®en° á°sla bloku
         cmp       bx,es:[EdiNBlok]         ; je to je®tà platnò blok ?
         jb        EditDl22                 ; je to je®tà platnò blok

; ------ omezen° ukazatele na konec souboru

         dec       bx                       ; n†vrat á°sla bloku
         sub       di,EdiBlokS              ; n†vrat popisovaáe
         mov       si,es:[di+EdiBlokN]      ; n†vrat ukazatele v bloku

; ------ nalezen° konce ru®enòch dat -> BP:CX (=blok:offset), ES:AX (=ukazatel)

EditDel3:push      si                       ; offset poá†tku dat
         push      di                       ; ukazatel bloku zaá†tku dat
         push      bx                       ; blok poá†tku dat

         add       si,cx                    ; offset konce dat LOW
         adc       bp,0                     ; offset konce dat HIGH

EditDl32:or        bp,bp                    ; je velkò offset ?
         jnz       EditDl33                 ; je je®tà velkò offset
         cmp       si,es:[di+EdiBlokN]      ; je ukazatel uvnit© bloku ?
         jb        EditDl34                 ; ukazatel je OK uvnit© bloku

EditDl33:sub       si,es:[di+EdiBlokN]      ; posun offsetu
         sbb       bp,0                     ; p©enos HIGH
         add       di,EdiBlokS              ; posun adresy popisovaáe
         inc       bx                       ; zvò®en° á°sla bloku
         cmp       bx,es:[EdiNBlok]         ; je to je®tà platnò blok ?
         jb        EditDl32                 ; je to je®tà platnò blok

         sub       di,EdiBlokS              ; n†vrat ukazatele bloku
         dec       bx                       ; n†vrat á°sla bloku
         mov       si,es:[di+EdiBlokN]      ; omezen° ukazatele na konce bloku

EditDl34:mov       bp,bx                    ; BP <- á°slo bloku konce dat
         mov       cx,si                    ; CX <- offset konce dat
         xchg      ax,di                    ; AX <- ukazatel bloku v tabulce

         pop       bx
         pop       di
         pop       si

; ------ test, zda jsou oba bloky v pamàti a zda je zn†mò poáet ©†dkñ

         cmp       word ptr es:[di+EdiBlokM],0 ; je blok 1 v pamàti ?
         je        EditDl36                 ; blok 1 nen° v pamàti
         xchg      ax,di                    ; DI <- adresa bloku 2
         cmp       word ptr es:[di+EdiBlokM],0 ; je blok 2 v pamàti ?
         xchg      ax,di
         jne       EditDl46                 ; bloky jsou OK

; ------ naáten° prvn°ho bloku do pamàti

EditDl36:push      cx
         call      EditBGet                 ; naáten° prvn°ho bloku
         pop       cx
         jnc       EditDl38                 ; operace OK
EditDl37:stc                                ; p©°znak chyby
         jmp       EditDel9                 ; chyba

; ------ naáten° posledn°ho bloku

EditDl38:cmp       bx,bp                    ; je to stejnò blok ?
         je        EditDel4                 ; je to stejnò blok

         push      cx
         push      bx
         mov       bx,bp                    ; BX <- á°slo posledn°ho bloku
         call      EditBGet                 ; naáten° posledn°ho bloku
         pop       bx
         pop       cx
         jc        EditDel9                 ; chyba

; ------ n†vrat adresy okna

EditDel4:call      EditGetD                 ; poskytnut° adresy okna

; ------ prvn° i posledn° blok mus° bòt v pamàti

         cmp       word ptr es:[di+EdiBlokM],0 ; je prvn° blok v pamàti ?
         je        EditDl37                 ; nen° v pamàti - chyba
         xchg      ax,di                    ; DI <- offset posledn°ho bloku
         cmp       word ptr es:[di+EdiBlokM],0 ; je posledn° blok v pamàti ?
         xchg      ax,di                    ; n†vrat adresy prvn°ho bloku
         je        EditDl37                 ; nen° v pamàti - chyba

; ------ test, zda bude ru®en° dat pouze v jednom bloku

EditDl46:cmp       bx,bp                    ; je to stejnò blok ?
         je        EditDel7                 ; je to stejnò blok

; ------ zru®en° dat z konce prvn°ho bloku

         push      cx
         mov       cx,es:[di+EdiBlokN]      ; poáet bajtñ v prvn°m bloku
         call      EditDDD                  ; zru®en° zbytku dat v bloku
         pop       cx

; ------ p©esun dat z posledn°ho bloku do prvn°ho

         push      cx
         mov       bp,BLOKBLOK              ; velikost jednoho bloku
         sub       bp,es:[di+EdiBlokN]      ; volnÇ m°sto v bloku 1
         xchg      ax,di                    ; DI <- ukazatel posledn°ho bloku
         sub       cx,es:[di+EdiBlokN]      ; - zbylÇ bajty v bloku 2
         xchg      ax,di
         neg       cx                       ; zbylÇ bajty v bloku 2
         cmp       bp,cx                    ; je mÇnà dat k p©esunu ?
         jb        EditDel5                 ; nen° mÇnà dat k p©esunu
         mov       bp,cx                    ; BP <- omezen° dat k p©esunu
EditDel5:pop       cx                       ; zaá†tek zbytku dat v bloku 2
         call      EditDMD                  ; p©esun dat do prvn°ho bloku
         add       cx,bp                    ; zaá†tek dat v posledn°m bloku

; ------ zru®en° vnit©n°ch blokñ

         add       di,EdiBlokS              ; ukazatel druhÇho bloku
         sub       ax,di                    ; rozd°l adres ukazatelñ
EditDel6:sub       ax,EdiBlokS              ; sn°ëen° á°taáe blokñ
         jb        EditDl66                 ; jsou jië v®echny bloky
         call      EditBDel                 ; zru®en° bloku
         jmp       short EditDel6           ; dal®° blok

; ------ zru®en° zaá†tku dat v posledn°m bloku ES:DI

EditDl66:xor       si,si                    ; poá†tek dat v posledn°m bloku
EditDel7:call      EditDDD                  ; zru®en° dat v bloku

; ------ zru®en° bloku, pokud se vypr†zdnil

         cmp       word ptr es:[di+EdiBlokN],0 ; je blok pr†zdnò ?
         jne       EditDel8                 ; blok nen° pr†zdnò
         call      EditBDel                 ; zru®en° bloku
EditDel8:clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

EditDel9:call      EditGt0D                 ; adresa okna
         pop       bp
         pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

EditDel  ENDP

; -----------------------------------------------------------------------------
;                            EditBDel
; zru®en° popisovaáe bloku (s korekc° ukazatelñ dat) (posouv† datovÇ bloky !)
; -----------------------------------------------------------------------------
; VSTUP: DX=á°slo segmentu okna
;        DI=adresa v tabulce popisovaáñ (mus° bòt platnò blok !)
;        ES=adresa segmentu okna (adresa zñst†v† zachov†na OK)
;        DS=datovò segment
; -----------------------------------------------------------------------------

EditBDel PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

; ------ p©°prava á°sla bloku -> BX

         and       dh,not bit15/bit8        ; nulov†n° p©°znaku okna 2
         mov       bx,di                    ; BX <- offset definice bloku
         sub       bx,EdiABlok              ; offset v tabulce blokñ
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; BX <- á°slo bloku

; ------ korekce tabulky áetnosti blokñ

         mov       cx,ds:[EditBSN]          ; poáet blokñ v tabulce
         jcxz      EditBDl4                 ; nen° ë†dnò blok

         mov       si,offset EditBSTb       ; tabulka áetnosti
EditBDl1:cmp       ds:[si+2],dx             ; je to obsluhovanÇ okno ?
         jne       EditBDl3                 ; nen° to obsluhovanÇ okno
         cmp       ds:[si+4],bx             ; leë° nad ru®enòm blokem ?
         ja        EditBDl2                 ; leë° nad ru®enòm blokem
         jb        EditBDl3                 ; neleë° nad ru®enòm blokem

         mov       word ptr ds:[si+2],0     ; je to ru®enò blok - uvolnàn°
;         mov       ax,ds:[si]               ; á°slo segmentu bloku
;         cmp       ax,ds:[EditBLst]         ; je to posledn° blok ?
;         jne       EditBD12                 ; nen° to posledn° blok
;         mov       word ptr ds:[EditBLst],0 ; zru®en° popisovaáe posledn°ho bloku
;EditBD12:cmp       ax,ds:[EditBLsL]         ; je to p©edposledn° blok ?
;         jne       EditBDl3                 ; nen° to p©edposledn° blok
;         mov       word ptr ds:[EditBLsL],0 ; zru®en° p©edposledn°ho bloku
         jmp       short EditBDl3

EditBDl2:dec       word ptr ds:[si+4]       ; sn°ëen° á°sla bloku
EditBDl3:add       si,6                     ; adresa dal®°ho popisovaáe
         loop      EditBDl1                 ; dal®° blok

; ------ korekce á°sla bloku poá†teán°ho ©†dku

EditBDl4:mov       si,EdiW1                 ; popisovaá okna 1

EditBD42:cmp       es:[si+EdiBTop],bx       ; leë° nad ru®enòm blokem ?
         jb        EditBDl5                 ; neleë° nad ru®enòm blokem
         ja        EditBD44                 ; leë° nad ru®enòm blokem
         mov       word ptr es:[si+EdiOTop],0 ; offset na zaá†tek dal®°ho bloku
         jmp       short EditBDl5
EditBD44:dec       word ptr es:[si+EdiBTop] ; sn°ëen° á°sla bloku

; ------ korekce á°sla bloku s kurzorem

EditBDl5:cmp       es:[si+EdiBKur],bx       ; leë° nad ru®enòm blokem ?
         jb        EditBDl6                 ; neleë° nad ru®enòm blokem
         ja        EditBD54                 ; leë° nad ru®enòm blokem
         mov       word ptr es:[si+EdiOKur],0; offset na zaá†tek dal®°ho bloku
         jmp       short EditBDl6
EditBD54:dec       word ptr es:[si+EdiBKur]

EditBDl6:cmp       es:[si+EdiBBKur],bx
         jb        EditBD66
         ja        EditBD64
         mov       word ptr es:[si+EdiOfKur],0
         jmp       short EditBD66
EditBD64:dec       word ptr es:[si+EdiBBKur]

EditBD66:xor       si,EdiW2 XOR EdiW1       ; popisovaá dal®°ho okna
         cmp       si,EdiW2                 ; byla jië obà okna ?
         je        EditBD42                 ; korekce dal®°ho okna

; ------ zru®en° bloku z p©echodnÇho souboru

EditBDl7:mov       ax,es:[di+EdiBlokD]      ; identifik†tor bloku
         inc       ax                       ; je blok p©idàlen ?
         jz        EditBDl8                 ; blok nen° p©idàlen
         dec       ax
         or        ax,ax                    ; je to p©echodnò soubor ?
         jns       EditBDl8                 ; nen° to p©edchodnò soubor
         call      EditTRes                 ; uvolnàn° bloku souboru

; ------ sn°ëen° velikosti souboru

EditBDl8:mov       ax,es:[di+EdiBlokN]      ; poáet bajtñ v bloku
         sub       word ptr es:[EdiSize],ax ; sn°ëen° velikosti souboru
         sbb       word ptr es:[EdiSize+2],0

; ------ sn°ëen° poátu ©†dkñ souboru

         mov       ax,es:[di+EdiBlokL]      ; poáet ©†dkñ v bloku
         inc       ax                       ; je poáet ©†dkñ zn†mò ?
         jz        EditBDl9                 ; poáet ©†dkñ nen° zn†mò
         dec       ax                       ; poáet ©†dkñ v bloku
         sub       word ptr es:[EdiRadku],ax ; sn°ëen° poátu ©†dkñ celkem
         sbb       word ptr es:[EdiRadku+2],0

; ------ zru®en° definice bloku

EditBDl9:mov       cx,EdiBlokS              ; velikost popisovaáe
         xchg      ax,dx                    ; AX <- á°slo segmentu okna
         call      far ptr DelDat           ; zru®en° definice bloku
         dec       word ptr es:[EdiNBlok]   ; sn°ëen° poátu blokñ

; ------ n†vrat registrñ

         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

EditBDel ENDP

; -----------------------------------------------------------------------------
;        p©esun dat z posledn°ho bloku ru®enÇ oblasti do prvn°ho bloku
;                     Oba bloky mus° bòt v pamàti !
;                Nesm° p©etÇct velikost dat v prvn°m bloku !
;              Nemodifikuje ukazatele a data v druhÇm bloku !
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=definice prvn°ho bloku
;        ES:AX=definice posledn°ho bloku
;        CX=zaá†tek dat v druhÇm bloku
;        SI=konec dat v prvn°m bloku
;        ES=segment definice souboru
;        BP=poáet bajtñ k p©enosu z posledn°ho do prvn°ho bloku
; VùSTUP: CY=chyba (neplatnÇ bloky nebo byl BP=0)
; -----------------------------------------------------------------------------

EditDMD  PROC      NEAR

; ------ £schova registrñ 1

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      bp
         push      ds

; ------ £schova registrñ 2

         push      di
         push      es

; ------ adresa posledn°ho bloku -> DX

         xor       bx,bx                    ; á°taá znakñ LF

         push      di                       ; definice prvn°ho bloku
         xchg      ax,di                    ; DI <- definice posledn°ho bloku
         mov       ax,es:[di+EdiBlokM]      ; AX <- á°slo posledn°ho bloku
         and       ah,not bit15/bit8        ; nulov†n° p©°znaku modifikace
         call      far ptr GetSgAdr         ; adresa posledn°ho bloku -> DX
         pop       di
         jc        EditDMD7                 ; chyba (blok nen° v pamàti)

; ------ adresa prvn°ho bloku -> ES

         mov       ax,es:[di+EdiBlokM]      ; á°slo prvn°ho bloku
         and       ah,not bit15/bit8        ; nulov†n° p©°znaku modifikace
         call      far ptr GetDat           ; adresa prvn°ho bloku -> ES
         mov       ds,dx                    ; DS <- adresa posledn°ho bloku
         jc        EditDMD7                 ; chyba (blok nen° v pamàti)

; ------ p©esun dat mezi bloky (DS -> ES)

         mov       di,si                    ; DI <- konec dat v prvn°m bloku
         mov       si,cx                    ; SI <- zaá†tek dat v druhÇm bloku
         push      di
         mov       cx,bp                    ; CX <- poáet bajtñ k p©esunu
         shr       cx,1                     ; poáet slov k p©esunu
         cld
         rep       movsw                    ; p©esun dat po slovech
         adc       cx,cx                    ; lichò bajt
         rep       movsb                    ; p©esun lichÇho bajtu
         pop       di                       ; zaá†tek novòch dat v prvn°m bloku

; ------ spoáten° poátu p©esunutòch ©†dkñ do prvn°ho bloku

         mov       al,LF                    ; hledanò znak LF
         mov       cx,bp                    ; CX <- poáet bajtñ
EditDMD3:jcxz      EditDMD8                 ; nejsou dal®° data
         repne     scasb                    ; nalezen° znaku LF
         jne       EditDMD8                 ; nejsou dal®° data
         inc       bx                       ; zvò®en° á°taáe znakñ LF
         jmp       short EditDMD3           ; dal®° hled†n°

; ------ n†vrat registrñ 2

EditDMD7:xor       bp,bp                    ; BP <- 0 p©i chybà se nic nep©en†®°
EditDMD8:pop       es
         pop       di

; ------ oprava ukazatelñ v prvn°m bloku

         add       word ptr es:[EdiSize],bp ; zvò®en° velikosti souboru
         adc       word ptr es:[EdiSize+2],0

         add       es:[di+EdiBlokN],bp      ; zvò®en° poátu dat v prvn°m bloku
         cmp       word ptr es:[di+EdiBlokL],-1 ; poáet ©†dkñ v bloku je zn†mò ?
         je        EditDMD9                 ; poáet ©†dkñ nen° zn†mò
         add       es:[di+EdiBlokL],bx      ; zvò®en° á°taáe ©†dkñ
         add       word ptr es:[EdiRadku],bx ; zvò®en° celkovÇho poátu ©†dkñ
         adc       word ptr es:[EdiRadku+2],0

; ------ n†vrat registrñ 1

EditDMD9:cmp       bp,1                     ; byla chyba blokñ ? (-> CY = chyba)
         pop       ds
         pop       bp
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

EditDMD  ENDP

; -----------------------------------------------------------------------------
;        zru®en° dat v bloku (mus° bòt v pamàti !)
; -----------------------------------------------------------------------------
; VSTUP: DI=definice bloku
;        SI=zaá†tek dat ke zru®en°
;        CX=konec dat ke zru®en°
;        ES=adresa segmentu definice souboru
;        DS=datovò segment
; -----------------------------------------------------------------------------

EditDDD  PROC      NEAR

; ------ £schova registrñ 1

         push      ax
         push      bx
         push      cx
         push      si

; ------ £schova registrñ 2

         push      di
         push      es

; ------ p©°prava ukazatelñ

         xor       bx,bx                    ; p©ednastaven° - nejsou LF
         sub       cx,si                    ; poáet bajtñ ke zru®en°
         jbe       EditDDD8                 ; neru®° se nic
         mov       ax,es:[di+EdiBlokM]      ; á°slo bloku v pamàti
         and       ax,not bit15             ; zru®en° p©°znaku modifikace
         jz        EditDDD8                 ; chyba - nen° blok v pamàti
         sub       es:[di+EdiBlokN],cx      ; sn°ëen° poátu bajtñ v bloku
         sub       word ptr es:[EdiSize],cx ; sn°ëen° velikosti souboru
         sbb       word ptr es:[EdiSize+2],0
         or        byte ptr es:[di+EdiBlokM+1],bit15/bit8 ; p©°znak modifikace

; ------ adresa datovÇho bloku AX

         mov       di,es:[di+EdiBlokN]      ; novò poáet bajtñ v bloku
         call      far ptr GetDat           ; adresa bloku
         jc        EditDDD8                 ; chyba ?

; ------ zji®tàn° poátu zru®enòch p©elomñ ©†dkñ -> BX

         push      di                       ; novò konec dat v bufferu
         push      cx                       ; poáet bajtñ ke zru®en°

         cld
         mov       al,LF                    ; hledanò bajt LF
         mov       di,si                    ; DI <- adresa zaá†tku dat
EditDDD2:jcxz      EditDDD3                 ; nejsou dal®° data
         repne     scasb                    ; nalezen° znaku LF
         jne       EditDDD3                 ; nen° dal®° znak LF
         inc       bx                       ; zvò®en° á°taáe znakñ LF
         jmp       short EditDDD2           ; dal®° hled†n°

EditDDD3:pop       di                       ; DI <- poáet bajtñ ke zru®en°
         pop       cx                       ; CX <- novò konec dat v bufferu

; ------ vòpoáet ukazatelñ pro p©°sun dat

         xchg      si,di                    ; SI <- poáet bajtñ, DI<-zaá†tek dat
         sub       cx,di                    ; poáet bajtñ k p©°sunu
         jbe       EditDDD8                 ; nen° co p©isunout
         add       si,di                    ; adresa dat k p©°sunu

; ------ p©°sun zbytku dat

         push      ds
         push      es
         pop       ds                       ; DS <- segment bufferu
         cld
         shr       cx,1                     ; poáet slov k p©°sunu
         rep       movsw                    ; p©°sun dat po slovech
         adc       cx,cx                    ; lichò bajt
         rep       movsb                    ; p©°sun lichÇho bajtu
         pop       ds

; ------ n†vrat registrñ 2

EditDDD8:pop       es
         pop       di

; ------ aktualizace ukazatelñ (BX=poáet zru®enòch p©elomñ ©†dkñ)

         cmp       word ptr es:[di+EdiBlokL],-1 ; je poáet ©†dkñ zn†mò ?
         je        EditDDD9                 ; poáet ©†dkñ nen° zn†mò
         sub       es:[di+EdiBlokL],bx      ; sn°ëen° poátu ©†dkñ v bloku
         sub       word ptr es:[EdiRadku],bx ; sn°ëen° celkovÇho poátu ©†dkñ
         sbb       word ptr es:[EdiRadku+2],0

; ------ n†vrat registrñ 1

EditDDD9:pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

EditDDD  ENDP

; -----------------------------------------------------------------------------
;                            EditILn
;               vloëen° novòch ©†dkñ do souboru
; -----------------------------------------------------------------------------
; VSTUP: CX:AX=poëadovanò poáet novòch ©†dkñ (CR/LF)
;        BX=á°slo bloku ukazatele
;        DX=á°slo okna
;        SI=offset ukazatele v bloku
;        DS=datovò segment
; VùSTUP: CX:AX=zbylò poáet neuloëenòch novòch ©†dkñ
;         BX=novÇ á°slo bloku
;         SI=novò offset ukazatele v bloku
;         ES=adresa okna
;         CY=chyba
; -----------------------------------------------------------------------------

EditILn  PROC      NEAR

; ------ £schova registrñ

         push      di
         push      bp
         mov       bp,CR + HI*LF            ; slovo k vloëen°

; ------ test, zda jsou je®tà dal®° data (-> NC)

EditILn1:or        ax,ax                    ; jsou dal®° data ?
         jnz       EditILn2                 ; jsou dal®° data
         jcxz      EditILn9                 ; konec dat (zde je NC !)

; ------ £schova registrñ

EditILn2:push      ax
         push      cx

; ------ stanoven° velikosti poëadovanòch dat

         jcxz      EditILn3                 ; nen° v°ce neë 64 KB
EditIL22:mov       ax,BLOKBLOK/2            ; asi tak se poëaduje

; ------ vytvo©en° m°sta k vloëen° novòch ©†dkñ

EditILn3:shl       ax,1                     ; poáet vkl†danòch bajtñ
         jc        EditIL22                 ; omezen° poátu bajtñ
         cmp       bp,LF + CR*HI            ; byl lichò poáet bajtñ ?
         jne       EditIL42                 ; nebyl lichò poáet bajtñ
         dec       ax                       ; oprava - byla jië pñlka p©elomu
EditIL42:xchg      ax,cx                    ; CX <- poëadovanò poáet bajtñ
         call      EditIns                  ; vytvo©en° m°sta k vloëen° mezer
         jc        EditILn4                 ; chyba
         stc
         jcxz      EditILn4                 ; chyba

         cld
         xchg      ax,bp                    ; AX <- slovo k uloëen°
         shr       cx,1                     ; poáet vkl†danòch slov
         push      cx
         rep       stosw                    ; uloëen° ©†dkñ
         pop       cx
         jnc       EditIL44                 ; nen° lichò poáet bajtñ

         stosb                              ; uloëen° lichÇho bajtu
         xchg      ah,al                    ; z†màna po©ad° bajtñ
         cmp       al,CR                    ; byl dokonáen celò ©†dek ?
         jne       EditIL44                 ; nebyl dokonáen ©†dek
         inc       cx                       ; korekce poátu ©†dkñ

EditIL44:xchg      ax,bp                    ; BP <- p©°®t° vkl†danÇ slovo
         clc                                ; p©°znak operace OK

EditILn4:mov       di,cx                    ; DI <- poáet uloëenòch ©†dkñ

; ------ n†vrat registrñ

         pop       cx
         pop       ax
         jc        EditILn9                 ; chyba

; ------ sn°ëen° á°taáe zbylòch ©†dkñ

         sub       ax,di
         sbb       cx,0
         jmp       short EditILn1           ; dal®° blok

; ------ adresa okna

EditILn9:call      EditGt0D                 ; adresa okna

; ------ n†vrat registrñ

         pop       bp
         pop       di
         ret

EditILn  ENDP

; -----------------------------------------------------------------------------
;                            EditINul
;                    vloëen° nul do ©†dku
; -----------------------------------------------------------------------------
; VSTUP: CX:AX=poëadovanò poáet nul
;        BX=á°slo bloku ukazatele
;        DX=á°slo okna
;        SI=offset ukazatele v bloku
;        DS=datovò segment
; VùSTUP: CX:AX=zbylò poáet neuloëenòch nul
;         BX=novÇ á°slo bloku
;         SI=novò offset ukazatele v bloku
;         ES=adresa okna
;         CY=chyba
; -----------------------------------------------------------------------------

EditINul PROC      NEAR

; ------ £schova registrñ

         push      di

; ------ test, zda je®tà zbòvaj° dal®° nuly (-> NC)

EditINu1:or        ax,ax                    ; jsou dal®° data ?
         jnz       EditINu2                 ; jsou dal®° data
         jcxz      EditINu9                 ; konec dat (zde je NC !)

; ------ £schova registrñ

EditINu2:push      ax
         push      cx

; ------ stanoven° velikosti poëadovanòch dat

         jcxz      EditINu3                 ; nen° v°ce neë 64 KB
         mov       ax,BLOKBLOK              ; asi tak se poëaduje

; ------ vytvo©en° m°sta k vloëen° mezer

EditINu3:xchg      ax,cx                    ; CX <- poëadovanò poáet bajtñ
         call      EditIns                  ; vytvo©en° m°sta k vloëen° nul
         jc        EditINu4                 ; chyba
         stc
         jcxz      EditINu4

; ------ uloëen° nul

         cld
         xor       ax,ax                    ; nuly k vloëen°
         push      cx
         shr       cx,1
         rep       stosw                    ; uloëen° nul
         adc       cx,cx
         rep       stosb                    ; uloëen° lichÇ nuly
         pop       cx
;         clc                                ; p©°znak operace OK

EditINu4:mov       di,cx                    ; DI <- poáet uloëenòch nul

; ------ n†vrat registrñ

         pop       cx
         pop       ax
         jc        EditINu9                 ; chyba

; ------ sn°ëen° á°taáe zbylòch nul

         sub       ax,di
         sbb       cx,0
         jmp       short EditINu1           ; dal®° blok

; ------ adresa okna

EditINu9:call      EditGt0D                 ; adresa okna

; ------ n†vrat registrñ

         pop       di
         ret

EditINul ENDP

; -----------------------------------------------------------------------------
;                            EditISpc
;                    vloëen° mezer do ©†dku
; -----------------------------------------------------------------------------
; VSTUP: CX:AX=poëadovanò poáet mezer
;        BX=á°slo bloku ukazatele
;        DX=á°slo okna
;        SI=offset ukazatele v bloku
;        DS=datovò segment
; VùSTUP: CX:AX=zbylò poáet neuloëenòch mezer
;         BX=novÇ á°slo bloku
;         SI=novò offset ukazatele v bloku
;         ES=adresa okna
;         CY=chyba
; -----------------------------------------------------------------------------

EditISpc PROC      NEAR

; ------ £schova registrñ

         push      di

; ------ test, zda je®tà zbòvaj° dal®° mezery (-> NC)

EditISp1:or        ax,ax                    ; jsou dal®° data ?
         jnz       EditISp2                 ; jsou dal®° data
         jcxz      EditISp9                 ; konec dat (zde je NC !)

; ------ £schova registrñ

EditISp2:push      ax
         push      cx

; ------ stanoven° velikosti poëadovanòch dat

         jcxz      EditISp3                 ; nen° v°ce neë 64 KB
         mov       ax,BLOKBLOK              ; asi tak se poëaduje

; ------ vytvo©en° m°sta k vloëen° mezer

EditISp3:xchg      ax,cx                    ; CX <- poëadovanò poáet bajtñ
         call      EditIns                  ; vytvo©en° m°sta k vloëen° mezer
         jc        EditISp4                 ; chyba
         stc
         jcxz      EditISp4

; ------ uloëen° mezer

         cld
         mov       ax,"  "                  ; znak mezery k vloëen°
         push      cx
         shr       cx,1
         rep       stosw                    ; uloëen° mezery
         adc       cx,cx
         rep       stosb                    ; uloëen° lichÇ mezery
         pop       cx
;         clc                                ; p©°znak operace OK

EditISp4:mov       di,cx                    ; DI <- poáet uloëenòch mezer

; ------ n†vrat registrñ

         pop       cx
         pop       ax
         jc        EditISp9                 ; chyba

; ------ sn°ëen° á°taáe zbylòch mezer

         sub       ax,di
         sbb       cx,0
         jmp       short EditISp1           ; dal®° blok

; ------ adresa okna

EditISp9:call      EditGt0D                 ; adresa okna

; ------ n†vrat registrñ

         pop       di
         ret

EditISpc ENDP

; -----------------------------------------------------------------------------
;                                  EditIns
;        vytvo©en° m°sta v souboru pro vloëen° znakñ (jeden buffer)
;           Po uloëen° dat lze opakovat operaci pro dal®° data.
;                   Nastaven p©°znak modifikace bloku.
; -----------------------------------------------------------------------------
; VSTUP: BX=á°slo bloku
;        CX=poáet znakñ k vloëen° (nesm° bòt = 0)
;        DX=á°slo okna (mus° bòt platnÇ !)
;        SI=offset v bloku (nemus° bòt normovanò, ale nesm° bòt mimo soubor !)
;        DS=datovò segment
; VùSTUP: CY=chyba operace (registry nedefinov†ny !)
;         BX=á°slo bloku konce dat (lze pokraáovat dal®° operac°)
;         CX=poáet bajtñ, kterÇ lze vloëit (=vytvo©enÇ m°sto pro data)
;         SI=offset v bloku konce dat
;         ES:DI=adresa v bufferu k uloëen° dat
; -----------------------------------------------------------------------------
;˛
EditIns  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bp
         mov       bp,cx                    ; poëadovanò poáet bajtñ

; ------ adresa definice okna -> ES

         call      EditGetD                 ; adresa definice okna
         or        byte ptr es:[EdiParm],bit0 ; p©°znak modifikace souboru

; ------ kontrola, zda nen° podteáen° á°sla bloku

         or        bx,bx                    ; je podteáen° á°sla bloku ?
         jns       EditIn02                 ; nen° podteáen° á°sla bloku
         xor       bx,bx                    ; minim†ln° á°slo bloku

; ------ popisovaá bloku -> ES:DI

EditIn02:mov       di,bx                    ; DI <- á°slo bloku
         shl       di,1
         shl       di,1
         shl       di,1                     ; á°slo bloku * 8
         add       di,EdiABlok              ; adresa popisovaáe bloku

; ------ test, zda je nàjakò blok

         cmp       word ptr es:[EdiNBlok],0 ; je nàjakò blok ?
         je        EditIn21                 ; nen° blok - vytvo©en°

; ------ korekce adresy, je-li offset z†pornò

EditIns1:cmp       si,BLOKTEST              ; je z†pornò offset ?
         jb        EditIns2                 ; offset nen° z†pornò
         or        bx,bx                    ; je jië blok 0 ?
         jz        EditIn23                 ; podteáen°
         dec       bx                       ; sn°ëen° á°sla bloku
         sub       di,EdiBlokS              ; posun adresy popisovaáe
         add       si,es:[di+EdiBlokN]      ; posun ukazatele v bloku
         jmp       short EditIns1           ; dal®° blok

; ------ korekce adresy, je-li offset za blokem

EditIns2:cmp       si,es:[di+EdiBlokN]      ; je ukazatel uvnit© bloku ?
         jb        EditIns3                 ; ukazatel je OK uvnit© bloku
         sub       si,es:[di+EdiBlokN]      ; posun offsetu
         add       di,EdiBlokS              ; posun adresy popisovaáe
         inc       bx                       ; zvò®en° á°sla bloku
         cmp       bx,es:[EdiNBlok]         ; je to je®tà platnò blok ?
         jb        EditIns2                 ; je to je®tà platnò blok

; ------ nen°-li posledn° blok plnò, mñëe se pouë°t

         cmp       word ptr es:[di+EdiBlokN-EdiBlokS],BLOKBLOK ; je blok plnò ?
         jae       EditIn22                 ; blok je plnò - mus° bòt novò
         dec       bx                       ; n†vrat á°sla posledn°ho bloku
         sub       di,EdiBlokS              ; n†vrat popisovaáe posledn°ho bloku
         mov       si,es:[di+EdiBlokN]      ; n†vrat offsetu na konec dat
         jmp       short EditIns3

; ------ vytvo©en° novÇho bloku ES:DI/BX (ukazatel je za daty)

EditIn21:xor       bx,bx                    ; blok 0
         mov       di,EdiABlok              ; adresa popisovaáe bloku

EditIn22:call      EditBNew                 ; vytvo©en° novÇho bloku
         jc        EditIn54                 ; chyba pamàti
EditIn23:xor       si,si                    ; ukazatel na zaá†tek bloku


; ====== Test, zda je pot©eba odsunout nàjak† data z bloku 1 do bloku 2

; ------ kontrola volnÇho m°sta v bloku BX:SI, ES:DI -> BP=bajtñ k odsunu

EditIns3:mov       ax,BLOKBLOK              ; velikost bloku
         sub       ax,es:[di+EdiBlokN]      ; AX <- volnÇ m°sto v bloku
         sub       bp,ax                    ; zbòvaj°c° pot©ebnÇ volnÇ m°sto
         jbe       EditIns7                 ; volnÇ m°sto vyhovuje OK
         cmp       si,es:[di+EdiBlokN]      ; jsou data za ukazatelem ?
         jae       EditIns7                 ; nejsou data k odsunu

; ------ test, zda je volnÇ m°sto v n†sleduj°c°m bloku

         inc       bx                       ; á°slo dal®°ho bloku
         cmp       bx,es:[EdiNBlok]         ; je to posledn° blok ?
         dec       bx                       ; n†vrat á°sla bloku
         jnc       EditIns4                 ; je to posledn° blok
         cmp       word ptr es:[di+EdiBlokS+EdiBlokN],BLOKBLOK ; dal®° blok OK ?
         jb        EditIns5                 ; dal®° blok m† volnÇ m°sto

; ------ vytvo©en° novÇho datovÇho bloku za blokem BX

EditIns4:add       di,EdiBlokS              ; adresa dal®°ho bloku
         inc       bx                       ; zvò®en° ukazatele bloku
         call      EditBNew                 ; vytvo©en° novÇho bloku
         jc        EditIn54                 ; chyba pamàti
         dec       bx                       ; n†vrat ukazatele bloku
         sub       di,EdiBlokS              ; n†vrat adresy aktivn°ho bloku

; ------ test, zda jsou oba bloky v pamàti a zda je zn†mò poáet ©†dkñ

EditIns5:xor       ax,ax                    ; AX <- 0
         cmp       es:[di+EdiBlokM],ax      ; je blok 1 v pamàti ?
         je        EditIn52                 ; blok 1 nen° v pamàti
         cmp       es:[di+EdiBlokS+EdiBlokM],ax ; je blok 2 v pamàti ?
         je        EditIn52                 ; blok 2 nen° v pamàti
         dec       ax                       ; AX <- -1
         cmp       es:[di+EdiBlokL],ax      ; je poáet ©†dkñ bloku 1 zn†mò ?
         je        EditIn52                 ; nen° zn†mò
         cmp       es:[di+EdiBlokS+EdiBlokL],ax ; je poáet ©†dkñ bloku 2 zn†mò ?
         jne       EditIn56                 ; bloky jsou OK

; ------ poskytnut° adresy n†sleduj°c°ho bloku (pro naáten° do pamàti)

EditIn52:inc       bx                       ; zvò®en° ukazatele á°sla bloku
         push      cx
         call      EditBGet                 ; poskytnut° dal®°ho bloku
         pop       cx
         dec       bx                       ; n†vrat á°sla aktu†ln°ho bloku
EditIn54:jc        EditIn84                 ; nàjak† chyba

; ------ poskytnut° adresy aktivn°ho bloku (pro naáten° do pamàti)

         push      cx
         call      EditBGet                 ; poskytnut° adresy bloku
         pop       cx
         jc        EditIn84                 ; chyba

; ------ n†vrat adresy okna -> ES

         call      EditGetD                 ; poskytnut° adresy okna

; ------ oba datovÇ bloky mus° bòt v pamàti

         xor       ax,ax
         cmp       es:[di+EdiBlokM],ax      ; je to platnò blok ?
         je        EditIns7                 ; chyba - asi m†lo pamàti
         cmp       es:[di+EdiBlokS+EdiBlokM],ax
         je        EditIns7                 ; chyba - asi m†lo pamàti


; ====== Odsun á†sti dat za ukazatelem do n†sleduj°c°ho bloku
;        (oba bloky mus° bòt p©ipraveny v pamàti !)
;        ES:DI=popisovaá, BX:SI=ukazatel dat, BP (CX)=poëadovanò poáet bajtñ

; ------ stanoven° poátu bajtñ k odsunu mezi bloky -> BP

EditIn56:mov       ax,BLOKBLOK              ; velikost bloku
         sub       ax,es:[di+EdiBlokS+EdiBlokN] ; volnÇ m°sto v druhÇm bloku
         cmp       ax,bp                    ; poëaduje se v°ce volnÇho m°sta ?
         jae       EditIns6                 ; volnÇ m°sto je OK
         xchg      ax,bp                    ; BP <- omezen° poátu bajtñ

EditIns6:mov       ax,es:[di+EdiBlokN]      ; poáet bajtñ v prvn°m bloku
         sub       ax,si                    ; poáet bajtñ za ukazatelem
         cmp       ax,bp                    ; je co odsunout ?
         jae       EditIn62                 ; zbòv† v°ce bajtñ neë pot©eba
         xchg      ax,bp                    ; BP <- omezen° poátu bajtñ k odsunu
EditIn62:or        bp,bp                    ; jsou nàjak† data k odsunu ?
         jz        EditIns7                 ; nen° nic k odsunu

; ------ p©esun dat z bufferu 1 do bufferu 2

         call      EditIIM                  ; p©esun dat z bufferu 1 do 2


; ====== vytvo©en° m°sta v aktu†ln°m bloku (je vytvo©eno m°sto na konci bloku)
;        ES:DI=popisovaá, BX:SI=ukazatel dat, CX=poëadovanò poáet bajtñ

; ------ omezen° velikosti vkl†danòch dat -> CX

EditIns7:mov       ax,BLOKBLOK              ; velikost bloku
         sub       ax,es:[di+EdiBlokN]      ; volnÇ m°sto v bloku
         cmp       ax,cx                    ; poëaduje se v°ce dat ?
         jae       EditIns8                 ; velikost poëadavku je OK
         xchg      ax,cx                    ; CX <- omezen° velikosti dat

; ------ adresa aktu†ln°ho bloku -> ES (a jeho p©°p. um°stàn° do pamàti)

EditIns8:push      cx                       ; poáet bajtñ k vloëen°
         call      EditBGet                 ; adresa aktu†ln°ho bloku
         mov       di,cx                    ; poáet bajtñ = adresa konce
         pop       cx
EditIn84:jc        EditIns9                 ; nàjak† chyba
         stc
         jcxz      EditIns9                 ; nàjak† chyba

; ------ odsun zbytku dat v bloku (CX=bajtñ k vloëen°, ES:SI=adresa, DI=konec)

         call      EditIII                  ; odsun zbytku dat v bufferu
                                            ;  -> ES:DI=adresa volnÇho m°sta
                                            ;  -> BX:SI=novò ukazatel
                                            ;  -> CX=poáet bajtñ

; ------ korekce ukazatelñ souboru

         push      es
         push      di

         call      EditGetD                 ; adresa definice okna
         add       word ptr es:[EdiSize],cx ; zvò®en° velikosti souboru
         adc       word ptr es:[EdiSize+2],0

         mov       di,bx                    ; á°slo bloku
         shl       di,1
         shl       di,1
         shl       di,1
         add       di,EdiABlok              ; adresa popisovaáe
         or        byte ptr es:[di+EdiBlokM+1],bit15/bit8 ; modifikace bloku 1
         add       word ptr es:[di+EdiBlokN],cx ; zvò®en° poátu bajtñ bloku 1
         call      EditIDlL                 ; zru®en° ©†dkñ bloku 1

         pop       di
         pop       es
         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

EditIns9:pop       bp
         pop       ax
         ret

EditIns  ENDP

; -----------------------------------------------------------------------------
;                            EditBNew
;                vytvo©en° novÇho popisovaáe bloku
; -----------------------------------------------------------------------------
; VSTUP: DX=á°slo segmentu okna
;        DI=adresa v tabulce popisovaáñ
;        BX=á°slo bloku
;        ES=adresa segmentu okna
;        DS=datovò segment
; VùSTUP: CY=chyba pamàti
; -----------------------------------------------------------------------------

EditBNew PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      di

; ------ vytvo©en° m°sta k vloëen° popisovaáe

         mov       cx,EdiBlokS              ; velikost popisovaáe
         xchg      ax,dx                    ; AX <- á°slo segmentu okna
         and       ah,not bit15/bit8        ; nulov†n° p©°znaku okna 2
         call      far ptr InsDat           ; vytvo©en° m°sta v bloku
         xchg      ax,dx                    ; DX <- á°slo segmentu okna
         jnc       EditBNw0                 ; operace OK
         jmp       EditBNw9                 ; nedostatek pamàti

; ------ inicializace ukazatelñ

EditBNw0:xor       ax,ax                    ; AX <- 0
         mov       es:[di+EdiBlokM],ax      ; nen° blok v pamàti
         mov       es:[di+EdiBlokN],ax      ; nejsou data v bloku
         dec       ax                       ; AX = -1
         mov       es:[di+EdiBlokD],ax      ; nen° blok na disku
         mov       es:[di+EdiBlokL],ax      ; poáet ©†dkñ je nezn†mò
         inc       word ptr es:[EdiNBlok]   ; zvò®en° á°taáe blokñ v tabulce

; ------ korekce tabulky áetnosti blokñ

         mov       ax,bx                    ; AX <- á°slo bloku v souboru
EditBNw1:mov       cx,ds:[EditBSN]          ; poáet blokñ v tabulce
         jcxz      EditBNw4                 ; nen° ë†dnò blok
         mov       di,offset EditBSTb       ; tabulka áetnosti
EditBNw2:cmp       ds:[di+2],dx             ; je to obsluhovanÇ okno ?
         jne       EditBNw3                 ; nen° to obsluhovanÇ okno
         cmp       ds:[di+4],ax             ; leë° nad vloëenòm blokem ?
         jb        EditBNw3                 ; neleë° nad vloëenòm blokem
         inc       word ptr ds:[di+4]       ; zvò®en° á°sla bloku
EditBNw3:add       di,6                     ; adresa dal®°ho popisovaáe
         loop      EditBNw2                 ; dal®° blok

; ------ pro prvn° blok nen° co odsouvat

EditBNw4:cmp       word ptr es:[EdiNBlok],1 ; je to prvn° blok ?
         je        EditBNw8                 ; je to prvn° blok

; ------ korekce á°sla bloku poá†teán°ho ©†dku - okno 1

         cmp       es:[EdiW1+EdiBTop],ax
         jb        EditBNw5
         inc       word ptr es:[EdiW1+EdiBTop]

; ------ korekce á°sla bloku s kurzorem - okno 1

EditBNw5:cmp       es:[EdiW1+EdiBKur],ax
         jb        EditBNw6
         inc       word ptr es:[EdiW1+EdiBKur]
EditBNw6:cmp       es:[EdiW1+EdiBBKur],ax
         jb        EditBNw7
         inc       word ptr es:[EdiW1+EdiBBKur]

; ------ korekce á°sla bloku poá†teán°ho ©†dku - okno 2

EditBNw7:cmp       es:[EdiW2+EdiBTop],ax
         jb        EdiBNw72
         inc       word ptr es:[EdiW2+EdiBTop]

; ------ korekce á°sla bloku s kurzorem - okno 2

EdiBNw72:cmp       es:[EdiW2+EdiBKur],ax
         jb        EdiBNw74
         inc       word ptr es:[EdiW2+EdiBKur]
EdiBNw74:cmp       es:[EdiW2+EdiBBKur],ax
         jb        EditBNw8
         inc       word ptr es:[EdiW2+EdiBBKur]

EditBNw8:clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

EditBNw9:pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

EditBNew ENDP

; -----------------------------------------------------------------------------
;                                EditIIM
;            P©esun dat z konce bufferu 1 na zaá†tek bufferu 2
;               V bufferu 2 mus° bòt m°sto k p©esunu dat !
;                     Oba bloky mus° bòt v pamàti !
;                Poáet ©†dkñ v obou bloc°ch mus° bòt zn†mò !
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=popisovaá bloku 1 (n†sleduje popisovaá bloku 2)
;        BP=poáet bajtñ k odsunu z bloku 1 do bloku 2
;        DS=datovò segment
; -----------------------------------------------------------------------------

EditIIM  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      es
         push      ds

; ------ adresa a poáet bajtñ v bufferu 1 -> DX, [SP]

         push      word ptr es:[di+EdiBlokN] ; poáet bajtñ v bufferu 1

         mov       ax,es:[di+EdiBlokM]      ; á°slo bufferu 1
         and       ah,not bit15/bit8        ; nulov†n° p©°znaku modifikace
         call      far ptr GetSgAdr         ; adresa bufferu 1 -> DX
         jc        EditIIM2                 ; chyba ?

; ------ adresa a poáet bajtñ v bufferu 2 -> ES, DI

         mov       ax,es:[di+EdiBlokS+EdiBlokM] ; á°slo bufferu 2
         and       ah,not bit15/bit8        ; nulov†n° p©°znaku modifikace
         mov       di,es:[di+EdiBlokS+EdiBlokN] ; poáet bajtñ v bufferu 2
         call      far ptr GetDat           ; adresa bufferu 2 -> ES
         jc        EditIIM2

; ------ odsun dat v bufferu 2 (adresa ES, konec DI)

         mov       cx,bp                    ; CX <- poëadovanÇ m°sto
         xor       si,si                    ; poá†tek dat v bufferu 2
         call      EditIII                  ; odsun dat v bufferu 2

; ------ p©esun dat z bufferu 1 do bufferu 2 (je CLD !)

         pop       si                       ; poáet bajtñ v bufferu 1

         mov       ds,dx                    ; DS <- adresa bufferu 1
         sub       si,cx                    ; zaá†tek dat k odsunu
         shr       cx,1                     ; poáet slov k p©esunu
         rep       movsw                    ; odsun dat po slovech
         adc       cx,cx
         rep       movsb                    ; odsun lichÇho bajtu dat

; ------ spoáten° p©esunutÇho poátu ©†dkñ LF -> DX (je CLD !)

         xor       di,di                    ; zaá†tek p©esunutòch dat
         xor       dx,dx                    ; á°taá ©†dkñ
         mov       al,LF                    ; hledanò znak LF
         mov       cx,bp                    ; poáet p©enesenòch bajtñ
EditIIM1:jcxz      EditIIM3                 ; nen° dal®° znak
         repne     scasb                    ; nalezen° znaku LF
         jne       EditIIM3                 ; konec hled†n° - znak nenalezen
         inc       dx                       ; zvò®en° á°taáe znakñ LF
         jmp       short EditIIM1           ; pokraáov†n° v hled†n°

; ------ n†vrat registrñ p©i chybà

EditIIM2:pop       si                       ; zru®en° poátu bajtñ v bufferu 1

         pop       ds
         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

; ------ n†vrat registrñ (DX=poáet p©esunutòch ©†dkñ)

EditIIM3:pop       ds
         pop       es
         pop       di
         pop       si
         sub       es:[di+EdiBlokL],dx      ; sn°ëen° poátu ©†dkñ v bloku 1
         add       es:[di+EdiBlokS+EdiBlokL],dx ; zvò®en° poátu ©†dkñ v bloku 2
         pop       dx
         pop       cx
         pop       ax

; ------ korekce ukazatelñ v bloc°ch

         or        byte ptr es:[di+EdiBlokM+1],bit15/bit8 ; modifikace bloku 1
         or        byte ptr es:[di+EdiBlokM+EdiBlokS+1],bit15/bit8 ; modif.bl.2
         sub       es:[di+EdiBlokN],bp      ; sn°ëen° dat v bloku 1
         add       es:[di+EdiBlokS+EdiBlokN],bp ; zvò®en° dat v bloku 2
         ret

EditIIM  ENDP

; -----------------------------------------------------------------------------
;        zru®en° á°taáe ©†dkñ popisovaáe ES:DI
; -----------------------------------------------------------------------------

EditIDlL PROC      NEAR

         push      ax
         mov       ax,es:[di+EdiBlokL]      ; poáet p©elomñ ©†dkñ
         inc       ax                       ; jsou ©†dky zn†mÇ ?
         jz        EditIDL9                 ; ©†dky nejsou zn†mÇ
         dec       ax
         sub       word ptr es:[EdiRadku],ax ; zru®en° z á°taáe ©†dkñ
         sbb       word ptr es:[EdiRadku+2],0
         mov       word ptr es:[di+EdiBlokL],-1 ; p©°znak nezn†mÇho poátu ©†dkñ
EditIDL9:pop       ax
         ret

EditIDlL ENDP

; -----------------------------------------------------------------------------
;        odsun zbytku dat v bloku (nesm° p©etÇct konec bufferu !)
; -----------------------------------------------------------------------------
; VSTUP: ES=segment bufferu
;        SI=zaá†tek dat k odsunu (nesm° p©etÇct za konec dat !)
;        DI=konec dat v bufferu
;        CX=poáet bajtñ k vloëen°
; VùSTUP: DI=zaá†tek vytvo©enÇho volnÇho m°sta (=pñvodn° registr SI)
;         SI=zaá†tek odsunutòch dat (posunutò ukazatel dat)
;         CLD smàr nahoru
; -----------------------------------------------------------------------------

EditIII  PROC      NEAR

         push      ax
         push      cx
         push      ds

         push      es
         pop       ds                       ; DS <- segment bufferu

         xchg      ax,cx                    ; AX <- poáet bajtñ k vloëen°
         mov       cx,di                    ; adresa starÇho konce dat
         sub       cx,si                    ; poáet bajtñ k odsunu
         dec       di
         dec       di                       ; ukazatel na posledn° slovo dat
         mov       si,di                    ; SI <- posledn° slovo dat
         add       di,ax                    ; nov† koncov† adresa

         std                                ; smàr dolñ
         shr       cx,1                     ; poáet slov k odsunu
         rep       movsw                    ; p©esun dat po slovech
         adc       cx,cx                    ; lichò bajt
         inc       si                       ; ukazatel na posledn° bajt dat
         inc       di
         rep       movsb                    ; odsun lichÇho bajtu dat

         inc       si                       ; posledn° uvol§ovanò bajt
         inc       di                       ; n†vrat na posledn° novò bajt
         xchg      si,di                    ; SI=novò offset, DI=ukl†dac° adresa

         pop       ds
         pop       cx                       ; poáet bajtñ k vloëen°
         pop       ax
         cld
         ret

EditIII  ENDP


; -----------------------------------------------------------------------------
;                                EditGtPO
;                pozice na ©†dku s omezen°m na konec ©†dku
; -----------------------------------------------------------------------------
; VSTUP: CX:AX=poëadovan† pozice v ©†dku
;        SI=offset zaá†tku ©†dku v bloku
;        BX=relativn° á°slo bloku
;        DX=á°slo okna (bit 15: 1=je okno 2)
;        DS=datovò segment
; VùSTUP: SI=offset nalezenÇ pozice (normalizov†no a omezeno na konec ©†dku)
;         BX=blok s nalezenou pozic°
;         ES=adresa definice okna
;         CY=chyba
; -----------------------------------------------------------------------------

EditGtPO PROC      NEAR

; ------ £schova registrñ

         push      di

; ------ nalezen° pozice CX:AX na ©†dku BX:SI -> BX:SI

         call      EditGetP                 ; adresa pozice zaá†tku bloku
         jc        EditGPO9                 ; chyba operace

; ------ korekce na konec ©†dku, je-li pozice bloku za koncem ©†dku

         or        di,di                    ; je konec ©†dku ?
         jns       EditGPO8                 ; nen° konec ©†dku
         inc       di                       ; -1 = konec souboru ?
         jz        EditGPO8                 ; je konec souboru
         dec       si                       ; n†vrat na konec ©†dku LF
         inc       di                       ; -2 = konec LF ?
         jz        EditGPO8                 ; je konec LF
         dec       si                       ; n†vrat na konec ©†dku 2 bajty

; ------ normalizace ukazatele

EditGPO8:or        si,si                    ; je ukazatel OK ?
         jns       EditGPO9                 ; ukazatel je OK
         push      cx
         call      EditNGet                 ; normalizace ukazatele
         call      EditGt0D                 ; obnoven° adresy okna -> ES
         pop       cx

; ------ n†vrat registrñ

EditGPO9:pop       di
         ret

EditGtPO ENDP

; -----------------------------------------------------------------------------
;                                EditGetP
;                        nalezen° pozice v ©†dku
; -----------------------------------------------------------------------------
; VSTUP: CX:AX=poëadovan† pozice v ©†dku
;        SI=offset zaá†tku ©†dku v bloku
;        BX=relativn° á°slo bloku
;        DX=á°slo okna (bit 15: 1=je okno 2)
;        DS=datovò segment
; VùSTUP: SI=offset nalezenÇ pozice v bloku (normalizov†no)
;         DI=p©°znaky (0=text, 1 aë 7=p©esah tabul†toru, -1=konec souboru/chyba,
;                      -2=LF, -3=LF/CR, -4=CR/LF)
;         BX=blok s nalezenou pozic°
;         ES=adresa definice okna
;         CY=chyba
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) poëadovan† pozice HIGH
;                   SS:[BP-4] (2) poëadovan† pozice LOW
;                   SS:[BP-5] (1) parametry okna
;                                    bit 1: 1=HEX m¢d ƒƒƒƒƒƒƒø0=textovò m¢d
;                                    bit 2: 1=bin†rn° m¢d ƒƒƒŸ
;                                    bit 7: 1=TAB je jako bàënò znak
; -----------------------------------------------------------------------------

EditGetP PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      bp
         mov       bp,sp
         sub       sp,6

; ------ £schova poëadovanÇ pozice

         mov       ss:[bp-2],cx             ; poëadovan† pozice HIGH
         mov       ss:[bp-4],ax             ; poëadovan† pozice LOW

; ------ adresa okna

         call      EditGetD                 ; adresa definice okna

; ------ parametry okna

         mov       di,EdiW1                 ; okno 1
         or        dx,dx                    ; je okno 2 ?
         jns       EditGtP0                 ; je okno 1
         mov       di,EdiW2                 ; okno 2
EditGtP0:mov       al,es:[di+EdiParm1]      ; parametry okna
         mov       ss:[bp-5],al             ; parametry okna

; ------ p©°prava ukazatele pozice -> DI:AX

         xor       ax,ax                    ; AX <- 0 ukazatel pozice LOW
         xor       di,di                    ; DI <- 0 ukazatel pozice HIGH
         jmp       short EditGP16           ; nebude zrychlenÇ hled†n°

; ------ test, zda mñëe bòt zrychlenÇ hled†n° pozice (ukazatele BX:SI/CX)

EditGtP1:test      byte ptr ss:[bp-5],bit7  ; je TAB jako bàënò znak ?
         jz        EditGP16                 ; TAB nen° bàënò znak
         test      byte ptr ss:[bp-5],bit1+bit2 ; je textovò m¢d ?
         jnz       EditGP16                 ; nen° textovò m¢d

; ------ normalizace ukazatelñ (je p©eteáen° p©es konec bufferu CX !)

EditGP11:sub       si,cx                    ; p©eteáen° do dal®°ho bufferu
         inc       bx                       ; zvò®en° á°sla bloku

; ------ adresa okna -> ES

         call      EditGetD                 ; adresa definice okna

; ------ kontrola, zda je je®tà platnÇ á°slo bloku

         cmp       bx,es:[EdiNBlok]         ; je platnÇ á°slo bloku ?
         jae       EditGP15                 ; je p©eteáen° za konec souboru

; ------ offset definice okna -> CX

         mov       cx,bx                    ; CX <- á°slo bloku
         shl       cx,1
         shl       cx,1
         shl       cx,1                     ; á°slo bloku * 8
         add       cx,EdiABlok              ; adresa definice bloku

; ------ test, zda je v bloku poáet ©†dkñ = 0 (-1=nezn†mÇ) -> CX=poáet bajtñ
; Je testov†n i n†sleduj°c° buffer, aby se zastavilo zrychlenÇ vyhled†v†n°
; d©°ve pro p©°pad, ëe by byl LF na zaá†tku dal®°ho bufferu (navr†til by se
; p©°znak LF nam°sto CR/LF). Mohlo by se je®tà st†t, ëe v tomto bloku bude
; poáet bajtñ = 0 a souáasnà dal®° blok zaá°nat LF, to je m†lo pravdàpodobnÇ.

         xchg      bx,cx                    ; BX <- adresa definice bloku
         cmp       word ptr es:[bx+EdiBlokL+EdiBlokS],0 ; jsou v dal®°m bufferu ©†dky ?
         jne       EditGP12                 ; budou ©†dky
         cmp       word ptr es:[bx+EdiBlokL],0 ; jsou v bloku ©†dky ?
         mov       bx,es:[bx+EdiBlokN]      ; BX <- poáet bajtñ v bloku
EditGP12:xchg      bx,cx                    ; n†vrat registrñ
         jne       EditGP16                 ; v bloku nen° poáet ©†dkñ = 0

; ------ normalizace ukazatele

         cmp       si,cx                    ; je ukazatel uvnit© bloku ?
         jae       EditGP11                 ; posun ukazatele bloku
         sub       cx,si                    ; zbytek dat do konce bloku

; ------ posun pozice a ukazatelñ

         add       si,cx                    ; posun adresy v bloku na konec
         add       ax,cx                    ; posun ukazatele pozice LOW
         adc       di,0                     ; posun ukazatele pozice HIGH
         mov       cx,si                    ; CX <- poáet bajtñ v bloku

; ------ test, zda je jië poëadovan† pozice

         cmp       di,ss:[bp-2]             ; poëadovan† pozice HIGH
         jne       EditGP14
         cmp       ax,ss:[bp-4]             ; poëadovan† pozice LOW
EditGP14:jb        EditGP11                 ; nen° dosaëeno poëadovanÇ pozice

; ------ oprava ukazatelñ

         sub       ax,ss:[bp-4]             ; p©esah pozice
         sub       si,ax                    ; oprava offsetu na pozici
         xor       di,di                    ; nen° p©esah
         jmp       EditGP77                 ; naáten° bufferu

; ------ n†vrat á°sla bloku p©i p©eteáen° konce

EditGP15:add       si,cx                    ; n†vrat offsetu
         dec       bx                       ; n†vrat á°sla bloku

; ------ adresa bloku BX:SI -> ES:SI/BX/CX

EditGP16:call      EditNGet                 ; poskytnut° adresy dal®°ho bloku
         jz        EditGtP8                 ; chyba nebo konec souboru

; ------ test, zda je dosaëeno poëadovanÇ pozice

EditGtP2:cmp       di,ss:[bp-2]             ; poëadovan† pozice HIGH
         jne       EdiGtP22
         cmp       ax,ss:[bp-4]             ; poëadovan† pozice LOW
EdiGtP22:jae       EditGtP4                 ; dosaëeno poëadovanÇ pozice

; ------ test, zda je p©ipraven dal®° znak

         cmp       si,cx                    ; je p©ipraven dal®° znak ?
         jae       EditGtP1                 ; nen° p©ipraven dal®° znak
         inc       si                       ; zvò®en° ukazatele dat

; ------ test, zda je bin†rn°/HEX m¢d

         test      byte ptr ss:[bp-5],bit1+bit2 ; je bin†rn°/HEX m¢d ?
         jnz       EditGtP3                 ; je bin†rn°/HEX m¢d

; ------ test, zda je konec ©†dku LF

         cmp       byte ptr es:[si-1],LF    ; je konec ©†dku LF ?
         je        EditGtP5                 ; je konec ©†dku LF

; ------ test, zda je znak CR

         cmp       byte ptr es:[si-1],CR    ; je znak CR ?
         je        EditGtP6                 ; je znak CR

; ------ test, zda je znak TAB

         cmp       byte ptr es:[si-1],TAB   ; je znak TAB ?
         je        EdiGtP42                 ; je znak TAB

; ------ je bàënò znak - zvò®en° pozice

EditGtP3:add       ax,1                     ; zvò®en° ukazatele pozice LOW
         adc       di,0                     ; p©enos HIGH
         jmp       short EditGtP2           ; test dal®°ho znaku

; ------ dosaëeno poëadovanÇ pozice -> DI p©esah

EditGtP4:sub       ax,ss:[bp-4]             ; p©esah
         xchg      ax,di                    ; DI <- p©esah
         jmp       short EditGP76           ; normalizace

; ------ je znak TAB

EdiGtP42:test      byte ptr ss:[bp-5],bit7  ; je tabul†tor bàënò znak ?
         jnz       EditGtP3                 ; tabul†tor je bàënò znak
         add       ax,8                     ; zvò®en° ukazatele pozice
         adc       di,0
         and       al,not 7                 ; zarovn†n° na tabulaán° pozici
         jmp       short EditGtP2           ; test dal®°ho znaku

; ------ je LF - zaji®tàn° dal®°ho znaku

EditGtP5:mov       di,-2                    ; p©°znak konce ©†dku LF
         cmp       si,cx                    ; je p©ipraven dal®° znak ?
         jb        EditGP54                 ; je p©ipraven dal®° znak OK
         call      EditNGet                 ; poskytnut° adresy bloku
         jz        EditGtP9                 ; chyba nebo konec dat (je jen LF)

; ------ test, zda za LF n†sleduje znak CR

EditGP54:cmp       byte ptr es:[si],CR      ; n†sleduje znak CR ?
         clc                                ; p©°znak operace OK
         jne       EditGtP9                 ; nen° znak CR - plat° pouze LF
         dec       di                       ; -3=konec LF/CR
         jmp       short EditGP74           ; konec

; ------ je CR - zaji®tàn° dal®°ho znaku

EditGtP6:cmp       si,cx                    ; je p©ipraven dal®° znak ?
         jb        EditGtP7                 ; je p©ipraven dal®° znak OK
         call      EditNGet                 ; poskytnut° adresy bloku
         jz        EditGtP8                 ; chyba nebo konec souboru

; ------ test, zda za CR n†sleduje znak LF

EditGtP7:cmp       byte ptr es:[si],LF      ; n†sleduje znak LF ?
         jne       EditGtP3                 ; nen†sleduje LF - znak CR je platnò
         mov       di,-4                    ; p©°znak konce CR/LF
EditGP74:inc       si                       ; p©eskoáen° znaku LF (CR)

; ------ normalizace pozice (DI=n†vratovò k¢d)

EditGP76:cmp       si,cx                    ; je dal®° znak ?
         cmc
         jnc       EditGtP9                 ; je dal®° znak OK
EditGP77:call      EditNGet                 ; normalizace pozice
         jmp       short EditGtP9

; ------ chyba nebo konec souboru

EditGtP8:mov       di,-1                    ; p©°znak konce souboru/chyba

; ------ n†vrat registrñ

EditGtP9:call      EditGt0D                 ; poskytnut° adresy okna
         mov       sp,bp
         pop       bp
         pop       cx
         pop       ax
         ret

EditGetP ENDP

; -----------------------------------------------------------------------------
;                                EditLenL
;                     stanoven° celkovÇ dÇlky ©†dku
; -----------------------------------------------------------------------------
; VSTUP: SI=offset zaá†tku ©†dku v bloku (nemus° bòt normalizovanò)
;        BX=relativn° á°slo bloku
;        DX=á°slo okna (bit 15: 1=je okno 2)
;        DS=datovò segment
; VùSTUP: CX:AX=celkov† dÇlka ©†dku (v pozic°ch)
;         ES=adresa definice okna
;         CY=chyba
; -----------------------------------------------------------------------------

EditLenL PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      si
         push      di
         push      bp

; ------ p©°prava parametrñ okna

         call      EditGetD                 ; adresa definice okna

; ------ adresa definice okna

         mov       di,EdiW1                 ; okno 1
         or        dx,dx                    ; je okno 2 ?
         jns       EdiLnL01                 ; je okno 1
         mov       di,EdiW2                 ; okno 2

; ------ test, zda je bin†rn° m¢d

EdiLnL01:mov       ah,es:[di+EdiParm1]      ; parametry
         test      ah,bit1+bit2             ; je bin†rn°/HEX m¢d ?
         jz        EditLnL0                 ; je textovò m¢d

; ------ p©evod ukazatele na offset v souboru -> CX:AX

         call      EditNGet                 ; normalizace ukazatelñ
         jc        EdiLnL06                 ; chyba
         call      EdiGetOf                 ; vòpoáet offsetu v souboru

; ------ zbytek do konce souboru -> BX:SI

         call      EditGetD                 ; adresa definice okna
         mov       si,word ptr es:[EdiSize] ; velikost souboru LOW
         mov       bx,word ptr es:[EdiSize+2] ; velikost souboru HIGH
         sub       si,ax                    ; zbytek do konce souboru LOW
         sbb       bx,cx                    ; zbytek do konce souboru HIGH

; ------ stanoven° dÇlky ©†dku -> CX:AX

         mov       cx,0                     ; CX <- 0
         mov       ax,cx                    ; AX <- 0
         jc        EdiLnL04                 ; p©eteáen° za konec souboru
         mov       ax,es:[di+EdiLSir]       ; ®°©ka vnit©n°ho ©†dku
         ja        EdiLnL04                 ; zbòv† je®tà dost dat
         cmp       ax,si                    ; zbòv† dost m°sta ?
         jbe       EdiLnL04                 ; zbòv† dost m°sta
         xchg      ax,si                    ; AX <- omezen° dÇlky ©†dku
EdiLnL04:clc                                ; p©°znak operace OK
EdiLnL06:jmp       EditLnLA

; ------ p©°prava ukazatelñ

EditLnL0:xor       di,di                    ; á°taá dÇlky LOW
         xor       bp,bp                    ; á°taá dÇlky HIGH
         jmp       short EditLL16           ; nebude zrychlenÇ hled†n°

; ------ test, zda mñëe bòt zrychlenÇ hled†n° konce (ukazatele BX:SI/CX)

EditLnL1:test      ah,bit7                  ; je TAB jako bàënò znak ?
         jz        EditLL16                 ; TAB nen° bàënò znak

; ------ normalizace ukazatelñ (je p©eteáen° p©es konec bufferu CX !)

EditLL11:sub       si,cx                    ; p©eteáen° do dal®°ho bufferu
         inc       bx                       ; zvò®en° á°sla bloku

; ------ adresa okna -> ES

         call      EditGetD                 ; adresa definice okna

; ------ kontrola, zda je je®tà platnÇ á°slo bloku

         cmp       bx,es:[EdiNBlok]         ; je platnÇ á°slo bloku ?
         jae       EditLL15                 ; je p©eteáen° za konec souboru

; ------ offset definice okna -> CX

         mov       cx,bx                    ; CX <- á°slo bloku
         shl       cx,1
         shl       cx,1
         shl       cx,1                     ; á°slo bloku * 8
         add       cx,EdiABlok              ; adresa definice bloku

; ------ test, zda je v bloku poáet ©†dkñ = 0 (-1=nezn†mÇ) -> CX=poáet bajtñ
; Je testov†n i n†sleduj°c° buffer, aby se zastavilo zrychlenÇ vyhled†v†n°
; d©°ve pro p©°pad, ëe by byl LF na zaá†tku dal®°ho bufferu (aby byl spr†vnà
; zapoá°t†n p©edchoz° znak CR). Mohlo by se je®tà st†t, ëe v tomto bloku bude
; poáet bajtñ = 0 a souáasnà dal®° blok zaá°nat LF, to je m†lo pravdàpodobnÇ.

         xchg      bx,cx                    ; BX <- adresa definice bloku
         cmp       word ptr es:[bx+EdiBlokL+EdiBlokS],0 ; jsou v dal®°m bufferu ©†dky ?
         jne       EditLL12                 ; budou ©†dky
         cmp       word ptr es:[bx+EdiBlokL],0 ; jsou v bloku ©†dky ?
         mov       bx,es:[bx+EdiBlokN]      ; BX <- poáet bajtñ v bloku
EditLL12:xchg      bx,cx                    ; n†vrat registrñ
         jne       EditLL16                 ; v bloku nen° poáet ©†dkñ = 0

; ------ normalizace ukazatele

         cmp       si,cx                    ; je ukazatel uvnit© bloku ?
         jae       EditLL11                 ; posun ukazatele bloku
         sub       cx,si                    ; zbytek dat do konce bloku

; ------ posun á°taáe dÇlky a ukazatelñ

         add       si,cx                    ; posun adresy v bloku na konec
         add       di,cx                    ; posun ukazatele dÇlky LOW
         adc       bp,0                     ; posun ukazatele dÇlky HIGH
         mov       cx,si                    ; CX <- poáet bajtñ v bloku
         jmp       short EditLL11           ; dal®° blok

; ------ n†vrat á°sla bloku p©i p©eteáen° konce

EditLL15:add       si,cx                    ; n†vrat offsetu
         dec       bx                       ; n†vrat á°sla bloku

; ------ adresa bloku BX:SI -> ES:SI/BX/CX (AH=parametry)

EditLL16:call      EditNGet                 ; poskytnut° adresy bloku
         jz        EditLnL9                 ; chyba nebo konec souboru

; ------ test, zda je p©ipraven dal®° znak

EditLnL2:cmp       si,cx                    ; je p©ipraven dal®° znak ?
         jae       EditLnL1                 ; nen° p©ipraven dal®° znak

; ------ naáten° znaku

         mov       al,es:[si]               ; naáten° znaku
         inc       si                       ; zvò®en° ukazatele znaku

; ------ test, zda je konec ©†dku LF

         cmp       al,LF                    ; je konec ©†dku LF ?
         je        EditLnL9                 ; je konec ©†dku LF

; ------ test, zda je znak CR

         cmp       al,CR                    ; je znak CR ?
         je        EditLnL6                 ; je znak CR

; ------ test, zda je znak TAB

         cmp       al,TAB                   ; je znak TAB ?
         je        EditLnL4                 ; je znak TAB

; ------ je bàënò znak - zvò®en° ukazatele pozice

EditLnL3:add       di,1                     ; zvò®en° ukazatele pozice LOW
         adc       bp,0                     ; p©enos HIGH
         jmp       short EditLnL2           ; test dal®°ho znaku

; ------ je znak TAB (AH=parametry)

EditLnL4:test      ah,bit7                  ; je TAB jako bàënò znak ?
         jnz       EditLnL3                 ; TAB je jako bàënò znak
         add       di,8                     ; zvò®en° ukazatele pozice LOW
         adc       bp,0                     ; p©enos HIGH
         and       di,not 7                 ; zarovn†n° na tabulaán° pozici
         jmp       short EditLnL2           ; test dal®°ho znaku

; ------ je CR - zaji®tàn° dal®°ho znaku

EditLnL6:cmp       si,cx                    ; je p©ipraven dal®° znak ?
         jb        EditLnL7                 ; je p©ipraven dal®° znak OK
         call      EditNGet                 ; poskytnut° dal®°ho bloku
         jc        EditLnL9                 ; chyba
         je        EditLnL3                 ; konec souboru - CR je platnò znak

; ------ test, zda za CR n†sleduje znak LF

EditLnL7:cmp       byte ptr es:[si],LF      ; n†sleduje znak LF ?
         jne       EditLnL3                 ; nen†sleduje LF - znak CR je platnò

; ------ n†vrat registrñ (CY=chyba)

EditLnL9:call      EditGt0D                 ; poskytnut° adresy okna
         xchg      ax,di                    ; AX <- dÇlka ©†dku LOW
         mov       cx,bp                    ; CX <- dÇlka ©†dku HIGH

EditLnLA:pop       bp
         pop       di
         pop       si
         pop       bx
         ret

EditLenL ENDP

; -----------------------------------------------------------------------------
;                              EdiBORad
;               p©evod bloku a offsetu na ©†dek a pozici
; -----------------------------------------------------------------------------
; VSTUP: SI=offset ukazatele v bloku
;        BX=relativn° á°slo bloku
;        DX=á°slo okna (bit 15: 1=je okno 2)
;        DS=datovò segment
; VùSTUP: CX:AX=©†dek
;         BP:DI=pozice
;         ES=nov† adresa okna
;         CY=chyba
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) á°slo okna
;                   SS:[BP-4] (2) offset definice okna
;                   SS:[BP-8] (4) ukazatel á°sla ©†dku
;                   SS:[BP-12] (4) nalezen† pozice
;                   SS:[BP-14] (2) offset naposledy nalezenÇho zaá†tku ©†dku
;                   SS:[BP-16] (2) blok zaá†tku ©†dku
; -----------------------------------------------------------------------------

; !!!!! CHYBA - nen° obsluhov†n konec ©†dku LF/CR (nap©. p©i Ctrl-PageDown) !!!

EdiBORad PROC      NEAR

; ------ £schova registrñ

         push      si
         push      bx
         mov       bp,sp
         sub       sp,16

; ------ inicializace lok†ln°ch promànnòch

         mov       ss:[bp-2],dx             ; á°slo okna

         mov       di,EdiW1                 ; okno 1
         or        dx,dx                    ; je okno 2 ?
         jns       EdiBORd0                 ; je okno 1
         mov       di,EdiW2                 ; okno 2

EdiBORd0:mov       ss:[bp-4],di             ; offset definice okna
         xor       ax,ax
         mov       ss:[bp-8],ax             ; ukazatel á°sla ©†dku
         mov       ss:[bp-8+2],ax
         mov       ss:[bp-12],ax            ; nalezen† pozice
         mov       ss:[bp-12+2],ax

; ------ test, zda je bin†rn° nebo HEX m¢d

         call      EditGetD                 ; adresa okna
         test      byte ptr es:[di+EdiParm1],bit1+bit2 ; je bin†rn°/HEX m¢d ?
         jz        EdiBOR01                 ; je textovò m¢d

; ------ vòpoáet ©†dku a pozice pro bin†rn° m¢d -> CX:AX

         call      EdiGetOf                 ; vòpoáet offsetu v souboru -> CX:AX
         mov       bx,es:[di+EdiLSir]       ; BX <- ®°©ka ©†dku
         push      dx
         xchg      ax,cx                    ; AX <- offset HIGH,CX <- offset LOW
         xor       dx,dx                    ; DX <- 0
         div       bx                       ; vòpoáet ©†dku HIGH
         mov       ss:[bp-8+2],ax           ; á°slo ©†dku HIGH
         xchg      ax,cx                    ; AX <- offset LOW
         div       bx                       ; vòpoáet ©†dku LOW
         mov       ss:[bp-8],ax             ; á°slo ©†dku LOW
         mov       ss:[bp-12],dx            ; pozice na ©†dku LOW
         pop       dx
         jmp       EdiBORd8

EdiBOR02:jmp       EdiBORd9                 ; chyba

; ------ adresa aktivn°ho bloku BX:SI -> ES:SI/BX/CX

EdiBOR01:call      EditNGet                 ; poskytnut° bloku
         jc        EdiBOR02                 ; chyba

; ------ spoáten° ©†dkñ v aktivn°m bloku (po hledanò offset)

EdiBORd1:add       ss:[bp-12],si            ; zvò®en° á°taáe offsetu pozice
         adc       word ptr ss:[bp-12+2],0
         mov       cx,si                    ; velikost dat k prohled†n°
         xor       di,di                    ; poá†teán° offset v bloku
         mov       al,LF                    ; hledanò znak LF
         cld
EdiBORd2:mov       ss:[bp-14],di            ; offset naposledy nalezenÇho ©†dku
         jcxz      EdiBORd3                 ; nen° dal®° znak
         repne     scasb                    ; vyhled†n° znaku LF
         jne       EdiBORd3                 ; dal®° znak nenalezen
         inc       word ptr ss:[bp-8]       ; á°taá ©†dkñ
         jmp       short EdiBORd2           ; dal®° hled†n°

; ------ test, zda byl nalezen zaá†tek ©†dku

EdiBORd3:cmp       word ptr ss:[bp-8],0     ; byl nalezen zaá†tek ©†dku ?
         jne       EdiBORd4                 ; byl nalezen zaá†tek ©†dku
         or        bx,bx                    ; je to jië prvn° blok ?
         jz        EdiBORd4                 ; je to jië prvn° blok - konec

; ------ posun k p©ede®lÇmu bloku

         mov       si,-1                    ; ukazatel na konec p©ede®lÇho bloku
         call      EditNGet                 ; posun k p©ede®lÇmu bloku
         jc        EdiBORd9                 ; chyba
         mov       si,cx                    ; SI <- poáet bajtñ v bloku
         jmp       short EdiBORd1           ; prohled†n° dal®°ho bloku

; ------ korekce offsetu pozice od zaá†tku ©†dku

EdiBORd4:mov       ax,ss:[bp-14]            ; naposledy nalezenò zaá†tek
         sub       ss:[bp-12],ax            ; oprava offsetu pozice
         sbb       word ptr ss:[bp-12+2],0
         mov       ss:[bp-16],bx            ; blok zaá†tku ©†dku

; ------ adresa okna -> ES

         call      EditGetD                 ; adresa okna -> ES

; ------ adresa popisovaáe bloku -> SI

         mov       si,bx                    ; á°slo aktivn°ho bloku
         shl       si,1
         shl       si,1
         shl       si,1                     ; á°slo bloku * 8
         add       si,EdiABlok              ; adresa tohoto bloku

; ------ p©iáten° ©†dkñ z ostatn°ch (p©ede®lòch) blokñ

EdiBORd5:or        bx,bx                    ; je jië prvn° blok ?
         jz        EdiBORd7                 ; je jië prvn° blok
         sub       si,EdiBlokS              ; posun adresy popisovaáe
         dec       bx                       ; sn°ëen° á°sla bloku
         mov       ax,es:[si+EdiBlokL]      ; poáet ©†dkñ v bloku
         inc       ax                       ; je poáet ©†dkñ zn†mò ?
         jnz       EdiBORd6                 ; poáet ©†dkñ je zn†mò
         call      EditBGet                 ; naáten° bloku
         jc        EdiBORd9                 ; chyba
         call      EditGetD                 ; nov† adresa okna
         mov       ax,es:[si+EdiBlokL]      ; poáet ©†dkñ v bloku
         inc       ax                       ; je poáet ©†dkñ zn†mò ?
         stc
         jz        EdiBORd9                 ; poáet ©†dkñ nen° zn†mò
EdiBORd6:dec       ax                       ; n†vrat á°sla poátu ©†dkñ
         add       ss:[bp-8],ax             ; zvò®en° á°taáe ©†dkñ
         adc       word ptr ss:[bp-8+2],0
         jmp       short EdiBORd5

; ------ p©evod offsetu na ©†dku na pozici na ©†dku

EdiBORd7:mov       ax,ss:[bp-12]            ; offset na ©†dku LOW
         mov       cx,ss:[bp-12+2]          ; offset na ©†dku HIGH
         mov       si,ss:[bp-14]            ; offset zaá†tku ©†dku
         mov       bx,ss:[bp-16]            ; blok zaá†tku ©†dku
         call      EdiOfPoz                 ; p©evod offsetu na pozici
         mov       ss:[bp-12],ax            ; pozice na ©†dku LOW
         mov       ss:[bp-12+2],cx          ; pozice na ©†dku HIGH

; ------ operace OK

EdiBORd8:mov       ax,ss:[bp-8]             ; á°slo ©†dku
         mov       cx,ss:[bp-8+2]
         mov       di,ss:[bp-12]            ; nalezen† pozice
         mov       si,ss:[bp-12+2]
         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

EdiBORd9:mov       sp,bp
         mov       bp,si
         pop       bx
         pop       si
         call      EditGt0D                 ; obnoven° adresy okna
         ret

EdiBORad ENDP

; -----------------------------------------------------------------------------
;                              EdiOfPoz
;                   p©evod offsetu na ©†dku na pozici
; -----------------------------------------------------------------------------
; VSTUP: CX:AX=offset na ©†dku (nesm° bòt za koncem ©†dku)
;        BX=blok zaá†tku ©†dku
;        SI=offset zaá†tku ©†dku v bloku
;        DX=segment okna (bit 15: 1=je okno 2) (mus° bòt platnÇ !)
;        DS=datovò segment
; VùSTUP: CX:AX=pozice na ©†dku
;         ES=nov† adresa okna
;         CY=chyba operace
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) á°slo segmentu okna
;                   SS:[BP-4] (2) á°slo bloku
;                   DX:AX=á°taá offsetu na ©†dku
;                   BX:DI=st©adaá pozice
; -----------------------------------------------------------------------------

EdiOfPoz PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      dx
         push      si
         push      di
         push      bp
         mov       bp,sp
         sub       sp,4

; ------ adresa okna -> ES

         mov       ss:[bp-2],dx             ; á°slo segmentu okna
         mov       ss:[bp-4],bx             ; ukazatel á°sla bloku
         call      EditGetD                 ; adresa okna

; ------ adresa definice okna -> DI

         mov       di,EdiW1                 ; okno 1
         or        dx,dx                    ; je okno 2 ?
         jns       EdiOfPz1                 ; je okno 1
         mov       di,EdiW2                 ; okno 2

; ------ test, zda je BIN nebo HEX m¢d a zda je tabul†tor platnò znak

EdiOfPz1:test      byte ptr es:[di+EdiParm1],bit1+bit2+bit7
         jnz       EdiOfPz9                 ; pozice stejn† jako offset

; ------ p©°prava registrñ

         mov       dx,cx                    ; á°taá offsetu HIGH
         xor       di,di                    ; st©adaá pozice LOW
         xor       bx,bx                    ; st©adaá pozice HIGH

; ------ adresa bloku -> ES

EdiOfPz2:push      bx
         push      dx
         mov       bx,ss:[bp-4]             ; ukazatel á°sla bloku
         mov       dx,ss:[bp-2]             ; á°slo segmentu okna
         call      EditNGet                 ; poskytnut° bloku
         mov       ss:[bp-4],bx             ; novÇ á°slo bloku
         pop       dx
         pop       bx
         jz        EdiOfPz8                 ; nejsou dal®° data

; ------ test, zda je dal®° bajt

EdiOfPz3:cmp       si,cx                    ; je za koncem dat ?
         jae       EdiOfPz2                 ; nen° dal®° znak

; ------ test, zda m† bòt dal®° bajt

         sub       ax,1                     ; sn°ëen° á°taáe offsetu
         sbb       dx,0
         jc        EdiOfPz7                 ; konec

; ------ test, zda je tabul†tor

         inc       si                       ; zvò®en° ukazatele dat
         cmp       byte ptr es:[si-1],TAB   ; byl to tabul†tor ?
         je        EdiOfPz4                 ; byl to tabul†tor

; ------ je platnò znak - zvò®en° ukazatelñ

         add       di,1                     ; zvò®en° ukazatele pozice
         adc       bx,0
         jmp       short EdiOfPz3

; ------ posun tabul†toru

EdiOfPz4:add       di,8                     ; zvò®en° ukazatele pozice
         adc       bx,0
         and       di,not 7                 ; zarovn†n° na tabulaán° pozici
         jmp       short EdiOfPz3           ; dal®° znak

; ------ n†vrat registrñ

EdiOfPz7:clc                                ; p©°znak operace OK
EdiOfPz8:xchg      ax,di                    ; AX <- pozice LOW
         mov       cx,bx                    ; CX <- pozice HIGH

EdiOfPz9:mov       sp,bp
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       bx
         call      EditGt0D                 ; obnoven° adresy okna
         ret

EdiOfPoz ENDP

; -----------------------------------------------------------------------------
;                              EdiGetAd
;                      vòpoáet adresy v souboru
; -----------------------------------------------------------------------------
; VSTUP: CX:AX=offset ukazatele v souboru (mñëe bòt i mimo rozsah souboru)
;        DX=á°slo okna (mus° bòt platnÇ !)
;        DS=datovò segment
; VùSTUP: SI=offset ukazatele v bloku
;         BX=relativn° á°slo bloku
;         NC
; -----------------------------------------------------------------------------

EdiGetAd PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      es

; ------ adresa definice okna

         call      EditGetD                 ; adresa definice okna

; ------ test, zda je nàjakò blok v souboru

         xor       bx,bx                    ; BX <- ukazatel á°sla bloku
         xor       si,si                    ; SI <- offset v bloku
         cmp       bx,es:[EdiNBlok]         ; je nàjakò blok v souboru ?
         je        EdiGetA9                 ; nen° ë†dnò blok v souboru
         mov       si,EdiABlok              ; zaá†tek definic blokñ

; ------ test, zda je adresa jië nalezena

EdiGetA1:or        cx,cx                    ; je jië offset < 64K ?
         jnz       EdiGetA2                 ; je je®tà velkò offset
         cmp       ax,es:[si+EdiBlokN]      ; je offset platnò ?
         jb        EdiGetA8                 ; nalezena adresa OK

; ------ sn°ëen° offsetu v souboru

EdiGetA2:sub       ax,es:[si+EdiBlokN]      ; odeáten° dat v bloku
         sbb       cx,0

; ------ posun ukazatele k dal®°mu bloku

         inc       bx                       ; zvò®en° ukazatele á°sla bloku
         add       si,EdiBlokS              ; adresa dal®°ho ukazatele

; ------ test, zda je je®tà dal®° platnò blok

         cmp       bx,es:[EdiNBlok]         ; je to platnò blok ?
         jb        EdiGetA1                 ; blok je platnò

; ------ n†vrat ukazatelñ na posledn° blok

         dec       bx                       ; n†vrat á°sla bloku
         mov       ax,es:[si-EdiBlokS+EdiBlokN] ; ukazatel na posledn° blok

; ------ n†vrat registrñ

EdiGetA8:xchg      ax,si                    ; SI <- offset dat v bloku
EdiGetA9:clc
         pop       es
         pop       cx
         pop       ax
         ret

EdiGetAd ENDP

; -----------------------------------------------------------------------------
;                              EdiGetOf
;                      vòpoáet offsetu v souboru
; -----------------------------------------------------------------------------
; VSTUP: SI=offset ukazatele v bloku (mus° bòt platnÇ !) (BX:SI normalizovanÇ !)
;        BX=relativn° á°slo bloku
;        DX=á°slo okna (mus° bòt platnÇ !)
;        DS=datovò segment
; VùSTUP: CX:AX=offset ukazatele v souboru
;         NC
; -----------------------------------------------------------------------------

EdiGetOf PROC      NEAR

; ------ £schova registrñ

         push      si
         push      bx
         push      es

; ------ adresa definice okna

         call      EditGetD                 ; adresa definice okna

; ------ spoáten° offsetu v souboru

         xchg      ax,si                    ; AX <- offset v posledn°m bloku
         xor       cx,cx                    ; á°taá offsetu HIGH
         or        bx,bx                    ; á°slo bloku
         jz        EdiGetO9                 ; byl prvn° blok
         mov       si,EdiABlok              ; zaá†tek definic blokñ
EdiGetO2:add       ax,es:[si+EdiBlokN]      ; p©iáten° velikosti bloku
         adc       cx,0                     ; p©enos HIGH
         add       si,EdiBlokS              ; adresa dal®°ho ukazatele
         dec       bx
         jnz       EdiGetO2                 ; p©iáten° dal®°ho bloku

; ------ n†vrat registrñ

EdiGetO9:clc
         pop       es
         pop       bx
         pop       si
         ret

EdiGetOf ENDP

; -----------------------------------------------------------------------------
;                                EdiGetLn
;                        poskytnut° adresy ©†dku
; -----------------------------------------------------------------------------
; VSTUP: CX:AX=á°slo poëadovanÇho ©†dku (kontroluje se p©eteáen°)
;        DX=á°slo okna (bit 15: 1=je okno 2)
;        DS=datovò segment
; VùSTUP: BX=blok se zaá†tkem ©†dku
;         SI=offset zaá†tku ©†dku v bloku
;         ES=novò segment definice okna
;         CY (a ZY) = chyba (BX a SI neplat°)
;         ZY (a NC) = neplatnÇ á°slo ©†dku (BX a SI ukazuj° na konec souboru)
;         NZ (a NC) = v®e OK (BX a SI ukazuj° na zaá†tek ©†dku)
; -----------------------------------------------------------------------------

EdiGetLn PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      di
         push      bp

; ------ adresa definice okna -> ES

         call      EditGetD                 ; adresa definice okna

; ------ adresa definice okna

         mov       bx,EdiW1                 ; okno 1
         or        dx,dx                    ; je okno 2 ?
         jns       EdiGtL01                 ; je okno 1
         mov       bx,EdiW2                 ; okno 2

; ------ test, zda je bin†rn° m¢d

EdiGtL01:test      byte ptr es:[bx+EdiParm1],bit1+bit2 ; je bin†rn°/HEX m¢d ?
         jz        EdiGetL0                 ; je textovò m¢d

; ------ p©epoáet ©†dku CX:AX na offset v souboru CX:AX

         mov       bx,es:[bx+EdiLSir]       ; BX <- ®°©ka ©†dku
         push      dx
         xchg      ax,cx                    ; AX <- ©†dek HIGH, CX <- ©†dek LOW
         mul       bx                       ; DX:AX <- vyn†soben° ©†dku HIGH
         xchg      ax,cx                    ; AX <- ©†dek LOW, CX <- offset HIGH
         xchg      dx,bx                    ; DX <- ®°©ka ©†dku, BX<-offset DHGH
         mul       dx                       ; vyn†soben° ©†dku LOW
         add       cx,dx                    ; p©enos offsetu HIGH
         pop       dx

; ------ omezen° p©i p©eteáen° offsetu

         adc       bx,bx                    ; je p©eteáen° offsetu ?
         jz        EdiGtL02                 ; nen° p©eteáen° offsetu
         mov       cx,-1                    ; CX <- -1 omezen° p©i p©eteáen°
         mov       ax,cx                    ; AX <- -1

; ------ nalezen° adresy CX:AX v souboru

EdiGtL02:call      EdiGetAd                 ; nalezen° adresy v souboru
         jmp       EdiGetLA

; ------ p©°prava k nalezen° poëadovanÇho bloku

EdiGetL0:xor       bx,bx                    ; ukazatel á°sla bloku
         xor       si,si                    ; offset, nen°-li ë†dnò blok
         mov       bp,ax                    ; á°slo ©†dku LOW
         or        bp,cx                    ; je poëadov†n ©†dek 0 ?
         jz        EdiGetL5                 ; poëadov†n ©†dek 0
         mov       di,EdiABlok              ; zaá†tek tabulky popisovaáñ
         cmp       bx,es:[si+EdiNBlok]      ; je nàjakò blok ?
         je        EdiGtL64                 ; nen° ë†dnò blok

; ------ parametry testovanÇho bloku

EdiGetL1:mov       si,es:[di+EdiBlokN]      ; p©°padnò konec bloku
         mov       bp,es:[di+EdiBlokL]      ; poáet ©†dkñ bloku

; ------ test, zda jsou zn†mÇ ©†dky bloku

         inc       bp                       ; je poáet ©†dkñ bloku zn†mò ?
         jz        EdiGetL7                 ; poáet ©†dkñ nen° zn†mò
EdiGetL2:dec       bp                       ; n†vrat poátu ©†dkñ

; ------ sn°ëen° á°taáe poëadovanòch ©†dkñ

         sub       ax,bp                    ; sn°ëen° á°taáe poëadovanÇho ©†dku
         sbb       cx,0
         ja        EdiGetL6                 ; nen° je®tà poëadovanò ©†dek
         jb        EdiGetL3                 ; podteáen° - je poëadovanò ©†dek
         or        ax,ax
         jnz       EdiGetL6                 ; nen° je®tà poëadovanò ©†dek
EdiGetL3:add       ax,bp                    ; n†vrat poátu ©†dkñ

; ------ nalezen° zaá†tku ©†dku uvnit© bloku (AX<>0 !)

         xor       si,si                    ; offset zaá†tku bloku
         call      EditBGet                 ; poskytnut° adresy bloku
         jc        EdiGetL9                 ; chyba
         push      cx
         push      bx                       ; á°slo bloku
         xchg      ax,bx                    ; BX <- poëadovanò poáet ©†dkñ
         xor       di,di                    ; zaá†tek bloku
         cld
         mov       al,LF                    ; hledanò znak LF
EdiGetL4:repne     scasb                    ; nalezen° znaku LF
         dec       bx                       ; á°taá znakñ LF
         jnz       EdiGetL4                 ; nalezen° dal®°ho znaku
         or        cx,cx                    ; je konec bloku ?
         pop       bx                       ; á°slo bloku
         pop       cx
         mov       si,di                    ; SI <- offset nalezenÇho ©†dku

; ------ zaji®tàn° koncovÇ adresy bloku

         jnz       EdiGtL42                 ; nen° konec bloku
         call      EditNGet                 ; normalizace adresy
         jc        EdiGetL9                 ; chyba
         je        EdiGetL5                 ; nejsou dal®° data

; ------ test, zda n†sleduje znak CR

EdiGtL42:cmp       byte ptr es:[si],CR      ; n†sleduje znak CR ?
         jne       EdiGetL5                 ; nen†sleduje znak CR

; ------ rychl† kontrola, zda p©ed znakem LF p©edch†z° znak CR

         cmp       si,2                     ; je pot©eba 2 znaky p©ed
         jb        EdiGtL44                 ; je m†lo znakñ p©ed
         inc       si                       ; p©ednastaven° - je LF/CR
         cmp       byte ptr es:[si-3],CR    ; p©edch†z° p©ed znakem LF znak CR ?
         jne       EdiGetL5                 ; nep©edch†z° - je LF/CR
         dec       si                       ; n†vrat ukazatele na CR
EdiGtL44:call      EdiGtLL                  ; synchronizace zaá†tku ©†dku
         jc        EdiGetL9                 ; chyba

; ------ operace OK

EdiGetL5:or        dx,dx                    ; p©°znak NZ, NC
EdiGtL52:jmp       short EdiGetL9

; ------ p©°prava pro dal®° blok

EdiGetL6:inc       bx                       ; zvò®en° á°taáe blokñ
         add       di,EdiBlokS              ; adresa dal®°ho popisovaáe
         cmp       bx,es:[EdiNBlok]         ; je to platnò blok ?
         jb        EdiGetL1                 ; je to platnò blok OK
         dec       bx                       ; n†vrat á°sla bloku
EdiGtL64:jmp       short EdiGetL8           ; ©†dek nenalezen

; ------ zji®tàn° poátu ©†dkñ bloku BX

EdiGetL7:push      cx
         call      EditBGet                 ; nalezen° parametrñ bloku
         pop       cx
         jc        EdiGetL9                 ; chyba

         call      EditGetD                 ; nov† adresa okna

         mov       bp,es:[di+EdiBlokL]      ; poáet ©†dkñ bloku
         inc       bp                       ; je poáet ©†dkñ jië zn†mò ?
         jnz       EdiGetL2                 ; poáet ©†dkñ je zn†mò

; ------ poëadovanò ©†dek nenalezen

EdiGetL8:xor       di,di                    ; nastaven° p©°znaku ZY a NC

; ------ adresa definice okna DX -> ES

EdiGetL9:call      EditGt0D                 ; adresa definice okna

; ------ n†vrat registrñ

EdiGetLA:pop       bp
         pop       di
         pop       cx
         pop       ax
         ret

EdiGetLn ENDP

; -----------------------------------------------------------------------------
;                                  EdiGetCL
;           poskytnut° celkovÇho poátu ©†dkñ (podle m¢du zobrazen°)
;   v textovÇm m¢du se poskytne poáet dosud zji®tànòch ©†dkñ bez aktualizace
; -----------------------------------------------------------------------------
; VSTUP: DX=á°slo okna (bit 15: 1=je okno 2)
;        DS=datovò segment
; VùSTUP: CX:AX=celkovò poáet ©†dkñ (nebo dosud zji®tànòch ©†dkñ)
; -----------------------------------------------------------------------------

EdiGetCL PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      es

; ------ adresa okna -> ES

         call      EditGetD                 ; adresa definice okna
         jc        EdiGetC9                 ; neplatnÇ á°slo okna

; ------ adresa definice okna -> BX

         mov       bx,EdiW1                 ; okno 1
         or        dx,dx                    ; je okno 2 ?
         jns       EdiGetC2                 ; je okno 1
         mov       bx,EdiW2                 ; okno 2

; ------ poáet ©†dkñ v textovÇm m¢du

EdiGetC2:mov       ax,word ptr es:[EdiRadku] ; celkovò poáet ©†dkñ v souboru LOW
         mov       cx,word ptr es:[EdiRadku+2] ; celkovò poáet ©†dkñ v souboru HIGH
         test      byte ptr es:[bx+EdiParm1],bit1+bit2 ; je bin†rn°/HEX m¢d ?
         jz        EdiGetC9                 ; je textovò m¢d

; ------ poáet ©†dkñ v bin†rn°m a HEX m¢du

         push      dx
         xor       dx,dx                    ; DX <- 0
         mov       ax,word ptr es:[EdiSize+2] ; velikost souboru HIGH
         mov       bx,es:[bx+EdiLSir]       ; poáet bajtñ na ©†dek
         div       bx                       ; poáet ©†dkñ HIGH
         xchg      ax,cx                    ; CX <- poáet ©†dkñ HIGH
         mov       ax,word ptr es:[EdiSize] ; velikost souboru LOW
         div       bx                       ; poáet ©†dkñ LOW
         pop       dx

; ------ n†vrat registrñ

EdiGetC9:pop       es
         pop       bx
         ret

EdiGetCL ENDP

; -----------------------------------------------------------------------------
;                                EdiAktL
;        aktualizace celkovÇho poátu ©†dkñ v souboru (jen textovò m¢d)
; -----------------------------------------------------------------------------
; VSTUP: DX=á°slo okna (bit 15: 1=je okno 2)
;        DS=datovò segment
; VùSTUP: ES=novò segment definice okna
;         CY=chyba operace
; -----------------------------------------------------------------------------

EdiAktL  PROC      NEAR

; ------ adresa definice okna -> ES

         call      EditGetD                 ; adresa definice okna
         jc        EdiAktL9                 ; chybnÇ á°slo okna

;; ------ test, zda je poáet ©†dkñ jië zji®tàn
;
;         test      byte ptr es:[EdiParm],bit1 ; je poáet ©†dkñ jië zji®tàn ?
;         jnz       EdiAktL9                 ; poáet ©†dkñ je jië zji®tàn

; ------ £schova registrñ

         push      bx
         push      cx
         push      di

; ------ adresa definice okna -> BX

         mov       bx,EdiW1                 ; okno 1
         or        dx,dx                    ; je okno 2 ?
         jns       EdiAktL1                 ; je okno 1
         mov       bx,EdiW2                 ; okno 2

; ------ test, zda je bin†rn°/HEX m¢d (pro urychlen° se nezji®üuje poáet ©†dkñ)

EdiAktL1:test      byte ptr es:[bx+EdiParm1],bit1+bit2 ; je bin†rn°/HEX m¢d ?
         jnz       EdiAktL8                 ; je bin†rn° nebo HEX m¢d

; ------ p©°prava k prohled†n° tabulky blokñ

         xor       bx,bx                    ; ukazatel á°sla bloku
         mov       di,EdiABlok              ; zaá†tek tabulky popisovaáñ

; ------ test, zda je dal®° platnò blok

EdiAktL2:cmp       bx,es:[EdiNBlok]         ; je to platnò blok ?
         jae       EdiAktL7                 ; nen° dal®° platnò blok

; ------ test, zda jsou zn†mÇ ©†dky bloku

         cmp       word ptr es:[di+EdiBlokL],-1 ; je poáet ©†dkñ zn†mò ?
         jne       EdiAktL5                 ; poáet ©†dkñ je zn†mò

; ------ zji®tàn° poátu ©†dkñ bloku BX

         call      EditBGet                 ; nalezen° parametrñ bloku
         call      EditGt0D                 ; nov† adresa okna -> ES
         jc        EdiAktL8                 ; chyba

; ------ test, zda je poáet ©†dkñ jië zn†mò

         cmp       word ptr es:[di+EdiBlokL],-1 ; byl poáet ©†dkñ zji®tàn ?
         stc                                ; p©°znak chyby operace
         je        EdiAktL8                 ; chyba

; ------ p©°prava pro dal®° blok

EdiAktL5:inc       bx                       ; zvò®en° á°taáe blokñ
         add       di,EdiBlokS              ; adresa dal®°ho popisovaáe
         jmp       short EdiAktL2           ; dal®° ©†dek

; ------ p©°znak, ëe poáet ©†dkñ byl zji®tàn

EdiAktL7:;or        byte ptr es:[EdiParm],bit1 ; p©°znak zji®tàn° poátu ©†dkñ
         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

EdiAktL8:pop       di
         pop       cx
         pop       bx
EdiAktL9:ret

EdiAktL  ENDP

; -----------------------------------------------------------------------------
;                                 EdiGtLL
;                       synchronizace zaá†tku ©†dku
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=ukazatel v bloku na znak CR, p©edchoz° znak byl LF
;        BX=aktu†ln° á°slo bloku (ukazatele normalizov†ny !)
;        DX=á°slo segmentu okna
;        DS=datovò segment
; VùSTUP: CY=chyba (ES nen° definov†n, SI nen° normalizov†n)
;         ES:SI=novò ukazatel na zaá†tek ©†dku (p©i chybà ES nen° definov†n !)
;         BX=novÇ aktu†ln° á°slo bloku
; -----------------------------------------------------------------------------

EdiGtLL  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      di
         push      bp

; ------ p©°prava registrñ

         mov       bp,256                   ; maxim†ln° poáet pokusñ
         mov       di,si                    ; DI <- souáasnò ukazatel na CR
         mov       ax,bx                    ; AX <- blok souáasnÇho ukazatele

; ------ test, zda p©ede®lò znak je CR (= je CR/LF)

         dec       si                       ; posun ukazatele na p©edchoz° LF
EdiGtLL1:inc       di                       ; bude LF/CR - znak CR plat°
         dec       si                       ; posun ukazatele
         jns       EdiGtLL2                 ; nen° podteáen°
         call      EditNGet                 ; adresa dal®°ho bloku
         jz        EdiGtLL5                 ; chyba nebo konec - je LF/CR
EdiGtLL2:cmp       byte ptr es:[si],CR      ; je p©ede®lò znak CR ?
         jne       EdiGtLL4                 ; p©ede®lò znak nen° CR - je LF/CR

; ------ test, zda dal®° znak je LF (= je LF/CR)

         dec       di                       ; je CR/LF - znak CR neplat°
         dec       si                       ; posun ukazatele
         jns       EdiGtLL3                 ; nen° podteáen°
         call      EditNGet                 ; adresa dal®°ho bloku
         jz        EdiGtLL5                 ; chyba nebo konec
EdiGtLL3:dec       bp                       ; á°taá pokusñ
         jz        EdiGtLL4                 ; konec - bude implicitnà CR/LF
         cmp       byte ptr es:[si],LF      ; je p©ede®lò znak LF ?
         je        EdiGtLL1                 ; p©ede®lò znak je LF - je LF/CR
                                          ;* jinak to je CR/LF
; ------ operace OK - normalizace adresy

EdiGtLL4:clc                                ; p©°znak operace OK
EdiGtLL5:mov       si,di                    ; SI <- n†vrat ukazatele zaá†tku ©†dku
         mov       bx,ax                    ; BX <- n†vrat bloku ukazatele
         jc        EdiGtLL6                 ; chyba
         call      EditNGet                 ; normalizace adresy

; ------ n†vrat registrñ

EdiGtLL6:pop       bp
         pop       di
         pop       cx
         pop       ax
         ret

EdiGtLL  ENDP

; -----------------------------------------------------------------------------
;                                EdiGetCh
;                  poskytnut° znaku na aktu†ln° pozici
; -----------------------------------------------------------------------------
; VSTUP: BX=aktu†ln° á°slo bloku
;        DX=á°slo segmentu okna
;        SI=offset v bloku (mñëe p©ekroáit konec i zaá†tek bloku)
;        DS=datovò segment
; VùSTUP: AL=znak na pozici (p©i neplatnÇm znaku ZY je AL=0)
;         BX=novò aktu†ln° blok (p©i chybà CY nezmànàn)
;         SI=novò offset v bloku (p©i chybà CY nezmànàn)
;         ES=segment definice okna
;         CY (a ZY) = chyba (BX a SI nezmànàn, AL=0)
;         ZY (a NC) = mimo rozsah souboru (BX a SI konec/zaá†tek, AL=0)
;         NZ (a NC) = v®e OK
; -----------------------------------------------------------------------------

EdiGetCh PROC      NEAR

; ------ poskytnut° bloku s normalizac°

         push      cx
         call      EditNGet                 ; poskytnut° bloku s normalizac°
         pop       cx

; ------ znak na poëadovanÇ pozici

         mov       al,0                     ; znak neplatnò
         jz        EdiGtCh2                 ; znak neplatnò (chyba nebo mimo)
         mov       al,es:[si]               ; znak z bufferu

; ------ nov† adresa definice okna

EdiGtCh2:call      EditGt0D                 ; ES <- adresa definice okna
         ret

EdiGetCh ENDP

; -----------------------------------------------------------------------------
;                               EditNGet
;               poskytnut° bloku souboru s normalizac° offsetu
;                         posouv† datovÇ bloky !
; -----------------------------------------------------------------------------
; VSTUP: BX=index poëadovanÇho bloku (mñëe bòt i mimo rozsah souboru)
;        DX=á°slo segmentu definice okna
;        SI=offset v bloku (mñëe p©ekroáit konec i zaá†tek bloku)
;                        (maxim†ln° p©ekroáen° o BLOKBLOK/2 !)
;        DS=datovò segment
; VùSTUP: BX=novò aktu†ln° blok
;         CX=poáet bajtñ v bloku
;         SI=novò offset v bloku
;         ES=adresa segmentu bloku souboru
;         CY (a ZY) = chyba (BX, CX, SI a ES nezmànàn)
;         ZY (a NC) = mimo rozsah souboru (BX,CX,SI,ES - konec/zaá†tek souboru)
;         NZ (a NC) = v®e OK
; -----------------------------------------------------------------------------
;˛
EditNGet PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      si
         push      es

; ------ poáet blokñ v souboru

         call      EditGetD                 ; adresa definice okna
         mov       ax,es:[EdiNBlok]         ; poáet blokñ v souboru

; ------ kontrola, zda nen° podteáen° á°sla bloku

         or        bx,bx                    ; je podteáen° á°sla bloku ?
         jns       EditNGt1                 ; nen° podteáen° á°sla bloku
         xor       bx,bx                    ; minim†ln° á°slo bloku

; ------ posun k p©ede®lÇmu bloku (je-li offset p©ed poá†tkem bloku)

EditNGt1:cmp       si,BLOKTEST              ; je z†pornò offset ?
         jb        EditNGt4                 ; nen° z†pornÇ á°slo
         dec       bx                       ; sn°ëen° á°sla bloku
         js        EditNGt3                 ; podteáen° p©ed poá†tek souboru
         call      EditBGet                 ; poskytnut° p©ede®lÇho bloku
         jc        EditNGt8                 ; chyba (mimo rozsah teÉ nevad°)
         add       si,cx                    ; posun ukazatele v bloku
         jmp       short EditNGt1           ; dal®° posun

; ------ podteáen° ukazatele p©ed poá†tek souboru

EditNGt3:xor       si,si                    ; omezen° offsetu p©i podteáen°
         xor       bx,bx                    ; omezen° bloku p©i podteáen°
         call      EditBGet                 ; adresa bloku 0
         jc        EditNGt8                 ; chyba
         jmp       short EditNGtB           ; mimo rozsah souboru

; ------ adresa aktu†ln°ho bloku

EditNGt4:call      EditBGet                 ; poskytnut° aktu†ln°ho bloku
         jc        EditNGt8                 ; chyba

; ------ kontrola, zda ukazatel je uvnit© bloku

         cmp       si,cx                    ; je ukazatel uvnit© bloku ?
         jb        EditNGt9                 ; ukazatel je OK uvnit© bloku

; ------ posun k dal®°mu bloku

         inc       bx                       ; zvò®en° ukazatele blokñ
         cmp       bx,ax                    ; je mimo rozsah ?
         jae       EditNGtA                 ; je mimo rozsah
         sub       si,cx                    ; posun adresy v bloku
         jmp       short EditNGt4           ; poskytnut° dal®°ho bloku

; ------ chyba - n†vrat ukazatelñ (zde je CY a ZY)

EditNGt8:pop       es
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

; ------ operace OK (n†vrat NC a NZ)

EditNGt9:add       sp,2*4                   ; zru®en° BX, CX, SI a ES
         pop       ax
         or        dx,dx                    ; p©°znak operace OK (= NC a NZ)
         ret

; ------ mimo rozsah souboru (n†vrat NC a ZY)

EditNGtA:dec       bx                       ; n†vrat á°sla bloku
         mov       si,cx                    ; SI <- omezen° na konec bloku
EditNGtB:add       sp,2*4                   ; zru®en° BX, CX, SI a ES
         pop       ax
         cmp       ax,ax                    ; p©°znak mimo rozsah (= NC a ZY)
         ret

EditNGet ENDP

; -----------------------------------------------------------------------------
;                             EditBGet
;        poskytnut° bloku souboru (s p©°padnòm naáten°m a aktualizac°)
;                      posouv† datovÇ bloky !
; -----------------------------------------------------------------------------
; VSTUP: BX=index poëadovanÇho bloku (mñëe bòt i mimo rozsah souboru)
;        DX=á°slo segmentu definice okna
;        DS=datovò segment
; VùSTUP: CX=poáet bajtñ v bloku souboru (p©i ZY je CX=0 !)
;         ES=adresa segmentu bloku souboru (pro ZY je ES neplatnò !)
;         CY (a ZY) = chyba (CX=0) (neplatnò segment okna nebo bloku)
;         ZY (a NC) = neplatnÇ á°slo bloku (blok mimo rozsah souboru) (CX=0)
;         NZ (a NC) = v®e OK
; -----------------------------------------------------------------------------

EditBGet PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      si
         push      di

; ------ adresa definice okna -> ES

         call      EditGetD                 ; adresa definice okna
         jc        EditBG12                 ; neplatnò segment

; ------ kontrola á°sla bloku

         cmp       bx,es:[EdiNBlok]         ; kontrola á°sla bloku
         jb        EditBGt1                 ; á°slo bloku je OK
         xor       cx,cx                    ; nejsou data, p©°znak ZY a NC
         jmp       short EditBG02

; ------ adresa definice bloku -> ES:SI

EditBGt1:mov       si,bx                    ; SI <- index bloku souboru
         shl       si,1
         shl       si,1
         shl       si,1                     ; offset v definián° tabulce
         add       si,EdiABlok              ; adresa definice bloku

; ------ adresa datovÇho bloku, pokud je vytvo©en -> ES, AX, CX, DI

         mov       ax,es:[si+EdiBlokM]      ; identifik†tor v pamàti
         mov       cx,es:[si+EdiBlokN]      ; poáet bajtñ v bloku
         or        ax,ax                    ; je blok p©idàlen ?
         jz        EditBGt2                 ; blok nen° p©idàlen
         mov       di,es:[si+EdiBlokL]      ; poáet ©†dkñ v bloku
         and       ah,not bit15/bit8        ; zru®en° p©°znaku modifikace
         call      far ptr GetDat           ; adresa datovÇho bloku
EditBG12:jc        EditBGt0                 ; nàjak† chyba
         jmp       short EditBGt7           ; aktualizace áetnosti pouëit° bloku

; ------ p©idàlen° novÇho datovÇho bloku (neaktualizuje je®tà áetnost pouëit° !)

EditBGt2:call      EditBCre                 ; p©idàlen° datovÇho bloku -> AX
         jc        EditBGt0                 ; chyba
         call      EditGetD                 ; nov† adresa okna
         mov       es:[si+EdiBlokM],ax      ; p©idàlenò datovò segment

; ------ naáten° bloku ze souboru

         mov       di,es:[si+EdiBlokD]      ; identifik†tor bloku na disku
         push      word ptr es:[si+EdiBLokL] ; poáet p©elomñ ©†dkñ LF
         call      far ptr GetDat           ; adresa datovÇho bloku
         jc        EditBGt5                 ; chyba ?
         inc       di                       ; je blok na disku p©idàlen ?
         jz        EditBGt5                 ; blok nen° p©idàlen
         dec       di                       ; n†vrat á°sla bloku
         xchg      ax,di                    ; AX <- identifik†tor bloku
         or        ax,ax                    ; je to p©echodnò soubor ?
         js        EditBGt3                 ; je to p©echodnò soubor
         call      EditIRea                 ; naáten° bloku ze vstup. souboru
         jmp       short EditBGt4

EditBGt3:call      EditTRea                 ; naáten° bloku z p©echod. souboru
EditBGt4:xchg      ax,di                    ; AX <- á°slo datovÇho bloku
EditBGt5:pop       di                       ; DI <- poáet p©elomñ ©†dkñ LF
         jnc       EditBGt7                 ; operace OK

; ------ p©i chybà uvolnàn° p©idàlenÇho bloku

         call      EditGetD                 ; nov† adresa okna -> ES
         xor       ax,ax                    ; AX <- 0
         xchg      ax,es:[si+EdiBlokM]      ; uvolnàn° bloku -> AX=á°slo bloku

; ------ oznaáen° bloku, ëe je volnò

         mov       cx,ds:[EditBSN]          ; poáet blokñ v tabulce
         jcxz      EditBGt0                 ; nen° ë†dnò blok

         mov       si,offset EditBSTb       ; tabulka áetnosti
EditBG52:cmp       ax,word ptr ds:[si]      ; je to tento blok ?
         jne       EditBG54                 ; nen°
         mov       word ptr ds:[si+2],0     ; je to ru®enò blok - uvolnàn°
EditBG54:add       si,6                     ; adresa dal®°ho popisovaáe
         loop      EditBG52                 ; dal®° blok

; ------ chyba operace

EditBGt0:xor       cx,cx                    ; p©ednastaven° - ë†dn† data (-> ZY)
         stc                                ; p©°znak chyby CY (zde je ZY !)
EditBG02:jmp       EditBGt9                 ; p©ekroáen poáet blokñ souboru

; ------ spoáten° poátu ©†dkñ v bloku ES (CX=poáet bajtñ, DX=á°slo okna, SI=popis.)

EditBGt7:inc       di                       ; je poáet ©†dkñ v bloku zn†mò ?
         jnz       EditBGt8                 ; poáet ©†dkñ v bloku je zn†mò
                                          ;* DI je zde = 0 !
         push      ax
         push      bx
         push      cx
         push      es

         xor       bx,bx                    ; á°taá p©elomñ LF
         mov       al,LF                    ; hledanò znak LF
         cld
EditBG71:jcxz      EditBG74                 ; nen° dal®° znak
         repne     scasb                    ; nalezen° znaku LF
         jne       EditBG74                 ; konec hled†n° - znak nenalezen
         inc       bx                       ; zvò®en° á°taáe znakñ LF
         jmp       short EditBG71           ; pokraáov†n° v hled†n°

EditBG74:call      EditGetD                 ; adresa okna
         mov       es:[si+EdiBlokL],bx      ; uloëen° zji®tànÇho poátu ©†dkñ
         add       word ptr es:[EdiRadku],bx ; zvò®en° celkovÇho poátu ©†dkñ
         adc       word ptr es:[EdiRadku+2],0

         pop       es
         pop       cx
         pop       bx
         pop       ax

; ------ aktualizace áetnosti pouëit° bloku AX/po©adovÇ á°slo BX, okna DX

EditBGt8:call      EditBAkB                 ; aktualizace áetnosti pouëit°
         or        dx,dx                    ; p©°znak operace OK = NC a NZ

; ------ n†vrat registrñ

EditBGt9:pop       di
         pop       si
         pop       ax
         ret

EditBGet ENDP

; -----------------------------------------------------------------------------
;                                EditBCre
;        vytvo©en° datovÇho bloku -> AX (CY=nelze vytvo©it datovò blok)
;                          posouv† datovÇ bloky !
;                Pozor, neaktualizuje áetnost pouëit° bloku !
; -----------------------------------------------------------------------------
; VSTUP: DX=á°slo segmentu okna
;        BX=index bloku v souboru okna
;        DS=datovò segment
; VùSTUP: AX=á°slo segmentu vytvo©enÇho bloku
;         CY=chyba
; -----------------------------------------------------------------------------

EditBCre PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      di
         push      es

; ------ prohled†n° tabulky datovòch blokñ a nalezen° volnÇho bloku

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       di,offset EditBSTb - 2   ; zaá†tek tabulky - 2
         mov       cx,ds:[EditBSN]          ; poáet blokñ v tabulce
         jcxz      EditBCr3                 ; nen° ë†dnò datovò blok
         cld
         xor       ax,ax                    ; hledanò volnò blok
EditBCr2:add       di,2 + 2                 ; posun o poloëku
         scasw                              ; je to volnò blok ?
         loopne    EditBCr2                 ; nen° volnò blok - dal®°
         jne       EditBCr3                 ; volnò blok nenalezen

; ------ nalezen volnò blok OK

         dec       di
         dec       di                       ; n†vrat ukazatele bloku + 2
         jmp       short EditBCr8           ; uloëen° parametrñ bloku

; ------ vytvo©en° novÇho bloku -> AX (DI=adresa popisovaáe bloku - 2)

EditBCr3:cmp       word ptr ds:[EditBSN],MAXBUSE ; je jië maxim†ln° poáet blokñ ?
         jae       EditBCr5                 ; je jië maxim†ln° poáet blokñ
         push      bx
         call      far ptr GetFree          ; poskytnut° volnÇ pamàti
         cmp       bx,(BLOKBLOK+1000h+1000h)/16 ; asi tolik mus° bòt volnÇ m°sto
         jb        EditBCr4                 ; je m†lo volnÇ pamàti
         call      far ptr CreatSeg         ; vytvo©en° novÇho datovÇho segmentu
         jc        EditBCr4                 ; nelze vytvo©it novò blok
         mov       bx,BLOKBLOK              ; poëadovan† velikost bloku
         call      far ptr ModiSegS         ; nastaven° velikosti bloku
         jnc       EditBCr4                 ; blok vytvo©en OK
         call      far ptr DelSeg           ; zru®en° bloku p©i chybà
         stc                                ; p©°znak chyby
EditBCr4:pop       bx
         jc        EditBCr5                 ; nelze vytvo©it novò blok

         inc       word ptr ds:[EditBSN]    ; zvò®en° á°taáe blokñ
         cld
         inc       di
         inc       di                       ; zaá†tek volnÇ poloëky v tabulce
         stosw                              ; uloëen° á°sla bloku
         jmp       short EditBCr8           ; uloëen° parametrñ bloku

; ------ uvolnàn° nejstar®°ho bloku

EditBCr5:cmp       word ptr ds:[EditBSN],0  ; je nàjakò blok ?
         stc
         je        EditBCr9                 ; nen° ë†dnò blok

         push      bx
         push      dx
         mov       di,offset EditBSTb+2     ; ukazatel na prvn° blok
         mov       dx,ds:[di]               ; AX <- á°slo segmentu okna
         mov       bx,ds:[di+2]             ; po©adovÇ á°slo bloku v oknà
         call      EditBSto                 ; uloëen° bloku BX okna DX
         pop       dx
         pop       bx
         jc        EditBCr9                 ; chyba uloëen° bloku

; ------ za©azen° novÇho bloku do seznamu (DI=popisovaá bloku + 2)

EditBCr8:mov       ax,ds:[di-2]             ; á°slo datovÇho bloku
         mov       ds:[di],dx               ; á°slo segmentu okna
         and       byte ptr ds:[di+1],not bit15/bit8 ; nulov†n° p©°znaku okna
         mov       ds:[di+2],bx             ; á°slo bloku v tabulce okna
;         clc                                ; NC = p©°znak operace OK

; ------ n†vrat registrñ

EditBCr9:pop       es
         pop       di
         pop       cx
         ret

EditBCre ENDP

; -----------------------------------------------------------------------------
; uvolnàn° bloku BX okna DX (posouv† datovÇ bloky a nenuluje áetnost !) CY=chyba
; -----------------------------------------------------------------------------

EditBSto PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      es

; ------ adresa okna DX -> ES

         call      EditGetD                 ; adresa okna
         jc        EditBSt9                 ; chyba, neplatnò segment

; ------ adresa definice bloku -> ES:BX

         shl       bx,1
         shl       bx,1
         shl       bx,1                     ; offset v tabulce definic
         add       bx,EdiABlok              ; adresa definice bloku

; ------ test, zda byl blok modifikov†n

         test      byte ptr es:[bx+EdiBlokM+1],bit15/bit8 ; byl modifikov†n ?
         jz        EditBSt6                 ; blok nebyl modifikov†n
         cmp       word ptr es:[bx+EdiBlokN],0 ; je nàco v bloku ?
         je        EditBSt6                 ; nen° nic v bloku

; ------ test, zda je vytvo©en blok v p©echodnÇm souboru

         mov       ax,es:[bx+EdiBlokD]      ; identifik†tor bloku na disku
         or        ax,ax                    ; je p©echodnò soub. ?
         jns       EditBSt2                 ; nen° p©echodnò soubor
         cmp       ax,-1                    ; je p©idàlen blok ?
         jne       EditBSt3                 ; je p©idàlen blok p©echod. souboru

; ------ obsazen° volnÇho bloku v p©echodnÇm souboru -> AX

EditBSt2:call      EditTSrc                 ; nalezen° volnÇho bloku -> AX
         jc        EditBSt9                 ; chyba pamàti
         call      EditTSet                 ; nastaven° p©°znaku pouëit° bloku
         jc        EditBSt9                 ; chyba pamàti
         call      EditGetD                 ; nov† adresa okna DX -> ES
         mov       es:[bx+EdiBlokD],ax      ; novò identifik†tor bloku na disku

; ------ z†pis bloku do p©echodnÇho souboru (blok AX)

EditBSt3:push      es
         push      ax
         mov       ax,es:[bx+EdiBlokM]      ; identifik†tor bloku v pamàti
         and       ah,not bit15/bit8        ; nulov†n° p©°znaku modifikace
         call      far ptr GetDat           ; adresa datovÇho bloku -> ES
         pop       ax
         jc        EditBSt4                 ; neplatnò blok ? (to nenastane)
         call      EditTWri                 ; z†pis bloku do souboru
EditBSt4:pop       es
         jc        EditBSt9                 ; chyba

; ------ uvolnàn° p©idàlen° bloku (NC=operace OK)

EditBSt6:mov       word ptr es:[bx+EdiBlokM],0 ; p©°znak uvolnàn° bloku z pamàti

; ------ n†vrat registrñ

EditBSt9:pop       es
         pop       bx
         pop       ax
         ret

EditBSto ENDP

; -----------------------------------------------------------------------------
;        aktualizace áetnosti pouëit° pamàüovÇho bloku AX, index BX, soubor DX
; -----------------------------------------------------------------------------

EditBAkB PROC      NEAR

; ------ nulov†n° p©°znaku modifikace bloku

         push      ax
         and       ax,not bit15             ; je blok = 0 ?
         jz        EditBAB9                 ; neplatnò blok

; ------ inicializace, je-li to posledn°/p©edposledn° blok

;         cmp       ax,ds:[EditBLst]         ; je to posledn° pouëitò blok ?
;         je        EditBAB9                 ; je to posledn° pouëitò blok
;         push      ax
;         xchg      ds:[EditBLst],ax         ; £schova novÇho pouëitÇho bloku
;         xchg      ds:[EditBLsL],ax         ; p©edposledn° pouëitò blok
;         cmp       ax,ds:[EditBLst]         ; je to p©edposledn° blok ?
;         pop       ax
;         je        EditBAB9                 ; je to p©edposledn° blok

; ------ £schova registrñ

         push      cx
         push      si
         push      di
         push      es

; ------ p©°prava k vyhled†n° bloku v tabulce áetnosti

         cld
         mov       di,offset EditBSTb       ; tabulka áetnost° blokñ
         push      ds
         pop       es                       ; ES <- datovò segment
         mov       cx,ds:[EditBSN]          ; poáet segmentñ v tabulce

; ------ nalezen° bloku v tabulce

         jcxz      EditBAB3                 ; nen° ë†dnò blok
EditBAB2:scasw                              ; je to hledanò blok ?
         je        EditBAB4                 ; vypu®tàn° bloku
         add       di,4                     ; adresa dal®°ho bloku
         loop      EditBAB2                 ; dal®° blok
EditBAB3:inc       word ptr ds:[EditBSN]    ; zvò®en° á°taáe blokñ
         cmp       word ptr ds:[EditBSN],MAXBUSE ; je jië maximum blokñ ?
         jbe       EditBAB6                 ; poáet blokñ je OK
         dec       word ptr ds:[EditBSN]    ; sn°ëen° poátu blokñ
         sub       di,6                     ; n†vrat na posledn° blok
         jmp       short EditBAB6

; ------ vypu®tàn° nalezenÇho bloku

EditBAB4:dec       di
         dec       di                       ; n†vrat zaá†tku popisovaáe
         dec       cx                       ; zbylò poáet blokñ
         mov       si,cx                    ; SI <- zbylò poáet blokñ
         shl       cx,1                     ; CX <- poáet blokñ * 2
         add       cx,si                    ; CX <- poáet blokñ * 3
         mov       si,di                    ; adresa poloëky
         add       si,6                     ; adresa dal®° poloëky
         rep       movsw                    ; p©°sun zbylòch blokñ

; ------ uloëen° definice bloku na konec tabulky

EditBAB6:stosw                              ; uloëen° á°sla bloku
         mov       ax,dx                    ; segment s popisovaáem souboru
         and       ah,not bit15/bit8        ; nulov†n° p©°znaku á°sla okna
         stosw                              ; segment s popisovaáem souboru
         mov       ax,bx                    ; blok v souboru
         stosw                              ; á°slo bloku

; ------ n†vrat registrñ

EditBAB8:pop       es
         pop       di
         pop       si
         pop       cx

EditBAB9:pop       ax
         ret

EditBAkB ENDP

; -----------------------------------------------------------------------------
;        ©†dkovÇ menu s £schovou registrñ DX
; -----------------------------------------------------------------------------

Edi0Menu PROC      NEAR

         push      dx
         call      far ptr Lin0Menu
         pop       dx
         ret

Edi0Menu ENDP

; -----------------------------------------------------------------------------
;        adresa okna DX s £schovou p©°znakñ -> ES
; -----------------------------------------------------------------------------

EditGt0D PROC      NEAR

         pushf
         call      EditGetD                 ; adresa okna DX -> ES
         popf
         ret

EditGt0D ENDP

; -----------------------------------------------------------------------------
;        adresa okna DX -> ES (CY=neplatnÇ okno)
; -----------------------------------------------------------------------------

EditGetD PROC      NEAR

         push      ax
         mov       ax,dx                    ; AX <- á°slo segmentu okna
         and       ah,not bit15/bit8        ; nulov†n° p©°znaku okna
         call      far ptr GetDat           ; adresa okna -> ES
         pop       ax
         ret

EditGetD ENDP

; -----------------------------------------------------------------------------
;        adresa segmentu bufferu -> ES (uchov†v† p©°znaky)
; -----------------------------------------------------------------------------

EditGetB PROC      NEAR

         pushf
         push      ax
         mov       ax,ds:[EditSBuf]         ; segment bufferu
         and       ah,not bit15/bit8
         call      far ptr GetDat           ; adresa okna
         pop       ax
         popf
         ret

EditGetB ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                        Obsluha vstupn°ho souboru
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; -----------------------------------------------------------------------------
;        naáten° bloku AX vstupn°ho souboru okna DX do bufferu ES (CY=chyba)
; -----------------------------------------------------------------------------

EditIRea PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      di

; ------ test, zda je aktivn° INT 24h

         test      byte ptr ds:[ParInt24],bit3 ; prob°h† obsluha INT 24h ?
         stc                                ; p©°znak chyby operace
         jnz       EditIRe9                 ; je obsluha INT 24h

; ------ poskytnut° identifik†toru vstupn°ho souboru -> AX

         and       ah,not bit15/bit8        ; nulov†n° p©°znaku p©ech. souboru
         push      ax                       ; á°slo bloku
         call      EditIGet                 ; poskytnut° identifik†toru -> AX
         pop       dx                       ; DX <- á°slo bloku
         jc        EditIRe9                 ; nàjak† chyba

; ------ vòpoáet offsetu v souboru (z†vislÇ na velikosti bloku BLOKBLOK !)

         xor       cx,cx                    ; CX <- 0
         shr       dx,1
         rcr       cx,1                     ; á°slo bloku * 8000h (tj. * 32 KB)

; ------ nastaven° ukazatele v souboru DX:CX

         call      far ptr SetUFile         ; nastaven° ukazatele v souboru
         jc        EditIRe9                 ; nàjak† chyba

; ------ naáten° dat ze souboru (mñëe bòt naáteno i mÇnà neë celò blok)

         mov       cx,BLOKBLOK              ; velikost jednoho bloku
         xor       di,di                    ; adresa zaá†tku bufferu
         call      far ptr ReadFile         ; naáten° bloku dat ze souboru

; ------ n†vrat registrñ

EditIRe9:pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

EditIRea ENDP

; -----------------------------------------------------------------------------
;        poskytnut° identifik†toru vstupn°ho souboru okna DX -> AX (CY chyba)
; -----------------------------------------------------------------------------

EditIGet PROC      NEAR

; ------ identifik†tor vstupn°ho souboru

         push      es
         call      EditGetD                 ; adresa okna DX
         jc        EditIGt1                 ; neplatnÇ á°slo okna ?
         mov       ax,es:[EdiIdent]         ; identifik†tor vstupn°ho souboru
         or        ax,ax                    ; je soubor otev©en ?
         jz        EditIGt2                 ; soubor nen° otev©en
EditIGt1:pop       es
         ret

; ------ £schova registrñ (ES=segment okna)

EditIGt2:push      si

; ------ test, zda je aktivn° INT 24h

         test      byte ptr ds:[ParInt24],bit3 ; prob°h† obsluha INT 24h ?
         stc                                ; p©°znak chyby operace
         jnz       EditIGt9                 ; je obsluha INT 24h

; ------ otev©en° souboru pro áten°

         mov       si,EdiSoub               ; jmÇno souboru
         call      far ptr OpenR            ; otev©en° souboru pro áten°
         jnc       EditIGt8                 ; soubor otev©en OK

; ------ uvolnàn° nàkterÇho identifik†toru souboru a novò pokus

         call      EditFFre                 ; uvolnàn° identifik†toru souboru
         call      far ptr OpenR            ; novò pokus o otev©en°
         jc        EditIGt9                 ; chyba - soubor nelze otev©°t
EditIGt8:mov       es:[EdiIdent],ax         ; identifik†tor souboru

; ------ n†vrat registrñ

EditIGt9:pop       si
         pop       es
         ret

EditIGet ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                      Obsluha p©echodnÇho souboru
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; -----------------------------------------------------------------------------
;        z†pis bloku AX p©echodnÇho souboru z bufferu ES:0 (CY=chyba)
; -----------------------------------------------------------------------------

EditTWri PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si

; ------ test, zda je aktivn° INT 24h

         test      byte ptr ds:[ParInt24],bit3 ; prob°h† obsluha INT 24h ?
         stc                                ; p©°znak chyby operace
         jnz       EditTWr9                 ; je obsluha INT 24h

; ------ vòpoáet offsetu v souboru (z†vislÇ na velikosti bloku BLOKBLOK !)

         and       ah,not bit15/bit8        ; nulov†n° p©°znaku p©ech. souboru
         xchg      ax,dx                    ; DX <- á°slo poëadovanÇho bloku
         xor       cx,cx                    ; CX <- 0
         shr       dx,1
         rcr       cx,1                     ; á°slo bloku * 8000h (tj. * 32 KB)

; ------ poskytnut° identifik†toru p©echodnÇho souboru

         call      EditTGet                 ; poskytnut° identifik†toru
         jc        EditTWr9                 ; nàjak† chyba

; ------ nastaven° ukazatele v souboru DX:CX

         call      far ptr SetUFile         ; nastaven° ukazatele v souboru
         jc        EditTWr9                 ; nàjak† chyba

; ------ z†pis dat do souboru

         mov       cx,BLOKBLOK              ; velikost jednoho bloku
         xor       si,si                    ; adresa zaá†tku bufferu
         call      far ptr WritFile         ; z†pis bloku dat do souboru

; ------ n†vrat registrñ

EditTWr9:pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

EditTWri ENDP

; -----------------------------------------------------------------------------
;        naáten° bloku AX p©echodnÇho souboru do bufferu ES:0 (CY=chyba)
; -----------------------------------------------------------------------------

EditTRea PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      di

; ------ test, zda je aktivn° INT 24h

         test      byte ptr ds:[ParInt24],bit3 ; prob°h† obsluha INT 24h ?
         stc                                ; p©°znak chyby operace
         jnz       EditTRe9                 ; je obsluha INT 24h

; ------ vòpoáet offsetu v souboru (z†vislÇ na bloku BLOKBLOK !) -> DX:CX

         and       ah,not bit15/bit8        ; nulov†n° p©°znaku p©ech. souboru
         xchg      ax,dx                    ; DX <- á°slo poëadovanÇho bloku
         xor       cx,cx                    ; CX <- 0
         shr       dx,1
         rcr       cx,1                     ; á°slo bloku * 8000h (tj. * 32 KB)

; ------ poskytnut° identifik†toru p©echodnÇho souboru

         call      EditTGet                 ; poskytnut° identifik†toru
         jc        EditTRe9                 ; nàjak† chyba

; ------ nastaven° ukazatele v souboru DX:CX

         call      far ptr SetUFile         ; nastaven° ukazatele v souboru
         jc        EditTRe9                 ; nàjak† chyba

; ------ naáten° dat ze souboru (mus° bòt naáten plnò blok !)

         mov       cx,BLOKBLOK              ; velikost jednoho bloku
         xor       di,di                    ; adresa zaá†tku bufferu
         call      far ptr Read0Fil         ; nucenÇ naáten° bloku dat

; ------ n†vrat registrñ

EditTRe9:pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

EditTRea ENDP

; -----------------------------------------------------------------------------
;        oznaáen° bloku AX p©echodnÇho souboru za pouëitò (CY=chyba pamàti)
; -----------------------------------------------------------------------------
;   (blok mñëe bòt vy®®° pouze o 1 oproti souáasnÇmu poátu blokñ !)
; (á°slo bloku mus° bòt zkontrolov†no na moënost p©eteáen° max. blokñ !)
;               POZOR - mñëe posunout jinÇ datovÇ bloky !
; -----------------------------------------------------------------------------

EditTSet PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      es

; ------ adresa segmentu mapy p©echodnÇho souboru -> ES

         call      EditTSeg                 ; adresa mapy p©echodnÇho souboru
         jc        EditTSt9                 ; nedostatek pamàti

; ------ kontrola, zda je zvàt®en° poátu blokñ v souboru

         and       ah,not bit15/bit8        ; nulov†n° p©°znaku p©ech. souboru
         mov       cx,ax                    ; CX <- £schova á°sla bloku
         cmp       ax,ds:[EditTmpN]         ; zvyëuje se poáet blokñ ?
         jb        EditTSt6                 ; poáet blokñ se nezvy®uje
         test      al,bit0+bit1+bit2        ; bude to novò bajt ?
         jnz       EditTSt5                 ; nen° to novò bajt

; ------ zvò®en° velikosti bloku mapy

         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; poáet bajtñ v segmentu - 1
         inc       ax                       ; poáet bajtñ v segmentu
         xchg      ax,bx                    ; BX <- poáet bajtñ v segmentu
         mov       ax,ds:[EditTmpS]         ; segment mapy souboru
         call      far ptr ModiSegS         ; nastaven° novÇ velikosti bloku
         jc        EditTSt9                 ; nedostatek pamàti
         mov       byte ptr es:[bx-1],0     ; inicializace novÇho bajtu
         mov       ax,cx                    ; AX <- á°slo novÇho bloku

EditTSt5:inc       word ptr ds:[EditTmpN]   ; zvò®en° poátu blokñ v souboru

; ------ nastaven° p©°znaku obsazen° bloku AX, CX

EditTSt6:shr       ax,1
         shr       ax,1
         shr       ax,1                     ; á°slo bloku / 8 -> offset
         xchg      ax,bx                    ; BX <- index v tabulce mapy
         and       cl,7                     ; á°slo bitu v bajtu
         mov       al,bit0                  ; maska
         shl       al,cl                    ; rotace masky na pozici
         or        es:[bx],al               ; nastaven° p©°znaku obsazen° bloku
                                          ;* NC=p©°znak operace OK
; ------ n†vrat registrñ

EditTSt9:pop       es
         pop       cx
         pop       bx
         pop       ax
         ret

EditTSet ENDP

; -----------------------------------------------------------------------------
;        nulov†n° (uvolnàn°) bloku AX p©echodnÇho souboru (CY=chyba)
; -----------------------------------------------------------------------------

EditTRes PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      es

; ------ adresa segmentu mapy p©echodnÇho souboru -> ES

         call      EditTSeg                 ; adresa mapy p©echodnÇho souboru
         jc        EditTRs9                 ; chyba

; ------ nulov†n° p©°znaku novÇho bloku

         and       ah,not bit15/bit8        ; nulov†n° p©°znaku p©ech. souboru
         cmp       ax,ds:[EditTmpN]         ; je to platnÇ á°slo bloku ?
         jae       EditTRs9                 ; nen° to platnÇ á°slo bloku
         mov       cx,ax                    ; CX <- á°slo bloku
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; á°slo bloku / 8 -> offset
         xchg      ax,bx                    ; BX <- index v tabulce mapy
         and       cl,7                     ; á°slo bitu v bajtu
         mov       al,not bit0              ; maska
         rol       al,cl                    ; rotace masky na pozici
         and       es:[bx],al               ; nulov†n° p©°znaku obsazen° bloku
                                          ;* NC=p©°znak operace OK
; ------ n†vrat registrñ

EditTRs9:pop       es
         pop       cx
         pop       bx
         pop       ax
         ret

EditTRes ENDP

; -----------------------------------------------------------------------------
;        nalezen° volnÇho bloku p©echodnÇho souboru -> AX (bit 15 nastaven) (CY)
; -----------------------------------------------------------------------------

EditTSrc PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      di
         push      es

; ------ adresa segmentu mapy -> ES

         call      EditTSeg                 ; adresa segmentu mapy
         jc        EditTSr9                 ; asi nedostatek pamàti

; ------ nalezen° volnÇho bloku -> ES:DI, AH=maska

         xor       di,di                    ; zaá†tek segmentu mapy
         mov       cx,ds:[EditTmpN]         ; poáet blokñ v mapà
         add       cx,7                     ; zarovn†n° nahoru na bajty
         shr       cx,1
         shr       cx,1
         shr       cx,1                     ; poáet blokñ/8 -> poáet bajtñ
         mov       ax,0ffh                  ; hled† se <> 0FFh, AH=0 maska
         cld
                                          ;* pro CX = 0 je zde nastaven ZY !
         repe      scasb                    ; nalezen° volnÇho bloku
         je        EditTSr5                 ; blok nebyl nalezen
         dec       di                       ; ukazatel na posledn° nalezenò bajt
         mov       ah,es:[di]               ; nalezenò posledn° blok

; ------ vòpoáet á°sla bloku

EditTSr5:shl       di,1
         shl       di,1
         shl       di,1                     ; á°slo bloku zaokrouhlenà na 8
         mov       al,bit0                  ; maska pro test
EditTSr6:test      ah,al                    ; nalezen volnò blok ?
         jz        EditTSr7                 ; nalezen volnò blok
         shl       al,1                     ; rotace masky
         inc       di                       ; zvò®en° ukazatele blokñ
         jmp       short EditTSr6           ; test dal®°ho bloku

; ------ kontrola a korekce á°sla bloku (max. povolenÇ á°slo bloku 7FFEh)

EditTSr7:xchg      ax,di                    ; AX <- á°slo nalezenÇho bloku
         cmp       ax,7fffh                 ; je p©eteáen° á°sla bloku ?
         cmc                                ; CY = neplatnÇ á°slo bloku
         jc        EditTSr9                 ; chyba - neplatnÇ á°slo bloku
         or        ah,bit15/bit8            ; p©°znak p©echodnÇho souboru

; ------ n†vrat registrñ

EditTSr9:pop       es
         pop       di
         pop       cx
         ret

EditTSrc ENDP

; -----------------------------------------------------------------------------
;        poskytnut° adresy mapy p©echodnÇho souboru -> ES (CY chyba)
; -----------------------------------------------------------------------------

EditTSeg PROC      NEAR

         push      ax
         mov       ax,ds:[EditTmpS]         ; segment mapy p©echodnÇho souboru
         or        ax,ax                    ; je segment vytvo©en ?
         jnz       EditTSg2                 ; segment je vytvo©en OK
         call      far ptr CreatSeg         ; vytvo©en° segmentu mapy
         jc        EditTSg4                 ; chyba pamàti
         mov       ds:[EditTmpS],ax         ; á°slo sgmentu mapy
         mov       word ptr ds:[EditTmpN],0 ; nen° ë†dnò blok

EditTSg2:call      far ptr GetDat           ; adresa segmentu mapy

EditTSg4:pop       ax
         ret

EditTSeg ENDP

; -----------------------------------------------------------------------------
;        poskytnut° identifik†toru p©echodnÇho souboru AX (a p©°p. vytvo©en°)
; -----------------------------------------------------------------------------

EditTGet PROC      NEAR

; ------ test, zda je soubor jië otev©en

         mov       ax,ds:[EditTemp]         ; identifik†tor p©echodnÇho souboru
         or        ax,ax                    ; je p©echodnò soubor jië otev©en ?
         jnz       EditTGt0                 ; p©echodnò soubor je otev©en

; ------ test, zda je aktivn° INT 24h

         test      byte ptr ds:[ParInt24],bit3 ; prob°h† obsluha INT 24h ?
         stc
         jnz       EditTGt0                 ; je obsluha INT 24h

; ------ £schova registrñ

         push      si
         push      es

; ------ je-li soubor vytvo©en, pouze jeho otev©en°

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       si,offset EditTmpJ       ; jmÇno p©echodnÇho souboru
         test      byte ptr ds:[EditParm],bit7 ; je p©echodnò soubor vytvo©en ?
         jz        EditTGt4                 ; p©echodnò soubor nen° vytvo©en
         call      far ptr OpenRW           ; otev©en° pro áten° i z†pis
         jnc       EditTGt8                 ; soubor otev©en OK
         call      EditFFre                 ; uvolnàn° identifik†toru souboru
         jc        EditTGt9                 ; nelze uvolnit identifik†tor
         call      far ptr OpenRW           ; novò pokus o otev©en°
         jmp       short EditTGt6

; ------ vytvo©en° p©echodnÇho souboru

EditTGt4:test      byte ptr ds:[TempDirP],bit0 ; je z†kaz z†pisu ?
         stc                                ; p©°znak chyby
         jnz       EditTGt9                 ; je z†kaz z†pisu
         call      far ptr CreatTmp         ; vytvo©en° p©echodnÇho souboru
         jnc       EditTGt7                 ; soubor vytvo©en OK

; ------ uvolnàn° identifik†toru souboru a novò pokus

         call      EditFFre                 ; uvolnàn° identifik†toru souboru
         jc        EditTGt9                 ; nelze uvolnit identifik†tor
         call      far ptr CreatTmp         ; vytvo©en° p©echodnÇho souboru
EditTGt6:jc        EditTGt9                 ; chyba vytvo©en° p©echod. souboru
EditTGt7:or        byte ptr ds:[EditParm],bit7 ; p©°znak vytvo©en° souboru
EditTGt8:mov       ds:[EditTemp],ax         ; identifik†tor p©echod. souboru

; ------ n†vrat registrñ

EditTGt9:pop       es
         pop       si
EditTGt0:ret

EditTGet ENDP

; -----------------------------------------------------------------------------
;        uzav©en° p©echodnÇho souboru p©i ukonáen° editace (posouv† bloky !)
; -----------------------------------------------------------------------------

EditTClo PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      si
         push      es

; ------ uzav©en° p©echodnÇho souboru

         mov       ax,ds:[EditTemp]         ; identifik†tor p©echodnÇho souboru
         call      far ptr ClosFile         ; uzav©en° p©echodnÇho souboru
         mov       ds:[EditTemp],ax         ; oznaáen°, ëe je soubor uzav©en

; ------ zru®en° p©echodnÇho souboru

         test      byte ptr ds:[EditParm],bit7 ; je p©echodnò soubor vytvo©en ?
         jz        EditTCl4                 ; p©echodnò soubor nen° vytvo©en
         push      ds
         pop       es                       ; ES <- datovò segment
         mov       si,offset EditTmpJ       ; jmÇno p©echodnÇho souboru
         call      far ptr DelFile          ; zru®en° p©echodnÇho souboru
         and       byte ptr ds:[EditParm],not bit7 ; p©echod.soub.nen° vytvo©en

; ------ zru®en° segmentu mapy p©echodnÇho souboru

EditTCl4:mov       ax,ds:[EditTmpS]         ; segment mapy
         call      far ptr DelSeg           ; zru®en° segmentu mapy
         mov       ds:[EditTmpS],ax

; ------ n†vrat registrñ

         pop       es
         pop       si
         pop       ax
         ret

EditTClo ENDP

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

; ------ definice p©echodnÇho souboru

;EditTmpF db        12,'$DOSMAN$.TMP',0      ; jmÇno p©echodnÇho souboru (vzor)
EditTmpJ label     byte
         db        FileMax dup(0)           ; plnÇ jmÇno p©echodnÇho souboru

EditTemp dw        0                        ; identifik†tor p©echodnÇho souboru
                                            ;   (0=nen° otev©en)
EditTmpS dw        0                        ; segment alokac° p©echod. souboru
                                            ;   (0=nen° vytvo©en)
                                            ; V segmentu alokac° p©°slu®° kaëdÇmu
                                            ; bloku souboru 1 bit: 1=blok obsazen

EditTmpN dw        0                        ; poáet blokñ 32 KB v p©echod. soub.

; ------ evidence pouëitòch blokñ (pro optimalizaci uvol§ov†n°)

;EditBLst dw        0                        ; posledn° pouëitò datovò blok (bit 15 = 0 !)
;EditBLsL dw        0                        ; p©edposledn° pouëitò datovò blok (bit 15 = 0 !)
EditBSN  dw        0                        ; poáet segmentñ blokñ v tabulce
EditBSTb label     word
         dw        3 * MAXBUSE dup(0)       ; tabulka pouëitòch blokñ (32 blokñ)

                                            ; (posledn° blok v tabulce je
                                            ;  posledn° pouëitò blok !)

; Struktura tabulky: 0: (2) segment datovÇho bloku (bit 15 = 0)
;                    2: (2) segment s popisovaáem souboru=okno (0=blok je volnò)
;                            bit 15 je vëdy = 0 ! (tj. vëdy jako okno 1)
;                    4: (2) á°slo bloku v souboru (á°slo v tabulce blokñ)

Data     ENDS

         END

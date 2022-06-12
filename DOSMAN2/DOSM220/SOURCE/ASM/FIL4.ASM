
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                              F I L E  -  4
;
;                 Obsluha souborñ - Informace, Modifikace, Program
;
; =============================================================================
;
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

INCLUDE  ASM\DEF.ASM

CodeFil  SEGMENT   BYTE PUBLIC
         ASSUME    cs:CodeFil,ds:Data

; *****************************************************************************
;
;                   Informace o souboru (volba "Informace")
;
; *****************************************************************************
;˛
AWMMnuSI LABEL     FAR

; ------ p©°prava k obsluze

         add       sp,4                     ; zru®en° n†vratovÇ adresy
         call      far ptr ClosMnuA         ; uzav©en° v®ech oken menu

InfoFile LABEL     FAR

         mov       byte ptr ds:[SIMnuLin+MnuAkt],1 ; aktivn° poloëka
         call      far ptr QSrcEnd          ; ukonáen° rychlovyhled†v†n°
         call      far ptr HistADir         ; uloëen° adres†©e do historie

; ------ test, zda je platn† poloëka pod kurzorem

         call      InfoTest                 ; test platnosti poloëky pod kurzorem
         jnc       InfoFl11                 ; je to platn† poloëka OK
InfoFil0:jmp       far ptr Main0

; ------ p©°prava poloëky

InfoFl11:call      InfoPath                 ; p©°prava cesty k poloëce
         call      InfoPMnu                 ; z†kaz voleb menu
         call      InfoRead                 ; naáten° informaán°ho souboru
         call      InfoParm                 ; p©°prava parametrñ poloëky (naáten°)
InfoFl12:call      InfPDek                  ; dek¢dov†n° parametrñ poloëky

; ------ obsluha menu

         call      far ptr DispAAWn         ; zobrazen° aktivn°ho okna
         mov       si,offset SIMnuLin
         call      far ptr Lin1Menu

         call      far ptr JumpBX           ; obsluha kl†vesy

         dw        1,InfoFil2               ; zad†n° koment†©e k poloëce
         dw        2,InfoFil4               ; editace popisu

         dw        5,InfoFil5               ; redukce poloëek
         dw        6,InfoFil3               ; zad†n° nadpisu adres†©e
         dw        0,InfoFil0               ; p©eru®en°

; -----------------------------------------------------------------------------
;        redukce koment†©ñ
; -----------------------------------------------------------------------------

; ------ potvrzen° operace

InfoFil5:mov       si,offset InfoRMnu       ; menu - redukce poloëek
         call      far ptr Lin0MenF         ; potvrzen° operace
         jnc       InfoFl51
InfoFl50:jmp       InfoFil0

; ------ segment koment†©ñ (test, zda je platnò) -> AX/ES

InfoFl51:call      far ptr GetAAWin         ; adresa aktivn°ho okna
         mov       ax,es:[AWinKomS]         ; segment koment†©ñ
         call      far ptr GetDat           ; adresa segmentu koment†©ñ
         jc        InfoFl50                 ; neplatnò segment

; ------ proveden° redukce

         call      InfoRed                  ; redukce koment†©ñ
         jmp       InfoFil0

; -----------------------------------------------------------------------------
;        redukce koment†©ñ (neuchov†v† registry !)
; -----------------------------------------------------------------------------
; VSTUP: AX=segment koment†©ñ (aktivn°ho okna)
;        ES=adresa segmentu koment†©ñ
; lok†ln° promànnÇ: SS:[BP-2] (2) á°slo segmentu koment†©ñ
;                   SS:[BP-4] (2) adresa segmentu koment†©ñ
; -----------------------------------------------------------------------------

InfoRed  PROC      NEAR

; ------ p©°prava registrñ

         mov       bp,sp
         sub       sp,4
         mov       ss:[bp-2],ax             ; á°slo segmentu koment†©ñ
         mov       ss:[bp-4],es             ; adresa segmentu koment†©ñ
         mov       si,2                     ; ukazatel dat koment†©ñ

; ------ test, zda jsou nàjakÇ dal®° ©†dky

InfoRed1:mov       es,ss:[bp-4]             ; ES <- adresa segmentu koment†©ñ
         cmp       si,es:[0]                ; bude dal®° ©†dek ?
         jb        InfoRd12
         jmp       InfoRed9                 ; nen° dal®° ©†dek
InfoRd12:mov       di,si                    ; DI <- £schova zaá†tku koment†©ñ

; ------ posun ukazatele na dal®° ©†dek -> SI

InfoRed2:mov       al,es:[si]               ; dÇlka ©†dku
         mov       ah,0
         inc       si                       ; ukazatel na zaá†tek textu
         add       si,ax                    ; adresa dal®°ho ©†dku

; ------ test, zda je dal®° ©†dek

         cmp       si,es:[0]                ; bude dal®° ©†dek ?
         jae       InfoRed3                 ; nebude dal®° ©†dek

; ------ test, zda je jië platnò ©†dek dal®°ho koment†©e

         mov       al,es:[si+1]             ; prvn° znak ©†dku
         cmp       al,0
         je        InfoRed2                 ; pr†zdnò ©†dek nen° platnò
         cmp       al," "
         je        InfoRed2
         cmp       al,TAB
         je        InfoRed2

; ------ ochrana p©ed zru®en°m nadpisu

InfoRed3:cmp       di,2                     ; je to prvn° ©†dek ?
         jne       InfoRd32                 ; nen° to prvn° ©†dek
         cmp       byte ptr es:[di+1]," "   ; je nadpis ?
         jbe       InfoRed1                 ; je to nadpis

; ------ p©°prava k vyhled†n° indexu poloëky

InfoRd32:call      far ptr GetAAWin         ; adresa aktivn°ho okna -> ES
         mov       cx,es:[AWinSouN]         ; poáet zobrazenòch poloëek
         mov       bx,word ptr es:[AWinKomI] ; tabulka indexñ - OFFSET
         mov       ax,es                    ; AX <- segment okna
         add       ax,word ptr es:[AWinKomI+2] ; segment tabulky indexñ
         mov       es,ax                    ; ES <- segment tabulky indexñ

; ------ vyhled†n° indexu koment†©e v tabulce

         jcxz      InfoRed6                 ; nen° nic zobrazeno
InfoRed4:cmp       di,es:[bx]               ; minim†ln° adresa
         jae       InfoRed5                 ; index nesouhlas°
         cmp       si,es:[bx]               ; maxim†ln° adresa
         jae       InfoRed1                 ; index nalezen OK - dal®°
InfoRed5:inc       bx
         inc       bx                       ; zvò®en° ukazatele v tabulce
         loop      InfoRed4                 ; test dal®°ho indexu

; ------ index nenalezen - vypu®tàn° koment†©e (poá†tek DI, konec SI)

InfoRed6:mov       cx,si                    ; CX <- adresa konce koment†©e
         sub       cx,di                    ; dÇlka ru®enÇho koment†©e
         mov       ax,ss:[bp-2]             ; á°slo segmentu koment†©ñ
         call      far ptr DelDat           ; zru®en° dat z bufferu

; ------ korekce ukazatelñ koment†©ñ

         call      far ptr GetAAWin         ; adresa aktivn°ho okna
         sub       es:[AWinKomN],cx         ; sn°ëen° poátu bajtñ v bufferu

; ------ p©°prava ke korekci tabulky indexñ

         mov       dx,cx                    ; DX <- korekce tabulky indexñ
         mov       cx,es:[AWinSouN]         ; poáet zobrazenòch poloëek
         mov       bx,word ptr es:[AWinKomI] ; tabulka indexñ - OFFSET
         mov       ax,es                    ; AX <- segment okna
         add       ax,word ptr es:[AWinKomI+2] ; segment tabulky indexñ
         mov       es,ax                    ; ES <- segment tabulky indexñ

; ------ korekce tabulky indexñ

         xchg      si,di                    ; SI <- zaá†tek, DI <- konec
         jcxz      InfoRd82                 ; nen° nic zobrazeno
InfoRed7:cmp       di,es:[bx]               ; maxim†ln° adresa
         ja        InfoRed8                 ; nen° za ru®enòm koment†©em
         sub       es:[bx],dx               ; korekce indexu
InfoRed8:inc       bx
         inc       bx                       ; zvò®en° ukazatele v tabulce
         loop      InfoRed7                 ; korekce dal®°ho indexu
InfoRd82:jmp       InfoRed1                 ; dal®° koment†©

; ------ uloëen° souboru FILEINFO

InfoRed9:mov       ax,ds:[SegmAkt]          ; aktivn° okno
         call      far ptr InitFKom         ; inicializace adres koment†©ñ
         call      far ptr WritFKom         ; uloëen° souboru FILEINFO

; ------ n†vrat registrñ

         mov       sp,bp
         ret

InfoRed  ENDP

; -----------------------------------------------------------------------------
;        zad†n° koment†©e k poloëce
; -----------------------------------------------------------------------------

; ------ adresa indexu koment†©e -> ES:DI

InfoFil2:call      far ptr GetAAWin         ; adresa aktivn°ho okna
         mov       dx,es:[AWinKomS]         ; segment koment†©ñ
         mov       di,es:[AWinKurz]         ; kurzor
         shl       di,1                     ; offset v tabulce indexñ
         add       di,word ptr es:[AWinKomI] ; offset indexu koment†©e
         mov       ax,es                    ; segment okna
         add       ax,word ptr es:[AWinKomI+2] ; segment indexu koment†©e
         mov       es,ax                    ; ES <- segment indexu koment†©e

; ------ adresa koment†©e k poloëce -> ES:DI

         mov       byte ptr ds:[SIKMnPN1],0 ; p©ednastaven° - nen° koment†©
         mov       di,es:[di]               ; adresa koment†©e
         or        di,di                    ; je koment†© definov†n ?
         jz        InfoFl26                 ; koment†© nen° definov†
         xchg      ax,dx                    ; AX <- segment koment†©ñ
         call      far ptr GetDat           ; adresa koment†©ñ
         jc        InfoFl26                 ; koment†©e nejsou
         mov       word ptr ds:[SIKMnPA1],di ; offset koment†©e
         mov       word ptr ds:[SIKMnPA1+2],es ; segment koment†©ñ

; ------ dÇlka koment†©e ES:DI -> CX

         xor       cx,cx                    ; CX <- 0  á°taá dÇlky
         dec       cx
         dec       di
InfoFl24:inc       di                       ; zvò®en° ukazatele textu
         inc       cx                       ; zvò®en° á°taáe dÇlky
         cmp       es:[di],ch               ; konec ?
         jne       InfoFl24                 ; nalezen° konce textu
         mov       byte ptr ds:[SIKMnPD1],cl ; dÇlka koment†©e
         inc       byte ptr ds:[SIKMnPN1]   ; je 1 p©edvolba

; ------ zad†n° novÇho koment†©e poloëky

InfoFl26:mov       si,offset SIKMnLin       ; menu
         call      far ptr Lin0Menu         ; zad†n° novÇho koment†©e
         jc        InfoFl29                 ; p©eru®en° operace

; ------ uloëen° zadanÇho koment†©e

         mov       ax,ds:[SegmAkt]          ; segment okna
         call      far ptr StorFKom         ; uloëen° zadanÇho koment†©e

InfoFl29:jmp       InfoFil0                 ; n†vrat z menu

; -----------------------------------------------------------------------------
;        zad†n° nadpisu adres†©e
; -----------------------------------------------------------------------------

; ------ p©°prava koment†©e nadpisu

InfoFil3:call      far ptr GetAAWin         ; adresa aktivn°ho okna
         mov       di,es:[AWinKomA]         ; adresa nadpisu
         mov       cx,es:[AWinKomD]         ; dÇlka nadpisu
         mov       byte ptr ds:[SINMnPN1],0 ; p©ednastaven° - nen° p©edvolba
         or        di,di                    ; je koment†© definov†n ?
         jz        InfoFl32                 ; koment†© nen° definov†n
         jcxz      InfoFl32                 ; koment†© m† dÇlku 0
         mov       ax,es:[AWinKomS]         ; segment koment†©ñ
         call      far ptr GetDat           ; adresa koment†©ñ
         jc        InfoFl32                 ; neplatnò segment
         mov       ds:[SINMnPD1],cx         ; dÇlka koment†©e
         mov       word ptr ds:[SINMnPA1],di; offset koment†©e
         mov       word ptr ds:[SINMnPA1+2],es ; segment koment†©ñ
         inc       byte ptr ds:[SINMnPN1]   ; 1 p©edvolba

; ------ zad†n° novÇho koment†©e poloëky

InfoFl32:mov       si,offset SINMnLin
         call      far ptr Lin0Menu         ; zad†n° novÇho koment†©e
         jc        InfoFl34                 ; p©eru®en° operace

; ------ uloëen° zadanÇho nadpisu

         mov       ax,ds:[SegmAkt]          ; segment okna
         call      far ptr StorNKom         ; uloëen° zadanÇho koment†©e

InfoFl34:jmp       short InfoFl29           ; n†vrat

; -----------------------------------------------------------------------------
;        dal®° poloëka v oknà
; -----------------------------------------------------------------------------

InfoMDal PROC      FAR

         push      bx
         mov       bx,5000h                 ; k¢d kl†vesy dolñ

InfoMDl1:push      cx

         mov       ch,1                     ; maxim†ln° poáet pokusñ
InfoMDl2:push      bx
         call      far ptr EditAWin         ; editace aktivn°ho okna
         pop       bx
         call      InfoTest                 ; test platnosti poloëky
         jnc       InfoMDl3                 ; poloëka je platn† OK
         loop      InfoMDl2                 ; dal®° pokus
         xor       bx,5000h XOR 4800h       ; zmàna smàru
         mov       ch,2
         jmp       short InfoMDl2

InfoMDl3:call      InfoPath                 ; p©°prava cesty k poloëce
         call      InfoPMnu                 ; z†kaz voleb menu
         call      InfoParm                 ; p©°prava parametrñ poloëky (naáten°)
         call      InfPDek                  ; dek¢dov†n° parametrñ poloëky

         call      far ptr DispAll          ; novÇ zobrazen° v®eho

InfoMDl9:pop       cx
         pop       bx
         ret

InfoMDal ENDP

; -----------------------------------------------------------------------------
;        p©edchoz° poloëka v oknà
; -----------------------------------------------------------------------------

InfoMPre PROC      FAR

         push      bx

         mov       bx,4800h                 ; k¢d kl†vesy nahoru
         jmp       short InfoMDl1           ; posun nahoru

InfoMPre ENDP

; -----------------------------------------------------------------------------
;        test platnosti poloëky pod kurzorem (CY=neplatn†)
; -----------------------------------------------------------------------------

InfoTest PROC      NEAR

; ------ £schova registrñ

         push      si
         push      es

; ------ test platnosti poloëky

         call      far ptr TestAAWn         ; test aktivn°ho okna
         jc        InfoTst2                 ; nen° zapnuto
         call      far ptr GetAKurz         ; poskytnut° adresy kurzoru
         jc        InfoTst2                 ; nen° poloëka pod kurzorem
         test      byte ptr es:[si+FileAtr],ATRT ; je to platn† poloëka ?
         jnz       InfoTst2                 ; je to platn† poloëka OK
         stc                                ; p©°znak, ëe nen° platn† poloëka

; ------ n†vrat registrñ

InfoTst2:pop       es
         pop       si
         ret

InfoTest ENDP

; -----------------------------------------------------------------------------
;        p©°prava cesty k poloëce pod kurzorem
; -----------------------------------------------------------------------------

InfoPath PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      si
         push      di
         push      es

; ------ uloëen° cesty aktivn°ho adres†©e

         mov       si,offset AktPath        ; aktivn° cesta
         mov       di,offset FilePath       ; buffer jmÇna souboru
         mov       cx,ds:[AktPathN]         ; dÇlka aktivn°ho adres†©e
         push      ds
         pop       es                       ; ES <- datovò segment
         cld
         inc       cx                       ; váetnà koncovÇ 0
         rep       movsb                    ; £schova aktivn°ho adres†©e
         dec       di                       ; n†vrat ukazatele na koncovou 0

; ------ test, zda se p©id†v† jmÇno poloëky pod kurzorem

         call      far ptr GetAAWin         ; adresa aktivn°ho okna -> ES
         test      byte ptr es:[AWinPrm1],bit4 ; je to strom ?
         jnz       InfoPth6                 ; je to strom - poloëka je v cestà
         call      far ptr GetAKurz         ; poskytnut° adresy kurzoru
         cmp       byte ptr es:[si+FileName],"." ; je to ".." ?
         je        InfoPth6                 ; je to ".." - je jië poloëka

; ------ zaji®tàn° oddàlovaáe "\"

         cmp       byte ptr ds:[di-1],"\"   ; je cesta ukonáena "\" ?
         je        InfoPth2                 ; poloëka je ukonáena "\" OK
         mov       byte ptr ds:[di],"\"     ; oddàlovaá cesty
         inc       di

; ------ dek¢dov†n° jmÇna poloëky ES:SI

InfoPth2:push      ds
         push      ds
         push      es
         pop       ds                       ; DS <- segment poloëky
         pop       es                       ; ES <- datovò segment (buffer)
         inc       si                       ; zaá†tek jmÇna souboru
         call      far ptr FileAsc          ; dek¢dov†n° jmÇna poloëky na ASCII
         pop       ds

; ------ dÇlka textu cesty (se jmÇnem poloëky)

InfoPth6:sub       di,offset FilePath
         mov       ds:[FileFilN],di         ; dÇlka textu cesty s poloëkou
         mov       ds:[FilePthN],di

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       si
         pop       cx
         ret

InfoPath ENDP

; -----------------------------------------------------------------------------
;        p©°prava voleb
; -----------------------------------------------------------------------------

InfoPMnu PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      si
         push      es

; ------ p©ednastaven° - povolen° v®ech voleb

         and       word ptr ds:[SIMnLBlk],not bit1+HI*bit1 ; "Koment†©" a "Editace"
         and       word ptr ds:[SIMnLBlk+2],not bit1+HI*bit1 ; "Dal®°" a "P©edchoz°"
         and       word ptr ds:[SIMnLBlk+4],not bit1+HI*bit1 ; "Redukce" a "Adres†©"

; ------ z†kaz volby "Dal®°", je-li posledn° poloëka v oknà

         call      far ptr GetAAWin         ; adresa aktivn°ho okna -> ES
         mov       bx,es:[AWinKurz]         ; kurzor
         inc       bx                       ; n†sleduj°c° poloëka
         cmp       bx,es:[AWinSouN]         ; je dal®° poloëka ?
         jb        InfoPMn2                 ; bude dal®° poloëka
         or        byte ptr ds:[SIMnLBlk+2],bit1 ; z†kaz volby "Dal®°"

; ------ z†kaz volby "P©edchoz°", je-li prvn° poloëka nebo nebude-li platn† poloëka

InfoPMn2:dec       bx                       ; n†vrat á°sla kurzoru
         jz        InfoPMn4                 ; je to jië prvn° poloëka - z†kaz
         dec       bx                       ; p©ipraven† p©°®t° poloëka
         jnz       InfoPMn6                 ; nebude je®tà prvn° poloëka - asi OK
         call      far ptr GetESPol         ; adresa p©°®t° poloëky
         test      byte ptr es:[si+FileAtr],ATRT ; bude to platn† poloëka ?
         jnz       InfoPMn6                 ; bude to platn† poloëka OK
InfoPMn4:or        byte ptr ds:[SIMnLBlk+3],bit1 ; z†kaz volby "Zpàt"

; ------ z†kaz voleb "Koment†©", "Popis", "Redukce" a "Adres†©" pro strom a seznam

InfoPMn6:call      far ptr GetAAWin         ; adresa aktivn°ho okna -> ES
         test      byte ptr es:[AWinPrm1],bit3 ; je to adres†©ovÇ okno ?
         jnz       InfoPMn8                 ; je to adres†©ovÇ okno OK
         or        word ptr ds:[SIMnLBlk],bit1 + HI*bit1 ; z†kaz "Koment†©" a "Editace"
         or        word ptr ds:[SIMnLBlk+4],bit1 + HI*bit1 ; z†kaz "Redukce" a "Adres†©"

; ------ n†vrat registrñ

InfoPMn8:pop       es
         pop       si
         pop       bx
         ret

InfoPMnu ENDP

; -----------------------------------------------------------------------------
;        zaji®tàn° naáten° informaán°ho souboru
; -----------------------------------------------------------------------------

InfoRead PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      es

; ------ test, zda to je adres†©ovÇ okno

         call      far ptr GetAAWin         ; adresa aktivn°ho okna -> ES
         test      byte ptr es:[AWinPrm1],bit3 ; je to adres†©ovÇ okno ?
         jz        InfoRea9                 ; nen° to adres†©ovÇ okno

; ------ test, zda jië byl koment†© naá°t†n

         test      byte ptr es:[AWinPrm1],bit6 ; byl jië koment†© hled†n ?
         jnz       InfoRea9                 ; koment†© jië byl hled†n

; ------ hl†®en° o naá°t†n° informac°

         mov       di,offset InfoCtuT       ; text - "Naá°t†m informace"
         call      far ptr InfFile          ; zobrazen° hl†®en°

; ------ zaji®tàn° naáten° informaán°ho souboru

         mov       al,es:[AWinPrm2]         ; souáasnò typ zobrazen° okna
         push      ax
         and       al,not bit5+bit6
         or        al,2*bit5                ; komentovanÇ okno
         mov       es:[AWinPrm2],al         ; komentovanÇ okno
         mov       ax,ds:[SegmAkt]          ; segment tohoto okna
         call      far ptr LoadFInf         ; naáten° informac°
         call      far ptr InitFKom         ; inicializace koment†©ñ
         call      far ptr GetDat           ; obnoven° adresy okna
         pop       ax
         mov       es:[AWinPrm2],al         ; n†vrat typu okna

         call      far ptr InfoClos         ; uzav©en° informaán°ho ©†dku

; ------ n†vrat registrñ

InfoRea9:pop       es
         pop       ax
         ret

InfoRead ENDP

; -----------------------------------------------------------------------------
;        p©°prava parametrñ poloëky (naáten° informac° z okna a z disku)
; -----------------------------------------------------------------------------

InfoParm PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ p©°prava velikosti alokaán°ho bloku disku

         call      far ptr GetAAWin         ; adresa aktivn°ho okna -> ES
         mov       ax,es:[AWinAlok]         ; velikost alokaán°ho bloku
         test      byte ptr es:[AWinPrm0],bit6 ; je CD-ROM ?
         jz        InfoPrm1                 ; nen° CD-ROM
         mov       ax,2048                  ; velikost pro CD-ROM

InfoPrm1:mov       ds:[SInfBlk],ax          ; velikost alokaán°ho bloku

; ------ naáten° parametrñ poloëky s okna

         call      far ptr GetAKurz         ; poskytnut° adresy kurzoru -> ES:SI
         push      ds
         push      ds
         push      es
         pop       ds                       ; DS <- segment poloëky
         pop       es                       ; ES <- datovò segment
         mov       di,offset FileFPol       ; fiktivn° poloëka
         mov       cx,20/2                  ; velikost poloëky
         cld
         rep       movsw                    ; £schova parametrñ poloëky
         pop       ds

; ------ test, zda je poloëka adres†©

         test      byte ptr ds:[FileFAtr],DIR ; je to adres†© ?
         jz        InfoPrm4                 ; nen° to adres†©

; ------ aktualizace parametrñ podadres†©e

         call      InfFilD                  ; informace o aktivn°m adres†©i
         mov       ax,word ptr ds:[SInfSize]
         mov       word ptr ds:[FileFSiz],ax
         mov       ax,word ptr ds:[SInfSize+2]
         mov       word ptr ds:[FileFSiz+2],ax
         jmp       short InfoPrm7

; ------ p©°prava obsazenÇ kapacity pro soubor

InfoPrm4:mov       cx,ds:[SInfBlk]          ; velikost alokaán°ho bloku
         mov       ax,word ptr ds:[FileFSiz] ; velikost souboru LOW
         mov       dx,word ptr ds:[FileFSiz+2] ; velikost souboru HIGH
         dec       cx                       ; velikost bloku - 1
         add       ax,cx                    ; zaokrouhlen° nahoru
         adc       dx,0
         inc       cx                       ; n†vrat velikosti bloku
         cmp       dx,cx                    ; p©ekroáen max. poáet blokñ ?
         jae       InfoPrm6                 ; p©ekroáena max. velikost
         div       cx                       ; poáet alokaán°ch blokñ
         mul       cx                       ; kapacita
InfoPrm6:mov       word ptr ds:[SInfKap],ax ; zabran† kapacita LOW
         mov       word ptr ds:[SInfKap+2],dx ; zabran† kapacita HIGH
         mov       word ptr ds:[SInfSoub],1 ; je to 1 soubor

; ------ naáten° dlouhÇho jmÇna souboru

InfoPrm7:mov       byte ptr ds:[DTALName-1],0 ; nen° dlouhÇ jmÇno
         mov       word ptr ds:[SIMnLPl3],offset SRMnuVL0 ; nejsou informace
         test      byte ptr ds:[Win95Par],bit2 ; jsou dlouh† jmÇna ?
         jnz       InfoPrm9                 ; nejsou dlouh† jmÇna
         call      InfoPath                 ; p©°prava cesty k poloëce
         mov       si,offset FilePath       ; buffer jmÇna souboru
         push      ds
         pop       es                       ; ES <- datovò segment
         call      far ptr ExisFile         ; naáten° dlouhÇho jmÇna

; ------ konverze fontñ dlouhÇho jmÇna

;         mov       si,offset DTALName
;         mov       cx,ds:[DTALNamN]         ; dÇlka textu
;         mov       dx,bit3+bit2*HI          ; z Latin 2 do Kamenickòch
;         call      far ptr KonvFnt          ; konverze fontñ

; ------ test, zda bude áas otev©en° ái vytvo©en°

         mov       ax,word ptr ds:[DTALCrea+2] ; datum vytvo©en° souboru
         or        ax,word ptr ds:[DTALOpen+2] ; datum otev©en° souboru
         jz        InfoPrm9                 ; nejsou platnÇ
         mov       word ptr ds:[SIMnLPl3],offset SRMnuVLn ; jsou informace

; ------ p©°prava data a áasu vytvo©en° a otev©en°

         mov       ax,word ptr ds:[DTALCrea+2]
         mov       ds:[SIMnBuf],ax          ; datum vytvo©en°
         mov       si,offset SIMnBuf-FileDate
         mov       di,offset SRMnuVtD       ; datum vytvo©en°
         mov       dx,ds                    ; DX <- datovò segment
         mov       ah,0                     ; barva se neukl†d†
         call      far ptr DekA4Dat         ; dek¢dov†n° data

         mov       cx,word ptr ds:[DTALCrea]
         mov       ds:[SIMnBuf],cx          ; áas vytvo©en°
         mov       si,offset SIMnBuf-FileTime
         mov       di,offset SRMnuVtT       ; áas vytvo©en°
         call      far ptr DekATmS          ; dek¢dov†n° áasu vytvo©en°

         mov       dx,word ptr ds:[DTALOpen+2]
         mov       ds:[SIMnBuf],dx          ; datum otev©en°
         mov       si,offset SIMnBuf-FileDate
         mov       di,offset SRMnuOpn       ; datum otev©en°
         mov       dx,ds                    ; DX <- datovò segment
         call      far ptr DekA4Dat         ; dek¢dov†n° data

; ------ n†vrat registrñ

InfoPrm9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

InfoParm ENDP

; -----------------------------------------------------------------------------
;                                 InfFilD
;           stanoven° parametrñ adres†©e pod kurzorem v aktivn°m oknà
; -----------------------------------------------------------------------------
; VSTUP:  DS=datovò segment
;         FilePath=plnÇ jmÇno adres†©e (dÇlka FileFilN)
;         [SInfBlk] = je jië p©ipravena velikost alokaán°ho bloku
;         hl†®en° je zobrazeno
; VùSTUP: CY=chyba nebo p©eru®en° operace
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: [BP-2] (2) á°taá £rovn°
; -----------------------------------------------------------------------------

InfFilD  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         mov       bp,sp
         sub       sp,2                     ; lok†ln° promànn†

; ------ hl†®en° o naá°t†n° informac°

         mov       di,offset InfoCtuT       ; text - "Naá°t†m informace"
         call      far ptr InfFile          ; zobrazen° hl†®en°

; ------ inicializace ukazatelñ

         xor       ax,ax                    ; AX <- 0
         mov       word ptr ds:[SInfSize],ax ; velikost adres†©e LOW
         mov       word ptr ds:[SInfSize+2],ax ; velikost adres†©e HIGH
         mov       word ptr ds:[SInfKap],ax  ; zabran† kapacita LOW
         mov       word ptr ds:[SInfKap+2],ax ; zabran† kapacita HIGH
         mov       word ptr ds:[SInfSoub],ax ; poáet souborñ v adres†©i
         mov       word ptr ss:[bp-2],0     ; á°taá hloubky vno©en°

; ------ bude vno©en° do podadres†©e

InfFilD2:inc       word ptr ss:[bp-2]       ; zvò®en° á°taáe hloubky vno©en°
         sub       sp,DTAMax                ; m°sto pro poloëku DTA

; ------ nastaven° pracovn° adresy DTA

         push      ss
         pop       es                       ; ES <- segment SS
         mov       si,sp                    ; adresa poloëky DTA v z†sobn°ku
         mov       bx,si                    ; £schova adresy poloëky DTA
         call      far ptr SetDTA           ; nastaven° pracovn° adresy DTA

; ------ p©id†n° textu "*.*" k cestà

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       si,offset All            ; text "*.*"
         call      far ptr AddGFil          ; p©id†n° textu "*.*"

; ------ nalezen° prvn°ho souboru

         mov       cx,DIR+HID+SYS+RO+ARC    ; atributy souboru
         mov       si,offset FilePath       ; specifikace
         call      far ptr SrcFirst         ; nalezen° prvn° poloëky

; ------ zru®en° textu "*.*" ze specifikace

         pushf
         call      far ptr SubGFil          ; odstranàn° textu "*.*"
         popf

; ------ test, zda bylo nàco nalezeno

InfFilD3:jc        InfFilD7                 ; nàjak† chyba nebo p©eru®en°
         jne       InfFilD7                 ; nen° dal®° poloëka v adres†©i
         cmp       byte ptr ss:[bx+DTAName],"." ; je to adres†© "." nebo ".." ?
         je        InfFilD8                 ; zak†zanò adres†©

; ------ rozli®en°, zda byl nalezen adres†© nebo soubor

         test      byte ptr ss:[bx+DTAAtrib],DIR ; je to adres†© ?
         jnz       InfFilD6                 ; byl nalezen adres†©

; ------ p©iáten° parametrñ souboru

         inc       word ptr ds:[SInfSoub]   ; zvò®en° á°taáe souborñ
         mov       ax,ss:[bx+DTASize]       ; velikost souboru LOW
         mov       dx,ss:[bx+DTASize+2]     ; velikost souboru HIGH
         mov       cx,ds:[SInfBlk]          ; velikost alokaán°ho bloku
         add       word ptr ds:[SInfSize],ax ; velikost souboru LOW
         adc       word ptr ds:[SInfSize+2],dx ; velikost souboru HIGH
         dec       cx                       ; velikost alok. bloku - 1
         add       ax,cx                    ; zaokrouhlen° na alokaán° blok
         adc       dx,0
         inc       cx
         cmp       dx,cx                    ; bylo by p©eteáen° ?
         jae       InfFilD5                 ; bylo by p©eteáen°
         div       cx                       ; vòpoáet poátu zabranòch blokñ
         mul       cx                       ; zabran† kapacita
InfFilD5:add       word ptr ds:[SInfKap],ax ; zabran† kapacita LOW
         adc       word ptr ds:[SInfKap+2],dx ; zabran† kapacita HIGH
         jmp       short InfFilD8           ; dal®° poloëka

; ------ nalezen adres†© - vno©en° do podadres†©e

InfFilD6:push      ss
         pop       es                       ; ES <- buffer v z†sobn°ku
         mov       si,sp                    ; SI <- adresa poloëky DTA
         add       si,DTAName               ; jmÇno nalezenÇho souboru
         call      far ptr AddGFil          ; p©id†n° nalezenÇho adres†©e
         jmp       short InfFilD2           ; vno©en° do podadres†©e

; ------ nen° dal®° poloëka - sn°ëen° £rovnà

InfFilD7:call      far ptr SrcClose         ; uzav©en° starÇho hled†n°

         dec       word ptr ss:[bp-2]       ; á°taá poloëek DTA
         clc                                ; p©°znak operace OK
         jz        InfFilD9                 ; nen° dal®° poloëka - konec
         add       sp,DTAMax                ; zru®en° poloëky DTA
         call      far ptr SubGFil          ; zru®en° posledn° poloëky z cesty

; ------ nastaven° p©ede®lÇ adresy DTA

         push      ss
         pop       es                       ; ES <- buffer v z†sobn°ku
         mov       si,sp                    ; adresa poloëky DTA v z†sobn°ku
         mov       bx,si                    ; £schova adresy poloëky DTA
         call      far ptr SetDTA           ; nastaven° pracovn° adresy DTA

; ------ vyhled†n° dal®° poloëky v adres†©i

InfFilD8:call      far ptr TestBreak        ; test p©eru®en° operace
         jc        InfFilD9                 ; je p©eru®en° operace
         call      far ptr SrcNext          ; nalezen° dal®° poloëky v adres†©i
         jmp       short InfFilD3           ; test dal®° poloëky

; ------ n†vrat registrñ

InfFilD9:mov       sp,bp
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx

; ------ uloëen° velikosti poloëky

         pushf
         call      far ptr GetAAWin         ; adresa aktivn°ho okna -> ES
         test      byte ptr es:[AWinPrm1],bit4 ; je to strom ?
         jnz       InfFilDA                 ; pro strom se neukl†d†
         call      far ptr GetAKurz          ; adresa poloëky
         mov       ax,word ptr ds:[SInfSize] ; velikost poloëky LOW
         mov       word ptr es:[si+FileSize],ax ; velikost poloëky LOW
         mov       ax,word ptr ds:[SInfSize+2] ; velikost poloëky HIGH
         mov       word ptr es:[si+FileSize+2],ax ; velikost poloëky HIGH

; ------ ukonáen° reëimu vyhled†v†n°

         mov       ax,ds:[SegmAkt]          ; segment aktivn°ho okna
         call      far ptr AktSelct         ; aktualizace vòbàru poloëek
InfFilDA:call      far ptr InfoClos         ; uzav©en° informaán°ho ©†dku
         popf
         pop       ax
         ret

InfFilD  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° parametrñ poloëky do menu
; -----------------------------------------------------------------------------

InfPDek  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ dek¢dov†n° z†kladn°ch parametrñ poloëky

         call      far ptr DekFParm         ; dek¢dov†n° parametrñ poloëky

; ------ konverze fontñ jmÇna souboru

;         test      byte ptr ds:[Win95Par],bit2 ; jsou dlouh† jmÇna ?
;         jnz       InfPDek0                 ; nejsou dlouh† jmÇna
;
;         push      ds
;         pop       es
;         mov       si,offset SRMnuFil
;         mov       ch,0
;         mov       cl,ds:[si]               ; dÇlka textu
;         mov       dx,bit3+bit2*HI          ; z Latin 2 do Kamenickòch
;         call      far ptr KonvFnt          ; konverze fontñ

; ------ oprava jmÇna poloëky pro ".."

InfPDek0:call      far ptr GetAKurz         ; adresa kurzoru
         mov       ax,".."
         cmp       word ptr es:[si+FileName],ax ; je to ".." ?
         jne       InfPDek1
         mov       word ptr ds:[SRMnuFil+1],ax
         mov       byte ptr ds:[SRMnuFil],2

; ------ vymaz†n° bufferu obsazenÇ kapacity

InfPDek1:push      ds
         pop       es                       ; ES <- datovò segment
         mov       di,offset SIMKapac       ; buffer obsazenÇ kapacity
         cld
         push      di
         mov       cx,13                    ; dÇlka bufferu
         mov       al," "
         rep       stosb                    ; vymaz†n° bufferu obsazenÇ kapacity
         pop       di

; ------ dek¢dov†n° obsazenÇ kapacity

         mov       ax,word ptr ds:[SInfKap] ; zabran† kapacita
         mov       dx,word ptr ds:[SInfKap+2]
         mov       bh,0                     ; atribut barvy se neukl†d†
         mov       bl,ds:[OddelRad]         ; znak oddàlovaáe ©†dñ
         call      far ptr DekNum           ; dek¢dov†n° £daje velikosti

; ------ vymaz†n° bufferu poátu souborñ (CH=0)

         mov       di,offset SIMSoub        ; buffer poátu souborñ
         cld
         push      di
         mov       cl,6
         mov       al," "
         rep       stosb                    ; vymaz†n° bufferu poátu souborñ
         pop       di

; ------ dek¢dov†n° poátu souborñ (BH=0, BL=oddàlovaá ©†dñ)

         mov       byte ptr ds:[di],"-"     ; p©°znak, ëe nen° adres†©
         test      byte ptr ds:[FileFAtr],DIR ; je to adres†© ?
         jz        InfPDek2                 ; nen° to adres†©
         mov       ax,ds:[SInfSoub]         ; poáet souborñ v adres†©i
         call      far ptr DekNumW          ; dek¢dov†n° poátu souborñ

; ------ p©ednastaven° - nejsou koment†©e

InfPDek2:mov       di,offset SIMKomK        ; koment†©e
         mov       cx,10                    ; poáet ©†dkñ koment†©ñ
InfPDek3:mov       byte ptr ds:[di],0       ; nen° koment†©
         mov       word ptr ds:[di+1],0     ; nen° ani platn† adresa
         add       di,11
         loop      InfPDek3                 ; dal®° ©†dek

; ------ test, zda je adres†©ovÇ okno

         call      far ptr GetAAWin         ; adresa aktivn°ho okna -> ES
         test      byte ptr es:[AWinPrm1],bit3 ; je to adres†©ovÇ okno ?
         jz        InfPDek9                 ; nen° to adres†©ovÇ okno

; ------ adresa segmentu koment†©ñ -> DX

         mov       ax,es:[AWinKomS]         ; CX <- á°slo segmentu koment†©ñ
         call      far ptr GetSgAdr         ; DX <- adresa segmentu koment†©ñ
         jc        InfPDek9                 ; nen° segment koment†©ñ

; ------ adresa koment†©e k poloëce -> ES:SI

         mov       ax,es                    ; AX <- adresa segmentu okna
         mov       si,es:[AWinKurz]         ; SI <- aktivn° poloëka
         shl       si,1                     ; offset v tabulce indexñ
         add       si,word ptr es:[AWinKomI] ; offset v tabulce indexñ
         add       ax,word ptr es:[AWinKomI+2] ; segment v tabulce indexñ
         mov       es,ax                    ; ES <- segment v tabulce indexñ
         mov       si,es:[si]               ; SI <- offset koment†©e
         or        si,si                    ; je koment†© ?
         jz        InfPDek9                 ; nen° koment†© k poloëce
         mov       es,dx                    ; DS <- segment koment†©ñ

; ------ uloëen° adresy koment†©e k poloëce

         mov       di,offset SIMKomK
         mov       word ptr ds:[di+1],si    ; offset koment†©e
         mov       word ptr ds:[di+3],es    ; segment koment†©e

; ------ zji®tàn° dÇlky koment†©e

         cld
         xor       cx,cx                    ; á°taá dÇlky koment†©e
         dec       cx
         dec       si
InfPDek4:inc       cx
         inc       si
         cmp       byte ptr es:[si],0
         jne       InfPDek4
         mov       ds:[di],cl               ; dÇlka koment†©e

; ------ test, zda je dal®° ©†dek

         mov       bx,9                     ; poáet ©†dkñ
InfPDek5:inc       si                       ; p©eskoáen° bajtu 0
         add       di,11                    ; adresa ukazatele dal®°ho ©†dku
         cmp       si,es:[0]                ; je jië konec dat ?
         jae       InfPDek9                 ; je jië konec dat

; ------ p©°prava dal®°ho ©†dku

         mov       ch,0
         mov       cl,es:[si]               ; dÇlka ©†dku
         inc       si                       ; zaá†tek textu ©†dku

; ------ test, zda to je ©†dek popisu poloëky

         dec       cx                       ; je pr†zdnò ©†dek ?
         jz        InfPDek7                 ; pr†zdnò ©†dek je platnò
         cmp       byte ptr es:[si]," "     ; zaá°n† ©†dek mezerou ?
         je        InfPDek6                 ; zaá°n† mezerou - je platnò
         cmp       byte ptr es:[si],TAB     ; zaá°n† tabul†torem ?
         jne       InfPDek9                 ; nen° to platnò ©†dek popisu

; ------ nalezen° zaá†tku textu ©†dku

InfPDek6:inc       si                       ; zvò®en° ukazatele textu
         dec       cx                       ; sn°ëen° á°taáe dÇlky ©†dku
         cmp       byte ptr es:[si]," "     ; mezera ?
         je        InfPDek6                 ; mezera se vypust°
         cmp       byte ptr es:[si],TAB     ; tabul†tor ?
         je        InfPDek6                 ; tabul†tor se vypust°

; ------ uloëen° parametrñ ©†dku

InfPDek7:mov       ds:[di],cl               ; dÇlka ©†dku
         mov       ds:[di+1],si             ; offset adresy ©†dku
         mov       ds:[di+3],es             ; segment adresy ©†dku

; ------ p©°prava pro dal®° ©†dek

         add       si,cx                    ; adresa konce ©†dku
         dec       bx                       ; á°taá ©†dkñ
         jnz       InfPDek5                 ; dal®° ©†dek popisu

; ------ n†vrat registrñ

InfPDek9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InfPDek  ENDP

; -----------------------------------------------------------------------------
;        editace popisu
; -----------------------------------------------------------------------------

; ------ otev©en° okna editoru -> ES:DI=buffer, CX=dÇlka

InfoFil4:call      far ptr InfoClos         ; uzav©en° informaán°ho ©†dku
         mov       si,offset PopisMnu       ; menu editoru popisu poloëky
         call      far ptr OpenText         ; otev©en° bufferu textu
         jc        InfoFl40                 ; chyba pamàti
         mov       ds:[si+EdMnuSeg],ax      ; segment okna
         call      InfoF4Pr                 ; inicializace editoru

; ------ naáten° textu k editaci

         call      InfoF4Re                 ; naáten° textu k editaci
         jnc       InfoFl43                 ; operace OK

; ------ chyba pamàti

InfoFl40:call      far ptr MemErr           ; chyba pamàti
         jmp       InfoFl49

; ------ otev©en° okna menu

InfoFl43:call      far ptr OpenMnu          ; otev©en° okna menu editoru

; ------ editace okna

InfoFl44:mov       si,offset PopisMnu       ; menu editoru
         call      far ptr KorEMnu          ; korekce okna
         test      byte ptr ds:[TextEPar],bit3 ; je t©eba zobrazit v®e ?
         jz        InfoFl45                 ; nen° zobrazen° v®eho
         call      far ptr DispAll
         jmp       short InfoFl46
InfoFl45:call      far ptr DispMnu          ; zobrazen° okna

; ------ vstup znaku z kl†vesnice -> BX

InfoFl46:call      far ptr InpChar          ; vstup znaku z kl†vesnice

; ------ menu kl†ves malÇ n†povàdy

         push      di
         mov       di,offset TxtMnHM1       ; menu kl†ves malÇ n†povàdy
         call      far ptr MenKlHlp         ; obsluha menu kl†ves
         pop       di

; ------ p©°prava k obsluze kl†vesy

InfoF464:mov       ax,ds:[si+EdMnuSeg]
         call      far ptr GetDat           ; adresa segmentu okna -> ES
         and       byte ptr ds:[TextEPar],not bit0+bit1+bit2+bit3

; ------ skok na obsluhu kl†vesy

         cmp       bl,27                    ; je p©eru®en° ESC ?
         je        InfoFl48                 ; je p©eru®en° editace ESC
         call      far ptr JumpBX           ; skok na obsluhu kl†vesy

         dw        4400h,InfoF472           ; F10 - obsluha menu
         dw        MousXKod+MousXMP,InfoF472 ; stisk st©edn°ho tlaá°tka my®i
         dw        3c00h,InfoF474           ; F2 - uloëen° souboru
         dw        0,InfoFl47               ; jinÇ kl†vesy

; ------ obsluha editace kl†ves

InfoFl47:call      far ptr EditEMnu         ; editace okna menu
         jmp       short InfoFl44           ; pokraáov†n° v editaci

; ------ F10 - menu

InfoF472:call      far ptr ZapisMnX         ; obsluha menu
         jnc       InfoF464                 ; v BX je k¢d kl†vesy
         jmp       short InfoFl44           ; nen° kl†vesa (p©eru®en°)

; ------ F2 - uloëen° zmàn

InfoF474:call      InfoPUlo                 ; uloëen° editovanÇho popisu poloëky
         jmp       short InfoFl44           ; dal®° kl†vesa

; ------ test, zda se m† text uloëit

InfoFl48:test      byte ptr es:[TextParm],bit1 ; text modifikov†n ?
         jz        InfoF486                 ; nebyl modifikov†n

         mov       si,offset ZUSMnLin       ; menu - text modifikov†n
         call      far ptr Lin0Menu         ; volba operace
         jc        InfoFl44                 ; p©eru®en° operace

         dec       bx                       ; uloëen° souboru ?
         jnz       InfoF486                 ; p©eru®en° operace
         call      InfoPUlo                 ; uloëen° editovanÇho popisu
         jc        InfoFl44                 ; p©eru®en° operace

; ------ uzav©en° okna editoru

InfoF486:mov       si,offset PopisMnu
         call      far ptr ClosMnu
         mov       ax,word ptr ds:[PopisMnu+EdMnuSeg] ; segment bufferu
         call      far ptr DelSeg           ; zru®en° segmentu
         mov       word ptr ds:[PopisMnu+EdMnuSeg],ax

InfoFl49:jmp       InfoFl12

; -----------------------------------------------------------------------------
;        p©°prava parametrñ k editaci popisu (ES=segment editoru)
; -----------------------------------------------------------------------------

InfoF4Pr PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      si
         push      di

; ------ jmÇno souboru (màlo by jië bòt p©ipraveno v SRMnuFil)

         mov       si,offset SRMnuFil+1     ; jmÇno souboru
         mov       ch,0
         mov       cl,ds:[si-1]             ; dÇlka jmÇna souboru
         cld
         mov       es:[TextNamN],cl         ; dÇlka jmÇna souboru
         mov       di,TextName              ; buffer jmÇna souboru
         rep       movsb                    ; uloëen° jmÇna souboru

; ------ koment†© k poloëce

         push      ds
         mov       cl,ds:[SIMKomK]          ; dÇlka koment†©e
         lds       si,dword ptr ds:[SIMKomK+1] ; adresa koment†©e
         mov       di,TextKom               ; buffer koment†©e
         cmp       cl,50                    ; je dÇlka koment†©e OK ?
         jbe       InfoF4P2                 ; dÇlka koment†©e je OK
         mov       cl,50                    ; omezen° dÇlky koment†©e
InfoF4P2:mov       es:[TextNKom],cl         ; dÇlka koment†©e
         rep       movsb                    ; p©enos textu koment†©e
         pop       ds

; ------ n†vrat registrñ

         pop       di
         pop       si
         pop       cx
         ret

InfoF4Pr ENDP

; -----------------------------------------------------------------------------
;        naáten° ©†dkñ k editaci (ES:DI=adresa bufferu, CX=velikost) -> CY chyba
; -----------------------------------------------------------------------------

InfoF4Re PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      si
         push      di
         push      ds

; ------ p©°prava registrñ k naáten° ©†dkñ

         cld
         lds       si,dword ptr ds:[SIMKomK+1+11] ; adresa prvn°ho ©†dku popisu
         or        si,si                    ; je platnò ©†dek ?
         jz        InfoF4R9                 ; nen° platnò ©†dek
         jmp       short InfoF4R7           ; prvn° ©†dek se nekontroluje

; ------ test, zda je dal®° ©†dek

InfoF4R2:cmp       si,ds:[0]                ; je dal®° ©†dek ?
         jae       InfoF4R9                 ; nen° dal®° ©†dek

; ------ test, zda je platnò ©†dek koment†©e

         lodsb                              ; naáten° p©ipravenÇho znaku
         cmp       al,0                     ; je pr†zdnò ©†dek ?
         je        InfoF4R8                 ; je pr†zdnò ©†dek
         cmp       al," "                   ; mezera ?
         je        InfoF4R6                 ; mezera - je platnò ©†dek
         cmp       al,TAB                   ; tabul†tor ?
         clc                                ; p©°znak operace OK
         jne       InfoF4R9                 ; nen° tabul†tor - nen° platnò ©†dek

; ------ vypu®tàn° mezer ze zaá†tku ©†dku

InfoF4R6:lodsb                              ; naáten° dal®°ho znaku
         cmp       al," "                   ; mezera ?
         je        InfoF4R6                 ; mezera se vypou®t°
         cmp       al,TAB                   ; tabul†tor ?
         je        InfoF4R6                 ; tabul†tor se vypou®t°
         dec       si                       ; n†vrat platnÇho znaku

; ------ p©enesen° textu ©†dku

InfoF4R7:lodsb                              ; naáten° dal®°ho znaku
         cmp       al,0                     ; je konec ©†dku ?
         je        InfoF4R8                 ; je konec ©†dku
         call      InfoF4RU                 ; uloëen° znaku AL
         jnc       InfoF4R7                 ; dal®° znak

; ------ uloëen° konce ©†dku CR/LF

InfoF4R8:inc       si                       ; p©eskoáen° bajtu dÇlky dal®°ho ©†dku
         mov       al,CR
         call      InfoF4RU
         jc        InfoF4R9
         mov       al,LF
         call      InfoF4RU
         jnc       InfoF4R2

; ------ nastaven° velikosti segmentu

InfoF4R9:pop       ds

         pushf
         mov       es:[TextByts],di         ; velikost dat v bufferu
         mov       ax,ds:[PopsSegm]         ; segment
         mov       bx,di                    ; BX <- konec dat
         call      far ptr ModiSegS         ; nastaven° velikosti segmentu
         popf

; ------ n†vrat registrñ

         pop       di
         pop       si
         pop       cx
         ret

InfoF4Re ENDP

; ------ uloëen° znaku AL do bufferu

InfoF4RU:stc                                ; p©°znak chyb
         jcxz      InfF4RU2                 ; nen° volnÇ m°sto v bufferu
         stosb                              ; uloëen° bajtu AL do bufferu
         dec       cx                       ; sn°ëen° á°taáe volnÇho m°sta
         inc       word ptr es:[TextBNum]   ; zvò®en° á°taáe dat v bufferu
         clc                                ; p©°znak operace OK
InfF4RU2:ret

; -----------------------------------------------------------------------------
;        uloëen° editovanÇho popisu poloëky (CY=p©eru®en° operace)
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) segment koment†©ñ
;                   SS:[BP-4] (2) offset indexu
;                   SS:[BP-6] (2) offset ©†dku koment†©e poloëky
;                   SS:[BP-8] (2) adresa segmentu koment†©ñ
;                   SS:[BP-10] (2) adresa zaá†tku popisu poloëky
;                   SS:[BP-12] (2) ukazatel adresy ©†dku v editoru
; -----------------------------------------------------------------------------

InfoPUlo PROC      NEAR

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
         sub       sp,12

; ------ segment koment†©ñ

         mov       ax,ds:[SegmAkt]          ; aktivn° okno
         call      far ptr KomSIni          ; inicializace segmentu
         jnc       InfoPUl1                 ; operace OK
InfoPUl0:jmp       InfoPUl8

; ------ adresa v indexovÇ tabulce -> ES:SI

InfoPUl1:mov       ss:[bp-2],ax             ; segment koment†©ñ
         mov       ss:[bp-8],es             ; adresa segmentu koment†©ñ
         call      far ptr GetAAWin         ; adresa aktivn°ho okna -> AX
         mov       si,es:[AWinKurz]         ; aktivn° poloëka
         shl       si,1                     ; offset v indexovÇ tabulce
         add       si,word ptr es:[AWinKomI] ; offset indexu
         mov       ss:[bp-4],si             ; offset indexu
         mov       ax,es                    ; segment okna
         add       ax,word ptr es:[AWinKomI+2] ; segment v indexovÇ tabulce
         mov       es,ax                    ; ES <- segment v indexovÇ tabulce

; ------ test, zda je koment†© poloëky vytvo©enò

         mov       di,es:[si]               ; offset koment†©e poloëky
         or        di,di                    ; je poloëka vytvo©ena ?
         jnz       InfoPUl2                 ; poloëka je vytvo©ena OK

; ------ vytvo©en° poloëky, nen°-li vytvo©ena

         mov       es,ss:[bp-8]             ; adresa segmentu koment†©ñ -> ES
         mov       di,es:[0]                ; velikost dat v segmentu
         mov       si,offset SRMnuFil       ; buffer jmÇna souboru
         mov       ch,0
         mov       cl,ds:[si]               ; dÇlka jmÇna souboru
         inc       cx                       ; + bajt dÇlky
         inc       cx                       ; + koncov† 0
         mov       ax,ss:[bp-2]             ; segment koment†©ñ
         call      far ptr InsDat           ; vytvo©en° m°sta pro jmÇno souboru
         jc        InfoPUl0                 ; chyba pamàti

; ------ uloëen° poloëky

         cld
         push      cx
         lodsb                              ; AL <- dÇlka jmÇna poloëky
         mov       cl,al                    ; CL <- dÇlka jmÇna poloëky
         inc       ax                       ; váetnà koncovÇ 0
         stosb                              ; dÇlka poloëky
         rep       movsb                    ; p©enos jmÇna poloëky
         mov       al,0
         stosb                              ; koncov† 0
         pop       cx
         dec       di                       ; n†vrat na koncovou 0

; ------ oprava ukazatelñ v oknà

         call      far ptr GetAAWin         ; adresa aktivn°ho okna
         add       es:[AWinKomN],cx         ; zvò®en° poátu bajtñ koment†©ñ

; ------ aktualizace koment†©e k poloëce

         mov       si,ss:[bp-4]             ; offset indexu
         mov       ax,es                    ; segment okna
         add       ax,word ptr es:[AWinKomI+2] ; segment v indexovÇ tabulce
         mov       es,ax                    ; ES <- segment v indexovÇ tabulce
         mov       es:[si],di               ; adresa koment†©e k poloëce
InfoPUl2:mov       ss:[bp-6],di             ; offset koment†©e poloëky

; ------ nalezen° zaá†tku dal®°ho ©†dku = adresa zaá†tku popisu poloëky -> DI

         mov       es,ss:[bp-8]             ; adresa segmentu koment†©ñ
InfoPUl3:inc       di                       ; zvò®en° ukazatele textu
         cmp       byte ptr es:[di-1],0     ; je zaá†tek dal®°ho ©†dku ?
         jne       InfoPUl3                 ; nalezen° zaá†tku dal®°ho ©†dku
         mov       ss:[bp-10],di            ; adresa zaá†tku popisu poloëky

; ------ nalezen° konce popisu poloëek -> ES:SI

         mov       si,di                    ; SI <- ukazatel ©†dkñ
InfoPUl4:cmp       si,es:[0]                ; je dal®° ©†dek ?
         jae       InfoPUl5                 ; nen° dal®° ©†dek
         mov       al,es:[si+1]             ; prvn° znak ©†dku
         cmp       al,0
         je        InfoPU42                 ; pr†zdnò ©†dek je platnò
         cmp       al," "
         je        InfoPU42                 ; je to platnò ©†dek popisu
         cmp       al,TAB
         jne       InfoPUl5                 ; nen° to ©†dek popisu
InfoPU42:mov       al,es:[si]               ; dÇlka ©†dku
         inc       si                       ; zaá†tek textu ©†dku
         mov       ah,0
         add       si,ax                    ; adresa dal®°ho ©†dku
         jmp       short InfoPUl4           ; dal®° ©†dek

; ------ zru®en° starÇho popisu poloëky

InfoPUl5:mov       cx,si                    ; CX <- adresa konce popisu
         sub       cx,di                    ; dÇlka popisu poloëek
         mov       ax,ss:[bp-2]             ; segment koment†©ñ
         call      far ptr DelDat           ; zru®en° starÇho popisu

; ------ oprava ukazatelñ v oknà

         call      far ptr GetAAWin         ; adresa aktivn°ho okna
         sub       es:[AWinKomN],cx         ; sn°ëen° poátu bajtñ koment†©ñ

; ------ p©°prava ukazatelñ pro jeden ©†dek

         mov       word ptr ss:[bp-12],TextBBeg ; ukazatel textu v editoru
InfoPUl6:mov       ax,ds:[PopsSegm]         ; segment editoru
         call      far ptr GetDat           ; adresa segmentu editoru
         mov       si,ss:[bp-12]            ; ukazatel textu v editoru
         mov       dx,es:[0]                ; adresa konce textu v editoru
         xor       cx,cx                    ; á°taá dÇlky ©†dku

; ------ nalezen° zaá†tku textu ©†dku

         dec       si
InfoPU61:inc       si                       ; zvò®en° ukazatele textu ©†dku
         cmp       si,dx                    ; je dal®° ©†dek ?
         jae       InfoPUl8                 ; nen° dal®° ©†dek - konec (je NC !)
         mov       al,es:[si]               ; p©ipravenò znak
         cmp       al," "
         je        InfoPU61
         cmp       al,TAB
         je        InfoPU61
         mov       ss:[bp-12],si            ; £schova adresy zaá†tku ©†dku

; ------ zji®tàn° dÇlky jednoho ©†dku v editoru -> CX

InfoPU62:cmp       si,dx                    ; je dal®° znak ?
         jae       InfoPU64                 ; nen° dal®° znak
         cmp       word ptr es:[si],CR + LF*HI ; je CR/LF ?
         je        InfoPU63                 ; je konec ©†dku
         inc       si                       ; zvò®en° ukazatele textu
         inc       cx                       ; zvò®en° á°taáe dÇlky ©†dku
         jmp       short InfoPU62           ; dal®° znak

; ------ £schova adresy dal®°ho ©†dku

InfoPU63:inc       si                       ; p©eskoáen° znaku CR
         inc       si                       ; p©eskoáen° znaku LF
InfoPU64:xchg      si,ss:[bp-12]            ; SI <- n†vrat zaá†tku ©†dku

; ------ omezen° dÇlky textu ©†dku

         cmp       cx,255-1-2               ; max. dÇlka (bez nuly a 2*TAB)
         jbe       InfoPU65                 ; dÇlka je OK
         mov       cx,255-1-2               ; omezen° dÇlky textu

; ------ vytvo©en° m°sta pro vloëen° ©†dku (je DI ukl†dac° adresa)

InfoPU65:mov       ax,ss:[bp-2]             ; segment koment†©ñ
         add       cx,1+1+2                 ; + dÇlka + nula + 2*TAB
         call      far ptr InsDat           ; vytvo©en° m°sta pro ©†dek
         jc        InfoPUl8                 ; chyba pamàti

; ------ p©enesen° textu ©†dku

         push      cx
         push      ds

         mov       ax,ds:[PopsSegm]         ; segment editoru
         call      far ptr GetSgAdr         ; adresa segmentu editoru -> DX
         mov       es,ss:[bp-8]             ; adresa segmentu koment†©ñ
         mov       ds,dx                    ; DS <- segment editoru
         dec       cx                       ; bez bajtu dÇlky
         mov       al,cl                    ; AL <- dÇlka ©†dku
         cld
         stosb                              ; uloëen° bajtu dÇlky ©†dku
         mov       al,TAB                   ; tabul†tor
         stosb                              ; uloëen° 2 tabul†torñ
         stosb
         sub       cl,1+2                   ; bez 2 tabul†torñ a bez koncovÇ 0
         rep       movsb                    ; p©enos textu ©†dku
         mov       al,0
         stosb                              ; koncov† 0

         pop       ds
         pop       cx

; ------ oprava ukazatelñ v oknà

         call      far ptr GetAAWin         ; adresa aktivn°ho okna
         sub       es:[AWinKomN],cx         ; sn°ëen° poátu bajtñ koment†©ñ
         jmp       short InfoPUl6

; ------ nulov†n° p©°znaku modifikace textu

InfoPUl8:pushf
         mov       ax,ds:[PopsSegm]         ; segment editoru
         call      far ptr GetDat           ; adresa segmentu editoru -> ES
         and       byte ptr es:[TextParm],not bit1 ; nulov†n° p©°znaku modifikace

; ------ uloëen° souboru FILEINFO

         mov       ax,ds:[SegmAkt]          ; aktivn° okno
         call      far ptr InitFKom         ; inicializace adres koment†©ñ
         call      far ptr WritFKom         ; uloëen° souboru FILEINFO
         popf

; ------ chyba pamàti

         jnc       InfoPUl9                 ; operace OK
         call      far ptr MemErr           ; chyba pamàti

; ------ n†vrat registrñ

InfoPUl9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InfoPUlo ENDP

; *****************************************************************************
;
;                      Modifikace parametrñ souborñ
;
; *****************************************************************************
;˛
AWMMnuSM LABEL     FAR

; ------ z†kaz poloëek p©i vypnutÇm aktivn°m oknà

         and       word ptr ds:[SMMnVBlk],not (bit1+HI*bit1) ; poloëky povoleny
         and       word ptr ds:[SMMnVBlk+2],not (bit1+HI*bit1) ; poloëky povoleny
         call      far ptr TestAAWn         ; je aktivn° okno zapnuto ?
         jnc       AWMMnSM1                 ; okno je zapnuto
         or        word ptr ds:[SMMnVBlk],bit1+HI*bit1 ; z†kaz poloëek
         or        word ptr ds:[SMMnVBlk+2],bit1+HI*bit1 ; z†kaz poloëek

AWMMnSM1:mov       ax,word ptr ds:[SMnuVert+MnuPoz] ; pozice p©edchoz°ho okna
         add       ax,0607h                 ; posun okna
         mov       word ptr ds:[si+MnuPoz],ax ; pozice okna

         jmp       far ptr VertMenu

ModSouTb db        bit0 + bit6              ; kurzor
         db        bit1 + bit6              ; oznaáenÇ
         db        bit2                     ; soubory
         db        bit2 + bit4 + bit6 + bit7 ; v®echny
         db        bit3 + bit4 + bit6       ; zadanÇ

ModiFil  LABEL     FAR

; ------ zah†jen° operace

         add       sp,4                     ; zru®en° n†vratovÇ adresy
         mov       bx,ds:[si+MnuAkt]        ; aktivn° zvolen† poloëka
         mov       al,cs:[bx+ModSouTb-1]    ; parametry pro vòbàr poloëek

; ------ vstupn° bod z funkán° kl†vesy (AL=typ operace)

ModiFilF LABEL     FAR

         call      far ptr ClosMnuA         ; uzav©en° v®ech oken menu
         call      far ptr InitFFil         ; inicializace vyhled†v†n°
         jc        ModiSou0                 ; nen° ë†dnò soubor

; ------ zad†n° souborñ textem

         test      byte ptr ds:[FileTyp],bit3 ; je specifikace textem ?
         jz        ModiSou2                 ; nen° specifikace textem

ModiSou1:mov       si,offset SMZMLin        ; menu zad†n° souborñ
         call      far ptr Lin0Menu         ; obsluha volby
         jnc       ModiSo12                 ; volba OK

; ------ p©eru®en° operace a n†vrat do hlavn° obsluhy

ModiSou0:jmp       far ptr Main0

; ------ rozbor zad†n° parametrñ operace

ModiSo12:call      far ptr RozborZ          ; rozbor zad†n° parametrñ operace
         jc        ModiSou0                 ; p©eru®en° operace
         jnz       ModiSou1                 ; opakov†n° zad†n°

; ------ doplnàn° cesty na plnÇ jmÇno

         call      far ptr RozbFPth         ; doplnàn° na plnÇ jmÇno

; ------ p©°prava p©edvoleb

ModiSou2:call      ModSPred                 ; p©°prava p©edvoleb

; ------ volba parametrñ operace

ModiSou3:mov       si,offset SMMMLin
         call      far ptr Lin0Menu         ; obsluha volby
         jc        ModiSou0

; ------ rozbor zad†n° parametrñ

         mov       si,offset LinBuff        ; editaán° buffer
         mov       ch,0
         mov       cl,ds:[LinNum]           ; poáet bajtñ v editaán°m bufferu
         push      cs
         call      near ptr ModiRozZ        ; rozbor zad†n° s hl†®en°m chyby
         jc        ModiSou0                 ; p©eru®en° operace
         jnz       ModiSou3                 ; opakov†n° zad†n°

; ------ zapnut° nebo vypnut° atributñ v oknà

ModiSou4:test      byte ptr ds:[ModiWPar],bit0 ; bylo nàco zad†no ?
         jz        ModiSou5                 ; nebylo nic zad†no
         call      far ptr GetAAWin         ; adresa aktivn°ho okna
         jc        ModiSou5                 ; chyba ?
         call      far ptr TestAAWn         ; zapnuto aktivn° okno ?
         jc        ModiSou5                 ; aktivn° okno nezapnuto
         test      byte ptr es:[AWinPrm1],bit3+bit5 ; adres†© nebo seznam ?
         jz        ModiSou5                 ; ne - tak to nen° pot©eba
         or        byte ptr es:[AWinPrm2],bit7 ; zapnut° atributñ
         test      byte ptr ds:[ModiWPar],bit1 ; je zapnut° atributñ ?
         jnz       ModiSo42                 ; je zapnut° atributñ
         and       byte ptr es:[AWinPrm2],not bit7 ; vypnut° atributñ

ModiSo42:push      ax
         push      si

         mov       al,es:[AWinPrm2]
         mov       si,offset ParamLC        ; parametry levÇho okna
         test      byte ptr ds:[WindPar],bit0 ; je aktivn° levÇ okno ?
         jnz       ModiSo44                 ; je aktivn° levÇ okno
         mov       si,offset ParamRC        ; parametry pravÇho okna
ModiSo44:mov       ds:[si],al               ; £schova parametrñ

         pop       si
         pop       ax

; ------ test, zda bylo nàco zad†no

ModiSou5:test      byte ptr ds:[ModiWPar],bit2+bit4+bit5+bit6+bit7 ; zad†no ?
         jz        ModiSou0                 ; nebylo nic zad†no - konec

; ------ zobrazen° £vodn°ho textu a inicializace

         call      far ptr HistADir         ; uloëen° adres†©e do historie
         mov       si,offset ModiTxt        ; text "Modifikuji"
         call      far ptr InfDisp0         ; zobrazen° textu
         call      far ptr InitFSet         ; inicializace oznaáen° poloëek

; ------ poskytnut° souboru k operaci

ModiSou6:call      far ptr DispTime         ; obsluha áasu
         call      far ptr DarkNul          ; nulov†n° stm°vaáe obrazovky
         call      far ptr GetFFil          ; poskytnut° souboru
         jnc       ModiSo61                 ; je dal®° soubor OK
         jmp       ModiSou9                 ; nen° dal®° soubor

ModiSo61:call      far ptr DispAAWn         ; zobrazen° okna
         test      byte ptr ds:[FileParm],bit3 ; je adres†© p©i n†vratu ?
         jz        ModSo612                 ; nen° to adres†© p©i n†vratu
         jmp       ModiSou7                 ; je to adres†© p©i n†vratu

; ------ zobrazen° informaán°ho textu

ModSo612:mov       di,offset ModiTxt        ; text "Modifikuji"
         call      far ptr InfFile          ; zobrazen° jmÇna poloëky

; ------ p©°prava poëadovanÇho data a áasu souboru -> DX, CX

         mov       cx,ds:[FileFTim]         ; áas souboru
         and       cx,ds:[ModiTimM]         ; maskov†n° áasu
         or        cx,ds:[ModiTim]          ; nastaven° poëadovanÇho áasu
         mov       dx,ds:[FileFDat]         ; datum souboru
         and       dx,ds:[ModiDatM]         ; maskov†n° data
         or        dx,ds:[ModiDat]          ; nastaven° poëadovanÇho data

; ------ test, zda se nastavuje datum a áas

         test      byte ptr ds:[ModiWPar],bit4+bit5+bit6+bit7 ; zad†n datum/áas ?
         jz        ModiSo64                 ; nezad†n datum ani áas
         test      byte ptr ds:[FileFAtr],DIR ; je to adres†© ?
         jnz       ModiSo63                 ; je adres†©

; ------ nastaven° poëadovanÇho data a áasu souboru (nastavuje atribut ARC !)

         call      far ptr OpenR            ; otev©en° souboru pro áten°
         jc        ModiSo62                 ; nàjak† chyba
         call      far ptr SetDFile         ; nastaven° data a áasu souboru
         pushf
         call      far ptr ClosFile         ; uzav©en° souboru
         popf
         jnc       ModiSo64                 ; operace probàhla OK

; ------ chyba - nelze nastavit parametry poloëky

ModiSo62:call      far ptr TestBEsc         ; test p©eru®en° operace
         jc        ModiSou9                 ; p©eru®en° operace
         call      far ptr DekFParm         ; p©°prava parametrñ souboru
         mov       si,offset ChbErMod       ; text - chyba modifikace
         call      far ptr Lin0MenF         ; chybovÇ hl†®en°
         jnc       ModiSou8
         call      far ptr SetEsc           ; p©°znak p©eru®en° operace ESC
         jmp       short ModiSou8

; ------ nastaven° data a áasu pro adres†©

ModiSo63:test      byte ptr ds:[Win95Par],bit2 ; jsou dlouh† jmÇna ?
         jnz       ModiSo64                 ; nen° dlouhÇ jmÇno
         call      far ptr SetDTDir         ; nastaven° data a áasu adres†©e
         jc        ModiSo62                 ; byla chyba operace

; ------ nastaven° atributñ poloëky (i kdyby nebyly zadanÇ - màn° se ARC !)

ModiSo64:mov       cl,ds:[FileFAtr]         ; atributy poloëky
         and       cl,ds:[ModiAtrM]         ; maskov†n° atributñ
         or        cl,ds:[ModiAtr]          ; nastaven° poëadovanòch atributñ
         and       cl,RO + HID + SYS + DIR + ARC ; pouze povolenÇ atributy
         call      far ptr SetAFile         ; nastaven° atributñ poloëky
         jc        ModiSo62                 ; chyba operace

; ------ operace provedena OK (zde je ES=DS !) - odznaáen° poloëky

ModiSou7:call      far ptr ResFFil          ; nulov†n° oznaáen° poloëky
ModiSou8:mov       si,offset FilePath       ; jmÇno souboru
         mov       cx,ds:[FilePthN]         ; dÇlka textu cesty
         call      far ptr AktWFile         ; aktualizace poloëky

; ------ p©°prava pro dal®° poloëku

         call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jc        ModiSou9                 ; p©eru®en° operace
         jmp       ModiSou6                 ; nen° p©eru®en° - dal®° poloëka

; ------ uzav©en° reëimu modifikace

ModiSou9:jmp       ModiSou0

; -----------------------------------------------------------------------------
;        p©°prava p©edvoleb
; -----------------------------------------------------------------------------

ModSPred PROC      NEAR

; ------ test, zda bude p©edvolba 2 (zapnut°/vypnut° zobrazen° atributñ)

;         mov       byte ptr ds:[SMMMLPrN],1 ;  bude 1 p©edvolba
;         call      far ptr GetAAWin         ; adresa aktivn°ho okna
;         jc        ModSPre2                 ; chyba ?
;         call      far ptr TestAAWn         ; zapnuto aktivn° okno ?
;         jc        ModSPre2                 ; aktivn° okno nezapnuto
;         test      byte ptr es:[AWinPrm1],bit3+bit5 ; adres†© nebo seznam ?
;         jz        ModSPre2                 ; ne - tak to nen° pot©eba
;         test      byte ptr es:[AWinPrm2],bit5+bit6 ; je to 1-sloupcovÇ okno ?
;         jnz       ModSPre2                 ; nen° to 1-sloupcovÇ okno
;         inc       byte ptr ds:[SMMMLPrN]   ;  bude 1 p©edvolba
;
;; ------ p©edvolba 2 - zapnut°/vypnut° zobrazen° atributñ
;
;         mov       al,"+"                   ; zapnut° atributñ
;         test      byte ptr es:[AWinPrm2],bit7 ; zobrazeny atributy ?
;         jz        ModSPre1                 ; atributy nejsou zobrazeny
;         mov       al,"-"                   ; vypnut° atributñ
;ModSPre1:mov       ds:[SMMMLPr2],al         ; p©°prava p©edvolby

; ------ p©°prava fale®nÇ poloëky, nen°-li poloëka pod kurzorem

ModSPre2:mov       byte ptr ds:[FileFAtr],0 ; atributy - v®echno na 0
         call      far ptr GetSDate         ; poskytnut° systÇmovÇho data
         mov       ds:[FileFDat],dx         ; aktu†ln° datum
         call      far ptr GetSTime         ; poskytnut° systÇmovÇho áasu
         mov       ds:[FileFTim],dx         ; aktu†ln° áas

; ------ poloëka pod kurzorem -> ES:SI

         call      far ptr TestAAWn         ; je aktivn° okno zapnuto ?
         jc        ModSPre3                 ; aktivn° okno nen° zapnuto
         call      far ptr GetAKurz         ; poskytnut° poloëky pod kurzorem
         jnc       ModSPre4                 ; poloëka je OK
ModSPre3:push      ds
         pop       es                       ; ES <- datovò segment
         mov       si,offset FileFPol       ; adresa fale®nÇ poloëky souboru

; ------ dek¢dov†n° atributñ

ModSPre4:mov       di,offset SMMMLPr1       ; buffer p©edvolby
         mov       al,es:[si+FileAtr]       ; atributy souboru
         shl       al,1                     ; p©eskoáen° bitu ATRT
         shl       al,1                     ; p©eskoáen° bitu ATRO
         mov       ah,"A"
         call      ModSPrA                  ; atribut ARC
         shl       al,1                     ; p©eskoáen° bitu DIR
         shl       al,1                     ; p©eskoáen° bitu ATRU
         mov       ah,"S"
         call      ModSPrA                  ; atribut SYS
         mov       ah,"H"
         call      ModSPrA                  ; atribut HID
         mov       ah,"R"
         call      ModSPrA                  ; atribut R/O

; ------ dek¢dov†n° data a áasu

         inc       di                       ; p©eskoáen° mezery
         inc       di                       ; p©eskoáen° znaku "D"
         push      ds
         mov       dx,ds                    ; DX <- datovò segment

         push      ds
         push      es
         pop       ds                       ; DS <- segment poloëky
         pop       es                       ; ES <- datovò segment
         mov       ah,0                     ; barva se neukl†d†
         call      far ptr DekA4Dat         ; dek¢dov†n° data

         inc       di                       ; p©eskoáen° mezery
         inc       di                       ; p©eskoáen° znaku "T"
         call      far ptr DekATmS          ; dek¢dov†n° áasu poloëky

         pop       ds
         ret

ModSPred ENDP

; ------ dek¢dov†n° jednoho atributu

ModSPrA: shl       al,1                     ; je atribut nastaven ?
         jc        ModSPrA2                 ; atribut je nastaven
         add       ah,"a"-"A"               ; korekce na malÇ p°smeno
ModSPrA2:mov       ds:[di],ah               ; uloëen° znaku
         inc       di                       ; zvò®en° ukl†dac° adresy
         ret

; *****************************************************************************
;                                   RozbCil
;           zad†n° a rozbor zad†n° c°le operace (tj. soubor + parametry)
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=menu volby
;        DS=datovò segment
; VùSTUP: CY=p©eru®en° operace
; -----------------------------------------------------------------------------
; niá° v®echny registry (kromà DS a BP)
; *****************************************************************************

RozbCil  PROC      FAR

         push      bp

; ------ zad†n° operace

         mov       bp,si                    ; BP <- £schova adresy menu
RozbCil1:call      far ptr Lin0Menu         ; zad†n° operace
         jc        RozbCil9                 ; p©eru®en° operace

; ------ nalezen° zaá†tku parametrñ

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       di,offset LinBuff        ; zaá†tek bufferu
         mov       ch,0
         mov       cl,ds:[LinNum]           ; dÇlka zadanÇho textu
         jcxz      RozbCil3                 ; nen° nic zad†no (CX=0, SI n†hodnÇ)
         cld
         mov       al,"/"                   ; oznaáen° parametrñ
         repne     scasb                    ; nalezen° znaku "/"
         jne       RozbCil3                 ; nejsou parametry (CX=0, SI n†hodnÇ)

; ------ zkr†cen° textu v ©†dku o parametry

         mov       si,di                    ; SI <- zaá†tek parametrñ
         mov       ax,di
         sub       ax,offset LinBuff+1      ; dÇlka textu jmÇna souboru (bez /)
         mov       ds:[LinNum],al           ; nov† dÇlka jmÇna souboru/adres†©e

; ------ rozbor zad†n° parametrñ

RozbCil3:call      far ptr ModiRozZ         ; rozbor zad†n° parametrñ
         jc        RozbCil9                 ; p©eru®en° operace
         mov       si,bp                    ; SI <- adresa menu
         jnz       RozbCil1                 ; opakov†n° zad†n° operace

RozbCil9:pop       bp
         ret

RozbCil  ENDP

; *****************************************************************************
;                                 ModiRozZ
;                    rozbor zad†n° parametrñ s kontrolou
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
;        DS:SI=adresa zaá†tku textu
;        CX=poáet znakñ
; VùSTUP: CY=p©eru®en° operace
;         NZ=chyba zad†n° parametrñ, opakov†n° zad†n°
;         ZY=v®e OK
; *****************************************************************************

ModiRozZ PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

; ------ rozbor zad†n° parametrñ operace

         push      cs
         call      near ptr ModiRozb        ; rozbor zad†n° parametrñ operace
         jnc       ModRozZ8                 ; parametry zad†ny OK

; ------ chyba zad†n° parametrñ operace

         mov       si,offset ChbLnPar       ; menu - chyba zad†n°
         call      far ptr Lin0MenF         ; chybovÇ hl†®en°
         jc        ModRozZ9                 ; p©eru®en° operace

; ------ opakov†n° zad†n° parametrñ operace

         or        si,si                    ; p©°znaky NC, NZ = opakov†n° zad†n°
         jmp       short ModRozZ9

; ------ n†vrat registrñ

ModRozZ8:xor       cx,cx                    ; p©°znaky NC, ZY = v®e OK
ModRozZ9:pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ModiRozZ  ENDP

; *****************************************************************************
;                              ModiRozb
;            rozbor zad†n° parametrñ k modifikaci souborñ
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa zaá†tku textu
;        CX=poáet znakñ
; VùSTUP: CY=chyba zad†n° parametrñ
;         DS:SI=adresa chyby
;         CX=poáet zbylòch znakñ
; *****************************************************************************
;˛
ModiRozb PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      dx
         push      di
         push      bp
         push      es

         mov       bp,si                    ; BP <- £schova zaá†tku textu
         push      ds
         pop       es                       ; ES <- datovò segment

; ------ inicializace ukazatelñ

         xor       ax,ax                    ; AX <- 0
         mov       ds:[ModiWPar],al         ; p©°znaky zad†n° parametrñ
         mov       ds:[ModiAtr],al          ; atributy k modifikaci poloëky
         mov       ds:[ModiTim],ax          ; áas k modifikaci poloëky
         mov       ds:[ModiDat],ax          ; datum k modifikaci poloëky
         dec       ax                       ; AX <- -1
         mov       ds:[ModiAtrM],al         ; maska atributñ k modifikaci
         mov       ds:[ModiTimM],ax         ; maska áasu k modifikaci poloëky
         mov       ds:[ModiDatM],ax         ; maska data k modifikaci poloëky

; ------ naáten° prvn°ho znaku

ModiRoz1:call      RozbPCh                  ; naáten° jednoho znaku
         jnc       ModiRoz2                 ; je nàjakò platnò znak
         clc                                ; p©°znak operace OK
         jmp       ModiRoz9                 ; konec parametrñ
ModiRoz2:call      far ptr UpCase           ; konverze znaku na velkÇ p°smeno

; ------ datum "D"

         cmp       al,"D"                   ; je zad†n° data ?
         jne       ModiRoz3                 ; nen° zad†n° data
         call      ModiRDat                 ; rozbor zad†n° data
         jmp       short ModiRoz1           ; dal®° parametr

; ------ áas "T"

ModiRoz3:cmp       al,"T"                   ; je zad†n° áasu ?
         jne       ModiRoz4                 ; nen° zad†n° áasu
         call      ModiRTim                 ; rozbor zad†n° áasu
         jmp       short ModiRoz1           ; dal®° parametr

; ------ zapnut° atributñ "+"

ModiRoz4:cmp       al,"+"                   ; je zapnut° atributñ ?
         jne       ModiRoz5                 ; nen° zapnut° atributñ
         or        byte ptr ds:[ModiWPar],bit0 + bit1 ; p©°znak zapnut° atributñ
         jmp       short ModiRoz1           ; dal®° parametr

; ------ vypnut° atributñ "-"

ModiRoz5:cmp       al,"-"                   ; je vypnut° atributñ ?
         jne       ModiRoz6                 ; nen° vypnut° atributñ
         or        byte ptr ds:[ModiWPar],bit0 ; p©°znak zad†n° parametru
         and       byte ptr ds:[ModiWPar],not bit1 ; p©°znak vypnut° atributñ
         jmp       short ModiRoz1           ; dal®° parametr

; ------ atributy

ModiRoz6:mov       di,offset ModiAtr        ; atributy
         cmp       al,"C"                   ; atribut "C" nen° povolen
         je        ModiRoz8                 ; chyba
         not       byte ptr ds:[di+1]       ; maska m† opaánò vòznam
         call      RozbPAtr                 ; rozbor zad†n° atributñ
         pushf
         not       byte ptr ds:[di+1]       ; n†vrat vòznamu masky
         popf
         jc        ModiRoz8                 ; chyba
         or        byte ptr ds:[ModiWPar],bit2 ; p©°znak zad†n° atributñ
         jmp       short ModiRoz1           ; dal®° parametr

; ------ chybnò znak - p©enesen° textu chyby do bufferu

ModiRoz8:call      RozbPErr                 ; £schova textu chyby

; ------ n†vrat registrñ

ModiRoz9:pop       es
         pop       bp
         pop       di
         pop       dx
         pop       bx
         pop       ax
         ret

ModiRozb ENDP

; -----------------------------------------------------------------------------
;        rozbor zad†n° data (parametr "D datum")
; -----------------------------------------------------------------------------
; niá° registry: AX, BX, DX, DI
; -----------------------------------------------------------------------------

ModiRDat PROC      NEAR

; ------ nulov†n° ukazatelñ

         or        byte ptr ds:[ModiWPar],bit4 ; p©°znak zad†n° data
         and       byte ptr ds:[ModiWPar],not bit5 ; zru®en° p©°znaku implicit.

         mov       di,offset ModiDat        ; datum
         call      RozbPDt0                 ; rozbor zad†n° data
         not       word ptr ds:[di+2]       ; oprava vòznamu masky

; ------ nastaven° aktu†ln°ho systÇmovÇho data

         cmp       word ptr ds:[di+2],-1    ; bylo nàco zad†no ?
         jne       ModiRDt5                 ; bylo nàco zad†no
         xor       byte ptr ds:[ModiWPar],bit4+bit5 ; p©°znak implicitn°ho data
         call      far ptr GetSDate         ; poskytnut° systÇmovÇho data
         mov       ds:[di],dx               ; aktu†ln° datum
         not       word ptr ds:[di+2]       ; 0=maska pro nulov†n° starÇho data
ModiRDt5:ret

ModiRDat ENDP

; -----------------------------------------------------------------------------
;        rozbor zad†n° áasu (parametr "T áas")
; -----------------------------------------------------------------------------
; niá° registry: AX, BX, DX, DI
; -----------------------------------------------------------------------------

ModiRTim PROC      NEAR

; ------ rozbor áasu

         or        byte ptr ds:[ModiWPar],bit6 ; p©°znak zad†n° áasu
         and       byte ptr ds:[ModiWPar],not bit7 ; zru®en° p©°znaku implicit.
         mov       di,offset ModiTim        ; áas
         call      RozbPHod                 ; rozbor hodin
         call      RozbPMin                 ; rozbor minut
         call      RozbPSek                 ; rozbor sekund
         not       word ptr ds:[di+2]       ; oprava vòznamu masky

; ------ nastaven° aktu†ln°ho systÇmovÇho áasu

         cmp       word ptr ds:[di+2],-1    ; je áas zad†n ?
         jne       ModiRTm9                 ; áas je zad†n
         xor       byte ptr ds:[ModiWPar],bit6+bit7 ; áas implicitn°
         call      far ptr GetSTime         ; poskytnut° systÇmovÇho áasu
         mov       ds:[di],dx               ; aktu†ln° áas
         not       word ptr ds:[di+2]       ; 0=maska pro nulov†n° starÇho áasu
ModiRTm9:ret

ModiRTim ENDP

; *****************************************************************************
;
;                           Start programu
;
; *****************************************************************************
;˛
Program  PROC      FAR

         mov       ax,word ptr ds:[SMnuVert+MnuPoz] ; pozice p©edchoz°ho okna
         add       ax,0607h                 ; posun okna
         mov       word ptr ds:[si+MnuPoz],ax        ; pozice okna

         push      dx
         mov       dl,ds:[ProgSwc]
         call      far ptr SetSwch          ; nastaven° p©ep°naáñ
         pop       dx

         jmp       far ptr VertMenu

Program  ENDP

; ------ p©ep°naá BAT m¢d

Progr101 PROC      FAR

         mov       al,bit0
Progr102:and       dl,not bit0+bit1+bit2
         or        dl,al
         and       byte ptr ds:[ProgSwc],not bit0+bit1+bit2
         or        ds:[ProgSwc],al
         call      far ptr SetSwch
         call      far ptr DispMnu
         ret

Progr101 ENDP

; ------ p©ep°naá LOADER m¢d

Progr104:mov       al,bit1
         jmp       short Progr102

; ------ p©ep°naá PERMANENT m¢d

Progr105:mov       al,bit2
         jmp       short Progr102

;Progr106:xor       dl,bit3
;         jmp       short Progr103
;
;Progr107:xor       dl,bit4
;         jmp       short Progr103
;
;Progr108:xor       dl,bit5
;         jmp       short Progr103

; -----------------------------------------------------------------------------
;        Program pod kurzorem
; -----------------------------------------------------------------------------

Progr2   PROC      FAR

         add       sp,4                     ; zru®en° n†vratovÇ adresy
         call      far ptr ClosMnuA         ; uzav©en° oken menu
         jmp       far ptr AWEnter0         ; proveden° p©°kazu

Progr2   ENDP

; -----------------------------------------------------------------------------
;        uëivatelskÇ menu
; -----------------------------------------------------------------------------

Progr3   PROC      FAR

         add       sp,4                     ; zru®en° n†vratovÇ adresy
         call      far ptr ClosMnuA         ; uzav©en° oken menu
         jmp       far ptr UserMenu         ; uëivatelskÇ menu

Progr3   ENDP

; -----------------------------------------------------------------------------
;        oznaáenÇ soubory
; -----------------------------------------------------------------------------

Progr4   PROC      FAR

         add       sp,4                     ; zru®en° n†vratovÇ adresy
         call      far ptr ClosMnuA         ; uzav©en° oken menu
         jmp       far ptr SelcExec         ; start oznaáenòch souborñ

Progr4   ENDP

; -----------------------------------------------------------------------------
;        Zadanò p©°kaz
; -----------------------------------------------------------------------------

Progr29: jmp       far ptr Main0

Progr5   PROC      FAR

         add       sp,4                     ; zru®en° n†vratovÇ adresy
         call      far ptr ClosMnuA         ; uzav©en° okna menu

; ------ zad†n° p©°kazu Shift-F2

Progr500 LABEL     FAR

         mov       word ptr ds:[SPZMLPlL],0 ; nen° p©edvolba
         mov       al,ds:[LineCNum]         ; poáet zadanòch znakñ
         cmp       al,0                     ; je nàco zad†no ?
         je        Progr501                 ; nen° nic zad†no
         inc       byte ptr ds:[SPZMLPlL]   ; je 1 p©edvolba
         mov       byte ptr ds:[SPZMLPlN],al ; dÇlka p©edvolby

Progr501:mov       si,offset SPZMLin        ; zadanò p©°kaz
         call      far ptr Lin0Menu
         jc        Progr29                  ; p©eru®en°

         mov       si,offset LinBuff        ; buffer
         mov       di,offset LineCBuf       ; buffer p©°kazu
         mov       ch,0
         mov       cl,ds:[LinNum]
         jcxz      Progr29                  ; nen° nic zad†no

         mov       ds:[LineCNum],cl         ; poáet zadanòch znakñ
         mov       ds:[LineCKur],cl         ; souáasnà pozice kurzoru
         push      ds
         pop       es
         cld
         rep       movsb                    ; p©enos zadanÇho p©°kazu

         test      byte ptr ds:[LinParm],bit0 ; je ukonáen° Ctrl-ENTER ?
         jz        Progr504                 ; nen° Ctrl-ENTER
         mov       ds:[LineCTop],cl         ; zobrazenò poá†tek
         call      far ptr DispLCom         ; zobrazen° p©°kazovÇho ©†dku
         jmp       short Progr29

Progr504:call      far ptr QSrcEnd          ; ukonáen° reëimu rychlovyhled†v†n°
         jmp       short ProgrEx2

; ------ proveden° p©°kazu z p©°kazovÇho ©†dku
; Pozor - je-li vol†no z inicializaán° sekvence, nemus° bòt je®tà okna naátena !

;˛
ProgrExe LABEL     FAR

         call      far ptr QSrcEnd          ; ukonáen° reëimu rychlovyhled†v†n°

; ------ pro extern° stm°vaá se neukl†d† historie, aby nerachotil disk

         test      byte ptr ds:[StartPar],bit1 ; je aktualizace INI souboru ?
         jnz       ProgrEx1                 ; je aktualizace INI souboru
         test      byte ptr ds:[ProgSwc3],bit1 ; je obsluha stm°vaáe ?
         jnz       ProgrEx1                 ; je obsluha ext. stm°vaáe

         call      far ptr HistADir         ; uloëen° adres†©e do historie

ProgrEx1:push      ds
         pop       es
         mov       si,offset AktPath        ; aktu†ln° adres†©
         call      far ptr SetDDir          ; nastaven° aktu†ln°ho adres†©e

         mov       al,HistComm              ; historie p©°kazñ
         mov       si,offset LineCBuf       ; buffer p©°kazu
         mov       ch,0
         mov       cl,ds:[LineCNum]         ; poáet bajtñ v bufferu

         test      byte ptr ds:[ProgSwc3],bit1 ; je obsluha stm°vaáe ?
         jnz       ProgEx28                 ; je obsluha ext. stm°vaáe

         test      byte ptr ds:[ProgSwc],bit7 ; je $DOSMAN$.BAT ?
         jnz       ProgrEx2                 ; je $DOSMAN$.BAT
         test      byte ptr ds:[ProgSwc2],bit0 ; je p©°kaz z EXTENSION/MENU ?
         jnz       ProgrEx2                 ; je EXTENSION/MENU
         test      byte ptr ds:[StartPar],bit1 ; je aktualizace INI souboru ?
         jnz       ProgrEx2                 ; je aktualizace INI souboru

         call      far ptr InsHist          ; uloëen° textu do historie

ProgrEx2:

         mov       si,offset ProgTxt1
         call      far ptr InfDisp0         ; zobrazen° informaán°ho textu

;; ------ n†hrada znakñ "||" v p©°kazu p©elomy ©†dkñ
;
;         mov       si,offset LineCBuf
;         mov       cl,ds:[LineCNum]
;         mov       ch,0
;         jcxz      ProgEx28
;         dec       cx
;         jz        ProgEx28
;         cld
;ProgEx22:lodsb
;         cmp       al,'"'
;         jne       ProgEx24
;ProgEx23:
;
;
;ProgEx24:
;
;
;
;ProgEx27:
;
;
;

ProgEx28:mov       es,ds:[SegPSP]
         mov       di,81h
         cld

         cmp       word ptr ds:[EnvSize],0  ; je prost©ed° definov†no ?
         je        Progr520                 ; nen° prost©ed° definov†no

         mov       ax,"E/"
         stosw
         mov       al,":"
         stosb
         mov       ax,ds:[EnvSize]          ; velikost prost©ed°
         xor       bx,bx
         call      far ptr DekNumW          ; dek¢dov†n° á°sla
         cld
         mov       al," "
         stosb

Progr520:mov       ax,"C/"
         stosw
         mov       al," "
         stosb
         mov       ax,0ffh - 2 - 1          ; asi tak konec ©†dku
         sub       ax,di                    ; zbylÇ m°sto

         mov       cs:[ProgAdrB],di         ; £schova adresy p©°kazu

         mov       ch,0
         mov       cl,ds:[LineCNum]
         cmp       cl,al
         jbe       Progr521                 ; dÇlka je OK
         mov       cl,al                    ; omezen° dÇlky textu
Progr521:mov       cs:[ProgAdrN],cx         ; dÇlka textu
         mov       si,offset LineCBuf
         rep       movsb
         mov       ax,CR+LF*HI
         stosw                              ; ukonáovac° CR

         mov       ax,di                    ; konec textu
         sub       ax,81h+2                 ; velikost textu
         mov       es:[80h],al

; ------ paket parametrñ

         mov       word ptr ds:[ExecPck0],80h ; adresa p©°kazovÇho ©†dku
         mov       ds:[ExecPck1],es
         mov       ds:[ExecPck2],es
         mov       ds:[ExecPck3],es
;         mov       ax,ds:[EnvParnt]         ; otcovskÇ prost©ed°
;         or        ax,ax
;         jnz       Prog5202
         mov       ax,es:[2ch]
Prog5202:mov       ds:[ExecPckE],ax

; ------ naáten° jmÇna programu COMMAND.COM

         mov       si,offset ComSpc         ; parametr "COMSPEC"
         call      far ptr Get0Env          ; nalezen° parametru COMSPEC
         jnc       Prg52022                 ; parametr nalezen OK

         mov       si,offset Command        ; parametr "COMMAND"
         push      ds
         pop       es                       ; ES <- datovò segment

Prg52022:mov       di,offset ExecPath       ; buffer k uloëen° jmÇna

         push      ds

         push      ds
         push      es
         pop       ds                       ; DS <- segment parametru
         pop       es                       ; ES <- datovò segment
         cld
Prg52023:cmp       di,offset ExecPath+FileMax-1
         jbe       Prg52024
         dec       di
Prg52024:lodsb
         stosb
         cmp       al,0
         jne       Prg52023

         pop       ds

; ------ uloëen° historie na disk

         call      far ptr StoSHist         ; uloëen° historie

; ------ n†vrat obrazovky

         call      far ptr ClosMnuA         ; uzav©en° v®ech menu

         test      byte ptr ds:[ProgSwc3],bit1 ; je obsluha stm°vaáe ?
         jnz       Pro51031                 ; je obsluha ext. stm°vaáe

         cmp       byte ptr ds:[STopLine],-1
         jne       Prog5101
         mov       word ptr ds:[STopAdr],0
         mov       byte ptr ds:[STopLine],0

Prog5101:xor       dx,dx
         mov       cl,ds:[Pozic]
         mov       ch,ds:[Radku]
         call      far ptr PopScr
         mov       dx,ds:[SKurzor]          ; uschovanò systÇmovò kurzor

         cmp       dh,ds:[MaxRow]           ; p©ekroáen maxim†ln° ©†dek ?
         jbe       Prog5102                 ; ©†dek je OK
         mov       dh,ds:[MaxRow]           ; omezen° ©†dku
Prog5102:cmp       dl,ds:[MaxPoz]           ; p©ekroáena maxim†ln° pozice ?
         jbe       Prog5103                 ; pozice je OK
         mov       dl,ds:[MaxPoz]           ; omezen° pozice
Prog5103:
         call      far ptr SetKurz          ; nastaven° kurzoru

; ------ vypnut° my®i

Pro51031:call      far ptr MouseOff         ; vypnut° kurzoru my®i
         call      far ptr PopFont          ; n†vrat definice fontñ
         test      byte ptr ds:[ParDisp],bit6 ; maj° se navracet fonty ?
         jnz       Pro51032                 ; fonty se maj° vracet
         call      far ptr InitFont
Pro51032:

; ------ odinstalov†n° obsluh p©eru®en°

         call      far ptr DeInsInt         ; odinstalov†n° obsluh p©eru®en°

; ------ nastaven° p©echodnÇho z†sobn°ku

         push      ss
         pop       es                       ; £schova segmentu z†sobn°ku
         mov       ax,SEG StackS            ; segment z†sobn°ku
         mov       ss,ax                    ; segment z†sobn°ku
         mov       sp,256                   ; adresa konce z†sobn°ku

; ------ uvolnàn° alokaán°ho bloku z†sobn°ku

         mov       ah,49h
         int       21h                      ; uvolnàn° bloku z†sobn°ku

; ------ uvolnàn° datovÇho bloku pamàti

         mov       es,ds:[TopSeg]           ; alokaán° datovò blok pamàti
         mov       ah,49h
         int       21h                      ; uvolnàn° bloku pamàti

; ------ extern° stm°vaá se startuje vëdy v rychlÇm m¢du

         test      byte ptr ds:[ProgSwc3],bit1 ; je obsluha stm°vaáe ?
         jnz       Progr534                 ; start v rychlÇm m¢du
         test      byte ptr ds:[StartPar],bit1 ; je aktualizace INI souboru ?
         jnz       Progr534                 ; je aktualizace INI souboru

; ------ proveden° p©°kazu pomoc° $DOSMAN$.BAT

         test      byte ptr ds:[UserSwcM],bit1 ; je menu s povelem "!" ?
         jz        Prog5104                 ; nen° menu s povelem "!"
         test      byte ptr ds:[UserSwcM],bit2 ; je m¢d spou®tàn° s BAT ?
         jnz       Prog5105                 ; nen° m¢d spou®tàn° s BAT
         jmp       short Progr53            ; jinò m¢d spou®tàn°

Prog5104:test      byte ptr ds:[ProgSwc],bit0 ; je BAT m¢d ?
         jz        Progr53                  ; nen° BAT m¢d
Prog5105:call      far ptr StorBCnf         ; uloëen° konfigurace

; ------ z†pis p©°kazu do souboru

         test      byte ptr ds:[ProgSwc],bit7 ; je jië $DOSMAN$.BAT ?
         jnz       Progr51                  ; je jië $DOSMAN$.BAT
         call      far ptr OpenBPth         ; vytvo©en° souboru
         jc        Progr51

         mov       es,ds:[SegPSP]           ; segment PSP
         mov       si,cs:[ProgAdrB]         ; zaá†tek dat
         mov       cx,cs:[ProgAdrN]         ; dÇlka dat
         inc       cx
         inc       cx
         call      far ptr WritFile         ; z†pis dat do souboru

         call      far ptr ClosFile

Progr51: mov       es,ds:[RezPSP]
         mov       byte ptr es:[80h],1      ; je m¢d BAT
         mov       ax,4c00h
         int       21h

ProgAdrB dw        81h                      ; uschovan† adresa zaá†tku p©°kazu
ProgAdrN dw        0                        ; dÇlka textu

; ------ proveden° p©°kazu bez zru®en° DOSMANu

Progr53: test      byte ptr ds:[UserSwcM],bit1 ; je menu s povelem "!" ?
         jz        Progr532                 ; nen° menu s povelem "!"
         test      byte ptr ds:[UserSwcM],bit4 ; je rychlò m¢d ?
         jz        Progr54                  ; nen° rychlò m¢d
         jmp       short Progr534           ; jinak rychlò m¢d

Progr532:test      byte ptr ds:[ProgSwc],bit2 ; je rychlò m¢d ?
         jz        Progr54                  ; nen° rychlò m¢d

; ------ start programu (DS=datovò segment)

Progr534:call      far ptr StoPCnf          ; uloëen° konfigurace

         push      ds
         mov       ax,SEG CodeLod           ; segment zavadàáe
         mov       ds,ax
         mov       dx,offset INT024
         mov       ax,2524h
         int       21h                      ; p©edefinov†n° INT 24h
         mov       dx,offset INT023
         mov       ax,2523h
         int       21h                      ; p©edefinov†n° INT 23h
         pop       ds

         push      ds
         pop       es
         mov       dx,offset ExecPath       ; cesta k programu
         mov       bx,offset ExecPack       ; paket parametrñ
         mov       ax,4b00h
         test      byte ptr ds:[StartPar],bit1 ; je aktualizace INI souboru ?
         jnz       Progr536                 ; je aktualizace INI souboru
         int       21h                      ; start programu

; ------ obnoven° ukazatele z†sobn°ku

Progr536:mov       ax,SEG StackS            ; segment z†sobn°ku
         mov       ss,ax                    ; segment z†sobn°ku
         mov       sp,256                   ; adresa konce z†sobn°ku

; ------ obnoven° registrñ

         mov       ax,SEG Data              ; datovò segment
         mov       ds,ax                    ; DS <- datovò segment
         mov       es,ds:[SegPSP]           ; segment PSP
         mov       byte ptr es:[80h],0      ; nen° nic v p©°kazovÇm ©†dku

; ------ novò start programu

         or        byte ptr ds:[StartPar],bit2 ; p©°znak opakovanÇho startu
         jmp       far ptr ReStart          ; opakovanò start

; ------ skok do obsluhy p©°kazu

Progr54: call      far ptr StoPCnf          ; uloëen° konfigurace
         mov       si,offset ConfBeg
         mov       di,si
         push      ds
         pop       es
         call      far ptr TestDSum         ; kontroln° souáet
         mov       ds:[si+4],dx             ; nastaven° kontroln°ho souátu
         test      byte ptr ds:[StartPar],bit0 ; je rezidentn° modul ?
         jnz       Progr55                  ; je rezidentn° modul
         jmp       far ptr Execute          ; proveden° p©°kazu

; ------ £schova dat do rezidentn°ho modulu

Progr55: mov       es,ds:[RezData]          ; rezidentn° data
         mov       cx,offset ConfEnd
         sub       cx,si
         cld
         rep       movsb                    ; £schova dat

         mov       di,80h
         mov       ax,ds:[RezPSP]
         mov       es:[ExecPck1],ax         ; segment p©°kazovÇho ©†dku
         mov       es:[ExecPck0],di         ; offset p©°kazovÇho ©†dku

         push      ds
         mov       es,ax
         mov       ds,ds:[SegPSP]
         mov       si,di
         mov       cl,128
         cld
         rep       movsb
         pop       ds

         mov       ax,4c00h
         int       21h

Progr5   ENDP

; -----------------------------------------------------------------------------
;        otev©en° souboru $DOSMAN$.BAT -> AX identifik†tor, CY=chyba
; -----------------------------------------------------------------------------

OpenBPth PROC      FAR

; ------ £schova regisrñ

         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp

; ------ sestaven° jmÇna souboru

         sub       sp,FileMax
         push      ss
         pop       es
         mov       di,sp
         mov       si,offset DosmBat
         call      far ptr TempFile         ; sestaven° jmÇna souboru

; ------ vytvo©en° souboru

         test      byte ptr ds:[TempDirP],bit0 ; je z†kaz z†pisu ?
         stc                                ; p©°znak chyby
         jnz       OpenBPt9                 ; je z†kaz z†pisu
         mov       si,sp
         call      far ptr CreatFil         ; vytvo©en° souboru

; ------ n†vrat registrñ

OpenBPt9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         ret

OpenBPth ENDP

CodeFil  ENDS

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;
;                                 Data
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
Data     SEGMENT   BYTE PUBLIC

; -----------------------------------------------------------------------------
;        Definice menu - informace o souboru
; -----------------------------------------------------------------------------
;˛
SIMnuLin label     byte                   ;* informace o souboru

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        7                        ; poáet platnòch poloëek menu
         dw        24                       ; celkovò poáet poloëek menu

         dw        SIMnLPol                 ; zaá†tek definice poloëek menu
         dw        SIMnLHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@InformaceOSouboru    ; á°slo str†nky velkÇ n†povàdy
         dw        SIMnLBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        SIMnLTit                 ; adresa titulu okna
         dw        SIMnLExe                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        21                       ; poá†teán° pozice okna
         db        5                        ; poá†teán° ©†dek okna
         db        80                       ; ®°©ka okna
         db        22                       ; vò®ka okna

         dw        250                      ; maxim†ln° dÇlka ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit2                     ; maska zad†vanòch znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; identifik†tor historie
         db        0                        ; poáet p©edvoleb

; ------ poloëky voleb

SIMnLPol db        bit6,5,4,0,1
         dw        SRMnuFil                 ; jmÇno souboru

         db        bit6,5,4,0,1             ; dlouhÇ jmÇno
         dw        DTALName-1

         db        bit6,42,'Datum: ',0,1
         dw        SRMnuDat
         db        0,'Velikost: ',0,1
         dw        SRMnuSiz
         db        0,'Atributy: ',0,1
         dw        SRMnuAtr
         db        ' '

         db        bit6,54,'  Äas: ',0,1
         dw        SRMnuTim
         db        0,'  Zab°r†: ',0
SIMKapac db        13 dup(" ")
         db        0,' Souborñ: ',0
SIMSoub  db        6 dup(" ")

         db        bit6,3,1
SIMnLPl3 dw        SRMnuVLn

         db        bit6+bit7,0

         db        bit6,10,4,0,3            ; koment†©
SIMKomK  db        0
         dd        0
         db        2,0                      ; (jen aby byla stejn† dÇlka poloëky)

         REPT      9
         db        bit6,9,4,3               ; popis
         db        0
         dd        0
         db        2,250                    ; mezery zprava
         ENDM

         db        bit6+bit7,0

         db        1,8,'Koment†©'
         db        1,5,'Popis'
         db        1,5,'Dal®°'
         db        1,4,'Zpàt'
         db        1,7,'Redukce'
         db        1,7,'Adres†©'
         db        1,6,'N†vrat'

SIMnLBlk db        0,0,0,0,0,0,0            ; blokovac° tabulka

SIMnLExe label     dword
         dd        Lin0MenR                 ; Koment†©
         dd        Lin0MenR                 ; Editace
         dd        InfoMDal                 ; Dal®°
         dd        InfoMPre                 ; Zpàt
         dd        Lin0MenR                 ; Redukce
         dd        Lin0MenR                 ; Adres†©
         dd        Lin0MenR                 ; N†vrat

SRMnuVL0 db        0

SRMnuVLn db        72,'Vytvo©eno: ',0
SRMnuVtD db        '00.00.0000'          ; datum vytvo©en°
         db        0,'   ...    v: ',0
SRMnuVtT db        '00:00:00'             ; áas vytvo©en°
         db        0,'     Otev©eno: ',0
SRMnuOpn db        '00.00.0000'             ; datum otev©en°

SIMnBuf  dw        0                        ; pracovn° mezibuffer (áas, datum)

; ------ n†povàda

HelpS    SEGMENT   BYTE PUBLIC
SIMnLHlp db        59,'Koment†© k poloëce (zobrazenò v komentovanÇm m¢du Ctrl-K)'
         db        36,'Editace v°ce©†dkovÇho popisu poloëky'
         db        42,'Zobrazen° informac° k dal®° poloëce v oknà'
         db        45,'Zobrazen° informac° k p©ede®lÇ poloëce v oknà'
         db        64,'Redukce koment†©ñ - vypu®tàn° koment†©ñ k neexistuj°c°m poloëk†m'
         db        62,'Koment†© k adres†©i (nadpis okna v komentovanÇm m¢du Ctrl-K)'
         db        26,'N†vrat z informaán°ho okna'
HelpS    ENDS

SIMnLTit db        9,'informace'

SInfSize dd        0                        ; velikost souboru nebo adres†©e
SInfKap  dd        0                        ; zabran† kapacita na disku
SInfSoub dw        0                        ; poáet souborñ v adres†©i
SInfBlk  dw        0                        ; velikost alokaán°ho bloku

InfoCtuT db        21,'Naá°t†m informace o ',0

; ------ menu - koment†© poloëky

SIKMnLin label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        SIKMnPol                 ; zaá†tek definice poloëek menu
         dw        SIKMnHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@KomentareSouboru     ; á°slo str†nky velkÇ n†povàdy
         dw        SIKMnBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        SIKMnTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        20                       ; poá†teán° pozice okna
         db        0                        ; poá†teán° ©†dek okna
         db        27                       ; ®°©ka okna
         db        8                        ; vò®ka okna

         dw        250                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        1                        ; celkovò poáet ©†dkñ
         dw        1                        ; poáet zobrazenòch ©†dkñ

         db        bit2                     ; maska zad†vanòch znakñ - v®echny
         db        3,13,10,0,'   '          ; zak†zanÇ znaky

         db        HistKom                  ; historie koment†©ñ
SIKMnPN1 db        0                        ; poáet p©edvoleb
SIKMnPD1 dw        0                        ; dÇlka p©edvolby
SIKMnPA1 dd        0                        ; adresa p©edvolby

; ------ poloëky voleb

SIKMnPol db        bit6,4,0,1
         dw        SRMnuFil                 ; jmÇno souboru

         db        0,0
         db        bit6+bit7,0
         db        2,6,' Uloë '
         db        1,6,'N†vrat'

SIKMnBlk db        0,0,0                    ; blokovac° tabulka

SIKMnTit db        8,'koment†©'

; ------ n†povàda

HelpS    SEGMENT   BYTE PUBLIC
SIKMnHlp db        58,'Zadejte novò koment†© poloëky (zobrazen† dÇlka 25 znakñ)'
         db        26,'Uloëen° zadanÇho koment†©e'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

; ------ menu - nadpis

SINMnLin label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        SINMnPol                 ; zaá†tek definice poloëek menu
         dw        SINMnHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@KomentareSouboru     ; á°slo str†nky velkÇ n†povàdy
         dw        SINMnBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        SINMnTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        20                       ; poá†teán° pozice okna
         db        0                        ; poá†teán° ©†dek okna
         db        40                       ; ®°©ka okna
         db        8                        ; vò®ka okna

         dw        250                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        1                        ; celkovò poáet ©†dkñ
         dw        1                        ; poáet zobrazenòch ©†dkñ

         db        bit2                     ; maska zad†vanòch znakñ - v®echny
         db        3,13,10,0,'   '          ; zak†zanÇ znaky

         db        HistKom                  ; historie koment†©ñ
SINMnPN1 db        0                        ; poáet p©edvoleb
SINMnPD1 dw        0                        ; dÇlka p©edvolby
SINMnPA1 dd        0                        ; adresa p©edvolby

; ------ poloëky voleb

SINMnPol db        bit6,21,'Novò nadpis adres†©e:'
         db        0,0
         db        bit6+bit7,0
         db        2,6,' Uloë '
         db        1,6,'N†vrat'

SINMnBlk db        0,0,0                    ; blokovac° tabulka

SINMnTit db        6,'nadpis'

; ------ n†povàda

HelpS    SEGMENT   BYTE PUBLIC
SINMnHlp db        57,'Zadejte novò nadpis adres†©e (zobrazen† dÇlka 38 znakñ)'
         db        24,'Uloëen° zadanÇho nadpisu'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

; -----------------------------------------------------------------------------
;        okno editoru pole popisu
; -----------------------------------------------------------------------------
;˛
PopisMnu label     byte
         db        16                       ; typ menu - editace textu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet poloëek menu
         dw        1                        ; celkovò poáet poloëek menu

         dw        0                        ; zaá†tek definice poloëek menu
         dw        TxtMnHl1                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@EditorZapisniku      ; á°slo str†nky velkÇ n†povàdy
         dw        0                        ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        PopMnTit                 ; adresa titulu okna
         dw        LinMenTM                 ; adresy obsluh
         dw        LinMenTM                 ; adresa podmenu
         dd        0                        ; n†vratov† adresa

         db        0                        ; poá†teán° pozice okna
         db        1                        ; poá†teán° ©†dek okna
         db        80                       ; ®°©ka okna
         db        21                       ; vò®ka okna

PopsSegm dw        0                        ; aktivn° segment s textem

PopMnTit db        13,'popis poloëky'

; -----------------------------------------------------------------------------
;        varov†n° p©ed redukc° poloëek
; -----------------------------------------------------------------------------

InfoRMnu label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka volby
         dw        2                        ; poáet platnòch poloëek menu
         dw        10                       ; celkovò poáet poloëek menu

         dw        InfoRMnP                 ; adresa definián° tabulky poloëek
         dw        InfoRMnH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@KomentareSouboru     ; á°slo str†nky velkÇ n†povàdy
         dw        InfoRMnB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        InfoRMnT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        6                        ; poá†teán° pozice
         db        7                        ; poá†teán° ©†dek
         db        54                       ; ®°©ka
         db        13                       ; vò®ka

         dw        255                      ; maxim†ln° dÇlka ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit2                     ; maska zad†vanòch znakñ
         db        0,'      '               ; dopl§uj°c° zak†zanÇ znaky

         db        0                        ; identifik†tor historie
         db        0                        ; poáet p©edvoleb

InfoRMnP db        bit6,9,0,'VAROVèNã'
         db        bit6,0
         db        bit6,31,'Redukc° koment†©ñ budou zru®eny'
         db        bit6,29,'v®echny koment†©e k poloëk†m,'
         db        bit6,27,'kterÇ v adres†©i neexistuj°'
         db        bit6,30,'nebo nejsou zobrazeny v oknà !'
         db        bit6,0
         db        bit6+bit7,0
         db        1,9,'Redukovat'
         db        1,6,'N†vrat'

HelpS    SEGMENT   BYTE PUBLIC
InfoRMnH db        52,'Proveden° redukce koment†©ñ k neexistuj°c°m poloëk†m'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

InfoRMnB db        0,0
InfoRMnT db        17,'redukce koment†©ñ'

; -----------------------------------------------------------------------------
;        Modifikace parametrñ souborñ
; -----------------------------------------------------------------------------
;˛
SMMnVert label     byte                   ;* menu modifikace souborñ

         db        2                        ; typ menu - vertik†ln° podmenu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka volby
         dw        5                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        SMMnVPol                 ; definián° tabulka poloëek
         dw        SMMnVHlp                 ; n†povàda
         dw        Hlp@MenuModifikaceSouboru ; á°slo str†nky velkÇ n†povàdy
         dw        SMMnVBlk                 ; blokovac° tabulka
         dw        0                        ; p©ep°naáe
         dw        SMMnVTit                 ; adresa titulu okna
         dw        SMMnVExe                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        36                       ; poá†teán° pozice
         db        10                       ; poá†teán° ©†dek
         db        20                       ; ®°©ka okna
         db        7                        ; vò®ka okna

SMMnVPol db        1,6,'Kurzor'
         db        1,8,'OznaáenÇ'
         db        1,7,'Soubory'
         db        1,7,'V®echny'
         db        1,6,'ZadanÇ'

SMMnVBlk db        0,0,0,0,0

SMMnVTit db        10,'modifikace'

HelpS    SEGMENT   BYTE PUBLIC
SMMnVHlp db        55,'Modifikace parametrñ souboru nebo adres†©e pod kurzorem'
         db        57,'Modifikace parametrñ oznaáenòch souborñ a adres†©ñ (F9)'
         db        50,'Modifikace parametrñ v®ech souborñ v aktivn°m oknà'
         db        77,'Modifikace parametrñ v®ech souborñ a adres†©ñ v aktivn°m oknà a podadres†©°ch'
         db        64,'Modifikace parametrñ souborñ a adres†©ñ podle blië®° specifikace'
HelpS    ENDS

SMMnVExe label     dword                    ; obsluhy voleb
         dd        ModiFil                  ; kurzor
         dd        ModiFil                  ; oznaáenÇ
         dd        ModiFil                  ; soubory
         dd        ModiFil                  ; v®echny
         dd        ModiFil                  ; zadanÇ

; -----------------------------------------------------------------------------
;       Volba souborñ k modifikaci parametrñ
; -----------------------------------------------------------------------------

SMZMLin  label     byte

         db        3                        ; typ menu - ©†dkovÇ podmenu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        SMZMLPol                 ; zaá†tek definice poloëek menu
         dw        SMZMLHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@VyberSouboru         ; á°slo str†nky velkÇ n†povàdy
         dw        SMZMLBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        SMZMLTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        45                       ; ®°©ka okna
         db        8                        ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        1                        ; celkovò poáet ©†dkñ
         dw        1                        ; poáet zobrazenòch ©†dkñ

         db        bit2                     ; maska zad†vanòch znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        HistSel                  ; identifik†tor historie
         db        1                        ; poáet p©edvoleb

         dw        3                        ; dÇlka p©edvolby
         dd        All                      ; p©edvolba

; ------ poloëky voleb

SMZMLPol db        bit6,31,'Soubory k modifikaci parametrñ:'
         db        0,0
         db        bit6+bit7,0
         db        1,6,'ProveÉ'
         db        1,6,'N†vrat'

SMZMLBlk db        0,0,0                    ; blokovac° tabulka

SMZMLTit db        6,'zadanÇ'

; ------ n†povàda

HelpS    SEGMENT   BYTE PUBLIC
SMZMLHlp db        3,1
         dw        MenuFndH
         db        48,'Modifikace parametrñ zadanòch souborñ a adres†©ñ'
         db        3,1
         dw        MenuHlP1
HelpS    ENDS

; -----------------------------------------------------------------------------
;        Zad†n° parametrñ souborñ
; -----------------------------------------------------------------------------

SMMMLin  label     byte

         db        3                        ; typ menu - ©†dkovÇ podmenu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        SMMMLPol                 ; zaá†tek definice poloëek menu
         dw        SMMMLHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@ModifikaceSouboru    ; á°slo str†nky velkÇ n†povàdy
         dw        SMMMLBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        SMMMLTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        45                       ; ®°©ka okna
         db        8                        ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        1                        ; celkovò poáet ©†dkñ
         dw        1                        ; poáet zobrazenòch ©†dkñ

         db        bit6                     ; maska zad†vanòch znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        HistAtri                 ; identifik†tor historie
         db        1                        ; poáet p©edvoleb

         dw        26                       ; dÇlka p©edvolby 1
         dd        SMMMLPr1                 ; p©edvolba 1
;         dw        1                        ; dÇlka p©edvolby 2
;         dd        SMMMLPr2                 ; p©edvolba 2

SMMMLPr1 db        'ashr D01.01.1980 T00:00:00' ; p©edvolba 1
;SMMMLPr2 db        '+'                      ; p©edvolba 2

; ------ poloëky voleb

SMMMLPol db        bit6,31,'Zadejte parametry k modifikaci:'
         db        0,0
         db        bit6+bit7,0
         db        1,6,'ProveÉ'
         db        1,6,'N†vrat'

SMMMLBlk db        0,0,0                    ; blokovac° tabulka

SMMMLTit db        10,'modifikace'

; ------ n†povàda

HelpS    SEGMENT   BYTE PUBLIC
SMMMLHlp db        89,'Parametry: atributy +/- zobrazit, ASHR nastavit, ashr nulovat; D datum, T áas'
         db        33,'Modifikace parametrñ podle zad†n°'
         db        3,1
         dw        MenuHlP1
HelpS    ENDS

; -----------------------------------------------------------------------------
;        chybovÇ hl†®en° - chyba modifikace
; -----------------------------------------------------------------------------

ChbErMod label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        2                        ; poáet platnòch poloëek menu
         dw        6                        ; celkovò poáet poloëek menu

         dw        ChbErMoP                 ; zaá†tek definice poloëek menu
         dw        ChbErMoH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@ModifikaceSouboru    ; á°slo str†nky velkÇ n†povàdy
         dw        ChbErMoB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        ChbErMoT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        56                       ; ®°©ka okna
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

ChbErMoT db        16,'chyba modifikace'

ChbErMoP db        bit6,6,0,'CHYBA'
         db        bit6,42,'Chyba modifikace parametrñ souboru ',0,1
         dw        SRMnuFil
         db        0,' !'
         db        bit6,0
         db        bit6+bit7,0
         db        1,5,'Dal®°'
         db        1,8,'P©eru®it'

ChbErMoB db        0,0                      ; blokovac° tabulka

HelpS    SEGMENT   BYTE PUBLIC
ChbErMoH db        48,'Pokraáov†n° modifikac° parametrñ dal®°ho souboru'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

; -----------------------------------------------------------------------------
;        data k modifikaci parametrñ souborñ (nemànit po©ad° poloëek a masek !)
; -----------------------------------------------------------------------------

ModiWPar db        0                        ; parametry
                                            ;   bit 0: 1=zad†n "+" nebo "-"
                                            ;   bit 1: 1=zap "+", 0=vyp "-"
                                            ;   bit 2: 1=zad†ny atributy ASHR
                                            ;   bit 3:
                                            ;   bit 4: 1=zad†no datum
                                            ;   bit 5: 1=aktu†ln° datum
                                            ;   bit 6: 1=zad†n áas
                                            ;   bit 7: 1=aktu†ln° áas

ModiAtr  db        0                        ; atributy k modifikaci poloëky
ModiAtrM db        -1                       ; maska atributñ k modifikaci

ModiTim  dw        0                        ; áas k modifikaci poloëky
ModiTimM dw        -1                       ; maska k modifikaci áasu poloëky

ModiDat  dw        0                        ; datum k modifikaci poloëky
ModiDatM dw        -1                       ; maska k modifikaci data poloëky

ModiTxt  db        12,'Modifikuji ',0

;ChybBuff db        1,32 dup(" ")            ; buffer chybovÇho textu

; -----------------------------------------------------------------------------
;        Start programu
; -----------------------------------------------------------------------------
;˛
SPMnVert label     byte                   ;* start programu

         db        2                        ; typ menu - vertik†ln° podmenu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka volby
         dw        7                        ; poáet platnòch poloëek menu
         dw        8                        ; celkovò poáet poloëek menu

         dw        SPMnVPol                 ; definián° tabulka poloëek
         dw        SPMnVHlp                 ; n†povàda
         dw        Hlp@MenuSpusteniprogramu ; á°slo str†nky velkÇ n†povàdy
         dw        SPMnVBlk                 ; blokovac° tabulka
         dw        SPMnVSwc                 ; p©ep°naáe
         dw        SPMnVTit                 ; adresa titulu okna
         dw        SPMnVExe                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        36                       ; poá†teán° pozice
         db        10                       ; poá†teán° ©†dek
         db        20                       ; ®°©ka okna
         db        10                       ; vò®ka okna

SPMnVPol db        bit7+1,7,'BAT m¢d'
         db        bit7+1,6,'Loader'
         db        bit7+1,10,'Rychlò m¢d'
         db        bit6+bit7,0
;         db        bit7+1,11,'COMMAND.COM'
;         db        bit7+1,10,'Dàlenò BAT'
;         db        bit7+1,14,'Uschovat vòbàr'
;         db        bit6+bit7,0
         db        1,6,'Kurzor'
         db        1,4,'Menu'
         db        1,8,'OznaáenÇ'
         db        1,6,'P©°kaz'
;         db        1,6,'ZadanÇ'

SPMnVSwc db        0,0,0

SPMnVBlk db        0,0,0,0,0,0,0

SPMnVTit db        7,'program'

HelpS    SEGMENT   BYTE PUBLIC
SPMnVHlp db        81,'M¢d s povelovòm souborem - v pamàti nic nezñst†v† (DOSMAN spu®tàn z DOSM.BAT)'
         db        78,'M¢d se zavadàáem - v pamàti zñst†v† 1.6 KB (+ rezidentn° á†st COMMAND.COM)'
         db        80,'Rychlò m¢d - v pamàti zñst†v† 310 KB (celò DOSMAN, nen° nutnÇ novÇ zav†dàn°)'
;         db        73,'Ke spu®tàn° programñ je pouëit COMMAND.COM (v pamàti nav°c zhruba 2.5 KB)'
;         db        62,'PovelovÇ soubory prov†dàny po ©†dc°ch (nen° nutnò COMMAND.COM)'
;         db        32,'óschova oznaáen° souborñ na disk'
         db        71,'Spu®tàn° programu pod kurzorem (ENTER; podle definice v DOSMAN.INI)'
         db        50,'Proveden° p©°kazu pomoc° uëivatelskÇho menu (F2)'
         db        81,'HromadnÇ proveden° p©°kazu s oznaáenòmi soubory (pro x.BAT uveÉte CALL x.BAT)'
         db        63,'Proveden° p©°kazu podle zad†n° (v p©°kazovÇm ©†dku; Shift-F2)'
;         db        50,'Operace provedena se soubory podle blië®°ho zad†n°'
HelpS    ENDS

SPMnVExe label     dword                    ; obsluhy voleb
         dd        Progr101                 ; BAT m¢d
         dd        Progr104                 ; Loader
         dd        Progr105                 ; Rychlò m¢d
;         dd        Progr106                 ; COMMAND.COM
;         dd        Progr107                 ; dàlenò BAT
;         dd        Progr108                 ; uschovat vòbàr
         dd        Progr2                   ; kurzor
         dd        Progr3                   ; menu
         dd        Progr4                   ; oznaáenÇ
         dd        Progr5                   ; p©°kaz
;         dd        0                        ; zadanÇ

; -----------------------------------------------------------------------------
;        Zad†n° p©°kazu
; -----------------------------------------------------------------------------

SPZMLin  label     byte

         db        3                        ; typ menu - ©†dkovÇ podmenu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        SPZMLPol                 ; zaá†tek definice poloëek menu
         dw        SPZMLHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@PrikazovyRadek       ; á°slo str†nky velkÇ n†povàdy
         dw        SPZMLBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        SPZMLTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        50                       ; ®°©ka okna
         db        8                        ; vò®ka okna

SPZMLinM dw        115                      ; maxim†ln° dÇlka ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        1                        ; celkovò poáet ©†dkñ
         dw        1                        ; poáet zobrazenòch ©†dkñ

         db        bit2                     ; maska zad†vanòch znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        HistComm                 ; identifik†tor historie
SPZMLPlL db        1                        ; poáet p©edvoleb

SPZMLPlN dw        0                        ; dÇlka p©edvolby
         dd        LineCBuf                 ; p©edvolba

; ------ poloëky voleb

SPZMLPol db        bit6,27,'Zadejte p©°kaz k proveden°:'
         db        0,0
         db        bit6+bit7,0
         db        1,6,'ProveÉ'
         db        1,6,'N†vrat'

SPZMLBlk db        0,0,0                    ; blokovac° tabulka

SPZMLTit db        6,'p©°kaz'

; ------ n†povàda

HelpS    SEGMENT   BYTE PUBLIC
SPZMLHlp db        26,'Zadejte p©°kaz k proveden°'
         db        26,'Proveden° zadanÇho p©°kazu'
         db        3,1
         dw        MenuHlP1
HelpS    ENDS

; ------ parametry

;ProgSwc  db        bit1+bit3+bit5           ; p©ep°naáe voleb
;                                            ;   bit 0: 1=BAT m¢d
;                                            ;   bit 1: 1=Loader
;                                            ;   bit 2: 1=rychlò m¢d (perm.)
;                                            ;   bit 3: 1=COMMAND.COM
;                                            ;   bit 4: 1=dàlenò BAT
;                                            ;   bit 5: 1=uschovat vòbàr

ProgSwc2 db        0                        ; parametry 2 pro program
                                            ;   bit 0: 1=je p©°kaz z EXTENSION/MENU


ProgTxt1 db        18,'Prov†d°m p©°kaz...'

Command  db        'C:\COMMAND.COM',0

ComSpc   db        7,'COMSPEC'

DosmBat  db        12,'$DOSMAN$.BAT'

Data     ENDS
         END

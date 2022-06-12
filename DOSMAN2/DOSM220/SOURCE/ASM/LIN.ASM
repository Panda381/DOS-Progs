

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                                L I N E
;
;                        obsluha p©¡kazov‚ho © dku
;
; =============================================================================
;
;        DispLCom (FAR) - zobrazen¡ p©¡kazov‚ho © dku (s kurzorem)
;        DispLKur (FAR) - zobrazen¡ kurzoru p©¡kazov‚ho © dku
;        InitLCom (FAR) - inicializace p©¡kazov‚ho © dku
;        EditLCom (FAR) - editace p©¡kazov‚ho © dku
;
;        LineCRad (BYTE) - © dek na obrazovce k zobrazen¡ p©¡kazov‚ho © dku
;        LineCVys (BYTE) - po‡et © dk– p©¡kazov‚ho © dku
;        LineCNum (BYTE) - po‡et znak– v p©¡kazov‚m © dku
;        LineCMax (BYTE) - maxim ln¡ d‚lka p©¡kazov‚ho © dku
;        LineCTop (BYTE) - zobrazen˜ po‡ tek p©¡kazov‚ho © dku
;        LineCKur (BYTE) - offset kurzoru v p©¡kazov‚m © dku
;        LineCBuf (BYTE) - buffer p©¡kazov‚ho © dku
;
;        AktPathN (WORD) - d‚lka cesty aktivn¡ho adres ©e
;        AktPath  (BYTE) - aktivn¡ adres ©
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

INCLUDE  ASM\DEF.ASM

CodeLin  SEGMENT   BYTE PUBLIC
         ASSUME    cs:CodeLin,ds:Data

LineCBfN EQU       250                      ; d‚lka bufferu p©¡kazov‚ho © dku

; *****************************************************************************
;                               MousLin
;                   obsluha p©¡kazov‚ho © dku my¨¡
;            Pozor - m–‘e zevnit© sk kat na obsluhu Shift-F2 !!!
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; VSTUP: CY=nen¡ obsluha
;         ZY=byla obsluha, ale nic se nedˆje
;         NZ=byla obsluha a je start p©¡kazu
; -----------------------------------------------------------------------------
; zni‡en‚ registry: AX, BX, CX, DX
; *****************************************************************************

MousLin  PROC      FAR

; ------ test, zda je stisk my¨i v p©¡kazov‚m © dku

         mov       dl,0                     ; po‡ te‡n¡ pozice
         mov       dh,ds:[LineCRad]         ; po‡ te‡n¡ © dek
         mov       cl,ds:[Pozic]            ; ¨¡©ka okna
         mov       ch,ds:[LineCVys]         ; v˜¨ka okna
         call      far ptr MouseTst         ; test stisku tla‡¡tka
         jnc       MousLin2                 ; je stisk tla‡¡tka my¨i
         jmp       MousLin9                 ; nen¡ stisk tla‡¡tka (-> je CY)

; ------ dvoj¡ stisk - proveden¡ p©¡kazu

MousLin2:cmp       al,MousXLD               ; lev‚ tla‡¡tko 2x ?
         je        MousLin8                 ; je lev‚ tla‡¡tko 2x

; ------ test, zda je nˆjak‚ tla‡¡tko

         test      al,MousXLH+MousXRH       ; je dr‘en¡ nˆjak‚ho tla‡¡tka ?
         jz        MousLin9                 ; nen¡ ‘ dn‚ tla‡¡tko (-> je ZY)

; ------ vyvol n¡ historie p©¡kaz– (pozor, sk ‡e na Shift-F2 !!!)

         mov       al,byte ptr ds:[MousePoz+1] ; © dek my¨i
         inc       ax                       ; 1 © dek rezerva
         cmp       al,ds:[LineCRad]         ; je smˆrem nahoru ?
         jae       MousLin3                 ; nen¡ vyvol n¡ historie
         add       sp,4                     ; zru¨en¡ n vratov‚ adresy
         jmp       far ptr Progr500         ; obsluha Shift-F2 (historie)

; ------ nastaven¡ kurzoru na pozici my¨i

MousLin3:cmp       byte ptr ds:[LineCNum],0 ; je nˆco v p©¡kaz. © dku ?
         je        MousLn74                 ; nen¡ nic v p©¡kaz. © dku
         mov       al,byte ptr ds:[MousePoz+1] ; © dek kurzoru my¨i
         mov       dh,ds:[LineCRad]         ; p©¡kazov˜ © dek
         cmp       al,dh                    ; je nad p©¡kazov˜m © dkem ?
         jae       MousLin4                 ; my¨ je OK
         mov       al,dh                    ; omezen¡ © dku s kurzorem
MousLin4:add       dh,ds:[LineCVys]         ; maxim ln¡ © dek
         cmp       al,dh                    ; je pod p©¡kazov˜m © dkem ?
         jb        MousLin5                 ; my¨ je OK
         mov       al,dh                    ; omezen¡ © dku s kurzorem
         dec       ax                       ; oprava na maxim ln¡ © dek
MousLin5:sub       al,ds:[LineCRad]         ; © dek relativnˆ
         mul       byte ptr ds:[Pozic]      ; p©epo‡et na pozici
         add       al,byte ptr ds:[MousePoz] ; p©i‡ten¡ pozice my¨i
         adc       ah,0
         sub       al,ds:[LineCPth]         ; ode‡ten¡ d‚lky cesty
         jnc       MousLin6                 ; nen¡ podte‡en¡
         mov       al,0                     ; omezen¡ p©i podte‡en¡
MousLin6:add       al,ds:[LineCTop]         ; p©i‡ten¡ po‡ tku
         adc       ah,0
         jnz       MousLin7                 ; je p©ete‡en¡
         cmp       al,ds:[LineCMax]         ; je p©ete‡en¡ konce ?
         jbe       MousLn72                 ; nen¡ p©ete‡en¡ konce
MousLin7:mov       al,ds:[LineCMax]         ; omezen¡ p©i p©ete‡en¡ kurzoru
MousLn72:cmp       al,ds:[LineCKur]         ; zmˆnila se pozice kurzoru ?
         je        MousLn74                 ; pozice se nezmˆnila
         mov       ds:[LineCKur],al         ; nov  pozice kurzoru
         call      far ptr DispLCom         ; nov‚ zobrazen¡ p©¡kaz. © dku
MousLn74:call      far ptr DispTime         ; obsluha hodin
         call      far ptr MouseInt         ; obsluha my¨i
         mov       al,ds:[MouseKey]         ; aktu ln¡ stav tla‡¡tek my¨i
         jmp       short MousLin2           ; nov  obsluha my¨i

; ------ test, zda je nˆco v © dku k proveden¡ (je 2x stisk lev‚ho tla‡¡tka)

MousLin8:cmp       byte ptr ds:[LineCNum],0 ; je nˆco v © dku ?
MousLin9:ret

MousLin  ENDP

; *****************************************************************************
;                            DispLCom
;                    zobrazen¡ p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; lok ln¡ promˆnn‚: SS:[BP-1] (1) ukazatel © dku na displeji
;                   SS:[BP-2] (1) ‡¡ta‡ © dk– k zobrazen¡
;                   SS:[BP-3] (1) ‡¡ta‡ zbyl˜ch znak– promptu
;                   SS:[BP-4] (1) ‡¡ta‡ zbyl˜ch znak– p©¡kazov‚ho © dku
;                   SS:[BP-6] (2) ukazatel adresy textu
; *****************************************************************************
;þ
DispLCom PROC      FAR

         test      byte ptr ds:[WindPar],bit6 ; je re‘im editoru ?
         jz        DispLCm0                 ; nen¡ re‘im editoru
         ret                                ; jinak konec

; ------ £schova registr–

DispLCm0:call      KorLCom                  ; korekce ukazatel– p©¡kaz. © dku
         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp

; ------ p©¡prava po‡tu © dk– k zobrazen¡ (zkr cen¡ p©i zobrazen¡ n povˆdy)

         mov       al,ds:[LineCVys]         ; v˜¨ka © dku
         cmp       al,0                     ; je povoleno zobrazen¡ ?
         je        DispLC14                 ; nen¡ povoleno zobrazen¡ © dku
         test      byte ptr ds:[HelpPar],bit0 ; je mal  n povˆda ?
         jnz       DispLCm2                 ; je mal  n povˆda - nesni‘uje se
         call      far ptr InfoAkt          ; je informa‡n¡ © dek ?
         jnc       DispLCm1                 ; je informa‡n¡ © dek
         test      byte ptr ds:[ParMenu],bit2 ; je nˆjak‚ menu ?
         jnz       DispLCm1                 ; je nˆjak‚ menu
         test      byte ptr ds:[WindPar],bit2 ; je re‘im zmˆny v˜¨ky okna ?
         jz        DispLCm2                 ; nen¡ ani re‘im zmˆny oken
DispLCm1:dec       al                       ; sn¡‘en¡ v˜¨ky © dku, je-li menu
         jnz       DispLCm2                 ; zbyl je¨tˆ nˆjak˜ © dek
DispLC14:jmp       DispLCmA                 ; nen¡ co zobrazit

; ------ p©¡prava lok ln¡ch promˆnn˜ch (AL=‡¡ta‡ © dk–)

DispLCm2:sub       sp,6                     ; m¡sto pro lok ln¡ promˆnn‚
         sub       sp,ds:[ByteRow]          ; buffer pro © dek textu
         mov       ah,ds:[LineCRad]         ; © dek k zobrazen¡
         mov       ss:[bp-2],ax             ; ‡¡ta‡ © dk– a ukazatel © dku
         mov       ah,ds:[LineCPth]         ; d‚lka cesty
         mov       al,ds:[LineCNum]         ; po‡et znak– p©¡kaz. © dku
         sub       al,ds:[LineCTop]         ; po‡et zbyl˜ch znak–
         jnc       DispLC23                 ; jsou nˆjak‚ znaky
         mov       al,0                     ; nezbyl ‘ dn˜ znak
DispLC23:mov       ss:[bp-4],ax             ; ‡¡ta‡ zbyl˜ch znak–
         mov       word ptr ss:[bp-6],offset AktPath ; ukazatel adresy cesty
         push      ss
         pop       es                       ; ES <- adresa bufferu

; ------ inicializa‡n¡ vymaz n¡ bufferu

DispLCm3:mov       di,sp                    ; za‡ tek bufferu
         push      di
         mov       ch,0
         mov       cl,ds:[Pozic]            ; po‡et pozic na © dek
         mov       al," "                   ; mazac¡ mezera
         mov       ah,ds:[LineCCol]         ; barva textu
         cld
         rep       stosw                    ; vymaz n¡ © dku
         pop       di

; ------ d‚lka textu cesty (CH=0 !)

         mov       si,ss:[bp-6]             ; ukazatel adresy textu
         mov       al,ss:[bp-3]             ; zbyl‚ znaky promptu
         mov       dl,ds:[Pozic]            ; po‡et pozic na © dek
         cmp       al,dl                    ; je text del¨¡ ?
         jbe       DispLCm4                 ; text je OK
         mov       al,dl                    ; omezen¡ d‚lky textu
DispLCm4:sub       ss:[bp-3],al             ; sn¡‘en¡ ‡¡ta‡e zbyl‚ d‚lky
         sub       dl,al                    ; zbyl  d‚lka © dku
         mov       cl,al                    ; po‡et znak– k dek¢dov n¡
         jcxz      DispLCm6                 ; nezbyl ji‘ text promptu

; ------ dek¢dov n¡ cesty (CLD !)

         mov       ah,ds:[LinePCol]         ; barva textu cesty
DispLCm5:lodsb                              ; znak k dek¢dov n¡
         stosw
         loop      DispLCm5                 ; dek¢dov n¡ dal¨¡ho znaku
         mov       ss:[bp-6],si             ; nov˜ ukazatel textu
         cmp       byte ptr ss:[bp-3],0     ; je ji‘ konec cesty ?
         jne       DispLCm6                 ; nen¡ je¨tˆ konec cesty
         mov       byte ptr es:[di-2],">"   ; ozna‡en¡ konce promptu
         mov       ah,0
         mov       al,ds:[LineCTop]         ; po‡ tek textu
         add       ax,offset LineCBuf       ; adresa p©¡kazov‚ho © dku
         mov       ss:[bp-6],ax             ; buffer p©¡kazov‚ho © dku

; ------ d‚lka textu p©¡kazov‚ho © dku

DispLCm6:mov       si,ss:[bp-6]             ; ukazatel textu
         mov       al,ss:[bp-4]             ; zbyl‚ znaky textu
         cmp       al,dl                    ; je text del¨¡ ?
         jbe       DispLCm7                 ; text je OK
         mov       al,dl                    ; omezen¡ d‚lky textu
DispLCm7:mov       dl,ss:[bp-4]             ; p–vodn¡ d‚lka textu
         sub       ss:[bp-4],al             ; sn¡‘en¡ ‡¡ta‡e zbyl‚ d‚lky textu
         mov       cl,al                    ; d‚lka textu k dek¢dov n¡
         jcxz      DispLCm9                 ; nezbyl dal¨¡ text

; ------ dek¢dov n¡ textu p©¡kazov‚ho © dku

         mov       ah,ds:[LineCCol]         ; barva textu
         push      di
DispLCm8:lodsb
         stosw
         loop      DispLCm8                 ; dek¢dov n¡ dal¨¡ho znaku
         mov       ss:[bp-6],si             ; nov˜ ukazatel textu
         pop       si                       ; za‡ tek ukl dac¡ adresy

; ------ znak p©ete‡en¡ za‡ tku © dku

         mov       ah,ds:[LineOCol]         ; barva znaku p©ete‡en¡
         mov       al,ds:[LineCTop]         ; za‡ tek textu
         cmp       al,0                     ; je za‡ tek textu ?
         je        DispLC82                 ; je za‡ tek © dku
         add       al,dl                    ; fiktivn¡ d‚lka textu
         cmp       al,ds:[LineCNum]         ; je to prvn¡ © dek textu ?
         jne       DispLC82                 ; nen¡ to prvn¡ © dek textu
         mov       al,"®"                   ; znak p©ete‡en¡
         mov       es:[si],ax               ; ulo‘en¡ znaku p©ete‡en¡

; ------ znak p©ete‡en¡ konce © dku

DispLC82:cmp       byte ptr ss:[bp-2],1     ; je posledn¡ © dek ?
         jne       DispLCm9                 ; nen¡ posledn¡ © dek
         cmp       byte ptr ss:[bp-4],0     ; zbyly je¨tˆ nˆjak‚ znaky ?
         je        DispLCm9                 ; nezbyly ‘ dn‚ znaky
         mov       al,"¯"                   ; znak p©ete‡en¡
         mov       es:[di-2],ax             ; znak p©ete‡en¡ konce

; ------ zobrazen¡ © dku

DispLCm9:mov       dl,0                     ; po‡ te‡n¡ pozice
         mov       dh,ss:[bp-1]             ; ukazatel © dku na displeji
         mov       cl,ds:[Pozic]            ; d‚lka © dku
         mov       si,sp                    ; adresa bufferu
         xor       ax,ax                    ; hladina k zobrazen¡
         call      far ptr DispMStr         ; zobrazen¡ © dku

; ------ p©¡prava pro dal¨¡ © dek

         inc       byte ptr ss:[bp-1]       ; zv˜¨en¡ ukazatele © dku
         dec       byte ptr ss:[bp-2]       ; ‡¡ta‡ © dk– k zobrazen¡
         jz        DispLCmA                 ; jsou ji‘ v¨echny © dky
         jmp       DispLCm3                 ; dek¢dov n¡ dal¨¡ho © dku

; ------ n vrat registr–

DispLCmA:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax

         call      far ptr DispLKur         ; zobrazen¡ kurzoru
         ret

DispLCom ENDP

; -----------------------------------------------------------------------------
;                                 KorLCom
;                  oprava ukazatel– p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; -----------------------------------------------------------------------------

KorLCom  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx

; ------ celkov  d‚lka © dku

         mov       al,ds:[Pozic]            ; po‡et pozic na © dek
         mul       byte ptr ds:[LineCVys]   ; celkov  d‚lka © dku
         sub       ax,5+1                   ; rezerva
         jc        KorLCom9                 ; nen¡ nic zobrazeno

; ------ d‚lka aktivn¡ cesty

         mov       bx,2                     ; d‚lka promptu bez cesty "C:"
         test      byte ptr ds:[LineCPar],bit0 ; je cesta ?
         jnz       KorLCom1                 ; nen¡ cesta
         mov       bx,ds:[AktPathN]         ; d‚lka aktivn¡ cesty
         cmp       bx,ax                    ; je d‚lka cesty OK ?
         jb        KorLCom1                 ; d‚lka cesty je OK
         mov       bx,ax                    ; omezen¡ d‚lky cesty
KorLCom1:inc       bx                       ; zv˜¨en¡ d‚lky o znak ">"
         mov       ds:[LineCPth],bl         ; d‚lka cesty
         add       ax,5+1                   ; n vrat d‚lky © dku

; ------ d‚lka zobraziteln‚ho textu © dku

         sub       ax,bx                    ; zbytek na © dek textu
         mov       ch,0                     ; CH <- 0
         mov       cl,ds:[LineCMax]         ; maxim ln¡ d‚lka © dku
         inc       cx                       ; rezerva pro kurzor
         cmp       ax,cx                    ; zb˜v  dost m¡sta ?
         jb        KorLCom2                 ; je dost m¡sta
         xchg      ax,cx                    ; AX <- omezen¡ d‚lky © dku
KorLCom2:mov       ds:[LineCDel],al         ; zobrazen  d‚lka © dku

; ------ rezerva po stran ch -> CL

         mov       cl,5                     ; rezerva na okraj¡ch 5 pozic
         cmp       al,10                    ; zobraz¡ se m‚nˆ ne‘ 10 znak– ?
         jae       KorLCom3                 ; zobraz¡ se dost znak–
         mov       cl,al                    ; po‡et zobrazen˜ch znak–
         shr       cl,1                     ; rezerva na okraj¡ch

; ------ ostatn¡ parametry

KorLCom3:xchg      ax,bx                    ; BL <- zobrazen  d‚lka © dku
         mov       bh,ds:[LineCNum]         ; BH <- po‡et znak– v bufferu
         mov       al,ds:[LineCKur]         ; AL <- pozice kurzoru
         cmp       al,bh                    ; je kurzor za koncem ?
         jb        KorLCm32                 ; kurzor nen¡ za koncem
         mov       bh,al                    ; korekce po‡tu znak– na kurzor
         inc       bh                       ; 1 pozice pro kurzor
KorLCm32:mov       ah,ds:[LineCTop]         ; AH <- po‡ tek © dku

; ------ stanoven¡ maxim ln¡ho za‡ tku © dku

         sub       bh,bl                    ; zobraz¡ se cel˜ © dek ?
         jbe       KorLCom5                 ; © dek se zobraz¡ cel˜

; ------ ohrani‡en¡ z lev‚ strany

         sub       al,cl                    ; rezerva na lev‚m okraji
         jbe       KorLCom5                 ; zobraz¡ se za‡ tek © dku
         cmp       al,ah                    ; je p©ed za‡ tkem © dku ?
         jb        KorLCom6                 ; je p©ed lev˜m okrajem
         add       al,cl                    ; n vrat pozice

; ------ ohrani‡en¡ z prav‚ strany

         add       al,cl                    ; rezerva na prav‚m okraji
         sub       al,bl                    ; korekce pro prav˜ okraj
         jbe       KorLCom4                 ; nen¡ je¨tˆ za prav˜m okrajem
         cmp       al,ah                    ; je za prav˜m okrajem ?
         jae       KorLCom6                 ; je za prav˜m okrajem
KorLCom4:mov       al,ah                    ; omezen¡ na maxim ln¡ po‡ tek
         jmp       short KorLCom6           ; je konec © dku

; ------ zobraz¡ se za‡ tek © dku

KorLCom5:mov       al,0                     ; bude za‡ tek © dku
         mov       bh,0                     ; maxim ln¡ za‡ tek textu

; ------ kontrola maxim ln¡ho za‡ tku

KorLCom6:cmp       al,bh                    ; p©ekro‡en maxim ln¡ za‡ tek ?
         jbe       KorLCom8                 ; nen¡ p©ekro‡en maxim ln¡ za‡ tek
         mov       al,bh                    ; omezen¡ na maxim ln¡ za‡ tek

; ------ nov˜ po‡ tek p©¡kazov‚ho © dku

KorLCom8:mov       ds:[LineCTop],al         ; nov˜ za‡ tek © dku

; ------ n vrat registr–

KorLCom9:pop       cx
         pop       bx
         pop       ax
         ret

KorLCom  ENDP

; *****************************************************************************
;                                  DispLKur
;           zobrazen¡ kurzoru p©¡kazov‚ho © dku (a‘ po korekci © dku !)
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; *****************************************************************************

DispLKur PROC      FAR

; ------ test, zda je zobrazen¡ kurzoru povoleno

         test      byte ptr ds:[ParMenu],bit2 ; je nˆjak‚ menu ?
         jnz       DispLKr1                 ; je nˆjak‚ menu
         call      far ptr InfoAkt          ; je informa‡n¡ © dek ?
         jnc       DispLKr1                 ; je informa‡n¡ © dek
         test      byte ptr ds:[WindPar],bit2+bit3+bit6 ; editor/qsrc/zmˆna
         jz        DispLKr2                 ; nen¡ editor/qsrc/zmˆna
DispLKr1:ret                                ; jinak konec

; ------ £schova registr–

DispLKr2:push      ax
         push      dx

; ------ nen¡-li ‘ dn˜ © dek, vypnut¡ kurzoru

         cmp       byte ptr ds:[LineCVys],0 ; je nˆjak˜ © dek ?
         jne       DispLKr3                 ; je nˆjak˜ © dek
         call      far ptr KurzOff          ; vypnut¡ kurzoru
         jmp       short DispLKr9

; ------ pozice na © dku relativnˆ

DispLKr3:mov       ah,0                     ; AH <- 0
         mov       al,ds:[LineCKur]         ; offset kurzoru
         sub       al,ds:[LineCTop]         ; offset po‡ tku © dku
         add       al,ds:[LineCPth]         ; p©i‡ten¡ cesty
         adc       ah,0

; ------ zobrazen¡ kurzoru

         div       byte ptr ds:[Pozic]      ; v˜po‡et © dku a pozice relativnˆ
         mov       dh,al                    ; © dek relativnˆ
         mov       dl,ah                    ; pozice
         add       dh,ds:[LineCRad]         ; p©i‡ten¡ © dku k zobrazen¡
         call      far ptr SetKurz          ; nastaven¡ pozice kurzoru
         call      far ptr SizeLKur         ; nastaven¡ n¡zk‚ho kurzoru

; ------ n vrat registr–

DispLKr9:pop       dx
         pop       ax
         ret

DispLKur ENDP

; *****************************************************************************
;                             InitLCom
;                  inicializace p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; *****************************************************************************

InitLCom PROC      FAR

         push      ax
         mov       byte ptr ds:[LineCNum],0 ; zru¨en¡ znak– v p©¡kaz. © dku
         mov       byte ptr ds:[LineCTop],0 ; offset za‡ tku © dku
         mov       byte ptr ds:[LineCKur],0 ; kurzor na za‡ tku © dku

         mov       al,127 - 2 - 3 - 2       ; d‚lka - CR/LF - "/C " - rezerva
         cmp       word ptr ds:[EnvSize],0  ; je velikost prost©ed¡ ?
         je        InitLCm2                 ; nen¡ velikost prost©ed¡
         sub       al,9                     ; m¡sto pro "/E:32767 "
InitLCm2:mov       ds:[LineCMax],al         ; maxim ln¡ d‚lka p©¡kaz. © dku
         mov       byte ptr ds:[SPZMLinM],al ; maxim ln¡ d‚lka p©¡kaz. © dku
         pop       ax
         ret

InitLCom ENDP

; *****************************************************************************
;                              EditLCom
;                    editace p©¡kazov‚ho © dku
;     - u nˆkter˜ch kl ves se rozli¨uje, zda je p©¡kazov˜ © dek pr zdn˜
; -----------------------------------------------------------------------------
; VSTUP: BX=kl vesa k editaci
;        DS=datov˜ segment
; VSTUP:BX=0 - kl vesa byla obslou‘ena
; *****************************************************************************
;þ
EditLCom PROC      FAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ p©¡prava registr–

         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       al,ds:[LineCKur]         ; kurzor
         mov       ah,0
         mov       si,offset LineCBuf       ; buffer
         add       si,ax                    ; adresa platn‚ho znaku

; ------ kontrola, zda je editace © dku povolena

         cmp       byte ptr ds:[LineCVys],0 ; je nˆjak˜ © dek ?
         jne       EditLCm1                 ; je nˆco v p©¡kazov‚m © dku
         jmp       EditLCm9                 ; nen¡ p©¡kazov˜ © dek

; ------ rozli¨en¡ platn‚ho znaku

EditLCm1:or        bx,bx                    ; je Ctrl-Break ?
         jz        EditLCm4                 ; je Ctrl-Break nebo neplatn  kl v.
         cmp       bh,MousXKod/HI           ; je k¢d my¨i ?
         je        EditLCm4                 ; my¨
         cmp       bx,0300h                 ; je Ctrl-@ ?
         je        EditLCm3                 ; je Ctrl-@
         or        bh,bh                    ; je platn˜ znak Alt-‡¡slo ?
         jz        EditLCm3                 ; je platn˜ znak Alt-‡¡slo
         cmp       bl," "                   ; je platn˜ znak ?
         jb        EditLCm4                 ; je ©¡dic¡ kl vesa
         cmp       bx,0e7fh                 ; ^BS
         je        EditLCm4                 ; je ^BS

; ------ je platn˜ znak - kontrola, zda je voln‚ m¡sto v bufferu

EditLCm3:mov       al,ds:[LineCNum]         ; po‡et znak– v p©¡kazov‚m © dku
         cmp       al,ds:[LineCMax]         ; je © dek pln˜ ?
         jae       EditLC38                 ; © dek je ji‘ pln˜

; ------ kontrola, zda je kurzor za koncem bufferu

         mov       al,ds:[LineCKur]         ; kurzor
         cmp       al,ds:[LineCMax]         ; je kurzor za koncem ?
         jae       EditLC38                 ; kurzor je za koncem

; ------ doplnˆn¡ mezer po kurzor

         sub       al,ds:[LineCNum]         ; po‡et chybˆj¡c¡ch znak–
         jbe       EditLC34                 ; nen¡ za koncem textu
         mov       ah,0
         mov       cx,ax                    ; CX <- po‡et mezer k doplnˆn¡
         mov       di,offset LineCBuf       ; buffer
         mov       al,ds:[LineCNum]         ; po‡et znak– v bufferu
         add       di,ax                    ; adresa konce textu
         mov       al," "                   ; mazac¡ znak mezery
         cld
         add       ds:[LineCNum],cl         ; zv˜¨en¡ po‡tu znak– v bufferu
         rep       stosb                    ; doplnˆn¡ mezer

; ------ vlo‘en¡ znaku do bufferu

EditLC34:mov       cx,LineCBfN-1            ; velikost bufferu - 1
         sub       cl,ds:[LineCKur]         ; zbyl˜ po‡et znak– v bufferu
         mov       di,offset LineCBuf+LineCBfN-1 ; posledn¡ znak bufferu
         mov       si,offset LineCBuf+LineCBfN-2 ; p©edposledn¡ znak bufferu
         std                                ; smˆr dol–
         rep       movsb                    ; odsunut¡ zbytku textu
         mov       byte ptr ds:[di],bl      ; ulo‘en¡ znaku do bufferu
         inc       byte ptr ds:[LineCNum]   ; zv˜¨en¡ po‡tu znak– v bufferu
         inc       byte ptr ds:[LineCKur]   ; zv˜¨en¡ pozice kurzoru
EditLC38:jmp       short EditLCm8

; ------ kontrola, zda je p©¡kazov˜ © dek pr zdn˜

EditLCm4:cmp       byte ptr ds:[LineCNum],0 ; je nˆco v p©¡kazov‚m © dku ?
         je        EditLCm9                 ; p©¡kazov˜ © dek je pr zdn˜

; ------ obsluha ©¡dic¡ch kl ves (AL=kurzor, SI=adresa v bufferu)

         mov       ah,ds:[LineCNum]         ; po‡et znak– v bufferu
         mov       ch,ds:[LineCMax]         ; maxim ln¡ d‚lka © dku
         call      EditLCm5                 ; skok na obsluhu kl vesy
         mov       ds:[LineCKur],al         ; nov  pozice kurzoru
         jmp       short EditLCm8           ; nov‚ zobrazen¡ © dku

EditLCm5:call      far ptr JumpBX

         dw        4b00h,EdLLft             ; vlevo - posun kurzoru vlevo
         dw        1f13h,EdLLft             ; ^S - vlevo
         dw        4d00h,EdLRgh             ; vpravo - posun kurzoru vpravo
         dw        2004h,EdLRgh             ; ^D - vpravo
         dw        0e08h,EdLBs              ; BS - maz n¡ znaku vlevo
         dw        2308h,EdLBs              ; ^H - maz n¡ znaku vlevo
         dw        5300h,EdLDel             ; DEL - maz n¡ znaku za kurzorem
         dw        2207h,EdLDel             ; ^G - maz n¡ znaku za kurzorem
         dw        4700h,EdLHome            ; HOME - kurzor na za‡ tek © dku
         dw        4f00h,EdLEnd             ; END - kurzor na konec © dku
         dw        011bh,EdLClr             ; ESC - zru¨en¡ © dku
         dw        1519h,EdLClr             ; ^Y - zru¨en¡ © dku
         dw        7300h,EdLCLf             ; ^vlevo - slovo vlevo
         dw        1e01h,EdLCLf             ; ^A - slovo vlevo
         dw        7400h,EdLCRg             ; ^vpravo - slovo vpravo
         dw        2106h,EdLCRg             ; ^F - slovo vpravo
         dw        0e7fh,EdLCBS             ; ^BS - vymaz n¡ slova p©ed kurzorem
         dw        9300h,EdLCDel            ; ^DEL - vymaz n¡ slova za kurzorem
         dw        1414h,EdLCDel            ; ^T - vymaz n¡ slova za kurzorem
         dw        0c1fh,EdLCPom            ; ^- - z mˆna 2 znak–

         dw        0,EditLCm6               ; kl vesa nenalezena

EditLCm6:pop       ax                       ; zru¨en¡ n vratov‚ adresy
         jmp       short EditLCm9

; ------ nov‚ zobrazen¡ po obsluze kl vesy

EditLCm8:xor       bx,bx                    ; p©¡znak obsluhy kl vesy
         call      far ptr DispLCom         ; nov‚ zobrazen¡ © dku

; ------ n vrat registr–

EditLCm9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

EditLCom ENDP

; -----------------------------------------------------------------------------
;        posun kurzoru o znak vlevo
; -----------------------------------------------------------------------------

EdLLft   PROC      NEAR

         cmp       al,0                     ; je ji‘ za‡ tek © dku ?
         je        EdLLft9                  ; je ji‘ za‡ tek © dku
         dec       ax                       ; sn¡‘en¡ pozice kurzoru
EdLLft9: ret

EdLLft   ENDP

; -----------------------------------------------------------------------------
;        posun kurzoru o znak vpravo
; -----------------------------------------------------------------------------

EdLRgh   PROC      NEAR

         cmp       al,ch                    ; je ji‘ konec © dku ?
         jae       EdLRgh9                  ; je ji‘ konec © dku
         inc       ax                       ; zv˜¨en¡ pozice kurzoru
EdLRgh9: ret

EdLRgh   ENDP

; -----------------------------------------------------------------------------
;        maz n¡ znaku p©ed kurzorem
; -----------------------------------------------------------------------------

EdLBs    PROC      NEAR

         cmp       al,0                     ; je ji‘ za‡ tek © dku ?
         je        EdLDel9                  ; je ji‘ za‡ tek © dku
         dec       ax                       ; sn¡‘en¡ pozice kurzoru
         dec       si                       ; sn¡‘en¡ adresy kurzoru
                                          ;* pokra‡uje maz n¡ znaku nad kurz. !
EdLBs    ENDP

; -----------------------------------------------------------------------------
;        maz n¡ znaku za kurzorem (mus¡ n sledovat za EdLBs !)
; -----------------------------------------------------------------------------

EdLDel   PROC      NEAR

         cmp       al,ah                    ; je kurzor na konci © dku ?
         jae       EdLDel9                  ; kurzor na konci - nen¡ co mazat
         call      DelChar                  ; zru¨en¡ znaku na pozici AL
EdLDel9: ret

EdLDel   ENDP

; -----------------------------------------------------------------------------
;        posun kurzoru na za‡ tek © dku
; -----------------------------------------------------------------------------

EdLHome  PROC      NEAR

         mov       al,0                     ; posun kurzoru na za‡ tek © dku
         ret

EdLHome  ENDP

; -----------------------------------------------------------------------------
;        posun kurzoru na konec © dku
; -----------------------------------------------------------------------------

EdLEnd   PROC      NEAR

         mov       al,ah                    ; po‡et znak– v bufferu
         ret

EdLEnd   ENDP

; -----------------------------------------------------------------------------
;        vymaz n¡ © dku
; -----------------------------------------------------------------------------

EdLClr   PROC      NEAR

         call      far ptr InitLCom         ; inicializace p©¡kaz. © dku
         xor       ax,ax                    ; AL <- 0 nov  pozice kurzoru
         ret

EdLClr   ENDP

; -----------------------------------------------------------------------------
;        slovo vlevo
; -----------------------------------------------------------------------------

EdLCLf   PROC      NEAR

; ------ sn¡‘en¡ pozice kurzoru o znak vlevo

         cmp       al,0                     ; je ji‘ po‡ tek © dku ?
         je        EdLCLf9                  ; je ji‘ po‡ tek © dku
         cmp       al,ah                    ; je za koncem textu ?
         ja        EdLEnd                   ; je za koncem textu
EdLCLf2: dec       si                       ; sn¡‘en¡ adresy v bufferu
         dec       al                       ; sn¡‘en¡ pozice kurzoru
         jz        EdLCLf9                  ; je ji‘ za‡ tek © dku

; ------ test, zda je ji‘ za‡ tek slova

         push      ax
         mov       ax,ds:[si-1]             ; p©edch zej¡c¡ znak a kurzor
         call      far ptr TestWrd          ; test, zda je za‡ tek slova
         pop       ax
         jc        EdLCLf2                  ; nen¡ za‡ tek slova - dal¨¡ znak

EdLCLf9: ret

EdLCLf   ENDP

; -----------------------------------------------------------------------------
;        slovo vpravo
; -----------------------------------------------------------------------------

EdLCRg   PROC      NEAR

; ------ zv˜¨en¡ pozice kurzoru o znak vpravo

         cmp       al,ah                    ; je ji‘ konec textu ?
         jae       EdLEnd                   ; je ji‘ konec textu
EdLCRg2: inc       si                       ; sn¡‘en¡ adresy v bufferu
         inc       ax                       ; zv˜¨en¡ pozice kurzoru
         cmp       al,ah                    ; je ji‘ konec textu ?
         jae       EdLCRg9                  ; je ji‘ konec textu

; ------ test, zda je ji‘ za‡ tek slova

         push      ax
         mov       ax,ds:[si-1]             ; p©edch zej¡c¡ znak a kurzor
         call      far ptr TestWrd          ; test, zda je za‡ tek slova
         pop       ax
         jc        EdLCRg2                  ; nen¡ za‡ tek slova - dal¨¡ znak

EdLCRg9: ret

EdLCRg   ENDP

; -----------------------------------------------------------------------------
;        vymaz n¡ slova p©ed kurzorem
; -----------------------------------------------------------------------------

EdLCBS   PROC      NEAR

; ------ vymaz n¡ p©ede¨l‚ho znaku

EdLCBS1: cmp       al,0                     ; je ji‘ po‡ tek © dku ?
         je        EdLCBS9                  ; je ji‘ po‡ tek © dku
EdLCBS2: dec       si                       ; sn¡‘en¡ adresy v bufferu
         dec       ax                       ; sn¡‘en¡ pozice kurzoru
         cmp       al,ah                    ; je za koncem textu ?
         jae       EdLCBS1                  ; je za koncem textu
         mov       cl,ds:[si]               ; £schova ru¨en‚ho znaku
         call      DelChar                  ; zru¨en¡ znaku na pozici kurzoru
         dec       ah                       ; sn¡‘en¡ d‚lky textu
         cmp       al,0                     ; je ji‘ po‡ tek © dku ?
         je        EdLCBS9                  ; je ji‘ po‡ tek © dku

; ------ test, zda je ji‘ za‡ tek slova

         push      ax
         mov       al,ds:[si-1]             ; p©edch zej¡c¡ znak
         mov       ah,cl                    ; znak na pozici kurzoru
         call      far ptr TestWrd          ; test, zda je za‡ tek slova
         pop       ax
         jc        EdLCBS2                  ; nen¡ za‡ tek slova - dal¨¡ znak

EdLCBS9: ret

EdLCBS   ENDP

; -----------------------------------------------------------------------------
;        vymaz n¡ slova za kurzorem
; -----------------------------------------------------------------------------

EdLCDel   PROC      NEAR

; ------ vymaz n¡ n sleduj¡c¡ho znaku

         cmp       al,ah                    ; je ji‘ konec © dku ?
         jae       EdLCDel9                 ; je ji‘ konec © dku
EdLCDel2:mov       cl,ds:[si]               ; £schova ru¨en‚ho znaku
         call      DelChar                  ; zru¨en¡ znaku na pozici kurzoru
         dec       ah                       ; sn¡‘en¡ d‚lky textu
         cmp       al,ah                    ; je ji‘ konec textu ?
         jae       EdLCDel9                 ; je ji‘ konec textu

; ------ test, zda je ji‘ za‡ tek slova

         push      ax
         mov       al,cl                    ; ru¨en˜ znak
         mov       ah,ds:[si]               ; n sleduj¡c¡ znak
         call      far ptr TestWrd          ; test, zda je za‡ tek slova
         pop       ax
         jc        EdLCDel2                 ; nen¡ za‡ tek slova - dal¨¡ znak

EdLCDel9:ret

EdLCDel   ENDP

; -----------------------------------------------------------------------------
;        z mˆna dvou znak– za kurzorem
; -----------------------------------------------------------------------------

EdLCPom  PROC      NEAR

         cmp       ah,0                     ; je nˆjak˜ text ?
         je        EdLCPom9                 ; nen¡ ‘ dn˜ text
         dec       ah                       ; 1 znak rezerva
         cmp       al,ah                    ; zb˜vaj¡ 2 znaky ?
         ja        EdLCPom9                 ; kurzor je za koncem © dku
         jb        EdLCPom4                 ; nen¡ posledn¡ znak

; ------ kurzor na posledn¡m znaku - vlo‘en¡ mezery

         cmp       al,ch                    ; je maxim ln¡ konec ?
         jae       EdLCPom9                 ; je ji‘ maxim ln¡ konec
         mov       byte ptr ds:[si+1]," "   ; dal¨¡ znak bude mezera
         inc       byte ptr ds:[LineCNum]   ; zv˜¨en¡ po‡tu znak– v bufferu

; ------ z mˆna 2 znak–

EdLCPom4:mov       ah,ds:[si]
         xchg      ah,ds:[si+1]
         mov       ds:[si],ah

EdLCPom9:ret

EdLCPom  ENDP

; -----------------------------------------------------------------------------
;        maz n¡ znaku na pozici AL, adresa SI
; -----------------------------------------------------------------------------

DelChar  PROC      NEAR

; ------ £schova registr–

         push      cx
         push      si
         push      di

; ------ maz n¡ znaku v bufferu

         mov       di,si                    ; adresa kurzoru
         inc       si                       ; adresa kurzoru + 1
         mov       ch,0
         mov       cl,ds:[LineCNum]         ; po‡et znak– textu
         sub       cl,al                    ; zbytek textu
         jbe       DelChar4                 ; nen¡ nic ke zru¨en¡
         cld                                ; smˆr nahoru
         rep       movsb                    ; p©¡sun zbytku textu a koncov‚ " "
         dec       byte ptr ds:[LineCNum]   ; sn¡‘en¡ po‡tu znak– v bufferu

; ------ n vrat registr–

DelChar4:pop       di
         pop       si
         pop       cx
         ret

DelChar  ENDP

CodeLin  ENDS

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                                 Data
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
Data     SEGMENT

;LinePCol db        0fh                      ; barva textu promptu
;LineCCol db        7                        ; barva textu p©¡kaz. © dku
;LineOCol db        0eh                      ; barva znaku p©ete‡en¡

; ------ definice zobrazen¡ © dku

LineCRad db        22                       ; © dek k zobrazen¡
LineCPth db        76                       ; d‚lka cesty k zobrazen¡
LineCDel db        80                       ; zobrazen  d‚lka p©¡kaz. © dku
LineCVys db        1                        ; v˜¨ka - po‡et © dk– (0 a‘ 2)

; ------ definice obsahu © dku

LineCNum db        0                        ; po‡et znak– v p©¡kaz. © dku
LineCMax db        120                      ; maxim ln¡ d‚lka p©¡kaz. © dku
                                            ;  (je buƒ 120 nebo 111)
LineCTop db        0                        ; offset za‡ tku zobrazen‚ho textu
LineCKur db        0                        ; pozice kurzoru v textu

LineCPar db        0                        ; parametry © dku
                                            ;    bit 0: 1=nen¡ adres ©ov  cesta

LineCBuf label     byte
         db        LineCBfN dup(" ")        ; buffer p©¡kazov‚ho © dku (+rezerva)
                                            ; (dek¢duje se sem nap©. p©¡kaz pro
                                            ;  konfiguraci + pln  cesta jako parametr

Data     ENDS

         END

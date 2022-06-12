
; -----------------------------------------------------------------------------
; Vstupn¡ soubor:
;      - ka‘d  str nka 24 © dk– (napevno)
;      - ka‘d˜ © dek ukon‡en CR/LF
;      - na prvn¡m © dku str nky je seznam n vˆ¨t¡ str nky, ka‘d‚ n vˆ¨t¡
;        je ohrani‡eno p©ep¡na‡i n vˆ¨t¡ (bajt 4) nebo koncem © dku CR/LF
;        Prvn¡ n vˆ¨t¡ na str nce se dosad¡ do defini‡n¡ho souboru HELP@DEF.ASM
;        jako symbol pro odkaz z programu (z n vˆ¨t¡ se vypust¡ mezery a
;        nepovolen‚ znaky a dopln¡ se p©ed nˆ text "Hlp@").
;      - na druh‚m © dku je titulek str nky (zobraz¡ se na horn¡ lince okna)
;      - n sleduje 22 © dk– textu
;          bajt 0 zap¡n /vyp¡n  zv˜raznˆn¡
;          bajt 1 zap¡n /vyp¡n  ozna‡en¡ kl vesy
;          bajt 2 zap¡n /vyp¡n  ozna‡en¡ volby menu
;          bajt 3 zap¡n /vyp¡n  horkou kl vesu volby menu
;          bajt 4 zap¡n /vyp¡n  odkaz na jinou str nku n povˆdy
;          bajt 5 zap¡n /vyp¡n  barvu st¡nu
;          Znak "ú" (k¢d 250) je pevn  mezera a nahrazuje se norm ln¡ mezerou.
;        P©ep¡na‡e mohou b˜t vypnuty t‚‘ koncem © dku. Sou‡asnˆ nesm¡ b˜t
;        nastaveno v¡ce p©ep¡na‡–. Jin‚ hodnoty p©ep¡na‡– nejsou povoleny.
; Konec souboru je indikov n znakem "*" na prvn¡m © dku (nam¡sto n vˆ¨t¡).
; Za koncov˜m znakem "*" jsou 3 ‡¡slice ozna‡uj¡c¡ ‡¡slo verze n povˆdy.
; -----------------------------------------------------------------------------
; Indexov˜ soubor (pou‘¡v  se bˆhem p©ekladu) - jedna polo‘ka n vˆ¨t¡:
;       (2) ‡¡slo str nky (‡¡slov no od 0)
;       (1) d‚lka textu n vˆ¨t¡
;       (x) text n vˆ¨t¡ p©eveden˜ na velk  p¡smena (‡e¨tina Kamenick˜ch)
; -----------------------------------------------------------------------------
; P©echodn˜ (i v˜stupn¡) soubor (samostatn˜ soubor):
;      - ka‘d  str nka m  23 © dk– (vypu¨tˆn © dek s n vˆ¨t¡mi)
;      - na prvn¡m © dku je titulek str nky
;      - n sleduje 22 © dk– textu:
;          bajt 0 zap¡n  zv˜raznˆn¡
;          bajt 1 zap¡n  ozna‡en¡ kl vesy
;          bajt 2 zap¡n  ozna‡en¡ volby menu
;          bajt 3 zap¡n  horkou kl vesu volby menu
;          bajt 4 zap¡n  odkaz na jinou str nku n povˆdy
;                   za bajtem n sleduje 1 slovo jako ‡¡slo str nky a text odkazu
;          bajt 5 zap¡n  barvu okna DOSMANu
;          bajt 6 navrac¡ norm ln¡ barvu
;          bajt 7 konec © dku (+ norm ln¡ barva)
;          bajt 8 a‘ 31 ... 2 a‘ 25 mezer
; -----------------------------------------------------------------------------
; V˜stupn¡ soubor:
;      (5) identifika‡n¡ text "DMHLP"
;      (3) ‡¡slo verze programu - 3 ‡¡slice, nap©. "200"
;      (2) po‡et str nek v souboru
;      (x)*2 velikosti zkomprimovan˜ch str nek v bajtech
;      Za tabulkou velikost¡ str nek za‡¡naj¡ jednotliv‚ str nky.
;      Str nky jsou zkomprimov ny pomoc¡ programu HLPGEN, je vypu¨tˆno
;      z hlav¡ souboru HLP (je n rodn¡ k¢d Kamenick˜ch).
;      Struktura jedn‚ str nky po rozbalen¡ je jako u p©echodn‚ str nky.
; -----------------------------------------------------------------------------
; Postup p©ekladu:
;  1.- Zmapov n¡ str nek - proch z¡ se vstupn¡ soubor, za©azuj¡ se symboly
;      do tabulky symbol– (indexov˜ soubor) s ‡¡sly str nek.
;      Hl s¡ se chyba, pokud symbol ji‘ existuje. Sou‡asnˆ se prvn¡ symbol
;      ze str nky pou‘ije jako odkaz v souboru HELP@DEF.ASM (pro program).
;  2.- Zap¡¨e se z hlav¡ souboru DOSMAN.HLP, offsety jsou zat¡m neplatn‚.
;  3.- P©eklad str nky - na‡te se jedna str nka ze vstupn¡ho souboru,
;      p©ek¢duje se do vnit©n¡ho tvaru, do odkazu se dosad¡ ‡¡slo str nky.
;      Prvn¡ © dek se vypou¨t¡ (n vˆ¨t¡), ukl d  se 23 © dk– (1.© dek=titulek).
;      Hl s¡ se chyba, pokud symbol neexistuje.
;  4.- Komprese str nky - p©elo‘en  str nka se zap¡¨e do p©echodn‚ho souboru
;      a zkomprimuje se pomoc¡ programu HLPGEN. Na‡te se zpˆt do bufferu.
;  5.- Z pis str nky - do tabulky index– str nek se ulo‘¡ d‚lka zkomprimovan‚
;      str nky a zap¡¨e se do souboru zkomprimovan  str nka (bez z hlav¡ HLP).
;  6.- Po z pisu v¨ech str nek se na za‡ tek souboru DOSMAN.HLP zap¡¨e znovu
;      z hlav¡ s platn˜mi d‚lkami str nek.
;  7.- Uzav©en¡ soubor–
; -----------------------------------------------------------------------------
; Postup pou‘it¡:
;  1.- Ze souboru DOSMAN.HLP se na‡te z hlav¡ 10 bajt–. Zkontroluje se
;      identifikace a uschov  se po‡et str nek v souboru.
;  2.- Do indexov‚ho bufferu (po‘adovan  velikost je zn m  z po‡tu str nek)
;      se na‡te indexov  tabulka str nek, kde jsou d‚lky zkomprim. str nek.
;  3.- Vytvo©¡ se pracovn¡ buffer o standardn¡ velikosti nap©. 4 KB.
;  4.- Na konec bufferu se na‡te po‘adovan  str nka (offset v souboru se
;      zjist¡ sou‡tem velikost¡ p©ede¨l˜ch str nek + z hlav¡, velikost
;      dat se zjist¡ z indexov‚ tabulky).
;  5.- Str nka se dekomprimuje (z konce bufferu na za‡ tek).
;  6.- Str nka se zmapuje - zjist¡ se d‚lka titulku str nky a po‡et odkaz–
; -----------------------------------------------------------------------------

DELKA    EQU       24                       ; po‡et © dk– na str nku
IBUFSIZE EQU       10000                    ; velikost vstupn¡ho bufferu
OBUFSIZE EQU       10000                    ; velikost v˜stupn¡ho bufferu
MAXSTRAN EQU       1000                     ; maxim ln¡ po‡et str nek
MAXSYMBN EQU       70                       ; maxim ln¡ d‚lka symbolu

; ------ znaky p©ep¡na‡– pro menu

HlpChBld EQU       0                        ; znak pro zv˜raznˆn¡
HlpChHey EQU       1                        ; znak ozna‡en¡ kl vesy
HlpChMnu EQU       2                        ; znak ozna‡en¡ menu
HlpChHot EQU       3                        ; znak hork‚ kl vesy menu
HlpChSym EQU       4                        ; znak symbolu
HlpChStn EQU       5                        ; znak barvy st¡nu
HlpChNul EQU       6                        ; znak norm ln¡ barvy
HlpChLin EQU       7                        ; znak konce © dku

CR       EQU       13                       ; znak CR
LF       EQU       10                       ; znak LF


Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ zmen¨en¡ bloku programu

Start:   mov       sp,offset Zasob          ; p©edefinov n¡ z sobn¡ku
         mov       bx,(offset(Zasob-Start)+110h)/16 ; po‘adovan  velikost
         mov       ah,4ah
         int       21h                      ; zmen¨en¡ bloku programu

; ------ otev©en¡ vstupn¡ho souboru pro ‡ten¡

         mov       dx,offset InpName        ; jm‚no vstupn¡ho souboru
         mov       ax,3d00h
         int       21h                      ; otev©en¡ pro ‡ten¡
         mov       bp,offset ErrRITxt       ; chybov‚ hl ¨en¡ - chyba ‡ten¡
         call      Chyba                    ; chybov‚ hl ¨en¡ pro CY
         mov       ds:[InpIdnt],ax          ; identifik tor vstupn¡ho souboru

; ------ vytvo©en¡ souboru symbol–

         mov       dx,offset InxName        ; indexov˜ soubor
         xor       cx,cx                    ; atributy souboru
         mov       ah,3ch
         int       21h                      ; vytvo©en¡ souboru index–
         mov       bp,offset ErrCXTxt       ; chyba - nelze vytvo©it
         call      Chyba
         mov       ds:[InxIdnt],ax          ; identifik tor indexov‚ho souboru

; ------ vytvo©en¡ defini‡n¡ho souboru (pro p©eklada‡)

         mov       dx,offset DefName        ; defini‡n¡ soubor
         xor       cx,cx                    ; atributy souboru
         mov       ah,3ch
         int       21h                      ; vytvo©en¡ souboru index–
         mov       bp,offset ErrCDTxt       ; chyba - nelze vytvo©it
         call      Chyba
         mov       ds:[DefIdnt],ax          ; identifik tor defini‡n¡ho souboru


; ====== 1: Zmapov n¡ str nek a symbol– ve vstupn¡m souboru
;þ
; ------ na‡ten¡ jedn‚ str nky ze vstupn¡ho souboru

Start1:  call      InpRead                  ; na‡ten¡ jedn‚ str nky

; ------ vymaz n¡ bufferu pro defini‡n¡ soubor

         cld
         mov       di,offset DefLine1       ; buffer defini‡n¡ho souboru
         mov       cx,MAXSYMBN              ; d‚lka defini‡n¡ho souboru
         mov       al," "                   ; mazac¡ znak mezery
         rep       stosb                    ; vymaz n¡ bufferu

; ------ test, zda je konec souboru

         mov       si,offset InpBuff        ; vstupn¡ buffer
         mov       ax,ds:[si]               ; 1. a 2. znak na © dku
         cmp       al,"*"                   ; je konec souboru ?
         jne       Start12                  ; nen¡ konec souboru

; ------ £schova ‡¡sla verze programu

         mov       ds:[OutIdnt0],ah         ; 1. znak ‡¡sla verze
         mov       ax,ds:[si+2]             ; 3. a 4. znak na © dku
         mov       word ptr ds:[OutIdnt0+1],ax ; 2. a 3. znak verze programu
         jmp       Start2                   ; je konec souboru

; ------ vypu¨tˆn¡ mezer p©ed prvn¡m symbolem

Start12: lodsb                              ; na‡ten¡ prvn¡ho bajtu
         cmp       al," "
         je        Start12                  ; mezera se vypust¡

; ------ kontrola, zda to je symbol

         cmp       al,HlpChSym              ; p©ep¡na‡ symbol– ?
         jne       Start17                  ; nen¡ to symbol

; ------ na‡ten¡ dal¨¡ho znaku k ulo‘en¡

         mov       di,offset DefLine1       ; buffer defini‡n¡ho souboru
Start13: lodsb                              ; na‡ten¡ dal¨¡ho znaku
         cmp       al," "                   ; je to mezera ?
         je        Start13                  ; mezera se vypou¨t¡

; ------ test, zda je konec symbolu

         cmp       al,CR                    ; je konec © dku ?
         je        Start14                  ; je to konec © dku
         cmp       al,HlpChSym              ; p©ep¡na‡ symbol– ?
         je        Start14

; ------ odstranˆn¡ diakritiky znaku

         cmp       al,128
         jb        Start133                 ; nen¡ diakritika
         mov       bx,offset TbKamCS0-128   ; konverzn¡ tabulka
         xlat                               ; konverze znaku

; ------ ulo‘en¡ znaku

Start133:stosb                              ; ulo‘en¡ znaku
         cmp       di,offset DefLine1+MAXSYMBN ; konec bufferu ?
         jb        Start13                  ; dal¨¡ znak

; ------ z pis © dku do defini‡n¡ho souboru

Start14: mov       dx,offset DefLine        ; © dek k z pisu
         mov       cx,offset(DefLine0-DefLine) ; d‚lka © dku
         mov       bx,ds:[DefIdnt]          ; identifik tor souboru
         mov       bp,offset ErrWDTxt       ; text hl ¨en¡ chyby
         call      WritFile                 ; z pis © dku do souboru

; ------ vypu¨tˆn¡ mezer p©ed symbolem

         inc       word ptr ds:[NumStran]   ; ‡¡ta‡ str nek v souboru
         mov       si,offset InpBuff        ; vstupn¡ buffer
Start15: cld
Start16: lodsb
         cmp       al," "
         je        Start16

; ------ test, zda je konec © dku se symboly

         cmp       al,CR                    ; je konec © dku ?
         je        Start19                  ; je konec © dku se symboly

; ------ test, zda to je symbol

         cmp       al,HlpChSym              ; je to symbol ?
         je        Start18                  ; je to symbol OK
Start17: mov       bp,offset ErrSLTxt       ; chybn˜ © dek symbol–
         jmp       Chyba0                   ; chyba

; ------ dek¢dov n¡ symbolu do bufferu

Start18: call      DekSymb                  ; dek¢dov n¡ symbolu DS:SI

; ------ nalezen¡ symbolu v tabulce

         call      SrcSymb                  ; nalezen¡ symbolu v tabulce
         cmc                                ; CY=symbol nalezen
         mov       bp,offset ErrSETxt       ; symbol ji‘ existuje
         call      Chyba                    ; chyba - symbol ji‘ existuje

; ------ nastaven¡ ukazatele na konec souboru symbol–

         mov       bx,ds:[InxIdnt]          ; identifik tor souboru symbol–
         mov       bp,offset ErrWXTxt       ; text - chyba z pisu
         call      EndFile                  ; nastaven¡ ukazatele na konec souboru

; ------ z pis nov‚ho symbolu na konec tabulky symbol–

         mov       dx,offset SymbPage       ; symbol
         mov       cl,ds:[SymbolN]          ; d‚lka textu symbolu
         mov       ch,0
         add       cx,3                     ; d‚lka cel‚ho popisova‡e
         call      WritFile                 ; z pis do souboru
         jmp       short Start15            ; dal¨¡ symbol na © dku

; ------ posun ukazatele souboru na dal¨¡ str nku

Start19: call      NextPage                 ; posun ukazatele na dal¨¡ str nku
         jmp       Start1                   ; dal¨¡ str nka


; ====== 2: Z pis z hlav¡ v˜stupn¡ho souboru (ukazatele zat¡m neplatn‚)
;þ
; ------ vytvo©en¡ v˜stupn¡ho souboru

Start2:  mov       dx,offset OutName        ; v˜stupn¡ soubor
         xor       cx,cx                    ; atributy souboru
         mov       ah,3ch
         int       21h                      ; vytvo©en¡ v˜stupn¡ho souboru
         mov       bp,offset ErrCOTxt       ; chyba - nelze vytvo©it
         call      Chyba
         mov       ds:[OutIdnt],ax          ; identifik tor v˜stupn¡ho souboru
         xchg      ax,bx                    ; BX <- identifik tor v˜stup.souboru

; ------ z pis z hlav¡ do v˜stupn¡ho souboru

         mov       dx,offset OutIdent       ; z hlav¡ souboru
         mov       cx,ds:[NumStran]         ; po‡et str nek v souboru
         shl       cx,1                     ; d‚lka tabulky d‚lek str nek
         add       cx,10                    ; p©i‡ten¡ z hlav¡
         mov       bp,offset ErrWOTxt       ; chyba z pisu
         call      WritFile                 ; z pis z hlav¡ souboru


; ====== 3: P©eklad str nky
;þ
; ------ inicializace ukazatele v souboru

         mov       word ptr ds:[InpOffs],0  ; nulov n¡ offsetu v souboru
         mov       word ptr ds:[InpOffs+2],0
         mov       word ptr ds:[Stranka],1  ; nulov n¡ ukazatele str nky
         mov       word ptr ds:[Radek],1    ; nulov n¡ ukazatele © dku

; ------ kontrola, zda jsou ji‘ v¨echny str nky

Start3:  mov       ax,ds:[NumStrn0]         ; ‡¡ta‡ stran pro druh˜ pr–chod
         cmp       ax,ds:[NumStran]         ; jsou ji‘ v¨echny str nky ?
         jb        Start31                  ; nejsou je¨tˆ v¨echny str nky
         jmp       Start6                   ; konec p©ekladu
Start31: inc       word ptr ds:[NumStrn0]   ; ‡¡ta‡ stran druh‚ho pr–chodu

; ------ na‡ten¡ jedn‚ str nky ze vstupn¡ho souboru

         call      InpRead                  ; na‡ten¡ jedn‚ str nky

; ------ prvn¡ © dek se p©esko‡¡ (n vˆ¨t¡)

         mov       si,offset InpBuff        ; vstupn¡ buffer
         call      NextLine                 ; p©esun na dal¨¡ © dek
         mov       di,offset OutBuff        ; v˜stupn¡ buffer

; ------ na‡ten¡ mezer

Start32: xor       cx,cx                    ; ‡¡ta‡ mezer
         cld
Start322:lodsb                              ; na‡ten¡ znaku
         cmp       al,"ú"                   ; je pevn  mezera ?
         jne       Strt3223                 ; nen¡ pevn  mezera
         mov       al," "                   ; n hrada norm ln¡ mezerou
Strt3223:cmp       al," "                   ; je to mezera ?
         jne       Start323                 ; ‡¡t n¡ mezer
         inc       cx                       ; zv˜¨en¡ ‡¡ta‡e mezer
         cmp       cl,25                    ; maxim ln¡ po‡et mezer
         jb        Start322                 ; m–‘e b˜t dal¨¡ mezera

; ------ ulo‘en¡ k¢du mezer

         inc       si                       ; p©ednastaven¡ - mezera platila
Start323:jcxz      Start33                  ; nen¡ ‘ dn  mezera
         dec       si                       ; n vrat posledn¡ho znaku
         mov       al," "                   ; byla jedna mezera
         dec       cx                       ; byla jedna mezera ?
         jz        Start324                 ; byla jedna mezera
         add       cl,7                     ; korekce ‡¡sla
         xchg      ax,cx                    ; AL <- k¢d mezer
Start324:stosb                              ; ulo‘en¡ bajtu
         jmp       short Start32            ; dal¨¡ mezery

; ------ test, zda je konec © dku

Start33: cmp       al,CR                    ; je konec © dku ?
         je        Start37                  ; je konec © dku

; ------ ulo‘en¡ bˆ‘n‚ho znaku

         stosb                              ; znak se ulo‘¡ beze zmˆny
         cmp       al," "                   ; je bˆ‘n˜ znak ?
         jae       Start32                  ; je bˆ‘n˜ znak - dal¨¡ znak

; ------ test, zda je odkaz

         mov       ah,al                    ; AH <- £schova p©ep¡na‡e
         cmp       al,HlpChSym              ; je to symbol ?
         jne       Start34                  ; nen¡ to symbol

; ------ dek¢dov n¡ textu n vˆ¨t¡

         push      si
         call      DekSymb                  ; dek¢dov n¡ symbolu do bufferu
         pop       si

; ------ nalezen¡ symbolu

         call      SrcSymb                  ; nalezen¡ symbolu
         mov       bp,offset ErrSFTxt       ; chyba - str nka neexistuje
         call      Chyba                    ; obsluha chyby

; ------ ulo‘en¡ ‡¡sla str nky

         cld
         stosw                              ; ulo‘en¡ ‡¡sla str nky
         mov       ah,HlpChSym              ; p©¡znak symbolu

; ------ dek¢dov n¡ textu s barvou

Start34: lodsb                              ; na‡ten¡ dal¨¡ho znaku
         cmp       al,"ú"                   ; je pevn  mezera ?
         jne       Start35                  ; nen¡ pevn  mezera
         mov       al," "                   ; n hrada norm ln¡ mezerou
Start35: cmp       al,CR                    ; je konec © dku ?
         je        Start37                  ; je konec © dku
         cmp       al,ah                    ; je to opˆt p©ep¡na‡ ?
         je        Start36                  ; je to opˆt p©ep¡na‡ - konec
         cmp       al," "                   ; je to platn˜ znak ?
         jb        Start34                  ; nen¡ to platn˜ znak
         stosb                              ; ulo‘en¡ znaku
         jmp       short Start34            ; dal¨¡ znak

; ------ konec textu s barvou

Start36: mov       al,HlpChNul              ; znak norm ln¡ barvy
         stosb                              ; ulo‘en¡ p©ep¡na‡e
         jmp       short Start32            ; dal¨¡ znak

; ------ ulo‘en¡ p©¡znaku konce © dku

Start37: mov       al,HlpChLin              ; p©¡znak konce © dku
         stosb                              ; ulo‘en¡ p©¡znaku konce © dku
         dec       si                       ; n vrat na znak CR

; ------ posun ukazatele na dal¨¡ © dek

         call      NextLine                 ; dal¨¡ © dek

; ------ kontrola, zda jsou ji‘ v¨echny © dky

         cmp       word ptr ds:[Radek],DELKA ; jsou ji‘ v¨echny © dky ?
         ja        Start39                  ; jsou ji‘ v¨echny © dky
         jmp       Start32                  ; dal¨¡ © dek

; ------ d‚lka dat ve v˜stupn¡m buffer

Start39: sub       di,offset OutBuff        ; d‚lka dat v bufferu
         mov       ds:[OutNum],di           ; po‡et bajt– v bufferu


; ====== 4: Komprese str nky
;þ
; ------ zru¨en¡ p©¡padn‚ho zkomprimovan‚ho p©echodn‚ho souboru

         mov       dx,offset BinName        ; jm‚no souboru
         mov       ah,41h
         int       21h                      ; zru¨en¡ p©echodn‚ho souboru 2

; ------ vytvo©en¡ p©echodn‚ho souboru

         mov       dx,offset TxtName        ; jm‚no souboru
         xor       cx,cx                    ; atributy souboru
         mov       ah,3ch
         int       21h                      ; vytvo©en¡ souboru
         mov       bp,offset ErrCTTxt       ; chyba vytvo©en¡ souboru
         call      Chyba
         xchg      ax,bx                    ; BX <- identifik tor souboru

; ------ z pis dat do p©echodn‚ho souboru

         mov       dx,offset OutBuff        ; v˜stupn¡ buffer
         mov       cx,ds:[OutNum]           ; po‡et bajt– v bufferu
         mov       bp,offset ErrWTTxt       ; chyba z pisu dat
         call      WritFile                 ; z pis dat do souboru

; ------ uzav©en¡ p©echodn‚ho souboru

         mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru

; ------ p©¡prava bloku parametr– pro spu¨tˆn¡ programu

         mov       ax,ds:[2ch]              ; segment prost©ed¡
         mov       ds:[HlpGenPE],ax         ; adresa segmentu prost©ed¡
         mov       ds:[HlpGenPC],ds         ; segment p©¡kazov‚ho © dku
         mov       ds:[HlpGenP1],ds         ; segment FCB1
         mov       ds:[HlpGenP2],ds         ; segment FCB2

; ------ £schova registr– p©ed spu¨tˆn¡m programu

         push      ds                       ; £schova DS
         push      es                       ; £schova ES
         mov       ds:[RegSP],sp            ; £schova registru SP
         mov       ds:[RegSS],ss            ; £schova registru SS

; ------ spu¨tˆn¡ programu

         mov       ax,4b00h
         mov       dx,offset HlpGen         ; jm‚no programu
         mov       bx,offset HlpGenP        ; blok parametr–
         int       21h                      ; spu¨tˆn¡ programu

; ------ n vrat registr–

         mov       ss,cs:[RegSS]            ; n vrat SS
         mov       sp,cs:[RegSP]            ; n vrat SP
         pop       es                       ; n vrat ES
         pop       ds                       ; n vrat DS
         cld
         sti

; ------ kontrola stavu operace

         mov       bp,offset ErrExTxt       ; chyba spu¨tˆn¡ programu
         call      Chyba                    ; obsluha chyby

; ------ otev©en¡ zak¢dovan‚ho p©echodn‚ho souboru

         mov       dx,offset BinName        ; p©echodn˜ soubor zkomprimovan˜
         mov       ax,3d00h
         int       21h                      ; otev©en¡ souboru
         mov       bp,offset ErrBiTxt       ; chyba p©i komprimaci
         call      Chyba
         xchg      ax,bx                    ; BX <- identifik tor souboru

; ------ na‡ten¡ souboru do pamˆti

         mov       dx,offset OutBuff        ; v˜stupn¡ buffer
         mov       cx,OBUFSIZE              ; velikost dat k na‡ten¡
         mov       ah,3fh
         int       21h                      ; na‡ten¡ souboru do pamˆti
         mov       bp,offset ErrCBTxt       ; chyba p©i ‡ten¡ ze souboru
         call      Chyba
         mov       ds:[OutNum],ax           ; po‡et bajt– v bufferu

; ------ uzav©en¡ zkomprimovan‚ho souboru

         mov       ah,3eh
         int       21h

; ------ zru¨en¡ nezkomprimovan‚ho p©echodn‚ho souboru

         mov       dx,offset TxtName        ; jm‚no souboru
         mov       ah,41h
         int       21h                      ; zru¨en¡ p©echodn‚ho souboru 1

; ------ zru¨en¡ zkomprimovan‚ho p©echodn‚ho souboru

         mov       dx,offset BinName        ; jm‚no souboru
         mov       ah,41h
         int       21h                      ; zru¨en¡ p©echodn‚ho souboru 2


; ====== 5: z pis zkomprimovan‚ str nky do v˜stupn¡ho souboru
;þ
; ------ kontrola velikosti str nky

         mov       ax,ds:[OutNum]           ; po‡et bajt– v bufferu
         sub       ax,6+1                   ; ode‡ten¡ z hlav¡ + 1
         mov       bp,offset ErrSBTxt       ; chybn  velikost
         call      Chyba
         inc       ax                       ; n vrat velikosti str nky

; ------ ulo‘en¡ velikosti str nky do tabulky

         mov       bx,ds:[NumStrn0]         ; ukazatel ‡¡sla str nky + 1
         shl       bx,1                     ; offset v tabulce + 2
         mov       ds:[bx+DelkTab-2],ax     ; ulo‘en¡ d‚lky str nky

; ------ z pis str nky do v˜stupn¡ho souboru

         xchg      ax,cx                    ; CX <- po‡et bajt– k z pisu
         mov       dx,offset OutBuff+6      ; str nka k z pisu
         mov       bx,ds:[OutIdnt]          ; identifik tor v˜stupn¡ho souboru
         mov       bp,offset ErrWOTxt       ; chyba z pisu
         call      WritFile                 ; z pis str nky do v˜stup. souboru

; ------ zobrazen¡ indik toru operace

         mov       ah,2
         mov       dl,"."
         int       21h

; ------ posun ukazatele souboru na dal¨¡ str nku

         call      NextPage                 ; posun ukazatele na dal¨¡ str nku
         jmp       Start3                   ; dal¨¡ str nka


; ====== 6: Opakovan˜ z pis z hlav¡ do v˜stupn¡ho souboru
;þ
; ------ resetov n¡ ukazatele souboru

Start6:  mov       bx,ds:[OutIdnt]          ; identifik tor souboru
         mov       bp,offset ErrWOTxt       ; chyba z pisu
         call      ResFile                  ; resetov n¡ ukazatele souboru

; ------ z pis z hlav¡ do v˜stupn¡ho souboru

         mov       dx,offset OutIdent       ; z hlav¡ souboru
         mov       cx,ds:[NumStran]         ; po‡et str nek v souboru
         shl       cx,1                     ; d‚lka tabulky d‚lek str nek
         add       cx,10                    ; p©i‡ten¡ z hlav¡
         call      WritFile                 ; z pis z hlav¡ souboru


; ====== 7: Uzav©en¡ soubor–
;þ
; ------ uzav©en¡ v˜stupn¡ho souboru

         mov       bx,ds:[OutIdnt]          ; identifik tor v˜stupn¡ho souboru
         mov       ah,3eh
         int       21h                      ; uzav©en¡ v˜stupn¡ho souboru

; ------ uzav©en¡ defini‡n¡ho souboru

         mov       bx,ds:[DefIdnt]          ; identifik tor defini‡n¡ho souboru
         mov       ah,3eh
         int       21h                      ; uzav©en¡ indexov‚ho souboru

; ------ uzav©en¡ indexov‚ho souboru

         mov       bx,ds:[InxIdnt]          ; identifik tor indexov‚ho souboru
         mov       ah,3eh
         int       21h                      ; uzav©en¡ indexov‚ho souboru

; ------ zru¨en¡ indexov‚ho souboru

         mov       dx,offset InxName        ; indexov˜ soubor
         mov       ah,41h
         int       21h                      ; zru¨en¡ indexov‚ho souboru

; ------ uzav©en¡ vstupn¡ho souboru

         mov       bx,ds:[InpIdnt]          ; identifik tor vstupn¡ho souboru
         mov       ah,3eh
         int       21h                      ; uzav©en¡ vstupn¡ho souboru

; ------ od© dkov n¡ obrazovky

         mov       dx,offset CRTxt
         mov       ah,9
         int       21h

; ------ konec OK

         mov       ax,4c00h
         int       21h

; *****************************************************************************
;
;                       Obsluha vstupn¡ho souboru
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        na‡ten¡ aktu ln¡ str nky ze vstupn¡ho souboru (bez posunu ukazatele)
; -----------------------------------------------------------------------------

InpRead  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      bp
         mov       bp,offset ErrRITxt       ; text hl ¨en¡ - chyba ‡ten¡

; ------ nastaven¡ ukazatele v souboru

         mov       bx,ds:[InpIdnt]          ; identifik tor souboru
         mov       dx,word ptr ds:[InpOffs] ; offset v souboru
         mov       cx,word ptr ds:[InpOffs+2]
         mov       ax,4200h
         int       21h                      ; nastaven¡ ukazatele v souboru
         call      Chyba

; ------ na‡ten¡ dat ze souboru

         mov       dx,offset InpBuff        ; vstupn¡ buffer
         mov       ah,3fh
         mov       cx,IBUFSIZE              ; velikost vztupn¡ho bufferu
         int       21h                      ; na‡ten¡ dat ze souboru
         call      Chyba
         cmp       ax,6                     ; minim lnˆ znak– (pro text "*200")
         call      Chyba

; ------ n vrat registr–

         pop       bp
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InpRead  ENDP

; -----------------------------------------------------------------------------
;        posun ukazatele na dal¨¡ str nku -> CX=d‚lka str nky
; -----------------------------------------------------------------------------

NextPage PROC      NEAR

         push      si

         mov       si,offset InpBuff        ; vstupn¡ buffer
         mov       cx,DELKA                 ; tolik © dk– se hled 
NextPag2:call      NextLine                 ; dal¨¡ © dek
         loop      NextPag2                 ; nalezen¡ konce str nky
         sub       si,offset InpBuff        ; po‡et bajt– na str nku
         add       word ptr ds:[InpOffs],si ; posun ukazatele souboru
         adc       word ptr ds:[InpOffs+2],0

         inc       word ptr ds:[Stranka]    ; zv˜¨en¡ ukazatele ‡¡sla str nky
         mov       word ptr ds:[Radek],1    ; nulov n¡ ukazatele ‡¡sla © dku

         mov       cx,si                    ; CX <- d‚lka str nky
         pop       si
         ret

NextPage ENDP

; -----------------------------------------------------------------------------
;        nalezen¡ dal¨¡ho © dku DS:SI
; -----------------------------------------------------------------------------

NextLine PROC      NEAR

         cld
         push      ax
NextLin1:lodsb
         cmp       al,LF
         jne       NextLin1
         inc       word ptr ds:[Radek]      ; zv˜¨en¡ ukazatele ‡¡sla © dku
         pop       ax
         ret

NextLine ENDP

; *****************************************************************************
;
;                              Obsluha symbol–
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        dek¢dov n¡ symbolu DS:SI do bufferu -> SI=konec za symbolem
; -----------------------------------------------------------------------------

DekSymb  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      di
         push      bp

; ------ p©¡prava ‡¡sla str nky symbolu

         mov       ax,ds:[Stranka]          ; ‡¡slo str nky + 1
         dec       ax                       ; korekce ‡¡sla str nky
         mov       ds:[SymbPage],ax         ; nastaven¡ ‡¡sla str nky

; ------ p©¡prava k dek¢dov n¡ symbolu

         mov       di,offset Symbol         ; buffer jm‚na symbolu
         mov       byte ptr ds:[SymbolN],0  ; nulov n¡ d‚lky symbolu
         cld

; ------ na‡ten¡ dal¨¡ho znaku symbolu

DekSymb1:lodsb                              ; na‡ten¡ dal¨¡ho znaku
         cmp       al," "
         je        DekSymb1                 ; mezera se ignoruje
         cmp       al,"ú"
         je        DekSymb1                 ; pevn  mezera

; ------ test, zda je konec © dku

         cmp       al,CR                    ; je konec © dku CR ?
         je        DekSymb8                 ; je konec © dku CR

; ------ test, zda je konec symbolu

         cmp       al,HlpChSym              ; je konec symbolu ?
         je        DekSymb9                 ; je konec symbolu

; ------ test, zda je buffer ji‘ pln˜

         cmp       byte ptr ds:[SymbolN],MAXSYMBN ; je buffer ji‘ pln˜ ?
         jae       DekSymb1                 ; buffer je ji‘ pln˜

; ------ konverze na velk‚ p¡smeno

         call      UpCase                   ; konverze na velk‚ p¡smeno

; ------ ulo‘en¡ znaku do bufferu

         inc       byte ptr ds:[SymbolN]    ; zv˜¨en¡ ‡¡ta‡e d‚lky symbolu
         stosb                              ; ulo‘en¡ znaku do bufferu
         jmp       short DekSymb1           ; dal¨¡ znak

; ------ n vrat ukazatele na koncov˜ znak CR

DekSymb8:dec       si                       ; n vrat ukazatele na znak CR

; ------ kontrola d‚lky symbolu

DekSymb9:cmp       byte ptr ds:[SymbolN],1  ; kontrola d‚lky symbolu
         mov       bp,offset ErrSlTxN       ; chyba - nulov  d‚lka symbolu
         call      Chyba                    ; obsluha chyby

; ------ n vrat registr–

         pop       bp
         pop       di
         pop       ax
         ret

DekSymb  ENDP

; -----------------------------------------------------------------------------
;        nalezen¡ symbolu v tabulce -> CY=nenalezen, AX=‡¡slo str nky
; -----------------------------------------------------------------------------

SrcSymb  PROC      NEAR

; ------ £schova registr–

         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp

; ------ p©¡prava k operaci

         mov       bp,offset ErrRXTxt       ; BP <- hl ¨en¡ - chyba ‡ten¡
         mov       bx,ds:[InxIdnt]          ; BX <- identifik tor souboru
         xor       cx,cx                    ; CX <- ukazatel offsetu HIGH
         xor       dx,dx                    ; DX <- ukazatel offsetu LOW

; ------ nastaven¡ ukazatele na dal¨¡ symbol

SrcSymb2:call      SetFile                  ; nastaven¡ ukazatele souboru

; ------ na‡ten¡ dal¨¡ho symbolu

         push      cx
         push      dx

         mov       dx,offset InxPage        ; buffer k na‡ten¡ symbolu
         mov       cx,MAXSYMBN+3            ; po‡et bajt– k na‡ten¡
         mov       ah,3fh
         int       21h                      ; na‡ten¡ dat ze souboru
         call      Chyba                    ; obsluha chyby

         pop       dx
         pop       cx
         cmp       ax,1                     ; bylo nˆco na‡teno ?
         jb        SrcSymb9                 ; nebylo nic na‡teno

; ------ posun ukazatele k dal¨¡mu symbolu

         mov       ah,0
         mov       al,ds:[InxSymbN]         ; d‚lka textu symbolu
         add       al,3                     ; p©i‡ten¡ z hlav¡
         add       dx,ax                    ; zv˜¨en¡ offsetu v souboru
         adc       cx,0

; ------ porovn n¡ symbol–

         push      cx
         mov       cl,ds:[InxSymbN]         ; d‚lka textu symbolu
         mov       ch,0
         inc       cx                       ; v‡etnˆ bajtu d‚lky textu
         mov       si,offset InxSymbN       ; text symbolu
         mov       di,offset SymbolN        ; hledan˜ symbol
         cld
         repe      cmpsb                    ; porovn n¡ text– symbol–
         pop       cx
         jne       SrcSymb2                 ; symbol nesouhlas¡ - dal¨¡ hled n¡

; ------ n vrat registr–

SrcSymb9:mov       ax,ds:[InxPage]          ; ‡¡slo str nky na‡ten‚ho symbolu
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

SrcSymb  ENDP

; *****************************************************************************
;
;                           Obecn‚ procedury
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;      z pis dat do souboru (CX bajt– od adresy DX, identifik tor BX, chyba BP)
; -----------------------------------------------------------------------------

WritFile PROC      NEAR

         push      ax

         mov       ah,40h
         int       21h                      ; z pis dat do souboru
         call      Chyba
         cmp       ax,cx                    ; bylo zaps no v¨e ?
         call      Chyba

         pop       ax
         ret

WritFile ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ ukazatele souboru BX na konec souboru (BP=chyba)
; -----------------------------------------------------------------------------

EndFile  PROC      NEAR

         push      ax
         mov       ax,4202h                 ; p©esunut¡ na konec souboru

EndFile1:push      cx
         push      dx

         xor       cx,cx                    ; CX <- 0
         xor       dx,dx                    ; DX <- 0
         int       21h                      ; nastaven¡ na konec/za‡ tek souboru
         call      Chyba

         pop       dx
         pop       cx
         pop       ax
         ret

EndFile  ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ ukazatele souboru BX na za‡ tek souboru (BP=chyba)
; -----------------------------------------------------------------------------

ResFile  PROC      NEAR

         push      ax
         mov       ax,4200h                 ; p©esunut¡ na za‡ tek souboru
         jmp       short EndFile1           ; p©esunut¡ ukazatele

ResFile  ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ ukazatele souboru BX na CX:DX (BP=chyba)
; -----------------------------------------------------------------------------

SetFile  PROC      NEAR

         push      ax
         push      cx
         push      dx

         mov       ax,4200h
         int       21h                      ; nastaven¡ ukazatele souboru
         call      Chyba                    ; obsluha chyby

         pop       dx
         pop       cx
         pop       ax
         ret

SetFile  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ znaku AL na velk‚ p¡smeno
; -----------------------------------------------------------------------------

UpCase   PROC      NEAR

         push      bx

         cmp       al,"a"
         jb        UpCase2
         cmp       al,"z"
         ja        UpCase2
         add       al,"A"-"a"

UpCase2: cmp       al,128
         jb        UpCase4

         mov       bx,offset TbKamUpC-128   ; konverzn¡ tabulka na velk  p¡smena
         xlat                               ; konverze na velk‚ p¡smeno

UpCase4: pop       bx
         ret

UpCase   ENDP

; -----------------------------------------------------------------------------
;        obsluha chyby, je-li nastaven CY (adresa hl ¨en¡ BP)
; -----------------------------------------------------------------------------

Chyba    PROC      NEAR

         jc        Chyba0                   ; je chyba
         ret

Chyba0   label     NEAR

         mov       ax,ds:[Stranka]          ; ‡¡slo str nky
         mov       di,offset ErrErr1
         call      DekNum                   ; dek¢dov n¡ ‡¡sla str nky

         mov       ax,ds:[Radek]            ; ‡¡slo © dku str nky
         mov       di,offset ErrErr2
         call      DekNum                   ; dek¢dov n¡ ‡¡sla © dku

         mov       dx,offset ErrErr         ; £vod hl ¨en¡
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodu hl ¨en¡

         mov       dx,bp                    ; DX <- text chyby
         mov       ah,9
         int       21h                      ; zobrazen¡ hl ¨en¡

         mov       dx,offset ErrErr3        ; zbytek hl ¨en¡
         mov       ah,9
         int       21h                      ; zbytek hl ¨en¡

         mov       ax,4c01h
         int       21h                      ; chybov˜ n vrat

Chyba    ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ ‡¡sla AX do bufferu DS:DI (=konec za ‡¡slem)
; -----------------------------------------------------------------------------

DekNum   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      dx
         push      di

; ------ dek¢dov n¡ ‡¡sla

         mov       bx,10
DekNum1: xor       dx,dx
         div       bx
         add       dl,"0"
         dec       di
         mov       ds:[di],dl
         or        ax,ax
         jnz       DekNum1

; ------ n vrat registr–

         pop       di
         pop       dx
         pop       bx
         pop       ax
         ret

DekNum   ENDP

; *****************************************************************************
;
;                                   data
;
; *****************************************************************************
;þ
; ------ konverzn¡ tabulka z k¢du Kamenick˜ch na velk  p¡smena

TbKamUpC label     byte
         db        '€š…Ž…†€‰‰Š‹œŠŽ'
         db        '’’§™•¦—™š›œž†'
         db        '‹•—¥¥¦§›ž««',172,173,174,175
         db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
         db        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
         db        208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
         db        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
         db        240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255

; ------ konverzn¡ tabulka z k¢du Kamenick˜ch na k¢d bez diakritiky

TbKamCS0 label     byte
         db        'CuedaDTceELIllAA'
         db        'EzZooOuUyOUSLYRt'
         db        'aiounNUOsrrR',172,173,174,175
         db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
         db        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
         db        208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
         db        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
         db        240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255

; ------ texty hl ¨en¡

ErrErr   db        'CHYBA [stranka 000'
ErrErr1  db        ' radek 00'
ErrErr2  db        ']: $'
ErrErr3  db        ' !'
CrTxt    db        13,10,'$'

ErrRITxt db        'Chyba cteni ze souboru HELP\HELP.TXT$'

ErrCXTxt db        'Nelze vytvorit soubor symbolu HELP.SYM$'
ErrRXTxt db        'Chyba cteni ze souboru symbolu HELP.SYM$'
ErrWXTxt db        'Chyba zapisu do souboru symbolu HELP.SYM$'

ErrCDTxt db        'Nelze vytvorit definicni soubor ASM\HELP@DEF.ASM$'
ErrWDTxt db        'Chyba zapisu do definicniho souboru ASM\HELP@DEF.ASM$'

ErrCOTxt db        'Nelze vytvorit vystupni soubor DOSMAN.HLP$'
ErrWOTxt db        'Chyba zapisu do vystupniho souboru DOSMAN.HLP$'

ErrCTTxt db        'Nelze vytvorit prechodny soubor TEMP.TXT$'
ErrWTTxt db        'Chyba zapisu do prechodneho souboru TEMP.TXT$'

ErrExTxt db        'Chyba pri spusteni programu EXEC\HLPGEN.EXE$'
ErrBiTxt db        'Chyba pri komprimaci do souboru TEMP.BIN$'
ErrCBTxt db        'Chyba pri cteni ze souboru TEMP.BIN$'
ErrSBTxt db        'Nulova velikost souboru TEMP.BIN$'

ErrSLTxt db        'Chybny radek symbolu$'
ErrSlTxN db        'Symbol s nulovou delkou$'
ErrSETxt db        'Symbol jiz existuje$'
ErrSFTxt db        'Stranka s pozadovanym navestim neexistuje$'

; ------ ukazatele

Radek    dw        1                        ; ukazatel ‡¡sla © dku str nky
Stranka  dw        1                        ; ukazatel ‡¡sla str nky (1...)

; ------ vstupn¡ soubor

InpName  db        'HELP\HELP.TXT',0        ; vstupn¡ soubor
InpIdnt  dw        0                        ; identifik tor vstupn¡ho souboru
InpOffs  dd        0                        ; offset ve vstupn¡m souboru
InpBuff  db        IBUFSIZE dup(0)          ; vstupn¡ buffer

; ------ indexov˜ soubor (tabulka symbol–)

InxName  db        'HELP.SYM',0             ; indexov˜ soubor
InxIdnt  dw        0                        ; identifik tor indexov‚ho souboru

; ------ buffer k na‡ten¡ jednoho symbolu z indexov‚ho souboru (nemˆnit po©ad¡!)

InxPage  dw        0                        ; ‡¡slo str nky na‡ten‚ho symbolu
InxSymbN db        0                        ; d‚lka textu na‡ten‚ho symbolu
InxSymb  db        MAXSYMBN dup(0)          ; text na‡ten‚ho symbolu

; ------ polo‘ka dek¢dovan‚ho indexov‚ho souboru (nemˆnit po©ad¡ !)

SymbPage dw        0                        ; ‡¡slo str nky symbolu
SymbolN  db        0                        ; d‚lka textu symbolu
Symbol   db        MAXSYMBN dup(0)          ; text symbolu

; ------ defini‡n¡ soubor (defini‡n¡ © dky "Hlp@Symbol db ?",13,10)

DefName  db        'ASM\HELP@DEF.ASM',0     ; defini‡n¡ soubor
DefIdnt  dw        0                        ; identifik tor defini‡n¡ho souboru
DefLine  db        'Hlp@'
DefLine1 db        MAXSYMBN dup(" ")        ; © dek defini‡n¡ho souboru
         db        ' db ?',13,10
DefLine0 label     byte

; ------ p©echodn˜ soubor 1 a 2 (nezkomprimovan˜ a zkomprimovan˜)

TxtName  db        'TEMP.TXT',0             ; p©echodn˜ soubor nezkomprimovan˜
BinName  db        'TEMP.BIN',0             ; p©echodn˜ soubor zkomprimovan˜

; ------ v˜stupn¡ soubor

OutName  db        'DOSMAN.HLP',0           ; v˜stupn¡ soubor
OutIdnt  dw        0                        ; identifik tor v˜stupn¡ho souboru

OutNum   dw        0                        ; po‡et bajt– ve v˜stupn¡m bufferu
OutBuff  db        OBUFSIZE dup(0)          ; v˜stupn¡ buffer

; ------ z hlav¡ v˜stupn¡ho souboru (nemˆnit po©ad¡ !)

OutIdent db        'DMHLP'                  ; identifika‡n¡ text
OutIdnt0 db        '000'                    ; ‡¡slo verze n povˆdy
NumStran dw        0                        ; po‡et str nek v souboru
DelkTab  dw        MAXSTRAN dup(0)          ; tabulka d‚lek str nek v souboru

NumStrn0 dw        0                        ; ‡¡ta‡ stran pro druh˜ pr–chod

; ------ p©¡kaz pro spu¨tˆn¡ programu HLPGEN

HlpGen   db        'EXEC\HLPGEN.EXE',0      ; specifikace programu

HlpGenP  label     byte                     ; blok parametr– pro program
HlpGenPE dw        0                        ; adresa segmentu prost©ed¡
         dw        HlpGenC                  ; offset p©¡kazov‚ho © dku
HlpGenPC dw        0                        ; segment p©¡kazov‚ho © dku
         dw        5ch                      ; offset prvn¡ho FCB
HlpGenP1 dw        0                        ; segment prvn¡ho FCB
         dw        6ch                      ; offset druh‚ho FCB
HlpGenP2 dw        0                        ; segment druh‚ho FCB

HlpGenC  db        21,' TEMP.TXT TEMP.BIN /K',13 ; p©¡kazov˜ © dek

RegSP    dw        0                        ; £schova registru SP
RegSS    dw        0                        ; £schova registru SS

; ------ z sobn¡k programu

         dw        1024 dup(0)              ; z sobn¡k
Zasob    label     word                     ; to je konec programu !!!!

Code     ENDS
         END       Start


; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                              F I L E  -  3
;
;                   Obsluha souborñ - Ru®en° (s nulov†n°m)
;
; =============================================================================
;
; Bàhem obsluhy je ve FileOPth uschov†n aktivn° adres†© na ru®enÇm disku !
; Buffer CilPath se pouë°v† k sestaven° p©echodnÇho jmÇna p©i nulov†n° souborñ.
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

INCLUDE  ASM\DEF.ASM

CodeFil  SEGMENT   BYTE PUBLIC
         ASSUME    cs:CodeFil,ds:Data

; *****************************************************************************
;
;                          Ru®en° souborñ
;
; *****************************************************************************
;˛
AWMMnuSR LABEL     FAR

; ------ dek¢dov†n° nulovac°ho bajtu

         mov       al,ds:[NulFBajt]         ; nulovac° bajt
         mov       ah,0                     ; nen° barva
         push      ds
         pop       es
         mov       di,offset SNMnVPl1       ; buffer k dek¢dov†n° bajtu
         call      far ptr DekHByte         ; dek¢dov†n° bajtu nulov†n°

; ------ nastaven° p©ep°naáñ menu

         mov       dl,ds:[RusParm2]         ; parametry
         call      far ptr SetSwch          ; nastaven° p©ep°naáe

; ------ obsluha menu

         mov       ax,word ptr ds:[SMnuVert+MnuPoz] ; pozice p©edchoz°ho okna
         add       ax,807h                  ; posun okna
         mov       word ptr ds:[si+MnuPoz],ax        ; pozice okna
         jmp       far ptr VertMenu

; ------ zad†n° bajtu k nulov†n°

RusSoNB  PROC      FAR

         push      si
         push      ds
         pop       es
         mov       dx,word ptr ds:[si+MnuPoz]
         add       dx,1*HI+16
         mov       si,offset SNMnVHl1
         mov       di,offset SNMnVPl1
         call      far ptr MenBHex          ; zad†n° novÇ hodnoty á°sla
         mov       ds:[NulFBajt],al         ; nov† hodnota bajtu
         pop       si
RusSoNB2:call      far ptr DispMnu          ; novÇ zobrazen° menu
         ret

RusSoNB  ENDP

; ------ p©ep°naá nulov†n°

RusSoNN: xor       byte ptr ds:[RusParm2],bit0 ; zmàna p©°znaku
         or        byte ptr ds:[RusParm2],bit1
RusSoNN2:mov       dl,ds:[RusParm2]
         call      far ptr SetSwch          ; novÇ nastaven° p©ep°naáñ
         jmp       short RusSoNB2

; ------ p©ep°naá ru®en°

RusSoNR: xor       byte ptr ds:[RusParm2],bit1 ; zmàna p©°znaku
         or        byte ptr ds:[RusParm2],bit0
         jmp       short RusSoNN2

RusSouTb db        bit0 + bit4 + bit6 + bit7 ; kurzor
         db        bit1 + bit4 + bit6 + bit7 ; oznaáenÇ
         db        bit3 + bit4 + bit6        ; zadanÇ

; ------ zah†jen° operace

RusSoub: add       sp,4                     ; zru®en° n†vratovÇ adresy

         mov       al,ds:[RusParm2]         ; aktu†ln° nastaven° parametrñ
         and       al,bit0+bit1             ; p©°znak nulov†n° a ru®en°
         and       byte ptr ds:[RusParm0],not bit0+bit1
         or        ds:[RusParm0],al         ; p©°znak nulov†n° a ru®en°
         mov       bx,ds:[si+MnuAkt]        ; aktivn° zvolen† poloëka
         mov       al,cs:[bx+RusSouTb-1-3]  ; parametry pro vòbàr poloëek
         jmp       short RusSou01

; ------ vstupn° bod z funkán° kl†vesy (AL=typ operace)

RusSoubF LABEL     FAR

         or        byte ptr ds:[RusParm0],bit1 ; prov†d° se ru®en°
         and       byte ptr ds:[RusParm0],not bit0 ; nen° nulov†n°

RusSou01:call      far ptr ClosMnuA         ; uzav©en° v®ech oken menu
         call      far ptr InitFFil         ; inicializace vyhled†v†n°
         jc        RusSoub0                 ; nen° ë†dn† poloëka k operaci
         mov       byte ptr ds:[RusParm],0  ; inicializace parametrñ
         and       byte ptr ds:[RusParm0],not bit7 ; nen° uschov†n aktivn° adres†©

; ------ vytvo©en° datovÇho bufferu pro nulov†n°

         test      byte ptr ds:[RusParm0],bit0 ; je nulov†n° ?
         jz        RusSou03                 ; nen° nulov†n°
         call      far ptr CreatBuf         ; vytvo©en° datovÇho bufferu
         jc        RusSoub0                 ; nedostatek pamàti
         call      far ptr GetBuff          ; poskytnut° bufferu -> ES
         xor       di,di                    ; DI <- 0
         mov       cx,ds:[BuffSize]         ; velikost bufferu
         cld
         mov       al,ds:[NulFBajt]         ; nulovac° bajt
         rep       stosb                    ; vynulov†n° bufferu

; ------ p©°prava parametrñ menu (BX=index typu operace)

RusSou03:mov       ax,ds:[bx+RusSTabH-2]    ; adresa n†povàdy
         mov       word ptr ds:[SR1MnLin+MnuHlp],ax
         mov       ax,ds:[bx+RusSTb2H-2]    ; adresa n†povàdy
         mov       word ptr ds:[SR3MnLin+MnuHlp],ax
         mov       ax,ds:[bx+RusSTabP-2]    ; adresa poloëky
         mov       word ptr ds:[SR1MnLin+MnuPol],ax
         mov       ax,ds:[bx+RusSTb2P-2]    ; adresa poloëky
         mov       word ptr ds:[SR3MnLin+MnuPol],ax

; ------ zad†n° souborñ textem

         test      byte ptr ds:[FileTyp],bit3 ; je specifikace textem ?
         jz        RusSoub2                 ; nen° specifikace textem

RusSou00:mov       si,offset SRZMLin        ; menu zad†n° souborñ
         call      far ptr Lin0Menu         ; obsluha volby
         jnc       RusSoub1                 ; volba OK

; ------ n†vrat z operace

RusSoub0:jmp       far ptr Main0

; ------ rozbor zad†n° parametrñ operace

RusSoub1:call      far ptr RozborZ          ; rozbor zad†n° parametrñ operace
         jc        RusSoub0                 ; p©eru®en° operace
         jnz       RusSou00                 ; opakov†n° zad†n°

; ------ doplnàn° na plnou cestu

         call      far ptr RozbFPth         ; doplnàn° na plnÇ jmÇno
         jmp       short RusSou28

; ------ zobrazen° hl†®en°

RusSoub2:mov       si,offset SR1MnLin
         call      far ptr Lin0MenF         ; potvrzen° volby
         jc        RusSoub0                 ; p©eru®en°
         test      byte ptr ds:[FileTyp],bit1+bit2 ; jsou oznaáenÇ/v®echny poloëky ?
         jz        RusSou28                 ; nejsou oznaáenÇ/v®echny poloëky
         mov       si,offset SR3MnLin
         call      far ptr Lin0MenF         ; potvrzen°
         jc        RusSoub0                 ; p©eru®en°

; ------ posledn° varov†n° p©i nulov†n° souborñ

RusSou28:test      byte ptr ds:[RusParm0],bit0 ; prov†d° se nulov†n° ?
         jz        RusSou29                 ; nen° nulov†n° dat
         mov       si,offset SN3MnLin
         call      far ptr Lin0MenF
         jc        RusSoub0                 ; p©eru®en°

; ------ zobrazen° £vodn°ho hl†®en° (nevad° ëe je stejnÇ pro ru®en° i nulov†n°)

RusSou29:call      far ptr HistADir         ; uloëen° adres†©e do historie
         mov       si,offset RusimTxt       ; text "Ru®°m"
         call      far ptr InfDisp0         ; zobrazen° hl†®en°
         call      far ptr InitFSet         ; inicializace oznaáen° poloëek

; ------ naáten° diskovòch informac° (pot©ebuje se zn†t velikost alok. bloku)

         mov       al,ds:[FilePath]         ; disk
         sub       al,"A"                   ; korekce na á°slo disku
         call      far ptr GetDInfo         ; diskovÇ informace

; ------ vòpoáet velikosti alokaán°ho bloku

         mul       cx                       ; vòpoáet poátu bajtñ na blok
         or        dx,dx
         jz        RusSou2A                 ; nen° v°ce neë 64 KB
         mov       ax,-1                    ; omezen° velikosti bloku
RusSou2A:mov       ds:[NulClust],ax         ; velikost bloku dat
         or        byte ptr ds:[FileParm],bit2 ; p©°znak povolen° adres†©ñ stromu

; ------ nalezen° dal®°ho souboru ke zru®en°

RusSoub3:call      far ptr DispTime         ; obsluha zobrazen° áasu
         call      far ptr DarkNul          ; nulov†n° stm°vaáe obrazovky
         call      far ptr TestBEsc         ; test p©eru®en° operace
         jc        RusSou31                 ; p©eru®en° operace
         call      far ptr GetFFil          ; poskytnut° dal®°ho souboru
         jnc       RusSou32
RusSou31:jmp       RusSoub9                 ; nen° dal®° soubor

; ------ zobrazen° aktivn°ho okna

RusSou32:call      far ptr DispAAWn         ; zobrazen° aktivn°ho okna

; ------ z†kaz ru®en° ROOT disku

         cmp       word ptr ds:[si+1],"\:"  ; je to ROOT adres†© disku ?
         jne       RusSo314
         cmp       byte ptr ds:[si+3],0
         jne       RusSo314                 ; nen° to ROOT adres†© disku

         mov       si,offset RotMnLin       ; chybovÇ hl†®en°
         call      far ptr Lin0MenF         ; chybovÇ hl†®en°
         jc        RusSou31                 ; p©eru®en° operace
         jmp       RusSou44                 ; z†kaz ru®en° ROOT disku

; ------ £schova aktivn°ho adres†©e disku (ES=DS !)

RusSo314:test      byte ptr ds:[RusParm0],bit7 ; uschov†n aktivn° adres†© ?
         jnz       RusSo320                 ; aktivn° adres†© jië byl uschov†n

         mov       al,ds:[si]               ; oznaáen° disku
         sub       al,"A"                   ; korekce na á°slo disku
         mov       di,offset FileOPth       ; buffer adres†©e
         call      far ptr GetDir           ; naáten° aktivn°ho adres†©e
         mov       ds:[FileOPtN],cx         ; dÇlka textu adres†©e
         call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jc        RusSou31                 ; p©eru®en° operace

; ------ zobrazen° hl†®en° o ru®en° poloëky

RusSo320:test      byte ptr ds:[RusParm0],bit0 ; je nulov†n° ?
         jz        RusSo321                 ; nen° nulov†n°
         mov       di,offset NulujTxt       ; text "Nuluji"
         call      far ptr InfKFile         ; zobrazen° hl†®en°
         jmp       short RusSo322

RusSo321:mov       di,offset RusimTxt       ; text "Ru®°m"
         call      far ptr InfFile          ; zobrazen° jmÇna souboru

; ------ potvrzen° ru®en° v p©°padà zad†n° parametrem

RusSo322:test      byte ptr ds:[FileParm],bit3 ; je adres†© p©i n†vratu ?
         jnz       RusSou34                 ; p©i n†vratu se nepotvrzuje
         test      byte ptr ds:[FileTyp],bit3 ; je specifikace textem ?
         jz        RusSou33                 ; nen° specifikace textem
         call      ZrusZad                  ; test zru®en° poloëky zad†n°m
         jnc       RusSou33                 ; poloëka se ru®°
RusSo326:jmp       RusSou44                 ; poloëka se neru®° - dal®° poloëka

; ------ test, zda se ru®° poloëka R/O

RusSou33:test      byte ptr ds:[FileFAtr],RO ; je poloëka R/O ?
         jz        RusSou34                 ; nen° poloëka R/O
         call      ZrusRO                   ; test zru®en° poloëky R/O
         jc        RusSo326                 ; poloëka se neru®° - dal®°

; ------ poloëka se ru®° - odstranàn° atributu R/O

         mov       ch,0
         mov       cl,ds:[FileFAtr]         ; atributy poloëky
         and       cl,not RO                ; nulov†n° atributu R/O
         call      far ptr SetAFile         ; nulov†n° atributñ poloëky

; ------ test, zda je soubor

RusSou34:test      byte ptr ds:[FileFAtr],DIR ; je to adres†© ?
         jnz       RusSoub4                 ; byl nalezen adres†©

; ------ nulov†n° souboru

         test      byte ptr ds:[RusParm0],bit0 ; nuluje se soubor ?
         jz        RusSou35                 ; nenuluje se
         call      NulFile                  ; nulov†n° souboru nebo adres†©e
         jmp       short RusSou36

; ------ zru®en° souboru

RusSou35:test      byte ptr ds:[RusParm0],bit1 ; ru®° se soubor ?
         jz        RusSou38                 ; neru®° se soubor
         call      far ptr DelFile          ; zru®en° souboru ES:SI
RusSou36:jnc       RusSoub6                 ; soubor zru®en OK

; ------ chyba - soubor nelze zru®it

RusSou38:jmp       RusSoub7

; ------ test, zda je ru®en aktivn° adres†© disku

RusSoub4:test      byte ptr ds:[RusParm0],bit1 ; ru®° se ?
         jz        RusSou44                 ; neru®° se

         mov       ax,ds:[FileFilN]         ; dÇlka jmÇna adres†©e
         cmp       ax,ds:[FileOPtN]         ; je to aktivn° adres†© ?
         jne       RusSou43                 ; nen° to aktivn° adres†©

; ------ zkr†cen° dÇlky aktivn°ho adres†©e

         add       ax,offset FileOPth       ; konec cesty
         xchg      ax,di                    ; DI <- adresa konce cesty
RusSou41:cmp       di,offset FileOPth+3     ; je jië minim†ln° dÇlka ?
         jbe       RusSou42                 ; je jië minim†ln° dÇlka
         dec       di                       ; sn°ëen° ukazatele cesty
         dec       word ptr ds:[FileOPtN]   ; sn°ëen° á°taáe dÇlky cesty
         cmp       byte ptr ds:[di],"\"     ; je jië oddàlovaá cesty ?
         jne       RusSou41                 ; nalezen° oddàlovaáe cesty

; ------ nastaven° novÇho aktivn°ho adres†©e (ES=DS !)

RusSou42:mov       byte ptr ds:[di],0       ; oznaáen° konce cesty
         push      si
         mov       si,offset FileOPth       ; nov† cesta
         call      far ptr SetDir           ; nastaven° novÇho aktivn°ho adres†©e
         pop       si

; ------ zru®en° adres†©e

RusSou43:call      far ptr DelDir           ; zru®en° adres†©e
         jnc       RusSoub6                 ; adres†© zru®en OK
         test      byte ptr ds:[FileTyp],bit3 ; je zad†n° textem ?
         jnz       RusSoub7                 ; zad†n° textem - neru®° se hloubàji
         test      byte ptr ds:[FileParm],bit3 ; je adres†© pri n†vratu ?
         jnz       RusSoub7                 ; je adres†© p©i n†vratu

; ------ u vno©enÇho okna se dotaz neprov†d°

         cmp       word ptr ds:[FileWNum],0 ; je vno©enÇ okno ?
         jne       RusSoub5                 ; ru®° se bez dotazu

; ------ dotaz, zda se m† ru®it nepr†zdnò adres†©

         call      ZrusDir                  ; zru®en° nepr†zdnÇho adres†©e
         jnc       RusSoub5                 ; adres†© se ru®° OK

; ------ poloëka se NERUõã - z†kaz vno©en° do podadres†©e

RusSou44:or        byte ptr ds:[FileParm],bit5 ; z†kaz vno©en° do adres†©e
         jmp       short RusSoub7           ; adres†© se neru®°

; ------ zru®en° poloëek v nepr†zdnÇm podadres†©i

RusSoub5:test      byte ptr ds:[RusParm0],bit0 ; je nulov†n° ?
         jnz       RusSoub7                 ; je nulov†n°, neru®° se hromadnà
         test      byte ptr ds:[RusParm0],bit1 ; je ru®en° ?
         jz        RusSoub7                 ; neru®° se
         call      ZrusVse                  ; zru®en° nalezenÇ poloëky
         jmp       short RusSoub7

; ------ poloëka zru®ena OK (soubor nebo adres†©)

RusSoub6:call      far ptr ResFFil          ; nulov†n° oznaáen° poloëky
         mov       si,offset FilePath       ; jmÇno ru®enÇ poloëky
         push      ds
         pop       es
         mov       cx,ds:[FilePthN]         ; dÇlka textu cesty
         mov       di,offset FileFPol       ; vzor poloëky
         mov       dx,ds                    ; DX <- segment vzoru poloëky
         call      far ptr DelWFile         ; zru®en° poloëky z oken
         call      far ptr DispAAWn         ; zobrazen° aktivn°ho okna
         call      far ptr DispNAWn         ; zobrazen° neaktivn°ho okna
         jmp       short RusSou72

; ------ aktualizace okna

RusSoub7:mov       si,offset FilePath       ; jmÇno ru®enÇ poloëky
         push      ds
         pop       es                       ; ES <- datovò segment
         call      far ptr ModiWDir         ; aktualizace oken

; ------ test, zda je p©eru®en° operace

RusSou72:call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jc        RusSoub9                 ; je p©eru®en° operace
         jmp       RusSoub3                 ; dal®° soubor

; ------ uzav©en° reëimu ru®en°

RusSoub9:jmp       RusSoub0

; -----------------------------------------------------------------------------
;                                  ZrusVse
;          hromadnÇ zru®en° souborñ v nalezenÇm adres†©i FILEPATH
; -----------------------------------------------------------------------------
;˛
ZrusVse  PROC      NEAR

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
         sub       sp,FileMax               ; buffer k £schovà adres†©e

; ------ p©°prava á°sla disku

         mov       al,ds:[FilePath]         ; disk
         add       al, -"A" + 1             ; korekce na á°slo disku
         mov       ds:[FCBAll],al           ; á°slo poëadovanÇho disku

; ------ £schova aktivn°ho adres†©e disku

         dec       ax                       ; korekce á°sla disku
         push      ss
         pop       es
         mov       di,sp                    ; buffer k £schovà aktiv. adres†©e
         call      far ptr GetDir           ; poskytnut° aktivn°ho adres†©e
         jc        ZrusVse9

; ------ nastaven° poëadovanÇho aktivn°ho adres†©e

         push      ds
         pop       es
         mov       si,offset FilePath       ; adres†©
         call      far ptr SetDir           ; nastaven° adres†©e
         jc        ZrusVse9                 ; chyba

; ------ zru®en° v®ech poloëek v adres†©i

         call      far ptr TestBreak        ; je p©eru®en° ?
         jc        ZrusVse8                 ; je p©eru®en°
         mov       dx,offset FCBAll         ; specifikace - v®echny soubory
         mov       ah,13h
         int       21h                      ; zru®en° v®ech souborñ

; ------ n†vrat pñvodn°ho aktivn°ho adres†©e

ZrusVse8:call      far ptr ZapKrit          ; zapnut° kritickÇ sekce
         push      ss
         pop       es
         mov       si,sp                    ; pñvodn° aktivn° adres†©
         call      far ptr SetDir           ; n†vrat aktivn°ho adres†©e
         call      far ptr VypKrit          ; vypnut° kritickÇ sekce

; ------ n†vrat registrñ

ZrusVse9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ZrusVse  ENDP

; -----------------------------------------------------------------------------
;                                  ZrusZad
;                dotaz, zda se bude nalezen† poloëka ru®it
; -----------------------------------------------------------------------------
; VSTUP: parametry souboru ve FILEPATH atd.
; VùSTUP: CY=poloëka se neru®° (nebo p©eru®en° operace)
; -----------------------------------------------------------------------------
;˛
ZrusZad  PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      dx
         push      si

; ------ test, zda se ru®° v®echny poloëky

         test      byte ptr ds:[FileFAtr],DIR ; byl nalezen adres†© ?
         jnz       ZrusZad2                 ; byl nalezen adres†©
         test      byte ptr ds:[RusParm],bit4 ; ru®° se v®echny soubory ?
         jz        ZrusZad3                 ; neru®° se
ZrusZad1:jmp       short ZrusZad9

ZrusZad2:test      byte ptr ds:[RusParm],bit5 ; ru®° se v®echny adres†©e ?
         jnz       ZrusZad1                 ; ru®° se v®echny adres†©e

; ------ dotaz na zru®en° poloëky

ZrusZad3:call      far ptr DekFParm         ; dek¢dov†n° parametrñ poloëky
         mov       si,offset SR4MnLin       ; menu pro soubor
         test      byte ptr ds:[FileFAtr],DIR ; byl nalezen adres†© ?
         jz        ZrusZad5                 ; byl nalezen soubor
         mov       si,offset SR5MnLin       ; menu pro adres†©
ZrusZad5:call      far ptr Lin0MenF         ; zad†n° volby
         call      far ptr JumpBX

         dw        1,ZrusZad7               ; poloëka se ru®°
         dw        2,ZrusZd72               ; ru®° se v®echny poloëky
         dw        3,ZrusZd54               ; dal®°
         dw        0,ZrusZd52               ; ESC

; ------ poloëka se neru®° (je ESC)

ZrusZd52:call      far ptr SetEsc           ; nastaven° p©°znaku p©eru®en° ESC
ZrusZd54:stc                                ; poloëka se neru®°
         jmp       short ZrusZad8           ; p©eru®en° operace

; ------ ru®° se v®echny n†sleduj°c° poloëky

ZrusZd72:test      byte ptr ds:[FileFAtr],DIR ; byl nalezen adres†© ?
         jnz       ZrusZd74                 ; byl nalezen adres†©
         or        byte ptr ds:[RusParm],bit4 ; ru®° se v®echny soubory
         jmp       short ZrusZad7
ZrusZd74:or        byte ptr ds:[RusParm],bit5 ; ru®° se v®echny adres†©e

; ------ poloëka se ru®°

ZrusZad7:clc                                ; p©°znak ru®en° poloëky

; ------ obnoven° informaán°ho ©†dku

ZrusZad8:pushf
         call      far ptr InfoDisp         ; obnoven° informaán°ho ©†dku
         popf

; ------ n†vrat registrñ

ZrusZad9:pop       si
         pop       dx
         pop       bx
         ret

ZrusZad  ENDP

; -----------------------------------------------------------------------------
;                                  ZrusDir
;                dotaz, zda se bude nalezenò nepr†zdnò adres†© ru®it
; -----------------------------------------------------------------------------
; VSTUP: parametry souboru ve FILEPATH atd.
; VùSTUP: CY=adres†© se neru®° (nebo p©eru®en° operace)
; -----------------------------------------------------------------------------
;˛
ZrusDir  PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      dx
         push      si

; ------ test, zda se ru®° v®echny adres†©e

         test      byte ptr ds:[RusParm],bit6 ; ru®° se v®echny adres†©e ?
         jnz       ZrusDir9                 ; ru®° se v®echny adres†©e
         test      byte ptr ds:[RusParm],bit7 ; p©eskoá° se v®echny adres†©e ?
         stc
         jnz       ZrusDir9                 ; p©eskoá° se v®echny adres†©e

; ------ dotaz na zru®en° nepr†zdnÇho adres†©e

         call      far ptr DekFParm         ; dek¢dov†n° parametrñ poloëky
         mov       si,offset SR8MnLin       ; menu pro soubor
         call      far ptr Lin0MenF         ; zad†n° volby
         call      far ptr JumpBX

         dw        1,ZrusDir7               ; zru®it
         dw        2,ZrusDir6               ; v®echny
         dw        3,ZrusDir5               ; dal®°
         dw        4,ZrusDir4               ; neru®it
         dw        0,ZrusDir3               ; p©eru®en°

; ------ p©eru®en° operace

ZrusDir3:call      far ptr SetEsc           ; nastaven° p©°znaku p©eru®en° ESC
         jmp       short ZrusDir9           ; p©eru®en° operace

; ------ p©eskoáen° v®ech n†sleduj°c°ch adres†©ñ

ZrusDir4:or        byte ptr ds:[RusParm],bit7 ; p©eskoá° se v®echny adres†©e
ZrusDir5:stc                                ; p©°znak p©eskoáen° poloëky
         jmp       short ZrusDir8

; ------ ru®° se v®echny n†sleduj°c° adres†©e

ZrusDir6:or        byte ptr ds:[RusParm],bit6 ; ru®° se v®echny adres†©e
ZrusDir7:clc                                ; p©°znak zru®en° poloëky

; ------ obnoven° informaán°ho ©†dku

ZrusDir8:pushf
         call      far ptr InfoDisp         ; obnoven° informaán°ho ©†dku
         popf                               ; p©°znak ru®en° poloëky

; ------ n†vrat registrñ

ZrusDir9:pop       si
         pop       dx
         pop       bx
         ret

ZrusDir  ENDP

; -----------------------------------------------------------------------------
;                               ZrusRO
;                   test, zda se poloëka R/O m† ru®it
; -----------------------------------------------------------------------------
; VSTUP: FILEPATH=jmÇno poloëky
;        DS=datovò segment
; VùSTUP: CY=poloëka se neru®° (nebo p©eru®en° operace)
; -----------------------------------------------------------------------------
;˛
ZrusRO   PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      dx
         push      si

; ------ test, zda se ru®° v®echny poloëky

         test      byte ptr ds:[FileFAtr],DIR ; byl nalezen adres†© ?
         jnz       ZrusRO2                  ; byl nalezen adres†©

         test      byte ptr ds:[RusParm],bit0 ; ru®° se v®echny soubory ?
         jnz       ZrusRO1                  ; soubory se ru®°
         test      byte ptr ds:[RusParm],bit1 ; p©eskoá° se v®echny soubory ?
         jz        ZrusRO3                  ; nep©eskoá° se v®echny soubory
ZrusRO0: stc                                ; p©°znak p©eskoáen° poloëky
ZrusRO1: jmp       short ZrusRO9

ZrusRO2: test      byte ptr ds:[RusParm],bit2 ; ru®° se v®echny adres†©e ?
         jnz       ZrusRO1                  ; ru®° se v®echny adres†©e
         test      byte ptr ds:[RusParm],bit3 ; p©eskoá° se v®echny adres†©e ?
         jnz       ZrusRO0                  ; p©eskoá° se v®echny adres†©e

; ------ dotaz na zru®en° poloëky

ZrusRO3: call      far ptr DekFParm         ; dek¢dov†n° parametrñ poloëky
         mov       si,offset SR6MnLin       ; menu pro soubor
         test      byte ptr ds:[FileFAtr],DIR ; byl nalezen adres†© ?
         jz        ZrusRO4                  ; byl nalezen soubor
         mov       si,offset SR7MnLin       ; menu pro adres†©
ZrusRO4: call      far ptr Lin0MenF         ; zad†n° volby
         call      far ptr JumpBX

         dw        1,ZrusRO74               ; zru®it
         dw        2,ZrusRO7                ; v®echny
         dw        3,ZrusRO64               ; dal®°
         dw        4,ZrusRO6                ; neru®it
         dw        0,ZrusRO5                ; p©eru®en°

; ------ p©eru®en° volby

ZrusRO5: call      far ptr SetEsc           ; nastaven° p©°znaku p©eru®en° ESC
         jmp       short ZrusRO9

; ------ p©eskoá° se v®echny n†sleduj°c° poloëky

ZrusRO6: test      byte ptr ds:[FileFAtr],DIR ; byl nalezen adres†© ?
         jnz       ZrusRO62                ; byl nalezen adres†©
         or        byte ptr ds:[RusParm],bit1 ; p©eskoá° se v®echny soubory
         jmp       short ZrusRO64
ZrusRO62:or        byte ptr ds:[RusParm],bit3 ; p©eskoá° se v®echny adres†©e
ZrusRO64:stc                                ; poloëka se p©eskoá°
         jmp       short ZrusRO8

; ------ ru®° se v®echny n†sleduj°c° poloëky

ZrusRO7: test      byte ptr ds:[FileFAtr],DIR ; byl nalezen adres†© ?
         jnz       ZrusRO72                ; byl nalezen adres†©
         or        byte ptr ds:[RusParm],bit0 ; ru®° se v®echny soubory
         jmp       short ZrusRO74
ZrusRO72:or        byte ptr ds:[RusParm],bit2 ; ru®° se v®echny adres†©e
ZrusRO74:clc                                ; p©°znak zru®en° poloëky

; ------ obnoven° informaán°ho ©†dku

ZrusRO8: pushf
         call      far ptr InfoDisp         ; obnoven° informaán°ho ©†dku
         popf

; ------ n†vrat registrñ

ZrusRO9: pop       si
         pop       dx
         pop       bx
         ret

ZrusRO   ENDP

; -----------------------------------------------------------------------------
;                                NulFile
;                      nulov†n° nalezenÇho souboru
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
;        FILEPATH=nalezenò soubor
; VùSTUP: CY=soubor nebyl vynulov†n
; -----------------------------------------------------------------------------
;˛
NulFile  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ jmÇno souboru

         push      ds
         pop       es
         mov       si,offset FilePath       ; jmÇno souboru

; ------ p©°prava velikosti dat k z†pisu -> DX:BX

         mov       ax,word ptr ds:[FileFSiz]; velikost souboru LOW
         mov       dx,word ptr ds:[FileFSiz+2] ; velikost souboru HIGH
         mov       cx,ds:[NulClust]         ; poáet bajtñ na blok
         dec       cx                       ; poáet bajtñ na blok - 1
         add       ax,cx                    ; zarovn†n° nahoru
         adc       dx,0
         inc       cx
         cmp       dx,cx
         jae       NulFil12
         div       cx
         mul       cx                       ; zaokrouhlen° na bloky
NulFil12:xchg      ax,bx                    ; BX <- velikost dat LOW

; ------ otev©en° souboru ES:SI pro z†pis

         call      far ptr OpenRW           ; otev©en° souboru pro z†pis
         jnc       NulFile1
         jmp       NulFile9                 ; chyba operace

; ------ adresa datovÇho bufferu -> ES

NulFile1:call      far ptr GetBuff          ; adresa datovÇho bufferu
         mov       cx,ds:[BuffSize]         ; velikost bufferu

; ------ stanoven° velikosti bloku dat k z†pisu

NulFile2:or        dx,dx                    ; je v°ce neë 64 KB ?
         jnz       NulFile3                 ; zbòv† v°ce neë 64 KB
         cmp       cx,bx                    ; je buffer men®° ?
         jbe       NulFile3                 ; buffer je men®°
         mov       cx,bx                    ; omezen° velikosti dat
NulFile3:sub       bx,cx                    ; sn°ëen° á°taáe zbylòch dat
         sbb       dx,0                     ; p©enos HIGH
         jcxz      NulFile4                 ; konec dat

; ------ z†pis jednoho bloku dat (p©i plnÇm disku je CX=0)

         xor       si,si
         call      far ptr WritFile         ; z†pis bloku dat
         call      far ptr InfoKurz         ; zobrazen° kurzoru operace
         jmp       short NulFile2

; ------ useknut° dat (zde je CX=0)

NulFile4:test      byte ptr ds:[RusParm0],bit1 ; prov†d° se ru®en° ?
         jz        NulFil42                 ; soubor se neru®°
         xor       dx,dx                    ; ukazatel souboru na zaá†tek
         call      far ptr SetUFile         ; nastaven° ukazatele v souboru
         call      far ptr WritFile         ; useknut° dat (z†pisem 0)

; ------ nulov†n° data a áasu souboru

NulFil42:xor       cx,cx                    ; áas souboru
         xor       dx,dx                    ; datum souboru
         call      far ptr SetDFile         ; nastaven° data a áasu souboru

; ------ uzav©en° souboru

         call      far ptr ClosFile         ; uzav©en° souboru

; ------ nulov†n° atributñ souboru

         xor       cx,cx                    ; CX <- 0 atributy
         push      ds
         pop       es
         mov       si,offset FilePath       ; jmÇno souboru
         call      far ptr SetAFile         ; nulov†n° atributñ souboru

; ------ p©enos textu cesty do c°lovÇho bufferu

         mov       di,offset CilPath        ; buffer c°lovÇ cesty
         mov       cx,ds:[FilePthN]         ; dÇlka textu cesty
         cld
         rep       movsb                    ; p©enos textu cesty
         mov       al,"\"
         dec       di
         scasb                              ; koná° cesta znakem "\" ?
         je        NulFile5                 ; koná° znakem "\"
         stosb                              ; uloëen° oddàlovaáe "\"

; ------ p©id†n° jmÇna souboru

NulFile5:mov       al,"$"                   ; jmÇno bude "$000"
         stosb
         mov       al,"0"
         stosb
         stosb
         stosb
         mov       bx,di                    ; BX <- £schova konce jmÇna
         mov       al,0
         stosb                              ; ukonáovac° 0

; ------ test, zda je chybovÇ p©eru®en° operace

NulFile6:call      far ptr TestBEsc         ; test chyby
         jc        NulFile9                 ; chyba - p©eru®en° operace

; ------ test, zda m† bòt ru®en° souboru

         test      byte ptr ds:[RusParm0],bit1 ; prov†d° se ru®en° ?
         stc                                ; p©°znak, ëe soubor nebyl zru®en
         jz        NulFile9                 ; soubor se neru®°

; ------ p©ejmenov†n° souboru

         mov       si,offset FilePath       ; starÇ jmÇno souboru
         mov       di,offset CilPath        ; novÇ jmÇno souboru
         mov       dx,ds                    ; DX <- segment novÇho jmÇna
         call      far ptr RenFile          ; p©ejmenov†n° souboru
         jnc       NulFile8                 ; soubor p©ejmenov†n OK

; ------ zmàna jmÇna souboru

         mov       di,bx                    ; konec cesty
NulFile7:dec       di
         inc       byte ptr ds:[di]         ; zvò®en° á°slice
         cmp       byte ptr ds:[di],"9"+1   ; p©eteáen° ?
         jne       NulFile6                 ; dal®° pokus
         mov       byte ptr ds:[di],"0"
         cmp       byte ptr ds:[di-1],"$"
         jne       NulFile7
         mov       di,si                    ; DI <- pñvodn° jmÇno souboru

; ------ zru®en° souboru

NulFile8:mov       si,di                    ; SI <- novÇ jmÇno souboru
         call      far ptr ZapKrit          ; zapnut° kritickÇ sekce
         call      far ptr DelFile          ; zru®en° souboru
         call      far ptr VypKrit          ; vypnut° kritickÇ sekce

; ------ n†vrat registrñ

NulFile9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

NulFile  ENDP

;         mov       ax,word ptr ds:[FileFSiz]
;         mov       word ptr ds:[CopyDRea],ax
;         mov       ax,word ptr ds:[FileFSiz+2]
;         mov       word ptr ds:[CopyDRea+2],ax
;         test      byte ptr ds:[FileFAtr],DIR
;         jz        RusSou62
;;         mov       ax,word ptr ds:[CopyDBlk]
;         mov       ax,ds:[NulClust]
;         mov       word ptr ds:[CopyDRea],ax
;;         mov       ax,word ptr ds:[CopyDBlk+2]
;;         mov       word ptr ds:[CopyDRea+2],ax
;RusSou62:mov       bp,offset FilePath
;         mov       cx,ds:[FilePthN]
;
;         call      far ptr AWDAkAW          ; aktualizace okna

;; -----------------------------------------------------------------------------
;;        aktualizace oken po zru®en° souboru
;; -----------------------------------------------------------------------------
;; VSTUP: DS:BP=jmÇno souboru ASCIIZ
;;        CX=dÇlka textu adres†©e (bez jmÇna souboru)
;; -----------------------------------------------------------------------------
;
;AWDAkAW  PROC      FAR
;
;         push      ax
;
;         mov       ax,ds:[SegmRAdr]
;         cmp       ax,ds:[SegmAkt]
;         je        AWDAkAW1
;         cmp       ax,ds:[SegmNAkt]
;         je        AWDAkAW1
;         call      AWDAktW          ; aktualizace obsahu okna
;
;AWDAkAW1:mov       ax,ds:[SegmLAdr]
;         cmp       ax,ds:[SegmAkt]
;         je        AWDAkAW2
;         cmp       ax,ds:[SegmNAkt]
;         je        AWDAkAW2
;         call      AWDAktW          ; aktualizace obsahu okna
;
;AWDAkAW2:mov       ax,ds:[SegmAkt]
;         call      AWDAktW          ; aktualizace obsahu okna
;         call      far ptr DispAWin
;
;         mov       ax,ds:[SegmNAkt]
;         call      AWDAktW
;         call      far ptr DispAWin
;
;         cmp       word ptr ds:[FileWNum],0
;         je        AWDAkAW3
;         mov       ax,ds:[FileWSeg] ; adresa prvn°ho okna
;         cmp       ax,ds:[SegmAkt]
;         je        AWDAkAW3
;         call      AWDAktW
;AWDAkAW3:
;         pop       ax
;         ret
;
;AWDAkAW  ENDP
;
;
;AWDAktW  PROC      NEAR
;
;         push      bx
;         push      cx
;         push      dx
;         push      si
;         push      di
;         push      es
;
;         call      far ptr GetDat           ; poskytnut° adresy okna
;         jnc       AWDAktW1
;AWDAktW0:jmp       AWDAktW9
;
;; ------ test, zda odpov°d† disk
;
;AWDAktW1:mov       si,bp                    ; zadanÇ jmÇno adres†©e
;         mov       di,AWinDir               ; adres†© okna
;         mov       bl,ds:[si]               ; oznaáen° disku
;         cmp       bl,es:[AWinDir]          ; souhlas° disk ?
;         jne       AWDAktW0                 ; disk nesouhlas°
;
;; ------ aktualizace diskovòch informac° okna
;
;         push      ax
;         push      dx
;
;         mov       ax,word ptr ds:[CopyDRea] ; ukazatel naátenòch dat
;         mov       dx,word ptr ds:[CopyDRea+2]
;         mov       bx,es:[AWinAlok]          ; velikost bloku
;         dec       bx
;         add       ax,bx                    ; zaokrouhlen° nahoru
;         adc       dx,0
;         inc       bx
;         cmp       dx,bx
;         jae       AWDAkW11
;         div       bx                       ; AX <- poáet blokñ
;         mul       bx                       ; DX:AX <- zaokrouhlen† velikost
;         add       word ptr es:[AWinDFre],ax ; oprava volnÇho m°sta
;         adc       word ptr es:[AWinDFre+2],dx
;
;AWDAkW11:pop       dx
;         pop       ax
;
;; ------ test, zda je adres†©
;
;         mov       bh,es:[AWinPrm1]         ; parametry
;         test      bh,bit3                  ; je to adres†© ?
;         jz        AWDAktW0                 ; nen° to adres†©
;
;; ------ kontrola, zda se adres†© shoduje
;
;AWDAkW14:cmp       cx,es:[AWinDNum]         ; souhlas° dÇlka adres†©e ?
;         jne       AWDAktW0                 ; adres†© nesouhlas°
;         cld
;         repe      cmpsb                    ; porovn†n° adres†©ñ
;         jne       AWDAktW0                 ; adres†© se neshoduje
;         mov       bx,si
;
;; ------ test, zda soubor existuje
;
;         push      ds
;         pop       es
;         mov       si,bp                    ; jmÇno souboru
;         call      far ptr ExisFile         ; test, zda soubor existuje
;         jnc       AWDAktW9                 ; soubor nalezen - to je chyba
;
;; ------ konverze jmÇna nalezenÇho souboru ES:SI na tvar FCB
;
;         mov       si,bx                    ; jmÇno souboru
;         cmp       byte ptr ds:[si],"\"
;         jne       AWDAkW15
;         inc       si
;AWDAkW15:sub       si,offset DTAName        ; fiktivin° poloëka DTA
;         call      far ptr GetBFCB          ; konverze na tvar FCB
;
;; ------ nalezen° poloëky v seznamu (-> ES:SI adresa)
;
;         call      far ptr TestWPol         ; test poloëky FCB, zda je v oknà
;         jc        AWDAktW9                 ; poloëka v oknà nenalezena OK
;
;; ------ zru®en° poloëky ES:SI ze seznamu
;
;         call      far ptr DelWFile         ; zru®en° poloëky ze seznamu
;
;; ------ n†vrat registrñ
;
;AWDAktW9:pop       es
;         pop       di
;         pop       si
;         pop       dx
;         pop       cx
;         pop       bx
;         ret
;
;AWDAktW  ENDP

CodeFil  ENDS

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
;        menu volby souborñ k ru®en°
; -----------------------------------------------------------------------------

SRMnVert label     BYTE

         db        2                        ; typ menu - vertik†ln° podmenu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka volby
         dw        6                        ; poáet platnòch poloëek menu
         dw        7                        ; celkovò poáet poloëek menu

         dw        SRMnVPol                 ; definián° tabulka poloëek
         dw        SRMnVHlp                 ; n†povàda
         dw        Hlp@MenuRuseniANulovaniSouboru ; á°slo str†nky velkÇ n†povàdy
         dw        SRMnVBlk                 ; blokovac° tabulka
         dw        SRMnVSwc                 ; p©ep°naáe
         dw        SRMnVTit                 ; adresa titulu okna
         dw        SRMnVExe                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        36                       ; poá†teán° pozice
         db        8                        ; poá†teán° ©†dek
         db        20                       ; ®°©ka okna
         db        9                        ; vò®ka okna

SRMnVPol db        1,16,'Bajt nulov†n° '
SNMnVPl1 db        '  '
         db        bit7+1,8,'Nulov†n°'
         db        bit7+1,6,'Ru®en°'
         db        bit6+bit7,0
         db        1,6,'Kurzor'
         db        1,8,'OznaáenÇ'
         db        1,6,'ZadanÇ'

; Poloëky modifikovanÇ p©i inicializaci programu !

SRMnVBlk db        0,0,0,0,0,0
SRMnVSwc db        0,0

SRMnVTit db        6,'ru®en°'

HelpS    SEGMENT   BYTE PUBLIC
SRMnVHlp db        63,'Zad†n° bajtu k vynulov†n° dat souboru (00 aë FF v HEX k¢du)'
         db        66,'Vynulov†n° souboru p©ed zru®en°m - soubor nelze jië zpàtnà obnovit'
         db        59,'Bude prov†dàno ru®en° souborñ (jinak jen vynulov†n° obsahu)'
         db        53,'Zru®en° souboru nebo adres†©e pod kurzorem (Alt-F8)'
         db        44,'Zru®en° oznaáenòch souborñ a adres†©ñ (F8)'
         db        53,'Zru®en° souborñ podle blië®° specifikace (Shift-F8)'
SNMnVHl1 db        70,'Zadejte hodnotu bajtu k nulov†n° dat souboru (00 aë FF v HEX k¢du)'
HelpS    ENDS

SRMnVExe label     dword                    ; obsluhy voleb
         dd        RusSoNB                  ; bajt
         dd        RusSoNN                  ; nulov†n°
         dd        RusSoNR                  ; ru®en°
         dd        RusSoub                  ; kurzor
         dd        RusSoub                  ; oznaáenÇ
         dd        RusSoub                  ; zadanÇ

; -----------------------------------------------------------------------------
;       Volba souborñ ke zru®en° (p©i zad†n° textem)
; -----------------------------------------------------------------------------

SRZMLin  label     byte

         db        3                        ; typ menu - ©†dkovÇ podmenu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        SRZMLPol                 ; zaá†tek definice poloëek menu
         dw        SRZMLHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@VyberSouboru         ; á°slo str†nky velkÇ n†povàdy
         dw        SRZMLBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        SRZMLTit                 ; adresa titulu okna
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

         db        HistFile                 ; identifik†tor historie
         db        1                        ; poáet p©edvoleb

         dw        3                        ; dÇlka p©edvolby
         dd        All                      ; p©edvolba

; ------ poloëky voleb

SRZMLPol db        bit6,19,'Soubory ke zru®en°:'
         db        0,0
         db        bit6+bit7,0
         db        1,6,'ProveÉ'
         db        1,6,'N†vrat'

SRZMLBlk db        0,0,0                    ; blokovac° tabulka

SRZMLTit db        6,'zadanÇ'

; ------ n†povàda

HelpS    SEGMENT   BYTE PUBLIC
SRZMLHlp db        3,1
         dw        MenuFndH
         db        51,'Zru®en° souborñ a adres†©ñ podle zadanÇ specifikace'
         db        3,1
         dw        MenuHlP1
HelpS    ENDS

; -----------------------------------------------------------------------------
;        hl†®en° o ru®en° souborñ nebo adres†©ñ
; -----------------------------------------------------------------------------

SR1MnLin label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka volby
         dw        2                        ; poáet platnòch poloëek menu
         dw        4                        ; celkovò poáet poloëek menu

         dw        SR1MnPl1                 ; adresa definián° tabulky poloëek
         dw        SR1MnHl1                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@RuseniSouboru        ; á°slo str†nky velkÇ n†povàdy
         dw        SR1MnBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        SR1MnTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        6                        ; poá†teán° pozice
         db        7                        ; poá†teán° ©†dek
         db        50                       ; ®°©ka
         db        7                        ; vò®ka

         dw        255                      ; maxim†ln° dÇlka ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit2                     ; maska zad†vanòch znakñ
         db        0,'      '               ; dopl§uj°c° zak†zanÇ znaky

         db        0                        ; identifik†tor historie
         db        0                        ; poáet p©edvoleb

SR1MnPl1 db        bit6,33,'Varov†n° - zru®°m soubor '
         db        4,0,1
         dw        FileTxtP                 ; buffer jmÇna souboru
         db        0,' !'

         db        bit6+bit7,0
         db        1,5,'Ru®it'
         db        1,7,'Neru®it'

SR1MnPl2 db        bit6,34,'Varov†n° - zru®°m adres†© '
         db        4,0,1
         dw        FileTxtP                 ; buffer jmÇna adres†©e
         db        0,' !'

         db        bit6+bit7,0
         db        1,5,'Ru®it'
         db        1,7,'Neru®it'

SR1MnBlk db        0,0

SR1MnTit db        6,'ru®en°'

HelpS    SEGMENT   BYTE PUBLIC
SR1MnHl1 db        28,'Zru®en° poëadovanÇho souboru'
         db        3,1
         dw        MenuHlP2

SR1MnHl2 db        50,'Zru®en° poëadovanÇho adres†©e (váetnà podadres†©ñ)'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

; ------ 1 oznaáen† poloëka

SR2MnPl1 db        bit6,42,'Oznaáen '
         db        0,1
         dw        FileTxtP                 ; buffer á°sla poátu souborñ
         db        0,' soubor/adres†© ke zru®en°...'
         db        bit6+bit7,0
         db        1,10,'Pokraáovat'
         db        1,7,'Neru®it'

; ------ 2 aë 4 oznaáenÇ poloëky

SR2MnPl2 db        bit6,45,'Oznaáeny '
         db        0,1
         dw        FileTxtP                 ; buffer á°sla poátu souborñ
         db        0,' soubory/adres†©e ke zru®en°...'

         db        bit6+bit7,0
         db        1,10,'Pokraáovat'
         db        1,7,'Neru®it'

; ------ 5 a v°ce oznaáenòch poloëek

SR2MnPl3 db        bit6,45,'Oznaáeno '
         db        0,1
         dw        FileTxtP                 ; buffer á°sla poátu souborñ
         db        0,' souborñ/adres†©ñ ke zru®en°...'

         db        bit6+bit7,0
         db        1,10,'Pokraáovat'
         db        1,7,'Neru®it'

; ------ v®echny adres†©e v oknà

SR2MnPl4 db        bit6,43,'Budou zru®eny v®echny soubory a adres†©e...'

         db        bit6+bit7,0
         db        1,5,'Ru®it'
         db        1,7,'Neru®it'

HelpS    SEGMENT   BYTE PUBLIC
SR2MnHl1 db        37,'Oznaáenò soubor/adres†© se bude ru®it'
         db        3,1
         dw        MenuHlP2

SR2MnHl2 db        42,'OznaáenÇ soubory a adres†©e se budou ru®it'
         db        3,1
         dw        MenuHlP2

SR2MnHl3 db        48,'V®echny soubory a adres†©e v oknà se budou ru®it'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

RusSTabH label     word                     ; tabulka n†povàd menu
         dw        SR1MnHl1                 ; kurzor - soubor
         dw        SR1MnHl2                 ; kurzor - adres†©
         dw        SR2MnHl1                 ; oznaáenò soubor/adres†©
         dw        SR2MnHl2                 ; 2 aë 4 oznaáenÇ poloëky
         dw        SR2MnHl2                 ; 5 a v°ce oznaáenòch poloëek
         dw        SR2MnHl3                 ; ... (v®echny soubory)
         dw        SR2MnHl3                 ; v®echny soubory a adres†©e
         dw        SR2MnHl3                 ; ... (zadanÇ)

RusSTabP label     word                     ; tabulka poloëek menu
         dw        SR1MnPl1                 ; kurzor - soubor
         dw        SR1MnPl2                 ; kurzor - adres†©
         dw        SR2MnPl1                 ; oznaáenò soubor/adres†©
         dw        SR2MnPl2                 ; 2 aë 4 oznaáenÇ poloëky
         dw        SR2MnPl3                 ; 5 a v°ce oznaáenòch poloëek
         dw        SR2MnPl4                 ; ... (v®echny soubory)
         dw        SR2MnPl4                 ; v®echny soubory a adres†©e
         dw        SR2MnPl4                 ; ... (zadanÇ)

; -----------------------------------------------------------------------------
;        varov†n° p©ed zru®en°m oznaáenòch poloëek
; -----------------------------------------------------------------------------

SR3MnLin label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka volby
         dw        2                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        SR3MnPl1                 ; adresa definián° tabulky poloëek
         dw        SR3MnHl1                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@RuseniSouboru        ; á°slo str†nky velkÇ n†povàdy
         dw        SR1MnBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        SR1MnTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        6                        ; poá†teán° pozice
         db        7                        ; poá†teán° ©†dek
         db        48                       ; ®°©ka
         db        8                        ; vò®ka

         dw        255                      ; maxim†ln° dÇlka ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit2                     ; maska zad†vanòch znakñ
         db        0,'      '               ; dopl§uj°c° zak†zanÇ znaky

         db        0                        ; identifik†tor historie
         db        0                        ; poáet p©edvoleb

; ------ 1 oznaáen† poloëka

SR3MnPl1 db        bit6,9,0,'VAROVèNã'
         db        bit6,38,'Zru®°m '
         db        0,1
         dw        FileTxtP                 ; buffer á°sla poátu souborñ
         db        0,' oznaáenò soubor/adres†© !'
         db        bit6+bit7,0
         db        1,5,'Ru®it'
         db        1,7,'Neru®it'

; ------ 2 aë 4 oznaáenÇ poloëky

SR3MnPl2 db        bit6,9,0,'VAROVèNã'
         db        bit6,40,'Zru®°m '
         db        0,1
         dw        FileTxtP                 ; buffer á°sla poátu souborñ
         db        0,' oznaáenÇ soubory/adres†©e !'

         db        bit6+bit7,0
         db        1,5,'Ru®it'
         db        1,7,'Neru®it'

; ------ 5 a v°ce oznaáenòch poloëek

SR3MnPl3 db        bit6,9,0,'VAROVèNã'
         db        bit6,42,'Zru®°m '
         db        0,1
         dw        FileTxtP                 ; buffer á°sla poátu souborñ
         db        0,' oznaáenòch souborñ/adres†©ñ !'

         db        bit6+bit7,0
         db        1,5,'Ru®it'
         db        1,7,'Neru®it'

; ------ v®echny soubory a adres†©e

SR3MnPl4 db        bit6,9,0,'VAROVèNã'
         db        bit6,42,'Zru®°m v®echny soubory a adres†©e v oknà !'

         db        bit6+bit7,0
         db        1,5,'Ru®it'
         db        1,7,'Neru®it'


HelpS    SEGMENT   BYTE PUBLIC
SR3MnHl1 db        35,'Zru®en° oznaáenÇho souboru/adres†©e'
         db        3,1
         dw        MenuHlP2

SR3MnHl2 db        37,'Zru®en° oznaáenòch souborñ a adres†©ñ'
         db        3,1
         dw        MenuHlP2

SR3MnHl3 db        39,'Zru®en° v®ech souborñ a adres†©ñ v oknà'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

RusSTb2H label     word                     ; tabulka n†povàd menu - potvrzen°
         dw        0                        ; kurzor - soubor
         dw        0                        ; kurzor - adres†©
         dw        SR3MnHl1                 ; oznaáenò soubor/adres†©
         dw        SR3MnHl2                 ; 2 aë 4 oznaáenÇ poloëky
         dw        SR3MnHl2                 ; 5 a v°ce oznaáenòch poloëek
         dw        SR3MnHl3                 ; v®echny soubory
         dw        SR3MnHl3                 ; v®echny soubory a adres†©e
         dw        0                        ; zadanÇ

RusSTb2P label     word                     ; tabulka poloëek menu - potvrzen°
         dw        0                        ; kurzor - soubor
         dw        0                        ; kurzor - adres†©
         dw        SR3MnPl1                 ; oznaáenò soubor/adres†©
         dw        SR3MnPl2                 ; 2 aë 4 oznaáenÇ poloëky
         dw        SR3MnPl3                 ; 5 a v°ce oznaáenòch poloëek
         dw        SR3MnPl4                 ; v®echny soubory
         dw        SR3MnPl4                 ; v®echny soubory a adres†©e
         dw        0                        ; zadanÇ

; -----------------------------------------------------------------------------
;        nalezen° souboru bàhem ru®en° se zad†n°m textem
; -----------------------------------------------------------------------------

SR4MnLin label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka volby
         dw        4                        ; poáet platnòch poloëek menu
         dw        12                       ; celkovò poáet poloëek menu

         dw        SR4MnPol                 ; adresa definián° tabulky poloëek
         dw        SR4MnHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@RuseniSouboru        ; á°slo str†nky velkÇ n†povàdy
         dw        SR4MnBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        SR4MnTit                 ; adresa titulu okna
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

SR4MnPol db        bit6,32,'Nalezen soubor ',0,1
         dw        SRMnuFil                 ; buffer jmÇna souboru
         db        0,' ke zru®en°.'

         db        bit6,0

         db        bit6,14,'Velikost: ',0,1
         dw        SRMnuSiz                 ; buffer velikosti

         db        bit6,14,'   Datum: ',0,1
         dw        SRMnuDat                 ; buffer data

         db        bit6,14,'     Äas: ',0,1
         dw        SRMnuTim                 ; buffer áasu

         db        bit6,0

         db        bit6,32,'P©ejete si tento soubor zru®it ?'

         db        bit6+bit7,0
         db        1,6,'Zru®it'
         db        1,7,'V®echny'
         db        1,5,'Dal®°'
         db        1,8,'P©eru®it'

SR4MnBlk db        0,0,0,0

SR4MnTit db        6,'ru®en°'

HelpS    SEGMENT   BYTE PUBLIC
SR4MnHlp db        26,'Zru®en° nalezenÇho souboru'
         db        46,'Zru®en° v®ech n†sleduj°c°ch souborñ bez dotazu'
         db        47,'Pokraáov†n° d†le bez zru®en° nalezenÇho souboru'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

; -----------------------------------------------------------------------------
;        nalezen° adres†©e bàhem ru®en° se zad†n°m textem
; -----------------------------------------------------------------------------

SR5MnLin label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka volby
         dw        4                        ; poáet platnòch poloëek menu
         dw        11                       ; celkovò poáet poloëek menu

         dw        SR5MnPol                 ; adresa definián° tabulky poloëek
         dw        SR5MnHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@RuseniSouboru        ; á°slo str†nky velkÇ n†povàdy
         dw        SR4MnBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        SR4MnTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        6                        ; poá†teán° pozice
         db        7                        ; poá†teán° ©†dek
         db        54                       ; ®°©ka
         db        12                       ; vò®ka

         dw        255                      ; maxim†ln° dÇlka ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit2                     ; maska zad†vanòch znakñ
         db        0,'      '               ; dopl§uj°c° zak†zanÇ znaky

         db        0                        ; identifik†tor historie
         db        0                        ; poáet p©edvoleb

SR5MnPol db        bit6,33,'Nalezen adres†© ',0,1
         dw        SRMnuFil                 ; buffer jmÇna souboru
         db        0,' ke zru®en°.'

         db        bit6,0

         db        bit6,14,'   Datum: ',0,1
         dw        SRMnuDat                 ; buffer data

         db        bit6,14,'     Äas: ',0,1
         dw        SRMnuTim                 ; buffer áasu

         db        bit6,0

         db        bit6,33,'P©ejete si tento adres†© zru®it ?'

         db        bit6+bit7,0
         db        1,6,'Zru®it'
         db        1,7,'V®echny'
         db        1,5,'Dal®°'
         db        1,8,'P©eru®it'

HelpS    SEGMENT   BYTE PUBLIC
SR5MnHlp db        27,'Zru®en° nalezenÇho adres†©e'
         db        47,'Zru®en° v®ech n†sleduj°c°ch adres†©ñ bez dotazu'
         db        48,'Pokraáov†n° d†le bez zru®en° nalezenÇho adres†©e'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

; -----------------------------------------------------------------------------
;        nalezen soubor chr†nàn atributem R/O
; -----------------------------------------------------------------------------

SR6MnLin label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka volby
         dw        5                        ; poáet platnòch poloëek menu
         dw        8                        ; celkovò poáet poloëek menu

         dw        SR6MnPol                 ; adresa definián° tabulky poloëek
         dw        SR6MnHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@RuseniSouboru        ; á°slo str†nky velkÇ n†povàdy
         dw        SR6MnBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        SR6MnTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        6                        ; poá†teán° pozice
         db        7                        ; poá†teán° ©†dek
         db        62                       ; ®°©ka
         db        8                        ; vò®ka

         dw        255                      ; maxim†ln° dÇlka ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit2                     ; maska zad†vanòch znakñ
         db        0,'      '               ; dopl§uj°c° zak†zanÇ znaky

         db        0                        ; identifik†tor historie
         db        0                        ; poáet p©edvoleb

SR6MnPol db        bit6,52,'Soubor ',0,1
         dw        SRMnuFil                 ; buffer jmÇna souboru
         db        0,' je chr†nàn proti zru®en° atributem R/O.'

         db        bit6,32,'P©ejete si jej i p©esto zru®it ?'

         db        bit6+bit7,0
         db        1,6,'Zru®it'
         db        1,7,'V®echny'
         db        1,5,'Dal®°'
         db        1,7,'Neru®it'
         db        1,8,'P©eru®it'

SR6MnBlk db        0,0,0,0,0

SR6MnTit db        11,'atribut R/O'

HelpS    SEGMENT   BYTE PUBLIC
SR6MnHlp db        53,'Zru®en° tohoto souboru (s ignorov†n°m atributu R/O)'
         db        64,'Zru®en° v®ech n†sleduj°c°ch souborñ s atributem R/O bez dotazu'
         db        43,'Pokraáov†n° d†le bez zru®en° tohoto souboru'
         db        64,'Neru®it ë†dnò z n†sleduj°c°ch souborñ oznaáenòch atributem R/O'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

; -----------------------------------------------------------------------------
;        nalezen° adres†©e s atributem R/O
; -----------------------------------------------------------------------------

SR7MnLin label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka volby
         dw        5                        ; poáet platnòch poloëek menu
         dw        8                        ; celkovò poáet poloëek menu

         dw        SR7MnPol                 ; adresa definián° tabulky poloëek
         dw        SR7MnHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@RuseniSouboru        ; á°slo str†nky velkÇ n†povàdy
         dw        SR6MnBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        SR6MnTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        6                        ; poá†teán° pozice
         db        7                        ; poá†teán° ©†dek
         db        62                       ; ®°©ka
         db        8                        ; vò®ka

         dw        255                      ; maxim†ln° dÇlka ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit2                     ; maska zad†vanòch znakñ
         db        0,'      '               ; dopl§uj°c° zak†zanÇ znaky

         db        0                        ; identifik†tor historie
         db        0                        ; poáet p©edvoleb

SR7MnPol db        bit6,53,'Adres†© ',0,1
         dw        SRMnuFil                 ; buffer jmÇna souboru
         db        0,' je chr†nàn proti zru®en° atributem R/O.'

         db        bit6,32,'P©ejete si jej i p©esto zru®it ?'

         db        bit6+bit7,0
         db        1,6,'Zru®it'
         db        1,7,'V®echny'
         db        1,5,'Dal®°'
         db        1,7,'Neru®it'
         db        1,8,'P©eru®it'

HelpS    SEGMENT   BYTE PUBLIC
SR7MnHlp db        54,'Zru®en° tohoto adres†©e (s ignorov†n°m atributu R/O)'
         db        65,'Zru®en° v®ech n†sleduj°c°ch adres†©ñ s atributem R/O bez dotazu'
         db        44,'Pokraáov†n° d†le bez zru®en° tohoto adres†©e'
         db        65,'Neru®it ë†dnò z n†sleduj°c°ch adres†©ñ oznaáenòch atributem R/O'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

; -----------------------------------------------------------------------------
;        nalezen° nepr†zdnÇho adres†©e
; -----------------------------------------------------------------------------

SR8MnLin label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka volby
         dw        5                        ; poáet platnòch poloëek menu
         dw        8                        ; celkovò poáet poloëek menu

         dw        SR8MnPol                 ; adresa definián° tabulky poloëek
         dw        SR8MnHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@RuseniSouboru        ; á°slo str†nky velkÇ n†povàdy
         dw        SR8MnBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        SR8MnTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        6                        ; poá†teán° pozice
         db        7                        ; poá†teán° ©†dek
         db        61                       ; ®°©ka
         db        8                        ; vò®ka

         dw        255                      ; maxim†ln° dÇlka ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit2                     ; maska zad†vanòch znakñ
         db        0,'      '               ; dopl§uj°c° zak†zanÇ znaky

         db        0                        ; identifik†tor historie
         db        0                        ; poáet p©edvoleb

SR8MnPol db        bit6,27,'Adres†© ',0,1
         dw        SRMnuFil                 ; buffer jmÇna souboru
         db        0,' nen° pr†zdnò.'

         db        bit6,32,'P©ejete si jej i p©esto zru®it ?'

         db        bit6+bit7,0
         db        1,6,'Zru®it'
         db        1,7,'V®echny'
         db        1,5,'Dal®°'
         db        1,7,'Neru®it'
         db        1,8,'P©eru®it'

SR8MnTit db        17,'nepr†zdnò adres†©'

HelpS    SEGMENT   BYTE PUBLIC
SR8MnHlp db        55,'Zru®en° tohoto adres†©e váetnà v®ech souborñ v adres†©i'
         db        59,'Zru®en° v®ech n†sleduj°c°ch nepr†zdnòch adres†©ñ bez dotazu'
         db        44,'Pokraáov†n° d†le bez zru®en° tohoto adres†©e'
         db        50,'Neru®it ë†dnò z n†sleduj°c°ch nepr†zdnòch adres†©ñ'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

; Tabulka modifikov†na p©i inicializaci programu !

SR8MnBlk db        0,0,0,0,0

; -----------------------------------------------------------------------------
;        varov†n° p©ed nulov†n°m
; -----------------------------------------------------------------------------

SN3MnLin label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka volby
         dw        2                        ; poáet platnòch poloëek menu
         dw        6                        ; celkovò poáet poloëek menu

         dw        SN3MnPol                 ; adresa definián° tabulky poloëek
         dw        SN3MnHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@MenuRuseniANulovaniSouboru ; á°slo str†nky velkÇ n†povàdy
         dw        SR1MnBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        SNMnVTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        6                        ; poá†teán° pozice
         db        7                        ; poá†teán° ©†dek
         db        44                       ; ®°©ka
         db        9                        ; vò®ka

         dw        255                      ; maxim†ln° dÇlka ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit2                     ; maska zad†vanòch znakñ
         db        0,'      '               ; dopl§uj°c° zak†zanÇ znaky

         db        0                        ; identifik†tor historie
         db        0                        ; poáet p©edvoleb

SN3MnPol db        bit6,9,0,'VAROVèNã'
         db        bit6,32,'ZvolenÇ soubory a adres†©e budou'
         db        bit6,30,'nulov†n°m nen†vratnà zniáeny !'
         db        bit6+bit7,0
         db        1,7,'Nulovat'
         db        1,8,'P©eru®it'

HelpS    SEGMENT   BYTE PUBLIC
SN3MnHlp db        54,'Zah†jen° operace ru®en° souborñ a adres†©ñ s nulov†n°m'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

SNMnVTit db        8,'nulov†n°'

; -----------------------------------------------------------------------------
;        ru®en ROOT adres†© disku
; -----------------------------------------------------------------------------

RotMnLin label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka volby
         dw        2                        ; poáet platnòch poloëek menu
         dw        6                        ; celkovò poáet poloëek menu

         dw        RotMnPol                 ; adresa definián° tabulky poloëek
         dw        RotMnHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@MenuRuseniANulovaniSouboru ; á°slo str†nky velkÇ n†povàdy
         dw        RotMnBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        RotMnTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        6                        ; poá†teán° pozice
         db        7                        ; poá†teán° ©†dek
         db        44                       ; ®°©ka
         db        9                        ; vò®ka

         dw        255                      ; maxim†ln° dÇlka ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit2                     ; maska zad†vanòch znakñ
         db        0,'      '               ; dopl§uj°c° zak†zanÇ znaky

         db        0                        ; identifik†tor historie
         db        0                        ; poáet p©edvoleb

RotMnPol db        bit6,9,0,'VAROVèNã'
         db        bit6,31,'ROOT disku nen° povoleno ru®it!'
         db        bit6,0
         db        bit6+bit7,0
         db        1,5,'Dal®°'
         db        1,8,'P©eru®it'

HelpS    SEGMENT   BYTE PUBLIC
RotMnHlp db        38,'Pokraáov†n° v operaci dal®°m adres†©em'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

RotMnBlk db        0,0                      ; blokovac° tabulka
RotMnTit db        10,'ru®en ROOT'

; -----------------------------------------------------------------------------
;        data pro ru®en° souborñ
; -----------------------------------------------------------------------------

;NulFBajt db        0                        ; nulovac° bajt souborñ
NulClust dw        0                        ; poáet bajtñ na alokaán° blok

RusimTxt db        7,'Ru®°m ',0

NulujTxt db        8,'Nuluji ',0

FCBAll   db        0                        ; disk
         db        '????????'               ; jmÇno souboru
         db        '???'                    ; p©°pona jmÇna souboru
         db        25 dup(0)                ; ostatn° parametry FCB

RusParm  db        0                        ; parametry pro ru®en°
                                            ;   bit 0: 1=ru®it soubory R/O
                                            ;   bit 1: 1=p©eskoáit soubory R/O
                                            ;   bit 2: 1=ru®it adres†©e R/O
                                            ;   bit 3: 1=p©eskoáit adres†©e R/O
                                            ;   bit 4: 1=ru®it v®echny soubory
                                            ;   bit 5: 1=ru®it v®echny adres†©e
                                            ;   bit 6: 1=ru®it nepr†zdnÇ adres.
                                            ;   bit 7: 1=p©eskoáit nepr†zdnÇ adr.

RusParm0 db        bit1                     ; aktu†ln° nastaven° parametrñ
                                            ;   bit 0: 1=prov†d° se nulov†n°
                                            ;   bit 1: 1=prov†d° se ru®en°

                                            ;   bit 7: 1=uschov†n aktivn° adres†©
                                            ;            (buffer FileOPth,
                                            ;             dÇlka v FileOPtN)

;RusParm2 db        bit1                     ; parametry pro ru®en° (z menu)
;                                            ;   bit 0: 1=prov†d° se nulov†n° dat
;                                            ;   bit 1: 1=prov†d° se ru®en°

Data     ENDS
         END


; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                               W I N D O W - 1
;
;                           Zobrazen° oken adres†©ñ
;
; =============================================================================
;
;        DispAAWn (FAR) - zobrazen° aktivn°ho adres†©ovÇho okna
;        DispAWin (FAR) - zobrazen° adres†©ovÇho okna AX
;
;        DekAFil  (FAR) - dek¢dov†n° jmÇna souboru
;        DekASiz  (FAR) - dek¢dov†n° velikosti souboru
;        DekA4Dat (FAR) - dek¢dov†n° data souboru (rok 4 pozice)
;        DekADat  (FAR) - dek¢dov†n° data souboru (rok 2 pozice)
;        DekATim  (FAR) - dek¢dov†n° áasu souboru (bez sekund)
;        DekATmS  (FAR) - dek¢dov†n° áasu souboru se sekundami
;        DekAAtr  (FAR) - dek¢dov†n° atributñ souboru
;
;        GetLAWin (FAR) - poskytnut° adresy levÇho okna
;        GetRAWin (FAR) - poskytnut° adresy pravÇho okna
;        GetAAWin (FAR) - poskytnut° adresy aktivn°ho okna
;        GetNAWin (FAR) - poskytnut° adresy neaktivn°ho okna
;        TestLAWn (FAR) - test, zda je levÇ okno zapnuto
;        TestRAWn (FAR) - test, zda je pravÇ okno zapnuto
;        TestAAWn (FAR) - test, zda je aktivn° okno zapnuto
;        TestNAWn (FAR) - test, zda je neaktivn° okno zapnuto
;        TestAWin (FAR) - test, zda je okno AX zapnuto
;
; -----------------------------------------------------------------------------
;
;        ParamL   (BYTE) - parametry levÇho okna
;        SegmL    (WORD) - á°slo segmentu levÇho okna
;        SegmLAdr (WORD) - levÇ okno - adres†©
;        SegmLLst (WORD) - levÇ okno - seznam
;        SegmLTre (WORD) - levÇ okno - strom
;
;        ParamR   (BYTE) - parametry pravÇho okna
;        SegmR    (WORD) - á°slo segmentu pravÇho okna
;        SegmRAdr (WORD) - pravÇ okno - adres†©
;        SegmRLst (WORD) - pravÇ okno - seznam
;        SegmLTre (WORD) - pravÇ okno - strom
;
;        WindPar  (BYTE) - parametry oken
;        SegmAkt  (WORD) - segment aktivn°ho okna
;        SegmNAkt (WORD) - segment neaktivn°ho okna
;        NumRows  (BYTE) - skuteán† vò®ka okna
;        NumRows0 (BYTE) - uëivatelsk† vò®ka okna
;
;        OddelRad (BYTE) - oddàlovac° znak ©†dñ á°sel
;        ZnakTim  (BYTE) - oddàlovac° znak áasu
;        ZnakDat  (BYTE) - oddàlovac° znak data
;        FormDat  (BYTE) - form†t zobrazen° data
;
;        QSrcBuff (BYTE) - buffer rychlovyhled†v†n°
;        QSrcNum  (BYTE) - poáet znakñ v bufferu rychlovyhled†v†n°
;
;        ColAWin1 (BYTE) - bàën† barva adres†©ovÇho okna
;        ColAWin2 (BYTE) - vysv°cen† barva adres†©ovÇho okna
;        ColAWin3 (BYTE) - barva kurzoru adres†©ovÇho okna
;        ColAWin4 (BYTE) - vysv°cen† barva kurzoru adres†©ovÇho okna
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

INCLUDE  ASM\DEF.ASM

CodeWin  SEGMENT   BYTE PUBLIC
         ASSUME    cs:CodeWin,ds:Data

; *****************************************************************************
;                               InitMWin
;              inicializace masky oken a segmentu definice skupin
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY=nedostatek pamàti
; neuchov†v† registry
; *****************************************************************************

InitMWin PROC      FAR

; ------ vytvo©en° segmentu masky

         call      far ptr CreatSeg         ; vytvo©en° segmentu
         jc        InitMWn2
         mov       ds:[SegmMWin],ax         ; segment masky
         mov       bx,200h/16
         call      far ptr ModiSeg          ; nastaven° velikosti segmentu
         jc        InitMWn2
         call      far ptr GetDat

; ------ vynulov†n° segmentu masky

         xor       di,di
         mov       ax,"  "
         cld
         mov       cx,200h/2
         rep       stosw

; ------ vytvo©en° segmentu skupin

         call      far ptr CreatSeg         ; vytvo©en° segmentu
         jc        InitMWn2
         mov       ds:[SegmFGrp],ax         ; segment skupin
         mov       bx,16/16                 ; asi tak velikost
         call      far ptr ModiSeg          ; nastaven° velikosti segmentu
         jc        InitMWn2
         call      far ptr GetDat
         mov       word ptr es:[0],2        ; velikost segmentu - nen° nic

;         clc                                ; operace OK
InitMWn2:ret

InitMWin ENDP

; *****************************************************************************
;                               InitIWin
;                  inicializace parametrñ modulu WINDOW
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; neuchov†v† registry
; *****************************************************************************

InitIWin PROC      FAR

; ------ nalezen° dal®°ho parametru

InitIWn1:call      far ptr NextLIni         ; dal®° ©†dek
         jnc       InitIWn2
IniIWn12:ret

InitIWn2:cmp       byte ptr es:[di],"["
         je        IniIWn12
         call      far ptr JumpPTxt

         db        7,'DISPLAB'
         dw        IniIWn31

         db        8,'DISPSORT'
         dw        IniIWn33

         db        8,'DISPFLIN'
         dw        IniIW334

         db        7,'SIZEWIN'
         dw        IniIWn34

         db        6,'AKTWIN'
         dw        IniIWn35

         db        8,'NWINPATH'
         dw        IniIWn36

         db        6,'LWINON'
         dw        IniIW41L

         db        6,'RWINON'
         dw        IniIW41R

         db        7,'LWINATR'
         dw        IniIW42L

         db        7,'RWINATR'
         dw        IniIW42R

         db        7,'LWINEXT'
         dw        IniIW43L

         db        7,'RWINEXT'
         dw        IniIW43R

         db        8,'LWINSORT'
         dw        IniIW44L

         db        8,'RWINSORT'
         dw        IniIW44R

         db        7,'LWINTYP'
         dw        IniIW45L

         db        7,'RWINTYP'
         dw        IniIW45R

         db        8,'LWINTREE'
         dw        IniIW46L

         db        8,'RWINTREE'
         dw        IniIW46R

;         db        8,'LWINVIEW'
;         dw        IniIW47L

;         db        8,'RWINVIEW'
;         dw        IniIW47R

         db        8,'LWINMASK'
         dw        IniIW48L

         db        8,'RWINMASK'
         dw        IniIW48R

         db        6,'ESCWIN'
         dw        IniIWn51

         db        9,'GROUPFILE'
         dw        IniIWn61

         db        9,'GROUPSORT'
         dw        IniIWn71

         db        7,'DIRSUMM'
         dw        IniIWin8

         db        0
         dw        InitIWn1

; ------ zobrazit jmÇno disku

IniIWn31:call      far ptr InitIPYN
         jc        IniIWn32
         and       byte ptr ds:[WindPar2],not bit0 ; nen° jmÇno disku
         jcxz      IniIWn32                    ; nen° jmÇno disku
         or        byte ptr ds:[WindPar2],bit0 ; je jmÇno disku
IniIWn32:jmp       InitIWn1

; ------ zobrazit t©°dàn° okna

IniIWn33:call      far ptr InitIPYN
         jc        IniIWn32
         and       byte ptr ds:[WindPar2],not bit1 ; nen° t©°dàn° okna
         jcxz      IniIWn32                 ; nen° t©°dàn° okna
         or        byte ptr ds:[WindPar2],bit1 ; je t©°dàn° okna
         jmp       short IniIWn32

; ------ zobrazit li®tu kurzoru v oknà

IniIW334:call      far ptr InitIPYN
         jc        IniIWn32
         and       byte ptr ds:[WindPar2],not bit3 ; nen° li®ta kurzoru
         jcxz      IniIWn32                 ; nen° li®ta kurzoru
         or        byte ptr ds:[WindPar2],bit3 ; je li®ta kurzoru
         jmp       short IniIWn32

; ------ vò®ka oken

IniIWn34:test      byte ptr ds:[StartPar],bit2 ; je prvn° inicializace ?
         jnz       IniIWn32                 ; byla jië prvn° inicializace
         call      far ptr InitIBNm         ; vò®ka oken
         jc        IniIWn32
         cmp       al,8                     ; minim†ln° vò®ka oken
         jae       IniIW342
         mov       al,8                     ; omezen° vò®ky oken
IniIW342:mov       ds:[NumRows0],al         ; zadanò poáet ©†dkñ
         jmp       short IniIWn32

; ------ aktivn° okno

IniIWn35:test      byte ptr ds:[StartPar],bit2 ; je prvn° inicializace ?
         jnz       IniIWn32                 ; byla jië prvn° inicializace

         mov       al,es:[di]               ; p©ipravenò znak
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         cmp       al,"L"                   ; levÇ okno ?
         jne       IniIW352
         or        byte ptr ds:[WindPar],bit0 ; aktivn° je levÇ okno
         jmp       short IniIWn32

IniIW352:cmp       al,"R"                   ; pravÇ okno ?
         jne       IniIWn32
         and       byte ptr ds:[WindPar],not bit0 ; aktivn° je pravÇ okno
         jmp       short IniIWn32

; ------ cesta k neaktivn°mu oknu

IniIWn36:test      byte ptr ds:[StartPar],bit2 ; je prvn° inicializace ?
         jnz       IniIWn32                 ; byla jië prvn° inicializace

         mov       si,offset NWinPath       ; cesta k neaktivn°mu oknu
         call      far ptr InitIPFl         ; naáten° neaktivn°ho adres†©e
         jc        IniIWn32
         mov       ds:[NWinPthN],cx         ; dÇlka textu adres†©e
IniIWn37:jmp       IniIWn32

; ------ okno zapnuto

IniIW41L:mov       si,offset ParamL
         jmp       short IniIW414

IniIW41R:mov       si,offset ParamR

IniIW414:test      byte ptr ds:[StartPar],bit2 ; je prvn° inicializace ?
         jnz       IniIWn37                 ; byla jië prvn° inicializace
         call      far ptr InitIPYN         ; p©ep°naá Y/N
         jc        IniIWn37
         and       byte ptr ds:[si],not bit0 ; okno vypnuto
         jcxz      IniIWn37                 ; vypnuto
         or        byte ptr ds:[si],bit0    ; okno zapnuto
         jmp       short IniIWn37

; ------ atributy v oknà

IniIW42L:mov       si,offset ParamLC
         jmp       short IniIW424

IniIW42R:mov       si,offset ParamRC

IniIW424:test      byte ptr ds:[StartPar],bit2 ; je prvn° inicializace ?
         jnz       IniIWn37
         call      far ptr InitIPYN         ; p©ep°naá Y/N
         jc        IniIWn37
         and       byte ptr ds:[si],not bit7 ; nejsou atributy
         jcxz      IniIWn37                 ; nejsou atributy
         or        byte ptr ds:[si],bit7    ; jsou atributy
         jmp       short IniIWn37

; ------ dopl§uj°c° stavovò ©†dek v oknà

IniIW43L:mov       si,offset ParamLC
         jmp       short IniIW434

IniIW43R:mov       si,offset ParamRC

IniIW434:test      byte ptr ds:[StartPar],bit2 ; je prvn° inicializace ?
         jnz       IniIWn37
         call      far ptr InitIPYN         ; p©ep°naá Y/N
         jc        IniIWn37
         or        byte ptr ds:[si],bit4    ; nen° stavovò ©†dek
         jcxz      IniIWn37                 ; nen° stavovò ©†dek
         and       byte ptr ds:[si],not bit4 ; je stavovò ©†dek
IniIW438:jmp       short IniIWn37

; ------ t©°dàn° okna

IniIW44L:mov       si,offset ParamLC
         jmp       short IniIW442

IniIW44R:mov       si,offset ParamRC

IniIW442:test      byte ptr ds:[StartPar],bit2 ; je prvn° inicializace ?
         jnz       IniIW438                 ; byla jië prvn° inicializace
         call      far ptr JumpPTxt

         db        4,'NAME'
         dw        IniIW444

         db        5,'!NAME'
         dw        IniIW444

         db        3,'EXT'
         dw        IniIW444

         db        4,'!EXT'
         dw        IniIW444

         db        4,'SIZE'
         dw        IniIW444

         db        5,'!SIZE'
         dw        IniIW444

         db        4,'DATE'
         dw        IniIW444

         db        5,'!DATE'
         dw        IniIW444

         db        2,'NO'
         dw        IniIW444

         db        0
         dw        InitIWn1

IniIW44T db        0*bit1,0*bit1+bit3
         db        1*bit1,1*bit1+bit3
         db        2*bit1,2*bit1+bit3
         db        3*bit1,3*bit1+bit3
         db        bit0

IniIW444:xchg      ax,bx
         mov       al,cs:[bx+IniIW44T-1]
         and       byte ptr ds:[si],not bit0+bit1+bit2+bit3
         or        ds:[si],al
IniIW448:jmp       short IniIW438

; ------ typ zobrazen° okna

IniIW45L:mov       si,offset ParamLC
         jmp       short IniIW452

IniIW45R:mov       si,offset ParamRC

IniIW452:test      byte ptr ds:[StartPar],bit2 ; je prvn° inicializace ?
         jnz       IniIW448                 ; byla jië prvn° inicializace
         call      far ptr JumpPTxt

         db        1,'1'
         dw        IniIW454

         db        1,'3'
         dw        IniIW454

         db        1,'C'
         dw        IniIW454

         db        1,'L'
         dw        IniIW454

         db        0
         dw        InitIWn1

IniIW454:dec       ax
         mov       cl,5
         shl       al,cl
         and       byte ptr ds:[si],not bit5+bit6
         or        ds:[si],al
         jmp       short IniIW448

; ------ zobrazen° stromu v oknà

IniIW46L:mov       si,offset ParamL
         jmp       short IniIW464

IniIW46R:mov       si,offset ParamR

IniIW464:test      byte ptr ds:[StartPar],bit2 ; je prvn° inicializace ?
         jnz       IniIW448
         call      far ptr InitIPYN         ; p©ep°naá Y/N
         jc        IniIW448
         and       byte ptr ds:[si],not bit1+bit2+bit3
         or        byte ptr ds:[si],bit1    ; zobrazen adres†©
         jcxz      IniIW448                 ; nen° strom
         xor       byte ptr ds:[si],bit1+bit2 ; zobrazen strom

;         jmp       short IniIW448
;
;; ------ rychlò prohl°ëeá okna
;
;IniIW47L:mov       si,offset ParamL
;         jmp       short IniIW474
;
;IniIW47R:mov       si,offset ParamR
;
;IniIW474:test      byte ptr ds:[StartPar],bit2 ; je prvn° inicializace ?
;         jnz       IniIW448
;         call      far ptr InitIPYN         ; p©ep°naá Y/N
;         jc        IniIW448
;         and       byte ptr ds:[si],not bit4 ; nen° prohl°ëeá
;         jcxz      IniIW448                 ; nen° strom
;         or        byte ptr ds:[si],bit4    ; je prohl°ëeá

IniIW476:jmp       short IniIW448

; ------ maska okna

IniIW48L:xor       si,si                    ; ukl†dac° adresa levÇho okna
         jmp       short IniIW482

IniIW48R:mov       si,100h                  ; ukl†dac° adresa pravÇho okna

IniIW482:mov       ax,ds:[SegmMWin]         ; segment masky oken
         call      far ptr GetSgAdr         ; adresa segmentu
         jc        IniIW476

         push      ds
         mov       cx,256                   ; maxim†ln° dÇlka filtru
         mov       ds,dx                    ; DS <- segment bufferu filtru
IniIW483:mov       al,es:[di]
         inc       di
         cmp       al," "
         jae       IniIW484
         dec       di
         mov       al," "
IniIW484:mov       ds:[si],al
         inc       si
         loop      IniIW483
         pop       ds

         jmp       short IniIW476

; ------ ESC zap/vyp oken

IniIWn51:call      far ptr InitIPYN         ; p©ep°naá Y/N
         jc        IniIW476
         and       byte ptr ds:[WindPar2],not bit2 ; nen° povoleno
         jcxz      IniIW476                 ; nen° povoleno
         or        byte ptr ds:[WindPar2],bit2 ; je povoleno
IniIW512:jmp       short IniIW476

; ------ definice skupin oken

                                          ;* nalezen° platnÇho ©†dku
IniIWn61:call      far ptr InitISpc         ; vypu®tàn° mezer

                                          ;* naáten° á°sla skupiny -> DL
         mov       dl,es:[di]               ; p©ipravenò znak
         sub       dl,"0"
         jb        IniIWn68                 ; nen° platnò ©†dek
         cmp       dl,9
         ja        IniIWn68
         add       dl,FileATU0              ; korekce á°sla skupiny
         inc       di
         cmp       byte ptr es:[di],":"
         jne       IniIWn68                 ; nen° platnò ©†dek
         inc       di

                                          ;* nalezen° dal®° p©°pony -> ES:DI
IniIWn62:call      far ptr InitISpc         ; vypu®tàn° mezer

                                          ;* naáten° p©°pony
         mov       bx,"  "                  ; 2. a 3. znak = mezera
         mov       dh," "
         mov       al,es:[di]
         cmp       al,";"
         je        IniIWn68
         cmp       al," "
         jbe       IniIWn68
         inc       di
         cmp       al,"."
         je        IniIWn63                 ; p©°pona jsou mezery
         call      far ptr UpCase
         mov       dh,al                    ; DH <- 1. znak p©°pony

         mov       al,es:[di]
         cmp       al,";"
         je        IniIWn63
         cmp       al," "
         jbe       IniIWn63
         inc       di
         call      far ptr UpCase
         mov       bl,al                    ; BL <- 2. znak p©°pony

         mov       al,es:[di]
         cmp       al,";"
         je        IniIWn63
         cmp       al," "
         jbe       IniIWn63
         inc       di
         call      far ptr UpCase
         mov       bh,al                    ; BH <- 3. znak p©°pony

                                          ;* uloëen° p©°pony
IniIWn63:push      di
         mov       ax,ds:[SegmFGrp]         ; segment definice skupin
         call      far ptr GetDat           ; adresa segmentu
         mov       di,es:[0]                ; konec dat v bufferu
         mov       cx,4                     ; poáet bajtñ k vloëen°
         call      far ptr InsDat           ; vloëen° dat
         jc        IniIWn64
         mov       es:[di],dx               ; á°slo skupiny a 1. znak
         mov       es:[di+2],bx             ; 2. a 3. znak p©°pony
IniIWn64:pop       di

         call      far ptr GetDIni          ; nov† adresa bufferu
         jmp       short IniIWn62           ; dal®° p©°pona

;                                          ;* rozbor zad†n° masky
;         mov       si,offset LinBuff        ; buffer ©†dku
;IniIWn62:mov       al,es:[di]
;         cmp       al,TAB
;         jne       IniIWn63
;         mov       al," "
;IniIWn63:cmp       al," "
;         jb        IniIWn64
;         cmp       al,";"
;         je        IniIWn64
;         inc       di
;         mov       ds:[si],al               ; uloëen° znaku do bufferu
;         inc       si
;         cmp       si,offset LinBuff+255
;         jb        IniIWn62
;IniIWn64:sub       si,offset LinBuff
;         xchg      ax,si
;         mov       ds:[LinNum],al           ; dÇlka textu v bufferu
;         call      far ptr Rozbor           ; rozbor zad†n° masky
;
;                                          ;* £schova tabulky parametrñ do bufferu
;         push      di
;
;         mov       ax,ds:[SegmFGrp]         ; segment definice skupin
;         call      far ptr GetDat           ; adresa segmentu
;         mov       bx,es:[0]                ; souáasn† velikost segmentu
;         mov       di,bx                    ; DI <- adresa konce bufferu
;         mov       cx,SIZE AWinFilS         ; velikost pole pro hled†n°
;         add       bx,SIZE AWinFilS         ; zvàt®en° velikosti segmentu
;         call      far ptr ModiSegS         ; zvàt®en° segmentu
;         jc        IniIWn67                 ; chyba pamàti
;         mov       es:[0],bx                ; nov† velikost segmentu
;         mov       si,offset SrcInit        ; zaá†tek parametrñ pro hled†n°
;         cld
;         rep       movsb                    ; £schova tabulky parametrñ
;
;IniIWn67:pop       di
;         call      far ptr GetDIni          ; nov† adresa bufferu

                                          ;* nalezen° dal®°ho ©†dku
IniIWn68:call      far ptr NextTIni         ; nalezen° dal®°ho ©†dku
         jc        IniIWn69                 ; nen° dal®° ©†dek
         cmp       byte ptr es:[di]," "
         je        IniIW682                 ; je dal®° ©†dek
         cmp       byte ptr es:[di],TAB
         je        IniIW682
         dec       di                       ; n†vrat ukazatele na p©ede®lò ©†dek
IniIWn69:jmp       InitIWn1                 ; nen° dal®° ©†dek
IniIW682:jmp       IniIWn61

; ------ t©°dàn° skupin souborñ

                                          ;* inicializace tabulky
IniIWn71:mov       si,offset GrpSortT
         mov       al,-1
IniIWn72:mov       cs:[si],al
         inc       si
         cmp       si,offset GrpSrtT0
         jb        IniIWn72

                                          ;* naáten° znaku
         dec       di
         mov       ah,1                     ; ukazatel t©°dic° hladiny

IniIWn73:dec       ah                       ; slouáen° s p©ede®lou skupinou
IniIWn74:inc       di
         mov       al,es:[di]
;         cmp       al,TAB
;         je        IniIWn74
         cmp       al," "
         jb        IniIWn69
;         je        IniIWn74
;         cmp       al,","
;         je        IniIWn74
         cmp       al,";"
         je        IniIWn69
         cmp       al,"+"
         je        IniIWn73                 ; je slouáen° skupin

                                          ;* rozpozn†n° znaku
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         mov       bx,offset GrpSortT       ; poloha pro ostatn°
         cmp       al,"?"                   ; ostatn° ?
         je        IniIWn75                 ; ostatn°
         inc       bx                       ; poloha pro ".."
         cmp       al,"U"                   ; nadadres†© ?
         je        IniIWn75                 ; nadadres†©
         inc       bx                       ; poloha pro adres†©e
         cmp       al,"D"                   ; adres†©e ?
         je        IniIWn75                 ; adres†©e
         inc       bx                       ; poloha pro HID/SYS
         cmp       al,"H"                   ; HID/SYS ?
         je        IniIWn75
         inc       bx                       ; poloha pro programy
         cmp       al,"X"                   ; programy ?
         je        IniIWn75                 ; jsou programy
         sub       al,"0"-1                 ; je á°slo ?
         jbe       IniIWn74                 ; nen° platnò znak
         cmp       al,FileTMax              ; maxim†ln° á°slice
         ja        IniIWn74                 ; neplatnò znak
         add       bl,al                    ; poloha skupiny
         adc       bh,0

IniIWn75:mov       cs:[bx],ah               ; uloëen° hladiny
         inc       ah                       ; zvò®en° ukazatele hladiny
         jmp       short IniIWn74           ; dal®° znak

; ------ naá°tat velikost adres†©ñ ze stromu

IniIWin8:call      far ptr InitIPYN
         jc        IniIWn81
         and       byte ptr ds:[WindPar2],not bit6 ; nen° naá°t†n° velikosti
         jcxz      IniIWn81                    ; nen° jmÇno disku
         or        byte ptr ds:[WindPar2],bit6 ; je naá°t†n° velikosti
IniIWn81:jmp       InitIWn1


InitIWin ENDP

GrpSortT db        -1,0,1,2,FileTMax+1 dup(-1) ; t©°dic° tabulka skupin souborñ
GrpSrtT0 label     byte

; *****************************************************************************
;                                    AktIWin
;                    inicializace nastaven° parametrñ oken
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
;        uchov†v† registr p©°znakñ !
; *****************************************************************************

AktIWin  PROC      FAR

; ------ £schova registrñ

         pushf
         push      ax
         push      bx
;         push      es

; ------ p©°znak vypnut° oken

         test      byte ptr ds:[ParamL],bit0 ; levÇ okno vypnuto ?
         jnz       AktIWin2                 ; levÇ okno nen° vypnuto
         test      byte ptr ds:[ParamR],bit0 ; pravÇ okno vypnuto ?
         jnz       AktIWin2                 ; pravÇ okno nen° vypnuto
         and       byte ptr ds:[WindPar],not bit1 ; obà okna jsou vypnuta

; ------ aktivn° a neaktivn° okno

AktIWin2:or        byte ptr ds:[ParamL],bit7 ; levÇ okno je aktivn°
         and       byte ptr ds:[ParamR],not bit7 ; pravÇ okno nen° aktivn°
         mov       ax,ds:[SegmL]            ; levÇ okno
         mov       bx,ds:[SegmR]            ; pravÇ okno
         test      byte ptr ds:[WindPar],bit0 ; je aktivn° levÇ okno ?
         jnz       AktIWin3                 ; je aktivn° levÇ okno
         xchg      ax,bx                    ; oprava oken
         and       byte ptr ds:[ParamL],not bit7 ; levÇ okno nen° aktivn°
         or        byte ptr ds:[ParamR],bit7 ; pravÇ okno je aktivn°
AktIWin3:mov       ds:[SegmAkt],ax          ; aktivn° okno
         mov       ds:[SegmNAkt],bx         ; neaktivn° okno

; ------ n†vrat registrñ

;         pop       es
         pop       bx
         pop       ax
         popf
         ret

AktIWin  ENDP

; *****************************************************************************
;                                InitWins
;                   inicializace (vytvo©en°) adres†©ovòch oken
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY=nedostatek pamàti
; neuchov†v† registry kromà DS
; *****************************************************************************
;˛
InitWins PROC      FAR

; ------ vytvo©en° levÇho adres†©ovÇho okna

         call      far ptr CreatAWn         ; vytvo©en° okna
         jc        InitWns2                 ; chyba pamàti
         mov       ds:[SegmLAdr],ax         ; á°slo segmentu
         mov       ds:[SegmL],ax            ; á°slo segmentu

; ------ nastaven° parametrñ okna

         mov       al,ds:[ParamLC]          ; parametry levÇho okna
         mov       es:[AWinPrm2],al         ; nastaven° parametrñ okna
         xor       si,si                    ; maska levÇho okna
         call      InitWinM                 ; inicializace masky okna

; ------ vytvo©en° pravÇho adres†©ovÇho okna

         call      far ptr CreatAWn         ; vytvo©en° okna
InitWns2:jc        InitWns9                 ; chyba pamàti
         mov       ds:[SegmRAdr],ax         ; á°slo segmentu
         mov       ds:[SegmR],ax            ; á°slo segmentu

; ------ nastaven° parametrñ okna

         mov       al,ds:[ParamRC]          ; parametry pravÇho okna
         mov       es:[AWinPrm2],al         ; nastaven° parametrñ okna
         mov       si,100h                  ; maska pravÇho okna
         call      InitWinM                 ; inicializace masky okna

; ------ aktualizace nastaven° parametrñ oken

         push      cs
         call      near ptr AktIWin         ; aktualizace nastaven° oken

; ------ adresa neaktivn°ho okna

         mov       ax,ds:[SegmNAkt]         ; segment neaktivn°ho okna
         call      far ptr GetDat           ; adresa neaktivn°ho okna

; ------ kontrola, zda je v cestà ud†n disk (= povinnÇ)

         mov       si,offset NWinPath       ; neaktivn° adres†©
         mov       cx,ds:[NWinPthN]         ; dÇlka neaktivn°ho adres†©e
         cmp       cl,3                     ; minim†ln° dÇlka adres†©e
         jb        InitWns6                 ; adres†© nezad†n
         cmp       byte ptr ds:[si+1],":"   ; je zad†n disk ?
         jne       InitWns6                 ; nen° zad†n disk - chyba

; ------ kontrola, zda je zad†n platnò disk

         mov       al,ds:[si]               ; oznaáen° disku
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         sub       al,"A"                   ; á°slo disku
         cmp       al,DiskMax               ; je á°slo disku OK ?
         jae       InitWns6                 ; neplatnÇ á°slo disku
         mov       ah,0
         xchg      ax,di                    ; DI <- á°slo disku
         cmp       byte ptr ds:[di+DiskITab],0 ; zad†n platnò disk ?
         je        InitWns6                 ; nen° platnò disk

; ------ p©enesen° cesty do neaktivn°ho okna

         mov       es:[AWinDNum],cx         ; dÇlka textu adres†©e
         inc       cx                       ; váetnà koncovÇ 0
         mov       di,AWinDir               ; buffer adres†©e
InitWns5:cld
         lodsb                              ; naáten° znaku
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         cld
         stosb                              ; uloëen° znaku
         loop      InitWns5                 ; dal®° znak

; ------ oznaáen° disku

         mov       al,es:[AWinDir]          ; aktivn° disk
         sub       al,"A"                   ; korekce na á°slo disku
         mov       es:[AWinDisk],al         ; aktivn° disk
InitWns6:clc                                ; p©°znak operace OK

; ------ zru®en° segmentu masek

InitWns9:pushf
         mov       ax,ds:[SegmMWin]         ; segment masek
         call      far ptr DelSeg           ; zru®en° segmentu masek
         mov       ds:[SegmMWin],ax

; ------ aktualizace cesty v neaktivn°m oknà, je-li to jinò disk

         call      far ptr TestNAWn         ; je neaktivn° okno zapnuto ?
         jc        InitWnsA                 ; neaktivn° okno nen° zapnuto
         call      far ptr GetAAWin         ; poskytnut° aktivn°ho okna
         mov       al,es:[AWinDisk]         ; disk okna
         call      far ptr GetNAWin         ; poskytnut° neaktivn°ho okna
         cmp       al,es:[AWinDisk]         ; je to stejnò disk ?
         je        InitWnsA                 ; je to stejnò disk

         mov       si,offset AWinDir        ; adres†© neaktivn°ho okna
         call      far ptr SetDir           ; nastaven° adres†©e okna

;         mov       al,es:[AWinDisk]         ; poëadovanò disk
;         mov       di,offset AWinDir        ; adres†© okna
;         call      far ptr GetDir           ; naáten° adres†©e
;         jc        InitWnsA                 ; chyba
;         mov       es:[AWinDNum],cx         ; dÇlka adres†©e
InitWnsA:popf
         ret

InitWins ENDP

; -----------------------------------------------------------------------------
;        inicializace masky okna (adresa ES, offset masky SI)
; -----------------------------------------------------------------------------

InitWinM PROC      NEAR

; ------ adresa segmentu masky -> DX

         mov       ax,ds:[SegmMWin]         ; segment masky
         call      far ptr GetSgAdr         ; adresa segmentu masky
         jc        InitWnM9

; ------ rozbor zad†n° masky

         push      es                       ; adresa okna
         push      ds

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       ds,dx                    ; DS <- segment bufferu
         mov       di,offset LinBuff        ; buffer ©†dku
         cld
         mov       cx,256/2
         rep       movsw                    ; p©enos textu do bufferu

         pop       ds
         mov       byte ptr ds:[LinNum],255 ; dÇlka textu
         call      far ptr Rozbor           ; rozbor zad†n° masky
         pop       es

; ------ p©enesen° masky do okna

         call      far ptr AWMOMsk          ; p©enesen° definice do okna
InitWnM9:ret

InitWinM ENDP

;; -----------------------------------------------------------------------------
;;        vytvo©en° okna (typ DL, ukazatel BX)
;; -----------------------------------------------------------------------------
;
;CreaIWin PROC      NEAR
;
;         call      far ptr CreatAWn         ; vytvo©en° okna
;         jnc       CreaIWn1
;         pop       ax                       ; zru®en° n†vratovÇ adresy
;         jmp       short InitWns9
;
;CreaIWn1:mov       ds:[bx],ax               ; segment okna
;         mov       es:[AWinPrm1],dl         ; typ okna
;
;         inc       bx
;         inc       bx                       ; zvò®en° ukazatele
;
;         shl       dl,1                     ; zvò®en° typu
;         ret
;
;CreaIWin ENDP

; -----------------------------------------------------------------------------
;        naáten° velikost° adres†©ñ ze stromu (okno AX)
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) adresa okna
;                   SS:[BP-4] (2) segment okna
;                   SS:[BP-6] (2) identifik†tor souboru $DOSMAN$.TRE
;                   SS:[BP-8] (2) segment datovÇho bufferu
;                   SS:[BP-10] (2) adresa datovÇho bufferu
;                   SS:[BP-12] (2) velikost datovÇho bufferu
;                   SS:[BP-14] (2) poáet bajtñ v datovÇm bufferu
;                   SS:[BP-16] (2) ukazatel adresy v bufferu
;                   SS:[BP-17] (1)
;                   SS:[BP-18] (1) hladina naá°tanòch poloëek
;                   SS:[BP-20] (2)
;                   SS:[BP-32] (12) buffer FCB jmÇna poloëky
;                              (256) buffer pro cestu
; -----------------------------------------------------------------------------

DirSumm  PROC      FAR

; ------ test, zda m† bòt operace prov†dàna

         test      byte ptr ds:[WindPar2],bit6   ; naá°t† se velikost adres†©ñ ?
         jnz       DirSumm1                 ; naá°t† se velikost adres†©ñ
         ret

; ------ £schova registrñ

DirSumm1:push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp
         sub       sp,32+256

; ------ p©°prava lok†ln°ch promànnòch

         mov       ss:[bp-4],ax             ; segment okna
         call      far ptr GetDat           ; adresa okna -> ES
         mov       ss:[bp-2],es             ; adresa okna

; ------ vytvo©en° datovÇho bufferu (ukazatel nen° pot©eba inicializovat)

         mov       bx,600                   ; asi tak minim†ln° velikost bufferu
         call      far ptr CreatDat         ; vytvo©en° datovÇho bufferu
         jnc       DirSum12                 ; buffer vytvo©en OK
         jmp       DirSumm9                 ; nedostatek pamàti

DirSum12:mov       ss:[bp-8],ax             ; segment datovÇho bufferu
         call      far ptr GetDat           ; adresa datovÇho bufferu
         mov       ss:[bp-10],es            ; adresa datovÇho bufferu
         mov       word ptr ss:[bp-14],0    ; v bufferu nejsou ë†dn† data

; ------ zarovn†n° velikosti bufferu na FileTSum

         mov       ax,FileTSum              ; velikost jednÇ poloëky
         xchg      ax,bx                    ; AX <- velikost bufferu
         xor       dx,dx                    ; DX <- 0
         div       bx                       ; poáet poloëek v bufferu
         mul       bx                       ; zarovnan† velikost bufferu
         mov       ss:[bp-12],ax            ; velikost datovÇho bufferu

; ------ sestaven° jmÇna souboru $DOSMAN$.TRE do bufferu

         mov       si,offset FileNTre       ; soubor "$DOSMAN$.TRE"
         xor       di,di                    ; poá†tek v bufferu
         call      far ptr TempFile         ; sestaven° jmÇna souboru

; ------ otev©en° souboru pro áten°

         xor       si,si                    ; jmÇno souboru
         call      far ptr OpenR            ; otev©en° souboru pro áten°
         jc        DirSumm8                 ; soubor nenalezen
         mov       ss:[bp-6],ax             ; identifik†tor vstupn°ho souboru

; ------ nalezen° vòchoz°ho adres†©e

         call      DirSPth                  ; nalezen° poëadovanÇho adres†©e
         jc        DirSumm7                 ; adres†© nenalezen
         mov       ss:[bp-18],al            ; hladina naá°tanòch poloëek

; ------ nalezen° dal®°ho podadres†©e

DirSumm2:call      DirSNxt                  ; naáten° dal®°ho podadres†©e
         jc        DirSumm7                 ; nen° dal®° podadres†©
         mov       al,ss:[bp-18]            ; poëadovan† hladina
         cmp       al,es:[si+FileTLev]      ; je to spr†vn† hladina ?
         jb        DirSumm2                 ; vno©enò podadres†© se p©eskoá°
         ja        DirSumm7                 ; konec vàtve adres†©ñ

; ------ nalezen° podadres†©e v oknà -> BX

         mov       ax,ss:[bp-4]             ; segment okna
         call      far ptr SrcWNam          ; vyhled†n° poloëky v oknà
         jc        DirSumm2                 ; poloëka nenalezena - dal®°

; ------ souáet velikost° vàtve -> DX:CX (poloëka BX)

         mov       al,ss:[bp-18]            ; poëadovan† hladina
         xor       cx,cx                    ; st©adaá velikosti LOW
         xor       dx,dx                    ; st©adaá velikosti HIGH
DirSumm3:add       cx,word ptr es:[si+FileTSiz] ; p©iáten° velikosti adres†©e
         adc       dx,word ptr es:[si+FileTSiz+2]
         call      DirSNxt                  ; naáten° dal®°ho podadres†©e
         jc        DirSumm4                 ; nen° dal®° podadres†©
         cmp       al,es:[si+FileTLev]      ; je to podadres†© ?
         jb        DirSumm3                 ; je to vno©enò podadres†© OK
         sub       word ptr ss:[bp-16],FileTSum ; n†vrat poloëky pro p©°®tà

; ------ adresa aktualizovanÇ poloëky -> ES:DI

DirSumm4:mov       es,ss:[bp-2]             ; ES <- adresa okna
         call      far ptr GetPolDI         ; adresa poloëky -> ES:DI
         jc        DirSumm2                 ; neplatn† poloëka (?)
         test      byte ptr es:[di+FileAtr],DIR ; je to adres†© ?
         jz        DirSumm2                 ; nen° to adres†©
         mov       word ptr es:[di+FileSize],cx ; velikost poloëky
         mov       word ptr es:[di+FileSize+2],dx
         jmp       short DirSumm2           ; dal®° poloëka

; ------ uzav©en° vstupn°ho souboru

DirSumm7:mov       ax,ss:[bp-6]             ; identifik†tor souboru
         call      far ptr ClosFile         ; uzav©en° souboru

; ------ zru®en° datovÇho bufferu

DirSumm8:mov       ax,ss:[bp-8]             ; segment datovÇho bufferu
         call      far ptr DelSeg           ; zru®en° datovÇho bufferu

; ------ n†vrat registrñ

DirSumm9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      far ptr AktSelct         ; aktualizace vòbàru poloëek
         ret

DirSumm  ENDP

; -----------------------------------------------------------------------------
; nalezen° poëadovanÇho adres†©e ve stromu -> CY=adres†© nenalezen, AL=hladina+1
; -----------------------------------------------------------------------------

DirSPth  PROC      NEAR

; ------ adresa bufferu v z†sobn°ku -> DI

         mov       di,sp                    ; DI <- buffer v z†sobn°ku
         inc       di
         inc       di                       ; p©eskoáen° n†vratovÇ adresy

; ------ £schova cesty okna do z†sobn°ku

         push      di
         push      ds

         mov       ds,ss:[bp-2]             ; adresa okna
         push      ss
         pop       es                       ; ES <- adresa bufferu
         mov       si,AWinDir               ; adres†© okna
         mov       cx,256/2                 ; dÇlka cesty
         cld
         rep       movsw                    ; £schova cesty do z†sobn°ku

         pop       ds
         pop       di

; ------ p©°prava k vyhled†n° poëadovanÇho adres†©e (DI=zaá†tek cesty)

         mov       al,0                     ; ukazatel hladiny (0=ROOT)

; ------ nalezen° zaá†tku dal®°ho podadres†©e

DirSPth1:mov       si,di                    ; SI <- zaá†tek podadres†©e
         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
DirSPth2:cmp       byte ptr es:[di],0       ; je konec cesty ?
         je        DirSPth3                 ; je konec cesty
         inc       di                       ; zvò®en° ukazatele
         cmp       byte ptr es:[di-1],"\"   ; je to dal®° podadres†© ?
         jne       DirSPth2                 ; nalezen° dal®°ho podadres†©e
DirSPth3:cmp       si,di                    ; je to konec cesty ?
         je        DirSPth9                 ; je konec cesty - v®e OK

; ------ dek¢dov†n° dal®°ho podadres†©e na tvar FCB (ES=SS, SI=jmÇno ASCII)

         push      di
         push      ds

         push      ss
         pop       ds                       ; DS <- segment z†sobn°ku
         lea       di,[bp-32]               ; buffer FCB jmÇna poloëky
         call      far ptr AsciFCB          ; dek¢dov†n° na jmÇno FCB

; ------ oprava poloëky pro ROOT

         cmp       byte ptr ds:[di+1],":"   ; je to ROOT ?
         jne       DirSPth4                 ; nen° to ROOT
         mov       byte ptr ds:[di+2],"\"   ; oprava pro ROOT

DirSPth4:pop       ds
         pop       di

; ------ naáten° dal®° poloëky -> ES:SI

DirSPth5:call      DirSNxt                  ; naáten° dal®° poloëky
         jc        DirSPth8                 ; nen° dal®° poloëka - nenalezeno

; ------ test, zda je to poëadovan† hladina poloëky

         cmp       al,es:[si+FileTLev]      ; je to hledan† hladina ?
         jb        DirSPth5                 ; je to podadres†© - dal®°
         ja        DirSPth8                 ; konec vàtve - nenalezeno

; ------ porovn†n° jmÇna poloëky

         push      di
         push      ds

         push      ss
         pop       ds                       ; DS <- segment poloëky FCB
         inc       si                       ; zaá†tek jmÇna poloëky
         mov       di,si                    ; DI <- zaá†tek jmÇna poloëky FCB
         lea       si,[bp-32]               ; jmÇno podcesty FCB
         mov       cx,11                    ; dÇlka textu
         cld
         repe      cmpsb                    ; porovn†n° jmÇna

         pop       ds
         pop       di
         jne       DirSPth5                 ; dal®° poloëka
         inc       ax                       ; zvò®en° ukazatele hladiny
         jmp       short DirSPth1           ; nalezena shodn† poloëka

DirSPth8:stc                                ; p©°znak chyby
DirSPth9:ret

DirSPth  ENDP

; -----------------------------------------------------------------------------
;        naáten° dal®° poloëky ze stromu (CY=nen° dal®° poloëka) -> ES:SI
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) adresa okna
;                   SS:[BP-4] (2) segment okna
;                   SS:[BP-6] (2) identifik†tor souboru $DOSMAN$.TRE
;                   SS:[BP-8] (2) segment datovÇho bufferu
;                   SS:[BP-10] (2) adresa datovÇho bufferu
;                   SS:[BP-12] (2) velikost datovÇho bufferu
;                   SS:[BP-14] (2) poáet bajtñ v datovÇm bufferu
;                   SS:[BP-16] (2) ukazatel adresy v bufferu
;                   SS:[BP-17] (1)
;                   SS:[BP-18] (1) hladina naá°tanòch poloëek
;                   SS:[BP-20] (2)
;                   SS:[BP-32] (12) buffer FCB jmÇna poloëky
;                              (256) buffer pro cestu
; -----------------------------------------------------------------------------

DirSNxt  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      di

; ------ zvò®en° ukazatele átec° adresy
; Nekontrolovat p©eteáen° 64KB - nestane se a mñëe bòt podteáeno pod 0 u navr†cenÇ poloëky

         mov       es,ss:[bp-10]            ; ES <- adresa datovÇho bufferu
         add       word ptr ss:[bp-16],FileTSum ; zvò®en° adresy v bufferu

; ------ test, zda je dal®° poloëka platn†

         mov       ax,ss:[bp-16]            ; adresa v bufferu
         add       ax,FileTSum              ; adresa konce poloëky
         jc        DirSNxt2                 ; p©eteáen°
         cmp       ax,ss:[bp-14]            ; je to platn† poloëka ?
         jbe       DirSNxt4                 ; je to platn† poloëka OK

; ------ naáten° dal®°ho bloku dat ze souboru
; P©edpokl†d† se, ëe velikost bufferu je zarovn†na na poloëky FileTSum
; a ëe i naá°t†n° proto prob°h† po celòch poloëk†ch.

DirSNxt2:xor       di,di                    ; offset ukl†dac° adresy
         mov       cx,ss:[bp-12]            ; velikost bufferu (bajtñ)
         mov       ax,ss:[bp-6]             ; identifik†tor vstupn°ho souboru
         call      far ptr ReadFile         ; naáten° bloku dat ze souboru
         mov       ss:[bp-14],cx            ; novò poáet bajtñ v bufferu
         mov       ss:[bp-16],di            ; nov† átec° adresa z bufferu
         cmp       cx,FileTSum              ; je dost dat ?
         jb        DirSNxt8                 ; nejsou dal®° data

; ------ je dal®° platn† poloëka

DirSNxt4:mov       si,ss:[bp-16]            ; adresa poloëky
         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

DirSNxt8:pop       di
         pop       cx
         pop       ax
         ret

DirSNxt  ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                  Obsluha zobrazen° adres†©ovòch oken
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; *****************************************************************************
;                            DispWAkt
;        podm°nànÇ zobrazen° oken (jen pokud je pot©eba zobrazen°)
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment (uchov†v† registr p©°znakñ !)
; *****************************************************************************

DispWAkt PROC      FAR

; ------ £schova registrñ

         pushf
         push      es

; ------ zobrazen° aktu†ln°ho okna

         push      cs
         call      near ptr GetAAWin        ; adresa aktivn°ho okna
         test      byte ptr es:[AWinPrm0],bit4 ; je pot©eba zobrazen° ?
         jz        DispWAk4                 ; nen° pot©eba zobrazen°
         push      cs
         call      near ptr DispAAWn        ; zobrazen° aktu†ln°ho okna

; ------ zobrazen° neaktu†ln°ho okna

DispWAk4:push      cs
         call      near ptr GetNAWin        ; adresa neaktivn°ho okna
         test      byte ptr es:[AWinPrm0],bit4 ; je pot©eba zobrazen° ?
         jz        DispWAk9                 ; nen° pot©eba zobrazen°
         push      cs
         call      near ptr DispNAWn        ; zobrazen° neaktu†ln°ho okna

; ------ n†vrat registrñ

DispWAk9:pop       es
         popf
         ret

DispWAkt ENDP

; *****************************************************************************
;                              DispNAWn
;                 zobrazen° neaktivn°ho adres†©ovÇho okna
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

DispNAWn PROC      FAR

         push      ax
         mov       ax,ds:[SegmNAkt]         ; neaktivn° okno
         push      cs
         call      near ptr DispAWin        ; zobrazen° neaktivn°ho okna
         pop       ax
         ret

DispNAWn ENDP

; *****************************************************************************
;                              DispAAWn
;                 zobrazen° aktivn°ho adres†©ovÇho okna
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

DispAAWn PROC      FAR

         push      ax
         mov       ax,ds:[SegmAkt]          ; aktivn° okno
         push      cs
         call      near ptr DispAWin        ; zobrazen° aktivn°ho okna
         pop       ax
         ret

DispAAWn ENDP

; *****************************************************************************
;                                 DispAWin
;                       zobrazen° adres†©ovÇho okna
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo pamàüovÇho bloku s definic°
;        DS=datovò segment
; *****************************************************************************

DispAWin PROC      FAR

; ------ test, zda je okno zapnuto

         push      cs
         call      near ptr TestAWin        ; test zobrazen° okna
         jnc       DispAWn1                 ; okno je zapnuto
         ret

; ------ £schova registrñ

DispAWn1:push      ax
         push      bx
         push      cx
         push      dx
         push      es

         xor       bx,bx                    ; hladina k zobrazen° okna

; ------ korekce oken, je-li mal† ®°©ka ©†dku

         mov       dl,0                     ; pozice levÇho okna
         cmp       byte ptr ds:[Pozic],80   ; je mÇnà pozic na ©†dek neë 80 ?
         jae       DispAW14                 ; poáet pozic na ©†dek je OK

         cmp       ax,ds:[SegmL]            ; je to levÇ okno ?
         je        DispAW12                 ; je to levÇ okno
         test      byte ptr ds:[WindPar],bit0 ; je aktivn° levÇ okno ?
         jz        DispAWn2                 ; je aktivn° pravÇ okno
DispAW11:jmp       DispAWnB                 ; okno se nezobraz°
DispAW12:test      byte ptr ds:[WindPar],bit0 ; je aktivn° levÇ okno ?
         jz        DispAW11                 ; je aktivn° pravÇ okno
         jmp       short DispAWn2

; ------ stanoven° poá†teán° pozice a ©†dku okna

DispAW14:mov       dl,ds:[Pozic]            ; poáet pozic na ©†dek
         shr       dl,1                     ; st©ed obrazovky
         cmp       ax,ds:[SegmL]            ; je to levÇ okno ?
         jne       DispAWn2                 ; nen° to levÇ okno
         sub       dl,40                    ; poá†teán° pozice levÇho okna
DispAWn2:mov       dh,0                     ; poá†teán° ©†dek oken bez menu
         test      byte ptr ds:[ParMenu],bit0 ; je trvalÇ menu ?
         jz        DispAWn3                 ; nen° trvalÇ menu
         mov       dh,1                     ; poá†teán° ©†dek p©i trvalÇm menu

; ------ p©°prava barev okna

DispAWn3:call      far ptr GetDat           ; poskytnut° adresy datovÇho bloku
         and       byte ptr es:[AWinPrm0],not bit4 ; nen° pot©eba zobrazen°

         push      ax
         push      bx

         xor       bx,bx
DispAW31:mov       al,ds:[bx+ColAWinT]
         mov       ds:[bx+ColXWinT],al
         inc       bx
         cmp       bl,4+FileTMax
         jb        DispAW31

         mov       ax,word ptr ds:[ColTWin1] ; strom
         mov       bx,word ptr ds:[ColTWin3]

         test      byte ptr es:[AWinPrm1],bit4 ; je strom ?
         jnz       DspAWn33                 ; je strom

         mov       ax,word ptr ds:[ColAWin1] ; adres†©e
         mov       bx,word ptr ds:[ColAWin3]

         test      byte ptr es:[AWinPrm1],bit5 ; je seznam ?
         jz        DspAWn33                 ; nen° seznam

         mov       ax,word ptr ds:[ColLWin1] ; seznam
         mov       bx,word ptr ds:[ColLWin3]

DspAWn33:mov       word ptr ds:[ColXWin1],ax ; aktivn° barva
         mov       word ptr ds:[ColXWin3],bx

         test      byte ptr es:[AWinPrm1],bit3   ; adres†© ?
         jnz       DspAWn34                 ; je
         xor       bx,bx
DispAW33:mov       ds:[bx+ColXWinT],al
         inc       bx
         cmp       bl,4+FileTMax
         jb        DispAW33

DspAWn34:
         pop       bx
         pop       ax

; ------ korekce poá†tku a kurzoru okna

         call      KorAWin                  ; korekce adres†©ovÇho okna

; ------ zobrazen° horn°ho okraje okna

         test      byte ptr ds:[ParMenu],bit0+bit3 ; je trvalÇ menu nebo vyp. ?
         jnz       DispAWn4                 ; je trvalÇ menu nebo vyp. menu
         test      byte ptr ds:[ParMenu],bit1 ; je hlavn° menu ?
         jnz       DispAWn5                 ; je hlavn° menu
DispAWn4:call      DispATop                 ; zobrazen° horn°ho ©†dku
DispAWn5:inc       dh                       ; adresa dal®°ho ©†dku

; ------ zobrazen° volnÇ a celkovÇ kapacity disku

         call      DispADsk                 ; zobrazen° informac° o disku
         inc       dh

; ------ zobrazen° poátu souborñ a obsazenÇ kapacity

         call      DispADir                 ; zobrazen° informac° o adres†©i
         inc       dh

; ------ zobrazen° cesty k aktivn°mu adres†©i

         call      DispAPth                 ; zobrazen° aktivn° cesty
         inc       dh

; ------ uráen° poátu ©†dkñ se soubory

         mov       ch,es:[AWinPrm2]         ; parametry
         and       ch,bit5+bit6             ; typ zobrazen° okna
         mov       cl,ds:[NumRows]          ; celkov† vò®ka okna
         sub       cl,5                     ; odeáten° bàënÇho z†hlav° a paty
         test      byte ptr es:[AWinPrm2],bit4 ; je stavovò ©†dek souboru ?
         jnz       DispAWn6                 ; nen° stavovò ©†dek soubory
         sub       cl,2                     ; odeáten° stavovÇho ©†dku

; ------ zobrazen° stromu

DispAWn6:test      byte ptr es:[AWinPrm1],bit4 ; je okno stromu ?
         jz        DispAW61                 ; nen° okno stromu
         call      far ptr DispTWn          ; zobrazen° okna stromu
         jmp       short DispAWn9

; ------ 1 sloupcovÇ (plnÇ) zobrazen° okna

DispAW61:test      byte ptr es:[AWinPrm1],bit5 ; je okno seznamu ?
         jnz       DispAW62                 ; je okno seznamu
         or        ch,ch                    ; je plnÇ zobrazen° okna ?
;         test      byte ptr es:[AWinPrm2],bit5+bit6 ; je plnÇ zobrazen° okna ?
         jnz       DispAWn7                 ; nen° plnÇ zobrazen° okna
DispAW62:call      DispA1Fl                 ; zobrazen° souborñ okna - 1 sloupec
         jmp       short DispAWn9

; ------ 3 sloupcovÇ (zkr†cenÇ) zobrazen° okna

DispAWn7:cmp       ch,1*bit5                ; je zkr†cenÇ zobrazen° okna ?
;         test      byte ptr es:[AWinPrm2],bit5 ; je 3 sloupcovÇ zobrazen° okna ?
;         jz        DispAWn8                 ; nen° zkr†cenÇ zobrazen°
         jne       DispAWn8                 ; nen° zkr†cenÇ zobrazen°
         call      DispA3Fl                 ; zkr†cenÇ zobrazen° souborñ
         jmp       short DispAWn9

; ------ komentovanÇ zobrazen° okna

DispAWn8:cmp       ch,2*bit5                ; je komentovanÇ zobrazen° ?
         jne       DispAW82                 ; nen° komentovanÇ zobrazen°
         call      DispAKFl                 ; komentovanÇ zobrazen° souborñ
         jmp       short DispAWn9

; ------ zobrazen° s dlouhòmi jmÇny

DispAW82:call      DispADFl                 ; zobrazen° s dlouhòmi jmÇny

; ------ zobrazen° stavovÇho ©†dku

DispAWn9:add       dh,cl                    ; ©†dek k zobrazen°
         test      byte ptr es:[AWinPrm2],bit4 ; je stavovò ©†dek souboru ?
         jnz       DispAWnA                 ; nen° stavovò ©†dek souboru
         call      DispASta                 ; zobrazen° stavovÇho ©†dku souboru
         add       dh,2                     ; dal®° ©†dek

; ------ zobrazen° koncovÇho ©†dku okna

DispAWnA:call      DispAEnd                 ; zobrazen° koncovÇ linky

; ------ n†vrat registrñ

DispAWnB:pop       es
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispAWin ENDP

; *****************************************************************************
;                                KorAWin
;                     Korekce poá†tku a kurzoru okna
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo datovÇho bloku okna
;        ES=segment definice okna
;        DS=datovò segment
; *****************************************************************************

KorAWin  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

; ------ uráen° poátu zobrazenòch souborñ -> CX, okraj SI

         mov       ch,0
         mov       cl,ds:[NumRows]          ; celkov† vò®ka okna
         sub       cl,5                     ; vnit©n° vò®ka okna
         test      byte ptr es:[AWinPrm2],bit4 ; je stavovò ©†dek ?
         jnz       KorAWin0                 ; nen° stavovò ©†dek
         dec       cx
         dec       cx                       ; odeáten° stavovÇho ©†dku
KorAWin0:xor       si,si                    ; rezerva pro okraje 0 ©†dkñ
         cmp       cl,3                     ; jsou alespo§ 3 ©†dky okna ?
         jb        KorAWin1                 ; jsou jenom 2 nebo 1 ©†dek
         inc       si                       ; rezerva 1 ©†dek pro okraje

; ------ up©esnàn° parametrñ pro 3-sloupcovÇ okno

KorAWin1:mov       al,es:[AWinPrm2]         ; parametry
         and       al,bit5+bit6             ; typ zobrazen°
         cmp       al,1*bit5                ; je 3-sloupcovÇ zobrazen° ?
         jne       KorAWin2                 ; nen° 3-sloupcovÇ zobrazen°
;         test      byte ptr es:[AWinPrm2],bit5 ; 3-sloupcovÇ okno ?
;         jz        KorAWin2                 ; nen° 3-sloupcovÇ okno
         mov       ax,cx                    ; vò®ka okna
         shl       cx,1                     ; vò®ka * 2
         add       cx,ax                    ; vò®ka * 3
         mov       si,1                     ; rezerva 1 poloëka

; ------ ostatn° parametry adres†©ovÇho okna

KorAWin2:mov       ax,es:[AWinKurz]         ; pozice kurzoru
         mov       bx,es:[AWinFrst]         ; prvn° zobrazen† poloëka
         mov       dx,es:[AWinSouN]         ; celkovò poáet souborñ v oknà

; ------ omezen° pozice kurzoru

         cmp       ax,dx                    ; je pozice kurzoru OK ?
         jb        KorAWin4                 ; pozice kurzoru je OK
         mov       ax,dx                    ; omezen° pozice kurzoru
         or        ax,ax                    ; jsou nàjakÇ poloëky ?
         jz        KorAWin3                 ; nejsou ë†dnÇ poloëky
         dec       ax                       ; á°slo posledn° poloëky
KorAWin3:mov       es:[AWinKurz],ax         ; opraven† pozice kurzoru

; ------ stanoven° maxim†ln°ho zaá†tku okna

KorAWin4:sub       dx,cx                    ; maxim†ln° zaá†tek okna
         jbe       KorAWin6                 ; je malò poáet ©†dkñ

; ------ ohraniáen° shora

         sub       ax,si                    ; rezerva na horn°m okraji
         jbe       KorAWin6                 ; je ©†dek 1 nebo 0 - je zaá†tek
         cmp       ax,bx                    ; je nad horn°m okrajem ?
         jb        KorAWin7                 ; je nad horn°m okrajem
         add       ax,si                    ; n†vrat kurzoru

; ------ ohraniáen° zdola

         inc       ax                       ; dal®° pozice
         add       ax,si                    ; rezerva 1 ©†dek
         sub       ax,cx                    ; korekce, pokud je pod doln°m okr.
         jbe       KorAWin5                 ; nen° je®tà pod doln°m okrajem
         cmp       ax,bx                    ; je pod doln°m okrajem ?
         jae       KorAWin7                 ; je pod doln°m okrajem
KorAWin5:mov       ax,bx                    ; pñvodn° zaá†tek
         jmp       short KorAWin7           ; je konec okna

; ------ je zaá†tek okna

KorAWin6:xor       ax,ax                    ; n†hradn° zaá†tek okna
         xor       dx,dx                    ; maxim†ln° zaá†tek okna

; ------ kontrola maxim†ln°ho zaá†tku

KorAWin7:cmp       ax,dx                    ; p©ekroáen maxim†ln° zaá†tek ?
         jbe       KorAWin8                 ; nen° p©ekroáen maxim†ln° zaá†tek
         xchg      ax,dx                    ; AX <- maxim†ln° zaá†tek

; ------ nastaven° novÇho zaá†tku okna

KorAWin8:mov       es:[AWinFrst],ax         ; novò poá†tek okna

; ------ n†vrat registrñ

KorAWin9:pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

KorAWin  ENDP

; *****************************************************************************
;                               DispATop
;                 zobrazen° horn° linky adres†©ovÇho okna
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo datovÇho bloku okna
;        BX=hladina k zobrazen°
;        DL=poá†teán° pozice okna
;        DH=©†dek k zobrazen°
;        ES=segment definice okna
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) á°slo okna
;                   SS:[BP-4] (2) segment okna
; *****************************************************************************

DispATop PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp

; ------ p©°prava bufferu v z†sobn°ku

         sub       sp,2*40+4                ; vytvo©en° bufferu v z†sobn°ku
         mov       ss:[bp-2],ax             ; £schova á°sla okna
         mov       ss:[bp-4],es             ; segment okna

; ------ p©°prava podkladovÇ linky

         cld
         mov       di,sp                    ; buffer v z†sobn°ku
         push      ss
         pop       es                       ; ES <- SS segment bufferu
         mov       ah,ds:[ColXWin1]         ; bàën† barva okna
         mov       al,"…"                   ; "…" levò horn° roh
         stosw                              ; uloëen° levÇho horn°ho rohu
         mov       al,"Õ"                   ; "Õ" vodorovn† linka
         mov       cx,38                    ; dÇlka vodorovnÇ linky
         rep       stosw                    ; uloëen° vodorovnÇ linky
         mov       al,"ª"                   ; "ª" pravò horn° roh
         stosw                              ; uloëen° pravÇho horn°ho rohu

; ------ p©i malÇm poátu znakñ na ©†dek zobrazen° oznaáen° "L" nebo "R"

         cmp       byte ptr ds:[Pozic],80   ; je m†lo znakñ na ©†dek ?
         jae       DispAT02                 ; je dost znakñ na ©†dek
         mov       ax,ss:[bp-2]             ; á°slo datovÇho bloku okna
         cmp       ax,ds:[SegmR]            ; je to pravÇ okno ?
         mov       ah,ds:[ColXWin3]         ; barva kurzoru
         mov       al,"L"                   ; oznaáen° levÇho okna
         jne       DispATp0                 ; nen° to pravÇ okno
         mov       al,"R"                   ; oznaáen° pravÇho okna
DispATp0:mov       es:[di-2*40+2*2],ax      ; oznaáen° okna
         mov       al," "                   ; mezera
         mov       es:[di-2*40+1*2],ax      ; lev† mezera
         mov       es:[di-2*40+3*2],ax      ; prav† mezera
         mov       ah,ds:[ColXWin1]         ; bàën† barva okna
         jmp       DispATp1

; ------ zobrazen° indikace operace stromu

DispAT02:push      es
         mov       es,ss:[bp-4]             ; segment okna
         mov       al,es:[AWinPrm1]
         pop       es
         test      al,bit4                  ; je to strom ?
         jz        DspAT024                 ; nen° to strom
         test      al,bit1                  ; je strom naáten ?
         jnz       DispAT06                 ; strom je jië naáten
         mov       al,0
         mov       cl,"*"                   ; indik†tor naá°t†n° stromu
         jmp       short DspAT032

; ------ zobrazen° t©°dàn° v oknà

DspAT024:test      byte ptr ds:[WindPar2],bit1 ; zobraz° se t©°dàn° okna ?
         jz        DispAT06                 ; nezobraz° se t©°dàn° okna

         push      es
         mov       es,ss:[bp-4]             ; segment okna
         mov       al,es:[AWinPrm2]         ; t©°dàn° okna

         mov       cl,"N"                   ; net©°d° se
         test      al,bit0                  ; okno se net©°d° ?
         jnz       DispAT03                 ; okno se net©°d°

         mov       cl,"J"                   ; t©°dàn° podle jmÇna
         test      al,bit1+bit2             ; t©°d° se podle jmÇna ?
         jz        DispAT03                 ; t©°d° se podle jmÇna

         mov       cl,"P"                   ; t©°dàn° podle p©°pony
         test      al,bit2                  ; t©°d° se podle p©°pony ?
         jz        DispAT03                 ; t©°d° se podle p©°pony

         mov       cl,"V"                   ; t©°dàn° podle velikosti
         test      al,bit1                  ; t©°d° se podle velikosti ?
         jz        DispAT03                 ; t©°d° se podle velikosti

         mov       cl,"D"                   ; jinak t©°dàn° podle data a áasu

DispAT03:pop       es

DspAT032:push      di

         push      ax
         mov       ax,ss:[bp-2]             ; á°slo datovÇho bloku okna
         cmp       ax,ds:[SegmR]            ; je to pravÇ okno ?
         pop       ax
         je        DspAT034                 ; je to pravÇ okno
         add       di,2*33                  ; asi tak pozice k dek¢dov†n° textu

DspAT034:mov       byte ptr es:[di-2*40+2*2],"[" ; levò okraj

         test      al,bit3                  ; je sestupnÇ t©°dàn° ?
         jz        DispAT04                 ; nen° sestupnÇ t©°dàn°
         test      al,bit0                  ; t©°d° se okno ?
         jnz       DispAT04                 ; okno se net©°d°

         mov       byte ptr es:[di-2*40+3*2],"!" ; sestupnÇ t©°dàn°
         inc       di
         inc       di

DispAT04:mov       es:[di-2*40+3*2],cl      ; t©°dàn° okna
         mov       byte ptr es:[di-2*40+4*2],"]" ; pravò okraj

         pop       di

; ------ dek¢dov†n° data pro levÇ okno

DispAT06:push      ax
         mov       ax,ss:[bp-2]             ; á°slo datovÇho bloku okna
         cmp       ax,ds:[SegmL]            ; je to levÇ okno ?
         jne       DispAT08                 ; nen° to levÇ okno
         test      byte ptr ds:[ParInt24],bit3 ; je z†kaz bàhem INT 24h ?
         jnz       DispAT08                 ; je z†kaz bàhem INT 24h
         push      di
         sub       di,2*40-2                ; adresa k dek¢dov†n° data
         mov       ah,ds:[ColXWin3]         ; barva textu data
         call      far ptr DekDDate         ; dek¢dov†n° systÇmovÇho data
         pop       di
DispAT08:pop       ax

; ------ dek¢dov†n° textu jmÇna disku

DispATp1:push      ds
         test      byte ptr ds:[WindPar2],bit0 ; zobraz° se jmÇno disku ?
         jz        DispATp4                 ; jmÇno disku se nezobraz°
         mov       ds,ss:[bp-4]             ; segment definice okna
         mov       cl,ds:[AWinLabN]         ; dÇlka n†và®t° disku
         jcxz      DispATp4                 ; nen° n†và®t° disku
         push      cx
         inc       cx                       ; zaokrouhlen° nahoru
         and       cl,not bit0              ; zarovn†n° na sudou dÇlku
         sub       di,2*20+2                ; polovina bufferu ©†dku - 1 znak
         sub       di,cx                    ; poá†tek k dek¢dov†n° textu
         pop       cx
         mov       al," "                   ; £vodn° mezera
         stosw                              ; uloëen° £vodn° mezery
         mov       si,AWinLab               ; n†và®t° disku
DispATp2:lodsb                              ; znak n†và®t°
         stosw                              ; uloëen° znaku do bufferu
         loop      DispATp2                 ; dek¢dov†n° dal®°ho znaku
         mov       al," "                   ; koncov† mezera
         stosw                              ; uloëen° koncovÇ mezery
DispATp4:pop       ds

; ------ dek¢dov†n° systÇmovÇho áasu

         cmp       byte ptr ds:[Pozic],80   ; je mÇnà pozic na ©†dek neë 80 ?
         jb        DspATp42                 ; áas se zobraz° vëdy
         mov       ax,ss:[bp-2]             ; á°slo datovÇho bloku okna
         cmp       ax,ds:[SegmR]            ; je to pravÇ okno ?
         jne       DispATp5                 ; nen° to pravÇ okno
DspATp42:test      byte ptr ds:[ParMenu],bit0 ; je trvalÇ hlavn° menu ?
         jnz       DispATp5                 ; je trvalÇ hlavn° menu
         lea       di,ss:[bp-4-2*9]         ; adresa k dek¢dov†n° áasu
         mov       ah,ds:[ColXWin3]         ; barva textu áasu
         call      far ptr DekSTime         ; dek¢dov†n° systÇmovÇho áasu

; ------ zobrazen° ©†dku

DispATp5:mov       cl,40                    ; ®°©ka ©†dku k zobrazen°
         mov       si,sp                    ; adresa bufferu v z†sobn°ku
         mov       ax,bx                    ; hladina k zobrazen°
         call      far ptr DispMStr         ; zobrazen° ©†dku horn°ho okraje

; ------ n†vrat registrñ

         mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DispATop ENDP

; *****************************************************************************
;                                 DispADsk
;                      zobrazen° informac° o disku
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo datovÇho bloku okna
;        BX=hladina k zobrazen°
;        DL=poá†teán° pozice okna
;        DH=©†dek k zobrazen°
;        ES=segment definice okna
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) á°slo okna
;                   SS:[BP-4] (2) segment okna
;                   SS:[BP-6] (2) pozice a ©†dek k zobrazen°
;                   SS:[BP-8] (2) hladina k zobrazen°
; *****************************************************************************

DispADsk PROC      NEAR

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

; ------ p©°prava bufferu v z†sobn°ku

         sub       sp,2*50+2*40+8           ; vytvo©en° bufferu v z†sobn°ku
         mov       ss:[bp-2],ax             ; £schova á°sla okna
         mov       ss:[bp-4],es             ; segment okna
         mov       ss:[bp-6],dx             ; pozice a ©†dek k zobrazen°
         mov       ss:[bp-8],bx             ; hladina k zobrazen°

; ------ disk s nezn†mou kapacitou

         mov       di,sp                    ; buffer v z†sobn°ku
         mov       ax,word ptr es:[AWinDMax]         ; celkov† kapacita - LOW
         or        ax,word ptr es:[AWinDMax+2]       ; celkov† kapacita - HIGH
         jnz       DispADs1                 ; kapacita disku zn†m†
         push      ss
         pop       es
         mov       si,offset DskTxt14
         mov       ah,ds:[ColXWin1]         ; bàën† barva textu
         call      far ptr DekTText         ; dek¢dov†n° textu "-"
         jmp       short DispADs3

; ------ dek¢dov†n° £daje o volnÇ kapacità

DispADs1:mov       ax,word ptr es:[AWinDFre]         ; voln† kapacita - LOW
         mov       dx,word ptr es:[AWinDFre+2]       ; voln† kapacita - HIGH
         push      ss
         pop       es
         mov       bh,ds:[ColXWin2]         ; vysv°cen† barva textu
         mov       bl,ds:[OddelRad]         ; znak oddàlovaáe ©†dñ
         call      far ptr DekNum           ; dek¢dov†n° á°sla

; ------ dek¢dov†n° mezitextu

         call      far ptr TestKonc         ; test koncovky á°sla DX:AX
         mov       si,offset DskTxt10       ; text "B volnò z "
         jcxz      DispADs2                 ; je koncovka "1"
         mov       si,offset DskTxt11       ; text "B volnÇ z "
         dec       cx
         jz        DispADs2                 ; je koncovka "2" aë "4"
         mov       si,offset DskTxt12       ; jinak text "B volnòch z "
DispADs2:mov       ah,ds:[ColXWin1]         ; bàën† barva textu
         call      far ptr DekTText         ; dek¢dov†n° textu

; ------ dek¢dov†n° £daje o celkovÇ kapacità

         mov       es,ss:[bp-4]             ; segment okna
         mov       ax,word ptr es:[AWinDMax]         ; celkov† kapacita - LOW
         mov       dx,word ptr es:[AWinDMax+2]       ; celkov† kapacita - HIGH
         push      ss
         pop       es
         call      far ptr DekNum           ; dek¢dov†n° á°sla

; ------ inicializaán° vymaz†n° ©†dku

DispADs3:push      di
         lea       di,[bp-2*40-8]           ; buffer v z†sobn°ku
         cld
         mov       ah,ds:[ColXWin1]         ; bàën† barva textu
         mov       al,"∫"                   ; "∫" levò okraj
         stosw                              ; uloëen° levÇho okraje
         mov       al," "                   ; mezera
         mov       cx,38                    ; dÇlka ©†dku
         rep       stosw                    ; vymaz†n° ©†dku
         mov       al,"∫"                   ; "∫" pravò okraj
         stosw                              ; uloëen° pravÇho okraje
         pop       cx                       ; adresa konce textu

; ------ p©enesen° textu do bufferu

         mov       si,sp                    ; zaá†tek textu
         sub       cx,si                    ; dÇlka textu * 2
         shr       cx,1                     ; dÇlka textu
         cmp       cl,38
         jb        DispADs4
         mov       cl,38
DispADs4:lea       di,[bp-2*20-8]           ; buffer v z†sobn°ku
         mov       bx,cx                    ; dÇlka textu
         inc       bx                       ; zaokrouhlen° nahoru
         and       bl,not bit0              ; zarovn†n° na sudou adresu
         sub       di,bx                    ; adresa k uloëen° textu
         push      ds
         push      ss
         pop       ds
         rep       movsw                    ; p©enesen° textu
         pop       ds

; ------ zobrazen° textu

         mov       dx,ss:[bp-6]             ; ©†dek a pozice
         mov       cl,40                    ; dÇlka textu
         lea       si,[bp-2*40-8]           ; adresa bufferu
         mov       ax,ss:[bp-8]             ; hladina k zobrazen°
         call      far ptr DispKStr         ; zobrazen° ©†dku spodn°ho okraje

; ------ n†vrat registrñ

         mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispADsk ENDP

; *****************************************************************************
;                              DispADir
;                    zobrazen° informac° o adres†©i
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo datovÇho bloku okna
;        BX=hladina k zobrazen°
;        DL=poá†teán° pozice okna
;        DH=©†dek k zobrazen°
;        ES=segment definice okna
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) á°slo okna
;                   SS:[BP-4] (2) segment okna
;                   SS:[BP-6] (2) pozice a ©†dek k zobrazen°
;                   SS:[BP-8] (2) hladina k zobrazen°
; *****************************************************************************

DispADir PROC      NEAR

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

; ------ p©°prava bufferu v z†sobn°ku

         sub       sp,2*50+2*40+8           ; vytvo©en° bufferu v z†sobn°ku
         mov       ss:[bp-2],ax             ; £schova á°sla okna
         mov       ss:[bp-4],es             ; segment okna
         mov       ss:[bp-6],dx             ; pozice a ©†dek k zobrazen°
         mov       ss:[bp-8],bx             ; hladina k zobrazen°

; ------ inicializaán° vymaz†n° ©†dku

         push      ss
         pop       es
         lea       di,[bp-2*40-8]           ; buffer v z†sobn°ku
         cld
         mov       ah,ds:[ColXWin1]         ; bàën† barva textu
         mov       al,"∫"                   ; "∫" levò okraj
         stosw                              ; uloëen° levÇho okraje
         mov       al," "                   ; mezera
         mov       cx,38                    ; dÇlka ©†dku
         rep       stosw                    ; vymaz†n° ©†dku
         mov       al,"∫"                   ; "∫" pravò okraj
         stosw                              ; uloëen° pravÇho okraje

; ------ test, zda se zobraz° koment†©

         mov       di,sp                    ; buffer v z†sobn°ku
         mov       es,ss:[bp-4]             ; segment okna
         test      byte ptr es:[AWinPrm1],bit3 ; je adres†©ovÇ okno ?
         jz        DispADr5                 ; nen° adres†©ovÇ okno
         mov       al,es:[AWinPrm2]
         and       al,bit5+bit6
         cmp       al,2*bit5                ; je komentovanÇ zobrazen° ?
         jne       DispADr5                 ; nen° komentovanÇ okno
;         test      byte ptr es:[AWinPrm2],bit6 ; je komentovanÇ okno ?
;         jz        DispADr5                 ; nen° komentovanÇ okno
         mov       cx,es:[AWinKomD]         ; dÇlka nadpisu
         jcxz      DispADr5                 ; nen° nadpis
         mov       si,es:[AWinKomA]         ; adresa nadpisu
         mov       ax,es:[AWinKomS]         ; segment pozn†mek
         call      far ptr GetDat           ; adresa segmentu pozn†mek
         jc        DispADr5                 ; segment pozn†mek nen° definov†n
         cmp       cx,38
         jb        DispADr1                 ; dÇlka textu je OK
         mov       cx,38                    ; omezen° dÇlky textu

; ------ dek¢dov†n° textu nadpisu

DispADr1:cld
         mov       ah,ds:[ColXWin1]         ; bàën† barva textu
         push      ds
         push      es
         pop       ds                       ; DS <- segment textu
         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
DispADr2:lodsb
         stosw
         loop      DispADr2                 ; p©enesen° textu nadpisu
         pop       ds

; ------ p©enesen° textu do bufferu

         mov       si,sp                    ; zaá†tek textu
         sub       di,si                    ; dÇlka textu * 2
         mov       cx,di                    ; dÇlka textu * 2
         shr       cx,1                     ; dÇlka textu
         cmp       cl,38
         jb        DispADr3
         mov       cl,38
DispADr3:lea       di,[bp-2*20-8]           ; polovina ©†dku
         mov       bx,cx                    ; dÇlka textu
         inc       bx                       ; zarovn†n° nahoru
         and       bl,not bit0              ; zarovn†n° na sudou adresu
         sub       di,bx                    ; adresa k uloëen° textu
         cld
         push      ds
         push      ss
         pop       ds
         rep       movsw                    ; p©enesen° textu
         pop       ds

; ------ zobrazen° textu (bez k¢dov†n°)

         lea       si,[bp-2*40-8]           ; adresa bufferu
         mov       al,"∫"                   ; "∫" levò okraj
         mov       es:[si],al               ; levò okraj
         mov       al,"∫"                   ; "∫" pravò okraj
         mov       es:[si+2*39],al          ; pravò okraj
         mov       dx,ss:[bp-6]             ; ©†dek a pozice
         mov       cl,40                    ; dÇlka textu
         mov       ax,ss:[bp-8]             ; hladina k zobrazen°
         call      far ptr DispMStr         ; zobrazen° ©†dku spodn°ho okraje
         jmp       DispADr9

; ------ dek¢dov†n° £daje o poátu souborñ

DispADr5:mov       es,ss:[bp-4]             ; segment okna
         mov       ax,es:[AWinDFil]         ; poáet souborñ
         xor       dx,dx                    ; vy®®° slovo
         mov       bh,ds:[ColXWin2]         ; vysv°cen† barva textu
         mov       bl,0                     ; nen° oddàlovac° teáka
         push      ss
         pop       es
         call      far ptr DekNum           ; dek¢dov†n° á°sla

; ------ dek¢dov†n° mezitextu 1 ("souborñ zab°r†")

         call      far ptr TestKonc         ; test koncovky á°sla
         mov       si,offset DskTxt20       ; text pro koncovku "1"
         jcxz      DispADr6                 ; je koncovka "1"
         mov       si,offset DskTxt21       ; text pro koncovku "2" aë "4"
         dec       cx
         jz        DispADr6                 ; je koncovka "2" aë "4"
         mov       si,offset DskTxt22       ; jinak text pro ostatn° koncovky
DispADr6:mov       ah,ds:[ColXWin1]         ; bàën† barva textu
         call      far ptr DekTText         ; dek¢dov†n° textu

; ------ dek¢dov†n° £daje o zabranÇ kapacità

         mov       es,ss:[bp-4]             ; segment okna
         mov       ax,word ptr es:[AWinDSum]         ; zabran† kapacita - LOW
         mov       dx,word ptr es:[AWinDSum+2]       ; zabran† kapacita - HIGH
         mov       bh,ds:[ColXWin2]         ; vysv°cen† barva textu
         mov       bl,ds:[OddelRad]         ; znak oddàlovac° teáky
         push      ss
         pop       es
         call      far ptr DekNum           ; dek¢dov†n° á°sla-zabran† kapacita

; ------ dek¢dov†n° mezitextu 2 ("bajtñ")

         mov       si,offset DskTxt33       ; "B"
         mov       ah,ds:[ColXWin1]         ; bàën† barva textu
         call      far ptr DekTText         ; dek¢dov†n° textu

; ------ p©enesen° textu do bufferu

         mov       si,sp                    ; zaá†tek textu
         sub       di,si                    ; dÇlka textu * 2
         mov       cx,di                    ; dÇlka textu * 2
         shr       cx,1                     ; dÇlka textu
         cmp       cl,38
         jb        DispAd82
         mov       cl,38
DispAd82:lea       di,[bp-2*20-8]
         mov       bx,cx                    ; dÇlka textu
         inc       bx                       ; zaokrouhlen° nahoru
         and       bl,not bit0              ; zarovn†n° na sudou adresu
         sub       di,bx                    ; adresa k uloëen° textu
         cld
         push      ds
         push      ss
         pop       ds
         rep       movsw                    ; p©enesen° textu
         pop       ds

; ------ zobrazen° textu (s k¢dov†n°m)

         mov       dx,ss:[bp-6]             ; ©†dek a pozice
         mov       cl,40                    ; dÇlka textu
         lea       si,[bp-2*40-8]           ; adresa bufferu
         mov       ax,ss:[bp-8]             ; hladina k zobrazen°
         call      far ptr DispKStr         ; zobrazen° ©†dku spodn°ho okraje

; ------ n†vrat registrñ

DispADr9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispADir ENDP

; *****************************************************************************
;                                DispAPth
;                      zobrazen° cesty k adres†©i
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo datovÇho bloku okna
;        BX=hladina k zobrazen°
;        DL=poá†teán° pozice okna
;        DH=©†dek k zobrazen°
;        ES=segment definice okna
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) á°slo okna
;                   SS:[BP-4] (2) segment okna
;                   SS:[BP-6] (2) hladina k zobrazen°
; *****************************************************************************

DispAPth PROC      NEAR

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

; ------ p©°prava bufferu v z†sobn°ku

         sub       sp,2*40+6                ; vytvo©en° bufferu v z†sobn°ku
         mov       ss:[bp-2],ax             ; £schova á°sla okna
         mov       ss:[bp-4],es             ; segment okna
         mov       ss:[bp-6],bx             ; hladina k zobrazen°

; ------ uráen° celkovÇ dÇlky textu cesty, kter† by se màla zobrazit -> BX

         mov       bx,es:[AWinDNum]         ; dÇlka textu adres†©e
         test      byte ptr es:[AWinPrm1],bit3 ; je adres†©ovÇ okno ?
         jz        DispAPt2                 ; nen° adres†©ovÇ okno
         test      byte ptr es:[AWinFilP],bit6 + bit7 ; jsou v®echny soubory ?
         jz        DispAPt2                 ; jsou v®echny soubory
         add       bl,5                     ; p©iáten° textu "prog"
         test      byte ptr es:[AWinFilP],bit6 ; jsou programy ?
         jnz       DispAPt2                 ; jsou programy
         sub       bl,5                     ; n†vrat dÇlky textu
         cmp       byte ptr es:[AWinFilM],0 ; je maska ?
         je        DispAPt2                 ; nen° maska
         cmp       bl,3                     ; je ROOT ?
         jbe       DispAPt1                 ; je ROOT
         inc       bx                       ; p©iáten° oddàlovac°ho znaku "\"
DispAPt1:add       bl,es:[AWinFilM]         ; p©iáten° dÇlky prvn° masky

; ------ inicializace podkladovÇ linky

DispAPt2:cld
         mov       di,sp                    ; buffer v z†sobn°ku
         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         mov       ah,ds:[ColXWin1]         ; bàën† barva okna
         mov       al,"Ã"                   ; "Ã" levò okraj
         stosw                              ; uloëen° levÇho okraje
         push      di
         mov       al,"Õ"                   ; "Õ" vodorovn† linka
         mov       cx,38                    ; dÇlka vodorovnÇ linky
         rep       stosw                    ; uloëen° vodorovnÇ linky
         mov       al,"π"                   ; "π" pravò okraj
         stosw                              ; uloëen° pravÇho horn°ho rohu
         pop       di

; ------ adresa k dek¢dov†n° textu adres†©e

         mov       cl,38-2                  ; maxim†ln° ®°©ka ©†dku - 2 mezery
         sub       cx,bx                    ; poáet zbylòch znakñ
         jbe       DispAPt3                 ; text je p©°li® dlouhò
         and       cl,not bit0              ; zarovn†n° na sudou adresu
         add       di,cx                    ; poá†teán° adresa textu - st©edàn°

; ------ p©°prava barvy textu

DispAPt3:mov       ax,ss:[bp-2]             ; á°slo okna
         cmp       ax,ds:[SegmAkt]          ; je to aktivn° okno ?
         mov       ah,ds:[ColXWin3]         ; barva textu - aktivn° okno
         je        DispAPt4                 ; je to aktivn° okno
         mov       ah,ds:[ColXWin1]         ; barva textu - neaktivn° okno

; ------ dek¢dov†n° £vodn° mezery

DispAPt4:mov       al," "                   ; £vodn° mezera
         cld
         stosw                              ; uloëen° £vodn° mezery

; ------ dek¢dov†n° textu disku

         push      ds
         mov       ds,ss:[bp-4]             ; segment definice okna
         mov       si,AWinDir               ; text adres†©e
         lodsb
         stosw                              ; oznaáen° disku
         lodsb
         stosw                              ; oddàlovaá disku ":"
         lodsb
         stosw                              ; inicializaán° lom°tko "\"

; ------ p©i dlouhÇm textu oddàlovac° teáky

         mov       cx,bx                    ; dÇlka textu adres†©e
         sub       cl,3                     ; odeáten° textu disku na zaá†tku
         jz        DispAPt6                 ; je ROOT
         cmp       cl,40-4-3                ; je dlouhò text ?
         jbe       DispAPt5                 ; text je OK
         mov       al,"."
         stosw
         stosw
         stosw                              ; 3 oddàlovac° teáky
         sub       cx,40-4-3-3              ; p©es†hnut° dÇlky textu adres†©e
         add       si,cx                    ; posun zaá†tku textu
         mov       cx,40-4-3-3              ; zobraz° se zbytek - 30 znakñ

; ------ dek¢dov†n° textu adres†©e

DispAPt5:lodsb                              ; znak n†và®t°
         stosw                              ; uloëen° znaku do bufferu
         loop      DispAPt5                 ; dek¢dov†n° dal®°ho znaku

; ------ p©enos textu masky (CX=0)

DispAPt6:test      byte ptr ds:[AWinPrm1],bit3 ; je adres†©ovÇ okno ?
         jz        DispAPt9                 ; nen° adres†©ovÇ okno
         mov       cl,ds:[AWinFilP]         ; parametry
         test      cl,bit7                  ; je maska ?
         jz        DispAPt9                 ; nen° maska
         mov       cl,ds:[AWinFilM]         ; dÇlka textu masky
         jcxz      DispAPt9                 ; nen° maska
         mov       si,AWinFilF.AWinFilt              ; adresa filtru souborñ
         sub       di,cx
         sub       di,cx                    ; n†vrat konce cesty
         mov       byte ptr es:[di-2],"\"   ; znak oddàlovaáe cesty
DispAPt7:lodsb                              ; znak masky k zobrazen°
         call      far ptr DownCase         ; konverze na malÇ p°smeno
         stosw                              ; uloëen° znaku masky
         loop      DispAPt7                 ; dal®° znak textu masky
DispAPt9:pop       ds

; ------ n†hradn° text pro programy

         test      cl,bit6                  ; jsou programy ?
         jz        DispAPtA                 ; nejsou programy
         sub       di,5*2                   ; n†vrat ukazatele
         mov       si,offset DskTxtE        ; text "Prog"
         call      far ptr DekTText         ; dek¢dov†n° textu

; ------ dek¢dov†n° koncovÇ mezery

DispAPtA:mov       al," "                   ; koncov† mezera
         stosw                              ; uloëen° koncovÇ mezery

; ------ zobrazen° ©†dku

         mov       cl,40                    ; ®°©ka ©†dku k zobrazen°
         mov       si,sp                    ; adresa bufferu
         mov       ax,ss:[bp-6]             ; hladina k zobrazen°
         call      far ptr DispMStr         ; zobrazen° ©†dku spodn°ho okraje

; ------ n†vrat registrñ

         mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispAPth ENDP

; *****************************************************************************
;                                DispASta
;                     zobrazen° stavovÇho ©†dku souboru (2 ©†dky)
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo datovÇho bloku okna
;        BX=hladina k zobrazen°
;        DL=poá†teán° pozice k zobrazen°
;        DH=poá†teán° ©†dek k zobrazen°
;        ES=segment sefinice okna
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) á°slo datovÇho bloku okna
;                   SS:[BP-4] (2) segment okna
;                   SS:[BP-6] (2) ©†dek a pozice k zobrazen°
;                   SS:[BP-8] (2) hladina k zobrazen°
; *****************************************************************************

DispASta PROC      NEAR

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

; ------ vytvo©en° bufferu v z†sobn°ku

         sub       sp,2*40 + 8
         mov       ss:[bp-2],ax             ; á°slo datovÇho bloku okna
         mov       ss:[bp-4],es             ; adresa bloku okna
         mov       ss:[bp-6],dx             ; ©†dek a pozice okna
         mov       ss:[bp-8],bx             ; hladina k zobrazen°
         mov       bh,es:[AWinPrm2]         ; parametry okna
         and       bh,bit5+bit6             ; typ zobrazen°

; ------ dek¢dov†n° oddàlovac° linky

         cld
         test      byte ptr es:[AWinPrm1],bit4 ; je to strom ?

         push      ss
         pop       es
         mov       di,sp                    ; buffer v z†sobn°ku

         mov       ah,ds:[ColXWin1]         ; bàën† barva okna
         mov       al,"∫"                   ; "∫" levò okraj
         stosw                              ; uloëen° levÇho okraje

         mov       cx,38                    ; dÇlka vnit©n° linky
         jnz       DispASt3                 ; je strom

         cmp       bh,3*bit5                ; jsou dlouh† jmÇna ?
         je        DispASt3                 ; jsou dlouh† jmÇna

         mov       al,"ƒ"                   ; "ƒ" vodorovn† linka - jmÇno souboru
         mov       cl,12                    ; dÇlka linky pro jmÇno souboru
         rep       stosw                    ; uloëen° linky pro jmÇno souboru
         mov       al,"¡"                   ; "¡"
         stosw

         mov       cl,25                    ; dÇlka linky pro komentovanÇ okno
         cmp       bh,2*bit5                ; je komentovanÇ okno ?
         je        DispASt3                 ; je komentovanÇ okno
;         test      bh,bit6                  ; je komentovanÇ okno ?
;         jnz       DispASt3                 ; je komentovanÇ okno

         mov       bl,12                    ; dÇlka 3. linky (3.sloupec souborñ)
         mov       cl,12                    ; dÇlka 2. linky (2.sloupec souborñ)
         cmp       bh,1*bit5                ; je 3-sloupcovÇ zobrazen° ?
         je        DispASt2                 ; je 3-sloupcovÇ zobrazen°
;         test      bh,bit5                  ; je 3. sloupcovÇ zobrazen° ?
;         jnz       DispASt2                 ; je 3 sloupcovÇ okno

         mov       cl,10                    ; dÇlka linky pro velikost souboru
         mov       al,"ƒ"                   ; "ƒ" vodorovn† linka
         rep       stosw                    ; uloëen° vodorovnÇ linky
         mov       al,"¡"                   ; "¡"
         stosw

         mov       bl,5                     ; dÇlka linky pro áas/atrib. souboru
         mov       cl,8                     ; dÇlka linky pro datum souboru

DispASt2:mov       al,"ƒ"                   ; "ƒ" vodorovn† linka
         rep       stosw                    ; uloëen° p©edposledn° linky
         mov       al,"¡"                   ; "¡"
         stosw

         mov       cl,bl                    ; dÇlka posledn° linky
DispASt3:mov       al,"ƒ"                   ; "ƒ" vodorovn† linka
         rep       stosw                    ; uloëen° vodorovnÇ linky

         mov       al,"∫"                   ; "∫" pravò okraj
         stosw                              ; uloëen° pravÇho okraje

; ------ zobrazen° oddàlovac° linky

         mov       si,sp                    ; dek¢dovanò text linky
         mov       cl,40                    ; dÇlka textu
         mov       ax,ss:[bp-8]             ; hladina k zobrazen°
         call      far ptr DispMStr         ; zobrazen° ©†dku spodn°ho okraje

; ------ inicializaán° vymaz†n° ©†dku

         cld
         mov       di,sp                    ; buffer v z†sobn°ku
         mov       ah,ds:[ColXWin1]         ; bàën† barva textu
         mov       al,"∫"                   ; "∫" levò okraj
         stosw                              ; uloëen° levÇho okraje
         mov       al," "                   ; mezera
         mov       cl,38                    ; dÇlka ©†dku
         rep       stosw                    ; vymaz†n° ©†dku
         mov       al,"∫"                   ; "∫" pravò okraj
         stosw                              ; uloëen° pravÇho okraje

; ------ adresa poloëky pod kurzorem -> ES:SI

         mov       es,ss:[bp-4]             ; segment definice okna
         push      bx
         mov       bx,es:[AWinKurz]         ; poloëka pod kurzorem
         call      far ptr GetESPol         ; adresa poloëky
         pop       bx
         jc        DispASt8                 ; nen° platnÇ á°slo poloëky

; ------ p©°prava registrñ k dek¢dov†n°

         mov       ch,ds:[ColXWin1]         ; bàën† barva textu
         mov       di,sp                    ; DI <- buffer v z†sobn°ku
         inc       di
         inc       di
         push      ds                       ; £schova DS
         mov       dx,ds                    ; £schova datovÇho segmentu
         push      es
         push      ss
         pop       es                       ; ES <- segment bufferu
         pop       ds                       ; DS <- segment poloëky

; ------ dek¢dov†n° poloëky - cesta

         test      byte ptr ds:[si+FileAtr],ATRT ; je to platn† poloëka ?
         jnz       DispASt4                 ; je to platn† poloëka
         mov       ah,ch                    ; bàën† barva textu
         call      DekAPth                  ; dek¢dov†n° textu cesty
         jmp       short DispASt7

; ------ dek¢dov†n° dlouhÇho jmÇna souboru

DispASt4:cmp       bh,0                     ; je plnÇ jmÇno ?
         jnz       DispASt6                 ; nen° plnÇ jmÇno
         cmp       byte ptr ds:[si+FileLong],0 ; je dlouhÇ jmÇno ?
         je        DispASt6                 ; nen° dlouhÇ jmÇno

         push      ds
         mov       ds,ss:[bp-4]             ; segment definice okna
         test      byte ptr ds:[AWinPrm1],bit4 ; je to strom ?
         pop       ds
         jnz       DispASt6                 ; je to strom

         mov       ah,ch
         mov       cl,ds:[si+FileLong]      ; dÇlka dlouhÇho jmÇna
         add       si,FileLong+1
         mov       ch,0
         cmp       cl,38
         jbe       DispASt5
         mov       cl,37
         mov       byte ptr es:[di+2*37],"~"
DispASt5:lodsb
         stosw
         loop      DispASt5
         jmp       short DispASt7

; ------ dek¢dov†n° velikosti souboru (i pro adres†©)

DispASt6:push      word ptr ds:[si+FileAtr] ; £schova atributñ
         and       byte ptr ds:[si+FileAtr],not DIR ; zru®en° p©°znaku adres†©e
         push      cs
         call      near ptr DekASiz         ; dek¢dov†n° velikosti souboru
         pop       word ptr ds:[si+FileAtr] ; n†vrat atributñ

; ------ dek¢dov†n° data souboru

         add       di,2*2
         push      cs
         call      near ptr DekA4Dat        ; dek¢dov†n° data (rok 4 á°slice)

; ------ dek¢dov†n° áasu souboru

         add       di,2*2
         push      cs
         call      near ptr DekATms         ; dek¢dov†n° áasu souboru (+sekundy)

; ------ dek¢dov†n° atributñ souboru

         inc       di
         inc       di
         push      cs
         call      near ptr DekAAtr         ; dek¢dov†n° atributñ souboru
DispASt7:pop       ds

; ------ zobrazen° stavovÇho ©†dku

DispASt8:push      ss
         pop       es                       ; ES <- buffer v z†sobn°ku
         mov       si,sp                    ; buffer v z†sobn°ku
         mov       dx,ss:[bp-6]             ; ©†dek a pozice k zobrazen°
         inc       dh                       ; zvò®en° ukazatele ©†dku
         mov       cl,40                    ; dÇlka ©†dku k zobrazen°
         mov       ax,ss:[bp-8]             ; hladina k zobrazen°
         call      far ptr DispMStr         ; zobrazen° ©†dku spodn°ho okraje

; ------ n†vrat registrñ

         mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispASta ENDP

; *****************************************************************************
;                                 DispAEnd
;                      zobrazen° koncovÇ linky okna
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo segmentu definice okna
;        BX=hladina k zobrazen°
;        DL=poá†teán° pozice okna
;        DH=©†dek k zobrazen°
;        ES=segment definice okna
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) pozice a ©†dek k zobrazen°
;                   SS:[BP-4] (2) poáet oznaáenòch souborñ
;                   SS:[BP-6] (2) souáet kapacit oznaáenòch souborñ HIGH
;                   SS:[BP-8] (2) souáet kapacit oznaáenòch souborñ LOW
;                   SS:[BP-10] (2) á°slo segmentu definice okna
;                   SS:[BP-11] (1)
;                   SS:[BP-12] (1) parametry okna 1
;                                         bit 3: 1=adres†©ovÇ okno
;                                         bit 4: 1=okno stromu
;                                         bit 5: 1=okno seznamu
;                   SS:[BP-14] (2) hladina k zobrazen°
; *****************************************************************************

DispAEnd PROC      NEAR

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

; ------ inicializace lok†ln°ch promànnòch

         sub       sp,2*50 + 2*40 + 14      ; vytvo©en° bufferu v z†sobn°ku
         mov       ss:[bp-2],dx             ; pozice a ©†dek k zobrazen°
         mov       ss:[bp-10],ax            ; á°slo segmentu definice okna
         xchg      ax,dx                    ; DX <- £schova á°sla segmentu
         mov       ax,es:[AWinSNum]         ; poáet oznaáenòch souborñ
         mov       ss:[bp-4],ax             ; poáet oznaáenòch souborñ
         mov       ax,word ptr es:[AWinSSum]         ; souáet kapacit LOW
         mov       ss:[bp-8],ax             ; souáet kapacit LOW
         mov       ax,word ptr es:[AWinSSum+2]       ; souáet kapacit HIGH
         mov       ss:[bp-6],ax             ; souáet kapacit HIGH
         mov       al,es:[AWinPrm1]         ; parametry okna 1
         mov       ss:[bp-12],al            ; parametry okna 1
         mov       ss:[bp-14],bx            ; hladina k zobrazen°

; ------ p©°prava bufferu v z†sobn°ku

         cld
         push      ss
         pop       es                       ; segment bufferu
         lea       di,[bp-14-2*40]          ; buffer v z†sobn°ku

; ------ inicializaán° dek¢dov†n° linky

         mov       ah,ds:[ColXWin1]         ; bàën† barva textu
         mov       al,"»"                   ; "»" levò spodn° roh
         stosw                              ; uloëen° levÇho spodn°ho rohu
         push      di
         test      byte ptr ds:[WindPar],bit2 ; je nastaven° vò®ky oken ?
         jz        DispAEn1                 ; nen° nastaven° vò®ky oken
         mov       ah,ds:[ColXWin2]         ; vysv°cen† barva
DispAEn1:mov       al,"Õ"                   ; "Õ" vodorovn† linka
         mov       cx,38                    ; ®°©ka okna
         rep       stosw                    ; uloëen° vodorovnÇ linky
         mov       ah,ds:[ColXWin1]         ; bàën† barva textu
         mov       al,"º"                   ; "º" pravò spodn° roh
         stosw                              ; uloëen° pravÇho spodn°ho rohu
         pop       di

; ------ korekce pro DEMO

         push      ax
         test      byte ptr ds:[LicDPar0],bit4 ; je DEMO verze ?
         jz        DspAEn14                 ; nen° DEMO verze

         cmp       byte ptr ds:[Pozic],80   ; minim†lnà pozic na ©†dek
         jb        DspAEn14                 ; je mal† ®°©ka obrazovky
         test      byte ptr ds:[ParamL],bit0 ; levÇ okno vypnuto ?
         jz        DspAEn14                 ; levÇ okno vypnuto
         test      byte ptr ds:[ParamR],bit0 ; pravÇ okno vypnuto ?
         jz        DspAEn14                 ; pravÇ okno vypnuto

         mov       ah,ds:[HelpColK]         ; barva pro text "DEMO"
         cmp       dx,ds:[SegmR]            ; je to pravÇ okno ?
         je        DspAEn12                 ; je to pravÇ okno
         mov       al,"D"
         mov       word ptr es:[di+2*37],ax
         mov       al,"E"
         mov       word ptr es:[di+2*38],ax
         jmp       short DspAEn14

DspAEn12:mov       al,"M"
         mov       word ptr es:[di-2],ax
         mov       al,"O"
         mov       word ptr es:[di],ax

DspAEn14:pop       ax

; ====== je reëim nastaven° vò®ky oken

         test      byte ptr ds:[WindPar],bit2 ; je nastaven° vò®ky oken ?
         jz        DispAEn2                 ; nen° nastaven° vò®ky oken
         mov       ah,ds:[ColXWin3]         ; barva kurzoru
         or        ah,80h                   ; p©°znak blik†n° textu
         mov       al,18                    ; znak ®ipek
         mov       es:[di+2*19],ax          ; uloëen° indik†toru nastaven° vò®ky
         jmp       short DispAE26           ; zobrazen° ©†dku


; ====== je reëim rychlovyhled†v†n°

DispAEn2:cmp       dx,ds:[SegmAkt]          ; je to aktivn° okno ?
         jne       DispAEn5                 ; nen° to aktivn° okno
         test      byte ptr ds:[WindPar],bit3 ; je reëim rychlovyhled†v†n° ?
         jz        DispAEn5                 ; nen° reëim rychlovyhled†v†n°

; ------ vymaz†n° textu k zobrazen° rychlovyhled†v†n°

         add       di,2*19-2*7              ; poá†tek k dek¢dov†n° textu
         mov       cl,13                    ; dÇlka textu
         mov       ah,ds:[ColXWin2]         ; vysv°cen† barva
         mov       al," "
         stosw                              ; uloëen° znaku mezery
         push      di
         rep       stosw                    ; vymaz†n° bufferu
         pop       di

; ------ dek¢dov†n° textu rychlovyhled†v†n°

         mov       cl,ds:[QSrcNum]          ; poáet znakñ v bufferu
         jcxz      DispAE24                 ; nen° ë†dnò text
         mov       si,offset QSrcBuff       ; buffer rychlovyhled†v†n°
         mov       dl,8                     ; á°taá dÇlky jmÇna
DispAE21:lodsb                              ; naáten° znaku k zobrazen°
         call      far ptr DownCase         ; konverze na malÇ p°smeno
         stosw                              ; uloëen° znaku
         dec       dl                       ; á°taá dÇlky jmÇna
         jnz       DispAE23                 ; nen° p©echod na jmÇno
         mov       al,"."                   ; oddàlovac° teáka
         stosw                              ; uloëen° oddàlovac° teáky
DispAE23:loop      DispAE21                 ; dek¢dov†n° dal®°ho znaku

; ------ zobrazen° kurzoru pro rychlovyhled†v†n°

DispAE24:mov       dx,ss:[bp-2]             ; pozice a ©†dek k zobrazen°
         add       dl,20-6                  ; poá†teán° pozice pro kurzor
         add       dl,ds:[QSrcNum]          ; pozice konce textu
         cmp       byte ptr ds:[QSrcNum],8  ; je za oddàlovac° teákou ?
         jb        DispAE25                 ; nen° za oddàlovac° teákou
         inc       dx                       ; p©eskoáen° oddàlovac° teáky
DispAE25:call      far ptr SetKurz          ; nastaven° kurzoru
DispAE26:jmp       DispAEn8                 ; zobrazen° ©†dku

; ====== zobrazen° informac° o oznaáenòch souborech

; ------ test, zda jsou oznaáeny nàjakÇ soubory

DispAEn5:cmp       word ptr ss:[bp-4],0     ; jsou oznaáeny nàjakÇ soubory ?
         je        DispAE26                 ; nejsou oznaáeny ë†dnÇ soubory

; ------ £vodn° mezera

         mov       di,sp                    ; buffer v z†sobn°ku
         mov       al," "
         stosw

; ------ dek¢dov†n° £daje o kapacità oznaáenòch souborñ

         mov       ax,ss:[bp-8]             ; soubory velkem - LOW
         mov       dx,ss:[bp-6]             ; soubory celkem - HIGH
         mov       bh,ds:[ColXWin2]         ; vysv°cen† barva textu
         mov       bl,ds:[OddelRad]         ; oddàlovac° znak ©†dñ
         call      far ptr DekNum           ; dek¢dov†n° á°sla

; ------ dek¢dov†n° mezitextu 1 ("bajtñ")

         call      far ptr TestKonc         ; test koncovky á°sla
         mov       si,offset DskTxt30       ; text "bajt"
         jcxz      DispAE52                 ; je koncovka "1"
         mov       si,offset DskTxt31       ; text "bajty"
         dec       cx
         jz        DispAE52                 ; je koncovka "2" aë "4"
         mov       si,offset DskTxt32       ; jinak text "bajtñ"
DispAE52:mov       ah,ds:[ColXWin1]         ; bàën† barva textu
         call      far ptr DekTText         ; dek¢dov†n° textu

; ------ dek¢dov†n° mezitextu 2 ("v")

         push      ax
         mov       ax,ss:[bp-4]             ; poáet oznaáenòch souborñ
         mov       si,offset DskTxt40       ; text "v"
         cmp       ax,5000
         jae       DispAE54                 ; 5000 a v°ce = "v"
         cmp       ax,2000
         jae       DispAE53                 ; 2000 aë 4999 = "ve"
         cmp       ax,500
         jae       DispAE54                 ; 500 aë 1999 = "v"
         cmp       ax,100
         jae       DispAE53                 ; 100 aë 499 = "ve"
         cmp       al,50
         jae       DispAE54                 ; 50 aë 99 = "v"
         cmp       al,20
         jae       DispAE53                 ; 20 aë 49 = "ve"
         cmp       al,15
         jae       DispAE54                 ; 15 aë 19 = "v"
         cmp       al,12
         jae       DispAE53                 ; 12 aë 14 = "ve"
         cmp       al,5
         jae       DispAE54                 ; 5 aë 11 = "v"
         cmp       al,1
         jbe       DispAE54                 ; 0 aë 1 = "v"
                                            ; 2 aë 4 = "ve"
DispAE53:mov       si,offset DskTxt41       ; text "ve"
DispAE54:pop       ax
         call      far ptr DekTText         ; dek¢dov†n° textu

; ------ dek¢dov†n° £daje o poátu souborñ

         mov       ax,ss:[bp-4]             ; poáet oznaáenòch souborñ
         xor       dx,dx                    ; DX <- 0
         mov       bl,0                     ; nen° oddàlovaá ©†du
         call      far ptr DekNum           ; dek¢dov†n° á°sla

; ------ dek¢dov†n° mezitextu 3 ("souborech")

         call      far ptr TestKonc         ; test koncovky á°sla
         mov       si,offset DskTxt50       ; text "souboru"
         jcxz      DispAE55                 ; je koncovka "1"
         mov       si,offset DskTxt51       ; text "souborech"
DispAE55:test      byte ptr ss:[bp-12],bit4 ; je to okno stromu ?
         jz        DispAE56                 ; nen° to okno stromu
         mov       si,offset DskTxt52       ; text "adres†©i"
         jcxz      DispAE56                 ; je koncovka "1"
         mov       si,offset DskTxt53       ; text "adres†©°ch"
DispAE56:mov       ah,ds:[ColXWin1]         ; bàën† barva textu
         call      far ptr DekTText         ; dek¢dov†n° textu

; ------ p©enesen° textu do ©†dku

         mov       si,sp                    ; adresa zaá†tku textu
         mov       cx,di                    ; adresa konce textu
         sub       cx,si                    ; dÇlka textu v bufferu * 2
         shr       cx,1                     ; dÇlka textu v bajtech
         lea       di,[bp-14-2*20]          ; polovina bufferu v z†sobn°ku
         mov       bx,cx                    ; dÇlka textu
         inc       bx                       ; zaokrouhlen°
         and       bl,not bit0              ; zarovn†n° na sudou adresu
         sub       di,bx                    ; adresa k uloëen° textu
         push      ds
         push      ss
         pop       ds
         cld
         rep       movsw                    ; p©enos textu
         pop       ds

; ------ zobrazen° textu doln°ho ©†dku

DispAEn8:lea       si,[bp-14-2*40]          ; buffer v z†sobn°ku
         mov       dx,ss:[bp-2]             ; pozice a ©†dek k zobrazen°
         mov       cl,40                    ; dÇlka ©†dku
         mov       ax,ss:[bp-14]            ; hladina k zobrazen°
         call      far ptr DispKStr         ; zobrazen° ©†dku spodn°ho okraje

; ------ n†vrat registrñ

         mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispAEnd ENDP

; *****************************************************************************
;                                 DispA3Fl
;            Zkr†cenÇ zobrazen° souborñ v adres†©ovÇm oknà (3 sloupce)
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo datovÇho bloku okna
;        BX=hladina k zobrazen°
;        DL=poá†teán° pozice k zobrazen°
;        DH=poá†teán° ©†dek k zobrazen°
;        CL=poáet ©†dkñ k zobrazen°
;        ES=segment definice okna
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) á°slo okna
;                   SS:[BP-4] (2) segment okna
;                   SS:[BP-6] (2) pozice a ©†dek k zobrazen°
;                   SS:[BP-7] (1) á°taá poloëek na ©†dku
;                   SS:[BP-8] (1) á°taá ©†dkñ k zobrazen°
;                   SS:[BP-10] (2) aktivn° poloëka
;                   SS:[BP-12] (2) ukazatel á°sla poloëky
;                   SS:[BP-14] (2) posun á°sla poloëky mezi sloupci
;                   SS:[BP-16] (2) hladina k zobrazen°
;                   SS:[BP-18] (2) á°taá zaá†tku ukazatele
;                   SS:[BP-20] (2) á°taá konce ukazatele
;                   SS:[BP-22] (2) á°taá kurzoru v poli ukazatele
;                   SS:[BP-23] (1)   parametry
;                                        bit 0: 1=zobraz° se ukazatel
;                                        bit 1: 1=zobrazena horn° ®ipka
;                                        bit 2: 1=zapnuta á†st ukazatele
; *****************************************************************************
;˛
DispA3Fl PROC      NEAR

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

; ------ p©°prava bufferu v z†sobn°ku

         sub       sp,2*40 + 24             ; vytvo©en° bufferu v z†sobn°ku

; ------ p©°prava lok†ln°ch promànnòch

         mov       ss:[bp-2],ax             ; £schova á°sla okna
         mov       ss:[bp-4],es             ; segment okna
         mov       ss:[bp-6],dx             ; pozice a ©†dek k zobrazen°
         xor       ch,ch                    ; CH <- 0
         mov       ss:[bp-8],cl             ; á°taá ©†dkñ k zobrazen°
         mov       ss:[bp-16],bx            ; hladina k zobrazen°
         mov       ax,es:[AWinKurz]         ; poloëka s kurzorem
         mov       ss:[bp-10],ax            ; aktivn° poloëka
         mov       bx,es:[AWinFrst]         ; prvn° zobrazen† poloëka
         mov       ss:[bp-12],bx            ; ukazatel á°sla poloëky
         mov       ss:[bp-14],cx            ; poáet ©†dkñ = odsazen° sloupcñ

; ------ p©°prava ukazatele (BX=prvn° poloëka)

         mov       byte ptr ss:[bp-23],0     ; parametry
         mov       dx,ss:[bp-2]             ; á°slo okna
         cmp       dx,ds:[SegmAkt]          ; je to aktivn° okno ?
         jne       DispA3F1                 ; nen° to aktivn° okno

         test      byte ptr ds:[WindPar2],bit3 ; m† se li®ta zobrazit ?
         jz        DispA3F1                 ; nezobraz° se

         mov       dx,cx                    ; SI <- poáet zobrazenòch ©†dkñ
         shl       dx,1
         add       dx,cx                    ; DX <- poáet zobrazenòch poloëek
         mov       si,es:[AWinSouN]         ; poáet zobrazenòch poloëek celkem
         cmp       cl,4                     ; minim†ln° vò®ka okna
         jb        DispA3F1                 ; mal† vò®ka okna
         dec       cx
         dec       cx                       ; bez okrajñ
         mov       ax,es:[AWinKurz]         ; kurzor

         call      far ptr DekUkaz          ; dek¢dov†n° ukazatele
         jc        DispA3F1                 ; ukazatel se nezobraz°
         inc       bx
         mov       ss:[bp-18],bx            ; á°taá zaá†tku ukazatele
         inc       cx
         mov       ss:[bp-20],cx            ; á°taá konce ukazatele
         inc       dx
         mov       ss:[bp-22],dx            ; á°taá kurzoru

         or        byte ptr ss:[bp-23],bit0 ; ukazatel se zobraz°

; ------ p©°prava okrajñ pro jeden ©†dek

DispA3F1:push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku
         cld
         mov       di,sp                    ; buffer v z†sobn°ku
         mov       ah,ds:[ColXWin1]         ; bàën† barva textu
         mov       al,"∫"                   ; "∫" levò okraj
         stosw                              ; uloëen° levÇho okraje
         mov       al,"≥"                   ; "≥"
         mov       es:[di+12*2],ax
         mov       es:[di+12*2+2+12*2],ax
         mov       al,"∫"                   ; "∫" pravò okraj
         mov       es:[di+2*38],ax          ; uloëen° pravÇho okraje
         mov       bx,ss:[bp-12]            ; ukazatel á°sla poloëky
         mov       byte ptr ss:[bp-7],3     ; á°taá poloëek na ©†dku

; ------ vymaz†n° neplatnÇ poloëky

DispA3F2:mov       ah,ds:[ColXWin1]         ; bàën† barva textu
         mov       es,ss:[bp-4]             ; segment definice okna
         cmp       bx,es:[AWinSouN]         ; je to platn† poloëka ?
         push      ss
         pop       es                       ; ES <- segment bufferu
         jb        DispA3F3                 ; je to platn† poloëka OK
         mov       al," "
         mov       cx,12                    ; poáet mezer k vymaz†n°
         rep       stosw                    ; vymaz†n° pr†zdnÇ poloëky
         jmp       DispA3F7           ; dal®° poloëka

; ------ zobrazen° kurzorñ po stran†ch poloëky

DispA3F3:mov       al,ds:[ColXWin2]         ; vysv°cen† poloëka
         cmp       bx,ss:[bp-10]            ; je to aktivn° poloëka ?
         jne       DispA3F4                 ; nen° to aktivn° poloëka
         mov       cl,"∞"                   ; znak kurzoru
         mov       byte ptr es:[di-2],cl    ; "∞" znak kurzoru po levÇ stranà
         mov       byte ptr es:[di+2*12],cl ; "∞" znak kurzoru po pravÇ stranà
         mov       cx,ss:[bp-2]             ; á°slo okna
         cmp       cx,ds:[SegmAkt]          ; je to aktivn° okno ?
         mov       ch,al                    ; £schova vysv°cenÇ barvy
         jne       DispA3F4                 ; nen° to aktivn° okno
         mov       ah,ds:[ColXWin3]         ; barva kurzoru
         mov       al,ds:[ColXWin4]         ; vysv°cenò kurzor

         push      ds
         push      es
         mov       es,ss:[bp-4]             ; segment definice okna
         call      far ptr GetESPol         ; adresa poloëky
         jmp       short DispA3F5

; ------ rozli®en° vysv°cenÇ poloëky

DispA3F4:push      ds

         push      es
         mov       es,ss:[bp-4]             ; segment definice okna
         call      far ptr GetESPol         ; adresa poloëky

         push      bx
         mov       bl,es:[si+FileATyp]      ; typ poloëky
         mov       bh,0
         mov       ah,ds:[bx+ColXWinT]      ; barva poloëky
         cmp       bl,FileATU0+FileTMax
         pop       bx
         jb        DispA3F5
         mov       ah,ds:[ColXWin1]         ; bàën† barva textu

DispA3F5:mov       dx,"≤"*HI + "∞"          ; znak kurzoru a vysv°cen°
         push      es
         pop       ds                       ; DS <- segment poloëky
         pop       es                       ; ES <- segment bufferu

         test      byte ptr ds:[si+FileAtr],ATRO ; je to oznaáen† poloëka ?
         jz        DispA3F6                 ; nen° oznaáen† poloëka
         mov       ah,al                    ; barva oznaáenÇ poloëky
         mov       es:[di+12*2+1],ah        ; barva oznaáenÇ poloëky
         cmp       byte ptr es:[di+12*2],dl ; je kurzor ?
         mov       byte ptr es:[di+12*2],dh ; indik†tor oznaáenÇ poloëky
         jne       DispA3F6                 ; nen° kurzor
         mov       byte ptr es:[di+12*2+1],ch ; vysv°cen† barva
         mov       byte ptr es:[di+12*2],dl ; znak kurzoru

; ------ dek¢dov†n° jmÇna souboru

DispA3F6:pop       dx                       ; datovò segment
         push      dx

         push      cs
         call      near ptr DekAFil          ; dek¢dov†n° jmÇna souboru
         pop       ds

; ------ za®ifrov†n° pro DEMO verzi

         call      DekAFilS                 ; za®ifrov†n° poloëky

; ------ p©°prava pro dal®° poloëku

DispA3F7:add       bx,ss:[bp-14]            ; zvò®en° ukazatele poloëky
         inc       di
         inc       di                       ; p©eskoáen° oddàlovaáe sloupcñ
         dec       byte ptr ss:[bp-7]       ; sn°ëen° á°taáe sloupcñ
         jz        DispA3F8                 ; jsou jië v®echny 3 sloupce
         jmp       DispA3F2                 ; dal®° sloupec na ©†dku

; ------ zobrazen° jednoho ©†dku

DispA3F8:

; ------ dek¢dov†n° ukazatele

         test      byte ptr ss:[bp-23],bit0  ; zobraz° se ukazatel ?
         jz        DspA3F89                 ; ukazatel se nezobraz°

         mov       si,sp                    ; buffer v z†sobn°ku
         add       si,2*39                  ; posledn° znak v z†sobn°ku
;         mov       ah,ds:[ColXWin3]         ; barva kurzoru
         mov       ah,ds:[ColMnu1]
         mov       al,1eh                   ; ®ipka nahoru
         test      byte ptr ss:[bp-23],bit1  ; byla horn° ®ipka ?
         jz        DspA3F88                 ; nebyla je®tà horn° ®ipka
         mov       al,1fh                   ; ®ipka dolñ
         cmp       byte ptr ss:[bp-8],1     ; je posledn° ©†dek ?
         je        DspA3F88                 ; je posledn° ©†dek

         dec       word ptr ss:[bp-18]      ; á°taá zaá†tku ukazatele
         jnz       DspA3F83
         or        byte ptr ss:[bp-23],bit2  ; zapnut ukazatel
DspA3F83:dec       word ptr ss:[bp-20]      ; á°taá konce ukazatele
         jnz       DspA3F84
         and       byte ptr ss:[bp-23],not bit2 ; vypnut ukazatel

DspA3F84:mov       al,4                     ; znak kurzoru
         dec       word ptr ss:[bp-22]      ; á°taá kurzoru
         jz        DspA3F88                 ; je znak kurzoru

         mov       al,"≤"                   ; jinak plocha ukazatele
         test      byte ptr ss:[bp-23],bit2  ; ukazatel zapnut ?
         jz        DspA3F88
         mov       ah,ds:[ColMnu2]

DspA3F88:mov       es:[si],ax               ; uloëen° znaku
         or        byte ptr ss:[bp-23],bit1  ; zobrazena horn° ®ipka


DspA3F89:
         mov       si,sp                    ; buffer v z†sobn°ku
         mov       cl,40                    ; dÇlka textu ©†dku
         mov       dx,ss:[bp-6]             ; pozice a ©†dek k zobrazen°
         mov       ax,ss:[bp-16]            ; hladina k zobrazen°
         call      far ptr DispMStr         ; zobrazen° jednoho ©†dku

; ------ p©°prava k zobrazen° dal®°ho ©†dku

         inc       word ptr ss:[bp-12]      ; zvò®en° ukazatele poloëky
         inc       byte ptr ss:[bp-5]       ; zvò®en° ukazatele ©†dku
         dec       byte ptr ss:[bp-8]       ; sn°ëen° á°taáe ©†dkñ k zobrazen°
         jz        DispA3F9                 ; nen° dal®° ©†dek
         jmp       DispA3F1                 ; zobrazen° dal®°ho ©†dku

; ------ n†vrat registrñ

DispA3F9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispA3Fl ENDP

; -----------------------------------------------------------------------------
;        za®ifrov†n° pro DEMO verzi (DX=datovò segment, BX=á°slo poloëky)
; -----------------------------------------------------------------------------

DekAFilS PROC      NEAR

         push      ds
         mov       ds,dx                    ; DS <- datovò segment
         test      byte ptr ds:[LicDPar0],bit4 ; je DEMO verze ?
         pop       ds
         jz        DekAFlSX                 ; nen° DEMO verze

         cmp       bx,15                    ; maxim†ln° á°slo poloëky
         jb        DekAFlSX                 ; poloëka je OK

         push      cx
         push      di

         sub       di,2*12
         mov       cx,8
DekAFlS2:cmp       byte ptr es:[di]," "
         je        DekAFlS3
         mov       byte ptr es:[di],"*"
DekAFlS3:inc       di
         inc       di
         loop      DekAFlS2

         mov       cl,3
DekAFlS4:inc       di
         inc       di
         cmp       byte ptr es:[di]," "
         je        DekAFlS5
         mov       byte ptr es:[di],"*"
DekAFlS5:loop      DekAFlS4

         pop       di
         pop       cx

DekAFlSX:ret

DekAFilS ENDP

; *****************************************************************************
;                                 DispA1Fl
;             PlnÇ zobrazen° souborñ v adres†©ovÇm oknà (1 sloupec)
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo datovÇho bloku okna
;        BX=hladina k zobrazen°
;        DL=poá†teán° pozice okna
;        DH=©†dek k zobrazen°
;        CL=poáet ©†dkñ k zobrazen°
;        ES=segment definice okna
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) á°slo okna
;                   SS:[BP-4] (2) segment okna
;                   SS:[BP-6] (2) pozice a ©†dek k zobrazen°
;                   SS:[BP-7] (1)   parametry
;                                        bit 0: 1=zobraz° se ukazatel
;                                        bit 1: 1=zobrazena horn° ®ipka
;                                        bit 2: 1=zapnuta á†st ukazatele
;                   SS:[BP-8] (1) á°taá ©†dkñ k zobrazen°
;                   SS:[BP-10] (2) á°taá aktivn° poloëky
;                   SS:[BP-12] (2) ukazatel á°sla poloëky
;                   SS:[BP-14] (2) hladina k zobrazen°
;                   SS:[BP-16] (2) á°taá zaá†tku ukazatele
;                   SS:[BP-18] (2) á°taá konce ukazatele
;                   SS:[BP-20] (2) á°taá kurzoru v poli ukazatele
; *****************************************************************************
;˛
DispA1Fl PROC      NEAR

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

; ------ p©°prava bufferu v z†sobn°ku

         sub       sp,2*40 + 20             ; vytvo©en° bufferu v z†sobn°ku

; ------ p©°prava lok†ln°ch promànnòch

         mov       ss:[bp-2],ax             ; £schova á°sla okna
         mov       ss:[bp-4],es             ; segment okna
         mov       ss:[bp-6],dx             ; pozice a ©†dek k zobrazen°
         mov       ss:[bp-8],cl             ; á°taá ©†dkñ k zobrazen°
         mov       ss:[bp-14],bx            ; hladina k zobrazen°
         mov       ax,es:[AWinKurz]         ; poloëka s kurzorem
         mov       bx,es:[AWinFrst]         ; prvn° poloëka
         sub       ax,bx                    ; offset od prvn° poloëky
         inc       ax                       ; p©ednastaven° á°taáe kurzoru
         mov       ss:[bp-10],ax            ; á°taá aktivn° poloëky (kurzoru)
         mov       ss:[bp-12],bx            ; ukazatel á°sla poloëky

; ------ p©°prava ukazatele (BX=prvn° poloëka)

         mov       byte ptr ss:[bp-7],0     ; parametry
         mov       dx,ss:[bp-2]             ; á°slo okna
         cmp       dx,ds:[SegmAkt]          ; je to aktivn° okno ?
         jne       DispA1F1                 ; nen° to aktivn° okno

         test      byte ptr ds:[WindPar2],bit3 ; m† se li®ta zobrazit ?
         jz        DispA1F1                 ; nezobraz° se

         mov       ch,0                     ; CX = poáet zobrazenòch ©†dkñ
         mov       dx,cx                    ; SI <- poáet zobrazenòch ©†dkñ
         mov       si,es:[AWinSouN]         ; poáet zobrazenòch poloëek celkem
         cmp       cl,4                     ; minim†ln° vò®ka okna
         jb        DispA1F1                 ; mal† vò®ka okna
         dec       cx
         dec       cx                       ; bez okrajñ
         mov       ax,es:[AWinKurz]         ; kurzor

         call      far ptr DekUkaz          ; dek¢dov†n° ukazatele
         jc        DispA1F1                 ; ukazatel se nezobraz°
         inc       bx
         mov       ss:[bp-16],bx            ; á°taá zaá†tku ukazatele
         inc       cx
         mov       ss:[bp-18],cx            ; á°taá konce ukazatele
         inc       dx
         mov       ss:[bp-20],dx            ; á°taá kurzoru

         or        byte ptr ss:[bp-7],bit0  ; ukazatel se zobraz°

; ------ inicializaán° zobrazen° okrajñ ©†dku

DispA1F1:push      ss
         pop       es                       ; ES <- segmentu bufferu v z†sobn°ku
         mov       ch,0                     ; CH <- 0
         mov       di,sp                    ; buffer v z†sobn°ku
         push      ds
         cld
         mov       ah,ds:[ColXWin1]         ; bàën† barva textu
         mov       al,"∫"                   ; "∫" znak okraje
         stosw                              ; uloëen° levÇho okraje
         mov       al,"∫"
         mov       es:[di+2*38],ax          ; uloëen° pravÇho okraje

; ------ vymaz†n° ©†dku, je-li neplatn† poloëka

         mov       es,ss:[bp-4]             ; segment definice okna
         mov       bx,ss:[bp-12]            ; ukazatel á°sla poloëky
         cmp       bx,es:[AWinSouN]         ; je platnÇ á°slo poloëky ?
         jb        DispA1F2                 ; je platnÇ á°slo poloëky
         push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku
         mov       al," "                   ; mezera
         mov       cl,12                    ; poáet vnit©n°ch mezer pro soubor
         rep       stosw                    ; vymaz†n° ©†dku
         mov       bx,ax
         mov       al,"≥"                   ; znak "≥"
         stosw
         xchg      ax,bx                    ; znak " "
         mov       cl,10
         rep       stosw
         xchg      ax,bx                    ; znak "≥"
         stosw
         xchg      ax,bx                    ; znak " "
         mov       cl,8
         rep       stosw
         xchg      ax,bx                    ; znak "≥"
         stosw
         xchg      ax,bx                    ; znak " "
         mov       cl,5
         rep       stosw
         jmp       DispA1F8                 ; dal®° ©†dek

; ------ zobrazen° kurzoru (AH=bàën† barva)

DispA1F2:mov       al,ds:[ColXWin2]         ; vysv°cen† poloëka
         mov       ch,ds:[ColLWin5]         ; barva cesty bez kurzoru
         dec       word ptr ss:[bp-10]      ; sn°ëen° á°taáe aktivn° poloëky
         jnz       DispA1F3                 ; nen° to ©†dek s kurzorem
         push      ss
         pop       es
         mov       cl,"∞"                   ; znak kurzoru
         mov       byte ptr es:[di-2],cl    ; "∞" znak kurzoru
         mov       byte ptr es:[di+2*38],cl ; "∞" znak kurzoru
         mov       es,ss:[bp-4]             ; segment definice okna
         mov       dx,ss:[bp-2]             ; á°slo okna
         cmp       dx,ds:[SegmAkt]          ; je to aktivn° okno ?
         jne       DispA1F3                 ; nen° to aktivn° okno
         mov       ah,ds:[ColXWin3]         ; barva kurzoru
         mov       al,ds:[ColXWin4]         ; vysv°cenò kurzor
         mov       ch,ds:[ColLWin6]         ; barva cesty s kurzorem

         mov       dl,es:[AWinPrm2]
         call      far ptr GetESPol         ; adresa poloëky
         jmp       short DspA1F38

; ------ rozli®en° vysv°cenÇ poloëky (nen°-li platn† ATRT, to nevad°)

DispA1F3:mov       dl,es:[AWinPrm2]
         call      far ptr GetESPol         ; adresa poloëky

         push      bx
         mov       bl,es:[si+FileATyp]      ; typ poloëky
         mov       bh,0
         mov       ah,ds:[bx+ColXWinT]      ; barva poloëky
         cmp       bl,FileATU0+FileTMax
         pop       bx
         jb        DspA1F38
         mov       ah,ds:[ColXWin1]         ; bàën† barva textu

DspA1F38:test      byte ptr es:[si+FileAtr],ATRO ; je to oznaáen† poloëka ?
         jz        DispA1F4                 ; nen° oznaáen† poloëka
         mov       ah,al                    ; barva oznaáenÇ poloëky

; ------ p©°prava registrñ k dek¢dov†n°

DispA1F4:mov       bl,dl                    ; £schova parametrñ - atributy
         mov       dx,ds                    ; £schova datovÇho segmentu
         push      es
         pop       ds                       ; DS <- segment poloëky
         push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku

; ------ dek¢dov†n° textu cesty seznamu

         test      byte ptr ds:[si+FileAtr],ATRT ; je to platn† poloëka ?
         jnz       DspA1F46                 ; je to platn† poloëka
         mov       ah,ch                    ; barva cesty
         call      DekAPth                  ; dek¢dov†n° textu cesty
         jmp       short DispA1F8

; ------ dek¢dov†n° jmÇna souboru (DX=datovò segment)

DspA1F46:push      cs
         call      near ptr DekAFil         ; dek¢dov†n° jmÇna souboru

; ------ za®ifrov†n° pro DEMO verzi

         push      bx
         mov       bx,ss:[bp-12]            ; ukazatel á°sla poloëky
         call      DekAFilS                 ; za®ifrov†n° poloëky
         pop       bx

; ------ oddàlovac° á†ra nebo indik†tor oznaáenÇ poloëky

         cld
         test      byte ptr ds:[si+FileAtr],ATRO ; je to oznaáen† poloëka ?
         push      ds
         mov       ds,dx                    ; DS <- datovò segment
         mov       al,"≥"                   ; "≥" oddàlovac° á†ra
         jz        DispA1F5                 ; nen° to oznaáen† poloëka
         mov       al,"≤"                   ; "≤" indik†tor oznaáenÇ poloëky
DispA1F5:pop       ds
         stosw                              ; uloëen° znaku

; ------ dek¢dov†n° velikosti souboru

         push      cs
         call      near ptr DekASiz         ; dek¢dov†n° velikosti souboru
         cld
         push      ds
         mov       ds,dx
         mov       al,"≥"                   ; "≥"
         pop       ds
         stosw

; ------ dek¢dov†n° data souboru

         push      ax
         push      cs
         call      near ptr DekADat         ; dek¢dov†n° data souboru
         cld
         pop       ax
         stosw

; ------ dek¢dov†n° áasu souboru

         push      cs
         test      bl,bit7                  ; jsou zobrazeny atributy ?
         jz        DispA1F6                 ; zobraz° se áas
         call      near ptr DekAAtr         ; dek¢dov†n° atributñ souboru
         jmp       short DispA1F8
DispA1F6:call      near ptr DekATim         ; dek¢dov†n° áasu souboru

; ------ p©°prava pro dal®° ©†dek

DispA1F8:inc       word ptr ss:[bp-12]      ; zvò®en° ukazatele poloëky
         pop       ds

; ------ dek¢dov†n° ukazatele

         test      byte ptr ss:[bp-7],bit0  ; zobraz° se ukazatel ?
         jz        DspA1F89                 ; ukazatel se nezobraz°

         mov       si,sp                    ; buffer v z†sobn°ku
         add       si,2*39                  ; posledn° znak v z†sobn°ku
;         mov       ah,ds:[ColXWin3]         ; barva kurzoru
         mov       ah,ds:[ColMnu1]
         mov       al,1eh                   ; ®ipka nahoru
         test      byte ptr ss:[bp-7],bit1  ; byla horn° ®ipka ?
         jz        DspA1F88                 ; nebyla je®tà horn° ®ipka
         mov       al,1fh                   ; ®ipka dolñ
         cmp       byte ptr ss:[bp-8],1     ; je posledn° ©†dek ?
         je        DspA1F88                 ; je posledn° ©†dek

         dec       word ptr ss:[bp-16]      ; á°taá zaá†tku ukazatele
         jnz       DspA1F83
         or        byte ptr ss:[bp-7],bit2  ; zapnut ukazatel
DspA1F83:dec       word ptr ss:[bp-18]      ; á°taá konce ukazatele
         jnz       DspA1F84
         and       byte ptr ss:[bp-7],not bit2 ; vypnut ukazatel

DspA1F84:mov       al,4                     ; znak kurzoru
         dec       word ptr ss:[bp-20]      ; á°taá kurzoru
         jz        DspA1F88                 ; je znak kurzoru

         mov       al,"≤"                   ; jinak plocha ukazatele
         test      byte ptr ss:[bp-7],bit2  ; ukazatel zapnut ?
         jz        DspA1F88
         mov       ah,ds:[ColMnu2]

DspA1F88:mov       es:[si],ax               ; uloëen° znaku
         or        byte ptr ss:[bp-7],bit1  ; zobrazena horn° ®ipka

; ------ zobrazen° jednoho ©†dku

DspA1F89:mov       si,sp                    ; buffer v z†sobn°ku
         mov       cl,40                    ; dÇlka textu ©†dku
         mov       dx,ss:[bp-6]             ; pozice a ©†dek k zobrazen°
         mov       ax,ss:[bp-14]            ; hladina k zobrazen°
         call      far ptr DispMStr         ; zobrazen° textu

; ------ p©°prava k zobrazen° dal®°ho ©†dku

         inc       byte ptr ss:[bp-5]       ; zvò®en° ukazatele ©†dku
         dec       byte ptr ss:[bp-8]       ; sn°ëen° á°taáe ©†dkñ k zobrazen°
         jz        DispA1F9
         jmp       DispA1F1                 ; zobrazen° dal®°ho ©†dku

; ------ n†vrat registrñ

DispA1F9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispA1Fl ENDP

; *****************************************************************************
;                                 DispAKFl
;             Zobrazen° souborñ v adres†©ovÇm oknà - komentovanÇ
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo datovÇho bloku okna
;        BX=hladina k zobrazen°
;        DL=poá†teán° pozice k zobrazen° souborñ
;        DH=©†dek k zobrazen°
;        CL=poáet ©†dkñ k zobrazen°
;        ES=segment definice okna
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) á°slo datovÇho bloku okna
;                   SS:[BP-4] (2) segment okna
;                   SS:[BP-6] (2) pozice a ©†dek k zobrazen°
;                   SS:[BP-7] (1)
;                   SS:[BP-8] (1) á°taá ©†dkñ k zobrazen°
;                   SS:[BP-10] (2) á°taá aktivn° poloëky
;                   SS:[BP-12] (2) ukazatel á°sla poloëky
;                   SS:[BP-14] (2) segment koment†©ñ (0=nen°)
;                   SS:[BP-16] (2) hladina k zobrazen°
;                   SS:[BP-18] (2) á°taá zaá†tku ukazatele
;                   SS:[BP-20] (2) á°taá konce ukazatele
;                   SS:[BP-22] (2) á°taá kurzoru v poli ukazatele
;                   SS:[BP-23] (1)   parametry
;                                        bit 0: 1=zobraz° se ukazatel
;                                        bit 1: 1=zobrazena horn° ®ipka
;                                        bit 2: 1=zapnuta á†st ukazatele
; *****************************************************************************
;˛
DispAKFl PROC      NEAR

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

; ------ p©°prava bufferu v z†sobn°ku

         sub       sp,2*40 + 24             ; vytvo©en° bufferu v z†sobn°ku

; ------ p©°prava lok†ln°ch promànnòch

         mov       ss:[bp-2],ax             ; £schova á°sla okna
         mov       ss:[bp-4],es             ; segment okna
         mov       ss:[bp-6],dx             ; pozice a ©†dek k zobrazen°
         mov       ch,0
         mov       ss:[bp-8],cl             ; á°taá ©†dkñ k zobrazen°
         mov       ax,es:[AWinKurz]         ; poloëka s kurzorem
         mov       ss:[bp-16],bx            ; hladina k zobrazen°
         mov       bx,es:[AWinFrst]         ; prvn° poloëka
         sub       ax,bx                    ; offset kurzoru od prvn° poloëky
         inc       ax                       ; p©ednastaven° á°taáe kurzoru
         mov       ss:[bp-10],ax            ; á°taá aktivn° poloëky
         mov       ss:[bp-12],bx            ; ukazatel á°sla poloëky
         mov       word ptr ss:[bp-14],0    ; p©°znak, ëe koment†©e nejsou
         mov       ax,es:[AWinKomS]         ; á°slo segmentu pozn†mek
         call      far ptr GetSgAdr         ; poskytnut° adresy pozn†mek
         jc        DispAKF0                 ; nejsou pozn†mky
         mov       ss:[bp-14],dx            ; adresa segmentu pozn†mek

; ------ p©°prava ukazatele (BX=prvn° poloëka)

DispAKF0:mov       byte ptr ss:[bp-23],0     ; parametry
         mov       dx,ss:[bp-2]             ; á°slo okna
         cmp       dx,ds:[SegmAkt]          ; je to aktivn° okno ?
         jne       DispAKF1                 ; nen° to aktivn° okno

         test      byte ptr ds:[WindPar2],bit3 ; m† se li®ta zobrazit ?
         jz        DispAKF1                 ; nezobraz° se

         mov       dx,cx                    ; SI <- poáet zobrazenòch ©†dkñ
         mov       si,es:[AWinSouN]         ; poáet zobrazenòch poloëek celkem
         cmp       cl,4                     ; minim†ln° vò®ka okna
         jb        DispAKF1                 ; mal† vò®ka okna
         dec       cx
         dec       cx                       ; bez okrajñ
         mov       ax,es:[AWinKurz]         ; kurzor

         call      far ptr DekUkaz          ; dek¢dov†n° ukazatele
         jc        DispAKF1                 ; ukazatel se nezobraz°
         inc       bx
         mov       ss:[bp-18],bx            ; á°taá zaá†tku ukazatele
         inc       cx
         mov       ss:[bp-20],cx            ; á°taá konce ukazatele
         inc       dx
         mov       ss:[bp-22],dx            ; á°taá kurzoru

         or        byte ptr ss:[bp-23],bit0 ; ukazatel se zobraz°

; ------ inicializaán° zobrazen° okrajñ ©†dku (zde je CH=0)

DispAKF1:push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku
         mov       di,sp                    ; DI <- buffer v z†sobn°ku
         push      ds                       ; £schova DS
         cld
         mov       ah,ds:[ColXWin1]         ; bàën† barva textu
         mov       al,"∫"                   ; "∫" levò okraj
         stosw                              ; uloëen° levÇho okraje
         mov       al,"∫"                   ; pravò okraj
         mov       es:[di+2*38],ax          ; uloëen° pravÇho okraje

; ------ vymaz†n° ©†dku, je-li neplatn† poloëka

         mov       es,ss:[bp-4]             ; segment definice okna
         mov       bx,ss:[bp-12]            ; ukazatel á°sla poloëky
         cmp       bx,es:[AWinSouN]         ; je platnÇ á°slo poloëky ?
         jb        DispAKF2                 ; je platnÇ á°slo poloëky
         push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku
         mov       al," "                   ; mezera
         mov       cl,12                    ; poáet vnit©n°ch mezer pro soubor
         rep       stosw                    ; vymaz†n° ©†dku
         mov       al,"≥"                   ; "≥"
         stosw
         mov       cl,25                    ; dÇlka zbytku ©†dku
         jmp       DispAKF7                 ; dal®° ©†dek

; ------ zobrazen° kurzoru

DispAKF2:mov       al,ds:[ColXWin2]         ; vysv°cen† poloëka
         dec       word ptr ss:[bp-10]      ; sn°ëen° á°taáe aktivn° poloëky
         jnz       DispAKF3                 ; nen° to ©†dek s kurzorem
         push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku
         mov       cl,"∞"                   ; znak kurzoru
         mov       byte ptr es:[di-2],cl    ; "∞" znak kurzoru
         mov       byte ptr es:[di+2*38],cl ; "∞" znak kurzoru
         mov       dx,ss:[bp-2]             ; á°slo okna
         cmp       dx,ds:[SegmAkt]          ; je to aktivn° okno ?
         jne       DispAKF3                 ; nen° to aktivn° okno

         mov       ah,ds:[ColXWin3]         ; barva kurzoru
         mov       al,ds:[ColXWin4]         ; vysv°cenò kurzor
         mov       es,ss:[bp-4]             ; segment definice okna
         call      far ptr GetESPol         ; adresa poloëky
         jmp       short DspAKF35

; ------ rozli®en° vysv°cenÇ poloëky

DispAKF3:mov       es,ss:[bp-4]             ; segment definice okna
         call      far ptr GetESPol         ; adresa poloëky

         push      bx
         mov       bl,es:[si+FileATyp]      ; typ poloëky
         mov       bh,0
         mov       ah,ds:[bx+ColXWinT]      ; barva poloëky
         cmp       bl,FileATU0+FileTMax
         pop       bx
         jb        DspAKF35
         mov       ah,ds:[ColXWin1]         ; bàën† barva textu

DspAKF35:test      byte ptr es:[si+FileAtr],ATRO ; je to oznaáen† poloëka ?
         jz        DispAKF4                 ; nen° oznaáen† poloëka
         mov       ah,al                    ; barva oznaáenÇ poloëky

; ------ dek¢dov†n° jmÇna souboru

DispAKF4:mov       dx,ds                    ; £schova datovÇho segmentu
         push      es
         pop       ds                       ; DS <- segment poloëky
         push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku
         push      cs
         call      near ptr DekAFil         ; dek¢dov†n° jmÇna souboru

; ------ za®ifrov†n° pro DEMO verzi

         call      DekAFilS                 ; za®ifrov†n° poloëky

; ------ oddàlovac° á†ra nebo indik†tor oznaáenÇ poloëky

         cld
         test      byte ptr ds:[si+FileAtr],ATRO ; je to oznaáen† poloëka ?
         push      ds
         mov       ds,dx
         mov       al,"≥"                   ; "≥" oddàlovac° á†ra
         jz        DispAKF5                 ; nen° to oznaáen† poloëka
         mov       al,"≤"                   ; "≤" indik†tor oznaáenÇ poloëky
DispAKF5:pop       ds
         stosw                              ; uloëen° znaku

; ------ adresa koment†©e k souboru

         mov       cl,25                    ; dÇlka pro koment†©e
         mov       dx,ss:[bp-14]            ; segment koment†©ñ
         or        dx,dx                    ; je segment koment†©ñ ?
         jz        DispAKF7                 ; nejsou koment†©e

         push      ds
         push      ax
         mov       ax,ss:[bp-4]             ; segment definice okna
         mov       ds,ax                    ; segment definice okna
         mov       si,ss:[bp-12]            ; ukazatel á°sla poloëky
         shl       si,1                     ; á°slo poloëky * 2
         add       si,word ptr ds:[AWinKomI]         ; adresa v tabulce indexñ
         add       ax,word ptr ds:[AWinKomI+2]
         mov       ds,ax                    ; segment tabulky koment†©ñ
         mov       si,ds:[si]               ; adresa koment†©e
         pop       ax
         pop       ds

         or        si,si                    ; je koment†© ?
         jz        DispAKF7                 ; nen° koment†©
         mov       ds,dx                    ; segment koment†©e

; ------ dek¢dov†n° pozn†mky k souboru

DispAKF6:lodsb                              ; naáten° znaku pozn†mky
         cmp       al,0                     ; konec textu ?
         je        DispAKF7                 ; konec textu
         stosw                              ; uloëen° znaku do bufferu
         loop      DispAKF6                 ; dal®° znak

; ------ vymaz†n° zbytku ©†dku

DispAKF7:mov       al," "                   ; znak mezery
         rep       stosw                    ; vymaz†n° zbytku ©†dku
         inc       word ptr ss:[bp-12]      ; zvò®en° ukazatele poloëky
         pop       ds

; ------ dek¢dov†n° ukazatele

         test      byte ptr ss:[bp-23],bit0  ; zobraz° se ukazatel ?
         jz        DspAKF89                 ; ukazatel se nezobraz°

         mov       si,sp                    ; buffer v z†sobn°ku
         add       si,2*39                  ; posledn° znak v z†sobn°ku
;         mov       ah,ds:[ColXWin3]         ; barva kurzoru
         mov       ah,ds:[ColMnu1]
         mov       al,1eh                   ; ®ipka nahoru
         test      byte ptr ss:[bp-23],bit1  ; byla horn° ®ipka ?
         jz        DspAKF88                 ; nebyla je®tà horn° ®ipka
         mov       al,1fh                   ; ®ipka dolñ
         cmp       byte ptr ss:[bp-8],1     ; je posledn° ©†dek ?
         je        DspAKF88                 ; je posledn° ©†dek

         dec       word ptr ss:[bp-18]      ; á°taá zaá†tku ukazatele
         jnz       DspAKF83
         or        byte ptr ss:[bp-23],bit2  ; zapnut ukazatel
DspAKF83:dec       word ptr ss:[bp-20]      ; á°taá konce ukazatele
         jnz       DspAKF84
         and       byte ptr ss:[bp-23],not bit2 ; vypnut ukazatel

DspAKF84:mov       al,4                     ; znak kurzoru
         dec       word ptr ss:[bp-22]      ; á°taá kurzoru
         jz        DspAKF88                 ; je znak kurzoru

         mov       al,"≤"                   ; jinak plocha ukazatele
         test      byte ptr ss:[bp-23],bit2  ; ukazatel zapnut ?
         jz        DspAKF88
         mov       ah,ds:[ColMnu2]

DspAKF88:mov       es:[si],ax               ; uloëen° znaku
         or        byte ptr ss:[bp-23],bit1  ; zobrazena horn° ®ipka

; ------ zobrazen° jednoho ©†dku

DspAKF89:mov       si,sp                    ; buffer v z†sobn°ku
         mov       cl,40                    ; dÇlka ©†dku
         mov       dx,ss:[bp-6]             ; pozice a ©†dek k zobrazen°
         mov       ax,ss:[bp-16]            ; hladina k zobrazen°
         call      far ptr DispMStr         ; zobrazen° textu

; ------ p©°prava k zobrazen° dal®°ho ©†dku

         inc       byte ptr ss:[bp-5]       ; zvò®en° ukazatele ©†dku
         dec       byte ptr ss:[bp-8]       ; sn°ëen° á°taáe ©†dkñ k zobrazen°
         jz        DispAKF9                 ; nen° dal®° ©†dek
         jmp       DispAKF1                 ; zobrazen° dal®°ho ©†dku

; ------ n†vrat registrñ

DispAKF9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispAKFl ENDP

; *****************************************************************************
;                                 DispADFl
;             Zobrazen° souborñ v adres†©ovÇm oknà - dlouh† jmÇna
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo datovÇho bloku okna
;        BX=hladina k zobrazen°
;        DL=poá†teán° pozice k zobrazen° souborñ
;        DH=©†dek k zobrazen°
;        CL=poáet ©†dkñ k zobrazen°
;        ES=segment definice okna
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) á°slo datovÇho bloku okna
;                   SS:[BP-4] (2) segment okna
;                   SS:[BP-6] (2) pozice a ©†dek k zobrazen°
;                   SS:[BP-7] (1)
;                   SS:[BP-8] (1) á°taá ©†dkñ k zobrazen°
;                   SS:[BP-10] (2) á°taá aktivn° poloëky
;                   SS:[BP-12] (2) ukazatel á°sla poloëky
;                   SS:[BP-14] (2) segment koment†©ñ (0=nen°)
;                   SS:[BP-16] (2) hladina k zobrazen°
;                   SS:[BP-18] (2) á°taá zaá†tku ukazatele
;                   SS:[BP-20] (2) á°taá konce ukazatele
;                   SS:[BP-22] (2) á°taá kurzoru v poli ukazatele
;                   SS:[BP-23] (1)   parametry
;                                        bit 0: 1=zobraz° se ukazatel
;                                        bit 1: 1=zobrazena horn° ®ipka
;                                        bit 2: 1=zapnuta á†st ukazatele
; *****************************************************************************
;˛
DispADFl PROC      NEAR

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

; ------ p©°prava bufferu v z†sobn°ku

         sub       sp,2*40 + 24             ; vytvo©en° bufferu v z†sobn°ku

; ------ p©°prava lok†ln°ch promànnòch

         mov       ss:[bp-2],ax             ; £schova á°sla okna
         mov       ss:[bp-4],es             ; segment okna
         mov       ss:[bp-6],dx             ; pozice a ©†dek k zobrazen°
         mov       ch,0
         mov       ss:[bp-8],cl             ; á°taá ©†dkñ k zobrazen°
         mov       ax,es:[AWinKurz]         ; poloëka s kurzorem
         mov       ss:[bp-16],bx            ; hladina k zobrazen°
         mov       bx,es:[AWinFrst]         ; prvn° poloëka
         sub       ax,bx                    ; offset kurzoru od prvn° poloëky
         inc       ax                       ; p©ednastaven° á°taáe kurzoru
         mov       ss:[bp-10],ax            ; á°taá aktivn° poloëky
         mov       ss:[bp-12],bx            ; ukazatel á°sla poloëky
         mov       word ptr ss:[bp-14],0    ; p©°znak, ëe koment†©e nejsou
         mov       ax,es:[AWinKomS]         ; á°slo segmentu pozn†mek
         call      far ptr GetSgAdr         ; poskytnut° adresy pozn†mek
         jc        DispADF0                 ; nejsou pozn†mky
         mov       ss:[bp-14],dx            ; adresa segmentu pozn†mek

; ------ p©°prava ukazatele (BX=prvn° poloëka)

DispADF0:mov       byte ptr ss:[bp-23],0     ; parametry
         mov       dx,ss:[bp-2]             ; á°slo okna
         cmp       dx,ds:[SegmAkt]          ; je to aktivn° okno ?
         jne       DispADF1                 ; nen° to aktivn° okno

         test      byte ptr ds:[WindPar2],bit3 ; m† se li®ta zobrazit ?
         jz        DispADF1                 ; nezobraz° se

         mov       dx,cx                    ; SI <- poáet zobrazenòch ©†dkñ
         mov       si,es:[AWinSouN]         ; poáet zobrazenòch poloëek celkem
         cmp       cl,4                     ; minim†ln° vò®ka okna
         jb        DispADF1                 ; mal† vò®ka okna
         dec       cx
         dec       cx                       ; bez okrajñ
         mov       ax,es:[AWinKurz]         ; kurzor

         call      far ptr DekUkaz          ; dek¢dov†n° ukazatele
         jc        DispADF1                 ; ukazatel se nezobraz°
         inc       bx
         mov       ss:[bp-18],bx            ; á°taá zaá†tku ukazatele
         inc       cx
         mov       ss:[bp-20],cx            ; á°taá konce ukazatele
         inc       dx
         mov       ss:[bp-22],dx            ; á°taá kurzoru

         or        byte ptr ss:[bp-23],bit0 ; ukazatel se zobraz°

; ------ inicializaán° zobrazen° okrajñ ©†dku (zde je CH=0)

DispADF1:push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku
         mov       di,sp                    ; DI <- buffer v z†sobn°ku
         push      ds                       ; £schova DS
         cld
         mov       ah,ds:[ColXWin1]         ; bàën† barva textu
         mov       al,"∫"                   ; "∫" levò okraj
         stosw                              ; uloëen° levÇho okraje
         mov       al,"∫"                   ; pravò okraj
         mov       es:[di+2*38],ax          ; uloëen° pravÇho okraje

; ------ vymaz†n° ©†dku, je-li neplatn† poloëka

         mov       es,ss:[bp-4]             ; segment definice okna
         mov       bx,ss:[bp-12]            ; ukazatel á°sla poloëky
         cmp       bx,es:[AWinSouN]         ; je platnÇ á°slo poloëky ?
         jb        DispADF2                 ; je platnÇ á°slo poloëky
         push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku
         mov       cl,38                    ; dÇlka zbytku ©†dku
         jmp       DispADF7                 ; dal®° ©†dek

; ------ zobrazen° kurzoru

DispADF2:mov       al,ds:[ColXWin2]         ; vysv°cen† poloëka
         dec       word ptr ss:[bp-10]      ; sn°ëen° á°taáe aktivn° poloëky
         jnz       DispADF3                 ; nen° to ©†dek s kurzorem
         push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku
         mov       cl,"∞"                   ; znak kurzoru
         mov       byte ptr es:[di-2],cl    ; "∞" znak kurzoru
         mov       byte ptr es:[di+2*38],cl ; "∞" znak kurzoru
         mov       dx,ss:[bp-2]             ; á°slo okna
         cmp       dx,ds:[SegmAkt]          ; je to aktivn° okno ?
         jne       DispADF3                 ; nen° to aktivn° okno

         mov       ah,ds:[ColXWin3]         ; barva kurzoru
         mov       al,ds:[ColXWin4]         ; vysv°cenò kurzor
         mov       es,ss:[bp-4]             ; segment definice okna
         call      far ptr GetESPol         ; adresa poloëky
         jmp       short DspADF35

; ------ rozli®en° vysv°cenÇ poloëky

DispADF3:mov       es,ss:[bp-4]             ; segment definice okna
         call      far ptr GetESPol         ; adresa poloëky

         push      bx
         mov       bl,es:[si+FileATyp]      ; typ poloëky
         mov       bh,0
         mov       ah,ds:[bx+ColXWinT]      ; barva poloëky
         cmp       bl,FileATU0+FileTMax
         pop       bx
         jb        DspADF35
         mov       ah,ds:[ColXWin1]         ; bàën† barva textu

DspADF35:test      byte ptr es:[si+FileAtr],ATRO ; je to oznaáen† poloëka ?
         jz        DispADF4                 ; nen° oznaáen† poloëka
         mov       ah,al                    ; barva oznaáenÇ poloëky

; ------ dek¢dov†n° dlouhÇho jmÇna souboru

DispADF4:mov       dx,ds                    ; £schova datovÇho segmentu
         push      es
         pop       ds                       ; DS <- segment poloëky
         push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku

; ------ rozli®en° typu poloëky

         inc       di
         inc       di
         mov       al," "
         mov       es:[di-2],ax
         cmp       byte ptr ds:[si+FileLong],36 ; je del®° jmÇno ?
         jbe       DspADF41                 ; nen° del®° jmÇno
         mov       al,"~"                   ; p©°znak dlouhÇho jmÇna

DspADF41:mov       es:[di+2*36],ax

         test      byte ptr ds:[si+FileAtr],DIR ; je to adres†© ?
         jz        DspADF42                 ; nen° to adres†©
         mov       al,"["
         mov       es:[di-2],ax             ; lev† z†vorka
         mov       al,"]"
         mov       es:[di+2*36],ax
         jmp       short DspADF44

DspADF42:test      byte ptr ds:[si+FileAtr],RO ; je R/O ?
         jz        DspADF43
         mov       al,"*"
         mov       es:[di-2],ax

DspADF43:test      byte ptr ds:[si+FileAtr],SYS+HID
         jz        DspADF44
         mov       al,"∞"
         mov       es:[di-2],ax

DspADF44:cmp       byte ptr ds:[si+FileLong],0 ; je dlouhÇ jmÇno ?
         jne       DispADF5                 ; je dlouhÇ jmÇno

;         push      cs
;         call      near ptr DekAFil         ; dek¢dov†n° jmÇna souboru
         call      DspADFKr                 ; dek¢dov†n° kr†tkÇho jmÇna

; ------ za®ifrov†n° pro DEMO verzi (DX=datovò segment, BX=á°slo poloëky !!!)

         call      DekAFilS                 ; za®ifrov†n° poloëky

         mov       cx,36-8-1-3              ; zbytek dÇlky ©†dku
         jmp       short DispADF7           ; vymaz†n° zbytku ©†dku

DispADF5:mov       cx,36                    ; inicializaán° dÇlka textu
         add       si,FileLong+1            ; zaá†tek dlouhÇho jmÇna
         mov       bl,ds:[si-1]             ; dÇlka jmÇna souboru
         mov       bh,0
         or        bx,bx                    ; je nàjakò znak ?
         jz        DispADF7                 ; nen° dal®° znak

         cmp       bx,cx
         jb        DispADF6
         mov       bx,cx

DispADF6:lodsb
         stosw
         dec       cx
         dec       bx
         jnz       DispADF6

;
;; ------ oddàlovac° á†ra nebo indik†tor oznaáenÇ poloëky
;
;         cld
;         test      byte ptr ds:[si+FileAtr],ATRO ; je to oznaáen† poloëka ?
;         push      ds
;         mov       ds,dx
;         mov       al,"≥"                   ; "≥" oddàlovac° á†ra
;         jz        DispADF5                 ; nen° to oznaáen† poloëka
;         mov       al,"≤"                   ; "≤" indik†tor oznaáenÇ poloëky
;DispADF5:pop       ds
;         stosw                              ; uloëen° znaku
;
;; ------ adresa koment†©e k souboru
;
;         mov       cl,25                    ; dÇlka pro koment†©e
;         mov       dx,ss:[bp-14]            ; segment koment†©ñ
;         or        dx,dx                    ; je segment koment†©ñ ?
;         jz        DispADF7                 ; nejsou koment†©e
;
;         push      ds
;         push      ax
;         mov       ax,ss:[bp-4]             ; segment definice okna
;         mov       ds,ax                    ; segment definice okna
;         mov       si,ss:[bp-12]            ; ukazatel á°sla poloëky
;         shl       si,1                     ; á°slo poloëky * 2
;         add       si,word ptr ds:[AWinKomI]         ; adresa v tabulce indexñ
;         add       ax,word ptr ds:[AWinKomI+2]
;         mov       ds,ax                    ; segment tabulky koment†©ñ
;         mov       si,ds:[si]               ; adresa koment†©e
;         pop       ax
;         pop       ds
;
;         or        si,si                    ; je koment†© ?
;         jz        DispADF7                 ; nen° koment†©
;         mov       ds,dx                    ; segment koment†©e
;
;; ------ dek¢dov†n° pozn†mky k souboru
;
;DispADF6:lodsb                              ; naáten° znaku pozn†mky
;         cmp       al,0                     ; konec textu ?
;         je        DispADF7                 ; konec textu
;         stosw                              ; uloëen° znaku do bufferu
;         loop      DispADF6                 ; dal®° znak

; ------ vymaz†n° zbytku ©†dku

DispADF7:mov       al," "                   ; znak mezery
         rep       stosw                    ; vymaz†n° zbytku ©†dku
         inc       word ptr ss:[bp-12]      ; zvò®en° ukazatele poloëky
         pop       ds

; ------ dek¢dov†n° ukazatele

         test      byte ptr ss:[bp-23],bit0  ; zobraz° se ukazatel ?
         jz        DspADF89                 ; ukazatel se nezobraz°

         mov       si,sp                    ; buffer v z†sobn°ku
         add       si,2*39                  ; posledn° znak v z†sobn°ku
;         mov       ah,ds:[ColXWin3]         ; barva kurzoru
         mov       ah,ds:[ColMnu1]
         mov       al,1eh                   ; ®ipka nahoru
         test      byte ptr ss:[bp-23],bit1  ; byla horn° ®ipka ?
         jz        DspADF88                 ; nebyla je®tà horn° ®ipka
         mov       al,1fh                   ; ®ipka dolñ
         cmp       byte ptr ss:[bp-8],1     ; je posledn° ©†dek ?
         je        DspADF88                 ; je posledn° ©†dek

         dec       word ptr ss:[bp-18]      ; á°taá zaá†tku ukazatele
         jnz       DspADF83
         or        byte ptr ss:[bp-23],bit2  ; zapnut ukazatel
DspADF83:dec       word ptr ss:[bp-20]      ; á°taá konce ukazatele
         jnz       DspADF84
         and       byte ptr ss:[bp-23],not bit2 ; vypnut ukazatel

DspADF84:mov       al,4                     ; znak kurzoru
         dec       word ptr ss:[bp-22]      ; á°taá kurzoru
         jz        DspADF88                 ; je znak kurzoru

         mov       al,"≤"                   ; jinak plocha ukazatele
         test      byte ptr ss:[bp-23],bit2  ; ukazatel zapnut ?
         jz        DspADF88
         mov       ah,ds:[ColMnu2]

DspADF88:mov       es:[si],ax               ; uloëen° znaku
         or        byte ptr ss:[bp-23],bit1  ; zobrazena horn° ®ipka

; ------ zobrazen° jednoho ©†dku

DspADF89:mov       si,sp                    ; buffer v z†sobn°ku
         mov       cl,40                    ; dÇlka ©†dku
         mov       dx,ss:[bp-6]             ; pozice a ©†dek k zobrazen°
         mov       ax,ss:[bp-16]            ; hladina k zobrazen°
         call      far ptr DispMStr         ; zobrazen° textu

; ------ p©°prava k zobrazen° dal®°ho ©†dku

         inc       byte ptr ss:[bp-5]       ; zvò®en° ukazatele ©†dku
         dec       byte ptr ss:[bp-8]       ; sn°ëen° á°taáe ©†dkñ k zobrazen°
         jz        DispADF9                 ; nen° dal®° ©†dek
         jmp       DispADF1                 ; zobrazen° dal®°ho ©†dku

; ------ n†vrat registrñ

DispADF9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispADFl ENDP

; ------ dek¢dov†n° kr†tkÇho jmÇna (interface jako DekAFil), niá° CX a SI !

DspADFKr PROC      NEAR

         push      di

         cld
         inc       si                       ; zaá†tek jmÇna poloëky
         mov       cx,8                     ; dÇlka jmÇna poloëky
DspADFK2:lodsb
         stosw
         loop      DspADFK2

DspADFK3:cmp       byte ptr es:[di-2]," "
         jne       DspADFK4
         dec       di
         dec       di
         inc       cx
         cmp       cl,8
         jb        DspADFK3

DspADFK4:mov       al,"."
         stosw

         cmp       byte ptr ds:[si]," "
         jne       DspADFK5
         mov       byte ptr es:[di-2]," "

DspADFK5:mov       cl,3
DspADFK6:lodsb
         stosw
         loop      DspADFK6

         mov       cl,8
         mov       al," "
         rep       stosw                    ; vymaz†n° zbytku

         pop       di
         add       di,2*(8+1+3)
         ret

DspADFKr ENDP

; *****************************************************************************
;                                DekAPth
;                  dek¢dov†n° textu cesty okna seznamu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=poloëka cesty k dek¢dov†n° (1. bajt = dÇlka cesty, minim†lnà 3)
;        ES:DI=ukl†dac° adresa (38 pozic)
;        AH=barva textu
; VùSTUP: ES:DI=nov† ukl†dac° adresa
; *****************************************************************************

DekAPth  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      si

; ------ dÇlka poloëky

         cld
         lodsb                              ; Al <- dÇlka textu poloëky
         sub       al,3                     ; bez 3 £vodn°ch znakñ
         mov       cl,al                    ; CL <- dÇlka textu poloëky
         mov       ch,0

; ------ p©enesen° oznaáen° disku

         lodsb
         stosw                              ; disk
         lodsb
         stosw                              ; oddàlovac° dvojteáka
         lodsb
         stosw                              ; £vodn° lom°tko

; ------ omezen° dÇlky textu

         mov       bl,38-3                  ; dÇlka zbytku textu
         cmp       cl,38-3                  ; maxim†ln° dÇlka zbytku textu
         jbe       DekAPth2                 ; dÇlka textu je OK
         sub       cl,38-3-3                ; p©esah textu
         add       si,cx                    ; posun poá†teán° adresy textu
         mov       cl,38-3-3                ; omezen° dÇlky textu
         mov       bl,38-3-3                ; omezen° zbytku textu
         mov       al,"."                   ; oznaáen° oddàlovaáe
         stosw
         stosw
         stosw                              ; uloëen° oddàlovac°ch "..."

; ------ p©enesen° platnÇ á†sti textu

DekAPth2:sub       bl,cl                    ; chybàj°c° zbytek textu
         jcxz      DekAPth4                 ; nen° dal®° text
DekAPth3:lodsb
         stosw
         loop      DekAPth3                 ; dal®° znak

; ------ vymaz†n° zbytku ©†dku

DekAPth4:mov       cl,bl                    ; chybàj°c° á†st
         mov       al," "
         rep       stosw                    ; vymaz†n° zbytku ©†dku

; ------ n†vrat registrñ

         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

DekAPth  ENDP

; *****************************************************************************
;                                   DekAFil
;                         dek¢dov†n° jmÇna souboru
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=poloëka souboru k dek¢dov†n°
;        ES:DI=ukl†dac° adresa (12 pozic: 8 jmÇno, 1 mezera, 3 p©°pona)
;               (DX=datovò segment)
;        AH=barva textu
; VùSTUP: ES:DI=nov† ukl†dac° adresa
; *****************************************************************************

DekAFil  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      si

; ------ p©°prava k dek¢dov†n° jmÇna souboru

         cld
         mov       cx,8                     ; dÇlka jmÇna souboru
         mov       bl,ds:[si+FileAtr]       ; atributy souboru
         mov       bh,bl                    ; atributy souboru

; ------ dek¢dov†n° jmÇna souboru

         inc       si                       ; zaá†tek jmÇna
DekAFil1:lodsb                              ; naáten° znaku jmÇna souboru
         test      bl,DIR + HID + SYS       ; bude velkÇ p°smeno ?
         jnz       DekAFil2                 ; bude velkÇ p°smeno
         call      far ptr DownCase         ; konverze na malÇ p°smeno
DekAFil2:stosw                              ; uloëen° znaku jmÇna souboru
         and       bl,not HID + SYS         ; zru®en° atributñ HID a SYS
         loop      DekAFil1                 ; dek¢dov†n° dal®°ho znaku

; ------ oddàlovac° znak mezi jmÇnem a p©°ponou

         mov       al,"∞"                   ; oznaáen° souborñ HID a SYS
         test      bh,HID + SYS             ; je soubor HID nebo SYS ?
         jnz       DekAFil3                 ; soubor je HID nebo SYS
         mov       al,"*"                   ; oznaáen° souborñ R/O
         test      bh,RO                    ; je soubor R/O ?
         jnz       DekAFil3                 ; soubor je R/O
         mov       al," "                   ; jinak mezera pro bàënò soubor
         test      bh,DIR                   ; je to adres†© ?
         jz        DekAFil3                 ; nen° to adres†©
;         cmp       word ptr ds:[si-8],".."  ; je to adres†© ".." ?
;         je        DekAFil3                 ; ten to nemus° m°t

         push      ax
         mov       ax,word ptr ds:[si+FileSize-FileExt] ; velikost LOW
         or        ax,word ptr ds:[si+FileSize-FileExt+2] ; velikost HIGH
         pop       ax
         jz        DekAFil3                 ; nen° velikost adres†©e

;         push      ds
;         mov       ds,dx                    ; DS <- datovò segment
;         test      byte ptr ds:[WindPar2],bit6   ; naá°t† se velikost adres†©ñ ?
;         pop       ds
;         jz        DekAFil3                 ; velikost se nenaá°t†

         mov       al,7                     ; oznaáen° adres†©e
DekAFil3:stosw

; ------ dek¢dov†n° p©°pony jmÇna souboru

         mov       cl,3                     ; dÇlka p©°pony jmÇna souboru
DekAFil4:lodsb                              ; naáten° znaku p©°pony jmÇna soub.
         test      bl,DIR                   ; bude velkÇ p°smeno ?
         jnz       DekAFil5                 ; bude velkÇ p°smeno
         call      far ptr DownCase         ; konverze na malÇ p°smeno
DekAFil5:stosw                              ; uloëen° znaku p©°pony jmÇna soub.
         loop      DekAFil4                 ; dek¢dov†n° dal®°ho znaku

; ------ n†vrat registrñ

         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

DekAFil  ENDP

; *****************************************************************************
;                                DekASiz
;                      dek¢dov†n° velikosti souboru
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=poloëka souboru k dek¢dov†n°
;        ES:DI=ukl†dac° adresa (10 pozic)
;        DX=datovò segment
;        AH=barva textu
; VùSTUP: ES:DI=nov† ukl†dac° adresa
; *****************************************************************************

DekASiz  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx

; ------ test, zda je to adres†©

         cld
         mov       cx,10                    ; dÇlka pole velikosti
         test      byte ptr ds:[si+FileAtr],DIR ; je to adres†© ?
         jz        DekASiz4                 ; nen° to adres†© - je to soubor

; ------ p©i naá°t†n° velikosti se zobraz° velikost souboru

         push      ax
         mov       ax,word ptr ds:[si+FileSize] ; velikost LOW
         or        ax,word ptr ds:[si+FileSize+2] ; velikost HIGH
         pop       ax
         jnz       DekASiz4                 ; je velikost adres†©e

;         cmp       word ptr ds:[si+FileName],".." ; je to nadadres†© ?
;         je        DekASiz1                 ; text se zobraz°
;
;         push      ds
;         mov       ds,dx                    ; DS <- datovò segment
;         test      byte ptr ds:[WindPar2],bit6   ; naá°t† se velikost adres†©ñ ?
;         pop       ds
;         jnz       DekASiz4                 ; velikost se naá°t†

; ------ dek¢dov†n° identifikaán°ho textu adres†©e

DekASiz1:cmp       word ptr ds:[si+FileName],".." ; je to nadadres†© ?
         push      si
         push      ds
         mov       si,offset DskTxtN        ; text "<NAD--ADR>"
         je        DekASiz2                 ; je to nadadres†©
         mov       si,offset DskTxtP        ; text "<POD--ADR>"
DekASiz2:mov       ds,dx                    ; datovò segment
DekASiz3:lodsb
         stosw
         loop      DekASiz3                 ; dek¢dov†n° textu adres†©e
         pop       ds
         pop       si
         jmp       short DekASiz9

; ------ dek¢dov†n° velikosti souboru (á°slo)

DekASiz4:mov       al," "
         rep       stosw                    ; vymaz†n° pole mezerou
         push      ds
         mov       ds,dx                    ; datovò segment
         mov       bl,ds:[OddelRad]         ; oddàlovac° znak ©†dñ
         pop       ds
         mov       bh,ah                    ; barva textu
         mov       ax,word ptr ds:[si+FileSize] ; velikost souboru LOW
         mov       dx,word ptr ds:[si+FileSize+2] ; velikost souboru HIGH
         call      far ptr Dek10Num         ; dek¢dov†n° velikosti s omezen°m

; ------ n†vrat registrñ

DekASiz9:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DekASiz  ENDP

; *****************************************************************************
;                                DekA4Dat
;                   dek¢dov†n° data souboru (rok 4 pozice)
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=poloëka souboru k dek¢dov†n°
;        ES:DI=ukl†dac° adresa (10 pozic)
;        AH=barva textu (0=barva se neukl†d†)
;        DX=datovò segment
; VùSTUP: ES:DI=nov† ukl†dac° adresa
; *****************************************************************************

DekA4Dat PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx

; ------ form†t data

         cld
         push      ds
         mov       ds,dx                    ; datovò segment
         mov       bl,ds:[ZnakDat]          ; oddàlovac° znak data
         mov       bh,ds:[FormDat]          ; form†t data (0=MDR,1=DMR,2=RMD)
         pop       ds

; ------ 1: evropskò form†t DEN/MâSãC/ROK

         mov       ch," "                   ; dopl§uj°c° znak
         cmp       bh,1                     ; form†t data = EVROPA ?
         jne       DekA4Dt3                 ; nen° evropskò form†t data

         call      DekADDen                 ; dek¢dov†n° dne
         call      DekADChr                 ; uloëen° oddàlovac°ho znaku data
         call      DekADMes                 ; dek¢dov†n° màs°ce
         jmp       short DekA4Dt6

; ------ 2: japonskò form†t ROK:MâSãC:DEN

DekA4Dt3:jb        DekA4Dt5                 ; nen° japonskò form†t data

         mov       ch,"0"                   ; dopl§uj°c° znak
         call      DekAD4Rk                 ; dek¢dov†n° roku (4 á°slice)
         call      DekADChr                 ; uloëen° oddàlovac°ho znaku data
         call      DekADMes                 ; dek¢dov†n° màs°ce
         call      DekADChr                 ; uloëen° oddàlovac°ho znaku data
         call      DekADDen                 ; dek¢dov†n° dne
         jmp       short DekA4Dt9

; ------ 0: americkò form†t MâSãC/DEN/ROK

DekA4Dt5:call      DekADMes                 ; dek¢dov†n° màs°ce
         call      DekADChr                 ; uloëen° oddàlovac°ho znaku data
         call      DekADDen                 ; dek¢dov†n° dne
DekA4Dt6:call      DekADChr                 ; uloëen° oddàlovac°ho znaku data
         call      DekAD4Rk                 ; dek¢dov†n° roku (4 á°slice)

; ------ n†vrat registrñ

DekA4Dt9:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DekA4Dat ENDP

; *****************************************************************************
;                                DekADat
;                   dek¢dov†n° data souboru (rok 2 pozice)
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=poloëka souboru k dek¢dov†n°
;        ES:DI=ukl†dac° adresa (8 pozic)
;        AH=barva textu (0=barva se neukl†d†)
;        DX=datovò segment
; VùSTUP: ES:DI=nov† ukl†dac° adresa
; *****************************************************************************

DekADat  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx

; ------ form†t data

         cld
         push      ds
         mov       ds,dx                    ; datovò segment
         mov       bl,ds:[ZnakDat]          ; oddàlovac° znak data
         mov       bh,ds:[FormDat]          ; form†t data (0=MDR,1=DMR,2=RMD)
         pop       ds

; ------ 1: evropskò form†t DEN/MâSãC/ROK

         mov       ch," "                   ; dopl§uj°c° znak
         cmp       bh,1                     ; je evropskò form†t ?
         jne       DekADat3                 ; nen° evropskò form†t data

         call      DekADDen                 ; dek¢dov†n° dne
         call      DekADChr                 ; uloëen° oddàlovac°ho znaku data
         call      DekADMes                 ; dek¢dov†n° màs°ce
         jmp       short DekADat6

; ------ 2: japonskò form†t ROK:MâSãC:DEN

DekADat3:jb        DekADat5                 ; nen° japonskò form†t data

         mov       ch,"0"                   ; dopl§uj°c° znak
         call      DekADRok                 ; dek¢dov†n° roku
         call      DekADChr                 ; uloëen° oddàlovac°ho znaku data
         call      DekADMes                 ; dek¢dov†n° màs°ce
         call      DekADChr                 ; uloëen° oddàlovac°ho znaku data
         call      DekADDen                 ; dek¢dov†n° dne
         jmp       short DekADat9

; ------ 0: americkò form†t MâSãC/DEN/ROK

DekADat5:call      DekADMes                 ; dek¢dov†n° màs°ce
         call      DekADChr                 ; uloëen° oddàlovac°ho znaku data
         call      DekADDen                 ; dek¢dov†n° dne
DekADat6:call      DekADChr                 ; uloëen° oddàlovac°ho znaku data
         call      DekADRok                 ; dek¢dov†n° roku

; ------ n†vrat registrñ

DekADat9:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DekADat  ENDP

; -----------------------------------------------------------------------------
;                                DekADDen
;                   dek¢dov†n° dne souboru (2 á°slice)
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=poloëka souboru
;        AH=barva textu (0=barva se neukl†d†)
;        CH=znak k doplnàn° (nam°sto prvn° "0")
;        ES:DI=ukl†dac° adresa (mus° bòt smàr CLD)
;        BL=oddàlovac° znak data
;        CLD=smàr nahoru
; VùSTUP:ES:DI=nov† ukl†dac° adresa
;        AL=oddàlovac° znak data
;        CH=dopl§uj°c° znak "0"
; -----------------------------------------------------------------------------
; niá° registr DX
; -----------------------------------------------------------------------------

DekADDen PROC      NEAR

         mov       al,byte ptr ds:[si+FileDate] ; datum LOW
         and       al,1fh                   ; den
         jmp       short DekADT             ; dek¢dov†n° dvojá°sl°

DekADDen ENDP

; -----------------------------------------------------------------------------
;                                DekADMes
;                   dek¢dov†n° màs°ce souboru (2 á°slice)
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=poloëka souboru
;        AH=barva textu (0=barva se neukl†d†)
;        CH=znak k doplnàn° (nam°sto prvn° "0")
;        ES:DI=ukl†dac° adresa (mus° bòt smàr CLD)
;        BL=oddàlovac° znak data
;        CLD=smàr nahoru
; VùSTUP:ES:DI=nov† ukl†dac° adresa
;        AL=oddàlovac° znak data
;        CH=dopl§uj°c° znak "0"
; -----------------------------------------------------------------------------
; niá° registry CL a DX
; -----------------------------------------------------------------------------

DekADMes PROC      NEAR

         mov       dx,ds:[si+FileDate]      ; datum souboru
         mov       cl,5                     ; poáet rotac°
         shr       dx,cl                    ; rotace màs°ce
         mov       al,dl                    ; màs°c
         and       al,0fh                   ; màs°c
                                          ;* pokraáuje DekADT !

DekADMes ENDP

; -----------------------------------------------------------------------------
;                               DekADT
;                dek¢dov†n° dvojá°sl° s doplnàn°m znaku
; -----------------------------------------------------------------------------
; VSTUP: AL=á°slo
;        AH=barva textu (0=barva se neukl†d†)
;        BL=oddàlovac° znak data
;        CH=znak k doplnàn° (nam°sto prvn° "0")
;        ES:DI=ukl†dac° adresa (mus° bòt smàr CLD)
;        CLD=smàr nahoru
; VùSTUP:ES:DI=nov† ukl†dac° adresa
;        AL=oddàlovac° znak data
;        CH=znak k doplnàn° "0"
; -----------------------------------------------------------------------------
; niá° registr DX
; -----------------------------------------------------------------------------

DekADT   PROC      NEAR

         mov       dx,ax                    ; £schova á°sla
         aam                                ; rozdàlen° AL na 2 á°slice
         add       ax,"00"                  ; korekce na á°slice ASCII
         xchg      ax,dx                    ; £schova á°sla do DX
         mov       al,dh                    ; vy®®° á°slice
         cmp       al,"0"                   ; je prvn° znak 0 ?
         jne       DekADT1                  ; nen° 0
         mov       al,ch                    ; n†hradn° prvn° znak

DekADT1: or        ah,ah                    ; je barva textu ?
         jz        DekADt2                  ; nen° barva textu
         stosw                              ; uloëen° prvn° á°slice
         mov       al,dl                    ; druh† á°slice
         stosw                              ; uloëen° druhÇ á°slice
         mov       al,bl                    ; oddàlovac° znak data
         mov       ch,"0"                   ; novò dopl§uj°c° znak "0"
         ret

DekADt2: stosb                              ; uloëen° prvn° á°slice
         mov       al,dl                    ; druh† á°slice
         stosb                              ; uloëen° druhÇ á°slice
         mov       al,bl                    ; oddàlovac° znak data
         mov       ch,"0"                   ; novò dopl§uj°c° znak "0"
         ret

DekADT   ENDP

; -----------------------------------------------------------------------------
;                               DekADRok
;                    dek¢dov†n° roku souboru (2 á°slice)
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=poloëka souboru
;        AH=barva textu (0=barva se neukl†d†)
;        CH=znak k doplnàn° (nam°sto prvn° "0")
;        ES:DI=ukl†dac° adresa (mus° bòt smàr CLD)
;        BL=oddàlovac° znak data
;        CLD=smàr nahoru
; VùSTUP:ES:DI=nov† ukl†dac° adresa
;        AL=oddàlovac° znak data
;        CH=dopl§uj°c° znak "0"
; -----------------------------------------------------------------------------
; niá° registry CL a DX
; -----------------------------------------------------------------------------

DekADRok PROC      NEAR

         mov       al,byte ptr ds:[si+FileDate+1] ; datum souboru - vy®®° bajt
         shr       al,1                     ; rok
         add       al,80                    ; p©iáten° z†kladu bez stolet°
         cmp       al,100                   ; je posledn° dvojá°sl° ?
         jb        DekADT                   ; á°slo je OK
         sub       al,100                   ; odeáten° stolet°
         cmp       al,100                   ; je jië posledn° dvojá°sl° ?
         jb        DekADT                   ; á°slo je OK
         sub       al,100                   ; odeáten° stolet°
         jmp       short DekADT             ; dek¢dov†n° dvojá°sl°

DekADRok ENDP

; -----------------------------------------------------------------------------
;                               DekAD4Rk
;                    dek¢dov†n° roku souboru (4 á°slice)
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=poloëka souboru
;        AH=barva textu (0=barva se neukl†d†)
;        ES:DI=ukl†dac° adresa (mus° bòt smàr CLD)
;        BL=oddàlovac° znak data
;        CLD=smàr nahoru
; VùSTUP:ES:DI=nov† ukl†dac° adresa
;        AL=oddàlovac° znak data
;        CH=dopl§uj°c° znak "0"
; -----------------------------------------------------------------------------
; niá° registry CL a DX
; -----------------------------------------------------------------------------

DekAD4Rk PROC      NEAR

         push      bx
         xchg      ax,bx                    ; BH <- barva textu
         mov       bl,0                     ; oddàlovaá ©†dñ se neukl†d†
         mov       al,byte ptr ds:[si+FileDate+1] ; datum souboru
         shr       al,9-8
         mov       ah,0
         add       ax,1980                  ; rok
         call      far ptr DekNumW          ; dek¢dov†n° á°sla (4 á°slice)
         xchg      ax,bx                    ; n†vrat barvy textu AH
         pop       bx
         mov       al,bl                    ; oddàlovac° znak data
         mov       ch,"0"                   ; dopl§uj°c° znak "0"
         cld
         ret

DekAD4Rk ENDP

; -----------------------------------------------------------------------------
;        podm°nànÇ uloëen° znaku AX (AH=0 barva se neukl†d†)
; -----------------------------------------------------------------------------

DekADChr PROC      NEAR

         or        ah,ah                    ; je barva ?
         jz        DekADCh2                 ; nen° barva
         stosw                              ; uloëen° znaku s barvou
         ret

DekADCh2:stosb                              ; uloëen° znaku bez barvy
         ret

DekADChr ENDP

; *****************************************************************************
;                                DekATim
;                       dek¢dov†n° áasu souboru
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=poloëka souboru k dek¢dov†n°
;        ES:DI=ukl†dac° adresa (5 pozic)
;        DX=datovò segment
;        AH=barva textu
; VùSTUP: ES:DI=nov† ukl†dac° adresa
; *****************************************************************************

DekATim  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx

; ------ oddàlovac° znak áasu

         push      ds
         mov       ds,dx                    ; datovò segment
         mov       bl,ds:[ZnakTim]          ; oddàlovac° znak áasu
         pop       ds

; ------ dek¢dov†n° hodiny

         cld
         mov       ch," "                   ; n†hradn° znak
         mov       al,byte ptr ds:[si+FileTime+1] ; áas souboru - vy®®° bajt
         mov       cl,11-8                  ; poáet rotac°
         shr       al,cl                    ; hodina
         call      DekADT                   ; dek¢dov†n° £daje hodiny

; ------ oddàlovac° znak áasu

         call      DekADChr                 ; uloëen° oddàlovac°ho znaku áasu

; ------ dek¢dov†n° minuty

         mov       dx,ds:[si+FileTime]      ; áas souboru
         mov       cl,5                     ; poáet rotac°
         shr       dx,cl                    ; minuta
         mov       al,dl                    ; minuta
         and       al,3fh                   ; minuta
         call      DekADT                   ; dek¢dov†n° £daje minut

; ------ n†vrat registrñ

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DekATim  ENDP

; *****************************************************************************
;                                DekATmS
;                   dek¢dov†n° áasu souboru se sekundami
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=poloëka souboru k dek¢dov†n°
;        ES:DI=ukl†dac° adresa (8 pozic)
;        DX=datovò segment
;        AH=barva textu
; VùSTUP: ES:DI=nov† ukl†dac° adresa
; *****************************************************************************

DekATmS  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx

; ------ oddàlovac° znak áasu

         push      ds
         mov       ds,dx                    ; datovò segment
         mov       bl,ds:[ZnakTim]          ; oddàlovac° znak áasu
         pop       ds

; ------ dek¢dov†n° hodiny

         cld
         mov       ch," "                   ; n†hradn° znak
         mov       al,byte ptr ds:[si+FileTime+1] ; áas souboru - vy®®° bajt
         mov       cl,11-8                  ; poáet rotac°
         shr       al,cl                    ; hodina
         call      DekADT                   ; dek¢dov†n° £daje hodiny

; ------ oddàlovac° znak áasu

         call      DekADChr                 ; uloëen° oddàlovac°ho znaku áasu

; ------ dek¢dov†n° minuty

         mov       dx,ds:[si+FileTime]      ; áas souboru
         mov       cl,5                     ; poáet rotac°
         shr       dx,cl                    ; minuta
         mov       al,dl                    ; minuta
         and       al,3fh                   ; minuta
         call      DekADT                   ; dek¢dov†n° £daje minut

; ------ oddàlovac° znak áasu

         call      DekADChr                 ; uloëen° oddàlovac°ho znaku áasu

; ------ dek¢dov†n° sekund

         mov       al,byte ptr ds:[si+FileTime] ; áas souboru
         and       al,1fh                   ; sekunda/2
         shl       al,1                     ; sekunda
         call      DekADT                   ; dek¢dov†n° £daje sekund

; ------ n†vrat registrñ

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DekATmS  ENDP

; *****************************************************************************
;                               DekAAtr
;                    dek¢dov†n° atributñ souboru
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=poloëka souboru k dek¢dov†n°
;        ES:DI=ukl†dac° adresa (5 pozic)
;        AH=barva textu (0=barva se neukl†d†)
; VùSTUP: ES:DI=nov† ukl†dac° adresa
; *****************************************************************************

DekAAtr  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx

; ------ p©°prava atributñ souboru

         cld
         mov       bl,ds:[si+FileAtr]       ; atributy souboru
         shl       bl,1                     ; zru®en° bitu 7
         shl       bl,1                     ; zru®en° bitu 6

; ------ atribut ARC

         mov       al,"A"                   ; archivn°
         shl       bl,1                     ; je atribut nastaven ?
         jc        DekAAtr1                 ; atribut ARC je nastaven
         mov       al,"."                   ; atribut ARC nen° nastaven
DekAAtr1:call      DekADChr                 ; uloëen° atributu ARC

; ------ atribut DIR

         mov       al,"D"                   ; adres†©
         shl       bl,1                     ; je atribut nastaven ?
         jc        DekAAtr2                 ; atribut DIR je nastaven
         mov       al,"."                   ; atribut DIR nen° nastaven
DekAAtr2:call      DekADChr                 ; uloëen° atributu DIR

; ------ atribut SYS

         shl       bl,1                     ; zru®en° bitu 3 (VOL)
         mov       al,"S"                   ; systÇmovò
         shl       bl,1                     ; je atribut nastaven ?
         jc        DekAAtr3                 ; atribut SYS je nastaven
         mov       al,"."                   ; atribut SYS nen° nastaven
DekAAtr3:call      DekADChr                 ; uloëen° atributu SYS

; ------ atribut HID

         mov       al,"H"                   ; skrytò
         shl       bl,1                     ; je atribut nastaven ?
         jc        DekAAtr4                 ; atribut HID je nastaven
         mov       al,"."                   ; atribut HID nen° nastaven
DekAAtr4:call      DekADChr                 ; uloëen° atributu HID

; ------ atribut R/O

         mov       al,"R"                   ; R/O
         shl       bl,1                     ; je atribut nastaven ?
         jc        DekAAtr5                 ; atribut R/O je nastaven
         mov       al,"."                   ; atribut R/O nen° nastaven
DekAAtr5:call      DekADChr                 ; uloëen° atributu R/O

; ------ n†vrat registrñ

         pop       bx
         pop       ax
         ret

DekAAtr  ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                         PomocnÇ procedury oken
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; *****************************************************************************
;                                 GetLAWin
;                       poskytnut° adresy levÇho okna
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:ES=segment definice levÇho okna
; *****************************************************************************

GetLAWin PROC      FAR

         push      ax
         mov       ax,ds:[SegmL]            ; levÇ okno
         call      far ptr GetDat           ; poskytnut° adresy okna
         pop       ax
         ret

GetLAWin ENDP

; *****************************************************************************
;                                GetRAWin
;                       poskytnut° adresy pravÇho okna
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:ES=segment definice pravÇho okna
; *****************************************************************************

GetRAWin PROC      FAR

         push      ax
         mov       ax,ds:[SegmR]            ; pravÇ okno
         call      far ptr GetDat           ; poskytnut° adresy okna
         pop       ax
         ret

GetRAWin ENDP

; *****************************************************************************
;                                GetAAWin
;                  poskytnut° adresy aktivn°ho okna
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:ES=segment definice aktivn°ho okna
; *****************************************************************************

GetAAWin PROC      FAR

         push      ax
         mov       ax,ds:[SegmAkt]          ; aktivn° okno
         call      far ptr GetDat           ; poskytnut° adresy okna
         pop       ax
         ret

GetAAWin ENDP

; *****************************************************************************
;                                GetNAWin
;                  poskytnut° adresy neaktivn°ho okna
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:ES=segment definice neaktivn°ho okna
; *****************************************************************************

GetNAWin PROC      FAR

         push      ax
         mov       ax,ds:[SegmNAkt]         ; neaktivn° okno
         call      far ptr GetDat           ; poskytnut° adresy okna
         pop       ax
         ret

GetNAWin ENDP

; *****************************************************************************
;                                TestLAWn
;               test, zda je levÇ okno zapnuto (a zobrazeno)
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:CY=levÇ okno nen° zapnuto
; *****************************************************************************

TestLAWn PROC      FAR

; ------ test, zda jsou okna zapnuta

         test      byte ptr ds:[WindPar],bit1 ; jsou okna zapnuta
         jz        TestLAW4                 ; okna jsou vypnuta

; ------ test, zda je zapnuto levÇ okno

         test      byte ptr ds:[ParamL],bit0 ; je levÇ okno zapnuto ?
         jz        TestLAW4                 ; levÇ okno nen° zapnuto
         ret                                ; okno zapnuto OK

; ------ okno nen° zapnuto

TestLAW4:stc                                ; p©°znak - okno nen° zapnuto
         ret

TestLAWn ENDP

; *****************************************************************************
;                                TestRAWn
;               test, zda je pravÇ okno zapnuto (a zobrazeno)
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:CY=pravÇ okno nen° zapnuto
; *****************************************************************************

TestRAWn PROC      FAR

; ------ test, zda jsou okna zapnuta

         test      byte ptr ds:[WindPar],bit1 ; jsou okna zapnuta
         jz        TestRAW4                 ; okna jsou vypnuta

; ------ test, zda je zapnuto pravÇ okno

         test      byte ptr ds:[ParamR],bit0 ; je pravÇ okno zapnuto ?
         jz        TestRAW4                 ; pravÇ okno nen° zapnuto
         ret                                ; okno zapnuto OK

; ------ okno nen° zapnuto

TestRAW4:stc                                ; p©°znak - okno nen° zapnuto
         ret

TestRAWn ENDP

; *****************************************************************************
;                                TestAAWn
;              test, zda je aktivn° okno zapnuto (a zobrazeno)
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:CY=aktivn° okno nen° zapnuto
; *****************************************************************************

TestAAWn PROC      FAR

; ------ test, zda jsou okna zapnuta

         test      byte ptr ds:[WindPar],bit1 ; jsou okna zapnuta
         jz        TestAAW4                 ; okna jsou vypnuta

; ------ test, zda je zapnuto levÇ okno

         test      byte ptr ds:[WindPar],bit0 ; je aktivn° levÇ okno ?
         jz        TestAAW2                 ; je aktivn° pravÇ okno
         test      byte ptr ds:[ParamL],bit0 ; je levÇ okno zapnuto ?
         jz        TestAAW4                 ; levÇ okno nen° zapnuto
         ret                                ; okno zapnuto OK

; ------ test, zda je zapnuto pravÇ okno

TestAAW2:test      byte ptr ds:[ParamR],bit0 ; je pravÇ okno zapnuto ?
         jz        TestAAW4                 ; pravÇ okno nen° zapnuto
         ret                                ; okno je zapnuto OK

; ------ okno nen° zapnuto

TestAAW4:stc                                ; p©°znak - okno nen° zapnuto
         ret

TestAAWn ENDP

; *****************************************************************************
;                                TestNAWn
;              test, zda je neaktivn° okno zapnuto (a zobrazeno)
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:CY=neaktivn° okno nen° zapnuto
; *****************************************************************************

TestNAWn PROC      FAR

; ------ test, zda jsou okna zapnuta

         test      byte ptr ds:[WindPar],bit1 ; jsou okna zapnuta
         jz        TestNAW4                 ; okna jsou vypnuta

; ------ test, zda je zapnuto levÇ okno

         test      byte ptr ds:[WindPar],bit0 ; je aktivn° levÇ okno ?
         jnz       TestNAW2                 ; je aktivn° levÇ okno
         test      byte ptr ds:[ParamL],bit0 ; je levÇ okno zapnuto ?
         jz        TestNAW4                 ; levÇ okno nen° zapnuto
         ret                                ; okno zapnuto OK

; ------ test, zda je zapnuto pravÇ okno

TestNAW2:test      byte ptr ds:[ParamR],bit0 ; je pravÇ okno zapnuto ?
         jz        TestNAW4                 ; pravÇ okno nen° zapnuto
         ret                                ; okno je zapnuto OK

; ------ okno nen° zapnuto

TestNAW4:stc                                ; p©°znak - okno nen° zapnuto
         ret

TestNAWn ENDP

; *****************************************************************************
;                              TestAWin
;                test, zda je okno AX zapnuto (a zobrazeno)
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo okna
;        DS=datovò segment
; VùSTUP:CY=okno nen° zobrazeno (je vypnuto)
; *****************************************************************************

TestAWin PROC      FAR

; ------ test, zda jsou okna zapnuta

         test      byte ptr ds:[WindPar],bit1 ; jsou okna zapnuta
         jz        TestAWn4                 ; okna jsou vypnuta

; ------ test, zda je zapnuto levÇ okno

         cmp       ax,ds:[SegmL]            ; je poëadov†no levÇ okno ?
         jne       TestAWn2                 ; nen° poëadov†no levÇ okno
         test      byte ptr ds:[ParamL],bit0 ; je levÇ okno zapnuto ?
         jz        TestAWn4                 ; levÇ okno nen° zapnuto
         ret                                ; okno zapnuto OK

; ------ test, zda je zapnuto pravÇ okno

TestAWn2:test      byte ptr ds:[ParamR],bit0 ; je pravÇ okno zapnuto ?
         jz        TestAWn4                 ; pravÇ okno nen° zapnuto
         ret                                ; okno je zapnuto OK

; ------ okno nen° zapnuto

TestAWn4:stc                                ; p©°znak - okno nen° zapnuto
         ret

TestAWin ENDP

; *****************************************************************************
;                                 ModWDisk
;                 modifikace adres†©ovÇho okna pro zadanò disk
;                       (uchov†v† registr p©°znakñ !)
; -----------------------------------------------------------------------------
; VSTUP: AL=á°slo disku (0=A:, ...)
;        AH=parametry
;              bit 3: 1=povoleno pro adres†©ovÇ okno
;              bit 4: 1=povoleno pro strom
;              bit 5: 1=povoleno pro seznam
;        DS=datovò segment
; *****************************************************************************

ModWDisk PROC      FAR

; ------ £schova registrñ

         pushf
         push      ax
         push      bx
         push      cx
         push      dx
         push      es
         xchg      ax,dx                    ; DL <- poëadovanò disk, DH <- parametry

; ------ aktualizace pro levò adres†©

         mov       ax,ds:[SegmLAdr]         ; levò adres†©
         call      ModW0Dsk                 ; aktualizace poloëky

; ------ aktualizace pro pravò adres†©

         mov       ax,ds:[SegmRAdr]         ; pravò adres†©
         call      ModW0Dsk                 ; aktualizace poloëky

; ------ aktualizace pro aktivn° okno

         mov       ax,ds:[SegmAkt]
         call      ModW0Ds1                 ; aktualizace poloëky

; ------ aktualizace pro neaktivn° okno

         mov       ax,ds:[SegmNAkt]
         call      ModW0Ds1                 ; aktualizace poloëky

; ------ okna pro vyhled†v†n°

         mov       cx,ds:[FileWNum]         ; poáet oken pro operaci
         jcxz      ModWDsk9                 ; nen° ë†dnÇ okno
         mov       bx,offset FileWSeg       ; ukazatel oken
ModWDsk8:mov       ax,ds:[bx]               ; uschovanÇ okno

         call      ModW0Dsk                 ; aktualizace okna

         inc       bx                       ; zvò®en° adresy v definici oken
         inc       bx
         loop      ModWDsk8                 ; bude dal®° okno

; ------ n†vrat registrñ

ModWDsk9:pop       es
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         popf
         ret

ModWDisk ENDP

; -----------------------------------------------------------------------------
;        modifikace pro okno AX, disk DL, parametry DH
; -----------------------------------------------------------------------------

ModW0Dsk PROC      NEAR

; ------ z†kaz aktivn°ho a neaktivn°ho okna

         cmp       ax,ds:[SegmAkt]
         je        ModW0Ds0
         cmp       ax,ds:[SegmNAkt]
         jne       ModW0Ds1
ModW0Ds0:ret

; ------ adresa okna AX -> ES

ModW0Ds1:call      far ptr GetDat           ; adresa okna AX -> ES
         jc        ModW0Ds0                 ; chyba - neplatnÇ okno

; ------ porovn†n° á°sla disku

         cmp       dl,es:[AWinDisk]         ; souhlas° disk ?
         jne       ModW0Ds9                 ; disk nesouhlas°

; ------ p©°znak aktualizace okna

         and       byte ptr es:[AWinPrm0],not bit2 ; informace o disku nezn†mÇ
         test      es:[AWinPrm1],dh         ; okno povoleno ?
         jz        ModW0Ds9                 ; okno nepovoleno
         and       byte ptr es:[AWinPrm1],not bit1 ; adres†© nenaáten
ModW0Ds9:ret

ModW0Dsk ENDP

CodeWin  ENDS

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                                 Data
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
Data     SEGMENT

; ------ popisovaáe oken

WindPar2 db        bit0+bit1+bit3+bit4+bit5+bit6 ; parametry okna 2
                                            ;   bit 0: 1=zobraz° se jmÇno disku
                                            ;   bit 1: 1=zobraz° se t©°dàn° okna
                                            ;   bit 2: 1=ESC zap/vyp oken
                                            ;   bit 3: 1=zobraz° se li®ta kurzoru
                                            ;   bit 4: 1=konec QSRC bez ALT-
                                            ;   bit 5: 1=autodir pro strom
                                            ;   bit 6: 1=velikost DIR ze stromu

NumRows  db        255                      ; skuteán† vò®ka okna

SegmMWin dw        0                        ; segment masky oken (pro inicializaci)

SegmAkt  dw        0                        ; segment aktivn°ho okna
SegmNAkt dw        0                        ; segment neaktivn°ho okna

; ------ segmenty oken - zachovat po©ad° segmentñ !

SegmL    dw        0                        ; 0: á°slo segmentu levÇho okna
SegmLAdr dw        0                        ; 2: levÇ okno - adres†©
;SegmLTre dw        0                        ; levÇ okno - strom
;SegmLLst dw        0                        ; levÇ okno - seznam
;SegmLQck dw        0                        ; levÇ okno - prohl°ëeá

SegmR    dw        0                        ; 0: á°slo segmentu pravÇho okna
SegmRAdr dw        0                        ; 2: pravÇ okno - adres†©
;SegmRTre dw        0                        ; pravÇ okno - strom
;SegmRLst dw        0                        ; pravÇ okno - seznam
;SegmRQck dw        0                        ; pravÇ okno - prohl°ëeá

; ------ rychlovyhled†v†n°

QSrcBuff label     byte
         db        11 dup("?")              ; buffer rychlovyhled†v†n°
QSrcNum  db        0                        ; poáet znakñ v buff. rychlovyhled.

; -----------------------------------------------------------------------------
;        zobrazen° adres†©ovòch oken
; -----------------------------------------------------------------------------

DskTxt10 db        11,' B volnò z '
DskTxt11 db        11,' B volnÇ z '
DskTxt12 db        13,' B volnòch z '
;DskTxt13 db        6,'CD-ROM'
DskTxt14 db        1,'-'

DskTxt20 db        15,' soubor zab°r† '
DskTxt21 db        18,' soubory zab°raj° '
DskTxt22 db        16,' souborñ zab°r† '

DskTxt30 db        5,' bajt'
DskTxt31 db        6,' bajty'
DskTxt32 db        6,' bajtñ'
DskTxt33 db        2,' B'

DskTxt40 db        3,' v '
DskTxt41 db        4,' ve '

DskTxt50 db        9,' souboru '
DskTxt51 db        11,' souborech '
DskTxt52 db        10,' adres†©i '
DskTxt53 db        12,' adres†©°ch '

DskTxtP  db        '<POD--ADR>'
DskTxtN  db        '<NAD--ADR>'

DskTxtE  db        5,4,'Prog'

; ------ aktu†ln° barvy (màn° se podle toho, zda je adres†©, strom, seznam)

ColXWin1 db        1bh                      ; bàën† barva adres†©ovÇho okna
ColXWin2 db        1eh                      ; vysv°cen† barva adres†©. okna
ColXWin3 db        30h                      ; barva kurzoru adres†©. okna
ColXWin4 db        3eh                      ; kurzor - vysv°cen† barva

ColXWinT label     byte
         db        07h                      ; barva poloëky ".."
         db        1bh                      ; barva adres†©ñ
         db        13h                      ; barva HID/SYS
         db        1fh                      ; barva programñ

         db        FileTMax dup(1dh)        ; uëivatelskÇ typy souborñ

; ------ n†rodnostn° konfigurace

OddelRad db        ''''                     ; oddàlovac° znak ©†dñ á°sel
OddelDes db        '.'                      ; oddàlovac° znak desetinnòch m°st
OddelPol db        ','                      ; oddàlovaá poloëek v datech
ZnakTim  db        ':'                      ; znak oddàlovaáe áasu (":", ".")
ZnakDat  db        '.'                      ; znak oddàlovaáe data
                                            ; (moënÇ znaky ".", "-", "/", ":")
FormDat  db        1                        ; form†t data
                                            ;   0 = màs°c/den/rok (USA)
                                            ;   1 = den/màs°c/rok (EVROPA)
                                            ;   2 = rok:màs°c:den (JAPONSKO)


SegmFGrp dw        0                        ; segment definic skupin souborñ
                                            ;  struktura:  0: (2) velikost dat
                                            ;             N*4 poloëky p©°pon
                                            ;                  (1) á°slo skupiny
                                            ;                  (3) p©°pona

Data     ENDS
         END

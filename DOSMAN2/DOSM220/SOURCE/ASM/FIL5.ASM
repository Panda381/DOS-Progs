
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                              F I L E  -  5
;
;                    Obsluha souborñ - Kop°rov†n° a P©esun
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
;                      P©esun souborñ a adres†©ñ
;
; *****************************************************************************
;˛
; Pozor na p©esouv†n° adres†©e, kterò je v jinÇm oknà jako aktivn° - DOS
; to nemus° povolit (je-li to aktivn° adres†© disku)

AWMMnuSJ LABEL     FAR

         mov       ax,word ptr ds:[SMnuVert+MnuPoz] ; pozice p©edchoz°ho okna
         add       ax,407h                  ; posun okna
         mov       word ptr ds:[si+MnuPoz],ax        ; pozice okna
         jmp       far ptr VertMenu

; ------ zah†jen° operace z menu

MoveFil  LABEL     FAR

         add       sp,4                     ; zru®en° n†vratovÇ adresy
         mov       bx,ds:[si+MnuAkt]        ; aktivn° zvolen† poloëka
         mov       al,cs:[bx+CopSouTb-1]    ; parametry pro vòbàr poloëek

; ------ vstupn° bod z funkán° kl†vesy (AL=typ operace)

MoveFilF LABEL     FAR

         mov       byte ptr ds:[CopyParD],bit6 ; p©°znak p©esunu
         jmp       short CopyFl04

; *****************************************************************************
;
;                      Kop°rov†n° souborñ a adres†©ñ
;
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) adresa masky dlouhÇho jmÇna v z†sobn°ku
;                   SS:[BP-4] (2)         (dÇlka masky dlouhÇho jmÇna v z†sobn°ku)
;                   SS:[BP-6] (2) adresa dlouhÇho jmÇna souboru v z†sobn°ku
;                   SS:[BP-8] (2)         (dÇlka dlouhÇho jmÇna souboru v z†sobn°ku)
;                   SS:[BP-10] (2) adresa c°lovÇho jmÇna souboru v z†sobn°ku
;                   SS:[BP-12] (2)       (dÇlka c°lovÇho jmÇna souboru v z†sobn°ku)
;                             (256) maska dlouhÇho jmÇna
;                             (256) uschovanÇ dlouhÇ jmÇno souboru
;                           (2*256) c°lovÇ dlouhÇ jmÇno
; -----------------------------------------------------------------------------
; Soubory mus° bòt p©i operaci poskytov†ny se zvò®en°m hloubky vno©en° max.
; o 1 £rove§, protoëe jsou prov†dàny korekce dlouhòch jmen na kr†tk†. Pouze
; u seznamu hled†n° nemus° bòt podadres†©e, protoëe se nevytv†©ej° s dlouhòmi
; jmÇny.
; *****************************************************************************
;˛
AWMMnuSK LABEL     FAR

         mov       ax,word ptr ds:[SMnuVert+MnuPoz] ; pozice p©edchoz°ho okna
         add       ax,507h                  ; posun okna
         mov       word ptr ds:[si+MnuPoz],ax        ; pozice okna
         jmp       far ptr VertMenu

CopSouTb db        bit0 + bit4 + bit6 + bit7; kurzor
         db        bit1 + bit4 + bit6 + bit7; oznaáenÇ
         db        bit2                     ; soubory
         db        bit2 + bit4 + bit6 + bit7; v®echny
         db        bit3 + bit4 + bit6       ; zadanÇ

; ------ zah†jen° operace z menu DS:SI

CopyFil  LABEL     FAR

         add       sp,4                     ; zru®en° n†vratovÇ adresy
         mov       bx,ds:[si+MnuAkt]        ; aktivn° zvolen† poloëka
         mov       al,cs:[bx+CopSouTb-1]    ; parametry pro vòbàr poloëek

; ------ vstupn° bod z funkán° kl†vesy (AL=typ operace)

CopyFilF LABEL     FAR

; ------ inicializace parametrñ

         mov       byte ptr ds:[CopyParD],bit5 ; p©°znak operace kop°rov†n°
CopyFl04:mov       byte ptr ds:[ExistPar],0 ; inicializace p©°znakñ p©episu
         mov       byte ptr ds:[CopyRusP],0 ; parametry pro ru®en° R/O poloëek
         call      far ptr ClosMnuA         ; uzav©en° v®ech oken menu

; ------ p©°prava lok†ln°ho bufferu

         push      bp
         mov       bp,sp
         sub       sp,12+256
         mov       ss:[bp-2],sp             ; adresa masky dlouhÇho jmÇna
         sub       sp,256
         mov       ss:[bp-6],sp             ; adresa dlouhÇho jmÇna
         sub       sp,2*256
         mov       ss:[bp-10],sp            ; adresa c°lovÇho dlouhÇho jmÇna

; ------ inicializace vyhled†v†n° souborñ (AL=typ operace)

         call      far ptr InitFFil         ; inicializace vyhled†v†n°
         jc        CopyFil0                 ; nen° ë†dnò soubor k operaci

; ------ vytvo©en° pracovn°ho datovÇho bufferu (BX=typ operace !)

         call      far ptr CreatBuf         ; vytvo©en° pracovn°ho bufferu
         jc        CopyFil0                 ; chyba

; ------ zad†n° souborñ textem (BX=typ operace !)

         test      byte ptr ds:[FileTyp],bit3 ; je specifikace textem ?
         jz        CopyFil3                 ; nen° specifikace textem
CopyFl00:mov       si,offset SKZMLin        ; menu zad†n° souborñ kop°rov†n°
         test      byte ptr ds:[CopyParD],bit5 ; je kop°rov†n° ?
         jnz       CopyFl06                 ; je kop°rov†n°
         mov       si,offset SJZMLin        ; menu zad†n° souborñ pro p©esun
CopyFl06:push      bx
         call      far ptr Lin0Menu         ; obsluha volby
         pop       bx
         jnc       CopyFil1                 ; volba OK

; ------ zru®en° lok†ln°ho bufferu, p©eru®en° operace

CopyFil0:mov       sp,bp
         pop       bp
         jmp       far ptr Main0

; ------ rozbor zad†n° parametrñ operace (BX=typ operace !)

CopyFil1:call      far ptr RozborZ          ; rozbor zad†n° parametrñ operace
         jc        CopyFil0                 ; p©eru®en° operace
         jnz       CopyFl00                 ; opakov†n° zad†n°

; ------ doplnàn° na plnou cestu (BX=typ operace !)

         call      far ptr RozbFPth         ; doplnàn° na plnÇ jmÇno

; ------ zad†n° c°le operace (BX=typ operace !)

CopyFil3:mov       si,offset SK1MLin        ; menu pro kop°rov†n°
         test      byte ptr ds:[CopyParD],bit5 ; je kop°rov†n° ?
         jnz       CopyFl31                 ; je kop°rov†n°
         mov       si,offset SJ1MLin        ; menu zad†n° c°le
CopyFl31:call      CopyFPrp                 ; p©°prava p©ep°naáñ
         call      CopPred                  ; p©edvolby a zad†n° c°le
         jc        CopyFil0                 ; p©eru®en° operace

; ------ £schova masky dlouhÇho jmÇna

         push      ss
         pop       es                       ; ES <- segment bufferu
         mov       si,offset LinBuff        ; buffer zadanÇho textu
         mov       ch,0
         mov       cl,ds:[LinNum]           ; dÇlka zadanÇho textu
         cld
CopFl312:mov       di,ss:[bp-2]             ; adresa masky dlouhÇho jmÇna
CopFl314:jcxz      CopFl316                 ; nen° dal®° znak
         lodsb                              ; naáten° znaku
         dec       cx                       ; sn°ëen° á°taáe znakñ
         cmp       al,"\"                   ; je adres†© ?
         je        CopFl312                 ; inicializace ukazatele
         cmp       al,":"
         je        CopFl312
         stosb                              ; uloëen° znaku masky
         jmp       short CopFl314           ; dal®° znak

CopFl316:mov       byte ptr es:[di],0       ; koncovò znak 0

; ------ inicializaán° zobrazen° textu

         mov       si,offset CopyTxt1       ; text "Kop°ruji"
         test      byte ptr ds:[CopyParD],bit5 ; je kop°rov†n° ?
         jnz       CopyFl32                 ; je kop°rov†n°
         mov       si,offset MoveTxt1       ; text "P©esov†m"
CopyFl32:call      far ptr InfDisp0         ; zobrazen° textu

; ------ p©°prava plnÇ c°lovÇ cesty

         call      far ptr InitFCil         ; rozbor zad†n° c°le kop°rov†n°
         jc        CopyFil0                 ; chyba nebo p©eru®en° operace
         test      byte ptr ds:[CopyPrD2],bit7 ; c°lovÇ jmÇno zru®it ?
         jz        CopyFl33                 ; c°lovÇ jmÇno nezru®eno

         mov       di,ss:[bp-2]             ; adresa masky dlouhÇho jmÇna
         mov       byte ptr ss:[di],0       ; koncovò znak 0

; ------ up©esnàn° c°le p©esunu (je p©ednastaven p©°znak p©esunu mezi disky)

CopyFl33:mov       al,ds:[CilPath]          ; c°lovò disk
         cmp       al,ds:[FilePath]         ; je stejnò disk ?
         jne       CopFl332                 ; nen° stejnò disk
         test      byte ptr ds:[CopyParD],bit6 ; je p©esun mezi disky ?
         jz        CopyFl34                 ; nen° p©esun mezi disky
         xor       byte ptr ds:[CopyParD],bit6+bit7 ; p©°znak p©esunu na disku
         jmp       short CopyFl34

; ------ aktualizace oken s c°lovòm diskem AL (jen pokud se li®° od zdrojovÇho)

CopFl332:sub       al,"A"                   ; korekce na á°slo disku
         mov       ah,bit3+bit4+bit5        ; asi aktualizovat v®e
         call      far ptr ModWDisk         ; aktualizace oken pro disk AL
         call      far ptr MainRead         ; obnoven° naáten° oken
         call      far ptr DispAll          ; zobrazen° v®eho
         call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jc        CopyFl41                 ; p©eru®en° operace

; ------ p©°prava parametrñ c°lovÇho disku

CopyFl34:call      far ptr HistADir         ; uloëen° adres†©e do historie
         call      far ptr InitFSet         ; inicializace oznaáen° poloëek
         call      CopyGDsk                 ; naáten° informac° o c°lovÇm disku

; ------ poskytnut° dal®°ho souboru k operaci

CopyFil4:call      far ptr DispTime         ; obsluha áasu
         call      far ptr DarkNul          ; nulov†n° stm°vaáe obrazovky
         call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jc        CopyFl41                 ; p©eru®en° operace
         call      far ptr GetFFil          ; poskytnut° souboru
         jnc       CopyFl42
CopyFl41:jmp       CopyFil9                 ; nen° dal®° soubor - konec
CopyFl42:call      far ptr DispAAWn         ; zobrazen° aktivn°ho okna

; ------ £schova dlouhÇho jmÇna souboru

         and       byte ptr ds:[CopyPrD2],not bit5 ; nen° dlouhÇ jmÇno
         test      byte ptr ds:[Win95Par],bit2 ; je z†kaz dlouhòch jmen ?
         jnz       CopFl428                 ; je z†kaz dlouhòch jmen
         test      byte ptr ds:[CopyPrD2],bit1 ; zkr†cen° na kr†tkÇ jmÇno ?
         jnz       CopFl428                 ; je zkr†cen° na kr†tkÇ jmÇno
         call      CopFUsch                 ; £schova dlouhÇho jmÇna

; ------ inicializace parametrñ pro jeden soubor

CopFl428:and       byte ptr ds:[CopyParD],not bit0+bit2+bit3 ; nen° vòstupn° soubor
         mov       ax,word ptr ds:[FileFSiz] ; velikost souboru LOW
         mov       word ptr ds:[CopyDSiz],ax ; zbòvaj°c° velikost LOW
         mov       word ptr ds:[CilFSize],ax
         mov       ax,word ptr ds:[FileFSiz+2] ; velikost souboru HIGH
         mov       word ptr ds:[CopyDSiz+2],ax ; zbòvaj°c° velikost LOW
         mov       word ptr ds:[CilFSize+2],ax
         and       byte ptr ds:[ExistPar],not bit0+bit6+bit7 ; nen° pokraáov†n° dal®°m diskem
         mov       word ptr ds:[CopyDRea],0 ; ukazatel naátenòch dat
         mov       word ptr ds:[CopyDRea+2],0
         mov       ax,ds:[FileFDat]
         mov       ds:[CilFDate],ax
         mov       ax,ds:[FileFTim]
         mov       ds:[CilFTime],ax
         mov       al,ds:[FileFAtr]
         mov       ds:[CilFAtr],al

; ------ sestaven° c°lovÇho jmÇna souboru

         call      far ptr GetFCil          ; sestaven° jmÇna c°lovÇho souboru
         test      byte ptr ds:[CopyPrD2],bit5 ; m† c°l dlouhÇ jmÇno ?
         jz        CopFl429                 ; c°l nem† dlouhÇ jmÇno
         call      GetFLCil                 ; c°l s dlouhòm jmÇnem

; ------ test a normalizace c°lovÇho souboru

CopFl429:call      CopyTCil                 ; test c°lovÇho souboru
         jc        CopFl42A                 ; soubor nenalezen
         or        byte ptr ds:[ExistPar],bit0 ; soubor jië existuje

; ------ zobrazen° hl†®en° o kop°rov†n°

CopFl42A:call      CopyHlas                 ; hl†®en° o kop°rov†n°

; ------ test, zda to je adres†©

         push      ds
         pop       es                       ; ES <- datovò segment
         test      byte ptr ds:[FileFAtr],DIR ; je to adres†© ?
         jnz       CopyFl43                 ; je to adres†©
         jmp       CopyFil5                 ; nen° to adres†©

; ------ test, zda je adres†© p©i n†vratu

CopyFl43:test      byte ptr ds:[FileParm],bit3 ; je adres†© p©i n†vratu ?
         jz        CopyFl44                 ; nen° to adres†© p©i n†vratu
         test      byte ptr ds:[CopyParD],bit5 ; je kop°rov†n° ?
         jnz       CopFl433                 ; je kop°rov†n° - nic se nedàje

; ------ p©i p©esunu se adres†© p©i n†vratu zru®°

         mov       si,offset FilePath       ; zdrojovò adres†©
         call      far ptr DelDir           ; zru®en° adres†©e
         jnc       CopFl432                 ; operace OK
         jmp       CopyFl45                 ; adres†© nebyl zru®en

CopFl432:mov       di,offset FileFPol       ; poloëka adres†©e
         mov       dx,ds                    ; DX <- datovò segment
         mov       cx,ds:[FilePthN]         ; dÇlka textu adres†©e
         call      far ptr DelWFile         ; zru®en° starÇho jmÇna adres†©e
         call      far ptr DispWAkt         ; podm°nànÇ zobrazen° oken
CopFl433:jmp       CopyFl47                 ; dal®° poloëka

; ------ test, zda je p©ejmenov†n° adres†©e ve stejnÇm adres†©i

CopyFl44:test      byte ptr ds:[CopyParD],bit7 ; je p©esun na disku ?
         jz        CopyFl46                 ; nen° p©esun na disku
         mov       si,offset FilePath       ; zdrojovÇ jmÇno
         mov       di,offset CilPath        ; c°lovÇ jmÇno
         mov       cx,ds:[FilePthN]         ; dÇlka textu adres†©e
         cmp       cx,ds:[CilCilPN]         ; souhlas° adres†© ?
         jne       CopyFl46                 ; nesouhlas° adres†©
         cld
         repe      cmpsb                    ; porovn†n° adres†©ñ
         jne       CopyFl46                 ; adres†© nesouhlas°

; ------ p©ejmenov†n° adres†©e na disku v jednom adres†©i

         mov       si,offset FilePath       ; zdrojovÇ jmÇno souboru

         test      byte ptr ds:[CopyPrD2],bit5 ; m† c°l dlouhÇ jmÇno ?
         jz        CopFl445                 ; c°l nem† dlouhÇ jmÇno

         mov       di,ss:[bp-10]            ; c°lovÇ jmÇno
         mov       dx,ss                    ; DX <- segment c°lovÇho jmÇna
         call      far ptr RenXFile         ; p©ejmenov†n° adres†©e
         call      KorFCil                  ; korekce c°lovÇho jmÇna
         mov       dx,ds                    ; DX <- datovò segment
         jnc       CopFl446                 ; operace OK

CopFl445:mov       di,offset CilPath        ; c°lovÇ jmÇno souboru
         mov       dx,ds                    ; DX <- datovò segment
         call      far ptr RenFile          ; p©ejmenov†n° souboru
         jnc       CopFl446                 ; adres†© p©ejmenov†n OK

         or        byte ptr ds:[FileParm],bit5 ; z†kaz vno©en° do adres†©e
         call      far ptr RenDErr          ; chyba p©ejmenov†n° adres†©e
         jmp       CopyFil7

CopFl446:or        byte ptr ds:[FileParm],bit5 ; z†kaz vno©en° do adres†©e
         mov       cx,ds:[FilePthN]         ; dÇlka textu adres†©e
         mov       di,offset FileFPol       ; vzor poloëky (zde je DX=DS !)
         call      far ptr DelWFile         ; zru®en° starÇho jmÇna adres†©e

         mov       si,offset CilPath        ; SI <- novÇ jmÇno adres†©e
         mov       cx,ds:[CilCilPN]         ; dÇlka textu adres†©e
         mov       di,offset CilFPol        ; vzor poloëky (zde je DX=DS !)
         call      far ptr InsWFile         ; vytvo©en° poloëky v oknà

         call      far ptr DispWAkt         ; podm°nànÇ zobrazen° oken
CopyFl45:jmp       CopyFl72                 ; dal®° poloëka

; ------ test, zda je cyklickÇ kop°rov†n° adres†©e do sebe

CopyFl46:mov       si,offset FilePath       ; zdrojovÇ jmÇno
         mov       di,offset CilPath        ; c°lovÇ jmÇno
         mov       cx,ds:[FileFilN]         ; dÇlka plnÇho textu adres†©e
         cld
         repe      cmpsb                    ; porovn†n° adres†©ñ
         jne       CopFl468                 ; adres†© nesouhlas°
         cmp       byte ptr ds:[di],"\"     ; je oddàlovaá ?
         jne       CopFl468                 ; nen° cyklicky
         or        byte ptr ds:[FileParm],bit5 ; z†kaz vno©en° do adres†©e
         mov       si,offset FilePath       ; zdrojovÇ jmÇno souboru
         call      far ptr CopCErr          ; chyba cyklickÇho kop°rov†n°
         jmp       CopyFil7

; ------ je to adres†© p©i vno©en° - vytvo©en° c°lovÇho adres†©e

CopFl468:mov       cx,ds:[FileFTim]         ; áas adres†©e
         mov       dx,ds:[FileFDat]         ; datum adres†©e
         mov       bl,ds:[FileFAtr]         ; atributy poloëky
         call      CopCreaD                 ; vytvo©en° adres†©e ES:SI
CopyFl47:jmp       CopyFil7                 ; dal®° poloëka

; ------ test, zda se kop°ruje soubor s†m do sebe

CopyFil5:test      byte ptr ds:[ExistPar],bit0 ; soubor nalezen ?
         jz        CopyFl54                 ; c°lovò soubor nenalezen
         mov       si,offset FilePath       ; zdrojovò soubor
         mov       di,offset CilPath        ; c°lovò soubor
         mov       cx,ds:[FileFilN]         ; dÇlka adres†©e se souborem
         inc       cx                       ; váetnà koncovÇ 0
         cld
         push      si
         repe      cmpsb                    ; porovn†n° jmen
         pop       si                       ; SI = zdrojovò soubor
         jne       CopyFl54                 ; je to OK
;         test      byte ptr ds:[CopyParD],bit7 ; je p©esun na disku ?
;         jz        CopyFl53                 ; nen° p©ejmenov†n° souboru
;         jmp       CopFl662                 ; je p©ejmenov†n° souboru

; ------ p©i p©esunu se nic nehl†s°

CopyFl53:test      byte ptr ds:[CopyParD],bit5 ; je kop°rov†n° ?
         jz        CopyFl45                 ; je p©esun - nic se nedàje
         call      far ptr CopErEq          ; chybovÇ hl†®en°
         jmp       short CopyFl57           ; dal®° soubor

; ------ rozli®en° operace, pokud soubor jië existuje

CopyFl54:call      CopyExis                 ; test, zda poloëka jië existuje
         jnc       CopyFl58                 ; soubor se zapisuje
CopyFl57:jmp       CopyFil8                 ; poloëka se nep©episuje

; ------ pro znakovÇ za©°zen° p©°mo skok na kop°rov†n°

CopyFl58:test      byte ptr ds:[ExistPar],bit6 ; je to znakovÇ za©°zen° ?
         jz        CopyFl59                 ; nen° to znakovÇ za©°zen°
         jmp       CopyFl68                 ; obsluha znakovÇho za©°zen°

; ------ test, zda m† bòt odstranàn atribut poloëky R/O

CopyFl59:test      byte ptr ds:[ExistPar],bit1+bit5 ; je p©epis/p©ipojen° souboru ?
         jz        CopyFil6                 ; nen° p©epis/p©ipojenò souboru
         test      byte ptr ds:[ExistPar],bit7 ; je dal®° disk ?
         jnz       CopyFil6                 ; je dal®° disk - p©ep°®e se vëdy
         test      byte ptr ds:[CilDTA+DTAAtrib],RO ; je soubor R/O ?
         jz        CopyFil6                 ; nen° soubor R/O
         call      CopyRO                   ; test p©episu poloëek R/O
         jc        CopyFl57                 ; poloëka se nep©episuje

; ------ pro s°üovò disk se volnÇ m°sto netestuje

CopyFil6:mov       bl,ds:[CilPath]          ; c°lovò disk
         mov       bh,0
         mov       al,ds:[bx+DiskITab-"A"]  ; parametry disku
         and       al,bit0+bit1+bit2        ; typ tisku
         cmp       al,4                     ; je to s°üovò disk ?
         je        CopyFl64                 ; pro s°üovò disk se netestuje

; ------ test volnÇho m°sta na disku

         test      byte ptr ds:[ExistPar],bit7 ; je dal®° disk ?
         jnz       CopyFl64                 ; je dal®° disk - pokraáuje bez dotazu
         test      byte ptr ds:[ExistPar],bit5 ; p©epis souboru ?
         jnz       CopyFl62                 ; je p©epis souboru
         test      byte ptr ds:[CopyParD],bit7 ; je p©esun na disku ?
         jnz       CopyFl64                 ; je p©esun na disku
CopyFl62:call      CopyFre                  ; test volnÇho m°sta disku
         jc        CopyFl57                 ; soubor se nekop°ruje

; ------ odstranàn° atributu R/O c°lovÇ poloëky

CopyFl64:test      byte ptr ds:[ExistPar],bit0 ; nalezena poloëka ?
         jz        CopyFl66                 ; nenalezena poloëka
         test      byte ptr ds:[CilDTA+DTAAtrib],RO ; je soubor R/O ?
         jz        CopyFl66                 ; nen° soubor R/O

         mov       cl,ds:[CilDTA+DTAAtrib]
         and       cl,not RO                ; nulov†n° atributu R/O
         mov       si,offset CilPath        ; c°lovò soubor
         call      far ptr SetAFile         ; zru®en° atributu R/O

; ------ p©esun souboru na disku

CopyFl66:test      byte ptr ds:[CopyParD],bit7 ; je p©esun na disku ?
         jz        CopyFl67                 ; nen° p©esun na disku
         test      byte ptr ds:[ExistPar],bit5 ; je p©ipojen° souboru ?
         jnz       CopyFl67                 ; je p©ipojen° souboru

; ------ zru®en° p©esouvanÇho souboru p©i p©episu na disku

         test      byte ptr ds:[ExistPar],bit1 ; je p©epis souboru ?
         jz        CopFl662                 ; nen° p©epis souboru
         call      CopyFDel                 ; zru®en° p©episovanÇho souboru
         jc        CopFl682                 ; chyba

; ------ p©ejmenov†n° souboru na disku

CopFl662:call      CopF6Ren                 ; p©ejmenov†n° souboru/adres†©e
         jnc       CopFl664                 ; soubor p©ejmenov†n OK

; ------ vytvo©en° c°lovÇho adres†©e

         call      CopFCDir                 ; vytvo©en° c°lovÇho adres†©e

; ------ druhò pokus o p©ejmenov†n° souboru na disku

         call      CopF6Ren                 ; p©ejmenov†n° souboru/adres†©e
         jnc       CopFl664                 ; soubor p©ejmenov†n OK

         call      far ptr CreatErr         ; chyba vytvo©en° souboru
         jmp       short CopFl682


CopFl664:mov       cx,ds:[FilePthN]         ; dÇlka textu adres†©e
         mov       di,offset FileFPol       ; vzor poloëky (zde je DX=DS !)
         call      far ptr DelWFile         ; zru®en° starÇho jmÇna souboru

         mov       si,offset CilPath        ; SI <- novÇ jmÇno souboru
         mov       cx,ds:[CilCilPN]         ; dÇlka textu adres†©e
         mov       di,offset CilFPol        ; vzor poloëky (zde je DX=DS !)
         call      far ptr InsWFile         ; vytvo©en° poloëky v oknà

         call      far ptr DispWAkt         ; podm°nànÇ zobrazen° oken
         jmp       CopyFl72

; ------ vytvo©en° p©echodnÇho vòstupn°ho souboru, je-li p©epis souboru

CopyFl67:test      byte ptr ds:[ExistPar],bit1 ; je p©epis souboru ?
         jz        CopyFl68                 ; nen° p©epis souboru
         call      CopyFTmp                 ; vytvo©en° p©echodnÇho souboru
         jnc       CopyFl68                 ; soubor vytvo©en OK
         call      far ptr TestBreak        ; je p©eru®en° operace ?
         jc        CopFl682                 ; p©eru®en° operace
         call      CopyFDel                 ; jinak zru®en° p©episovanÇho souboru
         jc        CopFl682                 ; chyba

; ------ otev©en° zdrojovÇho souboru

CopyFl68:mov       si,offset FilePath       ; zdrojovò soubor
         call      far ptr OpenR            ; otev©en° pro áten°
         jnc       CopFl684                 ; soubor otev©en OK

; ------ chyba otev©en° zdrojovÇho souboru

         call      far ptr OpenRErr         ; chyba otev©en° soubor
CopFl682:jmp       CopyFil8                 ; chyba

CopFl684:mov       ds:[FileIdnt],ax         ; identifik†tor zdroje

; ------ otev©en° existuj°c°ho souboru pro z†pis (p©i v°ce disc°ch mñëe bòt vytvo©en°)

         test      byte ptr ds:[CopyParD],bit3 ; je p©echodnò soubor ?
         jz        CopFl685
         jmp       CopyFl73                 ; je jië p©echodnò soubor

; ------ otev©en° s dlouhòm jmÇnem

CopFl685:test      byte ptr ds:[CopyPrD2],bit5 ; m† c°l dlouhÇ jmÇno ?
         jz        CopFl688                 ; nen° dlouhÇ jmÇno

         push      ss
         pop       es                       ; ES <- segment bufferu
         mov       si,ss:[bp-10]            ; c°lovÇ jmÇno

         test      byte ptr ds:[ExistPar],bit5 ; je p©ipojen° souboru ?
         jz        CopFl686                 ; nen° p©ipojen° souboru
         call      far ptr OpenXRW          ; otev©en° s dlouhòm jmÇnem
         call      KorFCil                  ; korekce c°lovÇho jmÇna
         jnc       CopFl689                 ; soubor otev©en OK
CopFl686:call      far ptr CreaXFil         ; vytvo©en° s dlouhòm jmÇnem
         call      KorFCil                  ; korekce c°lovÇho jmÇna
         mov       si,offset CilPath        ; jmÇno vòstupn°ho souboru
         push      ds
         pop       es
         jnc       CopyFl6B                 ; soubor vytvo©en OK

; ------ otev©en° s kr†tkòm jmÇnem

CopFl688:mov       si,offset CilPath        ; jmÇno vòstupn°ho souboru
         test      byte ptr ds:[ExistPar],bit5 ; je p©ipojen° souboru ?
         jz        CopyFL69                 ; nen° p©ipojen° souboru
         call      far ptr OpenW            ; otev©en° pro z†pis
         jc        CopyFL69                 ; chyba ? - moën† je dal®° disk
CopFl689:push      ds
         pop       es
         call      far ptr SizeFile         ; ukazatel na konec souboru
         jmp       short CopyFL6A

CopyFL69:call      far ptr CreatFil         ; vytvo©en° souboru
         jnc       CopyFl6B                 ; soubor vytvo©en OK

; ------ vytvo©en° c°lovÇho adres†©e

         call      CopFCDir                 ; vytvo©en° c°lovÇho adres†©e

; ------ druhò pokus o vytvo©en° souboru

         test      byte ptr ds:[CopyPrD2],bit5 ; m† c°l dlouhÇ jmÇno ?
         jz        CopFl698                 ; nen° dlouhÇ jmÇno

         push      ss
         pop       es                       ; ES <- segment bufferu
         mov       si,ss:[bp-10]            ; c°lovÇ jmÇno
         call      far ptr CreaXFil         ; vytvo©en° s dlouhòm jmÇnem
         call      KorFCil                  ; korekce c°lovÇho jmÇna
         mov       si,offset CilPath        ; jmÇno vòstupn°ho souboru
         push      ds
         pop       es
         jnc       CopyFl6B                 ; soubor vytvo©en OK

CopFl698:call      far ptr CreatFil
         jnc       CopyFl6B                 ; soubor vytvo©en OK

; ------ chyba - vòstupn° soubor nelze vytvo©it

         call      far ptr CreatErr         ; chyba vytvo©en° souboru
         jmp       CopFl682           ; p©eru®en° operace

CopyFl6B:or        byte ptr ds:[CopyParD],bit0 ; vòstupn° soubor vytvo©en
CopyFL6A:mov       ds:[CilIdent],ax         ; identifik†tor souboru
         test      byte ptr ds:[ExistPar],bit6 ; je to znakovÇ za©°zen° ?
         jz        CopyFl73                 ; nen° to znakovÇ za©°zen°
         call      far ptr TestDev          ; nastaven° bin†rn°ho m¢du za©°zen°

; ------ zkop°rov†n° bloku dat (do konce souboru nebo do konce diskety)
;˛
CopyFl73:call      CopyCop                  ; zkop°rov†n° dat souboru

; ------ uzav©en° souborñ (CY=je chyba operace)

CopyFl77:call      CopyClos                 ; uzav©en° souborñ
         jc        CopyFil8                 ; p©i chybà dal®° soubor

; ------ operace provedena OK

CopyFil7:test      byte ptr ds:[ExistPar],bit7 ; pokraáuje se d†l ?
         jz        CopyFl72                 ; nepokraáuje se

; ------ vòmàna disku

         call      CopyFre0                 ; vòmàna disku
         jc        CopyFil8                 ; p©eru®en° operace
         jmp       CopyFil5                 ; pokraáov†n° v operaci

; ------ p©i p©esunu zru®en° zdrojovÇho souboru

CopyFl72:test      byte ptr ds:[CopyParD],bit5 ; je kop°rov†n° ?
         jnz       CopFl728                 ; je kop°rov†n°
         test      byte ptr ds:[ExistPar],bit6 ; je to za©°zen° ?
         jnz       CopFl728                 ; je to za©°zen° -> neru®it
         test      byte ptr ds:[ExistPar],bit5 ; je p©ipojen° souboru ?
         jnz       CopFl722                 ; je p©ipojen° souboru
         test      byte ptr ds:[CopyParD],bit7 ; je p©esun na disku ?
         jnz       CopFl728                 ; je p©esun na disku

CopFl722:push      ds
         pop       es
         mov       si,offset FilePath
         test      byte ptr ds:[FileFAtr],RO ; je R/O ?
         jz        CopFl724                 ; nen° R/O
         mov       cl,0
         call      far ptr SetAFile         ; zru®en° atributu R/O
CopFl724:call      far ptr DelFile          ; zru®en° zdrojovÇho souboru
         jc        CopFl728

         mov       dx,ds                    ; DX <- datovò segment
         mov       di,offset FileFPol       ; ru®en† poloëka
         mov       cx,ds:[FilePthN]         ; dÇlka textu adres†©e
         call      far ptr DelWFile
         call      far ptr DispWAkt         ; podm°nànÇ zobrazen° oken

CopFl728:call      far ptr ResFFil          ; nulov†n° oznaáen° poloëky

;; ------ aktualizace oken (vytvo©en° c°lovÇ poloëky)
;
;         push      ds
;         pop       es
;         mov       si,offset CilPath
;         mov       cx,ds:[CilCilPN]         ; dÇlka textu adres†©e
;         mov       di,offset FileFPol       ; vzor poloëky
;         mov       dx,ds                    ; DX <- segment vzoru poloëky
;         call      far ptr InsWFile         ; vytvo©en° poloëky v oknà
;         call      far ptr DispWAkt         ; podm°nànÇ zobrazen° oken
;
;; ------ oprava volnÇho m°sta na disku
;
;         mov       ax,word ptr ds:[CopyDUlo] ; ukazatel uloëenòch dat
;         mov       dx,word ptr ds:[CopyDUlo+2]
;         mov       cx,ds:[CopyDBlk]         ; velikost bloku
;         dec       cx
;         add       ax,cx                    ; zaokrouhlen° nahoru
;         adc       dx,0
;         inc       cx
;         cmp       dx,cx
;         jae       CopyFil8
;         div       cx                       ; DX <- zbytek v bloku
;         sub       cx,dx                    ; CX <- nevyuëit† data v bloku
;         xor       ax,ax
;         sub       word ptr ds:[CopyDFre],cx ; oprava volnÇho m°sta
;         sbb       word ptr ds:[CopyDFre+2],ax
;         jnc       CopyFil8
;         mov       word ptr ds:[CopyDFre],ax
;         mov       word ptr ds:[CopyDFre+2],ax

; ------ zru®en° p©echodnÇho souboru (p©i p©eru®en° operace)

CopyFil8:mov       ax,ds:[FileIdnt]         ; identifik†tor vstupn°ho souboru
         call      far ptr ClosFile         ; uzav©en° souboru
         mov       ds:[FileIdnt],ax         ; p©°znak uzav©en° souboru

         test      byte ptr ds:[CopyParD],bit3 ; je dosud p©echodnò soubor ?
         jz        CopyFl84                 ; nen° jië p©echodnò sobor
         call      far ptr ZapKrit          ; zapnut° kritickÇho reëimu
         mov       ax,ds:[CilIdent]         ; identifik†tor p©echodnÇho souboru
         call      far ptr ClosFile         ; uzav©en° souboru
         mov       ds:[CilIdent],ax         ; zru®en° identifik†toru
         push      ds
         pop       es
         mov       si,offset CilTempF       ; p©echodnò c°lovò soubor
         call      far ptr DelFile          ; zru®en° p©echodnÇho souboru
         and       byte ptr ds:[CopyParD],not bit3 ; nen° jië p©echodnò soubor
         call      far ptr VypKrit          ; vypnut° kritickÇ sekce

; ------ p©°prava pro dal®° poloëku

CopyFl84:call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jc        CopyFil9                 ; p©eru®en°
         jmp       CopyFil4                 ; pokraáov†n° operace

; ------ uzav©en° reëimu kop°rov†n° (se zru®en°m lok†ln°ho bufferu)

CopyFil9:jmp       CopyFil0

; ------ p©ejmenov†n° jednoho souboru/adres†©e na disku

CopF6Ren PROC      NEAR

         mov       si,offset FilePath       ; zdrojovÇ jmÇno souboru

         test      byte ptr ds:[CopyPrD2],bit5 ; m† c°l dlouhÇ jmÇno ?
         jz        CopF6Rn2                 ; c°l nem† dlouhÇ jmÇno

         mov       dx,ss                    ; DX <- segment c°lovÇho jmÇna
         mov       di,ss:[bp-10]            ; c°lovÇ jmÇno
         call      far ptr RenXFile         ; p©ejmenov†n° adres†©e
         call      KorFCil                  ; korekce c°lovÇho jmÇna
         mov       dx,ds                    ; DX <- datovò segment
         jnc       CopF6Rn4                 ; operace OK

CopF6Rn2:mov       di,offset CilPath        ; c°lovÇ jmÇno souboru
         mov       dx,ds
         call      far ptr RenFile          ; p©ejmenov†n° souboru
CopF6Rn4:ret

CopF6Ren ENDP

; ------ vytvo©en° c°lovÇho adres†©e pro soubor

CopFCDir PROC      NEAR

         mov       di,offset CilPath        ; jmÇno vòstupn°ho souboru
         mov       si,di
         add       di,ds:[CilCilPN]         ; adresa konce cesty
         mov       bl,ds:[di]               ; £schova znaku
         mov       byte ptr ds:[di],0       ; oznaáen° konce cesty
         mov       cl,0                     ; atributy novÇho adres†©e
         call      far ptr CreaLDir         ; vytvo©en° dlouhÇho adres†©e
         mov       ds:[di],bl               ; n†vrat znaku
         call      far ptr DispWAkt         ; podm°nànÇ zobrazen° oken
         ret

CopFCDir ENDP

; -----------------------------------------------------------------------------
;        p©ep°naá Aktualizace
; -----------------------------------------------------------------------------

SKMnLExA PROC      FAR

         xor       byte ptr ds:[CopyPrD2],bit0 ; zmàna p©ep°naáe
         jmp       short SKMnLEK2

SKMnLExA ENDP

; -----------------------------------------------------------------------------
;        p©ep°naá Kr†tk† jmÇna
; -----------------------------------------------------------------------------

SKMnLExK PROC      FAR

         xor       byte ptr ds:[CopyPrD2],bit1 ; zmàna p©ep°naáe
SKMnLEK2:call      CopyFPrp                 ; p©°prava p©ep°naáñ
         call      far ptr DispMnu          ; novÇ zobrazen° menu
         ret

SKMnLExK ENDP

; -----------------------------------------------------------------------------
;        p©ep°naá Datum
; -----------------------------------------------------------------------------

SKMnLExD PROC      FAR

         xor       byte ptr ds:[CopyPrD2],bit2 ; zmàna p©ep°naáe
         jmp       short SKMnLEK2

SKMnLExD ENDP

; -----------------------------------------------------------------------------
;        p©°prava p©ep°naáñ menu volby c°le operace DS:SI
; -----------------------------------------------------------------------------

CopyFPrp PROC      NEAR

         push      ax
         push      dx

         mov       dl,ds:[CopyPrD2]         ; p©ep°naá dlouhòch jmen
         and       byte ptr ds:[SK1MLBlk+3],not bit1 ; operace povolena
         and       byte ptr ds:[SJ1MLBlk+3],not bit1

         test      byte ptr ds:[Win95Par],bit2 ; povoleno ?
         jz        CopyFPr2                 ; povoleno
         or        byte ptr ds:[SK1MLBlk+3],bit1 ; z†kaz
         or        byte ptr ds:[SJ1MLBlk+3],bit1 ; z†kaz
         or        dl,bit1                  ; kr†tk† jmÇna ano

CopyFPr2:call      far ptr SetSwch          ; nastaven° p©ep°naáñ

         mov       al,ds:[ZnakSwch]         ; zapnut
         test      dl,bit0                  ; aktualizace ?
         jnz       CopyFPr3                 ; p©ep°naá zapnut
         mov       al,ds:[ZnakSwch+1]       ; vypnuto
CopyFPr3:mov       ds:[SJ1MLPl0],al         ; znak p©ep°naáe
         mov       ds:[SK1MLPl0],al         ; znak p©ep°naáe

         mov       al,ds:[ZnakSwch]         ; zapnut
         test      dl,bit1                  ; kr†tk† jmÇna ?
         jnz       CopyFPr4                 ; p©ep°naá zapnut
         mov       al,ds:[ZnakSwch+1]       ; vypnuto
CopyFPr4:mov       ds:[SJ1MLPl1],al         ; znak p©ep°naáe
         mov       ds:[SK1MLPl1],al         ; znak p©ep°naáe

         mov       al,ds:[ZnakSwch]         ; zapnut
         test      dl,bit2                  ; datum ?
         jnz       CopyFPr6                 ; p©ep°naá zapnut
         mov       al,ds:[ZnakSwch+1]       ; vypnuto
CopyFPr6:mov       ds:[SJ1MLPl2],al         ; znak p©ep°naáe
         mov       ds:[SK1MLPl2],al         ; znak p©ep°naáe

         pop       dx
         pop       ax
         ret

CopyFPrp ENDP

; -----------------------------------------------------------------------------
;        £schova dlouhÇho jmÇna souboru do bufferu
; -----------------------------------------------------------------------------

CopFUsch PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      di
         push      es

; ------ £schova typu okna -> AL

         call      far ptr GetAAWin         ; adresa aktivn°ho okna
         mov       al,es:[AWinPrm1]         ; typ okna

; ------ adresa poloëky pod kurzorem -> ES:SI

         call      far ptr GetAKurz         ; poskytnut° adresy kurzoru
         jc        CopFUsc9                 ; nen° kurzor (?)

; ------ test, zda je dlouhÇ jmÇno

         mov       di,ss:[bp-6]             ; adresa dlouhÇho jmÇna
         test      al,bit3                  ; je to adres†©ovÇ okno ?
         jz        CopFUsc4                 ; nen° to adres†©ovÇ okno
         mov       al,es:[si+FileLong]      ; dÇlka dlouhÇho jmÇna
         or        al,al                    ; je dlouhÇ jmÇno ?
         jz        CopFUsc4                 ; nen° dlouhÇ jmÇno

; ------ £schova dlouhÇho jmÇna

         mov       ah,0                     ; AX = dÇlka dlouhÇho jmÇna
         push      ds
         xchg      ax,cx                    ; CX <- dÇlka dlouhÇho jmÇna
         add       si,FileLong+1            ; zaá†tek dlouhÇho jmÇna
         cld
         push      es
         pop       ds                       ; DS <- segment jmÇna
         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         rep       movsb                    ; £schova jmÇna souboru
         mov       al,0
         stosb                              ; koncov† 0
         pop       ds
         jmp       short CopFUsc8

; ------ test, zda se m† kr†tkÇ jmÇno prodlouëit

CopFUsc4:test      byte ptr ds:[CopyPrD2],bit1 ; je zmàna na dlouh† jmÇna ?
         jnz       CopFUsc9                 ; nen° zmàna na dlouh† jmÇna

; ------ dek¢dov†n° kr†tkÇho jmÇna soubor do z†sobn°ku

         push      ds
         push      es
         pop       ds                       ; DS <- segment poloëky
         push      ss
         pop       es                       ; ES <- segment bufferu
         inc       si                       ; zaá†tek jmÇna poloëky
         call      far ptr FileAsc          ; dek¢dov†n° jmÇna poloëky
         pop       ds

;; ------ korekce jmÇna souboru (prvn° p°smeno velkÇ, ostatn° mal†)
;
;         cld
;         mov       si,ss:[bp-6]             ; adresa jmÇna souboru
;         lods      byte ptr ss:[si]         ; naáten° prvn°ho znaku
;         call      far ptr UpCase           ; konverze na velkÇ p°smeno
;         jmp       short CopFUsc7           ; uloëen° znaku
;
;CopFUsc5:lods      byte ptr ss:[si]         ; naáten° znaku
;;         call      far ptr DownCase         ; konverze na malÇ p°smeno
;
;         call      far ptr UpCase           ; konverze na velkÇ p°smeno
;
;CopFUsc7:mov       ss:[si-1],al             ; uloëen° znaku
;         cmp       al,0                     ; je konec textu ?
;         jne       CopFUsc5                 ; dal®° znak

; ------ p©°znak, ëe bude dlouhÇ jmÇno

CopFUsc8:or        byte ptr ds:[CopyPrD2],bit5 ; c°l m† dlouhÇ jmÇno

; ------ n†vrat registrñ

CopFUsc9:pop       es
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

CopFUsch ENDP

; -----------------------------------------------------------------------------
;        p©°prava dlouhÇho jmÇna c°le operace
; -----------------------------------------------------------------------------
;˛
GetFLCil PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ kopie c°lovÇ cesty do bufferu

         mov       di,ss:[bp-10]            ; adresa c°lovÇho jmÇna
         push      ss
         pop       es                       ; ES <- segment bufferu
         mov       si,offset CilPath        ; c°lov† cesta
         mov       cx,ds:[CilCilPN]         ; dÇlka bez souboru
         cld
         rep       movsb                    ; p©enos cesty

; ------ zaji®tàn° oddàlovaáe adres†©e "\"

         dec       di
         mov       al,"\"
         scasb                              ; je oddàlovaá adres†©e ?
         je        GetFLCl2                 ; je oddàlovaá adres†©e
         stosb                              ; uloëen° oddàlovaáe adres†©e

; ------ test, zda bude maska

GetFLCl2:mov       si,ss:[bp-6]             ; adresa dlouhÇho jmÇna
         mov       bx,ss:[bp-2]             ; adresa masky dlouhÇho jmÇna
         test      byte ptr ds:[CopyPrD2],bit6 ; maska se neuplatn° ?
         jnz       GetFLCl3                 ; dlouh† maska se neuplatn°
         cmp       byte ptr ss:[bx],0       ; je maska ?
         jne       GetFLCl4                 ; je maska

; ------ p©enos dlouhÇho jmÇna, nen°-li maskov†n°

GetFLCl3:lods      byte ptr ss:[si]         ; naáten° znaku
         cmp       al,":"                   ; je oddàlovaá za©°zen° ?
         je        GetFLCl3                 ; oddàlovaá za©°zen° se ignoruje
         stosb
         cmp       al,0
         jne       GetFLCl3
         jmp       short GetFLCl9

; ------ p©enos dlouhÇho jmÇna s maskov†n°m

GetFLCl4:xchg      si,bx                    ; SI <- maska, BX <- jmÇno
GetFLC42:lods      byte ptr ss:[si]         ; naáten° znaku masky
         mov       ah,ss:[bx]               ; naáten° znaku jmÇna
         inc       bx                       ; zvò®en° ukazatele jmÇna

         cmp       al,ah                    ; jsou znaky shodnÇ ?
         je        GetFLCl7                 ; znaky jsou shodnÇ - nic nemànit
         or        al,al                    ; konec masky ?
         jz        GetFLCl7                 ; konec masky plat°

         or        ah,ah                    ; je konec jmÇna ?
         jz        GetFLC43                 ; ponech† se na konci
         cmp       ah,"."                   ; bude teáka jmÇna ?
         jne       GetFLC44                 ; nen° teáka jmÇna
GetFLC43:dec       bx                       ; teáka nebo konec se podrë°

GetFLC44:cmp       al,"*"                   ; n†hradn° znak ?
         jne       GetFLC45                 ; nen° n†hradn° znak
         cmp       ah,"."                   ; konec jmÇna ?
         je        GetFLC42                 ; konec jmÇna - dal®° znak
         or        ah,ah                    ; konec jmÇna ?
         jz        GetFLC42                 ; konec jmÇna - dal®° znak
         dec       si                       ; n†hradn° znak se ponech†
         mov       al,"?"                   ; n†hrada

GetFLC45:cmp       al,"."
         jne       GetFLCl5
         dec       bx
GetFLC46:inc       bx
         cmp       byte ptr ss:[bx],0
         je        GetFLCl7
         cmp       byte ptr ss:[bx],al
         jne       GetFLC46                 ; nalezen° teáky nebo konce jmÇna
         inc       bx                       ; p©eskoáen° znaku teáky

GetFLCl5:cmp       al,"?"                   ; n†hradn° znak ?
         jne       GetFLCl7                 ; plat° znak masky

GetFLCl6:xchg      al,ah                    ; AL <- platnò znak jmÇna
GetFLCl7:stosb                              ; uloëen° znaku
         cmp       al,0                     ; konec ?
         jne       GetFLC42                 ; dal®° znak

; ------ n†vrat registrñ

GetFLCl9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

GetFLCil ENDP

; -----------------------------------------------------------------------------
;        korekce dlouhÇho c°lovÇho jmÇna (CY=byla chyba), uchov†v† p©°znaky
; -----------------------------------------------------------------------------

KorFCil  PROC      NEAR

         pushf
         jc        KorFCil9                 ; byla chyba operace
         test      byte ptr ds:[CopyPrD2],bit5 ; je dlouhÇ jmÇno ?
         jz        KorFCil9                 ; nen° dlouhÇ jmÇno
         call      CopyTCil                 ; test c°lovÇho souboru
KorFCil9:popf
         ret

KorFCil  ENDP

; -----------------------------------------------------------------------------
;        vytvo©en° p©echodnÇho vòstupn°ho souboru (CY=nelze vytvo©it)
; -----------------------------------------------------------------------------

CopyFTmp PROC      NEAR

; ------ kopie c°lovÇho adres†©e do bufferu

         mov       si,offset CilPath        ; buffer c°lovÇho adres†©e
         mov       cx,FileMax-10            ; max. dÇlka c°l. adres†©e+soubor
         mov       di,offset CilTempF       ; buffer adres†©e
         push      ds
         pop       es                       ; ES <- datovò segment
         cld
         push      di
         rep       movsb                    ; £schova c°lovÇho adres†©e
         pop       si                       ; SI = buffer adres†©e

; ------ vytvo©en° p©echodnÇho souboru

         call      far ptr CreatPF          ; vytvo©en° p©echodnÇho souboru
         jc        CopyFTm9                 ; soubor nelze vytvo©it
         mov       ds:[CilIdent],ax         ; identifik†tor c°lovÇho souboru
         or        byte ptr ds:[CopyParD],bit3 ; p©°znak p©echodnÇho souboru
CopyFTm9:ret

CopyFTmp ENDP

; -----------------------------------------------------------------------------
;        uzav©en° souborñ p©i kop°rov†n° (VSTUP: CY=byla chyba operace)
; -----------------------------------------------------------------------------
;˛
CopyClos PROC      NEAR

         pushf

; ------ zru®en° vòstupn°ho souboru a nahrazen° p©echodnòm souborem

         jc        CopyCls1                 ; p©i chybà se neru®°
         test      byte ptr ds:[CopyParD],bit3 ; je p©echodnò soubor ?
         jz        CopyCls1                 ; nen° p©echodnò soubor
         call      CopyFDel                 ; zru®en° vòstupn°ho souboru
         popf
         pushf                              ; CY = chyba

; ------ uzav©en° zdrojovÇho souboru

CopyCls1:mov       ax,ds:[FileIdnt]
         call      far ptr ClosFile         ; uzav©en° souboru
         mov       ds:[FileIdnt],ax

; ------ nastaven° data a áasu vòstupn°ho souboru

         mov       ax,ds:[CilIdent]         ; identifik†tor vòstupn°ho souboru
         or        ax,ax                    ; je vòstupn° soubor otev©en ?
         jz        CopyCls2                 ; vòstupn° soubor nen° otev©en

         mov       cx,ds:[FileFTim]         ; áas
         and       cx,ds:[ModiTimM]         ; nulov†n° áasu
         or        cx,ds:[ModiTim]          ; nastaven° poëadovanÇho áasu
         mov       dx,ds:[FileFDat]         ; datum
         and       dx,ds:[ModiDatM]         ; nulov†n° data
         or        dx,ds:[ModiDat]          ; nastaven° poëadovanÇho data
         call      far ptr SetDFile         ; nastaven° data a áasu

; ------ uzav©en° c°lovÇho souboru

         call      far ptr ClosFile         ; uzav©en° souboru
         mov       ds:[CilIdent],ax         ; soubor nen° otev©en

; ------ nastaven° atributñ c°lovÇho souboru

CopyCls2:push      ds
         pop       es                       ; ES <- datovò segment
         mov       si,offset CilPath        ; jmÇno vòstupn°ho souboru
         mov       cl,ds:[FileFAtr]         ; atributy
         and       cl,ds:[ModiAtrM]         ; nulov†n° nastavovanòch atributñ
         or        cl,ds:[ModiAtr]          ; nastaven° poëadovanòch atributñ
         call      far ptr SetAFile         ; nastaven° atributñ

; ------ p©i chybà zru®en° vòstupn°ho souboru (a takÇ p©i z†pisu 0 bajtñ)

CopyCls3:popf
         jc        CopyCl32                 ; chyba
         mov       ax,word ptr ds:[CopyDUlo]
         or        ax,word ptr ds:[CopyDUlo+2] ; byla uloëena nàjak† data ?
         jnz       CopyCls5                 ; byla nàjak† data

         mov       ax,word ptr ds:[CopyDSiz]
         or        ax,word ptr ds:[CopyDSiz+2] ; zbòvaj° nàjak† data ?
         jz        CopyCls5                 ; nezbòvaj° ë†dn† data

CopyCl32:pushf
         test      byte ptr ds:[CopyParD],bit0 ; byl soubor vytvo©en ?
         jz        CopyCls4                 ; nebyl vytvo©en
         call      far ptr ZapKrit          ; zapnut° kritickÇho reëimu
         mov       si,offset CilPath        ; jmÇno vòstupn°ho souboru
         call      far ptr DelFile          ; zru®en° vòstupn°ho souboru
         call      far ptr VypKrit          ; vypnut° kritickÇho reëimu
CopyCls4:popf

; ------ aktualizace vytvo©enÇho souboru

CopyCls5:jc        CopyCls6                 ; byla chyba

         push      ds
         pop       es
         mov       si,offset FileFPol
         mov       di,offset CilFPol
         mov       cx,offset(CilFPol0-CilFPol)
         cld
         rep       movsb
         mov       ax,word ptr ds:[CopyDUlo] ; uloëen† data
         mov       word ptr ds:[CilFSize],ax
         mov       ax,word ptr ds:[CopyDUlo+2]
         mov       word ptr ds:[CilFSize+2],ax

         mov       si,offset CilPath
         mov       cx,ds:[CilCilPN]         ; dÇlka textu adres†©e
         mov       di,offset CilFPol        ; vzor poloëky
         mov       dx,ds                    ; DX <- segment vzoru poloëky
         call      far ptr InsWFile         ; vytvo©en° poloëky v oknà
         call      far ptr DispWAkt         ; podm°nànÇ zobrazen° oken

         clc
CopyCls6:ret

CopyClos ENDP

; -----------------------------------------------------------------------------
;        zkop°rov†n° á†sti dat (do konce souboru nebo do konce diskety) CY=chyba
; -----------------------------------------------------------------------------
;˛
CopyCop  PROC      NEAR

; ------ p©°prava ukazatelñ

         mov       bx,-1                    ; zat°m bez omezen° velikosti bloku
         and       byte ptr ds:[ExistPar],not bit7 ; nen° dal®° disk
         mov       word ptr ds:[CopyDUlo],0 ; á°taá uloëenòch dat
         mov       word ptr ds:[CopyDUlo+2],0

; ------ naáten° bloku dat ze souboru (omezen° BX bajtñ) -> CX bajtñ, adresa ES

CopyCop1:call      CopC0Rea                 ; naáten° bloku dat ze souboru
         jc        CopyCp59                 ; chyba - dal®° soubor
         jcxz      CopyCp59                 ; konec souboru (je NC=operace OK)
         mov       dx,cx                    ; DX <- £schova poátu naátenòch bajtñ

; ------ z†pis DX bajtñ dat (buffer ES) do vòstupn°ho souboru (omezen° BX)

CopyCop2:mov       cx,bx                    ; CX <- velikost bloku dat
CopyCp22:cmp       cx,dx                    ; bylo naáteno dost dat ?
         jbe       CopyCop3                 ; bylo naáteno dost dat
         mov       cx,dx                    ; omezen† velikost dat
CopyCop3:mov       ax,ds:[CilIdent]         ; identifik†tor vòstupn°ho souboru
         xor       si,si                    ; offset poá†tku dat
         call      far ptr TestBreak        ; je p©eru®en° operace ?
         jc        CopyCp59                 ; je p©eru®en° operace
         call      far ptr WritFile         ; z†pis dat do souboru
                                          ;* (pozor, p©i plnÇm disku je takÇ CY)
; ------ zmen®en° omezen° velikosti bloku, je-li konec disku

         cmp       bh,-1                    ; je jië omezen° bloku ?
         jne       CopyCop4                 ; je jië omezen° bloku
         cmp       bl,-2                    ; byl ukl†d†n zbytek do bloku ?
         jne       CopyCop5                 ; nebyl zbytek do konce bloku
         mov       bx,8000h                 ; p©°®t° omezen°
         jmp       short CopyCop5

CopyCop4:shr       bx,1                     ; zmen®en° omezen° bloku
         cmp       bx,64                    ; minim†ln° velikost bloku
         jae       CopyCop5                 ; velikost bloku je OK
         mov       bl,64                    ; minim†ln° velikost bloku

; ------ kontrola, zda bylo nàco uloëeno

CopyCop5:or        cx,cx                    ; bylo nàco uloëeno ?
         jnz       CopyCop7                 ; bylo nàco uloëeno

; ------ zru®en° p©episovanÇho souboru, je-li m†lo m°sta

         test      byte ptr ds:[CopyParD],bit3 ; je p©echodnò soubor ?
         jz        CopyCop6                 ; nen° p©echodnò soubor
         test      byte ptr ds:[ExistPar],bit0 ; existuje soubor ?
         jz        CopyCop6                 ; soubor neexistuje
         test      byte ptr ds:[CopyParD],bit2 ; byl soubor jië zru®en ?
         jnz       CopyCop6                 ; soubor jië byl zru®en
         call      CopyFDel                 ; zru®en° p©episovanÇho souboru
         jnc       CopyCop2                 ; opakov†n° z†pisu
CopyCp59:jmp       short CopyCop9           ; chyba

; ------ kontrola, zda byl jië zkou®en minim†ln° blok

CopyCop6:cmp       bx,64                    ; byl jië minim†ln° blok ?
         jbe       CopyCop8                 ; jië se nic neuloë° - konec disku

; ------ kontrola, zda je jië omezen° velikosti dat

         cmp       bx,-1                    ; je jië omezen° velikosti dat ?
         jne       CopyCop2                 ; je jië omezen° velikosti dat

; ------ vòpoáet zbytku do alokaán°ho bloku -> CX

         call      CopC0Zby                 ; poáet bajtñ do konce bloku -> CX
         dec       bx                       ; -2 = p©°znak uloëen° zbytku
         jmp       short CopyCp22

; ------ posun ukazatelñ o CX uloëenòch bajtñ

CopyCop7:call      CopC0Inc                 ; posun ukazatelñ
         jmp       short CopyCop1           ; dal®° blok dat

; ------ na disk se jië nic nevejde

CopyCop8:mov       word ptr ds:[CopyDFre],0 ; nen° m°sto na disku
         mov       word ptr ds:[CopyDFre+2],0
         mov       word ptr ds:[CopyDFr0],0 ; volnÇ m°sto bez p©epis. souboru
         mov       word ptr ds:[CopyDFr0+2],0
         or        byte ptr ds:[ExistPar],bit7 ; p©°znak dal®°ho disku
                                          ;* zde je NC !
CopyCop9:ret

CopyCop  ENDP

; ------ zbytek poátu bajtñ do konce alok.bloku (DX=bajtñ v bufferu) -> CX <> 0

CopC0Zby:push      dx
         mov       ax,word ptr ds:[CopyDUlo] ; á°taá uloëenòch dat na disk
         mov       dx,word ptr ds:[CopyDUlo+2]
         mov       cx,ds:[CopyDBlk]         ; velikost bloku disku
         cmp       dx,cx                    ; bylo by p©eteáen° ?
         jae       CopC0Zb2                 ; bylo by p©eteáen°
         div       cx                       ; vòpoáet á†sti v bloku
         sub       cx,dx                    ; CX = zbytek do bloku (1...)
CopC0Zb2:pop       dx
         ret

; -----------------------------------------------------------------------------
;        naáten° bloku dat ze souboru (omezen° BX) -> CX=poáet bajtñ, CY=chyba
; -----------------------------------------------------------------------------

CopC0Rea PROC      NEAR

; ------ nastaven° ukazatele ve zdrojovÇm souboru

         mov       ax,ds:[FileIdnt]         ; zdrojovò soubor
         mov       cx,word ptr ds:[CopyDRea] ; ukazatel naátenòch dat
         mov       dx,word ptr ds:[CopyDRea+2]
         call      far ptr SetUFile         ; nastaven° ukazatele v souboru
         jnc       CopC0Re5                 ; operace OK

; ------ chyba áten° ze souboru

CopC0Re2:mov       si,offset FilePath       ; jmÇno souboru
         push      ds
         pop       es                       ; ES <- segment jmÇna souboru
         call      far ptr ReadErr          ; chyba áten° ze souboru
         stc                                ; p©°znak dal®°ho souboru
         jmp       short CopC0Re9           ; dal®° soubor

; ------ naáten° bloku dat ze zdrojovÇho souboru AX (omezen° na BX bajtñ)

CopC0Re5:call      far ptr GetBuff          ; adresa bufferu -> ES
         jc        CopC0Re9                 ; chyba pamàti
         mov       cx,ds:[BuffSize]         ; velikost bufferu

         test      byte ptr ds:[ExistPar],bit6 ; je to znakovÇ za©°zen° ?
         jz        CopC0Re6                 ; nen° to znakovÇ za©°zen°
         or        ch,ch                    ; asi tak omezen° velikosti bloku
         jz        CopC0Re6                 ; je to OK
         mov       ch,1                     ; asi tak omezen° velikosti dat
CopC0Re6:cmp       cx,bx                    ; je pot©eba omezit ?
         jbe       CopC0Re8                 ; nen° pot©eba omezit
         mov       cx,bx                    ; omezen° velikosti bloku
CopC0Re8:xor       di,di                    ; offset zaá†tku bufferu
         call      far ptr ReadFile         ; áten° ze souboru
         jc        CopC0Re2                 ; chyba áten°

CopC0Re9:ret

CopC0Rea ENDP

; -----------------------------------------------------------------------------
;        posun ukazatelñ o CX uloëenòch bajtñ
; -----------------------------------------------------------------------------

CopC0Inc PROC      NEAR

         xor       ax,ax                    ; AX <- 0

; ------ á°taá uloëenòch dat na 1 disk

         add       word ptr ds:[CopyDUlo],cx ; á°taá uloëenòch dat
         adc       word ptr ds:[CopyDUlo+2],ax

; ------ á°taá naátenòch (a uloëenòch) dat ze souboru

         add       word ptr ds:[CopyDRea],cx ; ukazatel naátenòch dat
         adc       word ptr ds:[CopyDRea+2],ax

; ------ á°taá volnÇho m°sta na c°lovÇm disku

         sub       word ptr ds:[CopyDFre],cx ; sn°ëen° volnÇho m°sta disku
         sbb       word ptr ds:[CopyDFre+2],ax
         jnc       CopC0In2
         mov       word ptr ds:[CopyDFre],ax
         mov       word ptr ds:[CopyDFre+2],ax

; ------ á°taá volnÇho m°sta na c°lovÇm disku bez p©episovanÇho souboru

CopC0In2:sub       word ptr ds:[CopyDFr0],cx ; sn°ëen° volnÇho m°sta bez souboru
         sbb       word ptr ds:[CopyDFr0+2],ax
         jnc       CopC0In4
         mov       word ptr ds:[CopyDFr0],ax
         mov       word ptr ds:[CopyDFr0+2],ax

; ------ á°taá zbòvaj°c° velikosti souboru ke zkop°rov†n°

CopC0In4:sub       word ptr ds:[CopyDSiz],cx ; sn°ëen° zbòvaj°c° velikosti souboru
         sbb       word ptr ds:[CopyDSiz+2],ax
         jnc       CopC0In6
         mov       word ptr ds:[CopyDSiz],ax
         mov       word ptr ds:[CopyDSiz+2],ax

; ------ posun indik†toru operace

CopC0In6:call      far ptr InfoKurz         ; posun kurzoru operace
         ret

CopC0Inc ENDP

; -----------------------------------------------------------------------------
;        zru®en° p©episovanÇho souboru -> CY=chyba, bude dal®° soubor
; -----------------------------------------------------------------------------

CopyFDel PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ test, zda je soubor jië zru®en

         test      byte ptr ds:[ExistPar],bit0 ; existuje soubor ?
         jz        CopyFDl2                 ; soubor neexistuje
         test      byte ptr ds:[CopyParD],bit2 ; byl soubor jië zru®en ?
         jnz       CopyFDl2                 ; soubor jië byl zru®en

; ------ zru®en° vòstupn°ho souboru

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       si,offset CilPath        ; c°lovò soubor
         call      far ptr DelFile          ; zru®en° souboru
         jnc       CopyFDl4                 ; soubor zru®en OK

; ------ chyba - vòstupn° soubor nelze zru®it

         call      far ptr CopDErPr         ; chyba - soubor nelze zru®it
         stc                                ; bude dal®° soubor
CopyFDl2:jmp       short CopyFDl9

; ------ aktualizace po zru®en° c°lovÇho souboru

CopyFDl4:or        byte ptr ds:[CopyParD],bit2 ; p©°znak zru®en° souboru
         mov       cx,ds:[CilCilPN]         ; dÇlka c°lovÇho adres†©e
         mov       dx,ds
         mov       di,offset CilFPol        ; fiktivn° poloëka
         call      far ptr DelWFile         ; zru®en° souboru
         call      far ptr DispWAkt         ; podm°nànÇ zobrazen° oken

; ------ test, zda je otev©en p©echodnò soubor

         test      byte ptr ds:[CopyParD],bit3 ; je p©echodnò soubor ?
         jz        CopyFDl8                 ; nen° p©echodnò soubor

; ------ uzav©en° p©echodnÇho souboru

         mov       ax,ds:[CilIdent]         ; identifik†tor p©echodnÇho souboru
         call      far ptr ClosFile         ; uzav©en° souboru
         mov       ds:[CilIdent],ax         ; zru®en° identifik†toru

; ------ p©ejmenov†n° p©echodnÇho souboru na c°lovÇ jmÇno

         mov       si,offset CilTempF       ; jmÇno p©echodnÇho souboru

         test      byte ptr ds:[CopyPrD2],bit5 ; m† c°l dlouhÇ jmÇno ?
         jz        CopyFDl6                 ; c°l nem† dlouhÇ jmÇno

         mov       di,ss:[bp-10]            ; c°lovÇ jmÇno
         mov       dx,ss                    ; DX <- segment c°lovÇho jmÇna
         call      far ptr RenXFile         ; p©ejmenov†n° adres†©e
         call      KorFCil                  ; korekce c°lovÇho jmÇna
         jnc       CopyFDl7                 ; operace OK

CopyFDl6:mov       di,offset CilPath        ; c°lovÇ jmÇno souboru
         mov       dx,ds                    ; DX <- datovò segment
         call      far ptr RenFile          ; p©ejmenov†n° souboru
         jc        CopyFD71                 ; chyba p©ejmenov†n° souboru

; ------ otev©en° vòstupn°ho souboru

CopyFDl7:and       byte ptr ds:[CopyParD],not bit3 ; nen° jië p©echodnò soubor
         mov       si,offset CilPath        ; jmÇno c°lovÇho souboru
         call      far ptr OpenRW           ; otev©en° souboru pro z†pis
         jnc       CopyFD72                 ; soubor otev©en OK

; ------ chyba otev©en° vòstupn°ho souboru

CopyFD71:call      far ptr CreatErr         ; chyba vytvo©en° souboru
         stc                                ; p©°znak p©eru®en°
         jmp       short CopyFDl9

; ------ vystaven° ukazatele na konec souboru

CopyFD72:mov       ds:[CilIdent],ax         ; identifik†tor souboru
         call      far ptr SizeFile         ; vystaven° ukazatele v souboru
CopyFDl8:clc                                ; p©°znak operac° OK

; ------ n†vrat registrñ

CopyFDl9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

CopyFDel ENDP

; -----------------------------------------------------------------------------
;        vytvo©en° c°lovÇho adres†©e (datum DX, áas CX, atributy BL)
; -----------------------------------------------------------------------------

CopCreaD PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ instalace obsluhy áasu

         and       cx,ds:[ModiTimM]         ; nulov†n° áasu
         or        cx,ds:[ModiTim]          ; nastaven° poëadovanÇho áasu
         mov       di,cx                    ; DI <- £schova áasu
         and       dx,ds:[ModiDatM]         ; nulov†n° data
         or        dx,ds:[ModiDat]          ; nastaven° poëadovanÇho data
         test      byte ptr ds:[Win95Par],bit2 ; jsou dlouh† jmÇna ?
         jz        CopCreD1                 ; je dlouhÇ jmÇno
         test      byte ptr ds:[CopyPrD2],bit2 ; uchov†vat datum a áas ?
         jz        CopCreD1                 ; neuchov†vat
         call      far ptr InstA08          ; instalace obsluhy áasu

; ------ vytvo©en° adres†©e s dlouhòm jmÇnem

CopCreD1:mov       cl,bl                    ; atributy
         and       cl,ds:[ModiAtrM]         ; nulov†n° nastavovanòch atributñ
         or        cl,ds:[ModiAtr]          ; nastaven° poëadovanòch atributñ

         test      byte ptr ds:[CopyPrD2],bit5 ; je dlouhÇ jmÇno ?
         jz        CopCreD2                 ; nen° dlouhÇ jmÇno

         push      ss
         pop       es                       ; ES <- segment bufferu
         mov       si,ss:[bp-10]            ; c°lovÇ jmÇno
         call      far ptr CreaXDir         ; vytvo©en° adres†©e
         call      KorFCil                  ; korekce c°lovÇho jmÇna
         jc        CopCreD2                 ; chyba
         mov       ch,0
         call      far ptr SetXAFil         ; nastaven° atributñ adres†©e
         jmp       short CopCreD4

; ------ vytvo©en° dlouhÇho adres†©e

CopCreD2:push      ds
         pop       es                       ; ES <- datovò segment
         mov       si,offset CilPath        ; jmÇno c°lovÇho adres†©e
         call      far ptr CreaLDir         ; vytvo©en° dlouhÇho adres†©e

; ------ nastaven° data a áasu adres†©e, je-li dlouhÇ jmÇno

CopCreD4:test      byte ptr ds:[Win95Par],bit2 ; jsou dlouh† jmÇna ?
         jnz       CopCreD6                 ; nen° dlouhÇ jmÇno
         test      byte ptr ds:[CopyPrD2],bit2 ; uchov†vat datum a áas ?
         jz        CopCreD8                 ; neuchov†vat datum a áas
         mov       cx,di                    ; CX <- áas
         call      far ptr SetDTDir         ; nastaven° data a áasu adres†©e
         jmp       short CopCreD8

; ------ odinstalov†n° obsluhy áasu

CopCreD6:call      far ptr DInsA08          ; odinstalov†n° modifikace áasu

; ------ obnoven° zobrazen° oken

CopCreD8:call      far ptr DispWAkt         ; podm°nànÇ zobrazen° oken

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         ret

CopCreaD ENDP

; -----------------------------------------------------------------------------
;                                  CopPred
;        p©°prava p©edvoleb pro kop°rov†n° a p©esun, zad†n° c°le operace
; -----------------------------------------------------------------------------
; VSTUP: BX=typ operace
;                  2 = kurzor - soubor (ve FileTxtP je jmÇno souboru)
;                  4 = kurzor - adres†© (ve FileTxtP je jmÇno adres†©e)
;                  6 = 1 oznaáen† poloëka (ve FileTxtP je poáet poloëek)
;                  8 = 2 aë 4 oznaáenÇ poloëky (ve FileTxtP je poáet poloëek)
;                 10 = 5 a v°ce oznaáenòch poloëek (ve FileTxtP je poáet poloë.)
;                 12 = v®echny soubory
;                 14 = v®echny soubory a adres†©e
;                 16 = zadanÇ poloëky
;        SI=menu
; VùSTUP: CY=p©eru®en° operace
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) adresa definice menu
;                   SS:[BP-4] (2) typ operace
;                   SS:[BP-22] (18) p©edvolba 1 - jmÇno souboru pod kurzorem
;                              (FileMax) p©edvolba 2 - cesta k protàj®°mu oknu
; Niá° v®echny registry !
; -----------------------------------------------------------------------------

CopPred  PROC      NEAR

; ------ p©°prava lok†ln°ch promànnòch

         push      bp

         mov       bp,sp
         sub       sp,22+FileMax + 10
         mov       ss:[bp-2],si             ; adresa definice menu
         mov       ss:[bp-4],bx             ; typ operace
         mov       byte ptr ss:[bp-22],0    ; p©°znak - nen° kr†tkÇ jmÇno souboru

; ------ p©°prava parametrñ menu

         test      byte ptr ds:[HelpPar],bit2 ; je n†povàda k menu ?
         jnz       CopPred2                 ; n†povàda k menu nen°
         mov       es,ds:[HelpSeg]          ; segment n†povàdy
         mov       ax,ds:[bx+CopyTabH-2]    ; adresa n†povàdy
         mov       es:[SK1MLHlX],ax
         mov       es:[SJ1MLHlX],ax
CopPred2:mov       ax,ds:[bx+CopyTbPA-2]    ; adresa poloëky - A
         mov       ds:[SK1MLPlA],ax
         mov       ds:[SJ1MLPlA],ax
         mov       ax,ds:[bx+CopyTbPB-2]    ; adresa poloëky - B
         mov       ds:[SK1MLPlB],ax
         mov       ds:[SJ1MLPlB],ax

; ------ inicializace ukazatelñ

         lea       bx,[si+LMnuPreN]         ; BX <- definice p©edvoleb
         mov       byte ptr ds:[bx],0       ; nen° ë†dn† p©edvolba

; ------ test, zda bude poloëka pod kurzorem

         cmp       byte ptr ss:[bp-4],12    ; jsou v®echny poloëky nebo zadanÇ ?
         jae       CopPred4                 ; nen° poloëka pod kurzorem

; ------ £schova typu okna

         call      far ptr GetAAWin         ; adresa aktivn°ho okna
         mov       al,es:[AWinPrm1]         ; typ okna

; ------ adresa poloëky pod kurzorem -> ES:SI

         call      far ptr GetAKurz         ; poskytnut° adresy kurzoru
         jc        CopPred4                 ; nen° kurzor
         inc       byte ptr ds:[bx]         ; je 1 p©edvolba

; ------ test, zda bude dlouhÇ jmÇno

         test      al,bit3                  ; je to adres†©ovÇ okno ?
         jz        CopPrd26                 ; nen° to adres†©ovÇ okno
         mov       al,es:[si+FileLong]      ; dÇlka dlouhÇho jmÇna
         or        al,al                    ; je dlouhÇ jmÇno ?
         jz        CopPrd26                 ; nen° dlouhÇ jmÇno

; ------ nastaven° adresy dlouhÇho jmÇna

         mov       ah,0
         mov       ds:[bx+1],ax             ; dÇlka p©edvolby
         add       si,FileLong+1            ; zaá†tek dlouhÇho jmÇna
         mov       ds:[bx+3],si             ; adresa jmÇna
         mov       ds:[bx+5],es             ; segment jmÇna
         jmp       short CopPrd32

; ------ nastaven° ukazatelñ na poloëku

CopPrd26:lea       di,[bp-22]               ; p©edvolba 1 - poloëka
         mov       ds:[bx+3],di             ; p©edvolba 1 - poloëka
         mov       ds:[bx+5],ss

; ------ dek¢dov†n° jmÇna poloëky pod kurzorem

         push      ds
         push      es
         push      ss
         pop       es                       ; ES <- segment bufferu
         pop       ds                       ; DS <- segment poloëky
         inc       si                       ; zaá†tek jmÇna poloëky
         call      far ptr FileAsc          ; dek¢dov†n° jmÇna poloëky
         pop       ds
         sub       di,ds:[bx+3]             ; dÇlka textu p©edvolby 1
         mov       ds:[bx+1],di             ; dÇlka textu p©edvolby 1

; ------ oprava jmÇna poloëky na mal† p°smena

         cmp       byte ptr ss:[bp-4],2     ; je to soubor ?
         jne       CopPrd32                 ; nen° to soubor

         mov       cx,di                    ; CX <- dÇlka p©edvolby 1
         lea       di,[bp-22]               ; p©edvolba 1 - poloëka
CopPred3:mov       al,ss:[di]               ; naáten° znaku
;         call      far ptr DownCase         ; p©evod na malÇ p°smeno

         call      far ptr UpCase           ; konverze na velkÇ p°smeno

         cld
         stosb                              ; uloëen° znaku
         loop      CopPred3                 ; dal®° znak

CopPrd32:add       bx,6                     ; adresa dal®° p©edvolby

; ------ test, zda je protàj®° okno

CopPred4:call      far ptr TestNAWn         ; test, zda je neaktiv. okno zapnuto
         jc        CopPrd49                 ; neaktivn° okno nen° zapnuto

; ------ adresa protàj®°ho okna

         call      far ptr GetNAWin         ; adresa neaktivn°ho okna
CopPrd49:jc        CopPred9                 ; nàjak† chyba

; ------ test, zda je to aktivn° adres†©

         mov       cx,es:[AWinDNum]         ; dÇlka textu adres†©e
         cmp       cx,ds:[AktPathN]         ; je shodn† dÇlka ?
         jne       CopPred5                 ; dÇlka nen° shodn†

         push      cx
         mov       di,AWinDir               ; aktivn° adres†© neaktivn°ho okna
         mov       si,offset AktPath        ; aktivn° cesta
         cld
         repe      cmpsb                    ; porovn†n° textñ adres†©ñ
         pop       cx
         je        CopPred9                 ; je to aktivn° adres†© - nic

; ------ p©°prava ukazatelñ na cestu do protàj®°ho okna

CopPred5:mov       si,ss:[bp-2]             ; definice menu
         add       si,LMnuPreN              ; definice poátu p©edvoleb
         inc       byte ptr ds:[si]         ; je p©edvolba 2
         mov       ds:[bx+1],cx             ; dÇlka textu adres†©e
         mov       di,sp                    ; p©edvolba 2 - cesta
         mov       ds:[bx+3],di             ; p©edvolba 2 - cesta
         mov       ds:[bx+5],ss

; ------ p©°prava cesty k protàj®°mu oknu

         push      si
         push      ds

         push      es
         push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku
         pop       ds                       ; DS <- segment okna
         mov       si,AWinDir               ; zaá†tek textu cesty
         cld
         rep       movsb                    ; p©enos textu p©edvolby

         pop       ds
         pop       si

; ------ test, zda se k cestà p©id† jmÇno poloëky

         cmp       byte ptr ss:[bp-4],2     ; je kurzor - soubor ?
         ja        CopPrd82                 ; nen° kurzor - soubor
         cmp       byte ptr ds:[si],2       ; jsou obà p©edvolby ?
         jne       CopPrd82                 ; nejsou obà p©edvolby
         lea       si,ss:[bp-22]            ; p©edvolba 1 - poloëka
         cmp       byte ptr ss:[si],0       ; je kr†tkÇ jmÇno souboru ?
         je        CopPrd82                 ; nen° kr†tkÇ jmÇno souboru

; ------ kopie textu jmÇna poloëky, je-li kurzor (je zde CLD)

         mov       cx,ds:[bx-6+1]           ; CX <- dÇlka p©edvolby 1
         add       ds:[bx+1],cx             ; zvò®en° dÇlky p©edvolby 2
         mov       al,"\"
         dec       di
         scasb                              ; je znak "\" ?
         je        CopPred8                 ; je jië znak "\"
         stosb                              ; uloëen° znaku "\"
         inc       word ptr ds:[bx+1]       ; zvò®en° dÇlky textu cesty
CopPred8:rep       movs byte ptr es:[di],ss:[si] ; p©id†n° jmÇna poloëky

; ------ p©id†n° parametru "/r" pro CD disk

CopPrd82:push      es
         call      far ptr GetAAWin         ; adresa aktivn°ho okna -> ES
         test      byte ptr es:[AWinPrm0],bit6 ; je to CD-ROM disk ?
         pop       es
         jz        CopPred9                 ; nen° to CD-ROM disk

         cld
         mov       ax,"/ "                  ; mezera a znak parametru "/"
         stosw                              ; oddàlovac° mezera a znak "/"
         mov       ax,"r"                   ; parametr "r" a koncov† 0
         stosw
         add       word ptr ds:[bx+1],3     ; zvò®en° dÇlky textu

; ------ zad†n° a rozbor c°le operace (CY=p©eru®en°)

CopPred9:mov       si,ss:[bp-2]             ; adresa definice menu
         call      far ptr RozbCil          ; zad†n° a rozbor c°le

; ------ n†vrat registrñ

         mov       sp,bp
         pop       bp
         ret

CopPred  ENDP

; -----------------------------------------------------------------------------
;                                 CopyExis
;                     test, zda c°lovò soubor jië existuje
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY=soubor se nekop°ruje
; -----------------------------------------------------------------------------

CopyExis PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ inicializace operace pro v°cediskovò reëim

         and       byte ptr ds:[ExistPar],not bit3 ; nen° p©eskoáen°
         test      byte ptr ds:[ExistPar],bit1+bit5 ; je p©epis nebo p©ipojen° ?
         jnz       CopyEx12                 ; je p©epis nebo p©ipojen° - OK
         or        byte ptr ds:[ExistPar],bit1 ; p©epis souboru (pro dal®° disk)
CopyEx12:test      byte ptr ds:[ExistPar],bit7 ; je dal®° disk ?
         jnz       CopyEx10                 ; je dal®° disk
         and       byte ptr ds:[ExistPar],not bit1+bit5 ; nulov†n°

; ------ test, zda c°lovò soubor jië existuje

CopyEx10:test      byte ptr ds:[ExistPar],bit0 ; soubor existuje ?
         jnz       CopyEx3                  ; soubor jië existuje
CopyEx1: and       byte ptr ds:[ExistPar],not bit1+bit5 ; nulov†n° (pro dal®° disk)
                                          ;* zde je NC=soubor se p©ep°®e
CopyEx2: jmp       CopyEx9

; ------ chyba - existuje jië adres†© stejnÇho jmÇna jako ES:SI

CopyEx3: test      byte ptr ds:[CilDTA+DTAAtrib],DIR ; je to adres†© ?
         jz        CopyEx4                  ; nen° to adres†©
         call      far ptr CopDErr          ; chyba - existuje adres†©
         stc                                ; v ë†dnÇm p©°padà se nekop°ruje
         jmp       short CopyEx2            ; p©eru®en°

; ------ test, zda je p©ednastavena operace pro v®echny soubory

CopyEx4: test      byte ptr ds:[ExistPar],bit7 ; je dal®° disk ?
         jnz       CopyEx2                  ; dal®° disk - soubor se p©episuje
         or        byte ptr ds:[ExistPar],bit3 ; p©°znak p©eskoáen° souboru
         test      byte ptr ds:[ExistPar],bit4 ; je p©eskoáen° v®ech souborñ ?
         stc                                ; p©°znak p©eskoáen° souboru
         jnz       CopyEx2                  ; je p©eskoáen° souboru
         xor       byte ptr ds:[ExistPar],bit1+bit3 ; p©°znak p©episu souboru
         test      byte ptr ds:[ExistPar],bit2 ; je p©epis v®ech souborñ ?
         jnz       CopyEx2                  ; je p©epis souboru
         and       byte ptr ds:[ExistPar],not bit1+bit3+bit5 ; nulov†n° p©°znakñ

; ------ za©°zen° se automaticky p©episuje

         test      byte ptr ds:[ExistPar],bit6 ; je to za©°zen° ?
         jnz       CopyEx41                 ; je to za©°zen°

; ------ automatickò p©epis souborñ

         mov       si,offset FileFPol       ; poloëka kop°rovanÇho souboru
         mov       di,offset CilDTA         ; poloëka c°lovÇho souboru

         test      byte ptr ds:[CopyPrD2],bit0 ; je automatickò p©epis ?
         jz        CopyEx42                 ; nen° automatickò p©epis

         mov       ax,ds:[si+FileDate]      ; datum
         cmp       ax,ds:[di+DTADate]       ; porovn†n° data
         jne       CopyEx40                 ; datum nen° shodnÇ
         mov       ax,ds:[si+FileTime]      ; áas
         cmp       ax,ds:[di+DTATime]       ; porovn†n° áasu
CopyEx40:ja        CopyEx41                 ; novò soubor je novàj®° - p©epis
         jmp       CopyEx84                 ; je p©eskoáen° souboru
CopyEx41:jmp       CopyEx82                 ; je p©epis souboru

; ------ p©°prava textu porovn†n° parametrñ souborñ

CopyEx42:mov       bx,offset CopLD2P2       ; á†st textu 1 "Kop°rovanò soubor.."
         mov       cx,offset CopLD2P3       ; á†st textu 2 "novàj®°"
         mov       dx,offset CopLD2P7       ; á†st textu 3 "neë p©episovanò"

         mov       ax,ds:[si+FileDate]      ; datum
         cmp       ax,ds:[di+DTADate]       ; porovn†n° data
         jne       CopyEx43                 ; datum nen° shodnÇ
         mov       ax,ds:[si+FileTime]      ; áas
         cmp       ax,ds:[di+DTATime]       ; porovn†n° áasu
CopyEx43:ja        CopyEx5                  ; novò soubor je novàj®°
         mov       cx,offset CopLD2P4       ; á†st textu 2 "star®°"
         jb        CopyEx5                  ; novò soubor je star®°

         mov       cx,offset CopLD2P5       ; á†st textu 2 "vàt®°"
         mov       ax,word ptr ds:[si+FileSize+2] ; velikost HIGH
         cmp       ax,ds:[di+DTASize+2]     ; porovn†n° velikosti HIGH
         jne       CopyEx44                 ; velikost nen° shodn†
         mov       ax,word ptr ds:[si+FileSize] ; velikost LOW
         cmp       ax,ds:[di+DTASize]       ; porovn†n° velikosti LOW
CopyEx44:ja        CopyEx5                  ; novò soubor je vàt®°
         mov       cx,offset CopLD2P6       ; á†st textu 2 "men®°"
         jb        CopyEx5                  ; novò soubor je men®°

         mov       bx,offset CopLD2P1       ; á†st textu 1 "parametry shodnÇ"
         mov       cx,offset CopLD2P0
         mov       dx,offset CopLD2P0

CopyEx5: mov       word ptr ds:[CopLD2PA+1],bx ; á†st textu 1
         mov       word ptr ds:[CopLD2PA+4],cx ; á†st textu 2
         mov       word ptr ds:[CopLD2PA+7],dx ; á†st textu 3

; ------ dek¢dov†n° velikosti

         mov       di,offset CopLD2PV + 13  ; buffer k dek¢dov†n° velikosti
         mov       cx,28
         mov       al," "
         rep       stosb                    ; vymaz†n° bufferu textu

         mov       ax,word ptr ds:[CilDTA+DTASize] ; velikost c°lovÇho souboru
         mov       dx,word ptr ds:[CilDTA+DTASize+2]
         mov       bl,ds:[OddelRad]         ; oddàlovac° znak ©†dñ
         mov       bh,0                     ; barva textu - nen°
         call      far ptr DekNumD          ; dek¢dov†n° velikosti

         mov       di,offset CopLD2PV + 13 + 13 ; konec velikosti zdrojovÇho souboru
         mov       ax,word ptr ds:[si+FileSize]      ; velikost souboru LOW
         mov       dx,word ptr ds:[si+FileSize+2]    ; velikost souboru HIGH
         call      far ptr DekNumD          ; dek¢dov†n° velikosti

; ------ dek¢dov†n° data (DS:SI=zdrojovò soubor)

         mov       di,offset CopLD2PD + 16
         mov       ah,0                     ; barva nen°
         mov       dx,ds                    ; DX <- datovò segment
         call      far ptr DekA4Dat         ; dek¢dov†n° data zdrojovÇho souboru
         push      si
         mov       si,offset CilDTA + DTADate - FileDate ; fiktivn° c°lov† poloëka
         mov       di,offset CopLD2PD + 31
         call      far ptr DekA4Dat         ; dek¢dov†n° data c°lovÇho souboru
         pop       si

; ------ dek¢dov†n° áasu (DS:SI=zdrojovò soubor)

         mov       di,offset CopLD2PT + 18
         call      far ptr DekATmS          ; dek¢dov†n° áasu zdrojovÇho souboru
         mov       si,offset CilDTA + DTATime - FileTime ; fiktivn° c°lov† poloëka
         mov       di,offset CopLD2PT + 33
         call      far ptr DekATmS          ; dek¢dov†n° áasu c°lovÇho souboru

; ------ chybovÇ hl†®en° - soubor jië existuje

         call      far ptr InfoClos         ; uzav©en° funkce
         mov       si,offset CopyLD2
         call      far ptr Lin0Menu         ; zobrazen° menu
         call      far ptr InfoDisp         ; novÇ zobrazen° hl†®en°

; ------ obsluha zvolenÇ operace

         call      far ptr JumpBX           ; skok na obsluhu volby

         dw        1,CopyEx82               ; p©epsat
         dw        2,CopyEx81               ; v®echny
         dw        3,CopyEx84               ; dal®°
         dw        4,CopyEx83               ; nep©episovat
         dw        5,CopyEx85               ; slouáit

         dw        0,CopyEx6                ; konec nebo ESC

; ------ p©eru®en° operace

CopyEx6: call      far ptr SetEsc           ; p©°znak p©eru®en°
         jmp       short CopyEx9            ; p©eru®en° operace

; ------ p©epsat v®echny

CopyEx81:or        byte ptr ds:[ExistPar],bit2 ; p©epsat v®echny

; ------ p©epis

CopyEx82:or        byte ptr ds:[ExistPar],bit1 ; p©epis souboru
         jmp       short CopyEx9            ; zde je NC !

; ------ nep©episovat ë†dnò

CopyEx83:or        byte ptr ds:[ExistPar],bit4 ; p©eskoáit v®echny

; ------ dal®°

CopyEx84:or        byte ptr ds:[ExistPar],bit3 ; p©eskoáen° souboru
         stc                                ; p©°znak p©eskoáen°
         jmp       short CopyEx9

; ------ p©idat

CopyEx85:or        byte ptr ds:[ExistPar],bit5 ; p©ipojen° souboru
                                          ;* zde je nastaveno NC !
; ------ n†vrat registrñ

CopyEx9: pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

CopyExis ENDP

; -----------------------------------------------------------------------------
;                                 CopyRO
;                  test, zda se poloëka R/O p©episuje
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY=poloëka se nep©episuje
; -----------------------------------------------------------------------------

CopyRO   PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      dx
         push      si

; ------ test, zda se ru®°/p©eskakuj° v®echny poloëky

         test      byte ptr ds:[CopyRusP],bit0 ; p©episuj° se v®echny R/O ?
         jnz       CopyRO9                  ; p©episuj° se v®echny R/O
         test      byte ptr ds:[CopyRusP],bit1 ; p©eskakuj° se v®echny R/O ?
         jnz       CopyRO8                  ; p©eskakuj° se v®echny poloëky

; ------ dotaz na zru®en° poloëky

         call      far ptr InfoClos         ; uzav©en° informaán°ho ©†dku
         mov       si,offset CopL4Lin
         call      far ptr Lin0Menu         ; zad†n° volby
         call      far ptr InfoDisp         ; novÇ zobrazen° hl†®en°

         call      far ptr JumpBX

         dw        1,CopyRO6                ; p©epsat
         dw        2,CopyRO5                ; v®echny
         dw        3,CopyRO8                ; dal®°
         dw        4,CopyRO7                ; nep©episovat

         dw        0,CopyRO2                ; p©eru®it, ESC

; ------ p©eru®en° operace

CopyRO2: call      far ptr SetEsc           ; nastaven° p©°znaku p©eru®en° ESC
         jmp       short CopyRO9

; ------ p©epsat

CopyRO5: or        byte ptr ds:[CopyRusP],bit0 ; p©°znak zru®en° v®ech poloëek
CopyRO6: clc                                ; p©°znak p©episu poloëky
         jmp       short CopyRO9

; ------ p©eskoáit

CopyRO7: or        byte ptr ds:[CopyRusP],bit1 ; p©°znak p©eskoáen° v®ech
CopyRO8: stc                                ; p©°znak p©eskoáen° poloëky

; ------ n†vrat registrñ

CopyRO9: pop       si
         pop       dx
         pop       bx
         ret

CopyRO   ENDP

; -----------------------------------------------------------------------------
;                                CopyFre
;           test volnÇho m°sta na disku (p©ed zah†jen°m kop°rov†n°)
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY=soubor se p©eskoá°
; -----------------------------------------------------------------------------

CopyFre  PROC      NEAR

; ------ aktualizace volnÇ kapacity c°lovÇho disku

         call      CopyGDsk                 ; aktualizace volnÇho m°sta disku

; ------ £schova registrñ

CopyFre0:push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ p©°prava volnÇho m°sta disku -> DX:AX

         call      CopyPFre                 ; p©°prava volnÇho m°sta disku
         jc        CopyFre2                 ; nedostatek m°sta
         jmp       CopyFre9                 ; je dost volnÇho m°sta pro soubor

; ------ test p©°tomnosti p©episovanÇho souboru

CopyFr12:call      CopyTCil                 ; test c°lovÇho souboru

; ------ aktualizace obsahñ oken

         call      CopyWAkt                 ; aktualizace oken

; ------ p©°prava textñ hl†®en°

CopyFre2:mov       ds:[CopL3P11],offset CopL3P16 ; text "nen°"
         mov       ds:[CopL3P12],offset CopL3P18 ; text "Vymà§te disk..."

         call      CopyPFre                 ; p©°prava volnÇho m°sta disku
         jc        CopyFre4                 ; nen° dost volnÇho m°sta pro soubor

         mov       ds:[CopL3P11],offset CopL3P17 ; text "je"
         mov       ds:[CopL3P12],offset CopL3P19 ; text "Mñëete pokraáovat..."

; ------ dek¢dov†n° poëadovanÇho volnÇho m°sta

CopyFre4:mov       di,offset CopL3Pl4 + 27  ; buffer k dek¢dov†n°
         mov       ax,word ptr ds:[CopyDSiz] ; poëadovanÇ volnÇ m°sto
         mov       dx,word ptr ds:[CopyDSiz+2]
         call      CopyF0Nm                 ; dek¢dov†n° á°sla

; ------ dek¢dov†n° volnÇ kapacity disku

         mov       di,offset CopL3Pl3 + 27  ; buffer k dek¢dov†n°
         mov       ax,word ptr ds:[CopyDFr0]
         mov       dx,word ptr ds:[CopyDFr0+2]
         call      CopyF0Nm                 ; dek¢dov†n° á°sla

; ------ dek¢dov†n° celkovÇ kapacity disku

         mov       di,offset CopL3Pl2 + 27  ; buffer k dek¢dov†n°
         mov       ax,word ptr ds:[CopyDMax]
         mov       dx,word ptr ds:[CopyDMax+2]
         call      CopyF0Nm                 ; dek¢dov†n° á°sla

; ------ dotaz na dal®° postup

         mov       si,offset CopL3Lin
         call      far ptr Lin0MenF         ; zad†n° volby (vypr†zdnàn° kl†vesnice)
         call      far ptr InfoDisp         ; novÇ zobrazen° hl†®en°

         call      far ptr JumpBX
         dw        1,CopyFre8               ; pokraáov†n°
         dw        2,CopyFre6               ; dal®° soubor
         dw        3,CopyFr12               ; vòmàna disku

         dw        0,CopyFre5               ; p©eru®en° operace

; ------ p©eru®en° operace ESC

CopyFre5:call      far ptr SetEsc           ; nastaven° p©°znaku p©eru®en° ESC
CopyFre6:stc                                ; p©°znak dal®°ho souboru
         jmp       short CopyFre9

; ------ n†vrat registrñ

CopyFre8:call      CopyWAkt                 ; aktualizace oken po vòmànà diskety
         clc                                ; NC=p©°znak pokraáov†n°
CopyFre9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

CopyFre   ENDP

; ------ dek¢dov†n° á°sla DX:AX do bufferu DI

CopyF0Nm:push      ds
         pop       es                       ; ES <- datovò segment

         cld
         mov       cx,13
         push      di
         push      ax
         mov       al," "
         rep       stosb                    ; vymaz†n° bufferu á°sla
         pop       ax
         pop       di

         mov       bl,ds:[OddelRad]         ; oddàlovaá ©†dñ
         mov       bh,0                     ; barva se neukl†d†
         call      far ptr DekNum           ; dek¢dov†n° á°sla
         ret

; -----------------------------------------------------------------------------
;     test, zda je c°lovò soubor (a aktualizace informac° o souboru) -> CY=nen°
; -----------------------------------------------------------------------------

CopyTCil PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      di
         push      es

; ------ nastaven° adresy bufferu DTA

         push      ds
         pop       es                       ; ES <- segment bufferu DTA
         mov       si,offset CilDTA         ; SI <- buffer DTA
         call      far ptr SetDTA           ; nastaven° adresy DTA

; ------ zobrazen° hl†®en° o naá°t†n° informac° o disku (nen°-li nic zobrazeno)

         call      CopyIHls                 ; zobrazen° hl†®en°

; ------ test, zda c°lovò soubor jië existuje

         mov       si,offset CilPath        ; c°lovÇ jmÇno souboru
         test      byte ptr ds:[CopyPrD2],bit5 ; je dlouhÇ jmÇno ?
         jz        CopyTCl2                 ; nen° dlouhÇ jmÇno
         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         mov       si,ss:[bp-10]            ; c°lovÇ jmÇno
CopyTCl2:mov       cx,SYS+HID+DIR+RO
         call      far ptr SrcFirst         ; nalezen° souboru nebo adres†©e
         call      far ptr SrcClose         ; uzav©en° starÇho hled†n°
         jc        CopyTCl9                 ; nàjak† chyba (nap©. nen° adres†©)
         stc                                ; p©°znak, ëe soubor nen°
         jne       CopyTCl9                 ; soubor neexistuje

; ------ test, zda je souborem znakovÇ za©°zen° (a nastaven° do bin†rn°ho m¢du)

         call      far ptr OpenW            ; otev©en° pro z†pis
         jc        CopyTCl3                 ; asi to je soubor R/O
         call      far ptr TestDev          ; test, zda to je za©°zen°
         jc        CopyTC22                 ; je to soubor
         or        byte ptr ds:[ExistPar],bit6 ; p©°znak znakovÇho za©°zen°
CopyTC22:call      far ptr ClosFile         ; uzav©en° souboru/za©°zen°

; ------ £schova atributu

CopyTCl3:mov       al,ds:[CilDTA+DTAAtrib]
         mov       ds:[CilFAtr],al          ; £schova atributñ

; ------ £schova velikosti

         mov       ax,word ptr ds:[CilDTA+DTASize]
         mov       word ptr ds:[CilFSize],ax
         mov       ax,word ptr ds:[CilDTA+DTASize+2]
         mov       word ptr ds:[CilFSize+2],ax

; ------ £schova data

         mov       ax,word ptr ds:[CilDTA+DTADate]
         mov       ds:[CilFDate],ax

; ------ £schova áasu

         mov       ax,word ptr ds:[CilDTA+DTATime]
         mov       ds:[CilFTime],ax

; ------ p©°prava konce cesty v c°lovÇm bufferu

         mov       di,offset CilPath        ; c°lovò buffer
         add       di,ds:[CilCilPN]         ; konec cesty
         cmp       byte ptr ds:[di-1],"\"
         je        CopyTCl4
         inc       di

; ------ p©enesen° jmÇna souboru

CopyTCl4:cld
         push      ds
         pop       es                       ; ES <- datovò segment
         mov       si,offset CilDTA+DTAName ; jmÇno souboru
         xor       cx,cx                    ; CX <- á°taá dÇlky jmÇna
         push      si
         dec       cx                       ; p©ednastaven°
CopyTCl6:inc       cx                       ; zvò®en° á°taáe dÇlky jmÇna
         lodsb                              ; naáten° znaku
         stosb                              ; uloëen° znaku
         or        al,al                    ; je konec jmÇna ?
         jnz       CopyTCl6                 ; p©enesen° jmÇna
         pop       si

; ------ nov† dÇlka cesty

         sub       di,offset CilPath+1      ; dÇlka jmÇna souboru
         mov       ds:[CilPathN],di         ; nov† dÇlka jmÇna souboru

; ------ kopie jmÇna souboru i do FileTxtP

         mov       di,offset FileTxtP+1
         mov       ds:[di-1],cl             ; dÇlka jmÇna
         rep       movsb                    ; £schova jmÇna poloëky

; ------ n†vrat registrñ

         clc                                ; p©°znak, ëe soubor existuje OK
CopyTCl9:pop       es
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

CopyTCil ENDP

; -----------------------------------------------------------------------------
;        £schova parametrñ c°lovÇho souboru
; -----------------------------------------------------------------------------

CilFAkt  PROC      NEAR

; ------ £schova registrñ

         push      ax

; ------ n†vrat registrñ

         pop       ax
         ret

CilFAkt  ENDP

; -----------------------------------------------------------------------------
;        p©°prava volnÇho m°sta c°lovÇho disku -> DX:AX, CY=nestaá° m°sto
; -----------------------------------------------------------------------------

CopyPFre PROC      NEAR

         push      cx

; ------ p©°prava volnÇho m°sta disku

         mov       ax,word ptr ds:[CopyDFre] ; voln† kapacita disku
         mov       dx,word ptr ds:[CopyDFre+2]
         mov       word ptr ds:[CopyDFr0],ax ; voln† kapacita po p©episu
         mov       word ptr ds:[CopyDFr0+2],dx

; ------ test, zda se uvoln° p©episovanò soubor

         test      byte ptr ds:[ExistPar],bit0 ; existuje c°lovò soubor ?
         jz        CopyPFr4                 ; c°lovò soubor neexistuje
         test      byte ptr ds:[ExistPar],bit1 ; je p©epis souboru ?
         jz        CopyPFr4                 ; nen° p©epis souboru
         test      byte ptr ds:[CopyParD],bit2 ; byl soubor zru®en ?
         jnz       CopyPFr4                 ; soubor jië byl zru®en

; ------ zaokrouhlen† velikost souboru

         mov       ax,word ptr ds:[CilDTA+DTASize] ; velikost c°lovÇho souboru
         mov       dx,word ptr ds:[CilDTA+DTASize+2]
         mov       cx,ds:[CopyDBlk]         ; velikost alokaán°ho bloku
         dec       cx
         add       ax,cx                    ; zaokrouhlen° na alokaán° blok
         adc       dx,0
         inc       cx
         cmp       dx,cx                    ; bylo by p©eteáen° ?
         jae       CopyPFr3                 ; bylo by p©eteáen°
         div       cx                       ; p©epoáet na bloky
         mul       cx                       ; p©epoáet zp†tky na bajty

; ------ novÇ volnÇ m°sto disku -> DX:AX

CopyPFr3:add       ax,word ptr ds:[CopyDFr0] ; p©iáten° volnÇho m°sta disku
         adc       dx,word ptr ds:[CopyDFr0+2]
         mov       word ptr ds:[CopyDFr0],ax
         mov       word ptr ds:[CopyDFr0+2],dx

; ------ test, zda se soubor vejde na disk (CY=nevejde se)

CopyPFr4:test      byte ptr ds:[CopyParD],bit1 ; jsou diskovÇ informace platnÇ ?
         jnz       CopyPFr6                 ; diskovÇ informace jsou neplatnÇ
         cmp       dx,word ptr ds:[CopyDSiz+2] ; vejde se soubor na disk ?
         jne       CopyPFr6
         cmp       ax,word ptr ds:[CopyDSiz]

CopyPFr6:pop       cx
         ret

CopyPFre ENDP

; -----------------------------------------------------------------------------
;        aktualizace oken po vòmànà c°lovÇho disku
; -----------------------------------------------------------------------------

CopyWAkt PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      dx
         push      si
         push      es

; ------ naáten° novòch informac° o c°lovÇm disku

         call      CopyGDsk                 ; naáten° informac° o c°lovÇm disku
         call      far ptr TestBreak        ; bylo p©eru®en° operace ?
         jc        CopyAkt9                 ; je p©eru®en° operace

; ------ adresa neaktivn°ho okna

         call      far ptr GetNAWin         ; adresa neaktivn°ho okna
         jc        CopyAkt9
         test      byte ptr es:[AWinPrm1],bit3 ; je to adres†©ovÇ okno ?
         jz        CopyAkt9                 ; nen° to adres†©ovÇ okno

; ------ test, zda to je c°lovò disk

         mov       al,ds:[CilPath]          ; c°lovò disk
         cmp       al,es:[AWinDir]          ; souhlas° disk ?
         jne       CopyAkt9                 ; nen° to c°lovò disk

; ------ znovunaáten° neaktivn°ho okna

         and       byte ptr es:[AWinPrm0],not bit0 ; uchovat kurzor i oznaáen°
         mov       ax,ds:[SegmNAkt]         ; neaktivn° okno
         call      far ptr ReReadD          ; znovunaáten° okna
         call      far ptr DispNAWn         ; zobrazen° neaktivn°ho okna

; ------ obnoven° hl†®en° o kop°rov†n°

CopyAkt9:call      CopyHlas                 ; hl†®en° o operaci

; ------ n†vrat registrñ

         pop       es
         pop       si
         pop       dx
         pop       ax
         ret

CopyWAkt ENDP

; -----------------------------------------------------------------------------
;        inicializace parametrñ disku
; -----------------------------------------------------------------------------

CopyGDsk PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

; ------ zobrazen° hl†®en° o naá°t†n°

         call      CopyIHls                 ; zobrazen° hl†®en°

; ------ p©°prava jmÇna disku pro hl†®en°

         mov       al,ds:[CilPath]          ; c°lovò disk
         mov       ds:[CopL3Pl1],al         ; uloëen° oznaáen° disku
         sub       al,"A"                   ; korekce na á°slo disku

; ------ zji®tàn° informac° o c°lovÇm disku AL

         and       byte ptr ds:[CopyParD],not bit1 ; diskovÇ informace platnÇ OK
         call      far ptr GetDInfo         ; diskovÇ informace
         jnc       CopyGDs2                 ; informace jsou OK
         or        byte ptr ds:[CopyParD],bit1 ; neplatnÇ diskovÇ informace

; ------ vòpoáet velikosti alokaán°ho bloku

CopyGDs2:xchg      cx,dx                    ; CX<-blokñ celkem, DX<-bajtñ/sektor
         mul       dx                       ; vòpoáet poátu bajtñ na blok
         mov       ds:[CopyDBlk],ax         ; £schova poátu bajtñ na blok
         or        dx,dx                    ; je v°ce neë 64 KB ?
         jz        CopyGDs3                 ; je to OK
         mov       word ptr ds:[CopyDBlk],-1 ; omezen° velikosti bloku

; ------ vòpoáet celkovÇ kapacity disku

CopyGDs3:xchg      ax,cx                    ; AX<-blokñ celkem, CX<-blok LOW
         mov       si,dx                    ; SI <- velikost bloku HIGH
         push      ax                       ; blokñ celkem
         mul       si                       ; kapacita HIGH
         mov       word ptr ds:[CopyDMax+2],ax ; kapacita HIGH
         pop       ax                       ; blokñ celkem
         mul       cx                       ; kapacita LOW
         mov       word ptr ds:[CopyDMax],ax ; celkov† kapacita - LOW
         add       word ptr ds:[CopyDMax+2],dx ; celkov† kapacita - HIGH

; ------ vòpoáet volnÇ kapacity disku

         xchg      ax,si                    ; velikost bloku HIGH
         mul       bx                       ; volnÇ m°sto HIGH
         mov       word ptr ds:[CopyDFre+2],ax ; voln† kapacita HIGH
         xchg      ax,bx                    ; poáet volnòch alok. blokñ
         mul       cx                       ; vòpoáet volnÇ kapacity
         mov       word ptr ds:[CopyDFre],ax ; voln† kapacita - LOW
         add       word ptr ds:[CopyDFre+2],dx ; voln† kapacita - HIGH

; ------ n†vrat registrñ

         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

CopyGDsk ENDP

; -----------------------------------------------------------------------------
;        hl†®en° o kop°rov†n° a p©esunu
; -----------------------------------------------------------------------------

CopyHlas PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      si
         push      es

; ------ vymaz†n° informaán°ho ©†dku

         push      ds
         pop       es                       ; ES <- datovò segment
         call      far ptr InfoClr          ; vymaz†n° informaán°ho ©†dku

; ------ £vodn° á†st hl†®en°

         mov       si,offset CopyTxt1       ; text hl†®en° - á†st 1
         test      byte ptr ds:[CopyParD],bit5 ; je kop°rov†n° ?
         jnz       CopyHls1                 ; je kop°rov†n°
         mov       si,offset MoveTxt1       ; jinak p©ejmenov†n°
CopyHls1:call      far ptr InfoTxt          ; dek¢dov†n° £vodn° á†sti textu

; ------ jmÇno souboru

         mov       si,offset FilePath       ; plnÇ jmÇno souboru
         add       si,ds:[FilePthN]         ; zaá†tek jmÇna souboru
         mov       cx,ds:[FileFilN]         ; dÇlka se jmÇnem souboru
         sub       cx,ds:[FilePthN]         ; dÇlka jmÇna souboru
         cmp       byte ptr ds:[si],"\"     ; je oddàlovaá adres†©e ?
         jne       CopyHls2                 ; nen° oddàlovaá adres†©e
         inc       si                       ; p©eskoáen° oddàlovaáe adres†©e
         dec       cx                       ; sn°ëen° dÇlky textu
CopyHls2:call      far ptr InfoDek          ; dek¢dov†n° jmÇna souboru

; ------ druh† á†st textu

         mov       si,offset CopyTxt2       ; text hl†®en° - á†st 2 "do"
         call      far ptr InfoTxt          ; dek¢dov†n° druhÇ á†sti textu

; ------ c°lovò soubor

         mov       si,offset CilPath        ; text c°lovÇho jmÇna
         mov       cx,ds:[CilPathN]         ; dÇlka jmÇna souboru
         call      far ptr InfoDek          ; dek¢dov†n° jmÇna souboru

; ------ zobrazen° ©†dku

         test      byte ptr ds:[CopyParD],bit7 ; je p©esun na disku ?
         jz        CopyHls4                 ; nen° p©esun na disku
         call      far ptr InfoDisp         ; zobrazen° informaán°ho ©†dku
         jmp       short CopyHls5

CopyHls4:xor       cx,cx                    ; CX <- 0 p©°rustek nen°
         call      far ptr InfoKurz         ; zobrazen° ©†dku s kurzorem

; ------ n†vrat registrñ

CopyHls5:pop       es
         pop       si
         pop       cx
         ret

CopyHlas ENDP

; -----------------------------------------------------------------------------
;        podm°nànÇ hl†®en° o naá°t†n° informac° o disku
; -----------------------------------------------------------------------------

CopyIHls PROC      NEAR

         call      far ptr InfoAkt          ; test zobrazen° inf. ©†dku
         jnc       CopyIHl2                 ; informaán° ©†dek je jië zobrazen
         push      ax
         push      si
         mov       al,ds:[CilPath]          ; c°lovò disk
         mov       ds:[CopL3Ds2],al         ; oznaáen° disku
         mov       si,offset CopL3Dsk       ; text "Naá°t†m informace..."
         call      far ptr InfDisp0         ; hl†®en° o naá°t†n° informac°
         pop       si
         pop       ax
CopyIHl2:ret

CopyIHls ENDP

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
;        kop°rov†n° souborñ
; -----------------------------------------------------------------------------

SKMnVert label     byte                   ;* menu verifikace souborñ

         db        2                        ; typ menu - vertik†ln° podmenu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka volby
         dw        5                        ; poáet platnòch poloëek menu
         dw        6                        ; celkovò poáet poloëek menu

         dw        SKMnVPol                 ; definián° tabulka poloëek
         dw        SKMnVHlp                 ; n†povàda
         dw        Hlp@MenuKopirovaniSouboru ; á°slo str†nky velkÇ n†povàdy
         dw        SKMnVBlk                 ; blokovac° tabulka
         dw        0                        ; p©ep°naáe
         dw        SKMnVTit                 ; adresa titulu okna
         dw        SKMnVExe                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        36                       ; poá†teán° pozice
         db        10                       ; poá†teán° ©†dek
         db        20                       ; ®°©ka okna
         db        7                        ; vò®ka okna

SKMnVPol db        1,6,'Kurzor'
         db        1,8,'OznaáenÇ'
         db        1,7,'Soubory'
         db        1,7,'V®echny'
         db        1,6,'ZadanÇ'

SKMnVBlk db        0,0,0,0,0

SKMnVTit db        10,'kop°rov†n°'

HelpS    SEGMENT   BYTE PUBLIC
SKMnVHlp db        48,1
         dw        SKMnVHl1
         db        'souboru nebo adres†©e pod kurzorem (Alt-F5)'

         db        39,1
         dw        SKMnVHl1
         db        'oznaáenòch souborñ a adres†©ñ (F5)'

         db        32,1
         dw        SKMnVHl1
         db        'v®ech souborñ v aktivn°m oknà'

         db        43,1
         dw        SKMnVHl1
         db        'v®ech souborñ a adres†©ñ v aktivn°m oknà'

         db        59,1
         dw        SKMnVHl1
         db        'souborñ a adres†©ñ podle blië®° specifikace (Shift-F5)'
HelpS    ENDS

SKMnVHl1 db        11,'Kop°rov†n° '

SKMnVExe label     dword                    ; obsluhy voleb
         dd        CopyFil                  ; kurzor
         dd        CopyFil                  ; oznaáenÇ
         dd        CopyFil                  ; soubory
         dd        CopyFil                  ; v®echny
         dd        CopyFil                  ; zadanÇ

; -----------------------------------------------------------------------------
;       Volba souborñ ke kop°rov†n°
; -----------------------------------------------------------------------------

SKZMLin  label     byte

         db        3                        ; typ menu - ©†dkovÇ podmenu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        SKZMLPol                 ; zaá†tek definice poloëek menu
         dw        SKZMLHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@VyberSouboru         ; á°slo str†nky velkÇ n†povàdy
         dw        SKZMLBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        SKZMLTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        46                       ; ®°©ka okna
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

SKZMLPol db        bit6,30,'Zadejte soubory ke kop°rov†n°:'
         db        0,0
         db        bit6+bit7,0
         db        1,8,'Pokraáuj'
         db        1,6,'N†vrat'

SKZMLBlk db        0,0,0                    ; blokovac° tabulka

SKZMLTit db        6,'zadanÇ'

; ------ n†povàda

HelpS    SEGMENT   BYTE PUBLIC
SKZMLHlp db        3,1
         dw        MenuFndH

         db        30,1
         dw        SKMnVHl1
         db        'zadanòch souborñ a adres†©ñ'

         db        3,1
         dw        MenuHlP1
HelpS    ENDS

; -----------------------------------------------------------------------------
;       Volba c°le kop°rov†n°
; -----------------------------------------------------------------------------

SK1MLin  label     byte

         db        3                        ; typ menu - ©†dkovÇ podmenu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        6                        ; poáet platnòch poloëek menu
         dw        8                        ; celkovò poáet poloëek menu

         dw        SK1MLPol                 ; zaá†tek definice poloëek menu
         dw        SK1MLHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@KopirovaniSouboru    ; á°slo str†nky velkÇ n†povàdy
         dw        SK1MLBlk                 ; adresa blokovac° tabulky
         dw        SK1MLSwc                 ; adresa tabulky p©ep°naáñ
         dw        SK1MLTit                 ; adresa titulu okna
         dw        SK1MLExe                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        70                       ; ®°©ka okna
         db        8                        ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        1                        ; celkovò poáet ©†dkñ
         dw        1                        ; poáet zobrazenòch ©†dkñ

         db        bit2                     ; v®echny znaky (kvñli dlouhòm jmÇnñm)
         db        0,'      '               ; zak†zanÇ znaky

         db        HistFile                 ; identifik†tor historie

SK1MLnPN db        0                        ; poáet p©edvoleb

         dw        0                        ; dÇlka p©edvolby
         dd        0                        ; p©edvolba 1
         dw        0
         dd        0                        ; p©edvolba 2
;˛
; ------ poloëky voleb

SK1MLPol db        bit6,27,'Zkop°ruji '
         db        1
SK1MLPlA dw        SK1MLPA1
         db        4,0,1
         dw        FileTxtP                 ; parametr
         db        0,4,1
SK1MLPlB dw        SK1MLPB1
         db        ' do:'

         db        0,0
         db        bit6+bit7,0
         db        1,6,'ProveÉ'
         db        bit7+1,14,'Aktualizovat '
SK1MLPl0 db        '-'
         db        bit7+1,8,'Kr†tk† '
SK1MLPl1 db        '-'
         db        bit7+1,7,'Datum '
SK1MLPl2 db        '-'
         db        1,6,'N†vrat'

SK1MLPA1 db        7,'soubor '              ; 1 soubor
SK1MLPA2 db        8,'adres†© '
SK1MLPB1 db        0
SK1MLPB2 db        24,' oznaáenò soubor/adres†©'
SK1MLPB3 db        26,' oznaáenÇ soubory/adres†©e'
SK1MLPB4 db        28,' oznaáenòch souborñ/adres†©ñ'
SK1MLPB5 db        22,'v®echny soubory v oknà'
SK1MLPB6 db        33,'v®echny soubory a adres†©e v oknà'
SK1MLPB7 db        25,'zadanÇ soubory a adres†©e'

SK1MLBlk db        0,0,0,0,0,0              ; blokovac° tabulka
SK1MLSwc db        0,0,0

SK1MLTit db        14,'c°l kop°rov†n°'

HelpS    SEGMENT   BYTE PUBLIC
SK1MLHlp db        3,1
         dw        SK1MLHl0
         db        31,'Kop°rov†n° ',1
SK1MLHlX dw        SK1MLHl1
         db        ' do zadanÇho c°le'

         db        3,1
         dw        SK1MLHlC

         db        26,'V®echna dlouh†',1
         dw        SK1MLHlA
         db        'kr†tk†',1
         dw        SK1MLHlB

         db        42,'Uchov†vat/modifikovat datum a áas adres†©ñ'

         db        3,1
         dw        MenuHlP1
HelpS    ENDS

SK1MLHlA db        32,' jmÇna souborñ budou zmànàna na '
SK1MLHlB db        15,' (WINDOWS 95)'
SK1MLHlC db        42,'Automatickò p©epis star®°ch souborñ novòmi'

SK1MLExe dd        Lin0MenR                 ; ©†dky
         dd        Lin0MenR                 ; start
         dd        SKMnLExA                 ; aktualizace
         dd        SKMnLExK                 ; kr†tk† jmÇna
         dd        SKMnLExD                 ; datum
         dd        Lin0MenR                 ; n†vrat

SK1MLHl0 db        59,'Syntaxe: adres†©\maska  / ASHR ashr  Ddatum  Táas'
SK1MLHl1 db        7,'souboru'
SK1MLHl2 db        8,'adres†©e'
SK1MLHl5 db        16,'souborñ/adres†©ñ'

CopyTabH label     word                     ; tabulka n†povàd menu
         dw        SK1MLHL1                 ; kurzor - soubor
         dw        SK1MLHL2                 ; kurzor - adres†©
         dw        SK1MLHL5                 ; 1 oznaáenò soubor/adres†©
         dw        SK1MLHL5                 ; 2 aë 4 oznaáenÇ poloëky
         dw        SK1MLHL5                 ; 5 a v°ce oznaáenòch poloëek
         dw        SK1MLHL5                 ; v®echny soubory
         dw        SK1MLHL5                 ; v®echny soubory a adres†©e
         dw        SK1MLHL5                 ; zadanÇ

CopyTbPA label     word                     ; tabulka poloëek menu - A
         dw        SK1MLPA1                 ; kurzor - soubor
         dw        SK1MLPA2                 ; kurzor - adres†©
         dw        SK1MLPB1                 ; 1 oznaáenò soubor/adres†©
         dw        SK1MLPB1                 ; 2 aë 4 oznaáenÇ poloëky
         dw        SK1MLPB1                 ; 5 a v°ce oznaáenòch poloëek
         dw        SK1MLPB1                 ; v®echny soubory
         dw        SK1MLPB1                 ; v®echny soubory a adres†©e
         dw        SK1MLPB1                 ; zadanÇ

CopyTbPB label     word                     ; tabulka poloëek menu - B
         dw        SK1MLPB1                 ; kurzor - soubor
         dw        SK1MLPB1                 ; kurzor - adres†©
         dw        SK1MLPB2                 ; 1 oznaáenò soubor/adres†©
         dw        SK1MLPB3                 ; 2 aë 4 oznaáenÇ poloëky
         dw        SK1MLPB4                 ; 5 a v°ce oznaáenòch poloëek
         dw        SK1MLPB5                 ; v®echny soubory
         dw        SK1MLPB6                 ; v®echny soubory a adres†©e
         dw        SK1MLPB7                 ; zadanÇ

; -----------------------------------------------------------------------------
;     hl†®en° - existuje soubor stejnÇho jmÇna jako kop°rovanò soubor
; -----------------------------------------------------------------------------

CopyLD2  label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        6                        ; poáet platnòch poloëek menu
         dw        14                       ; celkovò poáet poloëek menu

         dw        CopyLD2P                 ; zaá†tek definice poloëek menu
         dw        CopyLD2H                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@KopirovaniSouboru    ; á°slo str†nky velkÇ n†povàdy
         dw        CopyLD2B                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        CopyLD2T                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        6                        ; poá†teán° ©†dek okna
         db        69                       ; ®°©ka okna
         db        13                       ; vò®ka okna

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

CopyLD2P db        bit6,42,'Existuje jië soubor stejnÇho jmÇna '
         db        0,1
         dw        FileTxtP
         db        0,' !'

         db        bit6,9
CopLD2PA db        1
         dw        CopLD2P1
         db        1
         dw        CopLD2P0
         db        1
         dw        CopLD2P0

         db        bit6+bit7,0

         db        bit6,38,'              zdrojovò:   p©episovanò:'
CopLD2PV db        bit6,39,'Velikost: ',0,'                            '
CopLD2PD db        bit6,39,'   Datum: ',0,'                            '
CopLD2PT db        bit6,39,'     Äas: ',0,'                            '

         db        bit6+bit7,0
         db        1,7,'P©epsat'
         db        1,7,'V®echny'
         db        1,5,'Dal®°'
         db        1,12,'Nep©episovat'
         db        1,7,'Slouáit'
         db        1,5,'Konec'

CopLD2P0 db        0
CopLD2P1 db        30,'Parametry souborñ jsou shodnÇ.'
CopLD2P2 db        20,'Zdrojovò soubor je ',0
CopLD2P3 db        7,'novàj®°'
CopLD2P4 db        6,'star®°'
CopLD2P5 db        5,'vàt®°'
CopLD2P6 db        5,'men®°'
CopLD2P7 db        18,0,' neë p©episovanò.'

HelpS    SEGMENT   BYTE PUBLIC
CopyLD2H db        54,'P©epsat c°lovò soubor kop°rovanòm/p©esouvanòm souborem'
         db        45,'P©epsat v®echny existuj°c° soubory bez dotazu'
         db        39,'Nep©episovat soubor a pokraáovat dal®°m'
         db        42,'Nep©episovat ë†dnò dal®° existuj°c° soubor'
         db        65,'P©idat kop°rovanò/p©esouvanò soubor na konec existuj°c°ho souboru'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

CopyLD2T db        15,'soubor existuje'

CopyLD2B db        0,0,0,0,0,0

; -----------------------------------------------------------------------------
;        na disku bude nedostatek m°sta ke zkop°rov†n° celÇho souboru
; -----------------------------------------------------------------------------
;˛
CopL3Lin label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka volby
         dw        4                        ; poáet platnòch poloëek menu
         dw        11                       ; celkovò poáet poloëek menu

         dw        CopL3Pol                 ; adresa definián° tabulky poloëek
         dw        CopL3Hlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@KopirovaniSouboru    ; á°slo str†nky velkÇ n†povàdy
         dw        CopL3Blk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        CopL3Tit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        6                        ; poá†teán° pozice
         db        7                        ; poá†teán° ©†dek
         db        68                       ; ®°©ka
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

CopL3Pol db        bit6,58,'Na disku ',0
CopL3Pl1 db        'A:',0,' ',1
CopL3P11 dw        CopL3P16
         db        ' dost m°sta ke zkop°rov†n° souboru ',0,1
         dw        FileTxtP
         db        0,'.'

         db        bit6,3,1
CopL3P12 dw        CopL3P17

         db        bit6+bit7,0
CopL3Pl2 db        bit6,38,'celkov† kapacita disku: ',0,'             '
CopL3Pl3 db        bit6,38,'  volnÇ m°sto na disku: ',0,'             '
CopL3Pl4 db        bit6,38,'poëadovanÇ volnÇ m°sto: ',0,'             '

         db        bit6+bit7,0
         db        1,10,'Pokraáovat'
         db        1,5,'Dal®°'
         db        1,9,'Novò disk'
         db        1,5,'Konec'

HelpS    SEGMENT   BYTE PUBLIC
CopL3Hlp db        77,'Pokraáov†n° uloëen°m souboru nebo jeho á†sti do velikosti volnÇho m°sta disku'
         db        56,'Soubor se nebude kop°rovat - pokraáov†n° dal®°m souborem'
         db        48,'Zobrazen° informac° o novÇm disku po jeho vòmànà'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

CopL3P16 db        4,'nen°'
CopL3P17 db        2,'je'
CopL3P18 db        48,'Vymà§te disk nebo rozdàlte soubor na v°ce á†st°.'
CopL3P19 db        28,'Mñëete pokraáovat v operaci.'

CopL3Blk db        0,0,0,0

CopL3Tit db        9,'disk plnò'

; -----------------------------------------------------------------------------
;        nalezen° souboru s atributem R/O
; -----------------------------------------------------------------------------

CopL4Lin label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka volby
         dw        5                        ; poáet platnòch poloëek menu
         dw        8                        ; celkovò poáet poloëek menu

         dw        CopL4Pol                 ; adresa definián° tabulky poloëek
         dw        CopL4Hlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@KopirovaniSouboru    ; á°slo str†nky velkÇ n†povàdy
         dw        CopL4Blk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        CopL4Tit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        6                        ; poá†teán° pozice
         db        7                        ; poá†teán° ©†dek
         db        64                       ; ®°©ka
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

CopL4Pol db        bit6,52,'Soubor ',0,1
         dw        FileTxtP                 ; buffer jmÇna souboru
         db        0,' je chr†nàn proti p©episu atributem R/O.'

         db        bit6,33,'P©ejete si jej i p©esto p©epsat ?'

         db        bit6+bit7,0
         db        1,7,'P©epsat'
         db        1,7,'V®echny'
         db        1,5,'Dal®°'
         db        1,12,'Nep©episovat'
         db        1,5,'Konec'

CopL4Blk db        0,0,0,0,0

CopL4Tit db        11,'atribut R/O'

HelpS    SEGMENT   BYTE PUBLIC
CopL4Hlp db        50,'P©epis tohoto souboru (s nulov†n°m atributu R/O)'
         db        63,'P©epis v®ech n†sleduj°c°ch souborñ s atributem R/O bez dotazu'
         db        43,'Pokraáov†n° d†le bez p©episu tohoto souboru'
         db        56,'Nep©episovat ë†dnò dal®° soubor oznaáenò atributem R/O'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

; -----------------------------------------------------------------------------
;        p©esun souborñ
; -----------------------------------------------------------------------------
;˛
SJMnVert label     byte

         db        2                        ; typ menu - vertik†ln° podmenu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka volby
         dw        5                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        SKMnVPol                 ; definián° tabulka poloëek
         dw        SJMnVHlp                 ; n†povàda
         dw        Hlp@MenuPrejmenovaniAPresun ; á°slo str†nky velkÇ n†povàdy
         dw        SJMnVBlk                 ; blokovac° tabulka
         dw        0                        ; p©ep°naáe
         dw        SJMnVTit                 ; adresa titulu okna
         dw        SJMnVExe                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        36                       ; poá†teán° pozice
         db        10                       ; poá†teán° ©†dek
         db        20                       ; ®°©ka okna
         db        7                        ; vò®ka okna

SJMnVBlk db        0,0,0,0,0

SJMnVTit db        12,'jmÇno/p©esun'

HelpS    SEGMENT   BYTE PUBLIC
SJMnVHlp db        65,'P©ejmenov†n°/p©esun souboru nebo adres†©e pod kurzorem (Alt-F6)'
         db        56,'P©ejmenov†n°/p©esun oznaáenòch souborñ a adres†©ñ (F6)'
         db        49,'P©ejmenov†n°/p©esun v®ech souborñ v aktivn°m oknà'
         db        60,'P©ejmenov†n°/p©esun v®ech souborñ a adres†©ñ v aktivn°m oknà'
         db        76,'P©ejmenov†n°/p©esun souborñ a adres†©ñ podle blië®° specifikace (Shift-F6)'
HelpS    ENDS

SJMnVExe label     dword                    ; obsluhy voleb
         dd        MoveFil                  ; kurzor
         dd        MoveFil                  ; oznaáenÇ
         dd        MoveFil                  ; adres†©
         dd        MoveFil                  ; podadres†©e
         dd        MoveFil                  ; zadanÇ

; -----------------------------------------------------------------------------
;       Volba souborñ k p©esunu
; -----------------------------------------------------------------------------

SJZMLin  label     byte

         db        3                        ; typ menu - ©†dkovÇ podmenu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        SJZMLPol                 ; zaá†tek definice poloëek menu
         dw        SJZMLHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@VyberSouboru         ; á°slo str†nky velkÇ n†povàdy
         dw        SJZMLBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        SJZMLTit                 ; adresa titulu okna
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

SJZMLPol db        bit6,39,'Zadejte soubory k p©ejmenov†n°/p©esunu:'
         db        0,0
         db        bit6+bit7,0
         db        1,6,'ProveÉ'
         db        1,6,'N†vrat'

SJZMLBlk db        0,0,0                    ; blokovac° tabulka

SJZMLTit db        6,'zadanÇ'

; ------ n†povàda

HelpS    SEGMENT   BYTE PUBLIC
SJZMLHlp db        3,1
         dw        MenuFndH
         db        47,'P©ejmenov†n°/p©esun zadanòch souborñ a adres†©ñ'
         db        3,1
         dw        MenuHlP1
HelpS    ENDS

; -----------------------------------------------------------------------------
;       Volba c°le p©esunu
; -----------------------------------------------------------------------------

SJ1MLin  label     byte

         db        3                        ; typ menu - ©†dkovÇ podmenu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        6                        ; poáet platnòch poloëek menu
         dw        8                        ; celkovò poáet poloëek menu

         dw        SJ1MLPol                 ; zaá†tek definice poloëek menu
         dw        SJ1MLHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@Prejmenovaniapresun  ; á°slo str†nky velkÇ n†povàdy
         dw        SJ1MLBlk                 ; adresa blokovac° tabulky
         dw        SJ1MLSwc                 ; adresa tabulky p©ep°naáñ
         dw        SJ1MLTit                 ; adresa titulu okna
         dw        SK1MLExe                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        70                       ; ®°©ka okna
         db        8                        ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        1                        ; celkovò poáet ©†dkñ
         dw        1                        ; poáet zobrazenòch ©†dkñ

         db        bit2                     ; v®echny znaky (kvñli dlouhòm jmÇnñm)
         db        0,'      '               ; zak†zanÇ znaky

         db        HistFile                 ; identifik†tor historie

SJ1MLnPN db        0                        ; poáet p©edvoleb

         dw        0                        ; dÇlka p©edvolby
         dd        0                        ; p©edvolba 1
         dw        0
         dd        0                        ; p©edvolba 2

; ------ poloëky voleb

SJ1MLPol db        bit6,36,'P©ejmenuji/p©esunu '
         db        1
SJ1MLPlA dw        SK1MLPA1
         db        4,0,1
         dw        FileTxtP                 ; parametr
         db        0,4,1
SJ1MLPlB dw        SK1MLPB1
         db        ' do:'

         db        0,0
         db        bit6+bit7,0
         db        1,6,'ProveÉ'
         db        bit7+1,14,'Aktualizovat '
SJ1MLPl0 db        '-'
         db        bit7+1,8,'Kr†tk† '
SJ1MLPl1 db        '-'
         db        bit7+1,7,'Datum '
SJ1MLPl2 db        '-'
         db        1,6,'N†vrat'

SJ1MLBlk db        0,0,0,0,0,0              ; blokovac° tabulka
SJ1MLSwc db        0,0,0

SJ1MLTit db        24,'c°l p©ejmenov†n°/p©esunu'

HelpS    SEGMENT   BYTE PUBLIC
SJ1MLHlp db        3,1
         dw        SK1MLHl0
         db        40,'P©ejmenov†n°/p©esun ',1
SJ1MLHlX dw        SK1MLHl1
         db        ' do zadanÇho c°le'

         db        3,1
         dw        SK1MLHlC

         db        26,'V®echna dlouh†',1
         dw        SK1MLHLA
         db        'kr†tk†',1
         dw        SK1MLHlB

         db        42,'Uchov†vat/modifikovat datum a áas adres†©ñ'

         db        3,1
         dw        MenuHlP1
HelpS    ENDS

; -----------------------------------------------------------------------------
;        data pro kop°rov†n° souborñ
; -----------------------------------------------------------------------------

CopyParD db        0                        ; parametry pro kop°rov†n°
                                            ;  bit 0: 1=c°lovò soubor byl vytvo©en
                                            ;         (aby jej bylo moënÇ zru®it
                                            ;          p©i ne£spà®nÇ operaci)
                                            ;  bit 1: 1=neplatnÇ disk. informace
                                            ;  bit 2: 1=p©episovanò soubor zru®en
                                            ;         (nelze jej jië pouë°t ke
                                            ;          zvò®en° volnÇho m°sta)
                                            ;  bit 3: 1=vytvo©en p©echodnò soubor
                                            ;  bit 4:
                                            ;  bit 5: 1=kop°rov†n°
                                            ;  bit 6: 1=p©esun mezi disky
                                            ;  bit 7: 1=p©esun na disku

;CopyPrD2 db        bit2                     ; parametry pro kop°rov†n° a p©esun
;                                            ;  bit 0: 1=aktualizace souborñ
;                                            ;  bit 1: 1=zmàna na kr†tk† jmÇna
;                                            ;  bit 2: 1=uchov†vat datum a áas adres†©ñ
;
;                                            ;  bit 5: 1=c°l m† dlouhÇ jmÇno
;                                            ;  bit 6: 1=dlouh† maska se neuplatn°
;                                            ;         (nastaveno v InitFCil)
;                                            ;  bit 7: 1=c°lovÇ jmÇno zru®eno
;                                            ;         (nastaveno v InitFCil)

ExistPar db        0                        ; parametry pro existuj°c° soubor
                                            ;  bit 0: 1=byl nalezen c°lovò soubor
                                            ;          (nenuluje se p©i zru®en°
                                            ;           souboru a nenastavuje se
                                            ;           p©i vytvo©en° souboru)
                                            ;  bit 1: 1=p©epis souboru
                                            ;  bit 2: 1=p©epis v®ech souborñ
                                            ;  bit 3: 1=p©eskoáen° souboru
                                            ;  bit 4: 1=p©eskoáen° v®ech souborñ
                                            ;  bit 5: 1=p©ipojen° souboru
                                            ;  bit 6: 1=c°lem znakovÇ za©°zen°
                                            ;  bit 7: 1=pokraáov†n° dal®°m diskem
                                            ;         (byl dokonáen z†pis na jeden
                                            ;          disk, bude nutnò dal®° disk)

CopyRusP db        0                        ; parametry pro ru®en° p©i kop°r.
                                            ;  bit 0: 1=p©episovat v®echny R/O
                                            ;  bit 1: 1=p©eskoáit v®echny R/O

CopyDFre dd        0                        ; volnÇ m°sto disku
CopyDFr0 dd        0                        ; volnÇ m°sto po p©episu souboru
CopyDMax dd        0                        ; celkov† kapacita disku
CopyDBlk dw        0                        ; velikost jednoho bloku disku
CopyDSiz dd        0                        ; zbòvaj°c° velikost souboru
CopyDRea dd        0                        ; ukazatel naátenòch dat ze souboru
CopyDUlo dd        0                        ; á°taá uloëenòch dat na 1 disku

CilTempF db        FileMax+1 dup(0)         ; p©echodnò c°lovò soubor

;FileIdnt dw        0                        ; identifik†tor zdrojovÇho souboru
;CilIdent dw        0                        ; identifik†tor c°lovÇho souboru

CilDTA   label     byte
         db        DTAMax dup(0)            ; buffer DTA p©episovanÇho souboru

; ------ poloëka simuluj°c° poloëku seznamu souborñ

CilFPol  label     byte
CilFAtr  db        0                        ; atributy nalezenÇho souboru
CilFCB   db        11 dup(0)                ; jmÇno souboru ve tvaru FCB
CilFSize dd        0                        ; velikost nalezenÇho souboru
CilFDate dw        0                        ; datum nalezenÇho souboru
CilFTime dw        0                        ; áas nalezenÇho souboru
CilFPol0 label     byte

CopyTxt1 db        10,'Kop°ruji ',0
CopyTxt2 db        6,0,' do ',0
MoveTxt1 db        11,'P©esouv†m ',0
CopL3Dsk db        28,'Naá°t†m informace o disku '
CopL3Ds2 db        'A:'

Data     ENDS
         END
